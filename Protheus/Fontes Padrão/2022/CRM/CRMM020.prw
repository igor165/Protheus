#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "CRMM020.CH"

Static __oModel := Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMMOPPORTUNITIES

Classe responsável por retornar as oportunidades de venda de um usuario 
autenticado no appCRM.

@author	Anderson Silva
@since		13/12/2016
@version	12.1.15
/*/
//------------------------------------------------------------------------------
WSRESTFUL CRMMOPPORTUNITIES DESCRIPTION STR0009 //"Oportunidades do CRM"

WSDATA UserId 			AS STRING 
WSDATA Opportunities 	AS STRING	OPTIONAL
WSDATA SearchKey 		AS STRING	OPTIONAL
WSDATA Fields			AS STRING	OPTIONAL
WSDATA EntityType		AS STRING	OPTIONAL
WSDATA IdEntity			AS STRING	OPTIONAL
WSDATA Page				AS INTEGER	OPTIONAL
WSDATA PageSize			AS INTEGER	OPTIONAL
WSDATA Owner			AS INTEGER	OPTIONAL 	 	 

WSMETHOD GET DESCRIPTION STR0001 WSSYNTAX "/CRMMOPPORTUNITIES/{UserId, Opportunities, SearchKey, Fields, Page, PageSize, EntityType, IdEntity,Owner}" //"Retorna as oportunidades do usuario / papel autenticado."
WSMETHOD PUT DESCRIPTION STR0002 WSSYNTAX "/CRMMOPPORTUNITIES/IdOpportunity" //"Atualiza a oportunidade do usuario / papel autenticado."

ENDWSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET / CRMMUSERROLES
Retorna as oportunidades de venda de um usuario autenticado no appCRM.

@param	UserId	, caracter, usuario do CRM.
Opportunities	, caracter, Lista de oportunidades para ser considerado na consulta. Ex: '000012,230012,304054'
SearchKey		, caracter, Chave de pesquisa para ser considerado na consulta. 
Obs. Se o parametro Opportunities foi informado a chave de pesquisa será desconsiderada.
Fields			, caracter, Lista de campos para montagem da consulta. Ex. 'OPP_NUMBER,OPP_REVIEW,OPP_DESCRIPTION'.
Page			, numerico, Posição do registro para ser considerado na consulta. Ex. A partir de: 40.
PageSize		, numerico, Posição final do registro para ser considerado na consulta. Ex. A partir de: 40 até 60.

@return cResponse		, caracter, JSON com as oportunidades.

@author	Anderson Silva
@since		13/12/2016
@version	12.1.15 
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE UserId, Opportunities, SearchKey, Fields, Page, PageSize, EntityType, IdEntity, Owner  WSSERVICE CRMMOPPORTUNITIES

	Local cTemp					:= GetNextAlias()
	Local cResponse				:= '{ "OPPORTUNITIES":[], "COUNT": 0 } '
	Local cConcat				:= ""
	Local cEntity				:= ""
	Local cAccountId			:= ""
	Local cAccountName			:= ""
	Local cFilterAD1			:= ""
	Local cQuery				:= ""
	Local cSalesProc			:= ""
	Local cSearch				:= ""
	Local cCodVend				:= ''
	Local cReadOnly				:= 'false'
	Local cMessage				:= "Internal Server Error"
	Local nRecord				:= 0
	Local nOppJson				:= 0
	Local nCount 				:= 0
	Local nX					:= 0
	Local nY					:= 0
	Local nFields				:= 0
	Local nStages				:= 0
	Local nOpportunities		:= 0
	Local nStart				:= 0
	Local nStatusCode			:= 500
	Local aFields				:= {}
	Local aStages				:= {}
	Local aOpportunities		:= {}
	Local lRet	 				:= .F.
	Local lHavFilter			:= .F.
	Local cNotes 				:= ""

	Default Self:UserId			:= ""
	Default Self:Opportunities	:= ""
	Default Self:SearchKey 		:= ""
	Default Self:Fields			:= ""
	Default Self:EntityType		:= ""
	Default Self:IdEntity		:= ""
	Default Self:Page			:= 1
	Default Self:PageSize		:= 20
	Default Self:Owner			:= 0
	Private nModulo 			:= 73

	//-------------------------------------------------------------------
	// Define o tipo de retorno do método
	//-------------------------------------------------------------------
	Self:SetContentType("application/json")

	If Empty( Self:UserId )
		Self:UserId := __cUserId
	EndIf

	If !Empty( Self:EntityType )
		Self:EntityType := Upper(Self:EntityType)
	EndIf

	If ( Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[1] ) )
		Self:Opportunities := Self:aURLParms[1]
	EndIf

	//-------------------------------------------------------------------
	// Nao aceita paginacao negativa.
	//-------------------------------------------------------------------
	If ( Positivo( Self:Page ) .And. Positivo( Self:PageSize ) )

		If !Empty( Self:UserId ) 

			AO3->( DBSetOrder(1) )
			If AO3->( MSSeek(xFilial("AO3") + Self:UserId ) )
				cCodVend	:= AO3->AO3_VEND
				If Empty( cCodVend)
					nStatusCode	:= 400
					cMessage	:= STR0012 //"Nao foi possivel identificar o vendedor deste usuario..."
				Else
					lRet := .T.
				EndIf
			Else
				nStatusCode	:= 400
				cMessage 	:= STR0013 //"Nao foi possivel identificar este usuario como usuario do CRM..."
			EndIf

			If lRet .And. !Empty( cCodVend )

				If !Empty( Self:Fields )
					aFields := StrTokArr( Alltrim( Upper( Self:Fields ) ), "," )
					nFields := Len( aFields )
				EndIf

				If !Empty( Self:Opportunities )
					aOpportunities	:= StrTokArr( Upper( Self:Opportunities  ), "," )
					nOpportunities	:= Len( aOpportunities )
				EndIf

				//-------------------------------------------------------------------
				// Define o operador de concatenação.
				//-------------------------------------------------------------------
				cConcat := IIF( ! "MSSQL" $ TCGetDB(), "||", "+" )

				//-------------------------------------------------------------------
				// Monta o filtro para query de Oportunidades
				//-------------------------------------------------------------------

				cFilterAD1	:= CRMXFilEnt( "AD1", .T. )

				cQuery := "SELECT DISTINCT "
				cQuery += "	AD1.AD1_FILIAL, AD1.AD1_NROPOR, AD1.AD1_REVISA, AD1.AD1_DESCRI, AD1.AD1_PROSPE, AD1.AD1_LOJPRO, "
				cQuery += "	AD1.AD1_CODCLI, AD1.AD1_LOJCLI, AD1.AD1_VEND, AD1.AD1_FEELIN, AD1.AD1_PROVEN,  "
				cQuery += "	AD1.AD1_STAGE, AD1.AD1_DTINI, AD1.AD1_MOEDA, AD1.AD1_DTPFIM, AD1.AD1_RCINIC, AD1.AD1_CODMEM, "
				cQuery += "	AD1.AD1_RCFECH, SA1.A1_NOME, SUS.US_NOME "
				
				If !Empty(cFilterAD1)
					cQuery += ", AO4.AO4_CTRLTT, AO4.AO4_PERVIS, AO4.AO4_PEREDT "
					lHavFilter := .T.
				EndIf
				
				cQuery += "FROM "
				cQuery += RetSqlName( "AD1" ) + " " + "AD1 "

				//-------------------------------------------------------------------
				// Filtro de pesquisa para SAI e SUS.
				//-------------------------------------------------------------------
				cQuery += "LEFT JOIN " + RetSqlName( "SA1" ) + " " + "SA1 "
				cQuery += "ON SA1.A1_FILIAL  = '" + xFilial("SA1") + "' AND AD1.AD1_CODCLI = SA1.A1_COD AND " 
				cQuery += "AD1.AD1_LOJCLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
				cQuery += "LEFT JOIN " + RetSqlName( "SUS" ) + " " + "SUS "
				cQuery += "ON SUS.US_FILIAL  = '" + xFilial("SUS") + "' AND AD1.AD1_PROSPE = SUS.US_COD AND "
				cQuery += "AD1.AD1_LOJPRO = SUS.US_LOJA AND SUS.D_E_L_E_T_ = ' ' "					

				If	lHavFilter
					cQuery += "INNER JOIN " + RetSqlName( "AO4" ) + " " + "AO4 "
					cQuery += "ON AO4.AO4_CHVREG = AD1.AD1_FILIAL " + cConcat + " AD1.AD1_NROPOR AND AO4.D_E_L_E_T_ = ' ' "
				
				EndIf

				cQuery += "WHERE " 
				cQuery += "AD1.AD1_FILIAL = '" + xFilial("AD1") + "' AND "
				cQuery += "AD1.AD1_STATUS = '1' AND "
				
				If !lHavFilter .Or. Self:Owner == 1
					cQuery += "AD1.AD1_VEND = '" + cCodVend + "' AND "
				ElseIf Self:Owner == 2
					cQuery += "AD1.AD1_VEND <> '" + cCodVend + "' AND "
				EndIf

				If Upper(Self:EntityType) == "SA1"
					If Empty( Self:IdEntity )
						cQuery += " AD1.AD1_CODCLI <> ' ' AND AD1.AD1_LOJCLI <> ' ' AND "
						cQuery += " AD1.AD1_PROSPE = ' ' AND AD1.AD1_LOJPRO = ' ' AND "
					Else
						cQuery += "AD1.AD1_CODCLI " + cConcat + "  AD1.AD1_LOJCLI = '" + Self:IdEntity + "' AND "
					EndIf
				EndIf
				
				If Upper(Self:EntityType) == "SUS"
					If Empty( Self:IdEntity )
						cQuery += " AD1.AD1_PROSPE <> ' ' AND AD1.AD1_LOJPRO <> ' ' AND "
						cQuery += " AD1.AD1_CODCLI = ' ' AND AD1.AD1_LOJCLI = ' ' AND "
					Else 
						cQuery += "AD1.AD1_PROSPE " + cConcat + "  AD1.AD1_LOJPRO = '" + Self:IdEntity + "' AND "
					EndIf		
				EndIf

				If !Empty( aOpportunities )
					If nOpportunities == 1
						cQuery += "AD1.AD1_NROPOR = '" + aOpportunities[1] + "' AND "
					Else 
						cQuery += "AD1.AD1_NROPOR IN ( " 
						For	nX := 1 To nOpportunities
							cQuery +=	"'" + aOpportunities[nX] + "'"
							If nX < nOpportunities
								cQuery +=	", "
							EndIf
						Next nX
						cQuery += ") AND "
					EndIf
				ElseIf !Empty( Self:SearchKey )
					cSearch := AllTrim( Upper( FwNoAccent( Self:SearchKey ) ) )
					cQuery  += "( AD1.AD1_NROPOR LIKE '%"	+ cSearch + "%' OR "
					cQuery  += "  AD1.AD1_DESCRI LIKE '%"	+ cSearch + "%' OR "
					cQuery  += "  AD1.AD1_CODCLI " 			+ cConcat + " AD1.AD1_LOJCLI LIKE '" + cSearch + "%' OR "
					cQuery  += "  AD1.AD1_PROSPE " 			+ cConcat + " AD1.AD1_LOJPRO LIKE '" + cSearch + "%' OR "
					cQuery  += "  SA1.A1_NOME LIKE '%"   	+ cSearch + "%' OR
					cQuery  += "  SUS.US_NOME LIKE '%"	 	+ cSearch + "%' ) AND " 
				EndIf

				If lHavFilter
					cQuery += cFilterAD1 + " AND "
					
				EndIf

				cQuery += "AD1.D_E_L_E_T_ = ' ' "

				cQuery += "ORDER BY AD1_DTPFIM ASC "

				//-------------------------------------------------------------------
				// Executa a instrução.
				//-------------------------------------------------------------------

				DBUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cTemp, .T., .T. )

				If ( cTemp )->( ! Eof() )

					//-------------------------------------------------------------------
					// Identifica a quantidade de registro no alias temporário.
					//-------------------------------------------------------------------
					COUNT TO nRecord

					//-------------------------------------------------------------------
					// Posiciona no primeiro registro.
					//-------------------------------------------------------------------
					( cTemp )->( DBGoTop() )

					//-------------------------------------------------------------------
					// Limita a pagina.
					//-------------------------------------------------------------------
					If Self:PageSize > 30 
						Self:PageSize := 20
					EndIf

					If Self:Page > 1
                        nStart := ( (Self:Page-1) * Self:PageSize) +1 
                    EndIf

					cResponse := ""
					cResponse += '{ "OPPORTUNITIES":['

					//-------------------------------------------------------------------
					// Percorre todos os registros sem privilégio definido.
					//-------------------------------------------------------------------
					While ( cTemp )->( ! Eof() )

						nCount ++

						If ( nCount >= nStart )

							nOppJson ++

							If ( cSalesProc <> ( cTemp )->AD1_PROVEN )
								aStages 	:= CRMM20Stages(  ( cTemp )->AD1_PROVEN )
								nStages		:= Len( aStages )
								cSalesProc	:= ( cTemp )->AD1_PROVEN
							EndIf


							If !Empty( ( cTemp )->AD1_CODCLI )
								cEntity			:= "SA1"
								cAccountId		:= ( cTemp )->AD1_CODCLI + ( cTemp )->AD1_LOJCLI
								cAccountName	:= AllTrim( ( cTemp )->A1_NOME )
							Else
								cEntity			:= "SUS"
								cAccountId		:= ( cTemp )->AD1_PROSPE + ( cTemp )->AD1_LOJPRO
								cAccountName	:= AllTrim( ( cTemp )->US_NOME )
							EndIf

							If lHavFilter
								cReadOnly := IIF( ( cTemp )->AO4_CTRLTT == 'F' .And. ( cTemp )->AO4_PEREDT  == 'F' .And. ( cTemp )->AO4_PERVIS == 'T', 'true', 'false' )
							EndIf

							cResponse += '{'

							If nFields == 0

								cResponse += '"OPP_BRANCH":"' 				+ ( cTemp )->AD1_FILIAL 										+ '",'
								cResponse += '"OPP_NUMBER":"' 				+ ( cTemp )->AD1_NROPOR 										+ '",'
								cResponse += '"OPP_REVIEW":"' 				+ ( cTemp )->AD1_REVISA 										+ '",'
								cResponse += '"OPP_DESCRIPTION":"' 			+ EncodeUTF8( CRMMText( ( cTemp )->AD1_DESCRI , .F.,.T.  ) )	+ '",'								
								cResponse += '"ACCOUNT_ENTITY":"' 			+ cEntity														+ '",'
								cResponse += '"ACCOUNT_ID":"' 				+ cAccountId 													+ '",'
								cResponse += '"ACCOUNT_NAME":"' 			+ EncodeUTF8(CRMMText( cAccountName ) )							+ '",'
								cResponse += '"SALES_REPRESENTATIVE":"'		+ ( cTemp )->AD1_VEND 											+ '",'
								cResponse += '"FEELING":"' 					+ ( cTemp )->AD1_FEELIN 										+ '",'
								cResponse += '"PROCESS":"' 					+ ( cTemp )->AD1_PROVEN 										+ '",'
								cResponse += '"STAGES": ['
								
								For nY := 1 To nStages
									cResponse += '{"STAGE_ID": "' + aStages[nY][1] + '", "STAGE_DESCRIPTION": "' + CRMMText(aStages[nY][2], .F., .T. )  + '"}'
									If nY < nStages
										cResponse += ',' 
									EndIf
								Next nY

								cResponse += ' ],'

								cNotes := StrTran( EncodeUTF8( MSMM(( cTemp )->AD1_CODMEM ) ),Chr(10),"\n") 
								cNotes := Strtran(cNotes,Chr(13),"\r")
								cNotes := Strtran(cNotes,"\"	,"\\")
								cNotes := Strtran(cNotes,"\s"	," ")
								cNotes := Strtran(cNotes,'"'	,'\"')

								cResponse += '"SELECTED_STAGE":"' 		+ ( cTemp )->AD1_STAGE 							+ '",'
								
								cResponse += '"NOTES":"' 				+ cNotes										+ '",'
								
								cResponse += '"START_DATE":"' 			+ ( cTemp )->AD1_DTINI 							+ '",'
								cResponse += '"ESTIMATED_DATE":"' 		+ ( cTemp )->AD1_DTPFIM 						+ '",'
								cResponse += '"CURRENCY":"' 			+ cValToChar( ( cTemp )->AD1_MOEDA )			+ '",'
								cResponse += '"ESTIMATED_VALUE":"' 		+ cValToChar( ( cTemp )->AD1_RCINIC ) 			+ '",'
								cResponse += '"MONTHLY_PAYMENT":"' 		+ cValToChar( ( cTemp )->AD1_RCFECH ) 			+ '",'
								cResponse += '"READONLY":"' 			+ cReadOnly										+ '"'

							Else

								For nX := 1 To nFields 
									aFields[nX] := Alltrim(aFields[nX])
									Do Case
										Case aFields[nX] == "OPP_BRANCH"
											cResponse += '"OPP_BRANCH":"' 				+ ( cTemp )->AD1_FILIAL 									+ '"'
										Case aFields[nX] == "OPP_NUMBER"
											cResponse += '"OPP_NUMBER":"' 				+ ( cTemp )->AD1_NROPOR 									+ '"'
										Case aFields[nX] == "OPP_REVIEW"
											cResponse += '"OPP_REVIEW":"' 				+ ( cTemp )->AD1_REVISA 									+ '"'
										Case aFields[nX] == "OPP_DESCRIPTION"
											cResponse += '"OPP_DESCRIPTION":"' 			+ EncodeUTF8(CRMMText( ( cTemp )->AD1_DESCRI , .F.,.T.  ) )	+ '"'										
										Case aFields[nX] == "ACCOUNT_ENTITY"
											cResponse += '"ACCOUNT_ENTITY":"'			+ cEntity 													+ '"'
										Case aFields[nX] == "ACCOUNT_ID"
											cResponse += '"ACCOUNT_ID":"' 				+ cAccountId 												+ '"'
										Case aFields[nX] == "ACCOUNT_NAME"
											cResponse += '"ACCOUNT_NAME":"' 			+ EncodeUTF8(CRMMText( cAccountName ))						+ '"'
										Case aFields[nX] == "SALES_REPRESENTATIVE"
											cResponse += '"SALES_REPRESENTATIVE":"'		+ ( cTemp )->AD1_VEND 										+ '"'
										Case aFields[nX] == "FEELING"
											cResponse += '"FEELING":"' 					+ ( cTemp )->AD1_FEELIN 									+ '"'
										Case aFields[nX] == "PROCESS"
											cResponse += '"PROCESS":"' 					+ ( cTemp )->AD1_PROVEN 									+ '"'
										Case aFields[nX] == "SELECTED_STAGE"

											cResponse += '"STAGES": ['

											For nY := 1 To nStages
												cResponse += '{"STAGE_ID": "' + aStages[nY][1] + '", "STAGE_DESCRIPTION": "' + CRMMText(aStages[nY][2], .F.,.T.) + '"}'
												If nY < nStages
													cResponse += ','
												EndIf
											Next nY

											cResponse += ' ],'
											cResponse += '"SELECTED_STAGE":"' 			+ ( cTemp )->AD1_STAGE 				+ '"'
										
										Case aFields[nX] == "NOTES"	 													
											cNotes := StrTran( EncodeUTF8( MSMM(( cTemp )->AD1_CODMEM ) ),Chr(10),"\n") 
											cNotes := Strtran(cNotes,Chr(13),"\r")
											cNotes := Strtran(cNotes,"\"	,"\\")
											cNotes := Strtran(cNotes,"\s"	," ")
											cNotes := Strtran(cNotes,'"'	,'\"')

											cResponse += '"NOTES":"' 					+ cNotes							+ '"'
										
										Case aFields[nX] == "START_DATE"
											cResponse += '"START_DATE":"' 				+ ( cTemp )->AD1_DTINI 				+ '"'
										Case aFields[nX] == "ESTIMATED_DATE"
											cResponse += '"ESTIMATED_DATE":"' 			+ ( cTemp )->AD1_DTPFIM 			+ '"'
										Case aFields[nX] == "CURRENCY"
											cResponse += '"CURRENCY":"' 				+ cValToChar( ( cTemp )->AD1_MOEDA ) + '"'
										Case aFields[nX] == "ESTIMATED_VALUE"
											cResponse += '"ESTIMATED_VALUE":"' 			+ cValToChar( ( cTemp )->AD1_RCINIC ) + '"'
										Case aFields[nX] == "MONTHLY_PAYMENT"
											cResponse += '"MONTHLY_PAYMENT":"' 			+ cValToChar( ( cTemp )->AD1_RCFECH ) + '"'

										OtherWise
											If ( nX == nFields .And. Right( cResponse, 1 ) == "," )
												cResponse := SubStr( cResponse, 1, Len( cResponse ) - 1 )
											EndIf
										Loop
									EndCase

									If nX < nFields
										cResponse += ','
									EndIf

								Next nX

							EndIf
							
							If lHavFilter 
								cResponse += ', "READONLY":"' + cReadOnly + '"'
							EndIf

							aContacts	:= CRMM20Contacts( (cTemp)->AD1_NROPOR, (cTemp)->AD1_REVISA )
							nContacts	:= Len( aContacts )	

							cResponse += ',"CONTACTS": ['

							For nY := 1 To nContacts
								If ColumnPos("U5_PRIEMP") > 0
									cResponse += '{"CONTACT_ID": "' + aContacts[nY][1] + '", "CONTACT_NAME": "' + EncodeUTF8(aContacts[nY][2]) + '", "MAIN_CONTACT": "' + aContacts[nY][3] + '" }'
								Else
									cResponse += '{"CONTACT_ID": "' + aContacts[nY][1] + '", "CONTACT_NAME": "' + EncodeUTF8(aContacts[nY][2]) + '" }'
								EndIf
								If nY < nContacts
									cResponse += ','
								EndIf
							Next nY

							cResponse += ' ] '

							cResponse += '}'

							If nOppJson < Self:PageSize .And. nCount < nRecord
								cResponse += ','
							EndIf

						EndIf

						If ( nOppJson == Self:PageSize )
							Exit
						EndIf

						( cTemp )->( DBSkip() )
					EndDo
					cResponse += '], '
					cResponse += '"COUNT": ' +cBIStr( nRecord ) + ' } '

				EndIf

			EndIf

		Else
			nStatusCode	:= 400
			cMessage 	:= STR0014 //"Nao foi possivel identificar usuario..."
		EndIf

	Else
		nStatusCode	:= 400
		cMessage 	:= STR0010 //"Verifique se os parametros de paginacao estao negativos..."
	EndIf

	If lRet 
		Self:SetResponse( cResponse )
	Else
		SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
	EndIf

	Asize(aFields,0)
	Asize(aStages,0)
	Asize(aOpportunities,0)

Return( lRet )

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} PUT / CRMMOPPORTUNITIES
Atualiza uma oportunidade de venda.

@param	 aURLParms			, caracter, Parametro recebido na URL id da oportunidade.
@return cResponse			, caracter, JSON com as oportunidades.

@author	Anderson Silva
@since		13/12/2016
@version	12.1.15 
/*/
//-----------------------------------------------------------------------------------
WSMETHOD PUT WSSERVICE CRMMOPPORTUNITIES

	Local oMdlAD1		:= Nil
	Local cBody			:= ""
	Local oOppJson		:= Nil
	Local aError		:= {}
	Local cResponse		:= ""
	Local cMessage		:= "Internal Server Error"
	Local nStatusCode	:= 500
	Local lRet	 		:= .F.

	Private nModulo 	:= 73

	Self:SetContentType("application/json")

	If Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[1] )

		DBSelectArea("AD1")
		AD1->( DBSetOrder( 1 ) )
		AD1->( MSSeek( xFilial("AD1") ) ) 

		If AD1->( MSSeek( xFilial("AD1") + Self:aURLParms[1] ) )

			cBody := Self:GetContent()

			If !Empty( cBody )

				FWJsonDeserialize(cBody,@oOppJson) 

				If !Empty( oOppJson )  

					If __oModel == Nil
						__oModel := FwLoadModel("FATA300")
					ElseIf __oModel:IsActive()
						//Desativa o model caso o mesmo não foi desativado por algum errorlog no commit da ultima utilização.
						__oModel:DeActivate()
					EndIf

					__oModel:SetOperation( MODEL_OPERATION_UPDATE )
					__oModel:Activate()

					If __oModel:IsActive()

						oMdlAD1 := __oModel:GetModel("AD1MASTER")

						If AttIsMemberOf(oOppJson,"OPP_DESCRIPTION") 
							oMdlAD1:SetValue("AD1_DESCRI"	,oOppJson:OPP_DESCRIPTION)
						EndIf

						If AttIsMemberOf(oOppJson,"FEELING") 
							oMdlAD1:SetValue("AD1_FEELIN"	,oOppJson:FEELING)
						EndIf

						If AttIsMemberOf(oOppJson,"SELECTED_STAGE") 
							oMdlAD1:SetValue("AD1_STAGE"	,oOppJson:SELECTED_STAGE)
						EndIf

						If AttIsMemberOf(oOppJson,"NOTES") 
							oMdlAD1:SetValue("AD1_MEMO"		, DecodeUTF8( StrTran( oOppJson:NOTES ,'"','' ) ) )
						EndIf

						If AttIsMemberOf(oOppJson,"ESTIMATED_DATE") 
							oMdlAD1:SetValue("AD1_DTPFIM"	,sTod( oOppJson:ESTIMATED_DATE ))  
						EndIf

						If AttIsMemberOf(oOppJson,"ESTIMATED_VALUE") 
							oMdlAD1:SetValue("AD1_RCINIC"	,nBIVal( oOppJson:ESTIMATED_VALUE ) )
						EndIf

						If AttIsMemberOf(oOppJson,"MONTHLY_PAYMENT") 
							oMdlAD1:SetValue("AD1_RCFECH"	,nBIVal( oOppJson:MONTHLY_PAYMENT ) )
						EndIf

						If __oModel:VldData() 
							__oModel:CommitData()
							cResponse		:= '{"sucessCode":200,"sucessMessage": "' + STR0003 + '"}' //"Oportunidade atualizada com sucesso..."
							lRet 			:= .T. 
						Else
							aError := __oModel:GetErrorMessage()
							If !Empty ( aError )
								
								If aError[MODEL_MSGERR_IDFIELDERR] == "AD1_DESCRI"
									cMessage := STR0015 //"O campo Oportunidade não foi preenchido..."
								Else
									cMessage := aError[MODEL_MSGERR_MESSAGE] 	+ " " + Chr(10)	
									cMessage += aError[MODEL_MSGERR_SOLUCTION]
								EndIf
								ASize(aError, 0)
								cMessage := EncodeUtf8( FwNoAccent( cMessage ) ) 
								nStatusCode	:= 400
							EndIf
						EndIf

					Else
						cMessage	:= STR0004 //"Falha na ativacao da oportunidade no servidor."
						nStatusCode	:= 400
					EndIf

					__oModel:DeActivate()

					FreeObj( oOppJson )
					oOppJson := Nil

				Else
					cMessage	:= STR0005 //"Falha na transformacao da oportunidade enviada para o servidor!"
					nStatusCode	:= 400 
				EndIf

			Else
				cMessage	:= STR0006 //"Dados da oportunidade nao encontrado no corpo da requisicao."
				nStatusCode	:= 400 
			EndIf

		Else
			cMessage	:= STR0007 //"Oportunidade nao encontrada no servidor"
			nStatusCode	:= 400 
		EndIf

	Else
		cMessage	:= STR0008 //"Falha na alteracao da Oportunidade. Verifique os parametro de envio!"
		nStatusCode	:= 400 
	EndIf

	If 	lRet
		Self:SetResponse( EncodeUTF8(cResponse) ) 
	Else
		SetRestFault( nStatusCode, EncodeUTF8(cMessage) ) 
	EndIf

Return( lRet ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMM20Stages
Retorna os estagios de um processo de venda.

@param	 cSalesProc	, caracter	, usuario do CRM.

@return aStages		, array		, Array com os estagios de venda.

@author	Anderson Silva
@since		13/12/2016
@version	12.1.15 
/*/
//-------------------------------------------------------------------
Static Function CRMM20Stages( cSalesProc )

	Local aStages 		:= {}
	Local cFilialAc2 	:= ""

	Default cSalesProc := ""

	DBSelectArea("AC2")
	AC2->( DBSetOrder( 1 ) )

	If !Empty( cSalesProc )
		cFilialAc2 	:= xFilial("AC2")
		If AC2->( MSSeek( cFilialAc2 + cSalesProc ) )
			While( AC2->( !Eof() ) .And. AC2->AC2_FILIAL == cFilialAc2 .And.;
			AC2->AC2_PROVEN == cSalesProc )
				aAdd( aStages, {AC2->AC2_STAGE, CRMMText( AC2->AC2_DESCRI ) } )
				AC2->( DBSkip() )
			End
		EndIf
	EndIf

Return( aStages )

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMM20Contacts
Retorna os contatos da Oportunidade de Venda.

@param	 cOportunity	, caracter	, Numero da oportunidade.
cRevision	    , caracter	, Revisao da oportunidade.

@return  aContacts		, array		, Array com os contatos da oportunidade.

@author	 Anderson Silva
@since	 12/12/2017
@version 12.1.18 
/*/
//-------------------------------------------------------------------
Static Function CRMM20Contacts( cOportunity, cRevision )

	Local aContacts 	:= {}
	Local cFilialAd9	:= ""
	Local cFilialSu5	:= ""

	Default cOportunity	:= ""

	DBSelectArea("AD9")
	AD9->( DBSetOrder( 1 ) )

	DBSelectArea("SU5")
	SU5->( DBSetOrder( 1 ) )

	If !Empty( cOportunity )
		cFilialAd9 := xFilial("AD9")
		cFilialSu5 := xFilial("SU5")
		If AD9->( MSSeek( cFilialAd9 + cOportunity + cRevision ) )
			While( AD9->( !Eof() ) .And. AD9->AD9_FILIAL == cFilialAd9 .And.;
			AD9->AD9_NROPOR == cOportunity .And. AD9->AD9_REVISA == cRevision )
				If SU5->( MSSeek(cFilialSu5 + AD9->AD9_CODCON ) )
					If ColumnPos("U5_PRIEMP") > 0
						aAdd( aContacts, { AD9->AD9_CODCON, CRMMText( SU5->U5_CONTAT ), SU5->U5_PRIEMP  } )
					ELSE
						aAdd( aContacts, { AD9->AD9_CODCON, CRMMText( SU5->U5_CONTAT ) } )
					ENDIF
					
					AD9->( DBSkip() )
				EndIf
			End
		EndIf
	EndIf
Return( aContacts )