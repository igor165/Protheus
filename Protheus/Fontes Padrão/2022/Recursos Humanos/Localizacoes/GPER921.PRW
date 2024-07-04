#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER921.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER921  ³ Autor ³  Flor Monroy          ³ Data ³ 31/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reporte de Acumulados POR EMPLEADO                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER921()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  FMONROY   ³14-06-11³Mej   ³Cambio en la especificación para quitar   ³±±
±±³            ³        ³      ³Arquitectura Organizacional y rango de    ³±±
±±³            ³        ³      ³preguntas de año.                         ³±± 
±±³Raquel Hager³27-06-12³016309³Correcao na query para correta ordenacao  ³±±
±±³            ³        ³ /2012³por Centro de Custo e Departamento. Corre-³±±
±±³            ³        ³TFGA02³para correta impressao de rel. sintetico. ³±±
±±³Jonathan Glz³24/11/16³MMI-  ³Se realiza modificacion a query y al while³±±
±±³            ³        ³  4223³de impresion; para que se impr. los datos ³±±
±±³            ³        ³      ³de todas la filiales.                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER921()

Local oReport
Local aGetArea	:=  GetArea()
Local cPerg		:=  "GPER921"
Private cLisSuc	:=	""		//Lista de Sucursales
Private cLisCC	:=	""		//Lista de Centros de costos
Private cLisDep	:=	""		//Lista de de Deptos 
Private cLisMat	:=	""		//Lista de matricula
Private cLisSit	:=	""		//Lista de situaciones   (Seleccion)
Private cLisCat	:=	""		//Lista de categorias (Seleccion)
Private cProces	:=	""		//Proceso
Private cLisCon	:=	""		//Lista de Conceptos (Seleccion)
Private cLisCon2:=	""		//Cont.Lista de Conceptos (Seleccion)
Private cLisCri	:=	""		//Lista de criterios
Private cVision	:=	""		//Cod Vision
Private cDepto	:=	""		//Cod
Private cAllCon :=	""		//Todos los conceptos

Private cAliasRG7 := CriaTrab(nil,.f.)	// Creo mi tabla temporal
Private cNomeProg := "GPER921"

Private nTipo	:=0			//Tipo de detalle
Private nAnioII	:=0			//Año inicial inicial
Private nAnioIF	:=0			//Año inicial final
Private nAnioFI	:=0			//Año final Inicial
Private nAnioFF	:=0			//Año final Final
Private nMes1	:=0			//Mes1 -Solo Para Reporte Sintetico
Private nMes2	:=0			//Mes2 -Solo para reporte Sintetico
Private nTipVal	:=0			//Tipo de valor a imprimir
Private nContPd	:=0
Private nMaxCol	:=13 		//Numero de Meses --Para el encabezado

dbSelectArea("RG7")
DbSetOrder(1)

If Pergunte(cPerg,.T.)
   If TodoOK()
		If nTipo == 1 //Informe Analitico
			oREPORT := REPORTDEF()
		Else  		 //Informe Sintetico
			oREPORT := ReportDef_hor()
		Endif
		oREPORT:PRINTDIALOG()	
   Endif
Endif    

RestArea(aGetArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportDef   Autor ³ FMonroy               ³ Data ³31/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Def. Reporte Analitico y Sintetico                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER921                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

Local aArea      := GetArea() 
Local oReport, oSection1,oSection2,oSection3,oSection4, oSection5
Local nCont:=0

Private cTitulo	:= OemToAnsi(STR0001) //"Acumulados por Concepto -"
                    //"Nombre"         ###"Matricula"      ###"Centro de Costos"###"Departamento"
Private aOrd    := {OemToAnsi(STR0003),OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006)}

cTitulo := Trim(cTitulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oReport:=TReport():New(cNomeProg,OemToAnsi(cTitulo), /*NomeProg */  ,{|oReport| PrintReport(oReport)})	
oReport:nColSpace:= 2
oReport:nFontBody	:= 5 // Define o tamanho da fonte.
oReport:CFONTBODY:="COURIER NEW"
oReport:Setlandscape(.T.)//Pag Horizontal  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: Encabezado                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

oSection1:= TRSection():New(oReport,"Sucursal",,aOrd,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetHeaderSection(.t.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.T.)	//Exibe Cabecalho da Secao
oSection1:SetLineStyle(.T.)   //Pone titulo del campo y aun lado el y valor
oSection1:SetCharSeparator(": ")
oSection1:SetLeftMargin(1)

TRCell():New(oSection1,"SM0_NOME",     ,STR0007, ,15/*,,,,,,,,,,,.t.*/)//"Empresa"
TRCell():New(oSection1,"SUCURSAL",     ,STR0008, ,30/*,,,,,,,,,,,.t.*/)//"Sucursal"
TRCell():New(oSection1,"PROCES"  ,     ,STR0009, ,TamSx3("RG7_PROCES")[1]+TamSx3("RCJ_DESCRI")[1]+2/*,,,,,,,,,,,.t.*/)//"Proceso"
TRCell():New(oSection1,"ANOI"    ,     ,STR0010, ,4/*,,,,,,,,,,,.t.*/)//"Del Año"
TRCell():New(oSection1,"ANOF"    ,     ,STR0011, ,4/*,,,,,,,,,,,.t.*/)//"Al Año"
TRCell():New(oSection1,"DET"     ,     ,STR0012, ,25/*,,,,,,,,,,,.t.*/)//"Tipo DaTalle"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 2da.     Secao:Enc"Tit                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection2:= TRSection():New(oReport,"Detalle1",,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"
oSection2:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection2:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao

TRCell():New(oSection2,"MT",, ,,9)//"Matricula"
TRCell():New(oSection2,"NOME",,,,TamSx3("RA_NOME")[1])//"Nombre"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 3ra.     Secao:Encabezado Empleado                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection3:= TRSection():New(oReport,"Detalle2",,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"
oSection3:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection3:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection3:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao

TRCell():New(oSection3,"RA_MAT",cAliasRG7,STR0013 ,  PesqPict("SRA","RA_MAT")    ,9)//"Matricula"
TRCell():New(oSection3,"RA_NOME",cAliasRG7, STR0014 ,  PesqPict("SRA","RA_NOME")    ,TamSx3("RA_NOME")[1])//"Nombre"
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 4da.     Secao: Detalle	Titulos		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection4:= TRSection():New(oReport,"Totales1",,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"
oSection4:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection4:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection4:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao

TRCell():New(oSection4,"CON"   ,,, ,TamSx3("RG7_PD")[1]+TamSx3("RV_DESC")[1], .F. , /*bBlock*/ ,"LEFT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
TRCell():New(oSection4,"CODCRI",,, ,11, .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
TRCell():New(oSection4,"ANOINI",,, ,9 , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)

For nCont:=1 to nMaxCol  // Analitico
	TRCell():New(oSection4,alltrim(STR(nCont)),, ,    ,13 , .F. , /*bBlock*/ ,"CENTER"  ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
Next

TRCell():New(oSection4,"TOTAL",, ,  , 14, .F. , /*bBlock*/ ,"CENTER"  ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.T. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //Total Anual

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 5ta.     Secao: Dtalle	                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection5:= TRSection():New(oReport,"Totales2",,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"
oSection5:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection5:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection5:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao

TRCell():New(oSection5,"CON"       ,,, ,(TamSx3("RG7_PD")[1]+TamSx3("RV_DESC")[1])-1, .F. , /*bBlock*/ ,"LEFT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
TRCell():New(oSection5,"RG7_CODCRI",,,  PesqPict("RG7","RG7_CODCRI")    ,9, .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
TRCell():New(oSection5,"RG7_ANOINI",,,  PesqPict("RG7","RG7_ANOINI")    ,7 , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)

For nCont:=1 to nMaxCol	// Analitico
	TRCell():New(oSection5,alltrim(STR(nCont)),,, PesqPict("RG7","RG7_ACUM01") ,12, .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"RIGHT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
Next

TRCell():New(oSection5,"TOTAL",,, "999,999,999.99" ,13, .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"RIGHT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.) //Total Anual

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportDef_hor   Autor ³ FMonroy           ³ Data ³31/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Def. Reporte             Sintetico                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER921                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef_hor()

Local aArea      := GetArea() 
Local oReport, oSection1,oSection2,oSection3,oSection4, oSection5
Local nCont:=0

Private cTitulo	:=OemToAnsi(STR0001) //"Acumulados por Concepto -"
                    //"Nombre"         ###"Matricula"     ###"Centro de Costos"###"Departamento"
Private aOrd    := {OemToAnsi(STR0003),OemToAnsi(STR0004),OemToAnsi(STR0005),OemToAnsi(STR0006)}

cTitulo := Trim(cTitulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oReport:=TReport():New(cNomeProg,OemToAnsi(cTitulo), /*NomeProg */  ,{|oReport| PrintReport(oReport)})	
oReport:nColSpace := 3
oReport:nFontBody := 5 // Define o tamanho da fonte.
oReport:cFontBody :="COURIER NEW"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: Encabezado                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection1:= TRSection():New(oReport,/*Titulo*/,,aOrd,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetHeaderSection(.t.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.T.)	//Exibe Cabecalho da Secao
oSection1:SetLineStyle(.T.)   //Pone titulo del campo y aun lado el y valor
OSection1:SetCharSeparator(":")    
oSection1:SetLeftMargin(15)

TRCell():New(oSection1,"SM0_NOME",	,STR0007,	,15)//"Empresa"
TRCell():New(oSection1,"SUCURSAL", ,STR0008,   ,30)//"Sucursal"
TRCell():New(oSection1,"PROCES",   ,STR0009,   ,TamSx3("RG7_PROCES")[1]+TamSx3("RCJ_DESCRI")[1]+2)//"Proceso"
TRCell():New(oSection1,"ANOI",     ,STR0010,   ,4)//"Del Año"
TRCell():New(oSection1,"ANOF",	    ,STR0011,   ,4)//"Al Año" 
TRCell():New(oSection1,"DET",      ,STR0012,   ,25)//"Tipo DaTalle"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 2da.     Secao:Enc"Tit                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection2:= TRSection():New(oReport,/*Titulo*/,,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"
oSection2:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection2:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao

TRCell():New(oSection2,"MT",, ,        ,9)//"Matricula"
TRCell():New(oSection2,"NOME",,  ,     ,TamSx3("RA_NOME")[1])//"Nombre"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 3ra.     Secao:Encabezado Empleado                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection3:= TRSection():New(oReport,/*Titilo*/,,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"
oSection3:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection3:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection3:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao

TRCell():New(oSection3,"RA_MAT",cAliasRG7,  STR0013 ,  PesqPict("SRA","RA_MAT")    ,9)//"Matricula"
TRCell():New(oSection3,"RA_NOME",cAliasRG7, STR0014 ,  PesqPict("SRA","RA_NOME")    ,TamSx3("RA_NOME")[1])//"Nombre"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 4da.     Secao: Detalle	Titulos		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection4:= TRSection():New(oReport,/*Titulo*/,,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"
oSection4:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection4:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection4:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao

TRCell():New(oSection4,"CON"   ,,, ,TamSx3("RG7_PD")[1]+TamSx3("RV_DESC")[1], .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
TRCell():New(oSection4,"CODCRI",,, ,10, .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
TRCell():New(oSection4,"ANOINI",,, ,8 , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)

For nCont:=nMes1 to nMes2  // Sintetico
	TRCell():New(oSection4,alltrim(STR(nCont)),, ,    ,14, .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"RIGHT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
Next

TRCell():New(oSection4,"SUMA",, ,  ,14, .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"RIGHT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
TRCell():New(oSection4,"TOTAL",, , ,14, .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"RIGHT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 5ta.     Secao: Dtalle	                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ-ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection5:= TRSection():New(oReport,/*Titulo*/,,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"
oSection5:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection5:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection5:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao

TRCell():New(oSection5,"CON"       ,,, ,TamSx3("RG7_PD")[1]+TamSx3("RV_DESC")[1], .F. , /*bBlock*/ ,"LEFT" ,.F. ,"LEFT" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
TRCell():New(oSection5,"RG7_CODCRI",,,  PesqPict("RG7","RG7_CODCRI")    ,9, .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
TRCell():New(oSection5,"RG7_ANOINI",,,  PesqPict("RG7","RG7_ANOINI")    ,7 , .F. , /*bBlock*/ ,"CENTER" ,.F. ,"CENTER" ,/*lCellBreak*/, 0 ,.F. ,/*nClrBack*/ ,/*nClrFore*/,.F.)

For nCont:=nMes1 to nMes2	// Sintetico
	TRCell():New(oSection5,alltrim(STR(nCont)),, ,  PesqPict("RG7","RG7_ACUM01")    ,12 , .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"RIGHT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
Next

TRCell():New(oSection5,"SUMA",, ,       PesqPict("RG7","RG7_ACUM01")   , 14, .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"RIGHT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)
TRCell():New(oSection5,"TOTAL",, ,      PesqPict("RG7","RG7_ACUM01")   , 14, .F. , /*bBlock*/ ,"RIGHT"  ,.F. ,"RIGHT" ,/*lCellBreak*/, 0 ,.t. ,/*nClrBack*/ ,/*nClrFore*/,.F.)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PrintReport Autor ³ FMonroy               ³ Data ³31/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³   Impresión del Informe                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³    PrintReport(oExp)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER921                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport)

Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(2)
Local oSection3  := oReport:Section(3)
Local oSection4  := oReport:Section(4)
Local oSection5  := oReport:Section(5)

Local cTitle	 := ""     
Local cOrdem     := "" 
Local cFilRG7    := xfilial("RG7")
Local cFilSRA    := xfilial("SRA")
Local cFilSRJ    := xfilial("SRJ")
Local cFilSRV    := xfilial("SRV")
Local cChaveArq	 := ""
Local cOrgJoin	 := "% %"
Local cFilPro    := ""
Local cSuc       := ""
Local cEmp       := ""
Local cMat       := ""
Local cSucEmp    := ""
Local cSelect    := ""
Local cGroup     := ""  
Local cPrefijo   := "" //A SI ES ACUMULADOS Y H SI ES HORAS, 
Local cSufijo    := "" 
Local cNome      := ""

Local nOrdem     := oSection1:GetOrder()
Local nTotal     := 0
Local nPos       := 0
Local nTpd       := 0
Local nCnt       := 0
Local nIx        := 0
Local _NPOS      := 0

Local aChaveArq	:= {}
Local _aAllFilial :={}
Local lShar		:= .F.

Pergunte(oReport:GetParam(),.F.)   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitle 	:= If(AllTrim(oReport:Title())== AllTrim(cTitle), OemToansi(cTitulo),oReport:Title())
oReport:SetTitle(cTitle + " - " + If(nTipo == 1, STR0015, STR0016 ))//ANALITICO # SINTETICO 

#IFDEF TOP

	//Transforma los parametros de tipo Rango en expresion SQL para ser utilizada en query
	MakeSqlExpr("GPER921")
	
	If nOrdem == 1
		cOrdem := "% RG7.RG7_FILIAL, SRA.RA_FILIAL, SRA.RA_MAT, RG7.RG7_PD %"
	ElseIf nOrdem == 2
		cOrdem := "% RG7.RG7_FILIAL, SRA.RA_FILIAL, SRA.RA_NOME, RG7.RG7_PD %"
	ElseIf nOrdem == 3
		cOrdem := "% RG7.RG7_FILIAL, SRA.RA_FILIAL, SRA.RA_CC, SRA.RA_MAT, RG7.RG7_PD %"
	ElseIf nOrdem == 4
		cOrdem := "% RG7.RG7_FILIAL, SRA.RA_FILIAL, SRA.RA_DEPTO, SRA.RA_MAT, RG7.RG7_PD %"
	Endif
	
	cFilPro :=  "%"
	cFilPro +=  IF( Empty(MV_PAR01) , " " , " AND " + REPLACE(MV_PAR01, "RA_FILIAL", " RG7.RG7_FILIAL ") ) //Suc
	cFilPro +=  IF( EMPTY(MV_PAR02) , " " , " AND " + MV_PAR02 ) //CC
	cFilPro +=  IF( Empty(MV_PAR03) , " " , " AND " + MV_PAR03 ) //Deptos
	cFilPro +=  IF( EMPTY(MV_PAR04) , " " , " AND " + MV_PAR04 ) //Matriculas
	cFilPro +=  IF( EMPTY(MV_PAR08) , " " , " AND " + MV_PAR08 ) //Procesos
	cFilPro +=  IF( EMPTY(MV_PAR13) , " " , " AND " + MV_PAR13 ) //Criterios
	
	IF cAllCon == 2 //NO imprime todos los conceptos, Imprime los seleccionados
		cFilPro +=  " AND (RG7.RG7_PD IN ("+cLisCon+")" //Conceptos 13
		cFilPro +=  IF(EMPTY(MV_PAR12), ") "," OR RG7.RG7_PD IN ("+cLisCon2+"))") //Mas Conceptos 14
	EndIf
	
	cFilPro +=  IF( EMPTY(MV_PAR09) , " AND RG7.RG7_ANOINI = "+ALLTRIM(STR(MV_PAR10)) , ;
	                " AND RG7.RG7_ANOINI BETWEEN "+ALLTRIM(Str(MV_PAR09))+" AND "+ALLTRIM(Str(MV_PAR10)) ;
	               ) //anio Inicial
	
	cFilPro +=  "%"
	
	cSelect :=	"% RG7.RG7_FILIAL, SRA.RA_FILIAL, RG7.RG7_PROCES, SRA.RA_MAT, SRA.RA_NOME, SRV.RV_DESC, "
	cSelect +=	" SRA.RA_NOME, RG7.RG7_PD, RG7.RG7_CODCRI, RG7.RG7_ANOINI, RCJ.RCJ_DESCRI, "
	cSelect +=	" SUM(RG7_HRS01) H01, SUM(RG7_HRS02) H02, SUM(RG7_HRS03) H03, SUM(RG7_HRS04) H04, "
	cSelect +=	" SUM(RG7_HRS05) H05, SUM(RG7_HRS06) H06, SUM(RG7_HRS07) H07, SUM(RG7_HRS08) H08, "
	cSelect +=	" SUM(RG7_HRS09) H09, SUM(RG7_HRS10) H10, SUM(RG7_HRS11) H11, SUM(RG7_HRS12) H12, SUM(RG7_HRS13) H13, "
	cSelect +=	" SUM(RG7_ACUM01) A01, SUM(RG7_ACUM02) A02, SUM(RG7_ACUM03) A03, SUM(RG7_ACUM04) A04, "
	cSelect +=	" SUM(RG7_ACUM05) A05, SUM(RG7_ACUM06) A06, SUM(RG7_ACUM07) A07, SUM(RG7_ACUM08) A08, "
	cSelect +=	" SUM(RG7_ACUM09) A09, SUM(RG7_ACUM10) A10, SUM(RG7_ACUM11) A11, SUM(RG7_ACUM12) A12, SUM(RG7_ACUM13) A13 %"

	cGroup  :=  "% RG7.RG7_FILIAL, SRA.RA_FILIAL, SRA.RA_CC, RG7.RG7_PROCES, SRA.RA_MAT, SRA.RA_NOME, "
	cGroup  +=  " SRA.RA_DEPTO, SRV.RV_DESC, SRA.RA_NOME , RG7.RG7_PD, RG7.RG7_CODCRI, RG7.RG7_ANOINI, RCJ.RCJ_DESCRI  %"
	
	BeginSql alias cAliasRG7
		SELECT	%exp:cSelect%
		FROM %table:RG7% RG7
			INNER JOIN %table:SRA% SRA ON RG7.RG7_PROCES = SRA.RA_PROCES AND RG7.RG7_MAT = SRA.RA_MAT
			INNER JOIN %table:SRV% SRV ON RG7.RG7_PD = SRV.RV_COD
			INNER JOIN %table:RCJ% RCJ ON RG7.RG7_PROCES = RCJ.RCJ_CODIGO
		%exp:cOrgJoin%
		WHERE SRA.RA_SITFOLH IN (%exp:cLisSit%)  //Situciones
		AND SRA.RA_CATFUNC IN (%exp:cLisCat%)  //Categorias
		%exp:cFilPro%
		AND  RG7.%notDel%
		AND SRA.%notDel%
		AND SRV.%notDel%
		AND RCJ.%notDel%
		GROUP BY %exp:cGroup%
		ORDER BY %exp:cOrdem%
	EndSql
			
#ELSE

	MSGERROR(STR0017)//"No esta disponible para DBF"
	
#ENDIF	

Begin Sequence 
	dbSelectArea( cAliasRG7 )
	count to nTotal
	oReport:SetMeter(nTotal) 
	(cAliasRG7)->(DbGoTop()) 
	If (cAliasRG7)->(!Eof())
	
		While (cAliasRG7)->(!Eof()) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Sección Encabezado de Sucursales                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSection1:Init() 
			oSection1:Cell("SM0_NOME"):Enable()
			oSection1:Cell("SUCURSAL"):Enable()					
			oSection1:Cell("SM0_NOME"):SetValue(SM0->M0_NOME)
			If  GetVersao(.F.) == "P10"
				oSection1:Cell("SUCURSAL"):SetValue(FWFilialName(cEmpAnt,(cAliasRG7)->RG7_FILIAL ,1) )
			Else
				_aAllFilial :=FWLoadSM0()
				_nPos := ASCAN(_aAllFilial, {|aVal|ALLTRIM( aVal[2]) == ALLTRIM((cAliasRG7)->RG7_FILIAL)})
				oSection1:Cell("SUCURSAL"):SetValue( iF( _NPOS > 0 , iF( !EMPTY(ALLTRIM(_aAllFilial[_NPOS][7])) , ;
				                                                          ALLTRIM(_aAllFilial[_NPOS][7]) , _aAllFilial[_NPOS][20] ), " "))
			EndIf
			
			oSection1:Cell("PROCES"):hide()
			oSection1:Cell("ANOI"):hide()
			oSection1:Cell("ANOF"):hide()
			oSection1:Cell("DET"):hide()
			oSection1:Printline()
			oSection1:Cell("SM0_NOME"):disable()
			oSection1:Cell("SUCURSAL"):disable()
			oSection1:Cell("PROCES"):show()
			oSection1:Cell("ANOI"):show()
			oSection1:Cell("ANOF"):show()
			oSection1:Cell("DET"):show()
			oSection1:Cell("PROCES"):SetValue(alltrim((cAliasRG7)->RG7_PROCES)+Space(1)+ALLTRIM((cAliasRG7)->RCJ_DESCRI))	
			oSection1:Cell("PROCES"):SetSize(len(alltrim((cAliasRG7)->RG7_PROCES)+Space(1)+ALLTRIM((cAliasRG7)->RCJ_DESCRI)))
			oSection1:Cell("ANOI"):SetValue(ALLTRIM(STR(nAnioII)))	
			oSection1:Cell("ANOF"):SetValue(ALLTRIM(STR(nAnioIF)))//	nAnioFI 
			
			If nTipVal==1
				oSection1:Cell("DET"):SetValue(STR0018)//"Valores"
				cPrefijo:="A"
			ElseIf nTipVal==2
				oSection1:Cell("DET"):SetValue(STR0019)//"Horas/Dias"
				cPrefijo:="H"
			ElseIf nTipVal=3
				oSection1:Cell("DET"):SetValue(STR0020)//"Horas/Días y Valores"
				cPrefijo:="H"
			EndIf	         
			
			oSection1:Printline()
			oSection1:Finish()
			oReport:fatline()
			
			cSuc:=(cAliasRG7)->RG7_FILIAL
			cEmp:=SM0->M0_NOME
			
			oSection2:Init()
			oSection2:Cell("MT"):SetValue(STR0013)//"Matricula"
			oSection2:Cell("NOME"):SetValue(STR0014)//"Nombre"
			oSection2:PrintLine()
			oSection3:Init()
			oSection4:Init()
			oSection5:Init()
						
			oSection4:Cell("CON"):SetValue(STR0021)//"Concepto"
			oSection4:Cell("CODCRI"):SetValue(STR0022)//"Criterio"
			oSection4:Cell("ANOINI"):SetValue(STR0023)//"Año Ini"
			If nTipo == 1
				For nCnt:=1 to nMaxCol
					oSection4:Cell(alltrim(str(nCnt))):SetValue(STR0024+alltrim(str(nCnt)))
				Next
			Else   
				For nCnt:=nMes1 to nMes2
					oSection4:Cell(alltrim(str(nCnt))):SetValue(STR0024+alltrim(str(nCnt)))
				Next
				oSection4:Cell("SUMA"):SetValue(STR0026)	//"Suma"				
			EndIf
			oSection4:cell("TOTAL"):SetValue(STR0027)	//"Total Anual"
			osection4:printline()
			oReport:fatline()
			
			While (cAliasRG7)->(!Eof()) .And. cEmp == SM0->M0_NOME .and. cSuc == (cAliasRG7)->RG7_FILIAL
				cMat:=(cAliasRG7)->RA_MAT
				cNome:=(cAliasRG7)->RA_NOME
				cSucEmp := (cAliasRG7)->RA_FILIAL

			    oReport:skipline()
				oSection3:Printline()
			oReport:skipline()
				While (cAliasRG7)->(!Eof()) .And. cEmp == SM0->M0_NOME .and. cSuc == (cAliasRG7)->RG7_FILIAL ;
				       .and. cMat == (cAliasRG7)->RA_MAT .and. cSucEmp == (cAliasRG7)->RA_FILIAL

					oSection5:Cell("CON"):SetValue(ALLTRIM((cAliasRG7)->RG7_PD)+Space(1)+ALLTRIM((cAliasRG7)->RV_DESC))
					oSection5:Cell("RG7_CODCRI"):SetValue((cAliasRG7)->RG7_CODCRI)
					oSection5:Cell("RG7_ANOINI"):SetValue((cAliasRG7)->RG7_ANOINI)
					nTpd:=0		

					If nTipo == 1
						For nIx:=1 to nMaxCol
							cSufijo:=STRZERO(nIx,2)
							nTpd+=&("(cAliasRG7)->"+cPrefijo+cSufijo)
							oSection5:Cell(alltrim(str(nIx))):SetValue(&("(cAliasRG7)->"+cPrefijo+cSufijo)) 
						Next					
						oSection5:Cell("TOTAL"):SetValue(nTpd)
						oSection5:Printline()
						If nTipval==3 //Imprime Ambos Valores
							nTpd:=0	
							For nIx:=1 to nMaxCol
								cSufijo:=STRZERO(nIx,2)
								nTpd+=&("(cAliasRG7)->A"+cSufijo)
								oSection5:Cell(alltrim(str(nIx))):SetValue(&("(cAliasRG7)->A"+cSufijo))
							Next
							oSection5:Cell("TOTAL"):SetValue(nTpd)
							oSection5:Printline()
						EndIf
					Else
						nTpd:=0						
						For nIx:=nMes1 to nMes2
							cSufijo:=STRZERO(nIx,2)
							nTpd+=&("(cAliasRG7)->"+cPrefijo+cSufijo)
							oSection5:Cell(alltrim(str(nIx))):SetValue(&("(cAliasRG7)->"+cPrefijo+cSufijo)) 
						Next			
						oSection5:Cell("SUMA"):SetValue(nTpd) 				
						
						nTpd:=0
						For nIx:=1 to nMaxCol
							cSufijo:= StrZero(nIx,2)
							nTpd += &("(cAliasRG7)->"+cPrefijo+cSufijo)
					 	Next
						oSection5:Cell("TOTAL"):SetValue(nTpd)
						oSection5:Printline()
						
						If nTipVal == 3 //Imprime Ambos Valores
							nTpd:=0	 
							For nIx:=nMes1 to nMes2
								cSufijo:=STRZERO(nIx,2)
								nTpd+=&("(cAliasRG7)->A"+cSufijo)
								oSection5:Cell(alltrim(str(nIx))):SetValue(&("(cAliasRG7)->A"+cSufijo)) 
							Next
							oSection5:Cell("SUMA"):SetValue(nTpd) 											

							nTpd:=0
							For nIx:=1 to nMaxCol
								cSufijo:=STRZERO(nIx,2)
								nTpd+=&("(cAliasRG7)->A"+cSufijo)
							Next
							oSection5:Cell("TOTAL"):SetValue(nTpd)
							oSection5:Printline()
						EndIf
					EndIf
					(cAliasRG7)->(dbSkip())
					oReport:IncMeter()   //regla de avance
				 EndDo 	// el mismo empleado
			Enddo 		//Empresa y sucursal igual
			oSection2:Finish()
			oSection3:Finish()
			oSection4:Finish()
			oSection5:Finish()
		EndDo //Fin  de archivo
	EndIf //If fin de archivo 
End Sequence

(cAliasRG7)->(dbCloseArea()) 

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TodoOK    ºAutor  ³Microsiga           º Data ³  31/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacion de los datos antes de Ejecutar el proceso        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TodoOK(cPerg)

Pergunte(cPerg,.F.)

cLisSuc:= MV_PAR01 //Lista de Sucursales
cLisCC:=  MV_PAR02 //Lista de Centros de costos
cLisDep:= MV_PAR03 //Lista de de Deptos 
cLisMat:= MV_PAR04 //Lista de matricula

IF EMPTY(SUBSTR(MV_PAR05,1,1))
	cLisSit:="%' ',"+ConvQry(MV_PAR05,"RA_SITFOLH")+"%"
ELSE	
	cLisSit	:= "%"+ConvQry(MV_PAR05,"RA_SITFOLH")+"%"//Lista de situaciones   (Seleccion)    Tabla 31
ENDIF

cLisCat:= "%"+ConvQry(MV_PAR06,"RA_CATFUNC")+"%"//Lista de categorias (Seleccion)
nTipo  := MV_PAR07 //Tipo de detalle
cProces:= MV_PAR08 //Proceso
nAnioII:= MV_PAR09 //Año inicial inicial
nAnioIF:= MV_PAR10 //Año inicial final

cLisCon  := ConvQry(MV_PAR11,"RV_COD")//Lista de Conceptos (Seleccion)
cLisCon2 := ConvQry(MV_PAR12,"RV_COD")//Cont.Lista de Conceptos (Seleccion)

cLisCri  := MV_PAR13 //Lista de criterios
nMes1    := MV_PAR14 //Mes1 -Solo Para Reporte Sintetico
nMes2    := MV_PAR15 //Mes1 -Solo Para Reporte Sintetico
nTipVal  := MV_PAR16 //Tipo de valor a imprimir
cAllCon := MV_PAR17 //Todos los conceptos

If nTipo ==2
	If nMes1  <=0 .or. nMes1>13
	    msginfo(STR0028)//"El Mes 1 para Informe Sintetico debe ser de 1 a 13"
		Return (.F.)
	endIf
	If nMes2  <=0 .or. nMes2>13
	    msginfo(STR0028)//"El Mes 2 para Informe Sintetico debe ser de 1 a 13"
		Return (.F.)
	endIf
endIf
Return (.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ConvQry   ºAutor  ³Microsiga           º Data ³  27/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Convierte a expreción sql un campo informado con un listbox ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   ConvQry(cExp,cExp1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³    cExp: Cadena de caracteres que retorna el litbox        ³±±
±±³          ³    cExp1: Campo del diccionario de datos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER921                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ConvQry(cLista,cCampo)

Local cTxt:=''
Local nTamReg := TamSX3(cCampo)[1]
Local nCont:=0
/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Genera texto para usar  para usar despues en Query             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/                 
cLista:=alltrim(cLista)

For nCont := 1 To Len( cLista ) Step nTamReg
    cTxt+="'" +SubStr( cLista , nCont , nTamReg )+"',"
Next       

cTxt := Substr(cTxt,1,len(cTxt)-1)                                   

Return ( cTxt )
