#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "FISR088.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FISR088  ³ Autor ³ Gpe Santacruz         ³ Data ³21/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Informe de DIOT                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FISR088                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³17/05/18³DMINA-2612³En Fun PrintReport por cada sucursal  ³±±
±±³            ³        ³          ³se crea un query asignando UNION ALL  ³±±
±±³            ³        ³          ³para uso de Xfilial en tablas con dif.³±± 
±±³            ³        ³          ³permisos en tablas SA2 y CE8 (Exclusi-³±± 
±±³            ³        ³          ³vas vs Compartidas)                   ³±±
±±³Alf. Medrano³21/05/18³DMINA-3163³En fun PrintReport se asigna Order by ³±±
±±³            ³        ³          ³al Final de query para Union ALL      ³±±
±±³LuisEnríquez³14/03/19³DMINA-6191³Se agrega columna para impresión del  ³±±
±±³            ³        ³          ³campo CE8_BASE8 de IVA Fronterizo del ³±±
±±³            ³        ³          ³8% para tipo analítico y resumen.(MEX)³±±
±±³  Marco A.  ³02/09/19³DMINA-7263³Se realizan cambios para evitar error ³±±
±±³            ³        ³          ³en impresion de Base 8 de IVA y se    ³±±
±±³            ³        ³          ³depura el fuente. (MEX)               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function FISR088()
Local aArea		:= GetArea()
Local oReport	:= Nil

Private NomeProg	:= "FISR088"
Private _cPar01		:= ""
Private _cPar02		:= ""
Private _cPar03		:= ""
PRIVATE cPerg		:= "FISR088"

If Pergunte(cPerg,.t.)
	_cPar01:=MV_PAR01
	_cPar02:=MV_PAR02
	_cPar03:=MV_PAR03
	
   if _cPar03==1 //Analitico
	   oReport := ReportDef()
   else //resumen            
      oReport := RepDef_RESUMEN()
   ENDIF  
   oReport:PrintDialog()	
ENDIF

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ReportDef ³ Autor ³ Gpe Santacruz        ³ Data ³21/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcio³ Funcion que genera el Reporte                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef
Local aArea		:= GetArea() 
Local oReport	:= Nil
Local oSection1	:= Nil
Local oSection2	:= Nil
Local oSection3	:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01       // Mes y año                                  ³
//³ mv_par02       // Rango de sucursales                        ³
//³ mv_par03       // Tipo de informe                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cTitulo:=OEMTOANSI(STR0002) // "DECLARACION INFORMATIVA DE OPERACIONES CON TERCEROS"  

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
oReport:=TReport():New(NomeProg,OemToAnsi(cTitulo),"FISR088",{|oReport| PrintReport(oReport)})	

Pergunte("FISR088",.F.)
oReport:SetLandscape()       // Define a orientacao de pagina do relatorio como retrato.

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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: Encabezado de la Sucursal  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

oSection1:= TRSection():New(oReport,oemtoansi(STR0003),{"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/) // "EncSucur"

oSection1:SetTotalInLine(.F.)  
oSection1:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
oSection1:SetLineStyle(.t.)   //Pone titulo del campo y aun lado el y valor
oSection1:SetCharSeparator(":")    
oSection1:SetHeaderBreak(.T.) 

TRCell():New(oSection1,"CE8_FILIAL","QRYCE8",STR0030 ,PesqPict("CE8","D4_FILIAL")     ,TamSx3("D4_FILIAL")[1])//"Sucursal  "
TRCell():New(oSection1,"M0_NOME","QRYCE8","" ,/*Pespiq*/    ,50)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 2da.     Secao: Proveedor  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection2:= TRSection():New(oReport,oemtoansi(STR0004),{"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/) 
oSection2:SetTotalInLine(.F.)  
oSection2:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.F.)

oSection2:SetLineStyle(.t.)   //Pone titulo del campo y aun lado el y valor         

oSection2:SetCharSeparator(":")    
oSection2:SetHeaderBreak(.T.) 

TRCell():New(oSection2,"CE8_PROV"	,"QRYCE8",STR0006		,PesqPict("CE8","CE8_PROV")		,TamSx3("CE8_PROV")[1]) 		//"Proveedor"
TRCell():New(oSection2,"CE8_TIENDA","QRYCE8",""			,PesqPict("CE8","CE8_TIENDA")  	,TamSx3("CE8_TIENDA")[1])
TRCell():New(oSection2,"A2_NOME"	,"QRYCE8",""			,PesqPict("SA2","A2_NOME")     ,TamSx3("A2_NOME")[1])
TRCell():New(oSection2,"CE8_RFC"	,"QRYCE8",STR0007		,PesqPict("CE8","CE8_RFC")     ,TamSx3("CE8_RFC")[1])		// "R.F.C."
TRCell():New(oSection2,"CE8_IDFISC","QRYCE8",STR0008		,PesqPict("CE8","CE8_IDFISC")  	,TamSx3("CE8_IDFISC")[1])	// "ID"
TRCell():New(oSection2,"CE8_TIPTER","QRYCE8",STR0009		,/*PesqPict("CE8","CE8_TIPTER")  */	,TamSx3("CE8_TIPTER")[1])	// "Tipo Ter"
TRCell():New(oSection2,"CE8_sep1"  ,""     ,""     	,/*PesqPict("CE8","CE8_TIPTER")  */	,2)	// "Tipo Ter"
TRCell():New(oSection2,"CE8_TIPOPE","QRYCE8",STR0010 	,/*PesqPict("CE8","CE8_TIPOPE")*/  	,TamSx3("CE8_TIPOPE")[1])	// "Operación"
TRCell():New(oSection2,"CE8_sep2"  ,""     ,""     	,/*PesqPict("CE8","CE8_TIPTER")  */	,2)	// "Tipo Ter"
TRCell():New(oSection2,"CE8_PAIS"	,"QRYCE8",STR0011		,/*PesqPict("CE8","CE8_PAIS")*/   	,TamSx3("CE8_PAIS")[1])		// "Pais"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 3ra.     Secao: Detalle  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection3:= TRSection():New(oReport,oemtoansi(STR0005),{"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/) //"dET"

oSection3:SetTotalInLine(.f.) 
oSection3:SetHeaderBreak(.T.)  
oSection3:SetHeaderSection(.T.)
oSection3:SetHeaderPage(.T.)
oSection3:SetLinesBefore(0) 

oSection3:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor

TRCell():New(oSection3,"CE8_FILIAL","QRYCE8",STR0012) // "Filial"
TRCell():New(oSection3,"CE8_PROV",  "QRYCE8",STR0013) // "Prov"
TRCell():New(oSection3,"CE8_TIENDA","QRYCE8",STR0014) // "Tda"                                                                           

TRCell():New(oSection3,"CE8_NUMDOC","QRYCE8",STR0015,,TamSx3("CE8_NUMDOC")[1]+TamSx3("CE8_SERIE")[1]+1,,,"LEFT",,"LEFT") // "Documento"
TRCell():New(oSection3,"CE8_FECDOC","QRYCE8",STR0016,,10,,,"LEFT",,"LEFT")	// "Fecha"            
TRCell():New(oSection3,"CE8_TIPO"  ,"QRYCE8",STR0017,,5,,,"LEFT",,"LEFT")		// "Tipo"

TRCell():New(oSection3,"CE8_BA1516","QRYCE8",STR0018		,"999,999,999.99",19,,,"RIGHT",,"RIGHT") 	// "Base 15/16%"
TRCell():New(oSection3,"CE8_BASE15","QRYCE8",STR0019		,"999,999,999.99",19,,,"RIGHT",,"RIGHT")	// "Base 15%"
TRCell():New(oSection3,"CE8_BA1011","QRYCE8",STR0020		,"999,999,999.99",19,,,"RIGHT",,"RIGHT")	// "Base 10/11%"
TRCell():New(oSection3,"CE8_BASE10","QRYCE8",STR0021		,"999,999,999.99",19,,,"RIGHT",,"RIGHT")	// "Base 10%"
If CE8->(ColumnPos("CE8_BASE8")) > 0
	TRCell():New(oSection3,"CE8_BASE8", "QRYCE8",STR0052        ,"999,999,999.99",19,,,"RIGHT",,"RIGHT")	// "Bs. 8%"
EndIf
TRCell():New(oSection3,"CE8_BI1516","QRYCE8",STR0022		,"999,999,999.99",19,,,"RIGHT",,"RIGHT")	// "Bs.Imp.15/16%"
TRCell():New(oSection3,"CE8_BI1011","QRYCE8",STR0023 	    ,"999,999,999.99",19,,,"RIGHT",,"RIGHT")	// "Bs.Imp.10/11%"
TRCell():New(oSection3,"CE8_BASIEX","QRYCE8",STR0024		,"999,999,999.99",14,,,"RIGHT",,"RIGHT")	// "Bs.Imp.Exenta"
TRCell():New(oSection3,"CE8_BASE0", "QRYCE8",STR0025		,"999,999,999.99",14,,,"RIGHT",,"RIGHT")	// "Base 0%"
TRCell():New(oSection3,"CE8_BASEEX","QRYCE8",STR0026		,"999,999,999.99",14,,,"RIGHT",,"RIGHT")	// "Base Exenta"
TRCell():New(oSection3,"CE8_IVARET","QRYCE8",STR0027		,"999,999,999.99",14,,,"RIGHT",,"RIGHT")	// "I.V.A. Ret."
TRCell():New(oSection3,"CE8_IVADEV","QRYCE8",STR0028		,"999,999,999.99",14,,,"RIGHT",,"RIGHT")	// "I.V.A. Dev."

oSection3:Cell("CE8_FILIAL"):HideHeader()
oSection3:Cell("CE8_FILIAL"):hide()

oSection3:Cell("CE8_PROV"):HideHeader()
oSection3:Cell("CE8_PROV"):hide()
oSection3:Cell("CE8_TIENDA"):HideHeader()
oSection3:Cell("CE8_TIENDA"):hide()                     

//Total por proveedor
oBreak := TRBreak():New(oSection3,oSection3:Cell("CE8_PROV"),"SubTotal",.f.,"")  //Falso para que muestre el total debajo de la columna correspondiente

TRFunction():New(oSection3:Cell("CE8_BA1516"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BASE15"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BA1011"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BASE10"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.)
If CE8->(ColumnPos("CE8_BASE8")) > 0
	TRFunction():New(oSection3:Cell("CE8_BASE8"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.)  
EndIf
TRFunction():New(oSection3:Cell("CE8_BI1516"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BI1011"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BASIEX"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BASE0" ),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BASEEX"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection3:Cell("CE8_IVARET"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection3:Cell("CE8_IVADEV"),NIL,"SUM",oBreak,"","999,999,999.99",/*uFormula*/,.F.,.F.) 

//Total por Filial
oBreak1 := TRBreak():New(oSection1,oSection1:Cell("CE8_FILIAL"),"Total Filial",.f.,"")  //Falso para que muestre el total debajo de la columna correspondiente

TRFunction():New(oSection3:Cell("CE8_BA1516"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BASE15"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BA1011"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BASE10"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.)
If CE8->(ColumnPos("CE8_BASE8")) > 0
	TRFunction():New(oSection3:Cell("CE8_BASE8"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.) 
EndIf
TRFunction():New(oSection3:Cell("CE8_BI1516"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BI1011"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BASIEX"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BASE0" ),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BASEEX"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.) 
TRFunction():New(oSection3:Cell("CE8_IVARET"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.) 
TRFunction():New(oSection3:Cell("CE8_IVADEV"),NIL,"SUM",oBreak1,"","999,999,999.99",/*uFormula*/,.f.,.F.) 

//TOTAL GENERAL

oBreakF := TRBreak():New(oReport,{|| .t. },STR0029,.f.,"")  //"Total general"  Falso para que muestre el total debajo de la columna correspondiente

TRFunction():New(oSection3:Cell("CE8_BA1516"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.) 
TRFunction():New(oSection3:Cell("CE8_BASE15"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection3:Cell("CE8_BA1011"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.) 
TRFunction():New(oSection3:Cell("CE8_BASE10"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.) 
If CE8->(ColumnPos("CE8_BASE8")) > 0
	TRFunction():New(oSection3:Cell("CE8_BASE8"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.)
EndIf
TRFunction():New(oSection3:Cell("CE8_BI1516"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.) 
TRFunction():New(oSection3:Cell("CE8_BI1011"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.) 
TRFunction():New(oSection3:Cell("CE8_BASIEX"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.) 
TRFunction():New(oSection3:Cell("CE8_BASE0" ),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.) 
TRFunction():New(oSection3:Cell("CE8_BASEEX"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.) 
TRFunction():New(oSection3:Cell("CE8_IVARET"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.) 
TRFunction():New(oSection3:Cell("CE8_IVADEV"),NIL,"SUM",oBreakF,"","999,999,999.99",/*uFormula*/,.F.,.f.) 

RESTAREA(aArea)       
Return oReport

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ RepDef_RESUMEN³ Autor ³ Gpe Santacruz   ³ Data ³21/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcio³ Funcion que genera el Reporte                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RepDef_RESUMEN
Local aArea		:= GetArea() 
Local oReport	:= Nil
Local oSection1	:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01       // Mes y año                                  ³
//³ mv_par02       // Rango de sucursales                        ³
//³ mv_par03       // Tipo de informe                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cTitulo:=OEMTOANSI(STR0002) // "DECLARACION INFORMATIVA DE OPERACIONES CON TERCEROS"

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
oReport:=TReport():New(NomeProg,OemToAnsi(cTitulo),"FISR088",{|oReport| PrnResumen(oReport)})	

Pergunte("FISR088",.F.)
oReport:SetLandscape()       // Define a orientacao de pagina do relatorio como retrato.

oReport:nColSpace:=2
oReport:nFontBody	:= 8 // Define o tamanho da fonte.
oReport:nLineHeight	:= 45 // Define a altura da linha.
oReport:CFONTBODY:="COURIER NEW"

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
//³ Criacao da Primeira Secao: Encabezado de la Sucursal                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

oSection1:= TRSection():New(oReport,oemtoansi(STR0003),{"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/) // "EncSucur"

oSection1:SetTotalInLine(.F.)  
oSection1:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection1:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
oSection1:SetLineStyle(.t.)   //Pone titulo del campo y aun lado el y valor
oSection1:SetCharSeparator(":")    
oSection1:SetHeaderBreak(.T.) 

TRCell():New(oSection1,"CE8_FILIAL","QRYCE8",STR0030 ,PesqPict("CE8","D4_FILIAL")     ,TamSx3("D4_FILIAL")[1])//"Sucursal  "
TRCell():New(oSection1,"M0_NOME","QRYCE8","" ,/*Pespiq*/    ,50)

//Resumen
oSection2:= TRSection():New(oReport,oemtoansi(STR0031),{"QRYCE8"},,/*Campos do SX3*/,/*Campos do SIX*/) // "Resumen" 
                                  
oSection2:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection2:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.t.)	//Exibe Cabecalho da Secao
oSection2:SetLeftMargin(20)

TRCell():New(oSection2,"DESC"		,"QRYCE8",STR0032,"",88,,,"LEFT",,"LEFT") // "Descripción"
TRCell():New(oSection2,"IMPORTE"	,"QRYCE8",STR0033,"999,999,999.99",20,,,"RIGHT",,"LEFT") // "Importe"

RESTAREA(aArea)       
Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³ PrintReport³ Autor ³ Gpe Santacruz      ³ Data ³21/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Función para impresion del Reporte                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ PrintReport()                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport)
Local oSection1 
Local oSection2 
Local oSection3
Local cTitle	:= "" 
Local nOrdem	:=0
Local cAliasCE8 := "QRYCE8" 

Local cQuery	:= ""
Local aFils   	:= {}
Local nTamFil	:= 0
Local nCont		:= 0  

if empty(_cPar01)
   msgalert(STR0034) // "Seleccione un periodo"
   return
endif   

if empty(_cPar02)
   msgalert(STR0035) // "Seleccione al menos una sucursal"
   return
endif   

If !Empty(_cPar02)
    _cPar02:=FS088Traduce(_cPar02)
Endif

Pergunte(oReport:GetParam(),.F.)   

		oSection1 	:= oReport:Section(1)
		oSection2 	:= oReport:Section(2)
		oSection3 	:= oReport:Section(3)
		nOrdem	  	:= oReport:GetOrder()      

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDesMes:=ObtDesMesAnio()
		cTitle 	:= AllTrim(oReport:Title())+ cDesMEs + STR0036	// " - ANALITICO"
		oReport:SetTitle(cTitle) 
		

		If !Empty(_cPar02)
			aFils := STRTOKARR(_cPar02, ',')
			nTamFil := len(aFils)
			For nCont := 1 to nTamFil
				
				If nCont > 1
					cQuery += " UNION ALL "
				Else
					cQuery := " " 
				EndIf
				
				cXfils = aFils[nCont] 
				
				cQuery += "Select CE8.* ,A2_NOME "
				cQuery += " From "  + RetSqlName("CE8") + " CE8, " + RetSqlName("SA2") + " SA2 "
				cQuery += " WHERE " 
				cQuery += " CE8_MESANO='"+_cPar01 + "' "
				cQuery += " AND CE8_FILIAL = " + cXfils + "  AND  A2_FILIAL = '" + xFilial("SA2" , STRTRAN( aFils[nCont], "'", "")) + "'"
				cQuery += " AND CE8_PROV = A2_COD " 
				cQuery += " AND CE8_TIENDA = A2_LOJA "                      
				cQuery += " AND CE8.D_E_L_E_T_=' '"   
				cQuery += " AND SA2.D_E_L_E_T_=' '"   
				
				If nCont == nTamFil
					cQuery +=" ORDER BY CE8_FILIAL,CE8_PROV,CE8_TIENDA,CE8_FECDOC " 
				EndIf
				
			Next
		Endif

		Begin Sequence  
		
			cQuery := ChangeQuery(cQuery)      
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCE8,.T.,.T.)  
			count to nTotal   		
			oReport:SetMeter(nTotal) 
			(cAliasCE8)->(DbGoTop()) 
		
			While (cAliasCE8)->(!Eof())
			    cFilRes:=(cAliasCE8)->CE8_filial
				oSection1:Init()  
				oSection1:PrintLine()

				While (cAliasCE8)->(!Eof())  .and. cFilRes==(cAliasCE8)->CE8_filial	     
					cProRes:=(cAliasCE8)->CE8_prov+(cAliasCE8)->CE8_tienda
					oSection2:Init() 
					oSection2:PrintLine()
					oSection2:Finish() 	
					oSection3:Init()
					
					While (cAliasCE8)->(!Eof())  .and. cFilRes==(cAliasCE8)->CE8_filial .and. 	cProRes==(cAliasCE8)->CE8_prov+(cAliasCE8)->CE8_tienda
							oSection3:Cell("CE8_NUMDOC"):SetValue(alltrim((cAliasCE8)->CE8_NUMDOC)+"-"+alltrim((cAliasCE8)->CE8_SERIE))
							oSection3:PrintLine()
							oReport:IncMeter()				
							(cAliasCE8)->(dbskip()) 	   
					EndDo
					oSection3:Finish() 
				EndDo
		
				oSection1:Finish()  
			EndDo         
		End Sequence
		(cAliasCE8)->(dbCloseArea())  

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³ PrnResumen ³ Autor ³ Gpe Santacruz      ³ Data ³21/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Función para impresion del Reporte de Resumen             ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ PrnResumen()                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrnResumen(oReport)
Local oSection1		:= Nil
Local oSection2		:= Nil 

Local cTitle		:= "" 
Local nOrdem		:=	0
Local cAliasCE8		:= "QRYCE8" 
Local cOrdem		:= "" 
Local lFieldBse8	:= .F.

Local cCposQuery	:= ""
Local cCposFrom		:= ""
Local cWhere		:= ""
Local cGroup		:= ""
Local nTot			:= 0

if empty(_cPar01)
   msgalert(STR0034) // "Seleccione un periodo"
   return
endif   

if empty(_cPar02)
   msgalert(STR0035) // "Seleccione al menos una sucursal"
   return
endif   

If !Empty(_cPar02)
    _cPar02:=FS088Traduce(_cPar02)
Endif

Pergunte(oReport:GetParam(),.F.)   

		oSection1 := oReport:Section(1)
		oSection2 := oReport:Section(2)		
		nOrdem	:= oReport:GetOrder()          

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDesMes:=ObtDesMesAnio()
		cTitle 	:= AllTrim(oReport:Title())+ cDesMEs + STR0037 // " - RESUMEN"
		oReport:SetTitle(cTitle) 
		
				cCposQuery 	:= "% CE8_FILIAL,CE8_MESANO, SUM(CE8_BA1516) nBA1516, SUM(CE8_BASE15) nBA15, SUM(CE8_BA1011) nBA1011,  "
				cCposQuery 	+= " SUM(CE8_BASE10) nBASE10, SUM(CE8_BI1516) nBI1516, SUM(CE8_BI1011) nBAI011,  "
				cCposQuery 	+= " SUM(CE8_BASIEX) nBASIEX, SUM(CE8_BASE0) nBASE0, SUM(CE8_BASEEX) nBASEEX,  "								
				cCposQuery 	+= " SUM(CE8_IVARET) nIVARET, SUM(CE8_IVADEV) nIVADEV, SUM(CE8_IVAPAG) nIVAPAG,SUM(CE8_IVPAGI) nIVPAGI "
				If CE8->(ColumnPos("CE8_BASE8")) > 0
					lFieldBse8 := .T.
					cCposQuery += ", SUM(CE8_BASE8) nBASE8 " 
				EndIf
				cCposQuery += " %"
				cCposFrom   := "%" + RetSqlName("CE8") + " CE8 " 						
				cCposFrom   += "%"
				
				cWhere :="%  "
			    cWhere +=" CE8_MESANO='"+_cPar01+"' and "
				cWhere +=" CE8_FILIAL IN ("+_cPar02+") "
		
				cWhere+="     AND CE8.D_E_L_E_T_  = ' ' %" 

				cGroup:= "% CE8_FILIAL,CE8_MESANO %"
				cOrdem:="%  CE8_FILIAL,CE8_MESANO %"
		
			BeginSql alias cAliasCE8 
				SELECT  %exp:cCposQuery%
				FROM  %exp:cCposFrom% 
				WHERE %exp:cWhere%     
				GROUP BY %exp:cGroup%     				
				ORDER BY %exp:cOrdem%
			EndSql
			
		Begin Sequence  
			count to nTotal
			oReport:SetMeter(nTotal) 
			(cAliasCE8)->(DbGoTop()) 
		
			dbSelectArea( cAliasCE8 )
			While (cAliasCE8)->(!Eof())
			    cFilRes:=(cAliasCE8)->CE8_filial
				oSection1:Init()  
				oSection1:PrintLine()
				While (cAliasCE8)->(!Eof())  .and. cFilRes==(cAliasCE8)->CE8_filial	     
						oSection2:Init()     
						nTot := fGetOper((cAliasCE8)->CE8_filial)
						
						oSection2:Cell("DESC"):SetValue(STR0051)		// "Valor Total pagado a la tasa del 15% o 16% de IVA"		
						oSection2:Cell("IMPORTE"):SetValue(nTot)								
						oSection2:PrintLine()
						
						oSection2:Cell("DESC"):SetValue(STR0038)		// "Valor Total pagado a la tasa del 15% o 16% de IVA"		
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBA1516)								
						oSection2:PrintLine()
						
						
						oSection2:Cell("DESC"):SetValue(STR0039)		// "Valor Total pagado a la tasa del 15% de IVA"		
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBA15)								
						oSection2:PrintLine()
						
						oSection2:Cell("DESC"):SetValue(STR0040)		// "Valor Total pagado a la tasa del 10% u 11% de IVA"		
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBA1011)								
						oSection2:PrintLine()
                       
						oSection2:Cell("DESC"):SetValue(STR0041)		// "Valor Total pagado a la tasa del 10%  de IVA"
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBASE10)								
						oSection2:PrintLine()
						
						If lFieldBse8
							oSection2:Cell("DESC"):SetValue(STR0053)		// "Valor Total pagado de los actos o actividades sujeto al estímulo de la región fronteriza norte"
							oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBASE8)								
							oSection2:PrintLine()
                        EndIf
                        
						oSection2:Cell("DESC"):SetValue(STR0042)		// "Valor Total pagado de importación de bienes y servicios a la tasa del 15% o 16% de IVA"		
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBI1516)								
						oSection2:PrintLine()
                       
						oSection2:Cell("DESC"):SetValue(STR0043)		// "Valor Total pagado de importación de bienes y servicios a la tasa del 10% o 11% de IVA"		
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBAI011)								
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0044)		// "Valor Total pagado de importación de bienes y servicios que no pagara IVA (Exentos)"		
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBASIEX)								
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0045)		// "Valor Total pagado a la tasa del 0% de IVA"		
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBASE0)								
						oSection2:PrintLine()
                        
						oSection2:Cell("DESC"):SetValue(STR0046)		// "Valor Total pagado por los que no se pagara el IVA (Exentos)"		
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nBASEEX)								
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0047)		// "IVA Total Retenido por el contribuyente"		
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nIVARET)								
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0048)		// "IVA Total Correspondiente a las devoluciones, descuentos y bonificaciones sobre compras"		
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nIVADEV)								
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0049)		// "IVA Total transferido (pagado) de bienes y servicios excepto importaciones"		
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nIVAPAG)								
						oSection2:PrintLine()

						oSection2:Cell("DESC"):SetValue(STR0050)		// "IVA Total pagado en las importaciones de bienes y servicios"		
						oSection2:Cell("IMPORTE"):SetValue((cAliasCE8)->nIVPAGI)								
						oSection2:PrintLine()
						
						oSection2:Finish() 
						oReport:IncMeter()		 
						(cAliasCE8)->(dbskip())
				enddo
				oSection1:Finish() 	
			EndDo         
		End Sequence
    	(cAliasCE8)->(dbCloseArea())

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³ObtDesMesAnio³ Autor ³ Gpe Santacruz     ³ Data ³21/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Función para obtener nombre del mes                       ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ ObtDesMesAnio()                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function ObtDesMesAnio
Local cDes:=''              
Local nMes:=val(substr(_cPar01,1,2))
Local cAnio:=alltrim(substr(_cPar01,3,4))
Local cDMes:=''
Do case
	Case  nMes==1
	     cDMes:="ENERO"
	Case  nMes==2
	     cDMes:="FEBRERO"
	Case  nMes==3
	     cDMes:="MARZO"
	Case  nMes==4
	     cDMes:="ABRIL"
	Case  nMes==5
	     cDMes:="MAYO"
	Case  nMes==6
	     cDMes:="JUNIO"
	Case  nMes==7
	     cDMes:="JULIO"
	Case  nMes==8
	     cDMes:="AGOSTO"
	Case  nMes==9
	     cDMes:="SEPTIEMBRE"
	Case  nMes==10
	     cDMes:="OCTUBRE"
	Case  nMes==11
	     cDMes:="NOVIEMBRE"
	Case  nMes==12
	     cDMes:="DICIEMBRE"
	     
EndCase
cDes:=" "+cDMes+" "+cAnio+" "
Return cDes

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao     ³ fGetOper   ³ Autor ³ Gpe Santacruz      ³ Data ³21/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Obtiene Valor Total pagado a la tasa del 15% o 16% de IVA ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxis   ³ fGetOper(ExpC1)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1: Filial de tabla CE8                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function fGetOper(cFilSel)
	Local nRet			:= 0
	Local aArea			:= GetArea()
	Local cAl			:= "QRYCONT"
	Local cWhere		:= ""
	Local lIsDBMsSQL	:= AllTrim(Upper(TcGetDb())) $ "MSSQL7|MSSQL"
	Local cSelect		:= IIf(lIsDBMsSQL, "%COUNT(DISTINCT(CE8_PROV+CE8_TIENDA)) AS TOTAL%",  "%COUNT(DISTINCT(CE8_PROV||CE8_TIENDA)) AS TOTAL%")
	
	cWhere := "%  "
	cWhere += " CE8_MESANO='"+_cPar01+"' and "
	cWhere += " CE8_FILIAL IN ('"+ cFilSel+ "') "
	cWhere += "     AND CE8.D_E_L_E_T_  = ' ' %" 
				
	BeginSQL alias cAl 
		SELECT %exp:cSelect%
		FROM %table:CE8% CE8
		WHERE %exp:cWhere% and %notDel%	
	EndSQl 
	
	While (cAl)->(!EOF())
		nRet := (cAl)->TOTAL
		(cAl)->(dbSkip())
	EndDo
	(cAl)->(dbCloseArea())

	RestArea(aArea)
	
Return nRet
