#INCLUDE "Ofigm090.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIGM090 ³ Autor ³  Renata               ³ Data ³ 23/12/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Libera para retransmissao no caso de reconsideracao        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#include "protheus.ch"
FUNCTION OFIGM090

PRIVATE cIndVO6, cChave, cCond
PRIVATE aRotina := MenuDef()
private oNroRrI, oNroRrF, oAnoRr,oCodMar
private cNroRrI, cNroRrF, cAnoRr,cCodMar, cDesMar
private aCampos := {}

cCodMar := OemtoAnsi(STR0001)    // //"SC "

FS_MENUM090()

if len(aRotina) == 0
   Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0002)  //garantia scania //"Libera RR's para Retransmissao"
PRIVATE cIndex 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("VG8")
cIndex  := CriaTrab(nil,.f.)
cChave  := IndexKey()
cCond   := 'VG8_TRANSM=="S".and.VG8_NUMRRC="' +cNroRrI+'".and.VG8_ANORRC="'+cAnoRr+'".and.empty(VG8_RRCNEW).and.VG8_EXCLUI=" "'
IndRegua("VG8",cIndex,cChave,,cCond,STR0003) //"Aguarde, filtrando registros..."

DbSelectArea("VG8")
nIndex := RetIndex("VG8")
#IFNDEF TOP
   dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)

mBrowse( 6, 1,22,75,"VG8",,,,"VG8_NUMRRC = cNroRri .and. VG8_ANORRC = cAnoRr .and. VG8_CODMAR = cCodMar .and. VG8_EXCLUI=space(1) .and. empty(VG8_RRCNEW) .and. VG8_TRANSM = 'S'")

dbSelectArea("VG8")
Set Filter to
RetIndex()
DbsetOrder(1)
#IFNDEF TOP
   If File(cIndex+OrdBagExt())
      fErase(cIndex+OrdBagExt())
   Endif
#ENDIF

return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_MENUM090Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta as opcoes do menu do programa                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_MENUM090(cAlias,nReg,nOpc)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MENUM090(cAlias, nReg, nOpc)
**************************************

aAltSx1  := { {"01",STR(year(date()),4),"","","","","","","","","","","","","","",""} }         
FG_AltSx1("OFGSC1","A",aAltSx1)
if !Pergunte("OFGSC1",.t.) 
   return
endif

cAnoRR  := MV_PAR01
cNroRri := MV_PAR02

return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GM090L    ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o listbox para marcar os itens e servicos para retrans³±±
±±³          ³missao                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM090L(CALIS,NREG,NOPC)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GM090L(cAlias,nReg,nOpc)

if VG8->VG8_EXCLUI # space(1) .or. !empty(VG8->VG8_RRCNEW) .or. VG8->VG8_TRANSM = 'N' .OR. VG8->VG8_NUMRRC # cNroRri
   help(" ",1,"OFIGM09001") 
   return
endif
 
//RetIndex()

FG_SEEK("VG8","cCODMAR+cANORR+cNRORRI",2,.f.)

DbSelectArea("VG6") 
dbsetorder(5)
FG_SEEK("VG6","VG8->VG8_CODMAR+VG8->VG8_NUMOSV+VG8->VG8_ANORRC+VG8->VG8_NUMRRC",5,.f.)

aStruLIB := {}

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

while !eof() .and. VG8->VG8_FILIAL+VG8->VG8_CODMAR+VG8->VG8_NUMOSV+VG8->VG8_ANORRC+VG8->VG8_NUMRRC==XFILIAL("VG6")+VG6->VG6_CODMAR+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC

   if VG6->VG6_EXCLUI = space(1)  .and. VG6->VG6_TRANSM = "S"
      aadd(aStruLIB,{ .f.,VG6_CODMAR,VG6_NUMOSV,VG6_ANORRC,VG6_NUMRRC,VG6_GRUITE,VG6_CODITE,VG6_CODSER,VG6_NOSNUP,VG6_NOSNUS,VG6_PECINT,VG6_SERINT,VG6_VALITE,VG6_VALSER,VG6_QTDITE})
   endif

   dbskip()   

Enddo

If Len(aStruLIB) == 0
   aadd(aStruLIB,{ .f.,space(3),space(8),space(4),space(7),space(3),space(27),space(15),space(8),space(8),space(15),space(6),0,0,0})
Endif

PRIVATE oLbox
PRIVATE oOk    := LoadBitmap( GetResources(), "LBOK" )
PRIVATE oNo    := LoadBitmap( GetResources(), "LBNO" )
PRIVATE oTik   := LoadBitmap( GetResources(), "LBTIK" )

While .t.

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0007) FROM  39,20 TO 54,84 OF oMainWnd //"Pecas/Servicos da RR"
                                         //PECAS/SERVICOS DA RR
	@ 12,.1 LISTBOX oLbox FIELDS HEADER   OemToAnsi(""),; // Indicador de Relacionamento
	OemToAnsi(STR0008),;       // //"Marca"
	OemtoAnsi(STR0009),;       // //"Ord.Serv"
	OemToAnsi(STR0010),;       // //"Ano"
	OemtoAnsi(STR0011),;       // //"Num.RR"
	OemtoAnsi(STR0012),;       //Grupo"	 //"Grupo"
	OemToAnsi(STR0013),;       //      //"Cod.Item"
    OemToAnsi(STR0014),;       // //"Qtdade"
	OemtoAnsi(STR0015);       // //"Cod.Serv"
	COLSIZES 10,20,30,20,30,20,40,20,40;    
	SIZE 254,101 OF Odlg PIXEL ON DBLCLICK (nPos:=oLbox:nAt,FS_GALIB(),oLbox:Refresh(),oLbox:nAt:=nPos)

	oLbox:SetArray(aStruLIB)
	oLbox:bLine := { || { if(aStruLIB[oLbox:nAt,01] == .f.,oNo,oTik),;
	aStruLIB[oLbox:nAt,02],;
	aStruLIB[oLbox:nAt,03],;
	aStruLIB[oLbox:nAt,04],;
	aStruLIB[oLbox:nAt,05],;
    aStruLIB[oLbox:nAt,06],;
	aStruLIB[oLbox:nAt,07],;
	aStruLIB[oLbox:nAt,15],;
    aStruLIB[oLbox:nAt,08]}}
	
	nOpca := 0

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{||nOpca := 1,oDlg:End()},{||nOpca := 2,oDlg:End()})

	If nOpca == 1
       FS_FLAGLIB() 
	   exit
    Else
       aStruLIB := {}
       exit
	Endif

Enddo

//dbselectarea("VG8")
//cIndex  := CriaTrab(nil,.f.)
//cChave  := IndexKey()
//cCond   := 'VG8_TRANSM=="S".and.VG8_NUMRRC="' +cNroRrI+'".and.VG8_ANORRC="'+cAnoRr+'".and.empty(VG8_RRCNEW).and.VG8_EXCLUI=" "'
//IndRegua("VG8",cIndex,cChave,,cCond,"Aguarde, filtrando registros...")
  
DbSelectArea("VG8")
nIndex := RetIndex("VG8")
#IFNDEF TOP
   dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)

return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_GALIB  ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o listbox para marcar os itens e servicos para retrans³±±
±±³          ³missao                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_GALIB()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GALIB()
****************

If aStruLIB[oLbox:nAt,1] == .f.
   aStruLIB[oLbox:nAt,1] := .t.
Else
   aStruLIB[oLbox:nAt,1] := .f.
Endif

oLbox:SetArray(aStruLIB)
oLbox:bLine := { || { if(aStruLIB[oLbox:nAt,01] == .f.,oNo,oTik),;
aStruLIB[oLbox:nAt,02],;
aStruLIB[oLbox:nAt,03],;
aStruLIB[oLbox:nAt,04],;
aStruLIB[oLbox:nAt,05],;
aStruLIB[oLbox:nAt,06],;
aStruLIB[oLbox:nAt,07],;
aStruLIB[oLbox:nAt,15],; 
aStruLIB[oLbox:nAt,08]}}

Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_FLAGLIB³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Muda o flag do VG6_TRANSM/VG8_TRANSM para "N"              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_FLAGLIB()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ integracao                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FS_FLAGLIB()
*****************
Local i := 0

lVG8 := .f.

Begin Transaction 

for i = 1 to len(aStruLIB)
      
   cFlag := aStruLIB[i,01] 

   if cFlag == .t.
       
      lVg8 := .T.
           
      if !empty(aStruLIB[i,07])
         dbgotop()
         dbsetorder(3)
         lProcura := dbseek(xFilial("VG6")+aStruLIB[i,02]+aStruLIB[i,03]+aStruLIB[i,11]+aStruLIB[i,04]+aStruLIB[i,05]) //marc+OS+cod.int.peca+ano+rr
      else
         dbgotop()
         dbsetorder(4)
         lProcura := dbseek(xFilial("VG6")+aStruLIB[i,02]+aStruLIB[i,03]+aStruLIB[i,12]+aStruLIB[i,04]+aStruLIB[i,05]) //marc+OS+cod.int.serv+ano+rr 
      endif

      RecLock("VG6",.F.)
      VG6->VG6_TRANSM := "N"
      MsUnlock()


   endif

next


if lVG8 = .T.
                           
   for i = 1 to len(aStruLIB)
      dbselectArea("VG8")
//      RetIndex()
      dbgotop()
      dbsetorder(2)
      lProcura := dbseek(xFilial("VG8")+aStruLIB[i,02]+aStruLIB[i,04]+aStruLIB[i,05]) //marc+ano+rr 
      RecLock("VG8",.F.)
      VG8->VG8_TRANSM := "N"
      MsUnlock()
   next

endif
                  
End Transaction                  
                  
dbSelectArea("VG8")

return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³VLDM090   ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se as rr's das pecas ou servicos marcadas para    ³±±
±±³          ³ retransmissao podem ser liberadas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ VLDM090(ARG)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 0 - RR INICIAL / 1 - MARCA / 2 - RR FINAL / 3- ANO DA RR   ³±±
±±³          ³ 4 - TIP SERV                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION FS_VLDM090(Arg)
*******************

if Arg == 0

   FG_STRZERO("cNroRrI",7)

   if !FG_SEEK("VG8","cCodMar+cAnoRr+cNroRrI",2,.F.) .or. empty(cNroRrI)
       help(" ",1,"SITRR1GM90") 
      return .f.
   elseif VG8->VG8_TRANSM = "N" 
      help(" ",1,"SITRR4GM90")  
      return .f.
   elseif VG8->VG8_EXCLUI = "S" 
      help(" ",1,"SITRR3GM90")  
      return .f.
   elseif !empty(VG8->VG8_RRCNEW) 
      help(" ",1,"SITRR2GM90") 
      return .f.

   endif

   return .t.

elseif Arg == 1

   if Empty(cCodMar)
      Return .f.
   Else
      dbselectarea("VE1")
      if !FG_SEEK("VE1","cCodMar",1,.F.)
         help(" ",1,"CMARCAGM90") 
         Return .f.
      else
         cDesMar := subs(VE1->VE1_DESMAR,1,6)
	 return .t.
      endif
   endif

elseif Arg == 2

   FG_STRZERO("cNroRrF",7)

   if !FG_SEEK("VG8","cCodMar+cAnoRr+cNroRrF",2,.F.)
      help(" ",1,"SITRR5GM90") 
       Return .f.
   endif

   return .t.

elseif Arg == 3

   if !FG_SEEK("VG8","cCodMar+cAnoRr",2,.F.) 
       help(" ",1,"SANORRGM90") 
       Return .f.
   endif

   return .t.

endif
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GM090V    ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza os dados do VG6/VG8 - modelo 3                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM090V(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GM090V(cAlias,nReg,nOpc)
***************************

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor  := 0
Local _ni	   := 0	
PRIVATE aRotina := { { "" ,"", 0 , 1},;
                     { "" ,"", 0 , 2},;    //VIZUALIZAR
                     { "" ,"", 0 , 4},;   //LIBERAR
                     { "","",  0,  4}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VG8",.t.)         // .t. para carregar campos virtuais

aCpoEnchoice:={}

DbSelectArea("SX3")
dbgotop()
DbSetOrder(1)
DbSeek("VG802")

While !Eof().and.(x3_arquivo=="VG8")
   if X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(x3_campo $ [VG8_TRANSM/VG8_EXCLUI/VG8_CODSER/VG8_SERINT/VG8_EXPGAR])
      AADD(aCpoEnchoice,x3_campo)
   Endif
   wVar := "M->"+x3_campo
   &wVar:= CriaVar(x3_campo)
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
elseif nOpc == 2  //VIZUALIZAR
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
dbgotop()
dbSeek("VG602")

aHeader:={}

While !Eof().And.(x3_arquivo=="VG6")
   If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(x3_campo $ [VG6_TRANSM/VG6_EXCLUI/VG6_NOSNUP/VG6_NOSNUS])
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
      wVar := "M->"+x3_campo
      &wVar := CriaVar(x3_campo)
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
   dbgotop()
   dbSetOrder(5)
   dbSeek(xFilial()+M->VG8_CODMAR+M->VG8_NUMOSV+M->VG8_ANORRC+M->VG8_NUMRRC)
   While !eof() .and. M->VG8_FILIAL+M->VG8_CODMAR+M->VG8_NUMOSV+M->VG8_ANORRC+M->VG8_NUMRRC == XFILIAL("VG6")+VG6->VG6_CODMAR+VG6->VG6_NUMOSV+VG6->VG6_ANORRC+VG6->VG6_NUMRRC
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
//   cTudOk        :="FS_TudOk()"   //"FS_OrdGaVw('M->VG6_ORDITE','VG8->VG8_NUMOSV'),FS_GarOk()"
   cTudOk        :="AllwaysTrue()"   //"FS_OrdGaVw('M->VG6_ORDITE','VG8->VG8_NUMOSV'),FS_GarOk()"
   cFieldOk      :="FG_MEMVAR()"


   _lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executar processamento                                       ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If _lRet .And. nOpc # 2

      dbselectArea("VG8")
      dbgotop()
      lProcura := dbseek(xFilial("VG8")+M->VG8_CODMAR+M->VG8_NUMOSV)

   Endif


Endif

Return

Static Function MenuDef()
Local aRotina := {{ STR0004 ,"axPesqui", 0, 1},;  //Pesquisar
               { STR0005 ,"GM090V"    , 0 , 2},;  //Visualizar
               { STR0006 ,"GM090L"    , 0 , 4}}   //Liberar
Return aRotina
