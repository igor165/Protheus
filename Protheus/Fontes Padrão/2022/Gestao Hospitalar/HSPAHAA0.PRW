#INCLUDE "HSPAHAA0.ch"
#include "protheus.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHAA0  º Autor ³ Cibele Peria       º Data ³  24/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Geracao das observacoes de marcacao dos cadastros de:      º±±
±±º          ³ Convenio, Medico e Procedimento                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar (Agenda Ambulatorial)             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HSPAHAA0()                                                                              
 Private oFolder, oDlg, Inclui := .F.

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) From 07,0 to 38,85	of oMainWnd  //"Observacoes de Marcacao"
  
  // Monta o Folder
  @ 012, 000 FOLDER oFolder SIZE 337, 255 OF oDlg PROMPTS STR0002, STR0003, STR0004 PIXEL //"Convenios"###"Medicos"###"Procedimentos"
  
  oMBGA9 := HS_MBrow(oFolder:aDialogs[1], "GA9", {000, 000, 335, 185}, /*cTopFun*/, /*cBotFun*/, /*cCpoSta*/, /*aResLeg*/, /*cCpoMar*/, /*aResMar*/, /*aItensMar*/, /*cCpoChave*/, /*bViewReg*/, .T., /*cFunMB*/, /*lBrowse*/, {"GA9_CODCON", "GA9_NOME  "}, /*cFunAM*/)
  oMBGA9:BLDBLCLICK := {|| FS_EMemo("GA9_OBSERV", STR0005, "GA9->GA9_NOME"  , .T.)} //"Observacoes"
  
  oMBGBJ := HS_MBrow(oFolder:aDialogs[2], "GBJ", {000, 000, 335, 185}, /*cTopFun*/, /*cBotFun*/, /*cCpoSta*/, /*aResLeg*/, /*cCpoMar*/, /*aResMar*/, /*aItensMar*/, /*cCpoChave*/, /*bViewReg*/, .T., /*cFunMB*/, /*lBrowse*/, {"GBJ_CRM   ", "GBJ_NOMMED"}, /*cFunAM*/, /*aRotMB*/, /*aCIniBrw*/, .T.)
  oMBGBJ:BLDBLCLICK := {|| FS_EMemo("GBJ_OBSERV", STR0005, "GBJ->GBJ_NOMMED", .T.)} //"Observacoes"
  
  oMBGa7 := HS_MBrow(oFolder:aDialogs[3], "GA7", {000, 000, 335, 185}, /*cTopFun*/, /*cBotFun*/, /*cCpoSta*/, /*aResLeg*/, /*cCpoMar*/, /*aResMar*/, /*aItensMar*/, /*cCpoChave*/, /*bViewReg*/, .T., /*cFunMB*/, /*lBrowse*/, {"GA7_CODPRO", "GA7_DESC  "}, /*cFunAM*/)        
  oMBGa7:BLDBLCLICK := {|| FS_EMemo("GA7_OBSERV", STR0005, "GA7->GA7_DESC"  , .T.)} //"Observacoes"
  
 ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar (oDlg, {|| oDlg:End()}, {|| oDlg:End()})
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_EMemo º Autor ³ Jose Orfeu         º Data ³  25/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Abre campo memo                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar (Agenda Ambulatorial)             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_EMemo(cCampo, cLabel, cCpoMsg, lEdit)
 Local oDlgM, oTexto, cTexto	:= "", aCpoMem := HS_CfgSx3(cCampo), aCpoMsg := HS_CfgSx3(SubStr(cCpoMsg, 6)), cMsg := ""
 Local cAlias := SUBSTR(cCampo,1,3)
 
 If aCpoMsg[25] == "V"
  cMsg := CriaVar(SubStr(cCpoMsg, 6))
 Else
  cMsg := &(cCpoMsg)
 EndIf
 
 lEdit  := IIf(lEdit  == Nil,           .T., lEdit)        
 cLabel := IIf(cLabel == Nil,            "", cLabel)
  
 cTexto := &(cAlias + "->" + cCampo)
 DEFINE MSDIALOG oDlgM FROM	62,100 TO 320,510 TITLE aCpoMem[10] PIXEL

  @ 003, 004 TO 027, 200 Label cLabel OF oDlgM PIXEL
  @ 040, 004 TO 110, 200 OF oDlgM PIXEL

  @ 013, 010 SAY cMsg SIZE 185, 010 OF oDlgM PIXEL

  @ 050, 010 GET oTexto VAR cTexto MEMO When lEdit SIZE 178.64, 051 OF oDlgM PIXEL   

 DEFINE SBUTTON FROM 115,170 TYPE 1 ACTION (FS_GMemo(cAlias,cCampo,cTexto),oDlgM:End()) ENABLE OF oDlgM

 ACTIVATE MSDIALOG oDlgM CENTERED 

Return(Nil)



Static Functio FS_GMemo(cAlias,cCampo,cTexto)
 
 RecLock(cAlias, .F.)
  &(calias + "->" + cCampo) := cTexto
 MsUnlock()                  

Return(Nil)
