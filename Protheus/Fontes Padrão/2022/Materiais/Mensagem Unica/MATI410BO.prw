#INCLUDE "MATI410BO.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWADAPTEREAI.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATI410BO
Mensagem unica de Rastreabilidade de Pedidos Venda\Compra com o Objeto Eai(FwObjEai)

@param oEaiObjEnt	- Objeto Eai de entrada
@param nTypeTrans	- Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage	- Tipo de mensagem. (Business Type, WhoIs, etc)
@param cVersion		- Versão em uso

@retorno aRet		- Array contendo o resultado da execucao.
			aRet[1]	(boolean)	- Indica o resultado da execução da função
			aRet[2]	(indefinido)- Objeto FwObjEai ou descrição do erro
			aRet[3]	(caracter)	- Nome da mensagem
			aRet[4]	(caracter)	- Tipo da mensagem

@author	 Rafael Tenorio da Costa 
@since 	 16/10/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function MATI410BO(oEaiObjEnt, nTypeTrans, cTypeMessage, cVersion)

	Local aRet := {.F., "", "DOCUMENTTRACEABILITYORDER", "JSON"}
	Local aAux := {}
	
	If nTypeTrans == TRANS_RECEIVE

		If cTypeMessage == EAI_MESSAGE_WHOIS
			aRet[1] := .T.
			aRet[2] := "1.000|1.001"
		Else
			aRet[1] := .F.
			aRet[2] := STR0001 + cTypeMessage	//"Tipo de mensagem não implementado: "
		EndIf

	ElseIf nTypeTrans == TRANS_SEND

		//Faz chamada da versão especifica
		If AllTrim(cVersion) == "1.000"
			aAux := v1000(oEaiObjEnt, nTypeTrans, cTypeMessage)
			
			aRet[1] := aAux[1]
			aRet[2] := aAux[2]
		ElseIf AllTrim(cVersion) == "1.001"
			aAux := v1001(oEaiObjEnt, nTypeTrans, cTypeMessage)
			
			aRet[1] := aAux[1]
			aRet[2] := aAux[2]	
		Else
			aRet[1] := .F.
			aRet[2] := STR0002	//"A versao da mensagem informada não foi implementada"
		EndIf
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} v1000
Efetuar o envio da menaagem unica

@param oEaiObjEnt	- Objeto Eai de entrada
@param nTypeTrans	- Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage	- Tipo de mensagem. (Business Type, WhoIs, etc)

@retorno aRet		- Array contendo o resultado da execucao.
			aRet[1]	(boolean)	- Indica o resultado da execução da função
			aRet[2]	(FwObjEai) 	- Objeto FwObjEai utilizado para o envio

@author	 Rafael Tenorio da Costa 
@since 	 16/10/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function v1000(oEaiObjEnt, nTypeTrans, cTypeMessage)

	Local aArea		 := GetArea()
	Local aRet		 := {.T., ""}
	Local oFwEaiObj  := FwEaiObj():New()
	Local oNFEaiObj	 := Nil
	Local cFunName	 := AllTrim( FunName() )
	Local aPedVen	 := {}
	Local aNfSaid	 := {}
	Local aRetSale	 := {}
	Local cRetSaleId := ""	
	Local cForn		 := ""
	Local cLoja		 := ""
	Local aRatCC	 := {}
	Local aRatPrj	 := {}
	Local nNF		 := 0
	
	//Pedido de Compra
	If cFunName $ "MATA120|MATA121"
	
		aRet[1] := .F.
		aRet[2] := STR0003	//"Mensagem de Pedido de Compra não implementada"
	
	//Pedido de Venda
	Else
	
		oFwEaiObj:Activate()
		oFwEaiObj:SetEvent("upsert")
		
		//Busca pedido de venda
		aPedVen := A410BPV(SC5->C5_NUM)
		
		If Len(aPedVen) > 0
			
			aItens	:= aPedVen[1][7]
			aRatCC	:= aPedVen[1][8]
			aRatPrj	:= aPedVen[1][9]
			cForn	:= Separa(aPedVen[1][4], "|")[1]
			cLoja	:= Separa(aPedVen[1][4], "|")[2]

			//Pedido gerado pelo Loja (C5_ORCRES), pega orçamento que originou Pedido de Venda
			If ExistFunc("LjxjSaleId") .And. !Empty(aPedVen[1][12])
				cRetSaleId := LjxjSaleId(aPedVen[1][11], aPedVen[1][12])
			EndIf	
			
			oFwEaiObj:SetProp("InternalId"		 		, IntPdVExt( , , aPedVen[1][1])[2]						)
			oFwEaiObj:SetProp("CompanyInternalId"		, AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt)				)
			oFwEaiObj:SetProp("CompanyId"		 		, AllTrim(cEmpAnt)										)
			oFwEaiObj:SetProp("BranchId"		 		, AllTrim(cFilAnt)										)
			oFwEaiObj:SetProp("Number"			 		, AllTrim(aPedVen[1][1])								)
			oFwEaiObj:SetProp("Status"			 		, AllTrim(aPedVen[1][6])								)
			oFwEaiObj:SetProp("TraceabilityCode"		, AllTrim(aPedVen[1][10])								)			
			oFwEaiObj:SetProp("RegisterDate"	 		, AllTrim( Transform(aPedVen[1][2], "@R 9999-99-99") )	)
			oFwEaiObj:SetProp("DeliveryDate"	 		, AllTrim( Transform(aPedVen[1][3], "@R 9999-99-99") )	)
			oFwEaiObj:SetProp("CustomerVendorInternalId", IntCliExt( , , cForn, cLoja)[2]						)
			oFwEaiObj:SetProp("Value"					, cValToChar(aPedVen[1][5])								)
			oFwEaiObj:SetProp("Type"					, "001"													)
			oFwEaiObj:SetProp("RetailSalesInternalId"	, cRetSaleId											)
			
			//Carrega itens do pedido
			CarItens(aItens  , aRatCC  , aRatPrj , "PV"		 , aPedVen[1][1],;
				  	 /*cSer*/, /*cCli*/, /*cLoj*/, @oFwEaiObj)
		
			oFwEaiObj:SetProp("ReturnTraceability")
	    	oFwEaiObj:GetPropValue("ReturnTraceability"):SetProp("ListOfTraceability")
	
			//Carrega as notas de saida
			aNfSaid := A410BNFS(aPedVen)
			  		
			If Len(aNfSaid) > 0
			
				For nNF:= 1 To Len(aNfSaid)
					aItens	:= aNfSaid[nNF][8]
					aRatCC	:= aNfSaid[nNF][9]
					aRatPrj	:= aNfSaid[nNF][10]
					cForn	:= Separa(aNfSaid[nNF][4], "|")[1]
					cLoja	:= Separa(aNfSaid[nNF][4], "|")[2]
					
					oNFEaiObj := oFwEaiObj:GetPropValue("ReturnTraceability"):GetPropValue("ListOfTraceability"):SetProp("Invoice", {})					
					
    				oNFEaiObj[nNF]:SetProp("InternalId"			, AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt) + "|" + AllTrim(aNfSaid[nNF][1]) + "|" + AllTrim(aNfSaid[nNF][2]) + "|" + AllTrim(cForn) + "|" + AllTrim(cLoja))
    				oNFEaiObj[nNF]:SetProp("CompanyInternalId"	, AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt)				)    				
    				oNFEaiObj[nNF]:SetProp("CompanyId"			, AllTrim(cEmpAnt)										)
					oNFEaiObj[nNF]:SetProp("BranchId"			, AllTrim(cFilAnt)										)
					oNFEaiObj[nNF]:SetProp("Number"				, AllTrim(aNfSaid[nNF][1])								)
					oNFEaiObj[nNF]:SetProp("Serie"				, AllTrim(aNfSaid[nNF][2])								)
					oNFEaiObj[nNF]:SetProp("Status"				, AllTrim(aNfSaid[nNF][7])								)
					oNFEaiObj[nNF]:SetProp("IssueDate"			, AllTrim( Transform(aNfSaid[nNF][3], "@R 9999-99-99") ))
					oNFEaiObj[nNF]:SetProp("VendorInternalId"	, IntCliExt( , , cForn, cLoja)[2]						)
					oNFEaiObj[nNF]:SetProp("Value"				, AllTrim( cValToChar(aNfSaid[nNF][6]) )				)
					oNFEaiObj[nNF]:SetProp("TypeOfDocument"		, AllTrim(aNfSaid[nNF][5])								)
					oNFEaiObj[nNF]:SetProp("ElectronicAccessKey", AllTrim(aNfSaid[nNF][12])								)
					
					//Carrega itens da nota fiscal
					CarItens(aItens		    , aRatCC, aRatPrj, "NFS"		  , aNfSaid[nNF][1],;
					 		 aNfSaid[nNF][2], cForn , cLoja	 , @oNFEaiObj[nNF])

					oNFEaiObj[nNF]:SetProp("ListOfParentInternalId")
					oNFEaiObj[nNF]:GetPropValue("ListOfParentInternalId"):SetProp("ParentInternalId")
					oNFEaiObj[nNF]:GetPropValue("ListOfParentInternalId"):GetPropValue("ParentInternalId"):SetProp("InternalId", IntPdVExt( , , aNfSaid[nNF][11])[2] )
					oNFEaiObj[nNF]:GetPropValue("ListOfParentInternalId"):GetPropValue("ParentInternalId"):SetProp("TypeCode"  , "004"								 )
	      		Next nNF
			Endif
			
			aRet[1] := .T.
			aRet[2] := oFwEaiObj
		Else
			
			aRet[1] := .F.
			aRet[2] := STR0004	//"Pedido de venda não encontrato no Protheus"
		EndIf
	EndIf
	
	FwFreeObj(aPedVen)
	FwFreeObj(aNfSaid)
	FwFreeObj(aRetSale)
	FwFreeObj(aRatCC)
	FwFreeObj(aRatPrj)
	
	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CarItens
Carrega os itens da mensagem do Pedido de venda ou da Nota fiscal de saida

@param aItens	 - Itens a serem informados
@param aRatCC    - Rateio por centro de custo a ser informado
@param aRatPrj   - Rateio por projeto a ser informado
@param cTipo	 - Tipo dos itens a serem carregados
@param cNum		 - Numero do peodito ou nota
@param cSer		 - Serie da nota
@param cCli		 - Cliente da nota
@param cLoj		 - Loja do cliente da nota
@param oFwEaiObj - Objeto Eai para ser atualizado com os itens

@return oFwEaiObj - Objeto atualizado com os itens

@author	 Rafael Tenorio da Costa 
@since 	 17/10/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CarItens(aItens, aRatCC, aRatPrj, cTipo	   , cNum,;
 						 cSer  , cCli  , cLoj	, oFwEaiObj)

	Local nItem	   	:= 0
	Local nRat	   	:= 0
	Local cInterId 	:= ""
	Local oItem 	:= Nil	
	Local oRatCC 	:= Nil
	Local oRatPrj	:= Nil
	
	Default cSer	:= ""
	Default cCli 	:= ""
	Default cLoj 	:= ""
	
	oFwEaiObj:SetProp("ListOfItem")
	
	If Len(aItens) > 0
	
		For nItem:= 1 To Len(aItens)
		
	    	If cTipo == "PV"
	    		cInterId := IntPdVExt( , , cNum, aItens[nItem][1])[2]
	    	Else
	    		cInterId := AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt) + "|" + AllTrim(cNum) + "|" + AllTrim(cSer) + "|" + AllTrim(cCli) + "|" + AllTrim(cLoj) + "|" + AllTrim(aItens[nItem][1])
	    	EndIf
	    	
			oItem := oFwEaiObj:GetPropValue("ListOfItem"):SetProp("Item", {})	    	
	    	
	    	oItem[nItem]:SetProp("InternalId"				, cInterId									)
	    	oItem[nItem]:SetProp("Number"					, AllTrim(aItens[nItem][1])					)
	    	oItem[nItem]:SetProp("ItemInternalId"			, IntProExt( , , aItens[nItem][2])[2]		)
	    	oItem[nItem]:SetProp("UnitofMeasureInternalId"	, IntUndExt( , , aItens[nItem][3])[2]		)
	    	oItem[nItem]:SetProp("Quantity"					, AllTrim( cValToChar(aItens[nItem][4]) )	)
	    	oItem[nItem]:SetProp("UnitPrice"				, AllTrim( cValToChar(aItens[nItem][5]) )	)
	    	oItem[nItem]:SetProp("TotalPrice"				, AllTrim( cValToChar(aItens[nItem][6]) )	)
	    	oItem[nItem]:SetProp("WarehouseInternalId"		, IntLocExt( , , aItens[nItem][7])[2]		)
	    	
	    	oItem[nItem]:SetProp("ListOfApportionCost")
	    	
	    	If Len(aRatCC) > 0
	    		For nRat:= 1 To Len(aRatCC)
	    		
	    			If AllTrim(aItens[nItem][1]) == AllTrim(aRatCC[nRat][3])
	    				If cTipo == "PV"
	    					cInterId := IntPdVExt( , , cNum, aRatCC[nRat][3])[2]
				    	Else
				    		cInterId := AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt) + "|" + AllTrim(cNum) + "|" + AllTrim(cSer) + "|" + AllTrim(cCli) + "|" + AllTrim(cLoj) + "|" + AllTrim(aRatCC[nRat][3]) 
				    	EndIf
				    	
				    	oRatCC := oItem[nItem]:GetPropValue("ListOfApportionCost"):SetProp("ApportionCost", {})
				    	
	    				oRatCC[nRat]:SetProp("InternalId"		  	, cInterId 								)      				
	    				oRatCC[nRat]:SetProp("CostCenterInternalId"	, IntCusExt( , , aRatCC[nRat][1])[2] 	)
	    				oRatCC[nRat]:SetProp("Percentual"			, AllTrim( cValToChar(aRatCC[nRat][2]) ))
	      			EndIf
	      		Next nRat
	      	EndIf
	      	
	      	oItem[nItem]:SetProp("ListOfApportionTask")
	      	
	      	If Len(aRatPrj) > 0
	      		For nRat:= 1 To Len(aRatPrj)

	      			If AllTrim(aItens[nItem][2]) == AllTrim(aRatPrj[nRat][4])
	      				oRatPrj := oItem[nItem]:GetPropValue("ListOfApportionTask"):SetProp("ApportionTask", {})
	      					      			
	      				oRatPrj[nRat]:SetProp("InternalId"			, IntProExt( , , aRatPrj[nRat][4])[2]										)
	      				oRatPrj[nRat]:SetProp("ProjectInternalId"	, IntPrjExt( , , aRatPrj[nRat][1])[2]										)
	      				oRatPrj[nRat]:SetProp("SubProjectInternalId", ""																		)
	      				oRatPrj[nRat]:SetProp("TaskInternalId"		, IntTrfExt( , , aRatPrj[nRat][1], aRatPrj[nRat][5], aRatPrj[nRat][2])[2]	)
	      				oRatPrj[nRat]:SetProp("Quantity"			, AllTrim( cValToChar(aRatPrj[nRat][3]) )									)
	      			EndIf
	      		Next nRat
	   		EndIf
	   		
	    Next nItem
	    
	EndIf

Return oFwEaiObj
//-------------------------------------------------------------------
/*/{Protheus.doc} v1001
Efetuar o envio da menaagem unica

@param oEaiObjEnt	- Objeto Eai de entrada
@param nTypeTrans	- Tipo de transacao. (Envio/Recebimento)
@param cTypeMessage	- Tipo de mensagem. (Business Type, WhoIs, etc)

@retorno aRet		- Array contendo o resultado da execucao e Dados da SEFAZ.
			aRet[1]	(boolean)	- Indica o resultado da execução da função
			aRet[2]	(FwObjEai) 	- Objeto FwObjEai utilizado para o envio

@author	 Everson S P Junior
@since 	 09/08/22
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function v1001(oEaiObjEnt, nTypeTrans, cTypeMessage)

	Local aArea		 := GetArea()
	Local aRet		 := {.T., ""}
	Local oFwEaiObj  := FwEaiObj():New()
	Local oNFEaiObj	 := Nil
	Local cFunName	 := AllTrim( FunName() )
	Local aPedVen	 := {}
	Local aNfSaid	 := {}
	Local aRetSale	 := {}
	Local cRetSaleId := ""	
	Local cForn		 := ""
	Local cLoja		 := ""
	Local aRatCC	 := {}
	Local aRatPrj	 := {}
	Local nNF		 := 0
	Local oTssNfce   := LOJGNFCE():new()
	Local lExistMeth := MethIsMemberOf(oTssnfce,"LjRetornaNotas")	
	Local aRetTssNfce  := {}
	
	//Pedido de Compra
	If cFunName $ "MATA120|MATA121"
	
		aRet[1] := .F.
		aRet[2] := STR0003	//"Mensagem de Pedido de Compra não implementada"
	
	//Pedido de Venda
	Else
	
		oFwEaiObj:Activate()
		oFwEaiObj:SetEvent("upsert")
		
		//Busca pedido de venda
		aPedVen := A410BPV(SC5->C5_NUM)
		
		If Len(aPedVen) > 0
			
			aItens	:= aPedVen[1][7]
			aRatCC	:= aPedVen[1][8]
			aRatPrj	:= aPedVen[1][9]
			cForn	:= Separa(aPedVen[1][4], "|")[1]
			cLoja	:= Separa(aPedVen[1][4], "|")[2]

			//Pedido gerado pelo Loja (C5_ORCRES), pega orçamento que originou Pedido de Venda
			If ExistFunc("LjxjSaleId") .And. !Empty(aPedVen[1][12])
				cRetSaleId := LjxjSaleId(aPedVen[1][11], aPedVen[1][12])
			EndIf	
			
			oFwEaiObj:SetProp("InternalId"		 		, IntPdVExt( , , aPedVen[1][1])[2]						)
			oFwEaiObj:SetProp("CompanyInternalId"		, AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt)				)
			oFwEaiObj:SetProp("CompanyId"		 		, AllTrim(cEmpAnt)										)
			oFwEaiObj:SetProp("BranchId"		 		, AllTrim(cFilAnt)										)
			oFwEaiObj:SetProp("Number"			 		, AllTrim(aPedVen[1][1])								)
			oFwEaiObj:SetProp("Status"			 		, AllTrim(aPedVen[1][6])								)
			oFwEaiObj:SetProp("TraceabilityCode"		, AllTrim(aPedVen[1][10])								)			
			oFwEaiObj:SetProp("RegisterDate"	 		, AllTrim( Transform(aPedVen[1][2], "@R 9999-99-99") )	)
			oFwEaiObj:SetProp("DeliveryDate"	 		, AllTrim( Transform(aPedVen[1][3], "@R 9999-99-99") )	)
			oFwEaiObj:SetProp("CustomerVendorInternalId", IntCliExt( , , cForn, cLoja)[2]						)
			oFwEaiObj:SetProp("Value"					, cValToChar(aPedVen[1][5])								)
			oFwEaiObj:SetProp("Type"					, "001"													)
			oFwEaiObj:SetProp("RetailSalesInternalId"	, cRetSaleId											)
			
			//Carrega itens do pedido
			CarItens(aItens  , aRatCC  , aRatPrj , "PV"		 , aPedVen[1][1],;
				  	 /*cSer*/, /*cCli*/, /*cLoj*/, @oFwEaiObj)
		
			oFwEaiObj:SetProp("ReturnTraceability")
	    	oFwEaiObj:GetPropValue("ReturnTraceability"):SetProp("ListOfTraceability")
	
			//Carrega as notas de saida
			aNfSaid := A410BNFS(aPedVen)
			  		
			If Len(aNfSaid) > 0
			
				For nNF:= 1 To Len(aNfSaid)
					aItens	:= aNfSaid[nNF][8]
					aRatCC	:= aNfSaid[nNF][9]
					aRatPrj	:= aNfSaid[nNF][10]
					cForn	:= Separa(aNfSaid[nNF][4], "|")[1]
					cLoja	:= Separa(aNfSaid[nNF][4], "|")[2]
					
					oNFEaiObj := oFwEaiObj:GetPropValue("ReturnTraceability"):GetPropValue("ListOfTraceability"):SetProp("Invoice", {})					
					
    				oNFEaiObj[nNF]:SetProp("InternalId"			, AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt) + "|" + AllTrim(aNfSaid[nNF][1]) + "|" + AllTrim(aNfSaid[nNF][2]) + "|" + AllTrim(cForn) + "|" + AllTrim(cLoja))
    				oNFEaiObj[nNF]:SetProp("CompanyInternalId"	, AllTrim(cEmpAnt) + "|" + AllTrim(cFilAnt)				)    				
    				oNFEaiObj[nNF]:SetProp("CompanyId"			, AllTrim(cEmpAnt)										)
					oNFEaiObj[nNF]:SetProp("BranchId"			, AllTrim(cFilAnt)										)
					oNFEaiObj[nNF]:SetProp("Number"				, AllTrim(aNfSaid[nNF][1])								)
					oNFEaiObj[nNF]:SetProp("Serie"				, AllTrim(aNfSaid[nNF][2])								)
					oNFEaiObj[nNF]:SetProp("Status"				, AllTrim(aNfSaid[nNF][7])								)
					oNFEaiObj[nNF]:SetProp("IssueDate"			, AllTrim( Transform(aNfSaid[nNF][3], "@R 9999-99-99") ))
					oNFEaiObj[nNF]:SetProp("VendorInternalId"	, IntCliExt( , , cForn, cLoja)[2]						)
					oNFEaiObj[nNF]:SetProp("Value"				, AllTrim( cValToChar(aNfSaid[nNF][6]) )				)
					oNFEaiObj[nNF]:SetProp("TypeOfDocument"		, AllTrim(aNfSaid[nNF][5])								)
					oNFEaiObj[nNF]:SetProp("ElectronicAccessKey", AllTrim(aNfSaid[nNF][12])								)
					
					//Carrega itens da nota fiscal
					CarItens(aItens		    , aRatCC, aRatPrj, "NFS"		  , aNfSaid[nNF][1],;
					 		 aNfSaid[nNF][2], cForn , cLoja	 , @oNFEaiObj[nNF])

					oNFEaiObj[nNF]:SetProp("ListOfParentInternalId")
					oNFEaiObj[nNF]:GetPropValue("ListOfParentInternalId"):SetProp("ParentInternalId")
					oNFEaiObj[nNF]:GetPropValue("ListOfParentInternalId"):GetPropValue("ParentInternalId"):SetProp("InternalId", IntPdVExt( , , aNfSaid[nNF][11])[2] )
					oNFEaiObj[nNF]:GetPropValue("ListOfParentInternalId"):GetPropValue("ParentInternalId"):SetProp("TypeCode"  , "004"								 )

 					If lExistMeth
						oTssnfce:LjRetornaNotas(aNfSaid[nNF][2]+aNfSaid[nNF][1])
            			aRetTssNfce := oTssnfce:aResultRetornaNotasNx
					EndIf	

					oNFEaiObj[nNF]:SetProp("DocumentContent")
					oNFEaiObj[nNF]:GetPropValue("DocumentContent"):SetProp("DocumentContentxml")
					oNFEaiObj[nNF]:GetPropValue("DocumentContent"):GetPropValue("DocumentContentxml"):SetProp("Xml",IIF(lExistMeth,Encode64(aRetTssNfce[2]),""))
					oNFEaiObj[nNF]:GetPropValue("DocumentContent"):GetPropValue("DocumentContentxml"):SetProp("ReturnCode",IIF(lExistMeth,aRetTssNfce[3],""))
					oNFEaiObj[nNF]:GetPropValue("DocumentContent"):GetPropValue("DocumentContentxml"):SetProp("XmlAuth",IIF(lExistMeth,Encode64(aRetTssNfce[4]),""))
					oNFEaiObj[nNF]:GetPropValue("DocumentContent"):GetPropValue("DocumentContentxml"):SetProp("StatusCodeSefaz",IIF(lExistMeth,aRetTssNfce[5],"404"))
					oNFEaiObj[nNF]:GetPropValue("DocumentContent"):GetPropValue("DocumentContentxml"):SetProp("StatusContent",IIF(lExistMeth,aRetTssNfce[6],"Aplicar Atualização dos fontes LOJXNFCE e LOJGNFCE com data maior que 11/08/2022"))
	      		Next nNF 
			Endif
			
			aRet[1] := .T.
			aRet[2] := oFwEaiObj
		Else
			
			aRet[1] := .F.
			aRet[2] := STR0004	//"Pedido de venda não encontrato no Protheus"
		EndIf
	EndIf
	
	FwFreeObj(aPedVen)
	FwFreeObj(aNfSaid)
	FwFreeObj(aRetSale)
	FwFreeObj(aRatCC)
	FwFreeObj(aRatPrj)
	
	RestArea(aArea)

Return aRet
