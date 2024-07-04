#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออหออออออัออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTSTableStructureCodebaseบAutor ณMichel Mosca  บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออสออออออฯออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     |Classe que contempla as rotina de acesso a banco de dados Codebase.บฑฑ 
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class TSTableStructureCodebase From PersistTSTableStructure

Method new() Constructor 
Method load(obj, keyInfo) 
Method loadMaster(obj, keyInfo) 
Method loadDetail(obj, keyInfo) 


EndClass
            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNew          บAutor  ณMichel W. Mosca  บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method new() Class TSTableStructureCodebase     
Return Self     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOAD      บAutor  ณMichel W. Mosca     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method load(obj, keyInfo) Class TSTableStructureCodebase  
Local lRet := .F.  

lRet := Self:loadMaster(obj, keyInfo)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOADMASTERบAutor  ณMichel W. Mosca     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os dados da tabela master.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method loadMaster(obj, keyInfo) Class TSTableStructureCodebase  
Local lRet 			:= .T. 		//Retorno da funcao
Local cAlias 	 				//Alias para acesso ao banco de dados
Local nCount  		:= 0		//Contador utilizado em loop for
Local nCountFields 	:= 0		//Contador utilizado no loop varrendo campos da selecao
Local cWhere  		:= ""		//Condicoes da query               
Local cValue 		:= ""      	//Valor do parametro recebido
Local cSeek 		:= ""
Local oField					//Objeto do tipo campo

//Adiciona o alias da tabela                              
cAlias := obj:master:alias 

//Adiciona as condicoes da query
For nCount := 1 To Len(keyInfo)
	oField := keyInfo[nCount]	
	cWhere += cAlias + "->" + oField + " == '" + Eval(&("{||" + obj:master:alias + "->" + oField + "}")) + "' .AND."
	//cWhere += cAlias + "->" + oField:name + " == '" + oField:value:value + "' .AND."
Next nCount                                        
cWhere := SubStr(cWhere,1,Len(cWhere)-5)

//Adiciona os campos da chave primaria
For nCount := 1 To Len(obj:master:pkFields)
	cValue := Space(obj:master:pkFields[nCount]:value:size)	
	For nCountFields := 1 To Len(keyInfo)
		oField := keyInfo[nCountFields]
		//If AllTrim(oField:name) == AllTrim(obj:master:pkFields[nCount]:name)
		If AllTrim(oField) == AllTrim(obj:master:pkFields[nCount]:name)
			//cValue := oField:value:value		
			cValue := Eval(&("{||" + obj:master:alias + "->" + oField + "}"))		
			Exit
		EndIf		
	Next nCountFields 
	cSeek += cValue	
Next nCount  


DbSelectArea(cAlias)
DbSetOrder(obj:master:iIdx) 
If DbSeek(RTrim(cSeek))
	If Eval(&("{||" + cWhere + "}"))
		Self:fillMaster(obj, cAlias)
		Self:loadDetail(obj, keyInfo, cAlias)
	Else
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIF

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOADDETAILบAutor  ณMichel W. Mosca     บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega os dados da tabela detalhes.                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method loadDetail(obj, keyInfo, cMasterAlias) Class TSTableStructureCodebase  
Local lRet := .T.         		//Retorno da funcao
Local cAlias :=	GetNextAlias() 	//Alias para acesso ao banco de dados
Local cFields := ""				//Campos da tabela a serem selecionados
Local nCount  := 0 				//Contador utilizado em loop for
Local nCountRel := 0 			//Contador utilizado em loop
Local cWhere  := ""				//Condicoes da query
Local oBranch					//Armazena a filial da tabela
Local oField					//Objeto do tipo campo                 
Local aSelFields := {}			//Campos inseridos na sele็ใo da query
Local nCountFields 	:= 0		//Contador utilizado no loop varrendo campos da selecao
Local cValue 		:= ""      	//Valor do parametro recebido
Local cSeek 		:= ""

//Adiciona o alias da tabela                              
cAlias := obj:detail:alias 

//Adiciona a relacao com a tabela master
For nCount := 1 To Len(obj:aRelations)
	cWhere += cAlias + "->" + obj:aRelations[nCount]:detail:name + " == '" + Eval(&("{||" + cMasterAlias + "->" + obj:aRelations[nCount]:master:name + "}")) + "' .AND." 	
Next nCount
cWhere := SubStr(cWhere,1,Len(cWhere)-5)
                       
//Adiciona os campos da chave primaria
For nCount := 1 To Len(obj:detail:pkFields)
	cValue := Space(obj:detail:pkFields[nCount]:value:size)	
	//Verifica se nใo foi passado nenhum parametro pelo usuario
	For nCountFields := 1 To Len(keyInfo)
		oField := keyInfo[nCountFields]
		//If AllTrim(oField:name) == AllTrim(obj:detail:pkFields[nCount]:name)
		If AllTrim(oField) == AllTrim(obj:detail:pkFields[nCount]:name)
			//cValue := oField:value:value		
			cValue := Eval(&("{||" + cMasterAlias + "->" + oField + "}"))
			Exit
		EndIf		                                           		
	Next nCountFields                                          
	//Verifica se o campo pertence ao relacionamento de tabelas
	For nCountFields := 1 To Len(obj:aRelations)
		If AllTrim(obj:detail:pkFields[nCount]:name) == AllTrim(obj:aRelations[nCountFields]:detail:name)		
			cValue := Eval(&("{||" + cMasterAlias + "->" + obj:aRelations[nCountFields]:master:name + "}"))			
		EndIf
	Next nCountFields	
	cSeek += cValue	
Next nCount  

DbSelectArea(cAlias)
DbSetOrder(obj:master:iIdx) 
If DbSeek(RTrim(cSeek))
	Self:fillDetail(obj, cAlias, "{||" + cWhere + "}")
Else
	lRet := .F.
EndIF

Return lRet                  

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
FUNCTION _TMKA505G()
RETURN NIL
