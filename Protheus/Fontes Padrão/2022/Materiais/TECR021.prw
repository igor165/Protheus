#Include "Rwmake.ch"
#Include "Protheus.ch"      
#Include "TOPCONN.ch"
#Include "TECR021.ch"
Static cAutoPerg := "TECR021"

//-------------------------------------------------------------------
/*/{Protheus.doc} TECR020
Monta as definiçoes do Relatorio de Check-In / Check-Out Gestão de Serviços

@author Cesar Bianchi
@since 14/08/2017
@version P12.1.20
/*/
//-------------------------------------------------------------------
Function TECR021()
	Local oReport := Nil
	Private cPerg	:= "TECR021" 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ PARAMETROS                                                             ³
	//³ MV_PAR01 : Data de ?                                                   ³
	//³ MV_PAR02 : Data ate?                                                   ³
	//³ MV_PAR03 : Atendente de ?                                              ³
	//³ MV_PAR04 : Atendente ate ?                                             ³
	//³ MV_PAR05 : Centro de custo de ?                                        ³
	//³ MV_PAR06 : Centro de custo ate ?                                       ³	
	//³ MV_PAR07 : Local de Atendimento de ?                                   ³
	//³ MV_PAR08 : Local de Atendimento  ate ?                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

	//Exibe dialog de perguntes ao usuario
	If !Pergunte(cPerg,.T.)
		Return nil
	EndIf

	//Pinta o relatorio a partir das perguntas escolhidas
	oReport := ReportDef()   
	oReport:PrintDialog()  
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} reportDef
Monta as definiçoes do relatorio de Relatorio de Check-In / Check-Out Gestão de Serviços

@author Cesar Bianchi
@since 14/08/2017
@version P12.1.20
@return  Nil
/*/
//-------------------------------------------------------------------------------------
Static Function ReportDef()
	
	Local cPerg		:= "TECR021"
	Local cTitulo 	:= STR0001 //"Relatorio de Check-In / Check-Out - Gestão de Serviços"
	Local oReport 	:= TReport():New(cPerg, cTitulo, cPerg , {|oReport| PrintReport(oReport)},STR0001)
	Local oSection1 := TRSection():New(oReport,STR0013,{"ABB","ABQ","ABS","AA1","SRA","TFF","TFL","TFJ","ADY","AD1","SB1","CN9","SRJ","SQ3","AC0","SR6"})	//"Check-Ins Registrados"

	//Define Propriedades do Relatorio (Cabeçalho, Orientação, Totais e SubTotais)
	oReport:ShowHeader()
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oSection1:SetTotalInLine(.F.)

	//Define colunas do relatorio
	TRCell():New(oSection1, "RA_MAT" 	, "SRA", OemToAnsi(STR0002) ,PesqPict('SRA',"RA_MAT")		,TamSX3("RA_MAT")[1]		,/*lPixel*/		,/*{|| code-block de impressao }*/)	//"Matricula RH"
	TRCell():New(oSection1, "AA1_CODTEC", "AA1", OemToAnsi(STR0003) ,PesqPict('AA1',"AA1_CODTEC")	,TamSX3("AA1_CODTEC")[1]	,/*lPixel*/		,/*{|| code-block de impressao }*/)	//"Código Atendente"
	TRCell():New(oSection1, "AA1_NOMTEC", "AA1", OemToAnsi(STR0004) ,PesqPict('AA1',"AA1_NOMTEC")	,TamSX3("AA1_NOMTEC")[1]	,/*lPixel*/		,/*{|| code-block de impressao }*/)	//"Nome Atendente"
	TRCell():New(oSection1, "ABS_DESCRI", "ABS", OemToAnsi(STR0006) ,PesqPict('ABS',"ABS_DESCRI")	,TamSX3("ABS_DESCRI")[1]	,/*lPixel*/		,/*{|| code-block de impressao }*/)	//"Descrição Local Atendimento"	
	TRCell():New(oSection1, "ABB_DTINI"	, "ABB", OemToAnsi(STR0007) ,PesqPict('ABB',"ABB_DTINI")	,TamSX3("ABB_DTINI")[1]		,/*lPixel*/		,/*{|| code-block de impressao }*/)	//"Data Inicial Posto"
	TRCell():New(oSection1, "ABB_HRINI"	, "ABB", OemToAnsi(STR0008) ,PesqPict('ABB',"ABB_HRINI")	,TamSX3("ABB_HRINI")[1]		,/*lPixel*/		,/*{|| code-block de impressao }*/)	//"Hora Inicial Posto"
	TRCell():New(oSection1, "ABB_HRCHIN", "ABB", OemToAnsi(STR0018) ,PesqPict('ABB',"ABB_HRCHIN")	,TamSX3("ABB_HRCHIN")[1]	,/*lPixel*/		,/*{|| code-block de impressao }*/)	//"Hora Check-In"	
	TRCell():New(oSection1, "ABB_DTFIM"	, "ABB", OemToAnsi(STR0009) ,PesqPict('ABB',"ABB_DTFIM")	,TamSX3("ABB_DTFIM")[1]		,/*lPixel*/		,/*{|| code-block de impressao }*/)	//"Data Final Posto"
	TRCell():New(oSection1, "ABB_HRFIM"	, "ABB", OemToAnsi(STR0010) ,PesqPict('ABB',"ABB_HRFIM")	,TamSX3("ABB_HRFIM")[1]		,/*lPixel*/		,/*{|| code-block de impressao }*/)	//"Hora Final Posto"
	TRCell():New(oSection1, "ABB_HRCOUT", "ABB", OemToAnsi(STR0019) ,PesqPict('ABB',"ABB_HRCOUT")	,TamSX3("ABB_HRCOUT")[1]	,/*lPixel*/		,/*{|| code-block de impressao }*/)	//"Hora Check-Out"
	TRCell():New(oSection1, "DIAFUNC"	, "   ", OemToAnsi(STR0022) ,"@!"							,3							,/*lPixel*/		,/*{|| code-block de impressao }*/)	//"Dia Normal de Trabalho"		
	
	//Define campos alinhados a esquerda
	oSection1:Cell("RA_MAT"):SetAlign("LEFT")
	oSection1:Cell("AA1_CODTEC"):SetAlign("LEFT")
	oSection1:Cell("AA1_NOMTEC"):SetAlign("LEFT")	
	oSection1:Cell("ABS_DESCRI"):SetAlign("LEFT")
	
	//Define campos alinhados ao centro
	oSection1:Cell("ABB_DTINI"):SetAlign("LEFT")
	oSection1:Cell("ABB_HRINI"):SetAlign("LEFT")	
	oSection1:Cell("ABB_HRCHIN"):SetAlign("LEFT")
	oSection1:Cell("ABB_DTFIM"):SetAlign("LEFT")
	oSection1:Cell("ABB_HRFIM"):SetAlign("LEFT")
	oSection1:Cell("ABB_HRCOUT"):SetAlign("LEFT")	
	
Return (oReport) 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Gera o relatorio de Check-In / Check-Out Gestão de Serviços

@author Cesar Bianchi
@since 14/08/2017
@version P12.1.20
@return  Nil
/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport(oReport)

	Local aArea		:= GetArea() 
	Local oSection1	:= oReport:Section(1)
	Local cAlias	:= GetNextAlias()
	Local aCalend	:= {}
	Local aHorPad	:= {}
	Local cDiaTrab	:= ""

	BEGIN REPORT QUERY oReport:Section(1)

		BeginSql alias cAlias
		
			SELECT SRA.RA_MAT, AA1.AA1_CODTEC, AA1.AA1_NOMTEC, ABS.ABS_LOCAL, ABS.ABS_DESCRI, ABB.ABB_DTINI, ABB.ABB_HRINI, ABB.ABB_HRCHIN, 
				ABB.ABB_DTFIM, ABB.ABB_HRFIM, ABB.ABB_HRCOUT, ABS.ABS_LATITU, ABS.ABS_LONGIT,
				ABB.ABB_LATIN, ABB.ABB_LONIN, ABB.ABB_LATOUT, ABB.ABB_LONOUT
			FROM %table:ABB% ABB
				JOIN %table:ABQ% ABQ
					ON ABQ.ABQ_FILIAL = %xfilial:ABQ%
				    AND ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM = ABB.ABB_IDCFAL
					AND ABQ.%notDel%				
				JOIN %table:ABS% ABS
					ON ABS.ABS_FILIAL = %xfilial:ABS%
					AND ABS.ABS_ENTIDA = '1'
					AND ABS.ABS_LOCAL = ABB.ABB_LOCAL
					AND ABS.%notDel%			
				JOIN %table:AA1% AA1
					ON AA1.AA1_FILIAL = %xfilial:AA1%
					AND AA1.AA1_CODTEC	=  ABB.ABB_CODTEC
					AND AA1.%notDel%				
				LEFT JOIN %table:SRA% SRA
					ON SRA.RA_FILIAL = %xfilial:SRA%
					AND SRA.RA_MAT = AA1.AA1_CDFUNC 
					AND SRA.%notDel%			
				LEFT JOIN %table:TFF% TFF
					ON TFF.TFF_FILIAL = %xfilial:TFF% 
				    AND TFF.TFF_COD = ABQ.ABQ_CODTFF
					AND TFF.TFF_CONTRT = ABQ.ABQ_CONTRT
					AND TFF.%notDel% 			
				LEFT JOIN %table:TFL% TFL
					ON TFL.TFL_FILIAL = %xfilial:TFL%
					AND TFL.TFL_CODIGO = TFF.TFF_CODPAI
					AND TFL.%notDel%			
				LEFT JOIN %table:TFJ% TFJ
					ON TFJ.TFJ_FILIAL = %xfilial:TFJ%
					AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI
					AND TFJ.%notDel%			
				LEFT JOIN %table:ADY% ADY 
					ON ADY.ADY_FILIAL = %xfilial:ADY%
					AND ADY.ADY_PROPOS = TFJ.TFJ_PROPOS
					AND ADY.ADY_PREVIS = TFJ.TFJ_PREVIS
					AND ADY.%notDel%			
				LEFT JOIN %table:AD1% AD1
					ON AD1.AD1_FILIAL = %xfilial:AD1%
					AND AD1.AD1_NROPOR = ADY.ADY_OPORTU			
					AND AD1.%notDel%			
				LEFT JOIN %table:SB1% SB1 
					ON SB1.B1_FILIAL = %xfilial:SB1%
					AND SB1.B1_COD = TFF.TFF_PRODUT
					AND SB1.%notDel%				
				LEFT JOIN %table:CN9% CN9
					ON CN9.CN9_FILIAL = %xfilial:CN9%
					AND CN9.CN9_NUMERO = TFJ.TFJ_CONTRT
					AND CN9.CN9_REVISA = TFJ.TFJ_CONREV
					AND CN9.CN9_REVATU = ' '
					AND CN9.%notDel%				
				LEFT JOIN %table:SRJ% SRJP
					ON SRJP.RJ_FILIAL = %xfilial:SRJ%
					AND SRJP.RJ_FUNCAO = TFF.TFF_FUNCAO
					AND SRJP.%notDel%			
				LEFT JOIN %table:SRJ% SRJF
					ON SRJF.RJ_FILIAL = %xfilial:SRJ%
					AND SRJF.RJ_FUNCAO = AA1.AA1_FUNCAO
					AND SRJF.%notDel%							
				LEFT JOIN %table:SQ3% SQ3
					ON SQ3.Q3_FILIAL = %xfilial:SQ3%
					AND SQ3.Q3_CARGO = TFF.TFF_CARGO
					AND SQ3.%notDel%				
				 LEFT JOIN %table:TDW% TDW 
					ON TDW.TDW_FILIAL = %xfilial:TDW%
					AND TDW.TDW_COD = TFF.TFF_ESCALA
					AND TDW.%notDel%					
				 LEFT JOIN %table:AC0% AC0
					ON AC0.AC0_FILIAL = %xfilial:AC0%
					AND AC0.AC0_CODIGO = TFF.TFF_CALEND
					AND AC0.%notDel%						
				 LEFT JOIN %table:SR6% SR6
					ON SR6.R6_FILIAL = %xfilial:SR6%
					AND SR6.R6_TURNO = TFF.TFF_TURNO
					AND SR6.%notDel%			
			WHERE ABB.ABB_FILIAL = %xfilial:ABB%
				 AND ABB.ABB_DTINI BETWEEN  %exp:MV_PAR01% AND %exp:MV_PAR02% 
				 AND ABB.ABB_CODTEC BETWEEN %exp:MV_PAR03% AND  %exp:MV_PAR04%
				 AND AA1.AA1_CC BETWEEN %exp:MV_PAR05% AND %exp:MV_PAR06%
				 AND ABB.ABB_LOCAL BETWEEN %exp:MV_PAR07%  AND %exp:MV_PAR08%
				AND ABB.%notDel%
				ORDER BY SRA.RA_MAT, ABB.ABB_DTINI, ABB.ABB_DTFIM, ABB.ABB_HRINI, ABB.ABB_HRFIM
		EndSql

	END REPORT QUERY oReport:Section(1)

	//Define tamanho da regua de processamento
	oReport:SetMeter((cAlias)->(RecCount()))

	//Monta a primeira secao do relatorio
	oSection1:Init()

	//Pinta cada registro da query de busca no relatorio
	dbSelectArea(cAlias)
	While (cAlias)->(!Eof())
		
		cDiaTrab := "Desconhecido"
		
		aHorPad := {}
		aCalend := {}
		If !(Empty((cAlias)->RA_MAT))
			dbSelectArea('SRA')
			SRA->(dbSetOrder(1))
			SRA->(dbSeek(xFilial('SRA')+(cAlias)->RA_MAT ))
	
			//Obtem a tabela de horarios padrao
			fTabTurno(@aHorPad) 
	
			//Obtem o calendario RH do Atendente
			CriaCalend(	(cAlias)->ABB_DTINI		,; //01 -> Data Inicial do Periodo
				 			(cAlias)->ABB_DTINI	,; //02 -> Data Final do Periodo
				 			SRA->RA_TNOTRAB	,; //03 -> Turno Para a Montagem do Calendario
				 			SRA->RA_SEQTURN	,; //04 -> Sequencia Inicial para a Montagem Calendario
				 			aHorPad			,; //05 -> Array Tabela de Horario Padrao
				 			@aCalend		,; //06 -> Array com o Calendario de Marcacoes
				 			xFilial('SRA')	)  //07 -> Filial para a Montagem da Tabela de Horario

		Else
			aCalend := {{"","","","","",""}}
		EndIf		 			
		
		//Imprime a linha
		If Len(aCalend) > 0 .and. Len(aCalend[1]) >= 6
			cDiaTrab := aCalend[1,6]
		Else
			cDiaTrab := "Desconhecido"
		EndIf
		oSection1:Cell("DIAFUNC"):SetValue(cDiaTrab)
		oSection1:PrintLine()

		//botao cancelar
		If oReport:Cancel()
			Exit
		EndIf

		//Incremento da regua
		oReport:IncMeter()

		//Proximo registro
		(cAlias)->(dbSkip())                                                          
	EndDo

	(cAlias)->(dbCloseArea())
	oSection1:Finish()
RestArea(aArea)
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPergTRp
Retorna o nome do Pergunte utilizado no relatório
Função utilizada na automação
@author Mateus Boiani
@since 31/10/2018
@return cAutoPerg, string, nome do pergunte
/*/
//-------------------------------------------------------------------------------------
Static Function GetPergTRp()

Return cAutoPerg

