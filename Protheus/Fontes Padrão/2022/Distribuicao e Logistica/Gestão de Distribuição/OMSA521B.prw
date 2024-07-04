#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "OMSA521B.CH"

#DEFINE OMSA521B01 "OMSA521B01"
#DEFINE OMSA521B02 "OMSA521B02"
#DEFINE OMSA521B03 "OMSA521B03"

#DEFINE SnTipo      1
#Define SAliasCols  5
#Define ScTipoDoc  10

Static oBrowse    := Nil
Static lMs520Vld  := ExistBlock("MS520VLD",,.T.)
Static lSF2520E   := ExistBlock("SF2520E")
Static lMs520VldE := ExistTemplate("MS520VLD")
Static lSF2520ET  := ExistTemplate("SF2520E")
Static lIntACD    := SuperGetMV("MV_INTACD",.F.,"0") == "1"
Static nVlEntCom  := OsVlEntCom()

//-------------------------------------------------------------------
/*/{Protheus.doc} OMSA521B
Exclusão dos Documentos de Saída - Carga

@author  Guilherme A. Metzger
@since   20/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function OMSA521B()

	If !ExistPerg()
		OmsMessage(STR0009,,1) // "Não foi possível localizar o grupo de perguntas OMSA521B no dicionário de dados SX1. Entre em contato com a equipe de suporte TOTVS."
		Return
	EndIf

	If Pergunte("OMSA521B",.T.)
		oBrowse:= FWMBrowse():New()
		oBrowse:SetDescription(STR0001) // Exclusão dos Documentos de Saída - Carga
		oBrowse:SetMenuDef("OMSA521B")
		oBrowse:SetAlias("DAK")
		oBrowse:SetFilterDefault("@"+MontaQuery())
		oBrowse:SetFixedBrowse(.T.)
		oBrowse:SetWalkThru(.F.)
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetParam({|| ShowPerg()})
		oBrowse:Activate()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função de definição do menu

@author  Guilherme A. Metzger
@since   20/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "OM521Exclu" OPERATION 5 ACCESS 0 // "Excluir"
	
	IF ExistBlock("OM521BRW")
	   aRotina := ExecBlock("OM521BRW",.F.,.F.,aRotina)
	Endif
	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaQuery
Efetua a montagem do filtro a ser aplicado ao Browse

@author  Guilherme A. Metzger
@since   22/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MontaQuery()
Local cQryDAK := ""

	cQryDAK :=     " DAK_FILIAL  = '"+xFilial("DAK")+"'"
	cQryDAK += " AND DAK_COD    >= '"+MV_PAR01+"'"
	cQryDAK += " AND DAK_COD    <= '"+MV_PAR02+"'"
	cQryDAK += " AND DAK_DATA   >= '"+DtoS(MV_PAR03)+"'"
	cQryDAK += " AND DAK_DATA   <= '"+DtoS(MV_PAR04)+"'"
	If !Empty(MV_PAR05)
		cQryDAK += " AND DAK_CAMINH = '"+MV_PAR05+"'"
	EndIf
	cQryDAK += " AND DAK_FEZNF   = '1'"

Return cQryDAK

//-------------------------------------------------------------------
/*/{Protheus.doc} ShowPerg
Apresenta o grupo de perguntas conforme localização

@author  Guilherme A. Metzger
@since   20/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ShowPerg()

	If cPaisLoc == "BRA"
		Pergunte("MTA521",.T.)
	Else
		Pergunte("MATXNF",.T.)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OM521Exclu
Função chamada do menu principal, que define a exclusão a ser executada:
Localização Brasil x Demais Localizações

@author  Guilherme A. Metzger
@since   20/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function OM521Exclu()

	If !(DAK->DAK_ACEFIN == "2")
		OmsHelp(STR0003,STR0004,OMSA521B01) // "O Retorno Financeiro desta Carga já foi realizado."
		Return
	EndIf

	If !(DAK->DAK_ACECAR == "2")
		OmsHelp(STR0005,STR0006,OMSA521B02) // "Esta Carga encontra-se encerrada." // "Realize o estorno do Retorno da Carga antes de prosseguir."
		Return
	EndIf

	If OmsQuestion(STR0007) // "Confirma o estorno dos Documentos de Saída relacionados a esta Carga?"

		If cPaisLoc == "BRA"
			OM521BraNF()
		Else
			OM521LocNF()
		EndIf

		oBrowse:Refresh(.T.)

	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OM521BraNF
Executa a exclusão das NFs de Saída vinculada à Carga - Localização Brasil

@author  Eduardo Riera
@since   29/12/2001
@version 1.0
/*/
//-------------------------------------------------------------------
Function OM521BraNF()
Local aArea      := GetArea()
Local aAreaSF2   := SF2->(GetArea())
Local aAreaDAK   := DAK->(GetArea())
Local aRegSD2    := {}
Local aRegSE1    := {}
Local aRegSE2    := {}
Local cQuery     := ""
Local cAliasSF2  := ""
Local cSavFil    := cFilAnt
Local lValido    := .T.
Local lMostraCtb := .F.
Local lAglCtb    := .F.
Local lContab    := .F.
Local lCarteira  := .F.
Local lNewDCL    := SuperGetMv("MV_DCLNEW",.F.,.F.)
Local cOmsCplInt := SuperGetMv("MV_CPLINT",.F.,"2") //Integração OMS x CPL
Local lMaDelNFS  := .F.
Local lCanDelF2  := .F.

	If cOmsCplInt == "1"
		DAK->(dbSetOrder(1))
		If DAK->(MSseek(xFilial("DAK") + DAK->DAK_COD + DAK->DAK_SEQCAR))
			If !Empty(DAK->DAK_VIAROT)
				MV_PAR04 := 2
			EndIf
		EndIf
	EndIf

	If lNewDCL
		DCLvrLacre(DAK->DAK_COD)
	ElseIf FindFunction("TCCheck") .And. TCCheck('DCL') .And. FindFunction("vrLacreDCL")
		vrLacreDCL(DAK->DAK_COD)
	EndIf

	// Inicializa processo de lançamento no modulo PCO
	PcoIniLan("000101")

	Pergunte("MTA521",.F.)

	lMostraCtb := (MV_PAR01 == 1)
	lAglCtb    := (MV_PAR02 == 1)
	lContab    := (MV_PAR03 == 1)
	lCarteira  := (MV_PAR04 == 1)

	cQuery := "SELECT R_E_C_N_O_ RECNOSF2"
	cQuery +=  " FROM "+RetSqlName("SF2")+" SF2"
	cQuery += " WHERE "
	If nVlEntCom == 1
		cQuery += " SF2.F2_FILIAL  = '"+xFilial("SF2")+"' AND"
	EndIf
	cQuery +=     " SF2.F2_CARGA   = '"+DAK->DAK_COD+"'"
	cQuery += " AND SF2.F2_SEQCAR  = '"+DAK->DAK_SEQCAR+"'"
	cQuery += " AND SF2.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasSF2 := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2,.T.,.T.)

	While !(cAliasSF2)->( Eof() )

		SF2->( DbGoto((cAliasSF2)->RECNOSF2) )

		// Integracao com o ACD - Validacao da exclusao da Nota Fiscal de Saida
		If lIntACD
			lValido := CBMS520VLD()
		ElseIf lMs520VldE
			lValido := ExecTemplate("MS520VLD",.F.,.F.)
		EndIf

		If lValido .And. lMs520Vld
			lValido := ExecBlock("MS520VLD",.F.,.F.)
		EndIf

		// Verifica a Filial do SF2
		cFilAnt := Iif(!Empty(xFilial("SF2")),SF2->F2_FILIAL,cFilAnt)

		// Verifica se o estorno do documento de saida pode ser feito
		aRegSD2 := {}
		aRegSE1 := {}
		aRegSE2 := {}

		lCanDelF2 := MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2,,.F.,,lCarteira)

		If lValido .AND. lCanDelF2

			If lIntACD
				CBSF2520E()
			// Pontos de Entrada
			ElseIf lSF2520ET
				ExecTemplate("SF2520E",.F.,.F.)
			EndIf

			If lSF2520E
				ExecBlock("SF2520E",.F.,.F.)
			EndIf

			// Estorna o documento de saida
			//SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,lMostraCtb,lAglCtb,lContab,lCarteira))
			lMaDelNFS := MaDelNFS(aRegSD2,aRegSE1,aRegSE2,lMostraCtb,lAglCtb,lContab,lCarteira)
			SF2->(lMaDelNFS)
		EndIf

		MsUnLockAll()

		(cAliasSF2)->( DbSkip() )
	EndDo

	(cAliasSF2)->( DbCloseArea() )

	if !lCanDelF2 .Or. !lMaDelNFS
		OmsMessage("Carga não pôde ser excluída, pois alguma das Notas Fiscais não pôde ser cancelada/excluída. Verifique documentos individualmente.",,1) 
	EndIf	

// Restaura a integridade da rotina
cFilAnt := cSavFil
RestArea(aAreaSF2)
RestArea(aAreaDAK)
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OM521LocNF
Executa a exclusão das NFs de Saída vinculada à Carga - Demais Localizações

@author  Guilherme A. Metzger
@since   20/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function OM521LocNF()
Local aArea      := GetArea()
Local aAreaSF2   := SF2->(GetArea())
Local aAreaSD2   := SD2->(GetArea())
Local aAreaDAK   := DAK->(GetArea())
Local aRetHead   := {}
Local cQuery     := ""
Local cAliasSF2  := ""
Local lMostraCtb := Nil
Local lAglCtb    := Nil
Local lContab    := Nil
Local lCarteira  := Nil

Local aCab        := {}
Local aItem       := {}
Local aItens      := {}

Private aCfgNf    := {}
Private aHeader   := {}
Private aCpos     := {}
Private lDeleta   := .T.
Private cEspecie  := ""
Private cFunname  := ""
Private lUsaCor   := .F.
Private lAnulaSF3 := .F.
Private lGerarCFD := .F.
Private nNFTipo   := 0
Private cTipo     := ""

Private inclui    := .F. //indica que e inclusao/exclusão de dados (ExistChav())
Private n //linha atual do acols
Private nMoedaCor := 1
Private aHeader   := IIf(Type("aHeader")=="U",{},aHeader)
Private aNfItem   := IIf(Type("aNfItem")=="U",{},aNfItem)
Private aNfCab    := IIf(Type("aNfCab")=="U",{},aNfCab)
Private aRecnos   := {}

	If !VldExcLoc()
		Return
	EndIf

	Pergunte("MATXNF",.F.)

	lMostraCtb := (MV_PAR01 == 1)
	lAglCtb    := (MV_PAR02 == 1)
	lContab    := (MV_PAR03 == 1)
	lCarteira  := .T.
	
	aRetHead:=LocxHead("SD2"/*cAlias*/,.F./*lMark*/,{}/*aCpos*/,{}/*aCposNo*/,{}/*aCposExt*/,{}/*aPEHeader*/,.T./*lConsUso*/,.F./*lNewGetDados*/)

	aHeader:=aClone(aRetHead[1])
	aCpos  :=aClone(aRetHead[2])
	
	//cQuery := "SELECT R_E_C_N_O_ RECNOSF2"
	cQuery := "SELECT SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA, SF2.F2_TIPODOC"
	cQuery +=  " FROM "+RetSqlName("SF2")+" SF2"
	cQuery += " WHERE "
	If nVlEntCom == 1
		cQuery += " SF2.F2_FILIAL  = '"+xFilial("SF2")+"' AND"
	EndIf
	cQuery +=     " SF2.F2_CARGA   = '"+DAK->DAK_COD+"'"
	cQuery += " AND SF2.F2_SEQCAR  = '"+DAK->DAK_SEQCAR+"'"
	cQuery += " AND SF2.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasSF2 := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2,.T.,.T.)

	While !(cAliasSF2)->( Eof() )

		//Antiga forma de exclusão de Notas Fiscais, que começou a apresentar vários problemas relacionados a variáveis declaradas nos outros produtos.
		//SF2->( DbGoto((cAliasSF2)->RECNOSF2) )
		//cEspecie := SF2->F2_ESPECIE
		//aCfgNf := MontaCfgNf(Val(SF2->F2_TIPODOC),{},.F./*lTela*/)
		//nNFTipo := aCfgNf[SnTipo]
		//cTipo   := aCfgNf[ScTipoDoc]
		//NFSetImps(aCfgNf[SAliasCols])
		//LocxDelNf("SF2",SF2->(Recno()),lMostraCtb,lAglCtb,lContab,lCarteira,.F./*lTela*/,.F./*lPerg*/)

		//Nova forma de exclusão, utilizando ExecAuto da função MATA467N. Copiada da função "JA206CANC", fonte JURA206.PRW
		lMSErroAuto := .F.
		
		aCab := {}
		AADD(aCab, {"F2_DOC"    , (cAliasSF2)->F2_DOC    , Nil})
		AADD(aCab, {"F2_SERIE"  , (cAliasSF2)->F2_SERIE  , Nil})
		AADD(aCab, {"F2_CLIENTE", (cAliasSF2)->F2_CLIENTE, Nil})
		AADD(aCab, {"F2_LOJA"   , (cAliasSF2)->F2_LOJA   , Nil})
		AADD(aCab, {"F2_TIPODOC", (cAliasSF2)->F2_TIPODOC, Nil})
		
		SD2->(dbSetOrder(3))
		SD2->(dbSeek(xFilial("SD2") + (cAliasSF2)->F2_DOC + (cAliasSF2)->F2_SERIE + (cAliasSF2)->F2_CLIENTE + (cAliasSF2)->F2_LOJA))
		While SD2->(!Eof()) .And. SD2->D2_FILIAL == xFilial("SD2") .And. ;
				SD2->D2_DOC == (cAliasSF2)->F2_DOC .And. SD2->D2_SERIE == (cAliasSF2)->F2_SERIE .And. ;
				SD2->D2_CLIENTE == (cAliasSF2)->F2_CLIENTE .And. SD2->D2_LOJA == (cAliasSF2)->F2_LOJA
			aItem :={}
			AADD(aItem, {"D2_DOC"    , SD2->D2_DOC    , Nil})
			AADD(aItem, {"D2_SERIE"  , SD2->D2_SERIE  , Nil})
			AADD(aItem, {"D2_CLIENTE", SD2->D2_CLIENTE, Nil})
			AADD(aItem, {"D2_LOJA"   , SD2->D2_LOJA   , Nil})
			AADD(aItens, aClone(aItem))
			SD2->(dbSkip())
		EndDo
		
		MSExecAuto({|x,y,z| MATA467N(x,y,z)}, aCab, aItens, 5)		
		
		(cAliasSF2)->( DbSkip() )
	EndDo

	(cAliasSF2)->( DbCloseArea() )

RestArea(aAreaSD2)
RestArea(aAreaSF2)
RestArea(aAreaDAK)
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldExcLoc
Realiza validações complementares na exclusão de documentos de saída localizados

@author  Guilherme A. Metzger
@since   20/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VldExcLoc()
Local aArea      := GetArea()
Local cQuery     := ""
Local cAliasSF2  := ""
Local lRet       := .T.

	If cPaisLoc == "ARG"
		// Esta validação em particular encontra-se fora da LocxDelNf, portanto, teve que ser replicada para o OMS
		cQuery := "SELECT R_E_C_N_O_ RECNOSF2"
		cQuery +=  " FROM "+RetSqlName("SF2")+" SF2"
		cQuery += " WHERE "
		If nVlEntCom == 1
			cQuery += " SF2.F2_FILIAL  = '"+xFilial("SF2")+"' AND"
		EndIf
		cQuery +=     " SF2.F2_CARGA   = '"+DAK->DAK_COD+"'"
		cQuery += " AND SF2.F2_SEQCAR  = '"+DAK->DAK_SEQCAR+"'"
		cQuery += " AND (SF2.F2_EMCAEE  <> ' ' OR SF2.F2_CAEE <> ' ')"
		cQuery += " AND SF2.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cAliasSF2 := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2,.T.,.T.)
		If !(cAliasSF2)->(Eof())
			OmsMessage(STR0008,OMSA521B03,2) // "Exclusão não permitida. A carga está vinculada a faturas transmitidas para a AFIP."
			lRet := .F.
		EndIf
		(cAliasSF2)->(DbCloseArea())
	EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ExistPerg
Verifica se o grupo de perguntas da rotina existe

@author  Guilherme A. Metzger
@since   22/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function ExistPerg()
Local oSX1Util := FWSX1Util():New()
Local aGroup   := {}
Local lRet     := .T.

	oSX1Util:AddGroup("OMSA521B")

	oSX1Util:SearchGroup()

	aGroup := oSX1Util:GetGroup("OMSA521B")

	If Len(aGroup[2]) <= 0
		lRet := .F.
	EndIf

	FreeObj(oSX1Util)

Return lRet
