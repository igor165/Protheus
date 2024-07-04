#INCLUDE "ofiom060.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOM060 ³ Autor ³  Fabio                ³ Data ³ 19/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apontamento Manual de Servico                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OFIOM060

PRIVATE aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0004) //"Apontamento Manual de Servico"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VO1",,"VO1->VO1_STATUS # 'A'")

Return


***********************
Function Om060(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor:=0, _ni:=0, i:=0

If VO1->VO1_STATUS # "A"
   Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RegToMemory("VO2",.T.)

aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VO2")
While !Eof().and.(x3_arquivo=="VO2")
   If X3USO(x3_usado).and.x3_nivel>0
      AADD(aCpoEnchoice,x3_campo)
   Endif
   wVar := "M->"+x3_campo
   &wVar:= CriaVar(x3_campo)
   dbSkip()
End
If !(Inclui)
   DbSelectArea("VO2")
   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif

If nOpc == 3
   nOpcE := 3
   nOpcG := 3
ElseIf nOpc == 4
   nOpcE := 4
   nOpcG := 4
ElseIf nOpc == 2
   nOpcE := 2
   nOpcG := 2
Else
   nOpcE := 5
   nOpcG := 5
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VO4")
aHeader:={}
While !Eof().And.(x3_arquivo=="VO4")
   If X3USO(x3_usado).And.cNivel>=x3_nivel
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
      wVar := "M->"+x3_campo
      &wVar := CriaVar(x3_campo)
   Endif
   dbSkip()
End

dbSelectArea("VO4")
dbSetOrder(1)
dbSeek(xFilial()+M->VO2_NOSNUM)

If Inclui .Or. !(Found())
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
       aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
   Next
Else
   aCols:={}
   While !eof() .and. VO4->VO4_NOSNUM == M->VO2_NOSNUM
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
   cTitulo       :=STR0001
   cAliasEnchoice:="VO2"
   cAliasGetD    :="VO4"
   cLinOk        :="FG_OBRIGAT()"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="FG_MEMVAR()"

   _lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

   If _lRet .and. nOpc # 2

      dbselectArea("VFD")
      If Inclui .or. Altera

         RecLock("VFD",If(Inclui,.T.,.F.))

         VFD->VFD_FILIAL := xFilial("VFD")
         VFD->VFD_CODCLI := M->VFD_CODCLI
         VFD->VFD_CODMAR := M->VFD_CODMAR
         VFD->VFD_MODVEI := M->VFD_MODVEI
         ConfirmSx8()
         MsUnlock()
//      Else

//         RecLock("VFD",.F.,.T.)
//         dbdelete()
//         MsUnlock()
//         WriteSx2("VFD")

      Endif

      for i:=1 to len(aCols)
         If empty(aCols[i,1])
            Loop
         Endif

         dbselectArea("VO4")
         wProcura := dbseek(xFilial("VO4")+M->VFD_CODCLI+M->VFD_CODMAR+M->VFD_MODVEI+aCols[I][1])

         If Inclui .or. Altera

            If aCols[i,5] .And. Altera .And. wProcura
//               RecLock("VO4",.F.,.T.)
//               dbdelete()
//               MsUnlock()
//               WriteSx2("VO4")
               RecLock("VO4",If(wProcura,.F.,.T.))
               VO4->VO4_DATFIN := If(Empty(aCols[I][4]),DdataBase,aCols[I][4])
               MsUnlock()
            ElseIf !(aCols[i,5])
               RecLock("VO4",If(wProcura,.F.,.T.))
               VO4->VO4_FILIAL := xFilial("VO4")
               VO4->VO4_CODCLI := M->VFD_CODCLI
               VO4->VO4_CODMAR := M->VFD_CODMAR
               VO4->VO4_MODVEI := M->VFD_MODVEI
               VO4->VO4_CODCOM := aCols[I][1]
               VO4->VO4_DATINI := aCols[I][3]
               VO4->VO4_DATFIN := aCols[I][4]
               MsUnlock()
            Endif

         Else

//            RecLock("VO4",.F.,.T.)
//            dbdelete()
//            MsUnlock()
//            WriteSx2("VO4")
            RecLock("VO4",If(wProcura,.F.,.T.))
            VO4->VO4_DATFIN := If(Empty(aCols[I][4]),DdataBase,aCols[I][4])
            MsUnlock()

         Endif

      Next

   Endif

Endif

Return

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},;   && Pesquisar //"Pesquisar"
                     { STR0002 ,"Om060", 0 , 2},;      && Visualizar //"Visualizar"
                     { STR0003 ,"Om060", 0 , 3}}       && Requisitar //"Requisitar"
Return aRotina
