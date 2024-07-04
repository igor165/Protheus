#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "MATI030.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATI030O   ºAutor  ³Totvs Cascavel     º Data ³  23/05/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao de integracao com o adapter EAI para recebimento e  º±±
±±º          ³ envio de informações do cadastro de Clientes (SA1)         º±±
±±º          ³ utilizando o conceito de mensagem unica JSON.        	  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATI030O                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATI030O( oEAIObEt, nTypeTrans, cTypeMessage )
	Local nX          	:= 0
	Local nCount		:= 0
	Local cValGov     	:= 0
	Local cTypeReg		:= 1
	Local nOpcx			:= 3
	Local lHotel      	:= SuperGetMV( "MV_INTHTL", , .F. )
	Local lRet        	:= .T.
	Local lGetXnum    	:= .F.
	Local lIniPadCod  	:= .F.
	Local cRotina  		:= IIF(MA030IsMVC(),"CRMA980","MATA030")
	Local cAlias      	:= "SA1"
	Local cField      	:= "A1_COD"
	Local cOwnerMsg		:= "CUSTOMERVENDOR"
	Local cEvent       	:= "upsert"
	Local cFilSA1 		:= FWxFilial("SA1")
	Local cMarca      	:= ""
	Local cValInt     	:= ""
	Local cValExt     	:= ""
	Local cCode       	:= ""
	Local cStore      	:= ""
	Local cLograd     	:= ""
	Local cNumero     	:= ""
	Local cCodEst     	:= ""
	Local cCodEstE    	:= ""
	Local cCodMun     	:= ""
	Local cCodMunE    	:= ""
	Local cPais  		:= ""
	Local cCodPais     	:= ""
	Local cEst   		:= ""
	Local cTel        	:= ""
	Local cTipoCli		:= ""
	Local cIniCli		:= ""
	Local cIniLoj		:= ""
	Local aRet        	:= {}
	Local aCliente    	:= {}
	Local aAux         	:= {}
	Local aAreaCCH		:= {}
	Local cEndEnt		:= ""
	Local cPaisCode   	:= ""
	Local cLogErro		:= ""
	Local oModel 		:= Nil
	Local ofwEAIObj		:= FWEAIobj():NEW()
	Local oMsgError		:= ""
	Local cProduct		:= ""
	Local cCNPJCPF		:= ""
	Local cTipoRG		:= ""
	Local cRG			:= ""
	Local lPFisica		:= .F.
	Local cRegionExtId  := ''
	Local cRegionCode   := ''
	Local cRegion       := ''
	Local cSegExtId     := ''
	Local cSegCode      := ''
	Local cSeg          := ''
	Local cFreightType  := ''
	Local oAddressRegion:= Nil
	Local cCarrExtId    := ''
	Local cCarrCode     := ''
	Local cCarrier      := ''
	Local cVendExtId    := ''
	Local cVendCode     := ''
	Local lExistCli		:= .F.

	Local cDatVenLim    := ''
	Local cTaxpayer     := ''
	Local cJson         := ''
	Local lNewLjCli 	:= .F.
	Local aRetCli   	:= {}
	Local lIntVetex		:= I030IsInteg()
	Local bRotAut       := { || IIf( MA030IsMVC() , MSExecAuto({|x, y| CRMA980(x, y)}, aCliente, nOpcx), MSExecAuto({|x, y| MATA030(x, y)}, aCliente, nOpcx) ) }

	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private lMsHelpAuto    := .T.

   	//--------------------------------------
	//recebimento mensagem
	//--------------------------------------
	If nTypeTrans == TRANS_RECEIVE .And. ValType( oEAIObEt ) == 'O' 
		
		//--------------------------------------
		//chegada de mensagem de negocios
		//--------------------------------------
		If cTypeMessage == EAI_MESSAGE_BUSINESS
			
			//Ajustado para receber o Type conforme documentacao API Totvs
			//Tipo do Registro: Customer Cliente, Vendor Fornecedor, Both Ambos
			//Identifica se o emitente é apenas Cliente, apenas Fornecedor ou Ambos 
			//1 – Cliente  
			//2 – Fornecedor 
			//3 – Ambos 
			Do Case
				Case VALTYPE(oEAIObEt:getPropValue("Type")) == "N" .AND. oEAIObEt:getPropValue("Type") == 1 .OR.; 
					 VALTYPE(oEAIObEt:getPropValue("Type")) == "C" .AND. oEAIObEt:getPropValue("Type") == "CUSTOMER"  //Cliente
					cTypeReg := "CUSTOMER"
				Case VALTYPE(oEAIObEt:getPropValue("Type")) == "N" .AND. oEAIObEt:getPropValue("Type") == 2 .OR.;
					 VALTYPE(oEAIObEt:getPropValue("Type")) == "C" .AND. oEAIObEt:getPropValue("Type") == "VENDOR" //Fornecedor
					cTypeReg := "VENDOR"
				Case VALTYPE(oEAIObEt:getPropValue("Type")) == "N" .AND. oEAIObEt:getPropValue("Type") == 3 .OR.;
					 VALTYPE(oEAIObEt:getPropValue("Type")) == "C" .AND. oEAIObEt:getPropValue("Type") == "BOTH" //Ambos
					cTypeReg := "BOTH"
				Otherwise
					lRet := .F.
					cLogErro := "Tipo de emitente fora de lista de valores (1=CUSTOMER,2=VENDOR,3=BOTH)" + CRLF
			Endcase	

			If lRet .And. (cTypeReg == "VENDOR"  .or. cTypeReg == "BOTH" ) 
			
				aRet := FWIntegDef("MATA020", cTypeMessage, nTypeTrans, oEAIObEt)
				
				If ValType(aRet) == "A"
					If !Empty(aRet)
						If cTypeReg == "VENDOR"
							lRet := aRet[1]
							ofwEAIObj := aRet[2]
						Else
							lRet := aRet[1]
							cLogErro := aRet[1][2] + CRLF
						Endif
					EndIf
				Endif			
			Endif

			If lRet
				If cTypeReg == "CUSTOMER" .Or. cTypeReg == "BOTH"
					cEvent := oEAIObEt:getHeaderValue("Event")
					If !Upper(RTrim(cEvent)) $ "UPSERT|REQUEST|DELETE" 
						lRet := .F.
						cLogErro := STR0014 + CRLF // "O evento informado é inválido!"	
					EndIf
					// Obtém a marca
					If oEAIObEt:getHeaderValue("ProductName") !=  Nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )
						cMarca :=  oEAIObEt:getHeaderValue("ProductName")
					Else
						lRet := .F.						
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0010 // "Product é obrigatório!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)														
					EndIf
				
					// Obtém o Valor externo
					If oEAIObEt:getPropValue("InternalId") != nil  .And. !Empty( oEAIObEt:getPropValue("InternalId") )
						cValExt := oEAIObEt:getPropValue("InternalId")
					Else
						lRet := .F.							
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0011 // "InternalId é obrigatório!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)														
					EndIf
		
					//Obtém o code
					If oEAIObEt:getPropValue("Code") != nil .And. !Empty( oEAIObEt:getPropValue("Code") )
						cCode := oEAIObEt:getPropValue("Code")
					Else
						//Se for integração com hotelaria, irá gerar um código sequencial ou considerar o inicializador padrão do campo código
						If !lHotel .And. !lIntVetex
							lRet := .F.							
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0012 // "Code é obrigatório!"
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)															
						Endif
					EndIf
					//Obtém a loja
					If oEAIObEt:getPropValue("StoreId") != nil 
						cStore := oEAIObEt:getPropValue("StoreId")
					EndIf
					
					//Obtém o valor interno
					aAux := IntCliInt(cValExt, cMarca)

					//Verifica se o cliente existe na Base, pois em casos onde um registro
					//é excluído após a integração o sistema não consegue importar novamente.
					dbSelectArea("SA1")
					SA1->( dbSetOrder( 1 ) )

					// Se o evento é Upsert
					cEvent := AllTrim( oEAIObEt:getHeaderValue("Event") )
					If ( Upper(cEvent) == "UPSERT" ) .Or. ( Upper(cEvent) == "REQUEST" )
						// Se o registro existe
						If Len( aAux ) > 0 
							If SA1->(MSSeek(cFilSA1+PADR(AAUX[2][3],LEN(SA1->A1_COD))+ PADR(AAUX[2][4],LEN(SA1->A1_LOJA))))
								If !( lIntVetex )
									nOpcx := 4
								Else
									//Verifica se os Enderecos Informados, Via Integracao, Já Estão Cadastrados na Base
									aRetCli   := I030SrcCli( oEAIObEt, SA1->A1_COD, SA1->A1_LOJA, 'JSON' )
									lNewLjCli := aRetCli[3]
									cCode 	  := IIf( Empty( aRetCli[ 1 ] ), AAUX[2][3], aRetCli[ 1 ] )
									cStore	  := IIf( Empty( aRetCli[ 2 ] ), AAUX[2][4], aRetCli[ 2 ] )
									Iif(!Empty(cCode),lExistCli := .T.,)	
									cValInt   := IntCliExt(, , cCode, cStore )[2]
									nOpcx 	  := IIf( lNewLjCli, 3, 4 )
									aAux	  := {}
								EndIf
							Else
								nOpcx := 3 // Incluir
							EndIf
						EndIf
					// Se o evento é Delete
					ElseIf ( Upper(cEvent) == "DELETE" ) 
						// Se o registro existe
						If Len( aAux ) > 0 
							If ( !lIntVetex )
								nOpcx := 5 // Delete
							Else
								If SA1->( MSSeek(cFilSA1+PADR(AAUX[2][3],LEN(SA1->A1_COD))+ PADR(AAUX[2][4],LEN(SA1->A1_LOJA))))
									nOpcx 	:= 5
									//Verifica se os Enderecos Informados, Via Integracao, Já Estão Cadastrados na Base
									aRetCli := I030SrcCli( oEAIObEt, SA1->A1_COD, SA1->A1_LOJA, 'JSON' )
									
									cCode 	:= IIf( Empty( aRetCli[ 1 ] ), AAUX[2][3], aRetCli[ 1 ] )
									cStore	:= IIf( Empty( aRetCli[ 2 ] ), AAUX[2][4], aRetCli[ 2 ] )
									cValInt := IntCliExt(, , cCode, cStore )[2]
									aAux	:= {}

								EndIf
							EndIf
						Else
							lRet := .F.
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0013 + " -> " + cValExt // "O registro a ser excluído não existe na base Protheus!"
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)															
						EndIf
					Else
						lRet := .F.						
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0014 // "O evento informado é inválido!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)															
					EndIf
		
					// Se é Insert
					If nOpcx == 3
						If Alltrim(cMarca)=="HIS"
							SA1->( dbSetOrder( 1 ) )
							If MsSeek( cFilSA1 + PadR(cCode, TamSX3("A1_COD")[1]) + PadR(cStore, TamSX3("A1_LOJA")[1] ) )
								nOpcx := 4
								aAdd(aCliente, {"A1_COD",  cCode, Nil})  // Código
								aAdd(aCliente, {"A1_LOJA", cStore, Nil}) // Loja
							Else
								cIniCli := GetSx3Cache("A1_COD","X3_RELACAO")
								cIniLoj := GetSx3Cache("A1_LOJA","X3_RELACAO")
								
								// Se não há inicializador padrão ou se A030INICPD esta contido, pois
								// este inicializador padrão é utilizado apenas pela RM					   
								If Empty(cIniCli) .Or. "A030INICPD" $ cIniCli
									aAdd(aCliente, {"A1_COD",  cCode, Nil})  // Código
								EndIf
							
								If Empty(cIniLoj)
									aAdd(aCliente, {"A1_LOJA", cStore, Nil}) // Loja
								EndIf
							EndIf
						Else
							
							If !lExistCli //se cliente já existe não execura inicializador padrão
								cFormula := GetSx3Cache("A1_COD","X3_RELACAO")
								lIniPadCod := !Empty(cFormula) .And. !( "A030INICPD" $ cFormula )
							EndIf	
							If !lIniPadCod
								//Se for integração com hotelaria, gera um código sequencial (pode ser alterada a lógica através de incializador padrão)
								If lHotel
									cCode := I30ProxNum()
								Else
									cCode := MATI030Num(cCode,@lGetXnum)
								EndIf
		
								aAdd(aCliente, {"A1_COD",  cCode, Nil})  // Código
							EndIf
					
							If Empty(GetSx3Cache("A1_LOJA","X3_RELACAO"))
								//Se for integração com hotelaria, fixa a loja como "00" (pode ser alterada a lógica através de incializador padrão) 
								If lHotel .Or. Empty(cStore)
									cStore := PadL(cStore,TamSX3("A1_LOJA")[1],"0")
								Endif
		
								aAdd(aCliente, {"A1_LOJA", cStore, Nil}) // Loja
							EndIf
						EndIf
					Else
						If !( lIntVetex )
							cValInt := IntCliExt(, , aAux[2][3], aAux[2][4] )[2]
							aAdd(aCliente, {"A1_COD" , PadR(aAux[2][3], TamSX3("A1_COD")[1]) , Nil}) // Código
							aAdd(aCliente, {"A1_LOJA", PadR(aAux[2][4], TamSX3("A1_LOJA")[1]), Nil}) // Loja
						Else
							aAdd(aCliente, {"A1_COD" , PadR(cCode , TamSX3("A1_COD")[1]) , Nil}) // Código
							aAdd(aCliente, {"A1_LOJA", PadR(cStore, TamSX3("A1_LOJA")[1]), Nil}) // Loja						
						EndIf
					EndIf
		
					If nOpcx # 5
						// Obtém o Nome ou Razão Social
						If oEAIObEt:getPropValue("Name") != nil .And. !Empty( oEAIObEt:getPropValue("Name") )
							aAdd(aCliente, {"A1_NOME", (UPPER(AllTrim(oEAIObEt:getPropValue("Name")))), Nil})
						Else
							lRet := .F.							
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0015 // "O nome é obrigatório!"
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)																
						EndIf
		
						// Obtém o Nome de Fantasia
						If oEAIObEt:getPropValue("ShortName") != nil .And. !Empty( oEAIObEt:getPropValue("ShortName") ) 
							aAdd(aCliente, {"A1_NREDUZ", (UPPER(AllTrim(oEAIObEt:getPropValue("ShortName")))), Nil})
						Else
							lRet := .F.								
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0016 // "O nome reduzido é obrigatório!"
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)																
						EndIf
		
						// Obtém Pessoa/Tipo
						If oEAIObEt:getPropValue("EntityType") != nil .And. !Empty( oEAIObEt:getPropValue("EntityType") )
							
							//Ajustado para receber o campo EntityType conforme documentacao API Totvs
							//Identifica se o emitente é Pessoa Física, Jurídica, Estrangeiro ou Trading 
							//1 – Pessoa Física 
							//2 – Pessoa Jurídica 
							//3 – Estrangeiro 
							//4 – Trading
							
							If VALTYPE(oEAIObEt:getPropValue("EntityType")) == "N" .And. oEAIObEt:getPropValue("EntityType") == 1 .Or.; 
								VALTYPE(oEAIObEt:getPropValue("EntityType")) == "C" .And. oEAIObEt:getPropValue("EntityType") == "PERSON"//"PERSON"
								aAdd(aCliente, {"A1_PESSOA", "F", Nil}) // Pessoa Física
						
							ElseIf VALTYPE(oEAIObEt:getPropValue("EntityType")) == "N" .And. oEAIObEt:getPropValue("EntityType") == 2 .Or.; 
								VALTYPE(oEAIObEt:getPropValue("EntityType")) == "C" .And. oEAIObEt:getPropValue("EntityType") == "COMPANY" //"COMPANY"
								aAdd(aCliente, {"A1_PESSOA", "J", Nil}) // Pessoa Jurídica
							EndIf
						
							If cPaisLoc <> 'BRA'
								aAdd(aCliente, {"A1_TIPO", "1", Nil})
							Else
								If oEAIObEt:getPropValue("StrategicCustomerType") != nil
									cTipoCli := oEAIObEt:getPropValue("StrategicCustomerType")
									
									//Trata o tipo de cliente considerando o formato esperado no Protheus para gravação desse dado
									If cTipoCli == "1"
										cTipoCli := "F"
									Elseif cTipoCli == "2"
										cTipoCli := "L"
									Elseif cTipoCli == "3"
										cTipoCli := "R"
									Elseif cTipoCli == "4"
										cTipoCli := "S"
									Elseif cTipoCli == "5"
										cTipoCli := "X"
									Endif
									
									aAdd( aCliente, {"A1_TIPO", cTipoCli, Nil} )
								Else
									aAdd( aCliente, {"A1_TIPO", "F", Nil} ) //Consumidor Final
								Endif
							EndIf 
						Else
							lRet := .F.							
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0017 // "O tipo do cliente é obrigatório"
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)																
						EndIf

						If oEAIObEt:getPropValue("Address") != nil .And. !Empty( oEAIObEt:getpropvalue("Address") )
							// Obtém o Número do Endereço do Cliente						
							If oEAIObEt:getPropValue("Address"):getPropValue("Number") != nil   
								aAdd(aCliente, {"A1_END", (UPPER(AllTrim(oEAIObEt:getPropValue("Address"):getPropValue("Address")))) + ", " + UPPER(oEAIObEt:getPropValue("Address"):getPropValue("Number")), Nil})
							Else
								aAdd(aCliente, {"A1_END", (UPPER(AllTrim(oEAIObEt:getPropValue("Address"):getPropValue("Address")))), Nil})
							EndIf

							// Obtém o Complemento do Endereço
							If oEAIObEt:getPropValue("Address"):getPropValue("Complement") != nil  
								aAdd(aCliente, {"A1_COMPLEM", (UPPER(oEAIObEt:getPropValue("Address"):getPropValue("Complement"))), Nil})
							EndIf

							// Obtém o Bairro do Cliente
							If oEAIObEt:getPropValue("Address"):getPropValue("District") != nil  
								aAdd(aCliente, {"A1_BAIRRO", (UPPER(oEAIObEt:getPropValue("Address"):getPropValue("District"))), Nil})
							EndIf						

							// Obtém o Cod Endereçamento Postal
							If oEAIObEt:getPropValue("Address"):getPropValue("ZIPCode") != nil 
								aAdd(aCliente, {"A1_CEP", oEAIObEt:getPropValue("Address"):getPropValue("ZIPCode"), Nil})
							EndIf

							// Obtém a Caixa Postal
							If oEAIObEt:getPropValue("Address"):getPropValue("POBox") != nil 
								aAdd(aCliente, {"A1_CXPOSTA", oEAIObEt:getPropValue("Address"):getPropValue("POBox"), Nil})
							EndIf

							//Obtém o código de Pais do Cliente, no padrão BACEN, através da descrição recebida (Exemplo: Brasil = 01058)
							If cPaisLoc == 'BRA' .Or. cPaisLoc == 'ARG'//Paises que utilizam a tabela CCH
								If oEAIObEt:getPropValue("Address"):getPropValue("Country") != NIL .AND. oEAIObEt:getPropValue("Address"):getPropValue("Country"):getPropValue("CountryDescription") != nil 
									cPais := AllTrim((Upper(oEAIObEt:getPropValue("Address"):getPropValue("Country"):getPropValue("CountryDescription"))))
									//Tratativa para considerar o nome do pais "BRAZIL"
									If cPaisLoc == "BRA"
										If cPais == "BRAZIL"
											cPais := "BRASIL"
										EndIf
									EndIf
									
									aAreaCCH := CCH->( GetArea() )
									cCodPais := PadR( Posicione( "CCH", 2, FWxFilial("CCH") + PadR( cPais, TamSx3("CCH_PAIS")[1] ), "CCH_CODIGO" ), TamSx3("A1_CODPAIS")[1] )
								
									CCH->( RestArea( aAreaCCH ) )
									If ! Empty( cCodPais )
										aAdd( aCliente, { "A1_CODPAIS", cCodPais, Nil } )
									EndIf
								EndIf
							EndIf
						
							//Obtém o Pais do Cliente pelo código (padrão SISCOMEX)
							If oEAIObEt:getPropValue("Address"):getPropValue("Country") != NIL .and. oEAIObEt:getPropValue("Address"):getPropValue("Country"):getPropValue("CountryCode") != nil 
								cPaisCode := oEAIObEt:getPropValue("Address"):getPropValue("Country"):getPropValue("CountryCode")
								cPaisCode := PadR( cPais, GetSX3Cache("A1_PAIS","X3_TAMANHO") )
							EndIf
						
							//Busca o país por código ou descrição
							cPaisCode := MATI30Pais(cPaisCode, cPais, cMarca)
							
						
							If !Empty(cPaisCode)
								aAdd(aCliente, {"A1_PAIS", cPaisCode, Nil})
								If cPaisCode <> A2030PALOC("SA1",1)
									cEst := "EX"
								Endif
							Else
								If !Empty(cPais) .And. cPais <> A2030PALOC("SA1",2)
									cEst := "EX"
								Endif
							EndIf

							// Obtém a Sigla da Federação
							If oEAIObEt:getPropValue("Address"):getPropValue("State") != NIL .AND. oEAIObEt:getPropValue("Address"):getPropValue("State"):getPropValue("StateCode") != nil 
								If Empty(cEst)
									cEst := AllTrim(Upper(oEAIObEt:getPropValue("Address"):getPropValue("State"):getPropValue("StateCode")))
								Endif
								aAdd(aCliente, {"A1_EST", cEst, Nil})
							Else
								lRet := .F.								
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0019 // "O estado é obrigatório"
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)																	
							EndIf

							If oEAIObEt:getPropValue("Address"):getPropValue("City") != Nil 

								// Obtém a descrição do Município do Cliente							
								If oEAIObEt:getPropValue("Address"):getPropValue("City"):getPropValue("CityDescription") != nil 
									aAdd(aCliente, {"A1_MUN", (UPPER(oEAIObEt:getPropValue("Address"):getPropValue("City"):getPropValue("CityDescription"))), Nil})
								Else
									lRet := .F.							
									ofwEAIObj:Activate()
									ofwEAIObj:setProp("ReturnContent")
									cLogErro := STR0020 // "A descrição do município é obrigatória"
									ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)																
								EndIf

								// Obtém o Código do Município
								If oEAIObEt:getPropValue("Address"):getPropValue("City"):getPropValue("CityCode") != nil 
									aAdd(aCliente, {"A1_COD_MUN", Right(oEAIObEt:getPropValue("Address"):getPropValue("City"):getPropValue("CityCode"), 5), Nil})
								EndIf

							Else
								lRet := .F.							
								ofwEAIObj:Activate()
								ofwEAIObj:setProp("ReturnContent")
								cLogErro := STR0020 // "A descrição do município é obrigatória"
								ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)	
							Endif

							If oEAIObEt:getPropValue("Address"):getPropValue("Region") != Nil
								//Verifica se existe o código do CustomerRegionInternalId, chave extrangeria para código de região
								If oEAIObEt:getPropValue("Address"):getPropValue("Region"):getPropValue("RegionInternalId") != nil  
									cRegionExtId := Alltrim(oEAIObEt:getPropValue("Address"):getPropValue("Region"):getPropValue("RegionInternalId"))
								EndIf
								//Verifica se existe o código do CustomerRegionCode, chave local do Protheus para Região, exemplo: 006-Região Norte
								If oEAIObEt:getPropValue("Address"):getPropValue("Region"):getPropValue("RegionCode") != nil  
									cRegionCode := Alltrim(oEAIObEt:getPropValue("Address"):getPropValue("Region"):getPropValue("RegionCode"))
								EndIf								
							
								cRegion := Mati30Regi(cRegionExtId, cRegionCode, cMarca)
								If !Empty(cRegion)
									aAdd(aCliente, { "A1_REGIAO", cRegion, Nil} )
								Endif
							Endif

						Else
							lRet := .F.							
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							cLogErro := STR0018 // "O Endereço é obrigatório"
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)																
						EndIf

						If oEAIObEt:getPropValue("Segment") != nil 
							oTaxes := oEAIObEt:getPropValue("Segment")
							For nX := 1 To Len( oTaxes )
								If oTaxes[nX]:getPropValue("Name") != nil 
									If oTaxes[nX]:getPropValue("InternalId") != nil 
										cSegExtId := oTaxes[nX]:getPropValue("InternalId")
									Endif	
									If oTaxes[nX]:getPropValue("CodeERP") != nil 
										cSegCode  := oTaxes[nX]:getPropValue("CodeERP")
									Endif
									cSeg      := Mati30Seg(cSegExtId, cSegCode, cMarca) // Função retorna o código do segmento no Protheus, SX5, tabela T3.
									If Empty(cSeg)
										Loop
									Endif

									If RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "SEGMENT1"
										aAdd(aCliente, {"A1_SATIV1", cSeg, Nil})
									ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "SEGMENT2"
										aAdd(aCliente, {"A1_SATIV2", cSeg, Nil})
									ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "SEGMENT3"
										aAdd(aCliente, {"A1_SATIV3", cSeg, Nil})
									ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "SEGMENT4"
										aAdd(aCliente, {"A1_SATIV4", cSeg, Nil})
									ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "SEGMENT5"
										aAdd(aCliente, {"A1_SATIV5", cSeg, Nil})
									ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "SEGMENT6"
										aAdd(aCliente, {"A1_SATIV6", cSeg, Nil})
									ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "SEGMENT7"
										aAdd(aCliente, {"A1_SATIV7", cSeg, Nil})
									ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "SEGMENT8"
										aAdd(aCliente, {"A1_SATIV8", cSeg, Nil})
									EndIf
								
								Endif
							Next nX
						Endif

						If oEAIObEt:getPropValue("FreightType") != nil .And. !Empty( oEAIObEt:getpropvalue("FreightType") )

							// Obtém o codigo do tipo de frete
							If oEAIObEt:getPropValue("FreightType"):getPropValue("Code") != nil  
								cFreightType := Alltrim(Upper(oEAIObEt:getPropValue("FreightType"):getPropValue("Code")))
								If cFreightType $ 'CFTRDS' // C=CIF;F=FOB;T=Por conta terceiros;R=Por conta remetente;D=Por conta destinatário;S=Sem frete
									aAdd(aCliente, {"A1_TPFRET", cFreightType, Nil})
								Endif	
							EndIf
						Endif

						// Obtém o codigo da tranportadora
						If oEAIObEt:getPropValue("Carrier") != nil 
							If oEAIObEt:getPropValue("Carrier"):getPropValue("InternalId") != nil  
								cCarrExtId := Alltrim(Upper(oEAIObEt:getPropValue("Carrier"):getPropValue("InternalId")))
							EndIf
							If oEAIObEt:getPropValue("Carrier"):getPropValue("CodeERP") != nil  
								cCarrCode := Alltrim(Upper(oEAIObEt:getPropValue("Carrier"):getPropValue("CodeERP")))
							EndIf
							cCarrier := Mati30Car(cCarrExtId, cCarrCode, cMarca)
							If !Empty(cCarrier) 
								aAdd(aCliente, {"A1_TRANSP", cCarrier, Nil})
							Endif	
						Endif

						// Limite de Crédito / Vencimento
						If oEAIObEt:getPropValue("CreditInformation") != nil 
							If oEAIObEt:getPropValue("CreditInformation"):getPropValue("MaturityCreditLimit") != nil	
								cDatVenLim := oEAIObEt:getPropValue("CreditInformation"):getPropValue("MaturityCreditLimit")
								If !Empty(cDatVenLim)
									aAdd(aCliente, {"A1_VENCLC", cTod(SubStr(cDatVenLim, 9, 2) + "/" + SubStr(cDatVenLim, 6, 2 ) + "/" + SubStr(cDatVenLim, 1, 4 )), Nil})
								Endif	
							Endif
						EndIf
						// Informa se o clinete é contribuinte do icms, sendo 1=Sim;2=Não
						If oEAIObEt:getPropValue("Taxpayer") != nil 
							cTaxpayer := oEAIObEt:getPropValue("Taxpayer")
							If cTaxpayer $ ('1/2')
								aAdd(aCliente, {"A1_CONTRIB", cTaxpayer, Nil})
							Endif
						EndIf
						
						If  oEAIObEt:getPropValue("VendorInformation") != nil .and. oEAIObEt:getPropValue("VendorInformation"):getPropValue("VendorType") != nil 
   						    
							If oEAIObEt:getPropValue("VendorInformation"):getPropValue("VendorType"):getPropValue("VendorInformationInternalID") != nil
								cVendExtId := oEAIObEt:getPropValue("VendorInformation"):getPropValue("VendorType"):getPropValue("VendorInformationInternalID")
							Endif
							
							If !Empty(cVendExtId)
								cVendCode := Int030Vend(cVendExtId,cMarca)
							Else
								If oEAIObEt:getPropValue("VendorInformation"):getPropValue("VendorType"):getPropValue("Code") != nil
									cVendCode  := oEAIObEt:getPropValue("VendorInformation"):getPropValue("VendorType"):getPropValue("Code")
								Endif	
							Endif

							If !Empty(cVendCode)
								SA3->(dbSetOrder(1))
								If SA3->(dbSeek(xFilial("SA3") + cVendCode))
									aAdd(aCliente, {"A1_VEND", cVendCode, Nil})
								Endif
							Endif
						Endif
	
						// Obtém Inscrição Estadual/Inscrição Municipal/CNPJ/CPF do Fornecedor
						If oEAIObEt:getPropValue("GovernmentalInformation") != nil
							oTaxes := oEAIObEt:getPropValue("GovernmentalInformation")
							
							If cPaisLoc $ "BRA"
								For nX := 1 To Len( oTaxes )
									If oTaxes[nX]:getPropValue("Name") != nil
										cValGov := oTaxes[nX]:getPropValue("Id")
										
										If RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "INSCRICAO ESTADUAL"
											aAdd(aCliente, {"A1_INSCR", cValGov, Nil})
										ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "INSCRICAO MUNICIPAL"
											aAdd(aCliente, {"A1_INSCRM", cValGov, Nil})
										ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) $ "CPF/CNPJ"
											aAdd(aCliente, {"A1_CGC", cValGov, Nil})
										ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "SUFRAMA"
											aAdd(aCliente, {"A1_SUFRAMA", cValGov, Nil})
										ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "PASSAPORTE" .AND. cPaisLoc == "BRA"
											aAdd(aCliente, {"A1_PFISICA", cValGov, Nil})
										ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "RG" .AND. cPaisLoc == "BRA"
											aAdd(aCliente, {"A1_PFISICA", cValGov, Nil})
											aAdd(aCliente, {"A1_RG", cValGov, Nil})
										ElseIf RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) == "INSCRICAO RURAL"
											aAdd(aCliente, {"A1_INSCRUR", cValGov, Nil})
										EndIf
									
									Endif
								Next nX

							Else
								cCNPJCPF := AllTrim(FWX3Titulo( "A1_CGC" )) 
								For nX := 1 To Len( oTaxes )
									If oTaxes[nX]:getPropValue("Name") != nil
										cValGov := oTaxes[nX]:getPropValue("Id")
								
										If RTrim(Upper(oTaxes[nX]:getPropValue("Name"))) $ cCNPJCPF 
											aAdd(aCliente, {"A1_CGC", cValGov, Nil})
										EndIf
									
									Endif
								Next nX	
							EndIf
						EndIf
						
						If oEAIObEt:getPropValue("ListOfCommunicationInformation") != nil 
							oLtOfCom := oEAIObEt:getPropValue("ListOfCommunicationInformation")				
							If (oLtOfCom[Len(oLtOfCom)]:getpropvalue('PhoneNumber') != nil)
								cStringTemp:= RemCharEsp(oLtOfCom[Len(oLtOfCom)]:getpropvalue('PhoneNumber'))							
								aTelefone := RemDddTel(cStringTemp)							
								aAdd(aCliente, {"A1_TEL",aTelefone[1], Nil})

								// Obtém o Número do Telefone
								If !Empty(aTelefone[2])
									If Len(AllTrim(aTelefone[2])) == 2
										aTelefone[2] := "0" + aTelefone[2]
									Endif
									aAdd(aCliente, {"A1_DDD",aTelefone[2], Nil})
								Elseif ( oLtOfCom[Len(oLtOfCom)]:getpropvalue('DiallingCode') != nil  )
									cStringTemp:= RemCharEsp(oLtOfCom[Len(oLtOfCom)]:getpropvalue('DiallingCode'))
									aTelefone[2] := "0" + allTrim(cStringTemp)
									aAdd(aCliente, {"A1_DDD",aTelefone[2], Nil})
								EndIf
			
								If !Empty(aTelefone[3])
									aAdd(aCliente, {"A1_DDI",aTelefone[3], Nil})
								ElseIF ( oLtOfCom[Len(oLtOfCom)]:getpropvalue('InternationalDiallingCode') != nil )
									cStringTemp:= RemCharEsp(oLtOfCom[Len(oLtOfCom)]:getpropvalue('InternationalDiallingCode'))
									aTelefone[3] := allTrim(cStringTemp)
									aAdd(aCliente, {"A1_DDI",aTelefone[3], Nil})
								EndIf
							EndIf
							// Obtém o E-Mail
							If oLtOfCom[Len(oLtOfCom)]:getpropvalue('Email') != nil 
								aAdd(aCliente, {"A1_EMAIL", oLtOfCom[Len(oLtOfCom)]:getpropvalue('Email'), Nil})
							Endif

							// Obtém o Número do Fax do Cliente.
							If oLtOfCom[Len(oLtOfCom)]:getpropvalue('FaxNumber') != nil 
								cStringTemp:= RemCharEsp(oLtOfCom[Len(oLtOfCom)]:getpropvalue('FaxNumber'))
								aTelefone := RemDddTel(cStringTemp)								
								Aadd( aCliente, { "A1_FAX",aTelefone[1],   Nil })
							Endif

							// Obtém a Home-Page
							If oLtOfCom[Len(oLtOfCom)]:getpropvalue('HomePage') != nil 
								aAdd(aCliente, {"A1_HPAGE", oLtOfCom[Len(oLtOfCom)]:getpropvalue('HomePage'), Nil}) // Home-Page
							Endif
						EndIf
		
						// Obtém o Contato na Empresa
						If oEAIObEt:getPropValue("ListOfContacts") != nil 
							oLtOfCont := oEAIObEt:getPropValue("ListOfContacts")
							If oLtOfCont[Len(oLtOfCont)]:getpropvalue('ContactInformationName') != nil
								aAdd(aCliente, {"A1_CONTATO", (oLtOfCont[Len(oLtOfCont)]:getpropvalue('ContactInformationName')), Nil})
							Endif
						EndIf
		
						// Obtém Bloqueia o Cliente?
						If oEAIObEt:getPropValue("RegisterSituation") != nil 
							If Upper(oEAIObEt:getPropValue("RegisterSituation")) == "ACTIVE"
								aAdd(aCliente, {"A1_MSBLQL", "2", Nil})
							Else
								aAdd(aCliente, {"A1_MSBLQL", "1", Nil})
							EndIf
						Else
							If !lHotel //Case seja integração com hotelaria, e essa tag esteja vazia, não muda o status para bloqueado
								aAdd(aCliente, {"A1_MSBLQL", "1", Nil})
							Endif
						EndIf
		
						// Obtém a Data de Nasc. ou Abertura
						If oEAIObEt:getpropvalue("RegisterDate") != nil 
							aAdd(aCliente, {"A1_DTNASC", CTOD(oEAIObEt:getpropvalue("RegisterDate")), Nil})
						EndIf

						// Obtém condição de pagamento
						If oEAIObEt:getpropvalue("PaymentConditionCode") != nil 
							aAdd(aCliente, {"A1_COND", RTRIM(oEAIObEt:getpropvalue("PaymentConditionCode")), Nil})
						EndIf

						// Obtém condição de Tabela de Preços
						If oEAIObEt:getpropvalue("PriceListHeaderItemCode") != nil 
							aAdd(aCliente, {"A1_TABELA", RTRIM(oEAIObEt:getpropvalue("PriceListHeaderItemCode")), Nil})
						EndIf

						// Obtém o End. de Cobr. do Cliente
						If oEAIObEt:getPropValue("BillingInformation") != nil  
							If oEAIObEt:getPropValue("BillingInformation"):getPropValue("Address") != nil
								If oEAIObEt:getPropValue("BillingInformation"):getPropValue("Address"):getPropValue("Number") != nil 
									aAdd(aCliente, {"A1_ENDCOB", ( oEAIObEt:getPropValue("BillingInformation"):getPropValue("Address"):getPropValue("Address") +', '+ oEAIObEt:getPropValue("BillingInformation"):getPropValue("Address"):getPropValue("Number") ), Nil})
								Else
									aAdd(aCliente, {"A1_ENDCOB", (oEAIObEt:getPropValue("BillingInformation"):getPropValue("Address"):getPropValue("Address")), Nil})
								EndIf

								// Obtém o Bairro de Cobrança
								If oEAIObEt:getPropValue("BillingInformation"):getPropValue("Address"):getPropValue("District") != nil 
									aAdd(aCliente, {"A1_BAIRROC", (oEAIObEt:getPropValue("BillingInformation"):getPropValue("Address"):getPropValue("District")), Nil})
								EndIf
			
								// Obtém o Cep de Cobrança
								If oEAIObEt:getPropValue("BillingInformation"):getPropValue("Address"):getPropValue("ZIPCode") != nil 
									aAdd(aCliente, {"A1_CEPC", oEAIObEt:getPropValue("BillingInformation"):getPropValue("Address"):getPropValue("ZIPCode"), Nil})
								EndIf
			
								// Obtém o Município de Cobrança
								If oEAIObEt:getPropValue("BillingInformation"):getPropValue("Address"):getPropValue("City"):getPropValue("CityDescription") != nil 
									aAdd(aCliente, {"A1_MUNC", (oEAIObEt:getPropValue("BillingInformation"):getPropValue("Address"):getPropValue("City"):getPropValue("CityDescription")), Nil})
								EndIf
			
								// Obtém a Uf de Cobrança
								If oEAIObEt:getPropValue("BillingInformation"):getPropValue("Address"):getPropValue("State"):getPropValue("StateCode") != nil 
									aAdd(aCliente, {"A1_ESTC", oEAIObEt:getPropValue("BillingInformation"):getPropValue("Address"):getPropValue("State"):getPropValue("StateCode"), Nil})
								EndIf
							EndIf
						Endif
		
						// Obtém o End. de Entr. do Cliente
						If oEAIObEt:getPropValue("ShippingAddress") != nil 
							If oEAIObEt:getPropValue("ShippingAddress"):getPropValue("Address") != nil
								cEndEnt :=  AllTrim(oEAIObEt:getPropValue("ShippingAddress"):getPropValue("Address"))
								If oEAIObEt:getPropValue("ShippingAddress"):getPropValue("Number") != nil 
									If !Empty(AllTrim(oEAIObEt:getPropValue("ShippingAddress"):getPropValue("Number")))
										cEndEnt += ", " + AllTrim(oEAIObEt:getPropValue("ShippingAddress"):getPropValue("Number"))
									Endif
								Endif
								cEndEnt := AllTrim(Upper(cEndEnt))

								cCompEnt := ''
								If oEAIObEt:getPropValue("ShippingAddress"):getPropValue("Complement") != nil 
									If !Empty(AllTrim(oEAIObEt:getPropValue("ShippingAddress"):getPropValue("Complement")))
										cCompEnt := AllTrim(oEAIObEt:getPropValue("ShippingAddress"):getPropValue("Complement"))
									Endif
								Endif
								cCompEnt := AllTrim(Upper(cCompEnt))
								
								If !( Empty( cEndEnt ) )
									Aadd( aCliente, { "A1_ENDENT" ,cEndEnt , Nil })
								EndIf

								If !( Empty( cCompEnt ) )
									Aadd( aCliente, { "A1_COMPENT",cCompEnt, Nil })
								EndIf

							EndIf	
		
							// Obtém o Cep de Entrega
							If oEAIObEt:getPropValue("ShippingAddress"):getPropValue("ZIPCode") != nil 
								aAdd(aCliente, {"A1_CEPE", oEAIObEt:getPropValue("ShippingAddress"):getPropValue("ZIPCode"), Nil})
							EndIf
		
							// Obtém o Bairro de Entrega
							If oEAIObEt:getPropValue("ShippingAddress"):getPropValue("District") != nil 
								aAdd(aCliente, {"A1_BAIRROE", oEAIObEt:getPropValue("ShippingAddress"):getPropValue("District"), Nil})
							EndIf
		
							// Obtém o Estado de Entrega
							If oEAIObEt:getPropValue("ShippingAddress"):getPropValue("State") != nil 
								If oEAIObEt:getPropValue("ShippingAddress"):getPropValue("State"):getPropValue("StateCode") != nil 
									aAdd(aCliente, {"A1_ESTE", oEAIObEt:getPropValue("ShippingAddress"):getPropValue("State"):getPropValue("StateCode"), Nil})
								EndIf
							Endif
						
							If oEAIObEt:getPropValue("ShippingAddress"):getPropValue("City") != nil
								// Obtém o Município da Entrega
								If oEAIObEt:getPropValue("ShippingAddress"):getPropValue("City"):getPropValue("CityCode") != nil 
									cMunEnt := Right(oEAIObEt:getPropValue("ShippingAddress"):getPropValue("City"):getPropValue("CityCode"), 5)
									aAdd(aCliente, {"A1_CODMUNE", cMunEnt, Nil } )
								EndIf
				
								// Obtém a descrição do Município de Entrega
								If oEAIObEt:getPropValue("ShippingAddress"):getPropValue("City"):getPropValue("CityDescription") != nil 
									aAdd(aCliente, {"A1_MUNE", oEAIObEt:getPropValue("ShippingAddress"):getPropValue("City"):getPropValue("CityDescription"), Nil})
								EndIf
							Endif
						Endif
						
						// Grava o campo "A1_ORIGEM" somente se for integracao com HIS
						If Alltrim(cMarca)=="HIS"
							aAdd( aCliente, { "A1_ORIGEM", "S1", Nil } )
						EndIf
					EndIf
		
					//Ponto de entrada para incluir campos no array aCliente
					If ExistBlock("MTI030NOM")
						aRetPe := ExecBlock("MTI030NOM",.F.,.F.,{aCliente,oEAIObEt:getPropValue("Name"), oEAIObEt:getJSON(), nOpcx})
						If ValType(aRetPe) == "A" .And. Len(aRetPe) >0
							If ValType(aRetPe) == "A"
								aCliente := aClone(aRetPe)
							EndIf
						EndIf
					EndIf
						
					//Ordena Array conforme dicionario de dados
					aCliente := FWVetByDic(aCliente,"SA1",.F.)
					
					//Verifica se houve erro antes da rotina automatica
					If lRet .AND. Empty( cLogErro )
						// Executa Rotina Automática conforme evento
						Eval( bRotAut )
			
						// Se a Rotina Automática retornou erro
						If lMsErroAuto
							lRet := .F.
							
							// Obtém o log de erros
							aErroAuto := GetAutoGRLog()
			
							// Varre o array obtendo os erros e quebrando a linha
							cLogErro := ""
							For nCount := 1 To Len(aErroAuto)
								cLogErro += StrTran( StrTran( aErroAuto[nCount], "<", "" ), "-", "" ) + CRLF
							Next nCount
							
							ofwEAIObj:Activate()
							ofwEAIObj:setProp("ReturnContent")
							ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
			
							lRet := .F.
							//Cancela a utilização do código sequencial
							If (lHotel .Or. lGetXnum ) .And. !lIniPadCod
								RollBackSX8()
							Endif
							
						Else
							// CRUD do XXF (de/para)
							If nOpcx == 3 // Insert
								cValInt := IntCliExt(, , SA1->A1_COD, SA1->A1_LOJA)[2]
								CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F.,,,cOwnerMsg)
							
								//Confirma a utilização do código sequencial
								If (lHotel .Or. lGetXnum ).AND. ! lIniPadCod
									ConfirmSX8()
								Endif
							ElseIf nOpcx = 4 // Update
								// se for integracao com o HIS e não houver internalId, 
								// então o His esta sincronizando o cliente dele com a do Protheus.
								// necessitando a geracao do internalId
								If Alltrim(cMarca)=="HIS" .AND. Empty(cValInt)
									cValInt := IntCliExt(, , SA1->A1_COD, SA1->A1_LOJA)[2]
								EndIf
								CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .F.,,,cOwnerMsg)
							Else  // Delete
								CFGA070Mnt(cMarca, cAlias, cField, cValExt, cValInt, .T.,,,cOwnerMsg)								
							EndIf
							
							lRet := .T.				
						EndIf																					
					EndIf												
				EndIf
			EndIf

			If cTypeReg <> "VENDOR"
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				If !lRet
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)		
				Else
					ofwEAIObj:getPropValue("ReturnContent"):setProp("ListOfInternalID",{},'InternalId',,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Name",cOwnerMsg,,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Origin",cValExt,,.T.)
					ofwEAIObj:getPropValue("ReturnContent"):get("ListOfInternalID")[1]:setprop("Destination",cValInt,,.T.)					
				EndIf					
			EndIf
		//--------------------------------------
		//resposta da mensagem Unica TOTVS
		//--------------------------------------
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
		
	       	// Se não houve erros na resposta
			If Upper(oEAIObEt:getPropValue("ProcessingInformation"):getPropValue("Status")) == "OK"  
	            // Verifica se a marca foi informada
	            cProduct := oEAIObEt:getHeaderValue("ProductName")
				If oEAIObEt:getHeaderValue("ProductName") !=  nil .And. !Empty( oEAIObEt:getHeaderValue("ProductName") )  .AND. ValType(cProduct) = "C" 
					cProduct := oEAIObEt:getHeaderValue("ProductName")
				Else
					lRet := .F.					
					ofwEAIObj:Activate()
					ofwEAIObj:setProp("ReturnContent")
					cLogErro := STR0021 // "Erro no retorno. O Product é obrigatório!"
					ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
															
				EndIf
	
				If lRet .and. oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID") !=  nil 
		            // Verifica se o código interno foi informado
					If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin") != nil 
						cValInt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Origin")
					Else
						lRet := .F.						
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0022 // "Erro no retorno. O OriginalInternalId é obrigatório!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)																
					EndIf
		
		            // Verifica se o código externo foi informado
					If oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination") != nil
						cValExt := oEAIObEt:getPropValue("ReturnContent"):getPropValue("ListOfInternalID")[1]:getPropValue("Destination")
					Else
						lRet := .F.
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0023 // "Erro no retorno. O DestinationInternalId é obrigatório"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
					EndIf											
					cEvent := oEAIObEt:getPropValue("ReceivedMessage"):getPropValue("Event")
					
					If cEvent != NIL
						cEvent := Upper(cEvent)
					EndIf
		
					If RTrim(cEvent) $ "UPSERT|DELETE"
		          		//Atualiza o registro na tabela XXF (de/para)
						If !CFGA070Mnt(cProduct, cAlias, cField, cValExt, cValInt, (cEvent = "DELETE"),,,cOwnerMsg)
							cLogErro := "Não foi possível gravar na tabela De/Para. Evento :" +cEvent + CRLF
							lRet := .F.
						EndIf
					Else
						lRet := .F.						
						ofwEAIObj:Activate()
						ofwEAIObj:setProp("ReturnContent")
						cLogErro := STR0025 // "Evento do retorno inválido!"
						ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)																
					EndIf
				Endif
			Else				
				If oEAIObEt:getpropvalue('ProcessingInformation') != nil
					oMsgError := oEAIObEt:getpropvalue('ProcessingInformation'):getpropvalue("ListOfMessages")
					For nX := 1 To Len( oMsgError )
						cMessage := oMsgError[nX]:getpropvalue('Message')
						If cMessage != NiL .AND. ValType(cMessage) == "C"
							cLogErro += cMessage + CRLF
						EndIf
					Next nX
				Endif
	
				lRet := .F.
			EndIf
			If !lRet
				ofwEAIObj:Activate()
				ofwEAIObj:setProp("ReturnContent")
				ofwEAIObj:getPropValue("ReturnContent"):setProp("Error", cLogErro)
			EndIf
			
		//--------------------------------------
	  	//whois
	  	//--------------------------------------
		ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
			ofwEAIObj := "1.000|2.000|2.001|2.002|2.003|2.005"
		EndIf
		
	//--------------------------------------
	//envio mensagem
	//--------------------------------------
	ElseIf(nTypeTrans == TRANS_SEND)
	   
		If cRotina == "MATA030"
			If(!Inclui .And. !Altera)
				cEvent := "delete"
			EndIf
		Else
			oModel := FwModelActive()
			If oModel:GetOperation() == MODEL_OPERATION_DELETE
				cEvent := 'delete'
			EndIf
		EndIf
	      
		If cEvent == "delete"
			CFGA070Mnt(,"SA1","A1_COD",,IntCliExt(, , SA1->A1_COD, SA1->A1_LOJA)[2],.T.,,,cOwnerMsg)
		EndIf
	     
	  	// Trata endereço separando Logradouro e Número
		cLograd := trataEnd(SA1->A1_END, "L")
		cNumero := trataEnd(SA1->A1_END, "N")
	
		If cPaisLoc $ "BRA"
			// Retorna o codigo do estado a partir da sigla
			cCodEst  := Tms120CdUf(SA1->A1_EST, '1')
		
			// Codigo do estado de entrega
			cCodEstE:= Tms120CdUf(SA1->A1_ESTE, '1')
		EndIf
	
	  	// Envio do codigo de acordo com padrao IBGE (cod. estado + cod. municipio)
		If(!Empty(SA1->A1_COD_MUN))
			cCodMun := Rtrim(cCodEst) + Rtrim(SA1->A1_COD_MUN)
		Endif
	
	  	// Codigo do municipio de entrega
		If cPaisLoc $ "ANG|BRA|EQU|HAI|PTG" .And. !Empty(SA1->A1_CODMUNE)
			cCodMunE := Rtrim(cCodEstE)  + Rtrim(SA1->A1_CODMUNE)
		EndIf

		//Montagem da mensagem
		ofwEAIObj:Activate()
		ofwEAIObj:setEvent(cEvent)
		
		ofwEAIObj:setprop("CompanyId", cEmpAnt)	
		ofwEAIObj:setprop("BranchId", cFilAnt)
		ofwEAIObj:setprop("CompanyInternalId", cEmpAnt + '|' + cFilAnt)
		ofwEAIObj:setprop("Code", Rtrim(SA1->A1_COD))
		ofwEAIObj:setprop("StoreId", Rtrim(SA1->A1_LOJA))
		ofwEAIObj:setprop("InternalId", IntCliExt(, , SA1->A1_COD, SA1->A1_LOJA)[2])
		ofwEAIObj:setprop("ShortName", Rtrim(SA1->A1_NREDUZ))
		ofwEAIObj:setprop("Name", Rtrim(SA1->A1_NOME))
		
		//Ajustado para enviar o tipo conforme documentacao API Totvs
		//Identifica se o emitente é apenas Cliente, apenas Fornecedor ou Ambos 
		//1 – Cliente 
		//2 – Fornecedor 
		//3 – Ambos
		ofwEAIObj:setprop("Type", 1 ) //'Customer'
		
		//Trata o tipo de cliente considerando o formato esperado no Protheus para gravação desse dado
		If cPaisLoc == 'BRA'
			cTipoCli := SA1->A1_TIPO
			If cTipoCli == "F"
				cTipoCli := "1"
			Elseif cTipoCli == "L"
				cTipoCli := "2"
			Elseif cTipoCli == "R"
				cTipoCli := "3"
			Elseif cTipoCli == "S"
				cTipoCli := "4"
			Elseif cTipoCli == "X"
				cTipoCli := "5"
			Endif
			ofwEAIObj:setprop("StrategicCustomerType",cTipoCli)
		Endif
		//Ajustado para enviar o tipo conforme documentacao API Totvs
		//Identifica se o emitente é Pessoa Física, Jurídica, Estrangeiro ou Trading 
		//1 – Pessoa Física 
		//2 – Pessoa Jurídica 
		//3 – Estrangeiro 
		//4 – Trading
		If cPaisLoc $ "BRA"
			If SA1->A1_PESSOA == 'F'
				ofwEAIObj:setprop("EntityType", 1)
				cCNPJCPF := 'CPF'
			Else
				ofwEAIObj:setprop("EntityType", 2)
				cCNPJCPF := 'CNPJ'
			EndIf
		Else
			If SA1->A1_PESSOA == 'F'
				ofwEAIObj:setprop("EntityType", 1)
			Else
				ofwEAIObj:setprop("EntityType", 2)
			EndIf
			 cCNPJCPF := AllTrim(FWX3Titulo( "A1_CGC" )) 
		EndIf
		
		If (!Empty(SA1->A1_DTNASC))
			ofwEAIObj:setprop("RegisterDate", SubStr(DToC(SA1->A1_DTNASC), 7, 4) + '-' + SubStr(DToC(SA1->A1_DTNASC), 4, 2) + '-' + SubStr(DToC(SA1->A1_DTNASC), 1, 2))
		EndIf
	
		If SA1->A1_MSBLQL == '1'
			ofwEAIObj:setprop("RegisterSituation", "Inactive")
		Else
			ofwEAIObj:setprop("RegisterSituation", "Active")
		EndIf

		lPFisica := cPaisLoc == "BRA" .And. !Empty(SA1->A1_PFISICA)
		
		If  cPaisLoc $ "BRA"
			If !Empty(SA1->A1_INSCR) .Or. !Empty(SA1->A1_INSCRM) .Or. !Empty(SA1->A1_CGC) .Or. !Empty(SA1->A1_SUFRAMA);
			.Or. !Empty(SA1->A1_RG) .Or. !Empty(SA1->A1_INSCRUR) .Or. lPFisica
				ofwEAIObj:setprop('GovernmentalInformation',{},'Tax',,.T.)
				ofwEAIObj:get("GovernmentalInformation")[1]:setprop("Name"   	, "INSCRICAO ESTADUAL",,.T.)
				ofwEAIObj:get("GovernmentalInformation")[1]:setprop("Scope"     , "State",,.T.)
				ofwEAIObj:get("GovernmentalInformation")[1]:setprop("Id"       	, Rtrim(SA1->A1_INSCR),,.T.)
				ofwEAIObj:setprop('GovernmentalInformation',{},'Tax',,.T.)
				ofwEAIObj:get("GovernmentalInformation")[2]:setprop("Name"   	,"INSCRICAO MUNICIPAL",,.T.)
				ofwEAIObj:get("GovernmentalInformation")[2]:setprop("Scope"     , "Municipal",,.T.)
				ofwEAIObj:get("GovernmentalInformation")[2]:setprop("Id"       	, Rtrim(SA1->A1_INSCRM),,.T.)
				ofwEAIObj:setprop('GovernmentalInformation',{},'Tax',,.T.)
				ofwEAIObj:get("GovernmentalInformation")[3]:setprop("Name"   	, cCNPJCPF,,.T.)
				ofwEAIObj:get("GovernmentalInformation")[3]:setprop("Scope"     , "Federal",,.T.)
				ofwEAIObj:get("GovernmentalInformation")[3]:setprop("Id"       	, Rtrim(SA1->A1_CGC),,.T.)
				ofwEAIObj:setprop('GovernmentalInformation',{},'Tax',,.T.)	        
				ofwEAIObj:get("GovernmentalInformation")[4]:setprop("Name"   	, "SUFRAMA",,.T.)
				ofwEAIObj:get("GovernmentalInformation")[4]:setprop("Scope"     , "Federal",,.T.)
				ofwEAIObj:get("GovernmentalInformation")[4]:setprop("Id"       	, Rtrim(SA1->A1_SUFRAMA),,.T.)
				ofwEAIObj:setprop('GovernmentalInformation',{},'Tax',,.T.)	        
				ofwEAIObj:get("GovernmentalInformation")[5]:setprop("Name"   	, "INSCRICAO RURAL",,.T.)
				ofwEAIObj:get("GovernmentalInformation")[5]:setprop("Scope"     , "State",,.T.)
				ofwEAIObj:get("GovernmentalInformation")[5]:setprop("Id"       	, Rtrim(SA1->A1_INSCRUR),,.T.)

				If SA1->A1_PESSOA == 'F' .And. (lPFisica .Or. !Empty(SA1->A1_RG))
					cTipoRG := IIF(SA1->A1_EST == "EX","PASSAPORTE","RG")
					cRG := IIF(lPFisica, SA1->A1_PFISICA, SA1->A1_RG) //Campo A1_RG utilizado apenas no modulo SIGALOJA

					ofwEAIObj:setprop('GovernmentalInformation',{},'Tax',,.T.)
					ofwEAIObj:get("GovernmentalInformation")[6]:setprop("Name"   	, cTipoRG,,.T.)
					ofwEAIObj:get("GovernmentalInformation")[6]:setprop("Scope"     , "Federal",,.T.)
					ofwEAIObj:get("GovernmentalInformation")[6]:setprop("Id"       	, RTrim(cRG),,.T.)
					
				Endif

			EndIf
			
			If !Empty(SA1->A1_SATIV1) .Or. !Empty(SA1->A1_SATIV2) .Or. !Empty(SA1->A1_SATIV3) .Or. !Empty(SA1->A1_SATIV4);
			.Or. !Empty(SA1->A1_SATIV5) .Or. !Empty(SA1->A1_SATIV6) .Or. !Empty(SA1->A1_SATIV7) .Or. !Empty(SA1->A1_SATIV8)
				
				ofwEAIObj:setprop('Segment',{},'Seg',,.T.)
				ofwEAIObj:get("Segment")[1]:setprop("Name"   	      , "Segment1",,.T.)
				ofwEAIObj:get("Segment")[1]:setprop("InternalId"      , Iif(!Empty(SA1->A1_SATIV1), cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|"+ Rtrim(SA1->A1_SATIV1),"") ,,.T.)
				ofwEAIObj:get("Segment")[1]:setprop("CodeERP"         , Rtrim(SA1->A1_SATIV1),,.T.)
				ofwEAIObj:get("Segment")[1]:setprop("Description"     , Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV1, "X5DESCRI()" )),,.T.)
				ofwEAIObj:setprop('Segment',{},'Seg',,.T.)
				ofwEAIObj:get("Segment")[2]:setprop("Name"   	      , "Segment2",,.T.)
				ofwEAIObj:get("Segment")[2]:setprop("InternalId"      , Iif(!Empty(SA1->A1_SATIV2), cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|"+ Rtrim(SA1->A1_SATIV2),"") ,,.T.)
				ofwEAIObj:get("Segment")[2]:setprop("CodeERP"         , Rtrim(SA1->A1_SATIV2),,.T.)
				ofwEAIObj:get("Segment")[2]:setprop("Description"     , Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV2, "X5DESCRI()" )),,.T.)
				ofwEAIObj:setprop('Segment',{},'Seg',,.T.)
				ofwEAIObj:get("Segment")[3]:setprop("Name"   	      , "Segment3",,.T.)
				ofwEAIObj:get("Segment")[3]:setprop("InternalId"      , Iif(!Empty(SA1->A1_SATIV3), cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + Rtrim(SA1->A1_SATIV3),"") ,,.T.)
				ofwEAIObj:get("Segment")[3]:setprop("CodeERP"         , Rtrim(SA1->A1_SATIV3),,.T.)
				ofwEAIObj:get("Segment")[3]:setprop("Description"     , Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV3, "X5DESCRI()" )),,.T.)
				ofwEAIObj:setprop('Segment',{},'Seg',,.T.)	        
				ofwEAIObj:get("Segment")[4]:setprop("Name"   	      , "Segment4",,.T.)
				ofwEAIObj:get("Segment")[4]:setprop("InternalId"      , Iif(!Empty(SA1->A1_SATIV4), cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|"+ Rtrim(SA1->A1_SATIV4),"") ,,.T.)
				ofwEAIObj:get("Segment")[4]:setprop("CodeERP"         , Rtrim(SA1->A1_SATIV4),,.T.)
				ofwEAIObj:get("Segment")[4]:setprop("Description"     , Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV4, "X5DESCRI()" )),,.T.)
				ofwEAIObj:setprop('Segment',{},'Seg',,.T.)	        
				ofwEAIObj:get("Segment")[5]:setprop("Name"   	      , "Segment5",,.T.)
				ofwEAIObj:get("Segment")[5]:setprop("InternalId"      , Iif(!Empty(SA1->A1_SATIV5), cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|"+ Rtrim(SA1->A1_SATIV5),"") ,,.T.)
				ofwEAIObj:get("Segment")[5]:setprop("CodeERP"         , Rtrim(SA1->A1_SATIV5),,.T.)
				ofwEAIObj:get("Segment")[5]:setprop("Description"     , Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV5, "X5DESCRI()" )),,.T.)
				ofwEAIObj:setprop('Segment',{},'Seg',,.T.)	        
				ofwEAIObj:get("Segment")[6]:setprop("Name"   	      , "Segment6",,.T.)
				ofwEAIObj:get("Segment")[6]:setprop("InternalId"      , Iif(!Empty(SA1->A1_SATIV6), cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|"+ Rtrim(SA1->A1_SATIV6),"") ,,.T.)
				ofwEAIObj:get("Segment")[6]:setprop("CodeERP"         , Rtrim(SA1->A1_SATIV6),,.T.)
				ofwEAIObj:get("Segment")[6]:setprop("Description"     , Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV6, "X5DESCRI()" )),,.T.)
				ofwEAIObj:setprop('Segment',{},'Seg',,.T.)	        
				ofwEAIObj:get("Segment")[7]:setprop("Name"   	      , "Segment7",,.T.)
				ofwEAIObj:get("Segment")[7]:setprop("InternalId"      , Iif(!Empty(SA1->A1_SATIV7), cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|"+ Rtrim(SA1->A1_SATIV7),"") ,,.T.)
				ofwEAIObj:get("Segment")[7]:setprop("CodeERP"         , Rtrim(SA1->A1_SATIV7),,.T.)
				ofwEAIObj:get("Segment")[7]:setprop("Description"     , Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV7, "X5DESCRI()" )),,.T.)
				ofwEAIObj:setprop('Segment',{},'Seg',,.T.)	        
				ofwEAIObj:get("Segment")[8]:setprop("Name"   	      , "Segment8",,.T.)
				ofwEAIObj:get("Segment")[8]:setprop("InternalId"      , Iif(!Empty(SA1->A1_SATIV8), cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|"+ Rtrim(SA1->A1_SATIV8),"") ,.T.)
				ofwEAIObj:get("Segment")[8]:setprop("CodeERP"         , Rtrim(SA1->A1_SATIV8),,.T.)
				ofwEAIObj:get("Segment")[8]:setprop("Description"     , Rtrim(Posicione("SX5",1, xFilial("SX5") + "T3" + SA1->A1_SATIV8, "X5DESCRI()" )),,.T.)

			EndIf

			//Enviando o Tipo de Frete.
			If !Empty(SA1->A1_TPFRET) // C=CIF;F=FOB;T=Por conta terceiros;R=Por conta remetente;D=Por conta destinatário;S=Sem frete                                    
				Do Case
					Case SA1->A1_TPFRET == 'C' 
						cFreightDesc := "CIF"
					Case SA1->A1_TPFRET == 'F' 
						cFreightDesc := "FOB"
					Case SA1->A1_TPFRET == 'T' 
						cFreightDesc := "Por conta terceiros"
					Case SA1->A1_TPFRET == 'R' 
						cFreightDesc := "Por conta remetente"
					Case SA1->A1_TPFRET == 'D' 
						cFreightDesc := "Por conta destinatário"
					Case SA1->A1_TPFRET == 'S' 
						cFreightDesc := "Sem frete"
					Otherwise
						cFreightDesc := "" 
				Endcase	 
				oFreight := ofwEAIObj:setprop("FreightType")
				oFreight:setprop("Code"       , SA1->A1_TPFRET )
				oFreight:setprop("Description", cFreightDesc )
			Endif	
			//Enviando o codigo da tranportadora
			If !Empty(SA1->A1_TRANSP) 
				oCarrier := ofwEAIObj:setprop("Carrier")
				oCarrier:setprop("CodeERP"    , RTrim(SA1->A1_TRANSP) )
				oCarrier:setprop("InternalId" , cEmpAnt + "|" + Alltrim(xFilial("SA4")) + "|" + RTrim(SA1->A1_TRANSP) )
				oCarrier:setprop("Description", Rtrim(Posicione("SA4",1, xFilial("SA4") + SA1->A1_TRANSP, "A4_NOME" )) )
			Endif	
		Else
			ofwEAIObj:setprop('GovernmentalInformation',{},'Tax',,.T.)
			ofwEAIObj:get("GovernmentalInformation")[1]:setprop("Name"   	, cCNPJCPF,,.T.)
			ofwEAIObj:get("GovernmentalInformation")[1]:setprop("Scope"     , "Federal",,.T.)
			ofwEAIObj:get("GovernmentalInformation")[1]:setprop("Id"       	, Rtrim(SA1->A1_CGC),,.T.)
		EndIf

		oAddress := ofwEAIObj:setprop("Address")
		oAddress:setprop("Address", Rtrim(cLograd) )
		oAddress:setprop("Number", Rtrim(cNumero) )
		oAddress:setprop("Complement", Iif(Empty(SA1->A1_COMPLEM),_NoTags(trataEnd(SA1->A1_END,"C")),_NoTags(Rtrim(SA1->A1_COMPLEM))) )
		If !Empty(cCodMun) .Or. !Empty(SA1->A1_MUN)
			oAddress:setprop("City")
			If !Empty(cCodMun)
				oAddress:getPropValue("City"):setprop("CityCode", cCodMun )
				oAddress:getPropValue("City"):setprop("CityInternalId", cCodMun )
			Else
				oAddress:getPropValue("City"):setprop("CityCode", "" )
				oAddress:getPropValue("City"):setprop("CityInternalId", "" )
			EndIf
			oAddress:getPropValue("City"):setprop("CityDescription", Rtrim(SA1->A1_MUN) )
		EndIf
		oAddress:setprop("District", Rtrim(SA1->A1_BAIRRO) )
		If !Empty(SA1->A1_EST)
			oAddressState := oAddress:setprop("State")
			oAddressState:setprop("StateCode", AllTrim( SA1->A1_EST ) )
			oAddressState:setprop("StateInternalId", AllTrim( SA1->A1_EST ) )
			oAddressState:setprop("StateDescription", Rtrim(Posicione("SX5",1, xFilial("SX5") + "12" + SA1->A1_EST, "X5DESCRI()" )) )			
		EndIf
		If !Empty(SA1->A1_PAIS)
			oAddressCountry := oAddress:setprop("Country")
			oAddressCountry:setprop("CountryCode", SA1->A1_PAIS )
			oAddressCountry:setprop("CountryInternalId", SA1->A1_PAIS )
			oAddressCountry:setprop("CountryDescription", Rtrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_DESCR")) )
		EndIf
		If !Empty(SA1->A1_REGIAO)
			oAddressRegion := oAddress:setprop("Region")
			oAddressRegion:setprop("RegionCode"       , RTrim(SA1->A1_REGIAO) )
			oAddressRegion:setprop("RegionInternalId" , cEmpAnt + "|" + Alltrim(xFilial("SX5")) + "|" + RTrim(SA1->A1_REGIAO) )			
			oAddressRegion:setprop("RegionDescription", Rtrim(Posicione("SX5",1, xFilial("SX5") + "A2" + SA1->A1_REGIAO, "X5DESCRI()" )) )
		EndIf
		oAddress:setprop("ZIPCode", Rtrim(SA1->A1_CEP) )
		oAddress:setprop("POBox", Rtrim(SA1->A1_CXPOSTA) )
		
	  	// Endereço de entrega
		If !Empty(SA1->A1_ENDENT) .Or. !Empty(SA1->A1_MUNE) .Or. !Empty(SA1->A1_BAIRROE) .Or. !Empty(SA1->A1_ESTE) .Or. !Empty(SA1->A1_CEPE)
			oShipAddress := ofwEAIObj:setprop("ShippingAddress")
			oShipAddress:setprop("Address", _NoTags(trataEnd(SA1->A1_ENDENT,"L")) )
			oShipAddress:setprop("Number", trataEnd(SA1->A1_ENDENT,"N") )
			oShipAddress:setprop("Complement", Iif(Empty(SA1->A1_COMPENT),_NoTags(trataEnd(SA1->A1_ENDENT,"C")),_NoTags(Rtrim( SA1->A1_COMPENT ) ) ) )
			If !Empty(cCodMunE) .And. !Empty(SA1->A1_MUNE)
				oShipAddCity := oShipAddress:setprop("City")
				oShipAddCity:setprop("CityCode", cCodMunE )
				oShipAddCity:setprop("CityDescription", Rtrim(SA1->A1_MUNE) )				
			EndIf	
			oShipAddress:setprop("District", Rtrim(SA1->A1_BAIRROE) )
			If !Empty(SA1->A1_ESTE)
				oShipAddState := oShipAddress:setprop("State")
				oShipAddState:setprop("StateCode", Rtrim(SA1->A1_ESTE) )
			EndIf	
			oShipAddress:setprop("ZIPCode", Rtrim(SA1->A1_CEPE) )	
		EndIf

	  	// Formas de contato
		If !Empty(SA1->A1_TEL) .Or. !Empty(SA1->A1_FAX) .Or. !Empty(SA1->A1_HPAGE) .Or. !Empty(SA1->A1_EMAIL)
			If !Empty(SA1->A1_DDI)
				cTel := AllTrim(SA1->A1_DDI)
			EndIf
			
			If !Empty(SA1->A1_DDD)
				If !Empty(cTel)
					cTel += AllTrim(SA1->A1_DDD)
				Else
					cTel := AllTrim(SA1->A1_DDD)
				EndIf
			EndIf
			
			If !Empty(cTel)
				cTel += AllTrim(SA1->A1_TEL)
			Else
				cTel := AllTrim(SA1->A1_TEL)
			EndIf
			
			ofwEAIObj:setprop('ListOfCommunicationInformation',{},'CommunicationInformation',,.T.)
			ofwEAIObj:get("ListOfCommunicationInformation")[1]:setprop("PhoneNumber", cTel,,.T.)
			ofwEAIObj:get("ListOfCommunicationInformation")[1]:setprop("FaxNumber", Rtrim(SA1->A1_FAX),,.T.)
			ofwEAIObj:get("ListOfCommunicationInformation")[1]:setprop("HomePage", _NoTags(Rtrim(SA1->A1_HPAGE)),,.T.)
			ofwEAIObj:get("ListOfCommunicationInformation")[1]:setprop("Email", _NoTags(Rtrim(SA1->A1_EMAIL)),,.T.)
		EndIf
		
		// Contato
		If !Empty(SA1->A1_CONTATO)
			ofwEAIObj:setprop('ListOfContacts',{},'Contact',,.T.)
			ofwEAIObj:get("ListOfContacts")[1]:setprop("ContactInformationName", _NoTags(Rtrim(SA1->A1_CONTATO)),,.T.)
		EndIf

	  	// Endereço de cobrança
		If !Empty(SA1->A1_ENDCOB) .Or. !Empty(SA1->A1_MUNC) .Or. !Empty(SA1->A1_BAIRROC) .Or. !Empty(SA1->A1_ESTC) .Or. !Empty(SA1->A1_CEPC)
			oBillInfor := ofwEAIObj:setprop("BillingInformation")
			oBillInfor := oBillInfor:setprop("Address")
			oBillInfor:setprop("Address", _NoTags(trataEnd(SA1->A1_ENDCOB,"L")) )
			oBillInfor:setprop("Number", trataEnd(SA1->A1_ENDCOB,"N") )
			oBillInfor:setprop("Complement", _NoTags(trataEnd(SA1->A1_ENDCOB,"C")) )
			oBillInfor:setprop("District", _NoTags(Rtrim(SA1->A1_BAIRROC)) )
			oBillInfor:setprop("ZIPCode", Rtrim(SA1->A1_CEPC) )
			oBillInfor:setprop("City")
			oBillInfor:getPropValue("City"):setprop("CityDescription", _NoTags(Rtrim(SA1->A1_MUNC)) )
			oBillState := oBillInfor:setprop("State")
			oBillState:setprop("StateCode", SA1->A1_ESTC )
		EndIf
		
		// Vendedor
		If !Empty(SA1->A1_VEND)
			oVedInf := ofwEAIObj:setprop("VendorInformation")
			oVedInf := oVedInf:setprop("VendorType")
			oVedInf:setprop("Code", SA1->A1_VEND )
			oVedInf:setprop("VendorInformationInternalID", Rtrim(cEmpAnt) + '|' + Rtrim(xFilial('SA3')) + '|' + Rtrim(SA1->A1_VEND) )
		EndIf
		
		// Condicao de Pagamento
		If !Empty(SA1->A1_COND)
			ofwEAIObj:setprop("PaymentConditionCode", Rtrim(SA1->A1_COND))
			ofwEAIObj:setprop("PaymentConditionInternalId", Rtrim(cEmpAnt) + '|' + Rtrim(xFilial('SE4')) + '|' + Rtrim(SA1->A1_COND))
		EndIf
		
		// Tabela de Preços
		If !Empty(SA1->A1_TABELA)
			ofwEAIObj:setprop("PriceListHeaderItemCode",  Rtrim(SA1->A1_TABELA))
			ofwEAIObj:setprop("PriceListHeaderItemInternalId",  Rtrim(cEmpAnt) + '|' + Rtrim(xFilial('DA0')) + '|' + Rtrim(SA1->A1_TABELA))
		EndIf

	   	// Limite de Crédito
		If !Empty(SA1->A1_LC) .or. !Empty(SA1->A1_VENCLC)
			ofwEAIObj:setprop("CreditInformation")
			ofwEAIObj:getPropValue("CreditInformation"):setprop("CreditLimit", SA1->A1_LC )
			If !Empty(SA1->A1_VENCLC)
				ofwEAIObj:getPropValue("CreditInformation"):setprop("MaturityCreditLimit", Transform(DtoS(SA1->A1_VENCLC),'@R 9999-99-99')) 
			Endif	
		EndIf

		IF !Empty(SA1->A1_CONTRIB)
			ofwEAIObj:setprop("Taxpayer", SA1->A1_CONTRIB)
		Endif
		
		If ExistBlock("MT030jin")
			cJson := ExecBlock("MT030Jin",.F.,.F., {cEvent,oModel})
			If ValType( cJson ) == "C" .And. !( Empty( cJson ) )
				ofwEAIObj:loadJson(cJson)
			Endif
		EndIf	

	EndIf
	
	
	aRet := { lRet, ofwEAIObj, cOwnerMsg } 

	aSize(aCliente,0 )
	aCliente := {}
	
	aSize(aAux,0)
	aAux := {}

	aSize(aAreaCCH,0)
	aAreaCCH := {}

Return aRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} IntCliExt
Monta o InternalID do Cliente de acordo com o código passado
no parâmetro.

@param   cEmpresa   Código da empresa (Default cEmpAnt)
@param   cFil       Código da Filial (Default cFilAnt)
@param   cCliente   Código do Cliente
@param   cLoja      Código da Loja do Cliente

@author  Totvs Cascavel
@version P12
@since   23/05/2018
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado.
         No segundo parâmetro uma variável string com o InternalID
         montado.

@sample  IntCliExt(, , '00001', '01') irá retornar {.T., '01|01|00001|01|C'}
/*/
//-------------------------------------------------------------------
Static Function IntCliExt(cEmpresa, cFil, cCliente, cLoja )

   	Local   aResult  := {}
   	
   	Default cEmpresa 	:= cEmpAnt
   	Default cFil     	:= xFilial('SA1')
	Default cCliente	:= ""
	Default cLoja		:= ""

	aAdd(aResult, .T.)
	aAdd(aResult, cEmpresa + '|' + RTrim(cFil) + '|' + RTrim(cCliente) + '|' + RTrim(cLoja) + '|C')

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} IntCliInt
Recebe um InternalID e retorna o código do Cliente.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Versão da mensagem única (Default 2.000)

@author  Leandro Luiz da Cruz
@version P11
@since   08/02/2013
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado no de/para.
         No segundo parâmetro uma variável array com a empresa,
         filial, o código do cliente e a loja do cliente.

@sample  IntLocInt('01|01|00001|01') irá retornar
{.T., {'01', '01', '00001', '01', 'C'}}
/*/
//-------------------------------------------------------------------
Static Function IntCliInt(cInternalID, cRefer)

   	Local   aResult  := {}
   	Local   aTemp    := {}
   	Local   cTemp    := ''
   	Local   cAlias   := 'SA1'
   	Local   cField   := 'A1_COD'

	Default cInternalID	:= ''
	Default cRefer		:= ''

	cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
	
  	If !Empty( cTemp )  
		aAdd(aResult, .T.)
	 	aTemp := Separa(cTemp, '|')
	 	aAdd(aResult, {})
	 	aResult[Len(aResult)] := aClone( aTemp )
	Endif

	aSize(aTemp, 0)
	aTemp := {}
	
Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc} A2030PAIS()
Array com codigo dos pais utilizados na TOTVS

@author  Rodrigo Machado Pontes
@version P11
@since   14/10/2015
@return  aArray - Array retornado conforme dicionario  de dados
/*/
//-------------------------------------------------------------------
Static Function A2030PAIS(cAliasPais)
	Local aAreaSYA	:= SYA->(GetArea())
	Local cCdPais	:= ""
	Local cCpo		:= Iif(cAliasPais=="SA1","A1_PAIS","A2_PAIS")
	Local cFilSYA	:= xFilial("SYA") 
	Local nI		:= 0
	Local aRet		:= {	{"BRASIL"					,"BRA","0"},;
						{"ANGOLA"					,"ANG","0"},;
						{"ARGENTINA"				,"ARG","0"},;
						{"BOLIVIA"					,"BOL","0"},;
						{"CHILE"					,"CHI","0"},;
						{"COLOMBIA"				    ,"COL","0"},;
						{"COSTA RICA"				,"COS","0"},;
						{"REPUBLICA DOMINICANA"	    ,"DOM","0"},;
						{"EQUADOR"					,"EQU","0"},;
						{"ESTADOS UNIDOS"			,"EUA","0"},;
						{"MEXICO"					,"MEX","0"},;
						{"PARAGUAI"				    ,"PAR","0"},;
						{"PERU"					    ,"PER","0"},;
						{"PORTUGAL"				    ,"PTG","0"},;
						{"URUGUAI"					,"URU","0"},;
						{"VENEZUELA"				,"VEN","0"}}
	Default cAliasPais := ''

	For nI := 1 To Len(aRet)
	cCdPais	:= ""
		cCdPais	:= PadR(Posicione("SYA",2,cFilSYA + PadR(aRet[nI,1],TamSx3("YA_DESCR")[1]),"YA_CODGI"),TamSx3(cCpo)[1])
	
	If !Empty(cCdPais)
		aRet[nI,3] := cCdPais
	Endif
	Next nI

	RestArea(aAreaSYA)
	aSize(aAreaSYA, 0)
	aAreaSYA := {}

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A2030PALOC()
Busca o codigo do pais atraves do cPaisLoc

@author  Rodrigo Machado Pontes
@version P11
@since   14/10/2015
@return  cCdPaisLoc - codigo do pais atraves do cPaisLoc
/*/
//-------------------------------------------------------------------
Static Function A2030PALOC(cAliasPais,nOpc)

	Local aPais			:= A2030PAIS(cAliasPais)
	Local nPos			:= 0
	Local cCdPaisLoc	:= ""

	Default cAliasPais	:= ''
	Default nOpc		:= 0

	If nOpc == 1 //Busca o Codigo do Pais
		nPos := aScan(aPais,{|x| AllTrim(x[2]) == AllTrim(Upper(cPaisLoc))})
		If nPos > 0
			cCdPaisLoc := aPais[nPos,3]
		Endif
	Elseif nOpc == 2 //Busca o Nome do Pais
		nPos := aScan(aPais,{|x| AllTrim(x[2]) == AllTrim(Upper(cPaisLoc))})
		If nPos > 0
			cCdPaisLoc := aPais[nPos,1]
		Endif
	Endif	
	aSize(aPais,0)

Return cCdPaisLoc

//-------------------------------------------------------------------
/*/{Protheus.doc} I30ProxNum
Rotina para retornar o Proximo numero para gravação

@return cRet, Código sequêncial válido

@author Pedro Alencar
@since 29/12/2015
@version 12.1.9
/*/
//-------------------------------------------------------------------
Function I30ProxNum()
	Local aAreaSA1 := {}
	Local cRet := ""
	Local lLivre := .F.
	Local cFilSA1	:= FWxFilial("SA1")
	
	aAreaSA1 := SA1->( GetArea() )
	SA1->( dbSetOrder( 1 ) )
	cRet := GetSxeNum( "SA1", "A1_COD" )
	
	While !lLivre
		If SA1->( msSeek( cFilSA1  + cRet ) )
			ConfirmSX8()
			cRet := GetSxeNum( "SA1", "A1_COD" )
		Else
			lLivre := .T.
		Endif
	Enddo
	
	RestArea( aAreaSA1 )
	aSize(aAreaSA1, 0)
	aAreaSA1 := {}

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MATI030Num
Recebe conteúdo da tag <CODE> e ajusta para o padrão protheus caso
esteja fora do padrão. 

@param   cCode      ,String, Conteúdo da tag <CODE>
@param   lGetXnum   ,Lógic,  Indica se foi utilizado Getsx8Num
@author  Squad CRM/Faturamento
@version P12
@since   18/04/2018
@return  cCode      ,String, Conteúdo da tag <CODE>
@sample  MATI030Num('34563597874', lGetxnum) => '345635' ou o proximo número livre
/*/
//-------------------------------------------------------------------
Function MATI030Num(cCode, lGetXnum)
    Local nLengA1Cod    := TamSX3('A1_COD')[1]
    Local aAreaCli      := {}
    Default cCode       := ''
    Default lGetXnum	:= .F. 
    
	cCode := IIf( Empty( cCode ), GetSx8Num( 'SA1','A1_COD' ), cCode ) 

    IF !Empty(cCode) .And. Len(cCode) > nLengA1Cod
        aAreaCli := SA1->( GetArea() )
        SA1->(dbSetOrder(1))
        
        cCode := Substr( cCode, 1, nLengA1Cod )
        
        If  SA1->(MsSeek(xFilial('SA1') + cCode))
            cCode := I30ProxNum()
            lGetXnum := .T.
        EndIf 

        SA1->( RestArea( aAreaCli ) )
        Asize(aAreaCli,0)
		aAreaCli := {}
    EndIf

Return cCode

//-------------------------------------------------------------------
/*/{Protheus.doc} MATI30Pais
Tradutor de código de país, para casos onde o código enviado seja diferente
dos encontrados na SYA

@param   cPaisCode      ,String, Código do país enviado ao adapter
@param   cPais          ,String, Nome do país enviado ao adaoter
@param   cMarca         ,String, Marca do Adapter para pesquisa no De/Para
@retur   cRet           ,String, Código do País na tabela SYA
@author  Squad CRM/Faturamento
@version P12
@since   11/05/2018
@sample  MATI30Pais('001', 'BRASIL') => '105'
/*/
//-------------------------------------------------------------------
Static Function MATI30Pais(cPaisCode, cPais, cMarca)
    Local aAreaSYA    := {}
    Local cFilSYA     := ''
    Local cRet        := '' 
    Local lHasCode    := !Empty(cPaisCode)
    Local lHasDesc    := !Empty(cPais)
    
    Default cPaisCode := ''
    Default cPais     := ''
    Default	cMarca		:= ''
    
    If lHasCode
        cRet := CFGA070Int(cMarca, 'SYA', 'YA_CODGI', cPaisCode)
    EndIf

    If !Empty(cRet)
        cRet := Alltrim( cRet )
    Else
        aAreaSYA := SYA->( GetArea() )
        cFilSYA := xFilial("SYA")
        
        If lHasCode
            cRet := AllTrim(Posicione("SYA",1,cFilSYA+cPaisCode,"YA_CODGI"))
        EndIf

        If Empty(cRet) .And. lHasDesc
            cRet := AllTrim(Posicione("SYA",2,cFilSYA+ Padr(cPais, GetSX3Cache("YA_DESCR","X3_TAMANHO") ),"YA_CODGI"))
        EndIf
        RestArea(aAreaSYA)
        Asize(aAreaSYA,0)   
		aAreaSYA := {}   
    EndIf
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Mati30Regi
Recebe um InternalID e CodigoRegiao interno do Protheus "006-Norte" e retorna o código da Region válido.

@param   cInternalID recebido na mensagem, externalId.
@param   cRegionCode Codigo da Regiao interno Protheus
@param   cMarca      Produto que enviou a mensagem


@author  TOTVS
@version P12
@since   03/12/2020
@return  cRet com o código valido no Protheus.

@sample  Mati30Regi('89014c65-9dc2-4074-8003-db3242fc3227', 'T3||006', 'MASTERCRM') irá retornar
006
/*/
//-------------------------------------------------------------------
Static Function Mati30Regi(cValExtID, cRegionCode, cMarca)

   	Local   cRet        := ''
	Local aAreaSX5      := SX5->(GetArea())
	Local cTemp         := ''
	Local aTemp         := {}

	Default cValExtID	:= ''
	Default cRegionCode	:= ''
	Default cMarca      := ''
	
	//Código interno do Prohteus para Região, se for enviado no Json, validamos se o código existe na SX5
	If !Empty(cRegionCode)
		If at('|', cRegionCode) > 0
			aTemp := Separa(cRegionCode, '|')
			If Len(aTemp) >= 3
				cRegionCode := Left(aTemp[3] + Space(Len(SA1->A1_REGIAO)), Len(SA1->A1_REGIAO) )
			Endif
		Else
			cRegionCode := Left(cRegionCode + Space(3), Len(SA1->A1_REGIAO))
		Endif
		SX5->(dbSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5") + 'A2' + cRegionCode ))
			SX5->( RestArea( aAreaSX5 ) )
			Return cRegionCode
		Endif
	EndIf

	//Código externo para busca, se não enviado o código interno do Protheus ou enviado codigo errado, verificamos pelo cValExtID na tabela XXF.
	cTemp := CFGA070Int(cMarca, 'SX5', 'X5_CHAVE', cValExtID)
	
  	If !Empty( cTemp ) 
	  	If at('|', cTemp) > 0
			aTemp := Separa(cTemp, '|')
			If Len(aTemp) >= 3
				cTemp := Left(aTemp[3] + Space(3), Len(SA1->A1_REGIAO))
			Endif
		Else
			cTemp := Left(cTemp + Space(3), Len(SA1->A1_REGIAO))
		Endif	
		SX5->(dbSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5") + 'A2' + cTemp ))
			cRet := cTemp
		Endif
	Endif

	SX5->( RestArea( aAreaSX5 ) )
Return cRet

/*/{Protheus.doc} Mati30Seg
Recebe um InternalID e CodigoSegmento interno do Protheus "000001-Industria Quimica/Resinas/Tintas/Sinteticos" e retorna o código do segmento valido.

@param   cInternalID recebido na mensagem, externalId.
@param   cSegCode    Codigo do segmento interno Protheus
@param   cMarca      Produto que enviou a mensagem

@author  TOTVS
@version P12
@since   03/12/2020
@return  cRet com o código valido no Protheus.

@sample  Mati30Seg('89014c65-9dc2-4074-8003-db3242fc3227', 'T3||000001', 'MASTERCRM') irá retornar
000001
/*/
//-------------------------------------------------------------------
Static Function Mati30Seg(cValExtID, cSegCode, cMarca)

   	Local   cRet        := ''
	Local aAreaSX5      := SX5->(GetArea())
	Local cTemp         := ''
	Local aTemp         := {}
	Local nLenA1SAT     := Len(SA1->A1_SATIV1)

	Default cValExtID	:= ''
	Default cSegCode	:= ''
	Default cMarca      := ''
	
	//Código interno do Prohteus para Região, se for enviado no Json, validamos se o código existe na SX5
	If !Empty(cSegCode)
		If at('|', cSegCode) > 0
			aTemp := Separa(cSegCode, '|')
			If Len(aTemp) >= 3
				cSegCode := Left(aTemp[3] + Space(nLenA1SAT), nLenA1SAT )
			Endif
		Else
			cSegCode := Left(cSegCode + Space(nLenA1SAT), nLenA1SAT )
		Endif
		SX5->(dbSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5") + 'T3' + cSegCode ))
			SX5->( RestArea( aAreaSX5 ) )
			Return cSegCode
		Endif
	EndIf

	//Código externo para busca, se não enviado o código interno do Protheus ou enviado codigo errado, verificamos pelo cValExtID na tabela XXF.
	cTemp := CFGA070Int(cMarca, 'SX5', 'X5_CHAVE', cValExtID)
	
  	If !Empty( cTemp ) 
	  	If at('|', cTemp) > 0
			aTemp := Separa(cTemp, '|')
			If Len(aTemp) >= 3
				cTemp := Left(aTemp[3] + Space(nLenA1SAT), nLenA1SAT )
			Endif
		Else
			cTemp := Left(cTemp + Space(nLenA1SAT), nLenA1SAT)
		Endif	
		SX5->(dbSetOrder(1))
		If SX5->(dbSeek(xFilial("SX5") + 'T3' + cTemp ))
			cRet := cTemp
		Endif
	Endif

	SX5->( RestArea( aAreaSX5 ) )
Return cRet

/*/{Protheus.doc} Mati30Car
Recebe um InternalID e Codigo Tranpsortadora retorna o código da tranportadora valido.

@param   cInternalID recebido na mensagem, externalId.
@param   cCarrCode    Codigo do segmento interno Protheus
@param   cMarca      Produto que enviou a mensagem

@author  TOTVS
@version P12
@since   03/12/2020
@return  cRet com o código valido no Protheus.

@sample  Mati30Car('89014c65-9dc2-4074-8003-db3242fc3227', 'T3||000001', 'MASTERCRM') irá retornar
000001
/*/
//-------------------------------------------------------------------
Static Function Mati30Car(cValExtID, cCarrCode, cMarca)

   	Local   cRet        := ''
	Local aAreaSA4      := SA4->(GetArea())
	Local cTemp         := ''
	Local aTemp         := {}
	Local nLenA1SAT     := Len(SA1->A1_TRANSP)

	Default cValExtID	:= ''
	Default cCarrCode	:= ''
	Default cMarca      := ''

	//Código interno do Prohteus para Transportadora, se for enviado no Json, validamos se o código existe na SA4
	If !Empty(cCarrCode)
		If at('|', cCarrCode) > 0
			aTemp := Separa(cCarrCode, '|')
			If Len(aTemp) >= 3
				cCarrCode := Left(aTemp[3] + Space(nLenA1SAT), nLenA1SAT )
			Endif
		Else
			cCarrCode := Left(cCarrCode + Space(nLenA1SAT), nLenA1SAT )
		Endif
		SA4->(dbSetOrder(1))
		If SA4->(dbSeek(xFilial("SA4") + cCarrCode ))
			SA4->( RestArea( aAreaSA4 ) )
			Return cCarrCode
		Endif
	EndIf

	//Código externo para busca, se não enviado o código interno do Protheus ou enviado codigo errado, verificamos pelo cValExtID na tabela XXF.
	cTemp := CFGA070Int(cMarca, 'SA4', 'A4_COD', cValExtID)
	
  	If !Empty( cTemp ) 
	  	If at('|', cTemp) > 0
			aTemp := Separa(cTemp, '|')
			If Len(aTemp) >= 3
				cTemp := Left(aTemp[3] + Space(nLenA1SAT), nLenA1SAT )
			Endif
		Else
			cTemp := Left(cTemp + Space(nLenA1SAT), nLenA1SAT)
		Endif	
		SA4->(dbSetOrder(1))
		If SA4->(dbSeek(xFilial("SA4") + cTemp ))
			cRet := cTemp
		Endif
  Endif

	SA4->( RestArea( aAreaSA4 ) )
Return cRet

/*/{Protheus.doc} I030SrcCli
	Funcao Responsavel por Verificar e Avaliar o Cadastro do Cliente Utilizando o Endereço Principal 
	@type  Function
	@author Paulo V. Beraldo
	@since Abr/2021
	@version 1.00
	@param oObj	  , Object  , Objeto Criado com os Dados Recebidos via Adapter
	@param cCodCli, Caracter, Codigo do Cliente
	@param cLojCli, Caracter, Loja do Cliente
	@return aRet  , Vetor   , Vetor com as Informacoes: Codigo do Cliente, Loja do Cliente, Inclusao ou Alteracao no Cadastro de Cliente
/*/
Function I030SrcCli( oObj, cCodCli, cLojCli, cType )
Local lRet		:= .F.
Local nCount	:= 0
Local aRet		:= {}
Local aArea		:= GetArea()
Local cQuery	:= Nil
Local cTmpAlias	:= GetNextAlias()
Local cCodAux	:= ''
Local cLojAux	:= ''
Local cCgc		:= ''
Local cEnd		:= ''
Local cCep		:= ''
Local cMun		:= ''
Local cBairro	:= ''
Local cEndCompl	:= ''

Default oObj	:= Nil
Default cCodCli	:= ''
Default cLojCli	:= ''
Default cType	:= 'JSON'

If !( ValType( oObj ) == 'O' ) .And. Empty( cCodCli ) .And. Empty( cLojCli )
	Aadd( aRet, '' )
	Aadd( aRet, '' )
	Aadd( aRet, .T. )
Else
	cCgc := Posicione( 'SA1', 1, FWxFilial( 'SA1' ) + cCodCli + cLojCli, 'A1_CGC' )
	//Endereco Principal
	If Upper( cType ) == 'XML'
		// Obtém o Cod Endereçamento Postal
		If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address") != "U"
			lRet := .T.
			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_ZIPCode:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_ZIPCode:Text)
				cCep := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_ZIPCode:Text
			EndIf

			If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address") != "U" .AND. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address)
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Address:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Address:Text)
					If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Number:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Number:Text)
						cEnd := UPPER(AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Address:Text)) + ", " + UPPER(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Number:Text)
					Else
						cEnd := UPPER(AllTrim(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Address:Text))
					EndIf
				EndIf

				// Obtém o Complemento do Endereço
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Complement:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Complement:Text)
					cEndCompl :=  UPPER(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_Complement:Text)
				EndIf

				// Obtém o Bairro do Cliente
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_District:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_District:Text)
					cBairro := UPPER(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_District:Text)
				EndIf

				// Obtém a descrição do Município do Cliente
				If Type("oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_CityDescription:Text") != "U" .And. !Empty(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_CityDescription:Text)
					cMun := UPPER(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_Address:_City:_CityDescription:Text)
				EndIf
			EndIf
		EndIf
	Else
		If oObj:getPropValue("Address") != nil .And. !Empty( oObj:getpropvalue("Address") )
			lRet := .T.
			// Obtém o Cod Endereçamento Postal
			If oObj:getPropValue("Address"):getPropValue("ZIPCode") != nil 
				cCep := oObj:getPropValue("Address"):getPropValue("ZIPCode")
			EndIf

			// Obtém o Número do Endereço do Cliente						
			If oObj:getPropValue("Address"):getPropValue("Number") != nil   
				cEnd := UPPER( AllTrim( oObj:getPropValue("Address"):getPropValue("Address") ) ) + ", " + UPPER( oObj:getPropValue("Address"):getPropValue("Number") )
			Else
				cEnd := UPPER( AllTrim( oObj:getPropValue("Address"):getPropValue("Address") ) )
			EndIf

			// Obtém o Complemento do Endereço
			If oObj:getPropValue("Address"):getPropValue("Complement") != nil  
				cEndCompl := UPPER( oObj:getPropValue("Address"):getPropValue("Complement") )
			EndIf

			// Obtém o Bairro do Cliente
			If oObj:getPropValue("Address"):getPropValue("District") != nil  
				cBairro := UPPER( oObj:getPropValue("Address"):getPropValue("District") )
			EndIf						

			If oObj:getPropValue("Address"):getPropValue("City") != Nil 
				// Obtém a descrição do Município do Cliente							
				If oObj:getPropValue("Address"):getPropValue("City"):getPropValue("CityDescription") != nil 
					cMun := UPPER( oObj:getPropValue("Address"):getPropValue("City"):getPropValue("CityDescription") ) 
				EndIf
			Endif
		EndIf
	EndIf

	If lRet .And. !( Empty( cCep ) )
		cQuery := " SELECT 	SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_NREDUZ, SA1.A1_CGC, "+CRLF
		cQuery += " 		SA1.A1_END, SA1.A1_COMPLEM, SA1.A1_CEP, SA1.A1_BAIRRO, SA1.A1_MUN, "+CRLF
		cQuery += " 		SA1.A1_ENDCOB, SA1.A1_BAIRROC, SA1.A1_CEPC, SA1.A1_MUNC, "+CRLF
		cQuery += " 		SA1.A1_ENDENT, SA1.A1_COMPENT, SA1.A1_CEPE, SA1.A1_BAIRROE, SA1.A1_MUNE "+CRLF

		cQuery += " FROM "+ RetSQLName( "SA1" ) +" SA1 "+CRLF

		cQuery += " WHERE SA1.A1_FILIAL = '"+ FWxFilial( "SA1" ) +"' "+CRLF
		cQuery += " 	AND SA1.A1_CGC = '"+ cCgc +"' "+CRLF
		cQuery += " 	AND SA1.A1_CEP = '"+ cCep +"' "+CRLF

		cQuery += " 	AND SA1.D_E_L_E_T_ = ' ' "
		
		lRet := .F.
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., __cRdd, TcGenQry( ,, cQuery ), cTmpAlias, .T., .F. )
		( cTmpAlias )->( dbGotop() )

		If !( cTmpAlias )->( Eof() )
			While !( cTmpAlias )->( Eof() )
				lRet := AllTrim( cEnd )       == AllTrim( ( cTmpAlias )->A1_END )    .And. AllTrim( cEndCompl )  == AllTrim( ( cTmpAlias )->A1_COMPLEM ) .And.;
						AllTrim( cBairro )    == AllTrim( ( cTmpAlias )->A1_BAIRRO ) .And. AllTrim( cMun )       == AllTrim( ( cTmpAlias )->A1_MUN )

				If ( lRet )
					cCodAux := ( cTmpAlias )->A1_COD
					cLojAux := ( cTmpAlias )->A1_LOJA
					Exit
				EndIf

				( cTmpAlias )->( dbSkip() )
			EndDo
			
			If !( lRet )
				aRet := I030LjCli( cCodCli, cLojCli )
			Else
				Aadd( aRet, cCodAux )
				Aadd( aRet, cLojAux )
				Aadd( aRet, !lRet )
			EndIf
		Else
			aRet := I030LjCli( cCodCli, cLojCli )
		EndIf
	Else
		Aadd( aRet, '' )
		Aadd( aRet, '' )
		Aadd( aRet, .T. )
	EndIf

EndIf

IIf( Select( cTmpAlias ) > 0, ( cTmpAlias )->( dbCloseArea() ), Nil )
RestArea( aArea )
Return aRet

/*/{Protheus.doc} I030LjCli
	Funcao Responsavel por Gerar Codigo de Cliente e Loja
	@type  Function
	@author Paulo V. Beraldo
	@since Abr/2021
	@version 1.00
	@param cCodCli, Caracter, Codigo do Cliente
	@param cLojCli, Caracter, Loja do Cliente
	@return aRet  , Vetor   , Vetor com as Informacoes: Codigo do Cliente, Loja do Cliente, Inclusao ou Alteracao no Cadastro de Cliente
/*/
Function I030LjCli( cCodCli, cLojCli )
Local aRet		:= {}
Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->( GetArea() )
Local cLojaUlt	:= Nil
Local cFilSA1	:= FWxFilial( 'SA1' )
Local nTamLoja	:= TamSx3( 'A1_LOJA' )[ 1 ]
Local lGetXnum	:= .F.

Default	cCodCli	:= ''
Default cLojCli := ''

If Empty( cCodCli )
	cCodCli := MATI030Num( cCode, @lGetXnum )
EndIf

If Empty( cLojCli )
	cLojCli := StrZero( 0 , nTamLoja )
EndIf

SA1->( dbSetOrder( 1 ) ) //A1_FILIAL + A1_COD + A1_LOJA
SA1->( dbSeek( cFilSA1 + cCodCli + cLojCli ) )
If SA1->( Found() )
	cLojaUlt := PadR( AllTrim( SA1->A1_LOJA ), nTamLoja )

	Do While SA1->( dbSeek( cFilSA1 + cCodCli + cLojaUlt ) )
		cLojaUlt := Padr( AllTrim( Soma1( cLojaUlt, nTamLoja ) ), nTamLoja )
	EndDo

	Aadd( aRet, cCodCli )
	Aadd( aRet, cLojaUlt )
	Aadd( aRet, .T. )
EndIf

RestArea( aAreaSA1 )
RestArea( aArea )
Return aRet

/*/{Protheus.doc} I030IsInteg
	Funcao Responsavel por Verificar se a Integracao Vetex Esta Habilitada
	@type  Function
	@author Paulo V. Beraldo
	@since Abr/2021
	@version 1.00
	@return lRet  , Boolean, Variavel Logica Indicando se a Integracao esta Ativa
/*/
Function I030IsInteg()
Local lRet	:= .F.
lRet := GetNewPar("MV_VALCNPJ","1") == "1" .And. GetNewPar("MV_VALCPF","1") == "1" .And. SuperGetMV( "MV_INTVTX", .t., .f.)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IntCliInt
Recebe um InternalID vendedor e retorna o código do Cliente.

@param   cInternalID InternalID recebido na mensagem.
@param   cRefer      Produto que enviou a mensagem
@param   cVersao     Versão da mensagem única (Default 2.000)

@author  Alessandro Afonso
@version P12
@since   26/05/2021
@return  aResult Array contendo no primeiro parâmetro uma variável
         lógica indicando se o registro foi encontrado no de/para.
         No segundo parâmetro uma variável array com a empresa,
         filial, o código do cliente e a loja do cliente.
@sample  Int30Vend('0ac5d186-7e7b-4549-8a8d-00e10f1be8ad', 'MASTERCRM') irá retornar
{.T., {'01', '01', '00001'}}
/*/
//-------------------------------------------------------------------
Function Int030Vend(cInternalID, cRefer)

   	Local   aTemp    := {}
   	Local   cTemp    := ''
	Local   cVend    := ''
   	Local   cAlias   := 'SA3'
   	Local   cField   := 'A3_COD'
	Local   nTamFil  := Len(FWxFilial("SA3")) 
	Local  aArea  	 := GetArea()
	Local  aAreaSA3	 := SA3->( GetArea() )
	Default cInternalID	:= ''
	Default cRefer		:= ''

	cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
	
  	If !Empty( cTemp )  
	 	aTemp := Separa(cTemp, '|')
		If Len(aTemp) >= 3
			cFilSA3 := Padr( aTemp[2],  nTamFil )
			SA3->(dbSetOrder(1))
			If SA3->(dbSeek(cFilSA3 + aTemp[3]))
				cVend := PadR(aTemp[3], TamSX3("A3_COD")[1])
			Endif
		Endif	
	Endif
	RestArea( aAreaSA3 )
	RestArea( aArea )
Return cVend
