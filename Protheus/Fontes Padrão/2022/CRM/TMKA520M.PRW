#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PersistWFTemplate  �Autor�Vendas Cliente�Data �  19/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     � Acesso a base de dados.                                    ��� 
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/      
Class PersistWFTemplate
        
	Method fillClass(obj, cAlias)
EndClass              
          
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fillClass     �Autor  �Vendas Cliente  � Data �  19/01/08   ���
�������������������������������������������������������������������������͹��
���Desc.     �Preenche a classe com a regra de negocios.                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method fillClass(obj, cAlias) Class PersistWFTemplate
	obj:htmlFile 		:= (cAlias)->KY_HTML	
	obj:cbTo 			:= (cAlias)->KY_TO
	obj:cbCC 			:= (cAlias)->KY_CC
	obj:cbCCO 			:= (cAlias)->KY_CCO
	obj:wfType 	   		:= (cAlias)->KY_TPWF
	obj:cbWhenReplied 	:= (cAlias)->KY_CBREPLY 
	          
	DbSelectArea("SKY")
	If (cAlias)->KY_ANEXA == "1"
		obj:lAttachFile := .T.
	Else
		obj:lAttachFile := .F.
	EndIf

	If (cAlias)->KY_SAVANEX == "1"
		obj:lSaveFile := .T.
	Else
		obj:lSaveFile := .F.
	EndIf	
	
	If (cAlias)->KY_MULTIAP == "1"
		obj:lMultiAprov := .T.
	Else
		obj:lMultiAprov := .F.
	EndIf

	obj:cMultiCon := (cAlias)->KY_MULTICO 

	obj:nMultiVal := (cAlias)->KY_MULTIVA

	obj:nTimeLim := (cAlias)->KY_TEMPOLI				

	obj:cTimeAnwser := (cAlias)->KY_TEMPORE

Return .T.
