//TODO criar validação de codigo municipio IBGE
#include 'totvs.ch'
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF
#DEFINE ARQUIVO_LOG "job_valida_sib.log"
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSSIBVAL

Funcao criada para carregar os jobs de sentetizacao referente ao SIB para a central de obrigacoes (B3L)

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSSIBVAL()
	Local aSay     := {}
	Local aButton  := {}
	Local nOpc     := 0
	Local Titulo	:= 'Validaçoes - SIB'
	Local cDesc1	:= 'Esta rotina fará as validações referente ao SIB para o '
	Local cDesc2	:= 'núcleo de informações e obrigações.'
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
			PLSVALSIB(cRegANS)
			//Processa( { || lOk := PLSVALSIB(cRegANS) },'Aguarde','Processando...',.F.)
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
/*/{Protheus.doc} PLSVALSIB

Funcao de importacao de eventos x despesas do PLS para o NIO - B3L

@param cDataRef		Data de referencia
@param cRegANS		Numero de registro da operadora na ANS
@param cTipProd		1-Produtos, 2-Beneficiario, 3-Despesas

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSVALSIB(cRegANS,nRecno)
	Local nArquivo		:= 0 //handle do arquivo/semaforo
	Local nFor			:= 0
	Local lContinua	:= .T. //Indica se deve .T. ou nao .F. continuar
	Local aThreads	:= {}
	Local aTipProc	:= {}
	Local aEmpresas	:= {}
	Local cTipProc	:= '2'
	Local cDataRef	:= DTOS(dDataBase)

	DEFAULT cRegANS	:= mv_par01
	DEFAULT nRecno 	:= 0

	bBlock := ErrorBlock( { |e| ChecErro(e) } )
	BEGIN SEQUENCE

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

		PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Inicio PLSVALSIB",ARQUIVO_LOG)

		//Validacao dos beneficiarios
		StartJob("PLSIBVLBN",GetEnvServer(),.F.,cEmpAnt,cFilAnt,;
			aThreads,cDataRef,cRegANS,cEmpAnt,Nil,;
			"Incluir","1",{},nRecno,.T.)

		//Fecha semaforo
		nArquivo := Semaforo('F',nArquivo)

		Recover
		//disarmTransaction()
		PObrInErro()

	END SEQUENCE

	ErrorBlock(bBlock)

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChecErro

Funcao criada para capturar o erro e pilha de chamado atulizando as variaveis __cError e __cCallStk
As variaveis devem ser definidas como private nas rotinas que irao ter o controle SEQUENCE implementado

@param e objeto erro

@author TOTVS PLS Team
@since 11/04/2016
/*/
//--------------------------------------------------------------------------------------------------
STATIC FUNCTION ChecErro(e)
	__cError := e:Description
	__cCallStk := e:ErrorStack
	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Erro: " + __cError + " CallStack: " + __cCallStk,ARQUIVO_LOG)
	BREAK

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
/*/{Protheus.doc} PLSIBVLBN

Funcao criada para validar os registros de beneficiarios da Central de Obrigacoes

@param cEmp			Empresa do sistema
@param cFil			Filial do sistema
@param aThreads		Matriz de informacoes da thread
@param cDataRef		Data de referencia
@param cTipData		1-Digitacao,2-Pagamento,3-Procedimento
@param cRegANS			Numero de registro da operadora na ANS
@param cEmpresa		Codigo do grupo empresa
@param cTipo			1=Job Validação;2=Comparação espelhos;3=Arq. Retorno

@return lRetorno	Retorna .T. para processamento ok e .F. para problema

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSIBVLBN(cEmp,cFil,aThreads,cDataRef,cRegANS,;
		cEmpresa,oModel,cOpe,cTipo,aCrit,;
		nRecno,lJob,cObri)
	Local lRet		:= .T.

	Local cCodObri		:= ""
	Local cAnoComp		:= ""
	Local cSazComp		:= ""
	Local cCodComp		:= ""
	Local cAlias    	:= "TRBBEN"

	Local aCritBen		:= {}
	Local aAreaB3K		:= {}

	Local nContador		:= 0

	Default cEmp 			:= ""
	Default cFil			:= ""
	Default cDataRef		:= DTOS(dDataBase)
	Default cRegANS		:= ""
	Default cEmpresa		:= ""
	Default cOpe			:= "Incluir"
	Default cTipo			:= "1" //cTipoVld		1=Job Validação;2=Comparação espelhos;3=Arq. Retorno
	Default nRecno		:= 0
	Default cObri		:= "2"

	Private __cError		:= ""
	Private __cCallStk 	:= ""
	Default oModel		:= nil
	Default aThreads		:= {}
	Default aCrit			:= {}
	Default lJob			:= .F.

	If lJob
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf

	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Inicio PLSIBVLBN" + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]",""),ARQUIVO_LOG)

	PtInternal(1,AllTrim("PLSIBVLBN " + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]","") + ": " + " validando beneficiarios"))

	aAreaB3K		:= B3K->(GetArea())


	If oModel == Nil
		//Carrego os dados nunca validados
		If SelecBenef(cAlias,cDataRef,cRegANS,cEmpresa,nRecno)

			If LocCmpSib(cDataRef,@cCodObri,@cAnoComp,@cSazComp,@cCodComp,cRegANS)


				While !(cAlias)->(Eof())

					aCritBen := {}
					MontaCriticas(cOpe,aCritBen)

					nContador++
					B3K->(dbGoTo((cAlias)->R_E_C_N_O_))
					lRet := PLOBVLDCRI(cRegANS,cCodObri,cAnoComp,cCodComp,aCritBen,;
						"B3K",(cAlias)->R_E_C_N_O_,Nil,Nil,cTipo,;
						aCrit,B3K->B3K_MATRIC,B3K->B3K_NOMBEN,cObri,B3K->B3K_CODCCO+B3K->B3K_MATRIC)

					(cAlias)->(dbSkip())

					If nContador % 100 == 0 .Or. nContador == 1
						PtInternal(1,AllTrim("PLSIBVLBN " + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "] "," ") + AllTrim(Str(nContador)) + " registros validados"))
					EndIf

				EndDo //!(cAlias)->(Eof())

			Else
				cMsg := "Não localizou obrigação do SIB ativa para a operadora informada:" + cRegANS
				If !lJob
					msgAlert(cMsg)
				EndIf
				PlsLogFil(CENDTHRL("I") + " " + cMsg,ARQUIVO_LOG)
			EndIf
		Else
			cMsg := "Não localizou dados para validar"
			If !lJob
				msgAlert(cMsg)
			EndIf
			PlsLogFil(CENDTHRL("I") + " " + cMsg,ARQUIVO_LOG)
		EndIf //SelecBenef()

		(cAlias)->(dbCloseArea())

	Else
		MontaCriticas(cOpe,aCritBen)
		lRet := PLOBVLDCRI(cRegANS,cCodObri,cAnoComp,cCodComp,aCritBen,;
			"B3K",,,oModel,cTipo,;
			aCrit,B3K->B3K_MATRIC,B3K->B3K_NOMBEN,cObri,B3K->B3K_CODCCO+B3K->B3K_MATRIC)
	EndIf //oModel == Nil


	PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Termino PLSIBVLBN" + Iif(!Empty(cEmpresa),"[" + AllTrim(cEmpresa) + "]. Total Reg. Proc.: " + Alltrim(str(nContador)),""),ARQUIVO_LOG)

	B3K->(RestArea(aAreaB3K))

Return lRet

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
Static Function MontaCriticas(cOpe,aCritBen)
	//verificar se no PLSVALSIP já não existe a critica
	If cOpe $ "Incluir"

		aAdd(aCritBen,{"B012","0101","SIBVLDB012"	,"Nome de beneficiário é obrigatório"																		    ,"O Nome NÃO pode conter: Apenas uma palavra | Primeiro nome com apenas uma letra exceto quando for D,I,O,U,Y | Último nome com apenas uma letra, exceto quando for I, O, U,Y | Números | Caracteres especiais @,“”,*,/,{},$,^,[],\,&,!,=,?,+,<,>,(),%,.,;,#,~" ,.F.,"B3K_NOMBEN"})
		aAdd(aCritBen,{"B013","0102","SIBVLDB013"	,"Nome de beneficiário inválido"																			    ,"O Nome NÃO pode conter: Apenas uma palavra | Primeiro nome com apenas uma letra exceto quando for D,I,O,U,Y | Último nome com apenas uma letra, exceto quando for I, O, U,Y | Números | Caracteres especiais @,“”,*,/,{},$,^,[],\,&,!,=,?,+,<,>,(),%,.,;,#,~" ,.F.,"B3K_NOMBEN"})
		aAdd(aCritBen,{"B014","0201","SIBVLDB014"	,"Data de nascimento é obrigatória"																		        ,"Preencher a data de nascimento do beneficiário conforme regra estabelecida pela ANS."	                                                                                                                                                                        ,.F.,"B3K_DATNAS"})
		aAdd(aCritBen,{"B015","0203","SIBVLDB015"	,"Data de nascimento deve ser posterior ou igual a 01/01/1890"											        ,"Preencher a data de nascimento do beneficiário conforme regra estabelecida pela ANS."	                                                                                                                                                                        ,.F.,"B3K_DATNAS"})
		aAdd(aCritBen,{"B016","0301","SIBVLDB016"	,"Código de sexo do beneficiário é obrigatório"															        ,"Preencher o código de sexo do beneficiário conforme regra estabelecida pela ANS. 1-Masculino. 3-Feminino"	                                                                                                                                                    ,.F.,"B3K_SEXO"  })
		aAdd(aCritBen,{"B017","0302","SIBVLDB017"	,"Código de sexo não existe no sistema (código inválido)."												        ,"Preencher o código de sexo do beneficiário conforme regra estabelecida pela ANS. 1-Masculino. 3-Feminino"	                                                                                                                                                    ,.F.,"B3K_SEXO"  })
		aAdd(aCritBen,{"B018","0401","SIBVLDB018"	,"CPF Inválido."																								,"Preencher CPF do beneficiário conforme regras da ANS"	,.F.,"B3K_CPF"})
		aAdd(aCritBen,{"B019","0402","SIBVLDB019"	,"CPF é obrigatório para beneficiário titular (independentemente de idade)."							        ,"Preencher CPF do beneficiário conforme regras da ANS"	,.F.,"B3K_CPF"})
		aAdd(aCritBen,{"B020","0403","SIBVLDB020"	,"CPF é obrigatório para beneficiário dependente com idade igual ou superior a 18 anos."			            ,"Preencher CPF do beneficiário conforme regras da ANS"	,.F.,"B3K_CPF"})
		aAdd(aCritBen,{"B021","0408","SIBVLDB021"	,"CPF ou Nome da Mãe ou CNS ou PIS/PASEP, um deles é obrigatório para dependente menor de idade."	            ,"Preencher pelo menos um dos campos indicados"	,.F.,"B3K_CPF.B3K_NOMMAE.B3K_CNS.B3K_PISPAS"})
		aAdd(aCritBen,{"B022","0503","SIBVLDB022"	,"Nome da Mãe ou CNS ou PIS/PASEP, um deles é obrigatório para titular e dependente maior de idade."	        ,"Preencher pelo menos um dos campos indicados"	,.F.,"B3K_NOMMAE.B3K_CNS.B3K_PISPAS"})
		aAdd(aCritBen,{"B023","0501","SIBVLDB023"	,"PIS/PASEP inválido"																						    ,"Preencha o PIS/PASEP conforme regras da ANS"	,.F.,"B3K_PISPAS"})
		aAdd(aCritBen,{"B025","0601","SIBVLDB025"	,"Nome da Mãe Inválido"																						    ,"O Nome NÃO pode conter: Apenas uma palavra | Primeiro nome com apenas uma letra exceto quando for D,I,O,U,Y | Último nome com apenas uma letra, exceto quando for I, O, U,Y | Números | Caracteres especiais @,“”,*,/,{},$,^,[],\,&,!,=,?,+,<,>,(),%,.,;,#,~" ,.F.,"B3K_NOMMAE"})
		aAdd(aCritBen,{"B026","0701","SIBVLDB026"	,"CNS inválido"																								    ,"Preencher o CNS conforme regras da ANS"	,.F.,"B3K_CNS"})
		aAdd(aCritBen,{"B027","0801","SIBVLDB027"	,"Código de Identificação do Beneficiário é obrigatório"												        ,"Preencher o Código de Identificação do beneficiário, conforme as regras de formação do código estabelecidas pela própria operadora"	,.F.,"B3K_MATRIC"})
		aAdd(aCritBen,{"B029","2101","SIBVLDB029"	,"Código de Indicação de endereço é obrigatório para residentes no Brasil"							            ,"Informar Código de Indicação de endereço:'1' – profissional ou '2' - residencial ou informar que beneficiário reside no exterior"	,.F.,"B3K_TIPEND"})
		aAdd(aCritBen,{"B030","2102","SIBVLDB030"	,"Código de Indicação de endereço não deve existir para beneficiários residentes no exterior"		            ,"Não informar Código de Indicação de endereço"	,.F.,"B3K_TIPEND"})
		aAdd(aCritBen,{"B031","2201","SIBVLDB031"	,"Logradouro é obrigatório para beneficiários residentes no Brasil"									            ,"Informar Logradouro ou informar que beneficiário reside no exterior"	,.F.,"B3K_ENDERE"})
		aAdd(aCritBen,{"B032","2202","SIBVLDB032"	,"Logradouro não deve existir para beneficiários residentes no exterior"								        ,"Não informar Logradouro ou informar que beneficiário reside no Brasil"	,.F.,"B3K_ENDERE"})
		aAdd(aCritBen,{"B033","2301","SIBVLDB033"	,"Número do Logradouro não deve existir no cadastro para beneficiários residentes no exterior"		            ,"Não informar Número do Logradouro ou informar que beneficiário reside no Brasil"	,.F.,"B3K_NR_END"})
		aAdd(aCritBen,{"B034","2302","SIBVLDB034"	,"Número do Logradouro é obrigatório para beneficiários residentes no Brasil"						            ,"Informar número do logradouro ou informar que beneficiário reside no exterior"	,.F.,"B3K_NR_END"})
		aAdd(aCritBen,{"B035","2401","SIBVLDB035"	,"Complemento Logradouro não deve existir no cadastro para beneficiários residentes no exterior"	            ,"Não informar Complemento Logradouro ou informar que beneficiário reside no Brasil"	,.F.,"B3K_COMEND"})
		aAdd(aCritBen,{"B036","2501","SIBVLDB036"	,"Bairro não deve existir no cadastro para beneficiários residentes no exterior"						        ,"Não informar Bairro ou informar que beneficiário reside no Brasil"	,.F.,"B3K_COMEND"})
		aAdd(aCritBen,{"B037","2601","SIBVLDB037"	,"Código de município é obrigatório para beneficiários residentes no Brasil"							        ,"Informar Código de município (IBGE) ou informar que beneficiário reside no exterior"	,.F.,"B3K_CODMUN"})
		aAdd(aCritBen,{"B038","2602","SIBVLDB038"	,"Código de município não existe na tabela de município do IBGE."										        ,"Informar código de município válido."	,.F.,"B3K_CODMUN"})
		aAdd(aCritBen,{"B039","2603","SIBVLDB039"	,"Código de município não deve existir no cadastro para beneficiários residentes no exterior"		            ,"Não informar Código de município (IBGE) ou informar que beneficiário reside no Brasil"	,.F.,"B3K_CODMUN"})
		aAdd(aCritBen,{"B040","2701","SIBVLDB040"	,"CEP é obrigatório para beneficiários residentes no Brasil"											        ,"Informar CEP ou informar que beneficiário reside no exterior"	,.F.,"B3K_CEPUSR"})
		aAdd(aCritBen,{"B041","2703","SIBVLDB041"	,"CEP não deve existir no cadastro para beneficiários residentes no exterior"						            ,"Não informar CEP ou informar que beneficiário reside no Brasil"	,.F.,"B3K_CEPUSR"})
		aAdd(aCritBen,{"B042","2902","SIBVLDB042"	,"Código de município de residência não existe na tabela de município do IBGE."						            ,"Código de município de residência válido"	,.F.,"B3K_MUNICI"})
		aAdd(aCritBen,{"B043","2810","SIBVLDB043"	,"Código de município de residência não deve existir no cadastro para beneficiários residentes no exterior"		,"Não informar Código de município de residência ou informar que beneficiário reside no Brasil"	,.F.,"B3K_MUNICI"})
		aAdd(aCritBen,{"B044","2904","SIBVLDB044"	,"Código de município de residência não deve existir no cadastro para beneficiários com endereço residencial"	,"Não informar Código de município de residência ou informar Código de Indicação de Endereço '2' - residencial"	,.F.,"B3K_MUNICI"})
		aAdd(aCritBen,{"B078","4101","SIBVLDB078"	,"DN inválido."                                                                                                 ,"Preencher DN com 11 caracteres."	,.F.,"B3K_DN"})
		aAdd(aCritBen,{"B045","4103","SIBVLDB045"	,"DN não deve existir no cadastro para beneficiários com data de nascimento anterior a 01/01/2007"              ,"Não preencher DN ou Preencher somente o DN válido, ou seja, com datas de nascimento posteriores a 01/01/2007."	,.F.,"B3K_DN"})
		//aAdd(aCritBen,{"B079","    ","SIBVLDB079"	,"Código de Indicação de Residência (Nacional/Exterior) deve ser informado"                                     ,"Código de Indicação de Residência (Nacional/Exterior) deve ser informado"	,.F.,"B3K_RESEXT"})
		aAdd(aCritBen,{"B046","0205","SIBVLDB046"	,"Data de nascimento deve ser anterior ou igual à primeira data da contratação do plano."			            ,"Preencher a data de nascimento do beneficiário conforme regra estabelecida pela ANS."	,.F.,"B3K_DATNAS"})
		aAdd(aCritBen,{"B047","0409","SIBVLDB047"	,"Já existe registro ativo com o mesmo CPF e plano na operadora."										        ,"Preencher CPF do beneficiário conforme regras da ANS"	,.F.,"B3K_CPF"})
		aAdd(aCritBen,{"B070","0410","SIBVLDB070"	,"Já existe registro ativo com o mesmo CPF, plano e empresa contratante na operadora."                          ,""        ,.F.,"B3K_CNPJCO.B3K_CEICON"})
		aAdd(aCritBen,{"B049","0902","SIBVLDB049"	,"Número do plano (RPS) e código do plano (SCPA) não podem ser informados simultaneamente."		                ,"Verificar o Número do Plano (RPS) ou Código do plano (SCPA) a ser informado e preencher somente um deles no XML correspondente."	,.F.,"B3K_SUSEP.B3K_SCPA"})
		aAdd(aCritBen,{"B050","0903","SIBVLDB050"	,"Um dos planos (RPS ou SCPA) é obrigatório"																    ,"Verificar o Número do Plano (RPS) ou Código do plano (SCPA) a ser informado e preencher somente um deles no XML correspondente."	,.F.,"B3K_SUSEP.B3K_SCPA"})
		aAdd(aCritBen,{"B051","1201","SIBVLDB051"	,"Data de contratação do plano é obrigatória."															        ,"Preencher a data de contratação de acordo com a data estabelecida no contrato do plano de saúde"	,.F.,"B3K_DATINC"})
		aAdd(aCritBen,{"B052","1201","SIBVLDB052"	,"Data de contratação do plano deve ser posterior ou igual a 01/01/1940"								        ,"Preencher a data de contratação de acordo com a data estabelecida no contrato do plano de saúde"	,.F.,"B3K_DATINC"})
		aAdd(aCritBen,{"B053","1201","SIBVLDB053"	,"Data de Contratação deve ser posterior ou igual a 01/01/1999, pois o plano informado é RPS"		            ,"Preencher a data de contratação de acordo com a data estabelecida no contrato do plano de saúde"	,.F.,"B3K_DATINC"})
		aAdd(aCritBen,{"B054","1301","SIBVLDB054"	,"Código de relação de dependência é obrigatório"														        ,"Preencha o código de relação de dependência conforme regra da ANS: '1' - Beneficiário titular (maior ou menor de idade). '3' - Cônjuge/Companheiro. '4' - Filho/Filha. '6' - Enteado/Enteada. '8' - Pai/Mãe "	,.F.,"B3K_TIPDEP"})
		aAdd(aCritBen,{"B055","1302","SIBVLDB055"	,"Código de relação de dependência não existe no sistema."												        ,"Preencha o código de relação de dependência conforme regra da ANS: '1' - Beneficiário titular (maior ou menor de idade). '3' - Cônjuge/Companheiro. '4' - Filho/Filha. '6' - Enteado/Enteada. '8' - Pai/Mãe "	,.F.,"B3K_TIPDEP"})
		aAdd(aCritBen,{"B056","1402","SIBVLDB057"	,"Código de Cobertura Parcial Temporária (CPT) não existe no sistema"									        ,"Preencha o código de Cobertura Parcial Temporária (CPT) conforme regra da ANS: '0' Não possui cobertura parcial temporária. '1' Possui cobertura parcial temporária."	,.F.,"B3K_ITEEXC"})
		aAdd(aCritBen,{"B057","1402","SIBVLDB056"	,"Código de Cobertura Parcial Temporária (CPT) é obrigatório"											        ,"Preencha o código de Cobertura Parcial Temporária (CPT) conforme regra da ANS: '0' Não possui cobertura parcial temporária. '1' Possui cobertura parcial temporária."	,.F.,"B3K_ITEEXC"})
		aAdd(aCritBen,{"B058","1502","SIBVLDB058"	,"Código de itens de procedimentos excluídos da cobertura (IPEC) não existe no sistema."			            ,"Preencha o Código de itens de procedimentos excluídos da cobertura (IPEC) conforme regra da ANS: '0' não há itens de procedimentos excluídos da cobertura. '1' há intens de procedimentos excluídos da cobertura"	,.F.,"B3K_ITEEXC"})
		aAdd(aCritBen,{"B059","1601","SIBVLDB059"	,"CNPJ e CEI da empresa contratante não podem existir no cadastro simultaneamente"					            ,"Preencher somente um dos campos (CNPJ ou CEI)"	,.F.,"B3K_CNPJCO.B3K_CEICON"})
		aAdd(aCritBen,{"B060","1602","SIBVLDB060"	,"CNPJ ou CEI da empresa contratante, um deles deve existir para plano coletivo."					            ,"Preencher um dos campos (CNPJ ou CEI)"	,.F.,"B3K_CNPJCO.B3K_CEICON"})
		aAdd(aCritBen,{"B061","1603","SIBVLDB061"	,"CNPJ ou CEI da empresa contratante não deve existir para plano individual ou familiar."			            ,"Não preencher os campos CNPJ e CEI"	,.F.,"B3K_CNPJCO.B3K_CEICON"})
		aAdd(aCritBen,{"B062","1604","SIBVLDB062"	,"CNPJ da empresa contratante inválido"																	        ,"Preencher CNPJ da empresa contratante conforme regras da ANS"	,.F.,"B3K_CNPJCO"})
		aAdd(aCritBen,{"B063","1704","SIBVLDB063"	,"CEI da empresa contratante inválido"																		    ,"Preencher CEI da empresa contratante conforme regras da ANS" ,.F.,"B3K_CEICON"})
		aAdd(aCritBen,{"B064","1801","SIBVLDB064"	,"Campo de Identificação de beneficiário titular é obrigatório para beneficiário dependente."		            ,"Preencher o campo Código Beneficiário Titular",.F.,"B3K_CODTIT"})
		aAdd(aCritBen,{"B065","1803","SIBVLDB065"	,"Campo de Identificação de beneficiário titular não pertence a um titular."							        ,"Preencher o campo Código Beneficiário Titular com um código válido",.F.,"B3K_CODTIT"})
		aAdd(aCritBen,{"B066","1804","SIBVLDB066"	,"Campo de Identificação de beneficiário titular não deve existir no cadastro para beneficiário titular."	    ,"Não preencher o campo Código Beneficiário Titular"	,.F.,"B3K_CODTIT"})
		aAdd(aCritBen,{"B081","    ","SIBVLDB081"	,"Conteúdo do campo Código Município IBGE está incorreto."	                                                    ,"Preencher o Campo com seis caracteres"	,.F.,"B3K_MUNICI"})
		aAdd(aCritBen,{"B082","    ","BProVazia"	,"Produto do beneficiario nao informado"																	    ,"Informe um produto para o beneficiario",.F.,""})
		aAdd(aCritBen,{"B083","    ","BProValid"    ,"Produto do beneficiario informado e invalido."															    ,"Atualize o cadastro do Produto/Plano",.F.,""})
		aAdd(aCritBen,{"B088","    ","SIBVLDB088"	,"Cep do Beneficiário deve possuir oito caracteres."	                                                        ,"Preencher o Campo com oito caracteres"		,.F.,"B3K_CEPUSR"})
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
/*/{Protheus.doc} SelecBenef

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
Static Function SelecBenef(cAlias,cDataRef,cRegANS,cEmpresa,nRecno)
	Local cSql			:= ""
	Local lRetorno		:= .F.
	Default cAlias		:= ""
	Default cDataRef	:= DTOS(dDataBase)
	Default cRegANS		:= '000000'
	Default cEmpresa	:= ""
	Default nRecno		:= 0

	If cAlias == "TRBBEN"

		cSql := " SELECT DISTINCT B3K.R_E_C_N_O_,B3X_OPERA "
		cSql += " FROM " + RetSqlName("B3K") + " B3K "
		cSql += " LEFT JOIN " + RetSqlName("B3X") + " B3X "
		cSql += " ON B3K_FILIAL = B3X_FILIAL "
		cSql += "    AND B3K.B3K_CODOPE = B3X_CODOPE "
		cSql += "    AND B3K.B3K_MATRIC = B3X_IDEORI "
		cSql += "    AND B3K.B3K_CODCCO = B3X_CODCCO "
		cSql += " WHERE B3K_FILIAL = '" + xFilial("B3K") + "' "
		If nRecno = 0 //Pego todos os beneficiários com valid. pdte
			cSql += " AND B3K_CODOPE = '" + cRegANS + "' "
			cSql += " AND B3K_STASIB in ('1','3') "
			cSql += " AND B3K.D_E_L_E_T_ = ' ' "
			cSql += " AND (B3X.D_E_L_E_T_ = ' ' OR B3X.D_E_L_E_T_ IS NULL) "
		Else //Pego o beneficiario selecionado
			cSql += " AND B3K.R_E_C_N_O_ = " + Alltrim(str(nRecno)) + " "
		EndIf


	EndIf

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
/*/{Protheus.doc} PLSSIBRTV

Funcao criada para retornar a lista de rotinas / jobs de validacao

@param cDado		Variavel passada por referencia para receber a lista de opcoes selecionada do F3
@description
	Lista de opcoes
	1 - Produtos / Plano
	2 - Beneficiarios
	3 - Eventos X Despesas

@return cDados		Lista de opcoes selecionadas no F3 separadas por virgula

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSSIBRTV(cDado)
	Local oDlg		:= Nil
	Local aConjunto	:= {}
	Local nFor		:= 0
	Local nOpc		:= 0
	Local bOK		:= { || nOpc := 1, oDlg:End() }
	Local bCancel	:= { || oDlg:End() }
	Default cDado	:= ''

	aAdd(aConjunto,{'1','Produtos / Planos'	,.F.})
	aAdd(aConjunto,{'2','Beneficiarios'		,.F.})
	aAdd(aConjunto,{'3','Eventos x Despesas',.F.})

	DEFINE MSDIALOG oDlg TITLE 'Conjuntos a processar' FROM 008.0,010.3 TO 036.4,100.3 OF GetWndDefault()
	@ 020,012 SAY oSay PROMPT 'Selecione o(s) conjunto(s) a serem procesados' SIZE 100,010 OF oDlg PIXEL COLOR CLR_HBLUE
	oConjunto := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	oConjunto:AddColumn(TcColumn():New(" "			,{ || IF(aConjunto[oConjunto:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) }	,"@!",Nil,Nil,Nil,015,.T.,.T.,Nil,Nil,Nil,.T.,Nil))
	oConjunto:AddColumn(TcColumn():New('Codigo'		,{ || OemToAnsi(aConjunto[oConjunto:nAt,1]) }																		,"@!",Nil,Nil,Nil,020,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	oConjunto:AddColumn(TcColumn():New('Descricao'	,{ || OemToAnsi(aConjunto[oConjunto:nAt,2]) }																		,"@!",Nil,Nil,Nil,200,.F.,.F.,Nil,Nil,Nil,.F.,Nil))
	oConjunto:SetArray(aConjunto)
	oConjunto:bLDblClick := { || aConjunto[oConjunto:nAt,3] := Eval( { || nIteMar := 0, aEval(aConjunto, {|x| IIf(x[3], nIteMar++, )}), IIf(nIteMar < 12 .Or. aConjunto[oConjunto:nAt, 3],IF(aConjunto[oConjunto:nAt,3],.F.,.T.),.F.) })}
	ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})

	If nOpc == 1

		cDado := ""
		For nFor := 1 To Len(aConjunto)
			If aConjunto[nFor,3]
				cDado += aConjunto[nFor,1]+","
			Endif
		Next

	Endif

	//Tira a virgula do final
	If Subs(cDado,Len(cDado),1) == ","
		cDado := Subs(cDado,1,Len(cDado)-1)
	EndIf

Return .T.
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
/*STATIC FUNCTION ChecErro(e)

__cError := e:Description
__cCallStk := e:ErrorStack

BREAK

Return*/