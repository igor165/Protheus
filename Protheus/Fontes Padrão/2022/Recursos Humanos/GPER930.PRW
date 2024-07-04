#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER930.CH"   
#INCLUDE "REPORT.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER930  ³ Autor ³ Leandro Drumond         ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Imposto de Renda sobre RRA                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER930(void)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³Chamado³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³15/08/2014³TQIBW3 ³Incluido o fonte da 11 para a 12 e efetu-³±±
±±³            ³          ³       ³ada a limpeza.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPER930()
Local aArea		:= GetArea()

Private oReport   
Private cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0002) + OemToAnsi(STR0003)//"Dirf Mensal" ### "Ser  impresso de acordo com os parametros solicitados pelo"  ### "usu rio."
Private cTit    := OemToAnsi(STR0004)			//"RELATORIO DIRF MENSAL"
Private nTamanho:="M"                                                         
Private nTpImpre:= 0
Private _nTipo	:= 0
Private cFilAnterior := Replicate("!", FWGETTAMFILIAL)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private wnrel:="GPER930"            //Nome Default do relatorio em Disco

If fRadioPerg(@nTpImpre) == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carregar os Mnemonicos 	                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetMnemonicos(NIL,NIL,.T.)
	oReport := ReportDef()
	oReport:PrintDialog()
ElseIf nTpImpre > 0
	GPER930R3(4)	  
EndIf

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ReportDef  ³ Autor ³ Leandro Drumond       ³ Data ³11/07/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Relatorio de Imposto de Renda / DIRF RRA                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER930(void)                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER930 - Generico - Release 4                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
Local oSection1 
Local oCell
Local cTitulo	:= OemToAnsi(STR0004)			//"RELATORIO DIRF MENSAL"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE REPORT oReport NAME "GPER930" TITLE cTitulo PARAMETER "GPR930A" ACTION {|oReport| R930Imp(oReport)} DESCRIPTION OemtoAnsi(STR0020) //"RELATORIO DIRF MENSAL" ### "Emite Relacao do Imposto de Renda - Dirf Mensal." 
oReport:SetTotalInLine(.F.)
Pergunte("GPR930A",.F.)

oSection1 := TRSection():New(oReport,OemToAnsi(STR0001),{"SRA","SRC"},{OemToAnsi(STR0008),OemToAnsi(STR0009),OemToAnsi(STR0010)},,) // "Contribuicoes" ### "Matr¡cula" ### "Centro de Custo" ### "Nome"
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderBreak(.T.)
oSection1:SetHeaderPage(.T.) 
oSection1:SetHeaderSection(.T.)

TRCell():New(oSection1,"RA_FILIAL" ,"SRA"	,OemToAnsi(STR0027),/*Picture*/			,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Fil."
TRCell():New(oSection1,"RA_CC"     ,"SRA"	,OemToAnsi(STR0028),/*Picture*/			,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "C.Custo"
TRCell():New(oSection1,"RA_MAT"    ,"SRA"	,OemToAnsi(STR0029),/*Picture*/			,8 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "Matr."
TRCell():New(oSection1,"RA_NOME"   ,"SRA"	,/*Titulo Coluna*/ ,/*Picture*/			,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 	// "Nome"
TRCell():New(oSection1,"CIDCMPL"	,"   "	,"Id.Complemento" ,/*Picture*/			,6 /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 	// "Id.Complemento"

TRCell():New(oSection1,"NFL_LCR_BS","  "	, oemToAnsi(STR0021),"@E 99,999,999.99"  ,13,, {|| aFolBas[_nTipo] }) //"Base IR RRA"
TRCell():New(oSection1,"NFL_LCR_IR","  "	, oemToAnsi(STR0022),"@E 99,999,999.99"  ,13,, {|| aFolIR[_nTipo]  }) //"IR RRA"

TRCell():New(oSection1,"N13SAL_BS" ," "	    ,OemToAnsi(STR0023),"@E 99,999,999.99" 	,13 ,/*lPixel*/,{|| a13Bas[_nTipo]   } /*{|| code-block de impressao }*/)	// "Base 13. RRA"
TRCell():New(oSection1,"N13SAL_IR"	," "	,OemToAnsi(STR0024),"@E 99,999,999.99" 	,13	,/*lPixel*/,{|| a13IR[_nTipo]    } /*{|| code-block de impressao }*/)	// "IR 13. RRA"
TRCell():New(oSection1,"NTOTAIS_BS"	," "  	,OemToAnsi(STR0025),"@E 99,999,999.99"	,13	,/*lPixel*/,{|| aFolBas[_nTipo] + a13Bas[_nTipo]  } /*{|| code-block de impressao }*/)	// "Totais Base"
TRCell():New(oSection1,"NTOTAIS_IR"	," "    ,OemToAnsi(STR0026),"@E 99,999,999.99"	,13	,/*lPixel*/,{|| aFolIR[_nTipo] + a13IR[_nTipo]     } /*{|| code-block de impressao }*/)	// "Totais IR"

oSection1:SetAutoSize()

oSection1:Cell("RA_FILIAL"):SetHeaderAlign("LEFT")
oSection1:Cell("RA_CC"):SetHeaderAlign("LEFT")
oSection1:Cell("RA_MAT"):SetHeaderAlign("LEFT")
oSection1:Cell("RA_NOME"):SetHeaderAlign("LEFT")
oSection1:Cell("CIDCMPL"):SetHeaderAlign("LEFT")
oSection1:Cell("NFL_LCR_BS"):SetHeaderAlign("RIGHT")
oSection1:Cell("NFL_LCR_IR"):SetHeaderAlign("RIGHT")
oSection1:Cell("N13SAL_BS"):SetHeaderAlign("RIGHT")
oSection1:Cell("N13SAL_IR"):SetHeaderAlign("RIGHT")
oSection1:Cell("NTOTAIS_BS"):SetHeaderAlign("RIGHT")
oSection1:Cell("NTOTAIS_IR"):SetHeaderAlign("RIGHT")

oSection1:Cell("RA_FILIAL"):SetAlign("LEFT")
oSection1:Cell("RA_CC"):SetAlign("LEFT")
oSection1:Cell("RA_MAT"):SetAlign("LEFT")
oSection1:Cell("RA_NOME"):SetAlign("LEFT")
oSection1:Cell("CIDCMPL"):SetAlign("LEFT")
oSection1:Cell("NFL_LCR_BS"):SetAlign("RIGHT")
oSection1:Cell("NFL_LCR_IR"):SetAlign("RIGHT")
oSection1:Cell("N13SAL_BS"):SetAlign("RIGHT")
oSection1:Cell("N13SAL_IR"):SetAlign("RIGHT")
oSection1:Cell("NTOTAIS_BS"):SetAlign("RIGHT")
oSection1:Cell("NTOTAIS_IR"):SetAlign("RIGHT")

Return(oReport)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R930Imp   ºAutor  ³Microsiga           º Data ³  11/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R930Imp(oReport)

GR930Imp(1,.F.,WnRel,"SRA","1",oReport,"GPER930")

Return NIl
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GR930Imp  ºAutor  ³Microsiga           º Data ³  11/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GR930Imp(nTipGer,lEnd,WnRel,cString,cAgrupa,oReport,cFonte)

If cFonte <> "GPER930"
	R3GR930Imp(nTipGer,lEnd,WnRel,cString,cAgrupa,oReport)
Else
	R930Impressao(nTipGer,lEnd,WnRel,cString,cAgrupa,oReport,cFonte)
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³R930ImpressaoºAutor ³Leandro Drumond   º Data ³  01/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function R930Impressao(nTipGer,lEnd,WnRel,cString,cAgrupa,oReport,cFonte)
Local oBreakFil
Local oBreakCCusto
Local lQuery 	 := .F.
Local aPeriodo	 := {}
Local cAcessaSRA := &("{ || " + ChkRH("GPER930","SRA","2") + "}")
Local cAcessaSRC := &("{ || " + ChkRH("GPER930","SRC","2") + "}")
Local cAcessaSRD := &("{ || " + ChkRH("GPER930","SRD","2") + "}")
Local cAliasQry	 := ""
Local cCpo		 := ""
Local cCpoData	 := ""
Local cChave	 := ""
Local cIndexOrd	 := ""
Local cDatarq	 := ""
Local dDataAux	 := CtoD("")
Local nX		 := 0
//Local cFiltro	 := ""
Local cTitCC	 := "" 
Local cTitFil	 := ""
Local cTit		 := ""
Local cTitulo  	 := ""
Local cFolMes    := ""
Local cChavePesq	:= ""
Local lGp050Fil	 := ExistBlock( "GP050FIL" )//variavel p/ PE GP050FIL 
Local lPass 	 := .F.
Local lRetPE     := .F.//variavel p/ PE GP050FIL
Local aPerAtual := {}

//Tratamento de transferencias  
Local aTransf		:= {}
Local cDataRecib	:= ""
Local lExitLoop		:= .F.
Local nTransf		:= 0
Local nLenaTransf	:= 0   

Default	oReport	 := ReportDef()                                 
Default cFonte	 := "GPER930"	

cTitulo			 := oReport:Title()

Private oSection1:= oReport:Section(1)    
Private aLinha   := {},nLastKey := 0
Private aCRA     := {STR0017,STR0018,STR0019}		//"Confirma"###"Repete"###"Abandona"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Utilizadas na funcao IMPR                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private Titulo
Private CONTFL:=1
Private LI:=0
Private nVez:=0
Private nOrdem		:= oSection1:GetOrder()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private(Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private nFolBas , nAdiBas , nFerBas , n13Bas
Private nFolIR  , nAdiIR  , nFerIR  , n13IR

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaves para faciliar o tratamento do processamento	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cFilDe    := mv_par01
Private cFilAte   := mv_par02
Private cCcDe     := mv_par03
Private cCcAte    := mv_par04
Private cMatDe    := mv_par05
Private cMatAte   := mv_par06
Private cNomDe    := mv_par07
Private cNomAte   := mv_par08
Private dDataDe   := mv_par09
Private dDataAte  := mv_par10
Private cSinAna   := If(mv_par11 == 1,"A","S")
Private lSalta    := If(mv_par12 == 1,.T.,.F.)
Private nTipImp   := 1
Private cCodRetDe := "    "
Private cCodRetAte:= "9999"
Private cIdCmpl	  := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private(Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aInfo     := {}
Private aCodFol   := {}
Private aCodLido  := {}
Private aFolBas[4] , aAdiBas[4] , aFerBas[4] , a13Bas[4]
Private aFolIR[4]  , aAdiIR[4]  , aFerIR[4]  , a13IR[4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaves para faciliar o tratamento do processamento	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lImpRelato  := (nTipGer == 1)  //Na geracao de titulo fincanceiro vem com valor diferente
Private lGeraTitulo := (nTipGer == 2)
Private lAgrupFil   := (cAgrupa == "1")
Private lAgrupCc    := (cAgrupa $  "2*3")
Private lAgrupFunc  := (cAgrupa == "4")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTit  	 := OemToAnsi(STR0031) + DTOC(dDataDe) + " - " + DTOC(dDataAte)	//""RELATORIO DIRF RRA                 Periodo: "
cTitulo  := If(AllTrim(oReport:Title())==AllTrim(cTitulo),cTit,oReport:Title())

//-- Altera o titulo do relatorio
oReport:SetTitle(cTitulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Quebra de pagina                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  nOrdem == 2 
	//-- Quebrar por Centro de Custo
	//-- Total Centro de Custo
	oBreakCCusto:= TRBreak():New(oSection1, {||oSection1:Cell("RA_FILIAL"):GetText()+'-'+oSection1:Cell("RA_CC"):GetText()},OemToAnsi(STR0032), .F.)	//"Total do Centro de Custo"
  
	If lSalta 
		oBreakCCusto:SetPageBreak()
	EndIf
	TRFunction():New(oSection1:Cell("NFL_LCR_BS" ),,"SUM",oBreakCCusto,"Total Fol./Lucro Base","@E 99,999,999.99",,.F.,.F.,)
	TRFunction():New(oSection1:Cell("NFL_LCR_IR" ),,"SUM",oBreakCCusto,"Total Fol./Lucro IR"  ,"@E 99,999,999.99",,.F.,.F.,)
	TRFunction():New(oSection1:Cell("N13SAL_BS"  ),,"SUM",oBreakCCusto,"Total 13.Sal. Base"   ,"@E 99,999,999.99",,.F.,.F.,)
	TRFunction():New(oSection1:Cell("N13SAL_IR"  ),,"SUM",oBreakCCusto,"Total 13.Sal. IR"     ,"@E 99,999,999.99",,.F.,.F.,)
	TRFunction():New(oSection1:Cell("NTOTAIS_BS" ),,"SUM",oBreakCCusto,"Totais Bases"         ,"@E 99,999,999.99",,.F.,.F.,)
	TRFunction():New(oSection1:Cell("NTOTAIS_IR" ),,"SUM",oBreakCCusto,"Totais IR"            ,"@E 99,999,999.99",,.F.,.F.,)

	oBreakCCusto:OnBreak({|x,y|cTitCC:=OemToAnsi(STR0032)+": "+x})	//"Total do Centro de Custo"
    oBreakCCusto:SetTotalText({||cTitCC})

EndIf

//-- Quebrar por Filial
//-- Total Filial
oBreakFil:= TRBreak():New(oSection1, oSection1:Cell("RA_FILIAL"),OemToAnsi(STR0033), .F.)	//"Total da Filial"
oBreakFil:SetPageBreak()

TRFunction():New(oSection1:Cell("NFL_LCR_BS" ),,"SUM",oBreakFil,"Total Fol./Lucro Base","@E 99,999,999.99",,.F.,.T.,)
TRFunction():New(oSection1:Cell("NFL_LCR_IR" ),,"SUM",oBreakFil,"Total Fol./Lucro IR"  ,"@E 99,999,999.99",,.F.,.T.,)
TRFunction():New(oSection1:Cell("N13SAL_BS"  ),,"SUM",oBreakFil,"Total 13.Sal. Base"   ,"@E 99,999,999.99",,.F.,.T.,)
TRFunction():New(oSection1:Cell("N13SAL_IR"  ),,"SUM",oBreakFil,"Total 13.Sal. IR"     ,"@E 99,999,999.99",,.F.,.T.,)
TRFunction():New(oSection1:Cell("NTOTAIS_BS" ),,"SUM",oBreakFil,"Totais Bases"         ,"@E 99,999,999.99",,.F.,.T.,)
TRFunction():New(oSection1:Cell("NTOTAIS_IR" ),,"SUM",oBreakFil,"Totais IR"            ,"@E 99,999,999.99",,.F.,.T.,)

oBreakFil:OnBreak({|x,y|cTitFil:=OemToAnsi(STR0033)+": "+x})	//"Total da Filial"
oBreakFil:SetTotalText({||cTitFil})

IF cSinAna =='S'
	oSection1:Cell("RA_FILIAL"):SetTitle('')
	oSection1:Cell("RA_CC"):SetTitle('')
	oSection1:Cell("RA_MAT"):SetTitle('')
	oSection1:Cell("RA_NOME"):SetTitle('')
	oSection1:Cell("CIDCMPL"):SetTitle('')
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os periodos onde devem ser lidos os identificadores de³
//³ verbas de folha de pagamento e adiantamento de salario.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MesAno(dDataDe) <> MesAno(dDataAte)
	If lImpRelato
		Aviso(OemToAnsi(STR0013),OemToAnsi(STR0014), { "OK"} )	//"Aviso"###"As datas inicial e final devem estar dentro do mesmo mês e ano. Verifique."
	EndIf
	Return nil
EndIf

dbSelectArea("SRA")
dbGoTop()  

fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, fGetRotOrdinar() ) //Obtem ano e mes do periodo atual 
If !Empty(aPerAtual)
	cFolMes := aPerAtual[1,5]+aPerAtual[1,4] //RCH_ANO + RCH-MES
EndIf

If MesAno(dDataDe) == cFolMes 
	Aadd(aPeriodo,{"SRC","RC",MesAno(dDataDe),"_DATA",SRC->(IndexKey()),"QSRC"})	   				//-- Mes Atual
	Aadd(aPeriodo,{"SRD","RD",MesAno(dDataDe-Day(dDataDe)),"_DATPGT",SRD->(IndexKey()),"QSRD"})	//-- Mes Anterior
ElseIf MesAno(dDataDe) < cFolMes 
	Aadd(aPeriodo,{"SRD","RD",MesAno(dDataDe),"_DATPGT",SRD->(IndexKey()),"QSRD"})				//-- Mes selecionado no parametro
	dDataAux	:= dDataDe-Day(dDataDe)
	Aadd(aPeriodo,{"SRD","RD",MesAno(dDataAux),"_DATPGT",SRD->(IndexKey()),"QSRD"})				//-- Mes Anterior ao mes selecionado
ElseIf MesAno(dDataDe) > cFolMes 
	Aadd(aPeriodo,{"SRC","RC",MesAno(dDataDe),"_DATA",SRC->(IndexKey()),"QSRC"})					//-- Mes selecionado no parametro
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria indice para Relatorio de IR.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOrdem == 1
	dbSetOrder(1)
	dbSeek(cFilDe + cMatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_MAT"
	cFim     := cFilAte + cMatAte
ElseIf nOrdem == 2
	dbSetOrder(2)
	dbSeek(cFilDe + cCcDe + cMatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
	cFim     := cFilAte + cCcAte + cMatAte
ElseIf nOrdem == 3
	dbSetOrder(3)
	dbSeek(cFilDe + cNomDe + cMatDe,.T.)
	cInicio  := "SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
	cFim     := cFilAte + cNomAte + cMatAte
EndIf

Afill(aFolBas,0)
Afill(a13Bas,0)
Afill(aAdiBas,0)
Afill(aFerBas,0)
Afill(aFolIR,0)
Afill(a13IR,0)
Afill(aAdiIR,0)
Afill(aFerIR,0)

cFilAnterior 	:= Replicate("!", FWGETTAMFILIAL)
cFilQuebra      := Replicate("!", FWGETTAMFILIAL)
cCcAnt  		:= "!!!!!!!!!"

dbSelectArea("SRA")

If lImpRelato
	//-- Incializa impressao   
	oSection1:Init()                              
	//-- Define o total da regua da tela de processamento do relatorio
	oReport:SetMeter( SRA->(RecCount()) )  
Else
	ProcRegua(SRA->(RecCount()))
EndIf

While !EOF() .And. &cInicio <= cFim

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimenta Cursor                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lImpRelato
		oReport:IncMeter(1)
	Else
		IncProc(STR0015) //"Gerando Titulos - Imposto de Renda"
	EndIf

	If lEnd
		Exit
	EndIf
	
	If SRA->RA_FILIAL # cFilQuebra
		If !FP_CODFOL(@aCodFol)
			Exit
		EndIf
		fInfo(@aInfo,SRA->RA_FILIAL)
  		If cFilQuebra # Space(FWGETTAMFILIAL)
			fImpFil()    // Totaliza Filial
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste Parametrizacao do Intervalo de Impressao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (SRA->RA_NOME < cNomDe)   .Or. (SRA->RA_NOME > cNomAte)  .Or. ;
	   (SRA->RA_MAT < cMatDe)    .Or. (SRA->RA_MAT > cMatAte)   .Or. ;
	   (SRA->RA_CC < cCcDe)      .Or. (SRA->RA_CC > cCcAte)     .Or. ;
	   (SRA->RA_FILIAL < cFilDe) .Or. (SRA->RA_FILIAL > cFilAte)
		fTestaTotal()
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste controle de acessos e filiais validas               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
		fTestaTotal()
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para desprezar funcionario caso retorne .T. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGp050Fil	
		lRetPE := ExecBlock( "GP050FIL", .F., .F. )
		If ( ( ValType(lRetPE) == "L" ) .and. lRetPE )
			fTestaTotal()
		EndIf
	EndIf 

	aCodLido := {}  // Contera as verbas ja lidas - evitara que nao sejam duplicadas

	For nX := 1 to Len(aPeriodo)
		cAlias		:= aPeriodo[nx,1]
		cCpo		:= aPeriodo[nx,2]
		cDatarq		:= aPeriodo[nx,3]
		cCpoData	:= aPeriodo[nx,4]
		cIndexOrd	:= aPeriodo[nx,5]
		cAliasQ		:= aPeriodo[nx,6]

    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste controle de acessos								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lQuery := fBuscaMvto(SRA->RA_FILIAL,SRA->RA_MAT,cAlias,cCpo,cDatarq,cCpoData,cIndexOrd,@cAliasQ)
		
		While !Eof() .And. ( (cAliasQ)->&(cCpo+"_FILIAL")+(cAliasQ)->&(cCpo+"_MAT") == SRA->RA_FILIAL+SRA->RA_MAT) .And.;
							If(cAliasQ == "SRD",cDatarq == SRD->RD_DATARQ,.T.)
	    	If (cAliasQ)->&(cCpo+cCpoData) < dDataDe .OR. (cAliasQ)->&(cCpo+cCpoData) > dDataAte .or. ;
				If(cAliasQ == "QSRD" .or. cAliasQ == "SRD", !Empty( (cAliasQ)->RD_EMPRESA), .F. )
		    	dbSkip()
		    	Loop
	    	EndIf
	    	
	    	cIdCmpl := (cAliasQ)->RF1_IDCMPL
	    	
	    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste controle de acessos								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cAliasQ == "SRC"
				If !Eval(cAcessaSRC)
					dbSkip()
					Loop
				EndIf
			Else
				If !Eval(cAcessaSRD)
					dbSkip()
					Loop
				EndIf
			EndIf

	    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folha de Pagamento                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cAliasQ)->&(cCpo+"_TIPO2") $ "C*I*G"
				// IR Folha
				If (cAliasQ)->&(cCpo+"_PD") == aCodFol[978,1]
					fSoma("FOLIR",(cAliasQ)->&(cCpo+"_VALOR"),(cAliasQ)->&(cCpo+"_PD"),(cAliasQ)->&(cCpo+cCpoData),.T.)
				EndIf
				
				// Base IR Folha
				If (cAliasQ)->&(cCpo+"_PD") == aCodFol[974,1] //.And. aFolIr[4] > 0
					fSoma("FOLBAS",(cAliasQ)->&(cCpo+"_VALOR"),(cAliasQ)->&(cCpo+"_PD"),(cAliasQ)->&(cCpo+cCpoData),.T.)
				EndIf
			EndIf

			lPass := .F.
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ 13§ Salario                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// IR 13 Salario
			If (cAliasQ)->&(cCpo+"_PD") == aCodFol[983,1] .And. (cAliasQ)->&(cCpo+"_TIPO2") # "R"
				fSoma("13IR",(cAliasQ)->&(cCpo+"_VALOR"),(cAliasQ)->&(cCpo+"_PD"),(cAliasQ)->&(cCpo+cCpoData),.T.)
			EndIf
			// Base IR 13 Salario
			If (cAliasQ)->&(cCpo+"_PD") == aCodFol[979,1] .And. (cAliasQ)->&(cCpo+"_TIPO2") # "R" //.And. a13Ir[4] > 0
				fSoma("13BAS",(cAliasQ)->&(cCpo+"_VALOR"),(cAliasQ)->&(cCpo+"_PD"),(cAliasQ)->&(cCpo+cCpoData),.T.)
			EndIf
			dbSkip()
		EndDo
	Next nx

	dbSelectArea("SRA")

	If	FTotAcumuladores(4,4) == 0
		fTestaTotal()
		Loop
	EndIf

	fImpFun()

	fTestaTotal()
EndDo

dbSelectArea("SRA")
Set Filter To
RetIndex( "SRA" )
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o alias padrao                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	If Select("QSRC") > 0
		QSRC->(dbCloseArea())
	EndIf
	If Select("QSRD") > 0
		QSRD->(dbCloseArea())
	EndIf
EndIf		

If lImpRelato
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza impressao inicializada pelo metodo Init             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:Finish()
EndIf
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fSoma			   ³Autor ³Leandro Drumond  ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                    		 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fSoma(cVetor,nVal,cCodVerba,dDataPagto,lSoma)

Local cChaveBusca := cCodVerba + MesAno(dDataPagto)
Local nFor

lSoma := If(lSoma == Nil,.F.,lSoma)

If Ascan( aCodLido, cChaveBusca ) == 0 .Or. lSoma
	cVet := "a" + cVetor
	For nFor = 1 To 4
		&(cVet)[nFor] += nVal
	Next nFor
	AADD(aCodLido, cChaveBusca )
EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FZeraAcumuladores³Autor ³Leandro Drumond  ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                    		 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FZeraAcumuladores(nDe,nAte)

Local nFor
For nFor = nDe TO nAte
	aFolBas[nFor] := 0
	a13Bas[nFor]  := 0
	aAdiBas[nFor] := 0
	aFerBas[nFor] := 0
	aFolIR[nFor]  := 0
	a13IR[nFor]   := 0
	aAdiIR[nFor]  := 0
	aFerIR[nFor]  := 0
Next nFor 

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FTotAcumuladores ³Autor ³Leandro Drumond  ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                    		 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FTotAcumuladores(nDe,nAte)

Local nTotal := 0
Local nFor
For nFor = nDe To nAte
	nTotal += aFolBas[nFor]
	nTotal += a13Bas[nFor]
	nTotal += aFolIR[nFor]
	nTotal += a13IR[nFor]
Next nFor

Return nTotal
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fTestaTotal ³ Autor ³Leandro Drumond      ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                    		 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fTestaTotal()

cFilAnterior := SRA->RA_FILIAL
cFilQuebra 	 := SRA->RA_FILIAL
cCcAnt     	 := SRA->RA_CC

oSection1:Cell("RA_FILIAL"):SetValue(SRA->RA_FILIAL)
oSection1:Cell("RA_CC"):SetValue(SRA->RA_CC)
oSection1:Cell("RA_MAT"):SetValue(SRA->RA_MAT)
oSection1:Cell("RA_NOME"):SetValue(SRA->RA_NOME) 

dbSelectArea("SRA")
dbSkip()

If Eof() .Or. &cInicio > cFim   
	fImpCc() 
	fImpFil()            
	fImpEmp()
ElseIf (cFilAnterior # SRA->RA_FILIAL)       
	fImpCc() 
	fImpFil()            
ElseIf cCcAnt # SRA->RA_CC .And. !Eof()
	fImpCc() 
EndIf

oSection1:Cell("RA_FILIAL"):SetValue(SRA->RA_FILIAL)
oSection1:Cell("RA_CC"):SetValue(SRA->RA_CC)
oSection1:Cell("RA_MAT"):SetValue(SRA->RA_MAT)
oSection1:Cell("RA_NOME"):SetValue(SRA->RA_NOME)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fImpFun     ³ Autor ³Leandro Drumond      ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime Funcionario		 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpFun()

_nTipo:=4

If FTotAcumuladores(4,4) = 0 // Verifica se Acumulador de funcionarios > 0
	Return Nil
EndIf

If lImpRelato
	fImprime(4) // Imprime funcionario
ElseIf lGeraTitulo .And. lAgrupFunc .and. (cSinAna == "A" )
		fGravTit( SRA->RA_FILIAL, SRA->RA_CC, SRA->RA_MAT, aFolIR[4]+a13IR[4] )
EndIf

FZeraAcumuladores(4,4) // Zera Acumuladores do Funcionario 

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fImpCc      ³ Autor ³Leandro Drumond      ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime Centro de Custos	 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpCc()

_nTipo:=3

If FTotAcumuladores(3,3) = 0 // Verifica se Acumulador de Centro de Custo > 0
	Return Nil
EndIf

If nOrdem ==  2 
	If lImpRelato
		fImprime(3) // Imprime Tot Centro de Custo
	ElseIf lGeraTitulo .And. lAgrupCc
		fGravTit( cFilAnterior, cCcAnt, , aFolIR[3]+a13IR[3] )
	EndIf
EndIf

FZeraAcumuladores(3,3) // Zera Acumuladores de Centro de Custo

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fImpFil     ³ Autor ³Leandro Drumond      ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime Total da Filial	 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpFil()

_nTipo:=2

If FTotAcumuladores(2,2) = 0 // Verifica se Acumulador de Filial > 0
	Return Nil
EndIf

If lImpRelato
	fImprime(2) // Imprime total da filial
ElseIf lGeraTitulo .And. lAgrupFil
	fGravTit( cFilAnterior, , , aFolIR[2]+a13IR[2] )
EndIf

FZeraAcumuladores(2,2) // Zera Acumuladores de Filial

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fImpEmp     ³ Autor ³Leandro Drumond      ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime Total da empresa	 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpEmp()

_nTipo:=1

If FTotAcumuladores(1,1) = 0 // Verifica se Acumulador Geral > 0
	Return Nil
EndIf

If lImpRelato
	fImprime(1) // Imprime Acumulador Geral
EndIf

FZeraAcumuladores(1,1) // Zera Acumuladores Geral

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fImprime    ³ Autor ³Leandro Drumond      ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime Totais Gerais nTipo: 								  ³±±
±±³          ³4-Funcionario, 3-Centro de Custo, 2-Filial, 1- Empresa	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImprime(nTipo)

_nTipo:=nTipo   

oSection1:Cell("NFL_LCR_BS"):SetValue(aFolBas[_nTipo])
oSection1:Cell("NFL_LCR_IR"):SetValue(aFolIR[_nTipo])
oSection1:Cell("N13SAL_BS"):SetValue(a13Bas[_nTipo])
oSection1:Cell("N13SAL_IR"):SetValue(a13IR[_nTipo])
oSection1:Cell("NTOTAIS_BS"):SetValue(aFolBas[_nTipo] + a13Bas[_nTipo])
oSection1:Cell("NTOTAIS_IR"):SetValue(aFolIR[_nTipo] + a13IR[_nTipo])
oSection1:Cell("CIDCMPL"):SetValue(cIdCmpl)

If nTipo == 4      
    
    If cSinAna == 'S' 
       	oSection1:Hide()   
    EndIf             

	oSection1:Printline()
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fBuscaMvto³ Autor ³Leandro Drumond        ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa query no movimento para buscar as verbas de IRRF.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fBuscaMvto(cFil,cMatr,cAlias,cCpo,cDatarq,cCpoData,cIndexOrd,cAliasQ)

Local lQuery 		:= .F.
Local cChave		:= ""
Local cCposQuery 	:= "FILIAL|MAT|EMPRESA|TIPO2|PD|VALOR|" + cCpoData
Local cSelect		:= ""
Local aStruSRC  := {}
Local cQuery	:= ""
Local nX

dbSelectArea(cAlias) 

lQuery    	:= 	.T. 
aStruSRC  	:= (cAlias)->(dbStruct())
	
For nX := 1 To Len(aStruSRC)
	If SubStr(aStruSRC[nX,1],4,Len(aStruSRC[nX,1])) $ cCposQuery
		If Empty(cSelect)
			cSelect	+= aStruSRC[nX,1] + " "
		Else
			cSelect	+=  ", " + aStruSRC[nX,1] + " "
		EndIf
	EndIf
Next nX
	
cSelect += ", RF1_IDCMPL, RF1_DESC "
		
cQuery := "SELECT " + cSelect
cQuery += "FROM "+RetSqlName(cAlias)+ " "+cAlias+" "
cQuery += "JOIN "+RetSqlName("RF1")+ " RF1 "
cQuery += "ON "+cCpo+"_IDCMPL = RF1_IDCMPL AND RF1_FILIAL = '" + xFilial('RF1') + "' "
cQuery += "WHERE "+cAlias+"."+cCpo+"_FILIAL='"+cFil+"' AND "
cQuery += cAlias+"."+cCpo+"_MAT='"+cMatr+"' AND "
cQuery += cAlias+"."+cCpo+cCpoData+">='"+dtos(dDataDe)+"' AND "
cQuery += cAlias+"."+cCpo+cCpoData+"<='"+dtos(dDataAte)+"' AND "
cQuery += cAlias+"."+cCpo+"_PD IN('"+aCodFol[974,1]+"','"+aCodFol[975,1]+"','"
cQuery += aCodFol[976,1]+"','"+aCodFol[977,1]+"','"+aCodFol[978,1]+"','"+aCodFol[979,1]+"','"
cQuery += aCodFol[980,1]+"','"+aCodFol[981,1]+"','"+aCodFol[982,1]+"','"+aCodFol[983,1]
cQuery += "') AND "

//-- Somente se estiver buscando informacao no acumulado
If cAlias == "SRD"
	cQuery += "SRD.RD_DATARQ='"+cDatarq+"' AND "
EndIf

cQuery += cAlias+".D_E_L_E_T_=' ' "
cQuery += "ORDER BY "+SqlOrder(cIndexOrd)
	
cQuery := ChangeQuery(cQuery)

//-- Fecha a area corrente
If select(cAliasQ) > 0
	(cAliasQ)->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQ)
	
For nX := 1 To Len(aStruSRC)
	If aStruSRC[nX][2]<>"C"
		TcSetField(cAliasQ,aStruSRC[nX][1],aStruSRC[nX][2],aStruSRC[nX][3],aStruSRC[nX][4])
	EndIf
Next nX			

dbSelectArea(cAliasQ) 

Return(lQuery)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fRadioPerg³ Autor ³ Leandro Drumond       ³ Data ³11/07/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta dialogo para selecao com botoes de radio             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fRadioPerg(nOpcRadio)

Local nOpcAux
Local oRadio
Local oDlg
Local oGroup
Local oFont
Local nReg

nOpcAux   := nOpcRadio
nOpcRadio := 0

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg FROM  094,001 TO 245,280 TITLE OemToAnsi(STR0001) PIXEL

@ 005,005 GROUP oGroup TO 055,135 LABEL OemToAnsi(STR0005) OF oDlg PIXEL	//"Dirf Mensal / Darf"
oGroup:oFont:=oFont
         
@ 020,010 RADIO oRadio VAR nOpcAux	ITEMS OemToAnsi(STR0006),OemToAnsi(STR0007)		;	//
									SIZE 115,010 OF oDlg PIXEL	//"Dirf RRA"###"Darf RRA"

DEFINE SBUTTON FROM 60, 070 TYPE 1 ENABLE OF oDlg ACTION ( nOpcRadio := nOpcAux, oDlg:End() )
DEFINE SBUTTON FROM 60, 105 TYPE 2 ENABLE OF oDlg ACTION ( nOpcRadio := -1,      oDlg:End() )

ACTIVATE MSDIALOG oDlg CENTERED

Return( nOpcRadio )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER930R3 ºAutor  ³Leandro Drumond     º Data ³  11/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER930R3(nRelease)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais (Basicas)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nTregs,nMult,nAnt,nAtu,nCnt,cSav20,cSav7 //Regua
Local cDesc1 	:= STR0001		//"Dirf Mensal"
Local cDesc2 	:= STR0002		//"Ser  impresso de acordo com os parametros solicitados pelo"
Local cDesc3 	:= STR0003		//"usu rio."
Local cString	:="SRA"        				// Alias do arquivo principal (Base)
Local aOrd 		:={STR0008,STR0009,STR0010}	//"Matricula"###"Centro de Custo"###"Nome"
Local lQuery 	:= .F.
Local aRegs		:= {}
Local aHelp		:= {}
Local aHelpE	:= {}
Local aHelpI	:= {}   
Local cHelp		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private(Basicas)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aReturn := {STR0007,1,STR0008, 2, 2, 1, "",1 }	// "Zebrado"###"Administra‡„o"
Private nomeprog:="GPER930"
Private aLinha  := {},nLastKey := 0
Private cPerg   :="GPR930B"
Private nTipImp

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private(Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCRA := {STR0017,STR0018,STR0019}		//"Confirma"###"Repete"###"Abandona"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis Utilizadas na funcao IMPR                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private Titulo
Private AT_PRG  := "GPER930"
Private wCabec0 := 2
Private CONTFL:=1
Private LI:=0
Private nTamanho:="M"
Private nVez:=0
Private nOrdem

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ //Objetos p/ Impresssao Grafica 							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private oFont07, oFont08, oFont10, oFont10n,oFont11,oFont13n, oFont15, oFont21n
Private oPrint

DEFAULT nRelease	:= 3 

Pergunte("GPR930B",.F.) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  Filial  De                               ³
//³ mv_par02        //  Filial  Ate                              ³
//³ mv_par03        //  Centro de Custo De                       ³
//³ mv_par04        //  Centro de Custo Ate                      ³
//³ mv_par05        //  Matricula De                             ³
//³ mv_par06        //  Matricula Ate                            ³
//³ mv_par07        //  Nome De                                  ³
//³ mv_par08        //  Nome Ate                                 ³
//³ mv_par09        //  Data de Pagamento De                     ³
//³ mv_par10        //  Data de Pagamento Ate                    ³
//³ mv_par11        //  Tipo Darf Grafico Darf Zebrado			 ³
//³ mv_par12        //  Data Vencimento                          ³
//³ mv_par13        //  Numero de Referencia                     ³
//³ mv_par14        //  Centralizado ( S/N )                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cTit      := STR0004		//"RELATORIO DIRF MENSAL"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:="GPER930"            //Nome Default do relatorio em Disco
wnrel:=SetPrint(cString,wnrel,cPerg,@cTit,cDesc1,cDesc2,cDesc3,.F.,aOrd,,nTamanho)

If nLastKey = 27
	Return
EndIf

If !(Mv_par11 = 1)
	SetDefault(aReturn,cString)
EndIf

If nLastKey = 27
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nOrdem    := aReturn[8]
cFilDe    := mv_par01
cFilAte   := mv_par02
cCcDe     := mv_par03
cCcAte    := mv_par04
cMatDe    := mv_par05
cMatAte   := mv_par06
cNomDe    := mv_par07
cNomAte   := mv_par08
dDataDe   := mv_par09
dDataAte  := mv_par10
nTipImp   := mv_par11 //1-Darf Gráfico; // 2-Guia Darf Zebrado
dVencto   := mv_par12
cNumRef   := mv_par13
cCentra   := mv_par14
cCodRetDe := "    "
cCodRetAte:= "9999"

oFont07	:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
oFont08	:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)  
oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont10n:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)		//negrito
oFont11	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
oFont15n:= TFont():New("Arial",15,15,,.T.,,,,.T.,.F.)		//negrito
oFont21n:= TFont():New("Arial",21,21,,.T.,,,,.T.,.F.)		//negrito
oPrint 	:= TMSPrinter():New("DARF - Guia de Recolhimento DARF")
oPrint:SetPortrait()                                                

If nTipImp==1  .and. (!oPrint:Setup() .or. !oPrint:isPrinterActive())
	Return
EndIf

RptStatus({|lEnd| R3GR930Imp(1, @lEnd,wnRel,cString,"")},Titulo)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R3GR930Imp³ Autor ³ Leandro Drumond       ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Imposto de Renda                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER930                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function R3GR930Imp(nTipGer,lEnd,WnRel,cString,cAgrupa)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Locais (Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local dDtBusFer
Local lSegRecibo
Local aPeriodo	 := {}
Local aRecnoSRG	 := {}
Local aRecnoSRGD := {}
Local cAcessaSRA := &("{ || " + ChkRH("GPER930","SRA","2") + "}")
Local cAcessaSRC := &("{ || " + ChkRH("GPER930","SRC","2") + "}")
Local cAcessaSRD := &("{ || " + ChkRH("GPER930","SRD","2") + "}")
Local cAcessaSRG := &("{ || " + ChkRH("GPER930","SRG","2") + "}")
Local cAcessaSRH := &("{ || " + ChkRH("GPER930","SRH","2") + "}")
Local cAlias	 := ""
Local cCpo		 := ""
Local cCpoData	 := ""
Local cChave	 := ""
Local cIndexOrd	 := ""
Local cDatarq	 := ""
Local cFolMes    := ""
Local cFilter	 := If ( nTipGer == 2, "", aReturn[7] )  //So recupera o elemento 7 do aReturn se nao for Geracao de Titulo
Local dDataAux	 := ctod("")
Local nx		 := 0
Local cChavePesq := ""
Local aAreaCorrente := {}
Local lGp050Fil	 := ExistBlock( "GP050FIL" )//variavel p/ PE GP050FIL 
Local lPass 	 := .F.
Local lRetPE     := .F.//variavel p/ PE GP050FIL 
Local aPerAtual := {}

//Tratamento de transferencias  
Local aTransf		:= {}
Local cDataRecib	:= ""
Local lExitLoop		:= .F.
Local nTransf		:= 0
Local nLenaTransf	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis Private(Programa)                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cOldRet
Private aInfo     := {}
Private aCodFol   := {}
Private aCodLido  := {}
Private aFolBas[4] , aAdiBas[4] , aFerBas[4] , a13Bas[4]
Private aFolIR[4]  , aAdiIR[4]  , aFerIR[4]  , a13IR[4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaves para faciliar o tratamento do processamento	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private lImpRelato  := (nTipGer == 1)  //Na geracao de titulo fincanceiro vem com valor diferente
Private lGeraTitulo := (nTipGer == 2)
Private lAgrupFil   := (cAgrupa == "1")
Private lAgrupCc    := (cAgrupa $  "2*3")
Private lAgrupFunc  := (cAgrupa == "4")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os periodos onde devem ser lidos os identificadores de³
//³ verbas de folha de pagamento e adiantamento de salario.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MesAno(dDataDe) <> MesAno(dDataAte)
	If lImpRelato
		Aviso(STR0013,STR0014, { "OK"} )	//"Aviso"###"As datas inicial e final devem estar dentro do mesmo mês e ano. Verifique."
	EndIf
	Return nil
EndIf

dbSelectArea("SRA")
dbGoTop()

fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, fGetRotOrdinar() ) //Obtem ano e mes do periodo atual 
If !Empty(aPerAtual)
	cFolMes := aPerAtual[1,5]+aPerAtual[1,4] //RCH_ANO + RCH-MES
EndIf

If MesAno(dDataDe) == cFolMes 
	Aadd(aPeriodo,{"SRC","RC",MesAno(dDataDe),"_DATA",SRC->(IndexKey()),"QSRC"})	   				//-- Mes Atual
	Aadd(aPeriodo,{"SRD","RD",MesAno(dDataDe-Day(dDataDe)),"_DATPGT",SRD->(IndexKey()),"QSRD"})	//-- Mes Anterior
ElseIf MesAno(dDataDe) < cFolMes 
	Aadd(aPeriodo,{"SRD","RD",MesAno(dDataDe),"_DATPGT",SRD->(IndexKey()),"QSRD"})				//-- Mes selecionado no parametro
	dDataAux	:= dDataDe-Day(dDataDe)
	Aadd(aPeriodo,{"SRD","RD",MesAno(dDataAux),"_DATPGT",SRD->(IndexKey()),"QSRD"})				//-- Mes Anterior ao mes selecionado
ElseIf MesAno(dDataDe) > cFolMes 
	Aadd(aPeriodo,{"SRC","RC",MesAno(dDataDe),"_DATA",SRC->(IndexKey()),"QSRC"})					//-- Mes selecionado no parametro
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria indice para Relatorio de IR.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    // Guias DARF Zebrado / Grafico
cArqNtx := CriaTrab(Nil,.F.)
If	nOrdem == 1
	If Empty( cCentra )
		cIndCond := "SRA->RA_FILIAL + SRA->RA_CODRET + SRA->RA_MAT"
		IndRegua("SRA",cArqNtx,cIndCond,,,STR0016)		//"Selecionando Registros..."
		dbSeek(cFilDe,.T.)
		cInicio  := "SRA->RA_FILIAL"
		cFim     := cFilAte
    Else
		cIndCond := "SRA->RA_CODRET+SRA->RA_FILIAL+ SRA->RA_MAT"
		IndRegua("SRA",cArqNtx,cIndCond,,,STR0016)		//"Selecionando Registros..."
		dbSeek(cCodRetDe,.T.)
		cInicio  := "SRA->RA_CODRET+SRA->RA_FILIAL"
		cFim     := cCodRetAte+cFilAte
    EndIf
ElseIf nOrdem == 2
	If Empty( cCentra )
		cIndCond := "SRA->RA_FILIAL + SRA->RA_CODRET + SRA->RA_CC + SRA->RA_MAT"
		IndRegua("SRA",cArqNtx,cIndCond,,,STR0016)		//"Selecionando Registros..."
		dbSeek(cFilDe,.T.)
		cInicio  := "SRA->RA_FILIAL"
		cFim     := cFilAte
	Else
		cIndCond := "SRA->RA_CODRET + SRA->RA_FILIAL + SRA->RA_CC + SRA->RA_MAT"
		IndRegua("SRA",cArqNtx,cIndCond,,,STR0016)		//"Selecionando Registros..."
		dbSeek(cCodRetDe,.T.)
		cInicio  := "SRA->RA_CODRET+SRA->RA_FILIAL"
		cFim     := cCodRetAte+cFilAte
	EndIf
ElseIf nOrdem == 3
	If Empty( cCentra )
		cIndCond := "SRA->RA_FILIAL + SRA->RA_CODRET + SRA->RA_NOME + SRA->RA_MAT"
		IndRegua("SRA",cArqNtx,cIndCond,,,STR0016)		//"Selecionando Registros..."
		dbSeek(cFilDe,.T.)
		cInicio  := "SRA->RA_FILIAL"
		cFim     := cFilAte
	Else
		cIndCond := "SRA->RA_CODRET + SRA->RA_FILIAL + SRA->RA_NOME + SRA->RA_MAT"
		IndRegua("SRA",cArqNtx,cIndCond,,,STR0016)		//"Selecionando Registros..."
		dbSeek(cCodRetDe,.T.)
		cInicio  := "SRA->RA_CODRET+SRA->RA_FILIAL"
		cFim     := cCodRetAte+cFilAte
	EndIf
EndIf

Afill(aFolBas,0)
Afill(a13Bas,0)
Afill(aAdiBas,0)
Afill(aFerBas,0)
Afill(aFolIR,0)
Afill(a13IR,0)
Afill(aAdiIR,0)
Afill(aFerIR,0)

cFilAnterior 	:= Replicate("!", FWGETTAMFILIAL)
cFilQuebra      := Replicate("!", FWGETTAMFILIAL)
cCcAnt  		:= "!!!!!!!!!"

dbSelectArea("SRA")

If lImpRelato
	SetRegua(SRA->(RecCount()))
Else
	ProcRegua(SRA->(RecCount()))
EndIf

cOldRet := "1889"

While !EOF() .And. &cInicio <= cFim

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Movimenta Cursor                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lImpRelato
		IncRegua()
	Else
		IncProc(STR0015) //"Gerando Titulos - Imposto de Renda"
	EndIf

	If lEnd
		If lImpRelato
			@Prow()+1,0 PSAY cCancel
		EndIf
		Exit
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste Filtro da setprint	- LEANDRO					             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Empty(cFilter) .And. ! &(cFilter)
		dbSelectArea("SRA")
		dbSkip()
		Loop
	EndIf	
	
	If SRA->RA_FILIAL # cFilQuebra
		If !FP_CODFOL(@aCodFol)
			Exit
		EndIf
		If !Empty(cCentra)
			fInfo(@aInfo,cCentra)
		Else
			fInfo(@aInfo,SRA->RA_FILIAL)
		EndIf
  		If cFilQuebra # Space(FWGETTAMFILIAL) .And. (Empty(cCentra))
			R3fImpFil()    // Totaliza Filial
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste Parametrizacao do Intervalo de Impressao            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (SRA->RA_NOME < cNomDe)   .Or. (SRA->RA_NOME > cNomAte)  .Or. ;
	   (SRA->RA_MAT < cMatDe)    .Or. (SRA->RA_MAT > cMatAte)   .Or. ;
	   (SRA->RA_CC < cCcDe)      .Or. (SRA->RA_CC > cCcAte)     .Or. ;
	   (SRA->RA_FILIAL < cFilDe) .Or. (SRA->RA_FILIAL > cFilAte)
		R3fTestaTotal()
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste controle de acessos e filiais validas               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
		dbSelectArea( "SRA" )
		dbSkip()
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de Entrada para desprezar funcionario caso retorne .T. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGp050Fil	
		lRetPE := ExecBlock( "GP050FIL", .F., .F. )
		If ( ( ValType(lRetPE) == "L" ) .and. lRetPE )
			SRA->( dbSkip() )
			Loop
		EndIf
	EndIf 

	aCodLido := {}  // Contera as verbas ja lidas - evitara que nao sejam duplicadas
	aRecnoSRG := {}
	aRecnoSRGD:= {}

	For nx := 1 to Len(aPeriodo)
		cAlias		:= aPeriodo[nx,1]
		cCpo		:= aPeriodo[nx,2]
		cDatarq		:= aPeriodo[nx,3]
		cCpoData	:= aPeriodo[nx,4]
		cIndexOrd	:= aPeriodo[nx,5]
		cAliasQ		:= aPeriodo[nx,6]
		//--PRIMEIRO DEVE VERIFICAR SE O iR DO ADIANTAMENTO ENTRA NO PERIODO INFORMADO
		//-- PARA PODER CONSIDERAR A BASE NA PROXIMA PESQUISA.
		dbSelectArea(cAlias)
		dbSetOrder(1)
		If cAlias == "SRC"
			cChave	:= SRA->RA_FILIAL + SRA->RA_MAT + aCodFol[12,1]
		Else
			cChave	:= SRA->RA_FILIAL + SRA->RA_MAT + cDatarq + aCodFol[12,1]
		EndIf
		If	dbSeek(cChave)
			While !Eof() .And. ((cAlias)->&(cCpo+"_FILIAL")+(cAlias)->&(cCpo+"_MAT") == SRA->RA_FILIAL+SRA->RA_MAT);
				 .And. aCodfol[12,1] == (cAlias)->&(cCpo+"_PD") .And. If(cAlias == "SRD",cDatarq == SRD->RD_DATARQ,.T.)
							
				If	(cAlias)->&(cCpo+cCpoData) < dDataDe .OR. (cAlias)->&(cCpo+cCpoData) > dDataAte .or. ;
					If(cAlias == "SRD", !Empty( (cAlias)->RD_EMPRESA ),.F. )
					dbSkip()
					Loop
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Consiste controle de acessos								 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cAlias == "SRC"
					If !Eval(cAcessaSRC)
						dbSkip()
						Loop
					EndIf
				Else
					If !Eval(cAcessaSRD)
						dbSkip()
						Loop
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ IR do Adiantamento											 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (cAlias)->&(cCpo+"_PD") = aCodFol[12,1]
					R3fSoma("ADIIR",(cAlias)->&(cCpo+"_VALOR"),(cAlias)->&(cCpo+"_PD"),(cAlias)->&(cCpo+cCpoData),.T.)
				EndIf
				dbSkip()
			EndDo
		EndIf

    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste controle de acessos								 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lQuery := R3fBuscaMvto(SRA->RA_FILIAL,SRA->RA_MAT,cAlias,cCpo,cDatarq,cCpoData,cIndexOrd,@cAliasQ)
		
		While !Eof() .And. ( (cAliasQ)->&(cCpo+"_FILIAL")+(cAliasQ)->&(cCpo+"_MAT") == SRA->RA_FILIAL+SRA->RA_MAT) .And.;
							If(cAliasQ == "SRD",cDatarq == SRD->RD_DATARQ,.T.)
	    	If (cAliasQ)->&(cCpo+cCpoData) < dDataDe .OR. (cAliasQ)->&(cCpo+cCpoData) > dDataAte .or. ;
				If(cAliasQ == "QSRD" .or. cAliasQ == "SRD", !Empty( (cAliasQ)->RD_EMPRESA), .F. )
		    	dbSkip()
		    	Loop
	    	EndIf
	    	
	    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste controle de acessos								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cAliasQ == "SRC"
				If !Eval(cAcessaSRC)
					dbSkip()
					Loop
				EndIf
			Else
				If !Eval(cAcessaSRD)
					dbSkip()
					Loop
				EndIf
			EndIf
	    	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Folha de Pagamento                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If (cAliasQ)->&(cCpo+"_TIPO2") $ "C*I*G"
				// IR Folha
				If (cAliasQ)->&(cCpo+"_PD") == aCodFol[978,1]
					R3fSoma("FOLIR",(cAliasQ)->&(cCpo+"_VALOR"),(cAliasQ)->&(cCpo+"_PD"),(cAliasQ)->&(cCpo+cCpoData),.T.)
				EndIf
				
				// Base IR Folha
				If (cAliasQ)->&(cCpo+"_PD") == aCodFol[974,1] //.And. aFolIr[4] > 0
					R3fSoma("FOLBAS",(cAliasQ)->&(cCpo+"_VALOR"),(cAliasQ)->&(cCpo+"_PD"),(cAliasQ)->&(cCpo+cCpoData),.T.)
				EndIf
			EndIf

			lPass := .F.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ 13§ Salario                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// IR 13 Salario
			If (cAliasQ)->&(cCpo+"_PD") == aCodFol[983,1] .And. (cAliasQ)->&(cCpo+"_TIPO2") # "R"
				R3fSoma("13IR",(cAliasQ)->&(cCpo+"_VALOR"),(cAliasQ)->&(cCpo+"_PD"),(cAliasQ)->&(cCpo+cCpoData),.T.)
			EndIf
			// Base IR 13 Salario
			If (cAliasQ)->&(cCpo+"_PD") == aCodFol[979,1] .And. (cAliasQ)->&(cCpo+"_TIPO2") # "R"// .And. a13Ir[4] > 0
				R3fSoma("13BAS",(cAliasQ)->&(cCpo+"_VALOR"),(cAliasQ)->&(cCpo+"_PD"),(cAliasQ)->&(cCpo+cCpoData),.T.)
			EndIf
			dbSkip()
		EndDo
	Next nx

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura no SRG Funcionarios Demitidos                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SRG" )
	If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT )
		While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT == SRG->RG_FILIAL + SRG->RG_MAT
			If SRG->RG_EFETIVA = "S" .And. (SRG->RG_DATAHOM >= dDataDe .And. SRG->RG_DATAHOM <= dDataAte )
				aAdd(aRecnoSRG,{SRG->RG_FILIAL+SRG->RG_MAT,SRG->RG_DTGERAR,SRG->RG_DATAHOM,SRG->RG_DATADEM,SRG->(RECNO())})
				dbSelectArea( "SRR" )
				If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + "R" + DtoS(SRG->RG_DTGERAR))
					While !Eof() .And. SRA->RA_FILIAL + SRA->RA_MAT + "R" + DtoC(SRG->RG_DTGERAR) == ;
									    SRR->RR_FILIAL + SRR->RR_MAT + "R" + DtoC(SRR->RR_DATA)
											 
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Consiste controle de acessos								 ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !Eval(cAcessaSRG)
							dbSkip()
							Loop
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Folha de Pagamento                                           ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						// IR Folha
						If SRR->RR_PD == aCodFol[978,1]
							R3fSoma("FOLIR",SRR->RR_VALOR,SRR->RR_PD,SRG->RG_DATAHOM,.T.)
						EndIf
						// Base IR Folha
						If SRR->RR_PD == aCodFol[974,1]// .And. aFolIr[4] > 0
							R3fSoma("FOLBAS",SRR->RR_VALOR,SRR->RR_PD,SRG->RG_DATAHOM,.T.)
						EndIf                                                             
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ 13§ Salario                                                  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						// IR 13 Salario
						If SRR->RR_PD == aCodFol[983,1]
							R3fSoma("13IR",SRR->RR_VALOR,SRR->RR_PD,SRG->RG_DATAHOM,.T.)
						EndIf
						// Base IR 13 Salario
						If SRR->RR_PD == aCodFol[979,1]// .And.a13Ir[4] > 0
							R3fSoma("13BAS",SRR->RR_VALOR,SRR->RR_PD,SRG->RG_DATAHOM,.T.)
						EndIf
						dbSkip()
					EndDo
				EndIf
			EndIf
			dbSelectArea("SRG")
			dbSkip()
		EndDo
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as rescisoes que devem ter o IR abatido.                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nx := 1 to Len(aRecnoSRG)
		dbSelectArea("SRG")
		dbgoto(aRecnoSRG[nx,5])
		SRG->(dbskip(-1))
		If	SRG->RG_FILIAL+SRG->RG_MAT == aRecnoSRG[nx,1] .And. ;
			MesAno(SRG->RG_DTGERAR) == MesAno(aRecnoSRG[nx,2]) .And. ;
			MesAno(SRG->RG_DTGERAR) == MesAno(SRG->RG_DATADEM) .And. ;
			!SRG->(BOF())
			aAdd(aRecnoSRGD,{SRG->RG_FILIAL+SRG->RG_MAT,SRG->RG_DTGERAR,SRG->RG_DATAHOM,SRG->RG_DATADEM,SRG->(RECNO())})
		EndIf
	next nx
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta os valores de IR de rescisoes complementares dentro do mes³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SRR" )
	For nx := 1 to Len(aRecnoSRGD)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Folha de Pagamento                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// IR Folha
		If dbSeek( aRecnoSRGD[nx,1] + "R" + DtoS(aRecnoSRGD[nx,2]) + aCodFol[978,1] )// .And. aFolIr[4] > 0
			R3fSoma("FOLIR",SRR->RR_VALOR*(-1),SRR->RR_PD,SRG->RG_DATAHOM,.T.)
		EndIf
		// Base IR Folha
		If dbSeek( aRecnoSRGD[nx,1] + "R" + DtoS(aRecnoSRGD[nx,2]) + aCodFol[974,1] ) //.And. aFolBas[4] > 0
			R3fSoma("FOLBAS",SRR->RR_VALOR*(-1),SRR->RR_PD,SRG->RG_DATAHOM,.T.)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ 13§ Salario                                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// IR 13 Salario
		If dbSeek( aRecnoSRGD[nx,1] + "R" + DtoS(aRecnoSRGD[nx,2]) + aCodFol[983,1] )// .And. a13Ir[4] > 0
			R3fSoma("13IR",SRR->RR_VALOR*(-1),SRR->RR_PD,SRG->RG_DATAHOM,.T.)
		EndIf
		// Base IR 13 Salario
		If dbSeek( aRecnoSRGD[nx,1] + "R" + DtoS(aRecnoSRGD[nx,2]) + aCodFol[979,1] )// .And. a13Bas[4] > 0
			R3fSoma("13BAS",SRR->RR_VALOR*(-1),SRR->RR_PD,SRG->RG_DATAHOM,.T.)
		EndIf
	Next nx
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 13§ Salario - podera ser pago em  qq mes do ano              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dDataAux	:= dDataDe
	If StrZero(YEAR(dDataAux),4) == SUBSTR(cFolmes,1,4)
		cAlias		:= "SRC"
		cCpo		:= "RC"
		cDatarq		:= MesAno(dDataAux)
		cCpoData	:= "_DATA"
		cChave		:= SRA->RA_FILIAL + SRA->RA_MAT
	Else 
		cAlias		:= "SRD"
		cCpo		:= "RD"
		cDatarq		:= str(Year(dDataAux),4)+"13"
		cCpoData	:= "_DATPGT"
		cChave		:= SRA->RA_FILIAL + SRA->RA_MAT + cDatarq
	EndIf
	
	dbSelectArea(cAlias)
	If dbSeek( cChave )
		While !Eof() .And. ((cAlias)->&(cCpo+"_FILIAL") + (cAlias)->&(cCpo+"_MAT") == SRA->RA_FILIAL + SRA->RA_MAT) ;
			   .And. If(cAlias == "SRD",cDatarq == SRD->RD_DATARQ,.T.)
			If (cAlias)->&(cCpo+cCpoData) < dDataDe .Or. (cAlias)->&(cCpo+cCpoData) > dDataAte
				dbSkip()
				Loop
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste controle de acessos								 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cAlias == "SRC"
				If !Eval(cAcessaSRC)
					dbSkip()
					Loop
				EndIf
			Else
				If !Eval(cAcessaSRD)
					dbSkip()
					Loop
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ 13§ Salario                                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// IR 13 Salario
			If (cAlias)->&(cCpo+"_PD") == aCodFol[983,1]
				R3fSoma("13IR",(cAlias)->&(cCpo+"_VALOR"),(cAlias)->&(cCpo+"_PD"),(cAlias)->&(cCpo+cCpoData),.T.)
			EndIf
			// Base IR 13 Salario
			If (cAlias)->&(cCpo+"_PD") == aCodFol[979,1] //.And. A13ir[4] > 0
				R3fSoma("13BAS",(cAlias)->&(cCpo+"_VALOR"),(cAlias)->&(cCpo+"_PD"),(cAlias)->&(cCpo+cCpoData),.T.)
			EndIf
			dbSkip()
		Enddo
	EndIf

	dbSelectArea("SRA")
	If	R3FTotAcumuladores(4,4) == 0
		R3fTestaTotal()
		Loop
	EndIf
	R3fImpFun()
	R3fTestaTotal()
EndDo

dbSelectArea("SRA")
Set Filter To
RetIndex( "SRA" )
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna o alias padrao                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lQuery
	If Select("QSRC") > 0
		QSRC->(dbCloseArea())
	EndIf
	If Select("QSRD") > 0
		QSRD->(dbCloseArea())
	EndIf
EndIf		

If nTipImp==2  // Guia Darf Zebrado
	fErase( cArqNtx + OrdBagExt() )
ElseIf nTipImp==1  // Guia Darf Grafica
	oPrint:Preview() // Visualiza impressao grafica antes de imprimir
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino do relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lImpRelato .And. nTipImp # 1		//Se nao for Grafico
	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		Commit
		ourspool(wnrel)
	EndIf
	MS_FLUSH()
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R3fSoma      ³ Autor ³Leandro Drumond     ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                          								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R3fSoma(cVetor,nVal,cCodVerba,dDataPagto,lSoma)
Local cChaveBusca := cCodVerba + MesAno(dDataPagto)
Local nFor

lSoma := If(lSoma == Nil,.F.,lSoma)

If Ascan( aCodLido, cChaveBusca ) == 0 .Or. lSoma
	cVet := "a" + cVetor
	For nFor = 1 To 4
		&(cVet)[nFor] += nVal
	Next nFor
	AADD(aCodLido, cChaveBusca )
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R3FZeraAcumuladores³Autor ³Leandro Drumond³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                        	 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R3FZeraAcumuladores(nDe,nAte)

Local nFor
For nFor = nDe TO nAte
	aFolBas[nFor] := 0
	a13Bas[nFor]  := 0
	aAdiBas[nFor] := 0
	aFerBas[nFor] := 0
	aFolIR[nFor]  := 0
	a13IR[nFor]   := 0
	aAdiIR[nFor]  := 0
	aFerIR[nFor]  := 0
Next nFor
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R3FTotAcumuladores ³Autor ³Leandro Drumond³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                        	 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R3FTotAcumuladores(nDe,nAte)
Local nTotal := 0
Local nFor
For nFor = nDe To nAte
	nTotal += aFolBas[nFor]
	nTotal += a13Bas[nFor]
	nTotal += aFolIR[nFor]
	nTotal += a13IR[nFor]
Next nFor

Return nTotal

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R3fTestaTotal³ Autor ³Leandro Drumond     ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa quebras         	 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R3fTestaTotal()
If !Empty(cCentra)  //Darf Zebrado ##Darf Grafica
   cFilAnterior := cCentra
Else
   cFilAnterior := SRA->RA_FILIAL
EndIf

cFilQuebra := SRA->RA_FILIAL
cCcAnt     := SRA->RA_CC

dbSelectArea("SRA")
dbSkip()

If Eof() .Or. &cInicio > cFim
	R3fImpCc()
	R3fImpFil()
	R3fImpEmp()
ElseIf (cFilAnterior # SRA->RA_FILIAL .And. Empty(cCentra))
	R3fImpCc()
	R3fImpFil()
ElseIf cCcAnt # SRA->RA_CC .And. !Eof()
	R3fImpCc()
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R3fImpFun   ³ Autor ³Leandro Drumond      ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime funcionario     	 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R3fImpFun()
If R3FTotAcumuladores(4,4) = 0 // Verifica se Acumulador de funcionarios > 0
	Return Nil
EndIf

R3FZeraAcumuladores(4,4) // Zera Acumuladores do Funcionario

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R3fImpCc    ³ Autor ³Leandro Drumond      ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime Centro de Custos	 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R3fImpCc()
If R3FTotAcumuladores(3,3) = 0 // Verifica se Acumulador de Centro de Custo > 0
	Return Nil
EndIf

R3FZeraAcumuladores(3,3) // Zera Acumuladores de Centro de Custo

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R3fImpFil   ³ Autor ³Leandro Drumond      ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime Filial          	 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R3fImpFil()
Local lImpDarf	 := ExistBlock( "IMPDARF",.F.,.T. )//variavel p/ PE "IMPDARF"

If R3FTotAcumuladores(2,2) = 0 // Verifica se Acumulador de Filial > 0
	Return Nil
EndIf

//Altera nTipImp para utilização no rdmake
If nTipImp == 1
	nTipImp := 3
EndIf

if lImpDarf
	ExecBlock("IMPDARF",.F.,.F.)
else
	GPER989()
endif
//Retorna valor original do nTipInf
If nTipImp == 3
	nTipImp := 1
EndIf

R3FZeraAcumuladores(2,2) // Zera Acumuladores de Filial

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R3fImpEmp   ³ Autor ³Leandro Drumond      ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime Total da empresa	 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R3fImpEmp()
If R3FTotAcumuladores(1,1) = 0 // Verifica se Acumulador Geral > 0
	Return Nil
EndIf

R3FZeraAcumuladores(1,1) // Zera Acumuladores Geral

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³R3fBuscaMvto³ Autor ³Leandro Drumond      ³ Data ³ 11.07.12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa query no movimento para buscar as verbas de IRRF.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function R3fBuscaMvto(cFil,cMatr,cAlias,cCpo,cDatarq,cCpoData,cIndexOrd,cAliasQ)

Local lQuery 	:= .F.
Local cChave	:= ""
Local aStruSRC  := {}
Local cQuery	:= ""
Local nX

dbSelectArea(cAlias) 

lQuery    	:= 	.T. 
aStruSRC  	:= (cAlias)->(dbStruct())
cQuery 		:= "SELECT * "

cQuery += "FROM "+RetSqlName(cAlias)+ " "+cAlias+" "
cQuery += "WHERE "+cAlias+"."+cCpo+"_FILIAL='"+cFil+"' AND "
cQuery += cAlias+"."+cCpo+"_MAT='"+cMatr+"' AND "
cQuery += cAlias+"."+cCpo+cCpoData+">='"+dtos(dDataDe)+"' AND "
cQuery += cAlias+"."+cCpo+cCpoData+"<='"+dtos(dDataAte)+"' AND "
cQuery += cAlias+"."+cCpo+"_PD IN('"+aCodFol[974,1]+"','"+aCodFol[975,1]+"','"
cQuery += aCodFol[976,1]+"','"+aCodFol[977,1]+"','"+aCodFol[978,1]+"','"+aCodFol[979,1]+"','"
cQuery += aCodFol[980,1]+"','"+aCodFol[981,1]+"','"+aCodFol[982,1]+"','"+aCodFol[983,1]
cQuery += "') AND "

//-- Somente se estiver buscando informacao no acumulado
If cAlias == "SRD"
	cQuery += "SRD.RD_DATARQ='"+cDatarq+"' AND "
EndIf

cQuery += cAlias+".D_E_L_E_T_=' ' "
cQuery += "ORDER BY "+SqlOrder(cIndexOrd)
	
cQuery := ChangeQuery(cQuery)

//-- Fecha a area corrente
If select(cAliasQ) > 0
	(cAliasQ)->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQ)
	
For nX := 1 To Len(aStruSRC)
	If aStruSRC[nX][2]<>"C"
		TcSetField(cAliasQ,aStruSRC[nX][1],aStruSRC[nX][2],aStruSRC[nX][3],aStruSRC[nX][4])
	EndIf
Next nX			
dbSelectArea(cAliasQ) 

Return(lQuery)
