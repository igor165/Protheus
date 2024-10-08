#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PersistWFI�Autor  �Vendas Clientes     � Data �  06/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Classe abstrata contemplando as funcionalidades comuns uti- ���
���          �lizadas no acesso ao banco de dados.                        ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Class PersistWFInformation From Persist
       
Method fillClass(obj,cAlias)    
Method UpdateDBFields(obj)
Method save(obj)   
Method delete(obj)

EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fillClass     �Autor  �Vendas Clientes � Data �  14/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por preencher a classe com a regra de    ���
���          �negocio.                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method fillClass(obj, cAlias) Class PersistWFInformation

obj:id   				:= (cAlias)->KW_CODIGO
obj:codProtheusUser		:= (cAlias)->KW_USER
obj:emailUser			:= (cAlias)->KW_EMAIL
obj:subject				:= (cAlias)->KW_SUBJECT
obj:userInfo			:= ""
obj:codeBlockWhenReplied:= TSEntrancePoint():new()
obj:codeBlockWhenReplied:setCodeBlock((cAlias)->KW_CODEBLK)
If SKW->(FieldPos("KW_LOTEAPR")) > 0 
	obj:cLoteApr			:= (cAlias)->KW_LOTEAPR
EndIf
If SKW->(FieldPos("KW_MODELO")) > 0 
	obj:cModelo			:= (cAlias)->KW_MODELO
EndIf
If SKW->(FieldPos("KW_DATE")) > 0 
	obj:dDate			:= (cAlias)->KW_DATE
EndIf
If SKW->(FieldPos("KW_TIME")) > 0 
	obj:cTime			:= (cAlias)->KW_TIME
EndIf
obj:internalID			:= (cAlias)->KW_INTERID
If ( obj:wfType == 2 )
	obj:wfIsAuthorized := IIf( (cAlias)->KW_AUTORIZ == "1", .T., .F. )
	If ValType(obj:wfIsWaiting) <> Nil
		If Empty((cAlias)->KW_AUTORIZ)
			obj:wfIsWaiting := .T.	
		EndIf	
	EndIf
		
EndIf

Return obj

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �UpdateDBFields�Autor  �Vendas Clientes � Data �  14/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza os campos da tabela de Workflow                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method UpdateDBFields(obj) Class PersistWFInformation
         
REPLACE SKW->KW_FILIAL	WITH xFilial("SKW")
REPLACE SKW->KW_USER 	WITH obj:codProtheusUser
REPLACE SKW->KW_EMAIL  	WITH obj:emailUser
REPLACE SKW->KW_SUBJECT	WITH obj:subject
REPLACE SKW->KW_CODEBLK	WITH obj:codeBlockWhenReplied:codeBlock
REPLACE SKW->KW_INTERID	WITH obj:internalID
If SKW->(FieldPos("KW_LOTEAPR")) > 0 
	REPLACE SKW->KW_LOTEAPR WITH obj:cLoteApr
EndIf
If SKW->(FieldPos("KW_MODELO")) > 0 
	REPLACE SKW->KW_MODELO WITH obj:cModelo
EndIf
If SKW->(FieldPos("KW_DATE")) > 0 
	REPLACE SKW->KW_DATE WITH obj:dDate
EndIf
If SKW->(FieldPos("KW_TIME")) > 0 
	REPLACE SKW->KW_TIME WITH obj:cTime
EndIf
If ( obj:wfType == 2 )
	If Empty(obj:id)	//Inclusao
		REPLACE SKW->KW_AUTORIZ WITH ""		//Aguardando aprovacao
	Else				//Alteracao
		REPLACE SKW->KW_AUTORIZ WITH IIf( obj:wfIsAuthorized == .T., "1", "2" )
	EndIf
Else
	REPLACE SKW->KW_AUTORIZ WITH "0"		//Workflow Informativo
EndIf
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �save      �Autor  � Vendas Clients     � Data �  14/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por salvar/atualizar o registro de WF na ���
���          �base de dados                                         	  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method save(obj) Class PersistWFInformation

Local lRet 	  := .F.	//Indica o retorno da funcao
Local cCodSKW := ""

BEGIN TRANSACTION 
	DbSelectArea("SKW")
	DbSetOrder(1) //KW_FILIAL+KW_CODIGO
	If Empty(obj:id)
		cCodSKW := GetSx8Num("SKW","KW_CODIGO")	
		While SKW->(DbSeek(xFilial("SKW")+cCodSKW)) 
			ConfirmSX8()
			cCodSKW := GetSx8Num("SKW","KW_CODIGO")
		EndDo
		ConfirmSX8()		
		//Inclusao SKW
		RecLock("SKW",.T.)
		SKW->KW_CODIGO := cCodSKW
		Self:UpdateDBFields(obj)
		MsUnlock()
		obj:id := SKW->KW_CODIGO 
		lRet := .T. 
	Else
		//Atualizacao do SKW 
		If DbSeek(xFilial("SKW") + obj:id)
			RecLock("SKW",.F.)
			Self:UpdateDBFields(obj) 
			lRet := .T. 
		EndIf         	
	EndIf                              
END TRANSACTION    

Return lRet                      


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �delete    �Autor  � Vendas Clientes    � Data �  14/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo responsavel por excluir o registro de Workflow da    ���
���          �base de dados                                         	  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method delete(obj) Class PersistWFInformation
Local lRet := .F.

BEGIN TRANSACTION

	DbSelectArea("SKW")
	DbSetOrder(1) 		//KW_FILIAL+KW_CODIGO
	If DbSeek(xFilial("SKW")+obj:id)
		Reclock( "SKW",.F.,.T.)
		DbDelete()
		MsUnlock()
		lRet := .T.
	EndIf
	
END TRANSACTION

Return lRet 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA520E     �Autor  �Vendas Clientes � Data �  06/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
FUNCTION _TMKA520E()

RETURN NIL
