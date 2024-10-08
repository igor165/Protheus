#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FINI330.CH"

/*/{Protheus.doc} FINI330
Funcao de integracao com o adapter EAI para recebimento de compensacao
de titulos a receber.

@param cXml, Xml passado para a rotina
@param nType, Determina se e uma mensagem a ser enviada/recebida (TRANS_SEND ou TRANS_RECEIVE)
@param cTypeMsg, Tipo de mensagem ( EAI_MESSAGE_WHOIS, EAI_MESSAGE_RESPONSE, EAI_MESSAGE_BUSINESS )

@return lRet, indica se a mensagem foi processada com sucesso
@return cXmlRet, Xml de retorno da funcao

@author TOTVS
@since 11/01/2017
@version 12.1.16
/*/
Function FINI330( cXml, nType, cTypeMessage )
	Local cXmlRet := ''
	Local lRet := .T.
	Local cEvent := ''
	Local cMarca := ''
	Local nValComAut := 0
	Local aCompInt := {}
	Local aAux := {}
	Local cPathBC := "/TOTVSMessage/BusinessMessage/BusinessContent/"
	Local cCodFOF := ""
	Local cFOFTitAdi := ""
	Local cFOFTitRec := ""
	Local cExtSE1Adi := ""
	Local cExtSE1Tit := ""
	Local cExtIdComp := ""
	Local cIntIdComp := ""
	Local aSE1 := {}
	Local aNCC_RA := {}
	Local aEstorno := {}
	Local cChaveTit := ''
	Local cChaveAdi := ''
	Local ckeyTitFK7 := ""

	Private oXmlFIN330 := Nil

	Do Case 
		Case nType == TRANS_SEND
			
			lRet := .F.
			cXmlRet := STR0001 //"Opera��o de envio n�o implementada no Protheus."
			
		Case nType == TRANS_RECEIVE

			If cTypeMessage == EAI_MESSAGE_BUSINESS
				oXmlFIN330 := tXMLManager():New()
				lRet := oXmlFIN330:Parse( cXml )
	
				If lRet
					cEvent := oXmlFIN330:XPathGetNodeValue( "/TOTVSMessage/BusinessMessage/BusinessEvent/Event" )
					cMarca := oXmlFIN330:XPathGetAtt( "/TOTVSMessage/MessageInformation/Product", "name" )
	
					If Upper( cEvent ) == "UPSERT"
												
						cExtIdComp := oXmlFIN330:XPathGetNodeValue( cPathBC + "InternalId" )
						If !Empty( cExtIdComp )							
							aCompInt := F330GetInt( cExtIdComp, cMarca )
							
							//Verifica se o InternalId j� existe e valida para n�o deixar alterar uma compensa��o j� integrada
							If aCompInt[1]
								lRet := .F.
								cXmlRet := STR0013 //"N�o � poss�vel alterar uma compensa��o j� integrada."
							Endif												
						Else
							lRet := .F.
							cXmlRet := STR0010 //"A tag InternalId � obrigat�ria"
						Endif					
						
						If lRet
							//Valor a ser compensado
							nValComAut	:= Val( oXmlFIN330:XPathGetNodeValue( cPathBC + "OffsettingValue" ) )
							
							//----------------------------------
							//Titulo a receber a ser compensado
							//----------------------------------
							cExtSE1Tit := oXmlFIN330:XPathGetNodeValue( cPathBC + "AccountReceivableDocumentInternalId" )							
							If !Empty( cExtSE1Tit )
								aAux := IntTRcInt( cExtSE1Tit, cMarca )
	
								If aAux[1]
									
									cPrefixo := PadR( aAux[2][3], TamSX3("E1_PREFIXO")[1] )
									cNumDoc  := PadR( aAux[2][4], TamSX3("E1_NUM")[1] )
									cParcela := PadR( aAux[2][5], TamSX3("E1_PARCELA")[1] )
									cTipoDoc := PadR( aAux[2][6], TamSX3("E1_TIPO")[1] )
	
									SE1->( DBSetOrder( 1 ) )
									If SE1->( DBSeek( FWxFilial("SE1") + cPrefixo + cNumDoc + cParcela + cTipoDoc ) )	
										
										//Guarda o RECNO do titulo a receber que ser� compensado
										aSE1 := {SE1->( Recno() )}
	
										//Gera a chave do t�tulo (FK7) para armazenar na FOF	
										cChaveTit := xFilial( "SE1", SE1->E1_FILORIG ) + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO	+ "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
										cFOFTitRec := FINGRVFK7( "SE1", cChaveTit )
	
										//Verifica se o titulo tem saldo
										If SE1->E1_SALDO == 0
											lRet := .F.
											cXmlRet := STR0003 //"O titulo para compensa��o n�o possui saldo."
										EndIf
	
										//Verifica se o saldo � maior que o valor a ser compensado
										If nValComAut > 0
											If nValComAut > SE1->E1_SALDO
												lRet := .F.
												cXmlRet := STR0004 //"O valor para compensa��o � superior ao saldo do t�tulo."
											EndIf
										Else
											nValComAut := SE1->E1_SALDO
										EndIf
										
									EndIf
	
								Else
									lRet := .F.
									cXmlRet := STR0005 + AllTrim( cExtSE1Tit ) //"T�tulo n�o encontrado: "
								EndIf
	
							Else
								AAdd( aAux, .F. )
								lRet := .F.
								cXmlRet := STR0006 //"A tag AccountReceivableDocumentInternalId � obrigat�ria"
							EndIf
												
							If lRet
								//---------------------------------
								//Titulo de recebimento antecipado
								//---------------------------------
								cExtSE1Adi := oXmlFIN330:XPathGetNodeValue( cPathBC + "AdvanceInternalId" )
								If !Empty( cExtSE1Adi )
									aAux := IntTRcInt( cExtSE1Adi, cMarca )
		
									If aAux[1]
									
										cPrefixo := PadR(aAux[2][3],TamSX3("E1_PREFIXO")[1])
										cNumDoc  := PadR(aAux[2][4],TamSX3("E1_NUM")[1])
										cParcela := PadR(aAux[2][5],TamSX3("E1_PARCELA")[1])
										cTipoDoc := PadR(aAux[2][6],TamSX3("E1_TIPO")[1])
		
										SE1->( DBSetOrder(1) )
										SE1->( DBSeek( FWxFilial("SE1") + cPrefixo + cNumDoc + cParcela + cTipoDoc ) )
		
										//Guarda o RECNO do titulo RA
										aNCC_RA := {SE1->(Recno())}
		
										//Gera a chave do t�tulo (FK7) para armazenar na FOF									
										cChaveAdi := FWxFilial( "SE1", SE1->E1_FILORIG ) + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO	+ "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
										cFOFTitAdi := FINGRVFK7( "SE1", cChaveAdi )		
									
									Else
									
										lRet := .F.
										cXmlRet := STR0005 + AllTrim( cExtSE1Adi ) //"T�tulo n�o encontrado: "
										
									EndIf
		
								Else
									AAdd( aAux, .F. )
									lRet := .F.
									cXmlRet := STR0007 //"A tag AdvanceInternalId � obrigat�ria."
								EndIf
							EndIf
						
						EndIf
						
						//Grava��o da compensa��o
						If lRet
	
							Begin Transaction
														
							SetFunName("FINI330") //Define o nome da rotina para grava��o do campo FK1_ORIGEM
							cCodFOF:= FWUUIDV4() //Gera o c�digo do processo de compensa��o
							
							//----------------------
							//Realiza a compensacao
							//----------------------
											//  nCaso,aSE1,aBaixa,aNCC_RA,aLiquidacao,aParam                   ,bBlock,aEstorno,aSE1Dados,aNewSE1,nSaldoComp,aCpoUser,aNCC_RAvlr,nSomaCheq,nTaxaCM,aTxMoeda,lConsdAbat,lRetLoja,cProcComp							
							lRet := MaIntBxCR( 3   ,aSE1,      ,aNCC_RA,           ,{.T.,.F.,.F.,.F.,.F.,.F.},      ,        ,         ,       ,nValComAut,        ,          ,         ,       ,        ,          ,        , cCodFOF )
							
							//Grava a tabela de controle de compensacao
							If lRet									
								RecLock( "FOF", .T. )
								FOF->FOF_FILIAL	:= FWxFilial("FOF")
								FOF->FOF_CODIGO	:= cCodFOF
								FOF->FOF_TITADI	:= cFOFTitAdi
								FOF->FOF_TITREC	:= cFOFTitRec
								FOF->FOF_RECPAG	:= "1" //1 = Receber
								FOF->( MSUnlock() )
							Else
								lRet := .F.
								cXMLRet	:= STR0008 //"N�o foi poss�vel compensar o titulo de adiantamento."
								DisarmTransaction()
							EndIf
	
							End Transaction
	
							If lRet
								cExtSE1Adi := F330ComInt( , cCodFOF )
								If !Empty(cExtSE1Adi)
									CFGA070Mnt( cMarca, "FOF", "FOF_CODIGO", cExtIdComp, cExtSE1Adi )
									//Monta xml com status do processamento da rotina automatica OK.
									cXMLRet := "<ListOfInternalId>"
									cXMLRet +=     "<InternalId>"
									cXMLRet +=         "<Name>AccountsReceivableOffsettingInternalId</Name>"
									cXMLRet +=         "<Origin>" + cExtIdComp + "</Origin>" //Valor recebido na tag
									cXMLRet +=         "<Destination>" + cExtSE1Adi + "</Destination>" //Valor XXF gerado
									cXMLRet +=     "</InternalId>"
									cXMLRet += "</ListOfInternalId>"
								EndIf
							EndIf
						EndIf
	
					//----------------------------
					//Cancelamento da Compensacao
					//----------------------------
					ElseIf  Upper( cEvent ) == "DELETE"
						
						cExtIdComp := oXmlFIN330:XPathGetNodeValue( cPathBC + "InternalId" )
	
						If !Empty( cExtIdComp )
							aAux := F330GetInt( cExtIdComp, cMarca )
	
							If aAux[1]
								cCodFOF := PadR( aAux[2][3], TamSX3("FOF_CODIGO")[1] )
	
								cIntIdComp := aAux[3]
	
								FOF->( DBSetOrder( 1 ) )
								If FOF->( DBSeek( FWxFilial("FOF") + cCodFOF ) )
	
									//Pega a chave do titulo a receber
									cChaveTit := FinFK7Key( '', FOF->FOF_TITREC )
									ckeyTitFK7 := FOF->FOF_TITREC
									
								Else
									lRet := .F.
									cXmlRet := STR0009 + AllTrim( cCodFOF ) //"Compensa��o n�o encontrada: "
								EndIf
	
							Else
								lRet := .F.
								cXmlRet := STR0009 + AllTrim( cExtIdComp ) //"Compensa��o n�o encontrada: "
							EndIf
	
						Else
							AAdd( aAux, .F. )
							lRet := .F.
							cXmlRet := STR0010 //"A tag InternalId � obrigat�ria"
						EndIf
	
						If lRet
	
							Begin Transaction
							
							//Posiciona o t�tulo para pegar o recno
							SE1->( DbSetOrder( 1 ) )
							If SE1->( MsSeek( cChaveTit ) )
								aSE1 := {SE1->(Recno())}
							
								//Posiciona a FK1 para pegar o id da baixa e posicionar a SE5 com precis�o, para n�o ter problema com a sequencia da baixa na compensa��o
								FK1->( DbSetOrder( 3 ) ) //FK1_IDCOMP+FK1_IDDOC
								If FK1->( MsSeek( cCodFOF + ckeyTitFK7 ) )
									
									//Posiciona SE5 com base no id da baixa
									SE5->( DbSetOrder( 21 ) ) //E5_FILIAL+E5_IDORIG+E5_TIPODOC
									If SE5->( MsSeek( FWxFilial("SE5") + FK1->FK1_IDFK1 + "CP" ) ) //Considera o tipo de documento, pois pode ter varias E5 com o mesmo id de baixa, por conta dos acrescimos, multas, juros e afins
										
										If !Empty(SE5->E5_DOCUMEN)
		
											aAdd(aEstorno, {{SE5->E5_DOCUMEN},SE5->E5_SEQ})
		
											//-----------------------
											// Cancela a compensacao
											//-----------------------
											//            nCaso,aSE1,aBaixa,aNCC_RA,    aLiquidacao,aParam                   ,bBlock,aEstorno,aSE1Dados,aNewSE1,nSaldoComp,aCpoUser,aNCC_RAvlr,nSomaCheq,nTaxaCM,aTxMoeda,lConsdAbat ,lRetLoja, cProcComp
											If !MaIntBxCR(3    ,aSE1,      ,/*aNCC_RA*/,           ,{.T.,.F.,.F.,.F.,.F.,.F.},      ,aEstorno,         ,       ,          ,        ,          ,         ,       ,        ,           ,        , ) 									
												lRet := .F.
												cXMLRet := STR0011 //"N�o foi poss�vel cancelar a compensa��o."
												DisarmTransaction()
											EndIf
											
										EndIf
										
									Endif 
									
								Endif
							Endif
	
							End Transaction
	
							If lRet
								//Deletar o XXF
								CFGA070Mnt( cMarca, "FOF", "FOF_CODIGO",, AllTrim(cIntIdComp), .T. ) 
							EndIf
							
						EndIf
						
					Else
					
						lRet := .F.
						cXmlRet := STR0012 //"O tipo de opera��o n�o foi informado corretamente na tag Event."
						
					Endif
					
				EndIf
				
			ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS //Informa��o das vers�es compat�veis com a mensagem �nica.
				
				cXMLRet := '2.000'
				
			EndIf
			
	EndCase

	aSize ( aCompInt, 0 )
	aCompInt := Nil
	aSize ( aAux, 0 )
	aAux := Nil
	aSize ( aSE1, 0 )
	aSE1 := Nil
	aSize ( aNCC_RA, 0 )
	aNCC_RA := Nil
	aSize ( aEstorno, 0 )
	aEstorno := Nil	
Return { lRet, cXmlRet, "ACCOUNTSRECEIVABLEOFFSETTING" }

/*/{Protheus.doc} F330ComInt
Funcao para montagemn do internalId de compensa��o

@param cIntFil, Filial da compensa��o
@param cCodigo, C�digo da compensa��o

@return cRetCode, InternalId da compensa��o

@author TOTVS
@since 11/01/2017
@version 12.1.16
/*/
Function F330ComInt( cIntFil, cCodigo )
	Local cRetCode := ''

	Default cIntFil := xFilial('SE5')

	cIntFil	:= XFilial( "FOF", cIntFil )

	cRetCode := cEmpAnt + '|' + RTrim(cIntFil) + '|' + RTrim(cCodigo)
Return cRetCode

/*/{Protheus.doc} F330GetInt
Funcao para encontrar a compensa��o no protheus atrav�s de um externalid informado

@param cCodigo, ExternalId da compensa��o
@param cMarca, Produto/marca da qual a informa��o est� sendo originada 

@return aRetorno, Vetor com o c�digo de compensa��o do protheus

@author TOTVS
@since 11/01/2017
@version 12.1.16
/*/
Function F330GetInt( cCodigo, cMarca )
	Local cValInt := ''
	Local aRetorno := {}
	Local aAux := {}
	Local nX := 0
	Local aCampos := {cEmpAnt, 'FOF_FILIAL', 'FOF_CODIGO'}

	cValInt := CFGA070Int( cMarca, 'FOF', 'FOF_CODIGO', cCodigo )
	If !Empty(cValInt)
		aAux := Separa( cValInt, '|' )

		aAdd( aRetorno, .T. )
		aAdd( aRetorno, aAux )
		aAdd( aRetorno, cValInt )

		aRetorno[2][1] := Padr( aRetorno[2][1], Len(cEmpAnt) )

		For nX := 2 to Len( aRetorno[2] ) //corrigindo  o tamanho dos campos
			aRetorno[2][nX] := Padr( aRetorno[2][nX], TamSX3(aCampos[nx])[1] )
		Next nX
	Else
		aAdd( aRetorno, .F. )
	EndIf
Return aRetorno

