#INCLUDE "plsr025.ch"
#include "protheus.ch"

#define ANTES_LACO 1
#define COND_LACO 2
#define PROC_LACO 3
#define DEPOIS_LACO 4

Static objCENFUNLGP := CENFUNLGP():New()
Static lautoSt := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSR025    บAutor  ณPaulo Carnelossi   บ Data ณ  06/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime relacao de utilizacao de servicos medicos p/ Familiaบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSR025(lAuto)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local wnrel
Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir a relacao de utilizacao"
Local cDesc2 := STR0002 //"de servicos RDAดs por familia"
Local cDesc3 := ""
Local cString := "BD6"

Local aOrd := {}

Default lAuto := .F.

PRIVATE cTitulo:= FunDesc() //"Servi็os Prestador Por Beneficiแrios"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { STR0004, 1,STR0005, 2, 2, 1, "",1 } //"Zebrado"###"Administracao"
Private cPerg   := "PLR025"
Private nomeprog:= "PLSR025"
Private nLastKey:=0
Private Tamanho := "M"
Private nTipo

lautoSt := lAuto

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao dos cabecalhos                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cabec1:= STR0006+"     "+STR0007 //"Codigo do Usuario"###"Nome do Usuario que utilizou o servico"
cabec2:= "     "+STR0008+"               "+STR0009+"  "+STR0010+"          "+STR0011+"                                      "+STR0012 //"Dt.Atend.N.Debito"###"Quant."###"Codigo AMB"###"Procedimento"###"Valor"
//        1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                 1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := "PLSR025"

Pergunte(cPerg,.F.)
M->BF8_CODINT := MV_PAR01 //para utilizar sxb BI5
M->BTC_CODPAD := MV_PAR14 //para utilizar sxb B24

if !lAuto
	wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho,,.F.)
endif

If !lauto .AND. nLastKey == 27
   Return
End

aAlias := {"BD6","BA0","BA1"}
objCENFUNLGP:setAlias(aAlias)

if !lAuto
	SetDefault(aReturn,cString)
endif

If !lauto .AND. nLastKey == 27
   Return ( NIL )
End

if !lauto
	RptStatus({|lEnd| PLSR025Imp(@lEnd,wnRel,cString)},cTitulo)
else
	PLSR025Imp(.F.,wnRel,cString)	
endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Fun…o    ณPLSR025Impณ Autor ณ Paulo Carnelossi      ณ Data ณ 06/01/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descri…o ณRelacao de Utilizacao de Servicos Medicos por Familia       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe   ณPLSR025Imp(lEnd,wnRel,cString)                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PLSR025Imp(lEnd,wnRel,cString)
Local cbcont,cbtxt

LOCAL cSQL
Local cArqTrab  := CriaTrab(nil,.F.)
Local aCondFinal
Local cCodEmp := "", cTitular := "", cAnoMes := "", cUsuario := "", cCodRDA := ""
Local nTotGer := 0, nTotEmp := 0, nTotTit := 0, nTotMes := 0, nTotUsu := 0, nTotRDA := 0
Local nTotAnt := 0
Local lImpr   := (mv_par08+mv_par09 != mv_par10+mv_par11)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

nTipo:=GetMv("MV_COMP")

dbSelectArea("BD6")

cSQL := "SELECT BD6.BD6_OPEUSR, BD6.BD6_BLOCPA, BD6.BD6_CODEMP, BD6.BD6_MATRIC, BD6.BD6_TIPREG,  "
cSQL += "BD6.BD6_DIGITO, BD6.BD6_ANOPAG+BD6.BD6_MESPAG AS BD6_ANOMES, "
cSQL += "BD6.BD6_NOMUSR, BD6.BD6_CODRDA, BD6.BD6_NOMRDA, "
cSQL += "BD6.BD6_DATPRO, BD6.BD6_NUMIMP, BD6.BD6_CODLDP, BD6.BD6_CODPEG, BD6.BD6_NUMERO, BD6.BD6_QTDPRO, "
cSQL += "BD6.BD6_CODPAD, BD6.BD6_CODPRO, BD6.BD6_DESPRO, "
cSQL += "BD6.BD6_VLRPAG, BD6.BD6_VLRTPF FROM "
cSQL += RetSQLName("BD6")+" BD6 "

cSQL += "WHERE "
cSQL += "BD6.BD6_FILIAL  = '"+xFilial("BD6")+"' AND "
cSQL += "BD6.BD6_OPEUSR  = '"+MV_PAR01+"' AND "
cSQL += "BD6.BD6_CODEMP >= '"+MV_PAR02+"' AND "
cSQL += "BD6.BD6_CODEMP <= '"+MV_PAR03+"' AND "
cSQL += "BD6.BD6_CONEMP >= '"+MV_PAR04+"' AND "
cSQL += "BD6.BD6_CONEMP <= '"+MV_PAR05+"' AND "
cSQL += "BD6.BD6_SUBCON >= '"+MV_PAR06+"' AND "
cSQL += "BD6.BD6_SUBCON <= '"+MV_PAR07+"' AND "
cSQL += "BD6.BD6_MATRIC >= '"+MV_PAR08+"' AND "
cSQL += "BD6.BD6_MATRIC <= '"+MV_PAR09+"' AND "
cSQL += "BD6.BD6_TIPREG >= '"+MV_PAR10+"' AND "
cSQL += "BD6.BD6_TIPREG <= '"+MV_PAR11+"' AND "
cSQL += "BD6.BD6_ANOPAG+BD6.BD6_MESPAG >= '"+MV_PAR12+MV_PAR13+"' AND "
cSQL += "BD6.BD6_ANOPAG+BD6.BD6_MESPAG <= '"+MV_PAR14+MV_PAR15+"' AND "
cSQL += "BD6.BD6_DATPRO >= '"+DTOS(MV_PAR16)+"' AND "
cSQL += "BD6.BD6_DATPRO <= '"+DTOS(MV_PAR17)+"' AND "
cSQL += "BD6.BD6_CODPAD >= '"+MV_PAR18+"' AND "
cSQL += "BD6.BD6_CODPAD <= '"+MV_PAR20+"' AND "
cSQL += "BD6.BD6_CODPRO >= '"+MV_PAR19+"' AND "
cSQL += "BD6.BD6_CODPRO <= '"+MV_PAR21+"' AND "
cSQL += "BD6.BD6_CODRDA >= '"+MV_PAR22+"' AND "
cSQL += "BD6.BD6_CODRDA <= '"+MV_PAR23+"' AND "
cSQL += "BD6.BD6_VLRPAG >= "+Str(MV_PAR24,19,2)+" AND "
cSQL += "BD6.BD6_VLRPAG <= "+Str(MV_PAR25,19,2)+" AND "

If mv_par33 == 1
	cSQL += "BD6.BD6_FASE IN ('2','3','4') AND BD6_SITUAC = '1' AND "
ElseIf mv_par33 == 2
	cSQL += "BD6.BD6_FASE = '2' AND BD6_SITUAC = '1' AND "
ElseIf mv_par33 == 3
	cSQL += "BD6.BD6_FASE = '3' AND BD6_SITUAC = '1' AND "
ElseIf mv_par33 == 4
	cSQL += "BD6.BD6_FASE = '4' AND BD6_SITUAC = '1' AND "
ElseIf mv_par33 == 5
	cSQL += "BD6.BD6_FASE IN ('3','4') AND BD6_SITUAC = '1' AND "
EndIf


//--considerar somente registros validos
cSQL += "BD6.D_E_L_E_T_ <> '*' "
cSQL += " ORDER BY "
cSQL += " BD6.BD6_CODEMP, BD6.BD6_MATRIC, BD6.BD6_ANOPAG, BD6.BD6_MESPAG, BD6.BD6_TIPREG, BD6.BD6_DIGITO, BD6.BD6_CODRDA"

PLSQuery(cSQL,cArqTrab)

//monta array contendo blocos de codigos que serao executados
// antes while - cond. while - processamento while - apos while

// Elemento 1 - ANTES_LACO
// Elemento 2 - COND_LACO
// Elemento 3 - PROC_LACO
// Elemento 4 - DEPOIS_LACO
// Elemento 5 - Variavel para comparacao
// Elemento 6 - Contador
// Elemento 7 - Nome do Campo
// Elemento 8 - Titulo do Campo
aCondFinal := {}

//Quebra enquanto nao fim de Arquivo  -----> BD6_CODEMP
aAdd( aCondFinal, ;
		   { ;
		   	{|nNivel|aCondFinal[nNivel][5] := ""}, ;
	   		{|nNivel|!Eof()}, ;
		   	{|nNivel|.T.}, ;
		   	{|nNivel|Impr_TotGer(cArqTrab, nTotGer, aCondFinal[nNivel][8], mv_par31 == 1)}, ;
	   		Nil,;
		   	0, ;
		   	"BD6_CODEMP",;  //pode ser qq campo
		   	STR0013; //"Total Geral "
	   } )

//1a. Quebra por Grupo Empresa  -----> BD6_CODEMP
aAdd( aCondFinal, ;
		   { ;
		   	{|nNivel|aCondFinal[nNivel][5] := FieldGet(FieldPos(aCondFinal[nNivel][7]))}, ;
	   		{|nNivel|FieldGet(FieldPos(aCondFinal[nNivel][7])) == aCondFinal[nNivel][5]}, ;
		   	{|nNivel|Impr_Empresa(cArqTrab, @cCodEmp), nTotEmp += nTotTit }, ;
		   	{|nNivel|Impr_TotEmp(cArqTrab, cCodEmp, @nTotEmp, @nTotGer, aCondFinal[nNivel][8], nTotAnt, mv_par30 == 1)}, ;
	   		Nil,;
		   	0, ;
		   	"BD6_CODEMP",;
		   	STR0014; //"Sub-Total da Empresa"
	   } )

//2a. Quebra por Matricula / Titular -----> BD6_MATRIC
aAdd( aCondFinal, ;
		   { ;
		   	{|nNivel|aCondFinal[nNivel][5] := FieldGet(FieldPos(aCondFinal[nNivel][7]))}, ;
	   		{|nNivel|FieldGet(FieldPos(aCondFinal[nNivel][7])) == aCondFinal[nNivel][5]}, ;
		   	{|nNivel|Impr_Titular(cArqTrab, @cTitular), nTotTit += nTotMes }, ;
		   	{|nNivel|Impr_TotTitular(@nTotTit, @nTotEmp, aCondFinal[nNivel][8], @nTotAnt, mv_par29 == 1) }, ;
	   		Nil,;
		   	0, ;
		   	"BD6_MATRIC",;
		   	STR0015; //"Sub-Total da Familia"
	   } )

//3a. Quebra por Ano/Mes Pag -----> BD6_ANOPAG
aAdd( aCondFinal, ;
		   { ;
		   	{|nNivel|aCondFinal[nNivel][5] := FieldGet(FieldPos(aCondFinal[nNivel][7]))}, ;
	   		{|nNivel|FieldGet(FieldPos(aCondFinal[nNivel][7])) == aCondFinal[nNivel][5]}, ;
		   	{|nNivel|Impr_AnoMes(cArqTrab, aCondFinal[nNivel][5], @cAnoMes, lImpr, .F.), nTotMes += nTotUsu }, ;
		   	{|nNivel|Impr_TotAnoMes(@nTotMes, @nTotTit, aCondFinal[nNivel][8], @nTotAnt, mv_par28 == 1) }, ;
	   		Nil,;
		   	0, ;
		   	"BD6_ANOMES",;
		   	STR0016; //"Sub-Total do Mes/Ano"
	   } )

//4a. Quebra por Tipo Reg -----> BD6_TIPREG
aAdd( aCondFinal, ;
		   { ;
		   	{|nNivel|aCondFinal[nNivel][5] := FieldGet(FieldPos(aCondFinal[nNivel][7]))}, ;
	   		{|nNivel|FieldGet(FieldPos(aCondFinal[nNivel][7])) == aCondFinal[nNivel][5]}, ;
		   	{|nNivel|Impr_Usuario(cArqTrab, @cUsuario), nTotUsu += nTotRDA }, ;
		   	{|nNivel|Impr_TotUsuario(@nTotUsu, @nTotMes, aCondFinal[nNivel][8], @nTotAnt, mv_par27 == 1 ) }, ;
	   		Nil,;
		   	0, ;
		   	"BD6_TIPREG",;
		   	STR0017; //"Sub-Total do Usuario"
	   } )

//5a. Quebra por Codigo da Prestadora Serv (RDA) -----> BD6_CODRDA
aAdd( aCondFinal, ;
		   { ;
		   	{|nNivel|aCondFinal[nNivel][5] := FieldGet(FieldPos(aCondFinal[nNivel][7]))}, ;
	   		{|nNivel|FieldGet(FieldPos(aCondFinal[nNivel][7])) == aCondFinal[nNivel][5]}, ;
		   	{|nNivel|Impr_RDA(cArqTrab, @cCodRDA), Impr_Detalhe(cArqTrab, @nTotRDA)}, ;
		   	{|nNivel|Impr_TotRDA(@nTotRDA, @nTotUsu, aCondFinal[nNivel][8], @nTotAnt, mv_par26 == 1) }, ;
	   		Nil,;
		   	0, ;
		   	"BD6_CODRDA",;
		   	STR0018; //"Sub-Total do Prestador do Servico"
	   } )

dbSelectArea(cArqTrab)
(cArqTrab)->(DbGoTop())

if !lautoSt
	SetRegua(RecCount())
endif

// Impressao do detalhe do relatorio com quebra
DetalheRel(aCondFinal, 1, cArqTrab)

//If li != 80
if !lautoSt
	Roda(cbcont,cbtxt,tamanho)
endif
//EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Recupera a Integridade dos dados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cArqTrab)
dbCloseArea()

dbSelectArea("BD6")

if !lautoSt
	Set Device To Screen
endif

If !lautoSt .AND. aReturn[5] = 1
   Set Printer To
	dbCommitAll()
   OurSpool(wnrel)
Endif

if !lautoSt
	MS_FLUSH()
endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_Detalhe บAutor  ณPaulo Carnelossi บ Data ณ  06/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de detalhe do relatorio                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Impr_Detalhe(cArqTrab, nTotRDA)
LOCAL cBD6vlr := ""

If li > 55
	cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Impr_Operadora(mv_par01, cArqTrab)
EndIf

@ li, 005 PSay 	objCENFUNLGP:verCamNPR("BD6_DATPRO",(cArqTrab)->BD6_DATPRO)
@ li, 014 PSay 	objCENFUNLGP:verCamNPR("BD6_CODLDP",(cArqTrab)->(BD6_CODLDP)+"-"+;
				objCENFUNLGP:verCamNPR("BD6_CODPEG",(cArqTrab)->BD6_CODPEG)+"-"+;
				objCENFUNLGP:verCamNPR("BD6_NUMERO",(cArqTrab)->BD6_NUMERO)) //BD6_NUMIMP

@ li, 036 PSay 	Transform(objCENFUNLGP:verCamNPR("BD6_QTDPRO",(cArqTrab)->BD6_QTDPRO),"@E 9,999.99")

@ li, 046 PSay 	objCENFUNLGP:verCamNPR("BD6_CODPAD",(cArqTrab)->BD6_CODPAD)+"-"+;
				Transform(objCENFUNLGP:verCamNPR("BD6_CODPRO",(cArqTrab)->BD6_CODPRO),PesqPict("BD6","BD6_CODPRO"))
				
@ li, 066 PSay 	SUBSTR(objCENFUNLGP:verCamNPR("BD6_DESPRO",(cArqTrab)->BD6_DESPRO), 1, 45)

If (cArqTrab)->BD6_BLOCPA == "1"
	If mv_par32==1
		@ li, 107 PSay Transform(objCENFUNLGP:verCamNPR("BD6_VLRPAG",(cArqTrab)->BD6_VLRPAG),"@E 999,999,999.99")
		nTotRDA += (cArqTrab)->BD6_VLRPAG
	Else
		@ li, 107 PSay Transform(0,"@E 999,999,999.99")
	EndIf
Else
	IIf(mv_par32==1, cBD6vlr := "BD6_VLRPAG", cBD6vlr := "BD6_VLRTPF")
	@ li, 107 PSay Transform(objCENFUNLGP:verCamNPR(cBD6vlr,(cArqTrab)->&(cBD6vlr)),"@E 999,999,999.99")
	nTotRDA += (cArqTrab)->(If(mv_par32==1,BD6_VLRPAG,BD6_VLRTPF))
EndIf

li++
li++

(cArqTrab)->(DbSkip())

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณImpr_Operadora บAutor ณPaulo Carnelossi  บ Data ณ 06/01/04  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณImprime dados da Operadora a que se refere o relatorio      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function	Impr_Operadora(cCodOpe, cArqTrab)

BA0->(dbSetOrder(1))
If BA0->(MsSeek(xFilial("BA0")+cCodOpe))
	@ li, 000 PSay PadC(Alltrim(objCENFUNLGP:verCamNPR("BA0_NOMINT",BA0->BA0_NOMINT)),132)
	li++
	@ li, 000 PSay 	PadC(Alltrim(objCENFUNLGP:verCamNPR("BA0_END",BA0->BA0_END))+" - CEP "+;
					AllTrim(objCENFUNLGP:verCamNPR("BA0_CEP",BA0->BA0_CEP))+" "+;
					AllTrim(objCENFUNLGP:verCamNPR("BA0_CIDADE",BA0->BA0_CIDADE))+" ("+;
					objCENFUNLGP:verCamNPR("BA0_EST",BA0->BA0_EST)+")",132)
	li++
	@ li, 000 PSay Padc("C.G.C. "+Alltrim(Transform(objCENFUNLGP:verCamNPR("BA0_CGC",BA0->BA0_CGC),PesqPict("BA0","BA0_CGC")))+ ;
	               If(BA0->(FieldPos("BA0_INCEST"))>0, "  "+STR0019+": "+;
				   objCENFUNLGP:verCamNPR("BA0_INCEST",BA0->BA0_INCEST),""); //"Insc.Est."
	               , 132)
	li++
	li++

	If mv_par12+mv_par13 == mv_par14+mv_par15
		Impr_AnoMes(cArqTrab, mv_par12+mv_par13, mv_par14+mv_par15, .T., .T.)
	EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณImpr_Empresa   บAutor ณPaulo Carnelossi  บ Data ณ 06/01/04  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณImprime dados da Empresa que se refere a qb do relatorio    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function	Impr_Empresa(cArqTrab, cCodEmp)

If cCodEmp <> (cArqTrab)->BD6_CODEMP
	If li > 55
		cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		Impr_Operadora(mv_par01, cArqTrab)
	EndIf

	@ li, 005 PSay STR0020+objCENFUNLGP:verCamNPR("BD6_CODEMP",(cArqTrab)->BD6_CODEMP)+" - "+; //"Empresa: "
					Posicione("BG9",1,xFilial("BG9")+objCENFUNLGP:verCamNPR("BD6_OPEUSR",(cArqTrab)->BD6_OPEUSR)+objCENFUNLGP:verCamNPR("BD6_CODEMP",(cArqTrab)->BD6_CODEMP),"BG9_DESCRI")
	li++
	li++
	cCodEmp := (cArqTrab)->BD6_CODEMP
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณImpr_Titular   บAutor ณPaulo Carnelossi  บ Data ณ 06/01/04  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณImprime dados do Titular  que se refere a qb do relatorio   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function	Impr_Titular(cArqTrab, cTitular)
//Local aArea := GetArea()
Local cAlias := Alias()

dbSelectArea("BA1")
dbSetOrder(2)

If dbSeek(xFilial("BA1")+(cArqTrab)->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC))
	If cTitular <> (cArqTrab)->(BD6_CODEMP+BD6_MATRIC)
		If li > 45
			cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			Impr_Operadora(mv_par01, cArqTrab)
		EndIf

		@ li, 010 PSay STR0021 +	/*objCENFUNLGP:verCamNPR("MV_PAR01",BA1->*/MV_PAR01+"."+;
									objCENFUNLGP:verCamNPR("BA1_CODEMP",BA1->BA1_CODEMP)+"."+;
									objCENFUNLGP:verCamNPR("BA1_MATRIC",BA1->BA1_MATRIC)+"."+;
									objCENFUNLGP:verCamNPR("BA1_TIPREG",BA1->BA1_TIPREG)+"."+;
									objCENFUNLGP:verCamNPR("BA1_DIGITO",BA1->BA1_DIGITO)+" "+; //"Titular da Familia: "
		               				objCENFUNLGP:verCamNPR("BA1_NOMUSR",BA1->BA1_NOMUSR)
		li++
		li++
		cTitular := (cArqTrab)->(BD6_CODEMP+BD6_MATRIC)
	EndIf
EndIf

//RestArea(aArea)
dbSelectArea(cAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณImpr_AnoMes    บAutor ณPaulo Carnelossi  บ Data ณ 06/01/04  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณImprime Ano/Mes de Pagto a que se refere a qb do relatorio  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function	Impr_AnoMes(cArqTrab, cAnoMesAux, cAnoMes, lImpr, lCentr)
Static aMeses := {STR0022,STR0023,STR0024,STR0025,STR0026,STR0027,; //"Jan"###"Fev"###"Mar"###"Abr"###"Mai"###"Jun"
					STR0028, STR0029, STR0030, STR0031, STR0032, STR0033} //"Jul"###"Ago"###"Set"###"Out"###"Nov"###"Dez"
Local cString := ""

If lImpr .And. cAnoMes <> (cArqTrab)->(BD6_CODEMP+BD6_MATRIC+BD6_ANOMES)
	If li > 48
		cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		Impr_Operadora(mv_par01, cArqTrab)
	EndIf

	If Val(Right(cAnoMesAux,2)) > 0 .And. Val(Right(cAnoMesAux,2)) <= 12
	    cString := "*** "+STR0034+" --> " + aMeses[Val(Right(cAnoMesAux,2))]+"/"+Left(cAnoMesAux,4)+" ***" //"Mes"
	Else
	    cString := "*** "+STR0034+" --> " + Right(cAnoMesAux,2)+"/"+Left(cAnoMesAux,4)+" ***" //"Mes"
	EndIf

	If lCentr
		@ li, 000 PSay PadC(cString, 132)
	Else
		@ li, 015 PSay cString
	EndIf

	li++
	li++
	cAnoMes := (cArqTrab)->(BD6_CODEMP+BD6_MATRIC+BD6_ANOMES)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณImpr_Usuario   บAutor ณPaulo Carnelossi  บ Data ณ 06/01/04  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณImprime Matricula e Nome do Usuario a que se refere a quebraบฑฑ
ฑฑบ          ณdo relatorio                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function	Impr_Usuario(cArqTrab, cUsuario)

If cUsuario <> (cArqTrab)->(BD6_CODEMP+BD6_MATRIC+BD6_ANOMES+BD6_MATRIC+BD6_TIPREG)
	If li > 51
		cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		Impr_Operadora(mv_par01, cArqTrab)
	EndIf

	@ li, 000 PSay 	/*objCENFUNLGP:verCamNPR("MV_PAR01",(cArqTrab)->*/MV_PAR01+"."+;
					objCENFUNLGP:verCamNPR("BD6_CODEMP",(cArqTrab)->BD6_CODEMP)+"."+;
					objCENFUNLGP:verCamNPR("BD6_MATRIC",(cArqTrab)->BD6_MATRIC)+"."+;
					objCENFUNLGP:verCamNPR("BD6_TIPREG",(cArqTrab)->BD6_TIPREG)+"."+;
					objCENFUNLGP:verCamNPR("BD6_DIGITO",(cArqTrab)->BD6_DIGITO)

	@ li, 022 PSay 	objCENFUNLGP:verCamNPR("BD6_NOMUSR",(cArqTrab)->BD6_NOMUSR)
	li++
	cUsuario := (cArqTrab)->(BD6_CODEMP+BD6_MATRIC+BD6_ANOMES+BD6_MATRIC+BD6_TIPREG)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณImpr_RDA       บAutor ณPaulo Carnelossi  บ Data ณ 06/01/04  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณImprime Codigo e Nome do Prestador do Servico (RDA) a que seบฑฑ
ฑฑบ          ณ refere a quebra do relatorio                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function	Impr_RDA(cArqTrab, cCodRDA)

If cCodRDA <> (cArqTrab)->(BD6_CODEMP+BD6_MATRIC+BD6_ANOMES+BD6_MATRIC+BD6_TIPREG+BD6_CODRDA)
	If li > 53
		cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		Impr_Operadora(mv_par01, cArqTrab)
	EndIf

	@ li, 022 PSay STR0035+	objCENFUNLGP:verCamNPR("BD6_CODRDA",(cArqTrab)->BD6_CODRDA)+" - "+;
							objCENFUNLGP:verCamNPR("BD6_NOMRDA",(cArqTrab)->BD6_NOMRDA) //"Prestador do Servico: "
	li++
	cCodRDA := (cArqTrab)->(BD6_CODEMP+BD6_MATRIC+BD6_ANOMES+BD6_MATRIC+BD6_TIPREG+BD6_CODRDA)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_TotGer    บAutor ณPaulo Carnelossi บ Data ณ 06/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณImprime total geral por empresa                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Impr_TotGer(cArqTrab, nTotGer, cTexto, lImpSubTot)

If lImpSubTot

	cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Impr_Operadora(mv_par01, cArqTrab)

	@ li, 000 Psay Repl("=", 132)
	li++
	li++
	@ li, 000 PSay "*** "+STR0036+" ***" //"TOTAL GERAL DA OPERADORA"
    li++

	Impr_SubTot(000,cTexto, .F., "-", .T., .T., nTotGer)

	li := 80  // para forcar quebra de pagina por empresa

EndIf

Return NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_TotEmp    บAutor ณPaulo Carnelossi บ Data ณ 06/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha separadora por empresa                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Impr_TotEmp(cArqTrab, cCodEmp, nTotEmp, nTotGer, cTexto, nTotAnt, lImpSubTot)

If lImpSubTot

	cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	Impr_Operadora(mv_par01, cArqTrab)

	@ li, 000 Psay Repl("=", 132)
	li++
	li++
	@ li, 000 PSay "*** "+STR0037+" ***" //"TOTAL POR EMPRESA"
    li++
	@ li, 005 PSay STR0020+cCodEmp+" - "+; //"Empresa: "
					Posicione("BG9",1,xFilial("BG9")+mv_par01+cCodEmp,"BG9_DESCRI")
	li++
	li++

	Impr_SubTot(000,cTexto, .F., "-", .T., .T., nTotEmp)

	li := 80  // para forcar quebra de pagina por empresa

EndIf

nTotGer += nTotEmp
nTotAnt := nTotEmp
nTotEmp := 0

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_TotTitularบAutor ณPaulo Carnelossi บ Data ณ 06/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณImprime Total por Titular do Servico utilizado              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Impr_TotTitular(nTotTit, nTotEmp, cTexto, nTotAnt, lImprSubTot)

If lImprSubTot //nTotTit <> nTotAnt
	Impr_SubTot(000,cTexto, .F., "-", .T., .T., nTotTit)
	li := 80 // forcar quebra de pagina a cada titular
Else
    @ li, 000 PSay Replicate("-", 132)
    li++
EndIf

nTotEmp += nTotTit
nTotAnt := nTotTit
nTotTit := 0

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_TotAnoMesบAutor ณPaulo Carnelossi บ Data ณ  06/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime Total por Ano/Mes                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Impr_TotAnoMes(nTotMes, nTotTit, cTexto, nTotAnt, lImprSubTot)

If lImprSubTot .And. nTotMes <> nTotAnt
	Impr_SubTot(015,cTexto, .F., "-", .T., .F., nTotMes)
EndIf

nTotTit += nTotMes
nTotAnt := nTotMes
nTotMes := 0

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_TotUsuarioบAutorณPaulo Carnelossi บ Data ณ  06/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime Total por USuario q utilizou o servico              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Impr_TotUsuario(nTotUsu, nTotMes, cTexto, nTotAnt, lImprSubTot)

If lImprSubTot .And. nTotUsu <> nTotAnt
	Impr_SubTot(022,cTexto, .F., "-", .T., .F., nTotUsu)
EndIf

nTotMes += nTotUsu
nTotAnt := nTotUsu
nTotUsu := 0

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_TotRda  บAutor  ณPaulo Carnelossi บ Data ณ  06/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime Total por Prest.Servico RDA                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Impr_TotRda(nTotRDA, nTotUsu, cTexto, nTotAnt, lImprSubTot)

If lImprSubTot
	Impr_SubTot(022,cTexto, .F., "-", .T., .F., nTotRDA)
EndIf

nTotUsu += nTotRDA
nTotAnt := nTotRDA
nTotRDA := 0

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDetalheRel บAutor ณPaulo Carnelossi    บ Data ณ  23/09/03   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime detalhe do relatorio quando existir agrupamentos    บฑฑ
ฑฑบ          ณde acordo com aCondFinal (array contendo blocos de codigos) บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function DetalheRel(aCondFinal, nNivel, cArqTrab)

AEVAL(aCondFinal,;
				{|cX, nX| (cArqTrab)->(Eval(aCondFinal[nX][ANTES_LACO],nX)) } ,  1,  nNivel)

//zerar contador
aCondFinal[nNivel][6] := 0

While (cArqTrab)->( ! Eof() .And. AvaliaCondicao(aCondFinal, nNivel, cArqTrab) )

      //If nNivel == Len(aCondFinal)     // somente no ultimo nivel imprime linha detalhe
			(cArqTrab)->(Eval(aCondFinal[nNivel][PROC_LACO], nNivel))
	  //EndIf

		If nNivel < Len(aCondFinal)  // avanca para proximo nivel
			DetalheRel(aCondFinal, nNivel+1, cArqTrab)
		EndIf

End

//If	nNivel == Len(aCondFinal) .Or. ;
//	(nNivel < Len(aCondFinal ) .And. aCondFinal[nNivel][6] <> aCondFinal[nNivel+1][6])
	(cArqTrab)->(Eval(aCondFinal[nNivel][DEPOIS_LACO],nNivel))
//EndIf

If nNivel > 1
	aCondFinal[nNivel-1][6] += aCondFinal[nNivel][6]
EndIf

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณAvaliaCondicaoบAutor ณPaulo Carnelossi    บ Data ณ 23/09/03 บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDesc.     ณavalia condicao while (auxiliar a funcao DetalheRel()       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AvaliaCondicao(aCondFinal, nNivel, cArqTrab)
Local aAux := {}, lCond := .T., lRet := .T., nY
AEVAL(aCondFinal,;
				{|cX, nX| aAdd(aAux,lCond:=(cArqTrab)->(Eval(aCondFinal[nX][COND_LACO], nX))) } ,  1,  nNivel)

For nY := 1 TO Len(aAux)
    If ! aAux[nY]
    	 lRet := .F.
    	 Exit
    EndIf
Next

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_SubTot บAutor ณPaulo Carnelossi   บ Data ณ  23/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de sub-total/total geral                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Impr_SubTot(nCol,cTexto,lAlinDir, cSinal, lImprTot, lImprLinSep, nQuant)

nCol := If(nCol == NIL, 000, nCol)
lAlinDir := If(lAlinDir == NIL, .T., lAlinDir)
cTexto := If(cTexto == NIL, STR0038, cTexto) //"Total"
cSinal := If(cSinal == NIL, "-", cSinal)
lImprTot := If(lImprTot == NIL, .T., lImprTot)

If lImprTot
	li++
	If lAlinDir
		@ li, nCol Psay PadR(cTexto+"................: "+Transform(nQuant,"@E 999,999,999.99"),120-nCol)
	Else
		@ li, nCol Psay PadL(cTexto+"................: "+Transform(nQuant,"@E 999,999,999.99"),120-nCol)
	EndIf
	li++
EndIf

If lImprLinSep
	@ li, nCol Psay Repl(cSinal,120-nCol)
	li++
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPL025FILXBบAutor  ณMicrosiga           บ Data ณ  30/10/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Filtra o SXB BAGPLS                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ PLSR025                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PL025FILXB(cAlias)
Local lRet := .T.

If cAlias == "BA1" .and. Empty(MV_PAR04) .And. Empty(MV_PAR05)
	lRet := BA1->BA1_FILIAL == xFilial("BA1") .and. ;
		BA1->BA1_CODINT == MV_PAR01 .AND. BA1->BA1_CODEMP >= MV_PAR02 .AND. BA1->BA1_CODEMP <= MV_PAR03
Else
	lRet := BA1->BA1_FILIAL == xFilial("BA1") .and. ;
	 BA1->BA1_CODINT == MV_PAR01 .AND. BA1->BA1_CODEMP >= MV_PAR02 .AND. BA1->BA1_CODEMP <= MV_PAR03 .AND. ;
	 BA1->BA1_CONEMP >= MV_PAR04 .AND. BA1->BA1_CONEMP <= MV_PAR05 .AND. BA1->BA1_SUBCON >= MV_PAR06 .AND. BA1->BA1_SUBCON <= MV_PAR07
Endif



Return lRet
