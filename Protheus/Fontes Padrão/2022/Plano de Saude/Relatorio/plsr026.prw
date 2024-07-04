#include "PLSMGER.CH"
#include "PLSMLIB.CH"

#IFDEF TOP
       #include "TOPCONN.CH"
#ENDIF       

#include "PROTHEUS.CH"
#include "COLORS.CH"

#define ANTES_LACO 	1
#define COND_LACO 		2
#define PROC_LACO 		3
#define DEPOIS_LACO 	4

#Define C_ALIAS 		1 //X3_ALIAS
#Define C_CAMPO 		2 //X3_CAMPO
#Define C_TIPO 		3 //X3_TIPO
#Define C_TAMANHO 		4 //X3_TAMANHO
#Define C_SUB 			5 //lSub
#Define C_TITLE 		6 //X3Title()
#Define C_PICTURE 		7 //X3_PICTURE
#Define C_CAB 			8 //lCab
#Define C_CBOX 		9 //CBOX

Static objCENFUNLGP := CENFUNLGP():New()
static lautoSt := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSR026    บAutor  ณPaulo Carnelossi   บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime relacao de PEGs                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSR026(lauto)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local wnrel
Local cDesc1 := "Este programa tem como objetivo imprimir a relacao de PEGs"
Local cDesc2 := ""
Local cDesc3 := ""
Local cString := "BCI"

Local aOrd := {}

PRIVATE cTitulo:= "Relatorio de PEGs"
PRIVATE cabec1
PRIVATE cabec2
Private aReturn := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private cPerg   := "PLR026"
Private nomeprog:= "PLSR026" 
Private nLastKey:=0
Private Tamanho := "G"
Private nTipo

Default lauto := .F.

lautoSt := lAuto

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Envia controle para a funcao SETPRINT                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
wnrel := "PLR026"

Pergunte(cPerg,.F.)
M->BF8_CODINT := MV_PAR01 //para utilizar sxb BI5
M->BTC_CODPAD := MV_PAR14 //para utilizar sxb B24

If !lauto
	wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho,,.F.)
endIf

If !lauto .AND. nLastKey == 27
   Return
End

If !lauto
	SetDefault(aReturn,cString)
endIf

If !lauto .AND. nLastKey == 27
   Return ( NIL )
End

aAlias :=  {"BDX", "BE4", "BD5", "BD6", "BCI", "BD7", "BCL"}
objCENFUNLGP:setAlias(aAlias)

If !lauto
	RptStatus({|lEnd| PLSR026Imp(@lEnd,wnRel,cString)},cTitulo)
else
	lEnd := .F.
	PLSR026Imp(@lEnd,wnRel,cString,lauto)
endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณ Fun…o    ณPLSR026Impณ Autor ณ Paulo Carnelossi      ณ Data ณ 09/01/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Descri…o ณRelacao de Utilizacao de Servicos Medicos por Familia       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Sintaxe   ณPLSR026Imp(lEnd,wnRel,cString)                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso       ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function PLSR026Imp(lEnd,wnRel,cString,lauto)
Local cbcont,cbtxt

LOCAL cSQL
Local cArqTrab  := CriaTrab(nil,.F.)
Local aCondFinal
Local aCpos, aAuxCab, nZ
Local aAuxSub, aTotGer, aTotLoc, aTotPEG, aTotGuia
Local cCabBCI1, cCabBCI2, cCabBDX1, cCabBDX2

Local cCodLDP := "", cCodPEG := ""

Local aExcCpo := {"BCI_DESGUI"}
Local aCabec  := {}
Local aExcTam

Default lauto := .F.

If MV_PAR20 = 1
	aExcTam := {	{"BE4_NOMUSR", 25},	{"BD5_NOMUSR", 30},	{"BDX_DESGLO", 80},	{"BDX_INFGLO", 50},; 
					{"BE4_DESCID", 25},	{"BE4_DESADM", 20},	{"BE4_NOMSOL", 20},	{"BD6_DESPRO", 29} }
Else
	aExcTam := {	{"BE4_NOMUSR", 25},	{"BD5_NOMUSR", 30},	{"BDX_DESGLO", 80},	{"BDX_INFGLO", 50},; 
					{"BE4_DESCID", 25},	{"BE4_DESADM", 20},	{"BE4_NOMSOL", 20} }
Endif


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

nTipo:=GetMv("MV_COMP")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao dos cabecalhos                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCpos  := Cpos_PLSR026()

aAuxCab := Linha_Cabec("BD6,BD7", aCpos, aExcTam)  
cabec1 := Space(15)+aAuxCab[1] + IIF(MV_PAR20=1,"Blq","")
cabec2 := Space(15)+aAuxCab[2] + IIF(MV_PAR20=1,"Pro","")
aAdd(aCabec, {"BD6", cabec1, cabec2})

aAuxCab  := Linha_Cabec("BCI", aCpos, aExcTam)  
cCabBCI1 := aAuxCab[1]
cCabBCI2 := aAuxCab[2]
aAdd(aCabec, {"BCI", cCabBCI1, cCabBCI2})

aAuxCab  := Linha_Cabec("BDX", aCpos, aExcTam)  
cCabBDX1 := aAuxCab[1]
cCabBDX2 := aAuxCab[2]
aAdd(aCabec, {"BDX", cCabBDX1, cCabBDX2})

aAuxCab  := Linha_Cabec("BE4", aCpos, aExcTam)  
cCabBE41 := aAuxCab[1]
cCabBE42 := aAuxCab[2]
aAdd(aCabec, {"BE4", cCabBE41, cCabBE42})

aAuxCab  := Linha_Cabec("BD5", aCpos, aExcTam)  
cCabBD51 := aAuxCab[1]
cCabBD52 := aAuxCab[2]
aAdd(aCabec, {"BD5", cCabBD51, cCabBD52})
 
aAuxSub := Cpos_SubTot(aCpos)

aTotGer 	:= Array(Len(aAuxSub))
aTotLoc     := Array(Len(aAuxSub))
aTotPEG		:= Array(Len(aAuxSub))
aTotGuia	:= Array(Len(aAuxSub))
AFILL(aTotGer, 0)
AFILL(aTotLoc, 0)
AFILL(aTotPeg, 0)
AFILL(aTotGuia, 0)

dbSelectArea("BDX")
dbSelectArea("BE4")
dbSelectArea("BD5")
dbSelectArea("BD6")
dbSelectArea("BCI")

cSQL := "SELECT "

cSQL += Lista_Cpos("BCI", aCpos, aExcCpo)

cSQL += ", BCL.BCL_DESCRI AS BCI_DESGUI, BCL.BCL_ALIAS AS BCI_ALIAS "

cSQL += " FROM "+RetSQLName("BCI")+" BCI , "
cSQL += RetSQLName("BCL")+" BCL "

cSQL += "WHERE "
cSQL += "BCI.BCI_FILIAL  = '"+xFilial("BCI")+"' AND "
cSQL += "BCI.BCI_CODOPE  = '"+MV_PAR01+"' AND " 
cSQL += "BCI.BCI_CODLDP >= '"+MV_PAR02+"' AND " 
cSQL += "BCI.BCI_CODLDP <= '"+MV_PAR03+"' AND " 
cSQL += "BCI.BCI_CODPEG >= '"+MV_PAR04+"' AND " 
cSQL += "BCI.BCI_CODPEG <= '"+MV_PAR05+"' AND " 
cSQL += "BCI.BCI_ANO+BCI.BCI_MES >= '"+MV_PAR06+MV_PAR07+"' AND " 
cSQL += "BCI.BCI_ANO+BCI.BCI_MES <= '"+MV_PAR08+MV_PAR09+"' AND " 
cSQL += "BCI.BCI_CODRDA >= '"+MV_PAR10+"' AND " 
cSQL += "BCI.BCI_CODRDA <= '"+MV_PAR11+"' AND " 
cSQL += "BCI.BCI_TIPGUI >= '"+MV_PAR12+"' AND " 
cSQL += "BCI.BCI_TIPGUI <= '"+MV_PAR13+"' AND " 

 /*
 //-- Bloqueado pois tornou-se desnecessario, devido as demais alteracoes.

If MV_PAR14 < 5
	//1=Digitacao;2=Conferencia;3=Pronta;4=Faturada  X3_CBOX
	cSQL += "BCI.BCI_FASE = '"+Str(MV_PAR14,1,0)+"' AND " 
EndIf

If MV_PAR15 < 3 //1=Ativo;2=Bloqueado;3=Todos
	iF MV_PAR15 == 1
	//1=Ativo;2=Cancelado;3=Bloqueado   X3_CBOX
		cSQL += "BCI.BCI_SITUAC = '1' AND " 
	Else
		cSQL += "BCI.BCI_SITUAC = '3' AND " //BLOQUEADOS
	EndIf	
Else
	cSQL += "BCI.BCI_SITUAC <> '2' AND " //TODOS --> ATIVOS E BLOQUEADOS
EndIf

 */
//--considerar somente registros validos
cSQL += "BCI.D_E_L_E_T_ <> '*' AND "

//--ligar com BCL e considerar somente registros validos
cSQL += "BCL.BCL_FILIAL  = '"+xFilial("BCL")+"' AND "
cSQL += "BCL.BCL_CODOPE  = '"+MV_PAR01+"' AND " 
cSQL += "BCL.BCL_TIPGUI = BCI.BCI_TIPGUI AND "
cSQL += "BCL.D_E_L_E_T_ <> '*' "

cSQL += " ORDER BY "
cSQL += " BCI_CODLDP, BCI_CODPEG, BCI_FASE, BCI_SITUAC"

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

//Quebra enquanto nao fim de Arquivo  -----> BCI_CODOPE
aAdd( aCondFinal, ;
		   { ;
		   	{|nNivel|aCondFinal[nNivel][5] := ""}, ;
	   		{|nNivel|!Eof()}, ;
		   	{|nNivel|.T.}, ;
		   	{|nNivel|Impr_TotGer(cArqTrab, aTotGer, aCondFinal[nNivel][8], mv_par17 == 1, aCpos)}, ;
	   		Nil,;
		   	0, ;
		   	"BCI_CODOPE",;  //pode ser qq campo
		   	"Total Geral ";
	   } )

//1a. Quebra por Grupo Local de Digitacao -----> BCI_CODLDP
aAdd( aCondFinal, ;
		   { ;
		   	{|nNivel|aCondFinal[nNivel][5] := FieldGet(FieldPos(aCondFinal[nNivel][7]))}, ;
	   		{|nNivel|FieldGet(FieldPos(aCondFinal[nNivel][7])) == aCondFinal[nNivel][5]}, ;
		   	{|nNivel|Impr_LocDig(cArqTrab, @cCodLdp) }, ;
		   	{|nNivel|Impr_TotLoc(aTotLoc, aTotGer, aCondFinal[nNivel][8], .F., aCpos)}, ;
	   		Nil,;
		   	0, ;
		   	"BCI_CODLDP",;
		   	"Sub-Total do Local de Digitacao";
	   } )

//2a. Quebra por Codigo da PEG -----> BCI_CODPEG
aAdd( aCondFinal, ;
		   { ;
		   	{|nNivel|aCondFinal[nNivel][5] := FieldGet(FieldPos(aCondFinal[nNivel][7]))}, ;
	   		{|nNivel|FieldGet(FieldPos(aCondFinal[nNivel][7])) == aCondFinal[nNivel][5]}, ;
		   	{|nNivel|Impr_PEG(cArqTrab, @cCodPEG), Impr_Detalhe(cArqTrab, aTotPEG, aTotGuia, aCabec, aCpos)}, ;
		   	{|nNivel|Impr_TotPEG(aTotPEG, aTotLoc, Trim(aCondFinal[nNivel][8]+" ("+Transform(cCodPeg,"@R 9999-99999999")+")"), mv_par16 == 1, aCpos) }, ;
	   		Nil,;
		   	0, ;
		   	"BCI_CODPEG",;
		   	"Sub-Total da PEG";
	   } )

dbSelectArea(cArqTrab)
(cArqTrab)->(DbGoTop())

If !lAuto
	SetRegua(RecCount())
EndIf

// Impressao do detalhe do relatorio com quebra
DetalheRel(aCondFinal, 1, cArqTrab)

//If li != 80
If !lAuto
	Roda(cbcont,cbtxt,tamanho)
endIf
//EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Recupera a Integridade dos dados                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea(cArqTrab)
dbCloseArea()

dbSelectArea("BCI")

If !lauto
	Set Device To Screen

	If aReturn[5] = 1
	Set Printer To
		dbCommitAll()
	OurSpool(wnrel)
	Endif

	MS_FLUSH()
endIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_LocDig  บAutor  ณPaulo Carnelossi บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de titulo do relatorio                        บฑฑ
ฑฑบ          ณ Nivel ----> CODLDP                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Impr_LocDig(cArqTrab, cCodLdp)

/*  //COMENTADO POIS DESNECESSARIO IMPRESSAO DO TITULO NESTE NIVEL
If li > 55
	cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
EndIf

@ li, 000 PSay "Local de Digitacao: "+(cArqTrab)->BCI_CODLDP
li++
li++
*/	

cCodLdp := (cArqTrab)->BCI_CODLDP

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_TotLoc  บAutor  ณPaulo Carnelossi บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de sub-total do relatorio                     บฑฑ
ฑฑบ          ณ Nivel ----> CODLDP                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Impr_TotLoc(aTotLoc, aTotGer, cTexto, lImpSubTot, aCpos)
Static aPict := {}

If Empty(aPict)
	aPict := Pict_SubTot(aCpos)
EndIf	

If lImpSubTot
    
	If li > 55
		cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
    EndIf
    //COMENTADO POIS FOI DESNECESSARIO IMPRESSAO DE SUB-TOTAL NESTE NIVEL
	//Impr_SubTot(053,cTexto, .T., "-", .T., .T., aTotLoc, aPict)

EndIf	

Total_NivelAcima(aTotGer, aTotLoc)
//zera aTotLoc
AEVAL(aTotLoc,{|nValue, nIndex | aTotLoc[nIndex] := 0 })

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_PEG     บAutor  ณPaulo Carnelossi บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de titulo do relatorio                   	  บฑฑ
ฑฑบ          ณ Nivel ----> PEG                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Impr_PEG(cArqTrab, cCodPeg)
local cBciLdp := ""
local cBciPeg := ""

/*  //comentado pois foi impresso na linha de detalhe
If li > 55
	cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
EndIf

@ li, 005 PSay "PEG No.: "+(cArqTrab)->(BCI_CODLDP+"-"+BCI_CODPEG)
li++
li++
*/

cBciLdp := objCENFUNLGP:verCamNPR("BCI_CODLDP", (cArqTrab)->BCI_CODLDP)
cBciPeg := objCENFUNLGP:verCamNPR("BCI_CODPEG", (cArqTrab)->BCI_CODPEG)

cCodPeg := cBciLdp+cBciPeg

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_TotPEG  บAutor  ณPaulo Carnelossi บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de sub-total do relatorio                     บฑฑ
ฑฑบ          ณ Nivel ----> PEG                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Impr_TotPEG(aTotPEG, aTotLoc, cTexto, lImpSubTot, aCpos)
Local nCt1 := 1
Local nCt2 := 5
Local nTot := 0
Static aPict := {}

If Empty(aPict)
	aPict := Pict_SubTot(aCpos)
EndIf	

If lImpSubTot
    
	For nCt1 := 1 to nCt2
		nTot += aTotPeg[(len(aTotPeg)-nCt1+1)]
	Next

	If nTot > 0
	
		If li > 55
			cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	    EndIf
	    
		If MV_PAR20 = 1
			Impr_SubTot(032,cTexto, .T., "-", .T., .T., aTotPeg, aPict)
		Else
			Impr_SubTot(053,cTexto, .T., "-", .T., .T., aTotPeg, aPict)
		Endif
		li++
	
	Endif

EndIf	

Total_NivelAcima(aTotLoc, aTotPeg)
//zera aTotPeg
AEVAL(aTotPeg,{|nValue, nIndex | aTotPeg[nIndex] := 0 })

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_Detalhe บAutor  ณPaulo Carnelossi บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de detalhe do relatorio                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Impr_Detalhe(cArqTrab, aTotPEG, aTotGuia, aCabec, aCpos)
Local nCol := 000, nX
Local cAlias := ALIAS()
Local cCabBCI1, cCabBCI2, lCabec
Local cCodGuia := ""
Local cSql := ""
Local lImpr := .T.

For nX := 1 TO Len(aCabec)
	If aCabec[nX][1] == "BCI"
		cCabBCI1 := aCabec[nX][2]
		cCabBCI2 := aCabec[nX][3]
        Exit
  	EndIf
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Valida Impressao da PEG...									 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lImpr := .T.

If MV_PAR20 = 1
	If MV_PAR22 <> 3

		cSQL := " SELECT COUNT(*) QTD FROM " + RetSQLName("BD7")
		cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND "
		cSQL +=       " BD7_CODOPE = '" + (cArqTrab)->BCI_CODOPE + "' AND "
		cSQL +=       " BD7_CODLDP = '" + (cArqTrab)->BCI_CODLDP + "' AND "
		cSQL +=       " BD7_CODPEG = '" + (cArqTrab)->BCI_CODPEG + "' AND "
		cSQL +=       " BD7_CODEMP >= '" + mv_par18 + "' AND "
		cSQL +=       " BD7_CODEMP <= '" + mv_par19 + "' AND "
		Do Case
			Case mv_par22 = 4
				cSql += " BD7_BLOPAG <> '1' AND "
			Case mv_par22 = 1
				cSql += " BD7_BLQAUG NOT IN ('1','2') AND "
			Case mv_par22 = 2
				cSql += " (BD7_BLQAUG IN ('1','2') OR BD7_BLOPAG <> '1') AND "
		EndCase

		If MV_PAR14 < 5
			cSQL += "BD7_FASE = '"+Str(MV_PAR14,1,0)+"' AND " 
		EndIf
		
		If MV_PAR15 < 3
			If MV_PAR15 == 1
				cSQL += "BD7_SITUAC = '1' AND " 
			Else
				cSQL += "BD7_SITUAC = '3' AND "
			EndIf	
		EndIf
		
		cSQL += " D_E_L_E_T_ <> '*' "

		PLSQUERY(cSQL,"TrbTmp")
		
		If TrbTmp->(QTD) = 0
			lImpr := .F.
		Endif
		
		TrbTmp->(DbCloseArea())
		
	Endif
Endif

If lImpr

	If li > 55
		cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	EndIf
	
	@ li, nCol PSay cCabBCI1
	li++
	If ! Empty(cCabBCI2)
		@ li, nCol PSay cCabBCI2
		li++
	EndIf
	@ li, nCol PSay Replicate("-", 220-nCol)
	li++
	
	Impr_Linha("BCI", aCpos, nCol, cArqTrab, , .F.)
	
	If (cArqTrab)->BCI_ALIAS == "BD5"
	    dbSelectArea("BD5")
	    If dbSeek((cArqTrab)->(xFilial("BD5")+BCI_CODOPE + BCI_CODLDP + BCI_CODPEG))
	    	lCabec := .T.
	    	While BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG == ;
			    (cArqTrab)->(xFilial("BD5")+BCI_CODOPE + BCI_CODLDP + BCI_CODPEG)
			    
			    If BD5->BD5_CODEMP >= mv_par18 .And. BD5->BD5_CODEMP <= mv_par19

					If MV_PAR14 < 5 .And. BD5->BD5_FASE <> Str(MV_PAR14,1,0) 
						DbSelectArea("BD5")
						DbSkip()
						Loop
					EndIf

					If MV_PAR15 < 3 //1=Ativo;2=Bloqueado;3=Todos
						iF MV_PAR15 == 1 .And. BD5->BD5_SITUAC <>'1'
							DbSelectArea("BD5")
							DbSkip()
							Loop							
						Elseif MV_PAR15==2 .And. BD5->BD5_SITUAC <>'3'
							DbSelectArea("BD5")
							DbSkip()
							Loop				
											
						Endif  
					Endif						
						//1=Ativo;2=Cancelado;3=Bloqueado   X3_CBOX
					
	   		       
	   		       BD5_DESCID := Posicione("BA9",1,xFilial("BA9")+BD5->BD5_CID,"BA9_DOENCA")
	    		   
				   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				   //ณ Valida Impressao do Cabecalho da Nota...	  				    ณ
	   			   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				   lImpr := .T.
					
				   If MV_PAR20 = 1
					
						cSQL := " SELECT COUNT(*) QTD FROM " + RetSQLName("BD7")
						cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND "
						cSQL +=       " BD7_CODOPE = '" + BD5->BD5_CODOPE + "' AND "
						cSQL +=       " BD7_CODLDP = '" + BD5->BD5_CODLDP + "' AND "
						cSQL +=       " BD7_CODPEG = '" + BD5->BD5_CODPEG + "' AND "
						cSQL +=       " BD7_NUMERO = '" + BD5->BD5_NUMERO + "' AND "
						cSQL +=       " BD7_CODEMP >= '" + mv_par18 + "' AND "
						cSQL +=       " BD7_CODEMP <= '" + mv_par19 + "' AND "
						
						If MV_PAR22 <> 3
							Do Case
								Case mv_par22 = 4
									cSql += " BD7_BLOPAG <> '1' AND "
								Case mv_par22 = 1
									cSql += " BD7_BLQAUG NOT IN ('1','2') AND "
								Case mv_par22 = 2
									cSql += " (BD7_BLQAUG IN ('1','2') OR BD7_BLOPAG <> '1') AND "
							EndCase
                        Endif
                        
						If MV_PAR14 < 5
							cSQL += "BD7_FASE = '"+Str(MV_PAR14,1,0)+"' AND " 
						EndIf
						
						If MV_PAR15 < 3
							If MV_PAR15 == 1
								cSQL += "BD7_SITUAC = '1' AND " 
							Else
								cSQL += "BD7_SITUAC = '3' AND "
							EndIf	
						EndIf

						cSQL += " D_E_L_E_T_ <> '*' "
				
						PLSQUERY(cSQL,"TrbTmp")
						
						If TrbTmp->(QTD) = 0
							lImpr := .F.
						Endif
						
						TrbTmp->(DbCloseArea())

				   Endif

				   dbSelectArea("BD5")
					
				   If lImpr
		    		   ImprimeBD5(cArqTrab, aCpos, aTotPeg, aTotGuia, aCabec, lCabec)
		    		   lCabec := .F.
		    	   Endif
	    		   
	    		   cCodGuia := BD5->(BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO)
	    		   dbSkip()
	    		   If cCodGuia <> BD5->(BD5_FILIAL + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO)
	    		   	  Total_NivelAcima(aTotPeg, aTotGuia)
	    			  //zera aTotGuia
			          AEVAL(aTotGuia,{|nValue, nIndex| aTotGuia[nIndex] := 0 })
	    		   EndIf
	    		   
	    		Endif   
				If lautoSt
					exit
				endIf
	    	End
	    	li++
		EndIf    	
	ElseIf (cArqTrab)->BCI_ALIAS == "BE4"
	    dbSelectArea("BE4")
	    If dbSeek((cArqTrab)->(xFilial("BE4")+BCI_CODOPE + BCI_CODLDP + BCI_CODPEG))
	    	lCabec := .T.
	    	While BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG == ;
			    (cArqTrab)->(xFilial("BE4")+BCI_CODOPE + BCI_CODLDP + BCI_CODPEG)
	  		    
	  		    If BE4->BE4_CODEMP >= mv_par18 .And. BE4->BE4_CODEMP <= mv_par19
	                 
					If MV_PAR14 < 5 .And. BE4->BE4_FASE <> Str(MV_PAR14,1,0) 
						DbSelectArea("BE4")
						DbSkip()
						Loop
					EndIf

					If MV_PAR15 < 3 //1=Ativo;2=Bloqueado;3=Todos
						iF MV_PAR15 == 1 .And. BE4->BE4_SITUAC <>'1'
							DbSelectArea("BE4")
							DbSkip()
							Loop							
						Elseif MV_PAR15==2 .And. BE4->BE4_SITUAC <>'3'
							DbSelectArea("BD5")
							DbSkip()
							Loop				
											
						Endif  
					Endif						
					
				   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				   //ณ Valida Impressao do Cabecalho da Nota...	  				    ณ
	   			   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				   lImpr := .T.
					
				   If MV_PAR20 = 1
					
						cSQL := " SELECT COUNT(*) QTD FROM " + RetSQLName("BD7")
						cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND "
						cSQL +=       " BD7_CODOPE = '" + BE4->BE4_CODOPE + "' AND "
						cSQL +=       " BD7_CODLDP = '" + BE4->BE4_CODLDP + "' AND "
						cSQL +=       " BD7_CODPEG = '" + BE4->BE4_CODPEG + "' AND "
						cSQL +=       " BD7_NUMERO = '" + BE4->BE4_NUMERO + "' AND "
						cSQL +=       " BD7_CODEMP >= '" + mv_par18 + "' AND "
						cSQL +=       " BD7_CODEMP <= '" + mv_par19 + "' AND "

						If MV_PAR22 <> 3
							Do Case
								Case mv_par22 = 4
									cSql += " BD7_BLOPAG <> '1' AND "
								Case mv_par22 = 1
									cSql += " BD7_BLQAUG NOT IN ('1','2') AND "
								Case mv_par22 = 2
									cSql += " (BD7_BLQAUG IN ('1','2') OR BD7_BLOPAG <> '1') AND "
							EndCase
                        Endif

						If MV_PAR14 < 5
							cSQL += "BD7_FASE = '"+Str(MV_PAR14,1,0)+"' AND " 
						EndIf
						
						If MV_PAR15 < 3
							If MV_PAR15 == 1
								cSQL += "BD7_SITUAC = '1' AND " 
							Else
								cSQL += "BD7_SITUAC = '3' AND "
							EndIf	
						EndIf
				
						cSQL += " D_E_L_E_T_ <> '*' "
				
						PLSQUERY(cSQL,"TrbTmp")
						
						If TrbTmp->(QTD) = 0
							lImpr := .F.
						Endif
						
						TrbTmp->(DbCloseArea())
						
				   Endif
					
			       dbSelectArea("BE4")
				   
				   If lImpr
				       ImprimeBE4(cArqTrab, aCpos, aTotPeg, aTotGuia, aCabec, lCabec)
				       lCabec := .F.
				   Endif

	   		       cCodGuia := BE4->(BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO)
	    		   dbSkip()
	    		   If cCodGuia <> BE4->(BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO)
	    			   Total_NivelAcima(aTotPeg, aTotGuia)
	    			   //zera aTotGuia
			           AEVAL(aTotGuia,{|nValue, nIndex| aTotGuia[nIndex] := 0 })
	    		   EndIf
	    		Endif   
				If lautoSt
					exit
				endIf
	    	End
		EndIf    	
	EndIf
EndIf

dbSelectArea(cAlias)

(cArqTrab)->(DbSkip())

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprimeBD5   บAutor  ณPaulo Carnelossi บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de detalhe do alias BD5                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImprimeBD5(cArqTrab, aCpos, aTotPeg, aTotGuia, aCabec, lCabec)
Local nCol := 005, nX
Local cAlias := Alias()
Local cCabBD51, cCabBD52, lCab := .F.
Local lPrima
Local lImp
Local lImpGlo
Local cChvBD7 := ""

For nX := 1 TO Len(aCabec)
	If aCabec[nX][1] == "BD5"
		cCabBD51 := aCabec[nX][2]
		cCabBD52 := aCabec[nX][3]
        Exit
  	EndIf
Next

If li > 55
	cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	lCab := .T.
EndIf

If lCabec .Or. lCab
	li++
	@ li, nCol PSay cCabBD51
	li++
	If ! Empty(cCabBD52)
		@ li, nCol PSay cCabBD52
		li++
	EndIf
	@ li, nCol PSay Replicate("-", 220-nCol)
	li++
	lCab := .F.
EndIf

Impr_Linha("BD5", aCpos, nCol, cArqTrab, , .F.)

dbSelectArea("BD6")
If BD6->(dbSeek(xFilial("BD6") + BD5->(BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO)))
	While BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO == ;
	    BD5->(xFilial("BD6") + BD5_CODOPE + BD5_CODLDP + BD5_CODPEG + BD5_NUMERO)

		If MV_PAR20 = 1
			Posicione("BD7",1,xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN),"")

			lPrima := .F.
			lImpGlo := .F.

			While BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)==BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) .and. !BD7->(Eof())
			    
				lImp := .T.
				
				Do Case
					Case mv_par22 = 4
						lImp := IIF((BD7->BD7_BLOPAG == '1'),.F.,.T.)
					Case mv_par22 = 1
						lImp := IIF((BD7->BD7_BLQAUG $ "1,2"),.F.,.T.)
					Case mv_par22 = 2
						lImp := IIF((BD7->BD7_BLQAUG $ "1,2") .or. (BD7->BD7_BLOPAG <> "1"),.T.,.F.)
                EndCase

				If MV_PAR14 < 5
					If BD7->BD7_FASE <> Str(MV_PAR14,1,0)
						lImp := .F.    
					Endif
				EndIf
				
				If MV_PAR15 < 3
					If MV_PAR15 = 1
						If BD7->BD7_SITUAC <> "1"
							lImp := .F.    
						Endif
					Else
						If BD7->BD7_SITUAC <> "3"
							lImp := .F.    
						Endif
					EndIf	
				EndIf

				If lImp
				
					ImprimeBD6(cArqTrab, aCpos, aTotPeg, aTotGuia, lPrima)
					Total_Guia(aTotGuia, aCpos, "BD7", lPrima,cChvBD7 == BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN))
					lImpGlo := .T.                
	
					If ! lPrima
						lPrima := .T.
					Endif
                Endif
                
				BD7->(DbSkip())
				cChvBD7 := BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)
			EndDo              
		Else
		
			lImp := .T.    
		
			If MV_PAR14 < 5
				If BD6->BD6_FASE <> Str(MV_PAR14,1,0)
					lImp := .F.    
				Endif
			EndIf
			
			If MV_PAR15 < 3
				If MV_PAR15 = 1
					If BD6->BD6_SITUAC <> "1"
						lImp := .F.    
					Endif
				Else
					If BD6->BD6_SITUAC <> "3"
						lImp := .F.    
					Endif
				EndIf	
			EndIf
					
			If lImp
				ImprimeBD6(cArqTrab, aCpos, aTotPeg, aTotGuia, .F.) 
				Total_Guia(aTotGuia, aCpos, "BD6", .F.)
				lImpGlo := .T.
			Endif	
		Endif

		// Caso o campo BD6_VLRGLO For maior que zero, vc deve listar 
		//as glosas que e o BDX, na mesma forma que vc localizou o BD6
		If lImpGlo
			If BD6->BD6_VLRGLO > 0
			   ImprimeBDX(cArqTrab, aCpos, aCabec)
			EndIf   
		EndIf   

    	BD6->(dbSkip())

 	EndDo
 	li++
EndIf    	

dbSelectArea(cAlias)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprimeBE4   บAutor  ณPaulo Carnelossi บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de detalhe do alias BE4                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImprimeBE4(cArqTrab, aCpos, aTotPeg, aTotGuia, aCabec, lCabec)
Local nCol := 005, nX
Local cAlias := Alias()
Local cCabBE41, cCabBE42, lCab := .F.
Local lPrima
Local lImp

For nX := 1 TO Len(aCabec)
	If aCabec[nX][1] == "BE4"
		cCabBE41 := aCabec[nX][2]
		cCabBE42 := aCabec[nX][3]
        Exit
  	EndIf
Next

If li > 55
	cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
	lCab := .T.
EndIf

If lCabec .Or. lCab
	li++
	@ li, nCol PSay cCabBE41
	li++
	If ! Empty(cCabBE42)
		@ li, nCol PSay cCabBE42
		li++
	EndIf
	@ li, nCol PSay Replicate("-", 220-nCol)
	li++
	lCab := .F.
EndIf

BE4_DESADM := Posicione("BDR",1,xFilial("BDR")+BE4->(BE4_CODOPE+BE4_TIPADM),"BDR_DESCRI")
Impr_Linha("BE4", aCpos, nCol, cArqTrab, , .F.)

/*
INCLUIDO POR PETERSON
21.02.07
HAVIA DESPOSICIONAMENTO NO BD5
*/
dbSelectArea("BD5")
BD5->(dbSetOrder(1))
BD5->(dbSeek(xFilial("BD5")+BE4->(BE4->BE4_CODOPE + BE4->BE4_CODLDP + BE4->BE4_CODPEG)))
/*
FIM ALTERACAO POR PETERSON
*/

dbSelectArea("BD6")
If BD6->(dbSeek(xFilial("BD6")+BE4->(BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO)))
	While BD6_FILIAL + BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO == ;
	    BE4->(xFilial("BD6")+BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO)

		If MV_PAR20 = 1
			Posicione("BD7",1,xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN),"")
			
			lPrima := .F.
			
			While BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)==BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) .and. ! BD7->(Eof())
			
				lImp := .T.
				
				Do Case
					Case mv_par22 = 4
						lImp := IIF((BD7->BD7_BLOPAG == '1'),.F.,.T.)
					Case mv_par22 = 1
						lImp := IIF((BD7->BD7_BLQAUG $ "1,2"),.F.,.T.)
					Case mv_par22 = 2
						lImp := IIF((BD7->BD7_BLQAUG $ "1,2") .or. (BD7->BD7_BLOPAG <> "1"),.T.,.F.)
                EndCase

				If MV_PAR14 < 5
					If BD7->BD7_FASE <> Str(MV_PAR14,1,0)
						lImp := .F.    
					Endif
				EndIf
				
				If MV_PAR15 < 3
					If MV_PAR15 = 1
						If BD7->BD7_SITUAC <> "1"
							lImp := .F.    
						Endif
					Else
						If BD7->BD7_SITUAC <> "3"
							lImp := .F.    
						Endif
					EndIf	
				EndIf
                
				If lImp
				
					ImprimeBD6(cArqTrab, aCpos, aTotPeg, aTotGuia, lPrima)
					Total_Guia(aTotGuia, aCpos, "BD7", lPrima)
	
					If ! lPrima
						lPrima := .T.
					Endif
				Endif

				BD7->(DbSkip())
			EndDo              
		Else

			lImp := .T.    
		
			If MV_PAR14 < 5
				If BD6->BD6_FASE <> Str(MV_PAR14,1,0)
					lImp := .F.    
				Endif
			EndIf
			
			If MV_PAR15 < 3
				If MV_PAR15 = 1
					If BD6->BD6_SITUAC <> "1"
						lImp := .F.    
					Endif
				Else
					If BD6->BD6_SITUAC <> "3"
						lImp := .F.    
					Endif
				EndIf	
			EndIf
            
			If lImp
				ImprimeBD6(cArqTrab, aCpos, aTotPeg, aTotGuia, .F.) 
				Total_Guia(aTotGuia, aCpos, "BD6", .F.)
			Endif	
		Endif        

    	BD6->(dbSkip())
 	EndDo
 	li++
EndIf    	

dbSelectArea(cAlias)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณTotal_Guia บAutor  ณPaulo Carnelossi    บ Data ณ 14/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณacumula valores dos campos com sub-total no array atotguia  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Total_Guia(aTotGuia, aCpos, cAlias, lCtrl,lMudBD7)
Static aAuxSub := {}
Local nZ
Default lMudBD7 := .F.

If Empty(aAuxSub) // aauxsub --> array com nome dos campos de sub-total
   aAuxSub := Cpos_SubTot(aCpos)
EndIf

For nZ := 1 TO Len(aTotGuia)
	If MV_PAR20 = 1
		If !(aAuxSub[nZ] $ "BD7_CODUNM,BD7_UNITDE") .and. !(lCtrl .and. aAuxSub[nZ] == "BD6_QTDPRO") //.And. (lMudBD7 .Or. !lMudBD7 .And. aAuxSub[nZ] == "BD6_VLRAPR")
			aTotGuia[nZ] += (substr(aAuxSub[nZ],1,3))->(FieldGet(FieldPos(aAuxSub[nZ])))
			If !lMudBD7 .And. aTotGuia[nZ] == 0 .And. aAuxSub[nz] == "BD7_VLRAPR"
				aTotGuia[nZ] := BD6->BD6_VLRAPR
			EndIf   
		Endif
	Else
		aTotGuia[nZ] += (cAlias)->(FieldGet(FieldPos(aAuxSub[nZ])))   
	Endif
Next

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออัอออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณTotal_NivelAcima บAutorณPaulo Carnelossi บ Data ณ 14/01/04  บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออฯอออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณRepassa valor do array nivel abaixo para nivel acima        บฑฑ
ฑฑบ          ณarray com valores de sub-totais                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Total_NivelAcima(aTotAcima, aTotAtual)
Local nZ

For nZ := 1 TO Len(aTotAcima)
	aTotAcima[nZ] += aTotAtual[nZ]
Next	

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณCpos_SubTotบAutor  ณPaulo Carnelossi    บ Data ณ 14/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna array com nome dos campos com sub-total             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Cpos_SubTot(aCpos)
Local aAuxSub := {}
Local nZ
For nZ := 1 TO Len(aCpos)
	If aCpos[nZ][C_SUB]
   		aAdd(aAuxSub, aCpos[nZ][C_CAMPO])
   EndIf
Next

Return aAuxSub

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณPict_SubTotบAutor  ณPaulo Carnelossi    บ Data ณ 14/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna array com pictures dos campos com sub-total         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Pict_SubTot(aCpos)
Local aAuxPic := {}
Local nZ
For nZ := 1 TO Len(aCpos)
	If aCpos[nZ][C_SUB]
   		aAdd(aAuxPic, aCpos[nZ][C_PICTURE])
   EndIf
Next

Return aAuxPic


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprimeBD6   บAutor  ณPaulo Carnelossi บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de detalhe do alias BD6                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImprimeBD6(cArqTrab, aCpos, aTotPeg, aTotGuia, lCtrl)
Local nCol := 015	//, nX
Local cAlias := Alias()

If MV_PAR20 = 1
	Impr_Linha(IIF(cAlias=="BD6","BD6,BD7",cAlias), aCpos, nCol, cArqTrab, , lCtrl)
Else
	Impr_Linha(cAlias, aCpos, nCol, cArqTrab, , .F.)
Endif

dbSelectArea(cAlias)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImprimeBDX   บAutor  ณPaulo Carnelossi บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime linha de detalhe do alias BDX - GLOSAS QDO          บฑฑ
ฑฑบ          ณ                                        BD6_VLRGLO > 0      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ImprimeBDX(cArqTrab, aCpos, aCabec)
Local nCol := 025, nX
Local cAlias := Alias()
Local cCabBDX1, cCabBDX2, lCab := .T.
Local cCodGlo := "", aChvImp := {"BDX_CODGLO"}

For nX := 1 TO Len(aCabec)
	If aCabec[nX][1] == "BDX"
		cCabBDX1 := aCabec[nX][2]
		cCabBDX2 := aCabec[nX][3]
        Exit
  	EndIf
Next

dbSelectArea("BDX")
If dbSeek(xFilial("BDX")+BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG+BD6_NUMERO))
	While BDX_FILIAL + BDX_CODOPE + BDX_CODLDP + BDX_CODPEG + BDX_NUMERO == ;
	    xFilial("BDX")+BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG+BD6_NUMERO)
	    
	    If li > 55
			cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			lCab := .T.
		EndIf

		If lCab
			li++
			@ li, nCol PSay cCabBDX1
			li++
			If ! Empty(cCabBDX2)
				@ li, nCol PSay cCabBDX2
				li++
			EndIf
			@ li, nCol PSay Replicate("-", 220-nCol)
			li++
			lCab := .F.
		EndIf
		
		If cCodGlo <> BDX->BDX_CODGLO
		    Impr_Linha("BDX", aCpos, nCol, cArqTrab, , .F.)
		    cCodGlo := BDX->BDX_CODGLO
		Else
			Impr_Linha("BDX", aCpos, nCol, cArqTrab, aChvImp, .F.)
		EndIf	
		
		dbSkip()
		
 	End
 	li++
EndIf    	

dbSelectArea(cAlias)

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัอออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_TotGer    บAutor ณPaulo Carnelossi บ Data ณ 09/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯอออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณImprime total geral                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Impr_TotGer(cArqTrab, aTotGer, cTexto, lImpSubTot, aCpos)
Local nCt1 := 1
Local nCt2 := 5
Local nTot := 0
Static aPict := {}

If Empty(aPict)
	aPict := Pict_SubTot(aCpos)
EndIf	

If lImpSubTot

	For nCt1 := 1 to nCt2
		nTot += aTotGer[(len(aTotGer)-nCt1+1)]
	Next
	
	cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)

	If nTot > 0

		@ li, 000 Psay Repl("=", 220)
		li++
		li++
		@ li, 000 PSay "*** TOTAL GERAL DA OPERADORA ***"
	    li++
		
		If MV_PAR20 = 1
			Impr_SubTot(032,cTexto, .T., "-", .T., .T., aTotGer, aPict)
		Else
			Impr_SubTot(053,cTexto, .T., "-", .T., .T., aTotGer, aPict)
		Endif

    Endif
EndIf	

Return NIL	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณCpos_PLSR026 บAutor  ณPaulo Carnelossi   บ Data ณ 09/01/04  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Monta array com campos a serem impresso no relatorio PEGs  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Cpos_PLSR026()
Local aCpoImp := {}, aCampos := {}, nX
Local lTit := .F., aCpoTit := {}
Local lSub := .F., aCpoSub := {}

aAdd(aCpoTit, "BCI_CODOPE")
aAdd(aCpoTit, "BCI_TIPGUI")

aAdd(aCpoTit, "BD5_CODOPE")
aAdd(aCpoTit, "BD5_CODLDP")
aAdd(aCpoTit, "BD5_CODPEG")
//aAdd(aCpoTit, "BD5_NUMERO")

aAdd(aCpoTit, "BE4_CODINT")
aAdd(aCpoTit, "BE4_CODLDP")
aAdd(aCpoTit, "BE4_CODPEG")
//aAdd(aCpoTit, "BE4_NUMERO")

aAdd(aCpoTit, "BD6_CODOPE")
aAdd(aCpoTit, "BD6_CODLDP")
aAdd(aCpoTit, "BD6_CODPEG")
aAdd(aCpoTit, "BD6_NUMERO")

aAdd(aCpoSub, "BD6_QTDPRO")
If MV_PAR20 = 1
	aAdd(aCpoSub, "BD7_CODUNM")
	aAdd(aCpoSub, "BD7_REFTDE")
	aAdd(aCpoSub, "BD7_UNITDE")
Endif

If MV_PAR20 = 1
	aAdd(aCpoSub, "BD7_VLRBPR")
	aAdd(aCpoSub, "BD7_VLRAPR")
	aAdd(aCpoSub, "BD7_VLRMAN")
	aAdd(aCpoSub, "BD7_VLRGLO")
	aAdd(aCpoSub, "BD7_VLRPAG")
Else
	aAdd(aCpoSub, "BD6_VLRBPR")
	aAdd(aCpoSub, "BD6_VLRAPR")
	aAdd(aCpoSub, "BD6_VLRMAN")
	aAdd(aCpoSub, "BD6_VLRGLO")
	aAdd(aCpoSub, "BD6_VLRPAG")
Endif
aAdd(aCpoImp, "BCI_CODOPE")
aAdd(aCpoImp, "BCI_CODLDP")
aAdd(aCpoImp, "BCI_CODPEG")
aAdd(aCpoImp, "BCI_MES")
aAdd(aCpoImp, "BCI_ANO")
aAdd(aCpoImp, "BCI_CODRDA")
aAdd(aCpoImp, "BCI_NOMRDA")
aAdd(aCpoImp, "BCI_TIPGUI")
aAdd(aCpoImp, "BCI_DESGUI")
aAdd(aCpoImp, "BCI_QTDEVE")
aAdd(aCpoImp, "BCI_QTDEVD")
aAdd(aCpoImp, "BCI_FASE")
aAdd(aCpoImp, "BCI_SITUAC")

aAdd(aCpoImp, "BCL_ALIAS")
aAdd(aCpoImp, "BCL_CDORIT")

aAdd(aCpoImp, "BD5_CODOPE")
aAdd(aCpoImp, "BD5_CODEMP")
aAdd(aCpoImp, "BD5_CODLDP")
aAdd(aCpoImp, "BD5_CODPEG")
aAdd(aCpoImp, "BD5_NUMERO")
aAdd(aCpoImp, "BD5_MATRIC")
aAdd(aCpoImp, "BD5_TIPREG")
aAdd(aCpoImp, "BD5_DIGITO")
aAdd(aCpoImp, "BD5_NOMUSR")
aAdd(aCpoImp, "BD5_DATPRO")
aAdd(aCpoImp, "BD5_CID")
aAdd(aCpoImp, "BD5_DESCID")
aAdd(aCpoImp, "BD5_REGSOL")
aAdd(aCpoImp, "BD5_NOMSOL")
aAdd(aCpoImp, "BD5_FASE")
//aAdd(aCpoImp, "BD5_SITUAC")
aAdd(aCpoImp, "BD5_DTDIGI")
If MV_PAR21 = 1
	aAdd(aCpoImp, "BD5_LOCREQ")
Endif
                      
aAdd(aCpoImp, "BE4_CODINT")
aAdd(aCpoImp, "BE4_CODLDP")
aAdd(aCpoImp, "BE4_CODPEG")
aAdd(aCpoImp, "BE4_NUMERO")
aAdd(aCpoImp, "BE4_CODEMP")
aAdd(aCpoImp, "BE4_MATRIC")
aAdd(aCpoImp, "BE4_TIPREG")
aAdd(aCpoImp, "BE4_DIGITO")
aAdd(aCpoImp, "BE4_NOMUSR")
aAdd(aCpoImp, "BE4_DATPRO")
aAdd(aCpoImp, "BE4_HORPRO")
aAdd(aCpoImp, "BE4_TIPADM")
aAdd(aCpoImp, "BE4_DESADM")
aAdd(aCpoImp, "BE4_GRPINT")
aAdd(aCpoImp, "BE4_TIPINT")
//aAdd(aCpoImp, "BE4_DIASIN")
aAdd(aCpoImp, "BE4_PADINT")
aAdd(aCpoImp, "BE4_CID")
aAdd(aCpoImp, "BE4_DESCID")
aAdd(aCpoImp, "BE4_REGSOL")
aAdd(aCpoImp, "BE4_NOMSOL")
aAdd(aCpoImp, "BE4_FASE")
//aAdd(aCpoImp, "BE4_SITUAC")
aAdd(aCpoImp, "BE4_DTDIGI")

aAdd(aCpoImp, "BD6_CODOPE")
aAdd(aCpoImp, "BD6_CODLDP")
aAdd(aCpoImp, "BD6_CODPEG")
aAdd(aCpoImp, "BD6_NUMERO")
aAdd(aCpoImp, "BD6_SEQUEN")
aAdd(aCpoImp, "BD6_CODPAD")
aAdd(aCpoImp, "BD6_CODPRO")
aAdd(aCpoImp, "BD6_DESPRO")
aAdd(aCpoImp, "BD6_QTDPRO")

If MV_PAR20 = 1
	aAdd(aCpoImp, "BD7_CODUNM")
	aAdd(aCpoImp, "BD7_REFTDE")
	aAdd(aCpoImp, "BD7_UNITDE")
Endif

If MV_PAR20 = 1
	aAdd(aCpoImp, "BD7_VLRBPR")
	aAdd(aCpoImp, "BD7_VLRAPR")
	aAdd(aCpoImp, "BD7_VLRMAN")
	aAdd(aCpoImp, "BD7_VLRGLO")
	aAdd(aCpoImp, "BD7_VLRPAG")
Else
	aAdd(aCpoImp, "BD6_VLRBPR")
	aAdd(aCpoImp, "BD6_VLRAPR")
	aAdd(aCpoImp, "BD6_VLRMAN")
	aAdd(aCpoImp, "BD6_VLRGLO")
	aAdd(aCpoImp, "BD6_VLRPAG")
Endif
aAdd(aCpoImp, "BD6_VIA")   
aAdd(aCpoImp, "BD6_PERVIA")
aAdd(aCpoImp, "BD6_CODTAB")
aAdd(aCpoImp, "BD6_ALIATB")

aAdd(aCpoImp, "BDX_CODGLO")
aAdd(aCpoImp, "BDX_DESGLO")
aAdd(aCpoImp, "BDX_ACAO")
aAdd(aCpoImp, "BDX_INFGLO")
aAdd(aCpoImp, "BDX_PERGLO")
aAdd(aCpoImp, "BDX_VLRGLO") 

dbSelectArea("SX3")
dbSetOrder(2)

For nX := 1 TO Len(aCpoImp)
	lTit := .F.
	lSub := .F.
    If dbSeek(aCpoImp[nX])
        lTit := ASCAN(aCpoTit, aCpoImp[nX]) > 0
        lSub := ASCAN(aCpoSub, aCpoImp[nX]) > 0
    	aAdd(aCampos, { X3_ARQUIVO, X3_CAMPO, X3_TIPO, X3_TAMANHO, lSub, X3_TITULO, X3_PICTURE, lTit, X3_CBOX })
    EndIf
Next

Return(aCampos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLinha_Cabec บAutor  ณPaulo Carnelossi  บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Linha Cabec para Relatorio                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Linha_Cabec(cAlias, aCampos, aExcTam)
Local nX, aLinCabec, cLinCabec1 := "", cLinCabec2 := "", cTitle, aAuxText
Local nZ, aComboBox, nMaiorTam := 0

For nX := 1 TO Len(aCampos)

	If aCampos[nX][C_ALIAS] $ cAlias .And. ! aCampos[nX][C_CAB]
        
        cTitle := AllTrim(aCampos[nX][C_TITLE])
        
		If aCampos[nX][C_TIPO] == "N"
		
       		If Len(cTitle) <= aCampos[nX][C_TAMANHO]
				cLinCabec1 += PadL(cTitle, aCampos[nX][C_TAMANHO])
				cLinCabec2 += Space(aCampos[nX][C_TAMANHO])
			Else
				aAuxText := R026QbTexto(cTitle, aCampos[nX][C_TAMANHO], Space(1))
				cLinCabec1 += PadL(aAuxText[1], aCampos[nX][C_TAMANHO])
				If Len(aAuxText) > 1
					cLinCabec2 += PadL(aAuxText[2], aCampos[nX][C_TAMANHO])
				EndIf	
			EndIf
			cLinCabec1 += Space(1)
			cLinCabec2 += Space(1)
			
       	Else

       		If  (nPosTam := ASCAN(aExcTam, {|aVal| aVal[1] == aCampos[nX][C_CAMPO]})) > 0
       			aCampos[nX][C_TAMANHO] := aExcTam[nPosTam][2]
       		EndIf
       		
       		If ! EMPTY(aCampos[nX][C_CBOX]) // COMBO BOX
       		    aComboBox := RetSX3Box(aCampos[nX][C_CBOX],,,1)
       		    nMaiorTam := aCampos[nX][C_TAMANHO]
       		    AEVAL(aComboBox, {|cValue, nZ|nMaiorTam := If(Len(aComboBox[nZ][1]) > nMaiorTam, Len(aComboBox[nZ][1]), nMaiorTam)} )
       			aCampos[nX][C_TAMANHO] := nMaiorTam
       	    EndIf
       	    
       		If Len(cTitle) <= aCampos[nX][C_TAMANHO]
				cLinCabec1 += PadR(cTitle, aCampos[nX][C_TAMANHO])
				cLinCabec2 += Space(aCampos[nX][C_TAMANHO])
			Else
				aAuxText := R026QbTexto(cTitle, aCampos[nX][C_TAMANHO], Space(1))
				cLinCabec1 += PadR(aAuxText[1], aCampos[nX][C_TAMANHO])
				If Len(aAuxText) > 1
					cLinCabec2 += PadR(aAuxText[2], aCampos[nX][C_TAMANHO])
				EndIf	
			EndIf
			cLinCabec1 += Space(1)
			cLinCabec2 += Space(1)

       	EndIf
       
	EndIf
	
Next
aLinCabec := { cLinCabec1, cLinCabec2 }

Return(aLinCabec)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณImpr_Linha  บAutor  ณPaulo Carnelossi  บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImprime Linha de dados                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Impr_Linha(cAlias, aCampos, nCol, cArqTrab, aChvImp, lCtrl)
Local nX, xContCpo, aComboBox, nZ, cValue, cCombo, cCampo, nPosCpo, cTxt
DEFAULT aChvImp := {}

For nX := 1 TO Len(aCampos)
    
	If aCampos[nX][C_ALIAS] $ cAlias .And. ! aCampos[nX][C_CAB]
        
        If lCtrl
	        If aCampos[nX][C_CAMPO] $ "BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_SEQUEN,BD6_CODPAD,BD6_CODPRO,BD6_DESPRO,BD6_QTDPRO"
				nCol += aCampos[nX][C_TAMANHO]+1
            	Loop
	        Endif
        Endif

        If cAlias == "BCI"
        	nPosCpo := (cArqTrab)->(FieldPos(aCampos[nX][C_CAMPO]))
            If nPosCpo > 0 
	        	xContCpo := (cArqTrab)->(FieldGet(nPosCpo))
	       	Else
        	    cCampo   :=aCampos[nX][C_CAMPO]
        		xContCpo := &cCampo
        	EndIf
        Else
            nPosCpo := (substr(aCampos[nX][C_CAMPO],1,3))->(FieldPos(aCampos[nX][C_CAMPO]))
            If nPosCpo > 0 
	        	xContCpo := (substr(aCampos[nX][C_CAMPO],1,3))->(FieldGet(nPosCpo))
	       	Else
        	    cCampo   :=aCampos[nX][C_CAMPO]
        		xContCpo := &cCampo
        	EndIf
        EndIf	
        
		If aCampos[nX][C_TIPO] == "N"
		    If Empty(aChvImp) .OR. ASCAN(aChvImp, aCampos[nX][C_CAMPO]) == 0
				If li > 55
					cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			    EndIf
				@ li, nCol PSay PadL(objCENFUNLGP:verCamNPR(aCampos[nX][C_CAMPO], Transform(xContCpo, aCampos[nX][C_PICTURE])), aCampos[nX][C_TAMANHO])
			EndIf	
       	Else
       		If aCampos[nX][C_TIPO] == "D"
       			xContCpo := DTOC(xContCpo)
       		EndIf
       		
       		If ! EMPTY(aCampos[nX][C_CBOX]) // COMBO BOX
       		    aComboBox := RetSX3Box(aCampos[nX][C_CBOX],,,1)
       		    cCombo := NIL
       		    For nZ := 1 To Len(aComboBox)
	       		    If aComboBox[nZ][2] == xContCpo
	       		    	cCombo := aComboBox[nZ][1]
       		    	    Exit
       		    	EndIf
       		    Next	    
       		    xContCpo := If(cCombo == NIL, xContCpo, cCombo)
       	    EndIf
       		
       		If Empty(aChvImp) .OR. ASCAN(aChvImp, aCampos[nX][C_CAMPO]) == 0
				If li > 55
					cabec(cTitulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			    EndIf
				@ li, nCol PSay PadR(objCENFUNLGP:verCamNPR(aCampos[nX][C_CAMPO], xContCpo), aCampos[nX][C_TAMANHO])
			EndIf

       	EndIf

		nCol += aCampos[nX][C_TAMANHO]+1  //1->separador
        
    EndIf
    
Next

If cAlias == "BD6,BD7"
	If MV_PAR20 = 1
		If BD7->BD7_BLOPAG == "1"
			cTxt := ""
			If BD7->BD7_BLQAUG $ "1,2"
				cTxt := "AuG"
			Else
				cTxt := "Sis"
			Endif
			@ li, nCol PSay objCENFUNLGP:verCamNPR("BD7_BLQAUG", cTxt)
		Endif
	Endif
Endif
li++

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLista_CposบAutor  ณPaulo Carnelossi    บ Data ณ  09/01/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna string campos para montar a query                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Lista_Cpos(cAlias, aCampos, aExcCpo)
Local nX, cStringCpos := ""

For nX := 1 TO Len(aCampos)
	If aCampos[nX][C_ALIAS] == cAlias 
	    If ASCAN(aExcCpo, aCampos[nX][C_CAMPO]) == 0
			cStringCpos += " "+cAlias+"."+aCampos[nX][C_CAMPO]+", "
		EndIf	
	EndIf
Next

cStringCpos := PadR(cStringCpos, Len(cStringCpos)-2)

Return(cStringCpos)



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

		(cArqTrab)->(Eval(aCondFinal[nNivel][PROC_LACO], nNivel))
		
		If nNivel < Len(aCondFinal)  // avanca para proximo nivel
			DetalheRel(aCondFinal, nNivel+1, cArqTrab)
		EndIf	
	If lautoSt
		exit
	endIf
End

(cArqTrab)->(Eval(aCondFinal[nNivel][DEPOIS_LACO],nNivel))

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

Static Function Impr_SubTot(nCol,cTexto,lAlinDir, cSinal, lImprTot, lImprLinSep, aQuant, aPict)
Local cString, cPict
Local nZ
nCol := If(nCol == NIL, 000, nCol)
lAlinDir := If(lAlinDir == NIL, .T., lAlinDir)
cTexto := If(cTexto == NIL, "Total", cTexto)
cSinal := If(cSinal == NIL, "-", cSinal)
lImprTot := If(lImprTot == NIL, .T., lImprTot)

If lImprTot
	li++
	cString  := Padr(cTexto,32,".")+": "
	For nZ := 1 TO Len(aQuant)
	    If MV_PAR20 = 1
			If nZ <> 2 .and. nZ <> 4 
				If nZ = 1
				   cPict  := "@E 9999999.99"
				Else
			    	cPict  := Alltrim(If(nZ=3,"@E 999,999,999,999.9999",(If(Empty(aPict[nZ]), "@E 999,999,999.99", aPict[nZ]))))
				Endif 
				cString += Transform(aQuant[nZ], cPict)+Space(2)
			Else           
				cString += Space(4)
			Endif
	    Else
		    If nZ = 1
			   cPict  := "@E 9999999.99"
			Else
		    	cPict  := Alltrim(If(nZ=3,"@E 999,999,999,999.9999",(If(Empty(aPict[nZ]), "@E 999,999,999.99", aPict[nZ]))))
			Endif 
			cString += Transform(aQuant[nZ], cPict)+Space(2)
		Endif
	Next
			
	If lAlinDir
		@ li, nCol Psay PadR(cString, 220-nCol)
	Else
		@ li, nCol Psay PadL(cString, 220-nCol)
	EndIf
	li++
EndIf	

If lImprLinSep
	@ li, nCol Psay Repl(cSinal,220-nCol)
	li++
EndIf	

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณR026QbTexto บAutor ณPaulo Carnelossi   บ Data ณ  02/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณQuebra o Texto de acordo com tamnho e separador informado   บฑฑ
ฑฑบ          ณdevolvendo um array com a string quebrada                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function R026QbTexto(cTexto, nTamanho, cSeparador)
Local aString := {}, nTamAux := nTamanho
Local nPos, nCtd, nTamOri := Len(cTexto), cAuxTexto

If Len(Trim(cTexto)) > 0

   If Len(Trim(cTexto)) <= nTamanho

      If Len(Trim(cTexto)) > 0
	      aAdd(aString, AllTrim(cTexto) )
      EndIf

   Else
	
		If (nPos := At(cSeparador, cTexto)) != 0
		   
			For nCtd := 1 TO nTamOri STEP nTamAux
		
				cAuxTexto := Subs(cTexto, nCtd, nTamanho)
			
			   If nCtd+nTamanho < nTamOri
				   While Len(Subs(cAuxTexto, Len(cAuxTexto), 1)) > 0 .And. ;
				   				Subs(cAuxTexto, Len(cAuxTexto), 1) <> cSeparador
				   
			   		cAuxTexto := Subs(cAuxTexto, 1, Len(cAuxTexto)-1)
			   		
			      End
			   EndIf
			      
		      If Len(cAuxTexto) > 0
			      cAuxTexto 	:= Subs(cTexto, nCtd, Len(cAuxTexto))
			      nTamAux 		:= Len(cAuxTexto)
		      Else
		      	cAuxTexto := Subs(cTexto, nCtd, nTamanho)
			      nTamAux 		:= nTamanho
		      EndIf
		
		      If Len(Trim(cAuxTexto)) > 0
			      aAdd(aString, Alltrim(cAuxTexto))
		      EndIf
		   Next
		
		Else
		
			For nCtd := 1 TO nTamOri STEP nTamanho
			   If Len(Subs(cTexto, nCtd, nTamanho)) > 0 
			      If Len(Trim(Subs(cTexto, nCtd, nTamanho))) > 0
						aAdd(aString, AllTrim(Subs(cTexto, nCtd, nTamanho)))
					EndIf	
				EndIf	
			Next
		
		EndIf
		
	EndIf
Else
	aAdd(aString, Space(nTamanho))	
EndIf

Return aString

