#Include 'Protheus.ch'
#Include 'topconn.ch'
#Include 'PLSDPSFNC.ch'
#include 'totvs.ch'

static oRegua     := nil
static lVisual    := .t.
static cSTTabBQ2  := ""
static cSTTabBQ3  := ""
static cSTTabBQ4  := ""  
static cSTFilBQ2  := ""
static cSTFilBQ3  := ""
static cSTFilBQ4  := ""

/*//-------------------------------------------------------------------
{Protheus.doc} PlDPSJob
Função quje recebe os parâmetros do JOB, e prepara o ambiente. Posições do aJob:
1 - Se Job / 2 - Data / 3 - Operadora / 4 - Empresa / 5 - Filial
@since    02/2021
//-------------------------------------------------------------------*/
function PlDPSJob(aJob)

if ( len(aJob) >= 7 .and. aJob[1] )
    RpcSetEnv( aJob[4], aJob[5] , , ,'PLS', , )
    PLSDPSCnGr(aJob[1], aJob[2], aJob[3], .f.)
else
    FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0035, 0, 0, {})//Parametrização incorreta. Consulte a documentação."
endif
return


/*//-------------------------------------------------------------------
{Protheus.doc} PLSDPSCnGr
Função Central de Gerenciamento, que deve ser chamada via Job ou rotina principal.
@since    02/2021
//-------------------------------------------------------------------*/
function PLSDPSCnGr(lJob, cData, cOperad, lAutoma)
default lJob    := .f.
default cData   := Date()
default cOperad := PlsIntPad()
default lAutoma := .f.

cData := iif( lJob, STRZERO(MONTH(cData),2) + cvaltochar(YEAR(cData)), cData ) 

//Verifico se existe as tabelas BQ2/BQ3/BQ4 no ambiente, pois já está inicializado
if InicVarStatic()

    if !lAutoma .and. !lJob
        oRegua := MsNewProcess():New( { || PLDPSManut(lJob, cData, cOperad) } , STR0001 , STR0002 , .f. )//"Processando etapas / Aguarde..."
        oRegua:Activate()
    else
        lVisual := .f.
        PLDPSManut(lJob, cData, cOperad)
    endif

endif

return


/*//-------------------------------------------------------------------
{Protheus.doc} PLDPSManut
Função Centrald e Gerenciamento, que deve ser chamada via Job ou rotina principal.
@since    02/2021
//-------------------------------------------------------------------*/
function PLDPSManut(lJob, cData, cOperad)
local aDadosFun := {}
local cNumSeq   := ""
local cMensagem := ""
local nRegDel   := 0
local nRegInc   := 0
local nRegAtu   := 0
local nPassos   := 4
local lInclusao := .f.
local lAtuLoteE := .f.
local lAtuLoteI := .f.

//Criando a régua número 1 de etapas
iif( lVisual, oRegua:SetRegua1(nPassos), "")

//1 - Verificar se já existe um lote para a incidência informada:
iif( lVisual, oRegua:IncRegua1(STR0003 + cvaltochar(nPassos) ), "") //"Etapa 1 de "
aDadosFun := PlIncluLote(cData, cOperad)
cNumSeq   := aDadosFun[1]
lInclusao := aDadosFun[3]     

//2 - Se o lote foi incluído, não existe a necessidade de verificar dados da BQ3 que não existem na SF1. Caso contrário, verificar.
iif( lVisual, oRegua:IncRegua1(STR0004 + cvaltochar(nPassos) ), "") //"Etapa 2 de "
if !lInclusao
    aDadosFun   := PlExcluBQ3(cData, cNumSeq, cOperad)
    nRegDel     := aDadosFun[1]
    lAtuLoteE   := aDadosFun[2]
endif 

//3 - Procurar dados da SF1/SD1 e grvar na BQ3 agora - tantos novos quanto alterados.
iif( lVisual, oRegua:IncRegua1(STR0005 + cvaltochar(nPassos) ), "") //"Etapa 3 de "
aDadosFun   := PlIncAltBQ3(cData, cNumSeq, cOperad)
nRegInc     := aDadosFun[1]
nRegAtu     := aDadosFun[2]
lAtuLoteI   := aDadosFun[3]
nRegDel     += aDadosFun[4]

//4 - Atualizar valores na BQ2 de total e status do documento, caso tenha alteração.
iif( lVisual, oRegua:IncRegua1(STR0009 + cvaltochar(nPassos) ), "") //Etapa 4 de "
aDadosFun := PlAtuBQ2(cData, cNumSeq, cOperad, .t., .t., iif( lAtuLoteE .or. lAtuLoteI, "2", ""), .f. )

//5 - Final de Processo - Incluídos - Alterados - Excluídos.
cMensagem := STR0012 + cvaltochar(nRegInc) + CRLF + STR0013 + cvaltochar(nRegAtu) + CRLF + STR0014 + cvaltochar(nRegDel)
if lVisual
    Help(nil, nil , STR0011, nil, cMensagem, 1, 0, nil, nil, nil, nil, nil, {} ) 
elseif !lVisual .and. !lInclusao
    PlAtuBQ4(cNumSeq, cOperad, lVisual, "SCHD", cMensagem)       
endif

//Grava no histórico a inclusão efetuada
if lInclusao
    PlAtuBQ4(cNumSeq, cOperad, lVisual, iif(lJob, "A", "M") + "001", STR0015 + CRLF + cMensagem) //Inclusão de Lote
endif
oRegua := nil
return


/*//-------------------------------------------------------------------
{Protheus.doc} PlIncluLote
Função genérica de gravação da BQ2, utlizando MVC.
@since    02/2021
//-------------------------------------------------------------------*/
static function PlIncluLote (cData, cOperad)
local aDadosRet     := {"0", cOperad, .f.}
local cRetSql       := PlDPSQLote(cData, cOperad)
local cRetCod       := ""
local oModelDPS     := FWLoadModel("PLSDPS1") 
local oObjBQ2		:= oModelDPS:GetModel('MASTERBQ2')

iif( lVisual, oRegua:SetRegua2(-1), "")

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cRetSql)),"QryLote",.f.,.t.)

BA0->(dbSetOrder(1)) //BA0_FILIAL+BA0_CODIDE+BA0_CODINT
if BA0->(MsSeek(xFilial('BA0') + cOperad ))

    if ( QryLote->(eof()) )
        oModelDPS:SetOperation(3)
        oModelDPS:Activate()

        oObjBQ2:setValue("BQ2_FILIAL"	, cSTFilBQ2)
        oObjBQ2:setValue("BQ2_CODOPE"	, cOperad)
        oObjBQ2:setValue("BQ2_TIPARQ"	, "1")  //"N" - NORMAL
        oObjBQ2:setValue("BQ2_VERSAO"	, "001")
        oObjBQ2:setValue("BQ2_INSCCM"	, PadL(alltrim(BA0->BA0_INSCMU),8,'0'))
        oObjBQ2:setValue("BQ2_INCIDE"	, cData)
        oObjBQ2:setValue("BQ2_CODSER"	, PadL(alltrim(BA0->BA0_CODISS),5,'0')) 
        oObjBQ2:setValue("BQ2_USUARI"	, upper(alltrim(UsrRetName(RetCodUsr()))) )

        cRetCod := PlVldSX8("BQ2", oObjBQ2:getValue("BQ2_CODSEQ"))
        if ( cRetCod != oObjBQ2:getValue("BQ2_CODSEQ") )
            oObjBQ2:setValue("BQ2_CODSEQ"   , cRetCod)    
        endif

        if (oModelDPS:VldData())
            oModelDPS:commitData()
            aDadosRet := {BQ2->BQ2_CODSEQ, BQ2->BQ2_CODOPE, .t.}
        endif
    else
        aDadosRet := {QryLote->CODSEQ, QryLote->CODOPE, .f.}
    endif
    QryLote->(dbcloseArea())
EndIf

iif( lVisual, oRegua:IncRegua2(STR0006), "") //"Lote OK! "

PlLimpModel(oModelDPS, oObjBQ2)

return aDadosRet


/*//-------------------------------------------------------------------
{Protheus.doc} PlExcluBQ3
Realiza a verificação dos itens que existem na BQ3, mas não existem mais na SF1/SD1
@since    03/2021
//-------------------------------------------------------------------*/
static function PlExcluBQ3 (cData, cNumSeq, cOperad)
local cRetSql       := PlDPSQExclu(cData, cNumSeq, cOperad)
local cMensagem     := ""
local nRegDel       := 0
local nRegQry       := 0
local nOperac       := 0
local lAtuBQ2       := .f.
local oModelDPS     := FWLoadModel("PLSDPS2") 
local oObjBQ3		:= oModelDPS:GetModel('MASTERBQ3')

iif( lVisual, oRegua:SetRegua2(-1), "")

//Verificar os deletados, conferindo se foi enviado ou não.
dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cRetSql)),"QryExcl",.f.,.t.)
BQ3->(dbSetOrder(1))

Count To nRegQry
QryExcl->(DBGoTop())

if ( QryExcl->(!eof()) )
    while QryExcl->(!eof())
        BQ3->(DbGoTo(QryExcl->REC))

        nOperac := iif( !empty(BQ3->BQ3_DATARQ), 4, 5 )

        oModelDPS:SetOperation(nOperac)
        oModelDPS:Activate()

        if nOperac == 4
            oObjBQ3:setValue("BQ3_SITDOC"   , "2")  //Exclusão
            oObjBQ3:setValue("BQ3_DATARQ"	, ctod("")) //Limpo a data, para sair no arquivo que vai ser gerado como "correção"  
            lAtuBQ2 := .t.
            cMensagem += BQ3->(BQ3_NUMDOC+BQ3_SERIE) + " - " + BQ3->(BQ3_FORNEC+BQ3_LOJA) + STR0030 + CRLF // 'E' - Exclusão
        else
            cMensagem += BQ3->(BQ3_NUMDOC+BQ3_SERIE) + " - " + BQ3->(BQ3_FORNEC+BQ3_LOJA) + STR0031 + CRLF // - Deletado
        endif   

        if (oModelDPS:VldData())
            oModelDPS:commitData()  
        endif
        oModelDPS:deActivate()

        nRegDel++
        iif( lVisual, oRegua:IncRegua2(STR0007 + cvaltochar(nRegDel) + " de " + cvaltochar(nRegQry)), "") //"Excluídos: "
        QryExcl->(dbskip())    
    enddo
    PlAtuBQ4(cNumSeq, cOperad, lVisual, "A003", STR0016 + CRLF + cMensagem) //Alteração de Item	
endif
QryExcl->(dbcloseArea())
PlLimpModel(oModelDPS, oObjBQ3)

return {nRegDel, lAtuBQ2}


/*//-------------------------------------------------------------------
{Protheus.doc} PlIncAltBQ3
Função genérica de gravação da BQ2, utlizando MVC.
@since    02/2021
//-------------------------------------------------------------------*/
static function PlIncAltBQ3 (cData, cNumSeq, cOperad)
local aContador     := {0, 0, .f., 0}
local cRetSql       := PlDPSQIncAlt( ctod(transform("01"+cData, "@R !!/!!/!!!!")) ) //Já que vamos pesquisar por inicio e fim
local cMensagem     := ""
local cTmpDocSer    := ""
local cUsuario      := iif( lVisual, substr(upper(alltrim(UsrRetName(RetCodUsr()))),1, 40), "Schedule")
local oModelDPS     := FWLoadModel("PLSDPS2") 
local oObjBQ3		:= oModelDPS:GetModel('MASTERBQ3')
local lInclusao     := .f.
local lTipNota      := .f.
local lWasDPS       := .f.
local nRegQry       := 0
local nLoop         := 0

BQ2->(dbSetOrder(1))
BQ3->(dbSetOrder(1))

iif( lVisual, oRegua:SetRegua2(-1), "")

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cRetSql)),"QryIncAlt",.f.,.t.)

Count To nRegQry
QryIncAlt->(DBGoTop())

if ( !QryIncAlt->(eof()) )

    while QryIncAlt->(!eof())

        //Situações onde a nota tem vários itens, mas com codiss diferente e/ou não agrupa
        if cTmpDocSer != (QryIncAlt->DOC + QryIncAlt->SERIE + QryIncAlt->FORNEC + QryIncAlt->LOJA + QryIncAlt->TIPNOTA)
           
            lTipNota := .f.
            if ( empty(QryIncAlt->RECBQ3) )
                lInclusao := .t.
            else
                BQ3->(dbgoto(QryIncAlt->RECBQ3))
                lTipNota := BQ3->BQ3_TIPDOC != QryIncAlt->TIPNOTA
                lWasDPS  := !empty(BQ3->BQ3_DATARQ)
            endif

            PGrvBQ3Mar(oModelDPS, oObjBQ3, cOperad, cNumSeq, cData, iif(lInclusao, 3, 4), @aContador, lTipNota, @cMensagem, cUsuario, lWasDPS)
            if ( lTipNota .and. lWasDPS)
                PGrvBQ3Mar(oModelDPS, oObjBQ3, cOperad, cNumSeq, cData, 3, @aContador, .f., @cMensagem, cUsuario)
            endif

            nLoop++
            iif( lVisual, oRegua:IncRegua2(STR0008 + cvaltochar(nLoop) + " de " + cvaltochar(nRegQry)), "") //"Incluidos/Alterados: "
            cTmpDocSer := (QryIncAlt->DOC + QryIncAlt->SERIE + QryIncAlt->FORNEC + QryIncAlt->LOJA + QryIncAlt->TIPNOTA)
        endif
        QryIncAlt->(dbskip())
    enddo    
endif

QryIncAlt->(dbcloseArea())

PlLimpModel(oModelDPS, oObjBQ3)
if !empty(cMensagem)
    PlAtuBQ4(cNumSeq, cOperad, lVisual, "A003", STR0016 + CRLF + cMensagem) //Alteração de Item
endif
return aContador


/*//-------------------------------------------------------------------
{Protheus.doc} PlAtuBQ2
Atualiza o cabeçalho do lote de DPS
@since    02/2021
//-------------------------------------------------------------------*/
static function PlAtuBQ2(cData, cNumSeq, cOperad, lAtuStatus, lAtuVal, cValStatus, lAtuTxtDPS)
local cRetSql       := PlVerDBQ3(cData, cOperad, cNumSeq)
local oModelDPS     := FWLoadModel("PLSDPS1") 
local oObjBQ2		:= oModelDPS:GetModel('MASTERBQ2')
local lGrvBQ4       := .f.
default lAtuStatus  := .f.
default lAtuVal     := .t.
default cValStatus  := ""
default lAtuTxtDPS  := .f.
iif( lVisual .and. !empty(oRegua), oRegua:SetRegua2(-1), "")

//Vamos atualizar o Lote
BQ2->(dbSetorder(1))
if ( BQ2->(DbSeek(cSTFilBQ2 + cOperad + cNumSeq)) )

    oModelDPS:SetOperation(4) //Alteração
    oModelDPS:Activate()

    if lAtuVal
        dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cRetSql)), "QryTot",.f.,.t.)
        oObjBQ2:setValue("BQ2_VLRTOT"	, QryTot->VLRTOTAL)
        QryTot->(dbcloseArea())
    endif    
    if lAtuStatus .and. !empty(cValStatus) .and. oObjBQ2:getValue("BQ2_TIPARQ") != cValStatus
        oObjBQ2:setValue("BQ2_TIPARQ"	, cValStatus)
        lGrvBQ4 := .t.
    endif
    if lAtuTxtDPS
        oObjBQ2:setValue("BQ2_GERDPS"	, "1")
    endif
    if (oModelDPS:VldData())
        oModelDPS:commitData()
        if lGrvBQ4
            PlAtuBQ4(cNumSeq, cOperad, lVisual, "A002", STR0017 + iif(cValStatus == "1", STR0028, STR0029))//Alteração de Lote - Normal/Retificação   
        endif
    endif
endif

iif( lVisual .and. !empty(oRegua), oRegua:IncRegua2(STR0010), "") //"Valores atualizados"

PlLimpModel(oModelDPS, oObjBQ2)
return


/*//-------------------------------------------------------------------
{Protheus.doc} PlLimpModel
Limpa o modelo passado nos parâmetros
@since    03/2021
//-------------------------------------------------------------------*/
static function PlLimpModel(oModelEx, oObjModEx)
if !empty(oModelEx) .and. !empty(oObjModEx)
    oModelEx:deActivate()
    oModelEx:destroy()
    freeObj( oModelEx )
    freeObj( oObjModEx )
    oModelEx  := nil
    oObjModEx := nil
endif
return


/*//-------------------------------------------------------------------
{Protheus.doc} PLSDPSTXT
Apresenta a tela para exibir onde gravar o txt
@since    03/2021
//-------------------------------------------------------------------*/
function PLSDPSTXT(cCodOpe, cNumSeq, cData, cTipTxt, cNomeArq, lAutoma, lAtuData, cLocAuto)
local cFile         := ""
local cRetSql       := ""
local cMensagem     := ""
local cErro         := ""
local cDocsTxt      := ""
local cDocZip       := substr(cNomeArq, 1, Len(cNomeArq)-4) + ".zip"
local cNomeTmp      := cNomeArq
local cArqsGra      := ""
local nRegQry       := 0
local nSeqBQ4       := 0
local oFileGrv      := nil
local lConfere      := !lAtuData //não deve atualizar a data quando for 'Conferencia'
local lGerArq       := .t.
local nParte        := 0
default lAutoma     := .f.
default lAtuData    := .f.  
default cLocAuto    := plsmudsis("/schemas/")  
 
InicVarStatic()
cRetSql := PLDPSQTxt(cCodOpe, cNumSeq, cData, cTipTxt, .f.)

dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cRetSql)),"QryTxt",.f.,.t.)
Count To nRegQry
QryTxt->(DBGoTop()) 

lVisual := iif(lAutoma, .f., .t.)

if nRegQry == 0
    //Final de Processo - Não existe movimento para essa incidência.
    Help(nil, nil , STR0011, nil, STR0026, 1, 0, nil, nil, nil, nil, nil, {} ) 

elseif nRegQry > 0
    cFile := iif(lVisual, cGetFile('Arquivo *|*.*|Arquivo Log|*.txt', STR0034,0,'C:\',.T.,GETF_LOCALHARD+GETF_RETDIRECTORY,.t.), cLocAuto)
	If !Empty(cFile)    
        while lGerArq
            nParte++
            if nParte > 1
                cNomeTmp := substr(cNomeArq, 1, len(cNomeArq)-4)
                cNomeTmp := cNomeTmp + "_parte_" + cvaltochar(nParte) + ".txt"
                cDocZip  := substr(cNomeTmp, 1, Len(cNomeTmp)-4) + ".zip"
            endif
            oFileGrv := FWFileWriter():New( cFile + cNomeTmp , .t.)
            oFileGrv:setBufferSize(16384)
            if oFileGrv:create()

                //Gravar o arquivo
                PlGrvtxtPos(oFileGrv, "QryTxt", nRegQry+4, @cDocsTxt, lConfere, @lGerArq)
                oFileGrv:close()
                iif( lVisual, IncProc(), "")
                
                if lAtuData
                    PlAtuBQ3Tx( PLDPSQTxt(cCodOpe, cNumSeq, cData, cTipTxt, .t.), cNumSeq, cCodOpe )
                    //Atualiza que a DPS foi gerada, no campo BQ2_GERDPS, da tabela BQ2 e atualiza status - se o lote era retificação
                    //passa a ser normal, já que a DPS "definitiva" foi gerada e os próximos são normais
                    PlAtuBQ2(cData, cNumSeq, cCodOpe, .t., .f., "1", .t.)
                endif
                iif( lVisual, IncProc(), "")

                //Arquivo DPS gerado no caminho: / Tipo da DPS:  / Parcial ou Total / Total / - Apenas Conferência
                cMensagem := STR0021 + alltrim(cFile) + cNomeTmp + CRLF + STR0022 + iif(cTipTxt == "1", STR0023, STR0024) + ;
                            CRLF + STR0024 + " - " + cvaltochar(nRegQry) + iif(lConfere, STR0032, "") 
                if empty(nSeqBQ4)                           
                    nSeqBQ4 := PlAtuBQ4(cNumSeq, cCodOpe, lVisual, "M004", cMensagem + CRLF + cDocsTxt)
                endif

                //compactar para gravar no Banco de conhecimento
                if ( fZip(cFile + cDocZip, {cFile + cNomeTmp}) == 0 )
                    PLSINCONH(cFile + cDocZip, "BQ4", cSTFilBQ4 + cCodOpe + nSeqBQ4,,.t.)
                    fErase(cFile + cDocZip)
                endif
                
                cArqsGra += iif(nParte > 1, STR0021 + cFile + cNomeTmp + CRLF, "") 
                //Final de Processo - Arquivo DPS gerado com sucesso! Caminho:
                if !lGerArq .and. lVisual
                    Help(nil, nil , STR0011, nil, STR0025 + CRLF + cNomeArq + CRLF + cArqsGra , 1, 0, nil, nil, nil, nil, nil, {} )
                    if nParte > 1
                        BQ4->(DbSetorder(1))
                        if ( BQ4->(DbSeek(cSTFilBQ4 + cCodOpe + nSeqBQ4)) )
                            PlAtuBQ4("", "", "", "", "", 4, { {"BQ4_OBSERV"	, cArqsGra}})
                        endif 
                    endif   
                endif
            else
                cErro := cvaltochar(fError())
                if lVisual
                    //Final de Processo - Não foi possível criar o arquivo. Código do erro: 
                    Help(nil, nil , STR0011, nil, STR0027 + cErro, 1, 0, nil, nil, nil, nil, nil, {} )
                endif
                PlAtuBQ4(cNumSeq, cCodOpe, lVisual, "ER02", STR0027 + cErro )
            endif
        enddo
    EndIf
endif
QryTxt->(dbcloseArea())
return


/*//-------------------------------------------------------------------
{Protheus.doc} PlGrvtxtPos
Grava o arquivo no formato esperado pelo manual de Repasse
@since    03/2021
//-------------------------------------------------------------------*/
static function PlGrvtxtPos(oFileGrv, QryTxt, nRegQry, cDocsTxt, lConfere, lVarArq)
local cLinha        := ""
local nQtdVez       := 0
local nValorRep     := 0
local nLacoCont     := 0
local lStopArq      := .f.

default lConfere    := .f.

iif( lVisual, ProcRegua(-1), "")

//Se arquivo de conferência, vamos adicionar uma linha a mais, indicando a situação do mesmo
if lConfere
    //"Arquivo apenas para simples conferência. Não utilize para envio."
    cLinha := "0" + STR0033
    cLinha += CRLF
    oFileGrv:write(cLinha)
    cLinha := ""
endif

//Gravar os dados da BQ2 posicionada  -  3.2 REGISTRO TIPO 1 – CABEÇALHO
cLinha := "1"                                               //Deve ser preenchido com valor "1", indicando linha de cabeçalho.
cLinha += iif( BQ2->BQ2_TIPARQ == "1", "N", "R")            //N - referente a envio normal R – referente à retificação de valores
cLinha += BQ2->BQ2_VERSAO                                   //Indica a versão do layout a ser utilizada.
cLinha += PadL(alltrim(BQ2->BQ2_INSCCM),8,'0')              //Inscrição municipal do Prestador a que se refere o arquivo.
cLinha += right(BQ2->BQ2_INCIDE,4) + left(BQ2->BQ2_INCIDE,2) //AAAAMM. O arquivo de transferência deverá conter todos os documentos referentes à incidência
cLinha += PadL(alltrim(BQ2->BQ2_CODSER),5,'0')              //Código do serviço prestado do Plano de Saúde para o qual serão informados os repasses.
cLinha += CRLF                                              //Caractere de Fim de Linha (Chr(13) + Chr(10)).
oFileGrv:write(cLinha)

cLinha := ""
//iif( lVisual, IncProc(), "")

//Gravar os dados da BQ3 encontradas  -  3.3 REGISTRO TIPO 2 – DETALHE
while QryTxt->(!eof())
    cLinha += "2"                                           //Deve ser preenchido com valor "2", indicando linha de detalhe.
    cLinha += QryTxt->TIPDOC                                //01 – NFS-e e 02 – NFTS
    cLinha += PadL(alltrim(QryTxt->NUMDOC) + alltrim(QryTxt->SERIE), 12, '0') //Informe o Número do Documento com 12 posições.
    cLinha += PadL(alltrim(QryTxt->INSCCM), 8, '0')         //A inscrição municipal do emitente: obrigatório se tipo do documento for igual a 01.
    cLinha += iif( QryTxt->SITDOC == "1", "I", iif(QryTxt->SITDOC == "2", "E", "A") ) //I – Inclusão / E – Exclusão / A - Alteração
    cLinha += StrTran(STRZERO(noRound(QryTxt->VLRREP,2),16,2),".","")         //Informe o Valor dos repasses com 15 posições.
    cLinha += CRLF                                  //Caractere de Fim de Linha (Chr(13) + Chr(10)).
    nValorRep += QryTxt->VLRREP
    nQtdVez++
    nLacoCont++
    //iif( lVisual, IncProc(), "")
    
    //Se deve para e criar novo arquivo
    if nLacoCont > 17500
        oFileGrv:write(cLinha)
        cLinha := ""
        nLacoCont := 0
        if fseek(oFileGrv:nHandLen, 0, 2) >= 9990000  //9.6 ~ 9.9 MB
            lStopArq := .t.
            QryTxt->(dbSkip())
            exit
        endif
    endif
    //cDocsTxt += alltrim(QryTxt->NUMDOC) + alltrim(QryTxt->SERIE) + " - " + QryTxt->FORNEC + QryTxt->LOJA + "; "
    QryTxt->(dbSkip())
enddo

if !empty(cLinha)
    oFileGrv:write(cLinha)
    cLinha := ""
endif    

//Rodapé 3.4 REGISTRO TIPO 9 – RODAPÉ
cLinha := "9"                       //Deve ser preenchido com valor “9”, indicando linha de rodapé.
cLinha += STRZERO(nQtdVez, 7)       //Número de linhas de detalhe (Tipo 2) contidas no arquivo.
cLinha += StrTran(STRZERO(noRound(nValorRep,2),16,2),".","")  //Informe a soma dos valores dos repasses das linhas de detalhe (Tipo 2) contidas no arquivo.
cLinha += CRLF                      //Caractere de Fim de Linha (Chr(13) + Chr(10)).
oFileGrv:write(cLinha)
//iif( lVisual, IncProc(), "")
lVarArq := iif(lStopArq .and. !QryTxt->(eof()), .t., .f.)
return


/*//-------------------------------------------------------------------
{Protheus.doc} PlAtuBQ3Tx
Grava na BQ3 a data da geração do arquivo DPS
@since    03/2021
//-------------------------------------------------------------------*/
static function PlAtuBQ3Tx(cQuery, cNumSeq, cCodOpe)
local cSql      := ""
local nRetUpd   := 0

cSql := " UPDATE " + cSTTabBQ3 
cSql += "   SET BQ3_DATARQ = '" + dtos(Date()) + "' "
cSql += " WHERE R_E_C_N_O_ IN ( " + cQuery + " ) " 

nRetUpd := TCSqlExec(cSql)
if nRetUpd < 0
    PlAtuBQ4(cNumSeq, cCodOpe, lVisual, "ER01", TCSQLError() )
endif
iif( lVisual, IncProc(), "")
return


/*//-------------------------------------------------------------------
{Protheus.doc} PlAtuBQ4
Função genérica de gravação da BQ2, utlizando MVC.
Devem estrar prefixadas com A - Automático / M - Manual - EX: A001
001 - Inclusão de Lote
002 - Alteração do Status do Lote
003 - Alteração do Status do Item
004 - Geração de DPS
ER01 - Erro de atualização nas datas da BQ3, após gerar DPS
ER02 - Erro de ao gerar o arquivo TXT no diretório escolhido
SCHD - Schedule atualizador
@since    03/2021
//-------------------------------------------------------------------*/
function PlAtuBQ4(cNumSeq, cOperad, lVisTela, cCodOcor, cMensagem, nOperac, aCampos)
local cRetCod       := ""
local nLaco         := 0
local oModelDPS     := FWLoadModel("PLSDPS3") 
local oObjBQ4		:= oModelDPS:GetModel('MASTERBQ4')
default cMensagem   := ""
default nOperac     := 3
default aCampos     := {}

oModelDPS:SetOperation(nOperac)
oModelDPS:Activate()

if nOperac == 3
    oObjBQ4:setValue("BQ4_FILIAL"	, cSTFilBQ4)
    oObjBQ4:setValue("BQ4_CODOPE"	, cOperad)
    oObjBQ4:setValue("BQ4_CODSEQ"	, cNumSeq)
    oObjBQ4:setValue("BQ4_CODOCO"	, cCodOcor)
    oObjBQ4:setValue("BQ4_USUARI"	, iif(lVisTela, substr(upper(alltrim(UsrRetName(RetCodUsr()))),1, 40), "Schedule") )
    oObjBQ4:setValue("BQ4_OBSERV"	, alltrim(getcomputername()) + CRLF + cMensagem)

    cRetCod := PlVldSX8("BQ4", oObjBQ4:getValue("BQ4_SEQPRO"))
    if ( cRetCod != oObjBQ4:getValue("BQ4_SEQPRO") )
        oObjBQ4:setValue("BQ4_SEQPRO"   , cRetCod)    
    endif
else
    if !empty(aCampos)
        for nLaco := 1 to len(aCampos)
            if len(aCampos[nLaco]) == 2
                aCampos[nLaco,2] := iif( aCampos[nLaco,1] == "BQ4_OBSERV", oObjBQ4:getValue("BQ4_OBSERV") + aCampos[nLaco,2], aCampos[nLaco,2] )
                oObjBQ4:setValue(aCampos[nLaco,1] , aCampos[nLaco,2])
            endif
        next
    endif    
endif
if (oModelDPS:VldData())
    oModelDPS:commitData()  
endif

PlLimpModel(oModelDPS, oObjBQ4)
       
return BQ4->BQ4_SEQPRO


/*//-------------------------------------------------------------------
{Protheus.doc} InicVarStatic
Função que verifica se existe as tabelas de DPS e inicializa as variáveis estáticas, para uso no sistema
@since    03/2021
//-------------------------------------------------------------------*/
static function InicVarStatic()
local lRet  := .t.

if !FWAliasInDic("BQ2") .or. !FWAliasInDic("BQ3") .or. !FWAliasInDic("BQ4")
    lRet := .f.
else
    cSTTabBQ2 := RetSqlName("BQ2")
    cSTTabBQ3 := RetSqlName("BQ3")
    cSTFilBQ2 := xFilial("BQ2")          
    cSTFilBQ3 := xFilial("BQ3") 
    cSTFilBQ4 := xFilial("BQ4")
endif      
return lRet


/*//-------------------------------------------------------------------
{Protheus.doc} PlVldSX8
Verifica se o código da BQ2_CODSEQ/BQ4_SEQPRO está duplicado e procura outros disponível.
@since    03/2021
//-------------------------------------------------------------------*/
static function PlVldSX8(cAlias, cCodGerado)
local aAreaTab		:= (cAlias)->(getArea())
local aCampos       := {"BQ2_CODSEQ", "BQ4_SEQPRO"}
default cCodGerado	:= ""

(cAlias)->(DbSetOrder(3))
if (cAlias)->( MsSeek(xFilial(cAlias) + cCodGerado ) )
	cCodGerado := GetSx8Num(cAlias, iif(cAlias == "BQ2", aCampos[1], aCampos[2]))
	(cAlias)->( ConfirmSx8() )

	//Prevenção para não pegar código igual já cadastrado
	while ( (cAlias)->(MsSeek(xFilial(cAlias) + cCodGerado)) )
		cCodGerado := GetSx8Num( cAlias, iif(cAlias == "BQ2", aCampos[1], aCampos[2]))
		(cAlias)->( ConfirmSx8() )
	enddo
endif
RestArea(aAreaTab)
return cCodGerado


/*//-------------------------------------------------------------------
{Protheus.doc} PGrvBQ3Mar
Grava BQ3. Deve passar o Model e o objeto do form para gravação
@since    03/2021
//-------------------------------------------------------------------*/
static function PGrvBQ3Mar(oModelBQ3, oObjBQ3, cOperad, cNumSeq, cData, nOperac, aContador, lMudaNota, cMensagem, cUsuario, lWasDPS)
default lMudaNota   := .f.
default lWasDPS     := .f.

if ( !empty(oModelBQ3) .and. !empty(oObjBQ3) )
    oModelBQ3:SetOperation(nOperac)
    oModelBQ3:Activate()

    if (nOperac == 3)
        oObjBQ3:setValue("BQ3_FILIAL"	, cSTFilBQ3)
        oObjBQ3:setValue("BQ3_CODOPE"	, cOperad)
        oObjBQ3:setValue("BQ3_CODSEQ"	, cNumSeq)
        oObjBQ3:setValue("BQ3_INCIDE"	, cData)
        oObjBQ3:setValue("BQ3_TIPDOC"	, QryIncAlt->TIPNOTA)  //NFE/NFTS
        oObjBQ3:setValue("BQ3_SITDOC"	, "1") //Inclusão
        oObjBQ3:setValue("BQ3_NUMDOC"	, QryIncAlt->DOC)
        oObjBQ3:setValue("BQ3_SERIE"	, QryIncAlt->SERIE)
        oObjBQ3:setValue("BQ3_FORNEC"	, QryIncAlt->FORNEC)
        oObjBQ3:setValue("BQ3_LOJA"	    , QryIncAlt->LOJA)
        oObjBQ3:setValue("BQ3_DATEMI"   , stod(QryIncAlt->EMISSAO))
        oObjBQ3:setValue("BQ3_VLRREP"	, QryIncAlt->VALBRUT)
        oObjBQ3:setValue("BQ3_CODISS"	, QryIncAlt->CODISS)
        oObjBQ3:setValue("BQ3_INSCCM"	, QryIncAlt->INSCMUN)
        oObjBQ3:setValue("BQ3_USUARI"	, cUsuario)
        aContador[1]++
    else
        if ( !lMudaNota .or. (lMudaNota .and. !lWasDPS) )
            oObjBQ3:setValue("BQ3_VLRREP"	, QryIncAlt->VALBRUT)  
            oObjBQ3:setValue("BQ3_CODISS"	, QryIncAlt->CODISS)
            oObjBQ3:setValue("BQ3_INSCCM"	, QryIncAlt->INSCMUN)
            oObjBQ3:setValue("BQ3_DATEMI"   , stod(QryIncAlt->EMISSAO))
        endif    
        if ( lWasDPS )
            oObjBQ3:setValue("BQ3_SITDOC"	, iif(!lMudaNota, "3", "2")) //Alteração / Se tipnota diferente, exclusão
            oObjBQ3:setValue("BQ3_DATARQ"	, ctod("")) //Limpo a data, para sair no arquivo que vai ser gerado como "correção"
            aContador[3] := .t.
        elseif lMudaNota
            oObjBQ3:setValue("BQ3_TIPDOC"	, QryIncAlt->TIPNOTA)
        endif 

        //Documento - Valor Antigo - Valor Novo
        cMensagem += STR0020 + QryIncAlt->(DOC+SERIE) + " - " + QryIncAlt->(FORNEC+LOJA) + " - " + ;
                     STR0018 + cvaltochar(BQ3->BQ3_VLRREP) + STR0019 + cvaltochar(QryIncAlt->VALBRUT) + iif(lMudaNota, " - " + ;
                     STR0018 + RetCombVal("BQ3_TIPDOC", BQ3->BQ3_TIPDOC) + STR0019 + RetCombVal("BQ3_TIPDOC", QryIncAlt->TIPNOTA), "") + CRLF
        
        If lMudaNota .AND. lWasDPS
            aContador[4]++
        Else
            aContador[2]++
        EndIf
    endif  

    if (oModelBQ3:VldData())
        oModelBQ3:commitData()  
    endif
    oModelBQ3:deActivate()
endif
return 


/*//-------------------------------------------------------------------
{Protheus.doc} RetCombVal
Retorna valores do combo
@since    03/2021
//-------------------------------------------------------------------*/
static function RetCombVal(cCampo, cValBusca)
local aDados    := separa(getsx3cache(cCampo,"X3_CBOX"), ";")
local cRetTxt   := cValBusca
local nPosicao  := 0

nPosicao := aScan(aDados, {|x| x = cValBusca})
if nPosicao > 0
    cRetTxt := alltrim(right( aDados[nPosicao], len(aDados[nPosicao]) - at( "=", aDados[nPosicao]) ))
endif
return cRetTxt





//QUERYS -> Querys das funções
/*//-------------------------------------------------------------------
{Protheus.doc} PlDPSQIncAlt
Query que verifica o que existe na SF1 e que ainda não foi colocado na BQ3, bem como o que existe na BQ3, mas teve valor alterado. 
@since    02/2021
//-------------------------------------------------------------------*/
function PlDPSQIncAlt(dData)
local cSql      := ""
local dDatIni   := ""
local dDatFim   := ""
default lJob    := .f.
default dData   := Date()

dDatIni   := dtos(FirstDate(dData)) //pegar o primeiro dia da incidência
dDatFim   := dtos(LastDate(dData)) //pegar o último dia da incidência.

cSql := " SELECT SF1.F1_DOC DOC, SF1.F1_SERIE SERIE, SF1.F1_FORNECE FORNEC, SF1.F1_LOJA LOJA, SF1.F1_EMISSAO EMISSAO, SF1.F1_DTDIGIT DATDIG, "
cSql += "    SF1.F1_VALBRUT VALBRUT,  SD1.D1_CODISS CODISS, SA2.A2_INSCRM INSCMUN, SA2.A2_NOME NOMFOR, "
cSql += "    (CASE WHEN  SF1.F1_ESPECIE = 'NFS' THEN '02' ELSE '01' END) TIPNOTA, BQ3.BQ3_VLRREP VALREP, BQ3.R_E_C_N_O_ RECBQ3 "
cSql += " FROM " + RetSqlName("SF1") + " SF1 "

cSql += " INNER JOIN " + RetSqlName("SD1") + " SD1 "
cSql += "    ON "
cSql += " 	    SD1.D1_FILIAL 	= '" + xFilial("SD1") + "' AND " 		
cSql += "       SD1.D1_DOC		= SF1.F1_DOC AND "
cSql += " 		SD1.D1_SERIE 	= SF1.F1_SERIE AND "
cSql += " 		SD1.D1_FORNECE 	= SF1.F1_FORNECE AND "
cSql += " 		SD1.D1_LOJA		= SF1.F1_LOJA  AND "
cSql += "       SD1.D1_CODISS IN ('04073','04111','04146','04139','04154','04189','04197','04219','04278','04340','04359','04375', "
cSql += "                         '04421','04430','04499','04502','04545','04553','04596','04650','04677','04723','04731','04871', "
cSql += "                         '04901','05053','05096','05134','05142','05223','05542','05576','05584','05539','05540') AND " 
cSql += "       SD1.D_E_L_E_T_  = ' ' "
 
cSql += " INNER JOIN " + RetSqlName("SA2") + " SA2 "
cSql += "    ON "
cSql += " 		SA2.A2_FILIAL 	= '" + xFilial("SA2") + "' AND "
cSql += " 		SA2.A2_COD		= SF1.F1_FORNECE AND "
cSql += " 		SA2.A2_LOJA 	= SF1.F1_LOJA  AND "
cSql += "       SA2.D_E_L_E_T_ = ' '  "
 
cSql += " LEFT JOIN " + cSTTabBQ3 + " BQ3 "
cSql += "    ON 
cSql += " 		BQ3.BQ3_FILIAL 	= '" + xFilial("BQ3") + "' AND "
cSql += " 		BQ3.BQ3_NUMDOC	= SF1.F1_DOC AND "
cSql += " 		BQ3.BQ3_SERIE 	= SF1.F1_SERIE AND "
cSql += " 		BQ3.BQ3_FORNEC  = SF1.F1_FORNECE AND "
cSql += " 		BQ3.BQ3_LOJA	= SF1.F1_LOJA AND "
cSql += "       BQ3.D_E_L_E_T_ = ' ' "

cSql += " WHERE SF1.F1_FILIAL = '" + xFilial("SF1") + "' AND SF1.D_E_L_E_T_ = ' ' AND "
cSql += "       SF1.F1_DTDIGIT BETWEEN '" + dDatIni + "' AND '" + dDatFim + "' "
 
cSql += " AND NOT EXISTS "
cSql += " 	( SELECT BQ3_FILIAL FROM " + RetSqlName("BQ3") + " BQ3E  WHERE "
cSql += "        BQ3E.BQ3_FILIAL = '" + xFilial("BQ3") + "' AND "
cSql += "        BQ3E.BQ3_NUMDOC = SF1.F1_DOC AND  "
cSql += "        BQ3E.BQ3_SERIE  = SF1.F1_SERIE AND "
cSql += "        BQ3E.BQ3_FORNEC = SF1.F1_FORNECE AND "
cSql += "        BQ3E.BQ3_VLRREP = SF1.F1_VALBRUT AND "
cSql += "        BQ3E.BQ3_TIPDOC = (CASE WHEN SF1.F1_ESPECIE = 'NFS' THEN '02' ELSE '01' END) AND "
cSql += "        BQ3E.D_E_L_E_T_ = ' '  "
cSql += "   ) "
 
cSql += " GROUP BY F1_DOC, F1_SERIE, F1_FORNECE, F1_LOJA, F1_EMISSAO, F1_DTDIGIT, F1_VALBRUT, "
cSql += " 	D1_CODISS, A2_INSCRM, A2_NOME, F1_ESPECIE, BQ3.BQ3_VLRREP, BQ3.R_E_C_N_O_ "
cSql += " 	ORDER BY SF1.F1_EMISSAO, SF1.F1_DOC, SF1.F1_SERIE "

return cSql


/*//-------------------------------------------------------------------
{Protheus.doc} PlDPSQExclu
Query que verifica dados que existem na BQ3, mas não existem na SF1, para deletar. 
@since    02/2021
//-------------------------------------------------------------------*/
function PlDPSQExclu(cDatIncide, cNumSeq, cOperad)
local cSql          := ""

cSql := " SELECT BQ3.R_E_C_N_O_ REC FROM " + cSTTabBQ3 + " BQ3 "
cSql += "   WHERE "
cSql += "     BQ3.BQ3_FILIAL     = '" + cSTFilBQ3  + "' "
cSql += "     AND BQ3.BQ3_CODOPE = '" + cOperad    + "' "
cSql += "     AND BQ3.BQ3_CODSEQ = '" + cNumSeq    + "' "
cSql += "     AND BQ3.BQ3_INCIDE = '" + cDatIncide + "' "
cSql += "     AND BQ3.BQ3_SITDOC = '1' "  //Se for exclusão/Alteração/vazio, ignorar
cSql += "     AND BQ3.D_E_L_E_T_ = ' ' "
cSql += "     AND NOT EXISTS "
cSql += "       ( SELECT F1_FILIAL FROM " + RetSqlName("SF1") + " SF1 "
cSql += "           WHERE "
cSql += "             SF1.F1_FILIAL      = '" + xFilial("SF1") + "' "
cSql += "             AND SF1.F1_DOC     = BQ3.BQ3_NUMDOC "
cSql += "             AND SF1.F1_SERIE   = BQ3.BQ3_SERIE  "
cSql += "             AND SF1.F1_FORNECE = BQ3.BQ3_FORNEC "
cSql += "             AND SF1.F1_LOJA    = BQ3.BQ3_LOJA "
cSql += "             AND SF1.D_E_L_E_T_ = ' ' "
cSql += "       ) "
return cSql


/*//-------------------------------------------------------------------
{Protheus.doc} PlDPSQLote
Query que verifica se o lote DPS na incidência da data informada já existe ou não, para sua criação.
@since    02/2021
//-------------------------------------------------------------------*/
function PlDPSQLote(cDatIncide, cOperad)
local cSql          := ""

cSql := " SELECT BQ2.BQ2_CODSEQ CODSEQ, BQ2.BQ2_CODOPE CODOPE FROM " + cSTTabBQ2 + " BQ2 "
cSql += "   WHERE "
cSql += "     BQ2.BQ2_FILIAL     = '" + cSTFilBQ2   + "' "
cSql += "     AND BQ2.BQ2_CODOPE = '" + cOperad     + "' "
cSql += "     AND BQ2.BQ2_INCIDE = '" + cDatIncide  + "' "
cSql += "     AND BQ2.D_E_L_E_T_ = ' ' "

return cSql


/*//-------------------------------------------------------------------
{Protheus.doc} PlVerDBQ3
Query que verifica o valor total dos registros de determinada incidência
@since    02/2021
//-------------------------------------------------------------------*/
function PlVerDBQ3(cDatIncide, cOperad, cNumSeq)
local cSql          := ""

cSql := " SELECT SUM(BQ3.BQ3_VLRREP) VLRTOTAL FROM " + cSTTabBQ3 + " BQ3 "
cSql += "   WHERE "
cSql += "     BQ3.BQ3_FILIAL     = '" + cSTFilBQ3      + "' "
cSql += "     AND BQ3.BQ3_CODOPE = '" + cOperad        + "' "
cSql += "     AND BQ3.BQ3_CODSEQ = '" + cNumSeq        + "' "
cSql += "     AND BQ3.BQ3_INCIDE = '" + cDatIncide     + "' "
cSql += "     AND BQ3.D_E_L_E_T_ = ' ' "

return cSql


/*//-------------------------------------------------------------------
{Protheus.doc} PLDPSQTxt
Query para buscar dados da incidência selecionada, para gerar o arquivo DPS e atualizar o campo BQ3_DATARQ
@since    03/2021
//-------------------------------------------------------------------*/
static function PLDPSQTxt(cCodOpe, cNumSeq, cData, cTipTxt, lRecno)
local cSql      := ""
default lRecno  := .f.

cSql := " SELECT " + iif( !lRecno, " BQ3.BQ3_INCIDE INCIDE, BQ3.BQ3_TIPDOC TIPDOC, BQ3.BQ3_SITDOC SITDOC, BQ3.BQ3_NUMDOC NUMDOC, BQ3.BQ3_SERIE SERIE, BQ3.BQ3_FORNEC FORNEC, " +;
             "BQ3.BQ3_LOJA LOJA, BQ3.BQ3_VLRREP VLRREP, BQ3.BQ3_CODISS CODISS, BQ3.BQ3_INSCCM INSCCM, BQ3.BQ3_DATARQ DATARQ", " BQ3.R_E_C_N_O_ " )
cSql += "   FROM " + cSTTabBQ3 + " BQ3 "
cSql += "     WHERE BQ3.BQ3_FILIAL = '" + cSTFilBQ3 + "' "
cSql += "       AND BQ3.BQ3_CODOPE = '" + cCodOpe   + "' "
cSql += "       AND BQ3.BQ3_CODSEQ = '" + cNumSeq   + "' " 
cSql += "       AND BQ3.BQ3_INCIDE = '" + cData     + "' "
if cTipTxt == "1"
    cSql += "       AND BQ3.BQ3_DATARQ = '        ' "
endif
cSql += "       AND BQ3.BQ3_SITDOC <> '9' "  //Não considerar no txt
cSql += "       AND BQ3.D_E_L_E_T_ = ' ' "
return cSql
