#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISXAPUR.CH"
#INCLUDE "FWCOMMAND.CH"
#Include "MATA95xDef.ch"

STATIC cDbType      := TCGetDB()
STATIC __aPrepared  := {}
STATIC _lFldCDY     := nil
STATIC _lXAPMTHREAD := FWIsInCallStack( 'XAPMTHREAD' )
STATIC aApurSX2     := Iif(_lXAPMTHREAD,{},LoadX2Apur()) //Quando processar XAPMTHREAD n„o possui cFialant neste momento
STATIC aApurSX3     := Iif(_lXAPMTHREAD,{},LoadX3Apur()) //POsteriormente È carregado a cache
STATIC aExistBloc   := Iif(_lXAPMTHREAD,{},LoadPEApur())
STATIC aFindFunc	:= Iif(_lXAPMTHREAD,{},LoadXFFApur())
STATIC _INTTMS      := Iif(_lXAPMTHREAD,.F.,IntTms())
STATIC lBuild   	:= GetBuild() >= "7.00.131227A"
STATIC oHashCFOP	:= Nil
STATIC oHashCFUF	:= Nil
STATIC oHasCodAju	:= Nil
STATIC aCodJu		:= {}

//Define para definicao do tamanho do array de apuracao. Utilizado no aApuracao e para criar a estrutura do TEMPDB
#DEFINE		LEN_CAMPO_IDXKEY			050
#DEFINE		LEN_ARRAY_APURACAO		145
#DEFINE		ARRAY_POSICAO_CHAR			{ { 1 , 'F3_CFO' , 'F3_CODISS' } ,;		//F3_CFO para ICMS/IPI OU F3_CODISS para o ISS 
										{ 19 , 'F3_ESTADO' } ,;
										{ 20 , 5 } ,;
										{ 74 , 'F3_TIPO' } ,;
										{ 89 , 200 },; 
										{124, 'F4_IPI'}}
#DEFINE		ARRAY_POS_NAO_CUMULATIVAS	{ 1 , 2 , 19 , 20 , 53 , 54 , 62 , 63 , 65 , 89 , 96, 124}
//-------------------------------------------------------------------
/*/{Protheus.doc} XApurRF3Nw
Funcao de processamento do movimento de escrituracao dos documentos fiscais de um determinado periodo.

@param	  cImp - Imposto <"IC"MS|"IP"I|"IS"S>
		  dDtIni - Dt Inicio da Apuracao
	 	  dDtFim - Dt Final da Apuracao
		  cNrLivro - Numero do Livro
	 	  lQbAliq - Quebra por Aliquota
		  lQbCFO - Quebra por CFO
		  nRegua - 0=Nao Exibe 1=Processamento 2=Relatorio
		  lEnd - Flag de InterrupáÑo
		  nConsFil 9 - Considera filial
		  cFilDe - Filial De
		  cFilAte - Filial ate
		  aEntr - array com o resumo de ICMS Retido para entrada
		  aSaid - array com o resumo de ICMS Retido para saida
		  cFilUsr - Filtro do usuario baseado na tabela SF3
		  lGeraArq - Gera Arquivo de Trabalho
		  cAliasTRB - Alias do arquivo de trabalho esperado de retorno da funcao 
		  lQbUF - Quebra por UF	
		  lQbPais - Quebra por CÛdigo do Pais	
		  lQbCfopUf - Quebra por CFOP+UF e por "Aliquota" caso necessite, mas somente se "lQbUF" e "lQbPais" forem .F.
		  lImpCrdSt - Flag de impressao do Credito ST atraves do campo F3_SOLTRIB 
		  lMv_UFSt - Flag que determina se efetua o tratamento do parametro MV_UFST 
		  lCrdEst - Flag que determina se trata o credito estimulo 
		  aEstimulo - Array com os valores de credito estimulo a serem considerados 
  		  lQbUfCfop - Flag de Quebra por UF+CFOP
  		  lConsUF - Indica se, quando a apuracao for consolidada, apenas as filiais estabelecidas no mesmo estado do consolidador sejam processadas
  		  aApurCDA - Array para armazenar lancamentos da apuracao ICMS gravados no CDA
  		  aApurF3 - (NAO USADO) - Array para armazenar lancamentos da apuracao ICMS gravados no SF3 
  		  aCDAIC - Array para armazenar lancamentos de ajustes da apuracao ICMS gravados no CDA
  		  aCDAST - Array para armazenar lancamentos de ajustes da apuracao ICMS-ST gravados no CDA
  		  cChamOrig - Funcao que esta chamando
  		  nParPerg - Parametro da pergunta
  		  aFilsCalc - Array das Filiais Selecionadas
  		  aApurMun - Array com os valores de ISS por municipio
		  lICMDes - Indica se havera calculo Credito ICMS Relat. Art.271 RICMS/SP		   
		  aIcmPago - Array para armazenar valores de GNRE ja pagos na emissao do documento
		  lICMGar - Indica se havera calculo Credito ICMS Garantido Relat. Art.435-N RICMS/MT
		  aCDADE - Array contendo os lancamentos de debitos especiais
		  aRetEsp - Array que me retorna o lancamento de documento fiscal que corresponde ao valor do ST-Debitado na entrada (_CREDST=3)
		  lGiaRs - Identifica se o arquivo de geracao eh o GIARS
		  nCredMT - Indica se calculo Credito Presumido MT
		  nOpcApur - Flag de tratamento na geracao do TEMPDB da Apuracao. 1=Refaz Movimento Tabela, 2=Apaga Tabela, 3=Leitura da Tabela

@return	  ARRAY	- Array com os valores de apuracao (aApuracao)
					OU
		  		  Array do TRB conforme especificacoes do RS
		  		  	OU
		  		  TRB padrao gerado pela rotina

@author Gustavo G. Rueda
@since 04/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XApurRF3Nw(cImp,; 	// 1 - Imposto <"IC"MS|"IP"I|"IS"S>
		  dDtIni	,; 	// 2 - Dt Inicio da Apuracao
	 	  dDtFim	,; 	// 3 - Dt Final da Apuracao
		  cNrLivro	,;	// 4 - Numero do Livro
	 	  lQbAliq	,;	// 5 - Quebra por Aliquota
		  lQbCFO	,;	// 6 - Quebra por CFO
		  nRegua	,;	// 7 - 0=Nao Exibe 1=Processamento 2=Relatorio
		  lEnd		,;	// 8 - Flag de InterrupáÑo
		  nConsFil	,;	// 9 - Considera filial
		  cFilDe	,;	// 10 - Filial De
		  cFilAte	,;	// 11 - Filial ate
		  aEntr		,;	// 12 - array com o resumo de ICMS Retido para entrada	 
		  aSaid		,;  // 13 - array com o resumo de ICMS Retido para saida
		  cFilUsr	,;	// 14 - 
		  lGeraArq	,;	// 15 - Gera Arquivo de Trabalho
		  cAliasTRB ,;	// 16 - 
		  lQbUF		,; 	// 17 - Quebra por UF	
		  lQbPais	,;	// 18 - Quebra por CÛdigo do Pais	
		  lQbCfopUf	,;	// 19 - Quebra por CFOP+UF e por "Aliquota" caso necessite, mas somente se "lQbUF" e "lQbPais" forem .F.
		  lImpCrdSt ,;	// 20 - 
		  lMv_UFSt  ,;	// 21 - 
		  lCrdEst   ,;	// 22 - 
		  aEstimulo ,;	// 23 - 
  		  lQbUfCfop ,;	// 24 - Quebra por UF+CFOP
  		  lConsUF	,;	// 25 - Indica se, quando a apuracao for consolidada, apenas as filiais estabelecidas no mesmo estado do consolidador sejam processadas
  		  aApurCDA	,;	// 26 - Array para armazenar lancamentos da apuracao ICMS gravados no CDA
  		  aApurF3	,;	// 27 - (NAO USADO) - Array para armazenar lancamentos da apuracao ICMS gravados no SF3
  		  aCDAIC	,;	// 28 - Array para armazenar lancamentos de ajustes da apuracao ICMS gravados no CDA
  		  aCDAST	,;	// 29 - Array para armazenar lancamentos de ajustes da apuracao ICMS-ST gravados no CDA
  		  cChamOrig ,; 	// 30 - Funcao que esta chamando
  		  nParPerg	,;	// 31 - Parametro da pergunta
  		  aFilsCalc	,;	// 32 - Array das Filiais Selecionadas
  		  aApurMun  ,;	// 33 - Array com os valores de ISS por municipio
		  lICMDes   ,;	// 34 - Indica se havera calculo Credito ICMS Relat. Art.271 RICMS/SP		   
		  aIcmPago  ,;	// 35 - Array para armazenar valores de GNRE ja pagos na emissao do documento
		  lICMGar,;   	// 36 - Indica se havera calculo Credito ICMS Garantido Relat. Art.435-N RICMS/MT
		  aCDADE,;		// 37 - Array contendo os lancamentos de debitos especiais
		  aRetEsp,;		// 38 - Array que me retorna o lancamento de documento fiscal que corresponde ao valor do ST-Debitado na entrada (_CREDST=3)
		  lGiaRs,;		// 39 - Identifica se o arquivo de geracao eh o GIARS
		  nCredMT,;    	// 40 - Indica se calculo Credito Presumido MT
		  nOpcApur,;   ////Flag de tratamento na geracao do TEMPDB da Apuracao. 1=Refaz Movimento Tabela, 2=Apaga Tabela, 3=Leitura da Tabela  
		  aConv139,;		//42 - Array com valores e informaÁıes do convenio 139/06	
		  aRecStDif,;
		  aMensIPI,;		  
		  aDifal,;
		  aCDADifal,;
		  lAutomato,;
		  aCDAExtra,;
		  aApurExtra,;
		  aApurCDV,;
		  aCDAIPI,;
		  aNWCredAcu,;
		  lProcRefer,;
		  cTempDeb,; 
		  cTempCrd,; 
		  cTempSTd,; 
		  cTempSTe,;
		  cTempIPIs,;
		  cTempIPIe )	

Local	cLockTDB	:=	cImp + DToS( dDtIni ) + DToS( dDtFim ) + '_' + FWGrpCompany() + '_' + FWCodFil()
Local	cAlsTempDB	:=	'TMPRF3'
Local	cAls2TempDB	:=	'TMP2RF3'
Local	cTempDB		:=	XApNmTDBR3( cImp , dDtIni , dDtFim , 'A' )		//Retorna o nome do TEMPDB a ser criado no RDBMS
Local	cTempDBRes	:=	XApNmTDBR3( cImp , dDtIni , dDtFim , 'B' )		//Retorna o nome do TEMPDB a ser criado no RDBMS
Local	aRetorno	:=	{}
Local	lProcessa	:=	.T.
Local	nMVRF3THR	:=	GetNewPar( 'MV_RF3THR' , 3 )
Local	nMVRF3MXT	:=	GetNewPar( 'MV_RF3MXT' , 5 )
Local	lMVRF3LOG	:=	GetNewPar( 'MV_RF3LOG' , .F. )
Local	nThreads	:=	Min( nMVRF3THR , nMVRF3MXT )
Local	nX			:=	0
Local	cJobFile	:=	''
Local	aJobAux		:=	{}
Local 	nRetry_0 	:= 	0
Local 	nRetry_1 	:= 	0
Local 	nTamArray   := LEN_ARRAY_APURACAO
Local 	lMsg		:= .T.
Local cTempDeb		:= "ICMSDEBITO"+AllTrim(Str(ThreadID()))
Local cTempCrd		:= "ICMSCREDITO"+AllTrim(Str(ThreadID()))
Local cTempSTd		:= "STDEBITO"+AllTrim(Str(ThreadID()))
Local cTempSTe		:= "STCREDITO"+AllTrim(Str(ThreadID()))
Local cTempIPIs		:= "IPIDEBITO"+AllTrim(Str(ThreadID()))
Local cTempIPIe		:= "IPICREDITO"+AllTrim(Str(ThreadID()))

Default aRecStDif	:= {}
Default aMensIPI	:= {}
Default aDifal	:= {}
Default aCDADifal	:= {}
Default aCDAExtra	:= {}
Default aApurExtra	:= {}
Default lAutomato := .F.
Default aApurCDV	:= {}
Default aCDAIPI		:= {}
Default aNWCredAcu	:= {}

nRegua := IIf( nRegua == NIL , 0 , nRegua )	

If nOpcApur <> 3 .And.;										//Quando a chamada for somente de leitura da tabela, nao preciso tratar semaforos
	!LockByName( 'XApurRF3Nw_' + cLockTDB , .T. , .T. )	//Tratamento de semaforo para garantir a execucao de isolada da rotina.

	If nRegua > 0
		ApMsgAlert( STR0101 + ;			//'J· est· sendo executada uma apuraÁ„o deste tributo para este perÌodo no momento, por favor, para reprocessar o movimento em quest„o aguarde o tÈrmino do outro processamento.'
				CRLF + CRLF + STR0102 )	//'As informaÁıes a seguir ser„o apresentadas com base em um movimento j· apurado.'
	Else
		ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0101 +;	//'J· est· sendo executada uma apuraÁ„o deste tributo para este perÌodo no momento, por favor, para reprocessar o movimento em quest„o aguarde o tÈrmino do outro processamento.'
				CRLF + CRLF + STR0102 )	//'As informaÁıes a seguir ser„o apresentadas com base em um movimento j· apurado.'
	EndIf

	//UserException( 'LockByName [ ' + 'XApurRF3Nw_' + cLockTDB + ' ] n„o realizado.' )
	lProcessa	:=	.F.
EndIf

//Verifica se deve processar a rotina, ou por LOCK ou por Visualizacao( nOpcApur = 3 )
If lProcessa
	If nOpcApur == 3
		nOpcApur := XATestTemp(cTempDB, cAlsTempDB, nTamArray )

		If nOpcApur == 1
			lMsg := .F.
		ElseIf nOpcApur == 4
			Return aRetorno	
		EndIf

		If lAutomato
			lMsg := .F.
		EndIf

	EndIf
	If nOpcApur <> 3 .And.;	//Quando se tratar da leitura da tabela, nao preciso consistir, pois soh vou ler
		nRegua > 0

		If lAutomato .Or. IsInCallStack('U_MATRAPR')
			lMsg := .F.
		EndIf

		//Deleto o TEMPDB de resumo, se conseguir, parto para delecao do principal
		If XApDelTempDB( cTempDB, lMsg ) 

			//Deleto o TEMPDB principal
			If XApDelTempDB( cTempDBRes , .F. )
				nOpcApur	:=	1	//Reprocessa Movimento
			Else
				nOpcApur	:=	3	//Visualizacao do Movimento
			EndIf

		Else
			nOpcApur	:=	3	//Visualizacao do Movimento
		EndIf

	EndIf

	//Inicializa o log de processamento
	ProcLogIni( {} , 'FISXAPURA' )

	//No reprocessamento, devo recriar a tabela, pois quando for igual a '1', tenho certeza que excluiu conforme condicao acima
	If nOpcApur == 1
		XApCrTempDB( cImp , cTempDB , cAlsTempDB , cTempDBRes , cAls2TempDB , lQbUfCfop , lQbAliq , lQbCFO , lQbPais , lQbUF , lQbCfopUf )
	EndIf

	//Na visualizacao nao preciso de multi-thread, somente no processamento 
	If nOpcApur <> 3 .And. nThreads > 0
		aThreads	:=	DefThread( nThreads , dDtIni, dDtFim )

		If nRegua>0
			If nRegua	==	1
				ProcRegua( ( Len( aThreads ) * 2 ) + 8 )
			Else
				SetRegua( ( Len( aThreads ) * 2 ) + 8 )
			Endif
		Endif

		For nX := 1 To Len( aThreads )

			If nRegua>0
				If nRegua	==	1
					IncProc( OemToAnsi( STR0103 ) )	//'Processando movimento'
				Else
					IncRegua()
				Endif
			Endif

			// Informacoes do semaforo
			cJobFile	:=	CriaTrab( Nil , .F. ) + ".job"

			// Inicializa variavel global de controle de thread
			cJobAux	:=	StrTran( "cCRF3_" + FWGrpCompany() + FWCodFil() , ' ' , '_' ) + StrZero( nX , 2 )
			PutGlbValue( cJobAux , "0" )
			GlbUnLock()

			// Adiciona o nome do arquivo de Job no array aJobAux
			aAdd( aJobAux , { StrZero( nX , 2 ) , cJobFile , cJobAux } )

			//Atualiza o log de processamento
			ProcLogAtu( "MENSAGEM",	'( Thread ' + StrZero( nX , 2 ) + ' ) ' + STR0104,; //Iniciando Processamento MThread da ResumeF3.'
									'( Thread ' + StrZero( nX , 2 ) + ' ) ' + STR0104 ) //Iniciando Processamento MThread da ResumeF3.'

			//Dispara thread
			StartJob( "XApMThread" , GetEnvServer() , .F. ,;
								cImp,; 		// 1 - Imposto <"IC"MS|"IP"I|"IS"S>
							  	aThreads[ nX , 1 ],; 		// 2 - Dt Inicio da Apuracao
						 	  	aThreads[ nX , 2 ],; 		// 3 - Dt Final da Apuracao
							  	cNrLivro,;		// 4 - Numero do Livro
						 	  	lQbAliq,;		// 5 - Quebra por Aliquota
							  	lQbCFO,;		// 6 - Quebra por CFO
							  	/*nRegua*/,;		// 7 - 0=Nao Exibe 1=Processamento 2=Relatorio (em STARTJOB o nRegua nao eh usado)
							  	lEnd,;			// 8 - Flag de InterrupáÑo
							  	nConsFil,;		// 9 - Considera filial
							  	cFilDe,;		// 10 - Filial De
							  	cFilAte,;		// 11 - Filial ate
							  	aEntr,;		// 12 - array com o resumo de ICMS Retido para entrada	 
							  	aSaid,; 		// 13 - array com o resumo de ICMS Retido para saida
							  	cFilUsr,;		// 14 - 
							  	lGeraArq,;		// 15 - Gera Arquivo de Trabalho
							  	cAliasTRB,;	// 16 - 
							  	lQbUF,;	 	// 17 - Quebra por UF	
							  	lQbPais,;		// 18 - Quebra por CÛdigo do Pais	
							  	lQbCfopUf,;	// 19 - Quebra por CFOP+UF e por "Aliquota" caso necessite, mas somente se "lQbUF" e "lQbPais" forem .F.
							  	lImpCrdSt,;	// 20 - 
							  	lMv_UFSt,;		// 21 - 
							  	lCrdEst,;		// 22 - 
							  	aEstimulo,;	// 23 - 
					  		  	lQbUfCfop,;	// 24 - Quebra por UF+CFOP
					  		  	lConsUF,;		// 25 - Indica se, quando a apuracao for consolidada, apenas as filiais estabelecidas no mesmo estado do consolidador sejam processadas
					  		  	aApurCDA	,;	// 26 - Array para armazenar lancamentos da apuracao ICMS gravados no CDA
					  		  	aApurF3,;		// 27 - (NAO USADO) - Array para armazenar lancamentos da apuracao ICMS gravados no SF3
					  		  	aCDAIC,;		// 28 - Array para armazenar lancamentos de ajustes da apuracao ICMS gravados no CDA
					  		  	aCDAST,;		// 29 - Array para armazenar lancamentos de ajustes da apuracao ICMS-ST gravados no CDA
					  		  	cChamOrig,; 	// 30 - Funcao que esta chamando
					  		  	nParPerg	,;	// 31 - Parametro da pergunta
					  		  	aFilsCalc,;	// 32 - Array das Filiais Selecionadas
					  		  	aApurMun,;		// 33 - Array com os valores de ISS por municipio
							  	lICMDes,;		// 34 - Indica se havera calculo Credito ICMS Relat. Art.271 RICMS/SP		   
							  	aIcmPago,;		// 35 - Array para armazenar valores de GNRE ja pagos na emissao do documento
							  	lICMGar,;   	// 36 - Indica se havera calculo Credito ICMS Garantido Relat. Art.435-N RICMS/MT
							  	aCDADE,;		// 37 - Array contendo os lancamentos de debitos especiais
							  	aRetEsp,;		// 38 - Array que me retorna o lancamento de documento fiscal que corresponde ao valor do ST-Debitado na entrada (_CREDST=3)
							  	lGiaRs,;		// 39 - Identifica se o arquivo de geracao eh o GIARS
							  	nCredMT,;    	// 40 - Indica se calculo Credito Presumido MT
							  	nOpcApur,;		// 41 - Flag de tratamento na geracao do TEMPDB da Apuracao. 1=Refaz Movimento Tabela, 2=Apaga Tabela, 3=Leitura da Tabela
							  	cTempDB,;		// 42 - Nome do temporario criado no RDBMS
							  	cTempDBRes,;	// 43 - TEMPDB de Resumo
							  	cJobFile,;		// 44 - Arquivo semaforo de controle da thread
							  	cJobAux,;		// 45 - Variavel global de controle do status do JOB
							  	FWGrpCompany(),;// 46 - Empresa
							  	FWCodFil(),;	// 47 - Filial
							  	StrZero( nX , 2 ),;//48 - Numero da Thread
							  	lMVRF3LOG,; //49 - Flag de geracao de CONOUT no console.log
								aRecStDif,;//50
								aMensIPI,;//51								
								aDifal,;//52
								aCDADifal,;//53
								aCDAExtra,;//54
								aApurExtra,;//55
								aApurCDV,;//56
								aCDAIPI,;//57
								aNWCredAcu,;//58
								lProcRefer,; //59
								cTempDeb,; //60
								cTempCrd,; //61
								cTempSTd,; //62
								cTempSTe,; //63
								cTempIPIs,; //64
								cTempIPIe) //65

			//conout("Iniciada Thread"+ cJobAux)
		Next nX

		//Controle de Seguranca para MULTI-THREAD
		For nX := 1 To Len( aJobAux )

			// Informacoes do semaforo
			cJobFile	:=	aJobAux[ nX , 2 ]

			// Inicializa variavel global de controle de thread
			cJobAux		:=	aJobAux[ nX , 3 ]

			While .T.
				Do Case
					// TRATAMENTO PARA ERRO DE SUBIDA DE THREAD
					Case GetGlbValue( cJobAux ) == '0'
						If nRetry_0 > 50
							ConOut( Replicate( '-' , 65 ) )
							ConOut( 'FISXAPURA.PRW: ' + STR0105 + aJobAux[ nX , 1 ] )	//'N„o foi possivel inicializar a thread '
							ConOut( Replicate( '-' , 65 ) )

							//Atualiza o log de processamento
							ProcLogAtu( 'ERRO',	'( Thread ' + aJobAux[ nX , 1 ] + ' ) ' + STR0106,; //N„o foi possivel inicializar a thread.'
												'( Thread ' + aJobAux[ nX , 1 ] + ' ) ' + STR0106 ) //N„o foi possivel inicializar a thread.'

							Final( 'FISXAPURA.PRW: ' + STR0105 + aJobAux[ nX , 1 ] )	//'N„o foi possivel inicializar a thread '
						Else
							nRetry_0 ++
						EndIf
					// TRATAMENTO PARA ERRO DE CONEXAO
					Case GetGlbValue(cJobAux) == '1'
						If FCreate( cJobFile ) # -1
							If nRetry_1 > 5
								ConOut( Replicate( '-' , 65 ) )
								ConOut( 'FISXAPURA.PRW: ' + STR0107 + aJobAux[ nX , 1 ] )	//'Erro de conexao na thread '
								ConOut( 'FISXAPURA.PRW: ' + STR0108 )	//'Numero de tentativas excedidas'
								ConOut( Replicate( '-' , 65 ) )

								//Atualiza o log de processamento
								ProcLogAtu( 'ERRO',	'( Thread ' + aJobAux[ nX , 1 ] + ' ) ' + STR0109,; //'Erro de conexao na thread.'
													'( Thread ' + aJobAux[ nX , 1 ] + ' ) ' + STR0109 ) //'Erro de conexao na thread.'

								Final( 'FISXAPURA.PRW: ' + STR0107 + aJobAux[ nX , 1 ] )	//'Erro de conexao na thread '

							Else
								// Inicializa variavel global de controle de Job
								PutGlbValue( cJobAux , '0' )
								GlbUnLock()

								// Reiniciar thread
								ConOut( Replicate( '-' , 65 ) )
								ConOut( 'FISXAPURA.PRW: ' + STR0107 + aJobAux[ nX , 1 ] )	//'Erro de conexao na thread '
								ConOut( 'FISXAPURA.PRW: ' + STR0110 + ' : ' + aJobAux[ nX , 1 ] )
								ConOut( Replicate( '-' , 65 ) )

								//Atualiza o log de processamento
								ProcLogAtu( 'ALERTA',	'( Thread ' + aJobAux[ nX , 1 ] + ' ) ' + STR0111,; //'Reiniciando thread.'
														'( Thread ' + aJobAux[ nX , 1 ] + ' ) ' + STR0111 ) //'Reiniciando thread.'

								//Dispara a thread novamente
								StartJob( "XApMThread" , GetEnvServer() , .F. ,;
													cImp,; 			// 1 - Imposto <"IC"MS|"IP"I|"IS"S>
												  	aThreads[ Val( aJobAux[ nX , 1 ] ) , 1 ],; 		// 2 - Dt Inicio da Apuracao
											 	  	aThreads[ Val( aJobAux[ nX , 1 ] ) , 2 ],; 		// 3 - Dt Final da Apuracao
												  	cNrLivro,;		// 4 - Numero do Livro
											 	  	lQbAliq,;		// 5 - Quebra por Aliquota
												  	lQbCFO,;		// 6 - Quebra por CFO
												  	/*nRegua*/,;	// 7 - 0=Nao Exibe 1=Processamento 2=Relatorio (em STARTJOB o nRegua nao eh usado)
												  	lEnd,;			// 8 - Flag de InterrupáÑo
												  	nConsFil,;		// 9 - Considera filial
												  	cFilDe,;		// 10 - Filial De
												  	cFilAte,;		// 11 - Filial ate
												  	aEntr,;			// 12 - array com o resumo de ICMS Retido para entrada	 
												  	aSaid,; 		// 13 - array com o resumo de ICMS Retido para saida
												  	cFilUsr,;		// 14 - 
												  	lGeraArq,;		// 15 - Gera Arquivo de Trabalho
												  	cAliasTRB,;		// 16 - 
												  	lQbUF,;	 		// 17 - Quebra por UF	
												  	lQbPais,;		// 18 - Quebra por CÛdigo do Pais	
												  	lQbCfopUf,;		// 19 - Quebra por CFOP+UF e por "Aliquota" caso necessite, mas somente se "lQbUF" e "lQbPais" forem .F.
												  	lImpCrdSt,;		// 20 - 
												  	lMv_UFSt,;		// 21 - 
												  	lCrdEst,;		// 22 - 
												  	aEstimulo,;		// 23 - 
										  		  	lQbUfCfop,;		// 24 - Quebra por UF+CFOP
										  		  	lConsUF,;		// 25 - Indica se, quando a apuracao for consolidada, apenas as filiais estabelecidas no mesmo estado do consolidador sejam processadas
										  		  	aApurCDA,;		// 26 - Array para armazenar lancamentos da apuracao ICMS gravados no CDA
										  		  	aApurF3,;		// 27 - (NAO USADO) - Array para armazenar lancamentos da apuracao ICMS gravados no SF3
										  		  	aCDAIC,;		// 28 - Array para armazenar lancamentos de ajustes da apuracao ICMS gravados no CDA
										  		  	aCDAST,;		// 29 - Array para armazenar lancamentos de ajustes da apuracao ICMS-ST gravados no CDA
										  		  	cChamOrig,; 	// 30 - Funcao que esta chamando
										  		  	nParPerg,;		// 31 - Parametro da pergunta
										  		  	aFilsCalc,;		// 32 - Array das Filiais Selecionadas
										  		  	aApurMun,;		// 33 - Array com os valores de ISS por municipio
												  	lICMDes,;		// 34 - Indica se havera calculo Credito ICMS Relat. Art.271 RICMS/SP		   
												  	aIcmPago,;		// 35 - Array para armazenar valores de GNRE ja pagos na emissao do documento
												  	lICMGar,;   	// 36 - Indica se havera calculo Credito ICMS Garantido Relat. Art.435-N RICMS/MT
												  	aCDADE,;		// 37 - Array contendo os lancamentos de debitos especiais
												  	aRetEsp,;		// 38 - Array que me retorna o lancamento de documento fiscal que corresponde ao valor do ST-Debitado na entrada (_CREDST=3)
												  	lGiaRs,;		// 39 - Identifica se o arquivo de geracao eh o GIARS
												  	nCredMT,;    	// 40 - Indica se calculo Credito Presumido MT
												  	nOpcApur,;		// 41 - Flag de tratamento na geracao do TEMPDB da Apuracao. 1=Refaz Movimento Tabela, 2=Apaga Tabela, 3=Leitura da Tabela
												  	cTempDB,;		// 42 - Nome do temporario criado no RDBMS
												  	cTempDBRes,;	// 43 - TEMPDB de Resumo
												  	cJobFile,;		// 44 - Arquivo semaforo de controle da thread
												  	cJobAux,;		// 45 - Variavel global de controle do status do JOB
												  	FWGrpCompany(),;// 46 - Empresa
							  						FWCodFil(),;	// 47 - Filial
							  						StrZero( nX , 2 ),;//48 - Numero da Thread
							  						lMVRF3LOG,;		//49 - Flag de geracao de CONOUT no console.log
													aRecStDif,;//50
													aMensIPI,;//51																										
													aDifal,;//52
													aCDADifal,;//53
													aCDAExtra,;//54
													aApurExtra,;//55
													aApurCDV,;//56
													aCDAIPI,;//57
													aNWCredAcu,;//58
													lProcRefer,; //59
													cTempDeb,; //60
													cTempCrd,; //61
													cTempSTd,; //62
													cTempSTe,; //63
													cTempIPIs,; //64
													cTempIPIe) //65
							EndIf
							nRetry_1 ++ 
						EndIf
					// TRATAMENTO PARA ERRO DE APLICACAO
					Case GetGlbValue( cJobAux ) == '2'
						If FCreate( cJobFile ) # -1
							ConOut( Replicate( '-' , 65 ) )	
							ConOut( 'FISXAPURA.PRW: ' + STR0112 + aJobAux[ nX , 1 ] )	//Erro de aplicacao na thread '
							ConOut( Replicate( '-' , 65 ) )

							//Atualiza o log de processamento
							ProcLogAtu( 'ERRO',	'( Thread ' + aJobAux[ nX , 1 ] + ' ) ' + STR0113,; //'Erro de aplicacao.'
												'( Thread ' + aJobAux[ nX , 1 ] + ' ) ' + STR0113 ) //'Erro de aplicacao.'

							Final( 'FISXAPURA.PRW: ' + STR0112 + aJobAux[ nX , 1 ] )	//'Erro de aplicacao na thread '
						EndIf
					// THREAD PROCESSADA CORRETAMENTE
					Case GetGlbValue( cJobAux ) == '3'
						// Atualiza o log de processamento
						ProcLogAtu( 'MENSAGEM',	'( Thread ' + aJobAux[ nX , 1 ] + ' ) ' + STR0114,; //Termino do processamento MThread da ResumeF3.'
												'( Thread ' + aJobAux[ nX , 1 ] + ' ) ' + STR0114 ) //Termino do processamento MThread da ResumeF3.'
						If nRegua>0
							If nRegua	==	1
								IncProc( OemToAnsi( STR0103 ) )	//'Processando movimento'
							Else
								IncRegua()
							Endif
						Endif

						Exit
				EndCase

				Sleep(100)
			EndDo
		Next nX

		//Exclusao dos temporarios criados
		For nX := 1 To Len( aJobAux )
			If File( aJobAux[ nX , 2 ] )
				FErase( aJobAux[ nX , 2 ] )
			EndIf
		Next nX
	EndIf

	//Chamando a funcao para como visualizacao para retornar os valores calculados
	ProcLogAtu( 'MENSAGEM',	STR0115,; //'Iniciando leitura da tabela temporaria gerada para retonar os valores calculados.'
							STR0115 ) //'Iniciando leitura da tabela temporaria gerada para retonar os valores calculados.'
								
	//Chamo novamente a funcao, mais com a opcao 3, para somente carregar o array de retorno com as informacoes processadas pela multi-thread	
	aRetorno	:=	XApMThread(cImp,; 		// 1 - Imposto <"IC"MS|"IP"I|"IS"S>
						  dDtIni,; 		// 2 - Dt Inicio da Apuracao
					 	  dDtFim,; 		// 3 - Dt Final da Apuracao
						  cNrLivro,;		// 4 - Numero do Livro
					 	  lQbAliq,;		// 5 - Quebra por Aliquota
						  lQbCFO,;			// 6 - Quebra por CFO
						  nRegua,;			// 7 - 0=Nao Exibe 1=Processamento 2=Relatorio
						  lEnd,;			// 8 - Flag de InterrupáÑo
						  nConsFil,;		// 9 - Considera filial
						  cFilDe,;			// 10 - Filial De
						  cFilAte,;		// 11 - Filial ate
						  @aEntr,;			// 12 - array com o resumo de ICMS Retido para entrada	 
						  @aSaid,; 			// 13 - array com o resumo de ICMS Retido para saida
						  cFilUsr,;		// 14 - 
						  lGeraArq,;		// 15 - Gera Arquivo de Trabalho
						  cAliasTRB,;		// 16 - 
						  lQbUF,;	 		// 17 - Quebra por UF	
						  lQbPais,;		// 18 - Quebra por CÛdigo do Pais	
						  lQbCfopUf,;		// 19 - Quebra por CFOP+UF e por "Aliquota" caso necessite, mas somente se "lQbUF" e "lQbPais" forem .F.
						  lImpCrdSt,;		// 20 - 
						  lMv_UFSt,;		// 21 - 
						  lCrdEst,;		// 22 - 
						  aEstimulo,;		// 23 - 
				  		  lQbUfCfop,;		// 24 - Quebra por UF+CFOP
				  		  lConsUF,;		// 25 - Indica se, quando a apuracao for consolidada, apenas as filiais estabelecidas no mesmo estado do consolidador sejam processadas
				  		  @aApurCDA	,;		// 26 - Array para armazenar lancamentos da apuracao ICMS gravados no CDA
				  		  @aApurF3,;		// 27 - (NAO USADO) - Array para armazenar lancamentos da apuracao ICMS gravados no SF3
				  		  @aCDAIC,;			// 28 - Array para armazenar lancamentos de ajustes da apuracao ICMS gravados no CDA
				  		  @aCDAST,;			// 29 - Array para armazenar lancamentos de ajustes da apuracao ICMS-ST gravados no CDA
				  		  cChamOrig,; 	// 30 - Funcao que esta chamando
				  		  nParPerg	,;		// 31 - Parametro da pergunta
				  		  aFilsCalc,;		// 32 - Array das Filiais Selecionadas
				  		  @aApurMun,;		// 33 - Array com os valores de ISS por municipio
						  lICMDes,;		// 34 - Indica se havera calculo Credito ICMS Relat. Art.271 RICMS/SP		   
						  @aIcmPago,;		// 35 - Array para armazenar valores de GNRE ja pagos na emissao do documento
						  lICMGar,;   	// 36 - Indica se havera calculo Credito ICMS Garantido Relat. Art.435-N RICMS/MT
						  @aCDADE,;			// 37 - Array contendo os lancamentos de debitos especiais
						  @aRetEsp,;		// 38 - Array que me retorna o lancamento de documento fiscal que corresponde ao valor do ST-Debitado na entrada (_CREDST=3)
						  lGiaRs,;			// 39 - Identifica se o arquivo de geracao eh o GIARS
						  nCredMT,;    	// 40 - Indica se calculo Credito Presumido MT
						  3,;				// 41 - Flag de tratamento na geracao do TEMPDB da Apuracao. 1=Refaz Movimento Tabela, 2=Apaga Tabela, 3=Leitura da Tabela
						  cTempDB,;		// 42 - Nome do temporario criado no RDBMS
						  cTempDBRes,,,,,,,;	// 43 - TEMPDB de Resumo
						  @aRecStDif,;
						  @aMensIPI,;						  
						  @aDifal,;
						  @aCDADifal,;
						  @aCDAExtra,;
						  @aApurExtra,;
						  @aApurCDV,;
						  @aCDAIPI,;
						  @aNWCredAcu,;
						  lProcRefer,; //59
						  cTempDeb,; //60
						  cTempCrd,; //61
						  cTempSTd,; //62
						  cTempSTe,; //63
						  cTempIPIs,; //64
						  cTempIPIe) //65

	//Chamando a funcao para como visualizacao para retornar os valores calculados
	ProcLogAtu( 'MENSAGEM',	STR0116,; //'Finalizando leitura da tabela temporaria gerada para retonar os valores calculados.'
							STR0116 ) //'Finalizando leitura da tabela temporaria gerada para retonar os valores calculados.'

	//Quando for visualizacao nao eh feito LOCKBYNAME
	If nOpcApur <> 3
		UnLockByName( 'XApurRF3Nw_' + cLockTDB , .T. , .T. )
	EndIf
EndIf
Return aRetorno

Function XApMThread(cImp,; 			// 1 - Imposto <"IC"MS|"IP"I|"IS"S>
					dDtIni,; 		// 2 - Dt Inicio da Apuracao
					dDtFim,; 		// 3 - Dt Final da Apuracao
					cNrLivro,;		// 4 - Numero do Livro
					lQbAliq,;		// 5 - Quebra por Aliquota
					lQbCFO,;		// 6 - Quebra por CFO
					nRegua,;		// 7 - 0=Nao Exibe 1=Processamento 2=Relatorio
					lEnd,;			// 8 - Flag de InterrupáÑo
					nConsFil,;		// 9 - Considera filial
				  	cFilDe,;		// 10 - Filial De
				  	cFilAte,;		// 11 - Filial ate
				  	aEntr,;			// 12 - array com o resumo de ICMS Retido para entrada	 
				  	aSaid,; 		// 13 - array com o resumo de ICMS Retido para saida
				  	cFilUsr,;		// 14 - 
				  	lGeraArq,;		// 15 - Gera Arquivo de Trabalho
				  	cAliasTRB,;		// 16 - 
				  	lQbUF,;	 		// 17 - Quebra por UF	
				  	lQbPais,;		// 18 - Quebra por CÛdigo do Pais	
				  	lQbCfopUf,;		// 19 - Quebra por CFOP+UF e por "Aliquota" caso necessite, mas somente se "lQbUF" e "lQbPais" forem .F.
				  	lImpCrdSt,;		// 20 - 
				  	lMv_UFSt,;		// 21 - 
				  	lCrdEst,;		// 22 - 
				  	aEstimulo,;		// 23 - 
		  		  	lQbUfCfop,;		// 24 - Quebra por UF+CFOP
		  		  	lConsUF,;		// 25 - Indica se, quando a apuracao for consolidada, apenas as filiais estabelecidas no mesmo estado do consolidador sejam processadas
		  		  	aApurCDA,;		// 26 - Array para armazenar lancamentos da apuracao ICMS gravados no CDA
		  		  	aApurF3,;		// 27 - (NAO USADO) - Array para armazenar lancamentos da apuracao ICMS gravados no SF3
		  		  	aCDAIC,;		// 28 - Array para armazenar lancamentos de ajustes da apuracao ICMS gravados no CDA
		  		  	aCDAST,;		// 29 - Array para armazenar lancamentos de ajustes da apuracao ICMS-ST gravados no CDA
		  		  	cChamOrig,; 	// 30 - Funcao que esta chamando
		  		  	nParPerg	,;	// 31 - Parametro da pergunta
		  		  	aFilsCalc,;		// 32 - Array das Filiais Selecionadas
		  		  	aApurMun,;		// 33 - Array com os valores de ISS por municipio
				  	lICMDes,;		// 34 - Indica se havera calculo Credito ICMS Relat. Art.271 RICMS/SP		   
				  	aIcmPago,;		// 35 - Array para armazenar valores de GNRE ja pagos na emissao do documento
				  	lICMGar,;   	// 36 - Indica se havera calculo Credito ICMS Garantido Relat. Art.435-N RICMS/MT
				  	aCDADE,;		// 37 - Array contendo os lancamentos de debitos especiais
				  	aRetEsp,;		// 38 - Array que me retorna o lancamento de documento fiscal que corresponde ao valor do ST-Debitado na entrada (_CREDST=3)
				  	lGiaRs,;		// 39 - Identifica se o arquivo de geracao eh o GIARS
				  	nCredMT,;    	// 40 - Indica se calculo Credito Presumido MT
				  	nOpcApur,;		// 41 - Flag de tratamento na geracao do TEMPDB da Apuracao. 1=Refaz Movimento Tabela, 2=Apaga Tabela, 3=Leitura da Tabela
				  	cTempDB,;		// 42 - Nome do temporario criado no RDBMS
				  	c2TempDB,;		// 43 - TEMPDB de Resumo
				  	cJobFile,;		// 44 - Arquivo semaforo de controle da thread
				  	cJobAux,;		// 45 - Variavel global de controle do status do JOB
				  	cEmpProc,;		// 46 - Empresa
					cFilProc,;		// 47 - Filial
					cNThread,;		// 48 - Numero da Thread
					lMVRF3LOG,;		// 49 - Flag de geracao de CONOUT no console.log	        
					aRecStDif,;//50
					aMensIPI,;	//51									
					aDifal,;//52
					aCDADifal,;//53
					aCDAExtra,;//54
					aApurExtra,;//55
					aApurCDV,;//56
					aCDAIPI,;//57
					aNWCredAcu,;//58
					lProcRefer,; //59
					cTempDeb,; //60
					cTempCrd,; //61
					cTempSTd,; //62
					cTempSTe,; //63
					cTempIPIs,; //64
					cTempIPIe) //65					
					
Local 	aApuracao	:=	{}
Local 	aArea     	:= 	GetArea()
Local	cAliasSF3	:=	GetNextAlias()
Local 	lMapResumo	:= .F.
Local 	aCredAcu    := 	{0,0}
Local	aTam		:=	{}
Local	aCampos		:= 	{}
Local	aCamposSF3 	:= 	{}
Local	cAlsTempDB	:=	'TMPRF3'
Local	c2AlsTempDB	:=	'TMP2RF3'
Local	dDtAnt		:=	CToD( '  /  /  ' )
Local	cMsg		:=	OemToAnsi( STR0001 ) //"Executando apuracaáÑo..."
Local 	nPos		:= 	0
Local 	nAliq		:= 	0
Local 	cCFO		:= 	''
Local	cA1PAIS		:=	''
Local	cA2PAIS		:=	''
Local	nVlrAnti	:=	0
Local 	cSimpNac    := 	""
Local 	lAtivo   	:= 	.F.
Local 	lConsumo 	:= 	.F.
Local 	nValAti  	:= 	0
Local	nValCon  	:= 	0
Local	nPorAti  	:= 	0
Local	nPorCon  	:= 	0
Local	cChaveSD1	:=	""
Local	nX			:=	0
Local	lCDC		:=	.F.
Local 	lChkGnre	:= 	aIcmPago <> NIL
Local 	aDbEsp 		:=	{}
Local 	aNfDupl     := 	{}
Local	cDtCanc 	:= 	''
Local	cCmpA1A2	:=	''
Local	cCmpSFT		:=	''
Local	cECmpD1D2	:=	''
Local	cECmpF1F2	:=	''
Local	cSCmpD1D2	:=	''
Local	cSCmpF1F2	:=	''
Local 	nRegEmp 	:= 	0
Local	aCrdAcAux	:=	{}
Local	nTotCDM		:=	0
Local	nTotEst		:=	0
Local	cSkTempDB	:=	''
Local	cCmpSF4		:=	''
Local	cChvSF3		:=	''
Local	cChvNF		:=	''
Local	lNewSF3		:=	.F.
Local	lNewNF		:=	.F.
Local	nHd1		:=	0
Local 	nRecBrut	:= 	0
Local	cPerThread	:=	''
Local 	nDiasAcreDt	:= 	Nil
Local	nLock		:=	0
Local	lLock		:=	.F.
Local	lSeek		:=	.F.
Local	cArqTRB		:=	''
Local	cQuery		:=	''
Local 	aStruSF3  	:= 	Nil
Local	nLoop		:=	0
Local	nCtd		:=	1
Local	nAcCtd		:=	0
Local	cLoop		:=	''
Local 	cAliasNotas := "NFSF3"
Local 	lApurICM  	:= 	.F. //aExistBloc[PE_APURICM]
Local	aNFsGiaRs	:=	{}
Local	laPais		:=	.F.
Local  cNCMESTC	:= ""
Local  lESTCRPR	:= "" 

Local 	cMvEstado 	:= 	Nil
Local 	lUsaCfps	:= 	Nil
Local 	cCFATGMB	:= 	Nil
Local 	lTransp   	:= 	Nil
Local 	cMV_StUf	:=	Nil
Local 	cMV_StUfS	:=	Nil
Local	lUfBA		:= 	Nil
Local	lMVCONSCGC	:=	Nil
Local 	lMesAnti	:= 	Nil
Local 	cCredOut	:= 	Nil
Local 	nPercCrOut	:= 	Nil
Local 	lRegEsp	:= 	Nil
Local 	lTransST	:= 	Nil
Local 	nFust		:=	Nil
Local 	nFunttel	:= 	Nil
Local 	lUfRj		:= 	Nil
Local 	lUfSE		:= 	Nil
Local 	lUsaSped	:= 	Nil
Local	cMVISS		:=	Nil
Local 	cLeiteIn	:= 	Nil
Local	aMVDESENV	:=	Nil 
Local	aMVFISCPES	:=	Nil

Local 	lAnticms	:= 	Nil
Local 	lCredAcu	:= 	Nil
Local 	lNWCredAcu	:= 	Nil
Local	lFTESTCRED	:=	Nil
Local	lB1FECOP	:=	Nil
Local	lB1ALFECOP	:=	Nil
Local	lB1ALFECST	:=	Nil
Local	lFTVALFUM	:=	Nil
Local	lFTCRDPCTR	:=	Nil		
Local	lFTCREDPRE	:=	Nil
Local	lB1PRODREC	:=	Nil
Local	lFTCRPREPR	:=	Nil
Local	lFTCPRESPR	:=	Nil
Local	lFTCRPRERO	:=	Nil
Local	lFTCRPREPE	:=	Nil
Local	lFTCPPRODE	:=	Nil 
Local	lFTTPPRODE	:=	Nil
Local	lFTCRPRESP	:=	Nil
Local	lFTCROUTGO	:=	Nil
Local	lFTCROUTSP	:=	Nil
Local	lA1REGPB	:=	Nil
Local	lF4PRZESP	:=	Nil
Local  lF4MKPCMP	:= Nil
Local  lF4FTATUSC	:= Nil
Local  lF4IPI  	:=  Nil
Local	lF4ESCRDPR	:=	Nil
Local	lFTVALTST	:=	Nil
Local	lFTCRPRELE	:=	Nil
Local	lFTVALFDS	:=	Nil
Local	lFTVLSENAR	:=	Nil
Local	lFTCRPRSIM	:=	Nil 
Local	lFTDS43080	:=	Nil
Local	lFTPR43080	:=	Nil
Local	lFTVFESTMT	:=	Nil	
Local	lF4VARATAC	:=	Nil
Local	lFTVALANTI	:=	Nil
Local	lA2SIMPNAC	:=	Nil
Local	lFTVFECPST	:=	Nil
Local	lFTVALFECP	:=	Nil
Local	lFTVFECPRN	:=	Nil
Local	lFTVFESTRN	:=	Nil
Local	lFTVFECPMG	:=	Nil
Local	lFTVFESTMG	:=	Nil
Local	lFTVFECPMT	:=	Nil
Local	lB1RICM65	:=	Nil
Local	lF4CRLEIT	:=	Nil
Local 	lF3Cnae	:= 	Nil
Local	lF3CODRSEF	:=	Nil
Local	lB5PROJDES	:=	Nil
Local	lF4IPIPECR	:=  Nil
Local	lF4TXAPIPI	:=  Nil
Local	lApGIEFD	:=	Nil
Local 	cCodPais	:= ""
Local	aCodPais	:= {}
Local   cTipoMov	:= ""  
Local   cIpi		:= ''      
Local	nFTVALCONT	:= 0
Local  nVlrBase	:= 0
Local  nICMAliq	:= 0
Local  nDifVlr		:= 0
Local  nCrOutPrtg	:= 0
Local  nRedPrtg	:= 0		
Local cMvFPadISS 	:= ""
Local cMunic	:= ""
Local cDescMun := ""
Local cForISS := ""
Local cChvMun := ""	
Local cPrefixo := ""
Local cChaveSE2 := ""
Local nPosMun := 0
//Local lProRurPf := .F. //Produtor rural pessoa fisica
Local lProRurPJ	:= .F.	//Produtor rural pessoa jurÌdica
Local cMvCODRSEF := ""
Local cLojISS := ""
Local aFornISS := {}
Local lFTDIFAL	:=	.F.
Local lFTVFCPDIF	:=	.F.
Local lFTPDDES	:=	.F.
Local nPosDifal	:= 0
Local cMV_SubTr	:= ''
Local cMV_DifTr	:= ''
Local dDTCOREC	:= "" //data de corte - estorno cred. pres.	
Local lEstCreImp := .F.
Local cEstE310 	:= ""
Local lFTBSICMOR	:= .F.
Local lF3BSICMOR	:= .F.
Local aGetIncent	:=	{}
Local lMVCDIFBEN 	:= .F.
Local aCfopDsv		:=	{}
Local cMVUFECSEP	:= ''
Local lMVUFICSEP	:= .F.
Local lIncsol		:= .F.
Local lFTVALPRO		:=	Nil
Local lFTVALFEEF 	:=	.F.
Local lFTALFCCMP 	:=	.F.
Local lconv13906	:= Nil
Local lJuridica		:= .F.
Local nTamTpDoc 	:= 0
Local lMVRF3THRE	:=	Nil
Local lFomentGO		:= nil
Local cCfMeraMov	:= nil	
Local cCfCrdFo   	:= nil	
Local lOrigIPI		:= Nil	
Local nPoscred		:= 0
Local nLimite		:= 0
Local nAliqIcm		:= 0
Local nImport		:= 0
Local aSubAp		:= {}
Local cProRurPJ 	:= ""
Local lConfApur 	:= .F.
Local cAlsDeb		:= "ICMSDEB"
Local cAlsCrd		:= "ICMSCRD"
Local cAlsSTd		:= "STDEB"
Local cAlsSTe		:= "STCRD"
Local cAlsIPIs		:= "IPIDEB"
Local cAlsIPIe		:= "IPICRD"
Local lAliasApur	:= .T.
Local lDIMESC		:=	IsInCallStack('DIMESC')
Local cMV_STNIEUF	:= ""
Local cMV_1DUPREF 	:= "" 

Local lFunname		:= IIf(FunName()=="MATA953",.T.,.F.)

Default lUfBA		:= 	Nil
Default aEntr 		:= 	{}
Default aSaid 		:= 	{}

Default cFilUsr		:= 	""
Default lGeraArq  	:= 	.F.
Default cAliasTRB 	:= 	""

Default lQbUF 	  	:= 	.F.
Default lQbPais		:= 	.F.
Default lQbCfopUf 	:= 	.F.
Default lImpCrdSt 	:= 	.F.
Default lMv_UFSt  	:= 	.F.
Default	lCrdEst		:=	.F.
Default aEstimulo 	:= 	{}
Default lQbUfCfop 	:= 	.F.
Default lConsUf   	:= 	.F.
Default aApurCDA  	:= 	{}
Default aApurF3		:= 	{}	//(NAO USADO)
Default aCDAIC	  	:= 	{}
Default aCDAST	  	:= 	{}
Default cChamOrig 	:= 	""
Default nParPerg  	:= 	0
Default aFilsCalc 	:= 	{}
Default aApurMun  	:= 	Nil
Default lICMDes		:=	.F.
Default aIcmPago	:=	{}
Default lICMGar		:=	.F.
Default aCDADE	  	:= 	{}
Default	aRetEsp		:= 	{}
Default lGiaRs    	:= 	.F.   
Default	nCredMT 	:= 	0
Default	nOpcApur	:=	1
Default	cTempDB		:=	''	//Nome do TEMPDB a ser criado no RDBMS
Default	cJobFile	:=	''
Default	cJobAux		:=	''
Default	cEmpProc	:=	''
Default	cFilProc	:=	''
Default	lMVRF3LOG	:=	.F. 
Default	aRecStDif	:= {}
Default aMensIPI	:= {}
Default aDifal	:= {} 
Default aCDADifal	:= {}
Default aCDAExtra	:= {}
Default aApurExtra	:= {}
DEFAULT aApurCDV	:= {} 
DEFAULT aCDAIPI		:= {} 
DEFAULT aNWCredAcu	:= {}


Do Case
	Case cImp	==	"IC"
		lQbAliq	:=	IIf( lQbAliq == NIL ,.T. , lQbAliq )
		lQbCFO	:=	IIf( lQbCFO == NIL , .T. , lQbCFO )

	Case cImp	==	"IP"
		lQbAliq	:=	IIf( lQbAliq == NIL , .F. , lQbAliq )
		lQbCFO	:=	IIf( lQbCFO == NIL , .T. , lQbCFO )

	Case cImp	==	"IS"
		lQbAliq	:=	IIf( lQbAliq == NIL ,.T. , lQbAliq )
		lQbCFO	:=	IIf( lQbCFO == NIL , .T. , lQbCFO )
EndCase
lQbCfopUf	:=	IIf((lQbUf .Or. lQbPais),.F.,lQbCfopUf)

cPerThread	:=	StrZero( Day( dDtIni ) , 2 ) + '/' + StrZero( Month( dDtIni ) , 2 ) + '/' + StrZero( Year( dDtIni ) , 4 ) + ' a '	
cPerThread	+=	StrZero( Day( dDtFim ) , 2 ) + '/' + StrZero( Month( dDtFim ) , 2 ) + '/' + StrZero( Year( dDtFim ) , 4 )

//nOpcApur igual a '1', forca reprocessamento do movimento atual e recriacao da tabela
If nOpcApur == 1
	// Apaga arquivo ja existente
	If File( cJobFile )
		FErase( cJobFile )
	EndIf

	// Criacao do arquivo de controle de jobs
	nHd1 := MSFCreate( cJobFile )

	// STATUS 1 - Iniciando execucao do Job
	PutGlbValue( cJobAux , "1" )
	GlbUnLock()

	// Seta job para nao consumir licensas
	RpcSetType( 3 )

	// Seta job para empresa filial desejada
	RpcSetEnv( cEmpProc , cFilProc , , , 'FIS' )

	// STATUS 2 - Conexao efetuada com sucesso
	PutGlbValue( cJobAux , "2" )
	GlbUnLock()

	PtInternal( 1 , 'Thread( ' + cNThread + ' ) - ' + STR0117 + ' ( de ' + cPerThread + ' )' )	//'Processando movimento  do perÌodo'
	TcInternal( 1 , 'ResumeF3 - Thread( ' + cNThread + ' ) - ' + STR0117 + ' ( de ' + cPerThread + ' )' )	//'Processando movimento  do perÌodo'

	//condicao para gerar o mensagem no console.log
	If lMVRF3LOG
		ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0118 + ' ( de ' + cPerThread + ' ) - Thread: ' + cNThread )	//'Iniciando processamento do movimento'
	EndIf

	
	aApurSX2		:=	LoadX2Apur()
	aApurSX3		:=	LoadX3Apur()	
	aExistBloc		:=	LoadPEApur()
	aFindFunc		:=  LoadXFFApur()
	_INTTMS			:=  IntTms()

	IF FWModeAccess( 'SX5' , 3 ) == 'C'
		//Carrega CFOPs SX5 unica vez caso seja compartilhada
		ApurVerCFO(,.T.)
	EndIf
	
	cMV_1DUPREF 	:= SuperGetMV("MV_1DUPREF")
	lApurICM  	:= 	aExistBloc[PE_APURICM]
	lCDC		:=	ChkFile( 'CDC' )
	nTamTpDoc 	:= TamSX3("F6_TIPODOC")[1]
	cDtCanc 	:= 	Space( TamSx3( "F3_DTCANC" )[ 1 ] )
	nRegEmp 	:= 	SM0->( RecNo() )
	aStruSF3  	:= 	SF3->(dbStruct())	
	cMV_SubTr	:=	IIf(aFindFunc[FF_GETSUBTRIB], GetSubTrib(), SuperGetMv("MV_SUBTRIB"))
	cMV_DifTr	:=	IIf(aFindFunc[FF_GETSUBTRIB], GetSubTrib("",.T.), SuperGetMv("MV_SUBTRIB")) // Pega IE de Difal
	cMvEstado 	:= 	SuperGetMv( "MV_ESTADO" )
	lUsaCfps	:= 	SuperGetMV( "MV_USACFPS" )
	cCFATGMB	:= 	SuperGetMv( "MV_CFATGMB" )
	lTransp   	:= 	SuperGetMV( "MV_CONFRE" , .F. , .T. )
	cMV_StUf	:=	SuperGetMV( "MV_STUF" )	// Define os estados a serem utilizados para o artigo 281
	cMV_StUfS	:=	SuperGetMV( "MV_STUFS" )	// Define os estados a serem utilizados para o artigo 281 - para as saidas
	lUfBA		:= 	SuperGetMv( 'MV_ESTADO' ) == 'BA'
	lMVCONSCGC	:=	GetNewPar ( 'MV_CONSCGC' , .F. )
	lMesAnti	:= 	GetNewPar ( 'MV_MESANTI' , .F. )
	cCredOut	:= 	GetNewPar ( 'MV_CROUTSP' , '')
	nPercCrOut	:= 	GetNewPar ( 'MV_MTR9281' , 20 ) / 100
	lRegEsp		:= 	SuperGetMv( 'MV_REGESP' ) > 0	//Desconsiderar Devolucao de Compra e Envio para Beneficiamento - Implementacao do P9AutoText do RJ
	lTransST	:= 	SuperGetMv( 'MV_TRANSST' ) .And. SuperGetMv( 'MV_ESTADO' )$"MG/SC"
	nFust		:=	GetNewPar ( "MV_FUST" , 0 )
	nFunttel	:= 	GetNewPar ( "MV_FUNTTEL" , 0 )
	lUfRj		:= 	SuperGetMv( 'MV_ESTADO' ) == 'RJ'
	lUfBA		:= 	SuperGetMv( 'MV_ESTADO' ) == 'BA'
	lUfSE		:=	SuperGetMv( 'MV_ESTADO' ) == 'SE'
	lUsaSped	:= 	SuperGetMv( "MV_USASPED" ,, .T. ) .And. aApurSX2[AI_CDH]  .And. aApurSX2[AI_CDA]  .And. aApurSX2[AI_CC6] 
	lApGIEFD	:=	SuperGetMv( "MV_GIAEFD"	,,	.F. ) .And. aApurSX2[AI_F3K]  .And. aApurSX2[AI_CDV]  .And. aApurSX2[AI_CDY] 	
	cMVISS		:=	SuperGetMv( "MV_ISS" )
	cLeiteIn	:= 	GetNewPar ( "MV_PRODLEI" , "" )
	aMVDESENV	:=	&(GetNewPar("MV_DESENV","{}") )
	aMVFISCPES	:=	&(GetNewPar("MV_FISCPES","{}") )
	cMvFPadISS := SuperGetMv("MV_FPADISS", .F., "")
	cMvCODRSEF  := SuperGetMv("MV_CODRSEF", .F., "'','100'")
	lEstCreImp	:= SuperGetMv("MV_ESTCIMP", .F., .F.)		
	cMvCODRSEF := IIF(Empty(cMvCODRSEF), "'','100'", cMvCODRSEF)
	cNCMESTC	:= GetNewPar('MV_NCMESTC', "")
	lESTCRPR	 := GetNewPar('MV_ESTCRPR', .F.)
	dDTCOREC	:= GetNewPar('MV_DTCOREC', "") //data de corte - estorno cred. pres.
	cEstE310	:= SuperGetMv("MV_ESTE310",.F.,"")
	cMVUFECSEP	:= SuperGetMv("MV_UFECSEP",.F.,"MG|AL|CE|DF|ES|MA|MS|PB|PE|PI|SE|RS")
	lMVCDIFBEN := SuperGetMV("MV_CDIFBEN", .F., .F.)
	lMVUFICSEP	:= cMvEstado$SuperGetMv("MV_UFICSEP",.F.,"")
	lMVRF3THRE	:=	GetNewPar( 'MV_RF3THRE' , .F. )
	lFomentGO	:= (GetNewPar("MV_ESTADO","")=="GO".And. GetNewPar("MV_FOMENGO",.F.))
	cCfMeraMov	:= GetNewPar("MV_MERAMOV",'') + '/5901/5902/5903/5905/5923/5924/5925/5934/6901/6903/6905/6923/6924/6925/6934' 	
	cCfCrdFo	:= GetNewPar("MV_CRDFOM",'') 
	lConfApur 	:= SuperGetMv("MV_CONFAPU",,.F.)
	aCfopDsv	:= xApCfopDef( "DES" )	
	lFTVFESTMT	:=	aApurSX3[FP_FT_VFESTMT]	
	lFTDS43080	:=	aApurSX3[FP_FT_DS43080]	
	lFTPR43080	:=	aApurSX3[FP_FT_PR43080]	
	lAnticms	:= 	aApurSX3[FP_F3_VALANTI]	
	lCredAcu	:= 	aApurSX3[FP_F3_CREDACU]		
	lNWCredAcu	:= lCredAcu .And. GetNewPar( 'MV_CREDACU' , .F. ) .And. aApurSX2[AI_F2P] .And. aApurSX2[AI_F2R]  //#TODO verifica parametros e campos dicionario
	lFTESTCRED := aApurSX3[FP_FT_ESTCRED]	
	lB1FECOP   := aApurSX3[FP_B1_FECOP]		
	lB1ALFECOP := aApurSX3[FP_B1_ALFECOP]	
	lB1ALFECST := aApurSX3[FP_B1_ALFECST]	
	lFTVALFUM  := aApurSX3[FP_FT_VALFUM]	
	lFTCRDPCTR := aApurSX3[FP_FT_CRDPCTR]	
	lFTCREDPRE := aApurSX3[FP_FT_CREDPRE]	
	lB1PRODREC := aApurSX3[FP_B1_PRODREC]	
	lFTCRPREPR := aApurSX3[FP_FT_CRPREPR]	
	lFTCPRESPR := aApurSX3[FP_FT_CPRESPR]	
	lFTCRPRERO := aApurSX3[FP_FT_CRPRERO]	
	lFTCRPREPE := aApurSX3[FP_FT_CRPREPE]	
	lFTCPPRODE := aApurSX3[FP_FT_CPPRODE]	
	lFTTPPRODE := aApurSX3[FP_FT_TPPRODE]	
	lFTCRPRESP := aApurSX3[FP_FT_CRPRESP]	
	lFTCROUTGO := aApurSX3[FP_FT_CROUTGO]	
	lFTCROUTSP := aApurSX3[FP_FT_CROUTSP]	
	lA1REGPB   := aApurSX3[FP_A1_REGPB]		
	lF4PRZESP  := aApurSX3[FP_F4_PRZESP]	
	lF4MKPCMP  := aApurSX3[FP_F4_MKPCMP]	
	lF4FTATUSC := aApurSX3[FP_F4_FTATUSC]	
	lF4IPI     := aApurSX3[FP_F4_IPI]		
	lF4ESCRDPR := aApurSX3[FP_F4_ESCRDPR]	
	lFTVALTST  := aApurSX3[FP_FT_VALTST]	
	lFTCRPRELE := aApurSX3[FP_FT_CRPRELE]	
	lFTVALFDS  := aApurSX3[FP_FT_VALFDS]	
	lFTVLSENAR := aApurSX3[FP_FT_VLSENAR]	
	lFTCRPRSIM := aApurSX3[FP_FT_CRPRSIM]	
	lF4VARATAC := aApurSX3[FP_F4_VARATAC]	
	lFTVALANTI := aApurSX3[FP_FT_VALANTI]	
	lA2SIMPNAC := aApurSX3[FP_A2_SIMPNAC]	
	lFTVFECPST := aApurSX3[FP_FT_VFECPST]	
	lFTVALFECP := aApurSX3[FP_FT_VALFECP]	
	lFTVFECPRN := aApurSX3[FP_FT_VFECPRN]	
	lFTVFESTRN := aApurSX3[FP_FT_VFESTRN]	
	lFTVFECPMG := aApurSX3[FP_FT_VFECPMG]	
	lFTVFESTMG := aApurSX3[FP_FT_VFESTMG]	
	lFTVFECPMT := aApurSX3[FP_FT_VFECPMT]	
	lB1RICM65  := aApurSX3[FP_B1_RICM65]	
	lF4CRLEIT  := aApurSX3[FP_F4_CRLEIT]	
	lF3Cnae    := aApurSX3[FP_F3_CNAE]		
	lF3CODRSEF := aApurSX3[FP_F3_CODRSEF]	
	lB5PROJDES := aApurSX3[FP_B5_PROJDES]	
	lconv13906 := aApurSX3[FP_FT_CV139]		
	lF4IPIPECR := aApurSX3[FP_F4_IPIPECR]	
	lF4TXAPIPI := aApurSX3[FP_F4_TXAPIPI]	
	lFTDIFAL   := aApurSX3[FP_FT_DIFAL]		
	lFTVFCPDIF := aApurSX3[FP_FT_VFCPDIF]	
	lFTBSICMOR := aApurSX3[FP_FT_BSICMOR]	
	lF3BSICMOR := aApurSX3[FP_F3_BSICMOR]	
	lFTPDDES   := aApurSX3[FP_FT_PDDES]		
	lFTVALPRO  := aApurSX3[FP_FT_VALPRO]	
	lFTVALFEEF := aApurSX3[FP_FT_VALFEEF]	
	lFTALFCCMP := aApurSX3[FP_FT_ALFCCMP]	
	lOrigIPI   := aApurSX3[FP_CDA_ORIGEM] .And. aApurSX3[FP_CDP_TPLANC]
	aSubAp     :={(aApurSX3[FP_CDO_SUBAP]),(aApurSX3[FP_CC6_SUBAP])}
	cMV_STNIEUF	:= SuperGetMV("MV_STNIEUF")
	cMV_1DUPREF := SuperGetMV("MV_1DUPREF")
	
	//Fiz este tratamento, pois em alguns ambiente o par‚metro MV_CONFRE È criado como caracter, estava errado no ATUSX, pois deveria ser do tipo lÛgico.
	IF valtype(lTransp) == 'C'
		IF 'T' $ lTransp 
			lTransp	:= .T.
		Else
			lTransp	:= .F.
		EndIF
	EndIf

	/*
		Verificacao do preenchimento do parametro MV_FPADISS: Se o usuario optar por utilizar uma loja
		diferente de "00" (padr„o), o codigo do fornecedor e da loja devem ser separados por ";". Caso
		o parametro nao seja preenchido desta forma sera considerado o tratamento anterior.
	*/

	If !Empty(cMvFPadISS)
		If AT(";",cMvFPadISS) > 0
			aFornISS := StrToKarr(cMvFPadISS, ";")

			If Len(aFornISS) >= 2
				cMvFPadISS := PadR(aFornISS[1], TamSX3("A2_COD")[1]) + PadR(aFornISS[2], TamSX3("A2_LOJA")[1])
			Else
				cMvFPadISS := PadR(aFornISS[1], TamSX3("A2_COD")[1]) +	PadR("00", TamSX3("A2_LOJA")[1])
			EndIf
		Else
			cMvFPadISS := PadR(cMvFPadISS, TamSX3("A2_COD")[1]) + PadR("00", TamSX3("A2_LOJA")[1])		
		EndIf
	EndIf

	nDiasAcreDt	:= 	IIf( cMvEstado == "SP" , 9 , IIf( cMvEstado == "PR" , 5 , 0 ) ) //Usada para atender a Legislacao de SP/PR

	//Garanto que executa somente para o ICMS, pois para o ISS que tb utiliza, jah executo no proprio MATA954.
	If cImp == 'IC' .And. nFust > 0 .Or. nFunttel > 0
		nRecBrut	:= 	CalcRB(dDtIni,dDtFim,0,.F.,{},.T.,,,,,,,,,,, dDtIni , dDtFim , 0 , .F. )
	EndIf

	//Trata filiais
	//Caso haja algum parametro sem ser passado ou se nao considera
	//    filiais, a filiais de/ate serao a corrente
	nConsFil	:=	Iif( nConsFil == Nil , 2 , nConsFil )
	If cFilDe == Nil .or. cFilAte == Nil .or. nConsFil == 2
		cFilDe	:= cFilProc
		cFilAte	:= cFilProc
	Endif
	If nConsFil == 1 .and. Len( aFilsCalc ) > 0
		cFilDe	:= Space( Len( cFilProc ) ) 
		cFilAte	:= Replicate( 'Z' , Len( cFilProc ) ) 
	EndIf

	//Define valores default
	lEnd		:=	IIf( lEnd == NIL , .F. , lEnd )
	nRegua		:=	IIf( nRegua == NIL , 0 , nRegua )
	cNrLivro	:=	IIf( cNrLivro == NIL	, "*" , cNrLivro )

	/*	
	TRECHO RETIRADO PORQUE APOS VERIFICACAO COM LIDER DO LOJA (LL), ESTE TRATAMENTO NAO DEVE SER MAIS UTILIZADO NA APURACAO DO IMPOSTO.
	SEGUNDO ELE, ESTE TRATAMENTO NAO TEM SENTIDO, POIS O MAPARESUMO EH UM TRATAMENTO ANTES DO SPED, COM O SPED O LIVRO EH GERADO ON-LINE.
	If SuperGetMV("MV_LJLVFIS",,1) == 2
		If FindFunction("MaxRVerFunc")
			If MaxRVerFunc(cChamOrig)	//Verifica chamada de origem dos Relatorios
				If nParPerg == 1 
					lMapResumo := .T.
				EndIf
			Endif
		EndIf
	EndIf
	*/

	//If lQbPais
		cCodPais	:= GetNewPar( "MV_PAIS" , "{'SA1->A1_CODPAIS','SA2->A2_CODPAIS'}" )	// Informa o nome do campo com o codigo ou sigla do PaÌs(SA1,SA2)
		aCodPais	:= &cCodPais
		laPais		:= ( ValType( aCodPais ) == "A" .And. Len( aCodPais ) >= 1 )
		cA1PAIS	:=	Iif( laPais .And. SA1->( FieldPos( aCodPais[ 1 ] ) ) > 0 , aCodPais[ 1 ] , '' )
		cA1PAIS	:=	Iif( laPais .And. Empty( cA1PAIS ) .And. SA1->( FieldPos( SubStr( aCodPais[ 1 ] , 6 , 10 ) ) ) > 0 , SubStr( aCodPais[ 1 ] , 6 , 10 ) , cA1PAIS )
		cA2PAIS	:=	Iif( laPais .And. SA2->( FieldPos( aCodPais[ 2 ] ) ) > 0 , aCodPais[ 2 ] , '' )
		cA2PAIS	:=	Iif( laPais .And. Empty( cA2PAIS ) .And. SA2->( FieldPos( SubStr( aCodPais[ 2 ] , 6 , 10 ) ) ) > 0 , SubStr( aCodPais[ 2 ] , 6 , 10 ) , cA2PAIS )
	//EndIf

	//Definindo alias e indices para processamento da funcao
	dbSelectArea( "SF6" )
	SF6->( dbSetOrder( 1 ) )
	If lCDC
		dbSelectArea( "CDC" )
		CDC->( dbSetOrder( 1 ) )
	Endif
	dbSelectArea( "SF3" )
	SF3->( dbSetOrder( 1 ) )
	dbSelectArea( "SF8" )
	SF8->( dbSetOrder( 3 ) )
	dbSelectArea( "SF4" )
	SF4->( dbSetOrder( 1 ) )
	dbSelectArea( "SF2" )
	SF2->( dbSetOrder( 1 ) )
	dbSelectArea( "SA2" )
	SA2->(dbSetOrder( 1 ) )
	dbSelectArea( "SE2" )
	SE2->(dbSetOrder( 1 ) )
	DbSelectArea("SC5")
	SC5->(DbSetOrder( 1 ) )
	DbSelectArea("CE1")
	CE1->(dbSetOrder( 1 ) )
	DbSelectArea("CD2")
	CD2->(dbSetOrder( 1 ) )
	If lApGIEFD
		DbSelectArea("F3K")
		F3K->(DbSetOrder( 1 ) )
	Endif
	DbSelectArea("CDY")	
	CDY->(DbSetOrder( 1 ) )

	If TCCanOpen( cTempDB )
		dbUseArea( .T. ,__cRdd , cTempDB , cAlsTempDB , .T. , .F. )
		( cAlsTempDB )->( dbClearIndex() , dbSetIndex( cTempDB + '_01' ) )
	EndIf
	
	If TCCanOpen( c2TempDB )
		dbUseArea( .T. ,__cRdd , c2TempDB , c2AlsTempDB , .T. , .F. )
		( c2AlsTempDB )->( dbClearIndex() , dbSetIndex( c2TempDB + '_01' ) )
	Else
		//c2AlsTempDB È a base para a rotina. Caso ela n„o seja criada pelo dbUseArea o processo deve ser interrompido.
		Return aApuracao
	EndIf

	If cImp == "IC"
		lAliasApur := TCCanOpen(cTempDeb) .AND. TCCanOpen(cTempCrd) .AND.;
			TCCanOpen(cTempSTd) .AND. TCCanOpen(cTempSTe)
	Elseif cImp == "IP"
		lAliasApur := TCCanOpen(cTempIPIs) .AND. TCCanOpen(cTempIPIe)
	EndIf

	If lConfApur .AND. lAliasApur
		If cImp == "IC" 
			//Abrindo TEMPDBs

			dbUseArea( .T. ,__cRdd , cTempDeb , cAlsDeb , .T. , .F. )
			( cAlsDeb )->( dbClearIndex() , dbSetIndex( cTempDeb + '_01' ) )
			
			dbUseArea( .T. ,__cRdd , cTempCrd , cAlsCrd , .T. , .F. )
			( cAlsCrd )->( dbClearIndex() , dbSetIndex( cTempCrd + '_01' ) )
			
			dbUseArea( .T. ,__cRdd , cTempSTd , cAlsSTd , .T. , .F. )
			( cAlsSTd )->( dbClearIndex() , dbSetIndex( cTempSTd + '_01' ) )
			
			dbUseArea( .T. ,__cRdd , cTempSTe , cAlsSTe , .T. , .F. )
			( cAlsSTe )->( dbClearIndex() , dbSetIndex( cTempSTe + '_01' ) )

		ElseIf cImp == "IP"		
			dbUseArea( .T. ,__cRdd , cTempIPIs , cAlsIPIs , .T. , .F. )
			( cAlsIPIs )->( dbClearIndex() , dbSetIndex( cTempIPIs + '_01' ) )
			
			dbUseArea( .T. ,__cRdd , cTempIPIe , cAlsIPIe , .T. , .F. )
			( cAlsIPIe )->( dbClearIndex() , dbSetIndex( cTempIPIe + '_01' ) )
		EndIf
	EndIf
	//Definindo campos do SELECT
	cCmpA1A2	:=	''
	cCmpA1A2	+=	'SA1.A1_INSCR, SA1.A1_TIPO, SA1.A1_EST, SA1.A1_COD_MUN, SA1.A1_CONTRIB, SA1.A1_TPJ, '
	If lQbPais .And. !Empty( cA1PAIS )
		cCmpA1A2	+=	'SA1.' + cA1PAIS + ', '
	EndIf
	cCmpA1A2	+=	'SA2.A2_SIMPNAC, SA2.A2_INSCR, SA2.A2_TIPO, SA2.A2_CONTRIB, SA2.A2_TPJ, '
	If lQbPais .And. !Empty( cA2PAIS )
		cCmpA1A2	+=	'SA2.' + cA2PAIS + ', '
	EndIf

	cCmpSFT	:=	''
	cCmpSFT	+=	'SFT.FT_ITEM,SFT.FT_ISENICM, SFT.FT_VALCONT, SFT.FT_VALICM, SFT.FT_ESTCRED, SFT.FT_BASEICM, SFT.FT_BASERET, SFT.FT_ICMSRET,SFT.FT_PRODUTO, SFT.FT_ALIQICM, '
	cCmpSFT	+=	'SFT.FT_ALQFECP, SFT.FT_CRDPRES, SFT.FT_TIPOMOV, SFT.FT_CRDTRAN, SFT.FT_CRDZFM, SFT.FT_OUTRICM, SFT.FT_ISSSUB, SFT.FT_CREDST, SFT.FT_ANTICMS, ' 
	cCmpSFT	+=	'SFT.FT_ICMAUTO, SFT.FT_ICMSCOM, SFT.FT_ICMSDIF, SFT.FT_TRFICM, SFT.FT_SOLTRIB, SFT.FT_CRPRST, SFT.FT_VALIPI, SFT.FT_ISENIPI, SFT.FT_OUTRIPI, '
	cCmpSFT	+=	'SFT.FT_IPIOBS, SFT.FT_OBSICM, SFT.FT_OBSSOL, SFT.FT_BASEIPI, SFT.FT_ISSMAT, SFT.FT_CFOP,SFT.FT_IDENTF3, SFT.FT_ESTADO,SFT.FT_FRETE, SFT.FT_RECISS, '
	cCmpSFT	+=	'SFT.FT_SERIE,SFT.FT_NFISCAL,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_CLASFIS,SFT.FT_COLVDIF,SFT.FT_QUANT,SFT.FT_EMISSAO,SFT.FT_OUTRRET,SFT.FT_ISENRET,'
	If lFTVFECPST
		cCmpSFT	+=	'SFT.FT_VFECPST, '
	EndIf	
	If lFTVFECPRN
		cCmpSFT	+=	'SFT.FT_VFECPRN, '
	EndIf
	If lFTVFESTRN
		cCmpSFT	+=	'SFT.FT_VFESTRN, '
	EndIf 
	If lFTVALFECP
		cCmpSFT	+=	'SFT.FT_VALFECP, '
	EndIf 
	If lFTCRPRELE
		cCmpSFT	+=	'SFT.FT_CRPRELE, '
	EndIf
	If lFTVALFDS
		cCmpSFT	+=	'SFT.FT_VALFDS, '
	EndIf
	If lFTVLSENAR
		cCmpSFT	+=	'SFT.FT_VLSENAR, '
	EndIf
	If lFTCRPRSIM
		cCmpSFT	+=	'SFT.FT_CRPRSIM, '
	EndIf
	If lFTVALANTI
		cCmpSFT	+=	'SFT.FT_VALANTI, '
	EndIf 
	If lFTVALTST
		cCmpSFT	+=	'SFT.FT_VALTST, '
	EndIf
	If lFTCRPREPE
		cCmpSFT	+=	'SFT.FT_CRPREPE, '
	EndIf
	If lFTTPPRODE
		cCmpSFT	+=	'SFT.FT_TPPRODE, '
	EndIf
	If lFTCPPRODE
		cCmpSFT	+=	'SFT.FT_CPPRODE, '
	EndIf
	If lFTCRPRESP
		cCmpSFT	+=	'SFT.FT_CRPRESP, '
	EndIf
	If lFTCROUTGO
		cCmpSFT	+=	'SFT.FT_CROUTGO, '
	EndIf
	If lFTCROUTSP
		cCmpSFT	+=	'SFT.FT_CROUTSP, '
	EndIf
	If lFTCRPRERO
		cCmpSFT	+=	'SFT.FT_CRPRERO, '
	EndIf
	If lFTCPRESPR
		cCmpSFT	+=	'SFT.FT_CPRESPR, '
	EndIf
	If lFTCRPREPR
		cCmpSFT	+=	'SFT.FT_CRPREPR, '
	EndIf		
	If lFTCRDPCTR
		cCmpSFT	+=	'SFT.FT_CRDPCTR, '
	EndIf
	If lFTCREDPRE
		cCmpSFT	+=	'SFT.FT_CREDPRE, '
	EndIf	
	If lFTVALFUM
		cCmpSFT	+=	'SFT.FT_VALFUM, '
	EndIf	
	If lFTDS43080
		cCmpSFT	+= 'SFT.FT_DS43080, '		
	Endif
	If lFTPR43080
		cCmpSFT += 'SFT.FT_PR43080,' 
	endif
	If lFTVFECPMG
		cCmpSFT	+=	'SFT.FT_VFECPMG, '
	EndIf
	If lFTVFESTMG
		cCmpSFT	+=	'SFT.FT_VFESTMG, '
	EndIf
	If lFTVFECPMT
		cCmpSFT	+=	'SFT.FT_VFECPMT, '
	EndIf	
	If lFTVFESTMT
		cCmpSFT	+=	'SFT.FT_VFESTMT, '
	EndIf
	If lConv13906 
		cCmpSFT	+=	'SFT.FT_CV139, '	
	EndIF

	If lFTDIFAL
		cCmpSFT	+=	'SFT.FT_DIFAL, '
	EndIF
	If lFTVFCPDIF
		cCmpSFT	+=	'SFT.FT_VFCPDIF, '
	EndIF	
	If lFTBSICMOR 
		cCmpSFT	+=	'SFT.FT_BSICMOR, '	
	EndIF	
	If lFTPDDES 
		cCmpSFT	+=	'SFT.FT_PDDES, '	
	EndIF	
	cCmpSFT += 'SFT.FT_TIPO, '		
	If lFTVALPRO
		cCmpSFT	+=	'SFT.FT_VALPRO, '
	EndIf	
	If lFTVALFEEF
		cCmpSFT	+=	'SFT.FT_VALFEEF, '
	EndIf
	If lFTALFCCMP 
		cCmpSFT	+=	'SFT.FT_ALFCCMP, '	
	EndIf

	If lF4PRZESP
		cCmpSF4	+=	'SF4.F4_PRZESP, '
	EndIf

	IF lF4MKPCMP
		cCmpSF4	+=	'F4_MKPCMP, '	
	EndIF
	            
	IF lF4FTATUSC	
		cCmpSF4	+=	'F4_FTATUSC, '		
	EndIF
	IF lF4IPI	
		cCmpSF4	+=	'F4_IPI, '		
	EndIF
	If lF4ESCRDPR
		cCmpSF4	+=	'F4_ESCRDPR, '		
	Endif 
	If lF4CRLEIT
		cCmpSF4	+=	'F4_CRLEIT, '			
	Endif	
	
	If lF4IPIPECR
		cCmpSF4	+=	'F4_IPIPECR, '
	EndIf
	
	If lF4TXAPIPI
		cCmpSF4	+=	'F4_TXAPIPI, ' 
	EndIf
	
	cCmpSF4	+=	'F4_INCSOL, '
	
	//Campos Entrada
	cECmpD1D2 := "SD1.D1_VALICM, 0 D2_VALICM, '' D2_PEDIDO, '' D2_CODISS, '' D2_COD, "
	cECmpF1F2 := "SF1.F1_TIPO, '' F2_TIPOCLI, '' F2_PREFIXO, '' F2_DUPL, '' F2_TIPO "

	//Campos Saida
	cSCmpD1D2	:=	"0 D1_VALICM, SD2.D2_VALICM, SD2.D2_PEDIDO, SD2.D2_CODISS, SD2.D2_COD, "
	cSCmpF1F2	:=	"'' F1_TIPO, SF2.F2_TIPOCLI, SF2.F2_PREFIXO, SF2.F2_DUPL, SF2.F2_TIPO "

	//------------------------------------------------------//--------------------------------------------------------------

	//Tratamento somente para o ICMS
	If cImp == "IC"
		//Processamento de funcoes cumulativas com o mesmo filtro de filiais passados na resumef3.
		//	Esses valores s„o unicos para todos os cfops
		dbSelectArea( "SM0" )
		MsSeek( cEmpAnt + cFilDe , .T. )

		cCgc	:=	SubStr (SM0->M0_CGC, 1, 8)
		//lProRurPf := (SM0->M0_PRODRUR$"F1")
		lProRurPJ := (SM0->M0_PRODRUR$"J2F1")

		While !SM0->( Eof() ) .and. FWGrpCompany( ) + FWCodFil() <= cEmpAnt + cFilAte 
			cFilAnt := FWGETCODFILIAL // Mudar filial atual temporariamente

			If (lMVCONSCGC .And. !(cCgc==SubStr (SM0->M0_CGC, 1, 8)))
				SM0->(DbSkip())
				Loop
			EndIf

			//Atendimento ao Art. 121 do ANEXO 5 do RICMS/SC. O mesmo determina que todo prestador de
			//  serviÁo de transporte deve apresentar as obrigaÁıes acessÛrias de forma consolidada pelo estabelecimento
			//  matriz, e esta consolidaÁ„o dever· abranger somente as empresas que estiverem domiciliadas no mesmo
			//  estado do estabelecimento consolidador.
			If lConsUF .And. (SM0->M0_ESTENT <> cMvEstado)
				SM0->(DbSkip())
				Loop
			EndIf

			//-- Tratamento para utilizacao da MatFilCalc
			If Len( aFilsCalc ) > 0 .And. nConsFil == 1
				nFilial := aScan( aFilsCalc , { |x| Alltrim(x[2]) == Alltrim(cFilAnt) } )
				If nFilial == 0 .or. ( nFilial > 0 .And.  !aFilsCalc[ nFilial , 1 ] )  //Filial n„o encontrada ou n„o marcada, vai para prÛxima
					SM0->(dbSkip())
					Loop
				EndIf
			EndIf

			//Antecipacao de ICMS
			//Somente sera processada a funcao Anticms se existir o campo F3_VALANTI e se o valor da Antecipacao			
			//    a ser exibido for no mes subsequente da entrada da nota fiscal
			If lMesAnti .And. lAnticms
				nVlrAnti += AntIcms( dDtIni , dDtFim )
			Endif

			//Tratamento para Credito Acumulado de ICMS - Bahia 
			//Artigos 106 a 109 do RICMS/BA.
			If lUfBA  .And. lCredAcu
				aCrdAcAux	:=	CredAcum( dDtIni , dDtFim )	//Retorna o valor do credito acumulado para o Estado da BA. - Exportacoes, - Outras hipoteses
				aCredAcu[ 1 ]	+=	aCrdAcAux[ 1 ]
				aCredAcu[ 2 ]	+=	aCrdAcAux[ 2 ]
			Endif

			nTotCDM	+=	TotCDM( dDtIni , dDtFim ) // Totaliza CrÈdito calculado (CDM_ICMENT)
			nTotEst	+=	TotEST( dDtIni , dDtFim ) // Totaliza Estorno do CrÈdito calculado (CDM_ESTORN) das DevoluÁıes Vendas

			If FWModeAccess( "SF3" , 3 ) == "C"
				Exit
			Endif

			SM0->( dbSkip() )
		EndDo
	EndIf
	//---------------------------------------------------------- // ----------------------------------------------

	//Posicionando empresa para inicio do processamento
	dbSelectArea( "SM0" )
	MsSeek( cEmpAnt + cFilDe , .T. )

	cCgc	:=	SubStr (SM0->M0_CGC, 1, 8)

	While !SM0->( Eof() ) .and. FWGrpCompany( ) + FWCodFil() <= cEmpAnt + cFilAte 
		cFilAnt := FWGETCODFILIAL // Mudar filial atual temporariamente

		If (lMVCONSCGC .And. !(cCgc==SubStr (SM0->M0_CGC, 1, 8)))
			SM0->(DbSkip ())
			Loop
		EndIf

		//Atendimento ao Art. 121 do ANEXO 5 do RICMS/SC. O mesmo determina que todo prestador de
		//  serviÁo de transporte deve apresentar as obrigaÁıes acessÛrias de forma consolidada pelo estabelecimento
		//  matriz, e esta consolidaÁ„o dever· abranger somente as empresas que estiverem domiciliadas no mesmo
		//  estado do estabelecimento consolidador.
		If lConsUF .And. (SM0->M0_ESTENT <> cMvEstado)
			SM0->(DbSkip ())
			Loop
		EndIf

		//-- Tratamento para utilizacao da MatFilCalc
		If Len( aFilsCalc ) > 0 .And. nConsFil == 1
			nFilial := aScan( aFilsCalc , { |x| Alltrim(x[2]) == Alltrim(cFilAnt) } )
			If nFilial == 0 .or. ( nFilial > 0 .And. !aFilsCalc[ nFilial , 1 ] )	//Filial n„o marcada, vai para proxima
				SM0->( dbSkip() )
				Loop
			EndIf
		EndIf
		
		

		lJuridica := RetPessoa(SM0->M0_CGC) $ "J2"
		cProRurPJ := SM0->M0_PRODRUR
		//condicao para gerar o mensagem no console.log
		If lMVRF3LOG
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0119 + cEmpAnt + ', Filial: ' + cFilAnt + ' - Thread: ' + cNThread )	//'Filtrando movimento no SGBD para a Empresa: '
		EndIf

		cQuery	:=	XApGetQry(cImp , dDtIni , dDtFim , nDiasAcreDt , cNrLivro ,lF3Cnae ,lF3CODRSEF ,cCmpA1A2 + cCmpSFT , cECmpF1F2 , cSCmpF1F2 , cECmpD1D2 , cSCmpD1D2 , cCmpSF4 , cDtCanc, aStruSF3, cMvCODRSEF)
		dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cQuery ) , cAliasSF3 )

		For nX := 1 To Len( aStruSF3 )
			If aStruSF3[ nX , 2 ] <> "C" .And. ( cAliasSF3 )->( FieldPos( aStruSF3[ nX , 1 ] ) ) <> 0
				TcSetField( cAliasSF3 , aStruSF3[ nX , 1 ] , aStruSF3[ nX , 2 ] , aStruSF3[ nX , 3 ] , aStruSF3[ nX , 4 ] )
			EndIf
		Next nX

		//condicao para gerar o mensagem no console.log
		If lMVRF3LOG
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0120 + ' - Thread: ' + cNThread )	//'Executando laÁo do processamento da query'
		EndIf

		//Carrega CÛdigos de Ajuste
		If  (cAliasSF3)->(!Eof())
			CargaCodAju(dDtIni,dDtFim)

			IF FWModeAccess( 'SX5' , 3 ) == 'E'
				//Carrega CFOPs SX5 por filial caso seja exclusiva
				ApurVerCFO(,.T.)
			EndIf
		Endif

		/*	

		TRECHO RETIRADO PORQUE APOS VERIFICACAO COM LIDER DO LOJA (LL), ESTE TRATAMENTO NAO DEVE SER MAIS UTILIZADO NA APURACAO DO IMPOSTO.
		SEGUNDO ELE, ESTE TRATAMENTO NAO TEM SENTIDO, POIS O MAPARESUMO EH UM TRATAMENTO ANTES DO SPED, COM O SPED O LIVRO EH GERADO ON-LINE.

		//Apresenta informacoes do Mapa Resumo atraves de arquivo temporario
		If lMapResumo
			cChave			:=	IndexKey()
			cArqBkpQry 		:=	cAliasSf3
			aMapaResumo		:= 	MaxRMapRes(dDtIni,dDtfIM)
			aGravaMapRes	:= 	MaXRAgrupF3(cFilAnt,aMapaResumo,cChamOrig)
			cArqTmpMP		:= 	MaXRExecArq(1)
			cAliasSf3		:=	MaXRAddArq(1,cArqTmpMP,cAliasSf3,,aGravaMapRes,cChave)	
		EndIf
		*/

		( cAliasSF3 )->( dbGoTop() )

		//Trecho comentado utilizado para auferir tempo de processamento
		nLoop	:=	0
		nCtd	:=	1
		nAcCtd	:=	0
		cLoop	:=	DToS( Date() ) + ' ' + Time()	
		While ( cAliasSF3 )->( !Eof() ) .And. !lEnd

			//condicao para gerar o mensagem no console.log
			If lMVRF3LOG
				//Trecho comentado utilizado para auferir tempo de processamento
				If cLoop <> DToS( Date() ) + ' ' + Time()
					nAcCtd	+=	nCtd
					nLoop++
					ConOut( cLoop + ' -> FISXAPURA.PRW:XApurRF3Nw: Qtd Regs: ' + AllTrim( StrZero( nCtd , 4 ) ) + ' - Media: ' + AllTrim( StrZero( Int( nAcCtd / nLoop ) , 4 ) ) + ' - Thread: ' + cNThread )
					cLoop	:=	DToS( Date() ) + ' ' + Time()
					nCtd	:=	1
				Else
					nCtd++
				EndIf
			EndIf

			If !Empty( cFilUsr ) .And. !( cAliasSF3 )->(&cFilUsr.)
				( cAliasSF3 )->( dbSkip() )
				Loop
			Endif
			

			If lQbPais .And. ( Substr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) $ "1#2#5#6" .Or. Empty( cCodPais ) )
				( cAliasSF3 )->( dbSkip( ))
				Loop
			Endif

			//Verifica interrupcao
			If Interrupcao( @lEnd )
				aApuracao := {}
				Loop
			Endif

			//Filtros
			If cImp $ "IC/IP" .And. ( cAliasSF3 )->F3_TIPO == "S"
				( cAliasSF3 )->( dbSkip() )
				Loop
			Endif

			//Desconsidera Notas Fiscais em Lote que nao possuem ISS
			If cImp == "IS" .And. Empty( ( cAliasSF3 )->F3_CODISS ) .And. ( cAliasSF3 )->F3_TIPO == 'L'
				( cAliasSF3 )->( dbSkip() )
				Loop
			Endif

			//Decreto Municipal 2.154/2003 - Florianopolis/SC
			If lUsaCfps .And. cImp == "IS" .And. FisChkCfps( "E" , ( cAliasSF3 )->F3_CFO )
				( cAliasSF3 )->( dbSkip() )
				Loop
			Endif

			IF (cAliasSF3)->FT_ICMSRET > 0 .or. (cAliasSF3)->FT_OBSSOL > 0
				CFC->(dbSetOrder(1))
				IF CFC->(dbSeek(xFilial("CFC")+ cMvEstado	 +(cAliasSF3)->FT_ESTADO+(cAliasSF3)->FT_PRODUTO)) .And. CFC->CFC_PRECST =='2'                      
					nPosRecST := Ascan( aRecStDif , { |x| x[1] == cMvEstado	 .And. x[2] == (cAliasSF3)->FT_ESTADO } )
					IF  nPosRecST > 0
						aRecStDif[nPosRecST][03] := Iif((cAliasSF3)->FT_ICMSRET>0, (cAliasSF3)->FT_ICMSRET, (cAliasSF3)->FT_OBSSOL)
					Else
						Aadd(aRecStDif, {cMvEstado	,(cAliasSF3)->FT_ESTADO,IIf((cAliasSF3)->FT_ICMSRET>0, (cAliasSF3)->FT_ICMSRET, (cAliasSF3)->FT_OBSSOL)})				
					EndIf
				EndIf
			EndIf

			//Verifica se deve zerar o valor contabil conforme cfops do parametro
			nFTVALCONT := (cAliasSF3)->FT_VALCONT
			If cImp$"IC|IP" .AND. Alltrim((cAliasSF3)->F3_CFO)$GetNewPar("MV_VLCTBZL"," ")
				nFTVALCONT := 0
			EndIf
			
			//Tratamento para montar o resumo do livro conforme PAIS + CFOP + Aliquota e UF
			//---------------------------------------------------------------------------------------------------------------------------------
			cCodPais	:=	''
			If ( ( ( Substr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) == "7" .And. !( cAliasSF3 )->F3_TIPO $ "BD" ) .Or. ( Substr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) == "3" .And. ( cAliasSF3 )->F3_TIPO $ "BD" ) ) .Or. ( lUsaCfps .And. FisChkCfps( "S" , ( cAliasSF3 )->F3_CFO ) ) ) .and. laPais
				If !Empty( cA1PAIS )
					cCodPais := SA1->( &( cA1PAIS ) )
				EndIf

			ElseIf Substr( ( cAliasSF3 )->F3_CFO , 1  , 1 ) $ "3#7" .and. Len( aCodPais ) == 2
				If !Empty( cA2PAIS )
					cCodPais := SA2->( &( cA2PAIS ) )
				EndIf
			EndIf

			If cImp == "IS"
				cCFO	:=	(cAliasSF3)->F3_CODISS
			Else
				cCFO	:=	ApurVerCFO( (cAliasSF3)->F3_CFO )
				If lApurICM
					cCfo	:=	ExecBlock( "APURICM" , .F. , .F. , { cCfo } )
				EndIf
			Endif
			nAliq	:=	IIf( cImp == "IP" , 0 , ( cAliasSF3 )->F3_ALIQICM )

			//---------------------------------------------------------------------------------------------------------------------------------
			
			nPos := aScan( aApuracao , { |x| x[20] == cCodPais .And. x[1] == cCFO .And. x[2] == nAliq .And. x[19] == ( cAliasSF3 )->F3_ESTADO} )
			
			If nPos==0
				AADD( aApuracao , Array( LEN_ARRAY_APURACAO ) )
				nPos	:=	Len( aApuracao )
				aEval( aApuracao[ nPos ] , { |x , i| aApuracao[ nPos , i ] := 0 } , 2 )

				aApuracao[ nPos , 01 ]	:=	cCFO
				aApuracao[ nPos , 02 ]	:=	nAliq
				aApuracao[ nPos , 19 ]	:=	( cAliasSF3 )->F3_ESTADO
				aApuracao[ nPos , 20 ]	:=	cCodPais
				aApuracao[ nPos , 89 ]	:= ""
				aApuracao[ nPos , 118]	:= 0
			Endif
			aApuracao[ nPos , 74 ]	:=	( cAliasSF3 )->F3_TIPO
			aApuracao[ nPos , 11 ]	+=	nFTVALCONT
			aApuracao[ nPos , 124]	:= "" // Posicao inutilizada.
			DbSelectArea("SA1")
			DbSetOrder(1)
			//aApuracao[ nPos , 133]  := IIF(lProRurPf,IIF(SA1->(MsSeek(xFilial("SA1")+(cAliasSF3)->(F3_CLIEFOR+F3_LOJA))) .And. SA1->A1_PESSOA$"F",.F.,.T.),.T.)
			aApuracao[ nPos , 133]  := lProRurPj //lProRurPf AlteraÁ„o com base na solicitaÁ„o 261149 - Consultoria Tribut·ria Totvs
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Estorno CrÈdito ICMS de ImportaÁ„o	                         ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If cMvEstado$"PE" .And. lEstCreImp .And. Substr((cAliasSF3)->F3_CFO,1,1)$"5|6"
				aApuracao[ nPos , 134] += EstCreImp(cAliasSF3,cMvEstado,dDtIni,dDtFim,cNCMESTC)
			Endif 

			If ! cImp $ "IC/IS"
				aApuracao[ nPos , 03 ]	+=	Iif((cAliasSF3)->F4_IPI=='R', 0, ( cAliasSF3 )->FT_BASEIPI) //Para apuraÁ„o comercio n„o atacadista , tratamento para que BaseIPI e Valor Ipi n„o demonstre na apuraÁ„o. F4_IPI =R e F4_LFIPI = O bruce
				aApuracao[ nPos , 04 ]	+=	Iif((cAliasSF3)->F4_IPI=='R', 0, ( cAliasSF3 )->FT_VALIPI)
				aApuracao[ nPos , 05 ]	+=	( cAliasSF3 )->FT_ISENIPI
				aApuracao[ nPos , 06 ]	+=	Iif((cAliasSF3)->F4_IPI=='R',( cAliasSF3 )->FT_OUTRIPI+( cAliasSF3 )->FT_BASEIPI,( cAliasSF3 )->FT_OUTRIPI)
				aApuracao[ nPos , 46 ]	+=	( cAliasSF3 )->FT_IPIOBS				
				If lF4IPIPECR .And. lF4TXAPIPI
					If SD1->(MsSeek(xFilial("SD1")+(cAliasSF3)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)))
						If SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES)) .And. !Empty(SF4->F4_IPIPECR) .And. !Empty(SF4->F4_TXAPIPI)
							AADD(aMensIPI,{SF4->F4_IPIPECR,SF4->F4_TXAPIPI,(cAliasSF3)->FT_VALIPI, Alltrim(( cAliasSF3 )->FT_CFOP ) })
						Endif
						aApuracao[nPos,136]  +=  iif( (cAliasSF3)->F4_IPI=='R' .AND. Empty((cAliasSF3)->F4_IPIPECR) .AND. EMPTY((cAliasSF3)->F4_TXAPIPI) ,(cAliasSF3)->FT_VALIPI,0)
					Endif
				Endif
				If lConfApur .AND. lAliasApur
				// ApuraÁ„o IPI
					If cImp =="IP"
						If aApuracao[nPos,03] > 0 .And. SubStr((cAliasSF3)->F3_CFO,1,1) >= "5" .And. (cAliasSF3)->F3_VALIPI > 0
							ApurTempNF((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_ENTRADA,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA,;
							(cAliasSF3)->F3_CFO,(cAliasSF3)->F3_ALIQIPI,(cAliasSF3)->F3_FORMULA,"IPI_Debito","IPI",cAlsIPIs,cAliasSF3)
						ElseIf aApuracao[nPos,03] > 0 .And. SubStr((cAliasSF3)->F3_CFO,1,1) < "5" .And. (cAliasSF3)->F3_VALIPI > 0
							ApurTempNF((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_ENTRADA,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA,;
							(cAliasSF3)->F3_CFO,(cAliasSF3)->F3_ALIQIPI,(cAliasSF3)->F3_FORMULA,"IPI_Credito","IPI",cAlsIPIe,cAliasSF3)
						EndIf
					Endif
				Endif
				
				//Tratamento para identificar se mudou a NF, tem coisas que preciso chamar apenas uma vez por NF, exemplo Lancamentos da CDA
				If cChvNF <> ( cAliasSF3 )->( F3_FILIAL + FT_TIPOMOV + F3_CLIEFOR + F3_LOJA + F3_SERIE + F3_NFISCAL )
					cChvNF	:=	( cAliasSF3 )->( F3_FILIAL + FT_TIPOMOV + F3_CLIEFOR + F3_LOJA + F3_SERIE + F3_NFISCAL )

					lNewNF	:=	.T.
				EndIf
				
				//Carrega Ajustde IPI
				If cImp == "IP" .And. lUsaSped .And. lOrigIPI .And. lNewNF .AND. (cAliasSF3)->COUNTCDA >= 1
					AjustIPI(cAliasSF3,@aCDAIPI,cNrLivro)
				Endif
			Else
				//Tratamento para campos que soh existem na tabela SF3 - Deve ser processado somente uma vez a cada SF3
				If cChvSF3 <> ( cAliasSF3 )->( F3_FILIAL + FT_TIPOMOV + F3_CLIEFOR + F3_LOJA + F3_SERIE + F3_NFISCAL + F3_IDENTFT )
					cChvSF3	:=	( cAliasSF3 )->( F3_FILIAL + FT_TIPOMOV + F3_CLIEFOR + F3_LOJA + F3_SERIE + F3_NFISCAL + F3_IDENTFT )

					lNewSF3	:=	.T.
				EndIf

				//Tratamento para identificar se mudou a NF, tem coisas que preciso chamar apenas uma vez por NF, exemplo Lancamentos da CDA
				If cChvNF <> ( cAliasSF3 )->( F3_FILIAL + FT_TIPOMOV + F3_CLIEFOR + F3_LOJA + F3_SERIE + F3_NFISCAL )
					cChvNF	:=	( cAliasSF3 )->( F3_FILIAL + FT_TIPOMOV + F3_CLIEFOR + F3_LOJA + F3_SERIE + F3_NFISCAL )

					lNewNF	:=	.T.
				EndIf

				aApuracao[ nPos , 03 ]	+=	( cAliasSF3 )->FT_BASEICM
				aApuracao[ nPos , 04 ]	+=	( cAliasSF3 )->FT_VALICM-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,(cAliasSF3)->FT_VALFECP)
				aApuracao[ nPos , 05 ]	+=	( cAliasSF3 )->FT_ISENICM+(cAliasSF3)->FT_ISENRET // Soma o valor do ICMS ST no valor de outras ICMS quando o livro de ST esta configurado como Outras	
				aApuracao[ nPos , 06 ]	+=	( cAliasSF3 )->FT_OUTRICM+(cAliasSF3)->FT_OUTRRET // Soma o valor do ICMS ST no valor de outras ICMS quando o livro de ST esta configurado como Outras	
				aApuracao[ nPos , 22 ]	+=	( cAliasSF3 )->FT_OBSICM
				aApuracao[ nPos , 24 ]	+=	( cAliasSF3 )->( FT_VALIPI + FT_ISENIPI + FT_OUTRIPI )
				aApuracao[ nPos , 29 ]	+=	( cAliasSF3 )->FT_ISSSUB
				aApuracao[ nPos , 137 ]	+=	IIf(lFTBSICMOR,(cAliasSF3)->FT_BSICMOR,0)
				aApuracao[ nPos , 138 ]	+=	( cAliasSF3 )->(FT_VALIPI + FT_IPIOBS) //criada a posiÁ„o 138 para somar o valor do ipi com o ipiobs pois ocorria erro na giars
				If lFTDS43080 .And. lFTPR43080
					If cMvEstado == "MG" .AND. ( cAliasSF3 )->FT_DS43080 <> 0 .AND. ( cAliasSF3 )->FT_PR43080 <> 0
						aApuracao[ nPos , 06 ]	+=	( cAliasSF3 )->FT_VALCONT - ( cAliasSF3 )->FT_BASEICM
					Endif
				Endif

				//Tratamento credito acumulado //#vitor01 - Se estiver preenchido o credito acumulado e n„o for a opÁ„o n„o se aplica (3)
				If lNWCredAcu .And. !Empty((cAliasSF3)->F3_CREDACU) .And. (cAliasSF3)->F3_CREDACU <> "3"
					If (Alltrim((cAliasSF3)->F3_TIPO) <> "D" .And. Alltrim((cAliasSF3)->F3_CFO) >= '5') .Or. Alltrim((cAliasSF3)->F3_TIPO) == "D" .And. Alltrim((cAliasSF3)->F3_CFO) <= '3'
						// Verifica se o tipo do credito acumulado j· est· no array
						nPoscred := Ascan(aNWCredAcu,{|x| x[1] == (cAliasSF3)->F3_CREDACU })
						
						// Se n„o tiver
						If Empty(nPoscred)
							// Adiciona a nova posiÁ„o
							Aadd(aNWCredAcu,{(cAliasSF3)->F3_CREDACU,0})
							nPoscred := Len(aNWCredAcu)
						Endif

						If Alltrim((cAliasSF3)->F3_TIPO) <> "D" .And. Alltrim((cAliasSF3)->F3_CFO) >= '5'
							// Soma os valores
							aNWCredAcu[nPoscred][2] += (cAliasSF3)->(F3_ISENICM+F3_OUTRICM)
						ElseIf Alltrim((cAliasSF3)->F3_TIPO) == "D" .And. Alltrim((cAliasSF3)->F3_CFO) <= '3'
							// Subtrai os valores
							aNWCredAcu[nPoscred][2] -= (cAliasSF3)->(F3_ISENICM+F3_OUTRICM)
						EndIf
					EndIf
				Endif

				//Tratamento para calculo somente do ICMS
				If cImp $ "IC"
					aApuracao[ nPos , 09 ]	+=	( cAliasSF3 )->FT_ICMAUTO
					If lFTDIFAL .And. lFTPDDES
						If ( cAliasSF3 )->FT_DIFAL == 0	.And. ( cAliasSF3 )->FT_PDDES == 0
							//Somente considera diferencial de alÌquota se n„o calculou Difal EC 87/15
							aApuracao[ nPos , 10 ]	+=	( cAliasSF3 )->FT_ICMSCOM
						EndIF
					Else						
						aApuracao[ nPos , 10 ]	+=	( cAliasSF3 )->FT_ICMSCOM
					EndIF

					aApuracao[ nPos , 14 ]	+=	( cAliasSF3 )->FT_ICMSDIF
					aApuracao[ nPos , 23 ] 	+= 	( cAliasSF3 )->FT_OBSSOL
					aApuracao[ nPos , 36 ]	+=	Iif( lNewSF3 , ( cAliasSF3 )->F3_SIMPLES , 0 )	//SIMPLES - SC
					aApuracao[ nPos , 46 ] 	+= 	( cAliasSF3 )->FT_IPIOBS

					//Alimentar AAPURACAO, posiÁ„o 75,76,77,78,79
					If ( cAliasSF3 )->FT_ICMSCOM > 0 .And. Alltrim( ( cAliasSF3 )->F3_CFO ) $ "291/197/2551/2556" .And. ( cAliasSF3 )->FT_VALICM == 0
						aApuracao[ nPos , 75 ]	+=	( cAliasSF3 )->FT_VALICM
						aApuracao[ nPos , 76 ]	+=	( cAliasSF3 )->FT_ICMSCOM
						aApuracao[ nPos , 77 ]	+=	nFTVALCONT
						aApuracao[ nPos , 78 ]	+=	( cAliasSF3 )->FT_ISENICM
					Endif
					
					If (lGiaRs .And. lIncsol)
						aApuracao[ nPos , 140 ] += ( cAliasSF3 )->FT_ICMSRET
					EndIf

					//Estorno de Credito/Debito
					If lFTESTCRED .And. ( cAliasSF3 )->FT_TIPOMOV == "E"
						aApuracao[ nPos , 47 ] 	+= 	( cAliasSF3 )->FT_ESTCRED 	// Estorno de Credito

					Elseif lFTESTCRED .And. ( cAliasSF3 )->FT_TIPOMOV == "S"
						aApuracao[ nPos , 49 ] 	+= ( cAliasSF3 )->FT_ESTCRED 	// Estorno de Debito

					Endif

					If lFTCRDPCTR
						aApuracao[ nPos , 111 ]	+=	( cAliasSF3 )->FT_CRDPCTR
					EndIf
					If lFTCREDPRE
						aApuracao[ nPos , 112 ]	+=	( cAliasSF3 )->FT_CREDPRE
					Endif
					//Implementacao no P9AutoText do RJ
					If lRegEsp
						If Left( Alltrim( ( cAliasSF3 )->F3_CFO ) , 1 ) $ "56" .And. ( cAliasSF3 )->F3_TIPO $ "DB"
							aApuracao[ nPos , 35 ]	+=	nFTVALCONT
						Endif
					Endif

					//Credito Presumido/RJ - Prestacoes de Servicos de Transporte
					If ( cAliasSF3 )->FT_TIPOMOV == "S"
						aApuracao[ nPos , 37 ]	+=	( cAliasSF3 )->FT_CRDTRAN
					Endif

					//Operacoes de Prazo Especial - RJ
					If Left( Alltrim( ( cAliasSF3 )->F3_CFO ) , 1 ) $ "5" .And. lF4PRZESP .And. ( cAliasSF3 )->F4_PRZESP $ "S"
						aApuracao[ nPos , 81 ]	+=	( cAliasSF3 )->FT_VALICM
					Endif

					//Valor de exclus„o de ICMS ST na Guia B do Rioa Grande do Sul
					IF lF4MKPCMP .AND. ( cAliasSF3 )->F4_MKPCMP == "2" .AND. cMvEstado $ "RS" .AND. SubStr(( cAliasSF3 )->FT_CFOP,1,2) $ "14$24"
						aApuracao[ nPos , 123 ]	:= Iif((lGiaRs .And. lIncsol),0,( cAliasSF3 )->FT_ICMSRET)
					//VAlor de exclus„o de aquisiÁ„o de serviÁo de transporte vinculado a aquisiÁ„o de ativo ou uso e consumo para GIA B RS
					ElseIF lF4FTATUSC .AND. ( cAliasSF3 )->F4_FTATUSC == "1" .AND.cMvEstado $ "RS".AND. alltrim(( cAliasSF3 )->FT_CFOP) $ "1949/2949"					
						aApuracao[ nPos , 123 ]	:= nFTVALCONT
					EndIF

					//Credito Presumido/AM - Entradas Interestaduais na Zona Franca de Manaus
					aApuracao[ nPos , 38 ]	+=	( cAliasSF3 )->FT_CRDZFM

					//valor Credito Presumido Substituicao Tributaria retido pelo contratante do servico de transporte - Decreto 44.147/2005 (MG)
					If ( cAliasSF3 )->FT_TIPOMOV == "E"
						aApuracao[ nPos , 39 ]	+=	( cAliasSF3 )->FT_CRPRST
					Endif

					If lTransST .And. lFTVALTST
						aApuracao[ nPos , 60 ]	+=	( cAliasSF3 )->FT_VALTST
					EndIf

					//Valor CrÈdito Presumido nas operaÁıes de SaÌda com o ICMS destacado sobre os produtos resultantes da industrializaÁ„o com componentes, partes e pecas recebidos do exterior, destinados a fabricacao de produtos de informatica, eletronicos e telecomunicacoes, por estabelecimento industrial desses setores. Tratamento conforme Art. 1∫ do DECRETO 4.316 de 19 de Junho de 1995.(BA)
					If lFTCRPRELE .And. ( cAliasSF3 )->FT_TIPOMOV == "S" // Credito
						aApuracao[ nPos , 41 ]	+=	( cAliasSF3 )->FT_CRPRELE

					ElseIf lFTCRPRELE .And. ( cAliasSF3 )->FT_TIPOMOV == "E" .And. (cAliasSF3)->F3_TIPO == 'D' // Estorno do Credito
						aApuracao[ nPos , 45 ]	+=	( cAliasSF3 )->FT_CRPRELE
					Endif

					//Valor referente ao Fundersul - Mato Grosso do Sul
					If lFTVALFDS     
						If Left( Alltrim( ( cAliasSF3 )->F3_CFO ) , 1 ) $ "156"
							If Alltrim( ( cAliasSF3 )->F3_TIPO ) == "D"
								aApuracao[ nPos , 44 ]	-=	( cAliasSF3 )->FT_VALFDS
							Else
								aApuracao[ nPos , 44 ]	+=	( cAliasSF3 )->FT_VALFDS  
							EndIf
						Endif
					Endif
					//Senar
					If lFTVLSENAR
						If Alltrim((cAliasSF3)->F3_TIPO) $ "DB"
							DbSelectArea("SF3")
							SF3->(DbSetOrder(5))
							SF3->(MsSeek(xFilial("SF3")+SFT->FT_SERORI+SFT->FT_NFORI+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			
							If Left(Alltrim(SF3->F3_CFO),1)$"567"
								DbSelectArea("SA1")
								DbSetOrder(1)
								If cProRurPJ$"1" .Or. !((cProRurPJ$"1" .And. SA1->(MsSeek(xFilial("SA1")+SF3->(F3_CLIEFOR+F3_LOJA))) .And. A1_PESSOA$"F"))
									aApuracao[nPos, 85] -= (cAliasSF3)->F3_VLSENAR
								EndIf
							ElseIf Left(Alltrim(SF3->F3_CFO),1)$"12"
								DbSelectArea("SA2")
								DbSetOrder(1)    
								If !lJuridica .And. !(SA2->(MsSeek(xFilial("SA2")+SF3->(F3_CLIEFOR+F3_LOJA))) .And. (SA2->A2_TIPO$"F" .OR. (SA2->A2_TIPO$"J" .And. SA2->A2_TIPORUR$"F"))) 					
									aApuracao[nPos, 85] -= (cAliasSF3)->F3_VLSENAR
								EndIf
							EndIf		
						Else
							If Left(Alltrim((cAliasSF3)->FT_CFOP),1)$"567"
								DbSelectArea("SA1")
								DbSetOrder(1)
								If !cProRurPJ$"1" .Or. (cProRurPJ$"1" .And. SA1->(MsSeek(xFilial("SA1")+(cAliasSF3)->(F3_CLIEFOR+F3_LOJA))) .And. A1_PESSOA$"F")
									aApuracao[nPos,85] += (cAliasSF3)->FT_VLSENAR
								EndIf								
							ElseIf Left(Alltrim((cAliasSF3)->FT_CFOP),1)$"12"
								DbSelectArea("SA2")
								DbSetOrder(1)    
								If lJuridica .And. SA2->(MsSeek(xFilial("SA2")+(cAliasSF3)->(F3_CLIEFOR+F3_LOJA))) .And. (SA2->A2_TIPO$"F" .Or. (SA2->A2_TIPO$"J" .And. SA2->A2_TIPORUR$"F")) 					
									aApuracao[nPos,85] += (cAliasSF3)->FT_VLSENAR
								EndIf
							EndIf
						 Endif 
					Endif
					//Credito Presumido Simples Nacional - SC
					If lFTCRPRSIM
						aApuracao[ nPos , 48 ]	+=	( cAliasSF3 )->FT_CRPRSIM
					Endif
					//Antecipacao ICMS
					
					If lF4VARATAC .And. !cMvEstado $ "SP" .And. ( cAliasSF3 )->FT_TIPOMOV == "E"
						If !Empty( ( cAliasSF3 )->F4_VARATAC)
							If ( cAliasSF3 )->F4_VARATAC == "2"
								If lFTVALANTI
									If lMesAnti
										aApuracao[ nPos , 50 ]	:=	nVlrAnti
									Else
										aApuracao[ nPos , 50 ]	+=	( cAliasSF3 )->FT_VALANTI
									Endif
								Endif
							ElseIf ( cAliasSF3 )->F4_VARATAC == "1" 
								aApuracao[ nPos , 79 ]	+=	( cAliasSF3 )->FT_OBSSOL
							Endif
						Else
							If lFTVALANTI
								If lMesAnti
									aApuracao[ nPos , 50 ] 	:= 	nVlrAnti
								Else
									aApuracao[ nPos , 50 ] 	+=	( cAliasSF3 )->FT_VALANTI
								Endif
							Endif
						Endif
					EndIf

					//Fust / Funttel
					If ( nFust > 0 .Or. nFunttel > 0 ) .And.;
						( aApuracao[ nPos , 53 ] + aApuracao[ nPos , 54 ] ) == 0	//Farah o calculo somente 1 vez

						aApuracao[ nPos , 53 ]	:= 	nRecBrut * nFust / 100 		//Fust
						aApuracao[ nPos , 54 ]	:=	nRecBrut * nFunttel / 100	//Funttel
					Endif

					// ********************** GOIAS (GO) *****************************
		    		nCrOutPrtg := 0
					nRedPrtg	:= 0
					nDifVlr := 0

					If	GetNewPar("MV_GERPROT",.F.) .And. lFTVALPRO
						//Credito Outorgado - GO Inc.III, Art 11 Anexo IX - RCTE-GO/97                  
						If (cAliasSF3)->FT_CROUTGO >0
							aApuracao[nPos,110] += (cAliasSF3)->FT_CROUTGO
						EndIf
						
						//Fundo de ProteÁ„o Social de Goi·s ñ PROTEGE
						If	lFTVALPRO .AND. (cAliasSF3)->FT_VALPRO >0
                     	aApuracao[ nPos , 51 ]  += (cAliasSF3)->FT_VALPRO
                  	EndIf
                  	
                  	// Totalizo o PROTEGE recolhido na emissao do(s) documento(s) - Apenas 1x por NF.                  	
				      	If SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) >= "5" .And. lNewNF
				      		SF6->(DbSetOrder(3)) // F6_FILIAL+F6_OPERNF+F6_TIPODOC+F6_DOC+F6_SERIE+F6_CLIFOR+F6_LOJA
							If SF6->( MsSeek( xFilial( "SF6" ) + "2" + PadR(( cAliasSF3 )->F2_TIPO, nTamTpDoc) + ( cAliasSF3 )->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA) ) )
								While !SF6->(Eof()) .AND. xFilial("SF6") == SF6->F6_FILIAL .AND. SF6->F6_OPERNF == "2" .And. SF6->F6_TIPODOC == PadR(SF2->F2_TIPO,nTamTpDoc) .AND.; 
									SF6->(F6_DOC+F6_SERIE+F6_CLIFOR+F6_LOJA) == ( cAliasSF3 )->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA) 
									If SF6->F6_TIPOIMP == "C"  								
										aApuracao[ nPos , 141 ]	+=	SF6->F6_VALOR								
									EndIf
									SF6->(dbSkip())
								EndDo								
							EndIf
							SF6->(DbSetOrder(1)) // F6_FILIAL+F6_EST+F6_NUMERO
						EndIf
                  	
					ElseIf  cMvEstado == "GO" 

						//Credito Outorgado - GO Inc.III, Art 11 Anexo IX - RCTE-GO/97					
						If (cAliasSF3)->FT_CROUTGO >0
							aApuracao[nPos,110] += (cAliasSF3)->FT_CROUTGO
							
							//Calculo Protege
							nCrOutPrtg:= (cAliasSF3)->FT_CROUTGO * 15 / 100
						Else
							aApuracao[nPos,110] += 0
						EndIf 
						
						//ReduÁ„o da Base do ICMS 
						If (cAliasSF3)->FT_BASEICM > 0 .And. ((cAliasSF3)->FT_OUTRICM > 0 .Or. (cAliasSF3)->FT_ISENICM > 0)
			
							nVlrBase := (cAliasSF3)->FT_BASEICM + (cAliasSF3)->FT_OUTRICM + (cAliasSF3)->FT_ISENICM
							nICMAliq := (cAliasSF3)->FT_ALIQICM
							
							nDifVlr := (nVlrBase * nICMAliq/100) - (cAliasSF3)->FT_VALICM
							
							//Calculo Protege
							nRedPrtg:= nDifVlr * 15 / 100	
						EndIf	

			    	   //Fundo de ProteÁ„o Social de Goi·s ñ PROTEGE			
						aApuracao[ nPos , 51 ]	+= nCrOutPrtg + nRedPrtg

				   ElseIf Left( Alltrim( ( cAliasSF3 )->F3_CFO ) , 1 ) > "5" .And. ( cAliasSF3 )->F3_ESTADO == "GO"

						//CD2_FILIAL+CD2_TPMOV+CD2_SERIE+CD2_DOC+CD2_CODCLI+CD2_LOJCLI+CD2_ITEM+CD2_CODPRO+CD2_IMP                                              
				    	//ReduÁ„o da Base do ICMS/ST na venda para GO
				    	If CD2->(MsSeek( xFilial( "CD2" ) + "S" + ( cAliasSF3 )->( FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO+"SOL" ) ) ) .And.;
				    		CD2->CD2_PREDBC > 0
 							// ENCONTRAR A bc ORIGINAL DE ICMS-ST
							nVlrBase := (CD2->CD2_BC*100) / CD2->CD2_PREDBC
							nICMAliq := CD2->CD2_ALIQ

							nDifVlr := ( (nVlrBase * nICMAliq/100) - (cAliasSF3)->FT_VALICM ) - CD2->CD2_VLTRIB

							//Fundo de ProteÁ„o Social de Goi·s ñ PROTEGE
							aApuracao[ nPos , 51 ]	+= nDifVlr * 15 / 100

						EndIf	

					Endif		

					// ********************** CEARA (CE) *****************************
					//FECOP P9AutoText do CE
					If cMvEstado=="CE" .And. ( cAliasSF3 )->F3_ESTADO == "CE"

						If lB1FECOP .And. lB1ALFECOP .And. ( cAliasSF3 )->FT_TIPOMOV == "S"
							If ( cAliasSF3 )->B1_FECOP == "1" .And. ( cAliasSF3 )->B1_ALFECOP > 0
								If ( cAliasSF3 )->B1_ALFECOP == 19
									aApuracao[ nPos , 68 ]	+=	( cAliasSF3 )->FT_VALICM

								ElseIf ( cAliasSF3 )->B1_ALFECOP == 27
									aApuracao[ nPos , 69 ]	+= 	( cAliasSF3 )->FT_VALICM

								EndIf
							EndIf
						EndIf

						If lB1FECOP .And. lB1ALFECST .And. ( cAliasSF3 )->FT_TIPOMOV == "S"
							If ( cAliasSF3 )->B1_FECOP == "1" .And. ( cAliasSF3 )->B1_ALFECST > 0
								If ( cAliasSF3 )->B1_ALFECST == 19
									aApuracao[ nPos , 70 ] 	+= 	( cAliasSF3 )->FT_ICMSRET

								ElseIf ( cAliasSF3 )->B1_ALFECST == 27
									aApuracao[ nPos , 71 ]	+= 	( cAliasSF3 )->FT_ICMSRET

								EndIf
							Endif
						EndIf
					EndIf

					// ********************** RIO DE JANEIRO E BAHIA (RJ/BA) *****************************
					//FECP
					If cMvEstado $ "RJ|BA|AL|CE|DF|ES|MA|MS|PB|PE|PI|SE"

						//Credito Acumulado de ICMS - Bahia
						If cMvEstado $ "BA" .And. lCredAcu .And.;
							( aApuracao[ nPos , 62 ] + aApuracao[ nPos , 63 ] ) == 0	//Processarah somente 1 vez

							aApuracao[ nPos , 62 ]	:=	aCredAcu[1] //Exportacoes
							aApuracao[ nPos , 63 ]	:=	aCredAcu[2] //Outras hipoteses
						Endif

						If ((( cAliasSF3 )->FT_ALQFECP > 0 .Or.(lFTALFCCMP .And. ( cAliasSF3 )->FT_ALFCCMP > 0)) .And. SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) < "3");
						    .Or. ((( cAliasSF3 )->FT_ALQFECP > 0 .Or.(lFTALFCCMP .And. ( cAliasSF3 )->FT_ALFCCMP > 0)) .And. SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) > "4" .And. (cAliasSF3)->F3_TIPO $ "D/B")
							If ( cAliasSF3 )->F4_COMPL=="S" .And. (cAliasSF3)->F3_ESTADO <> "RJ" .And.  (( cAliasSF3 )->F4_CONSUMO == "S" .Or. ( ( cAliasSF3 )->F4_LFICM == "O" .And. ( cAliasSF3 )->F4_CONSUMO == "O" ) )
								aApuracao[ nPos , 73 ]	+=	( cAliasSF3 )->FT_VALFECP		//(cAliasSF3)->F3_BASEICM * (SFT->FT_ALQFECP /100)
								aApuracao[ nPos , 10 ]	-=	( cAliasSF3 )->FT_VALFECP
							EndIf
						EndIf
					
						// Utilizado pelo P9AUTOTEXT.RJ	- Resolucao SEF 6.556/2003 - Art. 4
						// Utilizado pelo P9AUTOTEXT.BA
						If ( cAliasSF3 )->( FT_BASERET > 0 .And. FT_CREDST <> '4' )
							aApuracao[ nPos , 32 ]	+= 	Abs( ( cAliasSF3 )->FT_BASERET)
							aApuracao[ nPos , 57 ] 	+= 	Abs( Iif( lFTVFECPST , ( cAliasSF3 )->FT_VFECPST , 0 ) )
						Endif
						aApuracao[ nPos , 31 ]	+= 	( cAliasSF3 )->FT_BASEICM
						If !(cMvEstado == "RJ" .And. !((cAliasSF3)->F3_BASEICM > 0))
							If cMvEstado $ "AL|CE|DF|ES|MA|MS|PB|PE|PI|SE"
								IF ( cAliasSF3 )->FT_TIPOMOV == "S"
									aApuracao[ nPos , 59 ] 	+= 	Iif( lFTVALFECP , ( cAliasSF3 )->FT_VALFECP , 0 )
								EndIF
							Else
								aApuracao[ nPos , 59 ] 	+= 	Iif( lFTVALFECP , ( cAliasSF3 )->FT_VALFECP , 0 )						
							EndIF
						Endif
					EndIf					
					//Fundo Estadual de EquilÌbrio Fiscal do Estado do Rio de Janeiro - FEEF.
					If	lFTVALFEEF .AND. (cAliasSF3)->FT_VALFEEF >0
						if SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) < '5' .and. (cAliasSF3)->FT_TIPO == 'D' //DevoluÁ„o
							aApuracao[ nPos , 143 ]  += (cAliasSF3)->FT_VALFEEF
						elseif SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) >= '5
							aApuracao[ nPos , 139 ]  += (cAliasSF3)->FT_VALFEEF
						endif
					Else
                  		aApuracao[ nPos , 139 ]  += 0
                  		aApuracao[ nPos , 143 ]  += 0
				    EndIf
					
					// ********************** MARANHAO (MA) *****************************    	
					//FUMACOP P9AutoText do MA 
					If cMvEstado == "MA" .And. lFTVALFUM .And. ( cAliasSF3 )->FT_TIPOMOV == "S"
						aApuracao[ nPos , 83 ]	+=	( cAliasSF3 )->FT_VALFUM
					EndIf

					// ********************** PARANA (PR) / RIO GRANDE DO SUL (RS) *****************************
					//Parag. 16, Art.23 RICMS/PR - SN (Utilizar P9AUTOTEXT.PR)
					//CrÈdito aquisiÁ„o Optantes do Simples Nacional (Utilizar P9AUTOTEXT.RS)
					If cMvEstado $ "PR/RS/SC"
						If SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) $ "12"
							If ( cAliasSF3 )->F4_ICM == "S" .And. ( cAliasSF3 )->F4_CREDICM == "S" .And. ( cAliasSF3 )->F4_LFICM == "O"
								If lA2SIMPNAC  .And. ( cAliasSF3 )->A2_SIMPNAC $ "1S"
									aApuracao[ nPos , 108 ]	+=	( cAliasSF3 )->D1_VALICM
								Endif
							Endif
						Endif
					Endif

					If cMvEstado$"PR"
						//Credito Presumido - PR
						If Left( ( cAliasSF3 )->F3_CFO , 1 ) $ "3"
							aApuracao[ nPos , 34 ]	+=	( cAliasSF3 )->FT_CRDPRES
						EndIf

						//Credito Presumido - PR - RICMS (Art.4) Anexo III
						If lFTCRPREPR
							aApuracao[ nPos , 55 ]	+=	( cAliasSF3 )->FT_CRPREPR
						Endif
						
						//Cred. Presumido-art.631-A do RICMS/2008
						If lFTCPRESPR
							aApuracao[ nPos , 72 ]	+=	( cAliasSF3 )->FT_CPRESPR
						Endif
					    //Tratamento para Estorno de Credito Presumido do PR atraves do uso de Rastro (Lote)
					    //Venda fora do estado - Zona franca n„o permite estorno
					    //Nota fiscal origem deve ser de importacao
					    If lESTCRPR
							If (Left(Alltrim((cAliasSF3)->F3_CFO),1)$"6" .And. (cAliasSF3)->F3_ESTADO<>"AM") .Or. (cAliasSF3)->F3_TIPO=="D"
								aApuracao[nPos,130]	+= EstCrePres(cAliasSF3,cMvEstado,2,dDtIni,dDtFim,cNCMESTC,dDTCOREC)
							Endif
						Endif
																	
						If lB1RICM65 .And. ( cAliasSF3 )->B1_RICM65 == "1" .And. SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) >= "5"
							If CDC->(MsSeek( xFilial( "CDC" ) + "S" + ( cAliasSF3 )->( F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA ) ) )
								While !CDC->( Eof() ) .And.;
									CDC->CDC_FILIAL == xFilial("CDC") .And. CDC->CDC_TPMOV == "S" .And. CDC->CDC_DOC == (cAliasSF3)->F3_NFISCAL .And.;
									CDC->CDC_SERIE == (cAliasSF3)->F3_SERIE .And. CDC->CDC_CLIFOR == (cAliasSF3)->F3_CLIEFOR .And.;
									CDC->CDC_LOJA == (cAliasSF3)->F3_LOJA
									If SF6->( MsSeek( xFilial( "SF6" ) + CDC->( CDC_UF + CDC_GUIA ) ) )
										If SF6->F6_TIPOIMP == "1"
											aApuracao[ nPos , 80 ]	+=	SF6->F6_VALOR
										EndIf
									EndIf
									CDC->(dbSkip())
								End
							EndIf
						EndIf

					Elseif cMvEstado == "RS" .and. !Empty( cLeiteIn )
						aApuracao[ nPos , 119 ]	+=	( cAliasSF3 )->FT_CRDPRES
					ElseIf cMvEstado$"CE" .AND. Alltrim((cAliasSF3)->F3_ESPECIE)$"CTR/CTA/CTF/CTE/NFST"
						aApuracao[nPos,122]:= (cAliasSF3)->F3_CRDPRES
					ElseIf ( cAliasSF3 )->F3_TIPO <> "D"
						aApuracao[ nPos , 34 ]	+=	( cAliasSF3 )->FT_CRDPRES
					Endif

					IF ( cAliasSF3 )->F3_TIPO == "D"
						aApuracao[ nPos , 131 ]	+=	( cAliasSF3 )->FT_CRDPRES					
					EndIF

					//Tratamento para geracao dos anexos V.A e V.B da GIARS
					If ( lGiaRs .Or. cMvEstado == "RS" ) .And. aScan( aNFsGiaRs , {| aX | aX[ 1 ] == ( cAliasSF3 )->F3_NFISCAL } ) > 0
						( cAliasSF3 )->( aAdd( aNFsGiaRs , { F3_NFISCAL , F3_SERIE , F3_CLIEFOR , F3_LOJA , F3_CRDPRES , F3_CFO } ) )
					EndIf
					
					If lGiaRs // Tratamento exclusivo para GIARS
			     		lIncsol	:=( cAliasSF3 )->F4_INCSOL$'S'
			     	Else
			     		lIncsol	:= .F.
			     	EndIf

					// ********************** SAO PAULO (SP) *****************************
					If cMvEstado$"SP"
						//MAterial Recicl·vel
						If lB1PRODREC .And. ( cAliasSF3 )->B1_PRODREC $ "1S" .And.;
							( cAliasSF3 )->FT_TIPOMOV == "E"

							aApuracao[ nPos , 84 ]	+=	( cAliasSF3 )->FT_VALICM
						Endif

						//Credito Presumido - Decreto 52.586 de 28.12.2007 (P9AutoText)
						If lFTCRPRESP
							aApuracao[ nPos , 82 ]	+=	( cAliasSF3 )->FT_CRPRESP
						Endif
						//Credito Outorgado SP - Decreto 56.018 de 16/07/2010, o Decreto 56.855, 
						//	de 18 .03.2011 e o Decreto 56.874, de 23.03.2011  (P9AutoText)
						If lFTCROUTSP
							If Substr( ( cAliasSF3 )->B1_POSIPI , 1 , 4 ) $ cCredOut .And. !Substr( ( cAliasSF3 )->B1_POSIPI , 1 , 4 ) $ "0401/0403/4410/4411/1601/1602"					   																
								aApuracao[ nPos , 86 ]	+=	( cAliasSF3 )->FT_CROUTSP
	
							//Conforme Art.31 do Anexo III do RICMS os NCMs 1601/1602 devem
							// ser considerados na apuracao quando existir um documento de entrada,
							// para as demais situacoes o Credito Outorgado nao deve ser considerado,
							// alinhado com a equipe de legislacao.
							ElseIf (Substr( ( cAliasSF3 )->B1_POSIPI , 1 , 4 ) $ "1601/1602" .And. ( cAliasSF3 )->FT_TIPOMOV == "E") 
								aApuracao[ nPos , 86 ]	+=	( cAliasSF3 )->FT_CROUTSP
	
							Elseif Substr( ( cAliasSF3 )->B1_POSIPI , 1 , 4 ) == "0401"			 
								aApuracao[ nPos , 97 ]	+=	( cAliasSF3 )->FT_CROUTSP
	
							Elseif Substr( ( cAliasSF3 )->B1_POSIPI , 1 , 4 ) == "0403"				                                               
								aApuracao[ nPos , 98 ]	+=	( cAliasSF3 )->FT_CROUTSP 
	
							Elseif Substr( ( cAliasSF3 )->B1_POSIPI , 1 , 4 ) $ "4410/4411"
								aApuracao[ nPos , 99 ]	+=	( cAliasSF3 )->FT_CROUTSP
	
							Endif
						Endif
						//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
						//≥CrÈdito outorgado-art.11, anexo III, RICMS/SP		|
						//≥IntegraÁ„o com TMS        							| 	
						//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
						If ( cAliasSF3 )->FT_TIPOMOV == "S" .And. Alltrim( ( cAliasSF3 )->F3_ESPECIE ) == "CTR" .and. _INTTMS//IntTms()
							If aFindFunc[FF_VLDMTR928]
								If VldMTR928( cAliasSF3 , .T. )
									aApuracao[ nPos , 102 ]	+=	Round( ( ( cAliasSF3 )->FT_VALICM + ( cAliasSF3 )->FT_ICMSRET) * nPercCrOut , 2 )
								Endif
							Endif
						Endif

						//tratamento - remessa de venda para fora do estabelecimento (venda ambulante)
						If Alltrim( ( cAliasSF3 )->F3_CFO ) $ "5904/6904"
							aApuracao[ nPos , 100 ]	+=	( cAliasSF3 )->FT_VALICM
						EndIf

						//Antecipacao ICMS
						If ( cAliasSF3 )->FT_TIPOMOV == "E"
							If lF4VARATAC .And. !Empty( ( cAliasSF3 )->F4_VARATAC )
								If lFTVALANTI
									If lMesAnti
										aApuracao[ nPos , 50 ]	:=	nVlrAnti
									Else
										aApuracao[ nPos , 50 ]	+=	( cAliasSF3 )->FT_VALANTI
									Endif
								Endif
							Else
								If lFTVALANTI
									If lMesAnti
										aApuracao[ nPos , 50 ]	:=	nVlrAnti
									Else
										aApuracao[ nPos , 50 ]	+=	( cAliasSF3 )->FT_VALANTI
									Endif
								Endif
							Endif
						EndIf
					EndIf

					// ********************** MATO GROSSO (MT) *****************************
					// Utilizado pelo P9AUTOTEXT.MT
					If cMvEstado == "MT"
						If Alltrim( ( cAliasSF3 )->F3_OBSERV ) == "ICMS GARANTIDO" 
							If ( cAliasSF3 )->FT_TIPOMOV == "E"
								aApuracao[ nPos , 81 ]	+=	( cAliasSF3 )->FT_VALANTI

							ElseIf ( cAliasSF3 )->FT_TIPOMOV == "S"
								aApuracao[ nPos , 82 ]	+=	( cAliasSF3 )->FT_VALANTI

							Endif
						EndIf
						
						If ( cAliasSF3 )->( SubStr( F3_CFO , 1 , 1 ) >= "5"  ) //FECPMT sobre ICMS prÛprio
							aApuracao[ nPos , 117 ]	+=	Abs( RetValFecp( Iif(lFTVFECPMT,( cAliasSF3 )->FT_VFECPMT ,0)  , Iif(lFTVALFECP,(cAliasSF3)->FT_VALFECP,0) ) )
						Endif
						
						//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
						//≥Somente para o Estado do Mato Grosso         				≥
						//≥																≥
						//≥Verifica se o registro que esta sendo processado se enquadra ≥
						//≥nas regras para aplicacao do credito presumido               ≥
						//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
						If nCredMT == 1 .And. ( cAliasSF3 )->( Alltrim( F3_CFO ) == "6101" .And. FT_VALICM > 0 .And. F3_ESTADO <> "MT" .And. Alltrim( F3_ESPECIE ) == "SPED" )

							aApuracao[ nPos , 118 ]	+=	FCrPreMt( cAliasSF3 , aNfDupl )                                                                                       

							( cAliasSF3 )->( Aadd( aNfDupl , { F3_NFISCAL , F3_SERIE , F3_CLIEFOR , F3_LOJA } ) )

						Else
							aApuracao[ nPos , 118 ]	:=	0
						EndIf

					EndIf

					// ********************** RONDONIA (RO) *****************************
					//Credito Presumido - RO - RICMS (Art.39) Anexo IV
					If cMvEstado$"RO" .And. lFTCRPRERO
						If ( cAliasSF3 )->F3_TIPO <> "D"
							aApuracao[ nPos , 64 ]	+=	( cAliasSF3 )->FT_CRPRERO

						Elseif ( cAliasSF3 )->F3_TIPO == "D"
							aApuracao[ nPos , 101 ]	+=	( cAliasSF3 )->FT_CRPRERO

						EndIf
					EndIf

					// ********************** PERNAMBUCO (PE) *****************************
					//Credito Presumido - PE - Art. 6 Decreto n28.247 (P9AutoText)
					If cMvEstado$"PE"
						 If lFTCRPREPE
							aApuracao[ nPos , 66 ]	+=	( cAliasSF3 )->FT_CRPREPE   // Cred Pres. Art. xxx
						Endif
						If lFTCPPRODE .And. lFTTPPRODE
							//processa nota internas com credito de importaÁ„o
							IF ( cAliasSF3 )->FT_TIPOMOV == "S" .AND. ( cAliasSF3 )->FT_CPPRODE > 0 .And. ( cAliasSF3 )->FT_TPPRODE == "6" .AND. Substr( Alltrim( aApuracao[ nPos , 01 ] ) , 1 , 1 ) $ "5" 
								nImport  :=	GiafEntPrd(( cAliasSF3 )->FT_PRODUTO, ( cAliasSF3 )->FT_QUANT, STOD(( cAliasSF3 )->FT_EMISSAO),AllTrim(cNrLivro))
								nAliqIcm := ( cAliasSF3 )->FT_ALIQICM
								nLimite  := 0
								Do Case
									Case nAliqIcm <= 7
										nLimite += nImport * 0.035
									Case nAliqIcm > 7 .and. nAliqIcm <= 12
										nLimite += nImport * 0.06
									Case nAliqIcm > 12 .and. nAliqIcm <= 18
										nLimite += nImport * 0.08
									Case nAliqIcm > 18 
										nLimite += nImport * 0.10
								EndCase

								//Quando calculado na nota for superior a importaÁ„o utiliza a importaÁ„o
								If ( cAliasSF3 )->FT_CPPRODE > nLimite
									aApuracao[ nPos , 144 ] += nLimite
								Else
									aApuracao[ nPos , 144 ] += ( cAliasSF3 )->FT_CPPRODE
								Endif
							Endif

							If ( cAliasSF3 )->FT_TIPOMOV == "S"
								Do Case
									Case ( cAliasSF3 )->FT_TPPRODE == "1"
										aApuracao[ nPos , 90 ] -= ( cAliasSF3 )->FT_CPPRODE   //  Cred Pres Propede 
									Case ( cAliasSF3 )->FT_TPPRODE == "2"
										aApuracao[ nPos , 91 ] -= ( cAliasSF3 )->FT_CPPRODE   //  Cred Pres Propede
									Case ( cAliasSF3 )->FT_TPPRODE == "3"
										aApuracao[ nPos , 92 ] -= ( cAliasSF3 )->FT_CPPRODE   //  Cred Pres Propede
									Case ( cAliasSF3 )->FT_TPPRODE == "4"
										aApuracao[ nPos , 93 ] += ( cAliasSF3 )->FT_CPPRODE   //  Cred Pres Propede
									Case ( cAliasSF3 )->FT_TPPRODE == "5"
										aApuracao[ nPos , 94 ] -= ( cAliasSF3 )->FT_CPPRODE   //  Cred Pres Propede
									Case ( cAliasSF3 )->FT_TPPRODE == "6" .and. Substr( Alltrim( aApuracao[ nPos , 01 ] ) , 1 , 1 ) $ "6"
										aApuracao[ nPos , 95 ] -= ( cAliasSF3 )->FT_CPPRODE   //  Cred Pres Propede
								EndCase
							Else
								Do Case
									Case ( cAliasSF3 )->FT_TPPRODE == "1"
										aApuracao[ nPos , 90 ] += ( cAliasSF3 )->FT_CPPRODE   //  Cred Pres Propede
									Case ( cAliasSF3 )->FT_TPPRODE == "2"
										aApuracao[ nPos , 91 ] += ( cAliasSF3 )->FT_CPPRODE   //  Cred Pres Propede
									Case ( cAliasSF3 )->FT_TPPRODE == "3"
										aApuracao[ nPos , 92 ] += ( cAliasSF3 )->FT_CPPRODE   //  Cred Pres Propede
									Case ( cAliasSF3 )->FT_TPPRODE == "4"
										aApuracao[ nPos , 93 ] -= ( cAliasSF3 )->FT_CPPRODE   //  Cred Pres Propede
									Case ( cAliasSF3 )->FT_TPPRODE == "5"
										aApuracao[ nPos , 94 ] += ( cAliasSF3 )->FT_CPPRODE   //  Cred Pres Propede
									Case ( cAliasSF3 )->FT_TPPRODE == "6" .And. Substr( Alltrim( aApuracao[ nPos , 01 ] ) , 1 , 1 ) $ "6"
										aApuracao[ nPos , 95 ] += ( cAliasSF3 )->FT_CPPRODE   //  Cred Pres Propede
								EndCase
							EndIf
						Endif
					EndIf

					// ********************** PARAIBA (PB) *****************************
					//ICMS Retido Fonte - PB-RICMS Anexo 46
					//AO ALTERAR ESTE IF, ALTERAR TAMBEM O SPED FISCAL, POIS TEM UMA COPIA DESTE TRATAMENTO NA FUNCAO APURADOC()
					If cMvEstado $ "PB" .And. ( cAliasSF3 )->FT_TIPOMOV == "S" .And. lA1REGPB .And.  ( cAliasSF3 )->A1_REGPB == "1"
						aApuracao[ nPos , 67 ]	+=	( cAliasSF3 )->FT_ICMSRET
						aApuracao[ nPos , 08 ]	-=	( cAliasSF3 )->FT_ICMSRET
					EndIf

					// ********************** RONDONIA (RN) *****************************
					// Utilizado pelo P9AUTOTEXT.RN
					If cMvEstado $ "RN"
				    	
				    	//FECOP operaÁ„o direta consumo
				    	If ( cAliasSF3 )->( SubStr( F3_CFO , 1 , 1 ) $ "56" .And. FT_ICMSRET == 0 ) 
		                    aApuracao[ nPos , 104 ]	+=	Abs( RetValFecp( Iif(lFTVFECPRN,( cAliasSF3 )->FT_VFECPRN ,0)  , Iif(lFTVALFECP,(cAliasSF3)->FT_VALFECP,0) ) )
						EndIf

				    	//FECOP operaÁ„o interna subst.tribut·ria
				    	If ( cAliasSF3 )->( SubStr( F3_CFO , 1 , 1 ) $ "5" .And. FT_ICMSRET > 0 )
		                    aApuracao[ nPos , 105 ]	+=	Abs( RetValFecp( Iif(lFTVFESTRN,( cAliasSF3 )->FT_VFESTRN ,0)  , Iif(lFTVFECPST,(cAliasSF3)->FT_VFECPST,0) ) )
						EndIf

						//FECOP operaÁ„o interestadual subst.tribut·ria
						//FECOP operaÁ„o interestadual subst.tribut·ria
				    	If ( cAliasSF3 )->( SubStr( F3_CFO , 1 , 1 ) $ "2" .And. Alltrim( FT_ANTICMS ) == "1" )
		                    aApuracao[ nPos , 106 ]	+=	Abs( RetValFecp( Iif(lFTVFECPRN,( cAliasSF3 )->FT_VFECPRN ,0)  , Iif(lFTVALFECP,(cAliasSF3)->FT_VALFECP,0) ) )
		                    aApuracao[ nPos , 106 ]	+=	Abs( RetValFecp( Iif(lFTVFESTRN,( cAliasSF3 )->FT_VFESTRN ,0)  , Iif(lFTVFECPST,(cAliasSF3)->FT_VFECPST,0) ) )
					    EndIf

						//FECOP operaÁ„o entrada interna
					    //FECOP operaÁ„o entrada interna st
					    If SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) $ "1"					        
			               aApuracao[ nPos , 107 ]	+=	Abs( RetValFecp( Iif(lFTVFECPRN,( cAliasSF3 )->FT_VFECPRN ,0)  , Iif(lFTVALFECP,(cAliasSF3)->FT_VALFECP,0) ) )					       						    
			               aApuracao[ nPos , 107 ]	+=	Abs( RetValFecp( Iif(lFTVFESTRN,( cAliasSF3 )->FT_VFESTRN ,0)  , Iif(lFTVFECPST,(cAliasSF3)->FT_VFECPST,0) ) )					       
					    EndIf
					Endif

					// ********************** MINAS GERAIS (MG) *****************************
					// Utilizado pelo P9AUTOTEXT.MG
					If cMvEstado $ "MG"
						//ICMS-ST Transportes - MG
						If Alltrim( ( cAliasSF3 )->F3_CFO ) $ "5949" .And. ( cAliasSF3 )->FT_ICMSRET > 0 .And. ;
							( cAliasSF3 )->FT_VALICM == 0 .And. ( cAliasSF3 )->F4_OBSSOL=="5"
							aApuracao[ nPos , 103 ]		+=	( cAliasSf3 )->FT_ICMSRET
						Endif

						If SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) >= "5"
			    	   		If ( cAliasSF3 )->( FT_ICMSRET == 0 )	//FECP sobre ICMS prÛprio
				          		If ( cAliasSF3 )->F2_TIPOCLI == "F"
		                     	aApuracao[ nPos , 115 ]	+=	Abs( RetValFecp( Iif(lFTVFECPMG,( cAliasSF3 )->FT_VFECPMG ,0)  , Iif(lFTVALFECP,(cAliasSF3)->FT_VALFECP,0) ) )
		                   	Else
		                      	aApuracao[ nPos , 113 ]	+=	Abs( RetValFecp( Iif(lFTVFECPMG,( cAliasSF3 )->FT_VFECPMG ,0)  , Iif(lFTVALFECP,(cAliasSF3)->FT_VALFECP,0) ) )
					     		EndIf
					    	EndIf

			    	    	If ( cAliasSF3 )->( FT_ICMSRET > 0 )	//FECP sobre ICMS-ST
				          		If ( cAliasSF3 )->F2_TIPOCLI == "F"
						        	aApuracao[ nPos , 116 ]	+=	Abs(RetValFecp( Iif(lFTVFESTMG,( cAliasSF3 )->FT_VFESTMG ,0)  , Iif(lFTVFECPST,(cAliasSF3)->FT_VFECPST,0) ))
								Else
						        	aApuracao[ nPos , 114 ]	+=	Abs(RetValFecp( Iif(lFTVFESTMG,( cAliasSF3 )->FT_VFESTMG ,0)  , Iif(lFTVFECPST,(cAliasSF3)->FT_VFECPST,0) ))
								EndIf
							EndIf
						EndIf

				       //Art. 488 Anexo IX RICMS-MG
					    If ( cAliasSF3 )->FT_OUTRICM <> 0
							If SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) < "3"

					       	If lF4CRLEIT .And. ( cAliasSF3 )->F4_CRLEIT == "1"
									aApuracao[ nPos , 87 ]	+= 	( cAliasSF3 )->FT_OUTRICM
									aApuracao[ nPos , 89 ]	:= 	"-" + Alltrim( cValtochar( ( cAliasSF3 )->F3_NFISCAL ) ) + "-" + Alltrim( cValtochar( SerieNfId(cAliasSF3,2,"F3_SERIE") ) ) + " Data: " + Dtoc( ( cAliasSF3 )->F3_EMISSAO )
		    				    Endif

				    		Else
								If ( cAliasSF3 )->F4_CRLEIT == "1"
									aApuracao[ nPos , 88 ]	+= 	( cAliasSF3 )->FT_OUTRICM
									aApuracao[ nPos , 89 ]	:= 	"-" + Alltrim( cValtochar( ( cAliasSF3 )->F3_NFISCAL ) ) + "-" + Alltrim( cValtochar( SerieNfId(cAliasSF3,2,"F3_SERIE") ) ) + " Data: " + Dtoc( ( cAliasSF3 )->F3_EMISSAO )
		    					EndIf
				    		EndIf
				    	EndIf
					Endif

					//Verifica a existencia do parametro para ICMS Retido na saida.
					//Caso esteja preenchido, apenas as UFs indicadas no mesmo
					//devem ser processadas na saida. Caso contrario, a regra do
					//MV_STUF foi mantida (tanto para entradas como para saidas)
					lSTSaida:= .F.
					lProcST := .T.

					//AO ALTERAR ESTE IF, ALTERAR TAMBEM O SPED FISCAL, POIS TEM UMA
					//  COPIA DESTE TRATAMENTO NA FUNCAO APURADOC()
					If ( cAliasSF3)->FT_TIPOMOV == "S"
						If !Empty( cMv_StUfS ) 
							If ( cAliasSF3 )->F3_ESTADO $ cMv_StUfS
								If ( cAliasSF3 )->FT_CREDST <> "4"
									aApuracao[ nPos , 07 ]	+=	( cAliasSF3 )->FT_BASERET
									If lUsaSped
										aApuracao[ nPos , 08 ]	+= ( cAliasSF3 )->FT_ICMSRET-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,(cAliasSF3)->FT_VFECPST)										
									Else
										aApuracao[ nPos , 08 ]	+=	(cAliasSF3)->( Iif( lUfRj , Iif( F3_ESTADO $ cMvEstado , FT_ICMSRET-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,(cAliasSF3)->FT_VFECPST) , 0 ) , FT_ICMSRET-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,(cAliasSF3)->FT_VFECPST) ) )										
									EndIf
									aApuracao[ nPos , 56 ]	+=  Iif( lFTVFECPST , ( cAliasSF3 )->FT_VFECPST , 0 )									
									lSTSaida := .T.
								Else
									aApuracao[ nPos , 42 ]	+=	( cAliasSF3 )->FT_BASERET
									aApuracao[ nPos , 43 ]	+=	( cAliasSF3 )->FT_ICMSRET-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,(cAliasSF3)->FT_VFECPST)									
								Endif
							Else
								lProcST := .F.
							Endif
						Endif
					Endif

					//AO ALTERAR ESTE IF, ALTERAR TAMBEM O SPED FISCAL, POIS TEM UMA
					//       COPIA DESTE TRATAMENTO NA FUNCAO APURADOC()
					If ( !Empty( cMv_StUf ) .And. ( cAliasSF3 )->F3_ESTADO $ cMv_StUf ) .Or. Empty( cMv_StUf )

						If !lSTSaida .And. lProcST
							//SE cMvEstado=GO DEVE CONSIDERAR SOMENTE FORNECEDORES/CLIENTES QUE
							//PERTENCEM AO SIMPLES NACIONAL

							If cMvEstado $ "GO"
								cSimpNac	:=	""

								If lA2SIMPNAC .And. (cAliasSF3)->F3_TIPO <> "D" 
									cSimpNac := ( cAliasSF3 )->A2_SIMPNAC
								EndIf
							EndIf

							If ( cAliasSF3 )->FT_CREDST <> "4"	.and. ((cAliasSF3)->FT_ESTADO $ cMV_SubTr .Or. (AllTrim(cMvEstado)$AllTrim(cMV_STNIEUF)))																				
								
								If (cAliasSF3)->FT_TIPO <> "D"
								
									aApuracao[ nPos , 07 ]	+=	( cAliasSF3 )->FT_BASERET
																		
									// Quando o CREDST for 1 (Credita), sÛ somar na posiÁ„o "8" (CrÈdito) quando "Imprimir crÈdito ST = SIM".
									// Verificar condiÁ„o mais abaixo para totalizaÁ„o do FT_SOLTRIB na posiÁ„o 21. A posiÁ„o 21 ser· utilizada na montagem do aCols "ST-Entradas",
									// portanto a regra deve ser a mesma para o aApuracao para que os valores apresentados nas duas abas (ST-Entradas e ApuraÁ„o ST) sejam os mesmos.								
									If (cAliasSF3)->FT_CREDST $ " #1" .And. (cAliasSF3)->FT_SOLTRIB > 0
									
										If (lImpCrdSt .And. ((!Empty(cMv_StUf) .And. (cAliasSF3)->FT_ESTADO$cMv_StUf) .Or. Empty(cMv_StUf)))
										
											If lUsaSped
												aApuracao[ nPos , 08 ]	+=	( cAliasSF3 )->FT_ICMSRET
											Else
												aApuracao[ nPos , 08 ]	+=	(cAliasSF3)->( Iif( lUfRj , Iif( FT_ESTADO $ cMvEstado , FT_ICMSRET , 0 ) , FT_ICMSRET ) )
											EndIf
											
										EndIf
									
									Else
									
										If lUsaSped
											aApuracao[ nPos , 08 ]	+=	( cAliasSF3 )->FT_ICMSRET
										Else
											aApuracao[ nPos , 08 ]	+=	(cAliasSF3)->( Iif( lUfRj , Iif( F3_ESTADO $ cMvEstado , FT_ICMSRET , 0 ) , FT_ICMSRET ) )
										EndIf
									
									EndIf
								
								EndIf
								
								If cSimpNac <> "1" .Or. ( cAliasSF3 )->F3_TIPO == "D"
									If lUsaSped
										aApuracao[ nPos , 109 ]	+=	( cAliasSF3 )->FT_ICMSRET
									Else
										aApuracao[ nPos , 109 ]	+=	(cAliasSF3)->( Iif( lUfRj , Iif( F3_ESTADO $ cMvEstado , FT_ICMSRET , 0 ) , FT_ICMSRET ) )
									EndIf
								EndIf
								aApuracao[ nPos , 56 ]	+=	Iif( lFTVFECPST , ( cAliasSF3 )->FT_VFECPST , 0 )								
							Else							
								aApuracao[ nPos , 42 ]	+=	( cAliasSF3 )->FT_BASERET
								aApuracao[ nPos , 43 ]	+=	( cAliasSF3 )->FT_ICMSRET-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,(cAliasSF3)->FT_VFECPST)								
							Endif
						Endif
					EndIf

					//AO ALTERAR ESTE IF/ELSEIF, ALTERAR TAMBEM O SPED FISCAL, POIS
					//       TEM UMA COPIA DESTE TRATAMENTO NA FUNCAO APURADOC()
					If ( cAliasSF3 )->FT_SOLTRIB>0
						Do Case
							Case (cAliasSF3)->FT_CREDST $ " #1"
								// Nao considerar devoluÁıes pois a devoluÁ„o ser· considerada como "crÈdito" independentemente da configuraÁ„o do CREDST.
								// As devoluÁıes ser„o totalizadas na posiÁ„o 12 do aApuracao mais abaixo no fluxo.								
								If ( cAliasSF3 )->FT_TIPO <> "D"
									// Soma valor de FT_SOLTRIB para exibiÁ„o na linha "006 - CrÈditos" do resumo de ApuraÁ„o - ST e no aCols da aba ST - Entradas.									
									aApuracao[ nPos , 21 ]	+=	( cAliasSF3 )->FT_SOLTRIB
									If lImpCrdSt .And.;
										( ( ( ( !Empty( cMv_StUf ) .And. (cAliasSF3)->F3_ESTADO $ cMv_StUf ) .Or. Empty( cMv_StUf ) ) .And. lProcST ) .Or. lSTSaida )	
										If lUsaSped
											aApuracao[ nPos , 08 ]	-=	( cAliasSF3 )->FT_SOLTRIB 
										Else
											aApuracao[ nPos , 08 ]	-=	Iif( lUfRj , Iif( ( cAliasSF3 )->F3_ESTADO $ cMvEstado , ( cAliasSF3 )->FT_SOLTRIB , 0 ) , ( cAliasSF3 )->FT_SOLTRIB )  
										EndIf
									EndIf
								EndIf
							Case ( cAliasSF3 )->FT_CREDST == "3"
								aApuracao[ nPos , 33 ]	+=	( cAliasSF3 )->FT_SOLTRIB
								If lUsaSped
									aApuracao[ nPos , 08 ]	-=	IIf( lImpCrdSt , ( cAliasSF3 )->FT_SOLTRIB , ( cAliasSF3 )->FT_ICMSRET ) 
								Else
									aApuracao[ nPos , 08 ]	-=	Iif( lUfRj , Iif( ( cAliasSF3 )->F3_ESTADO $ cMvEstado , IIf( lImpCrdSt , ( cAliasSF3 )->FT_SOLTRIB , ( cAliasSF3 )->FT_ICMSRET ) , 0 ) , IIf( lImpCrdSt , ( cAliasSF3 )->FT_SOLTRIB , ( cAliasSF3 )->FT_ICMSRET ) )  
								EndIf
								//Quando utilizar o tratamento de ICMS ST de Transporte de MG, o valor do ICMS           
								//a debito devera ser lancado em outros debitos, mas em coluna especifica, atraves do P9.
								If lTransST .And. Left( Alltrim( ( cAliasSF3 )->F3_CFO ) , 1 ) $ "123" .And. ( cAliasSF3 )->FT_CRPRST > 0
									aApuracao[ nPos , 40 ]	+=	(cAliasSF3)->FT_SOLTRIB
									aApuracao[ nPos , 33 ]	-=	(cAliasSF3)->FT_SOLTRIB
								Endif
						EndCase
					EndIf

					//Verifica vinculo de Nota de conhecimento de frete com notas de
					//compra (Uso Consumo/Ativo Imobilizado)para incluir na linha de
					//DEBITO POR DIFERENCIAL codigo 25020 e 25030
					lAtivo   := .F.
					lConsumo := .F.
					nValAti  := 0
					nValCon  := 0
					nPorAti  := 0
					nPorCon  := 0
					If lTransp .And. ( cAliasSF3 )->( FT_TIPOMOV == 'E' .And. F1_TIPO == "C" )

						If SF8->( MsSeek( xFilial( "SF8" )+( cAliasSF3 )->( F3_NFISCAL + F3_SERIE + F3_CLIEFOR + F3_LOJA ) ) )

							cChaveSD1 := xFilial( "SD1" )+SF8->( F8_NFORIG + F8_SERORIG + F8_FORNECE + F8_LOJA )
							If SD1->( MsSeek( cChaveSD1 ) )
								While !SD1->( Eof() ) .And.;
									cChaveSD1 == xFilial("SD1")+SD1->( D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA )

									SF4->( MsSeek( xFilial( "SF4") + SD1->D1_TES ) )

									If SF4->F4_ATUATF == "S"
										lAtivo 	:= 	.T. // Ativo permanente
										nValAti 	+= 	SD1->D1_ICMSCOM
									Else
										If	SF4->F4_CONSUMO == "S"
											lConsumo := .T. //Material de uso de consumo
											nValCon  += SD1->D1_ICMSCOM
										EndIf
									EndIf
									SD1->( dbSkip() )
								End
							EndIf
						EndIf
					EndIf
					If lAtivo
						nPorAti	:=	( nValAti * 100 ) / ( nValAti + nValCon )
						aApuracao[ nPos , 18 ]	+=	nPorAti * ( cAliasSF3 )->FT_ICMSCOM / 100  // Ativo permanente - Conh.Frete
					EndIf

					If lConsumo
						nPorCon	:=	( nValCon * 100 ) / ( nValAti + nValCon )
						aApuracao[ nPos , 17 ]	+=	nPorCon * ( cAliasSF3 )->FT_ICMSCOM / 100	//Material de uso de consumo - Conh.Frete
					Endif

					If Substr( Alltrim( ( cAliasSF3 )->F3_CFO ) , 2 , 3 ) $ "97 " .Or. Substr( Alltrim( ( cAliasSF3 )->F3_CFO) , 2 , 3 ) $ "556/557/407"
						aApuracao[ nPos , 17 ]	+= 	( cAliasSF3 )->FT_ICMSCOM  //Material de uso de consumo

					ElseIf Substr( Alltrim( ( cAliasSF3 )->F3_CFO ) , 2 , 3 ) $ "91 " .Or. Substr( Alltrim( ( cAliasSF3 )->F3_CFO ) , 2 , 3 ) $ "551/406/553"
						aApuracao[ nPos , 18 ]	+= 	( cAliasSF3 )->FT_ICMSCOM  // Ativo permanente

					EndIf

					//ApuraÁ„o da Transf. do DÈbito e CrÈdito
					//Necess·rio a criaÁ„o do campo SF3->F3_TRFICM
					//Tipo = N
					//Tamanho = 14,2
					//Picture = @E 99,999,999,999.99
					If Substr( Alltrim( ( cAliasSF3 )->F3_CFO ) , 1 , 3 ) == "000" .Or. Substr( Alltrim( ( cAliasSF3 )->F3_CFO ) , 1 , 4 ) $ "1601/1602/5601/5602"
						aApuracao[ nPos , 15 ]	+=	( cAliasSF3 )->FT_TRFICM

					ElseIf Substr( Alltrim( ( cAliasSF3 )->F3_CFO ) , 1 , 3 ) == "999" .Or. Substr( Alltrim( ( cAliasSF3 )->F3_CFO ) , 1 , 4 ) $ "1605/5605"
						aApuracao[ nPos , 16 ]	+= ( cAliasSF3 )->FT_TRFICM

					EndIf

					//AO ALTERAR ESTE IF/ELSEIF, ALTERAR TAMBEM O SPED FISCAL, POIS
					//      TEM UMA COPIA DESTE TRATAMENTO NA FUNCAO APURADOC()
					If ( cAliasSF3 )->FT_TIPOMOV == 'E' .And. ( cAliasSF3 )->F3_TIPO == "D" //Devolucao de vendas com ICMS Retido
						If ( ( !Empty( cMv_StUf ) .And. ( ( cAliasSF3 )->F3_ESTADO $ cMv_StUf ) ) .Or. Empty( cMv_StUf ) )				
							If (cAliasSF3)->FT_CREDST <> "4"
								aApuracao[ nPos , 12 ]	+=	( cAliasSF3 )->FT_ICMSRET
							Endif
						EndIF

					ElseIf ( cAliasSF3 )->FT_TIPOMOV == 'S' .And. ( cAliasSF3 )->F3_TIPO != "D"
						If ( ( !Empty( cMv_StUf) .And. ( ( cAliasSF3 )->F3_ESTADO $ cMv_StUf ) ) .Or. Empty( cMv_StUf ) )				
							If ( cAliasSF3 )->FT_CREDST <> "4"
								aApuracao[ nPos , 13 ]	+=	( cAliasSF3 )->FT_ICMSRET
							Endif 
						EndIF
					EndIf

					If lQbUF
						//Verificacao - Contribuinte ou nao 
						If FNaoContri(cAliasSF3, .F., lDIMESC)

							aApuracao[ nPos , 25 ]	+=	nFTVALCONT

							If !( Alltrim( ( cAliasSF3 )->F3_CFO ) $ cCFATGMB .And. cMvEstado == "RS" )
								aApuracao[ nPos , 26 ]	+=	( cAliasSF3 )->FT_BASEICM
								aApuracao[ nPos , 58 ]	+=	Iif( lFTVALFECP , ( cAliasSF3 )->FT_VALFECP , 0 )
							Endif

						Else //Contribuinte
							aApuracao[ nPos , 27 ]	+=	nFTVALCONT

							If !( Alltrim( ( cAliasSF3 )->F3_CFO ) $ cCFATGMB .And. cMvEstado == "RS" )
								aApuracao[ nPos , 28 ]	+=	( cAliasSF3 )->FT_BASEICM
							Endif
						EndIf
					Endif

					//Processamento dos valores da apuraÁ„o do DIFAL
					//Verifica se os campos existem na SF3 e se o DIFAL ou FECP est· preenchidos
					If lFTDIFAL .AND. lFTVFCPDIF .AND. lFTPDDES .AND. (( cAliasSF3 )->FT_DIFAL > 0 .OR. ( cAliasSF3 )->FT_PDDES > 0)

						nFecpDest	:= (cAliasSF3)->FT_VFCPDIF
						nDifOri		:= (cAliasSF3)->FT_ICMSCOM
						nDifDest	:= (cAliasSF3)->FT_DIFAL
						cEntSaiDif	:= ''

						If SubStr( ( cAliasSF3 )->FT_CFOP , 1 , 1 ) == "6" .And. !( cAliasSF3 )->F3_TIPO $ "D"
							//SaÌda com dÈbito do DIFAL 
							cEntSaiDif	= '2'
						ElseIF SubStr( ( cAliasSF3 )->FT_CFOP , 1 , 1 ) == "2" .And. ( cAliasSF3 )->F3_TIPO $ "D" .Or. ( lMVCDIFBEN .And. ( cAliasSF3 )->F3_TIPO $ "B" .And. ( cAliasSF3 )->F3_FORMUL == "S" ) 
							//Entrada com crÈdito do difal
							cEntSaiDif	= '1'
						EndIF

						//---------------------------
						//DIFAL PARA ESTADO DE ORIGEM
						//---------------------------
						nPosDifal	:=	Ascan(aDifal,{|x|x[1]==cMvEstado})
						// N„o apura estados que ir„o utilizar apuraÁ„o do ICMS Proprio.
						IF !(cMvEstado $ cEstE310)
							If nPosDifal == 0
								AADD(aDifal,Array(05))
								nPosDifal	:= Len(aDifal)
								aDifal[nPosDifal,01]	:=	cMvEstado 	//UF    
								aDifal[nPosDifal,02]	:=	0			//DÈbito do Difal na saÌda
								aDifal[nPosDifal,03]	:=	0			//DÈbito do FECP na saÌda
								aDifal[nPosDifal,04]	:=	0			//CrÈdito do DIFAL na entrada
								aDifal[nPosDifal,05]	:=	0			//CrÈdito do FECO na entrada
							EndIf

							If cEntSaiDif == '2' //SaÌda com DIFAL

								//Para o estado de origem, na saÌda teremos somente o valor do diferencial partilhado
								//O FECP È somente para estado de destino
								aDifal[nPosDifal,02]	+=	(cAliasSF3)->FT_ICMSCOM 	//DÈbito do Difal na saÌda

							ElseIf cEntSaiDif == '1' //Entrada (devoluÁ„o de venda com valor de DIFAL)

								//Na devoluÁ„o de venda dever· considerar crÈdito o valor do diferencial partilhado 
								//O FECP È somente para estado de destino
								aDifal[nPosDifal,04]	+=	(cAliasSF3)->FT_ICMSCOM 	//DÈbito do Difal na saÌda

							EndIF
						EndIF
						//----------------------------
						//DIFAL PARA ESTADO DE DESTINO
						//----------------------------
						If (cAliasSF3)->FT_ESTADO  $ cMV_SubTr .Or. (cAliasSF3)->F3_ESTADO $ cMV_DifTr
							nPosDifal	:=	Ascan(aDifal,{|x|x[1]==(cAliasSF3)->FT_ESTADO })			
							If nPosDifal == 0
								AADD(aDifal,Array(05))
								nPosDifal	:= Len(aDifal)
								aDifal[nPosDifal,01]	:=	(cAliasSF3)->FT_ESTADO 		//UF    
								aDifal[nPosDifal,02]	:=	0						//DÈbito do Difal na saÌda
								aDifal[nPosDifal,03]	:=	0						//DÈbito do FECP na saÌda
								aDifal[nPosDifal,04]	:=	0								//CrÈdito do DIFAL na entrada
								aDifal[nPosDifal,05]	:=	0 								//CrÈdito do FECO na entrada
							EndIF		
								
							//Para estado de destino teremos o diferencial partilhado
							//E tambÈm o fecp integral
							
							If cEntSaiDif == '2' //SaÌda com DIFAL
								aDifal[nPosDifal,02]	+=	nDifDest			//DÈbito do Difal na saÌda
								aDifal[nPosDifal,03]	+=	nFecpDest			//DÈbito do FECP na saÌda		
							Elseif cEntSaiDif == '1' //SaÌda com DIFAL
								aDifal[nPosDifal,04]	+=	nDifDest			//DÈbito do Difal na saÌda
								aDifal[nPosDifal,05]	+=	nFecpDest			//DÈbito do FECP na saÌda				
							EndIF
						EndIF
					
					EndIF

					/*
					Aqui ser„o acumulados o valor cont·bil das saÌdas para aba Fomentar de GO. Ser„o acumuladas as saÌdas com exceÁ„o das devoluÁıes,
					remessas para industrializaÁ„o/beneficiamento, remessa para a depÛsito/armazÈm e saÌdas que constituem mera movimentaÁ„o fÌsica.
					*/
					IF lFomentGO .AND. Left( Alltrim( ( cAliasSF3 )->F3_CFO ) , 1 ) >= "5" .AND. !( cAliasSF3 )->F3_TIPO $ "B/D" .AND. !alltrim(( cAliasSF3 )->F3_CFO) $ cCfMeraMov 
						aApuracao[ nPos , 142]	+= nFTVALCONT
					EndIF

					/*Aqui acumularei os valores de crÈditos por entrada no perÌodo, para ser exibido na apuraÁ„o do Fomentar de GO. 
					Ser„o consideradas as entradas com crÈdito, porÈm as entradas que tiverem o CFOP contido no par‚metro cCfCrdFo n„o ser„o consideradas				
					*/
					IF lFomentGO .AND. Left( Alltrim( ( cAliasSF3 )->F3_CFO ) , 1 ) <= "3" .AND. !( cAliasSF3 )->F3_TIPO $ "B/D" .AND. !alltrim(( cAliasSF3 )->F3_CFO) $ cCfCrdFo
						aApuracao[ nPos , 145]	+= ( cAliasSF3 )->FT_VALICM
						
					EndIF					

					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥Atribuicao do Valor de Credito Estimulo≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
					If lCrdEst
						For nX := 1 To Len( aEstimulo )
							aApuracao[ nPos , 30 ]	+=	Iif( ( aEstimulo[ nX , 3 ] - aEstimulo[ nX , 2 ] ) < 0 , 0 , ( aEstimulo[ nX , 3 ] - aEstimulo[ nX , 2 ] ) )
						Next nX
						lCrdEst	:=.F.
					Endif

					//-------------------------------------------------------------------------------------
					//
					//									INCENTIVOS FISCAIS
					//
					//-------------------------------------------------------------------------------------
					//	Abaixo sao calculados os valores de Incentivos Fiscais
					//-------------------------------------------------------------------------------------
					If aFindFunc[FF_XAPGETINCENT]
						
						//-------------------------------------------------------------------------------------
						//
						//									DESENVOLVE - BA
						//
						//-------------------------------------------------------------------------------------
						//	Programa de Desenvolvimento Industrial e de Integracao Economica do Estado da Bahia
						//-------------------------------------------------------------------------------------
						//Embasamento legal:
						//
						//Resolucao  No 123/2009 (regime especial) , Lei no 7.980/2001 e Decreto no 8.205/2002
						//-------------------------------------------------------------------------------------
						If cMvEstado == "BA"
							If SubStr( ( cAliasSF3 )->FT_CFOP , 1 , 1 ) < "5" .and. ( (cAliasSF3)->FT_CFOP $ aCfopDsv[1] .or. (cAliasSF3)->FT_CFOP $ "5910|5911|5912|6910|6911|6912" )
								//Creditos - CNVP
								aGetIncent	:=	xApGetIncent(	"DES" , cAliasSF3 , .T. , {1,dDtIni,lB5PROJDES,( cAliasSF3 )->FT_PRODUTO,aMVDESENV} )
								aApuracao[ nPos , 120 ]	+=	aGetIncent[1]
								aApuracao[ nPos , 121 ]	+=	aGetIncent[2]
							Elseif ( (cAliasSF3)->FT_CFOP $ aCfopDsv[2] .or. (cAliasSF3)->FT_CFOP $ "1910|1911|1912|2910|2911|2912" )
								//Debitos - DNVP
								aGetIncent	:=	xApGetIncent(	"DES" , cAliasSF3 , .T. , {1,dDtIni,lB5PROJDES,( cAliasSF3 )->FT_PRODUTO,aMVDESENV} )
								aApuracao[ nPos , 121 ]	+=	aGetIncent[1]
								aApuracao[ nPos , 120 ]	+=	aGetIncent[2]
							Endif
						
						//-------------------------------------------------------------------------------------
						//
						//						TERMO DE ACORDO - CREDITO PRESUMIDO/ES
						//
						//-------------------------------------------------------------------------------------
						Elseif lF4ESCRDPR .And. cMvEstado == "ES" .And. ( cAliasSF3 )->F4_ESCRDPR$"1S" .And. Len(aMVFISCPES) > 0
			
							If dDtIni < CToD(aMVFISCPES[1])
						    
							    // ------------------------------------------
								// Estorno de Credito - Devolucoes - Entradas
								// ------------------------------------------
								If SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) < "5" .And. ( cAliasSF3 )->F3_TIPO $ "D"
								    
									// ------------------------------------------
									// nPos(125) - Estorno de Devolucoes Internas
									// ------------------------------------------
									If SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) == "1"
									
										aApuracao[ nPos , 125 ]	+=	( ( cAliasSF3 )->FT_VALICM * aMVFISCPES[2] ) / 100
								    
									// ------------------------------------------
									// nPos(126) - Estorno de Devolucoes Interestaduais
									// ------------------------------------------
									Elseif SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) == "2"
									
										aApuracao[ nPos , 126 ]	+=	( ( cAliasSF3 )->FT_VALICM * aMVFISCPES[3] ) / 100
									
									Endif
								
								// ------------------------------------------
								// Credito Presumido - Saidas
								// ------------------------------------------
								Elseif SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) >= "5"
								
									// ------------------------------------------
									// nPos(127) - Saidas Internas
									// ------------------------------------------
									If SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) == "5"
										
										aApuracao[ nPos , 127 ]	+=	( ( cAliasSF3 )->FT_VALICM * aMVFISCPES[2] ) / 100
									
									// ------------------------------------------
									// nPos(128) - Saidas Interestaduais
									// ------------------------------------------
									Elseif SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) == "6"
									
										aApuracao[ nPos , 128 ]	+=	( ( cAliasSF3 )->FT_VALICM * aMVFISCPES[3] ) / 100
									
									Endif
								Endif
							Endif
						Endif
					Endif	  
					// ------------------------------------------
					// Tratamento do convÍnio 139/06
					// ------------------------------------------
					If lConv13906 .AND. ( cAliasSF3 )->FT_CV139 == "1"
						nPos	:=	Ascan( aConv139,{ | x | x[ 1 ] == ( cAliasSF3 )->F3_ESTADO } )
						If	nPos == 0
							AADD( aConv139 , Array( 04 ) )
							nPos	:=	Len( aConv139 )
							aConv139[ nPos , 01 ]	:=	( cAliasSF3 )->F3_ESTADO
							aConv139[ nPos , 02 ]	:=	nFTVALCONT
							aConv139[ nPos , 03 ]	:=	( cAliasSF3 )->FT_BASEICM
							aConv139[ nPos , 04 ]	:=	( cAliasSF3 )->FT_VALICM
						Else
							aConv139[ nPos , 02 ]	+=	nFTVALCONT
							aConv139[ nPos , 03 ]	+=	( cAliasSF3 )->FT_BASEICM
							aConv139[ nPos , 04 ]	+=	( cAliasSF3 )->FT_VALICM
						EndIF
					EndIF

					nPosAp := nPos // Guardo nPos para verificar CDA x SF3
					//Apuracao do ICMS Retido por Unidade de Federacao				
					If ( ( !Empty( cMv_StUf ) .And. ( cAliasSF3 )->F3_ESTADO $ cMv_StUf ) .Or. Empty( cMv_StUf ) ) .Or. ;
						( ( !Empty( cMv_StUfS ) .And. ( cAliasSF3 )->F3_ESTADO $ cMv_StUfS .And. ( cAliasSF3 )->FT_TIPOMOV == "S" ) )

						If ( cAliasSF3 )->FT_TIPOMOV == "E"

							nPos	:=	Ascan( aEntr,{ | x | x[ 1 ] == ( cAliasSF3 )->F3_ESTADO } )
							If nPos == 0
								AADD( aEntr , Array( 08 ) )
								nPos	:=	Len( aEntr )
								aEntr[ nPos , 01 ]	:=	( cAliasSF3 )->F3_ESTADO
								Aeval( aEntr[ nPos ] , { | x , i | aEntr[ nPos , i ] := 0 } , 2 )
							EndIf
							If ( cAliasSF3 )->FT_CREDST <> "4"
								aEntr[ nPos , 03 ]	+=	( cAliasSF3 )->FT_BASERET
								//Devolucoes de vendas com credito de ST
								If ( cAliasSF3 )->F3_TIPO == "D"
									aEntr[ nPos , 07 ]	+= ( cAliasSF3 )->FT_ICMSRET	//ICMSRET
								Else
									aEntr[ nPos , 04 ]	+=	( cAliasSF3 )->FT_ICMSRET	//ICMSRET
								EndIf
							Endif
							If ( cAliasSF3 )->FT_SOLTRIB > 0
								Do Case
									Case ( cAliasSF3 )->FT_CREDST $ " #1"
										// N„o considerar as devoluÁıes pois elas ser„o sempre consideradas como crÈdito, na posiÁ„o 7 do array aEnt, independente do CREDST (com exceÁ„o do "4"). 
										If (cAliasSF3)->FT_TIPO <> "D"										
											If !lImpCrdSt
												aEntr[ nPos , 04 ]	-=	( cAliasSF3 )->FT_SOLTRIB
											EndIf
											aEntr[ nPos , 05 ]	+=	( cAliasSF3 )->FT_SOLTRIB
										EndIf
									Case ( cAliasSF3 )->FT_CREDST == "3"
										aEntr[ nPos , 06 ]	+=	( cAliasSF3 )->FT_SOLTRIB
										aEntr[ nPos , 04 ]	-=	( cAliasSF3 )->FT_SOLTRIB
									EndCase
							EndIf
							//Se MV_ESTADO n„o for igual a RJ e a opraÁ„o for do RJ ir· acumular valor de FECP ST
							If !lUfRj .AND. aEntr[nPos,01] == "RJ"
								aEntr[ nPos , 08 ]	+=	Iif(lFTVFECPST, (cAliasSF3)->FT_VFECPST, 0) 	//VFRCPST
							EndIF
						Else
							lProcST := .T.
							//Verifica se deve considerar esta UF na apuracao
							If !Empty( cMv_StUfS ) .And. !( ( cAliasSF3 )->F3_ESTADO $ cMv_StUfS )
								lProcST := .F.
							Endif

							If lProcST

								//Verifica se o ICMS ja foi pago em GNRE vinculada a NF
								If lChkGnre .And. ( cAliasSF3 )->FT_ICMSRET > 0 .And. ( cAliasSF3 )->FT_CREDST <> "4" .And. lCDC
									VerGNRENF( cAliasSF3 , @aIcmPago )
								Endif

								nPos	:=	Ascan( aSaid , { | x | x[ 1 ] == ( cAliasSF3 )->F3_ESTADO } )
								If nPos==0
									AADD( aSaid , Array( 05 ) )
									nPos	:=	Len( aSaid )
									aSaid[ nPos , 01 ]	:=	( cAliasSF3 )->F3_ESTADO
									Aeval( aSaid[ nPos ] , { | x , i | aSaid[ nPos , i ] := 0 } , 2 )
								Endif

								If (cAliasSF3)->FT_CREDST <> "4"
									aSaid[ nPos , 03 ]	+=	( cAliasSF3 )->FT_BASERET
									aSaid[ nPos , 04 ]	+=	( cAliasSF3 )->FT_ICMSRET-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,(cAliasSF3)->FT_VFECPST)								

									If nPos > 0 .And. aSaid[nPos,01]$cMVUFECSEP
										aSaid[nPos,05] +=	(cAliasSF3)->FT_VFECPST+(cAliasSF3)->FT_VFESTRN+(cAliasSF3)->FT_VFESTMG + (Iif(lFTVFESTMT,+(cAliasSF3)->FT_VFESTMT,0))
						    		EndIf
								Endif
							Endif
						EndIf
					EndIf

					If cImp == "IC" .AND. lUsaSped .And. lNewNF .And. (cAliasSF3)->COUNTCDA >= 1 
						CkLancCDA( cAliasSF3 , @aApurCDA , @aCDAIC , @aCDAST , @aCDADE , @aDbEsp , cNrLivro, @aCdaDifal,@aCDAExtra,@aApurExtra,lProcRefer,aSubAp)
						//Array que me retorna o lancamento de documento fiscal que corresponde ao valor do ST-Debitado na entrada (_CREDST=3)
						//Este array eh utilizado no MATA953 para fazer a subtracao do valor da GNRE para o estado(Aba 3) do valor da GNRE que
						//   serah gerado pelo Debitos Especiais atraves do lancamento de NF.                                                  
						If Len( aDbEsp ) > 0 .And. Type( "aEntr[nPos,01]" ) <> "U" 
							aAdd( aRetEsp , { aDbEsp[ 1 ] , aDbEsp[ 2 ] , aEntr[ nPos , 01 ] } )
						EndIf
					EndIf
					
					nPos	:=	nPosAp	//Restaurando a posicao do aApuracao

					//Na posicao 65 do aApuracao sera gravado o total Credito
					// ICMS Nao Dest. calculado na tabela CDM (Art.271 RICMS/SP
					//Na posicao 96 do aApuracao sera gravado o total Estornos
					//do CrÈdito ref. Devolucao Vendas do perÌodo
					If lICMDes
						aApuracao[ nPos , 65 ]	:=	nTotCDM // Totaliza CrÈdito calculado (CDM_ICMENT)           	       	       	   
						aApuracao[ nPos , 96 ]	:=	nTotEST // Totaliza Estorno do CrÈdito calculado (CDM_ESTORN) das DevoluÁıes Vendas           	       	       	   
					EndIf
					If	lApGIEFD
           				If F3K->(dbSeek(xFilial("F3K")+(cAliasSF3)->(FT_PRODUTO+FT_CFOP)))           			
							ApurCDV(cAliasSF3,@aApurCDV,lMVRF3THRE)                	   		
	              		Endif						
					EndIf
				
					If lConfApur .AND. lAliasApur
						// ApuraÁ„o ICMS
						If cImp=="IC"
							If /*aApuracao[nPos,04] > 0 .And. */SubStr((cAliasSF3)->F3_CFO,1,1) >= "5" //.And. (cAliasSF3)->F3_VALICM > 0
								ApurTempNF((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_ENTRADA,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA,;
								(cAliasSF3)->F3_CFO,(cAliasSF3)->F3_ALIQICM,(cAliasSF3)->F3_FORMULA,"Debito","ICMS", cAlsDeb, cAliasSF3)
							ElseIf aApuracao[nPos,04] > 0 .And. SubStr((cAliasSF3)->F3_CFO,1,1) < "5" .And. (cAliasSF3)->F3_VALICM > 0 
								ApurTempNF((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_ENTRADA,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA,;
								(cAliasSF3)->F3_CFO,(cAliasSF3)->F3_ALIQICM,(cAliasSF3)->F3_FORMULA,"Credito","ICMS", cAlsCrd, cAliasSF3)
							EndIf
							// ApuraÁ„o ICMS-ST
							If aApuracao[nPos,13] > 0 .And. SubStr((cAliasSF3)->F3_CFO,1,1) >= "5" 
								ApurTempNF((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_ENTRADA,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA,;
								(cAliasSF3)->F3_CFO,(cAliasSF3)->F3_ALIQICM,(cAliasSF3)->F3_FORMULA,"ST_Debito","ICMS", cAlsSTd, cAliasSF3)
							ElseIf ( (cAliasSF3)->F3_ICMSRET > 0 .And. (cAliasSF3)->F3_TIPO == "D" ) .Or. ( aApuracao[nPos,8] > 0 .And. SubStr((cAliasSF3)->F3_CFO,1,1) < "5" )
								ApurTempNF((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_ENTRADA,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA,;
								(cAliasSF3)->F3_CFO,(cAliasSF3)->F3_ALIQICM,(cAliasSF3)->F3_FORMULA,"ST_Credito","ICMS",cAlsSTe, cAliasSF3)
							Endif
						EndIf				
					Endif
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥             Apuracao de ISS por Municipio               |
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

				ElseIf cImp == "IS" .And. ValType( aApurMun ) == "A"

					//Verifica o Prefixo correto da Nota fiscal
					cPrefixo	:= 	Iif (Empty (( cAliasSF3 )->F2_PREFIXO), &(cMV_1DUPREF), ( cAliasSF3 )->F2_PREFIXO)

					// Chave p/ busca na SE2
					cChaveSe2	:= 	cPrefixo + ( cAliasSF3 )->F2_DUPL

					If SE2->( MsSeek( xFilial( "SE2" ) + cChaveSe2 ) ) .And. SE2->E2_TIPO $ MVTAXA + "|" + MVTXA .And. AllTrim( SE2->E2_NATUREZ ) $ &( cMVISS )

						If SA2->( MsSeek( xFilial("SA2")+SE2->( E2_FORNECE + E2_LOJA ) ) )						
							cMunic := UfCodIBGE(SA2->A2_EST) + SA2->A2_COD_MUN
							cDescMun := SA2->A2_MUN
							cForISS := SA2->A2_COD
							cLojISS := SA2->A2_LOJA
						EndIf

					Else
						If SC5->(MsSeek(xFilial("SC5") + ( cAliasSF3 )->D2_PEDIDO))

							// Se preencher a UF e o municipio da prestacao no pedido de venda, considerar estes dados p/ posicionar a CE1.
							If !Empty(AllTrim(SC5->C5_ESTPRES)) .And. !Empty(AllTrim(SC5->C5_MUNPRES))
								cChvMun := SC5->C5_ESTPRES + AllTrim(SC5->C5_MUNPRES)
							Else
								cChvMun := ( cAliasSF3 )->A1_EST + ( cAliasSF3 )->A1_COD_MUN 
							EndIf

							// Busca fornecedor do ISS no pedido de venda
							If 	!(Empty(SC5->C5_FORNISS))

								If SA2->(MsSeek(xFilial("SA2")+SC5->C5_FORNISS))
									cMunic	:= UfCodIBGE(SA2->A2_EST) + SA2->A2_COD_MUN
									cDescMun := SA2->A2_MUN
									cForISS := SA2->A2_COD
									cLojISS := SA2->A2_LOJA
								EndIf

							// Busca pelo produto no cadastro de aliquotas(CE1)
							ElseIf CE1->(MsSeek(xFilial("CE1") + ( cAliasSF3 )->D2_CODISS + cChvMun + ( cAliasSF3 )->D2_COD))										
								If SA2->(MsSeek(xFilial("SA2")+CE1->CE1_FORISS+CE1->CE1_LOJISS))
									cMunic	:= UfCodIBGE(SA2->A2_EST) + SA2->A2_COD_MUN
									cDescMun := SA2->A2_MUN
									cForISS := SA2->A2_COD
									cLojISS := SA2->A2_LOJA
								EndIf
							// Se n„o encontrar em nenhum cadastro, continua com o parametro e fornecedor padrao.
							Else
								// Parametro de forn. padrao do ISS na apuracao.							
								If !Empty(cMvFPadISS) .And. SA2->(MsSeek(xFilial("SA2") + cMvFPadISS))
									cMunic	:= UfCodIBGE(SA2->A2_EST) + SA2->A2_COD_MUN
									cDescMun := SA2->A2_MUN
									cForISS := SA2->A2_COD
									cLojISS := SA2->A2_LOJA
								Else
									cMunic	:= Space(TamSX3("A2_EST")[1] + TamSX3("A2_COD_MUN")[1])
									cDescMun := Space(TamSX3("A2_MUN")[1])
									cForISS := Space(TamSX3("A2_COD")[1])
									cLojISS := Space(TamSX3("A2_LOJA")[1])
								EndIf
							EndIf
						EndIf
					EndIf

					If ( nPosMun := aScan( aApurMun , { | aX | AllTrim(aX[ 1 ]) == AllTrim(cMunic) } ) ) == 0
						aAdd(aApurMun,{cMunic,;
							cDescMun,;
							nFTVALCONT ,;
							( cAliasSF3 )->FT_BASEICM,;
							( cAliasSF3 )->FT_VALICM,;
							( cAliasSF3 )->FT_ISENICM,;
							( cAliasSF3 )->FT_OUTRICM,;
							( cAliasSF3 )->FT_ISSMAT,;
							( cAliasSF3 )->FT_ISSSUB,;
							cForISS,;
							IIf((cAliasSF3)->FT_RECISS == "1", (cAliasSF3)->FT_VALICM, 0),;
							cLojISS})
					Else
						aApurMun[ nPosMun , 3 ]	+=	nFTVALCONT
						aApurMun[ nPosMun , 4 ]	+=	( cAliasSF3 )->FT_BASEICM
						aApurMun[ nPosMun , 5 ]	+=	( cAliasSF3 )->FT_VALICM
						aApurMun[ nPosMun , 6 ]	+=	( cAliasSF3 )->FT_ISENICM
						aApurMun[ nPosMun , 7 ]	+=	( cAliasSF3 )->FT_OUTRICM
						aApurMun[ nPosMun , 8 ]	+=	( cAliasSF3 )->FT_ISSMAT
						aApurMun[ nPosMun , 9 ]	+=	( cAliasSF3 )->FT_ISSSUB
						aApurMun[ nPosMun , 11]	+=	IIf((cAliasSF3)->FT_RECISS == "1", (cAliasSF3)->FT_VALICM, 0)
					EndIf
				EndIf

				// Valor de ISS retido
				If cImp = "IS" .And. (cAliasSF3)->FT_RECISS == "1"
					aApuracao[ nPos , 132 ] += (cAliasSF3)->FT_VALICM
				EndIf
			EndIf

			lNewSF3		:=	.F.
			lNewNF		:=	.F.
			( cAliasSF3 )->( dbSkip() )
		End

		/*
		TRECHO RETIRADO PORQUE APOS VERIFICACAO COM LIDER DO LOJA (LL), ESTE TRATAMENTO NAO DEVE SER MAIS UTILIZADO NA APURACAO DO IMPOSTO.
		SEGUNDO ELE, ESTE TRATAMENTO NAO TEM SENTIDO, POIS O MAPARESUMO EH UM TRATAMENTO ANTES DO SPED, COM O SPED O LIVRO EH GERADO ON-LINE.
		//Exclui arquivo temporario≥
		If lMapResumo
			MaXRExecArq( 2 , cArqTmpMP )
			cAliasSf3	:=	cArqBkpQry
			dbSelectArea( cAliasSF3 )
		EndIf
		*/

		//Fecha a area de trabalho da query
		( cAliasSF3 )->( dbCloseArea() )

		//Chama funÁ„o da rotina FISR017 para buscar o valor do Ressarcimento de ICMS.
		IF cMvEstado $ "BA" .AND. aFindFunc[FF_SELRELR017] .AND. Len(aApuracao) > 0
			aApuracao[len(aApuracao)][129]+=SelRelR017("BA",dDtIni,dDtFim,.T.)
		EndIF
		If FWModeAccess( "SF3" , 3 ) == "C"
			Exit
		Endif
		SM0->( dbSkip() )
	Enddo

	//condicao para gerar o mensagem no console.log
	If lMVRF3LOG
		ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0121 + ' ( ' + cPerThread + ' ) - Thread: ' + cNThread )	//'Alimentando TEMPDB com o movimento do perÌodo'
	EndIf

	//Alimentando TEMPDBs no RDBMS
	XApTMPDBRes( aApuracao , cAlsTempDB , c2AlsTempDB , lQbUfCfop , lQbAliq , lQbCFO , lQbPais , lQbUF , lQbCfopUf ,;
				aEntr, aSaid, aApurCDA, aCDAST, aCDADE, aCDAIC, aRetEsp, aApurMun, aIcmPago , aNFsGiaRs, aRecStDif, cNThread, aMensIPI, aDifal,aCDADifal,aCDAExtra,aApurExtra,aApurCDV,aCDAIPI,aNWCredAcu,c2TempDB)

	SM0->( dbGoTo( nRegEmp ) )
	cFilAnt := SM0->M0_CODFIL	
	

	//condicao para gerar o mensagem no console.log
	If lMVRF3LOG
		ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0122 + ' ( de ' + cPerThread + ' ) - Thread: ' + cNThread )	//'Termino do processamento do movimento'
	EndIf

	// STATUS 3 - Processamento efetuado com sucesso
	PutGlbValue( cJobAux , '3' )
	GlbUnLock()

	If lBuild
		FreeObj(oHashCFOP)
		oHashCFOP := NIL

		FreeObj(oHasCodAju)
		oHasCodAju := NIL		
	Endif

	RpcClearEnv()

EndIf

//nOpcApur igual a '3', monta o retorno da funcao baseado na tabela jah criada, sempre reprocessar o movimento
If nOpcApur == 3

	//Tratamento para quando se efetuar somente a leitura dos dados gravados no TEMPDB 
	//Alimentando aApuracao conforme TEMPDB do RDBMS
	aApuracao	:=	{}
	aEntr		:=	{}
	aSaid		:=	{}
	aApurCDA	:=	{}
	aCDAST		:=	{}
	aCDADE		:=	{}
	aCDAIC		:=	{}
	aRetEsp		:=	{}
	aApurMun	:=	{}
	aIcmPago	:=	{}
	aNFsGiaRs	:=	{}
	aDifal		:=	{}
	aCDADifal	:=	{}
	aCDAExtra	:= {}
	aApurExtra	:= {}
	aApurCDV	:=	{}
	aCDAIPI		:=	{}	
	aNWCredAcu	:=	{}	

	If TcCanOpen( cTempDB ) .AND. TcCanOpen( c2TempDB )
		dbUseArea( .T. ,__cRdd , cTempDB , cAlsTempDB , .T. , .F. )
		dbSetIndex( cTempDB + '_01' )

		dbUseArea( .T. ,__cRdd , c2TempDB , c2AlsTempDB , .T. , .F. )
		dbSetIndex( c2TempDB + '_01' )

		If nRegua>0
			If nRegua	==	1
				ProcRegua( ( cAlsTempDB )->( RecCount() ) + ( c2AlsTempDB )->( RecCount() ) )
			Else
				SetRegua( ( cAlsTempDB )->( RecCount() ) + ( c2AlsTempDB )->( RecCount() ) )
			Endif
		Endif
		lProRurPJ := (SM0->M0_PRODRUR$"J2F1")
		While !( cAlsTempDB )->( Eof() )

			If nRegua>0
				If nRegua	==	1
					IncProc( OemToAnsi( STR0001 ) )	//"Executando apuraáÑo..."
				Else
					IncRegua()
				Endif
			Endif

			//Acumuladores
			cCFO	:=	( cAlsTempDB )->CMP001
			Do Case
				Case lQbUfCfop
					
					nPos	:= aScan( aApuracao , { |x| x[ 19 ] == ( cAlsTempDB )->CMP019 .And. x[ 1 ] == cCFO } )					

				Case lQbAliq .and. lQbCFO .and. !lQbPais .And. !lQbUF
					IF cImp == "IP"
						If lQbCfopUf
							nPos := aScan( aApuracao , { |x| x[ 1 ] == cCFO .And. x[ 2 ] == ( cAlsTempDB )->CMP002 .And. x[ 19 ] == ( cAlsTempDB )->CMP019} )						
						Else
							nPos := aScan( aApuracao , { |x| x[ 1 ] == cCFO .And. x[ 2 ] == ( cAlsTempDB )->CMP002} )						
						Endif
					Else
						If lQbCfopUf
							nPos := aScan( aApuracao , { |x| x[ 1 ] == cCFO .And. x[ 2 ] == ( cAlsTempDB )->CMP002 .And. x[ 19 ] == ( cAlsTempDB )->CMP019 } )
						Else
							nPos := aScan( aApuracao , { |x| x[ 1 ] == cCFO .And. x[ 2 ] == ( cAlsTempDB )->CMP002 } )
						Endif
					EndIf
				Case !lQbAliq .And. lQbCFO .And. !lQbPais .And. !lQbUF
					IF cImp == "IP"
						If lQbCfopUf
							nPos := Ascan( aApuracao , { |x| x[ 1 ] == cCFO .And. x[ 19 ] == ( cAlsTempDB )->CMP019} )						
						Else
							nPos := Ascan( aApuracao , { |x| x[ 1 ] == cCFO} )						
						Endif
					Else
						If lQbCfopUf .OR. (cImp == "IC" .and. lFunname)
							nPos := Ascan( aApuracao , { |x| x[ 1 ] == cCFO .And. x[ 19 ] == ( cAlsTempDB )->CMP019 } )
						Else
							nPos := Ascan( aApuracao , { |x| x[ 1 ] == cCFO} )
						Endif
					EndIf
				Case (lQbAliq .And. !lQbCFO) .Or. ( !lQbAliq .And. !lQbCFO ) .And. !lQbPais .And. !lQbUF
					If !cImp == "IS"
						cCFO	:=	IIf( Val( Substr( ( cAlsTempDB )->CMP001 , 1 , 1 ) ) < 5 , "ENTR" , "SAID" )
					EndIF

					IF cImp == "IP"
						If lQbCfopUf
							nPos := Ascan( aApuracao , { |x| x[ 1 ] == cCFO .And. x[ 2 ] == ( cAlsTempDB )->CMP002 .And. x[ 19 ] == ( cAlsTempDB )->CMP019} )
						Else
							nPos := Ascan( aApuracao , { |x| x[ 1 ] == cCFO .And. x[ 2 ] == ( cAlsTempDB )->CMP002} )						
						Endif
					Else
						If lQbCfopUf
							nPos := Ascan( aApuracao , { |x| x[ 1 ] == cCFO .And. x[ 2 ] == ( cAlsTempDB )->CMP002 .And. x[ 19 ] == ( cAlsTempDB )->CMP019 } )
						Else
							nPos := Ascan( aApuracao , { |x| x[ 1 ] == cCFO .And. x[ 2 ] == ( cAlsTempDB )->CMP002 } )
						Endif
					EndIf
				Case lQbUF .and. !lQbCFO .and.!lQbAliq .and. !lQbPais
					cCFO	:=	IIf( Val( Substr( cCFO , 1  , 1 ) ) < 5 , "ENTR" , "SAID" )				
					nPos	:=	Ascan( aApuracao , { |x| x[ 19 ] == ( cAlsTempDB )->CMP019 .and. x[ 1 ] == cCFO } )				
				Case lQbUF .and. lQbCFO .and.!lQbAliq .and. !lQbPais				
					nPos	:=	Ascan( aApuracao , { |x| x[ 19 ] == ( cAlsTempDB )->CMP019 .and. x[1] == cCFO } )					
				Case lQbPais .and. !lQbCFO .and. !lQbAliq .And. !lQbUF
					cCFO	:=	IIf( Val( Substr( cCFO , 1 ,  1 ) ) < 5 , "ENTR" , "SAID" )
					IF cImp == "IP"
						nPos	:=	Ascan( aApuracao , { |x| x[20] == ( cAlsTempDB )->CMP020 .and. x[1] == cCFO } )
					Else
						nPos	:=	Ascan( aApuracao , { |x| x[20] == ( cAlsTempDB )->CMP020 .and. x[1] == cCFO } )
					EndIf
			EndCase
			If nPos == 0
				aAdd( aApuracao , Array( LEN_ARRAY_APURACAO ) )
				nPos	:=	Len( aApuracao )
			EndIf

			//Alimentando array conforme quebra acima
			For nX := 1 To Len( aApuracao[ nPos ] )
				If ValType( aApuracao[ nPos , nX ] ) == 'U'	//Quando for NIL, quer dizer que acabei de adicionar no AADD acima, entao nao tenho como acumular o valor.
					If nX == 1 
						aApuracao[ nPos , nX ]	:=	cCFO
					Else
						aApuracao[ nPos , nX ]	:=	( cAlsTempDB )->( FieldGet( nX ) )
					EndIf

				ElseIf ValType( aApuracao[ nPos , nX ] ) == 'N'
					If !Empty(aApuracao[ nPos , 2]) .And. lQbAliq .And. nX == 2
						aApuracao[ nPos , nX ]	:=	( cAlsTempDB )->( FieldGet( nX ) )
						
					Else
						aApuracao[ nPos , nX ]	+=	( cAlsTempDB )->( FieldGet( nX ) )
					Endif
				EndIf
			Next nX
			aApuracao[ nPos , 124 ]	:=	"" // Posicao inutilizada
			DbSelectArea("SA1")
			DbSetOrder(1)
			//aApuracao[nPos,133]  := IIF(lProRurPf,IIF(SA1->(MsSeek(xFilial("SA1")+(cAliasSF3)->(F3_CLIEFOR+F3_LOJA))) .And. SA1->A1_PESSOA$"F",.F.,.T.),.T.)
			aApuracao[ nPos , 133]  := lProRurPj //lProRurPf AlteraÁ„o com base na solicitaÁ„o 261149 - Consultoria Tribut·ria Totvs
			( cAlsTempDB )->( dbSkip() )
		End
		( cAlsTempDB )->( dbCloseArea() )

		While !( c2AlsTempDB )->( Eof() )

			If nRegua>0
				If nRegua	==	1
					IncProc( OemToAnsi( STR0001 ) )	//"Executando apuraáÑo..."
				Else
					IncRegua()
				Endif
			Endif

			Do Case
			Case ( c2AlsTempDB )->CMP001 == '1'
				aAdd( aEntr , Array( 8 ) )
				nPos				:=	Len( aEntr ) 
				aEntr[ nPos , 1 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 2 ) ) )
				For nX := 2 To Len( aEntr[ nPos ] )
					aEntr[ nPos , nX ]	:=	( c2AlsTempDB )->( FieldGet( nX + 1 ) )
				Next nX

			Case	( c2AlsTempDB )->CMP001 == '2'
				aAdd( aSaid , Array( 5 ) )
				nPos				:=	Len( aSaid ) 
				aSaid[ nPos , 1 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 2 ) ) )
				For nX := 2 To Len( aSaid[ nPos ] )
					aSaid[ nPos , nX ]	:=	( c2AlsTempDB )->( FieldGet( nX + 1 ) )
				Next nX

			Case	( c2AlsTempDB )->CMP001 == '3'
				aAdd( aApurCDA , Array( 8 ) )
				nPos	:=	Len( aApurCDA )

				aApurCDA[ nPos , 1 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 10 ) ) )
				aApurCDA[ nPos , 2 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 11 ) ) )
				aApurCDA[ nPos , 3 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 12 ) ) )
				aApurCDA[ nPos , 4 ]	:=	( c2AlsTempDB )->( FieldGet( 9  ) )
				aApurCDA[ nPos , 5 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 13 ) ) )
				aApurCDA[ nPos , 6 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 14 ) ) )
				aApurCDA[ nPos , 7 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 18 ) ) )
				aApurCDA[ nPos , 8 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 16 ) ) ) 

			Case	( c2AlsTempDB )->CMP001 == '4'
				aAdd( aCDAST , Array( 12 ) )
				nPos	:=	Len( aCDAST )

				aCDAST[ nPos , 1 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 10 ) ) )
				aCDAST[ nPos , 2 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 11 ) ) )
				aCDAST[ nPos , 3 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 12 ) ) )
				aCDAST[ nPos , 4 ]	:=	( c2AlsTempDB )->( FieldGet( 9  ) )
				aCDAST[ nPos , 5 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 13 ) ) )
				aCDAST[ nPos , 6 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 14 ) ) )
				aCDAST[ nPos , 7 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 2 ) ) )
				aCDAST[ nPos , 8 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 16 ) ) )
				aCDAST[ nPos , 9 ]	:=	.F.
				aCDAST[ nPos , 10 ]	:=	Iif(( c2AlsTempDB )->( FieldGet( 3  ) ) == 1,.T.,.F.)
				aCDAST[ nPos , 11 ]	:=  AllTrim( ( c2AlsTempDB )->( FieldGet( 18 ) ) )
				aCDAST[ nPos , 12 ]	:=  AllTrim( ( c2AlsTempDB )->( FieldGet( 19 ) ) )			
				

			Case	( c2AlsTempDB )->CMP001 == '5'
				aAdd( aCDADE , Array( 12 ) )
				nPos	:=	Len( aCDADE )
			
				aCDADE[ nPos , 1 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 10 ) ) )
				aCDADE[ nPos , 2 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 11 ) ) )
				aCDADE[ nPos , 3 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 12 ) ) )
				aCDADE[ nPos , 4 ]	:=	( c2AlsTempDB )->( FieldGet( 9  ) )
				aCDADE[ nPos , 5 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 13 ) ) )
				aCDADE[ nPos , 6 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 14 ) ) )
				aCDADE[ nPos , 7 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 2 ) ) )
				aCDADE[ nPos , 8 ]	:=	.F.
				aCDADE[ nPos , 9 ]	:=	Iif(( c2AlsTempDB )->( FieldGet( 3  ) ) == 1, .T., .F.)
				aCDADE[ nPos , 10 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 16 ) ) )
				aCDADE[ nPos , 11 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 18 ) ) )				
				aCDADE[ nPos , 12 ]	:=  AllTrim( ( c2AlsTempDB )->( FieldGet( 19 ) ) )				

			Case	( c2AlsTempDB )->CMP001 == '6'
				aAdd( aCDAIC , Array( 12 ) )
				nPos	:=	Len( aCDAIC )

				aCDAIC[ nPos , 1 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 10 ) ) )
				aCDAIC[ nPos , 2 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 11 ) ) )
				aCDAIC[ nPos , 3 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 12 ) ) )
				aCDAIC[ nPos , 4 ]	:=	( c2AlsTempDB )->( FieldGet( 9  ) )
				aCDAIC[ nPos , 5 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 13 ) ) )
				aCDAIC[ nPos , 6 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 14 ) ) )
				aCDAIC[ nPos , 7 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 2  ) ) )
				aCDAIC[ nPos , 8 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 16 ) ) )
				aCDAIC[ nPos , 9 ]	:=	.F.
				aCDAIC[ nPos , 10 ]	:=	Iif(( c2AlsTempDB )->( FieldGet( 3  ) ) == 1, .T., .F.)
				aCDAIC[ nPos , 11 ]	:= AllTrim( ( c2AlsTempDB )->( FieldGet( 18 ) ) )	
				aCDAIC[ nPos , 12 ]	:= AllTrim( ( c2AlsTempDB )->( FieldGet( 19 ) ) )		
				

			Case	( c2AlsTempDB )->CMP001 == '7'
				aAdd( aRetEsp , Array( 3 ) )
				nPos	:=	Len( aRetEsp )

				aRetEsp[ nPos , 1 ]	:=	( c2AlsTempDB )->( FieldGet( 2 ) )
				aRetEsp[ nPos , 2 ]	:=	( c2AlsTempDB )->( FieldGet( 3 ) )
				aRetEsp[ nPos , 3 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 10 ) ) )

			Case	( c2AlsTempDB )->CMP001 == '8'
				aAdd( aApurMun , Array( 12 ) )
				nPos	:=	Len( aApurMun )
				aApurMun[ nPos , 1 ] := AllTrim( ( c2AlsTempDB )->( FieldGet( 2 ) ) )
				aApurMun[ nPos , 2 ] := AllTrim( ( c2AlsTempDB )->( FieldGet( 10 ) ) )
				aApurMun[ nPos , 3 ] := ( c2AlsTempDB )->( FieldGet( 3 ) )
				aApurMun[ nPos , 4 ] := ( c2AlsTempDB )->( FieldGet( 4 ) )
				aApurMun[ nPos , 5 ] := ( c2AlsTempDB )->( FieldGet( 5 ) )
				aApurMun[ nPos , 6 ] := ( c2AlsTempDB )->( FieldGet( 6 ) )
				aApurMun[ nPos , 7 ] := ( c2AlsTempDB )->( FieldGet( 7 ) )
				aApurMun[ nPos , 8 ] := ( c2AlsTempDB )->( FieldGet( 8 ) )
				aApurMun[ nPos , 9 ] := ( c2AlsTempDB )->( FieldGet( 9 ) )
				aApurMun[ nPos , 10 ] := ( c2AlsTempDB )->( FieldGet( 11 ) )
				aApurMun[ nPos , 11 ] := ( c2AlsTempDB )->( FieldGet( 17 ) )
				aApurMun[ nPos , 12 ] := ( c2AlsTempDB )->( FieldGet( 18 ) )
			Case	( c2AlsTempDB )->CMP001 == '9'
				aAdd( aIcmPago , Array( 8 ) )
				nPos := Len( aIcmPago )

				aIcmPago[ nPos , 1 ] := AllTrim( ( c2AlsTempDB )->( FieldGet( 10 ) ) )
				aIcmPago[ nPos , 2 ] := ( c2AlsTempDB )->( FieldGet( 03  ) )
				aIcmPago[ nPos , 3 ] := AllTrim( ( c2AlsTempDB )->( FieldGet( 11 ) ) )
				aIcmPago[ nPos , 4 ] := SToD( ( c2AlsTempDB )->( FieldGet( 12 ) ) )
				aIcmPago[ nPos , 5 ] := AllTrim( ( c2AlsTempDB )->( FieldGet( 13 ) ) )
				aIcmPago[ nPos , 6 ] := AllTrim( ( c2AlsTempDB )->( FieldGet( 14 ) ) )
				aIcmPago[ nPos , 7 ] := ( c2AlsTempDB )->( FieldGet( 15 ) )
				aIcmPago[ nPos , 8 ] := ( c2AlsTempDB )->( FieldGet( 16 ) )

			Case	( c2AlsTempDB )->CMP001 == 'A'
				aAdd( aNFsGiaRs , Array( 6 ) )
				nPos	:=	Len( aNFsGiaRs )

				aNFsGiaRs[ nPos , 1 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 02 ) ) )
				aNFsGiaRs[ nPos , 2 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 10 ) ) )
				aNFsGiaRs[ nPos , 3 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 11 ) ) )
				aNFsGiaRs[ nPos , 4 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 12 ) ) )
				aNFsGiaRs[ nPos , 5 ]	:=	( c2AlsTempDB )->( FieldGet( 03 ) )
				aNFsGiaRs[ nPos , 6 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 13 ) ) ) 

			Case	( c2AlsTempDB )->CMP001 == 'B'
				aAdd( aRecSTDif , Array( 3 ) )
				nPos	:=	Len( aRecStDif )

				aRecStDif[ nPos , 1 ]	:=	AllTrim(  Substr(( c2AlsTempDB )->( FieldGet( 02 ) ),1,2 ) )

				aRecStDif[ nPos , 2 ]	:=	AllTrim(  Substr(( c2AlsTempDB )->( FieldGet( 02 ) ),3,2) )
			
				aRecStDif[ nPos , 3 ]	:=	( c2AlsTempDB )->( FieldGet( 03 ) )
			
			Case	( c2AlsTempDB )->CMP001 == 'C'			
				aAdd( aMensIPI , Array( 4 ) )
				nPos	:=	Len( aMensIPI ) 
			
				aMensIPI[ nPos , 1 ]	:=	( c2AlsTempDB )->( FieldGet( 03 ) )
				
				aMensIPI[ nPos , 2 ]	:=	( c2AlsTempDB )->( FieldGet( 02 ) )			
				
				aMensIPI[ nPos , 3 ]	:=	( c2AlsTempDB )->( FieldGet( 04 ) )			

				aMensIPI[ nPos , 4 ]	:=	Alltrim(( c2AlsTempDB )->( FieldGet( 10 ) ))
	

			Case	( c2AlsTempDB )->CMP001 == 'D'
				aAdd( aDifal , Array( 7 ) )
				nPos	:=	Len( aDifal )

				aDifal[ nPos , 1 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 02 ) ) )

				aDifal[ nPos , 2 ]	:=	( c2AlsTempDB )->( FieldGet( 03 ) )

				aDifal[ nPos , 3 ]	:=	( c2AlsTempDB )->( FieldGet( 04 ) )

				aDifal[ nPos , 4 ]	:=	( c2AlsTempDB )->( FieldGet( 05 ) )

				aDifal[ nPos , 5 ]	:=	( c2AlsTempDB )->( FieldGet( 06 ) )

			Case	( c2AlsTempDB )->CMP001 == 'E'
		
				aAdd( aCdaDifal , Array( 17 ) )
				nPos	:=	Len( aCdaDifal )
		
				aCdaDifal[ nPos , 1 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 02 ) ) )

				aCdaDifal[ nPos , 2 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 10 ) ) )			

				aCdaDifal[ nPos , 3 ]	:=	( c2AlsTempDB )->( FieldGet( 03 ) )			

				aCdaDifal[ nPos , 4 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 11 ) ) )

				aCdaDifal[ nPos , 5 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 12 ) ) )

				aCdaDifal[ nPos , 6 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 13 ) ) )

				aCdaDifal[ nPos , 7 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 14 ) ) )
			
				aCdaDifal[ nPos , 8 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 18 ) ) )						
				
				aCdaDifal[ nPos , 9 ]	:=	Iif (( c2AlsTempDB )->( FieldGet( 04 ) )==1, .T., .F.)					

				aCdaDifal[ nPos , 10 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 16 ) ) )
				
				aCdaDifal[ nPos , 11 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 19 ) ) )
				
				aCdaDifal[ nPos , 12 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 20 ) ) )
				
				aCdaDifal[ nPos , 13 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 21 ) ) )

				aCdaDifal[ nPos , 14 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 22 ) ) )

				aCdaDifal[ nPos , 15 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 23 ) ) )

				aCdaDifal[ nPos , 16 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 24 ) ) )

				aCdaDifal[ nPos , 17 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 25 ) ) )
	
			Case	( c2AlsTempDB )->CMP001 == 'F'		
				
				aAdd( aApurCDV , Array( 6 ) )
				
				nPos	:=	Len( aApurCDV )		
				aApurCDV[ nPos , 1 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 02 ) ) )
				aApurCDV[ nPos , 2 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 10 ) ) )
				aApurCDV[ nPos , 3 ]	:=	Alltrim( ( c2AlsTempDB )->( FieldGet( 11 ) ) )			
				aApurCDV[ nPos , 4 ]	:=	( c2AlsTempDB )->( FieldGet( 9 ) ) 
				aApurCDV[ nPos , 5 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 13 ) ) )												
				aApurCDV[ nPos , 6 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 14 ) ) )


			Case	( c2AlsTempDB )->CMP001 == 'G'

				aAdd( aApurExtra , Array( 8 ) )
				nPos	:=	Len( aApurExtra )
		
				aApurExtra[ nPos , 1 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 02 ) ) )

				aApurExtra[ nPos , 2 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 10 ) ) )			

				aApurExtra[ nPos , 3 ]	:=	( c2AlsTempDB )->( FieldGet( 03 ) )			

				aApurExtra[ nPos , 4 ]	:=	( c2AlsTempDB )->( FieldGet( 04 ) )

				aApurExtra[ nPos , 5 ]	:=	( c2AlsTempDB )->( FieldGet( 05 ) )

				aApurExtra[ nPos , 6 ]	:=	( c2AlsTempDB )->( FieldGet( 06 ) )

				aApurExtra[ nPos , 7 ]	:=	( c2AlsTempDB )->( FieldGet( 07 ) )
			
				aApurExtra[ nPos , 8 ]	:=	{}
			
			Case	( c2AlsTempDB )->CMP001 == 'H'		

				aAdd( aCDAExtra , Array( 10 ) )
				nPos	:=	Len( aCDAExtra )
		
				aCDAExtra[ nPos , 1 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 02 ) ) )

				aCDAExtra[ nPos , 2 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 10 ) ) )			

				aCDAExtra[ nPos , 3 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 11 ) ) )						

				aCDAExtra[ nPos , 4 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 12 ) ) )

				aCDAExtra[ nPos , 5 ]	:=	( c2AlsTempDB )->( FieldGet( 03 ) )	

				aCDAExtra[ nPos , 6 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 13 ) ) )

				aCDAExtra[ nPos , 7 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 14 ) ) )
			
				aCDAExtra[ nPos , 8 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 16 ) ) )
				
				aCDAExtra[ nPos , 9 ]	:=	Iif(( c2AlsTempDB )->( FieldGet( 15 ) ) == 1, .T., .F.)
				
				aCDAExtra[ nPos , 10 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 18 ) ) )
			
			Case	( c2AlsTempDB )->CMP001 == 'I'
				
				aAdd( aCDAIPI , Array( 6 ) )
				
				nPos	:=	Len( aCDAIPI )		
				aCDAIPI[ nPos , 1 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 02 ) ) )
				aCDAIPI[ nPos , 2 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 10 ) ) )
				aCDAIPI[ nPos , 3 ]	:=	Alltrim( ( c2AlsTempDB )->( FieldGet( 11 ) ) )			
				aCDAIPI[ nPos , 4 ]	:=	( c2AlsTempDB )->( FieldGet( 9 ) ) 
				aCDAIPI[ nPos , 5 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 13 ) ) )
				aCDAIPI[ nPos , 6 ]	:=	AllTrim( ( c2AlsTempDB )->( FieldGet( 14 ) ) )
			
			Case	( c2AlsTempDB )->CMP001 == 'J' //#TODO Temporario thread
				
				Aadd(aNWCredAcu,Array(2))
				
				nPos := Len(aNWCredAcu)
				aNWCredAcu[nPos][1] := (c2AlsTempDB)->(FieldGet(10))
				aNWCredAcu[nPos][2] := (c2AlsTempDB)->(FieldGet(03))

			EndCase


			( c2AlsTempDB )->( dbSkip() )
		End
		( c2AlsTempDB )->( dbCloseArea() )
	EndIf	

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Sorteia a apuracao                                           ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If lQbAliq.and.!lQbCFO
		aApuracao	:=	Asort(aApuracao,,,{|x,y|x[2]<y[2]})
	Elseif lQbUfCfop
		aApuracao	:=	Asort(aApuracao,,,{|x,y|x[19]+x[1]<y[19]+y[1]})
	Else
		aApuracao	:=	Asort(aApuracao,,,{|x,y|x[1]+StrZero(100000000000000-x[11],15)<y[1]+StrZero(100000000000000-y[11],15)})
	Endif	

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Tratamento para retorno do arquivo temporario≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If lGeraArq

		If nRegua>0
			If nRegua	==	1
				ProcRegua( Len( aApuracao ) )
			Else
				SetRegua( Len( aApuracao ) )
			Endif
		Endif

		If cImp == "IC" .Or. cImp == "IP"
			aCampos	:=	{}
			If lQbPais .And. laPais
				aAdd( aCampos , { "CODPAIS" , "C" , 3 , 0 } )
			EndIf

			If lQbUF
				aTam := TAMSX3("F3_ESTADO")
				aAdd( aCampos , {"UF" , "C" , aTam[1] , aTam[2] } )

				aTam := TAMSX3( "F3_VALCONT" )
				aAdd( aCampos , { "VALCONC"  , "N" , aTam[1] , aTam[2] } )
				aAdd( aCampos , { "VALCONNC" , "N" , aTam[1] , aTam[2] } )

				aTam := TAMSX3( "F3_BASEICM" )
				aAdd( aCampos , { "BASEICC"  , "N" , aTam[1] , aTam[2] } )
				aAdd( aCampos , { "BASEICNC" , "N" , aTam[1] , aTam[2] } )
			EndIf

			If lQbUfCfop
				aTam := TAMSX3( "F3_ESTADO" )
				aAdd( aCampos , { "UF" , "C" , aTam[1] , aTam[2] } )
			Endif

			If lQbCfopUf
				aTam := TAMSX3("F3_ESTADO")
				aAdd( aCampos , { "UF"		 , "C" , aTam[1] , aTam[2] } )

				aTam := TAMSX3("F3_ALIQICM")
				aAdd( aCampos , { "ALIQICMS" , "N" , aTam[1] , aTam[2] } )
			Endif

			aTam := TAMSX3("F3_CFO")
			AADD(aCampos,{"CFOP"	,"C",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_VALCONT")
			AADD(aCampos,{"VALCONT"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_BASEICM")
			AADD(aCampos,{"BASEICM"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_VALICM")
			AADD(aCampos,{"VALICM"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_ISENICM")
			AADD(aCampos,{"ISENICM"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_OUTRICM")
			AADD(aCampos,{"OUTRICM"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_BASERET")
			AADD(aCampos,{"BASERET"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_ICMSRET")
			AADD(aCampos,{"ICMSRET"	,"N",aTam[1],aTam[2]})
			
			aTam := TAMSX3("F3_ICMSRET")
			AADD(aCampos,{"VlRETIC"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_TRFICM")
			AADD(aCampos,{"TRFICM"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_ICMSCOM")
			AADD(aCampos,{"ICMSCOM"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_VALIPI")
			AADD(aCampos,{"VALIPI"	,"N",aTam[1],aTam[2]})
			AADD(aCampos,{"VLIPIOBS"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_IPIOBS")
			AADD(aCampos,{"IPIOBS"	,"N",aTam[1],aTam[2]})
			
			aTam  	:= 	Iif(aApurSX3[FP_F3_ESTCRED], TAMSX3("F3_ESTCRED"), {16,2})
			AADD(aCampos,{"ESTCRED"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_ISSSUB")
			AADD(aCampos,{"ISSSUB"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_OUTRICM")
			AADD(aCampos,{"VLEXCLRS"	,"N",aTam[1],aTam[2]})

			aTam  	:= Iif(lF3BSICMOR, TAMSX3("F3_BSICMOR"), {16,2})
			AADD(aCampos,{"BSICMOR","N",aTam[1],aTam[2]})
			cArqTRB	:= CriaTrab( aCampos )
			dbUseArea( .T. , __LocalDriver , cArqTRB , cAliasTRB , .T. , .F. )

			If lQbUF
				IndRegua(cAliasTRB,cArqTRB,"UF+CFOP")

			ElseIf lQbPais .And. laPais
				IndRegua( cAliasTRB , cArqTRB , "CODPAIS+CFOP" )

			ElseIf lQbCfopUf
				IndRegua( cAliasTRB , cArqTRB , "CFOP+UF" )	

			ElseIf lQbUfCfop
				IndRegua( cAliasTRB , cArqTRB , "UF+CFOP" )

			Else
				IndRegua( cAliasTRB , cArqTRB , "CFOP" )
			EndIf

			If lGiaRs				
				aTam := TAMSX3( "F3_NFISCAL" )
				AADD( aCamposSF3 , { "NFISCAL" , "C" , aTam[ 1 ] , aTam[ 2 ] } )

				aTam := TAMSX3( "F3_SERIE" )
				AADD( aCamposSF3 , { "SERIE" , "C" , aTam[ 1 ] , aTam[ 2 ] } )

				aTam := TAMSX3( "F3_CLIEFOR" )
				AADD( aCamposSF3 , { "CLIEFOR" , "C" , aTam[ 1 ] , aTam[ 2 ] } )

				aTam := TAMSX3( "F3_LOJA" )
				AADD( aCamposSF3 , { "LOJA" , "C" , aTam[ 1 ] , aTam[ 2 ] } )

				aTam := TAMSX3( "F3_CRDPRES" )
				AADD( aCamposSF3 , { "CRDPRES" , "N" , aTam[ 1 ] , aTam[ 2 ] } )

				aTam := TAMSX3( "F3_CFO" )
				AADD( aCamposSF3 , { "CFOP" , "C" , aTam[ 1 ] , aTam[ 2 ] } )

				cArqTRBSF3 := CriaTrab( aCamposSF3 )
				dbUseArea( .T. , __LocalDriver , cArqTRBSF3 , cAliasNotas , .T. , .F. )

				IndRegua( cAliasNotas , cArqTRBSF3 , "NFISCAL+SERIE+CLIEFOR+LOJA" )

				For nPos := 1 To Len( aNFsGiaRs )
					RecLock( cAliasNotas , .T. )
					( cAliasNotas )->NFISCAL	:= aNFsGiaRs[ nPos , 1 ]
					( cAliasNotas )->SERIE		:= aNFsGiaRs[ nPos , 2 ]
					( cAliasNotas )->CLIEFOR	:= aNFsGiaRs[ nPos , 3 ]
					( cAliasNotas )->LOJA		:= aNFsGiaRs[ nPos , 4 ]
					( cAliasNotas )->CRDPRES	:= aNFsGiaRs[ nPos , 5 ]
					( cAliasNotas )->CFOP		:= aNFsGiaRs[ nPos , 6 ]
					( cAliasNotas )->( MsUnlock() )
				Next nPos
			EndIf

			dbSelectArea( cAliasTRB )
			dbClearIndex()
			dbSetIndex( cArqTRB + OrdBagExt() )

			nPos := 0
			dbSelectArea( cAliasTRB )
			For nPos := 1 To Len( aApuracao )

				If nRegua>0
					If nRegua	==	1
						IncProc( OemToAnsi( STR0001 ) ) //"Executando apuraáÑo..."
					Else
						IncRegua()
					Endif
				Endif

				Reclock( cAliasTRB , .T. )
				ISSSUB		:= aApuracao[ nPos , 29 ]
				If lQbUF
					UF		:= aApuracao[ nPos , 19 ]
					//Nao Contribuinte
					VALCONNC	:= aApuracao[ nPos , 25 ]
					BASEICNC	:= aApuracao[ nPos , 26 ]
					//Contribuinte
					VALCONC		:= aApuracao[ nPos , 27 ]
					BASEICC		:= aApuracao[ nPos , 28 ]
				EndIf

				If lQbPais .and. Len( aCodPais ) >= 1
					CODPAIS	:= aApuracao[ nPos , 20 ]
				EndIf

				If lQbCfopUf
					ALIQICMS	:= aApuracao[ nPos , 02 ]
					UF			:= aApuracao[ nPos , 19 ]
				Endif

				If lQbUfCfop
					UF			:= aApuracao[ nPos , 19 ]
				Endif

				CFOP			:= aApuracao[ nPos , 01 ]
				VALCONT			:= aApuracao[ nPos , 11 ]
				BASEICM			:= aApuracao[ nPos , 03 ]
				VALICM			:= aApuracao[ nPos , 04 ]
				ISENICM			:= aApuracao[ nPos , 05 ]
				OUTRICM			:= aApuracao[ nPos , 06 ]
				BASERET			:= aApuracao[ nPos , 07 ]
				ICMSRET			:= aApuracao[ nPos , 08 ]
				VLEXCLRS		:= aApuracao[ nPos , 123 ]
				BSICMOR		:=  aApuracao[ nPos , 137 ]
				VlRETIC		:= aApuracao[ nPos , 140 ]

				If Substr( Alltrim( aApuracao[ nPos , 01 ] ) , 1 , 3 ) == "000" .Or. Substr( Alltrim( aApuracao[ nPos , 01 ] ) , 1 , 4 ) $ "1601#1602#5601#5602"
					TRFICM	:= aApuracao[ nPos , 15 ]

				ElseIf Substr( Alltrim( aApuracao[ nPos , 01 ] ) , 1 , 3 ) == "999" .Or. Substr( Alltrim( aApuracao[ nPos , 01 ] ) , 1 , 4 ) $ "1605#5605"
					TRFICM	:= aApuracao[ nPos , 16 ]
				Else
					TRFICM	:= 	0
				Endif
				ICMSCOM		:= aApuracao[ nPos , 10 ]

				If cImp == "IC"
					VALIPI	:= aApuracao[ nPos , 24 ]
					IPIOBS	:= aApuracao[ nPos , 46 ]
					VLIPIOBS  := aApuracao[ nPos , 138 ]
				EndIf
				
				If Substr( Alltrim( aApuracao[ nPos , 01 ] ) , 1 , 1 ) $ "123"
					ESTCRED	:= aApuracao[ nPos , 47 ]
				Else
					ESTCRED	:= aApuracao[ nPos , 49 ]
				Endif	
				MsUnLock()
			
			Next nPos
		ElseIf cImp == "IS"
			aCampos	:= {}
			aTam := TAMSX3("F3_CODISS")
			AADD(aCampos,{"CODISS"	,"C",aTam[1],aTam[2]})

			aTam2 := TAMSX3("F3_ALIQICM")
			AADD(aCampos,{"ALIQISS"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_VALCONT")
			AADD(aCampos,{"VALCONT"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_BASEICM")
			AADD(aCampos,{"BASEISS"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_VALICM")
			AADD(aCampos,{"VALISS"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_ISENICM")
			AADD(aCampos,{"ISENISS"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_OUTRICM")
			AADD(aCampos,{"OUTRISS"	,"N",aTam[1],aTam[2]})

			aTam := TAMSX3("F3_ISSSUB")
			AADD(aCampos,{"ISSSUB"	,"N",aTam[1],aTam[2]})

			cArqTRB := CriaTrab( aCampos )
			dbUseArea( .T. , __LocalDriver , cArqTRB , cAliasTRB , .T. , .F. )
			IndRegua( cAliasTRB , cArqTRB , "CODISS+STR(ALIQISS," + ALLTRIM( STR( aTam2[ 1 ] ) ) + "," + ALLTRIM( STR( aTam2[ 2 ] ) ) + ")" )
			dbSelectArea( cAliasTRB )
			dbClearIndex()
			dbSetIndex( cArqTRB + OrdBagExt() )

			nPos := 0
			dbSelectArea( cAliasTRB )
			For nPos := 1 to Len( aApuracao )

				If nRegua>0
					If nRegua	==	1
						IncProc( OemToAnsi( STR0001 ) ) //"Executando apuraáÑo..."
					Else
						IncRegua()
					Endif
				Endif

				Reclock( cAliasTRB , .T. )
				CODISS		:= aApuracao[ nPos , 01 ]
				ALIQISS		:= aApuracao[ nPos , 02 ]
				VALCONT		:= aApuracao[ nPos , 11 ]
				BASEISS		:= aApuracao[ nPos , 03 ]
				VALISS		:= aApuracao[ nPos , 04 ]
				ISENISS		:= aApuracao[ nPos , 05 ]
				OUTRISS		:= aApuracao[ nPos , 06 ]
				MsUnLock()
			Next nPos
		EndIf
	EndIf
EndIf
RestArea( aArea )

If !lGeraArq .Or. nOpcApur == 1	//Tratamento para somente gerar arquivo quando estiver visualizando o que jah foi processado.
	Return( aApuracao )
Else
	If lGiaRs
		Return( { cArqTRB , cArqTRBSF3 } )
	Else
		Return( cArqTRB )
	EndIf
EndIf

//-------------------------------------------------------------------
/*/{Protheus.doc} DefThread
 
FunÁ„o que ir· fazer divis„o dos dias para cada Thread, considendo
perÌodo passado e n˙mero de Threads passada.   

@return array com data inicial e final que cada Thread dever· processar.
@author Rafael Oliveira
@since 22/07/2021
@version 11.80
/*/
//-------------------------------------------------------------------
Function DefThread(nThread,dtIni, dtFin)
Local nRestoDia		:= 0
Local nCont			:= 0
Local nDiasThread	:= 0
Local nDiaAux		:= 0
Local nTotDias		:= (dtFin - dtIni) + 1
Local dtI			:= dtIni			
Local dtF			:= dtIni
Local aPer			:= {}

	If nThread <= nTotDias  
		
		For nCont := 1 to nTotDias
			If mod(nTotDias,nThread) == 0
				//Divis„o exata
				nDiasThread	:= nTotDias/nThread
				exit		
			Else
				nRestoDia++
				nTotDias -=1					
			EndIF
		
		Next nCont
		
	Else
		//O N⁄MERO DE THREAD SER¡ O MESMO QUE A QUANTIDADE DE DIA.
		nThread := nTotDias
		nDiasThread	:= 1
	EndIF

	For nCont := 1 to nThread
		
		nDiaAux := 0
		If nRestoDia > 0
			nDiaAux := 1
			nRestoDia -= 1		
		EndIF
		dtI	:= dtI
		dtF	:= dtI + (nDiasThread-1) + nDiaAux	

		AADD(aPer,{dtI,dtF})
		dtI	:=  dtF + 1
		
	Next nCont

Return aPer

//-------------------------------------------------------------------
/*/{Protheus.doc} XApNmTDBR3
Funcao de processamento do movimento de escrituracao dos documentos fiscais de um determinado periodo.

@param	  	cImp  	- Imposto <"IC"MS|"IP"I|"IS"S>
		  	dDtIni	- Dt Inicio da Apuracao
	 	  	dDtFim	- Dt Final da Apuracao
	 	  	cNomeTDB - Flag de identificacao do nome da tabela

@return	String - String formada pela inicial da tabela definida pela variavel 'cNomeTDB', mais o tipo do imposto, 
						mais data inicial do periodo, mais data final do periodo, mais o codigo do grupo de empresa e mais o codigo da filial

@author Gustavo G. Rueda
@since 04/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XApNmTDBR3( cImp , dDtIni , dDtFim , cNomeTDB )
Local	cDataIni:=	StrZero( Day( dDtIni ) , 2 )
Local	cDataFim:=	StrZero( Day( dDtFim ) , 2 )

local cName := ""
local cMesI := ""
local cAnoI := ""
local cMesF := ""
local cAnoF := ""

Default	cNomeTDB	:=	'A'

cMesI := StrZero( Month( dDtIni ) , 2 )
cDataIni	+=	cMesI
cAnoI := Right( StrZero( Year( dDtIni ) , 4 ) , 2 )
cDataIni	+=	cAnoI

cMesF := StrZero( Month( dDtFim ) , 2 )
cDataFim	+=	cMesF
cAnoF := Right( StrZero( Year( dDtFim ) , 4 ) , 2 )
cDataFim	+=	cAnoF

cName := StrTran( cNomeTDB + cImp + cDataIni + cDataFim + FWGrpCompany() + '_' + FWCodFil() , ' ' , '_' )

// Devido ao retorno do codigo da empresa ou filial, concatenado com as outras informaÁıes, passarem de 27 caracteres.
if cDbType == "ORACLE" .and. len(cName) > 27

	// FunÁ„o AglutUFS (Fonte: dpigo.prw) passa como o periodo de um ano, assim dever· considerar o mes inicial e final.
	if cMesI == cMesF
		cName := StrTran( cNomeTDB + cImp + cMesF + cAnoF + FWGrpCompany() + '_' + FWCodFil() , ' ' , '_' )
	else
		cName := StrTran( cNomeTDB + cImp + cMesI + cMesF + cAnoF + FWGrpCompany() + '_' + FWCodFil() , ' ' , '_' )
	endif

endif

Return cName
//-------------------------------------------------------------------
/*/{Protheus.doc} XApRetIdx
Funcao responsavel por montar uma chave de indice do TEMPDB principal conforme parametros de processamento

@param	  	lQbUfCfop - Indica chave de UF + CFOP
			lQbAliq   - Indica chave de Aliquota
			lQbCFO    - Indica chave de cFOP
			lQbPais   - Indica chave por PAIS
			lQbUF     - Indica chave por UF
			lQbCfopUf - Indica chave por CFOP + UF
			aApuracao - Array com o conteudo a ser inserido no TEMPDB, no formato da tabela para que seja retornado a chave de pesquisa
			cAlias    - Alias do TEMPDB para montar a chave no formado do campo

@return	cRetorno  - String com os campos a serem considerados na formacao do indice ou a string a ser pesquisado no TEMPDB no momento da gravacao. 

@author Gustavo G. Rueda
@since 04/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function XApRetIdx( lQbUfCfop , lQbAliq , lQbCFO , lQbPais , lQbUF , lQbCfopUf , aApuracao , cAlias )
Local		cRetorno	:=	''

Default	aApuracao	:=	Nil
Default	cAlias		:=	Nil


//Definicao e criacao dos indices da tabela temporario no RDBMS
Do Case
	Case lQbUfCfop
		If aApuracao == Nil
			cRetorno	:=	'CMP019+CMP001'				//UF + CFOP
		Else		
			cRetorno	:=	( cAlias )->( PadR( aApuracao[ 19 ] , Len( CMP019 ) ) + PadR( aApuracao[ 1 ] , Len( CMP001 ) ) )
		EndIf	

	Case lQbAliq .and. lQbCFO .and. !lQbPais .And. !lQbUF
		If lQbCfopUf
			If aApuracao == Nil
				cRetorno	:=	'CMP001+CMP002+CMP019'	//CFOP + ALIQUOTA + UF
			Else		
				cRetorno	:=	( cAlias )->( PadR( aApuracao[ 1 ] , Len( CMP001 ) ) + Str( aApuracao[ 2 ] , 18 , 2 ) + PadR( aApuracao[ 19 ], Len( CMP019 ) ) )
			EndIf
		Else
			If aApuracao == Nil
				cRetorno	:=	'CMP001+CMP002'			//CFOP + ALIQUOTA
			Else
				cRetorno	:=	( cAlias )->( PadR( aApuracao[ 1 ] , Len( CMP001 ) ) + Str( aApuracao[ 2 ] , 18 , 2 ) )
			EndIf			
		Endif			
	
	Case !lQbAliq .And. lQbCFO .And. !lQbPais .And. !lQbUF
		If lQbCfopUf
			If aApuracao == Nil
				cRetorno	:=	'CMP001+CMP019'			//CFOP + UF
			Else
				cRetorno	:=	( cAlias )->( PadR( aApuracao[ 1 ] , Len( CMP001 ) ) + PadR( aApuracao[ 19 ] , Len( CMP019 ) ) )
			EndIf
		Else
			If aApuracao == Nil
				cRetorno	:=	'CMP019+CMP001'					//UF + CFOP
			Else
				cRetorno	:=	( cAlias )->( PadR( aApuracao[ 1 ] , Len( CMP001 ) ) )
			EndIf
		Endif
		
	Case (lQbAliq .And. !lQbCFO) .Or. ( !lQbAliq .And. !lQbCFO ) .And. !lQbPais .And. !lQbUF
		If lQbCfopUf
			If aApuracao == Nil
				cRetorno	:=	'CMP001+CMP002+CMP019'	//CFOP + ALIQUOTA + UF
			Else
				cRetorno	:=	( cAlias )->( PadR( aApuracao[ 1 ] , Len( CMP001 ) ) + Str( aApuracao[ 2 ] , 18 , 2 ) + PadR( aApuracao[ 19 ], Len( CMP019 ) ) )
			EndIf
		Else
			If aApuracao == Nil
				cRetorno	:=	'CMP001+CMP002'			//CFOP + ALIQUOTA
			Else
				cRetorno	:=	( cAlias )->( PadR( aApuracao[ 1 ] , Len( CMP001 ) ) + Str( aApuracao[ 2 ] , 18 , 2 ) )
			EndIf
		Endif
    			
	Case lQbUF .and. !lQbCFO .and.!lQbAliq .and. !lQbPais
		If aApuracao == Nil
			cRetorno	:=	'CMP019+CMP001'				//UF + CFOP
		Else
			cRetorno	:=	( cAlias )->( PadR( aApuracao[ 19 ] , Len( CMP019 ) ) + PadR( aApuracao[ 1 ] , Len( CMP001 ) ) )
		EndIf
		
	Case lQbUF .and. lQbCFO .and.!lQbAliq .and. !lQbPais
		If aApuracao == Nil
			cRetorno	:=	'CMP019+CMP001'				//UF + CFOP
		Else
			cRetorno	:=	( cAlias )->( PadR( aApuracao[ 19 ] , Len( CMP019 ) ) + PadR( aApuracao[ 1 ] , Len( CMP001 ) ) )
		EndIf
		
	Case lQbPais .and. !lQbCFO .and. !lQbAliq .And. !lQbUF
		If aApuracao == Nil
			cRetorno	:=	'CMP020+CMP001'				//PAIS + CFOP
		Else
			cRetorno	:=	( cAlias )->( PadR( aApuracao[ 20 ] , Len( CMP020 ) ) + PadR( aApuracao[ 1 ] , Len( CMP001 ) ) )
		EndIf								
EndCase
Return cRetorno
//-------------------------------------------------------------------
/*/{Protheus.doc} XApGetQry
Funcao responsavel por retornar a query a ser tratado no processamento da rotina, formatada por tipo de operacao e imposto

@param	  	cImp        - Tipo de imposto <IC, IS e IP>
			dDtIni      - Data inicial do periodo
			dDtFim      - Data final do periodo
			nDiasAcreDt - Dias a serem considerados no mes seguinte para documentos de transferencia de credito
			cNrLivro    - Numero do livro
			lF3Cnae     - Flag de existencia do campo F3_CNAE
			lF3CODRSEF  - Flag de existencia do campo F3_CODRSEF
			cCposQry    - Campos do SELECT a serem acrescentados na query
			cECmpF1F2   - Campos do F1 e F2 a serem tratado na query (UNION) nas situacoes de Entrada
			cSCmpF1F2   - Campos do F1 e F2 a serem tratado na query (UNION) nas situacoes de Saida
			cECmpD1D2   - Campos do D1 e D2 a serem tratado na query (UNION) nas situacoes de Entrada
			cSCmpD1D2   - Campos do D1 e D2 a serem tratado na query (UNION) nas situacoes de Saida
			cCmpSF4     - Campos da tabela SF4 a serem acrescentados na query
			cDtCanc     - Data de cancelamento para filtro
			aStruSF3	- Retorno da funÁ„o DbStruct na tabela SF3
			
@return	cRetorno  - String com a query montada e processada pelo changequery 

@author Gustavo G. Rueda
@since 04/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XApGetQry( cImp , dDtIni , dDtFim , nDiasAcreDt , cNrLivro , lF3Cnae , lF3CODRSEF , cCposQry , cECmpF1F2 , cSCmpF1F2 , cECmpD1D2 , cSCmpD1D2 , cCmpSF4 , cDtCanc, aStruSF3, cMvCODRSEF, cCredAcu )
Local	nX		:= 	0
Local	cQuery	:=	""
Local  lB1FECOP		:=	aApurSX3[FP_B1_FECOP]	
Local  lB1ALFECST	:=	aApurSX3[FP_B1_ALFECST]	
Local  lB1ALFECOP	:=	aApurSX3[FP_B1_ALFECOP]	
Local  lA1REGPB     :=  aApurSX3[FP_A1_REGPB]	
Local  cTipoDB	    := AllTrim(Upper(TcGetDb()))
Local  cSelect		:= ""
Local  cMV_ESTADO	:= AllTrim(SuperGetMv('MV_ESTADO'))

Default cCredAcu	:=	''

IF cimp=="IC" .or. cimp=="IP"
	cSelect  += " ( CASE WHEN (SELECT COUNT(CDA.CDA_CODLAN) FROM " + RetSQLName( "CDA" ) + " CDA WHERE CDA.CDA_FILIAL='"+ xFilial( "CDA" ) + "' AND CDA.CDA_TPMOVI = CASE WHEN SUBSTRING(SF3.F3_CFO,1,1)<'5' THEN 'E' ELSE 'S' END AND CDA.CDA_ESPECI = SF3.F3_ESPECIE  AND CDA.CDA_NUMERO = SF3.F3_NFISCAL AND CDA.CDA_SERIE = SF3.F3_SERIE AND CDA.CDA_CLIFOR = SF3.F3_CLIEFOR AND CDA.CDA_LOJA = SF3.F3_LOJA AND CDA.CDA_ORIGEM " + Iif(cimp=="IC"," <= '2'", " = '3'") + " AND CDA.D_E_L_E_T_ = ' ') > 0 THEN 1 ELSE 0 END ) COUNTCDA, "
Endif
If cImp == 'IC'
	//Query para o ICM para Documentos de Entrada
	cQuery	+=	"SELECT "
	cQuery	+=  "SF3."+StrTran( Alltrim(SF3->( SqlOrder( IndexKey() ) ) ),",",",SF3.")+","

	If !Empty(cCredAcu)
		cQuery	+=	'  SF3.F3_CREDACU, SF3.F3_EMISSAO, '
	EndIf

	// Tratamento para DB2: Utilizado SELECT "SF3.*" pois nas bases DB2 a ChangeQuery atribui
	// um alias para todos os campos automaticamente. Como o SELECT eh da SF3 inteira, a
	// string da query retornada acaba ficando muito grande (Maior que 15k) e ocorre erro
	// de execucao. A linha acima, que coloca no SELECT primeiro os campos do indice, foi
	// mantida por questoes de performance, mesmo que os campos fiquem repetidos depois.
	
	If cTipoDB == "DB2"
		cQuery += "SF3.*, "
	Else
		For nX := 1 To len(aStruSF3)
			If !(Alltrim(aStruSF3[nX][1]) $ Alltrim(SF3->(SqlOrder(IndexKey()))))
				cQuery += "SF3."+ Alltrim(aStruSF3[nX][1])+","
			EndIf
		Next nX
	EndIf
	
	cQuery	+=	cCposQry
	cQuery	+=	"SB1.B1_PRODREC, SB1.B1_POSIPI, SB1.B1_RICM65, "	
	IF lB1FECOP
		cQuery	+= "SB1.B1_FECOP,"	
	Endif
	IF lB1ALFECST
		cQuery	+= "SB1.B1_ALFECST,"	
	Endif
	IF lB1ALFECOP
		cQuery	+= "SB1.B1_ALFECOP,"	
	Endif
	IF 	lA1REGPB
	 	cQuery  += "SA1.A1_REGPB,"
	Endif	

	cQuery  += cSelect
	

	cQuery	+=	cECmpD1D2
	cQuery	+=	"SF4.F4_COMPL, SF4.F4_CONSUMO, SF4.F4_VARATAC, SF4.F4_ICM, SF4.F4_CREDICM, SF4.F4_LFICM, SF4.F4_OBSSOL, "
	cQuery	+=	cCmpSF4
	cQuery	+=	cECmpF1F2
	cQuery	+=	"FROM "
	cQuery	+=	RetSqlName( "SF3" ) + ' SF3 '
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SA1" ) + " SA1 ON(SA1.A1_FILIAL='" + xFilial( "SA1" ) + "' AND SA1.A1_COD=SF3.F3_CLIEFOR AND SA1.A1_LOJA=SF3.F3_LOJA AND SA1.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SA2" ) + " SA2 ON(SA2.A2_FILIAL='" + xFilial( "SA2" ) + "' AND SA2.A2_COD=SF3.F3_CLIEFOR AND SA2.A2_LOJA=SF3.F3_LOJA AND SA2.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SF1" ) + " SF1 ON(SF1.F1_FILIAL='" + xFilial( "SF1" ) + "' AND SF1.F1_FORNECE=SF3.F3_CLIEFOR AND SF1.F1_LOJA=SF3.F3_LOJA AND SF1.F1_DOC=SF3.F3_NFISCAL AND SF1.F1_SERIE=SF3.F3_SERIE AND SF1.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SFT" ) + " SFT ON(SFT.FT_FILIAL='" + xFilial( "SFT" ) + "' AND SFT.FT_TIPOMOV='E' AND SFT.FT_CLIEFOR=SF3.F3_CLIEFOR AND SFT.FT_LOJA=SF3.F3_LOJA AND SFT.FT_SERIE=SF3.F3_SERIE AND SFT.FT_NFISCAL=SF3.F3_NFISCAL AND SFT.FT_IDENTF3=SF3.F3_IDENTFT AND SFT.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SB1" ) + " SB1 ON(SB1.B1_FILIAL='" + xFilial( "SB1" ) + "' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SD1" ) + " SD1 ON(SD1.D1_FILIAL='" + xFilial( "SD1" ) + "' AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_COD=SFT.FT_PRODUTO AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SF4" ) + " SF4 ON(SF4.F4_FILIAL='" + xFilial( "SF4" ) + "' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_=' ') "	
	cQuery	+=	"WHERE "
	cQuery	+=	"SF3.F3_FILIAL = '" + xFilial( "SF3" ) + "' AND "
	cQuery	+=	"( ( SF3.F3_ENTRADA>='" + DToS( dDtIni ) + "' AND SF3.F3_ENTRADA<='" + DToS( dDtFim ) + "' AND "
	If cMV_ESTADO=='PR'
		cQuery 	+=	"SF3.F3_CFO NOT IN('1602','1605','5601','5602','5605') ) "
	Else
		cQuery 	+=	"SF3.F3_CFO NOT IN('1601','1602','1605','5601','5602','5605') ) "
	EndIf
	   	
	//Tratamento para pegar os documentos de transferencias de credito, emitidas no mes seguinte
	If Day( dDtFim ) > nDiasAcreDt    
		cQuery += 	" OR ( SF3.F3_ENTRADA>='" + DToS( dDtIni + nDiasAcreDt ) + "' AND SF3.F3_ENTRADA<='" + DToS( dDtFim + nDiasAcreDt ) + "' AND "
		If cMV_ESTADO=='PR'
			cQuery += 	"SF3.F3_CFO IN('1602','1605','5601','5602','5605') ) "
		Else
			cQuery += 	"SF3.F3_CFO IN('1601','1602','1605','5601','5602','5605') ) "
		EndIf
	EndIf
	cQuery += 	") AND "		

	cQuery	+=	"SF3.F3_DTCANC = '" + cDtCanc + "' AND "
	cQuery	+=	"SF3.F3_CFO < '5' AND "
	cQuery += 	"SF3.F3_CODISS='" + Space( TamSx3( 'F3_CODISS' )[ 1 ] ) + "' AND "
	If lF3Cnae
		cQuery += "(SF3.F3_CNAE='" + Space( TamSx3( 'F3_CNAE' )[ 1 ] ) + "' OR (SF3.F3_CNAE<>'" + Space( TamSx3( 'F3_CNAE' )[ 1 ] ) + "' AND SF3.F3_TIPO<>'S')) AND "
	Endif
	If lF3CODRSEF
		cQuery += "((SF3.F3_ESPECIE IN ('SPED','CTE','NFCE') AND SF3.F3_CODRSEF IN(" + cMvCODRSEF + ")) OR SF3.F3_ESPECIE NOT IN ('SPED','CTE','NFCE')) AND "	
	Endif
	If cNrLivro <> "*"
		cQuery += "SF3.F3_NRLIVRO = '" + cNrLivro + "' AND "       
	Endif
	
	cQuery += "SF3.D_E_L_E_T_=' ' "
		
	If !Empty(cCredAcu)
		cQuery += " AND SF3.F3_CREDACU IN(" + cCredAcu + ") "
	EndIf
		
	cQuery += "UNION "
	
	cQuery	+=	"SELECT "
	cQuery	+=  "SF3."+StrTran( Alltrim(SF3->( SqlOrder( IndexKey() ) ) ),",",",SF3.")+","

	If !Empty(cCredAcu)
		cQuery	+=	' SF3.F3_CREDACU, SF3.F3_EMISSAO, '
	EndIf

	// Tratamento para DB2: Verificar na query principal.	
	If cTipoDB == "DB2"
		cQuery += "SF3.*, "
	Else
		For nX := 1 To len(aStruSF3)
			If !(Alltrim(aStruSF3[nX][1]) $ Alltrim(SF3->(SqlOrder(IndexKey()))))
				cQuery += "SF3."+ Alltrim(aStruSF3[nX][1])+","
			EndIf
		Next nX
	EndIf

	cQuery	+=	cCposQry
	cQuery	+=	" SB1.B1_PRODREC, SB1.B1_POSIPI, SB1.B1_RICM65, "
	IF lB1FECOP
		cQuery	+= "SB1.B1_FECOP,"
	Endif
	IF lB1ALFECST
		cQuery	+= "SB1.B1_ALFECST,"	
	Endif
	IF lB1ALFECOP
		cQuery	+= "SB1.B1_ALFECOP,"	
	Endif
	IF 	lA1REGPB
	 	cQuery  += "SA1.A1_REGPB,"
	Endif
	
	cQuery  += cSelect

	cQuery	+=	cSCmpD1D2
	cQuery	+=	"SF4.F4_COMPL, SF4.F4_CONSUMO, SF4.F4_VARATAC, SF4.F4_ICM, SF4.F4_CREDICM, SF4.F4_LFICM, SF4.F4_OBSSOL, "
	cQuery	+=	cCmpSF4
	cQuery	+=	cSCmpF1F2
	cQuery	+=	"FROM "
	cQuery	+=	RetSqlName( "SF3" ) + " SF3 "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SA1" ) + " SA1 ON(SA1.A1_FILIAL='" + xFilial( "SA1" ) + "' AND SA1.A1_COD=SF3.F3_CLIEFOR AND SA1.A1_LOJA=SF3.F3_LOJA AND SA1.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SA2" ) + " SA2 ON(SA2.A2_FILIAL='" + xFilial( "SA2" ) + "' AND SA2.A2_COD=SF3.F3_CLIEFOR AND SA2.A2_LOJA=SF3.F3_LOJA AND SA2.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SF2" ) + " SF2 ON(SF2.F2_FILIAL='" + xFilial( "SF2" ) + "' AND SF2.F2_CLIENTE=SF3.F3_CLIEFOR AND SF2.F2_LOJA=SF3.F3_LOJA AND SF2.F2_DOC=SF3.F3_NFISCAL AND SF2.F2_SERIE=SF3.F3_SERIE AND SF2.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SFT" ) + " SFT ON(SFT.FT_FILIAL='" + xFilial( "SFT" ) + "' AND SFT.FT_TIPOMOV='S' AND SFT.FT_CLIEFOR=SF3.F3_CLIEFOR AND SFT.FT_LOJA=SF3.F3_LOJA AND SFT.FT_SERIE=SF3.F3_SERIE AND SFT.FT_NFISCAL=SF3.F3_NFISCAL AND SFT.FT_IDENTF3=SF3.F3_IDENTFT AND SFT.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SB1" ) + " SB1 ON(SB1.B1_FILIAL='" + xFilial( "SB1" ) + "' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SD2" ) + " SD2 ON(SD2.D2_FILIAL='" + xFilial( "SD2" ) + "' AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D2_ITEM=SFT.FT_ITEM AND SD2.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SF4" ) + " SF4 ON(SF4.F4_FILIAL='" + xFilial( "SF4" ) + "' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_=' ')		

	cQuery	+=	"WHERE "
	cQuery	+=	"SF3.F3_FILIAL = '" + xFilial( "SF3" ) + "' AND "
	
	cQuery	+=	"( ( SF3.F3_ENTRADA>='" + DToS( dDtIni ) + "' AND SF3.F3_ENTRADA<='" + DToS( dDtFim ) + "' AND "
	cQuery	+=	"SF3.F3_CFO NOT IN ('5601','5602','5605') ) "
	
	//Tratamento para pegar os documentos de transferencias de credito, emitidas no mes seguinte
	If Day( dDtFim ) > nDiasAcreDt
		cQuery +=	" OR ( SF3.F3_ENTRADA>='" + DToS( dDtIni + nDiasAcreDt ) + "' AND SF3.F3_ENTRADA<='" + DToS( dDtFim + nDiasAcreDt ) + "' AND "
		cQuery +=	"SF3.F3_CFO IN ('5601','5602','5605') ) "
	EndIf
	cQuery +=	") AND "
	
	cQuery	+=	"SF3.F3_DTCANC = '" + cDtCanc + "' AND "
	cQuery	+=	"SF3.F3_CFO > '5' AND "
	cQuery += 	"SF3.F3_CODISS='" + Space( TamSx3( 'F3_CODISS' )[ 1 ] ) + "' AND "
	
	If lF3Cnae
		cQuery += "(SF3.F3_CNAE='" + Space( TamSx3( 'F3_CNAE' )[ 1 ] ) + "' OR (SF3.F3_CNAE<>'" + Space( TamSx3( 'F3_CNAE' )[ 1 ] ) + "' AND SF3.F3_TIPO<>'S')) AND "
	Endif
	If lF3CODRSEF
		cQuery += "((SF3.F3_ESPECIE IN ('SPED','CTE','NFCE') AND SF3.F3_CODRSEF IN(" + cMvCODRSEF + ")) OR SF3.F3_ESPECIE NOT IN ('SPED','CTE','NFCE')) AND "
	Endif
	If cNrLivro <> "*"
		cQuery += "SF3.F3_NRLIVRO = '" + cNrLivro + "' AND "       
	Endif
		
	cQuery += "SF3.D_E_L_E_T_=' ' "
		
	If !Empty(cCredAcu)
		cQuery += " AND SF3.F3_CREDACU IN(" + cCredAcu + ") "
		cQuery += " ORDER BY 10,3, 4, 5, 6, 7, 9 " 

	Else
		cQuery += "ORDER BY 1,2,3,4,5,6,7,8"

	EndIf
ElseIf cImp == 'IS'

	cQuery	+=	"SELECT "
	cQuery	+=  "SF3."+StrTran( Alltrim(SF3->( SqlOrder( IndexKey() ) ) ),",",",SF3.")+","

	For nX := 1 To len(aStruSF3)
		If !(Alltrim(aStruSF3[nX][1]) $ Alltrim(SF3->(SqlOrder(IndexKey()))))
			cQuery += "SF3."+ Alltrim(aStruSF3[nX][1])+","
		EndIf
	Next nX
	
	cQuery	+=	cCposQry
	cQuery	+=	"SB1.B1_PRODREC, SB1.B1_POSIPI, SB1.B1_RICM65, "
	IF lB1FECOP
		cQuery	+= "SB1.B1_FECOP,"
	Endif
	IF lB1ALFECST
		cQuery	+= "SB1.B1_ALFECST,"	
	Endif
	IF lB1ALFECOP
		cQuery	+= "SB1.B1_ALFECOP,"	
	Endif
	IF 	lA1REGPB
	 	cQuery  += "SA1.A1_REGPB,"
	Endif		

	cQuery	+=	cSCmpD1D2
	cQuery	+=	"SF4.F4_COMPL, SF4.F4_CONSUMO, SF4.F4_VARATAC, SF4.F4_ICM, SF4.F4_CREDICM, SF4.F4_LFICM, SF4.F4_OBSSOL, "
	cQuery	+=	cCmpSF4
	cQuery	+=	cSCmpF1F2
	cQuery	+=	"FROM "
	cQuery	+=	RetSqlName( "SF3" ) + " SF3 "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SA1" ) + " SA1 ON(SA1.A1_FILIAL='" + xFilial( "SA1" ) + "' AND SA1.A1_COD=SF3.F3_CLIEFOR AND SA1.A1_LOJA=SF3.F3_LOJA AND SA1.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SA2" ) + " SA2 ON(SA2.A2_FILIAL='" + xFilial( "SA2" ) + "' AND SA2.A2_COD=SF3.F3_CLIEFOR AND SA2.A2_LOJA=SF3.F3_LOJA AND SA2.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SF2" ) + " SF2 ON(SF2.F2_FILIAL='" + xFilial( "SF2" ) + "' AND SF2.F2_CLIENTE=SF3.F3_CLIEFOR AND SF2.F2_LOJA=SF3.F3_LOJA AND SF2.F2_DOC=SF3.F3_NFISCAL AND SF2.F2_SERIE=SF3.F3_SERIE AND SF2.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SFT" ) + " SFT ON(SFT.FT_FILIAL='" + xFilial( "SFT" ) + "' AND SFT.FT_TIPOMOV='S' AND SFT.FT_CLIEFOR=SF3.F3_CLIEFOR AND SFT.FT_LOJA=SF3.F3_LOJA AND SFT.FT_SERIE=SF3.F3_SERIE AND SFT.FT_NFISCAL=SF3.F3_NFISCAL AND SFT.FT_IDENTF3=SF3.F3_IDENTFT AND SFT.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SB1" ) + " SB1 ON(SB1.B1_FILIAL='" + xFilial( "SB1" ) + "' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SD2" ) + " SD2 ON(SD2.D2_FILIAL='" + xFilial( "SD2" ) + "' AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D2_ITEM=SFT.FT_ITEM AND SD2.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SF4" ) + " SF4 ON(SF4.F4_FILIAL='" + xFilial( "SF4" ) + "' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_=' ')
	cQuery	+=	"WHERE "
	cQuery	+=	"SF3.F3_FILIAL = '" + xFilial( "SF3" ) + "' AND "
	cQuery	+=	"SF3.F3_ENTRADA>='" + DToS( dDtIni ) + "' AND "
	cQuery	+=	"SF3.F3_ENTRADA<='" + DToS( dDtFim ) + "' AND "
	If lF3Cnae
		cQuery += "( SF3.F3_CODISS<>'" + Space( TamSx3( 'F3_CODISS' )[ 1 ] ) + "' OR "
		cQuery += "SF3.F3_CNAE<>'" + Space( TamSx3( 'F3_CNAE' )[ 1 ] ) + "') AND "
	Else
		cQuery += "SF3.F3_CODISS<>'" + Space( TamSx3( 'F3_CODISS' )[ 1 ] ) + "' AND "
	Endif
	cQuery	+=	"SF3.F3_CFO > '5' AND "
	
	If cNrLivro <> "*"
		cQuery += "SF3.F3_NRLIVRO = '" + cNrLivro + "' AND "       
	Endif
	
	cQuery	+=	"SF3.F3_DTCANC = '" + cDtCanc + "' AND "	
	cQuery 	+= 	"SF3.D_E_L_E_T_=' ' "
		
	cQuery 	+= "ORDER BY 1,2,3,4,5,6,7,8"

Else

	cQuery	+=	"SELECT "
	cQuery	+=  "SF3."+StrTran( Alltrim(SF3->( SqlOrder( IndexKey() ) ) ),",",",SF3.")+","

	For nX := 1 To len(aStruSF3)
		If !(Alltrim(aStruSF3[nX][1]) $ Alltrim(SF3->(SqlOrder(IndexKey())))) .AND. Alltrim(aStruSF3[nX][2]) <> "M"
			cQuery += "SF3."+ Alltrim(aStruSF3[nX][1])+","
		EndIf
	Next nX

	cQuery	+=	cCposQry
	cQuery	+=	"SB1.B1_PRODREC, SB1.B1_POSIPI, SB1.B1_RICM65, "
	IF lB1FECOP
		cQuery	+= "SB1.B1_FECOP,"
	Endif
	IF lB1ALFECST
		cQuery	+= "SB1.B1_ALFECST,"	
	Endif
	IF lB1ALFECOP
		cQuery	+= "SB1.B1_ALFECOP,"	
	Endif
	IF 	lA1REGPB
	 	cQuery  += "SA1.A1_REGPB,"
	Endif	
	
	cQuery  += cSelect
	

	cQuery	+=	cECmpD1D2
	cQuery	+=	"SF4.F4_COMPL, SF4.F4_CONSUMO, SF4.F4_VARATAC, SF4.F4_ICM, SF4.F4_CREDICM, SF4.F4_LFICM, SF4.F4_OBSSOL, "
	cQuery	+=	cCmpSF4
	cQuery	+=	cECmpF1F2
	cQuery	+=	"FROM "
	cQuery	+=	RetSqlName( "SF3" ) + ' SF3 '
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SA1" ) + " SA1 ON(SA1.A1_FILIAL='" + xFilial( "SA1" ) + "' AND SA1.A1_COD=SF3.F3_CLIEFOR AND SA1.A1_LOJA=SF3.F3_LOJA AND SA1.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SA2" ) + " SA2 ON(SA2.A2_FILIAL='" + xFilial( "SA2" ) + "' AND SA2.A2_COD=SF3.F3_CLIEFOR AND SA2.A2_LOJA=SF3.F3_LOJA AND SA2.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SF1" ) + " SF1 ON(SF1.F1_FILIAL='" + xFilial( "SF1" ) + "' AND SF1.F1_FORNECE=SF3.F3_CLIEFOR AND SF1.F1_LOJA=SF3.F3_LOJA AND SF1.F1_DOC=SF3.F3_NFISCAL AND SF1.F1_SERIE=SF3.F3_SERIE AND SF1.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SFT" ) + " SFT ON(SFT.FT_FILIAL='" + xFilial( "SFT" ) + "' AND SFT.FT_TIPOMOV='E' AND SFT.FT_CLIEFOR=SF3.F3_CLIEFOR AND SFT.FT_LOJA=SF3.F3_LOJA AND SFT.FT_SERIE=SF3.F3_SERIE AND SFT.FT_NFISCAL=SF3.F3_NFISCAL AND SFT.FT_IDENTF3=SF3.F3_IDENTFT AND SFT.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SB1" ) + " SB1 ON(SB1.B1_FILIAL='" + xFilial( "SB1" ) + "' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SD1" ) + " SD1 ON(SD1.D1_FILIAL='" + xFilial( "SD1" ) + "' AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_COD=SFT.FT_PRODUTO AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SF4" ) + " SF4 ON(SF4.F4_FILIAL='" + xFilial( "SF4" ) + "' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_=' ') "
	cQuery	+=	"WHERE "
	cQuery	+=	"SF3.F3_FILIAL = '" + xFilial( "SF3" ) + "' AND "
	cQuery	+=	"SF3.F3_ENTRADA>='" + DToS( dDtIni ) + "' AND "
	cQuery 	+=	"SF3.F3_ENTRADA<='" + DToS( dDtFim ) + "' AND "
	cQuery	+=	"SF3.F3_CFO < '5' AND "	
	
	
	If lF3CODRSEF
		cQuery += "((SF3.F3_ESPECIE IN ('SPED','CTE','NFCE') AND SF3.F3_CODRSEF IN(" + cMvCODRSEF + ")) OR SF3.F3_ESPECIE NOT IN ('SPED','CTE','NFCE')) AND "	
	Endif
	
	If cNrLivro <> "*"
		cQuery += "SF3.F3_NRLIVRO = '" + cNrLivro + "' AND "       
	Endif
	
	cQuery	+=	"SF3.F3_DTCANC = '" + cDtCanc + "' AND "
	cQuery 	+= 	"SF3.D_E_L_E_T_=' ' "
		
	cQuery 	+= "UNION "
	
	cQuery	+=	"SELECT "
	cQuery	+=  "SF3."+StrTran( Alltrim(SF3->( SqlOrder( IndexKey() ) ) ),",",",SF3.")+","

	For nX := 1 To len(aStruSF3)
		If !(Alltrim(aStruSF3[nX][1]) $ Alltrim(SF3->(SqlOrder(IndexKey())))) .AND. Alltrim(aStruSF3[nX][2]) <> "M"
			cQuery += "SF3."+ Alltrim(aStruSF3[nX][1])+","
		EndIf
	Next nX
	
	cQuery	+=	cCposQry
	cQuery	+=	"SB1.B1_PRODREC, SB1.B1_POSIPI, SB1.B1_RICM65, "
	IF lB1FECOP
		cQuery	+= "SB1.B1_FECOP,"
	Endif
	IF lB1ALFECST
		cQuery	+= "SB1.B1_ALFECST,"	
	Endif
	IF lB1ALFECOP
		cQuery	+= "SB1.B1_ALFECOP,"	
	Endif	
	IF 	lA1REGPB
	 	cQuery  += "SA1.A1_REGPB,"
	Endif	
	
	cQuery  += cSelect

	cQuery	+=	cSCmpD1D2
	cQuery	+=	"SF4.F4_COMPL, SF4.F4_CONSUMO, SF4.F4_VARATAC, SF4.F4_ICM, SF4.F4_CREDICM, SF4.F4_LFICM, SF4.F4_OBSSOL, "
	cQuery	+=	cCmpSF4
	cQuery	+=	cSCmpF1F2
	cQuery	+=	"FROM "
	cQuery	+=	RetSqlName( "SF3" ) + " SF3 "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SA1" ) + " SA1 ON(SA1.A1_FILIAL='" + xFilial( "SA1" ) + "' AND SA1.A1_COD=SF3.F3_CLIEFOR AND SA1.A1_LOJA=SF3.F3_LOJA AND SA1.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SA2" ) + " SA2 ON(SA2.A2_FILIAL='" + xFilial( "SA2" ) + "' AND SA2.A2_COD=SF3.F3_CLIEFOR AND SA2.A2_LOJA=SF3.F3_LOJA AND SA2.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SF2" ) + " SF2 ON(SF2.F2_FILIAL='" + xFilial( "SF2" ) + "' AND SF2.F2_CLIENTE=SF3.F3_CLIEFOR AND SF2.F2_LOJA=SF3.F3_LOJA AND SF2.F2_DOC=SF3.F3_NFISCAL AND SF2.F2_SERIE=SF3.F3_SERIE AND SF2.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SFT" ) + " SFT ON(SFT.FT_FILIAL='" + xFilial( "SFT" ) + "' AND SFT.FT_TIPOMOV='S' AND SFT.FT_CLIEFOR=SF3.F3_CLIEFOR AND SFT.FT_LOJA=SF3.F3_LOJA AND SFT.FT_SERIE=SF3.F3_SERIE AND SFT.FT_NFISCAL=SF3.F3_NFISCAL AND SFT.FT_IDENTF3=SF3.F3_IDENTFT AND SFT.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SB1" ) + " SB1 ON(SB1.B1_FILIAL='" + xFilial( "SB1" ) + "' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SD2" ) + " SD2 ON(SD2.D2_FILIAL='" + xFilial( "SD2" ) + "' AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D2_ITEM=SFT.FT_ITEM AND SD2.D_E_L_E_T_=' ') "
	cQuery	+=	"LEFT JOIN " + RetSqlName( "SF4" ) + " SF4 ON(SF4.F4_FILIAL='" + xFilial( "SF4" ) + "' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_=' ')	
	cQuery	+=	"WHERE "
	cQuery	+=	"SF3.F3_FILIAL = '" + xFilial( "SF3" ) + "' AND "
	cQuery	+=	"SF3.F3_ENTRADA>='" + DToS( dDtIni ) + "' AND "
	cQuery 	+=	"SF3.F3_ENTRADA<='" + DToS( dDtFim ) + "' AND "
	cQuery	+=	"SF3.F3_CFO > '5' AND "	
	
	If lF3CODRSEF
		cQuery += "((SF3.F3_ESPECIE IN ('SPED','CTE','NFCE') AND SF3.F3_CODRSEF IN(" + cMvCODRSEF + ")) OR SF3.F3_ESPECIE NOT IN ('SPED','CTE','NFCE')) AND "	
	Endif
	
	If cNrLivro <> "*"
		cQuery += "SF3.F3_NRLIVRO = '" + cNrLivro + "' AND "       
	Endif
	
	cQuery	+=	"SF3.F3_DTCANC = '" + cDtCanc + "' AND "
	cQuery 	+= 	"SF3.D_E_L_E_T_=' ' "
		
	cQuery 	+= "ORDER BY 1,2,3,4,5,6,7,8"

EndIf
Return ChangeQuery( cQuery ) 
//-------------------------------------------------------------------
/*/{Protheus.doc} XApCrTempDB
Funcao responsavel por criar os temporarios do banco a serem alimentados pela rotina durante o processamento das threads

@param	  	cImp       - Tipo do imposto
			cTempDB    - Nome do TEMPDB PRINCIPAL a ser criado
			cAlsTempDB - Alias definido para o TEMPDB PRINCIPAL criado
			c2TempDB   - Nome do TEMPDB RESUMO a ser criado
			c2AlsTempDB- Alias definido para o TEMPDB RESUMO criado
			lQbUfCfop  - Indica chave de UF + CFOP
			lQbAliq    - Indica chave de Aliquota
			lQbCFO     - Indica chave de cFOP
			lQbPais    - Indica chave por PAIS
			lQbUF      - Indica chave por UF
			lQbCfopUf  - Indica chave por CFOP + UF

@return	Nil 

@author Gustavo G. Rueda
@since 04/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function XApCrTempDB( cImp , cTempDB , cAlsTempDB , c2TempDB , c2AlsTempDB , lQbUfCfop , lQbAliq , lQbCFO , lQbPais , lQbUF , lQbCfopUf )
Local	aTamTmpDB	:=	{}		
Local	aCampos		:=	{}
Local	nPos		:=	0
Local	nX			:=	0
Local	cIndice		:=	''

//------------------------------------------------------- PRINCIPAL -------------------------------------------------------
//Definindo estrutura do temporario principal no banco
For nX := 1 To LEN_ARRAY_APURACAO
	
	aTamTmpDB	:=	{}
	
	If ( nPos := aScan( ARRAY_POSICAO_CHAR , { | aX | aX[ 1 ] == nX } ) ) > 0

		If cImp == 'IS' .And. Len( ARRAY_POSICAO_CHAR[ nPos ] ) == 3 .And. ValType( ARRAY_POSICAO_CHAR[ nPos , 3 ] ) == 'C'		//Campo especifico para o ISS
			aTamTmpDB	:=	{ 'C' , TamSx3( ARRAY_POSICAO_CHAR[ nPos , 3 ] )[ 1 ] , 0 }			
		
		ElseIf ValType( ARRAY_POSICAO_CHAR[ nPos , 2 ] ) == 'C'
			aTamTmpDB	:=	{ 'C' , TamSx3( ARRAY_POSICAO_CHAR[ nPos , 2 ] )[ 1 ] , 0 }
		
		ElseIf ValType( ARRAY_POSICAO_CHAR[ nPos , 2 ] ) == 'N'
			aTamTmpDB	:=	{ 'C' , ARRAY_POSICAO_CHAR[ nPos , 2 ] , 0 }
		
		EndIf
		
	Else
		aTamTmpDB	:=	{ 'N' , 18 , 2 }	
	EndIf
	
	If Len( aTamTmpDB ) > 0							
		aAdd( aCampos , { "CMP" + StrZero( nX , 3 ) , aTamTmpDB[ 1 ] , aTamTmpDB[ 2 ] , aTamTmpDB[ 3 ] } )
	EndIf
Next nX
	
//Cria a tabela no RDBMS com a estrutura definida acima
dbCreate( cTempDB , aCampos , __cRdd )

dbUseArea( .T. ,__cRdd , cTempDB , cAlsTempDB , .T. , .F. )

//Funcao que define e retorna indices da tabela temporaria no RDBMS
cIndice	:=	XApRetIdx( lQbUfCfop , lQbAliq , lQbCFO , lQbPais , lQbUF , lQbCfopUf )
dbCreateIndex ( cTempDB + '_01' , cIndice )
( cAlsTempDB )->( dbCloseArea() )

//------------------------------------------------------- SECUNDARIO -------------------------------------------------------
//Definindo estrutura do temporario no banco de resumo para dos arrays aEntr, aSaid, aApurCDA, aCDAST, aCDADE, aCDAIC, aRetEsp, aApurMun, aIcmPago, aDifal, aCdaDifal, aApurCDV, aCDAIPI, aNWCredAcu // #vitor01 Arquivo secundario
aCampos	:=	{} 
aAdd( aCampos , { "CMP001" , 'C' , 001 , 0 } )	//ID do registro (1=aEntr, 2=aSaid, 3=aApurCDA, 4=aCDAST, 5=aCDADE, 6=aCDAIC, 7=aRetEsp, 8=aApurMun, 9=aIcmPago, A=aNFsGiaRs, B=aRecSTDif,C=aMensIPI, D=aDifal, E=aCdaDifal, F=aApurCDV,  G=aApurExtra, H=aCDAExtra, I=aCDAIPI, J=aNWCredAcu)
aAdd( aCampos , { "CMP002" , 'C' , 050 , 0 } )	//Chave - String - aEntr[1], aSaid[1], aRetEsp[1], aApurMun[1], aIcmPago[1]+aIcmPago[3]+aIcmPago[4], aNFsGiaRs[1], aRecSTDif[1]+aRecSTDif[2], aDifal[1], aCdaDifal[1], aApurExtra[1], (aCDAExtra[1] + aCDAExtra[2] + aCDAExtra[3] + aCDAExtra[6] + aCDAExtra[8] ), aApurCDV[1] , aCDAIPI[1]
aAdd( aCampos , { "CMP003" , 'N' , 018 , 2 } )	//Valor 01 - aEntr[2], aSaid[2], aRetEsp[2], aApurMun[3], aIcmPago[2], aNFsGiaRs[5], aRecSTDif[3], aDifal[2], aCdaDifal[3], aApurExtra[3], aCDAExtra[5], aCDAST[10], aCDAIC[10], aCDADE[9],aNWCredAcu[2]
aAdd( aCampos , { "CMP004" , 'N' , 018 , 2 } )	//Valor 02 - aEntr[3], aSaid[3], aApurMun[4], aIcmPago[7], aDifal[3], aApurExtra[4], aCdaDifal[9]
aAdd( aCampos , { "CMP005" , 'N' , 018 , 2 } )	//Valor 03 - aEntr[4], aSaid[4], aApurMun[5], aIcmPago[8], aDifal[4], aApurExtra[5]
aAdd( aCampos , { "CMP006" , 'N' , 018 , 2 } )	//Valor 04 - aEntr[5], aSaid[5], aApurMun[6], aDifal[5], aApurExtra[6]
aAdd( aCampos , { "CMP007" , 'N' , 018 , 2 } )	//Valor 05 - aEntr[6], aApurMun[7], aApurExtra[7]
aAdd( aCampos , { "CMP008" , 'N' , 018 , 2 } )	//Valor 06 - aEntr[7], aApurMun[8]
aAdd( aCampos , { "CMP009" , 'N' , 018 , 2 } )	//Valor 07 - aEntr[8], aApurCDA[4], aCDAST[4], aCDADE[4], aCDAIC[4], aApurMun[9], aApurCDV[4],aCDAIPI[4]
aAdd( aCampos , { "CMP010" , 'C' , 100 , 0 } )	//Char  08 - aApurCDA[1], aCDAST[1], aCDADE[1], aCDAIC[1], aIcmPago[1], aRetEsp[3], aNFsGiaRs[2], aApurMun[2], aCdaDifal[2], aApurExtra[2], aCDAExtra[2], aApurCDV[2], aCDAIPI[2],aNWCredAcu[1]
aAdd( aCampos , { "CMP011" , 'C' , 100 , 0 } )	//Char  09 - aApurCDA[2], aCDAST[2], aCDADE[2], aCDAIC[2], aIcmPago[3]:DataToString, aNFsGiaRs[3], aApurMun[10], aCdaDifal[4], aCDAExtra[3], aApurCDV[3], aCDAIPI[3]
aAdd( aCampos , { "CMP012" , 'C' , 100 , 0 } )	//Char  10 - aApurCDA[3], aCDAST[3], aCDADE[3], aCDAIC[3], aIcmPago[4], aNFsGiaRs[4], aCdaDifal[5], aCDAExtra[4]
aAdd( aCampos , { "CMP013" , 'C' , 100 , 0 } )	//Char  11 - aApurCDA[5], aCDAST[5], aCDADE[5], aCDAIC[5], aIcmPago[5], aNFsGiaRs[6], aCdaDifal[6],  aCDAExtra[6], aApurCDV[5],aCDAIPI[5]
aAdd( aCampos , { "CMP014" , 'C' , 100 , 0 } )	//Char  12 - aApurCDA[6], aCDAST[6], aCDADE[6], aCDAIC[6], aIcmPago[6],aCdaDifal[7], aCDAExtra[7], aApurCDV[6],aCDAIPI[6] 
aAdd( aCampos , { "CMP015" , 'N' , 100 , 0 } )	//Char  13 - aApurCDA[7], aCDAST[7], aCDADE[7], aCDAIC[7], aCDAExtra[9]
aAdd( aCampos , { "CMP016" , 'C' , 100 , 0 } )	//Char  14 - aApurCDA[8], aCDAST[8], aCDAIC[8], aCDAExtra[8], aCdaDifal[16], aCDADE[10]
aAdd( aCampos , { "CMP017" , 'N' , 018 , 2 } )	//Valor 15 - aApurMun[11]
aAdd( aCampos , { "CMP018" , 'C' , 100 , 0 } )	//Char  16 - aApurMun[12],aCdaDifal[8], aCDAExtra[10], aCDAST[11], aCDAIC[11], aCDADE[11]
aAdd( aCampos , { "CMP019" , 'C' , 100 , 0 } )	//Char  17 - aCdaDifal[11],aCDAST[12], aCDAIC[12], aCDADE[12]
aAdd( aCampos , { "CMP020" , 'C' , 100 , 0 } )	//Char  18 - aCdaDifal[12]
aAdd( aCampos , { "CMP021" , 'C' , 100 , 0 } )	//Char  19 - aCdaDifal[13]
aAdd( aCampos , { "CMP022" , 'C' , 100 , 0 } )	//Char  20 - aCdaDifal[14]
aAdd( aCampos , { "CMP023" , 'C' , 100 , 0 } )	//Char  21 - aCdaDifal[15]
aAdd( aCampos , { "CMP024" , 'C' , 100 , 0 } )	//Char  22 - aCdaDifal[16]
aAdd( aCampos , { "CMP025" , 'C' , 100 , 0 } )	//Char  23 - aCdaDifal[17]

//Cria a tabela no RDBMS com a estrutura definida acima
dbCreate( c2TempDB , aCampos , __cRdd )

dbUseArea( .T. ,__cRdd , c2TempDB , c2AlsTempDB , .T. , .F. )

//Funcao que define e retorna indices da tabela temporaria no RDBMS
cIndice	:=	'CMP001+CMP002+CMP010'
dbCreateIndex ( c2TempDB + '_01' , cIndice )

cIndice2 :=	'CMP001+CMP002+CMP018+CMP019' //indice para aCDAIC, aCDAST
dbCreateIndex ( c2TempDB + '_02' , cIndice2 )

cIndice3 := 'CMP001+CMP011+CMP016+CMP025' //indice para o aCDADIFAL
dbCreateIndex ( c2TempDB + '_03' , cIndice3 )

cIndice4 := 'CMP001+CMP002+CMP016+CMP019' //indice para o aCDADE
dbCreateIndex ( c2TempDB + '_04' , cIndice4 )

( c2AlsTempDB )->( dbCloseArea() )

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} XApDelTempDB
Funcao responsavel por deletar os temporarios do banco e exibir mensagem caso haja inconsistencia

@param	  	cTempDB - Nome do TEMPDB a ser excluido
			lMsg    - Flag para exibir mensagem. (.T.) Exibe, (.F.) Nao exibe (DEFAULT .T.)

@return	lRet    - (.T.) Conseguiu apagar, (.F.) Nao conseguiu apagar 

@author Gustavo G. Rueda
@since 04/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function XApDelTempDB( cTempDB , lMsg )
Local	lRet		:=	.T.
Local	lOk			:=	.T.
Local	cMsgTempDB	:=	''
Local	cMsgNotDel	:=	''

Default	lMsg	:=	.T.

//Verifico se a tabela existe no RDBMS	
If TcCanOpen( cTempDB )
	
	cMsgTempDB	:=	STR0123	//'A apuraÁ„o deste perÌodo para este tributo j· foi gerada em um outro momento, ' 
	cMsgTempDB	+=	STR0124	//'os valores j· est„o calculados conforme o movimento da ocasi„o. '
	cMsgTempDB	+=	STR0125 + CRLF + CRLF	//'Deseja realmente refazer a ApuraÁ„o ?'
	cMsgTempDB	+=	STR0126	//'Ao selecionar "N„o", as informaÁıes a serem apresentadas ser„o com base no movimento j· calculado!'	
	If lMsg	//Tratamento para tornar a mensagem opcional
		lOk	:=	MsgYesNo( cMsgTempDB , STR0127 )	//'AtenÁ„o'
	EndIf
	
	If lOk
		If !TcDelFile( cTempDB )		//Caso exista, apago do RDBMS
			cMsgNotDel	:=	STR0128 + ' ( ' + cTempDB + ' ).' + CRLF + CRLF	//'Problema ao excluir TEMPDB 
			cMsgNotDel	+=	TcSqlError() + CRLF + CRLF
			cMsgNotDel	+=	STR0129 + CRLF + CRLF	//'A tabela em quest„o est· presa por alguma thread de processamento pelo TOP CONNECT, entrar em contato com o Administrador do sistema.' 
			cMsgNotDel	+=	STR0130	//'As informaÁıes a serem apresentadas ser„o com base no movimento j· calculado!'
			ApMsgAlert( cMsgNotDel )
			
			lRet	:=	.F.			
		EndIf
	Else
		lRet	:=	.F.
	EndIf
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} XApTMPDBRes
Funcao responsavel por inserir os dados do movimento nos TEMPDBs criados.

@param		aApuracao  - Array com os valores da apuracao a serem gravados no tempdb		
			cAlsTempDB - Alias definido para o TEMPDB PRINCIPAL criado
			c2AlsTempDB- Alias definido para o TEMPDB RESUMO criado
			lQbUfCfop  - Indica chave de UF + CFOP
			lQbAliq    - Indica chave de Aliquota
			lQbCFO     - Indica chave de cFOP
			lQbPais    - Indica chave por PAIS
			lQbUF      - Indica chave por UF
			lQbCfopUf  - Indica chave por CFOP + UF	
			aEntr      - array com o resumo de ICMS Retido para entrada	 
			aSaid      - array com o resumo de ICMS Retido para saida
			aApurCDA   - Array para armazenar lancamentos da apuracao ICMS gravados no CDA
			aCDAST     - Array para armazenar lancamentos de ajustes da apuracao ICMS-ST gravados no CDA
			aCDADE     - Array contendo os lancamentos de debitos especiais
			aCDAIC     - Array para armazenar lancamentos de ajustes da apuracao ICMS gravados no CDA
			aRetEsp    - Array que me retorna o lancamento de documento fiscal que corresponde ao valor do ST-Debitado na entrada (_CREDST=3)
			aApurMun   - Array com os valores de ISS por municipio
			aIcmPago   - Array para armazenar valores de GNRE ja pagos na emissao do documento
			aNFsGiaRs  - Array com informacoes especificas da GIARS

@return	 

@author Gustavo G. Rueda
@since 04/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function XApTMPDBRes( aApuracao , cAlsTempDB , c2AlsTempDB , lQbUfCfop , lQbAliq , lQbCFO , lQbPais , lQbUF , lQbCfopUf ,;
								aEntr, aSaid, aApurCDA, aCDAST, aCDADE, aCDAIC, aRetEsp, aApurMun, aIcmPago , aNFsGiaRs, aRecStDif, cNThread, aMensIPI, aDifal ,aCDADifal,aCDAExtra,aApurExtra, aApurCDV,aCDAIPI,aNWCredAcu, c2TempDB)
								
Local	nPos			:=	0
Local	lLock			:=	.F.
Local	cSkTempDB		:=	''			
Local	lSeek 			:= .F.
Local	nLock			:=	0
Local	nX				:=	0

Default	aEntr		:=	{}
Default	aSaid		:=	{}
Default	aApurCDA	:=	{}
Default	aCDAST		:=	{}
Default	aCDADE		:=	{}
Default	aCDAIC		:=	{}
Default	aRetEsp	:=	{}
Default	aApurMun	:=	{}
Default	aIcmPago	:=	{}  
Default	aRecStDif	:=  {} 
Default	cNThread	:= ""
Default	aMensIPI	:= {}
Default	aDifal		:= {}
Default	aCDADifal	:= {}
Default aCDAExtra	:= {}
Default aApurExtra	:= {}
Default	aApurCDV	:=	{}
Default	aCDAIPI		:=	{}
Default	aNWCredAcu	:=	{}

//------------------------------------------------------- PRIMARIO -------------------------------------------------------
//Alimentando TEMPDB no RDBMS

	For nPos := 1 To Len( aApuracao )

		lLock		:=	.F.
		cSkTempDB	:=	XApRetIdx( lQbUfCfop , lQbAliq , lQbCFO , lQbPais , lQbUF , lQbCfopUf , aApuracao[ nPos ] , cAlsTempDB )			
		lSeek 		:= ( cAlsTempDB )->( MsSeek( cSkTempDB ) )
		 	
	 	For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
			If lSeek
				If ( lLock := ( cAlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
					RecLock( cAlsTempDB , .F. )
				EndIf
			Else
				lLock	:=	.T.
				RecLock( cAlsTempDB , .T. )
			EndIf
			If lLock									
				For nX := 1 To Len( aApuracao[ nPos ] )
				
					If aScan( ARRAY_POS_NAO_CUMULATIVAS , { | aX | aX == nX } ) > 0
						( cAlsTempDB )->( FieldPut( nX , aApuracao[ nPos , nX ] ) )
					Else				
						If ValType(aApuracao[ nPos , nX ]) == "N"			
							( cAlsTempDB )->( FieldPut( nX , (FieldGet( nX ) + aApuracao[ nPos , nX ]) ) )
						EndIf
					EndIf
				Next nX		
				( cAlsTempDB )->( dbCommit() , MsUnlockAll() )
				Exit
			
			Else
				Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
										//	exponencial a medida que for tentando.
			EndIf
		Next nLock
		
		//Mensagem caso nao consiga fazer lock do registro
		If !lLock
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + cAlsTempDB + ' ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'				
		EndIf
	Next nPos

( cAlsTempDB )->( dbCloseArea() )

//------------------------------------------------------- SECUNDARIO:aEntr -------------------------------------------------------
Begin Transaction

	For nPos := 1 To Len( aEntr )

		lLock		:=	.F.
		cSkTempDB	:=	'1' + PadR( aEntr[ nPos , 1 ] , Len( ( c2AlsTempDB )->CMP002 ) )			
		lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )
		 	
	 	For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
			If lSeek
				If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
					RecLock( c2AlsTempDB , .F. )
				EndIf
			Else
				lLock	:=	.T.
				RecLock( c2AlsTempDB , .T. )
			EndIf
			If lLock
				( c2AlsTempDB )->( FieldPut( 1 , Left( cSkTempDB , 1 ) ) )									
				( c2AlsTempDB )->( FieldPut( 2 , aEntr[ nPos , 1 ] ) )
				For nX := 2 To Len( aEntr[ nPos ] )
					( c2AlsTempDB )->( FieldPut( nX + 1 , FieldGet( nX + 1 ) + aEntr[ nPos , nX ] ) )
				Next nX		
				( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
				Exit
			
			Else
				Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
										//	exponencial a medida que for tentando.
			EndIf
		Next nLock

		//Mensagem caso nao consiga fazer lock do registro
		If !lLock
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aEntr ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
		EndIf
	Next nPos
	
End Transaction

//------------------------------------------------------- SECUNDARIO:aSaid -------------------------------------------------------
Begin Transaction

	For nPos := 1 To Len( aSaid )

		lLock		:=	.F.
		cSkTempDB	:=	'2' + PadR( aSaid[ nPos , 1 ] , Len( ( c2AlsTempDB )->CMP002 ) )			
		lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )
		 	
	 	For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
			If lSeek
				If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
					RecLock( c2AlsTempDB , .F. )
				EndIf
			Else
				lLock	:=	.T.
				RecLock( c2AlsTempDB , .T. )
			EndIf
			If lLock
				( c2AlsTempDB )->( FieldPut( 1 , Left( cSkTempDB , 1 ) ) )
				( c2AlsTempDB )->( FieldPut( 2 , aSaid[ nPos , 1 ] ) )									
				For nX := 2 To Len( aSaid[ nPos ] )
					( c2AlsTempDB )->( FieldPut( nX + 1 , FieldGet( nX + 1 ) + aSaid[ nPos , nX ] ) )
				Next nX		
				( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
				Exit
			
			Else
				Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
										//	exponencial a medida que for tentando.
			EndIf
		Next nLock

		//Mensagem caso nao consiga fazer lock do registro
		If !lLock
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aSaid ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
		EndIf
	Next nPos
	
End Transaction

//------------------------------------------------------- SECUNDARIO:aApurCDA -------------------------------------------------------
Begin Transaction

	For nPos := 1 To Len( aApurCDA )
		RecLock( c2AlsTempDB , .T. )
		( c2AlsTempDB )->( FieldPut( 1  , '3' ) )									
		( c2AlsTempDB )->( FieldPut( 10 , aApurCDA[ nPos , 1 ] ) )
		( c2AlsTempDB )->( FieldPut( 11 , aApurCDA[ nPos , 2 ] ) )
		( c2AlsTempDB )->( FieldPut( 12 , aApurCDA[ nPos , 3 ] ) )
		( c2AlsTempDB )->( FieldPut( 9  , FieldGet( 9 ) + aApurCDA[ nPos , 4 ] ) )
		( c2AlsTempDB )->( FieldPut( 13 , aApurCDA[ nPos , 5 ] ) )
		( c2AlsTempDB )->( FieldPut( 14 , aApurCDA[ nPos , 6 ] ) )
		( c2AlsTempDB )->( FieldPut( 18 , aApurCDA[ nPos , 7 ] ) )
		( c2AlsTempDB )->( FieldPut( 16 , aApurCDA[ nPos , 8 ] ) )
		( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
	Next nPos
	
End Transaction

//------------------------------------------------------- SECUNDARIO:aCDAST -------------------------------------------------------
If Len(aCDAST) > 0

	DbClearIndex()
	DbSetIndex(c2TempDB+'_02') //"CMP001+CMP002+CMP018+CMP019"

	Begin Transaction

		For nPos := 1 To Len( aCDAST )

			lLock		:=	.F.
			cSkTempDB	:=	'4' 
			cSkTempDB	+=	PadR( aCDAST[ nPos , 7  ],Len( ( c2AlsTempDB )->CMP002 ) )
			cSkTempDB	+=  PadR( aCDAST[ nPos , 11 ],Len( ( c2AlsTempDB )->CMP018 ) )
			cSkTempDB	+=  PadR( aCDAST[ nPos , 12 ],Len( ( c2AlsTempDB )->CMP019 ) )

			lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )
				
			For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
				If lSeek
					If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
						RecLock( c2AlsTempDB , .F. )
					EndIf
				Else
					lLock	:=	.T.
					RecLock( c2AlsTempDB , .T. )
				EndIf
				If lLock
					( c2AlsTempDB )->( FieldPut( 1 , Left( cSkTempDB , 1 ) ) )									
					( c2AlsTempDB )->( FieldPut( 10 , aCDAST[ nPos , 1 ] ) )
					( c2AlsTempDB )->( FieldPut( 11 , aCDAST[ nPos , 2 ] ) )
					( c2AlsTempDB )->( FieldPut( 12 , aCDAST[ nPos , 3 ] ) )
					( c2AlsTempDB )->( FieldPut( 9  , FieldGet( 9 ) + aCDAST[ nPos , 4 ] ) )
					( c2AlsTempDB )->( FieldPut( 13 , aCDAST[ nPos , 5 ] ) )
					( c2AlsTempDB )->( FieldPut( 14 , aCDAST[ nPos , 6 ] ) )
					( c2AlsTempDB )->( FieldPut( 2  , aCDAST[ nPos , 7 ] ) )
					( c2AlsTempDB )->( FieldPut( 16 , aCDAST[ nPos , 8 ] ) )
					( c2AlsTempDB )->( FieldPut( 3 ,  IIf(aCDAST[ nPos , 10 ], 1, 2) ) )
					( c2AlsTempDB )->( FieldPut( 18 , aCDAST[ nPos , 11 ] ) )
					( c2AlsTempDB )->( FieldPut( 19 , aCDAST[ nPos , 12 ] ) )
					( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
					Exit
				
				Else
					Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
											//	exponencial a medida que for tentando.
				EndIf
			Next nLock

			//Mensagem caso nao consiga fazer lock do registro
			If !lLock
				ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aCDAST ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )		//'Impossivel fazer lock do TEMPDB'###'Tentativas'		
			EndIf

		Next nPos
		
	End Transaction

	//Altera para indice 1	
	DbClearIndex()
	DbSetIndex(c2TempDB+'_01') //"CMP001+CMP002+CMP010"	
Endif

//------------------------------------------------------- SECUNDARIO:aCDADE -------------------------------------------------------
If Len(aCDADE) > 0
	
	DbClearIndex()
	DbSetIndex(c2TempDB+'_04') //"CMP001+CMP002+CMP016+CMP019"
		
		Begin Transaction
						
			For nPos := 1 To Len( aCDADE )
			
				lLock		:=	.F.
				cSkTempDB	:=	'5' 
				cSkTempDB	+= PadR( aCDADE[ nPos , 7  ],Len( ( c2AlsTempDB )->CMP002 ) )
				cSkTempDB	+= PadR( aCDADE[ nPos , 10 ],Len( ( c2AlsTempDB )->CMP016 ) )
				cSkTempDB	+= PadR( aCDADE[ nPos , 12 ],Len( ( c2AlsTempDB )->CMP019 ) )

				lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )
					
				For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
					If lSeek
						If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
							RecLock( c2AlsTempDB , .F. )
						EndIf
					Else
						lLock	:=	.T.
						RecLock( c2AlsTempDB , .T. )
					EndIf
					If lLock
						( c2AlsTempDB )->( FieldPut( 1  , Left( cSkTempDB , 1 ) ) )									
						( c2AlsTempDB )->( FieldPut( 10 , aCDADE[ nPos , 1 ] ) )
						( c2AlsTempDB )->( FieldPut( 11 , aCDADE[ nPos , 2 ] ) )
						( c2AlsTempDB )->( FieldPut( 12 , aCDADE[ nPos , 3 ] ) )
						( c2AlsTempDB )->( FieldPut( 9  , FieldGet( 9 ) + aCDADE[ nPos , 4 ] ) )
						( c2AlsTempDB )->( FieldPut( 13 , aCDADE[ nPos , 5 ] ) )
						( c2AlsTempDB )->( FieldPut( 14 , aCDADE[ nPos , 6 ] ) )
						( c2AlsTempDB )->( FieldPut( 2  , aCDADE[ nPos , 7 ] ) )
						( c2AlsTempDB )->( FieldPut( 3  , Iif( aCDADE[ nPos , 9 ] ,1 ,2) ) )
						( c2AlsTempDB )->( FieldPut( 16  , aCDADE[ nPos , 10 ] ) )
						( c2AlsTempDB )->( FieldPut( 18  , aCDADE[ nPos , 11 ] ) )	
						( c2AlsTempDB )->( FieldPut( 19 , aCDADE[ nPos , 12 ] ) )
						( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
						Exit
					
					Else
						Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
												//	exponencial a medida que for tentando.
					EndIf
				Next nLock

				//Mensagem caso nao consiga fazer lock do registro
				If !lLock
					ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aCDADE ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
				EndIf
				
			Next nPos
			
		End Transaction
		//Altera para indice 1	
		DbClearIndex()
		DbSetIndex(c2TempDB+'_01') //"CMP001+CMP002+CMP010"	
Endif
//------------------------------------------------------- SECUNDARIO:aCDAIC -------------------------------------------------------


	//Altera para indice 2
	If Len( aCDAIC ) > 0
		
		DbClearIndex()
		DbSetIndex(c2TempDB+'_02') //"CMP001+CMP002+CMP018+CMP019"	

		Begin Transaction
			For nPos := 1 To Len( aCDAIC )
				

				lLock		:=	.F.
				cSkTempDB	:=	'6'
				cSkTempDB	+=	PadR( aCDAIC[ nPos , 7  ],Len( ( c2AlsTempDB )->CMP002 ) ) 
				cSkTempDB	+=	PadR( aCDAIC[ nPos , 11 ],Len( ( c2AlsTempDB )->CMP018 ) ) 
				cSkTempDB	+=  PadR( aCDAIC[ nPos , 12 ],Len( ( c2AlsTempDB )->CMP019 ) )
				
				
				lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )
					
				For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
					If lSeek
						If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
							RecLock( c2AlsTempDB , .F. )
						EndIf
					Else
						lLock	:=	.T.
						RecLock( c2AlsTempDB , .T. )
					EndIf
					If lLock
						( c2AlsTempDB )->( FieldPut( 1  , Left( cSkTempDB , 1 ) ) )									
						( c2AlsTempDB )->( FieldPut( 10 , aCDAIC[ nPos , 1 ] ) )
						( c2AlsTempDB )->( FieldPut( 11 , aCDAIC[ nPos , 2 ] ) )
						( c2AlsTempDB )->( FieldPut( 12 , aCDAIC[ nPos , 3 ] ) )
						( c2AlsTempDB )->( FieldPut( 9  , FieldGet( 9 ) + aCDAIC[ nPos , 4 ] ) )
						( c2AlsTempDB )->( FieldPut( 13 , aCDAIC[ nPos , 5 ] ) )
						( c2AlsTempDB )->( FieldPut( 14 , aCDAIC[ nPos , 6 ] ) )
						( c2AlsTempDB )->( FieldPut( 2  , aCDAIC[ nPos , 7 ] ) )
						( c2AlsTempDB )->( FieldPut( 16 , aCDAIC[ nPos , 8 ] ) )
						( c2AlsTempDB )->( FieldPut( 3 , Iif(aCDAIC[ nPos , 10 ],1,2) ) )
						( c2AlsTempDB )->( FieldPut( 18 , aCDAIC[ nPos , 11 ] ) )
						( c2AlsTempDB )->( FieldPut( 19 , aCDAIC[ nPos , 12 ] ) )
						
						( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
						Exit
					
					Else
						Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
												//	exponencial a medida que for tentando.
					EndIf
				Next nLock

				//Mensagem caso nao consiga fazer lock do registro
				If !lLock
					ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aCDAIC ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
				EndIf
				
			Next nPos
		End Transaction
	
		//Altera para indice 2	
		DbClearIndex()
		DbSetIndex(c2TempDB+'_01') //"CMP001+CMP002+CMP010"	
	ENDIF



//------------------------------------------------------- SECUNDARIO:aRetEsp -------------------------------------------------------
Begin Transaction

	For nPos := 1 To Len( aRetEsp )
		RecLock( c2AlsTempDB , .T. )
		( c2AlsTempDB )->( FieldPut( 1  , '7' ) )									
		( c2AlsTempDB )->( FieldPut( 2  , aRetEsp[ nPos , 1 ] ) )
		( c2AlsTempDB )->( FieldPut( 3  , FieldGet( 3 ) + aRetEsp[ nPos , 2 ] ) )
		( c2AlsTempDB )->( FieldPut( 10 , aRetEsp[ nPos , 3 ] ) )
		( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
	Next nPos
	
End Transaction

//------------------------------------------------------- SECUNDARIO:aApurMun -------------------------------------------------------
Begin Transaction

	For nPos := 1 To Len( aApurMun )

		lLock		:=	.F.
		cSkTempDB	:=	'8' + PadR( aApurMun[ nPos , 1 ] , Len( ( c2AlsTempDB )->CMP002 ) )			
		lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )
		 	
	 	For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
			If lSeek
				If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
					RecLock( c2AlsTempDB , .F. )
				EndIf
			Else
				lLock	:=	.T.
				RecLock( c2AlsTempDB , .T. )
			EndIf
			If lLock
				
				( c2AlsTempDB )->( FieldPut( 1  , Left( cSkTempDB , 1 ) ) )									
				( c2AlsTempDB )->( FieldPut( 2  , aApurMun[ nPos, 1 ] ) )
				( c2AlsTempDB )->( FieldPut( 3  , FieldGet( 3 ) + aApurMun[ nPos , 3 ] ) )
				( c2AlsTempDB )->( FieldPut( 4  , FieldGet( 4 ) + aApurMun[ nPos , 4 ] ) )
				( c2AlsTempDB )->( FieldPut( 5  , FieldGet( 5 ) + aApurMun[ nPos , 5 ] ) )
				( c2AlsTempDB )->( FieldPut( 6  , FieldGet( 6 ) + aApurMun[ nPos , 6 ] ) )
				( c2AlsTempDB )->( FieldPut( 7  , FieldGet( 7 ) + aApurMun[ nPos , 7 ] ) )
				( c2AlsTempDB )->( FieldPut( 8  , FieldGet( 8 ) + aApurMun[ nPos , 8 ] ) )
				( c2AlsTempDB )->( FieldPut( 9  , FieldGet( 9 ) + aApurMun[ nPos , 9 ] ) )
				( c2AlsTempDB )->( FieldPut( 10 , aApurMun[ nPos, 2 ] ) )
				( c2AlsTempDB )->( FieldPut( 11 , aApurMun[ nPos, 10 ] ) )
				( c2AlsTempDB )->( FieldPut( 17 , FieldGet( 17 ) + aApurMun[ nPos , 11 ] ) )
				( c2AlsTempDB )->( FieldPut( 18 , aApurMun[ nPos , 12 ] ) )
				( c2AlsTempDB )->( dbCommit()   , MsUnlockAll() )
					
				Exit
			
			Else
				Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
										//	exponencial a medida que for tentando.
			EndIf
		Next nLock

		//Mensagem caso nao consiga fazer lock do registro
		If !lLock
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aApurMun ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
		EndIf	

	Next nPos
	
End Transaction

//------------------------------------------------------- SECUNDARIO:aIcmPago -------------------------------------------------------
Begin Transaction

	For nPos := 1 To Len( aIcmPago )
	
		lLock		:=	.F.
		cSkTempDB	:=	'9' + PadR( aIcmPago[ nPos , 1 ]+aIcmPago[ nPos , 3 ]+DToS( aIcmPago[ nPos , 4 ] ) , Len( ( c2AlsTempDB )->CMP002 ) )			
		lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )
		 	
	 	For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
			If lSeek
				If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
					RecLock( c2AlsTempDB , .F. )
				EndIf
			Else
				lLock	:=	.T.
				RecLock( c2AlsTempDB , .T. )
			EndIf
			If lLock
				( c2AlsTempDB )->( FieldPut( 1  , Left( cSkTempDB , 1 ) ) )									
				( c2AlsTempDB )->( FieldPut( 2  , aIcmPago[ nPos , 1 ]+aIcmPago[ nPos , 3 ]+DToS( aIcmPago[ nPos , 4 ] ) ) )
				( c2AlsTempDB )->( FieldPut( 3  , FieldGet( 3 ) + aIcmPago[ nPos , 2 ] ) )
				( c2AlsTempDB )->( FieldPut( 4 , aIcmPago[ nPos , 7 ] ) )
				( c2AlsTempDB )->( FieldPut( 5 , aIcmPago[ nPos , 8 ] ) )
				( c2AlsTempDB )->( FieldPut( 10 , aIcmPago[ nPos , 1 ] ) )
				( c2AlsTempDB )->( FieldPut( 11 , aIcmPago[ nPos , 3 ] ) )
				( c2AlsTempDB )->( FieldPut( 12 , DToS( aIcmPago[ nPos , 4 ] ) ) )
				( c2AlsTempDB )->( FieldPut( 13 , aIcmPago[ nPos , 5 ] ) )
				( c2AlsTempDB )->( FieldPut( 14 , aIcmPago[ nPos , 6 ] ) )				
				( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
				Exit
			
			Else
				Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
										//	exponencial a medida que for tentando.
			EndIf
		Next nLock

		//Mensagem caso nao consiga fazer lock do registro
		If !lLock
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aIcmPago ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
		EndIf

	Next nPos
	
End Transaction

//------------------------------------------------------- SECUNDARIO:aNFsGiaRs -------------------------------------------------------
Begin Transaction

	For nPos := 1 To Len( aNFsGiaRs )
	
		lLock		:=	.F.
		cSkTempDB	:=	'A' + PadR( aNFsGiaRs[ nPos , 1 ] , Len( ( c2AlsTempDB )->CMP002 ) )			
		lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )
		 	
	 	For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
			If lSeek
				If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
					RecLock( c2AlsTempDB , .F. )
				EndIf
			Else
				lLock	:=	.T.
				RecLock( c2AlsTempDB , .T. )
			EndIf
			If lLock
				( c2AlsTempDB )->( FieldPut( 1  , Left( cSkTempDB , 1 ) ) )									
				( c2AlsTempDB )->( FieldPut( 2  , aNFsGiaRs[ nPos , 1 ] ) )
				( c2AlsTempDB )->( FieldPut( 3  , FieldGet( 3 ) + aNFsGiaRs[ nPos , 5 ] ) )
				( c2AlsTempDB )->( FieldPut( 10 , aNFsGiaRs[ nPos , 2 ] ) )
				( c2AlsTempDB )->( FieldPut( 11 , aNFsGiaRs[ nPos , 3 ] ) )
				( c2AlsTempDB )->( FieldPut( 12 , aNFsGiaRs[ nPos , 4 ] ) )
				( c2AlsTempDB )->( FieldPut( 13 , aNFsGiaRs[ nPos , 6 ] ) )
				( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
				Exit
			
			Else
				Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
										//	exponencial a medida que for tentando.
			EndIf
		Next nLock

		//Mensagem caso nao consiga fazer lock do registro
		If !lLock
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aNFsGiaRs ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
		EndIf

	Next nPos
	
End Transaction     
//------------------------------------------------------- SECUNDARIO:aRecStDif -------------------------------------------------------

Begin Transaction

	For nPos := 1 To Len( aRecStDif )
	
		lLock		:=	.F.
		cSkTempDB	:=	'B' + PadR( aRecStDif[ nPos , 1 ]+aRecStDif[ nPos , 2 ] , Len( ( c2AlsTempDB )->CMP002 ) )
		lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )
		 	
	 	For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
			If lSeek
				If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
					RecLock( c2AlsTempDB , .F. )
				EndIf
			Else
				lLock	:=	.T.
				RecLock( c2AlsTempDB , .T. )
			EndIf
			If lLock
				( c2AlsTempDB )->( FieldPut( 1  , Left( cSkTempDB , 1 ) ) )									
				( c2AlsTempDB )->( FieldPut( 2  , aRecStDif[ nPos , 1 ] + aRecStDif[ nPos , 2 ] ) )
				( c2AlsTempDB )->( FieldPut( 3 , aRecStDif[ nPos , 3 ] ) )
				( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
				Exit			
			Else
				Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
										//	exponencial a medida que for tentando.
			EndIf
		Next nLock

		//Mensagem caso nao consiga fazer lock do registro
		If !lLock
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aRecStDif ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
		EndIf

	Next nPos    
	             
End Transaction
//aRecStDif

//------------------------------------------------------- SECUNDARIO:aMensIPI -------------------------------------------------------

Begin Transaction
	For nPos := 1 To Len( aMensIPI )
		lLock		:=	.F.
		cSkTempDB	:=	'C' + PadR( Alltrim(Str(aMensIPI[ nPos, 1])) + aMensIPI[ nPos, 2] + aMensIPI[ nPos, 4]  , Len( ( c2AlsTempDB )->CMP002 ) )
		lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )

	 	For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
			If lSeek
				If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
					RecLock( c2AlsTempDB , .F. )
				EndIf
			Else
				lLock	:=	.T.
				RecLock( c2AlsTempDB , .T. )
			EndIf
			If lLock
				( c2AlsTempDB )->( FieldPut( 1  , Left( cSkTempDB , 1 ) ) )									
				( c2AlsTempDB )->( FieldPut( 3  , aMensIPI[ nPos, 1 ] ) )
				( c2AlsTempDB )->( FieldPut( 2  , aMensIPI[ nPos, 2 ] ) )				
				( c2AlsTempDB )->( FieldPut( 4  , aMensIPI[ nPos, 3 ] ) )
				( c2AlsTempDB )->( FieldPut( 10 , aMensIPI[ nPos, 4 ] ) )
				( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
				Exit			
			Else
				Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
										//	exponencial a medida que for tentando.
			EndIf
		Next nLock
		//Mensagem caso nao consiga fazer lock do registro
		If !lLock
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aRecStDif ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
		EndIf

	Next nPos    
End Transaction    

//------------------------------------------------------- SECUNDARIO:aDifal -------------------------------------------------------
Begin Transaction
	For nPos := 1 To Len( aDifal )
		lLock		:=	.F.
		cSkTempDB	:=	'D' + PadR( Alltrim(aDifal[ nPos, 1]) , Len( ( c2AlsTempDB )->CMP002 ) )
		lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )

	 	For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
			If lSeek
				If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
					RecLock( c2AlsTempDB , .F. )
				EndIf
			Else
				lLock	:=	.T.
				RecLock( c2AlsTempDB , .T. )
			EndIf
			If lLock
				( c2AlsTempDB )->( FieldPut( 1 , Left( cSkTempDB , 1 ) ) )									
				( c2AlsTempDB )->( FieldPut( 2 , aDifal[ nPos, 1 ] ) )
				( c2AlsTempDB )->( FieldPut( 3 , FieldGet( 3 ) + aDifal[ nPos, 2 ] ) )				
				( c2AlsTempDB )->( FieldPut( 4 , FieldGet( 4 ) + aDifal[ nPos, 3 ] ) )
				( c2AlsTempDB )->( FieldPut( 5 , FieldGet( 5 ) + aDifal[ nPos, 4 ] ) )
				( c2AlsTempDB )->( FieldPut( 6 , FieldGet( 6 ) + aDifal[ nPos, 5 ] ) )
				( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
				Exit			
			Else
				Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
										//	exponencial a medida que for tentando.
			EndIf
		Next nLock
		//Mensagem caso nao consiga fazer lock do registro
		If !lLock
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aDifal ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
		EndIf

	Next nPos    
End Transaction

//------------------------------------------------------- SECUNDARIO:aCDADifal -------------------------------------------------------
If Len(aCdaDifal) > 0

	DbClearIndex()
	DbSetIndex(c2TempDB+'_03') //"CMP001+CMP011+CMP016+CMP025"

	Begin Transaction
		For nPos := 1 To Len( aCDADifal )
			lLock		:=	.F.
			cSkTempDB	:=	'E'
			cSkTempDB	+= PadR( aCDADifal[ nPos , 4 ],Len( ( c2AlsTempDB )->CMP011 ) )
			cSkTempDB	+= PadR( aCDADifal[ nPos , 10],Len( ( c2AlsTempDB )->CMP016 ) )
			cSkTempDB	+= PadR( aCDADifal[ nPos , 17],Len( ( c2AlsTempDB )->CMP025 ) )

			Sleep(Random(500,5000)) // Quando temos um volume baixo de Notas , as Thread est„o chegando ao mesmo tempo, com isso se perdendo o posicionamento.
			lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )

			For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
				If lSeek
					If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
						RecLock( c2AlsTempDB , .F. )
					EndIf
				Else
					lLock	:=	.T.
					RecLock( c2AlsTempDB , .T. )
				EndIf			
				
				If lLock
					( c2AlsTempDB )->( FieldPut( 1  , Left( cSkTempDB , 1 ) ) )									
					( c2AlsTempDB )->( FieldPut( 2  , aCDADifal[ nPos, 1 ] ) )
					( c2AlsTempDB )->( FieldPut( 10 , aCDADifal[ nPos, 2 ] ) )				
					( c2AlsTempDB )->( FieldPut( 3  , FieldGet( 3 ) + aCDADifal[ nPos, 3 ] ) )
					( c2AlsTempDB )->( FieldPut( 11 , aCDADifal[ nPos, 4 ] ) )
					( c2AlsTempDB )->( FieldPut( 12 , aCDADifal[ nPos, 5 ] ) )
					( c2AlsTempDB )->( FieldPut( 13 , aCDADifal[ nPos, 6 ] ) )
					( c2AlsTempDB )->( FieldPut( 14 , aCDADifal[ nPos, 7 ] ) )
					( c2AlsTempDB )->( FieldPut( 18 , aCDADifal[ nPos, 8 ] ) )
					( c2AlsTempDB )->( FieldPut( 4 , Iif(aCDADifal[ nPos, 9 ],1,2) ) )
					( c2AlsTempDB )->( FieldPut( 16 , aCDADifal[ nPos, 10 ] ) )
					( c2AlsTempDB )->( FieldPut( 19 , aCDADifal[ nPos, 11 ] ) )
					( c2AlsTempDB )->( FieldPut( 20 , aCDADifal[ nPos, 12 ] ) )
					( c2AlsTempDB )->( FieldPut( 21 , aCDADifal[ nPos, 13 ] ) )
					( c2AlsTempDB )->( FieldPut( 22 , aCDADifal[ nPos, 14 ] ) )
					( c2AlsTempDB )->( FieldPut( 23 , aCDADifal[ nPos, 15 ] ) )
					( c2AlsTempDB )->( FieldPut( 24 , aCDADifal[ nPos, 16 ] ) )
					( c2AlsTempDB )->( FieldPut( 25 , aCDADifal[ nPos, 17 ] ) )
					( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
					Exit			
				Else
					Sleep( 2500 * nLock)	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
											//	exponencial a medida que for tentando.
				EndIf
			Next nLock
			//Mensagem caso nao consiga fazer lock do registro
			If !lLock
				ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aCDADifal ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
			EndIf

		Next nPos    
	End Transaction

	//Altera para indice 1	
	DbClearIndex()
	DbSetIndex(c2TempDB+'_01') //"CMP001+CMP002+CMP010"

Endif
//------------------------------------------------------- SECUNDARIO:aApurCDV -------------------------------------------------------

Begin Transaction
	For nPos := 1 To Len( aApurCDV )
		lLock		:=	.F.
		cSkTempDB	:=	'F' + PadR( Alltrim(aApurCDV[ nPos, 1]+aApurCDV[ nPos, 2]) , Len( ( c2AlsTempDB )->CMP002 ) )
		lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )

	 	For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
			If lSeek
				If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
					RecLock( c2AlsTempDB , .F. )
				EndIf
			Else
				lLock	:=	.T.
				RecLock( c2AlsTempDB , .T. )
			EndIf			
			
			If lLock
				( c2AlsTempDB )->( FieldPut( 1  , Left( cSkTempDB , 1 ) ) )									
				( c2AlsTempDB )->( FieldPut( 2  , aApurCDV[ nPos, 1 ] ) )
				( c2AlsTempDB )->( FieldPut( 10 , aApurCDV[ nPos, 2 ] ) )				
				( c2AlsTempDB )->( FieldPut( 11  , aApurCDV[ nPos, 3 ] ) )
				( c2AlsTempDB )->( FieldPut( 9 , aApurCDV[ nPos, 4 ] ) )
				( c2AlsTempDB )->( FieldPut( 13 , aApurCDV[ nPos, 5 ] ) )
				( c2AlsTempDB )->( FieldPut( 14 , aApurCDV[ nPos, 6 ] ) )
				( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
				Exit			
			Else
				Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
										//	exponencial a medida que for tentando.
			EndIf
		Next nLock
		//Mensagem caso nao consiga fazer lock do registro
		If !lLock
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aApurCDV ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
		EndIf

	Next nPos    
End Transaction

//------------------------------------------------------- SECUNDARIO:aApurExtra -------------------------------------------------------

Begin Transaction
	For nPos := 1 To Len( aApurExtra )
		lLock		:=	.F.
		cSkTempDB	:=	'G' + PadR( Alltrim(aApurExtra[ nPos, 1]) , Len( ( c2AlsTempDB )->CMP002 ) )
		lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )

	 	For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
			If lSeek
				If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
					RecLock( c2AlsTempDB , .F. )
				EndIf
			Else
				lLock	:=	.T.
				RecLock( c2AlsTempDB , .T. )
			EndIf			
			
			If lLock
				( c2AlsTempDB )->( FieldPut( 1  , Left( cSkTempDB , 1 ) ) )									
				( c2AlsTempDB )->( FieldPut( 2  , aApurExtra[ nPos, 1 ] ) )
				( c2AlsTempDB )->( FieldPut( 10 , aApurExtra[ nPos, 2 ] ) )				
				( c2AlsTempDB )->( FieldPut( 3  , aApurExtra[ nPos, 3 ] ) )
				( c2AlsTempDB )->( FieldPut( 4  , aApurExtra[ nPos, 4 ] ) )
				( c2AlsTempDB )->( FieldPut( 5  , aApurExtra[ nPos, 5 ] ) )
				( c2AlsTempDB )->( FieldPut( 6  , aApurExtra[ nPos, 6 ] ) )
				( c2AlsTempDB )->( FieldPut( 7  , aApurExtra[ nPos, 7 ] ) )												
				( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
				Exit			
			Else
				Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
										//	exponencial a medida que for tentando.
			EndIf
		Next nLock
		//Mensagem caso nao consiga fazer lock do registro
		If !lLock
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aApurExtra ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
		EndIf

	Next nPos    
End Transaction

//------------------------------------------------------- SECUNDARIO:aCDAExtra -------------------------------------------------------


Begin Transaction
	For nPos := 1 To Len( aCDAExtra )
		lLock		:=	.F.
		cSkTempDB	:=	'H' + PadR( aCDAExtra[ nPos, 1] + aCDAExtra[ nPos, 2] + aCDAExtra[ nPos, 3] + aCDAExtra[ nPos, 6] + aCDAExtra[ nPos, 8]  , Len( ( c2AlsTempDB )->CMP002 ) )
		lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )

	 	For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
			If lSeek
				If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
					RecLock( c2AlsTempDB , .F. )
				EndIf
			Else
				lLock	:=	.T.
				RecLock( c2AlsTempDB , .T. )
			EndIf	
			
			If lLock
				( c2AlsTempDB )->( FieldPut( 1  , Left( cSkTempDB , 1 ) ) )									
				( c2AlsTempDB )->( FieldPut( 2  , aCDAExtra[ nPos, 1 ] ) )
				( c2AlsTempDB )->( FieldPut( 10 , aCDAExtra[ nPos, 2 ] ) )				
				( c2AlsTempDB )->( FieldPut( 11 , aCDAExtra[ nPos, 3 ] ) )
				( c2AlsTempDB )->( FieldPut( 12 , aCDAExtra[ nPos, 4 ] ) )
				( c2AlsTempDB )->( FieldPut( 3 , FieldGet( 3 ) + aCDAExtra[ nPos, 5 ] ) )
				( c2AlsTempDB )->( FieldPut( 13 , aCDAExtra[ nPos, 6 ] ) )
				( c2AlsTempDB )->( FieldPut( 14 , aCDAExtra[ nPos, 7 ] ) )
				( c2AlsTempDB )->( FieldPut( 16 , aCDAExtra[ nPos, 8 ] ) )
				( c2AlsTempDB )->( FieldPut( 15 , Iif(aCDAExtra[ nPos, 9 ], 1, 2) ) )
				( c2AlsTempDB )->( FieldPut( 18 , aCDAExtra[ nPos, 10 ] ) )
				( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
				Exit			
			Else
				Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
										//	exponencial a medida que for tentando.
			EndIf
		Next nLock
		//Mensagem caso nao consiga fazer lock do registro
		If !lLock
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aCDAExtra ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
		EndIf

	Next nPos    
End Transaction

//------------------------------------------------------- SECUNDARIO:aCDAIPI -------------------------------------------------------

Begin Transaction
	For nPos := 1 To Len( aCDAIPI )
		lLock		:=	.F.
		cSkTempDB	:=	'I' + PadR( Alltrim(aCDAIPI[ nPos, 1]+aCDAIPI[ nPos, 2]) , Len( ( c2AlsTempDB )->CMP002 ) )
		lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )

	 	For nLock := 1 To 5	//Tentativas de Lock no caso de concorrencia
			If lSeek
				If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) )	//Verifica se consegue fazer LOCK  
					RecLock( c2AlsTempDB , .F. )
				EndIf
			Else
				lLock	:=	.T.
				RecLock( c2AlsTempDB , .T. )
			EndIf			
			
			If lLock
				( c2AlsTempDB )->( FieldPut( 1  , Left( cSkTempDB , 1 ) ) )									
				( c2AlsTempDB )->( FieldPut( 2  , aCDAIPI[ nPos, 1 ] ) )
				( c2AlsTempDB )->( FieldPut( 10 , aCDAIPI[ nPos, 2 ] ) )				
				( c2AlsTempDB )->( FieldPut( 11  , aCDAIPI[ nPos, 3 ] ) )
				( c2AlsTempDB )->( FieldPut( 9 , aCDAIPI[ nPos, 4 ] ) )
				( c2AlsTempDB )->( FieldPut( 13 , aCDAIPI[ nPos, 5 ] ) )				
				( c2AlsTempDB )->( FieldPut( 14 , aCDAIPI[ nPos, 6 ] ) )
				( c2AlsTempDB )->( dbCommit() , MsUnlockAll() )
				Exit			
			Else
				Sleep( 2500 * nLock )	//Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo 
										//	exponencial a medida que for tentando.
			EndIf
		Next nLock
		//Mensagem caso nao consiga fazer lock do registro
		If !lLock
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aCDAIPI ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )	//'Impossivel fazer lock do TEMPDB'###'Tentativas'			
		EndIf

	Next nPos    
End Transaction

//------------------------------------------------------- SECUNDARIO:aNWCredAcu ------------------------------------------------------- 

Begin Transaction
	For nPos := 1 To Len(aNWCredAcu)
		lLock		:=	.F.
		cSkTempDB	:=	'J'+ PadR( "CAC" , Len( ( c2AlsTempDB )->CMP002 ) ) //#TODO SECUNDARIO:aNWCredAcu
		lSeek 		:= ( c2AlsTempDB )->( MsSeek( cSkTempDB ) )

		For nLock := 1 To 5 //Tentativas de Lock no caso de concorrencia
			If lSeek
				If ( lLock := ( c2AlsTempDB )->( SimpleLock() ) ) //Verifica se consegue fazer LOCK
					RecLock( c2AlsTempDB , .F. )
				EndIf
			Else
				lLock	:=	.T.
				RecLock( c2AlsTempDB , .T. )
			EndIf

			If lLock
				(c2AlsTempDB)->(FieldPut(01,Left(cSkTempDB,1)))
				(c2AlsTempDB)->(FieldPut(02,"CAC"))
				(c2AlsTempDB)->(FieldPut(03,aNWCredAcu[nPos][2]))
				(c2AlsTempDB)->(FieldPut(10,aNWCredAcu[nPos][1]))
				(c2AlsTempDB)->(DbCommit(),MsUnlockAll())
				Exit
			Else
				/*
					Se nao conseguir fazer LOCK, aguarda um 2,5 segundos e tento de novo, esse tempo vai sendo exponencial a medida que for tentando.
				*/
				Sleep(2500 * nLock)
			EndIf
		Next nLock

		// Mensagem caso nao consiga fazer lock do registro
		If !lLock
			// 'Impossivel fazer lock do TEMPDB'###'Tentativas'
			ConOut( DToS( Date() ) + ' ' + Time() + ' -> FISXAPURA.PRW: ' + STR0131 + ' (' + c2AlsTempDB + ':aNWCredAcu ), ' + STR0132 + ': ' + AllTrim( Str( nLock , 1 ) ) + ' - Thread: ' + cNThread )
		EndIf
	Next nPos
End Transaction


( c2AlsTempDB )->( dbCloseArea() )

Return
/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ ResF3 ≥ Autor ≥ Juan Jose Pereira          ≥ Data ≥ 29/03/96 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Le SF3 gerando array com apuracao de imposto para periodo  ≥±±
±±≥          ≥ escolhido                                                  ≥±± 
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ Generico                                                   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function XApurRF3(cImp		,; 	// 1 - Imposto <"IC"MS|"IP"I|"IS"S>
		  dDtIni	,; 	// 2 - Dt Inicio da Apuracao
	 	  dDtFim	,; 	// 3 - Dt Final da Apuracao
		  cNrLivro	,;	// 4 - Numero do Livro
	 	  lQbAliq	,;	// 5 - Quebra por Aliquota
		  lQbCFO	,;	// 6 - Quebra por CFO
		  nRegua	,;	// 7 - 0=Nao Exibe 1=Processamento 2=Relatorio
		  lEnd		,;	// 8 - Flag de InterrupáÑo
		  nConsFil	,;	// 9 - Considera filial
		  cFilDe	,;	// 10 - Filial De
		  cFilAte	,;	// 11 - Filial ate
		  aEntr		,;	// 12 - array com o resumo de ICMS Retido para entrada	 
		  aSaid		,;  // 13 - array com o resumo de ICMS Retido para saida
		  cFilUsr	,;	// 14 - 
		  lGeraArq	,;	// 15 - Gera Arquivo de Trabalho
		  cAliasTRB ,;	// 16 - 
		  lQbUF		,; 	// 17 - Quebra por UF	
		  lQbPais	,;	// 18 - Quebra por CÛdigo do Pais	
		  lQbCfopUf	,;	// 19 - Quebra por CFOP+UF e por "Aliquota" caso necessite, mas somente se "lQbUF" e "lQbPais" forem .F.
		  lImpCrdSt ,;	// 20 - 
		  lMv_UFSt  ,;	// 21 - 
		  lCrdEst   ,;	// 22 - 
		  aEstimulo ,;	// 23 - 
  		  lQbUfCfop ,;	// 24 - Quebra por UF+CFOP
  		  lConsUF	,;	// 25 - Indica se, quando a apuracao for consolidada, apenas as filiais estabelecidas no mesmo estado do consolidador sejam processadas
  		  aApurCDA	,;	// 26 - Array para armazenar lancamentos da apuracao ICMS gravados no CDA
  		  aApurF3	,;	// 27 - Array para armazenar lancamentos da apuracao ICMS gravados no SF3
  		  aCDAIC	,;	// 28 - Array para armazenar lancamentos de ajustes da apuracao ICMS gravados no CDA
  		  aCDAST	,;	// 29 - Array para armazenar lancamentos de ajustes da apuracao ICMS-ST gravados no CDA
  		  cChamOrig ,; 	// 30 - Funcao que esta chamando
  		  nParPerg	,;	// 31 - Parametro da pergunta
  		  aFilsCalc	,;	// 32 - Array das Filiais Selecionadas
  		  aApurMun  ,;	// 33 - Array com os valores de ISS por municipio
		  lICMDes   ,;	// 34 - Indica se havera calculo Credito ICMS Relat. Art.271 RICMS/SP		   
		  aIcmPago  ,;	// 35 - Array para armazenar valores de GNRE ja pagos na emissao do documento
		  lICMGar,;   	// 36 - Indica se havera calculo Credito ICMS Garantido Relat. Art.435-N RICMS/MT
		  aCDADE,;		// 37 - Array contendo os lancamentos de debitos especiais
		  aRetEsp,;		// 38 - Array que me retorna o lancamento de documento fiscal que corresponde ao valor do ST-Debitado na entrada (_CREDST=3)
		  lGiaRs,;		// 39 - Identifica se o arquivo de geracao eh o GIARS
		  nCredMT,;     // 40 - Indica se calculo Credito Presumido MT
		  aConv139,;	// 41 - Array com informaÁıes e valores do convenio 139/06
		  aRecStDif,;
		  aMensIPI,;
		  aDifal,;
		  aCDADifal,;
		  aCDAExtra,;
		  aApurExtra,;		  
		  aApurCDV,;
		  aCDAIPI,;
		  aNWCredAcu,;
		  lProcRefer,;
		  cTempDeb,; 
		  cTempCrd,; 
		  cTempSTd,; 
		  cTempSTe,;
		  cTempIPIs,;
		  cTempIPIe )
     
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Define variaveis                                             ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Local cMvEstado  := AllTrim(SuperGetMv("MV_ESTADO"))
LOCAL aApuracao	:=	{}
LOCAL aArea     := GetArea() 
LOCAL nPos		:= 0
LOCAL nAliq		:= 0
LOCAL cCFO      := ""
LOCAL dDtAnt
LOCAL cMsg      := ""
LOCAL nRegEmp 	:= SM0->(RecNo())
LOCAL lQuery 	:= .F.
LOCAL cAliasSF3 := "SF3"
Local cIndSF3	:= ""
Local cChave	:= ""
Local cFiltro	:= ""
Local lApuricm  := aExistBloc[PE_APURICM]
Local nX		:= 0
Local aCampos	:= {}
Local aTam		:= {}
Local aTam2		:= {}
Local cArqTRB 	:= ""
Local cMV_StUf	:=	SuperGetMV("MV_STUF")	// Define os estados a serem utilizados para o artigo 281
Local cMV_StUfS	:=	SuperGetMV("MV_STUFS")	// Define os estados a serem utilizados para o artigo 281 - para as saidas
Local cMV_SubTr	:=	IIf(aFindFunc[FF_GETSUBTRIB], GetSubTrib(), SuperGetMv("MV_SUBTRIB"))
Local cMV_DifTr	:=	IIf(aFindFunc[FF_GETSUBTRIB], GetSubTrib("",.T.), SuperGetMv("MV_SUBTRIB")) // Pega IE de Difal
Local lChkGnre	:= (aIcmPago <> NIL)
Local cCodPais	:= ""
Local aCodPais	:= {}
Local nNum		:=	0
Local lUsaCfps	:= SuperGetMV("MV_USACFPS")
Local lUfRj		:= cMvEstado=='RJ'
Local lUfBA		:= cMvEstado=='BA'
Local lUfRN		:= cMvEstado=='RN'
Local lUfMG		:= cMvEstado=='MG'
Local lUfMT		:= cMvEstado=='MT'
Local lUfSE		:= cMvEstado=='SE'
Local lFTDS43080 := aApurSX3[FP_FT_DS43080]
Local lFTPR43080 := aApurSX3[FP_FT_PR43080]
Local aUFFecp    :={'AL', 'CE', 'DF', 'ES', 'MA', 'MS', 'PB', 'PE', 'PI', 'SE'}
Local lUFFecp    := .F.
Local lSTSaida   := .F.
Local lProcST    := .T.
Local lRegEsp    := (SuperGetMv("MV_REGESP")>0) //Desconsiderar Devolucao de Compra e Envio para Beneficiamento - Implementacao do P9AutoText do RJ
Local cCgc       := Space (8)
Local cCFATGMB   := SuperGetMv("MV_CFATGMB")
Local lTransST   := SuperGetMv("MV_TRANSST") .And. cMvEstado$"MG/SC"
Local laPais     := .F.
Local lUsaSped   := SuperGetMv("MV_USASPED",,.T.) .And. aApurSX2[AI_CDH] .And. aApurSX2[AI_CDA] .And. aApurSX2[AI_CC6]
Local lApGIEFD   := SuperGetMv("MV_GIAEFD",,.F.) .And. aApurSX2[AI_F3K] .And. aApurSX2[AI_CDV] .And. aApurSX2[AI_CDY]
Local lMVRF3THRE := GetNewPar( 'MV_RF3THRE' , .F. )
Local lAchouCDA  := .F.
Local nPosAp     := 0
Local nFust      := GetNewPar("MV_FUST",0)
Local nFunttel   := GetNewPar("MV_FUNTTEL",0)
Local nRecBrut   := 0
Local lSimplSC   := SuperGetMv("MV_SIMPLSC",.F.,.T.)
Local lTransp    := SuperGetMV("MV_CONFRE",.F.,.T.)
Local lConsumo      := .F.
Local lAtivo        := .F.
local nValAti       := 0
Local nVAlCon       := 0
Local nPorAti       := 0
Local nPorCon       := 0
Local cChaveSD1		:= ""
Local cAliasSF1     := "SF1" 
Local lMapResumo	:= .F.
Local aMapaResumo	:= 	{}
Local aGravaMapRes	:= 	{}
Local cArqBkpQry	:= 	""
Local aArqTmpMP		:= 	""
Local lMesAnti		:= GetNewPar("MV_MESANTI",.F.)
Local lAnticms		:= aApurSX3[FP_F3_VALANTI]
Local lCredAcu		:= aApurSX3[FP_F3_CREDACU]
Local lNWCredAcu	:= lCredAcu .And. GetNewPar( 'MV_CREDACU' , .F. ) //.And. AliasIndic( "F2P" ) .And. AliasIndic( "F2R" )  //#TODO verifica parametros e campos dicionario
Local nPoscred		:= 0
Local aCredAcu		:= {}
Local lF3Cnae		:= aApurSX3[FP_F3_CNAE]
Local nVlrAnti		:= 0
Local cMunic		:= ""
Local nFilial    	:= 0
Local aResF3FT		:= {}
Local lResF3FT		:= GetNewPar("MV_RESF3FT",.F.)    
Local cChaveSFT		:= ""
Local cChavel		:= ""
Local cTipoMov		:= ""
Local nValicm       := 0
Local nIcmscom1  := 0
Local nValcont1     := 0
Local nIsenicm      := 0   
Local cCredOut		:= GetNewPar("MV_CROUTSP","")
Local lArt488MG     := .F.
Local aDbEsp 		:=	{}
Local cAliasNotas   := "NFSF3"
Local nPercCrOut	:= GetNewPar("MV_MTR9281",20)/100
Local cSimpNac      := ""   
Local aNfDupl       := {}
Local	lMVRF3LOG	:=	GetNewPar( 'MV_RF3LOG' , .F. )
Local	nLoop	:=	0
Local	nCtd	:=	1
Local	nAcCtd	:=	0
Local	cLoop	:=	DToS( Date() ) + ' ' + Time() 
Local 	nDiasAcreDt	:= 	Nil
Local lF3VLSENAR 	:=	Nil
Local lB5PROJDES	:=	aApurSX3[FP_B5_PROJDES]	
Local lF4MKPCMP		:=  aApurSX3[FP_F4_MKPCMP]	
Local lF4FTATUSC	:=  aApurSX3[FP_F4_FTATUSC]	
Local lconv13906	:=	aApurSX3[FP_FT_CV139]	
Local lChk13906     := .F. //Ao varrer a SFT, È verificado se h· alguma ocorrencia de FT_CV139 == "1"
Local lFTALFCCMP	:=	aApurSX3[FP_FT_ALFCCMP]	
Local	lDIMESC		:=	IsInCallStack('DIMESC')
Local	aMVDESENV	:=	&(GetNewPar("MV_DESENV","{}") )
Local   cTipoMov	:= ""  
Local   cIpi		:= ''      
Local lF4ESCRDPR	:=	aApurSX3[FP_F4_ESCRDPR]	
Local	aMVFISCPES	:=	&(GetNewPar("MV_FISCPES","{}") )
Local	cF4EsCrPr	:=	' '
Local 	aRastro		:= {}
Local   aResF3D1	:= {}
Local   lGetVlICMSD1:= .F.
Local aCfopDsv		:= xApCfopDef( "DES" )
Local   lPARICMS	:= GetNewPar('MV_PARICMS', .F.)  
Local   aCIAP		:= {}
Local   lESTCRPR	:= GetNewPar('MV_ESTCRPR', .F.)   
Local	nF3VALCONT	:= 0
Local 	lFomentGO	:= (cMvEstado=="GO".And. GetNewPar("MV_FOMENGO",.F.))
Local 	cCfMeraMov	:= GetNewPar("MV_MERAMOV",'') + '/5901/5902/5903/5905/5923/5924/5925/5934/6901/6903/6905/6923/6924/6925/6934'
Local   cCfCrdFo	:= GetNewPar("MV_CRDFOM",'') 
Local 	nPosRecST	:= 0
Local	nVlrBase	:= 0
Local	nICMAliq	:= 0
Local nDifVlr		:= 0
Local nCrOutPrtg	:= 0
Local nRedPrtg	:= 0

Local nContMun   := 0
Local nContVal   := 0
Local cForISS    := ""
Local cDescMun   := ""
Local lEncont    := .F.
Local cChvMun    := ""
Local nPosMunIss := 0
Local cMvFPadISS 	:= SuperGetMv("MV_FPADISS",.F.,"")
//Local lProRurPf   := .F. // Produtor rural pessoa fisica
Local lProRurPJ  := .F.
Local lTemPedido := .F.
Local lEstCreImp	:= SuperGetMv("MV_ESTCIMP", .F., .F.)
Local cLojISS    := ""
Local aFornISS   := {}
Local cMvCODRSEF := SuperGetMv("MV_CODRSEF", .F., "'','100'")
Local cNCMESTC	:= GetNewPar('MV_NCMESTC', "")
Local lF3DIFAL   := aApurSX3[FP_F3_DIFAL]	
Local lF3BASEDES := aApurSX3[FP_F3_BASEDES]	
Local lF3VFCPDIF := aApurSX3[FP_F3_VFCPDIF]	
Local lFTPDDES   := aApurSX3[FP_FT_PDDES]	
Local nPosDifal  := 0
Local dDTCOREC	:= GetNewPar('MV_DTCOREC', "") //data de corte - estorno cred. pres.		
Local cEstE310	:= SuperGetMv("MV_ESTE310",.F.,"")
Local lF3BSICMOR := aApurSX3[FP_F3_BSICMOR]	
Local lMVCDIFBEN := SuperGetMV("MV_CDIFBEN", .F., .F.)
Local cMVUFECSEP	:= SuperGetMv("MV_UFECSEP",.F.,"MG|AL|CE|DF|ES|MA|MS|PB|PE|PI|SE|RS")
Local lIncsol    := .F.
Local lJuridica  := .F.
Local lMVUFICSEP	:= cMvEstado$SuperGetMv("MV_UFICSEP",.F.,"")
Local lF4IPIPECR := aApurSX3[FP_F4_IPIPECR]	
Local lF4TXAPIPI := aApurSX3[FP_F4_TXAPIPI]	
Local lF4CRLEIT  := aApurSX3[FP_F4_CRLEIT]	
Local lNewNF     := .F.
Local cChvNF     := ""
Local nTamTpDoc := TamSX3("F6_TIPODOC")[1]
Local lB1FECOP   := aApurSX3[FP_B1_FECOP]	
Local lB1ALFECST := aApurSX3[FP_B1_ALFECST]	
Local lB1ALFECOP := aApurSX3[FP_B1_ALFECOP]	
//VerificaÁ„o dos campos de FECP
Local lF3VALFECP := aApurSX3[FP_F3_VALFECP]	
Local lF3VFECPST := aApurSX3[FP_F3_VFECPST]	
Local lF3VFECPMT := aApurSX3[FP_F3_VFECPMT]	
Local lF3VFECPRN := aApurSX3[FP_F3_VFECPRN]	
Local lF3VFESTRN := aApurSX3[FP_F3_VFESTRN]	
Local lF3VFECPMG := aApurSX3[FP_F3_VFECPMG]	
Local lF3VFESTMG := aApurSX3[FP_F3_VFESTMG]	
Local lFTVFESTRN := aApurSX3[FP_FT_VFESTRN]	
Local lFTVALFECP := aApurSX3[FP_FT_VALFECP]	
Local lOrigIPI   := aApurSX3[FP_CDA_ORIGEM]	.And. aApurSX3[FP_CDP_TPLANC]
Local lCodrSef   := aApurSX3[FP_F3_CODRSEF]	
Local lAchouD1D2 := .F.
Local lAchouF4    := .F.
Local cChavePrd   := ""
Local aSubAp      :={(aApurSX3[FP_CDO_SUBAP]), (aApurSX3[FP_CC6_SUBAP])}
Local lPosIPI     := aApurSX3[FP_B1_POSIPI]
Local lCROutSP    := aApurSX3[FP_F3_CROUTSP]
Local lFTValPro   := aApurSX3[FP_FT_VALPRO]
Local lCROutGO    := aApurSX3[FP_F3_CROUTGO]
Local lFtValFEEF  := aApurSX3[FP_FT_VALFEEF]
Local lPosCredST  := aApurSX3[FP_FT_CREDST]	
Local lPosFecpST  := aApurSX3[FP_FT_VFECPST]
Local lPosSolTrb  := aApurSX3[FP_FT_SOLTRIB]
Local lPosCrprST  := aApurSX3[FP_FT_CRPRST]	
Local lPosEstCred := aApurSX3[FP_F3_ESTCRED]
Local lPosValFum  := aApurSX3[FP_F3_VALFUM]
Local lPosCrdPct  := aApurSX3[FP_F3_CRDPCTR]
Local lPosCrdPre  := aApurSX3[FP_F3_CREDPRE]
Local lPosPrdRec  := aApurSX3[FP_B1_PRODREC]
Local lPosCrpRep  := aApurSX3[FP_F3_CRPREPR]
Local lPosCrpEsp  := aApurSX3[FP_F3_CPRESPR]
Local lPosCrpRer  := aApurSX3[FP_F3_CRPRERO]
Local lPosCrpRPE  := aApurSX3[FP_F3_CRPREPE]
Local lPosCrpRod  := aApurSX3[FP_F3_CPPRODE]
Local lPosTpProd  := aApurSX3[FP_F3_TPPRODE]
Local lPosCrpRes  := aApurSX3[FP_F3_CRPRESP]
Local lPosRegPb   := aApurSX3[FP_A1_REGPB]	
Local lPosPrzEsp  := aApurSX3[FP_F4_PRZESP]	
Local lPosValTst  := aApurSX3[FP_F3_VALTST]	
Local lPosCprRel  := aApurSX3[FP_F3_CRPRELE]	
Local lPosValFDS  := aApurSX3[FP_F3_VALFDS]	
Local lPosCrpSim  := aApurSX3[FP_F3_CRPRSIM]	
Local lPosVarAta  := aApurSX3[FP_F4_VARATAC]
Local lPosValAnt  := aApurSX3[FP_F3_VALANTI]	
Local lPosSimNac  := aApurSX3[FP_A2_SIMPNAC]
Local lPosVlIncM  := aApurSX3[FP_F3_VLINCMG]
Local lPosRicm65  := aApurSX3[FP_B1_RICM65]
Local lFTCRPREPE  := aApurSX3[FP_FT_CRPREPE]
Local lFTCPPRODE  := aApurSX3[FP_FT_CPPRODE]	
Local lFTTPPRODE  := aApurSX3[FP_FT_TPPRODE]	
Local lMvGerProt	:= GetNewPar("MV_GERPROT",.F.)
Local cProRurPJ   := ""
Local lConfApur 	:= SuperGetMV("MV_CONFAPU",.F.,.F.)  //Tapia
Local cAlsDeb		:= "ICMSDEB"
Local cTempDeb		:= "ICMSDEBITO"+AllTrim(Str(ThreadID()))
Local cAlsCrd		:= "ICMSCRD"
Local cTempCrd		:= "ICMSCREDITO"+AllTrim(Str(ThreadID()))
Local cAlsSTd		:= "STDEB"
Local cTempSTd		:= "STDEBITO"+AllTrim(Str(ThreadID()))
Local cAlsSTe		:= "STCRD"
Local cTempSTe		:= "STCREDITO"+AllTrim(Str(ThreadID()))
Local cAlsIPIs		:= "IPIDEB"
Local cTempIPIs		:= "IPIDEBITO"+AllTrim(Str(ThreadID()))
Local cAlsIPIe		:= "IPICRD"
Local cTempIPIe		:= "IPICREDITO"+AllTrim(Str(ThreadID()))
Local lEntFec		:= .F.
Local lSaiFec		:= .F.
Local lFTTES		:= aApurSX3[FP_FT_TES]
Local cSdTes		:= ""
Local lAliasApur	:= .T.
Local cSelect		:= ""
Local cTipoDB	    := AllTrim(Upper(TcGetDb()))
Local aStruSF3  	:= 	SF3->(dbStruct())
Local cA1PAIS		:=	''
Local cA2PAIS		:=	''
Local cMV_STNIEUF	:= SuperGetMV("MV_STNIEUF")
Local cMV_1DUPREF 	:= SuperGetMV("MV_1DUPREF")
Local nAliqIcm		:= 0
Local nImport		:= 0
Local lRetCFUF		:= .F.
Local cChave		:= ""
Local lFunname		:= IIf(FunName()=="MATA953",.T.,.F.)
Local cAliasSFT     := 'QSFTAPURF3'
Local aBind 


#IFDEF TOP
	Local cDtCanc	:= ""                  
	Local cQuery	:= ""
#ENDIF

Default aRecStDif := {}
Default aMensIPI	:= {}
DEFAULT aEstimulo	:= {}
Default aApurCDA  := {}
Default aApurF3	  := {}
Default aCDAIC	  := {}
Default aCDAST	  := {}
Default aFilsCalc := {}
Default aCDADE	  := {}
Default aRetEsp	  := {}
DEFAULT cFilUsr   := ""
DEFAULT cAliasTRB := ""
DEFAULT cMv_StUf  := ""
DEFAULT cMv_StUfS := ""
Default cChamOrig := ""
DEFAULT lGeraArq  := .F.
DEFAULT lQbUF 	  := .F.            
DEFAULT lQbPais	  := .F.            
Default lQbCfopUf := .F.
Default lImpCrdSt := .F.
Default lMv_UFSt  := .F.
Default lQbUfCfop := .F.
Default lConsUf   := .F.
Default lGiaRs    := .F.   
Default nParPerg  := 0
Default nCredMT   := 0
Default aDifal	:= {}
Default aCDADifal	:= {}
Default aCDAExtra	:= {}
Default aApurExtra	:= {}
Default aApurCDV	:=	{}
Default aCDAIPI		:=	{}
Default aNWCredAcu	:=	{}

Static _cQrySFT 
Static _cQryCV139

/* TRECHO COMENTADO POIS O TRATAMENTO DO MAPA RESUMO FOI RETIRADO DA XApurRF3Nw (MULTITHREAD) EM 06/12/2012. */
/*If SuperGetMV("MV_LJLVFIS",,1) == 2 .and. FindFunction("MaxRVerFunc") .and. MaxRVerFunc(cChamOrig) .and. nParPerg == 1
	lMapResumo := .T.
EndIf*/

/*
	Verificacao do preenchimento do parametro MV_FPADISS: Se o usuario optar por utilizar uma loja
	diferente de "00" (padr„o), o codigo do fornecedor e da loja devem ser separados por ";". Caso
	o parametro nao seja preenchido desta forma sera considerado o tratamento anterior.
*/

//Fiz este tratamento, pois em alguns ambiente o par‚metro MV_CONFRE È criado como caracter, estava errado no ATUSX, pois deveria ser do tipo lÛgico.
IF valtype(lTransp) == 'C'
	IF 'T' $ lTransp 
		lTransp	:= .T.
	Else
		lTransp	:= .F.
	EndIF
EndIf

If !Empty(cMvFPadISS)	
	If AT(";",cMvFPadISS) > 0		
		aFornISS := StrToKarr(cMvFPadISS, ";")						  
					
		If Len(aFornISS) >= 2
			cMvFPadISS := PadR(aFornISS[1], TamSX3("A2_COD")[1]) + PadR(aFornISS[2], TamSX3("A2_LOJA")[1])
		Else
			cMvFPadISS := PadR(aFornISS[1], TamSX3("A2_COD")[1]) +	PadR("00", TamSX3("A2_LOJA")[1])
		EndIf 														 				  	
	Else
		cMvFPadISS := PadR(cMvFPadISS, TamSX3("A2_COD")[1]) + PadR("00", TamSX3("A2_LOJA")[1])		
	EndIf
EndIf

cMvCODRSEF		:= IIF(Empty(cMvCODRSEF), "'','100'", cMvCODRSEF)
nDiasAcreDt := IIf( cMvEstado == "SP" , 9 , IIf( cMvEstado == "PR" , 5 , 0 ) ) //Usada para atender a Legislacao de SP/PR
lF3VLSENAR  := (cAliasSF3)->( FieldPos( "F3_VLSENAR" ) ) > 0 //SENAR

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Antecipacao de ICMS               													              ≥
//≥Somente sera processada a funcao Anticms se existir o campo F3_VALANTI e se o valor da Antecipacao ≥
//≥a ser exibido for no mes subsequente da entrada da nota fiscal                                     ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If lMesAnti .And. lAnticms
   nVlrAnti := AntIcms(dDtIni,dDtFim)
Endif         

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Tratamento para Credito Acumulado de ICMS - Bahia    	  ≥ 
//≥ Artigos 106 a 109 do RICMS/BA. 			                  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If lUfBA .And. lCredAcu
	aCredAcu :=CredAcum(dDtIni,dDtFim)
Endif

If cImp == "IC"
	lAliasApur := TCCanOpen(cTempDeb) .AND. TCCanOpen(cTempCrd) .AND.;
		TCCanOpen(cTempSTd) .AND. TCCanOpen(cTempSTe)
Elseif cImp == "IP"
	lAliasApur := TCCanOpen(cTempIPIs) .AND. TCCanOpen(cTempIPIe)
EndIf

If lConfApur .AND. lAliasApur
	If cImp=="IC"
		dbUseArea( .T. ,__cRdd , cTempDeb , cAlsDeb , .T. , .F. )
		( cAlsDeb )->( dbClearIndex() , dbSetIndex( cTempDeb + '_01' ) )
	
		dbUseArea( .T. ,__cRdd , cTempCrd , cAlsCrd , .T. , .F. )
		( cAlsCrd )->( dbClearIndex() , dbSetIndex( cTempCrd + '_01' ) )
	
		dbUseArea( .T. ,__cRdd , cTempSTd , cAlsSTd , .T. , .F. )
		( cAlsSTd )->( dbClearIndex() , dbSetIndex( cTempSTd + '_01' ) )
	
		dbUseArea( .T. ,__cRdd , cTempSTe , cAlsSTe , .T. , .F. )
		( cAlsSTe )->( dbClearIndex() , dbSetIndex( cTempSTe + '_01' ) )
	Elseif cImp == "IP"
		dbUseArea( .T. ,__cRdd , cTempIPIs , cAlsIPIs , .T. , .F. )
		( cAlsIPIs )->( dbClearIndex() , dbSetIndex( cTempIPIs + '_01' ) )
	
		dbUseArea( .T. ,__cRdd , cTempIPIe , cAlsIPIe , .T. , .F. )
		( cAlsIPIe )->( dbClearIndex() , dbSetIndex( cTempIPIe + '_01' ) )
	Endif
Endif
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥Quebra por CFOP+UF e se necessitar por Aliquota≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
lQbCfopUf := IIf((lQbUf .Or. lQbPais),.F.,lQbCfopUf)

If lQbPais
	cCodPais	:= GetNewPar( "MV_PAIS" , "{'SA1->A1_CODPAIS','SA2->A2_CODPAIS'}" )	// Informa o nome do campo com o codigo ou sigla do PaÌs(SA1,SA2)
	aCodPais	:= &cCodPais
	laPais		:= ( ValType( aCodPais ) == "A" .And. Len( aCodPais ) >= 1 )
	cA1PAIS	:=	Iif( laPais .And. SA1->( FieldPos( aCodPais[ 1 ] ) ) > 0 , aCodPais[ 1 ] , '' )
	cA1PAIS	:=	Iif( laPais .And. Empty( cA1PAIS ) .And. SA1->( FieldPos( SubStr( aCodPais[ 1 ] , 6 , 10 ) ) ) > 0 , SubStr( aCodPais[ 1 ] , 6 , 10 ) , cA1PAIS )
	cA2PAIS	:=	Iif( laPais .And. SA2->( FieldPos( aCodPais[ 2 ] ) ) > 0 , aCodPais[ 2 ] , '' )
	cA2PAIS	:=	Iif( laPais .And. Empty( cA2PAIS ) .And. SA2->( FieldPos( SubStr( aCodPais[ 2 ] , 6 , 10 ) ) ) > 0 , SubStr( aCodPais[ 2 ] , 6 , 10 ) , cA2PAIS )
EndIf	               
If lGeraArq .and. ( cImp == "IC" .Or. cImp == "IP" )
	aCampos	:= {}        
	If lQbPais .And. laPais
		AADD(aCampos,{"CODPAIS"	,"C",3,0})
	EndIf
	If lQbUF 
		aTam  	:= TAMSX3("F3_ESTADO")
		AADD(aCampos,{"UF"		,"C",aTam[1],aTam[2]})
		aTam  	:= TAMSX3("F3_VALCONT")                               
		AADD(aCampos,{"VALCONC" ,"N",aTam[1],aTam[2]})                         
		AADD(aCampos,{"VALCONNC","N",aTam[1],aTam[2]})                         
		aTam  	:= TAMSX3("F3_BASEICM")                               
		AADD(aCampos,{"BASEICC"  ,"N",aTam[1],aTam[2]})                         
		AADD(aCampos,{"BASEICNC" ,"N",aTam[1],aTam[2]})
	EndIf
	//Quebra por Uf/CFOP    	
	If lQbUfCfop
		aTam  	:= TAMSX3("F3_ESTADO")
		AADD(aCampos,{"UF"		,"C",aTam[1],aTam[2]})
	Endif		
	If lQbCfopUf
		aTam  	:= TAMSX3("F3_ESTADO")
		AADD(aCampos,{"UF"		,"C",aTam[1],aTam[2]})
		aTam  	:= TAMSX3("F3_ALIQICM")
		AADD(aCampos,{"ALIQICMS","N",aTam[1],aTam[2]})
	Endif		
	
	aTam  	:= TAMSX3("F3_CFO")
	AADD(aCampos,{"CFOP"	,"C",aTam[1],aTam[2]})
	aTam  	:= TAMSX3("F3_VALCONT")                               
	AADD(aCampos,{"VALCONT"	,"N",aTam[1],aTam[2]})                         
	aTam  	:= TAMSX3("F3_BASEICM")                               
	AADD(aCampos,{"BASEICM"	,"N",aTam[1],aTam[2]})                         
	aTam  	:= TAMSX3("F3_VALICM")                               
	AADD(aCampos,{"VALICM"	,"N",aTam[1],aTam[2]})                         
	aTam  	:= TAMSX3("F3_ISENICM")                               
	AADD(aCampos,{"ISENICM"	,"N",aTam[1],aTam[2]})                         
	aTam  	:= TAMSX3("F3_OUTRICM")                               
	AADD(aCampos,{"OUTRICM"	,"N",aTam[1],aTam[2]})                         
	aTam  	:= TAMSX3("F3_BASERET")                               
	AADD(aCampos,{"BASERET"	,"N",aTam[1],aTam[2]})                         
	aTam  	:= TAMSX3("F3_ICMSRET")                               
	AADD(aCampos,{"ICMSRET"	,"N",aTam[1],aTam[2]})
	aTam  	:= TAMSX3("F3_ICMSRET")                               
	AADD(aCampos,{"VlRETIC"	,"N",aTam[1],aTam[2]})                         
	aTam  	:= TAMSX3("F3_TRFICM")                               
	AADD(aCampos,{"TRFICM"	,"N",aTam[1],aTam[2]})                         
	aTam  	:= TAMSX3("F3_ICMSCOM")                               
	AADD(aCampos,{"ICMSCOM"	,"N",aTam[1],aTam[2]})               
	aTam  	:= TAMSX3("F3_VALIPI")                               
	AADD(aCampos,{"VALIPI"	,"N",aTam[1],aTam[2]}) 
	AADD(aCampos,{"VLIPIOBS"	,"N",aTam[1],aTam[2]})            
	aTam  	:= TAMSX3("F3_IPIOBS")                               
	AADD(aCampos,{"IPIOBS"	,"N",aTam[1],aTam[2]})              
	aTam  	:=  Iif(aApurSX3[FP_F3_ESTCRED], TAMSX3("F3_ESTCRED"), {16,2})
	AADD(aCampos,{"ESTCRED"	,"N",aTam[1],aTam[2]})
    aTam  	:= TAMSX3("F3_ISSSUB")                               
	AADD(aCampos,{"ISSSUB"	,"N",aTam[1],aTam[2]})               
	
	aTam  	:= TAMSX3("F3_OUTRICM")                               
	AADD(aCampos,{"VLEXCLRS"	,"N",aTam[1],aTam[2]})               
	aTam  	:= Iif(lF3BSICMOR, TAMSX3("F3_BSICMOR"), {16,2})
	AADD(aCampos,{"BSICMOR"	,"N",aTam[1],aTam[2]})               

	cArqTRB :=	CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cArqTRB,cAliasTRB,.T.,.F.)
	If lQbUF
		IndRegua(cAliasTRB,cArqTRB,"UF+CFOP")
	ElseIf lQbPais .and. laPais
		IndRegua(cAliasTRB,cArqTRB,"CODPAIS+CFOP")
	ElseIf lQbCfopUf
		IndRegua(cAliasTRB,cArqTRB,"CFOP+UF")	
	ElseIf lQbUfCfop
		IndRegua(cAliasTRB,cArqTRB,"UF+CFOP")
	Else
		IndRegua(cAliasTRB,cArqTRB,"CFOP")
	EndIf	
	If lGiaRs				
	    aCamposSF3 := {}
	    aTam  	   := TAMSX3("F3_NFISCAL")                               
		AADD(aCamposSF3,{"NFISCAL","C",aTam[1],aTam[2]})	
	    
	    aTam    := TAMSX3("F3_SERIE")                               
		AADD(aCamposSF3,{"SERIE","C",aTam[1],aTam[2]})     					   					
				
		aTam  	:= TAMSX3("F3_CLIEFOR")                                                                  			
		AADD(aCamposSF3,{"CLIEFOR"	,"C",aTam[1],aTam[2]})                         
	
		aTam  	:= TAMSX3("F3_LOJA")                               
		AADD(aCamposSF3,{"LOJA"	,"C",aTam[1],aTam[2]})   
		
		aTam  	:= TAMSX3("F3_CRDPRES")                               
		AADD(aCamposSF3,{"CRDPRES"	,"N",aTam[1],aTam[2]}) 
		
	    aTam  	:= TAMSX3("F3_CFO")                               
		AADD(aCamposSF3,{"CFOP","C",aTam[1],aTam[2]})		                  
							
		cArqTRBSF3 :=	CriaTrab(aCamposSF3)
		DbUseArea(.T.,__LocalDriver,cArqTRBSF3,cAliasNotas,.T.,.F.)
		
		IndRegua(cAliasNotas,cArqTRBSF3,"NFISCAL+SERIE+CLIEFOR+LOJA")
	EndIf
	DbSelectArea(cAliasTRB)
	DbClearIndex()
	DbSetIndex(cArqTRB+OrdBagExt())
	
ElseIf lGeraArq .and. cImp == "IS"
	
	aCampos	:= {}        
	aTam  	:= TAMSX3("F3_CODISS")
	AADD(aCampos,{"CODISS"	,"C",aTam[1],aTam[2]})
	aTam2  	:= TAMSX3("F3_ALIQICM")               
	AADD(aCampos,{"ALIQISS"	,"N",aTam2[1],aTam2[2]})
	aTam  	:= TAMSX3("F3_VALCONT")                               
	AADD(aCampos,{"VALCONT"	,"N",aTam[1],aTam[2]})                         
	aTam  	:= TAMSX3("F3_BASEICM")                               
	AADD(aCampos,{"BASEISS"	,"N",aTam[1],aTam[2]})                         
	aTam  	:= TAMSX3("F3_VALICM")                               
	AADD(aCampos,{"VALISS"	,"N",aTam[1],aTam[2]})                         
	aTam  	:= TAMSX3("F3_ISENICM")                               
	AADD(aCampos,{"ISENISS"	,"N",aTam[1],aTam[2]})                         
	aTam  	:= TAMSX3("F3_OUTRICM")                               
	AADD(aCampos,{"OUTRISS"	,"N",aTam[1],aTam[2]})                         
    aTam  	:= TAMSX3("F3_ISSSUB")                               
	AADD(aCampos,{"ISSSUB"	,"N",aTam[1],aTam[2]})               

	cArqTRB := CriaTrab(aCampos)
	dbUseArea(.T.,__LocalDriver,cArqTRB,cAliasTRB,.T.,.F.)
	IndRegua(cAliasTRB,cArqTRB,"CODISS+STR(ALIQISS,"+ALLTRIM(STR(aTam2[1]))+","+ALLTRIM(STR(aTam2[2]))+")")
	DbSelectArea(cAliasTRB)
	DbClearIndex()
	DbSetIndex(cArqTRB+OrdBagExt())
	
EndIf	

aEntr := {}
aSaid := {}
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Trata filiais                                                ≥
//≥ Caso haja algum parametro sem ser passado ou se nao considera≥
//≥ filiais, a filiais de/ate serao a corrente                   ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
nConsFil := Iif(nConsFil==Nil,2,nConsFil)
If cFilDe == Nil .or. cFilAte == Nil .or. nConsFil == 2
	cFilDe := cFilAnt
	cFilAte:= cFilAnt
Endif

If nConsFil == 1 .and. Len( aFilsCalc ) > 0
	cFilDe := Space(Len( cFilAnt ) ) 
	cFilAte := Replicate('Z',Len( cFilAnt ) ) 
EndIf
//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Define valores default                                       ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
lEnd		:=	IIf(lEnd==NIL,.f.,lEnd)
nRegua	:=	IIf(nRegua==NIL,0,nRegua)
cNrLivro	:=	IIf(cNrLivro==NIL	,"*",cNrLivro)
Do Case
	Case cImp	==	"IC"
		lQbAliq	:=	IIf(lQbAliq==NIL,.t.,lQbAliq)
		lQbCFO	:=	IIf(lQbCFO==NIL,.t.,lQbCFO)
	Case cImp	==	"IP"
		lQbAliq	:=	IIf(lQbAliq==NIL,.f.,lQbAliq)
		lQbCFO	:=	IIf(lQbCFO==NIL,.t.,lQbCFO)
	Case cImp	==	"IS"
		lQbAliq	:=	IIf(lQbAliq==NIL,.t.,lQbAliq)
		lQbCFO	:=	IIf(lQbCFO==NIL,.t.,lQbCFO)
EndCase

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilDe,.T.)

cCgc	:=	SubStr (SM0->M0_CGC, 1, 8)
//lProRurPf := (SM0->M0_PRODRUR$"F1")
lProRurPJ := (SM0->M0_PRODRUR$"J2F1")

IF FWModeAccess( 'SX5' , 3 ) == 'C'
	//Carrega CFOPs SX5 unica vez caso seja compartilhada
	ApurVerCFO(,.T.)
EndIf


While !SM0->(Eof()) .and. FWGrpCompany()+FWCodFil() <= cEmpAnt+cFilAte 
	cFilAnt := FWGETCODFILIAL // Mudar filial atual temporariamente

	If (SuperGetMv ("MV_CONSCGC") .And. !(cCgc==SubStr (SM0->M0_CGC, 1, 8)))
		SM0->(DbSkip ())
		Loop
	EndIf
	                    
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Atendimento ao Art. 121 do ANEXO 5 do RICMS/SC. O mesmo determina que todo prestador de                    ≥
	//≥  serviÁo de transporte deve apresentar as obrigaÁıes acessÛrias de forma consolidada pelo estabelecimento ≥
	//≥  matriz, e esta consolidaÁ„o dever· abranger somente as empresas que estiverem domiciliadas no mesmo      ≥
	//≥  estado do estabelecimento consolidador.                                                                  ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If lConsUF .And. (SM0->M0_ESTENT <> cMvEstado)
		SM0->(DbSkip ())
		Loop
	EndIf
	//-- Tratamento para utilizacao da MatFilCalc
	If Len(aFilsCalc) > 0 .and. nConsFil == 1
       nFilial := Ascan(aFilsCalc,{|x| Alltrim(x[2])==Alltrim(cFilAnt)})
	   If nFilial == 0 .or. ( nFilial > 0 .And. !(aFilsCalc[  nFilial, 1 ]))  //Filial n„o encontrada ou n„o marcada, vai para prÛxima
			SM0->( dbSkip() ) 
			Loop
		EndIf
	EndIf

	_INTTMS      := IntTms()

	dbSelectArea("CD2")
	CD2->(dbSetOrder(1))
	dbSelectArea("SF6")
	SF6->(dbSetOrder(1))
	If ChkFile("CDC")
		dbSelectArea("CDC")
		CDC->(dbSetOrder(1))
	Endif
	dbSelectArea("SF3")
	SF3->(dbSetOrder(1))
	If lApGIEFD
		dbSelectArea("F3K")
		F3K->(DbSetOrder(1))
	Endif
	dbSelectArea("CDY")	
	CDY->(DbSetOrder(1))
	If nRegua>0
		If nRegua	==	1
			ProcRegua(dDtFim-dDtIni)
		Else
			SetRegua(dDtFim-dDtIni)
		Endif
		dDtAnt	:=	SF3->F3_ENTRADA
	Endif
	DbSelectArea("SA1")
	
	lJuridica := RetPessoa(SM0->M0_CGC) $ "J2"	
	nRecBrut := Iif(nFust > 0 .Or. nFunttel > 0, CalcRB(dDtIni,dDtFim,0,.F.,{},.T.,,,,,,,,,,,dDtIni,dDtFim,0,.F.),0)

	cProRurPJ := SM0->M0_PRODRUR
	
	cQuery	:= ""	
	cSelect := ""

	If cNrLivro <> "*"
		cQuery := "F3_NRLIVRO = '" + cNrLivro + "' AND "       
	Endif

	If lCodrSef .and. cImp	<>	"IS"
		cQuery += "((SF3.F3_ESPECIE IN ('SPED','CTE','NFCE') AND SF3.F3_CODRSEF IN(" + cMvCODRSEF + ")) OR SF3.F3_ESPECIE NOT IN ('SPED','CTE','NFCE')) AND "
	Endif                               
		
	If cImp	==	"IS"
		cQuery += "	F3_ENTRADA BETWEEN '"+Dtos(dDtIni)+"' AND '"+Dtos(dDtFim)+"' AND "
		If lF3Cnae
			cQuery += "(F3_CODISS <> '" + Space(TamSx3('F3_CODISS')[1]) + "' OR "
			cQuery += "F3_CNAE <> '" + Space(TamSx3('F3_CNAE')[1]) + "') AND "
		Else
			cQuery += "F3_CODISS <> '" + Space(TamSx3('F3_CODISS')[1]) + "' AND "
		EndIf
		cQuery += "F3_CFO >= '501' AND "
	ElseIf cimp=="IC"	 
		cQuery += " ((F3_ENTRADA BETWEEN '"+Dtos(dDtIni)+"' AND '"+Dtos(dDtFim)+"' AND "

		If cMvEstado=='PR'
			cQuery += "	F3_CFO NOT IN ('1602','1605','5601','5602','5605')) OR"						
			cQuery += " (F3_ENTRADA BETWEEN '"+Dtos(dDtIni+5)+"' AND '"+Dtos(dDtFim+5)+"' AND "
			cQuery += " F3_CFO IN ('1602','1605','5601','5602','5605'))) AND "
		Else	
			cQuery += "	F3_CFO NOT IN ('1601','1602','1605','5601','5602','5605')) OR"			   					
			cQuery += " (F3_ENTRADA BETWEEN '"+Dtos(dDtIni+nDiasAcreDt)+"' AND '"+Dtos(dDtFim+nDiasAcreDt)+"' AND "
			cQuery += " F3_CFO IN ('1601','1602','1605','5601','5602','5605'))) AND "
		EndIf
		
		cQuery += "F3_CODISS = '" + Space(TamSx3('F3_CODISS')[1]) + "' AND "
		If lF3Cnae
			cQuery += "( F3_CNAE = '" + Space(TamSx3('F3_CNAE')[1]) + "' OR ( F3_CNAE <> '" + Space(TamSx3('F3_CNAE')[1]) + "' AND F3_TIPO <> 'S' ) ) AND "
		Endif
	Else
		cQuery += "	F3_ENTRADA BETWEEN '"+Dtos(dDtIni)+"' AND '"+Dtos(dDtFim)+"' AND "
	EndIf

	For nX := 1 To len(aStruSF3)
		If SF3->(FieldPos(Alltrim(aStruSF3[nX][1])))  > 0
			cSelect += "SF3."+ Alltrim(aStruSF3[nX][1])+","
		EndIf
	Next nX

	IF cimp=="IC" .or. cimp=="IP"	
		cSelect  += " ( CASE WHEN (SELECT COUNT(CDA.CDA_CODLAN) FROM " + RetSQLName( "CDA" ) + " CDA WHERE CDA.CDA_FILIAL='"+ xFilial( "CDA" ) + "' AND CDA.CDA_TPMOVI = CASE WHEN SUBSTRING(SF3.F3_CFO,1,1)<'5' THEN 'E' ELSE 'S' END AND CDA.CDA_ESPECI = SF3.F3_ESPECIE  AND CDA.CDA_NUMERO = SF3.F3_NFISCAL AND CDA.CDA_SERIE = SF3.F3_SERIE AND CDA.CDA_CLIFOR = SF3.F3_CLIEFOR AND CDA.CDA_LOJA = SF3.F3_LOJA AND CDA.CDA_ORIGEM " + Iif(cimp=="IC"," <= '2'", " = '3'") + " AND CDA.D_E_L_E_T_ = ' ') > 0 THEN 1 ELSE 0 END ) COUNTCDA "
	Else
		cSelect := SubStr(cSelect,1, Len(AllTrim(cSelect))-1)
	Endif

	cSelect := "%" + cSelect + "%"	
	cQuery := "%" + cQuery + "%"	
															
	cDtCanc := Space(TamSx3("F3_DTCANC")[01])		

	lQuery 		:= .T.
	cAliasSF3	:= GetNextAlias()   
	
	BeginSql Alias cAliasSF3
		COLUMN F3_ENTRADA 	AS DATE
		COLUMN F3_EMISSAO 	AS DATE
		COLUMN F3_DTLANC 	AS DATE
		COLUMN F3_DTCANC 	AS DATE
		COLUMN F3_EMINFE 	AS DATE
		COLUMN F3_DTFIMNT 	AS DATE		
		SELECT 
		%Exp:cSelect%
		
		FROM %table:SF3% SF3
								
		WHERE SF3.F3_FILIAL = %xFilial:SF3% AND 
			SF3.F3_DTCANC = %Exp:cDtCanc% AND
			%Exp:cQuery%
			SF3.%NotDel%

		ORDER BY %Order:SF3%
	EndSql
	
	dbSelectArea(cAliasSF3)

	IF  (cAliasSF3)->(!Eof())
		//Carrega CÛdigos de Ajuste
		CargaCodAju(dDtIni,dDtFim)

		IF FWModeAccess( 'SX5' , 3 ) == 'E'
			//Carrega CFOPs SX5 por filial caso seja exclusiva
			ApurVerCFO(,.T.)
		EndIf
	Endif

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Apresenta informacoes do Mapa Resumo atraves de arquivo temporario≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ	
	/* TRECHO COMENTADO POIS O TRATAMENTO DO MAPA RESUMO FOI RETIRADO DA XApurRF3Nw (MULTITHREAD) EM 06/12/2012. */
	/*If lMapResumo	
		cChave			:=	IndexKey()    
		cArqBkpQry 	:= cAliasSf3
	
		aMapaResumo	:= 	MaxRMapRes(dDtIni,dDtfIM)
		aGravaMapRes	:= 	MaXRAgrupF3(cFilAnt,aMapaResumo,cChamOrig)
		cArqTmpMP		:= 	MaXRExecArq(1)
		cAliasSf3		:=	MaXRAddArq(1,cArqTmpMP,cAliasSf3,,aGravaMapRes,cChave)	
	EndIf*/  

	//---------------------------------------------------------------+
	// Montando o Hash do aApuracao									 |	
	//---------------------------------------------------------------+
	If lBuild
		oHashCFUF := HMNew()
	EndIf

	//Trecho comentado utilizado para auferir tempo de processamento
	nLoop	:=	0
	nCtd	:=	1
	nAcCtd	:=	0
	cLoop	:=	DToS( Date() ) + ' ' + Time()	
	While (cAliasSF3)->(!Eof()) .and. (cAliasSF3)->F3_FILIAL	==	xFilial("SF3") .and. (cAliasSF3)->F3_ENTRADA>=dDtIni .and. ((cAliasSF3)->F3_ENTRADA<=dDtFim .or. (cAliasSF3)->F3_ENTRADA<=(dDtFim+nDiasAcreDt)) .and. !lEnd
		//condicao para gerar o mensagem no console.log
		If lMVRF3LOG
			//Trecho comentado utilizado para auferir tempo de processamento
			If cLoop <> DToS( Date() ) + ' ' + Time()
				nAcCtd	+=	nCtd
				nLoop++
				ConOut( 'XApurRF3: ' + cLoop + ' - Qtd Regs: ' + AllTrim( StrZero( nCtd , 4 ) ) + ' - Media: ' + AllTrim( StrZero( Int( nAcCtd / nLoop ) , 4 ) ) )
				cLoop	:=	DToS( Date() ) + ' ' + Time()
				nCtd	:=	1
			Else
				nCtd++
			EndIf
		EndIf

		If !Empty(cFilUsr) .And. !((cAliasSF3)->(&cFilUsr.))
			(cAliasSF3)->(dbSkip())
			Loop	
		Endif
		
		If lQbPais .and. (Substr((cAliasSF3)->F3_CFO,1,1)$"1#2#5#6" .or. empty(cCodPais))
			(cAliasSF3)->(dbSkip())
			Loop	
		Endif			
			
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Movimenta regua                                              ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If nRegua>0
			cMsg	:=	OemToAnsi(STR0001) //"Executando apuraáÑo..."
			If dDtAnt	!=	(cAliasSF3)->F3_ENTRADA
				If nRegua	==	1
					IncProc(cMsg)
				Else
					IncRegua()
				Endif
				dDtAnt	:=	(cAliasSF3)->F3_ENTRADA
			EndIf
		Endif
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Verifica interrupcao                                         ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If Interrupcao(@lEnd)
			aApuracao := {}
			Loop
		Endif
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Filtros                                                      ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If cImp$"IC/IP" .AND.(cAliasSF3)->F3_TIPO=="S"
			(cAliasSF3)->(dbSkip())
			Loop
		Endif
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Desconsidera Notas Fiscais em Lote que nao possuem ISS≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	    If cImp == "IS" .And. Empty((cAliasSF3)->F3_CODISS) .And. (cAliasSF3)->F3_TIPO=='L'
		    (cAliasSF3)->(dbSkip())
		    Loop
	    Endif
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Decreto Municipal 2.154/2003 - Florianopolis/SC              ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If lUsaCfps .And. cImp == "IS" .And. FisChkCfps("E",(cAliasSF3)->F3_CFO)
		    (cAliasSF3)->(dbSkip())
		    Loop
	    Endif

		//Verifica se deve zerar o valor contabil conforme cfops do parametro
		nF3VALCONT := (cAliasSF3)->F3_VALCONT
		If cImp$"IC|IP" .AND. Alltrim((cAliasSF3)->F3_CFO)$GetNewPar("MV_VLCTBZL"," ")
			nF3VALCONT := 0	
		EndIf
		
		//Tratamento para identificar se mudou a NF, tem coisas que preciso chamar apenas uma vez por NF, exemplo Lancamentos da CDA
		If cChvNF <> ( cAliasSF3 )->( F3_FILIAL + F3_CLIEFOR + F3_LOJA + F3_SERIE + F3_NFISCAL )
			cChvNF	:=	( cAliasSF3 )->( F3_FILIAL + F3_CLIEFOR + F3_LOJA + F3_SERIE + F3_NFISCAL )
			lNewNF	:=	.T.
		EndIf
		
		SFT->(dbSetOrder(3))
		SD1->(dbSetOrder(1))		   		
		SD2->(dbSetOrder(3))
		SF4->(dbSetOrder(1))
		SA1->(dbSetOrder(1))  
		
		aResF3FT       := {}
		aResF3D1       := {}
		lGetVlICMSD1   := .F.
		nValicm	       := 0
		nIcmscom1	   := 0
		nValcont1	   := 0
		nIsenicm	   := 0
        lEntFec 	   := .F.
		lSaiFec		   := .F.
		cSdTes  	   := " " 	
										
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Acumuladores                                                 ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		Do Case
			Case lQbUfCfop
				cCFO :=	ApurVerCFO( (cAliasSF3)->F3_CFO )
				if lBuild .AND. lFunname
					cChave	:= 	(cAliasSF3)->F3_ESTADO + cCFO
					nPos := FisFindHash(oHashCFUF,cChave)
				else
					nPos := Ascan(aApuracao,{|x|x[19]==(cAliasSF3)->F3_ESTADO .And. x[1]==cCFO})
				EndIf
			Case lQbAliq .and. lQbCFO .and. !lQbPais .And. !lQbUF
				If cImp	==	"IS"
					cCFO	:=	((cAliasSF3)->F3_CODISS)
				Else
					cCFO	:=	ApurVerCFO( (cAliasSF3)->F3_CFO )
					If lApurICM
					   cCfo := ExecBlock("APURICM",.F.,.F.,{cCfo})
					EndIf
				Endif	
				nAliq	:=	IIf(cImp=="IP",0,(cAliasSF3)->F3_ALIQICM)
			
			    IF cImp == "IP"
			    	If lQbCfopUf
						if lBuild .AND. lFunname
							cChave := cCFO + cValToChar(nAliq) + (cAliasSF3)->F3_ESTADO			    			
							nPos := FisFindHash(oHashCFUF,cChave) 
						else
							nPos := Ascan(aApuracao,{|x|x[1]==cCFO .And. x[2]==nAliq .And. x[19]==(cAliasSF3)->F3_ESTADO})				
						EndIf
					Else
						if lBuild .AND. lFunname
							cChave := cCFO + cValToChar(nAliq)
							nPos := FisFindHash(oHashCFUF,cChave) 
						Else									
							nPos := Ascan(aApuracao,{|x|x[1]==cCFO.and.x[2]==nAliq})
						EndIf
					Endif
			    Else
					If lQbCfopUf
						if lBuild .AND. lFunname
							cChave := cCFO + cValToChar(nAliq) + (cAliasSF3)->F3_ESTADO
							nPos := FisFindHash(oHashCFUF,cChave) 
						else
							nPos := Ascan(aApuracao,{|x|x[1]==cCFO .And. x[2]==nAliq .And. x[19]==(cAliasSF3)->F3_ESTADO})
						EndIf
					Else
						if lBuild .AND. lFunname
							cChave := cCfo + cValToChar(nAliq)
							nPos := FisFindHash(oHashCFUF,cChave) 
						Else
							nPos := Ascan(aApuracao,{|x|x[1]==cCFO.and.x[2]==nAliq})
						EndIf
					Endif
				EndIf 							
			Case !lQbAliq .and. lQbCFO .and. !lQbPais .And. !lQbUF
				If cImp	==	"IS"					
					cCFO	:=	((cAliasSF3)->F3_CODISS)
				Else
					cCFO	:=	ApurVerCFO( (cAliasSF3)->F3_CFO )
					If lApurICM
					   cCfo := ExecBlock("APURICM",.F.,.F.,{cCfo})
					EndIf
				EndIf
				nAliq	:=	0
			
				IF cImp == "IP" 
					If lQbCfopUf
						if lBuild .AND. lFunname
							cChave := cCFO + (cAliasSF3)->F3_ESTADO						
							nPos := FisFindHash(oHashCFUF,cChave) 
						else
							nPos := Ascan(aApuracao,{|x|x[1]==cCFO .And. x[19]==(cAliasSF3)->F3_ESTADO})
						EndIf
					Else
						if lBuild .AND. lFunname
							cChave := cCFO
							nPos := FisFindHash(oHashCFUF,cChave)
						Else				   	
							nPos := Ascan(aApuracao,{|x|x[1]==cCFO}) 
						EndIf
					Endif
			    Else
					If lQbCfopUf .or. (cImp == "IC" .AND. lFunname)
						if lBuild .AND. lFunname
							cChave := cCFO + (cAliasSF3)->F3_ESTADO
							nPos := FisFindHash(oHashCFUF,cChave) 
						else
							nPos := Ascan(aApuracao,{|x|x[1]==cCFO .And. x[19]==(cAliasSF3)->F3_ESTADO})
						EndIf
					ELSE
						if lBuild .AND. lFunname
							cChave := cCFO
							nPos := FisFindHash(oHashCFUF,cChave) 
						else
							nPos := Ascan(aApuracao,{|x|x[1]==cCFO})
						EndIf
					Endif
				EndIf	
				
			Case (lQbAliq .and. !lQbCFO).or.(!lQbAliq .and. !lQbCFO) .and. !lQbPais .And. !lQbUF

				If cImp	==	"IS"
					cCFO	:=	((cAliasSF3)->F3_CODISS)
				Else				
					cCFO	:=	IIf(Val(Substr((cAliasSF3)->F3_CFO,1,1))<5,"ENTR","SAID")
				EndIF
				
				nAliq	:=	IIf(cImp=="IP",0,(cAliasSF3)->F3_ALIQICM)
		    	
				IF cImp == "IP"
					If lQbCfopUf
						if lBuild .AND. lFunname
							cChave := cCFO + cValtoChar(nAliq) + (cAliasSF3)->F3_ESTADO
							nPos := FisFindHash(oHashCFUF,cChave)
						Else
							nPos := Ascan(aApuracao,{|x|x[1]==cCFO .And. x[2]==nAliq .And. x[19]==(cAliasSF3)->F3_ESTADO})
						EndIf
					Else
						if lBuild .AND. lFunname
							cChave := cCFO + cValtoChar(nAliq)
							nPos := FisFindHash(oHashCFUF,cChave)
						else
							nPos := Ascan(aApuracao,{|x|x[1]==cCFO.and.x[2]==nAliq})
						EndIf
	    			Endif
			    Else
					If lQbCfopUf
						if lBuild .AND. lFunname
							cChave := cCFO + cValtoChar(nAliq) + (cAliasSF3)->F3_ESTADO
							nPos := FisFindHash(oHashCFUF,cChave)
						Else
							nPos := Ascan(aApuracao,{|x|x[1]==cCFO .And. x[2]==nAliq .And. x[19]==(cAliasSF3)->F3_ESTADO})
						EndIf
					Else
						if lBuild .AND. lFunname
							cChave := cCFO + cValtoChar(nAliq)
							nPos := FisFindHash(oHashCFUF,cChave)
						Else
							nPos := Ascan(aApuracao,{|x|x[1]==cCFO.and.x[2]==nAliq})
						EndIf
	    			Endif
				EndIf
    			
			Case lQbUF .and. !lQbCFO .and.!lQbAliq .and. !lQbPais
				cCFO	:=	IIf(Val(Substr((cAliasSF3)->F3_CFO,1,1))<5,"ENTR","SAID")
				nAliq	:=	0
				if lBuild .AND. lFunname
					cChave := (cAliasSF3)->F3_ESTADO + cCFO
					nPos := FisFindHash(oHashCFUF,cChave)
				Else
    				nPos :=	Ascan(aApuracao,{|x|x[19]==(cAliasSF3)->F3_ESTADO .and. x[1]==cCFO})
				EndIf  					
			Case lQbUF .and. lQbCFO .and.!lQbAliq .and. !lQbPais
				cCFO	:=	ApurVerCFO( (cAliasSF3)->F3_CFO )
				If lApurICM
				   cCfo := ExecBlock("APURICM",.F.,.F.,{cCfo})
				EndIf
				nAliq	:=	0
				if lBuild .AND. lFunname
					cChave := (cAliasSF3)->F3_ESTADO + cCFO
					nPos := FisFindHash(oHashCFUF,cChave)
				Else
					nPos := Ascan(aApuracao,{|x|x[19]==(cAliasSF3)->F3_ESTADO .and. x[1]==cCFO})				
				EndIF
			Case lQbPais .and. !lQbCFO .and. !lQbAliq .And. !lQbUF
				cCFO	:=	IIf(Val(Substr((cAliasSF3)->F3_CFO,1,1))<5,"ENTR","SAID")
				If !Empty( cA1PAIS ) .AND. (((Substr((cAliasSF3)->F3_CFO,1,1)=="7" .And. !(cAliasSF3)->F3_TIPO$"BD") .or. (Substr((cAliasSF3)->F3_CFO,1,1)=="3" .And. (cAliasSF3)->F3_TIPO$"BD")) .Or. (lUsaCfps .And. FisChkCfps("S",(cAliasSF3)->F3_CFO))) .and. laPais
					SA1->(MsSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					If !Empty( cA1PAIS )
						cCodPais := SA1->( &( cA1PAIS ) )
					EndIf
					
				ElseIf  !Empty( cA2PAIS ) .AND.  Substr((cAliasSF3)->F3_CFO,1,1)$"3#7" .and. Len(aCodPais) == 2
					SA2->(MsSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					If !Empty( cA2PAIS )
						cCodPais := SA2->( &( cA2PAIS ) )
					EndIf
				EndIf
				
				if lBuild .AND. lFunname
					cChave := cCodPais + cCfo
					nPos := FisFindHash(oHashCFUF,cChave)
				else
					nPos :=	Ascan(aApuracao,{|x|x[20]==cCodPais  .and. x[1]==cCFO})
				EndIf
									
		EndCase
		
		If nPos==0
			AADD(aApuracao,Array(LEN_ARRAY_APURACAO))
			nPos	:=	Len(aApuracao)
			if lBuild .AND. lFunname
			   FisAddHash(oHashCFUF, cChave, nPos) 
			EndIf	
			aApuracao[nPos,01]	:=	cCFO
			aApuracao[nPos,02]	:=	nAliq
			aApuracao[nPos,89]	:= ""
			IF lQbUF .or. lQbUfCfop
				Aeval(aApuracao[nPos],{|x,i|aApuracao[nPos,i]:=0},2)
				aApuracao[nPos,19]	:=	(cAliasSF3)->F3_ESTADO
			ElseIf lQbPais .and. Len(aCodPais) >= 1
				Aeval(aApuracao[nPos],{|x,i|aApuracao[nPos,i]:=0},3)
				aApuracao[nPos,20]	:=	cCodPais
			ElseIf lQbCfopUf
				Aeval(aApuracao[nPos],{|x,i|aApuracao[nPos,i]:=0},3)
				aApuracao[nPos,19]	:=	(cAliasSF3)->F3_ESTADO
			Else
				Aeval(aApuracao[nPos],{|x,i|aApuracao[nPos,i]:=0},3)
			EndIf
		    aApuracao[nPos,19]	:=	(cAliasSF3)->F3_ESTADO
		    aApuracao[nPos,118] := 0
		Endif
		
		aApuracao[nPos,124]	:= "" // Posicao inutilizada.
		aApuracao[nPos,74]	:=	(cAliasSF3)->F3_TIPO

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥O trecho abaixo deve concentrar as regras que dependem do posicionamento   |
		//≥da SFT, SD2, SD2, SF4 para evitar a repeticao destes lacos no processamento|
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		cTipoMov 	:= Iif((cAliasSF3)->F3_CFO >="5","S","E")
		
		If _cQrySFT == nil 
			_cQrySFT := "SELECT FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA,"
			_cQrySFT += " FT_ITEM, FT_PRODUTO, FT_EMISSAO, FT_ICMSRET, FT_OBSSOL, FT_ESTADO,"
			_cQrySFT += " FT_CREDST, FT_IDENTF3, FT_BASERET, FT_VFECPST, FT_SOLTRIB, FT_CRPRST,"
			_cQrySFT += " FT_VFESTRN, FT_TIPO, FT_VALIPI, FT_CFOP, FT_ICMSCOM, FT_VALICM,"
			_cQrySFT += " FT_DESPESA, FT_ISENICM, FT_VALPRO, FT_CROUTSP, FT_VALFEEF, FT_CRPREPE,"
			_cQrySFT += " FT_CPPRODE, FT_QUANT, FT_ALIQICM, FT_TPPRODE, FT_CV139, SFT.R_E_C_N_O_ RECSFT "
			If cMvEstado $ "SP"  .And. lCroutSP .And. lPosIPI
				_cQrySFT += " , B1_POSIPI "
			EndIf 
			_cQrySFT += " FROM " + RetSqlName('SFT')+" SFT "
			If cMvEstado $ "SP"  .And. lCroutSP .And. lPosIPI
				_cQrySFT += " INNER JOIN "+RetSqlName("SB1")+" SB1"
				_cQrySFT += " ON B1_FILIAL        = ?"
				_cQrySFT += " AND B1_COD          = FT_PRODUTO"
				_cQrySFT += " AND SB1.D_E_L_E_T_  = ?"
			EndIf 
			_cQrySFT += " WHERE FT_FILIAL     = ?"
			_cQrySFT += " AND FT_TIPOMOV      = ?"
			_cQrySFT += " AND FT_CLIEFOR      = ?"
			_cQrySFT += " AND FT_LOJA         = ?"
			_cQrySFT += " AND FT_SERIE        = ?"
			_cQrySFT += " AND FT_NFISCAL      = ?"
			_cQrySFT += " AND FT_IDENTF3      = ?"
			_cQrySFT += " AND SFT.D_E_L_E_T_  = ?"
		EndIf 
		aBind := {}
		If cMvEstado $ "SP"  .And. lCroutSP .And. lPosIPI
			AADD(aBind,xFilial("SB1"))
			AADD(aBind,Space(1))
		EndIf
		AADD(aBind,xFilial("SFT"))
		AADD(aBind,cTipoMov)
		AADD(aBind,(cAliasSF3)->F3_CLIEFOR)
		AADD(aBind,(cAliasSF3)->F3_LOJA)
		AADD(aBind,(cAliasSF3)->F3_SERIE)
		AADD(aBind,(cAliasSF3)->F3_NFISCAL)
		AADD(aBind,(cAliasSF3)->F3_IDENTFT)
		AADD(aBind,Space(1))
		dbUseArea(.T.,'TOPCONN',TcGenQry2(,,_cQrySFT,aBind),cAliasSFT,.T.,.F.)

			While (cAliasSFT)->(!Eof())
			   	lAchouD1D2 := .F.
			   	lAchouF4   := .F.
			   	lIncsol    := .F.
				lChk13906  := .F.
			   	
			   	// Posicionando D2 ou D2 conforme a operacao.					                
				If cTipoMov == "E"
					lAchouD1D2 := SD1->(MsSeek(xFilial("SD1")+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM)))
	     		Else
					lAchouD1D2 := SD2->(MsSeek(xFilial("SD2")+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM)))
		     	EndIf
		     	
		     	// Se encontrou D1 ou D2 posiciono a SF4.
		     	If lAchouD1D2		     	
		     		lAchouF4 := SF4->(MsSeek(xFilial("SF4")+IIf(cTipoMov == "E", SD1->D1_TES, SD2->D2_TES)))		     	
		     	EndIf
				
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥Verifica se as informacoes referente ao campo CREDST serao    |
				//≥consideradas da tabela SF3 ou SFT.                            |
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				If lResF3FT
					
					IF (cAliasSFT)->FT_ICMSRET > 0 .or. (cAliasSFT)->FT_OBSSOL > 0		
						CFC->(dbSetOrder(1))					 
						IF CFC->(dbSeek(xFilial("CFC")+ cMvEstado	 +(cAliasSFT)->FT_ESTADO+(cAliasSFT)->FT_PRODUTO)) .And. CFC->CFC_PRECST =='2';
								.And. (cAliasSFT)->FT_TIPOMOV == "S"  .And. (cAliasSFT)->FT_CREDST <> "4" .And. (cAliasSFT)->FT_ESTADO$cMV_StUfS                       
							nPosRecST := Ascan( aRecStDif , { |x| x[1] == cMvEstado .And. x[2] == (cAliasSFT)->FT_ESTADO } )
							IF nPosRecST > 0
								aRecStDif[nPosRecST][03] := Iif((cAliasSFT)->FT_ICMSRET>0, (cAliasSFT)->FT_ICMSRET, (cAliasSFT)->FT_OBSSOL)
							Else
								Aadd(aRecStDif, {cMvEstado,(cAliasSFT)->FT_ESTADO,IIf((cAliasSFT)->FT_ICMSRET>0, (cAliasSFT)->FT_ICMSRET, (cAliasSFT)->FT_OBSSOL)})
							EndIf
						EndIf
					EndIf
	
					Aadd(aResF3FT, {(cAliasSFT)->FT_FILIAL,;  	//01
									 (cAliasSFT)->FT_NFISCAL,; 	//02
									 (cAliasSFT)->FT_SERIE,;   	//03
									 (cAliasSFT)->FT_CLIEFOR,; 	//04
									 (cAliasSFT)->FT_LOJA,;    	//05
									 (cAliasSFT)->FT_TIPOMOV,; 	//06
									 (cAliasSFT)->FT_IDENTF3,; 	//07
									 Iif(lPosCredST,(cAliasSFT)->FT_CREDST,""),;	//08									 
									 (cAliasSFT)->FT_BASERET,; 	//09
									 Iif((cAliasSFT)->FT_ICMSRET>0, (cAliasSFT)->FT_ICMSRET, (cAliasSFT)->FT_OBSSOL),; //10
									 Iif(lPosFecpST,(cAliasSFT)->FT_VFECPST,0),; 	//11
									 Iif(lPosSolTrb,(cAliasSFT)->FT_SOLTRIB,0),; 	//12 
									 Iif(lPosCrprST,(cAliasSFT)->FT_CRPRST,0),;  	//13									  
									 RetValFecp( Iif(lFTVFESTRN, (cAliasSFT)->FT_VFESTRN ,0)  , Iif(lFTVALFECP,(cAliasSFT)->FT_VFECPST,0) ),;	//14
									 (cAliasSFT)->FT_PRODUTO,;	//15
									 (cAliasSFT)->FT_ITEM,; //16	  
									 (cAliasSFT)->FT_TIPO}) //17
										 
					If cTipoMov == "E" .And. lAchouD1D2 .And. cMvEstado$"PR/RS/SC"
						lGetVlICMSD1 := .T.
						Aadd(aResF3D1, {SD1->D1_VALICM}) // 1 - Valor do ICMS(SD1)											
					EndIf
					
				EndIf
				
				// Abaixo sao valores que dependem da SD1/SD2 e SF4 posicionadas.
				If lAchouD1D2 .And. lAchouF4

					cF4EsCrPr	:=	SF4->F4_ESCRDPR
					
					// Tratamento exclusivo para GIARS
					If lGiaRs 
			   			lIncsol := SF4->F4_INCSOL$'S'
			   		EndIf
			   		
			   		// Variaveis alimentadas nas operacoes de entrada.
					If cTipoMov == "E"
						
						// Totalizando os valores de IPI.
						If cImp == "IP"
							
							// Quando F4_IPI == 'R' o valor eh totalizado na posicao 136 do aApuracao.
							aApuracao[nPos,04] += IIf(SF4->F4_IPI == "R", 0, (cAliasSFT)->FT_VALIPI) 
							// Valores de IPI nao atacadista
							If lF4IPIPECR .And. lF4TXAPIPI									
								If SF4->F4_IPI == "R" .And. Empty(SF4->F4_IPIPECR) .And. Empty(SF4->F4_TXAPIPI)
									aApuracao[nPos,136]  += (cAliasSFT)->FT_VALIPI
								EndIf								
								If !Empty(SF4->F4_IPIPECR) .And. !Empty(SF4->F4_TXAPIPI)
									AADD(aMensIPI,{SF4->F4_IPIPECR,SF4->F4_TXAPIPI,(cAliasSFT)->FT_VALIPI, Alltrim((cAliasSFT)->FT_CFOP) })
								Endif							
							EndIf
							
						EndIf						
						
						//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
						//≥ Alimentar AAPURACAO, posiÁ„o 75,76,77,78,79 ≥
						//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ	
						If (cAliasSF3)->F3_ICMSCOM > 0 .And. (cAliasSFT)->FT_ICMSCOM > 0 .And. Alltrim((cAliasSFT)->FT_CFOP) $ "291/197/2551/2552/2556/2557" .And. (cAliasSFT)->FT_VALICM == 0
							nValicm += (cAliasSFT)->FT_VALICM
							nIcmscom1 += (cAliasSFT)->FT_ICMSCOM
							If SF4->F4_DSPRDIC == "3" .Or. SF4->F4_DESPICM == "2"
								nValcont1 += nF3VALCONT - (cAliasSFT)->FT_DESPESA
							Else
								nValcont1 += nF3VALCONT
							EndIf
							nIsenicm += (cAliasSFT)->FT_ISENICM
						EndIf
						
					EndIf
					
					// Variaveis alimentadas nas operacoes de saida.
					If cTipoMov == "S"					
						If cImp == "IP"
							aApuracao[nPos,04] += IIf(SF4->F4_IPI == "R" .And. !(SF4->F4_LFIPI$"T") .And. SF4->F4_CONSUMO == "N" , 0, (cAliasSFT)->FT_VALIPI) //aApuracao[nPos,04] += (cAliasSFT)->FT_VALIPI							
						EndIf					
					EndIf
				
				EndIf

				If	lApGIEFD
					If F3K->(MsSeek(xFilial("F3K")+(cAliasSFT)->(FT_PRODUTO+FT_CFOP)))          			
						ApurCDV(cAliasSF3,@aApurCDV,lMVRF3THRE)                	   		
					Endif
				EndIf

				//Fundo de ProteÁ„o Social de Goi·s ñ PROTEGE
				If lFTValPro .AND. ((cAliasSFT)->FT_VALPRO > 0) .AND. lMvGerProt
					aApuracao[ nPos , 51 ]  += (cAliasSFT)->FT_VALPRO
				EndIf
				
				If !(lFTValPro .AND. lMvGerProt) .And. cTipoMov == "S" .And. ( cAliasSF3 )->F3_ESTADO == "GO" .And. !(cMvEstado $ "GO")
					If CD2->(MsSeek( xFilial( "CD2" ) + "S" + (cAliasSFT)->( FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO+"SOL" ) ) ) .And. CD2->CD2_PREDBC > 0
						
						nVlrBase := (CD2->CD2_BC*100) / CD2->CD2_PREDBC
						nICMAliq := CD2->CD2_ALIQ

						nDifVlr := ( (nVlrBase * nICMAliq/100) - (cAliasSFT)->FT_VALICM ) - CD2->CD2_VLTRIB

						//Fundo de ProteÁ„o Social de Goi·s ñ PROTEGE
						aApuracao[ nPos , 51 ]	+= nDifVlr * 15 / 100

					EndIf
				EndIf			
				
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥Credito Outorgado SP - Decreto 56.018 de 16/07/2010, | 
				//|o Decreto 56.855, de 18 .03.2011 e o                 |
				//|Decreto 56.874, de 23.03.2011  (P9AutoText)   		≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				If cMvEstado $ "SP"  .And. lCroutSP .And. (cAliasSFT)->FT_CROUTSP > 0 .And. lPosIPI

						If  Substr((cAliasSFT)->B1_POSIPI,1,4) $ cCredOut .And. !Substr((cAliasSFT)->B1_POSIPI,1,4)$"0401/0403/4410/4411/1601/1602"					   																
							aApuracao[nPos,86] += (cAliasSFT)->FT_CROUTSP
							//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
							//≥Conforme Art.31 do Anexo III do RICMS os NCMs 1601/1602 devem         ≥
							//≥ser considerados na apuracao quando existir um documento de entrada,  ≥
							//≥para as demais situacoes o Credito Outorgado nao deve ser considerado,≥
							//≥alinhado com a equipe de legislacao.                                  ≥
							//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ							
						ElseIf (Substr((cAliasSFT)->B1_POSIPI,1,4)$ "1601/1602" .And. cTipoMov == "E") 
							aApuracao[nPos,86] += (cAliasSFT)->FT_CROUTSP
						Elseif  Substr((cAliasSFT)->B1_POSIPI,1,4)=="0401"			 
							aApuracao[nPos,97] += (cAliasSFT)->FT_CROUTSP
						Elseif 	Substr((cAliasSFT)->B1_POSIPI,1,4)=="0403"				                                               
							aApuracao[nPos,98] += (cAliasSFT)->FT_CROUTSP 
						Elseif  Substr((cAliasSFT)->B1_POSIPI,1,4)$"4410/4411"
							aApuracao[nPos,99] += (cAliasSFT)->FT_CROUTSP
						Endif

				EndIf
				
				If lFtValFEEF .And. (cAliasSFT)->FT_VALFEEF > 0
					If cTipoMov == 'E' .and. (cAliasSFT)->FT_TIPO == 'D' //Entrada e DevoluÁ„o
						aApuracao[ nPos , 143 ]  += (cAliasSFT)->FT_VALFEEF
					ElseIf cTipoMov == 'S'
						aApuracao[ nPos , 139 ]  += (cAliasSFT)->FT_VALFEEF
					EndIf
				EndIf

				IF lConv13906 .And. (cAliasSFT)->FT_CV139 == "1"
					lChk13906 := .T.
				EndIf

				// ********************** PERNAMBUCO (PE) *****************************
				//Credito Presumido - PE - Art. 6 Decreto n28.247 (P9AutoText)
				If cMvEstado$"PE"
					 If lFTCRPREPE
						aApuracao[ nPos , 66 ]	+=	(cAliasSFT)->FT_CRPREPE   // Cred Pres. Art. xxx
					Endif
					If lFTCPPRODE .And. lFTTPPRODE
						//processa nota internas com credito de importaÁ„o
						IF (cAliasSFT)->FT_TIPOMOV == "S" .AND. (cAliasSFT)->FT_CPPRODE > 0 .And. (cAliasSFT)->FT_TPPRODE == "6" .AND. Substr( Alltrim( aApuracao[ nPos , 01 ] ) , 1 , 1 ) $ "5" 
							nImport  :=	GiafEntPrd((cAliasSFT)->FT_PRODUTO, (cAliasSFT)->FT_QUANT, Stod((cAliasSFT)->FT_EMISSAO),AllTrim(cNrLivro))
							nAliqIcm := (cAliasSFT)->FT_ALIQICM
							nLimite  := 0
							Do Case
								Case nAliqIcm <= 7
									nLimite += nImport * 0.035
								Case nAliqIcm > 7 .and. nAliqIcm <= 12
									nLimite += nImport * 0.06
								Case nAliqIcm > 12 .and. nAliqIcm <= 18
									nLimite += nImport * 0.08
								Case nAliqIcm > 18 
									nLimite += nImport * 0.10
							EndCase

							//Quando calculado na nota for superior a importaÁ„o utiliza a importaÁ„o
							If (cAliasSFT)->FT_CPPRODE > nLimite
								aApuracao[ nPos , 144 ] += nLimite
							Else
								aApuracao[ nPos , 144 ] += (cAliasSFT)->FT_CPPRODE
							Endif
						Endif

						If (cAliasSFT)->FT_TIPOMOV == "S"
							Do Case
								Case (cAliasSFT)->FT_TPPRODE == "1"
									aApuracao[ nPos , 90 ] -= (cAliasSFT)->FT_CPPRODE   //  Cred Pres Propede 
								Case (cAliasSFT)->FT_TPPRODE == "2"
									aApuracao[ nPos , 91 ] -= (cAliasSFT)->FT_CPPRODE   //  Cred Pres Propede
								Case (cAliasSFT)->FT_TPPRODE == "3"
									aApuracao[ nPos , 92 ] -= (cAliasSFT)->FT_CPPRODE   //  Cred Pres Propede
								Case (cAliasSFT)->FT_TPPRODE == "4"
									aApuracao[ nPos , 93 ] += (cAliasSFT)->FT_CPPRODE   //  Cred Pres Propede
								Case (cAliasSFT)->FT_TPPRODE == "5"
									aApuracao[ nPos , 94 ] -= (cAliasSFT)->FT_CPPRODE   //  Cred Pres Propede
								Case (cAliasSFT)->FT_TPPRODE == "6" .and. Substr( Alltrim( aApuracao[ nPos , 01 ] ) , 1 , 1 ) $ "6"
									aApuracao[ nPos , 95 ] -= (cAliasSFT)->FT_CPPRODE   //  Cred Pres Propede
							EndCase
						Else
							Do Case
								Case (cAliasSFT)->FT_TPPRODE == "1"
									aApuracao[ nPos , 90 ] += (cAliasSFT)->FT_CPPRODE   //  Cred Pres Propede
								Case (cAliasSFT)->FT_TPPRODE == "2"
									aApuracao[ nPos , 91 ] += (cAliasSFT)->FT_CPPRODE   //  Cred Pres Propede
								Case (cAliasSFT)->FT_TPPRODE == "3"
									aApuracao[ nPos , 92 ] += (cAliasSFT)->FT_CPPRODE   //  Cred Pres Propede
								Case (cAliasSFT)->FT_TPPRODE == "4"
									aApuracao[ nPos , 93 ] -= (cAliasSFT)->FT_CPPRODE   //  Cred Pres Propede
								Case (cAliasSFT)->FT_TPPRODE == "5"
									aApuracao[ nPos , 94 ] += (cAliasSFT)->FT_CPPRODE   //  Cred Pres Propede
								Case (cAliasSFT)->FT_TPPRODE == "6" .And. Substr( Alltrim( aApuracao[ nPos , 01 ] ) , 1 , 1 ) $ "6"
									aApuracao[ nPos , 95 ] += (cAliasSFT)->FT_CPPRODE   //  Cred Pres Propede
							EndCase
						EndIf
					Endif
				EndIf

					
				(cAliasSFT)->(DbSkip())
				
			EndDo
			(cAliasSFT)->(dbCloseArea())

		aApuracao[nPos,75]	:=nValicm
		aApuracao[nPos,76]	:=nIcmscom1
		aApuracao[nPos,77]	:=nValcont1
		aApuracao[nPos,78]	:=nIsenicm
		aApuracao[ nPos , 133]  := lProRurPj //lProRurPf AlteraÁ„o com base na solicitaÁ„o 261149 - Consultoria Tribut·ria Totvs
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Estorno de Credito/Debito                                    ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ		
		If lPosEstCred //AlteraÁ„o referente a solicitaÁ„o descrita na issue DSERFIS1-17118
			If Left(Alltrim((cAliasSF3)->F3_CFO),1)$"567"
				aApuracao[nPos,47] += (cAliasSF3)->F3_ESTCRED // Estorno de Credito
			ElseIf Left(Alltrim((cAliasSF3)->F3_CFO),1)$"123"
				aApuracao[nPos,49] += (cAliasSF3)->F3_ESTCRED // Estorno de Debito
			EndIf	
	    EndIf              	            

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥  Implementacao no P9AutoText do GO                           ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
    	If  cMvEstado=="GO" .And. (Alltrim((cAliasSF3)->F3_ESPECIE)== "NFCEE" .Or. Alltrim((cAliasSF3)->F3_ESPECIE)== "NTSC" .Or. Alltrim((cAliasSF3)->F3_ESPECIE)== "NFSC") .And. Left(Alltrim((cAliasSF3)->F3_CFO),1)$"5"
			aApuracao[nPos,51] += (cAliasSF3)->F3_BASEICM
			aApuracao[nPos,52] += (cAliasSF3)->F3_BASERET
	    Endif
	    //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥  FECOP P9AutoText do CE			                             ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ  
		If cMvEstado=="CE" .And. (cAliasSF3)->F3_ESTADO == "CE" 
			If SubStr((cAliasSF3)->F3_CFO,1,1) >= "5"
				If SFT->(MsSeek(xFilial("SFT")+"S"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
					If SD2->(MsSeek(xFilial("SD2")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))
						If SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)) .And. lB1FECOP .And. lB1ALFECOP
							If SB1->B1_FECOP == "1" .And. SB1->B1_ALFECOP > 0
								If SB1->B1_ALFECOP == 19
									aApuracao[nPos,68] += (cAliasSF3)->F3_VALICM
								ElseIf SB1->B1_ALFECOP == 27
									aApuracao[nPos,69] += (cAliasSF3)->F3_VALICM
								EndIf
							Endif
						EndIf
					EndIf
				EndIf
			EndIf
			
			If SubStr((cAliasSF3)->F3_CFO,1,1) >= "5"
				If SFT->(MsSeek(xFilial("SFT")+"S"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
					If SD2->(MsSeek(xFilial("SD2")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))
						If SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)) .And. lB1FECOP .And. lB1ALFECST
							If SB1->B1_FECOP == "1" .And. SB1->B1_ALFECST > 0
								If SB1->B1_ALFECST == 19
									aApuracao[nPos,70] += (cAliasSF3)->F3_ICMSRET
								ElseIf SB1->B1_ALFECST == 27
									aApuracao[nPos,71] += (cAliasSF3)->F3_ICMSRET
								EndIf
							Endif
						EndIf
					EndiF
				EndIf
			EndIf
	    EndIf
//FECP	    
	    If (cMvEstado$"RJ" .And. SubStr((cAliasSF3)->F3_CFO,1,1) < "3")
			SFT->(dbSetOrder(3))
			If (SFT->(MsSeek(xFilial("SFT")+"E"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT)))
				lEntFec := .T.  
			Endif
		Elseif (cMvEstado$"RJ" .And. SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) > "4" .And. (cAliasSF3)->F3_TIPO $ "D/B") 
			SFT->(dbSetOrder(3))
			If (SFT->(MsSeek(xFilial("SFT")+"S"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT)))
				lSaiFec := .T.  			
			Endif
		Endif
		If lEntFec .Or. lSaiFec
			If SFT->FT_ALQFECP > 0 .Or. (lFTALFCCMP .And. SFT->FT_ALFCCMP > 0)
				If lFTTES .And. !Empty(SFT->FT_TES)
					cSdTes := SFT->FT_TES
				Else				
					If lEntFec			
						SD1->(dbSetOrder(1))
						If SD1->(MsSeek(xFilial("SD1")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))
							cSdTes	:= SD1->D1_TES
						Endif	
					Else
						SD2->(DbSetOrder(3))				
						If SD2->(MsSeek(xFilial("SD2")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))
							cSdTes	:= SD2->D2_TES
						Endif	
					Endif						
				Endif	
				If !Empty(cSdTes)
					SF4->(dbSetOrder(1))
					If SF4->(MsSeek(xFilial("SF4")+cSdTes))
						If SF4->F4_COMPL=="S" .And. (cAliasSF3)->F3_ESTADO <> "RJ" .And.  (SF4->F4_CONSUMO == "S" .Or. ( SF4->F4_LFICM == "O" .And. SF4->F4_CONSUMO == "O" ) )
							aApuracao[nPos,73]+= (cAliasSF3)->F3_VALFECP		//(cAliasSF3)->F3_BASEICM * (SFT->FT_ALQFECP /100)
							aApuracao[nPos,10]-=(cAliasSF3)->F3_VALFECP
						EndIf
					Endif	
				Endif	
			EndIf
    	Endif
    	

		//Tratamento credito acumulado //#vitor01 - Se estiver preenchido o credito acumulado e n„o for a opÁ„o n„o se aplica (3)
		If lNWCredAcu .And. !Empty((cAliasSF3)->F3_CREDACU) .And. (cAliasSF3)->F3_CREDACU <> "3"
			If (Alltrim((cAliasSF3)->F3_TIPO) <> "D" .And. Alltrim((cAliasSF3)->F3_CFO) >= '5') .Or. Alltrim((cAliasSF3)->F3_TIPO) == "D" .And. Alltrim((cAliasSF3)->F3_CFO) <= '3'
				// Verifica se o tipo do credito acumulado j· est· no array
				nPoscred := Ascan(aNWCredAcu,{|x| x[1] == (cAliasSF3)->F3_CREDACU })
				
				// Se n„o tiver
				If Empty(nPoscred)
					// Adiciona a nova posiÁ„o
					Aadd(aNWCredAcu,{(cAliasSF3)->F3_CREDACU,0})
					nPoscred := Len(aNWCredAcu)
				Endif

				If Alltrim((cAliasSF3)->F3_TIPO) <> "D" .And. Alltrim((cAliasSF3)->F3_CFO) >= '5'
					// Soma os valores
					aNWCredAcu[nPoscred][2] += (cAliasSF3)->(F3_ISENICM+F3_OUTRICM)
				ElseIf Alltrim((cAliasSF3)->F3_TIPO) == "D" .And. Alltrim((cAliasSF3)->F3_CFO) <= '3'
					// Subtrai os valores
					aNWCredAcu[nPoscred][2] -= (cAliasSF3)->(F3_ISENICM+F3_OUTRICM)
				EndIf
			EndIf
		Endif

		If cMvEstado$"BA" .And. SubStr((cAliasSF3)->F3_CFO,1,1) < "3"  
	    	SFT->(dbSetOrder(3))  
	    	SD1->(dbSetOrder(1))
   	 		If SFT->(MsSeek(xFilial("SFT")+"E"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
				If SD1->(MsSeek(xFilial("SD1")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))
					If SFT->FT_ALQFECP > 0 .Or. (lFTALFCCMP .And. SFT->FT_ALFCCMP > 0)
						SF4->(dbSetOrder(1))
					    If SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES))
							If SF4->F4_COMPL=="S" .And. (cAliasSF3)->F3_ESTADO <> "BA" .And.  (SF4->F4_CONSUMO = "S" .Or. ( SF4->F4_LFICM = "O" .And. SF4->F4_CONSUMO = "O" ) )
								aApuracao[nPos,73] += (cAliasSF3)->F3_VALFECP		//(cAliasSF3)->F3_BASEICM * (SFT->FT_ALQFECP /100)
								aApuracao[nPos,10] -= (cAliasSF3)->F3_VALFECP
							EndIf
						EndIf
    				EndIf
    			EndIf
    		EndIf
    	EndIf
    	
    	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥  FUMACOP P9AutoText do MA			                         ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ  
    	If cMvEstado=="MA"
			If Substr((cAliasSF3)->F3_CFO,1,1) >= "5"
				If lPosValFum
	    			If (cAliasSF3)->F3_VALFUM > 0
	    				aApuracao[nPos,83] += (cAliasSF3)->F3_VALFUM
	    			Endif
				Endif
	    	Endif
	    EndIf 	

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Credito Presumido/RJ/PR/CE                                   ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If cMvEstado$"PR"              
		    //Tratamento para Estorno de Credito Presumido do PR atraves do uso de Rastro (Lote)
		    //Venda fora do estado - Zona franca n„o permite estorno
		    //Nota fiscal origem deve ser de importacao
		    If lESTCRPR
				If (Left(Alltrim((cAliasSF3)->F3_CFO),1)$"6" .And. (cAliasSF3)->F3_ESTADO<>"AM") .Or. (cAliasSF3)->F3_TIPO=="D"
					aApuracao[nPos,130]	+= EstCrePres(cAliasSF3,cMvEstado,2,dDtIni,dDtFim,cNCMESTC,dDTCOREC)
				Endif
			Endif
			//			
    		If Left(Alltrim((cAliasSF3)->F3_CFO),1)$"3"    	
				aApuracao[nPos,34] += (cAliasSF3)->F3_CRDPRES
            EndIf
    	ElseIf cMvEstado$"CE" .AND. Alltrim((cAliasSF3)->F3_ESPECIE)$"CTR/CTA/CTF/CTE/NFST"
			aApuracao[nPos,122]:= (cAliasSF3)->F3_CRDPRES
		ElseIF (cAliasSF3)->F3_TIPO<>"D"
			aApuracao[nPos,34] += (cAliasSF3)->F3_CRDPRES
		Endif
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Estorno CrÈdito ICMS de ImportaÁ„o	                         ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If cMvEstado$"PE" .And. lEstCreImp .And. Substr((cAliasSF3)->F3_CFO,1,1)$"5|6"
			aApuracao[nPos,134] += EstCreImp(cAliasSF3,cMvEstado,dDtIni,dDtFim,cNCMESTC)
		Endif
		IF ( cAliasSF3 )->F3_TIPO == "D" 
			aApuracao[nPos,131]	+=	(cAliasSF3)->F3_CRDPRES					
		EndIF
		If lPosCrdPct	
			aApuracao[nPos,111] += (cAliasSF3)->F3_CRDPCTR
		EndIf
		
		If lPosCrdPre		
			aApuracao[nPos,112] += (cAliasSF3)->F3_CREDPRE
		EndIf		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ MAterial Recicl·vel     ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If cMvEstado=="SP" .And. SubStr((cAliasSF3)->F3_CFO,1,1) < "5"
			If SFT->(MsSeek(xFilial("SFT")+"E"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
	    		If SD1->(MsSeek(xFilial("SD1")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))
					If lPosPrdRec .And. SB1->(MsSeek(xFilial("SB1")+SD1->D1_COD))
						If SB1->B1_PRODREC$"1S" 
							aApuracao[nPos,84] += (cAliasSF3)->F3_VALICM
						Endif
					Endif
				Endif
			Endif
		Endif		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥  Implementacao no P9AutoText do MT                           ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
    	If  cMvEstado=="MT" .And. (Alltrim((cAliasSF3)->F3_OBSERV)== "ICMS GARANTIDO") .And. Left(Alltrim((cAliasSF3)->F3_CFO),1)<"5"
			aApuracao[nPos,81] += (cAliasSF3)->F3_VALANTI
		ELSEIF cMvEstado=="MT" .And. (Alltrim((cAliasSF3)->F3_OBSERV)== "ICMS GARANTIDO") .And. Left(Alltrim((cAliasSF3)->F3_CFO),1)>"4"
			aApuracao[nPos,82] += (cAliasSF3)->F3_VALANTI
		ENDIF        
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Credito Presumido - PR - RICMS (Art.4) Anexo III             ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If cMvEstado$"PR" .And. lPosCrpRep
			aApuracao[nPos,55] += (cAliasSF3)->F3_CRPREPR
		EndIf			
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Cred. Presumido-art.631-A do RICMS/2008                      ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If cMvEstado$"PR" .And. lPosCrpEsp
			aApuracao[nPos,72] += (cAliasSF3)->F3_CPRESPR
		EndIf				
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Credito Presumido - RO - RICMS (Art.39) Anexo IV             ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If cMvEstado$"RO" .And. lPosCrpRer .And. (cAliasSF3)->F3_TIPO<>"D"
			aApuracao[nPos,64] += (cAliasSF3)->F3_CRPRERO
		Elseif cMvEstado$"RO" .And. lPosCrpRer .And. (cAliasSF3)->F3_TIPO=="D"
			aApuracao[nPos,101] += (cAliasSF3)->F3_CRPRERO 
		EndIf		    
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Credito Presumido - Decreto 52.586 de 28.12.2007 (P9AutoText) ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If cMvEstado$"SP" .And. lPosCrpRes
			aApuracao[nPos,82] += (cAliasSF3)->F3_CRPRESP
		Else
			aApuracao[nPos,82] := 0	
		EndIf		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Credito Outorgado - GO Inc.III, Art 11 Anexo IX - RCTE-GO/97   ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If	lFTValPro .AND. lMvGerProt
		 	
		 	//Credito Outorgado - GO Inc.III, Art 11 Anexo IX - RCTE-GO/97		 	                  
        	If lCROutGO .And. (cAliasSF3)->F3_CROUTGO >0
            	aApuracao[nPos,110] += (cAliasSF3)->F3_CROUTGO
         	EndIf
			
			// Totalizo o PROTEGE recolhido na emissao do(s) documento(s) - Apenas 1x por NF.      		
	      	If SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) >= "5" .And. lNewNF
	      		If SF2->(MsSeek(xFilial("SF2")+(cAliasSF3)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)))
		      		SF6->(DbSetOrder(3)) // F6_FILIAL+F6_OPERNF+F6_TIPODOC+F6_DOC+F6_SERIE+F6_CLIFOR+F6_LOJA
					If SF6->( MsSeek( xFilial( "SF6" ) + "2" + PadR(SF2->F2_TIPO, nTamTpDoc) + ( cAliasSF3 )->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA) ) )
						While !SF6->(Eof()) .AND. xFilial("SF6") == SF6->F6_FILIAL .AND. SF6->F6_OPERNF == "2" .And. SF6->F6_TIPODOC == PadR(SF2->F2_TIPO,nTamTpDoc) .AND.; 
							SF6->(F6_DOC+F6_SERIE+F6_CLIFOR+F6_LOJA) == ( cAliasSF3 )->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA) 
							If SF6->F6_TIPOIMP == "C"  								
								aApuracao[ nPos , 141 ]	+=	SF6->F6_VALOR								
							EndIf
							SF6->(dbSkip())
						EndDo								
					EndIf
					SF6->(DbSetOrder(1)) // F6_FILIAL+F6_EST+F6_NUMERO
				EndIf				
			EndIf
			
       ElseIf cMvEstado$"GO" 
			nCrOutPrtg := 0
			nRedPrtg	:= 0

			//Credito Outorgado - GO Inc.III, Art 11 Anexo IX - RCTE-GO/97					
			If (cAliasSF3)->F3_CROUTGO > 0
				aApuracao[nPos,110] += (cAliasSF3)->F3_CROUTGO
				
				//Calculo Protege
				nCrOutPrtg:= (cAliasSF3)->F3_CROUTGO * 15 / 100 
			Else
				aApuracao[nPos,110] += 0	
			EndIf 
			
			//ReduÁ„o da Base do ICMS 
			If (cAliasSF3)->F3_BASEICM > 0 .And. ((cAliasSF3)->F3_OUTRICM > 0 .Or. (cAliasSF3)->F3_ISENICM > 0 )

				nVlrBase := (cAliasSF3)->F3_BASEICM + (cAliasSF3)->F3_OUTRICM + (cAliasSF3)->F3_ISENICM
				nICMAliq := (cAliasSF3)->F3_ALIQICM
				
				nDifVlr := (nVlrBase * nICMAliq/100) - (cAliasSF3)->F3_VALICM
				
				//Calculo Protege
				nRedPrtg:= nDifVlr * 15 / 100	
			EndIf	
			
			//Fundo de ProteÁ„o Social de Goi·s ñ PROTEGE	Goi·s		
			aApuracao[ nPos , 51 ]	+= nCrOutPrtg + nRedPrtg

		EndIf	

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥CrÈdito outorgado-art.11, anexo III, RICMS/SP		|
		//≥IntegraÁ„o com TMS        							| 	
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If cMvEstado$"SP" .And. Substr((cAliasSF3)->F3_CFO,1,1) >= "5" .And. Alltrim((cAliasSF3)->F3_ESPECIE)== "CTR" .and. _INTTMS ///IntTms()
			If aFindFunc[FF_VLDMTR928]
				If VldMTR928(cAliasSF3,lQuery)
		 			aApuracao[nPos,102] += Round(((cAliasSF3)->F3_VALICM + (cAliasSF3)->F3_ICMSRET) * nPercCrOut , 2 )
				Endif
			Endif
		Endif		
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ ICMS Retido Fonte - PB-RICMS Anexo 46                        ≥
		//|                                                              |
		//|AO ALTERAR ESTE IF, ALTERAR TAMBEM O SPED FISCAL, POIS TEM UMA|
		//|       COPIA DESTE TRATAMENTO NA FUNCAO APURADOC()            |
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ		
		If Substr((cAliasSF3)->F3_CFO,1,1) >= "5"
			SA1->(MsSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			
			If cMvEstado$"PB" .And. lPosRegPb  
				If SA1->A1_REGPB == "1"
		   			aApuracao[nPos,67] += (cAliasSF3)->F3_ICMSRET    
		   			aApuracao[nPos,08] -= (cAliasSF3)->F3_ICMSRET 
		   		Endif	
	   		EndIf	
		EndIf				    
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ SIMPLES - SC                                                 ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		aApuracao[nPos,36] += (cAliasSF3)->F3_SIMPLES
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Implementacao no P9AutoText do RJ                            ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If lRegEsp
			If Left(Alltrim((cAliasSF3)->F3_CFO),1)$"56" .And. (cAliasSF3)->F3_TIPO$"DB"
				aApuracao[nPos,35]	+=	nF3VALCONT	
			Endif
		Endif                                   
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Credito Presumido/RJ - Prestacoes de Servicos de Transporte  ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
    	If Left(Alltrim((cAliasSF3)->F3_CFO),1)$"567"
			aApuracao[nPos,37] += (cAliasSF3)->F3_CRDTRAN
	    Endif        
       	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Operacoes de Prazo Especial - RJ                             ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If SD2->(DBSeek(xFilial("SD2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
    		If SF4->(MsSeek(xFilial("SF4")+SD2->D2_TES))
        		If Left(Alltrim((cAliasSF3)->F3_CFO),1)$"5" .And. lPosPrzEsp .And.  SF4->F4_PRZESP$"S"
        			aApuracao[nPos,81] += (cAliasSF3)->F3_VALICM
       			Endif
			EndIf
		EndIf
        
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Credito Presumido/AM - Entradas Interestaduais na Zona Franca de Manaus  ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		aApuracao[nPos,38] += (cAliasSF3)->F3_CRDZFM
	    
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥valor Credito Presumido Substituicao Tributaria retido pelo contratante do servico de transporte - Decreto 44.147/2005 (MG)≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
    	If Left(Alltrim((cAliasSF3)->F3_CFO),1)$"123"
			aApuracao[nPos,39] += (cAliasSF3)->F3_CRPRST
	    Endif
	    
	    If lTransST
	    	If lPosValTst
		    	aApuracao[nPos,60] += (cAliasSF3)->F3_VALTST
		    EndIf	    	
	  	EndIf                     
	  		  	    
		//Valor CrÈdito Presumido nas operaÁıes de SaÌda com o ICMS destacado sobre os produtos resultantes da industrializaÁ„o com componentes, partes e pecas recebidos do exterior, destinados a fabricacao de produtos de informatica, eletronicos e telecomunicacoes, por estabelecimento industrial desses setores. Tratamento conforme Art. 1∫ do DECRETO 4.316 de 19 de Junho de 1995.(BA)
    	If lPosCprRel .And. Left(Alltrim((cAliasSF3)->F3_CFO),1)$"567" // Credito
			aApuracao[nPos,41] += (cAliasSF3)->F3_CRPRELE
		ElseIf lPosCprRel .And. Left(Alltrim((cAliasSF3)->F3_CFO),1)$"123" .And. "D"$(cAliasSF3)->F3_TIPO // Estorno do Credito
			aApuracao[nPos,45] += (cAliasSF3)->F3_CRPRELE
	    Endif
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Valor referente ao Fundersul - Mato Grosso do Sul≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If lPosValFDS       
			If Left(Alltrim((cAliasSF3)->F3_CFO),1) $ "1/5/6"
			    If Alltrim((cAliasSF3)->F3_TIPO)=="D"
			        aApuracao[nPos,44] -=(cAliasSF3)->F3_VALFDS
			    Else 
				    aApuracao[nPos,44] += (cAliasSF3)->F3_VALFDS  
			    EndIf
			Endif
		Endif

        //Senar
        If lF3VLSENAR        			                   
			If Alltrim((cAliasSF3)->F3_TIPO) $ "DB"
				//DSERFIS1-19238: Posiciono na SF3 da nota de origem para decidir se haver· deduÁ„o do valor de SENAR da apuraÁ„o, j· que a nota original pode n„o ter sido somada a apuraÁ„o
		
				SFT->(DbSetOrder(1))
				SFT->(MsSeek(xFilial("SFT")+Iif(Left(Alltrim((cAliasSF3)->F3_CFO),1)$"567", "S", "E")+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
			
				SF3->(DbSetOrder(5))
				SF3->(MsSeek(xFilial("SF3")+SFT->FT_SERORI+SFT->FT_NFORI+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))

				If Left(Alltrim(SF3->F3_CFO),1)$"567"
		
					SA1->(DbSetOrder(1))
					If cProRurPJ$"1" .Or. !((cProRurPJ$"1" .And. SA1->(MsSeek(xFilial("SA1")+SF3->(F3_CLIEFOR+F3_LOJA))) .And. SA1->A1_PESSOA$"F"))
						aApuracao[nPos, 85] -= (cAliasSF3)->F3_VLSENAR
					EndIf
				ElseIf Left(Alltrim(SF3->F3_CFO),1)$"12"
				
					SA2->(DbSetOrder(1))
					If !lJuridica .And. !(SA2->(MsSeek(xFilial("SA2")+SF3->(F3_CLIEFOR+F3_LOJA))) .And. (SA2->A2_TIPO$"F" .OR. (SA2->A2_TIPO$"J" .And. SA2->A2_TIPORUR$"F"))) 					
						aApuracao[nPos, 85] -= (cAliasSF3)->F3_VLSENAR
					EndIf
				EndIf		

			Else
				If Left(Alltrim((cAliasSF3)->F3_CFO),1)$"567"
				
					SA1->(DbSetOrder(1))
					If !cProRurPJ$"1" .Or. (cProRurPJ$"1" .And. SA1->(MsSeek(xFilial("SA1")+(cAliasSF3)->(F3_CLIEFOR+F3_LOJA))) .And. SA1->A1_PESSOA$"F")
						aApuracao[nPos,85] += (cAliasSF3)->F3_VLSENAR
					EndIf
				ElseIf Left(Alltrim((cAliasSF3)->F3_CFO),1)$"12"
					
					SA2->(dbSetOrder(1))
					If lJuridica .And. SA2->(MsSeek(xFilial("SA2")+(cAliasSF3)->(F3_CLIEFOR+F3_LOJA))) .And. (SA2->A2_TIPO$"F" .OR. (SA2->A2_TIPO$"J" .And. SA2->A2_TIPORUR$"F")) 					
						aApuracao[nPos,85] += (cAliasSF3)->F3_VLSENAR
					EndIf
				EndIf				  
			Endif
		Endif     
        //tratamento - remessa de venda para fora do estabelecimento (venda ambulante)
	    If cMvEstado=="SP" .And. (Alltrim((cAliasSF3)->F3_CFO)$"5904/6904")  
	        aApuracao[nPos,100]+= (cAliasSF3)->F3_VALICM		        
    	EndIf	            
     
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Credito Presumido Simples Nacional - SC                      ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If lPosCrpSim
			aApuracao[nPos,48] += (cAliasSF3)->F3_CRPRSIM
		Endif
		
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Antecipacao ICMS                                  			 ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
    	If SFT->(MsSeek(xFilial("SFT")+"E"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
	    	If SD1->(MsSeek(xFilial("SD1")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))
				SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES))                              
		       	If !(cMvEstado $ "SP")
				   	If lPosVarAta .And. !Empty(SF4->F4_VARATAC)
				   		If SF4->F4_VARATAC == "2"
				   			If lPosValAnt
				    	   		If lMesAnti
									aApuracao[nPos,50] := nVlrAnti
								Else
									aApuracao[nPos,50] += (cAliasSF3)->F3_VALANTI
								Endif
							Endif
				   	  	ElseIf SF4->F4_VARATAC == "1" 
				   		  		aApuracao[nPos,79] += (cAliasSF3)->F3_OBSSOL
				   		Endif				   			 
					Else
						If lPosValAnt
				    		If lMesAnti
								aApuracao[nPos,50] := nVlrAnti
							Else
								aApuracao[nPos,50] += (cAliasSF3)->F3_VALANTI
							Endif			 
						Endif
				    Endif
				Else
				   	If lPosVarAta  .And. !Empty(SF4->F4_VARATAC) 
				   		If lPosValAnt
			    	   		If lMesAnti
								aApuracao[nPos,50] := nVlrAnti
							Else
								aApuracao[nPos,50] += (cAliasSF3)->F3_VALANTI
			   				Endif 
			   			Endif
				   Else
				   		If lPosValAnt
				    		If lMesAnti
								aApuracao[nPos,50] := nVlrAnti
							Else
								aApuracao[nPos,50] += (cAliasSF3)->F3_VALANTI
							Endif
						Endif			 
				    Endif
				EndIf				
	       Endif
	    Endif 
	            
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Credito Acumulado de ICMS - Bahia                 			 ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
    	If lUfBA .And. lCredAcu
			aApuracao[nPos,62] := aCredAcu[1] //Exportacoes
			aApuracao[nPos,63] := aCredAcu[2] //Outras hipoteses
		Else
			aApuracao[nPos,62] := 0
			aApuracao[nPos,63] := 0
	    Endif	  
	    
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Fust / Funttel                                               ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
   	   	If nFust > 0 .Or. nFunttel > 0
	   		aApuracao[nPos,53] := ((nRecBrut*nFust)/100) //Fust
	   		aApuracao[nPos,54] := ((nRecBrut*nFunttel)/100)//Funttel
		Else	
			aApuracao[nPos,53] := 0 //Fust
			aApuracao[nPos,54] := 0 //Funttel
	    Endif
	    	    
	  	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Parag. 16, Art.23 RICMS/PR - SN (Utilizar P9AUTOTEXT.PR) 			  ≥
		//≥CrÈdito aquisiÁ„o Optantes do Simples Nacional (Utilizar P9AUTOTEXT.RS)≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	    If cMvEstado$"PR/RS/SC"
	    	If SubStr((cAliasSF3)->F3_CFO,1,1)$"12"
		    	If SFT->(MsSeek(xFilial("SF3")+"E"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
			    	If SD1->(MsSeek(xFilial("SD1")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))
						If SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES))
							If SF4->F4_ICM == "S" .AND. SF4->F4_CREDICM == "S" .AND. SF4->F4_LFICM == "O"
								If SA2->(MsSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
									If lPosSimNac .And. SA2->A2_SIMPNAC$"1S"
										If lGetVlICMSD1 .And. Len(aResF3D1) > 0                            
											For nX := 1 to Len(aResF3D1)
												aApuracao[nPos,108]	+= aResF3D1[nX][1]
											Next nX
										Else		   						
											aApuracao[nPos,108]	+=	SD1->D1_VALICM
										EndIf
									Endif
								EndIf	  
							Endif
						EndIf		   				
			   				
						//VAlor de exclus„o de ICMS ST na Guia B do Rioa Grande do SUl
						IF lF4MKPCMP .AND. SF4->F4_MKPCMP == "2" .AND. cMvEstado $ "RS" .AND. SubStr(SFT->FT_CFOP,1,2) $ "14$24"
							aApuracao[nPos,123]	:= Iif((lGiaRs .And. lIncsol),0,SFT->FT_ICMSRET)  // Se  (lGiaRs .And. lIncsol) o ICMS Ret j· est· no total 
						//VAlor de exclus„o de aquisiÁ„o de serviÁo de transporte vinculado a aquisiÁ„o de ativo ou uso e consumo para GIA B RS
						ElseIF lF4FTATUSC .AND. SF4->F4_FTATUSC == "1" .AND.cMvEstado $ "RS".AND. Alltrim(SFT->FT_CFOP) $ "1949/2949"
							aApuracao[ nPos , 123 ]	:= SFT->FT_VALCONT						
						EnDIF		   										
		   				
			   		Endif
			   	Endif
			Endif  				
	    Endif

		aApuracao[nPos,11]	+=	nF3VALCONT
		
		If cMvEstado=="SP"  .And. SubStr((cAliasSF3)->F3_CFO,1,1) < "3"
    	     If SFT->(MsSeek(xFilial("SF3")+"E"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
    	        While !SFT->(Eof()) .And. ALLTRIM(SFT->FT_CFOP) $ "291#297#2551#2552#2556#2557" .And. (cAliasSF3)->F3_IDENTFT == SFT->FT_IDENTF3
	    	  	    If SD1->(DbSeek(xFilial("SD1")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))			   
					    If SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES))
							If SF4->F4_ICM = "N"
								aApuracao[nPos,135] += SFT->FT_VALCONT // Valor n„o tributado a ser abatido posteriormente CH: TRXBBN 
							EndIf
						EndIf
    				EndIf
    				SFT->(DbSkip())
    			  EndDo	
    			EndIf
    	EndIf
		
		If cImp$"IC/IS"
			aApuracao[nPos,03]	+=	(cAliasSF3)->F3_BASEICM
			aApuracao[nPos,04]	+=	(cAliasSF3)->F3_VALICM-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,(cAliasSF3)->F3_VALFECP)
			aApuracao[nPos,05]	+=	(cAliasSF3)->F3_ISENICM
			If cMvEstado == "MG"  .And. lPosVlIncM .And.  (cAliasSF3)->F3_VLINCMG <> 0 
				aApuracao[nPos,06]	+=	(cAliasSF3)->F3_VLINCMG
			Else			                                               
				//http://tdn.totvs.com/plugins/viewsource/viewpagesrc.action?pageId=6076341
    			//RICMS-MG n∫ 43.080/2002.
    			//Inclus„o do valor que foi feito o desconto no campo outros do icms na apuraÁ„o
    			//chamado TPFMQ7    			
				If lFTDS43080 .and. lFTPR43080
   			    	IF ( cAliasSF3 )->F3_OUTRICM = 0 .AND. cMvEstado == "MG" .AND. ( cAliasSF3 )->F3_DS43080 > 0
    					aApuracao[ nPos , 06 ]	+=	( cAliasSF3 )->F3_VL43080
			    	ELSE
						aApuracao[nPos,06]	+=	(cAliasSF3)->F3_OUTRICM
					ENDIF	
				Endif
			EndIf
			aApuracao[nPos,29]	+=	(cAliasSF3)->F3_ISSSUB
			
			
			lUFFecp	:=	aScan( aUFFecp , { |x| x == cMvEstado } ) > 0
			// Utilizado pelo P9AUTOTEXT.RJ	- Resolucao SEF 6.556/2003 - Art. 4
			// Utilizado pelo P9AUTOTEXT.BA
			If lUfRj .Or. lUfBA .Or. lUfSE .Or. lUFFecp 
				If (cAliasSF3)->F3_BASERET > 0 .And. (cAliasSF3)->F3_CREDST <> '4'
				    aApuracao[nPos,32] += Abs((cAliasSF3)->F3_BASERET)
				    aApuracao[nPos,57] += Abs(Iif(lF3VFECPST,(cAliasSF3)->F3_VFECPST,0))				    
				Endif
				aApuracao[nPos,31] += (cAliasSF3)->F3_BASEICM
				If !(cMvEstado == "RJ" .And. !((cAliasSF3)->F3_BASEICM > 0))
					If lUfSE .Or. lUFFecp
						If SubStr((cAliasSF3)->F3_CFO,1,1) >= "5"
							aApuracao[nPos,59] += Iif(lF3VALFECP,(cAliasSF3)->F3_VALFECP ,0)
						EndIF					
					Else
						aApuracao[nPos,59] += Iif(lF3VALFECP,(cAliasSF3)->F3_VALFECP ,0)
					EndIF
				Endif
			Endif                                                              
		
			// Utilizado pelo P9AUTOTEXT.RN
			If lUfRN
		    	
		    	//FECOP operaÁ„o direta consumo
		    	If SubStr((cAliasSF3)->F3_CFO,1,1)$"5/6" .And. (cAliasSF3)->F3_ICMSRET == 0
                    aApuracao[nPos,104] += Abs( RetValFecp( Iif(lF3VFECPRN,( cAliasSF3 )->F3_VFECPRN ,0)  , Iif(lF3VALFECP,(cAliasSF3)->F3_VALFECP,0) ) )
				EndIf 
		    	
		    	//FECOP operaÁ„o interna subst.tribut·ria
		    	If SubStr((cAliasSF3)->F3_CFO,1,1)$"5" .And. (cAliasSF3)->F3_ICMSRET > 0                                      
                    aApuracao[nPos,105] += Abs( RetValFecp( Iif(lF3VFESTRN,( cAliasSF3 )->F3_VFESTRN ,0)  , Iif(lF3VFECPST,(cAliasSF3)->F3_VFECPST,0) ) )
				EndIf
		    	
		    	//FECOP operaÁ„o interestadual subst.tribut·ria
		    	If SubStr((cAliasSF3)->F3_CFO,1,1)$"2" .And. Alltrim((cAliasSF3)->F3_ANTICMS) == "1"
                    aApuracao[nPos,106] += Abs( RetValFecp( Iif(lF3VFECPRN,( cAliasSF3 )->F3_VFECPRN ,0)  , Iif(lF3VALFECP,(cAliasSF3)->F3_VALFECP,0) ) )
                    aApuracao[nPos,106] += Abs( RetValFecp( Iif(lF3VFESTRN,( cAliasSF3 )->F3_VFESTRN ,0)  , Iif(lF3VFECPST,(cAliasSF3)->F3_VFECPST,0) ) )
			    EndIf
			    
			    //FECOP operaÁ„o entrada interna
			    If SubStr((cAliasSF3)->F3_CFO,1,1)$"1"
	               aApuracao[nPos,107] += Abs( RetValFecp( Iif(lF3VFECPRN,( cAliasSF3 )->F3_VFECPRN ,0)  , Iif(lF3VALFECP,(cAliasSF3)->F3_VALFECP,0) ) )
	               aApuracao[nPos,107] += Abs( RetValFecp( Iif(lF3VFESTRN,( cAliasSF3 )->F3_VFESTRN ,0)  , Iif(lF3VFECPST,(cAliasSF3)->F3_VFECPST,0) ) )
			    EndIf
			
			Endif                                                              
			
			// Utilizado pelo P9AUTOTEXT.MG
			If lUfMG .And. SubStr((cAliasSF3)->F3_CFO,1,1)>="5"
 			    If SF2->(MsSeek(xFilial("SF3")+(cAliasSF3)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)))
		    	    If (cAliasSF3)->F3_ICMSRET == 0 //FECP sobre ICMS prÛprio
			            If SF2->F2_TIPOCLI == "F"				
                            aApuracao[nPos,115] += Abs(RetValFecp( Iif(lF3VFECPMG,( cAliasSF3 )->F3_VFECPMG ,0)  , Iif(lF3VALFECP,(cAliasSF3)->F3_VALFECP,0) ))
                        Else
                            aApuracao[nPos,113] += Abs(RetValFecp( Iif(lF3VFECPMG,( cAliasSF3 )->F3_VFECPMG ,0)  , Iif(lF3VALFECP,(cAliasSF3)->F3_VALFECP,0) ))
				        EndIf
				    EndIf
		    	    If (cAliasSF3)->F3_ICMSRET > 0 .AND. ((cAliasSF3)->F3_ESTADO $ cMV_SubTr) //FECP sobre ICMS-ST
			            If SF2->F2_TIPOCLI == "F"
					        aApuracao[nPos,116] += Abs( RetValFecp( Iif(lF3VFESTMG,( cAliasSF3 )->F3_VFESTMG ,0)  , Iif(lF3VFECPST,(cAliasSF3)->F3_VFECPST,0) ) ) 
						Else
					        aApuracao[nPos,114] += Abs( RetValFecp( Iif(lF3VFESTMG,( cAliasSF3 )->F3_VFESTMG ,0)  , Iif(lF3VFECPST,(cAliasSF3)->F3_VFECPST,0) ) ) 						    
						EndIf
					EndIf
			    Endif
			Endif                                                              
			
			// Utilizado pelo P9AUTOTEXT.MT
			If lUfMT
		  		If SubStr((cAliasSF3)->F3_CFO,1,1) >= "5" 
			   		aApuracao[nPos,117] += Abs( RetValFecp( Iif(lF3VFECPMT,(cAliasSF3)->F3_VFECPMT,0)  , Iif(lF3VALFECP,(cAliasSF3)->F3_VALFECP,0) ) )
		   		Endif
			Endif
			// Utilizado pelo P9AUTOTEXT.PR	- Art. 253 RICMS PR
			If cMvEstado=="PR"
				If SubStr((cAliasSF3)->F3_CFO,1,1) >= "5"
					If SFT->(MsSeek(xFilial("SF3")+"S"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
						If SB1->(MsSeek(xFilial("SB1")+SFT->FT_PRODUTO)) .And. lPosRicm65
							If SB1->B1_RICM65=="1"
								If CDC->(DbSeek(xFilial ("CDC")+"S"+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
									While CDC->(!EOF()) .And. CDC->CDC_FILIAL == xFilial("CDC") .And. CDC->CDC_TPMOV == "S" .And. CDC->CDC_DOC == (cAliasSF3)->F3_NFISCAL .And.;
										CDC->CDC_SERIE == (cAliasSF3)->F3_SERIE .And. CDC->CDC_CLIFOR == (cAliasSF3)->F3_CLIEFOR .And. CDC->CDC_LOJA == (cAliasSF3)->F3_LOJA
										If SF6->(dbSeek(xFilial("SF6")+CDC->CDC_UF+CDC->CDC_GUIA))
											If SF6->F6_TIPOIMP == "1"
												aApuracao[nPos,80] += SF6->F6_VALOR
											EndIf
										EndIf
										CDC->(dbSkip())
									EndDo
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf									
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥Verifica a existencia do parametro para ICMS Retido na saida.≥
			//≥Caso esteja preenchido, apenas as UFs indicadas no mesmo     ≥
			//≥devem ser processadas na saida. Caso contrario, a regra do   ≥
			//≥MV_STUF foi mantida (tanto para entradas como para saidas)   ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			lSTSaida 	:= .F.
			lProcST		:= .T.
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//|AO ALTERAR ESTE IF, ALTERAR TAMBEM O SPED FISCAL, POIS TEM UMA|
			//|       COPIA DESTE TRATAMENTO NA FUNCAO APURADOC()            |
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If SubStr((cAliasSF3)->F3_CFO,1,1) >= "5"
				If !Empty(cMv_StUfS) 
					If (cAliasSF3)->F3_ESTADO $ cMv_StUfS
						If lResF3FT .And. Len(aResF3FT)>0
							For nX := 1 to Len(aResF3FT)
								If aResF3FT[nX][8] <> "4"
									aApuracao[nPos,07]	+=	aResF3FT[nX][9] 	//BASERET
									If lUsaSped                                                                                                                           
										aApuracao[nPos,08]	+=	aResF3FT[nX][10]-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,aResF3FT[nX][11]) //ICMSRET
									else
										aApuracao[nPos,08]	+=	Iif( lUfRj , Iif( (cAliasSF3)->F3_ESTADO $ cMvEstado , aResF3FT[nX][10] , 0 ) , aResF3FT[nX][10] ) //ICMSRET
									EndIf
									aApuracao[nPos,56] 	+= 	aResF3FT[nX][11]	//VFRCPST
									lSTSaida := .T.
								Else
									aApuracao[nPos,42]	+=	aResF3FT[nX][9] 	//BASERET
									aApuracao[nPos,43]	+=	aResF3FT[nX][10]	//ICMSRET
								Endif
							Next
						Else
							If (cAliasSF3)->F3_CREDST <> "4" .and. ((cAliasSF3)->F3_ESTADO$cMV_SubTr .Or. (AllTrim(cMvEstado)$AllTrim(cMV_STNIEUF)))
								aApuracao[nPos,07]	+=	(cAliasSF3)->F3_BASERET
								If lUsaSped
									aApuracao[nPos,08]	+= (cAliasSF3)->F3_ICMSRET-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,(cAliasSF3)->F3_VFECPST) 
								else
									aApuracao[nPos,08]	+=	Iif( lUfRj , Iif( (cAliasSF3)->F3_ESTADO $ cMvEstado , (cAliasSF3)->F3_ICMSRET-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,(cAliasSF3)->F3_VFECPST) , 0) , (cAliasSF3)->F3_ICMSRET-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO $ "BD",0,(cAliasSF3)->F3_VFECPST))
								EndIf
								aApuracao[nPos,56] +=  Iif(lF3VFECPST,(cAliasSF3)->F3_VFECPST,0)
								lSTSaida := .T.
							Else
								aApuracao[nPos,42]	+=	(cAliasSF3)->F3_BASERET
								aApuracao[nPos,43]	+=	(cAliasSF3)->F3_ICMSRET-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,(cAliasSF3)->F3_VFECPST)							
							Endif
						Endif
					Else
						lProcST := .F.
					Endif
				Endif
			Endif
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//|AO ALTERAR ESTE IF, ALTERAR TAMBEM O SPED FISCAL, POIS TEM UMA|
			//|       COPIA DESTE TRATAMENTO NA FUNCAO APURADOC()            |
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		 	If ((!Empty(cMv_StUf) .And. ((cAliasSF3)->F3_ESTADO$cMv_StUf)) .or. Empty(cMv_StUf))
		 		If !lSTSaida .And. lProcST
					//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
					//≥SE cMvEstado=GO DEVE CONSIDERAR SOMENTE FORNECEDORES/CLIENTES QUE≥
					//≥PERTENCEM AO SIMPLES NACIONAL                                    ≥
					//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ							
					If cMvEstado$"GO" 
						cSimpNac      := ""
						If (cAliasSF3)->F3_TIPO<>"D"
					   		SA2->(DbSetOrder(1))
							If SA2->(MsSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)) .And. lPosSimNac
							  	cSimpNac := SA2->A2_SIMPNAC 
							EndIf
						EndIf									
					EndIf
					If lResF3FT .And. Len(aResF3FT)>0
						For nX := 1 to Len(aResF3FT)
			 				If aResF3FT[nX][8] <> "4"
								// Nao considerar devoluÁıes pois a devoluÁ„o ser· considerada como "crÈdito" independentemente da configuraÁ„o do CREDST.
								// As devoluÁıes ser„o totalizadas na posiÁ„o 12 do aApuracao mais abaixo no fluxo.
								If aResF3FT[nX][17] <> "D
									aApuracao[nPos,07]	+=	aResF3FT[nX][9] 	//BASERET
									// Quando o CREDST for 1 (Credita), sÛ somar na posiÁ„o "8" (CrÈdito) quando "Imprimir crÈdito ST = SIM".
									// Verificar condiÁ„o mais abaixo para totalizaÁ„o do F3_SOLTRIB na posiÁ„o 21. A posiÁ„o 21 ser· utilizada na montagem do aCols "ST-Entradas",
									// portanto a regra deve ser a mesma para o aApuracao para que os valores apresentados nas duas abas (ST-Entradas e ApuraÁ„o ST) sejam os mesmos.
									If aResF3FT[nX][8] $ " #1" .And. aResF3FT[nX][12] > 0
										If (lImpCrdSt .And. ((!Empty(cMv_StUf) .And. (cAliasSF3)->F3_ESTADO$cMv_StUf) .Or. Empty(cMv_StUf)))									
											If lUsaSped
												aApuracao[nPos,08]	+= aResF3FT[nX][10] //ICMSRET 
											Else                                                                                                                                   
												aApuracao[nPos,08]	+=	Iif( lUfRj , Iif( (cAliasSF3)->F3_ESTADO $ cMvEstado , aResF3FT[nX][10] , 0 ) , aResF3FT[nX][10] ) //ICMSRET 
											EndIf
										EndIf 									
									Else									
										If lUsaSped
											aApuracao[nPos,08]	+= aResF3FT[nX][10] //ICMSRET 
										Else                                                                                                                                   
											aApuracao[nPos,08]	+=	Iif( lUfRj , Iif( (cAliasSF3)->F3_ESTADO $ cMvEstado , aResF3FT[nX][10] , 0 ) , aResF3FT[nX][10] ) //ICMSRET 
										EndIf										 
									EndIf
								EndIf
								If cSimpNac <> "1" .Or. aResF3FT[nX][17] == "D"								 
									If lUsaSped
										aApuracao[nPos,109]	+= aResF3FT[nX][10] //ICMSRET 
									Else                                                                                                                                   
										aApuracao[nPos,109]	+=	Iif( lUfRj , Iif( (cAliasSF3)->F3_ESTADO $ cMvEstado , aResF3FT[nX][10] , 0 ) , aResF3FT[nX][10] ) //ICMSRET 
									EndIf 								
								EndIf
								aApuracao[nPos,56] 	+= 	aResF3FT[nX][11]	//VFECPST
							Else
								aApuracao[nPos,42]	+=	aResF3FT[nX][9]		//BASERET
								aApuracao[nPos,43]	+=	aResF3FT[nX][10]	//ICMSRET
							Endif
                     Next
					Else
			 			If (cAliasSF3)->F3_CREDST <> "4" .and. ((cAliasSF3)->F3_ESTADO $ cMV_SubTr .Or. (AllTrim(cMvEstado)$AllTrim(cMV_STNIEUF)))
							aApuracao[nPos,07]	+=	(cAliasSF3)->F3_BASERET
							// Nao considerar devoluÁıes pois a devoluÁ„o ser· considerada como "crÈdito" independentemente da configuraÁ„o do CREDST.
							// As devoluÁıes ser„o totalizadas na posiÁ„o 12 do aApuracao mais abaixo no fluxo.							
							If (cAliasSF3)->F3_TIPO <> "D"
								// Quando o CREDST for 1 (Credita), sÛ somar na posiÁ„o "8" (CrÈdito) quando "Imprimir crÈdito ST = SIM".
								// Verificar condiÁ„o mais abaixo para totalizaÁ„o do F3_SOLTRIB na posiÁ„o 21. A posiÁ„o 21 ser· utilizada na montagem do aCols "ST-Entradas",
								// portanto a regra deve ser a mesma para o aApuracao para que os valores apresentados nas duas abas (ST-Entradas e ApuraÁ„o ST) sejam os mesmos.								
								If (cAliasSF3)->F3_CREDST $ " #1" .And. (cAliasSF3)->F3_SOLTRIB > 0
									If (lImpCrdSt .And. ((!Empty(cMv_StUf) .And. (cAliasSF3)->F3_ESTADO$cMv_StUf) .Or. Empty(cMv_StUf)))
										If lUsaSped
											aApuracao[nPos,08] += (cAliasSF3)->F3_ICMSRET 	
										Else                                                                                                                                       
											aApuracao[nPos,08] += Iif( lUfRj , Iif( (cAliasSF3)->F3_ESTADO $ cMvEstado , (cAliasSF3)->F3_ICMSRET , 0 ) , (cAliasSF3)->F3_ICMSRET )	
										EndIf
									EndIf
								Else
									If lUsaSped
										aApuracao[nPos,08] += (cAliasSF3)->F3_ICMSRET 	
									Else                                                                                                                                       
										aApuracao[nPos,08] += Iif( lUfRj , Iif( (cAliasSF3)->F3_ESTADO $ cMvEstado , (cAliasSF3)->F3_ICMSRET , 0 ) , (cAliasSF3)->F3_ICMSRET )	
									EndIf
								EndIf
							EndIf
							If cSimpNac <> "1" .Or. (cAliasSF3)->F3_TIPO == "D"							
								If lUsaSped
									aApuracao[nPos,109] := (cAliasSF3)->F3_ICMSRET 	
								Else                                                                                                                                       
									aApuracao[nPos,109] := Iif( lUfRj , Iif( (cAliasSF3)->F3_ESTADO $ cMvEstado , (cAliasSF3)->F3_ICMSRET , 0 ) , (cAliasSF3)->F3_ICMSRET)	
								EndIf								
							EndIf
							aApuracao[nPos,56] += Iif(lF3VFECPST,(cAliasSF3)->F3_VFECPST,0)
						Else
							aApuracao[nPos,42]	+=	(cAliasSF3)->F3_BASERET
							aApuracao[nPos,43]	+=	(cAliasSF3)->F3_ICMSRET
						Endif
					Endif					
				Endif
			EndIf
			aApuracao[nPos,09]	+=	(cAliasSF3)->F3_ICMAUTO
			If (lGiaRs .And. lIncsol)
			 	 aApuracao[nPos,140] += (cAliasSF3)->F3_ICMSRET	// Retido Escuidas, para ajuste do I.C					
			EndIf
			If lF3DIFAL .And. lFTPDDES 
				If ( cAliasSF3 )->F3_DIFAL == 0 .And. SFT->FT_PDDES == 0
					
					If lPARICMS            
						If !Alltrim((cAliasSF3)->F3_CFO)$"291/197/2551/2552/2556/2557"
							aApuracao[nPos,10]	+=	(cAliasSF3)->F3_ICMSCOM
					    Endif
					Else    
						aApuracao[nPos,10]	+=	(cAliasSF3)->F3_ICMSCOM
					Endif
					
				EndIF
			Else
				If lPARICMS            
					If !Alltrim((cAliasSF3)->F3_CFO)$"291/197/2551/2552/2556/2557"
						aApuracao[nPos,10]	+=	(cAliasSF3)->F3_ICMSCOM
				    Endif
				Else    
					aApuracao[nPos,10]	+=	(cAliasSF3)->F3_ICMSCOM
				Endif
			EndIF
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	     	//≥Verifica vinculo de Nota de conhecimento de frete com notas de |
			//≥compra (Uso Consumo/Ativo Imobilizado)para incluir na linha de |
			//≥DEBITO POR DIFERENCIAL codigo 25020 e 25030                    |
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		    lAtivo   := .F.
		    lConsumo := .F.
		    nValAti  := 0
		    nValCon  := 0
		    nPorAti  := 0
	   		nPorCon  := 0
		    If lTransp
				If SF1->(MsSeek(xFilial("SF1")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
		           	If SF1->F1_TIPO=="C"
		           	    If SF8->(dbSeek(xFilial("SF1")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA))
	           	        	If SD1->(MsSeek(xFilial("SF8")+SF8->F8_NFORIG+SF8->F8_SERORIG+SF8->F8_FORNECE+SF8->F8_LOJA))
	           	        		cChaveSD1 := xFilial("SF8")+SF8->F8_NFORIG+SF8->F8_SERORIG+SF8->F8_FORNECE+SF8->F8_LOJA
    	       	        		While (!SD1->(Eof()) .And. cChaveSD1==xFilial("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
					    	   		If SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES))
										If SF4->F4_ATUATF=="S"
											lAtivo := .T. // Ativo permanente
											nValAti += SD1->D1_ICMSCOM
										Else
											If	SF4->F4_CONSUMO=="S"
												lConsumo := .T. //Material de uso de consumo
												nValCon  += SD1->D1_ICMSCOM
											EndIf
										EndIf
									EndIf
				   		   			SD1->(DbSkip())
							    EndDo
				   		   	EndIf
		        		EndIf 
		  			EndIf 	
		        Endif
			EndIf
   			If lAtivo
   				nPorAti := ((nValAti*100)/(nValAti+nValCon))
   				aApuracao[nPos,18] += (nPorAti*(cAliasSF3)->F3_ICMSCOM )/100  // Ativo permanente - Conh.Frete
   			EndIf
   			If lConsumo
   				nPorCon :=	((nValCon*100)/(nValAti+nValCon))
   				aApuracao[nPos,17] +=  (nPorCon*(cAliasSF3)->F3_ICMSCOM )/100	//Material de uso de consumo - Conh.Frete
   			Endif
			If Substr((cAliasSF3)->F3_CFO,2,3) $ "97 /556/557/407"
				aApuracao[nPos,17]	+= 	(cAliasSF3)->F3_ICMSCOM  //Material de uso de consumo
			ElseIf Substr((cAliasSF3)->F3_CFO,2,3) $ "91 /551/406/553" .and. !lPARICMS 
				aApuracao[nPos,18]	+= 	(cAliasSF3)->F3_ICMSCOM  // Ativo permanente
			EndIf
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ApuraÁ„o da Transf. do DÈbito e CrÈdito      ≥
			//≥Necess·rio a criaÁ„o do campo SF3->F3_TRFICM ≥
			//≥Tipo = N                                     ≥
			//≥Tamanho = 14,2           		            ≥ 
			//≥Picture = @E 99,999,999,999.99               ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If Substr(Alltrim((cAliasSF3)->F3_CFO),1,3)=="000" .Or. Substr(Alltrim((cAliasSF3)->F3_CFO),1,4) $ "1601/1602/5601/5602"
				aApuracao[nPos,15]	+= (cAliasSF3)->F3_TRFICM
			ElseIf Substr(Alltrim((cAliasSF3)->F3_CFO),1,3)=="999" .Or. Substr(Alltrim((cAliasSF3)->F3_CFO),1,4) $ "1605/5605"
			    aApuracao[nPos,16]	+= (cAliasSF3)->F3_TRFICM
			EndIf
			aApuracao[nPos,14]	+=	(cAliasSF3)->F3_ICMSDIF
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//|AO ALTERAR ESTE IF/ELSEIF, ALTERAR TAMBEM O SPED FISCAL, POIS |
			//|       TEM UMA COPIA DESTE TRATAMENTO NA FUNCAO APURADOC()    |
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If lResF3FT .And. Len(aResF3FT)>0
				For nX := 1 to Len(aResF3FT)
					If cMvEstado == 'SC' .And. lDIMESC  
						If Left(Alltrim((cAliasSF3)->F3_CFO),1) $ "123" .And. (cAliasSF3)->F3_CREDST <> "3" .And. aApuracao[nPos,08] > 0
							aApuracao[nPos,07]	-= (cAliasSF3)->F3_BASERET
							aApuracao[nPos,08]	-= (cAliasSF3)->F3_ICMSRET
						ElseIf Left(Alltrim((cAliasSF3)->F3_CFO),1) $ "567" .And. (cAliasSF3)->F3_ESTADO <> "SC" .And. aApuracao[nPos,08] > 0
							aApuracao[nPos,07]	-= (cAliasSF3)->F3_BASERET
							aApuracao[nPos,08]	-= (cAliasSF3)->F3_ICMSRET	
						EndIf 				
					ElseIf aResF3FT[nX][12] >0
						Do Case
							Case aResF3FT[nX][8]$" #1"
								// Nao considerar devoluÁıes pois a devoluÁ„o ser· considerada como "crÈdito" independentemente da configuraÁ„o do CREDST.
								// As devoluÁıes ser„o totalizadas na posiÁ„o 12 do aApuracao mais abaixo no fluxo.					
								If aResF3FT[nX][17] <> "D"
									// Soma valor de FT_SOLTRIB para exibiÁ„o na linha "006 - CrÈditos" do resumo de ApuraÁ„o - ST e no aCols da aba ST - Entradas.
									aApuracao[nPos,21]	+=	aResF3FT[nX][12]
				    	            If lImpCrdSt .And. ((((!Empty(cMv_StUf) .And. (cAliasSF3)->F3_ESTADO$cMv_StUf) .Or. Empty(cMv_StUf)).And.lProcST) .Or. lSTSaida)
				    	               If lUsaSped
											aApuracao[nPos,08]	-=	aResF3FT[nX][12]    
									   Else                                                                                                                            
									   		aApuracao[nPos,08]	-=	Iif( lUfRj , Iif( (cAliasSF3)->F3_ESTADO $ cMvEstado , aResF3FT[nX][12] , 0 ) , aResF3FT[nX][12] )   
									   EndIf
									EndIf
								EndIf
							Case aResF3FT[nX][8]=="3"
								aApuracao[nPos,33]	+=	aResF3FT[nX][12]
								If lUsaSped
									aApuracao[nPos,08]	-=	IIf(lImpCrdSt,aResF3FT[nX][12],aResF3FT[nX][10])  
								Else                                                                                                                                                                                              
									aApuracao[nPos,08]	-=	Iif( lUfRj , Iif( (cAliasSF3)->F3_ESTADO $ cMvEstado , IIf(lImpCrdSt,aResF3FT[nX][12],aResF3FT[nX][10]) , 0 ) , IIf(lImpCrdSt,aResF3FT[nX][12],aResF3FT[nX][10])  )   
								EndIf
								//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
								//≥Quando utilizar o tratamento de ICMS ST de Transporte de MG, o valor do ICMS           ≥
								//≥a debito devera ser lancado em outros debitos, mas em coluna especifica, atraves do P9.≥
								//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
								If lTransST .And. aResF3FT[nX][6]=="E" .And. aResF3FT[nX][13] > 0
									aApuracao[nPos,40]	+=	aResF3FT[nX][12]
									aApuracao[nPos,33]	-=	aResF3FT[nX][12]
								Endif
					  	EndCase
                    Endif
				Next	
			ElseIf cMvEstado == 'SC' .And. lDIMESC  
				If Left(Alltrim((cAliasSF3)->F3_CFO),1) $ "123" .And. (cAliasSF3)->F3_CREDST <> "3" .And. aApuracao[nPos,08] > 0 
					aApuracao[nPos,07]	-= (cAliasSF3)->F3_BASERET
					aApuracao[nPos,08]	-= (cAliasSF3)->F3_ICMSRET
				ElseIf Left(Alltrim((cAliasSF3)->F3_CFO),1) $ "567" .And. (cAliasSF3)->F3_ESTADO <> "SC" .And. aApuracao[nPos,08] > 0
					aApuracao[nPos,07]	-= (cAliasSF3)->F3_BASERET
					aApuracao[nPos,08]	-= (cAliasSF3)->F3_ICMSRET
				EndIf					
			ElseIf (cAliasSF3)->F3_SOLTRIB>0
				Do Case
					Case (cAliasSF3)->F3_CREDST $ " #1"
						// Nao considerar devoluÁıes pois a devoluÁ„o ser· considerada como "crÈdito" independentemente da configuraÁ„o do CREDST.
						// As devoluÁıes ser„o totalizadas na posiÁ„o 12 do aApuracao mais abaixo no fluxo.
						If (cAliasSF3)->F3_TIPO <> "D"
						 	// Soma valor de F3_SOLTRIB para exibiÁ„o na linha "006 - CrÈditos" do resumo de ApuraÁ„o - ST e no aCols da aba ST - Entradas.
							aApuracao[nPos,21]	+=	(cAliasSF3)->F3_SOLTRIB
		    	            If lImpCrdSt .And. ((((!Empty(cMv_StUf) .And. (cAliasSF3)->F3_ESTADO $ cMv_StUf) .Or. Empty(cMv_StUf)) .And. lProcST) .Or. lSTSaida)
		    	            	If lUsaSped
							   		aApuracao[nPos,08]	-=	(cAliasSF3)->F3_SOLTRIB 
								Else                                                                                                                                            
									aApuracao[nPos,08]	-=	Iif( lUfRj , Iif( (cAliasSF3)->F3_ESTADO $ cMvEstado , (cAliasSF3)->F3_SOLTRIB , 0 ) , (cAliasSF3)->F3_SOLTRIB )  
								EndIf
							EndIf
						EndIf
					Case (cAliasSF3)->F3_CREDST == "3" 
						aApuracao[nPos,33]	+=	(cAliasSF3)->F3_SOLTRIB
						If lUsaSped
							aApuracao[nPos,08]	-=	IIf(lImpCrdSt,(cAliasSF3)->F3_SOLTRIB,(cAliasSF3)->F3_ICMSRET) 
						Else
							aApuracao[nPos,08]	-=	Iif( lUfRj , Iif( (cAliasSF3)->F3_ESTADO $ cMvEstado , IIf(lImpCrdSt,(cAliasSF3)->F3_SOLTRIB,(cAliasSF3)->F3_ICMSRET) , 0 ) , IIf(lImpCrdSt,(cAliasSF3)->F3_SOLTRIB,(cAliasSF3)->F3_ICMSRET) )  
						EndIf                                                                                                                                                                                                                           
						//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
						//≥Quando utilizar o tratamento de ICMS ST de Transporte de MG, o valor do ICMS           ≥
						//≥a debito devera ser lancado em outros debitos, mas em coluna especifica, atraves do P9.≥
						//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
						If lTransST .And. Left(Alltrim((cAliasSF3)->F3_CFO),1) $ "123" .And. (cAliasSF3)->F3_CRPRST > 0
							aApuracao[nPos,40]	+=	(cAliasSF3)->F3_SOLTRIB
							aApuracao[nPos,33]	-=	(cAliasSF3)->F3_SOLTRIB
						Endif
			  	EndCase
		  	EndIf
		  	
		  	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//|AO ALTERAR ESTE IF/ELSEIF, ALTERAR TAMBEM O SPED FISCAL, POIS |
			//|       TEM UMA COPIA DESTE TRATAMENTO NA FUNCAO APURADOC()    |
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If Val(Substr((cAliasSF3)->F3_CFO,1,1))<5.and.(cAliasSF3)->F3_TIPO=="D" //Devolucao de vendas com ICMS Retido
				If lResF3FT .And. Len(aResF3FT)>0
					For nX := 1 to Len(aResF3FT)
						If aResF3FT[nX][8] <> "4"
							aApuracao[nPos,12]	+=	aResF3FT[nX][10]	//ICMSRET
						Endif
					Next
				Else
					If ((!Empty(cMv_StUf) .And. ((cAliasSF3)->F3_ESTADO$cMv_StUf)) .or. Empty(cMv_StUf))				
						If (cAliasSF3)->F3_CREDST <> "4"
							aApuracao[nPos,12]	+=	(cAliasSF3)->F3_ICMSRET
						Endif
					EndIF				
				Endif
           	ElseIf (Val(Substr((cAliasSF3)->F3_CFO,1,1))>=5.and.(cAliasSF3)->F3_TIPO!="D")
				If lResF3FT .And. Len(aResF3FT)>0
					For nX := 1 to Len(aResF3FT)
						If aResF3FT[nX][8] <> "4"
							aApuracao[nPos,13]	+=	aResF3FT[nX][10]-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,aResF3FT[nX][11])	//ICMSRET
						Endif
					Next
				Else
	          		If ((!Empty(cMv_StUf) .And. ((cAliasSF3)->F3_ESTADO$cMv_StUf)) .or. Empty(cMv_StUf))				
		          		If (cAliasSF3)->F3_CREDST <> "4"
							aApuracao[nPos,13]	+=	(cAliasSF3)->F3_ICMSRET-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,(cAliasSF3)->F3_VFECPST)
						Endif 
					EndIF
				Endif
			EndIf
			
			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ICMS-ST Transportes - MG			   ≥
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			
			If Alltrim((cAliasSF3)->F3_CFO)$"5949" .And. cMvEstado$"MG" .And. (cAliasSF3)->F3_ICMSRET > 0 .And. ;
				(cAliasSF3)->F3_VALICM == 0 .And. SF4->F4_OBSSOL=="5"
					aApuracao[nPos,103]		+=	(cAliasSf3)->F3_ICMSRET
			Endif
						
			If lGiaRs			
				aApuracao[nPos,24]	+=	(cAliasSF3)->F3_VALIPI
			Else
				aApuracao[nPos,24]	+=	(cAliasSF3)->F3_VALIPI+(cAliasSF3)->F3_ISENIPI+(cAliasSF3)->F3_OUTRIPI
			Endif
			aApuracao[nPos,46]  +=  (cAliasSF3)->F3_IPIOBS
			aApuracao[nPos,138]  += ((cAliasSF3)->F3_VALIPI + (cAliasSF3)->F3_IPIOBS)
			If lQbUF
				SA1->(MsSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				SA2->(MsSeek(xFilial("SA2")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥Verificacao - Contribuinte ou nao   ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
                If FNaoContri(cAliasSF3, .T., lDIMESC)

                   aApuracao[nPos,25]	+=	nF3VALCONT
                   If Alltrim((cAliasSF3)->F3_CFO)$cCFATGMB .And. cMvEstado == "RS"
				   		aApuracao[nPos,26]	+=	0
				   		aApuracao[nPos,58]	+= 0
				   Else
						aApuracao[nPos,26]	+=	(cAliasSF3)->F3_BASEICM
						aApuracao[nPos,58]	+=	Iif(lF3VALFECP,(cAliasSF3)->F3_VALFECP,0)
				   Endif
	            Else //Contribuinte 
		            aApuracao[nPos,27]	+=	nF3VALCONT         
		           If Alltrim((cAliasSF3)->F3_CFO)$cCFATGMB .And. cMvEstado == "RS"
		   		   		aApuracao[nPos,28]	+=	0
				   Else
						aApuracao[nPos,28]	+=	(cAliasSF3)->F3_BASEICM
			  	   Endif
	            EndIf
			Endif
			//Cria arquivo temporario para conferencia de apuraÁ„o de ICMS (Notas fiscais de saÌda e entrada) //Tapia
			If lConfApur .AND. lAliasApur
				// ApuraÁ„o ICMS
				If cImp=="IC"
					If /*aApuracao[nPos,04] > 0 .And. */SubStr((cAliasSF3)->F3_CFO,1,1) >= "5"// .And. (cAliasSF3)->F3_VALICM > 0
						ApurTempNF((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_ENTRADA,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA,;
						(cAliasSF3)->F3_CFO,(cAliasSF3)->F3_ALIQICM,(cAliasSF3)->F3_FORMULA,"Debito","ICMS", cAlsDeb, cAliasSF3)
					ElseIf SubStr((cAliasSF3)->F3_CFO,1,1) < "5" /* aApuracao[nPos,04] > 0 .And. .And. (cAliasSF3)->F3_VALICM > 0*/
						ApurTempNF((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_ENTRADA,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA,;
						(cAliasSF3)->F3_CFO,(cAliasSF3)->F3_ALIQICM,(cAliasSF3)->F3_FORMULA,"Credito","ICMS", cAlsCrd, cAliasSF3)
					EndIf
				// ApuraÁ„o ICMS-ST
					If aApuracao[nPos,13] > 0 .And. SubStr((cAliasSF3)->F3_CFO,1,1) >= "5" 
						ApurTempNF((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_ENTRADA,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA,;
						(cAliasSF3)->F3_CFO,(cAliasSF3)->F3_ALIQICM,(cAliasSF3)->F3_FORMULA,"ST_Debito","ICMS",cAlsSTd, cAliasSF3)
					ElseIf ( (cAliasSF3)->F3_ICMSRET > 0 .And. (cAliasSF3)->F3_TIPO == "D" ) .Or. ( aApuracao[nPos,8] > 0 .And. SubStr((cAliasSF3)->F3_CFO,1,1) < "5" )
						ApurTempNF((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_ENTRADA,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA,;
						(cAliasSF3)->F3_CFO,(cAliasSF3)->F3_ALIQICM,(cAliasSF3)->F3_FORMULA,"ST_Credito","ICMS",cAlsSTe, cAliasSF3)
					Endif
				EndIf				
			Endif
			//Fim alteracao Tapia
		Else
			aApuracao[nPos,03]	+=	Iif(SF4->F4_IPI=='R', 0, (cAliasSF3)->F3_BASEIPI) 	//Para apuraÁ„o comercio n„o atacadista , tratamento para que BaseIPI e Valor Ipi n„o demonstre na apuraÁ„o. F4_IPI =R e F4_LFIPI = O	bruce				   
			aApuracao[nPos,05]	+=	(cAliasSF3)->F3_ISENIPI
			aApuracao[nPos,06]	+=	Iif(SF4->F4_IPI=='R', (cAliasSF3)->F3_OUTRIPI+(cAliasSF3)->F3_BASEIPI,(cAliasSF3)->F3_OUTRIPI)
			aApuracao[nPos,46]  +=  (cAliasSF3)->F3_IPIOBS			
			
			If lConfApur .AND. lAliasApur
				// ApuraÁ„o IPI
				If cImp =="IP"
					If aApuracao[nPos,03] > 0 .And. SubStr((cAliasSF3)->F3_CFO,1,1) >= "5" .And. (cAliasSF3)->F3_VALIPI > 0
						ApurTempNF((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_ENTRADA,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA,;
						(cAliasSF3)->F3_CFO,(cAliasSF3)->F3_ALIQIPI,(cAliasSF3)->F3_FORMULA,"IPI_Debito","IPI",cAlsIPIs, cAliasSF3)
					ElseIf aApuracao[nPos,03] > 0 .And. SubStr((cAliasSF3)->F3_CFO,1,1) < "5" .And. (cAliasSF3)->F3_VALIPI > 0
						ApurTempNF((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_ENTRADA,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA,;
						(cAliasSF3)->F3_CFO,(cAliasSF3)->F3_ALIQIPI,(cAliasSF3)->F3_FORMULA,"IPI_Credito","IPI",cAlsIPIe, cAliasSF3)
					Endif
				EndIf
			Endif			
		Endif
		aApuracao[nPos,22] += (cAliasSF3)->F3_OBSICM
		aApuracao[nPos,23] += (cAliasSF3)->F3_OBSSOL
        
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Atribuicao do Valor de Credito Estimulo≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
        If lCrdEst
          For nX=1 To Len(aEstimulo)             
		   	  aApuracao[nPos,30] += If((aEstimulo[nX,3]-aEstimulo[nX,2])<0,0,(aEstimulo[nX,3]-aEstimulo[nX,2]))
			Next nX
		  lCrdEst	:=.F. 
	    Endif	  

        //Art. 488 Anexo IX RICMS-MG	    
	    If cMvEstado=="MG" .And. (cAliasSF3)->F3_OUTRICM <> 0       
	        If SubStr((cAliasSF3)->F3_CFO,1,1) < "3"
    	        If SFT->(dbSeek(xFilial("SF3")+"E"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
	    	  	    If SD1->(DbSeek(xFilial("SD1")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))
					    SF4->(dbSeek(xFilial("SF4")+SD1->D1_TES))					
					    lArt488MG := Iif(lF4CRLEIT,Iif(SF4->F4_CRLEIT == "1",.T.,.F.),.F.) 
					    If lArt488MG
					        aApuracao[nPos,87]:= (cAliasSF3)->F3_OUTRICM	
  			                aApuracao[nPos,89]:= "-" + Alltrim(cValtochar(SFT->FT_NFISCAL)) + "-" + Alltrim(cValtochar(SerieNfId("SFT",2,"FT_SERIE"))) + " Data: " + Dtoc(SFT->FT_EMISSAO)   
    				    Endif 
    				EndIf
    			EndIf
    		Else
    	        If SFT->(MsSeek(xFilial("SF3")+"S"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT))
	    	  	    If SD2->(MsSeek(xFilial("SD2")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_PRODUTO+SFT->FT_ITEM))
					    SF4->(MsSeek(xFilial("SD2")+SD2->D2_TES))					
					    lArt488MG := Iif(lF4CRLEIT,Iif(SF4->F4_CRLEIT == "1",.T.,.F.),.F.) 
				        If lArt488MG	    
					        aApuracao[nPos,88]:= (cAliasSF3)->F3_OUTRICM	
   			                aApuracao[nPos,89]:= "-" + Alltrim(cValtochar(SFT->FT_NFISCAL)) + "-" + Alltrim(cValtochar(SerieNfId("SFT",2,"FT_SERIE"))) + " Data: " + Dtoc(SFT->FT_EMISSAO)   
    			        EndIf
    				EndIf
    			EndIf    		
    		EndIf
    	EndIf
    	
    	//-------------------------------------------------------------------------------------
    	//
		//									INCENTIVOS FISCAIS
		//
		//-------------------------------------------------------------------------------------
		//	Abaixo sao calculados os valores de Incentivos Fiscais
		//-------------------------------------------------------------------------------------
		If aFindFunc[FF_XAPGETINCENT]
			
			//-------------------------------------------------------------------------------------
			//
			//									DESENVOLVE - BA
			//
			//-------------------------------------------------------------------------------------
			//	Programa de Desenvolvimento Industrial e de Integracao Economica do Estado da Bahia
			//-------------------------------------------------------------------------------------
			//Embasamento legal:
			//
			//Resolucao  No 123/2009 (regime especial) , Lei no 7.980/2001 e Decreto no 8.205/2002
			//-------------------------------------------------------------------------------------
			If cMvEstado == "BA" .And. Len(aMVDESENV) > 0
				
				If lResF3FT .And. Len(aResF3FT)>0
					
					SFT->( dbSetOrder( 1 ) )
					
					For nX := 1 to Len(aResF3FT)
					
						If SFT->( MsSeek(xFilial( "SFT" )+ cTipoMov + aResF3FT[nX][03] + aResF3FT[nX][02] + aResF3FT[nX][04] + aResF3FT[nX][05] + aResF3FT[nX][16] + aResF3FT[nX][15] ) )
							//If SFT->FT_CFOP $ aCfopDsv[1]
							If SubStr( SFT->FT_CFOP , 1 , 1 ) < "5" .and. ( SFT->FT_CFOP $ aCfopDsv[1] .or. Alltrim(SFT->FT_CFOP) $ "5910|5911|5912|6910|6911|6912" )
								//Creditos - CNVP
								aGetIncent	:=	xApGetIncent(	"DES" , "SFT" , .T. , {1,dDtIni,lB5PROJDES,SFT->FT_PRODUTO,aMVDESENV} )
								aApuracao[ nPos , 120 ]	+=	aGetIncent[1]
								aApuracao[ nPos , 121 ]	+=	aGetIncent[2]
							//Elseif SFT->FT_CFOP $ aCfopDsv[2]
							Elseif ( SFT->FT_CFOP $ aCfopDsv[2] .or. Alltrim(SFT->FT_CFOP) $ "1910|1911|1912|2910|2911|2912" )
								//Debitos - DNVP
								aGetIncent	:=	xApGetIncent(	"DES" , "SFT" , .T. , {1,dDtIni,lB5PROJDES,SFT->FT_PRODUTO,aMVDESENV} )
								aApuracao[ nPos , 121 ]	+=	aGetIncent[1]
								aApuracao[ nPos , 120 ]	+=	aGetIncent[2]

							Endif
						EndIf
					Next nX
					
					SFT->( dbSetOrder( 3 ) )
										
				Endif
			
			//-------------------------------------------------------------------------------------
			//
			//						TERMO DE ACORDO - CREDITO PRESUMIDO/ES
			//
			//-------------------------------------------------------------------------------------
			Elseif cMvEstado == "ES" .And. cF4EsCrPr$"1S" .And. Len(aMVFISCPES) > 0
			
				If dDtIni < CToD(aMVFISCPES[1])
			    
				    // ------------------------------------------
					// Estorno de Credito - Devolucoes - Entradas
					// ------------------------------------------
					If SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) < "5" .And. ( cAliasSF3 )->F3_TIPO $ "D"
					    
						// ------------------------------------------
						// nPos(125) - Estorno de Devolucoes Internas
						// ------------------------------------------
						If SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) == "1"
						
							aApuracao[ nPos , 125 ]	+=	( ( cAliasSF3 )->F3_VALICM * aMVFISCPES[2] ) / 100
					    
						// ------------------------------------------
						// nPos(126) - Estorno de Devolucoes Interestaduais
						// ------------------------------------------
						Elseif SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) == "2"
						
							aApuracao[ nPos , 126 ]	+=	( ( cAliasSF3 )->F3_VALICM * aMVFISCPES[3] ) / 100
						
						Endif
					
					// ------------------------------------------
					// Credito Presumido - Saidas
					// ------------------------------------------
					Elseif SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) >= "5"
					
						// ------------------------------------------
						// nPos(127) - Saidas Internas
						// ------------------------------------------
						If SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) == "5"
							
							aApuracao[ nPos , 127 ]	+=	( ( cAliasSF3 )->F3_VALICM * aMVFISCPES[2] ) / 100
						
						// ------------------------------------------
						// nPos(128) - Saidas Interestaduais
						// ------------------------------------------
						Elseif SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) == "6"
						
							aApuracao[ nPos , 128 ]	+=	( ( cAliasSF3 )->F3_VALICM * aMVFISCPES[3] ) / 100
						
						Endif
					Endif
				Endif
			Endif
		Endif
		nPosAp := nPos // Guardo nPos para verificar CDA x SF3
		// ------------------------------------------
		// Tratamento do convÍnio 139/06
		// ------------------------------------------
		If lConv13906 .And. lChk13906
			SFT->(dbSetOrder(3))           
	
			cChaveSFT 	:= xFilial("SF3")+"S"+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA+;
							   (cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_IDENTFT 
	
	
			If _cQryCV139 == nil 
				_cQryCV139 := "SELECT FT_ESTADO,FT_VALCONT,FT_BASEICM,FT_VALICM FROM "
				_cQryCV139 += RetSqlName('SFT')
				_cQryCV139 += " WHERE FT_FILIAL = ?"
				_cQryCV139 += " AND FT_TIPOMOV  = ?"
				_cQryCV139 += " AND FT_CLIEFOR  = ?"
				_cQryCV139 += " AND FT_LOJA     = ?"
				_cQryCV139 += " AND FT_SERIE    = ?"
				_cQryCV139 += " AND FT_NFISCAL  = ?"
				_cQryCV139 += " AND FT_IDENTF3  = ?"
				_cQryCV139 += " AND FT_CV139    = ?"
				_cQryCV139 += " AND D_E_L_E_T_  = ?"
			EndIf

			aBind := {}
			AADD(aBind,xFilial("SFT"))
			AADD(aBind,'S')
			AADD(aBind,(cAliasSF3)->F3_CLIEFOR)
			AADD(aBind,(cAliasSF3)->F3_LOJA)
			AADD(aBind,(cAliasSF3)->F3_SERIE)
			AADD(aBind,(cAliasSF3)->F3_NFISCAL)
			AADD(aBind,(cAliasSF3)->F3_IDENTFT)
			AADD(aBind,'1')
			AADD(aBind,Space(1))
			dbUseArea(.T.,'TOPCONN',TcGenQry2(,,_cQryCV139,aBind),cAliasSFT,.T.,.F.)

				While (cAliasSFT)->(Eof())
										
	
	
						nPos	:=	Ascan( aConv139,{ | x | x[ 1 ] == (cAliasSFT)->FT_ESTADO } )
						If	nPos == 0
							AADD( aConv139 , Array( 04 ) )  
							nPos	:=	Len( aConv139 )  
							aConv139[ nPos , 01 ]	:=	(cAliasSFT)->FT_ESTADO
							aConv139[ nPos , 02 ]	:=	(cAliasSFT)->FT_VALCONT
							aConv139[ nPos , 03 ]	:=	(cAliasSFT)->FT_BASEICM
							aConv139[ nPos , 04 ]	:=	(cAliasSFT)->FT_VALICM
						Else
							aConv139[ nPos , 02 ]	+=	(cAliasSFT)->FT_VALCONT
							aConv139[ nPos , 03 ]	+=	(cAliasSFT)->FT_BASEICM
							aConv139[ nPos , 04 ]	+=	(cAliasSFT)->FT_VALICM
						EndIF	
	
	
					(cAliasSFT)->(DbSkip())
				EndDo	
			(cAliasSFT)->(dbCloseArea())
		Endif

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Apuracao do ICMS Retido por Unidade de Federacao≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If cImp$"IC"
			If ((!Empty(cMv_StUf) .And. (cAliasSF3)->F3_ESTADO$cMv_StUf) .Or. Empty(cMv_StUf)) .Or. ;
				((!Empty(cMv_StUfS) .And. (cAliasSF3)->F3_ESTADO$cMv_StUfS .And. Substr((cAliasSF3)->F3_CFO,1,1) >= "5"))
				If substr((cAliasSF3)->F3_CFO,1,1) < "5"
					nPos	:=	Ascan(aEntr,{|x|x[1]==(cAliasSF3)->F3_ESTADO})
					If nPos==0
						AADD(aEntr,Array(08))
						nPos	:=	Len(aEntr)
						aEntr[nPos,01]	:=	(cAliasSF3)->F3_ESTADO
						Aeval(aEntr[nPos],{|x,i|aEntr[nPos,i]:=0},2)
					EndIf
					If lResF3FT .And. Len(aResF3FT)>0
						For nX := 1 to Len(aResF3FT)
							If aResF3FT[nX][8] <> "4"
								aEntr[nPos,03]	+=	aResF3FT[nX][9] 	//BASERET
								//Devolucoes de vendas com credito de ST
								If aResF3FT[nX][17] == "D"
									aEntr[nPos,07]	+= aResF3FT[nX][10]		//ICMSRET
									If nPos > 0 .And. aEntr[nPos,01]$cMVUFECSEP
										aEntr[nPos,08] += aResF3FT[nX][11]	//FECP ST
									EndIf	
								Else
									aEntr[nPos,04]	+=	aResF3FT[nX][10]	//ICMSRET
								EndIf
							Endif 
							If aResF3FT[nX][12]>0 	//SOLTRIB
								Do Case
									Case aResF3FT[nX][8]$" #1"
										// N„o considerar as devoluÁıes pois elas ser„o sempre consideradas como crÈdito, na posiÁ„o 7 do array aEnt, independente do CREDST (com exceÁ„o do "4"). 
										If aResF3FT[nX][17] <> "D"
											If !lImpCrdSt
									      		aEntr[nPos,04]	-=	aResF3FT[nX][12]
									   		EndIf
									   		aEntr[nPos,05]	+=	aResF3FT[nX][12]
									   	EndIf
									Case aResF3FT[nX][8]=="3"
							  			aEntr[nPos,06]	+=	aResF3FT[nX][12]
							      		aEntr[nPos,04]	-=	aResF3FT[nX][12]
							  	EndCase
							EndIf									
						Next
					Else
						If (cAliasSF3)->F3_CREDST <> "4"
							aEntr[nPos,03]	+=	(cAliasSF3)->F3_BASERET
							//Devolucoes de vendas com credito de ST
							If (cAliasSF3)->F3_TIPO == "D"
								aEntr[nPos,07]	+= (cAliasSF3)->F3_ICMSRET	//ICMSRET
								If nPos > 0 .And. aEntr[nPos,01]$cMVUFECSEP
									aEntr[nPos,08] +=	(cAliasSF3)->F3_VFECPST+(cAliasSF3)->F3_VFESTMT+(cAliasSF3)->F3_VFESTRN+(cAliasSF3)->F3_VFESTMG //FECP ST
								EndIf									
							Else
								aEntr[nPos,04]	+=	(cAliasSF3)->F3_ICMSRET	//ICMSRET
							EndIf
						Endif
						If (cAliasSF3)->F3_SOLTRIB > 0
							Do Case
								Case (cAliasSF3)->F3_CREDST $ " #1"
									// N„o considerar as devoluÁıes pois elas ser„o sempre consideradas como crÈdito, na posiÁ„o 7 do array aEntr, independente do CREDST (com exceÁ„o do "4"). 
									If (cAliasSF3)->F3_TIPO <> "D"
										If !lImpCrdSt 
									     	aEntr[nPos,04]	-=	(cAliasSF3)->F3_SOLTRIB
									   	EndIf
									   	aEntr[nPos,05]	+=	(cAliasSF3)->F3_SOLTRIB
								   	EndIf
								Case (cAliasSF3)->F3_CREDST == "3"
						  			aEntr[nPos,06]	+=	(cAliasSF3)->F3_SOLTRIB
						      		aEntr[nPos,04]	-=	(cAliasSF3)->F3_SOLTRIB
						  	EndCase
						EndIf
					Endif
				Else
					lProcST := .T.                                    
					//Verifica se deve considerar esta UF na apuracao
					If !Empty(cMv_StUfS) .And. !((cAliasSF3)->F3_ESTADO$cMv_StUfS)
						lProcST := .F.
					Endif             
					If lProcST
						//Verifica se o ICMS ja foi pago em GNRE vinculada a NF
						If lChkGnre .And. (cAliasSF3)->F3_ICMSRET > 0 .And. (cAliasSF3)->F3_CREDST <> "4" .And. ChkFile("CDC")
							VerGNRENF(cAliasSF3,@aIcmPago)
						Endif
						nPos	:=	Ascan(aSaid,{|x|x[1]==(cAliasSF3)->F3_ESTADO})
						If nPos==0
							AADD(aSaid,Array(05))
							nPos	:=	Len(aSaid)
							aSaid[nPos,01]	:=	(cAliasSF3)->F3_ESTADO
							Aeval(aSaid[nPos],{|x,i|aSaid[nPos,i]:=0},2)
						Endif
						If nPos > 0 .And. aSaid[nPos,01]$cMVUFECSEP
							aSaid[nPos,05] +=	(cAliasSF3)->F3_VFECPST+(cAliasSF3)->F3_VFESTMT+(cAliasSF3)->F3_VFESTRN+(cAliasSF3)->F3_VFESTMG
						EndIf		                           
						If lResF3FT .And. Len(aResF3FT)>0
							For nX := 1 to Len(aResF3FT)
								If aResF3FT[nX][8] <> "4"
									aSaid[nPos,03]	+=	aResF3FT[nX][9] 	//BASERET
									aSaid[nPos,04]	+=	aResF3FT[nX][10]-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,aResF3FT[nX][11])	//ICMSRET
								Endif 
	                        Next
                        Else
							If (cAliasSF3)->F3_CREDST <> "4"
								aSaid[nPos,03]	+=	(cAliasSF3)->F3_BASERET
								aSaid[nPos,04]	+=	(cAliasSF3)->F3_ICMSRET-IIF(!lMVUFICSEP.Or.Left((cAliasSF3)->F3_CFO,1)<>'5'.Or.(cAliasSF3)->F3_TIPO$"BD",0,(cAliasSF3)->F3_VFECPST)
							Endif
						Endif
					Endif    
				EndIf
			EndIf
		EndIf
		
		If cImp == "IC" .And. lUsaSped .and. (cAliasSF3)->COUNTCDA >= 1 //.And. Type("aCols7") == "A" .And. Len(aCols7) >= 18
			CkLancCDA(cAliasSF3,@aApurCDA,@aCDAIC,@aCDAST,@aCDADE,@aDbEsp,cNrLivro,@aCdaDifal,@aCDAExtra,@aApurExtra,lProcRefer,aSubAp)

			//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
			//≥ Array que me retorna o lancamento de documento fiscal que corresponde ao valor do ST-Debitado na entrada (_CREDST=3)≥
			//≥ Este array eh utilizado no MATA953 para fazer a subtracao do valor da GNRE para o estado(Aba 3) do valor da GNRE que≥
			//|   serah gerado pelo Debitos Especiais atraves do lancamento de NF.                                                  |
			//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
			If Len(aDbEsp)>0 .AND. ( Type("aEntr[nPos,01]")<>"U" ) 
				aAdd(aRetEsp,{aDbEsp[1],aDbEsp[2],aEntr[nPos,01]})
			EndIf		
		EndIf
		nPos := nPosAp // Restaura nPos para ser usado no aApuracao
		//Carrega asjuste da apuraÁ„o de IPI
		If cImp == "IP" .And. lUsaSped .And. lOrigIPI .And. lNewNF .AND. (cAliasSF3)->COUNTCDA >= 1
			AjustIPI(cAliasSF3,@aCDAIPI,cNrLivro)
		Endif

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥             Apuracao de ISS por Municipio               |
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

		If cImp=="IS" .And. ValType(aApurMun)=="A"
			
			//cMunic	:=	GetNewPar( 'MV_MUNIC' , "MUNIC" )
			
			If SF2->(MsSeek(xFilial("SF2")+(cAliasSF3)->(F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA)))
				
				cPrefixo	:= 	Iif (Empty (SF2->F2_PREFIXO), &(cMV_1DUPREF), SF2->F2_PREFIXO)	//Verifica o Prefixo correto da Nota fiscal
				
				cChaveSe2   := SF2->(cPrefixo + SF2->F2_DUPL)
				
				If SE2->(MsSeek(xFilial("SE2")+cChaveSe2)) .And. SE2->E2_TIPO$MVTAXA+"|"+MVTXA .And. AllTrim(SE2->E2_NATUREZ)$&(SuperGetMv("MV_ISS"))
															
					If SA2->(MsSeek(xFilial("SA2") + SE2->(E2_FORNECE+E2_LOJA)))
						cMunic := UfCodIBGE(SA2->A2_EST) + SA2->A2_COD_MUN
						cDescMun := SA2->A2_MUN
						cForISS := SA2->A2_COD
						cLojISS := SA2->A2_LOJA
					EndIf 					
					
				Else
					
					SC5->(DbSetOrder(1))
					
					CE1->(DbSetOrder(1))
					
					SA2->(DbSetOrder(1))
					
					cChvMun := SA1->A1_EST + SA1->A1_COD_MUN

					//SIGATMS - Buscar UF+Municipio onde efetivamente ocorreu a prestacao de servico.
					If _INTTMS // IntTms()
						DT6->(DbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
						If DT6->(MsSeek(IIf(FWModeAccess("DT6",3)=="E",SF2->F2_FILIAL,xFilial("DT6"))+SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE))
							DUY->(DbSetOrder(1)) //DUY_FILIAL+DUY_GRPVEN
							If DUY->(DbSeek(xFilial("DUY")+DT6->DT6_CDRCAL))
								cChvMun := DUY->DUY_EST+DUY->DUY_CODMUN
							EndIf
						EndIf
					EndIf

					If SC5->(MsSeek(xFilial("SC5") + SD2->D2_PEDIDO))
						
						// Se preencher a UF e o municipio da prestacao no pedido de venda, considerar estes dados p/ posicionar a CE1.
						If !Empty(AllTrim(SC5->C5_ESTPRES)) .And. !Empty(AllTrim(SC5->C5_MUNPRES))
							cChvMun := SC5->C5_ESTPRES + AllTrim(SC5->C5_MUNPRES)
						EndIf 	

						lTemPedido := .T.
					Else
						lTemPedido := .F.												
					Endif	
											
					
					// Busca fornecedor do ISS no pedido de venda
					If lTemPedido .And. !(Empty(SC5->C5_FORNISS))									
							
						If SA2->(MsSeek(xFilial("SA2")+SC5->C5_FORNISS))
							cMunic	:= UfCodIBGE(SA2->A2_EST) + SA2->A2_COD_MUN
							cDescMun := SA2->A2_MUN
							cForISS := SA2->A2_COD
							cLojISS := SA2->A2_LOJA							
						EndIf
						
					// Busca pelo produto no cadastro de aliquotas(CE1)
					ElseIf CE1->(MsSeek(xFilial("CE1") + SD2->D2_CODISS + cChvMun + SD2->D2_COD))										
							
						If SA2->(MsSeek(xFilial("SA2")+CE1->CE1_FORISS+CE1->CE1_LOJISS))
							cMunic	:= UfCodIBGE(SA2->A2_EST) + SA2->A2_COD_MUN
							cDescMun := SA2->A2_MUN
							cForISS := SA2->A2_COD
							cLojISS := SA2->A2_LOJA							
						EndIf
						
					// Parametro de forn. padrao do ISS na apuracao.									
					ElseIf !Empty(cMvFPadISS) .And. SA2->(MsSeek(xFilial("SA2") + cMvFPadISS)) 					
						cMunic	:= UfCodIBGE(SA2->A2_EST) + SA2->A2_COD_MUN
						cDescMun := SA2->A2_MUN
						cForISS := SA2->A2_COD
						cLojISS := SA2->A2_LOJA		
					Else
						cMunic	:= Space(TamSX3("A2_EST")[1] + TamSX3("A2_COD_MUN")[1])
						cDescMun := Space(TamSX3("A2_MUN")[1])
						cForISS := Space(TamSX3("A2_COD")[1])
						cLojISS := Space(TamSX3("A2_LOJA")[1])	
					EndIf																																
													
				EndIf
				
				// Agrupamento dos valores por municipio.
				// Tratamento F3_RECISS: Se o cliente for responsavel por recolher o ISS, nao considerar na base de calculo.
				//                       O valor dever· compor apenas o valor cont·bil.				
				If (nContVal := aScan(aApurMun, {|aX| AllTrim(aX[1]) == AllTrim(cMunic)})) == 0
						aAdd(aApurMun,{cMunic,;
							cDescMun,;
							nF3VALCONT,;							
							(cAliasSF3)->F3_BASEICM,;
							(cAliasSF3)->F3_VALICM,;
							(cAliasSF3)->F3_ISENICM,;
							(cAliasSF3)->F3_OUTRICM,;
							(cAliasSF3)->F3_ISSMAT,;
							(cAliasSF3)->F3_ISSSUB,;
							cForIss,;
							IIf((cAliasSF3)->F3_RECISS == "1", (cAliasSF3)->F3_VALICM, 0),; // Valor de ISS Retido - Se cliente recolhe = sim.
							cLojISS})
				Else
					aApurMun[nContVal, 3] += nF3VALCONT
					aApurMun[nContVal, 4] += (cAliasSF3)->F3_BASEICM
					aApurMun[nContVal, 5] += (cAliasSF3)->F3_VALICM
					aApurMun[nContVal, 6] += (cAliasSF3)->F3_ISENICM
					aApurMun[nContVal, 7] += (cAliasSF3)->F3_OUTRICM
					aApurMun[nContVal, 8] += (cAliasSF3)->F3_ISSMAT
					aApurMun[nContVal, 9] += (cAliasSF3)->F3_ISSSUB	
					aApurMun[nContVal, 11] += IIf((cAliasSF3)->F3_RECISS == "1", (cAliasSF3)->F3_VALICM, 0) // Valor de ISS Retido - Se cliente recolhe = sim.
				EndIf				
			EndIf
		EndIf	 
			 
 	    //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	  	//≥ Na posicao 65 do aApuracao sera gravado o total Credito |
		//| ICMS Nao Dest. calculado na tabela CDM (Art.271 RICMS/SP|
		//≥ Na posicao 96 do aApuracao sera gravado o total Estornos|
		//≥ do CrÈdito ref. Devolucao Vendas do perÌodo             |
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
    	If lICMDes 
    	   aApuracao[len(aApuracao),65]:=totCDM(dDtIni,dDtFim) // Totaliza CrÈdito calculado (CDM_ICMENT)           	       	       	   
    	   aApuracao[len(aApuracao),96]:=totEST(dDtIni,dDtFim) // Totaliza Estorno do CrÈdito calculado (CDM_ESTORN) das DevoluÁıes Vendas           	       	       	   
	    endif    

 	    //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø	    
		//≥ Tratamento para geracao dos anexos V.A e V.B da GIARS   |
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ	    	    
	    If lGiaRs
	 		 If !((cAliasNotas)->(DbSeek((cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA)))	 		 
	 		 	RecLock(cAliasNotas,.T.)                
			     	(cAliasNotas)->NFISCAL := (cAliasSF3)->F3_NFISCAL
			     	(cAliasNotas)->SERIE   := (cAliasSF3)->F3_SERIE
			     	(cAliasNotas)->CLIEFOR := (cAliasSF3)->F3_CLIEFOR
			     	(cAliasNotas)->LOJA    := (cAliasSF3)->F3_LOJA   
			     	(cAliasNotas)->CRDPRES := (cAliasSF3)->F3_CRDPRES
			     	(cAliasNotas)->CFOP    := (cAliasSF3)->F3_CFO             
			   (cAliasNotas)->(MsUnlock())
	 		 EndIf                   
	 	EndIf 
	 		 	      
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Somente para o Estado do Mato Grosso         				≥
		//≥																≥
		//≥Verifica se o registro que esta sendo processado se enquadra ≥
		//≥nas regras para aplicacao do credito presumido               ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If nCredMT == 1 .And. lUfMT .And. SubStr((cAliasSF3)->F3_CFO,1,1) >= "5" .And. Alltrim((cAliasSF3)->F3_CFO) == "6101" .And. ;
		   (cAliasSF3)->F3_VALICM > 0 .And. (cAliasSF3)->F3_ESTADO <> "MT" .And. Alltrim((cAliasSF3)->F3_ESPECIE) == "SPED"                          		   		   
		
			aApuracao[Len(aApuracao),118] += FCrPreMt(cAliasSF3,aNfDupl)                                                                                       

			Aadd(aNfDupl,{(cAliasSF3)->F3_NFISCAL,;
                          (cAliasSF3)->F3_SERIE,;
                          (cAliasSF3)->F3_CLIEFOR,;
                          (cAliasSF3)->F3_LOJA})

		Else
			aApuracao[len(aApuracao),118] := 0
		EndIf 
		
		If cImp = "IS" .And. (cAliasSF3)->F3_RECISS == "1"
			aApuracao[ nPos , 132 ] += (cAliasSF3)->F3_VALICM 
		EndIf 		
		
		//Processamento dos valores da apuraÁ„o do DIFAL
		//Verifica se os campos existem na SF3 e se o DIFAL ou FECP est· preenchidos
		If lF3DIFAL .AND. lF3VFCPDIF .AND. lF3BASEDES .AND. (( cAliasSF3 )->F3_DIFAL > 0 .Or. ( cAliasSF3 )->F3_BASEDES > 0) 
			
			nFecpDest	:= (cAliasSF3)->F3_VFCPDIF
			nDifOri	:= (cAliasSF3)->F3_ICMSCOM
			nDifDest	:= (cAliasSF3)->F3_DIFAL
			cEntSaiDif:=	''
			// Debitos DIFAL:
			
			// - SaÌdas interestaduais: N„o considerar devolucoes de COMPRA.
			
			// Creditos DIFAL:
			
			// - Entradas Interestaduais e devoluÁıes de VENDA.
			// - Beneficiamentos c/ formulario proprio = SIM: Utilizado para operacoes de consignacao, por exemplo, onde
			// eh necessario utilizar o tipo "B" na nota para controle de saldo em terceiros (nao eh possivel utilizar tipo "D" nestas operacoes).
			
			If SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) == "6" .And. !( cAliasSF3 )->F3_TIPO $ "D"
				//SaÌda com dÈbito do DIFAL 
				cEntSaiDif	= '2'
			ElseIF SubStr( ( cAliasSF3 )->F3_CFO , 1 , 1 ) == "2" .And. ( ( cAliasSF3 )->F3_TIPO $ "D" .Or. ( lMVCDIFBEN .And. ( cAliasSF3 )->F3_TIPO $ "B" .And. ( cAliasSF3 )->F3_FORMUL == "S" ) )
				//Entrada com crÈdito do difal
				cEntSaiDif	= '1'		
			EndIF
				
			//---------------------------
			//DIFAL PARA ESTADO DE ORIGEM
			//---------------------------				
			nPosDifal	:=	Ascan(aDifal,{|x|x[1]==cMvEstado})
	
			// N„o apura estados que ir„o utilizar apuraÁ„o do ICMS Proprio.
			IF  !(cMvEstado $ cEstE310)
				If nPosDifal == 0
					AADD(aDifal,Array(05))
					nPosDifal	:= Len(aDifal)
					aDifal[nPosDifal,01]	:=	cMvEstado 	//UF    
					aDifal[nPosDifal,02]	:=	0									//DÈbito do Difal na saÌda
					aDifal[nPosDifal,03]	:=	0									//DÈbito do FECP na saÌda
					aDifal[nPosDifal,04]	:=	0									//CrÈdito do DIFAL na entrada
					aDifal[nPosDifal,05]	:=	0 									//CrÈdito do FECO na entrada
				EndIf
							
				If cEntSaiDif == '2' //SaÌda com DIFAL
					
					//Para o estado de origem, na saÌda teremos somente o valor do diferencial partilhado
					//O FECP È somente para estado de destino
					aDifal[nPosDifal,02]	+=	(cAliasSF3)->F3_ICMSCOM 	//DÈbito do Difal na saÌda
					
				ElseIf cEntSaiDif == '1' //Entrada (devoluÁ„o de venda com valor de DIFAL)
		
					//Na devoluÁ„o de venda dever· considerar crÈdito o valor do diferencial partilhado 
					//O FECP È somente para estado de destino
					aDifal[nPosDifal,04]	+=	(cAliasSF3)->F3_ICMSCOM 	//DÈbito do Difal na saÌda
								
				EndIF 
			EndIF							
			//----------------------------
			//DIFAL PARA ESTADO DE DESTINO
			//----------------------------
			If (cAliasSF3)->F3_ESTADO $ cMV_SubTr .Or. (cAliasSF3)->F3_ESTADO $ cMV_DifTr
				nPosDifal	:=	Ascan(aDifal,{|x|x[1]==(cAliasSF3)->F3_ESTADO })			
				If nPosDifal == 0
					AADD(aDifal,Array(05))
					nPosDifal	:= Len(aDifal)
					aDifal[nPosDifal,01]	:=	(cAliasSF3)->F3_ESTADO 		//UF    
					aDifal[nPosDifal,02]	:=	0						//DÈbito do Difal na saÌda
					aDifal[nPosDifal,03]	:=	0						//DÈbito do FECP na saÌda
					aDifal[nPosDifal,04]	:=	0								//CrÈdito do DIFAL na entrada
					aDifal[nPosDifal,05]	:=	0 								//CrÈdito do FECO na entrada
				EndIF		
					
				//Para estado de destino teremos o diferencial partilhado
				//E tambÈm o fecp integral
				
				If cEntSaiDif == '2' //SaÌda com DIFAL
					aDifal[nPosDifal,02]	+=	nDifDest			//DÈbito do Difal na saÌda
					aDifal[nPosDifal,03]	+=	nFecpDest			//DÈbito do FECP na saÌda		
				Elseif cEntSaiDif == '1' //SaÌda com DIFAL
					aDifal[nPosDifal,04]	+=	nDifDest			//DÈbito do Difal na saÌda
					aDifal[nPosDifal,05]	+=	nFecpDest			//DÈbito do FECP na saÌda				
				EndIF
			EndIF
		
		EndIF

		/*
		Aqui ser„o acumulados o valor cont·bil das saÌdas para aba Fomentar de GO. Ser„o acumuladas as saÌdas com exceÁ„o das devoluÁıes,
		remessas para industrializaÁ„o/beneficiamento, remessa para a depÛsito/armazÈm e saÌdas que constituem mera movimentaÁ„o fÌsica.
		*/
		IF lFomentGO .AND. Left( Alltrim( ( cAliasSF3 )->F3_CFO ) , 1 ) >= "5"  .AND. !( cAliasSF3 )->F3_TIPO $ "B/D" .AND. !alltrim(( cAliasSF3 )->F3_CFO) $ cCfMeraMov
			aApuracao[nPos,142]	+= nF3VALCONT
		EndIF

		/*Aqui acumularei os valores de crÈditos por entrada no perÌodo, para ser exibido na apuraÁ„o do Fomentar de GO. 
		Ser„o consideradas as entradas com crÈdito, porÈm as entradas que tiverem o CFOP contido no par‚metro cCfCrdFo n„o ser„o consideradas				
		*/
		IF lFomentGO .AND. Left( Alltrim( ( cAliasSF3 )->F3_CFO ) , 1 ) <= "3" .AND. !( cAliasSF3 )->F3_TIPO $ "B/D" .AND. !alltrim(( cAliasSF3 )->F3_CFO) $ cCfCrdFo
			aApuracao[nPos,145]	+= (cAliasSF3)->F3_VALICM
		EndIF					

		nPos += 1		
		
		lNewNF := .F.
		
		(cAliasSF3)->(dbSkip())
	Enddo           

	If lPARICMS .And. nPos > 0 .And. cImp == "IC"                                       
	    aCIAP				:= FsApCiap(dDtIni,dDtFim)
		aApuracao[Len(aApuracao),18]	:= IIf(Len(aCIAP)>2,aCIAP[3],0)
	Endif
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Exclui arquivo temporario≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ		
	/* TRECHO COMENTADO POIS O TRATAMENTO DO MAPA RESUMO FOI RETIRADO DA XApurRF3Nw (MULTITHREAD) EM 06/12/2012. */
	/*If lMapResumo
		MaXRExecArq(2,cArqTmpMP)
		cAliasSf3 := cArqBkpQry
		DbSelectArea(cAliasSF3)
	EndIf*/			                                                       	

    //⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
    //≥ Fecha a area de trabalho da query                            ≥
    //¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ

	#IFDEF TOP
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	#ENDIF 
	
	//Chama funÁ„o da rotina FISR017 para buscar o valor do Ressarcimento de ICMS.
	IF cMvEstado $ "BA" .AND. aFindFunc[FF_SELRELR017] .AND. Len(aApuracao) > 0
		aApuracao[len(aApuracao)][129]+=SelRelR017("BA",dDtIni,dDtFim,.T.)
	EndIF
	If FWModeAccess("SF3",3)=="C"
		Exit
	Endif
	
	SM0->( dbSkip())
Enddo

If lConfApur .AND. lAliasApur
	If cImp=="IC"
		( cAlsDeb )->(DbCloseArea())
		( cAlsCrd )->(DbCloseArea())
		( cAlsSTd )->(DbCloseArea())
		( cAlsSTe )->(DbCloseArea())
	elseif cImp =="IP"
		( cAlsIPIs )->(DbCloseArea())
		( cAlsIPIe )->(DbCloseArea())
	Endif
Endif
If lQuery
    If Select(cAliasSF3)>0
	   dbSelectArea(cAliasSF3)
	   RetIndex()
	   Ferase(cAliasSF3)
	Endif   
Else
	RetIndex("SF3")
	dbClearFilter()
	Ferase(cIndSF3+OrdBagExt()) 
EndIf

SM0->(dbGoTo(nRegEmp))
cFilAnt := SM0->M0_CODFIL

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Sorteia a apuracao                                           ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If lQbAliq.and.!lQbCFO
	aApuracao	:=	Asort(aApuracao,,,{|x,y|x[2]<y[2]})
Elseif lQbUfCfop
	aApuracao	:=	Asort(aApuracao,,,{|x,y|x[19]+x[1]<y[19]+y[1]})
Else
	aApuracao	:=	Asort(aApuracao,,,{|x,y|x[1]+StrZero(100000000000000-x[11],15)<y[1]+StrZero(100000000000000-y[11],15)})
Endif

If lGeraArq .And. ( cImp == "IC" .Or. cImp == "IP" )
	nPos := 0
	dbSelectArea(cAliasTRB)
	For nPos:= 1 to Len(aApuracao)
		Reclock(cAliasTRB,.T.)                 
	    ISSSUB	:=	aApuracao[nPos,29]
		If lQbUF
			UF 	:= aApuracao[nPos,19]			
			//Nao Contribuinte
			VALCONNC := aApuracao[nPos,25]
			BASEICNC := aApuracao[nPos,26]	
			//Contribuinte
			VALCONC  := aApuracao[nPos,27]
			BASEICC  := aApuracao[nPos,28]
		EndIf				
		If lQbPais .and. Len(aCodPais) >= 1
			CODPAIS	:= aApuracao[nPos,20]			
		EndIf				
		If lQbCfopUf
			ALIQICMS := aApuracao[nPos,02]
			UF		 := aApuracao[nPos,19]			
		Endif
		If lQbUfCfop
			UF		 := aApuracao[nPos,19]
		Endif

		CFOP 	:= aApuracao[nPos,01]
		VALCONT := aApuracao[nPos,11]
		BASEICM := aApuracao[nPos,03]
		BSICMOR := aApuracao[nPos,137] 
		VALICM	:= aApuracao[nPos,04]
		ISENICM	:= aApuracao[nPos,05]
		OUTRICM := aApuracao[nPos,06]
		BASERET := aApuracao[nPos,07]
		If lGIARS .AND. aApuracao[nPos,43] > 0 
			ICMSRET := aApuracao[nPos,43]
		Else
			ICMSRET := aApuracao[nPos,08]
		EndIf		
		VLEXCLRS:= aApuracao[nPos,123]
		VlRETIC := aApuracao[nPos,140] // Valor das excluidas de St GIARS anexo IC
		If Substr(Alltrim(aApuracao[nPos,01]),1,3)=="000" .Or. Substr(Alltrim(aApuracao[nPos,01]),1,4)$"1601#1602#5601#5602"
			TRFICM 	:= aApuracao[nPos,15]
		ElseIf Substr(Alltrim(aApuracao[nPos,01]),1,3)=="999" .Or. Substr(Alltrim(aApuracao[nPos,01]),1,4)$"1605#5605"
			TRFICM 	:= aApuracao[nPos,16]
		Else
			TRFICM 	:= 0
		Endif
		ICMSCOM := aApuracao[nPos,10]
		If cImp == "IC"
           VALIPI := aApuracao[nPos,24]
           IPIOBS := aApuracao[nPos,46]
           VLIPIOBS := aApuracao[nPos,138]
		EndIf
		If Substr(Alltrim(aApuracao[nPos,01]),1,1)$"123"
			ESTCRED		:=	aApuracao[nPos,47]
		Else
			ESTCRED		:=	aApuracao[nPos,49]
		Endif	
		MsUnLock()
	Next nPos
ElseIf lGeraArq .and. cImp == "IS"
	nPos := 0
	dbSelectArea(cAliasTRB)
	For nPos:= 1 to Len(aApuracao)
		Reclock(cAliasTRB,.T.)                 
		CODISS  := aApuracao[nPos,01] 
		ALIQISS := aApuracao[nPos,02] 
		VALCONT := aApuracao[nPos,11]
		BASEISS := aApuracao[nPos,03]
		VALISS	:= aApuracao[nPos,04]
		ISENISS	:= aApuracao[nPos,05]
		OUTRISS := aApuracao[nPos,06]
		MsUnLock()
	Next nPos
EndIf

RestArea(aArea)

If lBuild
	FreeObj(oHashCFOP)
	oHashCFOP := NIL

	FreeObj(oHasCodAju)
	oHasCodAju := NIL	

	FreeObj(oHashCFUF)
	oHashCFUF := NIL
Endif

If !lGeraArq
	RETURN (aApuracao)
Else
	 If lGiaRs
		RETURN ({cArqTRB,cArqTRBSF3})	
	 Else
	 	RETURN (cArqTRB)
	 EndIf		
EndIf
//-----------------------------------------------------------------------
/*/{Protheus.doc} XATestTemp
Funcao criada para testar a estrutura da tabela criada atraves do 
processo de multithread
		
@return		

@author		Fabio V. Santana
@since		18/09/2014
@version	11.8
/*/
//-----------------------------------------------------------------------
Function XATestTemp(cTempDB, cAlsTempDB, nTamArray)

Local nColunas 	:= 0
Local aStruct 	:= {}
Local nOpcApur  := 3
Local cMsgTemp	:= ""

If TcCanOpen( cTempDB )   

	dbUseArea( .T. ,__cRdd , cTempDB , cAlsTempDB , .T. , .F. )

	aStruct := (cAlsTempDB)->(DBSTRUCT())
	nColunas :=  Len(aStruct)  
	
	If nColunas <> nTamArray  
  	
		cMsgTemp	:= STR0138  				//" A apuraÁ„o deste tributo para este perÌodo, j· foi gerada em outro momento,"
		cMsgTemp	+= STR0139  				// " porÈm a estrutura da tabela criada a partir da utilizaÁ„o desta rotina em"
		cMsgTemp	+= STR0140 + CRLF 			//" multithread, n„o est· de acordo com as informaÁıes mais atualizadas." 
		cMsgTemp	+= STR0141 + CRLF + CRLF  	//" Para que os dados sejam apresentados de maneira correta, ser· necessario recriar esta tabela." 
		cMsgTemp	+= STR0142 					//Deseja Recriar?
		
		lOk	:=	MsgYesNo( cMsgTemp , STR0127)
			
		If lOk
			nOpcApur := 1
		Else
			nOpcApur := 4
		EndIf
		
	EndIf

( cAlsTempDB )->( dbCloseArea() )

EndIf

Return nOpcApur

//-----------------------------------------------------------------------
/*/{Protheus.doc} Credito Presumido
Funcao criada para estorno do credito presumido

@param		cNumLote	Numero do SubLote.
@param		cLoteClt	Numero do lote.
@param 		cProduto   Codigo do produto
@param 		cEstado    Estado
@param 		nQdeVda    Quantidade vendida
@param 		nOper      1-Nacional 2-Importacao 3-Ambos
@param 		dDtIni		Data inicial do periodo
@param 		dDtFim		Data final do periodo
@param 		cNCMESTC	NCM a considerar
@param 		dDTCOREC	Data de corte
		
@return	nVlrEstor   Valor estorno

@author	Mauro A. Goncalves
@since		10/01/2014
@version	11.8
/*/
//-----------------------------------------------------------------------
Function EstCrePres(cAliasSF3, cEstado, nOper, dDtIni, dDtFim, cNCMESTC, dDTCOREC)
Local cAlsQry	:= ""
Local cAlsCG1	:= ""
Local lPrdCpa	:= .F.
Local nCRPREPR	:= 0
Local nQTDUSO	:= 0
Local nQTDENT	:= 0
Local nVlrEstor	:= 0
Local cChaveSFT	:= ""
Local cNumLote 	:= ""
Local cLoteCtl 	:= ""
Local cProduto 	:= ""
Local nQdeVda	:= 0
Local aNFOri	:= {}
Local cTipMov := IIf((cAliasSF3)->F3_TIPO=="D","E","S")
Local cChaveSD2	:= ""

Static aNFProc := {} //usado para controlar as devolucoes processadas
                                                                          
If (TcSrvType ()<>"AS/400")	
	dDTCOREC	:= IIf(Empty(dDTCOREC), CTOD("1900/01/01"), dDTCOREC) 
	cChaveSFT 	:= xFilial("SFT")+cTipMov+(cAliasSF3)->(F3_CLIEFOR+F3_LOJA+F3_SERIE+F3_NFISCAL+F3_IDENTFT)

	SFT->(dbSetOrder(3))            
	SFT->(dbSeek(cChaveSFT))   				
	While !SFT->(Eof()) .And. cChaveSFT==xFilial("SFT")+SFT->(cTipMov+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL+FT_IDENTF3)
		//Se for devolucao localiza a NF original
		If (cAliasSF3)->F3_TIPO=="D" 
			cChaveSD2 := xFilial("SD2")+SFT->(FT_NFORI+FT_SERORI+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEMORI)
		Else	
			cChaveSD2 := xFilial("SD2")+SFT->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM)		
		Endif
		//Verifica se o registro ja foi processado
		If Ascan(aNFProc,cChaveSD2)>0
			SFT->(dbSkip())
			Loop
		Endif
		
		If SD2->(MsSeek(cChaveSD2))		
			nQdeVda := SD2->D2_QUANT
			If (cAliasSF3)->F3_TIPO=="D" //Se for devolucao localiza a NF de Venda
				AADD(aNFProc,cChaveSD2)  
				aNFOri := SFT->(GETITENF(FT_NFORI,FT_SERORI,FT_ITEMORI,FT_PRODUTO,FT_CLIEFOR,FT_LOJA,{"FT_EMISSAO","FT_QUANT"},cEstado,cNCMESTC))
				//Verifica se a devolucao esta dentro do periodo
			   If !(aNFOri[1] >= dDtIni .And. aNFOri[1] <= dDtFim)
					nQdeVda := SFT->FT_QUANT * -1
				Else	
					nQdeVda -= SFT->FT_QUANT
				Endif	
			Else  //Verifica se ouve devolucao da NF Venda
				aNFOri := SFT->(GETITENFORI(FT_NFISCAL,FT_SERIE,FT_ITEM,FT_PRODUTO,FT_CLIEFOR,FT_LOJA,{"FT_EMISSAO","FT_QUANT"}))
				If Len(aNFOri)>0
					//Verifica se a devolucao esta dentro do periodo
					If aNFOri[1] >= dDtIni .And. aNFOri[1] <= dDtFim 
						nQdeVda -= aNFOri[2]
					Endif	
				Endif	 		
			Endif	
			cNumLote 	:= SD2->D2_NUMLOTE
			cLoteCtl 	:= SD2->D2_LOTECTL
			cProduto 	:= SD2->D2_COD
		    //Verifica se o produto eh produzido ou comprado. Se COUNT() maior que zero eh produzido
			cAlsCG1	:=	GetNextAlias()	
			BeginSql Alias cAlsCG1	
				SELECT COUNT(G1_COD) As PrdAcab
				FROM %Table:SG1% SG1
				WHERE SG1.G1_FILIAL=%xFilial:SG1% AND G1_COD=%Exp:cProduto% AND SG1.%NotDel%
			EndSql                                      
			lPrdCpa := (cAlsCG1)->PrdAcab <= 0
			(cAlsCG1)->(DbCloseArea())
			//Produzido
			cAlsQry	:=	GetNextAlias()
			If !lPrdCpa
				BeginSql Alias cAlsQry
					COLUMN FT_EMISSAO	AS DATE
					SELECT SD3.D3_LOTECTL,SD3.D3_NUMLOTE,SD3.D3_QUANT,SD1.D1_COD,SD1.D1_ITEM,SD1.D1_QUANT As QTDENT,SFT.FT_ESTADO,SFT.FT_CRDPRES,SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_EMISSAO,SD5.D5_QUANT/SD3.D3_QUANT As QTDUSO
					FROM %Table:SD3% SD3
					JOIN %Table:SD5% SD5 ON(SD5.D5_FILIAL=%xFilial:SD5% AND SubString(SD5.D5_OP,1,8)=SubString(SD3.D3_OP,1,8) AND SD5.D5_ORIGLAN<>'01' AND SD5.D5_ESTORNO<>'S' AND SD5.%NotDel%)
					JOIN %Table:SD1% SD1 ON(SD1.D1_FILIAL=%xFilial:SD1% AND SD1.D1_LOTECTL=SD5.D5_LOTECTL AND SD1.D1_NUMLOTE=SD5.D5_NUMLOTE AND SD1.%NotDel%)
					JOIN %Table:SFT% SFT ON(SFT.FT_FILIAL=%xFilial:SFT% AND SFT.FT_NFISCAL=SD1.D1_DOC AND SFT.FT_SERIE=SD1.D1_SERIE AND SFT.FT_CLIEFOR=SD1.D1_FORNECE AND SFT.FT_LOJA=SD1.D1_LOJA AND SFT.FT_ITEM=SD1.D1_ITEM AND SFT.FT_PRODUTO=SD1.D1_COD AND SFT.FT_CRDPRES>0 AND SFT.%NotDel%)
					JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1% AND SB1.B1_COD=%Exp:cProduto% AND SB1.B1_POSIPI IN('05040012','05040013') AND SB1.%NotDel%)
					WHERE 
						SD3.D3_FILIAL = %xFilial:SD3% AND 
						SD3.D3_OP<>'             ' AND
						SD3.D3_COD = %Exp:cProduto% AND
						SD3.D3_LOTECTL = %Exp:cLoteCtl% AND
						SD3.D3_NUMLOTE = %Exp:cNumLote% AND
						SD3.D3_ESTORNO <> 'S' AND
						SD3.%NotDel%
				EndSql		
			Else
				BeginSql Alias cAlsQry
					COLUMN FT_EMISSAO	AS DATE
					SELECT SB8.B8_QTDORI As QTDENT,SB8.B8_ORIGLAN,SFT.FT_ESTADO,SFT.FT_CRPREPR,SFT.FT_CRDPRES,FT_EMISSAO,0 as QTDUSO 
					FROM %Table:SB8% SB8
					JOIN %Table:SD1% SD1 ON(SD1.D1_FILIAL=%xFilial:SD1% AND SD1.D1_LOTECTL=SB8.B8_LOTECTL AND SD1.D1_NUMLOTE=SB8.B8_NUMLOTE AND SD1.%NotDel%)
					JOIN %Table:SFT% SFT ON(SFT.FT_FILIAL=%xFilial:SFT% AND SFT.FT_TIPOMOV='E' AND SFT.FT_SERIE=SD1.D1_SERIE AND SFT.FT_NFISCAL=SD1.D1_DOC AND SFT.FT_CLIEFOR=SD1.D1_FORNECE AND SFT.FT_LOJA=SD1.D1_LOJA AND SFT.FT_ITEM=SD1.D1_ITEM AND SFT.FT_PRODUTO=SD1.D1_COD AND FT_CRDPRES>0 AND SFT.%NotDel%)
					JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1% AND SB1.B1_COD=%Exp:cProduto% AND SB1.B1_POSIPI IN('05040012','05040013') AND SB1.%NotDel%)
					WHERE 
						SB8.B8_FILIAL = %xFilial:SB8% AND 
						SB8.B8_PRODUTO = %Exp:cProduto% AND
						SB8.B8_LOTECTL = %Exp:cLoteCtl% AND
						SB8.B8_NUMLOTE = %Exp:cNumLote% AND
						SB8.%NotDel%				
				EndSql		
			Endif	
	       nQTDENT 	:= 0
			nCRPREPR	:= 0
			nQTDUSO	:= 0
			While !(cAlsQry)->(EOF())                          
				//Parana
				//Verifica a data de corte
		       If cEstado=="PR" .And. (cAlsQry)->FT_EMISSAO >= dDTCOREC 							        
					If nOper==1 .And. (cAlsQry)->FT_ESTADO<>'EX'		//Nacional
				        nQTDENT 	+= (cAlsQry)->QTDENT
						nCRPREPR	+= (cAlsQry)->FT_CRDPRES 
						nQTDUSO		+= (cAlsQry)->QTDUSO
					ElseIf nOper==2 .And. (cAlsQry)->FT_ESTADO=='EX'	//Importado
				        nQTDENT 	+= (cAlsQry)->QTDENT
						nCRPREPR	+= (cAlsQry)->FT_CRDPRES 
						nQTDUSO		+= (cAlsQry)->QTDUSO
					ElseIf nOper==3										//Ambos
				        nQTDENT 	+= (cAlsQry)->QTDENT
						nCRPREPR	+= (cAlsQry)->FT_CRDPRES 
						nQTDUSO		+= (cAlsQry)->QTDUSO
					Endif	
				Endif	
				(cAlsQry)->(DbSkip())
			Enddo
			If lPrdCpa			
				nVlrEstor += (nCRPREPR / nQTDENT) * nQdeVda
			Else	
				nVlrEstor += ((nCRPREPR / nQTDENT) * nQTDUSO) * nQdeVda
			Endif	
			(cAlsQry)->(DbCloseArea())
		Endif		
		SFT->(DbSkip())
	Enddo			
Endif
Return nVlrEstor
//-----------------------------------------------------------------------
/*/{Protheus.doc} GETITENFORI 
Funcao criada para localizar o Item da NF Original na tabela SFT

@param		cNF			Numero da NF
@param		cSer		Serie
@param 		cIte		Numero do Item
@param 		cPrd		Codigo do Produto
@param 		cCliFor    Codigo do Cliente/Fornecedor
@param 		nLoja    	Loja do Cliente/Fornecedor
@param 		aCPO    	Nome dos campos que o conteudo sera retornado
		
@return	aCPO		Retorna o conteudo dos campos

@author	Mauro A. Goncalves
@since		26/10/2014
@version	11.8
/*/
//-----------------------------------------------------------------------
Function GETITENFORI(cNF,cSer,cIte,cPrd,cCliFor,cLoja,aCPO)
Local cAlsQry	:= ""
Local cCpos	:= ""
Local nA		:= 0

Default aCPO := {}

If (TcSrvType ()<>"AS/400")	
	cAlsQry :=	GetNextAlias()
	//Campos que serao retornados
	For nA := 1 to Len(aCPO)
		cCpos += aCPO[nA] + ","
	Next
	cCpos := "%" + IIf(Empty(cCpos),"*",Left(cCpos,Len(cCpos)-1)) + "%"		                                             			

	BeginSql Alias cAlsQry
	
		COLUMN FT_EMISSAO AS DATE
			
		SELECT	%Exp:cCpos%
		 
		FROM %Table:SFT%
		WHERE	FT_FILIAL = %xFilial:SFT% AND 
				FT_NFORI = %Exp:cNF% AND
				FT_SERORI = %Exp:cSer% AND
				FT_ITEMORI = %Exp:cIte% AND
				FT_PRODUTO = %Exp:cPrd% AND
				FT_CLIEFOR = %Exp:cCliFor% AND
				FT_LOJA = %Exp:cLoja% AND
				%NotDel%
				
	EndSql

	aCPO := {}
	For nA:=1 To (cAlsQry)->(FCOUNT())
		AADD(aCPO,(cAlsQry)->(FIELDGET(nA)))
	Next
	
	(cAlsQry)->(DbCloseArea())
Endif

Return aCPO
//-----------------------------------------------------------------------
/*/{Protheus.doc} GETITENF 
Funcao criada para localizar o Item da NF na tabela SFT

@param		cNF			Numero da NF
@param		cSer		Serie
@param 		cIte		Numero do Item
@param 		cPrd		Codigo do Produto
@param 		cCliFor    Codigo do Cliente/Fornecedor
@param 		nLoja    	Loja do Cliente/Fornecedor
@param 		aCPO    	Nome dos campos que o conteudo sera retornado
@param 		nQry		Define a selecao dos dados conforme necessidade
		
@return	aCPO		Retorna o conteudo dos campos

@author	Mauro A. Goncalves
@since		26/10/2014
@version	11.8
/*/
//-----------------------------------------------------------------------
Function GETITENF(cNF,cSer,cIte,cPrd,cCli,cLoj,aCPO,cEstado,cNCMESTC)
Local cAlsQry	:= ""
Local cWhere	:= ""
Local cCpos	:= ""
Local nA		:= 0

Default aCPO	:= {}
Default nQry	:= 1  

If (TcSrvType ()<>"AS/400")	
	cAlsQry :=	GetNextAlias()
	If !Empty(cNCMESTC)
		cNCMESTC := " AND FT_POSIPI IN(" + cNCMESTC + ") "
	Else	
		cNCMESTC := IIf(cEstado=="PR", " AND FT_POSIPI IN('05040012','05040013') ", "") 	 
	Endif
	
	//Campos que serao retornados
	For nA := 1 to Len(aCPO)
		cCpos += aCPO[nA] + ","
	Next
	cCpos := "%" + IIf(Empty(cCpos),"*",Left(cCpos,Len(cCpos)-1)) + "%"		                                             			
	
	//Monta a regra de selecao
	If cEstado=="PR"
		cWhere	+= " SUBSTRING(FT_CFOP,1,1)='6' "+cNCMESTC+" AND "
		cWhere += " FT_ESTADO<>'AM' AND FT_CODISS = '" + Space(TamSx3('FT_CODISS')[1]) + "' AND "
	ElseIf cEstado=="PE"
		cWhere	+= " SUBSTRING(FT_CFOP,1,1)='6' "+cNCMESTC+" AND "
		cWhere += " FT_CODISS = '" + Space(TamSx3('FT_CODISS')[1]) + "' AND "
	Endif	
	cWhere	:= "%" + cWhere + "%"		                                             			

	BeginSql Alias cAlsQry
	
		COLUMN FT_EMISSAO AS DATE
			
		SELECT FT_EMISSAO, FT_QUANT 
		FROM %Table:SFT%
		WHERE	FT_FILIAL = %xFilial:SFT% AND 
				FT_NFISCAL = %Exp:cNF% AND
				FT_SERIE = %Exp:cSer% AND
				FT_ITEM = %Exp:cIte% AND
				FT_PRODUTO = %Exp:cPrd% AND
				FT_CLIEFOR = %Exp:cCli% AND
				FT_LOJA = %Exp:cLoj% AND
				%Exp:cWhere%
				%NotDel%
				
	EndSql

	aCPO := {}
	For nA:=1 To (cAlsQry)->(FCOUNT())
		AADD(aCPO,(cAlsQry)->(FIELDGET(nA)))
	Next
	
	(cAlsQry)->(DbCloseArea())
Endif
Return aCPO

//-----------------------------------------------------------------------
/*/{Protheus.doc} GetSumDH0 
Funcao criada para somar DH0

@param		cAno		Ano a ser levado em consideraÁ„o
@param		cMes		Mes a ser levado em consideraÁ„o
@param		cImposto	Imposto a ser levado em consideraÁ„o

@return	nTotal		Retorna total 

@author	Leonardo Quintania
@since		08/04/2015
@version	11
/*/
//-----------------------------------------------------------------------
Function GetSumDH0(cDataIni,cDataFim,cImposto)
Local nTotal	:= 0

BeginSql Alias "DH0TMP"	
	SELECT SUM(DH0_VALICM) DH0_VALICM,
			SUM(DH0_VALIPI) DH0_VALIPI,
			SUM(DH0_VALPIS) DH0_VALPIS,
			SUM(DH0_VALCOF) DH0_VALCOF 
	FROM %Table:DH0%
		WHERE DH0_FILIAL = %xFilial:DH0% 
			AND DH0_DATA BETWEEN %Exp:cDataIni% AND %Exp:cDataFim% 
			AND %NotDel%
EndSql

If !DH0TMP->(EOF())
	If cImposto == "ICM"
		nTotal:= DH0TMP->DH0_VALICM
	ElseIf cImposto == "IPI"
		nTotal:= DH0TMP->DH0_VALIPI
	ElseIf cImposto == "PIS"
		nTotal:= DH0TMP->DH0_VALPIS
	ElseIf cImposto == "CONFINS"
		nTotal:= DH0TMP->DH0_VALCOF
	EndIf
EndIf

DH0TMP->(DbCloseArea())

Return nTotal
//-----------------------------------------------------------------------
/*/{Protheus.doc} Estorno de Credito ImportaÁ„o
Funcao criada para estorno do credito de ICMS de ImportaÁ„o

@param		cAliasSF3	Alias da tabela tempor·ria SF3.
@param		cMvEstado	Estado de localizaÁ„o do contribuinte.
@param 		dDtIni		Data Inicial da ApuraÁ„o
@param 		dDtFim		Data Final da ApuraÁ„o
		
@return	nVlrEstor   Valor estorno

@author	Cleber Maldonado
@since		05/05/2015
@version	11.9
/*/
//-----------------------------------------------------------------------
Function EstCreImp(cAliasSF3,cMvEstado,dDtIni,dDtFim,cNCMESTC)
Local	aArea		:= GetArea()
Local	nQTDENT	:= 0
Local	nVALICM	:= 0
Local	nVlrEstor	:= 0
Local	cAlsQry	:= ""
Local	lContrib	:= .F.
Local	cTipMov	:= IIf((cAliasSF3)->F3_TIPO=="D","E","S")

dbSelectArea("SB1")
If (TcSrvType ()<>"AS/400")	
	cChaveSFT 	:= xFilial("SFT")+cTipMov+(cAliasSF3)->(F3_CLIEFOR+F3_LOJA+F3_SERIE+F3_NFISCAL+F3_IDENTFT)
	SFT->(DbSetOrder(3))            
	SFT->(dbSeek(cChaveSFT))
	//OperaÁ„o valida para contribuinte dentro do estado e n„o contribuinte fora
	Posicione("SA1",1,xFilial("SA1")+SFT->FT_CLIEFOR+SFT->FT_LOJA,"A1_INSCR")
	lContrib := IIf(Empty(SA1->A1_INSCR) .Or. "ISENT"$SA1->A1_INSCR .Or. "RG"$SA1->A1_INSCR .Or. SA1->A1_CONTRIB=="2",.F.,.T.)	
	If SA1->A1_CONTRIB=="1" .And. SA1->A1_TPJ=="3" .And. Empty(SA1->A1_INSCR)
		lContrib := .F.
	Endif	
	While !SFT->(Eof()) .And. cChaveSFT==xFilial("SFT")+SFT->(cTipMov+FT_CLIEFOR+FT_LOJA+FT_SERIE+FT_NFISCAL+FT_IDENTF3)
		SB1->(MsSeek(xFilial("SB1")+SFT->FT_PRODUTO))
		If !(SB1->B1_ORIGEM$"1|2|6|7" .And. AllTrim(SB1->B1_POSIPI)$cNCMESTC)
			SFT->(DbSkip())
			Loop		
		Endif
	
		//Contribuinte dentro do estado - N„o contribuinte fora do estado
		If (!lContrib .And. Substr(SFT->FT_CFOP,1,1)$"5") .Or. (lContrib .And. Substr(SFT->FT_CFOP,1,1)$"6")
			SFT->(DbSkip())
			Loop		
		Endif
		
		cChaveSD2 := xFilial("SD2")+SFT->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM)		
		SD2->(DbSetOrder(3))            
		If SD2->(MsSeek(cChaveSD2))
			If Rastro(SD2->D2_COD)  
				nQdeVda := SD2->D2_QUANT
				//Verifica se ouve devolucao da NF Venda
				aNFOri := SFT->(GETITENFORI(FT_NFISCAL,FT_SERIE,FT_ITEM,FT_PRODUTO,FT_CLIEFOR,FT_LOJA,{"FT_EMISSAO","FT_QUANT"}))
				If Len(aNFOri)>0
					//Verifica se a devolucao esta dentro do periodo
					If aNFOri[1] >= dDtIni .And. aNFOri[1] <= dDtFim 
						nQdeVda -= aNFOri[2]
					Endif	
				Endif	 		
				cNumLote 	:= SD2->D2_NUMLOTE
				cLoteCtl 	:= SD2->D2_LOTECTL
				cProduto 	:= SD2->D2_COD
				cAlsQry		:= GetNextAlias()			
				BeginSql Alias cAlsQry
					SELECT SD1.D1_QUANT,SD1.D1_VALICM 
					FROM %Table:SB8% SB8
					JOIN %Table:SD1% SD1 ON(SD1.D1_FILIAL=%xFilial:SD1% AND SD1.D1_LOTECTL=SB8.B8_LOTECTL AND SD1.D1_NUMLOTE=SB8.B8_NUMLOTE AND SD1.%NotDel%)
					JOIN %Table:SFT% SFT ON(SFT.FT_FILIAL=%xFilial:SFT% AND SFT.FT_TIPOMOV='E' AND SFT.FT_SERIE=SD1.D1_SERIE AND SFT.FT_NFISCAL=SD1.D1_DOC AND SFT.FT_CLIEFOR=SD1.D1_FORNECE AND SFT.FT_LOJA=SD1.D1_LOJA AND SFT.FT_ITEM=SD1.D1_ITEM AND SFT.FT_PRODUTO=SD1.D1_COD AND SFT.%NotDel%)
					WHERE 
					SB8.B8_FILIAL = %xFilial:SB8% AND 
						SB8.B8_PRODUTO = %Exp:cProduto% AND
						SB8.B8_LOTECTL = %Exp:cLoteCtl% AND
						SB8.B8_NUMLOTE = %Exp:cNumLote% AND
						SB8.%NotDel%				
				EndSql
				While !(cAlsQry)->(Eof())
	    	    	nQTDENT 	+= (cAlsQry)->D1_QUANT
					nVALICM		+= (cAlsQry)->D1_VALICM
					(cAlsQry)->(DbSkip())			
				End
				nVlrEstor += (nVALICM / nQTDENT) * nQdeVda
			Endif
		Endif
	SFT->(DbSkip())		
	End
Endif
RestArea(aArea)
Return nVlrEstor

//-------------------------------------------------------------------
/*/{Protheus.doc} ApurCDV
Funcao que apura informaÁıes adicionais de apuraÁ„o - valores declaratÛrios para geraÁ„o do registro E115 da EFD

@param 	aApurCDV - Array para armazenar os codigos		

@return 

@author Marsaulo D. Souza
@since 04/08/2017
@version 1.0
/*/

Static Function ApurCDV(cAliasSF3,aApurCDV,lMVRF3THRE)
Local nPos   := 0
Local nValST := 0
Local nValDif:= 0
Local cChave := ""
Local cDesc  := ""
Local lCST   := aApurSX3[FP_F3K_CST]
Local cChaveCST := ""

Default aApurCDV := {}
Default lMVRF3THRE := .F.

If !lMVRF3THRE
	nValST  := SFT->(FT_ICMSRET+FT_OUTRRET+FT_ISENRET)
	nValST  := SFT->(Iif(nValST>0,nValST,FT_OBSSOL))
	cChave  := xFilial("SFT")+SFT->(FT_PRODUTO+FT_CFOP)
	cChaveCST := Substr(SFT->FT_CLASFIS,2,2)
	If SFT->FT_COLVDIF $ "1/2"
		nValDif := SFT->FT_ICMSDIF
	Else
		nValDif := SFT->(FT_OUTRICM+FT_ISENICM)-SFT->FT_BASEICM
	EndIf
Else
	nValST  := (cAliasSF3)->FT_ICMSRET
	nValST  := (cAliasSF3)->(Iif(nValST>0,nValST,FT_OBSSOL))
	cChave  := (cAliasSF3)->(F3_FILIAL+FT_PRODUTO+FT_CFOP)
	cChaveCST := SubStr((cAliasSF3)->FT_CLASFIS,2,2)
	If (cAliasSF3)->FT_COLVDIF $ "1/2"
		nValDif := (cAliasSF3)->FT_ICMSDIF
	Else
		nValDif := (cAliasSF3)->(FT_OUTRICM+FT_ISENICM)-(cAliasSF3)->FT_BASEICM
	EndIf
EndIf

While F3K->(!Eof()) .And. cChave == F3K->(F3K_FILIAL+F3K_PROD+F3K_CFOP)

	If lCST
		If !Empty(F3K->F3K_CST) .And. cChaveCST != F3K->F3K_CST
			F3K->(DbSkip())
			Loop
		EndIf
	EndIf

	nPos:=aScan(aApurCDV,{|aX|aX[1] == F3K->F3K_CFOP .AND. aX[2] == F3K->F3K_CODAJU})//devido valiÁ„o da GIARS
	If nPos == 0
		aAdd(aApurCDV, {})
		nPos := Len(aApurCDV)
		cDesc := getDescCDY( F3K->F3K_CODAJU)
		aAdd (aApurCDV[nPos], F3K->F3K_CFOP)
		aAdd (aApurCDV[nPos], F3K->F3K_CODAJU)
		aAdd (aApurCDV[nPos], cDesc)
		aAdd (aApurCDV[nPos], 0)
		aAdd (aApurCDV[nPos], "S")
		aAdd (aApurCDV[nPos],F3K->F3K_VALOR)
	Endif
	If F3K->F3K_VALOR == "1" //ICMS ST
		aApurCDV[nPos][4] += Iif(nValST > 0, nValST, 0)
	ElseIf(F3K->F3K_VALOR == "2")//IPI
		aApurCDV[nPos][4] += Iif(lMVRF3THRE,(cAliasSF3)->(FT_VALIPI + FT_IPIOBS),SFT->(FT_VALIPI + FT_IPIOBS))
	ElseIf (F3K->F3K_VALOR == "3")//Frete
		aApurCDV[nPos][4] += Iif(lMVRF3THRE,(cAliasSF3)->FT_FRETE,SFT->FT_FRETE)
	ElseIf(F3K->F3K_VALOR == "4")//Val.Dif.
		aApurCDV[nPos][4] += Iif(nValDif > 0, nValDif, 0)
	ElseIf(F3K->F3K_VALOR == "5")//Base Reduz.
		aApurCDV[nPos][4] += Iif(lMVRF3THRE,(cAliasSF3)->(FT_OUTRICM+FT_ISENICM)-(cAliasSF3)->FT_ICMSDIF,SFT->(FT_OUTRICM+FT_ISENICM)-SFT->FT_ICMSDIF)
	ElseIf(F3K->F3K_VALOR == "7")//Despesas
		aApurCDV[nPos][4] += Iif(lMVRF3THRE,(cAliasSF3)->FT_DESPESA,SFT->FT_DESPESA)
	ElseIf(F3K->F3K_VALOR == "9")//Valor Cont·bil
		aApurCDV[nPos][4] += Iif(lMVRF3THRE,(cAliasSF3)->FT_VALCONT,SFT->FT_VALCONT)
	Endif
	F3K->(DbSkip())
Enddo

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getDescCDY
Funcao que buscar a descriÁ„o do codigo do ajuste.

@param 	cRet - DescriÁ„o

@return 

@author Bruno Akyo Kubagawa
@since 10/10/2017
@version 1.0
/*/

function getDescCDY( cCodAju )
	local cRet := ""
	local cQuery := ""
	local cAliasQry := ""
	local aArea := getArea()
	
	default cCodAju := ""

	if _lFldCDY == nil
		_lFldCDY := aApurSX3[FP_CDY_DTINI] .and. aApurSX3[FP_CDY_DTFIM]
	endif

	if _lFldCDY
		
		cAliasQry := getNextAlias()
		
		cQuery := ""
		cQuery += " CDY.CDY_CODAJU = '" + cCodAju + "' AND " 
		cQuery += " CDY.CDY_DTINI <> ' ' AND CDY.CDY_DTINI <= '" + dToS(date()) + "' AND "
		cQuery += " ( CDY.CDY_DTFIM >= '" + dToS(date()) + "' OR CDY.CDY_DTFIM = ' ' ) " 
	
		cQuery := "%" + cQuery + "%"
		                                             			
		BeginSql Alias cAliasQry
			SELECT CDY.CDY_DESCR AS DESCR
			
			FROM %table:CDY% CDY
		   							
			WHERE CDY.CDY_FILIAL = %xFilial:CDY% AND 
				%Exp:cQuery% AND
				CDY.%NotDel%
	
		EndSql
		
		dbSelectArea(cAliasQry)
	
		cRet := alltrim( (cAliasQry)->DESCR  )
			
		(cAliasQry)->(dbCloseArea())
	endif
	
	if empty(cRet)
		cRet := Posicione("CDY",1,xFilial("CDY")+cCodAju,"CDY_DESCR")
	endif
	
	RestArea(aArea)
	
return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} ValFecp
FunÁ„o que ir· tratar valores do FECP, verificando se a operaÁ„o possui o valor
gravado no campo legado ou no campo genÈrico. 

- Se possuir valor somente no campo legado, ent„o ir· retornar o FECP do Legado
- Se possuir somente valor no campo genÈrico, ent„o ir· retornar o FECP genÈrico
- Se possuir valor em ambos (legado e genÈrico), ent„o ir· retornar o genÈrico
- Se n„o possuir valor em nenhum dos dois ir· retornar valor zero

@param		nValLegado -	Valor do Campo correspondente ao FECP legado
@param		nValGener  - 	Valor do Campo correspondente ao FECP genÈrico		

@return		nValFEcp  -  FECP a ser utilizado nas obrigaÁıes acessÛrias

@author		Erick G Dias
@since		14/09/2017
@version	12.1.17
/*/
//-----------------------------------------------------------------------
Static Function RetValFecp(nValLegado,nValGener )

Local nValFEcp	:= 0

If nValGener > 0
	//Ir· considerar o FECP genÈrico como prioridade
	nValFEcp	:= nValGener
ElseIf nValLegado > 0
	//N„o possui o FECP genÈrico gravado e ir· retornar ent„o o FECP legado
	nValFEcp	:= nValLegado
EndIF 

Return nValFEcp

//-------------------------------------------------------------------
/*/{Protheus.doc} GiafSaiPrd
@description Seleciona a itens da nota de saÌda por Aliquota para processar as importaÁıes de Prodepe
@param cChaveSF3 - Chave nota na SF3 - F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA

@return valor da importaÁ„o
@author Rafael.Soliveira	
@since 29/11/2018
/*/
//-------------------------------------------------------------------
Static Function GiafSaiPrd(cChaveSF3)
Local aArea		:= GetArea()
Local nValImp 	:= 0
Local nImport 	:= 0
Local nAliqIcm	:= 0
Local nCredProd	:= 0
Local nLimite	:= 0
Local cChaveSFT := xFilial("SFT")+"S"+cChaveSF3

dbSelectArea("SFT")
SFT->(dbSetOrder(1)) //FT_FILIAL, FT_TIPOMOV, FT_SERIE, FT_NFISCAL, FT_CLIEFOR, FT_LOJA, FT_ITEM, FT_PRODUTO
SFT->(MsSeek(cChaveSFT))


	While !SFT->(Eof()) .and. cChaveSFT == xFilial("SFT")+"S"+SFT->(FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA)
		nImport   := GiafEntPrd(SFT->FT_PRODUTO, SFT->FT_QUANT, SFT->FT_EMISSAO,Alltrim(SFT->FT_NRLIVRO))
		nAliqIcm  := SFT->FT_ALIQICM
		nCredProd := SFT->FT_CPPRODE
		nLimite  := 0
		Do Case
			Case nAliqIcm <= 7
				nLimite += nImport * 0.035
			Case nAliqIcm > 7 .and. nAliqIcm <= 12
				nLimite += nImport * 0.06
			Case nAliqIcm > 12 .and. nAliqIcm <= 18
				nLimite += nImport * 0.08
			Case nAliqIcm > 18 
				nLimite += nImport * 0.10
		EndCase
		
		//Quando calculado na nota for superior a importaÁ„o utiliza a importaÁ„o
		If nCredProd > nLimite
			nValImp += nLimite
		Else
			nValImp += nCredProd
		Endif 

		SFT->(dbSkip())
	EndDo

SFT->(DbCloseArea())
RestArea(aArea)

Return nValImp


//-------------------------------------------------------------------
/*/{Protheus.doc} GiafEntPrd
@description Seleciona a ˙ltima entrada de um determinado Produto para notas de Entrada
@param cCodPrd - CÛdigo do Produto
@param nQtdRef - Quantidade de ReferÍncia
@param dDTRef - Data de ReferÍncia para seleÁ„o das Entradas
@param cNrLivro - livro a ser processado

@return valor da importaÁ„o
@author Rafael.Soliveira	
@since 29/11/2018
/*/
//-------------------------------------------------------------------
Function GiafEntPrd(cCodPrd, nQtdRef, dDTRef,cNrLivro)
Local nQtdSdo		:= 1
Local nQtdEnt		:= 0
Local nQtdUti		:= 0
Local nQdePrdAcum	:= 0
Local nTotIteNF		:= 0
Local nVlrContEnt	:= 0
Local nValCont		:= 0
Local cAliasSFT		:= GetNextAlias()
Local cSelSFT		:= ""
Local cOrderBy		:= "ORDER BY SFT.FT_ENTRADA DESC ,SFT.FT_ITEM DESC"
Local cWhere		:= "SFT.FT_TIPOMOV ='E' "
Local dDtLimit    	:= Stod(AllTrim(Str((Year(dDTRef)-5)))+Substr(dtos(dDTRef),5,2)+'01')

//Seleciona livro a ser processado
If cNrLivro <> "*"	
	cWhere += "AND SFT.FT_NRLIVRO = '" + cNrLivro + "' " 
EndIf

cWhere := "%" + cWhere + "%"

cSelSFT +=	"SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ENTRADA, SFT.FT_PRODUTO, SFT.FT_ITEM, SFT.FT_TIPO,"
cSelSFT	+=	"SFT.FT_QUANT,SFT.FT_VALCONT,SFT.FT_BASEICM, SFT.FT_VALICM"

cSelSFT := "%" + cSelSFT + "%"
cOrderBy := "%" + cOrderBy + "%"


	BeginSql Alias cAliasSFT
	
		COLUMN FT_ENTRADA AS DATE		
		
		SELECT %Exp:cSelSFT%
	
		FROM 
		%table:SFT% SFT		
	
		WHERE 
				SFT.FT_FILIAL = %xFilial:SFT% AND
				%Exp:cWhere% AND
				SFT.FT_ENTRADA >= %Exp:dDtLimit% AND 
				SFT.FT_ENTRADA <= %Exp:dDTRef% AND
				SFT.FT_PRODUTO = %Exp:cCodPrd% AND
				SFT.FT_CFOP > '3' AND
				SFT.FT_TPPRODE = '6' AND
				SFT.FT_ICMSDIF > 0 AND
				SFT.FT_DTCANC =	'' AND
				(SFT.FT_TIPO NOT IN('B','D','P','I','C')) AND			
				SFT.FT_NFORI = ' ' AND SFT.FT_SERORI = ' ' AND SFT.FT_ITEMORI = ' ' AND
				SFT.%NotDel%
				%Exp:cOrderBy%
	EndSql

	
While !(cAliasSFT)->(EOF()) .And. nQtdSdo > 0 

	//Valor contabil
	nValCont := (cAliasSFT)->FT_VALCONT	

	//Quantidade da entrada	
	nQtdEnt := (cAliasSFT)->FT_QUANT
	

	//Verifica se a Quantidade atende 
	nQtdSdo := nQtdRef - nQtdEnt
	If nQtdSdo = 0
		nQtdUti := nQtdEnt
	ElseIf nQtdSdo < 0
		nQtdUti := nQtdRef
		nQtdSdo := 0
	Else
		nQtdUti := nQtdEnt
		nQtdRef -= nQtdEnt
	Endif
	
	//valor unitario
	nValCont	:= (nValCont / (cAliasSFT)->FT_QUANT) * nQtdUti	
			
	//Acumula caso precise calcular por mÈdia ponderada
	nTotIteNF		++
	nQdePrdAcum		+= nQtdUti 
	nVlrContEnt		+= nValCont	
	
	 						
	(cAliasSFT)->(DbSkip())
Enddo

(cAliasSFT)->(dbCloseArea())	

//Calcula a mÈdia ponderada se necessario
If nTotIteNF > 1
	nVlrContEnt := (nVlrContEnt / nQdePrdAcum) * nQdePrdAcum	
Endif
		
Return nVlrContEnt

//------------------------------------------------------------------------------------------
/* {Protheus.doc} ApurTempNF
Grava as notas fiscais referente a apuraÁ„o de ICMS

@author    Ronaldo Tapia
@version   12.1.17
@since     28/08/2017
@parametros: nOpc (1 - CrÈdito / 2 - DÈbito)
*/
//------------------------------------------------------------------------------------------				
				
Function ApurTempNF(cFilialApur,dDataEnt,cNFApur,cNFSerie,cCliente,cloja,cCFO,nAliqICM,cFormula,cOPCNF,cImp,cAlsApur, cAliasSF3)	

//Local aCampos1 := {}
//Local	nMVRF3THR	:=	GetNewPar( 'MV_RF3THR' , 3 )
//Local	nMVRF3MXT	:=	GetNewPar( 'MV_RF3MXT' , 5 )
//Local	nThreads	:=	Min( nMVRF3THR , nMVRF3MXT )
//Local 	lLock			:= .F.
//Local 	nX
Local 	cAlsDeb		:= "ICMSDEB"
Local 	cAlsCrd		:= "ICMSCRD"
Local 	cAlsSTd		:= "STDEB"
Local 	cAlsSTe		:= "STCRD"
Local 	cAlsIPIs	:= "IPIDEB"
Local 	cAlsIPIe	:= "IPICRD"
//Local 	cChave		:= cFilialApur+DTOS(dDataEnt)+cNFApur+cNFSerie+cCliente+cloja+cCFO+cValtoChar(nAliqICM)+cFormula


Default cFilialApur := ""
Default dDataEnt	:= CTOD("")
Default cCliente 	:= ""
Default cloja 		:= ""
Default cNFApur 	:= ""
Default cNFSerie	:= ""
Default cOPCNF		:= ""
Default cCFO		:= ""
Default nAliqICM	:= ""
Default cFormula	:= ""
Default cImp		:="ICMS"
Default cAlsApur	:= ""
Default cAliasSF3	:= ""


If !Empty(cFilialApur)
	
	If cImp =="ICMS" 
		
				If cOPCNF == "Debito" 
					cAlsApur := cAlsDeb
				/*************************************************************/
				/*Grava as notas fiscais de Debito apuradas - ApuraÁ„o ICMS */
				/*************************************************************/	
					Begin Transaction
						
							RecLock( cAlsApur, .T. )	
							( cAlsApur )->( FieldPut( 1 , cFilialApur ) )
							( cAlsApur )->( FieldPut( 2 , cNFApur ) )
							( cAlsApur )->( FieldPut( 3 , cNFSerie ) )
							( cAlsApur )->( FieldPut( 4 , (cAliasSF3)->F3_EMISSAO ) )
							( cAlsApur )->( FieldPut( 5 , (cAliasSF3)->F3_CLIEFOR ) )
							( cAlsApur )->( FieldPut( 6 , (cAliasSF3)->F3_LOJA ) )
							( cAlsApur )->( FieldPut( 7 , (cAliasSF3)->F3_ESTADO ) )
							( cAlsApur )->( FieldPut( 8 , (cAliasSF3)->F3_CFO ) )
							( cAlsApur )->( FieldPut( 9 , (cAliasSF3)->F3_FORMULA ) )
							( cAlsApur )->( FieldPut( 10, (cAliasSF3)->F3_CODRSEF ) )
							( cAlsApur )->( FieldPut( 11 , (cAliasSF3)->F3_ALIQICM ) )
							( cAlsApur )->( FieldPut( 12 , (cAliasSF3)->F3_VALICM  ) )
							( cAlsApur )->( FieldPut( 13 , (cAliasSF3)->F3_OUTRICM  ) )
							( cAlsApur )->( FieldPut( 14 , (cAliasSF3)->F3_ISENICM ) )
							( cAlsApur )->( FieldPut( 15 , (cAliasSF3)->F3_VALCONT ) )
							( cAlsApur )->( FieldPut( 16 , (cAliasSF3)->F3_IDENTFT ) )
							( cAlsApur )->( dbCommit() , MsUnlockAll() )

					End Transaction
			    EndIf
			
				If cOPCNF == "Credito"
					cAlsApur := cAlsCrd
					Begin Transaction
						
							RecLock( cAlsApur, .T. )	
							( cAlsApur )->( FieldPut( 1 , cFilialApur ) )
							( cAlsApur )->( FieldPut( 2 , cNFApur ) )
							( cAlsApur )->( FieldPut( 3 , cNFSerie ) )
							( cAlsApur )->( FieldPut( 4 , (cAliasSF3)->F3_EMISSAO ) )
							( cAlsApur )->( FieldPut( 5 , (cAliasSF3)->F3_CLIEFOR ) )
							( cAlsApur )->( FieldPut( 6 , (cAliasSF3)->F3_LOJA ) )
							( cAlsApur )->( FieldPut( 7 , (cAliasSF3)->F3_ESTADO ) )
							( cAlsApur )->( FieldPut( 8 , (cAliasSF3)->F3_CFO ) )
							( cAlsApur )->( FieldPut( 9 , (cAliasSF3)->F3_FORMULA ) )
							( cAlsApur )->( FieldPut( 10, (cAliasSF3)->F3_CODRSEF ) )
							( cAlsApur )->( FieldPut( 11 , (cAliasSF3)->F3_ALIQICM ) )
							( cAlsApur )->( FieldPut( 12 , (cAliasSF3)->F3_VALICM  ) )
							( cAlsApur )->( FieldPut( 13 , (cAliasSF3)->F3_OUTRICM  ) )
							( cAlsApur )->( FieldPut( 14 , (cAliasSF3)->F3_ISENICM ) )
							( cAlsApur )->( FieldPut( 15 , (cAliasSF3)->F3_VALCONT ) )
							( cAlsApur )->( FieldPut( 16 , (cAliasSF3)->F3_IDENTFT) )
							( cAlsApur )->( dbCommit() , MsUnlockAll() )

					End Transaction 
				EndIf
			
				If cOPCNF == "ST_Debito" // Verificar
					cAlsApur := cAlsSTd
					Begin Transaction
						
							RecLock( cAlsApur, .T. )	
							( cAlsApur )->( FieldPut( 1 , cFilialApur ) )
							( cAlsApur )->( FieldPut( 2 , cNFApur ) )
							( cAlsApur )->( FieldPut( 3 , cNFSerie ) )
							( cAlsApur )->( FieldPut( 4 , (cAliasSF3)->F3_EMISSAO ) )
							( cAlsApur )->( FieldPut( 5 , (cAliasSF3)->F3_CLIEFOR ) )
							( cAlsApur )->( FieldPut( 6 , (cAliasSF3)->F3_LOJA ) )
							( cAlsApur )->( FieldPut( 7 , (cAliasSF3)->F3_ESTADO ) )
							( cAlsApur )->( FieldPut( 8 , (cAliasSF3)->F3_CFO ) )
							( cAlsApur )->( FieldPut( 9 , (cAliasSF3)->F3_FORMULA ) )
							( cAlsApur )->( FieldPut( 10, (cAliasSF3)->F3_CODRSEF ) )
							( cAlsApur )->( FieldPut( 11 , (cAliasSF3)->F3_ALIQICM ) )
							( cAlsApur )->( FieldPut( 12 , (cAliasSF3)->F3_ICMSRET  ) )
							( cAlsApur )->( FieldPut( 13 , (cAliasSF3)->F3_OUTRICM ) )
							( cAlsApur )->( FieldPut( 14 , (cAliasSF3)->F3_ISENICM ) )
							( cAlsApur )->( FieldPut( 15 , (cAliasSF3)->F3_VALCONT ) )
							( cAlsApur )->( FieldPut( 16 , (cAliasSF3)->F3_IDENTFT ) )
							( cAlsApur )->( dbCommit() , MsUnlockAll() )
		
					End Transaction 
				EndIf
			
				If cOPCNF == "ST_Credito"
					cAlsApur := cAlsSTe
					Begin Transaction
						
							RecLock( cAlsApur, .T. )	
							( cAlsApur )->( FieldPut( 1 , cFilialApur ) )
							( cAlsApur )->( FieldPut( 2 , cNFApur ) )
							( cAlsApur )->( FieldPut( 3 , cNFSerie ) )
							( cAlsApur )->( FieldPut( 4 , (cAliasSF3)->F3_EMISSAO ) )
							( cAlsApur )->( FieldPut( 5 , (cAliasSF3)->F3_CLIEFOR ) )
							( cAlsApur )->( FieldPut( 6 , (cAliasSF3)->F3_LOJA ) )
							( cAlsApur )->( FieldPut( 7 , (cAliasSF3)->F3_ESTADO ) )
							( cAlsApur )->( FieldPut( 8 , (cAliasSF3)->F3_CFO ) )
							( cAlsApur )->( FieldPut( 9 , (cAliasSF3)->F3_FORMULA ) )
							( cAlsApur )->( FieldPut( 10, (cAliasSF3)->F3_CODRSEF ) )
							( cAlsApur )->( FieldPut( 11 ,(cAliasSF3)->F3_ALIQICM ) )
							( cAlsApur )->( FieldPut( 12 ,(cAliasSF3)->F3_ICMSRET  ) )
							( cAlsApur )->( FieldPut( 13 ,(cAliasSF3)->F3_OUTRICM ) )
							( cAlsApur )->( FieldPut( 14 ,(cAliasSF3)->F3_ISENICM ) )
							( cAlsApur )->( FieldPut( 15 ,(cAliasSF3)->F3_VALCONT ) )
							( cAlsApur )->( FieldPut( 16 , (cAliasSF3)->F3_IDENTFT ) )
							( cAlsApur )->( dbCommit() , MsUnlockAll() )

					End Transaction
				EndIf

	Endif
	
	If cImp =="IPI"
				If cOPCNF == "IPI_Debito"
					cAlsApur := cAlsIPIs
					Begin Transaction
							RecLock( cAlsApur, .T. )	
							( cAlsApur )->( FieldPut( 1 , cFilialApur ) )
							( cAlsApur )->( FieldPut( 2 , cNFApur ) )
							( cAlsApur )->( FieldPut( 3 , cNFSerie ) )
							( cAlsApur )->( FieldPut( 4 , (cAliasSF3)->F3_EMISSAO ) )
							( cAlsApur )->( FieldPut( 5 , (cAliasSF3)->F3_CLIEFOR ) )
							( cAlsApur )->( FieldPut( 6 , (cAliasSF3)->F3_LOJA ) )
							( cAlsApur )->( FieldPut( 7 , (cAliasSF3)->F3_CFO ) )
							( cAlsApur )->( FieldPut( 8 , (cAliasSF3)->F3_BASEIPI  ) )
							( cAlsApur )->( FieldPut( 9 , (cAliasSF3)->F3_VALIPI  ) )
							( cAlsApur )->( FieldPut( 10 , (cAliasSF3)->F3_OUTRIPI  ) )
							( cAlsApur )->( FieldPut( 11 , (cAliasSF3)->F3_ISENIPI ) )
							( cAlsApur )->( FieldPut( 12 , (cAliasSF3)->F3_VALCONT ) )
							( cAlsApur )->( FieldPut( 13 , (cAliasSF3)->F3_IDENTFT  ) )
							( cAlsApur )->( dbCommit() , MsUnlockAll() )
					End Transaction	
				EndIf
			
				If cOPCNF == "IPI_Credito"
					cAlsApur := cAlsIPIe
					Begin Transaction
						
							RecLock( cAlsApur, .T. )	
							( cAlsApur )->( FieldPut( 1 , cFilialApur ) )
							( cAlsApur )->( FieldPut( 2 , cNFApur ) )
							( cAlsApur )->( FieldPut( 3 , cNFSerie ) )
							( cAlsApur )->( FieldPut( 4 , (cAliasSF3)->F3_EMISSAO ) )
							( cAlsApur )->( FieldPut( 5 , (cAliasSF3)->F3_CLIEFOR ) )
							( cAlsApur )->( FieldPut( 6 , (cAliasSF3)->F3_LOJA ) )
							( cAlsApur )->( FieldPut( 7 , (cAliasSF3)->F3_CFO ) )
							( cAlsApur )->( FieldPut( 8 , (cAliasSF3)->F3_BASEIPI  ) )
							( cAlsApur )->( FieldPut( 9 , (cAliasSF3)->F3_VALIPI  ) )
							( cAlsApur )->( FieldPut( 10 , (cAliasSF3)->F3_OUTRIPI  ) )
							( cAlsApur )->( FieldPut( 11 , (cAliasSF3)->F3_ISENIPI ) )
							( cAlsApur )->( FieldPut( 12 , (cAliasSF3)->F3_VALCONT ) )
							( cAlsApur )->( FieldPut( 13 , (cAliasSF3)->F3_IDENTFT  ) )
							( cAlsApur )->( dbCommit() , MsUnlockAll() )
						//EndIf
					End Transaction
				EndIf
			//Endif
		//Endif
	EndIf
EndIf

Return

//------------------------------------------------------------------------------------------
/* {Protheus.doc} CrTempApu
Cria Estrutura do arquivo tempor·rio de conferencia da apuraÁ„o

@author    Felipe Guarnieri
@version   12.1.17
@since     28/08/2017
@parametros: cImp (IC, IP, IS, ST)

nOpc : 1 Criar
	   2 Deletar
*/
//------------------------------------------------------------------------------------------	
Function CrTempApu(cImp, cAlsApur, cTempApur )

Local aCampos1		:= {}
Local lRet 			:= !( TcCanOpen( cAlsApur ) .OR. Select( cAlsApur ) > 0 )

Default cImp		:=""
Default cAlsApur	:=""
Default cTempApur	:=""


If cImp =="IC"
	If lRet
		aCampos1 := {	{"FILIAL","C",TamSX3("F3_FILIAL")[1],0},; // FILIAL
						{"DOC","C",TamSX3("F3_NFISCAL")[1],0},; // DOC
						{"SERIE","C",TamSX3("F3_SERIE")[1],0},; // SERIE
						{"EMISSAO","D",TamSX3("F3_EMISSAO")[1],0},; // EMISSAO
						{"FORNECE","C",TamSX3("F3_CLIEFOR")[1],0},; // FORNECE
						{"LOJA","C",TamSX3("F3_LOJA")[1],0},; // LOJA
						{"ESTADO","C",TamSX3("F3_ESTADO")[1],0},; // UF
						{"CFOP","C",TamSX3("F3_CFO")[1],0},; // VALOR
						{"FORMULA","C",TamSX3("F3_FORMULA")[1],0},; // Formula
						{"CODRSEF","C",TamSX3("F3_CODRSEF")[1],0},; // Cod. Ret. Sefaz
						{"ALIQUOTA","N",TamSX3("F3_ALIQICM")[1],TamSX3("F3_ALIQICM")[2]},; // ALIQUOTA
						{"VALOR","N",TamSX3("F3_VALICM")[1],TamSX3("F3_VALICM")[2]},; // VALOR
						{"OUTROS","N",TamSX3("F3_OUTRICM")[1],TamSX3("F3_OUTRICM")[2]},; // Val Outros
						{"ISENTO","N",TamSX3("F3_ISENICM")[1],TamSX3("F3_ISENICM")[2]},; // Val Isento
						{"VALCONT","N",TamSX3("F3_VALCONT")[1],TamSX3("F3_VALCONT")[2]},; // Val Contabil
						{"IDENTFT","C",TamSX3("F3_IDENTFT")[1],0}} // Identificador SFT.
						
	
						

		dbCreate( cTempApur , aCampos1 , __cRdd )						
		dbUseArea( .T. ,__cRdd ,cTempApur ,cAlsApur ,.T. ,.F.)
		dbCreateIndex( cTempApur+'_01' ,"FILIAL+DOC+SERIE+EMISSAO+FORNECE+LOJA+ESTADO+CFOP+ALIQUOTA+FORMULA+IDENTFT" )
		(cAlsApur)->(DbCloseArea())
		lFirstApu := .F.
	EndIF
			
ElseIf cImp =="IP"
	If lRet
		aCampos1 := {	{"FILIAL","C",TamSX3("F3_FILIAL")[1],0},; // FILIAL
					{"DOC","C",TamSX3("F3_NFISCAL")[1],0},; // DOC
					{"SERIE","C",TamSX3("F3_SERIE")[1],0},; // SERIE
					{"EMISSAO","D",TamSX3("F3_EMISSAO")[1],0},; // EMISSAO
					{"FORNECE","C",TamSX3("F3_CLIEFOR")[1],0},; // FORNECE
					{"LOJA","C",TamSX3("F3_LOJA")[1],0},; // LOJA
					{"CFOP","C",TamSX3("F3_CFO")[1],0},; // VALOR
					{"BASEIPI","N",TamSX3("F3_BASEIPI")[1],TamSX3("F3_BASEIPI")[2]},; // VALOR
					{"VALOR","N",TamSX3("F3_VALIPI")[1],TamSX3("F3_VALIPI")[2]},; // VALOR
					{"OUTROS","N",TamSX3("F3_OUTRIPI")[1],TamSX3("F3_OUTRIPI")[2]},; // VALOR
					{"ISENTO","N",TamSX3("F3_ISENIPI")[1],TamSX3("F3_ISENIPI")[2]},; // VALOR
					{"VALCONT","N",TamSX3("F3_VALCONT")[1],TamSX3("F3_VALCONT")[2]},; // VALOR
					{"IDENTFT","C",TamSX3("F3_IDENTFT")[1],0}} // Identificador SFT.
					
						
	
		dbCreate( cTempApur , aCampos1 , __cRdd )						
		dbUseArea( .T. ,__cRdd ,cTempApur ,cAlsApur ,.T. ,.F.)
		dbCreateIndex( cTempApur+'_01' ,"FILIAL+DOC+SERIE+EMISSAO+FORNECE+LOJA+CFOP+IDENTFT" )
		(cAlsApur)->(DbCloseArea())
		lFirstApu := .F.
	EndIF		

EndIf		

Return 

//------------------------------------------------------------------------------------------
/* {Protheus.doc} FNaoContri
Checa se Cliente/Fornecedor na operacao È Nao-Contribuinte

@author     Thiago Yoshiaki Miyabara Nascimento
@version    12.1.27
@since      29/04/2021
@parametros cAliasSF3  - Alias SF3
			lBuscaA1A2 - Informa se dados do Cliente/Fornec advem das tabelas SA1/SA2 ou se estao mapeadas no Alias cAliasSF3
			lDimeSC    - Informa se a rotina sr trata de rotina DIMESC
			lCfopAnt   - Ativa Cfops Antigas -- DEFAULT .T.
@return		lRet       - .T. = Nao Contribuinte / .F. = Contribuinte 	 		    
*/
//------------------------------------------------------------------------------------------		
Function FNaoContri(cAliasSF3, lBuscaA1A2, lDimeSC, lCfopAnt)

	Local lRet       := .F.
	Local cInscr	 := ""  //Incricao Estadual
	Local cTipo   	 := ""  //Tipo do Cliente/Fornecedor
	Local cA1A2Contr := ""  //Contribuinte do ICMS 
	Local cA1A2TPJ	 := ""  //Tipo de Pessoa JurÌdica
	Local cAliasStr	 := ""	//Alias a ser utilizado para busca
	Local lDevBenef  := (cAliasSF3)->F3_TIPO $ "DB" //DevoluÁ„o ou Beneficiamento
	Local lMovEnt	 := Val(Substr((cAliasSF3)->F3_CFO,1,1)) < 5 //Tipo do Movimento Entrada
	Local cCFOPNCont := "6107/6108/5258/6258/5307/6307/5357/6357"//Cfop's de n„o contribuintes

	Default lBuscaA1A2 	:= .F.
	Default lDimeSC	   	:= .F.
	Default lCfopAnt	:= .T.		   		

	IF lCfopAnt
		cCFOPNCont += "/618/619/545/645/553/653/751/563/663"
	EndIf	

	If lMovEnt
		If lBuscaA1A2 
			cAliasStr	:= IIF(lDevBenef, "SA1->A1"        , "SA2->A2")
		Else
			cAliasStr   := IIF(lDevBenef, "(cAliasSF3)->A1", "(cAliasSF3)->A2")
		EndIf	
	Else
		If lBuscaA1A2
			cAliasStr   := IIF(lDevBenef, "SA2->A2"        , "SA1->A1")
		Else
			cAliasStr   := IIF(lDevBenef, "(cAliasSF3)->A2", "(cAliasSF3)->A1")
		EndIf	
	EndIf	
	
	cInscr		:= &(cAliasStr + "_INSCR"  )
	cTipo   	:= &(cAliasStr + "_TIPO"   )
	cA1A2Contr 	:= &(cAliasStr + "_CONTRIB")
	cA1A2TPJ	:= &(cAliasStr + "_TPJ"    )

	lRet := ( ( AllTrim( (cAliasSF3)->F3_CFO ) $ cCFOPNCont ) .Or.;
			  (("ISENT" $ Upper( cInscr ) .Or. ( Empty( cInscr ) .And. cTipo != "L" )) .And. ;
			   !(lDimeSC .And. cA1A2TPJ == "3" .And. cA1A2Contr == "1")) ) // Quando A#_CONTRIB = 1(Sim) e A#_TPJ = 3(MEI - Microempreendedor Individual)

Return lRet	//Quando lRet .T. = Nao Contribuinte / .F. = Contribuinte 

//Verifica se CFO esta cadastrado na tabela "13" do SX5
Function ApurVerCFO(CCFO,lCarga)
Local aCFOP     := {}
Local aRet      := {}
Local cAliasQry := ""
//Local cAToHM    := 'AToHM'
//Local cGet      := "HMGet"
//Local i         := 0
Local nTamCFOP  := 0

Default CCFO	:= ""
Default lCarga	:= .F.


IF lBuild 
	IF lCarga
		
		//DestrÛi o objeto do ajuste
		FreeObj(oHashCFOP)
		oHashCFOP:= NIL
	
		cAliasQry := GetNextAlias()

		BeginSql Alias cAliasQry
			SELECT SX5.X5_CHAVE, SX5.X5_DESCRI
			FROM %Table:SX5% SX5			
			WHERE
				SX5.X5_FILIAL = %xFilial:SX5%
				AND SX5.X5_TABELA = '13'
				AND SX5.%NotDel%
		EndSql

		DbSelectArea (cAliasQry)	
		
		Do While !(cAliasQry)->(Eof ())

			CCFO := AllTrim((cAliasQry)->X5_CHAVE)
			nTamCFOP  := len(CCFO)
			CCFO := if(nTamCFOP==3,CCFO+space(03),if(nTamCFOP==4,CCFO+space(2),CCFO+space(01)))
			
			AADD(aCFOP,{AllTrim((cAliasQry)->X5_CHAVE),(cAliasQry)->X5_DESCRI,CCFO})

			(cAliasQry)->(DbSkip ())
		EndDo
		
		(cAliasQry)->(DbCloseArea ())	

		// Cria o Objeto de HASH a partir do Array
		oHashCFOP := HMNew()	
		oHashCFOP := AtoHM(aCFOP)
		
		ASize(aCFOP,0) 	
	Else
		CCFO := AllTrim(CCFO)		

		IF HMGet( oHashCFOP , CCFO , @aRet )			
			CCFO := aRet[1][3]
		Else
			nTamCFOP  := len(CCFO)
			CCFO := if(nTamCFOP==3,CCFO+"*"+space(02),if(nTamCFOP==4,CCFO+"*"+space(1),CCFO+"*"))			
		Endif

	Endif	
Else
	CCFO := VerCFO(CCFO)
Endif

Return (CCFO)



/*/{Protheus.doc} CargaCodAju
	(Filtra CÛdigos de Ajustes utilizados no periodo - ICMS)
	
	@author Rafael Oliveira	
	@since 23/07/2021

	@return Retorna Nill

	Atualiza objeto hash
	
	/*/
Static Function CargaCodAju(dDtIni,dDtFim)
Local cAlias      := ""
Local cCodigo     := ""
Local cFrom       := ""
Local cSelect     := ""
Local cWhere      := ""
Local nDiasAcreDt := IIf( SuperGetMV("MV_ESTADO") == "SP" , 9 , IIf( SuperGetMV("MV_ESTADO") == "PR" , 5 , 0 ) ) //Usada para atender a Legislacao de SP/PR
Local nTamCod     := 0
Local lTpmCC6	  := aApurSX3[FP_CC6_TPMOV]
Local lTpmCDO	  := aApurSX3[FP_CDO_TPMOV]
Local lAgrupa  	  := aApurSX3[FP_CDO_AGRUPA] .AND. aApurSX3[FP_CC6_AGRUPA] 

cSelect += " DISTINCT CDA.CDA_CODLAN, CC6.CC6_CODLAN, CC6.CC6_SUBAP, CC6.CC6_REFLEX, CC6.CC6_TPAPUR, CC6.CC6_DESCR "

IF lTpmCC6
	cSelect += ", CC6.CC6_TPMOV, CC6.CC6_CODUTI, CC6.CC6_CODCRE "
Endif

IF lAgrupa
	cSelect += ", CC6.CC6_AGRUPA "
Endif

//CDO
cSelect += ", CDO.CDO_CODAJU, CDO.CDO_SUBAP, CDO.CDO_TPAPUR, CDO.CDO_UTILI, CDO.CDO_DESCR "

IF lTpmCDO
	cSelect += ", CDO.CDO_TPMOV, CDO.CDO_CODUTI, CDO.CDO_CODCRE "
Endif

IF lAgrupa
	cSelect += ", CDO.CDO_AGRUPA "
Endif

cFrom 		+= RetSqlName("CDA") + " CDA "

//FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
cFrom 		+=	" INNER JOIN "+RetSqlName("SF3")+" SF3 ON SF3.F3_FILIAL='"+xFilial("SF3")+"' AND SF3.F3_NFISCAL = CDA.CDA_NUMERO AND SF3.F3_SERIE = CDA.CDA_SERIE AND SF3.F3_CLIEFOR = CDA.CDA_CLIFOR AND SF3.F3_LOJA = CDA.CDA_LOJA AND  SF3.D_E_L_E_T_ =' '"

//CC6_FILIAL+CC6_CODLAN
cFrom 		+=	" LEFT OUTER JOIN "+RetSqlName("CC6")+" CC6 ON CC6.CC6_FILIAL='"+xFilial("CC6")+"' AND CDA.CDA_CODLAN=CC6.CC6_CODLAN AND CC6.D_E_L_E_T_ = ' '"

//CDO_FILIAL+CDO_CODAJU
cFrom 		+=	" LEFT OUTER JOIN "+RetSqlName("CDO")+" CDO ON CDO.CDO_FILIAL='"+xFilial("CDO")+"' AND CDA.CDA_CODLAN=CDO.CDO_CODAJU AND CDO.D_E_L_E_T_ = ' '"

cWhere		+= "CDA.CDA_FILIAL='"+xFilial("CDA")+"' "
cWhere		+= "AND CDA.CDA_ORIGEM <= '2' AND "


cWhere += " ((F3_ENTRADA BETWEEN '"+Dtos(dDtIni)+"' AND '"+Dtos(dDtFim)+"') OR  (F3_ENTRADA BETWEEN '"+Dtos(dDtIni+nDiasAcreDt)+"' AND '"+Dtos(dDtFim+nDiasAcreDt)+"')) AND "
cWhere += " SF3.F3_CODISS = ' ' AND SF3.F3_DTCANC = ' ' "

cSelect :=	"%" + cSelect + "%"
cFrom	:=	"%" + cFrom + 	"%"
cWhere	:=	"%" + cWhere + 	"%" 


cAlias := GetNextAlias()

BeginSql Alias cAlias
	SELECT 
		%Exp:cSelect%
	FROM 
			%Exp:cFrom%				
	WHERE
		CDA.CDA_FILIAL = %xFilial:CDA% AND
		%Exp:cWhere%				
		AND CDA.%NotDel%
EndSql

DbSelectArea (cAlias)	

//Limpa Array
ASize(aCodJu,0)

Do While !(cAlias)->(Eof ())

	cCodigo := allTrim((cAlias)->CDA_CODLAN)
	nTamCod := Len(cCodigo)

	IF nTamCod == 10		
		
		AADD(aCodJu,{cCodigo,;
					(cAlias)->CC6_SUBAP,;
					(cAlias)->CC6_REFLEX,;
					(cAlias)->CC6_TPAPUR,;
					(cAlias)->CC6_DESCR,;
					Iif(lTpmCC6,(cAlias)->CC6_TPMOV, ""),;
					Iif(lTpmCC6,(cAlias)->CC6_CODUTI,""),;
					Iif(lTpmCC6,(cAlias)->CC6_CODCRE,""),;
					Iif(lAgrupa,(cAlias)->CC6_AGRUPA,"")})

	Elseif nTamCod == 8		
	
		AADD(aCodJu,{cCodigo,;
					(cAlias)->CDO_SUBAP,;
					(cAlias)->CDO_UTILI,;
					(cAlias)->CDO_TPAPUR,;
					(cAlias)->CDO_DESCR,;
					Iif(lTpmCDO,(cAlias)->CDO_TPMOV, ""),;
					Iif(lTpmCDO,(cAlias)->CDO_CODUTI,""),;
					Iif(lTpmCDO,(cAlias)->CDO_CODCRE,""),;
					Iif(lAgrupa,(cAlias)->CDO_AGRUPA,"")})					

	Endif

	(cAlias)->(DbSkip ())
EndDo

(cAlias)->(DbCloseArea ())


If lBuild
	//DestrÛi o objeto do ajuste
	FreeObj(oHasCodAju)
	oHasCodAju:= NIL

	// Cria o Objeto de HASH a partir do Array
	oHasCodAju := HMNew()	
	oHasCodAju := AtoHM(aCodJu)
	
	ASize(aCodJu,0) 
Endif

Return


/*/{Protheus.doc} PesCodAjust(aRet)
	(Pesquisa e retorna CÛdigo de Ajuste de ICMS)

	@author Rafael Oliveira	
	@since 23/07/2021
	
	/*/
Function PesCodAjust(cCodigo)
Local aRet := {}
Local nPos := 0


If lBuild
	IF HMGet( oHasCodAju , Alltrim(cCodigo) , @aRet )
		Return aRet[1]
	Else
		Return aRet := {}
	Endif
Else
	nPos := aScan( aCodJu , { |x| Alltrim(x[1]) == Alltrim(cCodigo) } )
	IF nPos > 0
		Return aCodJu[nPos]	
	Else
		Return aRet := {}
	Endif
Endif

Return aRet
