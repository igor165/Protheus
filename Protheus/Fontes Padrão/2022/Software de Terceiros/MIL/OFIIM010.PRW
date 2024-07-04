#INCLUDE "ofiim010.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIIM010 ³ Autor ³  Emilton              ³ Data ³ 10/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Parametros para Transmissao/Recepcao de Dados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OFIIN010

PRIVATE aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := OemToAnsi(STR0006) //"parametros p/ Transmissao/Recepcao de Arquivos") //"Parametros p/ Transmissao/Recepcao de Arquivo"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"VH0")

Return

********************************
Function IM010(cAlias,nReg,nOpcx)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor  := 0	 
Local _ni	   := 0	
Private nOpc := nOpcx

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RegToMemory("VH0",.T.)

aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VH0")
While !Eof().and.(x3_arquivo=="VH0")
   If X3USO(x3_usado).and.x3_nivel>0
      AADD(aCpoEnchoice,x3_campo)
   Endif
   wVar := "M->"+x3_campo
   &wVar:= CriaVar(x3_campo)
   dbSkip()
End
If !(Inclui)
   DbSelectArea("VH0")
   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif

if nOpc == 3
   nOpcE := 3
   nOpcG := 3
elseif nOpc == 4
   nOpcE := 4
   nOpcG := 4
elseif nOpc == 2
   nOpcE := 2
   nOpcG := 2
else
   nOpcE := 5
   nOpcG := 5
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VH1")
aHeader:={}
While !Eof().And.(x3_arquivo=="VH1")
   If X3USO(x3_usado).And.cNivel>=x3_nivel &&.And. !(Alltrim(x3_campo) $ [VH1_CODMAR/VH1_CODOPE])
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
      wVar  := "M->"+x3_campo
      &wVar := CriaVar(x3_campo)
   Endif
   dbSkip()
End

dbSelectArea("VH1")
dbSetOrder(1)
dbSeek(xFilial("VH1")+M->VH0_CODMAR+M->VH0_CODOPE)

If Inclui .Or. !(Found())
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
       aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
   Next
Else
   aCols:={}

   While VH0->VH0_CODMAR+VH0->VH0_CODOPE == VH1->VH1_CODMAR+VH1->VH1_CODOPE .and. !eof()

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

   cTitulo       := cCadastro
   cAliasEnchoice:= "VH0"
   cAliasGetD    := "VH1"
   cLinOk        := "FG_OBRIGAT()"
   cTudOk        := "FS_GRAPART()"
   cFieldOk      := "FG_MEMVAR()"

   _lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIIM010  ºAutor  ³Microsiga           º Data ³  08/15/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAPART()
               
Local lProcura := .t.      
Local i 	   := 0
      
Begin Transaction     

   If nOpc # 2

      dbselectArea("VH0")
      If Inclui .or. Altera

         RecLock("VH0",If(Inclui,.T.,.F.))
         FG_GRAVAR("VH0")
         MsUnlock()

      Endif

      for i:=1 to len(aCols)
         If empty(aCols[i,FG_POSVAR("VH1_TIPREG")])
            Loop
         Endif

         dbselectArea("VH0")
         lProcura := dbseek(xFilial("VH1")+M->VH1_CODMAR+M->VH1_CODOPE+aCols[I,FG_POSVAR("VH1_TIPREG")])


         If Inclui .or. Altera

            If aCols[i,len(aCols[i])] .And. Altera .And. lProcura
               RecLock("VH1",If(lProcura,.F.,.T.))
               MsUnlock()
            ElseIf !(aCols[i,len(aCols[i])])
               RecLock("VH1",If(lProcura,.F.,.T.))
               FG_GRAVAR("VH1",aCols,aHeader,i)
               VH1->VH1_FILIAL := xFilial("VOQ")
               VH1->VH1_CODMAR := M->VH0_CODMAR
               VH1->VH1_CODOPE := M->VH0_CODOPE
               VH1->VH1_TIPREG := M->VH0_TIPREG
               MsUnlock()
            Endif

         Else

            RecLock("VH1",If(lProcura,.F.,.T.))
            MsUnlock()

         Endif

      Next

   Endif

End Transaction            

Return(.t.)

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},; //PESQUISAR 
                     { STR0002 ,"IM010", 0 , 2},;  //VISUALIZAR 
                     { STR0003 ,"IM010", 0 , 3},;  //INCLUIR
                     { STR0004 ,"IM010", 0 , 4},;  //ALTERAR
                     { STR0005 ,"IM010", 0 , 5} }  //EXCLUIR 
Return aRotina
