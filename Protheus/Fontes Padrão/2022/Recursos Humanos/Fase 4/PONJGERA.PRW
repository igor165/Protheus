#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
/*     
�����������������������������������������������������������������������Ŀ
�Programa  �PonJGera  � Autor � Leandro Drumond       � Data �18/06/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Programa para agendamento da rotina de geracao de calendario�
�����������������������������������������������������������������������Ĵ
�Sintaxe   �Void                                                        �
�����������������������������������������������������������������������Ĵ
� Uso      �Agendamento da rotina PONM400 - Geracao de Calendario		�
�����������������������������������������������������������������������Ĵ
�          ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.		    �
�����������������������������������������������������������������������Ĵ
�Programador � Data   � BOPS �  Motivo da Alteracao                     �
�����������������������������������������������������������������������Ĵ
�            �        �      �                                 		  	�
�������������������������������������������������������������������������
�����������������������������������������������������������������������Ŀ
� As Instrucoes Abaixo deverao ser Incluidas no INI do Server			�
�������������������������������������������������������������������������
[ONSTART]
JOBS=GERACAO_CALENDARIO		//Define o Nome do Job

[GERACAO_CALENDARIO]		//Configuracoes do Job
Main=u_StartJGera			//ou Main=wfStart() se tiver apenas uma empresa
Environment=Environment		//Nome do Environment que devera ser utilizado

�����������������������������������������������������������������������Ŀ
� A chamada abaixo devera ser Incluida no Agendamento do WorkFlow		�
�������������������������������������������������������������������������
u_GeraScheduler(	"01"   		,;	//01 -> Codigo da Empresa no SIGAMAT
				 	"08"		,;	//02 -> Codigo da Filial no SIGAMAT
				 	"1"			,;	//03 -> Codigo do Processo
				 	"200804"	,;	//04 -> Codigo do Periodo
				 	"07"   		,;	//05 -> Numero de Pagamento
				 	"081000001"	,;	//06 -> Codigo do Departamento
				 	"0320"		,;	//07 -> Centro de Custo
				 	.T.	   		,;  //08 -> Utiliza Filial da Empresa como parametro
			    )
�����������������������������������������������������������������������Ŀ
�Fun��o    �GeraScheduler� Autor � Leandro Drumond    � Data �21/11/2001�
�����������������������������������������������������������������������Ĵ
�Descri��o �Prepara o Ambiente da Empresa e Executa a Geracao do		�
�          �Calendario												    �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �u_GeraScheduler( aUserDefParam )							�
�����������������������������������������������������������������������Ĵ
�Parametros�aUserDefParam -> Array contendo os Parametros do Usuario	�
�          �       														�
�Conteudo  �aUserDefParam[1]Codigo da Empresa no SIGAMAT				�
�          �       														�
�          �aUserDefParam[2]Codigo da Filial no SIGAMAT  				�
�          �       														�
�          �aUserDefParam[3]Codigo do Processo							�
�          �       														�
�          �aUserDefParam[4]Codigo do Periodo							�
�          �aUserDefParam[5]Numero do Pagamento			                �
�          �aUserDefParam[6]Codigo do Departamento			            �
�          �aUserDefParam[7]Centro de Custo				 				�
�          �aUserDefParam[8]Se Utiliza a Filial passada como a que deve-�
�          �                ra ser processada como parametro.			�
�����������������������������������������������������������������������Ĵ
�Uso       �JOBGERA                                                  	�
�����������������������������������������������������������������������Ĵ
�Observacao�Essa Funcao devera ser Cadastrada no Agendamento           	�
�������������������������������������������������������������������������*/
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
�����������������������������������������������������������������������Ŀ
� Verifica os Parametros passados          								�
�������������������������������������������������������������������������*/
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
�����������������������������������������������������������������������Ŀ
� Verifica se Empresa/Filial foram Passados								�
�������������������������������������������������������������������������*/
IF !Empty( cEmp ) .and. !Empty( cFil )

	/*
	�����������������������������������������������������������������������Ŀ
	� Prepara Ambiente da Empresa											�
	�������������������������������������������������������������������������*/
	PREPARE ENVIRONMENT EMPRESA ( cEmp ) FILIAL ( cFil )
	
		/*
		�����������������������������������������������������������������������Ŀ
		� Redefine nModulo de forma a Garantir que o Modulo seja o SIGAPON		�
		�������������������������������������������������������������������������*/
		SetModulo( "SIGAPON" , "PON" )

		/*
		�����������������������������������������������������������������������Ŀ
		� Processando a Geracao de Calendario                          			�
		�������������������������������������������������������������������������*/
		If lSomentecFil
			cFilParam := cFil
		EndIf

		/*
		�����������������������������������������������������������������������Ŀ
		� Chamada da Funcao de Geracao de Calendario			     			�
		�������������������������������������������������������������������������*/
		Ponm400(	lWorkFlow					,;	//Define Que a Chamada Esta Sendo Efetuada Atraves do WorkFlow
				 	cProcesso					,;	//Processo
				 	cPeriodo					,;	//Periodo
					cNumPag						,;	//Numero de Pagamento
				 	cDepto						,;	//Departamento
				 	cCCusto	 					,;	//Centro de Custo
				 	cFilParam					 ;	//Filial - Se vazio considera todas
				)

	
	/*
	�����������������������������������������������������������������������Ŀ
	� Finaliza o Ambiente da Empresa										�
	�������������������������������������������������������������������������*/
	RESET ENVIRONMENT

EndIF

Return( NIL )

/*
�����������������������������������������������������������������������Ŀ
�Fun��o    �StartJGera	 � Autor � Leandro Drumond    � Data �18/06/2008�
�����������������������������������������������������������������������Ĵ
�Descri��o �Start do Processo de WorkFlow                               �
�����������������������������������������������������������������������Ĵ
�Sintaxe   �u_StartJGera												�
�����������������������������������������������������������������������Ĵ
�Parametros�															�
�����������������������������������������������������������������������Ĵ
�Uso       �JOBGERA                                                    	�
�������������������������������������������������������������������������*/
User Function StartJGera()

Local aEmpFil := Array( 02 )

aEmpFil[ 01 ] := "01"	//Codigo da Empresa confome SIGAMAT
aEmpFil[ 02 ] := "08"	//Codigo da Filial  confome SIGAMAT

Return( wfStart( aEmpFil ) )
