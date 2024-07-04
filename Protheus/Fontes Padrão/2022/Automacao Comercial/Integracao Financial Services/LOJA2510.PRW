#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "XMLXFUN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA2510   บAutor  ณMicrosiga          บ Data ณ  02/27/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo Dummy para identifica็ใo no reposit๓rio             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LOJA2510()
   
EvalTrigger()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    |IntegDef         บAutor  ณVendas Clientes      บ Data ณ  29/02/12   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo que gera/recebe o XML da fila EAI, conforme adapter config   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ  
ฑฑบParametrosณ ExpC1 = CXML                                                       บฑฑ
ฑฑบ          ณ ExpN2 = Tipo                                                       บฑฑ
ฑฑบ          ณ ExpC2 = Tipo da Mensagem                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaLoja/SigaFRT                                             		  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function IntegDef(cXml,nType,cTypeMsg) 

	Local lRet        := .T.    	// Retorno da fun็ใo
	Local cXmlRet     := ""  	    // XML de Retorno
	Local oXmlEAI     := NIL  	    // Objeto do XML EAI
	Local cPai        := ""      	// Nome da tag pai 
	Local aMAB        := NIL       // guarda os dados das refer๊ncias pessoais
	Local aTit        := nil       // guardo os tํtulos de Financiamento para 
	Local aTitGrvMeq  := {}        // Informa็๕es do tํtulos para gravar na MEQ
	
	Local cErroXml    := ""   	   //mensagem de erro XML
	Local cWarnXml    := ""        //mensagem de advertencia XML  
	Local nConta	  := 0                    
	Local cFilMEQ 	  := xFilial("MEQ")               
	Local nMVToler	  := 0  
	Local nTamMa8Tipo := TamSX3("MA8_TIPO")[1] 
	Local nMvFinJrTp  := SuperGetMv("MV_FINJRTP",,1)
	Local cMvJurTipo  := SuperGetMv("MV_JURTIPO",,"L")   
	Local cPict14_5 := "@R 999999999.99999"   
	
	
	If cMvJurTipo <> "L" 
		nMVToler := SuperGetMV("MV_TOLER",,0)
	EndIf  //adicionado para completar a tag mv_jurtipo
	
	//TituloCAP
	Do Case 
		// realiza o envio do tํtulo na Integra็ใo com o CAP
		Case ( nType == TRANS_SEND )
		
		conout ( '  Executou a INTEGDEF  - Inicio ' + cValtoChar( Time() ) )
		// Cria objeto para elabora็ใo do XML
		oXMLEAI := LjClXMLEai():New("BusinessRequest", , , , "TituloCAP", "BusinessContent")
	
		// Posiciona as tabelas para uso na montagem dos XMLs
		oXMLEAI:AddTab("SA1", 1 , { || DbSeek(xFilial("SA1")+ SE1->(E1_CLIENTE + E1_LOJA)) },.F.)
		oXMLEAI:AddTab("SF2", 2 , { || DbSeek(xFilial("SF2")+ SE1->(E1_CLIENTE + E1_LOJA + E1_NUMNOTA + E1_SERIE)) }, .F.) //F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE                                                                                                                    
		oXMLEAI:AddTab("SEF", 3 , { || DbSeek(xFilial("SEF")+ SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO)) },.F.)		//EF_PREFIXO + EF_TITULO + EF_PARCELA + EF_TIPO + EF_NUM
		oXMLEAI:AddTab("MAA", 2 , { || DbSeek(xFilial("MAA")+ SE1->(E1_CLIENTE + E1_LOJA)) }, .f.) 	//MAA_FILIAL+MAA_CODCLI+MAA_LOJA 
		oXMLEAI:AddTab("MAB", 2 , { || DbSeek(xFilial("MAB")+ SE1->(E1_CLIENTE + E1_LOJA)) },.F.) 	//MAB_FILIAL+MAB_CODCLI+MAB_LOJA
		oXMLEAI:AddTab("MA8", 4 , { || DbSeek(xFilial("MA8") + PadR("1",nTamMa8Tipo) +  SE1->(E1_CLIENTE + E1_LOJA)) },.F.) 	//MA8_FILIAL+MA8_CODCLI+MA8_LOJA 
		oXMLEAI:AddTab("MAD", 1 , { || DbSeek(xFilial("MAD")+ MA8->(MA8_CODEND)) },.F.)            	//MAD_FILIAL+MAD_CODEND
		oXMLEAI:AddTab("MA7", 1 , { || DbSeek(xFilial("MA7")+ SE1->(E1_CLIENTE + E1_LOJA)) },.F.)		//MA7_FILIAL+MA7_CODCLI+MA7_LOJA 
		oXMLEAI:AddTab("MAC", 2 , { || DbSeek(xFilial("MAC")+ SE1->(E1_CLIENTE + E1_LOJA)) },.F.)   	//MAC_FILIAL+MAC_CODCLI+MAC_LOJA 
		oXMLEAI:AddTab("SA6", 1 , { || DbSeek(xFilial("SA6")+ SE1->(E1_PORTADO + E1_AGEDEP + E1_CONTA)) },.F.) 
			    

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRealiza a inser็ใo dos conte๚dos e tags na lista para montagem do XMLณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	    oXMLEAI:AddTag("AddExternalCollection", "", 0,, , 1, "1","")  
		cPai := "AddExternalCollection"  
	       	oXMLEAI:AddTag("User", cPai,1,, , 1, "1",{ || SuperGetMv('MV_LJUSRFS',,'')}, "C", 15, )
			oXMLEAI:AddTag("Password", cPai,2,, , 1, "1",{ || SuperGetMv('MV_LJPSWFS',,'')},"C",15, )
			oXMLEAI:AddTag("ContractData",cPai,3,,{|| SE1->(Found()) }, 1, "1",,,,)
			
			cPai := "ContractData"
				oXMLEAI:AddTag("Corporation", cPai,4,, , 1, "1",{ || SuperGetMv('MV_LJIFSCO',,'')},"C",2,)
				oXMLEAI:AddTag("Regional", cPai,5,, , 1, "1",{ || SuperGetMv('MV_LJIFSRE',,'')},"C", 2,)
				oXMLEAI:AddTag("Company", cPai,6,, , 1, "1",{ || SM0->M0_CODIGO },"C", 2,)
				oXMLEAI:AddTag("Product", cPai,7,, , 1, "1",,"C", 20,)
				oXMLEAI:AddTag("Contract", cPai,8,, , 1, "1",{ || SE1->((E1_PREFIXO+E1_NUM+E1_TIPO)+IIF(E1_TIPO = "FI","0",E1_PARCELA)) },"C", 20,)
				oXMLEAI:AddTag("CollectingBank", cPai,9,, , 1, "1",{ || SA6->A6_COD_BC},"C", 3,) 
				oXMLEAI:AddTag("FirstDueDate",cPai,10, , ,1,"1",{ || SE1->(IIF(RTrim(E1_TIPO) == "FI",Lj2510Parc(@aTit,7,@aTitGrvMeq),E1_VENCREA)) }, "D",10)
			    oXMLEAI:AddTag("LastDueDate",cPai,11, , ,1,"1",{ || SE1->(IIF(RTrim(E1_TIPO) == "FI",Lj2510Parc(@aTit,8,@aTitGrvMeq),E1_VENCREA)) }, "D",8)
			    oXMLEAI:AddTag("NextDueDate",cPai,12, , ,1,"1",{ || SE1->(IIF(RTrim(E1_TIPO) == "FI",Lj2510Parc(@aTit,10,@aTitGrvMeq),E1_VENCREA))}, "D",8)
			    oXMLEAI:AddTag("ContractDate",cPai,13, , ,1,"1",{ || IIF(RTrim(SF2->F2_TIPO) == "NF",SF2->F2_EMISSAO,SE1->E1_EMISSAO)}, "D",8)
				oXMLEAI:AddTag("Guarantee",cPai,14, , ,1,"1",,"C",20)
				oXMLEAI:AddTag("FinValue",cPai,15, , ,1,"1",{ || IIF(RTrim(SE1->E1_TIPO) == "FI",SE1->(IIF(E1_VLRREAL = 0,Lj2510Parc(@aTit,3,@aTitGrvMeq),Lj2510Parc(@aTit,4,@aTitGrvMeq))),SE1->(IIF(E1_VLRREAL = 0,E1_VALOR,E1_VLRREAL))) }, "N",14,"@R 999999999.99999" )
				oXMLEAI:AddTag("CpfExt",cPai,16, , ,1,"1",{|| "00" }, "C",2)
				oXMLEAI:AddTag("CpfCgc",cPai,17, , ,1,"1",{ || SA1->A1_CGC }, "C",14)
				oXMLEAI:AddTag("CpfCgcGuarantor",cPai,18, , ,1,"1",,"C",14)
				oXMLEAI:AddTag("CpfExtGuarantor",cPai,19, , ,1,"1",,"C",2)
				oXMLEAI:AddTag("PersonType",cPai,20, , ,1,"1",{ || SA1->(IIF(A1_PESSOA == "F", "0", "1"))  }, "C",1)
				oXMLEAI:AddTag("FinRate",cPai,21, , ,1,"1",{ || IF(Left(SE1->E1_ORIGEM,4) == "LOJA",Lj2510Fin(SE1->E1_PREFIXO, SE1->E1_NUM),0)  },"N",11,"@R 9999.999999") //ALTERADO 14/06/12
				oXMLEAI:AddTag("InstallmtValue",cPai,22, , ,1,"1",{ || SE1->E1_VALOR   }, "N",15,cPict14_5)
				oXMLEAI:AddTag("Ind",cPai,23, , ,1,"1",{ || "PRE"},"C",5)
				oXMLEAI:AddTag("RateValue",cPai,24, , ,1,"1",,"N",15,cPict14_5)
				oXMLEAI:AddTag("InstPaidQty",cPai,25, , ,1,"1",{ || IIF(RTrim(SE1->E1_TIPO) == "FI",Lj2510Parc(@aTit,1,@aTitGrvMeq),1) }, "N",3,"@R 999")
				oXMLEAI:AddTag("BranchStoreTradeName",cPai,26, , ,1,"1",{ || SM0->M0_NOMECOM  }, "C",25)
				oXMLEAI:AddTag("PaidInstallmentsQty",cPai,27, , ,1,"1",{ || IIF(RTrim(SE1->E1_TIPO) == "FI",LTrim(Str(Lj2510Parc(@aTit,2,@aTitGrvMeq))), "1") }, "C",3)
				oXMLEAI:AddTag("StoreCompanyName",cPai,28, , ,1,"1",{ || SM0->M0_FILIAL  }, "C",40)
				oXMLEAI:AddTag("NextInstallment",cPai,29, , ,1,"1",{ || LjNumParc(SE1->E1_PARCELA) }, "N",3,"@R 999")
				oXMLEAI:AddTag("NextInstallmentType",cPai,30, , ,1,"1",{ ||  "p"  }, "C",1)
				oXMLEAI:AddTag("BalanceDue",cPai,31, , ,1,"1",{ || SE1->(IIF(RTrim(E1_TIPO) == "FI",Lj2510Parc(@aTit,9,@aTitGrvMeq),E1_SALDO)) }, "N",15,cPict14_5)
				oXMLEAI:AddTag("StoreCode",cPai,32, , ,1,"1",{ || SM0->M0_CODFIl},"C",4)
				oXMLEAI:AddTag("BranchCode",cPai,33, , ,1,"1",{ || SM0->M0_CODFIl},"C",4)
				oXMLEAI:AddTag("StorePaymtDate",cPai,34, , ,1,"1",,"D",10)
				oXMLEAI:AddTag("CustomerFinValue",cPai,35, , ,1,"1",{ || IIF(RTrim(SE1->E1_TIPO) == "FI",SE1->(IIF(E1_VLRREAL = 0,Lj2510Parc(@aTit,3,@aTitGrvMeq),Lj2510Parc(@aTit,4,@aTitGrvMeq))),SE1->(IIF(E1_VLRREAL = 0,E1_VALOR,E1_VLRREAL))) }, "N",16,"@R 9999999999.99999")
				oXMLEAI:AddTag("BalanceDueNextInstallmt",cPai,36, , ,1,"1",{ || IIF(RTrim(SE1->E1_TIPO) == "FI",Lj2510Parc(@aTit,9,@aTitGrvMeq),SE1->E1_SALDO) }, "N",15,cPict14_5)
				oXMLEAI:AddTag("BankBranchCode",cPai,37, , ,1,"1",, "C",10)
				oXMLEAI:AddTag("ManagerName",cPai,38, , ,1,"1",,"C",40)
				oXMLEAI:AddTag("CheckingAccountNumber",cPai,39, , ,1,"1",, "C",14)
				oXMLEAI:AddTag("LiborRate",cPai,40, , ,1,"1",,"N",9,"@R 99.999999")
				oXMLEAI:AddTag("IndexerType",cPai,41, , ,1,"1",,"C",1)
				oXMLEAI:AddTag("AnnualRate",cPai,42, , ,1,"1",,"N",9,"@R 99.999999")
				oXMLEAI:AddTag("AnnualRateBaseDays",cPai,43, , ,1,"1",,"N",3)
				oXMLEAI:AddTag("OriginalProductDescription",cPai,44, , ,1,"1",,"C",40)
				oXMLEAI:AddTag("SaleOrigin",cPai,45, , ,1,"1",,"C",20)
				oXMLEAI:AddTag("OriginSystem",cPai,46, , ,1,"1",{ || "PRT"  }, "C",3)
				oXMLEAI:AddTag("CodEvent",cPai,47, , ,1,"1",{ || "01"  }, "C",2)
				oXMLEAI:AddTag("CancelContractFl",cPai,48, , ,1,"1",{ || "0"  }, "C",1)
	
		cPai := "AddExternalCollection" 
		oXMLEAI:AddTag("InstallmentsData",cPai,49, ,{|| nConta := 0, .T.} ,1,"1","")
	
	        cPai := "InstallmentsData"

			If RTrim(SE1->E1_TIPO) <> "FI"
					aTitGrvMeq := {	{SE1->E1_PREFIXO,;
								SE1->E1_NUM,;
								SE1->E1_PARCELA,;
								SE1->E1_TIPO,;
								SE1->E1_VALOR,;
								SE1->(RECNO());
								}} 
            EndIf
			
			
			oXMLEAI:AddTag("InstallmentData",cPai,50,,{|| ((nConta := nConta + 1) <= Len(aTitGrvMeq))  },0,"N","")

				cPai := "InstallmentData"
					oXMLEAI:AddTag("Corporation",cPai,51, , ,1,"1",{ || SE1->(DbGoTo(aTitGrvMeq[nConta, 6])) , SuperGetMv('MV_LJIFSCO',,'')  }, "C",2)
					oXMLEAI:AddTag("Regional",cPai,52, , ,1,"1",{ || SuperGetMv('MV_LJIFSRE',,'')  }, "C",2)
					oXMLEAI:AddTag("Company",cPai,53, , ,1,"1",{ || SM0->M0_CODIGO }, "C",2)
					oXMLEAI:AddTag("Product",cPai,54, , ,1,"1",, "C",20)
					oXMLEAI:AddTag("Contract",cPai,55, , ,1,"1",{ || SE1->(E1_PREFIXO+E1_NUM+E1_TIPO + IIF(E1_TIPO = "FI", "0", E1_PARCELA) ) }, "C",20)
					oXMLEAI:AddTag("InstallmtValue",cPai,56, , ,1,"1",{ || SE1->E1_VALOR  }, "N",15,cPict14_5)
					oXMLEAI:AddTag("Installment",cPai,57, , ,1,"1",{ || LjNumParc(SE1->E1_PARCELA)   }, "N",3,"@R 999")
					oXMLEAI:AddTag("PercFine",cPai,58, , ,1,"1",{ || SuperGetMv("MV_LJMULTA")  }, "N",15,cPict14_5)
					oXMLEAI:AddTag("CollectionType",cPai,59, , ,1,"1",{|| "0" },"C",1) //alterado
					oXMLEAI:AddTag("FineCollectionQtyDays",cPai,60, , ,1,"1",{ || 0 },"N",2, "@R 99") 
					oXMLEAI:AddTag("CommissionRate",cPai,61, , ,1,"1",{ || Lj2510Jur(nMvFinJrTp, cMvJurTipo)  }, "N",15, "@R 999999999.99999")//alterado teste fabiana
					oXMLEAI:AddTag("DueDate",cPai,62, , ,1,"1",{ || SE1->E1_VENCREA  }, "D",8)
					oXMLEAI:AddTag("FineCollectionFreeDays",cPai,75, , ,1,"1",{ ||  nMVToler  }, "N",3,"@R 999")
	
		cPai := "AddExternalCollection"
		oXMLEAI:AddTag("CustomerData",cPai,76, , ,1,"1","")   
		
		    cPai := "CustomerData"
		    	oXMLEAI:AddTag("Corporation",cPai,77, , ,1,"1",{  || SuperGetMv('MV_LJIFSCO',,'') }, "C",2)
				oXMLEAI:AddTag("CpfExt",cPai,78, , ,1,"1",{ || "00"}, "C",2)
				oXMLEAI:AddTag("CpfCgc",cPai,79, , ,1,"1",{ || SA1->A1_CGC  }, "C",14)
				oXMLEAI:AddTag("BankRef1",cPai,80, ,,1,"1",, "C",40)   //alterado
				oXMLEAI:AddTag("BankRefDDD1",cPai,81, , ,1,"1",,"C",4)
				oXMLEAI:AddTag("BankRefPhone1",cPai,82, , ,1,"1",,"C",15)
				oXMLEAI:AddTag("BankRefExtension1",cPai,83, , ,1,"1",,"C",5)
				oXMLEAI:AddTag("BankRefBranch1",cPai,84, , ,1,"1",,"C",10)
				oXMLEAI:AddTag("BankRefAccount1",cPai,85, , ,1,"1",,"C",20)
				oXMLEAI:AddTag("BankRef2",cPai,86, , ,1,"1",, "C",40) //alterado
				oXMLEAI:AddTag("BankRefDDD2",cPai,87, , ,1,"1",,"C",4)
				oXMLEAI:AddTag("BankRefPhone2",cPai,88, , ,1,"1",,"C",15)
				oXMLEAI:AddTag("BankRefExtension2",cPai,89, , ,1,"1",,"C",15)
				oXMLEAI:AddTag("BankRefBranch2",cPai,90, , ,1,"1",,"C",10)
				oXMLEAI:AddTag("BankRefAccount2",cPai,91, , ,1,"1",,"C",20)
				oXMLEAI:AddTag("CommercialRefName1",cPai,92, , ,1,"1",,"C",40)
				oXMLEAI:AddTag("CommercialRefAddress1",cPai,93, , ,1,"1",,"C",60)
				oXMLEAI:AddTag("CommercialRefDDD1",cPai,94, , ,1,"1",,"C",4)
				oXMLEAI:AddTag("CommercialRefPhone1",cPai,95, , ,1,"1",,"C",15)
				oXMLEAI:AddTag("CommercialRefExtension1",cPai,96, , ,1,"1",,"C",15)
				oXMLEAI:AddTag("CommercialRefName2",cPai,97, , ,1,"1",,"C",40)
				oXMLEAI:AddTag("CommercialRefAddress2",cPai,98, , ,1,"1",,"C",60)
				oXMLEAI:AddTag("CommercialRefDDD2",cPai,99, , ,1,"1",,"C",4)
				oXMLEAI:AddTag("CommercialRefPhone2",cPai,100, , ,1,"1",,"C",15)
				oXMLEAI:AddTag("CommercialRefExtension2",cPai,101, , ,1,"1",,"C",5)
				oXMLEAI:AddTag("PersonalRefName1",cPai,102, , ,1,"1",{ || Lj2510Pesl(@aMAB,1,1)  }, "C",40)
				oXMLEAI:AddTag("PersonalRefAddress1",cPai,103, , ,1,"1",, "C",45)
				oXMLEAI:AddTag("PersonalRefDDD1",cPai,104, , ,1,"1",{|| Lj2510Pesl(@aMAB,1,2)  }, "C",4)
				oXMLEAI:AddTag("PersonalRefPhone1",cPai,105, , ,1,"1",{ || Lj2510Pesl(@aMAB,1,3)  }, "C",15)
				oXMLEAI:AddTag("PersonalRefExtension1",cPai,106, , ,1,"1",{ || Lj2510Pesl(@aMAB,1,4)  }, "C",5)
				oXMLEAI:AddTag("PersonalRefName2",cPai,107, , ,1,"1",{ || Lj2510Pesl(@aMAB,2,1)  }, "C",40)
				oXMLEAI:AddTag("PersonalRefAddress2",cPai,108, , ,1,"1",, "C",45)
				oXMLEAI:AddTag("PersonalRefDDD2",cPai,109, , ,1,"1",{ || Lj2510Pesl(@aMAB,2,2)  }, "C",4)
				oXMLEAI:AddTag("PersonalRefPhone2",cPai,110, , ,1,"1",{ || Lj2510Pesl(@aMAB,2,3)  }, "C",15)
				oXMLEAI:AddTag("PersonalRefExtension2",cPai,111, , ,1,"1",{ || Lj2510Pesl(@aMAB,2,4)  }, "C",5)  
				oXMLEAI:AddTag("LengthService",cPai,112, ,{ || MA8->( Found() .AND. !Empty(MA8_DTADM))} ,1,"1",{ || LTrim(Str(LojDifDtMe(MA8->MA8_DTADM, dDatabase))) }, "C",7)
				oXMLEAI:AddTag("CompanyType",cPai,113, , ,1,"1",,"C",1)
				oXMLEAI:AddTag("CompanyAddressDetails",cPai,114, , ,1,"1",,"C",15)
				oXMLEAI:AddTag("CompanyAddressNumber",cPai,115, , ,1,"1",,"C",5)
				oXMLEAI:AddTag("CompanyAddressStreet",cPai,116, ,{|| MA8->(Found()).AND. MAD->(Found()) } ,1,"1",{ || MAD->MAD_END }, "C",60)
				oXMLEAI:AddTag("CompanyName",cPai,117, ,{|| MA8->(Found())},1,"1",{ || MA8->MA8_EMPRES  }, "C",40)
				oXMLEAI:AddTag("CompanyCity",cPai,118, ,{ || MA8->(Found()) .AND. MAD->(Found()) },1,"1",{ || MAD->MAD_CID  }, "C",30)
				oXMLEAI:AddTag("CompanyState",cPai,119, ,{ || MA8->(Found()) .AND. MAD->(Found()) },1,"1",{ || MAD->MAD_UF  }, "C",2)
				oXMLEAI:AddTag("CompanyPostalCode",cPai,120, ,{ || MA8->(Found()) .AND. MAD->(Found()) },1,"1",{ || MAD->MAD_CEP  }, "C",8)
				oXMLEAI:AddTag("CompanyDDD",cPai,121, ,{ || MA8->(Found()) .AND. MAD->(Found()) },1,"1",{ || MAD->MAD_DDD  }, "C",4)
				oXMLEAI:AddTag("CompanyPhone",cPai,122, ,{ || MA8->(Found()) .AND. MAD->(Found()) },1,"1",{ || MAD->MAD_TEL  }, "C",15)
				oXMLEAI:AddTag("CompanyExtension",cPai,123, ,{ || MA8->(Found()) .AND. MAD->(Found()) },1,"1",{ || MAD->MAD_RAMAL  }, "C",5)
				oXMLEAI:AddTag("SalaryValue",cPai,124, ,{|| MA8->(Found())},1,"1",{ || MA8->MA8_RENDA  }, "N",20,"@R 99999999999999.99999" )
				oXMLEAI:AddTag("JobPosition",cPai,125, ,,1,"1",, "C",5)
				oXMLEAI:AddTag("CompanyDistrict",cPai,126, ,{ || MA8->(Found()) .AND. MAD->(Found()) },1,"1",{ || MAD->MAD_BAIRRO  }, "C",60)
				oXMLEAI:AddTag("Name",cPai,127, , ,1,"1",{ || SA1->A1_NOME }, "C",40)
				oXMLEAI:AddTag("Nationality",cPai,128, , ,1,"1",,"C",20)
				oXMLEAI:AddTag("BirthDate",cPai,129, , ,1,"1",{ || SA1->A1_DTNASC  }, "D",10)
				oXMLEAI:AddTag("Gender",cPai,130,,{ || MA7->(Found()) },1,"1",{ || IIF(MA7->MA7_SEXO =="1", "M", IIF(MA7->MA7_SEXO == "2", "F",""))  }, "C",1)
				oXMLEAI:AddTag("MaritalStatus",cPai,131, ,{ || MA7->(Found()) },1,"1",{ || IIF(MA7->MA7_ECIVIL == "3", "3", IIF(MA7->MA7_ECIVIL = "1", "2", IIF(MA7->MA7_ECIVIL = "2", "1", IIF(MA7->MA7_ECIVIL = "5", "4", ""))))  }, "C",1)
				oXMLEAI:AddTag("NumberOfDependants",cPai,132, , ,1,"1",{ || Lj2510RgDp()  }, "N",2)
				oXMLEAI:AddTag("FathersName",cPai,133, ,{ || MA7->(Found()) },1,"1",{ || MA7->MA7_PAI  }, "C",40)
				oXMLEAI:AddTag("MothersName",cPai,134, ,{ || MA7->(Found()) },1,"1",{ || MA7->MA7_MAE  }, "C",40)
				oXMLEAI:AddTag("DocumentType",cPai,135, , ,1,"1",{ || IIF(SA1->A1_PESSOA == "F", "1", "0")  }, "C",2)
				oXMLEAI:AddTag("IdNumber",cPai,136, ,,1,'1',{ || SA1->A1_PFISICA  }, "C",20)
				oXMLEAI:AddTag("IdBody",cPai,137, , ,1,"1",{ || "." } ,"C",10) //teste fcp
				oXMLEAI:AddTag("IdState",cPai,138, , ,1,"1",,"C",2)
				oXMLEAI:AddTag("IdIssueDate",cPai,139, , ,1,"1",,"D",10)
				oXMLEAI:AddTag("ResidenceType",cPai,140, , ,1,"1",,"C",1)
				oXMLEAI:AddTag("LengthOfResidence",cPai,141, ,{ || MA7->(Found()) },1,"1",{ || Str(Val(MA7->MA7_TRES))  }, "C",7)   //informa็ใo deve ser numerica
				oXMLEAI:AddTag("Street",cPai,142, , ,1,"1",{ || SA1->A1_END  }, "C",60)
				oXMLEAI:AddTag("Number",cPai,143, , ,1,"1",,"C",5)
				oXMLEAI:AddTag("Details",cPai,144, , ,1,"1",{ || SA1->A1_COMPLEM  }, "C",15)
				oXMLEAI:AddTag("District",cPai,145, , ,1,"1",{ || SA1->A1_BAIRRO  }, "C",60)
				oXMLEAI:AddTag("PostalCode",cPai,146, , ,1,"1",{ || SA1->A1_CEP  }, "C",8)
				oXMLEAI:AddTag("City",cPai,147, , ,1,"1",{ || SA1->A1_MUN  }, "C",30)
				oXMLEAI:AddTag("State",cPai,148, , ,1,"1",{ || SA1->A1_EST  }, "C",2)
				oXMLEAI:AddTag("DDD",cPai,149, , ,1,"1",{ || SA1->A1_DDD  }, "C",4)
				oXMLEAI:AddTag("Phone",cPai,150, , ,1,"1",{ || SA1->A1_TEL  }, "C",15)
				oXMLEAI:AddTag("Extension",cPai,151, , ,1,"1",,"C",5)
				oXMLEAI:AddTag("CustomerType",cPai,152, , ,1,"1",{ || IIF(SA1->A1_PESSOA == "F", "0", "5")  }, 'C',1)
				oXMLEAI:AddTag("MailingAddress",cPai,153, ,,1,"1",{ || IIF(MA7->(!Found() .OR. MA7_CARTA == "1"), "0", IIF(MA7->MA7_CARTA == "2", "1", "0"))  }, "C",1)
				oXMLEAI:AddTag("MailingDetails",cPai,154, ,,1,"1",{ || IIF(MA7->( Found() .AND. MA7_CARTA == "2"),"" , SA1->A1_COMPLEM)    }, "C",15)
				oXMLEAI:AddTag("MailingDistrict",cPai,155, ,,1,"1",{ || IIF(MA7->(Found()) .AND. MA8->(Found()) .AND. MAD->(Found()) .AND. MA7->MA7_CARTA == "2",MAD->MAD_BAIRRO , SA1->A1_BAIRRO)    }, "C",60)
				oXMLEAI:AddTag("MailingState",cPai,156, ,,1,"1",{ || IIF(MA7->(Found()) .AND. MA8->(Found()) .AND. MAD->(Found()) .AND. MA7->MA7_CARTA == "2",MAD->MAD_UF , SA1->A1_EST)    }, "C",2)
				oXMLEAI:AddTag("MailingCity",cPai,157, ,,1,"1",{ || IIF(MA7->(Found()) .AND. MA8->(Found()) .AND. MAD->(Found()) .AND. MA7->MA7_CARTA == "2",MAD->MAD_CID , SA1->A1_MUN)    }, "C",30)
				oXMLEAI:AddTag("MailingPostalCode",cPai,158, ,,1,"1",{ || IIF(MA7->(Found()) .AND. MA8->(Found()) .AND. MAD->(Found()) .AND. MA7->MA7_CARTA == "2",MAD->MAD_CEP , SA1->A1_CEP)    }, "C",8)
				oXMLEAI:AddTag("MailingNumber",cPai,159, , ,1,"1",,"C",5)
				oXMLEAI:AddTag("MailingStreet",cPai,160, ,,1,"1",{ || IIF(MA7->(Found()) .AND. MA8->(Found()) .AND. MAD->(Found()) .AND. MA7->MA7_CARTA == "2",MAD->MAD_END , SA1->A1_END)}, "C",60)
				oXMLEAI:AddTag("MailingDDD",cPai,161, ,,1,"1",{ || IIF(MA7->(Found()) .AND. MA8->(Found()) .AND. MAD->(Found()) .AND. MA7->MA7_CARTA == "2",MAD->MAD_DDD , SA1->A1_DDD)    }, "C",4)
				oXMLEAI:AddTag("MailingExtension",cPai,162, ,,1,"1",{ || IIF(MA7->(Found()) .AND. MA8->(Found()) .AND. MAD->(Found()) .AND. MA7->MA7_CARTA == "2",MAD->MAD_RAMAL , "")    }, "C",5)
				oXMLEAI:AddTag("MailingPhone",cPai,163, ,,1,"1",{ || IIF(MA7->(Found()) .AND. MA8->(Found()) .AND. MAD->(Found()) .AND. MA7->MA7_CARTA == "2",MAD->MAD_TEL , SA1->A1_TEL)    }, "C",15)
				oXMLEAI:AddTag("VehicleQty",cPai,164, , ,1,"1",,"N",6,"@R 999999")
				oXMLEAI:AddTag("StoreCard",cPai,165, , ,1,"1",,"C",1)
				oXMLEAI:AddTag("BankCard",cPai,166, , ,1,"1",,"C",1)
				oXMLEAI:AddTag("CreditCard",cPai,167, , ,1,"1",,"C",1)                                                 	
				oXMLEAI:AddTag("RevolvingCreditCheck",cPai,168, , ,1,"1",,"C",1)
				oXMLEAI:AddTag("PhoneLineType",cPai,169, , ,1,"1",,"C",1)
				oXMLEAI:AddTag("SpouseName",cPai,170, , ,1,"1",,"C",40)
				oXMLEAI:AddTag("MobileDDD",cPai,171, ,{ || MA7->(Found() .AND. !Empty(MA7_CELULA) .AND. At("(", MA7_CELULA) > 0  .AND. At(")",MA7_CELULA) > 0 ) } ,1,"1",{ || Subst(MA7->MA7_CELULA,At("(", MA7->MA7_CELULA)+1,RAt(")",MA7->MA7_CELULA) - (At("(", MA7->MA7_CELULA)+1) ) },"C",4)
				oXMLEAI:AddTag("MobileNumber",cPai,172, , { || MA7->(Found() .AND. !Empty(MA7_CELULA) .AND. At("(", MA7_CELULA) > 0 .AND. At(")",MA7_CELULA) > 0)},1,"1",{ || StrTran(StrTran(Subst(MA7->MA7_CELULA, At(")", MA7->MA7_CELULA)+1),"-")," ")  },"C",9)
				oXMLEAI:AddTag("PersonalRefName3",cPai,173, , ,1,"1",{ || Lj2510Pesl(@aMAB,3,1)  }, "C",40)
				oXMLEAI:AddTag("PersonalRefAddress3",cPai,174, , ,1,"1",, "C",45)
				oXMLEAI:AddTag("PersonalRefPhone3",cPai,175, , ,1,"1",{ || Lj2510Pesl(@aMAB,3,3)  }, "C",15)
				oXMLEAI:AddTag("PersonalRefDDD3",cPai,176, , ,1,"1",{ || Lj2510Pesl(@aMAB,3,2)  }, "C",4)
				oXMLEAI:AddTag("PersonalRefExtension3",cPai,177, , ,1,"1",{ || Lj2510Pesl(@aMAB,3,4)  }, "C",5)
				oXMLEAI:AddTag("PersonalRefMobileDDD1",cPai,178, , ,1,"1",,"C",4)
				oXMLEAI:AddTag("PersonalRefMobileNumber1",cPai,179, , ,1,"1",,"C",9)
				oXMLEAI:AddTag("PersonalRefMobileDDD2",cPai,180, , ,1,"1",,"C",9)
				oXMLEAI:AddTag("PersonalRefMobileNumber2",cPai,181, , ,1,"1",,"C",4)
				oXMLEAI:AddTag("PersonalRefMobileDDD3",cPai,182, , ,1,"1",,"C",4)
				oXMLEAI:AddTag("PersonalRefMobileNumber3",cPai,183, , ,1,"1",,"C",9)
				oXMLEAI:AddTag("PersonalRefEmail",cPai,184, , ,1,"1",,"C",40)
	
		cPai := "AddExternalCollection"
	 	oXMLEAI:AddTag("GuarantorData",cPai,185, , ,1,"1","")
		cPai := "AddExternalCollection"

		oXMLEAI:AddTag("ChecksData",cPai,294, , ,1,"1","")
	
			cPai := "ChecksData"  
						
			oXMLEAI:AddTag("CheckData",cPai,295,"SEF",{|| RTrim(SE1->E1_TIPO) == "CH" .AND. SEF->( EF_FILIAL + EF_PREFIXO + EF_TITULO + EF_PARCELA + EF_TIPO) == SE1->( E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO) } ,0,"N","")
		 
				cPai := "CheckData"
					oXMLEAI:AddTag("Corporation",cPai,296, , ,1,"1",{ || SuperGetMv('MV_LJIFSCO',,'')  }, "C",2)
					oXMLEAI:AddTag("Regional",cPai,297, , ,1,"1",{ || SuperGetMv('MV_LJIFSRE',,'')  }, "C",2)
					oXMLEAI:AddTag("Company",cPai,298, , ,1,"1",{ || SM0->M0_CODIGO}, "C",2)
					oXMLEAI:AddTag("Product",cPai,299, , ,1,"1",, "C",20)
					oXMLEAI:AddTag("Contract",cPai,300, , ,1,"1",{ || SE1->(E1_PREFIXO+E1_NUM+E1_TIPO + IIF(E1_TIPO = "FI", "0", E1_PARCELA))  }, "C",20)
					oXMLEAI:AddTag("Installment",cPai,301, , ,1,"1",{ || LjNumParc(SE1->E1_PARCELA)  }, "N",3,"@R 999")
					oXMLEAI:AddTag("InstallmentType",cPai,302, , ,1,"1",{ || "p"  }, "C",1)
					oXMLEAI:AddTag("SerialNumber",cPai,303, , ,1,"1",,"C",6)
					oXMLEAI:AddTag("Bank",cPai,304, , ,1,"1",{ || SEF->EF_BANCO }, "C",3)
					oXMLEAI:AddTag("Account",cPai,305, , ,1,"1",{ || SEF->EF_CONTA  }, "C",20)
					oXMLEAI:AddTag("CheckNumber ",cPai,306, , ,1,"1",{ || SEF->EF_NUM  }, "C",6)
					oXMLEAI:AddTag("BankBranch",cPai,307, , ,1,"1",{ || SEF->EF_AGENCIA  }, "C",9)      		    
		// gera o XML 
		cXMLRet := oXMLEAI:GerarXML()	  
		LjGravMEQ(aTitGrvMeq, cFilMEQ)
		conout ( '      Executou a INTEGDEF  - Final - Gera็ใo ' + cValtoChar( Time() ) )
		
		Case ( nType == TRANS_RECEIVE )
		Do Case 
		
			Case ( cTypeMsg == EAI_MESSAGE_WHOIS ) 
				
				conout ( '          Executou a INTEGDEF EAI_MESSAGE_WHOIS  - Inicio ' + cValtoChar( Time() ) )
				cXmlRet := "1.000"
			Case ( cTypeMsg == EAI_MESSAGE_RESPONSE )
				conout ( '  Executou a EAI_MESSAGE_RESPONSE - Final ' + cValtoChar( Time() ) )
	
			Case ( cTypeMsg == EAI_MESSAGE_RECEIPT )

		End Case	
	End Case
	
	// Limpa o objeto criado
	If oXMLEAI <> NIL
		FreeObj(oXMLEAI)
		oXMLEAI := NIL
	EndIf
	

Return { lRet, cXmlRet }          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLj2510PeslบAutor  ณMicrosiga           บ Data ณ  03/19/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que busca as Referencias Pessoais                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Lj2510Pesl(aMAB,nReg,nPosic)

	Local aArea		:= GetArea()                // salva a แrea posicionada para restaura็ใo
	Local aAreaMAB	:= MAB->(GetArea())        // salva a แrea posicionada na MAB para restaurar ao fim do processamento
	Local nCont 	:= 1                        // indice para uso no array aMAB
	Local cRet  	:= ""                       // variแvel com retorno da pesquisa
	
	
	Default aMAB := {{"","","",""},{"","","",""},{"","","",""}}
	
   	
   	If nReg == 1 .AND. nPosic == 1
	   	// realiza a itera็ใo pelo array e tabela para identifica็ใo dos registros
	    While nCont <= 3 .AND. MAB->(MAB_FILIAL+MAB_CODCLI+MAB_LOJA) == xFilial("MAB") + SA1->(A1_COD+A1_LOJA)
			aMAB[nCont,1] := MAB->MAB_NOME
			aMAB[nCont,2] := MAB->MAB_DDD
			aMAB[nCont,3] := MAB->MAB_TEL
			aMAB[nCont,4] := MAB->MAB_RAMAL
			nCont++
			MAB->(DbSkip())
		End	  
    EndIf
	
	MAB->(RestArea(aAreaMAB))
	RestArea( aArea )
	
	cRet := aMAB[nReg,nPosic]

Return cRet    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLj2510RgDpบAutor  ณMicrosiga           บ Data ณ  03/20/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que faz a somatoria dos Dependentes                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/    

Static Function Lj2510RgDp()
         	
	Local aArea 	:= GetArea()            // แrea posicionada para retorno
	Local aAreaMAC 	:= MAC->(GetArea())    // แrea posicionada na MAC
	Local nDepend	:= 0                    // variavel com retorno dos dependentes
	
	While MAC->(!EOF()) .AND. xFilial("MAC")+ SA1->(A1_COD + A1_LOJA) = MAC->(MAC_FILIAL + MAC_CODCLI + MAC_LOJA )
	      nDepend ++
	      MAC->(DbSkip())
	End
	
	MAC->(RestArea(aAreaMAC))
	RestArea(aArea)

Return nDepend        
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLj2510ParcบAutor  ณMicrosiga           บ Data ณ  03/20/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ funcao que trata as parcelas dos titulos                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Lj2510Parc(aTit,nPos,aTitGrvMeq)

    Local aArea 		:= GetArea()	// แrea salva para retorno ao final do processamento
    Local uRet          := nil               	// conte๚do do retorno da fun็ใo
    Local nParc 		:= 0           	// n๚mero das parcelas
    Local cTit  		:= ""          	// c๓digo do tํtulo
    Local nQtdParPgs	:= 0           	// quantidade de parcelas pagas
    Local nTotVal		:= 0           	// Valor total do tํtulo
    Local nTotVlR		:= 0           	// Valor Real dos tํtulos
    Local nTotValPg		:= 0           	// somat๓rio dos valores dos tํtulos pagos
    Local nTotVlRPg		:= 0           	// somat๓rio dos valores reais dos tํtulos pagos
    Local nQtdSaldo		:= 0			// somat๓rio dos saldos dos tํtulos
    Local cChavSE1 		:= SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)  // Indํce 1 da tabela SE1
    Local nRegistro		:= 0            //Posicao do registro

	Default aTit	      := {0,0,0,0,0,0,"","",0,""} 
	Default aTitGrvMeq    := {}

   
    If Len(aTitGrvMeq) = 0  .AND. aTit[1] = 0 
    
	    nRegistro := SE1->(Recno())
	    cTit := SE1->(E1_PREFIXO+E1_NUM+E1_TIPO)
	
		// itera็ใo para verifica็ใo das parcelas e se pertencem aos tํtulos em atraso
		While SE1->(!EOF()) .AND. xFilial("SE1")+ cTit == SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_TIPO) .AND. RTrim(SE1->E1_TIPO) == "FI"
		
			If Empty(aTit[7]) 
			   aTit[7] := SE1->E1_VENCREA                        
			EndIf
			
				
			//Se o Saldo do Tํtulo maior que zero 
			If SE1->E1_SALDO > 0 
				
	            nTotVal		:= nTotVal + SE1->E1_VALOR   		//Somat๓ria do Valor dos Titulos
	            nTotVlR		:= nTotVlR + SE1->E1_VLRREAL		//Somat๓ria do Valor Real dos Titulos
	            
			EndIf
			
			If SE1->(E1_SALDO = 0)		//Se o Saldo for igual a 0 
	
			    	nQtdParPgs++                               		//Quantidade dos Tํtulos que estใo pagas
					nTotValPg	:= nTotValPg + SE1->E1_VALOR		//Somat๓ria do Valor dos Tํtulos pagos
	            	nTotVlRPg	:= nTotVlRPg + SE1->E1_VLRREAL		//Somat๓ria do Valor real dos Tดtitulos pagos
			    
			EndIf 
	
			If SE1->E1_SALDO > 0 .AND. aScan(aTitGrvMeq,{ |x| x[1]+x[2]+x[3]+x[4] == SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)}) == 0  
			    
				AADD(aTitGrvMeq,{	SE1->E1_PREFIXO,;
									SE1->E1_NUM,;
									SE1->E1_PARCELA,;
									SE1->E1_TIPO,;
									SE1->E1_VALOR,;
									SE1->(RECNO());
									})   								
										
			EndIf  
			
			If SE1->E1_SALDO > 0 .AND. SE1->(E1_VENCREA) < dDataBase .and. Empty(aTit[10])
			
				aTit[10] := SE1->E1_VENCREA                  //Vencimento real da parcela mais antiga em atraso
				
			EndIf                                                                            
			
			nQtdSaldo := nQtdSaldo + SE1->E1_SALDO       //Somat๓ria do Saldo dos Tํtulos
			
			aTit[8] := SE1->E1_VENCREA                
			
			nParc++	            
			SE1->(dbSkip()) 
				
			
		End	           
			                               
	    aTit[1]	:= nParc 
	    aTit[2] := nQtdParPgs
	    aTit[3] := nTotVal
	    aTit[4] := nTotVlR
	    aTit[5] := nTotValPg
	    aTit[6] := nTotVlRPg 
	    aTit[9] := nQtdSaldo
	   
    	SE1->(DbGoTo(nRegistro))
	
	EndIf
	
	RestArea(aArea)
 
    If nPos > 0
	    If Len(aTit) >= nPos
	    	uRet := aTit[nPos]
	    EndIf
    Endif
    
    
Return uRet  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLjGravMEQ บAutor  ณMicrosiga           บ Data ณ  03/26/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que grava os dados na tabela MEQ                    บฑฑ
ฑฑบ          ณ Titulos recebidos/enviados                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/    

Static Function LjGravMEQ(aTitGrvMeq, cFilMEQ)

	Local aAreas := GetArea()      // area posicionada para retorno do posicionamento ao final do processamento
	Local nRg	 := 0              // numero do registro/posi็ใo no array
	    
	   
	For nRg := 1 to Len(aTitGrvMeq)
 		RecLock("MEQ",.T.)
   		Replace MEQ->MEQ_FILIAL  with  cFilMEQ
		Replace MEQ->MEQ_PREFIX  with aTitGrvMeq[nRg,1]
		Replace MEQ->MEQ_NUM     with aTitGrvMeq[nRg,2]
		Replace MEQ->MEQ_PARCEL  with aTitGrvMeq[nRg,3]     
		Replace MEQ->MEQ_TIPO    with aTitGrvMeq[nRg,4]
		Replace MEQ->MEQ_SEQTIT  with GetSXeNum("MEQ","MEQ_SEQTIT")
		Replace MEQ->MEQ_OPERAC  with "1"
		Replace MEQ->MEQ_DTINC	 with dDataBase
		Replace MEQ->MEQ_SALDO   with aTitGrvMeq[nRg,5]  
		ConFirmSX8()  
		MEQ->(MsUnLock())                       
	Next
		                    	
	RestArea(aAreas)	   
	
Return	  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLj2510Jur บAutor  ณMicrosiga           บ Data ณ  03/27/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que converte para mensal a taxa diaria de juros     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
   
Static Function Lj2510Jur(nMvFinJrTp, cMvJurTipo)

	Local aArea   := GetArea()      // area posicionada para retorno do posicionamento ao final do processamento
	Local nJurMes := 0              // conterแ os juros mensais  
	
	
	If cMvJurTipo <> "L"
	                
	   //	If SE1->(E1_VENCREA) < dDataBase
		If  nMvFinJrTp == 1  
			nJurMes := SE1->((E1_VALJUR/E1_VALOR)*100) * 30 //Taxa de Permanencia
		Else
			If nMvFinJrTp == 2  
				nJurMes := SE1->E1_PORCJUR  * 30
			ElseIf	nMvFinJrTp == 3	
				nJurMes := SE1->(E1_PORCJUR + ((E1_VALJUR/E1_VALOR)*100))  * 30
		    EndIf  
		EndIf 
		If cMvJurTipo == "C" //Formula composta	
			nJurMes := (((1 +(nJurMes/3000))**30)-1) *100  
		EndIf 
	EndIf
	
	RestArea(aArea)

Return nJurMes         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLj2510Fin บAutor  ณMicrosiga           บ Data ณ  07/04/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que retorna da Taxa de Financiamento                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
   
Static Function Lj2510Fin(cPrefixo, cNumero)

	Local aArea   := GetArea()      // area posicionada para retorno do posicionamento ao final do processamento
	Local aAreaSL1 := SL1->(GetArea())            // conterแ os juros mensais  
	Local nTaxaFin := 0     
	Local cFilSL1 := xFilial("SL1")    
	Local nTamSer := SL1->(TamSX3("L1_SERIE")[1])
	Local nTamDoc := SL1->(TamSX3("L1_DOC")[1])
	
	SL1->(DbSetOrder(11)) //L1_FILIAL + L1_SERPED + L1_DOCPED
	
	If !SL1->(DbSeek(cFilSL1+PadR(cPrefixo,nTamSer) + PadR(cNumero, nTamDoc)))
		SL1->(DbSetOrder(2)) //L1_FILIAL + L1_SERIE + L1_DOC
		SL1->(DbSeek(cFilSL1+PadR(cPrefixo,nTamSer) + PadR(cNumero, nTamDoc)))
	EndIf
	
	If SL1->(Found())
		nTaxaFin := SL1->L1_JUROS
	EndIf
	
	RestArea(aAreaSL1)
	
	RestArea(aArea)

Return nTaxaFin   
