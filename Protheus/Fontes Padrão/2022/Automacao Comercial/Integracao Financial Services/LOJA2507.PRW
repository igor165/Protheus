#INCLUDE "MSOBJECT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "LOJA2507.CH"

#DEFINE 	_L1_IFSANST_APROVADO 	"1"
#DEFINE 	_L1_IFSANST_REPROVADO 	"0"
#DEFINE 	_L1_IFSANST_MESA 		"2" 


Function LOJA2507()

Return  // "dummy" function - 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    |IntegDef         ºAutor  ³Vendas Clientes      º Data ³  29/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Metodo que gera/recebe o XML da fila EAI, conforme adapter config   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±  
±±ºParametros³ ExpC1 = CXML                                                       º±±
±±º          ³ ExpN2 = Tipo                                                       º±±
±±º          ³ ExpC2 = Tipo da Mensagem                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja/SigaFRT                                             		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Static Function IntegDef( cXml, nType, cTypeMsg )                

	Local lRet := .T.    //Retorno da função
	Local cXmlRet := ""  //XML de Retorno
	Local oXmlEAI := nil  //Objeto do XML EAI
	Local cPai := ""      //Nome da tag pai 
	Local aPagtos  := {} //Array com as formas de pagamentos  
	Local aDadosPar := {} //Array com os dados das parcelas
	Local nX := 0         //Variavel contadora
	Local cFilOrc := ""    //Filial do orcamento
	Local cOrcamento := ""    //Numero do orcamento  
	Local nContaPgto := 0 //Limite o array apgtos  
	Local nTamMa8Tipo := TamSX3("MA8_TIPO")[1]   
	Local aRefPess := {} //Array com as referencias pessoais 
	Local oTag := nil    //Tag de retorno
	Local cMsgRet := ""  //mensagem de retorno
	Local nValor := 0 //Valor do Bem/Compra  
	Local cStatAna	:= "" //Status da análise         
	Local cOperac := Lj2502GtOp() //Retorna o valor da operação
	Local cObsAnalise := Lj2502GtOb()	//Retorna o valor da observação       
	Local cAutAna := "" //Autorização da analise de credito     
	Local cRotina := "LOJA701" // Rotina que dispara o  processamento da mensagem (envio/recebimento)   
	Local oLjIntFSAn := nil //Objeto da analise de credito 
	Local cStatAnAtu := "" //Status da atualização da analise       
	Local cLogTEF := ""    //Variavel de log                  
	Local cMsg	:= ""	  //Mensagem de retorno
	Local cMsg1 := "" //Mensagem 1     
	Local aMsgWrn := {}  //Array de mensagens de advertencia
	Local aMsgErr := {} //Array de mensagens de erro 
	Local cPict14_5 := "@R 999999999.99999"
	
	conout ( 'Execucao da INTEGDEF - ' + FunName() + cValtoChar( Time() ) )        
	 
	//AnaliseCredito
	Do Case 
		// verificação do tipo de transação recebimento ou envio
		// trata o envio
		Case ( nType == TRANS_SEND )
		
		oXMLEAI := LjClXMLEai():New("BusinessRequest", , , , "AnaliseCredito", "BusinessContent") 
		oXMLEAI:AddTag("RetailProposalRegister", "", 0,, , 1, "1","")  //Adiciona a tag pai	                    
	
		conout ( 'inicio TRANS_SEND' + FunName() + " " + cValtoChar( Time() ) )       
	
		cFilOrc := SL1->L1_FILIAL    //Filial do orcamento
		cOrcamento := SL1->L1_NUM    //Numero do orcamento  
	
		oXMLEAI:AddTab("SA3",  1 , { || DbSeek(xFilial("SA3" + SL1->L1_VEND)) }, .f.)  //L4_FILIAL + L4_NUM
		oXMLEAI:AddTab("SL2",  1 , { || DbSeek(cFilOrc + cOrcamento) }, .f.)  //L2_FILIAL + L2_NUM
		oXMLEAI:AddTab("SL4",  1 , { || DbSeek(cFilOrc + cOrcamento) }, .f.)  //L4_FILIAL + L4_NUM
		oXMLEAI:AddTab("SA1",  1 , { || DbSeek(xFilial("SA1") +  SL1->(L1_CLIENTE + L1_LOJA)) }, .f.)  //A1_FILIAL+A1_COD+A1_LOJA                                                                                                                                        
		oXMLEAI:AddTab("MA7",  1 , { || DbSeek(xFilial("MA7") +  SL1->(L1_CLIENTE + L1_LOJA)) }, .f.)  //MA7_FILIAL+MA7_CODCLI+MA7_LOJA                                                                                                                                                                                                                                                                         
		oXMLEAI:AddTab("MAC",  2 , { || DbSeek(xFilial("MAC") +  SL1->(L1_CLIENTE + L1_LOJA) )}, .f.)  //MAC_FILIAL+MAC_CODCLI+MAC_LOJA                                                                                                                                                                                                                                                                                                                                                                                                           
		oXMLEAI:AddTab("MA8",  4 , { || DbSeek(xFilial("MA8") + PadR("1",nTamMa8Tipo) +   SL1->(L1_CLIENTE + L1_LOJA)) }, .f.)  //MA8_FILIAL + MA8_TIPO + MA8_CODCLI + MA8_LOJA                                                                                                                                                                                                                                                                                                                                                                                                          
		oXMLEAI:AddTab("MAD",  1 , { || DbSeek(xFilial("MAD") + MA8->MA8_CODEND) }, .f.)  //MAD_FILILA + MAD_CODEND                                                                                                                                                                                                                                                                                                                                                                                                         
		oXMLEAI:AddTab("MAB",  2 , { || DbSeek(xFilial("MAB") + SL1->(L1_CLIENTE + L1_LOJA)) }, .f.) ////MAB_FILIAL+MAB_CODCLI+MAB_LOJA    	                                                                                                                                 
			                                                                                               
		cPai := "RetailProposalRegister"  
			oXMLEAI:AddTag("User", cPai,1,, , 1, "1",{ || SuperGetMv('MV_LJUSRFS',,'')}, "C", 15, )
			oXMLEAI:AddTag("Password", cPai,2,, , 1, "1",{ ||SuperGetMv('MV_LJPSWFS',,'')}, "C", 15)
			oXMLEAI:AddTag("OriginSystem", cPai,3,, , 1, "1",{ || 'PRT' })  
			oXMLEAI:AddTag("OriginalContract", cPai,4,, , 1, "1",)   
			oXMLEAI:AddTag("ContractData", cPai,5,, , 1, "1",)  
	 
			cPai := "ContractData"   
				oXMLEAI:AddTag("CompanyCode", cPai,6,, , 1, "1",{ || SuperGetMv('MV_LJIFSEM',,'')}, "C",4) 
				oXMLEAI:AddTag("StoreCode", cPai,7,, , 1, "1",{ || '0000'}, "C",4) 
				oXMLEAI:AddTag("BranchCode", cPai,8,, , 1, "1",{ || SL1->L1_FILIAL}, "C",4)
				oXMLEAI:AddTag("RetailCompanyCode", cPai,9,, , 1, "1",{ ||cEmpAnt}, "C",2)  
				oXMLEAI:AddTag("OrderNumber", cPai,10,, , 1, "1",{ || SL1->L1_FILIAL+SL1->L1_NUM}, "C",20) 
				oXMLEAI:AddTag("AssetValue", cPai,11,, , 1, "1",{ || SL1->L1_VALBRUT+SL1->L1_DESCONT}, "N",15, cPict14_5)
				oXMLEAI:AddTag("NumberOfInstallments", cPai,12,, , 1, "1",{ || SL1->L1_PARCELA}, "N",2, "@R 99")
				oXMLEAI:AddTag("FinancingRate", cPai,13,, , 1, "1",{ || Lj2507DPar(9, cFilOrc, cOrcamento,@aDadosPar, @aPagtos)}, "N",9, "@R 99.999999") 
				oXMLEAI:AddTag("Product", cPai,14,, , 1, "1","", "C",2, )  
				oXMLEAI:AddTag("InstallmentValue", cPai,15,, , 1, "1",{ || Lj2507DPar(8, cFilOrc, cOrcamento,@aDadosPar, @aPagtos)}, "N",15, cPict14_5)
				oXMLEAI:AddTag("TacValue", cPai,16,, , 1, "1", , "N",15, cPict14_5)
				oXMLEAI:AddTag("ContractDate", cPai,17,, , 1, "1",{ || SL1->L1_EMISSAO} , "D")
				oXMLEAI:AddTag("FirstDueDate", cPai,18,, , 1, "1",{|| Lj2507DPar(3, cFilOrc, cOrcamento,@aDadosPar) }, "D") 
				oXMLEAI:AddTag("LastDueDate", cPai,19,, , 1, "1",{ || Lj2507DPar(4, cFilOrc, cOrcamento,@aDadosPar) } , "D")
				oXMLEAI:AddTag("iofFinanced", cPai,20,, , 1, "1",{ || NIL }, , "N",15, cPict14_5)
				oXMLEAI:AddTag("iofNotFinanced", cPai,21,, , 1, "1",{ || NIL },  "N",15, cPict14_5)
				oXMLEAI:AddTag("CollectionType", cPai,22,, , 1, "1",{ || 'FI' },  "C",3) 
				oXMLEAI:AddTag("AppropriationRate", cPai,23,, , 1, "1", ,  "C",3,)
				oXMLEAI:AddTag("DownPaymtDate", cPai,24,, , 1, "1",{ || Lj2507DPar(5, cFilOrc, cOrcamento,@aDadosPar)}, "D")
				oXMLEAI:AddTag("DownPaymtValue", cPai,25,, , 1, "1",{ || Lj2507DPar(6, cFilOrc, cOrcamento,@aDadosPar)}, "N",15, cPict14_5)
				oXMLEAI:AddTag("IncomesAppropriable", cPai,26,, , 1, "1",{ || SL1->L1_JUROS}, "N",15, cPict14_5)
				oXMLEAI:AddTag("CollectingBank", cPai,27,, , 1, "1",, "C",3) 
				oXMLEAI:AddTag("AssetDescription", cPai,28,, , 1, "1",, "C",40)
				oXMLEAI:AddTag("iofNaturalPerson", cPai,29,, , 1, "1",, "N",5, "@R 99.99")
				oXMLEAI:AddTag("iofCorporation", cPai,30,, , 1, "1",, "N",5, "@R 99.99")
				oXMLEAI:AddTag("CetRate", cPai,31,, , 1, "1",, "N",15, "@R 99999999.999999")
				oXMLEAI:AddTag("CommissionRate", cPai,32,, , 1, "1",, "N",5, "@R 99.99")
				oXMLEAI:AddTag("PercFine", cPai,33,, , 1, "1",, "N",5, "@R 99.99")
				oXMLEAI:AddTag("FineCollectionNumberDays", cPai,34,, , 1, "1",, "N",3, "@R 999")
				oXMLEAI:AddTag("FinancingTable", cPai,35,, , 1, "1",, "C",3, "@R 999") 
				oXMLEAI:AddTag("InsuranceValue", cPai,36,, , 1, "1",, "N",15, cPict14_5)
                oXMLEAI:AddTag("DutiesValue", cPai,37,, , 1, "1",, "N",15, cPict14_5) 
                oXMLEAI:AddTag("FinancedValue", cPai,38,, , 1, "1",{|| Lj2507DPar(1, cFilOrc, cOrcamento,@aDadosPar, @aPagtos)}, "N",15, cPict14_5)
                oXMLEAI:AddTag("CommissionValue", cPai,39,, , 1, "1",, "N",15, cPict14_5)
				oXMLEAI:AddTag("InsuranceCommValue", cPai,40,, , 1, "1",, "N",15, cPict14_5)
				oXMLEAI:AddTag("AuthorizationCode", cPai,41,, , 1, "1",, "C",10, "")
				oXMLEAI:AddTag("SaleDocument", cPai,42,, , 1, "1",, "C",10, "")  
				oXMLEAI:AddTag("stSaleDocument", cPai,43,, , 1, "1",, "C",1, "")  
				oXMLEAI:AddTag("DocumentIssueDate", cPai,44,, , 1, "1")
				oXMLEAI:AddTag("AcceptanceDispatchDate", cPai,45,, , 1, "1")    
				oXMLEAI:AddTag("ContractStatus", cPai,46,, , 1, "1",, "C",1)
				oXMLEAI:AddTag("SaleOrigin", cPai,47,, , 1, "1",{ || Lj2507DPar(7, cFilOrc, cOrcamento,@aDadosPar)}, "C",20)
				oXMLEAI:AddTag("InsuranceProduct", cPai,48,, , 1, "1",, "C",5) 
				oXMLEAI:AddTag("SaleAmount", cPai,49,, , 1, "1",, "N",15, cPict14_5)
				oXMLEAI:AddTag("SalespersonName", cPai,50,, , 1, "1",{ || SA3->A3_NOME}, "C",40)      
				oXMLEAI:AddTag("OrderType", cPai,51,, , 1, "1",{ || SL2->( !Eof() .AND. IIF(L2_ENTREGA <> '3', 'RETIRA', ''))}, "C",20)
				oXMLEAI:AddTag("NrDaysFreeInterests", cPai,52,, , 1, "1",, "N",3, "@R 999")
		   		oXMLEAI:AddTag("DiscountValue", cPai,53,, , 1, "1",{ || SL1->L1_DESCONT}, "N",15, cPict14_5)
				oXMLEAI:AddTag("Reanalysis", cPai,54,, , 1, "1", { || IIF(cOperac=="R","1","0") } ) 
				oXMLEAI:AddTag("ReanalysisObs", cPai,55,, , 1, "1", { || cObsAnalise } , "C", 255) 
		   	   
			cPai := "RetailProposalRegister"		   			 		   		
		   		oXMLEAI:AddTag("InstallmentsData", cPai,52,,{ || nContaPgto := 0,  nTamPagtos := Len(aPagtos), .T. } , 1, "1")  
		   		
		   		cPai := "InstallmentsData"
		   			oXMLEAI:AddTag("InstallmentDatum", cPai,53,,{|| nContaPgto := nContaPgto + 1, nContaPgto <= nTamPagtos }, 1, "N") 
			    	
			    	cPai := "InstallmentDatum" 
		   				oXMLEAI:AddTag("InstallmentNumber", cPai,01,,, 1, "1",{ || aPagtos[nContaPgto, 1]}, "N", ,"@R 99") 
			    		oXMLEAI:AddTag("DueDate", cPai,02,,, 1, "1",{ || aPagtos[nContaPgto, 2]},"D") 
			    		oXMLEAI:AddTag("ReceiptDate", cPai,03,,, 1, "1",{ || aPagtos[nContaPgto, 3]},"D") 
			    		oXMLEAI:AddTag("SubrogationDate", cPai,04,,, 1, "1") 
						oXMLEAI:AddTag("InstallmentValue", cPai,05,,, 1, "1",{ || aPagtos[nContaPgto, 4] },"N",15,cPict14_5)   
						oXMLEAI:AddTag("AmountPaid", cPai,06,,, 1, "1",{ || aPagtos[nContaPgto, 5]},"N",15, cPict14_5) 
						oXMLEAI:AddTag("SubrogationValue", cPai,07,,, 1, "1",) 
						oXMLEAI:AddTag("FlFinanced", cPai,08,,, 1, "1",{ || IIF( RTrim(aPagtos[nContaPgto, 8]) == "FI", "1", "0") },"C", 1)           
						oXMLEAI:AddTag("CollectionType", cPai,09,,, 1, "1",{ || aPagtos[nContaPgto, 8]},"C", 3)
			
			cPai := "RetailProposalRegister"			
				oXMLEAI:AddTag("CustomerData", cPai,60,"SA1",{ || SA1->( Found())   } , 1, "1")  
				
				cPai := "CustomerData"
					oXMLEAI:AddTag("CpfCnpj", cPai,61, , , 1, "1", { || SA1->A1_CGC} , "C", 14)  
					oXMLEAI:AddTag("Name", cPai,62,, , 1, "1", { || SA1->A1_NOME } , "C", 40) 
					oXMLEAI:AddTag("PersonType", cPai,64,, , 1, "1", { || SA1->( IIF( A1_TIPO <> "X", IIF(A1_PESSOA = "F", "0","1"), "")) } , "C", 1)
					oXMLEAI:AddTag("Gender", cPai,65,,{|| MA7->( Found() ) } , 1, "1", { || MA7->(IIF(MA7_SEXO == "1", "M",IIF(MA7_SEXO == "2", "F", ""))) } , "C", 1)
					oXMLEAI:AddTag("Nationality", cPai,66,, , 1, "1")
					oXMLEAI:AddTag("BirthDate", cPai,67,, , 1, "1", { || SA1->A1_DTNASC } , "D")
					oXMLEAI:AddTag("IdentityNumber", cPai,68,, , 1, "1", { || StrTran(StrTran(StrTran(SA1->A1_PFISICA, "."),"-"),"/") } , "C", 14)
					oXMLEAI:AddTag("IdIssuingBody", cPai,69,, , 1, "1")
					oXMLEAI:AddTag("IdentityState", cPai,70,, , 1, "1")
					oXMLEAI:AddTag("IdentityIssueDate", cPai,71,, , 1, "1")
					oXMLEAI:AddTag("MaritalStatus", cPai,72,,{ || MA7->(Found())  } , 1, "1",{ || MA7->(IIF( MA7_ECIVIL > "0" .AND. MA7_ECIVIL <= "3", Str(Val(MA7_ECIVIL)-1) , IIF(MA7_ECIVIL == "5", "3", "")))} ,"C",1)
					oXMLEAI:AddTag("NumberOfDependants", cPai,73,,{ || MAC->(Found()) } , 1, "1",{ || Lj2507NDep() } ,"N",2, "@R 99")
				 	oXMLEAI:AddTag("StreetAddress", cPai,74,, , 1, "1",{ || SA1->A1_END } ,"C",25)
				 	oXMLEAI:AddTag("AddressNumber", cPai,75,, , 1, "1", ,"C")
				 	oXMLEAI:AddTag("AddressDetail", cPai,76,, , 1, "1",{ || SA1->A1_COMPLEM} ,"C",15)
					oXMLEAI:AddTag("AddressDistrict",cPai,77, , ,1,"1",{ || SA1->A1_BAIRRO}, "C",20)
					oXMLEAI:AddTag("AddressPostalCode",cPai,78,, ,1,"1",{ || SA1->A1_CEP }, "C",8)
					oXMLEAI:AddTag("AddressCity",cPai,79, , ,1,"1",{ || SA1->A1_MUN }, "C",20)
					oXMLEAI:AddTag("AddressState",cPai,80, , ,1,"1",{ || SA1->A1_EST}, "C",2)
					oXMLEAI:AddTag("HomeDDD",cPai,81, , ,1,"1",{ || SA1->A1_DDD }, "C",4)
					oXMLEAI:AddTag("HomePhone",cPai,82, , ,1,"1",{ ||SA1->A1_TEL}, "C",15)
					oXMLEAI:AddTag("LengthOfResidence",cPai,83, ,{ || MA7->(Found()) } ,1,"1",{ || IIF(Val(MA7->MA7_TRES) > 0, AllTrim(Str(Val(MA7->MA7_TRES))), "" )}, "C",5) 
					oXMLEAI:AddTag("ResidenceType",cPai,84, , ,1,"1")
					oXMLEAI:AddTag("FathersName",cPai,85, ,{ || MA7->(Found()) } ,1,"1",{ || MA7->MA7_PAI }, "C",40)
					oXMLEAI:AddTag("MothersName",cPai,86, ,{ || MA7->(Found()) } ,1,"1",{ || MA7->MA7_MAE}, "C",40)
					oXMLEAI:AddTag("MailingAddress",cPai,87, ,	 ,1,"1",{ || MA7->(IIF( !Found() .OR. MA7_CARTA <> "2", "0", "1")) }, "C",1)
					oXMLEAI:AddTag("MailingStreet",cPai,88, ,	{ || MA7->(!Found())  .OR. (MA7->MA7_CARTA <> "2" .OR. ( MA8->(Found()) .AND. MAD->(Found() ) ) ) } ,1,"1",{ || IIF(MAD->(Found()) .AND. MA7->MA7_CARTA == "2",MAD->MAD_END , SA1->A1_END)  }, "C",25)
					oXMLEAI:AddTag("MailingNumber",cPai,89, ,	 ,1,"1")
					oXMLEAI:AddTag("MailingDetail",cPai,93, ,	{ || MA7->(!Found())  .OR. (MA7->MA7_CARTA <> "2" .OR. ( MA8->(Found()) .AND. MAD->(Found() ) ) ) } ,1,"1",{ || IIF(MAD->(Found()) .AND. MA7->MA7_CARTA == "2","" , SA1->A1_COMPLEM)  }, "C",15)
					oXMLEAI:AddTag("MailingDistrict",cPai,95, ,	{ || MA7->(!Found())  .OR. (MA7->MA7_CARTA <> "2" .OR. ( MA8->(Found()) .AND. MAD->(Found() ) ) ) },1,"1",{ ||  IIF(MAD->(Found()) .AND. MA7->MA7_CARTA == "2", MAD->MAD_BAIRRO , SA1->A1_BAIRRO)  }, "C",20)
					oXMLEAI:AddTag("MailingPostalCode",cPai,97,,{ || MA7->(!Found())  .OR. (MA7->MA7_CARTA <> "2" .OR. ( MA8->(Found()) .AND. MAD->(Found() ) ) ) } ,1,"1",{ || IIF(MAD->(Found()) .AND. MA7->MA7_CARTA == "2",MAD->MAD_CEP , SA1->A1_CEP)  }, "C",8)
					oXMLEAI:AddTag("MailingCity",cPai,99, ,		{ || MA7->(!Found())  .OR. (MA7->MA7_CARTA <> "2" .OR. ( MA8->(Found()) .AND. MAD->(Found() ) ) ) } ,1,"1",{ || IIF(MAD->(Found()) .AND. MA7->MA7_CARTA == "2",MAD->MAD_CID , SA1->A1_MUN)  }, "C",20)
					oXMLEAI:AddTag("MailingState",cPai,101, ,	{ || MA7->(!Found())  .OR. (MA7->MA7_CARTA <> "2" .OR. ( MA8->(Found()) .AND. MAD->(Found() ) ) ) } ,1,"1",{ || IIF(MAD->(Found()) .AND. MA7->MA7_CARTA == "2",MAD->MAD_UF , SA1->A1_EST)  }, "C",2)
					oXMLEAI:AddTag("CompanyName",cPai,103, ,{ || MA8->(Found()) } ,1,"1",{ || MA8->MA8_EMPRES}, "C",40)
					oXMLEAI:AddTag("CompanyType",cPai,104, , ,1,"1")
					oXMLEAI:AddTag("CompanyStreet",cPai,105, , { || MA8->(Found()) .AND. MAD->(Found()) } ,1,"1",{ || MAD->MAD_END}, "C",25)
					oXMLEAI:AddTag("CompanyNumber",cPai,106, , ,1,"1")
					oXMLEAI:AddTag("CompanyDetail",cPai,107, , ,1,"1")
					oXMLEAI:AddTag("CompanyDistrict",cPai,108, ,{ || MA8->(Found()) .AND. MAD->(Found()) },1,"1",{ || MAD->MAD_BAIRRO}, "C",20)
					oXMLEAI:AddTag("CompanyPostalCode",cPai,109, ,{ || MA8->(Found()) .AND. MAD->(Found()) },1,"1",{ || MAD->MAD_CEP}, "C",8)
					oXMLEAI:AddTag("CompanyCity",cPai,110, ,{ || MA8->(Found()) .AND. MAD->(Found()) },1,"1",{ || MAD->MAD_CID}, "C",20)
					oXMLEAI:AddTag("CompanyState",cPai,111, ,{ || MA8->(Found()) .AND. MAD->(Found()) },1,"1",{ || MAD->MAD_UF}, "C",2)
					oXMLEAI:AddTag("CompanyDDD",cPai,112, ,{ || MA8->(Found()) .AND. MAD->(Found()) },1,"1",{ || StrTran(StrTran(StrTran(MAD->MAD_DDD,"-"),")"),"(") }, "C",4)
					oXMLEAI:AddTag("CompanyPhone",cPai,113, ,{ || MA8->(Found()) .AND. MAD->(Found()) }  ,1,"1",{ || MAD->MAD_TEL}, "C",15)
					oXMLEAI:AddTag("CompanyExtension",cPai,114, ,{ || MA8->(Found()) .AND. MAD->(Found()) },1,"1",{ || MAD->MAD_RAMAL}, "C",5)
					oXMLEAI:AddTag("JobPosition",cPai,115, , ,1,"1", )
					oXMLEAI:AddTag("LengthOfService",cPai,116, ,{ || MA8->(Found() .AND. !Empty(MA8_DTADM))} ,1,"1",{ || LTrim(Str(LojDifDtMe(MA8->MA8_DTADM, dDatabase)))}, "C",5)
					oXMLEAI:AddTag("DateOfHire",cPai,117, ,{ || MA8->(Found())} ,1,"1",{ || MA8->MA8_DTADM }, "D")
					oXMLEAI:AddTag("SalaryAmount",cPai,118, ,{ || MA8->(Found())} ,1,"1",{ ||MA8->MA8_RENDA }, "N",20,"@R 99999999999999.99999")
					oXMLEAI:AddTag("VehicleQuantity",cPai,119, , ,1,"1")
					oXMLEAI:AddTag("BankReference1",cPai,120, , ,1,"1")
					oXMLEAI:AddTag("BranchReference1",cPai,121, , ,1,"1")
					oXMLEAI:AddTag("AccountReference1",cPai,122, , ,1,"1")
					oXMLEAI:AddTag("BankReferencePhone1",cPai,123, , ,1,"1")
					oXMLEAI:AddTag("BankReferenceExtension1",cPai,124, , ,1,"1")
					oXMLEAI:AddTag("BankReference2",cPai,125, , ,1,"1")
					oXMLEAI:AddTag("BranchReference2",cPai,126, , ,1,"1")
					oXMLEAI:AddTag("AccountReference2",cPai,127, , ,1,"1")
					oXMLEAI:AddTag("BankReferencePhone2",cPai,128, , ,1,"1")
					oXMLEAI:AddTag("BankReferenceExtension2",cPai,129, , ,1,"1")
					oXMLEAI:AddTag("CommercialReference1",cPai,130, , ,1,"1")
					oXMLEAI:AddTag("CommercialReferenceAddress1",cPai,131, , ,1,"1")
					oXMLEAI:AddTag("CommercialReferencePhone1",cPai,132, , ,1,"1")
					oXMLEAI:AddTag("CommercialReferenceExtension1",cPai,133, , ,1,"1")
					oXMLEAI:AddTag("CommercialReference2",cPai,134, , ,1,"1")
					oXMLEAI:AddTag("CommercialReferenceAddress2",cPai,135, , ,1,"1")
					oXMLEAI:AddTag("CommercialReferencePhone2",cPai,136, , ,1,"1")
					oXMLEAI:AddTag("CommercialReferenceExtension2",cPai,137, , ,1,"1")     
					oXMLEAI:AddTag("PersonalReference1",cPai,138, , ,1,"1",{ || Lj2507RefP(@aRefPess,1,1)}, "C",40)
					oXMLEAI:AddTag("PersonalReferenceAddress1",cPai,139, , ,1,"1")
					oXMLEAI:AddTag("PersonalReferencePhone1",cPai,142, , ,1,"1",{ || Lj2507RefP(@aRefPess,1,2)}, "C",15)
					oXMLEAI:AddTag("PersonalReference2",cPai,143, , ,1,"1",{ || Lj2507RefP(@aRefPess,2,1) }, "C",40)
					oXMLEAI:AddTag("PersonalReferenceAddress2",cPai,144, , ,1,"1")
					oXMLEAI:AddTag("PersonalReferencePhone2",cPai,147, , ,1,"1",{ || Lj2507RefP(@aRefPess,2,2)}, "C",15)
					oXMLEAI:AddTag("BankReferenceDDD1",cPai,148, , ,1,"1")
					oXMLEAI:AddTag("BankReferenceDDD2",cPai,149, , ,1,"1")
					oXMLEAI:AddTag("CommercialReferenceDDD1",cPai,150, , ,1,"1")
					oXMLEAI:AddTag("CommercialReferenceDDD2",cPai,151, , ,1,"1")
					oXMLEAI:AddTag("PersonalReferenceDDD1",cPai,152, , ,1,"1",{ || Lj2507RefP(@aRefPess,1,3) }, "C",4)
					oXMLEAI:AddTag("PersonalReferenceDDD2",cPai,153, , ,1,"1",{ || Lj2507RefP(@aRefPess,2,3) },"C",4)
					oXMLEAI:AddTag("PersonalReferenceExtension1",cPai,154, , ,1,"1",{ || Lj2507RefP(@aRefPess,1,4) }, "C",5)
					oXMLEAI:AddTag("PersonalReferenceExtension2",cPai,155, , ,1,"1",{ || Lj2507RefP(@aRefPess,2,4) }, "C",5)
					oXMLEAI:AddTag("PersonalReference3",cPai,156, , ,1,"1",{ || Lj2507RefP(@aRefPess,3,1)  }, "C",40)
					oXMLEAI:AddTag("PersonalReferenceAddress3",cPai,157, , ,1,"1")
					oXMLEAI:AddTag("PersonalReferencePhone3",cPai,160, , ,1,"1",{ || Lj2507RefP(@aRefPess,3,2) }, "C",15)
					oXMLEAI:AddTag("PersonalReferenceDDD3",cPai,161, , ,1,"1",{ || Lj2507RefP(@aRefPess,3,3) }, "C",4)
					oXMLEAI:AddTag("PersonalReferenceExtension3",cPai,162, , ,1,"1",{ || Lj2507RefP(@aRefPess,3,4)}, "C",5)
					oXMLEAI:AddTag("PersonalReferenceMobileDDD1",cPai,163, , ,1,"1")
					oXMLEAI:AddTag("PersonalReferenceMobile1",cPai,164, , ,1,"1")
					oXMLEAI:AddTag("PersonalReferenceMobileDDD2",cPai,165, , ,1,"1")
					oXMLEAI:AddTag("PersonalReferenceMobile2",cPai,166, , ,1,"1")
					oXMLEAI:AddTag("PersonalReferenceMobileDDD3",cPai,167, , ,1,"1")
					oXMLEAI:AddTag("PersonalReferenceMobile3",cPai,168, , ,1,"1")
					oXMLEAI:AddTag("PersonalReferenceEmail",cPai,169, , ,1,"1") 
					oXMLEAI:AddTag("MobileNumberDDD",cPai,170, ,{ || MA7->(Found() .AND. !Empty(MA7_CELULA) .AND. At("(", MA7_CELULA) > 0  .AND. At(")",MA7_CELULA) > 0 ) } ,1,"1",{ || Subst(MA7->MA7_CELULA,At("(", MA7->MA7_CELULA)+1,RAt(")",MA7->MA7_CELULA) - (At("(", MA7->MA7_CELULA)+1) ) },"C",4)
					oXMLEAI:AddTag("MobilePhoneNumber",cPai,171, , { || MA7->(Found() .AND. !Empty(MA7_CELULA) .AND. At("(", MA7_CELULA) > 0 .AND. At(")",MA7_CELULA) > 0)},1,"1",{ || StrTran(StrTran(Subst(MA7->MA7_CELULA, At(")", MA7->MA7_CELULA)+1),"-")," ")  },"C",9)
					
				cPai := "RetailProposalRegister"			
				oXMLEAI:AddTag("GuarantorData",cPai,172, , ,1,"1")  
				
				cPai := "GuarantorData"				
					oXMLEAI:AddTag("CpfCnpj",cPai,173, , ,1,"1",,"C",14)
					oXMLEAI:AddTag("Name",cPai,174, , ,1,"1",,"C",40)
					oXMLEAI:AddTag("PersonType",cPai,175, , ,1,"1",,"C",1)
					oXMLEAI:AddTag("Gender",cPai,177, , ,1,"1",,"C",1)
					oXMLEAI:AddTag("Nationality",cPai,178, , ,1,"1",,"C",15)
					oXMLEAI:AddTag("BirthDate",cPai,179, , ,1,"1",,"C",10)
					oXMLEAI:AddTag("IdentityNumber",cPai,180, , ,1,"1",,"C",14)
					oXMLEAI:AddTag("IdIssuingBody",cPai,181, , ,1,"1",,"C",5)
					oXMLEAI:AddTag("IdentityState",cPai,182, , ,1,"1",,"C",2)
					oXMLEAI:AddTag("IdentityIssueDate",cPai,183, , ,1,"1",,"C",10)
					oXMLEAI:AddTag("MaritalStatus",cPai,184, , ,1,"1",,"C",3)
					oXMLEAI:AddTag("NumberOfDependants",cPai,185, , ,1,"1",,"N",2)
					oXMLEAI:AddTag("StreetAddress",cPai,186, , ,1,"1",,"C",25)
					oXMLEAI:AddTag("AddressNumber",cPai,187, , ,1,"1",,"C",5)
					oXMLEAI:AddTag("AddressDetail",cPai,188, , ,1,"1",,"C",15)
					oXMLEAI:AddTag("AddressDistrict",cPai,189, , ,1,"1",,"C",20)
					oXMLEAI:AddTag("AddressPostalCode",cPai,190, , ,1,"1",,"C",8)
					oXMLEAI:AddTag("AddressCity",cPai,191, , ,1,"1",,"C",20)
					oXMLEAI:AddTag("AddressState",cPai,192, , ,1,"1",,"C",2)
					oXMLEAI:AddTag("HomeDDD",cPai,193, , ,1,"1",,"C",4)
					oXMLEAI:AddTag("HomePhone",cPai,194, , ,1,"1",,"C",15)
					oXMLEAI:AddTag("LengthOfResidence",cPai,195, , ,1,"1",,"C",5)
					oXMLEAI:AddTag("ResidenceType",cPai,196, , ,1,"1",,"C",4)
					oXMLEAI:AddTag("FathersName",cPai,197, , ,1,"1",,"C",40)
					oXMLEAI:AddTag("MothersName",cPai,198, , ,1,"1",,"C",40)
					oXMLEAI:AddTag("MailingAddress",cPai,199, , ,1,"1",,"C",1)
					oXMLEAI:AddTag("MailingStreet",cPai,200, , ,1,"1",,"C",25)
					oXMLEAI:AddTag("MailingNumber",cPai,201, , ,1,"1",,"C",5)
					oXMLEAI:AddTag("MailingDetail",cPai,203, , ,1,"1",,"C",15)
					oXMLEAI:AddTag("MailingDistrict",cPai,204, , ,1,"1",,"C",20)
					oXMLEAI:AddTag("MailingPostalCode",cPai,205, , ,1,"1",,"C",8)
					oXMLEAI:AddTag("MailingCity",cPai,206, , ,1,"1",,"C",20)
					oXMLEAI:AddTag("MailingState",cPai,207, , ,1,"1",,"C",2)
					oXMLEAI:AddTag("CompanyName",cPai,208, , ,1,"1",,"C",40)
					oXMLEAI:AddTag("CompanyType",cPai,209, , ,1,"1",,"C",1)
					oXMLEAI:AddTag("CompanyStreet",cPai,210, , ,1,"1",,"C",25)
					oXMLEAI:AddTag("CompanyNumber",cPai,211, , ,1,"1",,"C",5)
					oXMLEAI:AddTag("CompanyDetail",cPai,212, , ,1,"1",,"C",15)
					oXMLEAI:AddTag("CompanyDistrict",cPai,213, , ,1,"1",,"C",20)
					oXMLEAI:AddTag("CompanyPostalCode",cPai,214, , ,1,"1",,"C",8)
					oXMLEAI:AddTag("CompanyCity",cPai,215, , ,1,"1",,"C",20)
					oXMLEAI:AddTag("CompanyState",cPai,216, , ,1,"1",,"C",2)
					oXMLEAI:AddTag("CompanyDDD",cPai,217, , ,1,"1",,"C",4)
					oXMLEAI:AddTag("CompanyPhone",cPai,218, , ,1,"1",,"C",15)
					oXMLEAI:AddTag("CompanyExtension",cPai,219, , ,1,"1",,"C",5)
					oXMLEAI:AddTag("JobPosition",cPai,220, , ,1,"1",,"C",2)
					oXMLEAI:AddTag("LengthOfService",cPai,221, , ,1,"1",,"C",5) 
					oXMLEAI:AddTag("DateOfHire",cPai,222, , ,1,"1",,"N",20)
					oXMLEAI:AddTag("SalaryAmount",cPai,223, , ,1,"1",,"N",20)
					oXMLEAI:AddTag("VehicleQuantity",cPai,224, , ,1,"1",,"N",2)
					oXMLEAI:AddTag("BankReference1",cPai,225, , ,1,"1",,"C",40)
					oXMLEAI:AddTag("BranchReference1",cPai,226, , ,1,"1",,"C",10)
					oXMLEAI:AddTag("AccountReference1",cPai,227, , ,1,"1",,"C",14)
					oXMLEAI:AddTag("BankReferencePhone1",cPai,228, , ,1,"1",,"C",15)
					oXMLEAI:AddTag("BankReferenceExtension1",cPai,229, , ,1,"1",,"C",5)
					oXMLEAI:AddTag("BankReference2",cPai,230, , ,1,"1",,"C",40)
					oXMLEAI:AddTag("BranchReference2",cPai,231, , ,1,"1",,"C",10)
					oXMLEAI:AddTag("AccountReference2",cPai,232, , ,1,"1",,"C",14)
					oXMLEAI:AddTag("BankReferencePhone2",cPai,233, , ,1,"1",,"C",15)
					oXMLEAI:AddTag("BankReferenceExtension2",cPai,234, , ,1,"1",,"C",5)
					oXMLEAI:AddTag("CommercialReference1",cPai,235, , ,1,"1",,"C",40)
					oXMLEAI:AddTag("CommercialReferenceAddress1",cPai,236, , ,1,"1",,"C",45)
					oXMLEAI:AddTag("CommercialReferencePhone1",cPai,237, , ,1,"1",,"C",15)
					oXMLEAI:AddTag("CommercialReferenceExtension1",cPai,238, , ,1,"1",,"C",5)
					oXMLEAI:AddTag("CommercialReference2",cPai,239, , ,1,"1",,"C",40)
					oXMLEAI:AddTag("CommercialReferenceAddress2",cPai,240, , ,1,"1",,"C",45)
					oXMLEAI:AddTag("CommercialReferencePhone2",cPai,241, , ,1,"1",,"C",15)
					oXMLEAI:AddTag("CommercialReferenceExtension2",cPai,242, , ,1,"1",,"C",5)
					oXMLEAI:AddTag("PersonalReference1",cPai,243, , ,1,"1",,"C",40)
					oXMLEAI:AddTag("PersonalReferenceAddress1",cPai,244, , ,1,"1",,"C",45)
					oXMLEAI:AddTag("PersonalReferencePhone1",cPai,245, , ,1,"1",,"C",15)
					oXMLEAI:AddTag("PersonalReference2",cPai,246, , ,1,"1",,"C",40)
					oXMLEAI:AddTag("PersonalReferenceAddress2",cPai,247, , ,1,"1",,"C",45)
					oXMLEAI:AddTag("PersonalReferencePhone2",cPai,248, , ,1,"1",,"C",15)
					oXMLEAI:AddTag("BankReferenceDDD1",cPai,249, , ,1,"1",,"C",4)
					oXMLEAI:AddTag("BankReferenceDDD2",cPai,250, , ,1,"1",,"C",4)
					oXMLEAI:AddTag("CommercialReferenceDDD1",cPai,251, , ,1,"1",,"C",4)
					oXMLEAI:AddTag("CommercialReferenceDDD2",cPai,252, , ,1,"1",,"C",4)
					oXMLEAI:AddTag("PersonalReferenceDDD1",cPai,253, , ,1,"1",,"C",4)
					oXMLEAI:AddTag("PersonalReferenceDDD2",cPai,254, , ,1,"1",,"C",4)
					oXMLEAI:AddTag("PersonalReferenceExtension1",cPai,255, , ,1,"1",,"C",5)
					oXMLEAI:AddTag("PersonalReferenceExtension2",cPai,256, , ,1,"1",,"C",5)
					oXMLEAI:AddTag("PersonalReference3",cPai,257, , ,1,"1",,"C",40)
					oXMLEAI:AddTag("PersonalReferenceAddress3",cPai,258, , ,1,"1",,"C",45)
					oXMLEAI:AddTag("PersonalReferencePhone3",cPai,259, , ,1,"1",,"C",15)
					oXMLEAI:AddTag("PersonalReferenceDDD3",cPai,260, , ,1,"1",,"C",4)
					oXMLEAI:AddTag("PersonalReferenceExtension3",cPai,261, , ,1,"1",,"C",5)
					oXMLEAI:AddTag("PersonalReferenceMobileDDD1",cPai,262, , ,1,"1",,"C",4)
					oXMLEAI:AddTag("PersonalReferenceMobile1",cPai,263, , ,1,"1",,"C",9)
					oXMLEAI:AddTag("PersonalReferenceMobileDDD2",cPai,264, , ,1,"1",,"C",4)
					oXMLEAI:AddTag("PersonalReferenceMobile2",cPai,265, , ,1,"1",,"C",9)
					oXMLEAI:AddTag("PersonalReferenceMobileDDD3",cPai,266, , ,1,"1",,"C",4)
					oXMLEAI:AddTag("PersonalReferenceMobile3",cPai,267, , ,1,"1",,"C",9)
					oXMLEAI:AddTag("PersonalReferenceEmail",cPai,268, , ,1,"1",,"C",40)
					oXMLEAI:AddTag("MobileNumberDDD",cPai,269, , ,1,"1",,"C",4)
					oXMLEAI:AddTag("MobilePhoneNumber",cPai,270, , ,1,"1",,"C",9)  
	
				cPai := "RetailProposalRegister"								
					oXMLEAI:AddTag("ProductsInvoiceData",cPai,270,"SL2", ,1,"1",,"D",)
					
					cPai := "ProductsInvoiceData"
					oXMLEAI:AddTag("ProductInvoiceData",cPai,271,"SL2",{ || (!Eof() .AND. L2_FILIAL+L2_NUM == SL1->(L1_FILIAL + L1_NUM))} ,1,"N")
						
						cPai := "ProductInvoiceData"
						oXMLEAI:AddTag("Code",cPai,272, , ,1,"1",{ || SL2->L2_PRODUTO}, "C",40)
						oXMLEAI:AddTag("Description",cPai,273, , ,1,"1",{ || SL2->L2_DESCRI}, "C",255)
						oXMLEAI:AddTag("Unit",cPai,274, , ,1,"1",{ || SL2->L2_UM}, "C",3)
						oXMLEAI:AddTag("Quantity",cPai,275, , ,1,"1",{ || AllTrim( IIF(SL2->L2_QUANT > 99,Str(SL2->L2_QUANT,4,0),Transform( SL2->L2_QUANT, "@R 99.99"))) }, "C",4)
						oXMLEAI:AddTag("UnitValue",cPai,276, , ,1,"1",{ || SL2->L2_VRUNIT + SL2->((L2_VALIPI + L2_ICMSRET)/ L2_QUANT)}, "N",9, "@R 999999.99")
						oXMLEAI:AddTag("TotalValue",cPai,277, , ,1,"1",{ || SL2->L2_VLRITEM + SL2->L2_VALIPI + SL2->L2_ICMSRET}, "N",20, "@R 99999999999999.99999") 
						
			cPai := "RetailProposalRegister"			
					oXMLEAI:AddTag("Conveyance",cPai,278, , ,1,"1",,"C")
					
					cPai := "Conveyance"
						oXMLEAI:AddTag("Brand",cPai,279, , ,1,"1",,"C",20)
						oXMLEAI:AddTag("model",cPai,280, , ,1,"1",,"C",150)
						oXMLEAI:AddTag("Year",cPai,281, , ,1,"1",,"C",4)
						oXMLEAI:AddTag("color",cPai,282, , ,1,"1",,"C",20)
						oXMLEAI:AddTag("LicensePlate",cPai,283, , ,1,"1",,"C",10)
						oXMLEAI:AddTag("Chassis",cPai,284, , ,1,"1",,"C",30)
						oXMLEAI:AddTag("ConveyanceDescription",cPai,285, , ,1,"1",,"C",40)
						oXMLEAI:AddTag("ProductValue",cPai,286, , ,1,"1",,"N",14,5)
						oXMLEAI:AddTag("IssueDate",cPai,287, , ,1,"1",,"C",10)
						oXMLEAI:AddTag("Status",cPai,288, , ,1,"1",,"C",1)
						oXMLEAI:AddTag("ModelYear",cPai,289, , ,1,"1",,"C",4)
						oXMLEAI:AddTag("InsuranceName",cPai,290, , ,1,"1",,"C",30)
						oXMLEAI:AddTag("InsuranceDueDate",cPai,291, , ,1,"1",,"C",10)
						oXMLEAI:AddTag("VehicleInsuranceValue",cPai,292, , ,1,"1",,"N",14.5)
						oXMLEAI:AddTag("OtherVehicleExpValue",cPai,293, , ,1,"1",,"N",14.5)
						oXMLEAI:AddTag("VehicleFuel",cPai,294, , ,1,"1",,"C",10)
						oXMLEAI:AddTag("RenavamCode",cPai,295, , ,1,"1",,"C",20)
						oXMLEAI:AddTag("VehicleType",cPai,296, , ,1,"1",,"C",1)
						oXMLEAI:AddTag("ManufacturingType",cPai,297, , ,1,"1",,"C",1)
						oXMLEAI:AddTag("FiscalInvoiceValue",cPai,298, , ,1,"1",,"N",14.5)
						oXMLEAI:AddTag("FiscalInvoiceDate",cPai,299, , ,1,"1",,"C",10)
						oXMLEAI:AddTag("FiscalInvoice  ",cPai,300, , ,1,"1",,"C",10)
						oXMLEAI:AddTag("ApprovalNumber",cPai,301, , ,1,"1",,"C",9)
						oXMLEAI:AddTag("WarrantyStatus",cPai,302, , ,1,"1",,"C",1)
						oXMLEAI:AddTag("ReturnDate",cPai,303, , ,1,"1",,"C",10)
						oXMLEAI:AddTag("BrandCode",cPai,304, , ,1,"1",,"C",3)
						oXMLEAI:AddTag("ModelCode",cPai,305, , ,1,"1",,"C",3)
						oXMLEAI:AddTag("AppraisedValue",cPai,306, , ,1,"1",,"N",15.4)
						oXMLEAI:AddTag("YardCode",cPai,307, , ,1,"1",,"C",3)
						oXMLEAI:AddTag("SaleDate",cPai,308, , ,1,"1",,"C",10)
						oXMLEAI:AddTag("SaleAmount",cPai,309, , ,1,"1",,"N",14.5)
						oXMLEAI:AddTag("DeliveryStatus",cPai,310, , ,1,"1",,"C",1)
						oXMLEAI:AddTag("SeizureProcessStatus",cPai,311, , ,1,"1",,"C",1)
						oXMLEAI:AddTag("PlateStateCode",cPai,312, , ,1,"1",,"C",2)
						oXMLEAI:AddTag("ChassisRenumberingFl",cPai,313, , ,1,"1",,"C",1)
						oXMLEAI:AddTag("EngineCode",cPai,314, , ,1,"1",,"C",30)
						oXMLEAI:AddTag("VehicleDebtFineValue",cPai,315, , ,1,"1",,"N",14.5)
						oXMLEAI:AddTag("IpvaDebtValue",cPai,316, , ,1,"1",,"N",14.5)
						oXMLEAI:AddTag("CompulsoryInsDebtValue",cPai,317, , ,1,"1",,"N",14.5)
						oXMLEAI:AddTag("LicensingDebtValue",cPai,318, , ,1,"1",,"N",14.5)
						oXMLEAI:AddTag("VehicleDutNumber",cPai,319, , ,1,"1",,"N",20)
						oXMLEAI:AddTag("VehicleDutCopyNumber",cPai,320, , ,1,"1",,"N",2)
						oXMLEAI:AddTag("VehicleInspectionChngCode",cPai,321, , ,1,"1",,"C",30)
						oXMLEAI:AddTag("VehicleTypeNumber",cPai,322, , ,1,"1",,"N",4)
						oXMLEAI:AddTag("VehicleMileageNumber",cPai,323, , ,1,"1",,"N",7)
						oXMLEAI:AddTag("VehicleVersionDescrip",cPai,324, , ,1,"1",,"C",20)
						oXMLEAI:AddTag("NumberOfVehicleDoors",cPai,325, , ,1,"1",,"N",2)
						oXMLEAI:AddTag("LicenseStateCode",cPai,326, , ,1,"1",,"C",2)
						oXMLEAI:AddTag("ZeroMileageFl",cPai,327, , ,1,"1",,"C",1)
	
		cXMLRet := oXMLEAI:GerarXML()	  	
		conout ( 'fim TRANS_SEND' + FunName() + " " + cValtoChar( Time() ) )    
		
		Case ( nType == TRANS_RECEIVE )
	
		Do Case 
		
	//		EAI_MESSAGE_WHOIS == retorno da versão do XML para o solicitante
	//		condição tratada pelo FrameWork
			Case ( cTypeMsg == EAI_MESSAGE_WHOIS ) 
				cXmlRet := "1.000"
	
	//		EAI_MESSAGE_RESPONSE == resposta de uma BUSINESS_MESSAGE
	
			Case ( cTypeMsg == EAI_MESSAGE_RESPONSE )     //ler a response

	
			//fim do processamento da resposta XML
	
	//		EAI_MESSAGE_RECEIPT == aviso do recebimento do XML
	//		nos casos assíncronos, onde o processamento só é realizado dps
			Case ( cTypeMsg == EAI_MESSAGE_RECEIPT )
				cXmlRet := ""  
				
	//		EAI_MESSAGE_BUSINESS == necessário tratar o xml
	//		e realizar a operação
			Case ( cTypeMsg == EAI_MESSAGE_BUSINESS )
				//Testes de comunicação entre 2 ambientes, em virtude dos servicos  financial estarem
				//off-line, será retidado apos finalizacao dos testes
				
				conout ( 'inicio EAI_MESSAGE_BUSINESS - RECEIVE ' + FunName() + " " + cValtoChar( Time() ) )  
				
				conout ( 'fim EAI_MESSAGE_BUSINESS - RECEIVE' + cValtoChar( Time() ) )
	
		End Case	
	End Case
	
	If oXMLEAI <> NIL  
		oXMLEAI:Destruct()
		FreeObj(oXMLEAI)
		oXMLEAI := NIL
	EndIf
	
	
	conout ( 'Fim da INTEGDEF' + cValtoChar( Time() ) )         

Return { lRet, cXmlRet }          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    |Lj2507DPar       ºAutor  ³Vendas Clientes      º Data ³  09/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que retorna os dados das parcelas                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±  
±±ºParametros³ ExpN1 = Posicao do array dos dados do financiamento                º±±
±±º          ³ ExpC2 = Filial do Orcamento                                        º±±
±±º          ³ ExpC3 = Numero do Orcamento                                        º±±   
±±º          ³ ExpA4 = Dados do Financiamento                                     º±±
±±º          ³ ExpA5 = Dados das Parcelas                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja/SigaFRT                                             		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Static Function Lj2507DPar(nOpc, cFilOrc, cOrcamento, aDadosPar, aPagtos)     

	Local aArea := Nil        //Workarea Ativa
	Local aAreaSL4 := Nil     //WorkArea SL4
	Local uRet := nil         //Retorno da Função
	Local nTamAdmin := TamSx3("AE_COD")[1]  //Tamanho do campo da Administradora
	Local dDtVenc := CtoD("") //Data de Vencimento da Parcela   
	Local cFinanc := ""       //Indica se a Parcela e Financiada
	Local nValPago := 0       //Valor Pago
	Local lFormaId := FieldPos("L4_FORMAID") > 0  //Id da Forma
	Local aAreaSAE := nil     //WorkArea SAE
	   
	If Len(aDadosPar) = 0
		//Carrega os Dados das parcelas fianciadas   
		
		aArea := GetArea() 
		aAreaSL4 := SL4->(GetArea())
		
		aDadosPar := { 0,; //Valor Financiado    1
						0,; //Parcelas         2
						nil,; //Primeiro Pagamento  3
						nil,; //Ultimo Pagamento 4
						nil,; //Data da Entrada   - FORMA <> FI FI COM DATA     5
						0,; //Valor da Entrada    6
						"",; //Financeira := "" 7 
						0,; //Valor das pARCELAS
						0 ; //Taxa mensal de financiamento
						}
						                                                                                                                                	
		Do While SL4->(!Eof() .and. L4_FILIAL == cFilOrc .And. L4_NUM ==  cOrcamento)    
		
			If RTrim(SL4->L4_FORMA) == "FI"
				dDtVenc := CtoD("") 
				nValPago := 0
				If SL1->L1_EMISSAO == SL4->L4_DATA
					aDadosPar[6] += SL4->L4_VALOR 
					aDadosPar[3] := SL4->L4_DATA
					aDadosPar[5] := SL4->L4_DATA 
					dDtVenc := SL4->L4_DATA 
					nValPago := SL4->L4_VALOR
				EndIf 
				    
				aDadosPar[1] += SL4->L4_VALOR   
				aDadosPar[2]++   
				
				If Empty(aDadosPar[3]) .Or. aDadosPar[3] > SL4->L4_DATA
					aDadosPar[3] := SL4->L4_DATA
				EndIf
				
				If Empty(aDadosPar[4]) .Or. aDadosPar[4] < SL4->L4_DATA
					aDadosPar[4] := SL4->L4_DATA
				EndIf  
				
				cFinanc := "1"			
				If Empty(aDadosPar[7])
					aAreaSAE := SAE->(GetArea())
					SAE->(DbSetOrder(1)) //AE_FILIAL+AE_COD                                                                                                                                                
					aDadosPar[7] := Substr(SL4->L4_ADMINIS, nTamAdmin +4)  
	                If SAE->(DbSeek(xFilial("SAE") + Left(SL4->L4_ADMINIS, nTamAdmin)))
	                	aDadosPar[9] := SAE->AE_TAXA
	                EndIf
					RestArea(aAreaSAE) 
				EndIf
				
			Else
				If Empty(aDadosPar[5])	.Or. aDadosPar[5] > SL4->L4_DATA	
					aDadosPar[5] :=  SL4->L4_DATA 
				EndIf	
				aDadosPar[6] += SL4->L4_VALOR 
				dDtVenc := SL4->L4_DATA
				cFinanc := "0"
				nValPago := SL4->L4_VALOR
			EndIf   
			
			aAdd(aPagtos , {0,;//1 Numero da Parcela
						SL4->L4_DATA,;//2 Data de vencimento
						dDtVenc,; //3 Data de recimento
						SL4->L4_VALOR,; //4 Valor da Parcela
						nValPago,;//5 Valor pago
						0,;//6 Valor da subrogação
						cFinanc,;	//7 Parcela Financiada    
						SL4->L4_FORMA,;//8 Tipo de cobrança
						SL4->L4_ADMINIS,;//9 Administradora
						IIF(lFormaId, SL4->L4_FORMAID, "");	// 10 Forma Id
						})                                 
								
			SL4->(DbSkip(1))
		EndDo
		
		aSort(aPagtos,,,{|x,y| 	x[8] + x[9] + x[10] + DtoS(x[2]) <;
								y[8] + y[9] + y[10] + DtoS(y[2])})
								
		If aDadosPar[2] > 0 .and. aDadosPar[1]> 0
			aDadosPar[8] := aDadosPar[1]/aDadosPar[2]
		EndIf  
								
	    //Incrementa o valor da parcela     
	    For nValPago := 1 to Len(aPagtos)
	    	aPagtos[nValPago,1] := 	nValPago
	    Next
	   
		RestArea(aAreaSL4)
		RestArea(aArea)
	EndIf
	
	If Len(aDadosPar) >= nOpc
		uRet := aDadosPar[nOpc]
	EndIf
	
Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    |Lj2507NDep       ºAutor  ³Vendas Clientes      º Data ³  09/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que retorna os numeros de dependentes                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja/SigaFRT                                             		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Lj2507NDep()     

	Local aArea := GetArea()   //WorkArea Ativa
	Local aAreaMAC := MAC->(GetArea())  //WorkArea MAC
	Local nDep := 0            //Total de Dependentes
	Local cFilMAC := xFilial("MAC")  //Filial MAC
	
	While MAC->(!Eof() .AND.  cFilMAC + SL1->(L1_CLIENTE + L1_LOJA)  == MAC_FILIAL+ MAC_CODCLI+ MAC_LOJA)  
		nDep++
		MAC->(DbSkip(1))
	End
	
	RestArea(aAreaMAC)
	RestArea(aArea)

Return nDep   
   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    |Lj2507RefP       ºAutor  ³Vendas Clientes      º Data ³  09/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que retorna os dados pessoais                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±  
±±ºParametros³ ExpA1 = Array dos dados pessoais                                   º±±
±±º          ³ ExpN2 = Registro dos dados da referencia                           º±±
±±º          ³ ExpN3 = Coluna dos dados da referencia                             º±±   
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja/SigaFRT                                             		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Static Function Lj2507RefP(aRefPess, nSeqRef, nPosRef)      

	Local uRet := ""     //Retorno da Função
	Local aArea := nil   //WorkArea Ativa
	Local aAreaMAB := nil //WorjkArea MAB 
	Local nMaxReg := 3    //Total Máximo de Registros
	Local nContaReg := 0  //Contador de Registros
	
	If Len(aRefPess) == 0
	    aArea := GetArea()
		aAreaMAB := MAB->(GetArea())
		nContaReg := 1
	    aRefPess := { { "", "", "", ""},;
	                  { "", "", "", ""},;	
	                  { "", "", "", ""}}
		While MAB->( nContaReg <= nMaxReg .AND. !Eof() .AND. MAB_FILIAL+MAB_CODCLI+MAB_LOJA == xFilial("MAB") + SL1->(L1_CLIENTE + L1_LOJA) )
			aRefPess[nContaReg, 1] := MAB->MAB_NOME
			aRefPess[nContaReg, 2] := MAB->MAB_TEL
			aRefPess[nContaReg, 3] := MAB->MAB_DDD
			aRefPess[nContaReg, 4] := MAB->MAB_RAMAL
			MAB->(DbSkip(1))
			nContaReg++
		End
		RestArea(aAreaMAB)
	    RestArea(aArea)
	EndIf
	
	If Len(aRefPess) >= nSeqRef .AND. Len(aRefPess[nSeqRef]) >= nPosRef
		uRet := aRefPess[nSeqRef, nPosRef]
	EndIf
	
Return uRet     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    |LojDifDtMe       ºAutor  ³Vendas Clientes      º Data ³  09/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que calcula os meses decorridos entre duas datas             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±  
±±ºParametros³ ExpD1 = Data Inicial                                               º±±
±±º          ³ ExpD2 = Data Final                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja/SigaFRT                                             		  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function LojDifDtMe(dDataIni, dDataFim)  

	Local nDiaIni := 0   //Dia da Data Inicial
	Local nDiaFim := 0 	  //Dia da Data Final    
	Local nMesIni := 0   //Mes da Data Inicial
	Local nMesFim := 0   //Mes da Data Final
	Local nAnoIni := 0   //Ano da Data Inicial
	Local nAnoFim := 0   //Ano da Data Final
	Local nMeses := 0    //Meses Decorridos
	Local lFimMesIni := .F. //Verifica se é fim de Mes inicial
	Local lFimMesFim := .F. //Verificar se e fim de mes final  
	Local lInverte := .F.   //Calculo invertido
	Local dDtTmp            //Data temporaria
	
	Default dDataIni := dDataBase
	Default dDataFim := dDataBase     
	
	If dDataIni > dDataFim 	
		lInverte := .T. 
		dDtTmp := dDataFim
		dDataFim := dDataIni
		dDataIni := dDtTmp
	EndIf
	
	nDiaIni := Day(dDataIni)
	nDiaFim := Day(dDataFim)
	nMesIni := Month(dDataIni) 
	nMesFim := Month(dDataFim)
	nAnoIni := Year(dDataIni)
	nAnoFim := Year(dDataFim)
	
	lFimMesIni := LastDay(dDataIni) == dDataIni //Verifica se é fim de Mes inicial
	lFimMesFim := LastDay(dDataFim) == dDataFim //Verificar se e fim de mes final 
	
	
	
	If !(lFimMesIni .AND. lFimMesFim)  //Se não for fim de mes em ambos os casos
	
		If  lFimMesIni .Or. ( nDiaIni > nDiaFim .and. !lFimMesFim)  //Se for fim de mes inicial ou Dia inicial maior que o final e nçao for fim de mes final
			nMesIni++
		EndIf 
	
	EndIf 
		
	If nMesIni > nMesFim     
		nMeses := 12 - nMesIni
		nMeses += nMesFim
		nAnoIni++
	Else
		nMeses := nMesFim - nMesIni 
	EndIf 
	
	If nAnoIni < nAnoFim
		nMeses += (nAnoFim-nAnoIni)*12
	EndIf 
	
	nMeses := nMeses * IIF(!lInverte, 1, -1)

Return nMeses 
