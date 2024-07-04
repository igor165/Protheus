#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWEVENTVIEWCONSTS.CH" 
#INCLUDE 'FINA887.CH'

/*/{Protheus.doc} F887CTB
Clase responsable por el evento de reglas de negocio de 
localización padrón para contabilidad

@type 		Class
@author 	raul.medina
@version	12.1.27 / Superior
@since		30/04/2021
/*/
Class F887CTB From FwModelEvent 
	
	DATA lDigita As logical
    
    DATA lAglutina As logical
	
	DATA lGeraLanc As logical

	Method New() CONSTRUCTOR
	
	Method VldActivate()

	Method Destroy()
	
	Method BeforeTTS()
	
	Method InTTS()
	
	Method AfterTTS()
	
	Method F887CONT()
	
	Method F887CONTCA()
	
EndClass

/*/{Protheus.doc} New
Metodo responsable de la contrucción de la clase.

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		30/04/2021 
/*/
Method New() Class F887CTB
	
Return Nil	

/*/{Protheus.doc} VldActivate
Metodo responsable de las validaciones al activar el modelo

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		30/04/2021 
/*/
Method VldActivate(oModel) Class F887CTB
Local nOperation	:= oModel:GetOperation()
Local lRet			:= .T.
	
	self:lDigita  	:= .F.  // Muestra Asientos.
	self:lAglutina	:= .F.  // Agrupa Asientos.
	self:lGeraLanc	:= .F.  // Asientos on-line.

Return lRet

/*/{Protheus.doc} Destroy
Metodo responsable de destruir el objeto

@type 		Method
@author 	raul.medina
@version	12.1.27 / Superior
@since		30/04/2021 
/*/
Method Destroy() Class F887CTB

Return Nil

/*/{Protheus.doc} BeforeTTS
Metodo responsabe por ejecutar reglas de negocio genericas antes de la transacción
del modelo de datos.

@type 		Method

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	raul.medina	
@version	12.2.27 / Superior
@since		03/05/2021 
/*/
Method BeforeTTS(oModel, cModelId) Class F887CTB
Local nOperation	:= oModel:GetOperation()

Return Nil

/*/{Protheus.doc} InTTS
Metodo responsable por ejecutar reglas de negocio genericas 
dentro de la transacción del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		03/05/2021 
/*/
Method InTTS(oModel, cModelId) Class F887CTB
Local nOperation	:= oModel:GetOperation()
	

Return Nil


/*/{Protheus.doc} AfterTTS
Metodo responsable por ejecutar reglas de negocio genericas 
después de la transacción del modelo de datos.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados de Clientes.
@param 		cModelId ,caracter	,Identificador do sub-modelo.

@author 	raul.medina
@version	12.1.27 / Superior
@since		30/04/2021 
/*/
Method AfterTTS(oModel, cModelId) Class F887CTB
Local nOperation	:= oModel:GetOperation()
Local oModelFJT 	:= oModel:GetModel('FJT_MASTER')
	
	If nOperation == MODEL_OPERATION_INSERT
		self:lDigita  	:= oModelFJT:GetValue("ASIENTO") == 1 // Muestra Asientos. 
		self:lAglutina	:= oModelFJT:GetValue("AGRUPA") == 1  // Agrupa Asientos. 
		self:lGeraLanc	:= oModelFJT:GetValue("ONLINE") == 1  // Asientos on-line. 
		self:F887CONT(oModel)
	EndIf 

Return Nil


/*/{Protheus.doc} F887CONT
Metodo responsable por realizar la contabilidad.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados.

@author 	raul.medina
@version	12.1.27 / Superior
@since		30/04/2021 
/*/
Method F887CONT(oModel) Class F887CTB
Local nHdlPrv		:= 0
Local cKeyImp 		:= ""
Local cAlias		:= ""
Local lAchou		:= .F.       
Local aFlagCTB 		:= {}
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 
Local nXE5 			:= 0
Local cPadrao 		:= ""
Local cLoteCom 		:= ""
Local cArquivo 		:= ""
Local lLanctOk		:= .F.
Local cSerie		:= ""
Local cRecibo		:= ""
Local aDiario		:= {}
Local nLinha		:= 0
Local nTotalLanc	:= 0 
Default cDiario	:= ""
	
	nTotalLanc		:= 0
	cArquivo		:= ""
	nLinha 			:= 1
	
	If self:lGeraLanc
		cSerie	:=	oModel:GetValue("FJT_MASTER","FJT_SERIE")
		cRecibo	:=	oModel:GetValue("FJT_MASTER","FJT_RECIBO")
		//+--------------------------------------------------------------+
		//¦ Posiciona numero do Lote para Lancamentos do Financeiro      ¦
		//+--------------------------------------------------------------+
		dbSelectArea("SX5")
		MsSeek(xFilial()+"09FIN")
		cLoteCom:=IIF(Found(),AllTrim(X5DESCRI()),"FIN")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa Lancamento Contabil                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nHdlPrv := HeadProva( cLoteCom,;
		"FINA887" /*cPrograma*/,;
		Substr( cUsuario, 7, 6 ),;
		@cArquivo )

		If nHdlPrv <= 0
			Help(" ",1,"A100NOPROV")
		EndIf
	Else 
		Return
	
	EndIf
	
	If nHdlPrv > 0 .and. self:lGeraLanc
		//+--------------------------------------------------+
		//¦ Gera Lancamento Contab. para RECIBO.             ¦
		//+--------------------------------------------------+
		If self:lGeraLanc
			IF ExistBlock("F998NRG1")
				ExecBlock('F998NRG1',.F.,.F.)	
			ENDIF
			SEL->(DbSetOrder(8))
			SEL->(DbGotop())
			SEL->(MsSeek(xFilial("SEL")+cSerie+cRecibo,.F.))
			Do while !SEL->(EOF()) .And. SEL->EL_SERIE == cSerie .And. SEL->EL_RECIBO == cRecibo

				Do Case 
					Case SEL->EL_TIPODOC == "TB" .And. SEL->EL_TIPO $ MV_CRNEG+"/"+ MVRECANT .And. VerPadrao("5BN")
					lLancPad70 := .T. 
					cPadrao := "5BN" 
					Case SEL->EL_TIPODOC == "TB" .And. !(SEL->EL_TIPO $ MV_CRNEG+"/"+MVRECANT) .And. VerPadrao("5BO")
					lLancPad70 := .T.
					cPadrao := "5BO"			
					Case SEL->EL_TIPODOC == "RA" .And. VerPadrao("5BP")
					lLancPad70 := .T. 
					cPadrao := "5BP"
					Case SEL->EL_TIPODOC == "CH" .And. VerPadrao("5BQ")
					lLancPad70 := .T.  
					cPadrao := "5BQ"
					Case SEL->EL_TIPODOC == "DC" .And. VerPadrao("5BR")
					lLancPad70 := .T.
					cPadrao := "5BR"
					Case SEL->EL_TIPODOC == "EF" .And. VerPadrao("5BS")
					lLancPad70 := .T. 
					cPadrao := "5BS"
					Case SEL->EL_TIPODOC == "TF" .And. VerPadrao("5BT")
					lLancPad70 := .T.
					cPadrao := "5BT"
					Case SEL->EL_TIPODOC $ "RS/RL/RB/RI/RG/RR" .And. VerPadrao("5BU")
					lLancPad70 := .T.
					cPadrao := "5BU"
					Otherwise
					lLancPad70 := VerPadrao("575")
					cPadrao := "575"   
				EndCase			
				If lLancPad70
					SA6->(DbsetOrder(1))
					SA6->(MsSeek(xFilial("SA6")+SEL->EL_BANCO+SEL->EL_AGENCIA+SEL->EL_CONTA,.F.))

					SE1->(DbsetOrder(2))
					SE1->(MsSeek(xFilial("SE1")+SEL->EL_CLIORIG+SEL->EL_LOJORIG+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO,.F.))

					Do Case
						Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NCC")) )
						cAlias := "SF1"
						Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NDE")) )
						cAlias := "SF1"         
						Otherwise
						cAlias := "SF2"    
					EndCase
					cKeyImp := 	xFilial(cAlias)	+;
					SE1->E1_NUM		+;
					SE1->E1_PREFIXO	+;
					SE1->E1_CLIENTE	+;
					SE1->E1_LOJA			
					If ( cAlias == "SF1" )
						cKeyImp += SE1->E1_TIPO   
					Endif
					Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")
					lAchou:=.F.

					SE5->(DbSetOrder(2))
					//Nos casos de baixas parciais pelo recibo gera registros com a mesma chave.
					//A diferenca estah no campo E5_ORDREC(numero do recibo)		
					If SE5->(MsSeek(xFilial("SE5")+"BA"+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO))
						While xFilial("SE5") == SE5->E5_FILIAL .And. SEL->EL_PREFIXO == SE5->E5_PREFIXO .And.;
						SEL->EL_NUMERO == SE5->E5_NUMERO .And. SEL->EL_PARCELA == SE5->E5_PARCELA .And.;
						SEL->EL_TIPO == SE5->E5_TIPO .And. SE5->E5_TIPODOC == "BA" .And.!SE5->(Eof()) .And. !lAchou
							If (SE5->E5_ORDREC == cRecibo .And. SE5->E5_SERREC == cSerie )
								lAchou:=.T.
							Else
								SE5->(DbSkip())			
							EndIf

						EndDo
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Prepara Lancamento Contabil                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
						aAdd( aFlagCTB, {"EL_LA", "S", "SEL", SEL->( Recno() ), 0, 0, 0} )
					Endif
					nTotalLanc := nTotalLanc + DetProva( nHdlPrv,;
					cPadrao,;
					"FINA887" /*cPrograma*/,;
					cLoteCom,;
					@nLinha,;
					/*lExecuta*/,;
					/*cCriterio*/,;
					/*lRateio*/,;
					/*cChaveBusca*/,;
					/*aCT5*/,;
					/*lPosiciona*/,;
					@aFlagCTB,;
					/*aTabRecOri*/,;
					/*aDadosProva*/ )


					If UsaSeqCor()
						AAdd(aDiario,{"SEL",SEL->(Recno()),cDiario,"EL_NODIA","EL_DIACTB"})
					EndIf
				Endif	

				SEL->(DbSkip())
			EndDo
			
		Endif

		//+-----------------------------------------------------+
		//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
		//+-----------------------------------------------------+
		SEL->(DbSetOrder (8))
		SEL->(MsSeek(xFilial("SEL")+cSerie+cRecibo))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetiva Lan‡amento Contabil                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RodaProva(	nHdlPrv,; 
		nTotalLanc )

		lLanctOk := cA100Incl(	cArquivo,;
		nHdlPrv,;
		3 /*nOpcx*/,;
		cLoteCom,;
		self:lDigita,;
		self:lAglutina,;
		/*cOnLine*/,;
		/*dData*/,;
		/*dReproc*/,;
		@aFlagCTB,;
		/*aDadosProva*/,;
		aDiario )
		aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento


		If lLanctOk
			SEL->(DbSetOrder (8))
			If SEL->(MsSeek(xFilial("SEL")+cSerie+cRecibo))
				Do while SEL->EL_SERIE == cSerie .And. SEL->EL_RECIBO == cRecibo
					RecLock("SEL",.F.)
					Replace EL_LA With "S"
					MsUnLock()
					SEL->(DbSkip())
				Enddo
			EndIf
		Endif
	EndIf
	
Return Nil


/*/{Protheus.doc} F887CONT
Metodo responsable por realizar la contabilidad.

@type 		Method

@param 		oModel	 ,objeto	,Modelo de dados.

@author 	raul.medina
@version	12.1.27 / Superior
@since		03/05/2021 
/*/
Method F887CONTCA(oModel) Class F887CTB
Local nHdlPrv		:= 0
Local cKeyImp 		:= ""
Local cAlias		:= ""
Local lAchou		:= .F.       
Local aFlagCTB 		:= {}
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 
Local nXE5 			:= 0
Local cPadrao 		:= ""
Local cLoteCom 		:= ""
Local cArquivo 		:= ""
Local lLanctOk		:= .F.
Local cSerie		:= ""
Local cRecibo		:= ""
Local aDiario		:= {}
Local nLinha		:= 2
Local cPadrao		:= "576"
Local nTotalLanc	:= 0	

	cPadrao := "576"
	lLancPad := VerPadrao(cPadrao)
	
	If lLancPad
		cSerie	:=	FJT->FJT_SERIE
		cRecibo	:=	FJT->FJT_RECIBO
		
		//+--------------------------------------------------------------+
		//¦ Posiciona numero do Lote para Lancamentos do Financeiro      ¦
		//+--------------------------------------------------------------+
		dbSelectArea("SX5")
		MsSeek(xFilial()+"09FIN")
		cLoteCom:=IIF(Found(),Trim(X5_DESCRI),"FIN")
		nHdlPrv := HeadProva( cLoteCom,;
		                      "FINA887",;
		                      Substr( cUsuario, 7, 6 ),;
		                      @cArquivo )
	
		If nHdlPrv <= 0
			Help(" ",1,"A100NOPROV")
		EndIf
	EndIf

	If nHdlPrv > 0 
		SEL->(DbSetOrder(8))
		SEL->(MsSeek(xFilial("SEL")+cSerie+cRecibo,.F.))
		Do while !SEL->(EOF()) .And. SEL->EL_RECIBO == cRecibo .And. SEL->EL_SERIE == cSerie
			If UsaSeqCor()
				aDiario := {{"SEL",SEL->(recno()),cCodDiario,"EL_NODIA","EL_DIACTB"}}
			endif
		
			SA6->(DbsetOrder(1))
			SA6->(DbSeek(xFilial("SA6")+SEL->EL_BANCO+SEL->EL_AGENCIA+SEL->EL_CONTA,.F.))
			SE1->(DbsetOrder(2))
			SE1->(DbSeek(xFilial("SE1")+SEL->EL_CLIORIG+SEL->EL_LOJORIG+SEL->EL_PREFIXO+SEL->EL_NUMERO+SEL->EL_PARCELA+SEL->EL_TIPO,.F.))
			If SEL->EL_LA=="S"
				Do Case
					Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NCC")) )
						cAlias := "SF1"
					Case ( Alltrim(SEL->EL_TIPO) == Alltrim(GetSESnew("NDE")) )
						cAlias := "SF1"         
					Otherwise
						cAlias := "SF2"    
				EndCase
				cKeyImp := 	xFilial(cAlias)	+;
							SE1->E1_NUM		+;
							SE1->E1_PREFIXO	+;
							SE1->E1_CLIENTE	+;
							SE1->E1_LOJA			
				If ( cAlias == "SF1" )
					cKeyImp += SE1->E1_TIPO
				Endif
				Posicione(cAlias,1,cKeyImp,"F"+SubStr(cAlias,3,1)+"_VALIMP1")
				If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
					aAdd( aFlagCTB, {"EL_LA", "C", "SEL", SEL->( Recno() ), 0, 0, 0} )
				Else
					RecLock("SEL",.F.)
					Replace EL_LA With "C"
					MsUnLock()
				Endif

				nTotalLanc := nTotalLanc + DetProva( 	nHdlPrv,;
									                    "576",;
								                    "FINA887",;
								                    cLoteCom,;
								                    nLinha,;
								                    /*lExecuta*/,;
								                    /*cCriterio*/,;
								                    /*lRateio*/,;
								                    /*cChaveBusca*/,;
								                    /*aCT5*/,;
								                    /*lPosiciona*/,;
								                    @aFlagCTB,;
								                    /*aTabRecOri*/,;
								                    /*aDadosProva*/ )
			Endif
			SEL->(DbSkip())
		EndDo
		
		//+-----------------------------------------------------+
		//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
		//+-----------------------------------------------------+
		RodaProva(  nHdlPrv,;
					nTotalLanc)
			//+-----------------------------------------------------+
			//¦ Envia para Lancamento Contabil, se gerado arquivo   ¦
			//+-----------------------------------------------------+
		lLanctOk := cA100Incl( cArquivo,;
					           nHdlPrv,;
					           3,;
					           cLoteCom,;
					           self:lDigita,;
					           self:lAglutina,;
					           /*cOnLine*/,;
					           /*dData*/,;
					           /*dReproc*/,;
					           @aFlagCTB,;
					           /*aDadosProva*/,;
					           aDiario )
		aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

		If !lLanctOk
			SEL->(DbSeek(xFilial("SEL")+cSerie+cRecibo))
			Do while cRecibo == SEL->EL_RECIBO .AND. cSerie == SEL->EL_SERIE .AND. SEL->(!EOF())
				RecLock("SEL",.F.)
           		Replace SEL->EL_LA With "S"
				MsUnLock()
				SEL->(DbSkip())
			Enddo
		EndIf
	Endif

Return Nil
