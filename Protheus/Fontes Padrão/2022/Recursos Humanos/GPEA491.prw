#Include 'Protheus.ch'
#INCLUDE 'PONCALEN.CH'
#INCLUDE "GPEA491.CH"

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±                        
±±ºPrograma    ³GPEA491   ³Autor  ³ Flavio Correa         ³ Data ³  30/04/15           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao   ³Rotina de Geracao de Turnos para Periodos    	                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador ³ Data   ³ FNC            ³  Motivo da Alteracao                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºFlavio Corr ³30/04/15³TSGDSN          ³Inclusão de arquivo                          º±±
±±ºAllyson M   ³07/08/15³TSURZN          ³Ajuste p/ montar um calendario padrao quando º±±
±±º            ³        ³                ³nao possuir tabela do ponto 				   º±±
±±ºGabriel A.  ³06/02/17³MRH-6292        ³Ajuste para não valorizar cReg e cSeq quando º±±
±±º            ³        ³                ³for chamada do cadastro de período.          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEA491()
Local bProcesso		:= {|oSelf| GPMProcessa(oSelf)}
Local cPergCal  
Local cCadastro		:= OemToAnsi(STR0001)	//"Cadastro de Turnos para periodos"
Local cDescricao	:= OemToAnsi(STR0002)	// "Cadastro de Turnos para os períodos definidos nos parametros"

Private cTpCalend 	:=  SuperGetMv( "MV_TPCALEND" , .F. , "1" ,  )	 // 1 = Usa calendario Analitico , 2 = Usa calendario Sintetico  
Private cQtdeDPer 	:=  SuperGetMv( "MV_DIASPER" , .F. , "1" ,  )	 // 1 = Usa qtde de dias do mes do periodo , 2 = Usa sempre 30   		

cPergCal 	:= "GPEA491"
Pergunte(cPergCal,.F.)
tNewProcess():New( "GPEA491", cCadastro, bProcesso, cDescricao, cPergCal, , , , , .T., .T.  )  

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GPMProcessa   ³ Autor ³ Flavio S. Correa    ³ Data ³ 04/05/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processamento  -           						 	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function GPMProcessa(oSelf)
Local aArea			:= GetArea()
Local aCalend		:= {}
Local cQry			:= GetNextAlias() 
Local cQTurno		:= ""
Local cWhere		:= ""
Local cWTurno		:= ""
Local nReg			:= 0
Local lCpBloq	 	:= (SR6->(FieldPos("R6_MSBLQL")) > 0)

Private aRCFbkp 	:= {}
Private aRCGColsBkp := {}  

Private aRCGNotFields		:= {}
Private aColsRCGDef		:= {}
Private aRCFCols		:= {}
Private aRCGAllHeader	:= {}
Private aRCFHeader		:= {}
Private aRCFMaster		:= {}
Private aRCGMaster		:= {}
Private aRCFColsRec	 := {}    
Private aRCGColsRec	 := {}   
Private aRCGColsAll  := {}
Private cFilRFQ		 := xFilial("RFQ")   
Private cGp490Mes    := ""
Private cGp490Ano    := ""
Private cGp490Per    := ""
Private cGp490NPg    := ""
Private cGp490DIn	  := CtoD("//")		
Private cGp490DFi    := CtoD("//")                     
Private dRFQDtIni
Private dRFQDtFim
Private lGp490 		 := .T.
Private cProcesso	:= ""

If Empty(MV_PAR01)
	Help(" ", 1, "Help",, OemToAnsi(STR0003), 1, 0) //"Processo deve ser informado"
	return 
EndIf

If Empty(MV_PAR02)
	Help(" ", 1, "Help",, OemToAnsi(STR0004), 1, 0) //"Periodo deve ser informado"
	return 
EndIf

If Empty(MV_PAR03)
	Help(" ", 1, "Help",, OemToAnsi(STR0005), 1, 0) //"Turno deve ser informado"
	return 
EndIf

NotRCG()

MakeSqlExpr( "GPEA491" )


If !Empty(MV_PAR02)
	cWhere := "% " + MV_PAR02 + " AND %"
EndIf

If !Empty(MV_PAR03)
	cWTurno += " " + MV_PAR03 + " AND " 
EndIf

If lCpBloq
	cWTurno += "R6_MSBLQL <> '1' AND "
EndIf

If !Empty(cWTurno)
	cWTurno := "% " + cWTurno + "%"
EndIf

BeginSql alias cQry
	SELECT *
	FROM %table:RFQ% RFQ
	WHERE  %exp:cWhere%
		   RFQ.%notDel% 		   
		   AND RFQ_FILIAL = %xfilial:RFQ%
		   AND RFQ_PROCES = %exp:MV_PAR01%
		   
EndSql

DbSelectArea(cQry)
Count To nReg  
dbSelectArea(cQry)   
(cQry)->( DbGoTop() )

oSelf:SetRegua1(nReg)
oSelf:SaveLog( STR0006 + " - " + STR0007 )//"Cadastro de Turnos"## "inicio processamento"
While !(cQry)->(Eof())
	cQTurno	:= GetNextAlias()
	
	BeginSql alias cQTurno
	SELECT *
	FROM %table:SR6% SR6
	WHERE  %exp:cWTurno%
		   R6_FILIAL = %xfilial:SR6%
		   AND  SR6.%notDel%
	EndSql
	oSelf:SaveLog( STR0008 +(cQry)->RFQ_PERIOD)//"Processando periodo : " 
	
	While !(cQTurno)->(Eof())
		oSelf:IncRegua1(OemToAnsi(STR0008) + "  " + (cQry)->RFQ_PERIOD + " - " + (cQTurno)->R6_TURNO) ////"Processando periodo : " 
	
		If Len(aRCFCols) > 0
			
			aRCFCols := aClone(aRCFbkp)
			aRCGColsAll := aClone(aRCGColsBkp)
			
			nPosRCF_Tnotra := GdFieldPos( "RCF_TNOTRA"	, aRCFHeader ) 
			aRCFCols[1, nPosRCF_Tnotra] := (cQTurno)->R6_TURNO	// Codigo generico para todos os turnos
			
		Else
			Gp491MontaCols((cQry)->RFQ_PROCES,(cQry)->RFQ_PERIOD,(cQTurno)->R6_TURNO,stod((cQry)->RFQ_DTINI),stod((cQry)->RFQ_DTFIM),(cQry)->RFQ_NUMPAG)		
		EndIf
		oSelf:SaveLog( space(3) + STR0009 +(cQTurno)->R6_TURNO) //"Processando Turno : "
		
		aRCFMaster		:= {}
		aRCGMaster		:= {}
		aCalend := A491Calend(stod((cQry)->RFQ_DTINI),stod((cQry)->RFQ_DTFIM),(cQTurno)->R6_TURNO,(cQry)->RFQ_NUMPAG,(cQry)->RFQ_PERIOD,(cQry)->RFQ_MES,(cQry)->RFQ_ANO,(cQry)->RFQ_PROCES)

		(cQTurno)->(dbSkip())
	EndDo
	(cQTurno)->(dbCloseArea())
	
	(cQry)->(dbSkip())	
EndDo
(cQry)->(dbCloseArea())
oSelf:SaveLog( STR0006 + " - " + STR0010) //"Cadastro de Turnos"##"fim processamento"

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A491Calend   ³ Autor ³ Flavio S. Correa    ³ Data ³ 04/05/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta calendario           						 	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
static Function A491Calend(dPerIni,dPerFim,cTurno,cNumPag,cPeriodo,cMes,cAno,cProc)
Local aCalend		:= {}
Local nPosTnoTra	:=  GdFieldPos( "RCG_TNOTRA" ,  aRCGAllHeader )

dbSelectArea("RCF")
dbSetOrder(4)//RCF_FILIAL, RCF_PER, RCF_SEMANA, RCF_ANO, RCF_MES, RCF_PROCES, RCF_ROTEIR, RCF_TNOTRA, RCF_DTINI, RCF_DTFIM, RCF_MODULO, R_E_C_D_E_L_ 

cKey := xFilial("RCF") + cPeriodo+cNumPag+cAno+cMes+cProc+space(3)+cTurno+DtoS(dPerIni) + DtoS(dPerFim) + cModulo

If !RCF->(MsSeek(cKey , .F.))
	//Cria calendario para a data
	
	cGp490Per 	:= cPeriodo
	cGp490Mes	:= cMes
	cGp490Ano 	:= cAno 
	cGp490NPg 	:= cNumPag
	cGp490DIn 	:= dPerIni
	cGp490DFi 	:= dPerFim			
	dRFQDtIni 	:= dPerIni
	dRFQDtFim 	:= dPerFim
	cProcesso	:= cProc
	
	aColsRCGDef := A491Turno(dPerIni,dPerFim,cTurno)
	
	If Len(aColsRCGDef) > 0
		//calcula dias para gravar na RCF
		fCalCDias() 
		aRCGColsAll := aClone(aRCGMaster)
		aeval(aRCGColsAll,{|x| x[nPosTnoTra] := cTurno})
		Begin Transaction
			// Gravacao dos registros de turno  
			fGravaRCF(aRCFMaster[1],,Len(aRCFHeader))	
	 		If cTpCalend == "1" 
	 			fGravaRCG()
	 		EndIf
		End Transaction
	EndIf
EndIf

Return aCalend 

Function A491Turno(dPerIni,dPerFim,cTurno,aRCGNot)
Local aTabCalend	:= {}
Local nI			:= 1
Local nTam			:= 0 
Local cTipo			:= ""
Local nPos			:= 0
Local aHeader		:= IIf(isIncallstack("GPEA400"),aRCGHeader,aRCGAllHeader)
Local nPosDiaMes	:=  GdFieldPos( "RCG_DIAMES" ,  aHeader )
Local nPosTipdia	:=  GdFieldPos( "RCG_TIPDIA" ,  aHeader )
Local nPosVTrans	:=  GdFieldPos( "RCG_VTRANS" ,  aHeader )
Local nPosvRefei	:=  GdFieldPos( "RCG_VREFEI" ,  aHeader )
Local nPosvAlime	:=  GdFieldPos( "RCG_VALIM"  ,  aHeader )		
Local nPosHrsTra	:=  GdFieldPos( "RCG_HRSTRA" ,  aHeader )
Local nPosHrsDsr	:=  GdFieldPos( "RCG_HRSDSR" ,  aHeader )	
Local nPosTnoTra	:=  GdFieldPos( "RCG_TNOTRA" ,  aHeader )
Local aCOlRCG 		:= {}




DEFAULT aRCGNot := aRCGNotFields 
	CriaCalend(		dPerIni	 	,;	//01 -> Data Inicial do Calendario
				   	dPerFim		,;	//02 -> Data Final do Calendario
			   		cTurno		,;	//03 -> Turno de Trabalho
			   		""			,;	//04 -> Sequencia de Turno
			   		NIL			,;	//05 -> Tabela de Horario Padrao
			   		@aTabCalend	,;	//06 -> Calendario de Marcacoes
			   		cFilAnt    	,;	//07 -> Filial do Funcionario
			   		NIL   		,;	//08 -> Matricula do Funcionario
			   		NIL   		,;	//09 -> Centro de Custo do Funcionario
					NIL			,;	//10 -> Array com as Trocas de Turno
					NIL			,;	//11 -> Array com Todas as Excecoes do Periodo
					NIL			,;	//12 -> Se executa Query para a Montagem da Tabela Padrao
					.F.			,;	//13 -> Se executa a funcao se sincronismo do calendario
					NIL			 ;	//14 -> Se Forca a Criacao de Novo Calendario
			  	  )
	
	// Monta aCols com as informacoes do calendario
	aCOlRCG	:= 	fNewAcols( 	"1"			 ,;				// Tipo da Geracao 
								aRCGNot,;				// Campos Visuais 
								0,;							// Numero de campos usados - RCG
								dPerIni,;					// Data inicial para preenchimento do RCG
							   	dPerFim,;					// Data final para preenchimento do RCG
								8; 					// Horas dia
					 		 )		

	If Len(aTabCalend) > 0 
		nTam := Len(aCOlRCG)
		
		For nI := 1 To nTam
			nHoras := 0
			aeval(aTabCalend,{|x| iif(x[CALEND_POS_DATA_APO]==aCOlRCG[nI][nPosDiaMes],nHoras+=x[CALEND_POS_HRS_TRABA],0)})
			
			nPos := ascan(aTabCalend,{|x| x[CALEND_POS_DATA_APO] == aCOlRCG[nI][nPosDiaMes] .and. x[CALEND_POS_TIPO_MARC] == "1E"})
			
			If nPosTipdia > 0
				//Tipo do Dia (1=Trabalhado;2=Nao Trabalhado;3=DSR;4=Feriado
				Do Case
					Case (aTabCalend[nPos][CALEND_POS_TIPO_DIA] == "S")
						cTipo := "1"
					Case (aTabCalend[nPos][CALEND_POS_TIPO_DIA] == "D")
						cTipo := "3"
					Case (aTabCalend[nPos][CALEND_POS_TIPO_DIA] == "F")
						cTipo := "4"
					Case (aTabCalend[nPos][CALEND_POS_TIPO_DIA] == "N")
						cTipo := "2"
					Case (aTabCalend[nPos][CALEND_POS_TIPO_DIA] == "C")
						cTipo := "2"
					OtherWise
						cTipo := "1"
				EndCase
				If fFeriado( xFilial("SP3") ,aCOlRCG[nI][nPosDiaMes],,,) 
					cTipo := "4"
				EndIf
				aCOlRCG[nI][nPosTipdia] := cTipo
			EndIf
			If nPosTnoTra > 0
				aCOlRCG[nI][nPosTnoTra] := cTurno
			EndIf
			If nPosVTrans > 0
				If cTipo == "1" //trabalhado
					aCOlRCG[nI][nPosVTrans] := "1"// Utiliza Vale Transporte  (1=Sim; 2=Nao)
				Else
					aCOlRCG[nI][nPosVTrans] := "2"// Utiliza Vale Transporte  (1=Sim; 2=Nao)
				Endif
			EndIf
			
			If nPosvRefei > 0
				If cTipo == "1" //trabalhado
					aCOlRCG[nI][nPosvRefei] := "1"// Utiliza Vale Transporte  (1=Sim; 2=Nao)
				Else
					aCOlRCG[nI][nPosvRefei] := "2"// Utiliza Vale Transporte  (1=Sim; 2=Nao)
				Endif
			EndIf
			
			If nPosvAlime > 0
				If cTipo == "1" //trabalhado
					aCOlRCG[nI][nPosvAlime] := "1"// Utiliza Vale Transporte  (1=Sim; 2=Nao)
				Else
					aCOlRCG[nI][nPosvAlime] := "2"// Utiliza Vale Transporte  (1=Sim; 2=Nao)
				Endif
			EndIf
							
			If nPosHrsTra > 0
				If cTipo == "1" //trabalhado
					aCOlRCG[nI][nPosHrsTra] := nHoras
					aCOlRCG[nI][nPosHrsDsr] := 0
				Else
					aCOlRCG[nI][nPosHrsTra] := 0
				Endif
			EndIf
							
			If nPosHrsDsr > 0
				If cTipo == "3" .Or. cTipo == "4" //DSR e Feriado.
					If(nHoras != 0)
						aCOlRCG[nI][nPosHrsDsr] := nHoras
					Endif
						aCOlRCG[nI][nPosHrsTra] := 0
				Else
					aCOlRCG[nI][nPosHrsDsr] := 0
				EndIf
			EndIf
		
		Next nI
	EndIf
	
Return aCOlRCG

Static Function Gp491MontaCols(cProcesso,cPeriodo,cTurno,dPerIni,dPerFim,cNumPag)      
// Variaveis utilizadas para RCF
Local aRCFNotFields		:= {}
Local aRCFVirtGd		:= {}
Local aRCFVisualGd		:= {}
Local nRCFUsado			:= 0  
Local nPosRCF_Tnotra	:= 0
// Variaveis utilizadas para RCG
Local aRCGColsRec		:= {} 
Local aRCGVirtGd		:= {}
Local aRCGVisualGd		:= {}  
Local nRCGUsa			:= 0
// Variaveis auxiliares
Local cKey				:= ""	
Local lRetOK 			:= .T.      

	
	// Monta componentes RCF 
	aAdd( aRCFNotFields , "RCF_FILIAL"  )
	aAdd( aRCFNotFields , "RCF_PER"     )
	aAdd( aRCFNotFields , "RCF_PROCES"  )
	aAdd( aRCFNotFields , "RCF_ROTEIR"  )
	aAdd( aRCFNotFields , "RCF_SEMANA"  ) 
		
	aRCFCols := RCF->( GdMontaCols(@aRCFHeader,;  		// 01 -> Array com os Campos do Cabecalho da GetDados 
									@nRCFUsado,;		// 02 -> Numero de Campos em Uso 
									@aRCFVirtGd,;		// 03 -> [@]Array com os Campos Virtuais 
									@aRCFVisualGd,;		// 04 -> [@]Array com os Campos Visuais 
									"RCF",;				// 05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols 
									@aRCFNotFields,;	// 06 -> Opcional, Campos que nao Deverao constar no aHeader 
									@aRCFColsRec,;		// 07 -> [@]Array unidimensional contendo os Recnos 
									"RCH",;				// 08 -> Alias do Arquivo Pai 
									Nil,;				// 09 -> Chave para o Posicionamento no Alias Filho 
									Nil,;				// 10 -> Bloco para condicao de Loop While 
									Nil,;				// 11 -> Bloco para Skip no Loop While 
									Nil,;				// 12 -> Se Havera o Elemento de Delecao no aCols  
									Nil,;				// 13 -> Se cria variaveis Publicas 
									Nil,;				// 14 -> Se Sera considerado o Inicializador Padrao 
									Nil,;				// 15 -> Lado para o inicializador padrao 
									Nil,;				// 16 -> Opcional, Carregar Todos os Campos 
									Nil,;				// 17 -> Opcional, Nao Carregar os Campos Virtuais 
									Nil,;				// 18 -> Opcional, Utilizacao de Query para Selecao de Dados 
									.F.,;				// 19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP ) - utilizado com o parametro 10 
									.F.,;				// 20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP ) - utilizado com o parametro 11
									.T.,;				// 21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
									Nil,;				// 22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
									Nil,;				// 23 -> Verifica se Deve Checar se o campo eh usado
									Nil,;				// 24 -> Verifica se Deve Checar o nivel do usuario
									Nil,;				// 25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
									Nil,;				// 26 -> [@]Array que contera as chaves conforme recnos
									Nil,;				// 27 -> [@]Se devera efetuar o Lock dos Registros
									Nil,;				// 28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
							        Nil,;				// 29 -> Numero maximo de Locks a ser efetuado
									.T.;				// 30 -> Utiliza Numeracao na GhostCol
								);
					   )
	
	// Conter o valor @@@ no Turno de Trabalho
	nPosRCF_Tnotra := GdFieldPos( "RCF_TNOTRA"	, aRCFHeader ) 
	aRCFCols[1, nPosRCF_Tnotra] := cTurno	// Codigo generico para todos os turnos
	cKey:= xFilial("RCG")+cPeriodo+cNumPag+cProcesso+"   "+DtoS(dPerIni) + DtoS(dPerFim) + cModulo
	   
	// Monta componentes RCG 
	RCG->( dbSetOrder( RetOrdem( "RCG" , "RCG_FILIAL+RCG_PROCES+RCG_PER+RCG_SEMANA+RCG_ROTEIR+RCG_TNOTRA" ) ) )
	aRCGColsAll := GdMontaCols( ;
									@aRCGAllHeader,;	//01 -> Array com os Campos do Cabecalho da GetDados
					   	 			@nRCGUsa,;			//02 -> Numero de Campos em Uso
					 				@aRCGVirtGd,;		//03 -> [@]Array com os Campos Virtuais
					 				@aRCGVisualGd,;		//04 -> [@]Array com os Campos Visuais
					 				"RCG",;				//05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
					 				Nil,;				//06 -> Opcional, Campos que nao Deverao constar no aHeader
					 				@aRCGColsRec,;		//07 -> [@]Array unidimensional contendo os Recnos
	  								"RCG",;				//08 -> Alias do Arquivo Pai
	  				 				cKey,;				//09 -> Chave para o Posicionamento no Alias Filho
	  				 				Nil,;				//10 -> Bloco para condicao de Loop While
		  			 				Nil,;				//11 -> Bloco para Skip no Loop While
		  			 				.T.,;				//12 -> Se Havera o Elemento de Delecao no aCols
		  			 				Nil,;				//13 -> Se cria variaveis Publicas
		  			 				Nil,;				//14 -> Se Sera considerado o Inicializador Padrao
		  			 				Nil,;				//15 -> Lado para o inicializador padrao
		  			 				.T.,;				//16 -> Opcional, Carregar Todos os Campos
		  			 				Nil,;				//17 -> Opcional, Nao Carregar os Campos Virtuais
					 				Nil,;				//18 -> Opcional, Utilizacao de Query para Selecao de Dados
					 				.F.,;				//19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP )
					 				.F.,;				//20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP )
					 				.T.,;				//21 -> Carregar Coluna Fantasma
									Nil,;				//22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
									Nil,;				//23 -> Verifica se Deve Checar se o campo eh usado
									Nil,;				//24 -> Verifica se Deve Checar o nivel do usuario
									Nil,;				//25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
									Nil,;				//26 -> [@]Array que contera as chaves conforme recnos
									Nil,;				//27 -> [@]Se devera efetuar o Lock dos Registros
									Nil,;				//28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
							        Nil,;				//29 -> Numero maximo de Locks a ser efetuado
									.T.;				//30 -> Utiliza Numeracao na GhostCol
						 			) 

aRCFbkp := aClone(aRCFCols)
aRCGColsBkp := aClone(aRCGColsAll)  
         
Return( lRetOK )  

Static Function NotRCG()
	aRCGNotFields := {}
	aAdd( aRCGNotFields , "RCG_FILIAL"  )
	aAdd( aRCGNotFields , "RCG_TNOTRA"  )
	aAdd( aRCGNotFields , "RCG_PER"     )
	aAdd( aRCGNotFields , "RCG_SEMANA"  )	
	aAdd( aRCGNotFields , "RCG_PROCES"  )
	aAdd( aRCGNotFields , "RCG_ROTEIR"  )
	aAdd( aRCGNotFields , "RCG_MES"     )
	aAdd( aRCGNotFields , "RCG_ANO"     )

Return
