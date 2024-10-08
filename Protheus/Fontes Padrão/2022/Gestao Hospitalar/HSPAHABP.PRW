#INCLUDE "HSPAHABP.ch"
#include "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHABP  �Autor  �Mario Arizono       � Data �  02/03/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Faixa Etaria.                                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Administracao Hospitalar                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function HSPAHABP()

Private nOpc      := 0
Private cCadastro := STR0001 //"Cadastro de Faixa Etaria"
Private aRotina   := MenuDef()

If HS_LocTab("GHA")
	DbSelectArea("GHA")
	dbSetOrder(1)
	mBrowse(06, 01, 22, 75, "GHA")
	Return(Nil)
EndIf

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �HS_MntABP � Autor �Mario Arizono          � Data � 02/03/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Tratamento das funcoes.                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function HS_MntABP(cAliasABP, nRegABP, nOpcABP)
 Local nOpcDlg := 0
 Local aSize   := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local nGDOpc 	:= IIF(aRotina[nOpcABP, 4] == 3 .Or. aRotina[nOpcABP, 4] == 4, GD_INSERT + GD_UPDATE + GD_DELETE, 0)

 Private oEnGHA, oGHC
 Private aCGHC := {}, aHGHC := {}, nUGHC := 0, nLGHC := 0  
 Private nGHCCodPro := 0, nGHCCDGAte := 0
 
 Private aTela := {}, aGets := {}

 aSize 			:= MsAdvSize(.T.)
 aObjects := {}
 AAdd( aObjects, { 100, 040, .T., .T. } )
 AAdd( aObjects, { 100, 060, .T., .T. } )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 RegToMemory("GHA", IIf(aRotina[nOpcABP, 4] == 3, .T., .F.)) 
 
 HS_BDados("GHC", @aHGHC, @aCGHC, @nUGHC, 1,, IIf(aRotina[nOpcABP, 4] # 3, "'" + M->GHA_CDFETA + "' == GHC->GHC_CDFETA", Nil))
 nGHCCodPro := aScan(aHGHC, {| aVet | aVet[2] == "GHC_CODPRO"})
 nGHCCDGAte := aScan(aHGHC, {| aVet | aVet[2] == "GHC_CDGATE"})

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel

  oEnGHA := MsMGet():New("GHA", nRegABP, nOpcABP,,,,, aPObjs[1],, 2,,,, oDlg)
  oEnGHA:oBox:align := CONTROL_ALIGN_TOP
  
  oGHC := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc, "HS_DuplAC(oGHC:oBrowse:nAt, oGHC:aCols, {nGHCCODPRO})",,,,, 99999,,,, oDlg, aHGHC, aCGHC)
  oGHC:bLinhaOk      := {|| HS_DuplAC(oGHC:oBrowse:nAt, oGHC:aCols, {nGHCCODPRO}) }         
  oGHC:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcDlg := 1, IIf(Obrigatorio(aGets, aTela) .and. FS_ABPOK(nOpcABP) .And. ;
 																																																					                   HS_TudoOK("GHC", oGHC, nGHCCODPRO), oDlg:End(), ;
 																																																					                   nOpcDlg := 0)}, ;
                                                  {|| nOpcDlg := 0, oDlg:End()})

 If nOpcDlg == 1 .AND. nOpcABP <> 2
 	FS_GrvGHA(nOpcABP)
 	FS_GrvGHC()
 EndIf

Return(Nil)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_GrvGHA � Autor �Mario Arizono          � Data � 02/03/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para gravacao dos registros.                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function FS_GrvGHA(nOpcABP)
Local lFoundGHA := .F.

If aRotina[nOpcABP, 4] <> 2
	Begin Transaction
	dbSelectArea("GHA")
	dbSetOrder(1) //faixa etaria
	lFoundGHA := DbSeek(xFilial("GHA") + M->GHA_CDFETA)
	
	If aRotina[nOpcABP, 4] <> 5
		RecLock("GHA",!lFoundGHA)
	 	HS_GrvCpo("GHA")
	 	GHA->GHA_FILIAL := xFilial("GHA")
	 	GHA->GHA_LOGARQ := HS_LOGARQ()
		MsUnlock()
	Else
		dbSelectArea("GHA")
		dbSetOrder(1)
		RecLock("GHA", .F.)
 		dbDelete()
		MsUnlock()
		WriteSx2("GHA")
	EndIf
	End Transaction
EndIf

Return(Nil)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �HS_VLDABP � Autor �Mario Arizono          � Data � 02/03/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validacao dos campos.                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION HS_VLDABP()
 Local aAreaOld := GetArea()
 Local lRet := .T.

If ReadVar() == "M->GHA_IDAINI"
	If M->GHA_IDAINI > M->GHA_IDAFIN .AND. !EMPTY(M->GHA_IDAFIN)
		HS_MsgInf(STR0007, STR0009, STR0015)   //"Idade Inicial nao pode ser maior que Idade Final"###"Atencao"###"Valida��o da faixa etaria"
		lRet := .F.
	ElseIf M->GHA_IDAINI == M->GHA_IDAFIN .AND. !EMPTY(M->GHA_IDAFIN)
		HS_MsgInf(STR0010, STR0009, STR0015)    //"Idade Inicial nao pode ser igual a Idade Final"###"Atencao"###"Valida��o da faixa etaria"
		lRet := .F.
	Endif
ElseIf Readvar() == "M->GHA_IDAFIN"
	If M->GHA_IDAINI > M->GHA_IDAFIN .AND. !EMPTY(M->GHA_IDAINI)
		HS_MsgInf(STR0007, STR0009, STR0015)   //"Idade Inicial nao pode ser maior que Idade Final"###"Atencao"###"Valida��o da faixa etaria"
		lRet := .F.
	ElseIf M->GHA_IDAINI == M->GHA_IDAFIN .AND. !EMPTY(M->GHA_IDAINI)
		HS_MsgInf(STR0011, STR0009, STR0015)    //"Idade Final nao pode ser igual a Idade Inicial"###"Atencao"###"Valida��o da faixa etaria"
		lRet := .F.
	Endif
	
ElseIf Readvar() == "M->GHC_CODPRO"
 If !(lRet := HS_SeekRet("GA7", "M->GHC_CODPRO", 1, .F., "GHC_DESPRO", "GA7_DESC",, .F.))
  HS_MsgInf(STR0016, STR0017, STR0018) //"C�digo do procedimento n�o encontrado."###"Aten��o"###"Valida��o do Procedimento"
 ElseIf !EMPTY(oGHC:aCols[oGHC:oBrowse:nAt, nGHCCDGAte])
  DbSelectArea("GHF")
  DbSetOrder(1)
  If !(lRet := DbSeek(xFilial("GHF") + M->GHC_CODPRO + oGHC:aCols[oGHC:oBrowse:nAt, nGHCCDGAte]))
   HS_MsgInf(STR0019, STR0017, STR0020)  //"C�digo do procedimento incompat�vel com o Grupo de Atendimento."###"Aten��o"###"Valida��o do Grupo Atendimento"
  EndIf  
 EndIf

ElseIf Readvar() == "M->GHC_CDGATE"
	If !(lRet := HS_SeekRet("GH3", "M->GHC_CDGATE", 1, .F., "GHC_DSGATE", "GH3_DSGATE",, .F.))
  HS_MsgInf(STR0021, STR0017, STR0020) //"C�digo do Grupo Atendimento n�o encontrado."###"Aten��o"###"Valida��o do Grupo Atendimento"
 Else
  DbSelectArea("GHF")
  DbSetOrder(1)
  If !(lRet := DbSeek(xFilial("GHF") + oGHC:aCols[oGHC:oBrowse:nAt, nGHCCodPro] + M->GHC_CDGATE))
   HS_MsgInf(STR0022, STR0017, STR0020)  //"C�digo do Grupo de Atendimento n�o cadastrado no produto."###"Aten��o"###"Valida��o do Grupo Atendimento"
  EndIf  
 EndIf

Endif

 RestArea(aAreaOld)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FS_ABPOK  � Autor �Mario Arizono          � Data � 02/03/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validacao do ok.                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_ABPOK(nOpc)

Local lRet 			  := .T.
Local nIdaIni   := 0 , nIdaFin := 0, nRegGHA := 0
Local cCond := "", cCdFeta := ""

If nOpc == 3 .OR. nOpc == 4
	nIdaIni := M->GHA_IDAINI
	nIdaFin := M->GHA_IDAFIN  
	cCdFeta := M->GHA_CDFETA
	
	cCond   := " GHA_IDAFIN > "+ ALLTRIM(STR(nIdaIni)) + " AND GHA_IDAINI < "+ ALLTRIM(STR(nIdaFin)) + " "
	cCond   += " AND GHA_CDFETA <> '"+ cCdFeta + "' "
	nRegGHA := HS_CountTB("GHA", cCond)
	If nRegGHA > 0
		HS_MsgInf(STR0013, STR0009, STR0015)  //"Ja existem intervalos com esta faixa etaria"###"Atencao"###"Valida��o da faixa etaria"
		lRet := .F.
	Endif
Endif

Return(lRet)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �HS_GrvGHC � Autor � Daniel Peixoto        � Data � 28/02/07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � GRAVA ARQUIVO DE REGRAS Faixa x Proc. Grp Atend.           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAHSP                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_GrvGHC()
 Local nItem 				:= 0
 Local aAreaOld  := GetArea()
 Local lAchou    := .F.
 
 For nItem := 1 To Len(oGHC:aCols)
  
  DbSelectArea("GHC")
  DbSetOrder(1) //CDFETA
  lAchou := IIf(!Empty(oGHC:aCols[nItem, nGHCCODPRO]), DbSeek(xFilial("GHC") + M->GHA_CDFETA + oGHC:aCols[nItem, nGHCCODPRO]), .F.)
  If oGHC:aCols[nItem, Len(oGHC:aCols[nItem])] .And. lAchou /* exclusao */
   RecLock("GHC", .F., .T.)
    DbDelete()
    MsUnlock()
   WriteSx2("GHC")
  Else   
   If !EMPTY(oGHC:aCols[nItem, nGHCCODPRO])
    RecLock("GHC", !lAchou)
     HS_GRVCPO("GHC", oGHC:aCols, oGHC:aHeader, nItem)
     GHC->GHC_FILIAL := xFilial("GHC")
     GHC->GHC_CDFETA := M->GHA_CDFETA
    MsUnlock()
   EndIf 
  EndIf 
 Next
 
 DbSelectArea(aAreaOld)
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
Local aRotina :=	{{OemToAnsi(STR0002), "axPesqui" , 0, 1, 0, nil},;  //"Pesquisar"
					 {OemToAnsi(STR0003), "HS_MntABP", 0, 2, 0, nil},;  //"Visualizar"
					 {OemToAnsi(STR0004), "HS_MntABP", 0, 3, 0, nil},;  //"Incluir"
					 {OemToAnsi(STR0005), "HS_MntABP", 0, 4, 2, nil},;  //"Alterar"
					 {OemToAnsi(STR0006), "HS_MntABP", 0, 5, 1, nil}}   //"Excluir" 
Return(aRotina)