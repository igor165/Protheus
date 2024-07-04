#INCLUDE "veipa300.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ VEIPA300 ³ Autor ³  Andre                ³ Data ³ 24/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao das Parcelas do Participante                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Grupo VIP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIPA300

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0004)   //  //"Manutencao das Parcelas"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VP1")

Return


*********************************
Function CPC300(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor:=0 , _ni:=0, ni:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
   Case nOpc == 3 && Incluir
        nOpcE:=3
        nOpcG:=3
   Case nOpc == 4 && Alterar
        nOpcE:=4
        nOpcG:=4
   Case nOpc == 2 && Visualizar
        nOpcE:=2
        nOpcG:=2
   Otherwise
        nOpcE:=5
        nOpcG:=5
EndCase

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

If !(Inclui)
   DbSelectArea("VP1")
   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VP2")
aHeader:={}
While !Eof().And.(x3_arquivo=="VP2")
   if X3USO(x3_usado).And.cNivel>=x3_nivel.and.!(alltrim(x3_campo) $ [VP2_LOJA#VP2_NUMBOL#VP2_PERANT#VP2_LANANT#VP2_SALANT#VP2_PGTANT#VP2_VALANT#VP2_PARANT])
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
           x3_tamanho, x3_decimal,x3_valid,;
           x3_usado, x3_tipo, x3_arquivo, x3_context } )
      wVar := "M->"+x3_campo
      &wVar := CriaVar(x3_campo)
   Endif
   dbSkip()
End

if nOpc == 3
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
       aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
   Next
Else
   aCols:={}
   dbSelectArea("VP2")
   dbSetOrder(1)
   dbSeek(xFilial("VP2")+M->VP1_CODGRU+M->VP1_NUMCOT+M->VP1_CODCLI+M->VP1_LOJA)
   While !Eof() .and. VP2->VP2_FILIAL == xFilial("VP2") .and. VP2_CODGRU ==  M->VP1_CODGRU .and. VP2_NUMCOT == M->VP1_NUMCOT .and. VP2_CODCLI == M->VP1_CODCLI .and. VP2_LOJA == M->VP1_LOJA
       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado
           aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
       Next
       aCols[Len(aCols),nUsado+1]:=.F.
       dbSkip()
   End
Endif

If Len(aCols)>0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTitulo       :=STR0001  //"Manutencao da Parcelas"
   cAliasEnchoice:="VP1"
   cAliasGetD    :="VP2"
   cLinOk        :="AllwaysTrue()"
   cTudOk        :="FS_GRPA300()"
   cFieldOk      :="FG_MEMVAR()"

   Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

EndIf

Return


/////////////////////
Function FS_GRPA300()

Local lRet := .t.
Local ni :=0

Begin Transaction

   if altera
      DbSelectArea("VP2")
      For ni:=1 to Len(aCols)
          DbGotop()
          wKey := Dbseek(xFilial("VP2")+M->VP1_CODGRU+M->VP1_NUMCOT+M->VP1_CODCLI+M->VP1_LOJA+aCols[ni,FG_POSVAR("VP2_NUMPAR")])
          if wKey
             if RecLock("VP2",If(Inclui,.t.,.f.))
                VP2_FILIAL := xFilial("VP2")
                VP2_CODGRU := M->VP1_CODGRU
                VP2_NUMCOT := M->VP1_NUMCOT
                FG_GRAVAR("VP2",aCols,aHeader,ni)
                MsUnLock()
             Else
                lRet := .f.
                DisarmTransaction()
                Break
             Endif
          Endif
      Next
   Endif

End Transaction
DbCommitAll()

Return(lRet)

Static Function MenuDef()
Local aRotina := {{ STR0001 ,"axPesqui", 0, 1},; //Pesquisar
                  { STR0002 ,"CPC300"  , 0, 2},; //Visualizar
                  { STR0003 ,"CPC300"  , 0, 3},; //Incluir
                  { STR0003 ,"CPC300"  , 0, 4}}	 //Alterar
Return aRotina
