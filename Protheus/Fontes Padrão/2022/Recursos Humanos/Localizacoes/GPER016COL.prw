#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER016COL.CH"
#INCLUDE "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función   ³GPER016COL³ Autor ³ Alfredo Medrano       ³  Data ³ 29/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprimir el Reporte Retención Contingente                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GPER016COL()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Colombia                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Programador   ³ Data   ³ BOPS/FNC  ³  Motivo da Alteracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ m.camargo    ³25/03/12³TPAY99     ³Se obtiene % de Val No Apl.          ³±±
±±³ m.camargo    ³25/03/12³TPAY99     ³Se modifican tamaños de celdas num.  ³±±
±±³ Alf. Medrano ³16/02/16³TPAY99     ³se alinean campos de Seccion 2 en fun³±±
±±³              ³        ³           ³ReportDef                            ³±±
±±³ Alf. Medrano ³07/09/16³PDR_SER_   ³Merge 12.1.13                        ³±±
±±³              ³        ³MI002-56   ³                                     ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER016COL()
Local		oReport
Local		aArea 		:= GetArea()
Private 	cTitulo	:= OemToAnsi(STR0001)
Private 	aOrd    	:= {OemToAnsi(STR0007),OemToAnsi(STR0015)}	//"Matrícula"###"Filial + Matrícula"
Private 	cPerg   	:= "GPER016COL"

If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica las perguntas selecionadas      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte(cPerg,.F.)

    oReport := ReportDef()
    oReport:PrintDialog()
EndIF

RestArea( aArea )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ReportDef  ³ Autor ³ Alfredo Medrano       ³ Data ³29/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³  Relatorio Retención Contingente                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER016COL                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER016COL - Colombia                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oSection2




		//³Crea los componentes de impresion
		DEFINE REPORT oReport NAME "GPER016COL" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| ReportPrint(oReport)} DESCRIPTION OemtoAnsi(STR0016)  TOTAL IN COLUMN
		oReport:nFontBody := 6 	//Tamaño fuente del documento
		oReport:SetLandscape() 	//Define la orientación de la página del informe como Horizontal (paisaje).


		DEFINE SECTION oSection OF oReport TITLE " " TABLES "SRD" TOTAL IN COLUMN ORDERS aOrd
		DEFINE CELL NAME "RD_FILIAL" 	OF oSection ALIAS " "	SIZE TamSX3("RD_FILIAL")[1] 	 TITLE OemToAnsi(STR0004) // "Sucursal"
		DEFINE CELL NAME "RD_MAT" 	 	OF oSection ALIAS " "	SIZE TamSX3("RD_MAT")[1]		 TITLE OemToAnsi(STR0007) // "Matrícula"
		DEFINE FUNCTION FROM oSection:Cell("RD_MAT")		FUNCTION COUNT NO END SECTION

		DEFINE SECTION oSection1 OF oSection TITLE " "
		DEFINE CELL NAME "RD_FILIAL" 	OF oSection1 ALIAS " "	SIZE TamSX3("RD_FILIAL")[1] 	TITLE OemToAnsi(STR0004) ALIGN LEFT 			     					// "Sucursal"
		DEFINE CELL NAME "RD_CC" 	 	OF oSection1 ALIAS " "	SIZE TamSX3("RD_CC")[1] 		TITLE OemToAnsi(STR0005) ALIGN LEFT  									// "Centro Costo"
		DEFINE CELL NAME "CTT_DESC01"	OF oSection1 ALIAS " "	SIZE TamSX3("CTT_DESC01")[1]    TITLE " "                ALIGN LEFT										// "Descripción"
		DEFINE CELL NAME "RA_TPCIC"  	OF oSection1 ALIAS " "	SIZE TamSX3("RA_TPCIC")[1]		TITLE OemToAnsi(STR0021) ALIGN LEFT									// "Tipo ID"
		DEFINE CELL NAME "RA_CIC" 	 	OF oSection1 ALIAS " "	SIZE TamSX3("RA_CIC")[1]		TITLE OemToAnsi(STR0022) ALIGN LEFT									// "Num. ID"
		DEFINE CELL NAME "RD_MAT" 	 	OF oSection1 ALIAS " "	SIZE TamSX3("RD_MAT")[1]		TITLE OemToAnsi(STR0007) ALIGN LEFT										// "Matrícula"
		DEFINE CELL NAME "RA_NOME" 	 	OF oSection1 ALIAS " "	SIZE TamSX3("RA_NOME")[1]   	TITLE OemToAnsi(STR0008) ALIGN LEFT										// "Nombre"
		DEFINE CELL NAME "APOVOLSI" 	OF oSection1 ALIAS " "	SIZE 21				 	 	 	TITLE OemToAnsi(STR0009) ALIGN RIGHT  HEADER ALIGN RIGHT	PICTURE "@E 99,999,999,999.99"  // "Apo Vol Si Aplico"
		DEFINE CELL NAME "APOVOLNO"	    OF oSection1 ALIAS " "	SIZE 21							TITLE OemToAnsi(STR0010) ALIGN RIGHT  HEADER ALIGN RIGHT	PICTURE "@E 99,999,999,999.99"  // "Apo Vol No Aplico"
		DEFINE CELL NAME "RRESTVOL"	    OF oSection1 ALIAS " "	SIZE 21							TITLE OemToAnsi(STR0023) ALIGN RIGHT  HEADER ALIGN RIGHT	PICTURE "@E 99,999,999,999.99"  // "Ret. Rest. Vol."
		DEFINE CELL NAME "RETSINAPO"	OF oSection1 ALIAS " "	SIZE 21							TITLE OemToAnsi(STR0011) ALIGN RIGHT  HEADER ALIGN RIGHT	PICTURE "@E 99,999,999,999.99"  // "Ret Fte sin Apo Vol"
		DEFINE CELL NAME "RETENCON"		OF oSection1 ALIAS " "	SIZE 21							TITLE OemToAnsi(STR0012) ALIGN RIGHT  HEADER ALIGN RIGHT	PICTURE "@E 99,999,999,999.99"  // "Retención Contingente"
		DEFINE CELL NAME "ENTID" 		OF oSection1 ALIAS " "	SIZE TamSX3("RD_ENTIDAD")[1]	TITLE OemToAnsi(STR0014) ALIGN LEFT   HEADER ALIGN CENTER									// Entidad

		DEFINE SECTION oSection2 	OF oSection1 TITLE OemToAnsi(STR0020)  //"Aportacion Voluntaria"
		DEFINE CELL NAME "DET1" 	OF oSection2 ALIAS " " SIZE TamSX3("RD_FILIAL")[1]		TITLE ""  ALIGN LEFT
   		DEFINE CELL NAME "DET2"  	OF oSection2 ALIAS " " SIZE TamSX3("RD_CC")[1]	 		TITLE ""  ALIGN LEFT
   		DEFINE CELL NAME "DET3"   	OF oSection2 ALIAS " " SIZE TamSX3("CTT_DESC01")[1]		TITLE ""  ALIGN LEFT
		DEFINE CELL NAME "DET12"  	OF oSection2 ALIAS " " SIZE TamSX3("RA_TPCIC")[1]		TITLE ""  ALIGN LEFT
		DEFINE CELL NAME "DET13" 	OF oSection2 ALIAS " " SIZE TamSX3("RA_CIC")[1]			TITLE ""  ALIGN LEFT
		DEFINE CELL NAME "DET14" 	OF oSection2 ALIAS " " SIZE TamSX3("RD_MAT")[1]			TITLE ""  ALIGN LEFT
   		DEFINE CELL NAME "DET4" 	OF oSection2 ALIAS " " SIZE TamSX3("RA_NOME")[1]		TITLE ""  ALIGN RIGHT
   		DEFINE CELL NAME "DET6"   	OF oSection2 ALIAS " " SIZE 21							TITLE ""  ALIGN RIGHT
	   	DEFINE CELL NAME "DET7"   	OF oSection2 ALIAS " " SIZE 21							TITLE ""  ALIGN RIGHT
	   	DEFINE CELL NAME "DET11"   	OF oSection2 ALIAS " " SIZE 21							TITLE ""  ALIGN RIGHT
	   	DEFINE CELL NAME "DET8"   	OF oSection2 ALIAS " " SIZE 21							TITLE ""  ALIGN RIGHT
	   	DEFINE CELL NAME "DET9"   	OF oSection2 ALIAS " " SIZE 21							TITLE ""  ALIGN RIGHT
	   	DEFINE CELL NAME "DET10"	OF oSection2 ALIAS " " SIZE TamSX3("RD_ENTIDAD")[1] 	TITLE ""  ALIGN LEFT

		oSection:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
		oSection:SetHeaderPage(.F.)		//Exibe Cabecalho da Secao
		oSection2:SetHeaderSection(.F.)	//Exibe Cabecalho da Secao
		oSection2:SetHeaderPage(.F.)	//Exibe Cabecalho da Secao
		oSection1:SetAutoSize()
		oSection2:SetAutoSize()

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint      Autor ³Alfredo Medrano     ³ Data ³29/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportPrint devera ser criada para todos    ³±±
±±³          ³os relatorios que poderao ser agendados pelo usuario.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatorio                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER016COL			                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local oSection 	:= oReport:Section(1)
Local oSection1	:= oReport:Section(1):Section(1)

Local cAliasQry	:= ""
Local cSitQuery	:= ""
Local cCatQuery	:= ""
Local cTitFil	:= ""
Local nReg		:= 0

Local cSitua  	:= MV_PAR05
Local cCateg	:= MV_PAR06
Local nConso	:= MV_PAR11
Local nSucPag	:= MV_PAR12

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Variaveis de Acesso do Usuario                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cAcessaSRD	:= &( " { || " + ChkRH( "GPER016COL" , "SRD" , "2" ) + " } " )
Private nOrdem		:= oSection:GetOrder()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
//³ mv_par01        //  ¿Sucursal?                               ³
//³ mv_par02        //  ¿Centro de Costo?                        ³
//³ mv_par03        //  ¿Matricula?                              ³
//³ mv_par04        //  ¿Nombre?                                 ³
//³ mv_par05        //  ¿Situaciones?                            ³
//³ mv_par06        //  ¿Categorias?                             ³
//³ mv_par07        //  ¿Proceso?                                ³
//³ mv_par08        //  ¿Procedimiento?                          ³
//³ mv_par09        //  ¿Periodo? 									  ³
//³ mv_par10        //  ¿No Pago?                                ³
//³ mv_par11        //  ¿Consolidado?                            ³
//³ mv_par12        //  ¿Suc en otra Pag?                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aInfo		:= {}
Private cDESCRIP	:= ""   //Descripción del Centro de Costos
Private nVOLSI		:= 0   	//Apo Vol Si Aplico
Private nVOLNO		:= 0   	//Apo Vol No Aplico
Private nSINAPO	:= 0	//Ret Fte sin Apo Vol
Private nRETCON	:= 0	//Retención Contingente
Private nRRETVOL := 0 // Ret. Rest. Voluntarios
Private cNombre	:= ""	//Nombre
Private nTotalR	:= 0   //total de registros generados por la consulta
Private cFilSRV    := xfilial("SRV")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	Por cada empleado totaliza las siguientes columnas:	 ³
//³		Apo Vol Si Aplico										 ³
//³		Apo Vol No Aplico 									 ³
//³		Ret Fte sin Apo Vol 									 ³
//³		Retención Contingente 								 ³
//³                                        				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	DEFINE BREAK oBreakPrj OF oSection1 WHEN oSection1:Cell("RD_MAT")  TITLE OemToAnsi(STR0019)  	// "TOTAL -> "
	DEFINE FUNCTION oTFil  NAME "oTFil"	 FROM oSection1:Cell("APOVOLSI") 	FUNCTION SUM BREAK oBreakPrj NO END SECTION
	DEFINE FUNCTION oTFil2 NAME "oTFil2" 	 FROM oSection1:Cell("APOVOLNO")	FUNCTION SUM BREAK oBreakPrj NO END SECTION

	DEFINE FUNCTION oTFil2 NAME "oTFil5" 	 FROM oSection1:Cell("RRESTVOL")	FUNCTION SUM BREAK oBreakPrj NO END SECTION

	DEFINE FUNCTION oTFil3 NAME "oTFil3" 	 FROM oSection1:Cell("RETSINAPO")	FUNCTION SUM BREAK oBreakPrj NO END SECTION
	DEFINE FUNCTION oTFil4 NAME "oTFil4" 	 FROM oSection1:Cell("RETENCON")	FUNCTION SUM BREAK oBreakPrj NO END SECTION

//reporte por sucursal (MV_PAR11=2) realizar un corte por cada RD_FILIAL diferente.
	If nConso==2 .And. nSucPag == 2
		//-- Quebrar e Totalizar por Sucursal
		DEFINE BREAK oBreakFil OF oSection WHEN oSection:Cell("RD_FILIAL")  TITLE OemToAnsi(STR0018)	  	// "TOTAL SUCURSAL -> "
		DEFINE FUNCTION FROM oSection:Cell("RD_MAT")		FUNCTION COUNT BREAK oBreakFil NO END REPORT
 		oBreakFil:OnBreak({|x,y|cTitFil:=OemToAnsi(STR0018)+x,fInfo(@aInfo,y)})	// "TOTAL FILIAL -> "
	   oBreakFil:SetTotalText({||cTitFil})

	ElseIf nConso == 2 .And. nSucPag == 1 //Realizar un salto de página si MV_PAR12=1

		//-- Quebrar e Totalizar por Sucursal
		DEFINE BREAK oBreakFil OF oSection WHEN oSection:Cell("RD_FILIAL")  TITLE OemToAnsi(STR0018)	PAGE BREAK  // "TOTAL SUCURSAL -> " / Salto de página
		DEFINE FUNCTION 	FROM oSection:Cell("RD_MAT")		FUNCTION COUNT BREAK oBreakFil NO END REPORT
 		oBreakFil:OnBreak({|x,y|cTitFil:=OemToAnsi(STR0018)+x,fInfo(@aInfo,y)})	// "TOTAL FILIAL -> "
	   oBreakFil:SetTotalText({||cTitFil})

	EndIF

#IFDEF TOP
	cAliasQry := GetNextAlias()

		//-- Modifica variaveis para a Query
	cSitQuery := ""
	For nReg:=1 to Len(cSitua)
		cSitQuery += "'"+Subs(cSitua,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cSitua)
			cSitQuery += ","
		Endif
	Next nReg
	cSitQuery := "%" + cSitQuery + "%"

	cCatQuery := ""
	For nReg:=1 to Len(cCateg)
		cCatQuery += "'"+Subs(cCateg,nReg,1)+"'"
		If ( nReg+1 ) <= Len(cCateg)
			cCatQuery += ","
		Endif
	Next nReg
	cCatQuery := "%" + cCatQuery + "%"

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	BEGIN REPORT QUERY oSection

	If nConso == 1
		cOrdem := "%SRD.RD_MAT%"
	ElseIf nConso == 2
		cOrdem := "%SRD.RD_FILIAL,SRD.RD_MAT%"
	Endif

//³identificadores de Cálculo de los conceptos:			³
//³								 ID_CALCULO				³
//³372	RET FTE AP VOL SI AP			?				³
//³375	RET FTE AP VOL NO AP			?				³
//³374	RET FTE SIN AP VOLUN			?				³
//³373	RET FTE R CONTINGENT			?				³
//³332	AFC APORT VOLUNTARIA			?				³
//³333	AFP APORT VOLUNTARIA			?				³
//³                                        				³
	BeginSql alias cAliasQry
		SELECT	SRD.RD_FILIAL, SRD.RD_CC, SRD.RD_MAT, SRD.RD_PD, SRA.RA_NOME ,RV_CODFOL, SUM(RD_VALOR)  Total
		FROM %table:SRA% SRA, %table:SRD% SRD, %table:SRV% SRV
		WHERE 	SRD.RD_MAT = SRA.RA_MAT 						AND
				SRD.RD_FILIAL = SRA.RA_FILIAL					AND
				SRA.RA_SITFOLH	IN	(%exp:Upper(cSitQuery)%)	AND
				SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%)	AND
	 	    	(RD_PD IN (SELECT RV_COD FROM  %table:SRV% WHERE RV_CODFOL='1349' AND RV_FILIAL = %exp:cFilSRV% ) OR 		//Retencion en la Fuente Aportacion Vol SI Aplico
       			RD_PD IN (SELECT RV_COD FROM  %table:SRV% WHERE RV_CODFOL='1346' AND RV_FILIAL = %exp:cFilSRV% )  OR 		//RETENCION EN LA FUENTE APO VOL NO APLICO
       			RD_PD IN (SELECT RV_COD FROM  %table:SRV% WHERE RV_CODFOL='0066' AND RV_FILIAL = %exp:cFilSRV% )  OR 		//RET REST VOLUNTARIOS
       			RD_PD IN (SELECT RV_COD FROM  %table:SRV% WHERE RV_CODFOL='1347' AND RV_FILIAL = %exp:cFilSRV% )  OR 		//RETENCION EN LA FUENTE RETENCION CONTINGENTE
       			RD_PD IN (SELECT RV_COD FROM  %table:SRV% WHERE RV_CODFOL='1348' AND RV_FILIAL = %exp:cFilSRV% )) AND //Retencion en la Fuente Sin Aportacion Voluntaria
       			RD_PD=RV_COD 									AND
	 	    	SRD.D_E_L_E_T_ = ' '							AND
				SRA.D_E_L_E_T_ = ' '  							AND
				SRV.D_E_L_E_T_ = ' ' 							AND
				RV_FILIAL = %exp:cFilSRV%
      	GROUP BY RD_FILIAL,RD_CC, RD_MAT, RD_PD, RA_NOME, RV_CODFOL
		ORDER BY %exp:cOrdem%
	EndSql
	/*  Prepara relatorio para executar a query gerada pelo Embedded SQL passando como
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados
	pela funcao MakeSqlExpr para serem adicionados a query 	*/
	END REPORT QUERY oSection PARAM mv_par01, mv_par02, mv_par03, mv_par04,mv_par07,mv_par08,mv_par09,mv_par10
	Count to nTotalR  	// obtiene el total de registros

#ENDIF

 //-- Condición de impresión del Empleado
fGP16COLCond(cAliasQry, oReport)
oReport:SetMeter(100)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Termino do Relatorio                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFNDEF TOP
	dbSelectArea( "SRD" )
	Set Filter to
	dbSetOrder(1)
	Set Device To Screen
#ENDIF

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fGP16COLCond  ³ Autor ³ Alfredo Medrano  ³ Data ³30/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica condición para impresión de la línea del Reporte  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER016COL - Colombia                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGP16COLCond(cAliasQry, oReport)
Local lRet	   := .T.
Local nCTT		:= RETORDEM("CTT","CTT_FILIAL+CTT_CUSTO") // regresa el índice
Local aAreaLoc 	:= getArea()
Local oSection	:= oReport:Section(1)
Local oSection1	:= oReport:Section(1):Section(1)
Local oSection2	:= oReport:Section(1):Section(1):Section(1)
Local cMat		:= ""
Local cCC			:= ""
Local cFilGrp		:= ""
Local nX			:= 0
Private cFil		:= ""
Private cCenC	:= ""
Private cMatri	:= ""
Private cNombre	:= ""
Private cTipoID	:= ""
Private cNumID	:= ""
Default cAliasQry	:= "SRD"


	(cAliasQry )->(DBGOTOP()) // posiciona al primer registro del archivo de datos
	WHILE ( cAliasQry )->(!eof())
		oReport:IncMeter()
		If oReport:Cancel() //termina proceso si se cancela el reporte
			Exit
		EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Si el empleado existe varias veces solo se imprimirá una vez 	³
//³	y sus totales por concepto se mostrarán en la misma fila 		³
//³ a menos que éste cambie de Centro de Costos						³
//³                                        							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

		nX := nX+1
		If ( cAliasQry )->RD_MAT != cMat .And. cMat!=""
			ImprimeLinea(oSection1,oSection) //imprime línea
			oSection1:Finish()//Fin de la seccion1
			oReport:SkipLine()// Salto de línea
			AportVol(oSection2,oSection1) //Imprime las portaciones voluntarias del empleado
			oReport:SkipLine()// Salto de línea
			//inicializa variables privadas
			nVOLSI		:= 0   	//Apo Vol Si Aplico
			nVOLNO		:= 0   	//Apo Vol No Aplico
			nSINAPO	:= 0	//Ret Fte sin Apo Vol
			nRETCON	:= 0	//Retención Contingente
			nRRETVOL := 0 //Ret. Rest. Voluntarios

		ElseIf  ( cAliasQry )->RD_MAT == cMat .And. cCC!="" .And. ( cAliasQry )->RD_CC != cCC  //Imprime en otra línea mismo empleado - diferente Centro de costo
			ImprimeLinea(oSection1,oSection) // imprime Línea
			//inicializa variables privadas
			nVOLSI		:= 0   	//Apo Vol Si Aplico
			nVOLNO		:= 0   	//Apo Vol No Aplico
			nSINAPO	:= 0	//Ret Fte sin Apo Vol
			nRETCON	:= 0	//Retención Contingente
			nRRETVOL := 0 //Ret. Rest. Voluntarios
		EndIF

		If (cAliasQry)->RV_CODFOL =='1349'//Apo Vol Si Aplico
			nVOLSI := (cAliasQry)->Total
		ElseIf (cAliasQry)->RV_CODFOL =='1346'
			nVOLNO := (cAliasQry)->Total //Apo Vol No Aplico
		ElseIf (cAliasQry)->RV_CODFOL =='0066'
			nRRETVOL := (cAliasQry)->Total //Ret. Rest. Voluntarios
		ElseIf (cAliasQry)->RV_CODFOL =='1348'
			nSINAPO := (cAliasQry)->Total //Ret Fte sin Apo Vol
		ElseIf (cAliasQry)->RV_CODFOL =='1347'
			nRETCON := (cAliasQry)->Total //Retención Contingente
		End
		cDESCRIP 	:= POSICIONE( "CTT", nCTT, XFILIAL("CTT") + (cAliasQry)->RD_CC, "CTT_DESC01" ) //Retorna el centro de costos
		cFil		:= ( cAliasQry )->RD_FILIAL  //Sucursal
		cCenC		:= ( cAliasQry )->RD_CC		//Centro de Costo
		cMatri		:= ( cAliasQry )->RD_MAT		//Matrícula
		cNombre	:= ( cAliasQry )->RA_NOME	//Nombre
		cTipoID	:= POSICIONE( "SRA", 1, XFILIAL("SRA") + (cAliasQry)->RD_MAT, "RA_TPCIC" ) //Tipo ID
		cNumID	:= POSICIONE( "SRA", 1, XFILIAL("SRA") + (cAliasQry)->RD_MAT, "RA_CIC" )   // NUM ID

		cMat 	 := ( cAliasQry )->RD_MAT //asignamos la matricula
		cCC		 := ( cAliasQry )->RD_CC//asignameos Centro de costos
		cFilGrp := ( cAliasQry )->RD_FILIAL//asignameos Centro de costos

		If nX == nTotalR
			ImprimeLinea(oSection1,oSection)
			oSection1:Finish()
			oReport:SkipLine()
			AportVol(oSection2,oSection1)
			nVOLSI := 0
			nVOLNO := 0
			nSINAPO:= 0
			nRETCON:= 0
			nRRETVOL := 0 //Ret. Rest. Voluntarios
		EndIf

		( cAliasQry )->(dbSkip())
	ENDDO
	oSection:Finish()
	oSection2:Finish()

	( cAliasQry )->(dbCloseArea())
	restArea(aAreaLoc)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImprimeLinea()  ³ Autor ³ Alfredo Medrano ³Data ³01/10/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Línea para el Reporte                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPER016COL - Colombia                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ImprimeLinea(oSection1, oSection)

	If cFil != ""
		oSection:Init()
		oSection:cell("RD_FILIAL"):Hide()
		oSection:cell("RD_MAT"):Hide()
		oSection:cell("RD_FILIAL"):SetSize(0)
		oSection:cell("RD_MAT"):SetSize(0)
		oSection:cell("RD_FILIAL"):SetValue(cFil )
		oSection:cell("RD_MAT"):SetValue(cMatri )
		oSection:PrintLine()

		oSection1:cell("RD_FILIAL"):SetValue(cFil )
		oSection1:cell("RD_CC"):SetValue(cCenC )
		oSection1:cell("CTT_DESC01"):SetValue(cDESCRIP)
		oSection1:cell("RD_MAT"):SetValue(cMatri )
		oSection1:cell("RA_NOME"):SetValue(cNombre )
		oSection1:cell("RA_TPCIC"):SetValue(cTipoID )  //Tipo ID
		oSection1:cell("RA_CIC"):SetValue(cNumID )  //Num ID
		oSection1:cell("APOVOLSI"):SetValue(nVOLSI)	//Apo Vol Si Aplico
		oSection1:cell("APOVOLNO"):SetValue(nVOLNO)	//Apo Vol No Aplico
		oSection1:cell("RETSINAPO"):SetValue(nSINAPO)	//Ret Fte sin Apo Vol
		oSection1:cell("RETENCON"):SetValue(nRETCON)	//Retención Contingente
		oSection1:cell("RRESTVOL"):SetValue(nRRETVOL) //Ret. Rest. Voluntarios
		oSection1:Init()
		oSection1:PrintLine()
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AportVol ³ Autor ³ Alfredo Medrano     ³  Data ³ 01/11/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ •Obtiene Datos de Aportaciones Voluntarias del Empleado    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AportVol()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³			   ³		³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AportVol(oSection2,oSection1)
	Local aDatos  := {}
	Local aArea	   := getArea()
	Local cTmpPer := CriaTrab(Nil,.F.)
	Local cQuery  := ""
	Local nTotal1 := 0
	Local nTotal2 := 0
	Local nTotal3 := 0
	Local nTotal4 := 0
	Local nTotal5 := 0
	Local nValT	   := 0
	Local nValTT    := 0
	
	Local nTApoVol	:= 0
	Local nCoun	    := 0

	cQuery := " SELECT RD_FILIAL,RD_MAT, RD_PD, RD_VALOR, RD_ENTIDAD,RV_CODFOL, RV_DESC"
	CQuery += " FROM " + RetSqlName("SRD") +" SRD, " + RetSqlName("SRV") +" SRV "
 	cQuery += " WHERE "
 	cQuery += " RD_PD = RV_COD "
 	cQuery += " AND RD_FILIAL='"+ cFil +"' " 	//sucursal
    cQuery += " AND RD_MAT='"+ cMatri +"' " 	//Matricula

   	If	!Empty( mv_par07 )
   		cQuery += " AND " + mv_par07  		//Procesos
  	EndIf

  	If	!Empty( mv_par08 )
  		cQuery += " AND " + mv_par08  		//Procedimiento de Cálculo
  	EndIf

  	If	!Empty( mv_par09 )
  		cQuery += " AND " + mv_par09  		//Periodos
  	EndIf

  	If	!Empty( mv_par10 )
  		cQuery += " AND " + mv_par10  		//Número de Pago
  	EndIf

  	cQuery += " AND (RD_PD IN (SELECT RV_COD FROM " + RetSqlName("SRV") + " WHERE RV_CODFOL='1344' AND RV_FILIAL = '" + cFilSRV + "') " //Aportación Voluntaria AFC
    cQuery += " OR RD_PD IN (SELECT RV_COD FROM " + RetSqlName("SRV") + " WHERE RV_CODFOL='1345' AND RV_FILIAL = '" + cFilSRV + "') "  //Aportación Voluntaria AFP
    cQuery += " OR RD_PD IN (SELECT RV_COD FROM " + RetSqlName("SRV") + " WHERE RV_CODFOL='1356' AND RV_FILIAL = '" + cFilSRV + "')) "  //Aportación Voluntaria Empresa

  	cQuery += " AND SRD.D_E_L_E_T_ = ' ' "
  	cQuery += " AND SRV.D_E_L_E_T_ = ' ' "
  	cQuery += " AND RV_FILIAL = '" + cFilSRV + "'"

  	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpPer,.T.,.T.)
 	Count to nTApoVol
	(cTmpPer)->(dbgotop())//primer registro de tabla

	nValT := 0
	While  (cTmpPer)->(!EOF())

		IF (cTmpPer)-> RV_CODFOL =='1344'
			nValT += (cTmpPer)->RD_VALOR
		ElseIf  (cTmpPer)-> RV_CODFOL =='1345'
			nValT += (cTmpPer)->RD_VALOR
		ELseIf (cTmpPer)-> RV_CODFOL =='1356'
			nValT += (cTmpPer)->RD_VALOR
		EndIf

		(cTmpPer)-> (dbskip())
	EndDo

	(cTmpPer)->(dbgotop())//primer registro de tabla

	While  (cTmpPer)->(!EOF())
		nCoun := nCoun + 1

		//toma los totales para realizar el calculo de las aportaciones Voluntarias
		nVOLSI   :=oSection1:GetFunction("oTFil"):SectionValue()	//Apo Vol Si Aplico
		nVOLNO   :=oSection1:GetFunction("oTFil2"):SectionValue()	//Apo Vol No Aplico
		nSINAPO  :=oSection1:GetFunction("oTFil3"):SectionValue()	//Ret Fte sin Apo Vol
		nRETCON  :=oSection1:GetFunction("oTFil4"):SectionValue()	//Retención Contingente
		nRRETVOL :=oSection1:GetFunction("oTFil5"):SectionValue()	//Ret. Rest. Voluntarios

		IF (cTmpPer)-> RV_CODFOL =='1344'
			nValTT := (cTmpPer)->RD_VALOR
		ElseIf  (cTmpPer)-> RV_CODFOL =='1345'
			nValTT := (cTmpPer)->RD_VALOR
		ELseIf (cTmpPer)-> RV_CODFOL =='1356'
			nValTT := (cTmpPer)->RD_VALOR
		EndIf

		nTotal1 := ( ( ( nValT ) / nVOLSI  ) * nValTT )
		nTotal2 := ( ( ( nValT ) / nVOLNO  ) * nValTT )
		nTotal3 := ( ( ( nValT ) / nSINAPO ) * nValTT )
		nTotal4 := ( ( ( nValT ) / nRETCON ) * nValTT )
		nTotal5 := ( ( ( nValT ) / nRRETVOL) * nValTT )

		oSection2:cell("DET1" ):SetValue( space(TamSX3("RD_FILIAL")[1]))
		oSection2:cell("DET2" ):SetValue( (cTmpPer)->RD_PD)
		oSection2:cell("DET3" ):SetValue( (cTmpPer)->RV_DESC )
		oSection2:cell("DET12"):SetValue( space(TamSX3("RA_TPCIC")[1]))
		oSection2:cell("DET13"):SetValue( space(TamSX3("RA_CIC")[1]	))
		oSection2:cell("DET14"):SetValue( space(TamSX3("RD_MAT")[1]	))
		oSection2:cell("DET4" ):SetValue( TRANSFORM((cTmpPer)->RD_VALOR, "@E 99,999,999,999.99")  )
		oSection2:cell("DET6" ):SetValue( TRANSFORM(nTotal1, "@E 99,999,999,999.99") )
		oSection2:cell("DET7" ):SetValue( TRANSFORM(nTotal2, "@E 99,999,999,999.99") )
		oSection2:cell("DET11"):SetValue( TRANSFORM(nTotal5, "@E 99,999,999,999.99") ) //Ret. Rest Voluntarios
		oSection2:cell("DET8" ):SetValue( TRANSFORM(nTotal3, "@E 99,999,999,999.99") )
		oSection2:cell("DET9" ):SetValue( TRANSFORM(nTotal4, "@E 99,999,999,999.99") )
		oSection2:cell("DET10"):SetValue( (cTmpPer)->RD_ENTIDAD)

		oSection2:Init()
		oSection2:PrintLine()

		(cTmpPer)-> (dbskip())
	EndDo
	(cTmpPer)->( dbCloseArea())
	restArea(aArea)

Return aDatos
