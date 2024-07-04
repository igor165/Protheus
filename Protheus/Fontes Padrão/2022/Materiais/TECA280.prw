#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA280.CH" 
 
Static oMdlADZPrd	 := Nil	 	// ModelGrid Produtos.   
Static oMdlADZAce	 := Nil		// ModelGrid Acessorios.
Static oMdlPro	 := Nil 		// Model principal proposta
                 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTECA280	 บAutor  ณVendas CRM          บ Data ณ 26/03/12    บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ 
ฑฑบDesc.     ณVistoria Tecnica x Proposta Comercial.					  		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro					                          	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Codigo da Vistoria Tecnica.		 				  	 บฑฑ   
ฑฑบ			   ณExpO2 - Model da Proposta Comercial.  				 		 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA280							                           	 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TECA280(cCodVis,oModel)

Local bCloseOnOk	:= {|| .T. }                 	// Acao do botao Fechar.
Local bOk		 	:= {|oMdl|At280AdItP(oMdl)}	// Acao do botao Ok.
Local oMdlADY		:= oModel:GetModel("ADYMASTER")
Local lRetorno 	:= .T.
                 
Default cCodVis 	:= "" 

oMdlADZPrd 	:= oModel:GetModel("ADZPRODUTO") 	// ModelGrid Produtos.   
oMdlADZAce 	:= oModel:GetModel("ADZACESSOR")	// ModelGrid Acessorios.
oMdlPro	 	:= oModel

If ( Empty(cCodVis) .AND. (oMdlADY:GetValue("ADY_VISTEC") == "1" .AND.;
  	 !Empty(oMdlADY:GetValue("ADY_CODVIS")) .AND. oMdlADY:GetValue("ADY_SITVIS") == "3" ) )
	cCodVis := oMdlADY:GetValue("ADY_CODVIS") 
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Compara a ultima vistoria tecnica concluida com a proposta comercial. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cCodVis) 
		
	If lRetorno 
		DbSelectArea("AAT")
		DbSetOrder(1)
		  
		If DbSeek(xFilial("AAT")+cCodVis)
			FWExecView(STR0001,"VIEWDEF.TECA280",4,/*oDlg*/,bCloseOnOk,bOk,/*nPercReducao*/)    // "Comparar"
		EndIf
					
		A600CroFinance( oModel, .T. ) 	//Atualiza cronograma financeiro
		A600Total( Nil, oModel )			//Atualiza total geral		 
	EndIf
	
Else
	lRetorno := .F.
	MsgAlert( STR0054, STR0003 ) // "Vistoria T้cnica nใo disponํvel para compara็ใo!"#"Aten็ใo"
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณModelDef  บAutor  ณVendas CRM          บ Data ณ  13/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณModelo de Dados Comp. Vist. Tecnica x Proposta Comercial.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpO - Modelo de Dados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum					                      			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA280                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function ModelDef()

Local oModel 	 := Nil																			   	   	// Objeto que contem o modelo de dados.
Local cCpAux1	 := "AAU_FILIAL|AAU_ITEM|AAU_PRODUT|AAU_DESCRI|AAU_UM|AAU_MOEDA|AAU_QTDVEN|AAU_PRCVEN|AAU_PRCTAB"   			// Campos Itens da Vistoria Tecnica.
Local cCpAux2	 := "|AAU_VLRTOT|AAU_TPPROD|AAU_ITPAI|AAU_ITPROP|AAU_FOLDER|AAU_LOCAL|AAU_CODVIS|AAU_OBRIG|"	   				// Campos Itens da Vistoria Tecnica.
Local cCpAux3	 := "ADZ_FILIAL|ADZ_ITEM|ADZ_PRODUT|ADZ_DESCRI|ADZ_UM|ADZ_MOEDA|ADZ_QTDVEN|ADZ_PRCVEN"   		   				// Campos Itens da Proposta Comercial.
Local cCpAux4	 := "|ADZ_PRCTAB|ADZ_TOTAL|ADZ_TPPROD|ADZ_ITPAI|ADZ_FOLDER|ADZ_LOCAL|ADZ_CODVIS|ADZ_ITEMVI|"					// Campos Itens da Proposta Comercial.
Local cCpoVis	 := cCpAux1+cCpAux2	  																	// Campos Itens da Vistoria Tecnica.
Local cCpoPrp	 := cCpAux3+cCpAux4																		// Campos Itens da Proposta Comercial.
Local bAvCpoVis  := {|cCampo| AllTrim(cCampo)+"|" $ cCpoVis }  										// Bloco de codigo para considerar na estrurura de dados somente campos relacionado.
Local bAvCpoPrp	 := {|cCampo| AllTrim(cCampo)+"|" $ cCpoPrp }        					  				// Bloco de codigo para considerar na estrurura de dados somente campos relacionado.
Local oStVisAAT	 := FWFormStruct(1,"AAT",/*bAvalCampo*/ ,/*lViewUsado*/)		   						// Objeto que contem a estrutura do cabecalho de vistoria.
Local oStVisPrd  := FWFormStruct(1,"AAU",bAvCpoVis,/*lViewUsado*/)						   		   		// Objeto que contem a estrutura de produtos da vistoria.
Local oStVisAce  := FWFormStruct(1,"AAU",bAvCpoVis,/*lViewUsado*/) 	   					   				// Objeto que contem a estrutura de acessorios da vistoria.
Local oStPrpPrd  := FWFormStruct(1,"ADZ",bAvCpoPrp,/*lViewUsado*/)	  								    // Objeto que contem a estrutura de produtos da proposta comercial.
Local oStPrpAce	 := FWFormStruct(1,"ADZ",bAvCpoPrp,/*lViewUsado*/) 	   									// Objeto que contem a estrutura de acessorios da proposta comercial.
Local nTamTot1	 := TamSX3("AAU_VLRTOT")[1] 								     		   				// Tamanho do campo AAU_VRLTOT.
Local nDecTot1	 := TamSX3("AAU_VLRTOT")[2]										   		   				// Numero de decimais do campo AAU_VLRTOT.
Local nTamTot2	 := TamSX3("ADZ_TOTAL") [1]					   					   		   				// Tamanho do campo ADZ_TOTAL.
Local nDecTot2	 := TamSX3("ADZ_TOTAL") [2]								   								// Numero de decimais do campo ADZ_TOTAL.
Local bCond	   	 := {|| .T. }												   	   		  				// Condicao para soma.
Local bLoadPrd	 := {|oMdlGrid,lCopy| At280LdPrd(oMdlGrid)}  			 		   				// Bloco de codigo para fazer load do(s) produto(s).
Local bLoadAce	 := {|oMdlGrid,lCopy| At280LdAce(oMdlGrid)} 				   		   				// Bloco de codigo para fazer load do(s) acessorio(s).
Local bActivate  := {|oMdl|At280Act(oMdl)}   									   		   				// Bloco de codigo executado depois da abertura do model.
Local oMdlCVis	 := Nil      				   											   	   			// Model calculado Vistoria Tecnica.
Local oMdlCProp	 := Nil      															   				// Model calculado Proposta Comercial.
Local lAgendAbb	:= SuperGetMv("MV_ATVTABB",,.F.)   													// Controla agenda pela ABB

// Legenda Vistoria Tecnica        
oStVisPrd:AddField(	AllTrim("")			,;  	// [01] C Titulo do campo
					AllTrim(STR0040)	,;   	// [02] C ToolTip do campo
     				"AAU_LEGEN" 		,;    	// [03] C identificador (ID) do Field
         			"C" 				,;    	// [04] C Tipo do campo
            		15 					,;    	// [05] N Tamanho do campo
              		0 					,;    	// [06] N Decimal do campo
                	Nil 				,;    	// [07] B Code-block de valida็ใo do campo
                 	Nil					,;     	// [08] B Code-block de valida็ใo When do campo
                  	Nil 				,;    	// [09] A Lista de valores permitido do campo
                   	Nil 				,;  	// [10] L Indica se o campo tem preenchimento obrigat๓rio
                    {|| "BR_LARANJA"} 	,;   	// [11] B Code-block de inicializacao do campo
                    Nil 				,;  	// [12] L Indica se trata de um campo chave
                    Nil 				,;     	// [13] L Indica se o campo pode receber valor em uma opera็ใo de update.
                    .T. )              			// [14] L Indica se o campo ้ virtual


oStVisAce:AddField(	AllTrim("")			,;  	// [01] C Titulo do campo
					AllTrim(STR0040)	,;   	// [02] C ToolTip do campo
     				"AAU_LEGEN" 		,;    	// [03] C identificador (ID) do Field
         			"C" 				,;    	// [04] C Tipo do campo
            		15 					,;    	// [05] N Tamanho do campo
              		0 					,;    	// [06] N Decimal do campo
                	Nil 				,;    	// [07] B Code-block de valida็ใo do campo
                 	Nil					,;     	// [08] B Code-block de valida็ใo When do campo
                  	Nil 				,;    	// [09] A Lista de valores permitido do campo
                   	Nil 				,;  	// [10] L Indica se o campo tem preenchimento obrigat๓rio
                    {|| "BR_LARANJA"} 	,;   	// [11] B Code-block de inicializacao do campo
                    Nil 				,;  	// [12] L Indica se trata de um campo chave
                    Nil 				,;     	// [13] L Indica se o campo pode receber valor em uma opera็ใo de update.
                    .T. )              			// [14] L Indica se o campo ้ virtual


// Legenda Proposta Comercial
oStPrpPrd:AddField(	AllTrim("")			,;  	// [01] C Titulo do campo
					AllTrim(STR0040)	,;   	// [02] C ToolTip do campo
     				"ADZ_LEGEN" 		,;    	// [03] C identificador (ID) do Field
         			"C" 				,;    	// [04] C Tipo do campo
            		15 					,;    	// [05] N Tamanho do campo
              		0 					,;    	// [06] N Decimal do campo
                	Nil 				,;    	// [07] B Code-block de valida็ใo do campo
                 	Nil					,;     	// [08] B Code-block de valida็ใo When do campo
                  	Nil 				,;    	// [09] A Lista de valores permitido do campo
                   	Nil 				,;  	// [10] L Indica se o campo tem preenchimento obrigat๓rio
                    {|| "BR_LARANJA"}  	,;   	// [11] B Code-block de inicializacao do campo
                    Nil 				,;  	// [12] L Indica se trata de um campo chave
                    Nil 				,;     	// [13] L Indica se o campo pode receber valor em uma opera็ใo de update.
                    .T. )              			// [14] L Indica se o campo ้ virtual


oStPrpAce:AddField(	AllTrim("")			,;  	// [01] C Titulo do campo
					AllTrim(STR0040)	,;   	// [02] C ToolTip do campo
     				"ADZ_LEGEN" 		,;    	// [03] C identificador (ID) do Field
         			"C" 				,;    	// [04] C Tipo do campo
            		15					,;    	// [05] N Tamanho do campo
              		0 					,;    	// [06] N Decimal do campo
                	Nil 				,;    	// [07] B Code-block de valida็ใo do campo
                 	Nil					,;     	// [08] B Code-block de valida็ใo When do campo
                  	Nil 				,;    	// [09] A Lista de valores permitido do campo
                   	Nil 				,;  	// [10] L Indica se o campo tem preenchimento obrigat๓rio
                    {|| "BR_LARANJA"} 	,;   	// [11] B Code-block de inicializacao do campo
                    Nil 				,;  	// [12] L Indica se trata de um campo chave
                    Nil 				,;     	// [13] L Indica se o campo pode receber valor em uma opera็ใo de update.
                    .T. )              			// [14] L Indica se o campo ้ virtual
                                    
oStVisPrd:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.) 
oStVisAce:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)  
oStPrpPrd:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.) 
oStPrpAce:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)  
  
oStPrpPrd:SetProperty("ADZ_PRODUT",MODEL_FIELD_OBRIGAT,.T.) 
oStPrpAce:SetProperty("ADZ_PRODUT",MODEL_FIELD_OBRIGAT,.T.) 

If lAgendAbb	        
	oStVisAAT:SetProperty("AAT_DTINI",MODEL_FIELD_OBRIGAT,.F.) 
	oStVisAAT:SetProperty("AAT_HRINI",MODEL_FIELD_OBRIGAT,.F.) 
	oStVisAAT:SetProperty("AAT_DTFIM",MODEL_FIELD_OBRIGAT,.F.)
	oStVisAAT:SetProperty("AAT_HRFIM",MODEL_FIELD_OBRIGAT,.F.)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Instancia o modelo de dados Vist. Tecnica x Proposta Comercial. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oModel := MPFormModel():New("TECA280",/*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/)    

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona os campos no modelo de dados da vistoria tecnica. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oModel:AddFields("AATMASTER", /*cOwner*/,oStVisAAT,/*bPreValidacao*/,/*bPosValidacao*/, /*bCarga*/)
oModel:AddGrid("VISPRDDET","AATMASTER",oStVisPrd ,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/)
oModel:AddGrid("VISACEDET","AATMASTER",oStVisAce,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona os campos calculados no modelo de dados da vistoria tecnica. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oModel:AddCalc("TOTALVIS","AATMASTER","VISPRDDET","AAU_VLRTOT","AAU__TOTPRD","SUM",bCond,/*bInitValue*/,;
               STR0004,/*bFormula*/,nTamTot1,nDecTot1)  // "( A ) - Produto(s)"

oModel:AddCalc("TOTALVIS","AATMASTER","VISACEDET","AAU_VLRTOT","AAU__TOTACE","SUM",bCond,/*bInitValue*/,;
               STR0005,/*bFormula*/,nTamTot1,nDecTot1)  // "( B ) - Acessorio(s)"

oModel:AddCalc("TOTALVIS","AATMASTER","VISPRDDET","AAU_VLRTOT","AAU__TOT","FORMULA",bCond,/*bInitValue*/,;
		       STR0006,{ |oModel| oModel:GetValue("TOTALVIS","AAU__TOTPRD")+oModel:GetValue("TOTALVIS","AAU__TOTACE")},nTamTot1,nDecTot1) // "( A+B )"  

oMdlCVis := oModel:GetModel("TOTALVIS")		
oMdlCVis:AddEvents("TOTALVIS","AAU__TOT","AAU__TOTACE",bCond)	
	       
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona os campos no modelo de dados da proposta comercial. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู		       
oModel:AddGrid("PRPPRDDET","AATMASTER",oStPrpPrd,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,bLoadPrd)
oModel:AddGrid("PRPACEDET","AATMASTER",oStPrpAce,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/,bLoadAce)   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona os campos calculados no modelo de dados da proposta comercial. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oModel:AddCalc("TOTALPRP","AATMASTER","PRPPRDDET","ADZ_TOTAL","ADZ__TOTPRD","SUM",bCond,/*bInitValue*/,;
			   STR0004,/*bFormula*/,nTamTot2,nDecTot2)   // "( A ) - Produto(s)"

oModel:AddCalc("TOTALPRP","AATMASTER","PRPACEDET","ADZ_TOTAL","ADZ__TOTACE","SUM",bCond,/*bInitValue*/,;
               STR0005,/*bFormula*/,nTamTot2,nDecTot2)   // "( B ) - Acessorio(s)"

oModel:AddCalc("TOTALPRP","AATMASTER","PRPPRDDET","ADZ_TOTAL","ADZ__TOT","FORMULA",bCond,/*bInitValue*/,;
               STR0006,{ |oModel| oModel:GetValue("TOTALPRP","ADZ__TOTPRD")+oModel:GetValue("TOTALPRP","ADZ__TOTACE") },nTamTot2,nDecTot2)  // "( A+B )"  

oMdlCProp := oModel:GetModel("TOTALPRP")		
oMdlCProp:AddEvents("TOTALPRP","ADZ__TOT","ADZ__TOTACE",bCond)               
                             
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do relacionamento da vistoria t้cnica. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู               
oModel:SetRelation("VISPRDDET",{{"AAU_FILIAL","xFilial('AAU')"},{"AAU_CODVIS","AAT_CODVIS"},{"AAU_FOLDER","'1'"}},AAU->( IndexKey(2)))
oModel:SetRelation("VISACEDET",{{"AAU_FILIAL","xFilial('AAU')"},{"AAU_CODVIS","AAT_CODVIS"},{"AAU_FOLDER","'2'"}},AAU->( IndexKey(2))) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem do relacionamento da proposta comercial. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู      
oModel:SetRelation("PRPPRDDET",{{"ADZ_FILIAL","xFilial('ADZ')"},{"ADZ_PROPOS","AAT_PROPOS"},{"ADZ_REVISA","ADY_PREVIS"},{"ADZ_FOLDER","'1'"}},ADZ->( IndexKey(3)))
oModel:SetRelation("PRPACEDET",{{"ADZ_FILIAL","xFilial('ADZ')"},{"ADZ_PROPOS","AAT_PROPOS"},{"ADZ_REVISA","ADY_PREVIS"},{"ADZ_FOLDER","'2'"}},ADZ->( IndexKey(3)))  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cabecalho Vistoria Tecnica. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู     
oModel:GetModel("AATMASTER"):SetOnlyView(.T.)
oModel:GetModel("AATMASTER"):SetOnlyQuery(.T.)  
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Vistoria Tecnica - Produto / Acessorios. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู     
oModel:GetModel("VISPRDDET"):SetOnlyQuery(.T.)
oModel:GetModel("VISACEDET"):SetOnlyQuery(.T.)   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Proposta Comercial - Produto / Acessorios. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู     
oModel:GetModel("PRPPRDDET"):SetOnlyQuery(.T.)
oModel:GetModel("PRPACEDET"):SetOnlyQuery(.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Permite de grid sem dados. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oModel:GetModel("VISACEDET"):SetOptional(.T.)
oModel:GetModel("PRPACEDET"):SetOptional(.T.)
                               
oModel:SetDescription(STR0007) // "Vistoria T้cnica x Proposta Comercial"

oModel:SetActivate(bActivate)

Return(oModel)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณViewDef   บAutor  ณVendas CRM          บ Data ณ  13/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInterface Comp. Vist. Tecnica x Proposta Comercial.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpO - Interface                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum					                      			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA280                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()

Local oView		:= Nil														   				 // Objeto que contem interface vistoria tecnica x proposta comercial.
Local oModel	:= FWLoadModel("TECA280")													 // Objeto que contem o modelo de dados.
Local cCpAux1	 := "AAU_FILIAL|AAU_ITEM|AAU_PRODUT|AAU_DESCRI|AAU_UM|AAU_MOEDA|AAU_QTDVEN|AAU_PRCVEN|AAU_PRCTAB"   			 // Campos Itens da Vistoria Tecnica.
Local cCpAux2	 := "|AAU_VLRTOT|AAU_TPPROD|AAU_ITPAI|AAU_ITPROP|AAU_FOLDER|AAU_LOCAL|AAU_CODVIS|AAU_OBRIG|"  			   		 // Campos Itens da Vistoria Tecnica.
Local cCpAux3	 := "ADZ_FILIAL|ADZ_ITEM|ADZ_PRODUT|ADZ_DESCRI|ADZ_UM|ADZ_MOEDA|ADZ_QTDVEN|ADZ_PRCVEN"   		   				 // Campos Itens da Proposta Comercial.
Local cCpAux4	 := "|ADZ_PRCTAB|ADZ_TOTAL|ADZ_TPPROD|ADZ_ITPAI|ADZ_FOLDER|ADZ_LOCAL|ADZ_CODVIS|ADZ_ITEMVI|"				     // Campos Itens da Proposta Comercial.
Local cCpoVis	:= cCpAux1+cCpAux2	  														 // Campos Itens da Vistoria Tecnica.
Local cCpoPrp	:= cCpAux3+cCpAux4															 // Campos Itens da Proposta Comercial.
Local bAvCpoVis := {|cCampo| AllTrim(cCampo)+"|" $ cCpoVis }  								 // Bloco de codigo para considerar na estrurura de dados somente campos relacionado.
Local bAvCpoPrp	:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoPrp }        						 // Bloco de codigo para considerar na estrurura de dados somente campos relacionado.
Local oStVisAAT	:= FWFormStruct(2,"AAT",/*bAvalCampo*/,/*lViewUsado*/)	   			     	 // Objeto que contem a estrutura do cabecalho de vistoria.
Local oStVisPrd	:= FWFormStruct(2,"AAU",bAvCpoVis,/*lViewUsado*/)	   					     // Objeto que contem a estrutura de produtos da vistoria.
Local oStVisAce	:= FWFormStruct(2,"AAU",bAvCpoVis,/*lViewUsado*/) 						     // Objeto que contem a estrutura de acessorios da proposta comercial.
Local oStPrpPrd	:= FWFormStruct(2,"ADZ",bAvCpoPrp,/*lViewUsado*/)	   					     // Objeto que contem a estrutura de produtos da proposta comercial.
Local oStPrpAce	:= FWFormStruct(2,"ADZ",bAvCpoPrp,/*lViewUsado*/) 							 // Objeto que contem a estrutura de acessorios da proposta comercial.
Local oCalcVis	:= Nil															             // Objeto que contem a estrutura dos campos calculados vistoria tecnica.
Local oCalcPrp	:= Nil 																		 // Objeto que contem a estrutura dos campos calculados proposta comercial.
Local oButtons	:= Nil																		 // Objeto para adicinar os botoes na interface.
       

// Legenda Vistoria Tecnica
oStVisPrd:AddField(	"AAU_LEGEN" 		,;	// [01] C Nome do Campo
					"01" 				,; 	// [02] C Ordem
					AllTrim("")			,; 	// [03] C Titulo do campo
     				AllTrim(STR0040)	,; 	// [04] C Descri็ใo do campo
         			{STR0040} 	   		,; 	// [05] A Array com Help
            		"C" 				,; 	// [06] C Tipo do campo
            		"@BMP" 				,; 	// [07] C Picture
              		Nil 				,; 	// [08] B Bloco de Picture Var
                	"" 					,; 	// [09] C Consulta F3
                 	.F. 				,;	// [10] L Indica se o campo ้ evitแvel
                  	Nil 				,; 	// [11] C Pasta do campo
                   	Nil 				,;	// [12] C Agrupamento do campo
                    Nil 				,; 	// [13] A Lista de valores permitido do campo (Combo)
                    Nil 				,;	// [14] N Tamanho Maximo da maior op็ใo do combo
                    Nil 				,;	// [15] C Inicializador de Browse
                    .T. 				,;	// [16] L Indica se o campo ้ virtual
                    Nil )                 	// [17] C Picture Variแvel    
                  
oStVisAce:AddField(	"AAU_LEGEN" 		,;	// [01] C Nome do Campo
					"01" 				,; 	// [02] C Ordem
					AllTrim("")			,; 	// [03] C Titulo do campo
     				AllTrim(STR0040)	,; 	// [04] C Descri็ใo do campo
         			{STR0040} 	  		,; 	// [05] A Array com Help
            		"C" 				,; 	// [06] C Tipo do campo
            		"@BMP" 				,; 	// [07] C Picture
              		Nil 				,; 	// [08] B Bloco de Picture Var
                	"" 					,; 	// [09] C Consulta F3
                 	.F. 				,;	// [10] L Indica se o campo ้ evitแvel
                  	Nil 				,; 	// [11] C Pasta do campo
                   	Nil 				,;	// [12] C Agrupamento do campo
                    Nil 				,; 	// [13] A Lista de valores permitido do campo (Combo)
                    Nil 				,;	// [14] N Tamanho Maximo da maior op็ใo do combo
                    Nil 				,;	// [15] C Inicializador de Browse
                    .T. 				,;	// [16] L Indica se o campo ้ virtual
                    Nil )                 	// [17] C Picture Variแvel

// Legenda Proposta Comercial
oStPrpPrd:AddField(	"ADZ_LEGEN" 		,;	// [01] C Nome do Campo
					"01" 				,; 	// [02] C Ordem
					AllTrim("")			,; 	// [03] C Titulo do campo
     				AllTrim(STR0040)	,; 	// [04] C Descri็ใo do campo
         			{STR0040} 	  		,; 	// [05] A Array com Help
            		"C" 				,; 	// [06] C Tipo do campo
            		"@BMP" 				,; 	// [07] C Picture
              		Nil 				,; 	// [08] B Bloco de Picture Var
                	"" 					,; 	// [09] C Consulta F3
                 	.F. 				,;	// [10] L Indica se o campo ้ evitแvel
                  	Nil 				,; 	// [11] C Pasta do campo
                   	Nil 				,;	// [12] C Agrupamento do campo
                    Nil 				,; 	// [13] A Lista de valores permitido do campo (Combo)
                    Nil 				,;	// [14] N Tamanho Maximo da maior op็ใo do combo
                    Nil 				,;	// [15] C Inicializador de Browse
                    .T. 				,;	// [16] L Indica se o campo ้ virtual
                    Nil )                 	// [17] C Picture Variแvel    
                  
oStPrpAce:AddField(	"ADZ_LEGEN" 		,;	// [01] C Nome do Campo
					"01" 				,; 	// [02] C Ordem
					AllTrim("")			,; 	// [03] C Titulo do campo
     				AllTrim(STR0040)	,; 	// [04] C Descri็ใo do campo
         			{STR0040} 	   		,; 	// [05] A Array com Help
            		"C" 				,; 	// [06] C Tipo do campo
            		"@BMP" 				,; 	// [07] C Picture
              		Nil 				,; 	// [08] B Bloco de Picture Var
                	"" 					,; 	// [09] C Consulta F3
                 	.F. 				,;	// [10] L Indica se o campo ้ evitแvel
                  	Nil 				,; 	// [11] C Pasta do campo
                   	Nil 				,;	// [12] C Agrupamento do campo
                    Nil 				,; 	// [13] A Lista de valores permitido do campo (Combo)
                    Nil 				,;	// [14] N Tamanho Maximo da maior op็ใo do combo
                    Nil 				,;	// [15] C Inicializador de Browse
                    .T. 				,;	// [16] L Indica se o campo ้ virtual
                    Nil )                 	// [17] C Picture Variแvel

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Remove o campo Item Pai da Aba Produtos da Vistoria / Proposta ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู   
oStVisPrd:RemoveField("AAU_ITPAI")  
oStPrpPrd:RemoveField("ADZ_ITPAI")

oStVisPrd:SetProperty("*" ,MVC_VIEW_CANCHANGE,.F.)
oStVisAce:SetProperty("*" ,MVC_VIEW_CANCHANGE,.F.)
oStPrpPrd:SetProperty("*" ,MVC_VIEW_CANCHANGE,.F.)
oStPrpAce:SetProperty("*" ,MVC_VIEW_CANCHANGE,.F.)    

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Instancia a interface Vist. Tecnica x Proposta Comercial. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oView := FWFormView():New()
oView:SetModel(oModel) 

//ฺฤฤฤฤฤฤฤฤฤฤฟ
//ณ Legenda. ณ
//ภฤฤฤฤฤฤฤฤฤฤู    
oView:AddUserButton(STR0040,"",{ || At280Leg()})  // Visualizar Prospota

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a estrutura dos campos calculados. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oCalcVis := FWCalcStruct(oModel:GetModel("TOTALVIS"))
oCalcPrp := FWCalcStruct(oModel:GetModel("TOTALPRP")) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona os campos no cabecalho. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oView:AddField("VIS_VIEW_AAT",oStVisAAT,"AATMASTER")
oView:AddField("VIS_VIEW_TOT",oCalcVis,"TOTALVIS")
oView:AddField("PRP_VIEW_TOT",oCalcPrp,"TOTALPRP")  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Adiciona os campos no grid. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oView:AddGrid("VIS_VIEW_PRD",oStVisPrd,"VISPRDDET")
oView:AddGrid("VIS_VIEW_ACE",oStVisAce,"VISACEDET")
oView:AddGrid("PRP_VIEW_PRD",oStPrpPrd,"PRPPRDDET")
oView:AddGrid("PRP_VIEW_ACE",oStPrpAce,"PRPACEDET") 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cabecalho da Vistoria. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oView:CreateHorizontalBox("VIS_TOP",35)
oView:EnableTitleView("VIS_VIEW_AAT",STR0008)   // "Informa็๕es da Vistoria T้cnica"
oView:SetOwnerView("VIS_VIEW_AAT","VIS_TOP")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Vist. Tecnica x Proposta Comercial. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oView:CreateHorizontalBox("VISXPROP",47)     

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Vistoria Tecnica. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oView:CreateVerticalBox("VIS_CENTER",48,"VISXPROP")
oView:CreateFolder("FOLDER_VIS","VIS_CENTER")
oView:AddSheet("FOLDER_VIS","TAB1",STR0009)   // "Produtos"
oView:AddSheet("FOLDER_VIS","TAB2",STR0010)   // "Acess๓rios"
oView:CreateHorizontalBox("VIS_HBX_TAB1",100,,,"FOLDER_VIS","TAB1") // Produtos
oView:CreateHorizontalBox("VIS_HBX_TAB2",100,,,"FOLDER_VIS","TAB2") // Acessorios
oView:EnableTitleView("VIS_VIEW_PRD",STR0011) // "Produtos levantados na Vistoria T้cnica"
oView:EnableTitleView("VIS_VIEW_ACE",STR0012) // "Acess๓rios levantados na Vistoria T้cnica"
oView:SetOwnerView("VIS_VIEW_PRD","VIS_HBX_TAB1")
oView:SetOwnerView("VIS_VIEW_ACE","VIS_HBX_TAB2")  

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Botoes de Acoes. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oView:CreateVerticalBox("BTN_CENTER",4,"VISXPROP")
oView:AddOtherObject("ACTION_BUTTONS",{|oPanel| At280BtAct(oPanel) })
oView:SetOwnerView("ACTION_BUTTONS","BTN_CENTER")    

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Proposta Comercial. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oView:CreateVerticalBox("PRP_CENTER",48,"VISXPROP")
oView:CreateFolder("FOLDER_PRP","PRP_CENTER")
oView:AddSheet("FOLDER_PRP","TAB1",STR0009) 							// "Produtos"
oView:AddSheet("FOLDER_PRP","TAB2",STR0010)								// "Acess๓rios"
oView:CreateHorizontalBox("PRP_HBX_TAB1",100,,,"FOLDER_PRP","TAB1") 	// "Produtos"
oView:CreateHorizontalBox("PRP_HBX_TAB2",100,,,"FOLDER_PRP","TAB2") 	// "Acessorios"
oView:EnableTitleView("PRP_VIEW_PRD",STR0013) 					   		// "Produtos or็ados na Proposta Comercial"
oView:EnableTitleView("PRP_VIEW_ACE",STR0014) 							// "Acess๓rios or็ados na Proposta Comercial"
oView:SetOwnerView("PRP_VIEW_PRD","PRP_HBX_TAB1")
oView:SetOwnerView("PRP_VIEW_ACE","PRP_HBX_TAB2") 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Totais da Vistoria Tecnica x Proposta Comercial. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oView:CreateHorizontalBox("TOTAL",18)
oView:CreateVerticalBox("VISTORIA",48,"TOTAL")
oView:EnableTitleView("VIS_VIEW_TOT",STR0015) 	// "Valor Total dos itens Vistoriados"
oView:SetOwnerView("VIS_VIEW_TOT","VISTORIA")
oView:CreateVerticalBox("RESERV",4,"TOTAL")
oView:CreateVerticalBox("PROPOSTA",48,"TOTAL")
oView:EnableTitleView("PRP_VIEW_TOT",STR0016) 	// "Valor Total dos itens or็ados na Proposta Comercial")
oView:SetOwnerView("PRP_VIEW_TOT","PROPOSTA")

Return(oView)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณVendas CRM          บ Data ณ  13/03/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCriacao do MenuDef.	  	                        		  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpA - Opcoes de menu                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum					                      			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA270                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0017 ACTION "PesqBrw" 			OPERATION 1	ACCESS 0  // "Pesquisar"
ADD OPTION aRotina TITLE STR0018 ACTION "VIEWDEF.TECA280"	OPERATION 2	ACCESS 0  // "Visualizar"
ADD OPTION aRotina TITLE STR0019 ACTION "VIEWDEF.TECA280"	OPERATION 4	ACCESS 0  // "Alterar" 

Return(aRotina)
                
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt270Leg  บAutor  ณVendas CRM          บ Data ณ  27/02/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณLegenda da Vistoria Tecnica.	  	                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณNenhum                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณNenhum					                      			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA270                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function At280Leg()

Local oLegenda  :=  FWLegend():New()

oLegenda:Add("","BR_VERDE",STR0035) 	// "Item nใo alterado."
oLegenda:Add("","BR_AMARELO",STR0036)	// "Item alterado."
oLegenda:Add("","BR_AZUL",STR0037) 		// "Item incluido na Vistoria."
oLegenda:Add("","BR_LARANJA",STR0038)	// "Item incluido na Proposta ou Item excluido na Vistoria."
oLegenda:Add("","BR_CINZA",STR0039)		// "Item excluido."

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt280BtAct บAutor  ณVendas CRM          บ Data ณ 26/03/12    บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona os botoes de acoes ">" , ">>" e "Subst."			   บฑฑ 
ฑฑบ			 ณno formulario MVC.										   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro					                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto panel		 						           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA280							                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function At280BtAct(oPanel)

Local nTop  := oPanel:nTop				// Posicao superior.
Local nLeft := oPanel:nLeft+2         	// Posicao esquerda.
Local oView := FwViewActive()			// Ativa a interface. 

@ (nTop+82),(nLeft)  Button ">"  Size 20, 10 Message STR0020 Pixel Action At280AdIt(oView)  Of oPanel  // "Adiciona item selecionado" 
@ (nTop+99),(nLeft)  Button ">>" Size 20, 10 Message STR0021 Pixel Action At280AdAll(oView) Of oPanel  // "Adiciona todos os itens"
@ (nTop+116),(nLeft) Button "Subst." Size 20, 10 Message STR0043 Pixel Action At280AdQnt(oView) Of oPanel  // "Adiciona todos os itens" 

Return( .T. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt280AdIt  บAutor  ณVendas CRM          บ Data ณ 26/03/12    บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBotao adiciona item ">".							           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro					                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto de interface.		 						   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA280							                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function At280AdIt(oView)

Local oMdl 	 	:= FWModelActive() 	 						// Retorna o model ativo.
Local aFolder 	:= oView:GetFolderActive("FOLDER_VIS",2) 	// Retorna a pasta selecionada.
Local oMdlVisPrd	:= oMdl:GetModel("VISPRDDET")   			// Modelo de dados vistoria - produtos.
Local oMdlVisAce	:= oMdl:GetModel("VISACEDET")   			// Modelo de dados vistoria - acessorios.
Local oMdlProPrd	:= oMdl:GetModel("PRPPRDDET")  				// Modelo de dados proposta - produtos.
Local oMdlProAce	:= oMdl:GetModel("PRPACEDET")  				// Modelo de dados proposta - acessorios.
Local cItemPrd 		:= "" 										// Item do produto.
Local aAcessorio 	:= {}										// Array de acessorios.
Local nLinha		:= 0  										// Linha atual.
Local nX 			:= 0 									    // Incremento utilizado no laco For.
Local lSeek		:= .F.										// Procura linha.
Local aArea		:= GetArea()
Local cNewItem    := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Folder Produtos. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aFolder[1] == 1
	
	lSeek := ( oMdlProPrd:SeekLine({{"ADZ_ITEM",oMdlVisPrd:GetValue("AAU_ITPROP")}}) .AND. !Empty(oMdlProPrd:GetValue("ADZ_PRODUT")) )
		
	If !lSeek								
		 
		If !Empty(oMdlVisPrd:GetValue("AAU_PRODUT"))
		
			If A600VldPOrc(oMdlVisPrd:GetValue("AAU_PRODUT"), oMdlVisPrd:GetValue("AAU_CODVIS"))
											
				If MsgYesNo(STR0055+Alltrim(oMdlVisPrd:GetValue("AAU_PRODUT"))+" - "+Alltrim(oMdlVisPrd:GetValue("AAU_DESCRI"))+STR0023,STR0024) // "Deseja atualizar o produto "#" na proposta comercial?"#Aten็ใo
					
					A600CombOrc( .F., oMdlVisPrd:GetValue("AAU_CODVIS"), oMdlVisPrd:GetValue("AAU_PRODUT"), oMdlPro )
					
					If oMdlProPrd:SeekLine( { { "ADZ_PRODUT", oMdlVisPrd:GetValue("AAU_PRODUT") }})					
					
						nTotal := oMdlVisPrd:GetValue("AAU_VLRTOT") + oMdlProPrd:GetValue("ADZ_TOTAL")
						oMdlProPrd:SetValue( "ADZ_CODVIS", oMdlVisPrd:GetValue("AAU_CODVIS") )					
						oMdlProPrd:SetValue( "ADZ_LEGEN" , "BR_AZUL" )
						oMdlProPrd:SetValue( "ADZ_PRCVEN", nTotal )
						oMdlProPrd:SetValue( "ADZ_TOTAL" , nTotal )				
					
					Else 
					
						cItemPrd := oMdlVisPrd:GetValue("AAU_ITEM")
					
						If (!Empty(oMdlProPrd:GetValue("ADZ_PRODUT")))
							nLinha := oMdlProPrd:AddLine()
						EndIf
					
						nLinha := oMdlProPrd:GetLine()
					
						If nLinha > 0
							oMdlProPrd:GoLine(nLinha)
							cNewItem := Soma1(oMdlProPrd:GetValue("ADZ_ITEM",(nLinha-1)))
							
							oMdlProPrd:SetValue("ADZ_LEGEN","BR_AZUL")
							oMdlProPrd:SetValue("ADZ_ITEM",cNewItem)
							oMdlProPrd:SetValue("ADZ_PRODUT",oMdlVisPrd:GetValue("AAU_PRODUT"))
							oMdlProPrd:SetValue("ADZ_DESCRI",oMdlVisPrd:GetValue("AAU_DESCRI"))
							oMdlProPrd:SetValue("ADZ_UM",oMdlVisPrd:GetValue("AAU_UM"))
							oMdlProPrd:SetValue("ADZ_MOEDA",oMdlVisPrd:GetValue("AAU_MOEDA"))
							oMdlProPrd:SetValue("ADZ_QTDVEN",oMdlVisPrd:GetValue("AAU_QTDVEN"))
							oMdlProPrd:SetValue("ADZ_PRCVEN",oMdlVisPrd:GetValue("AAU_PRCVEN"))
							oMdlProPrd:SetValue("ADZ_PRCTAB",oMdlVisPrd:GetValue("AAU_PRCTAB"))
							oMdlProPrd:SetValue("ADZ_TOTAL",oMdlVisPrd:GetValue("AAU_VLRTOT"))
							oMdlProPrd:SetValue("ADZ_TPPROD",oMdlVisPrd:GetValue("AAU_TPPROD"))
							oMdlProPrd:SetValue("ADZ_FOLDER",oMdlVisPrd:GetValue("AAU_FOLDER"))
							oMdlProPrd:SetValue("ADZ_CODVIS",oMdlVisPrd:GetValue("AAU_CODVIS"))
							oMdlProPrd:SetValue("ADZ_LOCAL",oMdlVisPrd:GetValue("AAU_LOCAL"))
							oMdlProPrd:SetValue("ADZ_ITEMVI",oMdlVisPrd:GetValue("AAU_ITEM"))
							
						EndIf						
					EndIf
					
					// Verifica se o item pai do RH precisa ser atualizado ou incluso					
					TFJ->( DbSetOrder( 6 ) ) //TFJ_FILIAL + TFJ_CODVIS
	
					If TFJ->( DbSeek( xFilial('TFJ') + oMdlVisPrd:GetValue("AAU_CODVIS") ) )					
					
						For nX := 1 To oMdlVisPrd:Length()
						
							oMdlVisPrd:GoLine(nX)
							
							If TFJ->TFJ_GRPRH ==	oMdlVisPrd:GetValue("AAU_PRODUT")
							
								lSeek := ( oMdlProPrd:SeekLine({{"ADZ_PRODUT",oMdlVisPrd:GetValue("AAU_PRODUT")}}) .AND. !Empty(oMdlProPrd:GetValue("ADZ_PRODUT")) )
								
								If lSeek				
													
									If cNewItem <> oMdlProPrd:GetValue("ADZ_ITEM")
										nTotal := oMdlVisPrd:GetValue("AAU_VLRTOT") + oMdlProPrd:GetValue("ADZ_TOTAL")					
										oMdlProPrd:SetValue( "ADZ_LEGEN" , "BR_AZUL" )
										oMdlProPrd:SetValue( "ADZ_CODVIS", oMdlVisPrd:GetValue("AAU_CODVIS") )
										oMdlProPrd:SetValue( "ADZ_PRCVEN", nTotal )
										oMdlProPrd:SetValue( "ADZ_TOTAL" , nTotal )
									EndIf
																		
								Else
								
									cItemPrd := oMdlVisPrd:GetValue("AAU_ITEM")
					
									If (!Empty(oMdlProPrd:GetValue("ADZ_PRODUT")))
										nLinha := oMdlProPrd:AddLine()
									EndIf
								
									nLinha := oMdlProPrd:GetLine()
								
									If nLinha > 0
										oMdlProPrd:GoLine(nLinha)
										cNewItem := Soma1(oMdlProPrd:GetValue("ADZ_ITEM",(nLinha-1)))
										
										oMdlProPrd:SetValue("ADZ_LEGEN","BR_AZUL")
										oMdlProPrd:SetValue("ADZ_ITEM",cNewItem)
										oMdlProPrd:SetValue("ADZ_PRODUT",oMdlVisPrd:GetValue("AAU_PRODUT"))
										oMdlProPrd:SetValue("ADZ_DESCRI",oMdlVisPrd:GetValue("AAU_DESCRI"))
										oMdlProPrd:SetValue("ADZ_UM",oMdlVisPrd:GetValue("AAU_UM"))
										oMdlProPrd:SetValue("ADZ_MOEDA",oMdlVisPrd:GetValue("AAU_MOEDA"))
										oMdlProPrd:SetValue("ADZ_QTDVEN",oMdlVisPrd:GetValue("AAU_QTDVEN"))
										oMdlProPrd:SetValue("ADZ_PRCVEN",oMdlVisPrd:GetValue("AAU_PRCVEN"))
										oMdlProPrd:SetValue("ADZ_PRCTAB",oMdlVisPrd:GetValue("AAU_PRCTAB"))
										oMdlProPrd:SetValue("ADZ_TOTAL",oMdlVisPrd:GetValue("AAU_VLRTOT"))
										oMdlProPrd:SetValue("ADZ_TPPROD",oMdlVisPrd:GetValue("AAU_TPPROD"))
										oMdlProPrd:SetValue("ADZ_FOLDER",oMdlVisPrd:GetValue("AAU_FOLDER"))
										oMdlProPrd:SetValue("ADZ_CODVIS",oMdlVisPrd:GetValue("AAU_CODVIS"))
										oMdlProPrd:SetValue("ADZ_LOCAL",oMdlVisPrd:GetValue("AAU_LOCAL"))										
										oMdlProPrd:SetValue("ADZ_ITEMVI",oMdlVisPrd:GetValue("AAU_ITEM"))																	
									EndIf									
								 
								EndIf
								
								Exit
																
							EndIf						
								
						Next nX
					
					EndIf
					
					oMdlProPrd:GoLine(1)
					oMdlProAce:GoLine(1)
					oView:Refresh()				
					
				EndIf
				
			Else
			
				// "Deseja adicionar o produto "#XXXXXX#" na proposta comercial?"####"Aten็ใo"
				If MsgYesNo(STR0022+Alltrim(oMdlVisPrd:GetValue("AAU_PRODUT"))+" - "+Alltrim(oMdlVisPrd:GetValue("AAU_DESCRI"))+STR0023,STR0024)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Item Produto Vistoria. ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					cItemPrd := oMdlVisPrd:GetValue("AAU_ITEM")
					
					If (!Empty(oMdlProPrd:GetValue("ADZ_PRODUT")))
						nLinha := oMdlProPrd:AddLine()
					EndIf
					
					nLinha := oMdlProPrd:GetLine()
					
					If nLinha > 0
						oMdlProPrd:GoLine(nLinha)
						cNewItem := Soma1(oMdlProPrd:GetValue("ADZ_ITEM",(nLinha-1)))
						
						oMdlProPrd:SetValue("ADZ_LEGEN","BR_AZUL")
						oMdlProPrd:SetValue("ADZ_ITEM",cNewItem)
						oMdlProPrd:SetValue("ADZ_PRODUT",oMdlVisPrd:GetValue("AAU_PRODUT"))
						oMdlProPrd:SetValue("ADZ_DESCRI",oMdlVisPrd:GetValue("AAU_DESCRI"))
						oMdlProPrd:SetValue("ADZ_UM",oMdlVisPrd:GetValue("AAU_UM"))
						oMdlProPrd:SetValue("ADZ_MOEDA",oMdlVisPrd:GetValue("AAU_MOEDA"))
						oMdlProPrd:SetValue("ADZ_QTDVEN",oMdlVisPrd:GetValue("AAU_QTDVEN"))
						oMdlProPrd:SetValue("ADZ_PRCVEN",oMdlVisPrd:GetValue("AAU_PRCVEN"))
						oMdlProPrd:SetValue("ADZ_PRCTAB",oMdlVisPrd:GetValue("AAU_PRCTAB"))
						oMdlProPrd:SetValue("ADZ_TOTAL",oMdlVisPrd:GetValue("AAU_VLRTOT"))
						oMdlProPrd:SetValue("ADZ_TPPROD",oMdlVisPrd:GetValue("AAU_TPPROD"))
						oMdlProPrd:SetValue("ADZ_FOLDER",oMdlVisPrd:GetValue("AAU_FOLDER"))
						oMdlProPrd:SetValue("ADZ_CODVIS",oMdlVisPrd:GetValue("AAU_CODVIS"))
						oMdlProPrd:SetValue("ADZ_LOCAL",oMdlVisPrd:GetValue("AAU_LOCAL"))										
						oMdlProPrd:SetValue("ADZ_ITEMVI",oMdlVisPrd:GetValue("AAU_ITEM"))
						aAcessorio := At280RAce(cItemPrd,oMdlVisAce)
						
						If Len(aAcessorio) > 0
							//"Este produto possui acessorio(s) deseja adiciona-lo(s) na proposta comercial?"###"Aten็ใo"
							If MsgYesNo(STR0025,STR0024)
								//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณ Item Pai -  Produto (Proposta). ณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
								cItemPai := oMdlProPrd:GetValue("ADZ_ITEM")
								
								For nX := 1 To Len(aAcessorio)
									
									If (!Empty(oMdlProAce:GetValue("ADZ_PRODUT")))
										nLinha := oMdlProAce:AddLine()
									EndIf
									
									nLinha := oMdlProAce:GetLine()
									
									If nLinha > 0
										oMdlProAce:GoLine(nLinha)
										cNewItem := Soma1(oMdlProAce:GetValue("ADZ_ITEM",(nLinha-1)))
										
										oMdlProAce:SetValue("ADZ_LEGEN","BR_AZUL")
										oMdlProAce:SetValue("ADZ_ITEM",cNewItem)
										oMdlProAce:SetValue("ADZ_PRODUT",aAcessorio[nX][1])
										oMdlProAce:SetValue("ADZ_DESCRI",aAcessorio[nX][2])
										oMdlProAce:SetValue("ADZ_UM",aAcessorio[nX][3])
										oMdlProAce:SetValue("ADZ_MOEDA",aAcessorio[nX][4])
										oMdlProAce:SetValue("ADZ_QTDVEN",aAcessorio[nX][5])
										oMdlProAce:SetValue("ADZ_PRCVEN",aAcessorio[nX][6])
										oMdlProAce:SetValue("ADZ_PRCTAB",aAcessorio[nX][7])
										oMdlProAce:SetValue("ADZ_TOTAL",aAcessorio[nX][8])
										oMdlProAce:SetValue("ADZ_TPPROD",aAcessorio[nX][9])
										oMdlProAce:SetValue("ADZ_ITPAI",cItemPai)
										oMdlProAce:SetValue("ADZ_FOLDER",aAcessorio[nX][10])										
										oMdlProPrd:SetValue("ADZ_LOCAL",aAcessorio[nX][11])										
										oMdlProPrd:SetValue("ADZ_CODVIS",aAcessorio[nX][12])						
										oMdlProPrd:SetValue("ADZ_ITEMVI",aAcessorio[nX][13])
									EndIf
									
								Next nX
								
							EndIf
						EndIf
					EndIf
					oMdlProPrd:GoLine(1)
					oMdlProAce:GoLine(1)
					oView:Refresh()
				EndIf
				
			EndIf
			
		Else
			// "Nใo hแ produto para ser adicionado na proposta!"###"Aten็ใo"
			MsgAlert(STR0026,STR0024)
		EndIf
		
	Else
		// "Este produto jแ estแ adicionado na proposta comercial!"###"Aten็ใo"
		MsgAlert(STR0041,STR0024)
	EndIf
	
Else
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder Acessorios. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	lSeek := ( oMdlProAce:SeekLine({{"ADZ_ITEM",oMdlVisAce:GetValue("AAU_ITPROP")}}) .AND. !Empty(oMdlProAce:GetValue("ADZ_PRODUT")) )
	
	If !lSeek
		
		If !Empty(oMdlVisAce:GetValue("AAU_PRODUT"))
			// "Deseja adicionar o acess๓rio "XXXXX" na proposta comercial?"###"Aten็ใo"
			If MsgYesNo(STR0027+Alltrim(oMdlVisAce:GetValue("AAU_PRODUT"))+" - "+Alltrim(oMdlVisAce:GetValue("AAU_DESCRI"))+STR0028,STR0024)
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Item produto Vistoria Tecnica.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cItemPai := oMdlVisAce:GetValue("AAU_ITEM")
				
				If (!Empty(oMdlProAce:GetValue("ADZ_PRODUT")))
					nLinha := oMdlProAce:AddLine()
				EndIf
				
				nLinha := oMdlProAce:GetLine()
				
				If nLinha > 0
					oMdlProAce:GoLine(nLinha)
					cNewItem := Soma1(oMdlProAce:GetValue("ADZ_ITEM",(nLinha-1)))
					
					oMdlProAce:SetValue("ADZ_LEGEN","BR_AZUL")
					oMdlProAce:SetValue("ADZ_ITEM",cNewItem)
					oMdlProAce:SetValue("ADZ_PRODUT",oMdlVisAce:GetValue("AAU_PRODUT"))
					oMdlProAce:SetValue("ADZ_DESCRI",oMdlVisAce:GetValue("AAU_DESCRI"))
					oMdlProAce:SetValue("ADZ_UM",oMdlVisAce:GetValue("AAU_UM"))
					oMdlProAce:SetValue("ADZ_MOEDA",oMdlVisAce:GetValue("AAU_MOEDA"))
					oMdlProAce:SetValue("ADZ_QTDVEN",oMdlVisAce:GetValue("AAU_QTDVEN"))
					oMdlProAce:SetValue("ADZ_PRCVEN",oMdlVisAce:GetValue("AAU_PRCVEN"))
					oMdlProAce:SetValue("ADZ_PRCTAB",oMdlVisAce:GetValue("AAU_PRCTAB"))
					oMdlProAce:SetValue("ADZ_TOTAL",oMdlVisAce:GetValue("AAU_VLRTOT"))
					oMdlProAce:SetValue("ADZ_TPPROD",oMdlVisAce:GetValue("AAU_TPPROD"))
					oMdlProAce:SetValue("ADZ_FOLDER",oMdlVisAce:GetValue("AAU_FOLDER"))
					oMdlProAce:SetValue("ADZ_LOCAL",oMdlVisAce:GetValue("AAU_LOCAL")) 
					oMdlProAce:SetValue("ADZ_CODVIS",oMdlVisAce:GetValue("AAU_CODVIS"))
					oMdlProAce:SetValue("ADZ_ITEMVI",oMdlVisAce:GetValue("AAU_ITEM"))
			
				EndIf
				oMdlProAce:GoLine(1)
				oView:Refresh()
			EndIf
		Else
			// "Nใo hแ acess๓rio para ser adicionado na proposta!"###"Aten็ใo"
			MsgAlert(STR0029,STR0024)
		EndIf
	Else
		// "Este acess๓rio jแ estแ adicionado na proposta comercial!"###"Aten็ใo"
		MsgAlert(STR0042,STR0024)
	EndIf
	
EndIf

RestArea(aArea)

Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt280AdAll บAutor  ณVendas CRM          บ Data ณ 26/03/12    บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBotao adiciona todos os itens ">>".						   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro					                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto de interface.	 						       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA280							                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At280AdAll(oView)

Local oMdl 	 		:= FWModelActive() 	 						// Retorna o model ativo.
Local aFolder 		:= oView:GetFolderActive("FOLDER_VIS",2)	// Retorna a pasta selecionada.
Local oMdlVisPrd	:= oMdl:GetModel("VISPRDDET")              	// Modelo de dados vistoria - produtos.
Local oMdlVisAce	:= oMdl:GetModel("VISACEDET")				// Modelo de dados vistoria - acessorios.
Local oMdlProPrd	:= oMdl:GetModel("PRPPRDDET")				// Modelo de dados proposta - produtos.
Local oMdlProAce	:= oMdl:GetModel("PRPACEDET")				// Modelo de dados proposta - acessorios.
Local nX 			:= 0 										// Incremento utilizado no laco For.
Local nI 			:= 0 										// Incremento utilizado no laco For.
Local cItemPai 		:= 0                                        // Item Pai.
Local lSeek			:= .F. 										// Procura linha.

Local aVistoria := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Folder Produtos. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aFolder[1] == 1
	
	If !Empty(oMdlVisPrd:GetValue("AAU_PRODUT"))
		
		// "Deseja adicionar todos os produtos da vistoria t้cnica na proposta comercial?"####"Aten็ใo"
		If MsgYesNo(STR0030,STR0024)
		
			For nX := 1 To oMdlVisPrd:Length()	
																	
				oMdlVisPrd:GoLine(nX)
				lSeek := ( oMdlProPrd:SeekLine({{"ADZ_ITEM",oMdlVisPrd:GetValue("AAU_ITPROP")}}) .AND. !Empty(oMdlProPrd:GetValue("ADZ_PRODUT")) )
				
				If !lSeek
					
					If A600VldPOrc( oMdlVisPrd:GetValue("AAU_PRODUT"), oMdlVisPrd:GetValue("AAU_CODVIS") )									
																						
						If oMdlProPrd:SeekLine( { { "ADZ_PRODUT", oMdlVisPrd:GetValue("AAU_PRODUT") }})				
																		
							nTotal := oMdlVisPrd:GetValue("AAU_VLRTOT") + oMdlProPrd:GetValue("ADZ_TOTAL")
							
							oMdlProPrd:SetValue( "ADZ_LEGEN" , "BR_AZUL" )
							oMdlProPrd:SetValue( "ADZ_CODVIS", oMdlVisPrd:GetValue("AAU_CODVIS") )
							oMdlProPrd:SetValue( "ADZ_PRCVEN", nTotal )
							oMdlProPrd:SetValue( "ADZ_TOTAL" , nTotal )							
																			
						Else 
						
							cItemPrd := oMdlVisPrd:GetValue("AAU_ITEM")
						
							If (nX == 1 .AND. !Empty(oMdlProPrd:GetValue("ADZ_PRODUT")) ) .OR. ( nX > 1 .AND. !Empty(oMdlProPrd:GetValue("ADZ_PRODUT")))
								nLinha := oMdlProPrd:AddLine()
							EndIf
						
							nLinha := oMdlProPrd:GetLine()
						
							If nLinha > 0
							
								oMdlProPrd:GoLine(nLinha)
								cNewItem := Soma1(oMdlProPrd:GetValue("ADZ_ITEM",(nLinha-1)))
								
								oMdlProPrd:SetValue("ADZ_LEGEN","BR_AZUL")
								oMdlProPrd:SetValue("ADZ_ITEM",cNewItem)
								oMdlProPrd:SetValue("ADZ_PRODUT",oMdlVisPrd:GetValue("AAU_PRODUT"))
								oMdlProPrd:SetValue("ADZ_DESCRI",oMdlVisPrd:GetValue("AAU_DESCRI"))
								oMdlProPrd:SetValue("ADZ_UM",oMdlVisPrd:GetValue("AAU_UM"))
								oMdlProPrd:SetValue("ADZ_MOEDA",oMdlVisPrd:GetValue("AAU_MOEDA"))
								oMdlProPrd:SetValue("ADZ_QTDVEN",oMdlVisPrd:GetValue("AAU_QTDVEN"))
								oMdlProPrd:SetValue("ADZ_PRCVEN",oMdlVisPrd:GetValue("AAU_PRCVEN"))
								oMdlProPrd:SetValue("ADZ_PRCTAB",oMdlVisPrd:GetValue("AAU_PRCTAB"))
								oMdlProPrd:SetValue("ADZ_TOTAL",oMdlVisPrd:GetValue("AAU_VLRTOT"))
								oMdlProPrd:SetValue("ADZ_TPPROD",oMdlVisPrd:GetValue("AAU_TPPROD"))
								oMdlProPrd:SetValue("ADZ_FOLDER",oMdlVisPrd:GetValue("AAU_FOLDER"))
								oMdlProPrd:SetValue("ADZ_CODVIS",oMdlVisPrd:GetValue("AAU_CODVIS"))								
								oMdlProPrd:SetValue("ADZ_LOCAL",oMdlVisPrd:GetValue("AAU_LOCAL"))			
								oMdlProPrd:SetValue("ADZ_ITEMVI",oMdlVisPrd:GetValue("AAU_ITEM"))																
							EndIf
						
						EndIf						
						
						If	aScan( aVistoria, { |x| x == oMdlVisPrd:GetValue("AAU_CODVIS") } ) == 0
							aAdd( aVistoria, oMdlVisPrd:GetValue("AAU_CODVIS") )
						EndIf 					
					
					Else
					
						cItemPrd := oMdlVisPrd:GetValue("AAU_ITEM")
						
						If (nX == 1 .AND. !Empty(oMdlProPrd:GetValue("ADZ_PRODUT")) ) .OR. ( nX > 1 .AND. !Empty(oMdlProPrd:GetValue("ADZ_PRODUT")))
							nLinha := oMdlProPrd:AddLine()
						EndIf
						
						nLinha := oMdlProPrd:GetLine()
						
						If nLinha > 0
							oMdlProPrd:GoLine(nLinha)
							cNewItem := Soma1(oMdlProPrd:GetValue("ADZ_ITEM",(nLinha-1)))
							
							oMdlProPrd:SetValue("ADZ_LEGEN","BR_AZUL")
							oMdlProPrd:SetValue("ADZ_ITEM",cNewItem)
							oMdlProPrd:SetValue("ADZ_PRODUT",oMdlVisPrd:GetValue("AAU_PRODUT"))
							oMdlProPrd:SetValue("ADZ_DESCRI",oMdlVisPrd:GetValue("AAU_DESCRI"))
							oMdlProPrd:SetValue("ADZ_UM",oMdlVisPrd:GetValue("AAU_UM"))
							oMdlProPrd:SetValue("ADZ_MOEDA",oMdlVisPrd:GetValue("AAU_MOEDA"))
							oMdlProPrd:SetValue("ADZ_QTDVEN",oMdlVisPrd:GetValue("AAU_QTDVEN"))
							oMdlProPrd:SetValue("ADZ_PRCVEN",oMdlVisPrd:GetValue("AAU_PRCVEN"))
							oMdlProPrd:SetValue("ADZ_PRCTAB",oMdlVisPrd:GetValue("AAU_PRCTAB"))
							oMdlProPrd:SetValue("ADZ_TOTAL",oMdlVisPrd:GetValue("AAU_VLRTOT"))
							oMdlProPrd:SetValue("ADZ_TPPROD",oMdlVisPrd:GetValue("AAU_TPPROD"))
							oMdlProPrd:SetValue("ADZ_FOLDER",oMdlVisPrd:GetValue("AAU_FOLDER"))
							oMdlProPrd:SetValue("ADZ_CODVIS",oMdlVisPrd:GetValue("AAU_CODVIS"))							
							oMdlProPrd:SetValue("ADZ_LOCAL",oMdlVisPrd:GetValue("AAU_LOCAL"))							
							oMdlProPrd:SetValue("ADZ_ITEMVI",oMdlVisPrd:GetValue("AAU_ITEM"))							
							
							aAcessorio := At280RAce(cItemPrd,oMdlVisAce)
							
							If Len(aAcessorio) > 0
								// "Existem acessorios para o produto "XXXXXXXX"###Deseja adicionar na proposta comercial?"###"Aten็ใo"
								If MsgYesNo(STR0031+Alltrim(oMdlVisPrd:GetValue("AAU_PRODUT"))+" - "+Alltrim(oMdlVisPrd:GetValue("AAU_DESCRI"))+"."+CRLF+STR0032,STR0024)
									//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
									//ณ Item Pai -  Produto (Proposta). ณ
									//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
									cItemPai := oMdlProPrd:GetValue("ADZ_ITEM")
									
									For nI := 1 To Len(aAcessorio)
										
										If (nI == 1 .AND. !Empty(oMdlProAce:GetValue("ADZ_PRODUT")) ) .OR. ( nI > 1 .AND. !Empty(oMdlProAce:GetValue("ADZ_PRODUT")))
											nLinha := oMdlProAce:AddLine()
										EndIf
										
										nLinha := oMdlProAce:GetLine()
										
										If nLinha > 0
											oMdlProAce:GoLine(nLinha)
											cNewItem := Soma1(oMdlProAce:GetValue("ADZ_ITEM",(nLinha-1)))
											
											oMdlProAce:SetValue("ADZ_LEGEN","BR_AZUL")
											oMdlProAce:SetValue("ADZ_ITEM",cNewItem)
											oMdlProAce:SetValue("ADZ_PRODUT",aAcessorio[nI][1])
											oMdlProAce:SetValue("ADZ_DESCRI",aAcessorio[nI][2])
											oMdlProAce:SetValue("ADZ_UM",aAcessorio[nI][3])
											oMdlProAce:SetValue("ADZ_MOEDA",aAcessorio[nI][4])
											oMdlProAce:SetValue("ADZ_QTDVEN",aAcessorio[nI][5])
											oMdlProAce:SetValue("ADZ_PRCVEN",aAcessorio[nI][6])
											oMdlProAce:SetValue("ADZ_PRCTAB",aAcessorio[nI][7])
											oMdlProAce:SetValue("ADZ_TOTAL",aAcessorio[nI][8])
											oMdlProAce:SetValue("ADZ_TPPROD",aAcessorio[nI][9])
											oMdlProAce:SetValue("ADZ_ITPAI",cItemPai)
											oMdlProAce:SetValue("ADZ_FOLDER",aAcessorio[nI][10])
											oMdlProAce:SetValue("ADZ_CODVIS",aAcessorio[nX][12])											
											oMdlProAce:SetValue("ADZ_LOCAL",aAcessorio[nI][11])																																	
											oMdlProPrd:SetValue("ADZ_ITEMVI",aAcessorio[nX][13])								
										EndIf
										
									Next nI
									oMdlProAce:GoLine(1)
								EndIf
							EndIf
						EndIf
					EndIf						
				EndIf
			Next nX
			
			aArea := GetArea()
			
			If Len(aVistoria) > 0			
				For nI:=1 To Len(aVistoria)  
					A600CombOrc( .F., aVistoria[nI], Nil, oMdlPro )
				Next nI
			EndIf
			
			RestArea(aArea)			
			
			oMdlVisPrd:GoLine(1)
			oMdlProPrd:GoLine(1)
			oView:Refresh()  
			
		EndIf
	Else
		// "Nใo hแ produto para ser adicionado na proposta!"###"Aten็ใo"
		MsgAlert(STR0026,STR0024)
	EndIf
	
Else
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder Acessorios. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	
	If !Empty(oMdlVisAce:GetValue("AAU_PRODUT"))
		// "Deseja adicionar todos os acessorios da vistoria t้cnica na proposta comercial?"###"Aten็ใo"
		If MsgYesNo(STR0033,STR0034)
			
			For nX := 1 To oMdlVisAce:Length()
				
				oMdlVisAce:GoLine(nX)
				lSeek := ( oMdlProAce:SeekLine({{"ADZ_ITEM",oMdlVisAce:GetValue("AAU_ITPROP")}}) .AND. !Empty(oMdlProAce:GetValue("ADZ_PRODUT")) )
				
				If !lSeek
					
					If (nX == 1 .AND. !Empty(oMdlProAce:GetValue("ADZ_PRODUT")) ) .OR. ( nX > 1 .AND. !Empty(oMdlProAce:GetValue("ADZ_PRODUT")))
						nLinha := oMdlProAce:AddLine()
					EndIf
					
					nLinha := oMdlProAce:GetLine()
					
					If nLinha > 0
						oMdlProAce:GoLine(nLinha)
						cNewItem := Soma1(oMdlProAce:GetValue("ADZ_ITEM",(nLinha-1)))
						
						oMdlProAce:SetValue("ADZ_LEGEN","BR_AZUL")
						oMdlProAce:SetValue("ADZ_ITEM",cNewItem)
						oMdlProAce:SetValue("ADZ_PRODUT",oMdlVisAce:GetValue("AAU_PRODUT"))
						oMdlProAce:SetValue("ADZ_DESCRI",oMdlVisAce:GetValue("AAU_DESCRI"))
						oMdlProAce:SetValue("ADZ_UM",oMdlVisAce:GetValue("AAU_UM"))
						oMdlProAce:SetValue("ADZ_MOEDA",oMdlVisAce:GetValue("AAU_MOEDA"))
						oMdlProAce:SetValue("ADZ_QTDVEN",oMdlVisAce:GetValue("AAU_QTDVEN"))
						oMdlProAce:SetValue("ADZ_PRCVEN",oMdlVisAce:GetValue("AAU_PRCVEN"))
						oMdlProAce:SetValue("ADZ_PRCTAB",oMdlVisAce:GetValue("AAU_PRCTAB"))
						oMdlProAce:SetValue("ADZ_TOTAL",oMdlVisAce:GetValue("AAU_VLRTOT"))
						oMdlProAce:SetValue("ADZ_TPPROD",oMdlVisAce:GetValue("AAU_TPPROD"))
						oMdlProAce:SetValue("ADZ_FOLDER",oMdlVisAce:GetValue("AAU_FOLDER"))
						oMdlProAce:SetValue("ADZ_LOCAL",oMdlVisAce:GetValue("AAU_LOCAL")) 				
						oMdlProAce:SetValue("ADZ_CODVIS",oMdlVisAce:GetValue("AAU_CODVIS"))					
						oMdlProAce:SetValue("ADZ_ITEMVI",oMdlVisAce:GetValue("AAU_ITEM"))
						
					EndIf  
					
				EndIf
			Next nX
			oMdlProAce:GoLine(1)
			oView:Refresh()
		EndIf
	Else
		// "Nใo hแ acess๓rio para ser adicionado na proposta!"###"Aten็ใo"
		MsgAlert(STR0029,STR0024)
	EndIf
	
EndIf

Return( .T. )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt280AdQnt    บAutor  ณVendas CRM          บ Data ณ 26/03/12    บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBotao Substitui item "Subst."	       				              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro					                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto de interface.		 						      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA280							                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At280AdQnt(oView)

Local oMdl 	 		:= FWModelActive() 	 						// Retorna o model ativo.
Local aFolder 		:= oView:GetFolderActive("FOLDER_VIS",2) 	// Retorna a pasta selecionada.
Local oMdlVisPrd	:= oMdl:GetModel("VISPRDDET")   			// Modelo de dados vistoria - produtos.
Local oMdlVisAce	:= oMdl:GetModel("VISACEDET")   			// Modelo de dados vistoria - acessorios.
Local oMdlProPrd	:= oMdl:GetModel("PRPPRDDET")  				// Modelo de dados proposta - produtos.
Local oMdlProAce	:= oMdl:GetModel("PRPACEDET")  				// Modelo de dados proposta - acessorios.
Local cItemPrd 		:= "" 										// Item do produto.
Local aAcessorio 	:= {}										// Array de acessorios.
Local nLinha		:= 0  										// Linha atual.
Local nX 			:= 0 									    // Incremento utilizado no laco For.
Local lSeek			:= .F.										// Procura linha.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ	ADZ -> Proposta
//ณ Folder Produtos. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  AAU -> Vistoria
If aFolder[1] == 1

	lSeek := ( oMdlProPrd:SeekLine({{"ADZ_PRODUT",oMdlVisPrd:GetValue("AAU_PRODUT")},{"ADZ_ITEM",oMdlVisPrd:GetValue("AAU_ITPROP")}}) .AND. !Empty(oMdlProPrd:GetValue("ADZ_PRODUT"));
	 .AND. ( oMdlVisPrd:GetValue("AAU_QTDVEN") <> oMdlProPrd:GetValue("ADZ_QTDVEN") .OR. oMdlVisPrd:GetValue("AAU_PRCVEN") <> oMdlProPrd:GetValue("ADZ_PRCVEN") ) )

	If lSeek

		If !Empty(oMdlVisPrd:GetValue("AAU_PRODUT"))

			// "Deseja substituir o produto "#XXXXXX#" na proposta comercial?"####"Aten็ใo"
			If MsgYesNo(STR0044+Alltrim(oMdlVisPrd:GetValue("AAU_PRODUT"))+" - "+Alltrim(oMdlVisPrd:GetValue("AAU_DESCRI"))+STR0023,STR0024)				
				
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Item Produto Vistoria. ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				cItemPrd := oMdlVisPrd:GetValue("AAU_ITEM")

				If (!Empty(oMdlProPrd:GetValue("ADZ_PRODUT")))
					
					nLinha := oMdlProPrd:GetLine()
					
					If nLinha > 0  
						oMdlProPrd:GoLine(nLinha)
						oMdlProPrd:SetValue("ADZ_LEGEN","BR_AZUL")
						oMdlProPrd:SetValue("ADZ_QTDVEN",oMdlVisPrd:GetValue("AAU_QTDVEN"))
						oMdlProPrd:SetValue("ADZ_PRCVEN",oMdlVisPrd:GetValue("AAU_PRCVEN"))
						oMdlProPrd:SetValue("ADZ_TOTAL",oMdlVisPrd:GetValue("AAU_VLRTOT"))
						oMdlProPrd:SetValue("ADZ_FOLDER",oMdlVisPrd:GetValue("AAU_FOLDER"))					
						oMdlProPrd:SetValue("ADZ_LOCAL",oMdlVisPrd:GetValue("AAU_LOCAL"))					
						oMdlProPrd:SetValue("ADZ_CODVIS",oMdlVisPrd:GetValue("AAU_CODVIS"))										
						oMdlProPrd:SetValue("ADZ_ITEMVI",oMdlVisPrd:GetValue("AAU_ITEM"))					
										
						aAcessorio := At280RAce(cItemPrd,oMdlVisAce)
				
						If Len(aAcessorio) > 0
							//"Este produto possui acessorio(s) deseja adiciona-lo(s) na proposta comercial?"###"Aten็ใo"
							If MsgYesNo(STR0025,STR0024)
								//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
								//ณ Item Pai -  Produto (Proposta). ณ
								//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
								cItemPai := oMdlProPrd:GetValue("ADZ_ITEM")
							
								For nX := 1 To Len(aAcessorio)
									If (!Empty(oMdlProAce:GetValue("ADZ_PRODUT")))				
										nLinha := oMdlProAce:GetLine()
										If nLinha > 0
											oMdlProAce:GoLine(nLinha)
											oMdlProAce:SetValue("ADZ_LEGEN","BR_AZUL")
											oMdlProAce:SetValue("ADZ_QTDVEN",aAcessorio[nX][5])
											oMdlProAce:SetValue("ADZ_TOTAL",aAcessorio[nX][8])
											oMdlProAce:SetValue("ADZ_FOLDER",aAcessorio[nX][10])												
											oMdlProAce:SetValue("ADZ_LOCAL",aAcessorio[nX][11])																								
											oMdlProAce:SetValue("ADZ_CODVIS",aAcessorio[nX][12])																								
											oMdlProAce:SetValue("ADZ_ITEMVI",aAcessorio[nX][13])										
										EndIf
									EndIf
								Next nX
							EndIf
						EndIf												
					EndIf		
						
					//Substitui o item do or็amento de servi็os
					If A600VldPOrc(oMdlVisPrd:GetValue("AAU_PRODUT"), oMdlVisPrd:GetValue("AAU_CODVIS"))
						If MsgYesNo(STR0050,STR0024) // "Deseja realmente substituir todo o or็amento de servi็os ?"						
							
							A600CombOrc( .T., oMdlVisPrd:GetValue("AAU_CODVIS"), Nil, oMdlPro )
							
							For nX := 1 To oMdlVisPrd:Length()	
																	
								oMdlVisPrd:GoLine(nX)
					
								If A600VldPOrc( oMdlVisPrd:GetValue("AAU_PRODUT"), oMdlVisPrd:GetValue("AAU_CODVIS") )									
																						
									If oMdlProPrd:SeekLine( { { "ADZ_PRODUT", oMdlVisPrd:GetValue("AAU_PRODUT") }})
							
										oMdlProPrd:SetValue( "ADZ_LEGEN" , "BR_AZUL" )
										oMdlProPrd:SetValue( "ADZ_CODVIS", oMdlVisPrd:GetValue("AAU_CODVIS") )
										oMdlProPrd:SetValue( "ADZ_PRCVEN", oMdlVisPrd:GetValue("AAU_VLRTOT") )
										oMdlProPrd:SetValue( "ADZ_TOTAL" , oMdlVisPrd:GetValue("AAU_VLRTOT") )							
																			
									Else 
						
										cItemPrd := oMdlVisPrd:GetValue("AAU_ITEM")
						
										If (nX == 1 .AND. !Empty(oMdlProPrd:GetValue("ADZ_PRODUT")) ) .OR. ( nX > 1 .AND. !Empty(oMdlProPrd:GetValue("ADZ_PRODUT")))
											nLinha := oMdlProPrd:AddLine()
										EndIf
						
										nLinha := oMdlProPrd:GetLine()
						
										If nLinha > 0
							
											oMdlProPrd:GoLine(nLinha)
											cNewItem := Soma1(oMdlProPrd:GetValue("ADZ_ITEM",(nLinha-1)))
								
											oMdlProPrd:SetValue("ADZ_LEGEN","BR_AZUL")
											oMdlProPrd:SetValue("ADZ_ITEM",cNewItem)
											oMdlProPrd:SetValue("ADZ_PRODUT",oMdlVisPrd:GetValue("AAU_PRODUT"))
											oMdlProPrd:SetValue("ADZ_DESCRI",oMdlVisPrd:GetValue("AAU_DESCRI"))
											oMdlProPrd:SetValue("ADZ_UM",oMdlVisPrd:GetValue("AAU_UM"))
											oMdlProPrd:SetValue("ADZ_MOEDA",oMdlVisPrd:GetValue("AAU_MOEDA"))
											oMdlProPrd:SetValue("ADZ_QTDVEN",oMdlVisPrd:GetValue("AAU_QTDVEN"))
											oMdlProPrd:SetValue("ADZ_PRCVEN",oMdlVisPrd:GetValue("AAU_PRCVEN"))
											oMdlProPrd:SetValue("ADZ_PRCTAB",oMdlVisPrd:GetValue("AAU_PRCTAB"))
											oMdlProPrd:SetValue("ADZ_TOTAL",oMdlVisPrd:GetValue("AAU_VLRTOT"))
											oMdlProPrd:SetValue("ADZ_TPPROD",oMdlVisPrd:GetValue("AAU_TPPROD"))
											oMdlProPrd:SetValue("ADZ_FOLDER",oMdlVisPrd:GetValue("AAU_FOLDER"))
											oMdlProPrd:SetValue("ADZ_CODVIS",oMdlVisPrd:GetValue("AAU_CODVIS"))											
											oMdlProPrd:SetValue("ADZ_LOCAL",oMdlVisPrd:GetValue("AAU_LOCAL"))											
											oMdlProPrd:SetValue("ADZ_ITEMVI",oMdlVisPrd:GetValue("AAU_ITEM"))											
											
										EndIf
										
									EndIf
						
								EndIf					
								
						 	Next nX
						 	
						EndIf
						 	
					EndIf
				
				EndIf				
				
				oMdlProPrd:GoLine(1)
				oMdlProAce:GoLine(1)
				oView:Refresh()
				
			EndIf
			
		Else
			// "Nใo hแ produto para ser substituido na proposta!"###"Aten็ใo"
			MsgAlert(STR0048,STR0024)
		EndIf
	Else
		// "Este produto nใo pode ser substituido na proposta comercial!"###"Aten็ใo"
		MsgAlert(STR0045,STR0024)
	EndIf
	
Else
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Folder Acessorios. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	lSeek := ( oMdlProAce:SeekLine({{"ADZ_PRODUT",oMdlVisAce:GetValue("AAU_PRODUT")}}) .AND. !Empty(oMdlProAce:GetValue("ADZ_PRODUT"));
	 .AND. oMdlVisAce:GetValue("AAU_QTDVEN") <> oMdlProAce:GetValue("ADZ_QTDVEN") .AND. oMdlVisAce:GetValue("AAU_ITPROP") == oMdlProAce:GetValue("ADZ_ITEM") )
	 
	If lSeek
		If !Empty(oMdlVisAce:GetValue("AAU_PRODUT"))
			// "Deseja Substituir o acess๓rio "XXXXX" na proposta comercial?"###"Aten็ใo"
			If MsgYesNo(STR0047+Alltrim(oMdlVisAce:GetValue("AAU_PRODUT"))+" - "+Alltrim(oMdlVisAce:GetValue("AAU_DESCRI"))+STR0028,STR0024)
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Item produto Vistoria Tecnica.ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
				cItemPai := oMdlVisAce:GetValue("AAU_ITEM")
				
				If (!Empty(oMdlProAce:GetValue("ADZ_PRODUT")))			
				nLinha := oMdlProAce:GetLine()
				    If nLinha > 0
						oMdlProAce:GoLine(nLinha)
						oMdlProAce:SetValue("ADZ_LEGEN","BR_AZUL")
						oMdlProAce:SetValue("ADZ_QTDVEN",oMdlVisAce:GetValue("AAU_QTDVEN"))
						oMdlProAce:SetValue("ADZ_TOTAL",oMdlVisAce:GetValue("AAU_VLRTOT"))
						oMdlProAce:SetValue("ADZ_FOLDER",oMdlVisAce:GetValue("AAU_FOLDER"))
						oMdlProAce:SetValue("ADZ_LOCAL",oMdlVisAce:GetValue("AAU_LOCAL"))												
						oMdlProAce:SetValue("ADZ_CODVIS",oMdlVisAce:GetValue("AAU_CODVIS"))						
						oMdlProAce:SetValue("ADZ_ITEMVI",oMdlVisAce:GetValue("AAU_ITEM"))						
					EndIf
				EndIf
				lSubst := .T.
				oMdlProAce:GoLine(1)
				oView:Refresh()
			EndIf
		Else
			// "Nใo hแ acess๓rio para ser substituido na proposta!"###"Aten็ใo"
			MsgAlert(STR0049,STR0024)
		EndIf
	Else
		// "Este acess๓rio nใo pode ser substituido na proposta comercial!"###"Aten็ใo"
		MsgAlert(STR0046,STR0024)
	EndIf
	
EndIf
 
Return( .T. ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt280RAce  บAutor  ณVendas CRM          บ Data ณ 26/03/12    บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os acessorios do produto contido no grid.		       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro					                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpC1 - Item do produto		 						       บฑฑ
ฑฑบ			 ณExpO1 - Model de acessorio		 			    	       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA280							                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At280RAce(cItemPai,oMdlVisAce)

Local aAcessorio := {}        				// Array de acessorios.
Local nX 		 := 0                     	// Incremento utilizado no For.
Local nLinAtu	 := oMdlVisAce:GetLine()   	// Linha atual.

For nX := 1 to oMdlVisAce:Length()
	
	oMdlVisAce:GoLine(nX)
	
	If cItemPai == oMdlVisAce:GetValue("AAU_ITPAI")
		
		aAdd(aAcessorio,{	oMdlVisAce:GetValue("AAU_PRODUT") ,;
							oMdlVisAce:GetValue("AAU_DESCRI") ,;
							oMdlVisAce:GetValue("AAU_UM")	  ,;
							oMdlVisAce:GetValue("AAU_MOEDA")  ,;
							oMdlVisAce:GetValue("AAU_QTDVEN") ,;
							oMdlVisAce:GetValue("AAU_PRCVEN") ,;
							oMdlVisAce:GetValue("AAU_PRCTAB") ,;
							oMdlVisAce:GetValue("AAU_VLRTOT") ,;
							oMdlVisAce:GetValue("AAU_TPPROD") ,;
							oMdlVisAce:GetValue("AAU_FOLDER") ,;
							oMdlVisAce:GetValue("AAU_LOCAL")  ,;
							oMdlVisAce:GetValue("AAU_CODVIS") ,;
							oMdlVisAce:GetValue("AAU_ITEM") }	)
	EndIf
	
Next nX

oMdlVisAce:GoLine(nLinAtu)

Return( aAcessorio )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt280AdItP บAutor  ณVendas CRM          บ Data ณ 29/03/12    บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona os produtos / acessorios na proposta.		        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro 		                                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Modelo de Dados							           	 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA280							                             บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At280AdItP(oMdl)

Local oMdlProPrd	:= oMdl:GetModel("PRPPRDDET")  								// Modelo de dados proposta - produtos.
Local oMdlProAce	:= oMdl:GetModel("PRPACEDET")								// Modelo de dados proposta - produtos.
Local oMdlAtu		:= Nil      			                                       	// ModelGrid atual.
Local nX 			:= 0     														// Incremento utilizado no For.
Local nI			:= 0															// Incremento utilizado no For. 
Local nY			:= 0															// Incremento utilizado no For.
Local lAchou		:= .F.
Local aPrdSel		:= {}															// Array com produtos e acessorios.
Local aProduto 	:= {}															// Array com produtos.
Local aAcessorio	:= {}															// Array com acessorios.  
Local nLinha		:= 0															// Linha atual.

For nX	:= 1  To oMdlProPrd:Length()
	
	oMdlProPrd:GoLine(nX)
	
	If !oMdlProPrd:IsDeleted() .AND. !Empty(oMdlProPrd:GetValue("ADZ_PRODUT"))		
		aAdd(aProduto,{	oMdlProPrd:GetValue("ADZ_ITEM")		,;
							oMdlProPrd:GetValue("ADZ_PRODUT") 	,;
							oMdlProPrd:GetValue("ADZ_DESCRI") 	,;
							oMdlProPrd:GetValue("ADZ_UM")	  	,;
							oMdlProPrd:GetValue("ADZ_MOEDA")  	,;
							oMdlProPrd:GetValue("ADZ_QTDVEN") 	,;
							oMdlProPrd:GetValue("ADZ_PRCVEN") 	,;
							oMdlProPrd:GetValue("ADZ_PRCTAB") 	,;
							oMdlProPrd:GetValue("ADZ_TOTAL")  	,;
							oMdlProPrd:GetValue("ADZ_TPPROD") 	,;
							oMdlProPrd:GetValue("ADZ_ITPAI")	,;
							oMdlProPrd:GetValue("ADZ_FOLDER")	,;
							oMdlProPrd:GetValue("ADZ_LOCAL")	,;
							oMdlProPrd:GetValue("ADZ_CODVIS")	,;
							oMdlProPrd:GetValue("ADZ_ITEMVI")	})
	Endif 
	
Next nX               

For nX	:= 1	To oMdlProAce:Length()
		
	oMdlProAce:GoLine(nX)
		
	If !oMdlProAce:IsDeleted() .AND. !Empty(oMdlProAce:GetValue("ADZ_PRODUT"))
		
		aAdd(aAcessorio,{	oMdlProAce:GetValue("ADZ_ITEM")		,;
							oMdlProAce:GetValue("ADZ_PRODUT") 	,;
							oMdlProAce:GetValue("ADZ_DESCRI") 	,;
							oMdlProAce:GetValue("ADZ_UM")	  	,;
							oMdlProAce:GetValue("ADZ_MOEDA")  	,;
							oMdlProAce:GetValue("ADZ_QTDVEN") 	,;
							oMdlProAce:GetValue("ADZ_PRCVEN") 	,;
							oMdlProAce:GetValue("ADZ_PRCTAB") 	,;
							oMdlProAce:GetValue("ADZ_TOTAL")  	,;
							oMdlProAce:GetValue("ADZ_TPPROD") 	,;
							oMdlProAce:GetValue("ADZ_ITPAI")	,;
							oMdlProAce:GetValue("ADZ_FOLDER")	,;
							oMdlProAce:GetValue("ADZ_LOCAL")	,;
							oMdlProAce:GetValue("ADZ_CODVIS")	,;
							oMdlProAce:GetValue("ADZ_ITEMVI")	})
	Endif
	
Next nX


If Len(aProduto) > 0
	
	For nX := 1 To Len(aProduto)
		
		aAdd(aPrdSel,{ "P"				 ,;
						aProduto[nX][2] ,;
						aProduto[nX][3] ,;
						aProduto[nX][4] ,;
						aProduto[nX][5] ,;
						aProduto[nX][6] ,;
						aProduto[nX][7] ,;
						aProduto[nX][8] ,;
						aProduto[nX][9] ,;
						aProduto[nX][10],;
						aProduto[nX][11],;
						aProduto[nX][12],;
						aProduto[nX][13],;
						aProduto[nX][14],;
						aProduto[nX][15],;
						aProduto[nX][1]})
		
		nPos := aScan(aAcessorio,{|x| x[10] == aProduto[nX][1]})
		
		If nPos > 0
			
			For nI := Len(aAcessorio) To 1 Step -1
				
				If ( aAcessorio[nI][10] == aProduto[nX][1] )
					
					aAdd(aPrdSel,{ "A"  			   ,;
									aAcessorio[nI][2] ,;
									aAcessorio[nI][3] ,;
									aAcessorio[nI][4] ,;
									aAcessorio[nI][5] ,;
									aAcessorio[nI][6] ,;
									aAcessorio[nI][7] ,;
									aAcessorio[nI][8] ,;
									aAcessorio[nI][9] ,;
									aAcessorio[nI][10],;
									aAcessorio[nI][11],;
									aAcessorio[nI][12],;
									aAcessorio[nI][13],;
									aAcessorio[nI][14],;
									aAcessorio[nI][15],;
									aAcessorio[nI][1]})																											
					aDel(aAcessorio,nI)
					aSize(aAcessorio,(Len(aAcessorio)-1))
				EndIf
				
			Next nI
		EndIf
	Next nX
EndIf


If Len(aAcessorio) > 0
	
	For nX := 1 To Len(aAcessorio)
		
		aAdd(aPrdSel,{ "A"  			   ,;
						aAcessorio[nX][2] ,;
						aAcessorio[nX][3] ,;
						aAcessorio[nX][4] ,;
						aAcessorio[nX][5] ,;
						aAcessorio[nX][6] ,;
						aAcessorio[nX][7] ,;
						aAcessorio[nX][8] ,;
						aAcessorio[nX][9] ,;
						aAcessorio[nX][10],;
						aAcessorio[nX][11],;
						aAcessorio[nX][12],;
						aAcessorio[nX][13],;
						aAcessorio[nX][14],;
						aAcessorio[nX][15],;
						aAcessorio[nX][1]})
	Next nX
	
EndIf         

If Len(aPrdSel) > 0
	
	For nX := 1 To Len(aPrdSel)
		
		If aPrdSel[nX][1] == "P"
			oMdlAtu := oMdlADZPrd	
		Else
			oMdlAtu := oMdlADZAce	
		EndIf

		lAchou := .F.
		nLinha := 1			
		For nY := 1 To oMdlAtu:Length()
			oMdlAtu:GoLine(nY)
			If 	oMdlAtu:GetValue("ADZ_ITEM") == aPrdSel[nX][16]
				lAchou := .T. 
				Exit
			EndIf	
		Next nY
		
		If !lAchou .AND. !Empty(oMdlAtu:GetValue("ADZ_PRODUT"))
			nLinha := oMdlAtu:AddLine()
			oMdlAtu:GoLine(nLinha)			
		EndIf
		
		oMdlAtu:SetValue("ADZ_PRODUT"	,aPrdSel[nX][2])	
		oMdlAtu:SetValue("ADZ_DESCRI"	,aPrdSel[nX][3])	
		oMdlAtu:SetValue("ADZ_UM"		,aPrdSel[nX][4])		
		oMdlAtu:SetValue("ADZ_MOEDA"	,aPrdSel[nX][5])	
		oMdlAtu:SetValue("ADZ_QTDVEN"	,aPrdSel[nX][6])	
		oMdlAtu:SetValue("ADZ_PRCVEN"	,aPrdSel[nX][7])	
		oMdlAtu:SetValue("ADZ_PRCTAB"	,aPrdSel[nX][8])	
		oMdlAtu:SetValue("ADZ_TOTAL"	,aPrdSel[nX][9])	
		oMdlAtu:SetValue("ADZ_TPPROD"	,aPrdSel[nX][10])
		oMdlAtu:SetValue("ADZ_ITPAI"	,aPrdSel[nX][11])	
		oMdlAtu:SetValue("ADZ_FOLDER"	,aPrdSel[nX][12])
		oMdlAtu:SetValue("ADZ_LOCAL"	,aPrdSel[nX][13])
		oMdlAtu:SetValue("ADZ_CODVIS"	,aPrdSel[nX][14])
		oMdlAtu:SetValue("ADZ_ITEMVI"	,aPrdSel[nX][15])  
		
		If aPrdSel[nX][1] == "P"
			If A600VldPOrc(aPrdSel[nX][2], aPrdSel[nX][14])								
				// Atualiza a condi็ใo de pagamento e TES do item da proposta
				TFJ->(DbSetOrder(6)) //TFJ_FILIAL + TFJ_CODVIS	
				If TFJ->(DbSeek(xFilial("TFJ")+aPrdSel[nX][14]))
					oMdlAtu:SetValue("ADZ_CONDPG"	,TFJ->TFJ_CONDPG)   
					oMdlAtu:SetValue("ADZ_TES"		,TFJ->TFJ_TES)					
				EndIf
				A600AtuNItem( aPrdSel[nX][2], aPrdSel[nX][16] )
			EndIf			
		EndIf			                                          

	Next nX

	oMdlADZPrd:GoLine(1)
	oMdlADZAce:GoLine(1)

EndIf
 
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt280LdPrd บAutor  ณVendas CRM          บ Data ณ 29/03/12    บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz load dos produtos com base na Proposta Comercial.        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpA - Array com os produtos.		                           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto model grid. 						           	บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA280							                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function At280LdPrd(oMdlGrid)

Local oStruct  	:= oMdlGrid:GetStruct()		// Retorna a estrutura atual.
Local aCampos  	:= oStruct:GetFields()		// Retorna os campos da estrutura.
Local aLoadPrd 	:= {} 							// Array com os produtos para ser carregados.
Local nX	   		:= 0   							// Incremento utilizado no For.
Local nI	   		:= 0							// Incremento utilizado no For.
Local nLinha   	:= 0                            // Linha atual.

For nX := 1 To oMdlADZPrd:Length()
	oMdlADZPrd:GoLine(nX)
	aAdd(aLoadPrd,{oMdlADZPrd:GetDataId(),Array(Len(aCampos))})
	nLinha := Len(aLoadPrd)
	For nI := 1 To Len(aCampos)
		If aCampos[nI][MODEL_FIELD_IDFIELD] == "ADZ_LEGEN"
			aLoadPrd[nLinha][2][nI]	 := "BR_LARANJA"			
		Else
			aLoadPrd[nLinha][2][nI] := oMdlADZPrd:GetValue(aCampos[nI][MODEL_FIELD_IDFIELD])
		EndIf
	NexT nI
Next nX

Return(aLoadPrd)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt280LdAce บAutor  ณVendas CRM          บ Data ณ 29/03/12    บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz load dos acessorios com base na Proposta Comercial       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpA - Array com os acessorios.			                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO1 - Objeto model grid. 						 	          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA280							                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At280LdAce(oMdlGrid)

Local oStruct	 	:= oMdlGrid:GetStruct()			// Retorna a estrutura atual.
Local aCampos 	 	:= oStruct:GetFields()			// Retorna os campos da estrutura.
Local aLoadAce	 	:= {}               				// Array com os acessorios para ser carregados.
Local nX	   		:= 0								// Incremento utilizado no For.
Local nI	   		:= 0								// Incremento utilizado no For.
Local nLinha   	:= 0								// Linha atual.

For nX := 1 To oMdlADZAce:Length()
	oMdlADZAce:GoLine(nX)
	aAdd(aLoadAce,{oMdlADZAce:GetDataId(),Array(Len(aCampos))})
	nLinha := Len(aLoadAce)
	For nI := 1 To Len(aCampos)
		If aCampos[nI][MODEL_FIELD_IDFIELD] == "ADZ_LEGEN"
			aLoadAce[nLinha][2][nI] := "BR_LARANJA"
		Else
			aLoadAce[nLinha][2][nI] := oMdlADZAce:GetValue(aCampos[nI][MODEL_FIELD_IDFIELD])	
		EndIf
	NexT nI
Next nX

Return(aLoadAce)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAt280Act   บAutor  ณVendas CRM          บ Data ณ  28/02/12   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAdiciona a legenda nos itens.						           บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณExpL - Verdadeiro 		                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณExpO - Modelo de dados.					                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTECA280							                           บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function At280Act(oMdl)

Local oMdlVisPrd	:= oMdl:GetModel("VISPRDDET")	// Modelo de dados proposta - produtos.
Local oMdlVisAce	:= oMdl:GetModel("VISACEDET")  	// Modelo de dados proposta - produtos.								
Local oMdlPrpPrd	:= oMdl:GetModel("PRPPRDDET")	// Modelo de dados proposta - produtos.
Local oMdlPrpAce	:= oMdl:GetModel("PRPACEDET")  	// Modelo de dados proposta - produtos.
Local nX	   		:= 0 							// Incremento utilizado no laco For.
Local nI			:= 0							// Incremento utilizado no laco For.
Local lModified		:= .F. 							// Linha modificada.
Local aCampos		:= {}							// Campos da estrutura.
Local nLinha		:= 0  							// Linha atual.

aCampos :=	{ {"AAU_PRODUT","ADZ_PRODUT"}	,;
			  {"AAU_UM"	   ,"ADZ_UM"    }	,;
              {"AAU_MOEDA" ,"ADZ_MOEDA" }	,;
              {"AAU_QTDVEN","ADZ_QTDVEN"}	,;
              {"AAU_PRCVEN","ADZ_PRCVEN"}	,;
              {"AAU_PRCTAB","ADZ_PRCTAB"}	,;
              {"AAU_VLRTOT","ADZ_TOTAL" }	,;
		  	  {"AAU_TPPROD","ADZ_TPPROD"}	} 
		  	  
		  	          
For nX := 1 To oMdlVisPrd:Length()
	
	lModified := .F.            
	oMdlVisPrd:GoLine(nX)
	lSeek := ( oMdlPrpPrd:SeekLine({{"ADZ_ITEM",oMdlVisPrd:GetValue("AAU_ITPROP")}}) .AND. !Empty(oMdlPrpPrd:GetValue("ADZ_PRODUT")) )
	If lSeek
		nLinha := oMdlPrpPrd:GetLine()
		oMdlADZPrd:GoLine(nLinha)
		If !oMdlADZPrd:IsDeleted()
			For nI := 1 To Len(aCampos)
				If (	oMdlVisPrd:GetValue(aCampos[nI][1]) <> oMdlPrpPrd:GetValue(aCampos[nI][2]) )
						oMdlVisPrd:SetValue("AAU_LEGEN","BR_AMARELO")
						oMdlPrpPrd:SetValue("ADZ_LEGEN","BR_AMARELO")
					lModified := .T.
					Exit
				EndIf
			Next nI
			
			If !lModified
				oMdlVisPrd:SetValue("AAU_LEGEN","BR_VERDE")
				oMdlPrpPrd:SetValue("ADZ_LEGEN","BR_VERDE")
			EndIf
		Else
			oMdlVisPrd:SetValue("AAU_LEGEN","BR_CINZA")
			oMdlPrpPrd:SetValue("ADZ_LEGEN","BR_CINZA")
			oMdlPrpPrd:DeleteLine()
		EndIf
		
	Else
		If Empty(oMdlVisPrd:GetValue("AAU_ITPROP"))
			oMdlVisPrd:SetValue("AAU_LEGEN","BR_AZUL")
		Else
			oMdlVisPrd:SetValue("AAU_LEGEN","BR_CINZA")
		EndIf
	EndIf
	
Next nX   

For nX := 1 To oMdlVisAce:Length()
	
	lModified := .F.            
	oMdlVisAce:GoLine(nX)
	lSeek := ( oMdlPrpAce:SeekLine({{"ADZ_ITEM",oMdlVisAce:GetValue("AAU_ITPROP")}}) .AND. !Empty(oMdlPrpAce:GetValue("ADZ_PRODUT")) )
	If lSeek
		nLinha := oMdlPrpAce:GetLine()
		oMdlADZAce:GoLine(nLinha)
		If !oMdlADZAce:IsDeleted()
			For nI := 1 To Len(aCampos)
				If ( oMdlVisAce:GetValue(aCampos[nI][1]) <> oMdlPrpAce:GetValue(aCampos[nI][2]) )
					oMdlVisAce:SetValue("AAU_LEGEN","BR_AMARELO")
					oMdlPrpAce:SetValue("ADZ_LEGEN","BR_AMARELO")
					lModified := .T.
					Exit
				EndIf
			Next nI
			
			If !lModified
				oMdlVisAce:SetValue("AAU_LEGEN","BR_VERDE")
				oMdlPrpAce:SetValue("ADZ_LEGEN","BR_VERDE")
			EndIf
		Else
			oMdlVisAce:SetValue("AAU_LEGEN","BR_CINZA")
			oMdlPrpAce:SetValue("ADZ_LEGEN","BR_CINZA")
			oMdlPrpAce:DeleteLine()
		EndIf
		
	Else
		If Empty(oMdlVisAce:GetValue("AAU_ITPROP"))
			oMdlVisAce:SetValue("AAU_LEGEN","BR_AZUL")
		Else
			oMdlVisAce:SetValue("AAU_LEGEN","BR_CINZA") 
		EndIf
	EndIf
	
Next nX    
 
// Deleta linha no model para linhas deletadas no acols
For nX := 1 To oMdlADZPrd:Length()
	oMdlADZPrd:GoLine(nX)
	If oMdlADZPrd:IsDeleted()  
		oMdlPrpPrd:GoLine(nX)   
		oMdlPrpPrd:SetValue("ADZ_LEGEN","BR_CINZA")
		oMdlPrpPrd:DeleteLine()
	EndIf 
Next nX

For nX := 1 To oMdlADZAce:Length()
	oMdlADZAce:GoLine(nX)
	If oMdlADZAce:IsDeleted() 
		oMdlPrpAce:GoLine(nX)  
		oMdlPrpAce:SetValue("ADZ_LEGEN","BR_CINZA")
		oMdlPrpAce:DeleteLine()
	EndIf  	
Next nX

//Posiciona na primeira linha dos grid antes do activate do model.
oMdlVisPrd:GoLine(1)
oMdlVisAce:GoLine(1)								
oMdlPrpPrd:GoLine(1)
oMdlPrpAce:GoLine(1)

Return( .T. )