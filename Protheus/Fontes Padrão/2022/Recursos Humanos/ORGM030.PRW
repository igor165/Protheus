#INCLUDE "PROTHEUS.CH"
#INCLUDE "ORGM030.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ORGM030  ³ Autor ³ Rogerio Ribeiro       ³ Data ³ 23/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carga dos postos a partir dos funcionarios                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ORGM030()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAORG                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³        ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Program.  ³ Data   ³ BOPS ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia C.³01/08/14³TQEIB9³Incluido o fonte da 11 para a 12 e efetuada ³±±
±±³          ³        ³      ³a limpeza.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ORGM030()
	Local aSays			:= {}		// Array de Mensagens da tela de parametros
	Local aButtons		:= {} 		// array locais de preferencia
	Local nOpca 		:= 0		// Variavel de opcao
	Local lEmpProc		:= SuperGetMV("MV_ORGCEMP",.F.,"N")=="S" //Processa todas as empreas?

	Private cCadastro 	:= STR0001	// Titulo da Tela ->"Carga dos Departamento"
	Private nRbtMovTam 	:= GetSx3Cache( "RBT_CODMOV" , "X3_TAMANHO" )
	/*
	VALIDAÇÃO DE COMPARTILHAMENTO DE TABELAS RCL E SQB
	*/
	If FindFunction("fVldCompt")
		If !fVldCompt()
			Return .F.
		EndIf
	EndIf	
	Pergunte("ORGM030", .F.)
	
	AADD(aSays, STR0002)	//"Este programa tem a finalidade de gerar a carga inicial"  
	AADD(aSays, STR0003)	//"dos postos a partir do cadastro de funcionarios"  	
	
	AADD(aButtons, {5, .T., {|| Pergunte("ORGM030", .T.) } } )
	AADD(aButtons, {1, .T., {|o| nOpca := 1, If(GpConfOK(), FechaBatch(), nOpca:=0) }} )
	AADD(aButtons, {2, .T., {|o| FechaBatch() }} )

	FormBatch(cCadastro, aSays, aButtons)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpca == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Seleciona os participante do Criterio e Visao                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Proc2BarGauge(	{|| BeginProcess(lEmpProc) }	,;	//Acao a ser Executada
						NIL							,;	//Titulo do Dialogo         
						NIL							,;	//Mensagem para a 1a. BarGauge 
						NIL 						,;	//Mensagem para a 2a. BarGauge
						.T.							,;	//Se habilitara o botao para "Abortar" o processo
						.T.							,;	//Se havera controle de estimativa de tempo na 1a. BarGauge
						.T.							,;	//Se havera conteole de estimativa de tempo na 2a. BarGauge
						lEmpProc					 ;	//Se ira mostrar a 2a. BarGauge / Caso parametro esteja para todas as empreas
					)
	EndIf
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ORGM30Processa³ Autor ³ Rogerio Ribeiro		³ Data ³ 23/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento da carga inicial dos postos					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ORGM30Processa(lEmpProc)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lEmpProc - Carga completa as empresas							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAORG														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BeginProcess(lEmpProc)
	Local nCountTime					// Laco For Next
	Local aEmp				:= {}		// Array da Empresa
	Local cMsg1							// Mensagem do Gauge 1			
	Local cEmpBack			:= cEmpAnt	// Backup da empresa atual
	Local cFilBack			:= cFilAnt	// Backup da Filial atual
	Local aFiles			:= {}		// Array das tabelas a serem abertas
	Local nPosAlias 		:= 0		// Posicionamento do array das tabelas
	Local lProc				:= .F.
	Local nX				:= 0
	Local aRetSM0	        := {}
	Local lFWLoadSM0		:= FindFunction("FWLoadSM0")
		
	Private cFilRCL			:= xFilial("RCL")				//Filial da Tabela RCL
	Private	cFilSRA			:= xFilial("SRA")  				//Filial da Tabela SRA
	Private	cModoRCL		:= If(Empty(cFilRCL),"C","E")	//Modo acesso da tabela RCL
	Private	cModoSRA		:= If(Empty(cFilSRA),"C","E")	//Modo acesso da tabela SRA
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tabelas a serem abertas de outra empresa				      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aFiles,{"SRA",""})
	aadd(aFiles,{"RCL",	""})
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Formatar os parametros Range em expressao SQL			      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MakeSqlExpr("ORGM030")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega todas as empresa no Array aEmp						  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lEmpProc
		If lFWLoadSM0
			aRetSM0	:= FWLoadSM0()
			For nX := 1 To Len(aRetSM0)
				If aRetSM0[nx][2] $ MV_PAR01 .Or. Empty(MV_PAR01)
					aadd(aEmp,{aRetSM0[nx][1],aRetSM0[nx][2],aRetSM0[nx][7]})
				EndIf
			Next
		Else
			SM0->(dbGoTop())
			Do While !SM0->(Eof())
				If SM0->M0_CODFIL $ MV_PAR01 .Or. Empty(MV_PAR01)
					aadd(aEmp,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL})
				EndIf
				SM0->(dbSkip())
			EndDo
		EndIf
	
	Else
		aadd(aEmp, {SM0->M0_CODIGO, FWGETCODFILIAL, SM0->M0_FILIAL} )
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processar cargas dos departamentos das empresas				  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTimeIni	:= Time()
	dMsDate		:= MsDate()
	nLoops		:= Len(aEmp)
	BarGauge1Set(nLoops)
	
	For nCountTime:=1 to nLoops
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Abrir tabelas da respectiva empresa								  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	    If cEmpAnt <> aEmp[nCountTime,1]
			cEmpAnt		:=aEmp[nCountTime,1]			
			OrgxOpenFile(aFiles, aEmp[nCountTime,1])
	
			nPosAlias 	:= Ascan(aFiles,{|x| x[1] == "RCL"})
			cModoRCL	:= aFiles[nPosAlias,2]
	
			nPosAlias 	:= Ascan(aFiles,{|x| x[1] == "SRA"})
			cModoSRA	:= aFiles[nPosAlias, 2]
			lProc		:= .F.
		EndIf	
		
		cFilRCL:= If(cModoRCL=="C", Space(FWGETTAMFILIAL), aEmp[nCountTime,2])
		cFilSRA:= If(cModoSRA=="C", Space(FWGETTAMFILIAL), aEmp[nCountTime,2])
		
	    If lEmpProc
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calculo do tempo de processamento + incremento da regua IncPrcG1()³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cMsg1:= STR0004 + " - " + aEmp[nCountTime,1] + " " + aEmp[nCountTime,3]   //"Processando empresa"
			IncPrcG1Time(	cMsg1				,;	//01 -> Inicio da Mensagem
							nLoops		 		,;	//02 -> Numero de Registros a Serem Processados
							cTimeIni			,;	//03 -> Tempo Inicial
							.T.					,;	//04 -> Defina se eh um processo unico ou nao ( DEFAULT .T. )
							NIL					,;	//05 -> Contador de Processos
							1			 		,;	//06 -> Percentual para Incremento
							NIL					,;	//07 -> Se Deve Incrementar a Barra ou Apenas Atualizar a Mensagem
							NIL					 ;	//08 -> Se Forca a Atualizacao das Mensagens
						)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Selecao e gravacao dos postos								  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcessBranch(	aEmp[nCountTime, 1]	,;   	//Empresa
						aEmp[nCountTime, 2]	,;		//Filial
						MV_PAR01			,;		//Filtro Filial
						MV_PAR02			,;		//Filtro Departamento
						MV_PAR03			,;		//Filtro Matricula
						nCountTime			,;		//Sequencia de processamento
						lEmpProc			)		//Tipo do processamento .T. - Todas as empresas, .F. - Unica empresa
		lProc := .T.
	Next nCountTime
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Restauranto o ambiente original								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cEmpBack <> cEmpAnt .OR. cFilBack <> cFilAnt
		cEmpAnt:= cEmpBack
		cFilAnt:= cFilBack
		OrgxOpenFile(aFiles, cEmpBack)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processar resultado da query								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsgInfo(OemToAnsi(STR0005))		//Fim do Processamento
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ORGM30PrcFil  ³ Autor ³Marcos Alves       ³ Data ³11/09/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processas a caga das filias  							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Static Function ProcessBranch(  cEmpProc	,;   	//Empresa
								cFilProc	,;		//Filial a ser processada
								cParFilial	,;		//Filtro Filial
								cParDepto	,;		//Filtro Cento de Custo
								cParMatric	,;		//Filtro Matricula
								nCountTime	,;		//Sequencia de processamento
								lEmpProc	)		//Tipo do processamento .T. - Todas as empresas, .F. - Unica empresa

	Local cAliasQry		:= GetNextAlias()										//Alias do result set da query
	
	Local nRegTMP		:= 0													//Numero de registro do ResultSet
	Local cTimeIni		:= ""													//Hora inicial do processamento
	Local cMsg2			:= STR0006 + cFilProc									//Mensagem da tela Baug - #"Processando centros de custos - Filial "
	Local nSaveSx8Len											//Numero de codigos novos para confirmar
//    Local lExistPerson
	Local lExistPost
	Local lExistOcuppant
	Local cFields
    
    //Formato da clausula Where da Query com parametros de pergunte
	Local cWhere := "SRA.RA_SITFOLH <> 'D'"
	cWhere	+= " AND SRA.RA_DEPTO <> '" + Space(GetSx3Cache("RA_DEPTO", "X3_TAMANHO")) + "'"
	cWhere	+= " AND SRA.RA_POSTO = ' '"
	cWhere	+= " AND SRA.D_E_L_E_T_ = ' '"
	cWhere	+= IIF(Empty(cParFilial), "", " AND " + AllTrim(cParFilial))
	cWhere	+= IIF(Empty(cParDepto) , "", " AND " + AllTrim(cParDepto))
	cWhere	+= IIF(Empty(cParMatric), "", " AND " + AllTrim(cParMatric))
	cWhere	:= '%' + cWhere	+ '%'
	
	dbSelectArea("SRA")
	dbSetorder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Query para retornar o total de registros a serem processados.		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		    
	BEGINSQL ALIAS cAliasQry
		SELECT 
			COUNT(*) AS RECORDNUM
		FROM  
			%table:SRA% SRA 
		WHERE 
			%exp:cWhere%
	ENDSQL
	
	nRegTMP := (cAliasQry)->RECORDNUM
	(cAliasQry)->(DbCloseArea())

	cFields:= "SRA.RA_FILIAL, "
	cFields+= "SRA.RA_MAT, "
	cFields+= "SRA.RA_DEPTO, "
	cFields+= "SRA.RA_CC, "
	cFields+= "SRA.RA_CARGO, "
	cFields+= "SRA.RA_CODFUNC, "
	cFields+= "SRA.RA_SALARIO, "
	cFields+= "SRA.RA_TPCONTR, "
	cFields+= "SRA.RA_ADMISSA, "
	cFields+= "SRA.RA_PROCES, "
		
	If cPaisLoc == "BRA"      
		cFields+= "0 AS RA_FGTS, "
	ElseIf cPaisLoc == "MEX"      
		cFields+= "SRA.RA_KEYLOC, "
	EndIf

	cFields+= "SRA.D_E_L_E_T_, "
	cFields+= "SRA.R_E_C_N_O_ "
	cFields:= "%" + cFields	+ "%"

	BEGINSQL ALIAS cAliasQry
		COLUMN RA_ADMISSA AS DATE
		
		SELECT 
			%exp:cFields% 
		FROM  
			%table:SRA% SRA 
		WHERE 
			%exp:cWhere% 
		ORDER BY 
			%Order:SRA, 1%
	ENDSQL              
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caracteritiscas operacionais para Depuracao:									³
	//³ aRet:=GetLastQuery()															³
	//³ aRet[1] cAlias - Alias usado para abrir o Cursor.								³
	//³ aRet[2] cQuery - Query executada.												³
	//³ aRet[3] aCampos - Array de campos com critério de conversão especificados.		³
	//³ aRet[4] lNoParser - Caso .T., não foi utilizada ChangeQuery() na String original³
	//³ aRet[5] nTimeSpend - Tempo, em segundos, utilizado para a abertura do Cursor	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento do Result Set				   									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTimeIni	:= Time()			// Tempo inicial da calculo do tempo de processamento
	dMsDate		:= MsDate()			// Data do inicio do processamento
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seta o totalizador da Gauge 2			   									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lEmpProc  //Se processa todas as empresa usa 2 Gauge
		BarGauge2Set( nRegTMP )
	Else	
		BarGauge1Set( nRegTMP )
	EndIf

	dbSelectArea("RCX")
	dbSetorder(5)		//RCX_FILIAL+RCX_FILOCU+RCX_CODOCU+RCX_FILFUN+RCX_MATFUN
	dbSelectArea("RCL")
	dbSetorder(2)	 	//RCL_FILIAL+RCL_POSTO


	While !(cAliasQry)->(Eof())
		If lEmpProc  //Se processa todas as empresa usa 2 Gauge
			IncPrcG2Time(		cMsg2			,;	//01 -> Inicio da Mensagem
								nRegTMP			,;	//02 -> Numero de Registros a Serem Processados
								cTimeIni		,;	//03 -> Tempo Inicial
								.T.				,;	//04 -> Defina se eh um processo unico ou nao ( DEFAULT .T. )
								nCountTime		,;	//05 -> Contador de Processos
								1			 	,;	//06 -> Percentual para Incremento
								NIL				,;	//07 -> Se Deve Incrementar a Barra ou Apenas Atualizar a Mensagem
								NIL				 ;	//08 -> Se Forca a Atualizacao das Mensagens
							)
		Else
			IncPrcG1Time(		cMsg2			,;	//01 -> Inicio da Mensagem
								nRegTMP			,;	//02 -> Numero de Registros a Serem Processados
								cTimeIni		,;	//03 -> Tempo Inicial
								.T.				,;	//04 -> Defina se eh um processo unico ou nao ( DEFAULT .T. )
								nCountTime		,;	//05 -> Contador de Processos
								1			 	,;	//06 -> Percentual para Incremento
								NIL				,;	//07 -> Se Deve Incrementar a Barra ou Apenas Atualizar a Mensagem
								NIL				 ;	//08 -> Se Forca a Atualizacao das Mensagens
							)
	
		EndIf
		
		RCX->(dbSetorder(4))		//RCX_FILIAL+RCX_FILFUN+RCX_MATFUN+RCX_POSTO
		lExistOcuppant:= RCX->(DBSeek(xFilial("RCX") + (cAliasQry)->(RA_FILIAL + RA_MAT)))

		lExistPost:= .F.
		If lExistOcuppant
			lExistPost:= RCL->(DBSeek(cFilRCL + RCX->RCX_POSTO, .F. ) )
		EndIf
			
		Begin Transaction 
			nSaveSx8Len 	:= GetSx8Len()
			
			If !lExistPost
				RCL->(RecLock("RCL", .T.))
			    
				RCL->RCL_FILIAL	:= cFilRCL 											//Grava a filial da empresa aberta
				RCL->RCL_POSTO	:= &(GetSx3Cache("RCL_POSTO", "X3_RELACAO" ) ) 	//Pegar a função do dicionario
				RCL->RCL_DEPTO	:= (cAliasQry)->RA_DEPTO
				RCL->RCL_CC		:= (cAliasQry)->RA_CC
				RCL->RCL_DTINI	:= dDataBase
				RCL->RCL_DTFIM	:= CToD("  /  /  ")
				RCL->RCL_NPOSTO	:= 1
				RCL->RCL_OPOSTO	:= 1
				RCL->RCL_CARGO	:= (cAliasQry)->RA_CARGO
				RCL->RCL_FUNCAO	:= (cAliasQry)->RA_CODFUNC		
				RCL->RCL_SALAR	:= (cAliasQry)->RA_SALARIO
				RCL->RCL_ENCARG	:= 0
				RCL->RCL_BENEF	:= 0
				RCL->RCL_TPCONT := (cAliasQry)->RA_TPCONTR
				RCL->RCL_DTATU  := dDataBase
				RCL->RCL_TPOSTO := "1"		//1=Individual;2=Generico
				RCL->RCL_STATUS := "2"	   	//1-Posto vago;2-Posto ocupado
				RCL->RCL_PROCES	:= (cAliasQry)->RA_PROCES
				
				If cPaisLoc == "BRA"
					RCL->RCL_FGTS   := (cAliasQry)->RA_FGTS
				ElseIf cPaisLoc == "MEX"
					RCL->RCL_LOCPAG	:= (cAliasQry)->RA_KEYLOC					
				EndIf
				
				MsUnLock()
			EndIf
				
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Registro de movimentacao do posto							   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If !lExistPost
				RecLock("RBT", .T.)
				RBT->RBT_FILIAL		:= xFilial("RBT")
				RBT->RBT_CODMOV		:= fBuscaMov()
				RBT->RBT_DTAMOV		:= dDataBase
				RBT->RBT_DEPTO		:= RCL->RCL_DEPTO
				RBT->RBT_CC			:= RCL->RCL_CC
				RBT->RBT_FUNCAO		:= RCL->RCL_FUNCAO
				RBT->RBT_CARGO		:= RCL->RCL_CARGO
				RBT->RBT_REMUNE		:= RCL->RCL_SALAR
				RBT->RBT_ENCARG		:= RCL->RCL_ENCARG
				RBT->RBT_BENEF		:= RCL->RCL_BENEF
				RBT->RBT_TPOSTO		:= RCL->RCL_TPOSTO
				RBT->RBT_TPCONT		:= RCL->RCL_TPCONT
				RBT->RBT_QTDMOV		:= 1
				RBT->RBT_RESPON		:= cUserName 
				RBT->RBT_STATUS		:= "1"		//1=Baixado;2=Pendência  Parcial;3=Pendência  Total
				RBT->RBT_JUSTIF		:= "01"
				RBT->RBT_PROCES		:= RCL->RCL_PROCES
				If cPaisLoc == "BRA"
					RBT->RBT_FGTS		:= RCL->RCL_FGTS
				ElseIf cPaisLoc == "MEX"
					RBT->RBT_LOCPAG		:= RCL->RCL_LOCPAG
				EndIf

				MsUnLock()
				
				RecLock("RBX", .T.)		
				RBX->RBX_FILIAL		:= xFilial("RBX")
				RBX->RBX_CODMOV		:= RBT->RBT_CODMOV
				RBX->RBX_DTAMOV		:= dDataBase
				RBX->RBX_DEPTO		:= RCL->RCL_DEPTO
				RBX->RBX_TPOSTO		:= RCL->RCL_TPOSTO
				RBX->RBX_CODOPE		:= "1"			//1=Aprovar;2=Cancelar;3=Congelar
				RBX->RBX_QTDOPE		:= 1
				RBX->RBX_RESOPE		:= cUserName 
				RBX->RBX_JUSTIF		:= "01"
				MsUnLock()		

				
				RecLock("RBU",.T.)
				RBU->RBU_FILIAL 	:=	xFilial("RBU")
				RBU->RBU_POSTO 		:=	RCL->RCL_POSTO
				RBU->RBU_CODMOV		:=	&(GetSx3Cache("RBU_CODMOV", "X3_RELACAO" ) ) //GetSX8Num("RBU","RBU_CODMOV")
				RBU->RBU_DTAMOV  	:=	RCL->RCL_DTATU
				RBU->RBU_OPERAC 	:=	"1"		//1=Criação;2=Atualização;3=Ocupação;4=Congelamento;5=Cancelamento		
				RBU->RBU_DEPTO		:=	RCL->RCL_DEPTO 
				RBU->RBU_CARGO		:=	RCL->RCL_CARGO 
				RBU->RBU_FUNCAO		:=	RCL->RCL_FUNCAO
				RBU->RBU_CC			:=	RCL->RCL_CC	
				RBU->RBU_SALAR		:=	RCL->RCL_SALAR 
				RBU->RBU_ENCARG		:=	RCL->RCL_ENCARG
				RBU->RBU_BENEF		:=	RCL->RCL_BENEF 
				RBU->RBU_TPCONT		:=	RCL->RCL_TPCONT
				RBU->RBU_RESPON		:=	cUserName
				RBU->RBU_ORIGEM		:=	RBT->RBT_CODMOV 		//Relacionar com o movimentacao do Departamento RBT
				RBU->RBU_PROCES		:=	RCL->RCL_PROCES
				If cPaisLoc == "BRA"			
					RBU->RBU_FGTS		:=	RCL->RCL_FGTS  
				ElseIf cPaisLoc == "MEX"
					RBU->RBU_LOCPAG		:= RCL->RCL_LOCPAG
				EndIf			
				MsUnLock()
				
				
				RecLock("RBU",.T.)
				RBU->RBU_FILIAL 	:=	xFilial("RBU")
				RBU->RBU_POSTO 		:=	RCL->RCL_POSTO
				RBU->RBU_CODMOV		:=	&(GetSx3Cache("RBU_CODMOV", "X3_RELACAO" ) )//GetSX8Num("RBU","RBU_CODMOV")
				RBU->RBU_DTAMOV  	:=	RCL->RCL_DTATU
				RBU->RBU_OPERAC		:=	"3"
				RBU->RBU_FILFUN		:=	(cAliasQry)->RA_FILIAL
				RBU->RBU_MATFUN		:=	(cAliasQry)->RA_MAT
				RBU->RBU_DTINI		:=	(cAliasQry)->RA_ADMISSA
				RBU->RBU_DEPTO		:=	RCL->RCL_DEPTO 
				RBU->RBU_CARGO		:=	RCL->RCL_CARGO 
				RBU->RBU_FUNCAO		:=	RCL->RCL_FUNCAO
				RBU->RBU_CC			:=	RCL->RCL_CC	
				RBU->RBU_SALAR		:=	RCL->RCL_SALAR 
				RBU->RBU_ENCARG		:=	RCL->RCL_ENCARG
				RBU->RBU_BENEF		:=	RCL->RCL_BENEF 
				RBU->RBU_TPCONT		:=	RCL->RCL_TPCONT
				RBU->RBU_RESPON		:=	cUserName
				RBU->RBU_ORIGEM		:=	Space(GetSx3Cache("RBU_ORIGEM", "X3_TAMANHO"))
				RBU->RBU_PROCES		:=	RCL->RCL_PROCES
				
				If cPaisLoc == "BRA"
					RBU->RBU_FGTS		:=	RCL->RCL_FGTS
				ElseIf cPaisLoc == "MEX"
					RBU->RBU_LOCPAG		:=	RCL->RCL_LOCPAG				
				EndIf
				
				MsUnLock()				
			EndIf
		
			If !lExistOcuppant
				RCX->(RecLock("RCX", .T.))
		
				RCX->RCX_FILIAL	:= xFilial("RCX")
				RCX->RCX_POSTO	:= RCL->RCL_POSTO
				RCX->RCX_DTINI	:= (cAliasQry)->RA_ADMISSA
				RCX->RCX_TIPOCU	:= "1"	//Funcionario					
				RCX->RCX_FILFUN	:= (cAliasQry)->RA_FILIAL
				RCX->RCX_MATFUN	:= (cAliasQry)->RA_MAT
				RCX->RCX_SUBST	:= "2"	//Nao
				RCX->RCX_CODMOV	:=	RBU->RBU_CODMOV	
				
				RCX->(MsUnLock())
			EndIf	
			   
			SRA->(DBGoTo( (cAliasQry)->R_E_C_N_O_ ) )
			SRA->(RecLock("SRA", .F.))
			SRA->RA_POSTO	:= RCL->RCL_POSTO
			SRA->(MsUnLock())			
		
			While (GetSx8Len() > nSaveSx8Len)
				ConfirmSX8()
			End			
		End Transaction		

		(cAliasQry)->(DbSkip())
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Fechar o arquivo TMP da Query.									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	If Select(cAliasQry) > 0
		(cAliasQry)->(DbCloseArea())
	EndIf  
Return

/*/{Protheus.doc} fBuscaMov
Retorna o código de movimentação de acordo com a tabela RBT e não de acordo com controle
de numeração automática.
@author Allyson Mesashi
@since 26/03/2021
/*/
Function fBuscaMov()

Local aAreaRBT 		:= RBT->(GetArea())
Local cCodMov 		:= ""
Local cAliasTab		:= GetNextAlias()
Local lFazer 		:= .T.

BeginSql Alias cAliasTab
	SELECT MAX(RBT_CODMOV) CODMOV FROM %table:RBT% RBT
	WHERE RBT.RBT_FILIAL = %Exp:(xFilial("RBT"))%
		AND %NotDel%
EndSql

cCodMov := StrZero( Val((cAliasTab)->CODMOV)+1, nRbtMovTam )

RBT->( dbSetOrder(4) )//RBT_FILIAL+RBT_CODMOV
//Verifico se realmente o codigo é o correto a ser utilizado de acordo com a chave primária
While lFazer
	If RBT->(dbSeek(xFilial("RBT")+cCodMov))
		cCodMov := StrZero( Val((cAliasTab)->CODMOV)+1, nRbtMovTam )
	Else
		lFazer	:= .F.
	EndIf
End While

(cAliasTab)->( dbCloseArea() )

RestArea(aAreaRBT)

Return cCodMov
