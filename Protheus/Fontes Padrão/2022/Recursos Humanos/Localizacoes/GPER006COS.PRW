#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER006COS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPER006COS³ Autor ³  Flor Monroy               ³ Data ³ 26/07/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reportes Validación D152                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER006COS()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³     FNC   ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Christiane V³23/11/11³024239/2011³ Correção do Error Log ao acessar a rotina³±±
±±³Christiane V³30/11/11³024239/2011³ Correção da Impressão do relatório       ³±±
±±³Christiane V³13/12/11³024239/2011³ Correção da Impressão do relatório       ³±±
±±³Christiane V³28/12/11³024239/2011³ Correção Impressão do relatório por mês  ³±±
±±³            ³        ³           ³                                          ³±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function GPER006COS()


Local oReport
Local aGetArea	:=	GetArea()
Local cPerg		:=	"GPR006COS"
                                              
Private cSuc	:=	""	//Parametro de Entrada: Sucursal
Private cProceso:=	""	//Parametro de Entrada: Proceso
Private cPeriodo:=	""	//Parametro de Entrada: Periodo
Private cNumPag	:=	""	//Parametro de Entrada: Numero de Pago
Private cNomina	:=	""	//Parametro de Entrada: Nomina
Private cTipoD	:=	""	//Parametro de Entrada: 1=Analitico, 2=Sintetico
Private cOrdemD	:=	""	//Parametro de Entrada: 1=Empleado, 2=Concepto, 3=Mes
Private cRot	:=  ""
Private cAliasRG7:=	criatrab(nil,.f.)	// Creo mi tabla temporal
Private cNomeProg:=	"GPER006COS"

dbSelectArea("SRC")
dbSelectArea("SRV")
dbSelectArea("RCJ")
dbSelectArea("RCH")
dbSelectArea("SRY")
dbSelectArea("SRA")
dbSelectArea("RCC")

DbSetOrder(1)

Pergunte(cPerg, .F.)
cRot := MV_PAR03

IF Pergunte(cPerg,.T.)
	IF TodoOK()
		IF cOrdemD==3
			OREPORT:=REPORTDEFh()
		ELSE
			OREPORT:=REPORTDEFv()
		ENDIF

		OREPORT:PRINTDIALOG()	
	endif
ENDIF
RestArea(aGetArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportDefV|  Autor³ FMonroy               ³ Data ³26/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Def. Reporte en Vertical, esta definición servira para    ³±±
±±³          ³  construir los siguieentes Reportes de Validación D152:    ³±±
±±³          ³  -Reporte Sintético por Empleado o Concepto.               ³±±
±±³          ³  -Reporte Analítico por Concepto.                          ³±±
±±³          ³  -Reporte Analítico por Empleado.                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDefV()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER006COS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDefV()

Local aArea      := GetArea() 
Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oSection5

Private cTitulo	:=OEMTOANSI(STR0001) //"Reporte de Validación D152"

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
oReport:=TReport():New(cNomeProg,OemToAnsi(cTitulo), /*Pregunta*/  ,{|oReport| PrintReport(oReport)})	
oReport:nColSpace	:= 2
oReport:nFontBody	:= 6 	// Define o tamanho da fonte.
oReport:CFONTBODY	:=	"COURIER NEW"    
oReport:Setlandscape(.f.)//Vertical
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
//³ Definición de la Primera Sección: Encabezado                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

oSection1:= TRSection():New(oReport,"Encabezado",,/*aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.F.)		//Exibe Cabecalho da Secao
oSection1:SetLineStyle(.T.)   		//Pone titulo del campo y aun lado el y valor
OSection1:SetCharSeparator(":") 
   
oSection1:SetLeftMargin(10)

TRCell():New(oSection1,"EMP", ,STR0002,	,100	)	//"Empresa"
TRCell():New(oSection1,"SUC", ,STR0003,	,50		)	//"Sucursal"
TRCell():New(oSection1,"IDE", ,STR0004,	,50		)	//"No Identificación"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definición de la Segunda Sección: Detalle -Reporte Sintético por Emppleado o Concepto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

oSection2:= TRSection():New(oReport,"Detalle1",,/*aOrdem */ ,/*Campos do SX3*/,/*Campos do SIX*/) 

oSection2:SetLineStyle(.F.)   		//Pone titulo del campo y aun lado el y valor
oSection2:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.F.)		//Exibe Cabecalho da Secao
oSection2:SetLeftMargin(10)

TRCell():New(oSection2,"TPRE",	,STR0005	,						,100	)	//"Tipo Remuneración:"
TRCell():New(oSection2,"IMP",	,STR0006	,"999,999,999,999.99"	,15		)	//"Importe"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definición de la Tercera Sección:  Encabezado de Sección de los Reportes:³
//³  *Reporte Analítico por Concepto.			                             ³
//³  *Reporte Analítico por Empleado.           			                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

oSection3:= TRSection():New(oReport,"Detalle2",,/*aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/) 

oSection3:SetLineStyle(.T.)  		//Pone titulo del campo y aun lado el y valor
oSection3:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection3:SetHeaderPage(.F.)	   	//Exibe Cabecalho da Secao
oSection3:SetCharSeparator(":") 
oSection3:SetLeftMargin(10)

TRCell():New(oSection3,"TPRE",	,STR0005	,						,100	)	//"Tipo Remuneración:"
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definición de la Cuarta Sección:  Detalle  de los Reportes:              ³
//³  *Reporte Analítico por Concepto.			                             ³
//³  *Reporte Analítico por Empleado.           			                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

oSection4:= TRSection():New(oReport,"Detalle3",,/*aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/) 

oSection4:SetLineStyle(.F.)		//Pone titulo del campo y aun lado el y valor
oSection4:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection4:SetHeaderPage(.F.)		//Exibe Cabecalho da Secao
oSection4:SetLeftMargin(10)
TRCell():New(oSection4,"RC_PD",  cAliasRG7	,STR0006, 						,TamSx3("RC_PD")[1])	//Concepto
TRCell():New(oSection4,"RV_DESC",cAliasRG7	,STR0007,  					    ,TamSx3("RV_DESC")[1])	//Descripcióm
TRCell():New(oSection4,"RC_VALOR",	cAliasRG7,STR0008,"999,999,999,999.99"   	,15)				//Importe

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definición de la Quinta Sección:  Encabezado de la sección del Reporte:  ³
//³  *Reporte Analítico por Empleado.           			                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

oSection5:= TRSection():New(oReport,"Detalle4",,/*aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/) 

oSection5:SetLineStyle(.F.)   		//Pone titulo del campo y aun lado el y valor
oSection5:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection5:SetHeaderPage(.F.)		//Exibe Cabecalho da Secao
oSection5:SetLeftMargin(10)

TRCell():New(oSection5,"RA_MAT",	,STR0009,   ,TamSx3("RA_MAT")[1])//"Matricula"
TRCell():New(oSection5,"RA_NOME",	,STR0010,   ,TamSx3("RA_NOME")[1]+5)//"Nombre"
TRCell():New(oSection5,"RA_CIC",	,STR0011,   ,TamSx3("RA_CIC")[1])//"No Identidicación"

Return( oReport )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportDefH|  Autor³ FMonroy               ³ Data ³26/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Def. Reporte en Horizontal, esta definición servira para  ³±±
±±³          ³  construir los siguieentes Reportes de Validación D152:    ³±±
±±³          ³  -Reporte Sintético por Mes.                               ³±±
±±³          ³  -Reporte Analítico por Mes.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportDefH()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER006COS                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDefH()

Local aArea      := GetArea() 

Local oReport
Local oSection1
Local oSection2
Local oSection3
Local oSection4

Private cTitulo	:=OEMTOANSI(STR0001) // "Reporte de Validación D152"

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
oReport:=TReport():New(cNomeProg,OemToAnsi(cTitulo),/*cNomeProg*/  ,{|oReport| PrintReport(oReport)})	
oReport:nColSpace	:= 0
oReport:nFontBody	:= 5.5 	// Define o tamanho da fonte.
oReport:CFONTBODY	:=	"COURIER NEW"
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
//³ Definición de la Primera Sección: Encabezado                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

oSection1:= TRSection():New(oReport,"Detalle1",,/*aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/)
oSection1:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.F.)		//Exibe Cabecalho da Secao
oSection1:SetLineStyle(.T.)   		//Pone titulo del campo y aun lado el y valor
OSection1:SetCharSeparator(":") 

TRCell():New(oSection1,"EMP", ,STR0002,	,100	)	//"Empresa"
TRCell():New(oSection1,"SUC", ,STR0003, ,50		)	//"Sucursal"
TRCell():New(oSection1,"IDE", ,STR0004,	,50		)	//"No Identificación"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definición de la Segunda Sección:  Encabezado de Sección de los Reportes:³
//³  *Reporte Analítico por Mes.			                                 ³
//³  *Reporte Sintético por Mes.           			                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

oSection2:= TRSection():New(oReport,"Detalle2",,/*aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/) 

oSection2:SetLineStyle(.T.)  		//Pone titulo del campo y aun lado el y valor
oSection2:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.F.)	   	//Exibe Cabecalho da Secao
oSection2:SetCharSeparator(":") 

TRCell():New(oSection2,"TPRE",	,STR0005	,						,100	)	//"Tipo Remuneración:"
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definición de la Tercera Sección:  Detalle  de los Reportes:             ³
//³  *Reporte Analítico por Mes.  			                                 ³
//³  *Reporte Sintético por Mes.           			                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

oSection3:= TRSection():New(oReport,"Detalle3",,/*aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/) 

oSection3:SetLineStyle(.F.)		//Pone titulo del campo y aun lado el y valor
oSection3:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection3:SetHeaderPage(.F.)		//Exibe Cabecalho da Secao

TRCell():New(oSection3,"RG7_PD",	cAliasRG7	,STR0006, 						   ,8)	//Concepto
TRCell():New(oSection3,"RV_DESC",	cAliasRG7	,STR0007,  					       ,TamSx3("RV_DESC")[1])	//Descripcióm

TRCell():New(oSection3,"RG7_ACUM01",cAliasRG7	,STR0012	,"@E 999,999,999,999.99"   	,22)				//Importe01
TRCell():New(oSection3,"RG7_ACUM02",cAliasRG7	,STR0013	,"@E 999,999,999,999.99"   	,22)				//Importe02
TRCell():New(oSection3,"RG7_ACUM03",cAliasRG7	,STR0014	,"@E 999,999,999,999.99"   	,22)				//Importe03
TRCell():New(oSection3,"RG7_ACUM04",cAliasRG7	,STR0015	,"@E 999,999,999,999.99"   	,22)				//Importe04
TRCell():New(oSection3,"RG7_ACUM05",cAliasRG7	,STR0016	,"@E 999,999,999,999.99"   	,22)				//Importe05
TRCell():New(oSection3,"RG7_ACUM06",cAliasRG7	,STR0017	,"@E 999,999,999,999.99"   	,22)				//Importe06
TRCell():New(oSection3,"RG7_ACUM07",cAliasRG7	,STR0018	,"@E 999,999,999,999.99"   	,22)				//Importe07
TRCell():New(oSection3,"RG7_ACUM08",cAliasRG7	,STR0019	,"@E 999,999,999,999.99"   	,22)				//Importe08
TRCell():New(oSection3,"RG7_ACUM09",cAliasRG7	,STR0020	,"@E 999,999,999,999.99"   	,22)				//Importe09
TRCell():New(oSection3,"RG7_ACUM10",cAliasRG7	,STR0021	,"@E 999,999,999,999.99"   	,22)				//Importe10
TRCell():New(oSection3,"RG7_ACUM11",cAliasRG7	,STR0022	,"@E 999,999,999,999.99"   	,22)				//Importe11
TRCell():New(oSection3,"RG7_ACUM12",cAliasRG7	,STR0023	,"@E 999,999,999,999.99"   	,22)				//Importe12
TRCell():New(oSection3,"RG7_ACUM13",cAliasRG7	,STR0024	,"@E 999,999,999,999.99"   	,22)				//Importe13

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definición de la Cuarta Sección:  Encabezado de la sección del Reporte:  ³
//³  *Reporte Analítico por Mes.           			                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

oSection4:= TRSection():New(oReport,"Detalle4",,/*aOrdem */,/*Campos do SX3*/,/*Campos do SIX*/) 

oSection4:SetLineStyle(.F.)   		//Pone titulo del campo y aun lado el y valor
oSection4:SetHeaderSection(.t.)	//Exibe Cabecalho da Secao
oSection4:SetHeaderPage(.F.)		//Exibe Cabecalho da Secao

TRCell():New(oSection4,"RA_MAT",	,STR0009,   ,TamSx3("RA_MAT")[1])//"Matricula"
TRCell():New(oSection4,"RA_NOME",	,STR0010,   ,TamSx3("RA_NOME")[1]+5)//"Nombre"
TRCell():New(oSection4,"RA_CIC",	,STR0011,   ,TamSx3("RA_CIC")[1])//"No Identidicación"

RestArea( aArea )

Return( oReport )

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
±±³ Uso      ³  GPER006COS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Obtiene Registro                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
getQuery()
Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Analítico Ordenado por Empleado  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTipoD==1 .And. cOrdemD==1
	    ImpAnaEmp(oReport) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Analítico Ordenado por Concepto  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTipoD==1 .And. cOrdemD==2
		ImpAnaCon(oReport) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Analítico Ordenado por Mes       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTipoD==1 .And. cOrdemD==3
		ImpAnaMes(oReport) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Sintético Ordenado por Empleado o Concepto  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTipoD==2 .And. (cOrdemD==1 .Or. cOrdemD==2) 
		ImpSinEmp(oReport) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Sintético Ordenado por Mes       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case cTipoD==2 .And. cOrdemD==3 
		ImpSinMes(oReport) 
EndCase

(cAliasRG7)->(dbCloseArea()) 

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TodoOK    ºAutor  ³FMonroy             º Data ³  26/07/11   º±±
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

cSuc	:=	MV_PAR01 // Sucursal
cProceso:=	ConvQry(MV_PAR02,"RCJ_CODIGO")// Lista de Procesos 
cNomina	:=	MV_PAR03 // Nomina
cPeriodo:=	MV_PAR04 // Periodo
cNumPag	:=	MV_PAR05 // Numero de Pago
cTipoD	:=	MV_PAR06 // 1=Analitico, 2=Sintetico
cOrdemD	:=	MV_PAR07 // 1= Empleado, 2=Concepto, 3=Mes

Return (.T.)
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
±±³ Uso      ³  GPER006COS                                                   ³±±
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
    cTxt+="'"+SubStr( cLista , nCont , nTamReg )+"',"
NEXT       
cTxt:=substr(cTxt,1,len(cTxt)-1)                                   
Return ( cTxt )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ImpAnaEmp | Autor ³ FMonroy               ³ Data ³27/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Analítico Ordenado por Empleado                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  ImpAnaEmp(oExp1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  oExp1: Objeto TReport                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER006COS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpAnaEmp(oReport) 
Local oSection1	:= 	oReport:Section(1)
Local oSection3	:= 	oReport:Section(3)
Local oSection4	:= 	oReport:Section(4)
Local oSection5	:= 	oReport:Section(5)

Local nTotal	:=	0
Local nPosS020	:=	0 
Local nImportT	:=  0

Local cFilOri	:=	SM0->M0_CODFIL
Local cRemu		:=	""
Local cTitle	:=	""


dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cSuc,.T.))

Pergunte(oReport:GetParam(),.F.)   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitle 	:= If(AllTrim(oReport:Title())==AllTrim(cTitle), OemToansi(cTitulo),oReport:Title())
oReport:SetTitle(cTitle+" - "+STR0026)//"Formato Análitico por Empleado"

Begin Sequence 
	dbSelectArea( cAliasRG7 )
	count to nTotal
	oReport:SetMeter(nTotal) 
	(cAliasRG7)->(DbGoTop()) 
	If (cAliasRG7)->(!Eof())
	
		oSection1:Init()
		
		oSection1:Cell("EMP"):SETVALUE(SM0->M0_CODIGO+Space(2)+SM0->M0_NOMECOM)
		oSection1:Cell("SUC"):SETVALUE(SM0->M0_CODFIL+Space(2)+SM0->M0_FILIAL)
		oSection1:CELL("IDE"):SETVALUE(SM0->M0_CGC)
		
		oSection1:Printline()
		oSection1:Finish()
		oReport:Skipline()
		
		While (cAliasRG7)->(!Eof()) 
		    cMat:=(cAliasRG7)->RC_MAT
			oSection5:Init()
			oSection5:Cell("RA_MAT"):SETVALUE((cAliasRG7)->RC_MAT)
			oSection5:Cell("RA_NOME"):SETVALUE(rtrim((cAliasRG7)->RA_PRINOME) + Space(1) + rtrim((cAliasRG7)->RA_SECNOME) + Space(1)+ rtrim((cAliasRG7)->RA_PRISOBR) + Space(1) + rtrim((cAliasRG7)->RA_SECSOBR))
			oSection5:Cell("RA_CIC"):SETVALUE((cAliasRG7)->RA_CIC)
			oSection5:PrintLine()
			oSection5:Finish()
			oSection3:Init()
			While (cAliasRG7)->(!Eof()) .And. cMat==(cAliasRG7)->RC_MAT
				cRemu:=(cAliasRG7)->RV_DECLANU
				oReport:Skipline()
				nPosS020:=FPOSTAB("S020",(cAliasRG7)->RV_DECLANU,"=",4) 
				If nPosS020 > 0
					oSection3:Cell("TPRE"):SETVALUE((cAliasRG7)->RV_DECLANU+Space(1)+FTABELA("S020",nPosS020,5))
				Else
					oSection3:Cell("TPRE"):SETVALUE(" ")
				Endif
				oSection3:PrintLine()
				oSection4:Init()
				nImportT:=0
				While (cAliasRG7)->(!Eof()) .And. cMat==(cAliasRG7)->RC_MAT .And. cRemu==(cAliasRG7)->RV_DECLANU
					oSection4:Cell("RC_PD"):Setvalue((cAliasRG7)->RC_PD)//"Total"
					oSection4:Cell("RV_DESC"):SetValue((cAliasRG7)->RV_DESC)
					oSection4:Cell("RC_VALOR"):SetValue((cAliasRG7)->RC_VALOR)
					nImportT+=(cAliasRG7)->RC_VALOR
					oSection4:PrintLine()
					(cAliasRG7)->(dbSkip())
					oReport:IncMeter()
				EndDo
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Imprime Totales     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oReport:Skipline()
				oSection4:Cell("RC_PD"):Setvalue(STR0025)//"Total"
				oSection4:Cell("RV_DESC"):SetValue(Space(1))
				oSection4:Cell("RC_VALOR"):SetValue(nImportT)
				oSection4:Printline()
				oSection4:Finish()
				
			EndDo
			oSection3:Finish()
		EndDo
		oSection5:Finish()
		
		
	EndIf
End Sequence
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Volta a empresa anteriormente selecionada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cFilOri,.T.))
cFilAnt := SM0->M0_CODFIL

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ImpAnaCon | Autor ³ FMonroy               ³ Data ³27/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Analítico Ordenado por Concepto                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  ImpAnaCon(oExp1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  oExp1: Objeto TReport                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER006COS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImpAnaCon(oReport) 
Local oSection1	:= 	oReport:Section(1)
Local oSection3	:= 	oReport:Section(3)
Local oSection4	:= 	oReport:Section(4)

Local nTotal	:=	0
Local nPosS020	:=	0 
Local nImportT  :=	0

Local cFilOri	:=	SM0->M0_CODFIL
Local cTitle	:=	""
Local cRemu		:=	""

dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cSuc,.T.))
Pergunte(oReport:GetParam(),.F.)   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitle 	:= If(AllTrim(oReport:Title())==AllTrim(cTitle), OemToansi(cTitulo),oReport:Title())
oReport:SetTitle(cTitle+" - "+STR0027)//"Formato Analítico por Concepto"

Begin Sequence 
	dbSelectArea( cAliasRG7 )
	count to nTotal
	oReport:SetMeter(nTotal) 
	(cAliasRG7)->(DbGoTop()) 
	If (cAliasRG7)->(!Eof())
	
		oSection1:Init()
		oSection1:Cell("EMP"):SETVALUE(SM0->M0_CODIGO+Space(2)+SM0->M0_NOMECOM)
		oSection1:Cell("SUC"):SETVALUE(SM0->M0_CODFIL+Space(2)+SM0->M0_FILIAL)
		oSection1:CELL("IDE"):SETVALUE(SM0->M0_CGC)
		oSection1:Printline()
		oSection1:Finish()
		oReport:Skipline()
		
		oSection3:Init()
		While (cAliasRG7)->(!Eof()) 
		    cRemu:=(cAliasRG7)->RV_DECLANU
			oReport:Skipline()
			nPosS020:=FPOSTAB("S020",(cAliasRG7)->RV_DECLANU,"=",4)                 
			If nPosS020 > 0
				oSection3:Cell("TPRE"):SETVALUE((cAliasRG7)->RV_DECLANU+Space(1)+FTABELA("S020",nPosS020,5))
			Else 
				oSection3:Cell("TPRE"):SETVALUE(" ")			
			Endif
			oSection3:PrintLine()
			oSection4:Init()
			nImportT:=0
			While (cAliasRG7)->(!Eof()) .And. cRemu==(cAliasRG7)->RV_DECLANU
				oSection4:Cell("RC_PD"):Setvalue((cAliasRG7)->RC_PD)//"Total"
				oSection4:Cell("RV_DESC"):SetValue((cAliasRG7)->RV_DESC)
				oSection4:Cell("RC_VALOR"):SetValue((cAliasRG7)->RC_VALOR)
				nImportT+=(cAliasRG7)->RC_VALOR
				oSection4:PrintLine()
				(cAliasRG7)->(dbSkip())
				oReport:IncMeter()
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime Totales     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:Skipline()
			oSection4:Cell("RC_PD"):Setvalue(STR0025)//"Total"
			oSection4:Cell("RV_DESC"):SetValue(Space(1))
			oSection4:Cell("RC_VALOR"):SetValue(nImportT)
			oSection4:Printline()
			oSection4:Finish()
		EndDo
		oSection3:Finish()
		
	EndIf
End Sequence
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Volta a empresa anteriormente selecionada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cFilOri,.T.))
cFilAnt := SM0->M0_CODFIL
Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ImpAnaMes | Autor ³ FMonroy               ³ Data ³27/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Analítico Ordenado por Mes                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  ImpAnaMes(oExp1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  oExp1: Objeto TReport                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER006COS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function	ImpAnaMes(oReport) 

Local oSection1	:= 	oReport:Section(1)
Local oSection2	:= 	oReport:Section(2)
Local oSection3	:= 	oReport:Section(3)
Local oSection4	:= 	oReport:Section(4)

Local nTotal	:=	0
Local nPosS020	:=	0 

Local cFilOri	:=	SM0->M0_CODFIL
Local cRemu		:=	""
Local cTitle	:=	""

Local aImporT	:= {0,0,0,0,0,0,0,0,0,0,0,0,0}

dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cSuc,.T.))
Pergunte(oReport:GetParam(),.F.)   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitle 	:= If(AllTrim(oReport:Title())==AllTrim(cTitle), OemToansi(cTitulo),oReport:Title())
oReport:SetTitle(cTitle+" - "+STR0028)//"Formato Analítico por Mes"

Begin Sequence 
	dbSelectArea( cAliasRG7 )
	count to nTotal
	oReport:SetMeter(nTotal) 
	(cAliasRG7)->(DbGoTop()) 
	If (cAliasRG7)->(!Eof())
	
		oSection1:Init()		
		oSection1:Cell("EMP"):SETVALUE(SM0->M0_CODIGO+Space(2)+SM0->M0_NOMECOM)
		oSection1:Cell("SUC"):SETVALUE(SM0->M0_CODFIL+Space(2)+SM0->M0_FILIAL)
		oSection1:CELL("IDE"):SETVALUE(SM0->M0_CGC)
		oSection1:Printline()
		oSection1:Finish()
		
		oReport:Skipline()
		
		
		While (cAliasRG7)->(!Eof()) 
		    cMat:=(cAliasRG7)->RG7_MAT
			oSection4:Init()
			oSection4:Cell("RA_MAT"):SETVALUE((cAliasRG7)->RG7_MAT)
			oSection4:Cell("RA_NOME"):SETVALUE(rtrim((cAliasRG7)->RA_PRINOME) + Space(1) + rtrim((cAliasRG7)->RA_SECNOME) + Space(1)+ rtrim((cAliasRG7)->RA_PRISOBR) + Space(1) + rtrim((cAliasRG7)->RA_SECSOBR))
			oSection4:Cell("RA_CIC"):SETVALUE((cAliasRG7)->RA_CIC)
			oSection4:PrintLine()
			oSection4:Finish()
			oSection2:Init()
			While (cAliasRG7)->(!Eof()) .And. cMat==(cAliasRG7)->RG7_MAT
				cRemu:=(cAliasRG7)->RV_DECLANU
				nPosS020:=FPOSTAB("S020",(cAliasRG7)->RV_DECLANU,"=",4)
				oReport:skipline()                                                      
				If nPosS020 > 0
					oSection2:Cell("TPRE"):SETVALUE((cAliasRG7)->RV_DECLANU+Space(1)+FTABELA("S020",nPosS020,5))
				Else 
					oSection2:Cell("TPRE"):SETVALUE(" ")
				Endif
				oSection2:PrintLine()
				oSection3:Init()
				aImporT	:= {0,0,0,0,0,0,0,0,0,0,0,0,0}
				While (cAliasRG7)->(!Eof()).And. cMat==(cAliasRG7)->RG7_MAT .And. cRemu==(cAliasRG7)->RV_DECLANU
				
					oSection3:Cell("RG7_PD"):SETVALUE((cAliasRG7)->RG7_PD)
					oSection3:Cell("RV_DESC"):SETVALUE((cAliasRG7)->RV_DESC)
					oSection3:Cell("RG7_ACUM01"):SETVALUE((cAliasRG7)->RG7_ACUM01)
					oSection3:Cell("RG7_ACUM02"):SETVALUE((cAliasRG7)->RG7_ACUM02)
					oSection3:Cell("RG7_ACUM03"):SETVALUE((cAliasRG7)->RG7_ACUM03)
					oSection3:Cell("RG7_ACUM04"):SETVALUE((cAliasRG7)->RG7_ACUM04)
					oSection3:Cell("RG7_ACUM05"):SETVALUE((cAliasRG7)->RG7_ACUM05)
					oSection3:Cell("RG7_ACUM06"):SETVALUE((cAliasRG7)->RG7_ACUM06)
					oSection3:Cell("RG7_ACUM07"):SETVALUE((cAliasRG7)->RG7_ACUM07)
					oSection3:Cell("RG7_ACUM08"):SETVALUE((cAliasRG7)->RG7_ACUM08)
					oSection3:Cell("RG7_ACUM09"):SETVALUE((cAliasRG7)->RG7_ACUM09)
					oSection3:Cell("RG7_ACUM10"):SETVALUE((cAliasRG7)->RG7_ACUM10)
					oSection3:Cell("RG7_ACUM11"):SETVALUE((cAliasRG7)->RG7_ACUM11)
					oSection3:Cell("RG7_ACUM12"):SETVALUE((cAliasRG7)->RG7_ACUM12)
					oSection3:Cell("RG7_ACUM13"):SETVALUE((cAliasRG7)->RG7_ACUM13)
				
					aImporT[1]:=aImporT[1]+(cAliasRG7)->RG7_ACUM01
					aImporT[2]:=aImporT[2]+(cAliasRG7)->RG7_ACUM02
					aImporT[3]:=aImporT[3]+(cAliasRG7)->RG7_ACUM03
					aImporT[4]:=aImporT[4]+(cAliasRG7)->RG7_ACUM04
					aImporT[5]:=aImporT[5]+(cAliasRG7)->RG7_ACUM05
					aImporT[6]:=aImporT[6]+(cAliasRG7)->RG7_ACUM06
					aImporT[7]:=aImporT[7]+(cAliasRG7)->RG7_ACUM07
					aImporT[8]:=aImporT[8]+(cAliasRG7)->RG7_ACUM08
					aImporT[9]:=aImporT[9]+(cAliasRG7)->RG7_ACUM09
					aImporT[10]:=aImporT[10]+(cAliasRG7)->RG7_ACUM10
					aImporT[11]:=aImporT[11]+(cAliasRG7)->RG7_ACUM11
					aImporT[12]:=aImporT[12]+(cAliasRG7)->RG7_ACUM12
					aImporT[13]:=aImporT[13]+(cAliasRG7)->RG7_ACUM13
					oSection3:PrintLine()
					(cAliasRG7)->(dbSkip())
					oReport:IncMeter()
				EndDo
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Imprime Totales     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oReport:skipline()
				oSection3:Cell("RG7_PD"):SetValue(STR0025)//"Total"
				oSection3:Cell("RV_DESC"):SetValue(Space(1))
				oSection3:Cell("RG7_ACUM01"):SetValue(aImporT[1])
				oSection3:Cell("RG7_ACUM02"):SetValue(aImporT[2])
				oSection3:Cell("RG7_ACUM03"):SetValue(aImporT[3])
				oSection3:Cell("RG7_ACUM04"):SetValue(aImporT[4])
				oSection3:Cell("RG7_ACUM05"):SetValue(aImporT[5])
				oSection3:Cell("RG7_ACUM06"):SetValue(aImporT[6])
				oSection3:Cell("RG7_ACUM07"):SetValue(aImporT[7])
				oSection3:Cell("RG7_ACUM08"):SetValue(aImporT[8])
				oSection3:Cell("RG7_ACUM09"):SetValue(aImporT[9])
				oSection3:Cell("RG7_ACUM10"):SetValue(aImporT[10])
				oSection3:Cell("RG7_ACUM11"):SetValue(aImporT[11])
				oSection3:Cell("RG7_ACUM12"):SetValue(aImporT[12])
				oSection3:Cell("RG7_ACUM13"):SetValue(aImporT[13])
				oSection3:PrintLine()
				oSection3:Finish()
			EndDo
			oSection2:Finish()
		EndDo
		oSection4:Finish()
	EndIf
End Sequence
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Volta a empresa anteriormente selecionada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cFilOri,.T.))
cFilAnt := SM0->M0_CODFIL

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ImpSinEmp | Autor ³ FMonroy               ³ Data ³27/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Sintético Ordenado por Empleado o Concepto                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  ImpSinEmp(oExp1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  oExp1: Objeto TReport                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER006COS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function	ImpSinEmp(oReport) 
Local oSection1	:= 	oReport:Section(1)
Local oSection2	:= 	oReport:Section(2)

Local nTotal	:=	0
Local nPosS020	:=	0 

Local cFilOri	:=	SM0->M0_CODFIL
Local cTitle	:=	""

dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cSuc,.T.))
Pergunte(oReport:GetParam(),.F.)   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitle 	:= If(AllTrim(oReport:Title())==AllTrim(cTitle), OemToansi(cTitulo),oReport:Title())
oReport:SetTitle(cTitle+" - "+STR0029)//"Formato Sintético por Empleado o Concepto"
Begin Sequence 
	dbSelectArea( cAliasRG7 )
	count to nTotal
	oReport:SetMeter(nTotal) 
	(cAliasRG7)->(DbGoTop()) 
	If (cAliasRG7)->(!Eof())
	
		oSection1:Init()		
		oSection1:Cell("EMP"):SETVALUE(SM0->M0_CODIGO+Space(2)+SM0->M0_NOMECOM)
		oSection1:Cell("SUC"):SETVALUE(SM0->M0_CODFIL+Space(2)+SM0->M0_FILIAL)
		oSection1:CELL("IDE"):SETVALUE(SM0->M0_CGC)
		oSection1:Printline()
		oSection1:Finish()
		oReport:Skipline()
		
		oSection2:Init()
		While (cAliasRG7)->(!Eof()) 
			nPosS020:=FPOSTAB("S020",(cAliasRG7)->RV_DECLANU,"=",4)                 
			If nPosS020 > 0
				oSection2:Cell("TPRE"):SETVALUE((cAliasRG7)->RV_DECLANU+Space(1)+FTABELA("S020",nPosS020,5))
			Else 
				oSection2:Cell("TPRE"):SETVALUE(" ")
			Endif
			oSection2:Cell("IMP"):SETVALUE((cAliasRG7)->RC_VALOR)
			oSection2:PrintLine()
			(cAliasRG7)->(dbSkip())
			oReport:IncMeter()
		EndDo
		oSection2:Finish()
	EndIf
End Sequence
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Volta a empresa anteriormente selecionada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cFilOri,.T.))
cFilAnt := SM0->M0_CODFIL

Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ImpSinMes | Autor ³ FMonroy               ³ Data ³27/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Sintético Ordenado por Mes                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  ImpSinMes(oExp1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  oExp1: Objeto TReport                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER006COS                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function	ImpSinMes(oReport) 

Local oSection1	:= 	oReport:Section(1)
Local oSection2	:= 	oReport:Section(2)
Local oSection3	:= 	oReport:Section(3)

Local nTotal	:=	0
Local nPosS020	:=	0 

Local cFilOri	:=	SM0->M0_CODFIL
Local cRemu		:=	""
Local cTitle	:=	""

Local aImporT	:= {0,0,0,0,0,0,0,0,0,0,0,0,0}

dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cSuc,.T.))
Pergunte(oReport:GetParam(),.F.)   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitle 	:= If(AllTrim(oReport:Title())==AllTrim(cTitle), OemToansi(cTitulo),oReport:Title())
oReport:SetTitle(cTitle+" - "+STR0030)//"Formato Sintético por Mes"


Begin Sequence 
	dbSelectArea( cAliasRG7 )
	count to nTotal
	oReport:SetMeter(nTotal) 
	(cAliasRG7)->(DbGoTop()) 
	If (cAliasRG7)->(!Eof())
	
		oSection1:Init()
		
		oSection1:Cell("EMP"):SETVALUE(SM0->M0_CODIGO+Space(2)+SM0->M0_NOMECOM)
		oSection1:Cell("SUC"):SETVALUE(SM0->M0_CODFIL+Space(2)+SM0->M0_FILIAL)
		oSection1:CELL("IDE"):SETVALUE(SM0->M0_CGC)
		
		oSection1:Printline()
		oSection1:Finish()
		oReport:Skipline()
		
		oSection2:Init()
		
		While (cAliasRG7)->(!Eof()) 
		    cRemu:=(cAliasRG7)->RV_DECLANU
			oReport:skipline()
			nPosS020:=FPOSTAB("S020",(cAliasRG7)->RV_DECLANU,"=",4)                 
			If nPosS020 > 0
				oSection2:Cell("TPRE"):SETVALUE((cAliasRG7)->RV_DECLANU+Space(1)+FTABELA("S020",nPosS020,5))
			Else 
				oSection2:Cell("TPRE"):SETVALUE(" ")
			Endif
			oSection2:PrintLine()
			oSection3:Init()
			aImporT	:= {0,0,0,0,0,0,0,0,0,0,0,0,0}
			While (cAliasRG7)->(!Eof()) .And. cRemu==(cAliasRG7)->RV_DECLANU
				oSection3:Cell("RG7_PD"):SETVALUE((cAliasRG7)->RG7_PD)
				oSection3:Cell("RV_DESC"):SETVALUE((cAliasRG7)->RV_DESC)
				oSection3:Cell("RG7_ACUM01"):SETVALUE((cAliasRG7)->RG7_ACUM01)
				oSection3:Cell("RG7_ACUM02"):SETVALUE((cAliasRG7)->RG7_ACUM02)
				oSection3:Cell("RG7_ACUM03"):SETVALUE((cAliasRG7)->RG7_ACUM03)
				oSection3:Cell("RG7_ACUM04"):SETVALUE((cAliasRG7)->RG7_ACUM04)
				oSection3:Cell("RG7_ACUM05"):SETVALUE((cAliasRG7)->RG7_ACUM05)
				oSection3:Cell("RG7_ACUM06"):SETVALUE((cAliasRG7)->RG7_ACUM06)
				oSection3:Cell("RG7_ACUM07"):SETVALUE((cAliasRG7)->RG7_ACUM07)
				oSection3:Cell("RG7_ACUM08"):SETVALUE((cAliasRG7)->RG7_ACUM08)
				oSection3:Cell("RG7_ACUM09"):SETVALUE((cAliasRG7)->RG7_ACUM09)
				oSection3:Cell("RG7_ACUM10"):SETVALUE((cAliasRG7)->RG7_ACUM10)
				oSection3:Cell("RG7_ACUM11"):SETVALUE((cAliasRG7)->RG7_ACUM11)
				oSection3:Cell("RG7_ACUM12"):SETVALUE((cAliasRG7)->RG7_ACUM12)
				oSection3:Cell("RG7_ACUM13"):SETVALUE((cAliasRG7)->RG7_ACUM13)
				
				aImporT[1]:=aImporT[1]+(cAliasRG7)->RG7_ACUM01
				aImporT[2]:=aImporT[2]+(cAliasRG7)->RG7_ACUM02
				aImporT[3]:=aImporT[3]+(cAliasRG7)->RG7_ACUM03
				aImporT[4]:=aImporT[4]+(cAliasRG7)->RG7_ACUM04
				aImporT[5]:=aImporT[5]+(cAliasRG7)->RG7_ACUM05
				aImporT[6]:=aImporT[6]+(cAliasRG7)->RG7_ACUM06
				aImporT[7]:=aImporT[7]+(cAliasRG7)->RG7_ACUM07
				aImporT[8]:=aImporT[8]+(cAliasRG7)->RG7_ACUM08
				aImporT[9]:=aImporT[9]+(cAliasRG7)->RG7_ACUM09
				aImporT[10]:=aImporT[10]+(cAliasRG7)->RG7_ACUM10
				aImporT[11]:=aImporT[11]+(cAliasRG7)->RG7_ACUM11
				aImporT[12]:=aImporT[12]+(cAliasRG7)->RG7_ACUM12
				aImporT[13]:=aImporT[13]+(cAliasRG7)->RG7_ACUM13
				
				oSection3:PrintLine()
				(cAliasRG7)->(dbSkip())
				oReport:IncMeter()
			EndDo
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Imprime Totales     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:skipline()
			oSection3:Cell("RG7_PD"):SetValue(STR0025)//"Total"
			oSection3:Cell("RV_DESC"):SetValue(Space(1))
			oSection3:Cell("RG7_ACUM01"):SetValue(aImporT[1])
			oSection3:Cell("RG7_ACUM02"):SetValue(aImporT[2])
			oSection3:Cell("RG7_ACUM03"):SetValue(aImporT[3])
			oSection3:Cell("RG7_ACUM04"):SetValue(aImporT[4])
			oSection3:Cell("RG7_ACUM05"):SetValue(aImporT[5])
			oSection3:Cell("RG7_ACUM06"):SetValue(aImporT[6])
			oSection3:Cell("RG7_ACUM07"):SetValue(aImporT[7])
			oSection3:Cell("RG7_ACUM08"):SetValue(aImporT[8])
			oSection3:Cell("RG7_ACUM09"):SetValue(aImporT[9])
			oSection3:Cell("RG7_ACUM10"):SetValue(aImporT[10])
			oSection3:Cell("RG7_ACUM11"):SetValue(aImporT[11])
			oSection3:Cell("RG7_ACUM12"):SetValue(aImporT[12])
			oSection3:Cell("RG7_ACUM13"):SetValue(aImporT[13])
			oSection3:PrintLine()
			oSection3:Finish()
			
		EndDo
		oSection2:Finish()
		
	EndIf
End Sequence
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Volta a empresa anteriormente selecionada.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SM0")
SM0->(dbSeek(cEmpAnt+cFilOri,.T.))
cFilAnt := SM0->M0_CODFIL


Return ( Nil )
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³getQuery  | Autor ³ FMonroy               ³ Data ³27/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Obtención de Datos, Según el tipo de reporte seleccionado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  getQuery()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER006COS                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function getQuery()
Local aArea		:= GetArea()
Local cQuery 	:= ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Analítico Ordenado por Empleado  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cTipoD == 1 .And. cOrdemD == 1)
	
		cQuery := " SELECT SRC.RC_FILIAL,SRC.RC_MAT,SRA.RA_NOME,SRA.RA_CIC,SRC.RC_PD,SRV.RV_DESC,SRV.RV_DECLANU, SUM(SRC.RC_VALOR) RC_VALOR,SRA.RA_PRINOME,SRA.RA_SECNOME, SRA.RA_PRISOBR,SRA.RA_SECSOBR"
		cQuery += " FROM " + RetSqlName("SRC") + " SRC "
		cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV "
		cQuery += " ON SRC.RC_PD = SRV.RV_COD AND SRV.RV_FILIAL = '"+XFILIAL("SRV",SRC->RC_FILIAL)+"' AND SRV.RV_DECLANU<>''  "
		cQuery += " INNER JOIN " + RetSqlName("SRA") + " SRA "
		cQuery += " ON SRA.RA_MAT = SRC.RC_MAT AND SRA.RA_FILIAL = '"+XFILIAL("SRA",SRC->RC_FILIAL)+"' "
		cQuery += " WHERE SRC.RC_FILIAL = '" + cSuc+ "' "
		cQuery += " 		AND SRC.RC_PROCES IN( "+  cProceso +") "
		cQuery += " 		AND SRC.RC_PERIODO = '"+ cPeriodo +"' "
		cQuery += " 		AND SRC.RC_SEMANA = '"+ cNumPag +"' "
		cQuery += " 		AND SRC.RC_ROTEIR = '"+ cNomina +"' "
		cQuery += " AND SRC.D_E_L_E_T_ <> '*' AND SRV.D_E_L_E_T_ <> '*' "
		cQuery += " GROUP BY SRC.RC_FILIAL,SRC.RC_MAT,SRA.RA_NOME,SRA.RA_CIC,SRV.RV_DECLANU,SRC.RC_PD,SRV.RV_DESC,SRA.RA_PRINOME,SRA.RA_SECNOME, SRA.RA_PRISOBR,SRA.RA_SECSOBR " 
		cQuery += " ORDER BY SRA.RA_CIC,SRC.RC_FILIAL,SRC.RC_MAT,SRA.RA_NOME,SRV.RV_DECLANU,SRC.RC_PD "
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Analítico Ordenado por Concepto  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf (cTipoD == 1 .And. cOrdemD == 2)
	
		cQuery := " SELECT SRC.RC_FILIAL,SRC.RC_PD,SRV.RV_DESC,SRV.RV_DECLANU, SUM(SRC.RC_VALOR) RC_VALOR"
		cQuery += " FROM " + RetSqlName("SRC") + " SRC "
		cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV "
		cQuery += " ON SRC.RC_PD = SRV.RV_COD AND SRV.RV_FILIAL = '"+XFILIAL("SRV",SRC->RC_FILIAL)+"' AND SRV.RV_DECLANU<>''  "
		cQuery += " WHERE SRC.RC_FILIAL = '" + cSuc+ "'"
		cQuery += " 		AND SRC.RC_PROCES IN ( "+  cProceso +") "
		cQuery += " 		AND SRC.RC_PERIODO = '"+ cPeriodo +"' "
		cQuery += " 		AND SRC.RC_SEMANA = '"+ cNumPag +"' "
		cQuery += " 		AND SRC.RC_ROTEIR = '"+ cNomina +"' "
		cQuery += " AND SRC.D_E_L_E_T_ <> '*' AND SRV.D_E_L_E_T_ <> '*' "
		cQuery += " GROUP BY SRC.RC_FILIAL,SRV.RV_DECLANU,SRC.RC_PD,SRV.RV_DESC " 
		cQuery += " ORDER BY SRC.RC_FILIAL,SRV.RV_DECLANU,SRC.RC_PD,SRV.RV_DESC " 
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Analítico Ordenado por Mes       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf (cTipoD == 1 .And. cOrdemD == 3)
	
		cQuery := "SELECT RG7.RG7_MAT,SRA.RA_NOME,SRA.RA_CIC,RG7.RG7_PD, SUM(RG7.RG7_ACUM01) RG7_ACUM01, SUM(RG7.RG7_ACUM02) RG7_ACUM02, SUM(RG7.RG7_ACUM03) RG7_ACUM03,SUM( RG7.RG7_ACUM04) RG7_ACUM04"
		cQuery += "      ,SUM(RG7.RG7_ACUM05) RG7_ACUM05, SUM(RG7.RG7_ACUM06) RG7_ACUM06, SUM(RG7.RG7_ACUM07) RG7_ACUM07, SUM(RG7.RG7_ACUM08) RG7_ACUM08, SUM(RG7.RG7_ACUM09) RG7_ACUM09 "
		cQuery += "      ,SUM(RG7.RG7_ACUM10) RG7_ACUM10, SUM(RG7.RG7_ACUM11) RG7_ACUM11, SUM(RG7.RG7_ACUM12) RG7_ACUM12, SUM(RG7.RG7_ACUM13) RG7_ACUM13, SRV.RV_DECLANU "
		cQuery += "      ,SRV.RV_DESC,SRA.RA_PRINOME,SRA.RA_SECNOME, SRA.RA_PRISOBR,SRA.RA_SECSOBR "		
		cQuery += "FROM " +RetSQLName("RG7")+ " RG7, " 
		cQuery +=          RetSQLName("SRA")+ " SRA, " 
		cQuery +=          RetSQLName("SRV")+ " SRV, " 
		cQuery +=     	   RetSqlName("RCH")+ " RCH  "
		cQuery += "WHERE "

		cQuery += "  	SRA.RA_FILIAL ='"+XFILIAL("SRA",RG7->RG7_FILIAL)+"' "
		cQuery += "  AND SRA.RA_MAT = RG7.RG7_MAT "
		cQuery += "  AND SRV.RV_FILIAL ='"+XFILIAL("SRV",RG7->RG7_FILIAL)+"' "
		cQuery += "  AND SRV.RV_COD = RG7.RG7_PD AND SRV.RV_DECLANU<>'' "
		
		cQuery += "  AND RG7.RG7_FILIAL = SRA.RA_FILIAL"
		cQuery += "  AND RG7.RG7_MAT = SRA.RA_MAT"
		cQuery += "  AND RG7.RG7_PROCES = RCH.RCH_PROCES "
		cQuery += "  AND RG7.RG7_ANOINI = YEAR(RCH.RCH_DTINI)"
		cQuery += "  AND RG7.RG7_ANOFIM = YEAR(RCH.RCH_DTFIM)"		
		
		cQuery += " 	AND RCH.RCH_PROCES IN( "+ cProceso +") "
		cQuery += " 	AND RCH.RCH_PER = '"+ cPeriodo +"' "
		cQuery += " 	AND RCH.RCH_NUMPAG = '"+ cNumPag +"' "
		cQuery += " 	AND RCH.RCH_ROTEIR = '"+ cNomina +"' "
		
		cQuery += "  AND RG7.D_E_L_E_T_  = ' ' "
		cQuery += "  AND SRA.D_E_L_E_T_  = ' ' "
		cQuery += "  AND SRV.D_E_L_E_T_  = ' ' "
		cQuery += "  AND RCH.D_E_L_E_T_  = ' ' "
	    cQuery += " GROUP BY SRV.RV_DECLANU,RG7.RG7_PD,RG7.RG7_MAT,SRA.RA_NOME,SRA.RA_CIC,SRV.RV_DESC , SRA.RA_PRINOME,SRA.RA_SECNOME, SRA.RA_PRISOBR,SRA.RA_SECSOBR" 
	    cQuery += " ORDER BY SRA.RA_CIC,RG7.RG7_MAT,SRV.RV_DECLANU,RG7.RG7_PD" 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Sintético Ordenado por Empleado o Concepto  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf (cTipoD == 2 .And. (cOrdemD == 1 .Or. cOrdemD == 2))
		cQuery := " SELECT SRC.RC_FILIAL,SRV.RV_DECLANU, SUM(SRC.RC_VALOR) RC_VALOR"
		cQuery += " FROM " + RetSqlName("SRC") + " SRC "
		cQuery += " INNER JOIN " + RetSqlName("SRV") + " SRV "
		cQuery += " ON SRC.RC_PD = SRV.RV_COD AND SRV.RV_FILIAL ='"+XFILIAL("SRV",SRC->RC_FILIAL)+"' AND SRV.RV_DECLANU<>''  "	
		cQuery += " INNER JOIN " + RetSqlName("SRA") + " SRA "
		cQuery += " ON SRA.RA_MAT = SRC.RC_MAT AND SRA.RA_FILIAL ='"+XFILIAL("SRA",SRC->RC_FILIAL)+"'"
		cQuery += " WHERE SRC.RC_FILIAL = '" + cSuc+ "' "
		cQuery += " 		AND SRC.RC_PROCES IN ( "+ cProceso +") "
		cQuery += " 		AND SRC.RC_PERIODO = '"+ cPeriodo +"' "
		cQuery += " 		AND SRC.RC_SEMANA = '"+ cNumPag +"' "
		cQuery += " 		AND SRC.RC_ROTEIR = '"+ cNomina +"' "
		cQuery += " AND SRC.D_E_L_E_T_ <> '*' AND SRV.D_E_L_E_T_ <> '*' "
		cQuery += " GROUP BY SRC.RC_FILIAL,SRV.RV_DECLANU " 
		cQuery += " ORDER BY SRC.RC_FILIAL,SRV.RV_DECLANU " 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Sintético Ordenado por Mes       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ElseIf (cTipoD == 2 .And. cOrdemD == 3)
	 	
		cQuery := "SELECT RG7.RG7_PD, SUM(RG7.RG7_ACUM01) RG7_ACUM01, SUM(RG7.RG7_ACUM02) RG7_ACUM02, SUM(RG7.RG7_ACUM03) RG7_ACUM03,SUM( RG7.RG7_ACUM04) RG7_ACUM04"
		cQuery += "      ,SUM(RG7.RG7_ACUM05) RG7_ACUM05, SUM(RG7.RG7_ACUM06) RG7_ACUM06, SUM(RG7.RG7_ACUM07) RG7_ACUM07, SUM(RG7.RG7_ACUM08) RG7_ACUM08, SUM(RG7.RG7_ACUM09) RG7_ACUM09 "
		cQuery += "      ,SUM(RG7.RG7_ACUM10) RG7_ACUM10, SUM(RG7.RG7_ACUM11) RG7_ACUM11, SUM(RG7.RG7_ACUM12) RG7_ACUM12, SUM(RG7.RG7_ACUM13) RG7_ACUM13, SRV.RV_DECLANU "
		cQuery += "      ,SRV.RV_DESC "		
		cQuery += "FROM " +RetSQLName("RG7")+ " RG7, " 
		cQuery +=          RetSQLName("SRV")+ " SRV, " 
		cQuery +=     	   RetSqlName("RCH")+ " RCH  "
		cQuery += "WHERE "            
		
		cQuery += "  SRV.RV_FILIAL ='"+XFILIAL("SRV",RG7->RG7_FILIAL)+"' "
		cQuery += "  AND SRV.RV_COD = RG7.RG7_PD AND SRV.RV_DECLANU<>'' "
		
		//cQuery += "  AND RG7.RG7_PROCES = RCH.RCH_PROCES "
		cQuery += "  AND RG7.RG7_ANOINI = YEAR(RCH.RCH_DTINI)"
		cQuery += "  AND RG7.RG7_ANOFIM = YEAR(RCH.RCH_DTFIM)"		
		
		cQuery += " 	AND RCH.RCH_PROCES IN( "+ cProceso +") "
		cQuery += " 	AND RCH.RCH_PER = '"+ cPeriodo +"' "
		cQuery += " 	AND RCH.RCH_NUMPAG = '"+ cNumPag +"' "
		cQuery += " 	AND RCH.RCH_ROTEIR = '"+ cNomina +"' "

		cQuery += "  AND RG7.D_E_L_E_T_  = ' ' "
		cQuery += "  AND SRV.D_E_L_E_T_  = ' ' "
		cQuery += "  AND RCH.D_E_L_E_T_  = ' ' "
	    cQuery += " GROUP BY SRV.RV_DECLANU,RG7.RG7_PD,SRV.RV_DESC" 
	    cQuery += " ORDER BY SRV.RV_DECLANU,RG7.RG7_PD,SRV.RV_DESC" 
		
EndIf
        
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRG7,.T.,.T.)
RestArea( aArea )
Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Gpr006Roteiro³ Autor ³ Christiane Vieira     ³ Data ³30/11/11³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a descricao do roteiro selecionado na pergunte.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ GPER006COS                                                  ³±±
±±³    		 ³                                               			   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function Gpr006Roteiro()

Local lRet := .T.

lRet := ExistCpo("SRY", MV_PAR03)

cRot := MV_PAR03

Return ( lRet )