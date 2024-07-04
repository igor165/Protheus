#INCLUDE "HSPAHM09.ch"
#include "protheus.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM09  บ Autor ณ Jos้ Orfeu                ณ  26/03/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Confirmacao da Devolucao  (Armazem e Posto)                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHM09()
 Local aCores := {{"GBD->GBD_FLGDEV == '0'", 'BR_VERDE'   },;
                  {"GBD->GBD_FLGDEV == '1'", 'BR_AMARELO' },;
                  {"GBD->GBD_FLGDEV == '2'", 'BR_VERMELHO'}}
 Private cCadastro := STR0001 //"Confirma็ใo de devolu็๕es"
 Private aRotina := MenuDef()
 
 Private cFilM09    := ""
 Private lFilGBD    := .T. //Utilizada para filtro e consistencia de SETOR/USUARIO
 Private cGcsTipLoc  := ""  
 Private cCodLocFar := ""
 Private cCodLocSet := ""
 Private dDataDe    := CToD("  /  /  ")
 Private dDataAte   := CToD("  /  /  ")
 Private cCodArmFar := ""
 Private __aRLote   := {{"__cNUMLOT", "SB8->B8_NUMLOTE"}, ;
                        {"__cLOTEFO", "SB8->B8_LOTEFOR"}, ;
                        {"__cLOTECT", "SB8->B8_LOTECTL"}, ;
                        {"__dDTVALI", "SB8->B8_DTVALID"}}
 Private __cLOTECT   := Space(Len(GBE->GBE_LOTECT))
 Private __cNUMLOT   := Space(Len(GBE->GBE_NUMLOT))
 // Verifica se tema atualiza็ใo para descarte
 Private lDescarte  := Hs_ExisDic({;
 																																			{"C","GCS_ARMDES"},;
 																																			{"C","GCS_DARMDE"},;
 																																			{"C","GBD_QTDESC"},;
 																																			{"C","GBD_MOTDES"},;
 																																			{"C","GBD_DSMDES"},;
 																																			{"C","GBD_ALMORI"},;
 																																			{"C","GBE_QTCFDE"},;
 																																			{"C","GBE_QTDESC"},;
 																																			{"C","GBE_MOTDES"},;
 																																			{"C","GBE_DSMDES"}},.F.)
 
 If FS_FilM09("HSPM09", .F.) 
  cCodArmFar := HS_IniPadr("GCS", 1, cCodLocFar, "GCS_ARMSET",, .F.)
  SetKey(VK_F12, {|| FS_FilM09("HSPM09", .T.) })            
  DbSelectArea("GBD")
  mBrowse(06, 01, 22, 75, "GBD",,,,,, aCores,,,,,,,,cFilM09)
 EndIf
Return(Nil)

Function HS_CfmM09(cAliasM09, nRegM09, nOpcM09)
 Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local oEnGbd, oDlgM09, nOpcDlg := 0, aHGbe := {}, aCGbe := {}
 Local nGDOpc := 0
 Local aMLocksSb2 := {}, aMLocksSb3 := {}, nItens := 0
	Local aJoin := {}            					
 Local nForDev:=0 
 Private cCusMed := GetMv("MV_CUSMED"), aRegSD3 := {}, nUGbe := 0
 
 Private oGDGbe, __fVMatMed := "HS_M09VGbe(M->GBE_PRODEV)"
 
 Private nGbeIteDev := 0, nGbeSolici := 0, nGbeIteSol := 0, nGbeQConfi := 0, nGbeQtdADv := 0, nGbeQtdDev := 0
 Private nGbeQtdDes := 0, nGbeDsMDes := 0, nGbeMotDes :=0, nGbeQtCfDe := 0
 Private nGbeProDev := 0, nGbeSeqDes := 0
 Private nGbeLoteFo := 0, nGbeLoteCt := 0, nGbeNumLot := 0, nGbeDtVali := 0
 
 If     nOpcM09 == 3 .And. GBD->GBD_FLGDEV == "2" // Confirma็ใo de devolu็ใo // Confirma็ใo total
  HS_MsgInf(STR0007, STR0006, STR0016) //###"A solicita็ใo selecionada foi totalmente atendida"###"Atencao" //"Confirmacao da Devolucao"
  Return(Nil)
 EndIf 
 
 If !HS_VldPar(StrTran(aRotina[nOpcM09, 1], "&", ""))
  Return()
 EndIf 
 
 RegToMemory("GBD", aRotina[nOpcM09, 4] == 3)
              
 DbSelectArea("GBD")
 If !Empty(M->GBD_REGATE)
  DbSelectArea("GCY")
  DbSetOrder(1)
  DbSeek(xFilial("GCY") + M->GBD_REGATE)
  DbSelectArea("GBD")
  
  M->GBD_INDCBL :=SuperGetMV("MV_TPINDIC",,"1")
  If GCY->GCY_TPALTA == "99"
   HS_MsgInf(STR0008, STR0006 , STR0016) //"Atendimento ja foi cancelado" //"Confirmacao da Devolucao"
   Return(.T.)
  EndIf 
 EndIf
  
 HS_BDados("GBE", @aHGbe, @aCGbe, @nUGbe, 1, M->GBD_NUMDEV, "GBE->GBE_NUMDEV == '" + M->GBD_NUMDEV + "'")
 
 nGbeIteDev := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_ITEDEV"})
 nGbeSolici := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_SOLICI"})
 nGbeIteSol := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_ITESOL"})
 nGbeQConfi := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_QCONFI"})
 nGbeQtdADv := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_QTDADV"})
 nGbeQtdDev := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_QTDDEV"})
 nGbeQtdDes := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_QTDESC"})
 nGbeMotDes := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_MOTDES"})
 nGbeQtCfDe := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_QTCFDE"})
 nGbeDsMDes := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_DSMDES"})
 nGbeProDev := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_PRODEV"})
 nGbeSeqDes := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_SEQDES"})
 
 nGbeLoteFo := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_LOTEFO"})
 nGbeLoteCt := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_LOTECT"})
 nGbeNumLot := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_NUMLOT"})
 nGbeDtVali := aScan(aHGbe, {|aVet| AllTrim(aVet[2]) == "GBE_DTVALI"})
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 040, .T., .T. } )	
 AAdd( aObjects, { 100, 060, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
  
 DEFINE MSDIALOG oDlgM09 TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel
  oEnGbd := MsMGet():New("GBD", nRegM09, nOpcM09,,,,/*{"GBD_ALMORI"}*/, aPObjs[1],, 2)
  oEnGbd:oBox:align := CONTROL_ALIGN_TOP
  
  oGDGbe := MsNewGetDados():New(aPObjs[2, 1]+05, aPObjs[2, 2], aPObjs[2, 3]+10, aPObjs[2, 4], nGDOpc,,,,,, Len(aCGbe),,,,, aHGbe, aCGbe)
  oGDGbe:oBrowse:align := CONTROL_ALIGN_ALLCLIENT           	                        
  If HS_ExisDic({{"C", "GBE_LOTEFO"}}, .F.)    	                        
  	For nForDev := 1 To Len(oGDGbe:aCols) 
  	
  	 If Empty(oGDGbe:aCols[nForDev, nGbeLoteFo]) .or. Empty(oGDGbe:aCols[nForDev, nGbeLoteCt]) .or. ;
     Empty(oGDGbe:aCols[nForDev, nGbeNumLot])    .or. Empty(oGDGbe:aCols[nForDev, nGbeDtVali])
                      
   		DbSelectArea("GD5")
   		DbSetOrder(1)
   		If DbSeek(xFilial("GD5") + oGDGbe:aCols[nForDev, nGbeSeqDes])
   			oGDGbe:aCols[nForDev, nGbeLoteFo]:=GD5->GD5_LOTEFO
   			oGDGbe:aCols[nForDev, nGbeLoteCt]:=GD5->GD5_LOTECT
   			oGDGbe:aCols[nForDev, nGbeNumLot]:=GD5->GD5_NUMLOT
   			oGDGbe:aCols[nForDev, nGbeDtVali]:=GD5->GD5_DTVALI
   		Endif 
   	Endif
    Next
  Endif    
 ACTIVATE MSDIALOG oDlgM09 ON INIT EnchoiceBar(oDlgM09, {|| nOpcDlg := 1, oDlgM09:End()}, ;
                                                        {|| nOpcDlg := 0, oDlgM09:End()})
 
 If nOpcDlg == 1
  aSort(oGDGbe:aCols,,, {| X, Y| X[nGbeProDev] < Y[nGbeProDev]})
                                                                            
  For nItens := 1 To Len(oGDGbe:aCols)  
   If aScan(aMLocksSb2, oGDGbe:aCols[nItens, nGbeProDev] + GAI->GAI_ALMORI) == 0
    aAdd(aMLocksSb2, oGDGbe:aCols[nItens, nGbeProDev] + GAI->GAI_ALMORI)
   EndIf
   
   If aScan(aMLocksSb3, oGDGbe:aCols[nItens, nGbeProDev]) == 0 
    aAdd(aMLocksSb3, oGDGbe:aCols[nItens, nGbeProDev])
   EndIf
  Next
   
  If MultLock("SB2", aMLocksSb2, 1) .And. MultLock("SB3", aMLocksSb3, 1)
 
   Begin Transaction
    If nOpcM09 <> 2 // Confirma Devolu็ใo
     FS_GrvM09()
    EndIf 
   End Transaction
   
   HSPAHR04(M->GBD_NUMDEV,M->GBD_CODLOC)
   
  EndIf 
 Endif
Return(Nil)    

Static Function FS_GrvM09()
 Local nForDev := 0, nTQtdDev := 0, nTQtdDes := 0, nTQtdADv := 0
 
 For nForDev := 1 To Len(oGDGbe:aCols)                  
  If (oGDGbe:aCols[nForDev, nGbeQConfi] > 0) .Or. (oGDGbe:aCols[nForDev, nGbeQtCfDe] > 0)
   DbSelectArea("GBE")
   DbSetOrder(1)
   If DbSeek(xFilial("GBE") + M->GBD_NUMDEV + oGDGbe:aCols[nForDev, nGbeIteDev])
    RecLock("GBE", .F.)
     GBE->GBE_QTDDEV := oGDGbe:aCols[nForDev, nGbeQtdDev]
     
     If (oGDGbe:aCols[nForDev, nGbeQConfi]+oGDGbe:aCols[nForDev, nGbeQtdDes]) == GBE->GBE_QTDADV
      GBE->GBE_QTDESC := oGDGbe:aCols[nForDev, nGbeQtdDes]
     Else 
       GBE->GBE_QTDADV := GBE->GBE_QTDADV - oGDGbe:aCols[nForDev, nGbeQtdDes]
       GBE->GBE_QTDESC := 0
     EndIf
     GBE->GBE_LOGDEV := HS_LogArq()
    MsUnLock()             
    
    If oGDGbe:aCols[nForDev, nGbeQtdDes] > 0 .And. (oGDGbe:aCols[nForDev, nGbeQConfi]+oGDGbe:aCols[nForDev, nGbeQtdDes]) # oGDGbe:aCols[nForDev, nGbeQtdADv]
     RegToMemory("GBE",.F.)
     RecLock("GBE", .T.)   
      HS_GRVCPO("GBE")                               
      GBE->GBE_FILIAL := xFilial("GBE")
      GBE->GBE_ITEDEV := StrZero(Len(oGDGbe:aCols)+1, Len(GBE->GBE_ITEDEV))
      GBE->GBE_QTDDEV := 0
      GBE->GBE_QTDESC := oGDGbe:aCols[nForDev, nGbeQtdDes]
      GBE->GBE_QTDADV := oGDGbe:aCols[nForDev, nGbeQtdDes]
      GBE->GBE_LOGDEV := HS_LogArq()
      GBE->GBE_LOGARQ := HS_LogArq()     
      GBE->GBE_MOTDES := oGDGbe:aCols[nForDev, nGbeMotDes]

     MsUnLock()           
    EndIf 
           
   EndIf 
   
   DbSelectArea("GAJ")
   DbSetOrder(1)
   If DbSeek(xFilial("GAJ") + oGDGbe:aCols[nForDev, nGbeSolici] + oGDGbe:aCols[nForDev, nGbeIteSol])
    RecLock("GAJ", .F.)
     GAJ->GAJ_QTDDEV += (oGDGbe:aCols[nForDev, nGbeQConfi]+Iif(lDescarte,oGDGbe:aCols[nForDev, nGbeQtdDes],0))
    MsUnLock()
   Endif
   
   DbSelectArea("GD5")
   DbSetOrder(1)
   If DbSeek(xFilial("GD5") + oGDGbe:aCols[nForDev, nGbeSeqDes])
 	  RecLock("GD5", .F., .F.)
     If (oGDGbe:aCols[nForDev, nGbeQConfi]+Iif(lDescarte,oGDGbe:aCols[nForDev, nGbeQtdDes],0)) == GD5->GD5_QTDDES
      DbDelete()
    	Else
      GD5->GD5_QTDDES -= (oGDGbe:aCols[nForDev, nGbeQConfi]+Iif(lDescarte,oGDGbe:aCols[nForDev, nGbeQtdDes],0))
     EndIf
 	  MsUnlock()
   EndIf                                                                                    
   
   DbSelectArea("GAI")
   DbSetOrder(1)
   DbSeek(xFilial("GAI") + oGDGbe:aCols[nForDev, nGbeSolici])
   
   DbSelectArea("GCS")
   DbSetOrder(1)
   DbSeek(xFilial("GCS") + GAI->GAI_CODLOC)
   
   If HS_CONEST(oGDGbe:aCols[nForDev, nGbeProDev], GAI->GAI_CODLOC)[1]
    If oGDGbe:aCols[nForDev, nGbeQConfi] > 0
     HS_MovEst("E", oGDGbe:aCols[nForDev, nGbeProDev], oGDGbe:aCols[nForDev, nGbeQConfi], GAI->GAI_ALMORI, cUserName, GCS->GCS_CODCCU, , GAJ->GAJ_NUMLOT, GAJ->GAJ_LOTECT, GAJ->GAJ_DTVALI,,,,M->GBD_REGATE)
    EndIf
   
    If lDescarte .And. oGDGbe:aCols[nForDev, nGbeQtCfDe] > 0
	    DbSeek(xFilial("GCS") + cCodLocFar)
	    HS_MovEst("E", oGDGbe:aCols[nForDev, nGbeProDev], oGDGbe:aCols[nForDev, nGbeQtCfDe], GCS->GCS_ARMDES, cUserName, GCS->GCS_CODCCU, , GAJ->GAJ_NUMLOT, GAJ->GAJ_LOTECT, GAJ->GAJ_DTVALI,,,,M->GBD_REGATE)
    EndIf
   Endif
  EndIf 
  nTQtdDev += oGDGbe:aCols[nForDev, nGbeQtdDev]
  nTQtdDeS += Iif(lDescarte,oGDGbe:aCols[nForDev, nGbeQtdDes],0)
  nTQtdADv += oGDGbe:aCols[nForDev, nGbeQtdADv]
 Next
 
 DbSelectArea("GBD") 
 DbSetOrder(1)
 If DbSeek(xFilial("GBD") + M->GBD_NUMDEV)  
  RecLock("GBD", .F.)
   If (nTQtdDev == 0).And.(nTQtdDeS == 0)
    GBD->GBD_FLGDEV := "0" // Nใo confirmada
   ElseIf (nTQtdDev + nTQtdDeS) < nTQtdADv
    GBD->GBD_FLGDEV := "1" // Confirmada parcial
   Else   
    GBD->GBD_FLGDEV := "2" // Confirmada total
   EndIf
  MsUnLock()
 Endif   
Return(Nil)

Function HS_VldM09()
 Local lRet     := .T.
 Local cVar     := ReadVar()
   
 If cVar == "M->GBD_QCONFI"
  If !(lRet := (M->GBD_QCONFI >= 0))
   HS_MsgInf(STR0009, STR0006, STR0016) //###"Quantidade invalida"###"Atencao" //"Confirmacao da Devolucao"
  Endif 
 ElseIf cVar == "M->GBD_QTDESC"
  If !(lRet := (M->GBD_QTDESC >= 0))
   HS_MsgInf(STR0009, STR0006, STR0026) //###"Quantidade invalida"###"Atencao" ###"Confirmacao do Descarte"
  EndIf
 ElseIf cVar == "M->GBD_MOTDES"
  If !(lRet := HS_SeekRet('GGS', cVar, 1, .F., "GBD_DSMDES", "GGS_DSMOTI"))
   HS_MsgInf(STR0027, STR0006, STR0026) //###"Motivo do Descarte invalido."###"Atencao" ###"Confirmacao do Descarte"
  EndIf
 EndIf
  
Return(lRet)                                              

Function HS_M09VGbe()
 Local nPosGD  := 0
 Local lLote   := .T.
 Local cProVer :=M->GBD_CBMATM
 Local cProVld :=SB8->B8_PRODUTO
 Local nIndSB8:=2
 lLote   := Rastro(SB1->B1_COD)
 
  	If Hs_ExisDic({{"C","GBD_INDCBL"}}) .And. Type("M->GBD_INDCBL") <> "U" 
   		nIndSB8 := VAL(M->GBD_INDCBL)
  	EndIf 
 If HS_ExisDic({{"C", "GBE_LOTEFO"}}, .F.) .and. Empty(cProVer) .and. lLote  
	If nIndSB8=6
		 __cLoteFo :=aVetDados[1][2]
		 __cLoteCt :=aVetDados[1][3]
		 __cNumLot :=aVetDados[1][1]
		 __dDtVali:= STOD(aVetDados[1][4])						
		 cProVld:= aVetDados[1][6]
	EndIf  
 	If (nPosGD := aScan(oGDGbe:aCols, {| aVet | aVet[nGbeProDev] + aVet[nGbeLoteCt]+ aVet[nGbeNumLot] == PADR(cProVld, Len(oGDGbe:aCols[oGDGbe:nAt, nGbeProDev])) + __cLoteCT + __cNumLot .And. !aVet[nUGbe + 1] })) == 0 
		If (nPosGD := aScan(oGDGbe:aCols, {| aVet | aVet[nGbeProDev] + aVet[nGbeLoteCt]+ aVet[nGbeNumLot] == PADR(cProVld, Len(oGDGbe:aCols[oGDGbe:nAt, nGbeProDev])) + __cLoteCT + __cNumLot .And. Empty(aVet[nGbeProDev]) .And. !aVet[nUGbe + 1] })) == 0 
			HS_MsgInf(STR0010, STR0006, STR0016) //"Produto nao encontrado na solicita็ao"###"Atencao" //"Confirmacao da Devolucao"
			Return()
 		Endif
 	Endif
 Else
 	If lLote
 		FS_SelLte(M->GBE_PRODEV, oGDGbe) 
 			If (nPosGD := aScan(oGDGbe:aCols, {| aVet | aVet[nGbeProDev] + aVet[nGbeLoteCt]+ aVet[nGbeNumLot] == PADR(M->GBE_PRODEV, Len(oGDGbe:aCols[oGDGbe:nAt, nGbeProDev])) + __cLOTECT + __cNumLot .And. !aVet[nUGbe + 1] })) == 0 
 	   			If (nPosGD := aScan(oGDGbe:aCols, {| aVet | aVet[nGbeProDev] + aVet[nGbeLoteCt]+ aVet[nGbeNumLot] == PADR(M->GBE_PRODEV, Len(oGDGbe:aCols[oGDGbe:nAt, nGbeProDev])) + __cLOTECT + __cNumLot .And. Empty(aVet[nGbeProDev]) .And. !aVet[nUGbe + 1] })) == 0 
 			   		HS_MsgInf(STR0010, STR0006, STR0016) //"Produto nao encontrado na solicita็ao"###"Atencao" //"Confirmacao da Devolucao"
 	   		   		Return()
	 			Endif
	   		Endif
		
	Else	 
		// Procura pelo produto a devolver com quantidade a devolver maior que (quantidade devolvida + quantidade descartada)
 		If ( nPosGD := aScan(oGDGbe:aCols, {| aVet | aVet[nGbeProDev] == M->GBE_PRODEV .And.  aVet[nGbeQtdAdv] > (aVet[nGbeQtdDev]+Iif(lDescarte,aVet[nGbeQtdDes],0))})) == 0
 		// Se nใo achou o produto pega a posi็ใo do produto a devolver
 			nPosGD := aScan(oGDGbe:aCols, {| aVet | aVet[nGbeProDev] == M->GBE_PRODEV })
 		Endif
 	Endif
 Endif
 
 If  nPosGD == 0
 	HS_MsgInf(STR0010, STR0006, STR0016) //"Produto nao encontrado na solicita็ao"###"Atencao" //"Confirmacao da Devolucao"
 ElseIf (M->GBD_QCONFI + IIf(lDescarte,M->GBD_QTDESC,0)) > (oGDGbe:aCols[nPosGD, nGbeQtdADv] - (oGDGbe:aCols[nPosGD, nGbeQtdDev]+IIf(lDescarte,oGDGbe:aCols[nPosGD, nGbeQtdDes],0)))
 	HS_MsgInf(STR0011, STR0006, STR0016)  //"Quantidade informada somada a quantidade devolvida e somada a quantidade descartada ้ maior que a quantidade a ser devolvida"###"Atencao" //"Confirmacao da Devolucao"
 ElseIf lDescarte .And. !Empty(M->GBD_QTDESC) .And. Empty(M->GBD_MOTDES)
 	HS_MsgInf(STR0033, STR0006, STR0016)  //"Para realizar um descarte o campo Motivo do Descarte tem que ser informado"###"Atencao" //"Confirmacao da Devolucao"
 ElseIf FS_VALDAT(nPosGD)
 	oGDGbe:aCols[nPosGD, nGbeQConfi] += M->GBD_QCONFI 
 	oGDGbe:aCols[nPosGD, nGbeQtdDev] += M->GBD_QCONFI
 	oGDGbe:aCols[nPosGD, nGbeQtCfDe] += M->GBD_QTDESC  
 	oGDGbe:aCols[nPosGD, nGbeQtdDes] += M->GBD_QTDESC
 	If lDescarte
		oGDGbe:aCols[nPosGD, nGbeMotDes] := M->GBD_MOTDES
	  	oGDGbe:aCols[nPosGD, nGbeDsMDes] := M->GBD_DSMDES
	EndIf
	    
  	If oGDGbe:aCols[nPosGD, nGbeQtdADv] == (oGDGbe:aCols[nPosGD, nGbeQtdDev]+IIf(lDescarte,oGDGbe:aCols[nPosGD, nGbeQtdDes],0))
    	oGDGbe:aCols[nPosGD, nUGbe + 1] := .T.
  	EndIf

  	If oGDGbe:aCols[nPosGD, nGbeQtdDev] != 0 .Or. IIf(lDescarte,oGDGbe:aCols[nPosGD, nGbeQtdDes] != 0,.F.) 
		M->GBD_CBMATM := Space(len(M->GBD_CBMATM))
		M->GBD_CBLOTE := Space(len(M->GBD_CBLOTE))
	EndIf
	                                             
 	oGDGbe:oBrowse:nAt := nPosGD
 	oGDGbe:oBrowse:Refresh()
 EndIf

Return(.F.)

Function HS_LegM09()
 BrwLegenda(STR0001, STR0005, {{"BR_VERDE"   , STR0012}, ; //"Confirma็ใo de devolu็๕es"###"Legenda"###"Nใo confirmada"
                               {"BR_AMARELO" , STR0013}, ; //"Confirma็ใo parcial"
                               {"BR_VERMELHO", STR0014}})  //"Confirma็ใo total"
Return(.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤHฟ
//ณFuncao que fara a chamada da Rotina de Impressao devolucao  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤHู
Function HS_RelM09() 

  HSPAHR04(GBD->GBD_NUMDEV,GBD->GBD_CODLOC)

Return()

Static Function FS_VALDAT(nPosGd) 
 
 Local lRet     := .T.
 Local aArea    := GetArea(), aRetCon := {}
 Local dDatDev := dDatabase
 Local cHorDev := Time()
 
  aRetCon := HS_ConMed(M->GBD_REGATE, "", oGDGbe:aCols[nPosGD, nGbeSeqDes])
   
  DbSelectArea("GCZ")
  DbSetOrder(2) //filial+regate
  If DbSeek(xFilial("GCZ")+ M->GBD_REGATE + "0"+ aRetCon[9])  //Nr. Seq Guia
   If !EMPTY(aRetCon[5])
    If  aRetCon[6] == "N"
     HS_MsgInf(STR0017, STR0006, STR0016) //"O atendimento jแ estแ em alta"##"Atencao"##"Confirma็ใo da Devolu็ใo"
     lRet:=.F.
    Else
     dDatDev := aRetCon[3] //data da alta
     cHorDev := aRetCon[4] //hora alta
    Endif  
   Endif
   If !(lRet := !(dDatDev <  aRetCon[1] .Or. (dDatDev == aRetCon[1] .And. cHorDev < aRetCon[2])))
    HS_MsgInf(STR0018,STR0006,STR0019) //"A data da devolu็ใo nใo pode ser anterior a data do atendimento"###"Atencao"##"Inconsist๊ncia de data/ hora"
   ElseIf !(lRet := !(dDatDev > dDataBase .Or. (dDatDev == dDataBase .And. cHorDev > Time())))
    HS_MsgInf(STR0020, STR0006, STR0019)  //"A data da devolu็ใo nใo pode ser posterior a data corrente"###"Atencao"##"Inconsist๊ncia de data/ hora"
   ElseIf !Empty(aRetCon[7]) .AND. !(lRet := !(!(dDatDev > aRetCon[7])))
    HS_MsgInf(STR0021,STR0006,STR0022) //"A Data da devolu็ใo ้ menor ou igual ao ๚ltimo fechamento de estoque, nใo serแ possํvel efetuar o lan็amento."###"Atencao"##"Data Fecham."
   EndIf 
  Else
   HS_MsgInf(STR0024,STR0006,STR0025) //"Nใo existe nenhuma guia em aberto para este atendimento"###"Atencao"##"Inconsist๊ncia do status da guia"
   lRet := .F.                                        
  Endif
 
 RestArea(aArea)         

Return(lRet)

Static Function FS_FilM09(cPerg, lSetFilter)
 Local lRet        := .F.
 Local oObjMBrw    := GetObjBrow()
 Private lFarmacia := .T. // Identifica a origem para consulta padrใo para ser tratado em HS_FilGcs()
   
 //Fun็ใo para limpar as perguntas
 HS_PosSX1({{cPerg, "01", Nil}, {cPerg, "02", Nil}})

 If (lRet := Pergunte(cPerg))
 
  cCodLocFar := mv_par01
  cCodLocSet := mv_par02  
  dDtaDevDe  := mv_par03
  dDtaDevAte := mv_par04

  cFilM09 := "GBD_FILIAL = '" + xFilial("GBD") + "'"

  DbSelectArea("GCS")
  DbSetOrder(1) // GCS_FILIAL + GCS_CODLOC 
  DbSeek(xFilial("GCS") + cCodLocFar)
  
  If !Empty(GCS->GCS_ARMSET)
   cFilM09 += " AND GBD_ALMORI = '" + GCS->GCS_ARMSET + "'"
  Endif 

  If !Empty(cCodLocSet)
   cFilM09 += " AND GBD_CODLOC = '" + cCodLocSet + "'"
  Endif
  cFilM09 += " AND GBD_DATDEV BETWEEN '" + DTOS(dDtaDevDe) + "' AND '" + DTOS(dDtaDevAte) + "'"
  
  If lSetFilter
   SetMBTopFilter("GBD", cFilM09)
   oObjMBrw:GoTop()
   oObjMBrw:Refresh()
  EndIf
 EndIf
 DbSelectArea("GBD")
    
Return(lRet)

Function HS_VHSPM09(nPar, cCodLoc)
 Local lRet    := .T.
 
 If nPar == 1 .and. Empty(cCodLoc)
  HS_MsgInf(STR0029,STR0006,STR0028) //"Por favor, informe o codigo do setor."###"Atencao" //"Valida็ใo de perguntas"
  lRet := .F.
 ElseIf !Empty(cCodLoc)
  DbSelectArea("GCS")
  DbSetORder(1) // GCS_FILIAL + GCS_CODLOC
  If !DbSeek(xFilial("GCS") + cCodLoc)
   HS_MsgInf(STR0030,STR0006,STR0028) //"Setor nao cadastrado"###"Atencao"###"Valida็ใo de perguntas"
   lRet := .F.
  ElseIf nPar == 1 .and. GCS->GCS_TIPLOC <> "A" //Diferente de setor do tipo FARMACIA
   HS_MsgInf(STR0031,STR0006,STR0028) //"Setor invalido. Informe um setor do tipo 'Farmacia'."###"Atencao"###"Valida็ใo de perguntas"
   mv_par01 = "  " // limpa o campo
   lRet := .F.
  ElseIf nPar == 2 .and. GCS->GCS_TIPLOC == "A"
   HS_MsgInf(STR0032,STR0006,STR0028) //"Tipo do setor invalido (Farmacia)."###"Atencao"###"Valida็ใo de perguntas"
   mv_par02 = "  " // limpa o campo
   lRet := .F.
  Endif
 Endif
  
Return(lRet)                                                                  

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SElLte บ Autor ณ SAUDE              บ Data ณ 10/09/09    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que Busca lotes para a Devolucao                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/   

 Static Function FS_SelLte(cCodPMov, oLote)
 Local aArea := GetArea()
 Local cLstCpo := "", cFiltro := ""
 Local aHeader := {}, aCols := {}
 Local nPos    := 0
 Local oDlg, oDev
 Local nNUMLOTE := 0
 Local nLOTECTL := 0

  
 For nPos := 1 to len(oLote:aCols)
 	If  oLote:aCols[nPos, nGbeProDev] == cCodPMov .and.; 
 		!Empty(oLote:aCols[nPos, nGbeLoteCt]) .And. !(oLote:aCols[nPos, len(oLote:aCols[nPos])])
 		aAdd(aCols, {oLote:aCols[nPos, nGbeProDev], oLote:aCols[nPos, nGbeLoteCt], oLote:aCols[nPos, nGbeNumLot],.F.})
 	Endif 
 Next nPos
 
 If Len(aCols) > 0 
 	aHeader := FS_GerHead({"GBE_PRODEV", "GBE_LOTECT", "GBE_NUMLOT"})  
 	nLOTECTL := aScan(aHeader, {| aVet | aVet[2] == "GBE_LOTECT"})
 	nNUMLOTE := aScan(aHeader, {| aVet | aVet[2] == "GBE_NUMLOT"})
 
	aSize := MsAdvSize(.T.)
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T.,.T. } )
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
	aPObj := MsObjSize( aInfo, aObjects, .T. )
	nPosSB8 := 0
	DEFINE MSDIALOG oDlg TITLE OemToAnsi ("Consulta Lotes") From 000, 000 To 500, 700 Of oMainWnd PIXEL //"Consulta Lotes"
	oDev := MsNewGetDados():New(aPObj[1, 1], aPObj[1, 2], aPObj[1, 3], aPObj[1, 4], 0,,,,,,,,,, oDlg, aHeader, aCols)
	oDev:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oDev:oBrowse:BlDblClick := {|| __cLOTECT := oDev:aCols[oDev:oBrowse:nAt, nLoteCtl] , __cNUMLOT := oDev:aCols[oDev:oBrowse:nAt, nNumLote], oDlg:End()}
	ACTIVATE MSDIALOG oDlg CENTERED

 EndIf

 RestArea(aArea)

Return()     



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GerHeadบ Autor ณ SAUDE              บ Data ณ 10/09/09    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que monta aHeader                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/   
Static Function FS_GerHead(aCampos)
Local aArea      := GetArea()
Local nForCampos := 0
Local aHeader    := {}      
                       
 DbSelectArea("SX3")
 DbSetOrder(2)

 For nForCampos := 1 to len(aCampos)
 	If (ValType(aCampos[nForCampos]) == "C")
    	DbSeek(aCampos[nForCampos])
   		aAdd(aHeader, { TRIM(X3Titulo())	, ;
                   SX3->X3_CAMPO   	, ;
                   SX3->X3_PICTURE 	, ;
                   SX3->X3_TAMANHO 	, ;
                   SX3->X3_DECIMAL 	, ;
                   SX3->X3_VALID   	, ;
                   SX3->X3_USADO   	, ;
        	       SX3->X3_TIPO    	, ;
                   SX3->X3_F3      	, ;
        	       SX3->X3_CONTEXT 	, ;
                   SX3->X3_CBOX    	, ;
   		           SX3->X3_RELACAO 	, ;
                   SX3->X3_WHEN    	, ;
                   SX3->X3_VISUAL  	, ;
                   SX3->X3_VLDUSER 	, ;
                   SX3->X3_PICTVAR 	, ;
                   X3Obrigat(SX3->X3_CAMPO) })
 	ElseIf (ValType(aCampos[nForCampos]) == "A")
  		aAdd(aHeader, {TRIM(aCampos[nForCampos][1]),;
                  aCampos[nForCampos][2]	,;    
                  aCampos[nForCampos][3]	,;    
                  aCampos[nForCampos][4]	,;    
                  aCampos[nForCampos][5]	,;    
                  aCampos[nForCampos][6]	,; 
                  aCampos[nForCampos][7]	,; 
       		      aCampos[nForCampos][8]	,; 
                  aCampos[nForCampos][9]	,;
       		      aCampos[nForCampos][10],;    
                  aCampos[nForCampos][11],; 
    		      aCampos[nForCampos][12]})     
  EndIf
                
 Next nForCampos
 RestArea(aArea)
Return(aHeader)    
  



                                                               

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
Local aRotina :=	{{OemtoAnsi(STR0002), "axPesqui" , 0, 1, 0, nil},; //"Pesquisar"
                     {OemToAnsi(STR0003), "HS_CfmM09", 0, 2, 0, nil},; //"Visualizar"
                   	 {OemToAnsi(STR0004), "HS_CfmM09", 0, 4, 0, nil},; //"Confirmar" 
                   	 {OemtoAnsi(STR0015), "HS_RelM09", 0, 3, 0, nil},; //"Reimpressao"
             	     {OemtoAnsi(STR0005), "HS_LegM09", 0, 1, 0, nil}}  //"Legenda" 
Return(aRotina)
