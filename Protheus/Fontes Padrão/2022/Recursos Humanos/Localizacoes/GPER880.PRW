#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER880.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER880   ºAutor  ³Rogerio Ribeiro        º Data ³  20/02/09                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera arq. magnetico PILA (Planilha Integrada de Liquidacao de Aportes)      º±±
±±ºUso       ³ AP     											                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                             º±±
±±ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶±±
±±ºProgramador  ³ Data     ³ FNC            ³  Motivo da Alteracao                        º±±
±±ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶±±
±±º             ³02/06/2009³                ³Alteracao nos campos das tabelas S009, S014  º±±
±±º             ³          ³                ³e S021                                       º±±
±±ºFrancisco Jr ³07/01/2009³00000000259/2010³Compatibilizar fonte para Gestao Corporativa.º±±
±±º             ³          ³                ³                                             º±±
±±ºAdemar Jr.   ³04/07/2011³00000012173/2011³- Ajuste para chamada do SX1->GP880F4 entre  º±±
±±º             ³          ³Chamado_SDOQN6  ³  outras alteracoes                          º±±
±±ºAdemar Jr.   ³06/02/2012³000000?????/2011³- Ajustes diversos conforme validacao em Cli-º±±
±±º             ³          ³Chamado TEGDi2  ³  ente Piloto .                              º±±
±±ºAdemar Jr.   ³07/01/2013³Chamado: TETHSC |-Ajuste para Limitar os campos 42,43 e 44 em º±±
±±º             ³          ³                ³ 25 Salarios Minimos.                        º±±
±±ºAdemar Jr.   ³28/01/2013³Chamado: TGNZCW |-Implmentado geracao de linha do Beneficiarioº±±
±±º             ³          ³                ³ UPC Adicional, conforme consta no Artigo 11,º±±
±±º             ³          ³                ³ Numero 40 do Manual do Pila.                º±±
±±ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶±±
±±ºM. Camargo   ³15/122/013³Proyecto:       ³Modificaciones respecto a los nuevos decretosº±±
±±º             ³          ³                ³hasta el 2013 para el funcionamiento de la   º±±
±±º             ³          ³COL118_RH       ³PILA los cuales consisten en la generación deº±±
±±º             ³          ³                ³registros conforme las novedades del periodo º±±
±±º             ³          ³Requerimiento:  ³asi como la generación de los archivos planosº±±
±±º             ³          ³269704          ³y reporte en excel.                          º±±
±±ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶±±
±±ºJonathan Glez³08/03/2016³PCREQ-9393      ³Localizacion SIGAGPE v12 para Colombia.      º±±
±±º             ³          ³                ³Se realiza merge con version 11.8 para traer º±±
±±º             ³          ³                ³las soluciones de llamados TQHD89 y TSEMGZ.  º±±
±±º.Camargo     ³08/11/2017³                ³Adecuaciones resolución 2388 2016            º±±
±±ºM.Camargo    ³15/10/2018³DMINA-4640      ³Adecuaciones PILA Colombia. Actualización    º±±
±±º             ³          ³                ³acorde a cambios fiscales 2018        		  º±±
±±ºM.Camargo    ³15/10/2018³DMINA-4997      ³Adecuaciones PILA Colombia. Modificación col º±±
±±º             ³          ³                ³76 (74 en fuente).                 		  º±±
±±ºOscar Garcia ³28/08/2020³  DMINA-9685    ³Adecuaciones PILA Colombia. Modificación de  º±±
±±º  Marco A.   ³          ³                ³la impresion del campo 41.                   º±±
±±º   Marco A.  ³10/11/2020³  DMINA-10611   ³En la funcion GPE880Exec(), se sustituye la  º±±
±±º             ³          ³                ³variable nI por nPosRCP. (COL)               º±±
±±º   Marco A.  ³27/06/2021³  DMINA-12631   ³En la funcion GPE880Exec(), se substrae las  º±±
±±º             ³          ³                ³comillas sencillas a las preguntas 3, 5 y 6  º±±
±±ºARodriguez   ³14/07/2021³DMINA-13004     ³Se duplica valor de columna 47 en la 50-Totalº±±
±±º             ³          ³                ³cotización Pensiones. COL                    º±±
±±ºDiego rivera ³18/11/2021³DMINA-14075     ³En el método GetStructure(), de la rutina    º±±
±±º             ³          ³                ³GPER880, se realiza el intercambio de        º±±
±±º             ³          ³                ³descripciones, para que la columna 69 corres-º±±
±±º             ³          ³                ³ponda con "Valor aporte ICBF" y la columna 70º±±
±±º             ³          ³                ³corresponda con "Tarifa aporte ESAB".        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPER880()
	Local aArea := getArea()
	Local aSays		:= {}
	Local aButtons	:= {}
	Local lRun		:= .F.
		
	Private cCadastro 	:= OemToAnsi(STR0001) //"Geracao da Planilha Integrada de Liquidacao de Contribuicoes"	 
	Pergunte("GP880F4", .F.)	
	
	AAdd(aSays, OemToAnsi(STR0002))  // "Rotina para gerar os arquivos magneticos PILA."
	AAdd(aSays, OemToAnsi(STR0003))  // "O sistema irá gerar os arquivos de acordo com os parâmetros informados."

	// Para Gestao Corporativa.	                                                             
	AAdd(aButtons, {5, .T., {|| Pergunte("GP880F4", .T.)  } } ) 
	AAdd(aButtons, {1, .T., {|| lRun:= .T., FechaBatch() } } )
	AAdd(aButtons, {2, .T., {|| lRun:= .F., FechaBatch() } } )
		
	FormBatch(cCadastro, aSays, aButtons)

	If lRun
		Proc2BarGauge(	{|| GPE880Exec() }	,;	//Acao a ser Executada
							NIL				,;	//Titulo do Dialogo         
							NIL				,;	//Mensagem para a 1a. BarGauge 
							NIL				,;	//Mensagem para a 2a. BarGauge
							.T.				,;	//Se habilitara o botao para "Abortar" o processo
							.T.				,;	//Se havera controle de estimativa de tempo na 1a. BarGauge
							.T.				,;	//Se havera conteole de estimativa de tempo na 2a. BarGauge
							.T.				 ;	//Se ira mostrar a 2a. BarGauge / Caso parametro esteja para todas as empreas
						)
	EndIf
	RestArea(aArea)
Return

        
/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³          ³Autor³Rogerio Ribeiro            ³Data³11/03/2009³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³GPER880			                    	   					³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/
Function GPE880Exec()
	Local aArea:=getArea()
	Local nCount      := 0
	Local cTime1, cTime2
	Local oPila1 := Nil
	Local oPila2 := Nil
	Local nSalMin 	:= 0
	Local nI 			:= 0 
	
	Local aStruRCP	:= {}
	Local aMovRCP 	:= {}
	Local aRG1		:= {}
	Local nPosTpMov 	:= 0
	Local aMat		:= {}
	Local aNIT		:= {}
	Local aEPS		:= {}
	Local aAFP		:= {}
	Local cEntEPS		:= "" 
	Local cEntARL		:= ""
	Local cEntAFP		:= ""
	Local cEntCCF		:= ""
	Local nPosEPS		:= 0
	Local nPosARL		:= 0
	Local nPosAFP		:= 0
	Local cFormaApr		:= ""
	Local aMovPer		:= {} 		// Almacena movimientos del periodo y del histórico del periodo.
	Local aPeriodos		:= {}
	Local nCotAFP		:= 0
	Local nCotSalud		:= 0
	Local nPosSal		:= 0
	Local cTpImss		:= ""
	Local nRegistros	:= 0
	Local nContEmp		:= 0
	Local cFile3 		:= ""
	Local QSRA			:= ""
	Local cIds			:= "" // Guardas ird's de cálculo obtenidos de la S031 relacionados al tipo de ausencia
	Local nTotReg 		:= 0
	Local NAUX01 	:= 0
	Local NAUX02 	:= 0
	Local NAUX03 	:= 0
	Local NAUX04 	:= 0
	Local nDiasAus := 0
	Local lPension := .F.
	Local lSS 		:= .F.
	Local nPosRCP	:= 0
	Local cConCol15:= ""
	Local cConCol16:= ""
	Local cDatCol16:= ""
	Local cConCol21:= ""
	Local cDatCol21:= ""
	Local cConCol29:= ""
	Local cDatCol29:= ""
	Local dDatCo24A := CTOD("  /  /    ")
	Local dDatCo24B := CTOD("  /  /    ")
	Local cConCol24 := ""
	Local cDatCol24A := ""
	Local cDatCol24B := ""
				    
	Local dDatCo25A := CTOD("  /  /    ")
	Local dDatCo25B := CTOD("  /  /    ")
	Local cConCol25 := ""
	Local cDatCol25A := ""
	Local cDatCol25B := ""
	Local dDatCo26A := CTOD("  /  /    ")
	Local dDatCo26B := CTOD("  /  /    ")
	Local cConCol26 := ""
	Local cDatCol26A := ""
	Local cDatCol26B := ""
	Local dDatCo27A := CTOD("  /  /    ")
	Local dDatCo27B := CTOD("  /  /    ")
	Local cConCol27 := ""
	Local cDatCol27A := ""
	Local cDatCol27B := ""
	Local dDatCo30A := CTOD("  /  /    ")
	Local dDatCo30B := CTOD("  /  /    ")
	Local cConCol30 := ""
	Local cDatCol30A := ""
	Local cDatCol30B := ""
	Local cCGC		:= ""
	Local cTPSal	:= ""
	Local cFldTpSal		:= ""
	Local cFldRemVar	:= ""
	Local cFldTipCot	:= ""
	
	Private nFormaApr		// MV_PAR01
	Private cFilMatr		// MV_PAR02
	Private cFilSuc		// MV_PAR03
	Private dPerPag 		// MV_PAR04
	Private cProcesso		// MV_PAR05
	Private cProcedim		// MV_PAR06
	Private cTipoPlan		// MV_PAR07
	Private nNumPlan		// MV_PAR08
	Private dFecEfec      // MV_PAR09
	Private dDataPag		// MV_PAR10
	Private cTipoAcc		// MV_PAR11
	Private dDTIni			// MV_PAR12
	Private dDtFim			// MV_PAR13
	Private cFile01		// MV_PAR14
	Private cFile02		// MV_PAR15
	Private nTipoArq		// MV_PAR16//
	Private cMats			// MV_PAR17
	Private cCodPila		
	Private nLin	             
	Private dFinPer		
	Private aMovUPS         := {}
	
	//----------------------------------------------------------------------------------------//
	// Carrega as Perguntas pra gerar o Arquivo Texto
	//----------------------------------------------------------------------------------------//
	Pergunte("GP880F4", .F.)	 

	nFormaApr	:= MV_PAR01
	cFilMatr	:= MV_PAR02
	cFilSuc	   	:= StrTran(IIF(!Empty(MV_PAR03), MV_PAR03, MV_PAR02), "'", "")
	dPerPag 	:= CTOD("01/" + MV_PAR04)
	cProcesso	:= StrTran(MV_PAR05, "'", "")
	cProcedim	:= StrTran(MV_PAR06, "'", "")
	cTipoPlan	:= MV_PAR07
	nNumPlan	:= MV_PAR08
	dFecEfec	:= MV_PAR09
	dDataPag	:= MV_PAR10
	cTipoAcc	:= MV_PAR11
	dDTIni		:= MV_PAR12
	dDtFim		:= MV_PAR13
	cFile01		:= MV_PAR14
	cFile02		:= MV_PAR15
	nTipoArq	:= MV_PAR16
	cMats		:= MV_PAR17
	dFinPer 	:= MonthSum(dPerPag,1) -1
	nSalMin 	:= FTABELA("S019",1,4, dPerPag)
	aStruRCP 	:= RCP->(dbStruct())

	cFormaApr 	:= GetPresentationForm(nFormaApr)
	If at(".",cfile02)>0
		cFile3 	:= Substr(cFile02,1,at(".",cfile02)) + "xls"
	Else
		cFile3	:= alltrim(cfile02) + ".xls"
		cFile02 := alltrim(cfile02) + ".txt"
	EndIf
	aPeriodos 	:= fgetPer(month(dPerPag),year(dPerPag))
	QSRA  		:= FgetEmpl(aPeriodos) //Extrae empleados a procesar de SRA/SRC/SRD
	QSRA2 		:= FgetEmpl(aPeriodos,"40") //Extrae empleados a procesar de SRA/SRC/SRD excepto RA_TIPCOT == 40 
	DBSelectArea("SRA")
	DBSetOrder(1)
    cIdsAus  	:= fCodFolRCM()
	//-------------------------------------------------------------------------------------//
	// Arquivo Tipo 1								                                       		//
	//-------------------------------------------------------------------------------------//
	oPila1 := PILA():New(1)
	oPila2 := PILA():New(2)

	BarGauge1Set(2)
	cTime1 := Time()
	
	//-------------------------------------------------------------------------------------//
	// Arquivo Tipo 1 - Dados Gerais do Aportante										   //
	//-------------------------------------------------------------------------------------//
	IncPrcG1Time(STR0004, 12, cTime1, .T., 1, 1)	//"Arquivo Tipo 1 - Dados Gerais do Aportante"
	
	If len(SM0->M0_CGC) < 17
		cCGC := SM0->M0_CGC + Space(17 - len(SM0->M0_CGC))
	ElseIf len(SM0->M0_CGC) > 17
		cCGC := Substr(SM0->M0_CGC,1,17)
	Else
		cCGC := SM0->M0_CGC
	EndIf

	NAUX01 := FPOSTAB('S010', cCGC, '=', 4) 
	If NAUX01 == 0
		NAUX01:=1
	EndIF
	NAUX02 := FPOSTAB('S011',cCGC, '=', 5) 
	IF NAUX02 == 0
		NAUX02:=1
	EndIF
			
	NAUX03:=FPOSTAB('S012', cCGC, '=', 4) 
	IF NAUX03==0
		NAUX03:=1
	EndIF
			
	NAUX04:=FPOSTAB('S004', MV_PAR01, '=', 1) 
	IF NAUX04==0
		NAUX04:=1
	EndIF

	cNumNIT :=  AllTrim(SubSTr(fTabela('S011',NAUX02,5),1,17))
	cDigNIT := "0"
	nPosNIT := AT("-",cNumNIT)
	If nPosNIT <> 0
	   cDigNIT := SubSTr(cNumNIT,nPosNIT+1,1)
	   cNumNIT := SubSTr(cNumNIT,1,nPosNIT-1)
	EndIF
	cIDRep := AllTrim(SubSTr(fTabela('S010',NAUX01,10),1,17))
	cDigRep := "0"                  
	nPosNIT := AT("-",cIDRep)
	If nPosNIT <> 0
	    cDigRep := SubSTr(cIDRep,nPosNIT+1,1)
	    cIDRep := SubSTr(cIDRep,1,nPosNIT-1)
	EndIF   
		    	
	//# Se o parametro cFile02 estiver vazio, gera tudo no cFile01
	If !Empty(cFile02)
		IF nTipoArq <> 2

			oPila1:AddRecord()
			oPila1:SetField( "1", fTabela('S011',NAUX02,4)) 
			oPila1:SetField( "2", fTabela('S011',NAUX02,11))
			oPila1:SetField( "3", cNumNIT)
			oPila1:SetField( "4", cDigNIT)
			oPila1:SetField( "5", IIF(nFormaApr == 2 , SM0->M0_CODFIL, ""))
			oPila1:SetField( "6", Iif(nFormaApr == 2 , SM0->M0_FILIAL, ""))
			oPila1:SetField( "7", fTabela('S011',NAUX02,6))
			oPila1:SetField( "8", fTabela('S010',NAUX01,7))
			oPila1:SetField( "9", fTabela('S011',NAUX02,7))
			oPila1:SetField("10", cFormaApr)
			oPila1:SetField("11", Substr(SM0->M0_ENDCOB,1,40))
			oPila1:SetField("12", SubStr(SM0->M0_CODMUN,1, 3))
			oPila1:SetField("13", fTabela('S010',NAUX01,8)) 
			oPila1:SetField("14", fTabela('S011',NAUX02,8)) 
			oPila1:SetField("15", SM0->M0_TEL)
			oPila1:SetField("16", SM0->M0_FAX)
			oPila1:SetField("17", fTabela('S010',NAUX01,9)) 
			oPila1:SetField("18", cIDRep) 
			oPila1:SetField("19", cDigRep) 
			oPila1:SetField("20", fTabela('S010',NAUX01,15)) 
			oPila1:SetField("21", fTabela('S010',NAUX01,11)) 
			oPila1:SetField("22", fTabela('S010',NAUX01,12)) 
			oPila1:SetField("23", fTabela('S010',NAUX01,13)) 
			oPila1:SetField("24", fTabela('S010',NAUX01,14)) 
			oPila1:SetField("25", DateToStr(dDtIni))
			oPila1:SetField("26", cTipoAcc)
			oPila1:SetField("27", DateToStr(dDtFim))	
			oPila1:SetField("28", fTabela('S011',NAUX02,9)) 
			oPila1:SetField("29", DateToStr(dPerPag, "YYYY-MM"))
			oPila1:SetField("30", fTabela('S010',NAUX01,16))  
			oPila1:SetField("31", IIF(fTabela('S011',NAUX02,6) == "D", fTabela('S012',NAUX03,11),"          "))
			oPila1:SetField("32", IIF(fTabela('S011',NAUX02,6) == "D",SM0->M0_ESTCOB,"  "))	
			oPila1:SetField("33", IIF(fTabela('S011',NAUX02,6) == "D",IIF(fTabela('S012',NAUX03,12) == "1","S","N"),"N")) 
			oPila1:SetField("34", IIF(fTabela('S012',NAUX03,13) == '1','S','N'))
			oPila1:SaveRecord()
			
			oPila1:WriteFile(cFile01)
		EndIF
	Else

			oPila1:SetField( "1", fTabela('S011',NAUX02,4)) 
			oPila1:SetField( "2", fTabela('S011',NAUX02,11))
			oPila1:SetField( "3", cNumNIT)
			oPila1:SetField( "4", cDigNIT)
			oPila1:SetField( "5", IIF(nFormaApr == 2 , SM0->M0_CODFIL, ""))
			oPila1:SetField( "6", Iif(nFormaApr == 2 , SM0->M0_FILIAL, ""))
			oPila1:SetField( "7", fTabela('S011',NAUX02,6))
			oPila1:SetField( "8", fTabela('S010',NAUX01,7))
			oPila1:SetField( "9", fTabela('S011',NAUX02,7))
			oPila1:SetField("10", cFormaApr)
			oPila1:SetField("11", Substr(SM0->M0_ENDCOB,1,40))
			oPila1:SetField("12", SubStr(SM0->M0_CODMUN,1, 3))
			oPila1:SetField("13", fTabela('S010',NAUX01,8)) 
			oPila1:SetField("14", fTabela('S011',NAUX02,8)) 
			oPila1:SetField("15", SM0->M0_TEL)
			oPila1:SetField("16", SM0->M0_FAX)
			oPila1:SetField("17", fTabela('S010',NAUX01,9)) 
			oPila1:SetField("18", cIDRep) 
			oPila1:SetField("19", cDigRep) 
			oPila1:SetField("20", fTabela('S010',NAUX01,15)) 
			oPila1:SetField("21", fTabela('S010',NAUX01,11)) 
			oPila1:SetField("22", fTabela('S010',NAUX01,12)) 
			oPila1:SetField("23", fTabela('S010',NAUX01,13)) 
			oPila1:SetField("24", fTabela('S010',NAUX01,14)) 
			oPila1:SetField("25", DateToStr(dDtIni))
			oPila1:SetField("26", cTipoAcc)
			oPila1:SetField("27", DateToStr(dDtFim))	
			oPila1:SetField("28", fTabela('S011',NAUX02,9)) 
			oPila1:SetField("29", DateToStr(dPerPag, "YYYY-MM"))
			oPila1:SetField("30", fTabela('S010',NAUX01,16)) 	
			oPila1:SetField("31", IIF(fTabela('S011',NAUX02,6) == "D", fTabela('S012',NAUX03,11),"          "))
			oPila1:SetField("32", IIF(fTabela('S011',NAUX02,6) == "D",SM0->M0_ESTCOB,"  "))	
			oPila1:SetField("33", IIF(fTabela('S011',NAUX02,6) == "D",IIF(fTabela('S012',NAUX03,12) == "1","S","N"),"N")) 
			oPila1:SetField("34", IIF(fTabela('S012',NAUX03,13) == '1','S','N'))
								
		oPila2:SaveRecord()		
	EndIf
	
	//-------------------------------------------------------------------------------------//
	// Arquivo Tipo 2 - Registro Tipo 1: Cabecalho                                         //
	//-------------------------------------------------------------------------------------//
	IncPrcG1Time(STR0005, 12, cTime1, .T., 2, 1)	//"Arquivo Tipo 2 - Registro Tipo 1: Cabecalho"

	DBSelectArea(QSRA2)
	count to nRegistros
	
	DBSelectArea(QSRA)
	(QSRA)->(dbGotop())	
		
	dPerPag := MonthSum(dPerPag,1)		
	// ARCHIVO TIPO 2 REGISTRO TIPO 1
	oPila2:AddRecord(1)
	oPila2:SetField( "1", 	"01") 
	oPila2:SetField("2A", 	"1") 						// 2
	oPila2:SetField("2B",	StrZero(1, 4))				// 3
	oPila2:SetField( "3",	fTabela('S011',NAUX02,4))	// 4
	oPila2:SetField( "4",	fTabela('S011',NAUX02,11))	// 5
	oPila2:SetField( "5",	cNumNIT) 					// 6
	oPila2:SetField( "6",	cDigNIT) 					// 7
	oPila2:SetField( "7",	cTipoPlan)					// 8
	oPila2:SetField( "8",	Iif(cTipoPlan $ "EAIMSYTXKH",SPACE(10),nNumPlan)) 
	oPila2:SetField( "9",	Iif(cTipoPlan $ "EAIMSYTXKH",SPACE(10),DateToStr(dDataPag, "YYYY-MM-DD")))
	oPila2:SetField("10",	cFormaApr )
	oPila2:SetField("11",	IIF(nFormaApr == 2 ,SM0->M0_CODFIL,''))	
	oPila2:SetField("12",	IIF(nFormaApr == 2 ,SM0->M0_FILIAL,''))	
	oPila2:SetField("13",	IIF(cTipoPlan $ "AESK",fgetCodPila(),IIF(cTipoPlan $ "I",'INDAPAR',NIL))) 
	oPila2:SetField("14",	IIf(cTipoPlan $ "YIH",DateToStr(dPerPag, "YYYY-MM") ,DateToStr(MonthSub(dPerPag, 1), "YYYY-MM")))
	oPila2:SetField("15",	DateToStr(dPerPag, "YYYY-MM"))
	oPila2:SetField("16",	strZero(0,10))
	oPila2:SetField("17",	DateToStr(dFecEfec))
	oPila2:SetField("18",	nRegistros)
	oPila2:SetField("19",	fBaseICB()) 
	oPila2:SetField("20",	fTabela('S010',NAUX01,16))  
	oPila2:SetField("21",	fTabela('S011',NAUX02,9))  
	oPila2:SaveRecord()		
		
	dPerPag := MonthSub(dPerPag,1)
	IncPrcG1Time(STR0006, 12, cTime1, .T., 3, 1)	
	
	cTime2	:= Time()                
	BarGauge2Set(nRegistros)
	
	//"Arquivo Tipo 2 - Registro Tipo 2: Liquidacao detalhada das Contribuicoes"
	While (QSRA)->(!Eof()) 
		nContEmp++
		IncPrcG2Time((QSRA)->RA_MAT + " - " + (QSRA)->RA_NOME,nRegistros, cTime2, .T., nContEmp, 1)	
		If rTrim((QSRA)->RA_FILIAL) $ cFilSuc .And. rTrim((QSRA)->RA_PROCES) $ cProcesso .and. !Empty((QSRA)->RA_CIC) 
			
			aMat := fFindMatAdic((QSRA)->RA_CIC)			
			If !(len(aMat)>0)
				AADD(aMat,{(QSRA)->RA_FILIAL,(QSRA)->RA_MAT})
			EndIf 
				
			lPension := (QSRA)->RA_PGAPORT $ '1'
			//Campos de la RCP
			nPosTpMov	:= aScan(aStruRCP, { |x,y| x[1] == "RCP_TPMOV" } )
			nPosEPS		:= aScan(aStruRCP, { |x,y| x[1] == "RCP_CODRPA" } )
			nPosARL		:= aScan(aStruRCP, { |x,y| x[1] == "RCP_NITARL" } )
			nPosAFP		:= aScan(aStruRCP, { |x,y| x[1] == "RCP_NITAFP" } )
			nPosSal		:= aScan(aStruRCP, { |x,y| x[1] == "RCP_SALMES" } )
			nPosDMo		:= aScan(aStruRCP, { |x,y| x[1] == "RCP_DTMOV" } )
			cConCol15	:= ""
			cConCol16	:= ""
			cDatCol16	:= ""
			cConCol21	:= ""
			cDatCol21	:= ""
			cConCol29	:= ""
			cDatCol29	:= ""
			
			If aScan(aNIT,(QSRA)->RA_CIC) == 0	// Para no procesar doble o triple un empleado con dos matrículas.
				
				cEntEPS := (QSRA)->RA_CODRPAT
				cEntAFP := (QSRA)->RA_CODAFP
				cEntARL := (QSRA)->RA_NITARL
				cEntCCF := (QSRA)->RA_CXCOMP
				cAdmiss := STOD((QSRA)->RA_ADMISSA)	
			
				// AUSENTISMOS								
				//Estructura array Ausentimos en el periodo
				//+------------------+
				//| 1.-Filial       |
				//| 2.-Matricula    |
				//| 3.-Tipo Afa		|
				//| 4.-Num ID		|
				//| 5.-fecha inicio	|
				//| 6.-Fecha Fin	|
				//| 7.-EPS			|
				//| 8.-AFP			|
				//| 9.-tp imss		|
				//|10.-No. autoriza	|
				//|11.-Concepto		|
				//+------------------+
								
				If (QSRA)->RA_TIPCOT <> '56' // El tipo de cotizante 56 no genera ausentismos para la pila 
					aMovSR8 := Fgetmovsr8("",aMat,"",aPeriodos,"",cIdsAus)
				End If				
				// AUSENTISMOS
				For nI := 1 to Len(aMovSR8)
					aAFP := {}
					Aeps := {}
				  	dDatCo24A := CTOD("  /  /    ")
				   	dDatCo24B := CTOD("  /  /    ")
				   	cConCol24 := ""
				   	cDatCol24A := ""
				   	cDatCol24B := ""
				    
				   	dDatCo25A := CTOD("  /  /    ")
				   	dDatCo25B := CTOD("  /  /    ")
				   	cConCol25 := ""
				   	cDatCol25A := ""
				   	cDatCol25B := ""

				   	dDatCo26A := CTOD("  /  /    ")
				   	dDatCo26B := CTOD("  /  /    ")
				   	cConCol26 := ""
				   	cDatCol26A := ""
				   	cDatCol26B := ""

				   	dDatCo27A := CTOD("  /  /    ")
				   	dDatCo27B := CTOD("  /  /    ")
				   	cConCol27 := ""
				   	cDatCol27A := ""
				   	cDatCol27B := ""
				    
				   	dDatCo30A := CTOD("  /  /    ")
				   	dDatCo30B := CTOD("  /  /    ")
				   	cConCol30 := ""
				   	cDatCol30A := ""
				   	cDatCol30B := ""
				    
				    nConCol45 := 0
				    				    				    				    	
					AADD(aNIT,(QSRA)->RA_CIC) 
					cTpImss   := aMovSr8[nI,2]
					cCvTpImss := aMovSr8[nI,7]
					aMovPer:= fgetMovPer("",aMat,"",aPeriodos,aMovSR8[nI,5],aMovSR8[nI,6])
					nCount++
					oPila2:AddRecord(2)
					oPila2:SetField( "1","02")
					oPila2:SetField( "2",StrZero(nCount, 5))
			 		oPila2:SetField( "3",(QSRA)->RA_TPCIC )
			 		oPila2:SetField( "4",(QSRA)->RA_CIC)
					oPila2:SetField( "5",(QSRA)->RA_TIPCOT)
			 		oPila2:SetField( "6",(QSRA)->RA_SUBCOT )
			 		oPila2:SetField( "7",IIF((QSRA)->RA_PGAPORT $ '1' ,'X',Space(1)) )
			 		oPila2:SetField( "8",IIF((QSRA)->RA_RESEXT $ '1' ,'X',Space(1))  )
			 		oPila2:SetField( "9", (QSRA)->RA_ESTADO )
					oPila2:SetField("10", SUBSTRING((QSRA)->RA_MUNICIP,3,3)) 
					oPila2:SetField("11",(QSRA)->RA_PRISOBR)
					oPila2:SetField("12",(QSRA)->RA_SECSOBR)
					oPila2:SetField("13",(QSRA)->RA_PRINOME)
					oPila2:SetField("14",(QSRA)->RA_SECNOME)
					oPila2:SetField("15"," ")
					oPila2:SetField("16"," ")
					oPila2:SetField("17"," ")
					oPila2:SetField("18"," ")
					oPila2:SetField("19"," ")
					oPila2:SetField("20"," ")
					oPila2:SetField("21"," ")
					oPila2:SetField("22"," ")
					oPila2:SetField("23"," ")
					Do Case  
						Case cTpImss $ "LFC"
							//Si existe la C y F yo L se coloca la C
							oPila2:SetField("24",IIF(cTpImss $ "LF" ,"X",IIF(cTpImss == "C","C"," ")))						
							oPila2:SetField("25"," ")
							oPila2:SetField("26"," ")
							oPila2:SetField("27"," ")
							oPila2:SetField("30",0)																					
							oPila2:SetField("57",Space(15))
							oPila2:SetField("58",0)		
							oPila2:SetField("59",Space(15))	
							oPila2:SetField("60",0)
							 
							cConCol24 := "24"
							dDatCo24A := STOD(aMovSr8[nI,3])
							dDatCo24B := STOD(aMovSr8[nI,4])	
						Case cTpImss $ "G"
							oPila2:SetField("24"," ")						
							oPila2:SetField("25","X")
							oPila2:SetField("26"," ")
							oPila2:SetField("27"," ")
							oPila2:SetField("30",0)		
							oPila2:SetField("57",Space(15)) 						
							oPila2:SetField("58",0)
							oPila2:SetField("59",Space(15))	
							oPila2:SetField("60",0)	
							
							 cConCol25 := "25"
							 dDatCo25A := STOD(aMovSr8[nI,3])
							 dDatCo25B := STOD(aMovSr8[nI,4])	 	
						Case cTpImss $ "MP"
							oPila2:SetField("24"," ")						
							oPila2:SetField("25"," ")
							oPila2:SetField("26","X")
							oPila2:SetField("27"," ")
							oPila2:SetField("30",0)		
							oPila2:SetField("57",Space(15))
							oPila2:SetField("58",0)	
							oPila2:SetField("59",Space(15))	
							oPila2:SetField("60",0) 

							 cConCol26 := "26"
							 dDatCo26A := STOD(aMovSr8[nI,3])
							 dDatCo26B := STOD(aMovSr8[nI,4])
							 
						Case cTpImss $ "RVR"
							oPila2:SetField("24"," ")						
							oPila2:SetField("25"," ")
							oPila2:SetField("26"," ")
							oPila2:SetField("27",IIF(cTpImss$"VR","X"," "))
							oPila2:SetField("30",0)		
							oPila2:SetField("57",Space(15))
							oPila2:SetField("58",0)	
							oPila2:SetField("59",Space(15))	
							oPila2:SetField("60",0)	

							 cConCol27 := "27"
							 dDatCo27A := STOD(aMovSr8[nI,3])
							 dDatCo27B := STOD(aMovSr8[nI,4])

						Case cTpImss $ "A"
							oPila2:SetField("24"," ")						
							oPila2:SetField("25"," ")
							oPila2:SetField("26"," ")
							oPila2:SetField("27"," ")	
							aMovPer:= fgetMovPer("",aMat,"0042",aPeriodos)	
							oPila2:SetField("30",IIF(Len(aMovPer)>0,aMovPer[1,1],0))		
							oPila2:SetField("57",Space(15))
							oPila2:SetField("58",0)	
							oPila2:SetField("59",Space(15))	
							oPila2:SetField("60",0)	
							
							cConCol30 := "30"
							dDatCo30A := STOD(aMovSr8[nI,3])
							dDatCo30B := STOD(aMovSr8[nI,4])
							 
					End Case

					nTotReg := 0
					oPila2:SetField("28"," ")									
					oPila2:SetField("29"," ")

					aMovEnt := fgetMovUPS("",aMat,"1239",aPeriodos,,)
					nLin      	:= IIF ( Len(aMovEnt) > 0,FPOSTAB("S008",aMovEnt[1,3],"=",4,"AFP ","=",6),0)
					nLin 		:= IIF(nLin <> 0 ,nLin,0)
					cCodPila 	:= IIF(nLin <> 0,SubStr(FTABELA("S008",nLin,7),1,6),"      ") // para extraer el código de la PILA.
											
					oPila2:SetField("31",cCodPila)
					oPila2:SetField("32"," ")
						
					//aMovEnt := fgetMovUPS("",aMat,"1240",aPeriodos,,)
					//nLin        := IIF ( Len(aMovEnt) > 0,FPOSTAB("S008",aMovEnt[1,3],"=",4,"EPS ","=",6),0)
					nLin := FPOSTAB("S008",(QSRA)->RA_CODRPAT/*aMovEnt[1,3]*/,"=",4,"EPS ","=",6)
					nLin 		:= IIF(nLin <> 0 ,nLin,0)
					cCodPila 	:= IIF(nLin <> 0,SubStr(FTABELA("S008",nLin,7),1,6),"      ") // para extraer el código de la PILA.
					oPila2:SetField("33",cCodPila)

					oPila2:SetField("34"," ")
					
					cIds 	:= GetParameter("S031",cCvTpImss,11)  	
					aMovEnt := fgetMovUPS("",aMat,cIds,aPeriodos,,)
					nLin 	:= IIF(len(aMovEnt)>0,FPOSTAB("S008",aMovEnt[1,3],"=",4,"CCF ","=", 6),0)
					nLin 	:= IIF(nLin <> 0 ,nLin,0)
					cCodPila:= IIF(nLin <> 0,SubStr(FTABELA("S008",nLin,7),1,6),"      ") // para extraer el código de la PILA.
				
					oPila2:SetField("35",cCodPila)
					cIds	:= GetParameter("S031",cCvTpImss,7)
					 
					If !Empty(cIds)								
						If AT(";", cIds) > 0
						    nId := 1
				 			cAux := cIds
				 			nPos := AT(";", cIds)
							While nPos > 0 .and.  nPos <= len(cIds)
				 				cIds := Substr(cAux,nId,nPos-1)
				 				aMovPer:= fgetMovPer("",aMat,cIds,aPeriodos)
				 				If Len(aMovPer) > 0
				 					Exit
				 				EndIF
				 				
				 				nId := nPos + 1
				 				cAux := Substr(cAux,nId)
				 				nPos := AT(";", cAux)
				 				nId := 1
				 			EndDo
 				 			
				 			If aMovPer == Nil .or. Len(aMovPer) == 0 .or. (aMovPer[1,1] == 0)
				 				aMovPer:= fgetMovPer("",aMat,cAux,aPeriodos)
				 			EndIF				 			
				 		EndIF	
 				     EndIF

					oPila2:SetField("36",IIF(Len(aMovPer)>0,aMovPer[1,1],0))	

					cIds 		:= GetParameter("S031",cCvTpImss,6) 
					If !Empty(cIds)		
						If AT(";", cIds) > 0
						    nId := 1
				 			cAux := cIds
				 			nPos := AT(";", cIds)
							While nPos > 0 .and.  nPos <= len(cIds)
				 				cIds := Substr(cAux,nId,nPos-1)
				 				aMovPer:= fgetMovPer("",aMat,cIds,aPeriodos)
				 				If Len(aMovPer) > 0
				 				 Exit
				 				EndIF
				 				nId := nPos + 1
				 				cAux := Substr(cAux,nId)
				 				nPos := AT(";", cAux)
				 				nId := 1
				 			EndDo
 				 			
				 			If aMovPer == Nil .or. Len(aMovPer) == 0 .or. (aMovPer[1,1] == 0)
				 				aMovPer:= fgetMovPer("",aMat,cAux,aPeriodos)
				 			EndIF
				 		EndIF	
 				     EndIF
 				     					
					oPila2:SetField("37",IIF(Len(aMovPer)>0,aMovPer[1,1],0))
					nDiasAus += IIF(Len(aMovPer)>0,aMovPer[1,1],0)
					
					cIds 		:= GetParameter("S031",cCvTpImss,10)  
					aMovPer:= fgetMovPer("",aMat,cIds,aPeriodos)	
					oPila2:SetField("38",IIF(Len(aMovPer)>0,aMovPer[1,1],0))
					cIds 	:= GetParameter("S031",cCvTpImss,11)  
					aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)	
					oPila2:SetField("39",IIF(Len(aMovPer)>0,aMovPer[1,1],0))

					aMovPer	:= fgetMovPer("",aMat,"0318",aPeriodos) 
					oPila2:SetField("40",IIF(Len(aMovPer)>0,aMovPer[1,2],0))
					
					//Campo 41
					cFldTpSal	:= AllTrim((QSRA)->RA_TIPOSAL)
					cFldRemVar	:= AllTrim((QSRA)->RA_REMVAR)
					cFldTipCot	:= AllTrim((QSRA)->RA_TIPCOT)
					
					Do Case
						Case cFldTpSal $ "2|4" //Salarios Integrales
							cTPSal := "X"
						Case cFldRemVar == "1" .Or. cFldTpSal == "3"//Con Remuneracion Variable
							cTPSal := "V"
						Case cFldTpSal == '1' .And. !(cFldTipCot $ "12|19|20") //Sueldo Fijo y No Aprendices
							cTPSal := "F"
						OtherWise
							cTPSal := " "
					EndCase	
					oPila2:SetField("41",cTPSal)
					
					cIds 	:= GetParameter("S031",cCvTpImss,17)  	
					aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)	
					oPila2:SetField("42",IIF(Len(aMovPer)>0,aMovPer[1,2],0))

					cIds 	:= GetParameter("S031",cCvTpImss,16)  	
					aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)	
					oPila2:SetField("43",IIF(Len(aMovPer)>0,aMovPer[1,2],0))

					cIds 	:= GetParameter("S031",cCvTpImss,18)  
					aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)
					oPila2:SetField("44",IIF(Len(aMovPer)>0,aMovPer[1,2],0))
						
					cIds 	:= GetParameter("S031",cCvTpImss,19)  
					aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)
					nConCol45:= IIF(Len(aMovPer)>0,aMovPer[1,2],0)
					oPila2:SetField("45",nConCol45)
										
					cIds 	:= GetParameter("S031",cCvTpImss,17)  //IBC AFP
					aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)	
					nCotAFP	:= IIF(Len(aMovPer)>0,aMovPer[1,1],0)/100 // Horas
					oPila2:SetField("46",nCotAFP)	
					
					cIds:= GetParameter("S031",cCvTpImss,7)  
					aMovPer:= fgetMovPer("",aMat,cIds,aPeriodos)				
					oPila2:SetField("47",IIF(Len(aMovPer)>0,aMovPer[1,2],0))	
					nTotCol50 := IIF(Len(aMovPer)>0,aMovPer[1,2],0)	
					
					oPila2:SetField("48",0)
					oPila2:SetField("49",0)
					//nTotCol50 += IIF(Len(aMovPer)>0,aMovPer[1,2],0) // duplica Col47! Reactivar si lee nuevo Id Cálculo/movimientos Cols 48/49 
					oPila2:SetField("50",nTotCol50)	
					
					cIds 	:= GetParameter("S031",cCvTpImss,8)  	
					aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)
					oPila2:SetField("51",IIF(Len(aMovPer)>0,aMovPer[1,2],0))
						
					cIds 	:= GetParameter("S031",cCvTpImss,9)  
					aMovPer	:= fgetMovPer(cEntAFP,aMat,cIds,aPeriodos)	
					oPila2:SetField("52",IIF(Len(aMovPer)>0,aMovPer[1,2],0))			
					oPila2:SetField("53",0)	

					cIds 		:= GetParameter("S031",cCvTpImss,16)  // IBC EPS
					aMovPer		:= fgetMovPer("",aMat,cIds,aPeriodos)	
					nCotSalud 	:= IIF(Len(aMovPer)>0,aMovPer[1,1],0)/100 // Horas
					oPila2:SetField("54",nCotSalud)					

					cIds 	:= GetParameter("S031",cCvTpImss,6) //AUSENTISMOS	
					aMovPer	:= fgetMovPer(cEntEPS,aMat,cIds,aPeriodos)
					oPila2:SetField("55",IIF(Len(aMovPer)>0,aMovPer[1,2],0))					
					oPila2:SetField("56",0)					
					cIds 	:= GetParameter("S031",cCvTpImss,18)  // IBC ARL
					aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)	
					oPila2:SetField("61",IIF(Len(aMovPer)>0,aMovPer[1,1]/10000,0)) // hORAS					
					oPila2:SetField("62",StrZero(val((QSRA)->RA_KEYLOC),9))
					
					cIds 	:= GetParameter("S031",cCvTpImss,10) 
					aMovPer	:= fgetMovPer(cEntARL,aMat,cIds,aPeriodos)
					oPila2:SetField("63",IIF(Len(aMovPer)>0,aMovPer[1,2],0))

					cIds 	:= GetParameter("S031",cCvTpImss,19)  // IBC PARAFISCALES	
					aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)	
					oPila2:SetField("64",IIF(Len(aMovPer)>0,aMovPer[1,1]/100,0)) // hORAS
	
					cIds 		:= GetParameter("S031",cCvTpImss,11)  
					aMovPer:= fgetMovPer(cEntCCF,aMat,cIds,aPeriodos)					
					oPila2:SetField("65",IIF(Len(aMovPer)>0,aMovPer[1,2],""))
		
					/*cIds 		:= GetParameter("S031",cCvTpImss,14)  // ID ESAP	
					aMovPer		:= fgetMovPer("",aMat,cIds,aPeriodos)	
					oPila2:SetField("66",IIF(Len(aMovPer)>0,aMovPer[1,1]/100,0)) // hORAS*/
		
					cIds 		:= GetParameter("S031",cCvTpImss,13)  //Ausentismos
					aMovPer:= fgetMovPer("",aMat,cIds,aPeriodos)					
					oPila2:SetField("67",aMovPer[1,2])	

					/*cIds 		:= GetParameter("S031",cCvTpImss,15)  // ID MEN
					aMovPer		:= fgetMovPer("",aMat,cIds,aPeriodos)	
					oPila2:SetField("68",IIF(Len(aMovPer)>0,aMovPer[1,1]/100,0)) // hORAS	*/						
																	
					cIds 		:= GetParameter("S031",cCvTpImss,12) 
					aMovPer:= fgetMovPer("",aMat,cIds,aPeriodos)					
					oPila2:SetField("69",IIF(Len(aMovPer)>0,aMovPer[1,2],0))	
										
					oPila2:SetField("70",0)
					oPila2:SetField("71",0)
					oPila2:SetField("72",0)
					oPila2:SetField("73",0)
					oPila2:SetField("3A",Space(2))
					oPila2:SetField("4A",Space(16))
					
					If (QSRA)->RA_TIPCOT $ "19|20|12|"
						oPila2:SetField("74", "N") // 76
						oPila2:SetField("66",0) // hORAS
						oPila2:SetField("68",0) // hORAS
					Else
						cIds 	:= '0542'  
						aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)
						cIds := IIF(FTABELA("S007",1,6) *10 > aMovPer[1,2],"S","N")
						oPila2:SetField("74",cIds)	
						If cIds $ "S"
							oPila2:SetField("66",0) // hORAS
							oPila2:SetField("68",0) // hORAS
						Else
							cIds 		:= GetParameter("S031",cCvTpImss,14)  // ID IBC SENA	
							aMovPer		:= fgetMovPer("",aMat,cIds,aPeriodos)	
							oPila2:SetField("66",IIF(Len(aMovPer)>0,aMovPer[1,1]/100,0)) // hORAS
							
							cIds 		:= GetParameter("S031",cCvTpImss,15)  // ID MEN
							aMovPer		:= fgetMovPer("",aMat,cIds,aPeriodos)	
							oPila2:SetField("68",IIF(Len(aMovPer)>0,aMovPer[1,1]/100,0)) // hORAS
						EndIf		
					EndIf		
				   	cIds 		:= GetParameter("S031",cCvTpImss,10)  
					aMovEnt     := fgetMovUPS("",aMat,cIds,aPeriodos,,)
				
					nLin       := IIF ( Len(aMovEnt) > 0,FPOSTAB("S008",aMovEnt[1,3],"=",4,"ARL ","=",6),0)
					cCodPila 	:= IIF(nLin <> 0,SubStr(FTABELA("S008",nLin,7),1,6),"      ")
					
					oPila2:SetField("75",cCodPila)
					
					cConCol78 := " "
					cConCol78 := POSICIONE("RGC",1,XFILIAL("RGC") + (QSRA)->RA_KEYLOC,"RGC_TIPARL")
					
					IF AllTrim(cConCol78) == "I"
						cConCol78 := "1"
					ElseIF AllTrim(cConCol78) == "II"
						cConCol78 := "2"
					ElseIF AllTrim(cConCol78) == "III"
						cConCol78 := "3"
					ElseIF AllTrim(cConCol78) == "IV"
						cConCol78 := "4"
					ElseIF AllTrim(cConCol78) == "V"
						cConCol78 := "5"
					endIF
					
					oPila2:SetField("76",cConCol78)					
					oPila2:SetField("77",(QSRA)->RA_PORAFP) // 79
					oPila2:SetField("78",Space(10)) // 80 
					oPila2:SetField("79",Space(10)) // 81
					oPila2:SetField("80",Space(10)) // 82
					
					If !Empty(cConCol24)
						cDatCol24A  := DTOC(dDatCo24A)
						cDatCol24B  := DTOC(dDatCo24B)
						oPila2:SetField("81",DateToStr(dDatCo24A, "YYYY-MM-DD")) // 83
						oPila2:SetField("82",DateToStr(dDatCo24B, "YYYY-MM-DD")) // 84
					Else
						oPila2:SetField("81",Space(10)) // 83
						oPila2:SetField("82",Space(10)) // 84
					EndIF
					
					If !Empty(cConCol25)
						cDatCol25A  := DTOC(dDatCo25A)
						cDatCol25B  := DTOC(dDatCo25B)
						oPila2:SetField("83",DateToStr(dDatCo25A, "YYYY-MM-DD")) // 85
						oPila2:SetField("84",DateToStr(dDatCo25B, "YYYY-MM-DD")) // 86
					Else
					oPila2:SetField("83",Space(10)) // 85
					oPila2:SetField("84",Space(10)) // 86
					EndIF

					If !Empty(cConCol26)
					cDatCol26A  := DTOC(dDatCo26A)
					cDatCol26B  := DTOC(dDatCo26B)
					oPila2:SetField("85",DateToStr(dDatCo26A, "YYYY-MM-DD")) // 87
					oPila2:SetField("86",DateToStr(dDatCo26B, "YYYY-MM-DD")) // 88
					Else
					oPila2:SetField("85",Space(10)) // 87
					oPila2:SetField("86",Space(10)) // 88
					EndIF

					If !Empty(cConCol27)
						cDatCol27A  := DTOC(dDatCo27A)
						cDatCol27B  := DTOC(dDatCo27B)
						oPila2:SetField("87",DateToStr(dDatCo27A, "YYYY-MM-DD")) // 89
						oPila2:SetField("88",DateToStr(dDatCo27B, "YYYY-MM-DD")) // 90
					Else
						oPila2:SetField("87",Space(10)) // 89
						oPila2:SetField("88",Space(10)) // 90
					EndIf
															
					oPila2:SetField("89",Space(10)) // 91
					oPila2:SetField("90",Space(10)) // 92

					If !Empty(cConCol30)
						cDatCol30A  := DTOC(dDatCo30A)
						cDatCol30B  := DTOC(dDatCo30B)
						oPila2:SetField("91",DateToStr(dDatCo30A, "YYYY-MM-DD")) // 93
						oPila2:SetField("92",DateToStr(dDatCo30B, "YYYY-MM-DD")) // 94
					Else
						oPila2:SetField("91",Space(10)) // 93
						oPila2:SetField("92",Space(10)) // 94
					EndIf

					oPila2:SetField("93",nConCol45) // 95
					
					aMovPer := fgetMovPer("",aMat,"0638",aPeriodos,,)					
					oPila2:SetField("94",0) // Solo se informa en sueldos y salarios
					oPila2:SetField("95",IIF(!EMPTY((QSRA)->RA_FCHEXT),DateToStr(STOD((QSRA)->RA_FCHEXT), "YYYY-MM-DD"),Space(10))) // Solo se informa en sueldos y salarios
					oPila2:SaveRecord()
				Next nI
				lSS := nDiasAus < 30
					
				//////////////Movimientos de UPS Adicional
				
				//Estructura array aMovUPS en el periodo
				//+------------------+ 
				//| 1.-Filial        |
				//| 2.-Matricula     |
				//| 3.-Tipo Afa		 |
				//| 4.-Num ID		 |
				//| 5.-fecha inicio	 |
				//| 6.-Fecha Fin	 |
				//| 7.-EPS			 |
				//| 8.-AFP			 |
				//| 9.-tp imss		 |
				//|10.-No. autoriza	 |
				//|11.-Concepto		 |
				//+------------------+
				
				aMovUPS := fgetMovUPS("",aMat,"1246",aPeriodos,,)
				If  Len(aMovUPS) > 0 
				  	aRegUPS := getReUPS(aMat,"1246")
					For nI := 1 to Len(aRegUPS) 
	
						AADD(aNIT,(QSRA)->RA_CIC) 

						nCount++
						oPila2:AddRecord(2)
						oPila2:SetField( "1","02")
						oPila2:SetField( "2",StrZero(nCount, 5))
				 		oPila2:SetField( "3",aRegUPS[nI,1] )
				 		oPila2:SetField( "4",aRegUPS[nI,2])
						oPila2:SetField( "5","40")
				 		oPila2:SetField( "6",0)
				 		oPila2:SetField( "7",Space(30))
				 		oPila2:SetField( "8",Space(1))
				 		oPila2:SetField( "9","  ")
						oPila2:SetField("10",Space(3))	
						oPila2:SetField("11",aRegUPS[nI,3])
						oPila2:SetField("12",aRegUPS[nI,4])
						oPila2:SetField("13",aRegUPS[nI,5])
						oPila2:SetField("14",aRegUPS[nI,6])
						oPila2:SetField("15"," ")
						oPila2:SetField("16"," ")
						oPila2:SetField("17"," ")
						oPila2:SetField("18"," ")
						oPila2:SetField("19"," ")
						oPila2:SetField("20"," ")
						oPila2:SetField("21"," ")
						oPila2:SetField("22"," ")	
						oPila2:SetField("23"," ")
						oPila2:SetField("24"," ")						
						oPila2:SetField("25"," ")
						oPila2:SetField("26"," ")
						oPila2:SetField("27"," ")
						oPila2:SetField("28"," ")
						oPila2:SetField("29"," ")
						oPila2:SetField("30",0)	
						oPila2:SetField("31",Space(6))
						oPila2:SetField("32",Space(6))
						
						nLin := FPOSTAB('S008',cEntEPS,'=',4)
						cCodPila := IIF (nLin>0,fTabela('S008',nLin,7),"      ")

						oPila2:SetField("33",cCodPila)
						oPila2:SetField("34",Space(6))
						oPila2:SetField("35",Space(6))
						oPila2:SetField("36",0)
						oPila2:SetField("37",0)
						oPila2:SetField("38",0)
						oPila2:SetField("39",0)
						oPila2:SetField("40",0)
						oPila2:SetField("41",Space(1))		
						oPila2:SetField("42",0)
						oPila2:SetField("43",0)
						oPila2:SetField("44",0)
						oPila2:SetField("45",0)	
						oPila2:SetField("46",0)	
						oPila2:SetField("47",0)	
						oPila2:SetField("48",0)				
						oPila2:SetField("49",0)	
						oPila2:SetField("50",0)	
						oPila2:SetField("51",0)	
						oPila2:SetField("52",0)	
						oPila2:SetField("53",0)
						oPila2:SetField("54",0)	
						oPila2:SetField("55",0) // ups
						oPila2:SetField("56",aRegUPS[nI,7])																																								
						oPila2:SetField("57",Space(15))
						oPila2:SetField("58",0)		
						oPila2:SetField("59",Space(15))	
						oPila2:SetField("60",0)
						oPila2:SetField("61",0)	
						oPila2:SetField("62","")
						oPila2:SetField("63",0)
						oPila2:SetField("64",0)	
						oPila2:SetField("65","")	
						oPila2:SetField("66",0)		
						oPila2:SetField("67",0)	
						oPila2:SetField("68",0)	
						oPila2:SetField("69",0)	
						oPila2:SetField("70",0)	
						oPila2:SetField("71",0)
						oPila2:SetField("72",0)
						oPila2:SetField("73",0)
						oPila2:SetField("3A",(QSRA)->RA_TPCIC )
						oPila2:SetField("4A",(QSRA)->RA_CIC )
						oPila2:SetField("74", "N")											
						oPila2:SetField("75",Space(6)) // 77
						oPila2:SetField("76",Space(1)) // 78
						oPila2:SetField("77",Space(1)) // 79
						oPila2:SetField("78",Space(10)) // 80 
						oPila2:SetField("79",Space(10)) // 81
						oPila2:SetField("80",Space(10)) // 82
						oPila2:SetField("81",Space(10)) // 83
						oPila2:SetField("82",Space(10)) // 84
						oPila2:SetField("83",Space(10)) // 85
						oPila2:SetField("84",Space(10)) // 86
						oPila2:SetField("85",Space(10)) // 87
						oPila2:SetField("86",Space(10)) // 88
						oPila2:SetField("87",Space(10)) // 89
						oPila2:SetField("88",Space(10)) // 90
						oPila2:SetField("89",Space(10)) // 91
						oPila2:SetField("90",Space(10)) // 92
						oPila2:SetField("91",Space(10)) // 93
						oPila2:SetField("92",Space(10)) // 94					
						oPila2:SetField("93",nConCol45) // 95
					
						aMovPer := fgetMovPer("",aMat,"0638",aPeriodos,,)
						oPila2:SetField("94",0) //96 - Solo se informa en sueldos y salarios	
						oPila2:SetField("95",IIF(!EMPTY((QSRA)->RA_FCHEXT),DateToStr(STOD((QSRA)->RA_FCHEXT), "YYYY-MM-DD"),Space(10))) // Solo se informa en sueldos y salarios																						
						oPila2:SaveRecord()
					next nI
				EndIF
				
				///////////////////////////////////////	
				// SUELDOS Y SALARIOS Fusionado con Trayectoria Laboral
			 	If lSS			
					cEntEPS := (QSRA)->RA_CODRPAT
					cEntAFP := (QSRA)->RA_CODAFP
					cEntARL := (QSRA)->RA_NITARL
					cEntCCF := (QSRA)->RA_CXCOMP
									
					//---- TRAYECTORIA LABORAL
					// Si no ausentismos, ni UPS, genera un registro normal
					// pero considera los movimientos que pudiera generar trayectoria laboral
					// y los reporta en el mismo registro de sueldos y salarios	
					aMovRCP := getMovRCP((QSRA)->RA_RG,aStruRCP,aMat)					
					nCount++
					aRG1	:= getRegRG1(aMat,cEntAFP,.F.)
					lPension:= (QSRA)->RA_PGAPORT $ '1'
					oPila2:AddRecord(2)
					oPila2:SetField( "1","02")
					oPila2:SetField( "2",StrZero(nCount, 5))
			 		oPila2:SetField( "3",(QSRA)->RA_TPCIC )
			 		oPila2:SetField( "4",(QSRA)->RA_CIC)
					oPila2:SetField( "5",(QSRA)->RA_TIPCOT)
			 		oPila2:SetField( "6",(QSRA)->RA_SUBCOT )
			 		oPila2:SetField( "7",IIF(lPension ,'X',Space(1)) )
			 		oPila2:SetField( "8",IIF((QSRA)->RA_RESEXT $ '1' ,'X',Space(1))  )
			 		oPila2:SetField( "9", (QSRA)->RA_ESTADO )
					oPila2:SetField("10", SUBSTRING((QSRA)->RA_MUNICIP,3,3)) 
					oPila2:SetField("11",(QSRA)->RA_PRISOBR)
					oPila2:SetField("12",(QSRA)->RA_SECSOBR)
					oPila2:SetField("13",(QSRA)->RA_PRINOME)
					oPila2:SetField("14",(QSRA)->RA_SECNOME)
					
					// Busca movimiento de ingreso en el periodo en array aMovRCP
					nPosRCP := aScan(aMovRCP, {|x,y| x[nPosTpMov,2] == "01" })  // 01-INGRESOS
					If nPosRCP >0
						If 	AllTrim((QSRA)->RA_TIPCOT) <> "3"					
							oPila2:SetField("15","X")
							cConCol15 := "15"
						ElseIF AllTrim((QSRA)->RA_TIPCOT) == "3"
							nTotReg := FgetTOTPer("",aMat,"0883",aPeriodos) 
							If nTotReg > 0
								oPila2:SetField("15","R")
								cConCol15 := "15"
							Else
								nTotReg := FgetTOTPer("",aMat,"0876",aPeriodos) 
								If nTotReg > 0
									oPila2:SetField("15","C")
									cConCol15 := "15"
								Else
									oPila2:SetField("15"," ")
								EndIF
							EndIF
						EndIF	
					Else
						cConCol15 := ""
						oPila2:SetField("15"," ")
					EndIf
					nPosRCP := aScan(aMovRCP, {|x,y| x[nPosTpMov,2] == "02" })  // 02-RETIRO
					If nPosRCP > 0
						If 	AllTrim((QSRA)->RA_TIPCOT) <> "3"					
							oPila2:SetField("16","X")
							cConCol16 := "16"
						ElseIf AllTrim((QSRA)->RA_TIPCOT) == "3"
							nTotReg := FgetTOTPer("",aMat,"0883",aPeriodos) 								
							If nTotReg > 0
								oPila2:SetField("16","R")
								cConCol16 := "16"
							Else
								nTotReg := FgetTOTPer("",aMat,"0876",aPeriodos) 
								If nTotReg > 0
									oPila2:SetField("16","C")
									cConCol16 := "16"
								Else
									oPila2:SetField("16"," ")
									cConCol16:= "16"
								EndIF
							EndIF
						EndIF
						cDatCol16 := STOD(aMovRCP[nPosRCP,nPosDMo,2])
					Else
						cConCol16 := ""
						oPila2:SetField("16"," ")
					EndIf
					nPosRCP := aScan(aMovRCP, {|x,y| x[nPosTpMov,2] == "04" })  // 04-traslado desde otra eps
					If nPosRCP > 0
						oPila2:SetField("17","X")
					Else
						oPila2:SetField("17"," ")
					EndIf
					nPosRCP := aScan(aMovRCP, {|x,y| x[nPosTpMov,2] == "03" })  // 03-TRASLADO A OTRA EPS
					If nPosRCP > 0
						oPila2:SetField("18","X")
						cEntEPS 	:= aMovRCP[nPosRCP,nPosEPS,2]
						nLin 		:= FPOSTAB("S008",cEntEPS,"=",4,"EPS ","=", 6)
						nLin 		:= IIF(nLin <> 0 ,nLin,0)
						cCodPila 	:= IIF(nLin <> 0,SubStr(FTABELA("S008",nLin,7),1,6),"      ") // para extraer el código de la PILA.						
						oPila2:SetField("34",cCodPila)
					Else
						oPila2:SetField("18"," ")
						oPila2:SetField("34",Space(6))	
					EndIf
					nPosRCP := aScan(aMovRCP, {|x,y| x[nPosTpMov,2] == "08" })  // 08-TDP: TRASLADO DESDE OTRA AFP		
					If nPosRCP > 0
						oPila2:SetField("19","X")
					Else
						oPila2:SetField("19"," ")
					EndIf
					nPosRCP := aScan(aMovRCP, {|x,y| x[nPosTpMov,2] == "09" })  // 08-TDP: TRASLADO DESDE OTRA AFP		
					If nPosRCP > 0
						oPila2:SetField("20","X")
						cEntAFP		:= aMovRCP[nPosRCP,nPosAFP,2]
						nLin 		:= FPOSTAB("S008",cEntAFP,"=",4,"AFP ","=", 6)
						nLin 		:= IIF(nLin <> 0 ,nLin,1)
						cCodPila 	:= IIF(nLin <> 0 , SubStr(FTABELA("S008",nLin,7),1,6),"      ") // para extraer el código de la PILA.
						oPila2:SetField("32",cCodPila)
					Else
						oPila2:SetField("20"," ")
						oPila2:SetField("32","      ")
					EndIf
					nPosRCP := aScan(aMovRCP, {|x,y| x[nPosTpMov,2] == "05" })  // 05-VSP: VARIACION DE SALARIO PERMANENTE
					If nPosRCP > 0
						oPila2:SetField("21","X")	
						cConCol21 := "21"
						cDatCol21 := STOD(aMovRCP[nPosRCP,nPosDMo,2])
					Else						
						oPila2:SetField("21"," ")
					EndIf
					oPila2:SetField("22",Iif(cTipoPlan=="A","A", Iif(cTipoPlan $ "M/N/F/X","C"," ")))
					// Si existe un movimiento 05 no hay que poner una X en el campo 23
					If Empty(cConCol21)															
						nTotReg := FgetTOTPer("",aMat,"1552",aPeriodos)
						oPila2:SetField("23",IIF(nTotReg>0,"X"," "))
					Else
						oPila2:SetField("23",IIF(nTotReg>0,"X"," "))
					EndIf
					oPila2:SetField("24"," ")
					oPila2:SetField("25"," ")
					oPila2:SetField("26"," ")
					oPila2:SetField("27"," ")
					
					If alltrim((QSRA)->RA_CODAFP) <> '900336004-7'
						nTotReg := FgetTOTPer((QSRA)->RA_CODAFP,aMat,"1343;1344;1356;1548",aPeriodos)
						oPila2:SetField("28",IIF(nTotReg>0,"X"," "))
					Else
						oPila2:SetField("28"," ")
					EndIf
					// Busca VCT - Variación de Centro de Trabajo
					nPosRCP := aScan(aMovRCP, {|x,y| x[nPosTpMov,2] == "13" }) 	// 13-VCT: VARIACION CENTROS DE TRABAJO
					If 	nPosRCP
						oPila2:SetField("29","X")							
						cConCol29 := "29"
						cDatCol29 := STOD(aMovRCP[nPosRCP,nPosDMo,2])
					Else
						cConCol29:= ""				
						oPila2:SetField("29"," ")
					EndIf
					oPila2:SetField("30",0)
					
					If !lPension
						aMovEnt := fgetMovUPS("",aMat,"1239",aPeriodos,,)
						nLin      	:= IIF ( Len(aMovEnt) > 0,FPOSTAB("S008",aMovEnt[1,3],"=",4,"AFP ","=",6),0)
						nLin 	:= IIF(nLin <> 0 ,nLin,0)
						cCodPila:= IIF(nLin <> 0,SubStr(FTABELA("S008",nLin,7),1,6),"      ") // para extraer el código de la PILA.											
						oPila2:SetField("31",cCodPila)
					Else
						oPila2:SetField("31","      ")
					EndIf
											
					nLin := FPOSTAB("S008",(QSRA)->RA_CODRPAT/*aMovEnt[1,3]*/,"=",4,"EPS ","=",6)
					nLin 	:= IIF(nLin <> 0 ,nLin,0)
					cCodPila:= IIF(nLin <> 0,SubStr(FTABELA("S008",nLin,7),1,6),"      ") // para extraer el código de la PILA.
					oPila2:SetField("33",cCodPila)

					aMovEnt := fgetMovUPS("",aMat,"0876",aPeriodos,,)
					nLin 	:= IiF(len(aMovEnt)>0,FPOSTAB("S008",aMovEnt[1,3],"=",4,"CCF ","=",6),0)
					nLin 	:= IIF(nLin <> 0 ,nLin,0)
					cCodPila:= IIF(nLin <> 0,SubStr(FTABELA("S008",nLin,7),1,6),"      ") // para extraer el código de la PILA.				
					oPila2:SetField("35",cCodPila)
					cCvTpImss 	:= "S"
					If !lPension						
						cIds 		:= GetParameter("S031",cCvTpImss,7) 						
						If !Empty(cIds)								
							If AT(";", cIds) > 0
							    nId := 1
					 			cAux := cIds
					 			nPos := AT(";", cIds)
								While nPos > 0 .and.  nPos <= len(cIds)
					 				cIds := Substr(cAux,nId,nPos-1)
					 				aMovPer:= fgetMovPer("",aMat,cIds,aPeriodos)
					 				If Len(aMovPer) > 0
					 					If aMovPer[1,1] >0 .or. aMovPer[1,2]>0
					 				 		Exit
					 				 	EndIf
					 				EndIF
					 				
					 				nId := nPos + 1
					 				cAux := Substr(cAux,nId)
					 				nPos := AT(";", cAux)
					 				nId := 1
					 			EndDo 				 			
					 			If aMovPer == Nil .or. Len(aMovPer) == 0 .or. (aMovPer[1,1] == 0)
					 			 	aMovPer:= fgetMovPer("",aMat,cAux,aPeriodos)
					 			EndIF			 			
					 		EndIF	
	 				     EndIF
						oPila2:SetField("36",IIF(Len(aMovPer)>0,aMovPer[1,1],0))
					Else
						oPila2:SetField("36",0)	
					EndIf
					cIds 		:= GetParameter("S031",cCvTpImss,6) 
					If !Empty(cIds)								
						If AT(";", cIds) > 0
						    nId := 1
				 			cAux := cIds
				 			nPos := AT(";", cIds)
							While nPos > 0 .and.  nPos <= len(cIds)
				 				cIds := Substr(cAux,nId,nPos-1)
				 				aMovPer:= fgetMovPer("",aMat,cIds,aPeriodos)
				 				If Len(aMovPer) > 0
				 					If aMovPer[1,1] >0 
				 				 		Exit
				 				 	EndIf
				 				EndIF
				 				
				 				nId := nPos + 1
				 				cAux := Substr(cAux,nId)
				 				nPos := AT(";", cAux)
				 				nId := 1
				 			EndDo 				 			
				 			If aMovPer == Nil .or. Len(aMovPer) == 0 .or. (aMovPer[1,1] == 0)
				 			 	aMovPer:= fgetMovPer("",aMat,cAux,aPeriodos)
				 			EndIF				 			
				 		EndIF	
 				     EndIF
 				   	cCvTpImss := "S"  					
					oPila2:SetField("37",IIF(Len(aMovPer)>0,aMovPer[1,1],0))
					
					cIds 		:= GetParameter("S031",cCvTpImss,10)  
					aMovPer:= fgetMovPer("",aMat,cIds,aPeriodos)	
					oPila2:SetField("38",IIF(Len(aMovPer)>0,aMovPer[1,1],0))

					cIds 		:= GetParameter("S031",cCvTpImss,11)  	
					aMovPer:= fgetMovPer("",aMat,cIds,aPeriodos)	
					oPila2:SetField("39",IIF(Len(aMovPer)>0,aMovPer[1,1],0))

					aMovPer:= fgetMovPer("",aMat,"0318",aPeriodos) 	
					oPila2:SetField("40",IIF(Len(aMovPer)>0,aMovPer[1,2],0))
					
					//Campo 41
					cFldTpSal	:= AllTrim((QSRA)->RA_TIPOSAL)
					cFldRemVar	:= AllTrim((QSRA)->RA_REMVAR)
					cFldTipCot	:= AllTrim((QSRA)->RA_TIPCOT)
					
					Do Case
						Case cFldTpSal $ "2|4" //Salarios Integrales
							cTPSal := "X"
						Case cFldRemVar == "1" .Or. cFldTpSal == "3"//Con Remuneracion Variable
							cTPSal := "V"
						Case cFldTpSal == '1' .And. !(cFldTipCot $ "12|19|20") //Sueldo Fijo y No Aprendices
							cTPSal := "F"
						OtherWise
							cTPSal := " "
					EndCase	
					oPila2:SetField("41", cTPSal)
					
					If !lPension
						cIds 		:= GetParameter("S031",cCvTpImss,17)  
						aMovPer:= fgetMovPer("",aMat,cIds,aPeriodos)	
						oPila2:SetField("42",IIF(Len(aMovPer)>0,aMovPer[1,2],0))
					Else
						oPila2:SetField("42",0)
					EndIf	
					cIds 	:= GetParameter("S031",cCvTpImss,16)  	
					aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)	
					oPila2:SetField("43",IIF(Len(aMovPer)>0,aMovPer[1,2],0))

					cIds 	:= GetParameter("S031",cCvTpImss,18)  	
					aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)
					oPila2:SetField("44",IIF(Len(aMovPer)>0,aMovPer[1,2],0))
						
					cIds	:= GetParameter("S031",cCvTpImss,19)  
					aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)
					nConCol45 := IIF(Len(aMovPer)>0,aMovPer[1,2],0)
					oPila2:SetField("45",nConCol45)		
								
					If !lPension
						cIds	:= GetParameter("S031",cCvTpImss,17)  //IBC AFP
						aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)
						nCotAFP	:=IIF(Len(aMovPer)>0,aMovPer[1,1],0)/100 // Horas
						oPila2:SetField("46",nCotAFP)
						
						nTotCol50 := 0
						cIds	:= GetParameter("S031",cCvTpImss,7)  	
						aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)				
						oPila2:SetField("47",IIF(Len(aMovPer)>0,aMovPer[1,2],0))
							
						nTotCol50 += IIF(Len(aMovPer)>0,aMovPer[1,2],0)
						
						If alltrim((QSRA)->RA_CODAFP) <> '900336004-7'
							aMovPer:= fgetMovPer((QSRA)->RA_CODAFP,aMat,"1548",aPeriodos)	
							If Len(aMovPer)>0
								If aMovPer[1,2] == 0
									aMovPer:= fgetMovPer((QSRA)->RA_CODAFP,aMat,"1343",aPeriodos)
									If Len(aMovPer)>0
										If aMovPer[1,2] == 0
											aMovPer:= fgetMovPer((QSRA)->RA_CODAFP,aMat,"1344",aPeriodos)
										EndIF
									EndIF					
								endIF	
							Endif
							
							oPila2:SetField("48",IIF(Len(aMovPer)>0,aMovPer[1,2],0))	
							nTotCol50 += IIF(Len(aMovPer)>0,aMovPer[1,2],0)	
							
							aMovPer:= fgetMovPer((QSRA)->RA_CODAFP,aMat,"1356",aPeriodos)	
							oPila2:SetField("49",IIF(Len(aMovPer)>0,aMovPer[1,2],0))
							nTotCol50 += IIF(Len(aMovPer)>0,aMovPer[1,2],0)			
						Else
							oPila2:SetField("48",0)	
							oPila2:SetField("49",0)
							nTotCol50 += 0
						EndIf
												
						oPila2:SetField("50",nTotCol50)
						
						cIds 		:= GetParameter("S031",cCvTpImss,8)
						aMovPer:= fgetMovPer("",aMat,cIds,aPeriodos)
						oPila2:SetField("51",IIF(Len(aMovPer)>0,aMovPer[1,2],0))		
						cIds 		:= GetParameter("S031",cCvTpImss,9)
						aMovPer:= fgetMovPer("",aMat,cIds,aPeriodos)
						oPila2:SetField("52",IIF(Len(aMovPer)>0,aMovPer[1,2],0))	
						
						aMovPer:= fgetMovPer(cEntAFP,aMat,"1346",aPeriodos) 
						oPila2:SetField("53",IIF(Len(aMovPer)>0,aMovPer[1,2],0))

					Else
						oPila2:SetField("46",0)
						oPila2:SetField("47",0)
						oPila2:SetField("48",0)
						oPila2:SetField("49",0)
						oPila2:SetField("50",0)
						oPila2:SetField("51",0)
						oPila2:SetField("52",0)
						oPila2:SetField("53",0)
					EndIf

					cIds 		:= GetParameter("S031",cCvTpImss,16)  // IBC EPS
					aMovPer		:= fgetMovPer("",aMat,cIds,aPeriodos)	
					nCotSalud 	:= IIF(Len(aMovPer)>0,aMovPer[1,1],0)/100 // Horas
					oPila2:SetField("54",nCotSalud)	
					
					cIds 	:= GetParameter("S031",cCvTpImss,6) 		
					aMovPer	:= fgetMovPer(cEntEPS,aMat,cIds,aPeriodos)
					oPila2:SetField("55",IIF(Len(aMovPer)>0,aMovPer[1,2],0))
					oPila2:SetField("56",0)		// Debe ser 0 en sueldos y salarios								
					oPila2:SetField("57",Space(15))
					oPila2:SetField("58",0)		
					oPila2:SetField("59",Space(15))	
					oPila2:SetField("60",0)

					cIds 		:= GetParameter("S031",cCvTpImss,18)  // IBC ARL
					aMovPer		:= fgetMovPer("",aMat,cIds,aPeriodos)	
					oPila2:SetField("61",IIF(Len(aMovPer)>0,aMovPer[1,1]/10000," ")) // hORAS
					
					oPila2:SetField("62",STRZERO(Val((QSRA)->RA_KEYLOC),9))
					
					aMovPer:= fgetMovPer(cEntARL,aMat,"0883",aPeriodos)
					oPila2:SetField("63",IIF(Len(aMovPer)>0,aMovPer[1,2],0))
					
					cIds 		:= GetParameter("S031",cCvTpImss,19)  // IBC PARAFISCALES	
					aMovPer		:= fgetMovPer("",aMat,cIds,aPeriodos)	
					oPila2:SetField("64",IIF(Len(aMovPer)>0,aMovPer[1,1]/100,0)) // hORAS
					
					cIds 		:= GetParameter("S031",cCvTpImss,11)  
					aMovPer		:= fgetMovPer(cEntCCF,aMat,cIds,aPeriodos)										
					oPila2:SetField("65",IIF(Len(aMovPer)>0,aMovPer[1,2],""))	
					
					
					cIds 	:= GetParameter("S031",cCvTpImss,13)  // normal
					aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)					
					oPila2:SetField("67",aMovPer[1,2])
					
							
					cIds 		:= GetParameter("S031",cCvTpImss,12)  
					aMovPer:= fgetMovPer("",aMat,cIds,aPeriodos)					
					oPila2:SetField("69",aMovPer[1,2])
					
					oPila2:SetField("70",0)
					oPila2:SetField("71",0)
					oPila2:SetField("72",0)
					oPila2:SetField("73",0)

					oPila2:SetField("3A",Space(2)) // 74
					oPila2:SetField("4A",Space(16))// 75

					If (QSRA)->RA_TIPCOT $ "19|20|12|"
						oPila2:SetField("74", "N") // 76
						oPila2:SetField("66",0) // hORAS
							oPila2:SetField("68",0) // hORAS
					Else
						cIds 	:= '0542'  
						aMovPer	:= fgetMovPer("",aMat,cIds,aPeriodos)
						cIds := IIF(FTABELA("S007",1,6) *10 > aMovPer[1,2],"S","N")
						oPila2:SetField("74",cIds)	
						If cIds $ "S"
							oPila2:SetField("66",0) // hORAS
							oPila2:SetField("68",0) // hORAS
						Else
							cIds 		:= GetParameter("S031",cCvTpImss,14)  // ID IBC SENA	
							aMovPer		:= fgetMovPer("",aMat,cIds,aPeriodos)	
							oPila2:SetField("66",IIF(Len(aMovPer)>0,aMovPer[1,1]/100,0)) // hORAS
							
							cIds 		:= GetParameter("S031",cCvTpImss,15)  // ID MEN
							aMovPer		:= fgetMovPer("",aMat,cIds,aPeriodos)	
							oPila2:SetField("68",IIF(Len(aMovPer)>0,aMovPer[1,1]/100,0)) // hORAS
						EndIf		
					EndIf						
					//NORMAL
					cIds 		:= GetParameter("S031",cCvTpImss,10)  
					aMovEnt     := fgetMovUPS("",aMat,cIds,aPeriodos,,)
					nLin       := IIF ( Len(aMovEnt) > 0,FPOSTAB("S008",aMovEnt[1,3],"=",4,"ARL ","=",6),0)
					cCodPila 	:= IIF(nLin <> 0,SubStr(FTABELA("S008",nLin,7),1,6),"      ")
					oPila2:SetField("75",cCodPila) // 77
					

					cConCol78 := " "
					cConCol78 := POSICIONE("RGC",1,XFILIAL("RGC") + (QSRA)->RA_KEYLOC,"RGC_TIPARL")
					
					IF AllTrim(cConCol78) == "I"
						cConCol78 := "1"
					ElseIF AllTrim(cConCol78) == "II"
						cConCol78 := "2"
					ElseIF AllTrim(cConCol78) == "III"
						cConCol78 := "3"
					ElseIF AllTrim(cConCol78) == "IV"
						cConCol78 := "4"
					ElseIF AllTrim(cConCol78) == "V"
						cConCol78 := "5"
					endIF
					
					oPila2:SetField("76",cConCol78)//78					
					oPila2:SetField("77",(QSRA)->RA_PORAFP) // 79
					oPila2:SetField("78",IIf(Empty(AllTrim(cConCol15)),Space(10),DateToStr(cAdmiss, "YYYY-MM-DD")))  	// 80					
					oPila2:SetField("79",IIf(Empty(AllTrim(cConCol16)),Space(10),DateToStr(cDatCol16, "YYYY-MM-DD")))	// 81
					oPila2:SetField("80",IIf(Empty(AllTrim(cConCol21)),Space(10),DateToStr(cDatCol21, "YYYY-MM-DD"))) 	// 82
					oPila2:SetField("81",Space(10)) // 83
					oPila2:SetField("82",Space(10)) // 84
					oPila2:SetField("83",Space(10)) // 85
					oPila2:SetField("84",Space(10)) // 86
					oPila2:SetField("85",Space(10)) // 87
					oPila2:SetField("86",Space(10)) // 88
					oPila2:SetField("87",Space(10)) // 89
					oPila2:SetField("88",Space(10)) // 90
					oPila2:SetField("89",IIf(Empty(AllTrim(cConCol29)),Space(10),DateToStr(cDatCol29, "YYYY-MM-DD")))	// 91			
					oPila2:SetField("90",Space(10)) // 92
					oPila2:SetField("91",Space(10)) // 93
					oPila2:SetField("92",Space(10)) // 94
					oPila2:SetField("93",nConCol45) // 95
					
					aMovPer := fgetMovPer("",aMat,"0638",aPeriodos,,)
					oPila2:SetField("94",IIF(Len(aMovPer)>0,aMovPer[1,1],0)) // 96
					oPila2:SetField("95",IIF(!EMPTY((QSRA)->RA_FCHEXT),DateToStr(STOD((QSRA)->RA_FCHEXT), "YYYY-MM-DD"),Space(10))) // Solo se informa en sueldos y salarios					
					oPila2:SaveRecord()	
				EndIF
			End If
			
		End If
		nDiasAus := 0
		
		(QSRA)->(DBSkip())
	EndDo	
		
	IF nTipoArq == 2
		oPila2:GenExcel(cFile3)
		MsgInfo(STR0016, STR0017)
	Else
		IF oPila2:WriteFile(Iif( !Empty(cFile02),cFile02,cFile01 ))
			
			MsgInfo(STR0016, STR0017)// "Arquivos gerados com sucesso!" , "Informacao"
		Else
			MsgInfo(STR0161, STR0017)// Error al generar archivos, verifique por favor.
		End If
	End IF
	RestArea(aArea)
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ getParameter     ³ mayra.camargo      º Data ³  31/12/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene los parámetros de las tablas alfanuméricas.        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ GetParameter(cTab,cFilTab, nPosCol)                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³  cTab   := Código de la tabla alfanumérica                 º±±
±±º          ³  cFilTab:= Filial que se esta buscando                     º±±
±±º          ³  nPosCol:= Campo buscado                                   º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPE                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetParameter(cTab,cFilTab, nPosCol,lTotal)
	Local nLin 	:= 0
	Local cReturn := ""
	Local aArea := getArea()
	Local nX := 0
	Local cAux := ""
	
	Default lTotal := .F.
	cFilTab := iif(VALType(cFilTab) == "N",AllTrim(STR(cFilTab)),cFilTab)
	
	If !lTotal
		For nX := 1 to Len(cFilTab) 
			dbselectarea("RCC")
			RCC->(DBGOTOP())
			
			IF cTab $ "S031"
				nLin 	:= fPostab(cTab,Substr(cFilTab,nX),"=",4)
			Else
				nLin 	:= fPostab(cTab,Substr(cFilTab,nX),"=",1)
			EndIF
	
			nLin 	:= IIF(nLin == 0 .or. nLin == NIL, 1, nLin)
			IF !Empty(AllTrim(fTabela(cTab, nLin, nPosCol)))
			cReturn += AllTrim(fTabela(cTab, nLin, nPosCol)) + ";"
			EndIF
		Next nX
	Else
		For nLin:= 1 to 20	
				
			cAux := AllTrim(fTabela(cTab, nLin, nPosCol))
			If !Empty(cAux)
				cReturn += cAux + ";" 
			EndIf
		Next nX
	
	EndIf			
	RestArea(aArea)
Return cReturn

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³          ³Autor³Rogerio Ribeiro            ³Data³11/03/2009³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³GPER880			                    	   					³
³
³	U se tiver menos de 20 filiais ou não tenha filiais em mais de 5 cidades. 
³	C se tiver mais de 20 filiais ou tenha filiais em mais de 5 cidades. 
³	S se selecionar apenas uma filial na pergunte filial de ate. 
³	D depende da natureza juridica == 1,3,4 ou 5
³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function GetPresentationForm(nOpc)
	Local cReturn

	Do Case
		Case nOpc == 1
			cReturn := "U"
		Case nOpc == 2
			cReturn := "S"
	EndCase

Return cReturn

/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³          ³Autor³Rogerio Ribeiro            ³Data³11/03/2009³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide Parametros Formais>									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³GPER880			                    	   					³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function fTipoPlanilha()
	Local cVarRet := Alltrim(ReadVar())
	Local cReturn := &(cVarRet)
	Local aOpcoes := {	"E - " + STR0018,;	//"Funcionários Empresas"
							"Y - " + STR0019,;	//"Autônomos Empresas"
							"A - " + STR0020,;	//"Funcionários Adicionais"
							"I - " + STR0021,;	//"Autônomos"
							"S - " + STR0022,;	//"Funcionários de Autônomos"
							"M - " + STR0023,;	//"Mora"
							"N - " + STR0024;	//"Correções"
					 }  	
					    
			
	IF f_Opcoes(@cReturn, STR0025, aOpcoes, "EYAISMN", 12, 49, .T.)  // Chama funcao f_Opcoes
		&(cVarRet) := cReturn										 // Devolve Resultado
	EndIF
Return cReturn

Static Function DateToStr(dDate, cFormat)
	Local cReturn

	If cFormat == "YYYY-MM"
		cReturn := Year2Str(dDate) +"-"+ Month2Str(dDate)
	Elseif cFormat == "YYYYMM"
		cReturn := Year2Str(dDate) + Month2Str(dDate)
	Else
		cReturn := Year2Str(dDate) +"-"+ Month2Str(dDate) +"-"+ Day2Str(dDate)
	EndIf
Return cReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER880   ºAutor  ³ Equipe RH Inovacao º Data ³  22/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao de arquivo magnetico - PILA                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Microsiga Protheus 11                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fBaseICB()

	Local aArea := GetArea()
	Local nRet 		:= 0
	Local cAliasQry 	:= GetNextAlias()
	Local cIds := GetParameter("S031","", 19,.t.)
	Local aAux := StrToKArr(cIds, ";")
	Local cPdAux := ""
	Local cPDSRD		:= ""//fGetCodfol("0876") //fGetCodfol("0875")
	Local cFilSrc		:= ""
	Local cPeriodo 	:= DateToStr(CTOD("01/" + MV_PAR04),"YYYYMM")
	Local nI:= 0
	Local cEmp		:= IIF(!Empty(cMats),"% AND SRC." + RANGESX1("RC_MAT",cMats) +  " %", "%%")
	Local cEmp1		:= IIF(!Empty(cMats),"% AND SRD." + RANGESX1("RD_MAT",cMats) +  " %", "%%")
	
	// Se obtienen los conceptos asociados a los identificadores de cálculo
	If len(aAux) > 0
		cPDSRD := "% ("
	EndIF

	For nI:= 1 to len(aAux)		
		cPdAux := "'" + aAux[nI] +  IIF(nI < len(aAux),"',", "')%")
		cPDSRD += cPdAux 
	Next nI
	
	cFilSrc := RANGESX1("RC_FILIAL", cFilSuc)
	cFilSrc := iif(Empty(cFilSuc),"% SRC.RC_FILIAL='" + xFilial("SRC") +"' %","% SRC." + cFilSrc+ " %")
	
	cFilSrd := RANGESX1("RD_FILIAL", cFilSuc)
	cFilSrd := iif(Empty(cFilSuc),"% SRD.RD_FILIAL='" + xFilial("SRD") +"' %","% SRD." + cFilSrd+ " %")

	cFieldSrc := "% SUM(RC_VALOR) ID0876 %"  
	cFiltroSrc := 	"% SRC." + RANGESX1("RC_PROCES", cProcesso)
	cFiltroSrc += " AND SRC." + RANGESX1("RC_ROTEIR", cProcedim) + " %" 

	cFieldSrd := "% SUM(RD_VALOR) ID0876 %"  
	cFiltroSrd := 	"% SRD." + RANGESX1("RD_PROCES", cProcesso)
	cFiltroSrd += " AND SRD." + RANGESX1("RD_ROTEIR", cProcedim) + " %" 
		
	BeginSql alias cAliasQry

	SELECT SUM(ID0876) AS ID0876
		FROM (	
		
		SELECT %exp:cFieldSrd%
		FROM %table:SRD% SRD  
		INNER JOIN  %table:SRV% SRV 
		ON 	    SRD.RD_PD = SRV.RV_COD 	
		WHERE  %exp:cFilSrd% AND
		  		%exp:cFiltroSrd%  AND
		   		SRD.RD_PERIODO =   %exp:Upper(cPeriodo)%   AND   
		   		SRV.RV_CODFOL IN %exp:Upper(cPDSRD)%
		  AND SRV.RV_FILIAL = %exp:xfilial('SRV')% 	
		  AND SRD.%notDel%
		  AND SRV.%notDel% %exp:cEmp1%
		  GROUP BY SRD.RD_FILIAL,RD_PD
		UNION
		SELECT %exp:cFieldSrc%
		FROM %table:SRC% SRC  
		INNER JOIN  %table:SRV% SRV 
		ON 	    SRC.RC_PD = SRV.RV_COD 	
		WHERE  %exp:cFilSrc% AND
		  		%exp:cFiltroSrc%  AND
		   		SRC.RC_PERIODO =   %exp:Upper(cPeriodo)%   AND   
		   		SRV.RV_CODFOL IN %exp:Upper(cPDSRD)% 
		  AND SRV.RV_FILIAL = %exp:xfilial('SRV')%
		  AND SRC.%notDel%
		  AND SRV.%notDel% %exp:cEmp%
		  GROUP BY SRC.RC_FILIAL,RC_PD
	) V	  
	EndSql
	
	While (cAliasQry)->(!Eof())	
	
		nRet += (cAliasQry)->(ID0876)
		
		(cAliasQry)->(dbskip())
	EndDo
	(cAliasqry)->(dbCloseArea())
	RestArea(aArea)
Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGetcodPilºAutor  ³mayra.camargo       º Data ³ 31/12/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene el código de la pila de la tabla S008 según el nit º±±
±±º          ³ de la entidad.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPE                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FgetCodPila()

	Local cNitARL	:= "" //getParameter("S012",MV_PAR01,5) 
	Local V_NITARL	:= "" //SubStr(fTabela('S012',NAUX01,5),1,16)
	Local NAUX01	:= FPOSTAB('S010', MV_PAR01, '=', 1) 
	
	IF NAUX01 == 0
		NAUX01 := 1
	EndIF

	V_NITARL := SubStr(fTabela('S012',NAUX01,5),1,17)
	NAUX04 := FPOSTAB('S008',V_NITARL,'=',4)
	cNitARL := IIF(NAUX04>0,fTabela('S008',NAUX04,7),'      ')
	
Return cNitARL
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³getMovRCP ºAutor  |mayra.camargo       º Data ³  31/12/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene los movimientos de tray. laboral según el          º±±
±±º          ³ periodo para el empleado en cuestion                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ getMovRCP(cNIT,aHeader,aMat)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cNIT := NIT  de la entidad a buscar                         º±±
±±º          ³aHeader := Array con lso campos de la RCP                   º±±
±±º          ³aMat := Matriculas a buscar ya que el empleado puede estar  º±±
±±º          ³ en una o más sucursales                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ gpe                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function getMovRCP(cNIT,aHeader,aMat)
	Local aDados 	:= {}
	Local aArea		:= GetArea()
	Local cFields	:= ""
	Local cAliasRCP	:= GetNextAlias()
	Local cRCPTab	:= '%'+RetSqlName('RCP')+'%'
	Local nFields	:= 0
	Local aTray		:= {}
	Local cMats		:= "%("
	Local cFils		:= "%("
	lOCAL Ni 		:= 0
	
	DEFAULT cNIT	:= (QSRA)->RA_RG
	DEFAULT aHeader	:= {}
	
	//- Carregar somente os itens gerados pelo select
	cFields :=  "%" 
	
	For nI := 1 to len(aMat)
		cMats += "'" + aMat[nI,2] + "'"
		cFils += "'" + aMat[nI,1] + "'"
		If nI < len(aMat)
			cMats += ","
			cFils += ","
		Else 
			cMats+= ")%"
			cFils+= ")%"
		End If
	Next nI		
	
	For nFields := 1 to len(aHeader)
				
		//If Ascan(aVirtual,{|x| x = aHeader[nFields,2]}) = 0
			cFields += AllTrim(aHeader[nFields,1])
			if nFields <len(aHeader)
	    		cFields += ", "
	    	End If
		//Endif
				
	Next nFields
	
	cFields +=  "%"
	 
	BeginSql alias cAliasRCP
		SELECT %exp:cFields%
		FROM %exp:cRCPtab%
		WHERE RCP_FILIAL IN %exp:cFils%
			  AND RCP_MAT IN %exp:cMats% //RCP_RG = %exp:cNIT%
		  AND RCP_DTMOV BETWEEN %exp:dPerPag% AND %exp:dFinPer%
		  AND %notDel% 
		  ORDER BY RCP_DTMOV,RCP_TPMOV,RCP_MAT 
	EndSql
	
	//-- Geracao das informacoes no array de Trajetoria Laboral do Funcionario
	While (cAliasRCP)->(!Eof())
		aTray := {}
		For nFields := 1 to LEN(aHeader)
			AADD(aTray,{aHeader[nFields,1] , (cAliasRCP)->&(aHeader[nFields,1])})		
		Next nFields
		
		AADD (aDados, aTray)
		(cAliasRCP)->(dbSkip())		
	EndDo
	(cAliasRCP)->( DbCloseArea() )
	
	RestArea(aArea)

Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fgetmovperºAutor  |mayra.camargo       º Data ³  31/12/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene los movimientos de tray. laboral según el          º±±
±±º          ³ periodo para el empleado en cuestion                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ getMovRCP(cNIT,aHeader,aMat)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cNITEnt := NIT  de la entidad a buscar                      º±±
±±º          ³aMat := Matriculas a buscar ya que el empleado puede estar  º±±
±±º          ³ en una o más sucursales                                    º±±
±±º          ³cIDCal := Identificador de cálculo a buscar                 º±±
±±º          ³cNumId := para el caso de ausentismos se busca por numid    º±±
±±º          ³cNConcepto := para el caso de ausentismos se busca por Conc.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ gpe                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FgetMovPer(cNITEnt,aMat,cIDCal,aPer ,cNumID,cConcepto)
	Local aDados 		:= {}
	Local aArea			:= GetArea()
	Local cAliasMov		:= GetNextAlias()
	Local nPos			:= 0
	Local cMats			:= "%("
	Local cFils			:= "%("
	Local nI 			:= 0
	Local cRotSRD		:= "% SRD." + rangeSX1("RD_ROTEIR",cProcedim) + " %"
	Local cRotSRC		:= "% SRC." + rangeSX1("RC_ROTEIR",cProcedim) + " %"
	Local cPD			:= "" 
	Local cExpPer		:= "%"
	Local cExpEntSRC	:= ""
	Local cExpEntSRD	:= ""
	Local cExpFilSRC 	:= ""
	Local cExpFilSRD 	:= ""
	Local cAux			:= ""
	Local nTam			:= TamSX3("RV_CODFOL")[1]
	Local cProcSRC		:= IIF(Empty(cProcesso),""," AND SRC." + rangeSX1("RC_PROCES",cProcesso) )
	Local cProcSRD		:= IIF(Empty(cProcesso),""," AND SRD." + rangeSX1("RD_PROCES",cProcesso) )
	
	DEFAULT cNITEnt 	:= Space(TamSx3("RA_MAT"))
	DEFAULT aMat 	   	:= {SRA->RA_FILIAL,SRA->RA_MAT}
	DEFAULT cNumID		:= "%%"
	DEFAULT cConcepto	:= ""
	DEFAULT cIDCal		:= ""
	
	//- Carregar somente os itens gerados pelo select
	cExpFilSRC :=  IIF(!Empty(cExpFilSRC)," AND SRC.RC_NUMID='" + cNumID+ "' ","")
	cExpFilSRD :=  IIF(!Empty(cExpFilSRD)," AND SRD.RD_NUMID='" + cNumID+ "' ","")
	
	cExpEntSRC	:= IIF(!Empty(cNITEnt),"% AND SRC.RC_ENTIDAD='" + cNITEnt+ "' %","%%")
	cExpEntSRD	:= IIF(!Empty(cNITEnt),"% AND SRD.RD_ENTIDAD='" + cNITEnt+ "' %","%%")
	
	cExpFilSRC := "%" + cExpFilSRC + cProcSRC + " %"	
	cExpFilSRD := "%" + cExpFilSRD + cProcSRD + " %"	
	
	If !Empty(cIdCal)
				
		If AT(";", cIDCal) > 0
 			cAux := cIDCal
 			nPos := AT(";", cIDCal)
 			nI := 1
 			While nPos > 0 .and.  nPos <= len(cIDCal)
 				cPD +=  Fgetcodfol(Substr(cAux,nI,nTam)) +"','"
 				nI := nPos + 1
 				cAux := Substr(cAux,nI)
 				nPos := AT(";", cAux)
 				nI := 1
 			EndDo
 			IF !Empty(cAux)
 				cPD +=  Fgetcodfol(Substr(cAux,1)) +"','"
 			End If
 			If Substr(cPD,Len(cPD)-1,2)==",'"
		    	cPD:="%('" + Substr(cPD,1,Len(cPD)-2)+") %"
		    Else
			    cPD:= "%('" + cPD + "')%"
			Endif 
		Else
			cPD :="%('" + fgetcodfol(cIDCal)+ "') %" 
		End If
	Else	
		cPD :="%('" + cConcepto + "') %" 
	End If
	
	For nI := 1 to len(aMat)
		cMats += "'" + aMat[nI,2] + "'"
		cFils += "'" + aMat[nI,1] + "'"
		If nI < len(aMat)
			cMats += ","
			cFils += ","
		Else 
			cMats+= ")%"
			cFils+= ")%"
		End If
	Next nI			
	
	cExpPer := "%("
	For nI := 1 to len(aPer)
		cExpPer += "'" + aPer[nI,1] + "'"
		
		If nI < len(aPer)
			cExpPer += ","
		Else 
			cExpPer+= ")%"
		End If
	Next nI	
	
	BeginSql alias cAliasMov
		SELECT SUM(VALOR) AS VALOR, SUM(HORAS) AS HORAS
		FROM (	
			SELECT sum(SRC.RC_VALOR) AS VALOR,sum(SRC.RC_HORAS) AS HORAS
			FROM %table:SRA% SRA	INNER JOIN %table:SRC% SRC 
			ON 	    SRA.RA_FILIAL = SRC.RC_FILIAL	AND
					SRA.RA_MAT    = SRC.RC_MAT		
			WHERE  SRA.RA_FILIAL IN %exp:cFils%
			  AND SRA.RA_MAT IN %exp:cMats% 
			  AND SRC.RC_PD IN %exp:cPD%
			  AND %exp:cRotSRC%
			  AND SRC.RC_PERIODO IN %exp:cExpPer%
			  AND SRA.%notDel% %exp:cExpFilSRC% AND SRC.%notDel% %exp:cExpEntSRC% 
		UNION 
			SELECT sum(SRD.RD_VALOR) AS VALOR,sum(SRD.RD_HORAS) AS HORAS
			FROM %table:SRA% SRA	INNER JOIN %table:SRD% SRD 
			ON 	    SRA.RA_FILIAL = SRD.RD_FILIAL	AND
					SRA.RA_MAT    = SRD.RD_MAT		
			WHERE  SRA.RA_FILIAL IN %exp:cFils%
			  AND SRA.RA_MAT IN %exp:cMats% 
			  AND SRD.RD_PD IN %exp:cPD%
			  AND %exp:cRotSRD%
			  AND SRD.RD_PERIODO IN %exp:cExpPer%
			  AND SRA.%notDel% %exp:cExpFilSRD% AND SRD.%notDel% %exp:cExpEntSRD%		
		  ) V
	EndSql
	
	//-- Geracao das informacoes no array de Trajetoria Laboral do Funcionario
	While (cAliasMov)->(!Eof())
		AADD(aDados,{(cAliasMov)->HORAS,(cAliasMov)->VALOR})		
		(cAliasMov)->(dbSkip())		
	EndDo
	(cAliasMov)->( DbCloseArea() )
	
	RestArea(aArea)

Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fgetmovperºAutor  |mayra.camargo       º Data ³  31/12/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene los movimientos de tray. laboral según el          º±±
±±º          ³ periodo para el empleado en cuestion                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ getMovRCP(cNIT,aHeader,aMat)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cNITEnt := NIT  de la entidad a buscar                      º±±
±±º          ³aMat := Matriculas a buscar ya que el empleado puede estar  º±±
±±º          ³ en una o más sucursales                                    º±±
±±º          ³cIDCal := Identificador de cálculo a buscar                 º±±
±±º          ³cNumId := para el caso de ausentismos se busca por numid    º±±
±±º          ³cNConcepto := para el caso de ausentismos se busca por Conc.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ gpe                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FgetTOTPer(cNITEnt,aMat,cIDCal,aPer ,cNumID,cConcepto)
	Local aArea		:= GetArea()
	Local cAliasMov	:= GetNextAlias()
	Local nPos		:= 0
	Local cMats		:= "%("
	Local cFils		:= "%("
	Local nI 			:= 0
	Local cRotSRD		:= "% SRD." + rangeSX1("RD_ROTEIR",cProcedim) + " %"
	Local cRotSRC		:= "% SRC." + rangeSX1("RC_ROTEIR",cProcedim) + " %"
	Local cPD			:= "" 
	Local cExpPer		:= "%"
	Local cExpEntSRC	:= ""
	Local cExpEntSRD	:= ""
	Local cExpFilSRC 	:= ""
	Local cExpFilSRD := ""
	Local cAux		:= ""
	Local nTam		:= TamSX3("RV_CODFOL")[1]
	Local nCountReg := 0

	DEFAULT cNITEnt 	:= Space(TamSx3("RA_EPS"))
	DEFAULT aMat 	   	:= {SRA->RA_FILIAL,SRA->RA_MAT}
	DEFAULT cNumID		:= "%%"
	DEFAULT cConcepto	:= ""
	DEFAULT cIDCal 		:= ""
	
	//- Carregar somente os itens gerados pelo select
	cExpFilSRC :=  IIF(!Empty(cExpFilSRC),"% AND SRC.RC_NUMID='" + cNumID+ "' %","%%")
	cExpFilSRD :=  IIF(!Empty(cExpFilSRD),"% AND SRD.RD_NUMID='" + cNumID+ "' %","%%")
	
	cExpEntSRC	:= IIF(!Empty(cNITEnt),"% AND SRC.RC_ENTIDAD='" + cNITEnt + "' %","%%")
	cExpEntSRD	:= IIF(!Empty(cNITEnt),"% AND SRD.RD_ENTIDAD='" + cNITEnt + "' %","%%")
	
	If !Empty(cIdCal)
				
		If AT(";", cIDCal) > 0
 			cAux := cIDCal
 			nPos := AT(";", cIDCal)
 			nI := 1
 			While nPos > 0 .and.  nPos <= len(cIDCal)
 				cPD +=  Fgetcodfol(Substr(cAux,nI,nTam)) +"','"
 				nI := nPos + 1
 				cAux := Substr(cAux,nI)
 				nPos := AT(";", cAux)
 				nI := 1
 			EndDo
 			IF !Empty(cAux)
 				cPD +=  Fgetcodfol(Substr(cAux,1)) +"','"
 			End If
 			If Substr(cPD,Len(cPD)-1,2)==",'"
		    	cPD:="%('" + Substr(cPD,1,Len(cPD)-2)+") %"
		    Else
			    cPD:= "%('" + cPD + "')%"
			Endif 
		Else
			cPD :="%('" + fgetcodfol(cIDCal)+ "') %" 
		End If
	Else	
		cPD :="%('" + cConcepto + "') %" 
	End If
	
	For nI := 1 to len(aMat)
		cMats += "'" + aMat[nI,2] + "'"
		cFils += "'" + aMat[nI,1] + "'"
		If nI < len(aMat)
			cMats += ","
			cFils += ","
		Else 
			cMats+= ")%"
			cFils+= ")%"
		End If
	Next nI			
	
	cExpPer := "%("
	For nI := 1 to len(aPer)
		cExpPer += "'" + aPer[nI,1] + "'"
		
		If nI < len(aPer)
			cExpPer += ","
		Else 
			cExpPer+= ")%"
		End If
	Next nI	

	BeginSql alias cAliasMov

SELECT SUM(TOTAL) AS TOTAL
FROM (
			SELECT count(RC_PD) AS TOTAL
			FROM %table:SRA% SRA	INNER JOIN %table:SRC% SRC 
			ON 	    SRA.RA_FILIAL = SRC.RC_FILIAL	AND
					SRA.RA_MAT    = SRC.RC_MAT		
			WHERE  SRA.RA_FILIAL IN %exp:cFils%
			  AND SRA.RA_MAT IN %exp:cMats% 
			  AND SRC.RC_PD IN %exp:cPD%
			  AND %exp:cRotSRC% 
			  AND SRC.RC_PERIODO IN %exp:cExpPer%
			  AND SRA.%notDel% %exp:cExpFilSRC% 
			  AND SRC.%notDel% %exp:cExpEntSRC%
		UNION 
			SELECT count(RD_PD) AS TOTAL
			FROM %table:SRA% SRA	INNER JOIN %table:SRD% SRD 
			ON 	    SRA.RA_FILIAL = SRD.RD_FILIAL	AND
					SRA.RA_MAT    = SRD.RD_MAT		
			WHERE  SRA.RA_FILIAL IN %exp:cFils%
			  AND SRA.RA_MAT IN %exp:cMats% 
			  AND SRD.RD_PD IN %exp:cPD%
			  AND %exp:cRotSRD% 
			  AND SRD.RD_PERIODO IN %exp:cExpPer%
			  AND SRA.%notDel% %exp:cExpFilSRD% 
			  AND SRD.%notDel% %exp:cExpEntSRD%		  	
 )V
	EndSql
	
	//-- Geracao das informacoes no array de Trajetoria Laboral do Funcionario
	While (cAliasMov)->(!Eof())
		nCountReg += (cAliasMov)->TOTAL		
		(cAliasMov)->(dbSkip())		
	EndDo
	(cAliasMov)->( DbCloseArea() )
	
	RestArea(aArea)

Return nCountReg


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fgetmovsr8ºAutor  |mayra.camargo       º Data ³  31/12/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene los movimientos de tray. laboral según el          º±±
±±º          ³ periodo para el empleado en cuestion                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ getMovRCP(cNIT,aHeader,aMat)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cNITEnt := NIT  de la entidad a buscar                      º±±
±±º          ³aMat := Matriculas a buscar ya que el empleado puede estar  º±±
±±º          ³ en una o más sucursales                                    º±±
±±º          ³cIDCal := Identificador de cálculo a buscar                 º±±
±±º          ³cNumId := para el caso de ausentismos se busca por numid    º±±
±±º          ³cNConcepto := para el caso de ausentismos se busca por Conc.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ gpe                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fgetmovsr8(cNITEnt,aMat,cIDCal,aPer ,cNumID,cConcepto)
	Local aDados 		:= {}
	Local aArea			:= GetArea()
	Local cAliasMov		:= GetNextAlias()
	Local nPos			:= 0
	Local cMats			:= "%("
	Local cFils			:= "%("
	Local nI 			:= 0
	Local cRotSRD		:= "% SRD." + rangeSX1("RD_ROTEIR",cProcedim) + " %"
	Local cRotSRC		:= "% SRC." + rangeSX1("RC_ROTEIR",cProcedim) + " %"
	Local cPD			:= "" 
	Local cExpPer		:= "%"
	Local cExpEntSRC	:= ""
	Local cExpEntSRD	:= ""
	Local cExpFilSRC 	:= ""
	Local cExpFilSRD 	:= ""
	Local cAux			:= ""
	Local nTam			:= TamSX3("RV_CODFOL")[1]
	Local cExpTpImss	:= "%('A','F','M','P','G','V','L','C','E','R')%"
	Local dIni 			:= ""
	Local dFin 			:= ""
	Local cProcSRC		:= IIF(Empty(cProcesso),""," AND SRC." + rangeSX1("RC_PROCES",cProcesso) )
	Local cProcSRD		:= IIF(Empty(cProcesso),""," AND SRD." + rangeSX1("RD_PROCES",cProcesso) )
	
	DEFAULT cNITEnt 	:= Space(TamSx3("RA_MAT"))
	DEFAULT aMat 	   	:= {SRA->RA_FILIAL,SRA->RA_MAT}
	DEFAULT cNumID		:=  "%%"
	DEFAULT cConcepto	:= ""
	DEFAULT cIDCal 		:= ""
	
	//- Carregar somente os itens gerados pelo select
	cExpFilSRC :=  IIF(!Empty(cExpFilSRC)," AND SRC.RC_NUMID='" + cNumID+ "' ","")
	cExpFilSRD :=  IIF(!Empty(cExpFilSRD)," AND SRD.RD_NUMID='" + cNumID+ "' ","")
	
	cExpEntSRC	:= IIF(!Empty(cNITEnt),"% AND SRC.RC_ENTIDAD='" + cNITEnt+ "' %","%%")
	cExpEntSRD	:= IIF(!Empty(cNITEnt),"% AND SRD.RD_ENTIDAD='" + cNITEnt+ "' %","%%")
	
	cExpFilSRC := "%" + cExpFilSRC + cProcSRC + " %"	
	cExpFilSRD := "%" + cExpFilSRD + cProcSRD + " %"
	
	If !Empty(cIdCal)
				
		If AT(";", cIDCal) > 0
 			cAux := cIDCal
 			nPos := AT(";", cIDCal)
 			nI := 1
 			While nPos > 0 .and.  nPos <= len(cIDCal)
 				If !(Substr(cAux,nI,nTam) $ ";")
	 				If !Empty(AllTrim(Fgetcodfol(Substr(cAux,nI,nTam))))
	 				cPD +=  Fgetcodfol(Substr(cAux,nI,nTam)) +"','"
	 				EndIF
 				EndIF
 				nI := nPos + 1
 				cAux := Substr(cAux,nI)
 				nPos := AT(";", cAux)
 				nI := 1
 			EndDo
 			IF !Empty(cAux)
 				cPD +=  Fgetcodfol(Substr(cAux,1)) +"','"
 			End If
 			If Substr(cPD,Len(cPD)-1,2)==",'"
		    	cPD:="%('" + Substr(cPD,1,Len(cPD)-2)+") %"
		    Else
			    cPD:= "%('" + cPD + "')%"
			Endif 
		Else
			cPD :="%('" + fgetcodfol(cIDCal)+ "') %" 
		End If
	Else	
		cPD :="%('" + cConcepto + "') %" 
	End If
	
	For nI := 1 to len(aMat)
		cMats += "'" + aMat[nI,2] + "'"
		cFils += "'" + aMat[nI,1] + "'"
		If nI < len(aMat)
			cMats += ","
			cFils += ","
		Else 
			cMats+= ")%"
			cFils+= ")%"
		End If
	Next nI			
	
	cExpPer := "%("
	For nI := 1 to len(aPer)
		cExpPer += "'" + aPer[nI,1] + "'"
		
		If nI < len(aPer)
			cExpPer += ","
		Else 
			cExpPer+= ")%"
		End If
	Next nI	

	BeginSql alias cAliasMov

		SELECT SR8.R8_MAT,SR8.R8_FILIAL, SR8.R8_DATAINI, R8_DATAFIM,
 RCM_TPIMSS,
 SR8.R8_NAUTORI,SR8.R8_PD 
		FROM %table:SR8% SR8 
		INNER JOIN %table:RCM% RCM  ON SR8.R8_TIPOAFA = RCM.RCM_TIPO
		INNER JOIN %table:SRC% SRC 
					ON 	 SR8.R8_FILIAL = SRC.RC_FILIAL	AND
							SR8.R8_MAT    = SRC.RC_MAT		
					  AND SRC.RC_PD IN %exp:cPD%
					  AND %exp:cRotSRC%
					  AND SRC.RC_PERIODO IN %exp:cExpPer%
					  AND SRC.RC_NUMID = SR8.R8_NUMID AND SRC.%notDel% 
					  WHERE  SR8.R8_FILIAL IN %exp:cFils%
					  AND SR8.R8_MAT IN %exp:cMats%  
					  AND SR8.%notDel% AND RCM.%notDel% %exp:cExpFilSRC%
					  AND RCM.RCM_TPIMSS IN %exp:cExpTpImss%
UNION
		SELECT SR8.R8_MAT,SR8.R8_FILIAL, SR8.R8_DATAINI, R8_DATAFIM,
 RCM_TPIMSS,
 SR8.R8_NAUTORI,SR8.R8_PD 
		FROM %table:SR8% SR8 
		INNER JOIN %table:RCM% RCM  ON SR8.R8_TIPOAFA = RCM.RCM_TIPO
		INNER JOIN %table:SRD% SRD 
					ON 	 SR8.R8_FILIAL = SRD.RD_FILIAL	AND
							SR8.R8_MAT    = SRD.RD_MAT		
					  AND SRD.RD_PD IN %exp:cPD%
					  AND %exp:cRotSRD%
					  AND SRD.RD_PERIODO IN %exp:cExpPer%
					  AND SRD.RD_NUMID = SR8.R8_NUMID AND SRD.%notDel% 
					  WHERE  SR8.R8_FILIAL IN %exp:cFils%
					  AND SR8.R8_MAT IN %exp:cMats%  
					  AND SR8.%notDel% AND RCM.%notDel% %exp:cExpFilSRD% 
					  AND RCM.RCM_TPIMSS IN %exp:cExpTpImss%					  
	EndSql
	
	//-- Geracao das informacoes no array de Trajetoria Laboral do Funcionario
	While (cAliasMov)->(!Eof())
		// Verifica las fechas de los ausentismos si exceden del periodof
		If STOD((cAliasMov)->R8_DATAINI) < dPerPag
			dIni := DTOS(dPerPag)
		Else
			dIni := (cAliasMov)->R8_DATAINI
		EndIf
		
		If STOD((cAliasMov)->R8_DATAFIM )> dFinPer
			dFin := DTOS(dFinPer)
		Else
			dFin := (cAliasMov)->R8_DATAFIM
		EndIf
	
		nPosTImss := AScan(aDados, {|x,y| (cAliasMov)->RCM_TPIMSS $ x[2] })

	    If nPosTImss == 0
			If (cAliasMov)->RCM_TPIMSS == "C"
				AADD(aDados,{(cAliasMov)->R8_FILIAL	,"C",dIni,dFin,;
				(cAliasMov)->R8_NAUTORI,(cAliasMov)->R8_PD,(cAliasMov)->RCM_TPIMSS})	
			Elseif (cAliasMov)->RCM_TPIMSS $ "L"
				AADD(aDados,{(cAliasMov)->R8_FILIAL	,"L",dIni,dFin,;
				(cAliasMov)->R8_NAUTORI,(cAliasMov)->R8_PD,(cAliasMov)->RCM_TPIMSS})
			Elseif (cAliasMov)->RCM_TPIMSS $ "F"
				AADD(aDados,{(cAliasMov)->R8_FILIAL	,"F",dIni,dFin,;
				(cAliasMov)->R8_NAUTORI,(cAliasMov)->R8_PD,(cAliasMov)->RCM_TPIMSS})			
			Elseif (cAliasMov)->RCM_TPIMSS $ "G"
				AADD(aDados,{(cAliasMov)->R8_FILIAL	,"G",dIni,dFin,;
				(cAliasMov)->R8_NAUTORI,(cAliasMov)->R8_PD,(cAliasMov)->RCM_TPIMSS})	
			Elseif (cAliasMov)->RCM_TPIMSS $ "V"
				AADD(aDados,{(cAliasMov)->R8_FILIAL	,"V",dIni,dFin,;
				(cAliasMov)->R8_NAUTORI,(cAliasMov)->R8_PD,(cAliasMov)->RCM_TPIMSS})							
			Elseif (cAliasMov)->RCM_TPIMSS $ "R"
				AADD(aDados,{(cAliasMov)->R8_FILIAL	,"R",dIni,dFin,;
				(cAliasMov)->R8_NAUTORI,(cAliasMov)->R8_PD,(cAliasMov)->RCM_TPIMSS})
			Elseif (cAliasMov)->RCM_TPIMSS $ "M"
				AADD(aDados,{(cAliasMov)->R8_FILIAL	,"M",dIni,dFin,;
				(cAliasMov)->R8_NAUTORI,(cAliasMov)->R8_PD,(cAliasMov)->RCM_TPIMSS})
			Elseif (cAliasMov)->RCM_TPIMSS $ "P"
				AADD(aDados,{(cAliasMov)->R8_FILIAL	,"P",dIni,dFin,;
				(cAliasMov)->R8_NAUTORI,(cAliasMov)->R8_PD,(cAliasMov)->RCM_TPIMSS})
			Elseif (cAliasMov)->RCM_TPIMSS $ "A"
				AADD(aDados,{(cAliasMov)->R8_FILIAL	,"A",dIni,dFin,;
				(cAliasMov)->R8_NAUTORI,(cAliasMov)->R8_PD,(cAliasMov)->RCM_TPIMSS})
			EndIF
	    Else
	    
		    If aDados[nPosTImss,3] > dIni//(cAliasMov)->R8_DATAINI
		    	aDados[nPosTImss,3] := dIni//(cAliasMov)->R8_DATAINI
		    EndIF
		    
		    If aDados[nPosTImss,4] < dFin//(cAliasMov)->R8_DATAFIM
		    	aDados[nPosTImss,4] := dFin//(cAliasMov)->R8_DATAFIM
		    EndIF
		    
		    If !((cAliasMov)->R8_PD $ aDados[nPosTImss,6])
	    	   aDados[nPosTImss,6] += "','" + (cAliasMov)->R8_PD  
	    	EndIF    
		EndIF	
		(cAliasMov)->(dbSkip())		
	EndDo
	(cAliasMov)->( DbCloseArea() )
	
	RestArea(aArea)

Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fgetmovUPSºAutor  |mayra.camargo       º Data ³  31/12/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene los movimientos de tray. laboral según el          º±±
±±º          ³ periodo para el empleado en cuestion                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ getMovRCP(cNIT,aHeader,aMat)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cNITEnt := NIT  de la entidad a buscar                      º±±
±±º          ³aMat := Matriculas a buscar ya que el empleado puede estar  º±±
±±º          ³ en una o más sucursales                                    º±±
±±º          ³cIDCal := Identificador de cálculo a buscar                 º±±
±±º          ³cNumId := para el caso de ausentismos se busca por numid    º±±
±±º          ³cNConcepto := para el caso de ausentismos se busca por Conc.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ gpe                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fgetmovUPS(cNITEnt,aMat,cIDCal,aPer ,cNumID,cConcepto)
	Local aDados 		:= {}
	Local aArea			:= GetArea()
	Local cAliasMov		:= GetNextAlias()
	Local nPos			:= 0
	Local cMats			:= "%("
	Local cFils			:= "%("
	Local nI 			:= 0
	Local cRotSRD		:= "% SRD." + rangeSX1("RD_ROTEIR",cProcedim) + " %"
	Local cRotSRC		:= "% SRC." + rangeSX1("RC_ROTEIR",cProcedim) + " %"
	Local cPD			:= "" 
	Local cExpPer		:= "%"
	Local cExpEntSRC	:= ""
	Local cExpEntSRD	:= ""
	Local cExpFilSRC 	:= ""
	Local cExpFilSRD 	:= ""
	Local cAux			:= ""
	Local nTam			:= TamSX3("RV_CODFOL")[1]
	Local cProcSRC		:= IIF(Empty(cProcesso),""," AND SRC." + rangeSX1("RC_PROCES",cProcesso) )
	Local cProcSRD		:= IIF(Empty(cProcesso),""," AND SRD." + rangeSX1("RD_PROCES",cProcesso) )
	
	DEFAULT cNITEnt		:= Space(TamSx3("RA_MAT"))
	DEFAULT aMat		:= {SRA->RA_FILIAL,SRA->RA_MAT}
	DEFAULT cNumID		:= "%%"
	DEFAULT cConcepto	:= ""
	DEFAULT cIDCal		:= ""
	
	//- Carregar somente os itens gerados pelo select
	cExpFilSRC :=  IIF(!Empty(cExpFilSRC)," AND SRC.RC_NUMID='" + cNumID+ "' ","")
	cExpFilSRD :=  IIF(!Empty(cExpFilSRD)," AND SRD.RD_NUMID='" + cNumID+ "' ","")
	
	cExpEntSRC	:= IIF(!Empty(cNITEnt),"% AND SRC.RC_ENTIDAD='" + cNITEnt+ "' %","%%")
	cExpEntSRD	:= IIF(!Empty(cNITEnt),"% AND SRD.RD_ENTIDAD='" + cNITEnt+ "' %","%%")
	
	cExpFilSRC := "%" + cExpFilSRC + cProcSRC + " %"	
	cExpFilSRD := "%" + cExpFilSRD + cProcSRD + " %"	
	
	If !Empty(cIdCal)
				
		If AT(";", cIDCal) > 0
 			cAux := cIDCal
 			nPos := AT(";", cIDCal)
 			nI := 1
 			While nPos > 0 .and.  nPos <= len(cIDCal)
 				cPD +=  Fgetcodfol(Substr(cAux,nI,nTam)) +"','"
 				nI := nPos + 1
 				cAux := Substr(cAux,nI)
 				nPos := AT(";", cAux)
 				nI := 1
 			EndDo
 			IF !Empty(cAux)
 				cPD +=  Fgetcodfol(Substr(cAux,1)) +"','"
 			End If
 			If Substr(cPD,Len(cPD)-1,2)==",'"
		    	cPD:="%('" + Substr(cPD,1,Len(cPD)-2)+") %"
		    Else
			    cPD:= "%('" + cPD + "')%"
			Endif 
		Else
			cPD :="%('" + fgetcodfol(cIDCal)+ "') %" 
		End If
	Else	
		cPD :="%('" + cConcepto + "') %" 
	End If
	
	For nI := 1 to len(aMat)
		cMats += "'" + aMat[nI,2] + "'"
		cFils += "'" + aMat[nI,1] + "'"
		If nI < len(aMat)
			cMats += ","
			cFils += ","
		Else 
			cMats+= ")%"
			cFils+= ")%"
		End If
	Next nI			
	
	cExpPer := "%("
	For nI := 1 to len(aPer)
		cExpPer += "'" + aPer[nI,1] + "'"
		
		If nI < len(aPer)
			cExpPer += ","
		Else 
			cExpPer+= ")%"
		End If
	Next nI	
	
	BeginSql alias cAliasMov

			SELECT SUM(VALOR) AS VALOR, SUM(HORAS) AS HORAS, ENTIDAD as ENTIDAD
		FROM (
		SELECT SUM(SRC.RC_VALOR) AS VALOR,SUM(SRC.RC_HORAS) AS HORAS,SRC.RC_ENTIDAD AS ENTIDAD
			FROM %table:SRA% SRA	INNER JOIN %table:SRC% SRC 
			ON 	    SRA.RA_FILIAL = SRC.RC_FILIAL	AND
					SRA.RA_MAT    = SRC.RC_MAT		
			WHERE  SRA.RA_FILIAL IN %exp:cFils%
			  AND SRA.RA_MAT IN %exp:cMats% 
			  AND SRC.RC_PD IN %exp:cPD%
			  AND %exp:cRotSRC%
			  AND SRC.RC_PERIODO IN %exp:cExpPer%
			  AND SRA.%notDel% %exp:cExpFilSRC% AND SRC.%notDel% %exp:cExpEntSRC%
			  group by SRC.RC_VALOR,RC_HORAS,RC_ENTIDAD
		UNION 
			SELECT SRD.RD_VALOR AS VALOR, SRD.RD_HORAS AS HORAS,SRD.RD_ENTIDAD AS ENTIDAD
			FROM %table:SRA% SRA	INNER JOIN %table:SRD% SRD 
			ON 	    SRA.RA_FILIAL = SRD.RD_FILIAL	AND
					SRA.RA_MAT    = SRD.RD_MAT		
			WHERE  SRA.RA_FILIAL IN %exp:cFils%
			  AND SRA.RA_MAT IN %exp:cMats% 
			  AND SRD.RD_PD IN %exp:cPD%
			  AND %exp:cRotSRD%
			  AND SRD.RD_PERIODO IN %exp:cExpPer%
			  AND SRA.%notDel% %exp:cExpFilSRD% AND SRD.%notDel% %exp:cExpEntSRD%	
			  group by RD_VALOR,RD_HORAS,RD_ENTIDAD	  	
			  )v GROUP by VALOR,HORAS,ENTIDAD
	EndSql
	
	//-- Geracao das informacoes no array de Trajetoria Laboral do Funcionario
	While (cAliasMov)->(!Eof())
		AADD(aDados,{(cAliasMov)->HORAS,(cAliasMov)->VALOR,(cAliasMov)->ENTIDAD })		
		(cAliasMov)->(dbSkip())		
	EndDo
	(cAliasMov)->( DbCloseArea() )
	
	RestArea(aArea)

Return aDados

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fFindMatAdic(cNIT)ºAutor: mayra.camargoº Data ³ 31/12/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Busca las matrículas adicionales del empleado por NIT.     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function fFindMatAdic(cNIT)
	Local aArea		:= GetArea()
	Local cFields	:= ""
	Local cAliasSRA	:= GetNextAlias()
	Local aDados	:= {}
	
	DEFAULT cNIT	:= SRA->RA_RG
	
	//- Carregar somente os itens gerados pelo select
	cFields := "%RA_FILIAL,RA_MAT,RA_PROCES%"			

	//-- Leitura dos registros por ordem de Sequencia
	BeginSql alias cAliasSRA
		SELECT %exp:cFields%
		FROM %table:SRA%
		WHERE RA_RG = %exp:cNIT%
		  AND %notDel%
		  ORDER BY RA_MAT 
	EndSql
	
	//-- Geracao das informacoes no array de Trajetoria Laboral do Funcionario
	While (cAliasSRA)->(!Eof())
		If rTrim((cAliasSRA)->RA_PROCES) $ cProcesso
			aadd(aDados,{(cAliasSRA)-> RA_FILIAL,(cAliasSRA)->RA_MAT ,(cAliasSRA)->RA_PROCES})
		End If
		(cAliasSRA)->( DbSkip() )			
	EndDo
	(cAliasSRA)->( DbCloseArea() )
	
	RestArea(aArea)
Return aDados
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fgetPer   ºAutor  ³mayra.camargo       º Data ³ 31/12/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Busca los códigos de los periodos comprendidos en el        º±±
±±ºDesc.     ³mes/año indicados en el parametro MV_PAR04                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function fgetPer(cMes,cYear)

	Local aPer := {}
	Local aArea := getArea()
	
	cMes := strZero(cMes,2) 
	cYear:= str(cYear,4)
	
	dbselectarea("RCH")
	dbSetOrder(7)
	
	if RCH->(dbSeek(XFILIAL("RCH")+cYear+cMes))	
		Do While RCH->(!EOF()) 
			If RCH->RCH_MES == cMes .AND. RCH->RCH_ANO == cYear .and. RCH->RCH_ROTEIR $ cProcedim .and. rTrim(RCH->RCH_PROCES) $ cProcesso
					AADD(aPer,{RCH->RCH_PER,RCH->RCH_ROTEIR,RCH->RCH_PROCES,RCH->RCH_DTINI,RCH->RCH_DTFIM})
			EndIF
			RCH->(DBSkip())
		EndDo
	eND iF
	RestArea(aArea)		
Return aPer
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³getRegRG1 ºAutor  | mayra.camargo      º Data ³  31/12/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ontiene datos de la RG1                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ getRegRG1(aMat,cCodAFP,lIndica)                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aMat := Matrículas ab uscar.                                º±±
±±º          ³cCodAFP:= codigo de la Entidad de pensión                   º±±
±±º          ³lindica:= .F. para bsucar por tipo de calculo ='A'          º±±
±±º          ³         .T. para buscar por concepto para id calculo 1362  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPE                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function getRegRG1(aMat,cCodAFP,lIndica)
	
	Local aDados	:= {}
	Local aArea		:= GetArea()
	Local cFields	:= ""
	Local cAliasRG1	:= GetNextAlias()
	Local nI		:= 0
	Local cMats		:= "%("
	Local cFils		:= "%("
	Local cPD		:= "%%"
	
	DEFAULT cCodAFp	:= SRA->RA_CODAFP
	DEFAULT aMAT	:= {SRA->RA_FILIAL,SRA->RA_MAT}
	DEFAULT lIndica	:= .F.
	
	//- Carregar somente os itens gerados pelo select
	cFields :=  "% RG1_TPDATO, RG1_TPBLEG %"
	cPd := fGetcodfol("1362")
	For nI := 1 to len(aMat)
		cMats += "'" + aMat[nI,2] + "'"
		cFils += "'" + aMat[nI,1] + "'"
		If nI < len(aMat)
			cMats += ","
			cFils += ","
		Else 
			cMats+= ")%"
			cFils+= ")%"
		End If
	Next nI			
	
	If lIndica
		cPd := "%AND RG1_PD IN ('"+ fGetcodfol("1362") +"') %"
	Else
		cPD := "%AND RG1_TPCALC = 'A' AND  RG1_TPBLEG='"+ cCodAFP +"' %"	
	End If
			 
	BeginSql alias cAliasRG1
		SELECT %exp:cFields%
		FROM  %table:RG1% 
		WHERE  RG1_FILIAL IN %exp:cFils%
		  AND RG1_MAT IN %exp:cMats% 
		  AND (RG1_DINIPG >= %exp:dPerPag% OR RG1_DFIMPG <= %exp:dFinPer%)
		  AND %notDel%  %exp:cPd%	
	EndSql
	
	//-- Geracao das informacoes no array de Afastamentos do Funcionario
	While (cAliasRG1)->(!Eof())
				
		//Estructura array
		//+------------------+
		//| 1.-Filial        |
		//| 2.-Matricula     |
		//+------------------+
			  
		AADD(aDados,{	(cAliasRG1)->RG1_TPDATO	,;
						(cAliasRG1)->RG1_TPBLEG	})				
		(cAliasRG1)->(dbSkip())
				
	EndDo
	(cAliasRG1)->( DbCloseArea() )
	
	RestArea(aArea)

Return aDados


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³getRegUPS ºAutor  | mayra.camargo      º Data ³  31/12/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ontiene datos de la RG1                                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³ getRegRG1(aMat,cCodAFP,lIndica)                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aMat := Matrículas ab uscar.                                º±±
±±º          ³cCodAFP:= codigo de la Entidad de pensión                   º±±
±±º          ³lindica:= .F. para bsucar por tipo de calculo ='A'          º±±
±±º          ³         .T. para buscar por concepto para id calculo 1362  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GPE                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function getReUPS(aMat,cCodUPS)
	Local aDados	:= {}
	Local aArea		:= GetArea()
	Local cFields	:= ""
	Local cAliasUPS	:= GetNextAlias()
	Local nI		:= 0
	Local cMats		:= "%("
	Local cFils		:= "%("
	
	DEFAULT aMAT 		:= {SRA->RA_FILIAL,SRA->RA_MAT}
	
	//- Carregar somente os itens gerados pelo select
	For nI := 1 to len(aMat)
		cMats += "'" + aMat[nI,2] + "'"
		cFils += "'" + aMat[nI,1] + "'"
		If nI < len(aMat)
			cMats += ","
			cFils += ","
		Else 
			cMats+= ")%"
			cFils+= ")%"
		End If
	Next nI			
	
	cFields :=  "% RB_PRINOME, RB_SECNOME, RB_PRISOBR, RB_SECSOBR, RB_CIC, RB_TPCIC %"
	  
	For nI:= 1  to Len(aMovUPS)		
		BeginSql alias cAliasUPS
			SELECT %exp:cFields%
			FROM  %table:SRB% 
			WHERE  RB_FILIAL IN %exp:cFils%
			  AND RB_MAT IN %exp:cMats%
			  AND RB_CIC = %exp:aMovUPS[nI,3]% 
				  AND %notDel%  
		EndSql
		
			While (cAliasUPS)->(!Eof())
			
			AADD(aDados,{	(cAliasUPS)->RB_TPCIC	,;
							(cAliasUPS)->RB_CIC	,;
							(cAliasUPS)->RB_PRISOBR	,;
							(cAliasUPS)->RB_SECSOBR	,;
							(cAliasUPS)->RB_PRINOME	,;
							(cAliasUPS)->RB_SECNOME	,;
							aMovUPS[nI,2]})			
			
			(cAliasUPS)->(dbSkip())
			EndDo					
			(cAliasUPS)->( DbCloseArea() )			
		
		Next 

	RestArea(aArea)

Return aDados

//+--------------------------------------------------------------------------------------------------------------------------////
//| 	DEFINICIÓN DE LA CLASE PILA                                                                                          |
//+-------------------------------------------------------------------------------------------------------------------------+////
#DEFINE PILA_TAMANHO	1
#DEFINE PILA_INICIO		2
#DEFINE PILA_FINAL		3
#DEFINE PILA_TIPO		4
#DEFINE PILA_DESCRICAO	5
#DEFINE PILA_FORMATO	6

/*/{Protheus.doc} PILA
Gera arq. magnetico PILA (Planilha Integrada de Liquidacao de Aportes)  
@type class
@author mayra.camargo
@since 16/10/2018
@version 2.0
/*/
Class PILA from LongClassName
	Data nFileType
	Data nRecType
	Data oRecords
	Data oNewRec
 
	Method New(nFile) CONSTRUCTOR
	Method AddRecord(nRecord)
	Method FindRecord(nPos,nVal)
	Method SetField(cPosition, xValue)
	Method GetField(cPosition)
	Method SaveRecord()
	Method GetStructure(nFile, nRecord)
	Method BuildFileLines()
	Method WriteFile(cArquivo)
	Method genExcel(cArquivo)
EndClass


/// <summary>
/// 	
/// </summary>
/// <param name="nFile"></param>
/// <returns></returns>
Method New(nFile) Class PILA
	Self:nFileType	:= nFile
	Self:oRecords	:= ArrayList():New()
	Self:oNewRec	:= NIL
Return Self


/// <summary>
/// 	
/// </summary>
/// <param name="nRecord"></param>
/// <returns></returns>
Method AddRecord(nRecord) Class PILA
	Self:SaveRecord()
	Self:nRecType := nRecord
	
	Self:oNewRec:= HashTable():New()
Return 

/// <summary>
/// 	
/// </summary>
/// <param name="cPosition"></param>
/// <param name="xValue"></param>
/// <returns></returns>
Method SetField(cPosition, xValue) Class PILA
	Self:oNewRec:SetItem(cPosition, xValue)
Return 

/// <summary>
/// 	
/// </summary>
/// <param name="cPosition"></param>
/// <param name="xValue"></param>
/// <returns></returns>
Method GetField(cPosition) Class PILA	
Return Self:oNewRec:GetItem(cPosition)

/// <summary>
/// 	
/// </summary>
/// <returns></returns>
Method SaveRecord() Class PILA
	Local nIndex
	
	If Self:oNewRec != NIL
		nIndex:= AScan(Self:oRecords:ToArray(), {|oItem| oItem:GetKey() == (Self:nRecType+1)} )
		
		If nIndex > 0
			Self:oRecords:Insert(nIndex, DictionaryEntry():New(Self:nRecType, Self:oNewRec))
		Else
			Self:oRecords:Add(DictionaryEntry():New(Self:nRecType, Self:oNewRec))
		EndIf
	EndIf
	
	Self:oNewRec:= NIL
Return 

/// <summary>
/// 	
/// </summary>
/// <param name="cPosition"></param>
/// <param name="xValue"></param>
/// <returns></returns>
Method WriteFile(cArquivo) Class PILA
	Local nHandle	:= MSFCREATE(cArquivo, 0)
	Local aLines	:= Self:BuildFileLines()
	Local nCount
	
	IF FError() != 0 .AND. nHandle = -1 
		MsgInfo("Erro de Gravacao do Arquivo - Codigo DOS: " + STR(FError(), 3), "Erro")
		Return .F.
	Endif
	
	IF File( cArquivo )
		fErase( cArquivo )
	EndIF
	
    For nCount := 1 To Len(aLines)
	    Fwrite(nHandle, aLines[nCount] + CHR(13) + CHR(10) )
	Next nCount

	FClose(nHandle)
Return .T.


Method BuildFileLines() Class PILA
	Local aLines:= {}
	Local nCount
	Local nField
	Local nRecord
	Local cString
	Local oTmpRecord
	Local oStructure
			
	For nCount:= 1 to Self:oRecords:GetCount()		
		cString:= ""
		oTmpRecord	:= Self:oRecords:GetItem(nCount):GetValue()
		nRecord		:= Self:oRecords:GetItem(nCount):GetKey()
		oStructure	:= Self:GetStructure(Self:nFileType, nRecord)	

		For nField:= 1 To oStructure:GetCount()
			xValue:= oTmpRecord:GetItem( oStructure:GetKey(nField) )			
			aFieldStruct:= oStructure:GetValue(nField)
			
			IF Len(aFieldStruct) >= PILA_FORMATO
				xValue:= Eval(aFieldStruct[PILA_FORMATO], xValue, aFieldStruct[PILA_TAMANHO])
			Else
				If ValType(xValue) == "C"
					xValue:= PadR(xValue, aFieldStruct[PILA_TAMANHO])
				ElseIf ValType(xValue) == "N"
					xValue:= StrZero(xValue, aFieldStruct[PILA_TAMANHO])
				ElseIf ValType(xValue) == "D"
					xValue:= DTOS(xValue)
				ElseIf ValType(xValue) == "L"
					xValue:= IIF(xValue, "T", "F")
				ElseIf ValType(xValue) == "U"
					xValue:= Space(aFieldStruct[PILA_TAMANHO])
				EndIf
			EndIf
			
			cString+= xValue
		Next
		
		AAdd(aLines, cString)
	Next
Return aLines


Method genExcel(cFile) Class PILA
	Local aLines:= {}
	Local nCount
	Local nField
	Local nRecord
	Local cString
	Local oTmpRecord
	Local oStructure
	Local cWorksht := "PILA"
	Local cTable	:= "Registro tipo 2"
	Local cCell 	:= ""

	Local oExcel := FWMSEXCEL():New()
	oExcel:AddworkSheet(cWorksht)	
	oExcel:AddTable (cWorksht,cTable)
			
	For nCount:= 1 to Self:oRecords:GetCount()		
		cString:= ""
		oTmpRecord	:= Self:oRecords:GetItem(nCount):GetValue()
		nRecord		:= Self:oRecords:GetItem(nCount):GetKey()
		oStructure	:= Self:GetStructure(Self:nFileType, nRecord)	
		
		IF nCount > 1
			IF nCount == 2 
				For nField:= 1 To oStructure:GetCount()
					cCell := strZero(nField,2) + "-" + oStructure:GetValue(nField)[5]
					oExcel:AddColumn(cWorksht,cTable,cCell,1,1)
				Next nField
		 	EndIF
		 	
			For nField:= 1 To oStructure:GetCount()
	
				xValue:= oTmpRecord:GetItem( oStructure:GetKey(nField) )			
				aFieldStruct:= oStructure:GetValue(nField)
				
				IF Len(aFieldStruct) >= PILA_FORMATO
					xValue:= Eval(aFieldStruct[PILA_FORMATO], xValue, aFieldStruct[PILA_TAMANHO])
				Else
					If ValType(xValue) == "C"
						xValue:= PadR(xValue, aFieldStruct[PILA_TAMANHO])
												
					ElseIf ValType(xValue) == "N"
						xValue:= StrZero(xValue, aFieldStruct[PILA_TAMANHO])
						
					ElseIf ValType(xValue) == "D"
						xValue:= DTOS(xValue)
						
					ElseIf ValType(xValue) == "L"
						xValue:= IIF(xValue, "T", "F")
						
					ElseIf ValType(xValue) == "U"
						xValue:= Space(aFieldStruct[PILA_TAMANHO])
						
					EndIf
				EndIf
				
				AADD(aLines,xValue)
			Next nField
			
			oExcel:AddRow(cWorksht,cTable,aLines)
			aLines := {}
		EndIF
	Next
	
	oExcel:Activate()
	oExcel:GetXMLFile(cFile)
	conout("Archivo Generado Exitosamente.")
Return aLines

/// <summary>
/// 	
/// </summary>
/// <param name="nFile"></param>
/// <param name="nRecord"></param>
/// <returns></returns>
Method GetStructure(nFile, nRecord) Class PILA
	Local oStructure:= HashTable():New()
	
	If (nFile == 1)
		//				Campo	Tamanho	Inicio	Final	Tipo	Descrição
		oStructure:Add( "1",	{200,	  1,	200,	"A",	STR0027} )
		oStructure:Add( "2",	{  2,	201,	202,	"A",	STR0028} )
		oStructure:Add( "3",	{ 16,	203,	218,	"A",	STR0029} )
		oStructure:Add( "4",	{  1,	219,	219,	"N",	STR0030} )
		oStructure:Add( "5",	{ 10,	220,	229,	"A",	STR0031} )
		oStructure:Add( "6",	{ 40,	230,	269,	"A",	STR0032} )
		oStructure:Add( "7",	{  1,	270,	270,	"A",	STR0033} )
		oStructure:Add( "8",	{  1,	271,	271,	"N",	STR0034} )
		oStructure:Add( "9",	{  1,	272,	272,	"A",	STR0035} )
		oStructure:Add("10",	{  1,	273,	273,	"A",	STR0036} )
		oStructure:Add("11",	{ 40,	274,	313,	"A",	STR0037} )
		oStructure:Add("12",	{  3,	314,	316,	"A",	STR0038} )
		oStructure:Add("13",	{  2,	317,	318,	"A",	STR0039} )
		oStructure:Add("14",	{  4,	319,	322,	"A",	STR0040} )
		oStructure:Add("15",	{ 10,	323,	332,	"A",	STR0041} )
		oStructure:Add("16",	{ 10,	333,	342,	"A",	STR0042} )
		oStructure:Add("17",	{ 60,	343,	402,	"A",	STR0043} )
		oStructure:Add("18",	{ 16,	403,	418,	"A",	STR0044} )
		oStructure:Add("19",	{  1,	419,	419,	"A",	STR0045} )
		oStructure:Add("20",	{  2,	420,	421,	"A",	STR0046} )
		oStructure:Add("21",	{ 20,	422,	441,	"A",	STR0047} )
		oStructure:Add("22",	{ 30,	442,	471,	"A",	STR0048} )
		oStructure:Add("23",	{ 20,	472,	491,	"A",	STR0049} )
		oStructure:Add("24",	{ 30,	492,	521,	"A",	STR0050} )
		oStructure:Add("25",	{ 10,	522,	531,	"A",	STR0051} )
		oStructure:Add("26",	{  1,	532,	532,	"N",	STR0052} )
		oStructure:Add("27",	{ 10,	533,	542,	"A",	STR0053} )
		oStructure:Add("28",	{  2,	543,	544,	"A",	STR0054} )
		oStructure:Add("29",	{  7,	545,	551,	"N",	STR0055} )
		oStructure:Add("30",	{  2,	552,	552,	"N",	STR0056} )
		oStructure:Add("31",	{  10,	553,	554,	"A",	STR0054} )
		oStructure:Add("32",	{  2,	555,	556,	"A",	STR0055} )
		oStructure:Add("33",	{  1,	553,	554,	"A",	STR0181} )
		oStructure:Add("34",	{  1,	555,	556,	"A",	STR0182} )
	Else
		Do Case
			Case (nRecord == 0)
			//				Campo	Tamanho	Inicio	Final	Tipo	Descrição
				oStructure:Add( "1",	{200,	  1,	200,	"A",	STR0027} )
				oStructure:Add( "2",	{  2,	201,	202,	"A",	STR0028} )
				oStructure:Add( "3",	{ 16,	203,	218,	"A",	STR0029} )
				oStructure:Add( "4",	{  1,	219,	219,	"N",	STR0030} )
				oStructure:Add( "5",	{ 10,	220,	229,	"A",	STR0031} )
				oStructure:Add( "6",	{ 40,	230,	269,	"A",	STR0032} )
				oStructure:Add( "7",	{  1,	270,	270,	"A",	STR0033} )
				oStructure:Add( "8",	{  1,	271,	271,	"N",	STR0034} )
				oStructure:Add( "9",	{  1,	272,	272,	"A",	STR0035} )
				oStructure:Add("10",	{  1,	273,	273,	"A",	STR0036} )
				oStructure:Add("11",	{ 40,	274,	313,	"A",	STR0037} )
				oStructure:Add("12",	{  3,	314,	316,	"A",	STR0038} )
				oStructure:Add("13",	{  2,	317,	318,	"A",	STR0039} )
				oStructure:Add("14",	{  4,	319,	322,	"A",	STR0040} )
				oStructure:Add("15",	{ 10,	323,	332,	"A",	STR0041} )
				oStructure:Add("16",	{ 10,	333,	342,	"A",	STR0042} )
				oStructure:Add("17",	{ 60,	343,	402,	"A",	STR0043} )
				oStructure:Add("18",	{ 16,	403,	418,	"A",	STR0044} )
				oStructure:Add("19",	{  1,	419,	419,	"A",	STR0045} )
				oStructure:Add("20",	{  2,	420,	421,	"A",	STR0046} )
				oStructure:Add("21",	{ 20,	422,	441,	"A",	STR0047} )
				oStructure:Add("22",	{ 30,	442,	471,	"A",	STR0048} )
				oStructure:Add("23",	{ 20,	472,	491,	"A",	STR0049} )
				oStructure:Add("24",	{ 30,	492,	521,	"A",	STR0050} )
				oStructure:Add("25",	{ 10,	522,	531,	"A",	STR0051} )
				oStructure:Add("26",	{  1,	532,	532,	"N",	STR0052} )
				oStructure:Add("27",	{ 10,	533,	542,	"A",	STR0053} )
				oStructure:Add("28",	{  2,	543,	544,	"A",	STR0054} )
				oStructure:Add("29",	{  7,	545,	551,	"N",	STR0055} )
				oStructure:Add("30",	{  2,	552,	552,	"N",	STR0056} )
				oStructure:Add("31",	{  10,	553,	554,	"A",	STR0054} )
				oStructure:Add("32",	{  2,	555,	556,	"A",	STR0055} )
				oStructure:Add("33",	{  1,	553,	554,	"A",	STR0181} )
				oStructure:Add("34",	{  1,	555,	556,	"A",	STR0182} )
					
			Case (nRecord == 1)
				oStructure:Add(  "1",	{  2,	  1,	  2,	"N",	STR0061} )
				oStructure:Add( "2A",	{  1,	  3,	  3,	"N",	STR0062} )
				oStructure:Add( "2B",	{  4,	  4,	  7,	"N",	STR0063} )
				oStructure:Add(  "3",	{200,	  8,	207,	"A",	STR0064} )
				oStructure:Add(  "4",	{  2,	208,	209,	"A",	STR0065} )
				oStructure:Add(  "5",	{ 16,	210,	225,	"A",	STR0066} )
				oStructure:Add(  "6",	{  1,	226,	226,	"N",	STR0067} )
				oStructure:Add(  "7",	{  1,	227,	227,	"A",	STR0068} )
				oStructure:Add(  "8",	{ 10,	228,	237,	"N",	STR0069} )
				oStructure:Add(  "9",	{ 10,	238,	247,	"A",	STR0070} )
				oStructure:Add( "10",	{  1,	248,	248,	"A",	STR0071} )
				oStructure:Add( "11",	{ 10,	249,	258,	"A",	STR0072} )
				oStructure:Add( "12",	{ 40,	259,	298,	"A",	STR0073} )
				oStructure:Add( "13",	{  6,	299,	304,	"A",	STR0074} )
				oStructure:Add( "14",	{  7,	305,	311,	"A",	STR0075} )
				oStructure:Add( "15",	{  7,	312,	318,	"A",	STR0076} )
				oStructure:Add( "16",	{ 10,	319,	328,	"N",	STR0077} )
				oStructure:Add( "17",	{ 10,	329,	338,	"A",	STR0078} )
				oStructure:Add( "18",	{  5,	339,	343,	"N",	STR0079} )
				oStructure:Add( "19",	{ 12,	344,	355,	"N",	STR0080} )
				oStructure:Add( "20",	{  2,	356,	356,	"N",	STR0081} )
				oStructure:Add( "21",	{  2,	357,	358,	"N",	STR0082} )
			Case (nRecord == 2)
				//				Campo	Tamanho	Inicio	Final	Tipo	Descrição
				oStructure:Add(  "1",	{  2,	  1,	  2,	"N",	STR0083} ) // "Tipo de Registro"
				oStructure:Add(  "2",	{  5,	  3,	  7,	"N",	STR0085} ) // "Secuencia" 
				oStructure:Add(  "3",	{  2,	  8,	  9,	"A",	STR0086} ) // "Tipo de documento del cotizante" 
				oStructure:Add(  "4",	{ 16,	 10,	 25,	"A",	STR0087} ) // "No. Identificacion"
				oStructure:Add(  "5",	{  2,	 26,	 27,	"N",	STR0088} ) // "Tipo cotizante"
				oStructure:Add(  "6",	{  2,	 28,	 29,	"N",	STR0089} ) // "Subtipo cotizante"
				oStructure:Add(  "7",	{  1,	 30,	 30,	"A",	STR0090} ) // "Extranjero no obligado a pagar pension"
				oStructure:Add(  "8",	{  1,	 31,	 31,	"A",	STR0091} ) // "Colombiano residente en el exterior"
				oStructure:Add(  "9",	{  2,	 32,	 33,	"N",	STR0092} ) // "Código del Departamento de la ubicación laboral"
				oStructure:Add( "10",	{  3,	 34,	 36,	"N",	STR0084} ) // "Código del Municipio de residencia de la ubicación laboral"
				oStructure:Add( "11",	{ 20,	 37,	 56,	"A",	STR0093} ) // "1o. Apellido"
				oStructure:Add( "12",	{ 30,	 57,	 86,	"A",	STR0094} ) // "2do. Apellido"
				oStructure:Add( "13",	{ 20,	 87,	106,	"A",	STR0095} ) // "1o. Nombre"
				oStructure:Add( "14",	{ 30,	107,	136,	"A",	STR0096} ) // "2do. Nombre"
				oStructure:Add( "15",	{  1,	137,	137,	"A",	STR0097} ) // "ING: Ingresos"
				oStructure:Add( "16",	{  1,	138,	138,	"A",	STR0098} ) // "RET: Retiro"
				oStructure:Add( "17",	{  1,	139,	139,	"A",	STR0099} ) // "TDE: Traslado de otra EPS"
				oStructure:Add( "18",	{  1,	140,	140,	"A",	STR0100} ) // "TAE: Traslado A otra EPS"
				oStructure:Add( "19",	{  1,	141,	141,	"A",	STR0101} ) // "TDP: Traslado de otra AFP"
				oStructure:Add( "20",	{  1,	142,	142,	"A",	STR0102} ) // "TAP: Traslado a otra AFP"
				oStructure:Add( "21",	{  1,	143,	143,	"A",	STR0103} ) // "VSP: Variacion de salario permanente"
				oStructure:Add( "22",	{  1,	144,	144,	"A",	STR0104} ) // "Correcciones"
				oStructure:Add( "23",	{  1,	145,	145,	"A",	STR0105} ) // "VST: Variacion salario transitoria"
				oStructure:Add( "24",	{  1,	146,	146,	"A",	STR0106} ) // "SLN: Suspension temporal del contrato de trabajo, licencia no remunerada o comision de servicios"
				oStructure:Add( "25",	{  1,	147,	147,	"A",	STR0107} ) // "IGE: Incapacidad temporal por enfermedad general"
				oStructure:Add( "26",	{  1,	148,	148,	"A",	STR0108} ) // "LMA: Licencia maternidad o paternidad"
				oStructure:Add( "27",	{  1,	149,	149,	"A",	STR0109} ) // "VAC - LR: Vacaciones Licencia Remunerada"
				oStructure:Add( "28",	{  1,	150,	150,	"A",	STR0110} ) // "AVP: Aporte Voluntario"
				oStructure:Add( "29",	{  1,	151,	151,	"A",	STR0111} ) // "VCT: Variacion centros de trabajo"
				oStructure:Add( "30",	{  2,	152,	153,	"N",	STR0112} ) // "IRP: Incapacidad por accidente de trabajo o enfermedad profesional"
				oStructure:Add( "31",	{  6,	154,	159,	"A",	STR0113} ) // "Código de la AFP a la cual pertenece el afiliado"
				oStructure:Add( "32",	{  6,	160,	165,	"A",	STR0114} ) // "Código de la AFP a la cual se traslada el afiliado"
				oStructure:Add( "33",	{  6,	166,	171,	"A",	STR0115} ) // "Código EPS o EOC a la cual pertenece el afiliado"
				oStructure:Add( "34",	{  6,	172,	177,	"A",	STR0116} ) // "Código EPS actual (cuando cambia en periodo)"
				oStructure:Add( "35",	{  6,	178,	183,	"A",	STR0117} ) // "Codigo CCF"
				oStructure:Add( "36",	{  2,	184,	185,	"N",	STR0118} ) // "No. dias cotizados para pension obligatoria"
				oStructure:Add( "37",	{  2,	186,	187,	"N",	STR0119} ) // "No. Dias cotizados para salud"
				oStructure:Add( "38",	{  2,	188,	189,	"N",	STR0120} ) // "No. Dias cotizados para riesgos profesionales"
				oStructure:Add( "39",	{  2,	190,	191,	"N",	STR0121} ) // "No. Dias cotizados para CCF"
				oStructure:Add( "40",	{  9,	192,	200,	"N",	STR0122} ) // "Salario basico"
				oStructure:Add( "41",	{  1,	201,	201,	"A",	STR0123} ) // "Salario integral"
				oStructure:Add( "42",	{  9,	202,	210,	"N",	STR0124} ) // "IBC Pension"
				oStructure:Add( "43",	{  9,	211,	219,	"N",	STR0125} ) // "IBC Salud"
				oStructure:Add( "44",	{  9,	220,	228,	"N",	STR0126} ) // "IBC Riesgos profesionales"
				oStructure:Add( "45",	{  9,	229,	237,	"N",	STR0127} ) // "IBC CCF"
				oStructure:Add( "46",	{  7,	238,	244,	"N",	STR0128, {|nVal, nSize| StrZero(nVal, nSize, nSize-2) }} ) // "Tarifa de aporte pensiones"
				oStructure:Add( "47",	{  9,	245,	253,	"N",	STR0129} ) // "Aporte cotizacion obligatoria"
				oStructure:Add( "48",	{  9,	254,	262,	"N",	STR0130} ) // "Aporte voluntario afiliado al fondo de pensiones obligatorias"
				oStructure:Add( "49",	{  9,	263,	271,	"N",	STR0131} ) // "Cotizacion voluntaria del aportante al fondo de pensiones obligatorias"
				oStructure:Add( "50",	{  9,	272,	280,	"N",	STR0132} ) // "Total cotización Pensiones"
				oStructure:Add( "51",	{  9,	281,	289,	"N",	STR0133} ) // "Aportes a FSP Solidaridad"
				oStructure:Add( "52",	{  9,	290,	298,	"N",	STR0134} ) // "Aportes a FSP Subsistencia"
				oStructure:Add( "53",	{  9,	299,	307,	"N",	STR0135} ) // "Valor no retenido por aportes voluntarios"
				oStructure:Add( "54",	{  7,	308,	314,	"N",	STR0136, {|nVal, nSize| StrZero(nVal, nSize, nSize-2) }} ) // "Tarifa salud"
				oStructure:Add( "55",	{  9,	315,	323,	"N",	STR0137} ) // "Cotizaciones obligatorias a salud"
				oStructure:Add( "56",	{  9,	324,	332,	"N",	STR0138} ) // "Valor de la UPC adicional"
				oStructure:Add( "57",	{ 15,	333,	347,	"A",	STR0139} ) // "No. de autorizacion de incapacidad general"
				oStructure:Add( "58",	{  9,	348,	356,	"N",	STR0140} ) // "Valor de la incapacidad EG"
				oStructure:Add( "59",	{ 15,	357,	371,	"A",	STR0141} ) // "No. autorizacion de la licencia maternidad o paternidad"
				oStructure:Add( "60",	{  9,	372,	380,	"N",	STR0142} ) // "Valor de la licencia maternidad o paternidad"
				oStructure:Add( "61",	{  9,	381,	389,	"N",	STR0143, {|nVal, nSize| StrZero(nVal, nSize, nSize-2) } } ) // "Tarifa de aportes a Riesgos Laborales"
				oStructure:Add( "62",	{  9,	390,	398,	"N",	STR0144} ) // "Centro de trabajo: CT"
				oStructure:Add( "63",	{  9,	399,	407,	"N",	STR0145} ) // "Cotización obligatoria a Riesgos Laborales"
				oStructure:Add( "64",	{  7,	408,	414,	"N",	STR0146, {|nVal, nSize| StrZero(nVal, nSize, nSize-2) }} ) // "Tarifa aportes CCF"
				oStructure:Add( "65",	{  9,	415,	423,	"N",	STR0147} ) // "Valor aporte CCF"
				oStructure:Add( "66",	{  7,	424,	430,	"N",	STR0148, {|nVal, nSize| StrZero(nVal, nSize, nSize-2) }} ) // "Tarifa aporte SENA"
				oStructure:Add( "67",	{  9,	431,	439,	"N",	STR0149} ) // "Valor aporte SENA"
				oStructure:Add( "68",	{  7,	440,	446,	"N",	STR0150, {|nVal, nSize| StrZero(nVal, nSize, nSize-2) }} ) // "Tarifa aporte ICBF"
				oStructure:Add( "69",	{  9,	447,	455,	"N",	STR0152} ) // "Valor aporte ICBF"
				oStructure:Add( "70",	{  7,	456,	462,	"N",	STR0151, {|nVal, nSize| StrZero(nVal, nSize, nSize-2) }} ) // "Tarifa aporte ESAP"
				oStructure:Add( "71",	{  9,	463,	471,	"N",	STR0153} ) // "Valor aporte ESAP"
				oStructure:Add( "72",	{  7,	472,	478,	"N",	STR0154, {|nVal, nSize| StrZero(nVal, nSize, nSize-2) }} ) // "Tarifa aporte MEN"
				oStructure:Add( "73",	{  9,	479,	487,	"N",	STR0155} ) // "Valor aporte MEN"
				oStructure:Add( "3A",	{  2,	488,	489,	"A",	STR0156} ) // 74- "Tipo de documento del cotizante principal"
				oStructure:Add( "4A",	{ 16,	490,	505,	"A",	STR0157} ) // 75- "Número de identificación del cotizante principal"
				oStructure:Add( "74",	{  1,	506,	506,	"A",	STR0158} ) // 76- "Cotizante exento del pago de aporte de parafiscales. Ley 1607 de 2012."
				oStructure:Add( "75",	{  6,	507,	512,	"A",	STR0159} ) // 77- "Codigo de la administradora de riesgos de trabajo a la que pertenece el afiliado."
				oStructure:Add( "76",	{  1,	513,	513,	"A",	STR0160} ) // 78- "Clase de riesgo a que pertenece el filiado."
				oStructure:Add( "77",	{  1,	514,	514,	"A",	STR0163} ) // 79- "Indicador tarifa especial pensiones"
				oStructure:Add( "78",	{  10,	515,	524,	"A",	STR0164} ) // 80- "Fecha de ingreso"
				oStructure:Add( "79",	{  10,	525,	534,	"A",	STR0165} ) // 81- "Fecha de retiro"
				oStructure:Add( "80",	{  10,	535,	544,	"A",	STR0166} ) // 82- "Fecha Inicio VSP"
				oStructure:Add( "81",	{  10,	545,	554,	"A",	STR0167} ) // 83- "Fecha Inicio SLN"
				oStructure:Add( "82",	{  10,	555,	564,	"A",	STR0168} ) // 84- "Fecha Fin SLN"
				oStructure:Add( "83",	{  10,	565,	574,	"A",	STR0169} ) // 85- "Fecha inicio IGE"
				oStructure:Add( "84",	{  10,	575,	584,	"A",	STR0170} ) // 86- "Fecha fin IGE"
				oStructure:Add( "85",	{  10,	585,	594,	"A",	STR0171} ) // 87- "Fecha inicio LMA"
				oStructure:Add( "86",	{  10,	595,	604,	"A",	STR0172} ) // 88- "Fecha fin LMA"
				oStructure:Add( "87",	{  10,	605,	614,	"A",	STR0173} ) // 89- "Fecha inicio VAC - LR"
				oStructure:Add( "88",	{  10,	615,	624,	"A",	STR0174} ) // 90- "Fecha fin VAC – LR"
				oStructure:Add( "89",	{  10,	625,	634,	"A",	STR0175} ) // 91- "Fecha inicio VCT"
				oStructure:Add( "90",	{  10,	635,	644,	"A",	STR0176} ) // 92- "Fecha fin VCT"
				oStructure:Add( "91",	{  10,	645,	654,	"A",	STR0177} ) // 93- "Fecha inicio IRL"
				oStructure:Add( "92",	{  10,	655,	664,	"A",	STR0178} ) // 94- "Fecha fin IRL"
				oStructure:Add( "93",	{  9,	665,	673,	"N",	STR0179} ) // 95- "IBC otros parafiscales diferentes a CCF"
				oStructure:Add( "94",	{  3,	674,	676,	"N",	STR0180} ) // 96- "Numero de horas laboradas"
				oStructure:Add( "95",	{  10,	677,	686,	"A",	STR0183} ) // 97- "NO USADO"
							
			Case (nRecord == 3)
				oStructure:Add( "1",	{  2,	  1,	  2,	"N",	"Tipo de Registro"} )
				oStructure:Add( "2",	{  5,	  3,	  7,	"N",	"Sequencia"} )
				oStructure:Add( "3",	{  6,	  8,	 13,	"A",	"Còdigo da Administradora de Pensões"} )
				oStructure:Add( "4",	{ 16,	 14,	 29,	"A",	"Número de Identificação da Administradora de Pensão"} )
				oStructure:Add( "5",	{  1,	 30,	 30,	"N",	"Dígito de verificação da Administradora de Pensão"} )
				oStructure:Add( "6",	{ 10,	 31,	 40,	"N",	"Valor Total contribuições obrigatórias reportadas"} )
				oStructure:Add( "7",	{ 10,	 41,	 50,	"N",	"Valor Total contribuições voluntárias realizadas pelos afiliados"} )
				oStructure:Add( "8",	{ 10,	 51,	 60,	"N",	"Valor Total contribuições voluntárias realizadas pelo aportante"} )
				oStructure:Add( "9",	{ 10,	 61,	 70,	"N",	"Valor Total Aportes a Fundo de Solidariedade Pensional Subconta de Solidariedade"} )
				oStructure:Add("10",	{ 10,	 71,	 80,	"N",	"Valor Total Aportes a Fundo de Solidariedade Pensional Subconta de Subsistencia"} )
				oStructure:Add("11",	{  4,	 81,	 84,	"N",	"Número de dias de mora liquidados"} )
				oStructure:Add("12",	{ 10,	 85,	 94,	"N",	"Valor juros de mora sobre o valor total das contribuições do período liquidado"} )
				oStructure:Add("13",	{ 10,	 95,	104,	"N",	"Valor juros de mora sobre o valor total aporte Fundo de Solidariedade Pensional Subconta de Solidariedade"} )
				oStructure:Add("14",	{ 10,	105,	114,	"N",	"Valor juros de mora sobre o valor total aporte Fundo de Solidariedade Pensional Subconta de Subsistencia"} )
				oStructure:Add("15",	{ 10,	115,	124,	"N",	"TOTAL A PAGAR A ADMINISTRADORA"} )
				oStructure:Add("16",	{  6,	125,	130,	"N",	"Total de afiliados por Administradora"} )
			Case (nRecord == 4)
				oStructure:Add( "1",	{  2,	  1,	  2,	"N",	"Tipo de Registro"} )
				oStructure:Add( "2",	{  5,	  3,	  7,	"N",	"Sequencia"} )
				oStructure:Add( "3",	{  6,	  8,	 13,	"A",	"Código da Administradora de Saúde"} )
				oStructure:Add( "4",	{ 16,	 14,	 29,	"A",	"Numero de Identificação (NIT) da EPS ou EOC"} )
				oStructure:Add( "5",	{  1,	 30,	 30,	"N",	"Dígito de Verificação da EPS ou EOC"} )
				oStructure:Add( "6",	{ 10,	 31,	 40,	"N",	"Valor total contribuição obrigatória recolhidas para essa entidade"} )
				oStructure:Add( "7",	{ 10,	 41,	 50,	"N",	"Valor total UPC adicionais aportadas a essa administradora"} )
				oStructure:Add( "8",	{ 15,	 51,	 65,	"A",	"Número da autorização do pagamento das incapacidades"} )
				oStructure:Add( "9",	{ 10,	 66,	 75,	"N",	"Valor total das incapacidades pagas"} )
				oStructure:Add("10",	{ 15,	 76,	 90,	"A",	"Número da autorização de desconto das licenças maternidade"} )
				oStructure:Add("11",	{ 10,	 91,	100,	"N",	"Valor total das licenças maternidade ou paternidade"} )
				oStructure:Add("12",	{ 10,	101,	110,	"N",	"Valor líquido aportes contribuidos"} )
				oStructure:Add("13",	{  4,	111,	114,	"N",	"Número de dias de mora liquidados"} )
				oStructure:Add("14",	{ 10,	115,	124,	"N",	"Valor juros de mora, contribuições obrigatórias"} )
				oStructure:Add("15",	{ 10,	125,	134,	"N",	"Valor juros de mora, UPC adicionais"} )
				oStructure:Add("16",	{ 10,	135,	144,	"N",	"Subtotal aportes contribuidos"} )
				oStructure:Add("17",	{ 10,	145,	154,	"N",	"Subtotal aportes UPC adicionais"} )
				oStructure:Add("18",	{ 10,	155,	164,	"N",	"Número do formulário único ou planilha integrada inicial objeto de saldo a favor do empregador"} )
				oStructure:Add("19",	{ 10,	165,	174,	"N",	"Valor do saldo a favor do período anterior correspondente a contribuição obrigatória"} )
				oStructure:Add("20",	{ 10,	175,	184,	"N",	"Valor do saldo a favor do período anterior da UPC adicional"} )
				oStructure:Add("21",	{ 10,	185,	194,	"N",	"Total a pagar por contribuição obrigatória"} )
				oStructure:Add("22",	{ 10,	195,	204,	"N",	"Total a pagar por UPC adicional"} )
				oStructure:Add("23",	{ 10,	205,	214,	"N",	"TOTAL A PAGAR À ADMINISTRADORA"} )
				oStructure:Add("24",	{ 10,	215,	224,	"N",	"Valor fundo de solidariedade e garantia FOSYGA"} )
				oStructure:Add("25",	{  6,	225,	230,	"N",	"Total de afiliados por Administradora"} )
			Case (nRecord == 5)
				oStructure:Add( "1",	{  2,	  1,	  2,	"N",	"Tipo de Registro"} )
				oStructure:Add( "2",	{  5,	  3,	  7,	"N",	"Sequencia"} )
				oStructure:Add( "3",	{  6,	  8,	 13,	"A",	"Còdigo ARP"} )
				oStructure:Add( "4",	{ 16,	 14,	 29,	"A",	"Número de Identificação da ARP"} )
				oStructure:Add( "5",	{  1,	 30,	 30,	"N",	"Dígito de verificação da Administradora de Pensão"} )
				oStructure:Add( "6",	{ 10,	 31,	 40,	"N",	"Valor Total contribuições reportadas a essa administradora"} )
				oStructure:Add( "7",	{ 15,	 41,	 55,	"A",	"Número de autorização do pagamento das incapacidades"} )
				oStructure:Add( "8",	{ 10,	 56,	 65,	"N",	"Valor total das incapacidades pagas"} )
				oStructure:Add( "9",	{ 10,	 66,	 75,	"N",	"Valor dos aportes pagos a outros sistemas"} )
				oStructure:Add("10",	{ 10,	 76,	 85,	"N",	"Valor líquido aportes contribuidos"} )
				oStructure:Add("11",	{  4,	 86,	 89,	"N",	"Número de dias de mora liquidados"} )
				oStructure:Add("12",	{ 10,	 90,	 99,	"N",	"Valor juros de mora sobre as contribuições obrigatórias"} )
				oStructure:Add("13",	{ 10,	100,	109,	"N",	"Subtotal aportes contribuidos"} )
				oStructure:Add("14",	{ 10,	110,	119,	"N",	"Número do formulário único ou planilha integrada inicial objeto de saldo a favor do empregador"} )
				oStructure:Add("15",	{ 10,	120,	129,	"N",	"Valor do saldo a favor do período anterior"} )
				oStructure:Add("16",	{ 10,	130,	139,	"N",	"TOTAL A PAGAR A ADMINISTRADORA"} )
				oStructure:Add("17",	{ 10,	140,	149,	"N",	"Fundo de Riscos Profissionais"} )
				oStructure:Add("18",	{  6,	150,	155,	"N",	"Total de afiliados por Administradora"} )
			Case (nRecord == 6)
				oStructure:Add( "1",	{  2,	  1,	  2,	"N",	"Tipo de Registro"} )
				oStructure:Add( "2",	{  5,	  3,	  7,	"N",	"Sequencia"} )
				oStructure:Add( "3",	{  6,	  8,	 13,	"A",	"Còdigo CCF"} )
				oStructure:Add( "4",	{ 16,	 14,	 29,	"A",	"Número de Identificação CCF"} )
				oStructure:Add( "5",	{  1,	 30,	 30,	"N",	"Dígito de verificação da CCF"} )
				oStructure:Add( "6",	{ 10,	 31,	 40,	"N",	"Valor aporte a essa Caixa de Compensação"} )
				oStructure:Add( "7",	{  4,	 41,	 44,	"N",	"Número de dias de mora liquidados"} )
				oStructure:Add( "8",	{ 10,	 45,	 54,	"N",	"Valor juros de mora sobre o aporte"} )
				oStructure:Add( "9",	{ 10,	 55,	 64,	"N",	"Total a pagar a Caixa"} )
				oStructure:Add("10",	{  6,	 65,	 70,	"N",	"Total de afiliados por CCF"} )
			Case (nRecord == 7)				
				oStructure:Add( "1",	{  2,	  1,	  2,	"N",	"Tipo de Registro"} )
				oStructure:Add( "2",	{  5,	  3,	  7,	"N",	"Sequencia"} )
				oStructure:Add( "3",	{ 16,	  8,	 23,	"A",	"Número de Identificação SENA"} )
				oStructure:Add( "4",	{  1,	 24,	 24,	"N",	"Dígito de verificação SENA"} )
				oStructure:Add( "5",	{ 10,	 25,	 34,	"N",	"Valor aporte parafiscal"} )
				oStructure:Add( "6",	{  4,	 35,	 38,	"N",	"Número de dias de mora liquidados"} )
				oStructure:Add( "7",	{ 10,	 39,	 48,	"N",	"Valor juros de mora sobre o aporte"} )
				oStructure:Add( "8",	{ 10,	 49,	 58,	"N",	"Total a pagar SENA"} )
				oStructure:Add( "9",	{  6,	 59,	 64,	"N",	"Número de Pessoas"} )
			Case (nRecord == 8)
				oStructure:Add( "1",	{  2,	  1,	  2,	"N",	"Tipo de Registro"} )
				oStructure:Add( "2",	{  5,	  3,	  7,	"N",	"Sequencia"} )
				oStructure:Add( "3",	{ 16,	  8,	 23,	"A",	"Número de Identificação ICBF"} )
				oStructure:Add( "4",	{  1,	 24,	 24,	"N",	"Dígito de verificação da ICBF"} )
				oStructure:Add( "5",	{ 10,	 25,	 34,	"N",	"Valor contribuições"} )
				oStructure:Add( "6",	{  4,	 35,	 38,	"N",	"Número de dias de mora liquidados"} )
				oStructure:Add( "7",	{ 10,	 39,	 48,	"N",	"Valor juros de mora"} )
				oStructure:Add( "8",	{ 10,	 49,	 58,	"N",	"Total a pagar"} )
				oStructure:Add( "9",	{  6,	 59,	 64,	"N",	"Número de Pessoas"} )
			Case (nRecord == 9)
				oStructure:Add( "1",	{  2,	  1,	  2,	"N",	"Tipo de Registro"} )
				oStructure:Add( "2",	{  5,	  3,	  7,	"N",	"Sequencia"} )
				oStructure:Add( "3",	{ 16,	  8,	 23,	"A",	"Número de Identificação ESAP"} )
				oStructure:Add( "4",	{  1,	 24,	 24,	"N",	"Dígito de verificação da ESAP"} )
				oStructure:Add( "5",	{ 10,	 25,	 34,	"N",	"Valor a pagar"} )
				oStructure:Add( "6",	{  4,	 35,	 38,	"N",	"Número de dias de mora liquidados"} )
				oStructure:Add( "7",	{ 10,	 39,	 48,	"N",	"Valor juros de mora"} )
				oStructure:Add( "8",	{ 10,	 49,	 58,	"N",	"Total a pagar"} )
			Case (nRecord == 10)
				oStructure:Add( "1",	{  2,	  1,	  2,	"N",	"Tipo de Registro"} )
				oStructure:Add( "2",	{  5,	  3,	  7,	"N",	"Sequencia"} )
				oStructure:Add( "3",	{ 16,	  8,	 23,	"A",	"Número de Identificação MEN"} )
				oStructure:Add( "4",	{  1,	 24,	 24,	"N",	"Dígito de verificação da MEN"} )
				oStructure:Add( "5",	{ 10,	 25,	 34,	"N",	"Valor a pagar"} )
				oStructure:Add( "6",	{  4,	 35,	 38,	"N",	"Número de dias de mora liquidados"} )
				oStructure:Add( "7",	{ 10,	 39,	 48,	"N",	"Valor juros de mora"} )
				oStructure:Add( "8",	{ 10,	 49,	 58,	"N",	"Total a pagar"} )
			Case (nRecord == 11)
				oStructure:Add( "1",	{  2,	  1,	  2,	"N",	"Tipo de Registro"} )
				oStructure:Add( "2",	{ 10,	  3,	 12,	"N",	"Total a pagar a Pensões"} )
				oStructure:Add( "3",	{ 10,	 13,	 22,	"N",	"Total a pagar a Saúde"} )
				oStructure:Add( "4",	{ 10,	 23,	 32,	"N",	"Total a pagar a Riscos Profissionais"} )
				oStructure:Add( "5",	{ 10,	 33,	 42,	"N",	"Total a pagar a Caixas de Compensação"} )
				oStructure:Add( "6",	{ 10,	 43,	 52,	"N",	"Total a pagar a SENA"} )
				oStructure:Add( "7",	{ 10,	 53,	 62,	"N",	"Total a pagar a ICBF"} )
				oStructure:Add( "8",	{ 10,	 63,	 72,	"N",	"Total a pagar a ESAP"} )
				oStructure:Add( "9",	{ 10,	 73,	 82,	"N",	"Total a pagar a Ministério da Educação"} )
				oStructure:Add("10",	{ 10,	 83,	 92,	"N",	"Total a pagar"} )
				oStructure:Add("11",	{ 10,	 93,	102,	"N",	"Número de Administradoras de Pensões reportadas"} )
				oStructure:Add("12",	{ 10,	103,	112,	"N",	"Número de EPS reportadas"} )
				oStructure:Add("13",	{ 10,	113,	122,	"N",	"Número de ARP reportadas"} )
				oStructure:Add("14",	{ 10,	123,	132,	"N",	"Número de CCF reportadas"} )		
		EndCase
	EndIf
Return oStructure
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fGetEmpl()ºAutor  ³ mayra.camargo      º Data ³  17/01/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene los empleados que tienes registros en SRC y SRD    º±±
±±º          ³ para el periodo, roteir y proceso seleccionado en params.  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºSintaxe   ³FgetEmpl(aPer)                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aPer := Array con los códigos de los periodos comprendidos  º±±
±±º          ³		en el mes y año dado en parámetro MV_PAR04 del grupo º±±
±±º          ³       de preguntas gp880f4                                 º±±
±±º          ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPER880 COLOMBIA                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FgetEmpl(aPer,cTipcot)
	Local aArea		:= GetArea()
	Local cAliasMov	:= GetNextAlias()
	Local nI 			:= 0
	Local cRotSRD		:= "% SRD." + rangeSX1("RD_ROTEIR",cProcedim) + " %"
	Local cRotSRC		:= "% SRC." + rangeSX1("RC_ROTEIR",cProcedim) + " %"
	Local cEmp		:= IIF(!Empty(cMats),"% AND SRA." + RANGESX1("RA_MAT",cMats) +  " %", "%%")
	Local cExpFils	:= "% SRA." + rangeSX1("RA_FILIAL",cFilSuc) + " %" 
	Local cExpPer		:= ""//"%"
	Local cExpProc 	:= "% SRA." + rangeSX1("RA_PROCES",cProcesso) + " %"

	Default cTipCot  := " "
	DEFAULT aPer 		:= {}
	//- Carregar somente os itens gerados pelo select

	If !Empty(cTipCot) 
		If cTipoPlan $ "E"
			cTipCot := "% SRA.RA_TIPCOT IN ('1 ','01','12','18','19','20','21','22','30','31','32','51','54','55') %" 
		ElseIf cTipoPlan $ "I"
			cTipCot := "% SRA.RA_TIPCOT IN ('3 ','03','33','41','42','43') %" 
		ElseIf cTipoPlan $ "Y"
			cTipCot := "% SRA.RA_TIPCOT IN ('3 ','03','16','34','35','36','52','53') %" 
		ElseIf cTipoPlan $ "S"
			cTipCot := "% SRA.RA_TIPCOT IN ('2 ','02') %" 
		ElseIf cTipoPlan $ "T"
			cTipCot := "% SRA.RA_TIPCOT IN ('47') %"
		ElseIf cTipoPlan $ "K"
			cTipCot := "% SRA.RA_TIPCOT IN ('23') %"
		ElseIf cTipoPlan $ "H"
			cTipCot := "% SRA.RA_TIPCOT IN ('4 ','04') %"
		EndIF		
	Else
		If cTipoPlan $ "E"
			cTipCot := "% SRA.RA_TIPCOT IN ('1 ','01','12','18','19','20','21','22','30','31','32','40','51','54','55') %" 
		ElseIf cTipoPlan $ "I"
			cTipCot := "% SRA.RA_TIPCOT IN ('3 ','03','33','40','41','42','43') %" 
		ElseIf cTipoPlan $ "Y"
			cTipCot := "% SRA.RA_TIPCOT IN ('3 ','03','16','34','35','36','40','52','53') %" 
		ElseIf cTipoPlan $ "S"
			cTipCot := "% SRA.RA_TIPCOT IN ('2 ','02','40') %" 
		ElseIf cTipoPlan $ "T"
			cTipCot := "% SRA.RA_TIPCOT IN ('47') %"
		ElseIf cTipoPlan $ "K"
			cTipCot := "% SRA.RA_TIPCOT IN ('23') %"
		ElseIf cTipoPlan $ "H"
			cTipCot := "% SRA.RA_TIPCOT IN ('4 ','04',) %"
		EndIF
	EndIF
	cExpPer :="% IN ("
	For nI := 1 to len(aPer)
		cExpPer += "'" + aPer[nI,1] + "'"
		
		If nI < len(aPer)
			cExpPer += ","
		End If
	Next nI	
	cExpPer+= ")%"

	If !(len(aPer) <> 0)
		cExpPer:= "% IN (' ') %"
	EndIF
	
	BeginSql alias cAliasMov
		SELECT SRA.*
		FROM %Table:SRA% SRA
		WHERE %exp:cExpFils%
			AND (SRA.RA_MAT IN (
			SELECT DISTINCT SRC.RC_MAT
			FROM %table:SRC% SRC
			WHERE   %exp:cRotSRC% AND SRC.RC_PERIODO %exp:cExpPer% AND SRC.%notDel%) OR
			SRA.RA_MAT IN (
			SELECT DISTINCT SRD.RD_MAT
			FROM %table:SRD% SRD
			WHERE %exp:cRotSRD% AND SRD.RD_PERIODO %exp:cExpPer% AND SRD.%notDel%)) %exp:cEmp% 
			AND %exp:cExpProc%
			AND %exp:cTipCot%
			AND SRA.RA_CIC <> ' '
			AND SRA.%notDel%	 
			ORDER BY SRA.RA_MAT
	EndSql

	RestArea(aArea)
Return cAliasMov

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPER880   ºAutor  ³ Equipe RH Inovacao º Data ³  22/09/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Geracao de arquivo magnetico - PILA                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Microsiga Protheus 11                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fCodFolRCM()

	Local aArea		:= GetArea()
	Local cFields 	:= ""	
	Local cAliasQry	:= GetNextAlias()
	Local cIdsAgr	:= ""
	Local cFil		:= ""
	
	cFil := RANGESX1("RD_FILIAL", cFilSuc)
	cFil := iif(Empty(cFilSuc),"% SRD.RD_FILIAL='" + xFilial("SRD") +"' %","% SRD." + cFil+ " %")
	
	cFiltroSrd := 	"% SRM." + alltrim(RANGESX1("RM_PROCES", cProcesso))
	cFiltroSrd += " AND SRM." + AllTrim(RANGESX1("RM_CALCULO", cProcedim)) + " %" 
  
	cFields := "% RM_VERBA %"
	BeginSql alias cAliasQry
	   SELECT %exp:cFields%
	   FROM %table:SRM% SRM  
       WHERE SRM.%notDel%
       AND SRM.RM_LEEAUS ='1'
       AND %exp:cFiltroSrd% 
	EndSql
		
	While (cAliasQry)->(!Eof())
		cIdsAgr += (cAliasQry)->RM_VERBA + "','"
		(cAliasQry)->(DBSkip())
	EndDo
	(cAliasqry)->(dbCloseArea())
	RestArea(aArea)
	cIdsAgr := substr(cIdsAgr, 1, len(cIdsAgr)-3)
	
Return(cIdsAgr)
