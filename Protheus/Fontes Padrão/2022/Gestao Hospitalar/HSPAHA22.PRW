#INCLUDE "HSPAHA22.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "Colors.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA22  � Autor � Patricia Queiroz   � Data �  14/09/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de Frequencia de Administracao                    ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHA22()
 
 Private aRotina := MenuDef()
                    
 If HS_LocTab("GFZ")
  DbSelectArea("GFZ")
  mBrowse(06, 01, 22, 75, "GFZ") 
 EndIf  
 
Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_A22    � Autor � Patricia Queiroz   � Data �  14/09/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
                                                                            */
Function HS_A22(cAlias, nReg, nOpc) 

 Local nOpcA := 0

 Private nOpcE    := aRotina[nOpc, 4]
 Private aTela 		 := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private nUsado   := 0
 Private oGFZ
 Private lGDVazio := .F.
 
 RegToMemory("GFZ", (nOpcE == 3)) 

 nOpcA := 0

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 100, .T., .T.})

 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd //"Frequ�ncia de Administra��o"

 oGFZ := MsMGet():New("GFZ", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
 oGFZ:oBox:align:= CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. IIF(nOpcE == 5, FS_ValEx(), .T.), oDlg:End(), nOpcA == 0)}, ;
                                                      {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1 .And. nOpcE <> 2
  Begin Transaction
   FS_GrvA22(nOpcE)
  End Transaction 
  While __lSx8
   ConfirmSx8()
  EndDo  
 Else
  While __lSx8
   RollBackSx8()
  EndDo     
 EndIf

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvA22 �Autor  �Patricia Queiroz    � Data �  14/09/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Trava tabela para Inclusao, Alteracao e Exclusao.           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_GrvA22(nOpcE)

If nOpcE == 3 .Or. nOpcE == 4 //Incluir e Alterar
 If nOpcE == 3
  M->GFZ_CDFRQA := HS_VSxeNum("GFZ", "M->GFZ_CDFRQA", 1)
 Endif 
 RecLock("GFZ", (nOpcE == 3))
 HS_GrvCpo("GFZ")
 MsUnlock()	
ElseIf nOpcE == 5 //Excluir
 RecLock("GFZ", .F.)
 DbDelete()
 MsUnlock()
EndIf

Return(nOpcE)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_ValExAl�Autor  �Patricia Queiroz    � Data �  14/09/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para validar a exclusao e alteracao.                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                           
Static Function FS_ValEx()
 Local aArea := GetArea()
 Local lRet	 := .T.

 If HS_ExisDic({{"T", "GGB"}})  
  If HS_CountTB("GGB", "GGB_CDFRQA = '" + GFZ->GFZ_CDFRQA + "'")  > 0
  	HS_MsgInf(STR0007 + " " + STR0020, STR0008, STR0009)//"O registro possui relacionamento com Posologia de Medicamento."###"Exclus�o n�o permitida"###"Aten��o"###"Valida��o de Exclus�o" 
   lRet := .F.	
  EndIf
 Endif 
 RestArea(aArea)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_VldA22 �Autor  �Patricia Queiroz    � Data �  14/09/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para validacao dos campos.                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_VldA22()
 Local lRet  := .T.
 Local aArea := GetArea()

 If lRet := IIF(Altera, FS_VldAlt(), .T.)
 
  If ReadVar() == "M->GFZ_UNFRQA"
   M->GFZ_DUFRQA := 0
   M->GFZ_PEFRQA := 0
 
  ElseIf ReadVar() == "M->GFZ_DUFRQA"
   If lRet := (M->GFZ_DUFRQA >= 0)
    If M->GFZ_UNFRQA == "H" .And. !(lRet := M->GFZ_DUFRQA <= 24)
     HS_MsgInf(STR0011, STR0008, STR0010) //"A Dura��o n�o pode ser maior que 24 horas!"###"Aten��o"###"Valida��o de Inclus�o"    		         
    ElseIf M->GFZ_UNFRQA == "M" .And. !(lRet := M->GFZ_DUFRQA <= 1440)
     HS_MsgInf(STR0012, STR0008, STR0010) //"A Dura��o n�o pode ser maior que 1440 minutos!"###"Aten��o"###"Valida��o de Inclus�o"    		         
    Else
     M->GFZ_PEFRQA := 0
    EndIf 
   EndIf
       
  ElseIf ReadVar() == "M->GFZ_PEFRQA"
   If lRet := (M->GFZ_PEFRQA >= 0)
    If M->GFZ_UNFRQA == "H" .And. !(lRet := M->GFZ_PEFRQA <= 24)
     HS_MsgInf(STR0013, STR0008, STR0010) //"O Per�odo n�o pode ser maior que 24 horas!"###"Aten��o"###"Valida��o de Inclus�o"    		      
    ElseIf M->GFZ_UNFRQA == "M" .And. !(lRet := M->GFZ_PEFRQA <= 1440)
     HS_MsgInf(STR0014, STR0008, STR0010) //"O Per�odo n�o pode ser maior que 1440 minutos!"###"Aten��o"###"Valida��o de Inclus�o"    		     
    ElseIf !(lRet := M->GFZ_PEFRQA <= M->GFZ_DUFRQA)
     HS_MsgInf(STR0015, STR0008, STR0010) //"O Per�odo n�o pode ser maior que a Dura��o!"###"Aten��o"###"Valida��o de Inclus�o"    		  
    ElseIf !(lRet := Mod(M->GFZ_DUFRQA, M->GFZ_PEFRQA) == 0)
     HS_MsgInf(STR0016, STR0008, STR0010) //"O valor informado no per�odo deve ser m�ltiplo do valor informado na Dura�ao!"###"Aten��o"###"Valida��o de Inclus�o"    
    EndIf
   Endif 
  EndIf
  
 EndIf
 
 RestArea(aArea)

Return(lRet)    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VldAlt �Autor  �Patricia Queiroz    � Data �  14/09/06   ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para validacao dos campos que podem ser alterados.   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function FS_VldAlt()
 
 Local lRet  := .T.
 Local aArea := GetArea()
 
 If HS_ExisDic({{"T", "GGB"}})  
  If HS_CountTB("GGB", "GGB_CDFRQA = '" + GFZ->GFZ_CDFRQA + "'") > 0
   HS_MsgInf(STR0017, STR0008, STR0018) //"O campo n�o pode ser alterado, pois possui relacionamento com Posologia de Medicamento"###"Aten��o"###"Valida��o de Altera��o"   
   lRet := .F.	
  EndIf        
 Endif
 RestArea(aArea)
 
Return(lRet)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �HS_Dupl22 � Autor �Daniel Peixoto         � Data � 29/12/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validar duplicidade.                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function HS_Dupl22()
Local lRet := .T.

If Hs_SeekRet("GFZ", "M->GFZ_CDFRQA", 1, .F.,,,,, .T.)
 Hs_MsgInf(STR0019, STR0008, STR0010) //"Este c�digo j� existe"###"Aten��o"###"Valida��o de Inclus�o"
 lRet := .F.
EndIf

Return(lRet)


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
Local aRotina :=	{{OemtoAnsi(STR0001), "axPesqui"	, 0, 1, 0, nil},; //"Pesquisar"
                     {OemtoAnsi(STR0002), "HS_A22"		, 0, 2, 0, nil},; //"Visualizar"
                     {OemtoAnsi(STR0003), "HS_A22"		, 0, 3, 0, nil},; //"Incluir"
                     {OemtoAnsi(STR0004), "HS_A22"		, 0, 4, 0, nil},; //"Alterar"
                     {OemtoAnsi(STR0005), "HS_A22"		, 0, 5, 0, nil}}  //"Excluir" 
Return(aRotina)