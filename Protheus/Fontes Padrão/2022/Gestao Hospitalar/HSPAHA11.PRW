#INCLUDE "HSPAHA11.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA11  º Autor ³ Manoel             º Data ³  23/11/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CADASTRO DE GRUPO AMB/PROCEDIMENTOS                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHA11()
 Private cCadastro := STR0001 //"Grupos de procedimentos"
 Private aRotina := MenuDef()   
 Private cGcsTipLoc := "9G"
 DbSelectArea("GAQ")
 DbSetOrder(1)      
 
 If !Hs_ExisDic({{"T", "GNQ"}})
  Return(nil)
 EndIf

 DbSelectArea("GNQ")
 DbSetOrder(1)
  
 mBrowse(06, 01, 22, 75, "GAQ")
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ HSPAH031 ³ Autor ³  Daniel             ³ Data ³ 17/03/2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de Tratamento do Cadastro de Grupos de procedimento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_MntA11(cAliasA11, nRegA11, nOpcA11)
 Local nOpcDlg := 0, oDlgGaq, oEncGaq
 Local aSize  := {}, aObjects := {}, aInfo := {}, aPPanel := {}
 Local aCposGNQ := {"GNQ_CODLOC", "GNQ_NOMLOC"}                                    
 Local aHGnq := {}, aCGnq := {}, nUGnq := 0
 Local nOpcGd := IIf(aRotina[nOpcA11, 4] == 2 .Or. aRotina[nOpcA11, 4] == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
 
 Private aGets := {}, aTela := {}
 Private nGNQStaReg := 0, nGNQCodSeq := 0, nGNQCodLoc := 0, 	nGNQNomLoc := 0
 
 aSize 			:= MsAdvSize(.T.)
 
 aObjects := {}
 aAdd( aObjects, { 100, 030, .T., .T.} )
 aAdd( aObjects, { 100, 070, .T., .T., .T.} )
  
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPPanel := MsObjSize( aInfo, aObjects, .T. )
 
 RegToMemory("GAQ", aRotina[nOpcA11, 4] == 3)
 
	//HS_BDados("GNQ", @aHGnq, @aCGnq, @nUGnq, 1,, " GNQ_GRUPRO = '"+GAQ->GAQ_GRUPRO+"'" ,,, "/",,,,,, .T.,,,,,, aCposGNQ)	         
	HS_BDados("GNQ", @aHGnq, @aCGnq, @nUGnq, 1,, " GNQ_GRUPRO = '"+GAQ->GAQ_GRUPRO+"'", .T.)
    nGNQStaReg := aScan(aHGnq, {| aVet | aVet[2] == "HSP_STAREG"})
    nGNQCodSeq := aScan(aHGnq, {| aVet | aVet[2] == "GNQ_CODSEQ"})
    nGNQCodLoc := aScan(aHGnq, {| aVet | aVet[2] == "GNQ_CODLOC"})
	nGNQNomLoc := aScan(aHGnq, {| aVet | aVet[2] == "GNQ_NOMLOC"})
	
	If Empty(aCGnq[1, nGNQCodSeq])
  aCGnq[1, nGNQCodSeq] := StrZero(1,Len(GNQ->GNQ_CODSEQ))
 EndIf
 
 DEFINE MSDIALOG oDlgGaq TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5]	PIXEL of oMainWnd 

//TITLE OemToAnsi(cCadastro) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd

  oPEnc	:=	tPanel():New(aPPanel[1, 1], aPPanel[1, 2],, oDlgGaq,,,,,, aPPanel[1, 3], aPPanel[1, 4])
  oPEnc:Align := CONTROL_ALIGN_TOP
  
  oEncGaq := MsMGet():New(cAliasA11, nRegA11, nOpcA11,,,,, {aPPanel[1, 1], aPPanel[1, 2], aPPanel[1, 3], aPPanel[1, 4]},,,,,, oPEnc)
  oEncGaq:aEntryCtrls[aScan(oEncGaq:aGets, {|x| "GAQ_GRUPRO" $ x}) ]:lReadOnly := (aRotina[nOpcA11, 4] <> 3)
  oEncGaq:oBox:Align := CONTROL_ALIGN_ALLCLIENT
                                           
 @ aPPanel[2, 1], aPPanel[2, 2] FOLDER oFolder SIZE aPPanel[2, 3], aPPanel[2, 4] Pixel Of oDlgGaq Prompts "Setor Executante"
  
  oGNQ := MsNewGetDados():New(aPPanel[2, 1], aPPanel[2, 2], aPPanel[2, 3]-20, aPPanel[2,4], nOpcGd,"HS_DuplAC(oGNQ:oBrowse:nAt, oGNQ:aCols, {nGNQCodLoc},, .T.)",,"+GNQ_CODSEQ",,,99999,,,, oFolder:aDialogs[1], aHGnq, aCGnq)  
  oGNQ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT   
  oGNQ:cFieldOk           := "HS_GDAtrib(oGNQ, {{nGNQStaReg, 'BR_AMARELO', 'BR_VERDE'}})"
  oGNQ:oBrowse:bDelete    := {|| HS_GDAtrib(oGNQ, {{nGNQStaReg, "BR_CINZA", "BR_VERDE"}}), oGNQ:DelLine(), oGNQ:oBrowse:Refresh() }
                            
  
 ACTIVATE MSDIALOG oDlgGaq CENTERED ON INIT EnchoiceBar(oDlgGaq, {|| nOpcDlg := 1, IIf(Obrigatorio(aGets, aTela), oDlgGaq:End(), nOpcDlg := 0)}, ;
                                                        {|| nOpcDlg := 0, oDlgGaq:End()})

 If nOpcDlg == 1
  Begin Transaction 
  FS_GrvA11(nOpcA11)
  End Transaction  
 EndIf
Return(Nil)

//////////////////////////
Static Function FS_GrvA11(nOpcA11)
 If aRotina[nOpcA11, 4] <> 2 // se nao for consulta
  DbSelectArea("GAQ")  
  DbSetOrder(1)
  
  If aRotina[nOpcA11, 4] <> 3
   DbSeek(xFilial("GAQ") + M->GAQ_GRUPRO)
  EndIf 
  
  If aRotina[nOpcA11, 4] <> 5
   RecLock("GAQ", aRotina[nOpcA11, 4] == 3)
    HS_GrvCpo("GAQ")
    GAQ->GAQ_LOGARQ := HS_LogArq()
   MsUnLock()
  Else  // exclusao
   DbSelectArea("GA5")
   DbSetorder(2)
   If DbSeek(xFilial("GA5") + M->GAQ_GRUPRO)
    HS_MsgInf(STR0002, STR0004, STR0001) //"Existe este Grupo de Procedimentos na Tabela de Valores de CH's Diferenciados por  Convênio/Grupo AMB (GA5). Impossivel Exclui-lo!"###"Atencao"###"Grupos de procedimentos"
   Else 
    RecLock("GAQ", .F., .T.)
     DbDelete()
    MsUnlock()
    WriteSx2("GAQ") 
   Endif
  EndIf 
 	Fs_GrvGNQ(aRotina[nOpcA11, 4], M->GAQ_GRUPRO)
	Endif
Return(.T.)

Static Function Fs_GrvGNQ(nOpc, cGruPro)
 Local aArea  := getArea()
 Local nI     := 0
 Local lAchou := .F.
 
 DbSelectArea("GNQ")
 DbSetOrder(1)  //GNQ_FILIAL+GNQ_GRUPRO+GNQ_CODSEQ
 
 For nI := 1 To Len(oGnq:aCols)
  lAchou := DbSeek(xFilial("GNQ") + cGruPro + oGnq:aCols[nI , nGNQCodSeq])
  If (oGnq:aCols[nI, Len(oGnq:aHeader)+1]) .Or. nOpc == 5
   If lAchou 
    RecLock("GNQ", .F.)
     DbDelete()
    MsUnLock()  
    WriteSx2("GNQ")
   EndIf
  Else
   If (oGnq:aCols[nI, nGnqStaReg] # "BR_VERDE")
    RecLock("GNQ", !lAchou)
     GNQ->GNQ_FILIAL := xFilial("GNQ")
     GNQ->GNQ_GRUPRO := cGruPro
     GNQ->GNQ_CODSEQ := oGnq:aCols[nI, nGnqCodSeq]
     GNQ->GNQ_CODLOC := oGnq:aCols[nI, nGnqCodLoc]
    MsUnLock()     
   EndIf
  EndIf
 Next
  
 RestArea(aArea)
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VldA11 º Autor ³ Gilson da Silva    º Data ³  12/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³  Valida os campos                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar (Agenda Ambulatorial)                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VldA11()
Local lRet		:= .T.
Local lExoGnq	:= Type("oGnq") # "U"
Private cCodLoc := Space(TamSx3("GAQ_CODLOC")[1])
	
If !lExoGnq
	cCodLoc := &(ReadVar())
	If !Empty(cCodLoc)
		If !HS_SeekRet("GCS","cCodLoc",1,.F.,"GAQ_NOMLOC","GCS_NOMLOC",,,.T.)
			HS_MsgInf(STR0003, STR0004, STR0001) ////"Setor invalido"###"Atencao"###"Grupos de procedimentos"
			lRet := .F.
		ElseIf GCS->GCS_TIPLOC <> "9" .AND. GCS->GCS_TIPLOC <> "G"
			HS_MsgInf(STR0005, STR0004, STR0001)//"Setor invalido. Utilize um setor do tipo <Laudo ou Laboratorio>"###"Atencao"###"Grupos de procedimentos"
			lRet := .F.
		EndIf
	EndIf
Else
	If ReadVar() $ "M->GAQ_CODLOC/M->GNQ_CODLOC"
		cCodLoc := &(ReadVar())
		If !Empty(cCodLoc)
			If	(ReadVar() == "M->GNQ_CODLOC" .And. cCodLoc == M->GAQ_CODLOC) ; 
				.OR. (ReadVar() == "M->GAQ_CODLOC" .And. aScan(oGnq:aCols,{ |aVet| aVet[nGnqCodLoc] == cCodLoc}) > 0)
				HS_MsgInf("Setor já cadastrado para Grupo de Procedimentos.", STR0004, STR0001) ////"Setor invalido"###"Atencao"###"Grupos de procedimentos"
				lRet := .F.
			ElseIf !HS_SeekRet("GCS","cCodLoc",1,.F.,IIF(ReadVar() == "M->GAQ_CODLOC","GAQ_NOMLOC","oGnq:aCols[oGnq:nAt, nGnqNomLoc]"),"GCS_NOMLOC",,,.T.)
				HS_MsgInf(STR0003, STR0004, STR0001) ////"Setor invalido"###"Atencao"###"Grupos de procedimentos"
				lRet := .F.
			ElseIf GCS->GCS_TIPLOC <> "9" .AND. GCS->GCS_TIPLOC <> "G"
				HS_MsgInf(STR0005, STR0004, STR0001)//"Setor invalido. Utilize um setor do tipo <Laudo ou Laboratorio>"###"Atencao"###"Grupos de procedimentos"
				lRet := .F.
			EndIf	
		EndIf
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_ValA11 º Autor ³ Marcelo Jose       º Data ³  01/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³  Valida os campos                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar (Agenda Ambulatorial)                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_VALA11(nOpc)
 Local blRet   := {|L| lRet := L }, lRet := .T.
 Local bMess   := {|| Alert("Para Solicita Laudo = Sim, o Setor e Obrigatorio. Ok...", "Atencao"), Eval(blRet,.F.) }
 Local bValida := {|| IIf(PERTENCE("01")==.T.,IIf(M->GAQ_SLAUDO == "1",IIf(Empty(M->GAQ_CODLOC)=.T.,Eval(bMess),Eval(blRet,.T.)),Eval(blRet,.T.)), Eval(blRet,.F.)) }
 If nOpc == 1
  Eval( bValida )
 EndIf
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 06/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=	{{OemToAnsi("Pesquisar") , "axPesqui" , 0, 1, 0, nil}, ; //"Pesquisar" 
                     {OemToAnsi("Visualizar"), "HS_MntA11", 0, 2, 0, nil}, ; //"Visualizar" 
                     {OemToAnsi("Incluir")   , "HS_MntA11", 0, 3, 0, nil}, ; //"Incluir" 
                     {OemToAnsi("Alterar")   , "HS_MntA11", 0, 4, 0, nil}, ; //"Alterar" 
                     {OemToAnsi("Excluir")   , "HS_MntA11", 0, 5, 0, nil}}   //"Excluir"
Return(aRotina)
