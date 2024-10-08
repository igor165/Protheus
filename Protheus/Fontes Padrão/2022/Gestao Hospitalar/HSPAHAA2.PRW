#INCLUDE "HSPAHAA2.ch"
#include "protheus.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAA2  � Autor � Cibele Peria       � Data �  03/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Cadastro de EQUIPE MEDICA                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HSPAHAA2()
 Private aRotina := MenuDef()
 												      		

 mBrowse(06, 01, 22, 75, "GME")
Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_AA2    � Autor � Cibele Peria       � Data �  03/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Tratamento das funcoes                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_AA2(cAlias,nReg,nOpc)
 Local nOpA := 0     //, nGDOpc := IIf(nOpc == 2 .Or. nOpc == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)

 Private aTela 					:= {}, aGets := {} 
 Private aHeader 			:= {}, aCols := {}, nUsado := 0
 Private oGMF
 Private lGDVazio := .F.
	
	RegToMemory("GME",(nOpc == 3)) // Gera variavies de memoria para o GME
	                   
	HS_BDados("GMF", @aHeader, @aCols, @nUsado, 1, M->GME_CODEQP, "'" + M->GME_CODEQP + "' == GMF->GMF_CODEQP")
 nGMF_CODATO := aScan(aHeader, {| aVet | aVet[2] == "GMF_CODATO"})
 nGMF_DESATO := aScan(aHeader, {| aVet | aVet[2] == "GMF_DESATO"})
 nGMF_CODCRM := aScan(aHeader, {| aVet | aVet[2] == "GMF_CODCRM"})
 nGMF_NOMCRM := aScan(aHeader, {| aVet | aVet[2] == "GMF_NOMCRM"})
	 
 nOpA := 0   
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 040, .T., .T. } )	
 AAdd( aObjects, { 100, 060, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )        
 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Equipes Medicas"
 
  // Monta a Enchoice
  oEnchoi := MsMGet():New("GME",nReg,nOpc, , , , ,{aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, , , , , ,oDlg)
  oEnchoi :oBox:align:= CONTROL_ALIGN_TOP    
 
  oGMF := MsGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nOpc,,, "", .T.) 
  oGMF:oBrowse:align := CONTROL_ALIGN_ALLCLIENT     
  
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpA := 1, ;
                                                                IIF(Obrigatorio(aGets, aTela) .And. FS_TudoOK(), oDlg:End(), nOpA == 0)}, ;  
                                                            {|| nOpA := 0, oDlg:End()})
   
 //ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar (oDlg, {|| nOpA := 1, ;
 //                                                               IIF(Obrigatorio(aGets, aTela) .And. ;
 //                                                                   FS_TudoOK("GM0",nGM0_CODCON) .And. ;
 //                                                                   FS_TudoOK("GM1",nGM1_CODUSU) .And. ;
 //                                                                   FS_TudoOK("GM2",nGM2_CODPRO) .And. ;
 //                                                                   FS_TudoOK("GMB",nGMB_CODTXD) .And. ;
 //                                                                   FS_VldExcL(M->GCS_CODLOC), ;
 //                                                                    oDlg:End(), nOpA == 0)}, ;  
 //                                                           {|| nOpA := 0, oDlg:End()})

 If nOpA == 1
  FS_GrvAA2(nOpc)
 EndIf
 
Return(Nil)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvAA2 � Autor � Cibele Peria       � Data �  06/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina de Atualizacao das tabelas                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_GrvAA2(nOpc)
 Local cAliasOld := Alias(), wProcura := .F., nForACols := 0, lAchou := .F.
 
 If nOpc # 2                          // nao for consulta
  DbSelectArea("GME")
  DBSetOrder(1)
  wProcura := dbseek(xFilial("GME") + M->GME_CODEQP)
  If Inclui .or. Altera 
   RecLock("GME", If(Altera, .F., .T.))
    HS_GRVCPO("GME")
   MsUnlock()
    
   If !lGDVazio
    For nForACols := 1 To Len(aCols)
     pForACols := nForACols
     DbSelectArea("GMF")
     DbSetOrder(1)
     lAchou := DbSeek(xFilial("GMF") + M->GME_CODEQP + aCols[pForACols, nGMF_CODATO] + aCols[pForACols, nGMF_CODCRM])
     If aCols[nForACols, nUsado + 1] .And. lAchou 																	// exclusao
      RecLock("GMF", .F., .T.)
       DbDelete()
      MsUnlock()
     Else
      If !aCols[nForACols, nUsado + 1]
       RecLock("GMF", !lAchou)
        HS_GRVCPO("GMF", aCols, aHeader, nForACols)
        GMF->GMF_FILIAL := xFilial("GMF")
        GMF->GMF_CODEQP := M->GME_CODEQP
        GMF->GMF_LOGARQ := HS_LogArq()
       MsUnlock()                  
      Endif 
     Endif
    Next
   Endif
  
  Else  // exclusao
   If wProcura
    If !lGDVazio
     For nForACols := 1 To Len(aCols)
      /*pForACols := nForDel*/
      DbSelectArea("GMF")
      DbSetOrder(1)
      If DbSeek(xFilial(cAliasOld) + M->GME_CODEQP )
       RecLock("GMF", .F., .T.)
       DbDelete()
       MsUnlock()
      Endif
     Next
    Endif
    
    DbSelectArea("GME")
    RecLock("GME", .F., .T.)
    	DBDelete()
    MsUnlock()
   Endif 
  Endif
 Endif              
 
Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � HS_VldAA2� Autor �Cibele Peria           � Data � 06/12/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rotina de validacao dos campos                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function HS_VldAA2()
 Local lRet := .T., cAliasOld := Alias()
 
 If ReadVar() == "M->GME_CODCRM"
  
  If !HS_SeekRet("SRA","ALLTRIM(M->GME_CODCRM)",11,.f.,"GME_NOMCRM","RA_NOME",,,.T.) 
   HS_MsgInf(STR0007,STR0008,STR0006) //"CRM do cirurgiao invalido"###"Atencao"###"Equipes Medicas"
   lRet := .F.
  EndIf

 ElseIf ReadVar() = "M->GMF_CODATO"
  If !HS_SeekRet("GMC","M->GMF_CODATO",1,.f.,"GMF_DESATO","GMC_DESATO",,,.T.) 
   HS_MsgInf(STR0009,STR0008,STR0006) //"Ato invalido"###"Atencao"###"Equipes Medicas"
   lRet := .F.   
  Endif

 ElseIf ReadVar() = "M->GMF_CODCRM"
  If !HS_SeekRet("SRA","ALLTRIM(M->GMF_CODCRM)",11,.f.,"GMF_NOMCRM","RA_NOME",,,.T.) 
   HS_MsgInf(STR0010, STR0008, STR0006) //"CRM do medico invalido"###"Atencao"###"Equipes Medicas"
   lRet := .F.
  EndIf  
   
 Endif
     
 DbSelectAre(cAliasOld)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_TudoOK � Autor � Cibele Peria       � Data �  06/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Verificacao de validade da confirmacao de atualizacao      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_TudoOK()
 Local lRet := .T., nForaCols := 1, lAchou := .F.

 If (lAchou := (aScan(aCols, {| aVet | aVet[nGMF_CODCRM] == M->GME_CODCRM .And. !aVet[nUsado + 1]}) > 0))
  If Len(aCols) == 1 .And. Empty(aCols[1,nGMF_CODATO]) .And. Empty(aCols[1,nGMF_CODCRM])
   lGDVazio = .T.
  Else 
   lRet := oGMF:TudoOK()
   lGDVazio = .F.  
  Endif
 Else
  HS_MsgInf(STR0011,STR0008,STR0006)    //"Medico Cirurgiao do Cabecalho ainda nao esta relacionado no Grid abaixo... favor cadastra-lo."###"Atencao"###"Equipes Medicas"
  lRet := .F.
 EndIf
  
Return(lRet)   


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Tiago Bandeira        � Data � 06/06/07 ���
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
Local aRotina :=	{{OemtoAnsi(STR0001), "axPesqui"	, 0, 1, 0, nil},;  //"Pesquisar"
                     {OemtoAnsi(STR0002), "HS_AA2"		, 0, 2, 0, nil},;  //"Visualizar"
 					 {OemtoAnsi(STR0003), "HS_AA2"		, 0, 3, 0, nil},;  //"Incluir"
 					 {OemtoAnsi(STR0004), "HS_AA2"		, 0, 4, 0, nil},;  //"Alterar"
 					 {OemtoAnsi(STR0005), "HS_AA2"		, 0, 5, 0, nil}}   //"Excluir"
Return(aRotina)