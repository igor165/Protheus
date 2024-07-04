#INCLUDE "HSPAHM02.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "Colors.CH"
#INCLUDE "TopConn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM02  บ Autor ณ Patricia Queiroz   บ Data ณ  25/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Amostras                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/                                  
Function HSPAHM02()
                         
 Local aCposMB := {}
                   
 Local bKeyF12 := SetKey(VK_F12, {|| FS_FilM02(.T.)})
  
 Local aCor     := {{"GGP->GGP_CDSITA == '0'", "BR_AMARELO"} , ;                     
                    {"GGP->GGP_CDSITA == '1'", "BR_AZUL"}    , ;
                    {"GGP->GGP_CDSITA == '2'", "BR_CINZA"}   , ;                
                    {"GGP->GGP_CDSITA == '3'", "BR_VERMELHO"}, ;
                    {"GGP->GGP_CDSITA == '4'", "BR_VERDE"}   , ;                   
                    {"GGP->GGP_CDSITA == '5'", "BR_LARANJA"}}                                          

 
 Private aRotina := {{OemtoAnsi(STR0001), "axPesqui"   , 0, 1}, ;  //"Pesquisar"
                     {OemtoAnsi(STR0002), "HS_MntM02"  , 0, 2}, ;  //"Visualizar"
                     {OemtoAnsi(STR0014), "HS_MntM02"  , 0, 4}, ;  //"Recebimento"  
                     {OemtoAnsi(STR0056), "HS_DescAmot", 0, 4}, ;  //"Descartar" 
                     {OemtoAnsi(STR0015), "HS_EtqM02"  , 0, 1}, ;  //"Etiquetas"                                            
                     {OemtoAnsi(STR0020), "HSPAHR13()" , 0, 1}, ;  //"Impressใo"
                     {OemtoAnsi(STR0059), "HS_M02SCol", 0, 3}, ;  //"Solicitar Coleta"
                     {OemtoAnsi(STR0003), "HS_LegM02"   , 0, 1}}    //"Legenda"
                                                      
 Private __aMarkBrow := {}
 Private cCadastro   := STR0004 //"Amostras"
 Private cFilM02     := ""            
 Private cCodProt    := ""
 Private cLote       := Space(Len(GGP->GGP_CDPROT)) 
 Private cGcsTipLoc  := "C"
 Private cPerg := "HSPM02"
 
 If FS_FilM02(.F.)                            
 
  aAdd(aCposMB, { "GGP_IDMARK",, "", "" })
  aAdd(aCposMB, { HS_CfgSx3("GGP_LOCATE")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GGP_LOCATE")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GGP_LOCATE")[SX3->(FieldPos("X3_PICTURE"))] })
  aAdd(aCposMB, { HS_CfgSx3("GGP_DLOATE")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GGP_DLOATE")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GGP_DLOATE")[SX3->(FieldPos("X3_PICTURE"))] })  
  aAdd(aCposMB, { HS_CfgSx3("GGP_REGGER")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GGP_REGGER")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GGP_REGGER")[SX3->(FieldPos("X3_PICTURE"))] })
  aAdd(aCposMB, { HS_CfgSx3("GGP_REGATE")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GGP_REGATE")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GGP_REGATE")[SX3->(FieldPos("X3_PICTURE"))] })
  aAdd(aCposMB, { HS_CfgSx3("GGP_CDPROT")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GGP_CDPROT")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GGP_CDPROT")[SX3->(FieldPos("X3_PICTURE"))] })
  aAdd(aCposMB, { HS_CfgSx3("GGP_CDTIPA")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GGP_CDTIPA")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GGP_CDTIPA")[SX3->(FieldPos("X3_PICTURE"))] })  
  aAdd(aCposMB, { HS_CfgSx3("GGP_CDAMOT")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GGP_CDAMOT")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GGP_CDAMOT")[SX3->(FieldPos("X3_PICTURE"))] })
  aAdd(aCposMB, { HS_CfgSx3("GGP_CDCOLE")[SX3->(FieldPos("X3_CAMPO"))],, HS_CfgSx3("GGP_CDCOLE")[SX3->(FieldPos("X3_TITULO"))], HS_CfgSx3("GGP_CDCOLE")[SX3->(FieldPos("X3_PICTURE"))] })


  DbSelectArea("SX3")
  DbSetOrder(1) //X3_ARQUIVO + X3_ORDEM
  DbSeek("GGP")
  While !Eof() .And. SX3->X3_ARQUIVO == "GGP"
	  If X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_BROWSE == "S" .And. SX3->X3_CONTEXT <> "V" .And. ;
		  aScan(aCposMB, {| aVet | SX3->X3_CAMPO == aVet[1]}) == 0
	  	aAdd(aCposMB, { SX3->X3_CAMPO,, SX3->X3_TITULO, SX3->X3_PICTURE })
	  EndIf	
	  DbSkip()
  End
  
  MarkBrowse("GGP", "GGP_IDMARK",, aCposMB, .F., GetMark(), "HS_M02MBA('GGP', 'GGP_CDAMOT', @__aMarkBrow, cFilM02)",,,,, {|| oMB := GetMarkBrow(), oMB:bMark := {|| HS_M02MBU("GGP_IDMARK", "GGP_CDAMOT", @__aMarkBrow)}}, cFilM02, .T., aCor)
  
 EndIf 
 
 SetKey(VK_F12, bKeyF12)
 
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_MntM02 บ Autor ณ Patricia Queiroz   บ Data ณ  25/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tratamento das funcoes                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
                                                                            */
Function HS_MntM02(cAliasM02, nRegM02, nOpcM02)   

 Local nOpcA      := 0
 Local aSize      := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGGs := {}
 Local nGGOpc	    := GD_DELETE
 Local aCGGP      := {}, aHGGP := {}                
 Local nOpcLote   := 0 
 Local aArea      := GetArea()
 Local cProtocolo := ""

 Private nOpcCol := nOpcM02
 Private aTela 		:= {}
 Private aGets   := {}
 Private aHeader := {}
 Private aCols   := {}
 Private oGGQ, oGGP
 Private nUGGP := 0
 Private nGGPCODBAR := 0, nGGPCDTIPA := 0, nGGPDSTIPA := 0
 Private cCamposN := "", cCampos := ""
 Private cAmostra := ""
 
 
 If nOpcM02 <> 2
  DEFINE MSDIALOG oDlgLote TITLE STR0004 + " - " + STR0021 FROM 000, 000 TO 070, 400  OF oMainWnd PIXEL //"Amostras###Protocolo" 
 
   @ 018, 003 Say OemToAnsi(STR0022) Size 075, 009 OF oDlgLote PIXEL COLOR CLR_BLACK //"Informe o Protocolo :"
   @ 016, 051 MSGet oLote Var cLote F3 "GGQ001" Valid HS_VldLot(cLote,, nOpcM02) Size 020, 009 OF oDlgLote PIXEL COLOR CLR_BLACK 

  ACTIVATE MSDIALOG oDlgLote CENTERED ON INIT EnchoiceBar(oDlgLote, {|| nOpcLote := 1, oDlgLote:End()}, {|| nOpcLote := 0, oDlgLote:End()})
 EndIf 
 
 RegToMemory("GGQ", .F.) 
 nOpcA := 0
 
 M->GGQ_CDPROT := cLote
 
 If nOpcLote == 1 .Or. nOpcM02 == 2
 
  If nOpcM02 == 2 
   cProtocolo := IIF(!Empty(GGP->GGP_CDPROT), GGP->GGP_CDPROT, "A")
  EndIf 
 
  cCamposN := "GGP_CDCOLE/GGP_DATEMI/GGP_USUEMI/GGP_CDSITA/GGP_CDPROT/GGP_CDAMOT/GGP_REGATE/GGP_CDMOTI/GGP_DSMOTI/GGP_NOME  /GGP_DATATE/GGP_CDITEM"
  cCamposN += "GGP_REGGER/GGP_UNICOL/GGP_DSUNIC" 
  cCampos  := "GGP_CODBAR/GGP_CDTIPA/GGP_DSTIPA" 
 
  HS_BDados("GGP", @aHGGP, @aCGGP, @nUGGP, 1,, IIF(nOpcM02 == 3, "GGP->GGP_CDPROT == '" + cLote + "'", IIF(nOpcM02 == 2, "GGP->GGP_CDPROT == '" + cProtocolo + "'", Nil)),,, cCampos,, cCamposN, .F.)
  nGGPCODBAR := aScan(aHGGP, {| aVet | aVet[2] == "GGP_CODBAR"})
  nGGPCDTIPA := aScan(aHGGP, {| aVet | aVet[2] == "GGP_CDTIPA"})
  nGGPDSTIPA := aScan(aHGGP, {| aVet | aVet[2] == "GGP_DSTIPA"})    
  
  aSize := MsAdvSize(.T.)
  aObjects := {}
  AAdd(aObjects, {100, 050, .T., .T.})
  AAdd(aObjects, {100, 050, .T., .T.})

  aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
  aPObjs := MsObjSize(aInfo, aObjects, .T.) 
  
  DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0004) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd  //"Amostras"
                                
   oGGQ := MsMGet():New("GGQ", nRegM02, nOpcM02,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
   oGGQ:oBox:align := CONTROL_ALIGN_ALLCLIENT
  
   oGGP := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2],aPObjs[2, 3], aPObjs[2, 4], nGGOpc,,,,,,,,,,, aHGGP, aCGGP)
   oGGP:oBrowse:Align := CONTROL_ALIGN_BOTTOM
   
   If nOpcM02 == 2 .And. cProtocolo == "A"
    oGGP:aCols[oGGP:nAt, nGGPDSTIPA] := ""
    oGGP:oBrowse:Refresh()
   EndIf
   
   If nOpcM02 == 3
    M->GGQ_RESREC := cUserName
   EndIf                   
  
   HS_AdiItem(oGGP)
     
  ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(FS_GrvM02(nOpcM02, oGGP), oDlg:End(), nOpcA == 0)}, ;
                                                    {|| nOpcA := 0, oDlg:End()}) 
 EndIf                                                    
 
 If nOpcA == 1 .And. nOpcM02 == 3
  HSPAHR13(cCodProt)     
 EndIf                      
 
 RestArea(aArea)
 
Return(Nil)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_DescAmot บ Autor ณ Patricia Queiroz  บ Data ณ  25/01/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta a tela para descarte das amostras.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
                                                                            */
Function HS_DescAmot(cAliasM02, nRegM02, nOpcM02)

 Local nOpcA    := 0
 Local aSize    := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGGs := {}
 Local nGGOpc	  := GD_DELETE
 Local aCGGP    := {}, aHGGP := {}
 Local oLote, oCodMot, oDesMot
 Local nOpcLote := 0  

 Private aTela 		 := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private oGGP, oDlgD
 Private nUGGP    := 0
 Private nGGPCODBAR := 0, nGGPCDTIPA := 0, nGGPDSTIPA := 0
 Private cCamposN := "", cCampos := ""
 Private cCodBar  := Space(Len(GGP->GGP_CODBAR))
 Private cCodMot  := Space(Len(GGS->GGS_CDMOTI))
 Private cDesMot  := Space(Len(GGS->GGS_DSMOTI)) 
 
 nOpcA := 0 
 
 cCamposN := "GGP_CDCOLE/GGP_DATEMI/GGP_USUEMI/GGP_CDSITA/GGP_CDPROT/GGP_CDAMOT/GGP_REGATE/GGP_CDMOTI/GGP_DSMOTI/GGP_NOME  /GGP_DATATE/GGP_CDITEM"
 cCamposN += "GGP_REGGER/GGP_UNICOL/GGP_DSUNIC" 
 cCampos  := "GGP_CODBAR/GGP_CDTIPA/GGP_DSTIPA" 

 HS_BDados("GGP", @aHGGP, @aCGGP, @nUGGP, 1,,,,, cCampos,, cCamposN, .F.)
 nGGPCODBAR := aScan(aHGGP, {| aVet | aVet[2] == "GGP_CODBAR"})
 nGGPCDTIPA := aScan(aHGGP, {| aVet | aVet[2] == "GGP_CDTIPA"})
 nGGPDSTIPA := aScan(aHGGP, {| aVet | aVet[2] == "GGP_DSTIPA"})

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 050, .T., .T.})
 AAdd(aObjects, {100, 050, .T., .T.})
 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.) 
 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0004) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd  //"Amostras"
 
  @ 15, 005 SAY OemToAnsi(STR0055) OF oDlgD PIXEL COLOR CLR_BLUE //"Motivo Descarte"
  @ 15, 048 MSGET oCodMot VAR cCodMot Valid cDesMot := HS_IniPadr("GGS", 1, cCodMot, "GGS_DSMOTI", .F.) SIZE 060, 4 OF oDlgD F3 "GGS001" PIXEL COLOR CLR_BLACK
  
  @ 15, 130 SAY OemToAnsi(STR0054) OF oDlgD PIXEL COLOR CLR_BLUE //"Descricao"
  @ 15, 158 MSGET oDesMot VAR cDesMot SIZE 060, 4 OF oDlgD PIXEL WHEN .F.
  
  @ 30, 005  SAY OemToAnsi(STR0023) OF oDlgD PIXEL COLOR CLR_BLUE //"Cod. Barra" 
  @ 30, 048 MSGET oCodBar VAR cCodBar Valid HS_VldML(nOpcM02) SIZE 060, 4 OF oDlgD PIXEL COLOR CLR_BLACK
  
  oGGP := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2],aPObjs[2, 3], aPObjs[2, 4], nGGOpc,,,,,,,,,,, aHGGP, aCGGP)
  oGGP:oBrowse:Align := CONTROL_ALIGN_BOTTOM
  
  oGGP:aCols[oGGP:nAt, nGGPDSTIPA] := ""
  oGGP:oBrowse:Refresh()
  
  HS_AdiItem(oGGP)

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(FS_GrvM02(nOpcM02, oGGP), oDlg:End(), nOpcA == 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})
                                                    

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvM02 บAutor  ณPatricia Queiroz    บ Data ณ  26/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณTrava tabela para Inclusao, Alteracao e Exclusao.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvM02(nOpcM02, oGGP)

Local nFor := 0
Local lRet := .T.


If (lRet := Obrigatorio(aGets, aTela) .And. FS_VldGrv(nOpcM02, cLote))

 Begin Transaction  
  If nOpcM02 == 3 .Or. nOpcM02 == 4 //Opcao Recebimento ou Descartar
  
   cCodProt := cLote

   For nFor := 1 To Len(oGGP:aCols)
    DbSelectArea("GGP")
    DbSetOrder(1) // GGP_FILIAL + GGP_CDAMOT + GGP_CDSITA
    If DbSeek(xFilial("GGP") + SubStr(oGGP:aCols[nFor, nGGPCODBAR], 1, 6)) .And. oGGP:aCols[nFor, nUGGP + 1]
     RecLock("GGP", .F.)
      GGP->GGP_CDPROT := IIF(nOpcM02 == 4, GGP->GGP_CDPROT, cCodProt)
      GGP->GGP_CDSITA := IIF(nOpcM02 == 3, "2", "3")     
      GGP->GGP_CDMOTI := IIF(nOpcM02 == 4, cCodMot, Space(Len(GGP->GGP_CDMOTI)))
     MsUnLock() 
     cAmostra += IIF(Empty(cAmostra), "", ", ") + "'" + SubStr(oGGP:aCols[nFor, nGGPCODBAR], 1, 6) + "'"
    EndIf
   Next() 
  EndIf

  If nOpcM02 == 3 // Recebimento
   RecLock("GGQ", .F.)
    HS_GrvCpo("GGQ")
    GGQ->GGQ_CDPROT := cCodProt
    GGQ->GGQ_SITLOT := "2"
    MsUnlock()	   
  EndIf   

 End Transaction  
EndIf 

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldM02 บAutor  ณPatricia Queiroz    บ Data ณ  26/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacao lanca o codigo do tipo de amostra e a descricao   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldM02()

Local aArea := GetArea()
Local lRet  := .T.
Local aVet  := {}
Local nPos  := 0

If ReadVar() == "M->GGQ_CODBAR"
 If !Empty(M->GGQ_CODBAR)
  If !(lRet := (HS_SeekRet("GGP", "SubStr(M->GGQ_CODBAR, 1, 6)", 1, .F.)))
   HS_MsgInf(STR0008, STR0005, STR0007) //"Esta amostra nใo existe."###"Aten็ใo"###"Valida็ใo de Amostras"
  ElseIf nOpcCol == 3 .And. !(lRet := GGP->GGP_CDSITA == "1")
   HS_MsgInf(STR0016, STR0005, STR0007) //"Nใo ้ permitido o recebimento desta amostra, pois nใo se encontra Em Trโnsito."###"Aten็ใo"###"Valida็ใo de Amostras"
  ElseIf nOpcCol == 3 .And. !(lRet := HS_IniPadr("GGP", 1, SubStr(M->GGQ_CODBAR, 1, 6), "GGP_CDPROT", .F.) == M->GGQ_CDPROT)
   HS_MsgInf(STR0017, STR0005, STR0007) //"Nใo ้ permitido o lan็amento de amostras com protocolo diferente."###"Aten็ใo"###"Valida็ใo de Amostras"
  EndIf
  
  If lRet                     
   nPos := aScan(oGGP:aCols, {|aVet| SubStr(aVet[nGGPCODBAR], 1, 6) == SubStr(M->GGQ_CODBAR, 1, 6)})
   oGGP:aCols[nPos, nUGGP + 1] := .T.
  EndIf
  
  oGGP:oBrowse:Refresh()
  
  M->GGQ_CODBAR := Space(Len(M->GGQ_CODBAR))
  oGGQ:AENTRYCTRLS[aScan(oGGQ:aGets, {| aVet | "GGQ_CODBAR"	$ aVet})]:SetFocus()
  lRet := .T.   
  
 EndIf 
EndIf 

RestArea(aArea)

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldML บAutor  ณPatricia Queiroz    บ Data ณ  08/01/07    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida as amostras lan็adas no protoclo.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldML(nOpc)

Local aArea := GetArea()
Local lRet  := .T.
Local aVet  := {}
Local nPos  := 0

If !Empty(cCodBar)
 If !(lRet := (aScan(oGGP:aCols, {|aVet| SubStr(aVet[nGGPCODBAR], 1, 6) == SubStr(cCodBar, 1, 6)}) == 0 ))
  HS_MsgInf(STR0006, STR0005, STR0007)  //"Esta amostra jแ foi adicionada."###"Aten็ใo"###"Valida็ใo de Amostras"
 ElseIf !(lRet := (HS_SeekRet("GGP", "SubStr(cCodBar, 1, 6)", 1, .F.)))
  HS_MsgInf(STR0008, STR0005, STR0007) //"Esta amostra nใo existe."###"Aten็ใo"###"Valida็ใo de Amostras"
 ElseIf nOpc <> 4
  If !(lRet := GGP->GGP_CDSITA == "0")
   HS_MsgInf(STR0024, STR0005, STR0007) //"Nใo ้ permitido o lan็amento desta amostra, pois nใo se encontra Coletada."###"Aten็ใo"###"Valida็ใo de Amostras"
  EndIf 
 EndIf 
 If !Empty(oGGP:aCols[oGGP:nAt, nGGPCODBAR]) .And. lRet
  oGGP:AddLine(.F., .F.)                    
  oGGP:lNewLine := .F.
  nPos := Len(oGGP:aCols)
 Else
  nPos := oGGP:nAt
 EndIf
 If lRet
  oGGP:aCols[nPos, nGGPCODBAR] := cCodBar
  oGGP:aCols[nPos, nGGPCDTIPA] := HS_IniPadr("GGP", 1, SubStr(cCodBar, 1, 6), "GGP_CDTIPA",, .F.)
  oGGP:aCols[nPos, nGGPDSTIPA] := HS_IniPadr("GGG", 1, GGP->GGP_CDTIPA, "GGG_DSTIPA",, .F.)
 EndIf
 oGGP:oBrowse:Refresh()
 
 cCodBar := Space(Len(GGP->GGP_CDPROT))
 oCodBar:SetFocus()
 lRet := .T.     
 
EndIf 

RestArea(aArea)

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldGrv บAutor  ณPatricia Queiroz    บ Data ณ  27/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacao os dados para gravacao                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VldGrv(nOpc, cLote)

Local nFor  := 0
Local lRet  := .T.  
Local nCont := 0, nContGGP := 0
Local aArea := GetArea()

If nOpc == 3
 DbSelectArea("GGP")
 DbSetOrder(4) //GGP_FILIAL + GGP_CDPROT
 If DbSeek(xFilial("GGP") + cLote)
  While !Eof() .And. GGP->GGP_FILIAL == xFilial("GGP") .And. GGP->GGP_CDPROT == cLote
   nCont++  
   DbSkip()
  EndDo  
 EndIf
 
 For nFor := 1 To Len(oGGP:aCols) 
  If oGGP:aCols[nFor, nUGGP + 1] 
   nContGGP++
  EndIf    
 Next   

 If nCont <> nContGGP
  lRet := MsgYesNo(STR0053, STR0005) //"Nใo foram lan็adas todas as amostras para este lote. Deseja continuar?"###"Aten็ใo" 
 EndIf  
ElseIf nOpc == 4 .And. lRet  
 If Empty(cCodMot)
  HS_MsgInf(STR0052, STR0005, STR0043) //"Por favor preencha o motivo de descarte."###"Aten็ใo"###"Valida็ใo de Campos"
  lRet := .F.  
 EndIf
 
EndIf     

RestArea(aArea)

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_LegM02 บAutor  ณPatricia Queiroz    บ Data ณ  25/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณMonta Legenda                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_LegM02()

BrwLegenda(STR0004, STR0003, {{'BR_AMARELO' , STR0009} ,;  //Amostras###"Legenda"###"Coletada"
                              {'BR_AZUL'    , STR0010} ,;  //"Em Trโnsito"
                              {'BR_CINZA'   ,	STR0011} ,;  //"Em Anแlise"
                              {'BR_VERMELHO',	STR0012} ,;	 //"Descartada"
                              {'BR_VERDE'   ,	STR0013} ,;  //"Liberada"
                              {'BR_LARANJA' ,	STR0021}})   //"Protocolo"
Return(.T.)                                                            




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M02MBA บAutor  ณPatricia Queiroz    บ Data ณ  16/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณMarca todos os campos                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_M02MBA(cAliasM02, cCpos, aMBrow, cCondSql, lDesmarca)

 Local cSql  := "", cIndexKey := (cAliasM02)->(IndexKey()), cCposSql := cCpos, cCposTmp := cIndexKey
 Local aArea := GetArea(), nPCpo := 0

 Default cCondSql := PrefixoCpo(cAliasM02) + "_FILIAL = '" + xFilial(cAliasM02) + "' AND D_E_L_E_T_ <> '*'"
 Default lDesmarca := ThisInv()

 CursorWait()

 NewMark()
 
 SetInvert(!lDesmarca)
        
 If !lDesmarca
  aMBrow := {}            
  
  cCposSql := cCpos
  
  While !Empty(cCposTmp)         
   nPCpo := At("+", cCposTmp)    
   nPCpo := IIf(nPCpo > 0, nPCpo, Len(cCposTmp) + 1)
   If !(SubStr(cCposTmp, 1, nPCpo - 1) $ cCposSql)
    cCposSql += ", " + SubStr(cCposTmp, 1, nPCpo - 1)
   EndIf                                  
   
   cCposTmp := SubStr(cCposTmp, nPCpo + 1)
  End
  
  cSql := "SELECT " + cCposSql + " FROM " + RetSqlName("GGP") + " WHERE " + cCondSql
  cSql += " ORDER BY " + SqlOrder((cAliasM02)->(IndexKey()))
  
  cCpos := StrTran(cCpos, cAliasM02 + "_", "QRYMRK->" + cAliasM02 + "_")
  cCpos := StrTran(cCpos, ",", "+")
  
  cIndexKey := StrTran(cIndexKey, cAliasM02 + "_", "QRYMRK->" + cAliasM02 + "_")
  
  TCQUERY cSql NEW ALIAS "QRYMRK"
  
  While !Eof()                                        
   aAdd(aMBrow, {&(cCpos), &(cIndexKey)})
     
   DbSkip()
  End
  
  DbCloseArea()
 Else
  aMBrow := {}
 EndIf 
  
 CursorArrow()        
 
 RestArea(aArea)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M02MBU บAutor  ณPatricia Queiroz    บ Data ณ  16/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณMarca apenas um registro                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                     
Function HS_M02MBU(cCpoMrk, cCposChv, aMBrow)
 Local nPMark := 0
 
 IF IsMark(cCpoMrk, ThisMark(), ThisInv())
  aAdd(aMBrow, {&(cCposChv), &(indexkey())})
 ElseIf (nPMark := aScan(aMBrow, {| aVet | aVet[1] == &(cCposChv)})) > 0
  aDel(aMBrow, nPMark)
  aSize(aMBrow, Len(aMBrow) - 1)
 EndIf
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_EtqM02  บAutor  ณPatricia Queiroz    บ Data ณ  16/11/06  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณImprimi as etiquetas de acordo com as amostras selecionadas.บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                     
Function HS_EtqM02()

 Local aArea    := GetArea()
 Local cCodEtq  := ""
 Local cCodTipa := ""
 Local cCodBar  := ""
 Local oGGP
 Local aHGGP := {}, aCGGP := {}	
 Local nOpcA := 0
 
 Private cUsu   := Space(15) 
 Private nGGPIDMARK := 0; nGGPCDAMOT := 0
 
 
 If FS_Login()
 
  If FunName() == "HSPAHM01"
  
   DbSelectArea("GGP")
   DbSetOrder(1) //GGP_FILIAL + GGP_CDAMOT + GGP_CDSITA
  
   HS_BDados("GGP", @aHGGP, @aCGGP,, 1,, "GGP->GGP_CDCOLE == '" + GGO->GGO_CDCOLE + "'",,,,,,, "GGP_IDMARK", "'LBTIK'")
   nGGPIDMARK := aScan(aHGGP, {| aVet | aVet[2] == "GGP_IDMARK"})
   nGGPCDAMOT := aScan(aHGGP, {| aVet | aVet[2] == "GGP_CDAMOT"}) 
   
   aSize := MsAdvSize(.T.)
   aObjects := {}
   AAdd(aObjects, {100, 100, .T., .T.})

   aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
   aPObjs := MsObjSize(aInfo, aObjects, .T.)
   
   DEFINE MSDIALOG oDlg TITLE OemToAnsi("Amostras") From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd
   
    oGGP := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4],,,,,,,,,,,, aHGGP, aCGGP)
    oGGP:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                     
    oGGP:oBrowse:BlDblClick := {|| FS_DblClik(oGGP)}  
    
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIF(FS_GrvEtiq(oGGP), oDlg:End(), nOpcA == 0)}, ;
                                                    {|| nOpcA := 0, oDlg:End()})      
  EndIf 
 
  If nOpcA == 1 .Or. FunName() == "HSPAHM02"
  
   FS_GrvGGZ(__aMarkBrow)
   
   If !Empty(__aMarkBrow)
    aSort(__aMarkBrow,,, {|x,y| x[1] < y[1]})
   
    cCodBar := __aMarkBrow[1, 1]
   
    cCodTipa := HS_IniPadr("GGP", 1, cCodBar, "GGP_CDTIPA",, .F.)
    If Empty(cCodEtq  := HS_IniPadr("GGG", 1, cCodTipa, "GGG_CDETIQ",, .F.))
     HS_MsgInf(STR0019, STR0005, STR0007)//"Nใo hแ etiquetas para as amostras."###"Aten็ใo"###"Valida็ใo de Amostras"
     Return(.F.)                                                                        	
    EndIf 
    HSPAHR71(AllTrim(cCodEtq), { 1, __aMarkBrow[1, 1], __aMarkBrow[Len(__aMarkBrow), 1]})
   Else
    HS_MsgInf(STR0018, STR0005, STR0007) //"Nใo hแ amostras selecionadas."###"Aten็ใo"###"Valida็ใo de Amostras"
    Return(.F.)
   EndIf 
  EndIf 
 EndIf
 
 RestArea(aArea)
 
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FilM02  บAutor  ณPatricia Queiroz    บ Data ณ  05/01/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para filtrar as amostras.                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/     
Static Function FS_FilM02(lSetFilter)
 //Setor Coleta
 //Data Inicial
 //Data Final   
 //Protocolo
 // Situacao - Nao tera mais... serao filtradas todas

 Local lRet     := .T.
 Local oObjMBrw := GetMarkBrow()
 Local cLote    := "", cLocAte := ""
 Local dDatini, dDatFim
 
 If !Pergunte(cPerg)
  Return(.F.)
 EndIf
 
 cLocAte := MV_PAR01
 dDatini := MV_PAR02
 dDatFim := MV_PAR03 
 cLote   := MV_PAR04 
  
 cFilM02 := "GGP_FILIAL = '" + xFilial("GGP") + "' AND D_E_L_E_T_ <> '*' " 
 If !Empty(clote) 
  cFilM02 += "AND GGP_CDPROT = '" + cLote + "' "              
 EndIf    
 cFilM02 +=  "AND GGP_CDCOLE IN (SELECT GGO_CDCOLE FROM " + RetSqlname("GGO") + " GGO " +;
                                "WHERE GGO_FILIAL = '" + xFilial("GGO") + "' AND GGO.D_E_L_E_T_ <> '*' " +;
                                  "AND GGO_CDCOLE = GGP_CDCOLE " +;
                                  "AND GGO_DATINI BETWEEN '" + DTOS(dDatIni) + "' AND '" + DTOS(dDatFim) + "' " +;
             IIf(!Empty(cLocAte),"AND GGO_LOCATE = '" + cLocAte + "'","") + ")"
 
 DbSelectArea("GGP") 
 
 If lSetFilter
  MsgRun(STR0057, ,{|| SetMBTopFilter("GGP", cFilM02), oObjMBrw:oBrowse:GoTop(), oObjMBrw:oBrowse:Refresh()}) //"Selecionando registros...", "Aguarde..." 
 EndIf
 
Return(.T.)
            


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldLot บAutor  ณPatricia Queiroz    บ Data ณ  08/01/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida se o protocolo informado existe.                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldLot(cLote, nOpcML, nOpcM02)

 Local aArea := GetArea()
 Local lRet  := .T. 
 Local cSql  := ""
 
 Default nOpcM02 := 0
 Default nOpcML  := 0
 
 cSql := "SELECT COUNT(*) NTOTAL "
 cSql += "FROM " + RetSqlName("GGP") + " GGP "
 cSql += "WHERE GGP.GGP_FILIAL = '" + xFilial("GGP") + "' AND GGP.D_E_L_E_T_ <> '*' "
 cSql += "AND GGP.GGP_CDPROT = '" + cLote + "'"
 
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 
 DbSelectArea("QRY")
 If QRY->NTOTAL == 0
  HS_MsgInf(STR0038, STR0005, STR0039) //"Este protocolo nใo existe."###"Aten็ใo"###"Valida็ใo de Protocolo"
  lRet := .F.
 EndIf 
 
 If lRet 
  If !(lRet := HS_IniPadr("GGQ", 1, cLote, "GGQ_SITLOT", .F.) <> "2")  
   HS_MsgInf(STR0040, STR0005, STR0039)//"Este protocolo nใo pode ser utilizado, pois estแ encerrado."###"Aten็ใo"###"Valida็ใo de Protocolo"
  ElseIf (nOpcML == 2 .Or. nOpcM02 == 3) .And. !(lRet := HS_IniPadr("GGQ", 1, cLote, "GGQ_SITLOT", .F.) == "0") .And. FunName() == "HSPAHM01"
   HS_MsgInf(STR0041, STR0005, STR0039) //"Este protocolo nใo pode ser utilizado, pois nใo estแ Liberado."###"Aten็ใo"###"Valida็ใo de Protocolo"
  ElseIf FunName() == "HSPAHM02"
   If nOpcM02 == 3 .And. !(lRet := HS_IniPadr("GGQ", 1, cLote, "GGQ_SITLOT", .F.) == "1") 
   HS_MsgInf(STR0042, STR0005, STR0039)//"Este protocolo nใo pode ser utilizado, pois nใo foi efetuada a saํda."###"Aten็ใo"###"Valida็ใo de Protocolo"
   EndIf 
  EndIf 
 EndIf
 
 DbCloseArea()

 RestArea(aArea)

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_AdiItem บAutor  ณPatricia Queiroz    บ Data ณ  08/01/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Adiciona o item ao codigo da amostra.                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
 Function HS_AdiItem(oGGP)
 
 Local aArea := GetArea()
 Local nFor  := 0
 
 For nFor := 1 To Len(oGGP:aCols)
  oGGP:aCols[nFor, nGGPCODBAR] := AllTrim(oGGP:aCols[nFor, nGGPCODBAR]) + HS_IniPadr("GGP", 1, AllTrim(oGGP:aCols[nFor, nGGPCODBAR]), "GGP_CDITEM",, .F.)
 Next
                                                                        
 oGGP:oBrowse:Refresh() 
 RestArea(aArea) 

Return(Nil)
                                



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Login บAutor  ณPatricia Queiroz    บ Data ณ  24/01/07    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta a tela para informar o usuario responsavel pela      บฑฑ
ฑฑบ            reimpressao de etiqueta.                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_Login()

Local cSenha := Space(6)
Local lRet   := .F.

DEFINE MSDIALOG oDlgS TITLE OemToAnsi(STR0049) From 3, 0 To 09, 44 Of oMainWnd //"Autoriza็ใo"
 
@ 15, 010 SAY OemToAnsi(STR0050) OF oDlgS PIXEL COLOR CLR_BLUE //"Usuแrio:" 
@ 15, 035 MSGET OUsuario VAR cUsu SIZE 060, 4 OF oDlgS PIXEL COLOR CLR_BLACK
@ 30, 010 SAY OemToAnsi(STR0051) OF oDlgS PIXEL COLOR CLR_BLUE  //"Senha:"
@ 30, 035 MSGET OSenha VAR cSenha SIZE 040, 4 PASSWORD OF oDlgS PIXEL COLOR CLR_BLACK
ACTIVATE MSDIALOG oDlgS ON INIT EnchoiceBar(oDlgS, {|| IIF(lRet := FS_Verific(@cUsu, cSenha), oDlgS:End(), Nil)}, {||lRet := .F., oDlgS:End()}) CENTER
 
Return(lRet)
            


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Verific บAutor  ณPatricia Queiroz    บ Data ณ  24/01/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida o usuario responsavel pela reimpressao de etiqueta. บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_Verific(cUsu, cSenha)

Local lRet     := .T.
Local cMvResAu := GETMV("MV_RESAUTO")
 
If Empty(cUsu)  
 PswOrder(3)
 If PswSeek(cSenha, .T.)
  cUsu := pswret(1)[1, 2]
  lRet := .T.
 Else
  HS_MsgInf(STR0044, STR0005, STR0045) //"Senha Invแlida."###"Aten็ใo"###"Valida็ใo de Senha"
  lRet := .F.
 EndIf 
Else
 If !(lRet := AllTrim(cUsu) $ cMvResAu)
  HS_MsgInf(STR0046, STR0005, STR0047) //"O usuแrio informado nใo possui autoriza็ใo."###"Aten็ใo"###"Valida็ใo de Usuแrio"
 Else
  PswOrder(2)
  If PswSeek(cUsu, .T.)
   If PswName(cSenha)
    lRet := .T.
   Else
    HS_MsgInf(STR0044, STR0005, STR0045) //"Senha Invแlida."###"Aten็ใo"###"Valida็ใo de Senha"
    lRet := .F.
   EndIf
  Else
   HS_MsgInf(STR0048, STR0005, STR0047) //"Usuแrio nใo cadastrado."###"Aten็ใo"###"Valida็ใo de Usuแrio"
   lRet := .F.
  EndIf 
 EndIf 
EndIf
 
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvGGZ บAutor  ณPatricia Queiroz    บ Data ณ  24/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava o Log de reimpressao das etiquetas.                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvGGZ(__aMarkBrow)

Local aArea := GetArea()
Local nFor  := 0

Begin Transaction 

 DbSelectArea("GGZ")

 For nFor := 1 To Len(__aMarkBrow)
  RecLock("GGZ", .T.)
   GGZ->GGZ_CODLOG := GetSXENum("GGZ", "GGZ_CODLOG",, 1)   
   GGZ->GGZ_CDAMOT := __aMarkBrow[1, 1]
   GGZ->GGZ_CDPROT := HS_IniPadr("GGP", 1, __aMarkBrow[1, 1], "GGP_CDPROT",, .F.) 
   GGZ->GGZ_CDTIPA := HS_IniPadr("GGP", 1, __aMarkBrow[1, 1], "GGP_CDTIPA",, .F.) 
   GGZ->GGZ_CODUSU := cUsu
   GGZ->GGZ_DATREI := dDataBase
   GGZ->GGZ_HORREI := Time()
   GGZ->GGZ_FILIAL := xFilial("GGZ")
  MsUnLock()
 Next 
End Transaction

RestArea(aArea)

Return(Nil)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvEtiq บAutor  ณPatricia Queiroz    บ Data ณ  23/02/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Incluir no vetor as amostras selecionadas para a impressใo บฑฑ
บฑฑ            das etiquetas.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                 
Static Function FS_GrvEtiq(oGGAmo)

 Local aArea := GetArea()
 Local lRet  := .T.
 Local nFor  := 0
 
 For nFor := 1 To Len(oGGAmo:aCols)
  If oGGAmo:aCols[nFor, nGGPIDMARK] == "LBTIK" 
   aAdd(__aMarkBrow, {oGGAmo:aCols[nFor, nGGPCDAMOT], " "})
  EndIf
 Next
 
 If !(lRet := !(Empty(__aMarkBrow)))
  HS_MsgInf(STR0058, STR0005, STR0007) //"Nใo hแ amostras selecionadas. Selecione amostras ou cancele a opera็ใo."###"Aten็ใo"###"Valida็ใo de Amostras"
 EndIf

 RestArea(aArea)

Return(lRet)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DblClik บAutor  ณPatricia Queiroz    บ Data ณ  24/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para marcar e desmarcar o item.                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DblClik(oGGP)

 If oGGP:aHeader[oGGP:oBrowse:nColPos, 2] == "GGP_IDMARK"
  oGGP:aCols[oGGP:oBrowse:nAt, nGGPIDMARK] := IIf(oGGP:aCols[oGGP:oBrowse:nAt, nGGPIDMARK] == "LBTIK", "LBNO", "LBTIK")
 Else
  oGGP:EDITCELL(oGGP:oBrowse, oGGP:oBrowse:nAt, oGGP:oBrowse:nColPos)
 EndIf
 
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M02SColบAutor  ณLuiz Pereira S. Jr. บ Data ณ  28/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera solicita็ใo de coleta                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_M02SCol(cAlias, nReg, nOpc)

 Local nOpcA    := 0
 Local nGDOpc   := 0
 Local aSize    := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local oGGO, aCposAlt := {}
 
 Private aTela := {}
 Private aGets := {}
 Private cRegAte  := ""
 Private aAmostra := {}
  
 DbSelectArea("SX3")
 DbSetOrder(1) //GGO_FILIAL + GGO_CDCOLE + GGO_REGATE
 DbSeek("GGO")
 While !Eof() .And. SX3->X3_ARQUIVO == "GGO"
  If !(SX3->X3_CAMPO $ "GGO_DATFIN/GGO_HORFIN/GGO_INTERC/GGO_COLINT/GGO_CDUSUA")
   aAdd(aCposAlt, SX3->X3_CAMPO)
  EndIf
  DbSkip()
 End

 DbSelectArea("GCY")
 DbSetOrder(1) //GCY_FILIAL+GCY_REGATE
 DbSeek(xFilial("GCY") + GGP->GGP_REGATE)
 
 RegToMemory("GGO", .T.)
 
 M->GGO_REGATE := GCY->GCY_REGATE
 HS_VldM01("M->GGO_REGATE")
 
 M->GGO_USUSOL := cUserName

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 100, .T., .T.})

 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)
 
 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0060) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd  //"Coleta"

  oGGO := MsMGet():New("GGO"    , GGO->(Recno()), nOpc,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, aCposAlt,,,,, oDlg)
  oGGO:oBox:align:= CONTROL_ALIGN_ALLCLIENT
    
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, If(Obrigatorio(aGets,aTela), oDlg:End(),nOpcA := 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1
  Begin Transaction
 
   FS_GrvSCol()
  
   While __lSx8
    ConfirmSx8()
   EndDo
   
  End Transaction
 Else 
  While __lSx8
   RollBackSx8() 
  End 
 EndIf
 
 MbrChgLoop(.F.)

Return()

Static Function FS_GrvSCol()

 RecLock("GGO", .T.)
  HS_GrvCpo("GGO")
  GGO->GGO_DATINI := CTOD("  /  /  ")
  GGO->GGO_HORINI := Space(Len(GGO->GGO_HORINI))
  GGO->GGO_SITCOL := "6"
 MsUnlock()	

Return()
