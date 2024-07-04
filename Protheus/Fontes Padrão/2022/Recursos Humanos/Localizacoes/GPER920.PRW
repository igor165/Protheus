#INCLUDE "Protheus.ch"
#INCLUDE "GPER920.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER920  ³ Autor ³                       ³ Data ³ 24/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reporte de Acumulados por Concepto                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER920()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³FNC/Chamado³  Motivo da Alteracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Mohanad Odeh³31/05/12³011241/2012³Remoção da limpeza da variável cLista³±±
±±³            ³        ³     TEXTXT³ na função ConvQry para evitar erro  ³±±
±±³            ³        ³           ³quando não lista verba alguma.       ³±±
±±³Jonathan Glz³25/11/16³   MMI-4225³Se realiza modificacion al query y al³±±
±±³            ³        ³           ³while de impresion; para que se impr.³±±
±±³            ³        ³           ³los datos de todas la filiales.      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER920()                        
Local oReport
Local aGetArea	:= GetArea()
Local cPerg		:= "GPER920"

Private cLisSuc	:= ""//Lista de Sucursales
Private cLisCC	:= ""//Lista de Centros de costos
Private cLisDep	:= ""//Lista de de Deptos 
Private cLisMat	:= ""//Lista de matricula
Private cLisSit	:= ""//Lista de situaciones   (Seleccion)
Private cLisCat	:= ""//Lista de categorias (Seleccion)
Private cProces	:= ""//Proceso
Private cLisCon	:= ""//Lista de Conceptos (Seleccion)
Private cLisCri	:= ""//Lista de criterios
Private cAliasRG7:= criatrab(nil,.f.)	// Creo mi tabla temporal
Private NomeProg:= "GPER920"
Private nTipo	:= 0//Tipo de detalle
Private nAnio	:= 0//Año inicial
Private nAniof	:= 0//Año Final
Private nMesI	:= 0//De mes
Private nMesF	:= 0//A Mes
Private nTipVal	:= 0//Tipo de valor a imprimir
Private nImpTot	:= 0//Imprime totales?
Private nContPd	:= 0
Private nMaxCol	:= 11

dbSelectArea("RG7")
DbSetOrder(1)

If Pergunte(cPerg,.T.)
	IF TodoOK()
		//Ejecuta Reporte
		oReport := REPORTDEF()
		oReport:PRINTDIALOG()
   Endif
Endif

RestArea(aGetArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ReportDef   Autor ³ FMonroy               ³ Data ³25/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³  Def. Reporte Analitico y Sintetico                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER920                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()
Local aArea      := GetArea() 
Local nCont      :=0
Local oReport
Local oSection1
Local oSection2
Local oSection3

Private cTitulo	:=OEMTOANSI(STR0001) //"Acumulados por Concepto -"
                   //"Nombre"      ###"Matricula"    ###"Centro de Costos" ###"Departamento"
Private aOrd    := {OemToAnsi(STR0004),OemToAnsi(STR0003),OemToAnsi(STR0024),OemToAnsi(STR0025)}

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
oReport:=TReport():New(NomeProg,OemToAnsi(cTitulo), NomeProg  ,{|oReport| PrintReport(oReport)})	
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
OSection1:SetCharSeparator(":")    

TRCell():New(oSection1,"SM0_NOME",		,STR0005 , ,15,,,,,,,,,,,.t.)//"Empresa"
TRCell():New(oSection1,"SUCURSAL",     ,STR0006 , ,30,,,,,,,,,,,.t.)//"Sucursal"
TRCell():New(oSection1,"PROCES",       ,STR0007 , ,TamSx3("RG7_PROCES")[1]+TamSx3("RCJ_DESCRI")[1]+2,,,,,,,,,,,.t.)//"Proceso"
TRCell():New(oSection1,"MESI",         ,STR0008 , ,2,,,,,,,,,,,.t.)//"Del Mes"
TRCell():New(oSection1,"MESF",	      	,STR0009 , ,2,,,,,,,,,,,.t.)//"Al Mes" 
TRCell():New(oSection1,"ANIO",         ,STR0010 , ,4,,,,,,,,,,,.t.)//"Del Año"
TRCell():New(oSection1,"ANIOF",        ,STR0026 , ,4,,,,,,,,,,,.t.)//"Hasta el anio"
TRCell():New(oSection1,"DET",          ,STR0011 , ,25,,,,,,,,,,,.t.)//"Tipo DaTalle"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 2da.     Secao:Detalle Empleado                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection2:= TRSection():New(oReport,"Detalle",,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"
oSection2:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection2:SetHeaderSection(.T.)	//Exibe Cabecalho da Secao
oSection2:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao

TRCell():New(oSection2,"RA_MAT",cAliasRG7,STR0012 ,  PesqPict("SRA","RA_MAT")    ,9)//"Matricula"
TRCell():New(oSection2,"RA_NOME",cAliasRG7, STR0013 ,  PesqPict("SRA","RA_NOME")    ,TamSx3("RA_NOME")[1])//"Nombre"

For nCont:=1 to nMaxCol
	TRCell():New(oSection2,alltrim(STR(nCont)),, ,  "9,999,999,999.99"    ,16 )
Next

TRCell():New(oSection2,"TOTAL",, ,  "9,999,999,999.99"     ,16)
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da 3da.     Secao: Totales			                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection3:= TRSection():New(oReport,"Totales",,aOrd,/*Campos do SX3*/,/*Campos do SIX*/) //"EncPrograma"
oSection3:SetLineStyle(.F.)   //Pone titulo del campo y aun lado el y valor
oSection3:SetHeaderSection(.f.)	//Exibe Cabecalho da Secao
oSection3:SetHeaderPage(.f.)	//Exibe Cabecalho da Secao

TRCell():New(oSection3,"RA_MAT",,,  PesqPict("SRA","RA_MAT")    ,9)
TRCell():New(oSection3,"RA_NOME",,,  PesqPict("SRA","RA_NOME")    ,TamSx3("RA_NOME")[1])

For nCont:=1 to nMaxCol
	TRCell():New(oSection3,alltrim(STR(nCont)),, ,  "9,999,999,999.99"    ,16 )
Next

TRCell():New(oSection3,"TOTAL",, ,  "9,999,999,999.99"    , 16)
 
Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PrintReport Autor ³ FMonroy               ³ Data ³25/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³   Impresión del Informe                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³    PrintReport(oExp)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER920                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintReport(oReport)

Local oSection1  := oReport:Section(1)
Local oSection2  := oReport:Section(2)
Local oSection3  := oReport:Section(3)

Local cTitle	    := ""     
Local cOrdem     := "" 
Local cFilRG7    := xfilial("RG7")
Local cFilSRA    := xfilial("SRA")
Local cFilSRJ    := xfilial("SRJ")
Local cFilSRV    := xfilial("SRV")
Local cChaveArq	 := ""
Local cOrgJoin	 := "% %"
Local cFilPro    :=  ""
Local cSuc       := ""
Local cEmp       := ""
Local cSucEmp    := ""
Local cMat       := ""
Local cSelect    := ""
Local cGroup     := ""  
Local cPrefijo   := "" //A SI ES ACUMULADOS Y H SI ES HORAS, 
Local cSufijo    := "" 
Local cNome      := ""

Local nOrdem     := oSection1:GetOrder()
Local nTotal     := 0
Local nPos       := 0
Local nTpd       := 0
Local nTAcum     := 0
Local nCnt       := 0
Local nIx        := 0
Local nSTpd      := 0 // Total por fila
Local nPos1      := 0
Local _NPOS      := 0
Local nAnioI     := 0

Local aChaveArq	 := {}
Local ATSUC      := {}
Local ATEmp      := {} 
Local aAcum      := {}
Local aEncab     := dowArray(MV_PAR13,"RV_COD")
Local _aAllFilial:={}//FWLoadSM0()
//Local lSm0		:=FindFuction( FWLoadSM0())
Local lShar		 := .F.

Pergunte(oReport:GetParam(),.F.)   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Altera o Titulo do Relatorio conforme o parametro selecionado   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitle 	:= If(AllTrim(oReport:Title())==AllTrim(cTitle), OemToansi(cTitulo),oReport:Title())
oReport:SetTitle(cTitle+" - "+ If(ntipo==1,STR0022,STR0023))//ANALITICO # SINTETICO 

#IFDEF TOP

	//Transforma los parametros de tipo Rango en expresion SQL para ser utilizada en query 
	MakeSqlExpr("GPER920")  
		  
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
	
	cFilPro += IF( Empty(MV_PAR01) , " " , " AND " + REPLACE(MV_PAR01, "RA_FILIAL", " RG7.RG7_FILIAL ") ) //Suc
	cFilPro += IF( EMPTY(MV_PAR02) , " " , " AND " + MV_PAR02 ) //CC
	cFilPro += IF( Empty(MV_PAR03) , " " , " AND " + MV_PAR03 ) //Deptos
	cFilPro += IF( EMPTY(MV_PAR04) , " " , " AND " + MV_PAR04 ) //Matriculas
	cFilPro += IF( EMPTY(MV_PAR08) , " " , " AND " + MV_PAR08 ) //Procesos
	cFilPro += IF( EMPTY(MV_PAR14) , " " , " AND " + MV_PAR14 ) //Criterios
	cFilPro += " AND RG7.RG7_ANOINI BETWEEN " + Alltrim( STR(nAnio) ) + " AND " + Alltrim( STR(nAnioF) )
	cFilPro +=  "%"
	
	cSelect := "% RG7.RG7_FILIAL, RG7.RG7_ANOINI, SRA.RA_FILIAL, RG7.RG7_PROCES, SRA.RA_MAT, SRA.RA_NOME, "
	cSelect += " SRV.RV_DESC, SRA.RA_NOME , RG7.RG7_PD,SRA.RA_CC,SRA.RA_DEPTO,RCJ.RCJ_DESCRI, "
	cSelect += " SUM(RG7_HRS01)  H01, SUM(RG7_HRS02)  H02, SUM(RG7_HRS03)  H03, SUM(RG7_HRS04)  H04, SUM(RG7_HRS05)  H05, "
	cSelect += " SUM(RG7_HRS06)  H06, SUM(RG7_HRS07)  H07, SUM(RG7_HRS08)  H08, SUM(RG7_HRS09)  H09, SUM(RG7_HRS10)  H10, "
	cSelect += " SUM(RG7_HRS11)  H11, SUM(RG7_HRS12)  H12, SUM(RG7_HRS13)  H13, SUM(RG7_ACUM01) A01, SUM(RG7_ACUM02) A02, "
	cSelect += " SUM(RG7_ACUM03) A03, SUM(RG7_ACUM04) A04, SUM(RG7_ACUM05) A05, SUM(RG7_ACUM06) A06, SUM(RG7_ACUM07) A07, "
	cSelect += " SUM(RG7_ACUM08) A08, SUM(RG7_ACUM09) A09, SUM(RG7_ACUM10) A10, SUM(RG7_ACUM11) A11, SUM(RG7_ACUM12) A12, "
	cSelect += " SUM(RG7_ACUM13) A13 %"
	
	cGroup :=  "% RG7.RG7_FILIAL, RG7.RG7_ANOINI, SRA.RA_FILIAL,RG7.RG7_PROCES, SRA.RA_MAT, SRA.RA_NOME, SRV.RV_DESC, "
	cGroup +=  " SRA.RA_NOME, RG7.RG7_PD, SRA.RA_CC, SRA.RA_DEPTO, RCJ.RCJ_DESCRI %"
			
	BeginSql alias cAliasRG7
		SELECT	%exp:cSelect%            
		FROM %table:RG7% RG7    
			INNER JOIN %table:SRA% SRA ON RG7.RG7_PROCES = SRA.RA_PROCES AND RG7.RG7_MAT = SRA.RA_MAT
			INNER JOIN %table:SRV% SRV ON RG7.RG7_PD = SRV.RV_COD
			INNER JOIN %table:RCJ% RCJ ON RG7.RG7_PROCES = RCJ.RCJ_CODIGO
		WHERE SRA.RA_SITFOLH IN (%exp:cLisSit%) AND //Situciones
			  SRA.RA_CATFUNC IN (%exp:cLisCat%) AND //Categorias
			  RG7.RG7_PD     IN (%exp:cLisCon%)     //Conceptos
				%exp:cFilPro% 
				AND  RG7.%notDel% 
				AND SRA.%notDel% 
			    AND SRV.%notDel%  
				AND RCJ.%notDel% 
		GROUP BY %exp:cGroup%
		ORDER BY %exp:cOrdem%	 
	EndSql   
		
#ELSE

	MSGERROR(STR0014)//"No esta disponible para DBF"
	
#ENDIF
	
Begin Sequence  
	dbSelectArea( cAliasRG7 )
	count to nTotal
	oReport:SetMeter(nTotal) 
	(cAliasRG7)->(DbGoTop()) 
	If (cAliasRG7)->(!Eof())
		oSection1:Init()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa Totalizadores                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Aadd(ATEMP,{"",0,0,0})
		
		While (cAliasRG7)->(!Eof()) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Sección Encabezado de Sucursales                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
			oSection1:Cell("MESI"):hide()
			oSection1:Cell("MESF"):hide()
			oSection1:Cell("ANIO"):hide()
			oSection1:Cell("ANIOF"):hide()
			oSection1:Cell("DET"):hide()
			oSection1:Printline()
			oSection1:Cell("SM0_NOME"):disable()
			oSection1:Cell("SUCURSAL"):disable()
			oSection1:Cell("PROCES"):show()
			oSection1:Cell("MESI"):show()
			oSection1:Cell("MESF"):show()
			oSection1:Cell("ANIO"):show()
			oSection1:Cell("ANIOF"):show()
			oSection1:Cell("DET"):show()
			
			oSection1:Cell("PROCES"):SetValue(alltrim((cAliasRG7)->RG7_PROCES)+Space(1)+ALLTRIM((cAliasRG7)->RCJ_DESCRI))	
			oSection1:Cell("PROCES"):SetSize(len(alltrim((cAliasRG7)->RG7_PROCES)+Space(1)+ALLTRIM((cAliasRG7)->RCJ_DESCRI)))
			oSection1:Cell("MESI"):SetValue(STRZERO(nMESI,2))	
			oSection1:Cell("MESF"):SetValue(STRZERO(nMESF,2))	
			oSection1:Cell("ANIO"):SetValue(alltrim(STR(nAnio)))	
			oSection1:Cell("ANIOF"):SetValue(alltrim(STR(nAnioF)))	
			If nTipVal==1
				oSection1:Cell("DET"):SetValue(STR0015)//"Valores"
				cPrefijo:="A"
			ElseIf nTipVal==2
				oSection1:Cell("DET"):SetValue(STR0016)//"Horas/Dias"
				cPrefijo:="H"
			ElseIf nTipVal=3
				oSection1:Cell("DET"):SetValue(STR0017)//"Horas/Días y Valores"
				cPrefijo:="H"
			EndIf	         
			oSection1:Printline()
			
			oReport:fatline()
			cSuc := (cAliasRG7)->RG7_FILIAL
			cEmp:=SM0->M0_NOME
			oSection2:init()
			
			For nCnt:=1 to nMaxCol
				oSection2:Cell(alltrim(str(nCnt))):SetTitle("")
				oSection3:Cell(alltrim(str(nCnt))):SetTitle("")
			Next
			
			For nCnt:=1 to len(aEncab)
				oSection2:Cell( alltrim(str(aEncab[nCnt][2]))):SetTitle(ALLTRIM(aEncab[nCnt][1]) + "-" + ;
				                                                        SUBSTR(Posicione("SRV",1,CFILSRV+ALLTRIM(aEncab[nCnt][1]),"RV_DESC") ,1,12))
				oSection3:Cell(alltrim(str(nCnt))):SetValue(0)	//Inicializa Celdas	
				If ntipo==2//Rep Sintetico
					oSection3:Cell( alltrim(str(aEncab[nCnt][2]))):SetTitle(ALLTRIM(aEncab[nCnt][1]) + "-" + ;
					                                                        SUBSTR(Posicione("SRV",1,CFILSRV+ALLTRIM(aEncab[nCnt][1]),"RV_DESC"),1,12))
				EndIf                                                                                                                                
			Next 

			If nTipo==2
				oSection3:setheaderSection(.t.)                
				oSection3:Cell("RA_MAT"):SetTitle("")
				oSection3:Cell("RA_NOME"):SetTitle("")
			EndIf
						
			Atsuc:={}
			AADD(aTsuc,{"",0,0,0}) 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ aTsuc{"",0,0,0}                          | 
			//³ 1-PD-Concepto                            | 
			//³ 2-Columna                                | 
			//³ 3-Total Hrs                              | 
			//³ 4-Total Acum                             | 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Inicializa Celdas
			nAnioi:=(cAliasRG7)->RG7_ANOINI
			
			While (cAliasRG7)->(!Eof()) .And. cEmp == SM0->M0_NOME .and. cSuc == (cAliasRG7)->RG7_FILIAL .and. nANioi==(cAliasRG7)->RG7_ANOINI
				cMat  := (cAliasRG7)->RA_MAT
				cNome := (cAliasRG7)->RA_NOME
				cSucEmp := (cAliasRG7)->RA_FILIAL

				aAcum := {}
				nSTpd := 0
				//Inicializa Celdas
				For nCnt:=1 to len(aEncab)
					oSection2:Cell(alltrim(str(nCnt))):SetValue(0)
				Next
				
				While (cAliasRG7)->(!Eof()) .And. cEmp == SM0->M0_NOME .and. cSuc == (cAliasRG7)->RG7_FILIAL .and. ;
				       cSucEmp ==(cAliasRG7)->RA_FILIAL .and. cMat == (cAliasRG7)->RA_MAT .AND.  nANioi==(cAliasRG7)->RG7_ANOINI

					oSection2:Cell("RA_MAT"):SetValue((cAliasRG7)->RA_MAT)
					oSection2:Cell("RA_NOME"):SetValue((cAliasRG7)->RA_NOME)
					nTpd:=0		
					nTAcum:=0
					If (nPos:=ASCAN(aEncab, {|aVal|ALLTRIM( aVal[1]) == ALLTRIM((cAliasRG7)->RG7_PD)}))>0
							For nIx:=nMesI to nMesF
								cSufijo:=STRZERO(nIx,2)
								nTpd+=&("(cAliasRG7)->"+cPrefijo+cSufijo)
								IF(nTipVal==3,nTacum+=&("(cAliasRG7)->A"+cSufijo),)
							Next					
						oSection2:Cell(alltrim(str( aEncab[nPos][2]))):SetValue(nTpd)//sumatoria de los meses 
						
						IF(nTipVal==3,AADD(aAcum,{aEncab[nPos][1],nPos,nTAcum}),)//horas e importes
							nSTpd+=nTpd
						If(nPos1:=aSCan(aTsuc,{|aVal|aVal[1]==ALLTRIM((cAliasRG7)->RG7_PD)}))>0
							aTsuc[nPos1][3]:=aTsuc[nPos1][3]+nTpd
						Else
							aADd(aTsuc,{ALLTRIM((cAliasRG7)->RG7_PD),aEncab[nPos][2],ntpd,0})
						EndIf
					EndIf //Encuentra Pos
					(cAliasRG7)->(dbSkip())
					oReport:IncMeter()   //regla de avance
			 	EndDo // el mismo empleado
				 oSection2:Cell("TOTAL"):SetValue(nSTpd)
				 
				If nTipo==1 //Tipo Setalle
					oSection2:Printline()
				EndiF
				 
				IF nTipVal==3        
					nTAcum:=0
					oSection2:Cell("RA_MAT"):SetValue(cMat)
					oSection2:Cell("RA_NOME"):SetValue(cNome)
					For nCnt:=1 to len(aAcum)
						oSection2:Cell(alltrim(str( aAcum[nCnt][2]))):SetValue(aAcum[nCnt][3])
						nTAcum+=aAcum[nCnt][3]    
						//Totalizadores por sucursal
						If(nPos1:=aSCan(aTsuc,{|aVal|aVal[1]==ALLTRIM(aAcum[nCnt][1])}))>0
							aTsuc[nPos1][4]:=aTsuc[nPos1][4]+aAcum[nCnt][3]
						Else
							aADd(aTsuc,{ALLTRIM(aAcum[nCnt][1]),aAcum[nCnt][2],0,aAcum[nCnt][4]})	
						EndIf
					 Next    
					 oSection2:Cell("TOTAL"):SetValue(nTAcum)  

					 If nTipo==1
					 	oSection2:Printline()
					 EndIf
				 EndIf
			Enddo //Empresa y sucursal igual
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Imprime totales  POR SUCURSAL                                    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//Solo si IMPRIME TOTALES
			If nImptot==1 .Or. nTipo==2
			    If( nTipo==1,oReport:SkipLine(),)
			   	If(	ntipo==1,oReport:FatLine(),)
				oSection3:Init()
				nTpd:=0

				oSection3:Cell("RA_NOME"):SetValue(STR0018+" "+iif(nTipVal==3 ,STR0016,""))//"Total Sucursal"##"Horas/Dias"
				For nCnt:=1 to len (atSuc)
					If ASCAN(aEncab, {|aVal|ALLTRIM( aVal[1]) ==  atSuc[nCnt][1]})>0 //Busca PD
						oSection3:Cell(alltrim(str( atSuc[nCnt][2]))):SetValue(aTsuc[nCnt][3])
						ntpd+=aTsuc[nCnt][3]
						If(nPos1:=aSCan(aTEmp,{|aVal|aVal[1]==ALLTRIM(atSuc[nCnt][1])}))>0//Acumulador de Totales por Empresa
							aTEmp[nPos1][3]:=aTEmp[nPos1][3]+aTsuc[nCnt][3]
						Else
							aADd(aTEmp,{aTsuc[nCnt][1],aTsuc[nCnt][2],aTsuc[nCnt][3],0})	
						EndIf
					EndIf
				Next
				oSection3:Cell("TOTAL"):SetValue(nTpd) 
				oSection3:Printline()
				
				If nTipVal==3 
					nTpd:=0

					oSection3:Cell("RA_NOME"):SetValue(STR0018+" "+STR0015)//"Total Sucursal"##"Valores"
					For nCnt:=1 to len (atSuc)
						If ASCAN(aEncab, {|aVal|ALLTRIM( aVal[1]) ==  atSuc[nCnt][1]})>0 //Busca PD
							oSection3:Cell(alltrim(str( atSuc[nCnt][2]))):SetValue(aTsuc[nCnt][4])
							ntpd+=aTsuc[nCnt][4]
							if(nPos1:=aSCan(aTEmp,{|aVal|aVal[1]==ALLTRIM(atSuc[nCnt][1])}))>0//Acumulador de Totales por Empresa
								aTEmp[nPos1][4]:=aTEmp[nPos1][4]+aTsuc[nCnt][4]
							Else
								aADd(aTEmp,{aTsuc[nCnt][1],aTsuc[nCnt][2],0,aTsuc[nCnt][4]})	
							EndIf
						EndIf
					Next
					oSection3:Cell("TOTAL"):SetValue(nTpd) 
					oSection3:Printline()
				EndIf   
				oReport:skipline(2) //gsa
			EndIf
			oReport:skipline(1)
		EndDo //Fin  de archivo
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime totales  POR EMPRESA                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Solo si IMPRIME TOTALES
		If nImptot == 1 .Or. nTipo==2
			oReport:skipline()
			oReport:fatline()
			oSection3:Init()
			nTpd:=0
			oSection3:Cell("RA_NOME"):SetValue(STR0019+" "+iif(nTipVal==3 ,STR0016,""))//"Total Empresa"##"Horas/Dias"
			For nCnt:=1 to len (atEmp)                                                             
				If ASCAN(aEncab, {|aVal|ALLTRIM( aVal[1]) ==  atEmp[nCnt][1]})>0 //Busca PD
					oSection3:Cell(alltrim(str( atEmp[nCnt][2]))):SetValue(aTEmp[nCnt][3])
					ntpd+=aTemp[nCnt][3]
				EndIf
			Next
			oSection3:Cell("TOTAL"):SetValue(nTpd) 
			oSection3:Printline()
			
			IF nTipVal==3 
				nTpd:=0
				oSection3:Cell("RA_NOME"):SetValue(STR0019+" "+STR0015)//"Total Empresa"##"Valores"
				For nCnt:=1 to len (atEmp)                                                             
					If ASCAN(aEncab, {|aVal|ALLTRIM( aVal[1]) ==  atEmp[nCnt][1]})>0 //Busca PD
						oSection3:Cell(alltrim(str( atEmp[nCnt][2]))):SetValue(aTEmp[nCnt][4])
						ntpd+=aTemp[nCnt][4]
					EndIf
				Next
				oSection3:Cell("TOTAL"):SetValue(nTpd) 
				oSection3:Printline()
			EndIf
		EndIf
		oSection1:Finish()
		oSection2:Finish()
		oSection3:Finish()
	EndIf //If fin de archivo 
End Sequence

(cAliasRG7)->(dbCloseArea()) 

Return ( Nil )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TodoOK    ºAutor  ³Microsiga           º Data ³  24/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacion de los datos antes de Ejecutar el proceso        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function TodoOK(cPerg)

Pergunte(cPerg,.F.)

	cLisSuc	:= MV_PAR01 // Intervalos de Sucursales
	cLisCC	:= MV_PAR02 // Intervalos de Centros de costos
	cLisDep	:= MV_PAR03 // Intervalos de de Deptos
	cLisMat	:= MV_PAR04 // Intervalos de matricula

IF EMPTY(SUBSTR(MV_PAR05,1,1))
	cLisSit:="%' ',"+ConvQry(MV_PAR05,"RA_SITFOLH")+"%"
ELSE	
	cLisSit	:= "%"+ConvQry(MV_PAR05,"RA_SITFOLH")+"%"//Lista de situaciones   (Seleccion)    Tabla 31
ENDIF

cLisCat	:= "%"+ConvQry(MV_PAR06,"RA_CATFUNC")+"%"//Lista de categorias (Seleccion) Tabla 28
nTipo	:= MV_PAR07 //Tipo de detalle
cProces	:= MV_PAR08 //Proceso
nAnio	:= MV_PAR09 //Año inicial
nAnioF	:= MV_PAR10 //Año Final
nMesI	:= MV_PAR11 //De mes
nMesF	:= MV_PAR12 //A Mes
cLisCon	:= "%"+ConvQry(MV_PAR13,"RV_COD")+"%"//Lista de Conceptos (Seleccion)
cLisCri	:= MV_PAR14 //Intervalo de criterios
nTipVal	:= MV_PAR15 //Tipo de valor a imprimir
nImpTot	:= MV_PAR16 //Imprime totales?

//Validaciones de las preguntas
//Mes2>=Mes1
If nMesI > nMesF
	Msginfo(STR0020)//"El mes inicial debe ser menor al mes final"
	Return(.F.)
EndIf

//Listar hasta 11 conceptos
If nContPd := ConList(MV_PAR13,"RV_COD") > 11
	Msginfo(STR0021)//"Solo puede seleccionar hasta 11 Conceptos"
	Return ( .F. )
EndIf

Return (.T.)

/*/
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
±±³ Uso      ³  GPER920                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ConvQry(cLista,cCampo)
Local cTxt:=''
Local nTamReg := TamSX3(cCampo)[1]
Local nCont:=0

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Genera texto para usar  para usar despues en Query             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/                 
For nCont := 1 To Len( cLista ) Step nTamReg
    cTxt += "'" + SubStr( cLista , nCont , nTamReg ) + "',"
Next       

cTxt := Substr(cTxt,1, Len(cTxt)-1)                                   

Return ( cTxt )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ConList   ºAutor  ³Fmonroy             º Data ³  27/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Cuenta el numero de Items seleccionados en el listbox       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   ConList(cExp,cExp1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³    cExp: Cadena de caracteres que retorna el litbox        ³±±
±±³          ³    cExp1: Campo del diccionario de datos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER920                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ConList(cLista,cCampo)
Local nTamReg := TamSX3(cCampo)[1]
Local nCont :=0
             
cLista := Alltrim(cLista)
nCont :=  Len( cLista ) / nTamReg
                                
Return ( nCont )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³dowArray  ºAutor  ³Fmonroy             º Data ³  27/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Descri‡„o ³Carga arreglo con los conceptos seleccionados para encabeza-³±±
±±³          ³do del reporte                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³   ConList(cExp,cExp1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³    cExp: Cadena de caracteres que retorna el litbox        ³±±
±±³          ³    cExp1: Campp del diccionario de datos                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  GPER920                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DowArray(cLista,cCampo)
Local nTamReg := TamSX3(cCampo)[1]
Local nCont:=0
Local nIx:=1
Local aEnc:={}         
         
cLista := Alltrim(cLista)

For nCont := 1 To Len( cLista ) Step nTamReg 
    aadd(aEnc,{SubStr( cLista , nCont , nTamReg ),nIx})
    nIx++
Next    
 
Return ( aEnc )
