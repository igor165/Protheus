#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RSKDefs.ch"    
#INCLUDE "RSKA030.CH"

Static cErrorMsg := ""  
  
//-------------------------------------
/*/{Protheus.doc}  RSKDesdobr
Baixa titulos do cliente e gera titulos em nome da supplier

@param 		aDocumentos: 	Array de documentos com a seguinte estrutura
							aDocumentos[x][1]: Filial do documento
							aDocumentos[x][2]: Numero do documento
							aDocumentos[x][3]: id
							aDocumentos[x][4]: Codigo do Retorno
							aDocumentos[x][5]: Mensagem do Retorno
							aDocumentos[x][6]: Codigo da transacao
							aDocumentos[x][7]: Boleto em base64
							aDocumentos[x][8]: Valor total de taxas
							aDocumentos[x][9]: Valor total das parcelas
							aDocumentos[x][10]: Data de pagamento
							aDocumentos[x][11][y],[1]: Numero da parcela 
							aDocumentos[x][11][y],[2]: Data de vencimento da parcela
							aDocumentos[x][11][y],[3]: Valor da parcela
							aDocumentos[x][11][y],[4]: Valor de recebimento parceiro
							aDocumentos[x][11][y],[5]: Data de recebimento parceiro
							aDocumentos[x][11][y],[6]: Id tipo de taxa
							aDocumentos[x][11][y],[7]: Tipo de taxa Parcela
							aDocumentos[x][11][y],[8]: Valor da taxa Parcela
							aDocumentos[x][11][y],[9]: Valor da taxa da parcela em reais
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return 	Logico, Informa se os titulos foram baixados
@author 	jose.delmondes
@since  	25/05/2020 
@version	P12
/*/
//-------------------------------------
Function RSKDesdobr( aDocumentos, lAutomato ) 
	Local aArea			:= GetArea() 
	Local aTitulos		:= {}
	Local aItem 		:= {}
	Local lContinue 	:= .T.
	Local nX 			:= 0
	Local nY 			:= 0
	Local nTaxas		:= 0  
	Local nValTit		:= 0
	Local cFilDoc		:= ""
	Local cDoc 			:= ""  
	Local cCodRet		:= ""
	Local cMsgRet		:= ""
	Local cNFStatus		:= ""
	Local cCmdInv		:= ""
	Local cIdTransP		:= ""
	Local cBoleto		:= ""
	Local dDataVenc		:= cTod("//")
	Local oModel		:= Nil  
	Local oMdlAR1		:= Nil 
	Local aErrorMd		:= {}
	Local cTimeBaix		:= "" 
	Local cTimeDesb		:= ""
	Local cFilSE2 		:= xFilial( "SE2" )
	Local cNumSE2		:= ""
	Local cParcDef		:= "" //Caso haja mais de uma parcela utilizar o parametro MV_1DUP
	Local cHist			:= ""
	Local cIdNatInc		:= RskSeekNature( INCOME_NATURE )		// 1=Receita            
	Local cIdNatExp		:= RskSeekNature( EXPENSE_NATURE )		// 2=Despesa
	Local lUnfolding  	:= SuperGetMv( "MV_RSKDESD", , .T. )    
	Local nRecSE1Ori    := 0
	Local nQtdVend  	:= fa440CntVen()
	Local nQtdParcelas	:= 0
	Local cSE1Enum	    := ""
	Local cParDef 		:= ""
	Local cDefaultParc  := SuperGetMv("MV_1DUP",.F.,"1")

	Default lAutomato := .F.

	DBSelectArea( 'AR1' )
	DBSetOrder(1)	//AR1_FILIAL+AR1_COD

	For nX:= 1 To Len( aDocumentos )
		lContinue 	:= .T.
		cNFStatus	:= " "
		cErrorMsg 	:= " "
		nRecSE1Ori  := 0
		cFilDoc		:= aDocumentos[nX][ UPD_I_BRANCH ]		// [1]-filial
		cDoc 		:= aDocumentos[nX][ UPD_I_INVOICE ]		// [2]-numero do documento
		cCmdInv		:= aDocumentos[nX][ UPD_I_INVOICEID ]	// [3]-id da fatura  
		cCodRet		:= aDocumentos[nX][ UPD_I_RETURN ]		// [4]-codigo do retorno  
		cMsgRet		:= aDocumentos[nX][ UPD_I_MESSAGE ]		// [5]-mensagem do retorno
		cIdTransP	:= aDocumentos[nX][ UPD_I_TRANSACTION ]	// [6]-codigo da transação  

		aTitulos := {}

		If AR1->( DBSeek( xFilial( 'AR1' ) + cDoc ) ) .And. AR1->AR1_STATUS != AR1_STT_APPROVED		// 2=Aprovada
			If cCodRet == "000"                                                                        
			
				BEGIN TRANSACTION
					cBoleto   := aDocumentos[nX][ UPD_I_BANKSLIP ]				// [7]-boleto em base64  
					nTaxas 	  := aDocumentos[nX][ UPD_I_TOTAL_FEE ]				// [8]-valor total das taxas  
					nValTit	  := aDocumentos[nX][ UPD_I_TOTAL_PARC ] + nTaxas	// [9]-valor total das parcelas 
					dDataVenc := SToD( aDocumentos[nX][ UPD_I_RECEIPT_DT ] )	// [10]-data recebimento parceiro 
					cTimeDesb := Time()
					cHist	  := "Mais Neg. NFS: " + alltrim(AR1->AR1_DOC) + " / " + alltrim(AR1->AR1_SERIE)      

					cTimeBaix := Time() 
					
					If lUnfolding 
						lContinue := RSKBaixa( AR1->AR1_FILNF, AR1->AR1_PREFIX, AR1->AR1_DOC, 'NF', AR1->AR1_COD , @nRecSE1Ori, AR1->AR1_CONDPG  )
					EndIf

					If lContinue .And. lUnfolding
						cSE1Enum := ProxTitulo( "SE1", "OFF" )

						If aDocumentos[nX][UPD_I_ISSUERTYPE] == '2' // [13]-tipo de recibo do emissor
						  	cParDef	 	 := cDefaultParc
							nQtdParcelas := Len( aDocumentos[nX][ UPD_I_PARCELS ] )

							For nY := 01 To nQtdParcelas
								dDataVenc := SToD(aDocumentos[nX][UPD_I_PARCELS][nY][PARCEL_AMOUNTDT]) // [5]-Data de recebimento parceiro
								nValTit	  := aDocumentos[nX][UPD_I_PARCELS][nY][PARCEL_RECAMOUNT] + aDocumentos[nX][UPD_I_PARCELS][nY][PARCEL_RSVALUE] // [4]-Valor de recebimento parceiro + [9]-Valor da taxa da parcela em reais
								aItem     := RSKPrinc( AR1->AR1_FILNF, AR1->AR1_PREFIX, AR1->AR1_DOC, 'NF', nValTit, dDataVenc, cHist, cIdNatInc, nRecSE1Ori, nQtdVend, cSE1Enum, cParDef )
								If Len( aItem ) > 0
									aAdd( aTitulos, aItem )   
								Else 
									lContinue := .F.
									nY 		  := nQtdParcelas
								EndIf
								cParDef	:= MAParcela(cParDef)
							Next

						Else
							aItem := RSKPrinc( AR1->AR1_FILNF, AR1->AR1_PREFIX, AR1->AR1_DOC, 'NF', nValTit, dDataVenc, cHist, cIdNatInc, nRecSE1Ori, nQtdVend, cSE1Enum, cParDef )
							If Len( aItem ) > 0
								aAdd( aTitulos, aItem )   
							Else 
								lContinue := .F. 
							EndIf
						EndIf
					EndIf

					If lContinue .And. lUnfolding .And. nTaxas > 0
						cNumSE2 := ProxTitulo( "SE2", "OFF" )
						
						If aDocumentos[nX][UPD_I_ISSUERTYPE] == '2' // [13]-tipo de recibo do emissor
							cParcDef	 := cDefaultParc
							nQtdParcelas := Len( aDocumentos[nX][ UPD_I_PARCELS ] )

							For nY := 01 To nQtdParcelas
								dDataVenc := SToD(aDocumentos[nX][UPD_I_PARCELS][nY][PARCEL_AMOUNTDT]) // [5]-Data de recebimento parceiro
								nTaxas	  := aDocumentos[nX][UPD_I_PARCELS][nY][PARCEL_RSVALUE] 	   // [9]-Valor da taxa da parcela em reais
								aItem	  := RSKTaxa( cFilSE2, "OFF", cNumSE2, cParcDef, "MN+", nTaxas, dDataVenc, cHist, cIdNatExp )    
								If Len( aItem ) > 0
									aAdd( aTitulos, aItem )   
								Else 
									lContinue := .F.
									nY 		  := nQtdParcelas
								EndIf
								cParcDef := MAParcela(cParcDef)
							Next

						Else						
							aItem	:= RSKTaxa( cFilSE2, "OFF", cNumSE2, cParcDef, "MN+", nTaxas, dDataVenc, cHist, cIdNatExp )    
							If Len( aItem ) > 0
								aAdd( aTitulos, aItem )    
							Else 
								lContinue := .F.
							EndIf 
						EndIf
					EndIf
					
					If lContinue
						lContinue := RskNFSMovFin( aDocumentos[nX] , aTitulos )
					EndIf
					
					If lContinue
						lContinue := RSKGrvBol( cBoleto, AR1->AR1_COD )
					EndIf

					If lContinue
						cNFStatus	:= AR1_STT_APPROVED		// 2=Aprovado  
					Else
						DisarmTransaction()  
						cNFStatus	:= AR1_STT_FLIMSY 	// 5=Inconsistencia no processamento do Erp.
					EndIf

				END TRANSACTION
			Else
				cNFStatus := AR1_STT_REJECTED	// 3=Rejeitada
			EndIf
		
			oModel := FwLoadModel( "RSKA020" ) 
			oModel:SetOperation( MODEL_OPERATION_UPDATE )
			oModel:Activate()   

			If oModel:IsActive() 
				oMdlAR1 := oModel:GetModel( "AR1MASTER" )  
				
				oMdlAR1:SetValue( "AR1_STATUS", cNFStatus )   
				oMdlAR1:SetValue( "AR1_TCKTRA", cIdTransP ) 
				oMdlAR1:SetValue( "AR1_CMDINV", cCmdInv )
				
				If cNFStatus != "5"
					oMdlAR1:SetValue( "AR1_STARSK", STARSK_RECEIVED )  // 3=Recebido
					oMdlAR1:SetValue( "AR1_OBSPAR", cMsgRet )
				Else
					oMdlAR1:SetValue( "AR1_OBSPAR" , STR0001 + Chr(10) + cErrorMsg + Chr(10) + STR0002 )	//"Não foi possível realizar as movimentações financeiras para este documento de saída."###"***** Será realizado uma nova tentativa *****"
				EndIf
				
				oMdlAR1:SetValue( "AR1_DTAVAL" , FWTimeStamp( 1, Date(), Time() ) )
				
				If oModel:VldData()
					oModel:CommitData() 
				Else
					aErrorMd := oModel:GetErrorMessage()
					LogMsg( "RSKDesdobr", 23, 6, 1,"", "", "RSKDesdobr -> " + aErrorMd[6] )
				EndIf  
			EndIf    			
		EndIf
	Next nX

	RestArea( aArea )

	FWFreeArray( aArea )
	FWFreeArray( aTitulos )
	FWFreeArray( aItem )
	FWFreeArray( aErrorMd )
	FreeObj( oModel )
	FreeObj( oMdlAR1 )  
Return Nil

//-------------------------------------
/*/{Protheus.doc}  AR1Baixa
Baixa titulos a receber em nome do cliente

@param 		cFilOrig: Filial do documento
@param 		cPrefixo: Prefixo do titulo
@param 		cNum: Numero do titulo
@param 		cTipo: Tipo do titulo
@param 		cCod: Código de identificação da NFS Mais Negócios
@param 		@nRecSE1Ori, recebe o recno das parcelas em nome do cliente
@param 		cCondPgto, condição de pagamento da nota fiscal

@return 	Logico, Informa se os titulos foram baixados
@author 	jose.delmondes
@since  	25/05/2020
@version	P12
/*/
//-------------------------------------
Static Function RSKBaixa( cFilOrig, cPrefixo, cNum, cTipo, cCod, nRecSE1Ori, cCondPgto  )
	Local aArea				:= GetArea()
	Local aAreaSA6			:= SA6->( GetArea() )
	Local aAreaSE1			:= SE1->( GetArea() )
	Local aBaixa 			:= {}
	Local cAliasQry 		:= GetNextAlias()
	Local aBankPart			:= StrToArray( SuperGetMv( "MV_RSKBPAY",, "SUP|SUPPL|SUPPLIER" ), "|" )
	Local cBanco 			:= ''
	Local cAgencia			:= ''
	Local cConta 			:= ''
	Local aErroAuto			:= {}
	Local nI 				:= 0
	Local cError			:= ""
	Local lRet 				:= .T.
	Local aParam 			:= {}
	Local lFirstInstallment := .T.
	Local lRskPedAdt        := RskPedAdt(cCondPgto)

	Private lMsErroAuto		:= .F. 
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.	

	BeginSQL Alias cAliasQry

		SELECT	E1_PARCELA, E1_CLIENTE, E1_LOJA, E1_NATUREZ,E1_VALOR, R_E_C_N_O_ 
		FROM 	%Table:SE1% SE1
		WHERE	SE1.%NotDel% AND
				SE1.E1_FILORIG = %Exp:cFilOrig% AND
				SE1.E1_PREFIXO = %Exp:cPrefixo% AND
				SE1.E1_NUM = %Exp:cNum% AND
				SE1.E1_TIPO = %Exp:cTipo%
		ORDER BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
	EndSQL

	If Len( aBankPart ) == 3 .Or. Len( aBankPart ) == 6 
		SA6->( DBSetOrder(1) )	//A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
		
		cBanco 		:= PadR( aBankPart[BANKP_CODE], TamSX3( "A6_COD" )[1] ) 
		cAgencia	:= PadR( aBankPart[BANKP_AGENCY], TamSX3( "A6_AGENCIA" )[1] ) 
		cConta		:= PadR( aBankPart[BANKP_ACCOUNT], TamSX3( "A6_NUMCON" )[1] ) 
		
		If SA6->( DBSeek( xFilial( 'SA6' ) + cBanco + cAgencia + cConta ) )
			cBanco		:= SA6->A6_COD
			cAgencia	:= SA6->A6_AGENCIA
			cConta 		:= SA6->A6_NUMCON 
		EndIf  
	EndIf 

	While ( cAliasQry )->( !EOF() )	   
		//------------------------------------------------------------------------
		// Condição de pagamento com Adiantamento não deve baixar a primeira parcela
		//------------------------------------------------------------------------
		If lFirstInstallment .And. lRskPedAdt
			lFirstInstallment := .F.
			( cAliasQry )->( DbSkip() )
			Loop
		EndIf


		aBaixa :={	{ "E1_PREFIXO"	, cPrefixo					,Nil	 },;
					{ "E1_NUM"		, cNum						,Nil	 },;
					{ "E1_TIPO"		, cTipo						,Nil	 },;
					{ "E1_PARCELA"	, ( cAliasQry )->E1_PARCELA	,Nil	 },;
					{ "E1_CLIENTE"	, ( cAliasQry )->E1_CLIENTE	,Nil	 },;
					{ "E1_LOJA"		, ( cAliasQry )->E1_LOJA	,Nil	 },;
					{ "E1_NATUREZ"	, ( cAliasQry )->E1_NATUREZ	,Nil	 },;
					{ "AUTMOTBX"    , "OFF"                  	,Nil     },;
					{ "AUTBANCO"    , cBanco                 	,Nil     },;
					{ "AUTAGENCIA"  , cAgencia               	,Nil     },;
					{ "AUTCONTA"    , cConta           			,Nil     },;
					{ "AUTDTBAIXA"  , dDataBase              	,Nil     },;
					{ "AUTDTCREDITO", dDataBase              	,Nil     },;
					{ "AUTHIST"     , STR0003			    	,Nil     },; //"Baixa Supplier-OFF" !!! Validar justificativa 
					{ "AUTVALREC"   , ( cAliasQry )->E1_VALOR   ,Nil     }}

		aParam := {'SE1', 'BAIXACLI' , aBaixa}

		IF EXISTBLOCK("RskFinGrv")
			aBaixa := EXECBLOCK("RskFinGrv",.F.,.F.,aParam)[3]
		ENDIF		
					
		MSExecAuto( { |x,y| Fina070( x, y ) }, aBaixa, 3 )	 

		If lMsErroAuto
			lRet := .F.
			aErroAuto := GetAutoGRLog()
			For nI := 1 To Len( aErroAuto ) 
				cError += aErroAuto[nI]
			Next nI
			LogMsg( "RSKBaixa", 23, 6, 1, "", "", "RSKBaixa -> " + cError )
			cErrorMsg := cError
			Exit
		Else
			SE1->(dbgoto(( cAliasQry )->R_E_C_N_O_))

			RECLOCK("SE1", .F.)
				SE1->E1_HIST := "Baixa NF Mais Neg.: " +  alltrim(cCod)
			MSUNLOCK()     
		EndIf

		If nRecSE1Ori == 0
			nRecSE1Ori := ( cAliasQry )->R_E_C_N_O_
		EndIf

		( cAliasQry )->( dbSkip() )
	End

	( cAliasQry )->( dbCloseArea() )

	RestArea( aArea )
	RestArea( aAreaSA6 )
	RestArea( aAreaSE1 )

	FWFreeArray( aArea )
	FWFreeArray( aAreaSA6 )
	FWFreeArray( aAreaSE1 )
	FWFreeArray( aBaixa )
	FWFreeArray( aBankPart )
	FWFreeArray( aErroAuto )
	FWFreeArray( aParam )
Return lRet

//-------------------------------------
/*/{Protheus.doc} RSKPrinc
Gera titulo principal (a receber) da Supplier

@param 		cFilOrig: Filial do documento
@param 		cPrefixo: Prefixo do titulo Original
@param 		cNum: Numero do titulo Original
@param 		cTipo: Tipo do titulo Original
@param 		nValor: Valor do titulo
@param 		dDataVenc: Venciemento
@param 		cHist: Historico
@param		cNatureza: Código da Natureza (Receita)
@param 		nRecSE1Ori: recno de uma parcela a receber em nome do cliente
@param 		nQtdVend: Quantidade de vendedores
@param 		cSE1Enum: Número do Título a Receber
@param 		cParDef: Parcela do Título a Receber

@return 	array, títulos gerados
	[1]-tipo do título gerado, sendo 1=título principal ou 2=título de taxas
	[2]-filial
	[3]-prefixo do documento
	[4]-numero do titulo
	[5]-parcela do título
	[6]-tipo do título
	[7]-código do cliente
	[8]-loja do cliente
	[9]-valor do título
	[10]-data de vencimento do título

@author 	jose.delmondes
@since  	25/05/2020
@version	P12
/*/
//-------------------------------------
Static Function RSKPrinc( cFilOrig, cPrefixo, cNum, cTipo, nValor, dDataVenc, cHist, cNatureza, nRecSE1Ori, nQtdVend, cSE1Enum, cParDef )
	Local aArea 	:= GetArea()
	Local aAreaSE1 	:= SE1->(GetArea())
	Local aAreaSA3 	:= SA3->(GetArea())
	Local aTitulo 	:= {}
	Local aRet 		:= {}
	Local cCliente	:= SuperGetMV( "MV_RSKCPAY", .T., "" )
	Local cLoja 	:= ''
	Local lContinua := .T.
	Local aErroAuto	:= {}
	Local cError 	:= ""
	Local nI 		:= 0
	Local dEmissao	:= cTod("//")
	Local cPrefDef	:= "OFF"
	Local cTipDef	:= "DP"
	Local aParam 	:= {}
	Local nCntVen   := 0
	Local cNumVend	:= ""

	Private lMsErroAuto		:= .F. 
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.	

	If !Empty( cCliente )
		cLoja 		:= SubStr( cCliente, TamSX3( 'A1_COD' )[1] + 2, TamSX3( 'A1_LOJA' )[1] )
		cCliente	:= SubStr( cCliente, 1, TamSX3( 'A1_COD' )[1] )
	Else
		lContinua := .F.
	EndIf 

	If lContinua
		dEmissao := IIF( dDatabase > dDataVenc, dDataVenc, dDatabase )
		
		aTitulo  := {{ "E1_PREFIXO"  , cPrefDef        			, Nil },;
					 { "E1_NUM"      , cSE1Enum        			, Nil },;
					 { "E1_PARCELA"  , cParDef					, Nil },;
					 { "E1_TIPO"     , cTipDef         			, Nil },;
					 { "E1_NATUREZ"  , cNatureza				, Nil },;
					 { "E1_CLIENTE"  , cCliente          		, Nil },;
					 { "E1_LOJA"     , cLoja              		, Nil },;
					 { "E1_EMISSAO"  , dEmissao					, Nil },;
					 { "E1_VENCTO"   , dDataVenc				, Nil },;
					 { "E1_VENCREA"  , dDataVenc				, Nil },;
					 { "E1_HIST"     , cHist             		, Nil },;
					 { "E1_BOLETO"   , "2" 	            		, Nil },;					
					 { "E1_VALOR"    , nValor             		, Nil }}
		
		If nRecSE1Ori > 0 

			SE1->(DbGoTo(nRecSE1Ori))
			
			For nCntVen := 1 To nQtdVend
				If nCntVen > 9
					cNumVend := RetAsc( nCntVen, 1, .T. )
				Else
					cNumVend := cValToChar(nCntVen)
				EndIf
				If	Posicione("SA3", 1, xFilial("SA3") + &("SE1->E1_VEND" + cNumVend), "A3_ALBAIXA") == 100 
					aAdd(aTitulo, {"E1_VEND" + cNumVend, SE1->(FieldGet(SE1->(FieldPos("E1_VEND" + cNumVend)))), Nil})
					aAdd(aTitulo, {"E1_COMIS" + cNumVend, SE1->(FieldGet(SE1->(FieldPos("E1_COMIS" + cNumVend)))), Nil})
					If SE1->(FieldGet(SE1->(FieldPos("E1_BASCOM" + cNumVend)))) > 0 
						aAdd(aTitulo, {"E1_BASCOM" + cNumVend, nValor, Nil})
					EndIf
				EndIf
			Next nCntVen

		EndIf

		aParam := {'SE1', 'INCTITSUPP' , aTitulo}

		IF EXISTBLOCK("RskFinGrv")
			aTitulo := EXECBLOCK("RskFinGrv",.F.,.F.,aParam)[3]
		ENDIF   

		MsExecAuto( { |x,y| FINA040( x, y ) } , aTitulo, 3 )   

		If !lMsErroAuto
			aRet := { BILL_MAIN, cFilAnt, cPrefDef, cSE1Enum, cParDef, cTipDef, cCliente, cLoja, nValor, dDataVenc }	// 1=Título principal 
		Else
			aErroAuto := GetAutoGRLog()
			For nI := 1 To Len( aErroAuto )
				cError += aErroAuto[nI] 
			Next nI
			LogMsg( "RSKPrinc", 23, 6, 1, "", "", "RSKPrinc -> " + cError )
			cErrorMsg := cError	
		EndIf
	EndIf

	RestArea( aAreaSE1 )
	RestArea( aAreaSA3 )
	RestArea( aArea )

	FWFreeArray( aArea )
	FWFreeArray( aAreaSE1 )
	FWFreeArray( aAreaSA3 )
	FWFreeArray( aTitulo )
	FWFreeArray( aErroAuto )
	FWFreeArray( aParam )
Return aRet

//-------------------------------------
/*/{Protheus.doc} RSKTaxa
Gera os títulos de taxas (a pagar) para a Supplier

@param 		cFilOrig: Filial do documento
@param 		cPrefixo: Prefixo do titulo
@param 		cNum: Numero do titulo
@param 		cParcela: Parcela do titulo
@param 		cTipo: Tipo do titulo
@param 		nValor: Valor das taxas
@param 		dDataVenc: Vencimento
@param 		cHist: Historico
@param		cNatureza : Código da Natureza (Despesa)

@return 	array, títulos gerados, onde:
	[1]-tipo do título gerado, sendo 1=título principal ou 2=título de taxas
	[2]-filial
	[3]-prefixo do documento
	[4]-numero do titulo
	[5]-parcela do título
	[6]-tipo do título
	[7]-código do cliente
	[8]-loja do cliente
	[9]-valor do título
	[10]-data de vencimento do título

@author 	jose.delmondes
@since  	25/05/2020
@version	P12
/*/
//-------------------------------------
Function RSKTaxa( cFilOrig, cPrefixo, cNum, cParcela, cTipo, nValor, dDataVenc, cHist, cNatureza )
	Local aArea 	:= GetArea()
	Local aTitulo 	:= {}
	Local aRet 		:= {}
	Local cAliasQry := GetNextAlias()
	Local cCliente	:= SuperGetMV( "MV_RSKCPAY", .T., "" )
	Local cLoja 	:= ''
	Local lContinua := .T.
	Local aErroAuto	:= {}
	Local cError 	:= ""
	Local nI 		:= 0 
	Local dEmissao	:= cTod("//")
	Local aParam 	:= {}
	Local lLibTit 	:= SuperGetMV('MV_CTLIPAG', , .F.)
	Local dDataLib	:= CToD("//")

	Private lMsErroAuto		:= .F. 
	Private lAutoErrNoFile	:= .T.
	Private lMsHelpAuto   	:= .T.	

	If !Empty( cCliente )
		cLoja 		:= SubStr( cCliente, TamSX3( 'A1_COD' )[1] + 2, TamSX3( 'A1_LOJA' )[1] )
		cCliente 	:= SubStr( cCliente, 1, TamSX3( 'A1_COD' )[1] )
	Else
		lContinua	:= .F.
	EndIf
	
	If lContinua
		
		BeginSQL Alias cAliasQry

			SELECT	A2_COD, A2_LOJA  
			FROM 	%Table:SA2% SA2
			WHERE	SA2.%NotDel% AND
					SA2.A2_FILIAL  = %Exp:xFilial( "SA2", cFilOrig )% AND
					SA2.A2_CLIENTE = %Exp:cCliente% AND
					SA2.A2_LOJCLI  = %Exp:cLoja%

		EndSQL

		If ( cAliasQry )->( !Eof() )	
			dEmissao := IIF( dDatabase > dDataVenc, dDataVenc, dDatabase )
			dDataLib := IIf(lLibTit, dDatabase, dDataLib)
			
			aTitulo  := {{ "E2_PREFIXO" , cPrefixo          		, NIL },; 
						 { "E2_NUM"      , cNum        				, NIL },; 
						 { "E2_PARCELA"  , cParcela            		, NIL },;
						 { "E2_TIPO"     , cTipo            		, NIL },; 
						 { "E2_NATUREZ"  , cNatureza				, NIL },;
						 { "E2_FORNECE"  , ( cAliasQry )->A2_COD    , NIL },;
						 { "E2_LOJA"     , ( cAliasQry )->A2_LOJA   , NIL },;
						 { "E2_HIST"     , cHist	            	, Nil },;  
						 { "E2_EMISSAO"  , dEmissao					, NIL },;
						 { "E2_VENCTO"   , dDataVenc				, NIL },;
						 { "E2_VENCREA"  , dDataVenc				, NIL },;
						 { "E2_VALOR"    , nValor             		, NIL },;
						 { "E2_DATALIB"  , dDataLib            		, NIL }}

			aParam := {'SE2', 'INCTXSUPP' , aTitulo}

			IF EXISTBLOCK("RskFinGrv")
				aTitulo := EXECBLOCK("RskFinGrv",.F.,.F.,aParam)[3]
			ENDIF

			MsExecAuto( { |x,y| FINA050( x, y ) } , aTitulo, 3 ) 

			If !lMsErroAuto
				aRet := { BILL_FEE, cFilAnt, cPrefixo, cNum, cParcela, cTipo, ( cAliasQry )->A2_COD, ( cAliasQry )->A2_LOJA , nValor, dDataVenc }	// 2=Título de taxas
			Else
				aErroAuto := GetAutoGRLog()
				For nI := 1 To Len( aErroAuto )  
					cError += aErroAuto[nI]
				Next nI
				LogMsg( "RSKTaxa", 23, 6, 1, "", "", "RSKTaxa -> " + cError )
				cErrorMsg := cError	
			EndIf
		EndIf

		( cAliasQry )->( dbCloseArea() )
	EndIf 

	RestArea( aArea )

	FWFreeArray( aArea )
	FWFreeArray( aTitulo )
	FWFreeArray( aErroAuto )
	FWFreeArray( aParam )
Return aRet   

//-------------------------------------
/*/{Protheus.doc} RSKGrvBol
Grava boleto no banco de conhecimento

@param 		cFile: arquivo pdf em base 64
@param 		cDoc: codigo do documento

@return 	logico, informa se o boleto foi gravado 
@author 	jose.delmondes
@since  	04/06/2020
@version	P12
/*/
//-------------------------------------
Static Function RSKGrvBol( cFile, cDoc )
	Local cDirDocs 	:= MsDocPath()
	Local cName := StrTran( xFilial( 'AR1' ) + cDoc + '_boleto.pdf', ' ', '_' )
	Local lRet := .T.
	Local nStack := GetSX8Len()

	//------------------------------------------------------------------------------
	//-- Cria o documento no diretorio do banco de conhecimento
	//------------------------------------------------------------------------------
	nHandle:= FCREATE( cDirDocs + "\" + cName , 0 )

	If nHandle == -1
		lRet := .F.
	else
		//------------------------------------------------------------------------------
		//-- Escreve documento
		//------------------------------------------------------------------------------
		FWRITE( nHandle , Decode64( cFile ) ) 
		
		//------------------------------------------------------------------------------
		//-- Valida criacao do documento
		//------------------------------------------------------------------------------
		If FCLOSE( nHandle ) .And. File( cDirDocs + "\" + cName )
			//------------------------------------------------------------------------------
			//-- Grava tabelas do banco de conhecimento
			//------------------------------------------------------------------------------
			RecLock( "ACB" , .T. )
				ACB->ACB_FILIAL := xFilial( "ACB") 
				ACB->ACB_CODOBJ := GetSX8Num( "ACB" , "ACB_CODOBJ" )
				ACB->ACB_OBJETO := cName
				ACB->ACB_DESCRI := STR0004 //'Boleto'
			ACB->( MsUnlock() )

			RecLock( "AC9", .T. )
				AC9->AC9_FILIAL := xFilial( "AC9" )
				AC9->AC9_FILENT := xFilial( "AR1" )
				AC9->AC9_ENTIDA := "AR1"
				AC9->AC9_CODENT := xFilial( 'AR1' ) + cDoc
				AC9->AC9_CODOBJ := ACB->ACB_CODOBJ
			AC9->( MsUnlock() )

			//------------------------------------------------------------------------------
			//-- Confirma num. sequencial
			//------------------------------------------------------------------------------
			While GetSX8Len() > nStack 
				ConfirmSX8()
			End
		else		
			lRet = .F.
		EndIf 
	EndIf
Return lRet  
