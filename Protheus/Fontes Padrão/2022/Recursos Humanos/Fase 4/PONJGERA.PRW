#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
/*     
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Programa  ³PonJGera  ³ Autor ³ Leandro Drumond       ³ Data ³18/06/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Programa para agendamento da rotina de geracao de calendario³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³Void                                                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³Agendamento da rotina PONM400 - Geracao de Calendario		³
ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³          ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.		    ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³
ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³            ³        ³      ³                                 		  	³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ As Instrucoes Abaixo deverao ser Incluidas no INI do Server			³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
[ONSTART]
JOBS=GERACAO_CALENDARIO		//Define o Nome do Job

[GERACAO_CALENDARIO]		//Configuracoes do Job
Main=u_StartJGera			//ou Main=wfStart() se tiver apenas uma empresa
Environment=Environment		//Nome do Environment que devera ser utilizado

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ A chamada abaixo devera ser Incluida no Agendamento do WorkFlow		³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
u_GeraScheduler(	"01"   		,;	//01 -> Codigo da Empresa no SIGAMAT
				 	"08"		,;	//02 -> Codigo da Filial no SIGAMAT
				 	"1"			,;	//03 -> Codigo do Processo
				 	"200804"	,;	//04 -> Codigo do Periodo
				 	"07"   		,;	//05 -> Numero de Pagamento
				 	"081000001"	,;	//06 -> Codigo do Departamento
				 	"0320"		,;	//07 -> Centro de Custo
				 	.T.	   		,;  //08 -> Utiliza Filial da Empresa como parametro
			    )
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³GeraScheduler³ Autor ³ Leandro Drumond    ³ Data ³21/11/2001³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Prepara o Ambiente da Empresa e Executa a Geracao do		³
³          ³Calendario												    ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³u_GeraScheduler( aUserDefParam )							³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³aUserDefParam -> Array contendo os Parametros do Usuario	³
³          ³       														³
³Conteudo  ³aUserDefParam[1]Codigo da Empresa no SIGAMAT				³
³          ³       														³
³          ³aUserDefParam[2]Codigo da Filial no SIGAMAT  				³
³          ³       														³
³          ³aUserDefParam[3]Codigo do Processo							³
³          ³       														³
³          ³aUserDefParam[4]Codigo do Periodo							³
³          ³aUserDefParam[5]Numero do Pagamento			                ³
³          ³aUserDefParam[6]Codigo do Departamento			            ³
³          ³aUserDefParam[7]Centro de Custo				 				³
³          ³aUserDefParam[8]Se Utiliza a Filial passada como a que deve-³
³          ³                ra ser processada como parametro.			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³JOBGERA                                                  	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observacao³Essa Funcao devera ser Cadastrada no Agendamento           	³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
User Function GeraScheduler( aUserDefParam )

Local cEmp				:= ""
Local cFil				:= ""
Local cFilParam			:= ""
Local lWorkFlow			:= .T. 
Local cProcesso			:= ""
Local cPeriodo			:= ""
Local cNumPag			:= ""
Local cDepto			:= ""
Local cCCusto			:= ""
Local lSomentecFil		:= .F.
Local nUserParam		:= 0.00
Local nLenParam			:= 0.00

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Verifica os Parametros passados          								³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF ( !Empty( aUserDefParam ) .and. ValType( aUserDefParam ) == "A" )
	nLenParam := Len( aUserDefParam )
	For nUserParam := 1 To nLenParam
		Do Case
			Case ( nUserParam == 1 ) ; cEmp          	:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "C" ) , aUserDefParam[ nUserParam ] , ""	 )
			Case ( nUserParam == 2 ) ; cFil				:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "C" ) , aUserDefParam[ nUserParam ] , ""	 )
			Case ( nUserParam == 3 ) ; cProcesso		:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "C" ) , aUserDefParam[ nUserParam ] , ""  )
			Case ( nUserParam == 4 ) ; cPeriodo			:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "C" ) , aUserDefParam[ nUserParam ] , ""  )
			Case ( nUserParam == 5 ) ; cNumPag			:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "C" ) , aUserDefParam[ nUserParam ] , ""  )
			Case ( nUserParam == 6 ) ; cDepto			:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "C" ) , aUserDefParam[ nUserParam ] , ""  )
			Case ( nUserParam == 7 ) ; cCCusto			:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "C" ) , aUserDefParam[ nUserParam ] , ""  )
			Case ( nUserParam == 8 ) ; lSomentecFil		:= IF( ( ValType( aUserDefParam[ nUserParam ] ) == "L" ) , aUserDefParam[ nUserParam ] , .F. )
		End Case
	Next nUserParam
EndIF

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Verifica se Empresa/Filial foram Passados								³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !Empty( cEmp ) .and. !Empty( cFil )

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Prepara Ambiente da Empresa											³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	PREPARE ENVIRONMENT EMPRESA ( cEmp ) FILIAL ( cFil )
	
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Redefine nModulo de forma a Garantir que o Modulo seja o SIGAPON		³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		SetModulo( "SIGAPON" , "PON" )

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Processando a Geracao de Calendario                          			³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		If lSomentecFil
			cFilParam := cFil
		EndIf

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Chamada da Funcao de Geracao de Calendario			     			³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		Ponm400(	lWorkFlow					,;	//Define Que a Chamada Esta Sendo Efetuada Atraves do WorkFlow
				 	cProcesso					,;	//Processo
				 	cPeriodo					,;	//Periodo
					cNumPag						,;	//Numero de Pagamento
				 	cDepto						,;	//Departamento
				 	cCCusto	 					,;	//Centro de Custo
				 	cFilParam					 ;	//Filial - Se vazio considera todas
				)

	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Finaliza o Ambiente da Empresa										³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	RESET ENVIRONMENT

EndIF

Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡…o    ³StartJGera	 ³ Autor ³ Leandro Drumond    ³ Data ³18/06/2008³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡…o ³Start do Processo de WorkFlow                               ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³u_StartJGera												³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³JOBGERA                                                    	³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
User Function StartJGera()

Local aEmpFil := Array( 02 )

aEmpFil[ 01 ] := "01"	//Codigo da Empresa confome SIGAMAT
aEmpFil[ 02 ] := "08"	//Codigo da Filial  confome SIGAMAT

Return( wfStart( aEmpFil ) )
