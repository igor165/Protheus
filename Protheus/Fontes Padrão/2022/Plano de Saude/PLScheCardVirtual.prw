#Include "PROTHEUS.CH"
#Include "TBICONN.CH"

#Define NAME_LOG "PLScheCardVirtual.log"
#Define GERACAO_LOTE 2

//-----------------------------------------------------------------
/*/{Protheus.doc} PLScheCardVirtual
Schedule para geração dos cartões virtuais dos Beneficiários
 
@author Vinicius Queiros Teixeira
@since 10/01/2022
@version Protheus 12
/*/
//-----------------------------------------------------------------
Main Function PLScheCardVirtual()

    Local cMensagemErro := ""
    Local cOperadora := ""
    Local cMotivo := ""
    Local nDiaInicial := 0
    Local nDiaFinal := 0
    Local nDiaValidade := 0
    Local dDtValidInicial := CTod(" / / ")
    Local dDtValidFinal := CTod(" / / ")
    Local dDtValidade := CTod(" / / ")

    cOperadora := IIf(!Empty(MV_PAR01), MV_PAR01, "")
    cMotivo := IIf(!Empty(MV_PAR02), MV_PAR02, "")
    nDiaInicial := IIf(!Empty(MV_PAR03), MV_PAR03, 0)
    nDiaFinal := IIf(!Empty(MV_PAR04), MV_PAR04, 0)
    nDiaValidade := IIf(!Empty(MV_PAR05), MV_PAR05, 0)

    ImpLog(Replicate("=", 50), .F.)
    ImpLog("*** Iniciando Schedule [PLScheCardVirtual]")
    Conout("*** Iniciando Schedule [PLScheCardVirtual]")

    BA0->(DbSetOrder(1))

    cMensagemErro := IIf(Empty(cOperadora), "*** Nao foi informada a operadora nos parametros da rotina.", cMensagemErro)
    cMensagemErro := IIf(Empty(cMensagemErro) .And. !BA0->(MsSeek(xFilial("BA0")+cOperadora)), "*** A Operadora informada nao foi encontrada no sistema.", cMensagemErro)
    cMensagemErro := IIf(Empty(cMensagemErro) .And. !MayIUseCode("PLScheCardVirtual"+cOperadora), "Job PLMapComSche"+cOperadora+" - Já está em execução, aguarde o termino do processamento.", cMensagemErro)

    If Empty(cMensagemErro)
        dDtValidInicial := dDataBase - nDiaInicial
        dDtValidFinal := dDataBase + nDiaFinal
        dDtValidade := dDataBase + nDiaValidade 

        PLCardVirtualProcess(cOperadora, cMotivo, dDtValidInicial, dDtValidFinal, dDtValidade)
        FreeUsedCode() // Libera Semaforo
    EndIf

    ImpLog("*** Finalizando Schedule [PLScheCardVirtual]")
    Conout("*** Finalizando Schedule [PLScheCardVirtual]")
    ImpLog(Replicate("=", 50), .F.)
    ImpLog("",.F.)    

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} SchedDef
Pergunte do Schedule
 
@author Vinicius Queiros Teixeira
@since 10/01/2022
@version Protheus 12
/*/
//-----------------------------------------------------------------
Static Function SchedDef()
Return {"P", "PLSCARDVIR",, {}, ""}


//-----------------------------------------------------------------
/*/{Protheus.doc} PLCardVirtualProcess
Processa a geração dos cartões virtuais dos Beneficiários
 
@author Vinicius Queiros Teixeira
@since 10/01/2022
@version Protheus 12
/*/
//-----------------------------------------------------------------
Function PLCardVirtualProcess(cOperadora, cMotivo, dDtValidInicial, dDtValidFinal, dDtValidade)

    Local oDadosLote := Nil
    Local aLoteGerado := {}
    Local lProcess := .F.
    Local nX := 0
    Local cAliasTemp := ""
    Local cQuery := ""
    Local aRetorno := {}

    Local lCartaoVirtual := .T.
    Local cCodLote := ""

    If !CheckField()
        ImpLog("*** Dicionario de dados invalido")
        ImpLog("Verifique o cadastro dos campos referente ao cartao virtual.", .F.)
    Else
        cQuery := GetQueryProcess(cOperadora)

        cAliasTemp := GetNextAlias()
        dbUseArea(.T., "TOPCONN", tcGenQry(,,cQuery), cAliasTemp, .F., .T.)

        If !(cAliasTemp)->(Eof())

            While !(cAliasTemp)->(Eof())

                ImpLog("Iniciando processamento da empresa")
                ImpLog("Codigo: "+(cAliasTemp)->EMPRESA, .F.)
                ImpLog("Contrato/SubContrato: "+(cAliasTemp)->CONTRATO+"/"+(cAliasTemp)->SUBCONTRATO, .F.)

                oDadosLote := JsonObject():New()

                // Dados da memoria do Lote de Cartao
                oDadosLote["operadora"] := cOperadora
                oDadosLote["motivo"] := cMotivo
                oDadosLote["tipoGrupo"] := (cAliasTemp)->TIPO
                oDadosLote["empresaDe"] := (cAliasTemp)->EMPRESA
                oDadosLote["empresaAte"] := (cAliasTemp)->EMPRESA
                oDadosLote["contratoDe"] := (cAliasTemp)->CONTRATO
                oDadosLote["contratoAte"] := IIf(!Empty((cAliasTemp)->CONTRATO), (cAliasTemp)->CONTRATO, Replicate("Z", TamSX3("BDE_CONATE")[1]))
                oDadosLote["subcontratoDe"] := (cAliasTemp)->SUBCONTRATO
                oDadosLote["subcontratoAte"] := IIf(!Empty((cAliasTemp)->SUBCONTRATO), (cAliasTemp)->SUBCONTRATO, Replicate("Z", TamSX3("BDE_SUBATE")[1]))
                oDadosLote["matriculaDe"] := ""
                oDadosLote["matriculaAte"] := Replicate("Z", TamSX3("BDE_MATATE")[1])
                oDadosLote["dataValidadeDe"] := dDtValidInicial
                oDadosLote["dataValidadeAte"] := dDtValidFinal
                oDadosLote["mudaValidade"] := "1"
                oDadosLote["dataValidade"] := dDtValidade
                // Dados do processamento
                oDadosLote["cartaoVirtual"] := lCartaoVirtual
    
                aLoteGerado := PLLoteCartao(oDadosLote)

                cCodLote := aLoteGerado[1] // 1 = Codigo do Lote gerado
                aRetorno := aLoteGerado[2] // 2 = Dados do Lote gerado

                ImpLog("*** Resultado do Processamento", .F.)
                ImpLog("Status do Lote: "+IIf(!Empty(cCodLote), "Gerado com sucesso", "Falha na geração"), .F.)
                ImpLog("Quantidade Gerada: "+cValToChar(aRetorno[2][1]), .F.)
                ImpLog("Quantidade de Criticas: "+cValToChar(Len(aRetorno[3])), .F.)

                If Len(aRetorno[3]) > 0
                    For nX := 1 To Len(aRetorno[3])
                        ImpLog("-> "+aRetorno[3][nX][1]+" - "+ StrTran(aRetorno[3][nX][2], Chr(13)+Chr(10), " "), .F.)
                    Next nX
                EndIf

                If !Empty(cCodLote)
                    ImpLog("Codigo do Lote Gerado: "+cCodLote, .F.)
                EndIf
                ImpLog("",.F.)

                FreeObj(oDadosLote)
                oDadosLote := Nil

                lProcess := .T.
                cCodLote := ""

                (cAliasTemp)->(DbSkip())
            EndDo				
        Else
            ImpLog("*** Nenhuma empresa cadastrada com cartao virtual", .F.)
        EndIf
    
        (cAliasTemp)->(DbCloseArea())
    EndIF

Return lProcess


//-----------------------------------------------------------------
/*/{Protheus.doc} GetQueryProcess
Retorna query que irá processar os cartões virtuais dos beneficiários
 
@author Vinicius Queiros Teixeira
@since 10/01/2022
@version Protheus 12
/*/
//-----------------------------------------------------------------
Static Function GetQueryProcess(cOperadora)

    Local cQuery := ""
    Local cBanco := Upper(TCGetDb())
    Local cConcateCampo := ""

    cConcateCampo := IIf(cBanco $ "ORACLE/POSTGRES", "||", "+")

    // Empresa Pessoa Juricia
    cQuery := "SELECT BG9.BG9_TIPO AS TIPO, BG9.BG9_CODIGO AS EMPRESA, BT5.BT5_NUMCON AS CONTRATO, BQC.BQC_SUBCON AS SUBCONTRATO "
    cQuery += "FROM "+RetSQLName("BG9")+" BG9 "

    cQuery += " INNER JOIN "+RetSQLName("BT5")+" BT5 "
    cQuery += "  ON BT5.BT5_FILIAL = '"+xFilial("BT5")+"'"
    cQuery += " AND BT5.BT5_CODINT = BG9.BG9_CODINT"
    cQuery += " AND BT5.BT5_CODIGO = BG9.BG9_CODIGO"
    cQuery += " AND BT5.BT5_CARVIR <> '0'"
    cQuery += " AND BT5.D_E_L_E_T_= ' '"

    cQuery += " INNER JOIN "+RetSQLName("BQC")+" BQC "
    cQuery += "  ON BQC.BQC_FILIAL = '"+xFilial("BQC")+"'"
    cQuery += " AND BQC.BQC_CODIGO = BT5.BT5_CODINT "+cConcateCampo+" BT5.BT5_CODIGO "
    cQuery += " AND BQC.BQC_CARVIR <> '0'"
    cQuery += " AND BQC.D_E_L_E_T_= ' '"

	cQuery += " WHERE BG9.BG9_FILIAL = '"+xFilial("BG9")+"'"
	cQuery += "	  AND BG9.BG9_CODINT = '"+cOperadora+"'"
    cQuery += "	  AND BG9.BG9_TIPO = '2'"
    cQuery += "   AND BG9.BG9_CARVIR = '1'"
	cQuery += "   AND BG9.D_E_L_E_T_= ' ' "

    cQuery += " UNION "

    // Empresa Pessoa Fisica
    cQuery += "SELECT BG9.BG9_TIPO AS TIPO, BG9.BG9_CODIGO AS EMPRESA, '' AS CONTRATO, '' AS SUBCONTRATO "
    cQuery += "FROM "+RetSQLName("BG9")+" BG9 "

	cQuery += " WHERE BG9.BG9_FILIAL = '"+xFilial("BG9")+"'"
	cQuery += "	  AND BG9.BG9_CODINT = '"+cOperadora+"'"
    cQuery += "	  AND BG9.BG9_TIPO = '1'"
    cQuery += "   AND BG9.BG9_CARVIR = '1'"
	cQuery += "   AND BG9.D_E_L_E_T_= ' ' "

Return cQuery 


//-----------------------------------------------------------------
/*/{Protheus.doc} CloseLoteCardVirtual
Encerra o Lote de Cartão 
 
@author Vinicius Queiros Teixeira
@since 11/01/2022
@version Protheus 12
/*/
//-----------------------------------------------------------------
Static Function CloseLoteCardVirtual(cOperadora, cCodLote)

    Local lCloseLote := .F.

    BDE->(DbSetOrder(1))
	BED->(DbSetOrder(4))
    BA1->(DbSetOrder(2))

    If BDE->(MsSeek(xFilial("BDE")+cOperadora+cCodLote))

        BDE->(RecLock("BDE", .F.))
	        BDE->BDE_STACAR := "2" // Encerrado
        BDE->(MsUnlock())
		
	    If BED->(MsSeek(xFilial("BED")+BDE->BDE_CODIGO))
            While xFilial("BED") == BED->BED_FILIAL .And. BDE->BDE_CODIGO == BED->BED_CDIDEN

                BED->(RecLock("BED", .F.))
                    BED->BED_STACAR := "2" // Encerrado
                BED->(MsUnlock())
                
                If BA1->(MsSeek(xFilial("BA1")+BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG+BED_DIGITO))) .And. BA1->BA1_EMICAR == "2"
                    BA1->(RecLock("BA1", .F.))
                        BA1->BA1_EMICAR := "3" // Cartao Gerado
                    BA1->(MsUnLock())          
                Endif

                BED->(DbSkip())
            EndDo
        EndIf

        lCloseLote := .T.
    EndIf
    
Return lCloseLote


//-----------------------------------------------------------------
/*/{Protheus.doc} CheckField
Verifica se os campos do processo de cartão virtual estão criados
na base de dados
 
@author Vinicius Queiros Teixeira
@since 29/03/2022
@version Protheus 12
/*/
//-----------------------------------------------------------------
Static Function CheckField()

    Local lCheck := .F.

    If BA3->(FieldPos("BA3_CARVIR")) > 0 .And. BA1->(FieldPos("BA1_CARVIR")) > 0 .And.;
       BG9->(FieldPos("BG9_CARVIR")) > 0 .And. BQC->(FieldPos("BQC_CARVIR")) > 0 .And.;
       BT5->(FieldPos("BT5_CARVIR")) > 0 .And. BT6->(FieldPos("BT6_CARVIR")) > 0 .And.;
       BI3->(FieldPos("BI3_CARVIR")) > 0

        lCheck := .T.
    EndIf
 
Return lCheck


//-----------------------------------------------------------------
/*/{Protheus.doc} PLLoteCartao
Gera o Lote de Cartão de identificação 
 
@author Vinicius Queiros Teixeira
@since 30/03/2022
@version Protheus 12
/*/
//-----------------------------------------------------------------
Function PLLoteCartao(oDadosLote)

    Local aLoteGerado := {}
    Local aRetorno := {}
    Local aDados := {}
    Local lImpressao := .F.
    Local cCodLote := ""

    Default oDadosLote := Nil

    If ValType(oDadosLote) == "J" 
        RegToMemory("BDE", .T.)

        M->BDE_CODINT := oDadosLote["operadora"]
        M->BDE_MOTIVO := oDadosLote["motivo"]
        M->BDE_TIPGRU := oDadosLote["tipoGrupo"]
        M->BDE_EMPDE := oDadosLote["empresaDe"]
        M->BDE_EMPATE := oDadosLote["empresaAte"]
        M->BDE_CONDE := oDadosLote["contratoDe"]
        M->BDE_CONATE := oDadosLote["contratoAte"]
        M->BDE_SUBDE := oDadosLote["subcontratoDe"]
        M->BDE_SUBATE := oDadosLote["subcontratoAte"]
        M->BDE_MATDE := oDadosLote["matriculaDe"]
        M->BDE_MATATE := oDadosLote["matriculaAte"]
        M->BDE_DATA1 := oDadosLote["dataValidadeDe"] 
        M->BDE_DATA2 := oDadosLote["dataValidadeAte"]
        M->BDE_MUDVAL := oDadosLote["mudaValidade"]
        M->BDE_DATVAL := oDadosLote["dataValidade"]

        aDados := {M->BDE_CODIGO, M->BDE_MOTIVO, M->BDE_CODINT, Nil, GERACAO_LOTE, Nil, Nil, Nil, Nil, Nil, .T., lImpressao}

        aRetorno := Plsa264(aDados, .T., Nil, Nil, oDadosLote["cartaoVirtual"])

        If aRetorno[2][1] > 0

            cCodLote := M->BDE_CODIGO
            M->BDE_QTD := aRetorno[2][1]
            M->BDE_STACAR := "1" // Em Aberto

            BDE->(PLUPTENC("BDE", 3))

            CloseLoteCardVirtual(oDadosLote["operadora"], cCodLote)
        EndIf
    EndIf

    aLoteGerado := {cCodLote, aRetorno} 

Return aLoteGerado


//-----------------------------------------------------------------
/*/{Protheus.doc} ImpLog
Imprime Log do Schedule
 
@author Vinicius Queiros Teixeira
@since 10/01/2022
@version Protheus 12
/*/
//-----------------------------------------------------------------
Static Function ImpLog(cMsg, lDateTime)

    Local cDateTime := ""

    Default cMsg := ""
    Default lDateTime := .T.

    If lDateTime
        cDateTime := Substr(DTOS(Date()), 7, 2)+"/"+Substr(DTOS(Date()), 5, 2)+"/"+Substr(DTOS(Date()), 1, 4)+"-"+Time()
        PlsPtuLog("["+cDateTime+"] " + cMsg, NAME_LOG)
    Else
        PlsPtuLog(cMsg, NAME_LOG)
    EndIf    

Return