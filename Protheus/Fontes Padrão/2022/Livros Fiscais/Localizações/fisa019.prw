#Include "Protheus.ch"
#Include "Fisa019.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � FISA019  � Autor � Felipe C. Seolin   � Data �  05/08/10   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastro de Regi�es de Tributa��o			              ���
�������������������������������������������������������������������������͹��
���Uso       � Venezuela			                                      ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function FISA019()
	Local alArea		:= GetArea()
	Private aRotina		:= {}
	Private cCadastro	:= "Cadastro de Regi�es de Tributa��o"

	DBSelectArea("CCJ")
	CCJ->(DBSetOrder(1))
	CCJ->(DBGoTop())
	If CCJ->(EOF())
		CRIACCJ()
	EndIf
	aAdd(aRotina,{STR0001,"AxPesqui",0,1})
	aAdd(aRotina,{STR0002,"AxVisual",0,2})
	aAdd(aRotina,{STR0003,"AxInclui",0,3})
	aAdd(aRotina,{STR0004,"AxAltera",0,4})
	aAdd(aRotina,{STR0005,"AxDeleta",0,5})
	mBrowse(6,1,22,75,"CCJ",,,,,,)
	RestArea(alArea)
Return .T.