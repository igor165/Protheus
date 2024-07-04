#INCLUDE "HSPAHP34.ch"
#include "protheus.CH"
#include "colors.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP34  º Autor ³ José Orfeu         º Data ³  18/10/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consulta Resultados                                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP34() 
 aRotina := {{OemtoAnsi(STR0001), "HS_PESQ()"  , 0, 1}, ; // "Pesquisar //"Pesquisar"
             {OemtoAnsi(STR0002), "HSPAH341(4)", 0, 2}}   // "Consulta Solicitacoes" //"Exames"

 cCadastro := OemToAnsi(STR0003) //"Consulta Resultados de Exames"

 Private AHEADER  := {}, ACOLS := {}

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Endereca a funcao de BROWSE                                  ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 dbSelectArea("GAD")

 mBrowse(06, 01, 22, 75, "GAD")
Return NIL

Function HSPAH341() 
 Private cTabela  
 Private cIndice1 
 
 aRotina   := {{OemtoAnsi(STR0004),"HSPAH343(4)", 0 , 2 }}     //"Resultado"
 cCadastro := OemToAnsi(STR0005) //"Resultados de Exames"
 aCampos   := {{"GBY_DATRES", "D", 08, 00}, ;
               {"GBY_SOLICI", "C", 06, 00}, ;
               {"GBY_CODPRO", "C", 09, 00}, ;
               {"GBY_DESPRO", "C", 50, 00}, ; 
               {"GBY_LOGARQ", "C", 40, 00}, ; 
               {"GBY_RESULT", "C", 60, 00}}

 aCpo      := {{STR0006, "GBY_DATRES", "@D", "08", "00"}, ; //"Data"
               {STR0007, "GBY_SOLICI", "@!", "06", "00"}, ; //"Solicitacao"
               {STR0008, "GBY_CODPRO", "@!", "09", "00"}, ; //"Cod.Proced."
               {STR0009, "GBY_DESPRO", "@!", "50", "00"}, ; //"Descricao"
               {STR0010, "GBY_LOGARQ", "@!", "40", "00"}, ; //"Log Arquivo"
               {STR0004, "GBY_RESULT", "@!", "60", "00"}}   //"Resultado"

 HS_PrepArq()
                   
 DbSelectArea("GAFIL")

 mBrowse(06, 01, 22, 75, "GAFIL", aCpo,,,, 05,)

 DbSelectArea("GAFIL")
 DbCloseArea()
 fErase(cTabela)
 fErase(cIndice1)

 dbSelectArea("GAD")

 aRotina := {{OemtoAnsi(""), "", 0 , 1}, ; 
             {OemtoAnsi(""), "", 0 , 2}, ;
             {OemtoAnsi(""), "", 0 , 3}, ;
             {OemtoAnsi(""), "", 0 , 4, 2}, ;
             {OemtoAnsi(""), "", 0 , 5, 1}} 
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HSPAH343    ³ Autor ³ José Orfeu         ³ Data ³ 18/10/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Trata as variaveis de abertura quando utiliza o Word     	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Especifico                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function HSPAH343()
 Private oWord
 // Inicializa o Ole com o MS-Word 97 ( 8.0 )	
 oWord := OLE_CreateLink('TMsOleWord97')		
 cFOpen := Alltrim(GBY_RESULT)

 oleWdVisible := .T.
 oleWdPrintBack := .F.
 
 OLE_OpenFile(oWord,cFOpen)       
Return .T.

Static Function HS_PrepArq()
 //Local cDirSrv  := Upper(GetPvProfString(GetEnvServer(), "RootPath", "", GetADV97())) 
 Local cDirLaud := AllTrim(GetMV("MV_DIRLAUD"))
      
 //If SubStr(cDirSrv, Len(cDirSrv), 1) == "\"
 // cDirSrv := SubStr(cDirSrv, 1, Len(cDirSrv) - 1)
 //EndIf
 
 If SubStr(cDirLaud, Len(cDirLaud), 1) == "\"
  cDirLaud := SubStr(cDirLaud, 1, Len(cDirLaud) - 1)
 EndIf            
 
 cTabela  := CriaTrab(aCampos, .T.)
 cIndice1 := CriaTrab(Nil    , .F.)
 
 DbUseArea(.T., "DBFCDX", cTabela, "GAFIL", .F., .F.)
 DbCreateIndex(cIndice1, "DTOS(GBY_DATRES)", {|| GBY_DATRES})
 
 DbSelectArea("GAFIL")
 DbCloseArea()                                        
 DbUseArea(.T., "DBFCDX", cTabela, "GAFIL", .T., .F.)
 DbSetIndex(cIndice1)
 DbSetOrder(1)
 
 DbSelectArea("GBX")              
 DbSetOrder(2)
 dbseek(xFilial("GBX")+GAD->GAD_REGATE)
 IF FOUND()    
  While !eof() .and. GBX->GBX_FILIAL == xFilial("GBX") .AND. GBX->GBX_REGATE == GAD->GAD_REGATE 
   CCODPRO := SPACE(09)
   DbSelectArea("GBY")
   DBSetOrder(1)
   dBGotop()
   dbseek(xFilial("GBY")+GBX->GBX_SOLICI)
   IF FOUND()
    N:=0
    WHILE !EOF() .AND. GBY->GBY_FILIAL == XFILIAL("GBY") .AND. GBY->GBY_SOLICI == GBX->GBX_SOLICI
     IF GBY->GBY_ENTREG <> '1'
      DBSKIP()
      LOOP 
     ENDIF
             
     CCODPRO := GBY->GBY_PROSOL
     CDESPRO := SPACE(50)
     DbSelectArea("GA7")
     DBSetOrder(1)
     dBGotop()
     dbseek(xFilial("GA7")+GBY->GBY_PROSOL)
     IF FOUND()
      CDESPRO := GA7->GA7_DESC
     ENDIF                      
     N := N + 1   
     DbSelectArea("GAFIL")
     RECLOCK("GAFIL",.t.)
     GBY_DATRES := GBX->GBX_DATSOL
     GBY_SOLICI := GBX->GBX_SOLICI 
     GBY_CODPRO := CCODPRO
     GBY_DESPRO := CDESPRO       
     //GBY_RESULT := cDirSrv + cDirLaud + "\" + GBX->GBX_SOLICI + STRZERO(N, 2) + ".DOC"
     GBY_RESULT := cDirLaud + "\" + GBX->GBX_SOLICI + STRZERO(N, 2) + ".DOC"
     GBY_LOGARQ := GBY->GBY_LOGARQ
     MsUnlock()
            
     DbSelectArea("GBY")
     DbSkip()
    ENDDO   
   ENDIF
      
   DbSelectArea("GBX")
   DbSkip()
  ENDDO

  dbSelectArea("GAD")

 ENDIF
Return(.T.)