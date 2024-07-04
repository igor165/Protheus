#INCLUDE "hspaha90.ch"
#include "protheus.CH"
#include "colors.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA90  º Autor ³ Mario Arizono      º Data ³  02/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Prescricao Padrao                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHA90()  
 Local aVerTab := {{"T", "GHT"},;
                   {"C", "GHU_CDMEDI"},;
                   {"C", "GHU_DSITEM"},;
                   {"C", "GHU_APRESD"},;
                   {"C", "GHU_CDITPO"},;
                   {"C", "GHU_CDFRQA"},;
                   {"C", "GHU_DSFRQA"},;
                   {"C", "GHU_CDITUC"},;
                   {"C", "GHU_CDUNIC"},;
                   {"C", "GHU_DUNICO"},;
                   {"C", "GHU_IDREGI"},;
                   {"C", "GHU_OBSREG"},;
                   {"C", "GHU_VOLUME"},;
                   {"C", "GHU_CODVIA"},; 
                   {"C", "GHU_DESVIA"},;
                  	{"C", "GHU_CDMINF"},;
													     	{"C", "GHU_DSMINF"},;
                  	{"C", "GHU_QTDMED"},;
													     	{"C", "GHU_VELINF"}}    
  
 
 Local aCores := {{"GHT->GHT_ATIPRE == '0' ", 'BR_VERMELHO'  },;
                  {"GHT->GHT_ATIPRE == '1' ", 'BR_VERDE'}}

 
 Private cCadastro := STR0001 //"Cadastro de Prescricao Padrao"
 Private aRotina   := {{ OemToAnsi(STR0002)    ,"axPesqui", 0 , 1},;   //"Pesquisar"
								               { OemToAnsi(STR0003)    , "HS_Mnt90", 0 , 2},;  //"Visualizar"
                        { OemToAnsi(STR0004)   , "HS_Mnt90", 0 , 3},;  //"Incluir"
                        { OemToAnsi(STR0005)   , "HS_Mnt90", 0 , 4},;  //"Alterar"
                        { OemToAnsi(STR0006)   , "HS_Mnt90", 0 , 5},;  //"Excluir"
                        { OemToAnsi(STR0007)   , "HS_Mnt90", 0 , 4},;  //"Copiar"
                        { OemToAnsi(STR0008)   , "HSPAHR90", 0 , 3},;  //"Impressão"
                        { OemtoAnsi(STR0009)   , "HS_LegA90", 0, 1}}   //"Legenda"



  
 If !HS_EXISDIC(aVerTab)
  Return()
 Endif 
                                                                             
 DbSelectArea("GHT")
 DbSetOrder(1)

 mBrowse( 6, 1,22,75,"GHT",,,,,,aCores)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ HS_Mnt90 ³ Autor ³ Mario Arizono         ³ Data ³02/05/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Montagem das rotinas de tratamento da Presc. Padrao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_Mnt90(cAlias, nReg, nOpc)

 Local nOpcG := IIF(StrZero(aRotina[nOpc, 4], 2) $ "03/04", GD_DELETE, 0)
 Local nOpcA := 0
 Local aSize  := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local cGhtSeqPre := ""
 Local aButtons   := {}
 Local bFS_IncPre	:= {||HS_PreMed(oGHU, nGhuAprese, , LEN(GHU->GHU_APRESE), nGhuCdMedi, nGhuCdItpo)}
 
 
 Private nOpcA90 := nOpc
 Private oGHT, oGHU, oDlgA90
 Private aHGHU := {}, aCGHU := {}, nUGHU := 0
 
 Private aTela := {}, aGets := {}
 Private nGhuAprese := 0, nGhuCdItmp := 0, nGhuItemBr := 0, nGhuTpItmp := 0   
 Private nGhuCdMedi := 0, nGhuDsItem := 0, nGhuApresD := 0, nGhuCdItpo := 0, nGhuCdFrqa := 0, nGhuDsFrqa := 0, nGhuCdItuc := 0
 Private nGhuCdunic := 0, nGhuDunico := 0, nGhuIdRegi := 0, nGhuObsReg := 0, nGhuVolume := 0, nGhuCodVia := 0, nGhuDesvia := 0
 Private nGhuCdMinf := 0, nGhuDsMinf := 0, nGhuVelInf := 0, nGhuQtdMed := 0
 
 Private __aItPresc := {{"oGHU:aCols[oGHU:nAt, nGhuTpItmp]",     "03"},; 
                        {"oGHU:aCols[oGHU:nAt, nGhuCdMedi]",     "01"},; 
                        {"oGHU:aCols[oGHU:nAt, nGhuDsItem]",     "02"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuCdItmp]", "10, 02"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuAprese]",     "05"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuApresD]", "10, 06"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuCodVia]", "10, 04"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuDesvia]", "10, 05"},; 
                        {"oGHU:aCols[oGHU:nAt, nGhuCdItpo]", "11, 02"},; 
                        {"oGHU:aCols[oGHU:nAt, nGhuCdFrqa]", "11, 03"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuDsFrqa]", "11, 04"},; 
                        {"oGHU:aCols[oGHU:nAt, nGhuCdItuc]", "12, 02"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuCdunic]", "12, 03"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuDunico]", "12, 04"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuIdRegi]",     "07"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuObsreg]",     "08"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuQtdMed]",     "14"}}
 
 Private __aItCompo := {{"oGHU:aCols[oGHU:nAt, nGhuTpItmp]", "13, 08"},; 
                        {"oGHU:aCols[oGHU:nAt, nGhuCdMedi]", "13, 02"},; 
                        {"oGHU:aCols[oGHU:nAt, nGhuDsItem]", "13, 03"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuAprese]", "13, 09"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuCdunic]", "13, 05"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuDunico]", "13, 06"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuQtdMed]", "13, 04"}}
                        
 
 Private __aItDieta := {{"oGHU:aCols[oGHU:nAt, nGhuTpItmp]",     "03"},; 
                        {"oGHU:aCols[oGHU:nAt, nGhuCdMedi]",     "01"},; 
                        {"oGHU:aCols[oGHU:nAt, nGhuDsItem]",     "02"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuVolume]",     "05"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuCodVia]",     "06"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuDesvia]",     "07"},; 
                        {"oGHU:aCols[oGHU:nAt, nGhuVelInf]",     "08"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuCdMinf]",     "09"},; 
                        {"oGHU:aCols[oGHU:nAt, nGhuDsMinf]",     "10"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuCdFrqa]",     "11"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuDsFrqa]",     "12"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuObsreg]",     "13"}}
                         
                        
 Private __aItCuida := {{"oGHU:aCols[oGHU:nAt, nGhuTpItmp]",     "03"},; 
                        {"oGHU:aCols[oGHU:nAt, nGhuCdMedi]",     "01"},; 
                        {"oGHU:aCols[oGHU:nAt, nGhuDsItem]",     "02"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuCdFrqa]",     "05"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuDsFrqa]",     "06"},;
                        {"oGHU:aCols[oGHU:nAt, nGhuObsreg]",     "07"}}
                        
                        
 Aadd(aButtons	,{'NOTE'    ,  {||Eval(bFS_IncPre)}, STR0018, STR0019})  //"Incluir item da prescrição"##"Inc. Item" 
 
 RegToMemory("GHT", aRotina[nOpcA90, 4] == 3 .Or. nOpcA90 == 6)     
 
 cGhtSeqPre := IIF(nOpcA90 == 6, GHT->GHT_SEQPRE, M->GHT_SEQPRE)
             
 HS_BDados("GHU", @aHGHU, @aCGHU, @nUGHU, 1, cGhtSeqPre, IIf(aRotina[nOpcA90, 4] == 3 .And. nOpcA90 <> 6, Nil, "GHU->GHU_SEQPRE == '" + cGhtSeqPre + "'"))
 
 nGhuItemBr := aScan(aHGHU, {|aVet| aVet[2] == "GHU_ITEMBR"})
 nGhuTpItmp := aScan(aHGHU, {|aVet| aVet[2] == "GHU_TPITMP"})
 nGhuAprese := aScan(aHGHU, {|aVet| aVet[2] == "GHU_APRESE"})
 nGhuCdItmp := aScan(aHGHU, {|aVet| aVet[2] == "GHU_CDITMP"})
 nGhuCdMedi := aScan(aHGHU, {|aVet| aVet[2] == "GHU_CDMEDI"})
 nGhuDsItem := aScan(aHGHU, {|aVet| aVet[2] == "GHU_DSITEM"})
 nGhuApresD := aScan(aHGHU, {|aVet| aVet[2] == "GHU_APRESD"})
 nGhuCdItpo := aScan(aHGHU, {|aVet| aVet[2] == "GHU_CDITPO"})  
 nGhuCdFrqa := aScan(aHGHU, {|aVet| aVet[2] == "GHU_CDFRQA"}) 
 nGhuDsFrqa := aScan(aHGHU, {|aVet| aVet[2] == "GHU_DSFRQA"})
 nGhuCdItuc := aScan(aHGHU, {|aVet| aVet[2] == "GHU_CDITUC"})
 nGhuCdunic := aScan(aHGHU, {|aVet| aVet[2] == "GHU_CDUNIC"})
 nGhuDunico := aScan(aHGHU, {|aVet| aVet[2] == "GHU_DUNICO"})
 nGhuIdRegi := aScan(aHGHU, {|aVet| aVet[2] == "GHU_IDREGI"})
 nGhuObsReg := aScan(aHGHU, {|aVet| aVet[2] == "GHU_OBSREG"})         
 nGhuVolume := aScan(aHGHU, {|aVet| aVet[2] == "GHU_VOLUME"})
 nGhuCodVia := aScan(aHGHU, {|aVet| aVet[2] == "GHU_CODVIA"})
 nGhuDesvia := aScan(aHGHU, {|aVet| aVet[2] == "GHU_DESVIA"})
 nGhuCdMinf := aScan(aHGHU, {|aVet| aVet[2] == "GHU_CDMINF"})
 nGhuDsMinf := aScan(aHGHU, {|aVet| aVet[2] == "GHU_DSMINF"})
 nGhuVelInf := aScan(aHGHU, {|aVet| aVet[2] == "GHU_VELINF"}) 
 nGhuQtdMed := aScan(aHGHU, {|aVet| aVet[2] == "GHU_QTDMED"}) 
  
 If aRotina[nOpcA90, 4] == 3   .Or. Empty(aCGHU[1, nGhuItemBr])
  aCGHU[1, nGhuItemBr] := Soma1(aCGHU[1, nGhuItemBr], Len(aCGHU[1, nGhuItemBr]))
 EndIf 
 
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 030, .T., .T. } )	
 AAdd( aObjects, { 100, 070, .T., .T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )
 
 
 nOpcA := 0
 DEFINE MSDIALOG oDlgA90 TITLE STR0010 From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel   //"Cadastro Prescricao Padrão"

  oGHT := MsMGet():New("GHT", nReg, nOpcA90,,,,, aPObjs[1],, 3,,,,oDlgA90)
  oGHT:aEntryCtrls[aScan(oGHT:aGets, {|x| "GHT_ATIPRE" $ x}) ]:lReadOnly := (aRotina[nOpcA90, 4] == 3 .Or. nOpcA90 == 6)
  oGHT:oBox:Align := CONTROL_ALIGN_TOP   
  
  oGHU := MsNewGetDados():New(aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], nOpcG,"HS_DuplAC(oGHU:oBrowse:nAt, oGHU:aCols, { nGhuTpItmp, nGhuAprese, nGhuCdItmp})",,"+GHU_ITEMBR",,, 99999,,,,, aHGHU, aCGHU)
  oGHU:oBrowse:Align  := CONTROL_ALIGN_ALLCLIENT
  
  
 ACTIVATE MSDIALOG oDlgA90 ON INIT EnchoiceBar(oDlgA90, {|| nOpcA := 1, IIf(oGHU:TudoOk()  .And. Obrigatorio(aGets, aTela), oDlgA90:End(), nOpcA := 0)}, ;
                                                  {|| nOpcA := 0, oDlgA90:End()},,aButtons)   
                                                  
 If nOpcA == 1
  If aRotina[nOpcA90, 4] == 3
   Inclui := .T.
   Altera := .F.
  ElseIf aRotina[nOpcA90, 4] == 4
   Inclui := .F.
   Altera := .T.
  Endif 
  
  Begin Transaction 
   FS_GRVA90()
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
±±³Fun‡„o    ³ FS_GRVA90³ Autor ³ Mario Arizono         ³ Data ³02/05/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao para gravacao das Prescricoes Padroes               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_GRVA90()
 Local nForA := 0

 If aRotina[nOpcA90, 4] == 2 
  Return()
 Endif 
 

 If Inclui .Or. Altera 
  If Inclui
   M->GHT_SEQPRE := HS_VSxeNum("GHT", "M->GHT_SEQPRE", 1)
  Endif
  RecLock("GHT", Inclui .Or. nOpcA90 == 6)
   HS_GRVCPO("GHT")
   GHT->GHT_FILIAL  := xFilial("GHT")    
 	MsUnlock()
 	  		 
 Else  // exclusao
  RecLock("GHT",.F.,.T.)
   Dbdelete()
  MsUnlock()
  WriteSx2("GHT") 
 
 Endif
     
 For nForA := 1 To Len(oGHU:aCols)
  DbSelectArea("GHU")
  DbSetOrder(1)
  lAchou := DbSeek(xFilial("GHU") + oGHU:aCols[nForA, nGhuItemBr] + M->GHT_SEQPRE )                                
  If Inclui .Or. Altera 
   If oGHU:aCols[nForA, nUGHU+1] .And. lAchou // exclusao
    RecLock("GHU", .F., .T.)
     Dbdelete()
    MsUnlock()
    WriteSx2("GHU")
  	   
   ElseIf !oGHU:aCols[nForA, nUGHU+1] 
    RecLock("GHU", !lAchou)
     HS_GRVCPO("GHU", oGHU:aCols, oGHU:aHeader, nForA)
	    GHU->GHU_FILIAL := xFilial("GHU")  
	    GHU->GHU_SEQPRE := M->GHT_SEQPRE
		  MsUnlock() 
		  
	  Endif 

		Else  	
   If lAchou  // opcao exclusao do menu
    RecLock("GHU",.F.,.T.)
     Dbdelete()
    MsUnlock()
    WriteSx2("GHU")
   Endif   
    
  Endif
 Next   
 
 
Return()        

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_VLDA90 º Autor ³ Mario Arizono      º Data ³  02/05/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Funcao para validacao dos campos da Prescricao Padrao.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

FUNCTION HS_VLDA90()
 Local aArea    := GetArea()
 Local lRet     := .T.
 
 If ReadVar() == "M->GHT_CODCRM"
  If !(lRet := HS_SeekRet("SRA","M->GHT_CODCRM",11,.f.,"GHT_NOMMED","RA_NOME"))
  	HS_MsgInf(STR0011, STR0012, STR0013) //"CRM Inválido"###"Atenção"###"Validação Inclusão/Alteração"
  Endif
 ElseIf ReadVar() == "M->GHT_CODCID"   
	 If !(lRet := HS_SeekRet("GAS","M->GHT_CODCID",1,.f.,"GHT_DESCID","GAS_PATOLO"))
  	HS_MsgInf("CID Inválido", STR0012, STR0013) //"Atenção"###"Validação Inclusão/Alteração"
	 Endif	
 Endif
	
 RestArea(aArea)
 
Return(lRet)          
                   
Function HS_LegA90()
 BrwLegenda(cCadastro, STR0009, {{"BR_VERMELHO"   , STR0016}, ;  //"Legenda"###"Suspensa"
                                  { "BR_VERDE"      , STR0017}})  //"Ativa"
                                 
Return(.T.)



