#INCLUDE "PROTHEUS.CH"
#INCLUDE "HSPAHR71.CH"
#INCLUDE "TOPCONN.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณ HSPAHR71 บ Autor ณ Rodrigo Xavier     บ Data ณ  Junho/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao de etiquetas                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/



// 110 caracteres = 28 cm

Function HSPAHR71(cCodEti, aParam, lCtrlQtd)

Local cOldAlias := ""
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis privadas                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aSize     := MsAdvSize(.T.)  // array que contem as posicoes dos extremos da tela
Private cCadastro := OemToAnsi(STR0001)  // "Impressใo de etiquetas"
Private lRefresh  := .T.
Private aHeader   := {}
Private aCols     := {}
Private nUsado    := 0
Private nPos      := 0
Private aTela[0][0]
Private aGets[0]
Private nOpca1    := 0
Private cFilt01   := ""
Private cFilt02   := ""
Private aMv_Param := {}
Private cPerg     := ""
Private cTipoImp  := ""
Private cLinhaOk  := "AllwaysTrue()"
Private cTudoOk   := "AllwaysTrue()"
Private cFieldOk  := "AllwaysTrue()"
Private _aRet	  := {}

 Private aRotina   := {	{STR0046,	"AxPesqui", 				0, 1},;	//"Pesquisar"
                       	{STR0060,	"AxVisual", 				0, 2},;	//"Visualizar"
                       	{STR0047,	"HSR71Form(3)", 0, 3},;	//"Incluir"
                       	{STR0048,	"HSR71Form(4)", 0, 4},;	//"Alterar"
                       	{STR0049,	"HSR71GRV(5)", 	0, 5},;	//"Excluir"
                       	{STR0050,	"HSR71IMP()" , 	0, 2}} 	//"Imprimir"

Private lIExterno := cCodEti <> Nil
Private lContrQtd := .F.
Private aFonCorR71[30][4]
Private aCoresFont:= {CLR_BLACK, CLR_BLUE, CLR_GREEN, CLR_CYAN, CLR_RED, CLR_MAGENTA, CLR_BROWN, CLR_GRAY, CLR_YELLOW, CLR_WHITE}//GC8_CORFON (CBOX)
Private aTamFontR71 := {"6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24"}
Private lTipFont   := HS_ExisDic({{"C","GC8_TIPFON"}} , .F.) .and. HS_ExisDic({{"C","GC8_ESTFON"}} , .F.) .and. HS_ExisDic({{"C","GC8_TAMFTE"}} , .F.) .and. HS_ExisDic({{"C","GC8_CORFON"}} , .F.)
Private lAddCamExp := .F.
Private aCgc8Temp  := {}
Private nQtdObj     := 0

Default aParam    := ""
Default lCtrlQtd  := .F. // SE ATIVO CHAMA A TELA DE CONTROLE DE QUANTIDADE DE ETIQUETAS E FILTRO DE IMPRESSAO

lContrQtd := lCtrlQtd  // ATRIBUI A VARIAVEL PRIVATE DE CONTROLE O CONTEUDO DA VAR.PARAMETRO

HS_LNetUse()  //CRIA SE NAO EXISTIR E EXECUTA NETMAP.BAT

If !HS_ExisDic({{"C","GC8_TIPFON"," UPDGH037 - Melhorias na Impressใo de etiquetas - Requisito: 001084-SAUDE031"}})
	Return()
EndIf

/*
Tipo - "C" ou "E" - Campo ou Expressao
Codigo
Descricao
Linha
Coluna
Tamanho
Expressao
Codigo de Barra - .T. ou .F.
*/

Private aCampos    := {}
Private aExpress   := {}
Private aLbxCampo  := {}
Private aLbxEspres := {}
Private aLbxPar    := {}

cOldAlias := Alias()

DbSelectArea("GC7")
DbSetOrder(1)

If cCodEti == Nil
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Endereca a funcao de BROWSE                                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	mBrowse(6, 1,22,75,"GC7")
Else
	If ! GC7->(DbSeek(xFilial('GC7')+cCodEti))
		MsgStop(STR0067,STR0014)  //"Aten็ใo!"   //"Codigo de etiqueta nao cadastrado"
		Return(Nil)
	EndIf
	HSR71IMP(aParam)
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Devolve os indices padroes do SIGA.                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
RetIndex("GC7")

DbSelectArea(cOldAlias)

Return(Nil)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณHSR71Form บ Autor ณ Rodrigo Xavier     บ Data ณ Junho/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Formulario para altera็ใo dos dados                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HSR71Form(nAcao)

Local nP			    := 0
Local oPrg
Local aPrg	    := {"DPL","EPL","IPL","ZPL"}
Local oImp
Local aImp	    := {}
Local oPorta
Local aPorta	  := {"LPT1","LPT2","COM1","COM2","COM3","COM4"}
Local oSettPar
Local oEdtLogo

Local 	oEdtQtdLin
Local 	oEdtQtdCol
Local 	oEdtLinEti
Local 	oEdtColeti
Local 	oEdtMarSup
Local 	oEdtXLogo
Local 	oEdtYLogo

Local aButtons := {}
Local nPLogico := 1 // determina o operador logico da expressao de combinacao dos parametros das perguntas

Local nRow			:= 170
Local nCol			:= 010
Local nHeight		:= 014
Local nWidth		:= 100
Local nBtnNxt		:= 105
Local nAuxCalc	:= 0.60

Define FONT oFont NAME "Arial" BOLD

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao das variaveis privadas                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Private M->GC7_CODETI := Space(06)
Private M->GC7_DESCR  := Space(40)
Private M->GC7_QTDCOL := 0
Private M->GC7_QTDLIN := 0
Private M->GC7_LINETI := 0
Private M->GC7_PIXLIN := 50.59
Private M->GC7_COLETI := 0
Private M->GC7_PRGNAT := Space(Len(GC7->GC7_PRGNAT))
Private M->GC7_MODPRN := Space(Len(GC7->GC7_MODPRN))
Private M->GC7_PORTA	 := Space(Len(GC7->GC7_PORTA))
Private M->GC7_SETUP	 := Space(Len(GC7->GC7_SETUP))
Private M->GC7_LOGO 	 :=	Space(Len(GC7->GC7_LOGO))
Private M->GC7_XLOGO  :=	0
Private M->GC7_YLOGO  :=	0
Private M->GC7_ROTACA := "1"
Private M->GC7_FILA   := "1"
Private M->GC7_NOMEFI :=	space(8)
Private M->GC7_MARSUP :=	0
Private M->GC7_MARINF :=	0

Private oFont1 := TFont():New("ARIAL BOLD",,-12,,.T.)
Private oMsMGet

Private oRotacao, aRotacao := {STR0081,STR0082,STR0083,STR0084} //"1=Imp.Esq.p/Direita"###"2=De cima para Baixo"###"3=Imp.Dir.p/Esquerda"###"4=De baixo p/Cima"
Private oFila, oNomeFi, aFila := {"1=Nao Controla","2=Windows","3=Protheus","4=Virtual"}
Private cRotacao      := "N"
Private oCombo1, cCombo1
Private cCombo2
Private aItems  := {STR0005, STR0006, STR0068}  // "0 - Modo texto", "1 - Modo grafico" //"2 - Modo Termico"
Private aItems2 := {}

// aLbx -> Marca, Codigo, Descricao, Linha, Coluna, Tamanho, Expressao, Tipo, Fonte, Tamanho da Fonte (Prn Termica)
Private aLbx      := {{.f.,"","",0,0,0,"","",0,"","","","",0,""}}
Private oTik      := LoadBitmap( GetResources(), "LBTIK" )
Private oNo       := LoadBitmap( GetResources(), "LBNO" )
Private lMarca    := .F.
Private aCodBarra := {}

aExpress			:= {}
aLbxEspres	       := {}
aCampos			:= {}
aLbxCampo	       := {}

// Se for alteracao carrega os dados
If nAcao == 4
	
	M->GC7_CODETI	:=	GC7->GC7_CODETI
	M->GC7_DESCR		:=	GC7->GC7_DESCR
	M->GC7_QTDCOL	:=	GC7->GC7_QTDCOL
	M->GC7_QTDLIN	:=	GC7->GC7_QTDLIN
	M->GC7_LINETI	:=	GC7->GC7_LINETI
	M->GC7_PIXLIN	:=	IIf(GC7->GC7_PIXLIN <=0, 50.59,GC7->GC7_PIXLIN)
	M->GC7_COLETI	:=	GC7->GC7_COLETI
	M->GC7_PRGNAT	:=	GC7->GC7_PRGNAT
	M->GC7_MODPRN	:=	GC7->GC7_MODPRN
	M->GC7_PORTA		:=	GC7->GC7_PORTA
	M->GC7_SETUP		:=	GC7->GC7_SETUP
	M->GC7_LOGO 		:=	GC7->GC7_LOGO
	M->GC7_XLOGO 	:=	GC7->GC7_XLOGO
	M->GC7_YLOGO 	:=	GC7->GC7_YLOGO
	If HS_ExisDic({{"C","GC7_ROTACA"}} , .F.)
		M->GC7_ROTACA 	:=	GC7->GC7_ROTACA
	EndIf
	If HS_ExisDic({{"C","GC7_FILA"}} , .F.)
		M->GC7_FILA 	 :=	GC7->GC7_FILA
		M->GC7_NOMEFI	:=	GC7->GC7_NOMEFI
	EndIf
	If HS_ExisDic({{"C","GC7_MARSUP"}} , .F.)
		M->GC7_MARSUP	:=	GC7->GC7_MARSUP
		M->GC7_MARINF	:=	GC7->GC7_MARINF
	EndIf
	
	cCombo1Aux	:= GC7->GC7_TIPO
	cCombo2				:= GC7->GC7_TABELA
	cTipoImp 		:= GC7->GC7_TIPO
	
	aImp := TrataModelo(M->GC7_PRGNAT)  //Carrega os modelos de acordo com a impressora
	
	DBSelectArea("SX3")
	DBSetOrder(1)
	If DBSeek(SubStr(cCombo2,1,3))
		aLbx := {}
		While !Eof() .And. SX3->X3_ARQUIVO == SubStr(cCombo2,1,3)
			If SX3->X3_CONTEXT <> "V"
				AADD(aLbx,({.f.,SX3->X3_CAMPO,SX3->X3_DESCRIC,0,0,0,"","",.F.,Space(Len(GC8->GC8_FONTE)),Space(Len(GC8->GC8_TAMFON)),"","",0,""}))
			EndIf
			DBSkip()
		End
	EndIf
	
	DBSelectArea("GC8")
	DBSetOrder(1)//GC8_CODETI + GC8_SEQPAR
	DBSeek(xFilial("GC8")+GC7->GC7_CODETI)
	While !Eof() .And. GC8->GC8_CODETI == GC7->GC7_CODETI
		nP := Ascan(aLbx,{|aVet| aVet[2] == GC8->GC8_CAMPO})
		If nP > 0
			aLbx[nP][1] 	:= .T.
			aLbx[nP][2] 	:= GC8->GC8_CAMPO
			aLbx[nP][3] 	:= GC8->GC8_DESCR
			aLbx[nP][4] 	:= GC8->GC8_LINHA
			aLbx[nP][5] 	:= GC8->GC8_COLUNA
			aLbx[nP][6] 	:= GC8->GC8_TAMAN
			aLbx[nP][7] 	:= GC8->GC8_EXPRES
			aLbx[nP][9] 	:= GC8->GC8_CODBAR
			aLbx[nP][10]	:= GC8->GC8_FONTE
			aLbx[nP][11]	:= GC8->GC8_TAMFON
			if lTipFont
				aLbx[nP][12] 	:= GC8->GC8_TIPFON
				aLbx[nP][13]	:= GC8->GC8_ESTFON
				aLbx[nP][14]	:= GC8->GC8_TAMFTE
				aLbx[nP][15]	:= GC8->GC8_CORFON
			else
				aLbx[nP][12] 	:= ""
				aLbx[nP][13]	:= ""
				aLbx[nP][14]	:= 0
				aLbx[nP][15]	:= ""
			endif
			
		Else
			If (GC8->GC8_LINHA > 0 .And. GC8->GC8_COLUNA > 0 .And. GC8->GC8_TAMAN > 0)
				lEditando := .T.
			Else
				lEditando := .F.
			EndIf
			if lTipFont
				AADD(aExpress,({"E",GC8->GC8_CAMPO,GC8->GC8_DESCR,GC8->GC8_LINHA,GC8->GC8_COLUNA,;
				GC8->GC8_TAMAN,GC8->GC8_EXPRES,,GC8->GC8_CODBAR,GC8->GC8_FONTE,GC8->GC8_TAMFON,;
				GC8->GC8_TIPFON, GC8->GC8_ESTFON, GC8->GC8_TAMFTE, GC8->GC8_CORFON}))
				AADD(aLbxEspres,({lEditando,GC8->GC8_CAMPO,GC8->GC8_DESCR,GC8->GC8_LINHA,GC8->GC8_COLUNA,;
				GC8->GC8_TAMAN,GC8->GC8_EXPRES,0,GC8->GC8_FONTE,GC8->GC8_TAMFON,;
				GC8->GC8_TIPFON, GC8->GC8_ESTFON, GC8->GC8_TAMFTE, GC8->GC8_CORFON}))
			else
				AADD(aExpress,({"E",GC8->GC8_CAMPO,GC8->GC8_DESCR,GC8->GC8_LINHA,GC8->GC8_COLUNA,;
				GC8->GC8_TAMAN,GC8->GC8_EXPRES,,GC8->GC8_CODBAR,GC8->GC8_FONTE,GC8->GC8_TAMFON,;
				"", "", 0, "" }))
				AADD(aLbxEspres,({lEditando,GC8->GC8_CAMPO,GC8->GC8_DESCR,GC8->GC8_LINHA,GC8->GC8_COLUNA,;
				GC8->GC8_TAMAN,GC8->GC8_EXPRES,0,GC8->GC8_FONTE,GC8->GC8_TAMFON,;
				"", "", 0, ""}))
			endif
		EndIf
		
		// Carrega os parametros
		If GC8->GC8_PARAM == "1"
			If GC8->GC8_TPARAM == "0"
				cIntervalo := STR0030
			ElseIf GC8->GC8_TPARAM == "1"
				cIntervalo := STR0031
			EndIf
			
			If HS_ExisDic({{"C","GC8_PLOGIC"}} , .F.)
				nPLogico := IIF(GC8->GC8_PLOGIC==0,1,GC8->GC8_PLOGIC)
			Else
				nPLogico := 1
			EndIf
			
			AADD(aLbxPar,({IIf(GC8->GC8_TPARAM == "0",.F.,.T.), GC8->GC8_CAMPO, cIntervalo, nPLogico }))
		EndIf
		
		// Carrega os dados do codigo de barra
		If GC8->GC8_CODBAR
			AADD(aCodBarra,{GC8->GC8_CAMPO,GC8->GC8_CBLIN,GC8->GC8_CBCOL,GC8->GC8_CBTLIN,;
			GC8->GC8_CBTCOL,GC8->GC8_CBTIPO,GC8->GC8_CBDIR,GC8->GC8_CBDIG})
		EndIf
		
		DBSkip()
	Enddo
	
	If aExpress == {}
		AADD(aExpress,({"E","E"+STRZERO(Len(aExpress)+1,5),M->DESCR,0,0,0,M->EXPRES,,.F.,"","","","",0,""}))
	EndIf
	
	If aLbxEspres == {}
		AADD(aLbxEspres,({.f.,"E"+STRZERO(Len(aLbxEspres)+1,5),"",0,0,0,"","",0,"","","","",0,""}))
	EndIf
	
	If aCampos == {}
		AADD(aCampos,({"C","","",0,0,0,"",,.F.,"","","","",0,""}))
	EndIf
	
	If aLbxCampo == {}
		AADD(aLbxEspres,({.f.,"","",0,0,0,"",0,"","","","",0,""}))
	EndIf
	
Else
	cCombo1Aux := "0"
	cTipoImp 		:= cCombo1Aux
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega o SX2 no aItems2                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DBSelectArea("SX2")
DBSetOrder(1)
DBGotop()
While !Eof()
	AADD(aItems2,FWX2Chave() + " - " + X2Nome())//X2Nome() -> retorna a descri็ใo da tabela poscionada no dicionแrio (SX2) no idioma corrente.
	DBSkip()
End

aSize := MsAdvSize(.T.)
aObjects := {}
aAdd( aObjects, { 001, 090, .T., .T. } )
aAdd( aObjects, { 001, 010, .T., .T. } )

aSize[3] := aSize[3] * 0.75
aSize[4] := aSize[4] * 0.75
aSize[5] := aSize[5] * 0.75
aSize[6] := aSize[6] * 0.75

aInfo  := {aSize[1], aSize[2], aSize[3], aSize[4], 5, 5}
aPObjs := MsObjSize(aInfo, aObjects, .T.)
aScreen:= getScreenRes()

//Define o posicionamento dos botoes conforme resolucao da tela
If aScreen[1] >= 1440 .And. aScreen[2] >= 900
	nRow		:= 035
	nCol		:= 005
	nWidth		:= 1010
	nHeight	:= 529
	nBtnNxt	:= 105
	nAuxCalc:= 0.55	
ElseIf aScreen[1] >= 1280 .And. aScreen[2] >= 1024
	nRow		:= 275
	nCol		:= 060
	nWidth		:= 1000	
	nHeight	:= 500
	nBtnNxt	:= 105
	nAuxCalc:= 0.65	
ElseIf aScreen[1] >= 1280 .And. aScreen[2] >= 800
	nRow		:= 175
	nCol		:= 050
	nWidth		:= 1000
	nHeight	:= 500
	nBtnNxt	:= 105
	nAuxCalc:= 0.6	
ElseIf aScreen[1] >= 1020 .And. aScreen[2] >= 760
	nRow		:= 230
	nCol		:= 050
	nWidth		:= 980
	nHeight	:= 500
	nBtnNxt	:= 105
	nAuxCalc:= 0.6
ElseIf aScreen[1] >= 1150 .And. aScreen[2] >= 860
	nRow		:= 175
	nCol		:= 050
	//nWidth		:= 980
	nWidth		:= 800
	nHeight	:= 500
	nAuxCalc:= 0.6	
ElseIf aScreen[1] >= 800 .And. aScreen[2] >= 600
	nRow		:= 110
	nCol		:= 035
	nWidth		:= 600
	nHeight	:= 220
	nBtnNxt	:= 65
	nAuxCalc:= 0.55	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta o formulario ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Aadd(aButtons	,{'bmpord2'  , {|| FS_BTPOS() }, STR0112  , STR0113})      //"Seta o posicionamento de Campos e Expressoes"###"Posicao"
Aadd(aButtons	,{'parametros', {|| FS_BTPAR() }, STR0114, STR0115})  //"Configuracao de perguntas padrao - parametros."###"Parametro"

//DEFINE MSDIALOG oDlg TITLE cCadastro From 000, 000 To aPObjs[1][4], (aPObjs[1][4]*2)-50 OF oMainWnd PIXEL
DEFINE MSDIALOG oDlg TITLE cCadastro From 000, 000 To nHeight, nWidth OF oMainWnd PIXEL

@ aPObjs[1][1], aPObjs[1][2]*2 Say OemToAnsi(STR0002) Size 075, 009 OF oDlg PIXEL COLOR CLR_BLUE FONT oFont1 // "Codigo"
@ aPObjs[1][1], aPObjs[1][1] MSGet oEditCod var M->GC7_CODETI Size 040, 009 OF oDlg PIXEL COLOR CLR_BLACK Valid &cFieldOk WHEN INCLUI

@ aPObjs[1][1], 100 Say OemToAnsi(STR0003) Size 100, 009 OF oDlg PIXEL COLOR CLR_BLUE FONT oFont1  // "Descricao"
@ aPObjs[1][1], 135 MSGet oEditDescr var M->GC7_DESCR Size 150, 009 OF oDlg PIXEL COLOR CLR_BLACK Valid &cFieldOk

// D A D O S   D O   P E R I F E R I C O   E   I N T E R F A C E A M E N T O
//@ aPObjs[1][1]+15, aPObjs[1][2] TO aPObjs[1][1]+60,aPObjs[1][4]-25 LABEL ' Periferico e Interfaceamento ' OF oDlg PIXEL COLOR CLR_GREEN
@ aPObjs[1][1]+15, aPObjs[1][2] TO aPObjs[1][1]+50,nWidth/2 LABEL ' Periferico e Interfaceamento ' OF oDlg PIXEL COLOR CLR_GREEN

// modo de impressao
@ aPObjs[1][1]+20, aPObjs[1][2]*2 Say OemToAnsi(STR0004) Size 50, 009 OF oDlg PIXEL COLOR CLR_BLUE
oCombo1 := tComboBox():New(aPObjs[1][1]+30,aPObjs[1][2]*2,{|u|if(PCount()>0,(cCombo1:=u, cTipoImp := SubStr(cCombo1,1,1)),cCombo1)},aItems ,080,20,oDlg,,,,,,.T.,,,,,,,,,"cCombo1")
cCombo1 := cCombo1Aux
oCombo1:nAt := Val(SubStr(cCombo1,1,1))+1

If HS_ExisDic({{"C","GC7_FILA"}} , .F.)
	@ aPObjs[1][1]+20,110 Say STR0116 PIXEL of oDlg COLOR CLR_BLUE  //"Fila de impressao"
	@ aPObjs[1][1]+30,110 MSCOMBOBOX oFila Var M->GC7_FILA ITEMS aFila PIXEL of oDlg SIZE 050,09
	
	@ aPObjs[1][1]+20,175 Say STR0117 PIXEL of oDlg COLOR CLR_BLUE  //"Nome da Fila"
	@ aPObjs[1][1]+30,175 MsGet oNomeFi Var M->GC7_NOMEFI Picture "@!"  PIXEL of oDlg SIZE 050,09  WHEN oFila:nAt == 3
EndIf

// programacao nativa
@ aPObjs[1][1]+20,240 Say STR0069 PIXEL of oDlg COLOR CLR_BLUE //"Prg. Nativa"
@ aPObjs[1][1]+30,240 MSCOMBOBOX oPrg  VAR M->GC7_PRGNAT ITEMS aPrg SIZE 050,09 PIXEL OF oDlg Valid (;
aImp:=TrataModelo(M->GC7_PRGNAT),;
oImp:SetItems(aImp),;
oImp:Refresh(),.T.) WHEN oCombo1:nAt == 3

@ aPObjs[1][1]+20,300 Say STR0070 PIXEL of oDlg COLOR CLR_BLUE //"Impressora"
@ aPObjs[1][1]+30,300 MSCOMBOBOX oImp VAR M->GC7_MODPRN ITEMS aImp SIZE 050,09 PIXEL OF oDlg WHEN oCombo1:nAt == 3

@ aPObjs[1][1]+20,360 Say STR0071 PIXEL of oDlg COLOR CLR_BLUE //"Porta"
@ aPObjs[1][1]+30,360 MSCOMBOBOX oPorta  VAR M->GC7_PORTA ITEMS aPorta SIZE 050,09 PIXEL OF oDlg WHEN oCombo1:nAt == 3

@ aPObjs[1][1]+20,420 Say STR0085 PIXEL of oDlg COLOR CLR_BLUE //"Settings"
@ aPObjs[1][1]+30,420 MsGet oSettPar Var M->GC7_SETUP Picture "@!"  PIXEL of oDlg SIZE 075,09  WHEN "COM" $ M->GC7_PORTA .and. oCombo1:nAt == 3


// C O N F I G U R A C O E S   D O   F O R M U L A R I O    E T I Q U E T A
@ aPObjs[1][1]+50, aPObjs[1][2] TO aPObjs[1][1]+85,nWidth/2 LABEL ' Formulario-etiqueta ' OF oDlg PIXEL COLOR CLR_GREEN

@ aPObjs[1][1]+60, aPObjs[1][2]*2 Say OemToAnsi(STR0010) Size 075, 008 OF oDlg PIXEL COLOR CLR_BLUE   // "Qtde. Etiq. na vertical"
@ aPObjs[1][1]+60, 080 MSGet oEdtQtdLin var M->GC7_QTDLIN Size 020, 008 OF oDlg PIXEL COLOR CLR_BLACK Picture "999" Valid &cFieldOk

@ aPObjs[1][1]+70, aPObjs[1][2]*2 Say OemToAnsi(STR0011) Size 075, 008 OF oDlg PIXEL COLOR CLR_BLUE   // "Qtde. Etiq. na horizontal"
@ aPObjs[1][1]+70, 080 MSGet oEdtQtdCol var M->GC7_QTDCOL Size 020, 008 OF oDlg PIXEL COLOR CLR_BLACK Picture "999" Valid &cFieldOk

@ aPObjs[1][1]+60, aPObjs[1][1]+80 Say OemToAnsi(STR0043) Size 075, 009 OF oDlg PIXEL COLOR CLR_BLUE   // "Altura da etiqueta (cm)"
@ aPObjs[1][1]+60, 180 MSGet oEdtLinEti var M->GC7_LINETI Size 030, 008 OF oDlg PIXEL COLOR CLR_BLACK Picture "999.99" Valid &cFieldOk

@ aPObjs[1][1]+70, aPObjs[1][1]+80 Say OemToAnsi(STR0044) Size 075, 009 OF oDlg PIXEL COLOR CLR_BLUE   // "Largura da etiqueta (cm)"
@ aPObjs[1][1]+70, 180 MSGet oEdtColEti var M->GC7_COLETI Size 030, 008 OF oDlg PIXEL COLOR CLR_BLACK Picture "999.99" Valid &cFieldOk

@ aPObjs[1][1]+60, 216 Say OemToAnsi("Tam. Linha (px)") Size 075, 009 OF oDlg PIXEL COLOR CLR_BLUE   // "Tam. Linha (px)"
@ aPObjs[1][1]+60, 260 MSGet oEdtTamLin var M->GC7_PIXLIN Size 030, 008 OF oDlg PIXEL COLOR CLR_BLACK Picture "999.99" Valid &cFieldOk

If HS_ExisDic({{"C","GC7_MARSUP"}} , .F.)
	@ aPObjs[1][1]+60, 225 Say OemToAnsi(STR0118) Size 075, 009 OF oDlg PIXEL COLOR CLR_BLUE  //"Margem Sup.(em linhas)"
	@ aPObjs[1][1]+60, 290 MSGet oEdtMarSup var M->GC7_MARSUP Size 010, 008 OF oDlg PIXEL COLOR CLR_BLACK Picture "99" Valid &cFieldOk WHEN oCombo1:nAt == 2
	@ aPObjs[1][1]+70, 225 Say OemToAnsi(STR0119) Size 075, 009 OF oDlg PIXEL COLOR CLR_BLUE //"Margem Inf.(em linhas)"
	@ aPObjs[1][1]+70, 290 MSGet oEdtMarInf var M->GC7_MARINF Size 010, 008 OF oDlg PIXEL COLOR CLR_BLACK Picture "99" Valid &cFieldOk WHEN oCombo1:nAt == 2
EndIf

If HS_ExisDic({{"C","GC7_ROTACA"}} , .F.)
	@ aPObjs[1][1]+60,320 Say STR0086 + " do texto" PIXEL of oDlg COLOR CLR_BLUE //"Rotacao "  
	@ aPObjs[1][1]+70,320 MSCOMBOBOX oRotacao Var M->GC7_ROTACA ITEMS aRotacao PIXEL of oDlg SIZE 050,09 WHEN oCombo1:nAt == 3
EndIf

@ aPObjs[1][1]+60,390 Say STR0087 PIXEL of oDlg COLOR CLR_BLUE //"Logo.ext"
@ aPObjs[1][1]+60,445 Say STR0088 PIXEL of oDlg COLOR CLR_BLUE //"Eixo X"
@ aPObjs[1][1]+70,445 Say STR0089 PIXEL of oDlg COLOR CLR_BLUE //"Eixo Y"

if lTipFont
	@ aPObjs[1][1]+70,390 MsGet oEdtLogo Var M->GC7_LOGO  PIXEL of oDlg SIZE 050,09  WHEN oCombo1:nAt == 3 .or. oCombo1:nAt == 2
	@ aPObjs[1][1]+60,470 MsGet oEdtXLogo Var M->GC7_XLOGO  PIXEL Picture "99" of oDlg SIZE 020,08 WHEN oCombo1:nAt == 3 .or. oCombo1:nAt == 2
	@ aPObjs[1][1]+70,470 MsGet oEdtYLogo Var M->GC7_YLOGO  PIXEL Picture "99" of oDlg SIZE 020,08 WHEN oCombo1:nAt == 3  .or. oCombo1:nAt == 2
else
	@ aPObjs[1][1]+70,390 MsGet oEdtLogo Var M->GC7_LOGO  PIXEL of oDlg SIZE 050,09  WHEN oCombo1:nAt == 3
	@ aPObjs[1][1]+60,470 MsGet oEdtXLogo Var M->GC7_XLOGO  PIXEL Picture "99" of oDlg SIZE 020,08 WHEN oCombo1:nAt == 3
	@ aPObjs[1][1]+70,470 MsGet oEdtYLogo Var M->GC7_YLOGO  PIXEL Picture "99" of oDlg SIZE 020,08 WHEN oCombo1:nAt == 3
endif

// D A D O S   D A   T A B E L A   P A D R A O
	@ aPObjs[1][1]+90, aPObjs[1][2] TO aPObjs[1][1]+220,nWidth/2 LABEL ' Tabela e Campos ' OF oDlg PIXEL COLOR CLR_GREEN

@ aPObjs[1][1]+100,015 MSCOMBOBOX oCombo2 Var cCombo2 ITEMS aItems2 PIXEL of oDlg SIZE 120,20 valid FS_TABELA() WHEN Inclui

// ListBox contendo os campos
@ aPObjs[1][1]+115, 015 LISTBOX oLbx VAR cLbx FIELDS HEADER " ",;
OemtoAnsi(STR0029),;  //"Campo"
OemtoAnsi(STR0003);   //"Descricao"
COLSIZES 10,100,200;
SIZE 480,90 FONT oFont OF oDlg PIXEL ON DBLCLICK (nPos:=oLbx:nAt,FS_Marc(),oLbx:Refresh(),oLbx:nAt:=nPos)

oLbx:SetArray(aLbx)
oLbx:bLine:={||{if(aLbx[oLbx:nAt,1] == .f.,oNo,oTik),	aLbx[oLbx:nAt,2],	aLbx[oLbx:nAt,3]}}
cCombo2 := GC7->GC7_TABELA
oCombo2:Refresh()

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpca1 := 2,IIF(FS_TUDOK(),oDlg:End(),nOpca1 := 0) },{|| nOpca1 := 1,oDlg:End()},,aButtons)

If nOpca1 == 2
	Begin Transaction
	lGravou := HSR71GRV(nAcao)
	If lGravou
		commit
	EndIf
	End Transaction
EndIf

aLbxPar := {}
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณFS_TUDOK  บ Autor ณ MARCELO JOSE       บ Data ณ  05/10/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica informacoes antes de gravar os dados.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_TUDOK()
Local lRet := .T.
If HS_ExisDic({{"C","GC7_FILA"}} , .F.)
	If M->GC7_FILA == "3"
		If Empty(M->GC7_NOMEFI)
			HS_MsgInf(STR0120, STR0092, STR0093)  //"Atencao"###"Impressao de Etiquetas"    //"Se voce optou pelo Protheus gerenciar a fila de impressao, entao o nome da fila de impressao e obrigatorio."
			lRet := .F.
			oNomeFi:SetFocus()
		EndIf
	EndIf
EndIf
Return(lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณHSR71GRV()บ Autor ณ Rodrigo Xavier     บ Data ณ  Junho/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava o arquivo                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Function HSR71GRV(nAcao)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao das variaveis locais                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nInt

If nAcao == 3 .Or. nAcao == 4
	
	// Grava o GC7
	DBSelectArea("GC7")
	DBSetOrder(1)
	If Inclui
		RecLock("GC7",.T.)
	ElseIf nAcao == 4
		RecLock("GC7",.F.)
	EndIf
	
	GC7->GC7_FILIAL := xFilial("GC7")
	GC7->GC7_CODETI := M->GC7_CODETI
	GC7->GC7_DESCR  := M->GC7_DESCR
	GC7->GC7_TIPO   := cCombo1
	GC7->GC7_QTDCOL := M->GC7_QTDCOL
	GC7->GC7_QTDLIN := M->GC7_QTDLIN
	GC7->GC7_LINETI := M->GC7_LINETI
	GC7->GC7_PIXLIN := M->GC7_PIXLIN
	GC7->GC7_COLETI := M->GC7_COLETI
	GC7->GC7_TABELA := SUBSTR(cCombo2,1,3)
	GC7->GC7_PRGNAT	:= M->GC7_PRGNAT
	GC7->GC7_MODPRN := M->GC7_MODPRN
	GC7->GC7_PORTA  := M->GC7_PORTA
	GC7->GC7_SETUP  := M->GC7_SETUP
	GC7->GC7_LOGO   := M->GC7_LOGO
	GC7->GC7_XLOGO  := M->GC7_XLOGO
	GC7->GC7_YLOGO  := M->GC7_YLOGO
	If HS_ExisDic({{"C","GC7_ROTACA"}} , .F.)
		GC7->GC7_ROTACA  := M->GC7_ROTACA
	EndIf
	If HS_ExisDic({{"C","GC7_FILA"}} , .F.)
		GC7->GC7_FILA   := M->GC7_FILA
		GC7->GC7_NOMEFI := M->GC7_NOMEFI
	EndIf
	If HS_ExisDic({{"C","GC7_MARSUP"}} , .F.)
		GC7->GC7_MARSUP   := M->GC7_MARSUP
		GC7->GC7_MARINF   := M->GC7_MARINF
	EndIf
	MsUnlock()
	
	// Apaga os registros do GC8
	DBSelectArea("GC8")
	DBSetOrder(1)//GC8_CODETI + GC8_SEQPAR
	If DBSeek(xFilial("GC8")+M->GC7_CODETI)
		While !Eof() .And. GC8->GC8_CODETI == M->GC7_CODETI
			RecLock("GC8")
			dbDelete()
			MsUnlock()
			DBSkip()
		End
	EndIf
	
	// Adiciona os registros novos
	If Len(aLbx) > 0  // vetor da tabela selecionada com todos os campos da tabela (SX3 completo da tabela)
		For nInt := 1 to Len(aLbx)
			If aLbx[nInt][1]
				RecLock("GC8",.T.)
				GC8->GC8_FILIAL	:= xFilial("GC8")
				GC8->GC8_CODETI	:= M->GC7_CODETI
				GC8->GC8_CAMPO 	:= aLbx[nInt][2]
				GC8->GC8_DESCR 	:= aLbx[nInt][3]
				GC8->GC8_LINHA 	:= aLbx[nInt][4]
				GC8->GC8_COLUNA	:= aLbx[nInt][5]
				GC8->GC8_TAMAN 	:= aLbx[nInt][6]
				GC8->GC8_EXPRES	:= aLbx[nInt][7]
				GC8->GC8_CODBAR	:= aLbx[nInt][9]
				GC8->GC8_FONTE		:= aLbx[nInt][10]
				GC8->GC8_TAMFON	:= aLbx[nInt][11]
				if lTipFont
					GC8->GC8_TIPFON := aLbx[nInt][12]
					GC8->GC8_ESTFON := aLbx[nInt][13]
					GC8->GC8_TAMFTE := iIf(valType(aLbx[nInt][14]) == "N", aLbx[nInt][14], iIf(valType(aLbx[nInt][14]) == "C",val(aLbx[nInt][14]),0) )
					GC8->GC8_CORFON := aLbx[nInt][15]
				endif
				
				
				nP := Ascan(aLbxPar,{|aVet| Alltrim(aVet[2]) == Alltrim(GC8->GC8_CAMPO)})  // se encontrou no vetor da lista de parametro
				
				If nP > 0
					IIf( HS_ExisDic({{"C","GC8_PLOGIC"}} , .F.) , GC8->GC8_PLOGIC := aLbxPar[nP,4] , Nil )  // operador logico com o proximo registro.
					GC8->GC8_PARAM  := "1"  // se o campo do SX3 marcado no dicionario esta selecionado como parametro tambem.
					GC8->GC8_TPARAM := SubStr(aLbxPar[nP][3],1,1)  // se gera intervalo
					GC8->GC8_SEQPAR := STRZERO(nP, 3)
				Else
					GC8->GC8_PARAM  := "0"
					GC8->GC8_TPARAM := "0"
				EndIf
				
				nP1 := Ascan(aLbx,{|aVet| aVet[9] == .T.})
				If nP1 > 0
					nP := Ascan(aCodBarra,{|aVet| aVet[1] == aLbx[nInt][2]})
					If nP > 0
						GC8->GC8_CBLIN  := aCodBarra[nP][2]
						GC8->GC8_CBCOL  := aCodBarra[nP][3]
						GC8->GC8_CBTLIN := aCodBarra[nP][4]
						GC8->GC8_CBTCOL := aCodBarra[nP][5]
						GC8->GC8_CBTIPO := aCodBarra[nP][6]
						GC8->GC8_CBDIR  := aCodBarra[nP][7]
						GC8->GC8_CBDIG  := aCodBarra[nP][8]
					EndIf
				EndIf
				MsUnlock()
			EndIf
		Next
	EndIf
	
	// Adiciona os registros novos (expressoes)
	If Len(aExpress) > 0
		For nInt := 1 to Len(aExpress)
			RecLock("GC8",.T.)
			GC8->GC8_FILIAL := xFilial("GC8")
			GC8->GC8_CODETI := M->GC7_CODETI
			GC8->GC8_CAMPO  := aExpress[nInt][2]
			GC8->GC8_DESCR  := aExpress[nInt][3]
			GC8->GC8_LINHA  := aExpress[nInt][4]
			GC8->GC8_COLUNA := aExpress[nInt][5]
			GC8->GC8_TAMAN  := aExpress[nInt][6]
			GC8->GC8_EXPRES := aExpress[nInt][7]
			GC8->GC8_CODBAR := aExpress[nInt][9]
			GC8->GC8_FONTE		:= aExpress[nInt][10]
			GC8->GC8_TAMFON	:= aExpress[nInt][11]
			if lTipFont
				GC8->GC8_TIPFON := aExpress[nInt][12]
				GC8->GC8_ESTFON := aExpress[nInt][13]
				GC8->GC8_TAMFTE := iIf(valType(aExpress[nInt][14]) == "N", aExpress[nInt][14], iIf(valType(aExpress[nInt][14]) == "C",val(aExpress[nInt][14]),0) )
				GC8->GC8_CORFON := aExpress[nInt][15]
			endif
			
			//nP1 := Ascan(aLbx,{|aVet| aVet[9] == .T.})
			//If nP1 > 0
			
			nP := Ascan(aCodBarra,{|aVet| aVet[1] == aExpress[nInt][2]})
			If nP > 0
				If Len(aCodBarra) > 0
					GC8->GC8_CBLIN  := aCodBarra[nP][2]
					GC8->GC8_CBCOL  := aCodBarra[nP][3]
					GC8->GC8_CBTLIN := aCodBarra[nP][4]
					GC8->GC8_CBTCOL := aCodBarra[nP][5]
					GC8->GC8_CBTIPO := aCodBarra[nP][6]
					GC8->GC8_CBDIR  := aCodBarra[nP][7]
					GC8->GC8_CBDIG  := aCodBarra[nP][8]
				EndIf
			Endif
			
			MsUnlock()
		Next
	Endif
	
Elseif nAcao == 5
	If MsgYesNo(STR0028,STR0014)  // "Deseja realmente excluir este registro?"
		Begin Transaction
		// Apaga os registros do GC8
		DBSelectArea("GC8")
		DBSetOrder(1)//GC8_CODETI + GC8_SEQPAR
		If DBSeek(xFilial("GC8")+GC7->GC7_CODETI)
			While !Eof() .And. GC8->GC8_CODETI == GC7->GC7_CODETI
				RecLock("GC8")
				dbDelete()
				MsUnlock()
				DBSkip()
			End
		EndIf
		
		// Apaga o registro no GC7
		DBSelectArea("GC7")
		DBSetOrder(1)
		If DBSeek(xFilial("GC7")+GC7->GC7_CODETI)
			RecLock("GC7")
			dbDelete()
			MsUnlock()
		Endif
		
		Commit
		
		End Transaction
		
	Endif
	
Endif

aLbxPar := {}

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณFS_BTPOS()บ Autor ณ Rodrigo Xavier     บ Data ณ  Junho/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Botao de posicionamento                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function FS_BTPOS()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis locais                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nEsquerda   := (aSize[5]-100)/5
Local nTopo       := 14
Local nAltura     := ((aSize[6]-112)/2)-68
Local nLargura    := ((aSize[5]-100)/2)-((aSize[5]-100)/5)
Local nEtiAltura  := Int(9 * M->GC7_LINETI * (aSize[6]/339.5))
Local nEtiLargura := Int(5 * M->GC7_COLETI * (aSize[5]/262.5))
Local nInt        := 0
Local nAux        := 0
Local nInt2       := 0
Local nP          := 0
Local lMarca      := .F.
Local aFontTemp  := {}
Local nI          := 0
Local cVarLinha  := 0
Local oTBitmap1
Local oTBitmap2
Local cPathR71    := ""
Local cLogoR71    := ""
//Inclusao de variaveis para pre visualizacao de etiqueta / tipo de fonte
Local nJ           := 0
Local nLinha       := 0
Local nColuna      := 0
Local oFontX 		 := TFont():New("Arial"      	  			,09,08,,.F.,,,,,.F.) //
Local cTemp        := ""
Local cVarL        := ""
Local cVarO        := ""
Local cVarC        := ""
Local cVarFont     := ""
Local cVarCor      := ""
Local nX           := 1
Local cVarCol     := ""
Local cVarLin     := ""
local aFontTemp   := {}

local nSubMcr1 		:= 0
local nSubMcr2		:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis privadas                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private oAzul         := LoadBitmap( GetResources(), STR0051 ) //"BR_AZUL"
Private oCinza        := LoadBitmap( GetResources(), STR0052 )    //"BR_CINZA"
Private lCheckCBarra  := .F.
Private lEditando     := .F.
Private nPosicao      := 0
Private nOpca         := 0
Private lPrimv        := .T.
Private aVisualizacao := {}

Private M->TIPFON  := iIf(lTipFont, Space(Len(GC8->GC8_TIPFON)), "")
Private M->ESTFON  := iIf(lTipFont, Space(Len(GC8->GC8_ESTFON)), "")
Private M->TAMFTE  := 0
Private M->CORFON  := iIf(lTipFont, Space(Len(GC8->GC8_CORFON)), "")

Private nTopo       := 14
Private nAltura     := ((aSize[6]-112)/2)-68
Private nLargura    := ((aSize[5]-100)/2)-((aSize[5]-100)/5)
Private nEtiAltura  := Int(9 * M->GC7_LINETI * (aSize[6]/339.5))
Private nEtiLargura := Int(5 * M->GC7_COLETI * (aSize[5]/262.5))
Private nTamPixLin	 := M->GC7_PIXLIN
//DEFINE MSDIALOG oDlgPos TITLE cCadastro + STR0053 FROM aSize[7]+50,50 TO aSize[6]-50,aSize[5]-50 OF oMainWnd PIXEL //" - Posicionamento"
Private oDlgPos := TDialog():New(aSize[7]+50,50,aSize[6]-50,aSize[5]-50,cCadastro + STR0053,,,,,,,,oMainWnd,.T.)
For nInt := 1 to 30
	AADD(aVisualizacao,({""}))
Next

M->LINHA			:= 0
M->COLUNA		:= 0
M->FONTE			:= Space(Len(GC8->GC8_FONTE))
M->TAMFON		:= Space(Len(GC8->GC8_TAMFON))
M->TAMANHO	:= 0
M->EXPRES		:= Space(200)
M->DESCR		:= Space(030)

M->LINHA1  := Space(200)
M->LINHA2  := Space(200)
M->LINHA3  := Space(200)
M->LINHA4  := Space(200)
M->LINHA5  := Space(200)
M->LINHA6  := Space(200)
M->LINHA7  := Space(200)
M->LINHA8  := Space(200)
M->LINHA9  := Space(200)
M->LINHA10 := Space(200)
M->LINHA11 := Space(200)
M->LINHA12 := Space(200)
M->LINHA13 := Space(200)
M->LINHA14 := Space(200)
M->LINHA15 := Space(200)
M->LINHA16 := Space(200)
M->LINHA17 := Space(200)
M->LINHA18 := Space(200)
M->LINHA19 := Space(200)
M->LINHA20 := Space(200)
M->LINHA21 := Space(200)
M->LINHA22 := Space(200)
M->LINHA23 := Space(200)
M->LINHA24 := Space(200)
M->LINHA25 := Space(200)
M->LINHA26 := Space(200)
M->LINHA27 := Space(200)
M->LINHA28 := Space(200)
M->LINHA29 := Space(200)
M->LINHA30 := Space(200)

M->LINHAExp1  := Space(200)
M->LINHAExp2  := Space(200)
M->LINHAExp3  := Space(200)
M->LINHAExp4  := Space(200)
M->LINHAExp5  := Space(200)
M->LINHAExp6  := Space(200)
M->LINHAExp7  := Space(200)
M->LINHAExp8  := Space(200)
M->LINHAExp9  := Space(200)
M->LINHAExp10 := Space(200)
M->LINHAExp11 := Space(200)
M->LINHAExp12 := Space(200)
M->LINHAExp13 := Space(200)
M->LINHAExp14 := Space(200)
M->LINHAExp15 := Space(200)
M->LINHAExp16 := Space(200)
M->LINHAExp17 := Space(200)
M->LINHAExp18 := Space(200)
M->LINHAExp19 := Space(200)
M->LINHAExp20 := Space(200)
M->LINHAExp21 := Space(200)
M->LINHAExp22 := Space(200)
M->LINHAExp23 := Space(200)
M->LINHAExp24 := Space(200)
M->LINHAExp25 := Space(200)
M->LINHAExp26 := Space(200)
M->LINHAExp27 := Space(200)
M->LINHAExp28 := Space(200)
M->LINHAExp29 := Space(200)
M->LINHAExp30 := Space(200)

//Identifica se o Alias selecionado inicia em "S"
If SubStr(cCombo2,1,1) == "S"
	nSubMcr1 	:= 3
	nSubMcr2	:= 2
Else
	nSubMcr1 	:= 4
	nSubMcr2	:= 3
EndIf

If Len(aLbxCampo) < 1
	AADD(aLbxCampo,({.f.,"","",0,0,0,"","",0,"",""}))
EndIf

If cTipoImp <>"2"  .AND. (M->GC7_LINETI < 1 .Or. M->GC7_COLETI < 1)
	MsgStop(STR0015,STR0014)  // "Preencha as quantidades de linhas e colunas por etiquetas!", "Atencao!"
	Return
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Inicializa a variavel aLbxCampo                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty(aLbxCampo[1][2])
	For nInt := 1 to Len(aLbx)
		If aLbx[nInt][1]
			If nAux == 0
				aLbxCampo := {}
				nAux++
			EndIf
			If aLbx[nInt][4] > 0 .And. aLbx[nInt][5] > 0 .And. aLbx[nInt][6] > 0
				lMarca := .T.
			EndIf
			AADD(aLbxCampo,({lMarca,aLbx[nInt][2],aLbx[nInt][3],aLbx[nInt][4],aLbx[nInt][5],;
			aLbx[nInt][6],aLbx[nInt][7],aLbx[nInt][8],0,aLbx[nInt][10],aLbx[nInt][11],;
			,aLbx[nInt][12],aLbx[nInt][13],aLbx[nInt][14],aLbx[nInt][15]}))
			AADD(aCampos,({"C",aLbx[nInt][2],aLbx[nInt][3],aLbx[nInt][4],aLbx[nInt][5],;
			aLbx[nInt][6],aLbx[nInt][7],,aLbx[nInt][9],aLbx[nInt][10],aLbx[nInt][11],;
			aLbx[nInt][12],aLbx[nInt][13],aLbx[nInt][14],aLbx[nInt][15]}))
		EndIf
		lMarca := .F.
	Next
EndIf

If Len(aExpress) < 1
	AADD(aExpress,({"E","E"+STRZERO(Len(aExpress)+1,5),M->DESCR,0,0,0,M->EXPRES,,.F.,"","","","",0,""}))
EndIf

If Len(aLbxEspres) == 0
	AADD(aLbxEspres,({.f.,"E"+STRZERO(Len(aLbxEspres)+1,5),"",0,0,0,"","",0,"","","","",0,""}))
EndIf

FS_MONTAETI()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta o formulario para o posicionamento dos campos                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//DEFINE MSDIALOG oDlgPos TITLE cCadastro + STR0053 FROM aSize[7]+50,50 TO aSize[6]-50,aSize[5]-50 OF oMainWnd PIXEL //" - Posicionamento"

aSize := MsAdvSize(.T.)
aObjects := {}
aAdd( aObjects, { 001, 100, .T., .T. } )

aSize[3] := aSize[3] * 0.75
aSize[4] := aSize[4] * 0.75
aSize[5] := aSize[5] * 0.75
aSize[6] := aSize[6] * 0.75

aInfo  := {aSize[1], aSize[2], aSize[3], aSize[4], 5, 5}
aPObjs := MsObjSize(aInfo, aObjects, .T.)

// Monta o Folder
@ aPObjs[1][1], aPObjs[1][2] FOLDER oFolder SIZE nEsquerda-2, (aPObjs[1][3]/3)+10 OF oDlgPos PROMPTS STR0016, STR0017 PIXEL  // "      Campos      ", "    Expressoes    "
// --------------------------------------------------------------------------
// ABA - CAMPOS
// ListBox contendo os campos
@ 000, 000 LISTBOX oLbxCampo VAR cLbxCampo FIELDS HEADER " ",;
OemtoAnsi(STR0029),;  //"Campo"
OemtoAnsi(STR0003); //"Descricao"
COLSIZES 10,40,100;
SIZE nEsquerda-5,aPObjs[1][3]/3 FONT oFont OF oFolder:aDialogs[1] PIXEL ON DBLCLICK (nPos:=oLbxCampo:nAt,FS_CARCAM(),oLbxCampo:Refresh(),oLbxCampo:nAt:=nPos)

oLbxCampo:SetArray(aLbxCampo)

oLbxCampo:bLine := {||{if(aLbxCampo[oLbxCampo:nAt,1] == .f.,oCinza,oAzul),;
aLbxCampo[oLbxCampo:nAt,2],;
aLbxCampo[oLbxCampo:nAt,3]}}

// ------------------------------
// ABA - EXPRESSOES
// ListBox contendo as expressoes
@ 000, 000 LISTBOX oLbxExpressao VAR cLbxCampo FIELDS HEADER " ",;
OemtoAnsi(STR0022),;  //"Expressao"
OemtoAnsi(STR0003); //"Descricao"
COLSIZES 10,40,100;
SIZE nEsquerda-5,nAltura-nAltura/2-21 FONT oFont OF oFolder:aDialogs[2] PIXEL ON DBLCLICK (nPos:=oLbxExpressao:nAt,FS_CARCAM(),oLbxExpressao:Refresh(),oLbxExpressao:nAt:=nPos)

oLbxExpressao:SetArray(aLbxEspres)

oLbxExpressao:bLine := {||{if(aLbxEspres[oLbxExpressao:nAt,1] == .f.,oCinza,oAzul),;
aLbxEspres[oLbxExpressao:nAt,2],;
aLbxEspres[oLbxExpressao:nAt,3]}}

oBtnExpressao := tButton():New(nAltura-nAltura/2-10,(nEsquerda-100)/2,STR0018,oFolder:aDialogs[2],{||FS_ADDESP()},090,014,,,,.T.)  // "Adicionar expressao"

// Monta os Panels
oPanel				:=	tPanel():New(aPObjs[1][1],nEsquerda,,oDlgPos,,,,,CLR_GRAY,nLargura,nAltura)

@ aPObjs[1][1] + nAltura + 5 , nEsquerda Say "*** Pre-visualiza็ใo aproximada, ap๓s a configura็ใo realize a impressใo para um visualiza็ใo exata. "  Size 500, 009 OF oDlgPos PIXEL COLOR CLR_HRED

if lTipFont .and. oCombo1:nAt == 2
	//Monta o painel duplo
	oFolVis := TFolder():New( nAltura*0.015,nLargura*0.015,{STR0151,STR0152},,oPanel,,,CLR_RED,.T.,,nLargura*0.97,nAltura*0.97 ) //"Campos/Expressoes" ### "Pre Visualizacao"
	
	oEtiqueta :=	tPanel():New((nAltura-nEtiAltura)/2,(nLargura-nEtiLargura)/2,,oFolVis:aDialogs[1],,,,,CLR_HGRAY,nEtiLargura,nEtiAltura)
	oEtiqExp  :=	tPanel():New((nAltura-nEtiAltura)/2,(nLargura-nEtiLargura)/2,,oFolVis:aDialogs[2],,,,,CLR_HGRAY,nEtiLargura,nEtiAltura)
	
	cPathR71    := GetSrvProfString("Startpath","")
	cLogoR71    := "R71LOGO.bmp"
	
	//Carregando imagem para exibicao
	If !Empty(cLogoR71)
		FErase(cPathR71 + cLogoR71)
	endif
	if !empty(M->GC7_LOGO) .and. (oCombo1:nAt == 3 .or. oCombo1:nAt == 2)
		if RepExtract(alltrim(M->GC7_LOGO), cPathR71 + cLogoR71)
			
			oTBitmap2 := TBitmap():New(M->GC7_YLOGO, M->GC7_XLOGO,40, 40, , cPathR71 + cLogoR71,.F.,oEtiqExp,,,,,,,,,.T.,,,,)
			oTBitmap2:lAutoSize := .T.
		endif
	endif
	
	nLinha := 0
	//Criando variaveis para impressao
	for nI := 1 to 30
		cVarL := "M->LinhaExp" + cValToChar(nI)
		for nJ := 1 to len(&cVarL)
			//Objeto/Texto - Say
			cVarO   := "oSay" + cValToChar(nX)
			cVarC   := "cSay" + cValToChar(nX)
			
			cVarCol := "cColuna" + cValToChar(nX)
			cVarLin := "cLinha" + cValToChar(nX)
			cVarFont:= "cFont" + cValToChar(nX)
			cVarCor := "cCor" + cValToChar(nX)
			
			//Variaveis para atualizacao
			cNewText    := "cNewText" + cValToChar(nX)
			cNewFont    := "cNewFont" + cValToChar(nX)
			cNewCor     := "cNewCor" + cValToChar(nX)
			
			nQtdObj++
			nX++
			_SetOwnerPrvt(cVarO  , nil)
			
			//Se o Conteudo for um campo
			SX3->(DBSetOrder(1))
			If SX3->(DBSeek(SubStr(cCombo2,1,3))) .and. SubStr(&cVarL[nJ,1],nSubMcr1,1) == "_"
				cConteudo :=  &(SubStr(cCombo2,1,3) + "->" + &cVarL[nJ,1])
			Else
				cConteudo := &(&cVarL[nJ,1])
			EndIf
			
			_SetOwnerPrvt(cVarC  , cConteudo)
			_SetOwnerPrvt(cVarCol, &cVarL[nJ,2])
			_SetOwnerPrvt(cVarLin, nLinha)
			_SetOwnerPrvt(cVarFont, nil)
			_SetOwnerPrvt(cVarCor, nil)
			
			//Variaveis para atualizacao
			_SetOwnerPrvt(cNewText, "")
			_SetOwnerPrvt(cNewFont, nil)
			_SetOwnerPrvt(cNewCor , nil)
			
			aAdd(aFontTemp, {"","","",&cVarL[nJ,4],&cVarL[nJ,5],&cVarL[nJ,6],&cVarL[nJ,7]})
			aFontTemp := FS_retFontR71(aFontTemp, .T.)
			&cVarFont := aFontTemp[1]
			&cVarCor  := aFontTemp[2]
			
			&(cVarO) := tSay():New(&cVarLin,&cVarCol*2,{|| &cVarC },oEtiqExp,, &cVarFont,,,,.T.,&cVarCor,,,)
			
			aFontTemp := {}
			
		next nJ
		nLinha+=5
	next nI
	nX := 1
	oEtiqExp:refresh()
else
	//Monta o painel unico
	oEtiqueta :=	tPanel():New((nAltura-nEtiAltura)/2,(nLargura-nEtiLargura)/2,,oPanel,,,,,CLR_WHITE,nEtiLargura,nEtiAltura)
endif

//Carregando imagem para exibicao
If lTipFont .and.!Empty(cLogoR71)
	FErase(cPathR71 + cLogoR71)
	if !empty(M->GC7_LOGO) .and. (oCombo1:nAt == 3 .or. oCombo1:nAt == 2)
		if RepExtract(alltrim(M->GC7_LOGO), cPathR71 + cLogoR71)
			
			oTBitmap1 := TBitmap():New(M->GC7_YLOGO, M->GC7_XLOGO,40, 40, , cPathR71 + cLogoR71,.F.,oEtiqueta,,,,,,,,,.T.,,,,)
			oTBitmap1:lAutoSize := .T.
		endif
	endif
endif

@ 000, 003 Say FS_retExpR71(M->LINHA1 ,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 005, 003 Say FS_retExpR71(M->LINHA2 ,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 010, 003 Say FS_retExpR71(M->LINHA3 ,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 015, 003 Say FS_retExpR71(M->LINHA4 ,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 020, 003 Say FS_retExpR71(M->LINHA5 ,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 025, 003 Say FS_retExpR71(M->LINHA6 ,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 030, 003 Say FS_retExpR71(M->LINHA7 ,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 035, 003 Say FS_retExpR71(M->LINHA8 ,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 040, 003 Say FS_retExpR71(M->LINHA9 ,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 045, 003 Say FS_retExpR71(M->LINHA10,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 050, 003 Say FS_retExpR71(M->LINHA11,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 055, 003 Say FS_retExpR71(M->LINHA12,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 060, 003 Say FS_retExpR71(M->LINHA13,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 065, 003 Say FS_retExpR71(M->LINHA14,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 070, 003 Say FS_retExpR71(M->LINHA15,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 075, 003 Say FS_retExpR71(M->LINHA16,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 080, 003 Say FS_retExpR71(M->LINHA17,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 085, 003 Say FS_retExpR71(M->LINHA18,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 090, 003 Say FS_retExpR71(M->LINHA19,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 095, 003 Say FS_retExpR71(M->LINHA20,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 100, 003 Say FS_retExpR71(M->LINHA21,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 105, 003 Say FS_retExpR71(M->LINHA22,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 110, 003 Say FS_retExpR71(M->LINHA23,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 115, 003 Say FS_retExpR71(M->LINHA24,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 120, 003 Say FS_retExpR71(M->LINHA25,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 125, 003 Say FS_retExpR71(M->LINHA26,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 130, 003 Say FS_retExpR71(M->LINHA27,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 135, 003 Say FS_retExpR71(M->LINHA28,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 140, 003 Say FS_retExpR71(M->LINHA29,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
@ 145, 003 Say FS_retExpR71(M->LINHA30,.T.)  Size 500, 009 OF oEtiqueta PIXEL COLOR CLR_BLACK
oEtiqueta:refresh()

oFolder:bChange:= {|nAba| FS_ABA(nAba,oFolder:nOption)}  // nAba = aba que foi clicada, oFolder:nOption = aba anterior

// --------------------------------------------------------------------------
// Campos de configuracao
oPanelConf := tPanel():New(nAltura-nAltura/2+14,1,,oDlgPos,,,,,CLR_WHITE,nEsquerda-2,nAltura/2+20)
@ 006, 003 Say OemToAnsi(STR0003) Size 030, 009 OF oPanelConf PIXEL COLOR CLR_BLUE   // "Descricao"
@ 014, 003 MSGet oEditDescricao var M->DESCR Size 094, 009 OF oPanelConf Picture "@" PIXEL COLOR CLR_BLACK Valid &cFieldOk
@ 026, 003 Say OemToAnsi(STR0019) Size 030, 009 OF oPanelConf PIXEL COLOR CLR_BLUE   // "Linha"
@ 034, 003 MSGet oEditLinha var M->LINHA Size 030, 009 OF oPanelConf Picture "9999" PIXEL COLOR CLR_BLACK Valid &cFieldOk
@ 026, 035 Say OemToAnsi(STR0020) Size 030, 009 OF oPanelConf PIXEL COLOR CLR_BLUE   // "Coluna"
@ 034, 035 MSGet oEditColuna var M->COLUNA Size 030, 009 OF oPanelConf Picture "9999" PIXEL COLOR CLR_BLACK Valid &cFieldOk
@ 026, 067 Say OemToAnsi(STR0021) Size 030, 009 OF oPanelConf PIXEL COLOR CLR_BLUE   // "Tamanho"
@ 034, 067 MSGet oEditTamanho var M->TAMANHO Size 030, 009 OF oPanelConf Picture "9999" PIXEL COLOR CLR_BLACK Valid &cFieldOk

If cTipoImp == "2" // Etiqueta termica
	@ 026, 100 Say OemToAnsi(STR0072) Size 015, 009 OF oPanelConf PIXEL COLOR CLR_BLUE //"Fonte"
	@ 034, 100 MSGet oEditFonte var M->FONTE Size 010, 009 OF oPanelConf PIXEL COLOR CLR_BLACK
	
	@ 026, 120 Say OemToAnsi(STR0073) Size 030, 009 OF oPanelConf PIXEL COLOR CLR_BLUE //"Tam. Fonte"
	@ 034, 120 MSGet oEditTamFon var M->TAMFON Size 030, 009 OF oPanelConf PIXEL COLOR CLR_BLACK
Endif

@ 046, 003 Say OemToAnsi(STR0022) Size 030, 009 OF oPanelConf PIXEL COLOR CLR_BLUE   // "Expressao"
@ 054, 003 MSGet oEditExpressao var M->EXPRES Size 170, 009 OF oPanelConf Picture "@" PIXEL COLOR CLR_BLACK Valid &cFieldOk

oCheckCBarra := tCheckBox():New(065,003,STR0023, {|u|if( pcount()>0,lCheckCBarra:=u,lCheckCBarra)},oPanelConf,100,20,,{||FS_BTCBARRA()},,,,,,.T.)  // "Codigo de barra"
If Substr(cCombo1,1,1) == "0"
	oCheckCBarra:Disable()
Else
	oCheckCBarra:Enable()
EndIf
oBtnCBarra := tButton():New(068,57,STR0024,oPanelConf,{||FS_CBAGRV()},040,014,,,,.T.)  // "Configurar"
oBtnCBarra:lVisible := .F.
//oBtnFonte  := tButton():New(084,002,STR0025,oPanelConf,{||},095,014,,,,.T.)  // "Configurar Fonte"
If cTipoImp <> "2"
	oBtnFonte  := tButton():New(084,002,STR0025,oPanelConf,{||iIf(lTipFont .and. oCombo1:nAt == 2,FS_fonteR71(),)},095,014,,,,.T.)  // "Configurar Fonte"
endif
oBtnGravar := tButton():New(084,100,STR0026,oPanelConf,{||FS_PARGRV(.T.),iIf(lTipFont .and. oCombo1:nAt == 2, fs_atuSayR71(.T.),)},030,014,,,,.T.)  // "Gravar"

oPanelConf:lVisible := .F.

//ACTIVATE MSDIALOG oDlgPos ON INIT EnchoiceBar(oDlgPos, {|| nOpca := 2,oDlgPos:End()},{|| nOpca := 1,oDlgPos:End()})
oDlgPos:Activate(,,,.T.,{||.T.},,{|| EnchoiceBar(oDlgPos, {|| nOpca := 2,oDlgPos:End()},{|| nOpca := 1,oDlgPos:End()}),fs_atuSayR71() } )

If nOpca == 2
	For nInt2 := 1 to Len(aLbx)
		aLbx[nInt2][4] 	:= 0
		aLbx[nInt2][5] 	:= 0
		aLbx[nInt2][6] 	:= 0
		aLbx[nInt2][7] 	:= ""
		aLbx[nInt2][8] 	:= ""
		aLbx[nInt2][9] 	:= .F.
		aLbx[nInt2][10]	:= ""
		aLbx[nInt2][11]	:= ""
		
		aLbx[nInt2][12] 	:= ""
		aLbx[nInt2][13]	:= ""
		aLbx[nInt2][14]	:= 0
		aLbx[nInt2][15]	:= ""
		
	Next
	For nInt2 := 1 to Len(aCampos)
		nP := Ascan(aLbx,{|aVet| aVet[2] == aCampos[nInt2][2]})
		If nP > 0
			aLbx[nP][2] 	:= aCampos[nInt2][2]
			aLbx[nP][3] 	:= aCampos[nInt2][3]
			aLbx[nP][4] 	:= aCampos[nInt2][4]
			aLbx[nP][5] 	:= aCampos[nInt2][5]
			aLbx[nP][6] 	:= aCampos[nInt2][6]
			aLbx[nP][7] 	:= aCampos[nInt2][7]
			aLbx[nP][8] 	:= aCampos[nInt2][1]
			aLbx[nP][9] 	:= aCampos[nInt2][9]
			aLbx[nP][10]	:= aCampos[nInt2][10]
			aLbx[nP][11]	:= aCampos[nInt2][11]
			if lTipFont
				aLbx[nP][12] 	:= aCampos[nInt2][12]
				aLbx[nP][13]	:= aCampos[nInt2][13]
				aLbx[nP][14]	:= aCampos[nInt2][14]
				aLbx[nP][15]	:= aCampos[nInt2][15]
			endif
		EndIf
	Next
EndIf
aLbxCampo := {}
aCampos   := {}
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณFS_PARGRV()บ Autor ณ Rodrigo Xavier    บ Data ณ Junho/2003  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava as alteracoes do posicionamento na matriz            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_PARGRV(lGravar)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis locais                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nFolder := oFolder:nOption
Local cMatriz

If nFolder == 1
	cMatriz := "aCampos"
ElseIf nFolder == 2
	cMatriz := "aExpress"
EndIf

If M->LINHA <= 0 .or. M->COLUNA <=0 .or. M->TAMANHO <= 0
	MsgStop(STR0090) //"O campos LINHA, COLUNA e TAMANHO devem tem valor diferente de Zero !"
	Return
Endif

If !lGravar
	If M->DESCR    	<> &cMatriz[nPosicao][3] 	.or. ;
		M->LINHA    	<> &cMatriz[nPosicao][4]	 .or. ;
		M->COLUNA   	<> &cMatriz[nPosicao][5] 	.or. ;
		M->TAMANHO  	<> &cMatriz[nPosicao][6]	 .or. ;
		M->EXPRES   	<> &cMatriz[nPosicao][7] 	.or. ;
		lCheckCBarra	<> &cMatriz[nPosicao][9] 	.or. ;
		M->FONTE					<> &cMatriz[nPosicao][10]	.or. ;
		M->TAMFON				<> &cMatriz[nPosicao][11]
		
		If MsgYesNo(STR0027,STR0014)  // "Deseja gravar as alteracoes feitas?", "Atencao!"
			lGravar := .T.
		EndIf
	EndIf
EndIf

If lGravar
	If nFolder == 1
		aLbxCampo[nPosicao][3] := M->DESCR
	ElseIf nFolder == 2
		aLbxEspres[nPosicao][3] := M->DESCR
	EndIf
	
	&cMatriz[nPosicao][3] 	:= M->DESCR
	&cMatriz[nPosicao][4] 	:= M->LINHA
	&cMatriz[nPosicao][5] 	:= M->COLUNA
	&cMatriz[nPosicao][6] 	:= M->TAMANHO
	&cMatriz[nPosicao][7] 	:= M->EXPRES
	&cMatriz[nPosicao][10]	:= M->FONTE
	&cMatriz[nPosicao][11]	:= M->TAMFON
	if lTipFont
		&cMatriz[nPosicao][12] 	:= M->TIPFON
		&cMatriz[nPosicao][13] 	:= M->ESTFON
		&cMatriz[nPosicao][14]	:= M->TAMFTE
		&cMatriz[nPosicao][15] 	:= M->CORFON
	else
		&cMatriz[nPosicao][12] 	:= ""
		&cMatriz[nPosicao][13] 	:= ""
		&cMatriz[nPosicao][14]	:= 0
		&cMatriz[nPosicao][15] 	:= ""
	endif
	
	
	If lCheckCBarra
		&cMatriz[nPosicao][9] := .T.
	Else
		&cMatriz[nPosicao][9] := .F.
	EndIf
	
	If M->LINHA > 0 .And. M->COLUNA > 0 .And. M->TAMANHO > 0
		If nFolder == 1
			aLbxCampo[nPosicao][1] := .T.
		ElseIf nFolder == 2
			aLbxEspres[nPosicao][1] := .T.
		EndIf
		
	Else
		If nFolder == 1
			aLbxCampo[nPosicao][1] := .F.
		ElseIf nFolder == 2
			aLbxEspres[nPosicao][1] := .F.
		EndIf
	EndIf
	
	oLbxCampo:SetArray(aLbxCampo)
	oLbxCampo:bLine:={||{if(	aLbxCampo[oLbxCampo:nAt,1] == .f.,oCinza,oAzul),;
	aLbxCampo[oLbxCampo:nAt,2],;
	aLbxCampo[oLbxCampo:nAt,3]}}
	If nFolder == 1
		oLbxCampo:Refresh()
	ElseIf nFolder == 2
		oLbxExpressao:Refresh()
	EndIf
	
	oPanelConf:lVisible := .F.
	lEditando := .F.
	
EndIf
lCheckCBarra := .F.
FS_MONTAETI()
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณFS_BTPAR()บ Autor ณ Rodrigo Xavier     บ Data ณ  Junho/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Botao de parametros                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_BTPAR()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis Privadas                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nInt      := 0
Local aButPar   := {}

Local aLogic    := { "And" , ")And", ")And(", "And(", "Or" , ")Or", ")Or(", "Or(" }

Private cCombo3
Private aItems3 := {}
Private cCombo4
Private aItems4 := {STR0030,STR0031}  // "0 - Nao gerar intervalo", "1 - Gerar intervalo"
Private nList   := 1
Private nOpca2  := 0
Private oAzul   := LoadBitmap( GetResources(), "BR_AZUL" )
Private oCinza  := LoadBitmap( GetResources(), "BR_CINZA" )


If Len(aLbxPar) == 0
	AADD(aLbxPar,({.F.,"","",1}))
EndIf

For nInt := 1 to Len(aLbx)
	If aLbx[nInt][1]
		AADD(aItems3,aLbx[nInt][2])
	EndIf
Next

aSize := MsAdvSize(.T.)
aObjects := {}
aAdd( aObjects, { 001, 100, .T., .T. } )

aSize[3] := aSize[3] * 0.75
aSize[4] := aSize[4] * 0.75
aSize[5] := aSize[5] * 0.75
aSize[6] := aSize[6] * 0.75

aInfo  := {aSize[1], aSize[2], aSize[3], aSize[4], 5, 5}
aPObjs := MsObjSize(aInfo, aObjects, .T.)

Aadd(aButPar	,{"bmpincluir", {|| FS_ARRAYPAR(1) }, STR0121, STR0122})      //"Adiciona Parametro as perguntas"###"Adiciona"
Aadd(aButPar	,{"excluir"   , {|| FS_ARRAYPAR(2) }, STR0123 , STR0034})  //"Remove Parametro das perguntas"###"Remove"

DEFINE MSDIALOG oDlgPar TITLE cCadastro + STR0054 FROM 000,000 TO (aPObjs[1][4]/2)+50,450 OF oMainWnd PIXEL //" - Parametros"
@ aPObjs[1][1], aPObjs[1][2] Say OemToAnsi(STR0029) Size aPObjs[1][1]+60, aPObjs[1][2]*2 OF oDlgPar PIXEL COLOR CLR_BLUE  // "Campo"
@ aPObjs[1][1], 080 Say OemToAnsi(STR0032) Size 075, 009 OF oDlgPar PIXEL COLOR CLR_BLUE  // "Tipo"
oCombo3 := tComboBox():New(aPObjs[1][1],aPObjs[1][2],{|u|if(PCount()>0,cCombo3:=u,cCombo3)},aItems3 ,075,20,oDlgPar,,,,,,.T.,,,,,,,,,"cCombo3")
oCombo4 := tComboBox():New(aPObjs[1][1],080,{|u|if(PCount()>0,cCombo4:=u,cCombo4)},aItems4 ,075,20,oDlgPar,,,,,,.T.,,,,,,,,,"cCombo4")

@ aPObjs[1][1]+20, 003 LISTBOX oLbxPar VAR cLbxPar FIELDS HEADER " ",;
OemtoAnsi("Campo"),;
OemtoAnsi(STR0032),; //"Tipo";
OemtoAnsi("Rel.Logico");
COLSIZES 10,65,100,40;
SIZE 220,100 OF oDlgPar PIXEL ON;
DBLCLICK (nPos:=oLbxPar:nAt,;
aLbxPar[nPos,4] := IIf( aLbxPar[nPos,4] == 8, 1 , aLbxPar[nPos,4] + 1 ),;
oLbxPar:Refresh(),;
oLbxPar:nAt:=nPos)

oLbxPar:SetArray(aLbxPar)
oLbxPar:bLine := {||{iif(aLbxPar[oLbxPar:nAt,1] == .f.,oCinza,oAzul),;
aLbxPar[oLbxPar:nAt,2],;
aLbxPar[oLbxPar:nAt,3],;
iif(aLbxPar[oLbxPar:nAt,4]<>0,aLogic[aLbxPar[oLbxPar:nAt,4]],"") }}

ACTIVATE MSDIALOG oDlgPar CENTERED ON INIT EnchoiceBar(oDlgPar, {|| nOpca2 := 2,oDlgPar:End()},{|| nOpca2 := 1,oDlgPar:End()},,aButPar)
Return( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณFS_ARRAYPAR()บ Autor ณ Rodrigo Xavier  บ Data ณ Junho/2003  บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Adiciona e exclui parametro no vetor                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ARRAYPAR(nOperacao)
Local aLogic    := { "And" , ")And", ")And(", "And(", "Or" , ")Or", ")Or(", "Or(" }
// 1 = Adicionar, 2 = Remover
If nOperacao == 1
	If Empty(aLbxPar[Len(aLbxPar)][2])
		aLbxPar[Len(aLbxPar)][1] := IIf(SubStr(cCombo4,1,1) == "0",.F.,.T.)
		aLbxPar[Len(aLbxPar)][2] := cCombo3
		aLbxPar[Len(aLbxPar)][3] := cCombo4
	Else
		AADD(aLbxPar,({IIf(SubStr(cCombo4,1,1) == "0",.F.,.T.), cCombo3, cCombo4, 0}))
	EndIf
Else
	aDel(aLbxPar,oLbxPar:nAt)
	aSize(aLbxPar,Len(aLbxPar)-1)
	If Len(aLbxPar) < 1
		AADD(aLbxPar,({.F.,"","",0}))
	EndIf
EndIf
oLbxPar:SetArray(aLbxPar)
oLbxPar:bLine := {||{if(aLbxPar[oLbxPar:nAt,1] == .f.,oCinza,oAzul),;
aLbxPar[oLbxPar:nAt,2],;
aLbxPar[oLbxPar:nAt,3],;
iif(aLbxPar[oLbxPar:nAt,4]<>0,aLogic[aLbxPar[oLbxPar:nAt,4]],"") }}
oLbxPar:Refresh()
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณFS_TABELA()บ Autor ณ Rodrigo Xavier    บ Data ณ Junho/2003  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Botao de parametros                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_TABELA()
DBSelectArea("SX3")
DBSetOrder(1)
If DBSeek(SubStr(cCombo2,1,3))
	aLbx := {}
	While !Eof() .And. SX3->X3_ARQUIVO == SubStr(cCombo2,1,3)
		If SX3->X3_CONTEXT <> "V"
			
			AADD(aLbx,({.f.,SX3->X3_CAMPO,SX3->X3_DESCRIC,0,0,0,"","",.F.,Space(Len(GC8->GC8_FONTE)),Space(Len(GC8->GC8_TAMFON)),"","",0,""}))
		EndIf
		DBSkip()
	End
	oLbx:SetArray(aLbx)
	oLbx:bLine:={||{if(aLbx[oLbx:nAt,1] == .f.,oNo,oTik),;
	aLbx[oLbx:nAt,2],;
	aLbx[oLbx:nAt,3]}}
	oLbx:Refresh()
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ FS_Marc()        ณ Autor: Rodrigo Xavier ณ Data ณJunho/2003บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao para marcar e desmarcar o listbox                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_Marc()
If aLbx[oLbx:nAt,1] == .F.
	aLbx[oLbx:nAt,1] := .T.
Else
	aLbx[oLbx:nAt,1] := .F.
Endif
oLbx:refresh()
lEditando := .F.
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ FS_BTCBARRA()    ณ Autor: Rodrigo Xavier ณ Data ณJunho/2003ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao habilitar e desabilitar o botao para configuracao doณฑฑ
ฑฑณ          ณ codigo de barras                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_BTCBARRA()
If lCheckCBarra
	oBtnCBarra:lVisible := .T.
Else
	oBtnCBarra:lVisible := .F.
Endif
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบFuncao    ณ FS_ABA   บ Autor ณ Rodrigo Xavier     บ Data ณ  Junho/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Inicializa o folder, habilita o aCols, o aHeader e aciona  บฑฑ
ฑฑบ          ณ o getdados na mudanca do folder                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ABA(nAba,nAbaAntiga)
nFolder := oFolder:nOption
If oFolder:nOption == 1  // "Campos"
	oPanelConf:lVisible := .F.
ElseIf oFolder:nOption == 2  // "Expressoes"
	oPanelConf:lVisible := .F.
EndIf
lEditando := .F.
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบFuncao    ณFS_CARCAM()บ Autor ณ Rodrigo Xavier    บ Data ณ  Junho/2003 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Carrega os campos de configuracao com o campo escolhido    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_CARCAM()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis locais                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nFolder := oFolder:nOption
Local cMatriz

If nFolder == 1
	cMatriz := "aCampos"
ElseIf nFolder == 2
	cMatriz := "aExpress"
EndIf
If !Empty(&cMatriz[nPos][3])
	If lEditando
		FS_PARGRV(.F.)
	EndIf
	oPanelConf:lVisible := .T.
	lEditando := .T.
	nPosicao  := nPos
	
	M->DESCR    	:= &cMatriz[nPos][3]
	M->LINHA    	:= &cMatriz[nPos][4]
	M->COLUNA   	:= &cMatriz[nPos][5]
	M->TAMANHO  	:= &cMatriz[nPos][6]
	M->EXPRES   	:= &cMatriz[nPos][7]
	lCheckCBarra := &cMatriz[nPos][9]
	M->FONTE					:= &cMatriz[nPos][10]
	M->TAMFON				:= &cMatriz[nPos][11]
	if lTipFont
		M->TIPFON  := &cMatriz[nPos][12]
		M->ESTFON  := &cMatriz[nPos][13]
		M->TAMFTE  := &cMatriz[nPos][14]
		M->CORFON  := &cMatriz[nPos][15]
	endif
	
	
	If oFolder:nOption == 1
		oEditExpressao:Disable()
		oEditDescricao:Disable()
		oEditLinha:SetFocus()
	ElseIf oFolder:nOption == 2
		oEditExpressao:Enable()
		oEditDescricao:Enable()
		oEditDescricao:SetFocus()
	EndIf
	
	If lCheckCBarra
		oBtnCBarra:lVisible := .T.
		oBtnFonte:Enable()
	Else
		oBtnCBarra:lVisible := .F.
		if !lTipFont
			oBtnFonte:Disable()
		endif
	EndIf
	
	If Substr(cCombo1,1,1) == "0"
		oBtnCBarra:Disable()
	Else
		oBtnCBarra:Enable()
	EndIf
	
	oCheckCBarra:Refresh()
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบFuncao    ณFS_ADDESP()บ Autor ณ Rodrigo Xavier    บ Data ณ  Junho/2003 บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Adiciona uma expressao                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ADDESP()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis locais                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
// Local cExpressao := ""

If lEditando
	FS_PARGRV(.F.)
EndIf

//Inclcuindo campo/Expressao
lAddCamExp := .T.

oPanelConf:lVisible := .T.
lEditando := .T.

M->DESCR     := Space(30)
M->LINHA     := 0
M->COLUNA    := 0
M->TAMANHO   := 0
M->EXPRES    := Space(200)
lCheckCBarra := .F.
M->FONTE					:= Space(Len(GC8->GC8_FONTE))
M->TAMFON				:= Space(Len(GC8->GC8_TAMFON))

nPos := Len(aExpress)
If Empty(aExpress[nPos][3])
	nPosicao := nPos
Else
	
	AADD(aExpress,({"E","E"+STRZERO(Len(aExpress)+1,5),M->DESCR,0,0,0,M->EXPRES,,.F.,"","","","",0,""}))
	AADD(aLbxEspres,({.f.,"E"+STRZERO(Len(aLbxEspres)+1,5),"",0,0,0,"","",0,"","","","",0,""}))
	
	nPos := Len(aExpress)
	nPosicao := nPos
EndIf

oEditExpressao:Enable()
oEditDescricao:Enable()
oEditDescricao:SetFocus()
oCheckCBarra:Refresh()
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณFS_CBAGRV บ Autor ณ Rodrigo Xavier     บ Data ณ Junho/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava as alteracoes do posicionamento e configuracoes do   บฑฑ
ฑฑบ          ณ codigo de barras                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_CBAGRV()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao das variaveis locais                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local nOpca3 := 0
Local aArea  := GetArea()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Definicao das variaveis privadas                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private aItems5  := {"EAN13","EAN8","UPCA","SUP5","CODE128","INT25","MAT25","IND25","CODABAR","CODE3_9"}
Private cCombo5  := 0
Private nPosicao := 2
Private nDigito  := 2

M->EDIT_VERTICAL    := 0
M->EDIT_HORIZONTAL  := 0
M->EDIT_TVERTICAL   := 0
M->EDIT_THORIZONTAL := 0
M->EDIT_POSICAO     := "H"
M->EDIT_DIGITO      := "N"

If oFolder:nOption == 1
	cMatriz := "aCampos"
ElseIf oFolder:nOption == 2
	cMatriz := "aExpress"
EndIf
cMatriz += "[nPos]"

DBSELECTAREA("GC8")
DBSetOrder(1)
IF DBSeek(xFilial("GC8") + GC7->GC7_CODETI /*+ &(cMatriz+"[2]") */ )
	While !Eof() .AND. xFilial("GC8") == GC8->GC8_FILIAL .And. GC8->GC8_CODETI == GC7->GC7_CODETI
		IF GC8->GC8_CAMPO == &(cMatriz+"[2]")
			EXIT
		ENDIF
		DbSkip()
	End
ENDIF
RestArea(aArea)
cMatriz += "[9]"
If &cMatriz
	M->EDIT_VERTICAL    := GC8->GC8_CBLIN
	M->EDIT_HORIZONTAL  := GC8->GC8_CBCOL
	M->EDIT_TVERTICAL   := GC8->GC8_CBTLIN
	M->EDIT_THORIZONTAL := GC8->GC8_CBTCOL
	M->EDIT_POSICAO     := GC8->GC8_CBDIR
	M->EDIT_DIGITO      := GC8->GC8_CBDIG
	cCombo5             := GC8->GC8_CBTIPO
EndIf

DEFINE MSDIALOG oDlgCBar TITLE cCadastro + STR0055 FROM 000,000 TO 300,415 OF oMainWnd PIXEL //" - C๓digo de barra"

@ 015, 003 Say OemToAnsi(STR0035) Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_RED   // "Configuracoes do posicionamento"
@ 025, 003 Say OemToAnsi(STR0012) Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_BLUE   // "Centimetros na vertical"
@ 034, 003 MSGet oEditVertical var M->EDIT_VERTICAL Size 100, 009 OF oDlgCBar Picture "99.999" PIXEL COLOR CLR_BLACK Valid &cFieldOk
@ 025, 105 Say OemToAnsi(STR0013) Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_BLUE   // "Centimetros na horizontal"
@ 034, 105 MSGet oEditHorizontal var M->EDIT_HORIZONTAL Size 100, 009 OF oDlgCBar Picture "99.999" PIXEL COLOR CLR_BLACK Valid &cFieldOk

@ 048, 003 Say OemToAnsi(STR0036) Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_RED   // "Configuracoes do tamanho"
@ 058, 003 Say OemToAnsi(STR0045) Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_BLUE   // "Centimetros na vertical"
@ 067, 003 MSGet oEditVertical var M->EDIT_TVERTICAL Size 100, 009 OF oDlgCBar Picture "99.999" PIXEL COLOR CLR_BLACK Valid &cFieldOk
@ 058, 105 Say OemToAnsi(STR0042) Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_BLUE   // "Centimetros na horizontal"
@ 067, 105 MSGet oEditHorizontal var M->EDIT_THORIZONTAL Size 100, 009 OF oDlgCBar Picture "99.999" PIXEL COLOR CLR_BLACK Valid &cFieldOk

@ 091, 003 Say OemToAnsi(STR0037) Size 100, 009 OF oDlgCBar PIXEL COLOR CLR_BLUE   // "Tipo do c๓digo de barra"
oCombo5 := tComboBox():New(100,003,{|u|if(PCount()>0,cCombo5:=u,cCombo5)},aItems5,100,20,oDlgCBar,,,,,,.T.,,,,,,,,,"cCombo5")

@ 125, 003 RADIO oVisual VAR nPosicao PROMPT OemToAnsi(STR0038),OemToAnsi(STR0039) SIZE  100,9 OF oDlgCBar PIXEL ;  // "Imprime na vertical" ### "Imprime na horizontal"
ON CHANGE (M->EDIT_POSICAO := Iif(nPosicao==1,"V","H"))
If M->EDIT_POSICAO == "V"
	nPosicao := 1
Else
	nPosicao := 2
EndIf

@ 125, 105 RADIO oDigito VAR nDigito PROMPT OemToAnsi(STR0040),OemToAnsi(STR0041) SIZE  100,9 OF oDlgCBar PIXEL ;  // "Calcula dํgito" ### "Nใo calcula dํgito"
ON CHANGE (M->EDIT_DIGITO := Iif(nDigito==1,"S","N"))
If M->EDIT_DIGITO == "S"
	nDigito := 1
Else
	nDigito := 2
EndIf

ACTIVATE MSDIALOG oDlgCBar CENTERED ON INIT EnchoiceBar(oDlgCBar, {|| nOpca3 := 2,oDlgCBar:End()},{|| nOpca3 := 1,oDlgCBar:End()})

If nOpca3 == 2
	If oFolder:nOption == 1
		cMatriz := "aCampos"
	ElseIf oFolder:nOption == 2
		cMatriz := "aExpress"
	EndIf
	cMatriz += "[nPos][2]"
	nP := Ascan(aCodBarra,{|aVet| aVet[1] == &cMatriz})
	If nP > 0
		aCodBarra[nP][2] := M->EDIT_VERTICAL
		aCodBarra[nP][3] := M->EDIT_HORIZONTAL
		aCodBarra[nP][4] := M->EDIT_TVERTICAL
		aCodBarra[nP][5] := M->EDIT_THORIZONTAL
		aCodBarra[nP][6] := cCombo5
		aCodBarra[nP][7] := M->EDIT_POSICAO
		aCodBarra[nP][8] := M->EDIT_DIGITO
	Else
		AADD(aCodBarra,{&cMatriz,M->EDIT_VERTICAL,M->EDIT_HORIZONTAL,M->EDIT_TVERTICAL,;
		M->EDIT_THORIZONTAL,cCombo5,M->EDIT_POSICAO,M->EDIT_DIGITO})
	EndIf
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบFuncao    ณHSR71IMP()บ Autor ณ Rodrigo Xavier     บ Data ณ  Junho/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao das etiquetas                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSR71IMP(aParam)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis privadas                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local Cont
Local cCont
Local cIniFile := "C:\MSCBSPOOL.INI"  // controle da fila de impressao
Local cImp := "", cPorta := ""

SetPrvt("cPerg,cString,lAbortPrint,NLIN,NOMEPROG")
SetPrvt("WNREL,CDESC1,CDESC2,CDESC3,LHABILDICT,AORDEMINDEX")
SetPrvt("LHABILCOMPR,CTAMRELATO,ARETURN,NLASTKEY,CCABEC1,CCABEC2")
SetPrvt("NomeProg,nTipo,CTITULO")

Private aParametros := {}
Private nPlogic     := 1  // utilizado para definir a expressao logica dos parametros a ser utilizada no set filter

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define os tipos de fontes                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
// nome            	/lar/alt/fromuser/bold/italic/underline/
oFont1 				:= TFont():New("Arial"      	  			,09,08,,.F.,,,,,.F.) //
oFont2 				:= TFont():New("Arial"      	  			,09,10,,.F.,,,,,.F.) //Conteudo dos Campos
oFont3Bold	:= TFont():New("Arial Black"	  			,09,20,,.T.,,,,,.F.) //Titulo Relatorio
oFont4Bold	:= TFont():New("Arial Black"	  			,10,13,,.T.,,,,,.F.) //Titulo Itens
oFont4 				:= TFont():New("Arial"      	  			,09,12,,.T.,,,,,.F.) //Dados do Recibo de Entrega
oFont5 				:= TFont():New("Arial"      	  			,09,18,,.T.,,,,,.F.) //Codigo de Compensa็ใo do Banco
oFont6 				:= TFont():New("Arial"      	  			,09,14,,.T.,,,,,.F.) //Codigo de Compensa็ใo do Banco
oFont7 				:= TFont():New("Arial"         			,09,10,,.T.,,,,,.F.) //Conteudo dos Campos em Negrito
oFont8 				:= TFont():New("Arial"          		,09,09,,.F.,,,,,.F.) //Dados do Cliente
oFont9 				:= TFont():New("Times New Roman"		,09,10,,.T.,,,,,.F.) //Linha Digitavel
oFont10				:= TFont():New("Arial"      	  			,09,08,,.F.,,.T.,,,.F.) //

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define parametros para o SetPrint                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cString     := GC7->GC7_TABELA
cTitulo     := GC7->GC7_DESCR
Wnrel       := GC7->GC7_CODETI
cTipoImp    := SubStr(GC7->GC7_TIPO,1,1)
cDesc1      := ""
cDesc2      := ""
cDesc3      := ""
lHabilDict  := .F.     // habilita dicionario
aOrdemIndex := NIL     // array ordem de indexacao
lHabilCompr := .T.     // habilita compressao
cTamRelato  := "P"     // "P"=80, "M"=132, "G"=220

aParametros := {}
aCamposImp  := {}
aRegistros  := {}
aMv_Param   := {}

DBSelectArea("GC8")
DBSetOrder(1)//GC8_CODETI + GC8_SEQPAR
DBSeek(xFilial("GC8") + GC7->GC7_CODETI)
While !Eof() .And. GC8->GC8_CODETI == GC7->GC7_CODETI
	
	IIf ( HS_ExisDic({{"C","GC8_PLOGIC"}} , .F.) , nPlogic :=  IIF(GC8->GC8_PLOGIC==0,1,GC8->GC8_PLOGIC)   , nPlogic := 1 )
	
	If GC8->GC8_PARAM == "1"
		If GC8->GC8_TPARAM == "1"
			AADD(aParametros, {GC8->GC8_CAMPO, GC8->GC8_SEQPAR, nPlogic,1 })  // se gera intervalo forca o 1 campo com AND e o sengundo com a expressao adotada
			AADD(aParametros, {GC8->GC8_CAMPO, GC8->GC8_SEQPAR, nPlogic,2 })
		Else
			AADD(aParametros, {GC8->GC8_CAMPO, GC8->GC8_SEQPAR, nPlogic,0 })
		EndIf
	EndIf
	DBSkip()
	
End

If Len(aParametros) > 0
	cPerg := "R71" + SUBSTR(GC7->GC7_CODETI,4,3)
	cPerg := PADR(cPerg, Len(SX1->X1_GRUPO))
	GeraX1()
	
	If ValType(aParam) == "A"
		
		For Cont := 1 To Len(aParam)
			cCont := StrZero(Cont, 2)
			mv_par&cCont := aParam[Cont]
		Next Cont
		
	Elseif !fPergImp(cPerg)		//Elseif !Pergunte(cPerg,.T.)
		Return
	Endif
Else
	msgStop(STR0078) //"Atencao...Nao tem parametros de impressao...Para configurar parametros de impressao clique em Alterar, selecione os campos(para parametros) no Browse e depois clique no botao parametros..."
	Return( Nil )
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define parametros para o Set Default                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aReturn  := { STR0056, 1, STR0057, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
nLastKey := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define parametros para o Cabealho do Relatorio                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cCabec1	    := ""
cCabec2	    := ""
NomeProg	   := "HSPAHR71"
nTipo		     := 18
nLin 		     := 80
m_pag       := 01
lAbortPrint := .F.

If cTipoImp == "0"   // Impressora Matricial
	
	If nLastKey == 27
		Return
	Endif
	
Elseif cTipoImp == "2" // Impressora termica
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Controle da fila de impressao ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If HS_ExisDic({{"C","GC7_FILA"}} , .F.)
		If GC7->GC7_FILA == "3"  // se o controle da fila for PROTHEUS
			cImp       := GetPvProfString("SETUP", "IMPRESSORA", "", cIniFile )
			cPorta     := GetPvProfString("SETUP", "PORTA"	, "", cIniFile )
		EndIf
		//MSCBPRINTER(<ModelPrt>, <cPorta>,<nDensidade>,<nTamanho>,<lSrv>,<nPorta>,<cServer>, <cEnv>,  <nMemoria>, <cFila>, <lDrvWin>, <cPathSpool>)
		If     GC7->GC7_FILA == "1"  // se NAO houver o controle da fila
			GC7->(MSCBPRINTER(GC7_MODPRN, GC7_PORTA + IIf(!Empty(GC7_SETUP), ":" + GC7_SETUP, ""), Nil, IIf(Empty(GC7_LINETI), NIL, GC7_LINETI * 10), .F., Nil, Nil, Nil, Nil,/*"Teste"*/, /*.F.*/, Nil))
		ElseIf GC7->GC7_FILA == "2"  // se o Windows controla a fila de impressao
			GC7->(MSCBPRINTER(GC7_MODPRN, GC7_PORTA + IIf(!Empty(GC7_SETUP), ":" + GC7_SETUP, ""), Nil, IIf(Empty(GC7_LINETI), NIL, GC7_LINETI * 10), .F., Nil, Nil, Nil, Nil,/*"Teste"*/, .T., Nil))
		ElseIf GC7->GC7_FILA == "3"  // se o Protheus controla a fila de impressao
			// se o controle for do Protheus pega a impressora e a porta do MSCBSPOOL - REMOTE  em C:\MSCBSPOOL.INI
			GC7->(MSCBPRINTER(cImp, cPorta + IIf(!Empty(GC7_SETUP), ":" + GC7_SETUP, ""), Nil, IIf(Empty(GC7_LINETI), NIL, GC7_LINETI * 10), .F., Nil, Nil, Nil, Nil,ALLTRIM(GC7->GC7_NOMEFI),/*.F.*/, Nil))
		ElseIf GC7->GC7_FILA == "4"  // se o controle da fila for VIRTUAL
			GC7->(MSCBPRINTER(GC7_MODPRN, GC7_PORTA + IIf(!Empty(GC7_SETUP), ":" + GC7_SETUP, ""), Nil, IIf(Empty(GC7_LINETI), NIL, GC7_LINETI * 10), .F., Nil, Nil, Nil, Nil,/*Teste*/, /*.F.*/, Nil))
		Else
			GC7->(MSCBPRINTER(GC7_MODPRN, GC7_PORTA + IIf(!Empty(GC7_SETUP), ":" + GC7_SETUP, ""), Nil, IIf(Empty(GC7_LINETI), NIL, GC7_LINETI * 10), .F., Nil, Nil, Nil, Nil,/*"Teste"*/, /*.F.*/, Nil))
		EndIf
	Else
		GC7->(MSCBPRINTER(GC7_MODPRN, GC7_PORTA + IIf(!Empty(GC7_SETUP), ":" + GC7_SETUP, ""), Nil, IIf(Empty(GC7_LINETI), NIL, GC7_LINETI * 10), .F., Nil, Nil, Nil, Nil,/*"Teste"*/,/*.F.*/, Nil))
	EndIf
	MSCBCHKStatus(.F.)
EndIf

nTipo := 18
RptStatus({||HSPR71ImpP()},cTitulo)

Return( Nil )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPR71ImpPบ Autor ณRodrigo Xavier      บ Data ณ Junho/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressao                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function HSPR71ImpP()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis locais                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local lPrimeiro    := .T.
Local cCampoImp    := ""
Local cCriarCampo  := ""
Local cValExpre    := ""
Local nQtdEti      := 0
Local nInt01       := 0
Local nInt2        := 0
Local nInt3        := 0
Local nInt         := 0
Local nIntAnt      := 1
Local cMinhaTabela := ""
Local nLEtiq	      := 0
Local nLinAnt      := 0
Local nTamImpress  := 0
Local cCampoTxt    := ""
Local nTamLin      := 0
Local nCtaFor      := 1
Local cPLogico     := ""
Local cKet         := ""
Local cExtrai      := ""
Local bBlock       := ErrorBlock(), bErro := ErrorBlock( { |e| ChekBug(e) } )

Local oFontPrint
Local lPrintImg    := .F.
Local cPathR71    := GetSrvProfString("Startpath","")
Local cLogoR71    := "R71LOGO.bmp"
Local oImgR71
Local aFonTempImp
Local aFontImpr[1][3]
Local aTemp[1][7]

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis privadas                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cSql       := ""
Private aRegistros := {}
Private aCamposImp := {}
Private aCamImp    := {}

Private lJaImpLogo := .F. // ponteiro que vai dizer se ja imprimiu o logo.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Impressao de etiquetas MODO TEXTO:                                ณ
//ณ Define Variavel para impressao em modo texto direto na porta,     ณ
//ณ Esta variavel ira conter as linhas a serem impressas...           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cImpPort   := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Controle de Bloqueio do Spool de impressao para um mapeamento de  ณ
//ณ impressora para impedir que etiquetas se misturem na impressao.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private bLocUnLock := {|O,K| IIF( O == 1 , LockByName(K,.T.,.T.,.F.), UnLockByName(K,.T.,.T.,.F. ) ) }
Private cNetUse    := ""

Private lRetErro := .T.

If HS_ExisDic({{"C","GC7_FILA"}} , .F.)
	If GC7->GC7_FILA == "4"  // se o controle da fila for VIRTUAL
		cNetUse := FS_LENUSE( GC7->GC7_PORTA )  // retorno e do tipo:   "\\ADM002\FX-1170"
		If !Empty(cNetUse)
			IF !Eval ( bLocUnLock, 1, cNetUse )  // L O C K
				HS_MsgInf(STR0091, STR0092, STR0093)  //"A Impressora ja esta sendo usada por outro usuario... favor tentar a impressao mais tarde ok..."###"Atencao"###"Impressao de Etiquetas"
				RETURN(nIL)
			EndIf
		EndIf
	EndIf
EndIf

// se existir o campo de controle de rotacao entao pega o seu valor se nao cRotacao foi definida no comeco do fonte como "N"
If HS_ExisDic({{"C","GC7_ROTACA"}} , .F.)
	cRotacao	:=	IIF(GC7->GC7_ROTACA=="1","N",IIF(GC7->GC7_ROTACA=="2","R",IIF(GC7->GC7_ROTACA=="3","I",IIF(GC7->GC7_ROTACA=="4","B","N"))))
EndIf

DBSelectArea("GC8")
DBSetOrder(1)
If DBSeek(xFilial("GC8")+GC7->GC7_CODETI)
	While !Eof() .And. GC8->GC8_CODETI == GC7->GC7_CODETI
		SX3->(DBSetOrder(2))
		If SX3->(DBSeek(GC8->GC8_CAMPO))
			cCriarCampo := SX3->X3_CAMPO
		EndIf
		If GC8->GC8_TAMAN > 0 .And. GC8->GC8_LINHA > 0 .And. GC8->GC8_COLUNA > 0
			if lTipFont
				AADD(aCamposImp,{GC8->GC8_CAMPO, GC8->GC8_LINHA, GC8->GC8_COLUNA, GC8->GC8_TAMAN, GC8->GC8_EXPRES, GC8->GC8_CODBAR,;
				GC8->GC8_CBLIN, GC8->GC8_CBCOL, GC8->GC8_CBTLIN, GC8->GC8_CBTCOL, GC8->GC8_CBTIPO, GC8->GC8_CBDIR, GC8->GC8_CBDIG,;
				GC8->GC8_FONTE, GC8->GC8_TAMFON, GC8->GC8_DESCR, GC8_TIPFON, GC8_ESTFON, GC8_TAMFTE, GC8_CORFON})
			else
				AADD(aCamposImp,{GC8->GC8_CAMPO, GC8->GC8_LINHA, GC8->GC8_COLUNA, GC8->GC8_TAMAN, GC8->GC8_EXPRES, GC8->GC8_CODBAR,;
				GC8->GC8_CBLIN, GC8->GC8_CBCOL, GC8->GC8_CBTLIN, GC8->GC8_CBTCOL, GC8->GC8_CBTIPO, GC8->GC8_CBDIR, GC8->GC8_CBDIG,;
				GC8->GC8_FONTE, GC8->GC8_TAMFON, GC8->GC8_DESCR})
			endif
		EndIf
		DBSkip()
		
		If SX3->X3_CONTEXT <> "V"
			cMinhaTabela := GC7->GC7_TABELA +"->(FieldGet(FieldPos(SX3->X3_CAMPO)))"
			M->&(cCriarCampo):= &cMinhaTabela
		EndIf
	EndDo
	
	For nInt01 := 1 to Len(aMv_Param)
		cSinal := "=="
		cTipo := Posicione("SX3", 2, aParametros[nInt01, 1], "X3_TIPO")
		If nInt01 < Len(aParametros)
			If aParametros[nInt01+1, 1] == aParametros[nInt01, 1]
				cSinal := ">="
			EndIf
		EndIf
		If nInt01 > 1
			If aParametros[nInt01-1, 1] == aParametros[nInt01, 1]
				cSinal := "<="
			EndIf
		EndIf
		If ValType(&(aMv_Param[nInt01])) <> cTipo
			HS_MsgInf(STR0079 + ALLTRIM(STR(nInt01)) + STR0080, STR0014, STR0001) //"Parametro ["###"] configurado na etiqueta(Cadastro de Etiqueta) com o tipo diferente do informado no cadastro da ficha(Cadastro de Setor)"###"Aten็ใo"###"Etiquetas"
			
			If HS_ExisDic({{"C","GC7_FILA"}} , .F.)
				If GC7->GC7_FILA == "4"  // se o controle da fila for VIRTUAL
					If !Empty(cNetUse)
						Eval ( bLocUnlock, 2, cNetUse ) // UNLOCK
					EndIf
				EndIf
			EndIf
			
			Return(Nil)
		EndIf
		
		cPLogico := ""
		cKet     := ""
		
		If     aParametros[nInt01,3] == 1 // AND
			cPLogico := "   .And.   "
		ElseIf aParametros[nInt01,3] == 2 .AND. (aParametros[nInt01,4] == 2 .Or. aParametros[nInt01,4] == 0) // ) AND
			cKet     := " ) .And.   "
		ElseIf aParametros[nInt01,3] == 3 .AND. (aParametros[nInt01,4] == 2 .Or. aParametros[nInt01,4] == 0) // ) AND  (
			cKet     := " ) .And. ( "
		ElseIf aParametros[nInt01,3] == 4 .AND. (aParametros[nInt01,4] == 2 .Or. aParametros[nInt01,4] == 0) // AND  (
			cKet     := "   .And. ( "
		ElseIf aParametros[nInt01,3] == 5 // OR
			cPLogico := "   .Or.    "
		ElseIf aParametros[nInt01,3] == 6 .AND. (aParametros[nInt01,4] == 2 .Or. aParametros[nInt01,4] == 0) // ) OR
			cKet     := " ) .Or.    "
		ElseIf aParametros[nInt01,3] == 7 .AND. (aParametros[nInt01,4] == 2 .Or. aParametros[nInt01,4] == 0) // ) OR  (
			cKet     := " ) .Or. (  "
		ElseIf aParametros[nInt01,3] == 8 .AND. (aParametros[nInt01,4] == 2 .Or. aParametros[nInt01,4] == 0) // OR  (
			cKet     := "   .Or. (  "
		Else
			cPLogico := "   .Or.    "
		EndIf
		
		If cTipo == "D"
			If !Empty(DToS(&(aMv_Param[nInt01])))
				cSql += "DtoS(" + GC7->GC7_TABELA + "->" + aParametros[nInt01, 1] + ") " + cSinal + " '" + DToS(&(aMv_Param[nInt01])) + "'" + cPLogico
			EndIf
		ElseIf cTipo == "N"
			If !Empty(AllTrim(Str(&(aMv_Param[nInt01]))))
				cSql += GC7->GC7_TABELA + "->" + aParametros[nInt01, 1] + " " + cSinal + " " + AllTrim(Str(&(aMv_Param[nInt01]))) + cPLogico
			EndIf
		ElseIf cTipo == "C"
			If !Empty(&(aMv_Param[nInt01]))
				cSql += GC7->GC7_TABELA + "->" + aParametros[nInt01, 1] + " " + cSinal + " '" + &(aMv_Param[nInt01]) + "'" + cPLogico
			EndIf
		EndIf
		
		cExtrai := ALLTRIM(SUBSTR(cSql,(Len(cSql)-9), 10))
		
		If cExtrai $ ".And./.Or."
			If !Empty(cKet)
				cSql := SUBSTR(cSql,1,Len(cSql)-9)
			EndIf
			cSql += cKet
		Else
			cSql += cKet
		EndIf
		
		
	Next
	
	SX3->(DBSetOrder(1))
	SX3->(DBSeek(GC7->GC7_TABELA))
	
EndIf

DbSelectArea(GC7->GC7_TABELA)

If EMPTY(cSql)
	HS_MsgInf(STR0074, STR0014, STR0001) //"Nenhum registro foi encontrado"###"Aten็ใo"###"Etiquetas"
	If HS_ExisDic({{"C","GC7_FILA"}} , .F.)
		If GC7->GC7_FILA == "4"  // se o controle da fila for VIRTUAL
			If !Empty(cNetUse)
				Eval ( bLocUnlock, 2, cNetUse ) // UNLOCK
			EndIf
		EndIf
	EndIf
	Return(Nil)
EndIf

While at(" .And. (  ) ",cSql) <> 0
	cSql := StrTran(cSql, " .And. (  ) ", "")
EndDo

cSql := SUBSTR(cSql, 1, Len(cSql)-9)

if at(" .Or. (  ) ",cSql) <> 0
	While at(" .Or. (  ) ",cSql) <> 0
		cSql := StrTran(cSql, " .Or. (  ) ", "")
	EndDo
	cSql := SUBSTR(cSql, 1, Len(cSql)-9)
EndIf

//Testa a condi็ใo antes de executar o filtro
&(cSql)

ErrorBlock(bBlock)

If !lRetErro
	Return(Nil)
EndIf

Set Filter To &(Alltrim(cSql))

//cFiltro := BuildExpr(GC7->GC7_TABELA, oMainWnd, SUBSTR(cSql,1,Len(cSql)-6) , .T.)

DbSetOrder(1)
DBGotop()

SetRegua(RecCount() + RecCount())

aCamImp := aClone(aCamposImp)
ASORT(aCamposImp,,,{|x,y|x[2]<y[2]})


While !Eof()
	For nQtdEti := 1 to mv_Par01
		if lTipFont
			aAdd(aRegistros, Array(Len(aCamposImp)+1,6)) // Cria Vertor Em Branco
		else
			aAdd(aRegistros, Array(Len(aCamposImp)+1)) // Cria Vertor Em Branco
		endif
		
		For nInt := 1 to Len(aCamposImp)
			
			SX3->(DBSetOrder(2))
			If SX3->(DBSeek(aCamposImp[nInt][1]))
				cCampoImp := GC7->GC7_TABELA + "->" + aCamposImp[nInt][1]
			Else
				cCampoImp := aCamposImp[nInt][1]
			EndIf
			
			cTipo := Posicione("SX3", 2, SubStr(cCampoImp,6,Len(cCampoImp)-5), "X3_TIPO")
			
			if lTipFont
				If cTipo == "C"
					aRegistros[Len(aRegistros)][nInt][1] := AllTrim(&cCampoImp)
				ElseIf cTipo == "N"
					aRegistros[Len(aRegistros)][nInt][1] := Transform(&(cCampoImp),"")
				ElseIf cTipo == "D"
					aRegistros[Len(aRegistros)][nInt][1] := DtoC(&(cCampoImp))
				Else
					cTipo := ValType(&(aCamposImp[nInt][5]))
					If cTipo == "C"
						aRegistros[Len(aRegistros)][nInt] [1]:= AllTrim(&(aCamposImp[nInt][5]))
					Elseif cTipo == "N"
						aRegistros[Len(aRegistros)][nInt] [1]:= Transform(&(aCamposImp[nInt][5]),"")
					Elseif cTipo == "D"
						aRegistros[Len(aRegistros)][nInt] [1]:= DtoC(&(aCamposImp[nInt][5]))
					Elseif cTipo == "U" // Se indefinido move espaco
						aRegistros[Len(aRegistros)][nInt] [1]:= " "
					Endif
				Endif
				aRegistros[Len(aRegistros)][nInt][2] := aCamposImp[nInt][17]
				aRegistros[Len(aRegistros)][nInt][3] := aCamposImp[nInt][18]
				aRegistros[Len(aRegistros)][nInt][4] := aCamposImp[nInt][19]
				aRegistros[Len(aRegistros)][nInt][5] := aCamposImp[nInt][20]
				aRegistros[Len(aRegistros)][nInt][6] := .F.
				
			else
				If cTipo == "C"
					aRegistros[Len(aRegistros)][nInt] := AllTrim(&cCampoImp)
				ElseIf cTipo == "N"
					aRegistros[Len(aRegistros)][nInt] := Transform(&(cCampoImp),"")
				ElseIf cTipo == "D"
					aRegistros[Len(aRegistros)][nInt] := DtoC(&(cCampoImp))
				Else
					cTipo := ValType(&(aCamposImp[nInt][5]))
					If cTipo == "C"
						aRegistros[Len(aRegistros)][nInt] := AllTrim(&(aCamposImp[nInt][5]))
					Elseif cTipo == "N"
						aRegistros[Len(aRegistros)][nInt] := Transform(&(aCamposImp[nInt][5]),"")
					Elseif cTipo == "D"
						aRegistros[Len(aRegistros)][nInt] := DtoC(&(aCamposImp[nInt][5]))
					Elseif cTipo == "U" // Se indefinido move espaco
						aRegistros[Len(aRegistros)][nInt] := " "
					Endif
				Endif
			endif
			
		Next nInt1
	Next nInt
	
	DbSkip()
	IncRegua()
Enddo

DbClearFilter()

If !lIExterno .OR. lContrQtd
	If !HS_R71FIL()
		If HS_ExisDic({{"C","GC7_FILA"}} , .F.)
			If GC7->GC7_FILA == "4"  // se o controle da fila for VIRTUAL
				If !Empty(cNetUse)
					Eval ( bLocUnlock, 2, cNetUse ) // UNLOCK
				EndIf
			EndIf
		EndIf
		Return( NIL )
	EndIf
EndIf

If cTipoImp == "0"
	oPr := ReturnPrtObj()
Elseif cTipoImp == "1"
	oPr:=TMSPrinter():New("Protheus")
	oPr:Setup()
	oPr:SetPortrait()
	oPr:StartPage()
Endif

If cTipoImp == "0"
	nLin := 1
Elseif cTipoImp == "1"
	nLin := 0
EndIf

nLinhaAtual := 0  // Linha de etiqueta
nFatorCol   := GC7->GC7_QTDCOL - 1
nLinAnt     := nLin
nTamImpress := 0
nTamLin     := 0
nIntAnt     := 1
nRegAnt	  := 0

For nInt := 1 to Len(aRegistros)
	nLinhaEtiqueta := 0
	nLinhaAtual++
	nTamanVertical := Int(GC7->GC7_LINETI * 19 / 8)
	nTamImpress := 0
	nTamLin     := 0
	
	If nInt > 1
		nIntAnt := 0
	EndIf
	
	If cTipoImp == "2"  // Impressora termica
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Carrega logo padrao convertido de .bmp para .grf                  ณ
		//ณ MSCBLoadGrf                                                       ณ
		//ณ Tipo: Impressใo                                                   ณ
		//ณ Carrega uma imagem para mem๓ria da impressora                     ณ
		//ณ Observa็๕es                                                       ณ
		//ณ Para o padrใo Zebra, arquivo do grแfico tem que ser do tipo GRF,  ณ
		//ณ gerado atrav้s de um PCX ou TIF no software fornecido pelo        ณ
		//ณ fabricante da zebra.                                              ณ
		//ณ Para o padrใo Allegro e Eltron, arquivo do grแfico pode ser do    ณ
		//ณ tipo BMP, PCX e IMG. Nใo precisa ser convertido.                  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty(GC7->GC7_LOGO)
			MSCBLOADGRF(alltrim(GC7->GC7_LOGO))
		EndIf
		
		//CbBegin(1, 4)
		MsCbBegin()
		
	ElseIf cTipoImp == "1" // Impressora Grafica
		oPr:StartPage()
	Endif
	
	For nInt2 := 1 to Len(aCamposImp)    // FOR DE IMPRESSรO DOS CAMPOS
		
		If aCamposImp[nInt2][2] <= 0 .Or. aCamposImp[nInt2][3] <= 0 .Or. aCamposImp[nInt2][4] <= 0 // LINHA, COLUNA E TAMANHO
			Loop
		EndIf
		
		For nInt3 := 0 to GC7->GC7_QTDCOL-1 //FOR DE IMPRESSAO DAS COLUNAS
			nColuna := nInt3 * GC7->GC7_COLETI * 3.8 + aCamposImp[nInt2][3]
			nColImg := nInt3 * GC7->GC7_COLETI * 3.8 
			nTamCada := aCamposImp[nInt2][3]
			
			If nInt + nInt3 > Len(aRegistros)
				Exit
			EndIf
			
			If aCamposImp[nInt2][2] > 0 .And. aCamposImp[nInt2][3] > 0 .And. aCamposImp[nInt2][4] > 0 // LINHA, COLUNA E TAMANHO
				
				nLinhaEtiqueta++
				cTipo := Posicione("SX3", 2, aCamposImp[nInt2][1], "X3_TIPO")
				
				If cTipoImp == "0"
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Impressao de etiquetas MODO TEXTO:                                ณ
					//ณ Concatena linhas de impressao (linhas da etiqueta) para serem     ณ
					//ณ enviadas a porta, no final da rotina.                             ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If !Empty(aCamposImp[nInt2][11]) .and. aCamposImp[nInt2][6]
						MsBar3(aCamposImp[nInt2][11],;
						aCamposImp[nInt2][7] + (GC7->GC7_LINETI*(nLin-1)),;
						aCamposImp[nInt2][8] + (nColuna/4),;
						iIf(lTipFont, aRegistros[nInt+nInt3][nInt2][1], aRegistros[nInt+nInt3][nInt2]),;
						oPr,;
						Iif(aCamposImp[nInt2][13] == "S",.T.,.F.),,;
						Iif(aCamposImp[nInt2][12] == "H",.T.,.F.),;
						aCamposImp[nInt2][10],;
						aCamposImp[nInt2][9],,,,.T.)
						
					Else
						
						If nLinAnt != nLin     // BOPS 132259
							For nCtaFor := 1 to nLin-nLinAnt
								cImpPort    := cImpPort + CHR(13)+CHR(10) // controle de mudanca de linha
							Next
							If nInt != nIntAnt
								cImpPort := cImpPort + CHR(13)+CHR(10) // controle de mudanca de linha
								nIntAnt  := nInt
							EndIf
							nLinAnt     := nLin
							nTamImpress := 0
							nTamLin     := 0
						EndIf
						
						cCampoTxt := Alltrim(iIf(lTipFont, aRegistros[nInt+nInt3][nInt2][1], aRegistros[nInt+nInt3][nInt2])) // BOPS 132259
						
						//IF !EMPTY(aRegistros[nInt+nInt3][nInt2])  // 01/09/07 BOPS 132158  verifica se a linha nao esta definida
						IF !EMPTY(iIf(lTipFont, aRegistros[nInt+nInt3][nInt2][1], aRegistros[nInt+nInt3][nInt2]))  // 01/09/07 BOPS 132158  verifica se a linha nao esta definida
							nTamImpress += IIf((nColuna - nTamLin)==1,0,(nColuna - nTamLin)) // BOPS 132259
							cImpPort    := ALLTRIM(cImpPort) + SPACE(nTamImpress) + cCampoTxt
							nTamImpress := 0
							nTamLin     := len(cCampoTxt)
						Else // se nao tiver nada em E00001...na linha definida entao imprime em branco a linha!  BOPS 132158
							nTamImpress += nTamLin
							cImpPort    += SPACE(nTamImpress)+ ""
							nTamImpress := 0
							nTamLin     := 0
						EndIf
						
					Endif
				Elseif cTipoImp == "1"
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Impressao de etiquetas MODO GRAFICO                               ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					nLEtiqOld := nLEtiq
					nLEtiq    := ((nLinhaAtual - 1) * (GC7->GC7_LINETI * 138)) + (aCamposImp[nInt2][2] * GC7->GC7_PIXLIN) //50.59
					
					If HS_ExisDic({{"C","GC7_MARSUP"}} , .F.)  // controle de margem superior 10/12/07
						nLEtiq     := nLEtiq + ( GC7->GC7_MARSUP * GC7->GC7_PIXLIN )
						// alinha do codigo de barra nao controla a margem por aqui e sim no cadastro informado quantos centimentos a partir do topo no campo "CENTIMETROS DO TOPO"
						nLEtiq += 25.295
					EndIf
					
					/* Se passou a 1 fileira horizonta de etiquetas e pulou para a segunda fileira de etiquetas e for a 1 linha da proxima fileira entao: */
					If nLinhaAtual > 1  // retorna uma linha que estaria sendo calculada sempre a mais quando muda a fileira de etiqueta 10/12/07
						nLEtiq := nLEtiq - ((nLinhaAtual-1)*GC7->GC7_PIXLIN)
					EndIf
					
					If !Empty(aCamposImp[nInt2][11]) .and. aCamposImp[nInt2][6]
						MsBar3(aCamposImp[nInt2][11],;                                      // tipo do codigo code128 etc...
						aCamposImp[nInt2][7] + ((GC7->GC7_LINETI*(nLinhaAtual-1))/2),;  // Linha
						aCamposImp[nInt2][8] + (nColuna/8),;                         // Coluna
						iIf(lTipFont, aRegistros[nInt+nInt3][nInt2][1], aRegistros[nInt+nInt3][nInt2]),;                              // Variavel do codigo de barras
						oPr,;                                                        // objeto
						Iif(aCamposImp[nInt2][13] == "S",.T.,.F.),,;               // direcao
						Iif(aCamposImp[nInt2][12] == "H",.T.,.F.),;                // digito
						aCamposImp[nInt2][10],;                                     // espacamento entre barras
						aCamposImp[nInt2][9],;                                      // altura
						,,,.F.)
						
					Else
						
						if lTipFont .and. !aRegistros[nInt+nInt3][1][6]///!lPrintImg .AND. nRegAnt != nInt
							FErase(cPathR71 + cLogoR71)
							
							if !empty(GC7->GC7_LOGO)
								
								if RepExtract(alltrim(GC7->GC7_LOGO), cPathR71 + cLogoR71)
									//Temporario - somente par aobter tamanho da imagem
									DEFINE MSDIALOG oPanTemp TITLE "Temp" FROM 0,0 TO 1000,1000 PIXEL //"Aproveitamento de pagina"
									@ 012,012 BITMAP oImgR71 RESNAME cPathR71 + cLogoR71 PIXEL NOBORDER OF oPanTemp
									nPosImgSum := nInt3 * GC7->GC7_COLETI * 3.8 + GC7->GC7_XLOGO//(GC7->GC7_XLOGO - nTamCada)
									oPr:SayBitmap(nLEtiq+ Int(GC7->GC7_YLOGO * 25 / 8), (nPosImgSum*29.59), cPathR71 + cLogoR71, oImgR71:nClientWidth, oImgR71:nClientHeight)
									//oPr:SayBitmap(GC7->GC7_YLOGO, GC7->GC7_XLOGO, cPathR71 + cLogoR71, oImgR71:nClientWidth, oImgR71:nClientHeight)
									
									aRegistros[nInt+nInt3][1][6] := .T.
								endif 
								FreeObj(oPanTemp)
							endif
						endif
						IF !Empty(iIf(lTipFont, aRegistros[nInt+nInt3][nInt2][1], aRegistros[nInt+nInt3][nInt2]))  // 01/09/07 BOPS 132158  verifica se a linha nao esta definida
							
							if lTipFont
								aTemp[1][1] := ""
								aTemp[1][2] := ""
								aTemp[1][3] := ""
								aTemp[1][4] := aRegistros[nInt+nInt3][nInt2][2]
								aTemp[1][5] := aRegistros[nInt+nInt3][nInt2][3]
								aTemp[1][6] := aRegistros[nInt+nInt3][nInt2][4]
								aTemp[1][7] := aRegistros[nInt+nInt3][nInt2][5]
								
								aFonTempImp := FS_retFontR71(aTemp) //{Obejto tFont a ser usado , Cor da fonte}
								
								aFontImpr[1][1] := aFonTempImp[1]                   //Objeto fonte que serแ utilizado
								aFontImpr[1][2] := (aFontImpr[1][1]:nHeight)/2 	    //Largura do texto
								aFontImpr[1][3] :=  aFonTempImp[2]                 //Cor do texto
								
								oPr:say(nLEtiq,nColuna*29.59,aRegistros[nInt+nInt3][nInt2][1],aFontImpr[1][1],aFontImpr[1][2],aFontImpr[1][3])
							else
								oPr:say(nLEtiq,nColuna*29.59,aRegistros[nInt+nInt3][nInt2],oFont9)
							endif
							
							
						Else // se nao tiver nada em E00001...na linha definida entao imprime em branco a linha!  BOPS 132158
							oPr:say(nLEtiq,nColuna*29.59,"",oFont9)
						EndIf
						
						//mscbbox(nLEtiq,nColuna*29.59,nLEtiq+GC7->GC7_QTDLIN,nColuna*29.59+GC7->GC7_QTDCOL,37)
					Endif
					
				Elseif cTipoImp == "2"
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณ Impressao de etiquetas MODO TERMICO                               ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					If !Empty(aCamposImp[nInt2][11]) .and. aCamposImp[nInt2][6]
						//CBSAYBAR(                                                nXmm,                nYmm,                     cConteudo, cRo,                          cTypePrt,                nAltura,lDigVer, lLinha, lLinBaixo,cSubSetIni,              nLargura,              nRelacao,lCompacta,lSerial,cIncr,lZerosL)
						//CBSAYBAR(                                                  22,                  03,                Strzero(nX,10), "N",                            "MB07",                   8.36,    .F.,    .T.,       .F.,          ,                     3,                     2)
						if !Empty(iIf(lTipFont, aRegistros[nInt+nInt3][nInt2][1], aRegistros[nInt+nInt3][nInt2]))
							if lTipFont
								MSCBSAYBAR(aCamposImp[nInt2,3] + (GC7->GC7_COLETI * nInt3 * 10), aCamposImp[nInt2,2], aRegistros[nInt+nInt3][nInt2][1], 'N', RetTipoBar(aCamposImp[nInt2][11]),aCamposImp[nInt2][9]*10,    .F.,    .F.,          ,          , aCamposImp[nInt2][10], aCamposImp[nInt2][10])
							else
								MSCBSAYBAR(aCamposImp[nInt2,3] + (GC7->GC7_COLETI * nInt3 * 10), aCamposImp[nInt2,2], aRegistros[nInt+nInt3][nInt2], 'N', RetTipoBar(aCamposImp[nInt2][11]),aCamposImp[nInt2][9]*10,    .F.,    .F.,          ,          , aCamposImp[nInt2][10], aCamposImp[nInt2][10])
							endif
						EndIf
					Else
						//CBSAY(  05,                 16,     "IMPRESSORA ALLEGRO 2 BR", "N",                           "2",                       "01,01")
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณ Imprime logo  ณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						If !Empty(GC7->GC7_LOGO)
							If !lJaImpLogo
								MSCBGRAFIC(GC7->GC7_XLOGO, GC7->GC7_YLOGO, SUBS(GC7->GC7_LOGO,1,(AT( "." , GC7->GC7_LOGO )-1)))
								lJaImpLogo := .T.
							EndIf
						EndIf
						
						// Parametrizacao:  MscbSay(nXmm, nYmm, cTexto, cRotacao, cFonte, cTam, [lReverso],[lSerial], [cIncr], [lZerorsL])
						IF !EMPTY(iIf(lTipFont, aRegistros[nInt+nInt3][nInt2][1], aRegistros[nInt+nInt3][nInt2]))  // 01/09/07 BOPS 132158   verifica se a linha nao esta definida
							MsCbSay(aCamposImp[nInt2,3] + (GC7->GC7_COLETI * nInt3 * 10) /*+ nSoma3Lin*/,aCamposImp[nInt2,2]/*+nSoma3Lin*/, iIf(lTipFont, aRegistros[nInt+nInt3][nInt2][1], aRegistros[nInt+nInt3][nInt2]), cRotacao , Alltrim(aCamposImp[nInt2,14]), Alltrim(aCamposImp[nInt2,15]))
						Else // se nao tiver nada em E00001...na linha definida entao imprime em branco a linha!  BOPS 132158
							MsCbSay(aCamposImp[nInt2,3] + (GC7->GC7_COLETI * nInt3 * 10) /*+ nSoma3Lin*/,aCamposImp[nInt2,2]/*+nSoma3Lin*/, " ", cRotacao , Alltrim(aCamposImp[nInt2,14]), Alltrim(aCamposImp[nInt2,15]))
						EndIf
						
					Endif
				Endif
				
			Endif // O nLinhaEtiqueta*6 ้ o espa็amento entre os caracteres em pixel
			
		Next nInt3
		
		nLin++
		nTamanVertical--
		
	Next nInt2
	
	If cTipoImp == "2"  // Impressora termica
		MsCbEnd()
	Endif
	
	nInt += GC7->GC7_QTDCOL-1
	
	While !nTamanVertical <= 0
		nLin += 1
		nTamanVertical--
	End
	
	// verifica se a quantidade de linhas por pagina acabou
	If Int((nInt / GC7->GC7_QTDCOL) / GC7->GC7_QTDLIN) == (nInt / GC7->GC7_QTDCOL) / GC7->GC7_QTDLIN
		If cTipoImp == "0"
			Eject
			nLin--
			cImpPort := cImpPort + CHR(13)+CHR(10)
			cImpPort := cImpPort + CHR(13)+CHR(10)
		ElseIf cTipoImp == "1"
			nLin := 0
			nLinhaAtual := 0
			oPr:endpage()
		EndIf
	EndIf
	
	IncRegua()
	
	lPrintImg := .F.
	nRegAnt := nInt
Next nInt

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Controle de Bloqueio do Spool de impressao para um mapeamento de  ณ
//ณ impressora para impedir que etiquetas se misturem na impressao.   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If HS_ExisDic({{"C","GC7_FILA"}} , .F.)
	If GC7->GC7_FILA == "4"  // se o controle da fila for VIRTUAL
		If !Empty(cNetUse)
			Eval ( bLocUnlock, 2, cNetUse ) // UNLOCK
		EndIf
	EndIf
EndIf

If cTipoImp == "0"
	SET DEVICE TO SCREEN
Elseif cTipoImp == "1"
	oPr:EndPage()
	oPr:Preview()
	oPr:End()
Endif

If cTipoImp == "2"
	MsCbClosePrinter()
Else
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Impressao de etiquetas MODO TEXTO:                                ณ
	//ณ Envia para a porta de impressao o conteudo da variavel cImpPort,  ณ
	//ณ esta variavel contem as linhas a serem impressas...               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cTipoImp == "0"
		nH := CBOpenPort("LPT1")
		cImpPort := cImpPort + CHR(13)+CHR(10) // controle de mudanca de linha para descarregar o buffer por completo ao fim da impressao
		cImpPort := cImpPort + CHR(13)+CHR(10) // controle de mudanca de linha para descarregar o buffer por completo ao fim da impressao
		Fwrite(nH,cImpPort)
		Fclose(nH)
	Else
		
		MS_FLUSH()
		
	EndIf
	
Endif

aMv_Param := {}


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraX1    บ Autor ณRodrigo Xavier      บ Data ณ Junho/2003  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Impressao                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraX1()
Local i       := 0 ,;
j       := 0 ,;
nint0   := 0 ,;
_sAlias := Alias()

dbSelectArea("SX1")
dbSetOrder(1)
aRegs:={}

AADD(aRegs,{cPerg,"01",STR0059,"","","mv_ch1","N",9,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})                                 //"Qtd. cada etiqueta ?"
For nInt0 := 1 to Len(aParametros)
	If nInt0 <= Len(aParametros) .And. nInt0 > 1
		If aParametros[nInt0, 1] == aParametros[nInt0-1, 1]
			Loop
		EndIf
	EndIf
	If Posicione("GC8", 1, xFilial("GC8") + GC7->GC7_CODETI + aParametros[nInt0,2], "GC8_PARAM") == "1" //GC8_CODETI + GC8_SEQPAR
		cDescricao := Posicione("SX3", 2, aParametros[nInt0, 1], "X3_TITULO")
		cTipo      := Posicione("SX3", 2, aParametros[nInt0, 1], "X3_TIPO")
		cTamanho   := Posicione("SX3", 2, aParametros[nInt0, 1], "X3_TAMANHO")
		cF3        := Posicione("SX3", 2, aParametros[nInt0, 1], "X3_F3")
		AADD(aRegs,{cPerg,STRZERO(nInt0+1,2),PADR(cDescricao,19)+"?","","","mv_ch" + Str(nInt0+1), cTipo, cTamanho, 0, 0, "G","","mv_par" + STRZERO(nInt0+1,2),"","","","","","","","","","","","","","","","","","","","","","","","",cF3,""})
		AADD(aMv_Param,"mv_par" + STRZERO(nInt0+1,2))
		If nInt0 <= Len(aParametros)
			If Posicione("GC8", 1, xFilial("GC8") + GC7->GC7_CODETI + aParametros[nInt0,2], "GC8_TPARAM") == "1"
				AADD(aRegs,{cPerg,STRZERO(nInt0+2,2),"Ate " + PADR(cDescricao,15)+"?","","","mv_ch" + Str(nInt0+2), cTipo, cTamanho, 0, 0, "G","","mv_par" + STRZERO(nInt0+2,2),"","","","","","","","","","","","","","","","","","","","","","","","",cF3,""})
				AADD(aMv_Param,"mv_par" + STRZERO(nInt0+2,2))
			EndIf
		EndIf
	EndIf
Next

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Else
		If 	SX1->X1_PERGUNT <> aRegs[i,03]	.OR.;
			SX1->X1_TIPO    <> aRegs[i,07]	.OR.;
			SX1->X1_TAMANHO <> aRegs[i,08]	.OR.;
			SX1->X1_DECIMAL <> aRegs[i,09]	.OR.;
			SX1->X1_GSC     <> aRegs[i,11]	.OR.;
			SX1->X1_VAR01   <> aRegs[i,13]
			
			RecLock("SX1",.F.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		EndIf
	Endif
Next

dbSelectArea(_sAlias)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MONTAETIบAutor ณRodrigo Xavier      บ Data ณ Junho/2003  บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que monta a visualizacao da etiqueta                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MONTAETI()
Local cEspaco := ""
Local nInt    := 0
Local nInt2   := 0
Local aLinEtq := {}
Local nLinha  := 0
Local nI       := 0

Local nX          := 0


/*
If cTipoImp == "2" //Etiqueta Termica
Return Nil
Endif
*/

aVisualizacao := {}
For nInt := 1 to 30
	//AADD(aVisualizacao,({""}))
	AADD(aVisualizacao,({{},{},{},""}))//{[identificacao campo/expressao],[campo/id. expressao],expressao,linha,coluna,tamanho,Tipo de Fonte / Estilo Fonte / Tamanho Fonte / Cor Fonte}
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a etiqueta para visualizacao                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nInt := 1 to Len(aCampos)
	If aCampos[nInt][4] > 0 .And. aCampos[nInt][5] > 0 .And. aCampos[nInt][6] > 0
		
		/*
		   If aCampos[nInt][5] > 1
		    For nInt2 := 1 to aCampos[nInt][5]
		     cEspaco += "  "
		    Next                    
	   EndIf*/		
		
		nLinha 	:= aScan(aVisualizacao, {|aVet| iIf(valType(aVet[4]) == "N", aVet[4], 0 ) == aCampos[nInt][4]})
		if nLinha > 0 .and. valType(aCampos[nInt][4]) == "N" .and. aCampos[nInt][4] > 0 .and. !empty(AllTrim(aCampos[nInt][3]))
			aAdd(aVisualizacao[nLinha,1],{"[ " + AllTrim(aCampos[nInt][3]) + " ] ",aCampos[nInt][5],aCampos[nInt][6],;
			aCampos[nInt][12], aCampos[nInt][13], aCampos[nInt][14], aCampos[nInt][15]}) //titulo / Linha / tamanho / Tipo de Fonte / Estilo Fonte / Tamanho Fonte / Cor Fonte
			aAdd(aVisualizacao[nLInha,3],{AllTrim(aCampos[nInt][2]),aCampos[nInt][5], aCampos[nInt][6],;
			aCampos[nInt][12], aCampos[nInt][13], aCampos[nInt][14], aCampos[nInt][15]})//Campo, coluna, tamanho / Tipo de Fonte / Estilo Fonte / Tamanho Fonte / Cor Fonte
		else
			aAdd(aVisualizacao[aCampos[nInt,4],1],{AllTrim("[ " + aCampos[nInt][3]) + " ] ",aCampos[nInt][5], aCampos[nInt][6],;
			aCampos[nInt][12], aCampos[nInt][13], aCampos[nInt][14], aCampos[nInt][15]})//titulo, coluna, tamanho / Tipo de Fonte / Estilo Fonte / Tamanho Fonte / Cor Fonte
			aAdd(aVisualizacao[aCampos[nInt,4],2],{AllTrim(aCampos[nInt][2]),aCampos[nInt][5], aCampos[nInt][6],;
			aCampos[nInt][12], aCampos[nInt][13], aCampos[nInt][14], aCampos[nInt][15]})//Campo, coluna, tamanho / Tipo de Fonte / Estilo Fonte / Tamanho Fonte / Cor Fonte
			aAdd(aVisualizacao[aCampos[nInt,4],3],{AllTrim(aCampos[nInt][2]),aCampos[nInt][5], aCampos[nInt][6],;
			aCampos[nInt][12], aCampos[nInt][13], aCampos[nInt][14], aCampos[nInt][15]})//Expressao, coluna, tamanho / Tipo de Fonte / Estilo Fonte / Tamanho Fonte / Cor Fonte
			aVisualizacao[aCampos[nInt,4],4] := aCampos[nInt][4] //Linha
		endif
		nLinha := 0
		
	EndIf
Next
For nInt := 1 to Len(aExpress)
	If aExpress[nInt][4] > 0 .And. aExpress[nInt][5] > 0 .And. aExpress[nInt][6] > 0
		If aExpress[nInt][5] > 1
			For nInt2 := 1 to aExpress[nInt][5]
				cEspaco += "  "
			Next
		EndIf
		nLinha 	:= aScan(aVisualizacao, {|aVet| iIf(valType(aVet[4]) == "N", aVet[4], 0 ) == aExpress[nInt][4]})
		if nLinha > 0 .and. valType(aExpress[nInt][4]) == "N" .and. aExpress[nInt][4] > 0 .and. !empty(AllTrim(aExpress[nInt][7]))
			aAdd(aVisualizacao[nLinha,3],{AllTrim(aExpress[nInt][7]),aExpress[nInt][5],aExpress[nInt][6],;
			aExpress[nInt][12], aExpress[nInt][13], aExpress[nInt][14], aExpress[nInt][15]}) //Expressao / Linha
			
			aAdd(aVisualizacao[nLinha,1],{AllTrim("[ " + aExpress[nInt][3]) + " ] ",aExpress[nInt][5], aExpress[nInt][6],;
			aExpress[nInt][12], aExpress[nInt][13], aExpress[nInt][14], aExpress[nInt][15]})//titulo, coluna, tamanho / Tipo de Fonte / Estilo Fonte / Tamanho Fonte / Cor Fonte
		else
			aAdd(aVisualizacao[aExpress[nInt,4],1],{AllTrim("[ " + aExpress[nInt][3]) + " ] ",aExpress[nInt][5], aExpress[nInt][6],;
			aExpress[nInt][12], aExpress[nInt][13], aExpress[nInt][14], aExpress[nInt][15]})//titulo, coluna, tamanho/ Tipo de Fonte / Estilo Fonte / Tamanho Fonte / Cor Fonte
			
			aAdd(aVisualizacao[aExpress[nInt,4],2],{AllTrim(aExpress[nInt][2]),aExpress[nInt][5], aExpress[nInt][6],;
			aExpress[nInt][12], aExpress[nInt][13], aExpress[nInt][14], aExpress[nInt][15]})//Campo, coluna, tamanho/ Tipo de Fonte / Estilo Fonte / Tamanho Fonte / Cor Fonte
			
			aAdd(aVisualizacao[aExpress[nInt,4],3],{AllTrim(aExpress[nInt][7]),aExpress[nInt][5], aExpress[nInt][6],;
			aExpress[nInt][12], aExpress[nInt][13], aExpress[nInt][14], aExpress[nInt][15]})//Expressao, coluna, tamanho/ Tipo de Fonte / Estilo Fonte / Tamanho Fonte / Cor Fonte
			
			aVisualizacao[aExpress[nInt,4],4] := aExpress[nInt][4] //Linha
		endif
		nLinha := 0
		
		cEspaco := ""
	EndIf
Next
M->LINHA1  := aVisualizacao[01][1]
M->LINHA2  := aVisualizacao[02][1]
M->LINHA3  := aVisualizacao[03][1]
M->LINHA4  := aVisualizacao[04][1]
M->LINHA5  := aVisualizacao[05][1]
M->LINHA6  := aVisualizacao[06][1]
M->LINHA7  := aVisualizacao[07][1]
M->LINHA8  := aVisualizacao[08][1]
M->LINHA9  := aVisualizacao[09][1]
M->LINHA10 := aVisualizacao[10][1]
M->LINHA11 := aVisualizacao[11][1]
M->LINHA12 := aVisualizacao[12][1]
M->LINHA13 := aVisualizacao[13][1]
M->LINHA14 := aVisualizacao[14][1]
M->LINHA15 := aVisualizacao[15][1]
M->LINHA16 := aVisualizacao[16][1]
M->LINHA17 := aVisualizacao[17][1]
M->LINHA18 := aVisualizacao[18][1]
M->LINHA19 := aVisualizacao[19][1]
M->LINHA20 := aVisualizacao[20][1]
M->LINHA21 := aVisualizacao[21][1]
M->LINHA22 := aVisualizacao[22][1]
M->LINHA23 := aVisualizacao[23][1]
M->LINHA24 := aVisualizacao[24][1]
M->LINHA25 := aVisualizacao[25][1]
M->LINHA26 := aVisualizacao[26][1]
M->LINHA27 := aVisualizacao[27][1]
M->LINHA28 := aVisualizacao[28][1]
M->LINHA29 := aVisualizacao[29][1]
M->LINHA30 := aVisualizacao[30][1]

//Expressoes
M->LinhaExp1  := aVisualizacao[01][3]
M->LinhaExp2  := aVisualizacao[02][3]
M->LinhaExp3  := aVisualizacao[03][3]
M->LinhaExp4  := aVisualizacao[04][3]
M->LinhaExp5  := aVisualizacao[05][3]
M->LinhaExp6  := aVisualizacao[06][3]
M->LinhaExp7  := aVisualizacao[07][3]
M->LinhaExp8  := aVisualizacao[08][3]
M->LinhaExp9  := aVisualizacao[09][3]
M->LinhaExp10 := aVisualizacao[10][3]
M->LinhaExp11 := aVisualizacao[11][3]
M->LinhaExp12 := aVisualizacao[12][3]
M->LinhaExp13 := aVisualizacao[13][3]
M->LinhaExp14 := aVisualizacao[14][3]
M->LinhaExp15 := aVisualizacao[15][3]
M->LinhaExp16 := aVisualizacao[16][3]
M->LinhaExp17 := aVisualizacao[17][3]
M->LinhaExp18 := aVisualizacao[18][3]
M->LinhaExp19 := aVisualizacao[19][3]
M->LinhaExp20 := aVisualizacao[20][3]
M->LinhaExp21 := aVisualizacao[21][3]
M->LinhaExp22 := aVisualizacao[22][3]
M->LinhaExp23 := aVisualizacao[23][3]
M->LinhaExp24 := aVisualizacao[24][3]
M->LinhaExp25 := aVisualizacao[25][3]
M->LinhaExp26 := aVisualizacao[26][3]
M->LinhaExp27 := aVisualizacao[27][3]
M->LinhaExp28 := aVisualizacao[28][3]
M->LinhaExp29 := aVisualizacao[29][3]
M->LinhaExp30 := aVisualizacao[30][3]

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณHS_R71FIL บ Autor ณ Rodrigo Xavier     บ Data ณOutubro/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualizacao das tabelas de precos.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HS_R71FIL()

Local nOpca2 := 0
Local nLenGC8, nUGC8 := 0
Local nInt2, nInt3, nInt4 := 0, nInt := 0, nConta := 0
Local oMarcaT
Local nP        := 0
Local aButPar  := {}

Define FONT oFont NAME "Arial" BOLD

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define variaveis privadas                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private oTik       := LoadBitmap( GetResources(), "LBTIK" )
Private oNo        := LoadBitmap( GetResources(), "LBNO" )
Private nOpca1     := 0
Private aLbx       := {}
Private lCheck     := .T.
Private cCampoFilt := "", cHListBox := ""
Private oGC8
Private cGC8CODETI := ""
Private aCGC8 := {}

M->EtiQtd := 0
M->EtiApartir := 1


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta o formulario                                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Len(aRegistros) == 0
	HS_MsgInf(STR0074, STR0014, STR0001) //"Nใo hแ guias selecionadas."###"Aten็ใo"###"Valida็ใo da guia TISS"
	Return(.F.)
EndIf

nOpca2 := FS_RetLista()

If nOpca2 == 1
	Return(.F.)
EndIf

DEFINE MSDIALOG oDlgInicio TITLE STR0064 FROM 0,0 TO 080,250 PIXEL //"Aproveitamento de pagina"
@ 003, 003 Say OemToAnsi(STR0065) Size 150, 009 OF oDlgInicio PIXEL COLOR CLR_BLUE //"Imprimir a partir da etiqueta"
@ 013, 003 MSGet oEdit1 var M->EtiApartir Size 120, 009 OF oDlgInicio PIXEL COLOR CLR_BLACK PICTURE "999"
oBtnOk      := tButton():New(028,060,"Ok",oDlgInicio,{||oDlgInicio:End()},025,012,,,,.T.)
oBtnCancela := tButton():New(028,095,"Sair",oDlgInicio,{|| nOpca1 := 1, oDlgInicio:End()},025,12,,,,.T.)  //"Sair"
ACTIVATE MSDIALOG oDlgInicio CENTERED

If nOpca1 == 1
	Return
EndIf

aRegistros:={}
If nOpca2 == 2
	For nInt := 1 to Len(aCGC8)
		If aCGC8[nInt,1] == "LBNO"
			Loop
		EndIf
		For nInt2 := 1 to aCGC8[nInt, 2]
			//AADD(aRegistros,{aCGC8[nInt, 3]})
			if lTipFont
				AADD(aRegistros,{})
				AADD(aRegistros[Len(aRegistros)],{aCGC8Temp[nInt, 3][1],aCGC8Temp[nInt, 3][2],aCGC8Temp[nInt, 3][3],aCGC8Temp[nInt, 3][4],aCGC8Temp[nInt, 3][5], .F.})
			else
				AADD(aRegistros,{aCGC8[nInt, 3]})
			endif
			For nInt3 := 4 to Len(aCGC8[nInt]) - 2
				//aAdd(aRegistros[Len(aRegistros)], aCGC8[nInt, nInt3])
				if lTipFont
					aAdd(aRegistros[Len(aRegistros)], {aCGC8Temp[nInt, nInt3][1],aCGC8Temp[nInt, nInt3][2],aCGC8Temp[nInt, nInt3][3],aCGC8Temp[nInt, nInt3][4],aCGC8Temp[nInt, nInt3][5],.F.})
				else
					aAdd(aRegistros[Len(aRegistros)], aCGC8[nInt, nInt3])
				endif
			Next
		Next
	Next
EndIf
ASORT(aRegistros,,,{|x,y| x[1] < y[1] })

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_EXPLOG บ Autor ณ MARCELO JOSE       บ Data |  06/12/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ VISUALIZA A EXPRESSAO LOGICA DO FILTRO                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
STATIC FUNCTION FS_ExpLog()
Local nCtaFor := 1
Local cQuebra := cSql
Local nPos    := 0
Local nQuaCin := 0
Private oList, nList := 1, aTodos := {}

DEFINE MSDIALOG oDlgExp TITLE STR0124 FROM 0,0 TO 400,450 OF oDlg PIXEL  //"Expressao logica do filtro"

oList:=tListBox():New(20,10,{|u|if(Pcount()>0,nList:=u,nList)},aTodos,205,175,,oDlgExp,,,,.T.)

While .T.
	nPos    := At(".",cQuebra)
	nQuaCin := IIF(Subs(cQuebra,nPos+1,1)== "A",5,4) // se for And soma 5 se for Or soma 4
	If nPos > 0
		oList:Add(Subs( cQuebra , 1 , nPos+nQuaCin ) , oList:len() + 1)
		cQuebra := Subs(cQuebra , nPos + nQuaCin,(Len(cQuebra)-nPos) )
	Else
		Exit
	EndIf
End
oList:Add(cQuebra, oList:len() + 1)
oList:Refresh()

ACTIVATE MSDIALOG oDlgExp CENTERED ON INIT EnchoiceBar(oDlgExp, {|| oDlgExp:End()},{|| oDlgExp:End()})

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณFS_ODLG2OKบ Autor ณ Rodrigo Xavier     บ Data |Outubro/2003 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava a observacao                                         บฑฑ
ฑฑบ          ณ                                           ;                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ODLGQTD()
Local nQtd := 0, nConta := 0, nP := 0, nConta2 := 0
M->EtiQtd := aCGC8[oGC8:nAt,2]

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria o formulario para entrada dos dados do agendamento               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlgQtd TITLE STR0066 FROM 0,0 TO 080,250 PIXEL //"Alteracao da quantidade de etiquetas"
@ 003, 003 Say OemToAnsi(STR0062) Size 050, 009 OF oDlgQtd PIXEL COLOR CLR_BLUE //"Quantidade"
@ 013, 003 MSGet oEdit1 var M->EtiQtd Size 100, 009 OF oDlgQtd PIXEL COLOR CLR_BLACK PICTURE "999"
oBtnOk := tButton():New(011,105,"Ok",oDlgQtd,{||oDlgQtd:End()},020,014,,,,.T.)
ACTIVATE MSDIALOG oDlgQtd CENTERED

aCGC8[oGC8:nAt,2] := M->EtiQtd
oGC8:aCols[oGC8:nAt,2] := M->EtiQtd
oGC8:Refresh()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออ"ฑฑ
ฑฑบPrograma  ณFS_ODLGLOCบ Autor ณ Rodrigo Xavier     บ Data |Dezembro/2003บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Localiza item na lista de impressao.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ODLGLOC()
Local nProcura := 0, nPos := 0, nConta := 0
Local M->ItemLoc := Space(50)

If oGC8:oBrowse:nColPos <= 2
	oGC8:oBrowse:nColPos := 3
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Cria o formulario para entrada dos dados do agendamento               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlgLoc TITLE STR0125+oGC8:aHeader[oGC8:oBrowse:nColPos, 1] FROM 0,0 TO 080,250 PIXEL  //"Pesquisar por: "
@ 003, 003 Say OemToAnsi(STR0077) Size 150, 009 OF oDlgLoc PIXEL COLOR CLR_BLUE  //"Conteudo da pesquisa"
@ 013, 003 MSGet oEdit1 var M->ItemLoc Size 100, 009 OF oDlgLoc PIXEL COLOR CLR_BLACK PICTURE "@!"
oBtnOk := tButton():New(011,105,"Ok",oDlgLoc,{||oDlgLoc:End()},020,014,,,,.T.)
ACTIVATE MSDIALOG oDlgLoc CENTERED

If trim(M->ItemLoc) == ""
	Return
EndIf

nProcura := Len(ALLTRIM(M->ItemLoc))
nPos := Ascan(aCGC8,{|aVet| SubStr(aVet[oGC8:oBrowse:nColPos],1,nProcura) == SubStr(M->ItemLoc,1,nProcura)})
If nPos > 0
	oGC8:oBrowse:nAt := nPos
	oGC8:Refresh()
EndIf

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFS_MTODOS  ณ Autor ณ MARCELO JOSE          ณ Data ณ FEV/05   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ MARCA TODOS OS ITENS PARA IMPRESSAO                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_Mtodos(oGC8,aCGC8)
Local nCtaMarca := 0 , nPosIni := 0
nPosIni := oGC8:oBrowse:nAt
For nCtaMarca := 1 to Len(aCGC8)
	oGC8:oBrowse:nAt := nCtaMarca
	oGC8:aCols[oGC8:oBrowse:nAt,1] := IIf(oGC8:aCols[oGC8:oBrowse:nAt, 1] == "LBTIK", "LBNO", "LBTIK")
Next
oGC8:Refresh()
oGC8:oBrowse:nAt := nPosIni
Return(Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณTrataModeloณ Autor ณ Robson Ramiro A. Oliveณ Data ณ 17.01.05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Trata o modelo da impressora termica                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ TrataModelo()                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Impressora                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ R71                                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function TrataModelo(cPrg)
Local aModelo	:= {}
Local nX						:= 0
Local aImp				:= {}

MSCBModelo(cPrg,,,@aModelo)

For nX := 1 To Len(aModelo)
	aAdd(aImp,aModelo[nX,1])
Next

Return aClone(aImp)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณRetTipoBar ณ Autor ณ Alex Sandro Valario   ณ Data ณ 16.02.05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Retorna o tipo de codigo de barras referente ao modelo da   ณฑฑ
ฑฑณ          ณ impressora termica                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ RetTipoBar(ExpC1)                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = String com o tipo de codigo de barras               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ R71                                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RetTipoBar(cCodigo)
Local aTipo    :={"INT25"	,"CODE3_9"	,"EAN8"	,"EAN13"	,"UPCA"	,"SUP5"	,"CODE128"	}
Local aZebra   :={"2"		,"3"		,"8"		,"E"		,"U"		,"9"		,"C"		}
Local aAllegro :={"D"		,"A"		,"G"		,"F"		,"B"		,"C"		,"E"		}
Local aEltron  :={"2"		,"3"		,"E80"	,"E30"	,"UA0"	,"UE0"	,"1"		}
Local aIntermec:={"2"		,"0"		,"7,0,1"	,"7,0,2"	,"7,0,3"	,"7,0,4"	,"6,0,1" }
Local cModelo := Alltrim(GC7->GC7_MODPRN)
Local nPos
nPos := Ascan(aTipo,Alltrim(Upper(cCodigo)))
If nPos ==0
	Return cCodigo
EndIf
If MSCbModelo('ZPL',cModelo)
	cCodigo := aZebra[nPos]
ElseIf MSCbModelo('DPL',cModelo)
	cCodigo := aAllegro[nPos]
ElseIf MSCbModelo('EPL',cModelo)
	cCodigo := aEltron[nPos]
ElseIf MSCbModelo('IPL',cModelo)
	cCodigo := aIntermec[nPos]
EndIf

Return cCodigo
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณFS_LENUSE  ณ Autor ณ MARCELO JOSE          ณ Data ณ 30/08/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ LE O ARQUIVO NET USE PARA LOCK UNLOCK CONTROLE DO SPOOL     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Retorna uma string contendo o nome do mapeamento da porta   ณฑฑ
ฑฑณ          ณ cadastrada no modelo de etiqueta.                           ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_LENUSE( cPorta )
Local cRet       := "", ;
cCaminho   := IIF(GETREMOTETYPE()==2,"/tmp","c:\"), ;
mLinhaArq  := "", ;
nPosBco    := 0, ;
cStrRest   := "", ;
lLINUX     := IIF(GETREMOTETYPE()==2,.T.,.F.)


If !lLINUX
	
	// Le o arquivo gerado pela execucao da fun็ใo HS_LNetUse para
	// encontrar o nome da impressora mapeada na porta do GC7->GC7_PORTA
	If FT_FUse( ALLTRIM(cCaminho) + "mapnet.txt" ) /* ABRE O ARQUIVO TXT */
		Final(STR0094 + ALLTRIM(cCaminho) + "mapnet.txt" + STR0095 + FStrErro()) //"Nใo foi possํvel abrir o arquivo: "###" Problema: "
	EndIf
	
	FT_FGOTOP()
	/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ LOOP NO ARQUIVO PARA LEITURA DAS LINHAS            ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
	
	While !FT_FEof()
		
		mLinhaArq := FT_FReadln()  /* LEITURA DA LINHA E ATRIBUICAO DA LEITURA A VARIAVEL mLinhaArq */
		If !Empty(mLinhaArq) /* SE A LINHA NAO ESTIVER VAZIA */
			If cPorta $ mLinhaArq
				cStrRest := subs(mLinhaArq, 24, (len(mLinhaArq) - 24))
				nPosBco  := At(" ", cStrRest)
				cRet     := Subs(mLinhaArq, 24, nPosBco)
				Exit
			EndIf
		EndIf
		
		FT_FSkip()
		
	End
	
	FT_FUse() /* FECHA O ARQUIVO TXT */
	
EndIf

Return(cRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFSTRERRO  บ Autor ณ Marcelo Jose       บ Data ณSJRP 03/09/07บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ APONTA ERRO NA ABERTURA DO ARQUIVO NETMAP.BAT              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static function FStrErro()
Local cStrerro := ""

If fError() == 0
	cStrerro := STR0096 //"0	Opera็ใo realizada com sucesso. Sem erros."
ElseIf fError() == 2
	cStrerro := STR0097 //"Arquivo nใo encontrado."
ElseIf fError() == 3
	cStrerro := STR0098 //"Caminho nใo encontrado."
ElseIf fError() == 4
	cStrerro := STR0099 //"Muitos arquivos abertos."
ElseIf fError() == 5
	cStrerro := STR0100 //"Acessso negado."
ElseIf fError() == 6
	cStrerro := STR0101 //"Manipulador Invalido ( Handle )."
ElseIf fError() == 8
	cStrerro := STR0102 //"Mem๓ria Insuficiente."
ElseIf fError() == 15
	cStrerro := STR0103 //"Drive invแlido especificado."
ElseIf fError() == 19
	cStrerro := STR0104 //"Tentativa de gravar em disco protegido contra-grava็ใo."
ElseIf fError() == 21
	cStrerro := STR0105 //"Drive Nใo esta pronto."
ElseIf fError() == 23
	cStrerro := STR0106 //"Dados com erro de CRC."
ElseIf fError() == 29
	cStrerro := STR0107 //"Erro de grava็ใo."
ElseIf fError() == 30
	cStrerro := STR0108 //"Erro de leitura."
ElseIf fError() == 32
	cStrerro := STR0109 //"Viola็ใo de compartilhamento."
ElseIf fError() == 33
	cStrerro := STR0110 //"Erro de Lock."
EndIf

If Empty(cStrerro)
	cStrerro := STR0111 //"Erro indeterminado !!!"
EndIf

Return(cStrerro)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_LNetUseบ Autor ณ Marcelo Jose       บ Data ณSJRP 17/09/07บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CRIA SE NAO EXISTIR E EXECUTA NETMAP.BAT                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function HS_LNetUse()
Local nHdlW      := 0,;
cNetBat    := "netmap.bat",;
cCaminho   := IIF(GETREMOTETYPE()==2,"/tmp","c:\"), ;
lLINUX     := IIF(GETREMOTETYPE()==2,.T.,.F.)

If !File(cCaminho + "mapnet.txt")
	If !File(cCaminho + cNetBat)  // se nao existir o arquivo NETMAP.BAT entao cria-o
		nHdlW := FCREATE (cCaminho + cNetBat, 0)
		If nHdlW <> -1
			If lLINUX
				Fwrite(nHdlW, "cat > " + cCaminho + "mapnet.txt" )
			Else
				Fwrite(nHdlW, "NET USE > " + cCaminho + "mapnet.txt" )
			EndIf
			Fclose(nHdlW)
		Else
			Final(STR0094+ Alltrim(cCaminho+cNetBat) + STR0095 + FStrErro() ) //"Nใo foi possํvel abrir o arquivo: "###" Problema: "
		EndIf
	EndIf
	If !lLINUX
		WinExec(cCaminho + cNetBat) // executa o NETMAT.BAT
	EndIf
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RetLista  บAutor  ณPaulo C้sar         บ Data ณ  28/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFun็ใo para retornar os honorแrio individuais                  บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_RetLista(cCodEti)
Local aSize   	:= {}, aObjects := {}, aInfo := {}, aPObjs := {},aScreen 	:= {}
Local aHGC8   	:= {}, aButtons := {}, aRet := {}
Local nUGC8   := 0, nConta := 0, nInt := 0, nQtdEti := 0
Local lOK     := .T., lMarca := .T.
Local nTdOk   := 0
Local nForGC8 := 0
Local nRow			:= 170
Local nCol			:= 010
Local nHeight		:= 014
Local nWidth		:= 100
Local nBtnNxt		:= 105
Local nAuxCalc	:= 0.60	

Define  FONT oFont NAME "Arial,16," BOLD
aCgc8Temp := {}
Aadd(aHGC8, {" ",                  "lMarca", "@BMP", 2, 0, ".F.", "", "C", "", "V", "", "", "", "V"})

Aadd(aHGC8, {OemtoAnsi(STR0062), "nQtdEti",     "", 2, 0, ".F.", "", "N", "", "V", "", "", "", "V"})

For nConta := 1 to len(aRegistros[1])-1 // Monta cabe็alho
	Aadd(aHGC8, {aCamposImp[nConta, 16], "cGC8CODETI", "@!" ,len(trim(aCamposImp[nConta, 16])), 0, ".F.", ""    , "C", "", "V" , "" , "","","V"})
Next

For nInt := 1 to Len(aRegistros)
	
	if lTipFont
		If Ascan(aCGC8,{|aVet| aVet[3] == aRegistros[nInt, 1][1]}) <> 0  .and. Ascan(aCGC8,{|aVet| aVet[4] == aRegistros[nInt, 2][1]}) <> 0  //  imprimir todos itens conforme FNC0000025725/2009
			loop
		EndIf
	else
		If Ascan(aCGC8,{|aVet| aVet[3] == aRegistros[nInt, 1]}) <> 0  .and. Ascan(aCGC8,{|aVet| aVet[4] == aRegistros[nInt, 2]}) <> 0  //  imprimir todos itens conforme FNC0000025725/2009
			loop
		EndIf
	endif
	
	AADD(aCGC8,{"LBNO"})
	AADD(aCGC8[Len(aCGC8)],mv_Par01)
	if lTipFont
		AADD(aCgc8Temp,{"LBNO"})
		AADD(aCgc8Temp[Len(aCGC8)],mv_Par01)
	endif
	
	For nConta := 1 to len(aRegistros[nInt])
		if lTipFont
			AADD(aCGC8[Len(aCGC8)],aRegistros[nInt, nConta][1])
			AADD(aCgc8Temp[Len(aCGC8)],{aRegistros[nInt, nConta][1],aRegistros[nInt, nConta][2],aRegistros[nInt, nConta][3],aRegistros[nInt, nConta][4],aRegistros[nInt, nConta][5]})
		else
			AADD(aCGC8[Len(aCGC8)],aRegistros[nInt, nConta])
		endif
	Next
	AADD(aCGC8[Len(aCGC8)], .F.)
Next

aSize := MsAdvSize(.T.)
aObjects := {}
aAdd( aObjects, { 001, 090, .T., .T. } )
aAdd( aObjects, { 001, 010, .T., .T. } )

aSize[3] := aSize[3] * 0.75
aSize[4] := aSize[4] * 0.75
aSize[5] := aSize[5] * 0.75
aSize[6] := aSize[6] * 0.75

aInfo  := {aSize[1], aSize[2], aSize[3], aSize[4], 5, 5}
aPObjs := MsObjSize(aInfo, aObjects, .T.)
aScreen:= getScreenRes()

//Define o posicionamento dos botoes conforme resolucao da tela
If aScreen[1] >= 1440 .And. aScreen[2] >= 900
	nRow		:= 195
	nCol		:= 090
	nWidth	:= 100
	nHeight	:= 014
	nBtnNxt	:= 105
	nAuxCalc:= 0.55	
ElseIf aScreen[1] >= 1280 .And. aScreen[2] >= 1024
	nRow		:= 275
	nCol		:= 060
	nWidth	:= 100
	nHeight	:= 014
	nBtnNxt	:= 105
	nAuxCalc:= 0.65	
ElseIf aScreen[1] >= 1280 .And. aScreen[2] >= 800
	nRow		:= 175
	nCol		:= 050
	nWidth	:= 100
	nHeight	:= 014
	nBtnNxt	:= 105
	nAuxCalc:= 0.6	
ElseIf aScreen[1] >= 1020 .And. aScreen[2] >= 760
	nRow		:= 230
	nCol		:= 050
	nWidth	:= 100
	nHeight	:= 014
	nBtnNxt	:= 105
	nAuxCalc:= 0.6
ElseIf aScreen[1] >= 1150 .And. aScreen[2] >= 860
	nRow		:= 175
	nCol		:= 050
	nWidth	:= 100
	nHeight	:= 014
	nBtnNxt	:= 105
	nAuxCalc:= 0.6	
ElseIf aScreen[1] >= 800 .And. aScreen[2] >= 600
	nRow		:= 110
	nCol		:= 035
	nWidth	:= 60
	nHeight	:= 014
	nBtnNxt	:= 65
	nAuxCalc:= 0.55	
EndIf

Aadd(aButtons	,{"sfiltro" , {|| FS_ExpLog() }, STR0126 , STR0127})    //"Visualizar a Expressao logica do filtro"###"Filtro"
DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0007) FROM aSize[7],0 To aSize[6], aSize[5] OF oMainWnd PIXEL

//Define os botoes
oBtn01	:= tButton():New(aPObjs[2][1],nCol	,STR0063,oDlg,{||FS_ODLGQTD()}				,nWidth,nHeight,,,,.T.)	//"Alterar quantidade"
				nCol	+= nBtnNxt
oBtn02	:= tButton():New(aPObjs[2][1],nCol	,STR0075,oDlg,{||FS_ODLGLOC()}				,nWidth,nHeight,,,,.T.)	//"Localizar item"
				nCol += nBtnNxt
oMarcaT	:= tButton():New(aPObjs[2][1],nCol	,STR0076,oDlg,{||FS_Mtodos(oGC8,aCGC8)}	,nWidth,nHeight,,,,.T.)	//"Marca/Desmarca todos"

//Instancia o Objeto
oGC8 := MsNewGetDados():New(aPObjs[1][1]+5, aPObjs[1][2]+5, aPObjs[1][3], aPObjs[1][4]-5, 0,,,,,,,,,, oDlg, aHGC8, aCGC8)

//Seta as propriedades
oGC8:oBrowse:BlDblClick := {|| FS_DbClik(oGC8)}
oGC8:oBrowse:align := CONTROL_ALIGN_TOP
oGC8:SetArray(aCGC8)

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| nTdOk := 2, IIF(!FS_VldLista(), nTdOk := 0, oDlg:End())}, {|| nTdOk := 1, oDlg:End()},, aButtons)

For nConta := 1 to len(aCGC8)
	aCGC8[nConta, 1] := oGC8:aCols[nConta, 1]
	aCGC8[nConta, 2] := oGC8:aCols[nConta, 2]
	aRegistros[nConta, len(aCamposImp)+1] := oGC8:aCols[nConta, 1]
Next

Return(nTdOk)


Static Function FS_VldLista()
Local lRet := .T.
If !(lRet := (aScan(oGC8:aCols, {| aVet | aVet[1] == "LBTIK"}) > 0))
	HS_MsgInf(STR0074, STR0014, STR0001) //"Nใo hแ guias selecionadas."###"Aten็ใo"###"Valida็ใo da guia TISS"
EndIf
Return(lRet)

Static Function FS_DbClik(oGC8)
oGC8:aCols[oGC8:oBrowse:nAt, 1] := IIf(oGC8:aCols[oGC8:oBrowse:nAt, 1] == "LBTIK", "LBNO", "LBTIK")
oGC8:Refresh()
Return(Nil)

/***************************************************************************/
Static Function Chekbug(e)
If e:gencode > 0
	HS_MsgInf(STR0128 + e:Description + Chr(13) + Chr(10) + STR0129,STR0014,STR0130) //"Erro: "###"Erro na Execu็ใo do Filtro dos registros"###"Aten็ใo"###"Anแlise Filtro de Etiquetas"
	lRetErro:=.F.
EndIf
Return(lRetErro)

/*
###################################################################################
###################################################################################
### Programa  # FS_retExpR71     ### Autor #  Saude       ### Data # 16/02/2012 ###
###################################################################################
### Descricao # Retorna a string a ser impressa com base nas expressoes         ###
###           # informadas pelo usuario (para a mesma linha/colunas diferentes) ###
###################################################################################
### Parametro # aConteudo - array com as expressoes a serem analisadas para     ###
###           # o texto final.                                                  ###
###           # Deve conter:                                                    ###
###           #               [nI,1] = cTexto   - (Texto a ser impresso)        ###
###           #               [nI,2] = nColuna  - (Coluna definida para a       ###
###           #                                    expressao nI)                ###
###           #               [nI,3] = nTamanho - (Tamanho maximo a ser  utiliza###
###           #                                    pela expressao nI)           ###
###################################################################################
### Retorno   # cRet - texto a ser impresso na pre visualizacao                 ###
###################################################################################
### Uso       # GH                                                              ###
###################################################################################
*/

static function FS_retExpR71(aConteudo,lTexto)

local aArea      := getArea()
local cRetorno   := ""
Local nY          := 0
Local cVarLin    := ""
Local cTexto     := ""
Local cConteudo  := ""
Local nDifIni    := 0
Local nDifMid    := 0
Local cDifFim    := ""
Local cExpress   := ""
local nSubMcr1		:= 0
local nSubMcr2		:= 0

Default lTexto := .F.

if valType(aConteudo) # "A"
	return cRetorno
endif

//Identifica se o Alias selecionado inicia em "S"
If SubStr(cCombo2,1,1) == "S"
	nSubMcr1 	:= 3
	nSubMcr2	:= 2
Else
	nSubMcr1 	:= 4
	nSubMcr2	:= 3
EndIf

if len(aConteudo) > 1
	for nY := 1 to len(aConteudo)
		if !empty(aConteudo[nY,1])
			cExpress  := aConteudo[nY,1]
			if !lTexto
				if substr(cExpress,nSubMcr1,1) == "_"
					cExpress := substr(cExpress,1,nSubMcr2) + "->" + cExpress
				endif
				cConteudo := &(cExpress)
				cConteudo := iIf(valType(cConteudo) == "C", cConteudo, iIf(valType(cConteudo) == "D", dToc(cConteudo), iIf(valType(cConteudo) == "N", cValToChar(cConteudo),"" )))
				if len(cConteudo) > aConteudo[NY,3]
					cConteudo := substr(cConteudo, 1,aConteudo[nY,3])
				else
					cConteudo := padr(cConteudo,aConteudo[NY,3]," ")
				endif
				
			else
				cConteudo := cExpress
			endif
			
			if empty(cTexto)
				//se a coluna inicial ้ maior que 0
				if aConteudo[nY,2] > 0
					nDifIni := aConteudo[nY,2]
					cTexto += Repl(" ",nDifIni) + padr(cConteudo,iIf(aConteudo[NY,3] > len(cConteudo),aConteudo[NY,3], len(cConteudo) )," ")
				else
					cTexto += padr(cConteudo,aConteudo[NY,3]," ")
				endif
			elseif NY > 1 .and. aConteudo[NY,2] >= len(cTexto)   //Se a coluna inicial do segundo termo ้ maior que o tamanho da expressao
				cTexto := padr(cTexto, aConteudo[nY,2] - 1, " ") + cConteudo
			elseif nY > 1
				//se o tamanho do conteudo NAO sobrepoe totalmente o texto atual
				if aConteudo[NY,2] + aConteudo[nY,3] < len(cTexto)
					cDifFim := substr(cTexto,aConteudo[nY,2] + aConteudo[nY,3] + 1, (len(cTexto))-aConteudo[nY,2] + aConteudo[nY,3] + 1)
					cTexto := substr(cTexto,1,aConteudo[nY,2]-1) + cConteudo + cDifFim
				else
					cTexto  := Substr(cTexto,1,aConteudo[nY,2]-1) + cConteudo
				endif
			endif
		endif
	next nY
	cRetorno := cTexto
else
	if len(aConteudo) = 0
		aConteudo := ""
	else
		//Coluna inicial
		nDifIni   :=  aConteudo[1,2]
		nDifMid   :=  aConteudo[1,3]
		//Definindo o conteudo da linha
		cExpress  := aConteudo[1,1]
		if !lTexto
			if substr(cExpress,nSubMcr1,1) == "_"
				cExpress := substr(cExpress,1,nSubMcr2) + "->" + cExpress
			endif
			cConteudo := &cExpress
			cConteudo := iIf(valType(cConteudo) == "C", cConteudo, iIf(valType(cConteudo) == "D", dToc(cConteudo), iIf(valType(cConteudo) == "N", cValToChar(cConteudo),"" )))
			if len(cConteudo) > aConteudo[1,3]
				cConteudo := substr(cConteudo, 1,aConteudo[1,3])
			else
				cConteudo := padr(cConteudo,aConteudo[1,3]," ")
			endif
		else
			cConteudo := cExpress
		endif
		
		//se a coluna inicial ้ maior que 0
		if nDifIni > 0
			cTexto += Repl(" ",nDifIni) + cConteudo
		else
			cTexto += padr(cConteudo,nDifMid," ")
		endif
		
		cRetorno := cTexto
	endif
endif

restArea(aArea)
return cRetorno

/*
###################################################################################
###################################################################################
### Programa  # FS_fonteR71      ### Autor #  Saude       ### Data # 22/02/2012 ###
###################################################################################
### Descricao # Tela para configuracao de fonte para o campo selecionado        ###
###################################################################################
### Parametro #                                                                 ###
###           #                                                                 ###
###           #                                                                 ###
###################################################################################
### Retorno   # cRet - texto a ser impresso na pre visualizacao                 ###
###################################################################################
### Uso       # GH                                                              ###
###################################################################################
*/
static function FS_fonteR71()
Local aArea      := getArea()
Local oBtnOk
Local oBtnCanc
Local oRadioPlTr
Local aTipFontR71 := {"0=Arial","1=Courier New", "2=Times New Roman", "3=Helvetica", "4=Microsoft Sans Serif", "5=Verdana", "6=Tahoma", "7=Andalus", "8=Century", "9=Cordia New"}//Fontes homologadas para a classe TMSPrinter - GC8_TIPFONT
Local aEstFontR71 := {"1=" + STR0147, "2=" + STR0148, "3=" + STR0149, "4=" + STR0150,;//"Regular" ### "Italico" ### "Negrito" ### "Sublinhado"
"5=" + STR0149 + " " + STR0148, "6=" + STR0149 + " " + STR0150, "7=" + STR0148 + " " + STR0150, "8=" + STR0149 + " " + STR0148 + " " + STR0150} // "Negrito" ### "Italico" ### "Negrito ### "Sublinhado" ### "Italico" ### "Sublinhado" ### "Negrito" ### "Italico" ### "Sublinhado"
Local aCorR71      := {"0=" + STR0137, "1=" + STR0138, "2=" + STR0139, "3=" + STR0140, "4=" + STR0141, ; //"Preto" ### "Azul" ### "Verde" ### "Ciano" ### "Vermelho"
"5=" + STR0142, "6=" + STR0143, "7=" + STR0144, "8=" + STR0145, "9=" + STR0146} //"Magenta" ### "Marrom" ### "Cinza" ### "Amarelo" ### "Branco"
local cCorR71      := ""
Local cMatriz      := ""
Local nPosTip      := nPosEst := nPosTam := nPosCor := 0
Local nFolder      := oFolder:nOption
Local nPosTemp     := 0

private oComboCor

Static oDlgFontR71


If nFolder == 1
	cMatriz := "aCampos"
ElseIf nFolder == 2
	cMatriz := "aExpress"
EndIf

M->TIPFON  := ""
M->ESTFON  := ""
M->TAMFTE  := 0
M->CORFON  := ""

//Se nao esta incluindo campo/expressao
if !lAddCamExp
	if !empty(&cMatriz[nPosicao][12]) .and.  !empty(&cMatriz[nPosicao][13]) .or. &cMatriz[nPosicao][14] > 0 .or. !empty(&cMatriz[nPosicao][15])
		
		
		nPosTip := iIf(valtype(&cMatriz[nPosicao][12]) == "N", &cMatriz[nPosicao][12] + 1, iIf(valtype(&cMatriz[nPosicao][12]) == "C", val(substr(&cMatriz[nPosicao][12],1,1))+1,1))
		nPosEst := iIf(valtype(&cMatriz[nPosicao][13]) == "N", &cMatriz[nPosicao][13], iIf(valtype(&cMatriz[nPosicao][13]) == "C", val(substr(&cMatriz[nPosicao][13],1,1)),1))
		if  iIf(valType(&cMatriz[nPosicao][15]) == "N", &cMatriz[nPosicao][15], iIf(valType(&cMatriz[nPosicao][15]) == "C", val(&cMatriz[nPosicao][15]),1)) > 0
			nPosTam := Ascan(aTamFontR71,{|aVet| aVet == cValToChar(&cMatriz[nPosicao][14])})
		else
			nPosTam := 1
		endif
		nPosTemp := iIf(valtype(&cMatriz[nPosicao][15]) == "N", &cMatriz[nPosicao][15], iIf(valtype(&cMatriz[nPosicao][15]) == "C", val(substr(&cMatriz[nPosicao][15],1,1)),1))
		nPosCor  := iIf(nPosTemp == 0, 1, nPosTemp)
		
	else
		dbSelectArea("GC8")
		dbSetOrder(1)
		if dbSeek(xFilial("GC8") + M->GC7_CODETI)
			while GC8->GC8_CODETI == M->GC7_CODETI
				if cMatriz == "aCampos"
					if GC8->GC8_CAMPO == oLbxCampo:aArray[oLbxCampo:nAt,2]
						nPosTip  := iIf(!empty(GC8->GC8_TIPFON), val(GC8->GC8_TIPFON),0)
						nPosEst  := iIf(!empty(GC8->GC8_ESTFON), val(GC8->GC8_ESTFON),0)
						//nPosTam  := GC8->GC8_TAMFTE
						nPosTam  := Ascan(aTamFontR71,{|aVet| aVet == cValToChar(GC8->GC8_TAMFTE)})
						nPosCor  := iIf(!empty(GC8->GC8_CORFON), val(GC8->GC8_CORFON),0)
					endif
				else
					if GC8->GC8_CAMPO == oLbxExpressao:aArray[oLbxExpressao:nAt,2]
						nPosTip  := iIf(!empty(GC8->GC8_TIPFON), val(GC8->GC8_TIPFON),0)
						nPosEst  := iIf(!empty(GC8->GC8_ESTFON), val(GC8->GC8_ESTFON),0)
						//nPosTam  := GC8->GC8_TAMFTE
						nPosTam  := Ascan(aTamFontR71,{|aVet| aVet == cValToChar(GC8->GC8_TAMFTE)})
						nPosCor  := iIf(!empty(GC8->GC8_CORFON), val(GC8->GC8_CORFON),0)
					endif
				endif
				GC8->(dbSkip())
			end
		endif
		GC8->(dbCloseArea())
	endif
	nPosTemp:=0
endif

//Altura / largura
DEFINE MSDIALOG oDlgFontR71 TITLE STR0136 FROM 000, 000  TO 200, 560 COLORS 0, 16777215 PIXEL //"Configurar Fonte"

@ 010,010 LISTBOX oLbxTipFont FIELDS HEADER STR0135 SIZE 080,60 OF oDlgFontR71 PIXEL  //"Fonte"
oLbxTipFont:SetArray( aTipFontR71 )
oLbxTipFont:bLine := {|| {aTipFontR71[oLbxTipFont:nAt]}}
if nPosTip > 0
	oLbxTipFont:nAt := nPosTip
else
	oLbxTipFont:nAt := 1
endif
oLbxTipFont:refresh()

@ 010,100 LISTBOX oLbxEstFont FIELDS HEADER STR0134 SIZE 080,060 OF oDlgFontR71 PIXEL  //"Estilo"
oLbxEstFont:SetArray( aEstFontR71 )
oLbxEstFont:bLine := {|| {aEstFontR71[oLbxEstFont:nAt]}}
if nPosEst > 0
	oLbxEstFont:nAt := nPosEst
else
	oLbxEstFont:nAt := 1
endif
oLbxEstFonte:refresh()

@ 010,190 LISTBOX oLbxTamFont FIELDS HEADER STR0133 SIZE 080,060 OF oDlgFontR71 PIXEL  //"Tamanho"
oLbxTamFont:SetArray( aTamFontR71 )
oLbxTamFont:bLine := {|| {aTamFontR71[oLbxTamFont:nAt]}}
if nPosTam > 0
	oLbxTamFont:nAt := nPosTam
else
	oLbxTamFont:nAt := 1
endif
oLbxTamFont:refresh()

@ 075, 010 Say OemToAnsi(STR0132) Size 075, 009 OF oDlgFontR71 PIXEL //"Cor da fonte"
oComboCor := tComboBox():New(085, 010, {|u| if( Pcount( ) > 0, (oComboCor:=u, cCorR71 := SubStr(oComboCor,1,1)),oComboCor) } , aCorR71, 080, 020, oDlgFontR71,/*uParam8*/, /*bChange*/, /*bValid*/, /*nClrBack*/, /*nClrText*/, /*lPixel*/ .T., /*oFont*/, /*uParam15*/, /*uParam16*/, /*bWhen*/ , /*uParam18*/, /*uParam19*/, /*uParam20*/, /*uParam21*/, /*cReadVar*/ "cCorR71"  )
if nPosCor > 0
	oComboCor:nAt := nPosCor + 1
else
	oComboCor:nAt := 1
endif

@ 085, 190 BUTTON oBtnOk   PROMPT "Ok" SIZE 037, 012 OF oDlgFontR71 ACTION {|| ;
lAddCamExp := .F.,; //Nao esta mais incluindo expressao
&cMatriz[nPosicao][12] 	:= M->TIPFON := aTipFontR71[oLbxTipFont:nAt],;
&cMatriz[nPosicao][13] 	:= M->ESTFON := aEstFontR71[oLbxEstFont:nAt],;
&cMatriz[nPosicao][14]	:= M->TAMFTE := aTamFontR71[oLbxTamFont:nAt],;
&cMatriz[nPosicao][15] 	:= M->CORFON := cCorR71,;
oDlgFontR71:End()} PIXEL //"Ok"*/

@ 085, 230 BUTTON oBtnCanc PROMPT STR0131 SIZE 037, 012 OF oDlgFontR71 ACTION {|| oDlgFontR71:End()} PIXEL //"Cancelar"

ACTIVATE MSDIALOG oDlgFontR71 CENTERED

restArea(aArea)
return(NIL)

/*
###################################################################################
###################################################################################
### Programa  # FS_retFontR71    ### Autor #  Saude       ### Data # 27/02/2012 ###
###################################################################################
### Descricao # Retorna a fonte a ser utlizada na pre visualizacao/impressao    ###
###################################################################################
### Parametro # aConteudo - array com as expressoes e as opcoes de fonte        ###
###           # do texto final.                                                 ###
###           # Deve conter:                                                    ###
###           #               [nI,1] = Titulo Campo (Char)                      ###
###           #               [nI,2] = Linha (Char)                             ###
###           #               [nI,3] = Tamanho (Num)                            ###
###           #               [nI,4] = Tipo Fonte (Char)                        ###
###           #               [nI,5] = Estilo Fonte (Char)                      ###
###           #               [nI,6] = Tamanho Fonte (Char)                     ###
###           #               [nI,7] = Cor Fonte (Char)                         ###
###################################################################################
### Retorno   # oFontR71 - Fonte a ser usada na impressao                       ###
###################################################################################
### Uso       # GH                                                              ###
###################################################################################
*/

static function FS_retFontR71(aFontR71, lPosTam)

Local oFontR71 := TFont():New()
Local oFontRet
Local nI         := 0
Local cTipFont  := ""
Local cEstFont  := ""
Local nTamFont  := 0
Local cCorFont  := CLR_BLACK

Local lRegular    := .F.
Local lNegrito    := .F.
Local lItalico    := .F.
Local lSublinhado := .F.

Default lPosTam := .F.


for nI := 1 to len(aFontR71)
	if !empty(aFontR71[nI,4])
		cTipFont := aFontR71[nI,4]
	endif
	
	if !empty(aFontR71[nI,5])
		cEstFont := aFontR71[nI,5]
	endif
	
	if valType(aFontR71[nI,6]) == "N"
		if aFontR71[nI,6] > 0
			nTamFont := aFontR71[nI,6]
		endif
	else
		if val(aFontR71[nI,6]) > 0
			if !lPosTam
				nTamFont := val(aTamFontR71[val(aFontR71[nI,6])])
			else
				nTamFont := val(aFontR71[nI,6])
			endif
		endif
	endif
	
	if !empty(aFontR71[nI,7])
		cCorFont := aFontR71[nI,7]
	endif
next nI

if empty(cTipFont) .and. empty(cEstFont) .and. nTamFont == 0 .and. empty(cCorFont)
	return {oFontR71, cCorFont}
endif

cTipFont := iIf(len(cTipFont) > 1, substr(cTipFont,1,1), cTipFont)
cTipFont := hs_gDesCbx("GC8_TIPFON", cTipFont)
nTamFont := -(nTamFont)

cEstFont := iIf(len(cEstFont) > 1, substr(cEstFont,1,1), cEstFont)
//Estilo da fonte - GC8_ESTFON - CBOX
if cEstFont == "1" //Regular
	lRegular    := .T.
elseif cEstFont == "2" //Italico
	lItalico    := .T.
elseif cEstFont == "3" //Negrito
	lNegrito    := .T.
elseif cEstFont == "4" //Sublinhado
	lSublinhado := .T.
elseif cEstFont == "5" //Negrito Italico
	lNegrito    := .T.
	lItalico    := .T.
elseif cEstFont == "6" //Negrito Sublihnado
	lNegrito    := .T.
	lSublinhado  := .T.
elseif cEstFont == "7" //Italico Sublinhado
	lItalico    := .T.
	lSublinhado  := .T.
elseif cEstFont == "8" //Negrito Italico Sublinhado
	lItalico    := .T.
	lSublinhado := .T.
	lNegrito    := .T.
endif

//Cor
if empty(cCorFont)
	cCorFont := CLR_BLACK
else
	for nI := 0 to len(aCoresFont)-1
		if iIf(valType(cCorFont) == "C", cCorFont, cValToChar(cCorFont)) == cValToChar(nI)
			cCorFont := aCoresFont[nI+1]
		endif
	next nI
endif


oFontRet := TFont():New(cTipFont,,nTamFont,,lNegrito,,,,,lSublinhado,lItalico)
return {oFontRet, cCorFont}



/*
###################################################################################
###################################################################################
### Programa  # fs_atuSayR71     ### Autor #  Saude       ### Data ##07/03/2012 ###
###################################################################################
### Descricao # Atualiza o conteudo da visualizacao da etiqueta                 ###
###################################################################################
### Parametro #                                                                 ###
###################################################################################
### Retorno   #                                                                 ###
###################################################################################
### Uso       # GH                                                              ###
###################################################################################
*/
static function fs_atuSayR71(lRefresh)
local nL        := 0
local nY        := 0
local nW         := 1
local aFont      := {}
local cVarM     := ""
local cVarObj     := ""
local cVarTexto   := ""
local cVarCorLoc  := ""
local cNewText    := ""
local cNewFont    := ""
local cNewCor     := ""
Local nFolder     := oFolder:nOption
local cMatriz     := ""
local cPathR71    := GetSrvProfString("Startpath","")
local cLogoR71    := "R71LOGO.bmp"
local cTextoAtu   := ""
local cVarColLoc := ""
local cVarLinLoc := ""
local nSubMcr1		:= 0
local nSubMcr2		:= 0

Default lRefresh := .F.

If nFolder == 1
	cMatriz := "aCampos"
ElseIf nFolder == 2
	cMatriz := "aExpress"
EndIf

//Identifica se o Alias selecionado inicia em "S"
If SubStr(cCombo2,1,1) == "S"
	nSubMcr1 	:= 3
	nSubMcr2	:= 2
Else
	nSubMcr1 	:= 4
	nSubMcr2	:= 3
EndIf

//Se ้ impressora texto, finaliza
if oCombo1:nAt == 1
	return
	//Se ้ impressora termica, atualiza somente a imagem de exibicao e finaliza
elseif oCombo1:nAt == 3
	If !Empty(cLogoR71)
		FErase(cPathR71 + cLogoR71)
	endif
	if !empty(M->GC7_LOGO) .and. (oCombo1:nAt == 3 .or. oCombo1:nAt == 2)
		if RepExtract(alltrim(M->GC7_LOGO), cPathR71 + cLogoR71)			
			oTBitmap1 := TBitmap():New(M->GC7_YLOGO, M->GC7_XLOGO,40, 40, , cPathR71 + cLogoR71,.F.,oEtiqueta,,,,,,,,,.T.,,,,)
			oTBitmap1:lAutoSize := .T.
			oEtiqueta:Refresh()
			oDlgPos:Refresh()
		endif
	endif

	return
endif


//Excluindo imagem para exibicao anterior
FErase(cPathR71 + cLogoR71)
//Carregando imagem para exibicao
if !empty(M->GC7_LOGO) .and. (oCombo1:nAt == 3 .or. oCombo1:nAt == 2)
	if RepExtract(alltrim(M->GC7_LOGO), cPathR71 + cLogoR71)
		oTBitmap1 := TBitmap():New(M->GC7_YLOGO, M->GC7_XLOGO,40, 40, , cPathR71 + cLogoR71,.F.,oEtiqueta,,,,,,,,,.T.,,,,)
		oTBitmap1:lAutoSize := .T.
		
		oTBitmap2 := TBitmap():New(M->GC7_YLOGO, M->GC7_XLOGO,40, 40, , cPathR71 + cLogoR71,.F.,oEtiqExp,,,,,,,,,.T.,,,,)
		oTBitmap2:lAutoSize := .T.
	endif
endif

nLinha := 0
//Criando variaveis para impressao
for nL := 1 to 30
	cVarM := "M->LinhaExp" + cValToChar(nL)
	
	for nY := 1 to len(&cVarM)
		cVarObj   := "oSay" + cValToChar(nW)
		
		cVarTexto  := "cSay" + cValToChar(nW)
		
		cVarCorLoc := "cCor" + cValToChar(nW)
		
		cVarColLoc := "cColuna" + cValToChar(nW)
		cVarLinLoc := "cLinha" + cValToChar(nW)
		
		if lRefresh
			
			//freeObj(oEtiqExp)
			//oEtiqExp  :=	tPanel():New((nAltura-nEtiAltura)/2,(nLargura-nEtiLargura)/2,,oFolVis:aDialogs[2],,,,,CLR_HGRAY,nEtiLargura,nEtiAltura)
			
			//Se o Conteudo for um campo
			SX3->(DBSetOrder(1))
			If SX3->(DBSeek(SubStr(cCombo2,1,3))) .and. SubStr(&(cVarM)[nY,1],nSubMcr1,1) == "_"
				cTextoAtu :=  &(SubStr(cCombo2,1,3) + "->" + &(cVarM)[nY,1])
			Else
				cTextoAtu := &(&(cVarM)[nY,1])
			EndIf
			
			aAdd(aFont, {"","","",&(cVarM)[nY,4],;
			&(cVarM)[nY,5],;
			&(cVarM)[nY,6],;
			&(cVarM)[nY,7]})
								
			aFonT := FS_retFontR71(aFont, iIf(lRefresh,.T., .F.))
			
			//Fonte / Cor
			cNewText    := "cNewText" + cValToChar(nW)
			cNewFont    := "cNewFont" + cValToChar(nW)
			cNewCor     := "cNewCor" + cValToChar(nW)
			
			//&cNewText := &(cVarM)[nY,1]
			&cNewText := cTextoAtu
			&cNewFont := aFonT[1]
			&cNewCor  := aFonT[2]
			
			
			cVarObj   := "oSay" + cValToChar(nW)
			//&(cVarObj) := tSay():New(&cVarLinLoc,&cVarColLoc*2,{|| &cNewText },oEtiqExp,, &cNewFont,,,,.T.,&cNewCor,,,)
			_SetOwnerPrvt(cVarLinLoc  , nLinha)			
			_SetOwnerPrvt(cVarColLoc  , &(cVarM)[nY,2])			
			If ValType(cVarObj) == "O"
				cVarObjAux   := "oSay00" + cValToChar(nW)
				&(cVarObjAux) := tSay():New(&cVarLinLoc,&cVarColLoc,{|| "" },oEtiqExp,, ,,,,.T.,,,,)

				&cVarObj:nClrText := &cNewCor
				&cVarObj:SetText(&cNewText)
				&cVarObj:oFont    := &cNewFont 
				&cVarObj:nTop := &cVarObjAux:nTop                
				&cVarObj:nBottom := &cVarObjAux:nBottom				
				&cVarObj:nLeft := &cVarObjAux:nLeft
				/*&cVarObj:nRight := &cVarObjAux:nRight 								*/
				&cVarObj:Refresh()
				//_SetOwnerPrvt(cVarObjAux  , nil)           				
			Else
				//Criando campo/expressao inserido
				_SetOwnerPrvt(cVarObj  , nil)
				_SetOwnerPrvt(cVarCorLoc  , &cNewCor)

				_SetOwnerPrvt(cNewText, &cNewText)
				_SetOwnerPrvt(cNewFont, &cNewFont)
				_SetOwnerPrvt(cNewCor,  &cNewCor)
				
				&(cVarObj) := tSay():New(&cVarLinLoc,&cVarColLoc*2,{|| &cNewText },oEtiqExp,, &cNewFont,,,,.T.,&cNewCor,,,)
				
				&cVarObj:nClrText := &cNewCor
				&cVarObj:SetText(&cNewText)
				&cVarObj:oFont    := &cNewFont
				&cVarObj:Refresh()
			endif
			
			aFonT := {}
			
		else
			&cVarObj:nClrText := &cVarCorLoc
			&cVarObj:SetText(&cVarTexto)
			//&cVarObj:Refresh()
		endif
		
		nQtdObj++
		nW++
		
	next nY
	nLinha+=5
next nL
nW := 1

if lTipFont
	oEtiqExp:Refresh()
endif
oDlgPos:Refresh()

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fPergImp
Perguntas Impressใo de Etiquetas

@author    Guilherme Carvalho
@version   P12
@since     16/04/2018
/*/
//------------------------------------------------------------------------------------------
Static Function fPergImp(cPerg)
Local lRet			:= .F.
Local aPergs		:= {}
Local nX			:= 1
Local nQtdEti		:= 1
Local cCodPac		:= Space(6)
Local cPergParam	:= ""
Local cPicture		:= ""
Local nTamanho		:= 0
Local xConteudo

Pergunte(cPerg,.F.)

dbSelectArea("SX1")
dbSetOrder(1)
If SX1->(msSeek(cPerg))
	While !SX1->(Eof()) .And. AllTrim(SX1->X1_GRUPO) == AllTrim(cPerg)
		
		cPergParam := StrTran(AllTrim(SX1->X1_PERGUNT),"?","")
		
		If AllTrim(SX1->X1_TIPO) == "C"
			xConteudo 	:= PADR(SX1->X1_CNT01, SX1->X1_TAMANHO)
			cPicture 	:= "@!"
			nTamanho	:= SX1->X1_TAMANHO*3
			nTamanho	:= IIF( nTamanho < 040, 040, nTamanho )
			nTamanho	:= IIF( nTamanho > 120, 120, nTamanho )
		ElseIf AllTrim(SX1->X1_TIPO) == "N"
			xConteudo 	:= Val(AllTrim(SX1->X1_CNT01))
			cPicture 	:= "@E "+Replicate("9",SX1->X1_TAMANHO-SX1->X1_DECIMAL-1)
			If( SX1->X1_DECIMAL>0 )
				cPicture += "."+Replicate("9",SX1->X1_DECIMAL)
			Else
				cPicture += "9"
			EndIf
			nTamanho	:= SX1->X1_TAMANHO	
		ElseIf AllTrim(SX1->X1_TIPO) == "D"
			If Empty(SX1->X1_CNT01)
				xConteudo 	:= CToD("")
			Else
				xConteudo 	:= CToD(AllTrim(SX1->X1_CNT01))
			EndIf
			cPicture 	:= "@!"
			nTamanho	:= 50
		EndIf
		
		aadd( aPergs, {  1 	,cPergParam					;
							,xConteudo					;
							,cPicture					;
							,AllTrim(SX1->X1_VALID)		;
							,AllTrim(SX1->X1_F3)		;
							,/*'.T.'*/					;
							,nTamanho					;
							,.F. } 						)	
		SX1->(DbSkip())
	EndDo
EndIf

If( paramBox( aPergs, "Impressใo de Etiquetas", _aRet,/*bOK*/,/*aButtons*/,.T.,/*nPosX*/,/*nPosY*/,/*oDlgWizard*/,cPerg,/*lCanSave*/.F.,/*lUserSave*/ ) )
	
	If( VldPergImp( _aRet ) )
		lRet := .T.
	Else
		lRet := fPergImp()
	EndIf
EndIf
	
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldPergImp
Validador de perguntas

@author    Guilherme Guilherme
@version   P12
@since     16/04/2018
/*/
//------------------------------------------------------------------------------------------
Static Function VldPergImp( _aRet )
	Local lRet	 	:= .T.
	Local nX		:= 0
	Local cMvPar 	:= ""
	
	For nX:=1 to len( _aRet )
		cMvPar := "MV_PAR"+StrZero(nX,2)
		&cMvPar := _aRet[nX]	
	Next nX
	
Return lRet
