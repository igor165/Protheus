#INCLUDE "HSPAHC01.ch"
#include "protheus.CH"
#include "colors.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHC01  º Autor ³ Manoel Filho       º Data ³  09/05/02   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consulta Saldos em Estoque                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHC01() 

Private aRotina := MenuDef()


cCadastro := OemToAnsi(STR0003) //"Consulta Saldos de Produtos"


Private AHEADER  := {}, ACOLS := {}

dbSelectArea("SB1")
DBSetOrder(2)
Dbgotop()

mBrowse( 6, 1,22,75,"SB1")

Return NIL

////////////////////////
Function HSAHC11()
Local bCampo  := { |nCPO| Field(nCPO) }, nRecSb1 := RecNo()
Local nCntFor := 0, _ni:= 0
Private cFieldOk := cTudOk := cLinOk := "Allwaystrue()"

nOpca  := 0
nOpc   := 4    
nUsado := 0
nReg := 0
aGets := {}  // matriz que contem os campos que vao receber digitacao na enchoice
aTela := {}  // matriz que contem os campos que vao aparecer na enchoice
SetPrvt("wVar")
Private aTELA[0][0],aGETS[0] 
Private AHEADER := {}, ACOLS := {}

aRotina := {{"","", 0 , 1},; 
            {"","", 0 , 2},;
            {"","", 0 , 3},;
            {"","", 0 , 4,2},;
            {"","", 0 , 5,1}}


nOpcE := 2
nOpcG := 2

nUsado:=0
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("SB2")
While !Eof().and.(x3_arquivo=="SB2")
   If X3USO(x3_usado).and.x3_nivel>0
      nUsado++
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
      If(nUsado==2,35,x3_tamanho), x3_decimal,x3_valid,;
      x3_usado, x3_tipo, x3_arquivo, x3_context, x3_Relacao, x3_reserv } )
   Endif
   wVar := "M->"+x3_campo
   &wVar:= CriaVar(x3_campo) // executa x3_relacao
   dbSkip()
End        

SB1->(DbGoTo(nRecSb1))

If nOpc#3 // se nao for inclusao
   DbSelectArea("SB2")
   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif

   aCols:={}
   dbSelectArea("SB2")
   dbSetOrder(1)
   if dbSeek(xFilial("SB2")+SB1->B1_COD)
	   While SB2->B2_FILIAL+SB2->B2_COD == xFilial("SB2")+SB1->B1_COD .and. !eof()
	       AADD(aCols,Array(nUsado+1))
	       For _ni:=1 to nUsado
	           aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
	       Next                        
	       DbSelectArea("SX5")
	       DbSeek(xFilial("SX5")+"AL"+Alltrim(SB2->B2_LOCAL))
	       If Found()
   	          aCols[Len(aCols),2] := SX5->X5_DESCRI
	          aCols[Len(aCols),nUsado+1]:=.F.
	         Else
	          aCols[Len(aCols),nUsado+1]:=.F. 
		   Endif
	       DbSelectArea("SB2")
	       dbSkip()
	
	   Enddo
	Else
	   aCols:={Array(nUsado+1)}
	   aCols[1,nUsado+1]:=.F.
	   For _ni:=1 to nUsado
	       aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	   Next
	Endif	

nOpca := 0
If Len(aHeader) > 0 .and. Len(aCols) > 0

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTitulo       :=OemToAnsi(STR0003) //"Consulta Saldos de Produtos"
//   cAliasEnchoice:="SB1"
   cAliasGetd    :="SB2"
   cAlias        :="SB2"
// cLinOk        := "HS_LINOK()"
   cLinOk        :="AllwaysTrue()"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="AllwaysTrue()"

   DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 38,80	of oMainWnd   
//   EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,110,315},,3,,,,,,.F.)
   oGetDados:= MsGetDados():New(15,1,213,315,nOpcG,cLinOk,cTudOk,"",.T.,,,,,cFieldOk)   
   oGetDados:oBrowse:bChange := {|| HS_LmpC01() }
   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(oGetDados:TudoOk().And.obrigatorio(aGets,aTela),nOpca:=1,nOpca:=0),If(nOpca==1,oDlg:End(),.f.)},{|| oDlg:End() })

Endif

Return

//Função de Validação de Linhas da GetDados de Procedimentos
Function HS_LmpC01()
if empty(alltrim(aCols[n,1]))
   aCols[n,2]    := Space(45)
   //M->GA8_DESTPR := Space(45)        
   oGetDados:oBrowse:Refresh()
endif
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 11/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=	{{OemtoAnsi(STR0001),"axPesqui"  , 0 , 1, 0, nil},;            // "Pesquisar"
            		 {OemtoAnsi(STR0002),"HSAHC11(4)", 0 , 1, 0, nil}}             // "Consultar" 
Return(aRotina)