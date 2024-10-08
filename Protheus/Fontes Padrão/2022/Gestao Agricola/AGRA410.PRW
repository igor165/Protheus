#include 'AGRA410.CH'
#include 'protheus.ch'
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRA410  � Autor � Ricardo Tomasi     � Data �  21/07/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Padroes para Pedidos de Compras                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                        
Function AGRA410()
Private cCadastro := STR0001 //"Controle de Diaristas"
Private aRotina   := MenuDef()

dbSelectArea('NQF')
dbSetOrder(1)

mBrowse( 6, 1, 22, 75, 'NQF')

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRA410A � Autor � Ricardo Tomasi     � Data �  21/07/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina auxilial para montagem da tela de cadastro.         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AGRA410A(cAlias, nReg, nOpc)
Local aSize    := MsAdvSize()
Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj  := MsObjSize(aInfo,aObjects)
Local nOpcX    := aRotina[nOpc,4]
Local nOpcA    := 0
Local nY       := 0

Private aGets  := Array(0)
Private aTela  := Array(0,0)
Private oDlg
Private oEnch

If nOpcX==5
	If NQF->NQF_GERFIN == 'S'
		Alert('N�o � possivel excluir. Acerto ja fechado!')
		Return(.t.)
	EndIf
EndIf

RegToMemory('NQF',(nOpcX==3))

Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oEnch := MsMGet():New('NQF',,nOpcX,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA:=1, IIf(AGRA410B(nOpcX), oDlg:End(), nOpcA:=0) } , {|| nOpcA:=0, oDlg:End() })

If nOpcA==1 .And. (nOpcX==3 .Or. nOpcX==4 .Or. nOpcX==5)

	Begin Transaction
	dbSelectArea('NQF')
	dbSetOrder(1)
	dbSeek(xFilial('NQF')+M->NQF_CODMDO+DToS(M->NQF_DATA))
	If nOpcX==3 //Inclus�o
		If RecLock('NQF',.t.)
			For nY := 1 To FCount()
				&(FieldName(nY)) := &('M->'+FieldName(nY))
			Next nY
			NQF->NQF_FILIAL := xFilial('NQF')
			msUnLock()
		EndIf
		If __lSX8
			ConfirmSX8()
		EndIf
	EndIf
	If nOpcX==4 //Aletra��o
		If RecLock('NQF',.f.)
			For nY := 1 To FCount()
				&(FieldName(nY)) := &('M->'+FieldName(nY))
			Next nY
			msUnLock()
		EndIf
	EndIf
	If nOpcX==5 //Exclus�o
		If RecLock('NQF',.f.)
			dbDelete()
			msUnLock()
		EndIf
	EndIf
	End Transaction

Else
	If nOpcX==3
		If __lSX8
			RollBackSX8()
		EndIf
	EndIf
EndIf

Return()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � AGRA410B � Autor � Ricardo Tomasi     � Data �  21/07/2005 ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina auxilial para validar a tela de cadastro.           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function AGRA410B(nOpcX)
Local aAreaAt  := GetArea()
Local lRetorno := .t.

If nOpcX==3 .Or. nOpcX==4
	lRetorno := Obrigatorio(aGets,aTela)
EndIf

RestArea(aAreaAt)
Return(lRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MenuDef  �Autor  � Ricardo Tomasi     � Data �  04/10/2006 ���
�������������������������������������������������������������������������͹��
���Desc.     � Cria��o do menu.                                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Clientes Microsiga                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina:= {;
				 { STR0002 ,'AxPesqui',0,1} ,; //"Pesquisar"
				 { STR0003 ,'AGRA410A',0,2} ,; //"Visualizar"
				 { STR0004 ,'AGRA410A',0,3} ,; //"Incluir"
				 { STR0005 ,'AGRA410A',0,4} ,; //"Alterar"
				 { STR0006 ,'AGRA410A',0,5}  ; //"Excluir"
				 }
				 
Return(aRotina)
