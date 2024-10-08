#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TeleServicing�Autor  �Michel Mosca     � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Respons�vel pelo processo de controle e seq��ncia de	  ��� 
���          �execu��o de um modelo de atendimento, pontos de entradas,   ���
���          �bot�es no toolbar, carga e grava��o das tabelas de	 	  ���
���          �cabe�alho e detalhe. Utilizado na cria��o do modelo de 	  ���
���          �atendimento por um configurador bem como na apresenta��o 	  ���
���          �do modelo de atendimento para o usu�rio.					  ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������     
*/
Class TeleServicing

Data id					//Identificador do Modelo de Atendimento
Data name				//Nome do Modelo de Atendimento
Data whenOpenWindow		//Ponto de entrada executado quando a tela e aberta
Data whenPressedOKBtn 	//Ponto de entrada executado quando o usuario clica no botao OK
Data whenSelectContact 	//Ponto de entrada executado quando um contato e selecionado
Data whenPressedHistory //Ponto de entrada executado quando o usuario seleciona a tela de historico
Data whenRecord  		//Ponto de entrada executado no inicio do processo de gravacao do atendimento
Data whenRecorded  		//Ponto de entrada executado no fim do processo de gravacao do atendimento
Data whenCloseWindow 	//Ponto de entrada executado quando a tela de atendimento e encerrada
Data validGDItem		//Ponto de entrada para valida��o de linha digitada no item atual da GetDados
Data toolbarTop 		//Objeto que contem os botoes da barra de ferramentas superior
Data toolbarSide 		//Objeto que contem os botoes da barra de ferramentas lateral 
Data tableStructureInfo //Armazena as tabelas relacionadas ao atendimento.
Data oPersist           //Classe de acesso ao banco de dados


Method new() Constructor  
Method load(id)
Method save()
Method delete()
Method createPersist()
Method loadHistory(Obj, nType)
Method loadHistDetail(oObj, cCodMaster)
Method free()

End Class             

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �New          �Autor  �Michel W. Mosca  � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Metodo construtor da classe.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method new() Class TeleServicing     

Self:id 				:= ""
Self:name 				:= PAD("", 30, " ")
Self:oPersist 			:= Self:createPersist() 
Self:whenOpenWindow		:= TSEntrancePoint():new()
Self:whenPressedOKBtn	:= TSEntrancePoint():new()
Self:whenSelectContact	:= TSEntrancePoint():new()
Self:whenPressedHistory	:= TSEntrancePoint():new()
Self:whenRecord			:= TSEntrancePoint():new()
Self:whenRecorded		:= TSEntrancePoint():new()
Self:whenCloseWindow	:= TSEntrancePoint():new() 
Self:validGDItem		:= TSEntrancePoint():new() 
Self:toolbarTop    		:= TSToolbarList():new()
Self:toolbarTop:listType 	:= "1"
Self:toolbarSide       	:= TSToolbarList():new()
Self:tableStructureInfo := TSTableStructure():new()
Self:toolbarSide:listType 	:= "2"
Return Self     


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LOAD      �Autor  �Michel W. Mosca     � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method load(id) Class TeleServicing  
Local lRet := .F.  

Self:id := id
lRet := Self:oPersist:load(Self)
If !lRet 
	Self:id := ""
Else
	Self:toolbarTop:load(Self:id, "1")		
	Self:toolbarSide:load(Self:id, "2")	
EndIf
Return lRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �loadHistor�Autor  �Vendas Clientes     � Data �  07/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method loadHistory(Obj, nType) Class TeleServicing  
Local aRet := {}      

Default nType := 1 // 1 - Contato / 2 - Entidade

aRet := Self:oPersist:loadHistory(Obj, nType)

Return aRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �loadHistDe�Autor  �Vendas Clientes     � Data �  12/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method loadHistDetail(oObj, cCodMaster) Class TeleServicing
Local aRet := {}

aRet := Self:oPersist:loadHistDetail(oObj, cCodMaster)

Return aRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SAVE      �Autor  �Michel W. Mosca     � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method save() Class TeleServicing
Local lRet := .F.                       

lRet := Self:oPersist:save(Self)         
If lRet
	Self:toolbarTop:save()		
	Self:toolbarSide:save()
EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �DELETE    �Autor  �Michel W. Mosca     � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method delete() Class TeleServicing
Local lRet := .F.         
    
lRet := Self:oPersist:delete(Self)
If lRet
	Self:toolbarTop:deletAll()		
	Self:toolbarSide:deletAll()
EndIf
Return lRet
            
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �createPersist �Autor  �Michel W. Mosca � Data �  01/10/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna a classe de acesso ao banco de dados.               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP10                                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method createPersist() Class TeleServicing 
Local obj

#IFDEF TOP
	obj := TeleServicingTop():New()
#ELSE
	obj := TeleServicingCodebase():New()
#ENDIF
Return obj                                  
         
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
Method free() Class TeleServicing

TMKFree( Self:oPersist )
TMKFree( Self:whenOpenWindow )
TMKFree( Self:whenPressedOKBtn )
TMKFree( Self:whenSelectContact )
TMKFree( Self:whenPressedHistory )
TMKFree( Self:whenRecord )
TMKFree( Self:whenRecorded )
TMKFree( Self:whenCloseWindow )
TMKFree( Self:validGDItem )
TMKFree( Self:toolbarTop )
TMKFree( Self:toolbarSide )
TMKFree( Self:tableStructureInfo )

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
FUNCTION _TMKA500()
RETURN NIL
  

