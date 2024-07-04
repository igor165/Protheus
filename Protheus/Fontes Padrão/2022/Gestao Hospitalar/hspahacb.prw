#INCLUDE  "HSPAHACB.CH"
#INCLUDE "Protheus.CH"
#INCLUDE "TopConn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHACB  º Autor ³ Daniel Peixoto     º Data ³  14/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Usuarios Bloqueados / Ficha                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHACB()

Private aRotina := {{OemtoAnsi(STR0001)	, "axPesqui" , 0, 1}, ;   //"Pesquisar"
                    {OemtoAnsi(STR0002), "HS_ACB"		 	, 0, 2}, ;   //"Visualizar"
                    {OemtoAnsi(STR0003), "HS_ACB"		  , 0, 3}, ;   //"Incluir"
                    {OemtoAnsi(STR0004), "HS_ACB"		  , 0, 4}, ;   //"Alterar"
                    {OemtoAnsi(STR0005), "HS_ACB"		  , 0, 5} }   //"Excluir"
                    
	If !HS_EXISDIC({{"T", "GGY"}})
  Return()
 Endif 
 
 DbSelectArea("GGY")
	mBrowse(06, 01, 22, 75, "GGY")
	
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_ACB    º Autor ³ Daniel Peixoto     º Data ³  14/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tratamento das funcoes                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
                                                                            */
Function HS_ACB(cAlias, nReg, nOpc) 
Local nOpcA := 0, nGDOpc := IIF(nOpc == 2 .Or. nOpc == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)

Private nOpcE    := aRotina[nOpc, 4]
Private aTela 		 := {}
Private aGets    := {}

Private aCGHW	:= {}, aHGHW := {}, nUGHW := 0, nLGHW := 0
Private nGHWCODUSU := 0, nGHWSTAREG := 0, nGHWITEFIC := 0

Private oGGY, oGHW

 RegToMemory("GGY", (nOpcE == 3)) 

 nOpcA := 0 

 HS_BDados("GHW", @aHGHW, @aCGHW, @nUGHW, 1,, IIF(nOpc # 3, "'" + M->GGY_CODFIC + "' == GHW->GHW_CODFIC", Nil), .T.)
 nGHWSTAREG := aScan(aHGHW, {| aVet | aVet[2] == "HSP_STAREG"})
 nGHWCODUSU := aScan(aHGHW, {| aVet | aVet[2] == "GHW_CODUSU"})
 nGHWITEFIC := aScan(aHGHW, {| aVet | aVet[2] == "GHW_ITEFIC"})

 If Len(aCGHW) == 1 .And. Empty(aCGHW[1, nGHWCODUSU]) 
  aCGHW[1, nGHWITEFIC] := StrZero(1, Len(GHW->GHW_ITEFIC))
 EndIf 

 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 020, .T., .T. } )	
 AAdd( aObjects, { 100, 080, .T., .T.,.T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )  
 
 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
 
 aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
 aPGDs := MsObjSize( aInfo, aObjects, .T. )   

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd   //"Cadastro de Usuários Bloqueados por Ficha"

  oGGY := MsMGet():New("GGY", nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
  oGGY:oBox:align:= CONTROL_ALIGN_ALLCLIENT          
 
   // Monta o Folder 
  @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel Of oDlg Prompts STR0007 //"Usuários Bloqueados"
  oFolder:Align := CONTROL_ALIGN_BOTTOM    
 
  oGHW := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, "HS_DuplAC(oGHW:oBrowse:nAt, oGHW:aCols, {nGHWCODUSU},, .T.)",, "+GHW_ITEFIC",,, 99999,,,, oFolder:aDialogs[1], aHGHW, aCGHW)  
  oGHW:oBrowse:align := CONTROL_ALIGN_ALLCLIENT  
  oGHW:cFieldOk := "HS_GDAtrib(oGHW, {{nGHWSTAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGHW:oBrowse:bDelete := {|| HS_GDAtrib(oGHW, {{nGHWSTAREG, "BR_CINZA", "BR_VERDE"}}), oGHW:DelLine()}

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(Obrigatorio(aGets, aTela) .And. HS_TudoOK("GHW", oGHW, nGHWITEFIC), oDlg:End(), nOpcA := 0)}, ;
 																																																		{|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1 .And. nOpcE <> 2
 	Begin Transaction
  	FS_GrvACB(nOpcE)
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GrvACB ºAutor  ³Daniel Peixoto      º Data ³  14/03/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Trava tabela para Inclusao, Alteracao e Exclusao.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GrvACB(nOpcE)

If nOpcE == 3 .Or. nOpcE == 4 //Incluir e Alterar
	RecLock("GGY", (nOpcE == 3))
 	HS_GrvCpo("GGY")
	MsUnlock()	
 
 FS_GrvGM("GHW", 1, "M->GGY_CODFIC + oGHW:aCols[pForACols, nGHWITEFIC]", oGHW:aHeader, oGHW:aCols, nGHWCODUSU, nGHWSTAREG)

ElseIf nOpcE == 5 //Excluir
 FS_DelGM("GHW", 1, "M->GGY_CODFIC + oGHW:aCols[pForACols, nGHWITEFIC]", oGHW:aCols, nGHWCODUSU) // Excluir relacionamento GHW
	
	RecLock("GGY", .F.)
 	DbDelete()
	MsUnlock()
EndIf

Return(nOpcE)                                                        


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GrvGM  º Autor ³ Cibele Peria       º Data ³  12/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava arquivos de relacionamento - GM0, GM1 e GM2          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar (Agenda Ambulatorial)             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GrvGM(cAlias, nOrd, cChave, aHGrv, aCGrv, nPos, nStaReg)

 Local nForACols := 0, cAliasOld := Alias(), lAchou := .F.
 Local cPref := cAlias + "->" + PrefixoCpo(cAlias)

 If !(Len(aCGrv) == 1 .And. Empty(aCGrv[1, nPos]))
  While (nForACols := aScan(aCGrv, {| aVet | aVet[nStaReg] <> "BR_VERDE"}, nForACols + 1)) > 0
   pForACols := nForACols
  
   DbSelectArea(cAlias)
   DbSetOrder(nOrd)
   lAchou := DbSeek(xFilial(cAlias) + &(cChave))
   If aCGrv[nForACols, Len(aCGrv[nForACols])] .And. lAchou // exclusao
    RecLock(cAlias, .F., .T.)
     DbDelete()
    MsUnlock()
   Else
    If !aCGrv[nForACols, Len(aCGrv[nForACols])]
     RecLock(cAlias, !lAchou)
      HS_GRVCPO(cAlias, aCGrv, aHGrv, nForACols)
      &(cPref + "_FILIAL") := xFilial(cAlias)
      &(cPref + "_CODFIC") := M->GGY_CODFIC
     MsUnlock()                  
    EndIf 
   EndIf
  End
 EndIf 
 
 DbSelectArea(cAliasOld)
 
Return(Nil)                                                

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_DelGM  º Autor ³ Cibele Peria       º Data ³  12/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de DELETE dos relacionamentos do Local              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar (Agenda Ambulatorial)             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_DelGM(cAlias, nOrd, cChave, aCGrv, nPos)

 Local nForDel := 0, cAliasOld := Alias()
 
 If !(Len(aCGrv) == 1 .And. Empty(aCGrv[1, nPos])) 
  For nForDel := 1 To Len(aCGrv)
   pForACols := nForDel
  
   DbSelectArea(cAlias)
   DbSetOrder(nOrd)
   If DbSeek(xFilial(cAlias) + &(cChave))
    RecLock(cAlias, .F., .T.)
     DbDelete()
    MsUnlock()
   EndIf
  Next
 EndIf
 
 DbSelectArea(cAliasOld)
 
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_ACBFUNCº Autor ³ Gilson da Silva    º Data ³  08/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao do campo GDN_FUNCAO, verifica se a funcao        º±±
±±º          ³ digitada existe no sistema.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar (Agenda Ambulatorial)             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_ACBFUNC(cNomFunc)

 Local lRet := .T.
 Local aFichas := HS_RetFichas()
 Local nPFicha := 0
 
 If !(lRet := ((nPFicha := aScan(aFichas, {| aVet | PadR(AllTrim(aVet[1]), Len(GDN->GDN_FUNCAO)) == cNomFunc})) > 0))
  HS_MsgInf(STR0008, STR0009, STR0010) //"Informação invalida, somente fichas, termos e etiquetas podem ser utilizadas"###"Atenção"###"Validação de função"
 ElseIf HS_CountTB("GGY", "GGY_FUNCAO  = '" + M->GGY_FUNCAO + "'")  > 0
  HS_MsgInf(STR0011, STR0009, STR0012) //"Ficha já cadastrada."###"Atenção"###"Validação de duplicidade"
  lRet := .F.
 EndIf

 If lRet
  M->GGY_NOMFIC := aFichas[nPFicha][2]   //"Nome"
  oGGY:Refresh()
 EndIf
 
Return(lRet)
