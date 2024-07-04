// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 180    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "Protheus.ch"
#include "Ofiom110.ch"
/*      
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³OFIOM110  ³ Autor ³ Andre                 ³ Data ³ 01/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atendimento a Clientes (Orcamento de Pecas e Servicos e Ven ³±±
±±³          ³da de Pecas Balcao e Avaliacao do Resultado da Venda)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alteracoes³Autor    ³Descricao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Gestao de Concessionarias (SIGAPEC e SIGAOFI)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM110()

Local cTitle   := OemToAnsi(STR0001)
Local x
Local _ni := 0
Local cont
Local nCrrgVar := 0
Local aTitles  := {OemToAnsi(STR0042),OemToAnsi(STR0043),OemToAnsi(STR0044),OemToAnsi(STR0045),OemToAnsi(STR0046)}   //Consulta/Orcamento/Venda/Orcamento de Pecas/Orcamento de Servicos
Private cNota   := ""
Private cSerie := ""
Private GrvNoOS_ := "" // Variavel contendo o Nro da OS para gravacao no VS1 e VSJ (apos importacao do Orcamento para OS)
Private lBotOpc := .t.
Private nCheck := 1
Private nPosGrp := 1

Private nPosCod := 1
Private aIteD := {}
Private wVar :=""
Private lEntrou := .t.
Private cCodSiga := ""
Private cAbrir   := .f.
Private nCkPerg1 := 1
Private cEstMin  := 0
Private aVetForMIL := {}
Private cFormul    := SPACE(LEN(VS3->VS3_FORMUL))
// Variaveis Gerais

Private oFolder,oDlgConsulta,oDlgVenda, oBt1, oDlgOrc, oCodSiga
Private oLbItem, aPriEnc, aSegEnc
Private cCodCli, cLoja
Private cGruIte
Private cCodIte
Private cCodVen
Private lCheck1   := .f.
Private lJaMovPec := .f.
Private aHeader   := {}, aCols := {}, aGravaEnt := {}
Private cPesquisa := Space(100)
Private cNewDate1 := dDataBase-1
Private cNewDate2 := dDataBase
Private aIteBrw   := {}
Private cCodMar   := ""
Private nTotalEnt := 0
Private lItRel    := .f.
Private cReqDev   := "2"
Private cTipOpe   := 1
Private lDestroy  := .f.
Private lSalvou   := .t.
Private cPictCod  := "@!"
Private cNumLib   := " "
Private cGruFor   := "04"
Private lErroFor  := .f.
Private cForPeri  := ""
Private aErrAva   := {}   //Array de formulas incorretas
Private lJaGravou := .f.
Private cTesPad   := Space(3)
Private cCodOpe   := Space(3)
Private cCodCDCI  := Space(4)
Private cOpeMov2  := "1"
Private nDesPer   := 0
Private nValorCom := 0
Private nBrinde   := 0
Private lRecompra := .f.
Private cPrefNF   := ""
Private cPrefixo  := GetNewPar("MV_PREFBAL","BAL")
Private aIteBlq   := {} // itens reservados (orcamento aceito)
Private aIteRes   := {} // itens reservados anteriormentes  (orcamento aceito)s
Private cSimVda   := "P"  // Pecas
Private cTipAva   := "2"  // Pecas
Private aMemos1   := {{"VS1_OBSMEM","VS1_OBSERV"}}
Private aMemos2   := {{"VS9_OBSMEM","VS9_OBSERV"}}
Private aMemos3   := {{"VO1_OBSMEM","VO1_OBSERV"}}
Private lRefresh  := .t.
Private cNumOrc   := space(8)
//Private aRotina   := MenuDef()
Private aRotina := {{"", "",0,1},;
{"", "",0,2},;
{"", "",0,3},;
{"", "",0,4} }

Private M->VS1_ALTORC := " "

// Folder 3 - Condicao de Pagamento
Private oLbParc, oGetCondicao, oCondic1, oCondic2, oCondic3, oCondic4, oCondic5
Private cTipPag, cDesPag, cDesBco, cCodBco
Private oCodCDCI, oValorCom
Private cTipPag1
Private oTipPag, oDesPag, oDesBco, oCodBco
Private oGetMGet, oGetSrvcs, oGetPecas
Private nc        := 1
Private nUsadoC   := 1
Private nUsadoP   :=0
Private aIteParc  := {{cTod(""),0}}
Private cCondic1  := ctod(" ")
Private cCondic2  := space(02)
Private cCondic3  := space(Len(SE1->E1_PARCELA))
Private cCondic4  := space(02)
Private cCondic5  := "1"
Private cObsNF    := " "
Private aTitCre   := {}
Private nTotCre   := 0
Private nTipCre   := 1
If !(cPaisLoc == "BRA") // Manoel - 07/05/2009
	aTitles  := {OemToAnsi(STR0042),OemToAnsi(STR0043),OemToAnsi(STR0336),OemToAnsi(STR0045),OemToAnsi(STR0046)}   //Consulta/Orcamento/Venda/Orcamento de Pecas/Orcamento de Servicos
Endif

Private lFimArg := .f.
Inclui := .t.
Inclui2:= .t.

nOpc := 3 // Incluir
nOpcG:= 3 // Incluir
nOpcE:= 3 // Incluir
nOpcf:= 0

Private aIteRel := {}
aadd(aIteRel,{"","","",0,0})

Private aIteRe2 := {}
aadd(aIteRe2,{"","","",0,0})

// Consulta  de Itens

Private oLbIteRel, cKeyAce
Private cTipTem  := ""
Private nTemPad  := 0
Private nValHor  := 0
Private nValSer  := 0
Private nValTotS := 0
Private nPerSrv  := 0
Private nDesSrv  := 0
Private nPerPec  := 0
Private nDesPec  := 0
Private nQtdIte  := 0
Private nValTotP := 0
Private nValPec  := 0
Private Orcamento:= .f.
Private lExeKit  := .t.
Private lTitulo  := .t.
Private lVAMCid  := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Private aSvAtela := {{},{}}
Private aSvAGets := {{},{}}
Private aTela    := {}
Private aGets    := {}
Private aColsAnt := {}
Private lZap     := .f.

*** Define o cabecalho da tela de atualizacoes ***************************************

Private cCadastro := OemToAnsi(STR0137)
Private oTotPec,oTotSrv,oTotDes,oTotOrc, aPos
Private nTotPec  := 0,nTotSrv := 0,nTotDes := 0,nTotOrc := 0
Private nTotEntr := 0, nTotTit := 0, nTotFre := 0, nTotSeg := 0, nTotAce := 0
Private aHeaderP := {}, aHeaderS := {}, aHeaderI := {}, aHeaderC := {}, aColsP := {}, aColsS := {}, aColsI := {}, aColsC := {}
Private bRefresh := {|| FPRefresh()}
Private nP := 1
Private nS := 1
Private nIC:= 1
Private aCfgCpo := {}
Private aVetCampos := {}
Private cMostraAgr := ""
Private cMostraSeq := ""
Private cQuebraAgr := ""
Private cQuebraSeq := ""
Private nLenaCols  := 0
Private lImportAge := .f.
Private cGetDados := "oGD110"
Private lOX001Auto := .F.


&& Valida se a empresa tem autorizacao para utiliza o modulo de oficina.
If !AMIIn(11,14,41)
	Return
EndIf

&& Carrega numero do agendamento
cNumAgenda := ""
If Type("cNroAgenda") # "U"
	cNumAgenda := cNroAgenda
EndIf

RegToMemory("VS1",.T.)

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS1")
aPriEnc := {}
aSegEnc := {}

While x3_arquivo == "VS1" .and. !eof()
	
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. !AllTrim(x3_campo) $ [VS1_VALDES#VS1_DESACE#VS1_ICMCAL#VS1_VTOTNF#VS1_VALFRE#VS1_VALSEG]
		AADD(aPriEnc,x3_campo)
		if x3_campo <> "VS1_NUMORC"
			wVar := "M->"+x3_campo
			&wVar:= CriaVar(x3_campo)
		Endif
	Endif
	
	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and.  AllTrim(x3_campo) $ [VS1_VALDES#VS1_DESACE#VS1_ICMCAL#VS1_VTOTNF#VS1_VALFRE#VS1_VALSEG]
		AADD(aSegEnc,x3_campo)
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
	Endif
	
	dbSkip()
	
EndDo

//Pecas

nUsadoP:=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS3")
aHeaderP:={}
While !Eof().And.(x3_arquivo=="VS3")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( ! Trim(SX3->X3_CAMPO) $ "VS3_NUMORC" )  //VS3_NOTFAB/VS3_DTNFFB/VS3_PIPIFB/VS3_VIPIFB/VS3_PICMSB/VS3_VICMSB/VS3_NUMIDE
		nUsadoP++
		Aadd(aHeaderP,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		wVar := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols Pecas                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColsP:={Array(nUsadoP+1)}
aColsP[1,nUsadoP+1]:=.F.
For _ni:=1 to nUsadoP
	aColsP[1,_ni]:=CriaVar(aHeaderP[_ni,2])
Next

//Servicos

nUsadoS  := 0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS4")
aHeaderS := {}
While !Eof() .And. (x3_arquivo=="VS4")
	If X3USO(x3_usado) .and. cNivel >= x3_nivel .and. ( ! Trim(SX3->X3_CAMPO) $ "VS4_NUMORC" )
		nUsadoS++
		Aadd(aHeaderS,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		wVar := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols Servicos                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aColsS:={Array(nUsadoS+1)}
aColsS[1,nUsadoS+1]:=.F.
For _ni:=1 to nUsadoS
	aColsS[1,_ni]:=CriaVar(aHeaderS[_ni,2])
Next

// Se aCols e aHeader for vazio Retorna ao Menu
if Len(aColsP) == 0 .or. Len(aColsS) == 0
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols e aHeader da Condicao de Pagamento             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoC  :=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS9")
aHeaderC :={}
While !Eof().And.(x3_arquivo=="VS9")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN#VS9_PORTAD#VS9_DESPOR#VS9_ENTRAD#VS9_NATURE#VS9_CARTEI")
		nUsadoC++
		Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		wVar := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

//Zera as variaveis fiscais
MaFisEnd()

n          := 1
x          := 0
nLinP      := 1
nLinS      := 1
aCols      := {}
aHeader    := {}
cAliasGetD := "VS3"
cLinOk     := "AllwaysTrue()"
cLinOkP    := "FG_OBRIGAT() .and. FS_VERLINHA()"
cLinOkS    := "FG_OBRIGAT()"
cLinOkI    := "FG_OBRIGAT()"
cTudOOk    := "FS_VERCPO() .and. Fs_VerCabec()"
//cFieldOkP  := "FG_MEMVAR()"
cFieldOkP  := "FG_MEMVAR() .and. FS_TESTE110()"
cFieldOkS  := "FG_MEMVAR()"
cFieldOkI  := "FG_MEMVAR()"
nLinhas    := 999
aPos       := { 012,002,080,318 }

dbSelectArea("VS1")
dbSetOrder(1)

DEFINE FONT oFnt1 NAME "Arial" SIZE 08,14 BOLD
DEFINE FONT oFnt2 NAME "Arial" SIZE 08,15 BOLD
DEFINE FONT oFnt3 NAME "Arial" SIZE 08,13 BOLD
DEFINE FONT oFnt4 NAME "Times New Roman"  BOLD

nOpca := 0

Private wOrc        := .f.
Private lJaPerg     := .f.
Private lAbortPrint := .f.

aColsP[1,FG_POSVAR("VS3_SEQUEN","aHeaderP")]:= [001]
aColsS[1,FG_POSVAR("VS4_SEQUEN","aHeaderS")]:= [001]

Private o_grupo, o_codite, o_descri, o_codint
Private oDescri, oLbDesc
Private cDescri := space(180)
Private aArray  := {{"","",""}}

cPesqSB1 := "B11"
dbSelectArea("SX3")
dbSetOrder(2)
if dbSeek("VS3_CODITE")
	if SX3->X3_F3 <> "B07"
		cPesqSB1 := SX3->X3_F3
	Endif
Endif
dbSetOrder(1)

dbSelectArea("VS3")
dbSetOrder(1)

dbSelectArea("VS4")
dbSetOrder(1)

dbSelectArea("SB1")
dbSetOrder(7)

dbSelectArea("SB2")
dbSetOrder(1)

dbSelectArea("SB5")
dbSetOrder(1)

dbSelectArea("SBL")
dbSetOrder(1)

dbSelectArea("SBM")
dbSetOrder(1)

dbSelectArea("VAI")
dbSetOrder(4)

dbSelectArea("SA3")
dbSetOrder(1)

dbSelectArea("VEG")
dbSetOrder(2)

dbSelectArea("VE8")
dbSetOrder(2)

dbSelectArea("VE2")
dbSetOrder(1)

DEFINE MSDIALOG oDlgOrc FROM 000,000 TO 035,080 TITLE cTitle OF oMainWnd

@ 012,001 FOLDER oFolder SIZE 316,254 OF oDlgOrc PROMPTS aTitles[1],aTitles[2],aTitles[3] PIXEL
FG_INIFOLDER("oFolder")

If cPaisLoc == "BRA" // Manoel - 07/05/2009
	oFolder:bChange    := {||  FS_FOLDER(.t.)    }       // Executa na mudanca da aba
Else
	oFolder:bChange    := {||  FS_FOLDER(.t.,lFimArg)  }       // Executa na mudanca da aba
Endif
oFolder:bSetOption := {|x| FS_VALFOLDER(1,x) }       // Validacao na saida da aba

/*
DEFINE BUTTONBAR oBar1 SIZE 25,25 3D TOP OF oFolder:aDialogs[1]

DEFINE BUTTON RESOURCE "NEXT"        OF oBar1 ACTION  FS_INSERE() TOOLTIP STR0089    //"Inclui Item no Orcamento"
DEFINE BUTTON RESOURCE "BUDGETY"     OF oBar1 ACTION  DemandaFreq() TOOLTIP STR0090    //"Consulta Demanda e Frequencia do Item"
DEFINE BUTTON RESOURCE "AUTOM"       OF oBar1 ACTION (cGruIte := get_grupo,cCodIte := get_codite,OFMI900("VE6",0,3,{{"VE6_INDREG","1"}},.t.,.f.,OemToAnsi(STR0091)))  TOOLTIP OemToAnsi(STR0091)    //"Registro de Venda Perdida"
DEFINE BUTTON RESOURCE "CADEADO"     OF oBar1 ACTION (cGruIte := get_grupo,cCodIte := get_codite,OFMI900("VE6",0,3,{{"VE6_INDREG","2"}},.t.,.f.,OemToAnsi(STR0092)))  TOOLTIP OemToAnsi(STR0092)    //"Bloqueia Item"
DEFINE BUTTON RESOURCE "NOVACELULA"  OF oBar1 ACTION (cGruIte := get_grupo,cCodIte := get_codite,OFMI900("VE6",0,3,{{"VE6_INDREG","3"}},.t.,.f.,OemToAnsi(STR0093)))  TOOLTIP OemToAnsi(STR0093)    //"Reserva Item"
DEFINE BUTTON RESOURCE "HISTORIC"    OF oBar1 ACTION (cGruIte := get_grupo,cCodIte := get_codite,OFMI900("VE6",0,3,{{"VE6_INDREG","0"}},.t.,.f.,OemToAnsi(STR0094)))  TOOLTIP OemToAnsi(STR0094)    //"Requisicao de Compra"
if &(GetMv("MV_VLDDBLQ"))
DEFINE BUTTON RESOURCE "RECALC"   OF oBar1 ACTION FS_PERTIPDES() TOOLTIP "Desbloqueia ou Desreserva Item"
Endif
//DEFINE BUTTON RESOURCE "FILTRO"      OF oBar1 ACTION FS_FILTRAITEM(oDlgOrc) TOOLTIP "Filtrar Itens"
DEFINE BUTTON RESOURCE "S4WB014B"    OF oBar1 ACTION FG_ITESUB(get_grupo+get_codite) TOOLTIP "Consulta Substituicoes do Item"
DEFINE BUTTON RESOURCE "EDIT"        OF oBar1 ACTION FS_EDITLOCAL() TOOLTIP "Altera a Localizacao Fisica do Item"
DEFINE BUTTON RESOURCE "ANALITICO"   OF oBar1 ACTION if(Pergunte("OF20MV"),OFIOC150(MV_PAR01,MV_PAR02),NIL) TOOLTIP "Movimento da Peca"  //"Pecas do Orcamento"
DEFINE BUTTON RESOURCE "PENDENTE"    OF oBar1 ACTION OFIOC190(get_grupo,get_codite,get_grupo,get_codite) TOOLTIP "Pedidos pendentes"  //"Pedido"
DEFINE BUTTON RESOURCE "S4SB014N"    OF oBar1 ACTION (FG_CDATAS()) TOOLTIP "Calculo de Datas"
DEFINE BUTTON RESOURCE "PRODUTO"     OF oBar1 ACTION (FS_KIT110(.t.)) TOOLTIP "Consulta Itens e Kit's"
DEFINE BUTTON RESOURCE "RESPONSA"    OF oBar1 ACTION (ML500A()) TOOLTIP "Registra Abordagem"
DEFINE BUTTON RESOURCE "rpmimport"   OF oBar1 ACTION (FS_SITTRP()) TOOLTIP "Situacao Tributaria"
DEFINE BUTTON RESOURCE "preco"       OF oBar1 ACTION (FG_CDEPRO(SB1->B1_COD)) TOOLTIP "Compras / Vendas"
*/

MENU oMenu POPUP
MENUITEM STR0294  Action DemandaFreq()					   		//Demanda e Frequencia
MENUITEM STR0099  Action (cGruIte := get_grupo,cCodIte := get_codite,OFMI900("VE6",0,3,{{"VE6_INDREG","1"}},.t.,.f.,OemToAnsi(STR0091)))//Registro de Venda Perdida # Registo De Venda Perdida
MENUITEM STR0092  Action (cGruIte := get_grupo,cCodIte := get_codite,OFMI900("VE6",0,3,{{"VE6_INDREG","2"}},.t.,.f.,OemToAnsi(STR0092)))//Bloqueia Item # Bloqueia Item
MENUITEM STR0093  Action (cGruIte := get_grupo,cCodIte := get_codite,OFMI900("VE6",0,3,{{"VE6_INDREG","3"}},.t.,.f.,OemToAnsi(STR0093)))//Reserva Item # Reserva Item
MENUITEM STR0094  Action (cGruIte := get_grupo,cCodIte := get_codite,OFMI900("VE6",0,3,{{"VE6_INDREG","0"}},.t.,.f.,OemToAnsi(STR0094)))//Requisicao de Compra # Requisicao de Compra
MENUITEM STR0299  Action FS_PERTIPDES()							//Desbloqueia ou Desreserva
//MENUITEM "Filtrar Itens"  Action FS_FILTRAITEM(oDlgOrc)			//Filtrar Itens
MENUITEM STR0300  Action PESQ110(2,.f.) //alterado as funcoes - Rafael FG_ITESUB(get_grupo+get_codite)		//Consulta Substituicoes //
MENUITEM STR0301  Action FS_EDITLOCAL()					   		//Altera a Localizacao
MENUITEM STR0302  Action if(Pergunte("OF20MV"),OFIOC150(MV_PAR01,MV_PAR02),NIL)//Movimento da Peca
MENUITEM STR0303  Action OFIOC190(get_grupo,get_codite,get_grupo,get_codite) //Pedidos pendentes
MENUITEM STR0304  Action FG_CDATAS()					   		//Calculo de Datas
MENUITEM STR0305  Action FS_KIT110(.t.)					 		//Consulta Itens e Kit's

If (cPaisLoc == "BRA") // Manoel - 07/05/2009
	MENUITEM STR0306  Action FS_SITTRP()					 		//Situacao Tributaria
Endif

MENUITEM STR0307  Action FG_CDEPRO(get_codint)			 		//Compras / Vendas
MENUITEM STR0308  Action ML500A()						 		//Abordagem / Reclamacao
ENDMENU

@ 001,001 BUTTON oOpcoes  PROMPT OemToAnsi(STR0309) OF oFolder:aDialogs[1] SIZE 43,10 PIXEL ACTION OPCOES110( oOpcoes, -50, 20, oMenu, 1 ) WHEN lBotOpc //Opcoes
@ 001,045 BUTTON oInsere  PROMPT OemToAnsi(">>")        OF oFolder:aDialogs[1] SIZE 43,10 PIXEL ACTION FS_INSERE()
@ 001,120 CHECKBOX oItRel VAR lItRel PROMPT "Lista Itens Relacionados" SIZE 100,010 ON CLICK(FS_CHEITE()) OF oFolder:aDialogs[1] PIXEL
/* Andre Luis Almeida 27/02/2008 - Abordagem / RAIC no Botao de Opcoes
If FS_FILBOTAO(2,6)
@ 001,090 BUTTON oRegAbo  PROMPT OemToAnsi(STR0310) OF oFolder:aDialogs[1] SIZE 43,10 PIXEL ACTION ML500A() //Abordagem
Endif
*/
FS_FILBOTAO(2,6)

@ 014,002 SCROLLBOX oScrollCS VERTICAL SIZE 194,310 OF oFolder:aDialogs[1] BORDER PIXEL

aFields := {{"CODINT",STR0311    ,"C",TamSx3("B1_COD")[1],60,"@!",.t.,"FG_POSSB1('Get_CODINT','SB1->B1_COD'),Pesq110(4)",cPesqSB1,,CLR_HBLUE},;	//Chave
{"GRUPO" ,STR0013    ,"C",TamSx3("B1_GRUPO")[1],TamSx3("B1_GRUPO")[1],"@!",.t.,"Pesq110(1)","BM3",,CLR_HBLUE},;						//Grupo
{"CODITE",STR0312 	 ,"C",TamSx3("B1_CODITE")[1],TamSx3("B1_CODITE")[1],"@!",.t.,"Pesq110(2)",cPesqSB1,,CLR_HBLUE},;				//Codigo Item
{"DESCRI",STR0015	 ,"C",TamSx3("B1_DESC")[1],60,"@!",.t.,"Pesq110(3)",cPesqSB1,"Descri110()",CLR_HBLUE},;							//Descricao
{"MARCA" ,STR0313    ,"C",50,50,"@!",.f.},;											//Marca
{"LOCALI",STR0107 	 ,"C",30,50,"@!",.f.},;											//Localizacao
{"SITUAC",STR0314    ,"C",30,30,"@!",.f.},;											//Situacao
{"PRECO" ,STR0005    ,"N",40,40,"@E 999,999,999.99",.f.,,,"FS_PRECOS()",CLR_HRED},;	//Preco
{"QTDEST",STR0006	 ,"N",25,25,"@E 999,999",.f.,,,"FS_DISPON()",CLR_HRED},;		//Estoque
{"QTESTS",STR0315 	 ,"N",25,25,"@E 999,999",.f.,,,,CLR_HRED},;						//Estoque Seguranca
{"CLAABC",STR0316    ,"C",15,15,,.f.},;												//Class ABC
{"CODCAI",STR0317    ,"C",15,15,,.f.},;												//Cod CAI
{"CUSMED",STR0318 	 ,"N",40,40,"@E 999,999,999.99",.f.},;							//Custo Medio
{"ULTVDA",STR0319  	 ,"D",40,40,"@D",.f.},;											//Ult. Venda
{"ULTCOM",STR0321 	 ,"D",40,40,"@D",.f.},;											//Ult. Compra
{"QTDEMB",STR0298  	 ,"N",15,15,"999.99",.f.},;										//Qtd Embal.
{"PESO"  ,STR0297    ,"N",15,15,"999.99",.f.},;										//Peso
{"GRUDES",STR0296	 ,"C",15,15,"@!",.f.},;											//Grupo Descto
{"STATUS",STR0295	 ,"C",1,10,,.f.}}												//Status Pec/Fab

for cont := 1 to Len(aFields)
	&("o_"+aFields[cont,1]) := Nil
next

for cont := 1 to Len(aFields)
	if aFields[cont,3] == "C"
		&("get_"+aFields[cont,1]) := space(aFields[cont,4])
	Elseif aFields[cont,3] == "D"
		&("get_"+aFields[cont,1]) := ctod("")
	Else
		&("get_"+aFields[cont,1]) := 0
	Endif
next

EnchoiceTemp(oScrollCS, aFields)

@ 187,002 LISTBOX oLbItem FIELDS HEADER  OemToAnsi(STR0084),;
OemToAnsi(STR0085),;
OemToAnsi(STR0086),;
OemToAnsi(STR0087),;
OemToAnsi(STR0088);
COLSIZES 20,81,110,10,60;
SIZE 310,051 OF oFolder:aDialogs[1] ON DBLCLICK (FS_ITEREL890(oLbItem:nAt)) PIXEL

oLbItem:SetArray(aIteRe2)
oLbItem:bLine := { || { aIteRe2[oLbItem:nAt,1] ,;
aIteRe2[oLbItem:nAt,2] ,;
aIteRe2[oLbItem:nAt,3] ,;
Str(aIteRe2[oLbItem:nAt,4]),;
Transform(aIteRe2[oLbItem:nAt,5],"@E 9,999,999.99")}}

aTela := {}
aGets := {}
dbSelectArea("VS1")
Zero()
oGetMGet:= MsMGet():New("VS1",0,nOpcE,,,,aPriEnc,{015,002,085,312},,2,,,,oFolder:aDialogs[2],,.T.,.F.,"aSvATela[1]")
oGetMGet:oBox:bGotFocus   := {|| AL_Entra(1,"VS1")}
oGetMGet:oBox:bChange     := {|| Fs_ValInte() }
oGetMGet:oBox:bLostFocus  := {|| AL_Sai(1)}
aSvATela[1] := aClone(aTela)
aSvAGets[1] := aClone(aGets)

FS_TP110()

// Folder 2

@ 085,001 FOLDER oFolder2 SIZE 316,137 OF oFolder:aDialogs[2] PROMPTS aTitles[4],aTitles[5] PIXEL

oFolder2:bChange    := {||  FS_MUDAFLD2()     }       // Executa na mudanca da aba
oFolder2:bSetOption := {|x| FS_VALFOLDER(2,x) }       // Validacao na saida da aba

/*
DEFINE BUTTONBAR oBar1 SIZE 25,25 3D TOP OF oFolder:aDialogs[2]

DEFINE BUTTON RESOURCE "RPMNEW2"    OF oBar1 ACTION (FS_NOVO110())  TOOLTIP "Novo orcamento"
DEFINE BUTTON RESOURCE "RPMOPEN"    OF oBar1 ACTION (lDestroy := .t.,BrowseOrc(.t.))  TOOLTIP STR0095  //"Abre Orcamento Gravado"
DEFINE BUTTON RESOURCE "NOVACELULA" OF oBar1 ACTION FS_Catal110()                    TOOLTIP STR0096  //"Catalogo de Pecas"
DEFINE BUTTON RESOURCE "RECALC"     OF oBar1 ACTION FS_FINORC('1',.F.)              TOOLTIP STR0097  //"Recalcula Orcamento"
DEFINE BUTTON RESOURCE "PRINT02"    OF oBar1 ACTION Fs_PRINTORC()                    TOOLTIP STR0098  //"Imprime Orcamento"
DEFINE BUTTON RESOURCE "S4SB014N"   OF oBar1 ACTION (FG_CDATAS()) TOOLTIP "Calculo de Datas"
DEFINE BUTTON RESOURCE "PRODUTO"    OF oBar1 ACTION (FS_KIT110(.t.)) TOOLTIP "Consulta Itens e Kit's"
DEFINE BUTTON RESOURCE "RESPONSA"   OF oBar1 ACTION (ML500A()) TOOLTIP "Registra Abordagem"
DEFINE BUTTON RESOURCE "PGNEXT"     OF oBar1 ACTION FS_IMPORCOSV() TOOLTIP STR0290 When M->VS1_TIPORC == "2"
DEFINE BUTTON RESOURCE "POSCLI"     OF oBar1 ACTION FS_ORDB() TOOLTIP "Ordem de Busca"
//DEFINE BUTTON RESOURCE "PMSESTRU"   OF oBar1 ACTION FS_TREEPCSV() TOOLTIP " Estrutura do orcamento"
DEFINE BUTTON RESOURCE "AUTOM"      OF oBar1 ACTION (cGruIte := M->VS3_GRUITE,cCodIte := M->VS3_CODITE,OFMI900("VE6",0,3,{{"VE6_INDREG","1"}},.t.,.f.,OemToAnsi(STR0091)))  TOOLTIP OemToAnsi(STR0091)    //"Registro de Venda Perdida"

bOk     := {|| nOpca := 1, lJaGravou := .f. ,FS_FINORC(Nil,.t.,.t.) }
bCancel := {|| nOpca := 1,FS_MUDAABA() .and. FS_CANCELA() }

oBar1:nGroups += 6
DEFINE BUTTON oBtOk2 RESOURCE STR0028 OF oBar1 GROUP ACTION ( cTudoOk, lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP STR0029  //"OK"###"Ok - <Ctrl-O>"
SetKEY(15,oBtOk2:bAction)
DEFINE BUTTON oBtCan2 RESOURCE STR0030 OF oBar1 ACTION ( lLoop:=.f.,Eval(bCancel)) TOOLTIP STR0031  //"CANCEL"###"Cancelar - <Ctrl-X>"
SetKEY(24,oBtCan2:bAction)
*/

MENU oMenu2 POPUP
MENUITEM STR0322    Action FS_ORDB()			//Ordem de Busca Estoque
MENUITEM STR0096    Action FS_Catal110()		//Catalogo de Pecas
MENUITEM STR0097    Action FS_FINORC('1',.F.)	//Recalcula Orcamento
MENUITEM STR0304    Action FG_CDATAS()			//Calculo de Datas
MENUITEM STR0305	Action FS_KIT110(.t.)		//Consulta Itens e Kit's
MENUITEM STR0325    Action FS_IMPORCOSV()		//Exporta p/ Ordem Servico
If GetNewPar("MV_BVENPE","S") == "S"
	MENUITEM STR0326	Action (cGruIte := M->VS3_GRUITE,cCodIte := M->VS3_CODITE,OFMI900("VE6",0,3,{{"VE6_INDREG","1"}},.t.,.f.,OemToAnsi(STR0091)))//Venda Perdida
EndIf
// MENUITEM STR0327    Action (FG_VALFIS())		//Planilha Financeira  // Luis Remocao do Item fnc 3137/2009
MENUITEM STR0308	Action ML500A()				//Abordagem / Reclamacao
//MENUITEM "Inconveniente"              Action FS_TREEPCSV()
ENDMENU

@ 001,001 BUTTON oNovo    PROMPT OemToAnsi(STR0328) OF oFolder:aDialogs[2] SIZE 43,10 PIXEL ACTION FS_NOVO110()							//Novo
@ 001,045 BUTTON oAbrir   PROMPT OemToAnsi(STR0329) OF oFolder:aDialogs[2] SIZE 43,10 PIXEL ACTION (lDestroy := .t.,BrowseOrc(.t.))		//Abrir
@ 001,090 BUTTON oImp     PROMPT OemToAnsi(STR0324) OF oFolder:aDialogs[2] SIZE 43,10 PIXEL ACTION Fs_PRINTORC()						//Imprimir
@ 001,135 BUTTON oOpcoes2 PROMPT OemToAnsi(STR0309) OF oFolder:aDialogs[2] SIZE 43,10 PIXEL ACTION OPCOES110( oOpcoes2, -50, 20, oMenu2, 2 ) WHEN lBotOpc	//Opcoes

@ 001,210 BUTTON oBtOk2   PROMPT OemToAnsi(STR0028) OF oFolder:aDialogs[2] SIZE 43,10 PIXEL ACTION (nOpca := 1, lJaGravou := .f. ,FS_FINORC(Nil,.t.,.t.))	//OK
@ 001,255 BUTTON oBtCan2  PROMPT OemToAnsi(STR0323) OF oFolder:aDialogs[2] SIZE 43,10 PIXEL ACTION (nOpca := 1,FS_CANCELA())				//Cancela

@ 081,001 LISTBOX oLbIteRel FIELDS HEADER OemToAnsi(STR0013),;    // Grupo
OemToAnsi(STR0014),;    // Codigo do Item
OemToAnsi(STR0015),;    // Descricao
OemToAnsi(STR0016),;    // Quantidade
OemToAnsi(STR0017);     // Valor
COLSIZES 20,75,105,25,50;
SIZE 309,040 OF oFolder2:aDialogs[1] ON DBLCLICK (if(!Empty(aIteRel[oLbIteRel:nAt,1]).and.!Empty(aIteRel[oLbIteRel:nAt,2]),;
FS_ITEREL110(oLbIteRel:nAt),.t.), oLbIteRel:Refresh(), oGetPecas:oBrowse:Refresh() ) PIXEL
oLbIteRel:SetArray(aIteRel)
oLbIteRel:bLine := { || { aIteRel[oLbIteRel:nAt,1],;
aIteRel[oLbIteRel:nAt,2],;
aIteRel[oLbIteRel:nAt,3],;
FG_AlinVlrs(Transform(aIteRel[oLbIteRel:nAt,4],"@E 999,999")),;
FG_AlinVlrs(Transform(aIteRel[oLbIteRel:nAt,5],"@E 999,999,999.99"))}}

@ 221,001 TO 239,058 LABEL (" "+STR0011+" ") OF oFolder:aDialogs[2] PIXEL
@ 227,005 msget oTotDes VAR nTotDes Picture "@E 999,999,999.99" SIZE 50,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLACK when .f.

@ 221,060 TO 239,313 LABEL (" "+ STR0330 +" ") OF oFolder:aDialogs[2] PIXEL  //Totais Liquidos
@ 228,066 Say OemToAnsi(STR0010) SIZE 40,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLUE
@ 227,085 msget oTotPec VAR nTotPec Picture "@E 999,999,999.99" SIZE 50,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLACK when .f.
@ 228,145 Say OemToAnsi(STR0009) SIZE 40,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLUE
@ 227,171 msget oTotSrv VAR nTotSrv Picture "@E 999,999,999.99" SIZE 50,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLACK when .f.
@ 228,230 Say OemToAnsi(STR0012) SIZE 50,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLUE
@ 227,260 msget oTotOrc VAR nTotOrc Picture "@E 999,999,999.99" SIZE 50,08 OF oFolder:aDialogs[2] PIXEL COLOR CLR_BLACK when .f.

aHeader := aClone(aHeaderS)
aCols   := aClone(aColsS)
oGetSrvcs                       := MsGetDados():New(001,001,121,310,nOpcG,cLinOkS,cTudoOk,"+VS4_SEQUEN",.T.,,,,nLinhas,cFieldOkS,,,,oFolder2:aDialogs[2])
oGetSrvcs:oBrowse:default()
//oGetSrvcs:oBrowse:bChange       := {|| FG_MEMVAR(), nTemPad := aCols[n,FG_POSVAR("VS4_TEMPAD")], nValHor := aCols[n,FG_POSVAR("VS4_VALHOR")], nKilRod := aCols[n,FG_POSVAR("VS4_KILROD")], nValSer := aCols[n,FG_POSVAR("VS4_VALSER")], nPerSrv := aCols[n,FG_POSVAR("VS4_PERDES")], nDesSrv := aCols[n,FG_POSVAR("VS4_VALDES")], nValTotS := aCols[n,FG_POSVAR("VS4_VALTOT")], FS_SEQAUTO("S") }
oGetSrvcs:oBrowse:bChange     := {|| FG_MEMVAR(), FS_SEQAUTO("S") }
oGetSrvcs:oBrowse:bDelete       := {|| If(aCols[n,Len(aCols[n])] , aCols[n,Len(aCols[n])] := .f. , aCols[n,Len(aCols[n])] := .t.), FS_TOTSRV(), lJagravou := .f.,oGetSrvcs:oBrowse:SetFocus()}
oGetSrvcs:oBrowse:bEditCol      := {|| X:=0, lJagravou := .f.,Fs_TOTSRV(), FG_PULACPO(oGetSrvcs)}
oGetSrvcs:oBrowse:bGotFocus     := {|| oGetSrvcs:oBrowse:SetFocus()}

aHeader  := aClone(aHeaderP)
aCols    := aClone(aColsP)
oGetPecas                       := MsGetDados():New(001,001,080,310,nOpcG,cLinOkP,cTudoOk,"+VS3_SEQUEN",.T.,,,,nLinhas,cFieldOkP,,,,oFolder2:aDialogs[1])
oGetPecas:oBrowse:default()
oGetPecas:oBrowse:bChange       := {|| FS_ITEREL110(), cGruIte := aCols[n,FG_POSVAR("VS3_GRUITE","aHeaderP")], FS_SEQAUTO("P")}
oGetPecas:oBrowse:bEditCol      := {|| if( oGetPecas:oBrowse:nColPos # 1,(FG_MEMVAR(), FPRefresh(), if(oGetPecas:oBrowse:nColPos == 4,FS_ITEREL110(),.t.)),.t.), lJagravou := .f., cGruIte := M->VS3_GRUITE, FG_MEMVAR(), FG_PULACPO(oGetPecas) }
oGetPecas:oBrowse:bDelete       := {|| if(aCols[n,Len(aCols[n])] , aCols[n,Len(aCols[n])] := .f. , aCols[n,Len(aCols[n])] := .t.), if(FS_TOTPEC(),.t.,.f.), lJagravou := .f.,oGetPecas:oBrowse:SetFocus(),FS_TRANSFER(0,0,0,0,.T.,n),FG_MEMVAR() }
oGetPecas:oBrowse:bGotFocus     := {|| Fs_VerCabec(),oGetPecas:oBrowse:Refresh()}

// Folder 3 - Condicao de Pagamento

/*
DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oFolder:aDialogs[3]

DEFINE BUTTON RESOURCE "AUTOM"     OF oBar ACTION OFMI900("VE6",0,3,{{"VE6_INDREG","1"}},.t.,.f.,OemToAnsi(STR0099))      TOOLTIP OemToAnsi(STR0099)  //"Registro de Venda Perdida"
DEFINE BUTTON RESOURCE "CHAVE2"    OF oBar ACTION FS_LIBVENDA("1")              TOOLTIP STR0100  //"Libera Venda"
DEFINE BUTTON RESOURCE "PRECO"     OF oBar ACTION FS_AVALIARES() TOOLTIP STR0101  //"Avaliacao de Resultado"
DEFINE BUTTON RESOURCE "SALVAR"    OF oBar ACTION (FS_SALVAR(),lSalvou := .t.) TOOLTIP STR0146
DEFINE BUTTON RESOURCE "S4SB014N"  OF oBar ACTION FG_CDATAS() TOOLTIP "Calculo de Datas"
DEFINE BUTTON RESOURCE "POSCLI"    OF oBar ACTION FS_ORDB() TOOLTIP "Ordem de Busca"

bOk2    := {|| nOpca := 1,FS_FECVDA() }
bCancel2:= {|| nOpca := 1 }

oBar:nGroups += 6
DEFINE BUTTON oBtOk1  RESOURCE STR0028 OF oBar GROUP ACTION ( cTudoOk, lLoop:=lVolta,lOk:=Eval(bOk2)) TOOLTIP STR0029      //"OK"###"Ok - <Ctrl-O>"
SetKEY(15,oBtOk1:bAction)
DEFINE BUTTON oBtCan1 RESOURCE STR0030 OF oBar ACTION ( lLoop:=.f.,Eval(bCancel2), oFolder:nOption := 2) TOOLTIP STR0031  //"CANCEL"###"Cancelar - <Ctrl-X>"
SetKEY(24,oBtCan1:bAction)
*/

MENU oMenu3 POPUP
MENUITEM STR0331  Action FS_LIBVENDA("1")	//Verifica Liberacao Desconto
MENUITEM STR0332  Action FS_AVALIARES()		//Avalicao do Resultado
MENUITEM STR0304  Action FG_CDATAS() 		//Calculo de Datas
MENUITEM STR0333  Action FS_ORDB()		//Ordem de Busca no Estoque
ENDMENU

@ 001,001 BUTTON oSalvar  PROMPT OemToAnsi( STR0334 ) OF oFolder:aDialogs[3] SIZE 43,10 PIXEL ACTION (FS_SALVAR(),lSalvou := .t.)		//Salvar
@ 001,045 BUTTON oOpcoes3 PROMPT OemToAnsi( STR0309 ) OF oFolder:aDialogs[3] SIZE 43,10 PIXEL ACTION OPCOES110( oOpcoes3, -50, 20, oMenu3, 3 ) WHEN lBotOpc //Opcoes

@ 001,125 BUTTON oNO2     PROMPT OemToAnsi( STR0335 ) OF oFolder:aDialogs[3] SIZE 43,10 PIXEL ACTION (nOpca := 1,oFolder:nOption := 2)	//Voltar
@ 001,170 BUTTON oOK2     PROMPT OemToAnsi( STR0336 ) OF oFolder:aDialogs[3] SIZE 43,10 PIXEL ACTION (nOpca := 1,FS_FECVDA()) 			//Finaliza

FG_TELACOND(oFolder:aDialogs[3],1)

if ExistBlock("ATUBOT110")
	ExecBlock("ATUBOT110",.f.,.f.)
Endif

&& Carrega conteudo nas variaveis de acordo com o vetor - usado na importacao do orcamento.
If Type("aCrrgVar") # "U"
	
	oFolder:nOption := 2
	
	For nCrrgVar := 1 To Len(aCrrgVar)
		&( aCrrgVar[nCrrgVar,1]	 ) := aCrrgVar[nCrrgVar,2]
	Next
	
	FS_CARRAGENDA()
	
EndIf

ACTIVATE MSDIALOG oDlgOrc CENTER ON INIT (FG_EnchoiceBar(oDlgOrc,{|| nOpca := 1,oDlgOrc:End()},{|| nOpca := 2,FS_CANCELA(.t.),oDlgOrc:End()},1),AL_Inicio())

Return( (nOpca == 1) )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OM110ORCAC  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida o When do CAMPO VS1_ORCACE                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM110ORCAC()
Local lRet := .F.
if Left(Funname(),4) == "OFIX" .or. FunName() == "OFIOM350" .or. FunName() == "OFIOM430" .or. FunName() == "M_CONSPEC"
	return .t.
endif
If (cPaisLoc == "BRA")
	If M->VS1_TIPORC == "1" .and. ( Substr(GetMv("MV_LOJAVEI",,"NNNNNN"),1,1) == "N" .or. ( Substr(GetMv("MV_LOJAVEI",,"NNNNNN"),1,1) == "S" .and. nCheck==1 ) )
		lRet := .T.
	EndIf
Endif

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CANCELA  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cancela o Orcamento                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CANCELA(lFecha)

if lFecha # Nil
	if Inclui .and. lJaPerg
		RollBackSX8()
		/*
		dbSelectArea("VSM")
		dbSetOrder(6)
		if dbSeek(xFilial("VSM")+M->VS1_NUMORC)
		while !EOF() .and. VSM->VSM_NUMORC == M->VS1_NUMORC
		RecLock("VSM",.f.,.t.)
		VSM->(dbDelete())
		MsUnlock()
		WriteSx2("VSM")
		dbSelectArea("VSM")
		dbSkip()
		EndDo
		Endif
		*/
	Endif
	Return(oDlgOrc:End())
Endif

If left(aHeader[2,2],3) == "VS3"
	aColsP := aClone(aCols)
Elseif left(aHeader[2,2],3) == "VS4"
	aColsS := aClone(aCols)
Endif

if MsgYesNo(STR0147,STR0148)

	FS_MUDAABA()
	
	if ExistBlock("CANORC110")
		if !ExecBlock("CANORC110",.f.,.f.)
			Return(.f.)
		Endif
	Endif
	
	if Inclui
		RollBackSX8()
	Endif
	//	if !lSalvou
	//		if MsgYesNo(STR0149)
	//			FS_SALVAR()
	//			lSalvou := .t.
	//		Endif
	//	Endif
	
	lJaPerg  := .f.
	lDestroy := .t.
	
	if Type(cGetDados) <> "U"
		
		If Select("TMP") > 0
			dbSelectArea("TMP")
			dbCloseArea()
		EndIf

		/* Comentado pois da erro em
			cArqTra := CriaTrab(aVetCampos, .T.)   && Cria arquivo de trabalho
			DbUseArea( .T.,, cArqTra , "TMP", .f. )
			pelo Projeto Rússia*/
		/*cArqTra := CriaTrab(aVetCampos, .T.)   && Cria arquivo de trabalho
		DbUseArea( .T.,, cArqTra , "TMP", .f. )*/

		dbAppend()
	Endif
	
	FS_FOLDER(.f.)


	Limpa_Var()
	FG_MEMVAR()

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PESQ110    ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa o produto                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PESQ110(opcao,ltip) // o segundo parametro e utilizado na chamada pelo botao consultar item substituido.

Local cont  := 0
Local cDesc := ""
Local lVerDescri := .t.
default ltip := .t.

if nOpca == 2
	Return .t.
Endif

if ((opcao == 3 .and. !o_descri:lModified) .or. (opcao == 1 .and. !o_grupo:lModified) .or. ;
	(opcao == 2 .and. !o_codite:lModified) .or. (opcao == 4 .and. !o_codint:lModified)) .and. ltip
	Return .t.
Endif

if opcao == 1
	if Empty(get_grupo)
		Return .t.
	Endif
	dbSelectArea("SBM")
	dbSetOrder(1)
	if dbSeek(xFilial("SBM")+get_grupo)
		Return .t.
	Else
		Return .f.
	Endif
ElseIf opcao == 2
	
	lVerDescri := .t.
	if Empty(get_grupo)
		If !FG_POSSB1("get_codite","SB1->B1_CODITE","get_grupo")
			dbSelectArea("SB1")
			dbSetOrder(7)
			Return .f.
		Else
			lVerDescri := .f.
		Endif
	Endif
	if Empty(get_codite)
		Return .t.
	Endif
	If lVerDescri
		dbSelectArea("SB1")
		dbSetOrder(7)
		if !dbSeek(xFilial("SB1")+get_grupo+get_codite) .and. !Descri110(1)
			If !FG_POSSB1("get_codite","SB1->B1_CODITE","get_grupo")
				dbSelectArea("SB1")
				dbSetOrder(7)
				Return .f.
			Endif
		Endif
	Endif
	get_codite2 := get_codite
	get_codite := FG_ITESUB(get_grupo+get_codite)
	DbselectArea("SB1")
	DbSetOrder(7)
	DbSeek(xFilial("SB1")+get_grupo+get_codite)
	if get_codite2 <> get_codite
		PESQ110(opcao)
	Endif
	
	//   if SB1->B1_MSBLQL $ "1S"
	//      MsgInfo(STR0337,STR0148)//Este item esta bloqueado # Atencao
	//   Endif
	
	oScrollCS:Refresh()
ElseIf opcao == 3
	if Empty(get_descri)
		Return .t.
	Endif
	dbSelectArea("SB1")
	dbSetOrder(3)
	if !dbSeek(xFilial("SB1")+get_descri) .and. !Descri110(2)
		Return .f.
	Else
		nPos  := RecNo()
		cDesc := SB1->B1_DESC
		dbSkip()
		if cDesc == SB1->B1_DESC
			dbGoto(nPos)
			if !Descri110(2)
				Return .f.
			Endif
		Else
			dbSelectArea("SB1")
			dbGoto(nPos)
		Endif
	Endif
	oScrollCS:Refresh()
ElseIf opcao == 4 .or. opcao == 5
	if Empty(get_codint)
		Return .t.
	Endif
	dbSelectArea("SB1")
	dbSetOrder(1)
	if !dbSeek(xFilial("SB1")+get_codint)
		Return .f.
	Endif
	oScrollCS:Refresh()
Endif

get_grupo  := SB1->B1_GRUPO
get_codite := SB1->B1_CODITE
get_codint := SB1->B1_COD
get_descri := SB1->B1_DESC

if Empty(M->VS1_CODVEN) .or. alltrim(M->VS1_CODVEN) == alltrim(__cUserID)
	dbSelectArea("VAI")
	dbSetOrder(4)
	if !dbSeek(xFilial("VAI")+__cUserID)
		//	   MsgInfo("Usuario nao econtrado...","Atencao!")
	Endif
Else
	dbSelectArea("VAI")
	dbSetOrder(6)
	dbSeek(xFilial("VAI")+M->VS1_CODVEN)
Endif

M->VS1_CODVEN := VAI->VAI_CODVEN

dbSelectArea("SA3")
dbSetOrder(1)
dbSeek(xFilial("SA3")+VAI->VAI_CODVEN)
cCodVen := SA3->A3_COD
cCenCus := VAI->VAI_CC

cForPad := GETNEWPAR("MV_FMLPECA","")
if Empty(cForPad)
	MsgInfo(STR0289)
	//   oCodiIte:setfocus()
	Return
Endif

if Empty(cCodMar)
	cCodMar := SBM->BM_CODMAR
Endif

FS_PREENCHE()
FS_PESQUDBF()

FS_PROMOCAO(cCodMar,cCenCus,get_grupo,get_codite)

if lItRel
	aIteRe2 := FG_ITEREL(Nil,SB1->B1_GRUPO,get_codite,GETMV("MV_FMLPECA"))
Endif
If len(aIteRe2) <= 0
	aIteRe2 := {{"","","",0,0}}
EndIf
oLbItem:nAt := 1
oLbItem:SetArray(aIteRe2)
oLbItem:bLine := { || { aIteRe2[oLbItem:nAt,1] ,;
aIteRe2[oLbItem:nAt,2] ,;
aIteRe2[oLbItem:nAt,3] ,;
Str(aIteRe2[oLbItem:nAt,4]),;
Transform(aIteRe2[oLbItem:nAt,5],"@E 9,999,999.99")}}
oLbItem:Refresh()

for cont := 1 to Len(aFields)
	&("o_"+aFields[cont,1]):Refresh()
next

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_ITEREL890³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Traz itens relacionados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Linha do aCols                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ITEREL890(wLin)
if !Empty(aIteRe2[wLin,1]) .and. !Empty(aIteRe2[wLin,2])
	get_grupo  := aIteRe2[wLin,1]
	get_codite := aIteRe2[wLin,2]
	get_descri := aIteRe2[wLin,3]
	o_codite:lModified := .t.
	PESQ110(2)
Endif

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PREENCHE ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Preenche os campos da Consulta de Pecas                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PREENCHE()

Local bBlock
Local nSaldo := 0
SX5->(dbSeek(xFilial("SX5")+"T2"+SB1->B1_SITPROD))
get_SITUAC  := alltrim(SX5->X5_DESCRI)
//if get_SITUAC == "C"
//	get_SITUAC := STR0104  //"Cancelada"
//Elseif get_SITUAC == "S"
//	get_SITUAC := STR0105  //"Substituida"
//Else
//	get_SITUAC := STR0103  //"Normal"
//Endif

dbSelectArea("SB2")
dbSetOrder(1)
dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)

dbSelectArea("SBM")
DBSetOrder(1)
DBSeek(xFilial("SBM")+SB1->B1_GRUPO)

dbSelectArea("SB5")
dbSetOrder(1)
dbSeek(xFilial("SB5")+SB1->B1_COD)

dbSelectArea("SBL")
dbSetOrder(1)
dbSeek(xFilial("SBL")+SB1->B1_COD)
While !eof() .and. SBL->BL_PRODUTO == SB1->B1_COD
	get_CLAABC := SBL->BL_ABCVEND+SBL->BL_ABCCUST
	dbSkip()
Enddo

nSaldo := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)

bBlock := ErrorBlock()
bErro  := ErrorBlock( { |e| FGX_CheckBug(e) } )

cForPad := GETMV("MV_FMLPECA")

dbSelectArea("VEG")
dbSetOrder(2)
if dbSeek(xFilial("VEG")+"04"+&cForPad)
	
	wVar := VEG->VEG_FORMUL
	get_PRECO := &(wVar)
	
Else

	get_PRECO := SB1->B1_PRV1

Endif

ErrorBlock(bBlock)

get_QTDEST := nSaldo
get_QTESTS := SB1->B1_ESTSEG
get_ULTCOM := SB1->B1_UCOM
get_ultvda := SB2->B2_USAI
get_LOCALI := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ")
if ExistBlock("LOCAOM110")
	get_LOCALI := ExecBlock("LOCAOM110",.f.,.f.,{SB1->B1_COD})
Endif


//cCampo27 := SB1->B1_QE
get_QTDEMB := SB1->B1_QE
get_PESO   := SB1->B1_PESO
get_GRUDES := SB1->B1_GRUDES
//cCampo32 := SB1->B1_ORIGEM
//if SB5->(FieldPos("B5_STATUS")) <> 0
//	get_status := SB5->B5_STATUS
//Endif
DbSelectArea("VE9")
DbSetOrder(3)
DbSeek(xFilial("VE9")+get_codite)
                   
lRet := .f.
Do While !EOF() .and. VE9->VE9_FILIAL + VE9->VE9_ITEANT == xFilial("VE9") + get_codite

	If VE9->VE9_DATSUB <= dDataBase

		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek( xFilial("SB1") + VE9->VE9_GRUITE + VE9->VE9_ITENOV )
	    lRet := .t.
	EndIf
                  
	DbSelectArea("VE9")
   DbSkip()

Enddo
if lRet 
	get_status := "Substituida"
Else	
	get_status := "Ativa
Endif
if GetNewPar("MV_CUSBAL","S") == "S"
	get_CUSMED := SB2->B2_CM1
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PESQUDBF ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Mostra Campos da Consulta                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PESQUDBF()

//Substituicao
/*
dbSelectArea("VE9")
dbSetOrder(5)
If DbSeek(xFilial("VE9")+get_grupo+get_codite)
cCampo8 := VE9->VE9_ITENOV
cCampo9 := VE9->VE9_ITEANT
Else
DbSetOrder(6)
If dbSeek(xFilial("VE9")+get_grupo+get_codite)
cCampo8 := VE9->VE9_ITENOV
cCampo9 := VE9->VE9_ITEANT
Else
cCampo8 := " "
cCampo9 := " "
Endif
Endif
*/

//Kit
dbSelectArea("VE8")
dbSetOrder(2)
if dbSeek(xFilial("VE8")+get_grupo+get_codite)
	get_CODKIT := VE8->VE8_CODKIT
Endif

//Marca
dbSelectArea("SBM")
dbSetOrder(1)
if dbSeek(xFilial("SBM")+get_grupo)
	dbSelectArea("VE1")
	dbSetOrder(1)
	if dbSeek(xFilial("VE1")+SBM->BM_CODMAR)
		cCodMar   := VE1->VE1_CODMAR
		get_marca := VE1->VE1_DESMAR
	Endif
Endif

//C.A.I.
dbSelectArea("SB5")
dbSetOrder(1)
if dbSeek(xFilial("SB5")+SB1->B1_COD)
	dbSelectArea("VE2")
	dbSetOrder(1)
	if dbSeek(xFilial("VE2")+SBM->BM_CODMAR+SB5->B5_CODCAI)
		get_CODCAI := SB5->B5_CODCAI+"-"+VE2->VE2_DESCAI
	Endif
Endif

FS_PREENCHE()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_DISPON   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Mostra Estoque das Pecas por Almoxarifado                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_DISPON()

Private aIte1 := {}

dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+get_grupo+get_codite)

dbSelectArea("SM0")
DbGotop() //Todas as Filiais
Do while !EOF()
	if SM0->M0_CODIGO == Left(cNumEmp,2)
		nSaldo := FS_SALDOPEC(SM0->M0_CODFIL+SB1->B1_COD+SB1->B1_LOCPAD)
		SBE->(dbSeek(SM0->M0_CODFIL+SB2->B2_LOCAL))
		aAdd(aIte1,{"+ "+SM0->M0_NOME+"/"+SM0->M0_FILIAL,SBE->BE_LOCALIZ,TRANS(nSaldo,"@E 999,999,999.99"),SB2->B2_LOCAL})
	Endif
	dbSelectArea("SM0")
	dbSkip()
Enddo

if Len(aIte1) == 0
	aAdd(aIte1,{"","","",""})
Endif

xOpca := 0

DEFINE MSDIALOG xDlg TITLE STR0106 From 10,10 to 33,79 of oMainWnd    //"Localizacao do Item"

@ 012, 001 LISTBOX oLbHeadx FIELDS HEADER	OemToAnsi(STR0107),;  //"Localizacao"
OemToAnsi(STR0108),;  //"Descricao
OemToAnsi(STR0109);   //"Quantidade
COLSIZES 80,130,48;
SIZE 271,162 OF xDlg PIXEL ON DBLCLICK (FS_DISITE(oLbHeadx:nAt))

oLbHeadx:SetArray(aIte1)
oLbHeadx:bLine := { || { aIte1[oLbHeadx:nAt,1] ,;
aIte1[oLbHeadx:nAt,2] ,;
aIte1[oLbHeadx:nAt,3] }}

ACTIVATE MSDIALOG xDlg CENTER ON INIT (EnchoiceBar(xDlg,{|| xOpca := 1,xDlg:End()},{|| xOpca := 2,xDlg:End()}))

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_DISITE   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta ListBox com Disponibilidade do Item por Almoxarifado  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Numero da Linha do ListBox com a Filial                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_DISITE(nNumero)

Local i:=0

if SubStr(aIte1[nNumero,1],1,1) == " "
	if GetMv("MV_LOCALIZ") == "S" .and. localiza(SB1->B1_COD)
		FS_DISPLOC(nNumero)
		Return
	Else
		Return
	Endif
Endif

dbSelectArea("SM0")
DbGotop()
Do While !EOF()
	If SubStr(aIte1[nNumero,1],3) == SM0->M0_NOME+"/"+SM0->M0_FILIAL
		Exit
	Endif
	dbSkip()
Enddo

dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+get_grupo+get_codite)

aIte2 := {}
For i:= 1 to nNumero
	aAdd(aIte2,{aIte1[i,1],aIte1[i,2],aIte1[i,3],aIte1[i,4]})
Next

if SubStr(aIte1[nNumero,1],1,1) == "+"
	aIte2[Len(aIte2),1] := "- "+SubStr(aIte1[nNumero,1],3)
	dbSelectArea("SB2")
	dbSetOrder(1)
	dbSeek(xFilial("SB2")+SB1->B1_COD)
	Do while !EOF() .and. B2_FILIAL == SM0->M0_CODFIL .and. B2_COD == SB1->B1_COD
		if Substr(SB2->B2_LOCAL,1,1) $ "0123456789" .and. Substr(SB2->B2_LOCAL,2,1) $ "0123456789"
			nSaldo := SaldoSB2()
			SBE->(dbSeek(SM0->M0_CODFIL+SB2->B2_LOCAL))
			aAdd(aIte2,{"   + "+SM0->M0_NOME+"/"+SM0->M0_FILIAL,SBE->BE_LOCALIZ,TRANS(nSaldo,"@E 999,999,999.99"),SB2->B2_LOCAL})
		Endif
		dbSelectarea("SB2")
		dbSkip()
	Enddo
Else
	aIte2[Len(aIte2),1] := "+ "+SubStr(aIte1[nNumero,1],3)
Endif

For i:= nNumero+1 to Len(aIte1)
	if SubStr(aIte1[i,1],1,1) # " "
		aadd(aIte2,{aIte1[i,1],aIte1[i,2],aIte1[i,3],aIte1[i,4]})
	Endif
Next

if len(aIte2) == 0
	aadd(aIte2,{"","","",""})
Endif

aIte1 := aclone(aIte2)

oLbHeadx:SetArray(aIte1)
oLbHeadx:bLine := { || { aIte1[oLbHeadx:nAt,1] ,;
aIte1[oLbHeadx:nAt,2] ,;
aIte1[oLbHeadx:nAt,3] }}
oLbHeadx:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_DISPLOC  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta ListBox com Disponibilidade do Item por Localizacao   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Numero da Linha do ListBox com a Filial                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_DISPLOC(nNumero)

Local i:=0

dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+get_grupo+get_codite)
if SubStr(aIte1[nNumero,1],4,1) == " "
	Return
Endif

aIte2 := {}
For i:= 1 to nNumero
	aAdd(aIte2,{aIte1[i,1],aIte1[i,2],aIte1[i,3],aIte1[i,4]})
Next

if SubStr(aIte1[nNumero,1],4,1) == "+"
	aIte2[nNumero,1] := "   -"+SubStr(aIte1[nNumero,1],5)
	dbSelectArea("SBF")
	dbSetOrder(2)
	dbSeek(SM0->M0_CODFIL+SB1->B1_COD+aIte1[nNumero,4])
	Do while !EOF() .and. (BF_FILIAL == SM0->M0_CODFIL .and. BF_PRODUTO == SB1->B1_COD .and. BF_LOCAL == aIte1[nNumero,4])
		if SBF->BF_PRODUTO # SB1->B1_COD
			dbSkip()
		Endif
		SBE->(dbSeek(xFilial("SBE")+SBF->BF_LOCAL+SBF->BF_LOCALIZ))
		aAdd(aIte2,{"       "+SBF->BF_LOCALIZ,SBE->BE_DESCRIC,TRANS(SBF->BF_QUANT,"@E 999,999,999.99"),SBE->BE_LOCAL})
		dbSelectArea("SBF")
		dbSkip()
	Enddo
Else
	if SubStr(aIte1[nNumero,1],4,1) == "-"
		aIte2[nNumero,1] := "   +"+SubStr(aIte1[nNumero,1],5)
		For i:= nNumero+1 to Len(aIte1)
			if !SubStr(aIte1[i,1],4,1) $ "+/-" .and. !SubStr(aIte1[i,1],1,1) $ "+/-"
				nNumero++
			Else
				Exit
			Endif
		Next
	Endif
Endif

For i:= nNumero+1 to Len(aIte1)
	aadd(aIte2,{aIte1[i,1],aIte1[i,2],aIte1[i,3],aIte1[i,4]})
Next

if Len(aIte2) == 0
	aadd(aIte2,{"","","",""})
Endif

aIte1 := aClone(aIte2)

oLbHeadx:SetArray(aIte1)
oLbHeadx:bLine := { || { aIte1[oLbHeadx:nAt,1] ,;
aIte1[oLbHeadx:nAt,2] ,;
aIte1[oLbHeadx:nAt,3] }}
oLbHeadx:Refresh()


Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PRECOS   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Mostra os Precos dos Almoxarifados e Filiais                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PRECOS()

Local bBlock := ErrorBlock()
Local i:=0

wAlias := Alias()
wRecno := Recno()

bErro  := ErrorBlock( { |e| FGX_CheckBug(e) } )

dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+get_grupo+get_codite)
dbSelectArea("SB5")
dbSetOrder(1)
dbSeek(xFilial("SB5")+SB1->B1_COD)
dbSelectArea("VEG")
dbSetOrder(2)

dbSeek(xFilial("VEG")+"04")
xItem := {}
lRet := .t.
Do while !EOF() .and. VEG->VEG_FILIAL == xFilial("VEG") .and. VEG->VEG_GRUFOR == "04"
	
	if Empty(VEG->VEG_GRUPOS)
		lRet := .t.
	Else
		lRet := .f.
		For i:=1 to 25
			if Empty(Substr(VEG->VEG_GRUPOS,(i*4)-3,4))
				Exit
			Else
				if get_grupo == Substr(VEG->VEG_GRUPOS,(i*4)-3,4)
					lRet := .t.
					Exit
				Endif
			Endif
		Next
	Endif
	
	if lRet
		wVar := VEG->VEG_FORMUL
		aadd(xItem,{VEG->VEG_DESCRI,&wVar})
	Endif
	
	dbSelectArea("VEG")
	dbSkip()
Enddo

ErrorBlock(bBlock)

if len(xItem) == 0
	aadd(xItem,{"",""})
Endif

xOpca := 0

DEFINE MSDIALOG xDlg TITLE OemToAnsi( STR0338 ) From 14,30 to 33,80 of oMainWnd  //Precos do Item

@ 012, 001 LISTBOX oLbHeadx FIELDS HEADER	OemToAnsi(STR0110),;    //"Formula"
OemToAnsi(STR0111);     //"Valor"
COLSIZES 120,60;
SIZE 197,131 OF xDlg PIXEL

oLbHeadx:SetArray(xItem)
oLbHeadx:bLine := { || { xItem[oLbHeadx:nAt,1],;
Trans(xItem[oLbHeadx:nAt,2],"@E 999,999,999.99") }}

ACTIVATE MSDIALOG xDlg CENTER ON INIT (EnchoiceBar(xDlg,{|| xOpca := 1,xDlg:End()},{|| xOpca := 2,xDlg:End()}))

dbSelectArea("VEG")
dbSetOrder(1)
dbSeek(xFilial("VEG"))
dbSelectArea(wAlias)
DbGoto(wRecno)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_ITEREL110³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Mostra itens Relacionados                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nro da Linha do aCols                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ITEREL110(wLin)

Local cOld_GRUITE := aCols[n,fg_posvar("VS3_GRUITE","aHeaderP")]
Local cOld_CODITE := aCols[n,fg_posvar("VS3_CODITE","aHeaderP")]
Local cOld_DESITE := aCols[n,fg_posvar("VS3_DESITE","aHeaderP")]
if wLin # Nil
	M->VS3_GRUITE := aCols[n,fg_posvar("VS3_GRUITE","aHeaderP")] := aIteRel[wLin,1]
	M->VS3_CODITE := aCols[n,fg_posvar("VS3_CODITE","aHeaderP")] := aIteRel[wLin,2]
	M->VS3_DESITE := aCols[n,fg_posvar("VS3_DESITE","aHeaderP")] := aIteRel[wLin,3]
	if !FS_PRECPO("P")
		M->VS3_GRUITE := aCols[n,fg_posvar("VS3_GRUITE","aHeaderP")] := cOld_GRUITE
		M->VS3_CODITE := aCols[n,fg_posvar("VS3_CODITE","aHeaderP")] := cOld_CODITE
		M->VS3_DESITE := aCols[n,fg_posvar("VS3_DESITE","aHeaderP")] := cOld_DESITE
	Endif
Endif
aIteRel := FG_ITEREL(M->VS1_TIPTEM,aCols[n,fg_posvar("VS3_GRUITE","aHeaderP")],If(ReadVar()=="M->VS3_CODITE",M->VS3_CODITE,aCols[n,fg_posvar("VS3_CODITE","aHeaderP")]),) // luis delorme - "M->VS1_FORMUL")
If len(aIteRel) <= 0
	aIteRel := {{"","","",0,0}}
EndIf
oLbIteRel:nAt := 1
oLbIteRel:SetArray(aIteRel)
oLbIteRel:bLine := { || { aIteRel[oLbIteRel:nAt,1] ,;
aIteRel[oLbIteRel:nAt,2] ,;
aIteRel[oLbIteRel:nAt,3] ,;
FG_AlinVlrs(Transform(aIteRel[oLbIteRel:nAt,4],"@E 999,999")),;
FG_AlinVlrs(Transform(aIteRel[oLbIteRel:nAt,5],"@E 999,999,999.99"))}}
oLbIteRel:Refresh()
oGetPecas:oBrowse:Refresh()
aColsP := aClone(aCols)

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_PRECPO  ³ Autor ³ Emilton               ³ Data ³ 10/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Preenche Campos                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ P - Pecas / S - Servicos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Exclusivo                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PRECPO(cPecSrv,cArq)
Local cFormAnt := ""
Local lReturn := .t.

if Left(Funname(),4) == "OFIX" .or. FunName() == "OFIOM350" .or. FunName() == "OFIOM430" .or. FunName() == "M_CONSPEC"
	return .t.
endif


FG_MEMVAR()



if cArq == Nil
	cArq := 1
Endif

if cPecSrv == "P"
	
	if !Orcamento
		
		FG_Seek("SB1","M->VS3_GRUITE+M->VS3_CODITE",7,.f.)
		
		//		if cOpeMov2 == "2"
		//			if Empty(M->VS3_FORMUL)
		//				M->VS3_FORMUL := GETMV("MV_FMLPECA")
		//				if Type("M->VS3_FORMUL") <> "C"
		//					M->VS3_FORMUL := SPACE(LEN(VS3->VS3_FORMUL))
		//				Endif
		//			Endif
		//		Endif
		nValPec := FG_VALPEC(M->VS1_TIPTEM,"M->VS3_FORMUL",M->VS3_GRUITE,M->VS3_CODITE,"M->VS3_VALPEC",.f.,.t.)
		
		M->VS3_DESITE := SB1->B1_DESC  
 		aCols[n,FG_POSVAR("VS3_DESITE","aHeaderP")] := SB1->B1_DESC

		M->VS3_VALPEC := nValPec
		aCols[n,fg_posvar("VS3_VALPEC","aHeaderP")]   := nValPec            // Valor da Peca
		cFormAnt      := M->VS3_FORMUL
		cGruIte       := M->VS3_GRUITE  
		if ReadVar() <> "M->VS3_LOCAL"
			__ReadVar     := "M->VS3_CODITE"
	    Endif	
		lReturn       := FS_TOTPEC(cFormAnt)
		M->VS3_FORMUL := cFormAnt
		if ReadVar() <> "M->VS3_LOCAL"
			__ReadVar     := "M->VS3_FORMUL"
		Endif
	Endif
	
Else
	
	//	nTemPad       := int(FG_TEMPAD(VV1->VV1_CHAINT,M->VS4_CODSER,if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM))) / 100
	nTemPad       := FG_TEMPAD(VV1->VV1_CHAINT,M->VS4_CODSER,if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM),,M->VS1_CODMAR)
	M->VS4_TEMPAD := nTemPad
	
	nValHor       := If(VOK->VOK_INCMOB $ "0/2/5",0,FG_VALHOR(VOI->VOI_TIPTEM,dDataBase,,,VV1->VV1_CODMAR,M->VS4_CODSER,M->VS4_TIPSER,M->VS1_CLIFAT,M->VS1_LOJA))
	M->VS4_VALHOR := nValHor
	
	lReturn := FS_TOTSRV()
	
Endif

Return lReturn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_SALVAR  ³ Autor ³ Andre                 ³ Data ³ 20/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Salva Negociacao de Pagamentos                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Exclusivo                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SALVAR()

Local lAchou, i:=0 , j:=0

if lSalvou
	Return(.t.)
Endif

dbSelectArea("VS9")
OM110DELNEG() // Deleta toda a negociacao de entrada + financiamento + CDCI

dbSelectArea("VSE")
lAchou := dbSeek(xFilial("VSE")+"OR"+M->VS1_NUMORC+"B")
For i:=1 to Len(aGravaEnt)
	RecLock("VSE",!lAchou)
	VSE->VSE_FILIAL := xFilial("VSE")
	VSE->VSE_NUMIDE := "OR"+M->VS1_NUMORC
	VSE->VSE_TIPOPE := "B"
	VSE->VSE_SEQUEN := StrZero(aGravaEnt[i,1],2)
	VSE->VSE_TIPPAG := aGravaEnt[i,2]
	VSE->VSE_DESCCP := aGravaEnt[i,3]
	VSE->VSE_NOMECP := aGravaEnt[i,4]
	VSE->VSE_TIPOCP := aGravaEnt[i,5]
	VSE->VSE_TAMACP := aGravaEnt[i,6]
	VSE->VSE_DECICP := aGravaEnt[i,7]
	VSE->VSE_PICTCP := aGravaEnt[i,8]                                                        
	
	VSE->VSE_VALDIG := aGravaEnt[i,9]
Next

aMemos := Aclone(aMemos2)

lAchou := 0
For j:=1 to Len(aColsC)
	If !aColsC[j,Len(aColsC[j])] .and. !Empty(aColsC[j,1])
		dbSelectArea("VS9")
		dbSetOrder(1)
		if !dbSeek(xFilial("VS9")+"OR"+M->VS1_NUMORC+"     "+"B"+aColsC[j,FG_POSVAR("VS9_TIPPAG","aHeaderC")]+aColsC[j,FG_POSVAR('VS9_SEQUEN',"aHeaderC")])
			RecLock("VS9",.T.)
			Fg_Gravar("VS9",aColsC,aHeaderC,j)
			VS9->VS9_FILIAL := xFilial("VS9")
			VS9->VS9_NUMIDE := "OR"+M->VS1_NUMORC
			VS9->VS9_TIPOPE := "B"
			VS9->VS9_TIPPAG := aColsC[j,FG_POSVAR("VS9_TIPPAG","aHeaderC")]
			cVar := aMemos[1][2]
			MSMM(,TamSx3("VS9_OBSERV")[1],,&cVar,1,,,"VS9","VS9_OBSMEM")
			MsUnlock()
		Endif	
	Endif
Next

For i:=1 to Len(aIteParc)
	If !Empty(aIteParc[i,1])
		dbSelectArea("VS9")
		dbSetOrder(1)
		if !dbSeek(xFilial("VS9")+"OR"+M->VS1_NUMORC+"     "+"B"+"DP"+strzero(i,2))
			RecLock("VS9",.T.)
			VS9->VS9_FILIAL := xFilial("VS9")
			VS9->VS9_NUMIDE := "OR"+M->VS1_NUMORC
			VS9->VS9_TIPOPE := "B"
			VS9->VS9_TIPPAG := "DP"
	//		VS9->VS9_DESPAG := OemToAnsi(STR0136)//DUPLICATA
			VS9->VS9_DATPAG := DataValida(aIteParc[i,1])
			VS9->VS9_VALPAG := aIteParc[i,2]
			If VS1->(FieldPos("VS1_NATURE")) <> 0 .and. VS9->(FieldPos("VS9_NATURE")) <> 0
				VS9->VS9_NATURE := M->VS1_NATURE
			Endif
			if !Empty(cCondic1) .and. !Empty(cCondic3)
				VS9->VS9_REFPAG := alltrim(dtoc(cCondic1))+strzero(val(cCondic2),2)+strzero(val(cCondic3),3)+strzero(val(cCondic4),2)
			Endif
			VS9->VS9_SEQUEN := strzero(i,2)
			MsUnlock()    
		Endif	
	Endif
Next

dbSelectArea("VS9")

if !Empty(cCodCDCI) .and. nValorCom > 0
	RecLock("VS9",.T.)
	VS9->VS9_FILIAL := xFilial("VS9")
	VS9->VS9_NUMIDE := "CD"+M->VS1_NUMORC
	VS9->VS9_TIPOPE := "B"
	VS9->VS9_TIPPAG := "CD"
	VS9->VS9_DATPAG := dDataBase
	VS9->VS9_VALPAG := nValorCom
	VS9->VS9_REFPAG := cCodCDCI
	MsUnlock()
Endif

if ExistBlock("GRVNEG110")
	ExecBlock("GRVNEG110",.f.,.f.)
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_TOTPEC  ³ Autor ³ Andre/Emilton         ³ Data ³ 10/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Totaliza Pecas                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Exclusivo                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TOTPEC(cFormAnt)

Local Cont, _ni, i

Local lRetDes:= .t.
Local nSaldo := 0
Local y:=0
Local x := 0


Local nPos := 0
Default cFormAnt := ""

If FM_PILHA("OFIX") .or. FM_PILHA("OFIOM350") .or. FM_PILHA("OFIOM430") 
	Return(.t.)
EndIf
//if Left(Funname(),4) == "OFIX" .or. FunName() == "OFIOM350" .or. FunName() == "OFIOM430"
//	return .t.
//endif

FG_MEMVAR()

Do Case
	
	
	Case ReadVar() == "M->VS3_CODITE"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		SB1->(dbSetOrder(7))
		SB1->(dbSeek(xFilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE))
		
		//	   if SB1->B1_MSBLQL $ "1S"
		//   	   MsgInfo(STR0337 ,STR0148) //Este item esta Bloqueado... # Atencao...
		//   	   Return(.f.)
		//	   Endif
		
		SBM->(dbSetOrder(1))
		SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
		if SBM->BM_PROORI <> "1" .and. lRecompra
			MsgInfo( STR0339 ,STR0148) //"Este nao e um item original... # Atencao...
			Return(.f.)
		Endif
		
		If Empty(cFormAnt)
			//			if cOpeMov2 <> "2"
			M->VS3_FORMUL := M->VS1_FORMUL
			//			Else
			//				M->VS3_FORMUL := cFormul
			//			Endif
		Else
			M->VS3_FORMUL := cFormAnt
		EndIf
		aCols[n,FG_POSVAR("VS3_FORMUL","aHeaderP")] := M->VS3_FORMUL
		
		if cOpeMov2 == "1"
			aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")] := SB1->B1_TS
			M->VS3_CODTES := SB1->B1_TS
		Else
			SF4->(dbSetOrder(1))
			SF4->(dbSeek(xFilial("SF4")+SB1->B1_TS))
			dbSelectArea("VEL")
			dbSetOrder(1)
			if dbSeek(xFilial("VEL")+cCodOpe+Left(SB1->B1_ORIGEM,1)+SF4->F4_SITTRIB)
				cTesPad := VEL->VEL_TESESP
			Else
				dbSelectArea("VEB")
				if dbSeek(xFilial("VEB")+cCodOpe)
					cTesPad := VEB->VEB_TESPAD
				Endif
			Endif
			aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")] := cTesPad
			M->VS3_CODTES := cTesPad
		Endif
		
		MaFisRef("IT_PRODUTO","VS300",SB1->B1_COD)
		aCols[n,FG_POSVAR("VS3_CODITE","aHeaderP")] := M->VS3_CODITE
		
		if cOpeMov2 == "2"
			if Empty(M->VS3_FORMUL)
				M->VS3_FORMUL := GETMV("MV_FMLPECA")
				if Type("M->VS3_FORMUL") <> "C"
					M->VS3_FORMUL := SPACE(LEN(VS3->VS3_FORMUL))
				Endif
			Endif
		Endif
		nValPec := FG_VALPEC(M->VS1_TIPTEM,"M->VS3_FORMUL",M->VS3_GRUITE,M->VS3_CODITE,"M->VS3_VALPEC",.f.,.t.)
		if lErroFor
			MsgInfo(STR0340 ,STR0148) //Formula esta incorreta...`# Atencao!
		Endif
		
		FS_PROMOCAO(M->VS1_CODMAR,M->VS1_CENCUS,M->VS3_GRUITE,M->VS3_CODITE)
		
		aCols[n,FG_POSVAR("VS3_VALPEC","aHeaderP")] := nValPec
		MaFisRef("IT_TES","VS300",aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")])
		M->VS3_VALPEC := nValPec
		MaFisRef("IT_VALMERC","VS300",M->VS3_QTDITE*nValPec)
		
		//Desconto padrao cadastrado no VS1
		if aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")] == 0
			aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")] := M->VS1_PERPEC
		Endif
		M->VS3_PERDES := aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")]
		
		SBM->(dbSetOrder(1))
		SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
		FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,M->VS3_PERDES,,M->VS3_MODVEI)
		
		M->VS3_VALDES := ((M->VS3_VALPEC*M->VS3_QTDITE)/100)*M->VS3_PERDES
		M->VS3_VALTOT := (M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES
		
		aCols[n,FG_POSVAR("VS3_VALTOT","aHeaderP")] := M->VS3_VALTOT
		aCols[n,FG_POSVAR("VS3_VALDES","aHeaderP")] := M->VS3_VALDES
		
		MaFisRef("IT_DESCONTO","VS300",M->VS3_VALDES)
		
		if !Empty(SB1->B1_GRTRIB)
			MaFisRef("IT_GRPTRIB","VS300",SB1->B1_GRTRIB)
		Endif
		
		if !Empty(SB1->B1_GRTRIB) .or. SB1->B1_PICMENT > 0
			
			if SB1->B1_PICMENT > 0
				nAliSol  := SB1->B1_PICMENT
				nBaseSol := M->VS3_VALTOT+((M->VS3_VALTOT *nAliSol)/100)
				MaFisRef("IT_BASESOL","VS300",nBaseSol)
			Else
				dbSelectArea("SF7")
				dbSetOrder(1)
				if MsSeek(xFilial("SF7")+SB1->B1_GRTRIB+SA1->A1_GRPTRIB)
					while !EOF() .and. SF7->F7_GRTRIB == SB1->B1_GRTRIB
						if SF7->F7_GRPCLI == SA1->A1_GRPTRIB .and. SA1->A1_EST == SF7->F7_EST
							nBaseSol := M->VS3_VALTOT+((M->VS3_VALTOT *SF7->F7_MARGEM)/100)
							MaFisRef("IT_BASESOL","VS300",nBaseSol)
						Endif
						dbSelectArea("SF7")
						dbSkip()
					enddo
				Endif
			Endif
		Endif
		
		if Type("M->VS3_QTDEST") <> "U"
			nSaldo := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+LocIte110())
			M->VS3_QTDEST := nSaldo
			aCols[n,FG_POSVAR("VS3_QTDEST","aHeaderP")] := nSaldo
		Endif 
		if Empty(M->VS3_LOCAL)
			M->VS3_LOCAL :=  IIf(M->VS1_ORCACE$"1 ",SB1->B1_LOCPAD,GetMv("MV_RESITE"))
	    Endif
		aCols[n,FG_POSVAR("VS3_LOCAL","aHeaderP")] := M->VS3_LOCAL
		
		if Len(FS_KIT110()) = 0
			if ExistBlock("CHKPRO110")
				if !ExecBlock("CHKPRO110",.f.,.f.)
					Return(.f.)
				Endif
			Endif
		Endif
		
		FS_CONF110()
		
		FS_VIRTUAL()
		
	Case ReadVar() == "M->VS3_QTDITE"
		
		If Empty(M->VS1_CLIFAT+M->VS1_LOJA)
			aCols[n,fg_posvar("VS3_QTDITE","aHeaderP")] := M->VS3_QTDITE
			MsgStop(STR0249,STR0019)
			Return(.t.)
		EndIf
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		if M->VS3_QTDITE <> aCols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")]
			lJaMovPec := .f.
		Endif
		
		aCols[n,fg_posvar("VS3_QTDITE","aHeaderP")] := M->VS3_QTDITE
		
		wAlias := alias()
		
		FG_Seek("SB1","M->VS3_GRUITE+M->VS3_CODITE",7,.f.)
		nSaldo := FS_SALDOPEC(xFIlial("SB2")+SB1->B1_COD+LocIte110())
		if ExistBlock("CHKPRO110")
			if !ExecBlock("CHKPRO110",.f.,.f.)
				Return(.f.)
			Endif
		Endif
		
		SF4->(dbSeek(xFilial("SF4")+M->VS3_CODTES))
		//		if cOpeMov2 == "1" .or. SF4->F4_ESTOQUE == "S"
		if SF4->F4_ESTOQUE == "S"
			FS_QTDORC(M->VS3_QTDITE)
		Endif
		
		nPos := aScan(aIteBlq,{|x| x[1] == aCols[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
		FS_TRANSFER(nSaldo,M->VS3_QTDITE,nPos,aCols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")],.T.,n)
		if cOpeMov2 == "2"
			if Empty(M->VS3_FORMUL)
				M->VS3_FORMUL := GETMV("MV_FMLPECA")
				if Type("M->VS3_FORMUL") <> "C"
					M->VS3_FORMUL := SPACE(LEN(VS3->VS3_FORMUL))
				Endif
			Endif
		Endif
		nValPec := FG_VALPEC(M->VS1_TIPTEM,"M->VS3_FORMUL",M->VS3_GRUITE,M->VS3_CODITE,"M->VS3_VALPEC",.f.,.t.)
		if lErroFor
			MsgInfo(STR0340,STR0148) //Formula esta incorreta... # Atencao!
		EndIf
		
		if !Empty(M->VS3_CODTES) .and. !TipoTes(M->VS3_CODTES)
			MsgInfo(STR0341,STR0148) //Este item nao ira gerar movimentacao financeira... # Atencao!
		Endif
		
		dbSelectArea(wALias)
		
		FS_PROMOCAO(M->VS1_CODMAR,M->VS1_CENCUS,M->VS3_GRUITE,M->VS3_CODITE,.F.)
		
		aCols[n,FG_POSVAR("VS3_VALPEC","aHeaderP")] := nValPec
		MaFisRef("IT_TES","VS300",aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")])
		M->VS3_VALPEC := nValPec
		MaFisRef("IT_VALMERC","VS300",nValPec*M->VS3_QTDITE)
		
		//Desconto padrao cadastrado no VS1
		if aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")] == 0
			aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")] := M->VS1_PERPEC
		Endif
		M->VS3_PERDES := aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")]
		
		if GetMv("MV_ARREFAT") == "S"
			nQtdade := M->VS3_QTDITE
			nValDes := Val(Transform(((M->VS3_VALPEC*nQtdade)/100)*M->VS3_PERDES,"999999999.99"))
			nValDes := Val(Transform(Val(str((nValDes/nQtdade),12,2))*nQtdade,"999999999.99"))
			M->VS3_VALDES := Val(str(nValDes,12,2))
			M->VS3_PERDES := Val(Transform((M->VS3_VALDES*100)/(M->VS3_VALPEC*nQtdade),"999999999.99"))
			M->VS3_VALTOT := Val(Transform((M->VS3_VALPEC*nQtdade)-M->VS3_VALDES,"999999999.99"))
		Else
			nQtdade := M->VS3_QTDITE
			nValDes := NoRound(((M->VS3_VALPEC*nQtdade)/100)*M->VS3_PERDES,2)
			nValDes := NoRound(((nValDes/nQtdade)*nQtdade),2)
			M->VS3_VALDES := NoRound(nValDes,2)
			M->VS3_PERDES := NoRound((M->VS3_VALDES*100)/(M->VS3_VALPEC*nQtdade),2)
			M->VS3_VALTOT := NoRound((M->VS3_VALPEC*nQtdade)-M->VS3_VALDES,2)
		Endif
		
		SBM->(dbSetOrder(1))
		SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
		FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,M->VS3_PERDES,,M->VS3_MODVEI)
		MaFisRef("IT_DESCONTO","VS300",M->VS3_VALDES)
		
		aCols[n,fg_posvar("VS3_PERDES","aHeaderP")] := M->VS3_PERDES
		aCols[n,fg_posvar("VS3_VALDES","aHeaderP")] := M->VS3_VALDES
		aCols[n,fg_posvar("VS3_VALTOT","aHeaderP")] := M->VS3_VALTOT
		
		if !Empty(aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")])
			MaFisalt("IT_TES",aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")],n)
		Endif

		if M->VS1_TIPORC != "2" 	
			if M->VS3_QTDITE < SB1->B1_LOTVEN .and. SB1->B1_LOTVEN > 0
				MsgInfo("Quantidade insuficiente para venda do lote minimo ("+Alltrim(STR(SB1->B1_LOTVEN))+"). Verifique o Lote de Venda no cadastro do Produto.","Atencao")
				return .f.
			endif
		endif
		
		FS_CONF110()
		
		lJaGravou := .f.
		
	Case ReadVar() == "M->VS3_FORMUL"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		if VEG->VEG_GRUFOR # cGruFor
			Return .f.
		Endif
		
		wAlias := alias()
		
		if !FG_GRUPOFOR(cGruIte,M->VS3_FORMUL)
			Return .f.
		Endif
		
		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek(xFilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE)
		
		if cOpeMov2 == "2"
			if Empty(M->VS3_FORMUL)
				M->VS3_FORMUL := GETMV("MV_FMLPECA")
				if Type("M->VS3_FORMUL") <> "C"
					M->VS3_FORMUL := SPACE(LEN(VS3->VS3_FORMUL))
				Endif
			Endif
		Endif
		nValPec := FG_VALPEC(M->VS1_TIPTEM,"M->VS3_FORMUL",M->VS3_GRUITE,M->VS3_CODITE,"M->VS3_VALPEC",.f.,.t.)
		if lErroFor
			MsgInfo(STR0340,STR0148) //Formula esta incorreta... # Atencao!
		Endif
		
		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek(xFilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE)
		
		/// Verifica Custo dos Itens
		// Manoel - 26/05/2009
		SF4->(dbseek(xFilial("SF4")+M->VS3_CODTES))
		If GetNewPar("MV_LIBVAC","N") == "N" .and. SF4->F4_OPEMOV == "05"  //VENDA
			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek(xFilial("SB2")+SB1->B1_COD)
			nSdoPecB2 := 0
			While !eof() .and. SB1->B1_FILIAL+SB1->B1_COD == SB2->B2_FILIAL+SB2->B2_COD
				nSdoPecB2 += SB2->B2_QATU
				dbSkip()
			Enddo
			DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
			If Round(nValPec,2) < Round(SB2->B2_CM1,2) .and. nSdoPecB2 > 0
				MsgStop(STR0525)
				Return .f.
			Endif
		Endif
		
		dbSelectArea(wALias)
		
		if aCols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")] == 0
			MsgInfo(STR0151,STR0148)
			Return .f.
		Endif
		if aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")] == 0
			aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")] := M->VS1_PERPEC
		Endif
		
		MaFisRef("IT_VALMERC","VS300",M->VS3_QTDITE*nValPec)
		MaFisRef("IT_TES","VS300",aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")])
		
		SBM->(dbSetOrder(1))
		SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
		FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,M->VS3_PERDES,,M->VS3_MODVEI)
		
		if GetMv("MV_ARREFAT") == "S"
			M->VS3_VALDES := Round(((M->VS3_VALPEC*M->VS3_QTDITE)/100)*M->VS3_PERDES,2)
			M->VS3_VALTOT := Round((M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES,2)
		Else
			M->VS3_VALDES := NoRound(((M->VS3_VALPEC*M->VS3_QTDITE)/100)*M->VS3_PERDES,2)
			M->VS3_VALTOT := NoRound((M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES,2)
		Endif
		
		aCols[n,fg_posvar("VS3_PERDES","aHeaderP")] := M->VS3_PERDES
		aCols[n,fg_posvar("VS3_VALDES","aHeaderP")] := M->VS3_VALDES
		aCols[n,fg_posvar("VS3_VALTOT","aHeaderP")] := M->VS3_VALTOT
		
		MaFisRef("IT_DESCONTO","VS300",M->VS3_VALDES)
		
		aCols[n,FG_POSVAR("VS3_VALDES","aHeaderP")] := M->VS3_VALDES
		
	Case ReadVar() == "M->VS3_PERDES"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		if M->VS3_PERDES < 0 .or. M->VS3_PERDES > 99.99
			Return .f.
		Endif
		
		//    Manoel - 15/05/2009
		//		M->VS3_PERDES += 0.005 // Soma o valor 0.005 para conseguir fazer o calculo correto.
		
		dbSelectArea("VEN")
		dbSetOrder(2)
		if dbSeek(xFilial("VEN")+M->VS1_CODMAR+M->VS1_CENCUS+M->VS3_GRUITE+M->VS3_CODITE)
			if dDataBase >= VEN->VEN_DATINI .and. dDataBase <= VEN->VEN_DATFIN
				if VEN->VEN_VALPRO > 0
					MsgInfo(STR0342 ,STR0148) //Nao pode ser dado desconto para produto com preco em promocao  # Atencao!
					Return .f.
				Endif
			Endif
		Endif
		
		if aCols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")] == 0
			MsgInfo(STR0151,STR0148)
			Return .f.
		Endif
		if GetMv("MV_ARREFAT") == "S"
			nQtdade := aCols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")]
			nValDes := Val(Transform(((M->VS3_VALPEC*M->VS3_QTDITE)/100)*M->VS3_PERDES,"999999999.99"))
			nValDes := Val(Transform((NoRound(nValDes/nQtdade,2))*nQtdade,"999999999.99"))
			M->VS3_VALDES := nValDes
			M->VS3_PERDES := Val(Transform((M->VS3_VALDES*100)/(M->VS3_VALPEC*M->VS3_QTDITE),"999999999.99"))
			M->VS3_VALTOT := Val(Transform((M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES,"999999999.99"))
		Else
			nQtdade := aCols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")]
			nValDes := NoRound(((M->VS3_VALPEC*M->VS3_QTDITE)/100)*M->VS3_PERDES,2)
			nValDes := NoRound(((nValDes/nQtdade)*nQtdade),2)
			M->VS3_VALDES := NoRound(nValDes,2)
			M->VS3_PERDES := NoRound((M->VS3_VALDES*100)/(M->VS3_VALPEC*M->VS3_QTDITE),2)
			M->VS3_VALTOT := NoRound((M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES,2)
		Endif
		
		SBM->(dbSetOrder(1))
		SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
		lRetDes := FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,M->VS3_PERDES,,M->VS3_MODVEI)
		if !lRetDes
			if GetMv("MV_PLIBDMP") == "N"
				Return .f.
			Endif
		Endif
		
		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek(xFilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE)
		
		/// Verifica Custo dos Itens
		// Manoel - 26/05/2009
		SF4->(dbseek(xFilial("SF4")+M->VS3_CODTES))
		If GetNewPar("MV_LIBVAC","N") == "N" .and. SF4->F4_OPEMOV == "05"  //VENDA
			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek(xFilial("SB2")+SB1->B1_COD)
			nSdoPecB2 := 0
			While !eof() .and. SB1->B1_FILIAL+SB1->B1_COD == SB2->B2_FILIAL+SB2->B2_COD
				nSdoPecB2 += SB2->B2_QATU
				dbSkip()
			Enddo
			DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
			If Round(nValPec,2) < Round(SB2->B2_CM1,2) .and. nSdoPecB2 > 0
				MsgStop(STR0525)
				Return .f.
			Endif
		Endif
		
		aCols[n,fg_posvar("VS3_PERDES","aHeaderP")] := M->VS3_PERDES
		aCols[n,fg_posvar("VS3_VALDES","aHeaderP")] := M->VS3_VALDES
		aCols[n,fg_posvar("VS3_VALTOT","aHeaderP")] := M->VS3_VALTOT
		MaFisRef("IT_DESCONTO","VS300",M->VS3_VALDES)
		
	Case ReadVar() == "M->VS3_VALDES"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		if M->VS3_VALDES < 0 .or. M->VS3_VALDES > M->VS3_VALTOT
			Return .f.
		Endif
		
		if aCols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")] == 0
			MsgInfo(STR0151,STR0148)
			Return .f.
		Endif
		
		if !Empty(M->VS3_CODTES) .and. !TipoTes(M->VS3_CODTES)
			MsgInfo(STR0343 ,STR0148) //Desconto nao permitido, este item nao esta gerando movimentacao financeira # Atencao!
			Return .f.
		Endif
		
		dbSelectArea("VEN")
		dbSetOrder(2)
		if dbSeek(xFilial("VEN")+M->VS1_CODMAR+M->VS1_CENCUS+M->VS3_GRUITE+M->VS3_CODITE)
			if dDataBase >= VEN->VEN_DATINI .and. dDataBase <= VEN->VEN_DATFIN
				if VEN->VEN_VALPRO > 0
					MsgInfo(STR0342 ,STR0148) //Nao pode ser dado desconto para produto com preco em promocao # Atencao!
					Return .f.
				Endif
			Endif
		Endif
		
		if GetMv("MV_ARREFAT") == "S"
			nQtdade := aCols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")]
			nValDes := M->VS3_VALDES
			nValDes := Val(Transform(Val(Transform((nValDes/nQtdade),"999999999.99"))*nQtdade,"999999999.99"))
			M->VS3_VALDES := Val(Transform(nValDes,"999999999.99"))
			M->VS3_PERDES := Val(Transform((M->VS3_VALDES*100)/(M->VS3_VALPEC*M->VS3_QTDITE),"999999999.99"))
			M->VS3_VALTOT := Val(Transform((M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES,"999999999.99"))
		Else
			nQtdade := aCols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")]
			nValDes := M->VS3_VALDES
			nValDes := NoRound(((nValDes/nQtdade)*nQtdade),2)
			M->VS3_VALDES := NoRound(nValDes,2)
			M->VS3_PERDES := NoRound((M->VS3_VALDES*100)/(M->VS3_VALPEC*M->VS3_QTDITE),2)
			M->VS3_VALTOT := NoRound((M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES,2)
		Endif
		
		M->VS3_PERDES := Val(Transform((M->VS3_VALDES*100)/(M->VS3_VALPEC*M->VS3_QTDITE),"999999999.99"))
		M->VS3_VALTOT := Val(Transform((M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES,"999999999.99"))
		
		SBM->(dbSetOrder(1))
		SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
		lRetDes := FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,M->VS3_PERDES,,M->VS3_MODVEI)
		if !lRetDes
			if GetMv("MV_PLIBDMP") == "N"
				Return .f.
			Endif
		Endif
		
		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek(xFilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE)
		
		/// Verifica Custo dos Itens
		// Manoel - 26/05/2009
		SF4->(dbseek(xFilial("SF4")+M->VS3_CODTES))
		If GetNewPar("MV_LIBVAC","N") == "N" .and. SF4->F4_OPEMOV == "05"  //VENDA
			DbSelectArea("SB2")
			DbSetOrder(1)
			DbSeek(xFilial("SB2")+SB1->B1_COD)
			nSdoPecB2 := 0
			While !eof() .and. SB1->B1_FILIAL+SB1->B1_COD == SB2->B2_FILIAL+SB2->B2_COD
				nSdoPecB2 += SB2->B2_QATU
				dbSkip()
			Enddo
			DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
			If Round(nValPec,2) < Round(SB2->B2_CM1,2) .and. nSdoPecB2 > 0
				MsgStop(STR0525)
				Return .f.
			Endif
		Endif
		
		MaFisRef("IT_DESCONTO","VS300",M->VS3_VALDES)
		
		aCols[n,fg_posvar("VS3_PERDES","aHeaderP")] := M->VS3_PERDES
		aCols[n,fg_posvar("VS3_VALDES","aHeaderP")] := M->VS3_VALDES
		aCols[n,fg_posvar("VS3_VALTOT","aHeaderP")] := M->VS3_VALTOT
		
	Case ReadVar() == "M->VS3_CODTES"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		if Val(M->VS3_CODTES) < 500
			nOp  := Aviso( STR0344 , STR0345, { STR0028 } )//TES Incorreto # O TES informado nao e um TES de saida # ok
			Return .f.
		Endif
		
		if SF4->(dbSeek(xFilial("SF4")+M->VS3_CODTES))
			lIntNF := .t.
			if ExistBlock("INTNFBAL")
				lIntNF := ExecBlock("INTNFBAL",.f.,.f.)
			Endif
			if lIntNF
				if SF4->F4_ESTOQUE == "N"
					nOp  := Aviso( STR0346 , STR0347, { STR0028 , STR0323 } )//Nao Movimenta Estoque # O TES informado nao movimenta estoque #   ok # Cancelar
					if nOp == 2
						Return .f.
					Endif
				Endif
			Endif
		Else
			nOp  := Aviso( STR0348 , STR0349, { STR0028 } )//Nao Encontrado # O TES informado nao foi encontrado no cadastro # ok
		Endif
		
		wAlias := alias()
		
		FG_Seek("SB1","M->VS3_GRUITE+M->VS3_CODITE",7,.f.)
		
		if cOpeMov2 == "2"
			if Empty(M->VS3_FORMUL)
				M->VS3_FORMUL := GETMV("MV_FMLPECA")
				if Type("M->VS3_FORMUL") <> "C"
					M->VS3_FORMUL := SPACE(LEN(VS3->VS3_FORMUL))
				Endif
			Endif
		Endif
		nValPec := FG_VALPEC(M->VS1_TIPTEM,"M->VS3_FORMUL",M->VS3_GRUITE,M->VS3_CODITE,"M->VS3_VALPEC",.f.,.t.)
		if lErroFor
			MsgInfo(STR0340 ,STR0148) //Formula esta incorreta... # Atencao!
		Endif
		
		dbSelectArea(wALias)
		
		// Desconto padrao cadastrado no VS1
		if aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")] == 0
			aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")] := M->VS1_PERPEC
		Endif
		
		MaFisRef("IT_VALMERC","VS300",M->VS3_QTDITE*nValPec)
		MaFisRef("IT_TES","VS300",M->VS3_CODTES)
		
		M->VS3_VALDES := ((M->VS3_VALPEC*M->VS3_QTDITE)/100)*M->VS3_PERDES
		M->VS3_VALTOT := (M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES
		
		SBM->(dbSetOrder(1))
		SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
		FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,M->VS3_PERDES,,M->VS3_MODVEI)
		MaFisRef("IT_DESCONTO","VS300",M->VS3_VALDES)
		
		aCols[n,fg_posvar("VS3_PERDES","aHeaderP")] := M->VS3_PERDES
		aCols[n,fg_posvar("VS3_VALDES","aHeaderP")] := M->VS3_VALDES
		aCols[n,fg_posvar("VS3_VALTOT","aHeaderP")] := M->VS3_VALTOT
		
		if !TipoTes(M->VS3_CODTES)
			MsgInfo(STR0341 ,STR0148) //Este item nao ira gerar movimentacao financeira... # Atencao!
		Endif
		
	Case ReadVar() == "M->VS3_VALPEC"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		wAlias := alias()
		
		FG_Seek("SB1","M->VS3_GRUITE+M->VS3_CODITE",7,.f.)
		
		if cOpeMov2 == "2"
			if Empty(M->VS3_FORMUL)
				M->VS3_FORMUL := GETMV("MV_FMLPECA")
				if Type("M->VS3_FORMUL") <> "C"
					M->VS3_FORMUL := SPACE(LEN(VS3->VS3_FORMUL))
				Endif
			Endif
		Endif
		
		nValtmp := 0
		FG_VALPEC(M->VS1_TIPTEM,"M->VS3_FORMUL",M->VS3_GRUITE,M->VS3_CODITE,"nValTmp",.f.,.t.)
		//		nValTmp := FS_PROMOCAO(M->VS1_CODMAR,M->VS1_CENCUS,M->VS3_GRUITE,M->VS3_CODITE,.F.,.F.)
		
		if cOpeMov2 <> "2" .and. !lRecompra
			if M->VS3_VALPEC < nValTmp
				Return .f.
			Endif
		Endif
		
		dbSelectArea(wALias)
		
		nValPec := M->VS3_VALPEC
		
		aCols[n,FG_POSVAR("VS3_VALPEC","aHeaderP")] := nValPec
		MaFisRef("IT_TES","VS300",aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")])
		MaFisRef("IT_VALMERC","VS300",M->VS3_QTDITE*nValPec)
		
		//Desconto padrao cadastrado no VS1
		if aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")] == 0
			aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")] := M->VS1_PERPEC
		Endif
		
		M->VS3_PERDES := aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")]
		M->VS3_VALDES := ((M->VS3_VALPEC*M->VS3_QTDITE)/100)*M->VS3_PERDES
		M->VS3_VALTOT := (M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES
		
		SBM->(dbSetOrder(1))
		SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
		FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,M->VS3_PERDES,,M->VS3_MODVEI)
		MaFisRef("IT_DESCONTO","VS300",M->VS3_VALDES)
		
		aCols[n,fg_posvar("VS3_PERDES","aHeaderP")] := M->VS3_PERDES
		aCols[n,fg_posvar("VS3_VALDES","aHeaderP")] := M->VS3_VALDES
		aCols[n,fg_posvar("VS3_VALTOT","aHeaderP")] := M->VS3_VALTOT
		
	Case ReadVar() == "M->VS3_LOCAL"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		if GetMv("MV_CQ") == M->VS3_LOCAL
			MsgInfo( STR0350 +" "+M->VS3_LOCAL+" "+ STR0351 ,STR0148) //Armazem # reservado para Controle de Qualidade! #  Atencao!
			Return .f.
		Endif
		
		if Type("M->VS3_QTDEST") <> "U"
			nSaldo := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+LocIte110())
			M->VS3_QTDEST := nSaldo
			aCols[n,FG_POSVAR("VS3_QTDEST","aHeaderP")] := nSaldo
			aColsP := Aclone(aCols)
			oGetPecas:oBrowse:Refresh()
		Endif
		
		FS_CONF110()
		
		if M->VS3_LOCAL <> aCols[n,FG_POSVAR("VS3_LOCAL","aHeaderP")]
			lJaMovPec := .f.
		Endif
		
	Case ReadVar() == "M->VS3_ITESUB"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		dbSelectArea("VE4")
		dbSeek(xFilial("VE4"))
		if RecCount() > 1
			If !(dbSeek(xFilial("VE4")+M->VS1_CODMAR))
				Help(" ",1,"NAOPARFAB")
				Return(.f.)
			EndIf
		Endif
		if Len(Alltrim(M->VS3_ITESUB)) <> VE4->VE4_TAMCOD
			cCod := Right(StrZero(0,VE4->VE4_TAMCOD)+(alltrim(M->VS3_ITESUB)),8)
			M->VS3_ITESUB := cCod
			aCols[n,fg_posvar("VS3_ITESUB","aHeaderP")] := cCod
		Endif
		
	Case ReadVar() == "M->VS1_PERDES"
		
		if M->VS1_PERDES < 0 .or. M->VS1_PERDES > 99.99
			Return .f.
		Endif
		
		M->VS1_DESCON := 0
		
		nValor  := 0
		aCols   := aClone(aColsP)
		aHeader := aClone(aHeaderP)
		
		For cont := 1 to Len(aCols)
			if !aCols[cont,len(aCols[cont])]
				if aCols[cont,FG_POSVAR("VS3_QTDITE","aHeaderP")] == 0
					MsgInfo(STR0151,STR0148)
					Return .f.
				Endif
				
				M->VS3_GRUITE := aCols[cont,fg_posvar("VS3_GRUITE")]
				M->VS3_CODITE := aCols[cont,fg_posvar("VS3_CODITE")]
				M->VS3_FORMUL := aCols[cont,fg_posvar("VS3_FORMUL")]
				M->VS3_MODVEI := aCols[cont,fg_posvar("VS3_MODVEI")]
				
				M->VS3_VALPEC := aCols[cont,fg_posvar("VS3_VALPEC")]
				M->VS3_QTDITE := aCols[cont,fg_posvar("VS3_QTDITE")]
				M->VS3_PERDES := M->VS1_PERDES
				aCols[cont,FG_POSVAR("VS3_PERDES")] := M->VS1_PERDES
				
				n := cont
				if GetMv("MV_ARREFAT") == "S"
					nQtdade := aCols[cont,FG_POSVAR("VS3_QTDITE","aHeaderP")]
					nValDes := Val(Transform(((M->VS3_VALPEC*M->VS3_QTDITE)/100)*M->VS3_PERDES,"999999999.99"))
					nValDes := Val(Transform((NoRound(nValDes/nQtdade,2))*nQtdade,"999999999.99"))
					M->VS3_VALDES := nValDes
					M->VS3_PERDES := Val(Transform((M->VS3_VALDES*100)/(M->VS3_VALPEC*M->VS3_QTDITE),"999999999.99"))
					M->VS3_VALTOT := Val(Transform((M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES,"999999999.99"))
				Else
					nQtdade := aCols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")]
					nValDes := NoRound(((M->VS3_VALPEC*M->VS3_QTDITE)/100)*M->VS3_PERDES,2)
					nValDes := NoRound(((nValDes/nQtdade)*nQtdade),2)
					M->VS3_VALDES := NoRound(nValDes,2)
					M->VS3_PERDES := NoRound((M->VS3_VALDES*100)/(M->VS3_VALPEC*M->VS3_QTDITE),2)
					M->VS3_VALTOT := NoRound((M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES,2)
				Endif
				
				SBM->(dbSetOrder(1))
				SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
				lRetDes := FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,M->VS3_PERDES,,M->VS3_MODVEI)
				if !lRetDes
					if GetMv("MV_PLIBDMP") == "N"
						Return .f.
					Endif
				Endif
				
				aCols[n,fg_posvar("VS3_PERDES","aHeaderP")] := M->VS3_PERDES
				aCols[n,fg_posvar("VS3_VALDES","aHeaderP")] := M->VS3_VALDES
				aCols[n,fg_posvar("VS3_VALTOT","aHeaderP")] := M->VS3_VALTOT
				MaFisAlt("IT_DESCONTO",M->VS3_VALDES,n)
				
				nValor += M->VS3_VALDES
				
			Endif
		Next
		
		aColsP   := aClone(aCols)
		aHeaderP := aClone(aHeader)
		
		n := len(aColsP)
		oFolder2:nOption := 1
		
		oGetPecas:oBrowse:Refresh()
		oGetPecas:oBrowse:SetFocus()
		
	Case ReadVar() == "M->VS1_DESCON"
		
		if M->VS1_DESCON < 0
			Return .f.
		Endif
		
		//		if M->VS1_DESCON > 0
		
		M->VS1_PERDES := 0
		
		aCols   := aClone(aColsP)
		aHeader := aClone(aHeaderP)
		nDesconto   := M->VS1_DESCON
		nValResto   := nDesconto
		nMaiorValor := 0
		
		For i:=1 to Len(aCols)
			if !TipoTes(aCols[i,FG_POSVAR("VS3_CODTES","aHeaderP")])
				Loop
			Endif
			n := i
			
			M->VS3_GRUITE := aCols[i,fg_posvar("VS3_GRUITE")]
			M->VS3_CODITE := aCols[i,fg_posvar("VS3_CODITE")]
			M->VS3_FORMUL := aCols[i,fg_posvar("VS3_FORMUL")]
			M->VS3_MODVEI := aCols[i,fg_posvar("VS3_MODVEI")]
			
			M->VS3_VALPEC := aCols[i,fg_posvar("VS3_VALPEC","aHeaderP")]
			M->VS3_QTDITE := aCols[i,fg_posvar("VS3_QTDITE","aHeaderP")]
			M->VS3_VALTOT := aCols[i,fg_posvar("VS3_VALTOT","aHeaderP")]
			
			nPerIte  := (M->VS3_VALTOT / nTotOrc) * 100
			nValDesc := val(str(((nDesconto / 100) * nPerIte)/M->VS3_QTDITE,12,2)) * M->VS3_QTDITE
			
			if nValResto = 0
				nValDesc := 0
			Elseif nValResto < nValDesc
				nValDesc  := nValResto
				nValResto := 0
			Endif
			
			aCols[i,fg_posvar("VS3_VALDES","aHeaderP")] := nValDesc
			M->VS3_VALDES := aCols[i,fg_posvar("VS3_VALDES","aHeaderP")]
			aCols[i,FG_POSVAR("VS3_PERDES","aHeaderP")] := (M->VS3_VALDES / (M->VS3_VALPEC * M->VS3_QTDITE)) * 100
			M->VS3_PERDES := aCols[i,fg_posvar("VS3_PERDES","aHeaderP")]
			aCols[i,FG_POSVAR("VS3_VALTOT","aHeaderP")] := (M->VS3_VALPEC * M->VS3_QTDITE ) - M->VS3_VALDES
			
			SBM->(dbSetOrder(1))
			SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
			lRetDes := FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,M->VS3_PERDES,,M->VS3_MODVEI)
			if !lRetDes
				if GetMv("MV_PLIBDMP") == "N"
					Return .f.
				Endif
			Endif
			
			if nValResto > 0
				nValResto -= nValDesc
				if aCols[i,fg_posvar("VS3_VALTOT","aHeaderP")] > nMaiorValor
					nMaiorValor := aCols[i,fg_posvar("VS3_VALTOT","aHeaderP")]
					y := i
				Endif
			Endif
			
			nTotDes += nValDesc
			nTotOrc -= nValDesc
			
			MaFisAlt("IT_DESCONTO",M->VS3_VALDES,n)
			
		Next
		
		aColsP   := aClone(aCols)
		aHeaderP := aClone(aHeader)
		
		n := len(aColsP)
		oFolder2:nOption := 1
		
		oGetPecas:oBrowse:Refresh()
		oGetPecas:oBrowse:SetFocus()
		
		//		Endif
		
	Case ReadVar() == "M->VS1_DESACE"
		
		nTotOrc += M->VS1_DESACE
		nTotTit += M->VS1_DESACE
		
	Case ReadVar() == "M->VS1_VALFRE"
		
		nTotOrc += M->VS1_VALFRE
		nTotTit += M->VS1_VALFRE
		
	Case ReadVar() == "M->VS1_VALSEG"
		
		nTotOrc += M->VS1_VALSEG
		nTotTit += M->VS1_VALSEG
		
	Case ReadVar() == "M->VS1_ORCACE"
		
		For y:=1 to Len(aCols)
			dbSelectArea("SB1")
			dbSetOrder(7)
			dbSeek(xFilial("SB1")+aColsP[y,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[y,FG_POSVAR("VS3_CODITE","aHeaderP")])
			M->VS3_LOCAL :=  IIf(M->VS1_ORCACE$"1 ",SB1->B1_LOCPAD,GetMv("MV_RESITE"))
			aCols[y,FG_POSVAR("VS3_LOCAL","aHeaderP")] := M->VS3_LOCAL
		Next
		aColsP := Aclone(aCols)
		oGetPecas:oBrowse:Refresh()
		
	Case !aCols[n,Len(aCols[n])]
		for i := 1 to Len(aheader)
			if "Grupo" $ aheader[i,1]
				nPosGrp := i
			Endif
			if "Codigo" $ aheader[i,1]
				nPosCod := i
			Endif
		Next
		
		//	    nPos1 := aScan(aCols,{|x| x[nPosGrp]+x[nPosCod] == aColsP[n,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[n,FG_POSVAR("VS3_CODITE","aHeaderP")]})
		//		if nPos1 > 0
		nAchou := 0
		For y := 1 to Len(aCols)
			if y <> n
				if !aCols[y,Len(aCols[y])] .and. aCols[y,nPosGrp]+aCols[y,nPosCod] == aColsP[n,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[n,FG_POSVAR("VS3_CODITE","aHeaderP")]
					nAchou := 1
				Endif
			Endif
		Next
		if nAchou == 1
			MSGStop(STR0112)  //"Peca ja lancada no Orcamento, Revise"
			aCols[n,Len(aCols[n])] := .t.
			oGetPecas:oBrowse:Refresh()
			
			Return(.f.)
		EndIf
		//	Endif
		nPos:= aScan(aIteBlq,{|x| x[1] == aColsP[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
		if nPos <> 0
			if lJaGravou
				aIteBlq[nPos,4] := "N" //havia sido transferido anteriormente
				lJaMovPec := .f.
			Endif
		Endif
		
		//	For y:=1 to Len(aCols)
		//	   nPos := aScan(aIteD,{|x| x[1]+x[2] == aCols[y,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aCols[y,FG_POSVAR("VS3_CODITE","aHeaderP")]})
		//		If nPos == 0
		//	      aadd(aIteD,{aCols[y,FG_POSVAR("VS3_GRUITE","aHeaderP")],aCols[y,FG_POSVAR("VS3_CODITE","aHeaderP")],0,aCols[y,Len(aCols[y])] })
		//      ElseIf !aCols[y,Len(aCols[y])]
		// 			aIteD[nPos,3] += 1
		//      Endif
		//	Next
		//	If aIteD[1,3] > 0
		//		MSGStop(STR0112)  //"Peca ja lancada no Orcamento, Revise"
		//		oGetPecas:oBrowse:Refresh()
		///		Return(.f.)
		// /	EndIf
		
		wAlias := alias()
		
		FG_MEMVAR()
		
		FG_Seek("SB1","M->VS3_GRUITE+M->VS3_CODITE",7,.f.)
		
		if cOpeMov2 == "2"
			if Empty(M->VS3_FORMUL)
				M->VS3_FORMUL := GETMV("MV_FMLPECA")
				if Type("M->VS3_FORMUL") <> "C"
					M->VS3_FORMUL := SPACE(LEN(VS3->VS3_FORMUL))
				Endif
			Endif
		Endif
		nValPec := FG_VALPEC(M->VS1_TIPTEM,"M->VS3_FORMUL",M->VS3_GRUITE,M->VS3_CODITE,"M->VS3_VALPEC",.f.,.t.)
		if lErroFor
			MsgInfo(STR0340 ,STR0148)//Formula esta incorreta... # atencao!
		Endif
		
		dbSelectArea(wALias)
		
		aCols[n,FG_POSVAR("VS3_VALPEC","aHeaderP")] := nValPec
		MaFisRef("IT_TES","VS300",aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")])
		M->VS3_VALPEC := nValPec
		MaFisRef("IT_VALMERC","VS300",M->VS3_QTDITE*nValPec)
		
		//Desconto padrao cadastrado no VS1
		if aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")] == 0
			aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")] := M->VS1_PERPEC
		Endif
		
		M->VS3_PERDES := aCols[n,FG_POSVAR("VS3_PERDES","aHeaderP")]
		M->VS3_VALDES := ((M->VS3_VALPEC*M->VS3_QTDITE)/100)*M->VS3_PERDES
		M->VS3_VALTOT := (M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES
		
		SBM->(dbSetOrder(1))
		SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
		FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,M->VS3_PERDES,,M->VS3_MODVEI)
		MaFisRef("IT_DESCONTO","VS300",M->VS3_VALDES)
		
		aCols[n,fg_posvar("VS3_PERDES","aHeaderP")] := M->VS3_PERDES
		aCols[n,fg_posvar("VS3_VALDES","aHeaderP")] := M->VS3_VALDES
		aCols[n,fg_posvar("VS3_VALTOT","aHeaderP")] := M->VS3_VALTOT
		oGetPecas:oBrowse:Refresh()
	Case aCols[n,Len(aCols[n])]
		If M->VS1_ALTORC == "0"
			aCols[n,Len(aCols[n])] := .f.
			Return .t.
		Endif
		aCols[n,fg_posvar("VS3_PERDES","aHeaderP")] := 0
		aCols[n,fg_posvar("VS3_VALDES","aHeaderP")] := 0
		aCols[n,fg_posvar("VS3_VALTOT","aHeaderP")] := aCols[n,FG_POSVAR("VS3_VALPEC","aHeaderP")]*aCols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")]
		M->VS3_CODITE := Space(27)
		
		nPos:= aScan(aIteBlq,{|x| x[1] == aColsP[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
		if nPos <> 0
			if lJaGravou
				aIteBlq[nPos,4] := "S" //havia sido transferido anteriormente
				lJaMovPec := .f.
			Endif
		Endif
		MaFisalt("IT_VALMERC",0,n)
		oGetPecas:oBrowse:Refresh()
EndCase

nVlrTot := 0
M->VS1_DESCON := M->VS1_VALDES := 0
For _ni := 1 to len(aCols)
	If !aCols[_ni,Len(aCols[_ni])] .and. fg_posvar("VS3_VALPEC","aHeaderP") > 0 .and. fg_posvar("VS3_QTDITE","aHeaderP") > 0
		M->VS1_DESCON += aCols[_ni,fg_posvar("VS3_VALDES","aHeaderP")]
		nVlrTot += aCols[_ni,fg_posvar("VS3_VALPEC","aHeaderP")]*aCols[_ni,fg_posvar("VS3_QTDITE","aHeaderP")]
	EndIf
Next
For _ni := 1 to len(aColsS)
	If !aColsS[_ni,Len(aColsS[_ni])] .and. fg_posvar("VS4_VALDES","aHeaderS") > 0
		M->VS1_DESCON += aColsS[_ni,fg_posvar("VS4_VALDES","aHeaderS")]
		nVlrTot += aColsS[_ni,fg_posvar("VS4_VALSER","aHeaderS")]
	EndIf
Next
M->VS1_VALDES := M->VS1_DESCON
M->VS1_PERDES := val(str(( M->VS1_VALDES / nVlrTot ) * 100,12,2))
oGetMGet:Refresh()

FS_CALCVAL("N",.t.)

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_TOTSRV  ³ Autor ³ Emilton               ³ Data ³ 10/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Totaliza Servicos                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Exclusivo                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TOTSRV()
Local nwnk := 0
Local _ni := 0
Local lVO6_VALSER := VO6->(FieldPos("VO6_VALSER")) > 0

if Left(Funname(),4) == "OFIX" .or. FunName() == "OFIOM350" .or. FunName() == "OFIOM430" .or. FunName() == "M_CONSPEC"
	return .t.
endif

FG_MEMVAR()

Do Case
	
	Case ReadVar() == "M->VS4_CODSER"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		For nwnk := 1 to Len(aCols)
			If aCols[nwnk,FG_POSVAR("VS4_CODSER","aHeaderS")] == M->VS4_CODSER .and.;
				n <> nwnk .and. !aCols[nwnk,Len(aCols[nwnk])]
				MSGStop(STR0113)  //"Servico ja lancado no Orcamento, Revise"
				Return(.f.)
			EndIf
		Next
		
		FS_SERAGRU(M->VS4_CODSER)
		
		If !empty(aCols[n,fg_posvar("VS4_TIPSER","aHeaderS")])
			
			If aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] != 0
				nTotDes    -= aCols[n,fg_posvar("VS4_VALDES","aHeaderS")]
			Endif
			If aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] != 0
				nTotSrv    -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
				nTotOrc    -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
			Endif
			
			nTemPad       := 0
			nValHor       := 0
			nValSer       := 0
			nValTotS      := 0
			nPerSrv       := If(M->VS1_PERSER != 0,M->VS1_PERSER,0)
			nDesSrv       := 0
			
			M->VS4_TEMPAD := nTemPad
			M->VS4_VALHOR := nValHor
			M->VS4_TIPSER := "   "
			M->VS4_VALSER := nValSer
			M->VS4_PERDES := nPerSrv
			M->VS4_VALDES := nDesSrv
			M->VS4_VALTOT := nValTotS
			
			aCols[n,fg_posvar("VS4_TIPSER","aHeaderS")] := "   "
			aCols[n,fg_posvar("VS4_TEMPAD","aHeaderS")] := nTemPad
			aCols[n,fg_posvar("VS4_VALHOR","aHeaderS")] := nValHor
			aCols[n,fg_posvar("VS4_VALSER","aHeaderS")] := nValSer
			aCols[n,fg_posvar("VS4_PERDES","aHeaderS")] := nPerSrv
			aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] := nDesSrv
			aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] := nValTotS
			
			oTotDes:refresh()
			oTotSrv:refresh()
			oTotOrc:refresh()
			
		EndIf
		
	Case ReadVar() == "M->VS4_TIPSER"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		If aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] != 0
			nTotDes    -= aCols[n,fg_posvar("VS4_VALDES","aHeaderS")]
		Endif
		If aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] != 0
			nTotSrv    -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
			nTotOrc    -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
		Endif
		
		nValSer       := (nTemPad /100) * nValHor
		If lVO6_VALSER
			If VO6->VO6_VALSER > 0
				nValSer := VO6->VO6_VALSER
			EndIf
		EndIf
		nValTotS      := nValSer
		nPerSrv       := If(M->VS1_PERSER != 0,M->VS1_PERSER,0)
		nDesSrv       := 0
		
		M->VS4_VALHOR := nValHor
		M->VS4_PERDES := nPerSrv
		M->VS4_VALSER := nValSer
		M->VS4_VALTOT := nValTotS
		
		nPerSrv       := M->VS1_PERSER / 100
		nDesSrv       := Round(nValSer * nPerSrv,2)
		nValTotS      := nValSer - nDesSrv
		M->VS4_VALDES := nDesSrv
		M->VS4_VALTOT := nValTotS
		
		aCols[n,fg_posvar("VS4_TIPSER","aHeaderS")] := M->VS4_TIPSER
		aCols[n,fg_posvar("VS4_TEMPAD","aHeaderS")] := nTemPad //* 100
		aCols[n,fg_posvar("VS4_VALHOR","aHeaderS")] := nValHor
		aCols[n,fg_posvar("VS4_VALSER","aHeaderS")] := nValSer
		aCols[n,fg_posvar("VS4_PERDES","aHeaderS")] := M->VS1_PERSER
		aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] := nDesSrv
		aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] := nValTotS
		
		nTotSrv       += nValTotS
		nTotOrc       += nValTotS
		nTotDes       += nDesSrv
		
		oTotDes:refresh()
		oTotSrv:refresh()
		oTotOrc:refresh()
		
	Case ReadVar() == "M->VS4_CODSEC"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		aCols[n,fg_posvar("VS4_CODSEC","aHeaderS")] := M->VS4_CODSEC

	Case ReadVar() == "M->VS4_TEMPAD"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		If aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] != 0
			nTotDes    -= aCols[n,fg_posvar("VS4_VALDES","aHeaderS")]
		Endif
		If aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] != 0
			nTotSrv    -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
			nTotOrc    -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
		Endif
		
		nTemPad       := M->VS4_TEMPAD
		nValSer       := (nTemPad/100) * nValHor
		nValTotS      := nValSer
		nPerSrv       := If(M->VS1_PERSER != 0,M->VS1_PERSER,0)
		nDesSrv       := 0
		
		M->VS4_VALHOR := nValHor
		M->VS4_VALSER := nValSer
		M->VS4_PERDES := nPerSrv
		M->VS4_VALDES := nDesSrv
		M->VS4_VALTOT := nValTotS
		
		aCols[n,fg_posvar("VS4_TEMPAD","aHeaderS")] := nTemPad
		aCols[n,fg_posvar("VS4_VALHOR","aHeaderS")] := nValHor
		aCols[n,fg_posvar("VS4_VALSER","aHeaderS")] := nValSer
		aCols[n,fg_posvar("VS4_PERDES","aHeaderS")] := nPerSrv
		aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] := nDesSrv
		aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] := nValTotS
		
		nTotSrv  += nValTotS
		nTotOrc  += nValTotS
		
		oTotDes:refresh()
		oTotSrv:refresh()
		oTotOrc:refresh()
		
	Case ReadVar() == "M->VS4_VALSER"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		If aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] != 0
			nTotDes       -= aCols[n,fg_posvar("VS4_VALDES","aHeaderS")]
		Endif
		If aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] != 0
			nTotSrv       -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
			nTotOrc       -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
		Endif
		
		If VOK->VOK_INCMOB == "2"
			
			nTemPad       := 0
			nValHor       := 0
			nValSer       := M->VS4_VALSER
			nValTotS      := nValSer
			nPerSrv       := If(M->VS1_PERSER != 0,M->VS1_PERSER,0)
			nDesSrv       := 0
			
			M->VS4_VALHOR := nValHor
			M->VS4_VALSER := nValSer
			M->VS4_PERDES := nPerSrv
			M->VS4_VALDES := nDesSrv
			M->VS4_VALTOT := nValTotS
			
			aCols[n,fg_posvar("VS4_TEMPAD","aHeaderS")] := nTemPad             // Tempo Padrao
			aCols[n,fg_posvar("VS4_VALHOR","aHeaderS")] := nValHor             // Valor da Hora
			aCols[n,fg_posvar("VS4_VALSER","aHeaderS")] := nValSer             // Valor do Servico
			aCols[n,fg_posvar("VS4_PERDES","aHeaderS")] := nPerSrv             // Percentual de Desconto
			aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] := nDesSrv             // Valor do Desconto
			aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] := nValTotS            // Valor Total
			
			nTotSrv       += nValTotS
			nTotOrc       += nValTotS
			
		Else
			
			nValSer       := M->VS4_VALSER
			nValTotS      := nValSer
			nPerSrv       := If(M->VS1_PERSER != 0,M->VS1_PERSER,0)
			nDesSrv       := 0
			
			M->VS4_VALHOR := nValHor
			M->VS4_VALSER := nValSer
			M->VS4_PERDES := nPerSrv
			M->VS4_VALDES := nDesSrv
			M->VS4_VALTOT := nValTotS
			
			aCols[n,fg_posvar("VS4_TEMPAD","aHeaderS")] := nTemPad
			aCols[n,fg_posvar("VS4_VALHOR","aHeaderS")] := nValHor
			aCols[n,fg_posvar("VS4_VALSER","aHeaderS")] := nValSer
			aCols[n,fg_posvar("VS4_PERDES","aHeaderS")] := nPerSrv
			aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] := nDesSrv
			aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] := nValTotS
			
			nTotSrv       += nValTotS
			nTotOrc       += nValTotS
			
		Endif
		
		oTotDes:refresh()
		oTotSrv:refresh()
		oTotOrc:refresh()
		
	Case ReadVar() == "M->VS4_KILROD"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		If aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] != 0
			nTotDes       -= aCols[n,fg_posvar("VS4_VALDES","aHeaderS")]
		Endif
		If aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] != 0
			nTotSrv       -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
			nTotOrc       -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
		Endif
		
		nTemPad       := 0
		nValSer       := M->VS4_KILROD * VOK->VOK_PREKIL
		nValTotS      := nValSer
		nPerSrv       := If(M->VS1_PERSER != 0,M->VS1_PERSER,0)
		nDesSrv       := 0
		
		M->VS4_VALHOR := nValHor
		M->VS4_VALSER := nValSer
		M->VS4_PERDES := nPerSrv
		M->VS4_VALDES := nDesSrv
		M->VS4_VALTOT := nValTotS
		
		aCols[n,fg_posvar("VS4_TEMPAD","aHeaderS")] := nTemPad
		aCols[n,fg_posvar("VS4_VALHOR","aHeaderS")] := nValHor
		aCols[n,fg_posvar("VS4_VALSER","aHeaderS")] := nValSer
		aCols[n,fg_posvar("VS4_PERDES","aHeaderS")] := nPerSrv
		aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] := nDesSrv
		aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] := nValTotS
		
		nTotSrv       += nValTotS
		nTotOrc       += nValTotS
		
		oTotDes:refresh()
		oTotSrv:refresh()
		oTotOrc:refresh()
		
	Case ReadVar() == "M->VS4_PERDES"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		if M->VS4_PERDES < 0 .or. M->VS4_PERDES > 99.99
			Return .f.
		Endif
		
		If !FG_PERDES(,,"S",M->VS4_TIPSER,M->VS4_CODSER,,M->VS4_PERDES)
//			return .f.
		EndIf
		
		If aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] != 0
			nTotDes       -= aCols[n,fg_posvar("VS4_VALDES","aHeaderS")]
		Endif
		If aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] != 0
			nTotSrv       -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
			nTotOrc       -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
		Endif
		
		nValSer       := M->VS4_VALSER
		nPerSrv       := M->VS4_PERDES / 100
		nDesSrv       := Round(nValSer * nPerSrv,2)
		nValTotS      := nValSer - nDesSrv
		
		M->VS4_PERDES := ( nPerSrv * 100 )
		M->VS4_VALDES := nDesSrv
		M->VS4_VALTOT := nValTotS
		
		aCols[n,fg_posvar("VS4_PERDES","aHeaderS")] := ( nPerSrv * 100 )
		aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] := nDesSrv
		aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] := nValTotS
		
		nTotSrv       += nValTotS
		nTotOrc       += nValTotS
		nTotDes       += nDesSrv
		
		oTotSrv:refresh()
		oTotOrc:refresh()
		oTotDes:refresh()
		
	Case ReadVar() == "M->VS4_VALDES"
		
		If aCols[n,Len(aCols[n])]
			Return(.t.)
		EndIf
		
		if M->VS4_VALDES < 0 .or. M->VS4_VALDES > M->VS4_VALSER
			Return .f.
		Endif
		
		If !FG_PERDES(,,"S",M->VS4_TIPSER,M->VS4_CODSER,,((M->VS4_VALDES / M->VS4_VALSER) * 100))
//			return .f.
		EndIf
		
		If aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] != 0
			nTotDes       -= aCols[n,fg_posvar("VS4_VALDES","aHeaderS")]
		Endif
		If aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] != 0
			nTotSrv       -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
			nTotOrc       -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
		Endif
		
		nValSer       := aCols[n,fg_posvar("VS4_VALSER","aHeaderS")]
		nDesSrv       := M->VS4_VALDES
		nValTotS      := nValSer - nDesSrv
		nPerSrv       := 100 - ((nValTotS / nValSer) * 100)
		nValTotS      := nValSer - nDesSrv
		M->VS4_VALTOT := nValTotS
		
		M->VS4_PERDES := nPerSrv
		aCols[n,fg_posvar("VS4_PERDES","aHeaderS")] := nPerSrv
		aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] := nDesSrv
		aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] := nValSer - nDesSrv
		
		nTotSrv       += nValTotS
		nTotOrc       += nValTotS
		nTotDes       += nDesSrv
		
		oTotSrv:refresh()
		oTotOrc:refresh()
		oTotDes:refresh()
		
	Case aCols[n,Len(aCols[n])]
		
		If M->VS1_ALTORC == "0"
			aCols[n,Len(aCols[n])] := .f.
			Return .t.
		Endif
		
		aCols[n,fg_posvar("VS4_PERDES","aHeaderS")] := 0
		aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] := 0
		aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] := aCols[n,FG_POSVAR("VS4_VALSER","aHeaderS")]
		
		If aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] != 0
			nTotDes       -= aCols[n,fg_posvar("VS4_VALDES","aHeaderS")]
		Endif
		If aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] != 0
			nTotSrv       -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
			nTotOrc       -= aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
		Endif
		
		oGetSrvcs:oBrowse:Refresh()
		oTotSrv:refresh()
		oTotOrc:refresh()
		oTotDes:refresh()
		
	Case !aCols[n,Len(aCols[n])]
		
		If aCols[n,fg_posvar("VS4_VALDES","aHeaderS")] != 0
			nTotDes       += aCols[n,fg_posvar("VS4_VALDES","aHeaderS")]
		Endif
		If aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")] != 0
			nTotSrv       += aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
			nTotOrc       += aCols[n,fg_posvar("VS4_VALTOT","aHeaderS")]
		Endif
		
		oGetSrvcs:oBrowse:Refresh()
		oTotSrv:refresh()
		oTotOrc:refresh()
		oTotDes:refresh()
		
EndCase

aHeaderS := aClone(aHeader)
aColsS   := aClone(aCols)

aHeader  := aClone(aHeaderP)
aCols    := aClone(aColsP)

nVlrTot := 0
M->VS1_DESCON := M->VS1_VALDES := 0
For _ni := 1 to len(aCols)
	If !aCols[_ni,Len(aCols[_ni])]
		M->VS1_DESCON += aCols[_ni,fg_posvar("VS3_VALDES","aHeaderP")]
		nVlrTot += aCols[_ni,fg_posvar("VS3_VALPEC","aHeaderP")]*aCols[_ni,fg_posvar("VS3_QTDITE","aHeaderP")]
	EndIf
Next

FS_CALCVAL("N",.f.)

aHeader  := aClone(aHeaderS)
aCols    := aClone(aColsS)

For _ni := 1 to len(aCols)
	If !aCols[_ni,Len(aCols[_ni])]
		M->VS1_DESCON += aCols[_ni,fg_posvar("VS4_VALDES","aHeaderS")]
		nVlrTot += aCols[_ni,fg_posvar("VS4_VALSER","aHeaderS")]
	EndIf
Next
M->VS1_VALDES := M->VS1_DESCON
M->VS1_PERDES := val(str(( M->VS1_VALDES / nVlrTot ) * 100,12,2))

oGetMGet:Refresh()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FS_GetCha³ Autor ³  Emilton              ³ Data ³ 08/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Apresenta Dados de Veiculos para Orcamento                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GETCHA()

if Left(Funname(),4) == "OFIX" .or. FunName() == "OFIOM350" .or. FunName() == "OFIOM430" .or. FunName() == "M_CONSPEC"
	return OX001GETCHA()
endif

Private cPesqVV1 := M->VS1_GETKEY
lReturn := .f.
wSelect := Alias()

lReturn := FG_POSVEI("cPesqVV1",)

if !lReturn
	return(lReturn)
endif

DBSelectArea("VV1")

If ExistFunc("FM_VEIGAR")
	FM_VEIGAR() // Verifica se o Veiculo esta em garantia - 04/05/2009 - Andre Luis Almeida
EndIf

M->VS1_GETKEY := VV1->VV1_CHASSI

Private aTELA[0][0],aGETS[0]

If ExistFunc("OFA1100016_PesquisaCampanha") .And. VOU->(FieldPos("VOU_SERINT")) > 0
	OFA1100016_PesquisaCampanha(VV1->VV1_CHASSI)
EndIf

//Dados do Cliente
//if Empty(M->VS1_CLIFAT)
M->VS1_CLIFAT := VV1->VV1_PROATU
M->VS1_LOJA   := VV1->VV1_LJPATU
//Endif

FS_INIIMP(M->VS1_CLIFAT,M->VS1_LOJA)
FS_PREFAT()

M->VS1_CODMAR := VV1->VV1_CODMAR
M->VS1_CHASSI := VV1->VV1_CHASSI
M->VS1_CHAINT := VV1->VV1_CHAINT
M->VS1_PLAVEI := VV1->VV1_PLAVEI
M->VS1_CODFRO := VV1->VV1_CODFRO

If ExistBlock("VA010DPGR")
	ExecBlock("VA010DPGR",.f.,.f.,{VV1->VV1_CHAINT,3,0})
EndIf

cCodMar   := VV1->VV1_CODMAR
lJaGravou := .f.

if !FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.)
	
	aCampoVO5 := {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("VO5")
	While !EOF() .And. (X3_ARQUIVO == "VO5")
		IF X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
			AADD(aCampoVO5,X3_CAMPO)
		EndIF
		dbSkip()
	EndDO
	
	dbSelectArea("VO5")
	
	PRIVATE wChaInt := VV1->VV1_CHAINT
	
	nOpca := AxInclui("VO5",0,3,aCampoVO5)
	
	If nOpca != 1
		dbSelectArea("VS1")
		Return(.f.)
	EndIf
	
Endif

dbSelectArea("VS1")

if FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.)
	FG_SEEK("VV2","VV1->VV1_CODMAR+VV1->VV1_MODVEI",1,.f.)
	FG_SEEK("VVC","VV1->VV1_CODMAR+VV1->VV1_CORVEI",1,.f.)
	FG_SEEK("SA1","VV1->VV1_PROATU",1,.f.)
	FG_SEEK("VE1","VV1->VV1_CODMAR",1,.f.)
	if lVAMCid
		FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
	Endif
	M->VS1_DESMAR := VE1->VE1_DESMAR
	M->VS1_DESMOD := VV2->VV2_DESMOD
	M->VS1_CHAINT := VV1->VV1_CHAINT
	M->VS1_CHASSI := VV1->VV1_CHASSI
	M->VS1_PLAVEI := VV1->VV1_PLAVEI
	M->VS1_CODFRO := VV1->VV1_CODFRO
	M->VS1_FABMOD := VV1->VV1_FABMOD
	M->VS1_DESCOR := VVC->VVC_DESCRI
	M->VS1_PROVEI := SA1->A1_COD
	M->VS1_NOMPRO := SA1->A1_NOME
	M->VS1_ENDPRO := SA1->A1_END
	if lVAMCid
		M->VS1_CIDPRO := VAM->VAM_DESCID
		M->VS1_ESTPRO := VAM->VAM_ESTADO
	Else
		M->VS1_CIDPRO := SA1->A1_MUN
		M->VS1_ESTPRO := SA1->A1_EST
	Endif
	M->VS1_FONPRO := SA1->A1_TEL
	
Else
	
	M->VS1_DESMAR := ""
	M->VS1_DESMOD := ""
	M->VS1_CHAINT := ""
	M->VS1_CHASSI := ""
	M->VS1_PLAVEI := ""
	M->VS1_CODFRO := ""
	M->VS1_FABMOD := ""
	M->VS1_DESCOR := ""
	M->VS1_PROVEI := ""
	M->VS1_NOMPRO := ""
	M->VS1_ENDPRO := ""
	M->VS1_CIDPRO := ""
	M->VS1_ESTPRO := ""
	M->VS1_FONPRO := ""
	
	Return(.f.)
	
Endif

If Empty(wSelect)
	wSelect := "VS1"
EndIf
dbSelectArea(wSelect)

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_QTDORC   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica Quantidade pedida e Quantidade Disponivel          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_QTDORC(nQtd_)

Local nSaldo
Local lRet := .t.

Default nQtd_ := M->VS3_QTDITE


nSaldo := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+IIf(oFolder:nOption#3,LocIte110(),SB1->B1_LOCPAD))
//nSaldo := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+IIf(oFolder:nOption#3,LocIte110(),M->VS3_LOCAL))
if nQtd_ > nSaldo
	//   if Type("M->VS3_QTDEST") == "U"
	nOp  := Aviso( STR0352 , STR0353 +": "+alltrim(SB1->B1_DESC)+" "+ STR0354 +": "+str(nSaldo,6)+" "+ STR0355 , { STR0028 } )//Estoque # A qtdade requisitada da peca ## e maior que a qtdade em estoque, o estoque dessa peca e de # pecas... # ok
	lRet := .f.
	//   Endif
Endif
if nQtd_ > (nSaldo-SB1->B1_ESTSEG) .and. lRet = .t.
	nOp  := Aviso( STR0352 , STR0353+" "+SB1->B1_GRUPO + " " + alltrim(SB1->B1_CODITE)+ ": " + alltrim(SB1->B1_DESC)+" "+ STR0356 +": "+str(nSaldo-SB1->B1_ESTSEG,6)+" "+STR0355 , { STR0028 } )//"Estoque # A qtdade requisitada da peca # e maior que a qtdade minima reservada para o estoque de oficina, qtd a requisitar: #  pecas... OK
	lRet := .t. //da a mensagem, mas deixa vender.
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_CATAL110 | Autor ³ Andre                 ³ Data ³ 25/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CATAL110()







Local cTitulo    := STR0152
Local cTitReq    := cTitulo+STR0153+VE1->VE1_DESMAR

If Empty(M->VS1_CODMAR)
	MSGStop(STR0154)
	Return .t.
Endif

// seleciona a folder de pecas, caso o usuario esteja na folder de servicos.

FS_MUDAABA()
Private oLbTexto
Private cGrupoCat := Space(04)
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oLbItens,lBxFilho := .f.
Private aPecas     := {}
Private aPecasSele := {}
Private aArqTxt    := {}
Private lExec      := .f.
cSelect1 := Alias()

dbSelectArea("VE4")
If !(dbSeek(xFilial("VE4")+M->VS1_CODMAR))
	Help(" ",1,"NAOPARFAB")
	Return
EndIf

nOperacao := Aviso( cTitReq , STR0155 , { STR0156 , STR0157 , STR0158 } )

If nOperacao == 3
	Return
EndIf

If nOperacao == 1
	WaitRun(VE4->VE4_DIRFEX,1)                          //Chamada do Executavel do catalogo.
EndIf

aPecas := &( Alltrim(VE4->VE4_FUNCAO) )               //Chamada da Funcao p/ Montar os Itens

If Len(aArqTxt) == 0
	Return
EndIf

dbSelectArea("VE1")
dbSeek(xFilial("VE1")+M->VS1_CODMAR)

DEFINE MSDIALOG oDlgPecas TITLE cTitReq From 7,08 to 36,92      of oMainWnd

@ 17, .2 SAY   OemToAnsi(STR0036)  OF oDlgPecas PIXEL COLOR CLR_BLUE
@ 17,040 MSGET cGrupoCat     PICTURE "@!" F3 "E09" VALID SBM->(dbSeek(xFilial("SBM")+cGrupoCat)) .and. (SBM->BM_CODMAR == M->VS1_CODMAR) OF oDlgPecas PIXEL COLOR CLR_BLACK
@ 17,080 MSGET SBM->BM_DESC PICTURE "@!" OF oDlgPecas PIXEL COLOR CLR_BLUE When .f.

@ 60,002 TO 220,331 LABEL STR0031  OF oDlgPecas PIXEL

@ 5,001 LISTBOX oLbTexto FIELDS HEADER  OemToAnsi(STR0037),; // Arquivo
OemToAnsi(STR0038),; // Tamanho
OemToAnsi(STR0039),; // Data
OemToAnsi(STR0040),; // Hora
OemToAnsi(STR0041);  // Atributos
COLSIZES 60,60,60,60,60;
SIZE 316,50 OF oDlgPecas ON CHANGE (FS_ITENS100(olbTexto:nAt))

oLbTexto:SetArray(aArqTxt)
oLbTexto:bLine := { || { aArqTxt[oLbTexto:nAt,1] ,;
Str(aArqTxt[oLbTexto:nAt,2]) ,;
dToc(aArqTxt[oLbTexto:nAt,3]) ,;
aArqTxt[oLbTexto:nAt,4] ,;
aArqTxt[oLbTexto:nAt,5]}}

@ 9,001 LISTBOX oLbItens FIELDS HEADER OemToAnsi(""),;
OemToAnsi(STR0014),; // "Cod item"
OemToAnsi(STR0015),; // "Descricao
OemToAnsi(STR0016);  // "Quantidade
COLSIZES 60,60,90,20 ;
SIZE 316,88 OF oDlgPecas ON DBLCLICK(If(Val(aPecasSele[oLbItens:nAt,4])#0,If(aPecasSele[oLbItens:nAt,1],aPecasSele[oLbItens:nAt,1]:=.F.,aPecasSele[oLbItens:nAt,1]:=.T.),.T.),IIF(aPecasSele[oLbItens:nAt,1],oOk,oNo))

ACTIVATE MSDIALOG oDlgPecas ON INIT EnchoiceBar(oDlgPecas,{|| nOpca := 1,FS_IMPORC(aArqTxt[oLbTexto:nAt,1])},{|| nOpca := 0,(oDlgPecas:End())})

oGetPecas:ForceRefresh()

FS_ITEREL110()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_IMPORC   ³ Autor ³ Emilton               ³ Data ³ 27/10/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importa Dados de Orcamento de pecas do catalogo              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_IMPORC(cArquivo)

Local aColsSlv   := {}
Local	aHeaderSlv := {}
Local _ni:=0, i:=0, cont:=0
Local aNPecImp := {}

aArquivo := {}
nHandle  := Alltrim( Substr( VE4->VE4_DIRFAB , 1 , Rat("\",VE4->VE4_DIRFAB) )) + cArquivo
nHandle  := FOpen(nHandle,2)
cString  := FSeek(nHandle,0,2)
nTamanho := (cString/Len(aPecasSele))

FSeek(nHandle,0)
Orcamento :=.t.
lLibera := .t.
For cont:=1 to Len(aPecasSele)
	If aPecasSele[cont,1]
		
		if !MaFisFound('NF')
			MsgInfo(STR0357 ,STR0019)//E necessario informar o cabecalho do Orcamento primeiro... # Atemcao
			oDlgPecas:End()
			Return .f.
		Endif
		
		dbSelectArea("SB1")
		dbSetOrder(7)
		If dbSeek(xFilial("SB1")+cGrupoCat+aPecasSele[cont,2])
			if cOpeMov2 == "2"
				if Empty(M->VS3_FORMUL)
					M->VS3_FORMUL := GETMV("MV_FMLPECA")
					if Type("M->VS3_FORMUL") <> "C"
						M->VS3_FORMUL := SPACE(LEN(VS3->VS3_FORMUL))
					Endif
				Endif
			Endif
			nValPec := FG_VALPEC(M->VS1_TIPTEM,"M->VS3_FORMUL",M->VS3_GRUITE,M->VS3_CODITE,"M->VS3_VALPEC",.f.,.t.)
			if !Empty(aColsP[Len(aColsP),FG_POSVAR("VS3_SEQUEN","aHeaderP")]) .and. !Empty(aColsP[Len(aColsP),FG_POSVAR("VS3_GRUITE","aHeaderP")])
				AADD(aColsP,Array(nUsadoP+1))
				aColsP[Len(aColsP),nUsadoP+1]:=.F.
				For _ni:=1 to nUsadoP
					aColsP[Len(aColsP),_ni]:=CriaVar(aHeaderP[_ni,2])
				Next
			Endif
			
			n := Len(aColsP)
			
			aCols   := aClone(aColsP)
			aHeader := aClone(aHeaderP)
			
			//Insere a Peca no Orcamento
			aColsP[Len(aColsP),FG_POSVAR("VS3_SEQUEN","aHeaderP")] := StrZero(Len(aColsP),3)
			aColsP[Len(aColsP),FG_POSVAR("VS3_GRUITE","aHeaderP")] := cGrupoCat
			aColsP[Len(aColsP),FG_POSVAR("VS3_CODITE","aHeaderP")] := aPecasSele[cont,2]
			//			aColsP[Len(aColsP),FG_POSVAR("VS3_DESITE","aHeaderP")] := aPecasSele[cont,3]
			aColsP[Len(aColsP),FG_POSVAR("VS3_DESITE","aHeaderP")] := SB1->B1_DESC
			aColsP[Len(aColsP),FG_POSVAR("VS3_VALPEC","aHeaderP")] := nValPec
			
			M->VS3_GRUITE := cGrupoCat
			M->VS3_CODITE := aPecasSele[cont,2]
			
			//Calcula o Preco da Peca
			wAlias := alias()
			
			cKey := cGrupoCat+aPecasSele[cont,2]
			FG_Seek("SB1","cKey",7,.f.)
			MaFisRef("IT_PRODUTO","VS300",SB1->B1_COD)
			
			if cOpeMov2 == "1"
				aColsP[Len(aColsP),FG_POSVAR("VS3_FORMUL","aHeaderP")] := M->VS1_FORMUL
				aColsP[Len(aColsP),FG_POSVAR("VS3_CODTES","aHeaderP")] := SB1->B1_TS
			Else
				aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")] := cTesPad
				M->VS3_CODTES := cTesPad
				if Empty(M->VS3_FORMUL)
					M->VS3_FORMUL := GETMV("MV_FMLPECA")
					if Type("M->VS3_FORMUL") <> "C"
						M->VS3_FORMUL := SPACE(LEN(VS3->VS3_FORMUL))
					Endif
				Endif
			Endif
			nValPec := FG_VALPEC(M->VS1_TIPTEM,"M->VS3_FORMUL",M->VS3_GRUITE,M->VS3_CODITE,"M->VS3_VALPEC",.f.,.t.)
			
			dbSelectArea(wALias)
			
			//Quantidade inicial igual a 1
			aColsP[Len(aColsP),FG_POSVAR("VS3_QTDITE","aHeaderP")] := Val(aPecasSele[cont,4])
			aColsP[Len(aColsP),FG_POSVAR("VS3_VALPEC","aHeaderP")] := nValPec
			aColsP[Len(aColsP),FG_POSVAR("VS3_CODTES","aHeaderP")] := SB1->B1_TS
			
			M->VS3_QTDITE := Val(aPecasSele[cont,4])
			M->VS3_VALPEC := nValPec
			M->VS3_CODTES := SB1->B1_TS
			
			aColsSlv   := aClone(aColsP)
			aHeaderSlv := aClone(aHeaderP)
			
			// Verifica se o Array aIteRes e aIteBlq estao de acordo com o aColsP
			n1 := n
			FS_BLQRES()
			n := n1
			
			aColsP   := aClone(aColsSlv)
			aHeaderP := aClone(aHeaderSlv)
			
			// Analisa/Carrega Peca no Reservado
			FG_Seek("SB1","cKey",7,.f.)
			nSaldo := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+LocIte110(.f.,aCols,n))
			nPos := aScan(aIteBlq,{|x| x[1] == aCols[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
			
			//Desconto padrao cadastrado no VS1
			if aColsP[Len(aColsP),FG_POSVAR("VS3_PERDES","aHeaderP")] == 0
				aColsP[Len(aColsP),FG_POSVAR("VS3_PERDES","aHeaderP")] := M->VS1_PERPEC
			Endif
			M->VS3_PERDES := aColsP[Len(aColsP),FG_POSVAR("VS3_PERDES","aHeaderP")]
			
			SBM->(dbSetOrder(1))
			SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
			FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,M->VS3_PERDES,,M->VS3_MODVEI)
			
			M->VS3_VALDES := ((M->VS3_VALPEC*M->VS3_QTDITE)/100)*M->VS3_PERDES
			M->VS3_VALTOT := (M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES
			
			aColsP[Len(aColsP),FG_POSVAR("VS3_VALTOT","aHeaderP")] := M->VS3_VALTOT
			aColsP[Len(aColsP),FG_POSVAR("VS3_VALDES","aHeaderP")] := M->VS3_VALDES
			
			MaFisRef("IT_VALMERC" ,"VS300",M->VS3_VALTOT+M->VS3_VALDES)
			MaFisRef("IT_TES"     ,"VS300",aColsP[Len(aColsP),FG_POSVAR("VS3_CODTES","aHeaderP")])
			MaFisRef("IT_DESCONTO","VS300",M->VS3_VALDES)
			
			//aCols tem que estar igual ao aColsP por causa da funcao MaFisRet
			aCols   := aClone(aColsP)
			aHeader := aClone(aHeaderP)
			
			If (cPaisLoc == "BRA") // Manoel - 07/05/2009
				if cOpeMov2 == "1" .or. !Empty(cTesPad)
					aColsP[Len(aColsP),fg_posvar("VS3_VBAICM","aHeaderP")] := MaFisRet(Len(aColsP),"IT_BASEICM")
					aColsP[Len(aColsP),fg_posvar("VS3_ALIICM","aHeaderP")] := MaFisRet(Len(aColsP),"IT_ALIQICM")
					aColsP[Len(aColsP),fg_posvar("VS3_ICMCAL","aHeaderP")] := MaFisRet(Len(aColsP),"IT_VALICM")
					FpRefresh()
				Endif
			Endif
			
			aCols   := aClone(aColsP)
			aHeader := aClone(aHeaderP)
			
			FS_ITEREL110()
			
			nTotPec := 0
			nTotOrc := 0
			nTotDes := 0
			nTotTit := 0
			nBrinde := 0
			
			For i:=1 to Len(aCols)
				if aCols[i,Len(acols[i])] == .t.
					Loop
				Endif
				nTotPec += aCols[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
				nTotOrc += aCols[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
				nTotDes += aCols[i,FG_POSVAR("VS3_VALDES","aHeaderP")]
				if TipoTes(aCols[i,FG_POSVAR("VS3_CODTES","aHeaderP")])
					nTotTit += aCols[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
					//if SF4->F4_INCSOL == "S"
					//   nTotTit += MaFisRet(i,"IT_VALSOL")
					//Endif
				Else
					nBrinde += aCols[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
				Endif
			Next
			
			oTotDes:refresh()
			oTotPec:refresh()
			oTotOrc:refresh()
			
			if aColsP[Len(aColsP),Len(aColsP[Len(aColsP)])]
				aColsP[Len(aColsP),Len(aColsP[Len(aColsP)])] := .f.
			Endif
			
			oGetPecas:oBrowse:refresh()
			
		Else
			lLibera := .f.
			aadd(aNPecImp,aPecasSele[cont,2])
		EndIf
		
	EndIf
	
	cString  := FREADSTR(nHandle,nTamanho)
	Aadd(aArquivo,cString)
	
Next

/*
For cont:=1 to len(aPecasSele)
If Val(aPecasSele[cont,4]) == 0
aArquivo[cont] := Substr(aArquivo[cont],1,VE4->VE4_QTDINI)+Space(VE4->VE4_QTDTAM-2)+"0"+Substr(aArquivo[cont],(VE4->VE4_QTDINI+VE4->VE4_QTDTAM))
EndIf
FSeek(nHandle,(cont-1)*(nTamanho),0)
FWRITE(nHandle,aArquivo[cont])
Next
*/

FClose(nHandle)


If !(lLibera)
	cPecas := ""
	for cont := 1 to Len(aNPecImp)
		cPecas := cPecas + aNPecImp[cont]+chr(13)+chr(10)
	next
	MsgAlert( STR0358 +": "+chr(13)+chr(10)+cPecas , STR0148)	// Importacao finalizada, algums itens nao foram importados por nao existirem no cadastro # Atencao!
	//	Help(" ",1,"CATALOGO")
Else
	MsgInfo(STR0159,STR0028)
EndIf

oLbItens:SetFocus()
oLbTexto:SetFocus()

oDlgPecas:End()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_ITENS100 ³ Autor ³ Fabio                 ³ Data ³ 25/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtra os Itens de acordo com o arquivo.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ITENS100(wLin)

Local cont:=0

aPecasSele := {}
For cont:=1 to Len(aPecas)
	If Alltrim(aPecas[cont,1]) == Alltrim(aArqTxt[wLin,1])
		Aadd(aPecasSele,{If(Val(aPecas[cont,4]) == 0,.F.,.T.),aPecas[cont,2],aPecas[cont,3],aPecas[cont,4]})
	EndIf
Next

if Len(aPecasSele) > 0
	oLbItens:SetArray(aPecasSele)
	oLbItens:bLine := { || {  If(aPecasSele[oLbItens:nAt,1],oOk,oNo) ,;
	aPecasSele[oLbItens:nAt,2] ,;
	aPecasSele[oLbItens:nAt,3] ,;
	aPecasSele[oLbItens:nAt,4]}}
Endif
//Eval(olBItens:bLine)
if !lExec .and. wLin == 1
	lExec := .t.
	Return
Endif
oLbItens:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_FINORC   ³ Autor ³ Andre                 ³ Data ³ 25/08/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava Orcamento                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FINORC(cOpc,lPerg,lExecBlq)

Local lItens := .F. // flag para saber se existem itens validos no orcamento
Local lNovo  := .T. // indica se eh um orcamento novo ou se este ja havia sido gravado
Local lDel 	 := .F. // indica se a linha do aCols esta deletada
Local aArea  := {}
Local i := 0
Local y := 0
Local _nQtd
Local x_ := 0
Local xi_:=0
LOcal x := 0

Local aAreaVS1  := VS1->(GetArea())

Local nPos	:= 0



DEFAULT lExecBlq := .F.
////////////////////////////////////////////////////////////
// Rafael Goncalves - FNC 19571/2009                      //
// Incluido validacao se nao tem campo do aheader em bco  //
////////////////////////////////////////////////////////////
//inicio
if !FS_VERAHADER()//funcao para executar a validacao se existe item com grupo, item e quantidade no aheader       
	Return
Endif
/*
if M->VS1_TIPORC == "2"
	For i:=1 to Len(aColsP)
		if n == i .and. aHeaderP[1,2] == aHeader[1,2]
			if aColsP[i,Len(aColsP[i])] .or. ( len(aColsP)==1 .and. Empty(M->VS3_GRUITE) .and. Empty(M->VS3_CODITE) )
				Loop
			EndIf
			if Empty(M->VS3_GRUITE) .and. !Empty(M->VS3_CODITE)
				MsgInfo(STR0363 +" < "+strzero(i,3)+" >",STR0148)//Grupo do Item nao foi informado... item # Atencao!
				Return(.f.)
			Endif
			If Empty(M->VS3_CODITE)
				MsgInfo(STR0532 +" < "+strzero(i,3)+" >",STR0148)//codigo do Item nao foi informado... item # Atencao!
				Return(.f.)
			Endif
			if M->VS3_QTDITE == 0
				MsgInfo(STR0364 +" < "+strzero(i,3)+" >",STR0148) //Quantidade do item nao foi informada... item # Atencao!
				Return(.f.)
			Endif
		else
	   		if aColsP[i,Len(aColsP[i])] .or. ( len(aColsP)==1 .and. Empty(aColsP[i,FG_POSVAR("VS3_GRUITE","aHeaderP")]) .and. Empty(aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")]) )
				Loop
		    EndIf
			if Empty(aColsP[i,FG_POSVAR("VS3_GRUITE","aHeaderP")]) .and. !Empty(aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")])
				MsgInfo(STR0363 +" < "+strzero(i,3)+" >",STR0148)//Grupo do Item nao foi informado... item # Atencao!
				Return(.f.)
			Endif
			If Empty(aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")])
				MsgInfo(STR0532 +" < "+strzero(i,3)+" >",STR0148)//codigo do Item nao foi informado... item # Atencao!
				Return(.f.)
			Endif
			if aColsP[i,FG_POSVAR("VS3_QTDITE","aHeaderP")] == 0
				MsgInfo(STR0364 +" < "+strzero(i,3)+" >",STR0148) //Quantidade do item nao foi informada... item # Atencao!
				Return(.f.)
			Endif
		Endif 
	Next
Endif*/
//Fim da alteracao




/*
if Inclui .and. VS1->VS1_NUMORC <> M->VS1_NUMORC
dbSelectArea("VS1")
dbSetOrder(1)
if dbSeek(xFilial("VS1")+M->VS1_NUMORC)
M->VS1_NUMORC := GetSXENum("VS1","VS1_NUMORC")
Endif
Endif
*/

&& Verifica se o orcamento ja foi importado para a OS e nao deixa dar manutencao

If !Empty(M->VS1_NUMOSV)
	
	MsgStop(STR0291+M->VS1_NUMOSV+Chr(13)+Chr(10)+STR0293,STR0148 )
	Return(.f.)
	
EndIf


If left(aHeader[2,2],3) == "VS3"
	aColsP := aClone(aCols)
Elseif left(aHeader[2,2],3) == "VS4"
	aColsS := aClone(aCols)
Endif

VS1->(dbSetOrder(1))
if VS1->(dbSeek(xFilial("VS1")+M->VS1_NUMORC))
	if VS1->VS1_NUMPED <> M->VS1_NUMPED
		MsgInfo(STR0359 ,STR0148) //Orcamento precisa ser fechado para atualizacao, pois ja foi finalizado... # Atencao!
		RestArea(aAreaVS1)
		Return(.f.)
	Endif
Endif
RestArea(aAreaVS1)

if lPerg .or. (Len(aTitCre) > 0 .and. nTotCre = 0)
	CHKCRECLI()
Endif

For i:=1 to Len(aColsP)
	if aColsP[i,Len(aColsP[i])]
		lDel := .T.
		Loop
	Endif
	
	if GetMv("MV_CQ") == aColsP[i,FG_POSVAR("VS3_CODTES","aHeaderP")]
		MsgInfo(STR0360 +" "+aColsP[i,FG_POSVAR("VS3_CODTES","aHeaderP")] +" "+ STR0361 ,STR0148)//Armazem # reservado para Controle de Qualidade! # Atencao!
		Return .f.
	Endif
	
	if Empty(aColsP[i,FG_POSVAR("VS3_CODTES","aHeaderP")]) .and. !Empty(aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")])
		MsgInfo(STR0160+aColsP[i,FG_POSVAR("VS3_DESITE","aHeaderP")]+STR0161,STR0148)
		If cOpc<>Nil
			If cOpc=='1'
				MsgInfo(STR0362 ,STR0148) // O Orçamento não foi recalculado###"Atenção
			Endif
		Elseif cOpc==Nil
			MsgInfo(STR0162,STR0148)
		Endif
		Return .f.
	Endif
	if Empty(aColsP[i,FG_POSVAR("VS3_FORMUL","aHeaderP")]) .and. !Empty(aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")])
		MsgInfo(STR0160+aColsP[i,FG_POSVAR("VS3_DESITE","aHeaderP")]+STR0163,STR0148)
		If cOpc<>Nil
			If cOpc=='1'
				MsgInfo(STR0362 ,STR0148) // "O Orçamento não foi recalculado"###"Atenção"
			Endif
		Elseif cOpc==Nil
			MsgInfo(STR0162,STR0148)
		Endif
		Return .f.
	Endif
	If !Empty(aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")])
		lItens := .T.
	Endif
Next
If (lDel .and. !lItens .and. M->VS1_TIPORC == "1") .or. (!lItens .and. M->VS1_TIPORC == "1")
	MsgInfo(STR0531,STR0148) //Informe algum item no Orcamento!, Atencao!
	Return .F.
Endif

// Pecas
if M->VS1_TIPORC == "1"
	For i:=1 to Len(aColsP)
		if aColsP[i,Len(aColsP[i])]
			Loop
		Endif
		if Empty(aColsP[i,FG_POSVAR("VS3_GRUITE","aHeaderP")])
			MsgInfo(STR0363 +" < "+strzero(i,3)+" >",STR0148)//Grupo do Item nao foi informado... item # Atencao!
			Return(.f.)
		Endif
		if Empty(aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")])
			MsgInfo(STR0533 +" < "+strzero(i,3)+" >",STR0148)//Codigo do Item nao foi informado... item # Atencao!
			Return(.f.)
		Endif
		if aColsP[i,FG_POSVAR("VS3_QTDITE","aHeaderP")] == 0
			MsgInfo(STR0364 +" < "+strzero(i,3)+" >",STR0148) //Quantidade do item nao foi informada... item # Atencao!
			Return(.f.)
		Endif
	Next
Endif

if dTos(M->VS1_DATORC) < dTos(dDataBase ) .and. M->VS1_ORCACE <> "0"
	if lPerg
		if MsgYesNo(OemToAnsi(STR0114),OemToAnsi(STR0019))     //"Deseja Recalcular o Orcamento ?","Atencao!"
			FS_CALORC()
			M->VS1_DATORC := dDataBase
		Endif
	Endif
Else
	if cOpc == '1' .and. M->VS1_ORCACE <> "0"
		if MsgYesNo(OemToAnsi(STR0115),OemToAnsi(STR0019))  //"Confirma Recalculo do Orcamento ?"
			FS_CALORC()
			M->VS1_DATORC := dDataBase
		Endif
	Endif
Endif

//if !FG_CHEREV() //Otavio 27/11/2009 - FNC 00000026382/2009
//	Return .f.
//Endif
if lEntrou
	//	For y:=1 to Len(aCols)
	//	   nPos := aScan(aIteD,{|x| x[1]+x[2] == aCols[y,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aCols[y,FG_POSVAR("VS3_CODITE","aHeaderP")]})
	//		If nPos == 0
	//	      aadd(aIteD,{aCols[y,FG_POSVAR("VS3_GRUITE","aHeaderP")],aCols[y,FG_POSVAR("VS3_CODITE","aHeaderP")],0,aCols[y,Len(aCols[y])] })
	//      ElseIf !aCols[y,Len(aCols[y])]
	// 			aIteD[nPos,3] += 1
	//      Endif
	//	Next
	//	If aIteD[1,3] > 0
	//		MSGStop(STR0112)  //"Peca ja lancada no Orcamento, Revise"
	//		oGetPecas:oBrowse:Refresh()
	//		Return(.f.)
	//	EndIf
Endif
If cOpc<>Nil .and. cOpc=='1' .and. lPerg==.F. .and. !lJaGravou
	// Foi clicado no recalculo de orcamento mais o mesmo nem foi gravado ainda.
	Return
Elseif cOpc<>Nil .and. cOpc=='1' .and. lPerg==.F. .and. lJaGravou
	// Foi clicado no recalculo de orcamento o mesmo ja estava gravado,
	// perguntar se o usuario deseja gravar os novos valores
	if !MsgYesNo(OemToAnsi(STR0116),OemToAnsi(STR0019))    //"Confirma Gravacao do Orcamento ?"
		Return .f.
	Endif
Endif

// Utilizado na gravacao do aBlqIte

If lPerg==.F. .and. !lJaGravou
	lNovo := .T.
Elseif lPerg==.F. .and. lJaGravou
	lNovo := .F.
Endif

if (lPerg .and. !lJaGravou) .or. (M->VS1_TIPORC=="2" .and. cOpc<>'1')
	if !MsgYesNo(OemToAnsi(STR0116),OemToAnsi(STR0019))    //"Confirma Gravacao do Orcamento ?"
		Return .f.
	Endif
Endif

dbSelectArea("VAI")
If Empty(M->VS1_CODVEN)
	dbSetOrder(4)
	dbSeek(xFilial("VAI")+__cUserID)
Else
	dbSetOrder(6)
	dbSeek(xFilial("VAI")+M->VS1_CODVEN)
Endif

dbSelectArea("SA3")
dbSetOrder(1)
dbSeek(xFilial("SA3")+VAI->VAI_CODVEN)
cCodVen := SA3->A3_COD

// Cabecalho do Orcamento
Private lMsErroAuto := .F.

Begin Transaction

aMemos := aclone(aMemos1)
dbSelectArea("VS1")
dbSetOrder(1)
if RecLock("VS1",If(dbSeek(xFilial("VS1")+M->VS1_NUMORC),.f.,.t.))
	FG_GRAVAR("VS1")
	VS1->VS1_NUMLIB := cNumLib
	VS1->VS1_NOROUT := cOpeMov2
	VS1->VS1_HORORC := val(left(time(),2)+substr(time(),4,2))
	VS1->VS1_CODVEN := cCodVen
	VS1->VS1_NCLIFT := M->VS1_NCLIFT
	VS1->VS1_VTOTNF := nTotOrc
	if inclui
		ConfirmSx8()
	Endif
	cVar := aMemos[1][2]
	MSMM(,TamSx3("VS1_OBSERV")[1],,&cVar,1,,,"VS1","VS1_OBSMEM")
	MsUnlock()
Else
	DisarmTransaction()
	Break
Endif

dbSelectarea("VS3")
dbSetOrder(1)
if dbSeek(xFilial("VS3")+M->VS1_NUMORC)
	while !Eof() .and. VS3->VS3_NUMORC == M->VS1_NUMORC
		lExist := .f.
		For x_ := 1 to Len(aColsP)
			if aColsP[x_,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[x_,FG_POSVAR("VS3_CODITE","aHeaderP")] == VS3->VS3_GRUITE+VS3->VS3_CODITE
				lExist := .t.
				Exit
			Endif
		Next
		if !lExist
			RecLock("VS3",.f.,.t.)
			VS3->(dbDelete())
			MsUnlock()
			WriteSx2("VS3")
		Endif
		dbSelectArea("VS3")
		dbSkip()
	Enddo
Endif

dbSelectarea("VS4")
dbSetOrder(1)
if dbSeek(xFilial("VS4")+M->VS1_NUMORC)
	while !Eof() .and. VS4->VS4_NUMORC == M->VS1_NUMORC
		lExist := .f.
		If FG_POSVAR("VS4_CODSER","aHeaderS") > 0
			For x_ := 1 to Len(aColsS)
				if aColsS[x_,FG_POSVAR("VS4_CODSER","aHeaderS")] == VS4->VS4_CODSER
					lExist := .t.
				Endif
			Next
		EndIf
		if !lExist
			RecLock("VS4",.f.,.t.)
			VS4->(dbDelete())
			MsUnlock()
			WriteSx2("VS4")
		Endif
		dbSelectArea("VS4")
		dbSkip()
	Enddo
Endif

// Pecas
For i:=1 to Len(aColsP)
	if !Empty(aColsP[i,FG_POSVAR("VS3_SEQUEN","aHeaderP")]) .and. !Empty(aColsP[i,FG_POSVAR("VS3_GRUITE","aHeaderP")])
		dbSelectarea("VS3")
		dbSetOrder(2)
		if dbSeek(xFilial("VS3")+M->VS1_NUMORC+aColsP[i,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")]+aColsP[i,FG_POSVAR("VS3_SEQUEN","aHeaderP")])
			if aColsP[i,Len(aColsP[i])] == .t.
				if RecLock("VS3",.f.,.t.)
					VS3->(dbDelete())
					MsUnlock()
					WriteSx2("VS3")
				Else
					DisarmTransaction()
					Break
				Endif
			Else
				if RecLock("VS3",.F.)
					FG_GRAVAR("VS3",aColsP,aHeaderP,i)
					VS3->VS3_FILIAL := xFilial("VS3")
					VS3->VS3_NUMORC := VS1->VS1_NUMORC
					MsUnlock()
				Else
					DisarmTransaction()
					Break
				Endif
			Endif
		Else
			if aColsP[i,Len(aColsP[i])] == .f.
				if RecLock("VS3",.T.)
					FG_GRAVAR("VS3",aColsP,aHeaderP,i)
					VS3->VS3_FILIAL := xFilial("VS3")
					VS3->VS3_NUMORC := VS1->VS1_NUMORC
					VS3->VS3_VALTOT := (VS3->VS3_VALPEC * VS3->VS3_QTDITE)-VS3->VS3_VALDES
					MsUnlock()
				Else
					DisarmTransaction()
					Break
				Endif
			Endif
		Endif
	Endif
Next

// Servicos
For i:=1 to Len(aColsS)
	if !Empty(aColsS[i,FG_POSVAR("VS4_SEQUEN","aHeaderS")]) .and. !Empty(aColsS[i,FG_POSVAR("VS4_GRUSER","aHeaderS")]) .and. !Empty(aColsS[i,FG_POSVAR("VS4_CODSER","aHeaderS")])
		dbSelectarea("VS4")
		dbSetOrder(2)
		if dbSeek(xFilial("VS4")+M->VS1_NUMORC+aColsS[i,FG_POSVAR("VS4_CODSER","aHeaderS")])
			if aColsS[i,Len(aColsS[i])] == .t.
				if RecLock("VS4",.f.,.t.)
					VS4->(dbDelete())
					MsUnlock()
					WriteSx2("VS4")
				Else
					DisarmTransaction()
					Break
				Endif
			Else
				if RecLock("VS4",.F.)
					FG_GRAVAR("VS4",aColsS,aHeaderS,i)
					VS4->VS4_FILIAL := xFilial("VS4")
					VS4->VS4_NUMORC := VS1->VS1_NUMORC
					MsUnlock()
				Else
					DisarmTransaction()
					Break
				Endif
			Endif
		Else
			if aColsS[i,Len(aColsS[i])] == .f.
				if RecLock("VS4",.T.)
					FG_GRAVAR("VS4",aColsS,aHeaderS,i)
					VS4->VS4_FILIAL := xFilial("VS4")
					VS4->VS4_NUMORC := VS1->VS1_NUMORC
					MsUnlock()
				Else
					DisarmTransaction()
					Break
				Endif
			Endif
		Endif
	Endif
Next

dbSelectarea("VS3")
dbSetOrder(1)

dbSelectarea("VS4")
dbSetOrder(1)

//Salva o posionamento original dos arquivos tal como sua ordem
aSx3 := SX3->(GetArea())
aVs1 := VS1->(GetArea())
aVs3 := VS3->(GetArea())
aVs4 := VS4->(GetArea())

//Verifica se o Item esta reservado e transfere p/ almoxarifado reservado
if Len(aIteRes) == 0
	aIteRes := {}
	For xi_:=1 to Len(aColsP)
		aadd(aIteRes,{aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")],aColsP[xi_,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[xi_,FG_POSVAR("VS3_CODITE","aHeaderP")],0 })
	Next
Endif

if !lJaMovPec
	For y:= 1 To Len(aColsP)
		_nQtd    := aColsP[y,FG_POSVAR("VS3_QTDITE","aHeaderP")]
		_cGruIte := aColsP[y,FG_POSVAR("VS3_GRUITE","aHeaderP")]
		_cCodIte := aColsP[y,FG_POSVAR("VS3_CODITE","aHeaderP")]
		
		if Empty(_cGruIte) .or. Empty(_cCodIte)
			Loop
		Endif
		
		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xFilial("SB1")+_cGruIte+_cCodIte)
		nSaldo  := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+LocIte110(.f.,aColsP,y))
		nPos := aScan(aIteBlq,{|x| x[1] == aColsP[y,FG_POSVAR("VS3_SEQUEN","aHeaderP")]})
		FS_TRANSFER(nSaldo,_nQtd,nPos,_nQtd,.F.,y)      // ajusta antes de gravar
		FS_TRANSFER(nSaldo,_nQtd,nPos,_nQtd,.F.,y,.T.) // efetua a gravacao
		// zera os campos se nao for aceito
		If M->VS1_ORCACE=="1"
			Fs_GravaRes(VS3->(dbSeek(xFilial("VS3")+M->VS1_NUMORC+aColsP[y,FG_POSVAR("VS3_SEQUEN","aHeaderP")])),0)
		Else
			if aIteRes[y,3] == 0
				aIteRes[y,3] := aColsP[y,FG_POSVAR("VS3_QTDITE","aHeaderP")]
			Endif
		Endif
	Next
	lJaMovPec := .t.
Endif

//Restaura o posionamento original dos arquivos tal como sua ordem
SX3->(RestArea(aSx3))
VS1->(RestArea(aVs1))
VS3->(RestArea(aVs3))
VS4->(RestArea(aVs4))

lJaGravou := .t.

End Transaction

If lMsErroAuto
	MostraErro()
Endif

//if !lSalvou
//	if MsgYesNo(OemToAnsi("Salvar Negociacao de Pagamento?"),OemToAnsi(STR0148))
FS_SALVAR()
lSalvou := .t.
//	Endif
//Endif

if oFolder2:nOption == 1
	aHeader := aClone(aHeaderP)
	aCols   := aClone(aColsP)
	//	n := nP
	n := oGetPecas:oBrowse:nAt
	oGetPecas:oBrowse:SetFocus()
	oGetPecas:oBrowse:Refresh()
Else
	aHeader := aClone(aHeaderS)
	aCols   := aClone(aColsS)
	//	n := nS
	n := oGetSrvcs:oBrowse:nAt
	oGetSrvcs:oBrowse:SetFocus()
	oGetSrvcs:oBrowse:Refresh()
Endif

aArea := SA1->(GetArea())
if lExecBlq
	if ExistBlock("OFM110C")
		ExecBlock("OFM110C",.f.,.f.)
	EndIf
Endif
SA1->(RestArea(aArea))

//Restaura o posionamento original dos arquivos tal como sua ordem
SX3->(RestArea(aSx3))
VS1->(RestArea(aVs1))
VS3->(RestArea(aVs3))
VS4->(RestArea(aVs4))

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CALCORC  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula o Orcamento                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CALORC()

Local nOld := n
Local ix1 := 0
Local y:=0

Private nPos

// Recalcula Orcamento de Pecas
dbSelectArea("VAI")
If Empty(M->VS1_CODVEN)
	dbSetOrder(4)
	dbSeek(xFilial("VAI")+__cUserID)
Else
	dbSetOrder(6)
	dbSeek(xFilial("VAI")+M->VS1_CODVEN)
Endif

dbSelectArea("SA3")
dbSetOrder(1)
if !dbSeek(xFilial("SA3")+VAI->VAI_CODVEN)
	MsgInfo(STR0365 ,STR0148) //Usuario sem codigo de vendedor relacionado! # Atencao !
	Return .f.
Endif
cCodVen := SA3->A3_COD
cCenCus := VAI->VAI_CC

If Len(aColsP) > 0
	
	For ix1 := 1 to Len(aColsP)
		if !aColsP[ix1,Len(aColsP[ix1])]
			n := ix1
			cKeyAce := aColsP[IX1,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[ix1,FG_POSVAR("VS3_CODITE","aHeaderP")]
			FG_Seek("SB1","cKeyAce",7,.f.)
			if cOpeMov2 == "2"
				if Empty(M->VS3_FORMUL)
					M->VS3_FORMUL := GETMV("MV_FMLPECA")
					if Type("M->VS3_FORMUL") <> "C"
						M->VS3_FORMUL := SPACE(LEN(VS3->VS3_FORMUL))
					Endif
				Endif
			Endif
			nPos    := ix1
			nValPec := FG_VALPEC(M->VS1_TIPTEM,'aColsP[nPos,FG_POSVAR("VS3_FORMUL","aHeaderP")]',aColsP[nPos,FG_POSVAR("VS3_GRUITE","aHeaderP")],aColsP[nPos,FG_POSVAR("VS3_CODITE","aHeaderP")],'aColsP[nPos,FG_POSVAR("VS3_VALPEC","aHeaderP")]',.f.,.t.)
			FS_PROMOCAO(cCodMar,cCenCus,M->VS3_GRUITE,M->VS3_CODITE)
			
			aColsP[ix1,FG_POSVAR("VS3_VALPEC","aHeaderP")] := nValPec
			aColsP[ix1,FG_POSVAR("VS3_VALTOT","aHeaderP")] := (nValPec-aColsP[ix1,FG_POSVAR("VS3_VALDES","aHeaderP")])  * aColsP[ix1,FG_POSVAR("VS3_QTDITE","aHeaderP")]
			MaFisRef("IT_VALMERC" ,"VS300",aColsP[ix1,FG_POSVAR("VS3_QTDITE","aHeaderP")]*nValPec)
			MaFisRef("IT_TES"     ,"VS300",aColsP[ix1,FG_POSVAR("VS3_CODTES","aHeaderP")])
			MaFisRef("IT_DESCONTO","VS300",aColsP[ix1,FG_POSVAR("VS3_VALDES","aHeaderP")])
		Else
			n := ix1
			MaFisRef("IT_VALMERC" ,"VS300",0)
			MaFisRef("IT_TES"     ,"VS300",aColsP[ix1,FG_POSVAR("VS3_CODTES","aHeaderP")])
			MaFisRef("IT_DESCONTO","VS300",0)
		Endif
	Next
	
Endif

If (cPaisLoc == "BRA") // Manoel - 07/05/2009
	For y:=1 to Len(aColsP)
		n := y
		if !Empty(aColsP[n,fg_posvar("VS3_CODTES","aHeaderP")])
			if !aColsP[n,Len(aColsP[n])]
				aColsP[n,fg_posvar("VS3_VBAICM","aHeaderP")] := MaFisRet(n,"IT_BASEICM")
				aColsP[n,fg_posvar("VS3_ALIICM","aHeaderP")] := MaFisRet(n,"IT_ALIQICM")
				aColsP[n,fg_posvar("VS3_ICMCAL","aHeaderP")] := MaFisRet(n,"IT_VALICM")
			Endif
		Endif
	Next
	n := nOld
Endif

if M->VS1_VTOTNF+M->VS1_VALDES+M->VS1_ICMCAL+M->VS1_DESACE+M->VS1_VALFRE+M->VS1_VALSEG > 0
	M->VS1_VTOTNF := MaFisRet(,"NF_TOTAL")-MaFisRet(,"NF_DESCZF")
	M->VS1_VALDES := MaFisRet(,"NF_DESCONTO")
	M->VS1_ICMCAL := MaFisRet(,"NF_VALICM")
	M->VS1_DESACE := MaFisRet(,"NF_DESPESA")
	
	M->VS1_VALFRE := MaFisRet(,"NF_FRETE")
	M->VS1_VALSEG := MaFisRet(,"NF_SEGURO")
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PREFAT   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Pega Cliente a Faturar                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PREFAT()

Local cPesq := M->VS1_CLIFAT

if !Empty(M->VS1_LOJA)
	cPesq += M->VS1_LOJA
Endif

cAlias := Alias()

dbSelectArea("SA1")
if dbSeek(xFilial("SA1")+cPesq)
	FP_IniImp(M->VS1_CLIFAT,M->VS1_LOJA)
Else
	if !Empty(M->VS1_CLIFAT)
		MsgInfo(STR0366 ,STR0148) //Cliente nao encontrado... # Atencao!
		Return .f.
	Endif
Endif

if Empty(M->VS1_CLIFAT)
	Return .t.
Endif

if lVAMCid
	FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
Endif

M->VS1_NCLIFT := SA1->A1_NOME
M->VS1_ENDCLI := SA1->A1_END
if lVAMCid
	M->VS1_CIDCLI := VAM->VAM_DESCID
	M->VS1_ESTCLI := VAM->VAM_ESTADO
Else
	M->VS1_CIDPRO := SA1->A1_MUN
	M->VS1_ESTPRO := SA1->A1_EST
Endif
M->VS1_FONCLI := SA1->A1_TEL

dbSelectArea(cAlias)

if SA1->A1_MSBLQL == "1"
	MsgInfo(STR0367 ,STR0148) //Este cliente esta bloqueado... # Atencao!
	Return(.f.)
Endif

aTitCre := {}
If Alltrim(GetNewPar("MV_TITNCC","N")) == "S"
	dbSelectArea("SE1")
	dbSetOrder(2)
	dbSeek(xFilial("SE1")+M->VS1_CLIFAT+M->VS1_LOJA)
	while !EOF() .and. M->VS1_CLIFAT == SE1->E1_CLIENTE .and. M->VS1_LOJA == SE1->E1_LOJA
		if SE1->E1_SALDO > 0 .and. SE1->E1_TIPO == "NCC"
			aadd(aTitCre,{.f.,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_VENCTO,SE1->E1_SALDO,recno()})
		Endif
		dbSelectArea("SE1")
		dbSkip()
	Enddo
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERCPO   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Quando for Orcamento de Servico Valida Alguns Campos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CLIENTE()

//aArea := &(Alias())+->(GetArea()
M->VS1_CLIFAT := space(TamSx3("VS1_CLIFAT")[1])
M->VS1_LOJA   := space(TamSx3("VS1_LOJA")[1])
//M->VS1_NCLIFT := left(M->VS1_NCLIFT+space(50),(TamSx3("A1_NOME")[1]))
if ReadVar() == "M->VS1_NCLIFT"
	dbSelectArea("SA1")
	dbSetOrder(2)
	if dbSeek(xFilial("SA1")+M->VS1_NCLIFT)
		M->VS1_CLIFAT := SA1->A1_COD
		M->VS1_LOJA   := SA1->A1_LOJA
	Endif
	dbSetOrder(1)
	FP_INIIMP(M->VS1_CLIFAT,M->VS1_LOJA)
	FPREFRESH()
Endif

//RestArea(aArea)

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERCPO   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Quando for Orcamento de Servico Valida Alguns Campos        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VERCPO()

If M->VS1_TIPORC == "2"
	If Empty(M->VS1_FORMUL) .or. Empty(M->VS1_FORPAG) .or. Empty(M->VS1_GETKEY) .or. Empty(M->VS1_KILOME) .or. Empty(M->VS1_TIPTEM)
		Return .f.
	Endif
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERPEC   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se o Item possue Estoque e se foi Substituido      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VERPEC(lMsg)

Local lReturn := .t.
Local y

Local x := 0
Local i := 0
//Local aIteD := {}

Local nPos := 0
Default lMsg := .t.

if Left(Funname(),4) == "OFIX" .or. FunName() == "OFIOM350" .or. FunName() == "OFIOM430" .or. FunName() == "M_CONSPEC"
	return .t.
endif

FG_MEMVAR()

//Se nao for digitado codigo inteiro da peca mostra os codigos com aquele conteudo
if !FS_PESQPECA(aCols[n,FG_POSVAR("VS3_GRUITE","aHeaderP")],M->VS3_CODITE)
	//   Return .f.
Endif
if SB1->B1_MSBLQL $ "1S"
	MsgAlert(STR0368,STR0019)//O Produto escolhido esta bloqueado para a venda!
endif
if FG_VLGRIT(M->VS3_GRUITE+M->VS3_CODITE)
	nSaldo := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+LocIte110())
	nPos := aScan(aIteBlq,{|x| x[1] == M->VS3_SEQUEN })
	SF4->(DbSeek(xFilial("SF4")+aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")]))
	if nSaldo <= 0 .and. SF4->F4_ESTOQUE == "S"
		if Type("M->VS3_QTDEST") == "U"
			MsgInfo(STR0166+Alltrim(SB1->B1_GRUPO)+" "+Alltrim(SB1->B1_CODITE)+" - "+Alltrim(SB1->B1_DESC)+STR0167,STR0148)
		Endif
	Endif
	//    nPos := aScan(aIteD,{|x| x[1]+x[2] == M->VS3_GRUITE+M->VS3_CODITE})
	//    If nPos == 0
	//	   aadd(aIteD,{M->VS3_GRUITE,M->VS3_CODITE,0,aCols[y,Len(aCols[y])] })
	//       aadd(aIteD,{M->VS3_GRUITE,M->VS3_CODITE,0})
	//    Else//If !aCols[y,Len(aCols[y])]
	for i := 1 to Len(aheader)
		if "Grupo" $ aheader[i,1]
			nPosGrp := i
		Endif
		if "Codigo" $ aheader[i,1]
			nPosCod := i
		Endif
	Next
	nPos1 := aScan(aCols,{|x| x[nPosGrp]+x[nPosCod] == M->VS3_GRUITE+M->VS3_CODITE})
	if nPos1 > 0
		nAchou := 0
		For y := 1 to Len(aCols)
			if y <> n
				if !aCols[y,Len(aCols[y])] .and. aCols[y,nPosGrp]+aCols[y,nPosCod] == M->VS3_GRUITE+M->VS3_CODITE
					nAchou := 1
				Endif
			Endif
		Next
		if nAchou == 1
			MSGStop(STR0112)  //"Peca ja lancada no Orcamento, Revise"
			oGetPecas:oBrowse:Refresh()
			Return(.f.)
		EndIf
	Endif
	//	Endif   
	if ReadVar() <> "M->VS3_LOCAL"
		M->VS3_CODITE := FG_ITESUB(M->VS3_GRUITE+M->VS3_CODITE)

	Endif
	lReturn := FG_SEEK("SB1","M->VS3_GRUITE+M->VS3_CODITE",7,.F.,"VS3_DESITE","B1_DESC")
	if lReturn
		lReturn := FS_PRECPO("P")
		dbSelectArea("SB1")
		dbSetOrder(7)
		if lReturn
			lReturn := dbSeek(xFilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE)
		Endif
	Endif
Else
	lReturn := .f.
	If ReadVar()=="M->VS3_CODITE" .and. Empty(M->VS3_CODITE)
		Return lReturn
	Endif
	if lMsg
		MsgInfo(STR0168,STR0148)
	Endif
Endif
FS_ITEREL110()
Return(lReturn)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_TIPTEM100³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atribui valor para a Formula de Preco de acordo com T.Tempo ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TIPTEM100()

Local lRet := .T.

VOI->(dbSetOrder(1))
VOI->(dbSeek(xfilial("VOI")+M->VS1_TIPTEM))

If M->VS1_TIPORC == "2"
	If Empty(VOI->VOI_VALPEC)  //FNC 1834/2010 - BOBY
	    MsgStop(STR0534)       //Campo ->'Fórmula Vlr' no Cadastro de Tipo de Tempo, não Informado, Informe-o para Prosseguir o Orçamento
		lRet := .F.
		Return lRet
	Else
		FG_ATRVAL("VS1_FORMUL","VOI->VOI_VALPEC")
	EndIf
Endif

FG_VALIDA(,"VEGT1M->VS1_FORMUL*","VS1_NOMFOR := VEG_DESCRI")

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³BROWSEORC   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Browse dos Orcamentos Gravados e Nao Vendidos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BrowseOrc(lArray)

Local cChassi := ""
Local cPlaca  := ""
Local lRet    := .t.

Local cAliasVS1:= "AliasVS1"
Local cQuery   := ""
Private aNewBot := {{"DBG12",{|| lYesNo := !lYesNo, Fs_MosVen()},STR0169},;
{"EDIT",{ || Fs_PopupMenu()},STR0170}}
Private nLinOrc  := 1
Private lYesNo   := .t.
Private cYesNoTxt:= STR0171
Private oYesNotxt
Private nLinha
Private oDlg2
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

cCadastro:= STR0172

//if lArray == Nil .or. Len(aIteBrw) == 0
aIteBrw := {}

cQuery := "SELECT VS1.VS1_NUMORC , VS1.VS1_TIPORC , VS1.VS1_DATORC , VS1.VS1_HORORC , VS1.VS1_DATVAL , VS1.VS1_VTOTNF , VS1.VS1_NUMOSV , VS1.VS1_ORCACE , VS1.VS1_CHAINT , VS1.VS1_CLIFAT , VS1.VS1_LOJA , VS1.VS1_CODVEN , VS1.VS1_NCLIFT "
cQuery += "FROM "+RetSqlName("VS1")+" VS1 WHERE VS1.VS1_FILIAL='"+xFilial("VS1")+ "' AND VS1.VS1_NUMNFI='"+space(len(VS1->VS1_NUMNFI))+"' AND VS1.VS1_DATVAL>='"+dtos(dDataBase)+"' AND "
if Alltrim(GetNewPar("MV_FILVDB","")) <> ""
	dbSelectArea("VAI")
	If Empty(M->VS1_CODVEN)
		dbSetOrder(4)
		cSeekCV := __cUserID
	Else
		dbSetOrder(6)
		cSeekCV := M->VS1_CODVEN
	Endif
	if dbSeek(xFilial("VAI")+cSeekCV)
		if !(VAI->VAI_CODVEN $ GetNewPar("MV_FILVDB",""))
			cQuery += "VS1.VS1_CODVEN='"+VAI->VAI_CODVEN+"' AND "
		Endif
	Endif
Endif
cQuery += "VS1.VS1_PESQLJ='"+space(len(VS1->VS1_PESQLJ))+"' AND VS1.D_E_L_E_T_=' ' ORDER BY VS1.VS1_NUMORC DESC "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVS1,.T.,.T.)
Do While !( cAliasVS1 )->( Eof() )
	dDt1 := stod( (cAliasVS1)->( VS1_DATORC ) )
	dDt2 := stod( (cAliasVS1)->( VS1_DATVAL ) )
	cChassi := ""
	cPlaca  := ""
	if (cAliasVS1)->VS1_TIPORC == "2"
		if !Empty((cAliasVS1)->VS1_CHAINT)
			dbSelectArea("VV1")
			dbSetOrder(1)
			if dbSeek(xFilial("VV1")+(cAliasVS1)->VS1_CHAINT)
				cChassi := VV1->VV1_CHASSI
				cPlaca  := VV1->VV1_PLAVEI
			Endif
			dbSelectArea(cAliasVS1)
		Endif
	Endif
	
	cNomCli := (cAliasVS1)->VS1_NCLIFT
	SA1->(dbSetOrder(1))
	if SA1->(dbSeek(xFilial("SA1")+(cAliasVS1)->VS1_CLIFAT+(cAliasVS1)->VS1_LOJA))
		cNomCli := SA1->A1_NOME
	Endif
	
	cNomVen := ""
	SA3->(dbSetOrder(1))
	if SA3->(dbSeek(xFilial("SA3")+(cAliasVS1)->VS1_CODVEN))
		cNomVen := SA3->A3_NOME
	Endif
	
	aAdd(aIteBrw,{if((cAliasVS1)->VS1_ORCACE=="0",.t.,.f.), substr(cNomCli,1,20), (cAliasVS1)->VS1_NUMORC, substr(cNomVen,1,15),if((cAliasVS1)->VS1_TIPORC=="1",STR0379,STR0380) ,dDt1,Transform((cAliasVS1)->VS1_HORORC,"@R 99:99"),dDt2,cChassi,cPlaca,(cAliasVS1)->VS1_VTOTNF,(cAliasVS1)->VS1_NUMOSV}) //pecas # Srv/pec
	
	dbSelectArea(cAliasVS1)
	dbSkip()
Enddo
dbSelectArea(cAliasVS1)
dbCloseArea()

if Len(aIteBrw) == 0
	aadd(aIteBrw,{.f.," "," "," "," ",ctod("")," ",ctod("")," "," "," "," "})
	MsgInfo(STR0117,STR0019)  //"Nenhum Orcamento para ser Aberto!","Atencao!"
	dbSelectArea("VS1")
	if !MsgYesNo(STR0174,STR0148)
		oFolder:nOption := 1
		Return .f.
	Else
		lYesNo := .t.
		FS_MOSVEN(.f.)
	Endif
Endif
oFolder:nOption := 2
//Endif

dbSelectArea("VS1")
dbSetOrder(1)

if Len(aIteBrw) == 0
	aadd(aIteBrw,{.f.," "," "," "," ",ctod("")," ",ctod("")," "," "," "," "})
Endif

//Asort(aIteBrw,,,{|x,y| x[3] > y[3] })

xOpca  := 0
cOrcto := space(8)

DEFINE MSDIALOG oDlg2 FROM  04,10 TO 39,90 TITLE cCadastro OF oMainWnd

@ 014, 001 SAY STR0175 SIZE 45,08 OF oDlg2 PIXEL COLOR CLR_BLUE
@ 013, 031 MSGET oOrcto VAR cOrcto PICTURE "@!" SIZE 55,08 OF oDlg2 PIXEL COLOR CLR_HBLUE

@ 013, 095 BUTTON oPesOrc  PROMPT OemToAnsi(STR0369) OF oDlg2 SIZE 43,11 PIXEL ACTION (cOrcto := StrZero(val(cOrcto),8),if((nLinha := FS_VALCHAVE(cOrcto))>0,(oLbHd2:nAt := nLinha,oLbHd2:Refresh()),.t.)) //Pesquisar

@ 014, 160 SAY oYesNoTxt VAR cYesNoTxt SIZE 165,08 OF oDlg2 PIXEL COLOR CLR_BLUE
//oOrcto:bChange := {|| cOrcto := StrZero(val(cOrcto),8),if((nLinha := FS_VALCHAVE(cOrcto))>0,(xOpca:=1,oDlg2:End()),.t.) }

@ 025, 001 LISTBOX oLbHd2 FIELDS HEADER	OemToAnsi(""),;  //STR00306
OemToAnsi(STR0118),;		//Nome Cliente
OemToAnsi(STR0119),;		//Orcamento
OemToAnsi(STR0120),;		//Vendedor
OemToAnsi(STR0370),;		//Total
OemToAnsi(STR0371),;		//Tipo Orcamento
OemToAnsi(STR0122),;		//Data
OemToAnsi(STR0123),;		//Hora
OemToAnsi(STR0124),;		//Validade
OemToAnsi(STR0372),;		//Chassi
OemToAnsi(STR0373),;		//Placa
OemToAnsi(STR0374);			//Nro OS
COLSIZES 30,90,20,50,30,25,30,25,30,70,30,30;
SIZE 315,239 OF oDlg2 PIXEL ON DBLCLICK (nLinha := oLbHd2:nAt, xOpca := 1, oDlg2:End())

oLbHd2:SetArray(aIteBrw)
oLbHd2:bLine := { || { IIF(aIteBrw[oLbHd2:nAt,1],oOk,oNo) ,;
aIteBrw[oLbHd2:nAt,2] ,;
aIteBrw[oLbHd2:nAt,3] ,;
aIteBrw[oLbHd2:nAt,4] ,;
FG_AlinVlrs(Transform(aIteBrw[oLbHd2:nAt,11],"@E 9,999,999.99")) ,;
aIteBrw[oLbHd2:nAt,5] ,;
Transform(aIteBrw[oLbHd2:nAt,6],"@D") ,;
aIteBrw[oLbHd2:nAt,7] ,;
Transform(aIteBrw[oLbHd2:nAt,8],"@D") ,;
aIteBrw[oLbHd2:nAt,9] ,;
aIteBrw[oLbHd2:nAt,10] ,;
aIteBrw[oLbHd2:nAt,12] }}

ACTIVATE MSDIALOG oDlg2 CENTER ON INIT (EnchoiceBar(oDlg2,{|| xOpca := 1,oDlg2:End(),nLinha := oLbHd2:nAt},{|| xOpca := 2,oDlg2:End()},,aNewBot))

if xOpca == 1
	if lDestroy
		FS_DESTROY()
		lDestroy := .f.
		lJaPerg  := .t.
	Endif
	Fs_AbreOrc(nLinha)
Else
	lRet := .f.
Endif

&& Verifica se o orcamento ja foi importado para a OS e nao deixa dar manutencao

oGetMGet:oBox:Enable()
oGetSrvcs:oBrowse:Enable()
oGetPecas:oBrowse:Enable()

oGetMGet:lActive := .t.
oGetSrvcs:lActive := .t.
oGetPecas:lActive := .t.
oLbIteRel:Enable()

lBotOpc := .t.

If !Empty(VS1->VS1_NUMOSV)
	
	MsgStop(STR0291+M->VS1_NUMOSV+Chr(13)+Chr(10)+STR0292,STR0148 )
	
	lBotOpc := .f.
	
	oGetMGet:lActive := .f.
	oGetSrvcs:lActive := .f.
	oGetPecas:lActive := .f.
	oLbIteRel:Disable()
	
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_POPUPMENU³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Filtra os Orcamentos Gravados                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_POPUPMENU()

Local oLbxMenu
Local cIte := " "
Local aIte := {STR0286,STR0176,STR0177,STR0178,STR0179,STR0180,STR0181}

Private oDlgMenu

DEFINE MSDIALOG oDlgMenu TITLE OemtoAnsi(STR0182) FROM  02,04 TO 07,31 OF oMainWnd // "Menu de Opcoes"

@ 1,1 LISTBOX oLbxMenu VAR cIte ITEMS aIte SIZE 070, 035  OF oDlgMenu PIXEL ON DBLCLICK FS_EXECFUN(oDlgMenu,oLbxMenu:nAt)

DEFINE SBUTTON oOk1 TYPE 1 FROM 02,75 OF oDlgMenu ENABLE ONSTOP OemToAnsi(STR0028)       ACTION FS_EXECFUN(oDlgMenu,oLbxMenu:nAt)
oOk1:cToolTip := OemToAnsi(STR0028) 	// Ok
DEFINE SBUTTON oOk2 TYPE 2 FROM 18,75 OF oDlgMenu ENABLE ONSTOP OemToAnsi(STR0158) ACTION (oDlgMenu:End())
oOk2:cToolTip := OemToAnsi(STR0158)		// "Cancelar

ACTIVATE MSDIALOG oDlgMenu CENTER

oLbHd2:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_EXECFUN  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Executa as Funcoes do menu                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_EXECFUN(oDlgMenu,nPosLbx)

Do Case
	Case nPoslbx == 1
		FS_RUNMENU(nPosLbx)
	Case nPoslbx == 2
		FS_RUNMENU(nPosLbx)
	Case nPoslbx == 3
		xOpca := 1
		nLinha := oLbHd2:nAt
		oDlg2:End()
	Case nPoslbx == 4
		FS_EXCLUIORC()
	Case nPoslbx == 5
		FS_RUNMENU(nPosLbx)
	Case nPoslbx == 6
		FS_RUNMENU(nPosLbx)
	Case nPoslbx == 7
		FS_RUNMENU(nPosLbx)
EndCase

oDlgMenu:End()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_RUNMENU  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Executa as Funcoes do menu                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_RUNMENU(nPosLbx)

Local x_ :=0

if nPosLbx == 1
	cTipOrd   := " "
	aTipOrd   := {STR0287,STR0184,STR0288,STR0375}//Numero # Data # Cliente # Vendedor+Cliente+Data
	lOk := .t.
	DEFINE MSDIALOG oDlgNew TITLE OemtoAnsi(STR0185) FROM  02,04 TO 08,31 OF oMainWnd
	
	@ 02, 01 SAY STR0186  SIZE 40,08 OF oDlgNew PIXEL COLOR CLR_BLUE
	@ 02, 30 MSCOMBOBOX oTipPes VAR cTipOrd SIZE 70,50 ITEMS aTipOrd OF oDlgNew PIXEL
	
	DEFINE SBUTTON oOk1 TYPE 1 FROM 26,15 OF oDlgNew ENABLE ONSTOP OemToAnsi(STR0028) ACTION (lOk := .t.,oDlgNew:End())
	oOk1:cToolTip := OemToAnsi(STR0028) // ok
	DEFINE SBUTTON oOk2 TYPE 2 FROM 26,65 OF oDlgNew ENABLE ONSTOP OemToAnsi(STR0158) ACTION (lOk := .f.,oDlgNew:End())
	oOk2:cToolTip := OemToAnsi(STR0158) //"Cancelar
	
	ACTIVATE MSDIALOG oDlgNew CENTER
	if lOk
		if cTipOrd == STR0287                       //Numero
			Asort(aIteBrw,,,{|x,y| x[3] > y[3] })
		Elseif cTipOrd == STR0184                   //Data
			Asort(aIteBrw,,,{|x,y| dtos(x[6]) > dtos(y[6]) })
		Elseif cTipOrd == STR0288                   //Cliente
			Asort(aIteBrw,,,{|x,y| x[2] < y[2] })
		Elseif cTipOrd == STR0375					//Vendedor+Cliente+Data
			Asort(aIteBrw,,,{|x,y| x[4]+x[2] < y[4]+y[2] .and. dtos(x[6]) < dtos(y[6]) })
		Endif
	Endif
	
	oLbHd2:Refresh()
	
Elseif nPosLbx == 2
	cTipPes   := " "
	aTipPes   := {STR0183,STR0184,STR0376} //Nome,Data,(Chassi,Placa)
	cPesquisa := Space(100)
	lOk := .t.
	DEFINE MSDIALOG oDlgNew TITLE OemtoAnsi(STR0185)FROM  02,04 TO 08,31 OF oMainWnd // "Alteracao da Validade"
	
	@ 02, 01 SAY STR0186 SIZE 40,08 OF oDlgNew PIXEL COLOR CLR_BLUE
	@ 02, 30 MSCOMBOBOX oTipPes VAR cTipPes SIZE 70,50 ITEMS aTipPes OF oDlgNew PIXEL
	
	@ 16, 01 MSGET oPesquisa  VAR cPesquisa  PICTURE "@!" SIZE 100,08 OF oDlgNew PIXEL COLOR CLR_HBLUE
	
	DEFINE SBUTTON oOk1 TYPE 1 FROM 26,15 OF oDlgNew ENABLE ONSTOP STR0028       ACTION (lOk := .t.,FS_PESBRW(cTipPes,cPesquisa),oDlgNew:End())//OK
	oOk1:cToolTip := OemToAnsi(STR0028) // Ok
	DEFINE SBUTTON oOk2 TYPE 2 FROM 26,65 OF oDlgNew ENABLE ONSTOP "Cancelar" ACTION (lOk := .f.,oDlgNew:End()) //Cancelar
	oOk2:cToolTip := OemToAnsi(STR0158) // "Cancelar
	
	ACTIVATE MSDIALOG oDlgNew CENTER
	
Elseif nPosLbx == 5
	dbSelectArea("VS1")
	dbSetOrder(1)
	dbSeek(xFilial("VS1")+aIteBrw[oLbHd2:nAt,3])
	dNewDate := VS1->VS1_DATVAL
	lOk := .t.
	DEFINE MSDIALOG oDlgNew TITLE OemtoAnsi(STR0187) FROM  02,04 TO 08,31 OF oMainWnd
	
	@ 02, 005 SAY   STR0188  SIZE 40,08 OF oDlgNew PIXEL COLOR CLR_BLUE
	@ 02, 040 MSGET oNewDate  VAR dNewDate  PICTURE "@D" VALID (dNewDate >= dDataBase) SIZE 58,08 OF oDlgNew PIXEL COLOR CLR_HBLUE
	
	DEFINE SBUTTON oOk1 TYPE 1 FROM 20,05 OF oDlgNew ENABLE ONSTOP STR0028       ACTION (lOk := .t.,oDlgNew:End())//OK
	oOk1:cToolTip := OemToAnsi(STR0028) //Ok
	DEFINE SBUTTON oOk2 TYPE 2 FROM 20,65 OF oDlgNew ENABLE ONSTOP STR0158 ACTION (lOk := .f.,oDlgNew:End())
	oOk2:cToolTip := OemToAnsi(STR0158) // "Cancelar"
	
	ACTIVATE MSDIALOG oDlgNew CENTER
	if lOk
		RecLock("VS1",.f.)
		VS1->VS1_DATVAL := dNewDate
		MsUnlock()
		aIteBrw[oLbHd2:nAt,8] := dNewDate
	Endif
Elseif nPosLbx == 6
	aIteSlv := aClone(aIteBrw)
	cNewDate1 := dDataBase-1
	cNewDate2 := dDataBase
	lOk := .t.
	DEFINE MSDIALOG oDlgNew TITLE OemtoAnsi(STR0189) FROM  02,04 TO 08,31 OF oMainWnd
	
	@ 02, 005 SAY   STR0190  SIZE 40,08 OF oDlgNew PIXEL COLOR CLR_BLUE
	@ 02, 030 MSGET oNewDate1  VAR cNewDate1  PICTURE "@D" VALID DataValida(cNewDate1) SIZE 58,08 OF oDlgNew PIXEL COLOR CLR_HBLUE
	
	@ 14, 005 SAY   STR0191  SIZE 40,08 OF oDlgNew PIXEL COLOR CLR_BLUE
	@ 14, 030 MSGET oNewDate2  VAR cNewDate2  PICTURE "@D" VALID cNewDate2>=cNewDate1 SIZE 58,08 OF oDlgNew PIXEL COLOR CLR_HBLUE
	
	DEFINE SBUTTON oOk1 TYPE 1 FROM 33,10 OF oDlgNew ENABLE ONSTOP OemToAnsi(STR0028)       ACTION (lOk := .t.,oDlgNew:End())
	oOk1:cToolTip := OemToAnsi(STR0028) // Ok
	DEFINE SBUTTON oOk2 TYPE 2 FROM 33,60 OF oDlgNew ENABLE ONSTOP OemToAnsi(STR0158) ACTION (lOk := .f.,oDlgNew:End())
	oOk2:cToolTip := OemToAnsi(STR0158) //"Cancelar
	
	ACTIVATE MSDIALOG oDlgNew CENTER
	if lOk
		if Empty(cNewDate1) .or. Empty(cNewDate2)
			Return
		Endif
		lYesNo := .t.
		FS_MOSVEN()
	Endif
Elseif nPosLbx == 7
	cTipPes   := " "
	aTipPes   := {STR0183,STR0184,STR0195,STR0196} //nome #  data # vendedor # segmento
	cPesquisa := Space(100)
	lOk := .t.
	DEFINE MSDIALOG oDlgNew TITLE OemtoAnsi(STR0197) FROM  02,04 TO 08,31 OF oMainWnd
	
	@ 02, 01 SAY STR0198  SIZE 40,08 OF oDlgNew PIXEL COLOR CLR_BLUE
	@ 02, 30 MSCOMBOBOX oTipPes VAR cTipPes SIZE 70,50 ITEMS aTipPes OF oDlgNew PIXEL
	
	@ 16, 01 MSGET oPesquisa  VAR cPesquisa  PICTURE "@!" SIZE 100,08 OF oDlgNew PIXEL COLOR CLR_HBLUE
	
	DEFINE SBUTTON oOk1 TYPE 1 FROM 26,15 OF oDlgNew ENABLE ONSTOP OemToAnsi(STR0028)       ACTION (lOk := .t.,oDlgNew:End())
	oOk1:cToolTip := OemToAnsi(STR0028) // Ok
	DEFINE SBUTTON oOk2 TYPE 2 FROM 26,65 OF oDlgNew ENABLE ONSTOP OemToAnsi(STR0158) ACTION (lOk := .f.,oDlgNew:End())
	oOk2:cToolTip := OemToAnsi(STR0158) //"Cancelar
	
	ACTIVATE MSDIALOG oDlgNew CENTER
	if lOk
		if Empty(cPesquisa)
			Return(.f.)
		Endif
		aIteSlv := aClone(aIteBrw)
		cPesquisa := alltrim(cPesquisa)
		cYesNoTxt:= alltrim(cYesNoTxt)+ "  "+ STR0378 +" : "+cPesquisa //"Filtro
		oYesNoTxt:Refresh()
		if cTipPes == STR0183
			aNome := {}
			Asort(aIteBrw,1,,{|x,y| x[2] > y[2] })
			nPos := ascan(aIteBrw,{|x| cPesquisa $ x[2] })
			if nPos <= 0
				MsgInfo(STR0377 ,STR0148) // Nao Foi encontrada nenhuma ocorrencia... # atencao!
				Return
			Endif
			For x_ := 1 to Len(aIteBrw)
				if alltrim(cPesquisa) $ aIteBrw[x_,2]
					aadd(aNome,{aIteBrw[x_,1],aIteBrw[x_,2],aIteBrw[x_,3],aIteBrw[x_,4],aIteBrw[x_,5],aIteBrw[x_,6],aIteBrw[x_,7],aIteBrw[x_,8],aIteBrw[x_,9],aIteBrw[x_,10],aIteBrw[x_,11],aIteBrw[x_,12]})
				Endif
			Next
			if Len(aNome) > 0
				aIteBrw := aClone(aNome)
			Endif
		Elseif cTipPes == STR0195
			Asort(aIteBrw,1,,{|x,y| x[3] > y[3] })
			nPos := ascan(aIteBrw,{|x| alltrim(cPesquisa) $ x[4] })
			if nPos <= 0
				MsgInfo(STR0377 ,STR0148) //Nao Foi encontrada nenhuma ocorrencia... # Atencao!
				Return
			Endif
			aNome := {}
			For x_ := 1 to Len(aIteBrw)
				if alltrim(cPesquisa) $ aIteBrw[x_,4]
					aadd(aNome,{aIteBrw[x_,1],aIteBrw[x_,2],aIteBrw[x_,3],aIteBrw[x_,4],aIteBrw[x_,5],aIteBrw[x_,6],aIteBrw[x_,7],aIteBrw[x_,8],aIteBrw[x_,9],aIteBrw[x_,10],aIteBrw[x_,11],aIteBrw[x_,12]})
				Endif
			Next
			if Len(aNome) > 0
				aIteBrw := aClone(aNome)
			Endif
		Elseif cTipPes == STR0196
			Asort(aIteBrw,1,,{|x,y| x[3] > y[3] })
			nPos := ascan(aIteBrw,{|x| alltrim(cPesquisa) $ Upper(x[5]) })
			if nPos <= 0
				Return
			Endif
			cTipo := "1"
			if !STR0381 $ Upper(cPesquisa) //PECAS
				cTipo := "2"
			Endif
			cCond   := "VS1->VS1_TIPORC == cTipo .and. Empty(VS1->VS1_NUMNFI)"
		Else
			Asort(aIteBrw,1,,{|x,y| x[3] > y[3] })
			cPesquisa := cTod(cPesquisa)
			nPos := ascan(aIteBrw,{|x| x[6] == cPesquisa })
			if nPos <= 0
				Return
			Endif
			cCond   := "VS1->VS1_DATORC == cPesquisa .and. Empty(VS1->VS1_NUMNFI)"
		Endif
		
		if cTipPes $ (STR0196+"/"+STR0184)//segmento/data
			aIteBrw := {}
			dbSelectarea("VS1")
			dbSetOrder(1)
			RetIndex()
			*** Deve ser utilizado uma IndRegua
			cIndVS1 := CriaTrab(Nil, .F.)
			cChave  := "VS1_FILIAL+DTOS(VS1_DATORC)"
			oYesNoTxt:Refresh()
			IndRegua("VS1",cIndVS1,cChave,,cCond,OemToAnsi(STR0192) )
			dbSelectArea("VS1")
			nIndex := RetIndex("VS1")
			dbSetOrder(nIndex+1)
			
			dbSelectArea("VS1")
			dbSeek(xFilial("VS1"))
			Do While !EOF() .and. VS1->VS1_FILIAL == xFilial("VS1")
				cChassi := ""
				cPlaca  := ""
				if VS1->VS1_TIPORC == "2"
					if !Empty(VS1->VS1_CHAINT)
						dbSelectArea("VV1")
						dbSetOrder(1)
						if dbSeek(xFilial("VV1")+VS1->VS1_CHAINT)
							cChassi := VV1->VV1_CHASSI
							cPlaca  := VV1->VV1_PLAVEI
						Endif
						dbSelectArea("VS1")
					Endif
				Endif
				aAdd(aIteBrw,{if(VS1_ORCACE == "0",.t.,.f.), if(FG_VALIDA(,"SA1TVS1->VS1_CLIFAT*",,.f.),SA1->A1_NOME," "),VS1_NUMORC,FS_NOMVEN(),if(VS1_TIPORC=="1",STR0379,STR0380) ,VS1_DATORC,Transform(VS1_HORORC,"@R 99:99"),VS1_DATVAL,cChassi,cPlaca,VS1_VTOTNF,VS1_NUMOSV}) //Pecas # Srv/Pec
				dbSelectArea("VS1")
				dbSkip()
			Enddo
			
			dbSelectArea("VS1")
			dbSetOrder(1)
			RetIndex()
		Endif
		
		if Len(aIteBrw) == 0
			aadd(aIteBrw,{.f.," "," "," "," ",ctod("")," ",ctod("")," "," "," "," "})
			MsgInfo(STR0117,STR0019)  //"Nenhum Orcamento para ser Aberto!","Atencao!"
			oFolder:nOption := 1
			dbSelectArea("VS1")
			RetIndex()
			aIteBrw := aClone(aIteSlv)
		Endif
		
		oLbHd2:SetArray(aIteBrw)
		oLbHd2:bLine := { || { IIF(aIteBrw[oLbHd2:nAt,1],oOk,oNo) ,;
		aIteBrw[oLbHd2:nAt,2] ,;
		aIteBrw[oLbHd2:nAt,3] ,;
		aIteBrw[oLbHd2:nAt,4] ,;
		FG_AlinVlrs(Transform(aIteBrw[oLbHd2:nAt,11],"@E 9,999,999.99")) ,;
		aIteBrw[oLbHd2:nAt,5] ,;
		Transform(aIteBrw[oLbHd2:nAt,6],"@D") ,;
		aIteBrw[oLbHd2:nAt,7] ,;
		Transform(aIteBrw[oLbHd2:nAt,8],"@D") ,;
		aIteBrw[oLbHd2:nAt,9] ,;
		aIteBrw[oLbHd2:nAt,10] ,;
		aIteBrw[oLbHd2:nAt,12] }}
		oLbHd2:Refresh()
		
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PESBRW   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Pesquisa Orcamento                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PESBRW(cTipPes,cPesquisa)

cPesquisa := alltrim(cPesquisa)
if cTipPes == STR0183 //nome
	Asort(aIteBrw,1,,{|x,y| x[2] < y[2] })
	nPos := ascan(aIteBrw,{|x| cPesquisa == substr(x[2],1,Len(cPesquisa)) })
Elseif cTipPes == STR0376 //Chassi/Placa
	if len(alltrim(cPesquisa)) > 7
		Asort(aIteBrw,1,,{|x,y| x[9] < y[9] })
		nPos := ascan(aIteBrw,{|x| cPesquisa == substr(x[9],1,Len(cPesquisa)) })
	Else
		Asort(aIteBrw,1,,{|x,y| x[10] < y[10] })
		nPos := ascan(aIteBrw,{|x| cPesquisa == substr(x[10],1,Len(cPesquisa)) })
	Endif
Else
	Asort(aIteBrw,1,,{|x,y| dtos(x[6]) < dtos(y[6]) })
	cPesquisa := cTod(cPesquisa)
	nPos := ascan(aIteBrw,{|x| x[6] == cPesquisa })
Endif
if nPos > 0
	if nPos > 0
		if ValType(cPesquisa) == "D"
			cPesquisa := dToc(cPesquisa)
		Elseif ValType(cPesquisa) == "N"
			cPesquisa := Str(cPesquisa)
		Endif
		cYesNoTxt:= alltrim(cYesNoTxt)+ "  "+ STR0186 +": "+cPesquisa     //Pesquisa
		oYesNoTxt:Refresh()
	Endif
	oLbHd2:nat := nPos
	oLbHd2:Refresh()
Else
	MsgInfo(STR0382 ,STR0148)	//Pesquisa nao encontrada..
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_MOSVEN   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Filtra os Orcamentos Gravados                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MOSVEN(lRefresh)

Local cChassi := ""
Local cPlaca  := ""
Local cAliasVS1:= "AliasVS1"
Local cQuery   := ""
Default lRefresh := .t.

aIteBrw := {}
if lYesNo
	cYesNoTxt := STR0199
Else
	cYesNoTxt := STR0200
Endif
if Type("oYesNoTxt") <> "U"
	oYesNoTxt:Refresh()
Endif

dbSelectarea("VS1")
dbSetOrder(1)
cQuery := "SELECT VS1.VS1_NUMORC , VS1.VS1_TIPORC , VS1.VS1_DATORC , VS1.VS1_HORORC , VS1.VS1_DATVAL , VS1.VS1_VTOTNF , VS1.VS1_NUMOSV , VS1.VS1_ORCACE , VS1.VS1_CHAINT , VS1.VS1_CLIFAT , VS1.VS1_LOJA , VS1.VS1_CODVEN , VS1.VS1_NCLIFT "
cQuery += "FROM "+RetSqlName("VS1")+" VS1 WHERE VS1.VS1_FILIAL='"+xFilial("VS1")+ "' AND VS1.VS1_NUMNFI='"+space(len(VS1->VS1_NUMNFI))+"' AND "
if !lYesNo
	cQuery += "VS1.VS1_DATVAL>='"+dtos(dDataBase)+"' AND "
EndIf
if Alltrim(GetNewPar("MV_FILVDB","")) <> ""
	dbSelectArea("VAI")
	If Empty(M->VS1_CODVEN)
		dbSetOrder(4)
		cSeekCV := __cUserID
	Else
		dbSetOrder(6)
		cSeekCV := M->VS1_CODVEN
	Endif
	if dbSeek(xFilial("VAI")+cSeekCV)
		if !(VAI->VAI_CODVEN $ GetNewPar("MV_FILVDB",""))
			cQuery += "VS1.VS1_CODVEN='"+VAI->VAI_CODVEN+"' AND "
		Endif
	Endif
Endif
cQuery += "VS1.VS1_PESQLJ='"+space(len(VS1->VS1_PESQLJ))+"' AND VS1.D_E_L_E_T_=' ' ORDER BY VS1.VS1_NUMORC DESC "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasVS1,.T.,.T.)
Do While !( cAliasVS1 )->( Eof() )
	dDt1 := stod( (cAliasVS1)->( VS1_DATORC ) )
	dDt2 := stod( (cAliasVS1)->( VS1_DATVAL ) )
	cChassi := ""
	cPlaca  := ""
	if (cAliasVS1)->VS1_TIPORC == "2"
		if !Empty((cAliasVS1)->VS1_CHAINT)
			dbSelectArea("VV1")
			dbSetOrder(1)
			if dbSeek(xFilial("VV1")+(cAliasVS1)->VS1_CHAINT)
				cChassi := VV1->VV1_CHASSI
				cPlaca  := VV1->VV1_PLAVEI
			Endif
			dbSelectArea("VS1")
		Endif
	Endif
	cNomCli := (cAliasVS1)->VS1_NCLIFT
	SA1->(dbSetOrder(1))
	if SA1->(dbSeek(xFilial("SA1")+(cAliasVS1)->VS1_CLIFAT+(cAliasVS1)->VS1_LOJA))
		cNomCli := SA1->A1_NOME
	Endif
	cNomVen := ""
	SA3->(dbSetOrder(1))
	if SA3->(dbSeek(xFilial("SA3")+(cAliasVS1)->VS1_CODVEN))
		cNomVen := SA3->A3_NOME
	Endif
	aAdd(aIteBrw,{if((cAliasVS1)->VS1_ORCACE == "0",.t.,.f.), substr(cNomCli,1,20), (cAliasVS1)->VS1_NUMORC, substr(cNomVen,1,15),if((cAliasVS1)->VS1_TIPORC=="1",STR0379,STR0380) ,dDt1,Transform((cAliasVS1)->VS1_HORORC,"@R 99:99"),dDt2,cChassi,cPlaca, (cAliasVS1)->VS1_VTOTNF, (cAliasVS1)->VS1_NUMOSV})  //pecas # Srv/Pec
	dbSelectArea(cAliasVS1)
	dbSkip()
Enddo
dbSelectArea(cAliasVS1)
dbCloseArea()
dbSelectarea("VS1")

if Len(aIteBrw) == 0
    aadd(aIteBrw,{.f.," "," "," "," ",ctod("")," ",ctod("")," "," "," "," "})
	MsgInfo(STR0117,STR0019)  //"Nenhum Orcamento para ser Aberto!","Atencao!"
	//oFolder:nOption := 1
	//Return .f.
Endif

//Asort(aIteBrw,1,,{|x,y| x[3] > y[3] }) //Numero do Orcamento

if type("oLbHd2") <> "U"
	oLbHd2:SetArray(aIteBrw)
	oLbHd2:bLine := { || { IIF(aIteBrw[oLbHd2:nAt,1],oOk,oNo) ,;
	aIteBrw[oLbHd2:nAt,2] ,;
	aIteBrw[oLbHd2:nAt,3] ,;
	aIteBrw[oLbHd2:nAt,4] ,;
	FG_AlinVlrs(Transform(aIteBrw[oLbHd2:nAt,11],"@E 9,999,999.99")) ,;
	aIteBrw[oLbHd2:nAt,5] ,;
	Transform(aIteBrw[oLbHd2:nAt,6],"@D") ,;
	aIteBrw[oLbHd2:nAt,7] ,;
	Transform(aIteBrw[oLbHd2:nAt,8],"@D") ,;
	aIteBrw[oLbHd2:nAt,9] ,;
	aIteBrw[oLbHd2:nAt,10] ,;
	aIteBrw[oLbHd2:nAt,12] }}
	oLbHd2:Refresh()
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_EXCLUIORC³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Exclui Orcamento                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_EXCLUIORC()

Local bCampo  := { |nCPO| Field(nCPO) }
Local nCntFor := 0

Private aCpoenc := {}

dbSelectArea("VS1")
dbSetOrder(1)
dbSeek(xFilial("VS1")+aIteBrw[oLbHd2:nAt,3])

if VS1->VS1_TIPORC == "2"
	MsgInfo(STR0383 ,STR0148)//Este Orcamento nao pode ser excluido pois ja tem pecas retiradas... # Atencao!
	Return(.t.)
Endif

//If Substr(GetMv("MV_LOJAVEI",,"NNNNNN"),1,1) == "S"	//Integrado com o Sigaloja ?
If !Empty(VS1->VS1_PESQLJ)
	dbSelectArea("SL1")
	dbSetOrder(1)
	If dbSeek(xFilial("SL1")+VS1->VS1_PESQLJ)
		If !Empty(SL1->L1_DOC)
			dbSelectArea("VS1")
			MsgInfo(STR0384 ,STR0148) //Orcamento ja faturado # Atencao!
			Return .T.
		EndIf
	EndIf
EndIf
//EndIf

dbSelectArea("VS1")
dbSetOrder(1)

RegToMemory("VS1",.t.)
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS1")
While !Eof().and.(x3_arquivo=="VS1")
	If X3USO(x3_usado).and.cNivel>=x3_nivel
		AADD(aCpoEnc,x3_campo)
	Endif
	&("M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
	dbSkip()
End

dbSelectArea("VS1")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

cTitulo       :=STR0201
cAliasEnchoice:="VS1"
cTudOk        :="AllwaysTrue()"
cFieldOk      :="FG_MEMVAR()"

nOp := 2
DEFINE MSDIALOG oDlgCon TITLE cTitulo From 9,0 to 28,80	of oMainWnd
EnChoice(cAliasEnchoice,0,2,,,,aCpoEnc,{15,1,140,315},,3,,,,,,.F.)
ACTIVATE MSDIALOG oDlgCon CENTER ON INIT (EnchoiceBar(oDlgCon,{|| nOp := 1,FS_CONFEXC(),oDlgCon:End()},{|| nOp := 2,oDlgCon:End()}))


Return


/////////////////////
Function FS_CONFEXC()

Local cGrupo, cCodigo
Local _ni:=0, x_:=0

if MsgYesNo(OemToAnsi(STR0202),OemToAnsi(STR0203))
	
	Begin Transaction
	
	nOpc := 5
	
	nUsadoP:=0
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("VS3")
	aHeaderP:={}
	While !Eof().And.(x3_arquivo=="VS3")
		If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( ! Trim(SX3->X3_CAMPO) $ "VS3_NUMORC" )
			nUsadoP++
			Aadd(aHeaderP,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
			x3_tamanho, x3_decimal,x3_valid,;
			x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
			wVar := "M->"+x3_campo
			&wVar := CriaVar(x3_campo)
		Endif
		dbSkip()
	EndDo
	
	aColsP := {}
	dbSelectArea("VS3")
	dbSetOrder(1)
	dbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
	While VS3->VS3_FILIAL == xFilial("VS3") .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC .and. !eof()
		AADD(aColsP,Array(nUsadoP+1))
		For _ni:=1 to nUsadoP
			aColsP[Len(aColsP),_ni]:=If(aHeaderP[_ni,10] # "V",FieldGet(FieldPos(aHeaderP[_ni,2])),CriaVar(aHeaderP[_ni,2]))
		Next
		
		aColsP[Len(aColsP),nUsadoP+1]:=.F.
		dbSkip()
	EndDo
	
	if Len(aColsP) == 0
		aColsP:={Array(nUsadoP+1)}
		aColsP[1,nUsadoP+1]:=.F.
		For _ni:=1 to nUsadoP
			aColsP[1,_ni]:=CriaVar(aHeaderP[_ni,2])
		Next
	Endif
	
	dbSelectArea("VEC")
	dbSetOrder(1)
	dbSeek(xFilial("VEC")+VS1->VS1_NUMORC)
	While !Eof() .and. VEC->VEC_NUMORC == VS1->VS1_NUMORC
		if RecLock("VEC",.f.,.t.)
			VEC->(dbDelete())
			MsUnlock()
		Endif
		dbSelectArea("VEC")
		dbSkip()
	Enddo
	
	If M->VS1_ORCACE == "0"
		
		For x_:=1  to Len(aColsP)
			
			cGrupo  := aColsP[x_,fg_posvar("VS3_GRUITE","aHeaderP")]
			cCodigo := aColsP[x_,fg_posvar("VS3_CODITE","aHeaderP")]
			dbSelectArea("SB1")
			dbSetOrder(7)
			dbSeek(xFilial("SB1")+cGrupo+cCodigo)
			
			// Volta as pecas p/ o almoxarifado disponivel
			
			if ExistBlock("DESBLO110")
				ExecBlock("DESBLO110",.f.,.f.,{aHeaderP,aColsP,x_,nOpc})
			Endif
			
			aItensNew:={}
			
			cLocalSai := GetMv("MV_RESITE")
			cLocalEnt := LocIte110(.f.,aColsP,x_)
			
			dbSelectArea("SB5")
			dbSetOrder(1)
			dbSeek( xFilial("SB5") + SB1->B1_COD )
			cLocalizEnt := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ")
			if ExistBlock("LOCAOM110")
				cLocalizEnt := ExecBlock("LOCAOM110",.f.,.f.,{SB1->B1_COD})
			Endif
			
			cLocalizSai := GetMv("MV_RESLOC")
			cLocalizEnt := Alltrim(cLocalizEnt)
			
			cLocalizEnt += Space(TamSx3("B5_LOCALIZ")[1]-Len(cLocalizEnt))
			cLocalizSai := Alltrim(cLocalizSai)
			cLocalizSai += Space(TamSx3("B5_LOCALIZ")[1]-Len(cLocalizSai))
			
			dbSelectArea("SB1")
			dbSetOrder(1)
			
			//
			// Adiciona cabecalho com numero do documento e data da transferencia modelo II
			//
			aadd (aItensNew,{ nextnumero("SD3",2,"D3_DOC",.t.), ddatabase})
			
			// sequencia
			// produto, descricao, unidade de medida, local/localizacao origem
			// produto, descricao, unidade de medida, local/localizacao destino
			// numero de serie, lote, sublote, data de validade, qunatidade
			// quantidade na 2 unidade, estorno, numero de sequencia
			
			cNumSer  := " "
			cLoteCTL := " "
			cNumLot  := " "
			if LOCALIZA(SB1->B1_COD)
				cNumSer  := aColsP[x_,FG_POSVAR("VS3_LOTECT","aHeaderP")]
				cLoteCTL := aColsP[x_,FG_POSVAR("VS3_NUMLOT","aHeaderP")]
				cNumLot  := aColsP[x_,FG_POSVAR("VS3_NUMSER","aHeaderP")]
			Endif
			nQtdEst := aColsP[x_,FG_POSVAR("VS3_QTDITE","aHeaderP")]
			
			aadd ( aItensNew,{ SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, cLocalSai , if(LOCALIZA(SB1->B1_COD),cLocalizSai,Space(15)),;
			SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, cLocalEnt , if(LOCALIZA(SB1->B1_COD),cLocalizEnt,Space(15)),;
			cNumSer , cLoteCTL , cNumLot    ,;
			criavar('D3_DTVALID'), nQtdEst, nQtdEst, criavar("D3_QTSEGUM")   ,;
			criavar("D3_ESTORNO"), criavar("D3_NUMSEQ"), criavar("D3_LOTECTL"), criavar("D3_DTVALID"), criavar("D3_ITEMGRD")} )
			lMsErroAuto	 := .F.
			
			MsExecAuto({|x| MATA261(x)},aItensNew)
			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
				Break
			EndIf
			
			dbSelectArea("SB1")
			dbSetOrder(7)
			
		Next
		
	Endif
	
	dbSelectArea("VS3")
	dbSetOrder(1)
	dbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
	Do While !EOF() .and. xFilial("VS3") == VS3->VS3_FILIAL .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC
		RecLock("VS3",.f.,.t.)
		VS3->(DbDelete())
		MsUnlock()
		WriteSx2("VS3")
		dbSelectArea("VS3")
		dbSkip()
	Enddo
	dbSelectArea("VS4")
	dbSetOrder(1)
	dbSeek(xFilial("VS4")+VS1->VS1_NUMORC)
	Do While !EOF() .and. xFilial("VS4") == VS4->VS4_FILIAL .and. VS4->VS4_NUMORC == VS1->VS1_NUMORC
		RecLock("VS4",.f.,.t.)
		VS4->(DbDelete())
		MsUnlock()
		WriteSx2("VS4")
		dbSelectArea("VS4")
		dbSkip()
	Enddo
	dbSelectArea("VS1")
	RecLock("VS1",.f.,.t.)
	VS1->(DbDelete())
	MsUnlock()
	WriteSx2("VS1")
	
	End Transaction
	
	//Refaz o browse
	lYesNo := .t.
	FS_MOSVEN(.f.)
	
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VALCHAVE ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida chave digitada se existe no orcamento                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Variavel digitada                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALCHAVE(cOrcto)

Local nPos := 0

if VS1->(dbSeek(xFilial("VS1")+cOrcto)) .and. Empty(VS1->VS1_NUMPED)
	nPos := aScan(aIteBrw,{|x| x[3] == cOrcto })
Endif

if nPos <= 0
	MsgStop(STR0204,STR0148)
Endif

Return(nPos)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_ABREORC  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Abre Orcamento Gravado                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Linha do ListBox do BrowseOrc                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ABREORC(nLin)

Processa( { || FS_Abre(nLin) } )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_ABRE     ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Abre o Orcamento                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Linha do ListBox e Objetos do Meter...                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ABRE( nLin, oMeter, oText, oDlg, lEnd )


Local nItem	 := 0
Local i:=0
Local _ni:=0
Local nCntFor
Inclui := .f.
Inclui2:= .f.
Altera := .t.
cAbrir := .t.
nOpc  := 4
nOpcG := 4
nOpcE := 4

Limpa_Var()
MaFisEnd()

// Meter
ProcRegua(5)
IncProc(OemToAnsi(STR0205))

dbSelectarea("VS1")
if !dbSeek(xFilial("VS1")+aIteBrw[nLin,3])
	Return(.f.)
Endif

dbSelectarea("VS1")
For i:=1 to Len(aPriEnc)
	&("M->"+aPriEnc[i]) := &(aPriEnc[i])
Next

For i:=1 to Len(aSegEnc)
	&("M->"+aSegEnc[i]) := &(aSegEnc[i])
Next

M->VS1_OBSMEM := VS1->VS1_OBSMEM
M->VS1_OBSERV := CriaVar("VS1_OBSERV")

if M->VS1_TIPORC == "1"
	if oFolder2:nOption == 2
		oFolder2:nOption := 1
	Endif
Endif

If VS1->(FieldPos("VS1_ALTORC")) <> 0
	If M->VS1_ALTORC == "0" // Nao
		oGetPecas:oBrowse:aAlter:={}
		oGetSrvcs:oBrowse:aAlter:={}
	Else
		oGetPecas:oBrowse:aAlter:=nil
		oGetSrvcs:oBrowse:aAlter:=nil
	Endif
Else
	M->VS1_ALTORC := " "
	oGetPecas:oBrowse:aAlter:=nil
	oGetSrvcs:oBrowse:aAlter:=nil
EndIf

oGetPecas:oBrowse:refresh()
oGetSrvcs:oBrowse:refresh()

lRecompra := (VS1->(FieldPos("VS1_RETPEC")) <> 0 .and. VS1->VS1_RETPEC == "1")

// Funcao para inicializar o Controle do TES
FP_IniImp(M->VS1_CLIFAT,M->VS1_LOJA)

cNumLib  := VS1->VS1_NUMLIB
cOpeMov2 := VS1->VS1_NOROUT

VOI->(DbSetOrder(1))
VOI->(DbSeek(xFilial("VOI")+VS1->VS1_TIPTEM))

VE1->(DbSetOrder(1))
VE1->(DbSeek(xFilial("VE1")+VS1->VS1_CODMAR))

FG_SEEK("VV1","VS1->VS1_CHAINT",1,.f.)

M->VS1_GETKEY := VV1->VV1_CHASSI
M->VS1_CHASSI := VV1->VV1_CHASSI
M->VS1_CHAINT := VV1->VV1_CHAINT
M->VS1_PLAVEI := VV1->VV1_PLAVEI
M->VS1_CODFRO := VV1->VV1_CODFRO
M->VS1_CODMAR := VV1->VV1_CODMAR

FG_SEEK("SA1","VS1->VS1_CLIFAT",1,.f.)
if lVAMCid
	FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
Endif

aTitCre := {}
nTotCre := 0
If Alltrim(GetNewPar("MV_TITNCC","N")) == "S"
	dbSelectArea("SE1")
	dbSetOrder(2)
	dbSeek(xFilial("SE1")+M->VS1_CLIFAT+M->VS1_LOJA)
	while !EOF() .and. M->VS1_CLIFAT == SE1->E1_CLIENTE .and. M->VS1_LOJA == SE1->E1_LOJA
		if SE1->E1_SALDO > 0 .and. SE1->E1_TIPO == "NCC"
			aadd(aTitCre,{.f.,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_VENCTO,SE1->E1_SALDO,recno()})
			if str(recno()) $ M->VS1_TITNCC
				aTitCre[Len(aTitCre),1] := .t.
				nTotCre += SE1->E1_SALDO
			Endif
		Endif
		dbSelectArea("SE1")
		dbSkip()
	Enddo
EndIf

if !Empty(VS1->VS1_CLIFAT)
	M->VS1_NCLIFT := SA1->A1_NOME
	M->VS1_ENDCLI := SA1->A1_END
	if lVAMCid
		M->VS1_CIDCLI := VAM->VAM_DESCID
		M->VS1_ESTCLI := VAM->VAM_ESTADO
	Else
		M->VS1_CIDCLI := SA1->A1_MUN
		M->VS1_ESTCLI := SA1->A1_EST
	Endif
	M->VS1_FONCLI := SA1->A1_TEL
Endif

M->VS1_VALFRE := VS1->VS1_VALFRE
M->VS1_VALSEG := VS1->VS1_VALSEG
M->VS1_DESACE := VS1->VS1_DESACE
MaFisRef("NF_DESPESA","VS100",M->VS1_DESACE)
MaFisRef("NF_FRETE"  ,"VS100",M->VS1_VALFRE)
MaFisRef("NF_SEGURO" ,"VS100",M->VS1_VALSEG)

if FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.) .and. M->VS1_TIPORC == "2" //Somente quando for Orcamento Oficina
	FG_SEEK("VV2","VV1->VV1_CODMAR+VV1->VV1_MODVEI",1,.f.)
	FG_SEEK("VVC","VV1->VV1_CODMAR+VV1->VV1_CORVEI",1,.f.)
	FG_SEEK("SA1","VV1->VV1_PROATU",1,.f.)
	if lVAMCid
		FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
	Endif
	
	M->VS1_DESMAR := VE1->VE1_DESMAR
	M->VS1_DESMOD := VV2->VV2_DESMOD
	M->VS1_CHAINT := VV1->VV1_CHAINT
	M->VS1_CHASSI := VV1->VV1_CHASSI
	M->VS1_PLAVEI := VV1->VV1_PLAVEI
	M->VS1_CODFRO := VV1->VV1_CODFRO
	M->VS1_FABMOD := VV1->VV1_FABMOD
	M->VS1_DESCOR := VVC->VVC_DESCRI
	M->VS1_PROVEI := SA1->A1_COD
	M->VS1_NOMPRO := SA1->A1_NOME
	M->VS1_ENDPRO := SA1->A1_END
	if lVAMCid
		M->VS1_CIDPRO := VAM->VAM_DESCID
		M->VS1_ESTPRO := VAM->VAM_ESTADO
	Else
		M->VS1_CIDPRO := SA1->A1_MUN
		M->VS1_ESTPRO := SA1->A1_EST
	Endif
	M->VS1_FONPRO := SA1->A1_TEL
EndIf

// Variavel que controla cliente periodico
if VS1->VS1_NOROUT == "1"
	cForPeri := SA1->A1_COND
Endif

if Empty(M->VS1_CODVEN) .or. alltrim(M->VS1_CODVEN) == alltrim(__cUserID)
	dbSelectArea("VAI")
	dbSetOrder(4)
	dbSeek(xFilial("VAI")+__cUserID)
Else
	dbSelectArea("VAI")
	dbSetOrder(6)
	dbSeek(xFilial("VAI")+M->VS1_CODVEN)
Endif
dbSelectArea("SA3")
dbSetOrder(1)
dbSeek(xFilial("SA3")+M->VS1_CODVEN)
cCodVen := SA3->A3_COD
M->VS1_NOMVEN := SA3->A3_NOME

nTotTit := 0
nBrinde := 0
nTotDes := 0
nTotPec := 0
nTotOrc := 0
nTotEntr:= 0

// Monta aCols de Servicos

IncProc(STR0206)
aColsS := {}
DbSelectArea("VS4")
DbSetOrder(1)
//Fg_Seek("VS4","VS1->VS1_NUMORC",1,.F.)
DbSeek(xFilial("VS4")+VS1->VS1_NUMORC)
While VS4->VS4_FILIAL == xFilial("VS4") .and. VS4->VS4_NUMORC == VS1->VS1_NUMORC .and. !eof()
	AADD(aColsS,Array(nUsadoS+1))
	For _ni:=1 to nUsadoS
		aColsS[Len(aColsS),_ni]:=If(aHeaderS[_ni,10] # "V",FieldGet(FieldPos(aHeaderS[_ni,2])),CriaVar(aHeaderS[_ni,2]))
	Next
	aColsS[Len(aColsS),nUsadoS+1]:=.F.
	nTotDes += VS4->VS4_VALDES
	nTotSrv += VS4->VS4_VALTOT
	nTotOrc += VS4->VS4_VALTOT
	DbSkip()
EndDo

if Len(aColsS) == 0
	aColsS:={Array(nUsadoS+1)}
	aColsS[1,nUsadoS+1]:=.F.
	For _ni:=1 to nUsadoS
		aColsS[1,_ni]:=CriaVar(aHeaderS[_ni,2])
	Next
	aColsS[1,FG_POSVAR("VS4_SEQUEN","aHeaderS")]:= [001]
Endif

// Monta aCols de Pecas

IncProc(STR0207)
aIteBlq := {}
aColsP  := {}
aIteRes := {}

dbSelectArea("VS3")
dbSetOrder(1)
//Fg_Seek("VS3","VS1->VS1_NUMORC",1,.F.)
DbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
While VS3->VS3_FILIAL == xFilial("VS3") .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC .and. !eof()
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE)
	dbSelectArea("VS3")
	
	nItem += 1
	AADD(aColsP,Array(nUsadoP+1))
	
	For _ni:=1 to nUsadoP
		aColsP[Len(aColsP),_ni]:=If(aHeaderP[_ni,10] # "V",FieldGet(FieldPos(aHeaderP[_ni,2])),CriaVar(aHeaderP[_ni,2]))
	Next
	// Carrega reservas
	aadd(aIteRes,{VS3_SEQUEN,VS3_GRUITE+VS3_CODITE,VS3_QTDRES})
	FS_LOADTRANS(VS3->VS3_SEQUEN,VS3->VS3_QTDRES)
	
	aColsP[Len(aColsP),nUsadoP+1]:=.F.
	nTotDes += VS3->VS3_VALDES
	nTotPec += VS3->VS3_VALTOT
	nTotOrc += VS3->VS3_VALTOT
	if TipoTes(VS3_CODTES)
		nTotTit += VS3->VS3_VALTOT
	Else
		nBrinde += VS3->VS3_VALTOT
	Endif
	
	if fg_posvar("VS3_GRUITE","aHeaderP") > 0
		nSaldo := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+LocIte110())
		aColsP[nItem,FG_POSVAR("VS3_QTDEST","aHeaderP")] := nSaldo
	Endif
	
	MaFisIniLoad(nItem)
	MaFisLoad("IT_VALMERC" ,VS3->VS3_QTDITE*VS3->VS3_VALPEC,nItem)
	MaFisLoad("IT_PRODUTO" ,SB1->B1_COD,nItem)
	MaFisLoad("IT_DESCONTO",VS3->VS3_VALDES,nItem)
	MaFisLoad("IT_TES"     ,VS3->VS3_CODTES,nItem)
	MaFisLoad("IT_BASEICM" ,VS3->VS3_VBAICM,nItem)
	MaFisLoad("IT_ALIQICM" ,VS3->VS3_ALIICM,nItem)
	MaFisLoad("IT_VALICM"  ,VS3->VS3_ICMCAL,nItem)
	MaFisEndLoad(nItem)
	
	if !Empty(SB1->B1_GRTRIB)
		MaFisAlt("IT_GRPTRIB",SB1->B1_GRTRIB,nItem)
	Endif
	
	if !Empty(SB1->B1_GRTRIB) .or. SB1->B1_PICMENT > 0
		
		if SB1->B1_PICMENT > 0
			nAliSol  := SB1->B1_PICMENT
			nBaseSol := VS3->VS3_VALTOT+((VS3->VS3_VALTOT *nAliSol)/100)
			MaFisAlt("IT_BASESOL",nBaseSol,nItem)
		Else
			dbSelectArea("SF7")
			dbSetOrder(1)
			if MsSeek(xFilial("SF7")+SB1->B1_GRTRIB+SA1->A1_GRPTRIB)
				while !EOF() .and. SF7->F7_GRTRIB == SB1->B1_GRTRIB
					if SF7->F7_GRPCLI == SA1->A1_GRPTRIB .and. SA1->A1_EST == SF7->F7_EST
						nBaseSol := VS3->VS3_VALTOT+((VS3->VS3_VALTOT *SF7->F7_MARGEM)/100)
						MaFisAlt("IT_BASESOL",nBaseSol,nItem)
						//MaFisAlt("IT_VALSOL",((nBaseSol*MaFisRet(nItem,"IT_ALIQICM"))/100)-MaFisRet(nItem,"IT_VALICM"),nItem)
					Endif
					dbSelectArea("SF7")
					dbSkip()
				enddo
			Endif
		Endif
	Else
		MaFisAlt("IT_BASESOL",0,nItem)
		MaFisAlt("IT_VALSOL",0,nItem)
	Endif
	
	if SF4->F4_INCSOL == "S"
		nTotTit += MaFisRet(nItem,"IT_VALSOL")
	Endif
	
	dbSelectArea("VS3")
	dbSkip()
EndDo

if Len(aColsP) == 0
	aColsP:={Array(nUsadoP+1)}
	aColsP[1,nUsadoP+1]:=.F.
	For _ni:=1 to nUsadoP
		aColsP[1,_ni]:=CriaVar(aHeaderP[_ni,2])
	Next
	aColsP[1,FG_POSVAR("VS3_SEQUEN","aHeaderP")]:= [001]
Else
	aIteRel := FG_ITEREL(M->VS1_TIPTEM,aColsP[1,fg_posvar("VS3_GRUITE","aHeaderP")],If(ReadVar()=="M->VS3_CODITE",M->VS3_CODITE,aColsP[1,fg_posvar("VS3_CODITE","aHeaderP")]),"M->VS1_FORMUL")
	If len(aIteRel) <= 0
		aIteRel := {{"","","",0,0}}
	EndIf
	oLbIteRel:nAt := 1
	oLbIteRel:SetArray(aIteRel)
	oLbIteRel:bLine := { || { aIteRel[oLbIteRel:nAt,1] ,;
	aIteRel[oLbIteRel:nAt,2] ,;
	aIteRel[oLbIteRel:nAt,3] ,;
	FG_AlinVlrs(Transform(aIteRel[oLbIteRel:nAt,4],"@E 999,999")),;
	FG_AlinVlrs(Transform(aIteRel[oLbIteRel:nAt,5],"@E 999,999,999.99"))}}
	oLbIteRel:Refresh()
Endif

M->VS1_VTOTNF := MaFisRet(,"NF_TOTAL")-MaFisRet(,"NF_DESCZF")
M->VS1_VALDES := MaFisRet(,"NF_DESCONTO")
M->VS1_ICMCAL := MaFisRet(,"NF_VALICM")
M->VS1_DESACE := MaFisRet(,"NF_DESPESA")
M->VS1_VALFRE := MaFisRet(,"NF_FRETE")
M->VS1_VALSEG := MaFisRet(,"NF_SEGURO")

lJaPerg   := .t.
lJagravou := .t.

dbSelectArea("SE4")
if dbSeek(xFilial("SE4")+M->VS1_FORPAG)
	cTipPag := M->VS1_FORPAG
	cDesPag := SE4->E4_DESCRI
	M->VS1_FORPAG := cTipPag
	M->VS1_DESFPG := cDesPag
Endif

dbSelectArea("SA6")
if dbSeek(xFilial("SA6")+M->VS1_CODBCO)
	M->VS1_NOMBCO := SA6->A6_NOME
	cCodBco := M->VS1_CODBCO
	cDesBco := M->VS1_NOMBCO
Endif

dbSelectArea("VEG")
if dbSeek(xFilial("VEG")+M->VS1_FORMUL)
	M->VS1_NOMFOR := VEG->VEG_DESCRI
Endif

IncProc(STR0208)

dbSelectArea("VS9")
dbSetOrder(1)
if dbSeek(xFilial("VS9")+ LEFT("OR"+VS1->VS1_NUMORC+SPACE(15),Len(VS9->VS9_NUMIDE))+"B")
	aColsC := {}
	nC := 1
	Do While !Eof() .and. xFilial("VS9") == VS9->VS9_FILIAL .and. Alltrim(VS9->VS9_NUMIDE) == "OR"+VS1->VS1_NUMORC .and. VS9->VS9_TIPOPE == "B"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o aCols da Entrada                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If VS9->VS9_TIPPAG == "DP" //Duplicata
			aAdd(aIteParc, {VS9->VS9_DATPAG,VS9->VS9_VALPAG})
			if !Empty(VS9->VS9_REFPAG)
				cCondic1 := cTod(Substr(VS9->VS9_REFPAG,01,08))
				cCondic2 := Substr(VS9->VS9_REFPAG,09,02)
				cCondic3 := Substr(VS9->VS9_REFPAG,11,Len(SE1->E1_PARCELA))
				cCondic4 := Substr(VS9->VS9_REFPAG,13,02)
			Endif 
		Else
			AADD(aColsC,Array(nUsadoC+1))
			nTotEntr += VS9->VS9_VALPAG
			For _ni:=1 to nUsadoC
				aColsC[Len(aColsC),_ni]:=If(aHeaderC[_ni,10] # "V",FieldGet(FieldPos(aHeaderC[_ni,2])),CriaVar(aHeaderC[_ni,2]))
			Next
			aColsC[Len(aColsC),nUsadoC+1]:=.F.
			dbSelectArea("VSE")
			dbSetOrder(1)
			if dbSeek(xFilial("VSE")+LEFT("OR"+VS1->VS1_NUMORC+SPACE(15),Len(VS9->VS9_NUMIDE))+"B"+VS9->VS9_TIPPAG+VS9->VS9_SEQUEN)
				while !EOF() .and. &(VSE->(indexKey())) == xfilial("VSE")+LEFT("OR"+VS1->VS1_NUMORC+SPACE(15),Len(VS9->VS9_NUMIDE))+"B"+VS9->VS9_TIPPAG+VS9->VS9_SEQUEN
					aadd(aGravaEnt,{Len(aColsC),VSE->VSE_TIPPAG,VSE->VSE_DESCCP,VSE->VSE_NOMECP,VSE->VSE_TIPOCP,VSE->VSE_TAMACP,VSE->VSE_DECICP,VSE->VSE_PICTCP,VSE->VSE_VALDIG})
					dbSkip()
				Enddo
			Endif
		Endif
		dbSelectArea("VS9")
		dbSkip()
	Enddo
	aHeader := aClone(aHeaderC)
	aCols   := aClone(aColsC)
	oGetCondicao:oBrowse:refresh()
Endif

if Len(aColsC) == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols da Entrada                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsC:={Array(nUsadoC+1)}
	aColsC[1,nUsadoC+1]:=.F.
	For _ni:=1 to nUsadoC
		aColsC[1,_ni]:=CriaVar(aHeaderC[_ni,2])
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array de Financiamento                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VS9")
dbSetOrder(1)
if dbSeek(xFilial("VS9")+LEFT("OR"+VS1->VS1_NUMORC+SPACE(15),Len(VS9->VS9_NUMIDE))+"BDP")
	aIteParc := {}
	Do While !Eof() .and. xFilial("VS9") == VS9->VS9_FILIAL .and. Alltrim(VS9->VS9_NUMIDE) == "OR"+VS1->VS1_NUMORC .and. VS9->VS9_TIPOPE == "B"
		If VS9->VS9_TIPPAG == "DP"  //Duplicata
			aAdd(aIteParc, {VS9->VS9_DATPAG,VS9->VS9_VALPAG})
			if !Empty(VS9->VS9_REFPAG)
				cCondic1 := cTod(Substr(VS9->VS9_REFPAG,01,08))
				cCondic2 := Substr(VS9->VS9_REFPAG,09,02)
				cCondic3 := Substr(VS9->VS9_REFPAG,11,Len(SE1->E1_PARCELA))
				cCondic4 := Substr(VS9->VS9_REFPAG,13,02)
			Endif
		Else
			aadd(aIteParc,{VS9->VS9_DATPAG,VS9->VS9_VALPAG})
			nTotEntr += VS9->VS9_VALPAG
		Endif
		dbSkip()
	Enddo
Endif

if Len(aIteParc) == 0
	aIteParc := {{cTod(""),0}}
Endif

if Len(aIteParc) > 0
	oLbParc:SetArray(aIteParc)
	oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
	Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
	oLbParc:Refresh()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se houve CDCI traz codigo e valor combinado                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VS9")
dbSetOrder(1)
if dbSeek(xFilial("VS9")+"CD"+VS1->VS1_NUMORC)
	cCodCDCI  := alltrim(VS9->VS9_REFPAG)
	nValorCom := VS9->VS9_VALPAG
Endif
if Len(aColsAnt) = 0
	aColsAnt := aClone(aColsP)
Endif

IncProc(STR0209)

if Type(cGetDados) <> "U" .and. &(cGetDados):oBrowse:lVisible
	
	If SIX->(DbSeek( "VSO"+"6" )) .And. Empty(cNumAgenda)
		
		DbSelectArea("VSO")
		DbSetOrder(6)
		If DbSeek( xFilial("VSO") + M->VS1_NUMORC )
			
			cNumAgenda	:= VSO->VSO_NUMIDE
			
		EndIf
		
	EndIf
	
	if lZap
		dbSelectArea("TMP")
		Zap
	Else
		lZap := .t.
	Endif
	
	DbSelectArea("SX3")
	DbSetOrder(2)
	
	// Monta filho de pecas
	dbSelectArea("VSM")
	dbSetOrder(10)
	if dbSeek(xFilial("VSM")+M->VS1_NUMORC)
		
		cQuebraAgr := ""
		cQuebraSeq := ""
		cMostraSeq := ""
		cMostraAgr := ""
		
		nTotPec := 0
		nTotSrv := 0
		nTotDes := 0
		nTotOrc := 0
		
		dbSelectArea("VSM")
		Do While !Eof() .AND. VSM->VSM_NUMORC == VS1->VS1_NUMORC
			
			DbSelectArea("TMP")
			RecLock("TMP",.t.)
			For nCntFor := 1 to (FCount()-1)
				If VSM->( FieldPos( TMP->( FieldName(nCntFor) ) ) ) == 0
					If SX3->(DbSeek(TMP->(FieldName(nCntFor))))
						TMP->&( FieldName(nCntFor) ) := CriaVar( TMP->( FieldName(nCntFor) ) )
					EndIf
				Else
					TMP->&( FieldName(nCntFor) ) := VSM->( FieldGet( FieldPos( TMP->( FieldName(nCntFor) ) ) ) )
				EndIf
				DbSelectArea("TMP")
			Next
			//		   TMP->VSM_TOTAL := (TMP->VSM_VALOR * TMP->VSM_QTDITE) - TMP->VSM_VALDES
			TMP->VSM_FLAG := .f.
			MsUnLock()
			
			If cQuebraAgr # TMP->VSM_SEQUEN+TMP->VSM_TIPAGR
				cMostraAgr += StrZero(TMP->(Recno()),8)+"/"
			EndIf
			cQuebraAgr := TMP->VSM_SEQUEN+TMP->VSM_TIPAGR
			
			If cQuebraSeq # TMP->VSM_SEQUEN
				cMostraSeq += StrZero(TMP->(Recno()),8)+"/"
			EndIf
			cQuebraSeq := TMP->VSM_SEQUEN
			
			if TMP->VSM_TIPAGR $ "2/4"
				nTotPec := nTotPec + TMP->VSM_VALOR
			ElseIf TMP->VSM_TIPAGR $ "3/5"
				nTotSrv := nTotSrv + TMP->VSM_VALOR
			Endif
			nTotDes := nTotDes + TMP->VSM_VALDES
//			nTotOrc := (nTotPec + nTotSrv) - nTotDes
		    nTotOrc := MaFisRet(,"NF_TOTAL")-MaFisRet(,"NF_DESCZF")   //FNC - 13653 - BOBY 24/06/10
			
			dbSelectArea("VSM")
			dbSkip()
			
		EndDo
	Endif
	oTotPec:Refresh()
	oTotSrv:Refresh()
	oTotDes:Refresh()
	oTotOrc:Refresh()
	TMP->(dbGotop())
	&(cGetDados):nCount := TMP->(RecCount())
	&(cGetDados):oBrowse:Refresh()
Endif

if Type(cGetDados) == "U" .or. M->VS1_TIPORC <> "2"
	
	if oFolder2:nOption == 1
		aHeader := aClone(aHeaderP)
		aCols   := aClone(aColsP)
		n := nP
		oGetPecas:oBrowse:Refresh()
	Else
		aHeader := aClone(aHeaderS)
		aCols   := aClone(aColsS)
		n := nS
		oGetSrvcs:oBrowse:Refresh()
	Endif
	
	oGetMGet:Refresh()
	
Else
	
	if &(cGetDados):oBrowse:lVisible
		aHeader := aclone(aHeaderI)
		&(cGetDados):oBrowse:Refresh()
	Endif
	
Endif

M->VS1_DESCON := M->VS1_VALDES := nTotDes
M->VS1_PERDES := val(str(( nTotDes / nTotOrc ) * 100,12,2))

oGetMGet:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FOLDER   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Validacao na Mudanca de Aba                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FOLDER(lPriVez)
Local cont
Local nOld
Local bCampo  := { |nCPO| Field(nCPO) }
Local lIteLib := .t.
Local nTotOld := 0 // total ja reservado anteriormente
Local i:=0, y:=0, x:=0, nCntFor:=0
Local lEstNeg := .f.
//Implementação para controle de tela

Local cFOOper := ""
Local lFOOper := .f.
if oFolder:nOption == 2
	if Type(cGetDados) == "U" .or. M->VS1_TIPORC <> "2"
		if oFolder2:nOption == 1
			aHeader := aClone(aHeaderP)
			aCols   := aClone(aColsP)
			n := nP
			oGetPecas:oBrowse:Refresh()
		Else
			aHeader := aClone(aHeaderS)
			aCols   := aClone(aColsS)
			n := nS
			oGetSrvcs:oBrowse:Refresh()
		Endif
		FG_MEMVAR()
	Else
		if &(cGetDados):oBrowse:lVisible
			aHeader := aclone(aHeaderI)
			&(cGetDados):oBrowse:Refresh()
		Endif
	Endif
Elseif oFolder:nOption == 3
	
	If !lFimArg // Manoel - 07/05/2009 - cPaisLoc
		
		If left(aHeader[2,2],3) == "VS3"
			aColsP := aClone(aCols)
		Elseif left(aHeader[2,2],3) == "VS4"
			aColsS := aClone(aCols)
		Endif
		
		//Retorno de pecas (recompra)
		if lRecompra
			if Empty(M->VS1_AUTENV)
				MsgInfo(STR0385 ,STR0148)//Numero da autorizacao de envio da fabrica nao informado # Atencao!
				oFolder:nOption := 2
				Return
			Endif
			if Empty(M->VS1_ARMFAB)
				MsgInfo(STR0386 ,STR0148) //Armazem da Fabrica nao foi informada # Atencao!
				oFolder:nOption := 2
				Return
			Endif
			
			For cont := 1 to Len(aColsP)
				if FG_POSVAR("VS3_NUMIDE","aHeaderP") > 0 .and. Empty(aColsP[cont,FG_POSVAR("VS3_NUMIDE","aHeaderP")])
					MsgInfo(STR0387 ,STR0148) //Numero da etiqueta nao foi informada. # Atencao!
					oFolder:nOption := 2
					Return
				Elseif FG_POSVAR("VS3_NOTFAB","aHeaderP") > 0 .and. Empty(aColsP[cont,FG_POSVAR("VS3_NOTFAB","aHeaderP")])
					MsgInfo(STR0388 ,STR0148) //Numero da Nota Fiscal da Fabrica nao foi informada # Atencao!
					oFolder:nOption := 2
					Return
				Elseif FG_POSVAR("VS3_DTNFFB","aHeaderP") > 0 .and. Empty(aColsP[cont,FG_POSVAR("VS3_DTNFFB","aHeaderP")])
					MsgInfo(STR0389 ,STR0148) //Data da NF da Fabrica nao foi informada # Atencao!
					oFolder:nOption := 2
					Return
				Endif
			Next
		EndIf
		
		aHeader := aClone(aHeaderC)
		aCols   := aClone(aColsC)
		n := nC
		oGetCondicao:oBrowse:Refresh()
		
		cObsNF := " "
		
		nPos := 0
		if Empty(M->VS1_CLIFAT)
			For i:=1 to Len(oGetMGet:aEntryCtrls)
				if allTrim(oGetMGet:aEntryCtrls[i]:cReadVar) == "M->VS1_CLIFAT"
					nPos := i
					Exit
				Endif
			Next
		Endif
		
		if nPos > 0
			MsgInfo(STR0390 ,STR0148) //Cliente tem que estar cadastrado... # Atencao!
			oGetMGet:AENTRYCTRLS[nPos]:SetFocus()
			oFolder:nOption := 2
			Return
		Endif
		
		if !Fs_VerCabec()
			oFolder:nOption := 2
			Return
		Endif
		
		if ExistBlock("VALESTNEG")
			if !(lEstNeg := ExecBlock("VALESTNEG",.f.,.f.))
				oFolder:nOption := 2
				Return
			Endif
		EndIf
		
		if !Empty(M->VS1_FORPAG)
			cTipPag := M->VS1_FORPAG
			cDesPag := M->VS1_DESFPG
			oTipPag:Refresh()
			oDesPag:Refresh()
		Endif
		
		if !Empty(M->VS1_CODBCO)
			cCodBco := M->VS1_CODBCO
			cDesBco := M->VS1_NOMBCO
			oCodBco:Refresh()
			oDesBco:Refresh()
		Endif
		
		aHeaderSlv := aClone(aHeader)
		aColsSlv   := aClone(aCols)
		nSlv       := n
		
		aHeader := aClone(aHeaderP)
		aCols   := aClone(aColsP)
		n       := nP
		
		if lJaGravou
			RecLock("VS1",.f.)
			M->VS1_VTOTNF := MaFisRet(,"NF_TOTAL")-MaFisRet(,"NF_DESCZF")
			M->VS1_VALDES := MaFisRet(,"NF_DESCONTO")
			M->VS1_ICMCAL := MaFisRet(,"NF_VALICM")
			M->VS1_DESACE := MaFisRet(,"NF_DESPESA")
			
			M->VS1_VALFRE := MaFisRet(,"NF_FRETE")
			M->VS1_VALSEG := MaFisRet(,"NF_SEGURO")
			
			MsUnlock()
		Else
			if FS_FINORC(Nil,.t.,.t.)
				RecLock("VS1",.f.)
				M->VS1_VTOTNF := MaFisRet(,"NF_TOTAL")-MaFisRet(,"NF_DESCZF")
				M->VS1_VALDES := MaFisRet(,"NF_DESCONTO")
				M->VS1_ICMCAL := MaFisRet(,"NF_VALICM")
				M->VS1_DESACE := MaFisRet(,"NF_DESPESA")
				
				M->VS1_VALFRE := MaFisRet(,"NF_FRETE")
				M->VS1_VALSEG := MaFisRet(,"NF_SEGURO")
				
				MsUnlock()
			Else
				oFolder:nOption := 2
				Return(.f.)
			Endif
		Endif
		
		// Verifica se o Array aIteRes e aIteBlq estao de acordo com o aColsP
		n1 := n
		FS_BLQRES()
		n := n1
		
		nTotOrc := 0
		nTotTit := 0
		nBrinde := 0
		For i:=1 to Len(aColsP)
			if !aColsP[i,Len(aColsP[i])]
				If (GetMV("MV_ARREFAT")=="S")
					nTotOrc += Round(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
				Else
					nTotOrc += NoRound(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
				Endif
				if TipoTes(aColsP[i,FG_POSVAR("VS3_CODTES","aHeaderP")])
					If (GetMV("MV_ARREFAT")=="S")
						nTotTit += Round(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
					Else
						nTotTit += NoRound(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
					Endif
					//if SF4->F4_INCSOL == "S"
					//   nTotTit += MaFisRet(i,"IT_VALSOL")
					//Endif
				Else
					nBrinde += Round(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
				Endif
			Endif
		Next
		
		nTotOrc += M->VS1_DESACE
		nTotTit += M->VS1_DESACE
		
		nTotOrc += M->VS1_VALFRE
		nTotTit += M->VS1_VALFRE
		
		nTotOrc += M->VS1_VALSEG
		nTotTit += M->VS1_VALSEG
		
		nTotTit -= nTotCre

//		nTotOrc := MaFisRet(,"NF_TOTAL")-MaFisRet(,"NF_DESCZF")   //FNC - 13653 - BOBY 24/06/10
		nTotTit := nTotOrc - nTotCre                                //FNC - 13653 - BOBY 24/06/10
		
		For y:=1 to Len(aIteBlq)
			if y <= Len(aColsP)
				if !aColsP[y,Len(aColsP[y])]
					if aIteBlq[y,2] == "S"
						dbSelectArea("SB1")
						dbSetOrder(7)
						dbSeek(xFilial("SB1")+aColsP[y,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[y,FG_POSVAR("VS3_CODITE","aHeaderP")])
						dbSelectArea("SB2")
						if M->VS1_ORCACE == "0"
							dbSeek(xFilial("SB2")+SB1->B1_COD+GetMV("MV_RESITE")+GetMV("MV_RESLOC"))
						else
							dbSeek(xFilial("SB2")+SB1->B1_COD+LocIte110(.f.,aColsP,y))
						endif
						nSaldo := SaldoSB2()
						// faz a verificacao da qtde reserva anteriormente e a diferenca digita para
						// se o saldo eh suficiente para suprir a necessidade
						If !y > Len(aIteRes)
							nTotOld := aIteRes[y,3]
							If nTotOld <> 0 .and. aColsP[y,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[y,FG_POSVAR("VS3_CODITE","aHeaderP")]==aIteRes[y,2]
								If nTotOld-aCols[y,FG_POSVAR("VS3_QTDITE","aHeaderP")] > 0
									nTotOld := 0
								Endif
							Else
								nTotOld := 0
							Endif
						Else
							nTotOld := aCols[y,FG_POSVAR("VS3_QTDITE","aHeaderP")]
						Endif
						if nSaldo <= 0 .or. nSaldo < nTotOld
							lIteLib := .f.
						Endif
					Endif
				Endif
			Endif
		Next
		
		if !lIteLib .and. !lEstNeg .and. SF4->F4_ESTOQUE == "S"
			Help(" ",1,"NAOHAITEM")
			oFolder:nOption := 2
			Return
		Endif
		
		//Verifica se o TES e menor que 500
		For i:=1 to Len(aColsP)
			if !aColsP[i,Len(aColsP[i])]
				if val(aColsP[i,FG_POSVAR("VS3_CODTES","aHeaderP")]) < 500
					MsgInfo(STR0391 +" "+aColsP[i,FG_POSVAR("VS3_DESITE","aHeaderP")]+" "+ STR0392 ,STR0148) //O TES digitado do produto #e de ENTRADA  # Atencao!
					oFolder:nOption := 2
					Return
				Endif
			Endif
		Next
		
		if GetMV("MV_ESTNEG") <> "S"
			lEst := .t.
			//	   if cOpeMov2 <> "2"
			For y:=1 to Len(aColsP)
				if !aColsP[y,Len(aColsP[y])]
					SF4->(dbSeek(xFilial("SF4")+aColsP[y,FG_POSVAR("VS3_CODTES","aHeaderP")]))
					if SF4->F4_ESTOQUE == "N"
						Loop
					Endif
					dbSelectArea("SB1")
					dbSetOrder(7)
					dbSeek(xFilial("SB1")+aColsP[y,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[y,FG_POSVAR("VS3_CODITE","aHeaderP")])
					if !FS_QTDORC(aColsP[y,FG_POSVAR("VS3_QTDITE","aHeaderP")])
						MsgInfo(STR0166+Alltrim(SB1->B1_GRUPO)+" "+Alltrim(SB1->B1_CODITE)+" - "+Alltrim(SB1->B1_DESC)+STR0167,STR0148)
						lEst := .f.
					Endif
				Endif
			Next
			//		Endif
			if !lEst
				oFolder:nOption := 2
				Return
			Endif
		Endif
		
		For x:=1 to Len(aColsP)
			SF4->(dbSeek(xFilial("SF4")+aColsP[x,FG_POSVAR("VS3_CODTES","aHeaderP")]))
			if !aColsP[x,Len(acolsP[x])]
				if aColsP[x,FG_POSVAR("VS3_VALPEC","aHeaderP")] = 0
					Help(" ",1,"SEMPRECO")
					oFolder:nOption := 2
					Return
				Elseif aColsP[x,FG_POSVAR("VS3_QTDITE","aHeaderP")] == 0
					oFolder:nOption := 2
					Return
				Elseif SF4->F4_ESTOQUE == "N"
					if cOpeMov2 <> "2"
						lIntNF := .t.
						if ExistBlock("INTNFBAL")
							lIntNF := ExecBlock("INTNFBAL",.f.,.f.)
						Endif
						if lIntNF
							MsgInfo(STR0210,STR0148)
							oFolder:nOption := 2
							Return
						Endif
					Endif
				Endif
			Endif
		Next
		
		nSubTotal := 0
		For i:=1 to Len(aColsC)
			if !aColsC[i,Len(aColsC[i])]
				nSubTotal := nSubtotal + Round(val(Transform(aColsC[i,4],"999999.99")),2)
			Endif
		Next
		For i:=1 to Len(aIteParc)
			nSubTotal := nSubtotal + Round(val(Transform(aIteParc[i,2],"999999.99")),2)
		Next
		
		if Empty(aIteParc[1,1]) .or. aIteParc[1,2] = 0 .or. Round(nSubTotal,2) <> Round(nTotTit,2)
			if SE4->(DbSeek(xFilial("SE4")+M->VS1_FORPAG))
				if val(AllTrim(SE4->E4_COND)) > 0
					cTipPag1 := "VS1_FORPAG"
					/*
					nTotFre := M->VS1_VALFRE
					nTotSeg := M->VS1_VALSEG
					nTotAce := M->VS1_DESACE
					*/
					FS_CALPAR(cTipOpe,nTotTit)
				Else
					FG_DesfPag()
					cCondic1:=ctod(" ")
					cCondic2:=space(02)
					cCondic3:=space(Len(SE1->E1_PARCELA))
					cCondic4:=space(02)
				Endif
			Else
				if !lPriVez
					cTipPag := M->VS1_FORPAG
					cDesPag := M->VS1_DESFPG
					oTipPag:Refresh()
					oDesPag:Refresh()
				Endif
			Endif
		Endif
		
		nOld := n
		For y:=1 to Len(aColsP)
			n := y
			if !Empty(aColsP[n,fg_posvar("VS3_CODTES","aHeaderP")])
				if !aColsP[n,Len(aColsP[n])]
					If (cPaisLoc == "BRA") // Manoel - 07/05/2009
						aColsP[n,fg_posvar("VS3_VBAICM","aHeaderP")] := MaFisRet(n,"IT_BASEICM")
						aColsP[n,fg_posvar("VS3_ALIICM","aHeaderP")] := MaFisRet(n,"IT_ALIQICM")
						aColsP[n,fg_posvar("VS3_ICMCAL","aHeaderP")] := MaFisRet(n,"IT_VALICM")
					Endif
				Else
					MaFisRef("IT_VALMERC","VS300",0)
					MaFisRef("IT_TES","VS300",aColsP[n,FG_POSVAR("VS3_CODTES","aHeaderP")])
					MaFisRef("IT_DESCONTO","VS300",0)
				Endif
			Endif
		Next
		n := nOld
		
		M->VS1_VTOTNF := MaFisRet(,"NF_TOTAL")-MaFisRet(,"NF_DESCZF")
		M->VS1_VALDES := MaFisRet(,"NF_DESCONTO")
		M->VS1_ICMCAL := MaFisRet(,"NF_VALICM")
		M->VS1_DESACE := MaFisRet(,"NF_DESPESA")
	
		M->VS1_VALFRE := MaFisRet(,"NF_FRETE")
		M->VS1_VALSEG := MaFisRet(,"NF_SEGURO")
		
		nTotOrc := M->VS1_VTOTNF                 //FNC - 13653 - BOBY 24/06/10
		oTotOrc :Refresh()                       //FNC - 13653 - BOBY 24/06/10
		
		
		aHeader := aClone(aHeaderSlv)
		aCols   := aClone(aColsSlv)
		n       := nSlv
	Endif
	
	// Verifica Custo dos Itens
	// Manoel - 26/05/2009
	If GetNewPar("MV_LIBVAC","N") == "N"
		nSlv := n
		For y:=1 to Len(aColsP)
			n := y
			SF4->(dbseek(xFilial("SF4")+aColsP[n,fg_posvar("VS3_CODTES","aHeaderP")]))
			if !aColsP[y,Len(aColsP[y])] .and. SF4->F4_OPEMOV = "05"  //VENDA
				DbSelectArea("SB1")
				DbSetOrder(7)
				DbSeek(xFilial("SB1")+aColsP[n,fg_posvar("VS3_GRUITE","aHeaderP")]+aColsP[n,fg_posvar("VS3_CODITE","aHeaderP")])
				
				DbSelectArea("SB2")
				DbSetOrder(1)
				DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
				If Round((aColsP[n,fg_posvar("VS3_VALTOT","aHeaderP")]/aColsP[n,fg_posvar("VS3_QTDITE","aHeaderP")]),2) < Round(SB2->B2_CM1,2)
					MSGInfo(STR0526+ aColsP[n,fg_posvar("VS3_GRUITE","aHeaderP")]+aColsP[n,fg_posvar("VS3_CODITE","aHeaderP")]+ chr(10)+chr(13)+;
					STR0527)
					aHeader := aClone(aHeaderSlv)
					aCols   := aClone(aColsSlv)
					n       := nSlv
					oFolder:nOption := 2
					Return
				Endif
			Endif
		Next
		n := nSlv
	Endif
	
Endif

if oFolder:nOption # 2
	Return
Endif

if Type(cGetDados) <> "U"
	if &(cGetDados):oBrowse:lVisible
		aHeader := aclone(aHeaderI)
		&(cGetDados):oBrowse:Refresh()
	Endif
Endif

if lJaPerg == .t.
	Return
Endif

wOpca   := 2
cNumOrc := space(8)

DEFINE MSDIALOG oDlgPerg TITLE OemtoAnsi(STR0127) FROM  02,04 TO 10,28 OF oMainWnd   //"Tipo de Inclusao"

nCkPerg1 := 1
@ 005,005 RADIO oRadio1 VAR nCkPerg1 3D SIZE 70,10 PROMPT;
OemToAnsi(STR0393), OemToAnsi(STR0394);//Novo orcamento # Orcamento ja existente
OF oDlgPerg PIXEL ON CHANGE (iif(nCkPerg1==1,(oRadio2:lVisible:=.t.,oNumOrc:lVisible:=.f.),(oRadio2:lVisible:=.f.,oNumOrc:lVisible:=.t.)))

@ 028,005 MSGET oNumOrc VAR cNumOrc PICTURE "99999999" VALID FS_PESQORC() SIZE 37,10 OF oDlgPerg PIXEL //WHEN (nCkPerg1==2)

nCkPerg2 := 1
@ 028,005 RADIO oRadio2 VAR nCkPerg2 3D SIZE 70,10 PROMPT;
OemToAnsi(STR0395), OemToAnsi(STR0396); //Normal # Outras operacoes
OF oDlgPerg PIXEL ON CHANGE (.t.)
oRadio2:lVisible := .t.

@ 048,005 BUTTON oOk  PROMPT OemToAnsi(STR0397) OF oDlgPerg SIZE 43,11 PIXEL ACTION (wOpca := 1,oDlgPerg:End()) //Confirma
@ 048,048 BUTTON oNo  PROMPT OemToAnsi(STR0323) OF oDlgPerg SIZE 43,11 PIXEL ACTION (wOpca := 2,oDlgPerg:End())//Cancela

oOk:SetFocus()

ACTIVATE MSDIALOG oDlgPerg CENTER ON INIT ( If( Type("aCrrgVar") # "U", (Eval(oOk:bAction)) ,.t.) )

oGetMGet:oBox:Enable()
oGetSrvcs:oBrowse:Enable()
oGetPecas:oBrowse:Enable()

oGetMGet:lActive := .t.
oGetSrvcs:lActive := .t.
oGetPecas:lActive := .t.
oLbIteRel:Enable()

lBotOpc := .t.

if wOpca == 1
	
	If !Empty(cNumOrc) // Orcamento ja existente, numero ja digitado
		aAux := {}
		aAux := aClone(aIteBrw)
		aIteBrw := {}
		aadd(aIteBrw,{.f.," "," "," "," ",ctod("")," ",ctod("")," "," "," "," "})
		aIteBrw[1,3] := cNumOrc
		FS_ABREORC(1)
		aIteBrw := {}
		aIteBrw := aClone(aAux)
		oGetMGet:oBox:Enable()
		oGetSrvcs:oBrowse:Enable()
		oGetSrvcs:Refresh()
		oGetPecas:oBrowse:Enable()
		oGetMGet:lActive := .t.
		oGetSrvcs:lActive := .t.
		oGetPecas:lActive := .t.
		oLbIteRel:Enable()
		lBotOpc := .t.
		If !Empty(VS1->VS1_NUMOSV)
			MsgStop(STR0291+VS1->VS1_NUMOSV+Chr(13)+Chr(10)+STR0292,STR0148 )
			lBotOpc := .f.
			oGetMGet:lActive := .f.
			oGetSrvcs:lActive := .f.
			oGetPecas:lActive := .f.
			oLbIteRel:Disable()
		EndIf
		oOpcoes2:SetFocus()
		Return
	EndIf
	
	Limpa_Var()
	cOpeMov := str(nCkPerg1,1)
	
	if nCkPerg1 == 2   // 2-Orcamento ja existente
		
		dbSelectArea("VS1")
		if RecCount() = 0
			MsgInfo(STR0129,STR0019)   //"Nenhum Orcamento para ser Aberto!","Atencao!"
			oFolder:nOption := 1
			Return
		Else
			if !BrowseOrc()
				dbSelectArea("VS1")
				Return
			Endif
		Endif
		
	Else
		
		cOpeMov2 := str(nCkPerg2,1)
		
		if cOpeMov2 == "2"
			
			// Tela de TES especiais
			
			aTesEsp := {}
			if VEB->(FieldPos("VEB_FORMUL")) <> 0
				lFOOper := .t.
			EndIf
			dbSelectArea("VEB")
			dbSetOrder(1)
			dbSeek(xFilial("VEB"))
			While !Eof()
				SX5->(dbSeek(xFilial("SX5")+"VR"+VEB->VEB_CODOPE))
				cDesOpe := SX5->X5_DESCRI
				if val(VEB->VEB_TESPAD) >= 500
					aadd(aTesEsp,{VEB->VEB_CODOPE,cDesOpe,VEB->VEB_TESPAD,If(lFOOper,VEB->VEB_FORMUL,"")})
				Endif
				dbSelectArea("VEB")
				dbSkip()
			EndDo
			
			if Len(aTesEsp) == 0
				aadd(aTesEsp,{"","","",""})
			Endif
			
			xOpca   := 1
			DEFINE MSDIALOG oDlgTes TITLE STR0398 From 10,10 to 28,84 of oMainWnd //Tipos de Operacoes Padrao
			
			@ 012,001 LISTBOX oLbTes FIELDS HEADER  OemToAnsi(STR0399),OemToAnsi(STR0400),OemToAnsi(STR0401),OemToAnsi(STR0402) COLSIZES 30,175,35,35 SIZE 291,123 OF oDlgTes PIXEL//Operacao # Descricao # TES Padrao # Formula Padrao
			
			oLbTes:SetArray(aTesEsp)
			oLbTes:bLine := { || { aTesEsp[oLbTes:nAt,1] ,;
			aTesEsp[oLbTes:nAt,2] ,;
			aTesEsp[oLbTes:nAt,3] ,;
			aTesEsp[oLbTes:nAt,4] }}
			
			ACTIVATE MSDIALOG oDlgTes CENTER ON INIT EnchoiceBar(oDlgTes,{|| xOpca := 1, cCodOpe := aTesEsp[oLbTes:nAt,1], cTesPad := aTesEsp[oLbTes:nAt,3],cFOOper:=aTesEsp[oLbTes:nAt,4],oDlgTes:End()},{|| xOpca := 2,oDlgTes:End()})
			
			if !Empty(cTesPad)
				if !SF4->(dbSeek(xFilial("SF4")+cTesPad))
					MsgInfo(STR0403 ,STR0148) //Este TES nao foi cadastrado na tabela de TES.. # Atencao!
					cTesPad := Space(3)
				Endif
			Endif
			
			if xOpca == 2
				lDestroy := .f.
				lJaPerg  := .f.
				oFolder:nOption := 1
				Return .f.
			Endif
			
			/*
			// Tela de TES especiais Itens
			
			aTesEsp2 := {}
			
			dbSelectArea("VEL")
			dbSetOrder(1)
			dbSeek(xFilial("VEL")+cCodOpe)
			While !Eof() .and. VEL->VEL_CODOPE == cCodOpe
			SX5->(dbSeek(xFilial("SX5")+"S0"+VEL->VEL_ORIGEM))
			cDesOpe := SX5->X5_DESCRI
			aadd(aTesEsp2,{VEL->VEL_ORIGEM,cDesOpe,VEL->VEL_TESESP})
			dbSelectArea("VEL")
			dbSkip()
			EndDo
			if Len(aTesEsp2) > 0 .and. !Empty(aTesEsp2[1,1])
			xOpca   := 1
			DEFINE MSDIALOG oDlgTes TITLE "Tipos de Operacoes Padrao" From 10,10 to 28,84 of oMainWnd
			
			@ 012,001 LISTBOX oLbTes FIELDS HEADER  OemToAnsi("Origem"),;
			OemToAnsi("Descricao"),;
			OemToAnsi("TES Padrao");
			COLSIZES 30,200,20 SIZE 291,123 OF oDlgTes PIXEL
			
			oLbTes:SetArray(aTesEsp2)
			oLbTes:bLine := { || { aTesEsp2[oLbTes:nAt,1] ,;
			aTesEsp2[oLbTes:nAt,2] ,;
			aTesEsp2[oLbTes:nAt,3] }}
			
			ACTIVATE MSDIALOG oDlgTes CENTER ON INIT EnchoiceBar(oDlgTes,{|| xOpca := 1, cTesPad := aTesEsp[oLbTes:nAt,3],oDlgTes:End()},{|| xOpca := 2,oDlgTes:End()})
			
			if !Empty(cTesPad)
			if !SF4->(dbSeek(xFilial("SF4")+cTesPad))
			MsgInfo("Este TES nao foi cadastrado na tabela de TES...","Atencao!")
			cTesPad := Space(3)
			Endif
			Endif
			
			if xOpca == 2
			lDestroy := .f.
			lJaPerg  := .f.
			oFolder:nOption := 1
			Return .f.
			Endif
			Endif
			*/
		Endif
		
		Inclui := .t.
		Inclui2:= .t.
		
		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("VS1")
		While !EOF() .and. X3_ARQUIVO == "VS1"
			wVar := "M->"+x3_campo
			&wVar:= CriaVar(x3_campo)
			dbSkip()
		EndDo
		M->VS1_DATVAL := dDataBase+GetNewPar("MV_DTLIMIT",0)
		M->VS1_OBSERV := ""
		
		if cOpeMov2 == "2"
			M->VS1_TIPORC := "1"  // Venda de Pecas
			M->VS1_CODTES := cTesPad
			If !Empty(cFOOper)
				M->VS1_FORMUL := cFOOper
			EndIf
		Endif
		if GetNewPar("MV_GSXEORC","N") == "S"
			ConfirmSx8()
		Endif
		
		aColsP[1,FG_POSVAR("VS3_SEQUEN","aHeaderP")]:= [001]
		aColsS[1,FG_POSVAR("VS4_SEQUEN","aHeaderS")]:= [001]
		
	Endif
	
	oGetMGet:obox:Refresh()
	
	aCols   := aClone(aColsS)
	aHeader := aClone(aHeaderS)
	n       := nS
	oGetSrvcs:oBrowse:Refresh()
	
	aCols   := aClone(aColsP)
	aHeader := aClone(aHeaderP)
	n       := nP
	oGetPecas:oBrowse:Refresh()
	
	if Type(cGetDados) <> "U"
		if &(cGetDados):oBrowse:lVisible
			aHeader := aclone(aHeaderI)
			&(cGetDados):oBrowse:Refresh()
		Endif
	Endif
	
	lJaPerg := .t.
	
	dbSelectArea("SE4")
	if dbSeek(xFilial("SE4")+M->VS1_FORPAG)
		cTipPag := M->VS1_FORPAG
		cDesPag := SE4->E4_DESCRI
		M->VS1_FORPAG := cTipPag
		M->VS1_DESFPG := cDesPag
	Endif
	
	dbSelectArea("SA6")
	if dbSeek(xFilial("SA6")+M->VS1_CODBCO)
		M->VS1_NOMBCO := SA6->A6_NOME
		cCodBco := M->VS1_CODBCO
		cDesBco := M->VS1_NOMBCO
	Endif
	
	dbSelectArea("VEG")
	if dbSeek(xFilial("VEG")+M->VS1_FORMUL)
		M->VS1_NOMFOR := VEG->VEG_DESCRI
	Endif
	
	if !Inclui
		cAlias := Alias()
		dbSelectArea("VS1")
		For nCntFor := 1 TO FCount()
			M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
		Next
		dbSelectarea(cAlias)
	Endif
	
	if Inclui
		dbSelectArea("VAI")
		dbSetOrder(4)
		dbSeek(xFilial("VAI")+__cUserID)
		
		dbSelectArea("SA3")
		dbSetOrder(1)
		if !dbSeek(xFilial("SA3")+VAI->VAI_CODVEN)
			MsgInfo(STR0404 ,STR0148) //Usuario sem codigo de vendedor relacionado ! # Atencao!
			Return .f.
		Endif
		M->VS1_CODVEN := VAI->VAI_CODVEN
		cCodVen := SA3->A3_COD
		M->VS1_NOMVEN := SA3->A3_NOME
		M->VS1_CENCUS := VAI->VAI_CC
	Endif
	
	oGetMGet:SetFocus()
	
	/*
	dbSelectArea("VSM")
	dbSetOrder(6)
	if dbSeek(xFilial("VSM")+M->VS1_NUMORC)
	while !EOF() .and. VSM->VSM_NUMORC == M->VS1_NUMORC
	RecLock("VSM",.f.,.t.)
	VSM->(dbDelete())
	MsUnlock()
	WriteSx2("VSM")
	dbSelectArea("VSM")
	dbSkip()
	EndDo
	Endif
	*/
Else
	lDestroy := .f.
	lJaPerg  := .f.
	oFolder:nOption := 1
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_DESTROY  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Limpa a GetDados e Enchoice da Tela                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_DESTROY()

Local _ni:=0

//DeleteObject(oGetMGet)
//DeleteObject(oGetSrvcs)
//DeleteObject(oGetPecas)

lJaPerg  := .f.

nOpc := 3 // Incluir
nOpcG:= 3 // Incluir
nOpcE:= 3 // Incluir

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS1")

aPriEnc := {}

While x3_arquivo == "VS1" .and. !eof()
	if X3USO(x3_usado).and.cNivel>=x3_nivel
		AADD(aPriEnc,x3_campo)
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

//Pecas

nUsadoP:=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS3")
aHeaderP:={}
While !Eof().And.(x3_arquivo=="VS3")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( ! Trim(SX3->X3_CAMPO) $ "VS3_NUMORC" )
		nUsadoP++
		Aadd(aHeaderP,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		wVar := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols Pecas                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aColsP:={Array(nUsadoP+1)}
aColsP[1,nUsadoP+1]:=.F.
For _ni:=1 to nUsadoP
	aColsP[1,_ni]:=CriaVar(aHeaderP[_ni,2])
Next

//Servicos

nUsadoS := 0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS4")
aHeaderS := {}
While !Eof() .And. (x3_arquivo=="VS4")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( ! Trim(SX3->X3_CAMPO) $ "VS4_NUMORC" )
		nUsadoS++
		Aadd(aHeaderS,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
		wVar := "M->"+x3_campo
		&wVar := CriaVar(x3_campo)
	Endif
	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols Servicos                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aColsS:={Array(nUsadoS+1)}
aColsS[1,nUsadoS+1]:=.F.
For _ni:=1 to nUsadoS
	aColsS[1,_ni]:=CriaVar(aHeaderS[_ni,2])
Next

dbSelectArea("VS1")

if Type(cGetDados) <> "U"
	aCols   := {}
	aHeader := aClone(aHeaderI)
	&(cGetDados):oBrowse:Refresh()
Else
	aCols := aClone(aColsP)
	aHeader := aClone(aHeaderP)
	oGetPecas:oBrowse:Refresh()
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FECVDA ³ Autor ³ ANDRE                 ³ Data ³ 20/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao que faz integracao com MS, emite a NF/Bloqueto ...   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FECVDA()

Local lIteLib    := .t.
Local lRet       := .t.
Local lEntrada   := .f.
Local nwnk       := 0

Local lEstNeg    := .f.
Local i:=0
Local y:=0
Local x:=0
Local cMsg := ""
Local nQtdVal := 0
Local aAreaVS1  := VS1->(GetArea())
Local nVFatMin  := GetNewPar("MV_FATMIN",0)
Private nAliPis := GETMV("MV_TXPIS")  / 100
Private nAliCof := GETMV("MV_TXCOFIN")/ 100

dbSelectArea("VAI")
If Empty(M->VS1_CODVEN)
	dbSetOrder(4)
	dbSeek(xFilial("VAI")+__cUserID)
Else
	dbSetOrder(6)
	dbSeek(xFilial("VAI")+M->VS1_CODVEN)
Endif

lEmiNfi := .t.
If cPaisLoc == "BRA"
	if !(lEmiNfi := VAI->VAI_EMINFI == "1")
		MsgInfo(STR0405 ,STR0148) //Opcao de emissao de Nota Fiscal nao permitida para este usuario! # Atencao!
		Return(.f.)
	Endif
Endif

VS1->(dbSetOrder(1))
if VS1->(dbSeek(xFilial("VS1")+M->VS1_NUMORC))
	if !Empty(VS1->VS1_NUMPED)
		MsgInfo(STR0406 ,STR0148) //Orcamento ja foi finalizado... # Atencao!
		RestArea(aAreaVS1)
		Return(.f.)
	Endif
Endif

If (cPaisLoc == "BRA") // Manoel - 07/05/2009
	If !MsgYesNo(OemToAnsi(STR0130),OemToAnsi(STR0019))
		RestArea(aAreaVS1)
		Return
	Endif
Endif
lEntrou := .f.

if !FS_VALFPG(1)
	Help(" ",1,"M160TIPPAG")   // Falta Tipo de Pagamento
	RestArea(aAreaVS1)
	Return .f.
Endif

if !FS_VALFPG(2)
	Help(" ",1,"M110BANCO")   // Falta Banco
	RestArea(aAreaVS1)
	Return( .f. )
Endif

if Empty(GetMv("MV_CPNCLC")) .or. !alltrim(cTipPag) $ GetMv("MV_CPNCLC")
	If "B" $ GetMv("MV_CHKCRE")
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+M->VS1_CLIFAT+M->VS1_LOJA)
		If !MaAvalCred(M->VS1_CLIFAT, M->VS1_LOJA, (nTotOrc+FG_AVALCRED(M->VS1_CLIFAT, M->VS1_LOJA)) ,1,.T.)
			Help("  ",1,"LIMITECRED")
			RestArea(aAreaVS1)
			Return( .f. )
		EndIf
	EndIf
Endif

// Andre Luis Almeida - 20/06/08 - No Fechamento da Venda verifica se Qtde.Informada e' maior que a Disponivel //
If GetMv("MV_ESTNEG") <> "S"
	For i:=1 to Len(aColsP)
		If !aColsP[i,Len(aColsP[i])]
			DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek(xFilial("SF4")+aColsP[i,FG_POSVAR("VS3_CODTES","aHeaderP")])
			If SF4->F4_ESTOQUE == "S"
				DbSelectArea("SB1")
				DbSetOrder(7)
				DbSeek(xFilial("SB1")+aColsP[i,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")])
				cMsg := STR0407 +" '"+Alltrim(SB1->B1_GRUPO)+" "+Alltrim(SB1->B1_CODITE)+" - "+Alltrim(SB1->B1_DESC)+"' "+ STR0408 +CHR(13)+CHR(10)+CHR(13)+CHR(10) //O Item # nao pode ser vendido! Qtde.Informada maior que a Disponivel no Armazem
				cMsg += STR0409 +": "+Transform(aColsP[i,FG_POSVAR("VS3_QTDITE","aHeaderP")],"@E 999,999,999")+CHR(13)+CHR(10)+ STR0410  //Qtde.Informada # Disponivel no Armazem
				If !Empty(aColsP[i,FG_POSVAR("VS3_LOCAL","aHeaderP")])
					nQtdVal := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+aColsP[i,FG_POSVAR("VS3_LOCAL","aHeaderP")])
					cMsg += aColsP[i,FG_POSVAR("VS3_LOCAL","aHeaderP")]
				Else
					nQtdVal := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
					cMsg += SB1->B1_LOCPAD
				EndIf
				cMsg += ": "+Transform(nQtdVal,"@E 999,999,999")
				If aColsP[i,FG_POSVAR("VS3_QTDITE","aHeaderP")] > nQtdVal
					MsgStop(cMsg,STR0148) //Atencao!
					oFolder:nOption := 2
					Return( .f. )
				EndIf
			EndIf
		EndIf
	Next
EndIf
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

nTotOrc := 0
nTotTit := 0
nBrinde := 0
For i:=1 to Len(aColsP)
	if !aColsP[i,Len(aColsP[i])]
		If (GetMV("MV_ARREFAT")=="S")
			nTotOrc += Round(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
		Else
			nTotOrc += NoRound(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
		Endif
		if TipoTes(aColsP[i,FG_POSVAR("VS3_CODTES","aHeaderP")])
			If (GetMV("MV_ARREFAT")=="S")
				nTotTit += Round(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
			Else
				nTotTit += NoRound(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
			Endif
			//if SF4->F4_INCSOL == "S"
			//   nTotTit += MaFisRet(i,"IT_VALSOL")
			//Endif
		Else
			nBrinde += Round(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
		Endif
	Endif
Next

nTotOrc += M->VS1_DESACE
nTotTit += M->VS1_DESACE

nTotOrc += M->VS1_VALFRE
nTotTit += M->VS1_VALFRE

nTotOrc += M->VS1_VALSEG
nTotTit += M->VS1_VALSEG

//nTotOrc := MaFisRet(,"NF_TOTAL")-MaFisRet(,"NF_DESCZF")   //FNC - 14803 - BOBY 04/08/10
nTotTit := nTotOrc - nTotCre                                //FNC - 14803 - BOBY 04/08/10
//nTotTit -= nTotCre 

if nTotOrc <= 0
	MsgInfo(STR0411 ,STR0148) //Total da Nota esta incorreto... # Atencao!
	RestArea(aAreaVS1)
	Return( .f. )
Endif

if ExistBlock("VALESTNEG")
	if !(lEstNeg := ExecBlock("VALESTNEG",.f.,.f.))
		oFolder:nOption := 2
		RestArea(aAreaVS1)
		Return
	Endif
EndIf

if Len(aIteBlq) > Len(aColsP)
	aDel(aIteBlq,Len(aIteBlq))
	aSize(aIteBlq,Len(aIteBlq)-1)
Endif
if Len(aIteRes) > Len(aColsP)
	aDel(aIteRes,Len(aIteRes))
	aSize(aIteRes,Len(aIteRes)-1)
Endif

For y:=1 to Len(aIteBlq)
	if y <= Len(aColsP)
		if !aColsP[y,Len(aColsP[y])]
			if aIteBlq[y,2] == "S"
				dbSelectArea("SB1")
				dbSetOrder(7)
				dbSeek(xFilial("SB1")+aColsP[y,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[y,FG_POSVAR("VS3_CODITE","aHeaderP")])
				dbSelectArea("SB2")
				nSaldo := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+LocIte110(.f.,aColsP,y))
				// faz a verificacao da qtde reserva anteriormente e a diferenca digita para
				// se o saldo eh suficiente para suprir a necessidade
				If !y > Len(aIteRes)
					nTotOld := aIteRes[y,3]
					If nTotOld <> 0 .and. aColsP[y,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[y,FG_POSVAR("VS3_CODITE","aHeaderP")]==aIteRes[y,2]
						If nTotOld-aColsP[y,FG_POSVAR("VS3_QTDITE","aHeaderP")] > 0
							nTotOld := 0
						Endif
					Else
						nTotOld := 0
					Endif
				Else
					nTotOld := aColsP[y,FG_POSVAR("VS3_QTDITE","aHeaderP")]
				Endif
				if nSaldo <= 0 .or. nSaldo < nTotOld
					lIteLib := .f.
				Endif
			Endif
		Endif
	Endif
Next

if !lIteLib .and. !lEstNeg .and. SF4->F4_ESTOQUE == "S"
	Help(" ",1,"NAOHAITEM")
	oFolder:nOption := 2
	RestArea(aAreaVS1)
	Return( .f. )
Endif

For x:=1 to Len(aColsP)
	if !aColsP[x,Len(acolsP[x])]
		if aColsP[x,FG_POSVAR("VS3_VALPEC","aHeaderP")] = 0
			Help(" ",1,"SEMPRECO")
			oFolder:nOption := 2
			RestArea(aAreaVS1)
			Return( .f. )
		Endif
	Endif
Next

if SubStr(aHeader[1,2],1,3) == "VS9"
	aColsC   := aClone(aCols)
	aHeaderC := aClone(aHeader)
Endif

If !FS_VLDDTPG() //*** 12/06/2009 - Otavio - Validar se os campos de data do aColsC(Entrada) e do aIteParc(Parcelas) estao validos.
	Return( .f. )
EndIf

//Variavel para validar se a Entrada + Financiamento Batem com o Valor Total
nSubTotal := 0

For nWnk := 1 to Len(aColsC)
	If !Empty(aColsC[nWnk,1]) .and. !aColsC[nWnk,Len(aColsC[nWnk])]
		lEntrada := .T.
		Exit
	Endif
Next

if lEntrada .and. !Empty(SA1->A1_TIPPER) .and. !Empty(cForPeri) .and. cForPeri == cTipPag
	MsgInfo(STR0412 ,STR0148) //Por se tratar de cliente periodico nao pode ser dada nenhuma entrada... # Atencao!
	RestArea(aAreaVS1)
	Return( .f. )
Endif

If !lEntrada
	For nWnk := 1 to Len(aIteParc)
		If !Empty(aIteParc[nWnk,1]) .and. aIteParc[nWnk,2] > 0
			lEntrada := .T.
			Exit
		Endif
	Next
Endif

if lEntrada
	For i:=1 to Len(aColsC)
		if !aColsC[i,Len(aColsC[i])]
			nSubTotal := nSubtotal + Round(val(Transform(aColsC[i,4],"999999.99")),2)
		Endif
	Next
	For i:=1 to Len(aIteParc)
		nSubTotal := nSubtotal + Round(val(Transform(aIteParc[i,2],"999999.99")),2)
	Next
Else
	nSubTotal := nTotOrc
Endif

if Round(nSubTotal,2) < Round(nTotOrc-nBrinde,2)
	MsgInfo(STR0131,STR0019)  //"Entrada + Financiamento nao Bate com Valor TOTAL...","Atencao !"
	RestArea(aAreaVS1)
	Return( .f. )
Endif

//Verifica se tem valor minimo para faturar
if SE4->(dbSeek(xFilial("SE4")+M->VS1_FORPAG))
	if val(AllTrim(SE4->E4_COND)) > 0
		if nVFatMin > 0 .and. nTotOrc < nVFatMin
			MsgInfo(STR0413 ,STR0148) //Valor Minimo para venda a prazo nao atingido... # Atencao!
			RestArea(aAreaVS1)
			Return( .f. )
		Endif
	Endif
Endif

lSalvou := .t.
FS_FINORC(Nil,.f.)

if ( ExistBlock("OFM110A") )
	lRet := ExecBlock("OFM110A",.f.,.f.)
	if !lRet
		RestArea(aAreaVS1)
		Return(lRet)
	Endif
EndIf

//Nao integra com o SIGALOJA  ou  integra com o SIGALOJA e o usuario selecionou NF
// Manoel - 07/05/09
If (cPaisLoc == "BRA")
	If Substr(GetMv("MV_LOJAVEI",,"NNNNNN"),1,1) == "N" .or. ( Substr(GetMv("MV_LOJAVEI",,"NNNNNN"),1,1) == "S" .and. nCheck==1 )
		lGeraLoja := .f.
	Else
		//Integra com o loja
		lGeraLoja := .t.
	Endif
Else
	//Integra com o loja
	lGeraLoja := .t.
Endif

/*
if cOpeMov2 == "2"
if MsgYesNo("Gera Nota Fiscal no Loja","Pergunta ?")
lGeraLoja := .f.
Endif
Endif
*/

if LiberaVenda()
	if !OFIOM380(M->VS1_NUMORC)
		MsgInfo(STR0414 ,STR0148) //Orcamento nao conferido... # Atencao!
		RestArea(aAreaVS1)
		Return
	Endif
	
	If !lGeraLoja	//nao Integrado com o Sigaloja ?
		Processa( { || Fechavenda() } )
	Else
		Processa( { || FS_PROLOJA() } )
	EndIf
Endif

if ( ExistBlock("OFM110B") )
	lRet := ExecBlock("OFM110B",.f.,.f.)
	if !lRet
		RestArea(aAreaVS1)
		Return(lRet)
	Endif
EndIf

if GetNewPar("MV_IMPORDB","N") == "S"
	if ExistBlock("ORDBUSCB")
		ExecBlock("ORDBUSCB",.f.,.f.)
	Endif
Endif

if lDestroy
	cNumLib   := " "
	lJaGravou := .f.
	lJaperg   := .f.
	FS_DESTROY()
	nValorCom := 0
	cCodCdci  := space(4)
	//Zera as variaveis fiscais
	MaFisEnd()
	oFolder:aDialogs[1]:SetFocus()
	oFolder:nOption := 1
Else
	oFolder:aDialogs[2]:SetFocus()
	oFolder:nOption := 2
Endif

RestArea(aAreaVS1)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Fechavenda³ Autor ³ ANDRE                 ³ Data ³ 20/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao que faz integracao com MS, emite a NF/Bloqueto ...   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FechaVenda( oMeter, oText, oDlg, lEnd )

Local lRet      := .t.
Local lSerie    := .f.


Local lInclui   := Inclui
Local lIntNF    := .t.
Local iz_:=0
Local cEstado

//Private cNumPed := CriaVar("C5_NUM")
Private cNumPed := ""
Private j := 1
Private aCabPV  := {}
Private aItePV  := {}
Private lError  := .F.
// CRM
Private cCrmVei   := ""
Private lCamposCrm:= .F.

cSerie  := iif(nCheck==1,"",SuperGetMv("MV_SERCUP"))
// Meter
ProcRegua(9)
IncProc(STR0216)
If lAbortPrint
	If MsgYesNo(OemToAnsi(STR0229),OemToAnsi(STR0148))
		Help("  ",1,"M160PROABO")
		lRet := .f.
		lError := .T.
		DisarmTransaction()
		Break
	Else
		lAbortPrint := .f.
	EndIf
EndIf

lMsErroAuto := .f.
Inclui      := .t.
lSalvou     := .f.

//Volta estado do cliente (qdo cliente padrao)
if lVAMCid
	FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
	cEstado := VAM->VAM_ESTADO
Else
	cEstado := SA1->A1_EST
Endif

//if SA1->A1_PESSOA == "F" .and. !Empty(SA1->A1_INSCR) .and. cEstado <> GETMV("MV_ESTADO")
//   MaFisAlt("NF_CODCLIFOR",GetMv("MV_CLIPAD"))
//   MaFisAlt("NF_LOJA",GetMv("MV_LOJAPAD"))
//Endif

aProdutos := {}
For iz_:=1 to Len(aColsP)
	_cGruIte := aColsP[iz_,FG_POSVAR("VS3_GRUITE","aHeaderP")]
	_cCodIte := aColsP[iz_,FG_POSVAR("VS3_CODITE","aHeaderP")]
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+_cGruIte+_cCodIte)
	aadd(aProdutos,{SB1->B1_COD,if(M->VS1_ORCACE$"1 ",LocIte110(.f.,aColsP,iz_),GetMv("MV_RESITE"))})
Next

//Funcao para travar o SB2
FG_TRVM410(aProdutos,"N",SA1->A1_COD,SA1->A1_LOJA)

//Valida se o Sx5 esta em uso por outro usuario
//If !FG_SEMAFORO("SX5")
//	Return( .f. )
//EndIf

if ExistBlock("INTNFBAL")
	lIntNF := ExecBlock("INTNFBAL",.f.,.f.)
Endif

if nCheck == 1 .and. lIntNF //Nota Fiscal
	If (cPaisLoc == "BRA") // Manoel - 07/05/2009
		lSerie := Sx5NumNota(.T.,GetNewPar("MV_TPNRNFS","1"))
		If !lSerie
			//		SX5->(MsRUnLock())
			MsgStop(STR0215)
			Return .f.
		Endif
	Endif
Endif

// CRM
cCrmVei := ""
If Substr(GetMv("MV_CRMVEI",,"N"),1,1)=="S" .and. Substr(GetMv("MV_CRMVEI",,"N"),4,1)=="S"
	If FG_PESQTAB("VO1_CRMOK")
		If Pergunte("CRMVEI",.T.)
			cCrmVei	:= MV_PAR01
		Endif
		lCamposCrm := .T.
	Else
		lCamposCrm := .F.
	Endif
Endif

lSalvou := .f.
FS_SALVAR()

// por mais estranho que pareca esta funcao deve ser chamada aqui, antes da transacao - nao mexer - farinelli
If Select("__SE1")==0
	SumAbatRec( "", "", "", 1, "")
Endif
PERGUNTE("MT460A",.f.)
Begin Transaction
IncProc(STR0217)
Gera_Pedido()

If !(cPaisLoc == "BRA") // Manoel - 07/05/2009
	If M->VS1_TIPVEN == "2" // Atacadista
		lIntNF := .f.
		lError := .f.
	Endif
Endif

if lIntNF
	IncProc(STR0218)
	lRet := Nota_Fiscal()
	
	if ExistBlock("EMINFO110")
		ExecBlock("EMINFO110",.f.,.f.)
	Endif
	
	IncProc(STR0219)
	lRet := Gera_Titulo()
	
	if ExistBlock("EMITTO110")
		ExecBlock("EMITTO110",.f.,.f.)
	Endif
	
	IncProc(STR0220)
	lRet := Baixa_Titulo()
	IncProc(STR0221)
Endif
GrAvaliacao()
IncProc(STR0222)
GravEntrada()
IncProc(STR0223)
Financ_CDCI()
if lRecompra
	if ExistBlock("RETPEC110")
		ExecBlock("RETPEC110",.f.,.f.)
	Endif
Endif
End Transaction 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
MsRUnLock()

//FG_SEMAFORO("SX5","L")
//SX5->(MsRUnLock())

Inclui := lInclui

If !lError
	if !lMsErroauto
		lAcabLj := .t.
		IncProc(STR0224)
		Imprime_Doc()
		IncProc(STR0225)
		lDestroy := .t.
		Limpa_Var()
		
		MaFisEnd()
		if lIntNF
			
			DEFINE MSDIALOG oDlgNF TITLE OemtoAnsi("Nota Fiscal") FROM  02,04 TO 10,28 OF oMainWnd
			
			@ 016, 002 Say STR0227 + cNota  OF oDlgNF PIXEL FONT oFnt3
			@ 028, 002 Say STR0228 + cSerie OF oDlgNF PIXEL FONT oFnt3
			
			@ 048,048 BUTTON oOK  PROMPT OemToAnsi(STR0028)  OF oDlgNF SIZE 43,11 PIXEL ACTION (oDlgNF:End())//OK
			
			oOk:SetFocus()
			
			ACTIVATE MSDIALOG oDlgNF CENTER
			
		Endif
	Else
		MostraErro()
	Endif
Else
	if lMsErroauto
		MostraErro()
	Else
		lAcabLj := .t.
	Endif
	MsgStop(OemToAnsi(STR0415))//A venda nao foi concluida corretamente.
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LiberaVenda³ Autor ³ ANDRE                ³ Data ³ 20/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se existe desconto nao permitido                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LiberaVenda()

Local lRet      := .t.
Local lLiberado := .f.

Private lDesPer   := .t.

if !Empty(cNumLib)
	lRet := FS_CHECKLIB()
Else
	if !lLiberado
		lRet := FS_VERDESC(.t.)
	Endif
Endif

FG_SEEK("SA1","VS1->VS1_CLIFAT+VS1->VS1_LOJA",1,.f.)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Gera_Titulo³ Autor ³ ANDRE                ³ Data ³ 20/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao que faz integracao com o Contas a Receber            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gera_Titulo()

Local cont
Local cTipTit
Local cNatureza
Local lRet     := .t. , nParcelas:=0
Local aTitulo  := {}
Local cTipCob  := if(!Empty(cCodBco),"1","0")
Local cNumBord := ""
Local dDatBord := cTod("")
Local cNumBord2:= ""
Local dDatBord2:= cTod("")
Local i:=0
Local nSelect  := 0

if SF4->F4_DUPLIC == "N"  // Nao gera duplicatas
	lTitulo := .f.
	Return( .t. )
Endif

If lAbortPrint
	If MsgYesNo(OemToAnsi(STR0229),OemToAnsi(STR0148))
		Help("  ",1,"M160PROABO")
		lRet := .f.
		lError := .T.
		DisarmTransaction()
		Break
	Else
		lAbortPrint := .f.
	EndIf
EndIf

if Empty(cCodBco)
	cCodBco := GetMv("MV_BCOCXA")
	if Type("cCodBco") <> "C"
		MsgInfo(STR0416 ,STR0148) //Parametro <MV_BCOCXA> nao esta preenchido # Atencao!
		lMsErroauto := .f.
		DisarmTransaction()
		Break
	Endif
Endif
FG_Seek("SA1","VS1->VS1_CLIFAT+VS1->VS1_LOJA",1,.f.)
FG_Seek("SA3","cCodVen",1,.f.)
FG_Seek("SA6","cCodBco",1,.f.)
if SA6->A6_BORD == "0"
	cNumBord := "BCO"+SA6->A6_COD
	dDatBord := dDataBase
Endif

// Quando nao Houver Entrada (Cria uma Entrada Simulada)
if (Len(aColsC) = 1) .and. (Empty(aColsC[1,1])) .and. (Empty(aIteParc[1,1]))
	aColsC[Len(aColsC),1] := "DP"
	aColsC[Len(aColsC),2] := OemToAnsi(STR0136) // DUPLICATA
	aColsC[Len(aColsC),3] := dDataBase
	aColsC[Len(aColsC),4] := nTotTit
Endif

nParcelas:=0
For i:=1 to len(aColsC)
	if !Empty(aColsC[1,1]) .and. !aColsC[i,Len(aColsC[i])]
		
		if !Empty(SA1->A1_TIPPER) .and. !Empty(cForPeri) .and. cForPeri == cTipPag
			cTipTit   :=   GETMV("MV_TIPPER")    // Tipo de titulo a ser gerado
			cNatureza := &(GETMV("MV_NATPER"))   // Codigo da natureza dos titulos a serem gerados
		Else
			cTipTit   := aColsC[i,1]
			cNatureza := SA1->A1_NATUREZ
		Endif
		
		If FG_POSVAR("VS9_NATURE","aHeaderC") > 0
			if !Empty(aColsC[i,FG_POSVAR("VS9_NATURE","aHeaderC")])
				cNatureza := aColsC[i,FG_POSVAR("VS9_NATURE","aHeaderC")]
			Endif
		Endif
		If Empty(cNatureza)
			cNatureza := VS1->VS1_NATURE
		Endif
		
		cCodBco2 := cCodBco
		cNumBord2:= ""
		dDatBord2:= cTod("")
		If FG_POSVAR("VS9_PORTAD","aHeaderC") > 0
			if !Empty(aColsC[i,FG_POSVAR("VS9_PORTAD","aHeaderC")])
				cCodBco2 := aColsC[i,FG_POSVAR("VS9_PORTAD","aHeaderC")]
			Endif
		EndIf
		FG_Seek("SA6","cCodBco2",1,.f.)
		if SA6->A6_BORD == "0"
			cNumBord2 := "BCO"+SA6->A6_COD
			dDatBord2 := dDataBase
		Endif
		
		nParcelas++
		if TamSx3("E1_PARCELA")[1] = 1
			cParcela := ConvPN2PC(nParcelas)
		Else
			cParcela := Soma1( strzero(nParcelas-1,TamSx3("E1_PARCELA")[1]) )
		Endif
		
		
		dbSelectArea("VSA")
		dbSetOrder(1)
		dbSeek(xFilial("VSA")+aColsC[1,FG_POSVAR("VS9_TIPPAG","aHeaderC")])
	    if VSA->VSA_FINANC == "1"
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+VSA->VSA_CODCLI+VSA->VSA_LOJA)
        Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+VS1->VS1_CLIFAT+VS1->VS1_LOJA)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Otavio - 25/06/2009 - FNC 00000014055                        ³
		//³ Somente alimenta com natureza caso a mesma esteja preenchida ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cNatureza)
			aTitulo := {{"E1_PREFIXO" ,cPrefNF     ,Nil},;
			{"E1_NUM"     ,cNota                   ,Nil},;
			{"E1_PARCELA" ,cParcela                ,Nil},;
			{"E1_TIPO"    ,cTipTit                 ,Nil},;
			{"E1_NATUREZ" ,cNatureza               ,Nil},;
			{"E1_SITUACA",cTipCob                  ,Nil},;
			{"E1_CLIENTE" ,SA1->A1_COD             ,Nil},;
			{"E1_LOJA"    ,SA1->A1_LOJA            ,Nil},;
			{"E1_EMISSAO" ,dDataBase               ,Nil},;
			{"E1_VENCTO"  ,aColsC[i,3]             ,Nil},;
			{"E1_VENCREA" ,DataValida(aColsC[i,3]) ,Nil},;
			{"E1_VALOR"   ,aColsC[i,4]             ,Nil},;
			{"E1_NUMBOR"  ,cNumBord2               ,Nil},;
			{"E1_DATABOR" ,dDatBord2               ,Nil},;
			{"E1_PORTADO" ,cCodBco2                ,Nil},;
			{"E1_PREFORI" ,cPrefixo                ,Nil},;
			{"E1_VEND1"  , SA3->A3_COD             ,nil},;
			{"E1_COMIS1" , SA3->A3_COMIS           ,nil},;
			{"E1_BASCOM1", aColsC[i,4]             ,nil},;
			{"E1_PEDIDO" , cNumPed                 ,nil},;
			{"E1_NUMNOTA", cNota                   ,nil},;
			{"E1_SERIE"  , cSerie                  ,nil},;
			{"E1_ORIGEM" , "MATA460"               	,nil} }
		Else
			aTitulo := {{"E1_PREFIXO" ,cPrefNF     ,Nil},;
			{"E1_NUM"     ,cNota                   ,Nil},;
			{"E1_PARCELA" ,cParcela                ,Nil},;
			{"E1_TIPO"    ,cTipTit                 ,Nil},;
			{"E1_SITUACA",cTipCob                  ,Nil},;
			{"E1_CLIENTE" ,SA1->A1_COD             ,Nil},;
			{"E1_LOJA"    ,SA1->A1_LOJA            ,Nil},;
			{"E1_EMISSAO" ,dDataBase               ,Nil},;
			{"E1_VENCTO"  ,aColsC[i,3]             ,Nil},;
			{"E1_VENCREA" ,DataValida(aColsC[i,3]) ,Nil},;
			{"E1_VALOR"   ,aColsC[i,4]             ,Nil},;
			{"E1_NUMBOR"  ,cNumBord2               ,Nil},;
			{"E1_DATABOR" ,dDatBord2               ,Nil},;
			{"E1_PORTADO" ,cCodBco2                ,Nil},;
			{"E1_PREFORI" ,cPrefixo                ,Nil},;
			{"E1_VEND1"  , SA3->A3_COD             ,nil},;
			{"E1_COMIS1" , SA3->A3_COMIS           ,nil},;
			{"E1_BASCOM1", aColsC[i,4]             ,nil},;
			{"E1_PEDIDO" , cNumPed                 ,nil},;
			{"E1_NUMNOTA", cNota                   ,nil},;
			{"E1_SERIE"  , cSerie                  ,nil},;
			{"E1_ORIGEM" , "MATA460"               	,nil} }
		EndIf
		
		
		dbSelectArea("VSB")
		dbSetOrder(1)
		if dbSeek(xFilial("VSB")+aColsC[i,1])
			while !EOF() .and. VSB->VSB_TIPPAG == aColsC[i,1]
				if VSB->VSB_TABDES == "SE1"
					dbSelectArea("VSE")
					if dbSeek(xFilial("VSE")+"OR"+M->VS1_NUMORC+"B"+aColsC[i,FG_POSVAR('VS9_TIPPAG',"aHeaderC")]+aColsC[i,FG_POSVAR('VS9_SEQUEN',"aHeaderC")])
						if !Empty(VSE->VSE_VALDIG) .and. !Empty(VSB->VSB_CAMDES)
							aAdd(aTitulo,{VSB->VSB_CAMDES, VSE->VSE_VALDIG, nil})
						Endif
					Endif
				Endif
				dbSelectArea("VSB")
				dbSkip()
			EndDo
		Endif
		
		lMSHelpAuto := .t.
		lMsErroAuto := .f.
		
		dbSelectArea("SX1")
		dbSetOrder(1)
		if dbSeek("FIN04003")
			nSelect := SX1->X1_PRESEL
			RecLock("SX1",.F.)
			SX1->X1_PRESEL := 2
			MsUnlock()
		Endif
		Pergunte("FIN040",.F.)
		
		aSalvaCols   := aClone(aCols)
		aSalvaHeader := aClone(aHeader)
		aCols        := NIL
		aHeader      := NIL

		_nRecSA1 := SA1->(Recno())
		
		MSExecAuto({|x| FINA040(x)},aTitulo)
		
		SA1->(Dbgoto(_nRecSA1))		
		
		aCols   := aClone(aSalvaCols)
		aHeader := aClone(aSalvaHeader)
		
		If lMsErroAuto
			lRet := .F.
			lError := .T.
            Help(" ",1,"ERROGERACR") // Erro na Geracao do contas a receber   //boby
			MostraErro()
			DisarmTransaction()
			Break
		EndIf
	Endif
Next

// Contas a Receber do Financiamento
If lAbortPrint
	If MsgYesNo(OemToAnsi(STR0229),OemToAnsi(STR0148))
		Help("  ",1,"M160PROABO")
		lRet := .f.
		lError := .T.
        Help(" ",1,"ERROGERACR") // Erro na Geracao do contas a receber   //boby
		MostraErro()
		DisarmTransaction()
		Break
	Else
		lAbortPrint := .f.
	EndIf
EndIf

nParcelas:=0

if Empty(cCodCDCI)
	For i:=1 to Len(aIteParc)
		if Empty(aIteParc[i,1]) .or. aIteParc[i,2] == 0
			Loop
		Endif
		
		nParcelas++
		
		dbSelectArea("VSA")
		dbSetOrder(1)
		dbSeek(xFilial("VSA")+aColsC[1,FG_POSVAR("VS9_TIPPAG","aHeaderC")])
	    if VSA->VSA_FINANC == "1"
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+VSA->VSA_CODCLI+VSA->VSA_LOJA)
        Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+VS1->VS1_CLIFAT+VS1->VS1_LOJA)
		Endif
		if !Empty(SA1->A1_TIPPER) .and. !Empty(cForPeri) .and. cForPeri == cTipPag
			cTipTit   :=   GETMV("MV_TIPPER")    // Tipo de titulo a ser gerado
			cNatureza := &(GETMV("MV_NATPER"))   // Codigo da natureza dos titulos a serem gerados
		Else
			cTipTit   := "DP "
			cNatureza := SA1->A1_NATUREZ
		Endif
		
		if !Empty(VS1->VS1_NATURE)
			cNatureza := VS1->VS1_NATURE
		Endif
		
		//		{"E1_PARCELA",ConvPn2PC(nParcelas)      ,Nil},;
		
		if TamSx3("E1_PARCELA")[1] = 1
			cParcela := ConvPN2PC(nParcelas)
		Else
			cParcela := Soma1( strzero(nParcelas-1,TamSx3("E1_PARCELA")[1]) )
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Otavio - 25/06/2009 - FNC 00000014055                        ³
		//³ Somente alimenta com natureza caso a mesma esteja preenchida ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(cNatureza)
			aTitulo := {{"E1_PREFIXO",cPrefNF       ,Nil},;
			{"E1_NUM"    ,cNota                     ,Nil},;
			{"E1_PARCELA",cParcela                  ,Nil},;
			{"E1_TIPO"	 ,cTipTit                   ,Nil},;
			{"E1_NATUREZ",cNatureza                 ,Nil},;
			{"E1_SITUACA",cTipCob                   ,Nil},;
			{"E1_CLIENTE",SA1->A1_COD               ,Nil},;
			{"E1_LOJA"	 ,SA1->A1_LOJA              ,Nil},;
			{"E1_EMISSAO",dDataBase                 ,Nil},;
			{"E1_VENCTO" ,aIteParc[i,1]            ,Nil},;
			{"E1_VENCREA",DataValida(aIteParc[i,1]),Nil},;
			{"E1_VALOR"  ,aIteParc[i,2]            ,Nil},;
			{"E1_NUMBOR" ,cNumBord                  ,Nil},;
			{"E1_DATABOR",dDatBord                  ,Nil},;
			{"E1_PORTADO",cCodBco                   ,Nil},;
			{"E1_PREFORI",cPrefixo                  ,Nil},;
			{"E1_VEND1"  , SA3->A3_COD            ,nil},;
			{"E1_COMIS1" , SA3->A3_COMIS          ,nil},;
			{"E1_BASCOM1", aIteParc[i,2]          ,nil},;
			{"E1_PEDIDO" , cNumPed                ,nil},;
			{"E1_NUMNOTA", cNota                  ,nil},;
			{"E1_SERIE"  , cSerie                 ,nil},;
			{"E1_ORIGEM" , "MATA460"               	,nil} }
		Else
			aTitulo := {{"E1_PREFIXO",cPrefNF       ,Nil},;
			{"E1_NUM"    ,cNota                     ,Nil},;
			{"E1_PARCELA",cParcela                  ,Nil},;
			{"E1_TIPO"	 ,cTipTit                   ,Nil},;
			{"E1_SITUACA",cTipCob                   ,Nil},;
			{"E1_CLIENTE",SA1->A1_COD               ,Nil},;
			{"E1_LOJA"	 ,SA1->A1_LOJA              ,Nil},;
			{"E1_EMISSAO",dDataBase                 ,Nil},;
			{"E1_VENCTO" ,aIteParc[i,1]            ,Nil},;
			{"E1_VENCREA",DataValida(aIteParc[i,1]),Nil},;
			{"E1_VALOR"  ,aIteParc[i,2]            ,Nil},;
			{"E1_NUMBOR" ,cNumBord                  ,Nil},;
			{"E1_DATABOR",dDatBord                  ,Nil},;
			{"E1_PORTADO",cCodBco                   ,Nil},;
			{"E1_PREFORI",cPrefixo                  ,Nil},;
			{"E1_VEND1"  , SA3->A3_COD            ,nil},;
			{"E1_COMIS1" , SA3->A3_COMIS          ,nil},;
			{"E1_BASCOM1", aIteParc[i,2]          ,nil},;
			{"E1_PEDIDO" , cNumPed                ,nil},;
			{"E1_NUMNOTA", cNota                  ,nil},;
			{"E1_SERIE"  , cSerie                 ,nil},;
			{"E1_ORIGEM" , "MATA460"               	,nil} }
		EndIf
		
		lMsHelpAuto := .f.
		lMsErroauto := .f.
		
		dbSelectArea("SX1")
		dbSetOrder(1)
		if dbSeek("FIN04003")
			if nSelect == 0
				nSelect := SX1->X1_PRESEL
			Endif
			RecLock("SX1",.F.)
			SX1->X1_PRESEL := 2
			MsUnlock()
		Endif
		Pergunte("FIN040",.F.)
		
		aSalvaCols   := aClone(aCols)
		aSalvaHeader := aClone(aHeader)
		aCols        := NIL
		aHeader      := NIL

		_nRecSA1 := SA1->(Recno())//salva posicao SA1
		
		MSExecAuto({|x| FINA040(x)},aTitulo)
		
		SA1->(Dbgoto(_nRecSA1))	//volta posicao SA1	
		
		aCols   := aClone(aSalvaCols)
		aHeader := aClone(aSalvaHeader)
		
		If lMsErroAuto
			lRet := .F.
			lError := .T.
            Help(" ",1,"ERROGERACR") // Erro na Geracao do contas a receber   //boby
			MostraErro()
			DisarmTransaction()
			Break
		EndIf
	Next
Endif

if nSelect <> 0
	dbSelectArea("SX1")
	dbSetOrder(1)
	if dbSeek("FIN04003")
		RecLock("SX1",.F.)
		SX1->X1_PRESEL := nSelect
		MsUnlock()
	Endif
Endif

If Alltrim(GetNewPar("MV_TITNCC","N")) == "S"
	if nTotCre > 0
		nSaldo := nTotCre
		For cont := 1 to Len(aTitCre)
			if aTitCre[cont,1]
				dbSelectArea("SE1")
				dbGoto(aTitCre[cont,6])
				nValor := aTitCre[cont,5]
				if nValor > nSaldo
					nValor := nSaldo
				Endif
				nSaldo := nTotCre - nValor
				
				aBaixa  := {{"E1_PREFIXO"  ,SE1->E1_PREFIXO ,Nil},;
				{"E1_NUM"	   ,SE1->E1_NUM                  ,Nil},;
				{"E1_PARCELA"  ,SE1->E1_PARCELA              ,Nil},;
				{"E1_TIPO"	   ,"NCC"                        ,Nil},;
				{"AUTMOTBX"	   ,"NOR"                        ,Nil},;
				{"AUTDTBAIXA"  ,dDataBase                    ,Nil},;
				{"AUTDTCREDITO",dDataBase                    ,Nil},;
				{"AUTHIST"	   ,STR0230                      ,Nil},;
				{"AUTVALREC"   ,nValor                       ,Nil }}
				
				lMSHelpAuto := .f.
				lMsErroAuto := .f.
				MSExecAuto({|x| FINA070(x)},aBaixa)
				If lMsErroAuto
					lRet := .F.
					lError := .T.
		            Help(" ",1,"ERROGERACR") // Erro na Geracao do contas a receber    //boby
					MostraErro()
					DisarmTransaction()
					Break
				EndIf
			Endif
		Next
	Endif
EndIf

If ExistBlock("OM110TIT")
	ExecBlock("OM110TIT",.f.,.f.)
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Baixa_Titulo³ Autor ³ ANDRE                ³ Data ³ 20/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao que faz a Baixa de Titulos a Vista (Integracao)       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Baixa_Titulo()

Local lRet := .t.
Local i:=0

if SF4->F4_DUPLIC == "N"  // Nao gera duplicatas
	lTitulo := .f.
	Return( .t. )
Endif

If lAbortPrint
	If MsgYesNo(OemToAnsi(STR0229),OemToAnsi(STR0148))
		Help("  ",1,"M160PROABO")
		lRet := .f.
		lError := .T.
		DisarmTransaction()
		Break
	Else
		lAbortPrint := .f.
	EndIf
EndIf

//Parametro p/ ver se baixa automatico
if GETMV("MV_BXPEC") == "N"
	Return(lRet)
Endif

//Entrada
For i:=1 to Len(aColsC)
	if !Empty(aColsC[1,1]) .and. !aColsC[i,Len(aColsC[i])]
		//			{"E1_PARCELA" ,ConvPn2PC(i)       ,Nil},;
		
		if TamSx3("E1_PARCELA")[1] = 1
			cParcela := ConvPN2PC(i)
		Else
			cParcela := Soma1( strzero(i-1,TamSx3("E1_PARCELA")[1]) )
		Endif
		
		if DTOS(aColsC[i,3]) == DTOS(dDataBase)   // Se for a Vista <Baixa>
			aBaixa  := {{"E1_PREFIXO"  ,cPrefNF+space(TamSx3("E1_PREFIXO")[1]-Len(cPrefNF)),Nil},;
			{"E1_NUM"	  ,cNota               ,Nil},;
			{"E1_PARCELA" ,cParcela            ,Nil},;
			{"E1_TIPO"	  ,aColsC[i,1]         ,Nil},;
			{"AUTMOTBX"	  ,"NOR"               ,Nil},;
			{"AUTDTBAIXA"  ,dDataBase          ,Nil},;
			{"AUTDTCREDITO",dDataBase          ,Nil},;
			{"AUTHIST"	  ,STR0230			     ,Nil},;
			{"AUTVALREC"   ,aColsC[i,4]       ,Nil }}
			
			lMSHelpAuto := .f.
			lMsErroAuto := .f.
			MSExecAuto({|x| FINA070(x)},aBaixa)
			If lMsErroAuto
				lRet := .F.
				lError := .T.
				DisarmTransaction()
				Break
			EndIf
		Endif
	Endif
Next

//Financiamento
For i:=1 to Len(aIteParc)
	if Empty(aIteParc[i,1]) .or. aIteParc[i,2] == 0
		Loop
	Endif
	//		{"E1_PARCELA"  ,ConvPn2PC(i)        ,Nil},;
	
	if TamSx3("E1_PARCELA")[1] = 1
		cParcela := ConvPN2PC(i)
	Else
		cParcela := Soma1( strzero(i-1,TamSx3("E1_PARCELA")[1]) )
	Endif
	
	if DTOS(aIteParc[i,1]) == DTOS(dDataBase)   // Se for a Vista Baixa
		aBaixa  := {{"E1_PREFIXO"  ,cPrefNF+space(TamSx3("E1_PREFIXO")[1]-Len(cPrefNF)) ,Nil},;
		{"E1_NUM"	   ,cNota                ,Nil},;
		{"E1_PARCELA" ,cParcela              ,Nil},;
		{"E1_TIPO"	   ,"DP "                ,Nil},;
		{"AUTMOTBX"	   ,"NOR"                ,Nil},;
		{"AUTDTBAIXA"  ,dDataBase            ,Nil},;
		{"AUTDTCREDITO",dDataBase            ,Nil},;
		{"AUTHIST"	   ,STR0230			       ,Nil},;
		{"AUTVALREC"   ,aIteParc[i,2]       ,Nil }}
		
		lMSHelpAuto := .f.
		lMsErroAuto := .f.
		MSExecAuto({|x| FINA070(x)},aBaixa)
		If lMsErroAuto
			lRet := .F.
			lError := .T.
			DisarmTransaction()
			Break
		EndIf
	Endif
Next

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Gera_Pedido³ Autor ³ ANDRE                ³ Data ³ 20/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao que Gera o Pedido de Venda (Integracao)              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Gera_Pedido()

Local	nPrUnit, nPrVend, cLocal, cLocaliz
Local lRet    := .t.

Local cNumIte := "00"
Local x_:=0

Private cCliPad := ""
Private cLojPad := ""

Private cLoc  := 0

if ExistBlock("INTPEDBAL")
	if !ExecBlock("INTPEDBAL",.f.,.f.)
		Return(.f.)
	Endif
Endif

if lVAMCid
	FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
	cEstado := VAM->VAM_ESTADO
Else
	cEstado := SA1->A1_EST
Endif

//if SA1->A1_PESSOA == "J" .and. !Empty(SA1->A1_INSCR) .and. cEstado <> GETMV("MV_ESTADO")
//   cCliPad := ""
//   cLojPad := ""
//Else
//   cCliPad := GetMv("MV_CLIPAD")
//   cLojPad := GetMv("MV_LOJAPAD")
//Endif

If lAbortPrint
	If MsgYesNo(OemToAnsi(STR0229),OemToAnsi(STR0148))
		Help("  ",1,"M160PROABO")
		lRet := .f.
		lError := .T.
		DisarmTransaction()
		Break
	Else
		lAbortPrint := .f.
	EndIf
EndIf

aCabPV  := {}
aItePV  := {}

/*
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SC5")
While !Eof().and.(x3_arquivo=="SC5")
wVar := "M->"+x3_campo
&wVar:= CriaVar(x3_campo)
dbSkip()
EndDo
cNumPed := M->C5_NUM
*/

dbSelectArea("SA1")
dbSetOrder(1)
dbSeek(xFilial("SA1")+VS1->VS1_CLIFAT+VS1->VS1_LOJA)

//Cabecalho
//aadd(aCabPV,{"C5_NUM"    ,cNumPed         ,Nil}) // Numero do pedido
aadd(aCabPV,{"C5_TIPO"   ,"N"             ,Nil}) // Tipo de pedido
aadd(aCabPV,{"C5_CLIENTE",VS1->VS1_CLIFAT ,Nil}) // Codigo do cliente
aadd(aCabPV,{"C5_LOJACLI",VS1->VS1_LOJA   ,Nil}) // Loja do cliente
//if !Empty(cCliPad)
//   aadd(aCabPV,{"C5_CLIENT" ,cCliPad      ,Nil}) // Cliente Padrao
//   aadd(aCabPV,{"C5_LOJAENT",cLojPad      ,Nil}) // Loja para entrada
//Endif
aadd(aCabPV,{"C5_EMISSAO",dDataBase       ,Nil}) // Data de emissao
//aadd(aCabPV,{"C5_TABELA" ,'1'            ,Nil}) // Tabela de preco de venda
aadd(aCabPV,{"C5_CONDPAG",RetCondVei()    ,Nil}) // Codigo da condicao de pagamanto
aadd(aCabPV,{"C5_DESC1"  ,0               ,Nil}) // Percentual do Desconto Geral
aadd(aCabPV,{"C5_INCISS" ,"S"             ,Nil}) // ISS Incluso
aadd(aCabPV,{"C5_TIPLIB" ,"2"             ,Nil}) // Tipo de liberacao
aadd(aCabPV,{"C5_MOEDA"  ,1               ,Nil}) // Moeda
aadd(aCabPV,{"C5_LIBEROK","S"             ,Nil}) // Liberacao Total
aadd(aCabPV,{"C5_VEND1"  ,cCodVen         ,Nil}) // Codigo do vendedor
aadd(aCabPV,{"C5_TIPOCLI",SA1->A1_TIPO    ,Nil}) // Tipo do Cliente
aadd(aCabPV,{"C5_BANCO"  ,VS1->VS1_CODBCO ,Nil}) // Tipo do Cliente
aadd(aCabPV,{"C5_COMIS1" ,0               ,Nil}) // Percentual de Comissao
aadd(aCabPV,{"C5_DESPESA",VS1->VS1_DESACE ,Nil}) // Despesas na Venda a Integrar na NF
aadd(aCabPV,{"C5_FRETE"  ,VS1->VS1_VALFRE ,Nil}) // Despesas na Venda a Integrar na NF
aadd(aCabPV,{"C5_SEGURO" ,VS1->VS1_VALSEG ,Nil}) // Despesas na Venda a Integrar na NF


For x_:=1 to Len(aCabPV)
	Private &("M->"+aCabPV[x_,1]) := aCabPV[x_,2]
Next

aProdutos := {}

dbSelectArea("VS3")
dbSetOrder(1)
dbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
While VS3->VS3_FILIAL == xFilial("VS3") .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC .and. VS3->(!eof())
	
	//Pega a classificacao fiscal de acordo com o estado do cliente
	cCFiscal := FG_CLAFIS(VS3->VS3_CODTES)
	
	//	cNumIte := StrZero(++ncont,2)
	cNumIte := SOMA1(cNumIte)
	
	SB1->(dbSetOrder(7))
	SB1->(dbSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
	SB5->(dbSetOrder(1))
	SB5->(dbSeek(xFilial("SB5")+SB1->B1_COD))
	SB2->(dbSetOrder(1))
	SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD))
	SF4->(dbSetOrder(1))
	SF4->(dbSeek(xFilial("SF4")+VS3->VS3_CODTES))
	If M->VS1_ORCACE$"1 "
		cLoc := LocIte110(.f.)
	Else
		cLoc := GetMv("MV_RESITE")
	Endif
	FG_Seek("SBF","SB1->B1_COD+cLoc",2,.f.)
	// antes de dar problema de integracao, eu faco a verificacao e comunico ao usuario.
	// esse problema ocorrera quando o orcamento estiver aceito e nao existir qtde distribuida
	// para esse produto (no caso de existir localizacao)
	cLoc := SBF->BF_LOCALIZ
	
	If empty(cLoc) .and. localiza(SB1->B1_COD)
		MsgStop(OemToAnsi(STR0417)+SB1->B1_COD+OemToAnsi(" "+ STR0418 +": ")+GetMv("MV_RESITE")) //Nao existe saldo distribuido para o produto:  # no armazem
		lError := .T.
		lRet := .T.
		DisarmTransaction()
		Break
	Endif
	
	nPrUnit  := Round(VS3->VS3_VALPEC-(VS3->VS3_VALDES/VS3->VS3_QTDITE),2)
	nPrVend  := Round((VS3->VS3_VALPEC*VS3->VS3_QTDITE)-VS3->VS3_VALDES,2)
	cLocal   := if(M->VS1_ORCACE$"1 ",LocIte110(.f.),GetMv("MV_RESITE"))
	cLocaliz := if(localiza(SB1->B1_COD),cLoc,SPACE(15))
	
	//	If !(cPaisLoc == "BRA") // Manoel - 07/05/2009
	//		cCFiscal := SF4->F4_CF
	//	Endif
	
	//   aadd(aItePV,{{"C6_NUM"    , cNumPed         , Nil},; // Numero do Pedido
	//                {"C6_ITEM"   , cNumIte         , Nil},; // Numero do Item no Pedido
	
	aadd(aItePV,{{"C6_ITEM"   , cNumIte         , Nil},; // Numero do Item no Pedido
	{"C6_SEQUEN" , cNumIte         , Nil},; // Numero do Item no Pedido
	{"C6_PRODUTO", SB1->B1_COD     , Nil},; // Codigo do Produto
	{"C6_QTDVEN" , VS3->VS3_QTDITE , Nil},; // Quantidade Vendida
	{"C6_PRUNIT" , nPrUnit         , Nil},; // Preco Unitario do Produto
	{"C6_PRCVEN" , nPrUnit         , Nil},; // Preco Unitario Liquido
	{"C6_VALOR"  , nPrVend         , Nil},; // Valor Total do Item
	{"C6_ENTREG" , dDataBase       , Nil},; // Data da Entrega
	{"C6_UM"     , SB1->B1_UM  	   , Nil},; // Unidade de Medida Primar.
	{"C6_TES"    , VS3->VS3_CODTES , Nil},; // Tipo de Saida do Item
	{"C6_LOCAL"  , cLocal          , Nil},; // Almoxarifado
	{"C6_VALDESC", 0               , Nil},; // Valor do Desconto
	{"C6_COMIS1" , 0               , Nil},; // Comissao Vendedor
	{"C6_CF"     , cCFiscal        , Nil},; // CFO
	{"C6_DESCRI" , SB1->B1_DESC    , Nil},; // Descricao do Produto
	{"C6_CLI"    , SA1->A1_COD     , Nil},; // Cliente
	{"C6_LOJA"   , SA1->A1_LOJA    , Nil},; // Loja do Cliente
	{"C6_QTDEMP" , VS3->VS3_QTDITE , Nil}}) // Quantidade Empenhada
	if !Empty(cLocaliz) .or. localiza(SB1->B1_COD)
		aadd(aItePV[Len(aItePV)],{"C6_LOCALIZ", cLocaliz        , Nil})
	Endif
	VS3->(dbSkip())
Enddo

if M->VS1_DESACE > 0
	FS_OUTDESP(1)
Endif
if M->VS1_VALFRE > 0
	FS_OUTDESP(2)
Endif
if M->VS1_VALSEG > 0
	FS_OUTDESP(3)
Endif

if ExistBlock("INTPED110")
	ExecBlock("INTPED110",.f.,.f.,{@aCabPv,@aItePv})
Endif

FG_X3ORD("C",,aCabPv)
FG_X3ORD("I",,aItePv)

lInclui     := inclui
inclui      := .t.
lMsHelpAuto := .t.
lMsErroAuto := .f.
MsExecAuto({|x,y,z| mata410(x,y,z)},aCabPv,aItePv,3)
Inclui     := lInclui
If lMsErroAuto
	lRet   := .f.
	lError := .t.
	DisarmTransaction()
	Break
EndIf

cNumPed := SC5->C5_NUM
RecLock("VS1",.f.)
VS1->VS1_NUMPED := cNumPed
MsUnlock()

If !lMsErroAuto
	if ExistBlock("INTBAL01")
		ExecBlock("INTBAL01",.f.,.f.)
		if lMsErroAuto
			lRet   := .f.
			lError := .t.
			DisarmTransaction()
			Break
		Endif
	Endif
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Nota_Fiscal³ Autor ³ ANDRE                ³ Data ³ 20/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao que faz a NF de Venda (Integracao)                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Nota_Fiscal()

Local lRet     := .t.
Local nIteLib  := 0
Local aPvlNfs  := {}

If lAbortPrint
	If MsgYesNo(OemToAnsi(STR0229),OemToAnsi(STR0148))
		Help("  ",1,"M160PROABO")
		lRet := .f.
		lError := .T.
		DisarmTransaction()
		Break
	Else
		lAbortPrint := .f.
	EndIf
EndIf

dbSelectArea("SC9")
cChavSC9 := cNumPed+"01"
FG_Seek("SC9","cChavSC9")

/*
if GetMv("MV_LOCALIZ") == "N"
While SC9->C9_FILIAL+SC9->C9_PEDIDO == xFilial("SC9")+cNumPed .and. !Eof()
// Parametros nOpc: 1 - Libera
//                  2 - Rejeita
//           lAtuCred : Indica se Libera Credito
//           lAtuEst  : Indica se Libera Estoque
a450Grava(1,.T.,.T.)
dbSkip()
EndDo
Else
aRegs := {}
While SC9->C9_FILIAL+SC9->C9_PEDIDO == xFilial("SC9")+cNumPed .and. !Eof()
aAdd(aRegs,{SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+SC9->C9_PRODUTO})
dbSkip()
EndDo
dbSelectArea("SC9")
dbSetOrder(1)
For i_ := 1 to Len(aRegs)
if dbSeek(xFilial("SC9")+aRegs[i_,1])
a450Grava(1,.T.,.T.)
Endif
dbSelectArea("SC9")
Next
Endif
*/

lCredito := .t.
lEstoque := .t.
lLiber   := .t.
lTransf  := .f.

dbSelectArea("SC9")
dbSetOrder(1)

dbSelectArea("SC6")
dbSetOrder(1)
dbSeek(xFilial("SC6")+cNumPed+"01")
While !eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPed
	dbSelectArea("SC9")
	if !dbSeek(xFilial("SC9")+cNumPed+SC6->C6_ITEM)
		nQtdLib := SC6->C6_QTDVEN
		nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf)
	Endif
	dbSelectArea("SC6")
	dbSkip()
Enddo

dbSelectArea("SC9")
dbSeek(xFilial("SC9")+cNumPed+"01")
While !Eof() .and. xFilial("SC9")==SC9->C9_FILIAL .and. SC9->C9_PEDIDO == cNumPed
	
	If Empty(SC9->C9_BLCRED) .and. Empty(SC9->C9_BLEST)
		
		FG_Seek("SB1","SC9->C9_PRODUTO",1)
		FG_Seek("VS3","VS1->VS1_NUMORC+SB1->B1_GRUPO+SB1->B1_CODITE",2,.f.)
		FG_Seek("SC5","SC9->C9_PEDIDO",1,.F.)
		FG_Seek("SC6","SC9->C9_PEDIDO+SC9->C9_ITEM",1)
		FG_Seek("SB5","SB1->B1_COD")
		FG_Seek("SB2","SB1->B1_COD")
		FG_Seek("SF4","VS3->VS3_CODTES")
		FG_Seek("SE4","VS1->VS1_FORPAG",1)  //Tem que ser Tipo A para nao criar E1 automatico
		
		aAdd(aPvlNfs,{C9_PEDIDO,;
		C9_ITEM,;
		C9_SEQUEN,;
		C9_QTDLIB,;
		C9_PRCVEN,;
		C9_PRODUTO,;
		SF4->F4_ISS=="S",;
		SC9->(RecNo()),;
		SC5->(RecNo()),;
		SC6->(RecNo()),;
		SE4->(RecNo()),;
		SB1->(RecNo()),;
		SB2->(RecNo()),;
		SF4->(RecNo())})
		nIteLib++
	Else
		MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPv,aItePv,5)
	EndIf
	dbSelectArea("SC9")
	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera F2/D2, Atualiza Estoque, Financeiro, Contabilidade             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if nIteLib > 0
	PERGUNTE("MT460A",.f.)
	cNota := MaPvlNfs(aPvlNfs,iif(nCheck==1,cSerie,SuperGetMv("MV_SERCUP")), (mv_par01 == 1), (mv_par02 == 1), (mv_par03 == 1), (mv_par04 == 1), .F., 0, 0, .T., iif(nCheck==1,.F.,.T.))
	
	if Empty(cNota) .and. SF2->F2_SERIE == iif(nCheck==1,cSerie,SuperGetMv("MV_SERCUP"))
		cNota := SF2->F2_DOC
	Endif
	cNota := LEFT(cNota+sPACE(15),TamSx3("F2_DOC")[1])
	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	if SC5->(dbSeek(xFilial("SC5")+cNumPed))
		RecLock("SC5",.f.)
		SC5->C5_CONDPAG := cTipPag
		MsUnlock()
	Endif
	
	dbSelectArea("SF2")
	RecLock("SF2",.f.)
	SF2->F2_COND   := M->VS1_FORPAG
	SF2->F2_SERIE  := cSerie
	SF2->F2_PREFORI:= cPrefixo
	if lTitulo
		SF2->F2_DUPL   := cNota
		SF2->F2_VALFAT := nTotOrc
	Endif
	SF2->F2_DESCONT:= nTotDes
	
	&& Grava a observacao da nota fiscal
	If ( Type("cObsNF") # "U" .And. SF2->(FieldPos("F2_OBSMEM")) # 0 )
		aMemos  := {{"F2_OBSMEM","cObsNF"}}
		MSMM(,TamSx3("F2_OBSERV")[1],,&(aMemos[1][2]),1,,,"SF2","F2_OBSMEM")
	EndIf
	MsUnlock()
	
	cPrefNF := iif(nCheck==1,&(GetNewPar("MV_1DUPREF","cSerie")),SuperGetMv("MV_SERCUP"))
	
	dbSelectArea("SF2")
	RecLock("SF2",.f.)
	SF2->F2_PREFIXO:= cPrefNF
	MsUnlock()
	
	
	//Atualiza os descontos nos itens no campo respectivo
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSelectarea("VS3")
	dbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
	While !EOF() .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC
		dbSelectArea("SB1")
		dbSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE)
		dbSelectArea("SD2")
		if dbSeek(xFilial("SD2")+cNota+cSerie+VS1->VS1_CLIFAT+VS1->VS1_LOJA+SB1->B1_COD+Soma1(STRZERO(VAL(VS3->VS3_SEQUEN)-1,2),2) )
			RecLock("SD2",.f.)
			SD2->D2_DESC   := VS3->VS3_PERDES
			SD2->D2_DESCON := VS3->VS3_VALDES
			MsUnlock()
		Endif
		dbSelectarea("VS3")
		dbSkip()
	Enddo
	
	dbSelectArea("VS1")
	RecLock("VS1",.f.)
	VS1->VS1_NUMNFI := cNota
	VS1->VS1_SERNFI := cSerie
	MsUnlock()
Else
	lRet   := .f.
	lError := .t.
	DisarmTransaction()
	Break
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GrAvaliacao³ Autor ³ ANDRE                ³ Data ³ 20/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao que Grava a Avaliacao de Resultado                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GrAvaliacao()

Local lRet := .t.
Local _x :=0

If lAbortPrint
	If MsgYesNo(OemToAnsi(STR0229),OemToAnsi(STR0148))
		Help("  ",1,"M160PROABO")
		lRet := .f.
		lError := .T.
		DisarmTransaction()
		Break
	Else
		lAbortPrint := .f.
	EndIf
EndIf

For _x :=1 to Len(aColsP)
	
	if aColsP[_x,Len(aColsP[_x])]
		Loop
	Endif
	
	if Empty(aColsP[_x,FG_POSVAR("VS3_GRUITE","aHeaderP")]) .or. Empty(aColsP[_x,FG_POSVAR("VS3_CODITE","aHeaderP")])
		Loop
	Endif
	
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+aColsP[_x,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[_x,FG_POSVAR("VS3_CODITE","aHeaderP")])
	dbSelectArea("SB2")
	dbSeek(xFilial("SB2")+SB1->B1_COD+LocIte110(.f.,aColsP,_x))
	DbSelectarea("SF4")
	SF4->(dbSeek(xFilial("SF4")+aColsP[_X,FG_POSVAR("VS3_CODTES","aHeaderP")]))
	//Por motivo do ISS tem que posicionar no Item da Nota
	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(xFilial("SD2")+VS1->VS1_NUMNFI+VS1->VS1_SERNFI+VS1->VS1_CLIFAT+VS1->VS1_LOJA+SB1->B1_COD)
	
	dbSelectArea("VEC")
	RecLock("VEC",.t.)
	
	VEC_FILIAL := xFilial("VEC")
	VEC_NUMREL := GetSXENum("VEC","VEC_NUMREL")
	ConfirmSx8()
	VEC_NUMIDE := GetSXENum("VEC","VEC_NUMIDE")
	ConfirmSx8()
	VEC_NUMORC := VS1->VS1_NUMORC
	VEC_GRUITE := aColsP[_x,FG_POSVAR("VS3_GRUITE","aHeaderP")]
	VEC_CODITE := aColsP[_x,FG_POSVAR("VS3_CODITE","aHeaderP")]
	VEC_VALDES := aColsP[_x,FG_POSVAR("VS3_VALDES","aHeaderP")]
	VEC_QTDITE := aColsP[_x,FG_POSVAR("VS3_QTDITE","aHeaderP")]
	
	// Manoel - 07/04/2009  -  Acerto para gravacao correta dos arquivos
	If SF4->F4_CREDICM == "S"
		If VEC->VEC_VALICM != SD2->D2_VALICM
			VEC->VEC_VALICM := SD2->D2_VALICM
			VEC->VEC_ALQICM := SD2->D2_PICM
		EndIf
	Else
		VEC->VEC_VALICM := 0
		VEC->VEC_ALQICM := 0
	Endif
	//	VEC_ALQICM := aColsP[_x,FG_POSVAR("VS3_ALIICM","aHeaderP")]
	//	VEC_VALICM := aColsP[_x,FG_POSVAR("VS3_ICMCAL","aHeaderP")]
	
	//Valor do ISS quando Outras Operacoes
	VEC_ALQISS := SD2->D2_ALIQISS
	VEC_VALISS := SD2->D2_VALISS
	
	aPisCof := CalcPisCofSai(VEC->VEC_VALVDA)
	
	VEC_CODMAR := M->VS1_CODMAR
	VEC_PECINT := SB1->B1_COD
	
	// Manoel - 07/04/2009  -  Acerto para gravacao correta dos arquivos
	if SF4->F4_PISCRED = "2" // tributada
		if SF4->F4_PISCOF $ "1/3"  //PIS
			VEC->VEC_VALPIS := SD2->D2_VALIMP6 //round(VEC->VEC_VALVDA * 0.0165,2)
		endif
		if SF4->F4_PISCOF $ "2/3"  //COFINS
			VEC->VEC_VALCOF := SD2->D2_VALIMP5 //round(VEC->VEC_VALVDA * 0.076,2)
		endif
		if SF4->F4_PISCOF = "4"
			VEC->VEC_VALPIS := 0
			VEC->VEC_VALCOF := 0
		endif
	elseif SF4->F4_PISCRED # "2"  //isenta
		VEC->VEC_VALPIS := 0
		VEC->VEC_VALCOF := 0
	endif
	//	VEC_VALCOF := aPisCof[1,2] //(VEC_VALVDA * nAliCOF)
	//	VEC_VALPIS := aPisCof[1,1] //(VEC_VALVDA * nAliPIS)
	
	// Manoel - 07/04/2009  -  Acerto para gravacao correta dos arquivos
	VEC->VEC_TOTIMP := VEC->VEC_VALICM + VEC->VEC_VALCOF + VEC->VEC_VALPIS
	VEC->VEC_DESVAR := VEC->VEC_COMVEN + VEC->VEC_COMGER
	
	// Manoel - 07/04/2009  -  Acerto para gravacao correta dos arquivos
	If VEC->VEC_CUSMED != SD2->D2_CUSTO1
		VEC->VEC_CUSMED := SD2->D2_CUSTO1
	EndIf
	If VEC->VEC_VALFRE != SD2->D2_VALFRE
		VEC->VEC_VALFRE := SD2->D2_VALFRE
	Endif
	If VEC->VEC_VALSEG != SD2->D2_SEGURO
		VEC->VEC_VALSEG := SD2->D2_SEGURO
	Endif
	if VEC->(FieldPos("VEC_DESACE"))#0
		If VEC->VEC_DESACE != SD2->D2_DESPESA
			VEC->VEC_DESACE := SD2->D2_DESPESA
		Endif
	Endif
	if VEC->(FieldPos("VEC_ICMSRT"))#0
		If VEC->VEC_ICMSRT != SD2->D2_ICMSRET
			VEC->VEC_ICMSRT := SD2->D2_ICMSRET
		Endif
	Endif
	if VEC->(FieldPos("VEC_VALIPI"))#0
		if VEC->VEC_VALIPI != SD2->D2_VALIPI
			VEC->VEC_VALIPI := SD2->D2_VALIPI
		Endif
	Endif
	//	VEC_CUSMED := Round(NoRound(SB2->B2_CM1 * aColsP[_x,FG_POSVAR("VS3_QTDITE","aHeaderP")],3),2)
	// VEC_VALFRE := M->VS1_VALFRE/Len(aColsP)  //Frete
	// VEC_VALSEG := M->VS1_VALSEG/Len(aColsP)  //Seguro
	
	// Manoel - 07/04/2009  -  Acerto para gravacao correta dos arquivos
	VEC->VEC_JUREST := 0
	//	VEC_JUREST := FG_JUREST(VS1->VS1_NUMORC,SB1->B1_COD,SB1->B1_UCOM,VS1->VS1_DATORC,"P")
	VEC->VEC_CUSTOT := VEC->VEC_CUSMED + VEC->VEC_JUREST
	
	// Manoel - 07/04/2009  -  Acerto para gravacao correta dos arquivos
	VEC->VEC_VALBRU := SD2->D2_TOTAL + SD2->D2_VALFRE + SD2->D2_SEGURO + SD2->D2_DESPESA + SD2->D2_VALIPI + SD2->D2_ICMSRET + VEC->VEC_VALDES
	VEC->VEC_VALVDA := SD2->D2_TOTAL
	//	VEC_VALVDA := aColsP[_x,FG_POSVAR("VS3_VALTOT","aHeaderP")]
	//	VEC_VALBRU := aColsP[_x,FG_POSVAR("VS3_VALTOT","aHeaderP")] + aColsP[_x,FG_POSVAR("VS3_VALDES","aHeaderP")]
	
	
	// Manoel - 07/04/2009  -  Acerto para gravacao correta dos arquivos
	VEC->VEC_LUCBRU := (VEC->VEC_VALBRU-VEC->VEC_VALDES) - VEC->VEC_TOTIMP - VEC->VEC_CUSMED - iif(VEC->(FieldPos("VEC_ICMSRT"))#0,VEC->VEC_ICMSRT,0) + iif(VEC->(FieldPos("VEC_ICMSST"))#0,VEC->VEC_ICMSST,0) + iif(VEC->(FieldPos("VEC_DCLBST"))#0,VEC->VEC_DCLBST,0) + iif(VEC->(FieldPos("VEC_COPIST"))#0,VEC->VEC_COPIST,0)
	VEC->VEC_LUCLIQ := VEC->VEC_LUCBRU - VEC->VEC_JUREST - VEC->VEC_DESVAR - VEC->VEC_DESDEP - VEC->VEC_DESADM - VEC->VEC_DESFIX  //LUCRO MARGINAL
	VEC->VEC_RESFIN := VEC->VEC_LUCLIQ - VEC->VEC_CUSFIX  //LAIR
	//	VEC_LUCBRU := VEC_VALVDA - VEC_TOTIMP - VEC_CUSMED
	//	VEC_LUCLIQ := VEC_LUCBRU - VEC_JUREST - VEC_DESVAR - VEC_DESDEP - VEC_DESADM - VEC_DESFIX
	// VEC_RESFIN := VEC_LUCLIQ - VEC_CUSFIX
	
	VEC_DATVEN := dDataBase
	
	//Comissao
	if cOpeMov2 <> "2"
		aValCom    := FG_COMISS("P",cCodVen,VEC_DATVEN,VEC_GRUITE,VEC_VALVDA,"T",VEC_NUMIDE)
		VEC_COMVEN := aValCom[1]
		VEC_COMGER := aValCom[2]
	Else
		VEC_COMVEN := 0
		VEC_COMGER := 0
	Endif
	
	VEC_DESVAR := VEC_COMVEN + VEC_COMGER
	VEC_DESFIX := 0
	VEC_CUSFIX := 0
	VEC_DESDEP := M->VS1_DESACE/Len(aColsP)
	VEC_DESADM := 0
	VEC_RESFIN := 0
	VEC_BALOFI := "B" //Balcao
	VEC_DEPVEN := ""
	VEC_TIPTEM := ""  //Gravar qdo Ordem de Servico
	VEC_NUMOSV := ""  //Gravar qdo Ordem de Servico
	VEC_NUMNFI := cNota
	VEC_SERNFI := cSerie
	
	nRazIte    := VEC_VALBRU / (nTotOrc)
	
	VEC_VMFBRU := FG_CALCMF(FG_RETVDCP(cNota,cPrefNF,"S",nTotOrc)) * nRazIte
	VEC_VMFVDA := VEC_VMFBRU - FG_CALCMF( {{dDataBase,VEC_VALDES}} )
	VEC_VMFICM := FG_CALCMF( { {FG_RTDTIMP("ICM",dDataBase),VEC_VALICM} })
	VEC_VMFPIS := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VEC_VALPIS} })
	VEC_VMFCOF := FG_CALCMF( { {FG_RTDTIMP("COF",dDataBase),VEC_VALCOF} })
	VEC_TMFIMP := VEC_VMFICM + VEC_VMFCOF + VEC_VMFPIS
	
	VEC_CMFMED := FG_CALCMF( { {dDataBase,SB2->B2_CM1} }) * VEC_QTDITE
	VEC_JMFEST := FG_CALCMF( { {dDataBase,VEC_JUREST} })
	VEC_CMFTOT := VEC_CMFMED + VEC_JMFEST
	VEC_LMFBRU := VEC_VMFVDA - VEC_TMFIMP - VEC_CMFTOT
	
	VEC_VMFISS := FG_CALCMF( { {dDataBase,SD2->D2_VALISS} })
	
	if cOpeMov2 <> "2"
		aValCom    := FG_COMISS("P",cCodVen,VEC_DATVEN,VEC_GRUITE,VEC_VALVDA,"D")
		VEC_CMFVEN := FG_CALCMF(aValCom[1])
		VEC_CMFGER := FG_CALCMF(aValCom[2])
	Else
		VEC_CMFVEN := 0
		VEC_CMFGER := 0
	Endif
	
	VEC_VMFFRE := M->VS1_VALFRE/Len(aColsP)  //Frete Moeda Forte
	VEC_VMFSEG := M->VS1_VALSEG/Len(aColsP)  //Seguro Moeda Forte
	
	VEC_DMFVAR := VEC_CMFVEN + VEC_CMFGER
	VEC_LMFLIQ := VEC_LMFBRU - VEC_DMFVAR
	VEC_DMFFIX := 0
	VEC_CMFFIX := 0
	VEC_CMFDEP := 0
	VEC_DMFADM := 0
	VEC_RMFFIN := VEC_LMFLIQ - VEC_DMFFIX - VEC_CMFFIX - VEC_DMFDEP - VEC_DMFADM
	
	MsUnlock()
	
	dbSelectArea("VEC")
	
Next

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GravEntrada| Autor ³ ANDRE                ³ Data ³ 20/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao que faz a Gravacao dos Pagamentos da Entrada         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GravEntrada()

Local lRet := .t.

// Gravacao dos Dados dos Tipos de Pagamentos digitados na Entrada
If lAbortPrint
	If MsgYesNo(OemToAnsi(STR0229),OemToAnsi(STR0148))
		Help("  ",1,"M160PROABO")
		lRet := .f.
		lError := .T.
		DisarmTransaction()
		Break
	Else
		lAbortPrint := .f.
	EndIf
EndIf

if !lSalvou
	FS_SALVAR()
	lSalvou := .t.
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Financ_CDCI³ Autor ³ ANDRE                ³ Data ³ 20/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao que faz o Financiamento de CDCI                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Financ_CDCI()

Local i, lRet := .t.
Local nValorFin := 0

// Gera Titulo p/ CDCI e Gera Contrato de Adesao CDCI
if !Empty(cCodCDCI ) .and. !Empty(aIteParc[1,1]) .and. aIteParc[1,2] > 0
	cContrato := GetSxENum("SEM","EM_CONTRAT")
	ConfirmSx8()
	RecLock("VS1",.f.)
	VS1->VS1_CTCDCI := cContrato
	MsUnlock()
	DbSelectArea("SEN")
	DbSeek(xFilial("SEN")+cCodCDCI)
	lMsErroAuto := .f.
	lMsHelpAuto := .f.
	lError      := .f.
	GTitCDCI(aIteParc,VS1->VS1_CLIFAT,VS1->VS1_LOJA,cContrato)
	if lMsErroAuto
		lError := .t.
		DisarmTransaction()
		Break
	Endif
	
	For i:=1 to Len(aIteParc)
		nValorFin += Round(val(Transform(aIteParc[i,2],"999999.99")),2)
	Next
	
	if !GContCDCI(cContrato,VS1->VS1_CLIFAT,VS1->VS1_LOJA,cNota,cSerie,dDataBase,nTotOrc,nTotalEnt,nTotOrc-nTotalEnt,(nValorFin+nTotalEnt),aIteParc[1,2],aIteParc[1,1],cCodCDCI,0,SEN->EN_COEF,SEN->EN_IOC )
		DisarmTransaction()
		Break
	Endif
	lMsHelpAuto := .t.
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Imprime_DOC³ Autor ³ ANDRE                ³ Data ³ 20/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao que imprime a Nota o Contrato CDCI e os Bloquetos    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Imprime_doc()

Local lRet  := .t.

if !Empty(aIteParc[1,1])
	dbSelectArea("SA6")
	dbSetOrder(1)
	if dbSeek(xFilial("SA6")+M->VS1_CODBCO)
		//		if SA6->A6_BORD == "1"
		cDesBco := M->VS1_NOMBCO
		cObs1 := Substr(SA6->A6_MENSAGE,001,49)
		cObs2 := Substr(SA6->A6_MENSAGE,050,49)
		cObs3 := Substr(SA6->A6_MENSAGE,100,50)
		if ExistBlock("BLQCOB")
			ExecBlock("BLQCOB",.f.,.f.,{cNota,,,,cPrefNF,"1",cObs1,cObs2,cObs3,VS1->VS1_CODBCO})
		Endif
		//		Endif
	Endif
Endif

//Executa ponto de entrada para impressao
if ExistBlock("IMPDOC110")
	ExecBlock("IMPDOC110",.f.,.f.,{M->VS1_NUMORC,cNota,cSerie})
Endif

//Executa RdMake da Nota Fiscal
if ExistBlock("NFPECSER")
	ExecBlock("NFPECSER",.f.,.f.,{cNota,cSerie})
Endif

//Executa programa de impressao do Contrato de Adesao (CDCI)
if !Empty(cCodCDCI )
	if ExistBlock("CONTCDCI")
		ExecBlock("CONTCDCI",.f.,.f.,{SEM->EM_CONTRAT})
	Endif
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Limpa_Var  ³ Autor ³ ANDRE                ³ Data ³ 20/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao que Limpa as Variaveis de Memoria                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Limpa_Var()

Local nUsadoC := Len(aHeaderC)
Local nUsadoP := Len(aHeaderP)
Local nUsadoS := Len(aHeaderS)
Local _ni:=0

lRecompra := .f.
cCodBco := Space(3)
cDesBco := " "
cTipPag := Space(3)
cDesPag := " "

oCodBco:refresh()
oDesBco:Refresh()
oTipPag:refresh()
oDesPag:Refresh()

cCodCdci  := space(04)
nValorCom := 0

cCondic1  := ctod(" ")
cCondic2  := space(02)
cCondic3  := space(Len(SE1->E1_PARCELA))
cCondic4  := space(02)
cCondic5  := "1"

oCondic1:refresh()
oCondic2:refresh()
oCondic3:refresh()
oCondic4:refresh()

aIteBlq  := {}
aIteParc := {{cTod(""),0}}

n       := 1
nTotPec := 0
nTotSrv := 0
nTotOrc := 0
nTotDes := 0

oTotDes:refresh()
oTotPec:refresh()
oTotSrv:refresh()
oTotOrc:refresh()

//Parcelas do financiamento na aba 3
aIteParc := {{cTod(""),0}}
oLbParc:SetArray(aIteParc)
oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
oLbParc:Refresh()

//Pecas relacionadas na aba 2
aIteRel := {{"","","",0,0}}
oLbIteRel:nAt := 1
oLbIteRel:SetArray(aIteRel)
oLbIteRel:bLine := { || { aIteRel[oLbIteRel:nAt,1],;
aIteRel[oLbIteRel:nAt,2],;
aIteRel[oLbIteRel:nAt,3],;
FG_AlinVlrs(Transform(aIteRel[oLbIteRel:nAt,4],"@E 999,999")),;
FG_AlinVlrs(Transform(aIteRel[oLbIteRel:nAt,5],"@E 999,999,999.99"))}}
oLbIteRel:Refresh()

// Condicao de Pagamento
nC     :=1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols da Entrada                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VS9")
aColsC:={Array(nUsadoC+1)}
aColsC[1,nUsadoC+1]:=.F.
For _ni:=1 to nUsadoC
	aColsC[1,_ni]:=CriaVar(aHeaderC[_ni,2])
Next

// Pecas
nP := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols Pecas                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VS3")
aColsP:={Array(nUsadoP+1)}
aColsP[1,nUsadoP+1]:=.F.
For _ni:=1 to nUsadoP
	aColsP[1,_ni]:=CriaVar(aHeaderP[_ni,2])
Next

// Servicos
nS := 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols Servicos                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->VS1_TIPORC == "2"
	dbSelectArea("VS4")
	aColsS:={Array(nUsadoS+1)}
	aColsS[1,nUsadoS+1]:=.F.
	For _ni:=1 to nUsadoS
		aColsS[1,_ni]:=CriaVar(aHeaderS[_ni,2])
	Next
EndIf
If MaFisFound('NF')
	MaFisEnd()
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LIBVENDA  ³ Autor ³ ANDRE                 ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Liberacao de Venda com descontos acima do Permitido         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Qdo cPar diferente de nil, Mostra a situacao da Liberacao   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_LIBVENDA(cPar)

Local lLiberado := .t.
Local i:=0

if cPar # Nil
	if !Empty(cNumLib)
		dbSelectArea("VS6")
		dbSetOrder(1)
		if dbSeek(xFilial("VS6")+cNumLib)
			if Empty(VS6->VS6_DATAUT)
				MsgInfo(OemToAnsi(STR0231),OemToAnsi(STR0148))
				Return .f.
			Else
				if !FG_MOSLIB(cNumLib)
					lLiberado := .f.
				Else
					MsgInfo(OemToAnsi(STR0232),OemToAnsi(STR0028))    //"Venda Liberada...",Ok
					Return .t.
				Endif
			Endif
		Endif
	Endif
	Return(.t.)
Endif

if MsgYesNo(OemToAnsi(STR0233),OemToAnsi(STR0148))
	
	dbSelectArea("VS6")
	RecLock("VS6",.t.)
	
	Private aMemos  := {{"VS6_OBSMEM","VS6_OBSERV"}}
	Private oFonte  := TFont():New( "Arial", 8,14 )
	
	cObserv := MSMM(VS6->VS6_OBSMEM,TamSx3("VS6_OBSERV")[1])
	
	DEFINE MSDIALOG oDlg1 TITLE OemtoAnsi(STR0234) FROM  02,04 TO 14,56 OF oMainWnd
	
	DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
	DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (oDlg1:End()) ENABLE OF oDlg1
	
	@ 01,011 GET oObserv VAR cObserv OF oDlg1 MEMO SIZE 182,67 PIXEL
	oObserv:oFont := oFonte
	oObserv:bRClicked := {|| AllwaysTrue() }
	oObserv:SetFocus()
	
	ACTIVATE MSDIALOG oDlg1 CENTER
	
	Begin Transaction
	
	VS6->VS6_FILIAL := xFilial("VS6")
	VS6->VS6_NUMIDE := GetSxENum("VS6","VS6_NUMIDE")
	VS6->(ConfirmSx8())
	VS6->VS6_TIPAUT := "1"
	VS6->VS6_CODCLI := M->VS1_CLIFAT
	VS6->VS6_LOJA   := M->VS1_LOJA
	VS6->VS6_DATOCO := dDataBase
	VS6->VS6_HOROCO := val(substr(time(),1,2)+substr(time(),4,2))
	VS6->VS6_NUMORC := VS1->VS1_NUMORC
	VS6->VS6_TIPOCO := "000008"
	VS6->VS6_DESOCO := "DESCONTOS"
	VS6->VS6_USUARI := substr(cUsuario,7,15)
	//	VS6->VS6_DOC    := "Orc-"+VS1->VS1_NUMORC
	MSMM(,TamSx3("VS6_OBSERV")[1],,cObserv,1,,,"VS6","VS6_OBSMEM")
	MsUnlock()
	
	dbSelectArea("VS1")
	RecLock("VS1",.f.)
	cNumLib := VS6->VS6_NUMIDE
	VS1->VS1_NUMLIB := cNumLib
	MsUnlock()
	oGetMGet:oBox:Refresh()
	
	dbSelectArea("VS7")
	For i:=1 to Len(aColsP)
		if !aColsP[i,len(aColsP[i])]
			if RecLock("VS7",.t.)
				VS7->VS7_FILIAL := xFilial("VS7")
				VS7->VS7_NUMIDE := VS6->VS6_NUMIDE
				VS7->VS7_SEQUEN := Strzero(i,4)
				VS7->VS7_TIPAUT := "1"
				VS7->VS7_GRUITE := aColsP[i,fg_posvar("VS3_GRUITE","aHeaderP")]
				VS7->VS7_CODITE := aColsP[i,fg_posvar("VS3_CODITE","aHeaderP")]
				
				//Atribui a variavel "nDesPer" o Desconto Permitido
				SBM->(dbSetOrder(1))
				SBM->(dbSeek(xFilial("SBM")+aColsP[i,fg_posvar("VS3_GRUITE","aHeaderP")]))
				FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",aColsP[i,fg_posvar("VS3_GRUITE","aHeaderP")],aColsP[i,fg_posvar("VS3_CODITE","aHeaderP")],aColsP[i,fg_posvar("VS3_QTDITE","aHeaderP")],aColsP[i,fg_posvar("VS3_PERDES","aHeaderP")],.f.,aColsP[i,fg_posvar("VS3_MODVEI","aHeaderP")])
				VS7->VS7_DESPER := nDesPer
				
				VS7->VS7_DESDES := aColsP[i,fg_posvar("VS3_PERDES","aHeaderP")]
				VS7->VS7_VALORI := aColsP[i,fg_posvar("VS3_VALPEC","aHeaderP")]*aColsP[i,fg_posvar("VS3_QTDITE","aHeaderP")]
				VS7->VS7_VALPER := aColsP[i,fg_posvar("VS3_VALPEC","aHeaderP")]*aColsP[i,fg_posvar("VS3_QTDITE","aHeaderP")] - (aColsP[i,fg_posvar("VS3_VALPEC","aHeaderP")]*(1-(nDesPer/100)))*aColsP[i,fg_posvar("VS3_QTDITE","aHeaderP")]
				VS7->VS7_VALDES := aColsP[i,fg_posvar("VS3_VALDES","aHeaderP")]
				MsUnlock()
			Else
				DisarmTransaction()
				Break
			Endif
		Endif
	Next
	
	End Transaction
	
Endif

Return


/////////////////////////////
Static Function FS_CHECKLIB()



Local   lRet      := .t.
Local   nDesComp  := 0
Local j:=0

Private lAltDel   := .f.
Private lLiberado := .f.

dbSelectArea("VS6")
dbSetOrder(1)
If dbSeek(xFilial("VS6")+cNumLib)
	FS_VERDESC(.f.)
	dbSelectArea("VS7")
	dbSetOrder(1)
	If dbSeek(xFilial("VS7")+cNumLib)
		If lDesper == .t.
			Help(" ",1,"M160DELVS6")   // Os Descontos aplicados foram corrigidos e o pedido de liberacao de venda sera eliminado
			lAltDel := .t.
			While cNumLib == VS7_NUMIDE .and. xFilial("VS6") == VS7_FILIAL .and. !eof()
				RecLock("VS7",.F.,.T.)
				dbdelete()
				MsUnlock()
				WriteSx2("VS7")
				dbSkip()
			EndDo
			dbSelectArea("VS6")
			RecLock("VS6",.f.,.t.)
			Dbdelete()
			MsUnlock()
			WriteSx2("VS6")
		Else
			nDesComp := 0
			While cNumLib == VS7_NUMIDE .and. xFilial("VS7") == VS7_FILIAL .and. !Eof()
				nDesComp += VS7_VALDES
				nPos := aScan(aColsP,{|x| x[2]==VS7->VS7_GRUITE .and. x[3]==VS7->VS7_CODITE})
				if nPos == 0 .or. aColsP[nPos,Len(aColsP[nPos])]
					RecLock("VS7",.F.,.T.)
					DbDelete()
					MsUnlock()
					WriteSx2("VS7")
				Endif
				dbSkip()
			EndDo
			If nDesComp != nTotDes
				Help(" ",1,"M160ALTVS6")   // Os Descontos aplicados ainda continuam acima do permitido, o sistema alterara o pedido de liberacao de venda para os novos valores
				lRet    := .f.
				lAltDel := .t.
				dbSelectArea("VS6")
				RecLock("VS6",.f.)
				VS6->VS6_LIBPRO := ""
				VS6->VS6_DATAUT := cTod("")
				VS6->VS6_HORAUT := 0
				VS6->VS6_DATOCO := dDataBase
				VS6->VS6_HOROCO := val(substr(time(),1,2)+substr(time(),4,2))
				MsUnlock()
				
				dbSelectArea("VS7")
				For j:=1 to Len(aColsP)
					if !aColsP[j,Len(aColsP[nPos])]
						if dbSeek(xFilial("VS7")+cNumLib+StrZero(j,4)+"1")
							RecLock("VS7",.f.)
							VS7->VS7_DESDES := aColsP[j,FG_POSVAR("VS3_PERDES","aHeaderP")]
							VS7->VS7_VALDES := aColsP[j,FG_POSVAR("VS3_VALDES","aHeaderP")]
							MsUnlock()
						Else
							RecLock("VS7",.t.)
							VS7->VS7_FILIAL := xFilial("VS7")
							VS7->VS7_NUMIDE := VS6->VS6_NUMIDE
							VS7->VS7_SEQUEN := Strzero(j,4)
							VS7->VS7_TIPAUT := "1"
							VS7->VS7_GRUITE := aColsP[j,fg_posvar("VS3_GRUITE","aHeaderP")]
							VS7->VS7_CODITE := aColsP[j,fg_posvar("VS3_CODITE","aHeaderP")]
							
							//Atribui a variavel "nDesPer" o Desconto Permitido
							SBM->(dbSetOrder(1))
							SBM->(dbSeek(xFilial("SBM")+aColsP[j,fg_posvar("VS3_GRUITE","aHeaderP")]))
							FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",aColsP[j,fg_posvar("VS3_GRUITE","aHeaderP")],aColsP[j,fg_posvar("VS3_CODITE","aHeaderP")],aColsP[j,fg_posvar("VS3_QTDITE","aHeaderP")],aColsP[j,fg_posvar("VS3_PERDES","aHeaderP")],.f.,aColsP[j,fg_posvar("VS3_MODVEI","aHeaderP")])
							VS7->VS7_DESPER := nDesPer
							
							VS7->VS7_DESDES := aColsP[j,fg_posvar("VS3_PERDES","aHeaderP")]
							VS7->VS7_VALORI := aColsP[j,fg_posvar("VS3_VALPEC","aHeaderP")]*aColsP[j,fg_posvar("VS3_QTDITE","aHeaderP")]
							VS7->VS7_VALPER := aColsP[j,fg_posvar("VS3_VALPEC","aHeaderP")]*aColsP[j,fg_posvar("VS3_QTDITE","aHeaderP")] - (aColsP[j,fg_posvar("VS3_VALPEC","aHeaderP")]*(1-(nDesPer/100)))*aColsP[j,fg_posvar("VS3_QTDITE","aHeaderP")]
							VS7->VS7_VALDES := aColsP[j,fg_posvar("VS3_VALDES","aHeaderP")]
							MsUnlock()
						Endif
					Endif
				Next
				
			EndIf
			
			dbSelectArea("VS6")
			
		Endif
		
	EndIf
	
	If lAltDel == .f.
		If Empty(VS6->VS6_DATAUT)
			MsgInfo(OemToAnsi(STR0231),OemToAnsi(STR0148))       //"Venda ainda nao Liberada...","Atencao!")
			lRet := .f.
		Else
			If !FG_MOSLIB(cNumLib)
				cNumLib := ""
				lRet := .f.
			Else
				MsgInfo(OemToAnsi(STR0232),OemToAnsi(STR0028))    //"Venda Liberada...",OK
				lLiberado := .t.
			EndIf
		EndIf
	EndIf
	
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERDESC  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Ver desconto permitido                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VERDESC(lLibVda)

Local lRet := .t.
Local i:=0

For i:=1 to Len(aColsP)
	SBM->(dbSetOrder(1))
	SBM->(dbSeek(xFilial("SBM")+aColsP[i,fg_posvar("VS3_GRUITE","aHeaderP")]))
	If !FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",aColsP[i,fg_posvar("VS3_GRUITE","aHeaderP")],aColsP[i,fg_posvar("VS3_CODITE","aHeaderP")],aColsP[i,fg_posvar("VS3_QTDITE","aHeaderP")],aColsP[i,fg_posvar("VS3_PERDES","aHeaderP")],.f.,aColsP[i,fg_posvar("VS3_MODVEI","aHeaderP")])
		lRet    := .f.
		lDesPer := .f.
	Endif
Next

If lLibVda .and. !lDesPer
	If !FG_MNU( cUserName , 2 , "OFIOM170" )
		FS_LIBVENDA()
	Else
		lRet := .t.
	EndIf
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VALFOLDER³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida passagem de uma aba p/ outra                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nro da aba                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALFOLDER(nOpc,x)

Local lReturn := .t.

if oFolder:nOption == 2
	if Type(cGetDados) == "U"
		if oFolder2:nOption == 1
			aHeaderP := aClone(aHeader)
			aColsP   := aClone(aCols)
			nP       := n
		Else
			aHeaderS := aClone(aHeader)
			aColsS   := aClone(aCols)
			nS       := n
		Endif
	Else
		if &(cGetDados):oBrowse:lVisible
			aHeader := aclone(aHeaderI)
			&(cGetDados):oBrowse:Refresh()
		Endif
	Endif
Elseif oFolder:nOption == 3
	aHeaderC := aClone(aHeader)
	aColsC   := aClone(aCols)
	nC       := n
Endif

if x == 3
	If FS_VIABACP(aPriEnc) // Valida Inicializacao da ABA de Como Pagar
		if !lJaPerg
			lReturn := .f.
		Endif
		dbSelectArea("VAI")
		If Empty(M->VS1_CODVEN)
			dbSetOrder(4)
			dbSeek(xFilial("VAI")+__cUserID)
		Else
			dbSetOrder(6)
			dbSeek(xFilial("VAI")+M->VS1_CODVEN)
		Endif
		lNegPag := .t.
		If cPaisLoc == "BRA"
			if !(lNegPag := VAI->VAI_NEGPAG == "1")
				MsgInfo(STR0419 ,STR0148) //"Opcao de negociacao nao permitida para este usuario! # Atencao!
				lReturn := .f.
			Endif
		Endif
	Else
		lReturn := .f.
	Endif
Endif

//if !FG_CHEREV()
//	lReturn := .f. //Otavio 27/11/2009 - FNC 00000026382/2009
//Endif
if x # 1
	if TYPE("M->VS1_TIPORC") == "U"
		lReturn := .f.
	Else
		if nOpc == 1
			if x == 3
				if Empty(M->VS1_TIPORC)
					msginfo(STR0235,STR0148)
					lReturn := .f.
				Elseif M->VS1_TIPORC # "1"
					msginfo(STR0236,STR0148)
					lReturn := .f.
				Endif
			Endif
		Else
			if M->VS1_TIPORC # "2"
				msginfo(STR0237,STR0148)
				lReturn := .f.
			Endif
		Endif
	Endif
Endif


If !(cPaisLoc == "BRA") .and. M->VS1_TIPORC == "1" // Manoel - 07/05/2009
	If x == 3
		If MsgYesNo(OemToAnsi(STR0130),OemToAnsi(STR0019))
			FS_FECVDA()
			lFimArg := .t.
			oDlgOrc:end()
			//			oFolder:nOption := 1
			//			FS_FOLDER(.f.)
			//			o_CodInt:SetFocus()
			//			oScrollCS:Refresh()
			//			oDlgOrc:Refresh()
		Else
			lReturn := .f.
		Endif
	Endif
Endif


Return(lReturn)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_AVALIARES³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Avaliacao do Resultado da Venda                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_AVALIARES()

Private cArqTrb
Private cArqPes
Private cCodMap
Private cOutMoed
Private cSimOMoe
Private aVetVal := {}
Private aStru   := {}
Private cParPro := "1"
Private cNumero := VS1->VS1_NUMORC
Private cContChv:= "VEC_NUMORC"
Private cParTem := ""
Private lCalcTot:= .f.
Private cCpoDiv := "    1"

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VEC")
Do While !EOF() .and. x3_arquivo == "VEC"
	aadd(aVetVal,{x3_campo,x3_tipo,x3_tamanho,x3_decimal})
	dbSkip()
EndDo

aAltSx1  := { {"02","","","","","",GETMV("MV_SIMB1"),GETMV("MV_SIMB2"),GETMV("MV_SIMB3"),GETMV("MV_SIMB4"),GETMV("MV_SIMB5"),"","","","",""} }
FG_AltSx1("ATDCLI","A",aAltSx1)

if !PERGUNTE("ATDCLI")
	Return
Endif

cCodMap  := Mv_Par01
cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))

dbSelectArea("VEC")
oObjTempTable := OFDMSTempTable():New()
oObjTempTable:cAlias := "TRB"
oObjTempTable:aVetCampos := aVetVal
oObjTempTable:AddIndex(, {"VEC_FILIAL","VEC_NUMOSV"} )
oObjTempTable:CreateTable()


MSGRUN(oemtoansi(STR0420 ),"",{||CursorWait(),FS_AVRES2(),CursorArrow()})//Aguarde... Processando Mapa de Avaliacao

FG_RESAVA(cOutMoed,3,cSimVda,"","OFIOM110")

oObjTempTable:CloseTable()

Return


////////////////////
Function AL_Inicio()
aTela := aClone(aSvATela[1])
aGets := aClone(aSvAGets[1])
dbSelectArea("VS1")
Return .T.

////////////////////////////
Function AL_Entra(nE,cAlias)
aTela := AClone(aSvAtela[nE])
aGets := AClone(aSvaGets[nE])
dbSelectArea(cAlias)
Return

///////////////////
Function Al_Sai(nE)
aSvATela[nE]	:= aClone(aTela)
aSvAGets[nE]   	:= aClone(aGets)
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PRINTORC ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida passagem de uma aba p/ outra                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nro da aba                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fs_PRINTORC()

//Local cOpcao     := STR0239
Local oFolderSlv := oFolder

if !lJagravou
	MsgInfo(STR0421 ,STR0148) //O Orcamento tem que ser gravado antes da impressao! # Atencao!
	Return .f.
Endif

if ExistBlock("IMPORCBAL")
	if ExecBlock("IMPORCBAL",.f.,.f.)
		if !MsgYesNo(STR0422 ,STR0148) //O orcamento ja foi impresso, emitir novamente? # Atencao!
			Return .f.
		Endif
	Endif
Endif
/*
aOpcao := {STR0239,STR0240}
xOpc   := 2

DEFINE MSDIALOG oDlgPergImp TITLE OemtoAnsi(STR0241) FROM  02,04 TO 9,28 OF oMainWnd

nCkImp := 1
@ 005,005 RADIO oRadio1 VAR nCkImp 3D SIZE 70,10 PROMPT;
OemToAnsi(STR0239), OemToAnsi(STR0240);
OF oDlgPergImp PIXEL

@ 038,005 BUTTON oOkImp  PROMPT OemToAnsi("Confirma") OF oDlgPergImp SIZE 43,11 PIXEL ACTION (xOpc := 1,oDlgPergImp:End())
@ 038,048 BUTTON oNoImp  PROMPT OemToAnsi("Cancela")  OF oDlgPergImp SIZE 43,11 PIXEL ACTION (xOpc := 2,oDlgPergImp:End())

oOkImp:SetFocus()

ACTIVATE MSDIALOG oDlgPergImp CENTER

if xOpc == 1
if cOpcao == STR0239
//Executa RdMake de Impressao do Orcamento
if ExistBlock("ORCAMTO")
ExecBlock("ORCAMTO",.f.,.f.,{M->VS1_NUMORC})
Endif
Else
PERGUNTE("OFI110")
if Mv_par01 == 1
CALLCRYS("Orcamento",M->VS1_NUMORC)
Elseif Mv_par01 == 2
CALLCRYS("Orcament2",M->VS1_NUMORC)
Else
CALLCRYS("Orcament3",M->VS1_NUMORC)
Endif
Endif
Endif
*/
if ExistBlock("ORCAMTO")
	ExecBlock("ORCAMTO",.f.,.f.,{M->VS1_NUMORC})
Endif

oFolder := oFolderSlv

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_MUDAFPG  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atualiza Forma de Pagamento do Orcamento qdo alterado       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Not = Nil, Pega Forma de Pgto do VS1                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MUDAFPG(cPrinc)

Local wRet := .t.

if Left(Funname(),4) == "OFIX" .or. FunName() == "OFIOM350" .or. FunName() == "OFIO430" .or. FunName() == "M_CONSPEC"
	return .t.
endif

if cPrinc # Nil
	cTipPag := M->VS1_FORPAG
Endif

if !Empty(SA1->A1_TIPPER) .and. cOpeMov2 <> "2"
	if !(!Empty(cForPeri) .and. cForPeri == cTipPag)
		nOperacao := Aviso( STR0423, STR0424, { STR0028 , STR0323 } )//Cliente Periodico # Este e um cliente periodico, mudando a condicao de pagamento o sistema nao gerara titulos provisorios # ok # cancela
		if nOperacao <> 1
			Return .f.
		Endif
	Endif
Endif

if cPrinc == Nil
	if Empty(cTipPag)
		cTipPag := Space(3)
		cDesPag := ""
		oDesPag:Refresh()
		Return .t.
	Endif
Endif

dbSelectArea("SE4")
if dbSeek(xFilial("SE4")+cTipPag)
	cDesPag := SE4->E4_DESCRI
	M->VS1_FORPAG := cTipPag
	M->VS1_DESFPG := cDesPag
	if Inclui .and. !lJaGravou
		wRet := .t.
	Else
		RecLock("VS1",.f.)
		VS1->VS1_FORPAG := cTipPag
		MsUnlock()
	Endif
Else
	wRet := .f.
Endif

if SE4->(dbSeek(xFilial("SE4")+M->VS1_FORPAG))
	//	if val(AllTrim(SE4->E4_COND)) > 0
	/*
	nTotFre := M->VS1_VALFRE
	nTotSeg := M->VS1_VALSEG
	nTotAce := M->VS1_DESACE
	*/
	FS_CALPAR(cTipOpe,nTotTit)
	//	Else
	//		FG_DesfPag()
	//		cCondic1:=ctod(" ")
	//		cCondic2:=space(02)
	//		cCondic3:=space(02)
	//		cCondic4:=space(02)
	//	Endif
Endif

oDesPag:Refresh()

Return(wRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_MUDABCO  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Muda Banco do Orcamento                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Not = Nil, Pega Banco do VS1                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MUDABCO(cPrinc)

Local wRet := .t.

if cPrinc # Nil
	cCodBco := M->VS1_CODBCO
Endif

if cPrinc == Nil
	if Empty(cCodBco)
		cCodBco := Space(3)
		cDesBco := Space(3)
		oDesBco:Refresh()
		Return .t.
	Endif
Endif

dbSelectArea("SA6")
if dbSeek(xFilial("SA6")+cCodBco)
	cDesBco := SA6->A6_NOME
	M->VS1_CODBCO := cCodBco
	M->VS1_NOMBCO := cDesBco
	if Inclui .and. !lJaGravou
		wRet := .t.
	Else
		if RecLock("VS1",.f.)
			VS1->VS1_CODBCO := cCodBco
			MsUnlock()
		Endif
	Endif
Else
	SE4->(dbSeek(xFilial("SE4")+cTipPag))
	if Empty(cCodBco)
		if !val(SE4->E4_COND) == 0
			wRet := .f.
		Endif
	Else
		wRet := .f.
	Endif
Endif

oDesBco:Refresh()

Return(wRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FP_INIIMP   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Inicia Empresa                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Cliente e Loja                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Funcao Microsiga                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FP_INIIMP(cCodCli,cLoja)

If !MaFisFound('NF')
	If !Empty(cLoja)
		MaFisIni(cCodCli,cLoja,'C','N',SA1->A1_TIPO,MaFisRelImp("OF110",{"VS1","VS3"}))
	Else
		MaFisIni(cCodCli,SA1->A1_LOJA,'C','N',SA1->A1_TIPO,MaFisRelImp("OF110",{"VS1","VS3"}))
	EndIf
Else
	MaFisRef("NF_CODCLIFOR","VS300",cCodCli)
	If !Empty(cLoja)
		MaFisRef("NF_LOJA","VS300",cLoja)
	Else
		MaFisRef("NF_LOJA","VS300",SA1->A1_LOJA)
	EndIf
EndIf

if lVAMCid
	FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
	cEstado := VAM->VAM_ESTADO
Else
	cEstado := SA1->A1_EST
Endif

//if SA1->A1_PESSOA == "J" .and. !Empty(SA1->A1_INSCR) .and. cEstado <> GETMV("MV_ESTADO")  .and. MaFisFound('NF')
//   MaFisAlt("NF_CODCLIFOR",GetMv("MV_CLIPAD"))
//   MaFisAlt("NF_LOJA",GetMv("MV_LOJAPAD"))
//Endif

if !Empty(SA1->A1_TIPPER)	.and. cOpeMov2 <> "2" .and. Empty(M->VS1_FORPAG) 
	M->VS1_FORPAG := SA1->A1_COND
	cForPeri      := SA1->A1_COND
	FS_MUDAFPG(1)
Endif

if !lRecompra
	dbSelectArea("VE4")
	dbSeek(xFilial("VE4"))
	While !Eof() .and. xFilial("VE4") == VE4->VE4_FILIAL
		if cCodCli == VE4->VE4_CODFAB
			if MsgYesNo(STR0425 ,STR0148) //Este e um processo de retorno de pecas para a fabrica ? # Atencao!
				lRecompra := .t.
				M->VS1_RETPEC := "1"
				M->VS1_ORCACE := "0"
				Exit
			Endif
		Endif
		dbSelectArea("VE4")
		dbSkip()
	Enddo
Endif

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FPREFRESH   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atualiza Folder de Condicao de Pagamento                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generica                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FPREFRESH()

If MaFisFound('NF')
	M->VS1_VTOTNF := MaFisRet(,"NF_TOTAL")//-MAFISRET(1,"IT_DESCZF")
	M->VS1_VALDES := MaFisRet(,"NF_DESCONTO")
	M->VS1_ICMCAL := MaFisRet(,"NF_VALICM")
	M->VS1_DESACE := MaFisRet(,"NF_DESPESA")
	if M->VS1_ICMRET == 0 .and. M->VS1_BRICMS == 0 
		M->VS1_ICMRET:= MaFisRet(,"NF_VALSOL")
		M->VS1_BRICMS := MaFisRet(,"NF_BASESOL")
	Endif	
EndIf

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_TES      ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Inicializa TES do Produto                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Generica                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TES(nLin)

cSvAlias := Alias()

dbSelectArea("SB1")
dbSetOrder(7)
if nLin == Nil
	dbSeek(xFilial("SB1")+aCols[n,FG_POSVAR("VS3_GRUITE")]+aCols[n,FG_POSVAR("VS3_CODITE")])
Else
	dbSeek(xFilial("SB1")+aColsP[nLin,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[nLin,FG_POSVAR("VS3_CODITE","aHeaderP")])
Endif

dbSelectArea(cSvAlias)

Return(SB1->B1_TS)


/////////////////////
Function FS_PEGALOJA()

cAlias := Alias()

dbSelectArea("SA1")
dbSeek(xFilial("SA1")+M->VS1_CLIFAT)
M->VS1_LOJA := SA1->A1_LOJA
FP_IniImp(M->VS1_CLIFAT,M->VS1_LOJA)
FS_PREFAT()

dbSelectarea(cAlias)

Return .t.


////////////////////
Function Fs_RelFor()

// Local cForPad

dbSelectArea("VEG")
cForPad := GETMV("MV_FMLPECA")
if !Empty(cForPad)
	dbSetOrder(1)
	dbSeek(xFilial("VEG")+&cForPad)
Else
	dbSetOrder(2)
	dbSeek(xFilial("VEG")+"04")
	dbSetOrder(1)
Endif

dbSelectArea("VS1")
Return(VEG->VEG_CODIGO)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_INSERE   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Insere Peca da consulta no Orcamento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_INSERE()

Local cAceito := Iif(M->VS1_ORCACE=="0","S","N")
Local i:=0, _ni:=0

if !MaFisFound('NF')
	MsgInfo(STR0249,STR0148)
	Return .f.
Endif

if !lJaPerg
	MsgInfo(STR0243,STR0148)
	Return .f.
Endif

if !Fs_VerCabec()
	oFolder:nOption := 2
	Return
Endif

if Empty(get_grupo) .or. Empty(get_codite)
	MsgInfo(STR0244,STR0148)
	Return .f.
Endif

if !Empty(M->VS1_CODMAR)
	if M->VS1_CODMAR # cCodMar
		MsgInfo(STR0245,STR0148)
		Return .f.
	Endif
Endif

For i:=1 to Len(aColsP)
	if (aColsP[i,FG_POSVAR("VS3_GRUITE","aHeaderP")] == get_grupo) .and. (aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")] == get_codite) .and. !aColsP[i,Len(aColsP[i])]
		MsgInfo(STR0246,STR0148)
		Return .f.
	Endif
Next

if !Empty(aColsP[Len(aColsP),FG_POSVAR("VS3_SEQUEN","aHeaderP")]) .and. !Empty(aColsP[Len(aColsP),FG_POSVAR("VS3_GRUITE","aHeaderP")]) .and. !Empty(aColsP[Len(aColsP),FG_POSVAR("VS3_CODITE","aHeaderP")])
	AADD(aColsP,Array(nUsadoP+1))
	aColsP[Len(aColsP),nUsadoP+1]:=.F.
	For _ni:=1 to nUsadoP
		aColsP[Len(aColsP),_ni]:=CriaVar(aHeaderP[_ni,2])
	Next
Endif

n := Len(aColsP)

aCols   := aClone(aColsP)
aHeader := aClone(aHeaderP)

lJaMovPec := .f.

//Insere a Peca no Orcamento
aColsP[Len(aColsP),FG_POSVAR("VS3_SEQUEN","aHeaderP")] := FS_SEQAUTO("P")
aColsP[Len(aColsP),FG_POSVAR("VS3_GRUITE","aHeaderP")] := get_grupo
aColsP[Len(aColsP),FG_POSVAR("VS3_CODITE","aHeaderP")] := get_codite
aColsP[Len(aColsP),FG_POSVAR("VS3_DESITE","aHeaderP")] := get_descri
aColsP[Len(aColsP),FG_POSVAR("VS3_VALPEC","aHeaderP")] := get_codite1

if Type("M->VS3_QTDEST") <> "U"
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+get_grupo+get_codite)
	nSaldo := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
	M->VS3_QTDEST := nSaldo
	aColsP[Len(aColsP),FG_POSVAR("VS3_QTDEST","aHeaderP")] := nSaldo
Endif

M->VS3_GRUITE := get_grupo
M->VS3_CODITE := get_codite

//Calcula o Preco da Peca
wAlias := alias()

FG_Seek("SB1","get_grupo+get_codite",7,.f.)
FG_Seek("SB2","SB1->B1_COD+SB1->B1_LOCPAD",1,.f.)
if cOpeMov2 == "1"
	aColsP[Len(aColsP),FG_POSVAR("VS3_FORMUL","aHeaderP")] := M->VS1_FORMUL
	aColsP[Len(aColsP),FG_POSVAR("VS3_CODTES","aHeaderP")] := SB1->B1_TS
Else
	aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")] := cTesPad
	M->VS3_CODTES := cTesPad
	if Empty(M->VS3_FORMUL)
		M->VS3_FORMUL := GETMV("MV_FMLPECA")
		if Type("M->VS3_FORMUL") <> "C"
			M->VS3_FORMUL := SPACE(LEN(VS3->VS3_FORMUL))
		Endif
	Endif
Endif
nValPec := FG_VALPEC(M->VS1_TIPTEM,"M->VS3_FORMUL",M->VS3_GRUITE,M->VS3_CODITE,"M->VS3_VALPEC",.f.,.t.)

cCodMar := M->VS1_CODMAR
if Empty(cCodMar)
	dbSelectArea("SBM")
	dbSetOrder(1)
	dbSeek(xFilial("SBM")+M->VS3_GRUITE)
	cCodMar := SBM->BM_CODMAR
Endif

dbSelectArea("VAI")
If Empty(M->VS1_CODVEN)
	dbSetOrder(4)
	dbSeek(xFilial("VAI")+__cUserID)
Else
	dbSetOrder(6)
	dbSeek(xFilial("VAI")+M->VS1_CODVEN)
Endif

dbSelectArea("SA3")
dbSetOrder(1)
if !dbSeek(xFilial("SA3")+VAI->VAI_CODVEN)
	MsgInfo(STR0426 ,STR0148) //Usuario sem codigo de vendedor relacionado! # Atencao!
	Return .f.
Endif
cCodVen := SA3->A3_COD
cCenCus := VAI->VAI_CC

nValPec := FS_PROMOCAO(cCodMar,cCenCus,M->VS3_GRUITE,M->VS3_CODITE)

// LUIS DELORME
if nValPec == 0
	nValPec := get_preco
endif
//

dbSelectArea(wALias)

nPos := aScan(aIteBlq,{|x| x[1] == aColsP[Len(aColsP),FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
if nPos == 0
	aIteBlq[Len(aIteBlq),1] := aColsP[Len(aColsP),FG_POSVAR("VS3_SEQUEN","aHeaderP")]
	aIteBlq[Len(aIteBlq),2] := if(SaldoSb2()>0,"S","N")
	aIteBlq[Len(aIteBlq),3] := cAceito
	aIteBlq[Len(aIteBlq),4] := "N"
Endif

nPos := aScan(aIteRes,{|x| x[1] == aColsP[Len(aColsP),FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
if nPos == 0
	aIteRes[Len(aIteRes),1] := aColsP[Len(aColsP),FG_POSVAR("VS3_SEQUEN","aHeaderP")]
	aIteRes[Len(aIteRes),2] := aColsP[Len(aColsP),FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[Len(aColsP),FG_POSVAR("VS3_CODITE","aHeaderP")]
	aIteRes[Len(aIteRes),3] := 0
Endif

//Quantidade inicial igual a 1
aColsP[Len(aColsP),FG_POSVAR("VS3_QTDITE","aHeaderP")] := 1
aColsP[Len(aColsP),FG_POSVAR("VS3_VALPEC","aHeaderP")] := nValPec

M->VS3_QTDITE := 1
M->VS3_VALPEC := nValPec

//Desconto padrao cadastrado no VS1
if aColsP[Len(aColsP),FG_POSVAR("VS3_PERDES","aHeaderP")] == 0
	aColsP[Len(aColsP),FG_POSVAR("VS3_PERDES","aHeaderP")] := M->VS1_PERPEC
Endif
M->VS3_PERDES := aColsP[Len(aColsP),FG_POSVAR("VS3_PERDES","aHeaderP")]
SBM->(dbSetOrder(1))
SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,M->VS3_PERDES,,M->VS3_MODVEI)

M->VS3_VALDES := ((M->VS3_VALPEC*M->VS3_QTDITE)/100)*M->VS3_PERDES
M->VS3_VALTOT := (M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES

aColsP[Len(aColsP),FG_POSVAR("VS3_VALTOT","aHeaderP")] := M->VS3_VALTOT
aColsP[Len(aColsP),FG_POSVAR("VS3_VALDES","aHeaderP")] := M->VS3_VALDES

n := Len(aColsP)

MaFisRef("IT_PRODUTO","VS300",SB1->B1_COD)
MaFisRef("IT_VALMERC","VS300",M->VS3_VALTOT+M->VS3_VALDES)
MaFisRef("IT_TES","VS300",aColsP[n,FG_POSVAR("VS3_CODTES","aHeaderP")])
MaFisRef("IT_DESCONTO","VS300",M->VS3_VALDES)

M->VS1_VTOTNF := MaFisRet(,"NF_TOTAL")-MaFisRet(,"NF_DESCZF")
M->VS1_VALDES := MaFisRet(,"NF_DESCONTO")
M->VS1_ICMCAL := MaFisRet(,"NF_VALICM")
M->VS1_DESACE := MaFisRet(,"NF_DESPESA")

// Verifica as reservas do orcamento aceito
nSaldo := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
nPos := aScan(aIteBlq,{|x| x[1] == aColsP[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")]})
FS_TRANSFER(nSaldo,1,nPos,aColsP[n,FG_POSVAR("VS3_QTDITE","aHeaderP")],.F.,n)

//aCols tem que estar igual ao aColsP por causa da funcao MaFisRet
aCols   := aClone(aColsP)
aHeader := aClone(aHeaderP)

If (cPaisLoc == "BRA") // Manoel - 07/05/2009
	if cOpeMov2 == "1" .or. !Empty(cTesPad)
		aColsP[Len(aColsP),fg_posvar("VS3_VBAICM","aHeaderP")] := MaFisRet(Len(aColsP),"IT_BASEICM")
		aColsP[Len(aColsP),fg_posvar("VS3_ALIICM","aHeaderP")] := MaFisRet(Len(aColsP),"IT_ALIQICM")
		aColsP[Len(aColsP),fg_posvar("VS3_ICMCAL","aHeaderP")] := MaFisRet(Len(aColsP),"IT_VALICM")
		FpRefresh()
	Endif
Endif

aCols   := aClone(aColsP)
aHeader := aClone(aHeaderP)

FS_ITEREL110()

nTotPec := 0
nTotOrc := 0
nTotDes := 0
nTotTit := 0
nBrinde := 0

For i:=1 to Len(aCols)
	if aCols[i,Len(acols[i])] == .t.
		Loop
	Endif
	nTotPec += aCols[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
	nTotOrc += aCols[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
	nTotDes += aCols[i,FG_POSVAR("VS3_VALDES","aHeaderP")]
	if TipoTes(aCols[i,FG_POSVAR("VS3_CODTES","aHeaderP")])
		nTotTit += aCols[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
		//if SF4->F4_INCSOL == "S"
		//   nTotTit += MaFisRet(i,"IT_VALSOL")
		//Endif
	Else
		nBrinde += aCols[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
	Endif
Next

nTotTit -= nTotCre

oTotDes:refresh()
oTotPec:refresh()
oTotOrc:refresh()

if aColsP[Len(aColsP),Len(aColsP[Len(aColsP)])]
	aColsP[Len(aColsP),Len(aColsP[Len(aColsP)])] := .f.
Endif

// Verifica se o Array aIteRes e aIteBlq estao de acordo com o aColsP
n1 := n
FS_BLQRES()
n := n1

oGetPecas:oBrowse:Refresh()

if SB1->B1_MSBLQL $ "1S"
	MsgAlert(STR0368,STR0019)//O Produto escolhido esta bloqueado para a venda!
endif

MsgInfo(STR0247,STR0028)

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERCABEC ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se os Campos do VS1 Foram Informados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fs_VerCabec()

Local nPos := 0
Local wRet := .t.
Local i:=0

if Empty(M->VS1_TIPORC)
	For i:=1 to Len(oGetMGet:aEntryCtrls)
		if allTrim(oGetMGet:aEntryCtrls[i]:cReadVar) == "M->VS1_TIPORC"
			nPos := i
			wRet := .f.
			Exit
		Endif
	Next
	if nPos > 0
		MsgInfo(STR0248,STR0148)
		oGetMGet:AENTRYCTRLS[nPos]:SetFocus()
	Endif
	/*
	Elseif Empty(M->VS1_CLIFAT)
	For i:=1 to Len(oGetMGet:aEntryCtrls)
	if allTrim(oGetMGet:aEntryCtrls[i]:cReadVar) == "M->VS1_CLIFAT"
	nPos := i
	wRet := .f.
	Exit
	Endif
	Next
	if nPos > 0
	MsgInfo(STR0249,STR0148)
	oGetMGet:AENTRYCTRLS[nPos]:SetFocus()
	Endif
	Elseif Empty(M->VS1_LOJA)
	For i:=1 to Len(oGetMGet:aEntryCtrls)
	if allTrim(oGetMGet:aEntryCtrls[i]:cReadVar) == "M->VS1_LOJA"
	nPos := i
	wRet := .f.
	Exit
	Endif
	Next
	if nPos > 0
	MsgInfo(STR0250,STR0148)
	oGetMGet:AENTRYCTRLS[nPos]:SetFocus()
	Endif
	*/
Elseif Empty(M->VS1_FORMUL)
	For i:=1 to Len(oGetMGet:aEntryCtrls)
		if allTrim(oGetMGet:aEntryCtrls[i]:cReadVar) == "M->VS1_FORMUL"
			nPos := i
			wRet := .f.
			Exit
		Endif
	Next
	if nPos > 0
		MsgInfo(STR0251,STR0148)
		oGetMGet:AENTRYCTRLS[nPos]:SetFocus()
	Endif
Endif

/*
If !MaFisFound('NF') .and. wRet
FP_IniImp(M->VS1_CLIFAT,M->VS1_LOJA)
if !MaFisFound('NF')
MsgInfo("Fiscal nao inicializado !","Atencao !")
wRet := .f.
Endif
Endif
*/

if !wRet .and. !lRecompra
	if !Empty(M->VS1_NCLIFT)
		wRet := .t.
	Endif
Endif

Return(wRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VIABACP ³ Autor ³ Andre Luis Almeida  ³ Data ³ 15/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica quando inicializa ABA do 'Como Pagar'              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VIABACP()
Local ni   := 0
Local nPos := 0
Local wRet := .t.
Local i:=0
Local cAlAnt := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Otavio - 24/06/2009 - FNC 00000014055                        ³
//³ Verifica obrigatorios dos campos da MsMGet Atual             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i:=1 to Len(aPriEnc)
	If X3Obrigat(aPriEnc[i]) .and. Empty(&("M->"+aPriEnc[i])) .and. !(AllTrim(aPriEnc[i]) $ "VS1_TIPORC/VS1_CLIFAT/VS1_LOJA") //Exceto campos que ja sao validados pela funcao FS_VALFOLDER.
		Help(" ",1,"OBRIGAT2",,RetTitle(aPriEnc[i]),4,1 )
		Return
	EndIf
Next

if Empty(M->VS1_CLIFAT)
	For i:=1 to Len(oGetMGet:aEntryCtrls)
		if allTrim(oGetMGet:aEntryCtrls[i]:cReadVar) == "M->VS1_CLIFAT"
			nPos := i
			wRet := .f.
			Exit
		Endif
	Next
	if nPos > 0
		MsgInfo(STR0249,STR0148)
		oGetMGet:AENTRYCTRLS[nPos]:SetFocus()
	Endif
Elseif Empty(M->VS1_LOJA)
	For i:=1 to Len(oGetMGet:aEntryCtrls)
		if allTrim(oGetMGet:aEntryCtrls[i]:cReadVar) == "M->VS1_LOJA"
			nPos := i
			wRet := .f.
			Exit
		Endif
	Next
	if nPos > 0
		MsgInfo(STR0250,STR0148)
		oGetMGet:AENTRYCTRLS[nPos]:SetFocus()
	Endif
EndIf
If !MaFisFound('NF') .and. wRet
	FP_IniImp(M->VS1_CLIFAT,M->VS1_LOJA)
	if !MaFisFound('NF')
		MsgInfo(STR0427 ,STR0148) //Fiscal nao inicializado! # Atencao!
		wRet := .f.
	Endif
EndIf
cAlAnt := Alias()
DbSelectArea("SB1")
DbSetOrder(7)
For ni := 1 to len(aColsP)
	If !aColsP[ni,Len(aColsP[ni])]
		If DbSeek(xFilial("SB1")+aColsP[ni,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[ni,FG_POSVAR("VS3_CODITE","aHeaderP")])
			If SB1->B1_MSBLQL $ "1S"
				MsgAlert(STR0368+CHR(13)+CHR(10)+CHR(13)+CHR(10)+aColsP[ni,1]+" - "+SB1->B1_GRUPO+" "+SB1->B1_CODITE+CHR(13)+CHR(10)+SB1->B1_DESC,STR0019)//O Produto escolhido esta bloqueado para a venda!
				wRet := .f.
				Exit
			EndIf
		EndIf
	EndIf
Next
DbSelectArea(cAlAnt)
Return(wRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERCHASSI³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Pega Dados do Veiculo                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VERCHASSI()

dbSelectarea("VV1")
dbSetOrder(1)
if dbSeek(xFilial("VV1")+M->VS1_CHAINT)
	M->VS1_CHASSI := VV1_CHASSI
	M->VS1_DESMOD := VV1_MODVEI
	M->VS1_FABMOD := VV1_FABMOD
	M->VS1_DESCOR := VV1_CORVEI
	M->VS1_PROVEI := VV1_PROATU
	M->VS1_LOJAPR := VV1_LJPATU
	dbSelectarea("VE1")
	dbSetOrder(1)
	if dbSeek(xFilial("VE1")+VV1->VV1_CODMAR)
		M->VS1_DESMAR := VE1->VE1_MARCA
	Endif
	dbSelectarea("SA1")
	dbSetOrder(1)
	if dbSeek(xFilial("SA1")+M->VS1_PROVEI)
		if lVAMCid
			FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
		Endif
		M->VS1_NOMPRO := SA1->A1_NOME
		M->VS1_ENDPRO := SA1->A1_END
		if lVAMCid
			M->VS1_CIDPRO := VAM->VAM_DESCID
			M->VS1_ESTPRO := VAM->VAM_ESTADO
		Else
			M->VS1_CIDPRO := SA1->A1_MUN
			M->VS1_ESTPRO := SA1->A1_EST
		Endif
		M->VS1_FONPRO := SA1->A1_TEL
	Endif
Else
	Return .f.
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FORMUL   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Muda Formula de Pagamento                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FORMUL()

if Left(Funname(),4) == "OFIX" .or. FunName() == "OFIOM350" .or. FunName() == "OFIOM430" .or. FunName() == "M_CONSPEC"
	return .t.
endif

if FG_SEEK("VEG","M->VS1_FORMUL",1,.f.)
	if VEG->VEG_GRUFOR == cGruFor
		//		if cOpeMov2 == "1"
		if n > Len(aColsP)
			Return .t.
		Endif
		if Empty(aColsP[1,FG_POSVAR("VS3_CODITE","aHeaderP")])
			Return .t.
		Endif
		aColsP[n,fg_posvar("VS3_FORMUL","aHeaderP")] := M->VS1_FORMUL
		M->VS3_FORMUL := M->VS1_FORMUL
		Return .t.
	Endif
	//	Endif
Endif

Return .f.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_SERAGRU  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Insere Pecas do Servico Agrupado                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Codigo do Servico                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SERAGRU(cCodSer)

Local lIgual
Local ix_ := 0, xx:=0, _ni:=0, i:=0
Local cFormDes := ""

Private aAgrSerList := {}
Private aAgrupSer   := {}
Private aIteRelAgru := {}
Private oLbAgruSer
Private oLbIteRelAgru
Private lVez := .f.

dbSelectArea("VO6")
dbSetOrder(2)
if dbSeek(xFilial("VO6")+ FG_MARSRV(M->VS1_CODMAR,cCodSer) + cCodSer )
	if VO6->VO6_AGRSER == "N"
		Return
	Endif
	
	dbSelectArea("VO8")
	dbSeek(xFilial("VO8")+M->VS1_CODMAR+VV1->VV1_MODVEI+VV1->VV1_SEGMOD+cCodSer)
	Do While !EOF() .and. VO8->VO8_FILIAL == xFilial("VO8") .and. (VO8->VO8_CODMAR+VO8->VO8_CODSER == M->VS1_CODMAR+cCodSer).and. VO8->VO8_MODVEI+VO8->VO8_SEGMOD == VV1->VV1_MODVEI+VV1->VV1_SEGMOD
		If !VO8->VO8_TIPAGR $ "01"
			Aadd(aAgrSerList,{VO8->VO8_TIPAGR , VO8->VO8_GRUITE, VO8->VO8_CODITE, Posicione("SB1",7,xFilial("SB1")+VO8->VO8_GRUITE+VO8->VO8_CODITE,"B1_DESC") , VO8->VO8_QTDITE , .t. })
			cTipAgr := VO8->VO8_TIPAGR
		EndIf
		dbSelectArea("VO8")
		dbSkip()
	EndDo
	If Len(aAgrSerList) == 0
		Return
	EndIF
	aIteRelAgru := FG_ITEREL(M->VS1_TIPTEM,aAgrSerList[1,2],aAgrSerList[1,3],"M->VS1_FORMUL")
	
	oFonte   := TFont():New( "Arial", 6, 10 )
	cFormula := M->VS1_FORMUL
	cFormAnt := cFormula
	VEG->(dbSeek(xFilial("VEG")+cFormula))
	cFormDes := VEG->VEG_DESCRI
	
	nOpca := 0
	DEFINE MSDIALOG oDlgAgruSer TITLE STR0256 From 08,25 to 31,98   of oMainWnd
	
	@ 001,001 SAY STR0257 OF oDlgAgruSer PIXEL COLOR CLR_BLACK FONT oFnt4
	
	@ 008,001 LISTBOX oLbAgruSer FIELDS HEADER   OemToAnsi(STR0258),;
	OemToAnsi(STR0013),;
	OemToAnsi(STR0014),;
	OemToAnsi(STR0015),;
	OemToAnsi(STR0016);
	COLSIZES 20,30,50,120,30;
	SIZE 288,75 OF oDlgAgruSer ON CHANGE (FS_ITERELAGRU(oLbAgruSer:nAt))  PIXEL
	
	oLbAgruSer:SetArray(aAgrSerList)
	oLbAgruSer:bLine := { || { aAgrSerList[oLbAgruSer:nAt,1] ,;
	aAgrSerList[oLbAgruSer:nAt,2] ,;
	aAgrSerList[oLbAgruSer:nAt,3] ,;
	aAgrSerList[oLbAgruSer:nAt,4] ,;
	Transform(aAgrSerList[oLbAgruSer:nAt,5],"@E 999,999") }}
	
	
	@ 087,001 SAY STR0259 OF oDlgAgruSer PIXEL COLOR CLR_BLACK FONT oFnt4
	
	@ 095,001 LISTBOX oLbIteRelAgru FIELDS HEADER OemToAnsi(STR0013),;    // Grupo
	OemToAnsi(STR0014),;    // Codigo do Item
	OemToAnsi(STR0015),;    // Descricao
	OemToAnsi(STR0016),;    // Quantidade
	OemToAnsi(STR0017);     // Valor
	COLSIZES 20,40,80,40,40;
	SIZE 288,060 OF oDlgAgruSer ON DBLCLICK (if(!Empty(aIteRelAgru[oLbIteRelAgru:nAt,1]).and.!Empty(aIteRelAgru[oLbIteRelAgru:nAt,2]),FS_MUDARELAGRU(oLbIteRelAgru:nAt),.t.),oLbIteRelAgru:Refresh()) PIXEL
	
	oLbIteRelAgru:SetArray(aIteRelAgru)
	oLbIteRelAgru:bLine := { || { aIteRelAgru[oLbIteRelAgru:nAt,1],;
	aIteRelAgru[oLbIteRelAgru:nAt,2],;
	aIteRelAgru[oLbIteRelAgru:nAt,3],;
	FG_AlinVlrs(Transform(aIteRelAgru[oLbIteRelAgru:nAt,4],"@E 999,999")),;
	FG_AlinVlrs(Transform(aIteRelAgru[oLbIteRelAgru:nAt,5],"@E 999,999,999.99"))}}
	
	@ 160,005 SAY STR0260 OF oDlgAgruSer PIXEL COLOR CLR_BLACK
	@ 160,035 MSGET oFormula VAR cFormAnt PICTURE "@!" VALID IIf(VEG->(dbSeek(xFilial("VEG")+cFormAnt)),(cFormDes:=VEG->VEG_DESCRI),.f.) F3 "VEG" SIZE 25,4 OF oDlgAgruSer PIXEL COLOR CLR_BLACK
	@ 160,070 MSGET oDesFor  VAR cFormDes PICTURE "@!" SIZE 125,4 OF oDlgAgruSer PIXEL COLOR CLR_BLACK When .f.
	
	DEFINE SBUTTON oBotInc FROM 160,225 TYPE 1 ACTION (cFormula:=cFormAnt,nOpca := 1, oDlgAgruSer:End()) ENABLE OF oDlgAgruSer
	oBotInc:cToolTip := OemtoAnsi(STR0261)
	DEFINE SBUTTON FROM 160,255 TYPE 2 ACTION (nOpca := 2, oDlgAgruSer:End()) ENABLE OF oDlgAgruSer
	
	ACTIVATE MSDIALOG oDlgAgruSer ON INIT oBotInc:SetFocus()
	
	Asort(aAgrupSer,1,,{|x,y| x[1] == y[1] })
	
	nAnt := n
	
	if nOpca == 1
		
		For ix_ := 1 to Len(aAgrSerList)
			
			M->VS3_FORMUL := cFormula := cFormAnt
			
			lIgual := .f.
			if !Empty(aColsP[Len(aColsP),1]) .and. !Empty(aColsP[Len(aColsP),2])
				For xx:=1 to Len(aColsP)
					if (aColsP[xx,FG_POSVAR("VS3_GRUITE","aHeaderP")] == aAGrSerList[ix_,2]) .and. (aColsP[xx,FG_POSVAR("VS3_CODITE","aHeaderP")] == aAGrSerList[ix_,3])
						lIgual := .t.
						Exit
					Endif
				Next
				if !lIgual
					AADD(aColsP,Array(nUsadoP+1))
				Endif
			Endif
			
			If Empty(aColsP[Len(aColsP),FG_POSVAR("VS3_GRUITE","aHeaderP")])
				For _ni:=1 to nUsadoP
					aColsP[Len(aColsP),_ni]:=CriaVar(aHeaderP[_ni,2])
				Next
			EndIf
			
			n := Len(aColsP)
			
			if !lIgual
				aColsP[Len(aColsP),FG_POSVAR("VS3_SEQUEN","aHeaderP")] := StrZero(Len(aColsP),3)
				aColsP[Len(aColsP),FG_POSVAR("VS3_GRUITE","aHeaderP")] := aAGrSerList[ix_,2]
				aColsP[Len(aColsP),FG_POSVAR("VS3_CODITE","aHeaderP")] := aAGrSerList[ix_,3]
				aColsP[Len(aColsP),FG_POSVAR("VS3_DESITE","aHeaderP")] := aAGrSerList[ix_,4]
			Endif
			
			aColsP[Len(aColsP),FG_POSVAR("VS3_QTDITE","aHeaderP")] := aColsP[Len(aColsP),FG_POSVAR("VS3_QTDITE","aHeaderP")] + aAGrSerList[ix_,5]
			aColsP[Len(aColsP),Len(aColsP[Len(aColsP)])] := .f.
			
			cKey := aColsP[Len(aColsP),FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[Len(aColsP),FG_POSVAR("VS3_CODITE","aHeaderP")]
			FG_Seek("SB1","cKey",7,.f.)
			
			MaFisRef("IT_PRODUTO","VS300",SB1->B1_COD)
			
			//			if cOpeMov2 == "2"
			//				if Empty(M->VS3_FORMUL)
			//					M->VS3_FORMUL := GETMV("MV_FMLPECA")
			//					if Type("M->VS3_FORMUL") <> "C"
			//						M->VS3_FORMUL := ""
			//					Endif
			//					M->VS3_FORMUL := cFormula
			//				Endif
			//			Endif
			aColsP[Len(aColsP),FG_POSVAR("VS3_FORMUL","aHeaderP")] := M->VS3_FORMUL
			nValPec := FG_VALPEC(M->VS1_TIPTEM,"M->VS3_FORMUL",aColsP[Len(aColsP),FG_POSVAR("VS3_GRUITE","aHeaderP")],aColsP[Len(aColsP),FG_POSVAR("VS3_CODITE","aHeaderP")],"M->VS3_VALPEC",.f.,.t.)
			
			aColsP[Len(aColsP),FG_POSVAR("VS3_PERDES","aHeaderP")] := M->VS1_PERPEC
			aColsP[Len(aColsP),FG_POSVAR("VS3_VALDES","aHeaderP")] := ((nValPec * aColsP[Len(aColsP),FG_POSVAR("VS3_QTDITE","aHeaderP")]) / 100) * aColsP[Len(aColsP),FG_POSVAR("VS3_PERDES","aHeaderP")]
			aColsP[Len(aColsP),FG_POSVAR("VS3_VALTOT","aHeaderP")] := (nValPec * aColsP[Len(aColsP),FG_POSVAR("VS3_QTDITE","aHeaderP")])-aColsP[Len(aColsP),FG_POSVAR("VS3_VALDES","aHeaderP")]
			aColsP[Len(aColsP),FG_POSVAR("VS3_VALPEC","aHeaderP")] := nValPec
			
			MaFisRef("IT_VALMERC","VS300",aColsP[Len(aColsP),FG_POSVAR("VS3_QTDITE","aHeaderP")]*nValPec)
			
			aColsP[Len(aColsP),FG_POSVAR("VS3_CODTES","aHeaderP")] := FS_TES(Len(aColsP))
			If (cPaisLoc == "BRA") // Manoel - 07/05/2009
				aColsP[Len(aColsP),FG_POSVAR("VS3_VBAICM","aHeaderP")] := MaFisRet(Len(aColsP),"IT_BASEICM")
				aColsP[Len(aColsP),FG_POSVAR("VS3_ALIICM","aHeaderP")] := MaFisRet(Len(aColsP),"IT_ALIQICM")
				aColsP[Len(aColsP),FG_POSVAR("VS3_ICMCAL","aHeaderP")] := MaFisRet(Len(aColsP),"IT_VALICM")
			Endif
		Next
		
	Endif
	
	M->VS1_VTOTNF := MaFisRet(,"NF_TOTAL")-MaFisRet(,"NF_DESCZF")
	M->VS1_VALDES := MaFisRet(,"NF_DESCONTO")
	M->VS1_ICMCAL := MaFisRet(,"NF_VALICM")
	M->VS1_DESACE := MaFisRet(,"NF_DESPESA")
	
	nOpca := 0
	
	nTotPec := 0
	nTotOrc := 0
	nTotDes := 0
	nTotTit := 0
	nBrinde := 0
	
	For i:=1 to Len(aColsP)
		if aColsP[i,Len(acolsP[i])] == .t.
			Loop
		Endif
		nTotPec += aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
		nTotOrc += aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
		nTotDes += aColsP[i,FG_POSVAR("VS3_VALDES","aHeaderP")]
		if TipoTes(aColsP[i,FG_POSVAR("VS3_CODTES","aHeaderP")])
			nTotTit += aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
			//if SF4->F4_INCSOL == "S"
			//   nTotTit += MaFisRet(i,"IT_VALSOL")
			//Endif
		Else
			nBrinde += aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
		Endif
	Next
	
	nTotTit -= nTotCre
	
	oTotDes:refresh()
	oTotPec:refresh()
	oTotOrc:refresh()
	
	n := nAnt
	FS_FORMUL()
	
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_ITERELAGRU| Autor ³ ANDRE              ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Insere Pecas do Servico Agrupado                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Codigo do Servico                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ITERELAGRU(nLin)

aIteRelAgru := FG_ITEREL(M->VS1_TIPTEM,aAgrSerList[nLin,2],aAgrSerList[nLin,3],"M->VS1_FORMUL")
If len(aIteRelAgru) <= 0
	aIteRelAgru := {{"","","",0,0}}
EndIf
oLbIteRelAgru:nAt := 1
oLbIteRelAgru:SetArray(aIteRelAgru)
oLbIteRelAgru:bLine := { || { aIteRelAgru[oLbIteRelAgru:nAt,1] ,;
aIteRelAgru[oLbIteRelAgru:nAt,2] ,;
aIteRelAgru[oLbIteRelAgru:nAt,3] ,;
FG_AlinVlrs(Transform(aIteRelAgru[oLbIteRelAgru:nAt,4],"@E 999,999")),;
FG_AlinVlrs(Transform(aIteRelAgru[oLbIteRelAgru:nAt,5],"@E 999,999,999.99"))}}
if lVez
	oLbIteRelAgru:Refresh()
Else
	lVez := .t.
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_MUDARELAGRU|Autor³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cancela o Orcamento                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MUDARELAGRU(nLin)

aAgrSerList[oLbAgruSer:nAt,2] := aIteRelAgru[oLbIteRelAgru:nAt,1]
aAgrSerList[oLbAgruSer:nAt,3] := aIteRelAgru[oLbIteRelAgru:nAt,2]
aAgrSerList[oLbAgruSer:nAt,4] := aIteRelAgru[oLbIteRelAgru:nAt,3]

oLbAgruSer:SetArray(aAgrSerList)
oLbAgruSer:bLine := { || { aAgrSerList[oLbAgruSer:nAt,1],;
aAgrSerList[oLbAgruSer:nAt,2],;
aAgrSerList[oLbAgruSer:nAt,3],;
aAgrSerList[oLbAgruSer:nAt,4],;
Transform(aAgrSerList[oLbAgruSer:nAt,5],"@E 9,999,999.99")}}

oLbAgruSer:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_MUDAFLD2 ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Muda o Foco da GetDados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MUDAFLD2()

if oFolder2:nOption == 1
	aHeader := aClone(aHeaderP)
	aCols   := aClone(aColsP)
	n := nP
Else
	aHeader := aClone(aHeaderS)
	aCols   := aClone(aColsS)
	n := nS
	oGetSrvcs:oBrowse:Refresh()
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_SEQAUTO  ³ Autor ³ ANDRE               ³ Data ³ 31/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Muda o Foco da GetDados                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³"P" = Pecas   /    "S" = Servicos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SEQAUTO(cPecSer)

Local nSeq
Local xi_:=0

if cPecSer == "P"
	// Verifica Integridade da Sequencia
	nPos := 1
	nSeq := StrZero(n,3)
	if Empty(aColsP[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")])
		While nPos > 0
			nPos := aScan(aCols,{|x| x[1] == nSeq })
			if nPos > 0
				nSeq := StrZero(val(nSeq)+=1,3)
				FG_MEMVAR()
			Else
				Exit
			Endif
		EndDo
	Endif
	if Empty(aCols[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")])
		aCols[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")] := nSeq
	Endif
	oGetPecas:oBrowse:Refresh()
Else
	// Verifica Integridade da Sequencia
	nPos := 1
	nSeq := StrZero(n,3)
	While nPos > 0
		nPos := aScan(aCols,{|x| x[1] == nSeq })
		if nPos > 0
			nSeq := StrZero(val(nSeq)+=1,3)
			FG_MEMVAR()
		Else
			Exit
		Endif
	EndDo
	
	if Empty(aCols[n,FG_POSVAR("VS4_SEQUEN","aHeaderS")])
		aCols[n,FG_POSVAR("VS4_SEQUEN","aHeaderS")] := nSeq
	Endif
	oGetSrvcs:oBrowse:Refresh()
Endif

For xi_:=1 to Len(aColsP)
	if xi_ <= Len(aIteRes)
		if alltrim(aIteRes[xi_,1]) <> alltrim(aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")]) .or. ;
			alltrim(aIteRes[xi_,2]) <> alltrim(aColsP[xi_,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[xi_,FG_POSVAR("VS3_CODITE","aHeaderP")])
			
			aIteRes[xi_,1] := aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")]
			aIteRes[xi_,2] := aColsP[xi_,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[xi_,FG_POSVAR("VS3_CODITE","aHeaderP")]
		Endif
	Else
		aadd(aIteRes,{aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")],aColsP[xi_,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[xi_,FG_POSVAR("VS3_CODITE","aHeaderP")],0 })
	Endif
Next

For xi_:=1 to Len(aColsP)
	if xi_ <= Len(aIteBlq)
		if alltrim(aIteBlq[xi_,1]) <> alltrim(aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")]) .or. ;
			alltrim(aIteBlq[xi_,2]) <> alltrim(aColsP[xi_,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[xi_,FG_POSVAR("VS3_CODITE","aHeaderP")])
			
			aIteBlq[xi_,1] := aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")]
		Endif
	Else
		aadd(aIteBlq,{aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")],"N","N","N"})
	Endif
Next

Return( nSeq )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_RATEIO110³ Autor ³ ANDRE               ³ Data ³ 31/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Faz Rateio do Desconto dado no CDCI                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³"P" = Pecas   /    "S" = Servicos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_RATEIO110(nValorCom,aParcelas,nDesconto)

Local i:=0,y, x:=0
Local nPerIte    := 0
Local nValDesc   := 0
Local aColsSlv   := {}
Local aHeaderSlv := {}

if Len(aColsAnt) = 0
	aColsAnt := aClone(aColsP)
Else
	aColsP   := aClone(aColsAnt)
Endif

aColsSlv   := aClone(aCols)
aHeaderSlv := aCLone(aHeader)

aCols      := aClone(aColsP)
aHeader    := aCLone(aHeaderP)
nValResto  := nDesconto

if nDesconto > 0
	nMaiorValor :=0
	For i:=1 to Len(aColsP)
		if !TipoTes(aColsP[i,FG_POSVAR("VS3_CODTES","aHeaderP")])
			Loop
		Endif
		n := i
		
		M->VS3_VALPEC := aColsP[i,fg_posvar("VS3_VALPEC","aHeaderP")]
		M->VS3_QTDITE := aColsP[i,fg_posvar("VS3_QTDITE","aHeaderP")]
		M->VS3_VALTOT := aColsP[i,fg_posvar("VS3_VALTOT","aHeaderP")]
		
		nPerIte  := (M->VS3_VALTOT / nTotOrc) * 100
		nValDesc := (nDesconto / 100) * nPerIte
		
		if nValResto = 0
			nValDesc := 0
		Elseif nValResto < nValDesc
			nValDesc  := nValResto
			nValResto := 0
		Endif
		
		aColsP[i,fg_posvar("VS3_VALDES","aHeaderP")] += nValDesc
		M->VS3_VALDES := aColsP[i,fg_posvar("VS3_VALDES","aHeaderP")]
		aColsP[i,FG_POSVAR("VS3_PERDES","aHeaderP")] := (M->VS3_VALDES / (M->VS3_VALPEC * M->VS3_QTDITE)) * 100
		aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")] := (M->VS3_VALPEC * M->VS3_QTDITE ) - M->VS3_VALDES
		
		if nValResto > 0
			nValResto -= nValDesc
			if aColsP[i,fg_posvar("VS3_VALTOT","aHeaderP")] > nMaiorValor
				nMaiorValor := aColsP[i,fg_posvar("VS3_VALTOT","aHeaderP")]
				y := i
			Endif
		Endif
		
		nTotDes += nValDesc
		nTotOrc -= nValDesc
		
		MaFisRef("IT_DESCONTO","VS300",M->VS3_VALDES)
		
	Next
	
	// Valor a Financiar - Entrada
	nValEnt := 0
	For x:=1 to Len(aColsC)
		if !aColsC[x,Len(aColsC[x])] .and. !Empty(aColsC[x,1])
			nValEnt := nValEnt + aColsC[x,FG_POSVAR("VS9_VALPAG","aHeaderC")]
		Endif
	Next
	
	nVlCal := 0
	For i:=1 to Len(aParcelas)
		nVlCal := nVlCal + aParcelas[i,2]
	Next
	
	nVlDif := nValorCom - (nVlCal+nValEnt)
	aParcelas[Len(aParcelas),2] := aParcelas[Len(aParcelas),2] + nVlDif
	
	aIteParc := aClone(aParcelas)
	
	// Refaz o ListBox das Parcelas
	oLbParc:SetArray(aIteParc)
	oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
	Transform(aIteParc[oLbParc:nAt,2],"@E 999,999,999.99")}}
	oLbParc:Refresh()
	
	// Atualiza aCols de Pecas
	aCols   := aClone(aColsP)
	aHeader := aClone(aHeaderP)
	n:= nP
	oGetPecas:oBrowse:refresh()
	
	oTotOrc:Refresh()
	oTotDes:Refresh()
	
Endif
If Empty(cTipPag)
	If dbSeek(xFilial("SE4")+RetCondVei())
		cTipPag := RetCondVei()
		cDesPag := SE4->E4_DESCRI
	Endif
Else
	If dbSeek(xFilial("SE4")+ctipPag)
		cDesPag := SE4->E4_DESCRI
	EndIF
endif
M->VS1_FORPAG := cTipPag
M->VS1_DESFPG := cDesPag

dbSelectArea("SE4")
if dbSeek(xFilial("SE4")+cTipPag)
	cDesPag := SE4->E4_DESCRI
	M->VS1_FORPAG := cTipPag
	M->VS1_DESFPG := cDesPag
	if Inclui .and. !lJaGravou
		wRet := .t.
	Else
		dbSelectArea("VS1")
		if dbSeek(xFilial("VS1")+M->VS1_NUMORC)
			RecLock("VS1",.f.)
			VS1->VS1_FORPAG := cTipPag
			MsUnlock()
		Endif
	Endif
Else
	wRet := .f.
Endif

FS_MUDABCO()

FS_FINORC(Nil,.f.)

aCols   := aClone(aColsSlv)
aHeader := aCLone(aHeaderSlv)

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³DEMANDAFREQ ³ Autor ³ ANDRE               ³ Data ³ 31/07/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Calcula a Demanda e a Frequencia do Item                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Grupo / Codigo do Item                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DEMANDAFREQ()

Local aFreqDem := {}

dbSelectArea("SB1")
dbSetOrder(7)
if dbSeek(xFilial("SB1")+get_grupo+get_codite)
	dbSelectArea("SBL")
	dbSeek(xFilial("SBL")+SB1->B1_COD)
	Do while !EOF() .and. SBL->BL_FILIAL == xFilial("SBL") .and. SBL->BL_PRODUTO == SB1->B1_COD
		aadd(aFreqDem,{BL_MES,BL_ANO,BL_DEMANDA,BL_FREQUENCIA})
		dbSkip()
	Enddo
	
	if len(aFreqDem) == 0
		aadd(aFreqDem,{"","",0,0})
	Endif
	
	DEFINE MSDIALOG yDlg TITLE STR0262 From 10,20 to 29,70 of oMainWnd
	
	@ 012, 001 LISTBOX oLbHeady FIELDS HEADER	OemToAnsi(STR0263),;
	OemToAnsi(STR0264),;
	OemToAnsi(STR0265),;
	OemToAnsi(STR0266);
	COLSIZES 30,30,60,60;
	SIZE 197,131 OF yDlg PIXEL
	
	oLbHeady:SetArray(aFreqDem)
	oLbHeady:bLine := { || { aFreqDem[oLbHeady:nAt,1] ,;
	aFreqDem[oLbHeady:nAt,2] ,;
	aFreqDem[oLbHeady:nAt,3] ,;
	aFreqDem[oLbHeady:nAt,4] }}
	
	ACTIVATE MSDIALOG yDlg ON INIT (ENCHOICEBAR(yDlg,{|| yDlg:End()},{|| yDlg:End()}))
Else
	MsgInfo(STR0267,STR0148)
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |DESCRI110    |Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria um array com a descricao do Item de acordo c/ filtro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DESCRI110(nOpcao)
#IFDEF TOP
	Local cAliasSB1:= "AliasSB1"
#ELSE
	Local cAliasSB1:= "SB1"
#ENDIF
Local cQuery   := ""
Local nPesqAspa:= ""
Local cGruVei  := GetMv("MV_GRUVEI")+space(4-len(GetMv("MV_GRUVEI")))
Local cGruSrv  := left(GetNewPar("MV_GRUSRV","SRVC")+space(4),4)
Local nsaldo   := 0
Local cLocaliz := ""
Local cDesSQL  := ""
Local nOpca    := 0
Local bTroca   := { || stuff(get_descri,AT(",",get_descri),1,"%") }

default nOpcao := 2

if Select(cAliasSB1) > 0
	(cAliasSB1)->(dbCloseArea())
Endif

dbSelectArea("SB2")
dbSetOrder(1)

dbSelectArea("SB5")
dbSetOrder(1)

dbSelectArea("SB1")
dbSetOrder(3)

aArray := {}
if nOpcao == 2
	if !Empty(get_descri)
		cDesSQL := get_descri
		///// Retira do texto as ASPAS para frente (caso exista) /////
		nPesqAspa := AT("'",cDesSQL)
		If nPesqAspa > 0
			If nPesqAspa == 1
				cDesSQL := space(len(SB1->B1_DESC))
			Else // nPesqAspa > 1
				cDesSQL := Left(cDesSQL,nPesqAspa-1)
			EndIf
			get_descri := cDesSQL
		EndIf
		nPesqAspa := AT('"',cDesSQL)
		If nPesqAspa > 0
			If nPesqAspa == 1
				cDesSQL := space(len(SB1->B1_DESC))
			Else // nPesqAspa > 1
				cDesSQL := Left(cDesSQL,nPesqAspa-1)
			EndIf
			get_descri := cDesSQL
		EndIf
		//////////////////////////////////////////////////////////////
		while AT(",",cDesSQL) > 0
			cDesSQL := Eval(bTroca)
		enddo
		cQuery := "SELECT SB1.B1_COD , SB1.B1_GRUPO , SB1.B1_CODITE , SB1.B1_DESC , SB1.B1_LOCPAD FROM "+RetSqlName("SB1")+" SB1 "
		cQuery += "WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_DESC LIKE '%"+alltrim(cDesSQL)+"%' AND "
		cQuery += "SB1.B1_GRUPO<>'"+cGruVei+"' AND SB1.B1_GRUPO<>'"+cGruSrv+"' AND SB1.D_E_L_E_T_=' '"
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB1,.T.,.T.)
		Do While !( cAliasSB1 )->( Eof() )
			cLocaliz := ""
			if SB5->(dbSeek(xFilial("SB5")+(cAliasSB1)->B1_COD))
				cLocaliz := FM_PRODSBZ((cAliasSB1)->B1_COD,"SB5->B5_LOCALIZ")
				if ExistBlock("LOCAOM110")
					cLocaliz := ExecBlock("LOCAOM110",.f.,.f.,{(cAliasSB1)->B1_COD})
				Endif
			Endif
			nSaldo := 0
			if SB2->(dbSeek(xFilial("SB2")+(cAliasSB1)->B1_COD+(cAliasSB1)->B1_LOCPAD))
				nSaldo := SaldoSB2()
			Endif
			aAdd(aArray,{(cAliasSB1)->B1_DESC,(cAliasSB1)->B1_GRUPO,(cAliasSB1)->B1_CODITE,cLocaliz,nSaldo})
			dbSelectArea(cAliasSB1)
			dbSkip()
		Enddo
		(cAliasSB1)->(dbCloseArea())
	Endif
Else
	if !Empty(get_codite)
		dbSelectArea("SB1")
		dbSetOrder(7)
		dbSeek(xFilial("SB1")+get_grupo+get_codite,.t.)
		Do while !EOF() .and. B1_FILIAL == xFilial("SB1") .and. get_grupo = SB1->B1_GRUPO .and. alltrim(get_codite) == substr(SB1->B1_CODITE,1,len(alltrim(get_codite)))
			if SB1->B1_GRUPO <> cGruVei .and. SB1->B1_GRUPO <> cGruSrv
				cLocaliz := ""
				if SB5->(dbSeek(xFilial("SB5")+SB1->B1_COD))
					cLocaliz := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ")
					if ExistBlock("LOCAOM110")
						cLocaliz := ExecBlock("LOCAOM110",.f.,.f.,{SB1->B1_COD})
					Endif
				Endif
				nSaldo := 0
				if SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))
					nSaldo := SaldoSB2()
				Endif
				aAdd(aArray,{SB1->B1_DESC,SB1->B1_GRUPO,SB1->B1_CODITE,cLocaliz,nSaldo})
			Endif
			dbSelectArea("SB1")
			dbSkip()
		Enddo
	Endif
Endif
if Len(aArray) == 0
	If FG_POSSB1('Get_DESCRI','SB1->B1_DESC')
		get_CODINT := SB1->B1_COD
		Pesq110(4)
		Return(.t.)
	EndIf
	aArray := {{"","","","",0}}
Endif
nOpca := 0
DBSelectArea("SB1")
DBSetOrder(7)
DEFINE MSDIALOG oDlgPesD FROM 000,000 TO 032,080 TITLE STR0429 OF oMainWnd		//Pesquisa Descricao

@ 003,003 SAY (STR0378 +": "+get_descri) SIZE 300,08 OF oDlgPesD PIXEL COLOR CLR_RED 	//Filtro

@ 012,002 LISTBOX oLbDesc FIELDS HEADER  OemToAnsi(STR0139),;
OemToAnsi(STR0140),;
OemToAnsi(STR0141),;
OemToAnsi(STR0428),;//Local
OemToAnsi(STR0352); //Estoque
COLSIZES 90,20,50,50,50 SIZE 313,228 OF oDlgPesD ON DBLCLICK (nOpca:=1,DBSeek(xFilial("SB1")+aArray[oLbDesc:nAt,2]+aArray[oLbDesc:nAt,3]),Get_CODINT:=SB1->B1_COD,PESQ110(4),oDlgPesD:End()) PIXEL
oLbDesc:SetArray(aArray)
oLbDesc:bLine := { || { aArray[oLbDesc:nAt,1],;
aArray[oLbDesc:nAt,2],;
aArray[oLbDesc:nAt,3],;
aArray[oLbDesc:nAt,4],;
Transform(aArray[oLbDesc:nAt,5],"@E 9,999,999.99")}}

ACTIVATE MSDIALOG oDlgPesD CENTER // ON INIT (FG_EnchoiceBar(oDlgPesD,{|| nOpca := 1,FS_MUDAITE(oLbDesc:nAt),oDlgPesD:End()},{|| nOpca := 2,oDlgPesD:End()}))

Return(nOpca==1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_MUDAITE   |Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Muda Item da Consulta pelo Item relacionado                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_MUDAITE(nPos)

Local lRet := .t.

If Empty(aArray[nPos,2]) .and. Empty(aArray[nPos,3])
	Return .T.
Endif
get_grupo  := aArray[nPos,2]
get_codite := aArray[nPos,3]
dbSelectArea("SB1")
dbSetOrder(7)
if (lRet := dbSeek(xFilial("SB1")+get_grupo+get_codite))
	PESQ110()
Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VALFPG    |Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida forma de Pagamento                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALFPG(nTipo)

Local lRet := .t.
//Nao integra com o SIGALOJA  ou  integra com o SIGALOJA e o usuario selecionou NF

If (cPaisLoc == "BRA")
	If Substr(GetMv("MV_LOJAVEI",,"NNNNNN"),1,1) == "N" .or. ( Substr(GetMv("MV_LOJAVEI",,"NNNNNN"),1,1) == "S" .and. nCheck==1 )
		If nTipo == 1
			If Empty(cTipPag) .and. (Empty(cCondic3) .or. Empty(cCondic4))
				lRet := .f.
			Endif
		Else
			If SE4->(dbSeek(xFilial("SE4")+cTipPag))
				If AllTrim(SE4->E4_COND) # "0"
					If Empty(cCodBco)
						lRet := .f.
					Endif
				Endif
			Endif
		Endif
	EndIf
EndIf

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_FILTRAITEM|Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Filtra item na Consulta de Pecas                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FILTRAITEM(oWnd)

Private cFiltro
Private cIndSB1,cChave, aIteFilt,nIndex,oDlgFiltro,oLbFilt
dbSelectArea("SB1")
cFiltro := BuildExpr(,oWnd)

If !Empty(cFiltro)
	dbSelectarea("SB1")
	dbSetOrder(7)
	*** Deve ser utilizado uma IndRegua
	cIndSB1 := CriaTrab(Nil, .F.)
	cChave  := IndexKey()
	IndRegua("SB1",cIndSB1,cChave,,cFiltro,OemToAnsi(STR0273) )
	dbSelectArea("SB1")
	nIndex := RetIndex("SB1")
	dbSetOrder(nIndex+1)
	
	dbSelectarea("SB1")
	aIteFilt := {}
	dbSeek(xFilial("SB1"))
	Do While !EOF() .and. B1_FILIAL == xFilial("SB1")
		aadd(aIteFilt,{.f.,SB1->B1_GRUPO,SB1->B1_CODITE,SB1->B1_DESC,SB1->B1_UM,SB1->B1_QE,SB1->B1_PRV1,SB1->B1_LOCPAD})
		dbSkip()
	Enddo
	
	Private oOk := LoadBitmap( GetResources(), "LBOK" )
	Private oNo := LoadBitmap( GetResources(), "LBNO" )
	
	if Len(aIteFilt) == 0
		aIteFilt := {{.t.,"","","","","","",""}}
	Endif
	
	DEFINE MSDIALOG oDlgFiltro FROM  04,10 TO 39,90 TITLE cCadastro OF oMainWnd
	
	@ 013, 001 LISTBOX oLbFilt FIELDS HEADER	OemToAnsi(""),;
	OemToAnsi(STR0274),;    //"Grupo"
	OemToAnsi(STR0275),;    //"Codigo"
	OemToAnsi(STR0276),;  	//"Descricao"
	OemToAnsi(STR0277),;    //"Unidade de Medida"
	OemToAnsi(STR0278),;   	//"Quantidade Embalagem"
	OemToAnsi(STR0279),;    //"Preco"
	OemToAnsi(STR0280);     //"Local"
	COLSIZES 30,110,30,65,43,30,25,30;
	SIZE 315,251 OF oDlgFiltro PIXEL ON DBLCLICK (FS_INSFILTRO(oLbFilt:nAt))
	
	oLbFilt:SetArray(aIteFilt)
	oLbFilt:bLine := { || { IIF(aIteFilt[oLbFilt:nAt,1],oOk,oNo) ,;
	aIteFilt[oLbFilt:nAt,2] ,;
	aIteFilt[oLbFilt:nAt,3] ,;
	aIteFilt[oLbfilt:nAt,4] ,;
	aIteFilt[oLbFilt:nAt,5] ,;
	aIteFilt[oLbFilt:nAt,6] ,;
	aIteFilt[oLbFilt:nAt,7] ,;
	aIteFilt[oLbFilt:nAt,8] }}
	
	ACTIVATE MSDIALOG oDlgFiltro CENTER ON INIT (EnchoiceBar(oDlgFiltro,{|| FS_INSORCAMTO(),oDlgFiltro:End(),nLinha := oLbFilt:nAt},{|| oDlgFiltro:End()}))
Endif
dbSelectArea("SB1")
RetIndex()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_ADDFILTRO |Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Adiciona Filtro                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ADDFILTRO()

if Len(aCpoFiltro) > 1 .or. !Empty(aCpoFiltro[1,1])
	if !Empty(cAndOr)
		aadd(aCpoFiltro,{cAndOr,"",""})
	Else
		Return .f.
	Endif
Endif

if Len(aCpoFiltro) == 1 .and. Empty(aCpoFiltro[1,1])
	aCpoFiltro[1,1] := aArqNC[oArq1:nAt]
	aCpoFiltro[1,2] := cArq2
	aCpoFiltro[1,3] := cFiltro
Else
	aadd(aCpoFiltro,{aArqNC[oArq1:nAt],cArq2,cFiltro})
Endif

oLbF:SetArray(aCpoFiltro)
oLbF:bLine := { || { aCpoFiltro[oLbF:nAt,1] ,;
aCpoFiltro[oLbF:nAt,2] ,;
aCpoFiltro[oLbF:nAt,3] }}
oLbF:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_INSFILTRO |Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Insere Filtro                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_INSFILTRO(nLin)

get_grupo  := aIteFilt[nLin,2]
get_codite := aIteFilt[nLin,3]
PESQ110(2)

if aIteFilt[nLin,1]
	aIteFilt[nLin,1] := .f.
Else
	aIteFilt[nLin,1] := .t.
Endif

oLbFilt:SetArray(aIteFilt)
oLbFilt:bLine := { || { iif(aIteFilt[oLbFilt:nAt,1],oOk,oNo) ,;
aIteFilt[oLbFilt:nAt,2] ,;
aIteFilt[oLbFilt:nAt,3] ,;
aIteFilt[oLbfilt:nAt,4] ,;
aIteFilt[oLbFilt:nAt,5] ,;
aIteFilt[oLbFilt:nAt,6] ,;
aIteFilt[oLbFilt:nAt,7] ,;
aIteFilt[oLbFilt:nAt,8] }}

oLbFilt:Refresh()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_INSORCAMTO|Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Insere o item no Orcamento                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_INSORCAMTO()

Local nVez    := 0
Local nIns    := 0
Local lOk     := .f.

Local i:=0 , j:=0, _ni:=0

For i:=1 to Len(aIteFilt)
	if aIteFilt[i,1]
		nVez++
	Endif
Next

if nVez > 1
	
	if MsgYesNo(STR0281,STR0148)
		
		if !lJaPerg
			MsgInfo(STR0282,STR0148)
			Return .f.
		Endif
		
		aCols   := aClone(aColsP)
		aHeader := aClone(aHeaderP)
		
		For j:=1 to Len(aIteFilt)
			
			if !aIteFilt[j,1]
				Loop
			Endif
			
			get_grupo  := aIteFilt[j,2]
			get_codite := aIteFilt[j,3]
			PESQ110(2)
			
			if !Empty(M->VS1_CODMAR)
				if M->VS1_CODMAR # cCodMar
					MsgInfo(STR0283,STR0148)
					Loop
				Endif
			Endif
			
			For i:=1 to Len(aColsP)
				if (aCols[i,FG_POSVAR("VS3_GRUITE","aHeaderP")] == get_grupo) .and. (aCols[i,FG_POSVAR("VS3_CODITE","aHeaderP")] == get_codite).and. !aColsP[i,Len(aColsP[i])]
					MsgInfo(STR0284,STR0148)
					Loop
				Endif
			Next
			
			if !Empty(aColsP[Len(aColsP),FG_POSVAR("VS3_SEQUEN","aHeaderP")]) .and. !Empty(aColsP[Len(aColsP),FG_POSVAR("VS3_GRUITE","aHeaderP")]) .and. !Empty(aColsP[Len(aColsP),FG_POSVAR("VS3_CODITE","aHeaderP")])
				AADD(aColsP,Array(nUsadoP+1))
				aColsP[Len(aColsP),nUsadoP+1]:=.F.
				For _ni:=1 to nUsadoP
					aColsP[Len(aColsP),_ni]:=CriaVar(aHeaderP[_ni,2])
				Next
			Endif
			
			n := Len(aColsP)
			
			//Calcula o Preco da Peca
			wAlias := alias()
			
			FG_Seek("SB1","get_grupo+get_codite",7,.f.)
			MaFisRef("IT_PRODUTO","VS300",SB1->B1_COD)
			
			M->VS3_GRUITE := get_grupo
			M->VS3_CODITE := get_codite
			
			//			aColsP[Len(aColsP),FG_POSVAR("VS3_SEQUEN","aHeaderP")] := StrZero(n,3)
			aColsP[Len(aColsP),FG_POSVAR("VS3_GRUITE","aHeaderP")] := get_grupo
			aColsP[Len(aColsP),FG_POSVAR("VS3_CODITE","aHeaderP")] := get_codite
			aColsP[Len(aColsP),FG_POSVAR("VS3_DESITE","aHeaderP")] := SB1->B1_DESC
			
			aCols   := aClone(aColsP)
			aHeader := aClone(aHeaderP)
			n := Len(aColsP)
			// verifica o reservado para orcamento aceito
			nSaldo  := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
			nPos := aScan(aIteBlq,{|x| x[1] == aCols[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
			FS_TRANSFER(nSaldo,1,nPos,aCols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")],.F.,n)
			
			if cOpeMov2 == "1"
				aColsP[Len(aColsP),FG_POSVAR("VS3_FORMUL","aHeaderP")] := M->VS1_FORMUL
				aColsP[Len(aColsP),FG_POSVAR("VS3_CODTES","aHeaderP")] := SB1->B1_TS
			Else
				aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")] := cTesPad
				M->VS3_CODTES := cTesPad
				if Empty(M->VS3_FORMUL)
					M->VS3_FORMUL := GETMV("MV_FMLPECA")
					if Type("M->VS3_FORMUL") <> "C"
						M->VS3_FORMUL := SPACE(LEN(VS3->VS3_FORMUL))
					Endif
				Endif
			Endif
			nValPec := FG_VALPEC(M->VS1_TIPTEM,"M->VS1_FORMUL",M->VS3_GRUITE,M->VS3_CODITE,"M->VS3_VALPEC",.f.,.t.)
			
			dbSelectArea(wALias)
			
			//Quantidade inicial igual a 1
			aColsP[Len(aColsP),FG_POSVAR("VS3_QTDITE","aHeaderP")] := 1
			aColsP[Len(aColsP),FG_POSVAR("VS3_VALPEC","aHeaderP")] := nValPec
			
			M->VS3_QTDITE := 1
			M->VS3_VALPEC := nValPec
			
			//Desconto padrao cadastrado no VS1
			if aColsP[Len(aColsP),FG_POSVAR("VS3_PERDES","aHeaderP")] == 0
				aColsP[Len(aColsP),FG_POSVAR("VS3_PERDES","aHeaderP")] := M->VS1_PERPEC
			Endif
			M->VS3_PERDES := aColsP[Len(aColsP),FG_POSVAR("VS3_PERDES","aHeaderP")]
			SBM->(dbSetOrder(1))
			SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
			FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,M->VS3_PERDES,,M->VS3_MODVEI)
			
			M->VS3_VALDES := ((M->VS3_VALPEC*M->VS3_QTDITE)/100)*M->VS3_PERDES
			M->VS3_VALTOT := (M->VS3_VALPEC*M->VS3_QTDITE)-M->VS3_VALDES
			
			aColsP[Len(aColsP),FG_POSVAR("VS3_VALTOT","aHeaderP")] := M->VS3_VALTOT
			aColsP[Len(aColsP),FG_POSVAR("VS3_VALDES","aHeaderP")] := M->VS3_VALDES
			
			MaFisRef("IT_VALMERC" ,"VS300",M->VS3_VALTOT+M->VS3_VALDES)
			MaFisRef("IT_TES","VS300",aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")])
			MaFisRef("IT_DESCONTO","VS300",M->VS3_VALDES)
			
			//aCols tem que estar igual ao aColsP por causa da funcao MaFisRet
			aCols   := aClone(aColsP)
			aHeader := aClone(aHeaderP)
			
			If (cPaisLoc == "BRA") // Manoel - 07/05/2009
				if cOpeMov2 == "1" .or. !Empty(cTesPad)
					aColsP[Len(aColsP),fg_posvar("VS3_VBAICM","aHeaderP")] := MaFisRet(Len(aColsP),"IT_BASEICM")
					aColsP[Len(aColsP),fg_posvar("VS3_ALIICM","aHeaderP")] := MaFisRet(Len(aColsP),"IT_ALIQICM")
					aColsP[Len(aColsP),fg_posvar("VS3_ICMCAL","aHeaderP")] := MaFisRet(Len(aColsP),"IT_VALICM")
					FpRefresh()
				Endif
			Endif
			aCols   := aClone(aColsP)
			aHeader := aClone(aHeaderP)
			
			FS_ITEREL110()
			
			nTotPec := 0
			nTotOrc := 0
			nTotDes := 0
			nTotTit := 0
			nBrinde := 0
			
			For i:=1 to Len(aCols)
				if !aCols[i,Len(acols[i])]
					nTotPec += aCols[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
					nTotOrc += aCols[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
					nTotDes += aCols[i,FG_POSVAR("VS3_VALDES","aHeaderP")]
					if TipoTes(aCols[i,FG_POSVAR("VS3_CODTES","aHeaderP")])
						nTotTit += aCols[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
						//if SF4->F4_INCSOL == "S"
						//   nTotTit += MaFisRet(i,"IT_VALSOL")
						//Endif
					Else
						nBrinde += aCols[i,FG_POSVAR("VS3_VALTOT","aHeaderP")]
					Endif
				Endif
			Next
			
			nTotTit -= nTotCre
			
			oTotDes:refresh()
			oTotPec:refresh()
			oTotOrc:refresh()
			
			if aColsP[Len(aColsP),Len(aColsP[Len(aColsP)])]
				aColsP[Len(aColsP),Len(aColsP[Len(aColsP)])] := .f.
			Endif
			
			oGetPecas:oBrowse:refresh()
			
			FpRefresh()
			
			nIns++
			lOk := .t.
			
			if nIns = nVez
				Exit
			Endif
			
		Next
		if lOk
			MsgInfo(STR0285,STR0028)
		Endif
	Endif
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_TIPOTES  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica se o TES e de brind ou nao                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TipoTes(cTes)

Local lRet := .t.
Local cAlias := Alias()

dbSelectArea("SF4")
dbSetOrder(1)
if dbSeek(xFilial("SF4")+cTes)
	if (F4_ICM == "N" .or. F4_CREDICM == "N") .and. F4_ESTOQUE == "S" .and. F4_DUPLIC == "N"
		lRet := .f.
	Endif
Else
	lRet := .f.
Endif

dbSelectArea(cAlias)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_NOMEVEN  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Traz o nome do vendedor logado                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_NOMVEN()

Local cNome := " "

dbSelectArea("SA3")
dbSetOrder(1)
if dbSeek(xFilial("SA3")+VS1->VS1_CODVEN)
	cNome := SA3->A3_NOME
Endif
dbSelectarea("VS1")

Return(cNome)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VALSEQ   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria um array p/ ordenar os itens p/ validar na SaldoSB2()  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALSEQ()

Local lRet := .t.
Local nPos := 0
Local nPos2:= 0
Local nwnk := 0

If !aCols[n,Len(aCols[n])]
	For nwnk := 1 To Len(aCols)
		If nwnk==n .or. aCols[nwnk,Len(aCols[nwnk])]
			Loop
		Endif
		If aCols[nwnk,FG_POSVAR("VS3_SEQUEN","aHeaderP")] == M->VS3_SEQUEN
			Help(" ",1,"JAGRAVADO")
			Return (.f.)
		Endif
	Next
	nPos := aScan(aIteBlq,{|x| x[1] == aCols[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
	nPos2:= aScan(aIteRes,{|x| x[1] == aCols[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
	if nPos > 0
		aIteBlq[nPos,1] := M->VS3_SEQUEN
	Endif
	If nPos2 > 0
		aIteRes[nPos2,1] := M->VS3_SEQUEN
	Endif
Else
	Return(.F.)
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VALINTE  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Se o Orcamento for alterado pede p/ gravar                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALINTE()

if Left(Funname(),4) == "OFIX" .or. FunName() == "OFIOM350" .or. FunName() == "OFIOM430"  .or. FunName() == "M_CONSPEC"
	return .t.
endif


if ReadVar() == "M->VS1_CLIFAT"
	if SA1->A1_MSBLQL = "1"
		MsgInfo(STR0430 ,STR0148) //Cliente esta bloqueado! # Atencao!
		Return .f.
	Endif
Endif

lJaGravou := .f.

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_TRANALMO ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Trabsfere item p/ outro almoxarifado                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TRANALMO(nTipo,cProduto,nQtdade,nQtdeEst, cLocal)


Default cLocal := SB1->B1_LOCPAD

dbSelectArea("SB1")
dbSetOrder(7)
if dbSeek(xFilial("SB1")+cProduto)
	
	if nTipo == 1
		cLocalSai   := cLocal
		cLocalEnt   := GetMv("MV_RESITE")
	Else
		cLocalSai := GetMv("MV_RESITE")
		cLocalEnt := cLocal
	Endif
	
	//+---------------------------------------------------------------------+
	//¦Movimentacao interna do Item                                         ¦
	//+---------------------------------------------------------------------+
	aItensNew:={}
	
	dbSelectArea("SB5")
	dbSetOrder(1)
	dbSeek( xFilial("SB5") + SB1->B1_COD )
	
	if nTipo == 1
		cLocalizEnt := GetMv("MV_RESLOC")
		cLocalizSai := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ")
		if ExistBlock("LOCAOM110")
			cLocalizSai := ExecBlock("LOCAOM110",.f.,.f.,{SB1->B1_COD})
		Endif
	Else
		cLocalizEnt := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ")
		if ExistBlock("LOCAOM110")
			cLocalizEnt := ExecBlock("LOCAOM110",.f.,.f.,{SB1->B1_COD})
		Endif
		cLocalizSai := GetMv("MV_RESLOC")
	Endif
	cLocalizEnt := Alltrim(cLocalizEnt)
	cLocalizEnt += Space(TamSx3("B5_LOCALIZ")[1]-Len(cLocalizEnt))
	cLocalizSai := Alltrim(cLocalizSai)
	cLocalizSai += Space(TamSx3("B5_LOCALIZ")[1]-Len(cLocalizSai))
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	
	//
	// Adiciona cabecalho com numero do documento e data da transferencia modelo II
	//
	aadd (aItensNew,{ nextnumero("SD3",2,"D3_DOC",.t.), ddatabase})
	
	// sequencia
	// produto, descricao, unidade de medida, local/localizacao origem
	// produto, descricao, unidade de medida, local/localizacao destino
	// numero de serie, lote, sublote, data de validade, qunatidade
	// quantidade na 2 unidade, estorno, numero de sequencia
	//
	//
	
	aadd ( aItensNew,{ SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, cLocalSai , if(LOCALIZA(SB1->B1_COD),cLocalizSai,Space(15)),;
	SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, cLocalEnt , if(LOCALIZA(SB1->B1_COD),cLocalizEnt,Space(15)),;
	criavar('D3_NUMSERI'),criavar('D3_LOTECTL'), criavar('D3_NUMLOTE')    ,;
	criavar('D3_DTVALID'), nQtdeEst, nQtdeEst, criavar("D3_QTSEGUM")   ,;
	criavar("D3_ESTORNO"), criavar("D3_NUMSEQ"), criavar("D3_LOTECTL"), criavar("D3_DTVALID"), criavar("D3_ITEMGRD")} )
	lMsErroAuto	 := .F.
	
	MsExecAuto({|x| MATA261(x)},aItensNew)
	If lMsErroAuto
		DisarmTransaction()
		Break
	EndIf
	
	dbSelectArea("SB1")
	dbSetOrder(7)
	
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CALCVAL  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Restaura Calculos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CALCVAL(lGrava,lPeca)

Local i:=0

if Left(Funname(),4) == "OFIX" .or. FunName() == "OFIOM350" .or. FunName() == "OFIOM430" .or. FunName() == "M_CONSPEC"
	return .t.
endif

Private cProdAFS := "" // Produto: Acessorio/Frete/Seguro
Private cCodTAFS := "" // TES: Acessorio/Frete/Seguro
If ReadVar() == "M->VS1_DESACE" // Valida Item referente a Despesa Acessoria.
	If M->VS1_DESACE > 0
		cProdAFS := GetNewPar("MV_PRDESAC","")
		If !Empty(cProdAFS)
			If !FG_Seek("SB1","cProdAFS",1,.f.) // ITEM
				MsgStop("Produto '"+cProdAFS+"' informado no parametro 'MV_PRDESAC' nao esta cadastrado! Impossivel continuar.","Atencao")
				Return .f.
			Else
				cCodTAFS := GetNewPar("MV_TESDACE","")
				If Empty(cCodTAFS)
					MsgStop("Nao existe TES no parametro 'MV_TESDACE'! Impossivel continuar.","Atencao")
					Return .f.
				Else
					If !FG_Seek("SF4","cCodTAFS",1,.f.) //TES
						MsgStop("TES '"+cCodTAFS+"' informado no parametro 'MV_TESDACE' nao esta cadastrado! Impossivel continuar.","Atencao")
						Return .f.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
ElseIf ReadVar() == "M->VS1_VALFRE" // Valida Item referente ao Frete.
	If M->VS1_VALFRE > 0
		cProdAFS := GetNewPar("MV_PRFRETE","")
		If !Empty(cProdAFS)
			If !FG_Seek("SB1","cProdAFS",1,.f.) // ITEM
				MsgStop("Produto '"+cProdAFS+"' informado no parametro 'MV_PRFRETE' nao esta cadastrado! Impossivel continuar.","Atencao")
				Return .f.
			Else
				cCodTAFS := GetNewPar("MV_TESFRET","")
				If Empty(cCodTAFS)
					MsgStop("Nao existe TES no parametro 'MV_TESFRET'! Impossivel continuar.","Atencao")
					Return .f.
				Else
					If !FG_Seek("SF4","cCodTAFS",1,.f.) //TES
						MsgStop("TES '"+cCodTAFS+"' informado no parametro 'MV_TESFRET' nao esta cadastrado! Impossivel continuar.","Atencao")
						Return .f.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
ElseIf ReadVar() == "M->VS1_VALSEG" // Valida Item referente ao Seguro.
	If M->VS1_VALSEG > 0
		cProdAFS := GetNewPar("MV_PRSEGUR","")
		If !Empty(cProdAFS)
			If !FG_Seek("SB1","cProdAFS",1,.f.) // ITEM
				MsgStop("Produto '"+cProdAFS+"' informado no parametro 'MV_PRSEGUR' nao esta cadastrado! Impossivel continuar.","Atencao")
				Return .f.
			Else
				cCodTAFS := GetNewPar("MV_TESSEGU","")
				If Empty(cCodTAFS)
					MsgStop("Nao existe TES no parametro 'MV_TESSEGU'! Impossivel continuar.","Atencao")
					Return .f.
				Else
					If !FG_Seek("SF4","cCodTAFS",1,.f.) //TES
						MsgStop("TES '"+cCodTAFS+"' informado no parametro 'MV_TESSEGU' nao esta cadastrado! Impossivel continuar.","Atencao")
						Return .f.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

if lPeca == Nil
	lPeca := .t.
Endif

if oFolder:nOption == 2
	if oFolder2:nOption == 1
		If left(aHeader[2,2],3) == "VS3"
			aHeaderP := aClone(aHeader)
			aColsP   := aClone(aCols)
			If aColsP[n,Len(aColsP[n])]
				n := 1
			EndIf
			nP := n
			oGetPecas:oBrowse:refresh()
			oGetPecas:oBrowse:setfocus()
		Endif
	Else
		If left(aHeader[2,2],3) == "VS4"
			aHeaderS := aClone(aHeader)
			aColsS   := aClone(aCols)
			If aColsS[n,Len(aColsS[n])]
				n := 1
			EndIf
			nS := n
			oGetSrvcs:oBrowse:refresh()
			oGetSrvcs:oBrowse:setfocus()
		Endif
	Endif
Elseif oFolder:nOption == 3
	If left(aHeader[2,2],3) == "VS9"
		aHeaderC := aClone(aHeader)
		aColsC   := aClone(aCols)
		If aColsC[n,Len(aColsC[n])]
			n := 1
		EndIf
		nC := n
		oGetCondicao:oBrowse:refresh()
		oGetCondicao:oBrowse:setfocus()
	Endif
Endif

if lGrava # Nil .and. lGrava == "S"
	if !FS_FINORC(Nil,.f.)
		Return (.f.)
	Endif
	RecLock("VS1",.f.)
	If MaFisFound('NF')
		M->VS1_VTOTNF := MaFisRet(,"NF_TOTAL")-MaFisRet(,"NF_DESCZF")
		M->VS1_VALDES := MaFisRet(,"NF_DESCONTO")
		M->VS1_ICMCAL := MaFisRet(,"NF_VALICM")
		M->VS1_DESACE := MaFisRet(,"NF_DESPESA")
	Endif
	MsUnlock()
Endif

nTotPec := 0
nTotSrv := 0
nTotOrc := 0
nTotDes := 0
nTotTit := 0
nBrinde := 0

For i:=1 to Len(aColsP)
	if aColsP[i,Len(aColsP[i])]
		Loop
	Endif
	If (GetMV("MV_ARREFAT")=="S")
		nTotPec += Round(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
		nTotOrc += Round(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
		nTotDes += Round(val(Transform(aColsP[i,FG_POSVAR("VS3_VALDES","aHeaderP")],"999999.99")),2)
		if TipoTes(aColsP[i,FG_POSVAR("VS3_CODTES","aHeaderP")])
			nTotTit += Round(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
			//if SF4->F4_INCSOL == "S"
			//   nTotTit += MaFisRet(i,"IT_VALSOL")
			//Endif
		Else
			nBrinde += Round(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
		Endif
	Else
		nTotPec += NoRound(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
		nTotOrc += NoRound(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
		nTotDes += NoRound(val(Transform(aColsP[i,FG_POSVAR("VS3_VALDES","aHeaderP")],"999999.99")),2)
		if TipoTes(aColsP[i,FG_POSVAR("VS3_CODTES","aHeaderP")])
			nTotTit += NoRound(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
			//if SF4->F4_INCSOL == "S"
			//   nTotTit += MaFisRet(i,"IT_VALSOL")
			//Endif
		Else
			nBrinde += NoRound(val(Transform(aColsP[i,FG_POSVAR("VS3_VALTOT","aHeaderP")],"999999.99")),2)
		Endif
	Endif
Next

if lPeca
	if !aCols[n,Len(acols[n])] .and. M->VS3_QTDITE > 0 .And. fg_posvar("VS3_CODTES","aHeader") # 0
		if !Empty(aCols[n,fg_posvar("VS3_CODTES","aHeaderP")]) .or. !Empty(M->VS3_CODTES)
			if !aCols[n,Len(aCols[n])]
				If (cPaisLoc == "BRA") // Manoel - 07/05/2009
					aCols[n,fg_posvar("VS3_VBAICM","aHeaderP")] := MaFisRet(n,"IT_BASEICM")
					aCols[n,fg_posvar("VS3_ALIICM","aHeaderP")] := MaFisRet(n,"IT_ALIQICM")
					aCols[n,fg_posvar("VS3_ICMCAL","aHeaderP")] := MaFisRet(n,"IT_VALICM")
				Endif
			Else
				MaFisRef("IT_VALMERC","VS300",0)
				MaFisRef("IT_TES","VS300",aCols[n,FG_POSVAR("VS3_CODTES","aHeaderP")])
				MaFisRef("IT_DESCONTO","VS300",0)
			Endif
		Endif
	Endif
	
	if !Empty(SB1->B1_GRTRIB)
		MaFisAlt("IT_GRPTRIB",SB1->B1_GRTRIB,n)
	Endif
	
	if !Empty(SB1->B1_GRTRIB) .or. SB1->B1_PICMENT > 0
		if SB1->B1_PICMENT > 0
			nAliSol  := SB1->B1_PICMENT
			nBaseSol := aCols[n,fg_posvar("VS3_VALTOT","aHeaderP")]+((aCols[n,fg_posvar("VS3_VALTOT","aHeaderP")] *nAliSol)/100)
			MaFisAlt("IT_BASESOL",nBaseSol,n)
		Else
			dbSelectArea("SF7")
			dbSetOrder(1)
			if MsSeek(xFilial("SF7")+SB1->B1_GRTRIB+SA1->A1_GRPTRIB)
				while !EOF() .and. SF7->F7_GRTRIB == SB1->B1_GRTRIB
					if SF7->F7_GRPCLI == SA1->A1_GRPTRIB .and. SA1->A1_EST == SF7->F7_EST
						nBaseSol := aCols[n,fg_posvar("VS3_VALTOT","aHeaderP")]+((aCols[n,fg_posvar("VS3_VALTOT","aHeaderP")] *SF7->F7_MARGEM)/100)
						MaFisAlt("IT_BASESOL",nBaseSol,n)
						//MaFisAlt("IT_VALSOL",((nBaseSol*MaFisRet(n,"IT_ALIQICM"))/100)-MaFisRet(n,"IT_VALICM"),n)
					Endif
					dbSelectArea("SF7")
					dbSkip()
				enddo
			Endif
		Endif
	Else
		MaFisAlt("IT_BASESOL",0,n)
		MaFisAlt("IT_VALSOL",0,n)
	Endif
	if SF4->F4_INCSOL == "S" .and. !Empty(M->VS3_GRUITE) .and. !Empty(M->VS3_CODITE)
		aCols[n,fg_posvar("VS3_VICMSB","aHeaderP")] := MaFisRet(n,"IT_VALSOL")
	EndIf
	If MaFisFound('NF')
		M->VS1_VTOTNF := MaFisRet(,"NF_TOTAL")-MaFisRet(,"NF_DESCZF")
		M->VS1_VALDES := MaFisRet(,"NF_DESCONTO")
		M->VS1_ICMCAL := MaFisRet(,"NF_VALICM")
		M->VS1_DESACE := MaFisRet(,"NF_DESPESA")
	Endif
Endif

//Calculando Totais de Servicos
For i:=1 to Len(aColsS)
	if aColsS[i,Len(aColsS[i])]
		Loop
	Endif
	if GetMv("MV_ARREFAT") == "S"
		nTotDes += Round(val(Transform(aColsS[i,FG_POSVAR("VS4_VALDES","aHeaderS")],"999999.99")),2)
		nTotSrv += Round(val(Transform(aColsS[i,FG_POSVAR("VS4_VALTOT","aHeaderS")],"999999.99")),2)
		nTotOrc += Round(val(Transform(aColsS[i,FG_POSVAR("VS4_VALTOT","aHeaderS")],"999999.99")),2)
	Else
		nTotDes += NoRound(val(Transform(aColsS[i,FG_POSVAR("VS4_VALDES","aHeaderS")],"999999.99")),2)
		nTotSrv += NoRound(val(Transform(aColsS[i,FG_POSVAR("VS4_VALTOT","aHeaderS")],"999999.99")),2)
		nTotOrc += NoRound(val(Transform(aColsS[i,FG_POSVAR("VS4_VALTOT","aHeaderS")],"999999.99")),2)
	Endif
Next

nTotOrc += M->VS1_DESACE
nTotTit += M->VS1_DESACE

nTotOrc += M->VS1_VALFRE
nTotTit += M->VS1_VALFRE

nTotOrc += M->VS1_VALSEG
nTotTit += M->VS1_VALSEG

//nTotOrc := MaFisRet(,"NF_TOTAL")-MaFisRet(,"NF_DESCZF")   //FNC - 14803 - BOBY 04/08/10
nTotTit := nTotOrc - nTotCre                                //FNC - 14803 - BOBY 04/08/10
//nTotTit -= nTotCre 

oTotDes:refresh()
oTotPec:refresh()
oTotOrc:refresh()
oTotSrv:Refresh()

Return(.t.)


//////////////////
Function FS_PICT()

Local cPic := '@!%C'

if SBM->(dbSeek(xFilial("SBM")+get_grupo))
	if !Empty(SBM->BM_PICPAD)
		cPic := SBM->BM_PICPAD+'%C'
	Endif
Endif

Return(cPic)


////////////////////////
Function FS_VERBLQ(nPos)

M->VS3_GRUITE := aCols[nPos,FG_POSVAR("VS3_GRUITE","aHeaderP")]
M->VS3_CODITE := aCols[nPos,FG_POSVAR("VS3_CODITE","aHeaderP")]
M->VS3_QTDITE := aCols[nPos,FG_POSVAR("VS3_QTDITE","aHeaderP")]

SB1->(dbSetOrder(7))
SB1->(dbSeek(xFilial("SB1")+M->VS3_GRUITE+M->VS3_CODITE))
SB2->(dbSetOrder(1))
SB2->(dbSeek(xFilial("SB1")+SB1->B1_COD+SB1->B1_LOCPAD))
nSaldo := SaldoSB2()
// verifica reserva para orcamento aceito
nPosi := aScan(aIteBlq,{|x| x[1] == aCols[nPos,FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
FS_TRANSFER(nSaldo,M->VS3_QTDITE,nPosi,aCols[nPos,FG_POSVAR("VS3_QTDITE","aHeaderP")],.F.,nPos)

Return


///////////////////////
Function FS_EDITLOCAL()

Local  nOpca   := 0
Local oNewIte, cNewIte := Space(45)
If Empty(get_grupo) .or. Empty(get_codite)
	Return
Endif
dbSelectArea("SB1")
dbSetOrder(7)
dbSeek(xFilial("SB1")+get_grupo+get_codite)
dbSelectArea("SB5")
dbSetOrder(1)
if dbSeek(xFilial("SB5")+SB1->B1_COD)
	cNewIte := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALIZ")
	if ExistBlock("LOCAOM110")
		cLocalizEnt := ExecBlock("LOCAOM110",.f.,.f.,{SB1->B1_COD})
	Endif
else
	cNewIte := Space(TamSx3("B5_LOCALIZ")[1])
endif

DEFINE MSDIALOG oDlgNew TITLE OemtoAnsi(STR0072) FROM  02,04 TO 7,28 OF oMainWnd 	// "Localizacao"

@ 002, 002 Say OemToAnsi(STR0431) SIZE 80,08 OF oDlgNew PIXEL COLOR CLR_BLUE	//Nova Localizacao
@ 010, 002 MSGET oNewIte  VAR cNewIte  PICTURE "@!" SIZE 90,08 OF oDlgNew PIXEL COLOR CLR_BLACK

@ 023, 002 BUTTON oOk  PROMPT OemToAnsi(STR0397) OF oDlgNew SIZE 43,11 PIXEL ACTION (nOpca := 1,oDlgNew:End())	//Confirma
@ 023, 048 BUTTON oNo  PROMPT OemToAnsi(STR0323)  OF oDlgNew SIZE 43,11 PIXEL ACTION (nOpca := 2,oDlgNew:End())	//Cancela

ACTIVATE MSDIALOG oDlgNew CENTER

if nOpca == 1
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+get_grupo+get_codite)
	dbSelectArea("SB5")
	dbSetOrder(1)
	if dbSeek(xFilial("SB5")+SB1->B1_COD)
		RecLock("SB5",.f.)
		Replace B5_LOCALIZ with cNewIte
		MsUnlock()
		get_LOCALIZ := B5_LOCALIZ
	Else
		RecLock("SB5",.t.)
		Replace B5_FILIAL  with xFilial("SB5")
		Replace B5_COD     with SB1->B1_COD
		Replace B5_LOCALIZ with cNewIte
		MsUnlock()
		get_LOCALIZ := B5_LOCALIZ
	Endif
	If ExistBlock("LOCALIZ")
		ExecBlock("LOCALIZ",.f.,.f.,{cNewIte})
	EndIf
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_AVRES2 ³Ricardo Farinelli           | Data ³  31/08/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Complemento da funcao de visualizacao do mapa de resultado  º±±
±±º          ³com a MSGRUN para dar um status ao usuario                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Gestao de Concessionarias                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AVRES2()
Local aPISCOF := {}
Local ix_ := 0
Local ii  := 0

dbSelectArea("TRB")
dbSetOrder(1)

For ix_:=1 to Len(aColsP)
	if Type("cOpeMov2") == "U"
		cOpeMov2 := VS1->VS1_NOROUT
	Endif
	
	if aColsP[ix_,Len(aColsP[ix_])]
		Loop
	Endif
	
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+aColsP[ix_,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[ix_,FG_POSVAR("VS3_CODITE","aHeaderP")])
	dbSelectArea("SB2")
	dbSeek(xFilial("SB2")+SB1->B1_COD+aColsP[ix_,FG_POSVAR("VS3_LOCAL","aHeaderP")])
	
	dbSelectarea("SF4")
	SF4->(dbSeek(xFilial("SF4")+aColsP[ix_,FG_POSVAR("VS3_CODTES","aHeaderP")]))
	
	aPisCof := CalcPisCofSai(aColsP[ix_,FG_POSVAR("VS3_VALTOT","aHeaderP")])
	
	dbSelectArea("TRB")
	
	RecLock("TRB",.t.)
	
	VEC_NUMORC := VS1->VS1_NUMORC
	VEC_NUMREL := GetSXENum("VEC","VEC_NUMREL")
	ConfirmSx8()
	VEC_NUMIDE := GetSXENum("VEC","VEC_NUMIDE")
	ConfirmSx8()
	VEC_GRUITE := aColsP[ix_,FG_POSVAR("VS3_GRUITE","aHeaderP")]
	VEC_CODITE := aColsP[ix_,FG_POSVAR("VS3_CODITE","aHeaderP")]
	VEC_VALVDA := aColsP[ix_,FG_POSVAR("VS3_VALTOT","aHeaderP")]
	VEC_VALDES := aColsP[ix_,FG_POSVAR("VS3_VALDES","aHeaderP")]
	VEC_QTDITE := aColsP[ix_,FG_POSVAR("VS3_QTDITE","aHeaderP")]
	VEC_VALICM := aColsP[ix_,FG_POSVAR("VS3_ICMCAL","aHeaderP")]
	VEC_VALCOF := aPisCof[1,2] // VEC_VALVDA * GETMV("MV_TXCOFIN")/ 100
	VEC_VALPIS := aPisCof[1,1] // VEC_VALVDA * GETMV("MV_TXPIS")/ 100
	VEC_TOTIMP := VEC_VALICM + VEC_VALCOF + VEC_VALPIS
	VEC_CUSMED := SB2->B2_CM1 * aColsP[ix_,FG_POSVAR("VS3_QTDITE","aHeaderP")]
	//	VEC_JUREST := FG_JUREST(VS1->VS1_NUMORC,SB1->B1_COD,SB1->B1_UCOM,VS1->VS1_DATORC,"P")
	VEC_JUREST := 0
	VEC_CUSTOT := VEC_CUSMED + VEC_JUREST
	VEC_LUCBRU := VEC_VALVDA - VEC_TOTIMP - VEC_CUSMED
	VEC_DATVEN := dDataBase
	
	//Comissao
	if cOpeMov2 <> "2"
		aValCom    := FG_COMISS("P",cCodVen,VEC_DATVEN,VEC_GRUITE,VEC_VALVDA,"T",VEC_NUMIDE)
		VEC_COMVEN := aValCom[1]
		VEC_COMGER := aValCom[2]
	Else
		VEC_COMVEN := 0
		VEC_COMGER := 0
	Endif
	
	VEC_DESVAR := VEC_COMVEN + VEC_COMGER
	VEC_LUCLIQ := VEC_LUCBRU - VEC_JUREST - VEC_DESVAR - VEC_DESDEP - VEC_DESADM - VEC_DESFIX
	VEC_DESFIX := 0
	VEC_CUSFIX := 0
	VEC_DESDEP := 0
	VEC_DESADM := 0
	VEC_RESFIN := 0
	VEC_BALOFI := "B" //Balcao
	VEC_DEPVEN := ""
	VEC_TIPTEM := ""  //Gravar qdo Ordem de Servico
	VEC_NUMOSV := ""  //Gravar qdo Ordem de Servico
	VEC_RESFIN := VEC_LUCLIQ - VEC_CUSFIX
	VEC_NUMNFI := ""
	
	VEC_VALBRU := VEC_VALVDA + VEC_VALDES
	nRazIte    := VEC_VALBRU / (nTotOrc+nTotDes)
	VEC_VMFBRU := FG_CALCMF(FG_RETVDCP(,,"S",nTotOrc+nTotDes)) * nRazIte
	VEC_VMFVDA := VEC_VMFBRU - FG_CALCMF( {{dDataBase,VEC_VALDES}} )
	VEC_VMFICM := FG_CALCMF( { {FG_RTDTIMP("ICM",dDataBase),VEC_VALICM} })
	VEC_VMFPIS := FG_CALCMF( { {FG_RTDTIMP("PIS",dDataBase),VEC_VALPIS} })
	VEC_VMFCOF := FG_CALCMF( { {FG_RTDTIMP("COF",dDataBase),VEC_VALCOF} })
	VEC_TMFIMP := VEC_VMFICM + VEC_VMFCOF + VEC_VMFPIS
	VEC_CMFMED := FG_CALCMF( { {dDataBase,VEC_CUSMED} })
	VEC_JMFEST := FG_CALCMF( { {dDataBase,VEC_JUREST} })
	VEC_CMFTOT := VEC_CMFMED + VEC_JMFEST
	VEC_LMFBRU := VEC_VMFVDA - VEC_TMFIMP - VEC_CMFTOT
	
	if cOpeMov2 <> "2"
		aValCom    := FG_COMISS("P",cCodVen,VEC_DATVEN,VEC_GRUITE,VEC_VALVDA,"D")
		VEC_CMFVEN := FG_CALCMF(aValCom[1])
		VEC_CMFGER := FG_CALCMF(aValCom[2])
	Else
		VEC_CMFVEN := 0
		VEC_CMFGER := 0
	Endif
	
	VEC_DMFVAR := VEC_CMFVEN + VEC_CMFGER
	VEC_LMFLIQ := VEC_LMFBRU - VEC_DMFVAR
	VEC_DMFFIX := 0
	VEC_CMFFIX := 0
	VEC_CMFDEP := 0
	VEC_DMFADM := 0
	VEC_RMFFIN := VEC_LMFLIQ - VEC_DMFFIX - VEC_CMFFIX - VEC_DMFDEP - VEC_DMFADM
	
	dbSelectArea("TRB")
	MsUnlock()
	
	dbSelectArea("VS5")
	FG_Seek("VS5","cCodMap",1,.f.)
	
	dbSelectArea("VOQ")
	FG_Seek("VOQ","cCodMap",1,.f.)
	
	while !eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ")
		
		if VOQ_INDATI # "1" && Sim
			dbSkip()
			Loop
		Endif
		
		if VOQ_CODMAP # cCodMap
			Exit
		Endif
		
		cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
		
		aadd(aStru,{ VS1->VS1_NUMORC,,SB1->B1_COD,VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,;
		VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,;
		VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,VS1->VS1_DATORC,0,0,VOQ_CTATOT})
		
		dbSkip()
		
	Enddo
	
	dbSelectArea("TRB")
	
	FG_CalcVlrs(aStru,SB1->B1_COD)
	cCpoDiv := cCpoDiv + "#" + str(len(aStru)+1,5)
	
Next

lCalcTot:= .t.

dbSelectArea("VS5")
FG_Seek("VS5","cCodMap",1,.f.)

dbSelectArea("VOQ")
FG_Seek("VOQ","cCodMap",1,.f.)

While !Eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ")
	
	if VOQ_INDATI # "1" && Sim
		dbSkip()
		Loop
	Endif
	
	if VOQ_CODMAP # cCodMap
		exit
	Endif
	
	cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
	
	aadd(aStru,{ VS1->VS1_NUMORC,,"Total da Venda",VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,;
	VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,;
	VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,VS1->VS1_DATORC,0,0,VOQ_CTATOT}) // "Total da Venda"
	
	dbSkip()
	
Enddo

// Totaliza Mapa de Resultados quando mais de um Item
If Type("aStru") == "A"
	
	if Len(aStru) > 0
		cPriCta    := aStru[1,4]
		nQtdEMap   := aScan(aStru,{|x| x[4] == cPriCta},2) - 1  // Qtd de Elementos por Item no Mapa
		nTotStru   := (Len(aStru)-nQtdEMap) // Total de elementos no Vetor, exceto os elementos do Total da Venda
		nPosTotVda := nTotStru // Posicao ultimo elemento do vetor, anterior ao primeiro elemento do Total da Venda
		
		// Limpeza dos elementos do Total da Venda
		for ii := nPosTotVda+1 To Len(aStru)
			aStru[ii,09] := 0
			aStru[ii,12] := 0
		Next
		
		// Gravacao dos elementos do Total da Venda
		nSoma := nQtdEMap
		for ii := 1 To nTotStru
			nPosVet := (nPosTotVda+ii)-If(ii>nQtdEMap,nQtdEMap,0)
			if nPosVet > Len(aStru)
				nQtdEMap += nSoma
				nPosVet := (nPosTotVda+ii)-If(ii>nQtdEMap,nQtdEMap,0)
			Endif
			aStru[nPosVet,09] += aStru[ii,09]
			aStru[nPosVet,12] += aStru[ii,12]
		Next
		nTotItem := nTotStru + 1
		for ii := nTotItem To Len(aStru)
			aStru[ii,10] += ( aStru[ii,9]/aStru[nTotItem+1,9] ) * 100
		Next  
	Endif	
Endif


//FG_CalcVlrs(aStru,OemToAnsi("Total da Venda")) // "Total da Venda"

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM110DELNEG       ³Ricardo Farinelli   º Data ³  03/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta toda a negociacao para poder incluir as novas negociaº±±
±±º          ³coes                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM110DELNEG()

Local lAchou
Local _Fil  := xFilial("VS9")

dbSelectArea("VSE")
dbSeek(xFilial("VSE")+"OR"+M->VS1_NUMORC+"B")
While !Eof() .and. xFilial("VSE") == VSE->VSE_FILIAL .and. VSE->VSE_NUMIDE == "OR"+M->VS1_NUMORC .and. VSE->VSE_TIPOPE == "B"
	if RecLock("VSE",.f.,.t.)
		VSE->(dbDelete())
		MsUnlock()
		WriteSx2("VSE")
	Endif
	dbSkip()
Enddo

dbSelectArea("VS9")
lAchou:= dbSeek(xFilial("VS9")+"OR"+M->VS1_NUMORC)
Do While (_Fil+"OR"+M->VS1_NUMORC)== (VS9_FILIAL+VS9_NUMIDE) .and. !Eof()
	Reclock("VS9",.f.,.t.)
	Dbdelete()
	MsUnlock()
	VS9->(dbSkip())
Enddo

If dbSeek(xFilial("VS9")+"CD"+M->VS1_NUMORC)
	Reclock("VS9",.f.,.t.)
	Dbdelete()
	MsUnlock()
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TRANSFER       ³Ricardo Farinelli   º Data ³  06/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se deve ou efetuar algum tipo de transferencia paraº±±
±±º          ³uma peca                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de concessionarias                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nQtde = quantidade atual em estoque para a peca em questao º±±
±±º          ³ nQtdeDig = quantidade digitada pelo usuario                º±±
±±º          ³ nPosic = posicao do aIteBlq a ser analisada                º±±
±±º          ³ nQtdeAnt = Quantidade anterior existente no aCols          º±±
±±º          ³ lAcols   = vetor do qual sera pesquisado, se for .t. sera oº±±
±±º          ³            aCols, se .F. sera o aColsP                     º±±
±±º          ³ nx       = numero da linha a ser analisada                 º±±
±±º          ³ lTransfer= indica se eh para transferir ou apenas ajustar oº±±
±±º          ³            array aIteBlq                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TRANSFER(nQtde,nQtdeDig,nPosic,nQtdeAnt,lAcols,nx,lTransfer)

Local cAceito := Iif(M->VS1_ORCACE=="0","S","N")
Local cQuanti := Iif(nQtde<=0,"N","S")
Local _aAcols  := aClone(IIf(laCols,aCols,aColsP))
Local nQtdeTra := 0
Local cItem := ""
Default lTransfer := .F.

if laCols
	aColsP := aClone(_aACols)
Endif

If nx <> nil
	n := nx
Endif

If !M->VS1_TIPORC=="1"
	Return (.T.)
Endif

If _aACols[n,Len(_aACols[n])] .and. !lTransfer
	nPosRes := aScan(aIteRes,{|x| x[1] == _aAcols[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
	If nPosic == 0 .and. nPosRes == 0
		Aadd(aIteBlq,{_aAcols[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")],cQuanti,cAceito,"N"})
	Endif
	Return (.T.)
Endif

If nPosic == 0 .and. !lTransfer
	Aadd(aIteBlq,{_aAcols[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")],cQuanti,cAceito,"N"})
	nPosic := Len(aIteBlq)
Endif

nPosRes := aScan(aIteRes,{|x| x[1] == _aAcols[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
if nPosRes > 0 .and. !_aAcols[n,Len(_aAcols[n])]
	if aIteRes[nPosRes,3] == _aAcols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")] .and. lJaMovPec
		Return .t.
	Endif
Endif

lexist := Len(aIteRes) >= n .and. Len(aIteRes) <> 0

If !lTransfer
	aIteBlq[n,3] := cAceito
Endif

If cAceito == "S"
	if lTransfer
		if ExistBlock("TRASFE110")
			ExecBlock("TRASFE110",.f.,.f.,{aHeaderP,aColsP,n,nOpc})
		Endif
	Endif
	cGrupo  := _aACols[n,FG_POSVAR("VS3_GRUITE","aHeaderP")]
	cCodigo := _aACols[n,FG_POSVAR("VS3_CODITE","aHeaderP")]
	FG_Seek("SB1","cGrupo+cCodigo",7,.f.)
	dbSelectArea("SB2")
	dbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
	nSaldo := SaldoSB2()
	nQtde  := nSaldo
	If lExist
		If nQtde+aIteRes[n,3] < 	_aACols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")] .and. !lTransfer
			if GetMv("MV_ESTNEG") <> "S"
				aIteBlq[n,2] := "N"
				MsgInfo(STR0166+alltrim(SB1->B1_DESC)+ " >>  "+ STR0432 + Transform(nSaldo,"@E 99,999,999") + "  " + STR0433 , STR0148) //com # itens no Estoque, Verifique.
				Return (.F.)
			Else
				aIteBlq[n,2] := "S"
			Endif
		Elseif nQtde+aIteRes[n,3] >= 	_aACols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")] //.and. !lTransfer
			aIteBlq[n,2] := "S"
		Endif
	Else
		If nQtde < nQtdeDig .and. !lTransfer
			if GetMv("MV_ESTNEG") <> "S"
				aIteBlq[n,2] := "N"
				MsgInfo(STR0166+alltrim(SB1->B1_DESC)+ " >>  "+ STR0432 + Transform(nSaldo,"@E 99,999,999") + "  "+ STR0433 , STR0148)//com # itens no Estoque, Verifique.
				Return (.F.)
			Else
				aIteBlq[n,2] := "S"
			Endif
		Elseif nQtde > nQtdeDig .and. !lTransfer
			aIteBlq[n,2] := "S"
		Endif
	Endif
Endif

cItem := aColsP[n,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[n,FG_POSVAR("VS3_CODITE","aHeaderP")]

If lTransfer // esta executando transferencia
	If aIteBlq[n,2]+aIteBlq[n,3]+aIteBlq[n,4] == "SSN" .and.;
		!_aACols[n,Len(_aACols[n])] // item novo
		Fs_TranAlmo(1,cItem,_aACols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")],nQtdeDig,LocIte110(.f.,aColsP,n))
		Fs_GravaRes(VS3->(dbSeek(xFilial("VS3")+M->VS1_NUMORC+aColsP[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")])),nQtdeDig)
		aIteBlq[n,4] := "S"
	Elseif aIteBlq[n,2]+aIteBlq[n,3]+aIteBlq[n,4] == "SNS" .and.;
		!_aACols[n,Len(_aACols[n])] // item novo
		Fs_TranAlmo(2,cItem,_aACols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")],nQtdeDig,LocIte110(.f.,aColsP,n))
		Fs_GravaRes(VS3->(dbSeek(xFilial("VS3")+M->VS1_NUMORC+aColsP[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")])),0)
		aIteBlq[n,4] := "S"
	else
		If aIteBlq[n,2]+aIteBlq[n,3]+aIteBlq[n,4] =="SSS" // tem qtde e esta como aceito
			If _aACols[n,Len(_aACols[n])] // a linha esta deletada
				If lExist // existe um correspondente no aIteRes
					If aIteRes[nPosic,3] > 0
						Fs_TranAlmo(2,aIteRes[n,2],aIteRes[n,3],aIteRes[nposic,3],LocIte110(.f.,aColsP,n)) // Devolve
						Fs_GravaRes(VS3->(dbSeek(xFilial("VS3")+M->VS1_NUMORC+aColsP[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")])),0)
						aIteRes[nPosic,3] := 0
					Endif
				Endif
			Else // eh um item normal
				If lExist // existe um item correspondente no aIteRes
					If cItem==aIteRes[n,2]// o usuario nao trocou o item
						nQtdeTra := aColsP[n,FG_POSVAR("VS3_QTDITE","aHeaderP")]
						nQtdeTra -= aIteRes[n,3]
						If nQtdeTra < 0 // precisa transferir mais peca ainda (devolver)
							Fs_TranAlmo(2,aIteRes[n,2],aIteRes[n,3],Abs(nQtdeTra),LocIte110(.f.,aColsP,n)) // Devolve a diferenca
							Fs_GravaRes(VS3->(dbSeek(xFilial("VS3")+M->VS1_NUMORC+aColsP[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")])),nQtdeDig)
							aIteBlq[n,4] := "S"
							aIteRes[n,3] := aColsP[n,FG_POSVAR("VS3_QTDITE","aHeaderP")]
						Elseif nQtdeTra > 0 // precisa transferir mais peca ainda (mandar p/reservado)
							Fs_TranAlmo(1,aIteRes[n,2],aIteRes[n,3],nQtdeTra,LocIte110(.f.,aColsP,n)) // manda a diferenca p/reservado
							Fs_GravaRes(VS3->(dbSeek(xFilial("VS3")+M->VS1_NUMORC+aColsP[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")])),nQtdeDig)
							aIteBlq[n,4] := "S"
							aIteRes[n,3] := aColsP[n,FG_POSVAR("VS3_QTDITE","aHeaderP")]
						Endif
					Else // devolver o anterior e transferir o correto
						If aIteRes[nposic,3] > 0 // se houver qtde anterior
							Fs_TranAlmo(2,aIteRes[n,2],aIteRes[n,3],aIteRes[nposic,3],LocIte110(.f.,aColsP,n))
							Fs_GravaRes(VS3->(dbSeek(xFilial("VS3")+M->VS1_NUMORC+aColsP[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")])),0)
						Endif
						Fs_TranAlmo(1,cItem,_aAcols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")],nQtdeDig,LocIte110(.f.,aColsP,n))
						Fs_GravaRes(VS3->(dbSeek(xFilial("VS3")+M->VS1_NUMORC+aColsP[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")])),nQtdeDig)
						aIteBlq[n,4] := "S"
						aIteRes[n,2] := cItem
						aIteRes[n,3] := nQtdeDig
					Endif
				Else
					if aIteRes[n,3] == _aAcols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")]
						Return .t.
					Endif
					Fs_TranAlmo(1,cItem,_aAcols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")],nQtdeDig,LocIte110(.f.,_aAcols,n))
					Fs_GravaRes(VS3->(dbSeek(xFilial("VS3")+M->VS1_NUMORC+aColsP[n,FG_POSVAR("VS3_SEQUEN","aHeaderP")])),nQtdeDig)
					aIteBlq[n,4] := "S"
				Endif
			Endif
		Else
			If aIteBlq[n,2]+aIteBlq[n,3]=="NN" // nao tem estoque e nao esta aceito
				Return (.T.)
			Elseif aIteBlq[n,2]+aIteBlq[n,3]=="NS" // nao tem estoque e esta aceito
				Return (.T.)
			Elseif cAceito=="N"
				Return (.T.)
			Else
				Return (.F.)
			Endif
		Endif
	Endif
Endif

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_LOADTRANS      ³Ricardo Farinelli   º Data ³  06/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a carga das transferencias (orc aceito) realizadas ante-º±±
±±º          ³riormente                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LOADTRANS(cSeq,nQtde)

Local cQuanti := Iif(nqtde <= 0,"N","S") // esta zerado - nao tem estoque
Local cAceito := Iif(nQtde >  0,"S","N") // estava aceito anteriormente
Local cTransf := Iif(nQtde >  0,"S","N") // havia sido transferido anteriormente

Aadd(aIteBlq,{cSeq,cQuanti,cAceito,cTransf})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GRAVARES       ³Ricardo Farinelli   º Data ³  10/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava a qtde reservada para o orcamento aceito              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fs_GravaRes(lAchou,nQtd)

If lAchou
	Reclock("VS3",.F.)
	VS3->VS3_QTDRES := nqtd
	MsUnlock()
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CALCVAL  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Restaura Calculos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PROMOCAO(cMarca,cCCC,cGrupo,cCodIte,lMsg,lAltVar)

Local nValRet   := 0
Default lMsg    := .t.
Default laltVar := .t.

dbSelectArea("VEN")
dbSetOrder(2)
if dbSeek(xFilial("VEN")+cMarca+cCCC+cGrupo+cCodIte)
	if dDataBase >= VEN->VEN_DATINI .and. dDataBase <= VEN->VEN_DATFIN
		if VEN->VEN_ITEDES > 0
			if lMsg
				MsgInfo(STR0434+" < "+StrZero(VEN->VEN_ITEDES,3)+" >, "+ STR0435 +" < "+DtoS(VEN->VEN_DATFIN)+" >",STR0148) //O Item selecionado esta em promocao, Quantidade em promocao # vencimento da promocao # Atencao!
			Endif
		Endif
		if VEN->VEN_VALPRO > 0
			if lMsg
				MsgInfo(STR0436 ,STR0148) //O Item selecionado esta em promocao...  # Atencao!
			Endif
			if lAltVar
				if oFolder:nOption =2
					aCols[n,FG_POSVAR("VS3_VALPEC","aHeaderP")] := nValPec
					M->VS3_VALPEC := VEN->VEN_VALPRO
					nValPec := M->VS3_VALPEC
				Else
					get_PRECO := VEN->VEN_VALPRO
				Endif
			Endif
			nValRet := VEN->VEN_VALPRO
		Endif
	Endif
Endif

Return(nValRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_SALDOPEC       ³Ricardo Farinelli   º Data ³  14/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula o saldo em estoque de um almoxarifado para uma deterº±±
±±º          ³minada peca.                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SALDOPEC(cChave)

Local nSaldo := 0

aAlias := GetArea()
SB2->(dbSeek(cChave))
RestArea(aAlias)
nSaldo := SaldoSb2()
if ExistBlock("ESTOF110")
	nSaldo := ExecBlock("ESTOF110",.f.,.f.)
Endif

Return(nSaldo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_MUDAABAºAutor  ³Ricardo Farinelli   º Data ³  18/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Muda de pasta para nao ocorrer erro na abertura de um orca- º±±
±±º          ³mento de pecas e servicos ja existente                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MUDAABA()
// Forca a mudanca de aba para a aba de pecas, porque ao confirmar a abertura de um orcamento
// ja existente, se eu estiver na folder de servicos, perde-se o controle dos aheaders a acols's.
// o orcamento supoe que ao clicar em cancelar para abrir um novo orcamento, a folder
// atual seja a das pecas.

If M->VS1_TIPORC=="2" .and. oFolder2:nOption == 2
	oFolder2:nOption := 1
Endif

Return .T.


//////////////////////
Function FS_VERLINHA()

//Local y
Local lRet := .t.
//Local x := 0
//Local aIteD := {}
//Local nDel := 0
//Local nPos := 0

if !aCols[n,Len(aCols[n])]
	if aCols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")] <= 0
		MsgInfo(STR0437 ,STR0148) //Quantidade do Item necessita ser informada..." # Atencao!
		lRet := .f.
	Endif
Endif

if lExeKit
	if !lRecompra
		//		For y:=1 to Len(aCols)
		//	  		nPos := aScan(aIteD,{|x| x[1]+x[2] == aCols[y,FG_POSVAR("VS3_GRUITE" ,"aHeaderP")]+aCols[y,FG_POSVAR("VS3_CODITE","aHeaderP")]})
		//			If nPos == 0
		//	     		aadd(aIteD,{aCols[y,FG_POSVAR("VS3_GRUITE","aHeaderP")],aCols[y,FG_POSVAR("VS3_CODITE","aHeaderP")],0,aCols[y,Len(aCols[y])] })
		//    	ElseIf !aCols[y,Len(aCols[y])]
		// 				aIteD[nPos,3] += 1
		//      	Endif
		//		Next
		//		If aIteD[1,3] > 0
		//			MSGStop(STR0112)  //"Peca ja lancada no Orcamento, Revise"
		//			oGetPecas:oBrowse:Refresh()
		//			Return(.f.)
		//		EndIf
	Else
		dbSelectArea("VE4")
		dbSeek(xFilial("VE4"))
		if RecCount() > 1
			If !(dbSeek(xFilial("VE4")+M->VS1_CODMAR))
				Help(" ",1,"NAOPARFAB")
				Return(.f.)
			EndIf
		Endif
		//	   if Len(Alltrim(M->VS3_CODITE)) <> VE4->VE4_TAMCOD
		//  	   SB1->(dbSetOrder(7))
		//cCod := Right(StrZero(0,VE4->VE4_TAMCOD)+(alltrim(M->VS3_CODITE)),8)
		//      	cCod := Right(StrZero(0,VE4->VE4_TAMCOD)+(alltrim(M->VS3_CODITE)),20)
		//	      if !SB1->(dbSeek(xFilial("SB1")+M->VS3_GRUITE+cCod))
		//      	   MsgInfo(STR0438 ,STR0148) //Este item nao podera ser enviado pois ha divergencia com o tamanho do codigo... # Atencao!
		//				Return(.f.)
		//     	   Endif
		//        	M->VS3_CODITE := cCod
		//       Endif
	Endif
Endif

Return(lRet)


/////////////////////
Function FS_VIRTUAL()

Local cont := oGetPecas:oBrowse:ColPos

While aHeader[cont+1,10] == "V"
	if aHeader[cont+1,10] <> "V"
		Exit
	Else
		oGetPecas:oBrowse:ColPos := oGetPecas:oBrowse:ColPos+1
	Endif
	cont += 1
Enddo

Return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PROLOJA³ Autor ³Valdir F. Silva        ³ Data ³ 29/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao pa mostrar barra de progresso								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Siga Veiculos (Modulo de Oficina/Pecas)                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PROLOJA()
Local cOrcLOja
Private cNota  := ""
Private cSerie := ""
Private lAcabLJ := .f.

ProcRegua(4)
Begin Transaction
IncProc(STR0439)//Gravando Orcamento p/ Caixa

If !(cPaisLoc == "BRA")// Manoel - 07/05/2009
	If M->VS1_TIPVEN != "2" // nao for Atacadista
		cOrcLOja:=FS_INTLOJA()
	Endif
Else
	cOrcLOja:=FS_INTLOJA()
Endif

cNota  := cOrcLOja
cSerie := "LJ "

IncProc(STR0221)
GrAvaliacao()

IncProc(STR0222)
GravEntrada()

IncProc(STR0223)
Financ_CDCI()


End Transaction

If !(cPaisLoc == "BRA") .and. M->VS1_TIPORC == "1"// Manoel - 07/05/2009
	If M->VS1_TIPVEN == "2" // Atacadista
		Processa( { || Fechavenda() } )
		if lAcabLJ
			MsgInfo(STR0524+": " + SC5->C5_NUM,STR0441) //Numero do Pedido Gerado
		Endif
	Endif
Endif

lDestroy := .t.
Limpa_Var()

MaFisEnd()


If !(cPaisLoc == "BRA") // Manoel - 07/05/2009
	If M->VS1_TIPVEN != "2" // nao for Atacadista
		MsgInfo(STR0440+": " + cOrcLoja,STR0441)//Orcamento Nro # Operacao OK
	Endif
Else
	MsgInfo(STR0440+": " + cOrcLoja,STR0441)//Orcamento Nro # Operacao OK
Endif

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_INTLOJA³ Autor ³Valdir F. Silva        ³ Data ³ 29/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Faz integracao da venda balcao c/ o sigaloja				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Siga Veiculos (Modulo de Oficina/Pecas)                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_INTLOJA()
Local aCabPV  := Array(30)
Local aItePV  := {}
Local aPagPV  := {}
Local cLocal  := ""
Local cLocali := ""
Local nX
Local cOrcLoja

//Cabecalho
aCabPV[01] := SA1->A1_COD     //Codigo do cliente
aCabPV[02] := SA1->A1_LOJA    //Loja para entrada
aCabPV[03] := cCodVen         //Codigo do vendedor
aCabPV[04] := dDataBase+30    //Data de emissao
aCabPV[05] := 0    		       //Valor do ICMS
aCabPV[06] := 0               //Valor do ISS
aCabPV[07] := 0               //Valor do IPI
aCabPV[08] := nTotDes         //Valor do Desconto
aCabPV[09] := nTotOrc+nTotDes //Valor Liquido(Total-Desconto)
aCabPV[10] := "1"             //Quem esta gravando
aCabPV[11] := VS1->VS1_NUMORC //Chave a pesquisar
aCabPV[12] := cTipPag
aCabPV[13] := ""
aCabPV[14] := ""
aCabPV[15] := VS1->VS1_VALFRE
aCabPV[16] := VS1->VS1_VALSEG
aCabPV[17] := VS1->VS1_DESACE
aCabPV[18] := VS1->VS1_DATVAL
// grava campos faltantes...luis
aCabPV[19] :=  nTotEntr			// L1_ENTRADA - valor da entrada
aCabPV[20] :=  1				// L1_PARCELA - valor da parcela
aCabPV[21] :=  VS1->VS1_ICMCAL	// L1_VALICM - valor do icm
aCabPV[22] :=  MV_SIMB1			// L1_FORMPG - forma de pagto
aCabPV[23] := 0 				// L1_VLRDEBI - valor do cartao de debito
aCabPV[24] :=  time()			// L1_HORA - hora
aCabPV[25] :=  "0"				// L1_TIPODES - tipo de desconto (grava 0 ?)
aCabPV[26] :=  cEstacao			// L1_ESTACAO
aCabPV[27] :=  VS1->VS1_CODVE2 //Codigo do 2o vendedor 
aCabPV[28] :=  VS1->VS1_CODVE3 //Codigo do 3o vendedor 
aCabPV[29] :=  VS1->VS1_BRICMS //Base ICMS retido
aCabPV[30] :=  VS1->VS1_ICMRET //Valor ICMS retido


//Itens
dbSelectArea("VS3")
dbSetOrder(1)
dbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
While VS3->VS3_FILIAL == xFilial("VS3") .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC .and. VS3->(!eof())
	//Pega a classificacao fiscal de acordo com o estado do cliente
	cCFiscal := FG_CLAFIS(VS3->VS3_CODTES)

//	FG_Seek("SB1","VS3->VS3_GRUITE+VS3->VS3_CODITE",7,.f.)
	SB1->(DbSetOrder(7))
	SB1->(DbSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))

	cLocali := SB1->B1_LOCPAD
	If !(M->VS1_ORCACE$"1 ")
		cLocali := GetMv("MV_RESITE")
	Endif

//		FG_Seek("SBF","SB1->B1_COD+cLocali",2,.f.)
	SBF->(DbSetOrder(2))
	SBF->(DbSeek(xFilial("SBF")+SB1->B1_COD+cLocali))

	cLocali := SBF->BF_LOCALIZ
	If !Empty(VS3->VS3_LOCALI)
		cLocali := VS3->VS3_LOCALI
	EndIf
	cLocal := SB1->B1_LOCPAD
	If !Empty(VS3->VS3_LOCAL)
		cLocal := VS3->VS3_LOCAL
	EndIf
	
	Aadd(aItePV,Array(29))
	aItePV[Len(aItePV),01] := SB1->B1_COD     // Codigo do Produto
	aItePV[Len(aItePV),02] := SB1->B1_DESC    // Descricao do Produto
	aItePV[Len(aItePV),03] := VS3->VS3_QTDITE // Quantidade Vendida
	aItePV[Len(aItePV),04] := (VS3->VS3_VALTOT / VS3->VS3_QTDITE) // Valor Unitario
	aItePV[Len(aItePV),05] := VS3->VS3_VALTOT // Valor Total do Item
	aItePV[Len(aItePV),06] := If(M->VS1_ORCACE$"1 ",cLocal,GetMv("MV_RESITE")) // Almoxarifado
	aItePV[Len(aItePV),07] := 	SB1->B1_UM      // Unidade de Medida Primaria.
	aItePV[Len(aItePV),08] := VS3->VS3_PERDES // Desconto percentual
	aItePV[Len(aItePV),09] := VS3->VS3_VALDES // Desconto Valor
	aItePV[Len(aItePV),10] := VS3->VS3_CODTES // Tipo de Saida do Item
	aItePV[Len(aItePV),11] := cCFiscal        // CFO
	aItePV[Len(aItePV),12] := 0               //Valor IPI
	aItePV[Len(aItePV),13] := VS3->VS3_ICMCAL //Valor do ICMS
	aItePV[Len(aItePV),14] := 0               //Valor do ISS
	aItePV[Len(aItePV),15] := VS3->VS3_VBAICM //Base ICMS
	aItePV[Len(aItePV),16] := VS3->VS3_VALPEC // Valor Unitario
	aItePV[Len(aItePV),17] := "" 					 //Lote
	aItePV[Len(aItePV),18] := "" 					 //Sub Lote
	aItePV[Len(aItePV),19] := cLocali         //Localizacao
	aItePV[Len(aItePV),20] :=	""					 //Numero de Serie
	// grava campos faltantes...luis
	nPosMaFis := aScan(aColsP,{|x| x[FG_POSVAR("VS3_GRUITE","aHeaderP")]+x[FG_POSVAR("VS3_CODITE","aHeaderP")] == VS3->VS3_GRUITE+VS3->VS3_CODITE})
	aItePV[Len(aItePV),21] :=  MaFisRet(nPosMaFis,"IT_VALPS2") // L2_VALPS2 - valor do pis -
	aItePV[Len(aItePV),22] :=  MaFisRet(nPosMaFis,"IT_VALCF2") // L2_VALCF2 - valor cofins - MaFisRet(nPos,"IT_VALCF2")
	aItePV[Len(aItePV),23] :=  MaFisRet(nPosMaFis,"IT_BASEPS2") // L2_BASEPS2 - base do pis - MaFisRet(nPos,"IT_BASEPS2")
	aItePV[Len(aItePV),24] :=  MaFisRet(nPosMaFis,"IT_BASECF2") // L2_BASECF2 - base do cofins - MaFisRet(nPos,"IT_BASECF2")
	aItePV[Len(aItePV),25] :=  MaFisRet(nPosMaFis,"IT_ALIQPS2") // L2_ALIQPS2 - aliquota pis - MaFisRet(nPos,"ALIQPS2")
	aItePV[Len(aItePV),26] :=  MaFisRet(nPosMaFis,"IT_ALIQCF2") // L2_ALIQCF2 - aliquota cofins - MaFisRet(nPos,"IT_ALIQCF2")
	aItePV[Len(aItePV),27] :=  SB1->B1_SEGUM
	aItePV[Len(aItePV),28] :=  VS3->VS3_BICMSB
	aItePV[Len(aItePV),29] :=  VS3->VS3_VICMSB
	
	If ( ExistBlock("VETITLOJA") )
		aItePV := ExecBlock("VETITLOJA",.f.,.f.,{aCabPV,aItePV})
	EndIf
	
	dbSelectArea("VS3")
	dbSkip()
Enddo

//Entradas
For nX:=1 to Len(aColsC)
	If !aColsC[nX,Len(aColsC[nX])] .and. !Empty(aColsC[nX,1])
		Aadd(aPagPV,Array(4))
		aPagPV[Len(aPagPV),01] := aColsC[nX,3]
		aPagPV[Len(aPagPV),02] := aColsC[nX,4]
		aPagPV[Len(aPagPV),03] := aColsC[nX,1]
		aPagPV[Len(aPagPV),04] := ""
	Endif
Next

For nX:=1 to Len(aIteParc)
	If !Empty(aIteParc[nX,1])
		Aadd(aPagPV,Array(4))
		aPagPV[Len(aPagPV),01] := aIteParc[nX,1]
		aPagPV[Len(aPagPV),02] := aIteParc[nX,2]
		aPagPV[Len(aPagPV),03] := iif(empty(SE4->E4_FORMA),"DP",SE4->E4_FORMA)
		aPagPV[Len(aPagPV),04] := ""
	EndIf
Next

Asort(aPagPV,,,{|x,y| dtos(x[1])+descend(x[3]) < dtos(y[1])+descend(y[3]) })

// FG_GRVLOJA(aCabec,aItens,aPag,lExclui,cOrcamento)
FG_GRVLOJA(aCabPV,aItePV,aPagPV,.F.,@cOrcLoja)

RecLock("VS1",.f.)
VS1->VS1_PESQLJ := cOrcLoja
MsUnlock()

Return( cOrcLoja )


Function FS_BLQRES()

Local cQuanti
Local cAceito
Local cTransf
Local xi_:=0 , x_:=0

For xi_:=1 to Len(aColsP)
	nPos := aScan(aIteRes,{|x| x[1] == aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
	if nPos == 0
		aadd(aIteRes,{aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")],aColsP[xi_,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[xi_,FG_POSVAR("VS3_CODITE","aHeaderP")],0 })
	Endif
Next

aIte1 := {}
cIte1 := "#"
For x_:=1 to Len(aIteRes)
	if cIte1 # aIteRes[x_,1]
		aadd(aIte1,{aIteRes[x_,1],aIteRes[x_,2],aIteRes[x_,3] })
		cIte1 := aIteRes[x_,1]
	Else
		cIte1 := "#"
	Endif
Next
if Len(aIte1) <> Len(aIteRes)
	aIteRes := aClone(aIte1)
Endif

For xi_:=1 to Len(aColsP)
	nPos:= aScan(aIteBlq,{|x| x[1] == aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
	if nPos == 0
		cQuanti := "N"  // esta zerado - nao tem estoque
		cAceito := "N"  // estava aceito anteriormente
		cTransf := "N"  // havia sido transferido anteriormente
		aadd(aIteBlq,{aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")],cQuanti,cAceito,cTransf})
	Endif
Next

aIte1 := {}
cIte1 := "#"
For x_:=1 to Len(aIteBlq)
	if cIte1 # aIteBlq[x_,1]
		aadd(aIte1,{aIteBlq[x_,1],aIteBlq[x_,2],aIteBlq[x_,3],aIteBlq[x_,4] })
		cIte1 := aIteBlq[x_,1]
	Else
		cIte1 := "#"
	Endif
Next
if Len(aIte1) <> Len(aIteBlq)
	aIteBlq := aClone(aIte1)
Endif

For xi_:=1 to Len(aColsP)
	_nQtd    := aColsP[xi_,FG_POSVAR("VS3_QTDITE","aHeaderP")]
	_cGruIte := aColsP[xi_,FG_POSVAR("VS3_GRUITE","aHeaderP")]
	_cCodIte := aColsP[xi_,FG_POSVAR("VS3_CODITE","aHeaderP")]
	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+_cGruIte+_cCodIte)
	nSaldo  := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
	nPos := aScan(aIteBlq,{|x| x[1] == aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")]})
	FS_TRANSFER(nSaldo,_nQtd,nPos,_nQtd,.F.,xi_)      // ajusta antes de gravar
	FS_TRANSFER(nSaldo,_nQtd,nPos,_nQtd,.F.,xi_,.T.) // efetua a gravacao
	// zera os campos se nao for aceito
	If M->VS1_ORCACE=="1"
		Fs_GravaRes(VS3->(dbSeek(xFilial("VS3")+M->VS1_NUMORC+aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")])),0)
	Endif
Next

For xi_:=1 to Len(aColsP)
	nPos := aScan(aIteRes,{|x| x[1] == aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
	if nPos == 0
		aadd(aIteRes,{aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")],aColsP[xi_,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[xi_,FG_POSVAR("VS3_CODITE","aHeaderP")],0 })
	Endif
Next

aIte1 := {}
cIte1 := "#"
For x_:=1 to Len(aIteRes)
	if cIte1 # aIteRes[x_,1]
		aadd(aIte1,{aIteRes[x_,1],aIteRes[x_,2],aIteRes[x_,3] })
		cIte1 := aIteRes[x_,1]
	Else
		cIte1 := "#"
	Endif
Next
if Len(aIte1) <> Len(aIteRes)
	aIteRes := aClone(aIte1)
Endif

For xi_:=1 to Len(aColsP)
	nPos:= aScan(aIteBlq,{|x| x[1] == aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")] })
	if nPos == 0
		cQuanti := "N"  // esta zerado - nao tem estoque
		cAceito := "N"  // estava aceito anteriormente
		cTransf := "N"  // havia sido transferido anteriormente
		aadd(aIteBlq,{aColsP[xi_,FG_POSVAR("VS3_SEQUEN","aHeaderP")],cQuanti,cAceito,cTransf})
	Endif
Next

aIte1 := {}
cIte1 := "#"
For x_:=1 to Len(aIteBlq)
	if cIte1 # aIteBlq[x_,1]
		aadd(aIte1,{aIteBlq[x_,1],aIteBlq[x_,2],aIteBlq[x_,3],aIteBlq[x_,4] })
		cIte1 := aIteBlq[x_,1]
	Else
		cIte1 := "#"
	Endif
Next
if Len(aIte1) <> Len(aIteBlq)
	aIteBlq := aClone(aIte1)
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |FS_DESACES  ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria Item com Despesa Acessorios                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Venda Balcao                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OUTDESP(nDesp)

Private cProdAce := GetMv("MV_PRDESAC")
Private cProdFre := GetMv("MV_PRFRETE")
Private cProdSeg := GetMv("MV_PRSEGUR")
do case
	case nDesp == 1
		cProduto := cProdAce
	case nDesp == 2
		cProduto := cProdFre
	case nDesp == 3
		cProduto := cProdSeg
endcase

if Empty(cProduto)
	Return .f.
Endif

cCodTes1 := GetMv("MV_TESDACE")
cCodTes2 := GetMv("MV_TESFRET")
cCodTes3 := GetMv("MV_TESSEGU")
do case
	case nDesp == 1
		cCodTes := cCodTes1
	case nDesp == 2
		cCodTes := cCodTes2
	case nDesp == 3
		cCodTes := cCodTes3
endcase

if Empty(cCodTes)
	Return .f.
Endif

nValorOut1 := M->VS1_DESACE
nValorOut2 := M->VS1_VALFRE
nValorOut3 := M->VS1_VALSEG
do case
	case nDesp == 1
		nValor := nValorOut1
	case nDesp == 2
		nValor := nValorOut2
	case nDesp == 3
		nValor := nValorOut3
endcase

//Pega a classificacao fiscal de acordo com o estado do cliente
cCFiscal1 := FG_CLAFIS(GetMv("MV_TESDACE"))
cCFiscal2 := FG_CLAFIS(GetMv("MV_TESFRET"))
cCFiscal3 := FG_CLAFIS(GetMv("MV_TESSEGU"))
do case
	case nDesp == 1
		cCFiscal := cCFiscal1
	case nDesp == 2
		cCFiscal := cCFiscal2
	case nDesp == 3
		cCFiscal := cCFiscal3
endcase

FG_Seek("SB1","cProduto",1,.f.)
FG_Seek("SB5","SB1->B1_COD")
FG_Seek("SB2","SB1->B1_COD")
FG_Seek("SF4","VS3->VS3_CODTES")
if FG_Seek("SBF","SB1->B1_COD+SB1->B1_LOCPAD",2,.f.)
	cLoc := SBF->BF_LOCALIZ
Endif

//If !(cPaisLoc == "BRA") // Manoel - 07/05/2009
//	cCFiscal := SF4->F4_CF
//Endif

aadd(aItePV,{{"C6_NUM",cNumPed,Nil},;    				// Numero do Pedido
{"C6_ITEM"   ,strzero(Len(aColsP)+1+nDesp,2),Nil},;  	// Numero do Item no Pedido
{"C6_SEQUEN" ,strzero(Len(aColsP)+1+nDesp,2),Nil},;  	// Numero do Item no Pedido
{"C6_PRODUTO",SB1->B1_COD,Nil},;   		// Codigo do Produto
{"C6_QTDVEN" ,1,Nil},;  		   		// Quantidade Vendida
{"C6_PRUNIT" ,nValor,Nil},;  	   		// Preco Unitario do Produto
{"C6_PRCVEN" ,nValor,Nil},;  	   		// Preco Unitario Liquido
{"C6_VALOR"  ,nValor,Nil},;  	   		// Valor Total do Item
{"C6_ENTREG" ,dDataBase,Nil},;     		// Data da Entrega
{"C6_UM"     ,SB1->B1_UM,Nil},;    		// Unidade de Medida Primar.
{"C6_TES"    ,cCodTes,Nil},;  	   		// Tipo de Saida do Item
{"C6_LOCAL"  ,if(M->VS1_ORCACE$"1 ",SB1->B1_LOCPAD,GetMv("MV_RESITE")),Nil},;  // Almoxarifado
{"C6_VALDESC",0,Nil},;  				// Valor do Desconto
{"C6_COMIS1" ,0,Nil},;  				// Comissao Vendedor
{"C6_CF"     ,cCFiscal,Nil},;   		// CFO
{"C6_DESCRI" ,SB1->B1_DESC,Nil},;   	// Descricao do Produto
{"C6_CLI"    ,SC5->C5_CLIENTE,Nil},;   	// Cliente
{"C6_LOJA"   ,SC5->C5_LOJACLI,Nil},;   	// Loja do Cliente
{"C6_QTDEMP" ,1,Nil},;   				// Quantidade Empenhada
{"C6_QTDENT" ,1,Nil}})   				// Quantidade Entregue
if localiza(SB1->B1_COD)
	aadd(aItePV[Len(aItePV)],{"C6_LOCALIZ",if(localiza(SB1->B1_COD),cLoc,SPACE(15)),Nil})
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |FS_PERTIPDES| Autor ³ Thiago              ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Desbloqueia e Desreserva Item                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PERTIPDES()

cTipDes   := " "
aTipDes   := {STR0442,STR0443} //1=Desbloqueia # 2=Desreserva
lOk       := .t.

DEFINE MSDIALOG oDlgNew TITLE OemtoAnsi(STR0444) FROM  02,04 TO 08,31 OF oMainWnd //Tipo de Operacao!

@ 06, 10 SAY STR0371  SIZE 40,08 OF oDlgNew PIXEL COLOR CLR_BLUE 	//Tipo
@ 06, 30 MSCOMBOBOX oTipDes VAR cTipDes SIZE 70,50 ITEMS aTipDes OF oDlgNew PIXEL

DEFINE SBUTTON oOk1 TYPE 1 FROM 26,15 OF oDlgNew ENABLE ONSTOP OemToAnsi(STR0028) ACTION (lOk := .t.,oDlgNew:End())
oOk1:cToolTip := OemToAnsi(STR0028) 	// "Ok
DEFINE SBUTTON oOk2 TYPE 2 FROM 26,65 OF oDlgNew ENABLE ONSTOP OemToAnsi(STR0158) ACTION (lOk := .f.,oDlgNew:End())
oOk2:cToolTip := OemToAnsi(STR0158) 	//"Cancelar

ACTIVATE MSDIALOG oDlgNew CENTER

If Empty(get_grupo) .or. Empty(get_codite)
	MsgInfo(STR0445 ,STR0148) //Nenhum item selecionado... # Atencao!
	Return(.f.)
Endif

dbSelectArea("SB1")
dbSetOrder(7)
if !dbSeek(xFilial("SB1")+get_grupo+get_codite)
	MsgInfo(STR0446 ,STR0148) //Item nao encontrado... # Atencao!)
	Return(.f.)
Else
	cGrupo  := SB1->B1_GRUPO
	cCodIte := SB1->B1_CODITE
	cDesIte := SB1->B1_DESC
Endif

if lOk
	nTipDes := val(Substr(cTipDes,1,1))
	OFIOM260(nTipDes)
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_DESBLQITE³ Autor ³ Thiago              ³ Data ³ 19/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Desbloqueia e Desreserva Item                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Function FS_DESBLQITE(nTipo)

Local aMovto1 := {}
Local nQtd    := 0

if Empty(get_grupo) .or. Empty(get_codite)
MsgInfo(STR0445 ,STR0148) //Nenhum item selecionado... # Atencao!
Return(.f.)
Endif

dbSelectArea("SB1")
dbSetOrder(7)
if !dbSeek(xFilial("SB1")+get_grupo+get_codite)
MsgInfo(STR0446 ,STR0148) //Item nao encontrado... # Atencao!)
Return(.f.)
Else
cGrupo  := SB1->B1_GRUPO
cCodIte := SB1->B1_COD
cDesIte := SB1->B1_DESC
Endif

nOp := 0
if nTipo == 1
nSTR := STR0447
Else
nSTR := STR0530
Endif
DEFINE MSDIALOG oDlgDes TITLE nSTR From 10,30 to 19,70 of oMainWnd //Desbloqueio de Pecas

@ 020,012 SAY STR0448 OF oDlgDes SIZE 45,10 PIXEL COLOR CLR_BLACK //Grupo
@ 020,040 MSGET oGrupo VAR cGrupo PICTURE "@!" SIZE 10,4 OF oDlgDes PIXEL COLOR CLR_BLACK WHEN .f.

@ 035,012 SAY STR0449  OF oDlgDes SIZE 33,20 PIXEL COLOR CLR_BLACK //Item
@ 035,040 MSGET oCodIte VAR cCodIte PICTURE "@!" SIZE 55,4 OF oDlgDes PIXEL COLOR CLR_BLACK WHEN .f.
@ 035,100 SAY cDesIte OF oDlgDes SIZE 75,40 PIXEL COLOR CLR_BLUE

@ 050,012 SAY STR0450 OF oDlgDes SIZE 33,06 PIXEL COLOR CLR_BLACK    //Quantidade
@ 050,040 MSGET oQtd VAR nQtd PICTURE "@E 9999" VALID FS_VLQTDITE(nQtd,nTipo) SIZE 30,4 OF oDlgDes PIXEL COLOR CLR_BLACK

DEFINE SBUTTON oBtn1 TYPE 1 FROM 5000,5000 OF oDlgDes ENABLE

ACTIVATE MSDIALOG oDlgDes CENTER ON INIT EnchoiceBar(oDlgDes, {|| if(FS_VLQTDITE(nQtd,nTipo),(nOp := 1,oDlgDes:End()),.f.) } , {|| nOp := 2,oDlgDes:End() })

if nOp == 1 .and. nQtd > 0

if nTipo == 1 //Desbloqueia
cLocalSai   := GetMv("MV_BLQITE")
cLocalEnt   := SB1->B1_LOCPAD
Else
cLocalSai   := GetMv("MV_RESITE")
cLocalEnt   := SB1->B1_LOCPAD
Endif

//+---------------------------------------------------------------------+
//¦Movimentacao interna do Item                                         ¦
//+---------------------------------------------------------------------+
aItensNew:={}

dbSelectArea("SB5")
dbSetOrder(1)

if nTipo == 1 //Desbloqueia
cLocalizSai := GetMv("MV_BLQLOC")
Else
cLocalizSai := GetMv("MV_RESLOC")
Endif

dbSeek( xFilial("SB5") + SB1->B1_COD )
cLocalizEnt := SB5->B5_LOCALIZ
if ExistBlock("LOCAOM110")
cLocalizEnt := ExecBlock("LOCAOM110",.f.,.f.,{SB1->B1_COD})
Endif

cLocalizEnt := Alltrim(cLocalizEnt)
cLocalizEnt += Space(TamSx3("B5_LOCALIZ")[1]-Len(cLocalizEnt))
cLocalizSai := Alltrim(cLocalizSai)
cLocalizSai += Space(TamSx3("B5_LOCALIZ")[1]-Len(cLocalizSai))

dbSelectArea("SB1")
dbSetOrder(1)

//
// Adiciona cabecalho com numero do documento e data da transferencia modelo II
//
aadd (aItensNew,{ nextnumero("SD3",2,"D3_DOC",.t.), ddatabase})

// sequencia
// produto, descricao, unidade de medida, local/localizacao origem
// produto, descricao, unidade de medida, local/localizacao destino
// numero de serie, lote, sublote, data de validade, qunatidade
// quantidade na 2 unidade, estorno, numero de sequencia

aadd ( aItensNew,{ SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, cLocalSai , if(LOCALIZA(SB1->B1_COD),cLocalizSai,Space(15)),;
SB1->B1_COD, SB1->B1_DESC, SB1->B1_UM, cLocalEnt , if(LOCALIZA(SB1->B1_COD),cLocalizEnt,Space(15)),;
criavar('D3_NUMSERI'),criavar('D3_LOTECTL'), criavar('D3_NUMLOTE')    ,;
criavar('D3_DTVALID'), nQtd, nQtd, criavar("D3_QTSEGUM")   ,;
criavar("D3_ESTORNO"), criavar("D3_NUMSEQ"), criavar("D3_LOTECTL"), criavar("D3_DTVALID"), criavar("D3_ITEMGRD")} )
//	criavar("D3_ESTORNO"), criavar("D3_NUMSEQ"), criavar("D3_LOTECTL")} )
lMsErroAuto	 := .F.
lMsHelpAuto  := .T.

MsExecAuto({|x| MATA261(x)},aItensNew)
If lMsErroAuto
DisarmTransaction()
Break
EndIf

dbSelectArea("SB1")
dbSetOrder(7)

Endif

Return

*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VLQTDITE³ Autor ³Andre                 ³ Data ³ 29/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida Qtdade de Itens a ser Bloqueada      				     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Siga Veiculos (Modulo de Oficina/Pecas)                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Function FS_VLQTDITE(nQtd,nTipo)

Local lRet := .f.
Local cLoc := GetMv("MV_BLQITE")

if nTipo <> 1 //Desreserva
cLoc := GetMv("MV_RESITE")
Endif

if nQtd > 0
dbSelectArea("SB1")
dbSetOrder(7)
if dbSeek(xFilial("SB1")+get_grupo+get_codite)
dbSelectArea("SB2")
dbSetOrder(1)
if dbSeek(xFilial("SB2")+SB1->B1_COD+cLoc)
if nQtd <= SALDOSB2()
lRet := .t.
Endif
Endif
Endif
if !lRet
MsgInfo(STR0451 ,STR0148) //"Quantidade nao disponivel para esta Operacao! # Atencao!
Endif
Else
MsgInfo(STR0452 ,STR0148) //Quantidade positiva deve ser informada!" # Atencao!
Endif

Return(lRet)

*/
Function FS_PESQPECA(cGru,cCod)

Local oLbxPc
Local lRet    := .t.
Local lTela   := .t.
Local aCodPec := {}
Local nLimite := 0
Local cCpo    := ReadVar()

if Empty(cCod)
	Return .t.
Endif

dbSelectArea("SB1")
dbSetOrder(7)
if dbSeek(xFilial("SB1")+cGru+cCod)
	lTela := .f.
Else
	if substr(alltrim(cCod),1,1) == ":"
		dbSetOrder(3)
		dbSeek(xFilial("SB1")+substr(alltrim(cCod),2))
		While !Eof() .and. Substr(SB1->B1_DESC,1,Len(substr(alltrim(cCod),2))) == substr(alltrim(cCod),2)
			aAdd(aCodPec,{SB1->B1_DESC,SB1->B1_GRUPO,SB1->B1_CODITE})
			if nLimite > 600
				Exit
			Else
				nLimite++
			Endif
			SB1->(dbSkip())
		EndDo
	Else
		dbSeek(xFilial("SB1")+cGru+alltrim(cCod))
		While !Eof() .and. SB1->B1_GRUPO == cGru .and. Substr(SB1->B1_CODITE,1,Len(rTrim(cCod))) == rTrim(cCod)
			aAdd(aCodPec,{SB1->B1_DESC,SB1->B1_GRUPO,SB1->B1_CODITE})
			if nLimite > 600
				Exit
			Else
				nLimite++
			Endif
			SB1->(dbSkip())
		EndDo
	Endif
	if Len(aCodPec) == 0
		lTela := .f.
		lRet  := .f.
	Endif
Endif

if lTela
	DEFINE MSDIALOG oDlgCodPec TITLE STR0453 From 10,10 to 26,60 of oMainWnd    //"Pecas com Codigo Relacionado
	
	@ 013,001 LISTBOX oLbxPc FIELDS HEADER  OemToAnsi(STR0139),OemToAnsi(STR0140),OemToAnsi(STR0141) COLSIZES 90,20,50;
	SIZE 197,108 OF oDlgCodPec ON DBLCLICK (FS_SELECPC(aCodPec,oLbxPc:nAt, cCpo),oDlgCodPec:End()) PIXEL
	
	oLbxPc:SetArray(aCodPec)
	oLbxPc:bLine := { || { aCodPec[oLbxPc:nAt,1],aCodPec[oLbxPc:nAt,2],aCodPec[oLbxPc:nAt,3] }}
	
	ACTIVATE MSDIALOG oDlgCodPec CENTER ON INIT (EnchoiceBar(oDlgCodPec,{|| lRet := .t.,FS_SELECPC(aCodPec,oLbxPc:nAt, cCpo) ,oDlgCodPec:End()},{|| lRet := .f., oDlgCodPec:End()}))
Endif

Return lRet


Function FS_SELECPC(aArray_, nPos, cCpo)

if cCpo == "get_codite"
	get_gruite := aArray_[nPos,2]
	get_codite := aArray_[nPos,3]
Endif

if cCpo == "M->VS3_CODITE"
	M->VS3_GRUITE := aArray_[nPos,2]
	aCols[n,FG_POSVAR("VS3_GRUITE","aHeaderP")] := aArray_[nPos,2]
	M->VS3_CODITE := aArray_[nPos,3]
	aCols[n,FG_POSVAR("VS3_CODITE","aHeaderP")] := aArray_[nPos,3]
Endif

Return


Function fs_freseg()

if ReadVar() == "M->VS1_VALFRE"
	MaFisRef("NF_FRETE" ,"VS100",M->VS1_VALFRE)
Endif

if ReadVar() == "M->VS1_VALSEG"
	MaFisRef("NF_SEGURO","VS100",M->VS1_VALSEG)
Endif

FS_CALCVAL("N",.f.)

Return.t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIOM110  ºAutor  ³Microsiga           º Data ³  08/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ exporta para ordem de servico                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_IMPORCOSV()

Local aColsOld:={}, aHeaderOld:={}
Local cSvNomeGet := cGetDados
Local ni := 0
Local lOk := .t.

Private aCodErro := {"",""}
Private aItensNImp := {}
////////////////////////////////////////////////////////////
// Rafael Goncalves - FNC 19571/2009                      //
// Incluido validacao se tem campo do aheader em bco      //
////////////////////////////////////////////////////////////
//inicio
if !lJagravou
	MsgInfo(STR0421 ,STR0148) //O Orcamento tem que ser gravado antes de exportar para OS! # Atencao!
	Return .f.
Endif
if !FS_VERAHADER()//funcao para executar a validacao se existe item com grupo, item e quantidade no aheader       
	Return
Endif                                              
/*
if M->VS1_TIPORC == "2"
	For i:=1 to Len(aColsP)
		if n == i .and. aHeaderP[1,2] == aHeader[1,2]
			if aColsP[i,Len(aColsP[i])] .or. ( len(aColsP)==1 .and. Empty(M->VS3_GRUITE) .and. Empty(M->VS3_CODITE) )
				Loop
			EndIf
			if Empty(M->VS3_GRUITE) .and. !Empty(M->VS3_CODITE)
				MsgInfo(STR0363 +" < "+strzero(i,3)+" >",STR0148)//Grupo do Item nao foi informado... item # Atencao!
				Return(.f.)
			Endif
			If Empty(M->VS3_CODITE)
				MsgInfo(STR0532 +" < "+strzero(i,3)+" >",STR0148)//codigo do Item nao foi informado... item # Atencao!
				Return(.f.)
			Endif
			if M->VS3_QTDITE == 0
				MsgInfo(STR0364 +" < "+strzero(i,3)+" >",STR0148) //Quantidade do item nao foi informada... item # Atencao!
				Return(.f.)
			Endif
		else
	   		if aColsP[i,Len(aColsP[i])] .or. ( len(aColsP)==1 .and. Empty(aColsP[i,FG_POSVAR("VS3_GRUITE","aHeaderP")]) .and. Empty(aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")]) )
				Loop
		    EndIf
			if Empty(aColsP[i,FG_POSVAR("VS3_GRUITE","aHeaderP")]) .and. !Empty(aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")])
				MsgInfo(STR0363 +" < "+strzero(i,3)+" >",STR0148)//Grupo do Item nao foi informado... item # Atencao!
				Return(.f.)
			Endif
			If Empty(aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")])
				MsgInfo(STR0532 +" < "+strzero(i,3)+" >",STR0148)//codigo do Item nao foi informado... item # Atencao!
				Return(.f.)
			Endif
			if aColsP[i,FG_POSVAR("VS3_QTDITE","aHeaderP")] == 0
				MsgInfo(STR0364 +" < "+strzero(i,3)+" >",STR0148) //Quantidade do item nao foi informada... item # Atencao!
				Return(.f.)
			Endif
		Endif 
	Next
Endif
*/
//Fim da alteracao

begin transaction

If M->VS1_TIPORC <> "2"
	MsgStop(STR0454 ,STR0148) //Orcamento de pecas nao pode ser importado para Ordem de Servico! # Atencao!
	DisarmTransaction()
	Return
EndIf

If Empty(M->VS1_GETKEY)
	MsgStop(STR0455 ,STR0148) //Veiculo nao informado ou nao cadastrado. Impossivel importar para a ordem de servico! # Atencao!
	DisarmTransaction()
	Return
EndIf

DbSelectArea("VOW")
DbSetOrder(1)
lConsidera := .t.
if VOI->(FieldPos("VOI_CONVOW")) > 0
	VOI->(DbSetOrder(1))
	VOI->(DbSeek( xFilial("VOI") + M->VS1_TIPTEM ) )
	if VOI->VOI_CONVOW == "0"
		lConsidera := .f.
	endif
endif
If!( DbSeek( xFilial("VOW") + Posicione("VAI",4,xFilial("VAI")+__cUserID,"VAI_CODTEC") + M->VS1_TIPTEM ))  .and. lConsidera
	Help(" ",1,"TPPRODUT")
	dbSelectArea("VS1")
	DisarmTransaction()
	Return()
EndIf

DbSelectArea("SB1")
DbSetOrder(7)
For ni := 1 to len(aColsP)
	If !aColsP[ni,Len(aColsP[ni])]
		If DbSeek(xFilial("SB1")+aColsP[ni,FG_POSVAR("VS3_GRUITE","aHeaderP")]+aColsP[ni,FG_POSVAR("VS3_CODITE","aHeaderP")])
			If SB1->B1_MSBLQL $ "1S"
				MsgAlert(STR0368+CHR(13)+CHR(10)+CHR(13)+CHR(10)+aColsP[ni,1]+" - "+SB1->B1_GRUPO+" "+SB1->B1_CODITE+CHR(13)+CHR(10)+SB1->B1_DESC,STR0019)//O Produto escolhido esta bloqueado para a venda!
				lOk := .f.
				Exit
			EndIf
		EndIf
	EndIf
Next
dbSelectArea("VS1")

For ni := 1 to len(aColsS)
	If !Empty(aColsS[ni,FG_POSVAR("VS4_CODSER","aHeaderS")])
		If Empty(aColsS[ni,FG_POSVAR("VS4_TIPSER","aHeaderS")])
			MsgStop(STR0456 ,STR0148) //Servico sem Tipo de Servico. Impossivel importar para a ordem de servico! # Atencao!
			lOk := .f.
			Exit
		EndIf
		If FG_POSVAR("VS4_CODSEC","aHeaderS") > 0
			If Empty(aColsS[ni,FG_POSVAR("VS4_CODSEC","aHeaderS")])
				MsgStop(STR0457 ,STR0148) //Servico sem Codigo da Secao Oficina. Impossivel importar para a ordem de servico! # Atencao!
				lOk := .f.
				Exit
			EndIf
		EndIf
	EndIf
Next

If Empty(GetMv( "MV_RESITE" ))
	MsgStop(STR0529,STR0019)
	lOk := .f.
EndIf

If !lOk
	DisarmTransaction()
	Return
EndIf

dbSelectArea("VS1")
dbSetOrder(1)
If !DbSeek( xFilial("VS1") + M->VS1_NUMORC )
	If ( !MsgYesNo(STR0458 ,STR0148) .Or. !Eval(oBtOk2:bAction) ) //Orcamento nao foi gravado! Deseja gravar? # Atencao
		DisarmTransaction()
		Return
	EndIf
EndIf

// Orcamentos Oficina - Tipo de Servico e Secao Oficina.

&& Salva Arquivo de trabalho do orcamento
//FS_SALVATMP("TMP","TSV")

aColsOld   := Aclone(aCols)
aHeaderOld := Aclone(aHeader)

aCols   := NIL
aHeader := NIL

dbSelectArea("VS1")
lVSJVO4Suc := .t.
If MsgYesNo(STR0459 ,STR0148) //Deseja abrir uma nova O.S ? # Atencao!
	cNumOrd := FM_ABREOSV( @aCodErro ,,VS1->VS1_CHAINT , M->VS1_KILOME , VS1->VS1_CLIFAT, VS1->VS1_LOJA , "")
	if Empty(cNumOrd)
		MsgStop(aCodErro[2],STR0460 +" - "+aCodErro[1]) //ATENCAO
		lVSJVO4Suc := .f.
	else
		DEFINE MSDIALOG oDlgOSv TITLE OemtoAnsi(STR0461) FROM  02,04 TO 09,41 OF oMainWnd //Dados da Ordem de Servico
		@ 002,004 TO 35,145 LABEL STR0462 OF oDlgOSv PIXEL //Nro. da Ordem de Servico:
		@ 010, 035 Say cNumOrd  OF oDlgOSv PIXEL Font TFont():New( "System", 015, 048 ) SIZE 105,20
		DEFINE SBUTTON oFecha   FROM 038,110 TYPE 1 ACTION oDlgOSv:End() ENABLE OF oDlgOSv
		ACTIVATE MSDIALOG oDlgOSv CENTER
	endif
else
	If !Pergunte("OFM100",.T.)
		lVSJVO4Suc := .f.
	else
		cNumOrd := MV_PAR01
		If !FS_VLABERT(cNumOrd,VS1->VS1_TIPTEM)
			lVSJVO4Suc := .f.
		EndIf
	EndIf
EndIf
if !Empty(VS1->VS1_OBSMEM)
	cOBSVO1 := MSMM(VS1->VS1_OBSMEM,TamSx3("VS1_OBSERV")[1])
	DbSelectArea("VO1")
	DBSetOrder(1)
	DBSeek(xFilial("VO1")+cNumOrd)
	M->VO1_OBSERV := MSMM(VO1->VO1_OBSMEM,TamSx3("VO1_OBSERV")[1])
	DbSelectArea("VO1")
	RecLock("VO1",.f.)
	M->VO1_OBSERV := Alltrim(M->VO1_OBSERV)+cOBSVO1+Chr(13)+Chr(10)
	MSMM(,TamSx3("VO1_OBSERV")[1],,&(aMemos3[1][2]),1,,,"VO1","VO1_OBSMEM")
	MsUnlock()
endif
if lVSJVO4Suc
	DbSelectArea("VS4")
	DbSetOrder(1)
	if DbSeek(xFilial("VS4")+VS1->VS1_NUMORC)
		VO1->(dbSetOrder(1))
		VO1->(dbSeek(xFilial("VO1")+cNumOrd))
		//
		aCodErro := {"",""}
		cNosNum := FM_IMPVO4( @aCodErro, VS1->VS1_NUMORC , VO1->VO1_NUMOSV )
		if Empty(cNosNum)
			MsgStop(aCodErro[2],STR0460+" - "+aCodErro[1])//ATENCAO
			lVSJVO4Suc := .f.
		else
			If VO1->(FieldPos("VO1_NUMORC")) > 0
				If Empty(VO1->VO1_NUMORC)
					DbSelectArea("VO1")
					RecLock("VO1",.F.)
					VO1->VO1_NUMORC := VS1->VS1_NUMORC
					MsUnLock()
				EndIf
			EndIf
			DBSelectArea("VS1")
			reclock("VS1",.f.)
			VS1->VS1_NUMOSV := VO1->VO1_NUMOSV
			msunlock()
		endif
	endif
	
	// Rubens - 23/09/2009 
	// Posiciona na VO1 para gerar VSJ, pois nos Orcamentos sem servicos
	// não estava gerando os registros VSJ com o numero da OS correta   
	VO1->(dbSetOrder(1))
	VO1->(dbSeek(xFilial("VO1")+cNumOrd))
	if FM_IMPVSJ( @aItensNImp , VS1->VS1_NUMORC , VO1->VO1_NUMOSV )
		if Len(aItensNImp[2]) > 0
			if MsgYesNo(OemToAnsi(STR0463),OemToAnsi(STR0148)) //Pecas sem saldo suficiente! Imprimir relacao de pecas? # Atencao!
				FM_IPECNDISP(aItensNImp)
			endif
		endif
		If VO1->(FieldPos("VO1_NUMORC")) > 0
			If Empty(VO1->VO1_NUMORC)
				DbSelectArea("VO1")
				RecLock("VO1",.F.)
				VO1->VO1_NUMORC := VS1->VS1_NUMORC
				MsUnLock()
			EndIf
		EndIf
		DBSelectArea("VS1")
		reclock("VS1",.f.)
		VS1->VS1_NUMOSV := VO1->VO1_NUMOSV
		msunlock()
		lVSJVO4Suc := .t.
		If ExistBlock("IMPORCVSJ")
			ExecBlock("IMPORCVSJ",.f.,.f.,{VO1->VO1_NUMOSV})
		Endif
	endif
endif
If lVSJVO4Suc
	MsgInfo(STR0464 ,STR0148) //Orcamento exportado com sucesso! # Atencao!
	FG_PEDORD(VO1->VO1_NUMOSV,"N","S")
endif

if !lVSJVO4Suc
	DisarmTransaction()
	cGetDados := cSvNomeGet
	
	aCols   := Aclone(aColsP)
	aHeader := Aclone(aHeaderP)
	
	if Type(cGetDados) <> "U"
		
		aCols     := {}
		aHeader   := aClone(aHeaderI)
		&& Salva Arquivo de trabalho do orcamento
		//FS_SALVATMP("TSV","TMP",.t.)
		
		&(cGetDados):oBrowse:Refresh()
		
	Endif
	
	Return
	
EndIf

end Transaction

cGetDados := cSvNomeGet

aCols   := Aclone(aColsP)
aHeader := Aclone(aHeaderP)

lJaPerg  := .f.
lDestroy := .t.

Limpa_Var()

if Type(cGetDados) <> "U"
	
	aCols     := {}
	aHeader   := aClone(aHeaderI)
	&& Salva Arquivo de trabalho do orcamento
	//FS_SALVATMP("TSV","TMP",.t.)
	
	&(cGetDados):oBrowse:Refresh()
Endif

oFolder2:nOption := 1

FS_FOLDER(.f.)

&& Fecha orcamento apos importacao
If Type("aCrrgVar") # "U"
	
	Eval( {|| nOpca := 2,FS_CANCELA(.t.),nOpca := 1,oDlgOrc:End()} )
	
EndIf

Return

Function FS_ORDB()

if ExistBlock("ORDBUSCB")
	U_ORDBUSCB("O")
Else
	MsgInfo(OemToAnsi( STR0465 ),STR0148)//Ordem de busca indisponílvel # ATENCAO
Endif

Return


Function FS_TREEPCSV()

Local aSizeAut  := MsAdvSize()
Private oDescI, oObsI, oValorS, oGrupoP, oCodigoP, oDescP, oQtdP, oPerDesP, oValDesP
Private cDesc     := space(100)
Private cObs      := space(100)
Private cDescI    := space(100)
Private cObsI     := MSMM(VSM->VSM_OBSMEM,TamSx3("VSM_OBSERV")[1])
//Pecas
Private cGrupoP   := space(100)
Private cCodigoP  := space(100)
Private cDescP    := space(100)
Private nValorP   := 0
Private nQtdP     := 0
Private nPerDesP  := 0
Private nValDesP  := 0
//Servico agrupado
Private cGrupoSA  := space(100)
Private cCodigoSA := space(100)
Private cDescSA   := space(100)
Private cTipoSA   := space(100)
Private cTempoSA  := "00:00"
Private nValorSA  := 0
Private nPerDesSA := 0
Private nValDesSA := 0
//Servicos
Private cGrupoS   := space(100)
Private cCodigoS  := space(100)
Private cDescS    := space(100)
Private cTipoS    := space(100)
Private cTempoS   := space(100)
Private nValorS   := 0
Private nPerDesS  := 0
Private nValDesS  := 0
//Kit
Private cGrupoK   := space(100)
Private cCodigoK  := space(100)
Private cDescK    := space(100)

Private aOrgano := {}
Private cOrgano := ""
Private nOrdem  := 0

Private cGetMar, cGetMod1, cGetMod2

DEFINE FONT oFnt2 NAME "Arial" SIZE 10,18 BOLD

DEFINE MSDIALOG oDlgTree FROM aSizeAut[7],00 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL

/*DEFINE BUTTONBAR oBarTree SIZE 01,01 3D TOP OF oDlgTree

DEFINE BUTTON oBt1 RESOURCE "SHORTCUTNEW"  OF oBarTree ACTION (F110Act( oTree, 1, 1, oMenu )) TOOLTIP ""
//DEFINE BUTTON oBt2 RESOURCE "SHORTCUTEDIT" OF oBarTree ACTION .t. TOOLTIP ""
DEFINE BUTTON oBt3 RESOURCE "SHORTCUTDEL"  OF oBarTree ACTION (TREEDEL110(oTree:GetCargo())) TOOLTIP ""
DEFINE BUTTON oBt4 RESOURCE "OK"           OF oBarTree ACTION (Inclui2:= .f.,oDlgTree:End()) TOOLTIP ""
DEFINE BUTTON oBt5 RESOURCE "CANCEL"       OF oBarTree ACTION (TreCan010(),oDlgTree:End()) TOOLTIP ""
*/
oTree := DbTree():New( 13, 00, 277, 180,oDlgTree,,,.T.)
oTree:bChange := {|| F110Click( oTree ) }

MENU oMenu POPUP
MENUITEM STR0466  Action F110Inconv(oTree,oTree:GetCargo()) 	//Inconveniente
MENUITEM STR0467  Action F110Seragru(oTree,oTree:GetCargo()) 	//Servico Agrupado
MENUITEM STR0468  Action F110Kit(oTree,oTree:GetCargo()) 		//Kit Pecas
MENUITEM STR0469  Action F110Serv(oTree,oTree:GetCargo())		//Servico
MENUITEM STR0470  Action F110Peca(oTree,oTree:GetCargo())		//Peca
MENUITEM STR0471  Action F110Pesq(oTree)						//Pesquisa
ENDMENU

oTree:bRClicked := { |o,x,y| F110Act( o, x, y-100, oMenu ) } // Posição x,y em relação a Dialog

//Inconveniente
@ 13,181 SCROLLBOX oScroll1 VERTICAL SIZE 263,326 OF oDlgTree BORDER PIXEL
oScroll1:lVisible := .f.

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@ 00, 00 BITMAP oBmp RESNAME "LOGIN" oF oScroll1 SIZE 29, 180 NOBORDER WHEN .F. PIXEL

@ 03, 40 SAY STR0466 SIZE 200,08 OF oScroll1 FONT oFnt2 PIXEL 	//Inconveniente

@ 14, 30 TO 16 ,400 LABEL '' OF oScroll1   PIXEL

@ 26, 40 SAY   STR0400 SIZE 40,08 OF oScroll1 PIXEL //descricao
@ 38, 40 MSGET oDescI VAR cDescI PICTURE "@!" SIZE 150,8 OF oScroll1 PIXEL

@ 50, 40 SAY   STR0472 SIZE 40,08 OF oScroll1 PIXEL  			//Observacao
@ 61, 40 GET oObsI VAR cObsI OF oScroll1 MEMO SIZE 150,60 PIXEL

DEFINE SBUTTON oBut1 FROM 127, 110  TYPE 1 ACTION ( Grava_Inc() ) ENABLE of oScroll1

DEFINE SBUTTON oBut2 FROM 127, 142  TYPE 2 ACTION ( carregadados(oTree:GetCargo()) ) ENABLE of oScroll1

//Servico agrupado
@ 13,181 SCROLLBOX oScroll2 VERTICAL SIZE 263,326 OF oDlgTree BORDER PIXEL
oScroll2:lVisible := .f.

@ 00, 00 BITMAP oBmp RESNAME "LOGIN" oF oScroll2 SIZE 29, 180 NOBORDER WHEN .F. PIXEL

@ 03, 40 SAY STR0467 SIZE 200,08 OF oScroll2 FONT oFnt2 PIXEL  //Serviço agrupado

@ 14, 30 TO 16 ,400 LABEL '' OF oScroll2   PIXEL

@ 026, 40 SAY   STR0448 SIZE 40,08 OF oScroll2 PIXEL COLOR CLR_BLUE 	//grupo
@ 036, 40 MSGET oGrupoSA VAR cGrupoSA PICTURE "@!" SIZE 40,8 F3 "SBM" OF oScroll2 PIXEL

@ 050, 40 SAY   STR0275 SIZE 40,08 OF oScroll2 PIXEL COLOR CLR_BLUE  	//Codigo
@ 060, 40 MSGET oCodigoSA VAR cCodigoSA PICTURE "@!" SIZE 100,8 F3 "SB1" OF oScroll2 PIXEL

@ 074, 40 SAY   STR0400 SIZE 40,08 OF oScroll2 PIXEL COLOR CLR_BLUE 	//descricao
@ 084, 40 MSGET oDescSA VAR cDescSA PICTURE "@!" SIZE 150,8 OF oScroll2 PIXEL WHEN .f.

@ 100, 40 SAY   STR0371 SIZE 40,08 OF oScroll2 PIXEL 	//Tipo
@ 110, 40 MSGET oTipoSA VAR cTipoSA PICTURE "@!" SIZE 40,8 F3 "VOK" OF oScroll2 PIXEL

@ 124, 40 SAY   STR0474 SIZE 40,08 OF oScroll2 PIXEL 	//Tempo Padrao
@ 134, 40 MSGET oTempoSA VAR cTempoSA PICTURE "@!" SIZE 50,8 OF oScroll2 PIXEL WHEN .f.

@ 148, 40 SAY   STR0475 SIZE 80,08 OF oScroll2 PIXEL  //Valor do Servico
@ 160, 40 MSGET oValorSA VAR nValorSA PICTURE "@E 999,999.99" SIZE 50,8 OF oScroll2 PIXEL

@ 172, 40 SAY   STR0473 SIZE 40,08 OF oScroll2 PIXEL 	//Descontos
@ 182, 40 MSGET oPerDesSA VAR nPerDesSA PICTURE "@!" SIZE 30,8 OF oScroll2 PIXEL
@ 182, 80 MSGET oValDesSA VAR nValDesSA PICTURE "@!" SIZE 30,8 OF oScroll2 PIXEL

DEFINE SBUTTON oBut1 FROM 197, 110  TYPE 1 ACTION ( Grava_SAgr() ) ENABLE of oScroll2

DEFINE SBUTTON oBut2 FROM 197, 142  TYPE 2 ACTION ( carregadados(oTree:GetCargo()) ) ENABLE of oScroll2


//Kit Pecas
@ 13,181 SCROLLBOX oScroll3 VERTICAL SIZE 263,326 OF oDlgTree BORDER PIXEL
oScroll3:lVisible := .f.

@ 00, 00 BITMAP oBmp RESNAME "LOGIN" oF oScroll3 SIZE 29, 180 NOBORDER WHEN .F. PIXEL

@ 03, 40 SAY STR0476 SIZE 200,08 OF oScroll3 FONT oFnt2 PIXEL //Kit de pecas

@ 14, 30 TO 16 ,400 LABEL '' OF oScroll3   PIXEL

@ 026, 40 SAY   STR0448 SIZE 40,08 OF oScroll3 PIXEL //grupo
@ 036, 40 MSGET oGrupoK VAR cGrupoK PICTURE "@!" SIZE 40,8 F3 "SBM" OF oScroll3 PIXEL

@ 050, 40 SAY   STR0275 SIZE 40,08 OF oScroll3 PIXEL  //codigo
@ 060, 40 MSGET oCodigoK VAR cCodigoK PICTURE "@!" SIZE 100,8 F3 "SB1" OF oScroll3 PIXEL

@ 074, 40 SAY   STR0400 SIZE 40,08 OF oScroll3 PIXEL //descricao
@ 084, 40 MSGET oDescK VAR cDescK PICTURE "@!" SIZE 150,8 OF oScroll3 PIXEL WHEN .f.

DEFINE SBUTTON oBut1 FROM 100, 110  TYPE 1 ACTION ( .t. ) ENABLE of oScroll3

DEFINE SBUTTON oBut2 FROM 100, 142  TYPE 2 ACTION ( .t. ) ENABLE of oScroll3


//Servicos
@ 13,181 SCROLLBOX oScroll4 VERTICAL SIZE 263,326 OF oDlgTree BORDER PIXEL
oScroll4:lVisible := .f.

@ 00, 00 BITMAP oBmp RESNAME "LOGIN" oF oScroll4 SIZE 29, 180 NOBORDER WHEN .F. PIXEL

@ 03, 40 SAY STR0477 SIZE 200,08 OF oScroll4 FONT oFnt2 PIXEL  //Servicos

@ 14, 30 TO 16 ,400 LABEL '' OF oScroll4   PIXEL

@ 026, 40 SAY   STR0448 SIZE 40,08 OF oScroll4 PIXEL 			//grupo
@ 036, 40 MSGET oGrupoS VAR cGrupoS PICTURE "@!" SIZE 40,8 F3 "SBM" OF oScroll4 PIXEL

@ 050, 40 SAY   STR0275 SIZE 40,08 OF oScroll4 PIXEL 			//codigo
@ 060, 40 MSGET oCodigoS VAR cCodigoS PICTURE "@!" SIZE 100,8 F3 "SB1" OF oScroll4 PIXEL

@ 074, 40 SAY   STR0400 SIZE 40,08 OF oScroll4 PIXEL 			//descricao
@ 084, 40 MSGET oDescS VAR cDescS PICTURE "@!" SIZE 150,8 OF oScroll4 PIXEL WHEN .f.

@ 100, 40 SAY   STR0478 SIZE 40,08 OF oScroll4 PIXEL	//Tipo de Servico
@ 110, 40 MSGET oTipoS VAR cTipoS PICTURE "@!" SIZE 40,8 F3 "VOK" OF oScroll4 PIXEL

@ 124, 40 SAY   STR0474 SIZE 40,08 OF oScroll4 PIXEL //tempo padrao
@ 134, 40 MSGET oTempoS VAR cTempoS PICTURE "@R 99:99" SIZE 50,8 OF oScroll4 PIXEL WHEN .f.

@ 148, 40 SAY   STR0475 SIZE 80,08 OF oScroll4 PIXEL //valor do servico
@ 160, 40 MSGET oValorS VAR nValorS PICTURE "@E 999,999.99" SIZE 50,8 OF oScroll4 PIXEL

@ 172, 40 SAY   STR0473 SIZE 40,08 OF oScroll4 PIXEL //descontos
@ 182, 40 MSGET oPerDesS VAR nPerDesS PICTURE "@E 999,999.99" SIZE 30,8 OF oScroll4 PIXEL
@ 182, 80 MSGET oValDesS VAR nValDesS PICTURE "@E 999,999.99" SIZE 30,8 OF oScroll4 PIXEL

DEFINE SBUTTON oBut1 FROM 197, 110  TYPE 1 ACTION ( grava_srv() ) ENABLE of oScroll4

DEFINE SBUTTON oBut2 FROM 197, 142  TYPE 2 ACTION ( carregadados(oTree:GetCargo()) ) ENABLE of oScroll4


//Pecas
@ 13,181 SCROLLBOX oScroll5 VERTICAL SIZE 263,326 OF oDlgTree BORDER PIXEL
oScroll5:lVisible := .f.

@ 00, 00 BITMAP oBmp RESNAME "LOGIN" oF oScroll5 SIZE 29, 180 NOBORDER WHEN .F. PIXEL

@ 03, 40 SAY STR0379 SIZE 200,08 OF oScroll5 FONT oFnt2 PIXEL //pecas

@ 14, 30 TO 16 ,400 LABEL '' OF oScroll5   PIXEL

@ 026, 40 SAY   STR0448 SIZE 40,08 OF oScroll5 PIXEL //grupo
@ 038, 40 MSGET oGrupoP VAR cGrupoP PICTURE "@!" SIZE 40,8 F3 "SBM" OF oScroll5 PIXEL

@ 050, 40 SAY   STR0275 SIZE 40,08 OF oScroll5 PIXEL//codigo
@ 062, 40 MSGET oCodigoP VAR cCodigoP PICTURE "@!" SIZE 100,8 F3 "SB1" OF oScroll5 PIXEL

@ 074, 40 SAY   STR0400 SIZE 40,08 OF oScroll5 PIXEL //descricao
@ 086, 40 MSGET oDescP VAR cDescP PICTURE "@!" SIZE 150,8 OF oScroll5 PIXEL WHEN .f.

@ 100, 40 SAY   STR0450 SIZE 40,08 OF oScroll5 PIXEL  //quantidade
@ 112, 40 MSGET oQtdP VAR nQtdP PICTURE "99999" SIZE 30,8 OF oScroll5 PIXEL

@ 124, 40 SAY   STR0473 SIZE 40,08 OF oScroll5 PIXEL //descontos
@ 136, 40 MSGET oPerDesP VAR nPerDesP PICTURE "@E 999,999.99" SIZE 30,8 OF oScroll5 PIXEL
@ 136, 80 MSGET oValDesP VAR nValDesP PICTURE "@E 999,999.99" SIZE 30,8 OF oScroll5 PIXEL

DEFINE SBUTTON oBut1 FROM 147, 110  TYPE 1 ACTION ( grava_peca() ) ENABLE of oScroll5

DEFINE SBUTTON oBut2 FROM 147, 142  TYPE 2 ACTION ( carregadados(oTree:GetCargo()) ) ENABLE of oScroll5

ABRTRE010()

ACTIVATE MSDIALOG oDlgTree ON INIT Eval(oTree:bChange)

Return .t.

////////////////////
Function TreCan010()

if Inclui2
	dbSelectArea("VSM")
	dbSetOrder(6)
	if dbSeek(xFilial("VSM")+M->VS1_NUMORC)
		while !EOF() .and. VSM->VSM_NUMORC == M->VS1_NUMORC
			RecLock("VSM",.f.,.t.)
			VSM->(dbDelete())
			MsUnlock()
			WriteSx2("VSM")
			dbSelectArea("VSM")
			dbSkip()
		EndDo
	Endif
Endif

Return

//////////////////////////
Function F110Pesq( oTree )

LOCAL aItems     := {}
LOCAL aSeek      := {}

LOCAL cChavePesq := Space( 20 )
LOCAL cChave     := Space( 20 )
LOCAL cVar       := ""

LOCAL nCombo     := 1
LOCAL nOpca      := 0

LOCAL oCombo
LOCAL oDlg
LOCAL oBut1
LOCAL oBut2
LOCAL oGetPesq

AAdd( aItems, STR0031 ) // "Chamado Tecnico" //"Representante"
AAdd( aItems, STR0032 ) // "Ordem de Servico"

AAdd( aSeek, { "1US", 1, "@R XXXXXX", STR0031, "SA3" } )  //"Representante" //"Representante"
AAdd( aSeek, { "2GR", 1, "@R XXXXXX", STR0032, "ACA" } )  //"Grupo" //"Grupo"

DEFINE MSDIALOG oDlg TITLE CCADASTRO FROM 09,0 TO 21.2,43.5 OF oMainWnd

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@ 00, 00 BITMAP oBmp RESNAME "LOGIN" oF oDlg SIZE 30, 120 NOBORDER WHEN .F. PIXEL

@ 03, 40 SAY STR0033 FONT oBold PIXEL 			// Pesquisar entidade"

@ 14, 30 TO 16 ,400 LABEL '' OF oDlg   PIXEL

@ 23, 40 SAY STR0034 SIZE 40, 09 PIXEL 			//Entidade
@ 23, 80 COMBOBOX oCombo VAR cVar ITEMS aItems SIZE 80, 10 OF oDlg PIXEL

@ 35, 40 SAY STR0035  SIZE 40, 09    PIXEL 		//Chave "
@ 35, 80 MSGET oGetPesq1 VAR cChave WHEN .F. SIZE 80, 10 VALID .T. PIXEL

@ 48, 40 SAY STR0036 SIZE 40, 09    PIXEL 		//Pesquisa "
@ 48, 80 MSGET oGetPesq VAR cChavePesq SIZE 80, 10 VALID .T. PIXEL F3 "XYZZYZ"

oGetPesq:bGotFocus := { || oGetPesq:oGet:Picture := aSeek[ oCombo:nAt, 3 ],;
cChave := aSeek[ oCombo:nAt, 4 ], oGetPesq:cF3 := aSeek[ oCombo:nAt, 5 ],;
oGetPesq1:Refresh() }

DEFINE SBUTTON oBut1 FROM 67,  99  TYPE 1 ACTION ( nOpca := 1, nCombo := oCombo:nAt,;
oDlg:End() ) ENABLE of oDlg

DEFINE SBUTTON oBut2 FROM 67, 132   TYPE 2 ACTION ( nOpca := 0,;
oDlg:End() ) ENABLE of oDlg

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 1
	cChavePesq := RTRIM( cChavePesq )
	If !oTree:TreeSeek( aSeek[ nCombo, 1 ] + "-" + cChavePesq )
		Aviso( STR0037, STR0038, { STR0022 } )  //"Atencao !"###"Entidade nao encontrada !"###"Ok
	EndIf
EndIf

Return( .T. )



Function F110Click( oTree )

AEval( oMenu:aItems, { |x| x:Enable() } )

cCargo := oTree:GetCargo()
If Left( cCargo, 1 ) == "I"
	oScroll1:lVisible := .t.
	oScroll2:lVisible := .f.
	oScroll3:lVisible := .f.
	oScroll4:lVisible := .f.
	oScroll5:lVisible := .f.
ElseIf Left( cCargo, 1 ) == "P"
	oScroll1:lVisible := .f.
	oScroll2:lVisible := .f.
	oScroll3:lVisible := .f.
	oScroll4:lVisible := .f.
	oScroll5:lVisible := .t.
	AEval( oMenu:aItems, { |x| x:Disable() } )
	oMenu:aItems[6]:Enable()
ElseIf Left( cCargo, 1 ) == "S"
	oScroll1:lVisible := .f.
	oScroll2:lVisible := .f.
	oScroll3:lVisible := .f.
	oScroll4:lVisible := .t.
	oScroll5:lVisible := .f.
	AEval( oMenu:aItems, { |x| x:Disable() } )
	oMenu:aItems[3]:Enable()
	oMenu:aItems[5]:Enable()
	oMenu:aItems[6]:Enable()
ElseIf Left( cCargo, 1 ) == "K"
	oScroll1:lVisible := .f.
	oScroll2:lVisible := .f.
	oScroll3:lVisible := .t.
	oScroll4:lVisible := .f.
	oScroll5:lVisible := .f.
	AEval( oMenu:aItems, { |x| x:Disable() } )
	oMenu:aItems[5]:Enable()
	oMenu:aItems[6]:Enable()
ElseIf Left( cCargo, 1 ) == "A"
	oScroll1:lVisible := .f.
	oScroll2:lVisible := .t.
	oScroll3:lVisible := .f.
	oScroll4:lVisible := .f.
	oScroll5:lVisible := .f.
	AEval( oMenu:aItems, { |x| x:Disable() } )
	oMenu:aItems[3]:Enable()
	oMenu:aItems[5]:Enable()
	oMenu:aItems[6]:Enable()
Endif

CarregaDados(cCargo)

Return()

/////////////////////////////
Function CarregaDados(cCargo)

if Empty(oTree:cArqTree)
	Return
Endif

dbSelectarea("VSM")
dbSetOrder(6)

dbSelectArea(oTree:cArqTree)

If Left( cCargo, 1 ) == "I"
	dbSelectarea("VSM")
	if dbSeek(xFilial("VSM")+M->VS1_NUMORC+(oTree:cArqTree)->t_idtree+(oTree:cArqTree)->t_idcode)
		cDescI := VSM->VSM_DESINC
		oDescI:Refresh()
		cObsI := MSMM(VSM->VSM_OBSMEM,TamSx3("VSM_OBSERV")[1])
		oObsI:Refresh()
	Endif
ElseIf Left( cCargo, 1 ) == "P"
	dbSelectarea("VSM")
	if dbSeek(xFilial("VSM")+M->VS1_NUMORC+(oTree:cArqTree)->t_idtree+(oTree:cArqTree)->t_idcode)
		cGrupoP  := VSM->VSM_GRUITE
		oGrupoP:Refresh()
		cCodigoP := VSM->VSM_CODITE
		oCodigoP:Refresh()
		nQtdP    := VSM->VSM_QTDITE
		oQtdP:Refresh()
		dbSelectArea("SB1")
		dbSetOrder(7)
		if dbSeek(xFilial("SB1")+VSM->VSM_GRUITE+VSM->VSM_CODITE)
			cDescP := SB1->B1_DESC
			oDescP:Refresh()
		Endif
	Endif
ElseIf Left( cCargo, 1 ) == "S"
	dbSelectarea("VSM")
	if dbSeek(xFilial("VSM")+M->VS1_NUMORC+(oTree:cArqTree)->t_idtree+(oTree:cArqTree)->t_idcode)
		dbSelectArea("VO6")
		dbSetOrder(2)
		if dbSeek(xFilial("VO6")+FG_MARSRV(VSM->VSM_CODMAR,VSM->VSM_CODSER)+VSM->VSM_CODSER)
			cDescS := SB1->B1_DESC
			oDescS:Refresh()
			cGrupoS  := VO6->VO6_GRUSER
			oGrupoS:Refresh()
			cCodigoS := VO6->VO6_CODSER
			oCodigoS:Refresh()
			//			cTipoS  := VO6->VO6_TIPSER
			//			oTipoS:Refresh()
			cTempoS  := VO6->VO6_TEMFAB
			oTempoS:Refresh()
		Endif
	Endif
ElseIf Left( cCargo, 1 ) == "K"
	dbSelectarea("VSM")
	if dbSeek(xFilial("VSM")+M->VS1_NUMORC+(oTree:cArqTree)->t_idtree+(oTree:cArqTree)->t_idcode)
		cGrupoK  := VSM->VSM_GRUITE
		oGrupoK:Refresh()
		cCodigoK := VSM->VSM_CODITE
		oCodigoK:Refresh()
		dbSelectArea("VEH")
		dbSetOrder(1)
		if dbSeek(xFilial("VEH")+VSM->VSM_GRUITE+VSM->VSM_CODITE)
			cDescK := VEH->VEH_DESKIT
			oDescK:Refresh()
		Endif
	Endif
ElseIf Left( cCargo, 1 ) == "A"
	dbSelectarea("VSM")
	if dbSeek(xFilial("VSM")+M->VS1_NUMORC+(oTree:cArqTree)->t_idtree+(oTree:cArqTree)->t_idcode)
		dbSelectArea("VO6")
		dbSetOrder(2)
		if dbSeek(xFilial("VO6")+FG_MARSRV(VSM->VSM_CODMAR,VSM->VSM_CODSER)+VSM->VSM_CODSER)
			cDescSA := VO6->VO6_DESSER
			oDescSA:Refresh()
			cGrupoSA  := VO6->VO6_GRUSER
			oGrupoSA:Refresh()
			cCodigoSA := VO6->VO6_CODSER
			oCodigoSA:Refresh()
			//       cTipoSA  := VO6->VO6_TIPSER
			//			oTipoSA:Refresh()
			cTempoSA  := VO6->VO6_TEMFAB
			oTempoSA:Refresh()
		Endif
	Endif
Endif

dbSelectarea("VSM")

Return


Function F110Act( oTree, nX, nY, oMenu )

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilita todos os itens do menu                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AEval( oMenu:aItems, { |x| x:Disable() } )

cCargo := oTree:GetCargo()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Habilita as opcoes de acordo com a entidade do tree          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Left( cCargo, 3 ) == "1US"
oMenu:aItems[3]:enable()
If !lVisual
oMenu:aItems[2]:enable()
EndIf
ElseIf Left( cCargo, 3 ) == "2GR"
oMenu:aItems[3]:enable()
If !lVisual
oMenu:aItems[1]:enable()
oMenu:aItems[4]:enable()
oMenu:aItems[5]:enable()
EndIf
ElseIf Left( cCargo, 3 ) == "0MA"
If !lVisual
oMenu:aItems[4]:enable()
EndIf
EndIf

oMenu:aItems[6]:enable()

*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Menu PopUp                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oMenu:Activate( nX, nY, oTree )

Return()

///////////////////////////////////
Function F110Inconv(oTree, cCargo)

LOCAL cChave     := Space( 100 )

DEFINE MSDIALOG oDlg TITLE STR0466 FROM 09,0 TO 24,50 OF oMainWnd //inconveniente

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@ 00, 00 BITMAP oBmp RESNAME "LOGIN" oF oDlg SIZE 30, 120 NOBORDER WHEN .F. PIXEL

@ 03, 40 SAY STR0466 FONT oBold PIXEL //inconveniente

@ 14, 30 TO 16 ,400 LABEL '' OF oDlg   PIXEL

@ 23, 40 SAY STR0400 SIZE 40, 09 PIXEL //descricao
@ 23, 80 MSGET oDesc VAR cChave SIZE 115, 10 VALID .T. PIXEL

@ 37, 40 SAY   STR0472 SIZE 40,08 PIXEL  //observacao
@ 37, 80 GET oObs VAR cObsI MEMO SIZE 114,60 PIXEL

DEFINE SBUTTON oBut1 FROM 100, 130  TYPE 1 ACTION ( iif(!oTree:TreeSeek("I"+alltrim(cChave)), (nOpca := 1, oDlg:End()),.f.) ) ENABLE of oDlg

DEFINE SBUTTON oBut2 FROM 100, 165  TYPE 2 ACTION ( nOpca := 0, oDlg:End() ) ENABLE of oDlg

ACTIVATE MSDIALOG oDlg CENTERED

if nOpca == 1
	oTree:TreeSeek(cCargo)
	oTree:addItem(cChave,"I"+cChave,"UPDINFORMATION","UPDINFORMATION",,,1)
	GravaItem("I")
Endif

Return

////////////////////////////////
Function F110Peca(oTree, cCargo)



LOCAL cChavePesq := Space( 20 )

LOCAL nOpca      := 0

LOCAL oDlgP
LOCAL oBut1
LOCAL oBut2
LOCAL oGetPesq

cGruIte := ""

DEFINE MSDIALOG oDlgP TITLE STR0470 FROM 09,0 TO 25,50 OF oMainWnd //peca

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
@ 00, 00 BITMAP oBmp RESNAME "LOGIN" oF oDlgP SIZE 30, 120 NOBORDER WHEN .F. PIXEL

@ 03, 40 SAY STR0470 FONT oBold PIXEL //peca

@ 14, 30 TO 16 ,400 LABEL '' OF oDlgP   PIXEL

@ 23, 40 SAY STR0479 SIZE 70, 09 PIXEL OF oDlgP      //Codigo da Peca
@ 34, 40 MSGET oGetPesq VAR cChavePesq PICTURE "@!" F3 "B16"  SIZE 100, 10 VALID .T. PIXEL OF oDlgP

DEFINE SBUTTON oBut1 FROM 67,  99  TYPE 1 ACTION ( iif(!oTree:TreeSeek("P"+SB1->B1_COD), (nOpca := 1, oDlgP:End()),.f.) ) ENABLE of oDlgP

DEFINE SBUTTON oBut2 FROM 67, 132  TYPE 2 ACTION ( nOpca := 0, oDlgP:End() ) ENABLE of oDlgP

ACTIVATE MSDIALOG oDlgP CENTERED

if nOpca == 1
	oTree:TreeSeek(cCargo)
	oTree:addItem(SB1->B1_DESC,"P"+SB1->B1_COD,"PMSMATE","PMSMATE",,,2)
	GravaItem("P")
Endif

Return

////////////////////////////////
Function F110Serv(oTree, cCargo)

LOCAL cChavePesq := Space( 100 )

LOCAL nOpca      := 0

LOCAL oDlgs
LOCAL oBut1
LOCAL oBut2
LOCAL oGetPesq

DEFINE MSDIALOG oDlgS TITLE STR0469 FROM 09,0 TO 25,50 OF oMainWnd //Servico

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
@ 00, 00 BITMAP oBmp RESNAME "LOGIN" oF oDlgS SIZE 30, 120 NOBORDER WHEN .F. PIXEL

@ 03, 40 SAY STR0469 FONT oBold PIXEL //servico

@ 14, 30 TO 16 ,400 LABEL '' OF oDlgS   PIXEL

@ 23, 40 SAY STR0480 SIZE 70, 09 PIXEL OF oDlgS //"Codigo do Servico
@ 34, 40 MSGET oGetPesq VAR cChavePesq PICTURE "@!" F3 "V71"  SIZE 100, 10 VALID .T. PIXEL OF oDlgS

DEFINE SBUTTON oBut1 FROM 67,  99  TYPE 1 ACTION ( iif(!oTree:TreeSeek("S"+VO6->VO6_GRUSER+VO6->VO6_CODSER),(nOpca := 1, oDlgS:End()),.f.) ) ENABLE of oDlgS

DEFINE SBUTTON oBut2 FROM 67, 132   TYPE 2 ACTION ( nOpca := 0,;
oDlgS:End() ) ENABLE of oDlgS

ACTIVATE MSDIALOG oDlgS CENTERED

if nOpca == 1
	oTree:TreeSeek(cCargo)
	oTree:addItem(VO6->VO6_DESSER,"S"+VO6->VO6_GRUSER+VO6->VO6_CODSER,"BMPUSER","BMPUSER",,,2)
	GravaItem("S")
Endif

Return

///////////////////////////////
Function F110Kit(oTree, cCargo)




LOCAL cChavePesq := Space( 20 )
LOCAL nOpca      := 0

LOCAL oDlgK
LOCAL oBut1
LOCAL oBut2
LOCAL oGetPesq

DEFINE MSDIALOG oDlgK TITLE STR0476 FROM 09,0 TO 24,50 OF oMainWnd //ki de pecas

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
@ 00, 00 BITMAP oBmp RESNAME "LOGIN" oF oDlgK SIZE 30, 120 NOBORDER WHEN .F. PIXEL

@ 03, 40 SAY STR0476 FONT oBold PIXEL //kit de pecas

@ 14, 30 TO 16 ,400 LABEL '' OF oDlgK   PIXEL

@ 23, 40 SAY STR0481 SIZE 40, 09 PIXEL OF oDlgK  //Codigo do Kit
@ 34, 40 MSGET oGetPesq VAR cChavePesq PICTURE "@!" F3 "VEH"  SIZE 80, 10 VALID .T. PIXEL OF oDlgK

DEFINE SBUTTON oBut1 FROM 90, 130  TYPE 1 ACTION ( nOpca := 1, oDlgK:End() ) ENABLE of oDlgK

DEFINE SBUTTON oBut2 FROM 90, 165  TYPE 2 ACTION ( nOpca := 0, oDlgK:End() ) ENABLE of oDlgK

ACTIVATE MSDIALOG oDlgK CENTERED

if nOpca == 1
	oTree:TreeSeek(cCargo)
	oTree:addItem(VEH->VEH_DESKIT,"K"+VEH->VEH_DESKIT,"UPDWARNING","UPDWARNING",,,2)
	GravaItem("K")
	//Posiciona nos itens dos kits
	dbSelectarea("SB1")
	dbSetOrder(7)
	dbSelectArea("VE8")
	dbSetOrder(1)
	if dbSeek(xFilial("VE8")+VEH->VEH_GRUKIT+VEH->VEH_CODKIT)
		while !EOF() .and. VE8->VE8_GRUKIT+VE8->VE8_CODKIT == VEH->VEH_GRUKIT+VEH->VEH_CODKIT
			SB1->(dbSeek(xFilial("SB1")+VE8->VE8_GRUITE+VE8->VE8_CODITE))
			oTree:TreeSeek("K"+VEH->VEH_DESKIT)
			oTree:addItem(SB1->B1_DESC,"P"+SB1->B1_COD,"PMSMATE","PMSMATE",,,2)
			GravaItem("P")
			dbSelectArea("VE8")
			dbSkip()
		enddo
	Endif
Endif

Return


Function F110SerAgru(oTree, cCargo)



LOCAL cChavePesq := Space( 20 )
LOCAL nOpca      := 0

LOCAL oDlgSA
LOCAL oBut1
LOCAL oBut2
LOCAL oGetPesq

DEFINE MSDIALOG oDlgSA TITLE STR0467 FROM 09,0 TO 26,50 OF oMainWnd 		//Servico Agrupado

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@ 00, 00 BITMAP oBmp RESNAME "LOGIN" OF oDlgSA SIZE 30, 130 NOBORDER WHEN .F. PIXEL		//LOGIN

@ 03, 40 SAY STR0467 FONT oBold PIXEL					//Servico Agrupado

@ 14, 30 TO 16 ,400 LABEL '' OF oDlgSA   PIXEL

@ 20, 40 SAY STR0313 SIZE 70, 09 PIXEL OF oDlgSA 		//Marca
@ 27, 40 MSGET oGetMar VAR cGetMar PICTURE "@!" F3 "V71"  SIZE 100, 10 VALID .T. PIXEL OF oDlgSA

@ 43, 40 SAY STR0482 SIZE 70, 09 PIXEL OF oDlgSA		//Modelo
@ 50, 40 MSGET oGetMod1 VAR cGetMod1 PICTURE "@!" F3 "V71"  SIZE 100, 10 VALID .T. PIXEL OF oDlgSA

@ 67, 40 SAY STR0483 SIZE 70, 09 PIXEL OF oDlgSA		//Modelo especifico
@ 74, 40 MSGET oGetMod2 VAR cGetMod2 PICTURE "@!" F3 "V71"  SIZE 100, 10 VALID .T. PIXEL OF oDlgSA

@ 91, 40 SAY STR0480 SIZE 70, 09 PIXEL OF oDlgSA		//Codigo do Servico
@ 98, 40 MSGET oGetPesq VAR cChavePesq PICTURE "@!" F3 "V71"  SIZE 100, 10 VALID .T. PIXEL OF oDlgSA

DEFINE SBUTTON oBut1 FROM 113, 130  TYPE 1 ACTION ( nOpca := 1, oDlgSA:End() ) ENABLE of oDlgSA

DEFINE SBUTTON oBut2 FROM 113, 165  TYPE 2 ACTION ( nOpca := 0, oDlgSA:End() ) ENABLE of oDlgSA

ACTIVATE MSDIALOG oDlgSA CENTERED

if nOpca == 1
	oTree:TreeSeek(cCargo)
	oTree:addItem(VO6->VO6_DESSER,"A"+VO6->VO6_DESSER,"RPMIMPORT","RPMIMPORT",,,2)
	GravaItem("A")
	//Posiciona nos itens da tabela de revisao
	dbSelectarea("SB1")
	dbSetOrder(7)
	dbSelectArea("VO8")
	dbSetOrder(1)
	if dbSeek(xFilial("VO8")+VEH->VEH_GRUKIT+VEH->VEH_CODKIT)
		while !EOF() .and. VE8->VE8_GRUKIT+VE8->VE8_CODKIT == VEH->VEH_GRUKIT+VEH->VEH_CODKIT
			SB1->(dbSeek(xFilial("SB1")+VE8->VE8_GRUITE+VE8->VE8_CODITE))
			oTree:TreeSeek("K"+VEH->VEH_DESKIT)
			oTree:addItem(SB1->B1_DESC,"P"+SB1->B1_COD,"PMSMATE","PMSMATE",,,2)
			GravaItem("P")
			dbSelectArea("VE8")
			dbSkip()
		enddo
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GravaItem    ³ Autor ³ ANDRE             ³ Data ³ 08/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava a estrutura do treeview na tabela VSM                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GravaItem(cTipo)

Local cSequen := ""

dbSelectarea("VSM")
dbSetOrder(1)

dbSelectArea(oTree:cArqTree)
VSM->(RecLock("VSM",.t.))
VSM->VSM_FILIAL := xFilial("VSM")
VSM->VSM_NUMORC := M->VS1_NUMORC
VSM->VSM_TIPTEM := M->VS1_TIPTEM
VSM->VSM_IDLIST := t_idlist
VSM->VSM_IDTREE := t_idtree
VSM->VSM_IDCODE := t_idcode
VSM->VSM_ISTREE := t_istree
VSM->VSM_PROMPT := t_prompt
VSM->VSM_CARGO  := t_cargo
VSM->VSM_CLIENT := t_client

If Empty(Val(t_idtree))
	cSequen := Right(t_idcode,3)
Else
	cSequen := Right(t_idtree,3)
EndIf
VSM->VSM_SEQUEN := cSequen
if cTipo == "I"
	VSM->VSM_TIPAGR := "1"
	VSM->VSM_CODINC := ""
	VSM->VSM_DESINC := t_prompt
	MSMM(,TamSx3("VSM_OBSERV")[1],,cObsI,1,,,"VSM","VSM_OBSMEM")
Elseif cTipo == "P"
	VSM->VSM_TIPAGR := "2"
	VSM->VSM_GRUITE := SB1->B1_GRUPO
	VSM->VSM_CODITE := SB1->B1_CODITE
Elseif cTipo == "S"
	VSM->VSM_TIPAGR := "3"
	VSM->VSM_CODMAR := VO6->VO6_CODMAR
	VSM->VSM_CODSER := VO6->VO6_CODSER
	nTemPad         := FG_TEMPAD(VV1->VV1_CHAINT,VO6->VO6_CODSER,if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM),,VO6->VO6_CODMAR)
	nValHor         := If(VOK->VOK_INCMOB $ "0/2/5",0,FG_VALHOR(VOI->VOI_TIPTEM,dDataBase))
	nValSer         := (nTemPad /100) * nValHor
	VSM->VSM_VALOR  := nValSer
Elseif cTipo == "K"
	VSM->VSM_TIPAGR := "2"
	VSM->VSM_GRUITE := VEH->VEH_GRUKIT
	VSM->VSM_CODITE := VEH->VEH_CODKIT
Elseif cTipo == "A"
	VSM->VSM_TIPAGR := "3"
	VSM->VSM_CODMAR := VO6->VO6_CODMAR
	VSM->VSM_CODSER := VO6->VO6_CODSER
	nTemPad         := FG_TEMPAD(VV1->VV1_CHAINT,VO6->VO6_CODSER,if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM),,VO6->VO6_CODMAR)
	nValHor         := If(VOK->VOK_INCMOB $ "0/2/5",0,FG_VALHOR(VOI->VOI_TIPTEM,dDataBase))
	nValSer         := (nTemPad /100) * nValHor
	VSM->VSM_VALOR  := nValSer
Endif

VSM->(MsUnlock())
dbSelectArea("VSM")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Grava_Peca   ³ Autor ³ ANDRE             ³ Data ³ 08/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava a digitacao da peca                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Grava_Inc()

dbSelectarea("VSM")
dbSetOrder(6)

dbSelectArea(oTree:cArqTree)
dbSelectarea("VSM")
if dbSeek(xFilial("VSM")+M->VS1_NUMORC+(oTree:cArqTree)->t_idtree+(oTree:cArqTree)->t_idcode)
	VSM->(RecLock("VSM",.f.))
	VSM->VSM_TIPAGR := "1"
	VSM->VSM_CODINC := ""
	VSM->VSM_DESINC := cDescI
	MSMM(,TamSx3("VSM_OBSERV")[1],,cObsI,1,,,"VSM","VSM_OBSMEM")
	VSM->(MsUnlock())
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Grava_Peca   ³ Autor ³ ANDRE             ³ Data ³ 08/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava a digitacao da peca                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Grava_Peca()

dbSelectarea("VSM")
dbSetOrder(6)

dbSelectArea(oTree:cArqTree)
dbSelectarea("VSM")
if dbSeek(xFilial("VSM")+M->VS1_NUMORC+(oTree:cArqTree)->t_idtree+(oTree:cArqTree)->t_idcode)
	VSM->(RecLock("VSM",.f.))
	VSM->VSM_GRUITE := alltrim(cGrupoP)
	VSM->VSM_CODITE := alltrim(cCodigoP)
	VSM->VSM_QTDITE := nQtdP
	VSM->VSM_VALOR  := nValorP
	VSM->VSM_PERDES := nPerDesP
	VSM->VSM_VALDES := nValDesP
	VSM->(MsUnlock())
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Grava_Srv    ³ Autor ³ ANDRE             ³ Data ³ 08/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava a digitacao do servico                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Grava_Srv()

dbSelectarea("VSM")
dbSetOrder(6)

dbSelectArea(oTree:cArqTree)
dbSelectarea("VSM")
if dbSeek(xFilial("VSM")+M->VS1_NUMORC+(oTree:cArqTree)->t_idtree+(oTree:cArqTree)->t_idcode)
	VSM->(RecLock("VSM",.f.))
	VSM->VSM_CODSER := alltrim(cCodigoS)
	VSM->VSM_TIPSER := alltrim(cTipoS)
	VSM->VSM_VALOR  := nValorS
	VSM->VSM_PERDES := nPerDesS
	VSM->VSM_VALDES := nValDesS
	VSM->(MsUnlock())
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Grava_SAgr   ³ Autor ³ ANDRE             ³ Data ³ 08/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava a digitacao do Servico Agrupado                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Grava_SAgr()

dbSelectarea("VSM")
dbSetOrder(6)

dbSelectArea(oTree:cArqTree)
dbSelectarea("VSM")
if dbSeek(xFilial("VSM")+M->VS1_NUMORC+(oTree:cArqTree)->t_idtree+(oTree:cArqTree)->t_idcode)
	VSM->(RecLock("VSM",.f.))
	VSM->VSM_CODSER := alltrim(cCodigoSA)
	VSM->VSM_TIPSER := alltrim(cTipoSA)
	VSM->VSM_VALOR  := nValorSA
	VSM->VSM_PERDES := nPerDesSA
	VSM->VSM_VALDES := nValDesSA
	VSM->(MsUnlock())
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ABRTRE010    ³ Autor ³ ANDRE             ³ Data ³ 08/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Abre a estrutura do treeview da tabela VSM                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TREEDEL110(cCargo)

Local cStr := ""
Local cID  := ""

if Empty(oTree:cArqTree)
	Return
Endif

carregadados(cCargo)

dbSelectarea("VSM")
dbSetOrder(6)

dbSelectArea(oTree:cArqTree)

If Left( cCargo, 1 ) == "I"
	cStr := STR0484			//Inconveniente
ElseIf Left( cCargo, 1 ) == "P"
	cStr := STR0485			//Peca
ElseIf Left( cCargo, 1 ) == "S"
	cStr := STR0486			//Servico
ElseIf Left( cCargo, 1 ) == "K"
	cStr := STR0487			//Kite de pecas
ElseIf Left( cCargo, 1 ) == "A"
	cStr := STR0488			//Servico agrupado
Endif

cStr += alltrim((oTree:cArqTree)->t_prompt)

dbSelectarea("VSM")
if dbSeek(xFilial("VSM")+M->VS1_NUMORC+(oTree:cArqTree)->t_idtree+(oTree:cArqTree)->t_idcode)
	if MsgYesNo( STR0489  +" "+cStr+" ?",STR0490 ) //Apaga # Exclusao
		cID := (oTree:cArqTree)->t_idcode
		oTree:DelItem()
		dbSelectarea("VSM")
		RecLock("VSM",.f.,.t.)
		VSM->(dbDelete())
		MsUnlock()
		WriteSx2("VSM")
		
		//Apaga os itens dependentes
		dbSelectarea("VSM")
		dbSetOrder(6)
		if dbSeek(xFilial("VSM")+M->VS1_NUMORC+cID)
			while !EOF() .and. VSM->VSM_IDTREE == cID
				RecLock("VSM",.f.,.t.)
				VSM->(dbDelete())
				MsUnlock()
				WriteSx2("VSM")
				dbSkip()
			Enddo
		Endif
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ABRTRE010    ³ Autor ³ ANDRE             ³ Data ³ 08/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Abre a estrutura do treeview da tabela VSM                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ABRTRE010()

Local cFirst := ""

dbSelectarea("VSM")
dbSetOrder(7)
if !dbSeek(xFilial("VSM")+M->VS1_NUMORC)
	Return
Endif
cFirst := VSM->VSM_CARGO
while !EOF() .and. VSM->VSM_NUMORC == M->VS1_NUMORC
	if Substr(VSM->VSM_CARGO,1,1) == "I"
		cBMP := "UPDINFORMATION"
	Elseif Substr(VSM->VSM_CARGO,1,1) == "K"
		cBMP := "UPDWARNING"
	Elseif Substr(VSM->VSM_CARGO,1,1) == "A"
		cBMP := "RPMIMPORT"
	Elseif Substr(VSM->VSM_CARGO,1,1) == "S"
		cBMP := "BMPUSER"
	Elseif Substr(VSM->VSM_CARGO,1,1) == "P"
		cBMP := "PMSMATE"
	Endif
	if VSM->VSM_IDTREE == "0000000"
		oTree:TreeSeek(cFirst)
		oTree:addItem(VSM->VSM_PROMPT,VSM->VSM_CARGO,cBMP,cBMP,,,1)
	Else
		nPos   := Recno()
		if dbSeek(xFilial("VSM")+M->VS1_NUMORC+VSM->VSM_IDTREE)
			oTree:TreeSeek(ALLTRIM(VSM->VSM_CARGO))
			dbGoto(nPos)
			oTree:addItem(VSM->VSM_PROMPT,VSM->VSM_CARGO,cBMP,cBMP,,,2)
		Else
			dbGoto(nPos)
		Endif
	Endif
	dbSkip()
EndDo

dbSetOrder(1)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ EnchoiceTemp ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Opcoes do atendimento                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EnchoiceTemp(objeto,aCampos)

Local nPos

lCol := .t.
nCol := 4
nLin := 1
For nPos := 1 to Len(aCampos)
	
	//Label
	@ nLin, nCol SAY &("say_"+aCampos[nPos,1]) VAR "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" OF objeto Pixel COLOR iif((Len(aCampos[nPos]) >= 11 .and. aCampos[nPos,11] <> Nil),aCampos[nPos,11],CLR_BLACK)
	&("say_"+aCampos[nPos,1]):cCaption := aCampos[nPos,2]
	&("say_"+aCampos[nPos,1]):cTitle   := aCampos[nPos,2]
	
	//Edit
	if aCampos[nPos,3] == "C"
		&("get_"+aCampos[nPos,1]) := space(aCampos[nPos,4])
	Elseif aCampos[nPos,3] == "D"
		&("get_"+aCampos[nPos,1]) := ctod("")
	Else
		&("get_"+aCampos[nPos,1]) := "000000.0000"
	Endif
	
	@ nLin+7, nCol GET &("o_"+aCampos[nPos,1]) VAR &("get_"+aCampos[nPos,1]) OF objeto PIXEL
	&("o_"+aCampos[nPos,1]):cName      := "o_"+aCampos[nPos,1]
	&("o_"+aCampos[nPos,1]):nWidth     := (aCampos[nPos,5]*3)+30
	&("o_"+aCampos[nPos,1]):nHeight    := 19
	&("o_"+aCampos[nPos,1]):lShowHint  := .F.
	&("o_"+aCampos[nPos,1]):lReadOnly  := !aCampos[nPos,7]
	&("o_"+aCampos[nPos,1]):Align      := 0
	&("o_"+aCampos[nPos,1]):lVisibleControl := .T.
	&("o_"+aCampos[nPos,1]):lPassword  := .F.
	&("o_"+aCampos[nPos,1]):lHasButton := .T.
	&("o_"+aCampos[nPos,1]):cVariable  := "get_"+aCampos[nPos,1]
	&("o_"+aCampos[nPos,1]):bSetGet    := &( "{|U| If( PCount() == 0, get_"+aCampos[nPos,1]+", get_"+aCampos[nPos,1]+" := U ) }" )
	&("o_"+aCampos[nPos,1]):Picture    := iif((Len(aCampos[nPos]) >= 6 .and. aCampos[nPos,6] <> Nil),aCampos[nPos,6],"@!")
	if Len(aCampos[nPos]) >= 9 .and. aCampos[nPos,9] <> Nil
		&("o_"+aCampos[nPos,1]):cF3     := aCampos[nPos,9]
	Endif
	if Len(aCampos[nPos]) >= 8 .and. aCampos[nPos,8] <> Nil
		&("o_"+aCampos[nPos,1]):bValid  := &( "{|U| "+aCampos[nPos,8]+" }" )
	Endif
	if Len(aCampos[nPos]) >= 10 .and. aCampos[nPos,10] <> Nil
		@ nLin+7,nCol+((aCampos[nPos,5]*3)/2)+20 BUTTON &("obt_"+aCampos[nPos,1]) PROMPT OemToAnsi(STR0491) OF objeto SIZE 15,9.5 PIXEL //Mais
		&("obt_"+aCampos[nPos,1]):bAction  := &( "{|U| "+aCampos[nPos,10]+" }" )
	Endif
	
	if lCol
		lCol := .f.
		nCol := 170
	Else
		lCol := .t.
		nCol := 4
		nLin := nLin + 17
	Endif
	
Next

Return


Function LINOK110(lValid)

Local cont
Local nObrig
Local bCampo := { |nCPO| Field(nCPO) }
Local	nRecNo := TMP->(RecNo())

If lValid .and. nOpc == 3
	if TMP->VSM_TIPAGR == "1"
		if Empty(TMP->VSM_CODINC) .AND. Empty(TMP->VSM_DESINC) .And. !TMP->VSM_FLAG
			Help(1," ","OBRIGAT",,"Inconveniente",4,1)
			Return(.f.)
		Endif
	Else
		For nObrig:=1 to len(aHeader)
			if !( Alltrim(aHeader[nObrig,2]) $ "VSM_CODMAR/VSM_NUMORC" )
				If ( !TMP->VSM_TIPAGR $ "3/5" .Or. !( Alltrim(aHeader[nObrig,2]) $ "VSM_CODGRU/VSM_GRUITE" ) ) ;
					.And. x3obrigat(aHeader[nObrig,2]) .And. Empty(&("TMP->"+aHeader[nObrig,2])) .And. !TMP->VSM_FLAG
					Help(1," ","OBRIGAT",,aHeader[nObrig,1],4,1)
					Return(.f.)
				EndIf
			Endif
		Next
	Endif
	
	cQuebraAgr := ""
	cQuebraSeq := ""
	cMostraSeq := ""
	cMostraAgr := ""
	DbSelectArea("TMP")
	nRecNo := RecNo()
	For cont := 1 TO TMP->(FCount())
		M->&(EVAL(bCampo,cont)) := FieldGet(cont)
	Next
	
	DbGoTop()
	Do While !Eof()
		If (( TMP->VSM_SEQUEN == M->VSM_SEQUEN .And. TMP->VSM_TIPAGR == M->VSM_TIPAGR ;
			.And. ( ( TMP->VSM_TIPAGR == "1" .And. ( TMP->VSM_CODGRU+TMP->VSM_CODINC == M->VSM_CODGRU+M->VSM_CODINC .Or. TMP->VSM_SEQUEN == M->VSM_SEQUEN ) ) ;
			.Or.    ( TMP->VSM_TIPAGR $ "2/4" .And. TMP->VSM_GRUITE+TMP->VSM_CODITE == M->VSM_GRUITE+M->VSM_CODITE) ;
			.Or.    ( TMP->VSM_TIPAGR $ "3/5" .And. TMP->VSM_CODSER == M->VSM_CODSER ) ) ) ;
			.And.RecNo()#nRecNo) .And. !TMP->VSM_FLAG
			Help("  ",1,"EXISTCHAV")
			DbGoTo(nRecNo)
			Return(.f.)
		EndIf
		
		If cQuebraAgr # TMP->VSM_SEQUEN+TMP->VSM_TIPAGR
			cMostraAgr += StrZero(TMP->(Recno()),8)+"/"
		EndIf
		cQuebraAgr := TMP->VSM_SEQUEN+TMP->VSM_TIPAGR
		
		If cQuebraSeq # TMP->VSM_SEQUEN
			cMostraSeq += StrZero(TMP->(Recno()),8)+"/"
		EndIf
		cQuebraSeq := TMP->VSM_SEQUEN
		
		DbSkip()
	EndDo
	DbGoTo(nRecNo)
	
EndIf

TOTALI110()

Return(.t.)


Function FS_AALTER(cAliasCh,nLenaCols,oNomObj,aVetHeader)

Local aArea       := {}
Local cSele       := Alias()
Local cVarCh      := ""
Local aAlter      := {}

Local nAlterHeader:=0
Local aVHeaderW  := If(aVetHeader != Nil,aClone(aVetHeader),aClone(aHeader))

aArea := sGetArea(aArea , Alias())
aArea := sGetArea(aArea , "SIX")

dbSelectArea("SIX")
dbSetOrder(1)
If DbSeek( cAliasCh + "1" )
	cVarCh := Alltrim( SIX->CHAVE )
Else
	cVarCh := &(cAliasCh+"->(IndexKey())")
EndIf

Aadd(aAlter,{})
Aadd(aAlter,{})
Aadd(aAlter,{})
For nAlterHeader:=1 to Len(aVHeaderW)
	//   If !( Alltrim( aVHeaderW[nAlterHeader,2] ) $ cVarCh )
	Aadd(aAlter[1],aVHeaderW[nAlterHeader,2] )
	//   EndIf
	if Alltrim( aVHeaderW[nAlterHeader,2] ) <> "VSM_DESITE"
		Aadd(aAlter[2],aVHeaderW[nAlterHeader,2] )
	Endif
	if Alltrim( aVHeaderW[nAlterHeader,2] ) <> "VSM_CODGRU"
		Aadd(aAlter[3],aVHeaderW[nAlterHeader,2] )
	Endif
Next

If M->VSM_TIPAGR == "1"
	oNomObj:aAlter := oNomObj:oBrowse:aAlter := aClone(aAlter[1])
ElseIf M->VSM_TIPAGR $ "2/4"
	oNomObj:aAlter := oNomObj:oBrowse:aAlter := aClone(aAlter[2])
ElseIf M->VSM_TIPAGR $ "3/5"
	oNomObj:aAlter := oNomObj:oBrowse:aAlter := aClone(aAlter[3])
EndIf

// Volta posicoes originais
sRestArea(aArea)

dbSelectArea(cSele)

Return


Function CPOVSM110()
Local bBlock
Local nCntFor
Local lInc   := .t.
Local nRecNo := TMP->(Recno())
Local bCampo := { |nCPO| Field(nCPO) }

if ReadVar() == "M->VSM_CODITE"
	
	M->VSM_CODITE := FG_ITESUB(M->VSM_GRUITE+M->VSM_CODITE)
	
	if SB1->B1_MSBLQL $ "1S"
		MsgInfo(STR0337,STR0148) //Este item esta Bloqueado... # Atencao!
		Return(.f.)
	Endif
	
	if M->VSM_TIPAGR $ "2/4"
		
		dbSelectArea("VEH")
		dbSetOrder(1)
		if dbSeek(xfilial("VEH")+M->VSM_GRUITE+M->VSM_CODITE)
			dbSelectArea("VE8")
			dbSetOrder(1)
			if dbSeek(xFilial("VE8")+VEH->VEH_GRUKIT+VEH->VEH_CODKIT)
				while !EOF() .and. VE8->VE8_GRUKIT+VE8->VE8_CODKIT == VEH->VEH_GRUKIT+VEH->VEH_CODKIT
					
					lInc := .t.
					dbSelectArea("TMP")
					dbGoTop()
					Do While !Eof()
						If ( TMP->VSM_SEQUEN == M->VSM_SEQUEN .And. TMP->VSM_TIPAGR $ "2/4" .And. TMP->VSM_GRUITE+TMP->VSM_CODITE == VE8->VE8_GRUITE+VE8->VE8_CODITE)
							lInc := .f.
						EndIf
						dbSkip()
					EndDo
					dbGoTo(nRecNo)
					
					if lInc
						SB1->(dbSetOrder(7))
						SB1->(dbSeek(xFilial("SB1")+VE8->VE8_GRUITE+VE8->VE8_CODITE))
						DbSelectArea("TMP")
						RecLock("TMP",.t.)
						TMP->VSM_NUMORC := M->VS1_NUMORC
						TMP->VSM_SEQUEN := M->VSM_SEQUEN
						TMP->VSM_TIPAGR := "4"
						TMP->VSM_GRUITE := VE8->VE8_GRUITE
						TMP->VSM_CODITE := VE8->VE8_CODITE
						TMP->VSM_DESITE := SB1->B1_DESC
						TMP->VSM_QTDITE := VE8->VE8_QTDADE
						if Empty(TMP->VSM_TIPTEM)
							TMP->VSM_TIPTEM := M->VS1_TIPTEM
						Endif
						if Empty(TMP->VSM_CODMAR)
							TMP->VSM_CODMAR := M->VS1_CODMAR
						Endif
						TMP->VSM_TOTAL  := TMP->VSM_VALOR * TMP->VSM_QTDITE

						bBlock := ErrorBlock()
						bErro  := ErrorBlock( { |e| FGX_CheckBug(e) } )

						dbSelectArea("VEG")
						dbSetOrder(2)
						cForPad := GETMV("MV_FMLPECA")
						if dbSeek(xFilial("VEG")+"04"+&cForPad)
							TMP->VSM_VALOR  := &(VEG->VEG_FORMUL)
						Else
							TMP->VSM_VALOR  :=  SB1->B1_PRV1
						Endif
						
						ErrorBlock(bBlock)
						
						TMP->VSM_FLAG   := .f.
						MsUnLock()
						
						If cQuebraAgr # TMP->VSM_SEQUEN+TMP->VSM_TIPAGR
							cMostraAgr += StrZero(TMP->(Recno()),8)+"/"
						EndIf
						cQuebraAgr := TMP->VSM_SEQUEN+TMP->VSM_TIPAGR
						
						If cQuebraSeq # TMP->VSM_SEQUEN
							cMostraSeq += StrZero(TMP->(Recno()),8)+"/"
						EndIf
						cQuebraSeq := TMP->VSM_SEQUEN
					Endif
					
					&(cGetDados):nCount := TMP->(RecCount())
					dbSelectArea("VE8")
					dbSkip()
				Enddo
			Endif
		Endif
	Endif
	SB1->(dbSetOrder(7))
	SB1->(dbSeek(xFilial("SB1")+M->VSM_GRUITE+M->VSM_CODITE))
	dbSelectArea("VEG")
	dbSetOrder(2)
	cForPad := GETMV("MV_FMLPECA")
	if dbSeek(xFilial("VEG")+"04"+&cForPad)
		dbSelectArea("TMP")
		RecLock("TMP",.f.)

		bBlock := ErrorBlock()
		bErro  := ErrorBlock( { |e| FGX_CheckBug(e) } )
		
		TMP->VSM_VALOR  := &(VEG->VEG_FORMUL)
		
		ErrorBlock(bBlock)
		
		TMP->VSM_TOTAL  := TMP->VSM_VALOR * TMP->VSM_QTDITE
		MsUnlock()
	Else
		dbSelectArea("TMP")
		RecLock("TMP",.f.)
		TMP->VSM_VALOR  := SB1->B1_PRV1
		TMP->VSM_TOTAL  := TMP->VSM_VALOR * TMP->VSM_QTDITE
		MsUnlock()
	Endif
Endif

if ReadVar() == "M->VSM_CODSER"
	if M->VSM_TIPAGR $ "3/5" //Servico Agrupado
		dbSelectArea("VO6")
		dbSetOrder(2)
		if dbSeek(xfilial("VO6")+FG_MARSRV(M->VSM_CODMAR,M->VSM_CODSER)+M->VSM_CODSER)
			nRecVO6 := Recno()
			dbSelectArea("VO8")
			dbSetOrder(1)
			if dbSeek(xFilial("VO8")+VO6->VO6_CODMAR+VO6->VO6_MODVEI+VO6->VO6_SEGMOD+VO6->VO6_CODSER)
				while !EOF() .and. VO6->VO6_CODMAR+VO6->VO6_MODVEI+VO6->VO6_SEGMOD+VO6->VO6_CODSER == VO8->VO8_CODMAR+VO8->VO8_MODVEI+VO8->VO8_SEGMOD+VO8->VO8_CODSER
					
					lInc := .t.
					dbSelectArea("TMP")
					dbGoTop()
					Do While !Eof()
						If ( TMP->VSM_SEQUEN == M->VSM_SEQUEN .And. TMP->VSM_TIPAGR $ "2/4" .And. TMP->VSM_GRUITE+TMP->VSM_CODITE == VO8->VO8_GRUITE+VO8->VO8_CODITE)
							lInc := .f.
						EndIf
						If ( TMP->VSM_SEQUEN == M->VSM_SEQUEN .And. TMP->VSM_TIPAGR $ "3/5" .And. TMP->VSM_CODSER == VO8->VO8_CODSER)
							lInc := .f.
						EndIf
						dbSkip()
					EndDo
					dbGoTo(nRecNo)
					
					if lInc
						
						If VO8->VO8_TIPAGR == "1" //Servicos
							VO6->(dbSeek(xfilial("VO6")+FG_MARSRV(M->VSM_CODMAR,VO8->VO8_CODSRV)+VO8->VO8_CODSRV))
							VOK->(dbSeek(xfilial("VOK")+M->VSM_TIPSER))
						ElseIf VO8->VO8_TIPAGR == "2" //Pecas
							SB1->(dbSetOrder(7))
							SB1->(dbSeek(xFilial("SB1")+VO8->VO8_GRUITE+VO8->VO8_CODITE))
						Endif
						
						DbSelectArea("TMP")
						RecLock("TMP",.t.)
						TMP->VSM_NUMORC := M->VS1_NUMORC
						TMP->VSM_SEQUEN := M->VSM_SEQUEN
						TMP->VSM_TIPAGR := iif(VO8->VO8_TIPAGR == "1","5","4")
						if VO8->VO8_TIPAGR == "1" //Servicos
							TMP->VSM_CODSER := VO8->VO8_CODSRV
							TMP->VSM_DESSER := VO6->VO6_DESSER
							
							nTemPad         := FG_TEMPAD(VV1->VV1_CHAINT,VO6->VO6_CODSER,if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM),,VO6->VO6_CODMAR)
							nValHor         := If(VOK->VOK_INCMOB $ "0/2/5",0,FG_VALHOR(M->VS1_TIPTEM,dDataBase))
							nValSer         := (nTemPad /100) * nValHor
							TMP->VSM_VALOR  := nValSer
							
						Else
							TMP->VSM_GRUITE := VO8->VO8_GRUITE
							TMP->VSM_CODITE := VO8->VO8_CODITE
							TMP->VSM_QTDITE := VO8->VO8_QTDITE
							TMP->VSM_DESITE := SB1->B1_DESC
							
							bBlock := ErrorBlock()
							bErro  := ErrorBlock( { |e| FGX_CheckBug(e) } )

							dbSelectArea("VEG")
							dbSetOrder(2)
							cForPad := GETMV("MV_FMLPECA")
							if dbSeek(xFilial("VEG")+"04"+&cForPad)
								TMP->VSM_VALOR  := &(VEG->VEG_FORMUL)
							Else
								TMP->VSM_VALOR  :=  SB1->B1_PRV1
							Endif
							
							ErrorBlock(bBlock)
							
						Endif
						
						if Empty(TMP->VSM_TIPTEM)
							TMP->VSM_TIPTEM := M->VS1_TIPTEM
						Endif
						if Empty(TMP->VSM_CODMAR)
							TMP->VSM_CODMAR := M->VS1_CODMAR
						Endif
						TMP->VSM_TOTAL  := TMP->VSM_VALOR * TMP->VSM_QTDITE
						TMP->VSM_FLAG   := .f.
						MsUnLock()
						
						If cQuebraAgr # TMP->VSM_SEQUEN+TMP->VSM_TIPAGR
							cMostraAgr += StrZero(TMP->(Recno()),8)+"/"
						EndIf
						cQuebraAgr := TMP->VSM_SEQUEN+TMP->VSM_TIPAGR
						
						If cQuebraSeq # TMP->VSM_SEQUEN
							cMostraSeq += StrZero(TMP->(Recno()),8)+"/"
						EndIf
						cQuebraSeq := TMP->VSM_SEQUEN
					Endif
					
					&(cGetDados):nCount := TMP->(RecCount())
					VO6->(dbGoto(nRecVO6))
					dbSelectArea("VO8")
					dbSkip()
				Enddo
			Endif
		Endif
	Endif
Endif

if M->VSM_TIPAGR $ "3/5"
	if !Empty(TMP->VSM_CODSER) .and. !Empty(TMP->VSM_TIPSER)
		VO6->(dbSeek(xfilial("VO6")+FG_MARSRV(M->VSM_CODMAR,VO8->VO8_CODSRV)+VO8->VO8_CODSRV))
		VOK->(dbSeek(xfilial("VOK")+M->VSM_TIPSER))
		nTemPad         := FG_TEMPAD(VV1->VV1_CHAINT,M->VSM_CODSER,if(VOK->VOK_INCTEM == "3","1",VOK->VOK_INCTEM),,VO6->VO6_CODMAR)
		nValHor         := If(VOK->VOK_INCMOB $ "0/2/5",0,FG_VALHOR(M->VS1_TIPTEM,dDataBase))
		nValSer         := (nTemPad /100) * nValHor
		TMP->VSM_VALOR  := nValSer
		TMP->VSM_TOTAL  := nValSer
	Endif
Endif

if ReadVar() == "M->VSM_QTDITE"
	dbSelectArea("TMP")
	RecLock("TMP",.f.)
	TMP->VSM_TOTAL  := TMP->VSM_VALOR * M->VSM_QTDITE
	MsUnlock()
Endif

if ReadVar() == "M->VSM_VALDES"
	dbSelectArea("TMP")
	RecLock("TMP",.f.)
	if M->VSM_TIPAGR $ "3/5"
		TMP->VSM_TOTAL  := TMP->VSM_VALOR-M->VSM_VALDES
	Else
		TMP->VSM_TOTAL  := (TMP->VSM_VALOR * TMP->VSM_QTDITE)-M->VSM_VALDES
	Endif
	MsUnlock()
Endif

FS_AALTER("VSM",n,&(cGetDados),aHeaderI)
dbSelectArea("TMP")
dbGoTo(nRecNo)
dbSelectArea("TMP")
RecLock("TMP",.f.)
if Empty(TMP->VSM_CODMAR)
	TMP->VSM_CODMAR := M->VS1_CODMAR
Endif
if Empty(TMP->VSM_TIPTEM)
	TMP->VSM_TIPTEM := M->VS1_TIPTEM
Endif
MsUnlock()
&(cGetDados):nCount := TMP->(RecCount())

TOTALI110()

dbSelectArea("TMP")
For nCntFor := 1 TO FCount()
	M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next

Return .t.


/////////////////////
Function FS_TIPO110()

oFolder2:lVisible  := .t.
if Type(cGetDados) <> "U"
	&(cGetDados):oBrowse:lVisible := .f.
Endif
aHeader  := aClone(aHeaderP)
aCols    := aClone(aColsP)
n        := 1
oGetPecas:oBrowse:Refresh()

Return .t.

Function FS_TP110()

cTipo := ""

Return(cTipo)

Function TOTALI110(cTipo)

Local	nRecNo := TMP->(RecNo())

Default cTipo := "N"

dbSelectArea("TMP")
if cTipo == "D"
	if !TMP->VSM_FLAG
		RecLock("TMP",.f.)
		TMP->VSM_FLAG := .t.
		MsUnlock()
	Else
		RecLock("TMP",.f.)
		TMP->VSM_FLAG := .f.
		MsUnlock()
	Endif
Endif

nTotPec := 0
nTotSrv := 0
nTotDes := 0
nTotOrc := 0
dbSelectArea("TMP")
dbGoTop()
Do While !Eof()
	if !TMP->VSM_FLAG
		if TMP->VSM_TIPAGR $ "2/4"
			nTotPec := nTotPec + TMP->VSM_TOTAL
		ElseIf TMP->VSM_TIPAGR $ "3/5"
			nTotSrv := nTotSrv + TMP->VSM_TOTAL
		Endif
		nTotDes := nTotDes + TMP->VSM_VALDES
		nTotOrc := (nTotPec + nTotSrv) - nTotDes
	Endif
	dbSkip()
Enddo
oTotPec:Refresh()
oTotSrv:Refresh()
oTotDes:Refresh()
oTotOrc:Refresh()
dbGoTo(nRecNo)
&(cGetDados):oBrowse:Refresh()

Return


Function FS_KIT110(lBot)

Local _ni, cont, nPos
Local aRet := {}
Local lPromo := .f.
Local cGruKit := M->VS3_GRUITE
Local cCodKit := M->VS3_CODITE

default lBot := .f.

if !lExeKit
	Return(aRet)
Endif

if lBot
	cGruKit := Nil
	cCodKit := Nil
Endif

if "B" $ GetNewPar("MV_PESCOR","B")
	aRet := OFIOC040(cGruKit,cCodKit)
	if (valtype(aRet) = "A") .and. (Len(aRet) > 0)
		if !lBot
			aCols[n,FG_POSVAR("VS3_CODITE","aHeaderP")] := &(ReadVar())
		Endif
		For cont:=1 to Len(aRet)
			
			if lBot
				cGruKit := space(4)
				cCodKit := space(27)
			Endif
			
			if cont > 1
				if !lBot .or. !Empty(aCols[n,FG_POSVAR("VS3_CODITE","aHeaderP")])
					AADD(aCols,Array(nUsadoP+1))
				Endif
				aCols[Len(aCols),nUsadoP+1]:=.F.
				For _ni:=1 to nUsadoP
					aCols[Len(aCols),_ni]:=CriaVar(aHeaderP[_ni,2])
				Next
				nPos := Len(aCols)
			Else
				nPos := n
			Endif
			
			dbSelectArea("VEH")
			dbSetOrder(1)
			dbSeek(xFilial("VEH")+cGruKit+cCodKit)
			
			SB1->(dbSetOrder(7))
			SB1->(dbSeek(xFilial("SB1")+aRet[cont,1]+aRet[cont,2]))
			
			n := nPos
			MaFisRef("IT_PRODUTO","VS300",SB1->B1_COD)
			MaFisRef("IT_TES","VS300",aRet[cont,3])
			MaFisRef("IT_VALMERC","VS300",aRet[cont,5]*aRet[cont,4])
			
			M->VS3_GRUITE := aRet[cont,1]
			M->VS3_CODITE := aRet[cont,2]
			aCols[nPos,FG_POSVAR("VS3_SEQUEN","aHeaderP")] := StrZero(nPos,3)
			aCols[nPos,FG_POSVAR("VS3_GRUITE","aHeaderP")] := aRet[cont,1]
			aCols[nPos,FG_POSVAR("VS3_CODITE","aHeaderP")] := aRet[cont,2]
			
			FG_MEMVAR()
			dbSelectArea("SX3")
			dbSetOrder(2)
			if dbSeek("VS3_CODITE")
				lExeKit := .f.
				&(SX3->X3_VALID)
				&(SX3->X3_VLDUSER)
				lExeKit := .t.
			Endif
			dbSetOrder(1)
			
			aCols[nPos,FG_POSVAR("VS3_CODTES","aHeaderP")] := aRet[cont,3]
			aCols[nPos,FG_POSVAR("VS3_QTDITE","aHeaderP")] := aRet[cont,4]
			aCols[nPos,FG_POSVAR("VS3_FORMUL","aHeaderP")] := M->VS1_FORMUL
			if GetNewPar("MV_FMLKIT","") == ""
				aCols[nPos,FG_POSVAR("VS3_FORMUL","aHeaderP")] := GetNewPar("MV_FMLKIT","")
			Endif
			
			aCols[nPos,FG_POSVAR("VS3_VALPEC","aHeaderP")] := aRet[cont,5]
			aCols[nPos,FG_POSVAR("VS3_VALTOT","aHeaderP")] := aRet[cont,5]*aRet[cont,4]
			//			aCols[nPos,FG_POSVAR("VS3_DESITE","aHeaderP")] := SB1->B1_DESC
			
			M->VS3_LOCAL :=  IIf(M->VS1_ORCACE$"1 ",SB1->B1_LOCPAD,GetMv("MV_RESITE"))
			aCols[nPos,FG_POSVAR("VS3_LOCAL","aHeaderP")] := M->VS3_LOCAL
			
			aCols[nPos,FG_POSVAR("VS3_CODTES","aHeaderP")] := SB1->B1_TS
			If FG_POSVAR("VS3_GRUKIT","aHeaderP") > 0
				aCols[nPos,FG_POSVAR("VS3_GRUKIT","aHeaderP")] := VEH->VEH_GRUKIT
			EndIf
			If FG_POSVAR("VS3_CODKIT","aHeaderP") > 0
				aCols[nPos,FG_POSVAR("VS3_CODKIT","aHeaderP")] := VEH->VEH_CODKIT
			EndIf
			if Type("M->VS3_QTDEST") <> "U"
				nSaldo := FS_SALDOPEC(xFilial("SB2")+SB1->B1_COD+LocIte110())
				M->VS3_QTDEST := nSaldo
				aCols[nPos,FG_POSVAR("VS3_QTDEST","aHeaderP")] := nSaldo
			Endif
			
			cCenCus := VAI->VAI_CC
			cCodMar := M->VS1_CODMAR
			if Empty(cCodMar)
				cCodMar := SBM->BM_CODMAR
			Endif
			
			//			dbselectArea("VEN")
			//			dbSetOrder(8)
			//			if dbSeek(xFilial("VEN")+cCodMar+cCenCus+VEH->VEH_GRUKIT+VEH->VEH_CODKIT+aRet[cont,1]+aRet[cont,2])
			//			   lPromo := .t.
			//				aCols[nPos,FG_POSVAR("VS3_VALPEC","aHeaderP")] := VEN->VEN_VALPRO
			//				aCols[nPos,FG_POSVAR("VS3_VALTOT","aHeaderP")] := VEN->VEN_VALPRO*aRet[cont,4]
			//			Endif
			
		Next
		aColsP := Aclone(aCols)
		oGetPecas:oBrowse:Refresh()
	Endif
Endif

if lPromo
	MsgInfo(STR0492 ,STR0148) //"Peca(s) do kit em promocao... # Atencao!
Endif

Return(aRet)

/*
Static Function MenuDef()
Local aRotina := {{"", "",0,1},;
{"", "",0,2},;
{"", "",0,3},;
{"", "",0,4} }
Return (aRotina)
*/

///  Valid SX3 - BALCAO Atualiza Grupo automaticamente apos funcao FG_POSSB1() - Andre Luis Almeida - 25/01/07  ///
Function FS_BATUGRP()
if Left(Funname(),4) == "OFIX" .or. FunName() == "OFIOM350" .or. FunName() == "OFIOM430" .or. FunName() == "M_CONSPEC"
	return .t.
endif
aCols[n,FG_POSVAR("VS3_GRUITE","aHeaderP")] := M->VS3_GRUITE := SB1->B1_GRUPO
Return(.t.)


Function FS_CONF110()

Local wVar
Local aArea := GetArea()

dbSelectArea("SX3")
dbSetOrder(2)
if dbSeek("VS3_CONBAR")
	if FG_POSVAR("VS3_CONBAR","aHeaderP") > 0
		wVar := "M->"+x3_campo
		&wVar:= CriaVar(x3_campo)
		aCols[n,FG_POSVAR("VS3_CONBAR","aHeaderP")] := &wVar
	Endif
Endif

RestArea(aArea)

Return

Static Function FS_PESQORC()
Local lRet := .t.
If !Empty(cNumOrc)
	cNumOrc:=strzero(val(cNumOrc),8)
	dbSelectArea("VS1")
	dbSetOrder(1)
	If !dbSeek(xFilial("VS1")+cNumOrc)
		MsgAlert(STR0493 ,STR0148) //Orcamento nao encontrado! # Atencao!
		lRet := .f.
	Else
		if !Empty(VS1->VS1_NUMPED)
			MsgAlert(STR0494 ,STR0148) //Orcamento ja faturado! # Atencao!
			lRet := .f.
		Endif
	EndIf
EndIf
Return(lRet)


Function FS_NFRET()

Local lRet := .f.
Local aArea := GetArea()

dbSelectArea("VS1")
dbSetOrder(3)
if dbSeek(xFilial("VS1")+SF2->F2_DOC+SF2->F2_SERIE)
	if !Empty(VS1->VS1_AUTENV)
		lRet := .t.
	Endif
Endif

RestArea(aArea)

Return(lRet)


Function LocIte110(lMem,aCols_,nPos)

Local cLoc     := SB1->B1_LOCPAD
Default aCols_ := {}
Default lMem   := .t.  

if nCkPerg1 == 2 .or. cAbrir == .t.
   cLoc := VS3->VS3_LOCAL
Endif   
If M->VS1_ORCACE $ "1 "//.or. oFolder:nOption == 3
	if Len(aCols_) = 0
		if lMem
			if !Empty(M->VS3_LOCAL)
				cLoc := M->VS3_LOCAL
			Endif
		Else
			if !Empty(VS3->VS3_LOCAL)
				cLoc := VS3->VS3_LOCAL
			Endif
		Endif
	Else
		if FG_POSVAR("VS3_LOCAL","aHeaderP") > 0
			if !Empty(aCols_[nPos,FG_POSVAR("VS3_LOCAL","aHeaderP")])
				cLoc := aCols_[nPos,FG_POSVAR("VS3_LOCAL","aHeaderP")]
			Endif
		Endif
	Endif
Endif

Return(cLoc)


Function FS_NOVO110()

Local nCntFor

//	if !MsgYesNo("Inclui novo orcamento ?","Atencao!")
//	   Return(.f.)
//	Endif

if !lSalvou
	if MsgYesNo(STR0495 ,STR0148) //Salva Orcamento aberto? # Atencao!
		FS_FINORC('1',.F.)
		lSalvou := .t.
	Endif
Endif

oGetMGet:oBox:Enable()
oGetSrvcs:oBrowse:Enable()
oGetPecas:oBrowse:Enable()

oGetMGet:lActive := .t.
oGetSrvcs:lActive := .t.
oGetPecas:lActive := .t.
oLbIteRel:Enable()

lBotOpc := .t.

Limpa_Var()

Inclui := .t.
Inclui2:= .t.

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VS1")
While !EOF() .and. X3_ARQUIVO == "VS1"
	wVar := "M->"+x3_campo
	&wVar:= CriaVar(x3_campo)
	dbSkip()
EndDo
M->VS1_DATVAL := dDataBase+GetNewPar("MV_DTLIMIT",0)
M->VS1_OBSERV := ""

if cOpeMov2 == "2"
	M->VS1_TIPORC := "1"  // Venda de Pecas
	M->VS1_CODTES := cTesPad
Endif
if GetNewPar("MV_GSXEORC","N") == "S"
	ConfirmSx8()
Endif

aColsP[1,FG_POSVAR("VS3_SEQUEN","aHeaderP")]:= [001]
aColsS[1,FG_POSVAR("VS4_SEQUEN","aHeaderS")]:= [001]

oGetMGet:obox:Refresh()

aCols   := aClone(aColsS)
aHeader := aClone(aHeaderS)
n       := nS
oGetSrvcs:oBrowse:Refresh()

aCols   := aClone(aColsP)
aHeader := aClone(aHeaderP)
n       := nP
oGetPecas:oBrowse:Refresh()

if Type(cGetDados) <> "U"
	if &(cGetDados):oBrowse:lVisible
		aHeader := aclone(aHeaderI)
		&(cGetDados):oBrowse:Refresh()
	Endif
Endif

lJaPerg := .t.
lSalvou := .f.

dbSelectArea("SE4")
if dbSeek(xFilial("SE4")+M->VS1_FORPAG)
	cTipPag := M->VS1_FORPAG
	cDesPag := SE4->E4_DESCRI
	M->VS1_FORPAG := cTipPag
	M->VS1_DESFPG := cDesPag
Endif

dbSelectArea("SA6")
if dbSeek(xFilial("SA6")+M->VS1_CODBCO)
	M->VS1_NOMBCO := SA6->A6_NOME
	cCodBco := M->VS1_CODBCO
	cDesBco := M->VS1_NOMBCO
Endif

dbSelectArea("VEG")
if dbSeek(xFilial("VEG")+M->VS1_FORMUL)
	M->VS1_NOMFOR := VEG->VEG_DESCRI
Endif

if !Inclui
	cAlias := Alias()
	dbSelectArea("VS1")
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
	dbSelectarea(cAlias)
Endif

if Inclui
	dbSelectArea("VAI")
	dbSetOrder(4)
	dbSeek(xFilial("VAI")+__cUserID)
	
	dbSelectArea("SA3")
	dbSetOrder(1)
	if !dbSeek(xFilial("SA3")+VAI->VAI_CODVEN)
		MsgInfo(STR0496 ,STR0148) //Usuario sem codigo de vendedor relacionado! # Atencao!
		Return .f.
	Endif
	M->VS1_CODVEN := VAI->VAI_CODVEN
	cCodVen := SA3->A3_COD
	M->VS1_NOMVEN := SA3->A3_NOME
	M->VS1_CENCUS := VAI->VAI_CC
Endif

oGetMGet:SetFocus()

Return


Function FILB07110(cGrupo)

Local cSql := "@"

cSql += "B1_FILIAL='" + xFilial("SB1") + "'"
cSql += " AND D_E_L_E_T_ <> '*'"
cSql += " AND B1_GRUPO= '"+cGrupo+"'"

Return(cSql)

Function CHKCRECLI()
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
If Alltrim(GetNewPar("MV_TITNCC","N")) == "S"
	if Len(aTitCre) > 0
		nTipCre := 1
		DEFINE MSDIALOG oDlgTit FROM  04,10 TO 18,60 TITLE STR0497 OF oMainWnd		//Titulos de Credito
		
		@ 012, 001 LISTBOX oLbTit FIELDS HEADER	OemToAnsi(""),;
		OemToAnsi(STR0498),;			//Prefixo
		OemToAnsi(STR0499),;			//Numero"
		OemToAnsi(STR0500),;			//Vencto
		OemToAnsi(STR0111);				//"Valor
		COLSIZES 30,40,50,50,50;
		SIZE 198,64 OF oDlgTit PIXEL ON DBLCLICK (aTitCre[oLbTit:nAt,1]:=!aTitCre[oLbTit:nAt,1],FS_VALCRE(oLbTit:nAt,nTipCre),oLbTit:Refresh())
		
		oLbTit:SetArray(aTitCre)
		oLbTit:bLine := { || { IIF(aTitCre[oLbTit:nAt,1],oOk,oNo) ,;
		aTitCre[oLbTit:nAt,2] ,;
		aTitCre[oLbTit:nAt,3] ,;
		aTitCre[oLbTit:nAt,4] ,;
		Transform(aTitCre[oLbTit:nAt,5],"@E 999,999,999.99") }}
		
		@ 77,001 Say OemToAnsi(STR0502) SIZE 60,08 OF oDlgTit PIXEL COLOR CLR_BLUE 	//Forma de utilizacao
		
		@ 85,001 RADIO oRdTipo VAR nTipCre 3D SIZE 70,10 PROMPT;
		OemToAnsi(STR0503), OemToAnsi(STR0501);//Desconto # Abate no valor do Titulo
		OF oDlgTit PIXEL
		
		ACTIVATE MSDIALOG oDlgTit CENTER ON INIT (EnchoiceBar(oDlgTit,{|| xOpca := 1, iif(FS_TITNCC(),oDlgTit:End(),.t.) },{|| xOpca := 2,oDlgTit:End()}))
	Endif
EndIf
Return

///////////////////////////
Static Function FS_SITTRP()

Local aIteTrb := {}

If Empty(get_grupo) .or. Empty(get_codite)
	Return
Endif

DbSelectArea("SB1")
DbSetOrder(7)
DbSeek(xFilial("SB1")+get_grupo+get_codite)

DbSelectArea("SF4")
DbSetOrder(1)
DbSeek(xFilial("SF4")+SB1->B1_TS)

cAliqIcm := ""
If SF4->F4_CREDICM $ "S.1" .or. SB1->B1_PICM > 0
	cStrIcm  := STR0504	//ICMS
	cStrIcm1 := STR0505	//TRIBUTADO
	If SB1->B1_PICM > 0
		cAliqIcm := Transform(SB1->B1_PICM,"@E 999.99 %")
	Endif
Else
	// Manoel - 18/03/209 - Na Versao 5.08 SF4->F4_CREDST = "1" era igual a SIM
	//							 - Na Versao 10   de ser usado SF4->F4_CREDST = "2" (Retido ST) - de acordo com a Juliana
	//	If SF4->F4_CREDST $ "S.1"
	If SF4->F4_CREDST == "2"
		cStrIcm  := STR0504	//ICMS
		cStrIcm1 := STR0506	//COM SUBST. TRIBUTARIA
	Else
		cStrIcm  := STR0504	//ICMS
		cStrIcm1 := STR0507	//ISENTO
	Endif
Endif

cAliqIss := ""
If SF4->F4_ISS $ "S.1" .or. SB1->B1_ALIQISS > 0
	cStrIss  := STR0508	//ISS
	cStrIss1 := STR0505	//TRIBUTADO
	If SB1->B1_ALIQISS > 0
		cAliqIss := Transform(SB1->B1_ALIQISS,"@E 999.99 %")
	Else
		cAliqIss := Transform(GetMv("MV_ALIQISS"),"@E 999.99 %")
	Endif
Else
	cStrIss  := STR0508	//ISS
	cStrIss1 := STR0507	//isento
Endif

cAliqPis := ""
cAliqCof := ""
If SF4->F4_PISCRED == "3" .or. SB1->B1_PPIS > 0
	cStrPis  := STR0509	//PIS
	cStrPis1 := STR0510	//MONOFASICO
	cStrCof  := STR0511	//COFINS
	cStrCof1 := STR0510	//MONOFASICO
Else
	If SF4->F4_PISCOF == "1" .or. SB1->B1_PPIS > 0
		cStrPis  := STR0509	//PIS
		cStrPis1 := STR0505	//TRIBUTADO
		If SB1->B1_PPIS > 0
			cAliqPis := Transform(SB1->B1_PPIS,"@E 999.99 %")
		Else
			cAliqPis := Transform(GetMv("MV_TXPIS"),"@E 999.99 %")
		Endif
		cStrCof  := STR0511	//COFINS
		cStrCof1 := STR0510	//MONOFASICO
	ElseIf SF4->F4_PISCOF == "2" .or. SB1->B1_PCOFINS > 0
		cStrPis  := STR0509	//PIS
		cStrPis1 := STR0510	//MONOFASICO
		cStrCof  := STR0511	//COFINS
		cStrCof1 := STR0505	//TRIBUTADO
		If SB1->B1_PCOFINS > 0
			cAliqCof := Transform(SB1->B1_PCOFINS,"@E 999.99 %")
		Else
			cAliqCof := Transform(GetMv("MV_TXCOFIN"),"@E 999.99 %")
		Endif
	Else
		cStrPis  := STR0509	//PIS
		cStrPis1 := STR0505	//TRIBUTADO
		If SB1->B1_PPIS > 0
			cAliqPis := Transform(SB1->B1_PPIS,"@E 999.99 %")
		Else
			cAliqPis := Transform(GetMv("MV_TXPIS"),"@E 999.99 %")
		Endif
		cStrCof  := STR0511	//COFINS
		cStrCof1 := STR0505	//TRIBUTADO
		If SB1->B1_PCOFINS > 0
			cAliqCof := Transform(SB1->B1_PCOFINS,"@E 999.99 %")
		Else
			cAliqCof := Transform(GetMv("MV_TXCOFIN"),"@E 999.99 %")
		Endif
	Endif
Endif

If SB1->B1_INSS $ "S.1"
	cStrIns  := STR0512	//INSS
	cStrIns1 := STR0505	//TRIBUTADO
Else
	cStrIns  := STR0512	//INSS
	cStrIns1 := STR0507	//ISENTO
Endif

cAliqCsl := ""
If SB1->B1_CSLL $ "S.1" .or. SB1->B1_PCSLL > 0
	cStrCsl  := STR0513	//CSLL
	cStrCsl1 := STR0505	//TRIBUTADO
	If SB1->B1_PCSLL > 0
		cAliqCsl := Transform(SB1->B1_PCSLL,"@E 999.99 %")
	Endif
Else
	cStrCsl  := STR0513	//CSLL
	cStrCsl1 := STR0507	//ISENTO
Endif

If SB1->B1_IRRF $ "S.1"
	cStrIrf  := STR0514	//IRRF
	cStrIrf1 := STR0505	//TRIBUTADO
Else
	cStrIrf  := STR0514	//IRRF
	cStrIrf1 := STR0507	//ISENTO
Endif

aadd(aIteTrb,{cStrIcm,cStrIcm1,cAliqIcm})
aadd(aIteTrb,{cStrIss,cStrIss1,cAliqIss})
aadd(aIteTrb,{cStrPis,cStrPis1,cAliqPis})

aadd(aIteTrb,{cStrCof,cStrCof1,cAliqCof})
aadd(aIteTrb,{cStrCsl,cStrCsl1,cAliqCsl})

aadd(aIteTrb,{cStrIns,cStrIns1,""})
aadd(aIteTrb,{cStrIrf,cStrIrf1,""})

nOpca := 0
DEFINE MSDIALOG oDlgTrb TITLE OemtoAnsi( STR0306 ) FROM  01,10 TO 16,55 OF oMainWnd		//Situacao Tributaria

@ 014,002 LISTBOX oLbSit FIELDS HEADER  OemToAnsi(STR0515),; //Tributo
OemToAnsi(STR0314),; //Situacao
OemToAnsi(STR0111);		//Valor
COLSIZES 40,80,50;
SIZE 178,100 OF oDlgTrb PIXEL

oLbSit:SetArray(aIteTrb)
oLbSit:bLine := { || { aIteTrb[oLbSit:nAt,1] ,;
aIteTrb[oLbSit:nAt,2] ,;
aIteTrb[oLbSit:nAt,3]}}

ACTIVATE MSDIALOG oDlgTrb CENTER ON INIT EnchoiceBar(oDlgTrb,{|| oDlgTrb:End() },{|| oDlgTrb:End() })

Return


Function FS_TITNCC()

Local cont, i
Local nValNCC := 0
If Alltrim(GetNewPar("MV_TITNCC","N")) == "S"
	For cont := 1 to Len(aTitCre)
		if aTitCre[cont,1]
			nValNCC += aTitCre[cont,5]
		Endif
	Next
	
	if nTipCre == 1 .and. nValNCC >= nTotOrc
		MsgInfo(STR0516 ,STR0148) //Para utilizar o credito como desconto, o valor nao podera ser igual ou maior do que o valor do orcamento.. # Atencao!
		Return .f.
	Endif
	if nValNCC > 0 .and. nTipCre == 1
		
		M->VS1_PERDES := 0
		
		aCols   := aClone(aColsP)
		aHeader := aClone(aHeaderP)
		M->VS1_DESCON := nValNCC
		
		nDesconto     := M->VS1_DESCON
		nValResto     := nDesconto
		nMaiorValor   := 0
		
		For i:=1 to Len(aCols)
			if !TipoTes(aCols[i,FG_POSVAR("VS3_CODTES","aHeaderP")])
				Loop
			Endif
			n := i
			
			M->VS3_GRUITE := aCols[i,fg_posvar("VS3_GRUITE")]
			M->VS3_CODITE := aCols[i,fg_posvar("VS3_CODITE")]
			M->VS3_FORMUL := aCols[i,fg_posvar("VS3_FORMUL")]
			M->VS3_MODVEI := aCols[i,fg_posvar("VS3_MODVEI")]
			
			M->VS3_VALPEC := aCols[i,fg_posvar("VS3_VALPEC","aHeaderP")]
			M->VS3_QTDITE := aCols[i,fg_posvar("VS3_QTDITE","aHeaderP")]
			M->VS3_VALTOT := aCols[i,fg_posvar("VS3_VALTOT","aHeaderP")]
			
			nPerIte  := (M->VS3_VALTOT / nTotOrc) * 100
			nValDesc := (nDesconto / 100) * nPerIte
			
			if nValResto = 0
				nValDesc := 0
			Elseif nValResto < nValDesc
				nValDesc  := nValResto
				nValResto := 0
			Endif
			
			aCols[i,fg_posvar("VS3_VALDES","aHeaderP")] := nValDesc
			M->VS3_VALDES := aCols[i,fg_posvar("VS3_VALDES","aHeaderP")]
			aCols[i,FG_POSVAR("VS3_PERDES","aHeaderP")] := (M->VS3_VALDES / (M->VS3_VALPEC * M->VS3_QTDITE)) * 100
			M->VS3_PERDES := aCols[i,fg_posvar("VS3_PERDES","aHeaderP")]
			aCols[i,FG_POSVAR("VS3_VALTOT","aHeaderP")] := (M->VS3_VALPEC * M->VS3_QTDITE ) - M->VS3_VALDES
			
			SBM->(dbSetOrder(1))
			SBM->(dbSeek(xFilial("SBM")+M->VS3_GRUITE))
			lRetDes := FG_PERDES(SBM->BM_CODMAR,M->VS1_CENCUS,"P",M->VS3_GRUITE,M->VS3_CODITE,M->VS3_QTDITE,M->VS3_PERDES,,M->VS3_MODVEI)
			if !lRetDes
				if GetMv("MV_PLIBDMP") == "N"
					Return .f.
				Endif
			Endif
			
			if nValResto > 0
				nValResto -= nValDesc
				if aCols[i,fg_posvar("VS3_VALTOT","aHeaderP")] > nMaiorValor
					nMaiorValor := aCols[i,fg_posvar("VS3_VALTOT","aHeaderP")]
					y := i
				Endif
			Endif
			
			nTotDes += nValDesc
			nTotOrc -= nValDesc
			
			MaFisAlt("IT_DESCONTO",M->VS3_VALDES,n)
			
		Next
		
		aColsP   := aClone(aCols)
		aHeaderP := aClone(aHeader)
		
		oGetPecas:oBrowse:Refresh()
		oGetPecas:oBrowse:SetFocus()
		
		M->VS1_TITNCC := ""
		For cont := 1 to Len(aTitCre)
			if aTitCre[cont,1]
				if !Empty(M->VS1_TITNCC)
					M->VS1_TITNCC += "/"
				Endif
				M->VS1_TITNCC += Str(aTitCre[cont,6])
			Endif
		Next
		
	Elseif nValNCC > 0 .and. nTipCre == 2
		
		if nValNCC > nTotOrc
			nValNCC := nTotOrc
		Endif
		
		nTotTit -= nValNCC
		nTotCre := nValNCC
		
		M->VS1_TITNCC := ""
		For cont := 1 to Len(aTitCre)
			if aTitCre[cont,1]
				if !Empty(M->VS1_TITNCC)
					M->VS1_TITNCC += "/"
				Endif
				M->VS1_TITNCC += Str(aTitCre[cont,6])
			Endif
		Next
		
	Endif
EndIf

Return(.t.)


Function FS_VALCRE(nPos)
Local lRet := .t.
Local cont
Local nValNCC := 0
If Alltrim(GetNewPar("MV_TITNCC","N")) == "S"
	For cont := 1 to Len(aTitCre)
		if aTitCre[cont,1]
			nValNCC += aTitCre[cont,5]
		Endif
	Next
	if nValNCC > nTotPec .and. (nValNCC - aTitCre[nPos,5]) > nTotPec
		MsgInfo(STR0517 ,STR0148) //Total de desconto ja atingiu o valor do orcamento # Atencao!
		aTitCre[nPos,1] := .f.
		lRet := .f.
	Endif
EndIf
Return(lRet)


Function FS_FILBOTAO(nPag,nBot)

Local lRet := .t.

if ExistBlock("VALBOT110")
	lRet := ExecBlock("VALBOT110",.f.,.f.,{nPag,nBot})
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OPCOES110    ³ Autor ³ ANDRE             ³ Data ³ 08/03/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Opcoes do atendimento                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OPCOES110( oObj, nX, nY, oMenu, nMenu )

Local cont, cont2, nqtd

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilita todos os itens do menu                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//AEval( oMenu:aItems, { |x| x:Disable() } )

For cont := 1 to 3
	if nMenu = 1
		nqtd := 14
	elseif nMenu = 2
		nqtd := 8
	else
		nqtd := 4
	endif
	For cont2 := 0 to nqtd
		if !FS_FILBOTAO(cont,cont2)
			if nMenu = 1
				oMenu:aItems[cont2]:Disable()
			elseif nMenu = 2
				oMenu2:aItems[cont2]:Disable()
			else
				oMenu3:aItems[cont2]:Disable()
			endif
		Endif
	Next
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Menu PopUp                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if nMenu == 1
	oMenu:Activate( nX, nY, oObj )
Elseif nMenu == 2
	oMenu2:Activate( nX, nY, oObj )
Else
	oMenu3:Activate( nX, nY, oObj )
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIOM110  ºAutor  ³Microsiga           º Data ³  09/20/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CARRAGENDA()

If Empty(cNumAgenda)
	
	&& Seleciona agendamento
	FS_SELEAGE(M->VS1_CHASSI,M->VS1_CODFRO,M->VS1_PLAVEI,M->VS1_CHAINT)
	
EndIf

If !Empty(cNumAgenda)
	
	DbSelectArea("VSO")
	DbSetOrder(1)
	DbSeek( xFilial("VSO") + cNumAgenda )
	
	If Select("TMP") > 0
		&& Deleta importacao do agendamento anterior
		DbSelectArea("TMP")
		Dele all For TMP->VSM_TIPREG == "A" .Or. Empty(TMP->VSM_SEQUEN+TMP->VSM_CODGRU+TMP->VSM_CODINC)
		Pack
		
		If VSO->( Found() )
			
			DbSelectArea("VSO")
			cSeqInc := "000"
			Do While !Eof() .And. VSO->VSO_FILIAL==xFilial("VSO") .And. VSO->VSO_NUMIDE == cNumAgenda
				
				If !lImportAge
					If !( lImportAge := MsgYesNo(STR0518 ,OemToAnsi(STR0148))) //Importar inconvenientes do agendamento? # Atencao!
						Exit
					EndIf
				EndIf
				
				DbSelectArea("VSP")
				DbSetOrder(1)
				DbSeek( xFilial("VSP") + VSO->VSO_NUMIDE )
				Do While !Eof() .And. VSP->VSP_FILIAL==xFilial("VSP") .And. VSP->VSP_NUMIDE == VSO->VSO_NUMIDE
					
					cSeqInc := Soma1(cSeqInc,3)
					
					DbSelectArea("TMP")
					//							If RecCount() == 1
					//							   RecLock("TMP",.F.)
					//							Else
					RecLock("TMP",.T.)
					//							EndIf
					TMP->VSM_TIPAGR := "1"
					TMP->VSM_CODMAR := VV1->VV1_CODMAR
					TMP->VSM_TIPREG := "A"
					TMP->VSM_SEQUEN := cSeqInc
					TMP->VSM_CODGRU := VSP->VSP_CODGRU
					//						   TMP->VSM_DESGRU := Posicione("VSK",1,xFilial("VSK")+VV1->VV1_CODMAR+VSP->VSP_CODGRU,"VSK_DESGRU")
					TMP->VSM_CODINC := VSP->VSP_CODINC
					TMP->VSM_DESINC := Posicione("VSL",1,xFilial("VSL")+VV1->VV1_CODMAR+VSP->VSP_CODGRU+VSP->VSP_CODINC,"VSL_DESINC")
					TMP->VSM_TIPTEM := VSL->VSL_TIPTEM
					
					TMP->VSM_APROVA := "1"
					
					MsUnLock()
					
					
					DbSelectArea("VSP")
					DbSkip()
				EndDo
				
				DbSelectArea("VSO")
				DbSkip()
			EndDo
			
			TMP->(DbGoTop())
			
		EndIf
		
		/*		If lImportAge
		DbSelectArea("TMP")
		RecLock("TMP",.T.)
		MsUnLock()
		EndIf
		*/
		
		DbSelectArea("TMP")
		If RecCount() == 0
			RecLock("TMP",.T.)
			MsUnLock()
		EndIf
		&& Terceira Aba
		//		FS_CRIAGETDB()
		
		&(cGetDados):oBrowse:Refresh()
	EndIf
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VLDDTPG   ³ Autor ³ Otavio Favarelli  ³ Data ³ 12/06/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica dados digitados na entrada e parcelas para gerar  ³±±
±±³          ³ o SE1 corretamente.                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VLDDTPG()
Local lProbTit:= .f. // Verifica se existem problemas com as Datas dos Titulos
Local lObrigat:= .f. // Verifica se existem campos obrigatorios em branco
Local conti, contii

For conti := 1 to Len(aColsC)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Otavio - 25/06/2009 - FNC 00000014055                        ³
	//³ Verifica obrigatorios dos campos da MsMGet Atual             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For contii := 1 to Len(aHeaderC)
		If !Empty(aColsC[conti,FG_POSVAR("VS9_TIPPAG")])
			If X3Obrigat(aHeader[contii,2]) .and. Empty(aColsC[conti,FG_POSVAR(aHeader[contii,2])]) .and. !aColsC[conti,Len(aCols[conti])]
				Help(" ",1,"OBRIGAT2",,RetTitle(aHeaderC[contii,2]),4,1 )
				lObrigat:= .t.
				Exit
			EndIf
		EndIf
	Next
Next

If lObrigat
	Return .f.
EndIf

If Len(aColsC) >= 1 .and. !Empty(aColsC[1,FG_POSVAR("VS9_TIPPAG")])
	For conti := 1 to Len(aColsC)
		If !aColsC[conti,len(aColsC[conti])]
			If aColsC[conti,FG_POSVAR("VS9_DATPAG")] < dDatabase
				lProbTit := .t.
				Exit
			EndIf
		EndIf
	Next
EndIf
If !lProbTit // Nenhum problema com as Datas dos Titulos de Entrada
	For conti := 1 to Len(aIteParc) //Verifica as Datas das Parcelas do SE1
		If aIteParc[conti,2] <> 0
			If aIteParc[conti,1] < dDatabase
				lProbTit := .t.
				Exit
			EndIf
		EndIf
	Next
EndIf

If lProbTit
	MsgStop(STR0528,STR0148) // "Existem divergencias nas Datas de Vencimento dos Titulos", "Atencao"
	Return .f.
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_SALVATMºAutor  ³Fabio               º Data ³  10/16/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Salva/Restaura arquivo trabalho do orcamento               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
/* Comentado pois da erro em
	DbUseArea( .T.,, cArqTra , cArqNov, .f. )
	pelo Projeto Rússia*/
/*Static Function FS_SALVATMP(cArqOri,cArqNov,lCarrVar)

Local nObrig := 0

Default lCarrVar := .f.

If Type("cArqTra") # "U" .And. Select(cArqOri) > 0
	
	DbSelectArea(cArqOri)
	DbCloseArea()
	DbUseArea( .T.,, cArqTra , cArqNov, .f. )
	
	If lCarrVar
		
		cQuebraAgr := ""
		cQuebraSeq := ""
		cMostraSeq := ""
		cMostraAgr := ""
		DbSelectArea(cArqNov)
		DbGoTop()
		Do While !Eof()
			
			If cQuebraAgr # TMP->VSM_SEQUEN+TMP->VSM_TIPAGR
				cMostraAgr += StrZero(TMP->(Recno()),8)+"/"
			EndIf
			cQuebraAgr := TMP->VSM_SEQUEN+TMP->VSM_TIPAGR
			
			If cQuebraSeq # TMP->VSM_SEQUEN
				cMostraSeq += StrZero(TMP->(Recno()),8)+"/"
			EndIf
			cQuebraSeq := TMP->VSM_SEQUEN
			
			DbSkip()
			
		EndDo
		
		DbSelectArea(cArqNov)
		DbGoTop()
		For nObrig:=1 to FCount()
			&("M->"+FieldName(nObrig)) := &(cArqNov+"->"+FieldName(nObrig))
		Next
		
		&(cGetDados):oBrowse:SetFocus()
		&(cGetDados):oBrowse:Refresh()
		
	EndIf
	
EndIf

Return*/

// Tela para escolha do Tipo de Tempo quando Orcamento tipo Oficina // Andre Luis Almeida - 06/08/08 //
Function OM110TPTPO(cAux)
Local lOk    := .t.
Local cTpTpo := space(4) // Tipo de Tempo
Local cValTpTem := ""
Default cAux := ""
If Empty(cAux)
	If M->VS1_TIPORC == "2" .and. Empty(M->VS1_GETKEY)
		lOk  := .f.
		cAux := cTpTpo := M->VS1_TIPTEM
		DEFINE MSDIALOG oDlgTpTpo TITLE OemtoAnsi(STR0519) FROM  02,04 TO 10,28 OF oMainWnd		//Orcamento Oficina
		@ 020,012 Say OemToAnsi(STR0520+":") SIZE 40,08 OF oDlgTpTpo PIXEL COLOR CLR_BLUE		//Tipo de Tempo
		@ 018,053 MSGET oTpTpo VAR cTpTpo F3 "VOI" PICTURE "@!" VALID (!Empty(cTpTpo).and.OM110TPTPO(cTpTpo)) SIZE 25,10 OF oDlgTpTpo PIXEL
		@ 045,026 BUTTON oOk  PROMPT OemToAnsi(STR0028) OF oDlgTpTpo SIZE 44,11 PIXEL ACTION (lOk:=.t.,oDlgTpTpo:End())//ok
		ACTIVATE MSDIALOG oDlgTpTpo CENTER
		If !lOk
			M->VS1_TIPORC := "1"
			lSalvou  := .t.
			lDestroy := .f.
			//			lJaPerg  := .f.
			oFolder:nOption := 1
		EndIf
	EndIf
Else
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek("VS1_TIPTEM")
		cValTpTem := ""
		If !Empty(SX3->X3_VALID)
			cValTpTem += SX3->X3_VALID
		EndIf
		If !Empty(SX3->X3_VLDUSER)
			If !Empty(cValTpTem)
				cValTpTem += " .and. "
			EndIf
			cValTpTem += SX3->X3_VLDUSER
		EndIf
	EndIf
	dbSetOrder(1)
	DbSelectArea("VOI")
	DbSetOrder(1)
	If DbSeek(xFilial("VOI")+cAux)
		M->VS1_TIPTEM := cAux
		If !Empty(cValTpTem)
			If !(&cValTpTem)
				lOk := .f.
			EndIf
		EndIf
	Else
		lOk := .f.
	EndIf
	DbSelectArea("VS1")
EndIf
Return(lOk)


Static Function FS_VLABERT(cNumOrd,cTipTem)

Local aArea := {}

aArea := sGetArea(aArea , Alias())
aArea := sGetArea(aArea , "VO2")
aArea := sGetArea(aArea , "VO3")
aArea := sGetArea(aArea , "VO4")

&& Verifica se o tipo de tempo foi disponibilizado
DbSelectArea("VO2")
DbSetOrder(1)
DbSeek(xFilial("VO2")+cNumOrd )
Do While !Eof() .And. xFilial("VO2")==VO2->VO2_FILIAL .And. VO2->VO2_NUMOSV == cNumOrd
	
	If VO2->VO2_TIPREQ == "P"
		
		DbSelectArea("VO3")
		DbSetOrder(1)
		DbSeek(xFilial("VO3")+VO2->VO2_NOSNUM+cTipTem)
		If ( !Empty(VO3->VO3_DATDIS) .Or. !Empty(VO3->VO3_DATFEC) .Or. !Empty(VO3->VO3_DATCAN) )
			
			If !Empty(VO3->VO3_DATCAN)
				MsgStop(STR0521 +Chr(13)+ STR0520 +": "+cTipTem)//OS Cancelada! # Tipo de Tempo
			EndIf
			
			If !Empty(VO3->VO3_DATDIS)
				MsgStop(STR0523 +Chr(13)+ STR0520 +": "+cTipTem)//OS Disponibilizada! # Tipo de Tempo
			EndIf
			
			If !Empty(VO3->VO3_DATFEC)
				MsgStop(STR0522 +Chr(13)+ STR0520 +": "+cTipTem)//OS Fechada! # "Tipo de Tempo"
			EndIf
			
			sRestArea(aArea)
			
			Return(.f.)
			
		EndIf
		
	Else
		
		DbSelectArea("VO4")
		DbSetOrder(1)
		DbSeek(xFilial("VO4")+VO2->VO2_NOSNUM+cTipTem)
		If ( !Empty(VO4->VO4_DATDIS) .Or. !Empty(VO4->VO4_DATFEC) .Or. !Empty(VO4->VO4_DATCAN) )
			
			If !Empty(VO3->VO3_DATCAN)
				MsgStop(STR0521 +Chr(13)+ STR0520 +": "+cTipTem)//OS Cancelada! # Tipo de Tempo
			EndIf
			
			If !Empty(VO3->VO3_DATDIS)
				MsgStop(STR0523 +Chr(13)+ STR0520 +": "+cTipTem)//OS Disponibilizada! # Tipo de Tempo
			EndIf
			
			If !Empty(VO3->VO3_DATFEC)
				MsgStop(STR0522 +Chr(13)+ STR0520 +": "+cTipTem)//OS Fechada! # 	Tipo de Tempo
			EndIf
			
			sRestArea(aArea)
			
			Return(.f.)
			
		EndIf
		
	EndIf
	
	DbSelectArea("VO2")
	DbSkip()
	
EndDo

sRestArea(aArea)

Return(.t.)
Static Function FS_CHEITE()

if lItRel
	PESQ110(5)
Else
	aIteRe2 := {}
	aadd(aIteRe2,{"","","",0,0})
	oLbItem:nAt := 1
	oLbItem:SetArray(aIteRe2)
	oLbItem:bLine := { || { aIteRe2[oLbItem:nAt,1] ,;
	aIteRe2[oLbItem:nAt,2] ,;
	aIteRe2[oLbItem:nAt,3] ,;
	Str(aIteRe2[oLbItem:nAt,4]),;
	Transform(aIteRe2[oLbItem:nAt,5],"@E 9,999,999.99")}}
	oLbItem:Refresh()
Endif

Return(.t.)
Function FS_TESTE110()

if ReadVar() == "M->VS3_GRUITE"
	
	MaFisRef("IT_QUANT","VS300",aCols[n,FG_POSVAR("VS3_QTDITE","aHeaderP")])
	
Endif

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VERAHADERºAutor  ³Rafael/Andre      º Data ³  17/09/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se existe item no aherader com todos campos       º±±
±±º          ³ preenchidos - grupo, item e quantidade.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function FS_VERAHADER() 
Local i:= 1
Local lRet := .t.
if M->VS1_TIPORC == "2"
	For i:=1 to Len(aColsP)
		if n == i .and. aHeaderP[1,2] == aHeader[1,2]
			if aColsP[i,Len(aColsP[i])] .or. ( len(aColsP)==1 .and. Empty(M->VS3_GRUITE) .and. Empty(M->VS3_CODITE) )
				Loop
			EndIf
			if Empty(M->VS3_GRUITE) .and. !Empty(M->VS3_CODITE) .and. lRet
				MsgInfo(STR0363 +" < "+strzero(i,3)+" >",STR0148)//Grupo do Item nao foi informado... item # Atencao!
				Return(.f.)
				
			Endif
			If Empty(M->VS3_CODITE) .and. lRet
				MsgInfo(STR0532 +" < "+strzero(i,3)+" >",STR0148)//codigo do Item nao foi informado... item # Atencao!
				Return(.f.)
				
			Endif
			if M->VS3_QTDITE == 0 .and. lRet
				MsgInfo(STR0364 +" < "+strzero(i,3)+" >",STR0148) //Quantidade do item nao foi informada... item # Atencao!
				Return(.f.)
				
			Endif
		else
	   		if aColsP[i,Len(aColsP[i])] .or. ( len(aColsP)==1 .and. Empty(aColsP[i,FG_POSVAR("VS3_GRUITE","aHeaderP")]) .and. Empty(aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")]) )
				Loop
		    EndIf
			if Empty(aColsP[i,FG_POSVAR("VS3_GRUITE","aHeaderP")]) .and. !Empty(aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")])
				MsgInfo(STR0363 +" < "+strzero(i,3)+" >",STR0148)//Grupo do Item nao foi informado... item # Atencao!
				Return(.f.)
			
			Endif
			If Empty(aColsP[i,FG_POSVAR("VS3_CODITE","aHeaderP")])
				MsgInfo(STR0532 +" < "+strzero(i,3)+" >",STR0148)//codigo do Item nao foi informado... item # Atencao!
				Return(.f.)
				
			Endif
			if aColsP[i,FG_POSVAR("VS3_QTDITE","aHeaderP")] == 0 
				MsgInfo(STR0364 +" < "+strzero(i,3)+" >",STR0148) //Quantidade do item nao foi informada... item # Atencao!
				Return(.f.) 

			Endif
		Endif 
	Next
Endif

Return .t.
