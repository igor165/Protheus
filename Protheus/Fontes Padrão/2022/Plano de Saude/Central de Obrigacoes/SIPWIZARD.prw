#include "protheus.ch"
#include "topconn.ch"

#define CRLF chr(13) + chr(10)
#define TITLE_MODAL "SipWizard"
#define URL "https://cobprostorage.blob.core.windows.net/files/SIGACEN/sip/"
#define GRUGEN_DEFAULT "0001"
#define CSV_NATUREZA 1

static __aWarningsSIP := {}

/*/{Protheus.doc} SIPWIZARD
Rotina wizard para auxilio na configuração do SIP para central de obrigações.

@owner TOTVS

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@param lReport, logical, Se .t. rotina foi chamada apenas para gerar relatório.
/*/
function SIPWIZARD(lReport)
    local lFiles := .t.

    private __aFilesCSV := {"bf0-sipwizard.csv", "sip-vs-tuss.csv"}
    private __cMV
    private __lUserView
    private __cPathWizard := plsmudsis("/sipwizard/")

    default lReport := .f.

    __lUserView := ! lReport

    if __lUserView
        if ! msgyesno("Deseja iniciar o processo de analise e correção do SIPWizard?", TITLE_MODAL)
            return
        endif 
    endif 

    processa( {|| lFiles := chkFiles() }, "Validando arquivos")
    if ! lFiles ; return ; endif
    
    processa( {|| validAll() }, "Validando informações")

    if __lUserView
        if empty(__aWarningsSIP)
            msginfo("SipWizard executado com sucesso, sem nenhuma critica.", TITLE_MODAL)
        else
            msgalert("SipWizard encontrou algumas criticas, imprima o relatório a seguir.", TITLE_MODAL)
            reportSW(.t.)
        endif 
    endif
return 


/*/{Protheus.doc} chkFiles
Função responsável por realizar a verificação dos arquivos CSVs usados no processo, 
assim como realizar download dos mesmos caso não sejam encontrados no diretorio correto.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@return lValid, logical, Status da verificação.
/*/
static function chkFiles()
    local lValid := .t.
    local cFileZip := "csv-sipwizard.zip"
    local aCSVs := directory(__cPathWizard + "*.csv")
    local oWzFiles 

    procregua(2)
    incproc("Validando arquivos...")
	processmessage()

    if empty(aCSVs)
        lValid := .f.
    else 
        lValid := validFiles(aCSVs)
    endif 

    if ! lValid
        incproc("Baixando arquivos...")
	    processmessage() 
        oWzFiles := prjwzfiles():new(__cPathWizard, cFileZip)
        if oWzFiles:getwdclient(URL, cFileZip)
            funzip(__cPathWizard + cFileZip, __cPathWizard)
            ferase(__cPathWizard + cFileZip)
            lValid := .t.
        else
            ferase(__cPathWizard + cFileZip)

            msgalert("Não foi possível realizar o download dos arquivos CSV. Execute os passos abaixo e clique em 'Fechar' para continuar o processo: " + replicate(CRLF, 2) +;
                        " > Realize o download através do link:" + CRLF +;
                        URL + replicate(CRLF, 2) +;
                        " > Descompacte os arquivos na pasta '" + __cPathWizard + "'." + replicate(CRLF, 3) +;
                        "OBS.: Deixe essa janela aberta enquanto realiza a os passos citados." ;
            )

            lValid := validFiles(aCSVs)
            
            if ! lValid 
                msgstop("Você não realizou os passos acima, os arqivos ainda não se encontram na pasta '" + __cPathWizard + "'.")
            endif
        endif 

        freeobj(oWzFiles)
    endif 

return lValid 


/*/{Protheus.doc} validFiles
Função realiza a análise dos arquivos encontrados no diretório, afim de verificar se todos estão presentes.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@param aCSVs, array, Array com os arquivos encontrados no diretório.

@return lValid, logical, Status da verificação.
/*/
static function validFiles(aCSVs)
    local lValid := .t. 
    local nX 

    for nX := 1 to len(__aFilesCSV)
        lValid := iif( ascanx(aCSVs, {|y| upper(rtrim(y[1])) == upper(__aFilesCSV[nX])}) = 0, .f., lValid )
    next nX
return lValid 


/*/{Protheus.doc} validAll
Função responsável pelo HUB de chamadas das validações.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0
/*/
static function validAll()
    procregua(5)

    incproc("Validando MV_PLGRSIP")
	processmessage()
    if validMV() /* MV_PLGRSIP */
        incproc("Validando Grupo Gerencial")
	    processmessage()
        validGPG() /* Grupo Gerencial 'BSB' */

        incproc("Validando Natureza de Saúde")
	    processmessage()
        validNat() /* Natureza de saúde 'BF0' */
    else 
        aadd(__aWarningsSIP, {"BSB", "Não foi possivel analisar Grupo Gerencial, pois o parametro MV_PLGRSIP não está configurado.", 0})
        aadd(__aWarningsSIP, {"BF0", "Não foi possivel analisar Natureza de Saúde, pois o parametro MV_PLGRSIP não está configurado.", 0})
    endif 

    incproc("Validando Especialidades Médicas")
	processmessage()
    validEsp() /* Especialidades médicas 'BAQ' */

    incproc("Validando procedimentos TUSS")
	processmessage()
    validPro() /* Procedimentos */
return 


/*/{Protheus.doc} validMV
Função valida a existencia e conteúdo do parâmetro MV_PLGRSIP.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@return lValid, logical, Status da validação.
/*/
static function validMV()
    local lValid := .f.
    local cHash := md5(dtos(ddatabase)+time())
    
    __cMV := rtrim(getnewpar("MV_PLGRSIP", cHash))

    if __cMV == cHash /* MV não existe */
        if __lUserView
            if msgyesno("O parâmetro MV_PLGRSIP não existe. Deseja validar os dados com o conteúdo padrão '" + GRUGEN_DEFAULT + "' ?")
                lValid := .t.
                __cMV := GRUGEN_DEFAULT
            else 
                lValid := .f.
            endif 
        endif

        aadd(__aWarningsSIP, {"SX6", "O parâmetro MV_PLGRSIP não existe.", 0})
    else 
        if empty(__cMV) /* MV existe, porém sem conteúdo */
            if __lUserView
                if msgyesno("O parâmetro MV_PLGRSIP está sem conteúdo. Deseja inserir o conteúdo padrão '" + GRUGEN_DEFAULT + "' ?")
                    putmv("MV_PLGRSIP", GRUGEN_DEFAULT) //TODO valida se a função PUTMV está correta
                    __cMV := GRUGEN_DEFAULT
                    lValid := .t.
                endif
            endif 

            if ! lValid
                aadd(__aWarningsSIP, {"SX6", "O parâmetro MV_PLGRSIP está sem conteúdo.", 0})
            endif 
        else 
            lValid := .t.
        endif 
    endif
return lValid


/*/{Protheus.doc} validGPG
Função realiza a validação do Grupo Gerencial com base no grupo definido no MV_PLGRSIP.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@param lAuto, logical, Indica que a função foi chamada pela automação de teste.

@return nil, nil, Por padrão 'nil'.
/*/
static function validGPG(lAuto)
    local lValid := .f. 

    default lAuto := .f.

    BSB->(dbsetorder(1)) /* Indice: BSB_FILIAL+BSB_CODIGO */
    if ! BSB->(dbseek(xfilial("BSB") + __cMV))
        if __lUserView
            if msgyesno("Grupo Gerencial informado no MV não existe. Deseja inserir um registro para o grupo '" + __cMV + "' ?")
                grvData("BSB", {;
                    {"BSB_FILIAL", xfilial("BSB")},;
                    {"BSB_CODIGO", __cMV},;
                    {"BSB_DESCRI", "GRUPO GERENCIAL PADRAO"},;
                    {"BSB_CODPAD", ""};
                })
                lValid := .t.
            endif 
        endif 
        
        if ! lValid
            aadd(__aWarningsSIP, {"BSB", "Grupo Gerencial '" + __cMV + "' não encontrado."})
        endif 
    endif 
    BSB->(dbclosearea())
return iif(lAuto, __aWarningsSIP, nil)


/*/{Protheus.doc} validNat
Função valida os registros de natureza de saúde, tabela BF0.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@param lAuto, logical, Indique a função foi chamada pela automação de teste.

@return nil, nil, Por padrão 'nil'.
/*/
static function validNat(lAuto)
    local lValid := .f.
    local cAlias := getnextalias()

    default lAuto := .f.

    beginsql alias cAlias 
        SELECT R_E_C_N_O_ RECBF0
        FROM %table:BF0%
        WHERE BF0_FILIAL = %xfilial:BF0%
            AND BF0_GRUGEN = %exp:__cMV%
            AND %notdel%
    endsql 

    if (cAlias)->(eof())
        if __lUserView
            if msgyesno("Não existem natureza de saúde cadastradas para o Grupo gerencial '" + __cMV + "'. Deseja importar o padrão?")
                impNatu("BF0")
                lValid := .t.
            endif 
        endif 

        if ! lValid
            aadd(__aWarningsSIP, {"BF0", "Não existem naturezas de saúde (BF0) cadastradas para o grupo gerencial '" + __cMV + "' (BSB).", 0})
        endif
    else
        bdVsCSV(CSV_NATUREZA)
    endif 

    (cAlias)->(dbclosearea())
return iif(lAuto, __aWarningsSIP, nil)


/*/{Protheus.doc} impNatu 
Função realiza a importação de registros de natureza de saúde presentes em um arquivo CSV.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@param cAlias, caracter, Alias aonde os dados serão importados.
/*/
static function impNatu(cAlias)
    local oFileCSV
    local aLine 
    local aDataBF0
    local cFile

    aDataBF0 := {}
    cFile := plsmudsis(__cPathWizard + __aFilesCSV[1])

    oFileCSV := fwfilereader():new(cFile)
    if oFileCSV:open()
        oFileCSV:hasline()
        oFileCSV:getline()
        while oFileCSV:hasline()
            aLine := strtokarr2(oFileCSV:getline(), ";", .t.)
            aadd(aDataBF0, {;
                {"BF0_FILIAL", xfilial("BF0")},;
                {"BF0_GRUGEN", __cMV},;
                {"BF0_CODSUP", aLine[2]},;
                {"BF0_CODIGO", aLine[3]},;
                {"BF0_DESCRI", upper(aLine[4])},;
                {"BF0_CLASSE", aLine[5]},;
                {"BF0_NIVEL", aLine[6]},;
                {"BF0_IMPRIM", aLine[7]},;
                {"BF0_IDADE1", val(aLine[8])},;
                {"BF0_IDADE2", val(aLine[9])},;
                {"BF0_SEXO", aLine[10]},;
                {"BF0_BENEF", aLine[11]},;
                {"BF0_DESSIP", aLine[12]};
            })
        enddo
        oFileCSV:close()
    endif 

    msgrun("Importando natureza de saúde...", TITLE_MODAL, {|| aeval(aDataBF0, {|x| grvData(cAlias, x)}) })
    
    freeobj(oFileCSV)
return


/*/{Protheus.doc} bdVsCSV
Função que cria uma tabela temporária e aciona a importação dos dados, afim de realizar a chamada da função
que analisa e compara os dados das tabelas do Banco com a temporária recem criada.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@param nType, numeric, Indica o tipo de dados que será validado.
/*/
static function bdVsCSV(nType)
    local oTable

    do case 
        case nType = CSV_NATUREZA
            oTable := newTable("BF0TMP", fieldBF0(), {"BF0_FILIAL","BF0_GRUGEN","BF0_CODSUP","BF0_CODIGO"})
            impNatu(oTable:getalias())
            difTbBF0("BF0", oTable:getalias())

    endcase
return 


/*/{Protheus.doc} newTable
Realiza a criação de uma tabela temporária.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@param cName, caracter, Nome da tabela.
@param aFields, array, Array com os campos que vão compor a tabela.
@param aIndex, array, Array com o indice para a nova tabela.

@return oTbTmp, object, Objeto instanciado da classe 'fwtemporarytable'.
/*/
static function newTable(cName, aFields, aIndex)
    local oTbTmp

    oTbTmp := fwtemporarytable():new(cName)
    oTbTmp:setfields(aFields)
    oTbTmp:addindex("01", aIndex)
    oTbTmp:create()
return oTbTmp


/*/{Protheus.doc} fieldBF0
Função responsável por definir os campos para a tabela temporária.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@return aFields, array, Array com os campos.
/*/
static function fieldBF0()
    local aFields := {;
        {"BF0_FILIAL", "C", 2, 0},;
        {"BF0_GRUGEN", "C", 4, 0},;
        {"BF0_CODSUP", "C", 7, 0},;
        {"BF0_CODIGO", "C", 7, 0},;
        {"BF0_DESCRI", "C", 30, 0},;
        {"BF0_CLASSE", "C", 1, 0},;
        {"BF0_NIVEL", "C", 1, 0},;
        {"BF0_IMPRIM", "C", 1, 0},;
        {"BF0_IDADE1", "N", 3, 0},;
        {"BF0_IDADE2", "N", 3, 0},;
        {"BF0_SEXO", "C", 1, 0},;
        {"BF0_BENEF", "C", 1, 0},;
        {"BF0_DESSIP", "C", 60, 0};
    }
return aFields


/*/{Protheus.doc} difTbBF0
Função responsável por realizar a comparação de registros presentes no banco de dados com seu similar
na tabela temporária.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@param cAliasBD, caracter, Alias do banco de dados.
@param cAliasTMP, caracter, Alias da tabela temporária.
/*/
static function difTbBF0(cAliasBD, cAliasTMP)
    local lValid := .f.
    local cFilBF0 := xfilial("BF0")
    local aMatCol
    local aNatReg := {}
    local aNatDif := {}
    local nI

    (cAliasBD)->(dbsetorder(1)) /* Indice: BF0_FILIAL + BF0_GRUGEN + BF0_CODIGO */
    (cAliasBD)->(dbgotop())

    (cAliasTMP)->(dbgotop())
    while ! (cAliasTMP)->(eof())
        if (cAliasBD)->(msseek(cFilBF0 + (cAliasTMP)->(BF0_GRUGEN + BF0_CODIGO) ))
            if (cAliasBD)->BF0_CODSUP <> (cAliasTMP)->BF0_CODSUP 
                aadd(aNatDif, {"BF0_CODSUP", (cAliasBD)->BF0_CODSUP, (cAliasTMP)->BF0_CODSUP, alltrim(str((cAliasBD)->(recno()))), .t.})
            endif 

            if (cAliasBD)->BF0_DESCRI <> (cAliasTMP)->BF0_DESCRI 
                aadd(aNatDif, {"BF0_DESCRI", (cAliasBD)->BF0_DESCRI, (cAliasTMP)->BF0_DESCRI, alltrim(str((cAliasBD)->(recno()))), .t.})
            endif 

            if (cAliasBD)->BF0_CLASSE <> (cAliasTMP)->BF0_CLASSE 
                aadd(aNatDif, {"BF0_CLASSE", (cAliasBD)->BF0_CLASSE, (cAliasTMP)->BF0_CLASSE, alltrim(str((cAliasBD)->(recno()))), .t.})
            endif 

            if (cAliasBD)->BF0_NIVEL <> (cAliasTMP)->BF0_NIVEL 
                aadd(aNatDif, {"BF0_NIVEL", (cAliasBD)->BF0_NIVEL, (cAliasTMP)->BF0_NIVEL, alltrim(str((cAliasBD)->(recno()))), .t.})
            endif 

            if (cAliasBD)->BF0_IMPRIM <> (cAliasTMP)->BF0_IMPRIM
                aadd(aNatDif, {"BF0_IMPRIM", (cAliasBD)->BF0_IMPRIM, (cAliasTMP)->BF0_IMPRIM, alltrim(str((cAliasBD)->(recno()))), .t.})
            endif 

            if (cAliasBD)->BF0_IDADE1 <> (cAliasTMP)->BF0_IDADE1
                aadd(aNatDif, {"BF0_IDADE1", alltrim(str((cAliasBD)->BF0_IDADE1)), alltrim(str((cAliasTMP)->BF0_IDADE1)), alltrim(str((cAliasBD)->(recno()))), .t.})
            endif 

            if (cAliasBD)->BF0_IDADE2 <> (cAliasTMP)->BF0_IDADE2
                aadd(aNatDif, {"BF0_IDADE2", alltrim(str((cAliasBD)->BF0_IDADE2)), alltrim(str((cAliasTMP)->BF0_IDADE2)), alltrim(str((cAliasBD)->(recno()))), .t.})
            endif 

            if (cAliasBD)->BF0_SEXO <> (cAliasTMP)->BF0_SEXO
                aadd(aNatDif, {"BF0_SEXO", (cAliasBD)->BF0_SEXO, (cAliasTMP)->BF0_SEXO, alltrim(str((cAliasBD)->(recno()))), .t.})
            endif 

            if (cAliasBD)->BF0_BENEF <> (cAliasTMP)->BF0_BENEF
                aadd(aNatDif, {"BF0_BENEF", (cAliasBD)->BF0_BENEF, (cAliasTMP)->BF0_BENEF, alltrim(str((cAliasBD)->(recno()))), .t.})
            endif 

            if (cAliasBD)->BF0_DESSIP <> (cAliasTMP)->BF0_DESSIP
                aadd(aNatDif, {"BF0_DESSIP", (cAliasBD)->BF0_DESSIP, (cAliasTMP)->BF0_DESSIP, alltrim(str((cAliasBD)->(recno()))), .t.})
            endif 
        else 
            aadd(aNatReg, {;
                (cAliasTMP)->BF0_GRUGEN,;
                (cAliasTMP)->BF0_CODSUP,;
                (cAliasTMP)->BF0_CODIGO,;
                (cAliasTMP)->BF0_DESCRI,;
                (cAliasTMP)->BF0_CLASSE,;
                (cAliasTMP)->BF0_NIVEL,;
                (cAliasTMP)->BF0_IMPRIM,;
                alltrim(str((cAliasTMP)->BF0_IDADE1)),;
                alltrim(str((cAliasTMP)->BF0_IDADE2)),;
                (cAliasTMP)->BF0_SEXO,;
                (cAliasTMP)->BF0_BENEF,;
                (cAliasTMP)->BF0_DESSIP,;
                .t.;
            })
        endif 
        (cAliasTMP)->(dbskip())
    enddo 

    if ! empty(aNatReg)
        aMatCol := {}
        aadd(aMatCol, {"BF0_GRUGEN", "@C", 10, .t.})
        aadd(aMatCol, {"BF0_CODSUP", "@C", 10, .t.})
        aadd(aMatCol, {"BF0_CODIGO", "@C", 10, .t.})
        aadd(aMatCol, {"BF0_DESCRI", "@C", 10, .t.})
        aadd(aMatCol, {"BF0_CLASSE", "@C", 10, .f.})
        aadd(aMatCol, {"BF0_NIVEL", "@C", 10, .f.})
        aadd(aMatCol, {"BF0_IMPRIM", "@C", 10, .f.})
        aadd(aMatCol, {"BF0_IDADE1", "@C", 10, .f.})
        aadd(aMatCol, {"BF0_IDADE2", "@C", 10, .f.})
        aadd(aMatCol, {"BF0_SEXO", "@C", 10, .f.})
        aadd(aMatCol, {"BF0_BENEF", "@C", 10, .f.})
        aadd(aMatCol, {"BF0_DESSIP", "@C", 10, .f.})
        
        if __lUserView
            if msgyesno("Algumas classificações não foram encontradas. Deseja analisar para importar?", TITLE_MODAL)
                if PLSSELOPT("Selecione o(s) registros para importação", "Marca e Desmarca todos", aNatReg, aMatCol,, .t., .t., .f.)
                    if msgyesno("Confirma importaçao dos registros selecionados?", TITLE_MODAL)
                        for nI := 1 to len(aNatReg)
                            if atail(aNatReg[nI])
                                grvData("BF0", {;
                                    {"BF0_FILIAL", cFilBF0},;
                                    {"BF0_GRUGEN", aNatReg[nI,1]},;
                                    {"BF0_CODSUP", aNatReg[nI,2]},;
                                    {"BF0_CODIGO", aNatReg[nI,3]},;
                                    {"BF0_DESCRI", aNatReg[nI,4]},;
                                    {"BF0_CLASSE", aNatReg[nI,5]},;
                                    {"BF0_NIVEL", aNatReg[nI,6]},;
                                    {"BF0_IMPRIM", aNatReg[nI,7]},;
                                    {"BF0_IDADE1", val(aNatReg[nI,8])},;
                                    {"BF0_IDADE2", val(aNatReg[nI,9])},;
                                    {"BF0_SEXO", aNatReg[nI,10]},;
                                    {"BF0_BENEF", aNatReg[nI,11]},;
                                    {"BF0_DESSIP", aNatReg[nI,12]};
                                })
                            else 
                                aadd(__aWarningsSIP, {"BF0", "Natureza de saude para a classificação '" + aNatReg[nI,3] + "' não encontrada.", 0}) /* Usuário não selecionou o registro para importar. */
                            endif
                        next nI
                        lValid := .t.
                    else 
                        addCriBF0(aNatReg) /* Na janela de confirmação da importação o usuário clicou em 'Não'. */
                        lValid := .t.
                    endif 
                else 
                    addCriBF0(aNatReg) /* Na janela do markbrowse o usuário clicou em 'Fechar/Cancelar'. */
                    lValid := .t.
                endif 
            endif
        endif 

        if ! lValid 
            addCriBF0(aNatReg) /* Na janela de confirmação se deseja olhar as criticas o usuário clicou em 'Não'. */
        endif 
    endif 

    if ! empty(aNatDif)
        aMatCol := {}
        aadd(aMatCol, {"Campo", "@C", 10, .f.})
        aadd(aMatCol, {"Atual", "@C", 10, .f.})
        aadd(aMatCol, {"Correto", "@C", 10, .f.})
        aadd(aMatCol, {"RECNO", "@C", 10, .f.})

        if __lUserView
            if msgyesno("Encontramos registros de natureza de saude com problema. Deseja analisar para corrigir?", TITLE_MODAL)
                if PLSSELOPT("Selecione o(s) registros para correção", "Marca e Desmarca todos", aNatDif, aMatCol,, .t., .t., .f.)
                    if msgyesno("Confirma correção dos registros selecionados?", TITLE_MODAL)
                        dbselectarea("BF0")
                        for nI := 1 to len(aNatDif)
                            if atail(aNatDif[nI])
                                BF0->(dbgoto(val(aNatDif[nI,4])))
                                BF0->(reclock("BF0", .f.))
                                &("BF0->" + aNatDif[nI,1]) := iif(aNatDif[nI,1] $ "BF0_IDADE1|BF0_IDADE2", val(aNatDif[nI,3]), aNatDif[nI,3])
                                BF0->(msunlock())
                            else 
                                aadd(__aWarningsSIP, {"BF0", "Registro de natureza de saude inconsistente, campo '" + aNatDif[nI,1] + "' encontrado [" + alltrim(aNatDif[nI,2]) + "] esperado [" + alltrim(aNatDif[nI,3]) + "].", val(aNatDif[nI,4])})
                            endif 
                        next nI 
                        lValid := .t.
                    else 
                        addCriBF0(aNatDif, .t.) /* Na janela de confirmação da importação o usuário clicou em 'Não'. */
                        lValid := .t.
                    endif 
                else 
                    addCriBF0(aNatDif, .t.) /* Na janela do markbrowse o usuário clicou em 'Fechar/Cancelar'. */
                    lValid := .t.
                endif 
            endif 
        endif 

        if ! lValid
            addCriBF0(aNatDif, .t.) /* Na janela de confirmação se deseja olhar as criticas o usuário clicou em 'Não'. */
        endif 
    endif

return


/*/{Protheus.doc} addCriBF0
Função adiciona uma critica do array de criticas.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@param aNatu, array, Array com o registro de natureza de saúde criticado.
@param lDiff, logical, Indica se a critica se refere a uma conferencia com o banco de dados ou não encontrado.
/*/
static function addCriBF0(aNatu, lDiff)
    local nI 

    default lDiff := .f.

    if lDiff 
        for nI := 1 to len(aNatu)
            aadd(__aWarningsSIP, {"BF0", "Registro de natureza de saude inconsistente, campo '" + aNatu[nI,1] + "' encontrado [" + alltrim(aNatu[nI,2]) + "] esperado [" + alltrim(aNatu[nI,3]) + "].", val(aNatu[nI,4])})
        next nI 
    else 
        for nI := 1 to len(aNatu)
            aadd(__aWarningsSIP, {"BF0", "Natureza de saude para a classificação '" + aNatu[nI,3] + "' não encontrada.", 0})
        next nI 
    endif
return 


/*/{Protheus.doc} addCriBR8
Função adiciona uma critica do array de criticas.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@param aProced, array, Array com o registro de procedimentos criticado.
@param lDiff, logical, Indica se a critica se refere a uma conferencia com o banco de dados ou não encontrado.
/*/
static function addCriBR8(aProced, lDiff)
    local nI 

    default lDiff := .f.

    if lDiff 
        for nI := 1 to len(aProced)
            aadd(__aWarningsSIP, {"BR8", "Registro de procedimento inconsistente, campo '" + aProced[nI,1] + "' encontrado [" + alltrim(aProced[nI,2]) + "] esperado [" + alltrim(aProced[nI,3]) + "].", val(aProced[nI,4])})
        next nI 
    else 
        for nI := 1 to len(aProced)
            aadd(__aWarningsSIP, {"BR8", "Natureza de saude para a classificação '" + aProced[nI,3] + "' não encontrada.", 0})
        next nI 
    endif
return 


/*/{Protheus.doc} grvData
Função realiza a gravação dos dados informados no parametro 'aFields' na
tabela informada no parametro 'cAlias'.

@author Gabriel H. Klok

@type static function
@since 17/07/2020
@version 1.0

@param cAlias, caracter, Alias da tabela aonde os dados serão inseridos.
@param aFields, array, Array chave valor, contendo o campo e o conteúdo que sera inserido.
/*/
static function grvData(cAlias, aFields)
    (cAlias)->(dbappend())
    aeval(aFields, {|x| (cAlias)->(fieldput( (cAlias)->(fieldpos(x[1])), x[2])) } )
    (cAlias)->(dbcommit())
    (cAlias)->(msunlock())
return 


/*/{Protheus.doc} validEsp
Função de validação das especialidades de saúde 'BAQ' o item A do SIP.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0
/*/
static function validEsp()
    local nX
    local aClasA
    
    lValid := .t.
    aClasA := {;
        {'A11', .t.},;
        {'A12', .t.},;
        {'A13', .t.},;
        {'A14', .t.},;
        {'A15', .t.},;
        {'A16', .t.},;
        {'A17', .t.},;
        {'A18', .t.},;
        {'A19', .t.},;
        {'A110', .t.},;
        {'A111', .t.},;
        {'A112', .t.},;
        {'A113', .t.},;
        {'A114', .t.},;
        {'A115', .t.},;
        {'A116', .t.},;
        {'A117', .t.},;
        {'A118', .t.},;
        {'A119', .t.},;
        {'A120', .t.},;
        {'A121', .t.},;
        {'A122', .t.},;
        {'A123', .t.},;
        {'A124', .t.},;
        {'A125', .t.};
    }

    for nX := 1 to len(aClasA)
        if ! findClasA(aClasA[nX,1])
            aClasA[nX,2] := .f.
            aadd(__aWarningsSIP, {"BAQ", "Não foram encontradas especialidades '" + aClasA[nX,1] + "'", 0})
        endif 
    next nX
return


/*/{Protheus.doc} findClasA
Função responsável por realizar a busca no banco de dados, procurando registros em BAQ com 
classificação informada por parâmetro.

@author Gabriel H. Klok

@type static funcion
@since 13/07/2020
@version 1.0 

@param cClas, caracter, Codigo da classificacao desejada.

@return lValid, logical, Resultado da busca da classificação informada.
/*/
static function findClasA(cClas)
    local cAlias 
    local lValid

    cAlias := getnextalias()
    lValid := .t.

    beginsql alias cAlias 
        SELECT COUNT(BAQ_ESPSP2) QTD
        FROM %table:BAQ%
        WHERE BAQ_FILIAL = %xfilial:BAQ%
            AND BAQ_ESPSP2 = %exp:cClas%
            AND %notdel%
    endsql 

    if (cAlias)->QTD = 0
        lValid := .f.
    endif 

    (cAlias)->(dbclosearea())

return lValid


/*/{Protheus.doc} validPro
Função realiza a validação dos registros de procedimentos da tabela 'BR8' de acordo
com os dados importados do CSV TUSSxSIP.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0
/*/
static function validPro()
    local lValid := .f.
    local oFileCSV 
    local aLine
    local cFile
    local cWhere
    local cClasip
    local cCodPro 
    local cBenUtl
    local cFcaren
    local cTpCons
    local lInter 
    local aMatCol
    local nI

    private __aCriPro := {}

    cFile := plsmudsis(__cPathWizard + __aFilesCSV[2])

    oFileCSV := fwfilereader():new(cFile)
    if oFileCSV:open()
        oFileCSV:hasline()
        oFileCSV:getline()
        while oFileCSV:hasline()
            lValidTMP := .t.
            aLine := strtokarr2(oFileCSV:getline(), ";", .t.)

            cClasip := iif(empty(aLine[1]), aLine[2], aLine[1])
            cCodPro := aLine[3]
            cBenUtl := aLine[4]
            cFcaren := aLine[5]
            cTpCons := aLine[6]
            lInter := iif(!empty(aLine[2]) .and. left(aLine[2], 1) == "E", .t., .f.)

            if cClasip == "C101"
                cWhere := "% AND BR8_CLASIP = 'C101' AND BR8_CODPSA IN ('" + strtran(cCodPro, "|", "','") + "') %"
                if chkClas(cWhere) = 0
                    aadd(__aWarningsSIP, {"BR8", "Um dos procedimentos (40808033,40808041,40808173) deve ser classificado como C101 para cálculo de expostos.", 0})
                else 
                    chkCdPro(cClasip, "40808033", cBenUtl, cFcaren, cTpCons, lInter)
                    chkCdPro(cClasip, "40808041", cBenUtl, cFcaren, cTpCons, lInter)
                    chkCdPro(cClasip, "40808173", cBenUtl, cFcaren, cTpCons, lInter)                    
                endif     
                loop
            endif

            if empty(cCodPro)
                do case 
                    case cClasip == "A"
                        cWhere := "% AND (BR8_CLASIP = 'A' OR BR8_CLASP2 = 'A') %"
                        if chkClas(cWhere) > 0
                            aadd(__aWarningsSIP, {"BR8", "Não deve existir procedimentos com classificação 'A'.", 0})
                        endif 

                    case cClasip $ "B|C|D"
                        cWhere := "% AND BR8_CLASIP = '" + cClasip + "' AND BR8_BENUTL = '" + cBenUtl + "' AND BR8_FCAREN = '" + cFcaren + "' AND BR8_TPCONS = '" + cTpCons + "' %"
                        if chkClas(cWhere) < 1
                            aadd(__aWarningsSIP, {"BR8", "Nenhum procedimento encontrado com classificação '" + cClasip + "'.", 0})
                        endif 

                    case cClasip == "E141"
                        cWhere := "% AND BR8_CLASP2 = 'E141' AND BR8_BENUTL = '" + cBenUtl + "' AND BR8_FCAREN = '" + cFcaren + "' AND BR8_TPCONS = '" + cTpCons + "' %"
                        if chkClas(cWhere) < 1
                            aadd(__aWarningsSIP, {"BR8", "Nenhum procedimento encontrado com classificação '" + cClasip + "'.", 0})
                        endif 

                    case cClasip == "I"
                        cWhere := "% AND BR8_CLASIP = 'I' AND BR8_BENUTL = '" + cBenUtl + "' AND BR8_FCAREN = '" + cFcaren + "' AND BR8_TPCONS = '" + cTpCons + "' %"
                        if chkClas(cWhere) < 1
                            aadd(__aWarningsSIP, {"BR8", "Nenhum procedimento encontrado com classificação '" + cClasip + "'.", 0})
                        endif 

                endcase 
            else 
                chkCdPro(cClasip, cCodPro, cBenUtl, cFcaren, cTpCons, lInter)
            endif 
        enddo 
        oFileCSV:close()
    endif

    if ! empty(__aCriPro)
        aMatCol := {}
        aadd(aMatCol, {"Tabela", "@C", 10, .f.})
        aadd(aMatCol, {"Codigo", "@C", 16, .f.})
        aadd(aMatCol, {"Campo", "@C", 10, .f.})
        aadd(aMatCol, {"Atual", "@C", 10, .f.})
        aadd(aMatCol, {"Correto", "@C", 10, .f.})
        aadd(aMatCol, {"RECNO", "@C", 10, .f.})

        if __lUserView
            if msgyesno("Foram encontrados procedimentos inconsistentes. Deseja analisar para correção?", TITLE_MODAL)
                if PLSSELOPT("Selecione o(s) registros para correção", "Marca e Desmarca todos", __aCriPro, aMatCol,, .t., .t., .f.)
                    if msgyesno("Confirma correção dos registros selecionados?", TITLE_MODAL)
                        dbselectarea("BR8")
                        for nI := 1 to len(__aCriPro)
                            if atail(__aCriPro[nI])
                                BR8->(dbgoto(val(__aCriPro[nI,6])))
                                BR8->(reclock("BR8", .f.))
                                &("BR8->" + __aCriPro[nI,3]) := __aCriPro[nI,5]
                                BR8->(msunlock())
                            else 
                                aadd(__aWarningsSIP, {"BR8", "Registro de procedimento inconsistente, campo '" + __aCriPro[nI,2] + "' encontrado [" + alltrim(__aCriPro[nI,3]) + "] esperado [" + alltrim(__aCriPro[nI,4]) + "].", val(__aCriPro[nI,5])})
                            endif
                        next nI
                        lValid := .t.
                    else 
                        addCriBR8(__aCriPro, .t.) /* Na janela de confirmação da importação o usuário clicou em 'Não'. */
                        lValid := .t.
                    endif 
                else
                    addCriBR8(__aCriPro, .t.) /* Na janela do markbrowse o usuário clicou em 'Fechar/Cancelar'. */
                    lValid := .t.
                endif 
            endif 
        endif 

        if ! lValid
            addCriBR8(__aCriPro, .t.) /* Na janela de confirmação se deseja olhar as criticas o usuário clicou em 'Não'. */
        endif 
    endif  
return 


/*/{Protheus.doc} chkClas
Função realiza a verificação da quantidade de registros em 'BR8' com determinadas condições.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@param cWhere, caracter, String com o WHERE para utilizar na busca.

@return nCount, numeric, Indica a quantidade de registros que a busca retornou.
/*/
static function chkClas(cWhere)
    local cAlias := getnextalias()
    local nCount

    beginsql alias cAlias 
        SELECT COUNT(*) QTD 
        FROM %table:BR8%
        WHERE BR8_FILIAL = %xfilial:BR8%
            %exp:cWhere%
            AND %notdel%        
    endsql 

    nCount := (cAlias)->QTD

    (cAlias)->(dbclosearea())   
return nCount


/*/{Protheus.doc} chkCdPro
Função realiza a comparação no registro de procedimentos em 'BR8' com os parametros informados.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@param cClasip, caracter, Conteudo a ser comparado com o campo BR8_CLASIP ou BR8_CLASP2
@param cCodPro, caracter, Codigo do procedimento a ser analisado.
@param cBenUtl, caracter, Conteudo a ser comparado com o campo BR8_BENUTL.
@param cFcaren, caracter, Conteudo a ser comparado com o campo BR8_FCAREN.
@param cTpCons, caracter, Conteudo a ser comparado com o campo BR8_FCAREN.
@param lInter, logical, Indica se é internação.
@param lAuto, logical, Indica que a função foi chamada pela automação de testes.

@return nil, nil, Por padrão 'nil'.
/*/
static function chkCdPro(cClasip, cCodPro, cBenUtl, cFcaren, cTpCons, lInter, lAuto)
    local aAreaBR8 := BR8->(getarea())

    default lAuto := .f.

    BR8->(dbsetorder(3)) /* Indice: BR8_FILIAL+BR8_CODPSA+BR8_CODPAD */
    if BR8->(msseek(xfilial("BR8") + cCodPro))
        if lInter 
            if alltrim(BR8->BR8_CLASP2) <> cClasip
                aadd(__aCriPro, {BR8->BR8_CODPAD, cCodPro, "BR8_CLASP2", BR8->BR8_CLASP2, cClasip, alltrim(str(BR8->(recno()))), .t.})
            endif 
        else 
            if alltrim(BR8->BR8_CLASIP) <> cClasip
                aadd(__aCriPro, {BR8->BR8_CODPAD, cCodPro, "BR8_CLASIP", BR8->BR8_CLASIP, cClasip, alltrim(str(BR8->(recno()))), .t.})
            endif 
        endif

        if alltrim(BR8->BR8_BENUTL) <> cBenUtl 
            aadd(__aCriPro, {BR8->BR8_CODPAD, cCodPro, "BR8_BENUTL", BR8->BR8_BENUTL, cBenUtl, alltrim(str(BR8->(recno()))), .t.})
        endif 

        if alltrim(BR8->BR8_FCAREN) <> cFcaren
            aadd(__aCriPro, {BR8->BR8_CODPAD, cCodPro, "BR8_FCAREN", BR8->BR8_FCAREN, cFcaren, alltrim(str(BR8->(recno()))), .t.})
        endif 

        if alltrim(BR8->BR8_TPCONS) <> cTpCons 
            aadd(__aCriPro, {BR8->BR8_CODPAD, cCodPro, "BR8_TPCONS", BR8->BR8_TPCONS, cTpCons, alltrim(str(BR8->(recno()))), .t.})
        endif 
    else 
        aadd(__aWarningsSIP, {"BR8", "Não encontrato procedimento '" + cCodPro + "'.", 0})
    endif 

    restarea(aAreaBR8)
return iif(lAuto, iif(empty(__aWarningsSIP), __aCriPro, __aWarningsSIP), nil)


/*/{Protheus.doc} reportSW
Função do relatorio de criticas do SIPWizard.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@param lWizard, logical, Se .t. indica que foi chamado logo ao fim da rotina do wizard.
/*/
function reportSW(lWizard)
    local aArea := getarea()
    local oReport 

    default lWizard := .f. 

    if ! lWizard 
        sipwizard(.t.)
    endif 

    oReport := struct()
    oReport:printdialog()

    freeobj(oReport)
    restarea(aArea)
return 


/*/{Protheus.doc} struct
Função monta a estrutura do relatório.

@author Gabriel H. Klok
@since 19/08/2020
@version 1.0

@return oReport, object, Objeto instanciado da classe 'Treport'.
/*/
static function struct()
    local oReport 
    local oWarnings 

    local cName
    local cTitle
    local cDescri
    local bPrint 

    cName := "REPORTSW"
    cTitle := "Relatório das criticas SipWizard"
    cDescri := "Criticas encontradas pelo wizard para implementação do SIP."
    bPrint := {|oReport| printing(oReport)}

    oReport := treport():new(cName, cTitle,, bPrint, cDescri)
    oReport:nfontbody := 8
    oReport:nlineheight := 40
    oReport:setlandscape()
    oReport:hidefooter()

    oWarnings := trsection():new(oReport, "Criticas")
    oWarnings:setautosize(.t.)
    trcell():new(oWarnings, "LOCAL",, "Local", "@!", 10)
    trcell():new(oWarnings, "CRITICAS",, "Criticas", "@!", 250)
    trcell():new(oWarnings, "RECNO",, "Recno", "@E 99999999", 10,,, "RIGHT",, "RIGHT")

return oReport 


/*/{Protheus.doc} printing
Função que realiza a impressão do relatorio.

@author Gabriel H. Klok
@since 19/08/2020
@versino 1.0

@param oReport, object, Objeto da classe 'treport'.
/*/
static function printing(oReport)
    local oWarnings
    local nI

    oWarnings := oReport:section(1)

    oWarnings:init()
    for nI := 1 to len(__aWarningsSIP)
        oWarnings:cell("LOCAL"):setvalue(__aWarningsSIP[nI,1])
        oWarnings:cell("CRITICAS"):setvalue(__aWarningsSIP[nI,2])
        oWarnings:cell("RECNO"):setvalue(__aWarningsSIP[nI,3])

        oWarnings:printline()
    next nI    
    oWarnings:finish()
return 
