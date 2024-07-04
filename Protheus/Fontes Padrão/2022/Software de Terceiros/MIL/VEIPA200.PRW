#include "Veipa200.ch"
#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIPA200 ³ Autor ³ Andr‚                 ³ Data ³ 12/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Lancamento de Parcelas                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Grupo VIP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIPA200

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0006)  //Lancamento de Parcelas

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VP1")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PARCELAS  ³ Autor ³ Andr‚                 ³ Data ³ 14/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta Modelo 2                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function VPA200(cAlias,nReg,nOpc)

Local lOk := .t.
Local nCont
Local nCntFor,_ni := 0

Private wOpc := nOpc

if wOpc == 2
   wOpc := 1
Elseif wOpc == 3
   wOpc := 2
Endif

CODGRU := VP1->VP1_CODGRU
DESGRU := SPACE(25)
NUMCOT := VP1->VP1_NUMCOT
CODCLI := VP1->VP1_CODCLI
LOJCLI := VP1->VP1_LOJA
NOMCLI := SPACE(25)
FGDES("VP3","CODGRU","DESGRU","VP3_DESGRU")
FGDES("SA1","CODCLI+LOJCLI","NOMCLI","A1_NOME")

Private oFonte   := TFont():New( "Arial", 8, 14 )
Private oOk      := LoadBitmap( GetResources(), "LBOK" )
Private oNo      := LoadBitmap( GetResources(), "LBNO" )
nOpca   := 0

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0006) FROM  02,04 TO 08,54 OF oMainWnd && Movimentacao de Veiculos //"Lancamento de Parcelas"

      @  02, 04 SAY   STR0007 SIZE  25,06 OF oDlg PIXEL FONT oFonte //"Grupo"
      @  02, 30 MSGET CODGRU  SIZE  26,04 OF oDlg PIXEL When .f.
      @  02, 70 MSGET DESGRU  SIZE 125,04 OF oDlg PIXEL When .f.
      @  15, 04 SAY   STR0008  SIZE  23,06 OF oDlg PIXEL FONT oFonte //"Cota"
      @  15, 30 MSGET CODCLI  SIZE  40,04 OF oDlg PIXEL When .f.
      @  15, 70 MSGET NOMCLI  SIZE 125,04 OF oDlg PIXEL When .f.

      DEFINE SBUTTON FROM 30,127 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
      DEFINE SBUTTON FROM 30,161 TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

if nOpca == 1

   if wOpc == 4     // Exclusao
      if MsgYesNo(STR0009,STR0010)   // Confirma Exclusao , Atencao
         DbSelectArea("VP2")
         DbSetOrder(1)
         if dbSeek(xFilial("VP2")+CODGRU+NUMCOT+CODCLI)
            nCont := 0
            While !eof() .and. VP2->VP2_FILIAL == xFilial("VP2") .and. VP2_CODGRU == CODGRU .AND. VP2_NUMCOT == NUMCOT .AND. VP2_CODCLI == CODCLI
                  if !Empty(VP2_DATPAG)
                     if MsgYesNo(STR0011,STR0010)   // Participante com parcelas pagas, Exclui Mesmo?
                        Exit
                     Else
                        Return .f.
                     Endif
                  Endif
                  DbSkip()
            Enddo
         Endif
         dbGotop()
         if dbSeek(xFilial("VP2")+CODGRU+NUMCOT+CODCLI)
            nCont := 0
            lOk   := .t.
            Begin Transaction
               While !eof() .and. VP2->VP2_FILIAL == xFilial("VP2") .and. CODGRU == VP2_CODGRU .and. NUMCOT == VP2_NUMCOT .and. CODCLI == VP2_CODCLI
                   if RecLock("VP2",.f.,.t.)
                      Dele
                      MsUnlock()
                      DbSkip()
                      nCont++
                   Else
                      lOk := .f.
                      DisarmTransaction()
                      Break
                   Endif
               End
            End Transaction
            if !lOk
               HELP("REGNLOCK")
            Else
               MsgInfo(STR0012+Str(nCont)+STR0013,STR0010) //"Foram excluidas   "###"   Parcelas!"###"Atencao!"
            Endif
         Else
            MsgInfo(STR0014,STR0010) //"Nenhuma parcela foi encontrada para exclusao!"###"Atencao!"
         Endif
      Endif
      Return .t.
   Endif

   wRet := FG_GERPAR(CODGRU+NUMCOT+CODCLI+LOJCLI,wOpc)

   if wRet

      if MsgYesNo(STR0015,STR0016) == .f.   //"Visualiza Parcelas?","Confirme..." //"Visualiza as Parcelas?"###"Confirme.."
         Return .t.
      Endif

      bCampo := {|x| Field(x)}

      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Cria variaveis M->????? da Enchoice                          ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      RegToMemory("VP1",.T.)
      aCpoEnchoice  :={}
      DbSelectArea("SX3")
      DbSetOrder(1)
      DbSeek("VP1")
      While !Eof().and.(x3_arquivo=="VP1")
         If X3USO(x3_usado).and.x3_nivel>0
            AADD(aCpoEnchoice,x3_campo)
         Endif
         wVar := "M->"+x3_campo
         &wVar:= CriaVar(x3_campo)
         dbSkip()
      End
      Inclui := .f.
      If !(Inclui)
         DbSelectArea("VP1")
         For nCntFor := 1 TO FCount()
            M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
         Next
      Endif

      nOpcE := 2
      nOpcG := 2
      nOpc  := 2
      cFieldOk := "AllwaysTrue()"
      cLinOk   := "AllwaysTrue()"
      cTudoOk  := "AllwaysTrue()"

      nUsado:=0
      dbSelectArea("SX3")
      dbSeek("VP2")
      aHeader:={}
      While !Eof().And.(x3_arquivo=="VP2")
         if X3USO(x3_usado).and.cNivel>=x3_nivel.and.!(alltrim(x3_campo) $ [VP2_LOJA#VP2_NUMBOL#VP2_PERANT#VP2_LANANT#VP2_SALANT#VP2_PGTANT#VP2_VALANT#VP2_PARANT])
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
      if dbSeek(xFilial("VP2")+CODGRU+NUMCOT+CODCLI)
         While !eof() .and. VP2->VP2_FILIAL == xFilial("VP2") .and. VP2_CODGRU == CODGRU .AND. VP2_NUMCOT == NUMCOT .AND. VP2_CODCLI == CODCLI
             AADD(aCols,Array(nUsado+1))
             For _ni:=1 to nUsado
                 aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
             Next
             aCols[Len(aCols),nUsado+1]:=.F.
             dbSkip()
         End
      Else
         aCols:={Array(nUsado+1)}
         aCols[1,nUsado+1]:=.F.
         For _ni:=1 to nUsado
             aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
         Next
      Endif

      cTitulo       :=STR0017 //"Parcelas do Participantes"
      cAliasEnchoice:="VP1"
      cAliasGetD    :="VP2"
      cLinOk        :="AllwaysTrue()"
      cTudOk        :="AllwaysTrue()"
      cFieldOk      :="AllwaysTrue()"
      nOpcE := 2
      nOpcG := 2

      FS_Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

   Endif

Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FGDES    ³ Autor ³ Andr‚                 ³ Data ³ 12/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Traz Descricao do Grupo e do Participante                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Arg1 = Alias do Arquivo                                    ³±±
±±³          ³ Arg2 = Chave                                               ³±±
±±³          ³ Arg3 = Campo destino                                       ³±±
±±³          ³ Arg4 = Campo contendo o conteudo desejado                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FGDES(Arg1,Arg2,Arg3,Arg4)

&Arg2 := StrZero(Val(&Arg2),len(&Arg2))

DbSelectArea(Arg1)

if DbSeek(xFilial(Arg1)+&Arg2)
   &Arg3 := SUBSTR(&Arg4,1,25)
Endif

Return

/*
Static Function FS_PROCES()

   Processa({|lEnd| FG_GERPAR(CODGRU+NUMCOT+CODCLI+LOJCLI,wOpc)},,STR0018) //"Processando.."

Return .t.
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_Modelo3³ Autor ³ Andr‚                 ³ Data ³ 07/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Consulta as Parcelas Geradas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Modelo3(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze)
Local lRet, nOpca := 0,cSaveMenuh,nReg:=(cAlias1)->(Recno()),oDlg

Private Altera:=.f.,Inclui:=.f.,lRefresh:=.t.,aTELA:=Array(0,0),aGets:=Array(0),;
bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcE := If(nOpcE==Nil,3,nOpcE)
nOpcG := If(nOpcG==Nil,3,nOpcG)
lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas:=Iif(nLinhas==Nil,99,nLinhas)

DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,80	of oMainWnd
EnChoice(cAlias1,nReg,nOpcE,,,,aMyEncho,{15,1,70,315},aAltEnchoice,3,,,,,,lVirtual)
oGetDados := MsGetDados():New(75,1,143,315,nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,nLinhas,cFieldOk)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()})

lRet:=(nOpca==1)

Return lRet

Static Function MenuDef()
Local aRotina := { { STR0001 ,"AxPesqui()" ,0 ,1},;  //Pesquisar
                    { STR0002 ,"VPA200"  ,0 ,2},;  //Lancar
                    { STR0004 ,"VPA200"  ,0 ,3},;  //Atualizar
                    { STR0005 ,"VPA200"  ,0 ,4}}   //Excluir
Return aRotina
