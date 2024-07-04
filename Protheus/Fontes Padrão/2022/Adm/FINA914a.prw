#Include "Protheus.ch"
#Include "Fina914a.ch"
#Include "FWMVCDEF.CH"
#Include "TopConn.ch"
#Include "Tbiconn.ch"

Static __lAPixTpd := .F.
Static __lAutomat := .F.
Static __lSchedul := .F.
Static __oRegiFIF := Nil
Static __oRegiFV3 := Nil
//--------------------------------------------------------------------------
/*{Protheus.doc} FINA914a()
Rotina para importação dos processos de Pagamentos Digitais através da API do TPD
@author Sidney Santos
@since 20/10/2021
@version 12.1.33
*/
//--------------------------------------------------------------------------
Function FINA914a(aConfig As Array, l914aAuto As Logical, oJSONAuto)
	Local lTudoOK 		As Logical
	Local lEnvAberto  	As Logical
	Local cMay    		As Char

	Default aConfig 	:= {}
	Default l914aAuto 	:= .F.
	Default oJSONAuto 	:= Nil
	
	//Inicializa variáveis.
	lTudoOK 	:= .T.
	lEnvAberto  := .F.
    cMay := 'FINA914a'

	 If !Empty(aConfig) .And. IsBlind()
        cEmpAnt 	:= aConfig[2]
        cFilAnt 	:= aConfig[3]
		__lSchedul 	:= .T.
    EndIf

	If l914aAuto
        __lAutomat := .T.
    EndIf

	If __lSchedul .Or. __lAutomat
		//Verifica se a empresa está montada
        RpcSetEnv(cEmpAnt, cFilAnt, /*cUser*/, /*cPass*/, 'FIN', cMay, { 'FVR', 'FIF', 'FV3' })
        lEnvAberto := .T.
	EndIf

	If (lTudoOK := AllTrim((FwModeAccess("FVR",1) + FwModeAccess("FVR",2) + FwModeAccess("FVR",3))) == "CCC")
		lTudoOK := AllTrim((FwModeAccess("FV3",1) + FwModeAccess("FV3",2) + FwModeAccess("FV3",3))) == "CCC"
	EndIf
	
	If lTudoOK
		If !MayIUseCode(cMay)
			lTudoOK := .F.
			Help(" ", 1, "F914AAUSO", Nil, STR0003, 2, 0, Nil, Nil, Nil, Nil, Nil, {})
		Endif
		
		If lTudoOK
			__lAPixTpd := (FindFunction("F918AtuTPD") .And. F918AtuTPD())
			
			If __lAPixTpd
				If Empty(l914aAuto) .And. Empty(__lSchedul)
					F914aWiz()
				ElseIf l914aAuto .Or. (__lSchedul .And. F914aAutoriz())
					F914aApiImp(,,IIf(__lAutomat, oJSONAuto, NIL))
				EndIf
			Else//Ambiente desatualizado para utilizar esse recurso
				Help(" ", 1, "F914aDesatu", Nil, STR0005, 2, 0, Nil, Nil, Nil, Nil, Nil, { STR0006 })
			EndIf		
		EndIf
	Else
		Help(" ", 1, "F914ACOMPART", Nil, STR0004, 2, 0, Nil, Nil, Nil, Nil, Nil, {})
	EndIf

Return Nil

//--------------------------------------------------------------------------
/*{Protheus.doc} F914aWiz()
Montagem do wizard para importação da API

@author Sidney Santos
@since 20/10/2021
@version 12.1.33
*/
//--------------------------------------------------------------------------
Function F914aWiz()
	Local dIniApi		As Date
	Local dFimApi		As Date

	Private oStepWiz 	As Object
	Private oPagina1 	As Object
	Private oPagina2 	As Object
	Private oPagina3 	As Object
	Private oPagina4 	As Object
	Private oPagina5 	As Object
	Private aHdrFVR     As Array 
	Private aLogFVR     As Array 
	Private oColBrwLog  As Object 
	Private n1          As Numeric 
	Private n2          As Numeric 
	Private n3          As Numeric 
	Private n4          As Numeric 
	Private n5          As Numeric 
	Private n6          As Numeric 
	Private n7          As Numeric 
	Private n8          As Numeric 
	Private n9          As Numeric 
	Private n10         As Numeric 
	Private n11         As Numeric 
	Private n12         As Numeric 
	Private n13         As Numeric 
	Private n14         As Numeric 
	Private n15         As Numeric 
	Private n16         As Numeric 
	Private oBrowse     As Object
	Private lQtdAlt     As Logical 
	Private lAutoriz	As Logical

	aHdrFVR  	:= {}
	aLogFVR  	:= {}
	lQtdAlt	 	:= (FVR->(ColumnPos('FVR_QTDALT')) > 0)
	dIniApi		:= CToD("")
	dFimApi		:= CToD("")
	lAutoriz	:= .F.

		//									    altura, comprimento
		DEFINE DIALOG oDlg TITLE '' From 0, 30 TO 600, 1381 Pixel

		//                                      comprimento, altura
		oPanel := TPanel():New(0, 0, "", oDlg,,,,,, 678, 300)

		// Instancia a classe FWWizardControl	
		oStepWiz := FWWizardControl():New(oPanel)	
		oStepWiz:ActiveUISteps()
		
		//----------------------
		// Página 1
		//----------------------
		oPagina1 := oStepWiz:AddStep(STR0007, { | Panel | Step1(Panel) })
		oPagina1:SetStepDescription(STR0008)
		oPagina1:SetNextTitle(STR0009)
		oPagina1:SetNextAction({ || F914aAutoriz(oDlg) })  
		oPagina1:SetCancelAction({ || oDlg:End() })		   
		
		//----------------------
		// Página 2
		//----------------------
		oPagina2 := oStepWiz:AddStep(STR0010, { | Panel | Step2(Panel, @dIniApi, @dFimApi) })
		oPagina2:SetStepDescription(STR0011)
		oPagina2:SetNextTitle(STR0012)
		oPagina2:SetNextAction({ || VldStep2(dIniApi, dFimApi) })
		oPagina2:SetCancelWhen({ || .T. })
		oPagina2:SetPrevAction({ || .T. })	
		
		//----------------------
		// Página 3
		//----------------------
		oPagina3 := oStepWiz:AddStep(STR0013, { | Panel | Step3(Panel) })
		oPagina3:SetStepDescription(STR0014)
		oPagina3:SetNextTitle(STR0015)
		oPagina3:SetNextAction({ || oDlg:End() })
		oPagina2:SetCancelWhen({ || .F. })
		oPagina3:SetPrevWhen({ || .F. })	
			
		oStepWiz:Activate()
		
		ACTIVATE DIALOG oDlg CENTER
		
		oStepWiz:Destroy()

Return

//--------------------------------------------------------------------------
// Início dos blocos de construçãos das páginas de cada passo
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
/*{Protheus.doc} Step1
Construção do Painel 1

@param oPanel

@author Pedro Pereira Lima
@since 18/12/2017
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Step1(oPanel As Object)
	Local oFont1		As Object
	Local oFont2		As Object
	Local oSayDesc1		As Object
	Local oSayDesc2		As Object

	oFont1 	:= TFont():New( ,, -20, .T., .T.,,,,, )
	oFont2 	:= TFont():New(STR0016,, -15, .F., .F.,,,,, )

	oSayDesc1	:= TSay():New( 50, 180, { || STR0001 }, oPanel,, oFont1,,,, .T., CLR_BLUE, )
	oSayDesc2	:= TSay():New( 75, 280, { || STR0002 }, oPanel,, oFont1,,,, .T., CLR_BLUE, )

Return

//--------------------------------------------------------------------------
/*{Protheus.doc} F914aAutoriz(oDlg)
Verifica se tem comunicação com a API

@author Sidney Santos
@since 19/10/2021
@version 12.1.33
@param oDlg, Object, objeto Dialog
@return lRet, Logical, verifica se tem as informações de login salvas na tabela do framework e valida a conexão
*/
//-------------------------------------------------------------------------
Function F914aAutoriz(oDlg As Object) As Logical
	Local lRet As Logical

	oRecHub := F914aComunic()

	If !(lRet := oRecHub:ValidConn())
		Help(NIL, NIL, STR0017, NIL, STR0018, 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0019 + cEmpAnt + STR0020 + cFilAnt + STR0021 + oRecHub:cCodeComp + STR0022 + oRecHub:cURLRAC + STR0023 + oRecHub:cUserName })
		lRet := .F.
		oDlg:End()
	EndIf

Return lRet

//--------------------------------------------------------------------------
/*{Protheus.doc} F914aComunic()
Verifica se tem comunicação com a API

@author Sidney Silva
@since 19/10/2021
@version 12.1.33
*/
//-------------------------------------------------------------------------
Static Function F914aComunic() As Object
	Local cPDUrl			As Character
	Local cPDUser			As Character
	Local cPDPss			As Character
	Local cPDTenant			As Character
	Local cExtBusId			As Character
	Local oRecHub			As Object

	oRecHub     := FINReceiveHubTPD():New()
	cPDUrl      := oRecHub:GetURL()
	cPDUser     := PADR(oRecHub:cUserName,50)
	cPDPss      := PADR(oRecHub:cPassword,50)
	cPDTenant   := PADR(oRecHub:cTenant,50)
	cExtBusId   := PADR(oRecHub:cCodeComp,50)

Return oRecHub

//--------------------------------------------------------------------------
/*{Protheus.doc} Step2()
Construção do Painel 2

@param oPanel

@author Pedro Pereira Lima
@since 18/12/2017
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Step2(oPanel As Object, dIniApi As Date, dFimApi As Date)
	Local oSayDesc  As Object
	Local oSayDatDe As Object
	Local oDataDe   As Object
	Local oSayDatAt As Object
	Local oDataAte  As Object
	Local oFontA	As Object
	Local oFontB	As Object
	
	Default dIniApi   := DATE()
	Default dFimApi   := DATE()

	oFontA 		:= TFont():New( ,, -20, .T., .T.,,,,, )
	oFontB		:= TFont():New(,, -18, .T., .T.,,,,,)

	oSayDesc := TSay():New(035, 235, { || STR0024 }, oPanel,, oFontA,,,, .T., CLR_BLUE,)

	oSayDatDe := TSay():New(081,270,{|| STR0025},oPanel,, oFontB,,,,.T.,CLR_BLACK,)
	oDataDe   := TGet():New(080,340,bSetGet(dIniApi),oPanel,60,10,STR0026,,,,,,,.T.,,,,,,,,,,,,,,.T.)	
	oDataDe:bHelp := {|| ShowHelpCpo(STR0025, { STR0027 }, 2, {}, 1)}

	oSayDatAt := TSay():New(111,270,{|| STR0028},oPanel,, oFontB,,,,.T.,CLR_BLACK,)
	oDataAte  := TGet():New(110,340,bSetGet(dFimApi),oPanel,60,10,STR0026,{ || IIf(dFimApi >= dIniApi, .T., Help(NIL, NIL, STR0029, NIL, STR0030, 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0031 })) .And. dFimApi >= dIniApi },,,,,,.T.,,,,,,,,,,,,,,.T.)
	oDataAte:bHelp := {|| ShowHelpCpo(STR0028, { STR0032 }, 2, {}, 1)}

Return

//--------------------------------------------------------------------------
/*{Protheus.doc} Step3
Construção do Painel 3

@param oPanel

@author Pedro Pereira Lima
@since 19/12/2017
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Step3(oPanel As Object)
	Local nX As Numeric

	n1  := 1
	n2  := n1+1
	n3  := n2+1
	n4  := n3+1
	n5  := n4+1
	n6  := n5+1
	n7  := n6+1
	n8  := n7+1
	n9  := n8+1
	n10 := n9+1
	n11 := n10+1
	n12 := n11+1
	n13 := n12+1
	n14 := n13+1
	n15 := n14+1
	n16 := n15+1

	oBrowse := FWBrowse():New()
	oBrowse:SetOwner(oPanel)
	oBrowse:SetDataArray()
	oBrowse:SetArray(aLogFVR)

	oBrowse:AddLegend(STR0033 + STR0034, STR0035, STR0036) 
	oBrowse:AddLegend(STR0033 + STR0037, STR0038, STR0039) 
	oBrowse:AddLegend(STR0033 + STR0040, STR0041, STR0042) 
	oBrowse:AddLegend(STR0033 + STR0043, STR0044, STR0045) 
	oBrowse:AddLegend(STR0033 + STR0046, STR0047, STR0048) 
	oBrowse:AddLegend(STR0033 + STR0049, STR0050, STR0051) 
	oBrowse:AddLegend(STR0033 + STR0052, STR0053, STR0054) 
	oBrowse:AddLegend(STR0033 + STR0055, STR0056, STR0057) 
	oBrowse:AddLegend(STR0033 + STR0058, STR0059, STR0060) 

	For nX := 1 to Len(aHdrFVR)
		
		If nX <= n16 .And. !(Alltrim(aHdrFVR[nX][2]) $ "FVR_STATUS")
			oColBrwLog := FWBrwColumn():New()	
			oColBrwLog:SetSize(Len(Alltrim(aLogFVR[1][nX])))	
			&("oColBrwLog:SetData({|| aLogFVR[oBrowse:At(), n"+Alltrim(Str(nX))+" ]})")
			&("oColBrwLog:SetTitle((aHdrFVR[n"+Alltrim(Str(nX))+"][1]))")
			oBrowse:SetColumns({oColBrwLog})		
		EndIf
		
	Next nX

	oBrowse:Activate()

Return

//--------------------------------------------------------------------------
/*/{Protheus.doc} F914aAPI
Comunica com a API

@author Sidney Silva
@type  Static Function
@since 03/09/2021
@version 1.0
@return oResult, Json, retorna Json com os resultados	
/*/
//--------------------------------------------------------------------------
Static Function F914aAPI(dIniApi As Date, dFimApi As Date) As Object
	Local oRest			As Object
	Local cUrl			As Character
	Local cPath			As Character
	Local aHeader		As Array
	Local cToken		As Character
	Local cParams		As Character
	Local cExtBusId		As Character
	Local oRecHub 		As Object
	Local cHoraIni		As Character
	Local cHoraFim		As Character

	Default dIniApi := dDatabase
	Default dFimApi := dDatabase

	lRet        := .T.

	cPath       := ""
	aHeader     := {}
	oRecHub 	:= F914aComunic()
	cUrl        := oRecHub:GetURL()
	cToken      := oRecHub:GetToken()
	cParams     := ""
	cExtBusId	:= oRecHub:cCodeComp
	cResult     := ""
	cHttp       := ""
	cHoraIni	:= STR0061
	cHoraFim	:= STR0062

	oRest := FwRest():New(cUrl)

	Set(_SET_DATEFORMAT, "yyyy-mm-dd") 

	cPath += "?externalBusinessUnitId=" + Alltrim(cExtBusId)
	cPath += "&startDateMov=" + DToC((dIniApi - 5)) + cHoraIni
	cPath += "&endDateMov=" + DToC((dFimApi + 2)) + cHoraFim
	cPath += "&settled=true"

	oRest:SetPath(cPath)
	oRest:SetChkStatus(.F.)  

	aAdd(aHeader, "accept: application/json")	
	aAdd(aHeader, "Content-Type: application/json")    
	aAdd(aHeader, "charset: UTF-8")	
	aAdd(aHeader, "Authorization: Bearer " + cToken) 

	oRest:Get(aHeader)

	Set(_SET_DATEFORMAT, "dd/mm/yyyy") 
	FreeObj(oRecHub)

Return oRest

//--------------------------------------------------------------------------
/*{Protheus.doc} F914aApiImp()
Função que prepara a importação

@author Sidney Silva
@since 18/08/2021
@version 12.1.33
*/
//--------------------------------------------------------------------------
Static Function F914aApiImp(dIniApi As Date, dFimApi As Date, oJSONAuto) As Logical
	Local aArea  		As Array
	Local cNuComp  		As Character
	Local cSeqFIF		As Character
	Local cCodEst      	As Character
	Local cDtTef		As Character
	Local cOpType 		As Character
	Local cDtCred		As Character
	Local cMetodPag		As Character
	Local nVlLiq   		As Numeric
	Local nVlBrut 		As Numeric
	Local cIdTrans 		As Character
	Local cBancoDep		As Character
	Local cChavePIX		As Character
	Local cAgencia		As Character
	Local cConta		As Character
	Local nTxAdm		As Numeric
	Local cCodUser	 	As Character
	Local nQtdTran  	As Numeric
	Local nQtdValid  	As Numeric
	Local cIdFVRProc	As Character
	Local nAprovado		As Numeric
	Local nEstorno		As Numeric
	Local nReqRep		As Numeric
	Local nTotal		As Numeric
	Local cLinArq		As Character
	Local cHrProc		As Character
	Local dDtProc		As Date
	Local cMotFVR		As Character
	Local cMotFV3		As Character
	Local cNomOper		As Character
	Local cStatus		As Character
	Local cGrvFVR		As Character
	Local cSucess		As Character
	Local cBadReq 		As Character
	Local cUnauthori 	As Character
	Local cForbidden 	As Character
	Local cCodAut 		As Character
	Local oRest			As Object
	Local oTransacoes	As Object
	Local nX			As Numeric
	Local lProcesso		As Logical
	Local lGravaFV3		As Logical
	Local lRet			As Logical

	Default dIniApi := dDatabase
	Default dFimApi := dDatabase

	aArea  		:= GetArea() 	
	lRet		:= .T.
	cCodUser	:= RetCodUsr()
	dDtProc		:= dDatabase
	cHrProc		:= Time()
	cIdFVRProc	:= proxIdFVR()
	cSeqFIF 	:= proxIdFIF()
	cNomOper 	:= STR0063
	nQtdTran	:= 0	
	nQtdValid	:= 0	
	nAprovado	:= 0
	nEstorno	:= 0
	nReqRep		:= 0
	nTotal		:= 0
	cLinArq		:= "0"
	cCodEst		:= ""
	cNuComp		:= ""
	cCodAut		:= ""
	cIdTrans	:= ""
	cBancoDep	:= ""
	cAgencia 	:= ""
	cConta   	:= ""
	cGrvFVR		:= "1"
	cGrvFV3		:= "2"
	cBadReq		:= STR0064
	cUnauthori	:= STR0065
	cForbidden	:= STR0066
	cSucess		:= STR0067
	lProcess	:= .F.
	lGravaFV3	:= .F.

	IF __lAutomat
		cHttp := cSucess
	ELSE
		oRest := F914aAPI(dIniApi, dFimApi)
		cHttp := oRest:GetHTTPCode()
	ENDIF

	aHdrFVR := apBuildHeader(STR0070, { STR0071, STR0072, STR0073 }) // Guarda os campos da tabela de Log

	If !__lSchedul .And. !__lAutomat
	 	// Caso o Campo FVR_QTDALT não exista inclui manualmente para demosntrar apenas no wizard.
		IIf(!lQtdAlt,;
			aAdd(aHdrFVR, {"Linhas Editadas","FVR_QTDALT","@E 9,999,999,999,999,999                     ", 16, 0,;
			"                                                                                                                                ",;
			"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ",;
			"N","      "," "}), Nil)		
	EndIf

	DbSelectArea("FIF")	 
	// FIF_FILIAL + DTOS(FIF_DTCRED) + FIF_NUCOMP + FIF_PARCEL 
	FIF->(DbSetOrder(2))  

	If cHttp == cBadReq .Or. Empty(cHttp)	

		cMotFVR	:= STR0074
		cStatus	:= "7"

	ElseIf cHttp == cUnauthori .Or. cHttp == cForbidden

		cMotFVR	:= IIf(cHttp == cUnauthori, STR0075, STR0076)
		cStatus	:= "8"

	ElseIf cHttp == cSucess
		
		oTransacoes := F914aTrans(oRest, oJSONAuto)

		nQtdTran   	:= Len(oTransacoes)	
		cSeqArq		:= proxIdPIX()

		For nX := 1 To nQtdTran

			// cStatus: 1 = Pending, 2 = Approved, 3 = Cancelled, 4 = Expired, 5 = Refunded  
			cStatus	  := oTransacoes[nX]["status"]["id"]

			// cOpType : 1 = Sale, 2 = Cancellation, 3 = Settlement, 4 = Refund
			cOpType   := oTransacoes[nX]["operationType"]["id"]   

			lProcesso := oTransacoes[nX]["settled"]

			If (cOpType $ "1,4" .And. cStatus $ "2,5" .And. lProcesso)	

				nQtdValid += 1			

				cCodEst 	:=	oTransacoes[nX]["storeEin"] 
				cDtTef		:=	DToS(FwDateTimeToLocal(oTransacoes[nX]["operationDate"])[1])
				cDtCred		:=	DToS(FwDateTimeToLocal(oTransacoes[nX]["liquidationDate"])[1]) 
				cMetodPag 	:=	IIf(oTransacoes[nX]["paymentMethod"]["id"] == "1", "X", "D")
				nVlLiq      :=	oTransacoes[nX]["amount"]["deposited"]
				nVlBrut 	:=	oTransacoes[nX]["amount"]["transaction"]
				nTxAdm 		:=	((oTransacoes[nX]["amount"]["fee"] / oTransacoes[nX]["amount"]["transaction"]) * 100)
				cNuComp		:=	oTransacoes[nX]["externalTransactionId"]
				cCodAut		:=	oTransacoes[nX]["processorTransactionId"]
				cIdTrans    :=	IIf(oTransacoes[nX]["nsu"] == Nil, "", oTransacoes[nX]["nsu"])

				If oTransacoes[nX]["deposit"] <> Nil .And. oTransacoes[nX]["deposit"]:HasProperty("account") 
					cBancoDep 	:=	oTransacoes[nX]["deposit"]["account"]["bank"]["id"]
					cAgencia 	:=	oTransacoes[nX]["deposit"]["account"]["agency"]
					cConta   	:=	oTransacoes[nX]["deposit"]["account"]["number"]
				EndIf
				
				cChavePIX	:=	oTransacoes[nX]["pixDictKey"]

				If Empty(cBancoDep) .And. Empty(cAgencia) .And. Empty(cConta) 

					If Empty(cChavePIX)					
						cMotFV3		:= STR0081 + Alltrim(cNuComp)
						lGravaFV3	:= .T.
					Else
						
						aBanco := F914aBank(cChavePIX)

						If Empty(aBanco)
							cMotFV3		:= STR0077 + Alltrim(cNuComp)
							lGravaFV3	:= .T.							
						Else						
							cBancoDep	:= aBanco[1]
							cAgencia 	:= aBanco[2]
							cConta 		:= aBanco[3]
							lGravaFV3	:= .F.				
						EndIf
					EndIf
				EndIf

				If !lGravaFV3

					cOpType := IIf(cOpType == '1', '1', '3')

					If F914aExis(cDtCred, cNuComp, cOpType)

						cMotFV3		:= STR0078 + Alltrim(cNuComp)
						lGravaFV3	:= .T.					

					Else
						
						RecLock('FIF', .T.)			
						cSeqFIF := Soma1(Alltrim(cSeqFIF))	

						FIF->FIF_FILIAL	:= xFilial("FIF")
						FIF->FIF_TPREG	:= IIf(cStatus == '2', '1', '3')
						FIF->FIF_CODEST := cCodEst
						FIF->FIF_DTTEF  := SToD(cDtTef)
						FIF->FIF_NUCOMP := Alltrim(cNuComp)
						FIF->FIF_NSUTEF := Alltrim(cIdTrans)				
						FIF->FIF_VLBRUT := nVlBrut  
						FIF->FIF_VLLIQ	:= nVlLiq 
						FIF->FIF_DTCRED := SToD(cDtCred)
						FIF->FIF_TXSERV	:= nTxAdm
						FIF->FIF_DTIMP	:= dDtProc
						FIF->FIF_MSIMP	:= DtoS(dDtProc)
						FIF->FIF_CODFIL := cFilAnt                             
						FIF->FIF_SEQFIF	:= cSeqFIF
						FIF->FIF_ARQPAG := cSeqArq
						FIF->FIF_PARALF := ''
						FIF->FIF_PARCEL := ''
						FIF->FIF_TPPROD := cMetodPag
						FIF->FIF_MODPAG := '2'
						FIF->FIF_VLCOM	:= 0
						FIF->FIF_STATUS	:= '1'
						FIF->FIF_STVEND := '' 
						FIF->FIF_CODBCO := StrZero(Val(cBancoDep),TamSX3("FIF_CODBCO")[1])
						FIF->FIF_CODAGE := cAgencia
						FIF->FIF_NUMCC  := cConta
						FIF->FIF_INTRAN := ''
						FIF->FIF_CODLOJ := ''					 
						FIF->FIF_NURESU	:= ''
						FIF->FIF_NUCART := ''    
						FIF->FIF_TOTPAR := ''    
						FIF->FIF_CAPTUR := ''
						FIF->FIF_CODRED := ''					
						FIF->FIF_CODAUT := cCodAut
						FIF->FIF_CODBAN := ''
						FIF->FIF_CODADM := ''   
						FIF->FIF_ARQVEN := ''
						FIF->FIF_NSUARQ := ''   
						FIF->FIF_SEQREG := ''  					    
						IIf(cStatus == '2', nAprovado += 1, nEstorno += 1)
						nTotal += 1
						FIF->(MsUnlock())		
					EndIf
				EndIf

				If lGravaFV3									
					If !(F914ExFV3(cNuComp))

						cLinArq := Alltrim(Str(Val(cLinArq) + 1))

						F914GrvLog(cGrvFV3, cIdFVRProc, cLinArq, cSeqArq, dDtProc, cHrProc, cCodEst, cNuComp, cMotFV3, cNomOper, nTotal, 0, cStatus,,,,,cCodUser, nQtdValid, nQtdValid, 0)
					EndIf	

					nReqRep	+= 1
					lGravaFV3 := .F.	

				EndIf	
			EndIf			
		Next

		If nQtdValid == nReqRep .And. nQtdValid > 0

			cMotFVR	:= STR0039
			cStatus	:= "1"

		ElseIf nTotal == nQtdValid .And. nQtdValid > 0

			cMotFVR	:= STR0036
			cStatus	:= "0"		
		
		ElseIf nTotal < nQtdValid .And. nTotal > 0

			cMotFVR	:= STR0048
			cStatus	:= "4"	
		
		Else
		
			cMotFVR	:= STR0054
			cStatus	:= "6"	

		EndIf

	EndIf

	cSeqArq	:= proxIdPIX()

	F914GrvLog(cGrvFVR, cIdFVRProc, cLinArq, cSeqArq, dDtProc, cHrProc, cCodEst, cNuComp, cMotFVR, cNomOper, nTotal, 0, cStatus,,,,,cCodUser, nQtdValid, nQtdValid, 0)

	If !__lSchedul .And. !__lAutomat
		// Guarda Log temporário
		F914aLogFVR(FVR->(Recno()))
	EndIf

	FIF->(DbCloseArea())
	RestArea(aArea)

Return lRet

//--------------------------------------------------------------------------
/*{Protheus.doc} F914aTrans()
Função que popula o objeto de transações

@author Sidney Silva
@since 18/08/2021
@version 12.1.33
*/
//--------------------------------------------------------------------------
Static Function F914aTrans(oRest As Object, oJSONAuto) As Object
	Local cResult 	As Character
	Local oJson 	As Object

	Default oRest 	:= {}

	If __lAutomat
		oJson := oJSONAuto
	Else
		cResult := oRest:GetResult("transactions") 	

		oJson := JsonObject():New()
		oJson:FromJson(cResult)
	EndIf

Return oJson:GetJsonObject('transactions')

//--------------------------------------------------------------------------
/*/{Protheus.doc} proxIdFIF
Retorna próxima sequencia para a tabela FIF	

@author Sidney Silva
@type  Static Function
@since 03/09/2021
@version 1.0
@return cSeqFIF, character, retorna próxima sequencia para a tabela FIF	
/*/
//--------------------------------------------------------------------------
Static Function proxIdFIF() As Character
	Local aArea  		As Array
	Local aAreaFIF 		As Array
	Local cQryFIF		As Character
	Local cSeqFIF		As Character
	Local cTRBFIF		As Character

	aArea  		:= GetArea()
	cTRBFIF		:= GetNextAlias()
	cSeqFIF 	:= StrZero(0, 6)
	aAreaFIF 	:= FIF->(GetArea())

	cQryFIF := " SELECT MAX(FIF_SEQFIF) MAXFIF"
	cQryFIF += " FROM " + RetSqlName("FIF")
	cQryFIF += " WHERE D_E_L_E_T_ = ''"

	cQryFIF := ChangeQuery(cQryFIF)

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQryFIF), cTRBFIF)

	If (cTRBFIF)->(!Eof()) .And. !Empty((cTRBFIF)->(MAXFIF))
		cSeqFIF := (cTRBFIF)->(MAXFIF)
	EndIf

	(cTRBFIF)->(DbCloseArea())

	RestArea(aAreaFIF)
	RestArea(aArea)
	
Return cSeqFIF

//--------------------------------------------------------------------------
/*/{Protheus.doc} proxIdPIX
Retorna próxima sequencia para a tabela FIF	para PIX

@author Sidney Silva
@type  Static Function
@since 03/09/2021
@version 1.0
@return cSeqArq, character, retorna próxima sequencia para a tabela FIF	para PIX
/*/
//--------------------------------------------------------------------------
Static Function proxIdPIX() As Character
	Local aArea  		As Array
	Local aAreaFVR 		As Array
	Local cQryPIX		As Character
	Local cSeqArq		As Character
	Local cTRBPIX		As Character

	aArea  		:= GetArea()
	cTRBPIX		:= GetNextAlias()
	cSeqArq 	:= StrZero(1, 9)
	aAreaFVR 	:= FVR->(GetArea())

	DbSelectArea("FVR")
	cQryPIX := " SELECT MAX(FVR_NOMARQ) MAXPD"
	cQryPIX += " FROM " + RetSqlName("FVR")
	cQryPIX += " WHERE D_E_L_E_T_ = '' AND FVR_MODPAG = '2'"

	cQryPIX := ChangeQuery(cQryPIX)

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQryPIX), cTRBPIX)

	If (cTRBPIX)->(!Eof()) .And. !Empty((cTRBPIX)->(MAXPD))
		cSeqArq := Soma1(Alltrim((cTRBPIX)->(MAXPD)))
	EndIf

	(cTRBPIX)->(DbCloseArea())

	RestArea(aAreaFVR)
	RestArea(aArea)
	
Return cSeqArq

//--------------------------------------------------------------------------
/*/{Protheus.doc} proxIdFVR
Retorna próxima sequencia para a tabela FVR

@author Sidney Silva
@type  Static Function
@since 03/09/2021
@version 1.0	
@return cIdFVRProc, character, retorna próxima sequencia para a tabela FVR
/*/
//--------------------------------------------------------------------------
Static Function proxIdFVR() As Character
	Local aArea  		As Array
	Local aAreaFVR 		As Array
	Local cQryFVR		As Character
	Local cIdFVRProc	As Character
	Local cTRBFVR		As Character

	aArea  		:= GetArea()
	cTRBFVR		:= GetNextAlias()
	cIdFVRProc  := StrZero(1, 9)
	aAreaFVR 	:= FVR->(GetArea())

	cQryFVR := " SELECT MAX(FVR_IDPROC) MAXFVR"
	cQryFVR += " FROM " + RetSqlName("FVR")
	cQryFVR += " WHERE D_E_L_E_T_ = ''"

	cQryFVR := ChangeQuery(cQryFVR)

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQryFVR), cTRBFVR)

	If (cTRBFVR)->(!Eof()) .And. !Empty((cTRBFVR)->(MAXFVR))
		cIdFVRProc := Soma1(Alltrim((cTRBFVR)->(MAXFVR)))
	EndIf

	(cTRBFVR)->(DbCloseArea())

	RestArea(aAreaFVR)
	RestArea(aArea)
	
Return cIdFVRProc

//--------------------------------------------------------------------------
/*/{Protheus.doc} F914aBank
Retorna as informações de banco, agencia e conta de acordo com a chave PIX buscando aa tabela F70

@author Sidney Silva
@type  Static Function
@since 03/09/2021
@version 1.0	
@return aBanco, array, retorna um array com os dados de banco, agencia e conta
/*/
//--------------------------------------------------------------------------
Static Function F914aBank(cChavePIX As Character) As Array
	Local aArea  		As Array
	Local aAreaSA6 		As Array
	Local aAreaF70 		As Array
	Local cQry			As Character
	Local aBanco		As Array
	Local cTRBQRY		As Character

	Default cFilFIF 	:= ""
	Default cChavePIX 	:= ""

	aArea  		:= GetArea()
	cTRBQRY		:= GetNextAlias()
	aBanco		:= {}
	aAreaSA6 	:= SA6->(GetArea())
	aAreaF70 	:= F70->(GetArea())

	cQry := " SELECT SA6.A6_COD A6_COD, SA6.A6_AGENCIA A6_AGENCIA, SA6.A6_NUMCON A6_NUMCON "
	cQry += " FROM " + RetSqlName("SA6") + " SA6"
	cQry += " 	INNER JOIN " + RetSqlName("F70") + " F70 ON SA6.A6_COD = F70.F70_COD"
	cQry += " 		AND SA6.A6_AGENCIA = F70.F70_AGENCI"
	cQry += " 		AND SA6.A6_NUMCON = F70.F70_NUMCON"
	cQry += " 		AND SA6.A6_FILIAL = F70.F70_FILIAL"
	cQry += " 		AND F70.D_E_L_E_T_ = ''"
	cQry += " WHERE SA6.D_E_L_E_T_ = ''"
	cQry += " 	AND SA6.A6_FILIAL = '" + xFilial("SA6") + "'" 
	cQry += " 	AND F70.F70_FILIAL = '" + xFilial("F70") + "'"
	cQry += " 	AND F70.F70_CHVPIX = '" + Alltrim(cChavePIX) + "'"

	cQry := ChangeQuery(cQry)

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), cTRBQRY)

	If (cTRBQRY)->(!Eof())
		aAdd(aBanco, (cTRBQRY)->(A6_COD))
		aAdd(aBanco, (cTRBQRY)->(A6_AGENCIA))
		aAdd(aBanco, (cTRBQRY)->(A6_NUMCON))	
	EndIf

	(cTRBQRY)->(DbCloseArea())

	RestArea(aAreaSA6)
	RestArea(aAreaF70)
	RestArea(aArea)

Return aBanco

//--------------------------------------------------------------------------
/*{Protheus.doc} F914aLogFVR
Guarda o log em array para exibir registros efetuados na transação

@author Marcelo Ferreira
@since 05/06/2018
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function F914aLogFVR(nReg as Numeric, nQtdAlt as Numeric)
	Local nY 	As Numeric
	Local nZ 	As Numeric
	Local aArea As Array
	Local aAux  As Array

	Default nReg 	:= 0
	Default nQtdAlt := 0

	aArea	:= GetArea()
	aAux  	:= {}
	nZ      := 0

	FVR->(dbGoTo(nReg))
	For nY := 1 to Len(aHdrFVR)
		If !lQtdAlt .And. aHdrFVR[nY][2] == 'FVR_QTDALT'
			aAdd(aAux, nQtdAlt)
		Else
			aAdd(aAux, FVR->&(aHdrFVR[nY][2]))
		EndIf
	Next nY

	AAdd(aLogFVR, aClone(aAux))

	RestArea(aArea)

Return

/*{Protheus.doc} F914aExis
	Verifica se já existe o registro na base

	@author Sidney Santos
	@since 22/11/2021
	@version 12.1.33
*/
Static Function F914aExis(cDtCred As Character, cNuComp As Character, cOpType As Character) As Logical
	Local lRet   As Logical
	Local cQuery As Character
	
	Default cDtCred := ""
	Default cNuComp := ""
	Default cOpType := ""
	
	//Inicializa variáveis
	cQuery     := ""
	lRet	   := .F.
	
	If __oRegiFIF == Nil
		cQuery := "SELECT FIF.R_E_C_N_O_ NREGFIF " 
		cQuery += "FROM ? FIF WHERE "		
		cQuery += "FIF.FIF_DTCRED = ? "
		cQuery += "AND FIF.FIF_NUCOMP = ? "
		cQuery += "AND FIF.FIF_TPREG = ? "
		cQuery += "AND FIF.D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)
		__oRegiFIF := FWPreparedStatement():New(cQuery)		
	EndIf
	
	__oRegiFIF:SetNumeric(1, RetSqlName("FIF"))
	__oRegiFIF:SetString(2, cDtCred)
	__oRegiFIF:SetString(3, cNuComp)
	__oRegiFIF:SetString(4, cOpType)
	cQuery := __oRegiFIF:GetFixQuery()
	
	lRet := (MpSysExecScalar(cQuery, "NREGFIF") > 0)
Return lRet

/*{Protheus.doc} F914ExFV3
	Verifica se já existe o registro na tabela FV3
	
	@author sidney.silva
	@since 18/03/2022
	@version 12.1.33
*/
Static Function F914ExFV3(cNuComp As Character) As Logical
	Local lRet   As Logical
	Local cQuery As Character
	
	Default cNuComp := ""
	
	//Inicializa variáveis
	lRet   := .F.
	cQuery := ""
	
	If __oRegiFV3 == Nil 
		cQuery := "SELECT FV3.R_E_C_N_O_ NREGFV3 "
		cQuery += "FROM ? FV3 WHERE "
		cQuery += "FV3.FV3_NUCOMP = ? "
		cQuery += "AND FV3.D_E_L_E_T_ = ' ' "
        cQuery := ChangeQuery(cQuery)
		__oRegiFV3 := FWPreparedStatement():New(cQuery)		
	EndIf
	
	__oRegiFV3:SetNumeric(1, RetSqlName("FV3"))
	__oRegiFV3:SetString(2, cNuComp)
	cQuery := __oRegiFV3:GetFixQuery()	
	lRet   := (MpSysExecScalar(cQuery, "NREGFV3") > 0)
Return lRet

/*/{Protheus.doc} VldStep2
	Função para validar se a data está preenchida
	@type  Function
	@author sidney.santos
	@since 18/05/2022
	@param dDtIniImp, Date, data inicial da importação na API
	@param dDtFimImp, Date, data final da importação na API
	@return lRet, Logical, retorno da função para ativar o botão de avançar
	/*/
Function VldStep2(dDtIniImp As Date, dDtFimImp As Date)
	Local lRet As Logical

	Default dDtIniImp := CToD(' / / ')
	Default dDtFimImp := CToD(' / / ')

	lRet := .T.

	If(Empty(dDtIniImp) .And. Empty(dDtFimImp))
		Help(" ", 1, STR0029,, STR0082, 1, 0,,,,,, { STR0083 })
		lRet := .F.
	Else 
		Processa({ ||F914aApiImp(dDtIniImp, dDtFimImp) })
	EndIf

Return lRet
