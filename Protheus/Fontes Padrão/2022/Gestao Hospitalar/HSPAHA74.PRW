#INCLUDE "HSPAHA74.ch"
#include "protheus.CH"
#include "colors.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA74  º Autor ³ Mario Arizono      º Data ³  05/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Kit's  Virtuais                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHA74()  
 Private cCadastro := STR0013 //"Cadastro de Kit's Virtuais"
 Private aRotina   := {{ OemToAnsi(STR0001)    ,"axPesqui", 0 , 1},;    //"Pesquisar"
									               { OemToAnsi(STR0002)  ,'HS_Mnt74', 0 , 2},;    //"Visualizar"
                        { OemToAnsi(STR0003)    ,'HS_Mnt74', 0 , 3},;    //"Montagem"
                        { OemToAnsi(STR0004) ,'HS_Mnt74', 0 , 5},;  //"Desmontagem"
                        { OemToAnsi(STR0005)      ,'HS_Mnt74', 0 , 4}}    //"Copiar"

 Private cG1RTipo := "014"
  
 DbSelectArea("GHI")
 DbSetOrder(1)

 mBrowse( 6, 1,22,75,"GHI")

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ HS_Mnt74 ³ Autor ³ Mario Arizono         ³ Data ³05/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Montagem das rotinas de tratamento do kit virtual.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_Mnt74(cAlias, nReg, nOpc)

 Local nOpcG := IIF(StrZero(aRotina[nOpc, 4], 2) $ "03/04", GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local nOpcA := 0
 Local aSize  := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local cGhiSeqKit := ""
 
 Private nOpcA74 := nOpc
 Private oGHI, oGHJ
 Private aHGHJ := {}, aCGHJ := {}, nUGHJ := 0
 
 Private aTela := {}, aGets := {}
 Private nGhjCcoKit := 0, nGhjQtdKit := 0, nGhjDesCom := 0, nGhjCodBar := 0, nGhjNumLot := 0, nGhjLotFor := 0
 Private nGhjLotCtl := 0, nGhjDtVali := 0, nGhjItemBr := 0
 
 Private __cLOTEFO := Space(Len(GHJ->GHJ_LOTEFO))
 Private __cLOTECT := Space(Len(GHJ->GHJ_LOTECT))
 Private __cNUMLOT := Space(Len(GHJ->GHJ_NUMLOT))
 Private __dDTVALI := CriaVar("GHJ_DTVALI")
 
 Private __aRLote   := {{"__cNUMLOT", "SB8->B8_NUMLOTE"}, ;
                        {"__cLOTEFO", "SB8->B8_LOTEFOR"}, ;
                        {"__cLOTECT", "SB8->B8_LOTECTL"}, ;
                        {"__dDTVALI", "SB8->B8_DTVALID"}}
 
 RegToMemory("GHI", aRotina[nOpcA74, 4] == 3 .Or. nOpcA74 == 5)     
 If nOpcA74 == 5
  M->GHI_DESALM := SPACE(LEN(SX5->X5_DESCRI))
 Endif
 cGhiSeqKit := IIF(nOpcA74 == 5, GHI->GHI_SEQKIT, M->GHI_SEQKIT)
             
 HS_BDados("GHJ", @aHGHJ, @aCGHJ, @nUGHJ, 2, cGhiSeqKit, IIf(aRotina[nOpcA74, 4] == 3 .And. nOpcA74 <> 5, Nil, "GHJ->GHJ_SEQKIT == '" + cGhiSeqKit + "'"))
 
 nGhjCcoKit := aScan(aHGHJ, {|aVet| aVet[2] == "GHJ_CCOKIT"})
 nGhjQtdKit := aScan(aHGHJ, {|aVet| aVet[2] == "GHJ_QTDKIT"})
 nGhjDesCom := aScan(aHGHJ, {|aVet| aVet[2] == "GHJ_DESCOM"})
 nGhjCodBar := aScan(aHGHJ, {|aVet| aVet[2] == "GHJ_CODBAR"})
 nGhjItemBr := aScan(aHGHJ, {|aVet| aVet[2] == "GHJ_ITEMBR"})
 nGhjNumLot := aScan(aHGHJ, {|aVet| aVet[2] == "GHJ_NUMLOT"})
 nGhjLotFor := aScan(aHGHJ, {|aVet| aVet[2] == "GHJ_LOTEFO"})
 nGhjLotCtl := aScan(aHGHJ, {|aVet| aVet[2] == "GHJ_LOTECT"})
 nGhjDtVali := aScan(aHGHJ, {|aVet| aVet[2] == "GHJ_DTVALI"})
 
 
 
 If aRotina[nOpcA74, 4] == 3
  aCGHJ[1, nGhjItemBr] := Soma1(aCGHJ[1, nGhjItemBr], Len(aCGHJ[1, nGhjItemBr]))
 EndIf 


 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 030, .T., .T. } )	
 AAdd( aObjects, { 100, 070, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
 
 
 nOpcA := 0
 DEFINE MSDIALOG oDlg TITLE STR0006 From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel  //"Cadastro Kit Virtual"

  oGHI := MsMGet():New("GHI", nReg, nOpcA74,,,,, aPObjs[1],, 3,,,,oDlg)
  oGHI:oBox:Align := CONTROL_ALIGN_TOP   
  
  oGHJ := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nOpcG,,,"+GHJ_ITEMBR",,, 99999,,,,, aHGHJ, aCGHJ)
  oGHJ:oBrowse:Align  := CONTROL_ALIGN_ALLCLIENT
  
  
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(oGHJ:TudoOk()  .And. Obrigatorio(aGets, aTela) .And. IIF(nOpcA74 == 4, FS_VldDel(), .T.), oDlg:End(), nOpcA := 0)}, ;
                                                  {|| nOpcA := 0, oDlg:End()})   
                                                  
 If nOpcA == 1
  Begin Transaction 
   FS_GRVA74()
  End Transaction
  
  While __lSx8
   ConfirmSx8()
  End  
 Else
  While __lSx8
   RollBackSxe()
  End            
 Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_GRVA74³ Autor ³ Mario Arizono         ³ Data ³05/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para gravacao dos kits virtuais.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_GRVA74()
 Local nForA := 0

 If aRotina[nOpcA74, 4] == 2 
  Return()
 Endif 
 

 If Inclui .Or. Altera 
  M->GHI_SEQKIT := HS_VSxeNum("GHI", "M->GHI_SEQKIT", 1)
  RecLock("GHI", Inclui .Or. nOpcA74 == 5)
   HS_GRVCPO("GHI")
   GHI->GHI_FILIAL  := xFilial("GHI")    
   GHI->GHI_USUCAD  := cUserName
 	MsUnlock()
 	  		 
 Else  // exclusao
  RecLock("GHI",.F.,.T.)
   Dbdelete()
  MsUnlock()
  WriteSx2("GHI") 
 
 Endif
     
 For nForA := 1 To Len(oGHJ:aCols)
  DbSelectArea("GHJ")
  DbSetOrder(2)
  lAchou := DbSeek(xFilial("GHJ") + M->GHI_SEQKIT + oGHJ:aCols[nForA, nGhjItemBr] )
  If Inclui .Or. Altera 
   If oGHJ:aCols[nForA, nUGHJ+1] .And. lAchou // exclusao
    RecLock("GHJ", .F., .T.)
     Dbdelete()
    MsUnlock()
    WriteSx2("GHJ")
  	   
   ElseIf !oGHJ:aCols[nForA, nUGHJ+1] .And. !Empty(oGHJ:aCols[nForA, nGhjCcoKit])
    RecLock("GHJ", !lAchou)
     HS_GRVCPO("GHJ", oGHJ:aCols, oGHJ:aHeader, nForA)
	    GHJ->GHJ_FILIAL := xFilial("GHJ")  
	    GHJ->GHJ_SEQKIT := M->GHI_SEQKIT
		   GHJ->GHJ_ALMORI := M->GHI_ALMORI
	   MsUnlock() 
		  
	  Endif 

		Else  	
   If lAchou  // opcao exclusao do menu
    RecLock("GHJ",.F.,.T.)
     Dbdelete()
    MsUnlock()
    WriteSx2("GHJ")
   Endif   
    
  Endif
 Next   
 
 
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VLDA74 º Autor ³ Mario Arizono      º Data ³  05/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para validacao dos campos do kit virtual.            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

FUNCTION HS_VLDA74()
 Local cCodBar  := "", cProdAlt := ""
 Local aArea    := GetArea()
 Local lRet     := .T.
 Local nPosGD   := 0 
 Local lProdalt := GetMV("MV_PRODALT")
 If ReadVar() == "M->GHI_CODKIT"
  M->GHI_BARKIT := M->GHI_SEQKIT + M->GHI_CODKIT
 
 ElseIf ReadVar() == "M->GHI_BARKIT"  // Valida codigo de barras  
	 If !Empty(cCodBar := HS_INIPADR("GHI", 4, M->GHI_BARKIT,"GHI_BARKIT",,.F.))
	 	HS_MsgInf(STR0007+ ALLTRIM(cCodBar) + STR0008,STR0009, STR0010)  //"Código de barras "###" já cadastrado."###"Atenção"###"Validação código de barras."
		 lRet := .F.
	 Endif	

	ElseIf Readvar() == "M->GHI_ALMORI"
  If !(HS_SeekRet("SX5","'AL'+M->GHI_ALMORI",1,.f.,"GHI_DESALM","X5_DESCRI"))
   HS_MsgInf(STR0011,STR0009, STR0012)   //"Almoxarifado inválido."###"Atenção"###"Validação do almoxarifado"
   lRet := .F.
  Endif  
 
 ElseIf Readvar() == "M->GHJ_CCOKIT"
  DbSelectArea("SB1")
  DbSetOrder(1)
  If Dbseek(xFilial("SB1") + M->GHJ_CCOKIT)
   If lProdalt
    cProdalt := HS_PROALT(SB1->B1_COD)
    If !Empty(cProdalt) .And. HS_CountTB("GA0", "GA0_PROPAD = '" + M->GHJ_CCOKIT + "'") = 0
     HS_MsgInf(STR0013,STR0009, STR0014)  //"O Produto não pode ser lançado pois possui produto alternativo, por favor informe o alternativo."###"Atenção"###"Validação do produto."
     Return .F.
    Endif 
   Endif
   If Rastro(M->GHJ_CCOKIT)

    If !(lRet := HS_SELLOTE(M->GHJ_CCOKIT, M->GHI_ALMORI, oGHJ:aCols[oGHJ:nAt, nGhjQtdKit],.T.,,aRotina[nOpcA74, 4]))  
     HS_MsgInf(STR0015,STR0009, STR0014)  //"Produto não possuiu lote disponível."###"Atenção"###"Validação do produto."
    Else
     nPosGD := aScan(oGHJ:aCols, {| aVet | aVet[nGhjCcoKit] + aVet[nGhjLotFor] + aVet[nGhjLotCtl] + aVet[nGhjNumLot] + DToS(aVet[nGhjDtVali]) == M->GHJ_CCOKIT + __cLoteFo + __cLoteCt + __cNumLot + DToS(__dDtVali)})
    Endif
   Else
    nPosGD := aScan(oGHJ:aCols, {| aVet | aVet[nGhjCcoKit] == M->GHJ_CCOKIT })
   Endif
   If lRet
    If nPosGD == 0
     HS_SeekRet("SB1","M->GHJ_CCOKIT",1,.f.,{"GHJ_DESCOM", "GHJ_CODBAR"},{"B1_DESC", "B1_CODBAR"})   
     If Rastro(M->GHJ_CCOKIT)
      oGHJ:aCols[oGHJ:nAt, nGhjNumLot] := __cNumLot
      oGHJ:aCols[oGHJ:nAt, nGhjLotFor] := __cLoteFo  
      oGHJ:aCols[oGHJ:nAt, nGhjLotCtl] := __cLoteCt
      oGHJ:aCols[oGHJ:nAt, nGhjDtVali] := __dDtVali   
      oGHJ:Refresh()    
     Endif    
    Else
     HS_MsgInf(STR0016,STR0009, STR0014)   //"Já existe o produto lançado nos itens do kit."###"Atenção"###"Validação do produto."
     lRet := .F.        
    Endif 
   Endif
  Else
   HS_MsgInf(STR0017,STR0009, STR0014)    //"Produto inválido."###"Atenção"###"Validação do produto."
   lRet := .F.
  Endif
 EndIf
 __cLOTEFO   := Space(Len(GHJ->GHJ_LOTEFO))
 __cLOTECT   := Space(Len(GHJ->GHJ_LOTECT))
 __cNUMLOT   := Space(Len(GHJ->GHJ_NUMLOT))
 __dDTVALI   := CriaVar("GHJ_DTVALI") 

 RestArea(aArea)
 
Return(lRet)
                   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VLDDEL º Autor ³ Mario Arizono      º Data ³  01/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para validacao da delecao do kit virtual.            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 

Static Function FS_VldDel()
 Local lRet := .T.
 Local aArea:= GetArea()
 
 If !Empty(M->GHI_SOLICI)
  HS_MsgInf(STR0018, STR0009, STR0019)  //"Kit não pode ser desmontado pois já foi atendido."###"Atenção"###"Validação da desmontagem"
  lRet := .F.
 Endif 
 RestArea(aArea)
Return(lRet)
