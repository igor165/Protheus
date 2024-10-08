#INCLUDE "HSPAHAA3.ch"
#INCLUDE "protheus.CH"
#INCLUDE "TOPCONN.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSPAHAA3  � Autor � Cibele Peria       � Data �  07/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � CADASTRO DE DISPONIBILIDADE CIRURGICA                      ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Function HSPAHAA3()

 Private aRotina   := MenuDef()

  mBrowse(06, 01, 22, 75, "GMD")
Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | HS_AA3   � Autor � Cibele Peria       � Data �  07/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Manutecao de Disponibilide Cirurgica                       ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_AA3(cAlias, nReg, nOpc)

 Local nCntFor := 0, oEnc
 Local nOpcA := 0, nGDOpc := IIf(nOpc == 2 .Or. nOpc == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
 Local bFS_Facili	:= {||FS_FACILI()} // Facilitador para inclusao dos relacionamentos
 Local aButtons := {}, bKeyf4

 Private nGMG_DIASEM := 0, nGMG_IDEATI := 0, nLINGMG := 0
 Private nGMH_CODPLA := 0, nGMH_DESPLA := 0, nGMH_IDEATI := 0, nLINGMH := 0
 Private nGMI_CODPRO := 0, nGMI_DESPRO := 0, 	nGMI_IDEATI := 0, nLINGMI := 0
 Private oGMG, aHGMG := {}, aCGMG 	:= {}, nUGMG := 0
 Private oGMH, aHGMH := {}, aCGMH	 := {}, nUGMH := 0
 Private oGMI, aHGMI := {}, aCGMI	 := {}, nUGMI := 0, aHGMIW := {}, aCGMIW	:= {}
 Private oFolder, pForACols := 0
 Private aTela := {}, aGets := {}
 Private cGcsCodLoc := "", cGcsTipLoc := "", cGavTipo := "2"
  
//���������������������������������������Ŀ
//� Inclusao dos botoes dos facilitadores �
//�����������������������������������������
 Aadd(aButtons, {'PARAMETROS', {||Eval(bFS_FacILI)}, STR0034, STR0044}) //"Facilitador p/ inclus�o de itens no relacionamento"###"Itens"
 bKeyf4 :=	SetKey(VK_F4, { || Eval(bFS_Facili)})

//�������������������������������������������������������������Ŀ
//� Geracao dos atributos de memoria e dados para a NewGetDados �
//���������������������������������������������������������������
 RegToMemory(cAlias, nOpc == 3)
 
 HS_BDados("GMG", @aHGMG, @aCGMG, @nUGMG, 1, M->GMD_CODDIS, IIf(nOpc # 3, "'" + M->GMD_CODDIS + "' == GMG->GMG_CODDIS", Nil))
 nGMG_DIASEM := aScan(aHGMG, {| aVet | aVet[2] == "GMG_DIASEM"})
 nLINGMG := (IIf ( Len(aCGMG) == 1 .And. Empty(aCGMG[1, nGMG_DIASEM]), 0, Len(aCGMG) ))
 
 HS_BDados("GMH", @aHGMH, @aCGMH, @nUGMH, 1, M->GMD_CODDIS, IIf(nOpc # 3, "'" + M->GMD_CODDIS + "' == GMH->GMH_CODDIS", Nil))
 nGMH_CODPLA := aScan(aHGMH, {| aVet | aVet[2] == "GMH_CODPLA"})
 nGMH_DESPLA := aScan(aHGMH, {| aVet | aVet[2] == "GMH_DESPLA"})
 nLINGMH := (IIf ( Len(aCGMH) == 1 .And. Empty(aCGMH[1, nGMH_CODPLA]), 0, Len(aCGMH) ))
 
 HS_BDados("GMI", @aHGMI, @aCGMI, @nUGMI, 1, M->GMD_CODDIS, IIf(nOpc # 3, "'" + M->GMD_CODDIS + "' == GMI->GMI_CODDIS", Nil))
 nGMI_CODPRO := aScan(aHGMI, {| aVet | aVet[2] == "GMI_CODPRO"})
 nGMI_DESPRO := aScan(aHGMI, {| aVet | aVet[2] == "GMI_DESPRO"})
 nLINGMI := (IIf ( Len(aCGMI) == 1 .And. Empty(aCGMI[1, nGMI_CODPRO]), 0, Len(aCGMI)))
 
 If Inclui
  aHGMIW := aClone(aHGMI)
  aCGMIW := aClone(aCGMI)
 ElseIf Altera
  cGcsCodLoc := GMD->GMD_CODLOC
 Endif
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd(aObjects, {100, 040, .T., .T.})	
 AAdd(aObjects, {100, 060, .T., .T.,.T.})	
 
 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.) 
 
 aObjects := {}	
 AAdd(aObjects, {100, 100, .T., .T.})	
 
 aInfo := {aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0}
 aPGDs := MsObjSize(aInfo, aObjects, .T.)
  
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oMainWnd //"Disponibilidade Cir�rgica"

  oEnc:= MsMGet():New(cAlias, nReg, nOpc,,,,, aPObjs[1],,,,,, oDlg) 
  oEnc:oBox:Align := CONTROL_ALIGN_ALLCLIENT

 If nOpc == 3
  oEnc:AENTRYCTRLS[aScan(oEnc:aGets, {| aVet | "GMD_CODLOC" $ aVet})]:BGOTFOCUS := {|| FS_WhenCL("GMD_CODLOC")} 
  oEnc:AENTRYCTRLS[aScan(oEnc:aGets, {| aVet | "GMD_LOCATE" $ aVet})]:BGOTFOCUS := {|| FS_WhenCL("GMD_LOCATE")} 
 Endif  
  
  @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts STR0007, STR0008, STR0009 //"Dia da Semana"###"Planos n�o Atendidos"###"Procedimentos" 
  oFolder:Align := CONTROL_ALIGN_BOTTOM
  
  oGMG := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, , , , , , , , , , oFolder:aDialogs[1], aHGMG, aCGMG)
  oGMG:oBrowse:align := CONTROL_ALIGN_ALLCLIENT   
 
  oGMH := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, , , , , , 99999, , , , oFolder:aDialogs[2], aHGMH, aCGMH)
  oGMH:oBrowse:align := CONTROL_ALIGN_ALLCLIENT   
 
  oGMI := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, , , , , , 99999, , , , oFolder:aDialogs[3], aHGMI, aCGMI)
  oGMI:oBrowse:align := CONTROL_ALIGN_ALLCLIENT   
  nOpcA := 0
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela) .And. ;
                                                                             FS_VldExcD(M->GMD_CODDIS,nOpc) .And.     ;
                                                                             HS_TUDOOK("GMG",	oGMG, nGMG_DIASEM) .And. ; 
                                                                             HS_TUDOOK("GMH", oGMH, nGMH_CODPLA) .And. ;
                                                                             HS_TUDOOK("GMI", oGMI, nGMI_CODPRO) .And. ;
                                                                             FS_VldDisp() , ; 
                                                                            oDlg:End(), nOpcA := 0)},  ;
                                                            {|| nOpcA := 0, oDlg:End()},, aButtons)
 
 SetKey(VK_F4, bKeyF4)

 If nOpca == 1
	 FS_GrvAA3(nOpc)
 Else     
  While __lSx8
   RollBackSx8() 
  End 
 EndIf
 
Return(.T.)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_VldAA3 � Autor � Cibele Peria       � Data �  07/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao �  Valida os campos                                          ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar (Agenda Ambulatorial)                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_VldAA3()

Local lRet := .T., nPos := 0, nForACols := 0, cAliasOld := Alias(), lAchou := .F., cHorIni := ""

 If ReadVar() == "M->GMD_CODCRM"
  If !HS_SeekRet("SRA", "M->GMD_CODCRM", 11, .F., "GMD_NOMCRM", "RA_NOME",,, .T.)
   	HS_MsgInf(STR0014, STR0011, STR0006) //"CRM do m�dico inv�lido"###"Aten��o"###"Disponibilidade Cir�rgica"
   	lRet := .F.        
 	Else 
	  If !(HS_IniPadr("GBJ", 1, M->GMD_CODCRM, "GBJ_IDAGEN",, .F.) $ "1/2") // CIR/AMBOS
 	  HS_MsgInf(STR0043, STR0011, STR0006)  //"CRM do M�dico Inv�lido! M�dico n�o Habilitado para Incluir uma Disponibilidade"###"Aten��o"###"Disponibilidade Cir�rgica"
  	 lRet := .F.
	 	EndIf
 	EndIf
	
 ElseIf ReadVar() == "M->GMD_LOCATE"	
  If !HS_SeekRet("GCS", "M->GMD_LOCATE", 1, .F., "GMD_NLATEN", "GCS_NOMLOC",,, .T.) 
   HS_MsgInf(STR0010, STR0011, STR0006) //"Setor inv�lido"###"Aten��o"###"Disponibilidade Cir�rgica"
   lRet := .F.
  ElseIf GCS->GCS_IDEATI == "0"    
   HS_MsgInf(STR0012, STR0011, STR0006) //"Setor inativo"###"Aten��o"###"Disponibilidade Cir�rgica"
   lRet := .F.
  ElseIf GCS->GCS_TIPLOC <> "0"
   HS_MsgInf(STR0042, STR0011, STR0006)//"Este setor n�o � do interna��o."###"Aten��o"###"Disponibilidade Cir�rgica"
   lRet := .F.
  EndIf    
 
 ElseIf ReadVar() == "M->GMD_CODLOC"	
  If !HS_SeekRet("GCS", "M->GMD_CODLOC", 1, .F., "GMD_NOMLOC", "GCS_NOMLOC",,, .T.) 
   HS_MsgInf(STR0010, STR0011, STR0006) //"Setor inv�lido"###"Aten��o"###"Disponibilidade Cir�rgica"
   lRet := .F.
  ElseIf GCS->GCS_IDEATI == "0"    
   HS_MsgInf(STR0012, STR0011, STR0006) //"Setor inativo"###"Aten��o"###"Disponibilidade Cir�rgica"
   lRet := .F.
  ElseIf GCS->GCS_TIPLOC <> "4"
   HS_MsgInf(STR0013, STR0011, STR0006) //"Este setor n�o � do tipo cir�rgico."###"Aten��o"###"Disponibilidade Cir�rgica"
   lRet := .F.
  ElseIf !Empty(M->GMD_QUARTO)
   DbSelectArea("GAV")
   DbSetOrder(4) // GAV_FILIAL + GAV_QUARTO + GAV_TIPO
   If !DbSeek(xFilial("GAV") + M->GMD_QUARTO + "2" + M->GMD_CODLOC) 
    HS_MsgInf(STR0041, STR0011, STR0006) //"Quarto inv�lido para o setor informado"###"Aten��o"###"Disponibilidade Cir�rgica"
    lRet := .F.
   EndIf
  EndIf   
  If lRet
   cGcsCodLoc := GCS->GCS_CODLOC
   If Inclui
    oGMI:SetArray(aCGMIW)
    oGMI:oBrowse:Refresh()
   EndIf
  EndIf 
 	
 ElseIf ReadVar() == "M->GMD_QUARTO"
  If Empty(M->GMD_CODLOC)
   HS_MsgInf(STR0038, STR0011, STR0006) //"Por favor, informe o c�digo do setor"###"Aten��o"###"Disponibilidade Cir�rgica"
   lRet := .F.
  Else 
   DbSelectArea("GAV")
   DbSetOrder(4) // GAV_FILIAL + GAV_QUARTO + GAV_TIPO
   If DbSeek(xFilial("GAV") + M->GMD_QUARTO + "2" + M->GMD_CODLOC) 
    M->GMD_LEITO := GAV->GAV_LEITO
   Else 
    HS_MsgInf(STR0015, STR0011, STR0006) //"Quarto inv�lido ou n�o cir�rgico"###"Aten�o"###"Disponibilidade Cir�rgica"
    lRet := .F.
   EndIf
  EndIf 
 	
 ElseIf ReadVar() == "M->GMD_HORINI"
 	If !HS_VldHora(M->GMD_HORINI)
 		HS_MsgInf(STR0016, STR0011, STR0006) //"Hora inicial inv�lida"###"Aten��o"###"Disponibilidade Cir�rgica"
 		lRet := .F.
 	Else
 		If !Empty(M->GMD_HORFIM) .And. M->GMD_HORINI > M->GMD_HORFIM
 			HS_MsgInf(STR0017, STR0011, STR0006) //"Hora inicial maior que hora final"###"Aten��o"###"Disponibilidade Cir�rgica"
 			lRet := .F.
 		EndIf
 	EndIf
 	
 ElseIf ReadVar() == "M->GMD_HORFIM"
 	If !HS_VldHora(M->GMD_HORFIM)
 		HS_MsgInf(STR0018, STR0011, STR0006) //"Hora final inv�lida"###"Aten��o"###"Disponibilidade Cir�rgica"
 		lRet := .F.
 	Else
 		If !Empty(M->GMD_HORINI) .And. M->GMD_HORFIM < M->GMD_HORINI
 			HS_MsgInf(STR0019, STR0011, STR0006) //"Hora final menor que hora inicial."###"Aten��o"###"Disponibilidade Cir�rgica"
 			lRet := .F.
 		EndIf
 	EndIf
 	
 ElseIf ReadVar() == "M->GMD_INTMAR" 
  If !HS_VldHora(M->GMD_INTMAR) .Or. M->GMD_INTMAR == "00:00"
   HS_MsgInf(STR0020, STR0011, STR0006) //"Intervalo de marca��o inv�lido"###"Aten��o"###"Disponibilidade Cir�rgica"
 		lRet := .F.          
 	Else
 		cHorIni := HS_TotHoras(M->GMD_HORINI, M->GMD_HORFIM, "+", .T., .F.)    		
 		If !(lRet := !(M->GMD_INTMAR > cHorIni))
	   HS_MsgInf(STR0020, STR0011, STR0006) //"Intervalo de marca��o inv�lido"###"Aten��o"###"Disponibilidade Cir�rgica"
 		EndIf
 	EndIf  

 ElseIf ReadVar() == "M->GMG_DIASEM"
 	If M->GMG_DIASEM $ "12345678"
 		nPos := aScan(oGMG:aCols, {| aVet | aVet[nGMG_DIASEM] == M->GMG_DIASEM})
 		If nPos > 0 .And. nPos # oGMG:oBrowse:nAt
 			HS_MsgInf(STR0021, STR0011, STR0006) //"Dia da semana j� cadastrado"###"Aten��o"###"Disponibilidade Cir�rgica"
 			lRet := .F.
 		EndIf
 	Else
 		HS_MsgInf(STR0022, STR0011, STR0006) //"Dia da semana inv�lido"###"Aten��o"###"Disponibilidade Cir�rgica"
 		lRet := .F.
 	EndIf
 	
 ElseIf ReadVar() == "M->GMD_IDEATI"
 	If M->GMD_IDEATI == "1" .And. !Inclui
 		DbSelectArea("GM2")
 		DbSetOrder(1) // GM2_FILIAL + GM2_CODLOC + GM2_CODPRO
 		For nForACols := 1 To Len(oGMI:aCols)
 			If !DbSeek(xFilial("GM2") + M->GMD_CODLOC + oGMI:aCols[nForACols, nGMI_CODPRO])
 				MS_MsgInf(STR0023 + oGMI:aCols[nForACols, nGMI_CODPRO] + "/" + oGMI:aCols[nForACols, nGMI_DESPRO]+ ; //"O Procedimento ("
 				STR0024, STR0011, STR0006) //") n�o est� cadastrado em Setor x Procedimento"###"Aten��o"###"Disponibilidade Cir�rgica"
 				lRet := .F.
 			EndIf
 		Next
 		
 		DbSelectArea("GCM")
 		DBSetOrder(1) // GCM_FILIAL + GCM_CODCON + GCM_CODPLA
 		For nForACols := 1 To Len(oGMH:aCols)
 			If !DbSeek(xFilial("GCM") + oGMH:aCols[nForACols, nGMH_CODPLA] + oGMH:aCols[nForACols, nGMH_CODPLA])
 				HS_MsgInf(STR0025 + Trim(oGMH:aCols[nForACols, nGMH_CODPLA] + "/" + oGMH:aCols[nForACols, nGMH_NOMCON]) + ; //"O plano ("
 				STR0026, STR0011, STR0006) //") n�o est� cadastrado em Plano"###"Aten��o"###"Disponibilidade Cir�rgica"
 				lRet := .F.
 			EndIf
 		Next
 	Endif
 	             
// Foi definido nao fazer consistencia com o arquivo GM0-Setor X Plano nao atendido, permitindo que se
// inclua planos para a disponibildade independente do setor. Esta verificacao sera feita pela rotina de
// marcacao
 ElseIf ReadVar() == "M->GMH_CODPLA"																			// Valida Disp. x Planos Nao Atendidos
  If !HS_SeekRet("GCM", "M->GMH_CODPLA", 2, .F.,,,,, .T.) 
	 	HS_MsgInf(STR0027, STR0028, STR0006) //"Plano inv�lido"###"Verifique"###"Disponibilidade Cir�rgica"
	 	lRet := .F.
	 Else
	    GDFieldPut("GMH_DESPLA", HS_IniPadr("GCM", 2, M->GMH_CODPLA, "GCM_DESPLA",, .F.))	  
   nPos := aScan(oGMH:aCols, {| aVet | aVet[nGMH_CodPla] == M->GMH_CODPLA})
	 	If nPos > 0 .And. nPos # oGMH:oBrowse:nAt  // Verifica se este Plano ja foi cadastrado para a disponibilidade
	 		HS_MsgInf(STR0029, STR0011, STR0006) //"Plano j� cadastrado para esta disponibilidade"###"Aten��o"###"Disponibilidade Cir�rgica"
	 		lRet := .F.
	 	EndIf
	 EndIf

 ElseIf ReadVar() == "M->GMI_CODPRO"
 	If !HS_SeekRet("GM2", "M->GMD_CODLOC + M->GMI_CODPRO", 1, .F.,,,,, .T.)
 		HS_MsgInf(STR0030, STR0011, STR0006) //"Procedimento inv�lido ou n�o autorizado para este setor."###"Aten��o"###"Disponibilidade Cir�rgica"
 		lRet := .F.
 	Else
 		GDFieldPut("GMI_DESPRO", HS_IniPadr("GA7", 1, M->GMI_CODPRO, "GA7_DESC",, .F.))
 		nPos := aScan(oGMI:aCols, {| aVet | aVet[nGMI_CODPRO] == M->GMI_CODPRO})
 		If nPos > 0 .And. nPos # oGMI:oBrowse:nAt  // Verifica se este PROCEDIMENTO ja foi cadastrado
 			HS_MsgInf(STR0031, STR0011, STR0006) //"Procedimento j� cadastrado para esta disponibilidade"###"Aten��o"###"Disponibilidade Cir�rgica"
 			lRet := .F.
 		EndIf
 	EndIf
 	
 Endif
 
 DbSelectArea(cAliasOld)
Return(lRet)
 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VldExcD� Autor � Cibele Peria       � Data �  08/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina de Validacao da Exclusao de uma disponibilidade     ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_VldExcD(cCodDis,nOpc)

 Local lRet := .T., cAliasOld := Alias()
 
 DbSelectArea("GMJ")   //Agenda cirurgica
 DbSetOrder(2) //GMJ_FILIAL + GMJ_CODDIS + GMJ_DATAGE
 If DbSeek(xFilial("GMJ") + cCodDis )
  HS_MsgInf(STR0032, STR0033, STR0006) //"Existe agenda gerada para esta disponibilidade"###"Exclus�o n�o permitida"###"Disponibilidade Cir�rgica"
  lRet := .F.
 EndIf

 DbSelectArea(cAliasOld)
Return(lRet)   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_VldHora� Autor � Cibele Peria       � Data �  07/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina de Validacao da hora                                ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_VldHora(cHora, lVazio)

	Local lRet := .T.          
	
	Default lVazio := .F.

	cHora := StrTran(cHora, ":", "") 
	If Empty(cHora) 
	 lRet := lVazio
	ElseIf !(SubStr(cHora, 3, 2) >= '00' .And. SubStr(cHora, 3, 2) <= '59')
		lRet := .F.
	ElseIf !(SubStr(cHora, 1, 2) >= '00' .And. SubStr(cHora, 1, 2) <= '23')
		lRet := .F.                                                            
	EndIf	
	Return(lRet) 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvAA3 � Autor � Cibele Peria       � Data �  07/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina de Atualizacao das tabelas                          ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_GrvAA3(nOpc)

Local wProcura := .F., cAliasOld := Alias()

 aCGMG := aClone(oGMG:aCols)
 aCGMH := aClone(oGMH:aCols)
 aCGMI := aClone(oGMI:aCols)

 If nOpc # 2 // nao for consulta
 	DbSelectArea("GMD")
 	DbSetOrder(1)  // GMD_FILIAL + GMD_CODDIS
 	wProcura := DbSeek(xFilial("GMD") + M->GMD_CODDIS)
 	If Inclui .Or. Altera
 		RecLock("GMD", If(Altera, .F., .T.))
 		HS_GRVCPO("GMD")
   GMD->GMD_CODLOC := M->GMD_CODLOC
   GMD_GMD_LEITO   := M->GMD_LEITO
 		MsUnlock()
 		ConfirmSx8()
		
 		FS_GrvGM("GMG", 1, "M->GMD_CODDIS + aCGMG[pForACols, nGMG_DIASEM]", aHGMG, aCGMG, nUGMG)
	 	FS_GrvGM("GMH", 1, "M->GMD_CODDIS + aCGMH[pForACols, nGMH_CODPLA]", aHGMH, aCGMH, nUGMH)
 		FS_GrvGM("GMI", 1, "M->GMD_CODDIS + aCGMI[pForACols, nGMI_CODPRO]", aHGMI, aCGMI, nUGMI)
		
 	Else  // exclusao
		 If wProcura
			 FS_DelGM("GMG", 1, "M->GMD_CODDIS + aCGMG[pForACols, nGMG_DIASEM]", aCGMG)
			 FS_DelGM("GMH", 1, "M->GMD_CODDIS + aCGMH[pForACols, nGMH_CODPLA]", aCGMH)
			 FS_DelGM("GMI", 1, "M->GMD_CODDIS + aCGMI[pForACols, nGMI_CODPRO]", aCGMI)
				
			 DbSelectArea("GMD")
			 RecLock("GMD", .F., .T.)
			 DBDelete()
			 MsUnlock()
			 WriteSx2("GMD")
		 EndIf
		EndIf 
	EndIf

 DbSelectArea(cAliasOld)
Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_GrvGM  � Autor � Cibele Peria       � Data �  07/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Grava arquivos de relacionamento - GM0, GM1 e GM2          ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_GrvGM(cAlias, nOrd, cChave, aHGrv, aCGrv, nUGrv)

 Local nForACols := 0, cAliasOld := Alias(), lAchou := .F.
 Local cPref := cAlias + "->" + PrefixoCpo(cAlias)
 
 If !(Len(aCGrv) == 1 .And. Empty(aCGrv[1, 1]) )
  For nForACols := 1 To Len(aCGrv)
  	pForACols := nForACols
  	
  	DbSelectArea(cAlias)
  	DbSetOrder(nOrd)
  	lAchou := DbSeek(xFilial(cAlias) + &(cChave))
  	If aCGrv[nForACols, nUGrv + 1] .And. lAchou // exclusao
  		RecLock(cAlias, .F., .T.)
  		DbDelete()
  		MsUnlock()
  		WriteSx2(cAlias)
  	Else
  		If !aCGrv[nForACols, nUGrv + 1]
  			RecLock(cAlias, !lAchou)
  			HS_GRVCPO(cAlias, aCGrv, aHGrv, nForACols)
  			&(cPref + "_FILIAL") := xFilial(cAlias)
  			&(cPref + "_CODDIS") := M->GMD_CODDIS
  			&(cPref + "_IDEATI") := M->GMD_IDEATI
  			&(cPref + "_LOGARQ") := HS_LogArq()
  			If cAlias $ "GMH/GMI"
      If cAlias = "GMH"         // Se tabela de Conv/Plano
    			&(cPref + "_CODCON") := HS_IniPadr("GCM", 2, aCGrv[nForACols, nGMH_CODPLA], "GCM_CODCON")
   	 	EndIf
   			&(cPref + "_CODLOC") := M->GMD_CODLOC
   		EndIf	
  			MsUnlock()
  		EndIf
  	EndIf
  Next
 EndIf 

DbSelectArea(cAliasOld)
Return(Nil)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_DelGM  � Autor � Paulo Jose         � Data �  18/11/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Rotina de DELETE dos relacionamentos do Local              ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar (Agenda Ambulatorial)             ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_DelGM(cAlias, nOrd, cChave, aCGrv)

 Local nForDel := 0, cAliasOld := Alias()
 
 If !(Len(aCGRv) == 1 .And. Empty(aCGrv[1,1]) )
 
  For nForDel := 1 To Len(aCGrv)
  	pForACols := nForDel
  	
  	DbSelectArea(cAlias)
  	DbSetOrder(nOrd)
  	If DbSeek(xFilial(cAlias) + &(cChave))
  		RecLock(cAlias, .F., .T.)
  		DbDelete()
  		MsUnlock()
  		WriteSx2(cAlias)
  	EndIf
  Next
 EndIf  
 
 DbSelectArea(cAliasOld)
Return(Nil)


Static Function FS_WhenCL(cCpo)                                           
 
 If cCpo == "GMD_CODLOC"
  cGcsTipLoc := "4"
 ElseIf cCpo == "GMD_LOCATE"
  cGcsTipLoc := "0"
 EndIf              
Return(.T.)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HS_FProSet� Autor � Cibele Peria       � Data �  08/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Filtro da tabela GM2 (Procedimento por Setor), conforme    ���
���          � rotina.                                                    ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar. Utilizada no filtro da consulta  ��� 
���          � padrao GM2.                                                ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_FProSet(cFunName)

Return(GM2->GM2_CODLOC == IIF(cFunName == "HSPAHA97", M->GM6_CODLOC, M->GMD_CODLOC))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_FACILI � Autor � Cibele Peria       � Data �  24/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Prepara Facilitadores                                      ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_FACILI()

 If oFolder:nOption == 1
  HS_MsgInf(STR0037, STR0011, STR0006) //"Facilitador n�o gerado para este relacionamento"###"Aten��o"###"Disponibilidade Cir�rgica"
 ElseIf Empty(M->GMD_CODDIS)
  HS_MsgInf(STR0036, STR0011, STR0006) //"Por Favor, informe o c�digo da disponibilidade"###"Aten��o"###"Disponibilidade Cir�rgica"
 ElseIf Empty(M->GMD_CODLOC)
  HS_MsgInf(STR0038, STR0011, STR0006) //"Por favor, informe o c�digo do setor"###"Aten��o"###"Disponibilidade Cir�rgica" 
 ElseIf Empty(M->GMD_QUARTO)
  HS_MsgInf(STR0040, STR0011, STR0006) //Por favor, informe o c�digo do quarto"###"Aten��o"###"Disponibilidade Cir�rgica"
 Else 
  If oFolder:nOption == 2
   PROCESSA({||FS_FACPLA()})
  ElseIF oFolder:nOption == 3
   If Empty(M->GMD_CODLOC)
    HS_MsgInf(STR0038, STR0011, STR0006) //"Por favor, informe o c�digo do setor"###"Aten��o"###"Disponibilidade Cir�rgica"
   Else 
    PROCESSA({||FS_FACPRO()})
   EndIf 
  EndIf  
 EndIf

Return()

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_FACPLA � Autor � Cibele Peria       � Data �  24/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Facilitador para inclusao de planos no relacionamento      ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_FACPLA()

 Local aArea := GetArea(), nForACols := 0, lRet := .T.
                         
 aCGMH := aClone(oGMH:aCols)
 
 For nForACols := 1 To Len(aCGMH)
  If aCGMH[nForACols, nUGMH + 1] == .T.
   HS_MsgInf(STR0039, STR0011, STR0006) //"Atualize a disponibilidade (relacionamentos exclu�dos) antes de executar o facilitador"###"Aten��o"###"Disponibilidade Cir�rgica"
   lRet := .F.
   Exit
  EndIf 
 Next

 If lRet
  If Pergunte("HSAA3A", .T.)
 	 DbSelectArea("GCM") //Cadastro de Planos X Convenios
   DbSetOrder(2) // GCM_FILIAL + GCM_CODPLA
   ProcRegua(RecCount())
   DbSeek(xFilial("GCM") + MV_PAR01, .T.)
   
   While !Eof() .And. GCM_FILIAL == xFilial("GCM") .And. GCM_CODPLA <= MV_PAR02
    IncProc(STR0035 + GCM->GCM_CODPLA) //"Processando... "
    
   	If Empty(aCGMH[oGMH:nAt, nGMH_CODPLA])                
    	aCGMH[oGMH:nAt, nGMH_CODPLA] := GCM->GCM_CODPLA
    	aCGMH[oGMH:nAt, nGMH_DESPLA] := GCM->GCM_DESPLA
   		aCGMH[oGMH:nAt, nUGMH + 1] := .F.
    ElseIf aScan(aCGMH, {| aVet | aVet[1] == GCM_CODPLA})	== 0 
     aADD(aCGMH, oGMH:aCols[1])
   		aCGMH[Len(aCGMH), nGMH_CODPLA] := GCM->GCM_CODPLA
    	aCGMH[Len(aCGMH), nGMH_DESPLA] := GCM->GCM_DESPLA
    EndIf
   	
     oGMH:SetArray(aCGMH)
     
    DbSkip()
   EndDo
    
   oGMH:Refresh()
   
  EndIf
 EndIf

 RestArea(aArea)
Return(Nil) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_FACPRO � Autor � Cibele Peria       � Data �  27/12/04   ���
�������������������������������������������������������������������������͹��
���Descricao � Facilitador P/incluisao de procedimentos no relacionamento ���
�������������������������������������������������������������������������͹��
���Uso       � Administracao Hospitalar                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function FS_FACPRO()

 Local aArea := GetArea(), lRet := .T., nForACols := 0
 
 aCGMI := aClone(oGMI:aCols)
 
 For nForACols := 1 To Len(aCGMI)
  If aCGMI[nForACols, nUGMI + 1] == .T.
   HS_MsgInf(STR0039, STR0011, STR0006) //"Atualize a disponibilidade (relacionamentos exclu�dos) antes de executar o facilitador"###"Aten��o"###"Disponibilidade Cir�rgica"
   lRet := .F.
   Exit
  EndIf 
 Next
    
 If lRet
  If Pergunte("HSP99B", .T.)
 	 DbSelectArea("GM2") //Cadastro de Procedimentos
   DbSetOrder(1) // GM2_FILIAL + GM2_CODLOC + GM2_CODPRO
   ProcRegua(RecCount())
   DbSeek(xFilial("GM2") + M->GMD_CODLOC + MV_PAR01, .T.)
   While !Eof() .And. GM2->GM2_FILIAL == xFilial("GM2") .And. GM2->GM2_CODLOC == M->GMD_CODLOC ;
                .And. GM2->GM2_CODPRO <= MV_PAR02
    IncProc(STR0035 + GM2->GM2_CODPRO) //"Processando... "
    
    DbSelectArea("GA7")
    DbSetOrder(1) // GA7_FILIAL + GA7_CODPRO
    If DbSeek(xFilial("GA7") + GM2->GM2_CODPRO)
     If GA7->GA7_CODGPP >= MV_PAR03 .And. GA7->GA7_CODGPP <= MV_PAR04 //Consiste Grupo de Procedimento
     	If GA7->GA7_CODGDE >= MV_PAR05 .And. GA7->GA7_CODGDE <= MV_PAR06 //Consiste Grupo de Despesa
       If GA7->GA7_CODESP >= MV_PAR07 .And. GA7->GA7_CODESP <= MV_PAR08 //Consiste eSPECIALIDADE
    	 	
     	 	If Empty(aCGMI[oGMI:nAt, nGMI_CODPRO])
       		aCGMI[oGMI:nAt, nGMI_CODPRO] := GA7->GA7_CODPRO 
       		aCGMI[oGMI:nAt, nGMI_DESPRO] := GA7->GA7_DESC
       		aCGMI[oGMI:nAt, nUGMI+1] := .F.
       	ElseIf aScan(aCGMI, {| aVet | aVet[1] == GA7_CODPRO})	== 0 
       	 aADD(aCGMI, oGMI:aCols[1])
       	 aCGMI[Len(aCGMI), nGMI_CODPRO] := GA7->GA7_CODPRO
       	 aCGMI[Len(aCGMI), nGMI_DESPRO] := GA7->GA7_DESC
     	  EndIf
     	  
        oGMI:SetArray(aCGMI)
        
       EndIf  
      EndIf    
     EndIf
    EndIf
      
    DbSelectArea("GM2")
    DbSkip()
   End 
  
   oGMI:Refresh()
   
  EndIf
 EndIf
 
 RestArea(aArea)
Return(Nil) 


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_VldDisp� Autor � Patricia Queiroz   � Data �  28/08/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Valida se ao incluir uma disponbilidade ja existe outra com���
���          � os mesmos horarios e dias da semana.                       ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/ 

Static Function FS_VldDisp()
 
Local lRet    := .T.  
Local nCont   := 0
Local cHorIni := M->GMD_HORINI
Local cHorFim := M->GMD_HORFIM 
Local cSala   := M->GMD_QUARTO          
Local cSQL    := ""
Local cMsg    := ""    
Local aArea   := GetArea()
Local cDiaSem := ""


If INCLUI 

 For nCont := 1 To Len(oGMG:aCols)

  cDiaSem += oGMG:ACols[nCont,nGMG_DIASEM]

 Next

 DbSelectArea("GMD")
 DbSetOrder(2) // GMD_FILIAL + GMD_QUARTO + GMD_LEITO
 
 cSQL := "SELECT GMD.GMD_CODDIS, GMD.GMD_QUARTO, GMD.GMD_HORINI, GMD.GMD_HORFIM, GMD.GMD_IDEATI, GMG.GMG_DIASEM "
 cSQL += " FROM " + RetSqlName("GMD") + " GMD "                                         
 cSQL += " JOIN " + RetSqlName("GMG") + " GMG ON GMG.GMG_CODDIS = GMD.GMD_CODDIS AND GMG.GMG_FILIAL = '" + xFilial("GMG") + "' AND GMG.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE GMD.GMD_FILIAL = '" + xFilial("GMD") + "' AND GMD.D_E_L_E_T_ <> '*'
 cSQL += " AND GMD.GMD_HORFIM > '" + cHorIni + "' "
 cSQL += " AND GMD.GMD_HORINI < '" + cHorFim + "' " 
 cSQL += " AND GMD.GMD_QUARTO = '" + cSala + "' "
 cSQL += " AND GMD.GMD_IDEATI = '1' "
 cSQL += " AND GMG.GMG_DIASEM IN (" + HS_InSql(cDiaSem) + ") "
 
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 
 DbSelectArea("QRY")
 
 If !Eof()
   cMsg := STR0045 + cSala //"J� existe Disponibilidade para a Sala "  
   cMsg += STR0046 + QRY->GMD_HORINI + STR0047 + QRY->GMD_HORFIM //" no per�odo de "###" a "
   cMsg += STR0048 + FS_DiaExt(QRY->GMG_DIASEM) + "." //" para "
   HS_MsgInf(cMsg, STR0011, STR0006) //"Aten��o"###"Disponibilidade Cir�rgica"
   lRet := .F.
 EndIf 
 
 DbCloseArea()

EndIf                                          	

RestArea(aArea)

Return(lRet)           


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FS_DiaSem �Autor  �Patricia Queiroz    � Data �  28/08/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Retorna o dia da semana por extenso.                       ���
�������������������������������������������������������������������������͹��
���Uso       � FS_VldDisp                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function FS_DiaExt(cNroDia)

 Local cDia := ""
  
 If cNroDia == "1"
  cDia := STR0049 //"Domingo"
 ElseIf  cNroDia == "2"
  cDia := STR0050 //"Segunda-feira"
 ElseIf  cNroDia == "3"
  cDia := STR0051 //"Ter�a-feira"
	ElseIf  cNroDia == "4"
  cDia := STR0052 //"Quarta-feira"
	ElseIf  cNroDia == "5"
  cDia := STR0053 //"Quinta-feira"
	ElseIf  cNroDia == "6"
  cDia := STR0054 //"Sexta-feira"  
	ElseIf  cNroDia == "7"
  cDia := STR0055 //"S�bado"
	ElseIf  cNroDia == "8"
  cDia := STR0056 //"Feriado
 EndIf  
     
Return(cDia)


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
Local aRotina :=	{{OemtoAnsi(STR0001), "axPesqui", 0, 1, 0, nil},; //"Pesquisar"
                   	 {OemtoAnsi(STR0002), "HS_AA3"	 , 0, 2, 0, nil},; //"Visualizar"
                   	 {OemtoAnsi(STR0003), "HS_AA3"	 , 0, 3, 0, nil},; //"Incluir"
                   	 {OemtoAnsi(STR0004), "HS_AA3"	 , 0, 4, 0, nil},; //"Alterar"
                     {OemtoAnsi(STR0005), "HS_AA3"	 , 0, 5, 0, nil}}  //"Excluir"
Return(aRotina)