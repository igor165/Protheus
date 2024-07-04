#INCLUDE "HSPAHAA7.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*.
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHAA7  º Autor ³ MARCELO JOSE       º Data ³  07/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CADASTRO DE TABELA DE PRECOS TAXAS E DIARIAS               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Function HSPAHAA7()
Private cPerg := "HSPAA7"
Private lCopiou := .F.

aRotina :=	MenuDef()

cCadastro := STR0008 //"Tabela de Preços TAXAS/DIÁRIAS"


DbSelectArea("GD2")
DbSetOrder(1) //GD2_FILIAL + GD2_CODTAB

mBrowse(06, 01, 22, 75, "GD2")
Return(Nil)

/************************************************************************************************/
Function HSPAA71(cAlias, nReg, nOpc)

 Local bCampo     := {|nCPO| Field(nCPO)}, nCntFor := 1, lBTaxDia := .F.
 Local cAntCODTAB	:= GD2->GD2_CODTAB
	Local cAtuCODTAB	:= ""         
	Local nOpcE := aRotina[nOpc,4]
	Local nOpcA := 0, nOpcG := IIF(nOpcE == 2 .Or. nOpcE == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
	                            
	Private oGetDados
 Private aTELA[0][0], aGETS[0]
 Private AHEADER := {}, ACOLS := {}
 Private wVar
 Private nGD3_CODTAB := 0, nGD3_CODTXD := 0, nGD3_DESC := 0, nUsado := 0
	Private nGD3_DATVIG	:= 0
	Private aCGD3       := {}	
	Private nLGD3       := 0
 Private CTITULO, CALIASENCHOICE, CLINOK, CTUDOK, CFIELDOK
 
 if nOpc == 7 
	 If !(lCopiou  := !lCopiou)
   Return(nil)
  EndIf 
 ElseIf nOpc == 6 
  cPerg := "HSPAA7"      
  GeraX1()
  If !Pergunte(cPerg, .T.)
   Return(nil)
  EndIf
 EndIf 
 
 aGets := {}  /* matriz que contem os campos que vao receber digitacao na enchoice */
 aTela := {}  /* matriz que contem os campos que vao aparecer na enchoice          */

 DbSelectArea("GD2")
 RegToMemory("GD2",(nOpcE == 3))

 If nOpcE # 3// .And. nOpc # 6 .And. nOpc # 7 /* se nao for inclusao ou Gerar ou Copiar 
  DbSelectArea("GD2")
  For nCntFor := 1 To FCount()
   M->&(EVAL(bCampo, nCntFor)) := FieldGet(nCntFor)
  Next
 EndIf
	If nOpc == 7  // Salva codigo para retornar apos a criacao do acols
		cAtuCODTAB				:= M->GD2_CODTAB
		M->GD2_CODTAB	:= cAntCODTAB
	EndIf

 nLGD3 := HS_BDados("GD3", @aHeader, @aCols, @nUsado, 1, M->GD2_CODTAB, ;
                     Iif(!Empty(M->GD2_CODTAB),"'" + M->GD2_CODTAB + "' == GD3->GD3_CODTAB",;
                        Nil))
                        
 nGD3_CODTAB := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GD3_CODTAB"})
 nGD3_CODTXD := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GD3_CODTXD"})
 nGD3CODTXC  := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GD3_CODTXC"})
 nGD3_DESC   := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GD3_DESC"})
 nGD3_VALVTX := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GD3_VALVTX"})
 nGD3_DATVIG := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GD3_DATVIG"})
 nGD3_VALCTX := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GD3_VALCTX"})
 nGD3_TIPDES := aScan(aHeader, {|aVet| AllTrim(aVet[2]) == "GD3_TIPDES"})
 aCGD3       := aClone(aCols)
 
	If nOpc == 7  // Retorna codigo apos a criacao do acols
		M->GD2_CODTAB	:= cAtuCODTAB
 ElseIf nOpc == 6
  Processa({|| lBTaxDia := FS_BTaxDia()})
  If !lBTaxDia 
   HS_MsgInf(STR0009, STR0010, STR0008)  //"Nenhuma Taxa/Diária encontrada no período"###"Atenção"###"Tabela de Precos TAXAS/DIARIAS"
   Return(.F.)
  EndIf 
 EndIf

 DbSelectArea("GD2") 

 If Len(aHeader) > 0 
  cTitulo        := OemToAnsi(STR0008) //"Tabela de Preços TAXAS/DIÁRIAS"
  cAliasEnchoice := "GD2"
  cAliasGetd     := "GD3"
  cAlias         := "GD3"
  cLinOk         := "HS_LOKAA7()"
  cTudOk         := "AllwaysTrue()"
  cFieldOk       := "AllwaysTrue()"
  
  aSize := MsAdvSize(.T.)
  aObjects := {}	
  aAdd( aObjects, { 100, 040, .T., .T. } )	
  aAdd( aObjects, { 100, 050, .T., .T. } )	
  aAdd( aObjects, { 100, 010, .T., .T., .T. } )	 
  
  aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
  aPObjs := MsObjSize( aInfo, aObjects, .T. )
  
  nOpcA := 0  
 
  DEFINE MSDIALOG oDlg TITLE cTitulo From asize[7], 000 To asize[6], asize[5] Of oMainWnd Pixel  
  
  EnChoice(cAliasEnchoice, nReg, nOpcE,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},, 3,,,,,, .F.)
   
  oGetDados := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nOpcG, cLinOk, /*cTudOk*/,,,,99999, /*cFieldOk*/,,, oDlg, aHeader, aCols)
   
  oPPesq	:=	tPanel():New(aPObjs[3, 1], aPObjs[3, 2],, oDlg,,,,,, aPObjs[3, 3], aPObjs[3, 4]+4)
  oPPesq:Align := CONTROL_ALIGN_BOTTOM
  
  HS_GDPesqu( , , oGetDados, oPPesq, 002)
 
  ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpca := 1, IIf(oGetDados:TudoOk() .And. Obrigatorio(aGets, aTela) ;
                                                       .And. IIf(nOpcE == 5, FS_ExclGD2(), .T.), oDlg:End(), .F.)}, ;
                                                   {|| nOpcA := 0, lCopiou := .F., oDlg:End()})
 EndIf

 If nOpcA == 0
  While __lSX8 
   RollBackSXE()
  End
 ElseIf (nOpcA == 1 .And. nOpcE # 2)
  Begin Transaction
   GrvHSAA7(nOpcE)
  End Transaction  
  While __lSX8
   ConfirmSX8()
  End
 EndIf
Return(nil)


/************************************************************************************/
Function HS_LOKAA7()

 Local lRet := .T.
 
 If !(Len(aCols) == Len(aCGD3) ;
  .And. aCols[oGetDados:oBrowse:nAt, nGD3_CODTXD] == aCGD3[oGetDados:oBrowse:nAt, nGD3_CODTXD] ;
  .And. aCols[oGetDados:oBrowse:nAt, nGD3_DATVIG] == aCGD3[oGetDados:oBrowse:nAt, nGD3_DATVIG])
   lRet := HS_DuplAC(oGetDados:oBrowse:nAt, aCols, {nGD3_CODTXD, nGD3_DATVIG})
  If lRet
   aCGD3 := aClone(aCols)
  EndIf
 EndIf 
                         
Return(lRet)


/************************************************************************************/
Static Function GrvHSAA7(nOpcE)

 Local lAchou := .F., nCntFor := 1
  If Inclui
   M->GD2_CODTAB := HS_VSXENUM("GD2", "M->GD2_CODTAB",1)
  Else
   M->GD2_CODTAB := GD2->GD2_CODTAB
  Endif  
  
  
  If nOpcE == 5 
   RecLock("GD2", .F., .T.)
   Dbdelete()
   MsUnlock()
   WriteSx2("GD2")       
  Else                  
   RecLock("GD2", Inclui)
   HS_GrvCpo("GD2")          
   GD2->GD2_CODTAB := M->GD2_CODTAB
   GD2->GD2_DATATU := dDataBase
   GD2->GD2_LOGARQ := HS_LogArq()
   MsUnLock()
  EndIf
                   
  For nCntFor := 1 To Len(oGetDados:aCols)
   DbSelectArea("GD3")
   DbSetOrder(1)
   lAchou := DbSeek(xFilial("GD3") + M->GD2_CODTAB + oGetDados:aCols[nCntFor, nGD3_CODTXD] + DtoS(oGetDados:aCols[nCntFor, nGD3_DATVIG]))
   If Inclui .Or. Altera
    If oGetDados:aCols[nCntFor, Len(oGetDados:aCols[nCntFor])] .And. lAchou /* exclusao */
     RecLock("GD3", .F., .T.)
     DbDelete()
     MsUnlock()
     WriteSx2("GD3")
    Else
     If !oGetDados:aCols[nCntFor, Len(oGetDados:aCols[nCntFor])]
 	   RecLock("GD3", !lAchou)
 	   HS_GrvCpo("GD3", oGetDados:aCols, oGetDados:aHeader, nCntFor)
 	   GD3->GD3_FILIAL := xFilial("GD3")                                              	   
 	   GD3->GD3_CODTAB := M->GD2_CODTAB
 	   GD3->GD3_LOGARQ := HS_LOGARQ()
 	   MsUnlock()
 	  EndIf 
 	 EndIf
   Else  	
    If lAchou  /* opcao exclusao do menu */
     RecLock("GD3", .F., .T.)
     Dbdelete()
     MsUnlock()
     WriteSx2("GD3")
    EndIf   
   EndIf
  Next
  
Return(.T.)


/********************************************************************************************/
Static Function FS_BTaxDia()

 Local nOrdSb1 := GAA->(IndexOrd())
 
 aCols := {}
 
 ProcRegua(GAA->(RecCount()))
 
 DbSelectArea("GAA")
 DbSetOrder(1) //GAA_FILIAL + GAA_CODTXD
 DbSeek(xFilial("GAA") + MV_PAR03, .T.)
 While GAA->GAA_FILIAL == xFilial("GAA") .And. GAA->GAA_CODTXD <= MV_PAR04 .And. !Eof()
 
  If GAA->GAA_CODCTD < MV_PAR01 .Or. GAA->GAA_CODCTD > MV_PAR02
   DbSkip()
   Loop
  EndIF 
    
  aAdd(aCols, Array(nUsado + 1))
    
  If nGD3_CODTAB > 0
   aCols[Len(aCols)][nGD3_CODTAB] := M->GD2_CODTAB
  EndIf             
    
  If nGD3_CODTXD > 0 
   aCols[Len(aCols)][nGD3_CODTXD] := GAA->GAA_CODTXD
  EndIf
  
  If nGD3CODTXC > 0 
   aCols[Len(aCols)][nGD3CODTXC] := GAA->GAA_CODTXD
  EndIf
  
  If nGD3_DESC > 0
   aCols[Len(aCols)][nGD3_DESC] := GAA->GAA_DESC
  EndIf

  If nGD3_VALVTX > 0
   If MV_PAR05 > 0.00
    aCols[Len(aCols)][nGD3_VALVTX] := GAA->GAA_CUSCTD + ( ( GAA->GAA_CUSCTD * MV_PAR05 ) / 100 )
   Else
    aCols[Len(aCols)][nGD3_VALVTX] := GAA->GAA_CUSCTD
   EndIf 
  EndIf

  If nGD3_VALCTX > 0
   aCols[Len(aCols)][nGD3_VALCTX] := GAA->GAA_CUSCTD
  EndIf
  
  If nGD3_DATVIG > 0
   aCols[Len(aCols)][nGD3_DATVIG] := MV_PAR06
  EndIf
  
  If nGD3_TIPDES > 0
   aCols[Len(aCols)][nGD3_TIPDES] := "3"
  EndIf
  
  aCols[Len(aCols), nUsado + 1 ] := .F.
  IncProc(STR0011 + GAA->GAA_CODTXD) //" Taxa/Diária - "
  DbSkip()
 EndDo

 DbSelectArea("GAA")
 DbSetOrder(nOrdSb1)
 
 DbSelectArea("GD2")
Return(Len(aCols) > 0)


/******************************************************************************************/
Static Function GeraX1()

 Local _sAlias := Alias()
 Local j := 0, i := 0
 
 DbSelectArea("SX1")
 DbSetOrder(1) // X1_GRUPO + X1_ORDEM
 cPerg := PADR(cPerg, Len(SX1->X1_GRUPO))
 aRegs :={}

 aAdd(aRegs,{cPerg, "01", STR0012, "", "", "mv_ch1", "C", 02, 0, 0, "G", "", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "CT" , "S"}) //"Da Categoria  "
 aAdd(aRegs,{cPerg, "02", STR0013, "", "", "mv_ch2", "C", 02, 0, 0, "G", "", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "CT" , "S"}) //"Até Categoria "
 aAdd(aRegs,{cPerg, "03", STR0014, "", "", "mv_ch3", "C", 10, 0, 0, "G", "", "mv_par03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "GAA", "S"}) //"Da Taxa       "
 aAdd(aRegs,{cPerg, "04", STR0015, "", "", "mv_ch4", "C", 10, 0, 0, "G", "", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "GAA", "S"}) //"Até a Taxa    "
 aAdd(aRegs,{cPerg, "05", STR0016, "", "", "mv_ch5", "N", 06, 2, 0, "G", "", "mv_par05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "S"})  //"% Aplicado    "
 aAdd(aRegs,{cPerg, "06", STR0017, "", "", "mv_ch6", "D", 08, 2, 0, "G", "", "mv_par06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""   , "S"})  //"Vigência      "
 
 For I := 1 To Len(aRegs)
  If !DbSeek(cPerg + aRegs[I, 2])
   RecLock("SX1", .T.)
   For j:=1 To FCount()
    If j <= Len(aRegs[i])
     FieldPut(j, aRegs[i, j])
    EndIf
   Next
   MsUnlock()
  EndIf
 Next
 DbSelectArea(_sAlias)
Return(Nil)


/************************************************************************************/
Function HS_VldAA7()

 Local lRet   := .T.
 Local cCampo := ReadVar()
 
 If cCampo == "M->GD3_CODTXD"
 lRet:= HS_SeekRet("GAA", "M->GD3_CODTXD", 1, .F., "GD3_DESC", "GAA_DESC")
 
 ElseIf cCampo == "M->GD2_TBTISS" 
  If !EMPTY(M->GD2_TBTISS) .And. !(lRet := HS_SeekRet("G24", "M->GD2_TBTISS", 1, .F., "GD2_DTBTIS", "G24_DESCRI",,, .T.))
   HS_MsgInf(STR0025, STR0010, STR0026) //"Tabela do TISS não encontrada"###"Atenção"###"Validação dos campos"
  EndIf
 ElseIf cCampo == "M->GD3_CODTXC"
  If HS_ExisDic({{"C", "GD2_FVCDPR"}}, .F.)
   lRet:= IIf(!Empty(M->GD2_FVCDPR), &(M->GD2_FVCDPR), .T.)
  EndIf
 EndIf
 
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_AA7REA ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 06.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rejuste da tabela de taxas diarias                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_AA7REA                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

Function HS_AA7REA

Local aArea := GetArea()

If !Pergunte("HSAA7R", .T.)
 Return .F.
EndIf     

If MsgYesNo(OemToAnsi(STR0020) + GD2->GD2_CODTAB) //"Confirma reajuste Tabela de Taxas Diárias "
 Processa({|| FS_GerRea()}, OemToAnsi(STR0021) + GD2->GD2_CODTAB) //"Processando tabela "
EndIf

RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GerRea ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 06.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a reajuste da tabela de taxas diarias              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS_GerRea                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/    

Static Function FS_GerRea
 Local nValNovo := 0
 Local cQuery			:= ""
 Local nPorRea  := MV_PAR01
 Local dDatVig  := MV_PAR02
 Local lAtuVig  := MV_PAR03 == 1
 Local lCriaNovo:= .T.

 cQuery := "SELECT GD3.GD3_CODTXD, MAX(GD3.GD3_DATVIG) GD3_DATVIG "
 cQuery += "FROM " + RetSQLName("GD3") + " GD3 "
 cQuery += "WHERE GD3.GD3_FILIAL = '" + xFilial("GD3") + "' "	
 cQuery += "AND GD3.GD3_CODTAB = '" + GD2->GD2_CODTAB + "' "	
 cQuery += "AND GD3.D_E_L_E_T_ <> '*' "
 cQuery += "GROUP BY GD3.GD3_CODTXD"

 cQuery := ChangeQuery(cQuery)

 DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TRB", .F., .F.)

 DbSelectArea("TRB")
 ProcRegua(100)

 While !Eof()
 	IncProc(OemToAnsi(STR0022) + TRB->GD3_CODTXD) //"Atualizando "

 	DbSelectArea("GD3")
 	DbSetOrder(1) //FILIAL + CODTAB + CODTXD + DATVIG
  DbSeek(xFilial("GD3") + GD2->GD2_CODTAB + TRB->GD3_CODTXD + TRB->GD3_DATVIG)
  RegToMemory("GD3")

 	nValNovo := GD3->GD3_VALVTX * (1 + nPorRea/100)

  If nValNovo <> GD3->GD3_VALVTX .And. dDatVig >= STOD(TRB->GD3_DATVIG)

   lCriaNovo := .T.
   If dDatVig == STOD(TRB->GD3_DATVIG) 
    If lAtuVig
     lCriaNovo := .F.
		  Else
     DbSelectArea("TRB")
     DbSkip()
     Loop
		  EndIf
   EndIf

   Begin Transaction 
 
    DbSelectArea("GD2")
    RecLock("GD2", .F.)
     GD2->GD2_LOGARQ := HS_LOGARQ()
    MsUnLock()
   
    RecLock("GD3", lCriaNovo)
     HS_GrvCpo("GD3")
     GD3->GD3_FILIAL := xFilial("GD3")
    	GD3->GD3_VALVTX := nValNovo
    	GD3->GD3_DATVIG := dDatVig
	    GD3->GD3_LOGARQ := HS_LOGARQ()
    MsUnLock()

   End Transaction
  EndIf 

	 DbSelectArea("TRB")
  DbSkip()

 EndDo
 
 DbSelectArea("TRB")
 DbCloseArea()

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_AA7ATU ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 06.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualizacao da tabela de procedimentos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_AA7ATU                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

Function HS_AA7ATU

Local aArea := GetArea()

If !Pergunte("HSAA7A", .T.)
 Return(.F.)
EndIf     

If MsgYesNo(OemToAnsi(STR0023) + GD2->GD2_CODTAB) //"Confirma atualização da Tabela de Taxas Diárias "
 Processa({|| FS_GerAtu()}, OemToAnsi(STR0021) + GD2->GD2_CODTAB) //"Processando tabela "
EndIf

RestArea(aArea)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GerAtu ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 07.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a atualizacao da tabela de procedimentos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FS_GerAtu                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

Static Function FS_GerAtu

Local nTamLin := GD2->(GD2_TAMCOD + GD2_TAMVLR)
Local cArq    := Trim(GD2->GD2_NOMARQ)
Local nHdl    := Nil
Local cBuffer := Space(nTamLin + 2)
Local nBytes  := 0
Local cCOD				:= ""
Local nVLR				:= 0
Local nCont				:= 0
Local bCampo			:=	{|nCpo| Field(nCpo)}

nHdl := fOpen(cArq, 2) // Abre o arquivo

If nHdl == -1
	HS_MsgInf(OemToAnsi(STR0024), STR0010, STR0008) //"Arquivo não pode ser aberto!"###"Atenção"###"Tabela de Preços TAXAS/DIÁRIAS"
	Return
EndIf

Begin Transaction 

DbSelectArea("GD2")
RecLock("GD2", .F.)
GD2->GD2_LOGARQ := HS_LOGARQ()
MsUnLock()

nBytes := fRead(nHdl, @cBuffer, nTamLin+2)

ProcRegua(nBytes)

Do While nBytes == nTamLin+2

	cCOD	:= Substr(cBuffer, GD2->GD2_COLINI, GD2->GD2_TAMCOD)
	nVLR := SuperVal(Substr(cBuffer, GD2->GD2_COLINV, GD2->GD2_TAMVLR))  // Funcao que pega os valores com decimais

	DbSelectArea("GD3")
	DbSetOrder(2) // GD3_FILIAL + GD3_CODTAB + GD3_CODTXC + DTOS(GD3_DATVIG)
	If DbSeek(xFilial("GD3") + GD2->GD2_CODTAB + cCOD) .And. !Empty(cCOD)
		
		IncProc(OemToAnsi(STR0022) + GD3->GD3_CODTXC) //"Atualizando "

 	DbSelectArea("GD3")
 	RegToMemory("GD3", .F.)
 	
 	RecLock("GD3", .T.)
 	
		For nCont := 1 To FCount()  // Copia dados do registro original
			If "FILIAL" $ Field(nCont)
				FieldPut(nCont, xFilial("GD3"))
			Else
				FieldPut(nCont, M->&(Eval(bCampo, nCont)))
			EndIf
		Next nCont

		GD3->GD3_VALVTX := nVLR  // Atribui novos valores
		GD3->GD3_DATVIG := MV_PAR01
		GD3->GD3_LOGARQ := HS_LOGARQ()
 	MsUnLock()

	EndIf

 nBytes := fRead(nHdl, @cBuffer, nTamLin+2)

EndDo

End Transaction

fClose(nHdl)
          
Return(.T.)


/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_DescAA7º Autor ³ Daniel Peixoto     º Data ³  23/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de validacao dos campos de descricao.               º±±
±±º          ³ Chamada do X3_RELACAO do campo de Acordo com o Parametro   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_DescAA7(cAlias, nCpo)

 Local cCodChave := ""
 Local cDescri   := ""  
 
 If cAlias == "GD3"
 
  cCodChave := IIf(Alias() == "TMPGD3", (Alias())->GD3_CODTXD, "")
    
  If !Empty(cCodChave)
   cDescri := HS_IniPadr("GAA", 1, cCodChave, "GAA_DESC",,.F.)
  EndIf 
 
 EndIf
 
Return(cDescri) 

Static Function FS_ExclGD2()
 Local aArea := GetArea()
 Local lRet	 := .T.

 If (HS_CountTB("GD8", "GD8_CODTXD = '" + M->GD2_CODTAB + "'")  > 0) 
  HS_MsgInf(STR0027, STR0010, STR0028) //"Tabela de preços Tax/Dia possui relacionamento com Planos X Tabela Preço Tax/Dia."###"Atenção"###"Validação da Exclusão"
 	lRet := .F.
 Endif                                                                   
                                                                                                                      
 RestArea(aArea)
Return(lRet)   

Function HS_AA7SUS()
 Local aArea := GetArea()

 If !Pergunte("HSAA7S", .T.)
  Return(.F.)
 EndIf     

 If MsgYesNo(STR0030 + GD2->GD2_CODTAB) //"Confirma atualização de tabelas de Tax/Dia - SUS "
  Processa({|| FS_AtuSUS()}, STR0021 + GD2->GD2_CODTAB) //"Processando tabela "
 EndIf

 RestArea(aArea)
Return()

Static Function FS_AtuSUS()
 Local aArea := GetArea()
 Local cSql  := ""
 Local dVigencia := MV_PAR01
 
 ProcRegua(0)
 
 //Seleciona todos os procedimentos cujo próprio estaja na tabela (GMV) do SUS
 
 cSql := "SELECT DISTINCT GD3.GD3_CODTXD,GD3.GD3_CODTXC,GD3.GD3_TIPDES,GMV.GMV_DESCRI,GMV.GMV_VLRAS,GMV.GMV_VLSRVH,GMV.GMV_VLSRVP,GMV.GMV_VLSADT "
 cSql += "FROM " + RetSqlName("GD3") + " GD3 "
 cSql +=   "JOIN " + RetSqlName("GMV") + " GMV ON GMV.GMV_FILIAL = '" + xFilial("GMV") + "' AND GMV.D_E_L_E_T_ <> '*' AND "
 cSql +=                                        "GMV.GMV_CODSUS = GD3.GD3_CODTXC "
 cSql += "WHERE GD3.GD3_FILIAL = '" + xFilial("GD3") + "' AND GD3.D_E_L_E_T_ <> '*' AND GD3.GD3_CODTAB = '" + GD2->GD2_CODTAB + "' "

 cSql := ChangeQuery(cSql)
 TcQuery cSql NEW ALIAS "TMPPRO"
 
 DbSelectArea("TMPPRO")
 DbGotop()
 
 While !TMPPRO->(Eof())
  IncProc(STR0031 + TMPPRO->GD3_CODTXD) //"Atualizando "
  DbSelectArea("GD3")
  DbSetOrder(3) //GD3_FILIAL+GD3_CODTAB+GD3_CODTXD+GD3_CODTXC+DTOS(GD3_DATVIG)
  lAchou :=  DbSeek(xFilial("GD3") + GD2->GD2_CODTAB + TMPPRO->GD3_CODTXD + TMPPRO->GD3_CODTXC + DTOS(dVigencia))
  RecLock("GD3", !lAchou)
  	GD3->GD3_FILIAL := xFilial("GD3")
   GD3->GD3_CODTXD := TMPPRO->GD3_CODTXD
   GD3->GD3_CODTAB := GD2->GD2_CODTAB
   GD3->GD3_CODTXC := Iif(lAchou, GD3->GD3_CODTXC, TMPPRO->GD3_CODTXC)
   GD3->GD3_DESTXC := Iif(lAchou, GD3->GD3_DESTXC, TMPPRO->GMV_DESCRI)
   GD3->GD3_DATVIG := dVigencia
   GD3->GD3_VALVTX := IIf(!Empty(TMPPRO->GMV_VLRAS), TMPPRO->GMV_VLRAS, TMPPRO->GMV_VLSRVH + TMPPRO->GMV_VLSRVP + TMPPRO->GMV_VLSADT)
   GD3->GD3_TIPDES := Iif(lAchou, GD3->GD3_TIPDES, TMPPRO->GD3_TIPDES)
  MsUnlock()
  
  TMPPRO->(DbSkip())
 End
 
 TMPPRO->(DbCloseArea())
 
 RestArea(aArea)
Return()

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
Local aRotina :=	{{OemToAnsi(STR0001), "axPesqui" , 0, 1, 0, Nil},; //"Pesquisar"
	             	 {OemToAnsi(STR0002), 'HSPAA71'  , 0, 2, 0, Nil},; //"Visualizar"
	             	 {OemToAnsi(STR0003), 'HSPAA71'  , 0, 3, 0, Nil},; //"Incluir"
	             	 {OemToAnsi(STR0004), 'HSPAA71'  , 0, 4, 2, Nil},; //"Alterar"
	             	 {OemToAnsi(STR0005), 'HSPAA71'  , 0, 5, 0, Nil},; //"Excluir"
	             	 {OemToAnsi(STR0006), 'HSPAA71'  , 0, 3, 0, Nil},; //"Gerar"
	             	 {OemToAnsi(STR0007), 'HSPAA71'  , 0, 3, 0, Nil},; //"Copiar"
	             	 {OemToAnsi(STR0018), "HS_AA7REA", 0, 8, 0, Nil},; //"Reajuste"
	             	 {OemToAnsi(STR0019), "HS_AA7ATU", 0, 9, 0, Nil}}  //"Atualização"
	              //	 {OemToAnsi(STR0029), "HS_AA7SUS", 0, 9, 0, Nil}}
Return(aRotina)

