#Include 'Protheus.ch'
#include 'Fileio.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
#DEFINE ARQ_ANALISE_SIP "Log_Sip_Analise.Log"

Function CenAnaSip(lAuto)
    Local lJob        := .T.
    Local lRetCpy     := .F.
    local cPathArq	  := ""
    Local cComp       := ""
    Local cDir        := ""
    Local cArquivo	  := ""
    Local cBARRA      := ""
    Local lLinux      := IsSrvUnix()

    If !lAuto
        cComp:=B3D->(B3D_CODOPE+B3D_CDOBRI+B3D_CODIGO+B3D_TIPOBR+B3D_ANO+B3D_STATUS)
    EndIf

    If !lAuto .And. MsgYesNo("Esta rotina analisa cadastros básicos para gerar o SIP. O processamento é em segundo plano.Clique em Sim para processar a rotina ou Não para baixar um arquivo já gerado.","Análise SIP")

        startjob("CENANACR",getenvserver(),.F.,lAuto, lJob, cEmpAnt, cFilAnt,cComp,Dtos(B3D->B3D_VCTO))
        return
    Else

        IIF(lLinux,cBARRA:="/",cBARRA:="\")

        cDir:=cBARRA+"analise_sip"+cBARRA

        If !ExistDir(cDir)
            MakeDir(cDir)
        EndIf

        IIF(!lAuto,cArquivo  := "analise_sip_" + SubStr(cComp,14,4)+SubStr(cComp,11,2)+".csv",cArquivo  := "analise_sip_2200.csv")

        cPathArq := IIF(lAuto,"C:\SIP\",cGetFile("Arquivo csv | *.csv","Diretório para gravar o arquivo: "+cArquivo+". ",,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY,.F.))

        If !Empty(cPathArq)

            If !ExistDir(cPathArq)
                MakeDir(cPathArq)
            EndIf

            IIF(!lAuto,CpyS2T(cDir+cArquivo,cPathArq),"")
            lRetCpy := IIF(!lAuto,File(cPathArq+cArquivo),.T.)

        EndIf

    EndIF

    If !lAuto
        If lRetCpy
            MsgInfo("Arquivo: "+cArquivo+" baixado com sucesso!")
        Else
            If Empty(cPathArq)
                MsgInfo("Não foi possível copiar o arquivo "+cArquivo+" do servidor. Favor verificar se ele realmente já foi criado.")
            EndIf
        EndIf
    EndIF

Return lRetCpy

Function CENANACR(lAuto, lJob, cEmp, cFil,cComp,cDtVcto)
    Local cTxt   	  := "Trimestre;Operadora;Código da Crítica;Descrição da Crítica;" + CRLF
    Default cTriRec   := ""
    Default cEmp      := ""
    Default cFil      := ""
    Default cComp     := ""
    Default cDtVcto   := ""
    Default lAuto     := .F.
    Default lJob      := .T.

    cCodOpe  := IIF(!lAuto,SubStr(cComp,1,6),"417505")
    cCodObr  := IIF(!lAuto,SubStr(cComp,7,3),"005"   )
    cCodigo  := IIF(!lAuto,SubStr(cComp,10,3),"001"  )
    cAno     := IIF(!lAuto,SubStr(cComp,14,4),"2200" )
    cStatus  := IIF(!lAuto,SubStr(cComp,18,1),"6"    )
    cTriRec  := IIF(!lAuto,cAno + SubStr(cCodigo,2,2),"220001")

    If lJob
        RpcSetType(3)
        RpcSetEnv(cEmp,cFil,,,'PLS')
    EndIf

    //Verifica se o Compromisso posicionado está aberto e também se há compromisso anteriores em aberto.
    cTxt+= CenSip001(cTriRec,cCodOpe,cCodObr,cStatus,cDtVcto,lAuto)

    //Verifica o cadastro de natureza de saúde.Compara conteúdo de campos, idade e sexo
    cTxt+= CenSip002(cTriRec,cCodOpe,lAuto)

    //Verifica como estão as classificações na tabela padrão
    cTxt+= CenSip003(cTriRec,cCodOpe,lAuto)

    //Verifica se os procedimentos da tabela padrão estão de acordo com a TUSS
    cTxt+= CenSip004(cTriRec,cCodOpe,lAuto)

    //Verifica se os Produtos do PLS estão na Central Bi3 X B3J
    cTxt+= CenSip005(cTriRec,cCodOpe,lAuto)

    //Verifica se existe o diretório sip no servidor e também os schemas
    cTxt+= CenSip006(cTriRec,cCodOpe,lAuto)

    //Verifica se os beneficiários do PLS estão na Central
    cTxt+= CenSip007(cTriRec,cCodOpe,lAuto)

    cTxt+= "------;------;------;Fim do Processamento"
    //Gera o CSV
    CENGERCSV(cTrirec,cTxt,lAuto)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENGERCSV

Gera CSV

@author jose.paulo
@since 19/07/2022
/*/
//--------------------------------------------------------------------------------------------------
Function CENGERCSV(cTriRec,cTxt,lAuto)
    Local lLinux    := IsSrvUnix()
    Local cDir      := ""
    Local cArquivo	:= ""
    Local nArquivo  := 0

    Default cTxt    := ""
    Default cTriRec	:= ""
    Default lAuto   := .F.

    IIF(lLinux,cBARRA:="/",cBARRA:="\")

    cDir:=cBARRA+"analise_sip"+cBARRA

    If !ExistDir(cDir)
        MakeDir(cDir)
    EndIf

    cArquivo  := "analise_sip_" + AllTrim(cTriRec) + ".csv"
    nArquivo  := fCreate(cDir + cArquivo )

    If !Empty(cTriRec) .And. !Empty(cTxt)

        If nArquivo > 0
            FSeek(nArquivo,0,2)
            FWrite(nArquivo,cTxt + CRLF)
            FClose(nArquivo)
            cTxt := ""
        EndIf

    EndIf

Return

Function CenSip001(cTriRec,cCodOpe,cCodObr,cStatus,cDtVcto,lAuto)
    Local cTxt      := ""
    Local cSql      := ""
    Default cTrirec := ""
    Default cCodOpe := ""
    Default cCodObr := ""
    Default cStatus := ""
    Default cDtVcto := ""
    Default lAuto   := .F.

    If !Empty(cStatus) .And. Alltrim(cStatus) == "6" .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0001; Favor abrir o compromisso que estamos posicionados."
        cTxt+="Clique no Botão Obrigações->Mudar Status Comprom.-> Escolher Pendente Envio " + CRLF
    EndIf

    //B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_TIPOBR+B3D_STATUS+DTOS(B3D_VCTO)
    cSql := "SELECT R_E_C_N_O_ REC "
    cSql += "FROM " + RetSqlName("B3D") + " "
    cSql += "WHERE B3D_FILIAL = '" + xFilial("B3D") + "' AND B3D_CODOPE = '" + cCodOpe+ "' "
    cSql += "AND B3D_CDOBRI = '" + cCodObr+ "' "
    cSql += "AND B3D_TIPOBR = '1' "
    cSql += "AND B3D_STATUS <> '6' "
    cSql += "AND B3D_VCTO < '" + cDtVcto+ "' "
    cSql += "AND D_E_L_E_T_ = ' '  "

    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB3D",.F.,.T.)

    If TRBB3D->(!Eof()) .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0001;Há Compromissos anteriores que não foram finalizados. Posicione nos compromisso anteriores, "
        cTxt+="clique no botão obrigações->Mudar Status Comprom.->Escolher a Opção Finalizado. " + CRLF
    EndIF

    TRBB3D->(dbCloseArea())

Return cTxt

Function CenSip002(cTriRec,cCodOpe,lAuto)
    Local cTxt      := ""
    Local cSql      := ""
    Default cTrirec := ""
    Default cCodOpe := ""
    Default lAuto   :=.F.

    cSql := "SELECT UPPER(BF0_CODIGO) BF0_CODIGO, BF0_IDADE1, BF0_IDADE2, BF0_SEXO "
    cSql += "FROM " + RetSqlName("BF0") + " BF0 "
    cSql += "WHERE BF0_FILIAL = '" + xFilial("BF0") + "' AND BF0_GRUGEN = '" + AllTrim(GetNewPar("MV_PLGRSIP","0001")) + "' "
    cSql += "AND D_E_L_E_T_ = ' '  "
    cSql += "ORDER BY BF0_CODIGO"

    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBF01",.F.,.T.)


    If TRBBF01->(Eof())
        cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Não foi encontrado cadastro de Natureza de saúde de acordo com parâmetro MV_PLGRSIP." + CRLF
    EndIF

    Do While TRBBF01->(!Eof())

        If ALLTRIM(TRBBF01->BF0_CODIGO) == 'A'
            TRBBF01->(DBSkip())

        ElseIf ALLTRIM(TRBBF01->BF0_CODIGO) == 'C3'
            If TRBBF01->BF0_IDADE1 <> 25 .Or. TRBBF01->BF0_IDADE2 <> 59 .Or. TRBBF01->BF0_SEXO <> '2'
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 25 Idade até = 59 e sexo feminino. " + CRLF
            EndIF

        ElseIf ALLTRIM(TRBBF01->BF0_CODIGO) == 'C101'
            If TRBBF01->BF0_IDADE1 <> 50 .OR. TRBBF01->BF0_IDADE2 <> 69 .OR. TRBBF01->BF0_SEXO <> '2'
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 50 Idade até = 69 e sexo feminino. " + CRLF
            EndIF
        ElseIf ALLTRIM(TRBBF01->BF0_CODIGO) == 'C14'
            If TRBBF01->BF0_IDADE1 <> 50 .OR. TRBBF01->BF0_IDADE2 <> 69 .OR. !Empty(TRBBF01->BF0_SEXO)
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 50 Idade até = 69.O campo sexo deve ficar em branco. " + CRLF
            EndIF

        ElseIf ALLTRIM(TRBBF01->BF0_CODIGO) == 'E124'
            If TRBBF01->BF0_IDADE1 <> 60 .OR. TRBBF01->BF0_IDADE2 < 99 .OR. !Empty(TRBBF01->BF0_SEXO)
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 60 Idade até = 999.O campo sexo deve ficar em branco. " + CRLF
            EndIF

        ElseIf ALLTRIM(TRBBF01->BF0_CODIGO) == 'E141'
            If TRBBF01->BF0_IDADE1 <> 0 .OR. TRBBF01->BF0_IDADE2 <> 5 .OR. !Empty(TRBBF01->BF0_SEXO)
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 0 Idade até = 5.O campo sexo deve ficar em branco. " + CRLF
            EndIF

        ElseIf ALLTRIM(TRBBF01->BF0_CODIGO) == 'E142'
            If TRBBF01->BF0_IDADE1 <> 0 .OR. TRBBF01->BF0_IDADE2 <> 28 .OR. !Empty(TRBBF01->BF0_SEXO)
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 0 Idade até = 28.O campo sexo deve ficar em branco. " + CRLF
            EndIF

        ElseIf ALLTRIM(TRBBF01->BF0_CODIGO) == 'E1421'
            If TRBBF01->BF0_IDADE1 <> 0 .OR. TRBBF01->BF0_IDADE2 <> 6 .OR. !Empty(TRBBF01->BF0_SEXO)
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 0 Idade até = 6.O campo sexo deve ficar em branco. " + CRLF
            EndIF

        ElseIf ALLTRIM(TRBBF01->BF0_CODIGO) == 'I33'
            If TRBBF01->BF0_IDADE1 <> 0 .OR. TRBBF01->BF0_IDADE2 <> 12 .OR. !Empty(TRBBF01->BF0_SEXO)
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 0 Idade até = 12.O campo sexo deve ficar em branco. " + CRLF
            EndIF

        ElseIf ALLTRIM(TRBBF01->BF0_CODIGO) == 'I4'
            If TRBBF01->BF0_IDADE1 <> 12 .OR. TRBBF01->BF0_IDADE2 < 99 .OR. !Empty(TRBBF01->BF0_SEXO)
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 12 Idade até = 999.O campo sexo deve ficar em branco. " + CRLF
            EndIF

        ElseIf ALLTRIM(TRBBF01->BF0_CODIGO) == 'I5'
            If TRBBF01->BF0_IDADE1 <> 0 .OR. TRBBF01->BF0_IDADE2 <> 12 .OR. !Empty(TRBBF01->BF0_SEXO)
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 0 Idade até = 12.O campo sexo deve ficar em branco. " + CRLF
            EndIF

        ElseIf ALLTRIM(TRBBF01->BF0_CODIGO) == 'I6'
            If TRBBF01->BF0_IDADE1 <> 12 .OR. TRBBF01->BF0_IDADE2 < 99 .OR. !Empty(TRBBF01->BF0_SEXO)
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 12 Idade até = 999.O campo sexo deve ficar em branco. " + CRLF
            EndIF

        ElseIf ALLTRIM(TRBBF01->BF0_CODIGO) == 'I7'
            If TRBBF01->BF0_IDADE1 <> 12 .OR. TRBBF01->BF0_IDADE2 < 99 .OR. !Empty(TRBBF01->BF0_SEXO)
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 12 Idade até = 999.O campo sexo deve ficar em branco. " + CRLF
            EndIF

        ElseIf ALLTRIM(TRBBF01->BF0_CODIGO) == 'I8'
            If TRBBF01->BF0_IDADE1 <> 0 .OR. TRBBF01->BF0_IDADE2 <> 12 .OR. !Empty(TRBBF01->BF0_SEXO)
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 0 Idade até = 12.O campo sexo deve ficar em branco. " + CRLF
            EndIF

        ElseIf ALLTRIM(TRBBF01->BF0_CODIGO) == 'I9'
            If TRBBF01->BF0_IDADE1 <> 12 .OR. TRBBF01->BF0_IDADE2 < 99 .OR. !Empty(TRBBF01->BF0_SEXO)
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 12 Idade até = 999.O campo sexo deve ficar em branco. " + CRLF
            EndIF
        Else
            If TRBBF01->BF0_IDADE1 > 0 .OR. TRBBF01->BF0_IDADE2 < 110 .OR. !Empty(TRBBF01->BF0_SEXO)
                cTxt+=cTrirec +"; " + cCodOpe + "; 0002;Classificação "+AllTrim(TRBBF01->BF0_CODIGO)+" parametrizada incorretamente."
                cTxt+="Vá ao cadastro de Natureza de Saúde e coloque o campo Idade de = 0 Idade até = 999. O Campo Sexo deve estar em branco. " + CRLF
            EndIF

        EndIf

        TRBBF01->(DBSkip())
    EndDo

    TRBBF01->(dbCloseArea())

Return cTxt

Function CenSip003(cTriRec,cCodOpe,lAuto)
    Local cTxt          := ""
    Local cSql          := ""
    Local nCtA1         := 0
    Local nCtA2         := 0
    Local nCtB          := 0
    Local nCtC          := 0
    Local nCtC3         := 0
    Local nCtC101       := 0
    Local nCtD          := 0
    Local nCtE          := 0
    Local nCtE124       := 0
    Local nCtE141       := 0
    Local nCtE21        := 0
    Local nCtE22        := 0
    Local nCtE23        := 0
    Local nCtOI1        := 0
    Local nCtOI2        := 0
    Local nCtOI3        := 0
    Local nCtOI33       := 0
    Local nCtOI4        := 0
    Local nCtOI5        := 0
    Local nCtOI6        := 0
    Local nCtOI7        := 0
    Local nCtOI8        := 0
    Local nCtOI9        := 0
    Local nCtOI10       := 0

    Default cTrirec     := ""
    Default cCodOpe     := ""
    Default lAuto       := .F.

    cSql := "SELECT UPPER(BR8_CLASIP) BR8_CLASIP,UPPER(BR8_CLASP2) BR8_CLASP2,BR8_REGATD,BR8_FCAREN,BR8_CODPAD,BR8_CODPSA "
    cSql += "FROM " + RetSqlName("BR8") + " "
    cSql += "WHERE BR8_FILIAL = '" + xFilial("BR8") + "'"
    cSql += "  AND BR8_CLASIP <> ' ' OR BR8_CLASP2 <> ' ' "
    cSql += "  AND D_E_L_E_T_ = ' '  "

    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBR8",.F.,.T.)

    If TRBBR8->(Eof()) .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003;Não há procedimentos classificados na tabela padrão (BR8) campos BR8_CLASIP E BR8_CLASP2. " + CRLF
    EndIf

    Do While TRBBR8->(!Eof())

        If ALLTRIM(TRBBR8->BR8_CLASIP) <> '' .And. ALLTRIM(TRBBR8->BR8_CLASP2) <> ''
            cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Classificação incorreta. Não podemos ter os campos BR8_CLASIP e BR8_CLASP2 Preenchidos para o mesmo procedimento."
            cTxt+=" Quando o BR8_REGATD for igual internação o sistema vai considerar o BR8_CLASP2. Caso não seja internação vai considerar o BR8_CLASIP."
            cTxt+="Procedimento: "+TRBBR8->BR8_CODPAD+"" +TRBBR8->BR8_CODPSA+" " + CRLF

        ElseIf ALLTRIM(TRBBR8->BR8_CLASP2) <> "" .And. !('E' $ ALLTRIM(TRBBR8->BR8_CLASP2) )
            cTxt+=cTrirec +"; " + cCodOpe + "; 0003; No campo BR8_CLASP2 só deve conter classificações de internações ou seja que começam com E."
            cTxt+="Procedimento: "+TRBBR8->BR8_CODPAD+"" +TRBBR8->BR8_CODPSA+" " + CRLF

        ElseIf ALLTRIM(TRBBR8->BR8_CLASP2) <> "" .And. (ALLTRIM(TRBBR8->BR8_REGATD) == "" .Or. ALLTRIM(TRBBR8->BR8_CLASP2) <> "2")
            cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Procedimentos Classificados como E devem ter o campo BR8_REGATD preenchido como 2 - Internação. Favor ajustar."
            cTxt+="Procedimento: "+TRBBR8->BR8_CODPAD+"" +TRBBR8->BR8_CODPSA+" " + CRLF

        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) <> "" .And. (ALLTRIM(TRBBR8->BR8_REGATD) == "" .Or. ALLTRIM(TRBBR8->BR8_CLASP2) == "2")
            cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Procedimentos Classificados como A, B, C ou D devem ter o campo BR8_REGATD preenchido como 1 ou 3. Favor ajustar"
            cTxt+="Procedimento: "+TRBBR8->BR8_CODPAD+"" +TRBBR8->BR8_CODPSA+" " + CRLF

        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) <> "" .And. 'E' $ ALLTRIM(TRBBR8->BR8_CLASIP)
            cTxt+=cTrirec +"; " + cCodOpe + "; 0003; No campo BR8_CLASIP não pode conter classificações de internações."
            cTxt+="Procedimento: "+TRBBR8->BR8_CODPAD+"-" +TRBBR8->BR8_CODPSA+" " + CRLF

        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'A'
            cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Nunca devemos classificar procedimentos com A."
            cTxt+="Deve ser A1 para consulta ambulatorial e A2 para Consulta em emergência.Procedimento: "+TRBBR8->BR8_CODPAD+"" +TRBBR8->BR8_CODPSA+" " + CRLF

        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'A1'
            If TRBBR8->BR8_FCAREN == '1'
                nCtA1 ++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'A2'
            If TRBBR8->BR8_FCAREN == '1'
                nCtA2 ++
            EndIF
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'B'
            If TRBBR8->BR8_FCAREN == '1'
                nCtB++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'C'
            If TRBBR8->BR8_FCAREN == '1'
                nCtC++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'C3'
            If TRBBR8->BR8_FCAREN == '1'
                nCtC3++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'C101'
            If TRBBR8->BR8_FCAREN == '1'
                nCtC101++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'D'
            If TRBBR8->BR8_FCAREN == '1'
                nCtD++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASP2) == 'E'
            If TRBBR8->BR8_FCAREN == '1'
                nCtE++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASP2) == 'E124'
            If TRBBR8->BR8_FCAREN == '1'
                nCtE124++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASP2) == 'E141'
            If TRBBR8->BR8_FCAREN == '1'
                nCtE141++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASP2) == 'E21'
            If TRBBR8->BR8_FCAREN == '1'
                nCtE21++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASP2) == 'E22'
            If TRBBR8->BR8_FCAREN == '1'
                nCtE22++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASP2) == 'E23'
            If TRBBR8->BR8_FCAREN == '1'
                nCtE23++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'I1'
            If TRBBR8->BR8_FCAREN == '1'
                nCtOI1++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'I2'
            If TRBBR8->BR8_FCAREN == '1'
                nCtOI2++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'I3'
            If TRBBR8->BR8_FCAREN == '1'
                nCtOI3++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'I33'
            If TRBBR8->BR8_FCAREN == '1'
                nCtOI33++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'I4'
            If TRBBR8->BR8_FCAREN == '1'
                nCtOI4++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'I5'
            If TRBBR8->BR8_FCAREN == '1'
                nCtOI5++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'I6'
            If TRBBR8->BR8_FCAREN == '1'
                nCtOI6++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'I7'
            If TRBBR8->BR8_FCAREN == '1'
                nCtOI7++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'I8'
            If TRBBR8->BR8_FCAREN == '1'
                nCtOI8++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'I9'
            If TRBBR8->BR8_FCAREN == '1'
                nCtOI9++
            EndIf
        ElseIf ALLTRIM(TRBBR8->BR8_CLASIP) == 'I10'
            If TRBBR8->BR8_FCAREN == '1'
                nCtOI10++
            EndIf
        Else
            If TRBBR8->BR8_FCAREN == '1'
                If 'E' $ ALLTRIM(TRBBR8->BR8_CLASP2)
                    cTxt+=cTrirec +"; " + cCodOpe + "; 0003; O Procedimento "+TRBBR8->BR8_CODPSA+" está classificado como "+TRBBR8->BR8_CLASP2+"."
                    cTxt+="Ele não pode ter o campo BR8_FCAREN=1.Isso prejudica o cálculo de expostos. " + CRLF
                Else
                    cTxt+=cTrirec +"; " + cCodOpe + "; 0003; O Procedimento "+TRBBR8->BR8_CODPSA+" está classificado como "+TRBBR8->BR8_CLASIP+"."
                    cTxt+="Ele não pode ter o campo BR8_FCAREN=1.Isso prejudica o cálculo de expostos. " + CRLF
                EndIF
            EndIF
        EndIf

        TRBBR8->(DBSkip())

    EndDo

    TRBBR8->(dbCloseArea())

    If nCtA1 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Apenas 1 procedimento da classificação A1, deve ter o campo BR8_FCAREN = 1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIf

    If nCtA2 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Apenas 1 procedimento da classificação A2, deve ter o campo BR8_FCAREN = 1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIf

    If nCtB <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=B e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtC <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=C e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtC3 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=C3 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtC101 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=C101 e campo BR8_FCAREN=1."
        cTxt+="Sugerimos um destes procedimentos: 40808033 ou 40808041. Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtD <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=D e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtE <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=E e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtE124 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=E124 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtE141 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=E141 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtE21 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=E21 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtE22 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=E22 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtE23 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=E23 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtOI1 <>  1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=I1 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtOI2 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=I2 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtOI3 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=I3 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtOI33 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=I33 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtOI4 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=I4 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtOI5 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=I5 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtOI6 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=I6 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtOI7 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=I7 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtOI8 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=I8 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtOI9 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=I9 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

    If nCtOI10 <> 1 .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0003; Somente 1 Procedimento deve ser classificado como BR8_CLASIP=I10 e campo BR8_FCAREN=1."
        cTxt+="Isso irá influenciar no cálculo de expostos. " + CRLF
    EndIF

Return IIF(Len(cTxt)>100,cTxt,"")

Function CenSip004(cTriRec,cCodOpe,lAuto)
    Local nI   := 0
    Local aProc:= {}
    Local cRet := ""
    Local cTxt:="A1;10101012;A1;10106014;A1;10106030;A1;20101082;A1;40401022;A1;20101074;A1;20101015;A1;20101090;A1;10106049;A1;10106146;A1;20101210;A1;20101228;"
    cTxt+="A1;20101236;A1;20201133;A11;10101012;A12;10101012;A13;10101012;A14;10101012;A15;10101012;A16;10101012;A17;10101012;A18;10101012;A19;10101012;A110;10101012;"
    cTxt+="A111;10101012;A112;10101012;A113;10101012;A114;10101012;A115;10101012;A116;10101012;A117;10101012;A118;10101012;A119;10101012;A120;10101012;A121;10101012;"
    cTxt+="A122;10101012;A123;10101012;A124;10101012;A125;10101012;A2;10101039;B1;50000144;B1;50000160;B1;50000195;B1;50000209;B1;50000217;B1;50000233;B1;50000713;"
    cTxt+="B1;50000721;B1;50000730;B1;50000748;B1;50000756;B1;50000764;B1;50000772;B1;50000780;B1;50000853;B1;50000861;B1;50000870;B1;50001060;B1;50001078;B2;50000586;"
    cTxt+="B2;50000616;B2;50000640;B2;50000659;B3;50000560;B4;50000012;B4;50000020;B4;50000039;B4;50000047;B4;50000055;B4;50000080;B4;50000110;B4;50000128;B4;50000136;"
    cTxt+="B5;50000462;B5;50000470;B5;50000489;B5;50000497;B5;50000500;B5;50000519;C1;41101170;C1;41101324;C1;41101340;C1;41101332;C1;41101103;C1;41101316;C1;41101278;"
    cTxt+="C1;41101030;C1;41101219;C1;41101227;C1;41101138;C1;41101146;C1;41101154;C1;41101286;C1;41101014;C1;41101367;C1;41101375;C1;41101065;C1;41101049;C1;41101090;"
    cTxt+="C1;41101197;C1;41101235;C1;41101359;C1;41101162;C1;41101260;C1;41101251;C1;41101073;C1;41101081;C1;41101308;C1;41101189;C1;41101200;C1;41101057;C1;41101294;"
    cTxt+="C1;41101111;C1;41101243;C1;41101383;C1;41101391;C1;41101022;C1;41101120;C1;41102010;C1;41101430;C1;41101448;C1;41101456;C1;41101464;C1;41101472;C1;41101480;"
    cTxt+="C1;41101499;C1;41101502;C1;41101510;C1;41101529;C1;41101537;C1;41101545;C1;41101553;C1;41101561;C1;41101570;C1;41101588;C1;41101596;C1;41101600;C1;41101618;"
    cTxt+="C1;41101626;C1;41101634;C1;41101642;C1;41101650;C1;41101669;C2;41001109;C2;41001095;C2;41001168;C2;41001184;C2;41001176;C2;41001141;C2;41001044;C2;41001133;"
    cTxt+="C2;41001125;C2;41001087;C2;41001010;C2;41001052;C2;41001214;C2;41001192;C2;41001036;C2;41001028;C2;41001117;C2;41001060;C2;41001206;C2;41001150;C2;41001222;"
    cTxt+="C2;41001079;C2;41002016;C2;41001230;C2;41001249;C2;41001257;C2;41001265;C2;41001273;C2;41001281;C2;41001290;C2;41001303;C2;41001311;C2;41001320;C2;41001338;"
    cTxt+="C2;41001346;C2;41001354;C2;41001362;C2;41001370;C2;41001389;C2;41001397;C2;41001400;C2;41001419;C2;41001427;C2;41001435;C2;41001443;C2;41001451;C2;41001460;"
    cTxt+="C2;41001478;C2;41001486;C2;41001494;C2;41001508;C2;41001516;C2;41001524;C2;41001532;C2;41002040;C2;41002059;C3;40601137;C4;40808122;C4;40808130;C4;40808149;"
    cTxt+="C5;40901106;C6;40201031;C6;40201058;C6;40202054;C6;40201368;C7;40201120;C7;40201333;C7;40201139;C7;40202615;C7;40202038;C7;40202747;C8;40202666;C8;40202135;"
    cTxt+="C8;40201082;C8;40201090;C8;40201350;C9;20102011;C9;20102020;C9;20102100;C10;40808033;C10;40808041;C10;40808173;C101;40808033;C101;40808041;C101;40808173;"
    cTxt+="C11;40701034;C11;40701042;C11;40701050;C11;40701131;C11;40701140;C11;40701069;C12;40704017;C12;40704025;C13;40302075;C13;40302733;C14;40303136;C14;40303250;"
    cTxt+="C15;40801128;C15;40801160;C15;40801101;C15;40801110;C15;40801012;C15;40801020;C15;40801039;C15;40801209;C15;40801080;C15;40801055;C15;40801047;C15;40801098;"
    cTxt+="C15;40801136;C15;40801195;C15;40801187;C15;40801179;C15;40801063;C15;40801071;C15;40801152;C15;40801144;C15;40802019;C15;40802027;C15;40802035;C15;40802043;"
    cTxt+="C15;40802086;C15;40802060;C15;40802051;C15;40802094;C15;40802116;C15;40802108;C15;40802078;C15;40803104;C15;40803066;C15;40803074;C15;40803023;C15;40803082;"
    cTxt+="C15;40803040;C15;40803031;C15;40803090;C15;40803015;C15;40803147;C15;40803120;C15;40803139;C15;40803058;C15;40803112;C15;40804011;C15;40804020;C15;40804038;"
    cTxt+="C15;40804046;C15;40804054;C15;40804062;C15;40804070;C15;40804089;C15;40804097;C15;40804100;C15;40804119;C15;40804127;C15;40804135;C15;40805085;C15;40805093;"
    cTxt+="C15;40805050;C15;40805077;C15;40805069;C15;40805018;C15;40805026;C15;40805034;C15;40805042;C15;40806081;C15;40806103;C15;40806111;C15;40806120;C15;40806138;"
    cTxt+="C15;40806146;C15;40806154;C15;40806162;C15;40806090;C15;40806014;C15;40806170;C15;40806030;C15;40806057;C15;40806049;C15;40806073;C15;40806189;C15;40806065;"
    cTxt+="C15;40806022;C15;40807029;C15;40807070;C15;40807053;C15;40807061;C15;40807010;C15;40807045;C15;40807037;C15;40808025;C15;40808017;C15;40808050;C15;40808092;"
    cTxt+="C15;40808114;C15;40808106;C15;40808068;C15;40808157;C15;40808165;C15;40808084;C15;40809048;C15;40809110;C15;40809129;C15;40809064;C15;40809072;C15;40809080;"
    cTxt+="C15;40809013;C15;40809056;C15;40809030;C15;40809137;C15;40809099;C15;40809021;C15;40810011;C15;40811018;C15;40811026;C15;40812014;C15;40812022;C15;40812030;"
    cTxt+="C15;40812049;C15;40812057;C15;40812065;C15;40812073;C15;40812081;C15;40812090;C15;40812103;C15;40812111;C15;40812120;C15;40812138;C15;40812146;C15;40814130;"
    cTxt+="C15;40803155;C15;40806197;C15;40806200;C15;40806219;C15;40807088;C15;40807096;C15;40807100;C16;40101037;C16;40101045;C16;41401158;C16;41401166;C16;41401174;"
    cTxt+="C16;41401182;C16;41401190;C16;41401204;C16;40101061;C17;40901122;C17;40901572;C18;40901181;C18;40901173;C19;40901130;C20;40901262;D1;40401014;D2;20104278;"
    cTxt+="D2;20104286;D2;20104430;D2;20104243;D2;20104251;D2;20104294;D2;20104308;D3;41203070;D3;41203089;D3;41203097;D4;30909147;D4;30909139;D5;30909031;D6;31303269;"
    cTxt+="D6;31303293;E121;31002218;E121;31002390;E122;31304010;E122;31304052;E123;31205046;E123;31205070;E124;30725127;E124;30725135;E124;30725160;E124;30725100;"
    cTxt+="E124;30725119;E124;30725194;E124;30724058;E124;30724066;E124;30724074;E124;30724082;E125;30724279;E125;30726255;E125;30717159;E126;30904021;E126;30904161;"
    cTxt+="E127;30904145;E127;30904137;E127;30904099;E127;30904080;E127;30904102;E127;30904064;E127;30904153;E127;30904110;E127;30904129;E131;31309127;E132;31309054;"
    cTxt+="E132;31309208;I1;81000065;I2;81000294;I2;81000324;I2;81000340;I2;81000367;I2;81000375;I2;81000383;I2;81000405;I2;81000413;I2;81000421;I2;81000430;I2;81000472;"
    cTxt+="I2;81000480;I3;87000016;I3;87000024;I3;84000031;I3;84000058;I3;84000074;I3;84000090;I3;84000112;I3;84000139;I3;84000163;I3;84000171;I3;84000198;I3;84000201;"
    cTxt+="I3;85300055;I3;84000228;I3;84000236;I3;84000244;I3;84000252;I31;87000016;I31;87000024;I31;84000139;I32;84000090;I33;84000074;I33;84000058;I4;85300047;"
    cTxt+="I5;83000135;I6;85100048;I6;85100064;I6;85100099;I6;85100102;I6;85100110;I6;85100129;I6;85100137;I6;85100145;I6;85100153;I6;85100161;I6;85100196;I6;85100200;"
    cTxt+="I6;85100218;I6;85100226;I6;85100048;I7;85100064;I7;85100099;I7;85100102;I7;85100110;I7;85100129;I7;85100137;I7;85100145;I7;85100153;I7;85100161;I7;85100196;"
    cTxt+="I7;85100200;I7;85100218;I7;85100226;I7;82000875;I8;83000151;I9;85200131;I9;85200166;I9;85200140;I9;85200158;I10;85100170;I10;85100188;I10;85400181;I10;85400190;"
    cTxt+="I10;85400220;I10;85400238;I10;85400262;I10;85400297;I10;85400300;I10;85400319;I10;85400327;I10;85400335;I10;85400343;I10;85400351;I10;85400378;I10;85400386;"
    cTxt+="I10;85400408;I10;85400424;I10;85400513;I10;85400521;I10;85400530;I10;85400548;I10;85500097;I10;85500100;I10;85500119;I10;85500127;I10;85400122;I10;85400130;"
    cTxt+="I10;85500038;I10;85500046;I10;85500054;I11;83000020;I11;83000046;I11;83000062;I11;87000040;I11;87000059;I11;87000067;I11;85400106;I11;85400114;I11;85400149;"
    cTxt+="I11;85400157;I11;85400165;I11;85400173;I11;85400556;"

    Default lAuto   := .F.

    aProc:=StrTokArr(cTxt,";")
    cTxt:=""

    For nI:= 2 to Len(aProc) step 2
        cTxt += "'"+aProc[nI]+"',"+""
    Next

    cTxt:= Substr(cTxt,1,Len(cTxt)-1)

    cSql := "SELECT UPPER(BR8_CLASIP) BR8_CLASIP,UPPER(BR8_CLASP2) BR8_CLASP2,BR8_CODPSA "
    cSql += "FROM " + RetSqlName("BR8") + " "
    cSql += "WHERE BR8_FILIAL = '" + xFilial("BR8") + "'"
    cSql += "  AND BR8_CODPSA IN ( "+cTxt+" )"
    cSql += "  AND BR8_CLASIP = ' ' AND BR8_CLASP2 = ' ' AND BR8_TPPROC='0' "
    cSql += "  AND D_E_L_E_T_ = ' '  "

    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBBR802",.F.,.T.)

    While TRBBR802->(!Eof())
        nPos:= aScan(aProc,{ |x| AllTrim(x) == AllTrim(TRBBR802->BR8_CODPSA)})
        nPos:=nPos-1
        cRet += cTrirec +"; " + cCodOpe + "; 0004;Procedimento: "+AllTrim(TRBBR802->BR8_CODPSA)+" da tabela TUSS não classificado."
        cRet +="Classificação TUSS:"+aProc[nPos]+ "" + CRLF
        TRBBR802->(DBSkip())
    EndDo

    TRBBR802->(dbCloseArea())

Return cRet

Function CenSip005(cTriRec,cCodOpe,lAuto)
    Local cTxt      := ""
    Local cSql      := ""
    Default cTrirec := ""
    Default cCodOpe := ""
    Default lAuto   := .F.

    cSql += "SELECT BI3_CODINT, BI3_CODIGO, BI3_DESCRI, BI3_VERSAO, BI3_ABRANG, BA0_SUSEP  "
    cSql += "FROM " + RetSqlName("BI3") + " BI3,"  + RetSqlName("BA0") + " BA0 "
    cSql += "WHERE BI3_FILIAL = '" + xFilial('BI3') + "'  AND BA0_FILIAL = '" + xFilial('BA0') + "' "
    cSql += "AND BA0_SUSEP = '"+cCodOpe+ "' "
    cSql += "AND BI3_CODINT = BA0_CODIDE||BA0_CODINT "
    cSql += "AND BI3.D_E_L_E_T_ = ' ' "
    cSql += "GROUP BY BI3_CODINT, BI3_CODIGO, BI3_DESCRI, BI3_VERSAO, BI3_ABRANG, BA0_SUSEP "

    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBPRO",.F.,.T.)


    If TRBPRO->(Eof()) .Or. lAuto
        cTxt+=cTrirec +"; " + cCodOpe + "; 0005; Não foi encontrado Produtos cadastrados para Operadora: "+cCodOpe+" "+ CRLF
    EndIF

    While TRBPRO->(!Eof())
        If !BuscaB3J(TRBPRO->BA0_SUSEP+TRBPRO->BI3_CODIGO+TRBPRO->BI3_VERSAO) .Or. lAuto
            cTxt+=cTrirec +"; " + cCodOpe + "; 0005; O Produto "+TRBPRO->BI3_CODIGO+" Versão: "+TRBPRO->BI3_VERSAO+" não foi encontrado na Central."
            cTxt+=" Solicitamos que acesse a Central de Obrigações vá em Produtos/Planos e realize a Importação dos Produtos. Após Importar realize a validação na mesma tela." + CRLF
        EndIf
        TRBPRO->(DBSkip())
    EndDo

    TRBPRO->(dbCloseArea())

Return cTxt

Function CenSip006(cTriRec,cCodOpe,lAuto)
    Local cTxt      := ""
    Local cDir      := "sip"
    Local cSipV1    :="sipV1_02.xsd"
    Local cSipCx    :="sipSimpleTypeV1_02.xsd"
    Local cSipTp    :="sipComplexTypeV1_02.xsd"
    Local lLinux    := IsSrvUnix()
    Default cTrirec := ""
    Default cCodOpe := ""
    Default lAuto   := .F.

    IIF(lLinux,cBARRA:="/",cBARRA:="\")

    If !ExistDir(cBARRA+cDir)
        cTxt+= cTrirec +"; " + cCodOpe + "; 0006;Diretório sip não encontrado.No servidor dever ter um diretório chamado sip com os XSDs do sip dentro."+ CRLF
    else
        If !File(cBARRA+cDir+cBARRA+cSipV1) .Or. !File(cBARRA+cDir+cBARRA+cSipCx) .Or. !File(cBARRA+cDir+cBARRA+cSipTp) .Or. lAuto
            cTxt+= cTrirec +"; " + cCodOpe + "; 0006;Schemas não encontrados.No servidor, deve ter os schemas do SIP dentro do diretório sip."
            cTxt+="Os Schemas são: " +cSipV1+ ", " +cSipCx+ " e " +cSipTp+". "+ CRLF
        EndIF
    EndIf

Return cTxt

Function CenSip007(cTriRec,cCodOpe,lAuto)
    Local cSql      := ""
    Local cDataRef  := ""
    Local cDatBlo   := ""
    Local cOpePadr	:= PlsIntPad()
    Local cTxt      := ""
    Local cDb       := Alltrim(Upper(TcGetDb()) )
    Local lPodeBR8  := .F.
    Local cCodSeg   := ""
    Local lAtenOdon := .F.
    Local cForCon   := ""
    Local cChaveProd:= ""

    Default cTrirec := ""
    Default cCodOpe := ""
    Default lAuto   := .F.

    B3K->(DBSetOrder(1))

    cDataRef := CENDATREF(cTriRec)
    cDatBlo := DataTrimestre(cDataRef,"1")

    cSql := " SELECT "
    cSql += " '" + SubStr(cOpePadr,1,1) + "' BA0_CODIDE, '" + SubStr(cOpePadr,2,3) + "' BA0_CODINT, "
    cSql += " BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DATCAR, BA1_DATINC, BA1_DATNAS, "
    cSql += " BA1_DATBLO, BA1_SEXO, BA1_NOMUSR, BA3_CODPLA, BA3_VERSAO, BA1_CODPLA, BA1_VERSAO, "
    cSql += " BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB, BA1_DIGITO, BG9_TIPO, BG9_REPASS "
    cSql += " FROM "
    cSql += " " + RetSqlName("BA1") + " BA1 "
    cSql += " LEFT JOIN " + RetSqlName("BT5") + " BT5 ON "
    cSql += "     BT5_FILIAL = BA1_FILIAL "
    cSql += "     AND BT5_CODINT = BA1_CODINT "
    cSql += "     AND BT5_CODIGO = BA1_CODEMP "
    cSql += "     AND BT5_NUMCON = BA1_CONEMP "
    cSql += "     AND BT5_VERSAO = BA1_VERCON "
    cSql += "     AND BT5_INFANS = '1' "
    cSql += "     AND BT5.D_E_L_E_T_ = ' ' "
    cSql += " LEFT JOIN " + RetSqlName("BQC") + " BQC ON "
    cSql += "     BQC_FILIAL = BT5_FILIAL "

    IIF(cDb $ "ORACLE/POSTGRES",cSql += "     AND BQC_CODIGO = BT5_CODINT || BT5_CODIGO ",cSql += "     AND BQC_CODIGO = BT5_CODINT + BT5_CODIGO ")

    cSql += "     AND BQC_NUMCON = BT5_NUMCON "
    cSql += "     AND BQC_VERCON = BT5_VERSAO "
    cSql += "     AND BQC_SUBCON = BA1_SUBCON "
    cSql += "     AND BQC_VERSUB = BA1_VERSUB "
    cSql += "     AND BQC_INFANS = '1' "
    cSql += "     AND BQC.D_E_L_E_T_ = ' ', "
    cSql += " " + RetSqlName("BA3") + " BA3, " + RetSqlName("BG9") + " BG9 "
    cSql += " WHERE "
    cSql += " BA1_FILIAL = '" + xFilial("BA1") + "' AND BA3_FILIAL = '" + xFilial("BA3") + "' "
    cSql += " AND BG9_FILIAL = '" + xFilial("BG9") + "' "
    cSql += " AND BA1_CODINT = '" + cOpePadr + "' AND BA1_OPEORI = '" + cOpePadr + "' "
    cSql += " AND BA1_CODINT = BA3_CODINT AND BA1_CODEMP = BA3_CODEMP AND BA1_MATRIC = BA3_MATRIC "
    cSql += " AND BA1_CODINT = BG9_CODINT AND BA1_CODEMP = BG9_CODIGO "

    cSql += " AND BG9_REPASS <> '1' "
    cSql += " AND ( BA1_DATBLO = ' ' OR BA1_DATBLO >= '" + cDatBlo + "' ) "
    cSql += " AND BA1_DATINC <= '" + DataTrimestre(cDataRef,"2") + "' "
    cSql += " AND BA1_INFANS = '1' "
    cSql += " AND BA1.D_E_L_E_T_ = ' ' AND BA3.D_E_L_E_T_ = ' ' AND BG9.D_E_L_E_T_ = ' ' "

    cSql := ChangeQuery(cSql)

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBEXP",.F.,.T.)

    While TRBEXP->(!Eof())

        cChaveProd := PegaProduto("TRBEXP",@lPodeBR8,@cCodSeg,@lAtenOdon,@cForCon)//Vou pegar o produto na familia ou beneficiario, segmentacao, forma de contratacao e se atende odonto

        If PulaProduto("TRBEXP",cChaveProd)//Despreza produto nao informado a ANS
            TRBEXP->(dbSkip())
            Loop
        EndIf

        //B3K_FILIAL+B3K_CODOPE+B3K_MATRIC+B3K_STATUS
        If !B3K->(dbSeek(xFilial("B3K")+cCodOpe+PADR(TRBEXP->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),tamSX3("B3K_MATRIC")[1])))
            cTxt+= cTrirec +"; " + cCodOpe + "; 0007;A Matrícula "+Alltrim(TRBEXP->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO))+" existe no PLS (BA1), mas"
            cTxt+= " não foi encontrada na Central (B3K).Solicitamos que realize a importação e validação dos Beneficiários na Central."
            cTxt+= "Acesse a Central e vá em Atualizações/ Beneficiários ->Botão Outras Ações-> Imp. Beneficiários.Após importação rode as validações na mesma tela."+ CRLF
        Else
            If AllTrim(B3K->B3K_STATUS)<>'2'
                cTxt+= cTrirec +"; " + cCodOpe + "; 0007;Matrícula "+AllTrim(B3K->B3K_MATRIC)+" aguardando validação.Acesse a Central e vá em
                cTxt+= "Atualizações/ Beneficiários ->Botão Outras Ações-> Marque o beneficiário ->clique no botão Outras Ações->Valid.Selec.->Regras SIP."+ CRLF

            EndIF

        EndIf

        TRBEXP->(DbSkip())

    EndDo

    TRBEXP->(dbCloseArea())

Return cTxt

Function BuscaB3J(cChv)
    Local cSql:= ""
    Local lAchou := .F.
    Default cChv := ""

    cSql := " SELECT B3J_CODIGO FROM " + RetSqlName("B3J")
    cSql += " WHERE B3J_FILIAL = '" + xFilial("B3J") + "' "
    cSql += " AND B3J_CODOPE = '" + SUbStr(cChv,1,6) + "' "
    cSql += " AND B3J_CODIGO = '" + SUbStr(cChv,7,7) + "' "
    cSql += " AND D_E_L_E_T_ = ' '"
    cSql := ChangeQuery(cSql)
    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB3J",.F.,.T.)

    If !TRBB3J->(Eof())
        lAchou := .T.
    EndIf
    TRBB3J->(dbCloseArea())

Return lAchou
