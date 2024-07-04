#INCLUDE "Ofigm030.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIGM030 ³ Autor ³  Renata               ³ Data ³ 23/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclui garantia Scania                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Garantia  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "protheus.ch"

FUNCTION OFIGM030

PRIVATE cChave, cCond
PRIVATE aRotina := MenuDef()
private oNroRrI, oNroRrF, oAnoRr,oCodMar
private cNroRrI, cNroRrF, cAnoRr,cCodMar, cDesMar, cNumOsv
private aCampos := {}

FS_MENUM030()

if len(aRotina) == 0
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0001)  //exclusao de RR //"Exclusao da RR"
PRIVATE cIndex, nIndex := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("VG8")
cIndex  := CriaTrab(nil,.f.)
cChave  := IndexKey()
cCond   := 'VG8_NUMOSV = "'+cNumOsv+'" .and. VG8_EXCLUI=space(1) .and. VG8_CODMAR = "'+cCodMar+'"'
IndRegua("VG8",cIndex,cChave,,cCond,STR0002) //"Aguarde, filtrando registros..."

DbSelectArea("VG8")
nIndex := RetIndex("VG8")
#IFNDEF TOP
   dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)

mBrowse( 6, 1,22,75,"VG8",,,,"VG8_NUMOSV = cNumOsv .and. VG8_EXCLUI=space(1) .and. VG8_CODMAR = cCodMar")

dbSelectArea("VG8")
RetIndex()
DbsetOrder(1)
 
#IFNDEF TOP
   If File(cIndex+OrdBagExt())
      fErase(cIndex+OrdBagExt())
   Endif
#ENDIF

Return
  
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_MENUM030 Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o menu de opcoes do programa                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_MENUM030(Alias,nReg,nOpc)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MENUM030(cAlias, nReg, nOpc)
********************************

//aAltSx1  := { {"01",STR(year(date()),4),"","","","","","","","","","","","","","",""} }         
//FG_AltSx1("OFGSC1","A",aAltSx1)
//if !Pergunte("OFGSC1",.t.) 
//   return
//endif

//cAnoRR  := MV_PAR01
//cNroRri := MV_PAR02
       
if !Pergunte("OFGSC2",.t.) 
   return
endif

cCodMar := MV_PAR01  
cNumOsv := MV_PAR02

return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GM030E    ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o listbox para marcar as pecas e/ou servicos a serem ³±±
±±³          ³ excluidos                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM030E(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GM030E(cAlias,nReg,nOpc)

Private aStruEXC := {} , aStruVG8 := {}
Private nValIte := 0 , cCont_t := 0
PRIVATE oLbox
PRIVATE oOk    := LoadBitmap( GetResources(), "LBOK" )
PRIVATE oNo    := LoadBitmap( GetResources(), "LBNO" )
PRIVATE oTik   := LoadBitmap( GetResources(), "LBTIK" )

DbSelectArea("VG6") 
dbsetorder(5)
FG_SEEK("VG6","VG8->VG8_CODMAR+VG8->VG8_NUMOSV+VG8->VG8_ANORRC+VG8->VG8_NUMRRC",5,.f.)

// aStruEXC
// RELAC  L        && 01
// CODMAR C 03     && 02
// NUMOSV C 08     && 03
// ANORRC C 04     && 04
// NUMRRC C 07     && 05
// GRUITE C 03     && 06
// CODITE C 27     && 07
// CODSER C 15     && 08
// NOSNUP C 08     && 09 
// NOSNUS C 08     && 10
// PECINT C 15     && 11
// SERINT C 06     && 12
// VALITE N 12     && 13
// VALSER N 12     && 14
// QTDADE N 06     && 15   
// TIPTEM C 01     && 16

while !eof() .and. VG8->VG8_CODMAR+VG8->VG8_NUMOSV+VG8->VG8_ANORRC+VG8->VG8_NUMRRC == VG6->VG6_CODMAR+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC ;
             .and. VG6->VG6_FILIAL == xFilial("VG6")

   If VG6->VG6_EXCLUI = " " .and. empty(VG6->VG6_RRCNEW)
      aAdd(aStruEXC,{ .f.,VG6_CODMAR,VG6_NUMOSV,VG6_ANORRC,VG6_NUMRRC,VG6_GRUITE,VG6_CODITE,VG6_CODSER,VG6_NOSNUP,VG6_NOSNUS,VG6_PECINT,VG6_SERINT,VG6_VALITE,VG6_VALSER,VG6_QTDITE,VG6_TIPTEM})
   endif

   dbskip()   

Enddo

If Len(aStruEXC) == 0
   aadd(aStruEXC,{ .f.,space(3),space(8),space(4),space(7),space(3),space(27),space(15),space(8),space(8),space(15),space(6),0,0,0})
Endif

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0006) FROM  39,20 TO 54,84 OF oMainWnd //"Pecas/Servicos da RR"
                                                               // PECAS/SERVICOS DA RR
@ 12,.1 LISTBOX oLbox FIELDS HEADER OemToAnsi(""),;            // Indicador de Relacionamento
                                    OemToAnsi(STR0007),;       //  //"Marca"
                                    OemtoAnsi(STR0008),;       //  //"Ord.Serv"
                                    OemToAnsi(STR0009),;       //  //"Ano"
                                    OemtoAnsi(STR0010),;       //  //"Num.RR"
                                    OemtoAnsi(STR0011),;       //  //"Grupo"
                                    OemToAnsi(STR0012),;       //  //"Cod.Item"
                                    OemToAnsi(STR0013),;       //  //"Qtdade"
                                    OemtoAnsi(STR0014);        //  //"Cod.Serv"
	COLSIZES 10,20,30,20,30,20,40,20,40;    
	SIZE 254,101 OF Odlg PIXEL ON DBLCLICK (nPos:=oLbox:nAt,FS_GaExc(),oLbox:Refresh(),oLbox:nAt:=nPos)

oLbox:SetArray(aStruEXC)
oLbox:bLine := { || { if(aStruEXC[oLbox:nAt,01] == .f.,oNo,oTik),;
aStruEXC[oLbox:nAt,02],;
aStruEXC[oLbox:nAt,03],;
aStruEXC[oLbox:nAt,04],;
aStruEXC[oLbox:nAt,05],;
aStruEXC[oLbox:nAt,06],;
aStruEXC[oLbox:nAt,07],;
aStruEXC[oLbox:nAt,15],;
aStruEXC[oLbox:nAt,08]}}

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| If( FS_FLAGEXC() , oDlg:End() , .f. ) },{|| oDlg:End() } )
        
DbSelectArea("VG8")
dbSetOrder(nIndex+1)
      
//dbSelectArea("VG8")
//cIndex  := CriaTrab(nil,.f.)
//cChave  := IndexKey()
//cCond   := 'VG8_NUMRRC = "'+cNroRri+'"  .and. VG8_ANORRC = "'+cAnoRr+'" .and. VG8_EXCLUI=space(1) .and. empty(VG8_RRCNEW) .and. VG8_CODMAR = "'+cCodMar+'"'
//cCond   := 'VG8_NUMOSV = "'+cNumOsv+'" .and. VG8_EXCLUI=space(1) .and. VG8_CODMAR = "'+cCodMar+'"'
//IndRegua("VG8",cIndex,cChave,,cCond,"Aguarde, filtrando registros...")

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VLDM030   ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se as rr's das pecas ou servicos marcadas para    ³±±
±±³          ³ exclusao podem ser excluidas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ VLDM030(ARG)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 0 - RR INICIAL / 1 - MARCA / 2 - RR FINAL / 3- ANO DA RR   ³±±
±±³          ³ 4 - TIP SERV                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FS_VLDM030(Arg)
********************

if Arg == 0

   FG_STRZERO("cNroRrI",7)

   if !FG_SEEK("VG8","cCodMar+cAnoRr+cNroRrI",2,.F.) .or. empty(cNroRrI)
      help(" ",1,"SITRR1GM30")
      return .f.
   elseif !empty(VG8->VG8_RRCNEW)                       
      help(" ",1,"SITRR2GM30")
      return .f.
   elseif VG8->VG8_EXCLUI = "S"
      help(" ",1,"SITRR3GM30") 
      return .f.
   endif

   return .t.

elseif Arg == 1

   if Empty(cCodMar)
      Return .f.
   Else
      dbselectarea("VE1")
      if !FG_SEEK("VE1","cCodMar",1,.F.)
         help(" ",1,"CMARCAGM30") 
         Return .f.
      else
         cDesMar := subs(VE1->VE1_DESMAR,1,6)
         return .t.
      endif
   endif

elseif Arg == 2

   FG_STRZERO("cNroRrF",7)

   if !FG_SEEK("VG8","cCodMar+cAnoRr+cNroRrF",2,.F.)
       help(" ",1,"SITRR5GM30") 
       Return .f.
   endif

   return .t.

elseif Arg == 3

   if !FG_SEEK("VG8","cCodMar+cAnoRr",2,.F.)
       help(" ",1,"SANORRGM30")
       Return .f.
   endif

   return .t.
               
elseif Arg == 4

  if empty(cTipSer)
     return .f.
  endif

  if !FG_SEEK("VOK","cTipSer",1,.F.)
       help(" ",1,"TIPSERGM30") 
       Return .f.
   endif

   return .t.
 
endif           

Return .f.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_GAEXC  ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o listbox para marcar as pecas e/ou servicos a serem ³±±
±±³          ³ excluidos                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_GAEXC()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GaExc()
****************

If aStruEXC[oLbox:nAt,1] == .f.
   aStruEXC[oLbox:nAt,1] := .t.
Else
   aStruEXC[oLbox:nAt,1] := .f.
Endif

oLbox:SetArray(aStruEXC)
oLbox:bLine := { || { if(aStruEXC[oLbox:nAt,01] == .f.,oNo,oTik),;
aStruEXC[oLbox:nAt,02],;
aStruEXC[oLbox:nAt,03],;
aStruEXC[oLbox:nAt,04],;
aStruEXC[oLbox:nAt,05],;
aStruEXC[oLbox:nAt,06],;
aStruEXC[oLbox:nAt,07],;
aStruEXC[oLbox:nAt,15],; 
aStruEXC[oLbox:nAt,08]}}

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_FALGEXC³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chama as funcoes que gravarao os dados referentes  exclusao³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_FLAGEXC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/
Function FS_FLAGEXC()
*****************
          
Local lNExecPec := .t. , lNExecSrv := .t. 
Local i := 0               
Private lMsHelpAuto := .t. , lMsErroAuto := .f., lMsFinalAuto := .f.
Private vet_ant := {} , tValSer := 0 , tValIte := 0 , nQtdExt := 0 
Private lVol := .t. 

Begin Transaction

   for i := 1 to len(aStruEXC)
      
      if aStruEXC[i,01]
  
        if !empty(aStruEXC[i,07])      //peca
        
            lVol := .t.
            vetor_p:={}
            nQtdExt := aStruEXC[i,15]   //quantidade
        
            If !FS_MUDREQ(aStruEXC[i,13],aStruEXC[i,16],{aStruEXC[i,6],aStruEXC[i,7],aStruEXC[i,15]},{})
               lRet := .f.
               DisarmTransaction()
               Break
            EndIf
            
            if lVol = .t.

               If !FS_VOLALM()  //troca os almoxarifados
                  lRet := .f.
                  DisarmTransaction()
                  Break
               EndIf
               If !FS_GRAVG6()
                  lRet := .f.
                  DisarmTransaction()
                  Break
               EndIf

            else

               lNExecPec := .f.

            endif                                           
          
         elseif !empty(aStruEXC[i,08]) //servico

            lVol := .t.   
            vetor_s:={} 
            If !FS_MUDREQ(aStruEXC[i,14],aStruEXC[i,16],{},{aStruEXC[i,8],aStruEXC[i,10]})
               lRet := .f.
               DisarmTransaction()
               Break
            EndIf

            if lVol = .t.

               If !FS_GRAVG6()
                  lRet := .f.
                  DisarmTransaction()
                  Break
               EndIf

            else

               lNExecSrv := .f.

            endif        
         
         endif

      endif

   next

   If !FS_GRAVG8()
      lRet := .f.
      DisarmTransaction()
      Break
   EndIf
           
End Transaction

If lMsErroAuto
   MostraErro()
EndIf
lMsHelpAuto := .f.


If !lNExecPec 
   help(" ",1,"OFIGM03001") 
EndIf

If !lNExecSrv 
   help(" ",1,"OFIGM03002") 
EndIf

return( !lMsErroAuto )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_GRAVG6 ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava o as as pecas e servicos como excluidos no VG6       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_GRAVG6()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAVG6()
********************

if !empty(aStruEXC[i,11])  //peca

   FG_SEEK("VG6","aStruEXC[i,02]+aStruEXC[i,03]+aStruEXC[i,11]+aStruEXC[i,04]+aStruEXC[i,05]",3,.f.)  //marca+os+pecint+ano+rr

else

   FG_SEEK("VG6","aStruEXC[i,02]+aStruEXC[i,03]+aStruEXC[i,12]+aStruEXC[i,04]+aStruEXC[i,05]",4,.f.)  //marca+os+serint+ano+rr

endif

dbselectArea("VG6")
RecLock("VG6",.f.)
VG6->VG6_EXCLUI := "S"    
MsUnlock()

if !empty(VG6->VG6_RRCANT)

   if ascan(vet_ant,VG6->VG6_ANOANT+VG6->VG6_RRCANT) = 0

      aadd(vet_ant,VG6->VG6_ANOANT+VG6->VG6_RRCANT+VG6->VG6_NUMOSV+VG6->VG6_CODMAR)

   endif

endif   
 
while .T.

   if !empty(VG6->VG6_RRCANT)
   
      if !empty(aStruEXC[i,11]) //peca
         FG_SEEK("VG6","aStruEXC[i,02]+aStruEXC[i,03]+aStruEXC[i,11]+VG6->VG6_ANOANT+VG6->VG6_RRCANT",3,.f.)  //marca+os+pecint+ano+rr
      else
         FG_SEEK("VG6","aStruEXC[i,02]+aStruEXC[i,03]+aStruEXC[i,12]+VG6->VG6_ANOANT+VG6->VG6_RRCANT",4,.f.)  //marca+os+serint+ano+rr
      endif
   
      dbselectArea("VG6")
      RecLock("VG6",.f.)
      VG6->VG6_EXCLUI := "S"    
      VG6->VG6_USUEXC := __cUserID
      VG6->VG6_DATEXC := dDataBase
      VG6->VG6_HOREXC := val(subs(time(),1,2)+subs(time(),4,2))
      MsUnlock()
                              
      if !empty(VG6->VG6_RRCANT)                                   

         if ascan(vet_ant,VG6->VG6_ANOANT+VG6->VG6_RRCANT) = 0

            aadd(vet_ant,VG6->VG6_ANOANT+VG6->VG6_RRCANT+VG6->VG6_NUMOSV+VG6->VG6_CODMAR)

         endif

      endif  
                   
   else   
   
      exit
   
   endif

enddo
   
return .t.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_GRAVG8 ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as RR'S como excluidas caso todos os servicos e pecas³±±
±±³          ³ tenham sido excluidas                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_GRAVG8()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAVG8()
****************
                        
Local lGraVG8 := .t.          
Local y := 0

dbselectArea("VG8")

if len(aStruEXC) = cCont_t

   RecLock("VG8",.f.)
   VG8->VG8_EXCLUI := "S"    
   MsUnlock()
      
   if len(vet_ant) > 0

      for y = 1 to len(vet_ant)
         
         lGraVG8 := .t.

         dbselectArea("VG6")
         dbsetorder(5)
         
         FG_SEEK("VG6","subs(vet_ant[y],20,3)+subs(vet_ant[y],12,8)+subs(vet_ant[y],1,4)+subs(vet_ant[y],5,7)",5,.F.)
         
         do while !eof() .and. XFILIAL("VG6")+subs(vet_ant[y],20,3)+subs(vet_ant[y],12,8)+subs(vet_ant[y],1,4)+subs(vet_ant[y],5,7) = VG6->VG6_FILIAL+VG6->VG6_CODMAR+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC
         
            if empty(VG6->VG6_EXCLUI)

               lGraVG8:= .f.

               exit

            endif

            dbskip() 

         enddo
                            
         if lGraVG8 = .t. 

            dbselectArea("VG8")
            FG_SEEK("VG8","subs(vet_ant[y],20,3)+subs(vet_ant[y],12,8)+subs(vet_ant[y],1,4)+subs(vet_ant[y],5,7)",1,.F.)
      
            RecLock("VG8",.f.)
            VG8->VG8_EXCLUI := "S"
            MsUnlock()

         endif
         
      next
      
   endif
   
else

  dbselectArea("VG8")
  RecLock("VG8",.f.)
  VG8->VG8_VALITE := if(tValIte < VG8->VG8_VALITE,VG8->VG8_VALITE - tValIte,0)
  VG8->VG8_VALSER := if(tValSer < VG8->VG8_VALSER,VG8->VG8_VALSER - tValSer,0)
  MsUnlock()

endif                         

return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GM030V    ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza os dados do VG6/VG8 - modelo 3                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM030V(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GM030V(cAlias,nReg,nOpc)
*********************************

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor := 0 , _ni := 0 , nUsado := 0

Private aRotina := { { "" ,"", 0 , 1},;
                     { "" ,"", 0 , 2},; //VISUALIZAR
                     { "" ,"", 0 , 4},; //ALTERAR
                     { "","",  0,  4}}

Private aCols := {} , aHeader := {} , aCpoEnchoice:={}
Private cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VG8",.t.)         // .t. para carregar campos virtuais

aCpoEnchoice:={}

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VG8")

While !Eof().and.(x3_arquivo=="VG8")

   if X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VG8_TRANSM/VG8_EXCLUI/VG8_CODSER/VG8_SERINT/VG8_EXPGAR])
      AADD(aCpoEnchoice,x3_campo)
   Endif
   
   &("M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)

   dbSkip()

End

If !(Inclui)

   DbSelectArea("VG8")

   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next

Endif

if nOpc == 3   //ALTERAR
   nOpcE := 4
   nOpcG := 4
elseif nOpc == 2  //VISUALIZAR
   nOpcE := 2
   nOpcG := 2
else
   nOpcE := 5      //EXCLUIR
   nOpcG := 5
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0

dbSelectArea("SX3")
dbSeek("VG6")

aHeader:={}

While !Eof().And.(x3_arquivo=="VG6")

   If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(Alltrim(x3_campo) $ [VG6_TRANSM/VG6_EXCLUI/VG6_NOSNUP/VG6_NOSNUS])

      nUsado:=nUsado+1

      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )

      &( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)

   Endif

   dbSkip()

End

If Inclui

   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.

   For _ni:=1 to nUsado
       aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
   Next

Else

   aCols:={}
   dbSelectArea("VG6")
   dbSetOrder(5)
   dbSeek(xFilial()+M->VG8_CODMAR+M->VG8_NUMOSV+M->VG8_ANORRC+M->VG8_NUMRRC)

   While !eof() .and. M->VG8_CODMAR+M->VG8_NUMOSV+M->VG8_ANORRC+M->VG8_NUMRRC == VG6->VG6_CODMAR+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC ;
         .And. VG6->VG6_FILIAL == xFilial("VG6")  

       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado
           aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
       Next

       aCols[Len(aCols),nUsado+1]:=.F.

       dbSkip()

   End

   dbsetorder(1)

Endif

If Len(aCols)>0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTitulo       :=STR0001    //"Exclui Garantia"
   cAliasEnchoice:="VG8"
   cAliasGetD    :="VG6"
   cLinOk        :="FG_OBRIGAT()"
   cTudOk        :="AllwaysTrue()"
//   cTudOk        :="FS_TudOk()"   //"FS_OrdGaVw('M->VG6_ORDITE','VG8->VG8_NUMOSV'),FS_GarOk()"
   cFieldOk      :="FG_MEMVAR()"

   Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

Endif

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_VOLALM ³ Autor ³Renata                 ³ Data ³ 01/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retira a peca do almoxarifado garantia e coloca na oficina ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_VOLALM()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VOLALM(cAntTem)

Local aItensOld:={}  //GARANTIA
Local aItensNew:={}  //PARAMETRO DEFINE O TIPO DE TEMPO

FG_SEEK("SB1","aStruEXC[i,6]+aStruEXC[i,7]",7,.F.)  //GRUITE+CODITE

aadd(aItensOld,{"D3_TM",GetMv("MV_SAIDA"),NIL})
aadd(aItensOld,{"D3_COD",SB1->B1_COD,NIL})
aadd(aItensOld,{"D3_UM",SB1->B1_UM,NIL})
aadd(aItensOld,{"D3_QUANT",nQtdExt,NIL})
aadd(aItensOld,{"D3_LOCAL",Posicione("VOI",1,xFilial("VOI")+cAntTem,"VOI_CODALM"),NIL})
aadd(aItensOld,{"D3_EMISSAO",dDataBase,NIL})
       
lMsHelpAuto := .t.
lMsErroAuto := .f.
      
MSExecAuto({|x| MATA240(x)},aItensOld)       	    
     
If lMsErroAuto            

   DisarmTransaction()
   Break

EndIf   

aadd(aItensNew,{"D3_TM",GetMv("MV_ENTRADA"),NIL})
aadd(aItensNew,{"D3_COD",SB1->B1_COD,NIL})
aadd(aItensNew,{"D3_UM",SB1->B1_UM,NIL})
aadd(aItensNew,{"D3_QUANT",nQtdExt,NIL})
aadd(aItensNew,{"D3_LOCAL",Posicione("VOI",1,xFilial("VOI")+MV_PAR03,"VOI_CODALM"),NIL})
aadd(aItensNew,{"D3_EMISSAO",dDataBase,NIL})

lMsHelpAuto := .t.
lMsErroAuto := .f.

MSExecAuto({|x| MATA240(x)},aItensNew)       	    

If lMsErroAuto            

   DisarmTransaction()
   Break

EndIf   

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FS_MUDREQ ³Autor  ³Emilton             ³ Data ³  14/11/00   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Desc.     ³Altera Requisicao de pecas e Srv                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_MUDREQ(nValor,cAntTem,aPecas,aServicos)
**********************************************************

Local lRet    := .t.
Local ix1     := 0
Local ix2     := 0
Local cCliAnt := ""
Local cLojAnt := ""
Local aVetVFB := {}

/*

aPecas[1] == Grupo do Item
aPecas[2] == Codigo do Item
aPecas[3] == Nosso Numero

aServicos[1] == Codigo do Servico
aServicos[2] == Nosso Numero da Requisicao de Servicos

*/

//If FG_LIMCRE(MV_PAR05,MV_PAR06) < nValor
If !MaAvalCred(MV_PAR05,MV_PAR06,nValor ,1,.T.) 
   help(" ",1,"M030LIMCRE")
   return .f.
   lRet := .f.
EndIf

FG_SEEK("VOI","MV_PAR03",1,.F.)

If Len(aPecas) > 0

    If !FG_GRUTEM(MV_PAR03,aPecas[1])

       lRet := .f.
       Return .f.

    EndIF

    DbSelectArea("VO3")
    DbSetOrder(2)
    DbSeek(xFilial("VO3")+aPecas[1]+aPecas[2]+aPecas[3])

    If !RecLock("VO3",.F.)

       Help("  ",1,"REGNLOCK")
       lRet := .f.
       && DisarmTransaction()
       && Break

    EndIf

    cCliAnt         := VO3->VO3_FATPAR
    cLojAnt         := VO3->VO3_LOJA
    VO3->VO3_FILIAL := xFilial("VO3")
    VO3->VO3_TIPTEM := MV_PAR03
    VO3->VO3_FATPAR := MV_PAR05
    VO3->VO3_LOJA   := MV_PAR06
    If VOI->VOI_SITTPO == "3"
       VO3->VO3_DEPINT := MV_PAR04
    EndIf
    VO3->VO3_FORMUL := VOI->VOI_VALPEC
    VO3->VO3_VALPEC := FG_VALPEC(MV_PAR03,"VOI->VOI_VALPEC",aPecas[1],aPecas[2],,.f.,.t.)
    MsUnLock()

    DbSelectArea("VFB")
    DbSetOrder(3)
    DbSeek(xFilial("VFB")+cCliAnt+cLojAnt+VO1->VO1_CHAINT+VO1->VO1_NUMOSV+"P")

    While !Eof() .And. VFB->VFB_FILIAL == xFilial("VFB") ;
                 .And. VFB->VFB_CODCLI+VFB->VFB_LOJA+VFB->VFB_CHAINT+VFB->VFB_NUMOSV+VFB->VFB_SERPEC == cCliAnt+cLojAnt+VO1->VO1_CHAINT+VO1->VO1_NUMOSV+"P"

       If VFB->VFB_TIPTEM == cAntTem
          aAdd(aVetVFB,recno())
       EndIf
       DbSkip()

    EndDo

    For ix2 := 1 to len(aVetVFB)

        dbgoto(aVetVFB[ix2])
        If !RecLock("VFB",.F.)
           Help("  ",1,"REGNLOCK")
           lRet := .f.
           &&DisarmTransaction()
           &&Break
        EndIf

        VFB->VFB_CODCLI := VO3->VO3_FATPAR
        VFB->VFB_LOJA   := VO3->VO3_LOJA
        VFB->VFB_TIPTEM := VO3->VO3_TIPTEM
        MsUnlock()

    Next

EndIf

If Len(aServicos) > 0

   DbSelectArea("VO4")
   DbSetOrder(4)

   DbSeek(xFilial("VO4")+aServicos[1]+aServicos[2]+cAntTem)

   while aServicos[1]+aServicos[2]+cAntTem == VO4->VO4_CODSER+VO4->VO4_NOSNUM+VO4->VO4_TIPTEM .and. xFilial("VO4") == VO4->VO4_FILIAL .and. !eof()

      If !RecLock("VO4",.F.)
         Help("  ",1,"REGNLOCK")
         lRet := .f.
         DisarmTransaction()
         Break
      EndIf

      VO4->VO4_FILIAL := xFilial("VO4")
      VO4->VO4_TIPTEM := MV_PAR03
      VO4->VO4_FATPAR := MV_PAR05
      VO4->VO4_LOJA   := MV_PAR06
      If VOI->VOI_SITTPO == "3"
         VO4->VO4_DEPINT := MV_PAR04
      EndIf
      MsUnLock()

      dbSkip()

   EndDo

   DbSelectArea("VFB")
   DbSetOrder(3)
   DbSeek(xFilial("VFB")+aServicos[ix1,5]+aServicos[ix1,6]+VO1->VO1_CHAINT+VO1->VO1_NUMOSV+"S")

   While !Eof() .And. VFB->VFB_FILIAL == xFilial("VFB") ;
                .And. VFB->VFB_CODCLI+VFB->VFB_LOJA+VFB->VFB_CHAINT+VFB->VFB_NUMOSV+VFB->VFB_SERPEC == aServicos[ix1,5]+aServicos[ix1,6]+VO1->VO1_CHAINT+VO1->VO1_NUMOSV+"S"

      If VFB->VFB_TIPTEM == cAntTem

         If !RecLock("VFB",.F.)
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break
         EndIf

         VFB->VFB_CODCLI := MV_PAR05
         VFB->VFB_LOJA   := MV_PAR06
         VFB->VFB_TIPTEM := MV_PAR03
         MsUnlock()

      EndIf

      DbSkip()

   EndDo

EndIf

cCont_t := cCont_t + 1
tValIte := tValIte + aStruEXC[i,13]  //VL.GARANTIA P/ ABATER NO VG8

Return(lRet)

Function FS_TPO()
*****************

If FG_SEEK("VOO","MV_PAR01+MV_PAR05",1,.f.)
   help(" ",1,"M030DISFEC")
   Return .f.
EndIf

Return .t.

Static Function MenuDef()
Local aRotina := {{ STR0003 ,"axPesqui", 0 , 1},; 	//Pesquisar
              	{ STR0004 ,"GM030V"    , 0 , 2},;   //Visualizar
              	{ STR0005 ,"GM030E"    , 0 , 4}}    //Excluir
Return aRotina
