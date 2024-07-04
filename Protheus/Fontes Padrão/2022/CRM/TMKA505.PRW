#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPersistTeleServicingบAutor  ณMichel Mosca     บ Data ณ  01/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     |Classe abstrata contemplando as funcionalidades comuns utilizadas  บฑฑ 
ฑฑบ          ณno acesso ao banco de dados.                                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class PersistTeleServicing From Persist

Method save(obj)   
Method delete(obj)
Method fillClass(obj)               
Method fillRelations(obj, cAlias)
Method UpdateDBFields(obj)
Method UpdateDBRelFields(obj)
EndClass                               

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณUpdateDBFieldsบAutor  ณMichel W. Mosca บ Data ณ  01/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza os campos da tabela.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method UpdateDBFields(obj) Class PersistTeleServicing 
         
REPLACE SKA->KA_NOME 	WITH obj:name 
REPLACE SKA->KA_FILIAL	WITH xFilial("SKA")
REPLACE SKA->KA_ABRTELA	WITH obj:whenOpenWindow:codeBlock
REPLACE SKA->KA_PEBTNOK	WITH obj:whenPressedOKBtn:codeBlock
REPLACE SKA->KA_CONTSEL	WITH obj:whenSelectContact:codeBlock
REPLACE SKA->KA_PEHIST 	WITH obj:whenPressedHistory:codeBlock
REPLACE SKA->KA_PEGDIT	WITH obj:validGDItem:codeblock
REPLACE SKA->KA_ANTGRAV	WITH obj:whenRecord:codeBlock
REPLACE SKA->KA_APOGRAV	WITH obj:whenRecorded:codeBlock
REPLACE SKA->KA_ENCTELA	WITH obj:whenCloseWindow:codeBlock
REPLACE SKA->KA_ALIDET	WITH obj:tableStructureInfo:detail:alias
REPLACE SKA->KA_ALIMAST	WITH obj:tableStructureInfo:master:alias
REPLACE SKA->KA_CPCONT	WITH obj:tableStructureInfo:contactField:name  
REPLACE SKA->KA_CPNMENT WITH obj:tableStructureInfo:entityName:name
REPLACE SKA->KA_CPCHAVE WITH obj:tableStructureInfo:entityKey:name
REPLACE SKA->KA_CPIDXCH WITH obj:tableStructureInfo:entityIndex:name
REPLACE SKA->KA_CPGDINI	WITH obj:tableStructureInfo:initGDField:name
REPLACE SKA->KA_CMPKEY	WITH obj:tableStructureInfo:campaignKey:name
REPLACE SKA->KA_OPCODI	WITH obj:tableStructureInfo:operationCode:name
REPLACE SKA->KA_REGCOD	WITH obj:tableStructureInfo:registerCode:name
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออัออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณUpdateDBRelFieldsบAutorณMichel W. Mosca บ Data ณ 01/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออฯออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza os campos da tabela de relacoes.                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method UpdateDBRelFields(obj) Class PersistTeleServicing 
         

REPLACE SKB->KB_FILIAL	WITH xFilial("SKB")
REPLACE SKB->KB_CPOMAST	WITH obj:master:name
REPLACE SKB->KB_CPODET	WITH obj:detail:name
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfillClass     บAutor  ณMichel W. Mosca บ Data ณ  01/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreenche a classe com a regra de negocios.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method fillClass(obj, cAlias) Class PersistTeleServicing  

obj:id   				:= (cAlias)->KA_CODIGO
If cPaisLoc <> "BRA"
    
	Do Case 
		Case cPaisLoc $ "ARG|BOL|CHI|COL|COS|DOM|MEX|PAN|PAR|PER|POR|SAL|URU|VEN"
				obj:name 				:= (cAlias)->KA_NOMESPA
		Case cPaisLoc $ "EUA"
				obj:name 				:= (cAlias)->KA_NOMEENG
		Case cPaisLoc $ "ANG|EQU|HAI|PTG"	
				obj:name 				:= (cAlias)->KA_NOMEPTG
	EndCase

Else 
	obj:name 				:= (cAlias)->KA_NOME		
EndIf 
	
obj:whenOpenWindow		:= TSEntrancePoint():new() 
obj:whenOpenWindow:setCodeBlock((cAlias)->KA_ABRTELA)
obj:whenPressedOKBtn	:= TSEntrancePoint():new() 
obj:whenPressedOKBtn:setCodeBlock((cAlias)->KA_PEBTNOK)
obj:whenSelectContact	:= TSEntrancePoint():new()
obj:whenSelectContact:setCodeBlock((cAlias)->KA_CONTSEL)
obj:whenPressedHistory := TSEntrancePoint():new()
obj:whenPressedHistory:setCodeBlock((cAlias)->KA_PEHIST)
obj:whenRecord			:= TSEntrancePoint():new()
obj:whenRecord:setCodeBlock((cAlias)->KA_ANTGRAV)
obj:whenRecorded		:= TSEntrancePoint():new()
obj:whenRecorded:setCodeBlock((cAlias)->KA_APOGRAV)
obj:whenCloseWindow	:= TSEntrancePoint():new()  
obj:whenCloseWindow:setCodeBlock((cAlias)->KA_ENCTELA)
obj:validGDItem	:= TSEntrancePoint():new()  
obj:validGDItem:setCodeBlock((cAlias)->KA_PEGDIT)
obj:toolbarTop    		:= TSToolbarList():new()
obj:toolbarSide         := TSToolbarList():new()
obj:tableStructureInfo	:= TSTableStructure():new()
obj:tableStructureInfo:master:load(AllTrim((cAlias)->KA_ALIMAST),obj:id,.T.)
obj:tableStructureInfo:detail:load(AllTrim((cAlias)->KA_ALIDET),obj:id,.F.)
obj:tableStructureInfo:contactField:name := (cAlias)->KA_CPCONT
obj:tableStructureInfo:entityName:name 	:= (cAlias)->KA_CPNMENT
obj:tableStructureInfo:entityKey:name 	:= (cAlias)->KA_CPCHAVE
obj:tableStructureInfo:entityIndex:name	:= (cAlias)->KA_CPIDXCH
obj:tableStructureInfo:initGDField:name := (cAlias)->KA_CPGDINI
obj:tableStructureInfo:campaignKey:name := (cAlias)->KA_CMPKEY
obj:tableStructureInfo:operationCode:name := (cAlias)->KA_OPCODI
obj:tableStructureInfo:registerCode:name := (cAlias)->KA_REGCOD
Return obj                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfillRelations บAutor  ณMichel W. Mosca บ Data ณ  16/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreenche a classe com as relacoes de tabelas.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method fillRelations(obj, cAlias) Class PersistTeleServicing 
Local oRel 				//Objeto do tipo relacao 
Local oMasterField		//Objeto do tipo campo
Local oDetailField		//Objeto do tipo campo

While (cAlias)->(!EOF()) .AND. (cAlias)->KB_CODTELE == obj:id
	oRel 	:= TSRelation():new()
	oMasterField 	:= TSField():new()	
	oMasterField:name := (cAlias)->KB_CPOMAST	
	oRel:master := oMasterField	
	oDetailField	:= TSField():new()
	oDetailField:name := (cAlias)->KB_CPODET	
	oRel:detail	:= oDetailField 
	oRel:id 	:= (cAlias)->KB_CODIGO
	obj:tableStructureInfo:addRelation(oRel)
	(cAlias)->(DbSkip())	
End
Return obj    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSAVE      บAutor  ณMichel W. Mosca     บ Data ณ  01/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method save(obj) Class PersistTeleServicing
Local lRet := .F.    
Local nCount		//Contador utilizado em loop for

BEGIN TRANSACTION 
	DbSelectArea("SKA")
	DbSetOrder(1) //KA_FILIAL+KA_CODIGO
	If Empty(obj:id)
		//Insere SKA
		RecLock("SKA",.T.)
		Self:UpdateDBFields(obj)
		SKA->KA_CODIGO := GetSx8Num("SKA", "KA_CODIGO")				
		MsUnlock()                                         
		ConfirmSX8()
		obj:id := SKA->KA_CODIGO 
		obj:toolbarTop:setCodTele(obj:id)
		obj:toolbarSide:setCodTele(obj:id) 
		lRet := .T. 
	Else
		//Atualiza SKA       
		If DbSeek(xFilial("SKA") + obj:id)	
			RecLock("SKA",.F.)
			Self:UpdateDBFields(obj) 
			lRet := .T. 
		EndIf         	
	EndIf                                  

	//Insere/Atualiza SKB
	If lRet
		For nCount := 1 To Len(obj:tableStructureInfo:aRelations)		
			DbSelectArea("SKB")					     
			DbSetOrder(2) //KB_FILIAL+KB_CODTELE+KB_CODIGO
			If DbSeek(xFilial("SKB")+obj:id+obj:tableStructureInfo:aRelations[nCount]:id) .AND. obj:tableStructureInfo:aRelations[nCount]:id <> ""
				If !obj:tableStructureInfo:aRelations[nCount]:deleted
					RecLock("SKB",.F.)
					Self:UpdateDBRelFields(obj:tableStructureInfo:aRelations[nCount])									
				Else                  
					RecLock("SKB",.F., .T.)
					DbDelete()
				EndIf         
				MsUnlock()										
			Else
				RecLock("SKB",.T.)     
				Self:UpdateDBRelFields(obj:tableStructureInfo:aRelations[nCount])
				SKB->KB_CODIGO := GetSx8Num("SKB", "KB_CODIGO")							
				obj:tableStructureInfo:aRelations[nCount]:id := SKB->KB_CODIGO 		
				SKB->KB_CODTELE := obj:id
				MsUnlock()            							        
				ConfirmSX8()
			EndIf
		Next nCount	
	EndIf	
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
Method delete(obj) Class PersistTeleServicing
Local lRet := .F.

BEGIN TRANSACTION
	DbSelectArea("SKA")
	DbSetOrder(1) //KA_FILIAL+KA_CODIGO
	If DbSeek(xFilial("SKA")+obj:id)
		Reclock( "SKA" ,.F.,.T.)
		DbDelete()
		MsUnlock()		   
		lRet := .T.
	EndIf
	
	DbSelectArea("SKB")
	DbSetOrder(1) //KB_FILIAL+KB_CODTELE
	If DbSeek(xFilial("SKB")+obj:id)
		While !EOF() .AND. SKB->KB_CODTELE == obj:id
			Reclock( "SKB" ,.F.,.T.)
			DbDelete()
			MsUnlock()			   
			DbSkip()
		End	
	EndIf	
END TRANSACTION
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
FUNCTION _TMKA505()
RETURN NIL
