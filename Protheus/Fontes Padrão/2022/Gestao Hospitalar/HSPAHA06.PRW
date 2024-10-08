#include "PROTHEUS.CH"
#include "HSPAHA06.CH"
#include "COLORS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHA06  �Autor  �Antonio Marco       � Data �  16/11/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de impressoras                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Gestao Hospitalar                                           ���
�������������������������������������������������������������������������ͼ��  
���Altera��es� L.Gustavo Caloi 28/03/06 -> Padroniza��o da HS_MsgInf()    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function HSPAHA06() 

Private nOpc      := 0                                                          
Private cCadastro := STR0001 // "Cadastro de Impressoras"
Private aRotina   := MenuDef()

dbSelectArea("GFJ")
dbSetOrder(1)
mBrowse(06, 01, 22, 75, "GFJ")

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �HSAHA061  � Autor �Antonio Marco          � Data � 16/11/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao de Inclusao/Alteracao/Visualizacao                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function HSAHA061(cAliasA06, nRegA06, nOpcA06)
 Local nOpcDlg := 0
 Local aSize   := {}, aObjects := {}, aInfo := {}, aPObjs := {}

 Private oEnGFJ
 Private aTela := {}, aGets := {}
 
 aSize 			:= MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 RegToMemory("GFJ", IIf(aRotina[nOpcA06, 4] == 3, .T., .F.))      
 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel
  oEnGFJ := MsMGet():New("GFJ", nRegA06, nOpcA06,,,,, aPObjs[1],, 2)                          
  oEnGFJ:oBox:align := CONTROL_ALIGN_ALLCLIENT
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcDlg := 1, IIf(Obrigatorio(aGets, aTela), oDlg:End(), nOpcDlg := 0)}, ;
                                                  {|| nOpcDlg := 0, oDlg:End()})

 If nOpcDlg != 0  // nao cancelou?
  FS_GravaGFJ(nOpcA06)
	EndIf
Return(Nil)

// Atualizacao do registro
Static Function FS_GravaGFJ(nOpcA06)
	Local lAchou                                             
	Local cCODIMP
	Local cIDIMPP

	// inclusao da impressora padrao
 If aRotina[nOpcA06, 4] == 3 .And. M->GFJ_IDIMPP == "1"
 	dbSetOrder(2)
  If DbSeek(xFilial("GFJ") + "1")
		 HS_MsgInf(STR0013, STR0011, STR0016) //"Ja existe a Impressora Padrao!"###"ATENCAO"###"Funcao de Inclusao/Alteracao/Visualizacao"

			// inclui a impressora como nao-padrao
		 M->GFJ_IDIMPP := "0"
  EndIf
 EndIf 

	// alteracao da impressora...
 If aRotina[nOpcA06, 4] == 4
		cCODIMP := GFJ->GFJ_CODIMP
		
		// ...de nao-padrao p/ padrao
	 If GFJ->GFJ_IDIMPP == "0" .And. M->GFJ_IDIMPP == "1"
	  dbSetOrder(2)
 	 lAchou := DbSeek(xFilial("GFJ") + "1")

	 	If lAchou .And. GFJ->GFJ_CODIMP != M->GFJ_CODIMP
 	 	HS_MsgInf(STR0013, STR0011, STR0016) //"Ja existe a Impressora Padrao!"###"ATENCAO"###"Funcao de Inclusao/Alteracao/Visualizacao"
		  Return(Nil)
 		EndIf

		 dbSetOrder(1)
			DbSeek(xFilial("GFJ") + cCODIMP)
		EndIf

		// ...de padrao p/ nao-padrao
	 If GFJ->GFJ_IDIMPP == "1" .And. M->GFJ_IDIMPP == "0"
	 	HS_MsgInf(STR0015, STR0011, STR0016)  //"Deve ser definida uma nova Impressora Padrao!"###"ATENCAO"###"Funcao de Inclusao/Alteracao/Visualizacao"
		EndIf
 EndIf

 Begin Transaction
  If aRotina[nOpcA06, 4] != 5 // nao eh exclusao?
   RecLock("GFJ", aRotina[nOpcA06, 4] == 3) // inclcui e trava o registro (apenas na inclusao)
    GFJ->GFJ_FILIAL := xFilial("GFJ")
    GFJ->GFJ_CODIMP := M->GFJ_CODIMP
    GFJ->GFJ_DESIMP := M->GFJ_DESIMP
    GFJ->GFJ_QTLFOL := M->GFJ_QTLFOL
    GFJ->GFJ_IDIMPP := M->GFJ_IDIMPP
  	 GFJ->GFJ_LOGARQ := HS_LOGARQ()
   MsUnlock()
  Else
			cIDIMPP = GFJ->GFJ_IDIMPP

   dbSelectArea("GFJ")  
   dbSetOrder(1)
	  RecLock("GFJ", .F., .T.)
    dbDelete()
 	 MsUnlock()
  	WriteSx2("GFJ") // Atualiza a quantidade de registros deletados no SX2

 		// excluida impressora padrao?
	  If cIDIMPP == "1"
	  	HS_MsgInf(STR0015, STR0011, STR0016) //"Deve ser definida uma nova Impressora Padrao!"###"ATENCAO"###"Funcao de Inclusao/Alteracao/Visualizacao"
 		EndIf
  EndIf
 End Transaction 

Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_ValidImp�Autor �Antonio Marco       � Data �  18/11/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Valida a existencia de uma impressora no cadastro se o      ���
���          �codigo da mesma for informado                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Gestao Hospitalar                                           ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_ValidaImp()
Local lRet   := .T.
Local cCampo := ReadVar()

If AllTrim(&(cCampo)) != ""
 dbSelectArea("GFJ")
 dbSetOrder(1)
 If !DbSeek(xFilial("GFJ") + AllTrim(&(cCampo)))
 	lRet := .F.
 EndIf
	DbCloseArea()
EndIf

// ATENCAO! A variavel cCODIMP deve ser definida no programa que
// que imprime o relatorio, como Private
cCODIMP := AllTrim(&(cCampo))

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
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui", 0, 1, 0, nil},;	// Pesquisar 
	                 {OemToAnsi(STR0003), "HSAHA061", 0, 2, 0, nil},;	// Visualizar
               		 {OemToAnsi(STR0004), "HSAHA061", 0, 3, 0, nil},;	// Incluir
		             {OemToAnsi(STR0005), "HSAHA061", 0, 4, 2, nil},;	// Alterar
		             {OemToAnsi(STR0006), "HSAHA061", 0, 5, 1, nil}}	// Excluir 
Return(aRotina)