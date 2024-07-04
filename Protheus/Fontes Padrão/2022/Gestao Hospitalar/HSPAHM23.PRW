#INCLUDE "HSPAHM23.CH"
#include "protheus.CH"
#include "colors.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM23  บ Autor ณ Jos้ Orfeu         บ Data ณ  27/11/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atendimento de solicita็๕es de MAT/MED (Posto)             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHM23()                                                                     
 Local cFiltro
 Local cIDMaq  := HS_NUMID(2, "C:\") // Retorna o Numero de Serie do Volume do Drive C
 Local cCCuInt := HS_RetCCM(cIdMaq) // Retorna o Centro de Custo que a Maquina esta localizada 
 Local aCores  :=  {{"GCL->GCL_FLGPOS=='0'", 'BR_VERDE'   }, ;	   
                    {"GCL->GCL_FLGPOS=='1'", 'BR_AMARELO' }, ;	
                    {"GCL->GCL_FLGPOS=='2'", 'BR_VERMELHO'}}

 Define  FONT oFont NAME "Arial" BOLD

 Private aRotina   := {{OemtoAnsi(STR0001), "axPesqui"    , 0, 1}, ; //"Pesquisar"
                       {OemtoAnsi(STR0002), "HS_ATEM23(1)", 0, 1}, ; //"Atender"
                       {OemtoAnsi(STR0003), "HS_LEGM23()" , 0, 1}}   //"Legenda"
            
 Private cCadastro := OemToAnsi(STR0004) //"Atendimento de Solicita็ใo (Posto)"
 
 DbSelectArea("GAJ")
 DbSetOrder(1)

 DbSelectArea("GCL")
 
 If !Empty(AllTrim(cCCUInt))
  cFiltro  := "GCL->GCL_CODCCU $ '" + cCCuInt + "'"
  HS_AtvFilt("GCL", cFiltro) 
 EndIf 
 
 mBrowse(06, 01, 22, 75, "GCL",,,,,, aCores)
 
 If !Empty(AllTrim(cCCUInt))  
  HS_DtvFilt("GCL") 
 EndIf 
Return(Nil)

Function HS_ATEM23(nOpc)
 Local bCampo := {|nCPO| Field(nCPO)}
 Local cCampo       := ""
 Local oDlgSol, oQtdAte, nQtdAteP := 1, cCodBar := Space(Len(SB1->B1_CODBAR))
 Local aCpoEnchoice := {}
 Local nOpcA := 0, nUsado := 0, nCntFor := 0, aColsBrw := {}
 Local aCorBrw := {{"GAJ->GAJ_ATEPOS + GAJ->GAJ_DEVPOS == 0"                                                          , 'BR_VERDE'   }, ;	    
                   {"GAJ->GAJ_ATEPOS + GAJ->GAJ_DEVPOS > 0 .And. GAJ->GAJ_ATEPOS + GAJ->GAJ_DEVPOS <  GAJ->GAJ_QTDSOL", 'BR_AMARELO' }, ;
                   {"GAJ->GAJ_ATEPOS + GAJ->GAJ_DEVPOS > 0 .And. GAJ->GAJ_ATEPOS + GAJ->GAJ_DEVPOS == GAJ->GAJ_QTDSOL", 'BR_VERMELHO'}}
  
 Private aTela[0][0]
 Private aGets[0]
 Private aCols     := {}
 Private aHeader   := {}             
 
 DbSelectArea("GAI")
 DbSetOrder(1)
 DbSeek(xFilial("GAI") + GCL->GCL_SOLICI)
 
 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek("GAI")
 While !Eof() .And. (SX3->X3_ARQUIVO == "GAI")
  If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL
   AADD(aCpoEnchoice, SX3->X3_CAMPO)
  Endif
  cCampo  := "M->" + SX3->X3_CAMPO
  &cCampo := CriaVar(SX3->X3_CAMPO)
  dbSkip()
 End        
 
 DbSelectArea("GAI")
 For nCntFor := 1 TO FCount()
  M->&(EVAL(bCampo, nCntFor)) := FieldGet(nCntFor)
 Next
  
 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek("GAJ")
 While !Eof() .And. SX3->X3_ARQUIVO == "GAJ"
  If Sx3->X3_CAMPO == "GAJ_QTDATE" .Or. ;
     (X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. SX3->X3_BROWSE == "S" .And. ;
      !(SX3->X3_CAMPO $ "GAJ_SOLICI/GAJ_ORISOL/GAJ_CODTES/GAJ_MOVEST/GAJ_CODJUS/GAJ_JUSTIF/GAJ_SEQDES/GAJ_ENTREG/GAJ_LOGARQ/GAJ_LOGATE/GAJ_RESID "))
   aAdd(aColsBrw, SX3->X3_CAMPO)
  EndIf
  DbSkip()
 End                               
  
 DEFINE MSDIALOG oDlgSol TITLE cCadastro FROM 0,0 TO 500,794 PIXEL
  EnChoice("GAI",,  nOpc,,,, aCpoEnchoice, {015, 000, 090, 398},, 3,,,,,, Inclui)
   
  @ 100, 004 Say OemToAnsi(STR0008) Size 62,9 OF oDlgSol PIXEL COLOR CLR_BLUE FONT oFont //"Quantidade"
  @ 100, 053 MSGet oQtdAte Var nQtdAteP Picture "@E 99,999.9999" Valid FS_VldM23(1, nQtdAteP, cCodBar) Size 43,9 OF oDlgSol PIXEL COLOR CLR_BLACK
    
  @ 100, 100 Say OemToAnsi(STR0009) Size 62,9 OF oDlgSol PIXEL COLOR CLR_BLUE FONT oFont //"Codigo de Barras"
  @ 100, 150 MSGet oCodBar Var cCodBar /*F3 "G1R"*/ Valid FS_VldM23(2, nQtdAteP, cCodBar) Size 90,9 OF oDlgSol PIXEL COLOR CLR_BLACK
   
  oBrwAte := HS_MBrow(oDlgSol, "GAJ", {112, 0, 398, 140}, "'" + GAI->GAI_SOLICI + "'", "'" + GAI->GAI_SOLICI + "'", ;
                      /*cCpoSta*/, aCorBrw, /*cCpoMar*/, /*aResMar*/, /*aItensMar*/, /*cCpoChave*/, /*bViewReg*/, .F., /*cFunMB*/, .F., aColsBrw)
            
  oQtdAte:SetFocus()
 ACTIVATE MSDIALOG oDlgSol CENTERED ON INIT EnchoiceBar(oDlgSol, {|| oDlgSol:End(), nOpcA := 1}, ;
                                                                 {|| oDlgSol:End(), nOpcA := 0})
Return(Nil)

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณHS_LEGM23 ณAutor  ณ Jos้ Orfeu            ณ Data ณ27.11.2003 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณDemonstra a legenda das cores da mbrowse                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณGestao Hospitalar                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
/*/
Function HS_LEGM23()
 BrwLegenda(cCadastro, STR0003, {{"BR_VERDE"   , STR0005}, ; //"Legenda"###"Nao Atendida"
                                 {"BR_AMARELO" , STR0006}, ; //"Parcialmente atendida"
                                 {"BR_VERMELHO", STR0007}})  //"Totalmente atendida"
Return(.T.)
                           
Static Function FS_VldM23(nGetVld, nQtdAteP, cCodBar)
 Local aRValPro := {}
 
 If nGetVld == 1
  If nQtdAteP <= 0
   MsgStop(STR0010, STR0011) //"Quantidade invalida"###"Aten็ใo"
   Return(.F.)
  EndIf  
 ElseIf nGetVld == 2
  If Empty(cCodBar)
   Return(.T.)
  EndIf
  
  If SubStr(cCodBar, 1, 3) == "170"
   MsgStop(STR0012, STR0011) //"UCC-128: Identificador de Aplica็ใo (AI) invแlido"###"Aten็ใo"
   Return(.F.)
  EndIf
  
  cCodBar := IIf(SubStr(cCodBar, 1, 3) == "010", SubStr(cCodBar, 4, 13), SubStr(cCodBar, 1, 13))
    
  DBSelectArea("SB1")
  DBSetOrder(5)
  DBSeek(xFilial("SB1") + cCodBar)
  If !Found()
   DBSelectArea("GAP")
   DBSetOrder(1)
   DBSeek(xFilial("GAP") + cCodBar)
   If !Found()
    MsgStop(STR0013, STR0011) //"Nใo existe produto com este C๓digo de Barras!"###"Aten็ใo"
   	Return(.F.)
   Else
    cCodBar := GAP->GAP_CODIGO
   Endif
  Else
   cCodBar := SB1->B1_COD
  Endif

  DbSelectArea("SB1")
  DBSetOrder(1)
  DBSeek(xFilial("SB1") + PadR(cCodBar, Len(SB1->B1_COD)))
  If !Found()
   MsgStop(STR0014, STR0011) //"Este Produto Nใo Existe no Cadastro (SB1)!"###"Aten็ใo"
   Return(.F.)
  EndIf    
    
  DbSelectArea("GBI")
  DBSetOrder(1)
  DBSeek(xFilial("GBI") + PadR(cCodBar, Len(GBI->GBI_PRODUT)))
  If !Found()
   MsgStop(STR0015, STR0011) //"Este Produto Nใo Existe no Cadastro (GBI)!"###"Aten็ใo"
   Return(.F.)
  EndIf
  
  DbSelectArea("GAJ")
  DbSeek(xFilial("GAJ") + M->GAI_SOLICI + PadR(cCodBar, Len(GAJ->GAJ_PROSOL)))
  If Found()
   If nQtdAteP > (GAJ->GAJ_QTDATE - GAJ->GAJ_DEVPOS - GAJ->GAJ_ATEPOS)
    MsgStop(STR0016, STR0011) //"Quantidade digitada ้ maior que o saldo disponivel da solicita็ใo"###"Aten็ใo"
    Return(.F.)
   Else                                          
    DbSelectArea("GAD")
    DbSetOrder(1)
    DbSeek(xFilial("GAD") + GAI->GAI_REGATE)

    aRValPro := HS_RValPro("0", GAJ->GAJ_PROSOL, GAD->GAD_CODCON, GAD->GAD_CODPLA, GAD->GAD_TABPRO, "2", .T., GAI->GAI_ALMORI, .T.)
    If aRValPro[5] # 0
     Return(.F.)
    EndIf 
    
    Begin Transaction 
     // So grava Itens que Movimentam Estoque
 	   DbSelectArea("GAK")
    	RecLock("GAK", .T.)
     	GAK->GAK_FILIAL  := xFilial("GAK")
    	 GAK->GAK_REGATE  := GAD->GAD_REGATE
     	GAK->GAK_CODCCU  := GAD->GAD_CCUINT
     	GAK->GAK_SEQDES  := GetSXENum("GAK","GAK_SEQDES",,6)
     	GAK->GAK_CODMAT  := GAJ->GAJ_PROSOL
     	GAK->GAK_QTDMAT  := nQtdAteP
     	GAK->GAK_DATMAT  := GAI->GAI_DATSOL
     	GAK->GAK_VALREA  := aRValPro[1]
     	GAK->GAK_CODPRE  := aRValPro[3]
     	GAK->GAK_PCUMAT  := aRValPro[2]
     	GAK->GAK_FLGDCI  := GAI->GAI_FLGDCI
     	GAK->GAK_DSPBER  := GAI->GAI_DSPBER
     	GAK->GAK_GLOMAT  := IIf(aRValPro[4], "2", "0") // 2-Exce็ใo ou 0-Normal
     	GAK->GAK_CODCCI  := HS_CentLuc(GAD->GAD_CODCON, GAD->GAD_CCUINT)
     	GAK->GAK_LOGARQ  := cUserName + " - " + StrZero(Day(dDataBase), 02) + "/" + StrZero(Month(dDataBase), 02) + "/" + Str(Year(dDataBase), 04) + " - " + Time() + "h"
     	GAK->GAK_SOLICI  := GAI->GAI_SOLICI
 	   MsUnlock()
 	   ConfirmSx8()
 		
   	 DbSelectArea("GAJ")	              
 	   RecLock("GAJ", .F.)
      GAJ->GAJ_ATEPOS := GAJ->GAJ_ATEPOS + nQtdAteP
 	    GAJ->GAJ_SEQDES := GAK->GAK_SEQDES
 	    GAJ->GAJ_LOGATP := HS_LogArq()
     MsUnlock()    
 
     DbSelectArea("GAI")
     RecLock("GAI", .F.)
      GAI->GAI_FLGPOS := FS_VerFlg(GAJ->GAJ_SOLICI) //IIf(GAJ->GAJ_QTDSOL == GAJ->GAJ_ATEPOS + GAJ->GAJ_DEVPOS, "2", "1") 
     MsUnLock()       
     
     DbSelectArea("GCL")
     RecLock("GCL", .F.)
      If GAI->GAI_FLGPOS == "2" // 2-Total, retira do arquivo de solicita็๕es pendentes
       DbDelete()           
      Else
       GCL->GCL_FLGPOS := GAI->GAI_FLGPOS
      EndIf 
     MsUnLock()
    End Transaction
 
    oBrwAte:Refresh()
   EndIf 
  Else 
   MsgStop(STR0017, STR0011) //"Este Produto Nใo Existe na solicita็ใo (GBI)!"###"Aten็ใo"
   Return(.F.)
  EndIf  
 EndIf
Return(.T.)

Static Function FS_VerFlg(cGAJ_SOLICI)
 Local nFlgPos := "0", nRecGaj := GAJ->(RecNo()), cAliasOld := Alias()
 Local nQtdSol := 0, nQPosAte := 0, nQPosDev := 0
 DbSelectArea("GAJ")
 DbSetOrder(1)
 DbSeek(xFilial("GAJ") + cGaj_Solici)
 While !Eof() .And. GAJ->GAJ_SOLICI == cGaj_Solici
  nQtdSol  += GAJ->GAJ_QTDSOL
  nQPosAte += GAJ->GAJ_ATEPOS
  nQPosDev += GAJ->GAJ_DEVPOS  
 
  DbSkip()
 End                         
 
 If nQtdSol == nQPosAte + nQPosDev
  nFlgPos := "2"
 Else 
  If nQPosAte > 0
   nFlgPos := "1"
  Else           
   nFlgPos := "0"
  EndIf 
 EndIf 
    
 DbGoTo(nRecGaj)
 DbSelectArea(cAliasOld)
Return(nFlgPos)
