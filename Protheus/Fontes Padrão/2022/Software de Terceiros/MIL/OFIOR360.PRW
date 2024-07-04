#INCLUDE "ofior360.ch"
#Include "protheus.ch"
#Include "Fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR360 ³ Autor ³ Andr‚                 ³ Data ³ 01/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Copia do Contrato CDCI                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR360()

Private cCadastro := OemToAnsi(STR0001) // //"Contrato CDCI"
Private aRotina   := MenuDef()

DbSelectArea("SEM")

mBrowse( 6, 1,22,75,"SEM")

Return



Function ImpCDCI()

   Local bCampo   := { |nCPO| Field(nCPO) }
   Local aPages:= {}, aVar:={}
   Local i := 0

   Private aTELA[0][0], aGETS[0], aHeader[0]

   aRotina := { { " " ," " , 0, 1},;      //Pesquisar
                { " " ," " , 0, 2},;      //Visualizar
                { " " ," " , 0, 3},;      //Incluir
                { " " ," " , 0, 4},;   //Alterar
                { " " ," " , 0, 5} }   //Excluir

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Opcoes de acesso para a Modelo 3                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   cTitulo        := STR0001 // //"Contrato CDCI"
   cAliasEnchoice := "SEM"
   cLinOk         := "AllwaysTrue()"
   cTudoOk        := "AllwaysTrue()"
   cFieldOk       := "FG_MEMVAR()"

   nOpc :=2
   nOpcE:=2
   nOpcG:=2

   nOpca:=0

   lRefresh := .t.
   Inclui   := .f.
   lVirtual := .f.

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Cria variaveis M->????? da Enchoice                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ     &
   RegToMemory("SEM",.T.)
   aCpoEnchoice  :={}
   DbSelectArea("SX3")
   DbSetOrder(1)
   DbSeek("SEM")
   While !Eof().and.(x3_arquivo=="SEM")
      If X3USO(x3_usado).and.cNivel>=x3_nivel
         AADD(aCpoEnchoice,x3_campo)
      Endif
      wVar := "M->"+x3_campo
      &wVar:= &(x3_campo)
      dbSkip()
   End

   DbSelectArea("SEM")
   For i:=1 to Len(aCpoEnchoice)
      wVar := "M->"+aCpoEnchoice[i]
      &wVar:= &("SEM->"+aCpoenchoice[i])
   End

   DEFINE MSDIALOG oDlg FROM 000,000 TO 018,080 TITLE cTitulo OF oMainWnd

      Zero()
      oGetMGet:= MsMGet():New("SEM",0,nOpcE,,,,aCpoEnchoice,{014,002,130,312},,2,,,,oDlg,,.T.,.F.)

   ACTIVATE MSDIALOG oDlg CENTER ON INIT (FG_EnchoiceBar(oDlg,{|| nOpca := 1, oDlg:End()},{|| nOpca := 2,oDlg:End()}) )

   if nOpca == 1
      Processa( {|| COPIACDCI() } )
   Endif

Return



Function COPIACDCI()

   If ExistBlock("CONTCDCI")
      ExecBlock("CONTCDCI",.f.,.f.,{SEM->EM_CONTRAT})
   Endif

Return

Static Function MenuDef()
Local aRotina := {{OemToAnsi(STR0002),"AxPesqui",0,1},; //"Pesquisar"
                 {OemToAnsi(STR0003) ,"ImpCDCI" ,0,2}}  //"Imprimir"
Return aRotina
