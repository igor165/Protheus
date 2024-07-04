#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPER051PAR.CH"
#INCLUDE "REPORT.CH"

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ GPER051PAR 	³Autor³  Laura M.         ³ Data ³21/10/2019³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Reporte - Cambio de salario Minimo (Paraguay)              ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPER051PAR                                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³a    														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function GPER051PAR() 
Local aArea		:= GetArea()
Private dFechaRes := CTOD("//")
Private cCategor  := ""
Private cTarefas  := ""   
Private cPerg	  := "GPER051PAR"  
Private nPosCat   := 0
Private nPosDtAj  := 0 
Private nPosVlrU  := 0
Private nPosTare  := 0
Private nPosSMes  := 0
Private nPosSDia  := 0
Private nPosDesc  := 0
Private nPosDAnt  := 0
Private nPosAAnt  := 0
Private aTabS070  := {}
Private aTabS003  := {}
Private cPictDia  := PesqPict("SRJ","RJ_VALDIA",TamSX3("RJ_VALDIA")[1]) 
Private cPictFac  := PesqPict("SRJ","RJ_FACCON",TamSX3("RJ_FACCON")[1])
Private oReport   := Nil
Private aReport   := {}  
Private aOrd	  :={} 

Aadd(aOrd, OemToAnsi(STR0023))  //1  - // "Tipo de Salario (Categoría,Por Tarea y Antiguedad)"
Aadd(aOrd, OemToAnsi(STR0013))  //2  - // "Categoría"


Pergunte(cPerg,.F.) 

oReport:= ReportDef(aReport)
oReport:PrintDialog()
RestArea(aArea)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportDef  ºAutor  ³ Laura M.    ºFecha ³  05/12/16          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Define reporte                                              º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef(aReport)
Local oReport
Local oSectionA
Local oSectionB
Local cNomeProg := FunName()
Local cTitulo   := STR0001

//ALTERA O TITULO DO RELATORIO
DEFINE REPORT oReport NAME cNomeProg TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport(oReport,oSectionA,oSectionB) } DESCRIPTION STR0001 //"Reporte de Aumento de Salario Mínimo"
oReport:SetTotalInLine(.T.)
oReport:SetLandscape(.T.)
oReport:lHeaderVisible := .T.
oReport:lParamPage := .F.  	 	

//DEFINE O TOTAL DA REGUA DA TELA DE PROCESSAMENTO DO RELATORIO
oReport:SetMeter(LastRec())        

DEFINE SECTION oSectionA OF oReport TITLE OemToAnsi(STR0001) TABLES "SRJ","RCC" ORDERS aOrd	PAGE HEADER	//STR0001 "Reporte de Aumento de Salario Mínimo"
	DEFINE CELL NAME "FECHARES" OF oSectionA TITLE (OemToAnsi(STR0012)+ ': '+DTOC(dFechaRes)) SIZE 200 HEADER ALIGN LEFT
	oSectionA:SetTotalInLine(.F.)
	oSectionA:SetHeaderSection(.F.)
	
DEFINE SECTION oSectionB OF oReport TITLE OemToAnsi(STR0001) TABLES "SRJ","RCC" ORDERS aOrd	PAGE HEADER	 //STR0001 "Reporte de Aumento de Salario Mínimo"
/*01*/DEFINE CELL NAME "CODIGO"  	OF oSectionB TITLE OemToAnsi(STR0014) SIZE TamSX3("RJ_FUNCAO")[1]+10  HEADER ALIGN LEFT 	
/*02*/DEFINE CELL NAME "DESCRIP" 	OF oSectionB TITLE OemToAnsi(STR0015) SIZE 100 HEADER ALIGN LEFT
/*03*/DEFINE CELL NAME "SALARIOM" 	OF oSectionB TITLE OemToAnsi(STR0016+STR0017) SIZE TamSX3("RJ_VALDIA")[1]+20 HEADER ALIGN LEFT
/*04*/DEFINE CELL NAME "SALARIOD" 	OF oSectionB TITLE OemToAnsi(STR0016+STR0018) SIZE TamSX3("RJ_VALDIA")[1]+20 HEADER ALIGN LEFT
/*05*/DEFINE CELL NAME "FACTOR"     OF oSectionB TITLE OemToAnsi(STR0019) SIZE TamSX3("RJ_FACCON")[1]+10 HEADER ALIGN LEFT
/*06*/DEFINE CELL NAME "SALARIOT" 	OF oSectionB TITLE OemToAnsi(STR0016+STR0020) SIZE TamSX3("RJ_VALDIA")[1]+20 HEADER ALIGN LEFT
/*07*/DEFINE CELL NAME "DEANTIGU" 	OF oSectionB TITLE OemToAnsi(STR0021+STR0011) SIZE 20 HEADER ALIGN LEFT
/*08*/DEFINE CELL NAME "AANTIGUE" 	OF oSectionB TITLE OemToAnsi(STR0022+STR0011) SIZE 20 HEADER ALIGN LEFT
	
oSectionB:SetHeaderPage(.F.)
oSectionB:SetHeaderSection(.F.) 
oSectionB:SetHeaderBreak(.F.)	
		
Return oReport


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReportºAutor  ³Laura Medina        ºFecha ³  04/12/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Define reporte                                              º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrintReport(oReport,oSectionA,oSectionB)
Local nLoop     := 0
Local aCabTabA  := {}
Local lRet      := .T. 
Local nOrdem    := 1

MakeSqlExpr(cPerg)

dFechaRes := MV_PAR01
cCategor  := MV_PAR02 
cTarefas  := MV_PAR03   

nOrdem	  := oReport:GetOrder()

If  Empty(dFechaRes)
	Aviso(STR0003, STR0004 , {STR0002}   ) //Atencao, STR0003 "Indique una Fecha de Resolución" , {OK} 
	lRet  := .F. 
Endif

If  lRet
	//Obtener información de Categorías 
	Processa( {|| ObtCatRT2()}, STR0001,STR0007, .T. ) //"Categorías... ""Procesando... "
	//Obtener información de S070 - Salario por Tarea
	aCabTabA := ArmaRCB("S070")
	If  Len(aCabTabA)> 0 
	   	Processa( {|| GeraTabA(aCabTabA,"S070",1)}, STR0001,STR0008, .T. ) //"S070 - Salario por Tarea." "Procesando... "	
	Endif
	nPosCat  := 0
	nPosDtAj := 0  
	nPosDAnt := 0
	nPosAAnt := 0   
	nPosSMes := 0
	nPosSDia := 0
	aCabTabA := ArmaRCB("S003")
	If Len(aCabTabA)> 0 //S003 - Salario por Antigüedad
		Processa( {|| GeraTabA(aCabTabA,"S003",2)}, STR0001,STR0010, .T. ) //"S003 - Salario por Antigüedad" "Procesando... "
	Endif
	
	If Len(aReport) > 0
		If  nOrdem==2  //Se ordena por categoría 	
			aReport := aSort( aReport ,,, { |x,y| x[1] < y[1] }) 
		Endif
		oReport:StartPage()
		oReport:SetPageNumber(1)
		
		oSectionA:Init()
		oSectionA:Cell("FECHARES"):SetTitle("")
		oSectionA:Cell("FECHARES"):SetValue((OemToAnsi(STR0012)+ ': '+DTOC(dFechaRes) ))
		oSectionA:PrintLine()
		oReport:ThinLine()
		
		oSectionB:Init()
		oSectionB:Cell("CODIGO"):SetTitle("")
		oSectionB:Cell("DESCRIP"):SetTitle("")
		oSectionB:Cell("SALARIOM"):SetTitle("")
		oSectionB:Cell("SALARIOD"):SetTitle("")
		oSectionB:Cell("FACTOR"):SetTitle("")
		oSectionB:Cell("SALARIOT"):SetTitle("")
		oSectionB:Cell("DEANTIGU"):SetTitle("")
		oSectionB:Cell("AANTIGUE"):SetTitle("")
		
		oSectionB:Cell("CODIGO"):SetValue(OemToAnsi(STR0014))
		oSectionB:Cell("DESCRIP"):SetValue(OemToAnsi(STR0015))
		oSectionB:Cell("SALARIOM"):SetValue(OemToAnsi(STR0016+STR0017))
		oSectionB:Cell("SALARIOD"):SetValue(OemToAnsi(STR0016+STR0018))
		oSectionB:Cell("FACTOR"):SetValue(OemToAnsi(STR0019))
		oSectionB:Cell("SALARIOT"):SetValue(OemToAnsi(STR0016+STR0020))
		oSectionB:Cell("DEANTIGU"):SetValue(OemToAnsi(STR0021+STR0011))
		oSectionB:Cell("AANTIGUE"):SetValue(OemToAnsi(STR0022+STR0011))
		oSectionB:PrintLine()
		oReport:ThinLine()	

		For  nLoop:=1 to Len(aReport)
			If  oReport:Cancel()
				Exit
			EndIf 
			oSectionB:Cell("CODIGO"):SetValue(aReport[nLoop,1])
			oSectionB:Cell("DESCRIP"):SetValue(aReport[nLoop,2]) 
			oSectionB:Cell("SALARIOM"):SetValue(Transform(aReport[nLoop,3],cPictDia))
			oSectionB:Cell("SALARIOD"):SetValue(Transform(aReport[nLoop,4],cPictDia))
			oSectionB:Cell("FACTOR"):SetValue(Transform(aReport[nLoop,5],cPictFac))		
			oSectionB:Cell("SALARIOT"):SetValue(Transform(aReport[nLoop,6],cPictDia))
			oSectionB:Cell("DEANTIGU"):SetValue(Transform(aReport[nLoop,7],"@E 999.99"))
			oSectionB:Cell("AANTIGUE"):SetValue(Transform(aReport[nLoop,8],"@E 999.99"))
			oSectionB:PrintLine()
		Next 
		oReport:ThinLine()
		
		oReport:EndPage()
		oReport:EndReport()
	
	Else
		Aviso(STR0003, STR0006 , {STR0002} ) //Atencao, "No existen registros con esos parámetros.", {OK} 		
	Endif

Endif

Return lRet

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ ObtCatRT2  		³Autor³  Laura M.     ³ Data ³05/12/2019³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³ Obtener registros de categorías (Paraguay)                 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPER051PAR                                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³a    														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function ObtCatRT2() 
Local aArea		:= GetArea()
Local cQuery	:= ""	                         
Local nCont		:= 0
Local cAliasSRJ := GetNextAlias()
Local nI        := 0

/*
dFechaRes := MV_PAR01
cCategor  := MV_PAR02
cTarefas  := MV_PAR03 */

//Tabla Histórica de aumento de salarios************
cQuery := "SELECT RT2_FILIAL AS RJ_FILIAL, RT2_DESC AS RJ_DESC, RT2_CARGO AS RJ_CARGO, RT2_FUNCAO AS RJ_FUNCAO, "
cQuery += "RT2_SALANT AS RJ_SALANT, RT2_SALTAR AS RJ_SALTAR, RT2_SALARI AS RJ_SALARIO, RT2_VALDIA AS RJ_VALDIA, "
cQuery += "RT2_FACCON AS RJ_FACCON, RT2_DTAJUS AS RJ_DTAJUST " 
cQuery += "FROM "+RetSqlName("RT2")+" "					
cQuery += "WHERE "
//-- Categorias (RT2)
If !Empty(cCategor)
	cQuery += REPLACE(cCategor,"RJ_FUNCAO","RT2_FUNCAO") +" AND "
EndIf
cQuery += "RT2_SALANT = '2' AND RT2_SALTAR = '2' AND "
cQuery += "RT2_DTAJUS = '"+DTOS(dFechaRes)+"'  AND "
cQuery += "D_E_L_E_T_<>'*' AND " 
cQuery += "RT2_FILIAL = '"+xFilial("RT2")+"' "

//Tabla de Categorías*********************************
cQuery += "UNION " 
cQuery += "SELECT RJ_FILIAL, RJ_DESC, RJ_CARGO, RJ_FUNCAO, RJ_SALANT, RJ_SALTAR, RJ_SALARIO, RJ_VALDIA, " 
cQuery += "RJ_FACCON, RJ_DTAJUST " 
cQuery += "FROM "+RetSqlName("SRJ")+" "					
cQuery += "WHERE "
//-- Categorias (SRJ)
If !Empty(cCategor)
	cQuery += cCategor +" AND "
EndIf
cQuery += "RJ_SALANT = '2' AND RJ_SALTAR = '2' AND "
cQuery += "RJ_DTAJUST = '"+DTOS(dFechaRes)+"'  AND "
cQuery += "D_E_L_E_T_<>'*' AND " 
cQuery += "RJ_FILIAL = '"+xFilial("SRJ")+"' "

cQuery += "ORDER BY RJ_FILIAL, RJ_FUNCAO "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRJ,.T.,.T.)

Count to nCont
(cAliasSRJ)->(dbGoTop())
       
ProcRegua(nCont) 
While (cAliasSRJ)->(!eof())     
	nI++
	IncProc(STR0005 + STR0007 + str(nI))
	aAdd(aReport,{(cAliasSRJ)->RJ_FUNCAO,(cAliasSRJ)->RJ_DESC,(cAliasSRJ)->RJ_SALARIO,(cAliasSRJ)->RJ_VALDIA,(cAliasSRJ)->RJ_FACCON, "", "", ""})
		
   	(cAliasSRJ)->(dbSkip())	    
EndDo
(cAliasSRJ)->(dbCloseArea()) 

RestArea(aArea)   
Return


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ GeraTabA  		³Autor³  Laura M.         ³ Data ³21/10/2019³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Modificación de registros y el historico (Paraguay).       ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA030                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³a    														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function GeraTabA(aCabTab,cTab,nOpc)
Local nT        := 0
Local nPosIni   := 1
Local nTamCpo   := 0
Local nDecCpo   := 0 
Local aTab_S70  :={}
Local cConteudo := ""
Local nCont     := 0 
Local cQuery	:= ""	                       
Local cAliasRCC := GetNextAlias() 
Local nI        := 0

cQuery := "SELECT RCC_FILIAL, RCC_FIL, RCC_CODIGO, RCC_CHAVE, RCC_CONTEU, R_E_C_N_O_ RCCRECNO " 
cQuery += "FROM "+RetSqlName("RCC")+" "					
cQuery += "WHERE "
cQuery += "D_E_L_E_T_<>'*' " 
cQuery += "AND RCC_FILIAL = '"+xFilial("SRCC")+"' "
cQuery += "AND RCC_CODIGO = '"+cTab+"' "
  
If  nOpc==1 
	//-- Tareas solo para tabla (S070)
	If  !Empty(cTarefas)
		If 	AllTrim(Upper(TCGetDB())) $ "MSSQL"
			cQuery += "AND " + Replace(cTarefas,"RCC_CONTEU","SUBSTRING(RCC_CONTEU,1,3)")
		Else
			cQuery += "AND " + Replace(cTarefas,"RCC_CONTEU","SUBSTR(RCC_CONTEU,1,3)")
		Endif 
	Endif
	If  !Empty(cCategor)
		If 	AllTrim(Upper(TCGetDB())) $ "MSSQL"
			cQuery += "AND " + Replace(cCategor,"RJ_FUNCAO","SUBSTRING(RCC_CONTEU,162,5)")
		Else
			cQuery += "AND " + Replace(cCategor,"RJ_FUNCAO","SUBSTR(RCC_CONTEU,162,5)")
		Endif 
	Endif 
	If  !Empty(dFechaRes)
		If 	AllTrim(Upper(TCGetDB())) $ "MSSQL"
			cQuery += "AND " + "SUBSTRING(RCC_CONTEU,139,8)= '" +DTOS(dFechaRes)+ "' "
		Else
			cQuery += "AND " + "SUBSTR(RCC_CONTEU,139,8)= '" +DTOS(dFechaRes)+ "' "
		Endif 
	Endif
Elseif  nOpc==2 
	If  !Empty(cCategor)
		If 	AllTrim(Upper(TCGetDB())) $ "MSSQL"
			cQuery += "AND " + Replace(cCategor,"RJ_FUNCAO","SUBSTRING(RCC_CONTEU,1,5)")
		Else
			cQuery += "AND " + Replace(cCategor,"RJ_FUNCAO","SUBSTR(RCC_CONTEU,1,5)")
		Endif 
	Endif
	If  !Empty(dFechaRes)
		If 	AllTrim(Upper(TCGetDB())) $ "MSSQL"
			cQuery += "AND " + "SUBSTRING(RCC_CONTEU,162,8)= '" +DTOS(dFechaRes)+ "' "
		Else
			cQuery += "AND " + "SUBSTR(RCC_CONTEU,162,8)= '" +DTOS(dFechaRes)+ "' "
		Endif 
	Endif
Endif

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRCC,.T.,.T.)

Count to nCont
(cAliasRCC)->(dbGoTop())

ProcRegua(nCont) 
While (cAliasRCC)->(!EOF()) 
	aTab_S70  := {}
	nPosIni   := 1	
	nI++
	IncProc(STR0005 + Iif(nOpc==1,STR0008,STR0010)  + str(nI)) //Opc=1 -> "S070 - Salario por Tarea."
	If  Len(aCabTab)>0  
		//Obtener registro por registro de la RCC
		For nT:= 1 To Len(aCabTab) 
                                      
			//--Tamanho do Campo                                          	                
			nTamCpo := aCabTab[nT,3]
			nDecCpo := aCabTab[nT,4]
						
			//--Guarda conteudo do campo na Variavel 				
			If aCabTab[nT,2] == "C" 
				cConteudo := Subs((cAliasRCC)->RCC_CONTEU,nPosIni,nTamCpo)
			ElseIf aCabTab[nT,2] == "N"
				cConteudo := Val(Subs((cAliasRCC)->RCC_CONTEU,nPosIni,nTamCpo+nDecCpo))
			ElseIf aCabTab[nT,2] == "D"
				cConteudo := STOD(Subs((cAliasRCC)->RCC_CONTEU,nPosIni,nTamCpo))
			Endif                   
			//--Posicao Proximo Campo
			nPosIni += nTamCpo		
			Aadd(aTab_S70,cConteudo)
		Next nT	
		
		If  (Iif(nOpc==1,nPosCat>0 .And. nPosDtAj>0 .And. nPosVlrU>0 .And. nPosTare>0 .And. nPosDesc > 0 , ;
			         nPosCat>0 .And. nPosDtAj>0 .And. nPosSMes>0 .And. nPosSDia>0 .And. nPosDAnt>0 .And. nPosAAnt>0)) 
			
			If  Len(aTab_S70)>0 
				If  nOpc == 1 //S070
					aAdd(aReport,{aTab_S70[nPosCat]+"-"+aTab_S70[nPosTare],aTab_S70[nPosDesc],"","","1", aTab_S70[nPosVlrU],"", ""})
				Elseif nOpc == 2  //S003
					aAdd(aReport,{aTab_S70[nPosCat],POSICIONE("SRJ",1,xFilial("SRJ")+aTab_S70[nPosCat],"RJ_DESC"),aTab_S70[nPosSMes],aTab_S70[nPosSDia],"30","",aTab_S70[nPosDAnt],aTab_S70[nPosAAnt]})
				Endif
			Endif
			
		Endif	  
	Endif		
(cAliasRCC)->(dbSkip())	
Enddo

Return 

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ ArmaRCB  		³Autor³  Laura M.         ³ Data ³21/10/2019³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Arma encabezado RCB  (Paraguay)                             ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA030                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³a    														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function ArmaRCB(cTab)
Local aCabTab      := {}

dbSelectArea("RCB")
RCB->(Dbsetorder(1))

If  dbSeek(Xfilial("RCB")+cTab,.T.)
	While ! Eof() .And.  RCB->RCB_CODIGO == cTab	
		//--Carrega o Cabecalho da Tabela 
		RCB->(Aadd(aCabTab,{RCB_CAMPOS,RCB_TIPO,RCB_TAMAN,RCB_DECIMA}))
		RCB->(dbSkip())
	Enddo	
Endif

nPosCat  := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "CATEGORIA" })
nPosDtAj := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "FCHAJUSTE" })  
nPosCodT := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "CODIGO" })
nPosVlrU := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "VALUNITAR" })
nPosTare := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "CODIGO" })   
nPosSMes := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "SALMES" })
nPosSDia := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "SALDIA" })
nPosDesc := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "DESCRIP" })  
nPosDAnt := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "DEANT" })
nPosAAnt := aScan(aCabTab,{ |x| UPPER(Alltrim(x[1])) = "AANT" })      
   
Return aCabTab


