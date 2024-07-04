#include "PROTHEUS.CH"
#include "TOPCONN.CH"

Static objCENFUNLGP := CENFUNLGP():New()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR673 ³ Autor ³ Angelo Sperandio       ³ Data ³ 03.02.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Extrato de Movimentacao da RDA                             ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR673()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial                               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
function PLSR673(aPar, lAutoma, aVarAutoma)
Local lCentury      := __setcentury()
LOCAL aSx1Stru      := SX1->( DbStruct() )
LOCAL nTamPerg      := aSx1Stru[1,3]
local aAlias 		:= {}

PRIVATE cRelDir     := GetMv("MV_RELT")
PRIVATE nQtdLin
PRIVATE cNomeProg   := "PLSR673"
PRIVATE nCaracter   := 15
PRIVATE cTamanho    := GetNewPar("MV_PLTA673","M")
PRIVATE lPaisagem	:= (cTamanho == "G")
PRIVATE nLimite     := iif(lPaisagem,220,132)
PRIVATE cTitulo     := FunDesc() //"Conferência Interna de Pagamento"
PRIVATE cTitDem     := "CONFERENCIA INTERNA DE PAGAMENTO    -           Mes.......: "
PRIVATE cDesc1      := "Emite o extrato de servicos prestados pela RDA"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BD7"
PRIVATE cPerg       := "PLR673" + space(nTamPerg - 6)
PRIVATE nRel        := "PLSR673"
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {"Procedimento","Matricula Usuario","Impresso","Nome Usuario","Data Procedimento","Numero Guia"}
PRIVATE aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := ""
PRIVATE cCabec2     := ""
PRIVATE nColuna     := 00
PRIVATE nLi         := 68
PRIVATE nLinPag     := 68
PRIVATE pMoeda1     := "@E 999,999.99"
PRIVATE pMoeda2     := "@E 999,999,999.99"
PRIVATE nTamDes     := 35
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros do relatorio (SX1)...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCodOpe
PRIVATE cRdaDe
PRIVATE cRdaAte
PRIVATE cAno
PRIVATE cMes
PRIVATE cPegDe
PRIVATE cPegAte
PRIVATE nTipQbc
PRIVATE nTipRel
PRIVATE nFase
PRIVATE nNumImp
PRIVATE nImpBlq
PRIVATE cClaPre
PRIVATE cNumFat

PRIVATE lImpZero
PRIVATE aRet := {.T.,""}

PRIVATE lLisRes
PRIVATE lLisTit
PRIVATE nImpEnd
PRIVATE lGuiCob
PRIVATE lLisFor
Private	cLocDe    := ""
Private	cLocAte   := ""
PRIVATE dDatDe	  := stod("")
PRIVATE dDatAte	  := stod("")
PRIVATE cEspDe    := ""
PRIVATE cEspAte   := ""
PRIVATE cEmpDe	  := ""
PRIVATE cEmpAte   := ""
PRIVATE cConDe    := ""
PRIVATE cConAte   := ""
PRIVATE cSubDe    := ""
PRIVATE cSubAte   := ""
PRIVATE cPlaDe    := ""
PRIVATE cPlaAte   := ""
PRIVATE cProDe    := ""
PRIVATE cProAte   := ""
PRIVATE cLdpDe    := ""
PRIVATE cLdpAte   := ""
PRIVATE nImpMat   := 1
PRIVATE lImpLocRq := .F.
PRIVATE lImpCoPar := .F.
PRIVATE mv_par41  := ""
PRIVATE mv_par42  := ""
PRIVATE mv_par43  := ""
PRIVATE mv_par44  := ""
PRIVATE mv_par45  := ""
PRIVATE mv_par46	:= ""
PRIVATE aLog		:= {}
PRIVATE b673Err	:= .T.
PRIVATE lJunGlo	:= .F.
PRIVATE cChaveGlo	:= ""
PRIVATE cSlvPerg	:= cPerg
DEFAULT aPar		:= {} //Array com os parâmetros padrões
default lAutoma		:= .f.
default aVarAutoma	:= {}

Set Century Off

If BD6->(FieldPos("BD6_PAGRDA")) == 0
	MsgStop("SIGAPLS - Campo BD6_PAGRDA nao criado, por favor entrar em contato com o Suporte.")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Acessa parametros do relatorio...                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parâmetros padrões                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if len(aPar) > 0
	MV_PAR01  := aPar[01][01]    //	Operadora
	MV_PAR02  := aPar[01][02]    //	RDA De?
	MV_PAR03  := aPar[01][03]    //	RDA Até?
	MV_PAR04  := aPar[01][04]    //	Ano base?
	MV_PAR05  := aPar[01][05]    //	Mês Base?
	MV_PAR06  := aPar[01][06]    //	Peg De ?
	MV_PAR07  := aPar[01][07]    //	Peg Até?
	MV_PAR08  := aPar[01][08]    //	Tipo de Relatório?
	MV_PAR09  := aPar[01][09]    //	Fase?
	MV_PAR10  := aPar[01][10]    //	Imprimir?
	MV_PAR11  := aPar[01][11]    //	Imprimir Bloqueada?
	MV_PAR12  := aPar[01][12]    //	Classes RDA?
	MV_PAR13  := aPar[01][13]    //	Numero Lote Pagamento?
	MV_PAR14  := aPar[01][14]    //	Imprimir Valor Zero?
	MV_PAR15  := aPar[01][15]    //	Listar 1. Resumo ?
	MV_PAR16  := aPar[01][16]    //	Listar Títulos?
	MV_PAR17  := aPar[01][17]    //	Imprimir Endereço?
	MV_PAR18  := aPar[01][18]    //	Somente Guias Cobradas?
	MV_PAR19  := aPar[01][19]    //	Listar Fornecedor?
	MV_PAR20  := aPar[01][20]    //	Local Atendimento De ?
	MV_PAR21  := aPar[01][21]    //	Local Atendimento Ate?
	MV_PAR22  := aPar[01][22]    //	Data do Procedimento De ?
	MV_PAR23  := aPar[01][23]    //	Data do Procedimento Ate?
	MV_PAR24  := aPar[01][24]    //	Especialidade De?
	MV_PAR25  := aPar[01][25]    //	Especialidade Até?
	MV_PAR26  := aPar[01][26]    //	Local Digitação De?
	MV_PAR27  := aPar[01][27]    //	Local Digitação Ate?
	MV_PAR28  := aPar[01][28]    //	Empresa De?
	MV_PAR29  := aPar[01][29]    //	Empresa Até?
	MV_PAR30  := aPar[01][30]    //	Contrato De?
	MV_PAR31  := aPar[01][31]    //	Contrato Ate?
	MV_PAR32  := aPar[01][32]    //	Subcontrato De?
	MV_PAR33  := aPar[01][33]    //	Subcontrato Ate?
	MV_PAR34  := aPar[01][34]    //	Plano De?
	MV_PAR35  := aPar[01][35]    //	Plano Até?
	MV_PAR36  := aPar[01][36]    //	Procedimento De?
	MV_PAR37  := aPar[01][37]    //	Procedimento Até?
	MV_PAR38  := aPar[01][38]    //	Imp. Matricula?
	MV_PAR39  := aPar[01][39]    //	Imprimir Loc Requisição?
	MV_PAR40  := aPar[01][40]    //	Imprimir Co-Participação?
	MV_PAR41  := aPar[01][41]    //	Numero da Guia De?
	MV_PAR42  := aPar[01][42]    //	Numero de Guia Até?
	MV_PAR43  := aPar[01][43]    //	Data Digitação De ?
	MV_PAR44  := aPar[01][44]    //	Data Digitação Até?
	MV_PAR45  := aPar[01][45]    //	Numero da NFSS de ?
	MV_PAR46  := aPar[01][46]    //	Numero da NFSS ate ?
	MV_PAR47  := aPar[01][47]    //	Glosa Junto do Proc
	lFiltro	  := .F.
	cPerg	  := Iif(funname() $ 'PLSA498;PLSA600','PLR673IMP','') //aqui eu forco a nao mostrar os parametros
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama SetPrint                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nRel := SetPrint(cAlias,nRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)

If funname() $ 'PLSA498;PLSA600'
	cSlvPerg := cPerg
	Pergunte(cPerg,.F.)
EndIf
	
cPerg	  := cSlvPerg

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi cancelada a operacao                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nLastKey  == 27
	If  lCentury
		set century on
	Endif
	Return
Endif
If !(funname() $ 'PLSA498;PLSA600')
	cCodOpe   := mv_par01
	cRdaDe    := mv_par02
	cRdaAte   := mv_par03
	cAno      := mv_par04
	cMes      := mv_par05
	cPegDe    := mv_par06
	cPegAte   := mv_par07
	nTipRel   := mv_par08
	nFase     := mv_par09
	nNumImp   := mv_par10
	nImpBlq   := mv_par11
	cClaPre   := mv_par12
	cNumFat   := mv_par13
	lImpZero  := If(mv_par14==1,.T.,.F.)
	lLisRes   := If(mv_par15==1,.T.,.F.)
	lLisTit   := If(mv_par16==1,.T.,.F.)
	nImpEnd	  := mv_par17  //1=RDA --- 2=Local Atend.
	lGuiCob	  := If(mv_par18==1,.T.,.F.)
	lLisFor	  := If(mv_par19==1,.T.,.F.)
	If  lGuiCob .and. BD6->(FieldPos("BD6_NUMSE1")) == 0
		msgalert("Para listar apenas as guias ja cobradas, eh necessario ter o campo BD6_NUMSE1 criado e atualizado BD6")
		If  lCentury
			set century on
		Endif
		Return(aRet)
	Endif
	cLocDe	  	:= mv_par20
	cLocAte  	:= mv_par21
	dDatDe	  	:= mv_par22
	dDatAte  	:= mv_par23
	cEspDe   	:= mv_par24
	cEspAte  	:= mv_par25
	cLdpDe   	:= mv_par26
	cLdpAte  	:= mv_par27
	cEmpDe	  	:= mv_par28
	cEmpAte  	:= mv_par29
	cConDe   	:= mv_par30
	cConAte  	:= mv_par31
	cSubDe   	:= mv_par32
	cSubAte  	:= mv_par33
	cPlaDe    	:= mv_par34
	cPlaAte   	:= mv_par35
	cProDe    	:= mv_par36
	cProAte   	:= mv_par37
	nImpMat   	:= mv_par38
	lImpLocRq 	:= (mv_par39 == 1)
	lImpCoPar 	:= (mv_par40 == 1)
	cGuiDe    	:= mv_par41
	cGuiAte   	:= mv_par42
	dDatDiD	:= mv_par43
	dDatDiA	:= mv_par44
	cNFSSDe  	:= mv_par45
	cNFSSAte 	:= mv_par46
	lJunGlo	:= (mv_par47==1)
Else
	cCodOpe   := aPar[01][01]
	cRdaDe    := aPar[01][02]
	cRdaAte   := aPar[01][03]
	cAno      := aPar[01][04]
	cMes      := aPar[01][05]
	cPegDe    := aPar[01][06]
	cPegAte   := aPar[01][07]
	nTipRel   := aPar[01][08]
	nFase     := aPar[01][09]
	nNumImp   := mv_par01
	nImpBlq   := aPar[01][11]
	cClaPre   := aPar[01][12]
	cNumFat   := aPar[01][13]
	lImpZero  := If(mv_par02==1,.T.,.F.)
	lLisRes   := If(mv_par03==1,.T.,.F.)
	lLisTit   := If(mv_par04==1,.T.,.F.)
	nImpEnd	  := mv_par05  //1=RDA --- 2=Local Atend.
	lGuiCob	  := If(aPar[01][18]==1,.T.,.F.)
	lLisFor	  := If(aPar[01][19]==1,.T.,.F.)
	If  lGuiCob .and. BD6->(FieldPos("BD6_NUMSE1")) == 0
		msgalert("Para listar apenas as guias ja cobradas, é necessário ter o campo BD6_NUMSE1 criado e atualizado BD6")
		If  lCentury
			set century on
		Endif
		Return(aRet)
	Endif
	cLocDe	  	:= aPar[01][20]
	cLocAte  	:= aPar[01][21]
	dDatDe	  	:= aPar[01][22]
	dDatAte  	:= aPar[01][23]
	cEspDe   	:= aPar[01][24]
	cEspAte  	:= aPar[01][25]
	cLdpDe   	:= aPar[01][26]
	cLdpAte  	:= aPar[01][27]
	cEmpDe	  	:= aPar[01][28]
	cEmpAte  	:= aPar[01][29]
	cConDe   	:= aPar[01][30]
	cConAte  	:= aPar[01][31]
	cSubDe   	:= aPar[01][32]
	cSubAte  	:= aPar[01][33]
	cPlaDe    	:= aPar[01][34]
	cPlaAte   	:= aPar[01][35]
	cProDe    	:= aPar[01][36]
	cProAte   	:= aPar[01][37]
	nImpMat   	:= aPar[01][38]
	lImpLocRq 	:= (aPar[01][39] == 1)
	lImpCoPar 	:= (aPar[01][40] == 1)
	cGuiDe    	:= aPar[01][41]
	cGuiAte   	:= aPar[01][42]
	dDatDiD	:= aPar[01][43]
	dDatDiA	:= aPar[01][44]
	cNFSSDe  	:= aPar[01][45]
	cNFSSAte 	:= aPar[01][46]
	lJunGlo	:= (aPar[01][47]==1)
EndIf
If  nTipRel == 1
	lAnalitico := .T.
Else
	lAnalitico := .F.
Endif
cTitDem   += RetMesAno(cAno+cMes)

if lAutoma .and. len(aVarAutoma) > 0
	aReturn := aVarAutoma //imprimir na pasta spool
endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura impressora                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetDefault(aReturn,cAlias)

nTipQbc := aReturn[8]

If nTipQbc == 1 .or. nTipQbc == 5 .or. nTipQbc == 6
  cCabec1 := "Procedimento    Descricao                                                                        " + IIf(lImpLocRq, "Local Requisicao  ","") + IIf(lImpCoPar, "Co-Particip","")
  cCabec2 := "Matricula              Usuario                                       Movimento        Qtd TP   Qt Ref Un   Dt.Mov. INS    Valor     "+Iif(lPaisagem,"Desc.Loc.Atend.","")
ElseIf nTipQbc == 2 .or.  nTipQbc == 4 // Usuario
  cCabec1 := "Matricula              Usuario                                    " + IIf(lImpLocRq, "Local Requisicao  ","") + IIf(lImpCoPar,"Co-Particip","")
  cCabec2 := "Procedimento          Descricao                                       Movimento       Qtd  TP   Qt Ref Un  Dt.Mov. INS    Valor     "+Iif(lPaisagem,"Desc.Loc.Atend.","")
Else
  cCabec1 := "Impresso               Matricula              Usuario                                    " + IIf(lImpLocRq, "Local Requisicao  ","") + IIf(lImpCoPar,"Co-Particip","")
  cCabec2 := "Procedimento          Descricao                                       Movimento       Qtd TP   Qt Ref Un   Dt.Mov. INS    Valor"+Iif(lPaisagem,"Desc.Loc.Atend.","")
Endif

aAlias := {"BA1", "BD7", "BD6", "BAU", "BDX", "SE2", "BN4", "BID", "BB8", "BAQ", "BGQ", "BBB", "BCE", "BR8", "BA0", "B18", "SA2", "BAG", "BBC"}
objCENFUNLGP:setAlias(aAlias)
objCENFUNLGP:useLogUser()

MsAguarde({|| R673Imp(lAutoma) }, cTitulo, "", .T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera filtro do BD7                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ms_flush()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  lCentury
	set century on
Endif

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ PL673Err   ³ Autor ³Timoteo Bega         ³ Data ³ 08/06/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tratamento de Erro para filtro do usuario				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PL673Err()								 				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PLSR673()										          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PL673Err(e)
If e:gencode > 0
	If b673Err
		msgStop("Expressão criada pelo filtro é inváida"+chr(10)+chr(10)+e:Description)
		b673Err := .F.
	Endif
EndIf

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R673Imp  ³ Autor ³ Angelo Sperandio      ³ Data ³ 03.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime o extrato mensal dos servicos prestados            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function R673Imp(lAutoma)
Local nInd,nFor
LOCAL   nOrd        := aReturn[8]
LOCAL   cFor
LOCAL   cOrdem
LOCAL   cInd        := CriaTrab(Nil,.F.)
LOCAL   cSQL
Local   cOri        := ""
LOCAL   aSomaGlo    := {}
LOCAL   aRetAux		:= {}
LOCAL   nVlrItem    := 0
LOCAL   nVlrGloIt   := 0
LOCAL   nVlrTotGui  := 0
LOCAL   nVlrTotNot  := 0
LOCAL   nITens      := 0
Local 	nVlrRef     := 0
Local   nVlrGRef    := 0
Local 	nVlrPRef    := 0
Local 	nVlrTotPro  := 0
Local   aProcImp    := {}
Local   lListaCab   := .F.
Local   lTemMov
Local   lTem
LOCAL   cNameBD7    := RetSQLName("BD7")
LOCAL   cNameBA3    := RetSQLName("BA3")
LOCAL   nPosLot
LOCAL   nTotVlr
LOCAL   nTotIrf
LOCAL   nTotIns
Local   nTotAcr
Local   nTotDec
LOCAL   nLiq
LOCAL   nPos
LOCAL   cImpAnt
LOCAL   cGuiAnt
LOCAL   lLocEnd		:= .F.
Local   cGlosa		:= ""
Local   cBloq       := ""
Local   cBloq1      := ""
Local   cTipGlo     := ""
Local   cDesBlo	    := ""
Local 	cDesLoc	   	:= ""
Local   nTotGlo    	:= 0
Local	nTotGlos		:= 0
Local   cImpMat    	:= ""
LOCAL 	cBdxCodP  	:= "0"
Local   cLotBD7 	:= ""
Local   cLotBMR 	:= ""
Local   lInssUnic
Local   i,j
Local   cClaIns
Local   cDepIr
LOCAL 	cAcao
LOCAL 	cJusti
Local   cLocReq
Local   cCoPart
LOCAL   nI
Local   lContrRet	:= SuperGetMv("MV_BX10925",.T.,"2") == "1"  .And.;
						 (!Empty( SE5->( FieldPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_VRETCOF" ) ) ) .And. ;
				 		  !Empty( SE5->( FieldPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETPIS" ) ) ) .And. ;
						  !Empty( SE5->( FieldPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( FieldPos( "E5_PRETCSL" ) ) ) .And. ;
						  !Empty( SE2->( FieldPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( FieldPos( "FQ_SEQDES"  ) ) ) )
Local   nOutImp		:= 	0
Local 	nOutBaixa   :=  0
Local   nTotOutImp  :=	0
Local 	lCposVld	:=	(BBC->(FieldPos("BBC_VLDINI")) > 0 .And. BBC->(FieldPos("BBC_VLDFIM")) > 0)
Local aStruBD7 := BD7->(DbStruct())
Local nCntFor  := 0
Local nTemBGQ  := 0
Local nPis	   := 0
Local nCofins  := 0
Local nCSLL    := 0
Local lExisteLote :=.F.
Local cLinGlo	:= ""
Local cLinDes	:= ""
Local cLinAux	:= ""

Local nLenGlo 	:= 0
Local nLenDes 	:= 0
Local nLinha 	:= 0
Local nLinGlo 	:= 0
Local nLinDes 	:= 0
Local nPosGlo 	:= 0
Local nPosDes 	:= 0

Local cCabDente	:= ""
Local cCabAux	:= ""
Local lP673MATR := ExistBlock("P673MATR")

//variaveis utilizadas para lgpd
local cNomUsu  := ""
local cDenReg  := ""
local cFadEnt  := ""
local cDatNas  := ""
local cMatAnt  := ""
local cCodPad  := ""
local cCodPro  := ""
local cPro 	   := ""
local cProDesc := ""
local cBD6Desc := ""
local cMatric  := ""
local cNumImp  := ""
local cSeq 	   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Matriz Principal														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aTrbBD7 := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Controle de Glosas...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aGlosas     := {}
PRIVATE lGlosou     := .F.
PRIVATE cIni 		:= ""
PRIVATE cLinha 		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Totalizadores...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nQtd        := 0
PRIVATE nVlrGlo     := 0
PRIVATE nVlrPag     := 0
PRIVATE nDebFix     := 0
PRIVATE nCreFix     := 0
PRIVATE nDebVar     := 0
PRIVATE nCreVar     := 0
PRIVATE nDebApo     := 0
PRIVATE nCreApo     := 0

PRIVATE ntDebFix    := 0
PRIVATE ntCreFix    := 0
PRIVATE ntDebVar    := 0
PRIVATE ntCreVar    := 0
PRIVATE ntDebApo    := 0
PRIVATE ntCreApo    := 0

PRIVATE nCreTot     := 0
PRIVATE nDebTot     := 0
PRIVATE nVlrTot     := 0
PRIVATE nVlrIRF     := 0
PRIVATE nTotal      := 0
PRIVATE cRdaAnt
PRIVATE lFirst      := .T.
Private aResProd    := {0,0,0,0,0,0,0}
Private aResProdT   := {0,0,0,0,0,0,0}
Private aTabRes     := {}
Private aTabResT    := {}
Private lTemLot     := .F.
Private lLotImp     := .F.    // indica que existe lote somente de impostos
Private cLotImp     := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ variaveis de trabalho...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cNomCre     //Nome do Credenciado completo...
PRIVATE cMovime     //Codigo do movimento
PRIVATE cEspecia
PRIVATE cOpeLot
PRIVATE cNumLot	:= ""
PRIVATE cDesLot	:= ""
PRIVATE aLotes	:= {}
PRIVATE cLotes	:= ""
PRIVATE cVlrGloIt	:= ""
default lAutoma := .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mensagem                                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lAutoma
	MsProcTxt("Processando Dados...")
	ProcessMessages()
endif	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montado Matriz															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BA1->(dbSetOrder(2))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta novo nome do titulo do relatorio mostrando mes/ano                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo := AllTrim(cTitulo) + " - " + PLRETMES(Val(cMes)) + "/" + cAno
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seleciona indices                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BD5->(DbSetOrder(1))
BE4->(DbSetOrder(1))
BD6->(DbSetOrder(1))
BR8->(DbSetOrder(1))
BDX->(DbSetOrder(1))
BAF->(dbSetOrder(1))
BB8->(dbSetOrder(1))
SA2->(dbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra BAU-Rede de Atendimento                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := " SELECT R_E_C_N_O_ BAU_RECNO FROM " + RetSQLName("BAU")
cSQL += " WHERE BAU_FILIAL  = '" + xFilial("BAU") + "' AND "
cSQL += "       BAU_CODIGO >= '" + cRdaDe    + "' AND BAU_CODIGO <= '" + cRdaAte    + "' AND "
cSQL += "D_E_L_E_T_ = ''"
cSQL := ChangeQuery(cSQL)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBAU",.F.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime cada RDA                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While ! TrbBAU->(Eof())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mensagem de processamento                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !lAutoma
		MsProcTxt("Verificando... " + Left(AllTrim(BAU->BAU_NOME),30))
		ProcessMessages()
	endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona BAU-Rede de Atendimento                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BAU->(dbGoTo(TrbBAU->BAU_RECNO))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona SA2-Fornecedores                                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  lLisFor
		SA2->(msSeek(xFilial("SA2")+BAU->(BAU_CODSA2+BAU_LOJSA2)))
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a RDA pertence ao grupo informado                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  ! empty(cClaPre) .and. ! BAU->BAU_TIPPRE $ cClaPre
		TrbBAU->(DbSkip())
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a RDA existe para a operadora desejada                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	BAW->(DbSetOrder(1))
	If  ! BAW->(msSeek(xFilial("BAW")+BAU->BAU_CODIGO+cCodOpe))
		TrbBAU->(DbSkip())
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe movimento de producao medica para a rda               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lTemMov := .F.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se tem apontamento de producao                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSql := "SELECT BD7.* "
	cSql += "  FROM " + RetSQLName("BD7")+ " BD7 " //+ ", " + RetSQLName("BD6")
	cSql += "  WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND "
	cSql += " BD7_CODOPE = '"+cCodOpe+"' AND "
	cSql += " BD7_CODLDP >= '" +cLdpDe + "' AND BD7_CODLDP <= '" + cLdpAte + "' AND "
	cSql += " BD7_CODPEG >= '" + cPegDe+ "' AND BD7_CODPEG <= '" + cPegAte + "' AND "
	cSql += " BD7_NUMERO >= '" + cGuiDe+ "' AND BD7_NUMERO <= '" + cGuiAte + "' AND "
	If     nFase == 1 // pronta
		cSql += "BD7_SITUAC <> '2' AND BD7_FASE = '3' AND "
	ElseIf nFase == 2 // faturada
		cSql += "BD7_SITUAC <> '2' AND BD7_FASE = '4' AND "
	ElseIf nFase == 3 // conferencia
 		cSql += "BD7_SITUAC <> '2' AND BD7_FASE = '2' AND "
 	ElseIf nFase == 4 // conferencia
 		cSql += "BD7_SITUAC <> '2' AND"
	EndIf
   //Ao Chamar da PEG estava trazendo apenas uma Rda
	If !(funname() $ 'PLSA498;PLSA600')
	cSql += " BD7_CODRDA = '" + BAU->BAU_CODIGO    + "'  AND "
	Endif

	If  ! Empty(cNumFat) .And. nFase == 2
		cSql += "BD7_OPELOT = '"+cCodOpe+"' AND BD7_NUMLOT = '"+cNumFat+"' AND "
	Else
		If  nFase == 2
			cSql += "BD7_OPELOT = '"+cCodOpe+"' AND BD7_NUMLOT LIKE '"+cAno+cMes+"%' AND "
		ElseIf nFase <> 4
			cSql += "(BD7_ANOPAG < '" + cAno + "' OR ( BD7_ANOPAG = '" + cAno + "' AND BD7_MESPAG  <= '" + cMes + "' )) AND "
		Else
			cSql += "((BD7_OPELOT = '"+cCodOpe+"' AND BD7_NUMLOT LIKE '"+cAno+cMes+"%') OR((BD7_ANOPAG < '" + cAno + "' OR ( BD7_ANOPAG = '" + cAno + "' AND BD7_MESPAG  <= '" + cMes + "' ))) ) AND "
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Funcao generica que trata campos do estorno		   					     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("PlReChvEst")
	   	aRetAux  := PlReChvEst("BD7",.F.,.T.,.F.,.T.)
	   	cSQL     += aRetAux[1]
	Endif

	Do Case
		Case nImpBlq == 1 // imprimir guias bloqueadas pelo sistema
			cSql += "( BD7_BLOPAG <> '1' Or (BD7_BLOPAG = '1' AND BD7_BLQAUG =  ' ') Or BD7_SITUAC = '3' ) AND "
		Case nImpBlq == 2 // imprimir guias bloqueadas por auto-gerado
			cSql += "( BD7_BLOPAG <> '1' Or (BD7_BLOPAG = '1' AND BD7_BLQAUG <> ' ') ) AND BD7_SITUAC <> '3' AND "
		Case nImpBlq == 3 // imprimir todas guias bloqueadas
			cSql += ""
		Otherwise         // nao imprimir guias bloqueadas
			cSql += "BD7_BLOPAG <> '1' AND BD7_SITUAC <> '3' AND "
	EndCase

	If ! lImpZero
		cSql += " BD7_VLRPAG > 0 AND"
	Endif

	If ! Empty(dDatAte)
		cSql += " BD7_DATPRO >= '" + DTOS(dDatDe) + "' AND BD7_DATPRO <= '" + DTOS(dDatAte) + "' AND "
	Endif

	If ! Empty(cEspAte)
		cSql += " BD7_CODESP >= '" + cEspDe + "' AND BD7_CODESP <= '" + cEspAte + "' AND "
	Endif

	If ! Empty(cEmpAte)
		cSql += " BD7_CODEMP >= '" + cEmpDe + "' AND BD7_CODEMP <= '" + cEmpAte + "' AND"
	Endif

	If ! Empty(cPlaAte)
		cSql += " BD7_CODPLA >= '" + cPlaDe + "' AND BD7_CODPLA <= '" + cPlaAte + "' AND "
	Endif

	If ! Empty(cProAte)
		cSql += " BD7_CODPRO >= '" + 	cProDe + "' AND BD7_CODPRO <= '" + cProAte + "' AND "
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Somente pega as guias de um mesma NFSS							  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BD7->(FieldPos("BD7_SEQNFS")) > 0
	  If !Empty(cNFSSAte)
	  	cSQL += " ( BD7_SEQNFS >= '"+cNFSSDe+"' AND BD7_SEQNFS <= '"+cNFSSAte+"' ) AND "
	  EndIf
	Endif

	If  ! Empty(aReturn[7])
		cSql += PLSParSQL(aReturn[7]) + " AND "
	Endif

	cSql += " BD7.D_E_L_E_T_ = ' '"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta ordem                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If     nTipQbc == 1
		cSql+= " ORDER BY BD7_FILIAL,BD7_CODRDA,BD7_NUMLOT,BD7_CODPAD,BD7_CODPRO,BD7_DATPRO,BD7_CODOPE,BD7_CODEMP,BD7_MATRIC,BD7_TIPREG "
	ElseIf nTipQbc == 2
		cSql+= " ORDER BY BD7_FILIAL,BD7_CODRDA,BD7_NUMLOT,BD7_CODOPE,BD7_CODEMP,BD7_MATRIC,BD7_TIPREG,BD7_DATPRO,BD7_CODPAD,BD7_CODPRO "
	ElseIf nTipQbc == 3
		cSql+= " ORDER BY BD7_FILIAL,BD7_CODRDA,BD7_NUMLOT,BD7_NUMIMP,BD7_CODOPE,BD7_CODEMP,BD7_MATRIC,BD7_TIPREG,BD7_CODPAD,BD7_CODPRO "
	ElseIf nTipQbc == 4
		cSql+= " ORDER BY BD7_FILIAL,BD7_CODRDA,BD7_NUMLOT,BD7_NOMUSR,BD7_CODPAD,BD7_CODPRO"
	ElseIf nTipQbc == 5
		cSql+= " ORDER BY BD7_FILIAL,BD7_CODRDA,BD7_NUMLOT,BD7_DATPRO,BD7_CODPAD,BD7_CODPRO "
	ElseIf nTipQbc == 6
		cSql+= " ORDER BY BD7_FILIAL,BD7_CODRDA,BD7_NUMLOT,BD7_CODOPE,BD7_CODLDP,BD7_CODPEG,BD7_NUMERO,BD7_CODPAD,BD7_CODPRO"
	EndIf

	cSQL := ChangeQuery(cSQL)

	TrbBD7 := GetNextAlias()

	If Empty(aReturn[7])
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),TrbBD7,.F.,.T.)
	Else
		bError := ErrorBlock({|e| PL673Err(e) })
		Begin Sequence
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),TrbBD7,.F.,.T.)
		End Sequence
	EndIf

	If !b673Err
		Return b673Err
	EndIf

	For nCntFor := 1 To Len(aStruBD7)
		If ( aStruBD7[nCntFor,2]<>"C" )
	 		TcSetField(TrbBD7,aStruBD7[nCntFor,1],aStruBD7[nCntFor,2],aStruBD7[nCntFor,3],aStruBD7[nCntFor,4])
		EndIf
	Next nCntFor
	If !(TrbBD7)->(eof())
		lTemMov := .T.
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se tem debito/credito                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  nFase <> 2 // diferente de faturado
		cSQL := " SELECT COUNT(*) QTD FROM " + RetSQLName("BBC")
		cSQL += " WHERE BBC_FILIAL =  '" + xFilial("BBC")  + "' AND "
		cSQL += "       BBC_CODIGO =  '" + BAU->BAU_CODIGO + "' AND "
		cSQL += "       BBC_STATUS =  '1' AND "
		cSQL += "       BBC_PROMED =  '1' AND "

		If lCposVld // BOPS 98697
			cSQL += " ( '" + cAno + cMes + "01' >= BBC_VLDINI ) AND "
			cSQL += " ( ( '" + DtoS(LastDay(CtoD("01/"+cMes+"/"+cAno))) + "' <= BBC_VLDFIM ) OR ( BBC_VLDFIM = '        ' ) ) AND "
		EndIf

		cSQL += "       D_E_L_E_T_ = '' "
		cSQL := ChangeQuery(cSQL)

		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBBC",.F.,.T.)

		If  TrbBBC->QTD > 0
			lTemMov := .T.
		Endif
		TrbBBC->(DbCloseArea())
	Endif


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Foi dismembrando a crição da varial cLotBMR dos demais arrays para que não ocorra o	   ³
	// erro de banco ORA-01795: o número máximo de expressões em uma lista é de 1000		   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cSQL := " SELECT DISTINCT BGQ_NUMLOT FROM " + RetSQLName("BGQ")
	cSQL += " WHERE BGQ_FILIAL =  '" + xFilial("BGQ") + "' AND "
	cSQL += "       BGQ_CODIGO =  '" + BAU->BAU_CODIGO + "' AND "
	cSQL += " ( BGQ_ANO < '" + cAno + "' OR (BGQ_ANO = '" + cAno + "' AND BGQ_MES <= '"+ cMes +"' )) "
	If nFase ==4 //Todos
			cSQL += " OR (BGQ_NUMLOT <> '" + space(10)       + "' AND "
			If  !Empty(cNumFat)
				cSQL += "   BGQ_NUMLOT ='" + Alltrim(cAno+cMes+cNumFat) +"') AND "
			Else
				If AllTrim(TCGetDB()) == "ORACLE"
					cSQL += "  SUBSTR( BGQ_NUMLOT,1,6) ='" +    cAno+cMes +"') AND "
				Else
					cSQL += "  SUBSTRING( BGQ_NUMLOT,1,6) ='" + cAno+cMes +"') AND "
				Endif
			Endif
	ElseIf  nFase == 2 // Faturado
		cSQL += " AND BGQ_NUMLOT <> '" + space(10)       + "' AND "
		If  !Empty(cNumFat)
			cSQL += "   BGQ_NUMLOT ='" + Alltrim(cAno+cMes+cNumFat) +"'  AND "
		Else
			If AllTrim(TCGetDB()) == "ORACLE"
				cSQL += "  SUBSTR( BGQ_NUMLOT,1,6) ='" + cAno+cMes +"'  AND "
			Else
				cSQL += "  SUBSTRING( BGQ_NUMLOT,1,6) ='" + cAno+cMes +"'  AND "
			Endif
		Endif
	Else
		cSQL += " AND BGQ_NUMLOT =  '" + space(10)       + "' AND "
	Endif
	cSQL += "D_E_L_E_T_ = '' "
	cSQL += " GROUP BY  BGQ_NUMLOT " // TRATAMENTO EFETUADO PARA QUE NÃO OCORRA NUMERO MAXIMO DE COMPARAÇÕES NAS QUERYS ABAIXO
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBGQ",.F.,.T.)

	TrbBGQ->( dbEval({|| IIf(!Empty(cNumFat),"",cLotBMR += IIf(Empty(cLotBMR), "", ",") + "'" + SubStr(TrbBGQ->BGQ_NUMLOT, 7, 4) + "'")}) )

	TrbBGQ->(DbCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se tem debito/credito                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := " SELECT BGQ_NUMLOT,R_E_C_N_O_ AS NRECBGQ FROM " + RetSQLName("BGQ")
	cSQL += " WHERE BGQ_FILIAL =  '" + xFilial("BGQ") + "' AND "
	cSQL += "       BGQ_CODIGO =  '" + BAU->BAU_CODIGO + "' AND "
	cSQL += " ( BGQ_ANO < '" + cAno + "' OR (BGQ_ANO = '" + cAno + "' AND BGQ_MES <= '"+ cMes +"' )) "

	If nFase ==4 //Todos

			cSQL += " OR (BGQ_NUMLOT <> '" + space(10)       + "' AND "

			If  !Empty(cNumFat)
				cSQL += "   BGQ_NUMLOT ='" + Alltrim(cAno+cMes+cNumFat) +"') AND "
			Else
				If AllTrim(TCGetDB()) == "ORACLE"
					cSQL += "  SUBSTR( BGQ_NUMLOT,1,6) ='" +    cAno+cMes +"') AND "
				Else
					cSQL += "  SUBSTRING( BGQ_NUMLOT,1,6) ='" + cAno+cMes +"') AND "
				Endif
			Endif

	ElseIf  nFase == 2 // Faturado

		cSQL += " AND BGQ_NUMLOT <> '" + space(10)       + "' AND "
		If  !Empty(cNumFat)
			cSQL += "   BGQ_NUMLOT ='" + Alltrim(cAno+cMes+cNumFat) +"'  AND "
		Else
			If AllTrim(TCGetDB()) == "ORACLE"
				cSQL += "  SUBSTR( BGQ_NUMLOT,1,6) ='" + cAno+cMes +"'  AND "
			Else
				cSQL += "  SUBSTRING( BGQ_NUMLOT,1,6) ='" + cAno+cMes +"'  AND "
			Endif
		Endif
	Else
		cSQL += " AND BGQ_NUMLOT =  '" + space(10)       + "' AND "
	Endif
	cSQL += "D_E_L_E_T_ = ''"
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBGQ",.F.,.T.)

	nTemBGQ := 0
	aRecBGQ := {}
	TrbBGQ->( dbEval({|| nTemBGQ ++,aadd(aRecBGQ,TrbBGQ->NRECBGQ)}) )

    If nTemBGQ > 0
	   lTemMov := .T.
	Endif

	TrbBGQ->(DbCloseArea())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se tem apontamento de producao                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL := " SELECT COUNT(*) QTD FROM " + RetSQLName("BCE")
	cSQL += " WHERE BCE_FILIAL =  '" + xFilial("BCE") + "' AND "
	cSQL += "       BCE_CODIGO =  '" + BAU->BAU_CODIGO + "' AND "
	cSQL += "       BCE_CODINT =  '"+  cCodOpe         +"'  AND "
	cSQL += "       BCE_ANOPAG =  '" + cAno            + "' AND "
	cSQL += "       BCE_MESPAG =  '" + cMes            + "' AND "

	If nFase == 4 // Todos
	   cSQL += "   (BCE_NUMLOT <> '" + space(10)       + "' "
	   If ! Empty(dDatAte) .And. ! Empty(cLotBD7) .And. !Empty(cNumFat)
	      cSQL += " OR  BCE_NUMLOT IN (" + cLotBD7 + ")  "
	   EndIf
	   cSQL += ") AND "
	ElseIf nFase == 2 // Faturado
	   cSQL += "   BCE_NUMLOT <> '" + space(10)       + "' AND "
	   If ! Empty(dDatAte) .And. ! Empty(cLotBD7) .And. !Empty(cNumFat)
	      cSQL += "   BCE_NUMLOT IN (" + cLotBD7 + ") AND "
	   EndIf
	Else
	   cSQL += "   BCE_NUMLOT =  '" + space(10)       + "' AND "
	Endif
	cSQL += "D_E_L_E_T_ = ''"
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBCE",.F.,.T.)

	If TrbBCE->QTD > 0
	   lTemMov := .T.
	Endif
	TrbBCE->(DbCloseArea())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a RDA teve alguma movimentacao                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  ! lTemMov
		TrbBAU->(DbSkip())
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mensagem de processamento                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !lAutoma
		MsProcTxt("" + Left(AllTrim(BAU->BAU_NOME),20))
		ProcessMessages()
	endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa variaveis relativas a RDA                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  BAU->BAU_CALIMP $ "1,3"
		cDepIr := " Dependentes IR: " + PLSDEPIR(BAU->BAU_CODIGO,cAno,cMes)
	Else
		cDepIr := ""
	Endif
	cEspecia  := objCENFUNLGP:verCamNPR("BAQ_DESCRI", PLSLISESP(BAU->BAU_CODIGO))
	aLotes    := {}
	lInssUnic := .F.
	If  nFase == 2 .OR. nFase == 4
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta query                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := " SELECT BMR_FILIAL, BMR_OPERDA, BMR_CODRDA, BMR_OPELOT, BMR_ANOLOT, BMR_MESLOT, BMR_NUMLOT "
		cSQL += "  FROM " + RetSQLName("BMR")
		cSQL += "  WHERE BMR_FILIAL = '" + xFilial("BMR") + "' "
		cSQL += "    AND BMR_OPERDA = '" + cCodOpe + "' "
		cSQL += "    AND BMR_CODRDA = '" + BAU->BAU_CODIGO + "' "
		cSQL += "    AND BMR_OPELOT = '" + cCodOpe + "' "
		cSQL += "    AND BMR_ANOLOT = '" + cAno    + "' "
		cSQL += "    AND BMR_MESLOT = '" + cMes    + "' "
		If ! Empty(dDatAte) .And. ! Empty(cLotBMR)
			cSQL += "    AND BMR_NUMLOT IN (" + cLotBMR + ") "
		EndIf
		cSQL += "    AND D_E_L_E_T_ = ' ' "
		cSQL += " GROUP BY BMR_FILIAL, BMR_OPERDA, BMR_CODRDA, BMR_OPELOT, BMR_ANOLOT, BMR_MESLOT, BMR_NUMLOT "
		cSQL += " ORDER BY BMR_FILIAL, BMR_OPERDA, BMR_CODRDA, BMR_OPELOT, BMR_ANOLOT, BMR_MESLOT, BMR_NUMLOT "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa query                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)

		BMR->(DbSetOrder(1))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa arquivo de trabalho                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cLotes := ""
		While ! Trb->(eof())
			cLotes += "'" + Trb->(BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) + "',"
			BMR->(msSeek(Trb->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOT+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT)))
			If  BMR->BMR_CODLAN < "170" // nao eh um lote apenas de impostos
				aadd(aLotes,{cCodOpe,Trb->BMR_ANOLOT+Trb->BMR_MESLOT+Trb->BMR_NUMLOT})
			Else
				aadd(aLotes,{cCodOpe,Trb->BMR_ANOLOT+Trb->BMR_MESLOT+Trb->BMR_NUMLOT})
				lLotImp := .T.
				cLotImp := Trb->BMR_ANOLOT+Trb->BMR_MESLOT+Trb->BMR_NUMLOT
			Endif
			Trb->(dbSkip())
		Enddo
		Trb->(dbCloseArea())
		cLotes := alltrim(cLotes)
		If  right(cLotes,1) == ","
			clotes := "(" + substr(cLotes,1,len(cLotes)-1) + ")"
		Endif
		If len(aLotes) = 0
			aadd(aLotes,{space(4),space(10)})
		EndIf
	Else
		aadd(aLotes,{space(4),space(10)})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa variaveis                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aResProdT := {0,0,0,0,0,0,0}
	aTabResT  := {}
	ntBIss    := 0
	ntIss     := 0
	ntBPis    := 0
	ntPis     := 0
	ntBCofins := 0
	ntCofins  := 0
	ntBIR     := 0
	ntIR      := 0
	ntBCSLL   := 0
	ntCSLL    := 0
	ntBINSSPF := 0
	ntINSSPF  := 0
	ntBINSSPJ := 0
	ntINSSPJ  := 0
	ntBINSSJF := 0
	ntINSSJF  := 0
	ntPINSSPJ := 0
	ntPINSSPF := 0
	ntCrPINSS := 0
	lFirst    := .T.
	ntDebFix  := 0
	ntCreFix  := 0
	ntDebVar  := 0
	ntCreVar  := 0
	ntDebApo  := 0
	ntCreApo  := 0
	cRdaAnt   := BAU->BAU_CODIGO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processa todos os lotes da RDA                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nPosLot := 1 to len(aLotes)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta cabecalho                                                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  lAnalitico

			cCabDente := IIF(lPaisagem," Dente/Reg   Face     ", "   ")

			/*If nTipQbc == 1 .or. nTipQbc == 5
			  cCabec1 := "Procedimento    Descricao                                                                       Dente/Reg   Face     " + IIf(lImpLocRq, "Local Requisicao  ","") + IIf(lImpCoPar, "Co-Particip","")
			  cCabec2 := "Matricula              Usuario                             Idade           Movimento     Qtd  TP  Qt Ref  Un  Dt.Mov. INS    Valor     "+Iif(cTamanho == "G","Desc.Loc.Atend.","")
			Else*/
			If nTipQbc == 1 .or.  nTipQbc == 5 // Usuario
			  //-----------------------------------------------------------------------------------------------------------------
			  // Quando em modo paisagem, o cCabAux é utilizado na 2º linha do cabeçalho (Adaptação para o segmento Odontológica)
			  // Em modo retrato o legado é mantido e o relatório continua como antes.
			  //-----------------------------------------------------------------------------------------------------------------
			  cCabAux := IIf(lImpLocRq, "Local Requisicao  ","") + IIf(lImpCoPar,"Co-Particip "," ") + cCabDente

			  cCabec1 := "Procedimento          Descricao                                                     "  + IIf(!lPaisagem,cCabAux,"")
			  cCabec2 := "Matricula              Usuario                             Idade   "  + IIf(lPaisagem,cCabAux,"")+" Movimento          Qtd  TP   Qt Ref Un  Dt.Mov. INS      Valor   "+Iif(lPaisagem,"    Desc.Loc.Atend.","")
	      ElseIf nTipQbc == 2 .or.  nTipQbc == 4// Usuario
			  cCabec1 := "Matricula              Usuario                             Idade   "  + IIf(lImpLocRq, "Local Requisicao  ","") + IIf(lImpCoPar,"Co-Particip","")
			  cCabec2 := "Procedimento          Descricao                        " + cCabDente +"Movimento              Qtd  TP   Qt Ref Un  Dt.Mov. INS      Valor   "+Iif(lPaisagem," Desc.Loc.Atend.","")
	      ElseIf nTipQbc == 6
              cCabec1 := "Matricula              Usuario                             Idade 	 " + IIf(lImpLocRq, "Local Requisicao   ","") + IIf(lImpCoPar,"Co-Particip","")
              cCabec2 := "Procedimento          Descricao                        " + cCabDente + "Movimento              Qtd  TP   Qt Ref Un  Dt.Mov. INS      Valor     "+Iif(lPaisagem,"    Desc.Loc.Atend.","")
			Else
			  cCabec1 := "Impresso               Matricula              Usuario                                    Idade    " + IIf(lImpLocRq, "Local Requisicao  ","") + IIf(lImpCoPar,"Co-Particip","")
			  cCabec2 := "Procedimento          Descricao                           " + cCabDente + "Movimento                   Qtd TP   Qt Ref Un   Dt.Mov. INS    Valor"+Iif(lPaisagem,"    Desc.Loc.Atend.","")
			Endif
		Else
			cCabec1 := "Tipo Debito/Credito           Descricao                                   Credito         Debito"
			cCabec2 := ""
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa variaveis relativas ao lote                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cOpeLot := aLotes[nPosLot,1]
		cNumLot := aLotes[nPosLot,2]
		BAF->(msSeek(xFilial("BAF") + cOpeLot + cNumLot))
		cDesLot := BAF->BAF_HISTIT
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa variaveis                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aResProd := {0,0,0,0,0,0,0}
		aTabRes  := {}
		nVlrPag  := 0
		nVlrGlo  := 0
		nDebFix  := 0
		nCreFix  := 0
		nDebVar  := 0
		nDebApo  := 0
		nCreVar  := 0
		nCreApo  := 0
		nDebTot  := 0
		nCreTot  := 0
		nTotal   := 0
		aGlosas  := {}
		lTem    := .F.
		lTemLot := .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa variaveis                                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cProAnt := "" //BD7->(BD7_CODPAD+BD7_CODPRO)
		cUsuAnt := "" //BD7->(BD7_CODOPE+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG)
		cImpAnt := "" //BD7->(BD7_NUMIMP+BD7_CODOPE+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG)
      cGuiAnt := ""
		lFirst  := .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa todas as guias deste lote                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lExisteLote :=.F.
		If lAnalitico
			If lExisteLote .or. lLisRes
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime dados da RDA                                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				R673RDA()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Producao medica                                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cLinha := Replicate('-',nLimite)
				R673Linha(cLinha,1,0)
				cLinha := "Detalhes da Producao"
				R673Linha(cLinha,1,0)
			EndIf
		EndIf
		DbSelectArea(TrbBD7)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Inicio das soma de valores e totais
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		While !(TrbBD7)->(Eof())
				If nFase <> 4 .and. (TrbBD7)->BD7_NUMLOT <> cNumLot
				   Exit
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona BD6-Item da Guia                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  (TrbBD7)->BD7_FILIAL+(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODLDP+(TrbBD7)->BD7_CODPEG+(TrbBD7)->BD7_NUMERO+(TrbBD7)->BD7_ORIMOV+(TrbBD7)->BD7_SEQUEN <>;
					BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
					BD6->( msSeek( xFilial("BD6")+(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODLDP+(TrbBD7)->BD7_CODPEG+(TrbBD7)->BD7_NUMERO+(TrbBD7)->BD7_ORIMOV+(TrbBD7)->BD7_SEQUEN ) )
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ BOPS 103585 - Verifica "Data Digitacao" para cada procedimento.    ³
				//³               Esta verificacao era feita no cabecalho (BD5/BE4),   ³
				//³               porem pode ocorrer de haver procedimentos com data   ³
				//³               de digitacao diferente da informada no cabecalho.    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !(BD6->BD6_DTDIGI  >= dDatDiD .And. BD6->BD6_DTDIGI <= dDatDiA) .And. !Empty(dDatDiA)
					(TrbBD7)->(DbSkip())
					Loop
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona BD5,BE4-Capa da Guia                                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (TrbBD7)->BD7_ORIMOV == '2' .And. (TrbBD7)->BD7_FILIAL+(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODLDP+(TrbBD7)->BD7_CODPEG+(TrbBD7)->BD7_NUMERO <> ;
					BE4->(BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)

					BE4->( MsSeek( xFilial("BE4")+(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODLDP+(TrbBD7)->BD7_CODPEG+(TrbBD7)->BD7_NUMERO ) )

					cDesLoc := objCENFUNLGP:verCamNPR("BB8_DESLOC", Posicione("BB8",1,xFilial("BB8")+BE4->(BE4_CODRDA+BE4_OPERDA+BE4_CODLOC+BE4_LOCAL),"BB8_DESLOC"))

					If !(BE4->BE4_LOCAL  >= cLocDe .And. BE4->BE4_LOCAL <= cLocAte) .And. !Empty(cLocAte)
						(TrbBD7)->(DbSkip())
						Loop
					Endif

					If !(BE4->BE4_CONEMP  >= cConDe .And. BE4->BE4_CONEMP <= cConAte) .And. !Empty(cConAte)
						(TrbBD7)->(DbSkip())
						Loop
					Endif

					If !(BE4->BE4_SUBCON  >= cSubDe .And. BE4->BE4_SUBCON <= cSubAte) .And. !Empty(cSubAte)
						(TrbBD7)->(DbSkip())
						Loop
					Endif

				Else

					BD5->( MsSeek( xFilial("BD5")+(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODLDP+(TrbBD7)->BD7_CODPEG+(TrbBD7)->BD7_NUMERO ) )
					cDesLoc := objCENFUNLGP:verCamNPR("BB8_DESLOC", Posicione("BB8",1,xFilial("BB8")+BD5->(BD5_CODRDA+BD5_OPERDA+BD5_CODLOC+BD5_LOCAL),"BB8_DESLOC"))

					If !(BD5->BD5_LOCAL >= cLocDe .And. BD5->BD5_LOCAL <= cLocAte) .and. !Empty(cLocAte)
						(TrbBD7)->(DbSkip())
						Loop
					Endif

					If !(BD5->BD5_CONEMP  >= cConDe .And. BD5->BD5_CONEMP <= cConAte) .and. !Empty(cConAte)
						(TrbBD7)->(DbSkip())
						Loop
					Endif

					If !(BD5->BD5_SUBCON  >= cSubDe .And. BD5->BD5_SUBCON <= cSubAte) .and. !Empty(cSubAte)
						(TrbBD7)->(DbSkip())
						Loop
					Endif

				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se deve listar apenas guias cobradas                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  nFase == 1 .And. lGuiCob .And. BD6->(FieldPos("BD6_NUMSE1")) > 0 .And. Empty(BD6->BD6_NUMSE1) // pagar somente guias ja cobradas
					(TrbBD7)->(DbSkip())
					Loop
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona BA1-Usuarios                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG) <> (TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODEMP+(TrbBD7)->BD7_MATRIC+(TrbBD7)->BD7_TIPREG
					If !BA1->( MsSeek( xFilial("BA1")+(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODEMP+(TrbBD7)->BD7_MATRIC+(TrbBD7)->BD7_TIPREG ) )
						(TrbBD7)->(DbSkip())
						Loop
					EndIf
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona BR8-Tabela Padrao                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  BR8->(BR8_CODPAD+BR8_CODPSA) <> (TrbBD7)->BD7_CODPAD+(TrbBD7)->BD7_CODPRO
					BR8->( MsSeek( xFilial("BR8")+(TrbBD7)->BD7_CODPAD+(TrbBD7)->BD7_CODPRO ) )
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica quebra                                                          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nImpMat == 1
					cImpMat := BD6->BD6_MATUSA
				ElseIf nImpMat == 2
					cImpMat := "1"
				Else
					cImpMat := "2"
				EndIf
				// informações que fazem parte da lgpd
				cNomUsu := objCENFUNLGP:verCamNPR("BA1_NOMUSR", padR(BA1->BA1_NOMUSR,34))
				cDenReg := objCENFUNLGP:verCamNPR("BD6_DENREG", BD6->BD6_DENREG)
				cFadEnt	:= objCENFUNLGP:verCamNPR("BD6_FADENT", pad(SubStr(BD6->BD6_FADENT,1,06),06))
				cDatNas := objCENFUNLGP:verCamNPR("BA1_DATNAS", str(Calc_Idade( dDataBase,BA1->BA1_DATNAS ),2 ))
				cMatAnt := objCENFUNLGP:verCamNPR("BD6_MATANT", BD6->BD6_MATANT)
				cCodPad := objCENFUNLGP:verCamNPR("BD7_CODPAD", (TrbBD7)->BD7_CODPAD)
				cCodPro := objCENFUNLGP:verCamNPR("BD7_CODPRO", (TrbBD7)->BD7_CODPRO)
				cPro 	:= cCodPad+cCodPro
				cProDesc := objCENFUNLGP:verCamNPR("BR8_DESCRI", BR8->BR8_DESCRI)
				cBD6Desc := objCENFUNLGP:verCamNPR("BD6_DESPRO", subStr(BD6->BD6_DESPRO,1,35))
				cMatric :=  objCENFUNLGP:verCamNPR("BA1_CODINT", BA1->BA1_CODINT)+objCENFUNLGP:verCamNPR("BA1_CODEMP", BA1->BA1_CODEMP)+;
							objCENFUNLGP:verCamNPR("BA1_MATRIC", BA1->BA1_MATRIC)+objCENFUNLGP:verCamNPR("BA1_TIPREG", BA1->BA1_TIPREG)+;
							objCENFUNLGP:verCamNPR("BA1_DIGITO", BA1->BA1_DIGITO)
				cNumImp :=  objCENFUNLGP:verCamNPR("BD6_NUMIMP", BD6->BD6_NUMIMP)
				cSeq 	:=  objCENFUNLGP:verCamNPR("BD7_SEQUEN", (TrbBD7)->BD7_SEQUEN)
				
				If  lAnalitico
					cLocReq := IIf(lImpLocRq, objCENFUNLGP:verCamNPR("BD6_LOCREQ", PadR(X3Combo("BD6_LOCREQ",BD6->BD6_LOCREQ),20)), "")
					cCoPart := IIf(lImpCoPar, IIf(BD6->BD6_VLRTPF > 0,"    Sim    ","    Nao    "), "")

					If Len(aGlosas) > 0 .And. ! lFirst
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se for para agrupar procedimento e glosa, imprime a glosa                ³
					   	//³ senão acrecenta a glosa ao aGlosas para imprimir tudo no final.          ³
					   	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					    If lJunGlo
					        PLS673GL(@aGlosas,@cJusti,cBdxCodP,@nTotGlos,cAcao,@cGlosa,cTipGlo,pMoeda1, cLinha)
						EndIf
					EndIf
					Do Case
						Case nTipQbc == 1 .Or. nTipQbc == 5 // Procedimento
							If  cProAnt <> (TrbBD7)->BD7_CODPAD+(TrbBD7)->BD7_CODPRO .And. ! lFirst
								if lImpLocRq .AND. lPaisagem
									cLinha := Space(47)
								ElseIf lPaisagem
									cLinha := Space(27)
								Else
									cLinha := ""
								EndIf
								cLinha += IIF(lPaisagem,space(100),space(103)) + "Total:        " + TransForm(nTotal,pMoeda2)
								R673Linha(cLinha,1,0)
							Endif
							If  cProAnt <> (TrbBD7)->BD7_CODPAD+(TrbBD7)->BD7_CODPRO .or. lFirst
								cLinha := 	TransForm(cPro,"@R !! !!.!!.!!!-!") + "  " + substr(cProDesc,1,80) + Space(02)

								If !lPaisagem
									cLinha += 	cLocReq + Space(02) + ;
												cCoPart + space(04)
								else
									cLinha += 	cLocReq + Space(02) + ;
												cCoPart + space(02) + ;
												cDenReg + space(08) + cFadEnt + space(02)
								EndIf

								R673Linha(cLinha,1,0)
							Endif
							If  cUsuAnt <> (TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODEMP+(TrbBD7)->BD7_MATRIC+(TrbBD7)->BD7_TIPREG .Or.	lFirst .Or.;
								cProAnt <> (TrbBD7)->BD7_CODPAD+(TrbBD7)->BD7_CODPRO .OR. lPaisagem

								If lP673MATR
									Execblock("P673MATR",.F.,.F.,{nTipQbc,cIni,cLinha})
	                      Else
									If  cImpMat == "1"
										cIni := 	padR(transform(cMatric,"@R !!!!.!!!!.!!!!!!.!!-!"),21) + space(2) + ;
													cNomUsu + space(1) +;
													cDatNas + " Anos" + space(02)
										if lPaisagem
											cIni += 	cLocReq + space(02) + ;
														cCoPart + space(02) + ;
														cDenReg + space(08) + cFadEnt + space(02)
										endIf
									else
										If  len(alltrim(BD6->BD6_MATANT)) == 17
											cIni := 	padR(Transform(cMatAnt,"@R !!!!.!!!!.!!!!!!.!!-!"),21) + space(2) +;
														cNomUsu + space(1) +;
														cDatNas + " Anos" + space(02)
											if lPaisagem
												cIni += 	cLocReq + Space(02) + ;
															cCoPart + space(02) + ;
															cDenReg + space(08) + cFadEnt + space(02)
											endIf

										else
											cIni := 	padR(Transform(cMatAnt,"@R !!!.!!!!.!!!!!!.!!-!"),21) + space(2) +;
														cNomUsu + space(1) +;
														cDatNas + " Anos" + space(02)
											if lPaisagem
												cIni +=	cLocReq + Space(02) + ;
															cCoPart + space(02) + ;
															cDenReg + space(08) + cFadEnt + space(02)
											endIf
										Endif
									Endif
							  	EndIf
							Endif
						Case nTipQbc == 2 .or.  nTipQbc == 4 // Usuario

							If  cUsuAnt <> (TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODEMP+(TrbBD7)->BD7_MATRIC+(TrbBD7)->BD7_TIPREG .and. ! lFirst

								cLinha :=  iif(lPaisagem,space(121),space(103)) + "Total:" + TransForm(nTotal,pMoeda2)

								R673Linha(cLinha,1,0)
								nTotal := 0
							Endif

							If  cUsuAnt <> (TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODEMP+(TrbBD7)->BD7_MATRIC+(TrbBD7)->BD7_TIPREG .or. lFirst

								If lP673MATR
									Execblock("P673MATR",.F.,.F.,{nTipQbc,cIni,cLinha})
								Else
									If  cImpMat == "1"
										cLinha := padR(transform(cMatric,"@R !!!!.!!!!.!!!!!!.!!-!"),21) + space(2) +;
													cNomUsu + space(1) +;
													cDatNas+ " Anos" + space(02)
										if lPaisagem
											cLinha +=		cLocReq + space(2) + ;
															cCoPart + space(02) + ;
															cDenReg + space(08) + cFadEnt + space(02)
										endIf
									Else	
										If  len(alltrim(BD6->BD6_MATANT)) == 17
											cLinha := 	padR(Transform(cMatAnt,"@R !!!!.!!!!.!!!!!!.!!-!"),21) + space(02) + ;
														cNomUsu + Space(1) + ;
														cDatNas + " Anos" + space(02)
											if lPaisagem
												cLinha +=		cLocReq + space(2) + ;
																cCoPart + space(02) + ;
																cDenReg + space(08) + cFadEnt + space(02)
											endIf
										Else
											cLinha := 	padR(Transform(cMatAnt,"@R !!!.!!!!.!!!!!!.!!-!"),21) + space(02) + ;
														cNomUsu + Space(1) + ;
														cDatNas + " Anos" + space(02)
											if lPaisagem
												cLinha +=		cLocReq + space(2)  + ;
																cCoPart + space(02) + ;
																cDenReg + space(08) + cFadEnt + space(02)
											endIf
										Endif
									Endif
								EndIf
								R673Linha(cLinha,1,0)
							Endif
							If  cProAnt <> (TrbBD7)->BD7_CODPAD+(TrbBD7)->BD7_CODPRO .Or. lFirst .or. lPaisagem

								cIni := 	cCodPad + space(2) + ;
											cCodPro	+ space(2) + ;
											cBD6Desc + space(2) +;
											iif(lPaisagem,	cDenReg + space(08) + cFadEnt,"")
							Endif
						Case nTipQbc == 3 // Impresso
							If  cImpAnt <> (TrbBD7)->BD7_NUMIMP+(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODEMP+(TrbBD7)->BD7_MATRIC+(TrbBD7)->BD7_TIPREG .And. ! lFirst

								cLinha := iif(lPaisagem,space(128),space(110)) + "Total:" + TransForm(nTotal,pMoeda2)

								R673Linha(cLinha,1,0)
								nTotal := 0
							Endif
							If  cImpAnt <> (TrbBD7)->BD7_NUMIMP+(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODEMP+(TrbBD7)->BD7_MATRIC+(TrbBD7)->BD7_TIPREG
								If  cImpMat == "1"
									cLinha := 	cNumImp + "-" + cSeq + "   " + PadR(Transform(cMatric,"@R !!!!.!!!!.!!!!!!.!!-!"),21) + space(2) +;
												cNomUsu + space(1) +;
												cDatNas + " Anos" + space(02)
									if lPaisagem
										cLinha +=		cLocReq + space(2) + ;
														cCoPart + space(02) + ;
														cDenReg + space(08) + cFadEnt + space(02)
									endIf
								Else
									If  len(alltrim(BD6->BD6_MATANT)) == 17
										cLinha := cNumImp + "-" + cSeq + "   " + padR(Transform(cMatAnt,"@R !!!!.!!!!.!!!!!!.!!-!"),21) + space(2) + ;
													cNomUsu + Space(1) + ;
													cDatNas + " Anos" + space(02)
										if lPaisagem
											cLinha +=		cLocReq + space(2) + ;
															cCoPart + space(02) + ;
															cDenReg + space(08) + cFadEnt + space(02)
										endIf
									Else
										cLinha := cNumImp + "-" + cSeq + "   " + padR(Transform(cMatAnt,"@R !!!.!!!!.!!!!!!.!!-!"),21) + space(2) + ;
													cNomUsu + Space(1) + ;
													cDatNas + " Anos" + space(02)
										if lPaisagem
											cLinha +=		cLocReq + space(2) + ;
															cCoPart + space(02) + ;
															cDenReg + space(08) + cFadEnt + space(02)
										endIf
									Endif
								Endif
								R673Linha(cLinha,1,0)
							Endif

							If  cProAnt <> (TrbBD7)->BD7_CODPAD+(TrbBD7)->BD7_CODPRO .Or. lFirst .OR. lPaisagem

								cIni := 	cCodPad + space(2) + ;
											cCodPro + space(2) + ;
											cBD6Desc + space(1) +;
											iif(lPaisagem,	cDenReg + space(08) + cFadEnt,"") + space(01)
                      Endif

                 	Case nTipQbc == 6

                 		If  cGuiAnt <> (TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODLDP+(TrbBD7)->BD7_CODPEG+(TrbBD7)->BD7_NUMERO .and. ! lFirst
                          	cLinha := IIF(lPaisagem,space(121),space(103)) + "Total:" + TransForm(nTotal,pMoeda2)  // ver caso negativo ags ???
                          	R673Linha(cLinha,1,0)
                          	nTotal := 0
                      Endif

                      If  cGuiAnt <> (TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODLDP+(TrbBD7)->BD7_CODPEG+(TrbBD7)->BD7_NUMERO .or. lFirst .OR. lPaisagem

                         If lP673MATR
                         	Execblock("P673MATR",.F.,.F.,{nTipQbc,cIni,cLinha})
                      	Else
                          	If  cImpMat == "1"
										cLinha := 	padR(transform(cMatric,"@R !!!!.!!!!.!!!!!!.!!-!"),21) + space(2) + ;
													cNomUsu + space(1) + ;
													cDatNas + " Anos" + space(02)
										if lPaisagem
											cLinha +=		cLocReq + space(2) + ;
															cCoPart + space(02) + ;
															cDenReg + space(08) + cFadEnt + space(02)
										endIf
									else
										if  len(alltrim(BD6->BD6_MATANT)) == 17
											cLinha := 	padR(Transform(cMatAnt,"@R !!!!.!!!!.!!!!!!.!!-!"),21) + space(02) + ;
														cNomUsu + space(1) + ;
														cDatNas + " Anos" + space(02)
											if lPaisagem
												cLinha +=		clocReq + space(2) + ;
																cCoPart + space(02) + ;
																cDenReg + space(08) + cFadEnt + space(02)
											endIf
										else
											cLinha := 	padR(Transform(cMatAnt,"@R !!!.!!!!.!!!!!!.!!-!"),21) + space(2) + ;
														cNomUsu + Space(1) + ;
														cDatNas + " Anos" + space(02)
											if lPaisagem
												cLinha +=		clocReq + space(2) + ;
																cCoPart + space(02) + ;
																cDenReg + space(08) + cFadEnt + space(02)
											endIf
										endIf
									endIf
								endif
								R673Linha(cLinha,1,0)
							endIf

							If  cGuiAnt+cProAnt <> (TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODLDP+(TrbBD7)->BD7_CODPEG+(TrbBD7)->BD7_NUMERO+(TrbBD7)->BD7_CODPAD+(TrbBD7)->BD7_CODPRO .or. lFirst .OR. lPaisagem
								cIni := 	cCodPad + space(2) + ;
											cCodPro + space(2) + ;
											cBD6Desc + space(1) +;
											iif(lPaisagem,	cDenReg + space(08) + cFadEnt,"") + space(01)
							Endif
						EndCase
				Endif
				lFirst := .F.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializa variaveis                                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  nNumImp == 3
					cMovime := objCENFUNLGP:verCamNPR("BD7_CODPEG", (TrbBD7)->BD7_CODPEG) + '-' + objCENFUNLGP:verCamNPR("BD7_NUMERO", (TrbBD7)->BD7_NUMERO) + '-' + cSeq
				Elseif  nNumImp == 1
					cMovime := Space(8) + '-' + objCENFUNLGP:verCamNPR("BD7_NUMERO", (TrbBD7)->BD7_NUMERO) + '-' + cSeq
				Else
					If  ! empty(BD6->BD6_NUMIMP)
						cMovime := Space(1) + cNumImp + '-' + cSeq
					Else
						cMovime := Space(8) + '-' + objCENFUNLGP:verCamNPR("BD7_NUMERO", (TrbBD7)->BD7_NUMERO) + '-' + cSeq
					Endif
				Endif

				nVlrRef   := (TrbBD7)->BD7_REFTDE * BD6->BD6_QTDPRO // ??? ags
				nVlrItem  := If(BAU->BAU_PAGPRO $ "1, ",Round((TrbBD7)->BD7_VLRPAG,2),0)
				nVlrGloIt := If(BAU->BAU_PAGPRO $ "1, " .And. BD6->BD6_PAGRDA <> "1",Round((TrbBD7)->BD7_VLRGLO,2),0)

				If  BAU->BAU_PAGPRO $ "1, " .and. ((TrbBD7)->BD7_BLOPAG == "1" .OR. (TrbBD7)->BD7_SITUAC == "3") .And. BD6->BD6_PAGRDA <> "1"
					nVlrGloIt := nVlrItem
					nVlrItem  := 0
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe bloqueio                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cGlosa  := " "
				cBloq   := " "
				cBloq1  := " "
				cDesBlo := ""
				If  (TrbBD7)->BD7_BLOPAG = '1' // bloqueado pelo BD7
					cBloq   := "B"
					If  (TrbBD7)->BD7_BLQAUG $ "1,2"
						cBloq1  := "A"
						cDesBlo := objCENFUNLGP:verCamNPR("BD7_DESBLO", "BLOQUEADO PELA ROTINA DE AUTO-GERADO")
					Else
						cBloq1  := "S"
						cDesBlo := objCENFUNLGP:verCamNPR("BD7_DESBLO", (TrbBD7)->BD7_DESBLO)
					Endif
				ElseIf (TrbBD7)->BD7_SITUAC = '3' // bloqueado pelo menu
					cBloq   := "B"
					cBloq1  := "S"
					cDesBlo := objCENFUNLGP:verCamNPR("BD7_DESBLO", (TrbBD7)->BD7_DESBLO)
				Else
					cGlosa := if(nVlrGloIt > 0,"G","")
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Imprime linha de detalhe                                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  lAnalitico

					//cClaIns := aTrbBD7[nI,24]
					cClaIns :=Iif((TrbBD7)->BD7_CLAINS == "1" ,"F" ,"J" )
					cClaIns := objCENFUNLGP:verCamNPR("BD7_CLAINS", cClaIns)

					Do Case
						Case nTipQbc == 1 .or. nTipQbc = 5 // Procedimento
							cLinha := 	cIni 						+ space(1) + ;
										PadR(cMovime,21)			+ space(1) + ;
										Str(BD6->BD6_QTDPRO,3)	+ space(1) + ;
										objCENFUNLGP:verCamNPR("BD7_CODUNM", (TrbBD7)->BD7_CODUNM)		+ space(1) + ;
										Str(nVlrRef,7,2)			+ space(1) + ;
										objCENFUNLGP:verCamNPR("BD7_UNITDE", (TrbBD7)->BD7_UNITDE)		+ space(1) + ;
										objCENFUNLGP:verCamNPR("BD7_DATPRO", dtoc((TrbBD7)->BD7_DATPRO))	+ space(1) + ;
										cClaIns						+ space(1) + ;
										TransForm(nVlrItem,pMoeda1)	+ space(1) + ;
										cGlosa						+ ;
										cBloq						+ space(1) +;
	        	                   IIf(lPaisagem,cDesLoc,"")

	                      cLinha := IIF(Empty(SubStr(cLinha,1,8)),SubStr(cLinha,9),cLinha)
	                      R673Linha(cLinha,1,0)

						Case nTipQbc == 2 .or. nTipQbc ==4 // Usuario
							cLinha := 	cIni 						+ space(1) + ;//	IIF(lPaisagem,Space(18),"")		   + ;
										PadR(cMovime,21)			+ space(1) + ;
										Str(BD6->BD6_QTDPRO,3)		+ space(1) + ;
										objCENFUNLGP:verCamNPR("BD7_CODUNM", (TrbBD7)->BD7_CODUNM)		+ space(1) + ;
										Str(nVlrRef,7,2)			+ space(1) + ;
										objCENFUNLGP:verCamNPR("BD7_UNITDE", (TrbBD7)->BD7_UNITDE)		+ space(1) + ;
										objCENFUNLGP:verCamNPR("BD7_DATPRO", dtoc((TrbBD7)->BD7_DATPRO))	+ space(1) + ;
										cClaIns						+ space(1) + ;
										TransForm(nVlrItem,pMoeda1)	+ space(1) + ;
										cGlosa						+ ;
										cBloq						+ space(1) +;
	        	                   IIf(lPaisagem,cDesLoc,"")

	                      cLinha := IIF(Empty(SubStr(cLinha,1,8)),SubStr(cLinha,9),cLinha)
	                      R673Linha(cLinha,1,0)

						Case nTipQbc == 3 // Impresso
							cLinha := 	cIni 						+ space(1) + ;
										PadR(cMovime,21)			+ space(1) + ;
										Str(BD6->BD6_QTDPRO,3)		+ space(1) + ;
										objCENFUNLGP:verCamNPR("BD7_CODUNM", (TrbBD7)->BD7_CODUNM)		+ space(1) + ;
										Str(nVlrRef,7,2)			+ space(1) + ;
										objCENFUNLGP:verCamNPR("BD7_UNITDE", (TrbBD7)->BD7_UNITDE)		+ space(1) + ;
										objCENFUNLGP:verCamNPR("BD7_DATPRO", dtoc((TrbBD7)->BD7_DATPRO))	+ space(1) + ;
										cClaIns						+ space(1) + ;
										TransForm(nVlrItem,pMoeda1)	+ space(1) + ;
										cGlosa						+  ;
										cBloq						+ space(1) +;
	        	                  	iif(lPaisagem,cDesLoc,"")

	                      cLinha := IIF(Empty(SubStr(cLinha,1,8)),SubStr(cLinha,9),cLinha)
	                      R673Linha(cLinha,1,0)

                 		Case nTipQbc == 6
                 			cLinha :=	cIni							+ space(1) + ;
										PadR(cMovime,21)			+ space(1) + ;
										Str(BD6->BD6_QTDPRO,3)	+ space(1) + ;
										objCENFUNLGP:verCamNPR("BD7_CODUNM", (TrbBD7)->BD7_CODUNM)		+ space(1) + ;
										Str(nVlrRef,7,2)			+ space(1) + ;
										objCENFUNLGP:verCamNPR("BD7_UNITDE", (TrbBD7)->BD7_UNITDE)		+ space(1) + ;
										objCENFUNLGP:verCamNPR("BD7_DATPRO", dtoc((TrbBD7)->BD7_DATPRO))	+ space(1) + ;
										cClaIns						+ space(1) + ;
										TransForm(nVlrItem,pMoeda1)	+ space(1) + ;
										cGlosa						+ ;
										cBloq						+ space(1) +;
										iif(lPaisagem,cDesLoc,"")

                      	  cLinha := iiF(Empty(SubStr(cLinha,1,8)),SubStr(cLinha,9),cLinha)
                      	  R673Linha(cLinha,1,0)
					EndCase
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Controle sobre glosas...                                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !empty(cGlosa) .or. ! empty(cBloq)

					if cBloq1 == "S"
				        cTipGlo := "Bl. Manual"
				 	elseIf cBloq1 == "A"
				        cTipGlo := "Bl.Aut-Ger"
				   	else
				        cTipGlo := "Glosa     "
				   	endif

					aadd(aGlosas,{(	TrbBD7)->R_E_C_N_O_ ,;
										(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODLDP+(TrbBD7)->BD7_CODPEG+(TrbBD7)->BD7_NUMERO+(TrbBD7)->BD7_ORIMOV+(TrbBD7)->BD7_CODPAD+(TrbBD7)->BD7_CODPRO+(TrbBD7)->BD7_SEQUEN,;
										nVlrGloIt,;
										cMovime,;
										objCENFUNLGP:verCamNPR("BD7_CODUNM", (TrbBD7)->BD7_CODUNM),;
										cTipGlo,;
										cDesBlo})
				EndIf

				If mv_par48 == 1
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Salva campos de quebra                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cUsuAnt :=	(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODEMP+(TrbBD7)->BD7_MATRIC+(TrbBD7)->BD7_TIPREG
					cImpAnt :=	(TrbBD7)->BD7_NUMIMP+(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODEMP+(TrbBD7)->BD7_MATRIC+(TrbBD7)->BD7_TIPREG
		         	cGuiAnt :=	(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODLDP+(TrbBD7)->BD7_CODPEG+(TrbBD7)->BD7_NUMERO
					lTem 	 := .T.
					If (TrbBD7)->BD7_CODPAD+(TrbBD7)->BD7_CODPRO <> cProAnt//mudou o procedimento
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Zera o Valor caso for por Procedimento       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nTipQbc == 1 .Or. nTipQbc == 5 // Procedimento
							nTotal:= 0
						EndIf
						
						cProAnt :=	(TrbBD7)->BD7_CODPAD+(TrbBD7)->BD7_CODPRO
					EndIf
				Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Salva campos de quebra                                                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (TrbBD7)->BD7_CODPAD+(TrbBD7)->BD7_CODPRO <> cProAnt //mudou o procedimento
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Zera o Valor caso for por Procedimento       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If nTipQbc == 1 .Or. nTipQbc == 5 // Procedimento
							nTotal:= 0
						EndIf
					EndIf
					cProAnt :=	(TrbBD7)->BD7_CODPAD+(TrbBD7)->BD7_CODPRO
					cUsuAnt :=	(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODEMP+(TrbBD7)->BD7_MATRIC+(TrbBD7)->BD7_TIPREG
					cImpAnt :=	(TrbBD7)->BD7_NUMIMP+(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODEMP+(TrbBD7)->BD7_MATRIC+(TrbBD7)->BD7_TIPREG
		         	cGuiAnt :=	(TrbBD7)->BD7_CODOPE+(TrbBD7)->BD7_CODLDP+(TrbBD7)->BD7_CODPEG+(TrbBD7)->BD7_NUMERO
					lTem 	 := .T.
				EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Acumula valores                                                          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nTotal  += nVlrItem
				nVlrPag += nVlrItem

				Do Case
					Case (TrbBD7)->BD7_MODCOB <> '1' .And. (TrbBD7)->BD7_TIPUSR = '1' .And. (TrbBD7)->BD7_INTERC <> '1'
						aResProd[1]  += nVlrItem   //Custo Operacional PF
						aResProdT[1] += nVlrItem   //Custo Operacional PF
					Case (TrbBD7)->BD7_MODCOB <> '1' .And. (TrbBD7)->BD7_TIPUSR = '2' .And. (TrbBD7)->BD7_INTERC <> '1'
						aResProd[2]  += nVlrItem   //Custo Operacional PJ
						aResProdT[2] += nVlrItem   //Custo Operacional PJ
					Case (TrbBD7)->BD7_MODCOB = '1' .And. (TrbBD7)->BD7_TIPUSR = '1' .And. (TrbBD7)->BD7_INTERC <> '1'
						aResProd[3]  += nVlrItem   //Pre Pagamento PF
						aResProdT[3] += nVlrItem   //Pre Pagamento PF
					Case (TrbBD7)->BD7_MODCOB = '1' .And. (TrbBD7)->BD7_TIPUSR = '2' .And. (TrbBD7)->BD7_INTERC <> '1'
						aResProd[4]  += nVlrItem   //Pre Pagamento PJ
						aResProdT[4] += nVlrItem   //Pre Pagamento PJ
					Case (TrbBD7)->BD7_INTERC = '1'
						aResProd[5]  += nVlrItem   //Intercambio
						aResProdT[5] += nVlrItem   //Intercambio
					OtherWise
						aResProd[6]  += nVlrItem   //Outros
						aResProdT[6] += nVlrItem   //Outros
						aadd(aLog,{(TrbBD7)->BD7_CODOPE+"."+(TrbBD7)->BD7_CODLDP+"."+(TrbBD7)->BD7_CODPEG+"."+(TrbBD7)->BD7_NUMERO+"."+(TrbBD7)->BD7_ORIMOV+"."+(TrbBD7)->BD7_SEQUEN,(TrbBD7)->BD7_TIPUSR,(TrbBD7)->BD7_MODCOB,(TrbBD7)->BD7_INTERC } )
				EndCase
				if !lAutoma
					MsProcTxt(" " + objCENFUNLGP:verCamNPR("BAU_NOME", Left(AllTrim(BAU->BAU_NOME),20))+alltrim(str((TrbBD7)->(RECNO()))))
					ProcessMessages()
				endif	
				(TrbBD7)->(DbSkip())

		Enddo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ So finalizarei a area depois de processado todos os lotes                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosLot == len(aLotes)
			(TrbBD7)->(DbCloseArea())
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime total da producao medica do lote                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  lAnalitico
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Lista glosas                                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  Len(aGlosas) > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se for para agrupar procedimento e glosa, imprime a glosa                ³
			   //³ senão acrecenta a glosa ao aGlosas para imprimir tudo no final.          ³
			   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			    If lJunGlo
			        PLS673GL(@aGlosas,@cJusti,cBdxCodP,@nTotGlos,cAcao,@cGlosa,cTipGlo,pMoeda1, cLinha)
				Else
					R673Linha('',1,0)
					cLinha := "Glosa/Bloqueio     Movimento            Par      Valor Motivo Glosa/Bloqueio"
					R673Linha(cLinha,1,0)
					cLinha := "------------------ -------------------- --- ---------- -----------------------------------------------------------------------------"
					R673Linha(cLinha,1,0)
					nTotal := 0

					For I := 1 To Len(aGlosas)

						BD7->( DbGoTo(aGlosas[I,1]) )

						If  !empty(aGlosas[i,7])
							cLinha := allTrim(aGlosas[i,6]) + space(14) + alltrim(strtran(aGlosas[i,4],' ','')) + space(6) + allTrim(aGlosas[i,5]) + space(1) + transForm(aGlosas[i,3],pMoeda1) + space(1) + allTrim(aGlosas[i,7])
							R673Linha(cLinha,1,0)
						else
							If  BDX->(msSeek(xFilial("BDX")+aGlosas[i,2]))
								While ! BDX->(Eof()) .And. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN) == xFilial("BDX")+aGlosas[i,2]

									If  BDX->BDX_TIPREG $ " ,1,2"
										cAcao   := allTrim( X3COMBO("BDX_ACAO",BDX->BDX_ACAO) )

										If (BDX->BDX_ACAO $ '1' .or. aGlosas[i,3] > 0)

											if BDX->(FieldPos("BDX_OBS")) > 0
												cLinGlo := objCENFUNLGP:verCamNPR("BDX_OBS", allTrim(BDX->BDX_OBS)) //Controlam a impressão em várias linhas
											endIf
											cLinDes := objCENFUNLGP:verCamNPR("BDX_DESGLO", PadR(BDX->BDX_DESGLO,70))

											If allTrim(aGlosas[i,6]) <> "Glosa" .or. BDX->BDX_ACAO == '2'
												cLinha  := cAcao + "/" + alltrim(aGlosas[i,6])
											Else
												cLinha  := cAcao + space(16-len(cAcao))
											EndIf
											cLinha  +=  space(1) + alltrim(strtran(aGlosas[i,4],' ','')) + space(6) + allTrim(aGlosas[i,5]) + space(1) + transForm(aGlosas[i,3] ,pMoeda1) + space(1) + objCENFUNLGP:verCamNPR("BDX_CODGLO", allTrim(BDX->BDX_CODGLO)) + '-' + cLinDes

											R673Linha(cLinha,1,0)
											if !empty(cLinGlo)
												R673Linha('Obs: '+cLinGlo,1,0)
											endIf

											if !empty(BDX->BDX_RESPAL)
												cJusti   := 'Justif.: ' + objCENFUNLGP:verCamNPR("BDX_RESPAL", BDX->BDX_RESPAL)
												cBdxCodP := objCENFUNLGP:verCamNPR("BDX_CODPRO", BDX->BDX_CODPRO)

												R673Linha(cJusti,1,0)
												cJusti := ""
											endIf
											cGlosa  := Space(35)
										endIf
									endIf
									BDX->(DbSkip())
								endDo
							endIf

							If  !empty(cGlosa)
								R673Linha(alltrim(aGlosas[I,6]) + space(6) + cGlosa,1,0)
							Endif

						Endif

						nTotal += aGlosas[i,3]

					Next

					cLinha := space(97) + "Total Glosa: " + space(11) + transForm(nTotal,pMoeda1)
					R673Linha(cLinha,1,0)
					R673Linha(""    ,1,0)

					aGlosas := {}
				EndIf
			Endif
			If  ! lTem
				If lLisRes
					cLinha := "Nenhum lancamento ref detalhes da producao"
					R673Linha(cLinha,2,1)
				EndIf
			Else
				If    nTipQbc == 1 .or. nTipQbc == 5

					if lImpLocRq .and. lPaisagem
						cLinAux := Space(47)
					ElseIf lPaisagem
						cLinAux := Space(27)
					Else
						cLinAux := Space(3)
					EndIf

					cLinha := cLinAux + space(100) + "Total:        " + TransForm(nTotal,pMoeda2)  // ver caso negativo ags ???
					R673Linha(cLinha,1,0)
					cLinha := cLinAux + space(88) + "Total da producao:        " + TransForm(nVlrPag,pMoeda2)  // ver caso negativo ags ???
					R673Linha(cLinha,2,0)

				ElseIf nTipQbc == 2 .or.  nTipQbc == 4 // Usuario

					cLinha := IIF(lPaisagem,space(121),space(103)) + "Total:" + TransForm(nTotal,pMoeda2)  // ver caso negativo ags ???
					R673Linha(cLinha,1,0)
					cLinha := IIF(lPaisagem,space(109),space(91)) + "Total da producao:" + TransForm(nVlrPag,pMoeda2)  // ver caso negativo ags ???
                    R673Linha(cLinha,2,0)
                ElseIf nTipQbc == 6
                    cLinha := IIF(lPaisagem,space(121),space(103)) + "Total:" + TransForm(nTotal,pMoeda2)  // ver caso negativo ags ???
                    R673Linha(cLinha,1,0)
                    cLinha := IIF(lPaisagem,space(109),space(91)) + "Total da producao:" + TransForm(nVlrPag,pMoeda2)  // ver caso negativo ags ???
					R673Linha(cLinha,2,0)

				Else
					cLinha := IIF(lPaisagem,space(128),space(110)) + "Total:" + TransForm(nTotal,pMoeda2)  // ver caso negativo ags ???
					R673Linha(cLinha,1,0)
					cLinha := IIF(lPaisagem,space(116),space(98)) + "Total da producao:" + TransForm(nVlrPag,pMoeda2)  // ver caso negativo ags ???
					R673Linha(cLinha,2,0)
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Lista cabecalho                                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If  lLisRes
				cLinha := Replicate('-',nLimite)
				R673Linha(cLinha,1,0)
				cLinha := "Outros Creditos/Debitos       Descricao                                   Credito         Debito"
				R673Linha(cLinha,1,0)
				cLinha := "-----------------------       ------------------------------------        -------         ------"
				R673Linha(cLinha,1,0)
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Lista outros debitos/creditos                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			R673DC(cOpeLot,cNumLot,.T.,lLisRes)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Total debitos/creditos                                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nDebTot := nDebFix + nDebVar + nDebApo
			nCreTot := nCreFix + nCreVar + nCreApo

			If  lLisRes
				cLinha := Padr("Total Outros Creditos/Debitos",65,".") + ": " + TransForm(nCreTot,pMoeda2) + " "  + TransForm(nDebTot,pMoeda2)
				R673Linha(cLinha,2,0)
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta resumo                                                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For i := 1 to len(aGlosas)
				nTotGlos += aGlosas[i,3]
			Next

			cValor  := TransForm(nTotGlo,pMoeda2)
			aadd(aTabRes,{"Total Glosa",cValor,Space(Len(cValor)),Space(Len(cValor)),""})

			aTabRes := {}
			nVlrTot := nVlrPag + nCreFix + nCreVar + nCreApo - nDebFix - nDebVar - nDebApo
			cValor  := TransForm(nVlrTot,pMoeda2)

			If  nVlrTot >= 0
				cValor  := TransForm(nVlrTot,pMoeda2)
				aadd(aTabRes,{"Total Bruto",cValor,Space(Len(cValor)),Space(Len(cValor)),""})
			Else
				cValor  := TransForm(nVlrTot * -1,pMoeda2)
				aadd(aTabRes,{"Total Bruto",Space(Len(cValor)),cValor,Space(Len(cValor)),""})
			Endif

			nBIss     := 0
			nIss      := 0
			nBPis     := 0
			nPis      := 0
			nBCofins  := 0
			nCofins   := 0
			nBIR      := 0
			nIR       := 0
			nBCSLL    := 0
			nCSLL     := 0
			nBINSSPF  := 0
			nINSSPF   := 0
			nBINSSPJ  := 0
			nINSSPJ   := 0
			nBINSSJF  := 0
			nINSSJF   := 0
			nPINSSPJ  := 0
			nPINSSPF  := 0
			nCrPINSS  := 0

			If  nFase == 2 .OR. nFase == 4//somente faturadas
				//Buscar imposto PIS, Cofins, CSLL, IR e INSS PF, INSSPJ
				BMR->(DbSetOrder(3))
				If  BMR->(msSeek(xFilial("BMR")+cCodOpe+BAU->BAU_CODIGO+cOpeLot+cNumLot))
					While ! BMR->(Eof()) .And. BMR->(BMR_FILIAL+BMR_OPERDA+BMR_CODRDA+BMR_OPELOTE+BMR_ANOLOT+BMR_MESLOT+BMR_NUMLOT) == ;
						xFilial("BMR")+cCodOpe+BAU->BAU_CODIGO+cOpeLot+cNumLot
						Do Case
							Case BMR->BMR_CODLAN == "182"
								nBINSSPJ  += BMR->BMR_VLRPAG
								ntBINSSPJ += BMR->BMR_VLRPAG
								lInssUnic := .T.
							Case BMR->BMR_CODLAN == "183"
								nINSSPJ   += BMR->BMR_VLRPAG
								ntINSSPJ  += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "184"
								nBIss     += BMR->BMR_VLRPAG
								ntBIss    += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "185"
								nIss      += BMR->BMR_VLRPAG
								ntIss     += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "186"
								nBPis     += BMR->BMR_VLRPAG
								ntBPis    += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "187"
								nPis      += BMR->BMR_VLRPAG
								ntPis     += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "188"
								nBCofins  += BMR->BMR_VLRPAG
								ntBCofins += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "189"
								nCofins   += BMR->BMR_VLRPAG
								ntCofins  += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "190"
								nBCSLL    += BMR->BMR_VLRPAG
								ntBCSLL   += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "191"
								nCSLL     += BMR->BMR_VLRPAG
								ntCSLL    += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "192"
								nBINSSPF  += BMR->BMR_VLRPAG
								ntBINSSPF += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "193"
								nINSSPF   += BMR->BMR_VLRPAG
								ntINSSPF  += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "194"
								nBINSSPJ  += BMR->BMR_VLRPAG
								ntBINSSPJ += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "195"
								nINSSPJ   += BMR->BMR_VLRPAG
								ntINSSPJ  += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "196"
								nBINSSPF  += BMR->BMR_VLRPAG
								ntBINSSPF += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "197"
								nINSSPF   += BMR->BMR_VLRPAG
								ntINSSPF  += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "198"
								nBIR      += BMR->BMR_VLRPAG
								ntBIR     += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "199"
								nIR       += BMR->BMR_VLRPAG
								ntIR      += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "179"
								nPINSSPJ  += BMR->BMR_VLRPAG
								ntPINSSPJ += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "180"
								nPINSSPF  += BMR->BMR_VLRPAG
								ntPINSSPF += BMR->BMR_VLRPAG
							Case BMR->BMR_CODLAN == "181"
								nCrPINSS  += BMR->BMR_VLRPAG
								ntCrPINSS += BMR->BMR_VLRPAG
						EndCase
						BMR->(DbSkip())
					Enddo
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Busca impostos calculados                                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If  Len(aLotes) == 1 .and. lLotImp
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Monta query                                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cSQL := " SELECT BMR_ANOLOT, BMR_MESLOT, BMR_CODLAN, BMR_VLRPAG, R_E_C_N_O_ AS BMR_RECNO"
					cSQL += "  FROM " + RetSQLName("BMR")
					cSQL += "  WHERE BMR_FILIAL = '" + xFilial("BMR") + "' "
					cSQL += "    AND BMR_CODRDA = '" + BAU->BAU_CODIGO + "' "
					cSQL += "    AND BMR_ANOLOT = '" + cAno    + "' "
					cSQL += "    AND BMR_MESLOT = '" + cMes    + "' "
					If ! Empty(dDatAte) .And. ! Empty(cLotBMR)
						cSQL += "    AND BMR_NUMLOT IN (" + cLotBMR + ") "
					EndIf
					cSQL += "    AND BMR_CODLAN IN ('183','193','195','197','199') "
					cSQL += "    AND D_E_L_E_T_ = ' ' "
					cSQL += " ORDER BY BMR_ANOLOT, BMR_MESLOT ,R_E_C_N_O_ "
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa query                                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cSQL := ChangeQuery(cSQL)
					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Processa arquivo de trabalho                                        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					While ! Trb->(Eof())
						Do Case
							Case TRB->BMR_CODLAN == "183" ; nINSSPJ 	+= Trb->BMR_VLRPAG ; lInssUnic := .T.  // inss PF
							Case TRB->BMR_CODLAN == "193" ; nINSSPF 	+= Trb->BMR_VLRPAG  // inss PF
							Case TRB->BMR_CODLAN == "195" ; nINSSPJ 	+= Trb->BMR_VLRPAG  // inss PJ
							Case TRB->BMR_CODLAN == "197" ; nINSSPF 	+= Trb->BMR_VLRPAG  // inss PJ filantropico
							Case TRB->BMR_CODLAN == "199" ; nIR     	+= Trb->BMR_VLRPAG  // ir
							Case TRB->BMR_CODLAN == "179" ; nPINSSPJ	+= TRB->BMR_VLRPAG  // Prov INSS PJ
							Case TRB->BMR_CODLAN == "180" ; nPINSSPF	+= TRB->BMR_VLRPAG  // Prov INSS PF
							Case TRB->BMR_CODLAN == "181" ; nCrPINSS	+= TRB->BMR_VLRPAG  // Cred Prov INSS
						EndCase
						Trb->(DbSkip())
					Enddo
					Trb->(dbCloseArea())
				Endif

				If nPis+nCofins+nCSLL == 0
					cSQL := " SELECT R_E_C_N_O_  AS E2_RECNO "
					cSQL += "  FROM " + RetSQLName("SE2")
					cSQL += "  WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
					cSQL += "    AND E2_CODRDA = '" + BAU->BAU_CODIGO + "' "
					cSQL += "    AND E2_PLLOTE = '" + cNumLot + "' "
					cSQL += "    AND D_E_L_E_T_ = ' ' "
					cSQL += " ORDER BY E2_VENCTO "
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Executa query                                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cSQL := ChangeQuery(cSQL)
					dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)
         			While ! Trb->(eof())
						SE2->(dbGoTo(Trb->E2_RECNO))
						If (SE2->E2_TIPO == MVINSS .And. ;
							IIf(GetNewPar("MV_PLPGUNI","1") == "3", IIf(SE2->(FieldPos("E2_FORORI")) > 0, Empty(SE2->E2_FORORI), .T.), .T.)) .Or. ;
							SE2->E2_TIPO == MVTAXA
							Trb->(dbSkip())
							Loop
						Endif

						nPis 		+= SE2->E2_VRETPIS
						nCofins 	+= SE2->E2_VRETCOF
					   nCSLL  	+= SE2->E2_VRETCSL

					   ntPis    += SE2->E2_VRETPIS
			    		ntCofins += SE2->E2_VRETCOF
			    		ntCSLL   += SE2->E2_VRETCSL
			    		Trb->(dbSkip())
					EndDo
					Trb->(dbCloseArea())
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Monta resumo                                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cValor := TransForm(0,pMoeda2) // apenas para pegar o tamanho deste campo

				If  nIss > 0
					aadd(aTabRes,{"ISS",Space(Len(cValor)),TransForm(nIss,pMoeda2),TransForm(nBIss,pMoeda2),""})
				Endif
				If  nPis > 0
					aadd(aTabRes,{"PIS",Space(Len(cValor)),TransForm(nPis,pMoeda2),TransForm(nBPis,pMoeda2),""})
				Endif
				If  nCofins > 0
					aadd(aTabRes,{"COFINS",Space(Len(cValor)),TransForm(nCofins,pMoeda2),TransForm(nBCofins,pMoeda2),""})
				Endif
				If  nCSLL   > 0
					aadd(aTabRes,{"CSLL",Space(Len(cValor)),TransForm(nCSLL,pMoeda2),TransForm(nBCSLL,pMoeda2),""})
				Endif
				If  nPINSSPF > 0
					aadd(aTabRes,{"Prov INSS PF",Space(Len(cValor)),TransForm(nPINSSPF,pMoeda2),TransForm(nBINSSPF,pMoeda2),""})
				Endif
				If  nPINSSPJ > 0
					aadd(aTabRes,{"Prov INSS PJ",Space(Len(cValor)),TransForm(nPINSSPJ,pMoeda2),TransForm(nBINSSPJ,pMoeda2),""})
				Endif
				If  nINSSPF > 0
					aadd(aTabRes,{"INSS PF",Space(Len(cValor)),TransForm(nINSSPF,pMoeda2),TransForm(nBINSSPF,pMoeda2),""})
				Endif
				If  nINSSPJ > 0
					aadd(aTabRes,{iif(lInssUnic,"INSS","INSS PJ"),Space(Len(cValor)),TransForm(nINSSPJ,pMoeda2),TransForm(nBINSSPJ,pMoeda2),""})
				Endif
				If  nINSSJF > 0
					aadd(aTabRes,{"INSS JF",Space(Len(cValor)),TransForm(nINSSJF,pMoeda2),TransForm(nBINSSJF,pMoeda2),""})
				Endif
				If  nIR > 0
					aadd(aTabRes,{"I.R",Space(Len(cValor)),TransForm(nIR,pMoeda2),TransForm(nBIR,pMoeda2),cDepIr})
				Endif
				If  nCrPINSS > 0
					aadd(aTabRes,{"Cred Prov INSS",TransForm(nCrPINSS,pMoeda2),space(len(cValor)),space(len(cValor)),""})
				Endif
			Endif

		   	nVlrTot := nVlrPag + nCreTot - nDebTot - nIss - nPis - nCofins - nCSLL - nINSSPF - nINSSPJ - nINSSJF - nIR - nPINSSPF - nPINSSPJ + nCrPINSS

			If  nVlrTot > 0
				cValor := TransForm(nVlrTot,pMoeda2)
				aadd(aTabRes,{"Total Liquido",cValor,Space(Len(cValor)),Space(Len(cValor)),""})
			Else
				cValor := TransForm(nVlrTot * -1,pMoeda2)
				aadd(aTabRes,{"Total Liquido",Space(Len(cValor)),cValor,Space(Len(cValor)),""})
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta cabecalho                                                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCabec1 := "Tipo Debito/Credito           Descricao                                   Credito         Debito"
			cCabec2 := ""
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime resumo do lote da RDA                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			R673RDA()
			R673Res_Prod(aResProd)

			R673DC(cOpeLot,cNumLot,.F.,!lLisRes)

			nDebTot := nDebFix + nDebVar + nDebApo
			nCreTot := nVlrPag + nCreFix + nCreVar + nCreApo

			cLinha := Padr("Total Creditos/Debitos",65,".") + ": " + TransForm(nCreTot,pMoeda2) + " "  + TransForm(nDebTot,pMoeda2)

			R673Linha(cLinha,2,0)
			R673Res()
		Endif
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecha area se a mesma ainda estiver aberta                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Select("TrbBD7") > 0
		(TrbBD7)->(DbCloseArea())
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime resumo da RDA                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  len(aLotes) > 1 .or. ! lAnalitico

		If Empty(dDatAte)
			cTitulo := AllTrim(cTitulo) + " - RESUMO MENSAL"
		EndIf

		R673RDA(.F.)
		R673Res_Prod(aResProdT)

		If  lAnalitico
			R673DC("","",.F.,.T.)
		Else
			R673DC("","",.T.,.T.)
		Endif
		nVlrPag := aResProdT[1] + aResProdT[2] + aResProdT[3] + aResProdT[4] + aResProdT[5] + aResProdT[6] + aResProdT[7]

		nDebTot := ntDebFix + ntDebVar + ntDebApo
		nCreTot := nVlrPag + ntCreFix + ntCreVar + ntCreApo

		cLinha := Padr("Total Creditos/Debitos",65,".") + ": " + TransForm(nCreTot,pMoeda2) + " "  + TransForm(nDebTot,pMoeda2)

		R673Linha(cLinha,2,0)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Busca impostos calculados                                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (! GetNewPar("MV_PLPGUNI","1") $ "1,3" .and. BAU->BAU_CALIMP == "3") .or. ;
			! lAnalitico
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa variaveis                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			ntBIss    := 0
			ntIss     := 0
			ntBPis    := 0
			ntPis     := 0
			ntBCofins := 0
			ntCofins  := 0
			ntBCSLL   := 0
			ntCSLL    := 0
			ntBINSSPF := 0
			ntINSSPF  := 0
			ntBINSSPJ := 0
			ntINSSPJ  := 0
			ntBINSSPF := 0
			ntINSSPF  := 0
			ntPINSSPJ := 0
			ntPINSSPF := 0
			ntCrPINSS := 0
			ntBIR    	:= 0
			ntIR     	:= 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta query                                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSQL := " SELECT BMR_ANOLOT, BMR_MESLOT, BMR_CODLAN, BMR_VLRPAG, R_E_C_N_O_ AS BMR_RECNO"
			cSQL += "  FROM " + RetSQLName("BMR")
			cSQL += "  WHERE BMR_FILIAL = '" + xFilial("BMR") + "' "
			cSQL += "    AND BMR_CODRDA = '" + BAU->BAU_CODIGO + "' "
			cSQL += "    AND BMR_ANOLOT = '" + cAno    + "' "
			cSQL += "    AND BMR_MESLOT = '" + cMes    + "' "
			If ! Empty(dDatAte) .And. ! Empty(cLotBMR)
				cSQL += "    AND BMR_NUMLOT IN (" + cLotBMR + ")
			EndIf
			cSQL += "    AND D_E_L_E_T_ = ' ' "
			cSQL += " ORDER BY BMR_ANOLOT, BMR_MESLOT ,R_E_C_N_O_ "
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa query                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Processa arquivo de trabalho                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While ! Trb->(eof())
				Do Case
					Case TRB->BMR_CODLAN == "182" ; ntBINSSPJ += TRB->BMR_VLRPAG ; lInssUnic := .T.
					Case TRB->BMR_CODLAN == "183" ; ntINSSPJ  += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "184" ; ntBIss    += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "185" ; ntIss     += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "186" ; ntBPis    += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "187" ; ntPis     += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "188" ; ntBCofins += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "189" ; ntCofins  += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "190" ; ntBCSLL   += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "191" ; ntCSLL    += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "192" ; ntBINSSPF += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "193" ; ntINSSPF  += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "194" ; ntBINSSPJ += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "195" ; ntINSSPJ  += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "196" ; ntBINSSPF += TRB->BMR_VLRPAG //nBINSSJF += BMR->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "197" ; ntINSSPF  += TRB->BMR_VLRPAG //nINSSJF  += BMR->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "198" ; ntBIR     += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "199" ; ntIR      += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "179" ; ntPINSSPJ += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "180" ; ntPINSSPF += TRB->BMR_VLRPAG
					Case TRB->BMR_CODLAN == "181" ; ntCrPINSS += TRB->BMR_VLRPAG
				EndCase
				Trb->(dbSkip())
			Enddo
			Trb->(dbCloseArea())
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta resumo                                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For i := 1 to len(aGlosas)
			nTotGlo += aGlosas[i,3]
		Next

		cValor  := TransForm(nTotGlo,pMoeda2)
		aadd(aTabRes,{"Total Glosa",space(len(cValor)),cValor,space(len(cValor)),""})

		aTabRes := {}
		nVlrTot := nVlrPag + ntCreFix + ntCreVar + ntCreApo - ntDebFix - ntDebVar - ntDebApo
		cValor  := TransForm(nVlrTot,pMoeda2)
		If  nVlrTot >= 0
			cValor  := TransForm(nVlrTot,pMoeda2)
			aadd(aTabRes,{"Total Bruto",cValor,space(len(cValor)),space(len(cValor)),""})
		Else
			cValor  := TransForm(nVlrTot * -1,pMoeda2)
			aadd(aTabRes,{"Total Bruto",space(len(cValor)),cValor,space(len(cValor)),""})
		Endif

		If ntPis+ntCofins+ntCSLL == 0
			cSQL := " SELECT R_E_C_N_O_  AS E2_RECNO "
			cSQL += "  FROM " + RetSQLName("SE2")
			cSQL += "  WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
			cSQL += "    AND E2_CODRDA = '" + BAU->BAU_CODIGO + "' "
			cSQL += "    AND E2_PLLOTE = '" + cNumLot + "' "
			cSQL += "    AND D_E_L_E_T_ = ' ' "
			cSQL += " ORDER BY E2_VENCTO "
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa query                                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)
			While ! Trb->(eof())
				SE2->(dbGoTo(Trb->E2_RECNO))
				If (SE2->E2_TIPO == MVINSS .And. ;
					IIf(GetNewPar("MV_PLPGUNI","1") == "3", IIf(SE2->(FieldPos("E2_FORORI")) > 0, Empty(SE2->E2_FORORI), .T.), .T.)) .Or. ;
					SE2->E2_TIPO == MVTAXA
					Trb->(dbSkip())
					Loop
				Endif

				nPis    += SE2->E2_VRETPIS
				nCofins += SE2->E2_VRETCOF
		    	nCSLL   += SE2->E2_VRETCSL

				ntPis    += SE2->E2_VRETPIS
				ntCofins += SE2->E2_VRETCOF
				ntCSLL   += SE2->E2_VRETCSL
			Trb->(dbSkip())
			End
			Trb->(dbCloseArea())
		Endif

		If  nFase == 2 .OR. nFase == 4 //somente faturadas
			cValor := TransForm(0,pMoeda2) // apenas para pegar o tamanho deste campo
			If  ntIss > 0 .or. ntBIss > 0
				aadd(aTabRes,{"ISS"    ,space(len(cValor)),TransForm(ntIss   ,pMoeda2),TransForm(ntBIss   ,pMoeda2),""})
			Endif
			If  ntPis > 0 .or. ntBPis > 0
				aadd(aTabRes,{"PIS"    ,space(len(cValor)),TransForm(ntPis   ,pMoeda2),TransForm(ntBPis   ,pMoeda2),""})
			Endif
			If  ntCofins > 0 .or. ntBCofins > 0
				aadd(aTabRes,{"COFINS" ,space(len(cValor)),TransForm(ntCofins,pMoeda2),TransForm(ntBCofins,pMoeda2),""})
			Endif
			If  ntCSLL   > 0 .or. ntBCSLL > 0
				aadd(aTabRes,{"CSLL"   ,space(len(cValor)),TransForm(ntCSLL  ,pMoeda2),TransForm(ntBCSLL  ,pMoeda2),""})
			Endif
			If  ntPINSSPF > 0
				aadd(aTabRes,{"Prov INSS PF",space(len(cValor)),TransForm(ntPINSSPF,pMoeda2),space(len(cValor)),""})
			Endif
			If  ntPINSSPJ > 0
				aadd(aTabRes,{"Prov INSS PJ",space(len(cValor)),TransForm(ntPINSSPJ,pMoeda2),space(len(cValor)),""})
			Endif
			If  ntINSSPF > 0 .or. ntBINSSPF > 0
				aadd(aTabRes,{"INSS PF",space(len(cValor)),TransForm(ntINSSPF,pMoeda2),TransForm(ntBINSSPF,pMoeda2),""})
			Endif
			If  ntINSSPJ > 0 .or. ntBINSSPJ > 0
				If  lInssUnic
					aadd(aTabRes,{"INSS"   ,space(len(cValor)),TransForm(ntINSSPJ,pMoeda2),TransForm(ntBINSSPJ,pMoeda2),""})
				Else
					aadd(aTabRes,{"INSS PJ",space(len(cValor)),TransForm(ntINSSPJ,pMoeda2),TransForm(ntBINSSPJ,pMoeda2),""})
				Endif
			Endif
			If  ntINSSJF > 0 .or. ntBINSSJF > 0
				aadd(aTabRes,{"INSS JF",space(len(cValor)),TransForm(ntINSSJF,pMoeda2),TransForm(ntBINSSJF,pMoeda2),""})
			Endif
			If  ntIR > 0 .or. ntBIR > 0
				aadd(aTabRes,{"I.R"    ,space(len(cValor)),TransForm(ntIR    ,pMoeda2),TransForm(ntBIR    ,pMoeda2),cDepIr})
			Endif
			If  ntCrPINSS > 0
				aadd(aTabRes,{"Cred Prov INSS",TransForm(ntCrPINSS,pMoeda2),space(len(cValor)),space(len(cValor)),""})
			Endif
		Endif

	  	nVlrTot := nCreTot - nDebTot - ntIss - ntPis - ntCofins - ntCSLL - ntINSSPF - ntINSSPJ - ntINSSJF - ntIR - ntPINSSPJ - ntPINSSPF + ntCrPINSS

		If  nVlrTot > 0
			cValor := TransForm(nVlrTot,pMoeda2)
			aadd(aTabRes,{"Total Liquido",cValor,space(len(cValor)),space(len(cValor)),""})
		Else
			cValor := TransForm(nVlrTot * -1,pMoeda2)
			aadd(aTabRes,{"Total Liquido",space(len(cValor)),cValor,space(len(cValor)),""})
		Endif
		R673Res()
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime os titulos gerados                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  ( nFase == 2 .OR. nFase == 4 ) .and. lLisTit
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta query                                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  empty(cLotes)
			cLotes := "('')"
		Endif
		cSQL := " SELECT R_E_C_N_O_  AS E2_RECNO "
		cSQL += "  FROM " + RetSQLName("SE2")
		cSQL += "  WHERE E2_FILIAL = '" + xFilial("SE2") + "' "
		cSQL += "    AND E2_CODRDA = '" + BAU->BAU_CODIGO + "' "
		cSQL += "    AND E2_PLLOTE IN " + cLotes
		cSQL += "    AND D_E_L_E_T_ = ' ' "
		cSQL += " ORDER BY R_E_C_N_O_ "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa query                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"Trb",.F.,.T.)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa arquivo de trabalho                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aTitulos := {}
		SE5->(dbSetOrder(5))//E5_FILIAL+E5_LOTE+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)
		While ! Trb->(eof())
			SE2->(dbGoTo(Trb->E2_RECNO))

			if SE5->(msSeek(xFilial("SE5")+SE2->(E2_LOTE+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO))) .and. SE5->E5_MOTBX == GetNewPar("MV_PLMOTBC","CAN")
				trb->(dbSkip())
				loop
			endIf

			if !empty(SE2->E2_PARCELA)
				Trb->(dbSkip())
				loop
			endif

			nPos := aScan(aTitulos,{|x| x[1]+x[2]+x[3] == SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_TIPO})
			If  nPos == 0
				//             1-prefixo,       2-numero,   3-tipo, 4-emissao, 5-vencto, 6-valor, 7-ir, 8-inss, 9-acrescimo, 10-decrescimo, 11-Outros Impostos (PIS/COFINS/CSLL/ISS)
				aadd(aTitulos,{objCENFUNLGP:verCamNPR("E2_PREFIXO", SE2->E2_PREFIXO),objCENFUNLGP:verCamNPR("E2_NUM", SE2->E2_NUM),""     ,ctod("")  ,ctod("") ,0       ,0    ,0, 0, 0, 0, .F.,0})
				nPos := len(aTitulos)
			Endif

			nValor := SE2->E2_VALOR
			aTitulos[nPos,4]	:= SE2->E2_EMISSAO
			aTitulos[nPos,5] 	:= SE2->E2_VENCTO

			if allTrim(SE2->E2_TIPO) == "NDF"
				aTitulos[nPos,6] -= nValor

				Trb->(dbSkip())
				loop
			endif

			nOutImp := SE2->E2_VRETPIS + SE2->E2_VRETCOF + SE2->E2_VRETCSL

		  	aTitulos[nPos,3] 	:= SE2->E2_TIPO
			aTitulos[nPos,6] 	:= nValor + SE2->E2_IRRF + SE2->E2_INSS + SE2->E2_ISS + nOutImp
			aTitulos[nPos,7] 	:= iif(aTitulos[nPos, 7] == 0, SE2->E2_IRRF, aTitulos[nPos, 7])
			aTitulos[nPos,8] 	:= iif(aTitulos[nPos, 8] == 0, IIf(SE2->E2_TIPO == MVINSS, nValor, SE2->E2_INSS), aTitulos[nPos, 8])
			aTitulos[nPos,9]	:= SE2->E2_ACRESC
			aTitulos[nPos,10]	:= SE2->E2_DECRESC
			aTitulos[nPos,11]	:= nOutImp
			aTitulos[nPos,12]	:= SE2->E2_ISS>0
			aTitulos[nPos,13]	:= SE2->E2_ISS

			Trb->(dbSkip())
		enddo
		Trb->(dbCloseArea())

		nTotVlr   	:= 0
		nTotIns   	:= 0
		nTotIrf   	:= 0
		nTotOutImp	:= 0
		nTotAcr   	:= 0
		nTotDec   	:= 0

		if  Len(aTitulos) > 0
		   	cLinha := "Titulos Gerados"
		   R673Linha(cLinha,1,1)
			cLinha := "Pfx  Numero   Tp  Emissao  Vencto            Valor           IRRF           INSS       Outr Imp  Acrescimo Decrescimo        Liquido"
			R673Linha(cLinha,1,0)
			cLinha := "--- --------- --- -------- -------- -------------- -------------- -------------- -------------- ---------- ---------- --------------"
			R673Linha(cLinha,1,0)
		endIf

		for nPos := 1 to len(aTitulos)
			nLiq := aTitulos[nPos,6] //E2_VALOR
			nLiq += aTitulos[nPos,9] //Acrescimo

			nLiq -= aTitulos[nPos,7] //E2_IRRF
			nLiq -= aTitulos[nPos,8] //E2_INSS
			nLiq -= aTitulos[nPos,11]//E2_VRETPIS + E2_VRETCOF + E2_VRETCSL + E2_VRETISS
			nLiq -= aTitulos[nPos,13]//E2_ISS
			nLiq -= aTitulos[nPos,10]//Decrescimo

			if nLiq < 0
				aTitulos[nPos,3] := "NDF"
			endIf

			cLinha :=	aTitulos[nPos,1] + space(1) +; //PFX
						aTitulos[nPos,2] + space(1) +; //Numero
						aTitulos[nPos,3] + space(1) +; //Tp
						objCENFUNLGP:verCamNPR("E2_EMISSAO", dtoc(aTitulos[nPos,4])) + space(1) +; //Emissao
						objCENFUNLGP:verCamNPR("E2_VENCTO", dtoc(aTitulos[nPos,5])) + space(1) +; //Vencto
						TransForm(aTitulos[nPos,6],pMoeda2) + space(1) +; //Valor
						TransForm(aTitulos[nPos,7],pMoeda2) + space(1) +; //Irrf
						TransForm(aTitulos[nPos,8],pMoeda2) + space(1) +; //Inss
						TransForm(aTitulos[nPos,11]+aTitulos[nPos,13],pMoeda2) + space(1) +; //Outr Imp
						TransForm(aTitulos[nPos,9],pMoeda1) + space(1) +; //Acrescimo
						TransForm(aTitulos[nPos,10],pMoeda1) + space(1) +; //Decrescimo
						TransForm(nLiq,pMoeda2) //Liquido

			R673Linha(cLinha,1,0)

			nTotVlr   += aTitulos[nPos,6]
			nTotIrf   += aTitulos[nPos,7]
			nTotIns   += aTitulos[nPos,8]
			nTotOutImp	+= aTitulos[nPos,11]+aTitulos[nPos,13]
			nTotAcr   += aTitulos[nPos,9]
			nTotDec   += aTitulos[nPos,10]
		next

		if len(aTitulos) > 1
			cLinha := "                                    -------------- -------------- -------------- -------------- ---------- ---------- --------------"
		   R673Linha(cLinha,1,1)

			nLiq := nTotVlr + nTotAcr - nTotIrf - nTotIns - nTotOutImp - nTotDec

			cLinha := "Total" + space(31) +;
						TransForm(nTotVlr,pMoeda2) 		+ space(1) +;
						TransForm(nTotIrf,pMoeda2) 		+ space(1) +;
						TransForm(nTotIns,pMoeda2) 		+ space(1) +;
						TransForm(nTotOutImp,pMoeda2) 	+ space(1) +;
						TransForm(nTotAcr,pMoeda1) 		+ space(1) +;
						TransForm(nTotDec,pMoeda1) 		+ space(1) +;
						TransForm(nLiq,pMoeda2)
			R673Linha(cLinha,1,0)
		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime as mensagens de extrato prestador (BN4)...                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMsgExt := PLSEXTPRE(BAU->BAU_CODIGO,cCodOpe,cAno,cMes,BAU->BAU_COPCRE)
	If  Len(aMsgExt) > 0
		cLinha := PadC("MENSAGENS DE EXTRATO", 132, "-")
		R673Linha(cLinha,1,2)
	Endif
	For nFor := 1 To Len(aMsgExt)
		cLinha := objCENFUNLGP:verCamNPR("BN4_MSG1", PadC(&(AllTrim(aMsgExt[nFor])), 132))
		R673Linha(cLinha,1,0)
	Next
	If  Len(aMsgExt) > 0
		cLinha := PadC("", 132, "-")
		R673Linha(cLinha,1,1)
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Imprime os dados do credenciado no fim da pagina...                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nFase <> 4 .Or. Len(aLotes) > 0
		nLi := 50
		BA0->(DbSetOrder(1))
		BA0->(msSeek(xFilial("BA0")+cCodOpe))
		
		cLinha := objCENFUNLGP:verCamNPR("BA0_CODIDE", BA0->BA0_CODIDE)+objCENFUNLGP:verCamNPR("BA0_CODINT", BA0->BA0_CODINT)+" - "+AllTrim(objCENFUNLGP:verCamNPR("BA0_NOMINT", BA0->BA0_NOMINT))+Space(02)+"CNPJ: "+transform(objCENFUNLGP:verCamNPR("BA0_NOMINT", BA0->BA0_CGC),"@R !!.!!!.!!!/!!!!-!!")
		R673Linha(cLinha,1,1)
		cLinha := objCENFUNLGP:verCamNPR("BAU_CODIGO", BAU->BAU_CODIGO) +' - '+objCENFUNLGP:verCamNPR("BAU_NOME", BAU->BAU_NOME)
		R673Linha(cLinha,1,0)
		If  len(alltrim(BAU->BAU_CPFCGC)) == 11
			cLinha := "INSS: " + objCENFUNLGP:verCamNPR("BAU_INSS", AllTrim(BAU->BAU_INSS))  + '   CPF: ' + transform(objCENFUNLGP:verCamNPR("BAU_CPFCGC", BAU->BAU_CPFCGC),"@R !!!.!!!.!!!-!!")
		Else
			cLinha := "INSS: " + objCENFUNLGP:verCamNPR("BAU_INSS", AllTrim(BAU->BAU_INSS)) + '   CNPJ: ' + transform(objCENFUNLGP:verCamNPR("BAU_CPFCGC", BAU->BAU_CPFCGC),"@R !!.!!!.!!!/!!!!-!!")
		Endif
		R673Linha(cLinha,1,0)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se eh para buscar o endereco pela RDA ou pelo Local de Atendimento    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  nImpEnd == 1 //RDA
			If BAU->(FieldPos("BAU_TIPLOG")) > 0 .and. !Empty(BAU->BAU_TIPLOG)
				B18->(Dbseek(xFilial("B18")+BAU->BAU_TIPLOG))
				cLinha := objCENFUNLGP:verCamNPR("B18_DESCRI", Alltrim(B18->B18_DESCRI)) +" "+ objCENFUNLGP:verCamNPR("BAU_END", Alltrim(BAU->BAU_END)) +;
						  Iif( BAU->(FieldPos("BAU_NUMERO")) > 0 .and. !Empty(BAU->BAU_NUMERO)," "+objCENFUNLGP:verCamNPR("BAU_NUMERO", BAU->BAU_NUMERO)," ")+ " - " + objCENFUNLGP:verCamNPR("BAU_BAIRRO", AllTrim(BAU->BAU_BAIRRO))
			Else
				cLinha := objCENFUNLGP:verCamNPR("BAU_END", Alltrim(BAU->BAU_END)) +Iif( BAU->(FieldPos("BAU_NUMERO")) > 0 .and. !Empty(BAU->BAU_NUMERO)," "+objCENFUNLGP:verCamNPR("BAU_NUMERO", BAU->BAU_NUMERO)," ")+ " - " + objCENFUNLGP:verCamNPR("BAU_BAIRRO", AllTrim(BAU->BAU_BAIRRO))
			Endif
			R673Linha(cLinha,1,0)
			cLinha := TransForm(objCENFUNLGP:verCamNPR("BAU_CEP", BAU->BAU_CEP),PesqPict("BAU","BAU_CEP")) + " - " + AllTrim(objCENFUNLGP:verCamNPR("BID_DESCRI", posicione("BID",1,xFilial("BID")+BAU->BAU_MUN,"BID_DESCRI"))) + " - " + objCENFUNLGP:verCamNPR("BAU_EST", BAU->BAU_EST)
			R673Linha(cLinha,1,0)
		Else //Local Atendimento
			BB8->(msSeek(xFilial("BB8")+BAU->BAU_CODIGO+cCodOpe))
			While ! BB8->(Eof()) .and. BB8->BB8_FILIAL == xFilial("BB8")  .and. ;
				BB8->BB8_CODIGO == BAU->BAU_CODIGO .and. ;
				BB8->BB8_CODINT == cCodOpe
				If  Empty(BB8->BB8_DATBLO)
					lLocEnd = .T.
					Exit
				Endif
				BB8->(DbSkip())
			Enddo
			If  lLocEnd
				cLinha := objCENFUNLGP:verCamNPR("BB8_END", AllTrim(BB8->BB8_END)) + " - " + objCENFUNLGP:verCamNPR("BB8_BAIRRO", AllTrim(BB8->BB8_BAIRRO))
				R673Linha(cLinha,1,0)
				cLinha := TransForm(objCENFUNLGP:verCamNPR("BB8_CEP", BB8->BB8_CEP),PesqPict("BB8","BB8_CEP")) + " - " + objCENFUNLGP:verCamNPR("BID_DESCRI", AllTrim(posicione("BID",1,xFilial("BID")+BB8->BB8_CODMUN,"BID_DESCRI"))) + " - " + objCENFUNLGP:verCamNPR("BB8_EST", BB8->BB8_EST)
				R673Linha(cLinha,1,0)
			Else
				cLinha := ""
				R673Linha(cLinha,1,0)
				cLinha := ""
				R673Linha(cLinha,1,0)
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime rodade padrao                                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Roda(0,space(10),cTamanho)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acessa proximo registro                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nLi:=68
	TrbBAU->(DbSkip())
Enddo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha arquivo de trabalho                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TrbBAU->(DbCloseArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mensagem de processamento                         		 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  len(aLog) > 0
	PLSCRIGEN(aLog,{{"Movimento","@!",120},{"BD7_TIPUSR","@!",50},{"BD7_MODCOB","@!",50},{"BD7_INTERC","@!",50}},"Ocorrencias no processamento",nil,nil)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Libera impressao                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  aReturn[5] == 1
	Set Printer To
	OurSpool(nrel)
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do Relat¢rio                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R673RDA   ³ Autor ³ Angelo Sperandio     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime dados da RDA                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function R673RDA(lImpLot)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime dados da RDA                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nLin, i
Default lImpLot := .T.
nli := 999
If  lLisFor
	cLinha := "Fornecedor: " + objCENFUNLGP:verCamNPR("A2_COD", SA2->A2_COD) + "-" + objCENFUNLGP:verCamNPR("A2_LOJA", SA2->A2_LOJA) + " " + objCENFUNLGP:verCamNPR("A2_NOME", SA2->A2_NOME)
	R673Linha(cLinha,1,0)
Endif
cRdaAnt := BAU->BAU_CODIGO
cLinha := "R.D.A.: " + objCENFUNLGP:verCamNPR("BAU_CODIGO", BAU->BAU_CODIGO) + "-" + objCENFUNLGP:verCamNPR("BAU_NOME", alltrim(BAU->BAU_NOME)) + ;
"  Classe: " + objCENFUNLGP:verCamNPR("BAG_DESCRI", alltrim(posicione("BAG",1,xFilial("BAG")+BAU->BAU_TIPPRE,"BAG_DESCRI"))) + ;
"  Tipo: " + objCENFUNLGP:verCamNPR("BAU_COPCRE", alltrim(X3COMBO("BAU_COPCRE",BAU->BAU_COPCRE)))
R673Linha(cLinha,1,0)
cLinha := "Especialidade: " + alltrim(cEspecia)
nLin := mlcount(cLinha,120)
For i := 1 to nLin
	R673Linha(memoline(cLinha,120,i),1,0)
Next
If  lImpLot
	cLinha := "Lote..: " + cOpeLot + " " + cNumLot + " - " + cDesLot
	R673Linha(cLinha,1,0)
Endif

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R673DC    ³ Autor ³ Angelo Sperandio     ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime outros debitos/creditos                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function R673DC(cOpeLot,cNumLot,lSoma,lLisRes)
Local cTit := ""
Local j:=0
Local i:=0
Local 	lCposVld	:=	(BBC->(FieldPos("BBC_VLDINI")) > 0 .And. BBC->(FieldPos("BBC_VLDFIM")) > 0)
Default cOpeLot := ""
Default cNumLot := ""
Default lSoma   := .T.

nDebFix := 0
nCreFix := 0
nCreVar := 0
nDebVar := 0
nCreApo := 0
nDebApo := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lista debitos/creditos fixos                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTit := "Creditos/Debitos Fixos:       "
lTem := .F.
If  nFase == 2 .OR. nFase == 4 // Faturada
	For J:=1 to len(aRecBGQ)

		BGQ->(DbGoto(aRecBGQ[j]))

		If  alltrim(BGQ->BGQ_NUMLAU) <> "BBC"
			Loop
		Endif

		BBB->(DbSetOrder(1))
		BBB->(msSeek(xFilial("BBB")+BGQ->BGQ_CODLAN))

		If  lLisRes // lAnalitico

			cValor := TransForm(BGQ->BGQ_VALOR,pMoeda2)

			If  BGQ->BGQ_TIPO == "1"
				If  lLisRes
					cLinha := cTit + Padr(objCENFUNLGP:verCamNPR("BGQ_CODLAN", BGQ->BGQ_CODLAN) + "-" + objCENFUNLGP:verCamNPR("BBB_DESCRI", alltrim(BBB->BBB_DESCRI)),nTamDes,".") + ": " + ;
					space(len(cValor)) + " " + cValor + " " + ;
					If(alltrim(BGQ->BGQ_NUMLAU) <> "BBC",objCENFUNLGP:verCamNPR("BGQ_OBS", substr(BGQ->BGQ_OBS,1,35)),"")
						R673Linha(cLinha,1,0)
				Endif
			Else
				If  BGQ->BGQ_TIPO == "2"
					If  lLisRes
							cLinha := cTit + Padr(objCENFUNLGP:verCamNPR("BGQ_CODLAN", BGQ->BGQ_CODLAN) + "-" + objCENFUNLGP:verCamNPR("BBB_DESCRI", alltrim(BBB->BBB_DESCRI)),nTamDes,".") + ": " + ;
							cValor + " " + space(len(cValor)) + " " + ;
							If(alltrim(BGQ->BGQ_NUMLAU) <> "BBC",objCENFUNLGP:verCamNPR("BGQ_OBS", substr(BGQ->BGQ_OBS,1,35)),"")
								R673Linha(cLinha,1,0)
					Endif
				Endif
				cTit := space(30)
			EndIf
		Endif
		If  BGQ->BGQ_TIPO == "1"
			nDebFix += BGQ->BGQ_VALOR
		Else
			If  BGQ->BGQ_TIPO == "2"
				nCreFix += BGQ->BGQ_VALOR
			Endif
		Endif
		lTem := .T.
	Next
Else

	BBC->(DbSetOrder(2))
	If  BBC->(msSeek(xFilial("BBC")+BAU->BAU_CODIGO+"11"))
		While ! BBC->(Eof()) .And. ;
			BBC->(BBC_FILIAL+BBC_CODIGO+BBC_STATUS+BBC_PROMED) == ;
			xFilial("BBC")+cRdaAnt+"11"
			If lCposVld
				If ! ( cAno + cMes + "01" >= DtoS(BBC->BBC_VLDINI) .And. ;
					(DtoS(LastDay(CtoD("01/"+cMes+"/"+cAno))) <= DtoS(BBC->BBC_VLDFIM) .Or. Empty(BBC->BBC_VLDFIM)) )
					BBC->(DbSkip())
					Loop
				EndIf
			EndIf
			BBB->(DbSetOrder(1))
			BBB->(msSeek(xFilial("BBB")+BBC->BBC_CODSER))
			If  lLisRes // lAnalitico
				cValor := TransForm(BBC->BBC_VALOR,pMoeda2)
				If  BBB->BBB_TIPSER == "1"
					If  lLisRes
						cLinha := cTit + Padr(objCENFUNLGP:verCamNPR("BBC_CODSER", BBC->BBC_CODSER) + "-" + objCENFUNLGP:verCamNPR("BBB_DESCRI", alltrim(BBB->BBB_DESCRI)),nTamDes,".") + ": " + ;
						space(len(cValor)) + " " + cValor
						R673Linha(cLinha,1,0)
					Endif
				Else
					If  BBB->BBB_TIPSER == "2"
						If  lLisRes
							cLinha := cTit + Padr(objCENFUNLGP:verCamNPR("BBC_CODSER", BBC->BBC_CODSER) + "-" + objCENFUNLGP:verCamNPR("BBB_DESCRI", alltrim(BBB->BBB_DESCRI)),nTamDes,".") + ": " + ;
							cValor + " " + space(len(cValor))
							R673Linha(cLinha,1,0)
						Endif
					Endif
				Endif
				cTit := space(30)
			Endif
			If  BBB->BBB_TIPSER == "1"
				nDebFix += BBC->BBC_VALOR
			Else
				If  BBB->BBB_TIPSER == "2"
					nCreFix += BBC->BBC_VALOR
				Endif
			Endif
			lTem := .T.
			BBC->(DbSkip())
		Enddo
	Endif
Endif
If  lLisRes
    cLinha := cTit + Padr("Total Creditos/Debitos Fixos",nTamDes,".") + ": " + ;
              TransForm(nCreFix,pMoeda2) + " " + ;
              TransForm(nDebFix,pMoeda2)
    R673Linha(cLinha,1,0)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lista debitos/creditos variaveis                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  lLisRes
    If  lLisRes // lAnalitico
        cLinha := Replicate(' ',nLimite)
        R673Linha(cLinha,1,0)
    Endif
Endif
cTit := "Creditos/Debitos Variaveis:   "
lTem := .F.
For i:=1 to len(aRecBGQ)

	BGQ->(DbGoto(aRecBGQ[i]))

 	If  alltrim(BGQ->BGQ_NUMLAU) == "BBC"
  		Loop
  	Endif
   If  nFase == 2 .and. empty(BGQ->BGQ_NUMLOT)
      Loop
   Endif
   If  nFase <> 2 .and. ! empty(BGQ->BGQ_NUMLOT)
      Loop
   Endif

	BBB->(DbSetOrder(1))
	BBB->(msSeek(xFilial("BBB")+BGQ->BGQ_CODLAN))

	If  lLisRes // lAnalitico
   		cValor := TransForm(BGQ->BGQ_VALOR,pMoeda2)
      If  BGQ->BGQ_TIPO == "1"
	      	If  lLisRes
	    	   	cLinha := cTit + Padr(objCENFUNLGP:verCamNPR("BGQ_CODLAN", BGQ->BGQ_CODLAN) + "-" + objCENFUNLGP:verCamNPR("BBB_DESCRI", alltrim(BBB->BBB_DESCRI)),nTamDes,".") + ": " + ;
		                space(len(cValor)) + " " + cValor + " " + ;
	                   If(alltrim(BGQ->BGQ_NUMLAU) <> "BBC",objCENFUNLGP:verCamNPR("BGQ_OBS", substr(BGQ->BGQ_OBS,1,35)),"")
	             R673Linha(cLinha,1,0)
	         Endif
	      Else
	         If  BGQ->BGQ_TIPO == "2"
	        		If  lLisRes
	    	     		cLinha := cTit + Padr(objCENFUNLGP:verCamNPR("BGQ_CODLAN", BGQ->BGQ_CODLAN) + "-" + objCENFUNLGP:verCamNPR("BBB_DESCRI", alltrim(BBB->BBB_DESCRI)),nTamDes,".") + ": " + ;
		           				cValor + " " + space(len(cValor)) + " " + ;
		                      If(alltrim(BGQ->BGQ_NUMLAU) <> "BBC",objCENFUNLGP:verCamNPR("BGQ_OBS", substr(BGQ->BGQ_OBS,1,35)),"")
	                R673Linha(cLinha,1,0)
	             Endif
	          Endif
	      Endif
           cTit := space(30)
   		EndIf
      If  BGQ->BGQ_TIPO == "1"
	       nDebVar += BGQ->BGQ_VALOR
	   Else
           If  BGQ->BGQ_TIPO == "2"
	           nCreVar += BGQ->BGQ_VALOR
	       Endif
	   Endif
       lTem := .T.
Next

If  lLisRes
    cLinha := cTit + Padr("Total Creditos/Debitos variaveis",nTamDes,".") + ": " + ;
              TransForm(nCreVar,pMoeda2) + " " + ;
              TransForm(nDebVar,pMoeda2)
    R673Linha(cLinha,1,0)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lista apontamentos                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  lLisRes
    If  lLisRes // lAnalitico
        cLinha := Replicate(' ',nLimite)
        R673Linha(cLinha,1,0)
    Endif
Endif
cTit := "Apontamentos da Producao:     "
lTem := .F.
BCE->(DbSetOrder(2))
If  BCE->(msSeek(xFilial("BGQ")+cRdaAnt+cCodOpe+cAno+cMes))
    While ! BCE->(Eof()) .And. BCE->(BCE_FILIAL+BCE_CODIGO+BCE_CODINT+BCE_ANOPAG+BCE_MESPAG) == ;
                                xFilial("BGQ")+cRdaAnt+cCodOpe+cAno+cMes

	   If ! Empty(cOpeLot+cNumLot) .And. BCE->(BCE_OPELOT+BCE_NUMLOT) <> cOpeLot+cNumLot
	       BCE->(DbSkip())
	       Loop
	   EndIf

       If  lLisRes // lAnalitico
           BBB->(DbSetOrder(1))
           BBB->(msSeek(xFilial("BBB")+BCE->BCE_CODPAG))
           cValor := TransForm(BCE->BCE_VLRAPT,pMoeda2)
           If  lLisRes
               cLinha := cTit + Padr(objCENFUNLGP:verCamNPR("BCE_CODPAG", BCE->BCE_CODPAG) + "-" + objCENFUNLGP:verCamNPR("BBB_DESCRI", alltrim(BBB->BBB_DESCRI)),nTamDes,".") + ": " + ;
	                     TransForm(BCE->BCE_VLRAPT,pMoeda2)
               R673Linha(cLinha,1,0)
           Endif
           cTit := space(30)
	   EndIf
       nCreApo += BCE->BCE_VLRAPT
       lTem := .T.
       BCE->(DbSkip())
    Enddo
Endif
If  lLisRes
    cLinha := cTit + Padr("Total Apontamentos da Producao",nTamDes,".") + ": " + ;
              TransForm(nCreApo,pMoeda2) + " " + ;
              TransForm(nDebApo,pMoeda2)
    R673Linha(cLinha,1,0)
Endif

If  lSoma
    ntDebFix += nDebFix
    ntCreFix += nCreFix
    ntCreVar += nCreVar
    ntDebVar += nDebVar
    ntCreApo += nCreApo
    ntDebApo += nDebApo
Endif

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R673Res     ³ Autor ³ Angelo Sperandio   ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime resumo dos totais                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function R673Res()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTit
Local i
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lista cabecalho                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLinha := Replicate('-',nLimite)
R673Linha(cLinha,1,0)
cLinha := "Resumo do Pagamento           Descricao                                   Credito         Debito           Base"
R673Linha(cLinha,1,0)
cLinha := "                              ------------------------------------        -------         ------           ----"
R673Linha(cLinha,1,0)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime resumo                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTit := "                              "
If  len(aTabRes) > 0
    For i := 1 to len(aTabRes)
        cLinha := cTit + Padr(aTabRes[i,1],nTamDes,".") + ": " + aTabRes[i,2] + " " + aTabRes[i,3] + " " + aTabRes[i,4] + " " + aTabRes[i,5]
        R673Linha(cLinha,1,0)
        cTit := space(30)
    Next
Endif
cLinha := Replicate('-',nLimite)
R673Linha(cLinha,1,0)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R673Res_Prod³ Autor ³ Angelo Sperandio   ³ Data ³ 28.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime resumo da producao medica                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function R673Res_Prod(aRes)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nX := 0
Local aTitulo := {  "Custo Operacional Pessoa Fisica",;
					"Custo Operacional Pessoa Juridica",;
					"Pre-Pagamento Pessoa Fisica",;
					"Pre-Pagamento Pessoa Juridica",;
					"Intercambio",;
					"Outros",;
					"Glosas" }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lista cabecalho                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLinha := Replicate('-',nLimite)
R673Linha(cLinha,1,0)
nli++
cTit := "Resumo da Producao :          "

nTotal := 0
For nX := 1 TO Len(aRes)
    If  aRes[nX] > 0
        cLinha := cTit + Padr(aTitulo[nX],nTamDes,".") + ": " + Transform(aRes[nX],pMoeda2)
        R673Linha(cLinha,1,0)
        cTit := space(30)
    	If  nX < 7
		    nTotal += aRes[nX]
		EndIf
    EndIf
Next

cLinha := cTit + Padr("Total da Producao       ",nTamDes,".") + ": " + Transform(nTotal,pMoeda2)
R673Linha(cLinha,1,1)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R673Linha ³ Autor ³ Angelo Sperandio     ³ Data ³ 03.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime linha de detalhe                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function R673Linha(cLinha,nAntes,nApos)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declara variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL i, nLin, cLinhaAux := ""
LOCAL nLiRDA := nLi
Local cLinBkp	:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salta linhas antes                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lTemLot := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salta linhas antes                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i := 1 to nAntes
    nli++
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime cabecalho                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nli > nLinPag
    nli := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCaracter)
    nli++

	//Acrescenta "R.D.A - CLASSE - ESPECIALIDADE" a cada nova pagina.
   	If nLiRDA <> 999
   		@ nLi, 0 PSAY "R.D.A.: " + objCENFUNLGP:verCamNPR("BAU_CODIGO", BAU->BAU_CODIGO) + "-" + objCENFUNLGP:verCamNPR("BAU_NOME", alltrim(BAU->BAU_NOME)) + ;
		          "   Classe: " + objCENFUNLGP:verCamNPR("BAU_TIPPRE", alltrim(posicione("BAG",1,xFilial("BAG")+BAU->BAU_TIPPRE,"BAG_DESCRI")))
        nli++
       cLinBkp := iif (!empty(cLinha), cLinha, "") 
   		cLinha := "Especialidade: " + alltrim(cEspecia)
   		nLin := mlcount(cLinha,120)
		For i := 1 to nLin
			cLinhaAux := &("memoline(cLinha,120,i)")
			@ nLi, 0 PSAY cLinhaAux
			nli++
		Next
		cLinha := iif (!empty(cLinBkp), cLinBkp, "")
        @ nLi, 0 PSAY "Lote..: " + cOpeLot + " " + cNumLot + " " +cDesLot
		nli:=nli+1
		@nli,0 PSAY Replicate('-',nLimite)
		nli++
	EndIf

Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime linha de detalhe                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ nLi, 0 pSay cLinha
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salta linhas apos                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i := 1 to nApos
    nli++
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da funcao                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetMesAno      ºAutor ³Paulo Carnelossi  º Data ³ 09/01/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna Mes/Ano                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function	RetMesAno(cAnoMes)
Static aMeses := {"Jan","Fev","Mar","Abr","Mai","Jun",;
					"Jul", "Ago", "Set", "Out", "Nov", "Dez"}
Local cString := ""

If Val(Right(cAnoMes,2)) > 0 .And. Val(Right(cAnoMes,2)) <= 12
    cString := aMeses[Val(Right(cAnoMes,2))]+"/"+Left(cAnoMes,4)
Else
    cString := Right(cAnoMes,2)+"/"+Left(cAnoMes,4)
EndIf

Return(cString)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLS673GL  ºAutor  ³Everton M. Fernandesº Data ³  17/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Imprime as inforações da Glosa                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PLSR673                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function PLS673GL(aGlosas,cJusti,cBdxCodP,nTotGlos,cAcao,cGlosa,cTipGlo,pMoeda1,cLinha)
Local i			:= 0
Local cLinGlo	:= ""
Local cLinDes	:= ""
Local lPrim		:= .F.

R673Linha('',1,0)
cLinha := "Glosa/Bloqueio  Par Motivo Glosa/Bloqueio"
R673Linha(cLinha,1,0)
cLinha := "--------------- --- --------------------------------------------------------------------------------------------------------------"
R673Linha(cLinha,1,0)
nTotGlos := 0

For I := 1 To Len(aGlosas)
	BD7->( DbGoTo(aGlosas[I,1]) )

	If  !Empty(aGlosas[i,7])
		cLinha := allTrim(aGlosas[i,6]) + space(11) + cGlosa + space(3) + aGlosas[i,7]

		if !empty(aGlosas[i,3])
			nTotGlos += aGlosas[i,3]
		endIf
		R673Linha(cLinha,1,0)
	Else
		If BDX->(msSeek(xFilial("BDX")+aGlosas[i,2]))
			lPrim := .T.
			while ! BDX->(eof()) .And. BDX->(BDX_FILIAL+BDX_CODOPE+BDX_CODLDP+BDX_CODPEG+BDX_NUMERO+BDX_ORIMOV+BDX_CODPAD+BDX_CODPRO+BDX_SEQUEN) == xFilial("BDX")+aGlosas[i,2]

				If  BDX->BDX_TIPREG $ " ,1,2"

					cAcao := allTrim( X3COMBO("BDX_ACAO",BDX->BDX_ACAO))

					If (BDX->BDX_ACAO $ '1' .or. aGlosas[i,3] > 0)

						if BDX->(FieldPos("BDX_OBS")) > 0
							cLinGlo := objCENFUNLGP:verCamNPR("BDX_OBS", allTrim(BDX->BDX_OBS))
						endIf
						cLinDes := objCENFUNLGP:verCamNPR("BDX_DESGLO", PadR(BDX->BDX_DESGLO,70))

						nValIt := aGlosas[i,3]

						if allTrim(aGlosas[i,6]) <> "Glosa"
							cLinha  := cAcao + "/" + allTrim(aGlosas[i,6]) + space(6)
						else
							cLinha  := cAcao + space(15-len(cAcao)) + space(1)
						endIf
						cLinha +=  allTrim(aGlosas[i,5]) + space(1) +  objCENFUNLGP:verCamNPR("BDX_CODGLO", allTrim(BDX->BDX_CODGLO)) + '-' + cLinDes

						R673Linha(cLinha,1,0)
						if !empty(cLinGlo)
							R673Linha('Obs: ' + cLinGlo,1,0)
						endIf

						If lPrim
							nTotGlos 	+= nValIt
							lPrim		:= .F.
						EndIf

						if !empty(BDX->BDX_RESPAL)
							cJusti   := 'Justif.: ' + objCENFUNLGP:verCamNPR("BDX_RESPAL", BDX->BDX_RESPAL)
							cBdxCodP := objCENFUNLGP:verCamNPR("BDX_CODPRO", BDX->BDX_CODPRO)

							R673Linha(cJusti,1,0)
							cJusti := ""
						endIf
						cGlosa := space(35)
					endIf
				endif
				BDX->(DbSkip())
			endDo
		Endif
	EndIf
Next I
If !empty(cGlosa)
	R673Linha(cTipGlo + space(6) + cGlosa,1,0)
Endif

cLinha := space(97) + "Total Glosa: " + space(11) + TransForm(nTotGlos,pMoeda1)

R673Linha(cLinha,1,0)
R673Linha(""    ,1,0)
aGlosas := {}

Return