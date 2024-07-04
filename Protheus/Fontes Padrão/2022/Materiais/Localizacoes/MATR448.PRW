#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATR448.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR448  ³ Autor ³  Gsantacruz           ³ Data ³ 30/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reporte de Validación de Pedimento                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MATR448()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function  MATR448 ()

Local   oReport
Local   aGetArea   :=   GetArea()
Local   lSalir     :=   .f.
Private NomeProg   :=   'MATR448'

Private NumPed     :=  RSC->RSC_NUMPED
Private cPedFil    :=   RSC->RSC_FILIAL

If !TRepInUse()	//verifica se a opção relatórios personalizáveis está disponível
	MSGSTOP(OEMTOANSI(STR0001) )//"Para usar este inform debe tener MP8 R4 en adelante!"
	lSalir:=.t.
endif
if lSalir
	RestArea(aGetArea)
	Return
endif

oReport := ReportDef()
oReport:PrintDialog()
RestArea(aGetArea)

Return ( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportDef   Autor ³ FMonroy               ³ Data ³31/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Def. Reporte de Validación del pedimento                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  MATR448                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

Local aArea      := GetArea()

Local oReport,    oSection1,  oSection2,  oSection3,  oSection4,   oSection5
Local oSection6,  oSection7,  oSection8,  oSection9,  oSection10,  oSection11
Local oSection12, oSection13, oSection14, oSection15, oSection16, oSection17

Local cAliasRSC  :=   GetNextAlias()	// Creo mi tabla temporal
Local cAliasRSA  :=   GetNextAlias()	// Creo mi tabla temporal
Local cAliasRSI  :=  GetNextAlias()	// Creo mi tabla temporal


Private cTitulo	:=OEMTOANSI(STR0002) //"Pedimento"

cTitulo := Trim(cTitulo)
oReport:=TReport():New(NomeProg,OemToAnsi(cTitulo), /*NomeProg */  ,{|oReport| PrintReport(oReport,cAliasRSC,cAliasRSA,cAliasRSI)})
oReport:nColSpace:= 0.75
oReport:nFontBody	:= 4 // Define o tamanho da fonte.
oReport:nLineHeight	:= 30 // Define a altura da linha.
oReport:CFONTBODY:="COURIER NEW"
oReport:Setlandscape(.T.)//Pag Horizontal
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao:-Titulos de cada sección --------------------- ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:= TRSection():New(oReport,STR0023,,/* aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/) //"Titulo"
oSection1:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
TRCell():New(oSection1,"TIT",,,,80)//Titulo de cada sección
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 2da.     Secao: ---Datos Generales (RSC)--------------------  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2:= TRSection():New(oReport,STR0024,{"RSC"},/* aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/) //"Datos Generales"
oSection2:SetHeaderSection(.t.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao
oSection2:SetLineStyle(.T.)   //Pone titulo del campo y aun lado el y valor
OSection2:SetCharSeparator(":")

TRCell():New(oSection2,"PEDIMENT",,,,80)//Pedimento
TRCell():New(oSection2,"CLVPEDIMENT",,,,80)//Clave Pedimento
TRCell():New(oSection2,"RSC_REGIM"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_REGIM")	,TamSx3("RSC_REGIM")[1])
TRCell():New(oSection2,"RSC_DESORI"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_DESORI")	,TamSx3("RSC_DESORI")[1])
TRCell():New(oSection2,"RSC_TC"		,cAliasRSC ,  ,  PesqPict("RSC","RSC_TC")		,TamSx3("RSC_TC")[1])
TRCell():New(oSection2,"RSC_PESO"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_PESO")		,TamSx3("RSC_PESO")[1])
TRCell():New(oSection2,"RSC_ADUANA"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_ADUANA")	,TamSx3("RSC_ADUANA")[1])
TRCell():New(oSection2,"RSC_TRANSE"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_TRANSE")	,TamSx3("RSC_TRANSE")[1])
TRCell():New(oSection2,"RSC_TRANSA"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_TRANSA")	,TamSx3("RSC_TRANSA")[1])
TRCell():New(oSection2,"RSC_TRANSS"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_TRANSS")	,TamSx3("RSC_TRANSS")[1])
TRCell():New(oSection2,"RSC_PEDORI"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_PEDORI")	,TamSx3("RSC_PEDORI")[1])
TRCell():New(oSection2,"RSC_FECEXT"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_FECEXT")	,TamSx3("RSC_FECEXT")[1])
TRCell():New(oSection2,"RSC_VALIDA"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_VALIDA")	,TamSx3("RSC_VALIDA")[1])
TRCell():New(oSection2,"RSC_FECENT"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_FECENT")	,TamSx3("RSC_FECENT")[1])
TRCell():New(oSection2,"RSC_FCHPGO"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_FCHPGO")	,TamSx3("RSC_FCHPGO")[1]) 
TRCell():New(oSection2,"RSC_FACINC"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_FACINC")	,TamSx3("RSC_FACINC")[1])
TRCell():New(oSection2,"RSC_FV"		,cAliasRSC ,  ,  PesqPict("RSC","RSC_FV")	,TamSx3("RSC_FV")[1])
TRCell():New(oSection2,"RSC_IVA"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_IVA")	,TamSx3("RSC_IVA")[1] )
TRCell():New(oSection2,"RSC_AGENTE"	,cAliasRSC ,  ,  PesqPict("RSC","RSC_AGENTE")	,TamSx3("RSC_AGENTE")[1]+TamSx3("DB9_NOME")[1]+1) 
TRCell():New(oSection2,"RSC_OBSERV"	,cAliasRSC ,  ,  "!@",60) 
 
oSection2:Cell("RSC_PESO"):SetCellBreak()
oSection2:Cell("RSC_TRANSS"):SetCellBreak()
oSection2:Cell("RSC_FECEXT"):SetCellBreak()
oSection2:Cell("RSC_FCHPGO"):SetCellBreak()
oSection2:Cell("RSC_IVA"):SetCellBreak()
oSection2:Cell("RSC_AGENTE"):SetCellBreak()
oSection2:Cell("PEDIMENT"):SetCellBreak()
oSection2:Cell("CLVPEDIMENT"):SetCellBreak()
oSection2:Cell("PEDIMENT"):Disable()
oSection2:Cell("CLVPEDIMENT"):Disable()
oSection2:nLinesBefore:=0
oSection1:nLinesBefore:=0
//ÚÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 3.     Secao: ------Valores         (RSJ)    ----------------- ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection3:= TRSection():New(oReport,STR0025,{"RSJ"},/* aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/) //"Valores"
oSection3:SetLineStyle(.f.)   //Pone titulo del campo y aun lado el y valor
oSection3:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection3:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao

TRCell():New(oSection3,"VAL",		"RSJ"	,	,"!@"							,20)
TRCell():New(oSection3,"VAL_IMP",	"RSJ"	,	,PesqPict("RSJ","RSJ_VALADU")	,TamSx3("RSJ_VALADU")[1])
//ÚÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 4da.     Secao: ------Resumén de Impuestos   ----------------- ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection4:= TRSection():New(oReport,STR0026,{"RSL"},/* aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/) //"Resumén de Impuestos"
oSection4:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection4:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection4:SetHeaderPage(.F.)	//Exibe Cabecalho


TRCell():New(oSection4,"RSL_CODIMP"	,"RSL",		,PesqPict("RSL","RSL_CODIMP")	,TamSx3("RSL_CODIMP")[1])
TRCell():New(oSection4,"RSL_DESC"	,"RSL",		,PesqPict("RSL","RSL_DESC")		,TamSx3("RSL_DESC")[1])
TRCell():New(oSection4,"RSL_IMPORT"	,"RSL",		,PesqPict("RSL","RSL_IMPORT")	,TamSx3("RSL_IMPORT")[1])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 5ta.     Secao: ---Transportista----------------------------  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection5:= TRSection():New(oReport,STR0027,{"RSO"},/* aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/) //"Transportista"
oSection5:SetLineStyle(.T.)//Pone titulo del campo y aun lado el y valor
oSection5:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection5:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao

TRCell():New(oSection5,"RSO_TRANS"	,"RSO" ,  ,  PesqPict("RSO","RSO_TRANS")	,TamSx3("RSO_TRANS")[1])
TRCell():New(oSection5,"RSO_IDENT"	,"RSO" ,  ,  PesqPict("RSO","RSO_IDENT")	,TamSx3("RSO_IDENT")[1])
TRCell():New(oSection5,"RSO_NUMCON"	,"RSO" ,  ,  PesqPict("RSO","RSO_NUMCON")	,TamSx3("RSO_NUMCON")[1])
TRCell():New(oSection5,"RSO_TIPCON"	,"RSO" ,  ,  PesqPict("RSO","RSO_TIPCON")	,TamSx3("RSO_TIPCON")[1])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 6ta.     Secao: ---Calculo del Costo------------------------  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection6:= TRSection():New(oReport,STR0028,{"RSI"},/*aOrdem */ ,/*Campos do SX3*/,/*Campos do SIX*/) //"Calculos del Costo"
oSection6:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection6:SetHeaderSection(.t.)	//Exibe Cabecalho da Secao
oSection6:SetHeaderPage(.f.)	//Exibe Cabecalho

TRCell():New(oSection6,"RSG_FRACAR"	,cAliasRSI,		,PesqPict("RSG","RSG_FRACAR")	,TamSx3("RSG_FRACAR")[1])
TRCell():New(oSection6,"RSH_TASA"	,cAliasRSI,		,PesqPict("RSH","RSH_TASA")		,TamSx3("RSH_TASA")[1])
TRCell():New(oSection6,"RSI_PROD"	,cAliasRSI,		,PesqPict("RSI","RSI_PROD")		,TamSx3("RSI_PROD")[1])
TRCell():New(oSection6,"RSI_DESC"	,cAliasRSI,		,PesqPict("RSI","RSI_DESC")		,TamSx3("RSI_DESC")[1])
TRCell():New(oSection6,"RSI_UMC"	,cAliasRSI,		,PesqPict("RSI","RSI_UMC")		,TamSx3("RSI_UMC")[1])
TRCell():New(oSection6,"RSI_CANT"	,cAliasRSI,		,PesqPict("RSI","RSI_CANT")		,TamSx3("RSI_CANT")[1])
TRCell():New(oSection6,"RSI_COSTO"	,cAliasRSI,		,PesqPict("RSI","RSI_COSTO")	,TamSx3("RSI_COSTO")[1])
TRCell():New(oSection6,"RSI_IMPOR"	,cAliasRSI,		,PesqPict("RSI","RSI_IMPOR")	,TamSx3("RSI_IMPOR")[1])
TRCell():New(oSection6,"RSI_INCREM"	,cAliasRSI,		,PesqPict("RSI","RSI_INCREM")	,TamSx3("RSI_INCREM")[1])
TRCell():New(oSection6,"RSI_CIF"	,cAliasRSI,		,PesqPict("RSI","RSI_CIF")		,TamSx3("RSI_CIF")[1])
TRCell():New(oSection6,"RSI_IMPUES"	,cAliasRSI,		,PesqPict("RSI","RSI_IMPUES")	,TamSx3("RSI_IMPUES")[1])
TRCell():New(oSection6,"RSI_GASTOS"	,cAliasRSI,		,PesqPict("RSI","RSI_GASTOS")	,TamSx3("RSI_GASTOS")[1])
TRCell():New(oSection6,"RSI_CANT2"	,cAliasRSI,		,"999,999,999,999.99"			,20)
TRCell():New(oSection6,"RSI_COSUNI"	,cAliasRSI,		,PesqPict("RSI","RSI_COSUNI")	,TamSx3("RSI_COSUNI")[1])

oSection6:Cell("RSI_CANT"):SetCellBreak()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 7ma.     Secao: ---Incrementables---------------------------  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection7:= TRSection():New(oReport,STR0021,{"RSK"},/*aOrdem */ ,/*Campos do SX3*/,/*Campos do SIX*/) //"Incrementables"
oSection7:SetHeaderSection(.t.)	//Exibe Cabecalho da Secao
oSection7:SetHeaderPage(.f.)	//Exibe Cabecalho

TRCell():New(oSection7,"RSK_FOLIO"	,"RSK",		,PesqPict("RSK","RSK_FOLIO")	,TamSx3("RSK_FOLIO")[1])
TRCell():New(oSection7,"RSK_PROV"	,"RSK",		,PesqPict("RSK","RSK_PROV")		,TamSx3("RSK_PROV")[1])
TRCell():New(oSection7,"RSK_TDA"	,"RSK",		,PesqPict("RSK","RSK_TDA")		,TamSx3("RSK_TDA")[1])
TRCell():New(oSection7,"A2_NOME"	,     ,		,PesqPict("SA2","A2_NOME")		,TamSx3("A2_NOME")[1])
TRCell():New(oSection7,"RSK_TIPO"	,"RSK",		,PesqPict("RSK","RSK_TIPO")		,TamSx3("RSK_TIPO")[1])
TRCell():New(oSection7,"RSK_VALMON"	,"RSK",		,PesqPict("RSK","RSK_VALMON")	,TamSx3("RSK_VALMON")[1])
TRCell():New(oSection7,"RSK_MONEDA"	,"RSK",		,PesqPict("RSK","RSK_MONEDA")	,TamSx3("RSK_MONEDA")[1])
TRCell():New(oSection7,"RSK_VALOR"	,"RSK",		,PesqPict("RSK","RSK_VALOR")	,TamSx3("RSK_VALOR")[1])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 8va.     Secao: --Pedimentos Facturas-----------------------   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection8:= TRSection():New(oReport,STR0029,{"RSE"},/*aOrdem */ ,/*Campos do SX3*/,/*Campos do SIX*/) //"Pedimentos Facturas"
oSection8:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection8:SetHeaderPage(.f.)	//Exibe Cabecalho

TRCell():New(oSection8,"RSE_FACT"	,cAliasRSC, ,PesqPict("RSE","RSE_FACT")		,TamSx3("RSE_FACT")[1])
TRCell():New(oSection8,"RSE_SERIE"	,cAliasRSC, ,PesqPict("RSE","RSE_SERIE")	,TamSx3("RSE_SERIE")[1])
TRCell():New(oSection8,"RSE_TIPO"	,cAliasRSC, ,PesqPict("RSE","RSE_TIPO")		,TamSx3("RSE_TIPO")[1])
TRCell():New(oSection8,"RSE_EMISIO"	,cAliasRSC, ,PesqPict("RSE","RSE_EMISIO")	,TamSx3("RSE_EMISIO")[1])
TRCell():New(oSection8,"RSE_INCOTE"	,cAliasRSC, ,PesqPict("RSE","RSE_INCOTE")	,TamSx3("RSE_INCOTE")[1])
TRCell():New(oSection8,"RSE_PROV"	,cAliasRSC, ,PesqPict("RSE","RSE_PROV")		,TamSx3("RSE_PROV")[1])
TRCell():New(oSection8,"RSE_TDA"	,cAliasRSC, ,PesqPict("RSE","RSE_TDA")		,TamSx3("RSE_TDA")[1])
TRCell():New(oSection8,"A2_NOME"	,         , ,PesqPict("SA2","A2_NOME")		,TamSx3("A2_NOME")[1])
TRCell():New(oSection8,"RSE_CONPGO"	,cAliasRSC, ,PesqPict("RSE","RSE_CONPGO")	,TamSx3("RSE_CONPGO")[1])
TRCell():New(oSection8,"RSE_MONED"	,cAliasRSC, ,PesqPict("RSE","RSE_MONED")	,TamSx3("RSE_MONED")[1])
TRCell():New(oSection8,"RSE_TC"		,cAliasRSC, ,PesqPict("RSE","RSE_TC")		,TamSx3("RSE_TC")[1])
TRCell():New(oSection8,"RSE_TASA"	,cAliasRSC, ,PesqPict("RSE","RSE_TASA")		,TamSx3("RSE_TASA")[1])
TRCell():New(oSection8,"RSE_DESCTO"	,cAliasRSC, ,PesqPict("RSE","RSE_DESCTO")	,TamSx3("RSE_DESCTO")[1])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 9na.     Secao: --Pedimentos Items por Facturas (RSF)----------³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection9:= TRSection():New(oSection8,STR0029,{"RSF"},/*aOrdem */ ,/*Campos do SX3*/,/*Campos do SIX*/) //"Pedimentos Facturas"
oSection9:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection9:SetHeaderPage(.f.)	//Exibe Cabecalho
oSection9:SetLeftMargin(5)

TRCell():New(oSection9,"RSF_ITEM",		cAliasRSC, ,PesqPict("RSF","RSF_ITEM")		,TamSx3("RSF_ITEM")[1])
TRCell():New(oSection9,"RSF_TIPO",		cAliasRSC, ,PesqPict("RSF","RSF_TIPO")		,TamSx3("RSF_TIPO")[1])
TRCell():New(oSection9,"RSF_PRODUC",	cAliasRSC, ,PesqPict("RSF","RSF_PRODUC")	,TamSx3("RSF_PRODUC")[1])
TRCell():New(oSection9,"RSF_DESC",		cAliasRSC, ,PesqPict("RSF","RSF_DESC")		,TamSx3("RSF_DESC")[1])
TRCell():New(oSection9,"RSF_UM",		cAliasRSC, ,PesqPict("RSF","RSF_UM")		,TamSx3("RSF_UM")[1])
TRCell():New(oSection9,"RSF_CANT",		cAliasRSC, ,PesqPict("RSF","RSF_CANT")		,TamSx3("RSF_CANT")[1])
TRCell():New(oSection9,"RSF_PRECIO",	cAliasRSC, ,PesqPict("RSF","RSF_PRECIO")	,TamSx3("RSF_PRECIO")[1])
TRCell():New(oSection9,"RSF_TOTAL",		cAliasRSC, ,PesqPict("RSF","RSF_TOTAL")		,TamSx3("RSF_TOTAL")[1])
TRCell():New(oSection9,"RSF_UM2",		cAliasRSC, ,PesqPict("RSF","RSF_UM2")		,TamSx3("RSF_UM2")[1])
TRCell():New(oSection9,"RSF_CANUM2",	cAliasRSC, ,PesqPict("RSF","RSF_CANUM2")	,TamSx3("RSF_CANUM2")[1])
TRCell():New(oSection9,"RSF_ALMACE",	cAliasRSC, ,PesqPict("RSF","RSF_ALMACE")	,TamSx3("RSF_ALMACE")[1])
TRCell():New(oSection9,"RSF_TES",		cAliasRSC, ,PesqPict("RSF","RSF_TES")		,TamSx3("RSF_TES")[1])
TRCell():New(oSection9,"RSF_CONTA",		cAliasRSC, ,PesqPict("RSF","RSF_CONTA")		,TamSx3("RSF_CONTA")[1])
TRCell():New(oSection9,"RSF_CC",		cAliasRSC, ,PesqPict("RSF","RSF_CC")		,TamSx3("RSF_CC")[1])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 10ma.     Secao: --Pedimentos Items datos de Importación(RSG)---³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection10:= TRSection():New(oSection8,STR0030,{"RSG"},/*aOrdem */ ,/*Campos do SX3*/,/*Campos do SIX*/)  //"Items-Datos de Importación"
oSection10:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection10:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection10:SetHeaderPage(.f.)	//Exibe Cabecalho
oSection10:SetLeftMargin(10)
TRCell():New(oSection10,"RSG_SECC"		,cAliasRSC, ,PesqPict("RSG","RSG_SECC")		,TamSx3("RSG_SECC")[1])
TRCell():New(oSection10,"RSG_FRACAR"	,cAliasRSC, ,PesqPict("RSG","RSG_FRACAR")	,TamSx3("RSG_FRACAR")[1])
TRCell():New(oSection10,"RSG_VINCU"		,cAliasRSC, ,PesqPict("RSG","RSG_VINCU")	,TamSx3("RSG_VINCU")[1])
TRCell():New(oSection10,"RSG_METVAL"	,cAliasRSC, ,PesqPict("RSG","RSG_METVAL")	,TamSx3("RSG_METVAL")[1])
TRCell():New(oSection10,"RSG_UMC"		,cAliasRSC, ,PesqPict("RSG","RSG_UMC")		,TamSx3("RSG_UMC")[1])
TRCell():New(oSection10,"RSG_CANUMC"	,cAliasRSC, ,PesqPict("RSG","RSG_CANUMC")	,TamSx3("RSG_CANUMC")[1])
TRCell():New(oSection10,"RSG_PAIVTA"	,cAliasRSC, ,PesqPict("RSG","RSG_PAIVTA")	,TamSx3("RSG_PAIVTA")[1])
TRCell():New(oSection10,"RSG_PAIORI"	,cAliasRSC, ,PesqPict("RSG","RSG_PAIORI")	,TamSx3("RSG_PAIORI")[1])
TRCell():New(oSection10,"RSG_DOLARE"	,cAliasRSC, ,PesqPict("RSG","RSG_DOLARE")	,TamSx3("RSG_DOLARE")[1])
TRCell():New(oSection10,"RSG_VALCOM"	,cAliasRSC, ,PesqPict("RSG","RSG_VALCOM")	,TamSx3("RSG_VALCOM")[1])
TRCell():New(oSection10,"RSG_VALADU"	,cAliasRSC, ,PesqPict("RSG","RSG_VALADU")	,TamSx3("RSG_VALADU")[1])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 11va.     Secao: --Pedimentos Impuestos por Items   (RSH)------³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection11:= TRSection():New(oSection8,STR0030,{"RSH"},/*aOrdem */ ,/*Campos do SX3*/,/*Campos do SIX*/) //"Items-Datos de Importación"
oSection11:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection11:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection11:SetHeaderPage(.f.)	//Exibe Cabecalho
oSection11:SetLeftMargin(15)

TRCell():New(oSection11,"RSH_IMPUES",	cAliasRSC	, ,PesqPict("RSH","RSH_IMPUES")	,TamSx3("RSH_IMPUES")[1])
TRCell():New(oSection11,"RSA_DESC",					, ,PesqPict("RSA","RSA_DESC")	,TamSx3("RSA_DESC")[1])
TRCell():New(oSection11,"RSH_TIPTAS",	cAliasRSC	, ,PesqPict("RSH","RSH_TIPTAS")	,TamSx3("RSH_TIPTAS")[1])
TRCell():New(oSection11,"RSH_TASA",		cAliasRSC	, ,PesqPict("RSH","RSH_TASA")	,TamSx3("RSH_TASA")[1])
TRCell():New(oSection11,"RSH_IMPPAG",	cAliasRSC	, ,PesqPict("RSH","RSH_IMPPAG")	,TamSx3("RSH_IMPPAG")[1])
TRCell():New(oSection11,"RSH_PORIVA",	cAliasRSC	, ,PesqPict("RSH","RSH_PORIVA")	,TamSx3("RSH_PORIVA")[1])
TRCell():New(oSection11,"RSH_IMPIVA",	cAliasRSC	, ,PesqPict("RSH","RSH_IMPIVA")	,TamSx3("RSH_IMPIVA")[1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 12.     Secao: --Pedimentos Facturas-----------------------   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection12:= TRSection():New(oReport,STR0029,,/*aOrdem */ ,/*Campos do SX3*/,/*Campos do SIX*/) //"Pedimentos Facturas"
oSection12:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection12:SetHeaderPage(.f.)	//Exibe Cabecalho

TRCell():New(oSection12,"RSE_FACT"	,	,	,	,TamSx3("RSE_FACT")[1])
TRCell():New(oSection12,"RSE_SERIE"	,	,	,	,TamSx3("RSE_SERIE")[1])
TRCell():New(oSection12,"RSE_TIPO"	,	,	,	,TamSx3("RSE_TIPO")[1])
TRCell():New(oSection12,"RSE_EMISIO",	,	,	,TamSx3("RSE_EMISIO")[1])
TRCell():New(oSection12,"RSE_INCOTE",	,	,	,TamSx3("RSE_INCOTE")[1])
TRCell():New(oSection12,"RSE_PROV"	,	,	,	,TamSx3("RSE_PROV")[1])
TRCell():New(oSection12,"RSE_TDA"	,	,	,	,TamSx3("RSE_TDA")[1])
TRCell():New(oSection12,"A2_NOME"	,	,	,	,TamSx3("A2_NOME")[1])
TRCell():New(oSection12,"RSE_CONPGO",	,	,	,TamSx3("RSE_CONPGO")[1])
TRCell():New(oSection12,"RSE_MONED"	,	,	,	,TamSx3("RSE_MONED")[1])
TRCell():New(oSection12,"RSE_TC"	,	,	,	,TamSx3("RSE_TC")[1])
TRCell():New(oSection12,"RSE_TASA"	,	,	,	,TamSx3("RSE_TASA")[1])
TRCell():New(oSection12,"RSE_DESCTO",	,	,	,TamSx3("RSE_DESCTO")[1])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 13ma.     Secao: --Pedimentos Items por Facturas (RSF)---------³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection13:= TRSection():New(oSection12,STR0029,,/*aOrdem */ ,/*Campos do SX3*/,/*Campos do SIX*/) //"Pedimentos Facturas"
oSection13:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection13:SetHeaderPage(.f.)	//Exibe Cabecalho
oSection13:SetLeftMargin(5)

TRCell():New(oSection13,"RSF_ITEM"	,	,	,	,TamSx3("RSF_ITEM")[1])
TRCell():New(oSection13,"RSF_TIPO"	,	,	,	,TamSx3("RSF_TIPO")[1])
TRCell():New(oSection13,"RSF_PRODUC",	,	,	,TamSx3("RSF_PRODUC")[1])
TRCell():New(oSection13,"RSF_DESC"	,	,	,	,TamSx3("RSF_DESC")[1])
TRCell():New(oSection13,"RSF_UM"	,	,	,	,TamSx3("RSF_UM")[1])
TRCell():New(oSection13,"RSF_CANT"	,	,	,	,TamSx3("RSF_CANT")[1])
TRCell():New(oSection13,"RSF_PRECIO",	,	,	,TamSx3("RSF_PRECIO")[1])
TRCell():New(oSection13,"RSF_TOTAL"	,	,	,	,TamSx3("RSF_TOTAL")[1])
TRCell():New(oSection13,"RSF_UM2"	,	,	,	,TamSx3("RSF_UM2")[1])
TRCell():New(oSection13,"RSF_CANUM2",	,	,	,TamSx3("RSF_CANUM2")[1])
TRCell():New(oSection13,"RSF_ALMACE",	,	,	,TamSx3("RSF_ALMACE")[1])
TRCell():New(oSection13,"RSF_TES"	,	,	,	,TamSx3("RSF_TES")[1])
TRCell():New(oSection13,"RSF_CONTA"	,	,	,	,TamSx3("RSF_CONTA")[1])
TRCell():New(oSection13,"RSF_CC"	,	,	,	,TamSx3("RSF_CC")[1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 14va.     Secao: --Pedimentos Items datos de Importación(RSG)---³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection14:= TRSection():New(oSection12,STR0030,,/*aOrdem */ ,/*Campos do SX3*/,/*Campos do SIX*/) //"Items-Datos de Importación"
//oSection14:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection14:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection14:SetHeaderPage(.f.)	//Exibe Cabecalho
oSection14:SetLeftMargin(10)


TRCell():New(oSection14,"RSG_SECC"	,	,	,	,TamSx3("RSG_SECC")[1])
TRCell():New(oSection14,"RSG_FRACAR",	,	,	,TamSx3("RSG_FRACAR")[1])
TRCell():New(oSection14,"RSG_VINCU"	,	,	,	,TamSx3("RSG_VINCU")[1])
TRCell():New(oSection14,"RSG_METVAL",	,	,	,TamSx3("RSG_METVAL")[1])
TRCell():New(oSection14,"RSG_UMC"	,	,	,	,TamSx3("RSG_UMC")[1])
TRCell():New(oSection14,"RSG_CANUMC",	,	,	,TamSx3("RSG_CANUMC")[1])
TRCell():New(oSection14,"RSG_PAIVTA",	,	,	,TamSx3("RSG_PAIVTA")[1])
TRCell():New(oSection14,"RSG_PAIORI",	,	,	,TamSx3("RSG_PAIORI")[1])
TRCell():New(oSection14,"RSG_DOLARE",	,	,	,TamSx3("RSG_DOLARE")[1])
TRCell():New(oSection14,"RSG_VALCOM",	,	,	,TamSx3("RSG_VALCOM")[1])
TRCell():New(oSection14,"RSG_VALADU",	,	,	,TamSx3("RSG_VALADU")[1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 15va.     Secao: --Pedimentos Impuestos por Items    (RSH)------³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oSection15:= TRSection():New(oSection12,STR0030,,/*aOrdem */ ,/*Campos do SX3*/,/*Campos do SIX*/) //"Items-Datos de Importación"
//oSection12:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection15:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection15:SetHeaderPage(.f.)	//Exibe Cabecalho
oSection15:SetLeftMargin(15)

TRCell():New(oSection15,"RSH_IMPUES",	,	,	,TamSx3("RSH_IMPUES")[1])
TRCell():New(oSection15,"RSA_DESC"	,	,	,	,TamSx3("RSA_DESC")[1])
TRCell():New(oSection15,"RSH_TIPTAS",	,	,	,TamSx3("RSH_TIPTAS")[1])
TRCell():New(oSection15,"RSH_TASA"	,	,	,	,TamSx3("RSH_TASA")[1])
TRCell():New(oSection15,"RSH_IMPPAG",	,	,	,TamSx3("RSH_IMPPAG")[1])
TRCell():New(oSection15,"RSH_PORIVA",	,	,	,TamSx3("RSH_PORIVA")[1])
TRCell():New(oSection15,"RSH_IMPIVA",	,	,	,TamSx3("RSH_IMPIVA")[1])

oSection12:nLinesBefore:=0
oSection13:nLinesBefore:=0
oSection14:nLinesBefore:=0
oSection15:nLinesBefore:=0
oSection8:nLinesBefore:=0
oSection9:nLinesBefore:=0
oSection10:nLinesBefore:=0
oSection11:nLinesBefore:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 16va. 1O  Secao: --Resumen de Gastos                (RSJ)------³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection16:= TRSection():New(oReport,STR0031,,/*aOrdem */ ,/*Campos do SX3*/,/*Campos do SIX*/) //"Resumén de Gastos"
oSection16:SetHeaderSection(.t.)	//Exibe Cabecalho da Secao
oSection16:SetHeaderPage(.f.)	//Exibe Cabecalho

TRCell():New(oSection16,"GASTOS"  , , ,  ,15)
TRCell():New(oSection16,"EXTR"    , , ,  ,15)
TRCell():New(oSection16,"NAC"     , , ,  ,15)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 17. 11    Secao ---Tasa a nivel pedimento-------------------  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection17:= TRSection():New(oReport,STR0033,{"RSA"},/* aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/) //"Tasa a nivel Pedimento"
oSection17:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection17:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection17:SetHeaderPage(.F.)	//Exibe Cabecalho

TRCell():New(oSection17,"RSA_DESC"		,cAliasRSA,  ,  PesqPict("RSA","RSA_DESC")		,TamSx3("RSA_DESC")[1])
TRCell():New(oSection17,"RSA_TIPO"		,cAliasRSA,  ,  PesqPict("RSA","RSA_TIPO")		,TamSx3("RSA_TIPO")[1])
TRCell():New(oSection17,"RSA_TASIMP"	,cAliasRSA,  ,  PesqPict("RSA","RSA_TASIMP")	,TamSx3("RSA_TASIMP")[1])

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PrintReport Autor ³ FMonroy               ³ Data ³07/06/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³   Impresión del Informe                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³    PrintReport(oExp)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  MATR448                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport,cAliasRSC,cAliasRSA,cAliasRSI)

Local oSection1		:=	oReport:Section(1)
Local oSection2		:=	oReport:Section(2)
Local oSection3		:=	oReport:Section(3)
Local oSection8		:=	oReport:Section(8)
Local oSection9		:=	oReport:Section(8):Section(1)
Local oSection10	:=	oReport:Section(8):Section(2)
Local oSection11	:=	oReport:Section(8):Section(3)
Local cFiltro		:=	""
Local cRSEItem		:=	""
Local cRSFItem		:=	""
Local cRSGSecc		:=	""
Local cTitle		:=	""
Local nValAdu		:=	0
Local nValCom		:=	0
Local nPorIva		:=	0
Local nImpIva		:=	0




	cSelect:= "% RSE_FACT, RSE_SERIE,RSE_TIPO,RSE_EMISIO,RSE_INCOTE,RSE_PROV,RSE_TDA,RSE_CONPGO,RSE_MONED,RSE_TASA, RSE_TC, RSE_DESCTO,RSE_ITEM, "
	cSelect+= "  RSC_NUMPED,RSC_REGIM,RSC_DESORI, RSC_TC,RSC_PESO,RSC_ADUANA, RSC_TRANSE, RSC_TRANSA, RSC_TRANSS, RSC_VALIDA, RSC_FECENT, RSC_FCHPGO, RSC_AGENTE, RSC_OBSERV,RSC_FV ,RSC_IVA, RSC_AGENTE, RSC_PEDORI,"
	cSelect+= " RSF_ITEM,RSF_TIPO,RSF_PRODUC,RSF_UM,RSF_CANT,RSF_PRECIO,RSF_TOTAL, RSF_UM2, RSF_CANUM2, RSF_ALMACE,RSF_TES,RSF_CONTA,RSF_CC, "//RSF_FACCOM,RSF_PROCOM, "
	cSelect+= " RSG_SECC, RSG_FRACAR, RSG_VINCU, RSG_METVAL, RSG_UMC, RSG_CANUMC,  RSG_PAIVTA, RSG_PAIORI,RSG_DOLARE, RSG_VALCOM, RSG_VALADU, RSG_IMPIVA,RSG_PORIVA,"
	cSelect+= " RSH_IMPUES, RSH_TIPTAS,RSH_TASA, RSH_IMPPAG,RSH_PORIVA,RSH_IMPIVA,RSF.RSF_ITEDOC,RSC_FECEXT,RSC_FACINC ,RSC_CVEPED%"

	cFiltro:=   "%  RSC.RSC_NUMPED ='"      + Numped + "' "
	cFiltro+=   "   AND RSC.RSC_FILIAL ='"  + cPedFil+ "'  %"

oSection2:BeginQuery()

	BeginSql alias cAliasRSC

		SELECT	%exp:cSelect%

		FROM %table:RSC% RSC

		LEFT OUTER JOIN  %table:RSE% RSE
		ON 	   RSC.RSC_NUMPED  =  RSE.RSE_NUMPED
        AND    RSC.RSC_FILIAL  =  RSE.RSE_FILIAL
		AND RSE.%notDel%

		LEFT OUTER JOIN %table:RSF% RSF
		ON 	   RSF.RSF_NUMPED  =  RSE.RSE_NUMPED
		AND    RSF.RSF_ITEDOC  =  RSE.RSE_ITEM
		AND    RSF.RSF_FILIAL  =  RSE.RSE_FILIAL
		AND RSF.%notDel%
		LEFT OUTER JOIN %table:RSG% RSG
		ON     RSG.RSG_NUMPED  =  RSF.RSF_NUMPED
		AND    RSG.RSG_ITEM    =  RSF.RSF_ITEM
		AND    RSG.RSG_FILIAL  =  RSF.RSF_FILIAL
		AND    RSG.RSG_FACT    =  RSE.RSE_FACT 
		AND    RSG.RSG_SERIE   =  RSE.RSE_SERIE
		AND    RSG.RSG_PROV    =  RSE.RSE_PROV 
		AND    RSG.RSG_TDA     =  RSE.RSE_TDA
		AND RSG.%notDel%
		LEFT OUTER JOIN %table:RSH% RSH
		ON     RSH.RSH_NUMPED  =  RSG.RSG_NUMPED
		AND    RSH.RSH_ITEM    =  RSG.RSG_ITEM
		AND    RSH.RSH_SECC    =  RSG.RSG_SECC
		AND    RSH.RSH_FILIAL  =  RSG.RSG_FILIAL
		AND    RSH.RSH_FACT    =  RSE.RSE_FACT 
		AND    RSH.RSH_SERIE   =  RSE.RSE_SERIE
		AND    RSH.RSH_PROV    =  RSE.RSE_PROV 
		AND    RSH.RSH_TDA     =  RSE.RSE_TDA
	   AND RSH.%notDel%
		WHERE
	       %exp:cFiltro%
			AND RSC.%notDel%
			
			
			
		    

		ORDER BY RSC.RSC_NUMPED ,RSE.RSE_FACT,RSE.RSE_SERIE,RSE.RSE_PROV,RSE.RSE_TDA,RSF.RSF_ITEDOC

	EndSql

oSection2:EndQuery()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitle 	:= If( AllTrim( oReport:Title())==AllTrim( cTitle ), OemToansi( cTitulo ),oReport:Title() )
oReport:SetTitle( cTitle+" : "+ Numped+Space(1)+TitSX3("RSC_CVEPED")[1]+" : "+ AllTrim(( cAliasRSC )->RSC_CVEPED))//Pedimento: 999999999

	dbSelectArea( cAliasRSC )
	count to nTotal
	oReport:SetMeter(nTotal)

	(cAliasRSC)->(DbGoTop())
	If (cAliasRSC)->(!Eof())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 1 :-Titulos de cada sección ---------------------Datos Generales  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection1:Init()                 //01234567890123456789012345678901234567890123456789
		oSection1:Cell( "TIT" ):SetValue(STR0003 )//"-- Datos Generales -------------------------------"
	    oSection1:Printline()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 2 :-Pedimento -----------------------------------                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		impsec2(oReport,cAliasRSC)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 1 :-Titulos de cada sección ---------------------                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                                     //01234567890123456789012345678901234567890123456789
		oSection1:Cell( "TIT" ):SetValue(replicate("-",10))
	    oSection1:Printline()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 3 :-Valores      -----------------------------------              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fImpSec3VAL(oReport)
		oReport:skipline()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 1 :-Titulos de cada sección ---------------------                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                                     //01234567890123456789012345678901234567890123456789
		oSection1:Cell( "TIT" ):SetValue(STR0022)//"-- Tasa a Nivel pedimento –-------------------------------------------"
	    oSection1:Printline()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 17 :-Valores      -----------------------------------              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fImpSec17(oReport,cAliasRSA)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 1 :-Titulos de cada sección ------------- Impuestos por Pedimento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                                     //01234567890123456789012345678901234567890123456789
		oSection1:Cell( "TIT" ):SetValue( STR0005)// "-- Resumén de Impuestos -----------------------"
	    oSection1:Printline()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 4 :-Resumén de Impuestos   -----------------------------------    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fImpSec4(oReport)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 1 :-Titulos de cada sección ---------------------Transportista    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                                     //01234567890123456789012345678901234567890123456789
		oSection1:Cell( "TIT" ):SetValue(STR0006)//"-- Transportista ---------------------------------"
	    oSection1:Printline()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 5 :-Transportita -----------------------------------              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fImpSec5(oReport)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 1 :-Titulos de cada sección ------------------Calculo del Costo   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                                     //01234567890123456789012345678901234567890123456789
		oSection1:Cell( "TIT" ):SetValue(STR0007)//#DEFINE STR0009 "-- Calculos del Costo ----------------------------"
	    oSection1:Printline()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 6 :-Calculo del Costo-------------------------------              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fImpSec6(oReport,cAliasRSI)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 1 :-Titulos de cada sección ------------------DESGLOSE            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                 //01234567890123456789012345678901234567890123456789
		oSection1:Cell( "TIT" ):SetValue(STR0008)//"-- DESGLOSE---------------------------------"
	    oSection1:Printline()
		oSection1:Cell( "TIT" ):SetValue(STR0009)//"-- Incrementables---------------------------------"
		oSection1:Printline()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 7 :-Incrementables ---------------------------------              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fImpSec7(oReport)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 1 :-Titulos de cada sección ------------- Facturas                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	                                     //01234567890123456789012345678901234567890123456789
		oSection1:Cell( "TIT" ):SetValue( STR0010)//"-- Facturas --------------------------------------"
	    oSection1:Printline()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  ----------Detalle de Facturación -----------------------------------    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ImptTit(oReport)
		oreport:fatLine()//ThinLine()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 8 :-Facturas RSE           -----------------------------------    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection8:Init()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 9 :-Items por Facturas RSF -----------------------------------    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection9:Init()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 10 :-Items Datos de Importación RSG ---------------------------    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection10:Init()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 11 :-Impuestos por Item RSH -----------------------------------    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection11:Init()
		
		While (cAliasRSC)->(!Eof())
			cRSEItem := (cAliasRSC)->RSE_ITEM
			oSection8:CELL("A2_NOME"):SETVALUE(POSICIONE( "SA2" , 1 , xFilial("SA2") + ( cAliasRSC )->RSE_PROV+( cAliasRSC )->RSE_TDA, "A2_NOME" ))
			oSection8:PRintLine()
			nValAdu		:=	0
			nValCom		:=	0
			nPorIva		:=	0
			nImpIva		:=	0
			While (cAliasRSC)->( !Eof() ) .And. cRSEItem == ( cAliasRSC )->RSE_ITEM
				cRSFItem:=( cAliasRSC )->RSF_ITEM
				oSection9:cell("RSF_DESC"):SETVALUE(POSICIONE( "SB1" , 1 , xFilial("SB1") + ( cAliasRSC )->RSF_PRODUC, "B1_DESC" )) //GSA
				oSection9:PrintLine()
				While (cAliasRSC)->( !Eof() ) .And. cRSEItem == ( cAliasRSC )->RSE_ITEM .And. cRSFItem==( cAliasRSC )->RSF_ITEM
					cRSGSec:= ( cAliasRSC )->RSG_SECC
					nValAdu		+=	( cAliasRSC )->RSG_VALADU
					nValCom		+=	( cAliasRSC )->RSG_VALCOM
					nPorIva		+=	( cAliasRSC )->RSG_PORIVA
					nImpIva		+=	( cAliasRSC )->RSG_IMPIVA
					oSection10:PrintLine()
					While (cAliasRSC)->( !Eof() ) .And. cRSEItem == ( cAliasRSC )->RSE_ITEM .And. cRSFItem==( cAliasRSC )->RSF_ITEM .And. cRSGSec== ( cAliasRSC )->RSG_SECC
						oSection11:cell("RSA_DESC"):SETVALUE(POSICIONE( "RSA" , 1 , xFilial("RSA") + ( cAliasRSC )->RSH_IMPUES, "RSA_DESC" ))
						oSection11:PrintLine()
						(cAliasRSC)->(dbSkip())
						oReport:IncMeter()   //regla de avance
					EndDo //Datos Import
				 EndDo //mismo item RSF
			Enddo //Fin de Archivo
			//imprime totales
			oReport:skipline()
			PrintTot(nValAdu,nValCom,nPorIva,nImpIva,oReport)
			oReport:skipline()
			
		EndDo //Fin  de archivo
		oSection8:Finish()
		oSection9:Finish()
		oSection10:Finish()
		oSection11:Finish()
		   								   //01234567890123456789012345678901234567890123456789
		oSection1:Cell( "TIT" ):SetValue(STR0011)//"--Resumen de Gastos------------------------------------------------------"
	    oSection1:Printline()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Secao 16 :-Pedimentos Items por facturas (RSF)  --------------------    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fImpSec16( oReport )
		
	EndIf //If fin de archivo

(cAliasRSC)->(dbCloseArea())

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao     fImpSec5  ºAutor  ³FMonroy             º Data ³  11/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Imprime la seccion 3 --Transportista                        ³±±
±±³          ³ del informe de Pedimentos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   fImpSec3( oExp )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³   oExp: Objeto TReport                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³   MATR448                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpSec5(oReport)
Local  oSection5  :=  oReport:Section( 5 )

DbSelectArea( "RSO" )
RSO-> ( dbSetOrder( 1 ) )
If RSO->(dbseek( cPedFil + NumPed ))

	oSection5:Init()
	oSection5:Printline()
	oSection5:Finish()

EndIf
dbCloseArea( )
Return ( Nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fImpSec4  ºAutor  ³FMonroy             º Data ³  11/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Imprime la seccion 4 --Resumén de Impuestos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   fImpSec4( oExp )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³   oExp: Objeto TReport                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³   MATR448                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpSec4( oReport )
Local  oSection4  :=  oReport:Section( 4 )
Local nImppag	  :=	0

DbSelectArea( "RSL" )

RSL->( dbSetOrder( 1 ) )
If RSL->(dbseek( xFilial( "RSL" ) + NumPed   ))

	oSection4:Init()
	While  RSL->( !Eof() ).AND. (alltrim(RSL->RSL_FILIAL) + alltrim(RSL->RSL_NUMPED) == alltrim(xFilial( "RSL" )) + alltrim(NumPed)  )
		oSection4:Printline()
		nImppag+=RSL->RSL_IMPORT
		RSL->( DbSkip() )
	EndDo
	oSection4:cell("RSL_CODIMP"):hide()
	oSection4:cell("RSL_DESC"):SetValue(STR0012)//"Total -->"
	oSection4:cell("RSL_IMPORT"):setvalue(nImppag)
	oSection4:PrintLine()
	oSection4:Finish()
EndIf
dbCloseArea( )
Return ( Nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ImptTit   ºAutor  ³FMonroy             º Data ³  11/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Imprime la seccion 9101112--Titulos                         ³±±
±±³          ³ del informe de Pedimentos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   ImptTit( oExp )                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³   oExp: Objeto TReport                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³   MATR448                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImptTit(oReport)

Local oSection12   := oReport:Section(9)
Local oSection13  := oReport:Section(9):Section(1)
Local oSection14  := oReport:Section(9):Section(2)
Local oSection15  := oReport:Section(9):Section(3)
oSection12:init()
oSection13:init()
oSection14:init()
oSection15:init()
DbSelectArea( "RSE" )

oSection12:cell("RSE_FACT"):SetPicture("!@")
oSection12:cell("RSE_SERIE"):SetPicture("!@")
oSection12:cell("RSE_TIPO"):SetPicture("!@")
oSection12:cell("RSE_EMISIO"):SetPicture("!@")
oSection12:cell("RSE_INCOTE"):SetPicture("!@")
oSection12:cell("RSE_PROV"):SetPicture("!@")
oSection12:cell("RSE_TDA"):SetPicture("!@")
oSection12:CELL("A2_NOME"):SetPicture("!@")
oSection12:cell("RSE_CONPGO"):SetPicture("!@")
oSection12:cell("RSE_MONED"):SetPicture("!@")
oSection12:cell("RSE_TC"):SetPicture("!@")
oSection12:cell("RSE_TASA"):SetPicture("!@")
oSection12:cell("RSE_DESCTO"):SetPicture("!@")

oSection12:cell("RSE_FACT"):SetValue( TitSX3( "RSE_FACT" )[1])
oSection12:cell("RSE_SERIE"):SetValue( TitSX3("RSE_SERIE")[1])
oSection12:cell("RSE_TIPO"):SetValue( TitSX3("RSE_TIPO")[1])
oSection12:cell("RSE_EMISIO"):SetValue( TitSX3("RSE_EMISIO")[1])
oSection12:cell("RSE_INCOTE"):SetValue( TitSX3("RSE_INCOTE")[1])
oSection12:cell("RSE_PROV"):SetValue( TitSX3("RSE_PROV")[1])
oSection12:cell("RSE_TDA"):SetValue( TitSX3("RSE_TDA")[1])
oSection12:CELL("A2_NOME"):SETVALUE(TitSX3("A2_NOME")[1])
oSection12:cell("RSE_CONPGO"):SetValue( TitSX3("RSE_CONPGO")[1])
oSection12:cell("RSE_MONED"):SetValue( TitSX3("RSE_MONED")[1])
oSection12:cell("RSE_TC"):SetValue( TitSX3("RSE_TC")[1])
oSection12:cell("RSE_TASA"):SetValue( TitSX3("RSE_TASA")[1])
oSection12:cell("RSE_DESCTO"):SetValue( TitSX3("RSE_DESCTO")[1])


oSection13:cell("RSF_ITEM"):SetPicture("!@")
oSection13:cell("RSF_TIPO"):SetPicture("!@")
oSection13:cell("RSF_PRODUC"):SetPicture("!@")
oSection13:cell("RSF_DESC"  ):SetPicture("!@")
oSection13:cell("RSF_UM"    ):SetPicture("!@")
oSection13:cell("RSF_CANT"  ):SetPicture("!@")
oSection13:cell("RSF_PRECIO"):SetPicture("!@")
oSection13:cell("RSF_TOTAL" ):SetPicture("!@")
oSection13:cell("RSF_UM2"):SetPicture("!@")
oSection13:cell("RSF_CANUM2"):SetPicture("!@")
oSection13:cell("RSF_ALMACE"):SetPicture("!@")
oSection13:cell("RSF_TES"   ):SetPicture("!@")
oSection13:cell("RSF_CONTA" ):SetPicture("!@")
oSection13:cell("RSF_CC"    ):SetPicture("!@")

oSection13:cell("RSF_ITEM"):SetValue( TitSX3("RSF_ITEM")[1])
oSection13:cell("RSF_TIPO"):SetValue( TitSX3("RSF_TIPO")[1])
oSection13:cell("RSF_PRODUC"):SetValue( TitSX3("RSF_PRODUC")[1])
oSection13:cell("RSF_DESC"  ):SetValue( TitSX3("RSF_DESC")[1])
oSection13:cell("RSF_UM"    ):SetValue( TitSX3("RSF_UM")[1])
oSection13:cell("RSF_CANT"  ):SetValue( TitSX3("RSF_CANT")[1])
oSection13:cell("RSF_PRECIO"):SetValue( TitSX3("RSF_PRECIO")[1])
oSection13:cell("RSF_TOTAL" ):SetValue( TitSX3("RSF_TOTAL")[1])
oSection13:cell("RSF_UM2"):SetValue( TitSX3("RSF_UM2")[1])
oSection13:cell("RSF_CANUM2"):SetValue( TitSX3("RSF_CANUM2")[1])
oSection13:cell("RSF_ALMACE"):SetValue( TitSX3("RSF_ALMACE")[1])
oSection13:cell("RSF_TES"   ):SetValue( TitSX3("RSF_TES")[1])
oSection13:cell("RSF_CONTA" ):SetValue( TitSX3("RSF_CONTA")[1])
oSection13:cell("RSF_CC"    ):SetValue( TitSX3("RSF_CC")[1])

oSection14:cell("RSG_SECC"   ):SetPicture("!@")
oSection14:cell("RSG_FRACAR" ):SetPicture("!@")
oSection14:cell("RSG_VINCU"  ):SetPicture("!@")
oSection14:cell("RSG_METVAL" ):SetPicture("!@")
oSection14:cell("RSG_UMC"    ):SetPicture("!@")
oSection14:cell("RSG_CANUMC" ):SetPicture("!@")
oSection14:cell("RSG_PAIVTA" ):SetPicture("!@")
oSection14:cell("RSG_PAIORI" ):SetPicture("!@")
oSection14:cell("RSG_DOLARE" ):SetPicture("!@")
oSection14:cell("RSG_VALCOM" ):SetPicture("!@")
oSection14:cell("RSG_VALADU" ):SetPicture("!@")

oSection14:cell("RSG_SECC"   ):SetValue( TitSX3("RSG_SECC")[1])
oSection14:cell("RSG_FRACAR" ):SetValue( TitSX3("RSG_FRACAR")[1])
oSection14:cell("RSG_VINCU"  ):SetValue( TitSX3("RSG_VINCU")[1])
oSection14:cell("RSG_METVAL" ):SetValue( TitSX3("RSG_METVAL")[1])
oSection14:cell("RSG_UMC"    ):SetValue( TitSX3("RSG_UMC")[1])
oSection14:cell("RSG_CANUMC" ):SetValue( TitSX3("RSG_CANUMC")[1])
oSection14:cell("RSG_PAIVTA" ):SetValue( TitSX3("RSG_PAIVTA")[1])
oSection14:cell("RSG_PAIORI" ):SetValue( TitSX3("RSG_PAIORI")[1])
oSection14:cell("RSG_DOLARE" ):SetValue( TitSX3("RSG_DOLARE")[1])
oSection14:cell("RSG_VALCOM" ):SetValue( TitSX3("RSG_VALCOM")[1])
oSection14:cell("RSG_VALADU" ):SetValue( TitSX3("RSG_VALADU")[1])

oSection15:cell("RSH_IMPUES"  ):SetPicture("!@")
oSection15:cell("RSA_DESC"    ):SetPicture("!@")
oSection15:cell("RSH_TIPTAS"  ):SetPicture("!@")
oSection15:cell("RSH_TASA"    ):SetPicture("!@")
oSection15:cell("RSH_IMPPAG"  ):SetPicture("!@")
oSection15:cell("RSH_IMPIVA"  ):SetPicture("!@")
oSection15:cell("RSH_PORIVA"  ):SetPicture("!@")

oSection15:cell("RSH_IMPUES"  ):SetValue( TitSX3("RSH_IMPUES")[1])
oSection15:cell("RSA_DESC"    ):SetValue( TitSX3("RSA_DESC")[1])
oSection15:cell("RSH_TIPTAS"  ):SetValue( TitSX3("RSH_TIPTAS")[1])
oSection15:cell("RSH_TASA"    ):SetValue( TitSX3("RSH_TASA")[1])
oSection15:cell("RSH_IMPPAG"  ):SetValue( TitSX3("RSH_IMPPAG")[1])
oSection15:cell("RSH_IMPIVA"  ):SetValue( TitSX3("RSH_IMPIVA")[1])
oSection15:cell("RSH_PORIVA"  ):SetValue( TitSX3("RSH_PORIVA")[1])

oReport:skipline()
oSection12:Printline()
oSection13:Printline()
oSection14:Printline()
oSection15:Printline()


oSection12:Finish()
oSection13:Finish()
oSection14:Finish()
oSection15:Finish()

dbCloseArea( )
Return ( Nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³fImpSec16 ºAutor  ³FMonroy             º Data ³  11/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Imprime la seccion 13--Resumén de Gastos                    ³±±
±±³          ³ del informe de Pedimentos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   fImpSec16( oExp )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³   oExp: Objeto TReport                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³   MATR448                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpSec16( oReport )
Local  oSection16  :=  oReport:Section( 10 )
DbSelectArea( "RSJ" )

RSJ->( dbSetOrder( 1 ) )

If RSJ->(dbseek( xFilial( "RSJ" ) + NumPed  ))
	oSection16:Init()

	oSection16:cell("GASTOS"):SeTTitle(STR0013)// "Gastos"
	oSection16:cell("EXTR"):SeTTitle(STR0014)//"Extranjeros"
	oSection16:cell("NAC"):SeTTitle(STR0015)//"Nacionales"

	oSection16:cell("GASTOS"):SetPicture("!@")
	oSection16:cell("EXTR"):SetPicture("999,999,999,999.99")
	oSection16:cell("NAC"):SetPicture("999,999,999,999.99")

	oSection16:cell("GASTOS"):SeTValue(STR0016)//"Fletes"
	oSection16:cell("EXTR"):SeTValue(RSJ->RSJ_FLETEE)
	oSection16:cell("NAC"):SeTValue(RSJ->RSJ_FLETEN)
	oSection16:Printline()

	oSection16:cell("GASTOS"):SeTValue(STR0017)//"Seguros"
	oSection16:cell("EXTR"):SeTValue(RSJ->RSJ_SEGE)
	oSection16:cell("NAC"):SeTValue(RSJ->RSJ_SEGN)
	oSection16:Printline()

	oSection16:cell("GASTOS"):SeTValue(STR0018)//"Almacenaje"
	oSection16:cell("EXTR"):SeTValue(RSJ->RSJ_ALME)
	oSection16:cell("NAC"):SeTValue(RSJ->RSJ_ALMN)
	oSection16:Printline()


	oSection16:cell("GASTOS"):SeTValue(STR0019)//"Otros"
	oSection16:cell("EXTR"):SeTValue(  0/*RSJ->RSJ_OTROE*/)
	oSection16:cell("NAC"):SeTValue(RSJ->RSJ_OTRON)
	oSection16:Printline()
	
	oSection16:cell("GASTOS"):SeTValue(STR0021)//"Incrementables"
	oSection16:cell("EXTR"):SeTValue(RSJ->RSJ_VALINC)
	oSection16:cell("NAC"):SeTValue(0)
	oSection16:Printline()
	

	oReport:skipline()

	oSection16:cell("GASTOS"):SeTValue(STR0020)//"Total"
	oSection16:cell("EXTR"):SeTValue(RSJ->RSJ_FLETEE+RSJ->RSJ_SEGE+RSJ->RSJ_ALME+/*RSJ->RSJ_OTROE+*/RSJ->RSJ_VALINC)
	oSection16:cell("NAC"):SeTValue(RSJ->RSJ_FLETEN+RSJ->RSJ_SEGN+RSJ->RSJ_ALMN+RSJ->RSJ_OTRON)
	oSection16:Printline()

	oSection16:Finish()
EndIf
dbCloseArea( )
Return ( Nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    fImpSec3VALºAutor  ³FMonroy             º Data ³  11/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Imprime la seccion 2 Valores                                ³±±
±±³          ³ del informe de Pedimentos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   fImpSec3VAL( oExp )                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³   oExp: Objeto TReport                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³   MATR448                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpSec3VAL( oReport )
Local Osection3:= oReport:Section( 3 )
DbSelectArea( "RSJ" )
 RSJ-> ( dbSetOrder( 1 ) )
 If RSJ->(dbseek( cPedFil + NumPed ))
	oSection3:Init()
 	While  RSJ->( !Eof() ).AND. (alltrim(RSJ->RSJ_FILIAL) + alltrim(RSJ->RSJ_NUMPED)  == alltrim(xFilial( "RSJ" )) + alltrim(NumPed)   )
	 
		oSection3:cell("VAL" ):SetValue( TitSX3( "RSJ_VALDOL" )[1] )
		oSection3:cell("VAL_IMP" ):SetValue( RSJ->RSJ_VALDOL)
		oSection3:printline()
		oSection3:cell("VAL" ):SetValue( TitSX3( "RSJ_VALADU" )[1] )
		oSection3:cell("VAL_IMP" ):SetValue( RSJ->RSJ_VALADU)
		oSection3:printline()
		oSection3:cell("VAL" ):SetValue( TitSX3( "RSJ_VALPES" )[1] )
		oSection3:cell("VAL_IMP" ):SetValue( RSJ->RSJ_VALPES)
		oSection3:printline()
		
		RSJ-> ( dbskip() )
	EndDo
	oSection3:Finish()
 EndIf
dbCloseArea( )
Return ( Nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao     fImpSec6  ºAutor  ³FMonroy             º Data ³  11/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Imprime la seccion 6 Calculo del Costo                      ³±±
±±³          ³ del informe de Pedimentos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   fImpSec6( oExp )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³   oExp: Objeto TReport                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³   MATR448                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpSec6(oReport,cAliasRSI)

Local oSection6:=oReport:Section(6)

Local nImpor	:=0
Local nIncrem	:=0
Local nCif		:=0
Local nImpues	:=0
Local nGastos	:=0
Local nCostoT	:=0
Local nCosUni	:=0


	cFiltro:=   "%  RSI.RSI_NUMPED ='"      + Numped + "' "
	cFiltro+=   "   AND RSA.RSA_USOFRA ='1'               "
	cFiltro+=   "   AND RSI.RSI_FILIAL ='"  + cPedFil+ "'  %"
	oSection6:BeginQuery()
	BeginSql alias cAliasRSI

		SELECT	RSG_FRACAR, RSH_TASA, RSI_PROD, RSI_UMC,RSI_CANT, RSI_COSTO,RSI_CANT2
				RSI_IMPOR,  RSI_INCREM, RSI_CIF, RSI_IMPUES, RSI_GASTOS,RSI_COSUNI, (RSI_CIF+RSI_IMPUES+RSI_GASTOS)  COSTOT
		FROM %table:RSI% RSI
		
		LEFT OUTER JOIN  %table:RSG% RSG
			ON RSG_FILIAL=RSI_FILIAL
			AND RSG_NUMPED=RSI_NUMPED
			AND RSG_FACT=RSI_FACT
			AND RSG_SERIE=RSI_SERIE
			AND RSG_PROV=RSI_PROV
			AND RSG_TDA=RSI_TDA
			AND RSG_ITEM=RSI_ITEM
		
		LEFT OUTER JOIN  %table:RSH% RSH
			ON RSG_FILIAL=RSH_FILIAL
			AND RSG_NUMPED=RSH_NUMPED
			AND RSG_FACT=RSH_FACT
			AND RSG_SERIE=RSH_SERIE
			AND RSG_PROV=RSH_PROV
			AND RSG_TDA=RSH_TDA
			AND RSG_ITEM=RSH_ITEM
			AND RSG_SECC=RSH_SECC
		
		LEFT OUTER JOIN  %table:RSA% RSA
			ON RSA_CODIGO=RSH_IMPUES
		WHERE
	       %exp:cFiltro%
			AND RSI.%notDel%
			AND RSH.%notDel%
			AND RSG.%notDel%
			AND RSA.%notDel%
	EndSql
Begin Sequence
oSection6:EndQuery()

	dbSelectArea( cAliasRSI )

	(cAliasRSI)->(DbGoTop())
	If (cAliasRSI)->(!Eof())
		oSection6:Init()
		oSection6:cell("RSI_CANT2"):setTitle(STR0020)//"Total"
		While (cAliasRSI)->(!Eof())
			oSection6:cell("RSI_DESC"):setvalue(POSICIONE("SB1",1,XFILIAL("SB1")+(cAliasRSI)->RSI_PROD,"B1_DESC"))
			oSection6:cell("RSI_CANT2"):setvalue((cAliasRSI)->COSTOT)
			oSection6:printline()
			
			nImpor	+=(cAliasRSI)->RSI_IMPOR
			nIncrem	+=(cAliasRSI)->RSI_INCREM
			nCif	+=(cAliasRSI)->RSI_CIF
			nImpues	+=(cAliasRSI)->RSI_IMPUES
			nGastos	+=(cAliasRSI)->RSI_GASTOS
			nCostoT	+=(cAliasRSI)->COSTOT
			nCosUni	+=(cAliasRSI)->RSI_COSUNI

			(cAliasRSI)->(dbSkip())

		EndDo //Fin  de archivo
		
		//Imprime Totales
		oSection6:cell("RSG_FRACAR"):Hide()
		oSection6:cell("RSH_TASA"):Hide()
		oSection6:cell("RSI_PROD"):hide()
		oSection6:cell("RSI_DESC"):setvalue(STR0012)//"Total-->"
		oSection6:cell("RSI_UMC"):hide()
		oSection6:cell("RSI_CANT"):hide()

		oSection6:cell("RSI_COSTO"):hide()
		oSection6:cell("RSI_IMPOR"):setvalue(nImpor)

		oSection6:cell("RSI_INCREM"):setvalue(nIncrem)
		oSection6:cell("RSI_CIF"):setvalue(nCIF)

		oSection6:cell("RSI_IMPUES"):setvalue(nImpues)
		oSection6:cell("RSI_GASTOS"):setvalue(nGastos)
		oSection6:cell("RSI_CANT2"):SETVALUE(nCostoT)
		oSection6:cell("RSI_COSUNI"):SETVALUE(nCosUni)

		oSection6:PrintLine()
		oSection6:Finish()

	
EndIf //If fin de archivo

End Sequence
(cAliasRSI)->(dbCloseArea())

Return (  Nil  )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao     fImpSec7  ºAutor  ³FMonroy             º Data ³  11/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Imprime la seccion 7 Incrementables                         ³±±
±±³          ³ del informe de Pedimentos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   fImpSec7( oExp )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³   oExp: Objeto TReport                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³   MATR448                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fImpSec7(oReport)
Local oSection7:=oReport:Section(7)

DbSelectArea( "RSK" )
 RSK-> ( dbSetOrder( 1 ) )
 If RSK->(dbseek( cPedFil + NumPed ))
	oSection7:Init()
 	While  RSK->( !Eof() ).AND. (alltrim(RSK->RSK_FILIAL) + alltrim(RSK->RSK_NUMPED)  == alltrim(xFilial( "RSJ" )) + alltrim(NumPed)  )
		 oSection7:CELL("A2_NOME"):SETVALUE(POSICIONE( "SA2" , 1 , xFilial("SA2") + RSK->RSK_PROV+RSK->RSK_TDA, "A2_NOME" ))
         oSection7:printline()
		 RSK-> ( dbskip() )
	EndDo
	oSection7:Finish()
 EndIf
dbCloseArea( )

Return( Nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao     PrintTot  ºAutor  ³FMonroy             º Data ³  28/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Imprimir Totales por factura                                ³±±
±±³          ³ del informe de Pedimentos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   PrintTot(nExp,nExp1,nExp2,nExp3, oExp4 )                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³   nExp:  Valor númerico                                    ³±±
±±³          ³   nExp1: Valor númerico                                    ³±±
±±³          ³   nExp2: Valor númerico                                    ³±±
±±³          ³   nExp3: Valor númerico                                    ³±±
±±³          ³   oExp4: Objeto TReport                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³   MATR448                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function PrintTot(nValAdu,nValCom,nPorIva,nImpIva,oReport)

Local oSection14  := oReport:Section(9):Section(2)

oSection14:init()

oSection14:cell("RSG_SECC"   ):SetPicture("!@")
oSection14:cell("RSG_FRACAR" ):SetPicture("!@")
oSection14:cell("RSG_VINCU"  ):SetPicture("!@")
oSection14:cell("RSG_METVAL" ):SetPicture("!@")
oSection14:cell("RSG_UMC"    ):SetPicture("!@")
oSection14:cell("RSG_CANUMC" ):SetPicture("!@")
oSection14:cell("RSG_PAIVTA" ):SetPicture("!@")
oSection14:cell("RSG_PAIORI" ):SetPicture("!@")
oSection14:cell("RSG_DOLARE" ):SetPicture("!@")
oSection14:cell("RSG_VALCOM" ):SetPicture( PesqPict("RSG","RSG_VALCOM"))
oSection14:cell("RSG_VALADU" ):SetPicture( PesqPict("RSG","RSG_VALADU"))

oSection14:cell("RSG_SECC"   ):SetValue( SPACE(1))
oSection14:cell("RSG_FRACAR" ):SetValue( SPACE(1))
oSection14:cell("RSG_VINCU"  ):SetValue( SPACE(1))
oSection14:cell("RSG_METVAL" ):SetValue( SPACE(1))
oSection14:cell("RSG_UMC"    ):SetValue( SPACE(1))
oSection14:cell("RSG_CANUMC" ):SetValue( SPACE(1))
oSection14:cell("RSG_PAIVTA" ):SetValue( SPACE(1))
oSection14:cell("RSG_PAIORI" ):SetValue( SPACE(1))
oSection14:cell("RSG_DOLARE" ):SetValue( STR0020)//"Total"
oSection14:cell("RSG_VALCOM" ):SetValue( nValCom)
oSection14:cell("RSG_VALADU" ):SetValue( nValAdu)

OSECTION14:PRINTLINE()
OSECTION14:FINISH()


Return ( Nil )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao     ImpSec2   ºAutor  ³FMonroy             º Data ³  11/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Imprimir Secc 2                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   ImpSec2( oExp )                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³   oExp: Objeto TReport                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³   MATR448                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpSec2(oReport,cAliasRSC)

Local oSection2:=oReport:Section(2)

oSection2:Init()
If oReport:nDevice == 4
	oSection2:cell("PEDIMENT"):Enable()
	oSection2:cell("CLVPEDIMENT"):Enable()
	oSection2:cell("PEDIMENT"):SetTitle(STR0002) // Pedimento
	oSection2:cell("PEDIMENT"):SetValue(NumPed)
	oSection2:cell("CLVPEDIMENT"):SetTitle(TitSX3("RSC_CVEPED")[1]) // Cve Pediment
	oSection2:cell("CLVPEDIMENT"):SetValue(AllTrim(( cAliasRSC )->RSC_CVEPED))
EndIf
oSection2:cell("RSC_AGENTE" ):SetValue( alltrim(( cAliasRSC )->RSC_AGENTE)+Space(1)+ POSICIONE( "DB9" , 1 , xFilial("DB9") + ( cAliasRSC )->RSC_AGENTE, "DB9_NOME" ))
oSection2:cell("RSC_OBSERV"):Settitle( TitSX3( "RSC_OBSERV" )[1]  )
oSection2:cell("RSC_OBSERV" ):SetValue(impObserv(oReport))
oSection2:printline()
oSection2:finish()

Return (Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao     impObserv ºAutor  ³FMonroy             º Data ³  11/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Imprimer Observaciones del pedimento                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   impObserv( oExp )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³   oExp: Objeto TReport                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³   MATR448                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static function impObserv(oReport)

Local cMemo			:=	""
Local nCont			:=	1 

dbSelectArea("RSC")
dbSeek(cPedFil+Numped)
cMemo := MemoLine(RSC->RSC_OBSERV,,nCont) 

Return( cmemo )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao     fImpSec17 ºAutor  ³FMonroy             º Data ³  11/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Imprimir Sección 17                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   fImpSec17( oExp )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³   oExp: Objeto TReport                                     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³   MATR448                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fImpSec17(oReport,cAliasRSA)

Local oSection17:=oReport:Section(11)

	cFiltro:=   "%  RSD.RSD_NUMPED ='"      + Numped + "' "
	cFiltro+=   "   AND RSD.RSD_FILIAL ='"  + cPedFil+ "'  %"
	oSection17:BeginQuery()	
	BeginSql alias cAliasRSA

		SELECT	RSA_DESC,   RSA_TIPO,		RSA_TASIMP ,RSA_IMPORT
		FROM %table:RSD% RSD
		INNER JOIN  %table:RSA% RSA
			ON 	   RSA.RSA_CODIGO  =  RSD.RSD_CODIMP
		WHERE
	       %exp:cFiltro%
			AND RSD.%notDel%
			AND RSA.%notDel%
		ORDER BY RSA.RSA_DESC 

	EndSql

Begin Sequence
oSection17:EndQuery()

	dbSelectArea( cAliasRSA )
	
	(cAliasRSA)->(DbGoTop())
	If (cAliasRSA)->(!Eof())
		oSection17:Init()
		While (cAliasRSA)->(!Eof())
			OSECTION17:CELL("RSA_TASIMP"):SETVALUE(IF((cAliasRSA)->RSA_TASIMP==0,(cAliasRSA)->RSA_IMPORT,(cAliasRSA)->RSA_TASIMP))
			oSection17:PrintLine()
			(cAliasRSA)->(dbSkip())
						
		EndDo //Fin  de archivo
		oSection17:Finish()
	EndIf //If fin de archivo
	
End Sequence
(cAliasRSA)->(dbCloseArea())

Return ( Nil )
