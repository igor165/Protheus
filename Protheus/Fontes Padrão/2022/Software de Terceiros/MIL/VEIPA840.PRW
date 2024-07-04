#include "Veipa840.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VEIPA840 ³ Autor ³  Andre                ³ Data ³ 18/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Antecipacao / Lances                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIPA840
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0001) //"Antecipacao / Lances"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao axCadastro                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTudoOK := "ABATELAN()"
cDel    := "VALIDEXC()"
axCadastro("VP4", cCadastro,cDel,cTudoOK)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ABATELAN ³ Autor ³  Andre                ³ Data ³ 18/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abatimento das parcelas em relacao ao lance                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Func„o Interna exclusiva para este modulo                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ABATELAN()
Local nRecno
Local dDataLan
dbSelectArea("VP4")
nRecno   := Recno()
dDataLan := M->VP4_DATLAN
wSeek := VP4->VP4_CODGRU+VP4->VP4_NUMCOT+VP4->VP4_CODCLI+VP4->VP4_LOJA
if DbSeek(xFilial("VP4")+wSeek)
   do while !EOF() .and. VP4->VP4_CODGRU+VP4->VP4_NUMCOT+VP4->VP4_CODCLI+VP4->VP4_LOJA == wSeek
      if VP4->VP4_DATLAN == dDataLan .and. VP4->(Recno()) <> nRecno
         MsgStop(OemToAnsi(STR0011),OemToAnsi(STR0003))
         Return .f.
      Endif   
		If VP4->VP4_ANTLAN == "1" .and. M->VP4_ANTLAN == "1" .and. VP4->(Recno()) <> nRecno
			MsgStop(OemToAnsi(STR0012),OemToAnsi(STR0003)) 
			Return .F.
		Endif
      dbSkip()
   Enddo
Endif
dbGoto(nRecno)
DbSelectArea("VP1")
if DbSeek(xFilial("VP1")+M->VP4_CODGRU+M->VP4_NUMCOT+M->VP4_CODCLI+M->VP4_LOJA)
   RecLock("VP1",.f.)
   VP1->VP1_FILIAL := xFilial("VP1")
   VP1->VP1_PERLAN := VP1->VP1_PERLAN + M->VP4_PERLAN
   VP1->VP1_PERPAG := VP1->VP1_PERPAG + M->VP4_PERLAN
   MsUnlock()
   nQtdPar := VP1_QTDPAR
Endif
nValLan := M->VP4_VALLAN
nValPar := 0
if !FG_GERPAR(M->VP4_CODGRU+M->VP4_NUMCOT+M->VP4_CODCLI+M->VP4_LOJA,2,.f.)
   Return .f.
Endif
DbSelectArea("VP2")
DbGotop()
if DbSeek(xFilial("VP2")+M->VP4_CODGRU+M->VP4_NUMCOT+M->VP4_CODCLI+M->VP4_LOJA)
   Do While !EOF()
      if VP2_CODGRU+VP2_NUMCOT+VP2_CODCLI+VP2_LOJA # M->VP4_CODGRU+M->VP4_NUMCOT+M->VP4_CODCLI+M->VP4_LOJA
         Exit
      Endif
      if Empty(VP2_DATPAG)
          RecLock("VP2",.f.)
          VP2_PARANT := VP2_VALPAR
          VP2_PGTANT := VP2_PARPAG
          VP2_SALANT := VP2_PERSAL
          VP2_VALANT := VP2_VALLAN
          VP2_LANANT := VP2_PERLAN
          VP2_PAGANT := VP2_PERPAG
          MsUnlock()
      Endif
      DbSkip()
   Enddo
Endif
DbGotop()
if M->VP4_PARINI == "1"

   nNroPar := FG_VALPAR(M->VP4_CODGRU+M->VP4_NUMCOT+M->VP4_CODCLI+M->VP4_LOJA,VP4_VALLAN)

   if !nNroPar > 0
      MsgInfo(STR0002,STR0003) //"Lance nao suportado pelas parcelas..."###"Atencao!"
      Return .f.
   Endif

   DbGotop()
   if DbSeek(xFilial("VP2")+M->VP4_CODGRU+M->VP4_NUMCOT+M->VP4_CODCLI+M->VP4_LOJA)
      Do While M->VP4_CODGRU+M->VP4_NUMCOT+M->VP4_CODCLI+M->VP4_LOJA = VP2_CODGRU+VP2_NUMCOT+VP2_CODCLI+VP2_LOJA
         if Empty(VP2_DATPAG)
            if VP2_VALPAR >= (nValLan/nNroPar)
               DbSelectArea("VP2")
               RecLock("VP2",.f.)
               VP2->VP2_FILIAL := xFilial("VP2")
               VP2->VP2_VALPAR := VP2_VALPAR - (nValLan / nNroPar)
               VP2->VP2_VALLAN := VP2_VALLAN + (nValLan / nNroPar)
               VP2->VP2_PERLAN := VP2_PERLAN + (M->VP4_PERLAN / nNroPar)
               VP2->VP2_PARPAG := VP2_PARPAG + (nValLan / nNroPar)
               VP2->VP2_TOTPAG := VP2_TOTPAG + (nValLan / nNroPar)
               VP2->VP2_PERPAG := VP2_PERPAG + (M->VP4_PERLAN / nNroPar)
               VP2->VP2_PERSAL := VP2->VP2_PERSAL - (M->VP4_PERLAN / nNroPar)
               MsUnlock()
            Endif
         Endif
         DbSkip()
      Enddo
   Else
      MsgStop(STR0004,STR0003) //"As parcelas desta cota n„o foram geradas!"###"Atencao!"
      Return .f.
   Endif

   FG_GERPAR(M->VP4_CODGRU+M->VP4_NUMCOT+M->VP4_CODCLI+M->VP4_LOJA,2,.f.)

Else
   DbGotop()
   if DbSeek(xFilial("VP2")+M->VP4_CODGRU+M->VP4_NUMCOT+M->VP4_CODCLI+M->VP4_LOJA+strzero(nQtdPar,3))
      nNroPar := 0
      nValLa2 := nValLan
      Do While .t.
         if nValLa2 == 0 .or. !VP2_VALPAR > 0
            Exit
         Endif
         if VP2_VALPAR > nValLa2
            nNroPar++
            nValLa2 := 0
         Else
            nNroPar++
            nValLa2 := nValLa2 - VP2_VALPAR
         Endif
         DbSkip(-1)
      Enddo
      nValLa2 := nValLan
      DbGotop()
      if DbSeek(xFilial("VP2")+M->VP4_CODGRU+M->VP4_NUMCOT+M->VP4_CODCLI+M->VP4_LOJA+strzero(nQtdPar,3))
         Do While .t.
            if nValLa2 == 0
               Exit
            Endif
            if VP2_VALPAR > nValLa2
               nValLan := nValLa2
            Else
               nValLan := VP2_VALPAR
            Endif

            nValLa2 := nValLa2 - nValLan

            RecLock("VP2",.f.)
            VP2->VP2_FILIAL := xFilial("VP2")
            VP2_PARPAG := VP2_PARPAG + nValLan
            VP2_VALPAR := VP2_VALPAR - nValLan
            VP2_VALLAN := VP2_VALLAN + nValLan
            VP2_PERLAN := VP2_PERLAN + ((nValLan / VP2_VALBEM)* 100)
            VP2_PERPAG := VP2_PERPAG + ((nValLan / VP2_VALBEM)* 100)
            VP2_PERSAL := VP2->VP2_PERSAL - ((nValLan / VP2_VALBEM)* 100)
            VP2_TOTPAG := VP2_VALLAN

            if VP2_VALPAR == 0
               VP2_VALDES := 0
            Endif

            MsUnlock()

            DbSkip(-1)
         Enddo

         if !FG_GERPAR(VP2_CODGRU+VP2_NUMCOT+VP2_CODCLI+VP2_LOJA,2,.f.)
            MsgInfo(STR0005,STR0003) //"As parcelas nao foram atualizadas corretamente"###"Atencao!"
         Endif
      Else
         Return .f.
      Endif
   Else
      Return .f.
   Endif
Endif
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VALIDEXC ³ Autor ³  Andre                ³ Data ³ 18/06/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida Exclusao do Lance/Antecipacao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Func„o Interna exclusiva para este modulo                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VALIDEXC()
Local nRecno
Local dDataLan
dbSelectArea("VP4")
nRecno   := Recno()
dDataLan := VP4->VP4_DATLAN
wSeek := VP4->VP4_CODGRU+VP4->VP4_NUMCOT+VP4->VP4_CODCLI+VP4->VP4_LOJA
if DbSeek(xFilial("VP4")+wSeek)
   Do while !EOF() .and. VP4->VP4_CODGRU+VP4->VP4_NUMCOT+VP4->VP4_CODCLI+VP4->VP4_LOJA == wSeek
      if VP4->VP4_DATLAN > dDataLan
         MsgStop(STR0006,STR0003)   // Foi encontrado um lance posterior a este,Somente o ultimo lance deste cliente pode ser excluido
         Return .f.
      Endif   
      dbSkip()
   Enddo
Else
   msgStop(STR0007,STR0003)   // Arquivo de Indice com problema, Arquivo (VP4)
   Return .f.
Endif
dbGoto(nRecno)
if VP4->VP4_PARINI == "1"
   dbSelectArea("VP2")
   dbGotop()
   if DbSeek(xFilial("VP2")+VP4->VP4_CODGRU+VP4->VP4_NUMCOT+VP4->VP4_CODCLI+VP4->VP4_LOJA)
      Do While !EOF()
         if VP2_CODGRU+VP2_NUMCOT+VP2_CODCLI+VP2_LOJA # VP4->VP4_CODGRU+VP4->VP4_NUMCOT+VP4->VP4_CODCLI+VP4->VP4_LOJA
            Exit
         Endif
         if !Empty(VP2_DATPAG) .and. VP2_DATPAG >= VP4->VP4_DATLAN
            MsgInfo(STR0008,STR0003)    //Antecipacao/Lance ja baixado nas Parcelas
            Return(.f.)
         Endif
         dbSkip()
      Enddo
   Endif
Endif
if !FG_GERPAR(VP4->VP4_CODGRU+VP4->VP4_NUMCOT+VP4->VP4_CODCLI+VP4->VP4_LOJA,2,.f.)
   Return .t.     // Se nao existir parcelas no participante pode Excluir...
Endif
wRet := FG_GERPAR(VP4->VP4_CODGRU+VP4->VP4_NUMCOT+VP4->VP4_CODCLI+VP4->VP4_LOJA,3)
Return(wRet)

Function FS_VALL()
local lRet := .t.
dbSelectArea("VP1")
dbSetOrder(1)
dbSeek(xFilial("VP1")+M->VP4_CODGRU+M->VP4_NUMCOT)
dbSelectArea("VP6")
dbSetOrder(1)
If dbSeek(xFilial("VP6")+VP1->VP1_CODBEM)
   If M->VP4_VALLAN > VP1->VP1_VALCRE
      MsgStop(STR0009,STR0010) //"Valor do Lance excede ao saldo em aberto do bem"###"Atencao"
      lRet := .f.
   EndIf
EndIf 
dbSelectArea("VP4")
return lRet

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)