//TODO criar validação de codigo municipio IBGE
#include 'totvs.ch'
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF
#DEFINE ARQUIVO_LOG "job_valida_sib_ope.log"
#DEFINE PDTE_VALID     "1" // Pendente Validação
#DEFINE VALIDO         "2" // Valido
#DEFINE INVALIDO       "3" // Inválido
#DEFINE ENV_ANS        "4" // Enviado ANS
#DEFINE CRIT_ANS       "5" // Criticado ANS
#DEFINE ACAT_ANS       "6" // Acatado ANS
#DEFINE CANCELADO      "7" // Cancelado

#DEFINE SIB_INCLUIR    "1" // Incluir
#DEFINE SIB_RETIFIC    "2" // Retificar
#DEFINE SIB_MUDCONT    "3" // Mud.Contrat
#DEFINE SIB_CANCELA    "4" // Cancelar
#DEFINE SIB_REATIVA    "5" // Reativar

#DEFINE JOB_VALID		"1" // Job Validacao

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSIBOPE

Funcao criada para carregar os jobs de sentetizacao referente ao SIB para a central de obrigacoes (B3L)

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSSIBOPE()
	Local aSay     := {}
	Local aButton  := {}
	Local nOpc     := 0
	Local Titulo	:= 'Validaçoes Movimentações - SIB'
	Local cDesc1	:= 'Esta rotina fará as validações referente as movimentaçãos SIB '
	Local cDesc2	:= 'para o núcleo de informações e obrigações.'
	Local cDesc3	:= ""
	Local lOk		:= .T.
	Local cDataRef	:= "" //Data informada pelo usuaio
	Local cRegANS	:= "" //Codigo de registro da operadora
	Local cTipProc	:= "" //Tipo de processamento 1=Beneficiarios; 2=Eventos x Despesa

	aAdd( aSay, cDesc1 )
	aAdd( aSay, cDesc2 )
	aAdd( aSay, cDesc3 )

	aAdd( aButton, { 5, .T., { || nOpc := 1, Pergunte('PLSVALSIB',.T.,Titulo,.F.) } } )
	aAdd( aButton, { 1, .T., { || nOpc := 2, Iif( ValidaPergunta(), FechaBatch(), nOpc := 0 ) } } )
	aAdd( aButton, { 2, .T., { || FechaBatch() } } )

	FormBatch( Titulo, aSay, aButton, , 200, 450 )

	If nOpc == 2

		cRegANS	:= mv_par01

		If !Empty(cRegANS)
			PLSVALOPE(cRegANS)
		Else
			MsgInfo("Para confirmar o processamento informe todos os parâmetros.","TOTVS")
			Pergunte('PLSVALSIB',.T.,Titulo,.F.)
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
/*/{Protheus.doc} PLSVALOPE

Funcao de importacao de eventos x despesas do PLS para o NIO - B3L

@param cDataRef		Data de referencia
@param cRegANS		Numero de registro da operadora na ANS
@param cTipProd		1-Produtos, 2-Beneficiario, 3-Despesas

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSVALOPE(cRegANS,nRecno)
	Local nArquivo		:= 0 //handle do arquivo/semaforo
	Local nFor			:= 0
	Local lContinua	:= .T. //Indica se deve .T. ou nao .F. continuar
	Local aThreads	:= {}
	Local aTipProc	:= {}
	Local cTipProc	:= '2'
	Local cDataRef	:= DTOS(dDataBase)

	DEFAULT cRegANS	:= mv_par01
	DEFAULT nRecno 	:= 0

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

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Inicio PLSVALOPE",ARQUIVO_LOG)

	//Validacao dos beneficiarios
	StartJob("PLSIBVLOP",GetEnvServer(),.F.,cEmpAnt,cFilAnt,;
		aThreads,cDataRef,cRegANS,cEmpAnt,Nil,;
		"1",{},nRecno,.T.)

	//Fecha semaforo
	nArquivo := Semaforo('F',nArquivo)

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
		"JobSIB"+StrZero(nTipProc,2),;		//02-
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
/*/{Protheus.doc} PLSIBVLOP

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
Function PLSIBVLOP(cEmp,cFil,aThreads,cDataRef,cRegANS,cEmpresa,oModel,cTipo,aCrit,nRecno,lJob,nRecB3K,cCampos,cOpe)
	Local lRet		:= .T.

	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cSazComp		:= ""
	Local cCodComp		:= ""
	Local cAlias	 		:= "TRBOPE"

	Local aCritBen		:= {}
	Local aAreaB3K		:= {}
	Local aAreaB3F 		:= {}

	Local nContador		:= 0
	Local  nI				:= 0
	Local aAreaB3X			:= {}

	Default cEmp 			:= ""
	Default cFil			:= ""
	Default cDataRef		:= DTOS(dDataBase)
	Default cRegANS		:= ""
	Default cEmpresa		:= ""
	Default cOpe			:= "Incluir"
	Default cTipo			:= JOB_VALID //cTipoVld		1=Job Validação;2=Comparação espelhos;3=Arq. Retorno
	Default cCampos	 	:= ""

	Default nRecno		:= 0
	Default nRecB3K		:= 0

	Default oModel		:= nil

	Default aThreads		:= {}
	Default aCrit			:= {}

	Default lJob			:= .F.

	Private __cError		:= ""
	Private __cCallStk 	:= ""

	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf
	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Inicio PLSIBVLOP" + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]",""),ARQUIVO_LOG)
	aAreaB3K := B3K->(GetArea())
	aAreaB3X := B3X->(GetArea())
	aAreaB3F := B3F->(GetArea())
	PtInternal(1,AllTrim("PLSIBVLOP " + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]","") + ": " + " validando beneficiarios"))

	//bBlock := ErrorBlock( { |e| ChecErro(e) } )
	//BEGIN SEQUENCE

	If oModel == Nil
		//Carrego os dados nunca validados
		If SelecOpera(cAlias,cDataRef,cRegANS,cEmpresa,nRecno,;
				nRecB3K)

			If LocCmpSib(cDataRef,@cCodObri,@cAnoComp,@cSazComp,@cCodComp,cRegANS)

				While !(cAlias)->(Eof())

					//1=Incluir;2=Retificar;3=Mud.Contrat;4=Cancelar;5=Reativar;6=Atualizado ANS
					cOpe := RetOpe((cAlias)->B3X_OPERA)

					aCritBen := {}
					B3K->( DbGoto( (cAlias)->B3X_BENEF) )
					B3X->(dbGoTo((cAlias)->R_E_C_N_O_))

					If cOpe == "Alterar"

						cCampos := AllTrim(B3X->B3X_CAMPO)

						aCampos := StrTokArr2(cCampos,".")
						For nI := 1 to Len(aCampos)
							MontaCriticas(cOpe,aCritBen,aCampos[nI])
						Next nI

					Else
						MontaCriticas(cOpe,aCritBen)
					EndIf
					nContador++

					lRet := PLOBVLDCRI(cRegANS,cCodObri,cAnoComp,cCodComp,aCritBen,;
						"B3X",(cAlias)->R_E_C_N_O_,Nil,Nil,cTipo,;
						aCrit,B3X->B3X_IDEORI,B3X->B3X_DESORI,,B3X->B3X_CODCCO+B3X->B3X_IDEORI)

					(cAlias)->(dbSkip())

					If nContador % 100 == 0 .Or. nContador == 1
						PtInternal(1,AllTrim("PLSIBVLOP " + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "] "," ") + AllTrim(Str(nContador)) + " registros validados"))
					EndIf


				EndDo //!(cAlias)->(Eof())

			Else
				PlsLogFil( CENDTHRL("W") + "Não encontrou o compromisso. Data:" + cDataRef + "; Operadora:" + cRegANS + "; Empresa:" + cEmpresa + "; Movmto B3X:" + AllTrim(Str(nRecno)) + "; Recno Benef B3K:" + AllTrim(Str(nRecB3K)) ,ARQUIVO_LOG)
			EndIf // IF LocCmpSib(cDataRef,@cCodObri,@cAnoComp,@cSazComp,@cCodComp,cRegANS)

		Else
			PlsLogFil( CENDTHRL("W") + "Não encontrou movimentação para validar. Data:" + cDataRef + "; Operadora:" + cRegANS + "; Empresa:" + cEmpresa + "; Movmto B3X:" + AllTrim(Str(nRecno)) + "; Recno Benef B3K:" + AllTrim(Str(nRecB3K)) ,ARQUIVO_LOG)
		EndIf //SelecOpera()

		(cAlias)->(dbCloseArea())

	Else
		If cOpe == "Alterar" .AND. !Empty(cCampos)

			aCampos := StrTokArr2(cCampos,".")
			For nI := 1 to Len(aCampos)
				MontaCriticas(cOpe,aCritBen,aCampos[nI])
			Next nI

		Else
			MontaCriticas(cOpe,aCritBen)
		EndIf
		lRet := PLOBVLDCRI(cRegANS,cCodObri,cAnoComp,cCodComp,aCritBen,;
			"B3X",,,oModel,cTipo,;
			aCrit,B3X->B3X_IDEORI,B3X->B3X_DESORI,,B3X->B3X_CODCCO+B3X->B3X_IDEORI)
	EndIf //oModel == Nil

	//RECOVER
	//disarmTransaction()
	//Cria um registro na tabela de log de erros
	//	PObrInErro()

	//END SEQUENCE
	//ErrorBlock(bBlock)

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Termino PLSIBVLOP" + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]. Total Reg. Proc.: " + Alltrim(str(nContador)),""),ARQUIVO_LOG)

	B3K->(RestArea(aAreaB3K))
	B3X->(RestArea(aAreaB3X))
	B3F->(RestArea(aAreaB3F))

	aCritBen := Nil
	aAreaB3K := Nil
	aAreaB3F := Nil

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetOpe

Retorna o texto descritivo da operação do SIB

@param cOpera		Código da Operação SIB. 1=Incluir;2=Retificar;3=Mud.Contrat;4=Cancelar;5=Reativar;6=Atualizado ANS

@return cOpe		Descrição da Operação

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetOpe(cOpera)

	Local cOpe := ""

	Default cOpera := SIB_INCLUIR

	Do Case
		Case cOpera == SIB_INCLUIR
			cOpe := "Incluir"
		Case cOpera == SIB_RETIFIC
			cOpe := "Alterar"
		Case cOpera == SIB_MUDCONT
			cOpe := "Transferir"
		Case cOpera == SIB_CANCELA
			cOpe := "Cancelar"
		Case cOpera == SIB_REATIVA
			cOpe := "Reativar"
	EndCase

Return cOpe

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaCriticas

Função criada para verificar se existe a critica no array e adiciona-lá
@return aCritBen Array com as criticas

@author lima.everton
@since 06/08/2019

/*/
Static Function AddCritica(aCritBen, cCodCri, cCodAnsC, cFuncao, cDescCri, cSolucao, lTotaliza, cCampo)

	Local nI      := 0
	Local nTotal  := Len(aCritBen)
	Local lExiste := .F.

	If nTotal > 0
		//Verifica se já existe
		For nI := 1 to nTotal
			if aCritBen[nI][1] == cCodCri
				lExiste := .T.
				Exit
			EndIf
		Next
		//Se não existe adiciona
		If !lExiste
			aAdd(aCritBen,{cCodCri, cCodAnsC, cFuncao,cDescCri, cSolucao, lTotaliza, cCampo})
		EndIf
	Else
		aAdd(aCritBen,{cCodCri, cCodAnsC, cFuncao,cDescCri, cSolucao, lTotaliza, cCampo})
	EndIf

Return aCritBen

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MontaCriticas

Funcao criada para alimetar as variaveis referente a chave do compromisso se este for encontrado

@param cOpe	Operação que deve ser validada
@param aCritBen	Array de críticas. Estrututa:	[1]Código da crítica,
												[2]Código da crítica na ANS,
												[3]Função de validação,
												[4]Descrição da crítica,
												[5]Solução,
												[6]Indicação de crítica totalizadora (SIP),
												[7]Campo afetado pela crítica


@return lRetorno	Retorna Verdadeiro (.T.) se localizou ou Falso (.F.) caso nao encontre

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MontaCriticas(cOpe,aCritBen,cCampo)

	//Validações que devem ser executadas em apenas uma operação
	Default cCampo := "None"

	AddCritica(aCritBen,"B082","    ","BProVazia","Produto do beneficiario nao informado","Informe um produto para o beneficiario",.F.,"")
	AddCritica(aCritBen,"B083","    ","BProValid","Produto do beneficiario informado e invalido.","Atualize o cadastro do Produto/Plano",.F.,"")

	If cOpe $ "Alterar"
		//Criticas gerais da alteração
		AddCritica(aCritBen,"B001","3001","SIBVLDB001","CCO é obrigatório","Para beneficiários que constam no cadastro da ANS o CCO é obrigatório."	,.F.,"B3K_CCO")
		AddCritica(aCritBen,"B076","3002","SIBVLDB076","CCO inválido","CCO deve ter 12 caracteres."	,.F.,"B3K_CCO")
		//Criticas que ocorrem em mais de um campo
		If cCampo $ "B3K_CPF.B3K_NOMMAE.B3K_CNS.B3K_PISPAS"
			AddCritica(aCritBen,"B021","0408","SIBVLDB021","CPF ou Nome da Mãe ou CNS ou PIS/PASEP, um deles é obrigatório para dependente menor de idade."	,"Preencher pelo menos um dos campos indicados"	,.F.,"B3K_CPF.B3K_NOMMAE.B3K_CNS.B3K_PISPAS")
		EndIf
		If cCampo $ "B3K_SUSEP.B3K_SCPA"
			AddCritica(aCritBen,"B049","0902","SIBVLDB049","Número do plano (RPS) e código do plano (SCPA) não podem ser informados simultaneamente.","Verificar o Número do Plano (RPS) ou Código do plano (SCPA) a ser informado e preencher somente um deles no XML correspondente."	,.F.,"B3K_SUSEP.B3K_SCPA")
			AddCritica(aCritBen,"B050","0903","SIBVLDB050","Um dos planos (RPS ou SCPA) é obrigatório","Verificar o Número do Plano (RPS) ou Código do plano (SCPA) a ser informado e preencher somente um deles no XML correspondente.",.F.,"B3K_SUSEP.B3K_SCPA")
		EndIf
		If cCampo $ "B3K_NOMMAE.B3K_CNS.B3K_PISPAS"
			AddCritica(aCritBen,"B022","0503","SIBVLDB022","Nome da Mãe ou CNS ou PIS/PASEP, um deles é obrigatório para titular e dependente maior de idade."	,"Preencher pelo menos um dos campos indicados"	,.F.,"B3K_NOMMAE.B3K_CNS.B3K_PISPAS")
		EndIf
		If cCampo $ "B3K_CNPJCO.B3K_CEICON"
			AddCritica(aCritBen,"B059","1601","SIBVLDB059","CNPJ e CEI da empresa contratante não podem existir no cadastro simultaneamente","Preencher somente um dos campos (CNPJ ou CEI)",.F.,"B3K_CNPJCO.B3K_CEICON")
			AddCritica(aCritBen,"B060","1602","SIBVLDB060","CNPJ ou CEI da empresa contratante, um deles deve existir para plano coletivo.","Preencher um dos campos (CNPJ ou CEI)",.F.,"B3K_CNPJCO.B3K_CEICON")
			AddCritica(aCritBen,"B061","1603","SIBVLDB061","CNPJ ou CEI da empresa contratante não deve existir para plano individual ou familiar.","Não preencher os campos CNPJ e CEI",.F.,"B3K_CNPJCO.B3K_CEICON")
		EndIf

		//Criticas específicas de cada campo
		If cCampo == "B3K_CEICON"
			AddCritica(aCritBen,"B063","1704","SIBVLDB063","CEI da empresa contratante inválido","Preencher CEI da empresa contratante conforme regras da ANS" ,.F.,"B3K_CEICON")
		ElseIf cCampo == "B3K_CNPJCO"
			AddCritica(aCritBen,"B062","1604","SIBVLDB062","CNPJ da empresa contratante inválido","Preencher CNPJ da empresa contratante conforme regras da ANS",.F.,"B3K_CNPJCO")
		ElseIf cCampo == "B3K_ITEEXC"
			AddCritica(aCritBen,"B056","1402","SIBVLDB057","Código de Cobertura Parcial Temporária (CPT) não existe no sistema","Preencha o código de Cobertura Parcial Temporária (CPT) conforme regra da ANS: '0' Não possui cobertura parcial temporária. '1' Possui cobertura parcial temporária.",.F.,"B3K_ITEEXC")
			AddCritica(aCritBen,"B057","1402","SIBVLDB056","Código de Cobertura Parcial Temporária (CPT) é obrigatório","Preencha o código de Cobertura Parcial Temporária (CPT) conforme regra da ANS: '0' Não possui cobertura parcial temporária. '1' Possui cobertura parcial temporária.",.F.,"B3K_ITEEXC")
			AddCritica(aCritBen,"B058","1502","SIBVLDB058","Código de itens de procedimentos excluídos da cobertura (IPEC) não existe no sistema.","Preencha o Código de itens de procedimentos excluídos da cobertura (IPEC) conforme regra da ANS: '0' não há itens de procedimentos excluídos da cobertura. '1' há intens de procedimentos excluídos da cobertura",.F.,"B3K_ITEEXC")
		ElseIf cCampo == "B3K_DATNASB3K_TIPDEP"
			AddCritica(aCritBen,"B054","1301","SIBVLDB054","Código de relação de dependência é obrigatório","Preencha o código de relação de dependência conforme regra da ANS: '1' - Beneficiário titular (maior ou menor de idade). '3' - Cônjuge/Companheiro. '4' - Filho/Filha. '6' - Enteado/Enteada. '8' - Pai/Mãe "	,.F.,"B3K_TIPDEP")
			AddCritica(aCritBen,"B055","1302","SIBVLDB055","Código de relação de dependência não existe no sistema.","Preencha o código de relação de dependência conforme regra da ANS: '1' - Beneficiário titular (maior ou menor de idade). '3' - Cônjuge/Companheiro. '4' - Filho/Filha. '6' - Enteado/Enteada. '8' - Pai/Mãe "	,.F.,"B3K_TIPDEP")
		ElseIf cCampo == "B3K_DATINC"
			AddCritica(aCritBen,"B051","1201","SIBVLDB051","Data de contratação do plano é obrigatória.","Preencher a data de contratação de acordo com a data estabelecida no contrato do plano de saúde",.F.,"B3K_DATINC")
			AddCritica(aCritBen,"B052","1201","SIBVLDB052","Data de contratação do plano deve ser posterior ou igual a 01/01/1940","Preencher a data de contratação de acordo com a data estabelecida no contrato do plano de saúde",.F.,"B3K_DATINC")
			AddCritica(aCritBen,"B053","1201","SIBVLDB053","Data de Contratação deve ser posterior ou igual a 01/01/1999, pois o plano informado é RPS","Preencher a data de contratação de acordo com a data estabelecida no contrato do plano de saúde",.F.,"B3K_DATINC")
			AddCritica(aCritBen,"B068","1214","SIBVLDB068","Data de Contratação deve ser anterior ou igual a menor data existente no cadastro: Data Histórico ou Data Cancelamento ou Data Reativação ou Data de Inclusão. Se não tiver havido mudança contratual."	,"Informe uma data de contratação válida.",.F.,"B3K_DATINC")
		ElseIf cCampo == "B3K_DATNAS"
			AddCritica(aCritBen,"B046","0205","SIBVLDB046","Data de nascimento deve ser anterior ou igual à primeira data da contratação do plano.","Preencher a data de nascimento do beneficiário conforme regra estabelecida pela ANS.",.F.,"B3K_DATNAS")
		ElseIf cCampo == "B3K_CODTIT"
			AddCritica(aCritBen,"B064","1801","SIBVLDB064","Campo de Identificação de beneficiário titular é obrigatório para beneficiário dependente.","Preencher o campo Código Beneficiário Titular",.F.,"B3K_CODTIT")
			AddCritica(aCritBen,"B065","1803","SIBVLDB065","Campo de Identificação de beneficiário titular não pertence a um titular.","Preencher o campo Código Beneficiário Titular com um código válido",.F.,"B3K_CODTIT")
			AddCritica(aCritBen,"B066","1804","SIBVLDB066","Campo de Identificação de beneficiário titular não deve existir no cadastro para beneficiário titular."	,"Não preencher o campo Código Beneficiário Titular",.F.,"B3K_CODTIT")
		ElseIf cCampo == "B3K_NOMBEN"
			AddCritica(aCritBen,"B012","0101","SIBVLDB012","Nome de beneficiário é obrigatório","Preencher o nome conforme regras estabelecidas pela ANS->O Nome NÃO pode: Conter apenas uma palavra. Primeiro nome com apenas uma letra, exceto quando o primeiro nome for: D,I,O,U,Y (com ou sem acento). Último nome com apenas uma letra, exceto quando o último nome for: I, O, U,Y (com ou sem acento). Nomes que contenham um ou mais números: 1, 2, 3, 4, 5, 6, 7, 8, 9 e 0. Nomes que contenham um ou mais caracteres especiais: @ (arroba),“ ” (aspas),* (asterisco),/ (barra),{ } (chaves),$ (cifrão),^ (circunflexo),[ ] (colchetes),\ (contra barra),& (E comercial),! (exclamação) ,= (igual) ,? (interrogação),+ (mais) ,< (menor que) ,> (maior que) ,( ) (parênteses),% (percentual),. (ponto), (ponto e vírgula),# (sustenido) ,~ (til) , (vírgula).Serão validados nomes com as letras “ e “ e “ y “ entre nomes, por se tratarem de conectivos"	,.F.,"B3K_NOMBEN")
			AddCritica(aCritBen,"B013","0102","SIBVLDB013","Nome de beneficiário inválido","Preencher o nome conforme regras estabelecidas pela ANS->O Nome NÃO pode: Conter apenas uma palavra. Primeiro nome com apenas uma letra, exceto quando o primeiro nome for: D,I,O,U,Y (com ou sem acento). Último nome com apenas uma letra, exceto quando o último nome for: I, O, U,Y (com ou sem acento). Nomes que contenham um ou mais números: 1, 2, 3, 4, 5, 6, 7, 8, 9 e 0. Nomes que contenham um ou mais caracteres especiais: @ (arroba),“ ” (aspas),* (asterisco),/ (barra),{ } (chaves),$ (cifrão),^ (circunflexo),[ ] (colchetes),\ (contra barra),& (E comercial),! (exclamação) ,= (igual) ,? (interrogação),+ (mais) ,< (menor que) ,> (maior que) ,( ) (parênteses),% (percentual),. (ponto), (ponto e vírgula),# (sustenido) ,~ (til) , (vírgula).Serão validados nomes com as letras “ e “ e “ y “ entre nomes, por se tratarem de conectivos"	,.F.,"B3K_NOMBEN")
			AddCritica(aCritBen,"B070","0410","SIBVLDB070","Já existe registro ativo com o mesmo CPF, plano e empresa contratante na operadora.","",.F.,"B3K_CNPJCO.B3K_CEICON")
		ElseIf cCampo == "B3K_DATNAS"
			AddCritica(aCritBen,"B014","0201","SIBVLDB014","Data de nascimento é obrigatória","Preencher a data de nascimento do beneficiário conforme regra estabelecida pela ANS."	,.F.,"B3K_DATNAS")
			AddCritica(aCritBen,"B015","0203","SIBVLDB015","Data de nascimento deve ser posterior ou igual a 01/01/1890","Preencher a data de nascimento do beneficiário conforme regra estabelecida pela ANS."	,.F.,"B3K_DATNAS")
		ElseIf cCampo == "B3K_SEXO"
			AddCritica(aCritBen,"B016","0301","SIBVLDB016","Código de sexo do beneficiário é obrigatório"															,"Preencher o código de sexo do beneficiário conforme regra estabelecida pela ANS. 1-Masculino. 3-Feminino"	,.F.,"B3K_SEXO")
			AddCritica(aCritBen,"B017","0302","SIBVLDB017","Código de sexo não existe no sistema (código inválido)."												,"Preencher o código de sexo do beneficiário conforme regra estabelecida pela ANS. 1-Masculino. 3-Feminino"	,.F.,"B3K_SEXO")
		ElseIf cCampo == "B3K_CPF"
			AddCritica(aCritBen,"B018","0401","SIBVLDB018","CPF Inválido."																								,"Preencher CPF do beneficiário conforme regras da ANS"	,.F.,"B3K_CPF")
			AddCritica(aCritBen,"B019","0402","SIBVLDB019","CPF é obrigatório para beneficiário titular (independentemente de idade)."							,"Preencher CPF do beneficiário conforme regras da ANS"	,.F.,"B3K_CPF")
			AddCritica(aCritBen,"B020","0403","SIBVLDB020","CPF é obrigatório para beneficiário dependente com idade igual ou superior a 18 anos."			,"Preencher CPF do beneficiário conforme regras da ANS"	,.F.,"B3K_CPF")
			AddCritica(aCritBen,"B047","0409","SIBVLDB047","Já existe registro ativo com o mesmo CPF e plano na operadora."										,"Preencher CPF do beneficiário conforme regras da ANS"	,.F.,"B3K_CPF")
		ElseIf cCampo == "B3K_PISPAS"
			AddCritica(aCritBen,"B023","0501","SIBVLDB023","PIS/PASEP inválido"																						,"Preencha o PIS/PASEP conforme regras da ANS"	,.F.,"B3K_PISPAS")
		ElseIf cCampo == "B3K_NOMMAE"
			AddCritica(aCritBen,"B025","0601","SIBVLDB025","Nome da Mãe Inválido"																						,"Preencher o nome conforme regras estabelecidas pela ANS->O Nome NÃO pode: Conter apenas uma palavra. Primeiro nome com apenas uma letra, exceto quando o primeiro nome for: D,I,O,U,Y (com ou sem acento). Último nome com apenas uma letra, exceto quando o último nome for: I, O, U,Y (com ou sem acento). Nomes que contenham um ou mais números: 1, 2, 3, 4, 5, 6, 7, 8, 9 e 0. Nomes que contenham um ou mais caracteres especiais: @ (arroba),“ ” (aspas),* (asterisco),/ (barra),{ } (chaves),$ (cifrão),^ (circunflexo),[ ] (colchetes),\ (contra barra),& (E comercial),! (exclamação) ,= (igual) ,? (interrogação),+ (mais) ,< (menor que) ,> (maior que) ,( ) (parênteses),% (percentual),. (ponto),. (ponto e vírgula),# (sustenido) ,~ (til) , (vírgula).Serão validados nomes com as letras “ e “ e “ y “ entre nomes, por se tratarem de conectivos"	,.F.,"B3K_NOMMAE")
		ElseIf cCampo == "B3K_CNS"
			AddCritica(aCritBen,"B026","0701","SIBVLDB026","CNS inválido"																								,"Preencher o CNS conforme regras da ANS"	,.F.,"B3K_CNS")
		ElseIf cCampo == "B3K_MATRIC"
			AddCritica(aCritBen,"B027","0801","SIBVLDB027","Código de Identificação do Beneficiário é obrigatório"												,"Preencher o Código de Identificação do beneficiário, conforme as regras de formação do código estabelecidas pela própria operadora"	,.F.,"B3K_MATRIC")
		ElseIf cCampo == "B3K_TIPEND"
			AddCritica(aCritBen,"B029","2101","SIBVLDB029","Código de Indicação de endereço é obrigatório para residentes no Brasil"							,"Informar Código de Indicação de endereço:'1' – profissional ou '2' - residencial ou informar que beneficiário reside no exterior"	,.F.,"B3K_TIPEND")
			AddCritica(aCritBen,"B030","2102","SIBVLDB030","Código de Indicação de endereço não deve existir para beneficiários residentes no exterior"		,"Não informar Código de Indicação de endereço"	,.F.,"B3K_TIPEND")
		ElseIf cCampo == "B3K_ENDERE"
			AddCritica(aCritBen,"B031","2201","SIBVLDB031","Logradouro é obrigatório para beneficiários residentes no Brasil"									,"Informar Logradouro ou informar que beneficiário reside no exterior"	,.F.,"B3K_ENDERE")
			AddCritica(aCritBen,"B032","2202","SIBVLDB032","Logradouro não deve existir para beneficiários residentes no exterior"								,"Não informar Logradouro ou informar que beneficiário reside no Brasil"	,.F.,"B3K_ENDERE")
		ElseIf cCampo == "B3K_NR_END"
			AddCritica(aCritBen,"B033","2301","SIBVLDB033","Número do Logradouro não deve existir no cadastro para beneficiários residentes no exterior"		,"Não informar Número do Logradouro ou informar que beneficiário reside no Brasil"	,.F.,"B3K_NR_END")
			AddCritica(aCritBen,"B034","2302","SIBVLDB034","Número do Logradouro é obrigatório para beneficiários residentes no Brasil"						,"Informar número do logradouro ou informar que beneficiário reside no exterior"	,.F.,"B3K_NR_END")
		ElseIf cCampo == "B3K_COMEND"
			AddCritica(aCritBen,"B035","2401","SIBVLDB035","Complemento Logradouro não deve existir no cadastro para beneficiários residentes no exterior"	,"Não informar Complemento Logradouro ou informar que beneficiário reside no Brasil"	,.F.,"B3K_COMEND")
			AddCritica(aCritBen,"B036","2501","SIBVLDB036","Bairro não deve existir no cadastro para beneficiários residentes no exterior"						,"Não informar Bairro ou informar que beneficiário reside no Brasil"	,.F.,"B3K_COMEND")
		ElseIf cCampo == "B3K_CODMUN"
			AddCritica(aCritBen,"B037","2601","SIBVLDB037","Código de município é obrigatório para beneficiários residentes no Brasil"							,"Informar Código de município (IBGE) ou informar que beneficiário reside no exterior"	,.F.,"B3K_CODMUN")
			AddCritica(aCritBen,"B038","2602","SIBVLDB038","Código de município não existe na tabela de município do IBGE."										,"Informar código de município válido."	,.F.,"B3K_CODMUN")
			AddCritica(aCritBen,"B039","2603","SIBVLDB039","Código de município não deve existir no cadastro para beneficiários residentes no exterior"		,"Não informar Código de município (IBGE) ou informar que beneficiário reside no Brasil"	,.F.,"B3K_CODMUN")
		ElseIf cCampo == "B3K_CEPUSR"
			AddCritica(aCritBen,"B040","2701","SIBVLDB040","CEP é obrigatório para beneficiários residentes no Brasil"											,"Informar CEP ou informar que beneficiário reside no exterior"	,.F.,"B3K_CEPUSR")
			AddCritica(aCritBen,"B041","2703","SIBVLDB041","CEP não deve existir no cadastro para beneficiários residentes no exterior"						,"Não informar CEP ou informar que beneficiário reside no Brasil"	,.F.,"B3K_CEPUSR")
			AddCritica(aCritBen,"B088","    ","SIBVLDB088","Cep do Beneficiário deve possuir oito caracteres."	,"Preencher o Campo com oito caracteres"	,.F.,"B3K_CEPUSR")
		ElseIf cCampo == "B3K_MUNICI"
			AddCritica(aCritBen,"B042","2902","SIBVLDB042","Código de município de residência não existe na tabela de município do IBGE."						,"Código de município de residência válido"	,.F.,"B3K_MUNICI")
			AddCritica(aCritBen,"B043","2810","SIBVLDB043","Código de município de residência não deve existir no cadastro para beneficiários residentes no exterior"		,"Não informar Código de município de residência ou informar que beneficiário reside no Brasil"	,.F.,"B3K_MUNICI")
			AddCritica(aCritBen,"B044","2904","SIBVLDB044","Código de município de residência não deve existir no cadastro para beneficiários com endereço residencial"		,"Não informar Código de município de residência ou informar Código de Indicação de Endereço '2' - residencial"	,.F.,"B3K_MUNICI")
		ElseIf cCampo == "B3K_DN"
			AddCritica(aCritBen,"B078","4101","SIBVLDB078","DN inválido." ,"Preencher DN com 11 caracteres."	,.F.,"B3K_DN")
			AddCritica(aCritBen,"B045","4103","SIBVLDB045","DN não deve existir no cadastro para beneficiários com data de nascimento anterior a 01/01/2007" ,"Não preencher DN ou Preencher somente o DN válido, ou seja, com datas de nascimento posteriores a 01/01/2007."	,.F.,"B3K_DN")
		ElseIf cCampo == "B3K_RESEXT"
			AddCritica(aCritBen,"B079","    ","SIBVLDB079","Código de Indicação de Residência (Nacional/Exterior) deve ser informado" ,"Código de Indicação de Residência (Nacional/Exterior) deve ser informado"	,.F.,"B3K_RESEXT")
		ElseIf cCampo == "B3K_CAEPF"
			If B3K->(FieldPos("B3K_CAEPF")) > 0
				AddCritica(aCritBen,"B090","4204","SIBVLDB090","CAEPF Inválido."	,"Preencher CAEPF do beneficiário conforme regras da ANS"	,.F.,"B3K_CPF")
			EndIf
		ElseIf cCampo == "B3K_MUNICI"
			AddCritica(aCritBen,"B081","    ","SIBVLDB081","Conteúdo do campo Código Município IBGE está incorreto."	,"Preencher o Campo com seis caracteres",.F.,"B3K_MUNICI")
		EndIf

	EndIf

	If cOpe $ "Transferir"

		AddCritica(aCritBen,"B002","0905","SIBVLDB002","Número do Plano RPS não pode ser o mesmo existente em caso de mudança contratual"					,"Verificar o Número do Plano (RPS) Origem e Destino"	, .F.,"")
		AddCritica(aCritBen,"B003","0914","SIBVLDB003","Número do plano de origem e Número do Plano RPS não podem ser iguais"								,"Verificar o Número do Plano (RPS) ou Código do plano (SCPA) a ser informado e preencher somente um deles no XML correspondente."	, .F.,"")
		AddCritica(aCritBen,"B004","1013","SIBVLDB004","Número do plano de origem e código do plano SCPA não podem ser informados simultaneamente"		,"Verificar o Número do Plano (RPS) ou Código do plano (SCPA) a ser informado e preencher somente um deles no XML correspondente."	, .F.,"")
		AddCritica(aCritBen,"B067","1209","SIBVLDB067","Data de contratação deve ser posterior a maior data existente no cadastro: Data de Reativação ou Data de Contratação."		,"Informar a data de contratação válida."	, .F.,"")

	EndIf

	If cOpe $ "Reativar"
		AddCritica(aCritBen,"B005","2003","SIBVLDB005","Data de Reativação é obrigatória"																		,"Informar a data de reativação do beneficiário"	, .F.,"B3K_DATINC")
		AddCritica(aCritBen,"B074","2008","SIBVLDB074","Um movimento de desbloqueio só pode ser precedido de um bloqueio"	,"Informe uma data de reativação válida.",.F.,"B3K_DATREA")
		AddCritica(aCritBen,"B077","3210","SIBVLDB077","Código de motivo de cancelamento informado não permite reativação."	,"A operação não poderá ser realizada.",.F.,"B3K_MOTBLO")
	EndIf

	If cOpe $ "Cancelar"
		AddCritica(aCritBen,"B007","3101","SIBVLDB007","Data de cancelamento é obrigatória"						,"Informar a data de cancelamento do contrato"	,.F.,"B3K_DATBLO")
		AddCritica(aCritBen,"B009","3201","SIBVLDB009","Código de motivo de cancelamento é obrigatório"			,"Informar o código do motivo de cancelamento."	,.F.,"B3K_MOTBLO")
		AddCritica(aCritBen,"B010","3202","SIBVLDB010","Código de motivo de cancelamento não existe no sistema" ,"Informar um código de motivo de cancelamento válido."	,.F.,"B3K_MOTBLO")
		AddCritica(aCritBen,"B071","2011","SIBVLDB071","Data de cancelamento deve ser posterior a data de inclusão ou igual/posterior a ultima reativação enviada para a ANS"	,"",.F.,"B3K_DATBLO")
		AddCritica(aCritBen,"B072","2012","SIBVLDB072","Um movimento de bloqueio só pode ser precedido de uma inclusão ou de um desbloqueio."	,"",.F.,"B3K_DATBLO")
	EndIf

	//Validações que devem ser executadas em mais de uma operação
	If cOpe $ "Reativar,Transferir"
		AddCritica(aCritBen,"B011","3205","SIBVLDB011","Código de Motivo de Cancelamento existente no cadastro não permite a reativação/transferência do registro."	,"O campo código do motivo de Cancelamento: 44 – 'Óbito', 45 - 'Transferência de Carteira', 46 - 'Inclusão Indevida', 47 - 'Fraude' ou 48 - 'Portabilidade' preenchido no cadastro de beneficiários da operadora junto à ANS não permite reativar ou mudar o plano de saúde."	,.F.,"B3K_MOTBLO")
	EndIf

	If cOpe $ "Cancelar,Reativar,Transferir"
		AddCritica(aCritBen,"B076","3002","SIBVLDB076","CCO obrigatório para esta movimentação.","CCO deve ter 12 caracteres."	,.F.,"B3K_CCO")
	EndIf

	If cOpe $ "Incluir"

		AddCritica(aCritBen,"B012","0101","SIBVLDB012","Nome de beneficiário é obrigatório","Preencher o nome conforme regras estabelecidas pela ANS->O Nome NÃO pode: Conter apenas uma palavra. Primeiro nome com apenas uma letra, exceto quando o primeiro nome for: D,I,O,U,Y (com ou sem acento). Último nome com apenas uma letra, exceto quando o último nome for: I, O, U,Y (com ou sem acento). Nomes que contenham um ou mais números: 1, 2, 3, 4, 5, 6, 7, 8, 9 e 0. Nomes que contenham um ou mais caracteres especiais: @ (arroba),“ ” (aspas),* (asterisco),/ (barra),{ } (chaves),$ (cifrão),^ (circunflexo),[ ] (colchetes),\ (contra barra),& (E comercial),! (exclamação) ,= (igual) ,? (interrogação),+ (mais) ,< (menor que) ,> (maior que) ,( ) (parênteses),% (percentual),. (ponto), (ponto e vírgula),# (sustenido) ,~ (til) , (vírgula).Serão validados nomes com as letras “ e “ e “ y “ entre nomes, por se tratarem de conectivos"	,.F.,"B3K_NOMBEN")
		AddCritica(aCritBen,"B013","0102","SIBVLDB013","Nome de beneficiário inválido","Preencher o nome conforme regras estabelecidas pela ANS->O Nome NÃO pode: Conter apenas uma palavra. Primeiro nome com apenas uma letra, exceto quando o primeiro nome for: D,I,O,U,Y (com ou sem acento). Último nome com apenas uma letra, exceto quando o último nome for: I, O, U,Y (com ou sem acento). Nomes que contenham um ou mais números: 1, 2, 3, 4, 5, 6, 7, 8, 9 e 0. Nomes que contenham um ou mais caracteres especiais: @ (arroba),“ ” (aspas),* (asterisco),/ (barra),{ } (chaves),$ (cifrão),^ (circunflexo),[ ] (colchetes),\ (contra barra),& (E comercial),! (exclamação) ,= (igual) ,? (interrogação),+ (mais) ,< (menor que) ,> (maior que) ,( ) (parênteses),% (percentual),. (ponto), (ponto e vírgula),# (sustenido) ,~ (til) , (vírgula).Serão validados nomes com as letras “ e “ e “ y “ entre nomes, por se tratarem de conectivos"	,.F.,"B3K_NOMBEN")
		AddCritica(aCritBen,"B014","0201","SIBVLDB014","Data de nascimento é obrigatória","Preencher a data de nascimento do beneficiário conforme regra estabelecida pela ANS."	,.F.,"B3K_DATNAS")
		AddCritica(aCritBen,"B015","0203","SIBVLDB015","Data de nascimento deve ser posterior ou igual a 01/01/1890","Preencher a data de nascimento do beneficiário conforme regra estabelecida pela ANS."	,.F.,"B3K_DATNAS")
		AddCritica(aCritBen,"B016","0301","SIBVLDB016","Código de sexo do beneficiário é obrigatório","Preencher o código de sexo do beneficiário conforme regra estabelecida pela ANS. 1-Masculino. 3-Feminino"	,.F.,"B3K_SEXO")
		AddCritica(aCritBen,"B017","0302","SIBVLDB017","Código de sexo não existe no sistema (código inválido).","Preencher o código de sexo do beneficiário conforme regra estabelecida pela ANS. 1-Masculino. 3-Feminino"	,.F.,"B3K_SEXO")
		AddCritica(aCritBen,"B018","0401","SIBVLDB018","CPF Inválido.","Preencher CPF do beneficiário conforme regras da ANS"	,.F.,"B3K_CPF")
		AddCritica(aCritBen,"B019","0402","SIBVLDB019","CPF é obrigatório para beneficiário titular (independentemente de idade).","Preencher CPF do beneficiário conforme regras da ANS"	,.F.,"B3K_CPF")
		AddCritica(aCritBen,"B020","0403","SIBVLDB020","CPF é obrigatório para beneficiário dependente com idade igual ou superior a 18 anos.","Preencher CPF do beneficiário conforme regras da ANS"	,.F.,"B3K_CPF")
		AddCritica(aCritBen,"B021","0408","SIBVLDB021","CPF ou Nome da Mãe ou CNS ou PIS/PASEP, um deles é obrigatório para dependente menor de idade."	,"Preencher pelo menos um dos campos indicados"	,.F.,"B3K_CPF.B3K_NOMMAE.B3K_CNS.B3K_PISPAS")
		AddCritica(aCritBen,"B022","0503","SIBVLDB022","Nome da Mãe ou CNS ou PIS/PASEP, um deles é obrigatório para titular e dependente maior de idade."	,"Preencher pelo menos um dos campos indicados"	,.F.,"B3K_NOMMAE.B3K_CNS.B3K_PISPAS")
		AddCritica(aCritBen,"B023","0501","SIBVLDB023","PIS/PASEP inválido","Preencha o PIS/PASEP conforme regras da ANS"	,.F.,"B3K_PISPAS")
		AddCritica(aCritBen,"B025","0601","SIBVLDB025","Nome da Mãe Inválido","Preencher o nome conforme regras estabelecidas pela ANS->O Nome NÃO pode: Conter apenas uma palavra. Primeiro nome com apenas uma letra, exceto quando o primeiro nome for: D,I,O,U,Y (com ou sem acento). Último nome com apenas uma letra, exceto quando o último nome for: I, O, U,Y (com ou sem acento). Nomes que contenham um ou mais números: 1, 2, 3, 4, 5, 6, 7, 8, 9 e 0. Nomes que contenham um ou mais caracteres especiais: @ (arroba),“ ” (aspas),* (asterisco),/ (barra),{ } (chaves),$ (cifrão),^ (circunflexo),[ ] (colchetes),\ (contra barra),& (E comercial),! (exclamação) ,= (igual) ,? (interrogação),+ (mais) ,< (menor que) ,> (maior que) ,( ) (parênteses),% (percentual),. (ponto),. (ponto e vírgula),# (sustenido) ,~ (til) , (vírgula).Serão validados nomes com as letras “ e “ e “ y “ entre nomes, por se tratarem de conectivos"	,.F.,"B3K_NOMMAE")
		AddCritica(aCritBen,"B026","0701","SIBVLDB026","CNS inválido","Preencher o CNS conforme regras da ANS"	,.F.,"B3K_CNS")
		AddCritica(aCritBen,"B027","0801","SIBVLDB027","Código de Identificação do Beneficiário é obrigatório","Preencher o Código de Identificação do beneficiário, conforme as regras de formação do código estabelecidas pela própria operadora"	,.F.,"B3K_MATRIC")
		AddCritica(aCritBen,"B029","2101","SIBVLDB029","Código de Indicação de endereço é obrigatório para residentes no Brasil","Informar Código de Indicação de endereço:'1' – profissional ou '2' - residencial ou informar que beneficiário reside no exterior"	,.F.,"B3K_TIPEND")
		AddCritica(aCritBen,"B030","2102","SIBVLDB030","Código de Indicação de endereço não deve existir para beneficiários residentes no exterior","Não informar Código de Indicação de endereço"	,.F.,"B3K_TIPEND")
		AddCritica(aCritBen,"B031","2201","SIBVLDB031","Logradouro é obrigatório para beneficiários residentes no Brasil","Informar Logradouro ou informar que beneficiário reside no exterior"	,.F.,"B3K_ENDERE")
		AddCritica(aCritBen,"B032","2202","SIBVLDB032","Logradouro não deve existir para beneficiários residentes no exterior","Não informar Logradouro ou informar que beneficiário reside no Brasil"	,.F.,"B3K_ENDERE")
		AddCritica(aCritBen,"B033","2301","SIBVLDB033","Número do Logradouro não deve existir no cadastro para beneficiários residentes no exterior","Não informar Número do Logradouro ou informar que beneficiário reside no Brasil"	,.F.,"B3K_NR_END")
		AddCritica(aCritBen,"B034","2302","SIBVLDB034","Número do Logradouro é obrigatório para beneficiários residentes no Brasil","Informar número do logradouro ou informar que beneficiário reside no exterior"	,.F.,"B3K_NR_END")
		AddCritica(aCritBen,"B035","2401","SIBVLDB035","Complemento Logradouro não deve existir no cadastro para beneficiários residentes no exterior","Não informar Complemento Logradouro ou informar que beneficiário reside no Brasil"	,.F.,"B3K_COMEND")
		AddCritica(aCritBen,"B036","2501","SIBVLDB036","Bairro não deve existir no cadastro para beneficiários residentes no exterior","Não informar Bairro ou informar que beneficiário reside no Brasil"	,.F.,"B3K_COMEND")
		AddCritica(aCritBen,"B037","2601","SIBVLDB037","Código de município é obrigatório para beneficiários residentes no Brasil","Informar Código de município (IBGE) ou informar que beneficiário reside no exterior"	,.F.,"B3K_CODMUN")
		AddCritica(aCritBen,"B038","2602","SIBVLDB038","Código de município não existe na tabela de município do IBGE.","Informar código de município válido."	,.F.,"B3K_CODMUN")
		AddCritica(aCritBen,"B039","2603","SIBVLDB039","Código de município não deve existir no cadastro para beneficiários residentes no exterior"		,"Não informar Código de município (IBGE) ou informar que beneficiário reside no Brasil"	,.F.,"B3K_CODMUN")
		AddCritica(aCritBen,"B040","2701","SIBVLDB040","CEP é obrigatório para beneficiários residentes no Brasil","Informar CEP ou informar que beneficiário reside no exterior"	,.F.,"B3K_CEPUSR")
		AddCritica(aCritBen,"B041","2703","SIBVLDB041","CEP não deve existir no cadastro para beneficiários residentes no exterior"						,"Não informar CEP ou informar que beneficiário reside no Brasil"	,.F.,"B3K_CEPUSR")
		AddCritica(aCritBen,"B042","2902","SIBVLDB042","Código de município de residência não existe na tabela de município do IBGE."						,"Código de município de residência válido"	,.F.,"B3K_MUNICI")
		AddCritica(aCritBen,"B043","2810","SIBVLDB043","Código de município de residência não deve existir no cadastro para beneficiários residentes no exterior"		,"Não informar Código de município de residência ou informar que beneficiário reside no Brasil"	,.F.,"B3K_MUNICI")
		AddCritica(aCritBen,"B044","2904","SIBVLDB044","Código de município de residência não deve existir no cadastro para beneficiários com endereço residencial"		,"Não informar Código de município de residência ou informar Código de Indicação de Endereço '2' - residencial"	,.F.,"B3K_MUNICI")
		AddCritica(aCritBen,"B078","4101","SIBVLDB078","DN inválido." ,"Preencher DN com 11 caracteres.",.F.,"B3K_DN")
		AddCritica(aCritBen,"B045","4103","SIBVLDB045","DN não deve existir no cadastro para beneficiários com data de nascimento anterior a 01/01/2007" ,"Não preencher DN ou Preencher somente o DN válido, ou seja, com datas de nascimento posteriores a 01/01/2007."	,.F.,"B3K_DN")
		AddCritica(aCritBen,"B079","    ","SIBVLDB079","Código de Indicação de Residência (Nacional/Exterior) deve ser informado" ,"Código de Indicação de Residência (Nacional/Exterior) deve ser informado"	,.F.,"B3K_RESEXT")
		AddCritica(aCritBen,"B081","    ","SIBVLDB081","Conteúdo do campo Código Município IBGE está incorreto.","Preencher o Campo com seis caracteres"	,.F.,"B3K_MUNICI")
		AddCritica(aCritBen,"B088","    ","SIBVLDB088","Cep do Beneficiário deve possuir oito caracteres."	,"Preencher o Campo com oito caracteres"	,.F.,"B3K_CEPUSR")
		AddCritica(aCritBen,"B075","1014","SIBVLDB075","Data de Contratação não pode ser posterior a 01/01/1999, pois o beneficiário é titular e o plano existente é SCPA e 'Individual ou Familiar'.","Informar data de Contratação válida",.F.,"B3K_DATINC")
	EndIf

	If cOpe $ "Incluir,Transferir"

		AddCritica(aCritBen,"B046","0205","SIBVLDB046","Data de nascimento deve ser anterior ou igual à primeira data da contratação do plano.","Preencher a data de nascimento do beneficiário conforme regra estabelecida pela ANS.",.F.,"B3K_DATNAS")
		AddCritica(aCritBen,"B047","0409","SIBVLDB047","Já existe registro ativo com o mesmo CPF e plano na operadora.","Preencher CPF do beneficiário conforme regras da ANS",.F.,"B3K_CPF")
		AddCritica(aCritBen,"B070","0410","SIBVLDB070","Já existe registro ativo com o mesmo CPF, plano e empresa contratante na operadora.","",.F.,"B3K_CNPJCO.B3K_CEICON")
		AddCritica(aCritBen,"B049","0902","SIBVLDB049","Número do plano (RPS) e código do plano (SCPA) não podem ser informados simultaneamente.","Verificar o Número do Plano (RPS) ou Código do plano (SCPA) a ser informado e preencher somente um deles no XML correspondente."	,.F.,"B3K_SUSEP.B3K_SCPA")
		AddCritica(aCritBen,"B050","0903","SIBVLDB050","Um dos planos (RPS ou SCPA) é obrigatório","Verificar o Número do Plano (RPS) ou Código do plano (SCPA) a ser informado e preencher somente um deles no XML correspondente.",.F.,"B3K_SUSEP.B3K_SCPA")
		AddCritica(aCritBen,"B051","1201","SIBVLDB051","Data de contratação do plano é obrigatória.","Preencher a data de contratação de acordo com a data estabelecida no contrato do plano de saúde",.F.,"B3K_DATINC")
		AddCritica(aCritBen,"B052","1201","SIBVLDB052","Data de contratação do plano deve ser posterior ou igual a 01/01/1940","Preencher a data de contratação de acordo com a data estabelecida no contrato do plano de saúde",.F.,"B3K_DATINC")
		AddCritica(aCritBen,"B053","1201","SIBVLDB053","Data de Contratação deve ser posterior ou igual a 01/01/1999, pois o plano informado é RPS","Preencher a data de contratação de acordo com a data estabelecida no contrato do plano de saúde"	,.F.,"B3K_DATINC")
		AddCritica(aCritBen,"B054","1301","SIBVLDB054","Código de relação de dependência é obrigatório","Preencha o código de relação de dependência conforme regra da ANS: '1' - Beneficiário titular (maior ou menor de idade). '3' - Cônjuge/Companheiro. '4' - Filho/Filha. '6' - Enteado/Enteada. '8' - Pai/Mãe "	,.F.,"B3K_TIPDEP")
		AddCritica(aCritBen,"B055","1302","SIBVLDB055","Código de relação de dependência não existe no sistema.","Preencha o código de relação de dependência conforme regra da ANS: '1' - Beneficiário titular (maior ou menor de idade). '3' - Cônjuge/Companheiro. '4' - Filho/Filha. '6' - Enteado/Enteada. '8' - Pai/Mãe "	,.F.,"B3K_TIPDEP")
		AddCritica(aCritBen,"B056","1402","SIBVLDB057","Código de Cobertura Parcial Temporária (CPT) não existe no sistema","Preencha o código de Cobertura Parcial Temporária (CPT) conforme regra da ANS: '0' Não possui cobertura parcial temporária. '1' Possui cobertura parcial temporária."	,.F.,"B3K_ITEEXC")
		AddCritica(aCritBen,"B057","1402","SIBVLDB056","Código de Cobertura Parcial Temporária (CPT) é obrigatório","Preencha o código de Cobertura Parcial Temporária (CPT) conforme regra da ANS: '0' Não possui cobertura parcial temporária. '1' Possui cobertura parcial temporária."	,.F.,"B3K_ITEEXC")
		AddCritica(aCritBen,"B058","1502","SIBVLDB058","Código de itens de procedimentos excluídos da cobertura (IPEC) não existe no sistema.","Preencha o Código de itens de procedimentos excluídos da cobertura (IPEC) conforme regra da ANS: '0' não há itens de procedimentos excluídos da cobertura. '1' há intens de procedimentos excluídos da cobertura"	,.F.,"B3K_ITEEXC")
		AddCritica(aCritBen,"B059","1601","SIBVLDB059","CNPJ e CEI da empresa contratante não podem existir no cadastro simultaneamente","Preencher somente um dos campos (CNPJ ou CEI)",.F.,"B3K_CNPJCO.B3K_CEICON")
		AddCritica(aCritBen,"B060","1602","SIBVLDB060","CNPJ ou CEI da empresa contratante, um deles deve existir para plano coletivo.","Preencher um dos campos (CNPJ ou CEI)"	,.F.,"B3K_CNPJCO.B3K_CEICON")
		AddCritica(aCritBen,"B061","1603","SIBVLDB061","CNPJ ou CEI da empresa contratante não deve existir para plano individual ou familiar.","Não preencher os campos CNPJ e CEI",.F.,"B3K_CNPJCO.B3K_CEICON")
		AddCritica(aCritBen,"B062","1604","SIBVLDB062","CNPJ da empresa contratante inválido","Preencher CNPJ da empresa contratante conforme regras da ANS",.F.,"B3K_CNPJCO")
		AddCritica(aCritBen,"B063","1704","SIBVLDB063","CEI da empresa contratante inválido","Preencher CEI da empresa contratante conforme regras da ANS" ,.F.,"B3K_CEICON")
		AddCritica(aCritBen,"B064","1801","SIBVLDB064","Campo de Identificação de beneficiário titular é obrigatório para beneficiário dependente.","Preencher o campo Código Beneficiário Titular",.F.,"B3K_CODTIT")
		AddCritica(aCritBen,"B065","1803","SIBVLDB065","Campo de Identificação de beneficiário titular não pertence a um titular.","Preencher o campo Código Beneficiário Titular com um código válido",.F.,"B3K_CODTIT")
		AddCritica(aCritBen,"B066","1804","SIBVLDB066","Campo de Identificação de beneficiário titular não deve existir no cadastro para beneficiário titular."	,"Não preencher o campo Código Beneficiário Titular",.F.,"B3K_CODTIT")
		If B3K->(FieldPos("B3K_CAEPF")) > 0
			AddCritica(aCritBen,"B090","4204","SIBVLDB090","CAEPF Inválido."	,"Preencher CAEPF do beneficiário conforme regras da ANS"	,.F.,"B3K_CPF")
		EndIf
		AddCritica(aCritBen,"B093","    ","SIBVLDB093","Quando preenchido o campo Num Plano RPS Ori(Portab), seu conteúdo deve ser numérico e o tamanho de 9 posições.","Informe o conteúdo do campo Num Plano RPS Ori(Portab) numérico com 9 posições",.F.,"B3K_PLAORI")

	EndIf

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LocCmpSib

Funcao criada para alimetar as variaveis referente a chave do compromisso se este for encontrado

@param cDataReal	Data de realizacao ou database
@param cCodObri		Chave do obrigacao
@param cAnoComp		Ano do compromisso
@param cSazComp		Chave da sazonalidade
@param cCodComp		Codigo do compromisso
@param cRegANS		Numero de registro da operadora na ANS

@return lRetorno	Retorna Verdadeiro (.T.) se localizou ou Falso (.F.) caso nao encontre

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function LocCmpSib(cDataRef,cCodObri,cAnoComp,cSazComp,cCodComp,;
		cRegANS)
	Local lRetorno		:= .T.
	Local cAliasN     	:= getNextAlias()
	Local cSql			:= ""
	Default cDataRef	:= DTOS(dDataBase)
	Default cCodObri	:= ""
	Default cAnoComp	:= ""
	Default cSazComp	:= ""
	Default cCodComp	:= ""
	Default cRegANS	:= '000000'

	cSql := "SELECT B3A_CODIGO, B3D_ANO, B3D_CODIGO, B3A_SZNLDD, B3A.R_E_C_N_O_ B3ARECNO, B3D.R_E_C_N_O_ B3DRECNO "
	cSql += " FROM "
	cSql += " " + RetSqlName("B3A") + " B3A, "
	cSql += " " + RetSqlName("B3D") + " B3D  "
	cSql += " WHERE "
	cSql += " B3A_FILIAL = '" + xFilial("B3A") + "' "
	cSql += " AND B3A_CODOPE = '" + cRegANS + "' "
	cSql += " AND B3A_TIPO = '2' "
	cSql += " AND B3A_ATIVO = '1' "
	cSql += " AND B3D_FILIAL = B3A_FILIAL "
	cSql += " AND B3D_CODOPE = B3A_CODOPE "
	cSql += " AND B3D_CDOBRI = B3A_CODIGO "
	cSql += " AND B3D_STATUS <> '6' "
	cSql += " AND B3A.D_E_L_E_T_ = ' ' "
	cSql += " AND B3D.D_E_L_E_T_ = ' ' "
	cSql += " ORDER BY B3D_ANO, B3D_CODIGO ASC "
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasN,.F.,.T.)

	PlsLogFil(CENDTHRL("I") + " LocalizaCompromisso: " + cSQL,ARQUIVO_LOG)

	If (cAliasN)->(Eof())
		lRetorno := .F.
	Else
		cCodObri := (cAliasN)->B3A_CODIGO
		cSazComp := (cAliasN)->B3A_SZNLDD
		cAnoComp := (cAliasN)->B3D_ANO
		cCodComp := (cAliasN)->B3D_CODIGO
	EndIf

	B3A->(dbGoTo((cAliasN)->(B3ARECNO) ) )
	B3D->(dbGoTo((cAliasN)->(B3DRECNO) ) )
	(cAliasN)->(dbCloseArea())

Return lRetorno
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
/*/{Protheus.doc} SelecOpera

Funcao cria a area de trabalho TRBBEN com as informacoes de beneficiarios a validarem

@param cAlias		Area de trabalho corrente
@param cDataRef	Data de referencia
@param cRegANS		Numero de registro da operadora na ANS
@param cEmpresa	Codigo do grupo empresa
@param nRecIni		Limite inferior do range de recnos
@param nRecFim		Limite superior do range de recnos

@return lRetorno	retorno logico indicando se foi .T. ou nao .F. encontrado registros

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function SelecOpera(cAlias,cDataRef,cRegANS,cEmpresa,nRecno,;
		nRecB3K)
	Local cSql			:= ""
	Local lRetorno		:= .F.
	Default cAlias		:= ""
	Default cDataRef	:= DTOS(dDataBase)
	Default cRegANS		:= '000000'
	Default cEmpresa	:= ""
	Default nRecno		:= 0
	Default nRecB3K		:= 0

	cSql := " SELECT DISTINCT B3X.R_E_C_N_O_,B3X_BENEF,B3X_OPERA "
	cSql += " FROM " + RetSqlName("B3X") + " B3X "
	cSql += " WHERE B3X_FILIAL = '" + xFilial("B3X") + "' "
	If nRecno > 0 //Pego o beneficiario selecionado
		cSql += " AND B3X.R_E_C_N_O_ = " + Alltrim(str(nRecno)) + " "
	ElseIf nRecB3K > 0 //Pego o beneficiario selecionado
		cSql += " AND B3X.B3X_BENEF = " + Alltrim(str(nRecB3K)) + " "
	EndIf
	cSql += " AND B3X_STATUS IN ('1','2','3') "
	cSql += " AND (B3X.D_E_L_E_T_ = ' ' OR B3X.D_E_L_E_T_ IS NULL) "

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
		"PLSVALSIB",;
		,;
		aOrdem,;
		""}


Return aParam

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChecErro

Funcao criada para capturar o erro as variáveis __cError e __cCallStk sao private e precisam ser criadas
na rotina que ira ter o controle SEQUENCE que chama esta funcao

@param e		Referencia ao erro
@param nThread	Numero da thread em execucao

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
STATIC FUNCTION ChecErro(e)

	__cError := e:Description
	__cCallStk := e:ErrorStack

	BREAK

Return