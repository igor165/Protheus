#include 'protheus.ch'
#INCLUDE "fwmvcdef.ch"
 
/* {Protheus.doc} UBAC010        
Sincronizações do aplicativo do Beneficiamento

@author 	francisco.nunes
@since 		30/07/2018
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function UBAC010()
		
	Private oMBrowse := {}
			
	oMBrowse := FWMBrowse():New()	
	oMBrowse:SetAlias("NC2")
	oMBrowse:SetDescription('Sincronizações do Aplicativo do Beneficiamento') // Sincronizações do Aplicativo do Beneficiamento
							
	oMBrowse:AddLegend("NC2_STATUS = '1'", "GREEN", "Sincronizado") //"Sincronizado"
	oMBrowse:AddLegend("NC2_STATUS = '2'", "RED", "Erro de sincronização") //"Erro de sincronização"
					
	oMBrowse:Activate()
	
Return()

/*{Protheus.doc} MenuDef()
@type  Function
@author francisco.nunes
@since 30/07/2018
@version 1.0
*/
Static Function MenuDef()
	Local aRotina := {} 

	aAdd(aRotina, {'Pesquisar'       , "PesqBrw"        , 0, 1, 0, .T.})  //'Pesquisar'
	aAdd(aRotina, {'Visualizar'      , 'ViewDef.UBAC010', 0, 2, 0, Nil})  //'Visualizar'	
	aAdd(aRotina, {'Processar'       , "UB010PROC()"    , 0, 4, 0, Nil})  //"Processar"
	aAdd(aRotina, {'Limpar Historico', "UB010LIMP()"    , 0, 4, 0, Nil})  //"Limpar Historico"
	
Return aRotina

/*{Protheus.doc} ModelDef()
Função que retorna o modelo padrao para a rotina

@type  Function
@author francisco.nunes
@since 30/07/2018
@version 1.0
*/
Static Function ModelDef()
	Local oStruNC2 := FWFormStruct(1, "NC2")
	Local oStruNC3 := FWFormStruct(1, "NC3")
	Local oStruNC4 := FWFormStruct(1, "NC4")
	Local oStruNCW := FWFormStruct(1, "NCW")
	Local oModel   := MPFormModel():New("UBAC010")
		
	// Adiciona a Estrutura da Grid o Botão de Legenda
	If !IsBlind()
		oStruNC4:AddField("TP" , "Legenda", 'NC4_STSLEG', 'BT' , 1 , 0, , NIL , NIL, NIL, {|| UB010LGNC4(NC4->(NC4_STATUS))}, NIL, .F., .T.)
	EndIf	
	
	oModel:AddFields('NC2UNICO', Nil, oStruNC2)
	oModel:SetDescription('Sincronização') //"Sincronização"
	oModel:GetModel('NC2UNICO'):SetDescription('Dados da Sincronização') //"Dados da Sincronização"
	
	oModel:AddGrid("NC3UNICO", "NC2UNICO", oStruNC3)
	oModel:GetModel("NC3UNICO"):SetDescription('Contaminantes') //"Contaminantes"
	oModel:GetModel("NC3UNICO"):SetUniqueLine({"NC3_SEQUEN"})
	oModel:GetModel("NC3UNICO"):SetOptional(.T.)
	oModel:SetRelation("NC3UNICO", {{"NC3_FILIAL", "FWxFilial('NC3')" }, {"NC3_DATA", "NC2_DATA"}, {"NC3_HORA", "NC2_HORA"}}, NC3->(IndexKey(1)))
	
	oModel:AddGrid("NC4UNICO", "NC2UNICO", oStruNC4)
	oModel:GetModel("NC4UNICO"):SetDescription('Erros de sincronização') //"Erros de sincronização"
	oModel:GetModel("NC4UNICO"):SetUniqueLine({"NC4_SEQUEN"})
	oModel:GetModel("NC4UNICO"):SetOptional(.T.)
	oModel:SetRelation("NC4UNICO", {{"NC4_FILIAL", "FWxFilial('NC4')" }, {"NC4_DATA", "NC2_DATA"}, {"NC4_HORA", "NC2_HORA"}}, NC4->(IndexKey(1)))	
	
	oModel:AddGrid("NCWUNICO", "NC2UNICO", oStruNCW)
	oModel:GetModel("NCWUNICO"):SetDescription('Fardos de sincronização') //"Fardos de sincronização"
	oModel:GetModel("NCWUNICO"):SetUniqueLine({"NCW_SEQUEN"})
	oModel:GetModel("NCWUNICO"):SetOptional(.T.)
	oModel:SetRelation("NCWUNICO", {{"NCW_FILIAL", "FWxFilial('NCW')" }, {"NCW_DATA", "NC2_DATA"}, {"NCW_HORA", "NC2_HORA"}}, NCW->(IndexKey(1)))
			
Return oModel

/*{Protheus.doc} ViewDef()
Função que retorna a view para o modelo padrao da rotina

@type  Function
@author francisco.nunes
@since 30/07/2018
@version 1.0
*/
Static Function ViewDef()
	Local oStruNC2 := FWFormStruct(2, "NC2")
	Local oStruNC3 := FWFormStruct(2, "NC3")
	Local oStruNC4 := FWFormStruct(2, "NC4")
	Local oStruNCW := FWFormStruct(2, "NCW")
	Local oModel   := FWLoadModel("UBAC010")
	Local oView	   := FWFormView():New()
	
	oStruNC3:RemoveField("NC3_DATA")
	oStruNC3:RemoveField("NC3_HORA")
	
	oStruNC4:AddField("NC4_STSLEG", '01', "", "Legenda", {}, 'BT', '@BMP', NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T.)	
	oStruNC4:RemoveField("NC4_DATA")
	oStruNC4:RemoveField("NC4_HORA")
	oStruNC4:RemoveField("NC4_STATUS")
	
	oStruNCW:RemoveField("NCW_DATA")
	oStruNCW:RemoveField("NCW_HORA")
	oStruNCW:RemoveField("NCW_SEQSIN")
				
	oView:SetModel(oModel)
	oView:AddField("VIEW_NC2", oStruNC2, "NC2UNICO")
	oView:AddGrid("VIEW_NC4", oStruNC4, "NC4UNICO")
	oView:AddGrid("VIEW_NC3", oStruNC3, "NC3UNICO")
	oView:AddGrid("VIEW_NCW", oStruNCW, "NCWUNICO")
		
	oView:CreateHorizontalBox("SUPERIOR", 40)
	oView:CreateHorizontalBox("INFERIOR", 60)
	
	oView:CreateFolder("GRADES", "INFERIOR")
	oView:AddSheet("GRADES", "PASTA01", OemToAnsi('Erros de Sincronização')) //"Erros de Sincronização"
	oView:AddSheet("GRADES", "PASTA02", OemToAnsi('Contaminantes')) //"Contaminantes"
	oView:AddSheet("GRADES", "PASTA03", OemToAnsi('Fardos')) //"Fardos"
	
	oView:CreateHorizontalBox("PASTA_NC4", 100,,, "GRADES", "PASTA01" )
	oView:CreateHorizontalBox("PASTA_NC3", 100,,, "GRADES", "PASTA02" )
	oView:CreateHorizontalBox("PASTA_NCW", 100,,, "GRADES", "PASTA03" )		
	
	oView:SetOwnerView("VIEW_NC2", "SUPERIOR")
	oView:SetOwnerView("VIEW_NC4", "PASTA_NC4")
	oView:SetOwnerView("VIEW_NC3", "PASTA_NC3")
	oView:SetOwnerView("VIEW_NCW", "PASTA_NCW")
	
	oView:EnableTitleView("VIEW_NC2")
	oView:EnableTitleView("VIEW_NC4")
	oView:EnableTitleView("VIEW_NC3")
	oView:EnableTitleView("VIEW_NCW")
	
	oView:SetViewProperty("VIEW_NC4", "GRIDDOUBLECLICK", {{|oGrid,cFieldName,nLineGrid,nLineModel| UB010DBCL(cFieldName)}})
			
	oView:SetCloseOnOk({||.T.})

Return oView

/*{Protheus.doc} UB010DBCL
Trata o Double Click através da view para a Grid NC4.

@author francisco.nunes
@since 30/07/2018
@version 1.0
@param cFieldName, characters, campo efetou o clique
@type function
*/
Static Function UB010DBCL(cFieldName)
	 
    Local aLegenda := {}
    
    // Se o campo for a legenda, então apresenta a legenda
    If cFieldName == "NC4_STSLEG" 
        aLegenda := {{"BR_VERMELHO", 'Aguardando correção'},; // # 'Aguardando correção'
        			 {"BR_VERDE", 'Corrigido'}} // # 'Corrigido'                     

        BrwLegenda('Status do Erro', "Legenda", aLegenda) // *String Legenda não precisa ser cadastrada
    EndIf
    
Return .T.      
        
/*{Protheus.doc} UB010LGNC4
Retorna o tipo de legenda, conforme o status.

@author francisco.nunes
@since 30/07/2018
@version 1.0
@param cStatus, characters, Código de status
@return cTpCor, characters, Cor da legenda
@type function
*/
Static Function UB010LGNC4(cStatus)

	Local cTpCor := ""
	
	If cStatus = "1"
		cTpCor := "BR_VERMELHO"
	ElseIf  cStatus = "2"
		cTpCor := "BR_VERDE"
	EndIf

Return cTpCor

/*{Protheus.doc} UB010PROC
Processar a sincronização novamente (Quando possui algum erro de negócio e foi corrigido)

@author 	francisco.nunes
@since 		30/07/2018
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function UB010PROC()
		
	// Opção disponível apenas para itens de sincronização com erros
	If NC2->NC2_STATUS == "1" // Sincronizado
		MsgAlert("Já foi efetuado a sincronização deste item.", "Atenção")
		Return .F.		
	EndIf
	
	//"Aguarde" # "Aguarde a finalização do processamento da sincronização..."
	oProcess := MsNewProcess():New({|| UB010SINC()}, 'Aguarde', 'Aguarde o processamento da sincronização', .F.)
	oProcess:Activate()
	
Return .T.

/*{Protheus.doc} UB010SINC
Efetua as validações e se der tudo certo ocorreu efetua o processamento da sincronização

@author 	francisco.nunes
@since 		31/07/2018
@version 	1.0
@param 		Nil
@return 	Nil
*/
Static Function UB010SINC()

	Local nRecno	:= 0
	Local cTipoEnt	:= ""
	Local aContam	:= {}
	Local aErros	:= {}
	Local aCmps 	:= {}				
	Local cFilRom 	:= ""
	Local cCodRom 	:= ""
	Local cCodIne 	:= ""
	Local cSafra  	:= ""
	Local cEtiqu  	:= ""
	Local cBloco  	:= ""
	Local cCodOpe 	:= ""
	Local aCodRom	:= {}

	BEGIN TRANSACTION
	
		// Verificar se os erros foram corrigidos		
		If NC2->NC2_TPOPE $ "1|2"
			lErroSinc := UBW05CERR(NC2->NC2_FILIAL,NC2->NC2_DATA,NC2->NC2_HORA)
		ElseIf NC2->NC2_TPOPE == "3"
			lErroSinc := UBW09CERR(NC2->NC2_FILIAL,NC2->NC2_DATA,NC2->NC2_HORA,"1",NC2->NC2_TPENT,NC2->NC2_TPFILT,NC2->NC2_CODUN,NC2->NC2_CODINI,NC2->NC2_CODFIN)		
		ElseIf NC2->NC2_TPOPE == "4"
			lErroSinc := UBW02CERR(NC2->NC2_FILIAL,NC2->NC2_DATA,NC2->NC2_HORA,NC2->NC2_TPENT,NC2->NC2_TPFILT,NC2->NC2_CODUN,NC2->NC2_CODINI,NC2->NC2_CODFIN)
		ElseIf NC2->NC2_TPOPE == "5"
			lErroSinc := UBW09CERR(NC2->NC2_FILIAL,NC2->NC2_DATA,NC2->NC2_HORA,"2",,,NC2->NC2_CODUN)
		ElseIf NC2->NC2_TPOPE == "6" //Emb. Fisico
			lErroSinc := UBW07CERR(NC2->NC2_FILIAL,NC2->NC2_DATA,NC2->NC2_HORA,"2",,,NC2->NC2_CODUN)
		ElseIf NC2->NC2_TPOPE == "7" //Carregamento
			lErroSinc := UBW10CERR(NC2->NC2_FILIAL,NC2->NC2_DATA,NC2->NC2_HORA,NC2->NC2_SEQUEN,"2",,,NC2->NC2_CODUN) 
		EndIf
		
		// Caso os erros não tenham sido corrigidos ou tenham encontrados novos erros, não deixará continuar o 
		// processamento
		If lErroSinc
			MsgAlert("Os erros deste item não foram corrigidos ou foram encontrados novos erros.", "Atenção")			
		Else	
						
			If NC2->NC2_TPOPE $ "1|2" 
			
				// Recebimento ou Estorno da mala
			
				// Buscar o recno da mala					
				cAlias := GetNextAlias()
			    cQuery := " SELECT DXJ.R_E_C_N_O_, "
			    cQuery += "        DXJ.DXJ_FILIAL, "
			    cQuery += "    	   DXJ.DXJ_SAFRA, "
			    cQuery += "    	   DXJ.DXJ_CODIGO, "
			    cQuery += "    	   N73.N73_CODREM "
			    cQuery += " FROM " + RetSqlName("DXJ") + " DXJ "
			    cQuery += " INNER JOIN " + RetSqlName("N73") + " N73 ON N73.N73_FILIAL = DXJ.DXJ_FILIAL "
			    cQuery += "   AND N73.N73_CODMAL = DXJ.DXJ_CODIGO AND N73.N73_TIPO = DXJ.DXJ_TIPO "
			    cQuery += "   AND N73.D_E_L_E_T_ = ' ' "
			    cQuery += " WHERE DXJ.DXJ_STATUS IN ('1','2','4','5') "
			    cQuery += "   AND DXJ.D_E_L_E_T_ = ' ' "
			    cQuery += "   AND DXJ.DXJ_DATENV <> '' "
			    cQuery += "   AND DXJ.DXJ_CODBAR = '" + NC2->NC2_CODUN + "' "
			    
			    cQuery := ChangeQuery(cQuery)
			    MPSysOpenQuery(cQuery, cAlias)
	
				If (cAlias)->(!Eof()) 
					nRecno 	 := (cAlias)->R_E_C_N_O_
					cFilMala := (cAlias)->DXJ_FILIAL
					cCodMala := (cAlias)->DXJ_CODIGO
					cSafra   := (cAlias)->DXJ_SAFRA
					cCodRem  := (cAlias)->N73_CODREM					
				EndIf	
				
				If 	NC2->NC2_TPOPE == "1"					
					// Realiza a alteração da mala (Recebimento)											
					aErros := UBW05AltMl("1", nRecno, cFilMala, cCodMala, cSafra, cCodRem, NC2->NC2_DATOPE, NC2->NC2_HOROPE, NC2->NC2_USUOPE, NC2->NC2_FILIAL, NC2->NC2_DATA, NC2->NC2_HORA, NC2->NC2_SEQUEN)
				Else
					// Realiza a alteração da mala (Estorno)											
					aErros := UBW05AltMl("2", nRecno, cFilMala, cCodMala, cSafra, cCodRem, , , , NC2->NC2_FILIAL, NC2->NC2_DATA, NC2->NC2_HORA, NC2->NC2_SEQUEN)
				EndIf
				
			ElseIf NC2->NC2_TPOPE == "3"
			
				// Classificação do algodão
			
				If NC2->NC2_TPENT == "1" // Fardo 
					cTipoEnt := "1"
				ElseIf NC2->NC2_TPENT == "3" // Mala
					cTipoEnt := "2"
				EndIf			
				
				aErros := UBW09Class(cTipoEnt, NC2->NC2_TPFILT, NC2->NC2_CODUN, NC2->NC2_CODINI, NC2->NC2_CODFIN, NC2->NC2_DATOPE, NC2->NC2_HOROPE, NC2->NC2_USUOPE, NC2->NC2_TPCLAS, NC2->NC2_CODCLA, NC2->NC2_FILIAL, NC2->NC2_DATA, NC2->NC2_HORA, NC2->NC2_SEQUEN)
						
			ElseIf NC2->NC2_TPOPE == "4" 
				
				// Análise de contaminantes
			
				BEGIN TRANSACTION
				
					If NC2->NC2_TPENT == "1" // Fardo 
						cTipoEnt := "2"
					ElseIf NC2->NC2_TPENT == "2" // Bloco
						cTipoEnt := "3"
					ElseIf NC2->NC2_TPENT == "3" // Mala
						cTipoEnt := "1"
					EndIf
					
					DbSelectArea("NC3")
					NC3->(DbSetOrder(1)) // NC3_FILIAL+DTOS(NC3_DATA)+NC3_HORA+NC3_SEQSIN+NC3_SEQUEN
					If NC3->(DbSeek(NC2->NC2_FILIAL+NC2->NC2_DATA+NC2->NC2_HORA+NC2->NC2_SEQUEN))
						While NC3->(!Eof()) .AND. NC3->(NC3_FILIAL+NC3_DATA+NC3_HORA+NC3_SEQSIN) == NC2->NC2_FILIAL+NC2->NC2_DATA+NC2->NC2_HORA+NC2->NC2_SEQUEN
												
							Aadd(aContam, JsonObject():New())
							
							aTail(aContam)["code"] 		 := NC3->NC3_CODCON
							aTail(aContam)["typeResult"] := NC3->NC3_TPRES
							aTail(aContam)["result"] 	 := NC3->NC3_RESULT
														
							NC3->(DbSkip())
						EndDo						
					EndIf
			
					// Inclusão dos lançamentos de contminantes
					aErros := UB02IncLC(cTipoEnt, NC2->NC2_TPFILT, NC2->NC2_CODUN, NC2->NC2_CODINI, NC2->NC2_CODFIN, NC2->NC2_DATOPE, NC2->NC2_USUOPE, aContam, NC2->NC2_OBSCON, NC2->NC2_FILIAL, NC2->NC2_DATA, NC2->NC2_HORA, NC2->NC2_SEQUEN)
					
					If Len(aErros) > 0
						DisarmTransaction()
					EndIf
					
				END TRANSACTION
				
			ElseIf NC2->NC2_TPOPE == "5"
			
				// Revisão do tipo de classificação
				aErros := UBW09TeRev(NC2->NC2_CODUN, NC2->NC2_TPCLAS, NC2->NC2_FILIAL, NC2->NC2_DATA, NC2->NC2_HORA, NC2->NC2_SEQUEN)
			
			ElseIf NC2->NC2_TPOPE == "6" //Emb. Fisico
				aErros := UBW07Revisao(NC2->NC2_CODUN,NC2->NC2_FILIAL, NC2->NC2_DATA, NC2->NC2_HORA, NC2->NC2_SEQUEN ,NC2->NC2_CODALT)
			ElseIf NC2->NC2_TPOPE == "7"//Carregamento	
			
				BEGIN TRANSACTION
			
					aCmps := StrTokArr(NC2->NC2_CODUN,";")
										
					cFilRom := PadR(aCmps[1], TamSX3("NJJ_FILIAL")[1])
					cCodRom := PadR(aCmps[2], TamSX3("NJJ_CODROM")[1])
					cCodIne := PadR(aCmps[3], TamSX3("N7Q_CODINE")[1])
				
					DbSelectArea("NCW")
					NCW->(DbSetOrder(1)) // NCW_FILIAL+DTOS(NCW_DATA)+NCW_HORA+NCW_SEQSIN+NCW_SEQUEN
					If NCW->(DbSeek(NC2->NC2_FILIAL+DTOS(NC2->NC2_DATA)+NC2->NC2_HORA+NC2->NC2_SEQUEN))
						While NCW->(!Eof()) .AND. NCW->(NCW_FILIAL+DTOS(NCW_DATA)+NCW_HORA+NCW_SEQSIN) == NC2->(NC2_FILIAL+DTOS(NC2_DATA)+NC2_HORA+NC2_SEQUEN)
											
							cSafra  := PadR(NCW->NCW_SAFRA, TamSX3("NJJ_CODSAF")[1])
							cEtiqu  := PadR(NCW->NCW_ETIQ,  TamSX3("DXI_ETIQ")[1])
							cBloco  := PadR(NCW->NCW_BLOCO, TamSX3("DXD_CODIGO")[1])
							cCodOpe := AllTrim(NCW->NCW_TPOPER)
							
							// Realiza o vinculo / desvinculo dos fardos no romaneio		
							UBW10CARG(NCW->NCW_FILIAL, NCW->NCW_DATA, NCW->NCW_HORA, NCW->NCW_SEQSIN, cFilRom, cCodRom, cCodIne, cSafra, cEtiqu, cBloco, cCodOpe, @aCodRom, @aErros)
																										
							NCW->(DbSkip())
						EndDo						
					EndIf
					
					If Len(aErros) == 0
						UBW10ALTR(aCodRom)
					EndIf
				
				END TRANSACTION
				
			EndIf
			
			// Alteração do status da sincronização para "1=Sincronizado", caso não tenham encontrado nenhum erro
			If Len(aErros) == 0				
				UBAltStSin(NC2->NC2_FILIAL, NC2->NC2_DATA, NC2->NC2_HORA, NC2->NC2_SEQUEN ,"1")
			Else
				MsgAlert("Os erros deste item não foram corrigidos ou foram encontrados novos erros.", "Atenção")
			EndIf
			
		EndIf		
		
	END TRANSACTION

Return .T.

/*{Protheus.doc} UB010LIMP
Rotina para limpar os registro da NC2 e NC4 NC3 e NCW

@author 	Felipe.mendes
@since 		30/07/2018
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function UB010LIMP()
	
	
	If MSGYESNO( " Limpar registro com data superior a 60 dias? ", "Aviso" )
	
		//"Aguarde" # "Aguarde a finalização do processamento "
		oProcess := MsNewProcess():New({|| UB010Proces()}, 'Aguarde', 'Aguarde o processamento', .F.)
		oProcess:Activate()
	EndIf
	
Return .T.

/*{Protheus.doc} UB010Proces
Processo de limpeza

@author 	Felipe.mendes
@since 		30/07/2018
@version 	1.0
@param 		Nil
@return 	Nil
*/
Function UB010Proces()
	
	Local cData := Year2Str(Year(DDATABASE - 60)) + Month2Str(Month(DDATABASE - 60)) + Day2Str(Day(DDATABASE - 60))

	BEGIN TRANSACTION	

		DbSelectArea("NC2")	
		DbSetOrder(1)
		DbgoTop()
		While NC2->(!Eof()) .AND. NC2->NC2_FILIAL + DtoS(NC2->NC2_DATA) < xFilial("NC2") + cData
		
			DbSelectArea("NC4")
			DbSetOrder(1) //NC4_FILIAL+DTOS(NC4_DATA)+NC4_HORA+NC4_SEQSIN+NC4_SEQUEN
			DbSeek(NC2->(NC2_FILIAL + DTOS(NC2_DATA) + NC2_HORA + NC2_SEQUEN))
			While NC4->(!Eof()) .AND. NC4->(NC4_FILIAL+DTOS(NC4_DATA)+NC4_HORA+NC4_SEQSIN) == NC2->(NC2_FILIAL + DTOS(NC2_DATA) + NC2_HORA + NC2_SEQUEN)
				If RecLock("NC4", .F.)
					NC4->(DbDelete())
					NC4->(MsUnlock())			
				EndIf
				NC4->(DbSkip())
			EndDo
			
			DbSelectArea("NC3")
			DbSetOrder(1) //NC3_FILIAL+DTOS(NC3_DATA)+NC3_HORA+NC3_SEQSIN+NC3_SEQUEN
			DbSeek(NC2->(NC2_FILIAL + DTOS(NC2_DATA) + NC2_HORA + NC2_SEQUEN))
			While NC3->(!Eof()) .AND. NC3->(NC3_FILIAL+DTOS(NC3_DATA)+NC3_HORA+NC3_SEQSIN) == NC2->(NC2_FILIAL + DTOS(NC2_DATA) + NC2_HORA + NC2_SEQUEN)
				If RecLock("NC3", .F.)
					NC3->(DbDelete())
					NC3->(MsUnlock())			
				EndIf
				NC3->(DbSkip())
			EndDo
			
			DbSelectArea("NCW")
			DbSetOrder(1) //NCW_FILIAL+DTOS(NCW_DATA)+NCW_HORA+NCW_SEQSIN+NCW_SEQUEN
			DbSeek(NC2->(NC2_FILIAL + DTOS(NC2_DATA) + NC2_HORA + NC2_SEQUEN))
			While NCW->(!Eof()) .AND. NCW->(NCW_FILIAL+DTOS(NCW_DATA)+NCW_HORA+NCW_SEQSIN) == NC2->(NC2_FILIAL + DTOS(NC2_DATA) + NC2_HORA + NC2_SEQUEN)
				If RecLock("NCW", .F.)
					NCW->(DbDelete())
					NCW->(MsUnlock())			
				EndIf
				NCW->(DbSkip())
			EndDo
			
			If RecLock("NC2", .F.)
				NC2->(DbDelete())
				NC2->(MsUnlock())			
			EndIf
	
			NC2->(DbSkip())
		EndDo

	END TRANSACTION

Return .T.
