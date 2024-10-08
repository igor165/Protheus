#INCLUDE "HSPAHA14.ch"
#include "PROTHEUS.CH"
#include "COLORS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA14  �Autor  �Antonio Marco       � Data �  27/10/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de hospitais. Utilizado nos emprestimos de MAT/MED;���
���          �do hospital p/ terceiros e vice versa.                      ���
�������������������������������������������������������������������������͹��
���Uso       �Administracao Hospitalar                                    ���
�������������������������������������������������������������������������ͼ��
���Altera��es� L.Gustavo Caloi 28/03/06 -> Padroniza��o da HS_MsgInf()    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHA14() 
Private nOpc      := 0                                                          
Private cCadastro := STR0001 //"Cadastro de Hospital"
Private aRotina   := MenuDef()

dbSelectArea("GFF")
dbSetOrder(1)
mBrowse(06, 01, 22, 75, "GFF")

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �HSAHA141  � Autor �Antonio Marco          � Data � 28/10/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de Inclusao/Alteracao/Visualizacao                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSAHA141(cAliasA14, nRegA14, nOpcA14)
Local nOpcDlg := 0
Local aSize   := {}, aObjects := {}, aInfo := {}, aPObjs := {}

Private oEnGFF
Private aTela := {}, aGets := {}

aSize 			:= MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

RegToMemory("GFF", IIf(aRotina[nOpcA14, 4] == 3, .T., .F.))

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel
oEnGFF := MsMGet():New("GFF", nRegA14, nOpcA14,,,,, aPObjs[1],, 2)
oEnGFF:oBox:align := CONTROL_ALIGN_ALLCLIENT
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcDlg := 1, IIf(Obrigatorio(aGets, aTela), oDlg:End(), nOpcDlg := 0)}, ;
{|| nOpcDlg := 0, oDlg:End()})

If nOpcDlg == 0 // cancelou?
	While __lSx8
		RollBackSxe()
	End
ElseIf aRotina[nOpcA14, 4] # 2 // nao eh pesquisa?
	FS_GravaGFF(nOpcA14)
EndIf

Return(Nil)

// Atualizacao do registro
Static Function FS_GravaGFF(nOpcA14)

// nao eh inclusao e o registro nao esta posicionado
If aRotina[nOpcA14, 4] # 3 .And. GFF->GFF_CODHOS # M->GFF_CODHOS
	dbSelectArea("GFF")
	dbSetOrder(1)
	DbSeek(xFilial("GFF") + M->GFF_CODHOS)
ElseIf aRotina[nOpcA14, 4] == 3
	M->GFF_CODHOS := HS_VSxeNum("GFF", "M->GFF_CODHOS", 1) // valida o codigo
EndIf

Begin Transaction
If aRotina[nOpcA14, 4] # 5 // nao eh exclusao?
	RecLock("GFF", aRotina[nOpcA14, 4] == 3) // inclcui e trava o registro (apenas na inclusao)
	HS_GrvCpo("GFF")
	GFF->GFF_LOGARQ := HS_LOGARQ()
	MsUnlock()
	ConfirmSx8()
Else
	// procura emprestimo para/do hospital
	dbSelectArea("GFG")
	dbSetOrder(2)
	
	lAchou = DbSeek(xFilial("GFG") + M->GFF_CODHOS)
	If lAchou
		HS_MsgInf(STR0007, STR0008, STR0006) //"Existem empr�stimos gerados para este hospital. Exclus�o n�o permitida""###"Aten��o"####"Excluir"
	Else
		dbSelectArea("GFF")
		dbSetOrder(1)
		RecLock("GFF", .F., .T.)
		dbDelete()
		MsUnlock()
		WriteSx2("GFF") // Atualiza a quantidade de registros deletados no SX2
	EndIf
EndIf
End Transaction

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Tiago Bandeira        � Data � 11/07/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Defini��o do aRotina (Menu funcional)                      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MenuDef()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()
//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Gera arquivo TXT para exportacao                      �
//�    4 - Recebe arquivo TXT                                    �
//����������������������������������������������������������������
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui", 0, 1, 0, nil},;	//"Pesquisar"
	                 {OemToAnsi(STR0003), "HSAHA141", 0, 2, 0, nil},;	//"Visualizar"
               		 {OemToAnsi(STR0004), "HSAHA141", 0, 3, 0, nil},;	//"Incluir"
		             {OemToAnsi(STR0005), "HSAHA141", 0, 4, 2, nil},;	//"Alterar"
		             {OemToAnsi(STR0006), "HSAHA141", 0, 5, 1, nil}}	//"Excluir" 
Return(aRotina)
