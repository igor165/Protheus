#INCLUDE "HSPAHA31.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA31  บ Autor ณ Manoel Filho       บ Data ณ  27/11/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Kit's                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHA31()                                  
 Local aVerTab := {{"C", "GAG_CODLOC"},;
                   {"C", "GAG_NOMLOC"},;
                   {"C", "GAF_CODVIA"},;
                   {"C", "GAF_DESVIA"}}
 Private cCadastro := STR0006 //"Cadastro de Kit's"
 Private aRotina   := MenuDef()

 Private cG1RTipo := "014"
  
 If !HS_EXISDIC(aVerTab)
  Return()
 Endif 
 DbSelectArea("GAF")
 DbSetOrder(1)

 mBrowse( 6, 1,22,75,"GAF")

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ HSPAH311 ณ Autor ณ Manoel Filho         ณ Data ณ 27/11/2001ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao de Tratamento do Cadastro de Taxas/Diarias Hospital ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HSPAH311(cAlias, nReg, nOpc)
 
 Local nOpcE := nOpc
 Local nOpcG := IIF(aRotina[nOpc, 4] == 2 .OR. aRotina[nOpc, 4] == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
 Local nOpcA := 0
 
 Local aSize  := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGDs := {}

 Private oGAF, oGAG, oGF, oFolder
 Private aHGAG := {}, aCGAG := {}, nUGAG := 0
 Private aHGFC := {}, aCGFC := {}, nUGFC := 0
 
 Private aTela := {}, aGets := {}
 Private nGAG_CCOKIT := 0
 Private nGAG_QTDKIT := 0
 Private nGAG_DESCOM := 0
 Private nGAG_CODBAR := 0
 Private nGAG_CODLOC := 0
 
 Private nGFC_CODLOC := 0
 Private nGFC_CCOKIT := 0

 Private cGAF_CCoKit := ""
 Private cCcoKit_Kit := "", nPos_Kit := 0 

 RegToMemory("GAF", aRotina[nOpc, 4] == 3)
             
 HS_BDados("GAG", @aHGAG, @aCGAG, @nUGAG, 2, M->GAF_CODKIT, IIf(aRotina[nOpc, 4] == 3, Nil, "GAG->GAG_CODKIT == '" + M->GAF_CODKIT + "'"))
 nGAG_CCOKIT := aScan(aHGAG, {|aVet| aVet[2] == "GAG_CCOKIT"})
 nGAG_QTDKIT := aScan(aHGAG, {|aVet| aVet[2] == "GAG_QTDKIT"})
 nGAG_DESCOM := aScan(aHGAG, {|aVet| aVet[2] == "GAG_DESCOM"})
 nGAG_CODBAR := aScan(aHGAG, {|aVet| aVet[2] == "GAG_CODBAR"})
 nGAG_ITEMBR := aScan(aHGAG, {|aVet| aVet[2] == "GAG_ITEMBR"})
 nGAG_CODLOC := aScan(aHGAG, {|aVet| aVet[2] == "GAG_CODLOC"})
 
 If aRotina[nOpc, 4] == 3
  aCGAG[1, nGAG_ITEMBR] := Soma1(aCGAG[1, nGAG_ITEMBR], Len(aCGAG[1, nGAG_ITEMBR]))
 EndIf 

 HS_BDados("GFC", @aHGFC, @aCGFC, @nUGFC, 1, M->GAF_CODKIT, IIf(aRotina[nOpc, 4] == 3, Nil, "GFC->GFC_CODKIT == '" + M->GAF_CODKIT + "'"))
 nGFC_CODLOC := aScan(aHGFC, {|aVet| aVet[2] == "GFC_CODLOC"})  
 nGFC_CCOKIT := aScan(aHGFC, {|aVet| aVet[2] == "GFC_CCOKIT"}) 

 If Altera .and. !Empty(M->GAF_CCOKIT)
  cCcoKit_Kit := M->GAF_CCOKIT
  nPos_Kit := aScan(aCGAG, {|aVet| aVet[nGAG_CCOKIT] == M->GAF_CCOKIT})
 Endif 

 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 026, .T., .T. } )	
 AAdd( aObjects, { 100, 074, .T., .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
 
 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
 
 aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
 aPGDs := MsObjSize( aInfo, aObjects, .T. )

 nOpcA := 0
 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel

  oGAF := MsMGet():New("GAF", nReg, nOpc,,,,, aPObjs[1],, 2,,,,oDlg)
  oGAF:oBox:Align := CONTROL_ALIGN_ALLCLIENT
                                                                            
  @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4]  OF oDlg PIXEL PROMPTS STR0019, STR0020
  oFolder:Align := CONTROL_ALIGN_BOTTOM  
  
  oGAG := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nOpcG,,,"+GAG_ITEMBR",,, 99999,,,,oFolder:aDialogs[1], aHGAG, aCGAG)
  oGAG:oBrowse:Align  := CONTROL_ALIGN_ALLCLIENT
  //oGAG:oBrowse:bDelOk := {|| FS_VExGAG()}
  oGAG:cFieldOk       := "HS_DuplA31()"       

  oGFC := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nOpcG,,,,,, 99999,,,,oFolder:aDialogs[2], aHGFC, aCGFC)
  oGFC:oBrowse:Align  := CONTROL_ALIGN_ALLCLIENT
  oGFC:cFieldOk       := "HS_DuplA31()"  

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(oGAG:TudoOk() .And. HS_TudoOk("GFC", oGFC, nGFC_CODLOC) .And. Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)}, ;
                                                  {|| nOpcA := 0, oDlg:End()})   
                                                  
 If nOpcA == 1
  GrvHSP31(nOpc)
 Endif

Return()

Static Function GrvHSP31(nOpc)
 Local nForA := 0

 If aRotina[nOpc, 4] == 2 // se for consulta, sai..
  Return()
 Endif 

 Begin Transaction 

 If Inclui .or. Altera
  RecLock("GAF", Inclui)
   HS_GRVCPO("GAF")
   GAF->GAF_FILIAL  := xFilial("GAF")
 	 GAF->GAF_LOGARQ  := HS_LOGARQ()
 	MsUnlock()
 	  		 
 Else  // exclusao
  RecLock("GAF",.F.,.T.)
   Dbdelete()
  MsUnlock()
  WriteSx2("GAF") 
 
 Endif
     
 For nForA := 1 To Len(oGAG:aCols)
  DbSelectArea("GAG")
  DbSetOrder(2)
/*  lAchou := DbSeek(xFilial("GAG") + M->GAF_CODKIT + oGAG:aCols[nForA, nGAG_CCOKIT] + M->GAF_ALMORI)*/
  lAchou := DbSeek(xFilial("GAG") + M->GAF_CODKIT + oGAG:aCols[nForA, nGAG_ITEMBR] )
  If Inclui  .or. Altera
   If oGAG:aCols[nForA, nUGAG+1] .And. lAchou // exclusao
    RecLock("GAG", .F., .T.)
     Dbdelete()
    MsUnlock()
    WriteSx2("GAG")
  	   
   ElseIf !oGAG:aCols[nForA, nUGAG+1]
    RecLock("GAG", !lAchou)
     HS_GRVCPO("GAG", oGAG:aCols, oGAG:aHeader, nForA)
	    GAG->GAG_FILIAL := xFilial("GAG")  
	    GAG->GAG_CODKIT := M->GAF_CODKIT
		   GAG->GAG_LOGARQ := HS_LOGARQ()
		   GAG->GAG_ALMORI := M->GAF_ALMORI
	   MsUnlock() 
	   ConfirmSX8()                 
	  
	  Endif 

		Else  	
   If lAchou  // opcao exclusao do menu
    RecLock("GAG",.F.,.T.)
     Dbdelete()
    MsUnlock()
    WriteSx2("GAG")
   Endif   
    
  Endif
 Next   
 
 For nForA := 1 To Len(oGFC:aCols)
  DbSelectArea("GFC")
  DbSetOrder(1)
  lAchou := DbSeek(xFilial("GFC") + M->GAF_CODKIT + oGFC:aCols[nForA, nGFC_CODLOC] + oGFC:aCols[nForA, nGFC_CCOKIT])
  If Inclui  .or. Altera
   If oGFC:aCols[nForA, nUGFC+1] .And. lAchou // exclusao
    RecLock("GFC", .F., .T.)
     Dbdelete()
    MsUnlock()
    WriteSx2("GFC")
  	   
   ElseIf !oGFC:aCols[nForA, nUGFC+1]
    RecLock("GFC", !lAchou)
     HS_GRVCPO("GFC", oGFC:aCols, oGFC:aHeader, nForA)
	    GFC->GFC_FILIAL := xFilial("GFC")  
     GFC->GFC_CODKIT := M->GAF_CODKIT
		   GFC->GFC_LOGARQ := HS_LOGARQ()
	   MsUnlock() 
	   ConfirmSX8()                 
	  
	  Endif 

		Else  	
   If lAchou  // opcao exclusao do menu
    RecLock("GFC",.F.,.T.)
     Dbdelete()
    MsUnlock()
    WriteSx2("GFC")
   Endif   
    
  Endif
 Next   

 End Transaction
 
Return()

/////////////////////////
// Funcao chamada no SX3 - Campo GAG_CCOKIT e GAF_CCOKIT
Function HS_ValKit()
 Local aArea       := GetArea()
 Local lRet        := .T.
 Local nPos_MM     := 0 

 If ReadVar() == "M->GAF_CCOKIT"
  
  If M->GAF_CCOKIT == cCcoKit_Kit
   Return(.T.)
  Endif
    
  If Empty(M->GAF_CCOKIT)
   nPos_MM := 0

  ElseIf lRet := FS_VldPro("M->GAF_CCOKIT", "GAF_DESCOM")
   
   If len(oGAG:aCols) == 1 .and. Empty(oGAG:aCols[1, nGAG_CCOKIT]) .and. !oGAG:aCols[1, nUGAG+1]
    nPos_MM := 1
    
   ElseIf (nPos_MM := aScan(oGAG:aCols, {|aVet| aVet[nGAG_CCOKIT] == M->GAF_CCOKIT})) == 0
     oGAG:AddLine(.F., .F.)
    oGAG:lNewLine := .F.
    nPos_MM := len(oGAG:aCols)
   
   Else
    If oGAG:aCols[nPos_MM, nUGAG+1]  //Se o registro esta deletado
     If lRet := MsgYesNo(STR0015) //"Este produto consta nos itens como deletado. Confirma sua utilizacao como componente principal do kit?"
      oGAG:aCols[nPos_MM, nUGAG+1] := .F.
     Endif 
    Else
     lRet := MsgYesNo(STR0017)  //	"Este produto ja foi incluido como item do kit. Confirma a sua utilizacao como componente principal?"
    Endif
   Endif
  
  Endif
  
  If lRet
   If nPos_MM > 0 .and. Empty(oGAG:aCols[nPos_MM, nGAG_CCOKIT])
    oGAG:aCols[nPos_MM, nGAG_CCOKIT] := M->GAF_CCOKIT
    oGAG:aCols[nPos_MM, nGAG_QTDKIT] := 1
    oGAG:aCols[nPos_MM, nGAG_DESCOM] := M->GAF_DESCOM
    oGAG:aCols[nPos_MM, nGAG_CODBAR] := Posicione("SB1", 1, xFilial("SB1") + M->GAF_CCOKIT, "B1_CODBAR" )      
    oGAG:aCols[nPos_MM, nUGAG+1]     := .F.
   Endif
   //Tratamento do componente principal anterior
   If !Empty(ccCoKit_Kit) .and. MsgYesNo(STR0026 + ALLTRIM(cCCoKit_Kit) + STR0027) //"Voce deseja eliminar o componente principal anterior ("###") do kit?"
    oGAG:aCols[nPos_Kit, nUGAG+1]    := .T.
   Endif
   cCCoKit_Kit := M->GAF_CCOKIT
   nPos_Kit    := nPos_MM
  Endif
	 oFolder:nOption := 1

 ElseIf ReadVar() == "M->GAG_CCOKIT"
  If oGAG:oBrowse:nAt == nPos_Kit
   HS_MsgInf(STR0018, STR0008, STR0006) //"Produto principal do kit nao pode ser alterado!"###"Atencao"###"Cadastro de Kit's"
   Return(.F.)
  Endif
 
  If Empty(M->GAG_CCOKIT)
   HS_MsgInf(STR0016, STR0008, STR0006) //"Por favor, informe o codigo do produto"###"Atencao"###"Cadastro de Kit's"
   Return(.F.)
  Endif

  lRet := FS_VldPro("M->GAG_CCOKIT", "GAG_DESCOM")

 ElseIf ReadVar() == "M->GAG_CODLOC"
  If Empty(M->GAG_CODLOC)
   HS_MsgInf(STR0022, STR0008, STR0006) //	"Por favor, informe o codigo do setor"###"Atencao"###"Cadastro de Kit's"
   Return(.F.)
  ElseIf !HS_SeekRet("GCS", "M->GAG_CODLOC", 1, .f., "GAG_NOMLOC", "GCS_NOMLOC")
   HS_MsgInf(STR0023, STR0008, STR0006) //"Setor nao encontrado"###"Atencao"###"Cadastro de Kit's"
   Return(.F.)
  Endif 
 ElseIf ReadVar() == "M->GAF_CODVIA"
  If Empty(M->GAF_CODVIA)
   HS_MsgInf(STR0029, STR0008, STR0006) //	"Por favor, informe o codigo da via."###"Atencao"###"Cadastro de Kit's"
   Return(.F.)
  ElseIf !HS_SeekRet("GFW", "M->GAF_CODVIA", 1, .f., "GAF_DESVIA", "GFW_DESVIA")
   HS_MsgInf(STR0030, STR0008, STR0006) //"C๓digo da via invแlido."###"Atencao"###"Cadastro de Kit's"
   Return(.F.)
  Endif
 ElseIf ReadVar() == "M->GFC_CODLOC"
  If Empty(M->GFC_CODLOC)
   HS_MsgInf(STR0022, STR0008, STR0006) //	"Por favor, informe o codigo do setor"###"Atencao"###"Cadastro de Kit's"
   Return(.F.)
  ElseIf !HS_SeekRet("GCS", "M->GFC_CODLOC", 1, .f., "GFC_NOMLOC", "GCS_NOMLOC")
   HS_MsgInf(STR0023, STR0008, STR0006) //"Setor nao encontrado"###"Atencao"###"Cadastro de Kit's"
   Return(.F.)
  Endif
   
 ElseIf ReadVar() == "M->GFC_CCOKIT"
  If Empty(M->GFC_CCOKIT)
   HS_MsgInf(STR0021, STR0008, STR0006) //"Por favor, informe o codigo da taxa"###"Atencao"###"Cadastro de Kit's"
   Return(.F.)
  ElseIf !HS_SeekRet("GAA", "M->GFC_CCOKIT", 1, .f., "GFC_DESCOM", "GAA_DESC")
   HS_MsgInf(STR0024, STR0008, STR0006) //"Taxa nao encontrada"###"Atencao"###"Cadastro de Kit's"
   Return(.F.)
  Endif 

 Endif                  

 oGAG:oBrowse:Refresh()
 RestArea(aArea)
 
Return(lRet)

// Funcao que valida na pesquisa do 
// Codigo de Barras (se necessario secundarios)
// Data 24.01.02
// Jose Roberto / Manoel Filho
/////////////////////////////
Function HS_VERCBK(cAlias)
IF SUBSTR(M->GAG_CODBAR,1,3)=="170"
   HS_MsgInf(STR0009, STR0008, STR0006) //"Codigo de barras invalido"###"Aten็ใo"###"Cadastro de Kit's"
   Return(.f.)
ENDIF

IF SUBSTR(M->GAG_CODBAR,1,3)=="010"
   M->GAG_CODBAR := SUBSTR(M->GAG_CODBAR,4,13)
 ELSE
   M->GAG_CODBAR := SUBSTR(M->GAG_CODBAR,1,13)
ENDIF
          
if HS_SeekRet("SB1","M->GAG_CODBAR",5,.f.,"GAG_DESCOM","B1_DESC")
   HS_SeekRet("GBI","SB1->B1_COD",1,.f.,)
   DbSelectArea(cAlias)
   If GBI->GBI_PRODES == "0"
      HS_MsgInf(STR0010, STR0008, STR0006) //"Produto Desativado!"###"Aten็ใo"###"Cadastro de Kit's"
      Return .f.
   Endif
 Else
   if HS_SeekRet("GAP","M->GAG_CODBAR",1,.f.)
      HS_SeekRet("SB1","GAP->GAP_CODIGO",1,.f.,"GAG_DESCOM","B1_DESC")
      DbSelectArea(cAlias)
    Else 
      HS_MsgInf(STR0011, STR0008, STR0006) //"C๓digo de Barras nใo encontrado!"###"Aten็ใo"###"Cadastro de Kit's"
      DbSelectArea(cAlias)
      Return .f.
   Endif
Endif                 
M->GAG_CCOKIT := SB1->B1_COD    
oGAG:obrowse:refresh()
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA31  บ Autor ณ Cibele Peria       บ Data ณ  22/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida a exclusao de um item da getdados (GAG)             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
/*Static Function FS_VExGAG()
 Local lRet := .T.
 
 If !Empty(oGAG:aCols[oGAG:oBrowse:nAt, nGAG_CCoKit]) .and. oGAG:aCols[oGAG:oBrowse:nAt, nGAG_CCoKit] == M->GAF_CCOKIT .and. oGAG:oBrowse:nAt == nPos_Kit
  MsgStop(STR0014) //"Produto principal do kit nao pode ser excluido!"
  oGAG:aCols[oGAG:oBrowse:nAt, nUGAG + 1] := .F.
  oGAG:oBrowse:Refresh()
  lRet := .F.
 Endif                                            		
 
Return(lRet)   */

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldPro บ Autor ณ Cibele Peria       บ Data ณ  01/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida o codigo do produto digitado                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VldPro(cCcoKit, cDesCom)
 Local aArea := GetArea()  
 
 HS_SeekRet("SB1", cCCOKIT, 1, .f., cDesCom, "B1_DESC")
 If !SB1->B1_REQUIS $ "1/3"
  HS_MsgInf(STR0007, STR0008, STR0006) //"Este Produto nใo pode compor um KIT!"###"Aten็ใo"###"Cadastro de Kit's"
  Return(.F.)
 Endif 
     
 DbSelectArea("GBI")         
 DbSetOrder(1)  //GBI_FILIAL + GBI_PRODUTO
 DbSeeK(xFilial("GBI") + &(cCCOKIT) )
   
 If !GBI->GBI_TIPO $ "0/1/4" 
  HS_MsgInf(STR0012, STR0008, STR0006) //"Selecione um produto que seja do tipo Material ou Medicamento!"###"Aten็ใo"###"Cadastro de Kit's"
  Return(.F.)
 Endif
 
 RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_DuplA31บ Autor ณ Cibele Peria       บ Data ณ  01/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida o duplicidade de ocorrencia nas getdados            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_DuplA31()
 Local nPosDupl := 0
 Local nForS    := 0
 Local lRet     := .T.
 
 If Empty(&(ReadVar()))
  Return(.T.)
 Endif 
 
 If ReadVar() == "M->GAG_CCOKIT"
  If (nPosDupl := aScan(oGAG:aCols, {| aVet | aVet[nGAG_CCOKIT] == M->GAG_CCOKIT}) ) <> oGAG:nAt .and. nPosDupl <> 0
 	 	HS_MsgInf(STR0025 + ALLTRIM(STR(nPosDupl)) + ".", STR0008, STR0006) //"Informacao ja cadastrada. Por favor, verifique a linha "###"Aten็ใo"###"Cadastro de Kit's"
 	 	lRet := .F.
	 Endif

 ElseIf ReadVar() == "M->GFC_CODLOC" .and. !Empty(oGFC:aCols[oGFC:nAt, nGFC_CCOKIT])
  If (nPosDupl := aScan(oGFC:aCols, {| aVet | aVet[nGFC_CODLOC] == M->GFC_CODLOC .and. aVet[nGFC_CCOKIT] == oGFC:aCols[oGFC:nAt, nGFC_CCOKIT] }) ) <> oGFC:nAt .and. nPosDupl <> 0
	 	HS_MsgInf(STR0025 + ALLTRIM(STR(nPosDupl)) + ".", STR0008, STR0006) //"Informacao ja cadastrada. Por favor, verifique a linha "###"Aten็ใo"###"Cadastro de Kit's"
	 	lRet := .F.
	 Endif
	 
 ElseIf ReadVar() == "M->GFC_CCOKIT" .and. !Empty(oGFC:aCols[oGFC:nAt, nGFC_CODLOC])
  If (nPosDupl := aScan(oGFC:aCols, {| aVet | aVet[nGFC_CODLOC] == oGFC:aCols[oGFC:nAt, nGFC_CODLOC] .and. aVet[nGFC_CCOKIT] == M->GFC_CCOKIT }) ) <> oGFC:nAt .and. nPosDupl <> 0
	 	HS_MsgInf(STR0025 + ALLTRIM(STR(nPosDupl)) + ".", STR0008, STR0006) //"Informacao ja cadastrada. Por favor, verifique a linha "###"Aten็ใo"###"Cadastro de Kit's"
	 	lRet := .F.
	 Endif

 Endif	 

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 11/07/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao                      ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRotina :=	{{ OemToAnsi(STR0001), "axPesqui", 0, 1, 0, nil},;		//"Pesquisar"
					 { OemToAnsi(STR0002), 'HSPAH311', 0, 2, 0, nil},;		//"Visualizar"
                     { OemToAnsi(STR0003), 'HSPAH311', 0, 3, 0, nil},;		//"Incluir"
                     { OemToAnsi(STR0004), 'HSPAH311', 0, 4, 0, nil},;		//"Alterar"
                     { OemToAnsi(STR0005), 'HSPAH311', 0, 5, 0, nil},;		//"Excluir"
                     { OemToAnsi(STR0028), 'HSPAHA74', 0, 3, 0, nil}}		//"Kit Virtual"  
Return(aRotina)
