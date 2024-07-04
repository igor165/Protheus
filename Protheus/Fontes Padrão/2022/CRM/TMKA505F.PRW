#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออออออออหอออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPersistTSTableStructureบAutorณMichel Mosca    บ Data ณ  01/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออสอออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     |Classe abstrata contemplando as funcionalidades comuns utilizadas  บฑฑ 
ฑฑบ          ณno acesso ao banco de dados.                                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class PersistTSTableStructure From Persist

Method save(obj) 
Method saveMaster(obj) 
Method saveDetail(obj)
Method delete(obj)                        
Method fillMaster(obj, cAlias)
Method fillDetail(obj, cAlias)
EndClass                               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSAVE      บAutor  ณMichel W. Mosca     บ Data ณ  23/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method save(obj) Class PersistTSTableStructure
Local lRet 	:= 	.F.     //Retorno da funcao          

Self:saveMaster(obj)
Self:saveDetail(obj)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSAVEMASTERบAutor  ณMichel W. Mosca     บ Data ณ  23/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method saveMaster(obj) Class PersistTSTableStructure
Local lRet 		:= .F.  //Retorno da funcao
Local nCount	:= 0	//Contador utilizado em loop
Local nPkCount  := 0	//Contador de itens da chave primaria 
Local nCountRel := 0   	//Contador de relacionamentos
Local oRow 				//Objeto linha do BD.
Local cSeek	:= ""		//Dados para realizar um DbSeek
Local lInsert := .F.	//Indica se deve ser inserido um novo registro

BEGIN TRANSACTION

	DbSelectArea(obj:master:alias)
	DbSetOrder(obj:master:iIdx)	 

	For nCount := 1 To Len(obj:master:rows)
		oRow := obj:master:rows[nCount]		
		cSeek := ""		
		For nPkCount := 1 To Len(oRow:pkFields)                          
			cSeek += oRow:pkFields[nPkCount]:value:value		
		Next nPkCount                                    
		
		If DbSeek(cSeek)
			lInsert := .F.		
		Else
			lInsert := .T.		
		EndIf 
		RecLock(obj:master:alias,lInsert)   
		
		If lInsert		
			//Campos da chave primaria
			For nPkCount := 1 To Len(oRow:pkFields)
				Eval(&("{|oValue| " + obj:master:alias + "->" + oRow:pkFields[nPkCount]:name + " := oValue}"),oRow:pkFields[nPkCount]:value:value)
				lRet := .T.
			Next nPkCount
		EndIf		
		//Campos da tabela
		For nPkCount := 1 To Len(oRow:fields)
			If oRow:fields[nPkCount]:context <> "V"
				Eval(&("{|oValue| " + obj:master:alias + "->" + oRow:fields[nPkCount]:name + " := oValue}"),oRow:fields[nPkCount]:value:value)
				lRet := .T.
			EndIf
		Next nPkCount				
		MsUnlock()
		
		//Adiciona a relacao com a tabela master
		For nCountRel := 1 To Len(obj:aRelations)
			obj:aRelations[nCountRel]:master:value:value := Eval(&("{||" + obj:master:alias + "->" + obj:aRelations[nCountRel]:master:name + "}"))			
		Next nCountRel	 
		
		If oRow:deleted 
			RecLock(obj:master:alias,.F.,.T.)
			DbDelete()		
			MsUnlock()
		EndIf				
		
		lRet := .T.
	Next nCount 
	ConfirmSX8()
END TRANSACTION    

Return lRet                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSAVEDETAILบAutor  ณMichel W. Mosca     บ Data ณ  23/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method saveDetail(obj) Class PersistTSTableStructure
Local lRet 	:= 	.F.     //Retorno da funcao
Local nCount:=	0		//Contador utilizado em loop
Local nPkCount := 0		//Contador de itens da chave primaria
Local nPkCount2:= 0		//Contador de itens da chave primaria
Local nPkCount3:= 0		//Contador de itens da chave primaria
Local oRow 				//Objeto linha do BD.
Local cSeek	:= ""		//Dados para realizar um DbSeek
Local lInsert := .F.	//Indica se deve ser inserido um novo registro
  

BEGIN TRANSACTION

	DbSelectArea(obj:detail:alias)
	DbSetOrder(obj:detail:iIdx)	

	For nCount := 1 To Len(obj:detail:rows)
		oRow := obj:detail:rows[nCount]

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAdiciona a relacao com a tabela master ณ
		//ณna chave primaria para registros novos.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                
		If oRow:lNew					
			For nPkCount := 1 To Len(obj:aRelations)
				For nPkCount3 := 1 To Len(oRow:pkFields)
					If AllTrim(oRow:pkFields[nPkCount3]:name) == AllTrim(obj:aRelations[nPkCount]:detail:name)
						oRow:pkFields[nPkCount3]:value:value := obj:aRelations[nPkCount]:master:value:value
						Exit
					EndIf	
				Next nPkCount3									
			Next nPkCount									
		EndIf
		
		cSeek := ""		
		For nPkCount := 1 To Len(oRow:pkFields)                          
			cSeek += IF(Empty(oRow:pkFields[nPkCount]:value:value), Space(oRow:pkFields[nPkCount]:value:size), oRow:pkFields[nPkCount]:value:value)
		Next nPkCount                                    		

		If DbSeek(cSeek)
			lInsert := .F.		
		Else
			lInsert := .T.		
		EndIf    

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerificacao adicional quando viola-se        |
		//|a chave primaria ao incluir novos registros.	ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !lInsert .AND. oRow:lNew
			If !Empty(obj:initGDField:name)
				While !lInsert 
					For nPkCount2 := 1 To Len(oRow:pkFields)                          
						If AllTrim(obj:initGDField:name) == AllTrim(oRow:pkFields[nPkCount2]:name)
							oRow:pkFields[nPkCount2]:value:value := Soma1(oRow:pkFields[nPkCount2]:value:value)
							cSeek := ""		
							For nPkCount := 1 To Len(oRow:pkFields)                          
								cSeek += IF(Empty(oRow:pkFields[nPkCount]:value:value), Space(oRow:pkFields[nPkCount]:value:size), oRow:pkFields[nPkCount]:value:value)
							Next nPkCount						
							Exit
						EndIf
					Next nPkCount2 
					If nPkCount2 <= Len(oRow:pkFields)
						If DbSeek(cSeek)
							lInsert := .F.		
						Else
							lInsert := .T.
							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณAtribui o novo valor do campoณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
							For nPkCount := 1 To Len(oRow:fields)
								If AllTrim(oRow:pkFields[nPkCount2]:name) == AllTrim(oRow:fields[nPkCount]:name)
									oRow:fields[nPkCount]:value:value := oRow:pkFields[nPkCount2]:value:value
									Exit
								EndIf	
							Next nPkCount				        								
						EndIf 
					Else
						lInsert := .T.
					EndIf   					  					
				End                            						
			EndIf	
		EndIf

		RecLock(obj:detail:alias,lInsert)   		
		//Campos da tabela
	  	For nPkCount := 1 To Len(oRow:fields)
			If !("ADF_CODOBS" $ oRow:fields[nPkCount]:name)
				Eval(&("{|oValue| " + obj:detail:alias + "->" + oRow:fields[nPkCount]:name + " := oValue}"),oRow:fields[nPkCount]:value:value)
			ElseIf ("ADF_CODOBS" $ oRow:fields[nPkCount]:name) .And. oRow:lNew
				If !Empty(GdFieldGet("ADF_OBS", nCount))
					Eval(&("{|oValue| " + obj:detail:alias + "->" + oRow:fields[nPkCount]:name + " := oValue}"),MSMM(,TamSx3("ADF_OBS")[1],,GdFieldGet("ADF_OBS", nCount),1,,,"ADF","ADF_CODOBS"))
				Else
					Eval(&("{|oValue| " + obj:detail:alias + "->" + oRow:fields[nPkCount]:name + " := oValue}"),oRow:fields[nPkCount]:value:value)
				EndIf
			ElseIf ("ADF_CODOBS" $ oRow:fields[nPkCount]:name) .And. !oRow:lNew
				If !Empty(GdFieldGet("ADF_OBS", nCount))
					Eval(&("{|oValue| " + obj:detail:alias + "->" + oRow:fields[nPkCount]:name + " := oValue}"),MSMM(Iif(!Empty(&(obj:detail:alias+"->"+oRow:fields[nPkCount]:name)),;
						 &(obj:detail:alias+"->"+oRow:fields[nPkCount]:name),Nil),TamSx3("ADF_OBS")[1],,GdFieldGet("ADF_OBS", nCount),1,,,"ADF","ADF_CODOBS"))
				Else
					Eval(&("{|oValue| " + obj:detail:alias + "->" + oRow:fields[nPkCount]:name + " := oValue}"),oRow:fields[nPkCount]:value:value)
				EndIf
			EndIf
			lRet := .T.
		Next nPkCount				        
		If lInsert		
			//Campos da chave primaria
			For nPkCount := 1 To Len(oRow:pkFields)
				Eval(&("{|oValue| " + obj:detail:alias + "->" + oRow:pkFields[nPkCount]:name + " := oValue}"),oRow:pkFields[nPkCount]:value:value)
				lRet := .T.
			Next nPkCount
			
			//Adiciona a relacao com a tabela master
			For nPkCount := 1 To Len(obj:aRelations)
				Eval(&("{|oValue| " + obj:detail:alias + "->" + obj:aRelations[nPkCount]:detail:name + " := oValue}"),obj:aRelations[nPkCount]:master:value:value)
			Next nPkCount			
		EndIf		
		MsUnlock()     
		If oRow:deleted 
			RecLock(obj:detail:alias,.F.,.T.)
			DbDelete()		
			MsUnlock()
		EndIf
		lRet := .T.
	Next nCount 
	ConfirmSX8()
END TRANSACTION    

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDELETE    บAutor  ณMichel W. Mosca     บ Data ณ  01/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method delete(obj) Class PersistTSTableStructure
Local lRet := .F.

BEGIN TRANSACTION
/*	DbSelectArea("SKA")
	DbSetOrder(1) //KA_FILIAL+KA_CODIGO
	If DbSeek(xFilial("SKA")+obj:id)
		Reclock( "SKA" ,.F.,.T.)
		DbDelete()
		MsUnlock()		   
		lRet := .T.
	EndIf
	*/
END TRANSACTION
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfillDetail    บAutor  ณMichel W. Mosca บ Data ณ  22/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreenche a classe com os registros da tabela detalhe.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method fillDetail(obj, cAlias, cValid) Class PersistTSTableStructure 
Local oRow 							    		//Registro na tabela                     
Local lRet				:= .F.					//Retorno da funcao
Local nCount			:= 0 					//Contador  
Local cAliasReal		:= obj:detail:alias		//Alias Real
Default cValid 			:= "{||.T. .AND. .T.}"

While (cAlias)->(!EOF()) .AND. Eval(&(cValid))   
	oRow := obj:detail:getNewRow()
		
	//Adiciona o RecnNo 
	#IFNDEF TOP
		oRow:rowID := (cAlias)->(RecNo())
	#ELSE
		oRow:rowID := (cAlias)->R_E_C_N_O_
	#ENDIF
	
	(cAliasReal)->(DBGoTo((cAlias)->R_E_C_N_O_))

	//Campos da chave primaria
	For nCount := 1 To Len(oRow:pkFields)
		oRow:pkFields[nCount]:value:value := Eval(&("{||" + cAliasReal  + "->" + oRow:pkFields[nCount]:name + "}"))		
		lRet := .T.
	Next nCount
	
	//Campos da tabela
	For nCount := 1 To Len(oRow:fields) 
		oRow:fields[nCount]:value:value := Eval(&("{||" + cAliasReal + "->" + oRow:fields[nCount]:name + "}"))
		lRet := .T.
	Next nCount
	
	obj:detail:addRow(oRow) 
	(cAlias)->(DbSkip())
End
Return obj

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfillMaster    บAutor  ณMichel W. Mosca บ Data ณ  22/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreenche a classe com os registros da tabela master.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method fillMaster(obj, cAlias) Class PersistTSTableStructure 
Local oRow := obj:master:getNewRow()   //Registro na tabela                     
Local lRet := .F.						//Retorno da funcao
Local nCount := 0 						//Contador
                  
//Adiciona o RecnNo
oRow:rowID := (cAlias)->(RecNo())           
           
//Campos da chave primaria
For nCount := 1 To Len(oRow:pkFields)
	oRow:pkFields[nCount]:value:value := Eval(&("{||" + cAlias + "->" + oRow:pkFields[nCount]:name + "}"))
	lRet := .T.
Next nCount

//Campos da tabela
For nCount := 1 To Len(oRow:fields)
	If oRow:fields[nCount]:context <> "V" .AND. TamSx3(oRow:fields[nCount]:name)[3] <> "M"
		oRow:fields[nCount]:value:value := Eval(&("{||" + cAlias + "->" + oRow:fields[nCount]:name + "}"))
		lRet := .T.
	ElseIf oRow:fields[nCount]:context <> "V" .AND. TamSx3(oRow:fields[nCount]:name)[3] == "M"
		oRow:fields[nCount]:value:value := &(oRow:fields[nCount]:name)
		lRet := .T.
	EndIf
Next nCount
obj:master:addRow(oRow) 
Return obj  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_TMKA500      บAutor  ณMichel W. Mosca บ Data ณ  09/11/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao dummy apenas para o programa aparecer no inspetor de บฑฑ
ฑฑบ          ณobjetos                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                   
FUNCTION _TMKA505F()
RETURN NIL