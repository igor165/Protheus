#Include "PROTHEUS.CH"
#Include "REPORT.CH"
#Include "TOPCONN.CH"
#Include "ATFR502.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcion   ³ ATFR502    ³ Autor ³Laura Elena Medina Prado³ Data ³ 01/03/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçào ³ RT 6/84 Ajuste por Inflacion.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ATFR502()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAATF                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ATFR502()
Local nOpcA    := 0
Local aSays    := {}
Local aButtons := {}
Local aArea    := GetArea()
Private cPerg      := "ATFR502"
Private dDatIni    := ("//")
Private dDatFim    := ("//")
Private cIniGpo    := ""
Private cFimGpo    := ""
Private cPestana   := 1
Private oReport    := Nil
Private oSectionA  := Nil //Seccion Grupo
Private cTmpQry    := GetNextAlias()
Private cPictVlr   := PesqPict("SN3","N3_VORIG1",TamSX3("N3_VORIG1")[1])
	
	Pergunte( cPerg, .F. )
	aAdd(aSays, OemToAnsi( STR0023 ) )  //"RT 6/84 Ajuste por Inflacion de Activo Fijo"
	aAdd(aButtons, { 5,.T.,{ || Pergunte(cPerg,.T. ) } } )
	aAdd(aButtons, { 1,.T.,{ |o| IIf(VldParam(), (nOpcA := 1, o:oWnd:End()), Nil) }} )
	aAdd(aButtons, { 2,.T.,{ |o| nOpcA := 2, o:oWnd:End() }} )             
	FormBatch( oemtoansi(STR0001), aSays, aButtons )  //"Este informe imprimira el Ajuste por Inflación."
	
	If  nOpcA == 2
		Return
	Else
		dDatIni  := MV_PAR01
		dDatFim  := MV_PAR02
		cIniGpo  := MV_PAR03
		cFimGpo  := MV_PAR04
		cPestana := MV_PAR05
	EndIf 
	
ReportDef()
oReport:PrintDialog()
RestArea(aArea)

Return



/*/{Protheus.doc} ReportDef
Inicializa objetos para emitir informe.

@Type    Function
@Author  Laura Elena Medina Prado 
@Since   04/03/2019
@Version P12.1.17
@Param   
@Return  
/*/
Static Function ReportDef()
Local cNomeProg := FunName()

	DEFINE REPORT oReport NAME cNomeProg TITLE Iif(cPestana ==1,STR0030,STR0031) PARAMETER "" ACTION {|oReport| Iif(cPestana ==1,PrintReport(oReport),Print2Report(oReport)) } DESCRIPTION STR0030
	oReport:SetTotalInLine(.F.)
	oReport:SetLandscape(.T.)	
	oReport:ShowParamPage()
	oReport:lParamPage := .T.
	
	DEFINE SECTION oSectionA OF oReport TITLE  Iif(cPestana ==1,STR0030,STR0031) TOTAL IN COLUMN
	If  cPestana ==1 //Bienes
		/*Seccion Grupo*/
		DEFINE CELL NAME "CODIGOA"  OF oSectionA TITLE STR0009+" "+STR0002  SIZE TamSX3("NG_GRUPO")[1]    HEADER ALIGN LEFT //C¾digo Grupo
		DEFINE CELL NAME "DESCRIA"  OF oSectionA TITLE STR0010+" "+STR0002   SIZE TamSX3("NG_DESCRIC")[1] HEADER ALIGN LEFT //Descripci¾n Grupo
		/*Seccion Activo Fijo*/
		DEFINE CELL NAME "CODIGOB"  OF oSectionA TITLE STR0009+" "+STR0036  SIZE (TamSX3("N1_CBASE")[1]+1+TamSX3("N1_ITEM")[1]) HEADER ALIGN LEFT //C¾digo Bien
		DEFINE CELL NAME "DESCRIB"  OF oSectionA TITLE STR0010+" "+STR0036  SIZE TamSX3("NG_DESCRIC")[1]  HEADER ALIGN LEFT //Descripci¾n Bien
		DEFINE CELL NAME "ESTADO"   OF oSectionA TITLE STR0011  SIZE 15   HEADER ALIGN LEFT //Estado
		/*Seccion Fecha*/
		DEFINE CELL NAME "ADQUISA"  OF oSectionA TITLE STR0004+" "+STR0012  SIZE TamSX3("N3_AQUISIC")[1]  HEADER ALIGN LEFT //Fecha Adquisici¾n
		DEFINE CELL NAME "BAJA"     OF oSectionA TITLE STR0004+" "+STR0013  SIZE TamSX3("N3_DTBAIXA")[1]  HEADER ALIGN LEFT //Fecha Baja
		/*Seccion Cuenta*/ 
		DEFINE CELL NAME "ADQUISB"  OF oSectionA TITLE STR0005+" "+STR0012 SIZE TamSX3("N3_CCONTAB")[1]   HEADER ALIGN LEFT //Cuenta Adquisici¾n
		DEFINE CELL NAME "ACUMULA"  OF oSectionA TITLE STR0005+" "+STR0014 SIZE TamSX3("N3_CCDEPR")[1]    HEADER ALIGN LEFT //Cuenta Acumulada
		DEFINE CELL NAME "MES"      OF oSectionA TITLE STR0005+" "+STR0015 SIZE TamSX3("N3_CDEPREC")[1]   HEADER ALIGN LEFT //Cuenta Dep. Mensual
		DEFINE CELL NAME "CCOSTO"   OF oSectionA TITLE STR0016  SIZE TamSX3("N3_CCUSTO")[1]    HEADER ALIGN LEFT //Centro de Costo
		DEFINE CELL NAME "AXL"      OF oSectionA TITLE STR0005+" "+STR0017 SIZE TamSX3("N3_CDESP")[1]     HEADER ALIGN LEFT //Cuenta Correc Dep.
		DEFINE CELL NAME "PNETO"    OF oSectionA TITLE STR0005+" "+STR0018 SIZE TamSX3("N3_CCORREC")[1]   HEADER ALIGN LEFT //Cuenta Correc Bien
		/*Seccion Origen*/
		DEFINE CELL NAME "VALORE"   OF oSectionA TITLE STR0019+" "+STR0006 SIZE TamSX3("N3_VORIG1")[1]    HEADER ALIGN RIGHT //Valor Origen
		DEFINE CELL NAME "EJECICE"  OF oSectionA TITLE STR0020+" "+STR0006 SIZE TamSX3("N3_VRDBAL1")[1]   HEADER ALIGN RIGHT //Ejercicio Origen
		DEFINE CELL NAME "ACUMULE"  OF oSectionA TITLE STR0021+" "+STR0006 SIZE TamSX3("N3_VRDACM1")[1]   HEADER ALIGN RIGHT //Acumulada Origen
		DEFINE CELL NAME "VALORRE"  OF oSectionA TITLE STR0022+" "+STR0006 SIZE TamSX3("N3_VORIG1")[1]    HEADER ALIGN RIGHT //Valor Residual Origen
		/*Seccion Revaluo*/
		DEFINE CELL NAME "VALORF"   OF oSectionA TITLE STR0019+" "+STR0007 SIZE TamSX3("N3_VORIG1")[1]    HEADER ALIGN RIGHT //Valor Reval·o
		DEFINE CELL NAME "EJECICF"  OF oSectionA TITLE STR0020+" "+STR0007 SIZE TamSX3("N3_VRDBAL1")[1]   HEADER ALIGN RIGHT //Ejercicio Reval·o
		DEFINE CELL NAME "ACUMULF"  OF oSectionA TITLE STR0021+" "+STR0007 SIZE TamSX3("N3_VRDACM1")[1]   HEADER ALIGN RIGHT //Acumulada Reval·o
		DEFINE CELL NAME "VALORRF"  OF oSectionA TITLE STR0022+" "+STR0007 SIZE TamSX3("N3_VORIG1")[1]    HEADER ALIGN RIGHT //Valor Residual Reval·o
		/*Seccion Diferencia*/
		DEFINE CELL NAME "VALORG"   OF oSectionA TITLE STR0019+" "+STR0008 SIZE TamSX3("N3_VORIG1")[1]    HEADER ALIGN RIGHT //Valor Diferencia
		DEFINE CELL NAME "EJECICG"  OF oSectionA TITLE STR0020+" "+STR0008 SIZE TamSX3("N3_VRDBAL1")[1]   HEADER ALIGN RIGHT //Ejercicio Diferencia
		DEFINE CELL NAME "ACUMULG"  OF oSectionA TITLE STR0021+" "+STR0008 SIZE TamSX3("N3_VRDACM1")[1]   HEADER ALIGN RIGHT //Acumulada Diferencia
		DEFINE CELL NAME "VALORRG"  OF oSectionA TITLE STR0022+" "+STR0008 SIZE TamSX3("N3_VORIG1")[1]    HEADER ALIGN RIGHT //Valor Residual Diferencia
		
	Elseif cPestana == 2 //Transferencias
			/*Seccion Grupo*/
		DEFINE CELL NAME "CODIGOA"  OF oSectionA TITLE STR0009+" "+CRLF+STR0002  SIZE TamSX3("NG_GRUPO")[1]    HEADER ALIGN LEFT //C¾digo Grupo
		DEFINE CELL NAME "DESCRIA"  OF oSectionA TITLE STR0010+" "+STR0002  SIZE TamSX3("NG_DESCRIC")[1]  HEADER ALIGN LEFT //Descripci¾n Grupo
		/*Seccion Activo Fijo*/
		DEFINE CELL NAME "CODIGOB"  OF oSectionA TITLE STR0009+" "+STR0036  SIZE (TamSX3("N1_CBASE")[1]+1+TamSX3("N1_ITEM")[1]) HEADER ALIGN LEFT //C¾digo Bien
		DEFINE CELL NAME "DESCRIB"  OF oSectionA TITLE STR0010+" "+STR0036  SIZE TamSX3("NG_DESCRIC")[1]  HEADER ALIGN LEFT //Descripci¾n Bien
		/*Seccion Transferencia*/ 
		DEFINE CELL NAME "CONTA"  OF oSectionA TITLE STR0037 SIZE TamSX3("N4_CONTA")[1]   HEADER ALIGN RIGHT //Imputaci¾n contable bien transferido
		DEFINE CELL NAME "VALORH" OF oSectionA TITLE STR0038 SIZE TamSX3("N4_VLROC1")[1]  HEADER ALIGN RIGHT //Valores Hist¾ricos
		DEFINE CELL NAME "VALORA" OF oSectionA TITLE STR0039 SIZE TamSX3("N4_VLROC1")[1]  HEADER ALIGN RIGHT //Valores Ajustados
		DEFINE CELL NAME "DIFERE" OF oSectionA TITLE STR0008 SIZE TamSX3("N4_VLROC1")[1]  HEADER ALIGN RIGHT //Diferencia
		
	Endif   
    oSectionA:SetHeaderPage(.F.)
	oSectionA:SetTotalInLine(.F.)
	oSectionA:SetHeaderSection(.F.)
	oSectionA:SetHeaderBreak(.T.)
Return


/*/{Protheus.doc} PrintReport
Obtiene datos y genera el informe  -Bienes-.

@Type    Function
@Author  Laura Elena Medina Prado 
@Since   04/03/2019
@Version P12.1.17
@Param   
@Return  
/*/
Static Function PrintReport(oReport)
Local nLoop     := 0
Local cQuery    := ""
Local cEstatus  := ""
Local nBaixa    := 0
Local nVlrRev   := 0 
Local nEjeRev   := 0
Local nAcuRev   := 0 
Local nVReRev   := 0
Local nActivos  := 0
Local nIndPer   := 0 
Local nIndPerA  := 0
Local nIndAdq   := 0
Local cChavGpo  := ""
Local cChavAnt  := ""
Local nTotVlrO   := 0 
Local nTotEjeO   := 0
Local nTotAcuO   := 0 
Local nTotVReO   := 0
Local nTotVlrR   := 0 
Local nTotEjeR   := 0
Local nTotAcuR   := 0 
Local nTotVReR   := 0
Local nTotVlrD   := 0 
Local nTotEjeD   := 0
Local nTotAcuD   := 0 
Local nTotVReD   := 0
Local nTGlVlrO   := 0 
Local nTGlEjeO   := 0
Local nTGlAcuO   := 0 
Local nTGlVReO   := 0
Local nTGlVlrR   := 0 
Local nTGlEjeR   := 0
Local nTGlAcuR   := 0 
Local nTGlVReR   := 0
Local nTGlVlrD   := 0 
Local nTGlEjeD   := 0
Local nTGlAcuD   := 0 
Local nTGlVReD   := 0

	/* Obtiene Activos*/
	cQuery := " SELECT NG_GRUPO, NG_DESCRIC, N1_CBASE, N1_ITEM, N1_DESCRIC, N3_AQUISIC, N3_BAIXA, N3_DTBAIXA, " 
	cQuery += " N3_CCONTAB, N3_CCDEPR, N3_CDEPREC, N3_CCUSTO, N3_CDESP, N3_CCORREC, N3_VORIG1, N3_VRDBAL1, N3_VRCACM1, "
	cQuery += " N3_AMPLIA1, N3_CCDEPR, N3_VRCDA1, N3_VRDACM1  "
	cQuery += " FROM " + RetSqlName("SNG") + " SNG, " + RetSqlName("SN1") + " SN1, " + RetSqlName("SN3") + " SN3 "
	cQuery += " WHERE NG_GRUPO = N1_GRUPO "
	cQuery += " AND N1_CBASE = N3_CBASE "
	cQuery += " AND N1_ITEM  = N3_ITEM "
	cQuery += " AND N3_AQUISIC BETWEEN "+Dtos(dDatIni)+" AND "+Dtos(dDatFim)
	cQuery += " AND NG_GRUPO  BETWEEN '"+cIniGpo+"' AND '"+ cFimGpo +"'" 
	cQuery += " AND N1_FILIAL = '" + xFilial("SN1") + "' "
	cQuery += " AND NG_FILIAL = '" + xFilial("SNG") + "' "
	cQuery += " AND N3_FILIAL = '" + xFilial("SN3") + "' "
	cQuery += " AND SN1.D_E_L_E_T_ = '' "
	cQuery += " AND SNG.D_E_L_E_T_ = '' "
	cQuery += " AND SN3.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY NG_GRUPO, N1_CBASE, N1_ITEM, N3_AQUISIC "
	cQuery := ChangeQuery(cQuery)     
	
	
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cTmpQry,.T.,.T.)
	TcSetField(cTmpQry, "N3_AQUISIC", "D",   TamSX3("N3_AQUISIC")[1], TamSX3("N3_AQUISIC")[2])
	TcSetField(cTmpQry, "N3_DTBAIXA", "D",   TamSX3("N3_DTBAIXA")[1], TamSX3("N3_DTBAIXA")[2])
	TcSetField(cTmpQry, "N3_VORIG1",  "N",   TamSX3("N3_VORIG1")[1],  TamSX3("N3_VORIG1")[2])
	TcSetField(cTmpQry, "N3_VRDBAL1", "N",   TamSX3("N3_VRDBAL1")[1], TamSX3("N3_VRDBAL1")[2])
	TcSetField(cTmpQry, "N3_VRDACM1", "N",   TamSX3("N3_VRDACM1")[1], TamSX3("N3_VRDACM1")[2])
	
	Count to nActivos
	
	If  nActivos > 0
		nIndPer  := POSICIONE("SIE",1,XFILIAL("SIE")+STRZERO(YEAR(dDatFim),4)+STRZERO(MONTH(dDatFim),2),"IE_INDICE")
		nIndPerA := POSICIONE("SIE",1,XFILIAL("SIE")+STRZERO(YEAR(dDatFim)-1,4)+"12","IE_INDICE")
		oSectionA:Init()
		oSectionA:Cell("CODIGOA"):SetTitle("")
		oSectionA:Cell("DESCRIA"):SetTitle("")
		oSectionA:Cell("CODIGOB"):SetTitle("")
		oSectionA:Cell("DESCRIB"):SetTitle("")
		oSectionA:Cell("ESTADO"):SetTitle("")	
		oSectionA:Cell("ADQUISA"):SetTitle("")
		oSectionA:Cell("BAJA"):SetTitle("")	
		oSectionA:Cell("ADQUISB"):SetTitle("") 	
		oSectionA:Cell("ACUMULA"):SetTitle("")
		oSectionA:Cell("MES"):SetTitle("")
		oSectionA:Cell("CCOSTO"):SetTitle("")
		oSectionA:Cell("AXL"):SetTitle("")
		oSectionA:Cell("PNETO"):SetTitle("")		
		oSectionA:Cell("VALORE"):SetTitle("")
		oSectionA:Cell("EJECICE"):SetTitle("")
		oSectionA:Cell("ACUMULE"):SetTitle("") 
		oSectionA:Cell("VALORRE"):SetTitle("") 
		oSectionA:Cell("VALORF"):SetTitle("")
		oSectionA:Cell("EJECICF"):SetTitle("")
		oSectionA:Cell("ACUMULF"):SetTitle("") 
		oSectionA:Cell("VALORRF"):SetTitle("") 
		oSectionA:Cell("VALORG"):SetTitle("")
		oSectionA:Cell("EJECICG"):SetTitle("")
		oSectionA:Cell("ACUMULG"):SetTitle("") 
		oSectionA:Cell("VALORRG"):SetTitle("") 

		oSectionA:Cell("CODIGOA"):SetValue(STR0009+" "+STR0002)
		oSectionA:Cell("DESCRIA"):SetValue(STR0010+" "+STR0002)
		oSectionA:Cell("CODIGOB"):SetValue(STR0009+" "+STR0036)
		oSectionA:Cell("DESCRIB"):SetValue(STR0010+" "+STR0036)
		oSectionA:Cell("ESTADO"):SetValue(STR0011)
		oSectionA:Cell("ADQUISA"):SetValue(STR0004+" "+STR0012)
		oSectionA:Cell("BAJA"):SetValue(STR0004+" "+STR0013)
		oSectionA:Cell("ADQUISB"):SetValue(STR0005+" "+STR0012) 	
		oSectionA:Cell("ACUMULA"):SetValue(STR0005+" "+STR0014)
		oSectionA:Cell("MES"):SetValue(STR0005+" "+STR0015)
		oSectionA:Cell("CCOSTO"):SetValue(STR0016)
		oSectionA:Cell("AXL"):SetValue(STR0005+" "+STR0017)
		oSectionA:Cell("PNETO"):SetValue(STR0005+" "+STR0018)
		oSectionA:Cell("VALORE"):SetValue(STR0019+" "+STR0006)
		oSectionA:Cell("EJECICE"):SetValue(STR0020+" "+STR0006)
		oSectionA:Cell("ACUMULE"):SetValue(STR0021+" "+STR0006) 
		oSectionA:Cell("VALORRE"):SetValue(STR0022+" "+STR0006)
		oSectionA:Cell("VALORF"):SetValue(STR0019+" "+STR0007)
		oSectionA:Cell("EJECICF"):SetValue(STR0020+" "+STR0007)
		oSectionA:Cell("ACUMULF"):SetValue(STR0021+" "+STR0007) 
		oSectionA:Cell("VALORRF"):SetValue(STR0021+" "+STR0007)
		oSectionA:Cell("VALORG"):SetValue(STR0019+" "+STR0008)
		oSectionA:Cell("EJECICG"):SetValue(STR0020+" "+STR0008)
		oSectionA:Cell("ACUMULG"):SetValue(STR0021+" "+STR0008)
		oSectionA:Cell("VALORRG"):SetValue(STR0022+" "+STR0008)	
		oSectionA:PrintLine()
		oReport:ThinLine()	
	Endif
	
	(cTmpQry)->(dbGoTop())
	While (cTmpQry)->(!Eof())
		If  oReport:Cancel()
			Exit
		EndIf
		cEstatus  := ""
		nVlrRev   := 0 
		nEjeRev   := 0
		nAcuRev   := 0 
		nVReRev   := 0
		/*Seccion Grupo*/
		oSectionA:Cell("CODIGOA"):SetValue((cTmpQry)->(NG_GRUPO))
		oSectionA:Cell("DESCRIA"):SetValue((cTmpQry)->(NG_DESCRIC)) 
		/*Seccion Activo Fijo*/
		//Registro dado de Baja (Venta/Baixa)
		If   Val((cTmpQry)->(N3_BAIXA))>0 .AND. !Empty((cTmpQry)->(N3_DTBAIXA)) 
			 nBaixa := VerBaixa((cTmpQry)->(N1_CBASE),(cTmpQry)->(N1_ITEM)) 
			 If  nBaixa == 1 //Vendido
			 	 cEstatus := STR0035
			 Elseif nBaixa == 2 //Baja
			 	 cEstatus := STR0032
			 Else 
			 	 cEstatus := STR0032
			 Endif  
		Else   //nVlrEdo > 0 ...es Activo  y  VlrEdo <= 0 ... es Amortizado
			cEstatus :=  Iif((cTmpQry)->(N3_VORIG1+N3_VRCACM1+N3_AMPLIA1)-(cTmpQry)->(N3_VRDACM1+N3_VRCDA1)>0,STR0033,STR0034)
		Endif  	
		oSectionA:Cell("CODIGOB"):SetValue((cTmpQry)->(N1_CBASE)+" "+(cTmpQry)->(N1_ITEM))
		oSectionA:Cell("DESCRIB"):SetValue((cTmpQry)->(N1_DESCRIC))
		oSectionA:Cell("ESTADO"):SetValue(cEstatus)
		/*Seccion Fecha*/
		oSectionA:Cell("ADQUISA"):SetValue(dtoc((cTmpQry)->(N3_AQUISIC)))
		oSectionA:Cell("BAJA"):SetValue(dtoc((cTmpQry)->(N3_DTBAIXA)))	
		/*Seccion Cuenta*/
		oSectionA:Cell("ADQUISB"):SetValue((cTmpQry)->(N3_CCONTAB))
		oSectionA:Cell("ACUMULA"):SetValue((cTmpQry)->(N3_CCDEPR))
		oSectionA:Cell("MES"):SetValue((cTmpQry)->(N3_CDEPREC))	
		oSectionA:Cell("CCOSTO"):SetValue((cTmpQry)->(N3_CCUSTO))
		oSectionA:Cell("AXL"):SetValue((cTmpQry)->(N3_CDESP))
		oSectionA:Cell("PNETO"):SetValue((cTmpQry)->(N3_CCORREC))
		
		/*Seccion Origen*/
		nTotVlrO   += (cTmpQry)->(N3_VORIG1)
		nTotEjeO   += (cTmpQry)->(N3_VRDBAL1)
		nTotAcuO   += (cTmpQry)->(N3_VRDACM1)
		nTotVReO   += (cTmpQry)->(N3_VORIG1)-(cTmpQry)->(N3_VRDACM1)
		oSectionA:Cell("VALORE"):SetValue(Transform((cTmpQry)->(N3_VORIG1), cPictVlr))
		oSectionA:Cell("EJECICE"):SetValue(Transform((cTmpQry)->(N3_VRDBAL1), cPictVlr))
		oSectionA:Cell("ACUMULE"):SetValue(Transform((cTmpQry)->(N3_VRDACM1), cPictVlr))		
		oSectionA:Cell("VALORRE"):SetValue(Transform(((cTmpQry)->(N3_VORIG1)-(cTmpQry)->(N3_VRDACM1)), cPictVlr))
		/*Seccion Revaluo*/
		If  nIndPer > 0 
			If (cTmpQry)->(N3_VORIG1) >0 
				nIndAdq := POSICIONE("SIE",1,XFILIAL("SIE")+STRZERO(YEAR((cTmpQry)->(N3_AQUISIC)),4)+STRZERO(MONTH((cTmpQry)->(N3_AQUISIC)),2),"IE_INDICE") 
				nVlrRev := IIf(nIndAdq>0,(cTmpQry)->(N3_VORIG1)*(nIndPer/nIndAdq),0 )
			Endif
			If  nIndPerA > 0 
				If  (cTmpQry)->(N3_VRDBAL1) >0  
					nEjeRev := (cTmpQry)->(N3_VRDBAL1)*(nIndPer/nIndPerA)
				Endif
				If  (cTmpQry)->(N3_VRDACM1) >0  
					nAcuRev := (cTmpQry)->(N3_VRDACM1)*(nIndPer/nIndPerA)
				Endif
			Endif
		Endif 
		nVReRev := (nVlrRev-nAcuRev) 
		nTotVlrR   += nVlrRev
		nTotEjeR   += nEjeRev
		nTotAcuR   += nAcuRev
		nTotVReR   += nVReRev
		nTotVlrD   += (nVlrRev-(cTmpQry)->(N3_VORIG1))
		nTotEjeD   += (nEjeRev-(cTmpQry)->(N3_VRDBAL1))
		nTotAcuD   += (nAcuRev-(cTmpQry)->(N3_VRDACM1))
		nTotVReD   += nVReRev - ( (cTmpQry)->(N3_VORIG1)-(cTmpQry)->(N3_VRDACM1) )
		oSectionA:Cell("VALORF"):SetValue(Transform(nVlrRev, cPictVlr))
		oSectionA:Cell("EJECICF"):SetValue(Transform(nEjeRev, cPictVlr))
		oSectionA:Cell("ACUMULF"):SetValue(Transform(nAcuRev, cPictVlr))		
		oSectionA:Cell("VALORRF"):SetValue(Transform(nVReRev, cPictVlr))
		/*Seccion Diferencia*/
		oSectionA:Cell("VALORG"):SetValue(Transform((nVlrRev-(cTmpQry)->(N3_VORIG1)), cPictVlr))
		oSectionA:Cell("EJECICG"):SetValue(Transform((nEjeRev-(cTmpQry)->(N3_VRDBAL1)), cPictVlr))
		oSectionA:Cell("ACUMULG"):SetValue(Transform((nAcuRev-(cTmpQry)->(N3_VRDACM1)), cPictVlr))		
		oSectionA:Cell("VALORRG"):SetValue(Transform(nVReRev - (((cTmpQry)->(N3_VORIG1)-(cTmpQry)->(N3_VRDACM1))), cPictVlr))
		oSectionA:PrintLine()
		
		cChavAnt := (cTmpQry)->(NG_GRUPO)
		(cTmpQry)->(dbSkip())
		cChavGpo := (cTmpQry)->(NG_GRUPO)
		
		If  cChavAnt <> cChavGpo //Hacer corte por Grupo e imprimir totales	
			fTotales(nTotVlrO, nTotEjeO, nTotAcuO, nTotVReO,;
			  		 nTotVlrR, nTotEjeR, nTotAcuR, nTotVReR,;
			  		 nTotVlrD, nTotEjeD, nTotAcuD, nTotVReD,  "Total Grupo " ) //Total por Grupo //+ Alltrim(cChavAnt)	
			nTGlVlrO  += nTotVlrO
			nTGlEjeO  += nTotEjeO
			nTGlAcuO  += nTotAcuO
			nTGlVReO  += nTotVReO
			nTGlVlrR  += nTotVlrR
			nTGlEjeR  += nTotEjeR
			nTGlAcuR  += nTotAcuR
			nTGlVReR  += nTotVReR
			nTGlVlrD  += nTotVlrD
			nTGlEjeD  += nTotEjeD
			nTGlAcuD  += nTotAcuD
			nTGlVReD  += nTotVReD	
			
			nTotVlrO  := 0
			nTotEjeO  := 0
			nTotAcuO  := 0
			nTotVReO  := 0
			nTotVlrR  := 0
			nTotEjeR  := 0
			nTotAcuR  := 0
			nTotVReR  := 0	
			nTotVlrD  := 0
			nTotEjeD  := 0
			nTotAcuD  := 0
			nTotVReD  := 0
		Endif
		
		If (cTmpQry)->(Eof())
			fTotales(nTGlVlrO, nTGlEjeO, nTGlAcuO, nTGlVReO,;
			 		  nTGlVlrR, nTGlEjeR, nTGlAcuR, nTGlVReR,;
			 		  nTGlVlrD, nTGlEjeD, nTGlAcuD, nTGlVReD, "Total General: ", 2) //Total Reporte		
		EndIf

	EndDo
	//Finaliza reporte
	oReport:EndReport()
	(cTmpQry)->(dbCloseArea())
Return


/*/{Protheus.doc} Print2Report
Obtiene datos y genera el informe -Transferencias-.

@Type    Function
@Author  Laura Elena Medina Prado 
@Since   04/03/2019
@Version P12.1.17
@Param   
@Return  
/*/
Static Function Print2Report(oReport)
Local nLoop     := 0
Local cQuery    := ""
Local nVlrAju   := 0
Local nActivos  := 0
Local nIndPer   := 0 
Local nIndDat   := 0
Local cChavCta  := ""
Local cChavAnt  := ""
Local nTotVlrH  := 0
Local nTotVlrA  := 0
Local nTotDif   := 0
Local nTotGVlrH := 0
Local nTotGVlrA := 0
Local nTotGDif  := 0
Local cMotivo   := "04"
Local cTPCta    := "1"

	/* Obtiene Activos*/
	cQuery := " SELECT NG_GRUPO, NG_DESCRIC, N1_CBASE, N1_ITEM, N1_DESCRIC, N4_CONTA, N4_VLROC1, N4_DATA " 
	cQuery += " FROM " + RetSqlName("SNG") + " SNG, " + RetSqlName("SN1") + " SN1, " + RetSqlName("SN4") + " SN4 "
	cQuery += " WHERE NG_GRUPO = N1_GRUPO "
	cQuery += " AND N1_CBASE = N4_CBASE "
	cQuery += " AND N1_ITEM  = N4_ITEM "
	cQuery += " AND N4_DATA BETWEEN "+Dtos(dDatIni)+" AND "+Dtos(dDatFim)  
	cQuery += " AND NG_GRUPO  BETWEEN '"+cIniGpo+"' AND '"+ cFimGpo +"'" 
	cQuery += " AND N4_OCORR = '"+ cMotivo +"' "
	cQuery += " AND N4_TIPOCNT = '"+ cTPCta +"' "  
	cQuery += " AND N1_FILIAL = '" + xFilial("SN1") + "' "
	cQuery += " AND NG_FILIAL = '" + xFilial("SNG") + "' "
	cQuery += " AND N4_FILIAL = '" + xFilial("SN4") + "' "
	cQuery += " AND SN1.D_E_L_E_T_ = '' "
	cQuery += " AND SNG.D_E_L_E_T_ = '' "
	cQuery += " AND SN4.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY N4_CONTA, N4_DATA "
	cQuery := ChangeQuery(cQuery)     	
	
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cTmpQry,.T.,.T.)
	TcSetField(cTmpQry, "N4_DATA", "D",  TamSX3("N4_DATA")[1],   TamSX3("N4_DATA")[2])
	TcSetField(cTmpQry, "N4_VLROC1","N", TamSX3("N4_VLROC1")[1], TamSX3("N4_VLROC1")[2])

	Count to nActivos
	
	If  nActivos > 0
		nIndPer  := POSICIONE("SIE",1,XFILIAL("SIE")+STRZERO(YEAR(dDatFim),4)+STRZERO(MONTH(dDatFim),2),"IE_INDICE")
		oSectionA:Init() 
		oSectionA:Cell("CODIGOA"):SetTitle("")
		oSectionA:Cell("DESCRIA"):SetTitle("")
		oSectionA:Cell("CODIGOB"):SetTitle("")
		oSectionA:Cell("DESCRIB"):SetTitle("")
		oSectionA:Cell("CONTA"):SetTitle("")
		oSectionA:Cell("VALORH"):SetTitle("")
		oSectionA:Cell("VALORA"):SetTitle("")
		oSectionA:Cell("DIFERE"):SetTitle("") 
		
		oSectionA:Cell("CODIGOA"):SetValue(STR0009+" "+CRLF+STR0002 )
		oSectionA:Cell("DESCRIA"):SetValue(STR0010+" "+STR0002)
		oSectionA:Cell("CODIGOB"):SetValue(STR0009+" "+STR0036)
		oSectionA:Cell("DESCRIB"):SetValue(STR0010+" "+STR0036)
		oSectionA:Cell("CONTA"):SetValue(STR0037)
		oSectionA:Cell("VALORH"):SetValue(STR0038)
		oSectionA:Cell("VALORA"):SetValue(STR0039)
		oSectionA:Cell("DIFERE"):SetValue(STR0008) 
		oSectionA:PrintLine()
		oReport:ThinLine()	
	Endif
	
	(cTmpQry)->(dbGoTop())
	While (cTmpQry)->(!Eof())
		If  oReport:Cancel()
			Exit
		EndIf
				
		nVlrAju  := 0
		/*Seccion Grupo*/
		oSectionA:Cell("CODIGOA"):SetValue((cTmpQry)->(NG_GRUPO))
		oSectionA:Cell("DESCRIA"):SetValue((cTmpQry)->(NG_DESCRIC)) 
		/*Seccion Activo Fijo*/
		oSectionA:Cell("CODIGOB"):SetValue((cTmpQry)->(N1_CBASE)+" "+(cTmpQry)->(N1_ITEM))
		oSectionA:Cell("DESCRIB"):SetValue((cTmpQry)->(N1_DESCRIC))
		/*Seccion Transferencia*/ 
		If  nIndPer > 0 
			If (cTmpQry)->(N4_VLROC1) >0 
				nIndDat := POSICIONE("SIE",1,XFILIAL("SIE")+STRZERO(YEAR((cTmpQry)->(N4_DATA)),4)+STRZERO(MONTH((cTmpQry)->(N4_DATA)),2),"IE_INDICE") 
				nVlrAju := IIf(nIndDat>0,(cTmpQry)->(N4_VLROC1)*(nIndPer/nIndDat),0 )
			Endif
		Endif 
		nTotVlrH  += ((cTmpQry)->(N4_VLROC1))
		nTotVlrA  += (nVlrAju)
		nTotDif   += (nVlrAju - (cTmpQry)->(N4_VLROC1))
		oSectionA:Cell("CONTA"):SetValue((cTmpQry)->(N4_CONTA))
		oSectionA:Cell("VALORH"):SetValue(Transform((cTmpQry)->(N4_VLROC1), cPictVlr))
		oSectionA:Cell("VALORA"):SetValue(Transform(nVlrAju, cPictVlr))		
		oSectionA:Cell("DIFERE"):SetValue(Transform(nVlrAju - (cTmpQry)->(N4_VLROC1),  cPictVlr))
		oSectionA:PrintLine()
			
		cChavAnt := (cTmpQry)->(N4_CONTA)
		(cTmpQry)->(dbSkip())
		cChavCta := (cTmpQry)->(N4_CONTA)
		
		If  cChavAnt <> cChavCta //Hacer corte por cuenta e imprimir totales
			//oReport:SkipLine(1)
			//oSectionA:Finish()
			f2Totales(nTotVlrH, nTotVlrA, nTotDif, "Total Cuenta " ) //Total por Grupo //+ Alltrim(cChavAnt)
			nTotGVlrH := nTotGVlrH + nTotVlrH
			nTotGVlrA := nTotGVlrA + nTotVlrA
			nTotGDif  := nTotGDif  + nTotDif
			nTotVlrH  := 0
			nTotVlrA  := 0
			nTotDif   := 0
		Endif
		
		If (cTmpQry)->(Eof())
			//f2Totales(nTotVlrH, nTotVlrA, nTotDif, "Total Grupo: "+ Alltrim(cChavAnt) ) //Total por Grupo
			f2Totales(nTotGVlrH, nTotGVlrA, nTotGDif, "Total General: ", 2) //Total Reporte
		EndIf
		 
	EndDo
	//Finaliza reporte
	oReport:EndReport()
	(cTmpQry)->(dbCloseArea())
Return


/*/{Protheus.doc} VldParam
Validación de los parámetros.

@Type    Function
@Author  Laura Elena Medina Prado 
@Since   01/03/2019
@Version P12.1.17
@Param   
@Return  
/*/

Static Function VldParam() 
Local lRet := .T. 
Local aArea     := GetArea()
/*
Private dIniFch    := ("//")
Private dFinFch    := ("//")
Private cIniGpo    := ""
Private cFimGpo    := 0
Private cPestana   := 1 */
dDatIni  := MV_PAR01
dDatFim  := MV_PAR02
cIniGpo  := MV_PAR03
cFimGpo  := MV_PAR04
cPestana := MV_PAR05
//Validaciones del Periodo
If  Empty(dDatIni) .And. Empty(dDatFim)
	AVISO(STR0024,STR0026,{STR0025}) //Atención,"Se debe informar un Rango de Periodos.",{Ok}
	lRet := .F.
Elseif (!Empty(dDatIni) .And. !Empty(dDatFim) ) .OR. (!Empty(dDatIni) .And. Empty(dDatFim))
	If  dDatIni>dDatFim .OR. (!Empty(dDatIni) .And. Empty(dDatFim))
		AVISO(STR0024,STR0028,{STR0025}) //"El Periodo de Inicio debe ser menor al Final."
		lRet := .F.
	Endif
Endif

//Validaciones del Grupo de Bienes
If  lRet .And. ((Empty(cIniGpo) .And. Empty(cFimGpo)) .OR.  (!Empty(cIniGpo) .And. Empty(cFimGpo)) )
	AVISO(STR0024,STR0027,{STR0025}) //Atención,"Se debe informar un Rango de Grupo de Bienes.",{Ok}
	lRet := .F.
Endif 
	
//Validación de la Posición
If  lRet .And. (cPestana != 1 .AND. cPestana != 2)
	AVISO(STR0024,STR0029,{STR0025}) //Atención,"Indique la posición.",{Ok}
	lRet := .F.
Endif

RestArea(aArea)
Return lRet



/*/{Protheus.doc} VerBaixa
Verifica si es una Baja o Venta.

@Type    Function
@Author  Laura Elena Medina Prado 
@Since   05/03/2019
@Version P12.1.17
@Param   
@Return  
/*/

Static Function VerBaixa(cBase,cItem)
Local cQuery    := ""
Local cMotivo   := "01"
Local cSN4Qry   := GetNextAlias()
Local nTipBaixa := 0 
Local aArea     := GetArea()

cQuery := " SELECT N4_CBASE, N4_ITEM, N4_MOTIVO, N4_NOTA " 
cQuery += " FROM " + RetSqlName("SN4") + " SN4 " 
cQuery += " WHERE  N4_CBASE = '"+ cBase +"' " 
cQuery += " AND N4_ITEM  = '"+ cItem +"' " 
cQuery += " AND N4_MOTIVO = '"+ cMotivo +"' " 
cQuery += " AND N4_FILIAL = '" + xFilial("SN4") + "' "
cQuery += " AND SN4.D_E_L_E_T_ = '' "
cQuery += " ORDER BY N4_NOTA DESC "
cQuery := ChangeQuery(cQuery)     
	
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cSN4Qry,.T.,.T.)

(cSN4Qry)->(dbGoTop())
While (cSN4Qry)->(!Eof())
	nTipBaixa := 2 //Baja
	If  !Empty((cSN4Qry)->(N4_NOTA))
		 nTipBaixa := 1 //Vendido
		 Exit 
	Endif 
(cSN4Qry)->(dbSkip())
EndDo

RestArea(aArea)
Return nTipBaixa


/*/{Protheus.doc} f2Totales
Muestra totales en informe.

@Type    Static Function
@Author  Laura Elena Medina Prado 
@Since   07/03/2019
@Version P12.1.17
@Param   nTot1: Valor Historio
		 nTot2: Valor Ajustado
		 nTot3: Valor Diferencia
		 cDescTotal: Descripción
		 nBandera:  Bandera para fechar la SecciónA
@Return  
/*/
Static Function f2Totales(nTot1, nTot2, nTot3, cDescTotal, nBandera)
Default nTot1 := 0
Default nTot2 := 0
Default nTot3 := 0
Default cDescTotal := 0
Default nBandera   := 1
 
oSectionA:Cell("CODIGOA"):SetTitle("")
oSectionA:Cell("DESCRIA"):SetTitle("")
oSectionA:Cell("CODIGOB"):SetTitle("")
oSectionA:Cell("DESCRIB"):SetTitle("")
oSectionA:Cell("CONTA"):SetTitle("")
oSectionA:Cell("VALORH"):SetTitle("")
oSectionA:Cell("VALORA"):SetTitle("")
oSectionA:Cell("DIFERE"):SetTitle("") 

oSectionA:Cell("CODIGOA"):SetValue("")
oSectionA:Cell("DESCRIA"):SetValue(cDescTotal)	
oSectionA:Cell("CODIGOB"):SetValue("")
oSectionA:Cell("DESCRIB"):SetValue("")
oSectionA:Cell("CONTA"):SetValue("")
oSectionA:Cell("VALORH"):SetValue(Transform(nTot1, cPictVlr))	
oSectionA:Cell("VALORA"):SetValue(Transform(nTot2, cPictVlr))	
oSectionA:Cell("DIFERE"):SetValue(Transform(nTot3, cPictVlr))	
oSectionA:PrintLine()
oReport:SkipLine(1)
If  nBandera == 2
	oSectionA:Finish()
Endif	
Return


/*/{Protheus.doc} fTotales
Muestra totales en informe.

@Type    Static Function
@Author  Laura Elena Medina Prado 
@Since   07/03/2019
@Version P12.1.17
@Param   nTot1-nTot12: Valor X
		 cDescTotal: Descripción
		 nBandera:  Bandera para fechar la SecciónA
@Return  
/*/
Static Function fTotales(nTot1,nTot2,nTot3,nTot4,nTot5,nTot6,nTot7,nTot8,nTot9,nTot10,nTot11,nTot12,cDescTotal, nBandera)
Default nTot1 := 0
Default nTot2 := 0
Default nTot3 := 0
Default nTot4 := 0
Default nTot5 := 0
Default nTot6 := 0
Default nTot7 := 0
Default nTot8 := 0
Default nTot9 := 0
Default nTot10:= 0
Default nTot11:= 0
Default nTot12:= 0
Default cDescTotal := 0
Default nBandera   := 1
  
oSectionA:Cell("CODIGOA"):SetTitle("")
oSectionA:Cell("DESCRIA"):SetTitle("")

oSectionA:Cell("CODIGOB"):SetTitle("")
oSectionA:Cell("DESCRIB"):SetTitle("")
oSectionA:Cell("ESTADO"):SetTitle("")

oSectionA:Cell("ADQUISA"):SetTitle("")
oSectionA:Cell("BAJA"):SetTitle("")

oSectionA:Cell("ADQUISB"):SetTitle("") 	
oSectionA:Cell("ACUMULA"):SetTitle("")
oSectionA:Cell("MES"):SetTitle("")
oSectionA:Cell("CCOSTO"):SetTitle("")
oSectionA:Cell("AXL"):SetTitle("")
oSectionA:Cell("PNETO"):SetTitle("")

oSectionA:Cell("VALORE"):SetTitle("")
oSectionA:Cell("EJECICE"):SetTitle("")
oSectionA:Cell("ACUMULE"):SetTitle("") 
oSectionA:Cell("VALORRE"):SetTitle("") 
oSectionA:Cell("VALORF"):SetTitle("")
oSectionA:Cell("EJECICF"):SetTitle("")
oSectionA:Cell("ACUMULF"):SetTitle("") 
oSectionA:Cell("VALORRF"):SetTitle("") 

oSectionA:Cell("VALORG"):SetTitle("")
oSectionA:Cell("EJECICG"):SetTitle("")
oSectionA:Cell("ACUMULG"):SetTitle("") 
oSectionA:Cell("VALORRG"):SetTitle("") 

//Celdas
oSectionA:Cell("CODIGOA"):SetValue("")
oSectionA:Cell("DESCRIA"):SetValue(cDescTotal)

oSectionA:Cell("CODIGOB"):SetValue("")
oSectionA:Cell("DESCRIB"):SetValue("")
oSectionA:Cell("ESTADO"):SetValue("")

oSectionA:Cell("ADQUISA"):SetValue("")
oSectionA:Cell("BAJA"):SetValue("")

oSectionA:Cell("ADQUISB"):SetValue("") 	
oSectionA:Cell("ACUMULA"):SetValue("")
oSectionA:Cell("MES"):SetValue("")
oSectionA:Cell("CCOSTO"):SetValue("")
oSectionA:Cell("AXL"):SetValue("")
oSectionA:Cell("PNETO"):SetValue("")

oSectionA:Cell("VALORE"):SetValue(Transform(nTot1, cPictVlr))
oSectionA:Cell("EJECICE"):SetValue(Transform(nTot2, cPictVlr))
oSectionA:Cell("ACUMULE"):SetValue(Transform(nTot3, cPictVlr)) 
oSectionA:Cell("VALORRE"):SetValue(Transform(nTot4, cPictVlr))

oSectionA:Cell("VALORF"):SetValue(Transform(nTot5, cPictVlr))
oSectionA:Cell("EJECICF"):SetValue(Transform(nTot6, cPictVlr))
oSectionA:Cell("ACUMULF"):SetValue(Transform(nTot7, cPictVlr)) 
oSectionA:Cell("VALORRF"):SetValue(Transform(nTot8, cPictVlr))

oSectionA:Cell("VALORG"):SetValue(Transform(nTot9, cPictVlr))
oSectionA:Cell("EJECICG"):SetValue(Transform(nTot10, cPictVlr))
oSectionA:Cell("ACUMULG"):SetValue(Transform(nTot11, cPictVlr))
oSectionA:Cell("VALORRG"):SetValue(Transform(nTot12, cPictVlr))	
oSectionA:PrintLine()
oReport:SkipLine(1)
If  nBandera == 2
	oSectionA:Finish()
Endif	
	
Return