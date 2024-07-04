#INCLUDE "PROTHEUS.CH"   
#INCLUDE "report.ch"    
#INCLUDE "GPER911COL.ch" 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPER911COL³ Autor ³ Tiago Malta           ³ Data ³ 08/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao de Provisão - Colombia                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER911COL                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Chamado ³  Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Ademar Jr. ³04/09/12³         ³-Ajustes diversos no MV_PAR01 ==4(VAC) ³±±
±±³ Ademar Jr. ³07/01/13³ TETHSC  |-Corrigido o ID a ser considerado,     ³±±
±±³            ³        |         |quando Impr.Primas,na variavel DIASCAUS³±±
±±³Miguel Rojas³20/10/13³COL11.8RH| Modificaciones para Modelo 2          ³±±
±±³Miguel Rojas³09/01/14³COL11.8RH|Modificacion objeto oSection2. Rechazo ³±±
±±³Miguel Rojas³24/01/14³COL11.8RH³Modificacion Query filtro between      ³±±
±±³Miguel Rojas³27/01/14³COL11.8RH³Etiqueta SBC vacaciones sin imprimir   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Camargo   ³27/03/14³TPCXQZ   ³-Ajustes en id's de calc salían mal las³±±
±±³M.Camargo   ³27/03/14³TPCXQZ   ³cantidades en los 4 reportes.          ³±±
±±³Jonathan Glz³17/02/16³PCREQ-   ³Localización GPE Colombia v12.         ³±±
±±³            ³        ³    9393 ³Se elimina error con comilla sin cerrar³±±
±±³            ³        ³         ³y se elimina codigo obsoleto del fuente³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER911COL()
Local	oReport                             
Local	aArea 	:= GetArea()

Private cString	:= "SRA"				// alias do arquivo principal (Base)
Private lCorpManage		:= fIsCorpManage(FWGrpCompany())

If lCorpManage
	Private lEmpFil	  	:= !Empty(FWSM0Layout(cEmpAnt, 1))  
	Private cLayoutGC 	:= FWSM0Layout(cEmpAnt)
	Private nStartEmp	:= At("E",cLayoutGC)
	Private nStartUnN	:= At("U",cLayoutGC)
	Private nEmpLength := Len(FWSM0Layout(cEmpAnt, 1))
	Private nUnNLength := Len(FWSM0Layout(cEmpAnt, 2))
EndIf

oReport := ReportDef()
oReport:PrintDialog()                      

RestArea( aArea )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef ³ Autor ³ Tiago Malta           ³ Data ³ 09.08.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definicao do relatorio                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local oBreakPg                                    
Local oSection1
Local oSection2
Local cTitulo := STR0001
Local cPerg   := "GPER911COL"

Pergunte( cPerg , .F. )
                         
//-- Objeto Function               

	//-- Inicio definicao do Relatorio
	   DEFINE	 REPORT oReport NAME "GPER911COL" TITLE OemToAnsi(cTitulo)  PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION ""
 	        oReport:SetLandscape()

		//-- Section de Funcionario
		DEFINE SECTION oSection1 OF oReport TABLES "SRA" TITLE OemToAnsi(cTitulo) TOTAL IN COLUMN
		    	oSection1 :SetHeaderPage()
			
			// CELL HEADER BORDER  
    	   DEFINE CELL NAME "RA_FILIAL"  	OF oSection1 ALIAS cString SIZE 10 //
		 	DEFINE CELL NAME "RA_MAT" 	   OF oSection1 ALIAS cString          //1
			DEFINE CELL NAME "RA_NOME"		OF oSection1 ALIAS cString          //2
			DEFINE CELL NAME "RA_RG"			OF oSection1 ALIAS cString TITLE oemToansi(STR0031) SIZE 20           
			DEFINE CELL NAME "RA_ADMISSA"	OF oSection1 ALIAS cString          //4 
			DEFINE CELL NAME "DIASCAUS"		OF oSection1 ALIAS cString TITLE oemToansi(STR0019)  SIZE 15 ALIGN RIGHT HEADER ALIGN RIGHT  // 5 
			DEFINE CELL NAME "RA_SALARIO"	OF oSection1 ALIAS cString TITLE oemToansi(STR0032)  Size 16 ALIGN RIGHT HEADER ALIGN RIGHT                              // 6     
			
			oSection1:Cell("RA_FILIAL"):Disable()

//* Seccion 2 corte por sucursal
   oSection2 := TRSection():New(oReport,,,)
	oSection2:SetHeaderPage()
	oSection2:SetLineBreak(.F.) //.T. imprime una o mas lineas - .F.= no imprime linea  
	TRCell():New(oSection2,OemToAnsi(STR0029),'','',/*Picture*/,60,/*lPixel*/,/*{|| code-block de impressao }*/) //Sucursal
Return oReport   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReport ºAutor  ³Tiago Malta         º Data ³  09/08/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function PrintReport(oReport)     
//-- Objeto
Local oSection1 := oReport:Section(1) 		// Funcionario
Local oSection2 := oReport:Section(2)		// Sucursal

//-- String
Local oBreakFil
Local oBreakEFil
Local cTitFun
Local cFiltro		:= ""
Local cSitQuery 	:= ""
Local cCatQuery 	:= ""
Local cProdPagoQ	:= ""
Local cQrySRA		:= "SRA"  
Local nReg		:= 0
Local cSituacao 	:= MV_PAR06
Local cCategoria	:= MV_PAR07
Local cProcesso	:= MV_PAR08
Local cTipoNomina:= MV_PAR09
Local cPeriodo	:= MV_PAR10
Local cNrPgto		:= MV_PAR11
Local nConsolida	:= MV_PAR12
Local cPrefx    	:= "" 
Local cAliasAux 	:= ""
Local cTitEFil  	:= ""
Local cMes 		:=""
Local cAnio 		:= ""
Local cSucursal 	:= ""
Local cPeriodo1	:= SubStr(cPeriodo,1,4)
Local cPerg   := "GPER911COL"

cPeriodo1 := cPeriodo1+"01"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01        //  Tipo de Informe                          ³	
	//³ mv_par02        //  Filial                                   ³
	//³ mv_par03        //  Centro de Costo                          ³
	//³ mv_par04        //  Matricula                                ³
	//³ mv_par05        //  Nome                                     ³
	//³ mv_par06        //  Situacao                                 ³
	//³ mv_par07        //  Categoria                                ³
	//³ mv_par08        //  Processo                                 ³
	//³ mv_par09        //  Proced de nomina Provision/Consolidación ³
	//³ mv_par10        //  Periodo                                  ³
    //³ mv_par11        //  Nr Pago                                  ³
    //³ mv_par12        //  1 Consolidado / 2 Sucursal               ³ 
	//³ mv_par13        //  Prod. Pago                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(cPerg) // Convierte grupo de preguntas a expresiones SQL
If !Empty(MV_PAR02)
       cFiltro += "AND SRA."+SubStr(MV_PAR02,2,Len(MV_PAR02)-2)		
EndIf

If !Empty(MV_PAR03)
      cFiltro += "AND SRA."+SubStr(MV_PAR03,2,Len(MV_PAR03)-2)   
EndIf

If !Empty(MV_PAR04)
	cFiltro += "AND SRA."+SubStr(MV_PAR04,2,Len(MV_PAR04)-2)	
EndIf 

If !Empty(MV_PAR05)
	cFiltro += "AND SRA."+SubStr(MV_PAR05,2,Len(MV_PAR05)-2)
EndIf

//--- MV_PAR06
For nReg:=1 to Len(cSituacao)
	cSitQuery += "'"+Subs(cSituacao,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cSituacao)
		cSitQuery += "," 
	Endif
Next nReg        
//-- MV_PAR07
cCategoria = cCategoria
For nReg:=1 to Len(cCategoria)
    cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCategoria)
		cCatQuery += "," 
	Endif
Next nReg

Dbselectarea("RCH")
RCH ->(DBSETORDER(1))
RCH ->(	Dbseek(xFilial("RCH")+cProcesso+cPeriodo+cNrPgto))
IF EMPTY(RCH->RCH_DTFECH)
	cPrefx    := "RC"
	cAliasAux := "SRC"
ELSE
	cPrefx    := "RD" 
	cAliasAux := "SRD"
ENDIF

// MV_PAR13
If !Empty(MV_PAR13)
	cProdPagoQ := " AND "+strTran(SubStr(MV_PAR13,2,Len(MV_PAR13)-2), "RY_CALCULO", cPreFx+"_ROTEIR ")
EndIf

cMes = RCH->RCH_MES
cAnio = RCH->RCH_ANO

cQuery := "SELECT RA_FILIAL,RA_MAT,RA_NOME,RA_ADMISSA,RA_SALARIO,RA_CIC,RA_RG" 

IF MV_PAR01 == 1	//-Cesantias
    // STR0023 ->"Consolidación de Cesantías"
	oReport:CTITLE := STR0023 + " " +RCH_MES+"/"+RCH_ANO
	DEFINE CELL NAME "SBCCESAN"		OF oSection1 ALIAS cString TITLE oemToansi(STR0037) SIZE 16 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT //"SBC.Int.Cesantías"
	DEFINE CELL NAME "CESCAUSA"		OF oSection1 ALIAS cString TITLE oemToansi(STR0003) SIZE 16 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT //STR0003 "Ant.Cesantías"
	DEFINE CELL NAME "ANTECESA"		OF oSection1 ALIAS cString TITLE oemToansi(STR0002) SIZE 16 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT //STR0002 "Acum.Cesantías"
	DEFINE CELL NAME "AJUSTPROV"	OF oSection1 ALIAS cString TITLE oemToansi(STR0006) SIZE 16 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT //STR0006 "Provisión"

	IF cPreFX == "RC"
	   		cQuery := "SELECT RA_FILIAL,RA_MAT,RA_NOME,RA_ADMISSA,RA_SALARIO,RA_CIC,RA_RG,RC_MAT"
	ELSE
			cQuery := "SELECT RA_FILIAL,RA_MAT,RA_NOME,RA_ADMISSA,RA_SALARIO,RA_CIC,RA_RG"
	EndIF

	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0904')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS DIASCAUS "					
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('1025')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS SBCCESAN " 

	if cPreFx == "RD"    	   
	    cQuery += ", (SELECT SUM(CASE WHEN "+cPreFx+"_PD = '"+FGETCODFOL('0889')+"' THEN "
    	cQuery += cPrefx+"_VALOR ELSE 0 END)"
    	cQuery += " FROM "+RetSqlName(cAliasAux)+" "+ cAliasAux 
    	cQuery += " WHERE "+cPreFx+"_PROCES ='"+cProcesso+"'"
       	cQuery += cProdPagoQ+" AND ("
       	cQuery += cPreFx+"_PERIODO BETWEEN '"+cPeriodo1+"' AND '"+cPeriodo+"') AND "
       	cQuery += cPreFX+"_MAT = RA_MAT) AS CESCAUSA"
	
	else
	   cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0889')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS CESCAUSA"	 
	   //cPrefx    := "RD"   /// Cambia PrFx para los campos RD_   
	   //cAliasAux := "SRD" /// Cambia cAliasAux para la consulta desde SRD
      cPrefx    := "RC"   /// Restaurando valor Original del _RC   
	   cAliasAux := "SRC" /// Restaurando valor Origial del Alias SRC
	       
	endif
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0890')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS ANTECESA " //Columna 9 
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0897')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS AJUSTPROV  "
	

ELSEIF MV_PAR01 == 2	//-Interesses de Cesantias
	IF cPreFX == "RC"
	   		cQuery := "SELECT RA_FILIAL,RA_MAT,RA_NOME,RA_ADMISSA,RA_SALARIO,RA_CIC,RA_RG,RC_MAT"
	ELSE
			cQuery := "SELECT RA_FILIAL,RA_MAT,RA_NOME,RA_ADMISSA,RA_SALARIO,RA_CIC,RA_RG"
	EndIF

        //STR0024 ->"Consolidación de Int-Cesantías"  
	oReport:CTITLE := STR0024+ " "+RCH_MES+"/"+RCH_ANO
   DEFINE CELL NAME "BASELIQUI"	OF oSection1 ALIAS cString TITLE oemToansi(STR0033) SIZE 20 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT //STR0033 "SBC.Int.Cesantías"
	DEFINE CELL NAME "CESATUAL"		OF oSection1 ALIAS cString TITLE oemToansi(STR0008) SIZE 20 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT //STR0008 "Acum. Cesantía"
	DEFINE CELL NAME "INTERCES"		OF oSection1 ALIAS cString TITLE oemToansi(STR0007) SIZE 20 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT //STR0007 "Int.Cesantías"
	DEFINE CELL NAME "ANTINTCES"	OF oSection1 ALIAS cString TITLE oemToansi(STR0009) SIZE 20 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT //STR0009 "Ant.Int.Ces. "			
	DEFINE CELL NAME "PRVINTCES"	OF oSection1 ALIAS cString TITLE oemToansi(STR0010) SIZE 20 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT //STR0010 "Acum.Int.Ces."						
	DEFINE CELL NAME "AJUSTPROV"	OF oSection1 ALIAS cString TITLE oemToansi(STR0038) SIZE 20 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT //STR0011 "Prov.Int.Ces."
		
   cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0905')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS DIASCAUS "   //0905 1026  0890  1028  0913 0906  1243 
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('1026')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS BASELIQUI "
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0890')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS CESATUAL "
	
	if cPreFx == "RD"
		cQuery += ", (SELECT SUM(CASE WHEN "+cPreFx+"_PD = '"+FGETCODFOL('1028')+"' THEN "
    	cQuery += cPrefx+"_VALOR ELSE 0 END)"
    	cQuery += " FROM "+RetSqlName(cAliasAux)+" "+ cAliasAux 
    	cQuery += " WHERE "+cPreFx+"_PROCES ='"+cProcesso+"'"
       	cQuery += cProdPagoQ+" AND ("
       	cQuery += cPreFx+"_PERIODO BETWEEN '"+cPeriodo1+"' AND '"+cPeriodo+"') AND "
       	cQuery += cPreFX+"_MAT = RA_MAT) AS INTERCES "
						
    else
	   cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('1028')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS INTERCES"
       cPrefx    := "RC"   /// Restaurando valor Original del _RC   
	   cAliasAux := "SRC" /// Restaurando valor Origial del Alias SRC
       
	endif
	
    if cPreFx == "RD"
    	cQuery += ", (SELECT SUM(CASE WHEN "+cPreFx+"_PD = '"+FGETCODFOL('0913')+"' THEN "
    	cQuery += cPrefx+"_VALOR ELSE 0 END)"
    	cQuery += " FROM "+RetSqlName(cAliasAux)+" "+ cAliasAux 
    	cQuery += " WHERE "+cPreFx+"_PROCES ='"+cProcesso+"'"
       	cQuery += cProdPagoQ+" AND ("
       	cQuery += cPreFx+"_PERIODO BETWEEN '"+cPeriodo1+"' AND '"+cPeriodo+"') AND "
       	cQuery += cPreFX+"_MAT = RA_MAT) AS ANTINTCES "    
      
	else
	   cQuery += ",SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0913')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS ANTINTCES"
	  
       cPrefx    := "RC"   /// Restaurando valor Original del _RC   
	   cAliasAux := "SRC" /// Restaurando valor Origial del Alias SRC
       
	endif
    
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0906')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS PRVINTCES "			
	
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('1243')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS AJUSTPROV "
	
ELSEIF MV_PAR01 == 3	//-Primas

        //STR0021 ->"Consolidacion de  primas"
	oReport:CTITLE := STR0021 + " " + RCH_MES+"/"+RCH_ANO
	IF cPreFX == "RC"
	   cQuery := "SELECT RA_FILIAL,RA_MAT,RA_NOME,RA_ADMISSA,RA_SALARIO,RA_CIC,RA_RG,RC_MAT"
	ELSE
		cQuery := "SELECT RA_FILIAL,RA_MAT,RA_NOME,RA_ADMISSA,RA_SALARIO,RA_CIC,RA_RG"
	EndIF	   

   DEFINE CELL NAME "BASELIQUI"    OF oSection1 ALIAS cString TITLE oemToansi(STR0034) SIZE 20 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT // 7								
   DEFINE CELL NAME "PRICAUSA"     OF oSection1 ALIAS cString TITLE oemToansi(STR0012) SIZE 20 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
	DEFINE CELL NAME "PROVPRIMA"    OF oSection1 ALIAS cString TITLE oemToansi(STR0013) SIZE 20 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT		
	DEFINE CELL NAME "AJUSTPROV"    OF oSection1 ALIAS cString TITLE oemToansi(STR0035) SIZE 20 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT	
	
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0908')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS DIASCAUS " 
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('1074')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS BASELIQUI "
	
    if cPreFx == "RD"
    
        cQuery += ", (SELECT SUM(CASE WHEN ("+cPreFx+"_PD = '"+FGETCODFOL('1032')+"') THEN "
    	cQuery += cPrefx+"_VALOR ELSE 0 END)"
    	cQuery += " FROM "+RetSqlName(cAliasAux)+" "+ cAliasAux 
    	cQuery += " WHERE "+cPreFx+"_PROCES ='"+cProcesso+"'"
       	cQuery += cProdPagoQ+" AND ("
       	cQuery += cPreFx+"_PERIODO BETWEEN '"+cPeriodo1+"' AND '"+cPeriodo+"') AND "
       	cQuery += cPreFX+"_MAT = RA_MAT) AS PRICAUSA "
             	
	else	
	   cQuery += " ,SUM(CASE WHEN ("+cPrefx+"_PD = '"+FGETCODFOL('1032')+"' ) THEN "+cPrefx+"_VALOR ELSE 0 END) AS PRICAUSA"
	  
       cPrefx    := "RC"   /// Restaurando valor Original del _RC   
	   cAliasAux := "SRC" /// Restaurando valor Origial del Alias SRC
       
	endif
	
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0909')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS PROVPRIMA  " 
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0907')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS AJUSTPROV  "
	
ELSEIF MV_PAR01 == 4	//-Vacaciones
    //STR0022 ->"Consolidación de Vacaciones"
	oReport:CTITLE := STR0022 +" "+RCH_MES+"/"+RCH_ANO
        
   DEFINE CELL NAME "BASELIQ"   OF oSection1 ALIAS cString TITLE oemToansi(STR0036) SIZE 16 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT   
	DEFINE CELL NAME "TOTVACDIA"   OF oSection1 ALIAS cString TITLE oemToansi(STR0014) SIZE 16 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
	DEFINE CELL NAME "VACDISFRU"   OF oSection1 ALIAS cString TITLE oemToansi(STR0016) SIZE 16 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
	DEFINE CELL NAME "VACDIAS"     OF oSection1 ALIAS cString TITLE oemToansi(STR0030) SIZE 16 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
	DEFINE CELL NAME "PENDVALOR"   OF oSection1 ALIAS cString TITLE oemToansi(STR0017) SIZE 16 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
	DEFINE CELL NAME "PROVVAC"     OF oSection1 ALIAS cString TITLE oemToansi(STR0006) SIZE 16 PICTURE "@E 999,999,999,999.99" ALIGN RIGHT HEADER ALIGN RIGHT
	
	oSection1:Cell("DIASCAUS"):Disable()		
	
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0075')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS BASELIQ"
	
	cQuery += " ,(SELECT SUM( RF_DFERVAT + RF_DFERAAT ) "   //-- Derecho=SUMA(RF_DFERVAT)+SUMA(RF_DFERAAT)
	cQuery += " FROM  "+ RetSqlName("SRF") + " WHERE  "
	cQuery += " 		RF_FILIAL = SRA.RA_FILIAL AND "
	cQuery += " 		RF_MAT    = SRA.RA_MAT    AND "
	cQuery += "			D_E_L_E_T_ = ' ' ) AS TOTVACDIA  "   //--"Vacaciones Días"
	       
	cQuery += " ,( SELECT SUM(RF_DFERANT ) "   ///Original RF_DFERANT+RF_FERPAGA   SUMA(RF_DFERANT) (Espec. Colombia)
	cQuery += " FROM  "+ RetSqlName("SRF") + " WHERE  "
	cQuery += " 		RF_FILIAL = SRA.RA_FILIAL AND "
	cQuery += " 		RF_MAT    = SRA.RA_MAT    AND "
	cQuery += "			D_E_L_E_T_ = ' ' ) AS VACDISFRU  "  //--"Vac.Disfrutadas"
	
	cQuery += " ,( SELECT SUM( RF_DFERVAT + RF_DFERAAT ) - "   //--SUMA(RF_DFERVAT)+SUMA(RF_DFERAAT)- SUMA(RF_DFERANT) 
	cQuery += "           SUM( RF_DFERANT ) "
	cQuery += " FROM  "+ RetSqlName("SRF") + " WHERE  "
	cQuery += " 		RF_FILIAL = SRA.RA_FILIAL AND "
	cQuery += " 		RF_MAT    = SRA.RA_MAT    AND "
	cQuery += "			D_E_L_E_T_ = ' ' ) AS VACDIAS  "  //--"Días Pendientes"
	
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0911')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS PENDVALOR "  //#define STR0017 "Imp.Pendientes" */
	
	cQuery += " ,SUM(CASE WHEN "+cPrefx+"_PD = '"+FGETCODFOL('0104')+"' THEN "+cPrefx+"_VALOR ELSE 0 END) AS PROVVAC "   //#define STR0018 "Prov.Vacaciones"
	
Endif

cQuery += "	FROM "	+ RetSqlName("SRA") + " SRA " 
cQuery += "	INNER JOIN " + RetSqlName(cAliasAux) + " "+cAliasAux+" ON "
cQuery += "           "+cAliasAux+"."+cPrefx+"_FILIAL     = SRA.RA_FILIAL      AND " 
cQuery += "			  "+cAliasAux+"."+cPrefx+"_MAT        = SRA.RA_MAT         AND " 
cQuery += "	  		  "+cAliasAux+"."+cPrefx+"_PERIODO    = '"+cPeriodo+"'     AND " 
cQuery += "	   		  "+cAliasAux+"."+cPrefx+"_ROTEIR     = '"+cTipoNomina+"'              AND " 
cQuery += "	   		  "+cAliasAux+"."+cPrefx+"_SEMANA     = '"+cNrPgto +"'     AND "
cQuery += "	   		  "+cAliasAux+".D_E_L_E_T_ = ' ' "		 

cQuery += "		WHERE SRA.RA_SITFOLH	IN	("+cSitQuery+") 	AND " 
cQuery += "			  SRA.RA_CATFUNC	IN	("+cCatQuery+") 	AND " 
cQuery += "			  SRA.RA_PROCES   =  '"+cProcesso+"' 	AND "
cQuery += "            SRA.RA_TIPOSAL IN ('1','3')     AND "

cQuery += "	 		  SRA.D_E_L_E_T_     = ' ' "

IF !EMPTY(cFiltro)
	cQuery += cFiltro
ENDIF
If  ( MV_PAR01 == 2 .OR. MV_PAR01 == 3 .OR. MV_PAR01 == 1) .AND. cPrefx =="RC" 
	cQuery += "	 	GROUP BY RA_FILIAL,RA_MAT,RA_NOME,RA_ADMISSA,RA_SALARIO,RA_CIC,RA_RG,RC_MAT"
Else	 
	cQuery += "	 	GROUP BY RA_FILIAL,RA_MAT,RA_NOME,RA_ADMISSA,RA_SALARIO,RA_CIC,RA_RG"
EndIf	

cQuery += "		ORDER BY RA_FILIAL,RA_MAT " 

cQuery 		:= ChangeQuery(cQuery)
	
IF Select(cQrySRA) > 0
	(cQrySRA)->( DBCLOSEAREA() )
ENDIF
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cQrySRA)	 
TCSetField(cQrySRA, "RA_ADMISSA", "D", 8, 0)
 
if nConsolida == 2
  DEFINE BREAK oBreakFil  OF oSection1  WHEN  oSection1:Cell("RA_FILIAL" ) TITLE OemToAnsi(STR0025)
  oBreakFil:OnBreak({|x,y|cTitFun:=OemToAnsi(STR0026)+" "+cSucursal})	//"Total x " 
   	  oBreakFil:SetTotalText({||cTitFun+="  "+ OemToAnsi(STR0027)}) 

endif  
DEFINE FUNCTION NAME "RA_NOME" FROM oSection1:Cell("RA_NOME" ) FUNCTION COUNT BREAK oBreakFil TITLE "Tot.Func:" NO END SECTION NO END REPORT PICTURE "9999"

///// Subtotales por Sucursal     		                                    
IF MV_PAR01 == 1	            

	DEFINE FUNCTION NAME "CESCAUSA"  FROM oSection1:Cell("CESCAUSA" ) FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
	DEFINE FUNCTION NAME "ANTECESA"  FROM oSection1:Cell("ANTECESA" ) FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
   	DEFINE FUNCTION NAME "AJUSTPROV" FROM oSection1:Cell("AJUSTPROV") FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
   	
ELSEIF MV_PAR01 == 2    

	DEFINE FUNCTION NAME "CESATUAL"  FROM oSection1:Cell("CESATUAL" )  FUNCTION SUM   BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
	DEFINE FUNCTION NAME "INTERCES"  FROM oSection1:Cell("INTERCES" )  FUNCTION SUM   BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
   	DEFINE FUNCTION NAME "ANTINTCES" FROM oSection1:Cell("ANTINTCES" ) FUNCTION SUM   BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
	DEFINE FUNCTION NAME "PRVINTCES" FROM oSection1:Cell("PRVINTCES" ) FUNCTION SUM   BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"			
	DEFINE FUNCTION NAME "AJUSTPROV" FROM oSection1:Cell("AJUSTPROV" ) FUNCTION SUM   BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"					
   		  
ELSEIF MV_PAR01 == 3

	DEFINE FUNCTION NAME "PRICAUSA"   FROM oSection1:Cell("PRICAUSA" )  FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
	DEFINE FUNCTION NAME "PROVPRIMA"  FROM oSection1:Cell("PROVPRIMA" ) FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
	DEFINE FUNCTION NAME "AJUSTPROV"  FROM oSection1:Cell("AJUSTPROV" ) FUNCTION SUM     BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
   		  
ELSEIF MV_PAR01 == 4

   DEFINE FUNCTION NAME "TOTVACDIA"  FROM oSection1:Cell("TOTVACDIA" ) FUNCTION SUM   BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
	DEFINE FUNCTION NAME "VACDISFRU"  FROM oSection1:Cell("VACDISFRU" ) FUNCTION SUM   BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
	DEFINE FUNCTION NAME "VACDIAS"    FROM oSection1:Cell("VACDIAS" )   FUNCTION SUM    BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
	DEFINE FUNCTION NAME "PENDVALOR"  FROM oSection1:Cell("PENDVALOR" ) FUNCTION SUM    BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"			
	DEFINE FUNCTION NAME "PROVVAC"    FROM oSection1:Cell("PROVVAC")    FUNCTION SUM    BREAK oBreakFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"			
  
ENDIF
    
If lCorpManage

	DEFINE BREAK oBreakEFil OF oReport   WHEN  { || Substr((cQrySRA)->RA_FILIAL, nStartEmp, nEmpLength) }
	
	IF MV_PAR01 == 1	            

		DEFINE FUNCTION NAME "CESCAUSA"  FROM oSection1:Cell("CESCAUSA" ) FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
		DEFINE FUNCTION NAME "ANTECESA"  FROM oSection1:Cell("ANTECESA" ) FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
		DEFINE FUNCTION NAME "AJUSTPROV" FROM oSection1:Cell("AJUSTPROV") FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"			
	   	
	ELSEIF MV_PAR01 == 2    

		DEFINE FUNCTION NAME "CESATUAL"  FROM oSection1:Cell("CESATUAL" )  FUNCTION SUM   BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
		DEFINE FUNCTION NAME "INTERCES"  FROM oSection1:Cell("INTERCES" )  FUNCTION SUM   BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
	   	DEFINE FUNCTION NAME "ANTINTCES" FROM oSection1:Cell("ANTINTCES" ) FUNCTION SUM   BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
		DEFINE FUNCTION NAME "PRVINTCES" FROM oSection1:Cell("PRVINTCES" ) FUNCTION SUM   BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"			
		DEFINE FUNCTION NAME "AJUSTPROV" FROM oSection1:Cell("AJUSTPROV" ) FUNCTION SUM   BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"					
	   		  
	ELSEIF MV_PAR01 == 3

		DEFINE FUNCTION NAME "PRICAUSA"   FROM oSection1:Cell("PRICAUSA" )  FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"
		DEFINE FUNCTION NAME "PROVPRIMA"  FROM oSection1:Cell("PROVPRIMA" ) FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
		DEFINE FUNCTION NAME "AJUSTPROV"  FROM oSection1:Cell("AJUSTPROV" ) FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
	   		  
	ELSEIF MV_PAR01 == 4

		DEFINE FUNCTION NAME "VACDISFRU"  FROM oSection1:Cell("VACDISFRU" ) FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
		DEFINE FUNCTION NAME "VACDIAS"    FROM oSection1:Cell("VACDIAS" )   FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"	
		DEFINE FUNCTION NAME "PENDVALOR"  FROM oSection1:Cell("PENDVALOR" ) FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"			
		DEFINE FUNCTION NAME "PROVVAC"    FROM oSection1:Cell("PROVVAC")    FUNCTION SUM     BREAK oBreakEFil NO END SECTION NO END REPORT PICTURE "@E 999,999,999,999.99"			
	  
	ENDIF
		
oBreakEFil:OnBreak({ |x,y| cTitEFil := OemToAnsi(STR0028) + " " + x })	
oBreakEFil:SetTotalText({ || cTitEFil })
oBreakEFil:SetTotalInLine(.F.)		

EndIf       
	
//-- Define o total da regua da tela de processamento do relatorio
oReport:SetMeter((cQrySRA)->( RecCount() ))

//-- Impressao na quebra de pagina - Impressao das informacoes da Empresa e Filial
oReport:OnPageBreak({||(oReport) })

//-- Impressao do Relatorio
( cQrySRA )->(DBGOTOP()) // posiciona al primer registro del archivo de datos

 WHILE ( cQrySRA )->(!eof())
    cFilialAux  := POSICIONE( "SM0", 1,SM0->M0_CODIGO + ( cQrySRA )->RA_FILIAL, "M0_FILIAL" ) //obtiene la filial
    cFilialAux  += " "+ POSICIONE( "SM0", 1,SM0->M0_CODIGO + ( cQrySRA )->RA_FILIAL, "M0_NOMECOM" ) //obtiene Nombre de la filial
    oReport:IncMeter()
	if oReport:Cancel() //termina proceso si se cancela el reporte
		Exit
	EndIf
   oSection1:Print() 
   (cQrySRA )->(dbSkip())
ENDDO
 
IF SELECT("RCH") > 0
	RCH->( DBCLOSEAREA() )
ENDIF
	
IF SELECT("SRA") > 0
	SRA->( DBCLOSEAREA() )
ENDIF

Return NIL   
