#include "Protheus.ch"
#include "ORGM020.CH"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ORGM020  ³ Autor ³ Marcos Alves          ³ Data ³ 30/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Carga dos departamento a partir do Centro de Custo         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ORGM020(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAORG                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³        ³      ³                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Obs.      ³                                                            ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Program.  ³ Data   ³ BOPS ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia C.³01/08/14³TQEIB9³Incluido o fonte da 11 para a 12 e efetuada ³±±
±±³          ³        ³      ³a limpeza.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ORGM020()
Local aSays			:= {}		// Array de Mensagens da tela de parametros
Local aButtons		:= {} 		// array locais de preferencia
Local nOpca 		:= 0		// Variavel de opcao
Local lEmpProc		:= SuperGetMV("MV_ORGCEMP",.F.,"N")=="S" //Processa todas as empreas?
Private cCadastro 	:= STR0001	// Titulo da Tela ->"Carga dos Departamento"
/*
VALIDAÇÃO DE COMPARTILHAMENTO DE TABELAS RCL E SQB
*/
If FindFunction("fVldCompt")
	If !fVldCompt()
		Return .F.
	EndIf
EndIf	
Pergunte("ORGM020",.F.)

AADD(aSays, STR0002	)	//"Este programa tem a finalidade de gerar a carga inicial"  
AADD(aSays, STR0003	)	//"dos departamento a partir do cadastro de Centro de Custo"  	

AADD(aButtons, { 5,.T.,{|| Pergunte("ORGM020",.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,If(GpConfOK(),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
FormBatch( cCadastro, aSays, aButtons )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seleciona os participante do Criterio e Visao                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Proc2BarGauge(	{ || OrgM20Processa(lEmpProc) }	,;	//Acao a ser Executada
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
±±³Fun‡…o    ³OrgM20Processa³ Autor ³ Marcos Alves          ³ Data ³ 30/08/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processamento da carga inicial dos departamentos				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³OrgM20Processa(lEmpProc)										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³lEmpProc - Carga completa as empresas							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAORG														  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OrgM20Processa(lEmpProc)
Local nCountTime					// Laco For Next
Local aEmp				:={}		// Array da Empresa
Local nLoop				:=0			// Total do Laco For Next
Local cMsg1							// Mensagem do Bauge 1			
Local cEmpBack			:=cEmpAnt	// Backup da empresa atual
Local cFilBack			:=cFilAnt	// Backup da Filial atual
Local aFiles			:={}		// Array das tabelas a serem abertas
Local nPosAlias 		:= 0		//Posicionamento do array das tabelas
Local lProc				:=.F.
Local cMV_Par01			:= ""
Local nX				:= 0
Local aRetSM0	        := {}
Local lFWLoadSM0		:= FindFunction("FWLoadSM0")

Private cFilSQB			:=xFilial("SQB")				//Filial da Tabela SQB
Private	cFilCTT			:=xFilial("CTT")   				//Filial da Tabela CTT
Private	cModoSQB		:=If(Empty(cFilSQB),"C","E")	//Modo acesso da tabela SQB
Private	cModoCTT		:=If(Empty(cFilCTT),"C","E")	//Modo acesso da tabela CTT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tabelas a serem abertas de outra empresa				      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aadd(aFiles,{"CTT",""})
aadd(aFiles,{"SQB",""})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formatar os parametros Ranger em expressao ADVPL SM0          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//MakeAdvplExpr("ORGM020")
//cMV_Par01	:=mv_par01
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Formatar os parametros Ranger em expressao SQL			      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr("ORGM020")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega todas as empresa no Array aEmp						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lEmpProc	
	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
		For nX := 1 To Len(aRetSM0)
			If Alltrim(aRetSM0[nx][2]) $ MV_PAR01
				aadd(aEmp,{aRetSM0[nx][1],aRetSM0[nx][2],aRetSM0[nx][7]})
			EndIf
		Next
	Else
		SM0->(dbGoTop())
		Do While !SM0->(Eof())
			If Alltrim(SM0->M0_CODFIL) $ MV_PAR01
				aadd(aEmp,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL})
			EndIf
			SM0->(dbSkip())
		EndDo
	EndIf
Else
	aadd(aEmp,{SM0->M0_CODIGO,FWCodFil(),SM0->M0_FILIAL})
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processar cargas dos departamentos das empresas				  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTimeIni	:= Time()
dMsDate		:= MsDate()
nLoops		:=Len(aEmp)
BarGauge1Set( nLoops )
For nCountTime:=1 to nLoops
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abrir tabelas da respectiva empresa								  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If cEmpAnt<>aEmp[nCountTime,1]
		cEmpAnt		:=aEmp[nCountTime,1]
		OrgxOpenFile(aFiles,aEmp[nCountTime,1])

		nPosAlias 	:= Ascan(aFiles,{|x| x[1] == "SQB"})
		cModoSQB		:=aFiles[nPosAlias,2]

		nPosAlias 	:= Ascan(aFiles,{|x| x[1] == "CTT"})
		cModoCTT	:=aFiles[nPosAlias,2]
		lProc		:=.F.
	EndIf	

    If lEmpProc
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculo do tempo de processamento + incremento da regua IncPrcG1()³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cMsg1:=STR0004+" - "+aEmp[nCountTime,1]+" "+aEmp[nCountTime,3]   //"Processando empresa"
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
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando as duas tabelas forem compatilhada nao precisa processar as filiais³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cFilSQB == cFilCTT) .AND. lProc
		Loop
	EndIf	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Selecao e gravacao dos centro de custo no departamento		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	OrgM20PrcFil(	aEmp[nCountTime,1]	,;   	//Empresa
			  		aEmp[nCountTime,2]	,;		//Filial
					mv_par01			,;		//Filtro Filial
					mv_par02			,;		//Filtro Cento de Custo
					nCountTime			,;		//Sequencia de processamento
					lEmpProc			)		//Tipo do processamento .T. - Todas as empresas, .F. - Unica empresa
	lProc:=.T.			
Next nCountTime
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restauranto o ambiente original								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cEmpBack<>cEmpAnt.OR.cFilBack<>cFilAnt
	cEmpAnt:=cEmpBack
	cFilAnt:=cFilBack
	OrgxOpenFile(aFiles,cEmpBack)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processar resultado da query								  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgInfo(OemToAnsi(STR0005))		//Fim do Processamento
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OrgM20PrcFil  ³ Autor ³Marcos Alves       ³ Data ³11/09/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processas a caga das filias  							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function OrgM20PrcFil(  cProcEmp	,;   	//Empresa
						cFilProc	,;		//Filial a ser processada
						cParFilial	,;		//Filtro Filial
						cParCC		,;		//Filtro Cento de Custo
						nCountTime	,;		//Sequencia de processamento
						lEmpProc)			//Tipo do processamento .T. - Todas as empresas, .F. - Unica empresa

	Local cAliasTMP		:= "CTTTMP"  										//Alias do result set da query
	Local nOrdSQB		:=	RetOrdem( "SQB" ,"QB_FILIAL+QB_CC+QB_DEPTO")	//Ordem da Tabela SQB
	Local nOrdCTT		:=	RetOrdem( "CTT" ,CTT->(IndexKey()))			//Ordem da tebale S
	Local nRegTMP		:=0													//Numero de registro do ResultSet
	Local cTimeIni		:=""												//Hora inicial do processamento
	Local cMsg2			:=STR0006+cFilProc									//Mensagem da tela Baug - #"Processando centros de custos - Filial "
	Local cWhere		:="" 
	
	cWhere	:= " CTT.CTT_CLASSE = '2'"
	cWhere	+= " AND CTT.D_E_L_E_T_ = ' '"
	cWhere	+= IIF(Empty(cParFilial), "", " AND " + AllTrim(cParFilial))
	cWhere	+= IIF(Empty(cParCC) , "", " AND " + AllTrim(cParCC))
	cWhere	:= '%' + cWhere	+ '%'

	
	dbSelectArea("CTT")
	dbSetorder(1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Query para retornar o total de registros a serem processados.		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		    
	BEGINSQL ALIAS cAliasTMP
		SELECT 
			COUNT(*) AS RECORDNUM
		FROM  
			%table:CTT% CTT 
		WHERE 
			%exp:cWhere%
	ENDSQL
	
	nRegTMP:=(cAliasTMP)->(RECORDNUM)
	(cAliasTMP)->(DbCloseArea())
	
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Query para retornar os dados a serem processados.					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		    
	BEGINSQL ALIAS cAliasTMP
		SELECT 
			CTT.CTT_FILIAL,
			CTT.CTT_CUSTO, 
			CTT.CTT_DESC01
		FROM  
			%table:CTT% CTT 
		WHERE 
			%exp:cWhere%
		ORDER BY 
			%Order:CTT,1%
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
	cTimeIni	:=Time()			// Tempo inicial da calculo do tempo de processamento
	dMsDate		:=MsDate()			// Data do inicio do processamento
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Seta o totalizador da Gauge 2			   									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lEmpProc  //Se processa todas as empresa usa 2 Gauge
		BarGauge2Set( nRegTMP )
	Else	
		BarGauge1Set( nRegTMP )
	EndIf
	
	dbSelectArea("SQB")
	dbSetorder(nOrdSQB) //QB_FILIAL+QB_CC+QB_DEPTO
	While !(cAliasTMP)->(Eof())    
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
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se ja estiver cadastrado atualiza, senao inclui						³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lLock:=SQB->(dbSeek(cFilSQB + (cAliasTMP)->CTT_CUSTO , .F. ) )
		SQB->(RecLock("SQB",!lLock))
	    If !lLock 
			SQB->(FieldPut(FieldPos("QB_FILIAL"), cFilSQB) ) 										//Grava a filial da empresa aberta
			SQB->(FieldPut(FieldPos("QB_DEPTO")	, &(GetSx3Cache( "QB_DEPTO" , "X3_RELACAO" ))) ) 	//Pegar a função do dicionario - SX8Num("SQB","QB_DEPTO")
		EndIf

		SQB->(FieldPut(FieldPos("QB_DESCRIC")	, (cAliasTMP)->CTT_DESC01))
		SQB->(FieldPut(FieldPos("QB_CC")		, (cAliasTMP)->CTT_CUSTO))
		SQB->( MsUnLock() )
		ConfirmSX8()
		(cAliasTMP)->(DbSkip())
	End
                                                    
	                                               
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Fechar o arquivo TMP da Query.									³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
	If Select(cAliasTMP) > 0
		(cAliasTMP)->(DbCloseArea())
	EndIf  
Return NIL
