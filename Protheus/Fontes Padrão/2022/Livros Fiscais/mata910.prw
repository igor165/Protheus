#include "Protheus.ch"
#include "Mata910.ch"

#DEFINE VALMERC    1 // Valor total do mercadoria
#DEFINE VALDESC	    2 // Valor total do desconto
#DEFINE FRETE      3 // Valor total do Frete
#DEFINE VALDESP    4 // Valor total da despesa
#DEFINE TOTF1      5 // Total de Despesas Folder 1
#DEFINE TOTPED     6 // Total do Pedido
#DEFINE SEGURO     7 // Valor total do seguro
#DEFINE TOTF3      8 // Total utilizado no Folder 3
#DEFINE VNAGREG    9 // Valor nao agregado ao total do documento

Static lLGPD  		:= FindFunction("FISLGPD") .And. FISLGPD()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATA910  ³ Autor ³ Edson Maricate        ³ Data ³ 17.01.00   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Entrada de Notas Fiscais de Compra Manual                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function MATA910(xAutoCab,xAutoItens,nOpcAuto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo os campos do arquivo que sempre deverao³
//³ aparecer no browse. (funcao mBrouse)                         ³
//³ ----------- Elementos contidos por dimensao ---------------- ³
//³ 1. Titulo do campo (Este nao pode ter mais de 12 caracteres) ³
//³ 2. Nome do campo a ser editado                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aFixe := { { STR0046,"D1_DOC    " },; //"Numero da NF"
                { STR0047,"D1_SERIE  " },; //"Serie da NF "
                { STR0048,"D1_FORNECE" } } //"Fornecedor  "

Local aCores    := {	{'D1_TIPO=="N"'		,'DISABLE'   	},;	// NF Normal
						{'D1_TIPO=="P"'		,'BR_AZUL'   	},;	// NF de Compl. IPI
						{'D1_TIPO=="I"'		,'BR_MARROM' 	},;	// NF de Compl. ICMS
						{'D1_TIPO=="C"'		,'BR_PINK'   	},;	// NF de Compl. Preco/Frete
						{'D1_TIPO=="B"'		,'BR_CINZA'  	},;	// NF de Beneficiamento
						{'D1_TIPO=="D"'		,'BR_AMARELO'	} }	// NF de Devolucao

Local lSped 	:=	.F.

Default nOpcAuto     := 3

PRIVATE cCalcImpV		:= GETMV("MV_GERIMPV")            // Internacionaliza‡„o
PRIVATE lSD1100I 		:= .F.
PRIVATE lSD1100E 		:= .F.
PRIVATE lSF1100I 		:= .F.
PRIVATE lSF1100E 		:= .F.
PRIVATE lSF3COMPL		:= (ExistBlock("SF3COMPL"))
PRIVATE lIntegracao	:=	.F.
PRIVATE l100BD   		:=	.F.			// Base Desp. Acessorias
PRIVATE cTipoNF		:=	'E' // Flag para AliqIcm() no Mata100x
PRIVATE lConfrete2	:=	.f.,lConImp2:=.f.
PRIVATE lMT100DP		:=	.F.
PRIVATE aAutoItens 	:=	{}
PRIVATE aRotina 		:= MenuDef()
PRIVATE l103Auto    := .F.	//Criada para possibilitar utilizacao de funcoes no MATA103X
PRIVATE oFisTrbGen	
PRIVATE lGeraNum	:= .F.
//Inicializando variaveis para processo de rotina automatica
PRIVATE l910Auto     := ValType(xAutoCab) == "A" .and. ValType(xAutoItens) == "A"
PRIVATE aAutoCab     := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis da funcao pergunte                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cColICMS 	:= GETMV("MV_COLICMS")
mv_par01		:=	2
mv_par02		:=	2
mv_par03		:=	2
lRecebto 	:=	.F.

lSped 	:=	cPaisLoc == "BRA"

If lSped
	Aadd(aRotina,{STR0068,"a910Compl",0,4,0,NIL}) //"Complementos"
Endif


PRIVATE cCadastro	:= OemToAnsi(STR0005) //"Notas Fiscais de Entrada"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//³ Obs.: O parametro aFixe nao e' obrigatorio e pode ser omitido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If l910Auto
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	DEFAULT nOpcAuto := 3
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"SF1")
Else
    mBrowse( 6, 1,22,75,"SD1",aFixe,"D1_TES",,,,aCores)
EndIf


Return
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do Programa                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a910NFiscal³ Autor ³ Edson Maricate       ³ Data ³18/01/00  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de inclusao de notas fiscal de entrada.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ a910Inclui(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Numero da opcao selecionada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION a910NFiscal(cAlias,nReg,nOpcx)

Local nOpc		:=	0
Local lGravaOk	:=	.T.
Local nUsado	:=	0
Local aArea		:=	GetArea()
Local aPages	:=	{"HEADER"}

Local aCombo1		:= {STR0038,;	//"Normal"
						 STR0039,;	//"Devoluçao"
						 STR0040,;	//"Beneficiamento"
						 STR0041,;	//"Compl.  ICMS"
						 STR0042,;	//"Compl.  IPI"
						 STR0043}	//"Compl. Preço"

Local aAuxCombo1	:= {"N","D","B","I","P","C"}
Local c910Tipo		:= ""
Local aCombo2		:= {STR0045,;  //"Nao"
						STR0044 }  //"Sim"
Local c910Form	:= ""
Local aCombo3   := {"   ",;
					STR0077,;	//"N-Normal"
					STR0078,;	//"C-Complementar"
					STR0079,;	//"A-Anula Valores"
					STR0080}    //"S-Substituto
Local aCombo4	:= {STR0073,;	//"C-CIF"
					STR0074,;	//"F-FOB"
					STR0075,;	//"T-Por conta terceiro"
					STR0084,;   //"R - POR CONTA REMETENTE"
					STR0085,;   //"D - POR CONTA DESTINATÁRIO"
					STR0076,;	//"S-Sem frete".
					"   "}
Local aTitles	:=	{	OemToAnsi(STR0006),; //"Totais"
							OemToAnsi(STR0007),; //"Inf. Fornecedor"
							OemToAnsi(STR0008),; //"Descontos/Frete/Despesas"
							OemToAnsi(STR0009),; //"Impostos"
							OemToAnsi(STR0010)} //"Livros Fiscais"

Local aInfForn	:= {"","",CTOD("  /  /  "),CTOD("  /  /  "),"",""}
Local a910Var	:= {0,0,0,0,0,0,0,0,0}

Local l910Visual	:= .F.
Local l910Deleta	:= .F.
Local l910Altera	:= .F.
Local lPyme		   	:= Iif(Type("__lPyme") <> "U",__lPyme,.F.)

Local aSizeAut		:= MsAdvSize(,.F.,345)
Local lContinua		:= .T.
Local aRecSF3		:= {}
Local aNFEletr		:= {}


Local oDlg
Local oGetDados
Local oc910SForn
Local oc910GForn
Local oc910Loj
Local oCond
Local ocNota
Local ocSerie
Local o910Tipo
Local oCombo1
Local oCombo3
Local oCombo4
Local odDEmissao
Local aObj[18]	// Array com os objetos utilizados no Folder
Local c910SForn	:= OemToAnsi(STR0011) //"Fornecedor"
Local cSeek, cWhile
Local nY	:=0
Local nI	:=0
Local nObj	:=0
Local nObj1	:=0
Local nSpedExc:= GetNewPar("MV_SPEDEXC",72)
Local nHoras := 0
Local dDtDigit  := dDataBase
Local nLinSay   := 0
Local aUsButtons	:= {}
Local xButtons	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo os campos do arquivo que deverao ser   ³
//³ mostrados pela GetDados().                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aGetCpo	:= {	"D1_ITEM"   , "D1_COD"		,"D1_UM"		,"D1_QUANT"	,"D1_VUNIT"	,;
						"D1_TOTAL"	,"D1_VALIPI"	,"D1_VALICM"	,"D1_TES"	,;
						"D1_CF"		,"D1_VALICMR"	,"D1_PICM"		,"D1_SEGUM"	,;
						"D1_QTSEGUM","D1_IPI"		,"D1_PESO"		,"D1_CONTA"	,;
						"D1_DESC"	,"D1_NFORI"		,"D1_SERIORI"	,"D1_BASEICM",;
						"D1_BRICMS"	,"D1_ICMSRET"	,"D1_LOCAL"		,"D1_ITEMORI",;
						"D1_BASEIPI","D1_VALDESC"	,"D1_CLASFIS"	,"D1_CC", "D1_ALIQII",;
						"D1_II", "D1_ITEMCTA", "D1_CLVL"}

Local nLancAp		:=	0
Local aHeadCDA		:=	{}
Local aColsCDA		:=	{}
Local aHeadCDV		:= {}
Local aColsCDV		:= {}
Local nNFe			:=	0
Local nDanfe        := 0
Local cTpCte    := " "
Local cTpFrt    := " "
Local c910Cte   := " "
Local c910Frt   := " "
Local nCombo    := 1
Local cSerId	   := ""
Local cPerg		:= "MATA910"
Local lTrbGen 	:= IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SD1","D1_IDTRIB"), .F.)
Private aDanfe  := {}

Private l910Inclui := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o campo de codigo de lancamento cat 83 ³
//³deve estar visivel no acols                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SuperGetMV("MV_CAT8309",,.F.)
	aAdd(aGetCpo,"D1_CODLAN")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case nOpcX == 0
		nOpcX := 2
		PRIVATE aRotina := { { STR0002, "a910NFiscal", 0, 2 }, { STR0002 , "a910NFiscal" , 0 , 2 } }
		l910Visual 	:= .T.
	Case aRotina[nOpcx][4] == 2
		l910Visual 	:= .T.
	Case aRotina[nOpcx][4] == 3
		l910Inclui	:= .T.
	Case aRotina[nOpcx][4] == 5
		l910Deleta	:= .T.
		l910Visual	:= .T.
		
		If cPaisLoc == "BRA"
			ValidPerg(cPerg)
			Pergunte(cPerg,.F.)
			SetKey( VK_F12,{|| Pergunte(cPerg,.T.)})
		EndIf
EndCase

//If !lPyme .And. !l910Deleta .And. l910Visual    <<== Inibido Serie 3 tem banco do conhecimento
  If !l910Deleta .And. l910Visual
	xButtons := {}
	AAdd(xButtons,{ "CLIPS", {|| A910Conhec() }, STR0050, "Conhecim." } ) // "Banco de Conhecimento", "Conhecim."
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Avalia botoes do usuario                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "MA910BUT" )
	If ValType( aUsButtons := ExecBlock( "MA910BUT", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd(xButtons, x) } )
	EndIf
EndIf

Private bTgRefresh		:= {|| Iif(lTrbGen .And. ValType(oGetDados) == "O",MaFisLinTG(oFisTrbGen,oGetDados:oBrowse:nAt),.T.)}
Private	bFolderRefresh  := {|| (A910FRefresh(aObj))}
Private bGDRefresh      := Iif(ValType(oGetDados) == "O",{|| (oGetDados:oBrowse:Refresh()) },{|| .T. })
Private bRefresh        := {|| (A910Refresh(@a910Var,l910Visual,nValBrut)),(Eval(bFolderRefresh)),Eval(bTgRefresh)}
Private bListRefresh    := {|| (A910FisToaCols()),Eval(bRefresh),Eval(bGdRefresh)}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica parametro MV_DATAFIS pela data de digitacao.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l910Visual .And. !FisChkDt(dDatabase)
	Return
Endif

If Type("l910Auto") <> "L"
	l910Auto := .F.
EndIf

If !l910Auto
	dbSelectArea("SF1")
	dbSetOrder(1)
	dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
Else
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
EndIf

Private	cTipo      := If(l910Inclui,CriaVar("F1_TIPO"),SF1->F1_TIPO)
Private cFormul    := If(l910Inclui,CriaVar("F1_FORMUL"),SF1->F1_FORMUL)
Private cNFiscal   := If(l910Inclui,CriaVar("F1_DOC"),SF1->F1_DOC)
Private cSerie     := If(l910Inclui,CriaVar("F1_SERIE"),SF1->F1_SERIE)
Private dDEmissao  := If(l910Inclui,CriaVar("F1_EMISSAO"),SF1->F1_EMISSAO)
Private ca100For   := If(l910Inclui,CriaVar("F1_FORNECE"),SF1->F1_FORNECE)
Private cLoja      := If(l910Inclui,CriaVar("F1_LOJA"),SF1->F1_LOJA)
Private cEspecie   := If(l910Inclui,CriaVar("F1_ESPECIE"),SF1->F1_ESPECIE)
Private aValidGet  := {}
Private	aInfFornAut:= {}
Private	a910VarAut := {}
Private	aNFeAut    := {}
Private	aDANAut    := {}

nValBrut := SF1->F1_VALBRUT


PRIVATE	aCols   := {},;
        aHeader := {}
PRIVATE oLancApICMS
PRIVATE oLancCDV 
PRIVATE aColsD1		:=	aCols
PRIVATE aHeadD1		:=	aHeader
dDtdigit 	:= IIf(!Empty(SF1->F1_DTDIGIT),SF1->F1_DTDIGIT,SF1->F1_EMISSAO)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica valores da Nota Fiscal Eletronica no SF2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "BRA"
	If l910Inclui
		aNFEletr := {CriaVar("F1_NFELETR"),CriaVar("F1_CODNFE"),CriaVar("F1_EMINFE"),CriaVar("F1_HORNFE"),CriaVar("F1_CREDNFE"),CriaVar("F1_NUMRPS")}
	Else
		aNFEletr := {SF1->F1_NFELETR,SF1->F1_CODNFE,SF1->F1_EMINFE,SF1->F1_HORNFE,SF1->F1_CREDNFE,SF1->F1_NUMRPS}
	Endif
Endif

If cPaisLoc == "BRA"
	If l910Inclui
		aDanfe := {CriaVar("F1_CHVNFE"),CriaVar("F1_TPFRETE"),CriaVar("F1_TPCTE")}
	Else
		aDanfe := {SF1->F1_CHVNFE,SF1->F1_TPFRETE,SF1->F1_TPCTE}
	Endif

    cTpCte  := If(l910Inclui,CriaVar("F1_TPCTE"),SF1->F1_TPCTE)
    cTpFrt  := If(l910Inclui,CriaVar("F1_TPFRETE"),SF1->F1_TPFRETE)
Endif

If !l910Inclui
	If l910Deleta
		If SF1->F1_FORMUL == "S" .And. "SPED"$cEspecie .And. SF1->F1_FIMP$"TS"
			nHoras := SubtHoras( dDtdigit, SF1->F1_HORA, dDataBase, substr(Time(),1,2)+":"+substr(Time(),4,2) )
			If nHoras > nSpedExc .And. SF1->F1_STATUS<>"C"
				MsgAlert("Não foi possivel excluir a(s) nota(s), pois o prazo para o cancelamento da(s) NF-e é de " + Alltrim(STR(nSpedExc)) +" horas")
				Return .T.
		    EndIf
		EndIf
		If !FisChkExc(SD1->D1_SERIE,SD1->D1_DOC,SD1->D1_FORNECE,SD1->D1_LOJA)
			RestArea(aArea)
			Return(.T.)
		Endif
		If SF1->F1_ORIGLAN != "LF"
			HELP("  ",1,"NAOLIV")
			RestArea(aArea)
			Return .T.
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa as variaveis utilizadas na exibicao da NF         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A910Fornec(SF1->F1_FORNECE,SF1->F1_LOJA,@aInfForn,cTipo,l910Inclui)
	If !l910Auto
		IIF(!l910Visual, A910CabOk(@oCombo1,@ocNota,@odDEmissao,@oc910GForn,@oc910Loj,l910Visual), Nil)
		c910Tipo	:= aCombo1[aScan(aAuxCombo1,cTipo)]
		c910Form	:= aCombo2[If(cFormul=="S",2,1)]
		If Alltrim(cTpCte)<>""
    	    IF Ascan(aCombo3, {|x| Substr(x,1,1) == cTpCte}) > 0
		        c910Cte := aCombo3[Ascan(aCombo3, {|x| Substr(x,1,1) == cTpCte})]
			EndIF
    	EndIf
		If Alltrim(cTpFrt)<>""
    	    IF Ascan(aCombo4, {|x| Substr(x,1,1) == cTpFrt}) > 0
		        c910Frt := aCombo4[Ascan(aCombo4, {|x| Substr(x,1,1) == cTpFrt})]
			EndIF
    	EndIf
	EndIf
EndIf

cSeek		:= xFilial("SD1")+cNFiscal+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
cWhile		:= "SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader e aCols                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sintaxe da FillGetDados(nOpcx,cAlias,nOrder,cSeekKey,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry,bCriaVar,lUserFields) |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FillGetDados(nOpcx,"SD1",1,cSeek,{|| &cWhile },/*uSeekFor*/,/*aNoFields*/,aGetCpo,/*lOnlyYes*/,/*cQuery*/,/*bMontCols*/,l910Inclui,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,{|| IIF(l910Deleta .and. !SoftLock("SD1"),lContinua := .F.,.T.)},/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/,.T.)

If l910Inclui
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a montagem de uma linha em branco no aCols.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCols[1][Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"})] := StrZero(1,TAMSX3("D1_ITEM")[1])
Else

	MaFisIniNF(1,SF1->(RecNo()))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carega o Array contendo os Registros Fiscais.(SF3)      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF3")
	dbSetOrder(4)
	dbSeek(xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE)
	While !Eof().And.lContinua.And. xFilial()+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE == ;
						F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
		If Substr(SF3->F3_CFO,1,1) < "5" .And. Empty(SF3->F3_DTCANC)
			aAdd(aRecSF3,RecNo())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Trava os registros do SF3 - exclusao                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If l910Deleta
				If !SoftLock("SF3")
					lContinua := .F.
				Endif
			EndIf
		EndIf
	    dbSkip()
	End
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa o Refresh nos valores de impostos.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	A910Refresh(@a910Var,l910Visual,nValBrut)
EndIf

If !l910Auto
	aObjects := {}
	AAdd( aObjects, { 0,    41, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 0,    75, .T., .F. } )

	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }

	aPosObj := MsObjSize( aInfo, aObjects )

	aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],310,;
						{{8,23,78,128,163,200,250,270},;
						{8,32,95,130,170,204,260},;
						{5,70,160,205,295},;
						{6,34,200,215},;
						{6,34,106,139},;
						{6,34,245,268,220},;
						{5,50,150,190},;
						{277,130,190,293}})


	DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro Of oMainWnd PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

	@ aPosObj[1][1],aPosObj[1][2] TO aPosObj[1][3],aPosObj[1][4] LABEL '' OF oDlg PIXEL

	nLinSay	:=	aPosObj[1][1]+6

	@ nLinSay  ,aPosGet[1,1] SAY OemToAnsi(STR0012) Of oDlg PIXEL SIZE 26 ,9 //'Tipo'
	@ nLinSay-2,aPosGet[1,2] MSCOMBOBOX oCombo1 VAR c910Tipo ITEMS aCombo1 SIZE 50 ,90 ;
	   			WHEN VisualSX3('F1_TIPO').and. !l910Visual  VALID A910Combo(@cTipo,aCombo1,c910Tipo,aAuxCombo1).And.;
	   			A910Tipo(cTipo,@oc910SForn,@c910SForn,@oc910GForn,@ca100For,@cLoja,@oc910Loj) OF oDlg PIXEL

	@ nLinSay   ,aPosGet[1,3] SAY OemToAnsi(STR0013) Of oDlg PIXEL SIZE 52 ,9 //'Formulario Proprio'
	@ nLinSay-2 ,aPosGet[1,4] MSCOMBOBOX oCombo2 VAR c910Form ITEMS aCombo2 SIZE 25 ,50 ;
		    			WHEN VisualSX3('F1_FORMUL').And.!l910Visual ;
		    			VALID A910Combo(@cFormul,aCombo2,c910Form,{"N","S"}).And.a910Formul(cFormul,@cNFiscal,@cSerie,@ocNota,@ocSerie) OF oDlg PIXEL


	@ nLinSay  ,aPosGet[1,5] SAY OemToAnsi(STR0014) Of oDlg PIXEL SIZE 45 ,9 //'Nota Fiscal'
	@ nLinSay-2,aPosGet[1,6]	MSGET ocNota VAR cNFiscal Picture PesqPict('SF1','F1_DOC') ;
	When VisualSX3('F1_DOC').and. !l910Visual .and. !lGeraNum Valid A910Fornec(ca100For,cLoja,@aInfForn,cTipo,l910Inclui,c910Form);
	.And.CheckSX3('F1_DOC').and. A910VldNum(cNFiscal) OF oDlg PIXEL SIZE 34 ,9

	@ nLinSay  ,aPosGet[1,7] SAY OemToAnsi(STR0015) Of oDlg PIXEL SIZE 23 ,9 //'Serie'
	@ nLinSay-2,aPosGet[1,8] MSGET ocSerie VAR cSerie  Picture PesqPict('SF1','F1_SERIE') ;
	When VisualSX3('F1_SERIE').and. !l910Visual .and. !lGeraNum Valid A910Fornec(ca100For,cLoja,@aInfForn,cTipo,l910Inclui).And.CheckSX3('F1_SERIE');
	OF oDlg PIXEL SIZE 18 ,9

	nLinSay	+=	20

	@ nLinSay  ,aPosGet[2,1] SAY OemToAnsi(STR0016) Of oDlg PIXEL SIZE 16 ,9 //'Data'
	@ nLinSay-2,aPosGet[2,2]	MSGET odDEmissao VAR dDEmissao Picture PesqPict('SF1','F1_EMISSAO') ;
	When VisualSX3('F1_EMISSAO').and. !l910Visual Valid  A910Emissao(dDEmissao) .And. CheckSX3('F1_EMISSAO')  ;
	OF oDlg PIXEL SIZE 49 ,9

	@ nLinSay  ,aPosGet[2,3] SAY oc910SForn VAR Iif(cTipo$'DB' .And. l910Visual, OemToAnsi(STR0036), c910SForn) Of oDlg PIXEL SIZE 43 ,9
	@ nLinSay-2,aPosGet[2,4] MSGET oc910GForn VAR ca100For  Picture PesqPict('SF1','F1_FORNECE') F3 CpoRetF3('F1_FORNECE');
	When VisualSX3('F1_FORNECE').and. !l910Visual Valid  A910Fornec(ca100For,cLoja,@aInfForn,cTipo,l910Inclui,c910Form).And.CheckSX3('F1_FORNECE',ca100For);
	.And.A910VFold("NF_CODCLIFOR",cA100For) OF oDlg PIXEL SIZE 41 ,9

	@ nLinSay-2  ,aPosGet[2,5] MSGET oc910Loj VAR cLoja  Picture PesqPict('SF1','F1_LOJA') F3 CpoRetF3('F1_LOJA');
	When VisualSX3('F1_LOJA').and. !l910Visual Valid CheckSX3('F1_LOJA',cLoja).and. A910Fornec(ca100For,cLoja,@aInfForn,cTipo,l910Inclui) ;
	.And.A910VFold("NF_LOJA",cLoja) OF oDlg PIXEL SIZE 15 ,9

	@ nLinSay  ,aPosGet[2,6] SAY OemToAnsi(STR0017) Of oDlg PIXEL SIZE 63 ,9 //'Tipo de Documento'
	@ nLinSay-2,aPosGet[2,7] MSGET cEspecie  Picture PesqPict('SF1','F1_ESPECIE') F3 CpoRetF3('F1_ESPECIE');
	When VisualSX3('F1_ESPECIE').and. !l910Visual Valid CheckSX3('F1_ESPECIE',cEspecie) .And. MaFisRef("NF_ESPECIE","MT100",cEspecie) ;
	OF oDlg PIXEL SIZE 30 ,9

	oGetDados	:= MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,'A910LinOk','A910TudOk','+D1_ITEM',.T.,,,,9999,'A910FieldOk',,,'A910Del')
	oGetDados:oBrowse:bGotFocus	:= {||A910CabOk(@oCombo1,@ocNota,@odDEmissao,@oc910GForn,@oc910Loj,l910Visual)}

	//Adiciona bloco de código para atualizar aba de tributos genéricos por item na mudança de linha do item
	If lTrbGen
		oGetDados:oBrowse:bChange := {|| Eval(bTgRefresh)}
	EndIF

	If cPaisLoc == "BRA"
		Aadd(aTitles,OemToAnsi(STR0052)) //"Nota Fiscal Eletrônica"
		nNFe 	:= 	Len(aTitles)

	    aAdd(aTitles,STR0067)	//"Lançamentos da Apuração de ICMS"
	    nLancAp	:=	Len(aTitles)

		Aadd(aTitles,OemToAnsi(STR0069)) //"Infor.DANFE"
		nDanfe 	:= 	Len(aTitles)	

		If lTrbGen
			Aadd(aTitles,STR0083) //"Tributos Genéricos - Por Item"
			nTrbGen	:= Len(aTitles)
		EndIF

	Endif

	oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitles,aPages,oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]*0.29,)
	If lTrbGen
		oFolder:bSetOption := {|nDst| Iif(nDst == nTrbGen, Eval(bTgRefresh),.T.)}
	EndIF

	For ni := 1 to Len(oFolder:aDialogs)
		DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
	Next

	// Tela de Totalizadores

	oFolder:aDialogs[1]:oFont := oDlg:oFont

	@ 06	,aPosGet[3,1] SAY OemToAnsi(STR0018) Of oFolder:aDialogs[1] PIXEL SIZE 55 ,9 // "Valor da Mercadoria"
	@ 05	,aPosGet[3,2] MSGET aObj[1] VAR a910Var[VALMERC] Picture PesqPict('SD1','D1_TOTAL') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

	@ 06	,aPosGet[3,3] SAY OemToAnsi(STR0019) Of oFolder:aDialogs[1] PIXEL SIZE 49 ,9 // "Descontos"
	@ 05	,aPosGet[3,4] MSGET aObj[2] VAR a910Var[VALDESC]  Picture PesqPict('SD1','D1_VALDESC') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

	@ 20 ,aPosGet[3,1] SAY OemToAnsi(STR0020) Of oFolder:aDialogs[1] PIXEL SIZE 45 ,9 // "Valor do Frete"
	@ 19 ,aPosGet[3,2] MSGET aObj[3] VAR a910Var[FRETE]  Picture PesqPict('SD1','D1_TOTAL') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

	@ 20 ,aPosGet[3,3] SAY OemToAnsi(STR0021) Of oFolder:aDialogs[1] PIXEL SIZE 50 ,9 // "Valor do Seguro"
	@ 19 ,aPosGet[3,4] MSGET aObj[4] VAR a910Var[SEGURO]  Picture PesqPict('SD1','D1_TOTAL') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

	@ 34 ,aPosGet[3,3] SAY OemToAnsi(STR0022) Of oFolder:aDialogs[1] PIXEL SIZE 50 ,9  // "Despesas"
	@ 33 ,aPosGet[3,4] MSGET aObj[5] VAR a910Var[VALDESP]  Picture PesqPict('SD1','D1_TOTAL') OF oFolder:aDialogs[1] PIXEL When .F.  SIZE 80 ,9

	@ 50 ,aPosGet[3,3] SAY OemToAnsi(STR0023) Of oFolder:aDialogs[1] PIXEL SIZE 58 ,9 // "Total da Nota"
	@ 49 ,aPosGet[3,4] MSGET aObj[6] VAR a910Var[TOTPED]  Picture PesqPict('SF1','F1_VALBRUT') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

	@ 45 ,003	TO 48 ,aPosGet[3,5] LABEL '' OF oFolder:aDialogs[1] PIXEL

	// Informacoes do Fornecedor

	oFolder:aDialogs[2]:oFont := oDlg:oFont
	@ 06  ,aPosGet[4,1] SAY OemToAnsi(STR0024) Of oFolder:aDialogs[2] PIXEL SIZE 37 ,9 // "Nome"
	@ 05  ,aPosGet[4,2] MSGET aObj[7] VAR aInfForn[1] Picture PesqPict('SA2','A2_NOME');
	When .F. OF oFolder:aDialogs[2] PIXEL SIZE 159,9 
	iif(lLGPD,AnonimoLGPD(aObj[7],'A2_NOME'),.F.)

	@ 6  ,aPosGet[4,3] SAY OemToAnsi(STR0025) Of oFolder:aDialogs[2] PIXEL SIZE 23 ,9 // "Tel."
	@ 5  ,aPosGet[4,4] MSGET aObj[8] VAR aInfForn[2] Picture PesqPict('SA2','A2_TEL');
	When .F. OF oFolder:aDialogs[2] PIXEL SIZE 74 ,9 
	iif(lLGPD,AnonimoLGPD(aObj[8],'A2_TEL'),.F.)

	@ 43 ,aPosGet[5,1] SAY OemToAnsi(STR0026) Of oFolder:aDialogs[2] PIXEL SIZE 32 ,9 // "1a Compra"
	@ 42 ,aPosGet[5,2] MSGET aObj[9] VAR aInfForn[3] Picture PesqPict('SA2','A2_PRICOM') ;
	When .F. OF oFolder:aDialogs[2] PIXEL SIZE 56 ,9 
	iif(lLGPD,AnonimoLGPD(aObj[9],'A2_PRICOM'),.F.)

	@ 43 ,aPosGet[5,3] SAY OemToAnsi(STR0027) Of oFolder:aDialogs[2] PIXEL SIZE 36 ,9 // "Ult. Compra"
	@ 42 ,aPosGet[5,4] MSGET aObj[10] VAR aInfForn[4] Picture PesqPict('SA2','A2_ULTCOM');
	When .F. OF oFolder:aDialogs[2] PIXEL SIZE 56 ,9 
	iif(lLGPD,AnonimoLGPD(aObj[10],'A2_ULTCOM'),.F.)

	@ 24 ,aPosGet[6,1] SAY OemToAnsi(STR0028) Of oFolder:aDialogs[2] PIXEL SIZE 49 ,9 // "Endereco"
	@ 23 ,aPosGet[6,2] MSGET aObj[11] VAR aInfForn[5]  Picture PesqPict('SA2','A2_END');
	When .F. OF oFolder:aDialogs[2] PIXEL SIZE 205,9 
	iif(lLGPD,AnonimoLGPD(aObj[11],'A2_END'),.F.)

	@ 24 ,aPosGet[6,3] SAY OemToAnsi(STR0029) Of oFolder:aDialogs[2] PIXEL SIZE 32 ,9 // "Estado"
	@ 23 ,aPosGet[6,4] MSGET aObj[12] VAR aInfForn[6]  Picture PesqPict('SA2','A2_EST');
	When .F. OF oFolder:aDialogs[2] PIXEL SIZE 21 ,9 
	iif(lLGPD,AnonimoLGPD(aObj[12],'A2_EST'),.F.)

	@ 42 ,aPosGet[6,5] BUTTON OemToAnsi(STR0030) SIZE 40 ,11  FONT oDlg:oFont ACTION A103ToFC030()  OF oFolder:aDialogs[2] PIXEL // "Mais Inf."

	// Frete/Despesas/Descontos

	oFolder:aDialogs[3]:oFont := oDlg:oFont

	@ 09 ,aPosGet[7,1] SAY OemToAnsi(STR0031) Of oFolder:aDialogs[3] PIXEL SIZE 58 ,12 //"Valor do Desconto"
	@ 08 ,aPosGet[7,2] MSGET aObj[13] VAR a910Var[VALDESC]  Picture PesqPict('SD1','D1_VALDESC') OF oFolder:aDialogs[3] PIXEL When !l910Visual  VALID A910VFold("NF_DESCONTO",a910Var[VALDESC]) SIZE 80 ,9

	@ 09 ,aPosGet[7,3] SAY OemToAnsi(STR0032) Of oFolder:aDialogs[3] PIXEL SIZE 58 ,9 //"Valor do Frete"
	@ 08 ,aPosGet[7,4] MSGET aObj[14] VAR a910Var[FRETE]  Picture PesqPict('SD1','D1_VALFRE') OF oFolder:aDialogs[3] PIXEL WHEN !l910Visual VALID A910VFold("NF_FRETE",a910Var[FRETE]) SIZE 80,9

	@ 26 ,aPosGet[7,1] SAY OemToAnsi(STR0033) Of oFolder:aDialogs[3] PIXEL SIZE 42 ,9 // "Despesas"
	@ 25 ,aPosGet[7,2] MSGET aObj[15] VAR a910Var[VALDESP] Picture PesqPict('SD1','D1_DESPESA') OF oFolder:aDialogs[3] PIXEL WHEN !l910Visual VALID A910VFold("NF_DESPESA",a910Var[VALDESP]) SIZE 80,9

	@ 26 ,aPosGet[7,3] SAY OemToAnsi(STR0034) Of oFolder:aDialogs[3] PIXEL SIZE 35 ,9 // "Seguro"
	@ 25 ,aPosGet[7,4] MSGET aObj[16] VAR a910Var[SEGURO]  Picture PesqPict('SD1','D1_SEGURO') OF oFolder:aDialogs[3] PIXEL WHEN !l910Visual VALID A910VFold("NF_SEGURO",a910Var[SEGURO]) SIZE 80,9

	@ 38 ,005  TO 40 ,aPosGet[8,1] LABEL '' OF oFolder:aDialogs[3] PIXEL

	@ 48 ,aPosGet[8,2] SAY OemToAnsi(STR0035) Of oFolder:aDialogs[3] PIXEL SIZE 80 ,9 // "Total ( Frete+Despesas)"
	@ 47 ,aPosGet[8,3] MSGET a910Var[TOTF3]  Picture PesqPict('SD1','D1_VALFRE') OF oFolder:aDialogs[3] PIXEL WHEN .F. SIZE 80,9

	// Impostos

	oFolder:aDialogs[4]:oFont := oDlg:oFont

	aObj[17] := MaFisRodape(1,oFolder:aDialogs[4],,{5,3,aPosGet[8,4],53},bListRefresh,l910Visual)

	oFolder:aDialogs[5]:oFont := oDlg:oFont

	aObj[18] := MaFisBrwLivro(oFolder:aDialogs[5],{5,3,aPosGet[8,4],53},.T.,aRecSF3,l910Visual)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nota Fiscal Eletronica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "BRA"
		Aadd(aObj,Nil)
		oFolder:aDialogs[nNFe]:oFont := oDlg:oFont

		@ 9 ,aPosGet[7,1] SAY OemToAnsi(STR0053) Of oFolder:aDialogs[6] PIXEL SIZE 48 ,12 //"Número"
		@ 8 ,aPosGet[7,2] MSGET aObj[19] VAR aNFEletr[01];
		Picture PesqPict('SF1','F1_NFELETR');
		OF oFolder:aDialogs[6] PIXEL;
		When VisualSX3('F1_NFELETR') .And. !l910Visual;
		VALID CheckSX3("F1_NFELETR",aNFEletr[01]);
		SIZE 80 ,9
		aObj[19]:cSX1Hlp := "F1_NFELETR"

		@ 9 ,aPosGet[7,3] SAY OemToAnsi(STR0056) Of oFolder:aDialogs[6] PIXEL SIZE 48 ,12 //"Cód. verificação"
		@ 8 ,aPosGet[7,4] MSGET aObj[19] VAR aNFEletr[02];
		Picture PesqPict('SF1','F1_CODNFE');
		OF oFolder:aDialogs[6] PIXEL;
		When VisualSX3('F1_CODNFE') .And. !l910Visual;
		VALID CheckSX3("F1_CODNFE",aNFEletr[02]);
		SIZE 80 ,9
		aObj[19]:cSX1Hlp := "F1_CODNFE"

		@ 26 ,aPosGet[7,1] SAY OemToAnsi(STR0054) Of oFolder:aDialogs[6] PIXEL SIZE 48 ,12 //"Emissão"
		@ 25 ,aPosGet[7,2] MSGET aObj[19] VAR aNFEletr[03];
		Picture PesqPict('SF1','F1_EMINFE');
		OF oFolder:aDialogs[6] PIXEL;
		When VisualSX3('F1_EMINFE') .And. !l910Visual;
		VALID A910NFe('EMINFE',aNFEletr) .And. CheckSX3("F1_EMINFE",aNFEletr[03]);
		SIZE 80 ,9
		aObj[19]:cSX1Hlp := "F1_EMINFE"

		@ 26 ,aPosGet[7,3] SAY OemToAnsi(STR0055) Of oFolder:aDialogs[6] PIXEL SIZE 48 ,12 //"Hora da emissão"
		@ 25 ,aPosGet[7,4] MSGET aObj[19] VAR aNFEletr[04];
		Picture PesqPict('SF1','F1_HORNFE');
		OF oFolder:aDialogs[6] PIXEL;
		When VisualSX3('F1_HORNFE') .And. !l910Visual;
		VALID CheckSX3("F1_HORNFE",aNFEletr[04]);
		SIZE 80 ,9
		aObj[19]:cSX1Hlp := "F1_HORNFE"

		@ 43 ,aPosGet[7,1] SAY OemToAnsi(STR0057) Of oFolder:aDialogs[6] PIXEL SIZE 48 ,12 //"Valor Crédito"
		@ 42 ,aPosGet[7,2] MSGET aObj[19] VAR aNFEletr[05];
		Picture PesqPict('SF1','F1_CREDNFE');
		OF oFolder:aDialogs[6] PIXEL;
		When VisualSX3('F1_CREDNFE') .And. !l910Visual;
		VALID A910NFe('CREDNFE',aNFEletr) .And. CheckSX3("F1_CREDNFE",aNFEletr[05]);
		SIZE 80 ,9
		aObj[19]:cSX1Hlp := "F1_CREDNFE"

	    @ 43 ,aPosGet[7,3] SAY OemToAnsi(STR0059) Of oFolder:aDialogs[6] PIXEL SIZE 48 ,12 //"Número RPS"
	    @ 42 ,aPosGet[7,4] MSGET aObj[19] VAR aNFEletr[06];
	    Picture PesqPict('SF1','F1_NUMRPS');
	    OF oFolder:aDialogs[6] PIXEL;
	    When VisualSX3('F1_CREDNFE') .And. !l910Visual;
	    VALID CheckSX3("F1_NUMRPS",aNFEletr[06]);
	    SIZE 80 ,9
	    aObj[19]:cSX1Hlp := "F1_NUMRPS"
	Endif

	// Infor.DANFE
	If cPaisLoc == "BRA"
		Aadd(aObj,Nil)
		nObj1 := Len(aObj)
		oFolder:aDialogs[nDanfe]:oFont := oDlg:oFont

	    @ 9 ,aPosGet[7,1] SAY OemToAnsi(STR0070) Of oFolder:aDialogs[nDanfe] PIXEL SIZE 48 ,12 //"Chave NFE/CTE"
	    @ 8 ,aPosGet[7,2] MSGET aObj[nObj1] VAR aDanfe[01];
	    Picture PesqPict('SF1','F1_CHVNFE');
	    OF oFolder:aDialogs[nDanfe] PIXEL;
	    When VisualSX3('F1_CHVNFE') .And. !l910Visual;
	    VALID CheckSX3("F1_CHVNFE",aDanfe[01]);
	    SIZE 150 ,9 
	    aObj[nObj1]:cSX1Hlp := "F1_CHVNFE"
	 	iif(lLGPD,AnonimoLGPD(aObj[nObj1],'F1_CHVNFE'),.F.)

	    @ 26 ,aPosGet[7,1] SAY OemToAnsi(STR0071) Of oFolder:aDialogs[nDanfe] PIXEL SIZE 48 ,12 //"Tipo Frete"
	    @ 25 ,aPosGet[7,2] MSCOMBOBOX oCombo4 VAR c910Frt ITEMS aCombo4 SIZE 80 ,9 ;
	                        When VisualSX3('F1_TPFRETE') .And. !l910Visual;
	                        VALID Iif(c910Frt==Nil .Or. Alltrim(c910Frt)=="",aCombo4[5],aCombo4[Ascan(aCombo4, {|x| Substr(x,1,1) == Substr(c910Frt,1,1)})]) OF oFolder:aDialogs[nDanfe] PIXEL
	 		 //aObj[nObj1]:cSX1Hlp := "F1_TPFRETE"
	    If l910Inclui
	        cTpFrt := Substr(c910Frt,1,1)
	    Else
	        cTpFrt := SF1->F1_TPFRETE
	    EndIf

	    @ 26 ,aPosGet[7,3] SAY OemToAnsi(STR0072) Of oFolder:aDialogs[nDanfe] PIXEL SIZE 48 ,12 //"Tipo CTE"
	    @ 25 ,aPosGet[7,4] MSCOMBOBOX oCombo3 VAR c910Cte ITEMS aCombo3 SIZE 80 ,9 ;
	                        When VisualSX3('F1_TPCTE') .And. !l910Visual;
	                        VALID Iif(c910Cte==Nil .Or. Alltrim(c910Cte)=="",aCombo3[1],aCombo3[Ascan(aCombo3, {|x| Substr(x,1,1) == Substr(c910Cte,1,1)})]) OF oFolder:aDialogs[nDanfe] PIXEL
	        //aObj[nObj1]:cSX1Hlp := "F1_TPCTE"
	    If l910Inclui
	        cTpCte := Substr(c910Cte,1,1)
	    Else
	        cTpCte := SF1->F1_TPFRETE
	    EndIf
	
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	    //³Total nao agregado ao valor do documento³
	    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If GetNewPar("MV_VNAGREG",.F.)
	        Aadd(aObj,Nil)
	        nObj := Len(aObj)
	        @ 51 ,aPosGet[3,1] SAY OemToAnsi(STR0058) Of oFolder:aDialogs[1] PIXEL SIZE 58 ,9 // "Valor não Agregado"
	        @ 49 ,aPosGet[3,2] MSGET aObj[nObj] VAR a910Var[VNAGREG]  Picture PesqPict('SF1','F1_VNAGREG') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9
	    Endif
	
	EndIf

	If nLancAp>0
		oFolder:aDialogs[nLancAp]:oFont := oDlg:oFont	
		If  FindFunction("a017xLAICMS")
			oLancCDV := a017xLAICMS(oFolder:aDialogs[nLancAp],{5,4,( aPosObj[3,4]-aPosObj[3,2] )-10,53},aHeadCDV,aColsCDV,l910Visual,l910Inclui,"SD1")
		Endif
		oLancApICMS := a103xLAICMS(oFolder:aDialogs[nLancAp],{5,4,( aPosObj[3,4]-aPosObj[3,2] )-10,53},@aHeadCDA,@aColsCDA,l910Visual,l910Inclui)
	EndIf

	//----------------------------------------
	//Folder dos tributos genéricos por item
	//----------------------------------------
	If lTrbGen
		oFolder:aDialogs[nTrbGen]:oFont := oDlg:oFont
		oFisTrbGen := MaFisBrwTG(oFolder:aDialogs[nTrbGen],{5,4,( aPosObj[3,4]-aPosObj[3,2] ) - 10,53}, l910Visual)
	EndIF

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(oGetDados:TudoOk() ,(nOpc:=1,oDlg:End()),nOpc:=0)},{||oDlg:End()},NIL, xButtons )
Else

	nOpc := 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente se for inclusao executa as validacoes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l910Inclui
		aValidGet := {}
		aInfFornAut:= aClone(aInfForn)
		cTipo     := aAutoCab[ProcH("F1_TIPO"),2]
		a910VarAut:= aClone(a910Var)
		aNFeAut   := aClone(aNFEletr)
		aDANAut   := aClone(aDANFE)

		Aadd(aValidGet,{"c910Tipo" ,aAutoCab[ProcH("F1_TIPO"),2]   ,"A910Tipo(cTipo,,,,@ca100For,@cLoja,)",.t.})
		Aadd(aValidGet,{"cNFiscal" ,aAutoCab[ProcH("F1_DOC") ,2]   ,"A910Fornec(ca100For,cLoja,@aInfFornAut,cTipo,l910Inclui)" ,.f.})
		Aadd(aValidGet,{"cSerie"   ,aAutoCab[ProcH("F1_SERIE"),2]  ,"A910Fornec(ca100For,cLoja,@aInfFornAut,cTipo,l910Inclui) .And.CheckSX3('F1_SERIE')",.t.})
		Aadd(aValidGet,{"dDEmissao",aAutoCab[ProcH("F1_EMISSAO"),2],"A910Emissao(dDEmissao) .And. CheckSX3('F1_EMISSAO')",.t.})
		Aadd(aValidGet,{"ca100For" ,aAutoCab[ProcH("F1_FORNECE"),2],"A910Fornec(ca100For,cLoja,@aInfFornAut,cTipo,l910Inclui).And.CheckSX3('F1_FORNECE',ca100For) .And.A910VFold('NF_CODCLIFOR',ca100For)",.t.})
		Aadd(aValidGet,{"cLoja"    ,aAutoCab[ProcH("F1_LOJA"),2]   ,"CheckSX3('F1_LOJA',cLoja).and. A910Fornec(ca100For,cLoja,@aInfFornAut,cTipo,l910Inclui)	.And.A910VFold('NF_LOJA',cLoja)",.t.})
		Aadd(aValidGet,{"cEspecie" ,aAutoCab[ProcH("F1_ESPECIE"),2],"CheckSX3('F1_ESPECIE',cEspecie)",.f.}) 	 

		If !SF1->(MsVldGAuto(aValidGet)) // consiste os gets
			nOpc:= 0
		EndIf

		If !MaFisFound("NF")
			MaFisIni(ca100For,cLoja,If(cTipo$'DB',"C","F"),cTipo,Nil,MaFisRelImp("MT100",{"SF1","SD1"}),,.T.,,,,,,,,,,,,,,,,,dDEmissao,,,,,,,,IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SD1","D1_IDTRIB"), .F.))
		EndIf
		aInfForn := aClone(aInfFornAut)
		a910Var  := aClone(a910VarAut)
		If !MsGetDAuto(aAutoItens,"A910LinOk",{|| A910TudOk()},aAutoCab,aRotina[nOpcx][4])
			nOpc := 0
		EndIf
	EndIf
EndIf

If nOpc == 1 
	aDanfe[2] := Substr(c910Frt,1,1)
	aDanfe[3] := Substr(c910Cte,1,1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada na Exclusao.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l910Deleta .And. ExistBlock("MTA910E")
		ExecBlock("MTA910E",.f.,.f.)
	Endif
	Begin Transaction
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a gravacao da Nota Fiscal (Inclusao/Alteracao/Exclusao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If l910Inclui .Or. l910Altera .Or. l910Deleta
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa a gravacao atraves das funcoes MATXFIS         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisWrite()
		a103GrvCDA(l910Deleta,"E",cEspecie,cFormul,cNFiscal,cSerie,cA100For,cLoja)
		If Type("oLancCDV")=="O" 
			a017GrvCDV(l910Deleta,"E",cEspecie,cFormul,cNFiscal,cSerie,cA100For,cLoja)
		Endif

		If !l910Auto
			Processa({||A910Grava(l910Deleta,aNFEletr,aDanfe,l910Inclui)},cCadastro)
		Else
			A910Grava(l910Deleta,aNFEletr,aDanfe,l910Inclui)
		EndIf

		If l910Deleta
			M926DlSped(1,cNFiscal,cSerId,cA100For,cLoja,"1")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processa os gatilhos                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		EvalTrigger()
	EndIf
	End Transaction
Endif

If Type("lGeraNum") == "L"
	lGeraNum := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza o uso das funcoes MATXFIS                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisEnd()

RestArea(aArea)

Return nOpc

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A910FRefre³ Autor ³ Edson Maricate        ³ Data ³ 10.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa o refresh nos objetos do array.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Array contendo os Objetos                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatA910                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A910FRefresh(aObj)
Local nx

If !l910Auto
	For nx := 1 to Len(aObj)
		aObj[nx]:Refresh()
	Next
EndIf
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A910Refresh³ Autor ³ Edson Maricate       ³ Data ³ 10.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa o Refresh do Folder.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatA910                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function A910Refresh(a910Var,l910Visual,nValBrut)

Local aArea	:= GetArea()
Default l910Visual 	:= .F.
Default nValBrut	:= 0

a910Var[VALMERC]	:= MaFisRet(,"NF_VALMERC")
a910Var[VALDESC]	:= MaFisRet(,"NF_DESCONTO")
a910Var[FRETE]	:= MaFisRet(,"NF_FRETE")
a910Var[TOTPED]	:= MaFisRet(,"NF_TOTAL")
a910Var[SEGURO]	:= MaFisRet(,"NF_SEGURO")
a910Var[VALDESP]	:= MaFisRet(,"NF_DESPESA")
a910Var[TOTF1]	:= a910Var[VALDESP]+a910Var[SEGURO]
a910Var[TOTF3]	:= a910Var[FRETE]+a910Var[SEGURO]+a910Var[VALDESP]
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atraves de parametro, sera exibido ou nao o valor nao agregado ao total do documento de entrada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If GetNewPar("MV_VNAGREG",.F.)
	a910Var[VNAGREG]	:= MaFisRet(,"NF_VNAGREG")
Endif

If l910Visual
	a910Var[TOTPED] := nValBrut
Endif
RestArea(aArea)

Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A910CabOk ³ Autor ³ Edson Maricate        ³ Data ³ 10.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa  as validacoes dos Gets.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatA910                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A910CabOk(oTipo,oNota,oEmis,oForn,oLoja,l910Visual)
Local lRet 	:= .F.

Do Case
	Case Empty(cTipo)
		oTipo:SetFocus()
	Case Empty(cNFiscal) .And. cFormul != "S" .and. !lGeraNum
		oNota:SetFocus()
	Case Empty(dDEmissao)
		oEmis:SetFocus()
	Case Empty(ca100For)
		oForn:SetFocus()
	Case Empty(cLoja)
		oLoja:SetFocus()
	OtherWise
		If !MaFisFound("NF")
			MaFisIni(ca100For,cLoja,If(cTipo$'DB',"C","F"),cTipo,Nil,MaFisRelImp("MT100",{"SF1","SD1"}),,.T.,,,,,,,,,,,,,,,,,dDEmissao,,,,,,,,IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SD1","D1_IDTRIB"), .F.))
			MaFisIniLoad(Len(aCols)) // Carrega aNfItem para tratativa no MATXFIS
		ElseIf !l910Visual
			MaFisAlt("NF_DTEMISS",dDEmissao)
			Eval(bListRefresh)
		EndIf
		lRet := .T.
EndCase

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A910VFold ³ Autor ³ Edson Maricate        ³ Data ³ 10.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Exucuta o calculo de valores para campos Totalizadores.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Referencia ( vide MATXFIS)                         ³±±
±±³          ³ ExpC2 = Valor da Referencia                                ³±±
±±³          ³ ExpL3 = .T./.F.- Executa o Refresh do folder               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Campos Totalizadores do MATA910                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A910VFold(cReferencia,xValor,lRefre)
Local aArea	:= GetArea()

If lRefre==Nil
	lRefre := .T.
EndIf

If MaFisFound("NF") .And. !(MaFisRet(,cReferencia)== xValor)
	MaFisAlt(cReferencia,xValor)
	a910FisToaCols()
	If lRefre
		Eval(bRefresh)
		Eval(bGDRefresh)
	EndIf
EndIf

RestArea(aArea)
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A910FieldOk ³Autor³ Edson Maricate        ³ Data ³06.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validade de campo da GateDados.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA910                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A910FieldOk()
Eval(bRefresh)
Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ A910Del  ³ Autor ³ Aline Correa do Vale  ³ Data ³ 26.11.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica a delecao da linha                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Objeto a ser verificado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MatA910                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A910Del(o)
Local nPosCalc  := 0
Local nPosIt	:= 0
Local nPosItD1	:= aScan(aHeader,{|aX| aX[2]==PadR("D1_ITEM",Len(SX3->X3_CAMPO))})
Local nPosCod	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD" })
Local nI		:=	0

If !Empty(aCols[n][nPosCod])
	 MaFisDel(n,aCols[n][Len(aCols[n])])
	 Eval(bRefresh)
EndIf

If Type("oLancApICMS")<>"U" .And. oLancApICMS<>Nil
	nPosCalc:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CALPRO"})
	nPosIt	:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_NUMITE"})
	For nI := 1 To Len(oLancApICMS:aCols)
		If aCols[n,nPosItD1]==oLancApICMS:aCols[nI,nPosIt]
			oLancApICMS:aCols[nI,Len(oLancApICMS:aCols[nI])]	:=	aCols[n,Len(aCols[n])]
		EndIf
	Next nI
	oLancApICMS:Refresh()
EndIf


If Type("oLancCDV")<>"U" .And. oLancCDV<>Nil .And. nPosItD1>0
	nPosCalc:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_AUTO"})
	nPosIt	:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_NUMITE"})
	For nI := 1 To Len(oLancCDV:aCols)
		If aCols[n,nPosItD1]==oLancCDV:aCols[nI,nPosIt]
			oLancCDV:aCols[nI,Len(oLancCDV:aCols[nI])]	:=	aCols[n,Len(aCols[n])]
		EndIf
	Next nI
	oLancCDV:Refresh()
EndIf


Return .T.
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A910LinOk³Autor³ Edson ; Andreia          ³ Data ³06.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validade da linha da GatDados.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA910                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A910LinOk()
Local lRet 		:= .T.
Local nPosCod	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_COD" })
Local nPosQuant:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_QUANT"})
Local nPosUnit	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_VUNIT"})
Local nPosTotal:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_TOTAL"})
Local nPosTES	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_TES"})
Local nPosCF	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_CF"})
Local nPosOri	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_NFORI"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a linha nao esta em branco e os itens nao Deletados   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If CheckCols(n,aCols) .And. !aCols[n][Len(aHeader)+1]
	Do Case
		Case Empty(aCols[n][nPosCod]) 	.Or. ;
			(Empty(aCols[n][nPosQuant]).And.cTipo$"NDB").Or. ;
			 Empty(aCols[n][nPosUnit]) 	.Or. ;
			 Empty(aCols[n][nPosTotal]) 	.Or. ;
			 Empty(aCols[n][nPosCF])   	.Or. ;
			 Empty(aCols[n][nPosTES])      .Or. ;
			 Empty(aCols[n][nPosCF])
				Help("  ",1,"A100VZ")
				lRet := .F.
		Case cTipo $"CPI" .And. Empty(aCols[n][nPosOri])
				HELP(" ",1,"A910COMPIP")
				lRet := .F.
		case cTipo=="D" .And.Empty(aCols[n][nPosOri])
				HELP(" ",1,"A910NFORI")
				lRet := .F.
		Case cTipo$'NDB' .And. (aCols[n][nPosTotal]>(aCols[n][nPosUnit]*aCols[n][nPosQuant]+0.09);
				.Or. aCols[n][nPosTotal]<(aCols[n][nPosUnit]*aCols[n][nPosQuant]-0.09))
				Help("  ",1,'A12003')
				lRet := .F.
		EndCase
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pontos de Entrada 							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (ExistBlock("MT910LOK"))
	lRet := ExecBlock("MT910LOK",.F.,.F.,{lRet})
EndIf

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A910TudOk³Autor³ Edson ; Andreia          ³ Data ³06.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Validade TudOk da GetDados.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA910                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A910Tudok()
Local lRet   := .T.
Local nItens := 0
Local nx     := 0
Local cChvEspe := SuperGetMV( "MV_CHVESPE" , .F. , "" )

If Empty(ca100For) .Or. Empty(dDEmissao) .Or. Empty(cTipo) .Or. (Empty(cNFiscal) .and. !lGeraNum)
	Help(" ",1,"A100FALTA")
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para validar o cabecalho da Nota de Entrada ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ExistBlock("MAT910OK")
	lRet := ExecBlock("MAT910OK",.F., .F., {dDEmissao, cTipo, cNFiscal, cEspecie, cA100For, cLoja})
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impede a inclusao de documentos sem nenhum item ativo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nx:=1 to len(aCols)
	If !aCols[nx][Len(aCols[nx])]
		nItens ++
	Endif
Next

If nItens == 0
	Help("  ",1,"A100VZ")
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o Registro esta Bloqueado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	If cTipo$"DB"
		dbSelectArea("SA1")
		dbSetOrder(1)
		If MsSeek(xFilial("SA1")+ca100For+cLoja)
			If !RegistroOk("SA1")
				lRet := .F.
			EndIf
		Endif
	Else
		dbSelectArea("SA2")
		dbSetOrder(1)
		If MsSeek(xFilial("SA2")+ca100For+cLoja)
			If !RegistroOk("SA2")
				lRet := .F.
			EndIf
		Endif
	Endif
Endif

//Caso lRet já esteja com .F., então não realizará a validação da função A910Nota.
If lRet
	lRet := A910Nota(cNFiscal,cSerie,cEspecie,dDEmissao,ca100For,cLoja,cFormul)
EndIF

If lRet
	If SF1->(FieldPos("F1_CHVNFE"))>0
		If Empty(aDanfe[01]) .And. Alltrim(cEspecie)$StrTran(cChvEspe,',','|') .And. cFormul$" N"
    		Alert("O campo F1_CHVNFE é de preenchimento obrigatório, para a especie informada.")
    		lRet := .F.
    	EndIf
   Endif
EndIf

Return lRet
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a910FisToaCols³ Autor ³ Edson Maricate    ³ Data ³ 01.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza o aCols com os valores da funcao fiscal.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA910                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A910FisToaCols()

Local nx,ny
Local cValid
Local nPosRef

For ny := 1 to Len(aCols)
	For nx	:= 1 to Len(aHeader)
		cValid	:= AllTrim(UPPER(aHeader[nx][6]))
		If "MAFISREF"$cValid
			nPosRef := AT('MAFISREF("',cValid) + 10
			cRefCols:=Substr(cValid,nPosRef,AT('","MT100",',cValid)-nPosRef )
			If MaFisFound("IT",ny)
				aCols[ny][nx]:= MaFisRet(ny,cRefCols)
			EndIf
		EndIf
	Next
Next

Return .T.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a910Tipo³ Autor ³ Edson Maricate          ³ Data ³ 01.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do Tipo de Nota.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA910 : Campo F1_TIPO                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A910Tipo(cTipo,oSForn,cSForn,oGForn,cFornece,cLoja,oLoja)
Local nPosTES	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D1_TES"})
Local nx
Local nY
If cTipo$'DB'
	If Type("l910Auto") != "L" .or. !l910Auto
		oGForn:cF3 	:= 'SA1'
	EndIf
	cSForn		:= OemToAnsi(STR0036) //Cliente
	If MaFisFound("NF") .And. MaFisRet(,"NF_TIPONF") != cTipo
		cFornece		:= CriaVar("F1_FORNECE")
		cLoja			:= CriaVar("F1_LOJA")
	EndIf
Else
	If Type("l910Auto") != "L" .or. !l910Auto
		oGForn:cF3 	:= 'FOR'
	EndIf
	cSForn		:= OemToAnsi(STR0037)     //Fornecedor
	If MaFisFound("NF") .And. MaFisRet(,"NF_TIPONF") != cTipo
		cFornece		:= CriaVar("F1_FORNECE")
		cLoja			:= CriaVar("F1_LOJA")
	EndIf
EndIf

If MaFisFound("NF") .And. cTipo!= MafisRet(,"NF_TIPONF")
	aCols			:= {}
	aADD(aCols,Array(Len(aHeader)+1))
	For ny := 1 to Len(aHeader)
		If Trim(aHeader[ny][2]) == "D1_ITEM"
			aCols[1][ny] 	:= StrZero(1,Len(SD1->D1_ITEM))
		ElseIf ( aHeader[ny][10] != "V")
			aCols[1][ny] := CriaVar(aHeader[ny][2])
		EndIf
		aCols[1][Len(aHeader)+1] := .F.
	Next ny
	MaFisAlt("NF_CLIFOR",If(cTipo$"DB","C","F"))
	MaFisAlt("NF_TIPONF",cTipo)
	MaFisClear()
	oSForn:Refresh()
	oGForn:Refresh()
	oLoja:Refresh()
	Eval(bGDRefresh)
	Eval(bRefresh)
EndIf

Return .T.
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a910Emissao³ Autor ³ Edson Maricate       ³ Data ³ 01.02.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao do Tipo de Nota.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA910 : Campo F1_EMISSAO                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A910Emissao(dEmissao)
Local lRet	:= .T.

If dEmissao > dDataBase
	lRet := .F.
	HELP("  ",1,"A100DATAM")
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³MATA910   ºAutor  ³Andreia dos Santos  º Data ³  21/01/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA910 Campo: Formulario proprio	                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A910Formul(cFormul,cNota,cSerie,oNFiscal,oSerie)
Local lRet := .T.

If cFormul == "S"
	cNota		:= CriaVar("F1_DOC")
	cSerie  	:= CriaVar("F1_SERIE")
   oNFiscal:Refresh()
   oSerie:Refresh()
ElseIf cFormul == "N"
	lGeraNum := .F.
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³A910FornecºAutor  ³Andreia dos Santos  º Data ³  21/01/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Carrega os dados do Fornecedor/Cliente                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Mata910 Campo: Fornecedor		                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A910Fornec(cFornece,cLojaFor,aInfForn,cTipo,l910Inclui,cForm)

Local aAreaSF1 := SF1->(GetArea())
Local lRet := .T.

//PE para verificar se a NF foi cancelada
if l910Inclui
   if ExistBlock("MTVALNF")
      if !ExecBlock("MTVALNF",.F.,.F.,{"SF1",xFilial(),cNFiscal,cSerie,cFornece,cLojaFor})
         Return .F.
      endif
   endif
endif

IF !Empty(cFornece)
	If cTipo$"DB"
		dbSelectArea("SA1")
		dbSetOrder(1)
		IF !Empty(cLojaFor)
			lRet := SA1->(dbSeek(xFilial("SA1")+cFornece+cLojaFor))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o array que contem os dados do Fornecedor      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				aInfForn[1]	:= SA1->A1_NOME						// Nome
				aInfForn[2]	:= SA1->A1_TEL 						// Telefone
				aInfForn[3]	:= SA1->A1_PRICOM	    				//Primeira Compra do Cliente
				aInfForn[4]	:= SA1->A1_ULTCOM      				//Ultima Compra do Cliente
				aInfForn[5]	:= SA1->A1_END+" - "+SA1->A1_MUN //Endereco
				aInfForn[6]	:= SA1->A1_EST         			  //Estado
			EndIf
		Else
			lRet 	:= SA1->(dbSeek(xFilial("SA1")+cFornece))
			If lRet
				cLoja := SA1->A1_LOJA
			Endif
		EndIf
	Else
		dbSelectArea("SA2")
		dbSetOrder(1)
		IF !Empty(cLojaFor)
			lRet := SA2->(dbSeek(xFilial("SA2")+cFornece+cLojaFor))
			If lRet
				aInfForn[1]	:= SA2->A2_NOME						// Nome
				aInfForn[2]	:= SA2->A2_TEL 						// Telefone
				aInfForn[3]	:= SA2->A2_PRICOM	    				//Primeira Compra
				aInfForn[4]	:= SA2->A2_ULTCOM      				//Ultima Compra
				aInfForn[5]	:= SA2->A2_END+" - "+SA2->A2_MUN		//Endereco
				aInfForn[6]	:= SA2->A2_EST         				//Estado
			EndIf
		Else
			lRet := SA2->(dbSeek(xFilial("SA2")+cFornece))
			If lRet
				cLoja := SA2->A2_LOJA
			Endif
		Endif
	EndIf
EndIF

RestArea(aAreaSF1)

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a910Grava ³ Autor ³ Andreia dos Santos       ³ Data ³         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Critica se a linha digitada esta ok                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata910                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A910Grava(lDeleta,aNFEletr,aDanfe,l910Inclui)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definine variaveis                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nX       := 0
Local nY       := 0
Local nDedICMS := 0
Local aHorario := {}
Local cHoraRMT := SuperGetMv("MV_HORARMT",.F.,"2")	//Horário gravado nos campos F1_HORA/F2_HORA.
													//1=Horario do SmartClient; 2=Horario do servidor;
													//3=Fuso horário da filial corrente;
Local lMvAtuComp := SuperGetMV("MV_ATUCOMP",,.F.)
Local cArqCtb	 := ""
Local nHdlPrv	 := 0
Local nTotalCtb	 := 0
Local aRecOri    := {}
Local cLancPad	 := "6A8" // Cancelamento de Notas Fiscais Manuais
Local lLancPad	 := VerPadrao(cLancPad)	
Local cAuxCod	 := ""
Local lExibCtb   := Iif(MV_PAR01 == 1, .T., .F.)
Local lAglutCtb  := Iif(MV_PAR02 == 1, .T., .F.) 
Local lTrbGen 	 := IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SD1","D1_IDTRIB"), .F.)
Local nTrbGen	 := 0
Local aFlagCTB   := {}

Default aNfEletr := {}
Default aDanfe   := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no fornecedor escolhido                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipo$"DB"
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial()+ca100For+cLoja)
Else
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial()+ca100For+cLoja)
EndIf

If Type("l910Auto") != "L" .or. !l910Auto
	ProcRegua(Len(aCols)+1)
EndIf

If !lDeleta
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza dados padroes do cabecalho da NF de entrada.        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF1")
	dbSetOrder(1)
	RecLock("SF1",.T.)
	SF1->F1_FILIAL	:= xFilial("SF1")
	SF1->F1_DOC		:= cNFiscal
	SF1->F1_STATUS	:= 'A'
//	SF1->F1_SERIE	:= cSerie
	SerieNfId("SF1",1,"F1_SERIE",dDEmissao,cEspecie,cSerie)
	SF1->F1_FORNECE	:= ca100For
	SF1->F1_LOJA	:= cLoja
	SF1->F1_EMISSAO	:= dDEmissao
	SF1->F1_EST		:= IIF(cTipo$"DB",SA1->A1_EST,SA2->A2_EST)
	SF1->F1_TIPO	:= cTipo
	SF1->F1_DTDIGIT	:= dDataBase
	SF1->F1_RECBMTO	:= If(Empty(SF1->F1_DTDIGIT),dDataBase,SF1->F1_DTDIGIT)
	SF1->F1_FORMUL	:= IIf(cFormul=="S","S"," ")
	SF1->F1_ESPECIE	:= cEspecie
	SF1->F1_ORIGLAN	:= "LF"

	If SuperGetMv("MV_HORANFE",.F.,.F.) .And. Empty(SF1->F1_HORA)
		//Parametro MV_HORARMT habilitado pega a hora do smartclient, caso contrario a hora do servidor
		If cHoraRMT == '1' //Horario do SmartClient
			SF1->F1_HORA := GetRmtTime()
		ElseIf cHoraRMT == '2' //Horario do servidor 
			SF1->F1_HORA := Time()
		ElseIf cHoraRMT =='3' //Horario de acordo com o estado da filial corrente			
			aHorario := A103HORA()
			If !Empty(aHorario[2])
				SF1->F1_HORA := aHorario[2]
			EndIf
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nota Fiscal Eletronica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "BRA"
		SF1->F1_NFELETR	:= aNFEletr[01]
		SF1->F1_CODNFE	:= aNFEletr[02]
		SF1->F1_EMINFE	:= aNFEletr[03]
		SF1->F1_HORNFE	:= aNFEletr[04]
		SF1->F1_CREDNFE	:= aNFEletr[05]
		SF1->F1_NUMRPS	:= aNFEletr[06]
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Informações DANFE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "BRA"
		SF1->F1_CHVNFE	:= aDanfe[01]
		SF1->F1_TPFRETE	:= aDanfe[02]
		If Alltrim(SF1->F1_ESPECIE)=="CTE"
			SF1->F1_TPCTE	:= aDanfe[03]
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua a gravacao dos campos referentes ao imposto   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisWrite(2,"SF1",Nil)
	
	//Gravação do campo F1_IDNF
	IF SF1->(FieldPos('F1_IDNF')) > 0
		SF1->F1_IDNF := FWUUID("SF1")
	EndIf

	SF1->(FKCommit())
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza dados padroes dos itens da NF de entrada.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	dbSetOrder(1)

	If Type("l910Auto") != "L" .or. !l910Auto
		IncProc()
	EndIf

	For nx := 1 to Len(aCols)
		If !aCols[nx][Len(aCols[nx])]
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza dados do corpo da nota selecionados pelo cliente   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			RecLock("SD1",.T.)
			For ny := 1 to Len(aHeader)
				If aHeader[ny][10] # "V"
					SD1->(FieldPut(FieldPos(Trim(aHeader[ny][2])),aCols[nx][ny]))
				Endif
			Next ny
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial()+SD1->D1_COD)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza dados padroes do corpo da nota fiscal de entrada    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SD1->D1_FILIAL	:= xFilial("SD1")
			SD1->D1_FORNECE	:= cA100For
			SD1->D1_LOJA	:= cLoja
			SD1->D1_DOC		:= cNFiscal
//			SD1->D1_SERIE	:= cSerie
			SerieNfId("SD1",1,"D1_SERIE",dDEmissao,cEspecie,cSerie)
			SD1->D1_EMISSAO	:= dDEmissao
			SD1->D1_DTDIGIT	:= dDataBase
			SD1->D1_GRUPO	:= SB1->B1_GRUPO
			SD1->D1_TIPO	:= cTipo
			SD1->D1_TP		:= SB1->B1_TIPO
			SD1->D1_NUMSEQ	:= ProxNum()
			SD1->D1_FORMUL	:= If(cFormul=="S","S"," ")
			SD1->D1_ORIGLAN := "LF"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Efetua a gravacao dos campos referentes ao imposto   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisWrite(2,"SD1",nx)

			//Faz chamada para gravação dos tributos genéricos na tabela F2D, bem como o ID do tributo na SD2.
			IF lTrbGen
				SD1->D1_IDTRIB	:= MaFisTG(1,"SD1",nx)
			EndIF
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desconta o Valor do ICMS DESONERADO do valor do Item D1_VUNIT          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES))
		If SF4->F4_AGREG$"R"
			nDedICMS += MaFisRet(nX,"IT_DEDICM")
			SD1->D1_TOTAL -= MaFisRet(nX,"IT_DEDICM")
			SD1->D1_VUNIT := A410Arred(SD1->D1_TOTAL/IIf(SD1->D1_QUANT==0,1,SD1->D1_QUANT),"D1_VUNIT")
		EndIf

		If Type("l910Auto") != "L" .or. !l910Auto
			IncProc()
		EndIf
	Next nx

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desconta o Valor do ICMS DESONERADO do valor do Item D1_VUNIT          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nDedICMS > 0
		SF1->F1_VALMERC -= nDedICMS
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza dados dos complementos SPED automaticamente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMvAtuComp .And. l910Inclui
		AtuComp(cNFiscal,SF1->F1_SERIE,cEspecie,cA100For,cLoja,"E",cTipo)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava arquivo de Livros Fiscais (SF3)                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisAtuSF3(1,"E",SF1->(RecNo()))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada na Inclusao.                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("MTA910I")
		ExecBlock("MTA910I",.f.,.f.)
	Endif

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lançamento contábil de exclusão da nota fiscal           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SF1->F1_DTLANC) .And. cPaisLoc == "BRA" .And. lLancPad .And. CanProcItvl(SF1->F1_DTLANC, SF1->F1_DTLANC,cFilAnt,cFilAnt,"MATA910")
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Encontra o numero do lote					  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SX5->( dbSeek(xFilial("SX5")+"09"+"FIS") )
			cLoteCtb := StrZero(INT(VAL(X5Descri())+1),4)
		Else
			cLoteCtb:="0001"
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa o arquivo de contabilizacao. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nHdlPrv := HeadProva(cLoteCtb,"MATA910",cUserName,@cArqCtb)
		If nHdlPrv <= 0
			HELP(" ",1,"SEM_LANC")
		EndIf

		aAdd(aFlagCTB,{"F1_DTLANC",dDatabase,"SF1",SF1->(Recno()),0,0,0})
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Contabilizacao do Lancamento de Exclusão da Nota. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 		
		nTotalCtb += DetProva(nHdlPrv,cLancPad,"MATA910",cLoteCtb,,,,,@cAuxCod,@aRecOri,,@aFlagCTB)
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia a Contabilizacao do Lancamento de Exclusão da Nota. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
		If nTotalCtb > 0  
			RodaProva(nHdlPrv,nTotalCtb)
			cA100Incl(cArqCtb,nHdlPrv,1,cLoteCtb,lExibCtb,lAglutCtb,,,,aFlagCTB)
		EndIf
		FreeProcItvl("MATA910")
		
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o Registro de Livros Fiscais ( SF3 )              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisAtuSF3(2,"E",SF1->(RecNo()))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Itens das NF's de entradas.                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial()+cNFiscal+cSerie+ca100For+cLoja)

	While !Eof() .And. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == ;
						xFilial()+cNFiscal+cSerie+ca100For+cLoja

		//Faz chamada para exclusão dos tributos genéricos.
		IF lTrbGen .AND. !Empty(D1_IDTRIB)
			MaFisTG(2,,,D1_IDTRIB)
		EndIF
		
		RecLock("SD1",.F.,.T.)
		dbDelete()
		MsUnLock()
		dbSkip()
		If Type("l910Auto") != "L" .or. !l910Auto
			IncProc()
		EndIF
	EndDo
	SD1->(FKCommit())
	If Type("l910Auto") != "L" .or. !l910Auto
		IncProc()
	EndIF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui a amarracao com os conhecimentos                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsDocument( "SF1", SF1->( RecNo() ), 2, , 3 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cabecalho das notas de entrada.                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF1")
	RecLock("SF1",.F.,.T.)

	SF1->(dbDelete())
	SF1->(MsUnlock())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Integracao NATIVA PROTHEUS x TAF.									       	     ³
	//³	Ao Excluir uma Nota Fiscal de Terceiros no Protheus a TAFInOnLn() exclui         ³
	//³ esta nota diretamente no TAF caso a mesma tenha sido importada pela intergacao   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF1->F1_FORMUL <> "S" .And. SFT->(FieldPos("FT_TAFKEY")) > 0 .And. ;
		FindFunction("TAFExstInt").And. TAFExstInt()  .And. ;
		FindFunction("TAFVldAmb") .And. TAFVldAmb("1")    

		aAreaAnt := GetArea()
		dbUseArea( .T.,"TOPCONN","TAFST1","TAFST1",.T.,.F.)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Deleta a nota da tabela TAFST1 caso o usuario esteja excluindo ³
		//³a Nota antes do JOB ter integrado a nota no TAF,evitando que a ³
		//³nota possa ser integrada apos excluida no Protheus.            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SELECT("TAFST1") > 0
			
			cQuery := "DELETE FROM TAFST1 WHERE "
			cQuery += "TAFFIL    = '"+ allTrim( cEmpAnt ) + allTrim( cFilAnt ) + "' AND "
			cQuery += "TAFTPREG  = 'T013' AND "
			cQuery += "TAFSTATUS = '1'    AND "
			cQuery += "TAFKEY    = '" + xFilial("SF1")+"E"+SF1->F1_SERIE+SF1->F1_DOC+SF1->F1_FORNECE+SF1->F1_LOJA +"'"
			TcSqlExec(cQuery)

			TAFST1->(dbCloseArea())
			
		EndIf
		
		RestArea(aAreaAnt)
		
		TAFIntOnLn( "T013" , 5 , cEmpAnt+cFilAnt )
		
	Endif


EndIf

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A910Combo³Autor³ Edson Maricate           ³ Data ³06.01.2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida o Combo Box e inicializa a variavel correspondente.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1	: Variavel a ser atualizada                          ³±±
±±³          ³ExpA2	: Array contendo as opcoes do Combo                  ³±±
±±³          ³ExpC3	: Opcao selecionada no Combo                         ³±±
±±³          ³ExpA4	: Array contendo as referencias das opcoes do combo  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATA103                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A910Combo(cVariavel,aCombo,cCombo,aReferencia)

Local nPos	:= aScan(aCombo,cCombo)

If nPos > 0
	cVariavel	:= aReferencia[nPos]
EndIf


Return (nPos>0)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³a910conhec³ Autor ³Sergio Silveira        ³ Data ³15/08/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada da visualizacao do banco de conhecimento            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³a910conhec()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function a910conhec()

Local aRotBack := AClone( aRotina )
Local nBack    := N

Private aRotina := {}

Aadd(aRotina,{STR0048,"MsDocument", 0 , 2}) //"Conhecimento"

MsDocument( "SF1", SF1->( Recno() ), 1 )

aRotina := AClone( aRotBack )
N := nBack

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A910Docume³ Autor ³Sergio Silveira        ³ Data ³15/08/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada da rotina de amarracao do banco de conhecimento     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A910Docume()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function A910Docume( cAlias, nRec, nOpc )

Local aArea    := GetArea()
Local xRet

SD1->( MsGoto( nRec ) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Posiciona no SF1 a partir do SD1                             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SF1->( dbSetOrder( 1 ) )

If SF1->( MsSeek( xFilial( "SF1" ) + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA  ) )
	xRet := MsDocument( "SF1", SF1->( Recno() ), nOpc )
EndIf

RestArea( aArea )

Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A910NFe   ³ Autor ³Mary C. Hergert        ³ Data ³29/06/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida campos da Nota Fiscal Eletronica de Sao Paulo        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A910NFe(cExp01,aExp01)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExp01: Campo a ser validado                                ³±±
±±³          ³aExp01: Array com as variaveis de memoria                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A910NFe(cCampo,aNFEletr)

Local lRet := .T.

If cPaisLoc == "BRA"
	If cCampo == "EMINFE"
		If !Empty(aNFEletr[03]) .And. aNFEletr[03] < dDEmissao
			Help("",1,"A100NFEDT")
			lRet := .F.
		Endif
	ElseIf cCampo == "CREDNFE"
		If aNFEletr[05] < 0
			Help("",1,"A100NFECR")
			lRet := .F.
		Endif
	Endif
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ANFMLegenda³ Autor ³ Liber de Esteban     ³ Data ³ 24/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA910/MATA920                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ANFMLegenda()
Local aLegenda := {}

aAdd(aLegenda,{"DISABLE"   ,STR0061}) //"Docto. Normal"
aAdd(aLegenda,{"BR_AZUL"   ,STR0062}) //"Docto. de Compl. IPI"
aAdd(aLegenda,{"BR_MARROM" ,STR0063}) //"Docto. de Compl. ICMS"
aAdd(aLegenda,{"BR_PINK"   ,STR0064}) //"Docto. de Compl. Preco/Frete"
aAdd(aLegenda,{"BR_CINZA"  ,STR0065}) //"Docto. de Beneficiamento"
aAdd(aLegenda,{"BR_AMARELO",STR0066}) //"Docto. de Devolucao"

BrwLegenda(cCadastro,STR0060,aLegenda) //"Legenda"

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()

Private	aRotina := {	{ STR0001 ,"AxPesqui"  	,0,1,0,.F.},;	//"Pesquisar"
								{ STR0002 ,"a910NFiscal",0,2,0,NIL},;	//"Visualizar"
								{ STR0003 ,"a910NFiscal",0,3,0,NIL},;	//"Incluir"
								{ STR0004 ,"a910NFiscal",0,5,0,NIL}}    //"Excluir"

Aadd(aRotina,{STR0049,"a910Docume",0,4,0,NIL}) //"Conhecimento"

aAdd(aRotina,{STR0068,"a910Compl",0,4,0,NIL}) //"Complementos"	

aAdd(aRotina,{STR0060,"ANFMLegenda",0,2,0,.F.}) //"Legenda"

If ExistBlock("MT910MNU")
	ExecBlock("MT910MNU",.F.,.F.)
EndIf

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³a910Compl ºAutor  ³Mary C. Hergert     º Data ³  05/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Executa a rotina de complementos do documento fiscal        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Mata910                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function a910Compl()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a especie do documento³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SF1->(dbSetOrder(1))
SF1->(dbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))

Mata926(SD1->D1_DOC,SD1->D1_SERIE,SF1->F1_ESPECIE,SD1->D1_FORNECE,SD1->D1_LOJA,"E",SD1->D1_TIPO,SD1->D1_CF)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³a910Nota³ Autor ³ Fabio V Santana         ³ Data ³ 19.03.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida o Numero da Nota Fiscal Digitado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA910 					                               		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A910Nota(cNota,cSerie,cEspecie,dDataEmis,cFornece,cLojaFor,cFormul)

Local lRet := .T.
Local lUsaNewKey  := TamSX3("F1_SERIE")[1] == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso
Local cSerId    := IIf( lUsaNewKey , SerieNfId("SF1",4,"F1_SERIE",dDataEmis,cEspecie,cSerie) , cSerie )

IF Empty(cNFiscal) .and. lGeraNum
	lRet := a910NextDoc()
	IF !lRet
		HELP(" ",1,"F1_DOC")
	EndIf
ENDIF

If lRet
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Consiste duplicidade de digitacao de Nota Fiscal  			        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SF1->(dbSeek(xFilial("SF1")+cNFiscal+cSerId)) .And. Inclui
		If !(SF1->(dbSeek(xFilial("SF1")+cNFiscal+cSerId+cFornece+cLojaFor)))
			If cFormul $ "S"
				If !(MsgYesNo("Existe Nota Fiscal com esta numeração para outro fornecedor, deseja continuar ? ","Inclui NF ?"))
					cNFiscal := CriaVar("F1_DOC")
					cSerie   := CriaVar("F1_SERIE")
					lRet := .F.
				EndIf	
			EndIf
		Else
			HELP(" ",1,"EXISTNF")
			If !(cFormul $ "S")
				lRet := .F.
			Else
				If (MsgYesNo("Deseja selecionar o próximo número para a Nota ? ","Inclui NF ?"))
					lRet := a910NextDoc()
				Else
					lRet := .F.
				EndIf
			EndIf
		EndIF
	Endif

EndIf

Return lRet

/*/{Protheus.doc} a910NextDoc()
@description
Funcao responsavel por retornar o numero da proxima nota
quando o usuario nao digitar.
@author yuri.gimenes by MATA920
@since 19/05/2021
@version 12
/*/
Static Function a910NextDoc()

Local aArea	   := GetArea()
Local cTipoNf  := SuperGetMv("MV_TPNRNFS")
Local lRet    := .F.
Local cNSerie  := cSerie


Private cNumero := "" // Precisa ser private com este nome - Funcao Sx5NumNota.
Private lMudouNum := .F. // Precisa ser private com este nome - Funcao Sx5NumNota.

lRet := Sx5NumNota(@cNSerie, cTipoNf)

If lRet

	// Numeracao via SX5 ou SXE/SXF
	If cTipoNf $ "1|2"
				
		// Apenas via SX5 pois com XE/XF o usuario nao consegue confirmar a selecao da serie se o documento ja existir.
		If cTipoNf == "1"
			SF1->(dbSetOrder(1))
			If SF1->(MsSeek(xFilial("SF1") + PADR(cNumero, TamSx3("F1_DOC")[1]) + cNSerie + ca100For + cLoja))
				MsgAlert("Este número de documento já foi utilizado." + Chr(13) + Chr(10) + "Digite um número válido.")				
				lRet := .F.
			EndIf
		EndIf
		
		// lMudouNum sera .T. quando utilizar XE/XF e o usuario alterar a numeracao na tela.
		// Neste caso devo respeitar o numero digitado. No entando a proxima numeração seguirá
		// a sequencia normal.
		If !lMudouNum
			cNumero := NxtSX5Nota(cNSerie, NIL, cTipoNf)
		EndIf
		
		cNFiscal  := cNumero
		cSerie	  := cNSerie
			
	// Numeracao via SD9
	ElseIf cTipoNf == "3" .And. AliasIndic("SD9")
	 
		cNFiscal := MA461NumNf(.T., cNSerie)
		cSerie := cNSerie
		
	EndIf

EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} A910VldNum()
@description
Funcao responsavel por validar se a numeracao automatica deve ou ser gerada.
@author yuri.gimenes by MATA920
@since 19/05/2021
@version 12
/*/
Function A910VldNum(c910Nota)

Local lRet := .T.

If cPaisLoc == "BRA" .And. Empty(c910Nota) .AND. cFormul =='S'

	lRet := lGeraNum := MsgYesNo("Deixar o número do documento em branco indica que será solicitada uma série no momento da gravação e o número será sugerido pelo sistema." + Chr(13) + Chr(10) + ;								
								 "Deseja continuar?", "Numeração Automática")

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg
 
Função que irá criar O SX1 complementar.
 
@author Eduardo Vicente da Silva
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

Static Function ValidPerg(cPerg)

If FindFunction("EngSX1117")
	EngSX1117( cPerg, "01", "Mostra Lancto Contábil", "Mostra Lancto Contábil", "Mostra Lancto Contábil",       "MV_CH1", "C", 1, 0,,"C",,,,,"MV_PAR01","Sim","Sim","Sim",,"Não","Não","Não",,,,,,,,,,{"Informa se deseja mostrar a tela de lançamento contábil."},{},{},)
	EngSX1117( cPerg, "02", "Aglutina Lancto Contábil", "Aglutina Lancto Contábil", "Aglutina Lancto Contábil", "MV_CH2", "C", 1, 0,,"C",,,,,"MV_PAR02","Sim","Sim","Sim",,"Não","Não","Não",,,,,,,,,,{"Informa se deseja aglutinar os lançamentos contábeis."},{},{},)
EndIf

Return

Static Function ProcH(cCampo)
Return aScan(aAutoCab,{|x|Trim(x[1])== cCampo }) 
