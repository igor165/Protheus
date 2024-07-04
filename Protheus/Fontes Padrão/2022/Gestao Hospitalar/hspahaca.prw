#INCLUDE "hspahaca.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHACA  � Autor � Daniel Peixoto     � Data �  18/02/08   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Vias de Acesso da Prescri��o                   ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHACA()

Private aRotina := MenuDef()

 If !HS_EXISDIC({{"T", "GFW"}})
  Return()
 Endif 
 
 DbSelectArea("GFW")
	mBrowse(06, 01, 22, 75, "GFW")
	
Return(Nil)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_ACA    � Autor � Daniel Peixoto     � Data �  18/02/08   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
                                                                            */
Function HS_ACA(cAlias, nReg, nOpc) 
Local nOpcA := 0

Private nOpcE    := aRotina[nOpc, 4]
Private aTela 		 := {}
Private aGets    := {}
Private aHeader  := {}
Private aCols    := {}
Private nUsado   := 0
Private oGFW
Private lGDVazio := .F.

RegToMemory("GFW", (nOpcE == 3)) 

nOpcA := 0

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd(aObjects, {100, 100, .T., .T.})

aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T.)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd  //"Cadastro de Vias de Acesso Prescri��o"

 oGFW := MsMGet():New("GFW", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGFW:oBox:align:= CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIF(nOpcE == 5, FS_ValExcl(), .T.), oDlg:End(), nOpcA == 0)}, ;
																																																		{|| nOpcA := 0, oDlg:End()})

If nOpcA == 1 .And. nOpcE <> 2
	FS_GrvACA(nOpcE)
EndIf

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvACA �Autor  �Daniel Peixoto      � Data �  18/02/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvACA(nOpcE)

If nOpcE == 3 .Or. nOpcE == 4 //Incluir e Alterar
	RecLock("GFW", (nOpcE == 3))
	HS_GrvCpo("GFW")
	MsUnlock()	
ElseIf nOpcE == 5 //Excluir
	RecLock("GFW", .F.)
	DbDelete()
	MsUnlock()
EndIf

Return(nOpcE)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_ValExcl�Autor  �Daniel Peixoto      � Data �  18/02/08   ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para validacao da exclusao.                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_ValExcl()

Local aArea := GetArea()
Local lRet	 := .T.

If nOpcE == 5 
 If HS_CountTB("GGD", "GGD_CODVIA = '" + GFW->GFW_CODVIA + "'")  > 0
 	HS_MsgInf(STR0007 + ". " + STR0008, STR0009, STR0010 ) //"O registro possui relacionamento com Apresenta��o de Diluente."###"Exclus�o n�o permitida"###"Aten��o"###"Valida��o de Exclus�o"
	 lRet := .F.	
 EndIf   

 If lRet 
  If HS_CountTB("GGA", "GGA_CODVIA = '" + GFW->GFW_CODVIA + "'")  > 0
 	 HS_MsgInf(STR0011, STR0009, STR0010) //"O registro possui relacionamento com Apresenta��o de Medicamento."###"Aten��o"###"Valida��o de Exclus�o"
	  lRet := .F.	 
	 EndIf 	 
	EndIf 
	
EndIf
 
RestArea(aArea)

Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Daniel Peixoto        � Data � 26/02/08 ���
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
Local aRotina := {{OemtoAnsi(STR0001)	, "axPesqui" , 0, 1}, ;  //"Pesquisar"
                    {OemtoAnsi(STR0002), "HS_ACA"		 	, 0, 2}, ;  //"Visualizar"
                    {OemtoAnsi(STR0003), "HS_ACA"		  , 0, 3}, ;  //"Incluir"
                    {OemtoAnsi(STR0004), "HS_ACA"		  , 0, 4}, ;  //"Alterar"
                    {OemtoAnsi(STR0005), "HS_ACA"		  , 0, 5} }  //"Excluir"

Return(aRotina)