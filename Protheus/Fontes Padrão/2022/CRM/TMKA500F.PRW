#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TSTableStructure�Autor�Michel Mosca    � Data �  09/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Descreve o relacionamento entre tabelas para teleatendi-   ��� 
���          �-mento.                                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/        
Class TSTableStructure
Data keyFields	//Chaves de relacionamento entre tabelas
Data master		//Tabela com cabe�alho de dados do atendimento
Data detail     //Tabela com detalhes do atendimento
Data oPersist	//Classe de acesso ao banco de dados 
Data aRelations //Relacionamentos entre as tabelas 
Data contactField	//Campo onde deve ser armazenado o c�digo do contato do atendimento   
Data entityName		//Campo onde ser� armazenado o nome da entidade selecionado pelo contato
Data entityKey		//Campo onde ser� armazenado a chave de busca da entidade do contato
Data entityIndex	//Campo onde � armazenado o n�mero do indice utilizado pela chave de busca
Data campaignKey	//Campo onde � armazenado o codigo da campanha
Data operationCode	//Campo onde � armazenado o tipo de opera��o. Normalmente: 1-Receptivo;2-Ativo
Data registerCode	//Campo onde � armazenado o Codigo Identificador do Atendimento
Data initGDField	//Campo a ser inicializado pela GetDados.

Method new() Constructor
Method addRelation(relation)
Method delRelation(relation)
Method load(keyInfo)
Method save()
Method delete()
Method createPersist()     
Method clear()
Method free()

End Class               

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Michel W. Mosca  � Data �  09/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class TSTableStructure             

Self:keyFields	:= {}    
Self:master     := TSTable():new()
Self:detail     := TSTable():new()
Self:oPersist 	:= Self:createPersist() 
Self:aRelations	:= {}    
Self:contactField := TSField():new()   
Self:entityName	:= TSField():new()   
Self:entityKey	:= TSField():new()   
Self:entityIndex:= TSField():new()   
Self:campaignKey:= TSField():new() 
Self:operationCode:= TSField():new() 
Self:registerCode  := TSField():new() 
Self:initGDField:= TSField():new() 

Return Self 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �addRelation  �Autor  �Michel W. Mosca  � Data �  09/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Adiciona uma rela��o entre duas tabelas. 				      ���
���          �                                                            ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                 
Method addRelation(relation) Class TSTableStructure 

aAdd(Self:aRelations, relation)
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �delRelation  �Autor  �Michel W. Mosca  � Data �  09/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Remove uma rela��o existente entre as tabelas.              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/  
Method delRelation(relation)Class TSTableStructure
Local nCount 

For nCount := 1 To Len(Self:aRelations)
	If Self:aRelations[nCount]:compareTo(relation)
		relation:deleted	:= .T.
		//aDel(Self:aRelations, nCount)	
		//aSize(Self:aRelations, Len(Self:aRelations)-1)
		Exit
	EndIf
Next nCount

Return Nil         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOAD      �Autor  �Michel W. Mosca     � Data �  09/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carregar os dados das tabelas cabe�alho e detalhe.          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method load(keyInfo) Class TSTableStructure
Local lRet := .F.  

If ValType(keyInfo) == "A" 
	Self:clear()
	lRet := Self:oPersist:load(Self, keyInfo)	
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SAVE      �Autor  �Michel W. Mosca     � Data �  09/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Salva os dados carregados atualmente nas tabelas do banco   ���
���          �de dados.                                                   ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method save() Class TSTableStructure
Local lRet := .F.                       

lRet := Self:oPersist:save(Self)         
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DELETE    �Autor  �Michel W. Mosca     � Data �  09/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Apaga os dados carregados atualmente das tabelas no         ���
���          �banco de dados.                                             ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method delete() Class TSTableStructure
Local lRet := .F.         
    
lRet := Self:oPersist:delete(Self)
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �createPersist �Autor  �Michel W. Mosca � Data �  09/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a classe de acesso ao banco de dados.               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method createPersist() Class TSTableStructure 
Local obj

#IFDEF TOP
	obj := TSTableStructureTop():New()	
#ELSE
	obj := TSTableStructureCodebase():New()
#ENDIF
Return obj 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �clear         �Autor  �Michel W. Mosca � Data �  24/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Limpa os registros das tabelas master e detail.             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method clear() Class TSTableStructure                       
Local lRet := .F.

Self:master:clearRecordSet()
Self:detail:clearRecordSet()
lRet := .T.
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    �free       	�Autor  �Vendas Clientes � Data �  30/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Libera a mem�ria dos objetos utilizados.    			 	  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method free() Class TSTableStructure                       
TMKFree( Self:keyFields )
TMKFree( Self:master )
TMKFree( Self:detail )
TMKFree( Self:oPersist )
TMKFree( Self:aRelations )
TMKFree( Self:contactField )
TMKFree( Self:entityName )
TMKFree( Self:entityKey )
TMKFree( Self:entityIndex )
TMKFree( Self:campaignKey )
TMKFree( Self:operationCode )
TMKFree( Self:registerCode )
TMKFree( Self:initGDField )
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �_TMKA500      �Autor  �Michel W. Mosca � Data �  09/11/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao dummy apenas para o programa aparecer no inspetor de ���
���          �objetos                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                   
FUNCTION _TMKA500F()
RETURN NIL