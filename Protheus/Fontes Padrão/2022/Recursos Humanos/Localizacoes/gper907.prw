#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPER907.CH" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GPER907  ³ Autor ³ Alex Sandro Fagundes	³ Data ³ 22/09/10	         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emite SRI - Informe de Rendimentos do Equador			             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPER907()                                                	         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico - Equador                                              	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³Chamado    ³Motivo da Alteracao 		                     ³±±
±±³Kelly S.    ³27/10/11³TDUJOF     ³Ajuste na picture de campos de valor.  		 ³±±
±±³Kelly S.    ³27/10/11³TEIHIO     ³Ajuste na impressao do importo retido. 		 ³±±
±±³Emerson Camp³23/02/12³TEIHIO     ³Ajuste na montagem da query para padronizar com ³±±
±±³            ³        ³           ³o DB2. 		                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function GPER907()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis Locais (Basicas)                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cAno    		:= ""
	Local cFiltro		:= "" 

	//-Define o numero da linha de impressao como 0
	SetPrc(0,0)
	Private aReturn  := {STR0011, 1,STR0012, 1, 1, 1, "",1 }	//"Zebrado"###"Administra‡„o"
	Private cDesc1 := STR0003		//"Emissao Formulario 107."
	Private cDesc2 := STR0004		//"Ser  impresso de acordo com os parametros solicitados pelo"
	Private cDesc3 := STR0005		//"usuario."
	Private aOrd   := {STR0006,STR0007,STR0008,STR0009,STR0010} //"Matricula"###"C.Custo"###"Nome"###"Chapa"###"C.Custo + Nome"
	Private oPrint   
	Private li      := _PROW()	
	Private cString := ""
	Private wnrel
	Private cPerg    	:= "GPER907"
	Private Titulo 		:= STR0003		//"SRI - FORMULARIO 107"
	Private cTamanho 	:= "G"
	Private cDtEntrega	:= ""

	cString	:= "RH6"	
	wnrel	:= "GPER907"            //Nome Default do relatorio em Disco
	wnrel	:= SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,cTamanho)
	
	If nLastKey == 27
		Return
	EndIf

	SetDefault(aReturn,cString,,,cTamanho,1)	
	
	If nLastKey == 27
		Return
	EndIf

	Pergunte("GPER907",.F.)

	cAno := AllTrim(Transform(MV_PAR02,"9999"))
	cDtEntrega	:= StrZero(Year(MV_PAR04),4) + StrZero(Month(MV_PAR04),2) + StrZero(Day(MV_PAR04),2)

	cAliasRH6 := "RH6"
	#IFDEF TOP
	
		//--Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
		MakeSqlExpr("GPER907")

		//-- Adiciona no filtro o parametro tipo Range
		cFiltro := "%"
		 
		cFiltro += "RH6.RH6_ANORET = '"+cAno+"'"
		//-- Filial
		If !Empty(MV_PAR01)
			cFiltro += " AND " + MV_PAR01 
		EndIf
		
		//-- MATRICULA
		If !Empty(MV_PAR03)			
			cFiltro += " AND " + MV_PAR03 
		EndIf		
        cFiltro += "%"
        
    	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Consiste o filtro incluido pelo usuario -bt.personalizar     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	  	
		cOrdem := "%RH6.RH6_FILIAL, RH6.RH6_MAT%" 
		
	
		//-Apaga o Alias SRH6
		If Select(cAliasRH6) > 0
	  		(cAliasRH6)->( dbclosearea() )
	 	EndIf
		//dbSelectArea(cAliasSRA)
		BeginSql alias cAliasRH6
    	SELECT RH6.*
  			FROM %table:RH6% RH6
			WHERE  RH6.%notDel%  AND
			   	   %exp:cFiltro%
			ORDER BY %exp:cOrdem%
		EndSql
 	
	#Endif
	

	DbSelectArea( cAliasRH6 )
	dbgotop()	

	If !Eof()
		While RH6->( !Eof() )
			If RH6->RH6_ANORET == cAno
//				If RH6->RH6_FILIAL $ cFilRh6 .AND. RH6->RH6_MAT $ cMatRh6
					MsAguarde( fDetalhe(), OemToAnsi(STR0013))
//				EndIf
			EndIf		
			RH6->( dbSkip() )
		EndDo
	EndIf

	Set Device To Screen
	If aReturn[5] = 1
		Set Printer To
		Commit
		ourspool(wnrel)
	Endif
    
	//-Apaga o Alias SRH6
	If Select(cAliasRH6) > 0
  		(cAliasRH6)->( dbclosearea() )
 	EndIf
	MS_FLUSH()

Return() 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fDetalhe  ³ Autor ³ Alex Sandro Fagundes  ³ Data ³ 24/09/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO Cabecalho Form Continuo SRI                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCabec()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fDetalhe()			// Cabecalho do SRI
	Local cExer			:= ""
	Local cExerCom		:= ""
	
	cExer := RH6->RH6_ANORET
	cExerCom :=	SubStr(cDtEntrega,1,1) + " " + SubStr(cDtEntrega,2,1) + " " + SubStr(cDtEntrega,3,1) + " " + SubStr(cDtEntrega,4,1) + " "
	cExerCom +=	SubStr(cDtEntrega,5,1) + " " + SubStr(cDtEntrega,6,1) + " "
	cExerCom +=	SubStr(cDtEntrega,7,1) + " " + SubStr(cDtEntrega,8,1)
	
	// Cabecalho
	@ PROW(),PCOL() PSAY ""
	LI +=3
	@ LI,28 PSAY SubStr(cExer,1,1) + " " + SubStr(cExer,2,1) + " " + SubStr(cExer,3,1) + " " + SubStr(cExer,4,1)
	@ LI,54 PSAY cExerCom
	LI += 3
	@ LI,01 PSAY SM0->M0_CGC
	@ LI,30 PSAY SM0->M0_NOME
	LI += 3
	@ LI,01 PSAY RH6->RH6_IDRET
	@ LI,30 PSAY RH6->RH6_NOME

	//Liquidacion del imposto
	LI +=3
	@ LI,55 PSAY Transform(RH6->RH6_SALAR,"@E 9,999,999.99")		//SUELDOS Y SALARIOS
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_COMISS,"@E 9,999,999.99") 		//SOBRESUELDOS, COMISIONES, BONOS Y OTRAS REMUNERACIONES GRAVADAS
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_D13SAL,"@E 9,999,999.99")		//DÉCIMO TERCER SUELDO (Informativo)
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_D14SAL,"@E 9,999,999.99")		//DÉCIMO CUARTO SUELDO (Informativo)
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_FONDO,"@E 9,999,999.99")		//FONDO DE RESERVA (Informativo)
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_PARUTI,"@E 9,999,999.99")		//PARTICIPACIÓN UTILIDADES
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_VRESCI,"@E 9,999,999.99")		//DESAHUCIO Y OTRAS REMUNERACIONES QUE NO CONSTITUYEN RENTA GRAVADA (Informativo)
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_APIESS,"@E 9,999,999.99")		//(-) APORTE PERSONAL IESS (únicamente pagado por el empleado)
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_DEDVIV,"@E 9,999,999.99")		//(-) DEDUCCIÓN GASTOS PERSONALES - VIVIENDA
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_DEDSAL,"@E 9,999,999.99")		//(-) DEDUCCIÓN GASTOS PERSONALES - SALUD
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_DEDEDU,"@E 9,999,999.99")		//(-) DEDUCCIÓN GASTOS PERSONALES - EDUCACIÓN
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_DEDALI,"@E 9,999,999.99")		//(-) DEDUCCIÓN GASTOS PERSONALES - ALIMENTACIÓN
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_DEDVES,"@E 9,999,999.99")		//(-) DEDUCCIÓN GASTOS PERSONALES - VESTIMENTA
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_DESCAP,"@E 9,999,999.99")		//(-) REBAJA POR DISCAPACIDAD
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_TERIDA,"@E 9,999,999.99")		//(-) REBAJA POR TERCERA EDAD
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_INRETE,"@E 9,999,999.99")		//IMPUESTO A LA RENTA ASUMIDO POR ESTE EMPLEADOR
	LI +=2
	@ LI,55 PSAY Transform(RH6->RH6_SUBTOT,"@E 9,999,999.99")		//SUBTOTAL ESTE EMPLEADOR                                 
																	//(301+303+311-315-317-319-321-323-325-327-329+331)
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_NUMMES,"@E 999")				//NÚMERO DE MESES TRABAJADOS CON ESTE EMPLEADOR
	LI += 5
	@ LI,55 PSAY Transform(RH6->RH6_OUTEMP,"@E 9,999,999.99")		//INGRESOS GRAVADOS GENERADOS CON OTROS EMPLEADORES
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_OUTDED,"@E 9,999,999.99")		//(-) DEDUCCIÓN GASTOS PERSONALES CONSIDERADAS POR OTROS EMPLEADORES
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_OUTBXS,"@E 9,999,999.99")		//(-) OTRAS REBAJAS CONSIDERADAS POR OTROS EMPLEADORES
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_BASIMP,"@E 9,999,999.99")		//BASE IMPONIBLE TOTAL ANUAL
	LI ++															//(351+401-403-405)
	@ LI,55 PSAY Transform(RH6->RH6_IMPCAU,"@E 9,999,999.99")		//IMPUESTO A LA RENTA CAUSADO
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_IMPRET,"@E 9,999,999.99")		//VALOR DEL IMPUESTO RETENIDO POR ESTE EMPLEADOR
	LI ++
	@ LI,55 PSAY Transform(RH6->RH6_OUTIMP,"@E 9,999,999.99")		//VALOR DEL IMPUESTO RETENIDO POR EMPLEADORES ANTERIORES DURANTE EL PERÍODO

	Li += 7

Return Nil
