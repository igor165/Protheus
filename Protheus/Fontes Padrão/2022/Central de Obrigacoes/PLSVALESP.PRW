#include 'totvs.ch'
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF
#DEFINE ARQUIVO_LOG "job_valida_sib_espelho.log"
#DEFINE JOBESPELHO 	"2"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSIBESP

Funcao criada para carregar os jobs de sentetizacao referente ao SIB para a central de obrigacoes (B3L)

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSSIBESP(nRecno)
	Local aSay     := {}
	Local aButton  := {}
	Local nOpc     := 0
	Local Titulo	:= 'Validaçoes - SIB - Base Central x Espelho ANS'
	Local cDesc1	:= 'Esta rotina fará as validações entre a base do'
	Local cDesc2	:= 'núcleo de informações e obrigações e a base da.'
	Local cDesc3	:= "ANS "
	Local lOk		:= .T.
	Local cDataRef	:= "" //Data informada pelo usuaio
	Local cRegANS	:= "" //Codigo de registro da operadora
	Local cTipProc	:= "" //Tipo de processamento 1=Beneficiarios; 2=Eventos x Despesa
	Default nRecno	:= 0

	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )

	aAdd( aButton, { 5, .T., { || nOpc := 1, Pergunte('PLSVALESP',.T.,Titulo,.F.) } } )
	aAdd( aButton, { 1, .T., { || nOpc := 2, Iif( ValidaPergunta(), FechaBatch(), nOpc := 0 ) } } )
	aAdd( aButton, { 2, .T., { || FechaBatch() } } )

	FormBatch( Titulo, aSay, aButton, , 200, 450 )

	If nOpc == 2

		cRegANS		:= mv_par01
		cTipProc	:= "2"//AllTrim(mv_par04)

		If !Empty(cRegANS) .Or. !Empty(cTipProc)
			Processa( { || lOk := PLSVALESP(cDataRef,cRegANS,cTipProc,nRecno) },'Aguarde','Processando...',.F.)
		Else
			MsgInfo("Para confirmar o processamento informe todos os parâmetros.","TOTVS")
			Pergunte('PLSVALESP',.T.,Titulo,.F.)
		EndIf

	EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaPergunta

Funcao criada para verificar se todas perguntas foram respondidas

@return lRet	Verdadeiro (.T.) se todas as perguntas foram respondidas, senao Falso (.F.)

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ValidaPergunta()
	Local lRet	:= .T.
	Local cMsg	:= ""

	If Empty(mv_par01)
		lRet := .F.
		cMsg += "Qual a operadora padrao ?" + CRLF
	EndIf

	If !lRet
		MsgInfo("Os seguintes parametros nao foram respondidos: " + CRLF + CRLF + cMsg ,"TOTVS")
	EndIf

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSVALESP

Funcao de importacao de eventos x despesas do PLS para o NIO - B3L

@param cDataRef		Data de referencia
@param cRegANS		Numero de registro da operadora na ANS
@param cTipProd		1-Produtos, 2-Beneficiario, 3-Despesas

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSVALESP(cDataRef,cRegANS,cTipProc,nRecno,lMark)
	Local   nArquivo	:= 0 //handle do arquivo/semaforo
	Local   nFor			:= 0
	Local   lContinua := .T. //Indica se deve .T. ou nao .F. continuar
	Local   aThreads	:= {}
	Local   aTipProc	:= {}
	Local   nCriBenNoANS := MV_PAR03
	Default cDataRef	:= DTOS(dDataBase)
	Default cRegANS	  := MV_PAR01
	Default cTipProc	:= '2'
	Default nRecno	  := 0
	Default lMark	    := .F.

	If !Empty(MV_PAR02)
		cDataRef := DTOS(MV_PAR02)
	EndIf

	If Empty(MV_PAR02) .Or. valtype(MV_PAR03)=="C"
		nCriBenNoANS := 1 //Critica beneficiários que não estão na ANS
	EndIf

	aTipProc := StrTokArr(cTipProc,',')
	For nFor := 1 TO Len(aTipProc)
		AdicionaThreads(aThreads,Val(aTipProc[nFor]))
	Next nFor

	//abrir semaforo
	nArquivo := Semaforo('A',0)

	//Se abriu o semaforo e carregou os beneficiarios do PLS
	If nArquivo <= 0
		lContinua := .F.
	EndIf

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Inicio PLSVALESP",ARQUIVO_LOG)

	//Validacao do espelho de beneficiarios
	StartJob("PLSIBVLES",GetEnvServer(),.F.,cEmpAnt,cFilAnt,;
		aThreads,cDataRef,cRegANS,cEmpAnt,Nil,;
		nRecno,,nCriBenNoANS)

	//Fecha semaforo
	nArquivo := Semaforo('F',nArquivo)

	If !isBlind() .AND. !lMark
		MsgInfo("A validação será realizada em segundo plano. Para acompanhar a execução clique em Atualizar na tela principal.","TOTVS")
	EndIf


Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AdicionaThreads

Funcao criada para alimentar de forma padronizada a matriz de threads

@param aThreads		Matriz com as informacoes referente as threads
@param nTipProc		Tipo de processamento a ser realizado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function AdicionaThreads(aThreads,nTipProc)
	Default aThreads	:= {}
	Default nTipProc	:= 0

	aAdd(aThreads,{;
		{2},;								//01-
		"JobSIBESP"+StrZero(nTipProc,2),;		//02-
		"Nao",;								//03-
		nTipProc,;							//04-
		0,;									//05-
		Time(),;							//06-
		"",;								//07-
		"",;								//08-
		"JobSIBSta"+StrZero(nTipProc,2),;	//09-
		"BR_VERDE",;						//10-
		"JobSIBPerc"+StrZero(nTipProc,2),;	//11-
		Nil,;								//12-
		"JobSIBProc"+StrZero(nTipProc,2),;	//13-
		"JobSIBEvPr"+StrZero(nTipProc,2),;	//14-
		0,;									//15-
		"JobSIBEvDs"+StrZero(nTipProc,2),;	//16-
		0,;									//17-
		"Normal",;							//18-
		0,;									//19-
		0,;									//20-
		.F.,;								//21-
		{},;								//22-
		})

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSIBVLES

Funcao criada para validar os registros de beneficiarios da Central de Obrigacoes

@param cEmp			Empresa do sistema
@param cFil			Filial do sistema
@param aThreads		Matriz de informacoes da thread
@param cDataRef		Data de referencia
@param cTipData		1-Digitacao,2-Pagamento,3-Procedimento
@param cRegANS			Numero de registro da operadora na ANS
@param cEmpresa		Codigo do grupo empresa

@return lRetorno	Retorna .T. para processamento ok e .F. para problema

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSIBVLES(cEmp,cFil,aThreads,cDataRef,cRegANS,;
		cEmpresa,oModel,nRecno,lJob,nCriBenNoANS)
	Local lValido			:= .T.

	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cSazComp		:= ""
	Local cCodComp		:= ""
	Local cAlias	 	:= "TRBBEN"
	Local cObri			:= "2"
	Local aCritBen		:= {}
	Local aCriticas		:= {}

	Local nContador		:= 0

	Default cEmp 		:= ""
	Default cFil		:= ""
	Default aThreads	:= {}
	Default cDataRef	:= DTOS(dDataBase)
	Default cRegANS		:= ""
	Default cEmpresa	:= ""
	Default oModel	:= nil
	Default nRecno	:= 0
	Default lJob	:= .T.


	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf
	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Inicio PLSIBVLES" + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]",""),ARQUIVO_LOG)
	PtInternal(1,AllTrim("PLSIBVLES " + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]","") + ": " + " validando beneficiarios"))


	If oModel == Nil

		If LocCmpSib(cDataRef,@cCodObri,@cAnoComp,@cSazComp,@cCodComp,;
				cRegANS)

			//O beneficiário está na base da Central e da ANS
			If BenefCntANS(cAlias,cRegANS,cEmpresa,nRecno,cDataRef)

				//Validações que devem ser executadas em apenas uma operação
				PlMntCriEs(aCritBen)

				While !TRBBEN->(Eof())
					nContador++

					lValido := PlObVldCri(cRegANS,cCodObri,cAnoComp,cCodComp,aCritBen,;
						"B3K",TRBBEN->R_E_C_N_O_,Nil,Nil,JOBESPELHO,;
						aCriticas,TRBBEN->B3K_MATRIC,TRBBEN->B3K_NOMBEN,cObri,TRBBEN->B3K_CODCCO+TRBBEN->B3K_MATRIC)

					TRBBEN->(dbSkip())

					If nContador % 100 == 0 .Or. nContador == 1
						PtInternal(1,AllTrim("PLSIBVLES " + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "] "," ") + AllTrim(Str(nContador)) + " registros validados"))
					EndIf

				EndDo //!TRBBEN->(Eof())

			EndIf //BenefCntANS

			TRBBEN->(dbCloseArea())

			//O beneficiário está na Base da Operadora, mas não na ANS
			If BenefCnt(cAlias,cRegANS,cEmpresa,nRecno) .AND. nCriBenNoANS == 1 //Critica = 1

				aCritBen := {}
				aAdd(aCritBen,{"E029",;
					"    ",;
					"SIBVLDE029"	,;
					"O beneficiário está cadastrado na Base da Operadora, mas não na ANS",;
					"Envie o beneficiário como inclusão para a ANS.",;
					.F.,"B3K_MATRIC"})

				While !TRBBEN->(Eof())
					nContador++

					lValido := PlObVldCri(cRegANS,cCodObri,cAnoComp,cCodComp,aCritBen,;
						"B3K",TRBBEN->R_E_C_N_O_,Nil,Nil,JOBESPELHO,;
						aCriticas,TRBBEN->B3K_MATRIC,TRBBEN->B3K_NOMBEN,cObri,TRBBEN->B3K_CODCCO+TRBBEN->B3K_MATRIC)

					TRBBEN->(dbSkip())

					If nContador % 100 == 0 .Or. nContador == 1
						PtInternal(1,AllTrim("PLSIBVLES " + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "] "," ") + AllTrim(Str(nContador)) + " registros validados"))
					EndIf

				EndDo //!TRBBEN->(Eof())

			EndIf //BenefCnt

			TRBBEN->(dbCloseArea())

			//O beneficiário está na ANS, mas não na Base da Operadora
			If nRecno == 0
				BenefANS(cAlias,cRegANS,cEmpresa)

				aCritBen := {}
				aAdd(aCritBen,{"E030",;
					"    ",;
					"SIBVLDE030"	,;
					"O beneficiário está cadastrado na ANS, mas não na Base da Operadora",;
					"Inclua o beneficiário na base da Operadora.",;
					.F.,"B3W_MATRIC"})

				While !TRBBEN->(Eof())
					nContador++

					lValido := PlObVldCri(cRegANS,cCodObri,cAnoComp,cCodComp,aCritBen,;
						"B3W",TRBBEN->R_E_C_N_O_,Nil,Nil,JOBESPELHO,;
						aCriticas,TRBBEN->B3W_MATRIC,TRBBEN->B3W_NOMBEN,cObri,TRBBEN->B3W_CODCCO+TRBBEN->B3W_MATRIC)

					TRBBEN->(dbSkip())

					If nContador % 100 == 0 .Or. nContador == 1
						PtInternal(1,AllTrim("PLSIBVLES " + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "] "," ") + AllTrim(Str(nContador)) + " registros validados"))
					EndIf

				EndDo //!TRBBEN->(Eof())

				TRBBEN->(dbCloseArea())

			EndIf //BenefANS

		EndIf //LocCmpSib()

	Else
		lValido := PlObVldCri(cRegANS,cCodObri,cAnoComp,cCodComp,aCritBen,;
			"B3K",nil,nil,oModel,JOBESPELHO,;
			aCriticas,TRBBEN->B3K_MATRIC,TRBBEN->B3K_NOMBEN,cObri,TRBBEN->B3K_CODCCO+TRBBEN->B3K_MATRIC)
	EndIf //oModel == Nil

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Termino PLSIBVLES" + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]. Total Reg. Proc.: " + Alltrim(str(nContador)),""),ARQUIVO_LOG)

Return lValido
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSIBVLES

Funcao criada carregar as críticas que serão validadas

@param aCritBen	Array de críticas. Estrututa:	[1]Código da crítica,
														[2]Código da crítica na ANS,
														[3]Função de validação,
														[4]Descrição da crítica,
														[5]Solução,
														[6]Indicação de crítica totalizadora (SIP),
														[7]Campo afetado pela crítica
@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function PlMntCriEs(aCritBen)
	//Criticas que apenas comparam as bases
	aAdd(aCritBen,{"E001",;
		"    ",;
		"SIBVLDE001"	,;
		"O nome do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS."	,;
		.F.,;
		"B3K_NOMBEN"})
	aAdd(aCritBen,{"E002",;
		"    ",;
		"SIBVLDE002"	,;
		"A data de nascimento não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_DATNAS"})
	aAdd(aCritBen,{"E003",;
		"    ",;
		"SIBVLDE003"	,;
		"O código do sexo do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_SEXO"})
	aAdd(aCritBen,{"E004",;
		"    ",;
		"SIBVLDE004"	,;
		"O CPF do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_CPF"})
	aAdd(aCritBen,{"E005",;
		"    ",;
		"SIBVLDE005"	,;
		"O PIS/PASEP do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_PISPAS"})
	aAdd(aCritBen,{"E006",;
		"    ",;
		"SIBVLDE006"	,;
		"O CNS do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_CNS"})
	aAdd(aCritBen,{"E007",;
		"    ",;
		"SIBVLDE007"	,;
		"O Nome da Mãe do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_NOMMAE"})
	aAdd(aCritBen,{"E008",;
		"    ",;
		"SIBVLDE008"	,;
		"O Número da Declaração Nascido Vivo do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_DN"})
	aAdd(aCritBen,{"E009",;
		"    ",;
		"SIBVLDE009"	,;
		"O Logradouro do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_ENDERE"})
	aAdd(aCritBen,{"E010",;
		"    ",;
		"SIBVLDE010"	,;
		"O Número do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_NR_END"})
	aAdd(aCritBen,{"E011",;
		"    ",;
		"SIBVLDE011"	,;
		"O Complemento do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_COMEND"})
	aAdd(aCritBen,{"E012",;
		"    ",;
		"SIBVLDE012"	,;
		"O Bairro do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_BAIRRO"})
	aAdd(aCritBen,{"E013",;
		"    ",;
		"SIBVLDE013"	,;
		"O Código Município Residência do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_CODMUN"})
	aAdd(aCritBen,{"E014",;
		"    ",;
		"SIBVLDE014"	,;
		"O CEP do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_CEPUSR"})
	aAdd(aCritBen,{"E015",;
		"    ",;
		"SIBVLDE015"	,;
		"O Tipo Endereço do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_TIPEND"})
	aAdd(aCritBen,{"E016",;
		"    ",;
		"SIBVLDE016"	,;
		"O código Reside Exterior do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_RESEXT"})
	aAdd(aCritBen,{"E017",;
		"    ",;
		"SIBVLDE017"	,;
		"O Código do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_MATRIC"})
	aAdd(aCritBen,{"E018",;
		"    ",;
		"SIBVLDE018"	,;
		"A Relação Dependência do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_TIPDEP"})
	aAdd(aCritBen,{"E019",;
		"    ",;
		"SIBVLDE019"	,;
		"O Código Beneficiário Titular do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_CODTIT"})

	aAdd(aCritBen,{"E020",;
		"    ",;
		"SIBVLDE020"	,;
		"A Data Contratação do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_DATINC"})
	aAdd(aCritBen,{"E021",;
		"    ",;
		"SIBVLDE021"	,;
		"A Data Bloqueio do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_DATBLO"})
	aAdd(aCritBen,{"E022",;
		"    ",;
		"SIBVLDE022"	,;
		"Número de Registro do Plano na ANS (SUSEP) do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_SUSEP"})
	aAdd(aCritBen,{"E023",;
		"    ",;
		"SIBVLDE023"	,;
		"O Código do Cadastro do Plano na ANS (SCPA) do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_SCPA"})
	aAdd(aCritBen,{"E024",;
		"    ",;
		"SIBVLDE024"	,;
		"O Plano Origem (portabilidade) do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_PLAORI"})
	aAdd(aCritBen,{"E025",;
		"    ",;
		"SIBVLDE025"	,;
		"Cobertura Parcial Temporária do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_COBPAR"})
	aAdd(aCritBen,{"E026",;
		"    ",;
		"SIBVLDE026"	,;
		"Itens CPT do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_ITEEXC"})
	aAdd(aCritBen,{"E027",;
		"    ",;
		"SIBVLDE027"	,;
		"O CNPJ Contratante do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_CNPJCO"})
	aAdd(aCritBen,{"E028",;
		"    ",;
		"SIBVLDE028"	,;
		"O CEI Contratante do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_CEICON"})
	aAdd(aCritBen,{"E031",;
		"    ",;
		"SIBVLDE031"	,;
		"Situação da Central não condiz com a situação da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_SITANS"})
	aAdd(aCritBen,{"E032",;
		"    ",;
		"SIBVLDE032"	,;
		"A Data Reativação do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_DATREA"})
	aAdd(aCritBen,{"E033",;
		"    ",;
		"SIBVLDE033"	,;
		"O Motivo Bloqueio do beneficiário não condiz com o cadastro da ANS",;
		"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
		.F.,"B3K_MOTBLO"})
	If B3K->(FieldPos("B3K_CAEPF")) > 0
		aAdd(aCritBen,{"E034",;
			"    ",;
			"SIBVLDE034"	,;
			"O CAEPF do beneficiário não condiz com o cadastro da ANS",;
			"Atualizar o sistema conforme o cadastro na ANS ou enviar retificação cadastral para a ANS.",;
			.F.,"B3K_CAEPF"})
	EndIf
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Semaforo

Funcao criada para abrir e fechar semaforo em arquivo

@param cOpcao		A-abrir; F-Fechar
@param nArquivo		Handle do arquivo no disco

@return nArquivo	Handle do arquivo criado o zero quando fechar

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function Semaforo(cOpcao,nArquivo)
	Local cArquivo		:= 'job_eventodespesa.smf'
	Default nArquivo	:= 0
	Default cOpcao		:= 'A'

	Do Case

		Case cOpcao == 'A' //Vou criar/abrir o semaforo/arquivo

			nArquivo := FCreate(cArquivo)

		Case cOpcao == 'F' //Vou apagar/fechar o semaforo/arquivo

			If FClose(nArquivo)
				nArquivo := 0
			EndIf

	EndCase

Return nArquivo
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BenefCntANS

Funcao cria a area de trabalho TRBBEN com as informacoes de beneficiarios a validarem

@param cAlias		Area de trabalho corrente
@param cDataRef	Data de referencia
@param cRegANS		Numero de registro da operadora na ANS


@return lRetorno	retorno logico indicando se foi .T. ou nao .F. encontrado registros

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BenefCntANS(cAlias,cRegANS,cEmpresa,nRecno, cDataRef)
	Local cSql			:= ""
	Local lRetorno		:= .F.
	Default cAlias		:= ""
	Default cRegANS		:= '000000'
	Default nRecno		:= 0

	cSql := " SELECT '" + cDataRef + "' DATA_BASE, "
	cSql += " B3K.R_E_C_N_O_ R_E_C_N_O_, "
	cSql += " B3K_BAIRRO, B3K_CEICON, B3K_CEPUSR, B3K_CNPJCO, "
	cSql += " B3K_CNS, B3K_COBPAR, B3K_CODCCO, B3K_CODMUN, "
	cSql += " B3K_CODOPE, B3K_CODPRO, B3K_CODTIT, B3K_COMEND, "
	cSql += " B3K_CPF, B3K_CPFMAE, B3K_CPFPRE, B3K_DATBLO, "
	cSql += " B3K_DATINC, B3K_DATNAS, B3K_DATREA, B3K_DIACOB, "
	cSql += " B3K_DN, B3K_DTINSI, B3K_DTINVL, B3K_DTTESI, "
	cSql += " B3K_DTTEVL, B3K_ENDERE, B3K_FILIAL, B3K_HRINSI, "
	cSql += " B3K_HRINVL, B3K_HRTESI, B3K_HRTEVL, B3K_ITEEXC, "
	cSql += " B3K_MATANT, B3K_MATRIC, B3K_MOTBLO, B3K_MUNICI, "
	cSql += " B3K_NOMBEN, B3K_NOMMAE, B3K_NR_END, B3K_OPESIB, "
	cSql += " B3K_PISPAS, B3K_PLAORI, B3K_RESEXT, B3K_SCPA, "
	cSql += " B3K_SEXO, B3K_SITANS, B3K_STAESP, B3K_STASIB, "
	cSql += " B3K_STATUS, B3K_SUSEP , B3K_TIPDEP, B3K_TIPEND, "
	cSql += " B3K_TRADES, B3K_TRAORI, B3K_UF, "
	cSql += " B3W_BAIRRO, B3W_CEICON, B3W_CEPUSR, B3W_CNPJCO, "
	cSql += " B3W_CNS, B3W_COBPAR, B3W_CODCCO, B3W_CODMUN, "
	cSql += " B3W_CODOPE, B3W_CODTIT, B3W_COMEND, B3W_CPF, "
	cSql += " B3W_DATBLO, B3W_DATINC, B3W_DATNAS, B3W_DATREA, "
	cSql += " B3W_DN, B3W_ENDERE, B3W_FILIAL, B3W_ITECPT, "
	cSql += " B3W_ITEEXC, B3W_MATRIC, B3W_MOTBLO, B3W_MUNICI, "
	cSql += " B3W_NOMBEN, B3W_NOMMAE, B3W_NR_END, B3W_PISPAS, "
	cSql += " B3W_PLAORI, B3W_RESEXT, B3W_SCPA , B3W_SEXO , "
	cSql += " B3W_SITANS, B3W_SUSEP, B3W_TIPDEP, B3W_TIPEND "
	If B3K->(FieldPos("B3K_CAEPF")) > 0 .And. B3W->(FieldPos("B3W_CAEPF")) > 0
		cSql += " ,B3K_CAEPF, B3W_CAEPF "
	EndIf
	cSql += " FROM " + RetSqlName("B3K") + " B3K "
	cSql += " FULL OUTER JOIN "
	cSql += " " + RetSqlName("B3W") + " B3W "
	cSql += " ON B3K_FILIAL = B3W_FILIAL "
	cSql += " AND B3K_CODCCO = B3W_CODCCO "
	cSql += " WHERE B3K_FILIAL = '" + xFilial("B3K") + "' "
	cSql += " AND B3K_CODOPE = '" + cRegANS + "' "
	cSql += " AND B3W_CODCCO <> '' "
	If nRecno > 0
		cSql += " AND B3K.R_E_C_N_O_ = " + Alltrim(str(nRecno)) + " "
	EndIf
	cSql += " AND B3K.D_E_L_E_T_ = ' '"
	cSql += " AND B3W.D_E_L_E_T_ = ' '"

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

	If Empty(cAlias) .Or. (cAlias)->(Eof())
		lRetorno := .F.
	Else
		lRetorno := .T.
	EndIf

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] " + cAlias + "(" + AllTrim(cEmpresa) + "): " + cSql,ARQUIVO_LOG)


Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BenefCnt

Funcao cria a area de trabalho TRBBEN com as informacoes de beneficiarios a validarem

@param cAlias		Area de trabalho corrente
@param cDataRef	Data de referencia
@param cRegANS		Numero de registro da operadora na ANS


@return lRetorno	retorno logico indicando se foi .T. ou nao .F. encontrado registros

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BenefCnt(cAlias,cRegANS,cEmpresa,nRecno)
	Local cSql			:= ""
	Local lRetorno		:= .F.
	Default cAlias		:= ""
	Default cRegANS		:= '000000'
	Default nRecno		:= 0

	cSql := " SELECT B3K.* FROM " + RetSqlName("B3K") + " B3K "
	cSql += " WHERE B3K_FILIAL = '" + xFilial("B3K") + "' "
	cSql += " 		AND ( B3K.B3K_CODCCO = ''  "
	cSql += " 		OR B3K_CODCCO NOT IN (
	cSql += " 			SELECT B3W_CODCCO
	cSql += " 			FROM " + RetSqlName("B3W") + " B3W "
	cSql += " 			WHERE B3W.D_E_L_E_T_ = ' ' "
	cSql += " 			AND B3W.B3W_CODOPE = '" + cRegANS + "' ) ) "
	cSql += " 		AND B3K.B3K_CODOPE = '" + cRegANS + "' "
	If nRecno > 0
		cSql += " AND B3K.R_E_C_N_O_ = " + Alltrim(str(nRecno)) + " "
	EndIf
	cSql += " 		AND B3K.D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

	If Empty(cAlias) .Or. (cAlias)->(Eof())
		lRetorno := .F.
	Else
		lRetorno := .T.
	EndIf

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] " + cAlias + "(" + AllTrim(cEmpresa) + "): " + cSql,ARQUIVO_LOG)


Return lRetorno

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BenefANS

Funcao cria a area de trabalho TRBBEN com as informacoes de beneficiarios a validarem

@param cAlias		Area de trabalho corrente
@param cDataRef	Data de referencia
@param cRegANS		Numero de registro da operadora na ANS


@return lRetorno	retorno logico indicando se foi .T. ou nao .F. encontrado registros

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function BenefANS(cAlias,cRegANS,cEmpresa)
	Local cSql			:= ""
	Local lRetorno		:= .F.
	Default cAlias		:= ""
	Default cRegANS		:= '000000'

	cSql := " SELECT B3W.* FROM " + RetSqlName("B3W") + " B3W "
	cSql += " WHERE B3W_FILIAL = '" + xFilial("B3W") + "' "
	cSql += " 		AND B3W_CODCCO NOT IN (   "
	cSql += " 			SELECT B3K_CODCCO     "
	cSql += " 			FROM " + RetSqlName("B3K") + " B3K "
	cSql += " 			WHERE B3K.D_E_L_E_T_ = ' '         "
	cSql += " 			AND B3K.B3K_CODOPE = '" + cRegANS + "' "
	cSql += " 			AND B3K.B3K_CODCCO <> '' ) "
	cSql += " 		AND B3W.B3W_CODOPE = '" + cRegANS + "' "
	cSql += " 		AND B3W.D_E_L_E_T_ = '' "

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAlias,.F.,.T.)

	If Empty(cAlias) .Or. (cAlias)->(Eof())
		lRetorno := .F.
	Else
		lRetorno := .T.
	EndIf

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] " + cAlias + "(" + AllTrim(cEmpresa) + "): " + cSql,ARQUIVO_LOG)


Return lRetorno

/*
Funcao criada para definir o pergunte do schedule
*/
Static Function SchedDef()
	Local aOrdem := {}
	Local aParam := {}

	aParam := { "P",;
		"PLSVALESP",;
		,;
		aOrdem,;
		""}


Return aParam
