#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FINR645.CH"

Static aSelFil 		:= {}
Static __cTmpSE1Fil := ""
Static cChave1 		:= ""
Static cChave2 		:= ""
Static cChave3 		:= ""
Static cChave4 		:= ""
Static cPerg	 	:= "FINR645A"
Static cAlias1 		:= ""
Static cAlias2 		:= ""
Static cAlias3 		:= ""
Static cWhereFJX	:= ""
Static cWhereFJZ 	:= ""
Static cFilFJY		:= ""
Static cRet770F3	:= ""
Static cRetFJXF3	:= ""
Static __oF645CP

//-------------------------------------------------------------------
/*/{Protheus.doc} FINR645
Relatório do PDD

@author Kaique Schiller
@since 06/04/2015
@version 12
/*/
//-------------------------------------------------------------------

Function FINR645()

Local oReport	:= Nil
Local lTReport	:= TRepInUse()
Local lRet		:= .T.
Local cAuxPDD	:= "FRV_SITPDD = '1' "

If !( TableIndic("FJX") .and. TableIndic("FJY") .and. TableIndic("FJZ") .and. TableIndic("FWZ") )
	HELP(" ",1,STR0018 ,, STR0019 ,2,0,,,,,,{ STR0020 }) // "FINA460-ROTINA NOVA DE LIQUIDAÇÃO" # "Dicionário Desatualizado" # "Migrar para Protheus 12.1.17 - out 2017"
	Return .F.
Endif

cWhereFJX 		:= ""
cWhereFJZ 		:= ""
cFilFJY			:= ""
__cTmpSE1Fil	:= ""
cChave1 		:= ""
cChave2 		:= ""
cChave3 		:= ""
cChave4 		:= ""

If !lTReport
	Help("  ",1,"FINR645",,STR0001,1,0)//Função disponível apenas TREPORT
	Return
EndIf

If Pergunte(cPerg,.T.)
	If MV_PAR09 == 1
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			lRet := .F.
		EndIf
	Else
		aSelFil := {cFilAnt}
	EndIf
	
	If MV_PAR10 == 1 //Seleciona Sit. Cobrança
		cFilFJY := F77GetSit('FJZ_SITPDD',cAuxPDD,.F.)
		If Empty(cFilFJY)
			cFilFJY := "1 = 1" 
		Endif
	Else
		cFilFJY := "1 = 1" 
	EndIf
	
	cFilFJY := "%" + cFilFJY + "%"
	
	If lRet
		oReport := ReportDef()
		oReport:lParamReadOnly := .F. 
		oReport:PrintDialog()
	EndIf
EndIf

CtbTmpErase(__cTmpSE1Fil)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Relatório do PDD

@author Kaique Schiller
@since 06/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local oReport 	:= Nil
Local oFJY 		:= Nil
Local oFJZ 		:= Nil
Local oFWZ 		:= Nil
Local cDesc		:= STR0002 //Este programa tem como objetivo imprimir o PDD
Local oBreak	:= Nil 
Local bPrint	:= {|oRep| FJYPRINT(oRep)}
Local cTitulo	:= STR0005 //Relatório do PDD 
Local cChvSE1	:= "(cAlias2)->FJZ_PREFIX + (cAlias2)->FJZ_NUM + (cAlias2)->FJZ_PARCEL + (cAlias2)->FJZ_TIPO"

cAlias1 := GetNextAlias()
cAlias2 := GetNextAlias()
cAlias3 := GetNextAlias()

Pergunte(cPerg,.F.)

DEFINE REPORT oReport NAME "FINR645" TITLE cTitulo PARAMETER cPerg ACTION {|oReport|RepFIN(oReport)} DESCRIPTION cDesc 
	DEFINE SECTION oFJY OF oReport TITLE STR0003 TABLES "SA1","AI0" //Clientes
	DEFINE CELL NAME "FJY_CLIENT"	OF oFJY ALIAS "FJY"
	DEFINE CELL NAME "FJY_LOJA"		OF oFJY ALIAS "FJY"
	DEFINE CELL NAME "A1_NOME" 		OF oFJY ALIAS "SA1" 
	oFJY:SetAutoSize()
	oFJY:OnPrintLine(bPrint)
	DEFINE SECTION oFJZ OF oFJY TITLE STR0004 TABLES "FJZ","SE1","FRV","SK1","ACG" PAGE HEADER //Títulos
		DEFINE CELL NAME "FJZ_PROC" 	OF oFJZ ALIAS "FJZ"
		DEFINE CELL NAME "FJX_DTREF"   	OF oFJZ ALIAS "FJX"
		DEFINE CELL NAME "GRUPEMP"   	OF oFJZ ALIAS "FJX" TITLE STR0010 SIZE 4 ALIGN CENTER  BLOCK {|| cEmpAnt } //"Grupo Emp" 
		DEFINE CELL NAME "FJZ_FILTIT" 	OF oFJZ ALIAS "FJZ" 
		DEFINE CELL NAME "FJZ_PREFIX"  	OF oFJZ ALIAS "FJZ"
		DEFINE CELL NAME "FJZ_NUM"  	OF oFJZ ALIAS "FJZ" 
		DEFINE CELL NAME "FJZ_PARCEL"  	OF oFJZ ALIAS "FJZ" TITLE "Parc " SIZE 4
		DEFINE CELL NAME "FJZ_TIPO"  	OF oFJZ ALIAS "FJZ" SIZE 5
		DEFINE CELL NAME "LIQUID"   	OF oFJZ ALIAS "FJZ" TITLE "Liq "  SIZE 3 ALIGN LEFT AUTO SIZE HEADER ALIGN RIGHT BLOCK {|| IIF( F645VLDLIQ(&cChvSE1) , "Sim", "" ) } //"Liquidação"                                               
		DEFINE CELL NAME "FJZ_EMISS"   	OF oFJZ ALIAS "FJZ"
		DEFINE CELL NAME "FJZ_VENCTO"  	OF oFJZ ALIAS "FJZ"
		DEFINE CELL NAME "FRV_DESCRI"  	OF oFJZ ALIAS "FJZ" TITLE STR0011 SIZE 22 //"Situação PDD."
		DEFINE CELL NAME "VENCER"   	OF oFJZ ALIAS "FJZ" TITLE STR0012  SIZE TamSX3('FJZ_SALDO')[1] PICTURE PesqPict("FJZ",'FJZ_SALDO', TamSX3('FJZ_SALDO')[1] ) ALIGN RIGHT AUTO SIZE HEADER ALIGN RIGHT BLOCK {|| IIF( (cAlias2)->FJZ_QTDATR  <= 0 , (cAlias2)->FJZ_SALDO, 0 ) } //"Vencer"                                               
		DEFINE CELL NAME "VENCIDO"   	OF oFJZ ALIAS "FJZ" TITLE STR0013  SIZE TamSX3('FJZ_SALDO')[1] PICTURE PesqPict("FJZ",'FJZ_SALDO', TamSX3('FJZ_SALDO')[1] ) ALIGN RIGHT AUTO SIZE HEADER ALIGN RIGHT BLOCK {|| IIF( (cAlias2)->FJZ_QTDATR  >  0 , (cAlias2)->FJZ_SALDO, 0 ) } //"Vencido" 
		DEFINE CELL NAME "FJZ_QTDATR" 	OF oFJZ ALIAS "FJZ" 
		DEFINE CELL NAME "FJZ_STATUS"	OF oFJZ ALIAS "FJZ"
		DEFINE CELL NAME "FJX_TIPO"		OF oFJZ ALIAS "FJX"

		oFJZ:SetAutoSize()
		
		If MV_PAR11 == 1 //Rateio = Sim
			DEFINE SECTION oFWZ OF oFJZ TITLE STR0009 TABLES "FWZ","SD2","SB1","SBM" PAGE HEADER //Rateio NF PDD
			DEFINE CELL NAME "FWZ_DOC"		OF oFWZ ALIAS "FWZ"
			DEFINE CELL NAME "FWZ_SERIE"	OF oFWZ ALIAS "FWZ"
			DEFINE CELL NAME "FWZ_CODPRO"	OF oFWZ ALIAS "FWZ"
			DEFINE CELL NAME "B1_DESC"		OF oFWZ ALIAS "SB1" 
			DEFINE CELL NAME "FWZ_PERCEC"	OF oFWZ ALIAS "FWZ"
			DEFINE CELL NAME "FWZ_VLRRAT"	OF oFWZ ALIAS "FWZ"
			DEFINE CELL NAME "FWZ_SLDRAT"	OF oFWZ ALIAS "FWZ"
			oFWZ:SetAutoSize()
		EndIf

		oBreak := TRBreak():New(oFJY,{ || oFJY:Cell("FJY_CLIENT"):uPrint+oFJY:Cell("FJY_LOJA"):uPrint }, STR0008 , .F.)//"Sub-Total
		
		TRFunction():New(oFJZ:Cell("VENCER")  , STR0014 , "SUM", , Substr(STR0014,1,29), , , .F., .T., .F., oFJZ,{|| IIF(FR645Sum(cAlias2,1) .And. (cAlias2)->FJX_TIPO == "1", .T., .F.)}) // "Provisao Constituida a Vencer" 
		TRFunction():New(oFJZ:Cell("VENCER")  , STR0015 , "SUM", , Substr(STR0015,1,29), , , .F., .T., .F., oFJZ,{|| IIF(FR645Sum(cAlias2,2) .And. (cAlias2)->FJX_TIPO == "2", .T., .F.)}) // "Provisao Revertida  a Vencer" 

		TRFunction():New(oFJZ:Cell("VENCIDO") , STR0016 , "SUM", , Substr(STR0016,1,29), , , .F., .T., .F., oFJZ,{|| IIF(FR645Sum(cAlias2,3) .And. (cAlias2)->FJX_TIPO == "1", .T., .F.)}) // "Provisao Constituida Vencida"
		TRFunction():New(oFJZ:Cell("VENCIDO") , STR0017 , "SUM", , Substr(STR0017,1,29), , , .F., .T., .F., oFJZ,{|| IIF(FR645Sum(cAlias2,4) .And. (cAlias2)->FJX_TIPO == "2", .T., .F.)}) // "Provisao Revertida Vencida"
		
	oReport:SetUseGC(.F.)
	oReport:ParamReadOnly()
	oReport:SetLandScape()
	oReport:DisableOrientation()
	
Return oReport
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Relatório do PDD

@author Alvaro Camillo Neto
@since 06/04/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function FR645Sum(cAlias2,nOpc)

Local lRet 		:= .T.
Local cChave 	:= (cAlias2)->(FJZ_FILTIT+FJZ_PREFIX+FJZ_NUM+FJZ_PARCEL+FJZ_TIPO+FJX_TIPO)

If nOpc == 1
	If cChave1 != cChave
		cChave1 := cChave
		lRet := .T.
	Else
		lRet := .F.
	EndIf
ElseIf nOpc == 2
	If cChave2 != cChave
		cChave2 := cChave
		lRet := .T.
	Else
		lRet := .F.
	EndIf
ElseIf nOpc == 3
	If cChave3 != cChave
		cChave3 := cChave
		lRet := .T.
	Else
		lRet := .F.
	EndIf
ElseIf nOpc == 4
	If cChave4 != cChave
		cChave4 := cChave
		lRet := .T.
	Else
		lRet := .F.
	EndIF
EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Relatório do PDD

@author Kaique Schiller
@since 06/04/2015
@version 12
/*/
//-------------------------------------------------------------------

Static Function RepFIN(oReport)

Local oFJY 		:= oReport:Section(1)
Local oFJZ 		:= oReport:Section(1):Section(1)
Local oFWZ 		:= Nil
Local cWhereProc	:= ""

If Empty(cFilFJY) //Seleciona Sit. Cobrança
	cFilFJY := "1 = 1" 
	cFilFJY := "%" + cFilFJY + "%"
EndIf

Pergunte(cPerg,.F.)

If MV_PAR11 == 1 //Rateio = Sim
	oFWZ 	:= oReport:Section(1):Section(1):Section(1)
EndIf

MakeSqlExpr(cPerg)

//Demonstra ?                   
If MV_PAR08 == 1 // Todos
	cWhereFJX += " 1 = 1 "
Elseif MV_PAR08 == 2
	cWhereFJX += " FJX.FJX_TIPO = '1'  " // Constituicao
Elseif MV_PAR08 == 3
	cWhereFJX += " FJX.FJX_TIPO = '2'  " // Reversão 	
Endif

//Status Proc ?                 
If MV_PAR12 == 1
	cWhereFJX += " AND 1 = 1 "
ElseIf MV_PAR12 == 2
	cWhereFJX += " AND FJX.FJX_STATUS = '1' " // Simulado
Elseif MV_PAR12 == 3
	cWhereFJX += " AND FJX.FJX_STATUS = '2' "	// Efetivado
Endif

//Status do Titulo
//1=Constiuição Simulada;2=Constiuição Efetivada;3=Reversão Simulada;4=Reversão Efetivada  
cWhereFJZ += " FJZ_FILTIT "+ GetRngFil( aSelFil, "SE1", .T., @__cTmpSE1Fil, , .T.) + " AND  "
If MV_PAR08 == 1 .And. MV_PAR12 == 1 // Todos os Tipos e Todos os Status
	cWhereFJZ += " FJZ.FJZ_STATUS IN ('1','2','3','4')  "
ElseIf MV_PAR08 == 1 .And. MV_PAR12 == 2 // Todos os Tipos e Simulados
	cWhereFJZ += " FJZ.FJZ_STATUS IN ('1','3')  "
ElseIf MV_PAR08 == 1 .And. MV_PAR12 == 3 // Todos os Tipos e Efetivados
	cWhereFJZ += " FJZ.FJZ_STATUS IN ('2','4')  "
ElseIf MV_PAR08 == 2 .And. MV_PAR12 == 1 // Constituicao e Todos os Status
	cWhereFJZ += " FJZ.FJZ_STATUS IN ('1','2')  "
ElseIf MV_PAR08 == 2 .And. MV_PAR12 == 2 // Constituicao e Simulados
	cWhereFJZ += " FJZ.FJZ_STATUS IN ('1')  "
ElseIf MV_PAR08 == 2 .And. MV_PAR12 == 3 // Constituicao e Efetivados
	cWhereFJZ += " FJZ.FJZ_STATUS IN ('2')  "
ElseIf MV_PAR08 == 3 .And. MV_PAR12 == 1 // Reversão e Todos os Status
	cWhereFJZ += " FJZ.FJZ_STATUS IN ('3','4')  "
ElseIf MV_PAR08 == 3 .And. MV_PAR12 == 2 // Reversão e Simulados
	cWhereFJZ += " FJZ.FJZ_STATUS IN ('3') "
ElseIf MV_PAR08 == 3 .And. MV_PAR12 == 3 // Reversão e Efetivados
	cWhereFJZ += " FJZ.FJZ_STATUS IN ('4')  "
EndIf

If !Empty(MV_PAR05)
	cWhereProc :=  MV_PAR05 + " AND " 
EndIf

cWhereFJX	:= "%" + cWhereFJX + "%"
cWhereFJZ	:= "%" + cWhereFJZ + "%"
cWhereProc	:= "%" + cWhereProc + "%"

//Seção de Clientes
BEGIN REPORT QUERY oFJY

BeginSql alias cAlias1
	
	SELECT DISTINCT 
	FJY_FILCLI,
	FJY_CLIENT,
	FJY_LOJA
	FROM
	%table:FJX% FJX
	INNER JOIN %table:FJY% FJY ON
	FJX.FJX_FILIAL = FJY_FILIAL
	AND FJX.FJX_PROC = FJY_PROC
	AND FJY_OK = 'T'
	WHERE
	FJY.FJY_CLIENT BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR03% AND
	FJY.FJY_LOJA BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR04% AND
	FJX.FJX_DTPROC BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07% AND
	FJX.FJX_DTREF BETWEEN %Exp:MV_PAR13% AND %Exp:MV_PAR14% AND
	%Exp:cWhereFJX% AND
	%Exp:cWhereProc%
	FJX.%NotDel% AND
	FJY.%NotDel%
	
	ORDER BY FJY_FILCLI,FJY_CLIENT,FJY_LOJA
	
EndSql

END REPORT QUERY oFJY

//Seção de Títulos
BEGIN REPORT QUERY oFJZ

BeginSql alias cAlias2
	
SELECT
	FJX_FILIAL,
	FJX_PROC,
	FJX_DTREF,
	FJX_STATUS,
	FJX_TIPO,
	
	FJY_FILIAL,
	FJY_PROC,
	FJY_ITEM,
	FJY_CLIENT,
	FJY_LOJA,                                                                
	
	FJZ_FILIAL,
	FJZ_PROC,
	FJZ_ITCLI,
	FJZ_ITEM,
	FJZ_FILTIT,
	FJZ_PREFIX,
	FJZ_NUM, 
	FJZ_PARCEL,
	FJZ_TIPO , 
	FJZ_EMISS,
	FJZ_VENCTO,
	FJZ_SITPDD,
	FJZ_VALOR,
	FJZ_SALDO,
	FJZ_QTDATR,
	FJZ_MOTBX,
	FJZ_STATUS,
	FJZ_REVSTA,
	FJZ_VENCRE,
	FJZ_QTDARE,
	FRV_DESCRI

FROM 
	%table:FJX% FJX
	INNER JOIN %table:FJY% FJY ON 
	FJX.FJX_FILIAL = FJY_FILIAL
	AND FJX.FJX_PROC = FJY_PROC
	AND FJY_OK = 'T'
	
	INNER JOIN %table:FJZ% FJZ ON 
	FJY.FJY_FILIAL = FJZ.FJZ_FILIAL
	AND FJY.FJY_PROC	= FJZ.FJZ_PROC
	AND FJY.FJY_ITEM = FJZ.FJZ_ITCLI
	AND FJZ_OK = 'T'

	INNER JOIN %table:FRV% FRV ON 
	FRV.FRV_FILIAL = %xFilial:FRV%
	AND FJZ.FJZ_SITPDD	= FRV.FRV_CODIGO
	    
WHERE
	FJY.FJY_FILCLI = %report_param: (cAlias1)->FJY_FILCLI% AND 
	FJY.FJY_CLIENT = %report_param: (cAlias1)->FJY_CLIENT% AND 
	FJY.FJY_LOJA = %report_param: (cAlias1)->FJY_LOJA% AND 
	FJX.FJX_DTPROC BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07% AND
	FJX.FJX_DTREF BETWEEN %Exp:MV_PAR13% AND %Exp:MV_PAR14% AND
	%Exp:cWhereFJX% AND
	%Exp:cWhereFJZ% AND
	%Exp:cFilFJY% AND	
	%Exp:cWhereProc%
	FJX.%NotDel% AND 
	FJY.%NotDel% AND
	FJZ.%NotDel% AND
	FRV.%NotDel%

ORDER BY FJX_FILIAL,FJX_PROC,FJY_ITEM,FJZ_ITEM

EndSql

END REPORT QUERY oFJZ PARAM MV_PAR05

If MV_PAR11 == 1 //Rateio = Sim
	//Rateio Nota Fiscal
	
	BEGIN REPORT QUERY oFWZ
		
		BeginSql alias cAlias3
			
			SELECT
			FJY_CLIENT,
			FJY_LOJA,
			FJZ_FILTIT,
        	FWZ_FILIAL,
        	FWZ_PROC,
        	FWZ_ITCLI,
        	FWZ_ITTIT,                                                                                         
			FWZ_DOC,
			FWZ_SERIE,
			FWZ_ITEM,
			FWZ_CODPRO,
			FWZ_PERCEC,
			FWZ_VLRRAT,
			B1_GRUPO,
			B1_DESC,
			FWZ_SLDRAT
			
					
			FROM
			%table:FJX% FJX
			INNER JOIN %table:FJY% FJY ON
			FJX.FJX_FILIAL = FJY_FILIAL
			AND FJX.FJX_PROC = FJY_PROC
			AND FJY_OK = 'T'
			
			INNER JOIN %table:FJZ% FJZ ON
			FJY.FJY_FILIAL = FJZ.FJZ_FILIAL
			AND FJY.FJY_PROC	= FJZ.FJZ_PROC
			AND FJY.FJY_ITEM = FJZ.FJZ_ITCLI
			AND FJZ_OK = 'T'
			
			LEFT JOIN   %table:FWZ% FWZ  ON
			FWZ.FWZ_FILIAL = FJZ.FJZ_FILIAL AND
			FWZ.FWZ_PROC = FJZ.FJZ_PROC AND
			FWZ.FWZ_ITCLI = FJZ.FJZ_ITCLI AND
			FWZ.FWZ_ITTIT = FJZ.FJZ_ITEM AND
			FWZ.D_E_L_E_T_= ' '

			LEFT JOIN   %table:SB1% SB1  ON
			SB1.B1_FILIAL = %xFilial:SB1% AND
			SB1.B1_COD = FWZ.FWZ_CODPRO AND
			SB1.D_E_L_E_T_= ' '

			WHERE
			FWZ_FILIAL = %report_param: (cAlias2)->FJZ_FILIAL% AND
			FWZ_PROC = %report_param: (cAlias2)->FJZ_PROC% AND
			FWZ_ITCLI = %report_param: (cAlias2)->FJZ_ITCLI% AND
			FWZ_ITTIT = %report_param: (cAlias2)->FJZ_ITEM% AND
			
			FJX.%NotDel% AND
			FJY.%NotDel% AND
			FWZ.%NotDel%
			
			ORDER BY FJX_FILIAL,FJX_PROC,FJY_ITEM,FJZ_ITEM
			
		EndSql
		
	END REPORT QUERY oFWZ PARAM MV_PAR05
	//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM 
	TRPosition():New(oFWZ,"SD2", 3,{ || xFilial("SD2",(cAlias3)->(FJZ_FILTIT))+(cAlias3)->(FWZ_DOC+FWZ_SERIE+FJY_CLIENT+FJY_LOJA+FWZ_CODPRO+FWZ_ITEM ) }, .T.)
	//B1_FILIAL+B1_COD
	TRPosition():New(oFWZ,"SB1", 1,{ || xFilial("SB1",(cAlias3)->(FJZ_FILTIT))+(cAlias3)->(FWZ_CODPRO) }, .T.)
	//BM_FILIAL+BM_GRUPO
	TRPosition():New(oFWZ,"SBM", 1,{ || xFilial("SBM",(cAlias3)->(FJZ_FILTIT))+(cAlias3)->(B1_GRUPO) }, .T.)
EndIf

//A1_FILIAL+A1_COD+A1_LOJA 
TRPosition():New(oFJY,"SA1", 1,{ || (cAlias1)->(FJY_FILCLI+FJY_CLIENT+FJY_LOJA) }, .T.)
//AI0_FILIAL+AI0_CODCLI+AI0_LOJA
TRPosition():New(oFJY,"AI0", 1,{ || xFilial("AI0") + (cAlias1)->(FJY_CLIENT+FJY_LOJA) }, .T.)
//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
TRPosition():New(oFJZ,"SE1", 2,{ || xFilial("SE1",(cAlias2)->(FJZ_FILTIT))+(cAlias2)->(FJY_CLIENT+FJY_LOJA+FJZ_PREFIX+FJZ_NUM+FJZ_PARCEL+FJZ_TIPO ) }, .T.)

//FRV_FILIAL+FRV_CODIGO
TRPosition():New(oFJZ,"FRV", 1,{ || xFilial("FRV",(cAlias2)->(FJZ_FILTIT))+(cAlias2)->(FJZ_SITPDD) }, .T.)
//K1_FILIAL+K1_PREFIXO+K1_NUM+K1_PARCELA+K1_TIPO+K1_FILORIG
TRPosition():New(oFJZ,"SK1", 1,{ || xFilial("SK1",(cAlias2)->(FJZ_FILTIT))+(cAlias2)->(FJZ_PREFIX+FJZ_NUM+FJZ_PARCEL+FJZ_TIPO+FJZ_FILTIT ) }, .T.)
//ACG_FILIAL+ACG_CODIGO+ACG_PREFIX+ACG_TITULO+ACG_PARCEL+ACG_TIPO+ACG_FILORI
TRPosition():New(oFJZ,"ACG", 1,{ || XFilial("ACG")+F645CodACG((cAlias2)->(FJZ_PREFIX),(cAlias2)->(FJZ_NUM),(cAlias2)->(FJZ_PARCEL),(cAlias2)->(FJZ_TIPO),(cAlias2)->(FJZ_FILTIT))+(cAlias2)->(FJZ_PREFIX+FJZ_NUM+FJZ_PARCEL+FJZ_TIPO+FJZ_FILTIT ) }, .T.)

oFJY:Print() 
	
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} FJYPRINT
Função de avaliação de impressão de clientes

@author Alvaro Camillo
@since 18/11/2015
@version 12
/*/
//-------------------------------------------------------------------
Function FJYPRINT(oRep)
Local lRet 		:= .T.
Local cAliasFJY	:= "FJTQUERY"
Local aArea 	:= GetArea()

If Empty(cFilFJY) //Seleciona Sit. Cobrança
	cFilFJY := "1 = 1" 
	cFilFJY := "%" + cFilFJY + "%"
EndIf

BeginSql alias cAliasFJY

SELECT
	COUNT(FJZ_PROC) CONTFJZ
FROM 
	%table:FJX% FJX
	INNER JOIN %table:FJY% FJY ON 
	FJX.FJX_FILIAL = FJY_FILIAL
	AND FJX.FJX_PROC = FJY_PROC
	AND FJY_OK = 'T'
	
	INNER JOIN %table:FJZ% FJZ ON 
	FJY.FJY_FILIAL = FJZ.FJZ_FILIAL
	AND FJY.FJY_PROC	= FJZ.FJZ_PROC
	AND FJY.FJY_ITEM = FJZ.FJZ_ITCLI
	AND FJZ_OK = 'T'
	    
WHERE
	FJY.FJY_FILCLI = %Exp:(cAlias1)->FJY_FILCLI% AND 
	FJY.FJY_CLIENT = %Exp:(cAlias1)->FJY_CLIENT% AND 
	FJY.FJY_LOJA =   %Exp:(cAlias1)->FJY_LOJA% AND 
	FJX.FJX_DTPROC BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07% AND
	FJX.FJX_DTREF BETWEEN %Exp:MV_PAR13% AND %Exp:MV_PAR14% AND
	%Exp:cWhereFJX% AND
	%Exp:cWhereFJZ% AND
	%Exp:cFilFJY% AND
	FJX.%NotDel% AND 
	FJY.%NotDel% AND
	FJZ.%NotDel%
EndSql

lRet := (cAliasFJY)->CONTFJZ > 0

(cAliasFJY)->(dbCloseArea())
RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F645CodACG
Funcao para obter o maior codigo da ACG para a chave do titulo

@author TOTVS
@since 28/04/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function F645CodACG(cPrefix,cNum,cParcel,cTipo,cFilTit)
Local aSaveArea	:= GetArea()
Local cUltCod	:= ""
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()

cQuery := " SELECT "											+CRLF
cQuery +=		" MAX(ACG_CODIGO) ACG_CODIGO "					+CRLF
cQuery += " FROM " + RetSqlName("ACG") + " ACG "				+CRLF
cQuery += " WHERE "												+CRLF
cQuery +=		" ACG.ACG_FILORI		= '" + cFilTit	+ "' "	+CRLF
cQuery +=		" AND ACG.ACG_PREFIX	= '" + cPrefix	+ "' "	+CRLF
cQuery +=		" AND ACG.ACG_TITULO	= '" + cNum		+ "' "	+CRLF
cQuery +=		" AND ACG.ACG_PARCEL	= '" + cParcel	+ "' "	+CRLF
cQuery +=		" AND ACG.ACG_TIPO		= '" + cTipo	+ "' "	+CRLF
cQuery +=		" AND ACG.D_E_L_E_T_	= '' "					+CRLF

cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

If (cAliasQry)->(!EOF())
	cUltCod := (cAliasQry)->ACG_CODIGO
EndIf

(cAliasQry)->(DbCloseArea())

RestArea(aSaveArea)

Return cUltCod                         


//-------------------------------------------------------------------
/*/{Protheus.doc} F77GetSit

Funcao F770GetSit na versao original da CEMIG/TOTVS V12 foi alterada
Para manter compatibilidade para CEMIG, alterado o nome e disponível
neste mesmo fonte.

/*/
//-------------------------------------------------------------------
         

Function F77GetSit(cCampo,cFiltro,lFilFW2)

Local cRet		:= ''

Default cFiltro := ''
Default lFilFW2 := .T.

	//Markbrowse com as situações de cobranças.
	
	F770FltSC(cFiltro,lFilFW2, @cRet770F3)
		
	If !Empty(cRet770F3)
		cRet := cCampo + " IN (" + cRet770F3 + ")"
	EndIf

Return cRet 


	//-------------------------------------------------------------------
	/*/{Protheus.doc} F645CODPRO
	Consulta Especifica dos Codigos da Provisão

	@author Francisco Oliveira
	@since 19/06/2019
	@version 12.1.25
	/*/
	//-------------------------------------------------------------------
Function F645PROV() As Logical

	Local aColumns	As Array
	Local aPesq		As Array
	Local aStruct	As Array
	Local bOk		As Codeblock
	Local bCancel	As Codeblock
	Local cArqTrb	As Character
	Local cQuery	As Character
	Local cMvPar	As Character
	Local nCampo	As Numeric
	Local lRetorno	As Logical
	Local oDlg		As Object
	Local oMrkBrw	As Object

	aColumns	:= {}
	aPesq		:= {}
	aStruct		:= FJX->(DBStruct())
	cMvPar		:= Alltrim(ReadVar())
	bOk			:= {|| F645RETVAR(cArqTrb,cMvPar) , oDlg:End()}
	bCancel		:= {|| oMrkBrw:Deactivate(), oDlg:End()}
	cArqTrb		:= GetNextAlias()
	cQuery		:= ""
	nCampo		:= 0
	lRetorno	:= .F.

	If __oF645CP <> NIL
		__o645CP:Delete()
		__o645CP := NIL
	EndIf

	//Cria o Objeto do FwTemporaryTable
	__oF645CP := FwTemporaryTable():New(cArqTrb)

	//Cria a estrutura do alias temporario
	Aadd(aStruct, {"FJX_OK", "C", 1, 0})	 //Adiciono o campo de marca
	__oF645CP:SetFields(aStruct)

	__oF645CP:AddIndex("1", {"FJX_PROC"})
	
	//Criando a Tabela Temporaria
	__oF645CP:Create()

	//Selecao dos Dados da FJX
	cQuery += " SELECT FJX.FJX_PROC, FJX.FJX_DTPROC, FJX.FJX_DTREF, FJX.FJX_DTEFET " + CRLF
	cQuery += " FROM " + RetSqlName("FJX")    + " FJX " +              CRLF
	cQuery += " WHERE	FJX.FJX_FILIAL = '"   + xFilial("FJX") + "'" + CRLF
	cQuery += " AND		FJX.D_E_L_E_T_ = ' '" +                        CRLF
	cQuery += " ORDER BY FJX_PROC "

	cQuery := ChangeQuery(cQuery)

	//Cria arquivo temporario
	Processa({|| SqlToTrb(cQuery, aStruct, cArqTrb)})

	(cArqTrb)->(DbGotop())
	// Marca os registro já selecionados.
	While !(cArqTrb)->(Eof())
		(cArqTrb)->(Reclock(cArqTrb,.F.))
			(cArqTrb)->FJX_OK := "X"
		(cArqTrb)->(MsUnlock())
		
		(cArqTrb)->(DbSkip())
	End

	(cArqTrb)->(DbGotop())
	//Fica na ordem da query
	DbSetOrder(0)

	//MarkBrowse
	For nCampo := 1 To Len( aStruct )
		If	aStruct[nCampo][1] $ "FJX_PROC|FJX_DTPROC|FJX_DTREF|FJX_DTEFET"
			AAdd(aColumns, FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||" + aStruct[nCampo][1] + "}") )
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStruct[nCampo][1]))
			aColumns[Len(aColumns)]:SetSize(aStruct[nCampo][3])
			aColumns[Len(aColumns)]:SetDecimal(aStruct[nCampo][4])
			aColumns[Len(aColumns)]:SetPicture(PesqPict("FJX", aStruct[nCampo][1]))
		EndIf
	Next nCampo

	//Regras para pesquisa na tela
	Aadd(aPesq, {AllTrim(RetTitle("FJX_PROC")), {{"FJX", "C", TamSX3("FJX_PROC")[1], 0, AllTrim(RetTitle("FJX_PROC")), "@!"}}, 1})
	
	If !(cArqTrb)->(Eof())
		DEFINE MSDIALOG oDlg TITLE "Provisão PDD" From 300, 0 to 800,800 OF oMainWnd PIXEL //Administradoras
		oMrkBrw := FWMarkBrowse():New()
		oMrkBrw:oBrowse:SetEditCell(.T.)
		oMrkBrw:SetFieldMark("FJX_OK")
		oMrkBrw:SetOwner(oDlg)
		oMrkBrw:SetAlias(cArqTrb)
		oMrkBrw:SetSeek(.T., aPesq)
		oMrkBrw:SetMenuDef("")
		oMrkBrw:AddButton("Confirmar", bOk, NIL, 2) //Confirmar
		oMrkBrw:AddButton("Cancelar", bCancel, NIL, 2) //Cancelar
		oMrkBrw:bMark	:= {||}
		oMrkBrw:bAllMark	:= {|| F645MrkAll(oMrkBrw, cArqTrb)}
		oMrkBrw:SetMark( "X", cArqTrb, "FJX_OK" )
		oMrkBrw:SetDescription("")
		oMrkBrw:SetColumns(aColumns)
		oMrkBrw:SetTemporary(.T.)
		oMrkBrw:Activate()
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
	GETDREFRESH()
	If __oF645CP <> NIL
		__oF645CP:Delete()
		__oF645CP := NIL
	EndIf

	Return lRetorno

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F645MrkAll
	Marca ou Desmarca todas as Provisões

	@author Francisco Oliveira
	@since 19/06/2019
	@version 12.1.25
	/*/
	//-------------------------------------------------------------------

Static Function F645MrkAll( oMrkBrw As Object, cArqTrb As Character ) As Logical
	Local cMarca As Character

	cMarca := oMrkBrw:Mark()

	DbSelectArea( cArqTrb )
	(cArqTrb)->( DbGoTop() )

	While !(cArqTrb)->( Eof() )

		RecLock( cArqTrb, .F. )

		If (cArqTrb)->FJX_OK == cMarca
			(cArqTrb)->FJX_OK := " "
		Else
			(cArqTrb)->FJX_OK := cMarca
		EndIf

		MsUnlock()
		(cArqTrb)->(DbSkip())
	EndDo

	(cArqTrb)->(DbGoTop())
	oMrkBrw:oBrowse:Refresh(.T.)

	Return .T.

//-------------------------------------------------------------------
	/*/{Protheus.doc} F645RETVAR
	Retorna variavel com as provisões escolhidas pelo usuario

	@author Francisco Oliveira
	@since 19/06/2019
	@version 12.1.25
	/*/
	//-------------------------------------------------------------------

Static Function F645RETVAR(cArqTrb,cMvPar)

Local nCount As Numeric

nCount 		:= 0
cRetFJXF3	:= ""

While !(cArqTrb)->( Eof() )
	If !Empty((cArqTrb)->FJX_OK)
		cRetFJXF3 += If(nCount > 0, ";" + (cArqTrb)->FJX_PROC, (cArqTrb)->FJX_PROC )
		nCount++
	Endif
	(cArqTrb)->(DbSkip())
EndDo

&(cMvPar) := cRetFJXF3

Return cRetFJXF3

//-------------------------------------------------------------------
/*/{Protheus.doc} F645RETF3
Retorna variavel com as provisões escolhidas pelo usuario para tela de perguntas

@author Francisco Oliveira
@since 19/06/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------

Function F645RETF3()
Return cRetFJXF3

//-------------------------------------------------------------------
/*/{Protheus.doc} F645VLDLIQ
Retorna variavel logica se o titulo for de origem de liquidação

@author Francisco Oliveira
@since 21/06/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------


Static Function F645VLDLIQ(cChvSE1)

Local lRet As Logical

lRet := .F.

SE1->(DbSetOrder(1))

If SE1->(DbseeK(xFilial("SE1") + cChvSE1))
	If !Empty(SE1->E1_NUMLIQ)
		lRet := .T.
	Endif
Endif

Return lRet
