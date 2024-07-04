#INCLUDE "veipa860.ch"
#include "protheus.ch"
#include "fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIPA860 ³ Autor ³ Andr‚                 ³ Data ³ 12/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Recebimento de Parcelas                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico (Modelo 2)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION VEIPA860

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0003)  // //"Recebimento de Parcelas"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VP1")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PARCELAS2 ³ Autor ³ Andr‚                 ³ Data ³ 14/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta Modelo 2                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PARCELAS2(cAlias, nReg, nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor,_ni,i  := 0

Private lGrv := .f.
Private aColsSlv

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nOpcE := 2
nOpcG := 2

INCLUI := .f.
ALTERA := .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VP1",.f.)
DbSelectArea("VP1")
For nCntFor := 1 TO FCount()
   if INCLUI
      if ValType(FieldGet(nCntFor)) == "C" .or. ValType(FieldGet(nCntFor)) == "M"
         M->&(EVAL(bCampo,nCntFor)) := space(len(FieldGet(nCntFor)))
      Elseif ValType(FieldGet(nCntFor)) == "N"
         M->&(EVAL(bCampo,nCntFor)) := 0
      Elseif ValType(FieldGet(nCntFor)) == "L"
         M->&(EVAL(bCampo,nCntFor)) := " "
      Elseif ValType(FieldGet(nCntFor)) == "D"
         M->&(EVAL(bCampo,nCntFor)) := ctod("")
      Endif
   Else
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Endif
Next

FG_GERPAR(VP1->VP1_CODGRU+VP1->VP1_NUMCOT+VP1->VP1_CODCLI+VP1->VP1_LOJA,2,.f.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VP2")
aHeader:={}
While !Eof().And.(x3_arquivo=="VP2")
   if X3USO(x3_usado) .AND. cNivel>=x3_nivel .AND. !(Alltrim(X3_CAMPO) $ [VP2_LOJA#VP2_NUMBOL#VP2_PERANT#VP2_LANANT#VP2_SALANT#VP2_PGTANT#VP2_VALANT#VP2_PARANT])
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context } )
   Endif
   dbSkip()
End

aCols:={}
dbSelectArea("VP2")
dbSetOrder(1)
if dbSeek(xFilial("VP2")+VP1->VP1_CODGRU+VP1->VP1_NUMCOT+VP1->VP1_CODCLI+VP1->VP1_LOJA)
   While !eof() .and. VP1->VP1_CODGRU == VP2_CODGRU .AND. VP1->VP1_NUMCOT == VP2_NUMCOT .AND. VP1->VP1_CODCLI == VP2_CODCLI .AND. VP1->VP1_LOJA == VP2->VP2_LOJA
       if !empty(VP2_DATPAG)
          DbSkip()
          Loop
       Endif
       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado
           aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
       Next
       aCols[Len(aCols),nUsado+1]:=.F.
       dbSkip()
   End
Else
   HELP("PARNAOGER")
Endif

aColsSlv := aClone(aCols)

If Len(aCols)>0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTitulo       := STR0003   // //"Recebimento de Parcelas"
   cAliasEnchoice:= "VP1"
   cAliasGetD    := "VP2"
   cFieldOk      := "FG_MEMVAR()"
   cLinOk        := "AllwaysTrue()"
   cTudOk        := "FS_GRPA860()"
   aCpoEnchoice  := {}

   dbSelectArea("SX3")
   dbSeek("VP1")
   aCpoEnchoice := {}
   While !Eof().and.(x3_arquivo=="VP1")
      if X3USO(x3_usado).and.cNivel>=x3_nivel
         AADD(aCpoEnchoice,x3_campo)
      Endif
      dbSkip()
   End

   Set Key VK_F10 to FS_BAIXA()

   l_RetMod := Fs_Mod3860(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

   if !l_RetMod  // Se Cancelar Gravacao
      
      if !lGrv
         Return 
      Endif   
   
      aCols := aClone(aColsSlv)

		Begin Transaction

		   DbSelectArea("VP2")
		   DbSetOrder(1)

		   DbSeek(xFilial("VP2")+VP1->VP1_CODGRU+VP1->VP1_NUMCOT+VP1->VP1_CODCLI+VP1->VP1_LOJA)
	
   		For i:=1 to Len(aCols)
		       DbSeek(xFilial("VP2")+VP1->VP1_CODGRU+VP1->VP1_NUMCOT+VP1->VP1_CODCLI+VP1->VP1_LOJA+aCols[i,fg_posvar("VP2_NUMPAR")])
		       if RecLock("VP2",.f.)
		          VP2->VP2_FILIAL := xFilial("VP2")
		          VP2->VP2_PARPAG := aCols[i,fg_posvar("VP2_PARPAG")]
		          VP2->VP2_DESPAG := aCols[i,fg_posvar("VP2_DESPAG")]
		          VP2->VP2_TOTPAG := aCols[i,fg_posvar("VP2_TOTPAG")]
		          VP2->VP2_DATPAG := aCols[i,fg_posvar("VP2_DATPAG")]
		          VP2->VP2_PERPAG := aCols[i,fg_posvar("VP2_PERPAG")]
		          VP2->VP2_PERDIF := aCols[i,fg_posvar("VP2_PERDIF")]
		          VP2->VP2_PERSAL := aCols[i,fg_posvar("VP2_PERSAL")]
		          FG_GRAVAR("VP2",aCols,aHeader,i)
		          if !Empty(VP2->VP2_DATPAG)
		              VP2->VP2_PARANT := 0
		              VP2->VP2_PGTANT := 0
		              VP2->VP2_LANANT := 0
		              VP2->VP2_VALANT := 0
		              VP2->VP2_PERANT := 0
		              VP2->VP2_SALANT := 0
      		    Endif
		          MsUnlock()
		       Else
		          lRet := .f.
		          DisarmTransaction()
		          Break
		       Endif
		   Next

         FG_GERPAR(VP1->VP1_CODGRU+VP1->VP1_NUMCOT+VP1->VP1_CODCLI+VP1->VP1_LOJA,2,.f.)

		End Transaction
      
   Endif

Endif

Return


/////////////////////
Function FS_GRPA860()

Local lRet := .t.
Local i := 0
lGrv := .t.

Begin Transaction

   DbSelectArea("VP2")
   DbSetOrder(1)

   DbSeek(xFilial("VP2")+VP1->VP1_CODGRU+VP1->VP1_NUMCOT+VP1->VP1_CODCLI+VP1->VP1_LOJA)

   For i:=1 to Len(aCols)
       DbSeek(xFilial("VP2")+VP1->VP1_CODGRU+VP1->VP1_NUMCOT+VP1->VP1_CODCLI+VP1->VP1_LOJA+aCols[i,fg_posvar("VP2_NUMPAR")])
       if RecLock("VP2",.f.)
          VP2->VP2_FILIAL := xFilial("VP2")
          VP2->VP2_PARPAG := aCols[i,fg_posvar("VP2_PARPAG")]
          VP2->VP2_DESPAG := aCols[i,fg_posvar("VP2_DESPAG")]
          VP2->VP2_TOTPAG := aCols[i,fg_posvar("VP2_TOTPAG")]
          VP2->VP2_DATPAG := aCols[i,fg_posvar("VP2_DATPAG")]
          VP2->VP2_PERPAG := aCols[i,fg_posvar("VP2_PERPAG")]
          VP2->VP2_PERDIF := aCols[i,fg_posvar("VP2_PERDIF")]
          VP2->VP2_PERSAL := aCols[i,fg_posvar("VP2_PERSAL")]
          FG_GRAVAR("VP2",aCols,aHeader,i)
          if !Empty(VP2->VP2_DATPAG)
              VP2->VP2_PARANT := 0
              VP2->VP2_PGTANT := 0
              VP2->VP2_LANANT := 0
              VP2->VP2_VALANT := 0
              VP2->VP2_PERANT := 0
              VP2->VP2_SALANT := 0
          Endif
          MsUnlock()
       Else
          lRet := .f.
          DisarmTransaction()
          Break
       Endif
   Next

End Transaction

Set Key VK_F10 to

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_BAIXA  ³ Autor ³ Andr‚                 ³ Data ³ 12/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Tela BAIXA                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico (Modelo 2)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_BAIXA()

dData   := dDataBase
nPAGPAR := aCols[n,fg_posvar("VP2_VALPAR")]
nDESPAG := aCols[n,fg_posvar("VP2_VALDES")]
nTOTPAG := nPAGPAR+nDESPAG
nVALACR := 0

nOpca := 0

if !Empty(aCols[n,fg_posvar("VP2_DATPAG")])
   Return .f.
Endif

if n > 1
   if Empty(aCols[n-1,fg_posvar("VP2_DATPAG")]) .or. aCols[n,fg_posvar("VP2_PARPAG")] == 0
      Return .f.
   Endif
Endif

DEFINE MSDIALOG oDlg2 TITLE OemToAnsi(STR0003) From 5,2 TO 15,35 OF oMainWnd   // //"Recebimento de Parcelas"

   @ 03,   2 TO 020, 130 LABEL "" OF oDlg2  PIXEL
   @ 21,   2 TO 057, 130 LABEL "" OF oDlg2  PIXEL

   @ 8,    5  SAY OemToAnsi(STR0004)+aCols[n,1]+STR0005+dtoc(aCols[n,2]) SIZE 100,07 OF oDlg2 PIXEL //"Parcela:"###"    Vencto..: "

   @ 25,   5	SAY OemToAnsi(STR0006)	SIZE 50,07 OF oDlg2 PIXEL //"Data de Pagamento"

   @ 25,  55 MSGET dData	Picture "@D" SIZE 40, 11 OF oDlg2 PIXEL

   ( SOMA2(1) )

   @ 042,  5 SAY OemToAnsi(STR0007)	SIZE 52, 07 OF oDlg2 PIXEL //"Total a Pagar"

   @ 042, 55	MSGET nTotPag  Picture "@E 9,999,999.99" SIZE 60, 11 OF oDlg2 PIXEL

   DEFINE SBUTTON FROM 059,63 TYPE 1 ACTION (nOpca := 1,oDlg2:End()) ENABLE OF oDlg2
   DEFINE SBUTTON FROM 059,97 TYPE 2 ACTION (nOpca := 2,oDlg2:End()) ENABLE OF oDlg2

ACTIVATE MSDIALOG oDlg2 CENTER

if nOpca == 1

   lGrv := .t.

   wAlias := Alias()

   wPIdeal := VP1->VP1_PERIDE

   wValorBem := 0
   wPerSaldo := 0

   dbSelectArea("VP6")
   if VP6->(DbSeek(xFilial("VP6")+VP1->VP1_CODBEM))
      wValorBem := VP6->VP6_VALBEM
   Endif

   DbSelectArea("VP2")
   DbSetOrder(1)
   DbGotop()
   DbSeek(xFilial("VP2")+M->VP1_CODGRU+M->VP1_NUMCOT+M->VP1_CODCLI+M->VP1_LOJA+aCols[n,fg_posvar("VP2_NUMPAR")])

   DbSelectArea(wAlias)

   nPAGPAR := nTOTPAG - nDESPAG
   aCols[n,fg_posvar("VP2_PARPAG")]  := aCols[n,fg_posvar("VP2_PARPAG")] + nPAGPAR
   aCols[n,fg_posvar("VP2_DESPAG")]  := nDESPAG
   aCols[n,fg_posvar("VP2_TOTPAG")] := aCols[n,fg_posvar("VP2_PARPAG")]+aCols[n,fg_posvar("VP2_DESPAG")]

   aCols[n,fg_posvar("VP2_DATPAG")] := dData
   aCols[n,fg_posvar("VP2_PERPAG")] := aCols[n,fg_posvar("VP2_PERPAG")]+((nPAGPAR-aCols[n,fg_posvar("VP2_VALLAN")])/wValorBem)*100
   if aCols[n,fg_posvar("VP2_PERPAG")] < wPIDEAL
      aCols[n,fg_posvar("VP2_PERDIF")] := wPIDEAL - aCols[n,fg_posvar("VP2_PERPAG")]
   Else
      aCols[n,fg_posvar("VP2_PERDIF")] := 0
   Endif

   RecLock("VP2",.f.)

   VP2_PARPAG := aCols[n,fg_posvar("VP2_PARPAG")]
   VP2_DESPAG := nDESPAG
   VP2_TOTPAG := aCols[n,fg_posvar("VP2_TOTPAG")]
   VP2_DATPAG := dData

   VP2_PERPAG := aCols[n,fg_posvar("VP2_PERPAG")]
   if VP2_PERPAG < wPIDEAL
      VP2_PERDIF := aCols[n,fg_posvar("VP2_PERDIF")]
   Else
      VP2_PERDIF := 0
   Endif

   MsUnlock()

   wPerSaldo   := (wPerSaldo + VP2_PERPAG) - VP2_PERDIF

/*
   DbSelectArea("VP2")
   DbGotop()
   DbSeek(xFilial("VP2")+M->VP1_CODGRU+M->VP1_NUMCOT+M->VP1_CODCLI+M->VP1_LOJA+aCols[n,fg_posvar("VP2_NUMPAR")])
   Do while !EOF() .and. VP2->VP2_FILIAL == xFilial("VP2") .and. VP2_CODGRU == M->VP1_CODGRU .and. VP2_NUMCOT == M->VP1_NUMCOT
      RecLock("VP2",.f.)
      VP2_PERSAL := VP2_PERSAL - wPerSaldo
      MsUnlock()
      DbSkip()
   Enddo
  */

   FG_GERPAR(VP1->VP1_CODGRU+VP1->VP1_NUMCOT+VP1->VP1_CODCLI+VP1->VP1_LOJA,2,.f.)

Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SOMA2    ³ Autor ³ Andr‚                 ³ Data ³ 12/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Soma nas variaveis                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico (Modelo 2)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function SOMA2(Arg)

nTOTPAG := 0

if Arg == 1
   if nPAGPAR > 0
      nTOTPAG := nTOTPAG + nPAGPAR
      nTOTPAG := nTOTPAG + nDESPAG
   Else
      Return .f.
   Endif
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_Mod3860 ³ Autor ³ Andre               ³ Data ³ 12/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Enchoice e GetDados                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lRet:=Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,      ³±±
±±³	      ³ cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice)³±±
±±³	      ³lRet=Retorno .T. Confirma / .F. Abandona	                   ³±±
±±³	      ³cTitulo=Titulo da Janela                                    ³±±
±±³	      ³cAlias1=Alias da Enchoice                                   ³±±
±±³	      ³cAlias2=Alias da GetDados                                   ³±±
±±³	      ³aMyEncho=Array com campos da Enchoice                       ³±±
±±³	      ³cLinOk=LinOk                                                ³±±
±±³	      ³cTudOk=TudOk                                                ³±±
±±³	      ³nOpcE=nOpc da Enchoice                                      ³±±
±±³	      ³nOpcG=nOpc da GetDados                                      ³±±
±±³	      ³cFieldOk=validacao para todos os campos da GetDados         ³±±
±±³	      ³lVirtual=Permite visualizar campos virtuais na enchoice     ³±±
±±³	      ³nLinhas=Numero Maximo de linhas na getdados                 ³±±
±±³	      ³aAltEnchoice=Array com campos da Enchoice Alteraveis        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RdMake                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_Mod3860(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice)
Local lRet, nOpca := 0,cSaveMenuh,nReg:=(cAlias1)->(Recno()),oDlg

Private Altera:=.t.,Inclui:=.t.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
		bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcE := If(nOpcE==Nil,3,nOpcE)
nOpcG := If(nOpcG==Nil,3,nOpcG)
lVirtual:= Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas:=Iif(nLinhas==Nil,99,nLinhas)

DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,80	of oMainWnd
EnChoice(cAlias1,nReg,nOpcE,,,,aMyEncho,{15,1,75,315},aAltEnchoice,3,,,,,,lVirtual)
oGetDados := MsGetDados():New(75,1,143,315,nOpcG,cLinOk,cTudoOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,nLinhas,cFieldOk)
ACTIVATE MSDIALOG oDlg ON INIT FS_CHBAR860(oDlg,{||nOpca:=1,if(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()})

lRet:=(nOpca==1)
Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_CHBAR860 ³ Autor ³ Andre                 ³ Data ³ 12/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Poe a enchoicebar na tela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CHBAR860(oDlg,bOk,bCancel)

Local oBar, bSet15, bSet24, lOk, oBtOk, oBtCan
Local lVolta :=.f.

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

DEFINE BUTTON RESOURCE "S4WB005N" OF oBar ACTION NaoDisp()           TOOLTIP STR0008  // //"Recortar"
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar ACTION NaoDisp()           TOOLTIP STR0009  // //"Copiar"
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar ACTION NaoDisp()           TOOLTIP STR0010  // //"Colar"
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP STR0011  // //"Calculadora..."
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar ACTION Agenda()            TOOLTIP STR0012  // //"Agenda..."
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar ACTION OurSpool()          TOOLTIP STR0013  //"Gerenciador de ImpressÆo..." //"Gerenciador de Impressao..."
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar ACTION HelProg()           TOOLTIP STR0014  // //"Help de Programa..."
DEFINE BUTTON RESOURCE "SALARIOS" OF oBar GROUP ACTION FS_BAIXA()    TOOLTIP STR0015  // //"Monta tela BAIXA para BAIXAr as parcelas"

oBar:nGroups += 6
DEFINE BUTTON oBtOk RESOURCE "OK" OF oBar GROUP ACTION ( lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP STR0016  //### //"Ok - <Ctrl-O>"
SetKEY(15,oBtOk:bAction)
DEFINE BUTTON oBtCan RESOURCE "CANCEL" OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtonOff(bSet15,bSet24,.T.)) TOOLTIP STR0017  //### //"Cancelar - <Ctrl-X>"

SetKEY(24,oBtCan:bAction)
oDlg:bSet15 := oBtOk:bAction
oDlg:bSet24 := oBtCan:bAction
oBar:bRClicked := {|| AllwaysTrue()}
Return nil

Static Function ButtonOff(bSet15,bSet24,lOk)
DEFAULT lOk := .t.
IF lOk
    SetKey(15,bSet15)
    SetKey(24,bSet24)
Endif

Return .T.

Static Function MenuDef()
Local aRotina := { { STR0001 ,"AxPesqui()" , 0 , 1},;  // "Pesquisar"
                   { STR0002 ,"Parcelas2" , 0 , 2}}    // "Receber"
Return aRotina
