#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEM023.CH"

Static nOrdemMult 	:= 0
Static lWorkFlow  	:= IIF(TYPE("lWorkFlow") == "L", lWorkFlow, .F.)
Static lMiddleware 	:= Iif(cPaisLoc == 'BRA' .And. findfunction("fVerMW") , fVerMW(),SuperGetMv("MV_MID",, .F.))
Static lTemRJM		:= ChkFile("RJM")
Static nTamCC		:= TamSx3("RA_CC")[1]

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEM023D ³ Autor ³ Marcia Moura                                ³ Data ³ 10/11/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina de Envio de Eventos - Estabelecimentos e lotações                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEM023D()                                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ FNC/Requisito  ³ Chamado ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcia Moura |30/10/2015|                |TTHMWK   ³Integracao do registro S-1005 com o TAF    ³±±
±±³Marcia Moura |17/11/2015|                |TTHN03   ³Integracao do registro S-1020 com o TAF    ³±±
±±³Marcia Moura ³18/05/2016|                ³TVEJZM   ³Adaptacao leiaute 2.2                      ³±±
±±³Marcos Cout  ³02/05/2017|                ³DRHESOCP-214³Adaptação do leiaute do eSocial         ³±±
±±³             ³          |                ³         ³Manutenção na tabela S-1005 e S-1020       ³±±
±±³Marcia Moura ³02/06/2017³DRHESOCP-316    ³         ³Pacote para Atendimento                    ³±±
±±³Marcos Cout ³12/06/2017 ³DRHESOCP-389    ³         ³War Room + Merge                           ³±±
±±³            ³           ³                ³         ³Subir fontes para release superior (17)    ³±±
±±³Marcia Moura³29/06/2017 ³DRHESOCP-516    ³         ³Erros encontrados durante os testes FILIPI ³±±
±±³Marcia Moura³04/07/2017 ³DRHESOCP-548    ³         ³Erros no relatorio de inconsistencias S1005³±±
±±³Marcia Moura³05/07/2017 ³DRHESOCP-547    ³         ³Erros no relatorio de inconsistencias S1020³±±
±±³Oswaldo L   ³07/07/2017 ³DRHESOCP-579    ³         ³Ajuste erro de sintaxe no fonte            ³±±
±±³Marcos Cout ³28/07/2017 ³DRHESOCP-703    ³         ³Realizar ajustes estéticos e padronizados  ³±±
±±³            ³           ³                ³         ³no relatório de Carga Inicial dos Eventos  ³±±
±±³Marcos Cout ³01/08/2017 ³DRHESOCP-       ³         ³Realizar ajustes estéticos e padronizados  ³±±
±±³            ³           ³                ³         ³no relatório de Lotação, Estab e Obras     ³±±
±±³Marcos Cout ³09/08/2017 ³ DRHESOCP-32 /  ³         ³Realizar a criação dos eventos extemporaneo³±±
±±³            ³           ³   DRHESOCP-562 ³         ³dos eventos S-1005 e S-1020                ³±±
±±³Marcos Cout ³31/08/2017 ³ DRHESOCP-628   ³         ³Realizar ajustes necessários para retornar ³±±
±±³            ³           ³                ³         ³o tipo de ponto informada na tabela S-119  ³±±
±±³Marcos Cout |14/09/2017|DRHESOCP-1018    |         |Realizando o ajuste necessário para que o  ³±±
±±³            |          |                 |         |sistema realize a validação do layout dispo³±±
±±³            |          |                 |         |_nível no ambiente para fazer a integração ³±±
±±³            |          |                 |         |entre o SIGAGPE e o SIGATAF                ³±±
±±|Claudinei S.|25/09/2017|DRHESOCP-1130    |         |Ajuste em fObraX14() para preencher a tag  |±±
±±|            |          |                 |         |<regPt> com o tipo do ponto da tabela S041 |±±
±±|            |          |                 |         |ou S119 dependendo do leiaute do eSocial   |±±
±±|Marcos Cout.|03/10/2017|DRHESOCP-1329    |         |Realizar os ajustes necessários para que a |±±
±±|            |          |                 |         |filial 'MATRIZ' enviem as suas lotações e  |±±
±±|            |          |                 |         |de suas afiliadas corretamente             |±±
±±|Marcos Cout.|06/10/2017|DRHESOCP-1469    |         |Removida variavel declarada incorretamente |±±
±±|            |          |                 |         |que causava error.log ao realizar a carga  |±±
±±|            |          |                 |         |inicial do evento S-1005 - Estabelecimento |±±
±±|Eduardo V.  |20/12/2017|  DRHESOCP-2448	|         |Inclusão de condicional para validação de  |±±
±±|            |          |                 |         |campos CTT_TIPO2 e CTT_TPLOT    			  |±±
±±|Marcos Cout.|20/10/2017|DRHESOCP-2449    |         |Realizado ajustes na geração das TAGS qnd  |±±
±±|            |          |DRHESOCP-2450    |         |Tipo de Lotação é igual a "01"             |±±
±±|            |          |DRHESOCP-2452    |         |                                           |±±
±±|Marcos Cout.|03/01/2018|DRHESOCP-2655    |         |Realizando ajustes para gerar S1005 config |±±
±±|            |          |                 |         |para <tpInsc> igual a "3" - CAEPF          |±±
±±|Eduardo V.  |05/01/2018|DRHESOCP-2678	|         |Troc de valor lógico da fCar_RAIS,onde para|±±
±±|            |          |                 |         |de exibir a mensagem indevida na carga     |±±
±±|Marcos Cout.|10/01/2018|DRHESOCP-2656    |         |Realizar ajustes na geração do evento S1005|±±
±±|            |          |                 |         |Empreitada Total ou Sub-Empreitada         |±±
±±|Renan Borges|10/01/2018|DRHESOCP-2678    |         |Realizado ajustes para corrigir Filial Ma_ |±±
±±|            |          |                 |         |triz no momento do envio                   |±±
±±|Marcos Cout.|10/01/2018|DRHESOCP-2656    |         |Ajustando fluxo para geração do evento     |±±
±±|            |          |                 |         |S-1005 para Produtor Rural. Criado bloco de|±±
±±|            |          |                 |         |inconsistência para CAEPF                  |±±
±±|Marcos Cout.|26/01/2018|DRHESOCP-2928    |         |Realizando ajustes para que durante a carga|±±
±±|            |          |                 |         |inicial, o sistema não fique informando que|±±
±±|            |          |                 |         |sobre o campo matriz em reg vazios na S119 |±±
±±|            |          |                 |         |Ajustes para gerar o <fap> e <aliqRatAjust>|±±
±±|Marcos Cout.|01/02/2018|DRHESOCP-3007    |         |Realizado ajuste na leitura da tabela S120 |±±
±±³Eduardo V.  |02/02/2018| DRHESOCP-2852   |         |Inclusão de adaptações para extemporaneo	  |±±
±±|            |          |                 |         |de lotação                                 |±±
±±|Eduardo vic.|07/02/2018|DRHESOCP-2927    |         |Inclusão de validação para Entidade		  |±±
±±|Marcos Cout |16/02/2018|DRHESOCP-126     |         |Realizando ajustes para geração da integra-|±±
±±|            |          |                 |         |ção com evento S-1005 a partir da manuten- |±±
±±|            |          |                 |         |ção de tabelas.                            |±±
±±|Marcos Cout |22/02/2018|DRHESOCP-3217    |         |Ajuste no calculo do RAT, PERAC e FAP      |±±
±±|Marcos Cout.³23/02/2018³DRHESOCP-3059              ³Adicionar na carga inicial a opção         ³±±
±±|            ³          ³                           ³"Exclusão em Lote" para remover do RET os  ³±±
±±|            ³          ³                           ³eventos já integrado                       ³±±
±±|Marcos Cout.³28/02/2018³DRHESOCP-3307              ³Realizando a criação da Exclusão em lote p/³±±
±±|            ³          ³                           ³o evento S-1005 Estabelecimento e S-1020   ³±±
±±|            ³          ³                           ³Lotação                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPEM023D()

	Local aArea		 	:= GetArea()
	Local aAreaCR9  	:= {}
	Local oProcesso	 	:= Nil
	Local oDlgEven		:= Nil
	Local cAliasTRB		:= GetNextAlias()
	Local cProcesso		:= ""
	Local nOpcX			:= 0
	Local dDataRef		:= SToD("  /  /    ")
	Local aSizeTel		:= MsAdvSize(.F.)
	Local aObjects		:= {}
	Local aInfo			:= {}
	Local aPosObj		:= {}
	Local oFWLayer		:= FWLayer():New()
	Local aBotoes  	 	:= {}

	RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGp23InSM0³ Autor ³ Alessandro Santos     ³ Data ³27/05/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Adiciona informacoes no array para impressao de inconsisten ³±±
±±³          ³cias para Sigamat.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGp23InSM0()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023  					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Static Function fGp23InSM0(aLogProc, aEstObras, cMsgLog,cVersEnvio)

	Local aArea	:= GetArea()

	//Inicia inconsistencias
	aAdd(aLogProc, OemToAnsi(STR0086) +  " -> " + aEstObras[8]) //##"Filial"
	//tem que ter tipo e numero de inscricao, percetual acidente trabalho, CNAE, RAT, Contrata aprendiz e Informação de ponto

	//-----------------------------------------------------------------------------------------
	//| Se aEstObras[12,1] == .T. significa que NÃO É OBRA e quem alimenta o campo é o SIGAMAT
	//| caso contrário, SE FOR OBRA, quem alimenta é a tabela F0F, que já é tratado la embaixo
	//-----------------------------------------------------------------------------------------
	If aEstObras[12,1] .AND. aEstObras[13,1]
		//Campo tipo vazio - <tpInsc>
		If Empty(aEstObras[1])
			aAdd(aLogProc,   OemToAnsi(STR0129) + " - " + OemToAnsi(STR0130)) //##"Sigamat" ##"Tipo de Inscrição"
			cMsgLog += " - " + OemToAnsi(STR0130) //##"Tipo de Inscrição"
		EndIf

		//Campo Cei2 vazio - <nrInsc>
		If Empty(aEstObras[2])
			aAdd(aLogProc,   OemToAnsi(STR0129) + " - " + OemToAnsi(STR0131)) //##"Sigamat" ##"CEI"
			cMsgLog += " - " + OemToAnsi(STR0131) //##"CEI"
		EndIf
	EndIf

	//Campo Cnae vazio
	If Empty(aEstObras[4])
		aAdd(aLogProc,   OemToAnsi(STR0129) + " - " + OemToAnsi(STR0135)) //##"Sigamat" ##"Código CNAE"
		cMsgLog += " - " + OemToAnsi(STR0135) //##"Código CNAE"
	EndIf

	//Aprendiz
	If empty(aEstObras[6])
		aAdd(aLogProc,   OemToAnsi(STR0159) ) //##"PReencher os dados de Aprendiz
		cMsgLog += " - " + OemToAnsi(STR0159)	//##"PReencher os dados de Aprendiz
	EndIf

	//S119 - Tipo Ponto
	If empty(aEstObras[7])
		aAdd(aLogProc,   If(cVersEnvio < "2.3", OemToAnsi(STR0167),OemToAnsi(STR0158))  ) //##"O Campo Regime do Ponto está vazio e seu preenchimento é obrigatório, utilize a tabela S119"
		cMsgLog += " - " + If(cVersEnvio < "2.3", OemToAnsi(STR0167),OemToAnsi(STR0158))	//##"O Campo Regime do Ponto está vazio e seu preenchimento é obrigatório, utilize a tabela S119"
	EndIf

	//S119 - Empresa é a Matriz e não está marcada como Matriz na S119
	If aEstObras[9] //lEmpMatriz
		aAdd(aLogProc,   OemToAnsi(STR0192) ) //##"A empresa está configurada como matriz e o campo Empresa Matriz não foi marcado como Matriz na tabela S119"
		cMsgLog += " - " + OemToAnsi(STR0192)	//##"A empresa está configurada como matriz e o campo Empresa Matriz não foi marcado como Matriz na tabela S119"
	Endif

	//S119 - Empresa não é Matriz e está marcada como Matriz na S119
	If aEstObras[10] //lFilMatriz
		aAdd(aLogProc,   OemToAnsi(STR0193) ) //##"A empresa não está configurada como matriz e o campo Empresa Matriz foi marcado como Matriz na tabela S119"
		cMsgLog += " - " + OemToAnsi(STR0193)	//##"A empresa não está configurada como matriz e o campo Empresa Matriz foi marcado como Matriz na tabela S119"
	Endif

	//S119 - Empresa não é Matriz e está marcada como Matriz na S119
	If !aEstObras[11] //lTb119
		aAdd(aLogProc,   OemToAnsi(STR0194) ) //##"Tabela S119 com os dados do Estabelecimento\Obra não foi encontrada"
		cMsgLog += " - " + OemToAnsi(STR0194)	//##"Tabela S119 com os dados do Estabelecimento\Obra não foi encontrada"
	Endif

	//Erro no Complemento de Estabelecimento (OBRAS - F0F)
	If !aEstObras[12,1]

		//Cenário#1 - Não encontrou o Registro dentro da tabela F0F - Complemento de Empresa
		If Empty(aEstObras[12,2]) .and. Empty(aEstObras[12,3])
			aAdd(aLogProc, OemToAnsi(STR0202) + " " + OemToAnsi(STR0203)) //##"A obra não está cadastrada no Complemento de Empresa. Verifique o cadastro antes de realizar a integração"
			cMsgLog += " - " + OemToAnsi(STR0202) + " " + OemToAnsi(STR0203)	//##"A obra não está cadastrada no Complemento de Empresa. Verifique o cadastro antes de realizar a integração"
		Else
			//Cenário#2 - Encontrou o Registro dentro da tabela F0F mas possui o F0F_CNO vazio
			If Empty(aEstObras[12,2])
				aAdd(aLogProc, OemToAnsi(STR0204) + " " + OemToAnsi(STR0203)) //##"A obra não possui o código de CNO preenchido no Complemento de Empresa. Verifique o cadastro antes de realizar a integração"
				cMsgLog += " - " + OemToAnsi(STR0204) + " " + OemToAnsi(STR0203)	//##"A obra não possui o código de CNO preenchido no Complemento de Empresa. Verifique o cadastro antes de realizar a integração"
			EndIf

			//Cenário#3 - Encontrou o Registro dentro da tabela F0F mas possui F0F_TPOBRA vazio
			If Empty(aEstObras[12,3])
				aAdd(aLogProc, OemToAnsi(STR0205) + " " + OemToAnsi(STR0203)) //##"A obra não possui o Tipo de Obra cadastrada no Complemento de Empresa. Verifique o cadastro antes de realizar a integração"
				cMsgLog += " - " + OemToAnsi(STR0205) + " " + OemToAnsi(STR0203)	//##"A obra não possui o Tipo de Obra cadastrada no Complemento de Empresa. Verifique o cadastro antes de realizar a integração"
			EndIf

			//Cenário#4 - Encontrou o Registro dentro da tabela F0F mas possui F0F_TPOBRA igual a "2 - Sub Empreitada"
			If (aEstObras[12,3] == "2")
				aAdd(aLogProc, OemToAnsi(STR0206) + " " + OemToAnsi(STR0203)) //##"A obra está cadastrada como 'Sub-Empreitada ou Parcial' no Complemento de Empresa. Verifique o cadastro antes de realizar a integração"
				cMsgLog += " - " + OemToAnsi(STR0206) + " " + OemToAnsi(STR0203)	//##"A obra está cadastrada como 'Sub-Empreitada ou Parcial' no Complemento de Empresa. Verifique o cadastro antes de realizar a integração"
			EndIf
		EndIf

	Endif

	//Erro no Complemento de Estabelecimento (PRODUTOR RURAL - F0F)
	If !aEstObras[13,1]

		//Cenário#0 - Registro no SIGAMAT está preenchido incorretamente.
		If aEstObras[13,4] $ "2|3"
			aAdd(aLogProc, OemToAnsi(STR0211) ) //##"Caso opte por CEI, o produtor rural deve estar cadastrado como '1 - Pessoa Física' no campo Produtor Rural dentro do SIGAMAT"
			cMsgLog += " - " + OemToAnsi(STR0211) + " " + OemToAnsi(STR0203)	//##"Caso opte por CEI, o produtor rural deve estar cadastrado como '1 - Pessoa Física' no campo Produtor Rural dentro do SIGAMAT". Verifique o cadastro antes de realizar a integração"
		Else
			//Cenário#1 - Não encontrou o Registro dentro da tabela F0F - Complemento de Empresa
			If Empty(aEstObras[13,2]) .and. Empty(aEstObras[13,3])
				aAdd(aLogProc, OemToAnsi(STR0207) ) //##"O produtor rural não está cadastrada no Complemento de Empresa (F0F)."
				cMsgLog += " - " + OemToAnsi(STR0207) + " " + OemToAnsi(STR0203)	//##"O produtor rural não está cadastrada no Complemento de Empresa (F0F). Verifique o cadastro antes de realizar a integração"
			Else
				//Cenário#2 - Encontrou o Registro dentro da tabela F0F mas possui o F0F_CAEPF vazio
				If Empty(aEstObras[13,2])
					aAdd(aLogProc, OemToAnsi(STR0208) ) //##"O produtor rural não possui o código de CAEPF preenchido no Complemento de Empresa (F0F)."
					cMsgLog += " - " + OemToAnsi(STR0208) + " " + OemToAnsi(STR0203)	//##"O produtor rural não possui o código de CAEPF preenchido no Complemento de Empresa (F0F). Verifique o cadastro antes de realizar a integração"
				EndIf

				//Cenário#3 - Encontrou o Registro dentro da tabela F0F mas possui F0F_TPCAEP vazio
				If Empty(aEstObras[13,3])
					aAdd(aLogProc, OemToAnsi(STR0209) ) //##"O produtor rural não possui o Tipo de CAEPF cadastrada no Complemento de Empresa (F0F)."
					cMsgLog += " - " + OemToAnsi(STR0209) + " " + OemToAnsi(STR0203)	//##"O produtor rural não possui o Tipo de CAEPF cadastrada no Complemento de Empresa (F0F)."
				EndIf

				//Cenário#4 - Encontrou o Registro dentro da tabela F0F mas possui F0F_TPCAEP diferente de "2 - Produtor Rural"
				If (aEstObras[13,3] <> "2" .AND. !Empty(aEstObras[13,3]))
					aAdd(aLogProc, OemToAnsi(STR0210) ) //##"O produtor rural deve estar cadastrado como 'Produtor Rural' no Tipo de CAEPF no Complemento de Empresa (F0F)."
					cMsgLog += " - " + OemToAnsi(STR0210) + " " + OemToAnsi(STR0203)	//##"O produtor rural deve estar cadastrado como 'Produtor Rural' no Tipo de CAEPF no Complemento de Empresa (F0F)."
				EndIf

				//Cenário#5 - Encontrou o Registro dentro da tabela F0F mas no SIGAMAT esta como CEI e PRODUTOR RURAL igual a 2 (PJ) ou 3 (ESPECIAL)
				If (aEstObras[13,4] $ "2|3")
					aAdd(aLogProc, OemToAnsi(STR0211) ) //##"Caso opte por CEI, o produtor rural deve estar cadastrado como '1 - Pessoa Física' no campo Produtor Rural dentro do SIGAMAT"
					cMsgLog += " - " + OemToAnsi(STR0210) + " " + OemToAnsi(STR0203)	//##"Caso opte por CEI, o produtor rural deve estar cadastrado como '1 - Pessoa Física' no campo Produtor Rural dentro do SIGAMAT"
				EndIf
			EndIf
			aAdd(aLogProc, OemToAnsi(STR0203) ) //##""Verifique o cadastro antes de realizar a integração"
		EndIf

	Endif

	//Pula linha
	aAdd(aLogProc, "")

	RestArea(aArea)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fObraX14  ³ Autor ³ Alessandro Santos     ³ Data ³02/03/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza carga das tabelas de Obras para o TAF               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCargObras()                                          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Function fObraX14(cMesAnoP, nOpcAP, aLogProc, aDados, aArrayFilP, dPar7, cVersEnvio, aDdsX14, nOpcAux, aRegsManut, aRegS119, aRegS120, cFilRCC, lPeriod, cCodigo)
	Local aArea		 	:= GetArea()
	Local cMenIni    	:= ""
	Local cInscric   	:= ""
	Local cTpInscr   	:= ""
	Local cResumo		:= ""
	Local cMsgLog		:= ""
	Local cLayout		:= ""
	Local cTpReg 		:= ""
	Local cTpPcd 		:= ""
	Local cNrPcd 		:= ""
	Local cTpApr 		:= ""
	Local cNrApr 		:= ""
	Local cTpEEn 		:= ""
	Local cAnoMes		:= AnoMes(dPar7)
	Local cSub			:= ""
	Local cEmpMat		:= ""

	Local nFAP			:= 0
	Local nRAT			:= 0
	Local nAcident		:= 0
	Local nI			:= 0
	Local nCont			:= 0
	Local z1 			:= 0
	Local nPos 			:= 0
	Local nPos1 		:= 0
	Local nS119			:= 0
	Local nS120			:= 0
	Local nE			:= 0
	Local nR			:= 0
	Local lContinua		:= .T.
	Local cStatus		:= ""
	Local cFPAS 		:= ""
	Local aInfoFil   	:= {}
	Local aEstObras  	:= {}
	Local aErros		:= {}
	Local aFilEnv		:= {}
	Local aSM0    		:= {}
	Local aX14			:= {}
	Local aTabS119		:= {}
	Local aTabS120		:= {}
	Local aTabS129		:= {}
	Local aEstEd		:= {}
	Local aArrayP 		:= {}
	Local aResumo 		:= {}
	Local aIncons 		:= {}
	Local aAreaRA0
	Local dDataRef
	Local nX			:= 0
	Local nHrInicio
	Local nContador		:= 0
	Local nContErr		:= 0
	Local nHrFim
	Local nPosInco		:= 0
	Local lPonto		:= .T.
	Local lTabS129		:= .F.

	Local cFilEmp		:= ""
	Local lEntEduc		:= .F.
	Local lEmpMatriz	:= .F. //Verificar se é Matriz e não está informada na S119
	Local lFilMatriz    := .F. //Verificar se não é Matriz e está informada como Matriz na S119
	Local lTb119		:= .F. //Se encontrou a filial da tabela S119
	Local lCAEPF		:= .F.
	Local cCAEPF		:= ""
	Local cTpCAEPF		:= ""
	Local aCAEPFF0F		:= {.T.,"","",""} //Valor inicial indiferente do cenário (Adequa a validacao)
	Local cSGMTCAEPF	:= ""
	Local lOBRA			:= .F.
	Local cCEIObra		:= ""
	Local cTpObra		:= ""
	Local aObrasF0F		:= {.T.,"",""} //Valor inicial indiferente do cenário (Adequa a validacao)
	Local lMatriz		:= .F.
	Local aResumo		:= {}
	Local aTabS119		:= {}
	Local aTabS120		:= {}
	Local lExtS119		:= .F.
	Local lExtS120		:= .F.
	Local lExtemp		:= .F.
	Local cChave		:= ""
	Local nOpcao		:= 0
	Local nCol			:= 0
	Local lIgual		:= .F.
	Local lRccCompart	:= .F.
	Local nManut		:= 0
	Local lContinua		:= .T.
	Local aColsManut	:= {}
	Local lExtS037		:= .F.
	Local nPos2 		:= 0
	Local nS137 		:= 0
	Local nS129 		:= 0
	Local nPos129 		:= 0
	Local cFunc			:= ""

	Local aInfoFil		:= {}
	Local aDadosMID		:= {}
	Local aInfoC		:= {}
	Local dDtGer		:= Date()
	Local cHrGer		:= Time()
	Local lAdmPubl		:= .F.
	Local cTpInsc		:= ""
	Local cSeqId    	:= "00001"
	Local cStatOld		:= ""
	Local fName			:= "GPEM023"
	Local cKey			:= ""
	local cFilEnv		:= ""
	Local cId			:= ""
	Local cRetKey   	:= ""
	Local cMsgDesat 	:= ""
	Local cNrInsc		:= ""
	Local cVersMW		:= ""
	Local lNT15			:= .F.
	Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
	Local cTpProc		:= ""
	Local cNrProc		:= ""
	Local cCSusp		:= ""
	Local cTp			:= ""
	Local lTemRJL		:= ChkFile("RJL")
	Local tpCaepf		:= ""
	Local cCNPJR		:= ""

	Default cMesAnoP 	:= ""
	Default nOpcAP 		:= 1
	Default aArrayFilP 	:= {}
	Default cVersEnvio	:= "2.2" //Responsavel por armazenar a versão do layout de envio
	Default nOpcAux     := 3
	Default aDdsX14     := {}
	Default aRegsManut  := {}
	Default aRegS119	:= {}
	Default aRegS120	:= {}
	Default cFilRCC		:= xFilial("RCC")
	Default lPeriod     := .F.
	Default cCodigo		:= ""


	Private aInfRAIS 	:= {}

	if lMiddleware .and. !ChkFile("RJ9") .And. !ChkFile("RJE")
		cMsgDesat := CRLF + OemToAnsi(STR0260) + CRLF
		MSGINFO(cMsgDesat,STR0036)
		Return()
	EndIf



	cFilEnv				:= aArrayFilP[2]
	aFilEnv				:= aArrayFilP[3]
	If Len(aArrayFilP) > 3
		lMatriz := aArrayFilP[4]
	EndIf


	If( Len(aRegS119) > 0 ) .OR. ( Len(aRegS120) > 0 ) .OR. ( Len(aDdsX14) )
		lExtemp := .T.
	EndIf

	If Empty(xFilial("RCC"))
		lRccCompart := .T.
	EndIf

	//Monta variavel dDataRef da data de competencia em aberto p/ busca do fCarrTab
	If !Empty(cMesAnoP)
		dDataRef			:= cToD( "01/" + SubStr( cMesAnoP, 1, 2 ) + "/" + SubStr( cMesAnoP, 3, 4 ) )
		cAnoMes				:= SubStr(cMesAnoP,3,4)+SubStr(cMesAnoP,1,2)
	EndIf

	//Se for exclusão em Lote
	If nOpcAP == 5
		nOpcAux := 5
	EndIf

	nOpcao := nOpcAux

	If Len(aFilEnv) > 0
		lTb119 := .F.
		fVersEsoc( "S1005", .F., Nil, Nil, Nil, Nil, @cVersMW, @lNT15 )
		//Inicio de Operação
		nHrInicio := Seconds()

		For nI := 1 To Len(aFilEnv)
			//Limpa para proxima carga de filial
			aEstEd := {}

			//Reseta valor para o padrão da tela
			nOpcAux := nOpcao

			lIgual := .F.

			If !IsBlind()
				//Inicializa regua de processamento
				ProcRegua(nI)
			EndIf
			//Verifica a filial da tabela RCC logada e se for a mesma da filial que esta sendo enviada
			//o fluxo segue, se não volta para o topo
			If lExtemp .and. !lRccCompart
				If !AllTrim(xFilial("RCC", aFilEnv[nI])) $ Alltrim(cFilRCC)
					lLog := .F.
					Loop
				EndIf
			EndIf

			//Busca informacoes detalhadas da filial pois FWLoadSM0 nao traz todas necessarias
			fInfo(aInfoFil, aFilEnv[nI], cEmpAnt)

			//Limpa variaveis
			cInscric := ""
			cTpInscr := ""
			lTabS129 := .F.

			//Busca CNPJ ou CEI da Filial e Tipo de Inscricao
			If Valtype(aInfoFil[15]) <> "N"
				//--------------------------------------
				//| Gera Obra | Se for CEI e Produtor
				//| 1 ->CEI   | Rural for vazio
				//----------------------------------------
				If Val(aInfoFil[15]) == 1 .AND. Empty(aInfoFil[12])
					//Realiza a busca pela OBRA na tabela F0F
					lOBRA := fBuscaOBRA( aFilEnv[nI], @cCEIObra, @cTpObra )
					aObrasF0F := {lOBRA, cCEIObra, cTpObra}

					//Se não encontrar na F0F, segue o fluxo normal
					If lOBRA
						cInscric := cCEIObra //CEI
						cTpInscr := "4"
					EndIf

					//--------------------------------------
					//| Gera Empresa | Se for CNPJ/CGC
					//| 2 ->CNPJ     |
					//----------------------------------------
				ElseIf val(aInfoFil[15]) == 2
					cInscric := aInfoFil[8] //CGC
					cTpInscr := "1"

					//--------------------------------------------
					//| Gera CAEPF               | Se for CEI mas
					//| 1 ->CEI + 1 ->Prod Rural | estiver cadastrado
					//| 3 ->CPF                  | como Produtor Rural
					//|                          | ou se for CPF
					//-------------------------------------------------
				ElseIf val(aInfoFil[15]) == 3 .OR. ( val(aInfoFil[15]) == 1 .AND. !Empty(aInfoFil[12]) )
					//Realiza a busca pelo CAEPF na tabela F0F
					lCAEPF := fBuscaCAEPF( aFilEnv[nI], @cCAEPF, @cTpCAEPF )

					//Caso SIGAMAT esteja como CEI e Produtor Rural for diferente de "1 - Pessoa Física" = Bloqueia
					If ( val(aInfoFil[15]) == 1 .AND. aInfoFil[12] $ "2|3" )
						cSGMTCAEPF = aInfoFil[12]
						lCAEPF := .F.
					EndIf

					//Se não encontrar na F0F, segue o fluxo normal
					If lCAEPF
						cInscric := cCAEPF //CAEPF
						cTpInscr := "3"
					EndIf

					aCAEPFF0F := {lCAEPF, cCAEPF, cTpCAEPF, cSGMTCAEPF}

				EndIf
			Else
				//--------------------------------------
				//| Gera Obra | Se for CEI e Produtor
				//| 1 ->CEI   | Rural for vazio
				//----------------------------------------
				If aInfoFil[15] == 1 .AND. Empty(aInfoFil[12]) .And. aInfoFil[28] <> 3
					//Realiza a busca pela OBRA na tabela F0F
					lOBRA := fBuscaOBRA( aFilEnv[nI], @cCEIObra, @cTpObra )
					aObrasF0F := {lOBRA, cCEIObra, cTpObra}

					If lOBRA
						cInscric := cCEIObra //CEI
						cTpInscr := "4"
					EndIf

					//--------------------------------------
					//| Gera Empresa | Se for CNPJ/CGC
					//| 2 ->CNPJ     |
					//----------------------------------------
				ElseIf aInfoFil[15] == 2
					If fBuscaCAEPF( aFilEnv[nI], @cCAEPF, @cTpCAEPF )
						cInscric := cCAEPF
						cTpInscr := "3"
						aCAEPFF0F := {.T., cCAEPF, cTpCAEPF, cSGMTCAEPF}
					Else
						cInscric := aInfoFil[8] //CGC
						cTpInscr := "1"
					EndIf

					//--------------------------------------------
					//| Gera CAEPF               | Se for CEI mas
					//| 1 ->CEI + 1 ->Prod Rural | estiver cadastrado
					//| 3 ->CPF                  | como Produtor Rural
					//|                          | ou se for CPF
					//-------------------------------------------------
				ElseIf aInfoFil[15] == 3 .OR. ( aInfoFil[15] == 1 .AND. (!Empty(aInfoFil[12]) .Or. aInfoFil[28] == 3) )

					//Realiza a busca pelo CAEPF na tabela F0F
					lCAEPF := fBuscaCAEPF( aFilEnv[nI], @cCAEPF, @cTpCAEPF )

					//Caso SIGAMAT esteja como CEI e Produtor Rural for diferente de "1 - Pessoa Física" = Bloqueia
					If ( aInfoFil[15] == 1 .AND. aInfoFil[12] $ "2|3" )
						cSGMTCAEPF = aInfoFil[12]
						lCAEPF := .F.
					EndIf

					//Se não encontrar na F0F, segue o fluxo normal
					If lCAEPF
						cInscric := cCAEPF //CAEPF
						cTpInscr := "3"
					EndIf

					aCAEPFF0F := {lCAEPF, cCAEPF, cTpCAEPF, cSGMTCAEPF}

				EndIf
			EndIf

			If cVersEnvio < "2.3"
				//Busca informacoes do Parametro45 // ponto
				fCar_RAIS(@aInfRAIS, aFilEnv[nI],.T., substr(cAnoMes,1,4))
			EndIf

			//Busca informacoes da tabela S037
			If Len(aDdsX14) == 0
				fInssEmp(aFilEnv[nI],@aX14,.F.,cAnoMes)
			Else
				lExtS037 := .T.

				aX14 := aClone(aDdsX14)
				//"Empurrra" todos para baixo e adiciona a STRING "S119" ou "S120" -> Compatibilidade
				For nX := 1 To Len(aX14)
					If lPeriod //Caso use mês/ano, empurra somente 1
						aSize( aX14[nX], Len(aX14[nX])+1 )
						AIns( aX14[nX], 1 )
						aX14[nX,1] := cCodigo
					Else //Caso não use mês/ano, empurra 2 para ajustar
						//Ajusta o aCols com o mesmo resultado do fCarrTab
						aSize( aX14[nX], Len(aX14[nX])+2 )
						AIns( aX14[nX], 1 )
						aX14[nX,1] := cCodigo
						AIns( aX14[nX], 3 )
						aX14[nX,3] := "      " //Adiciona uma 'data vazia'
					EndIf
				Next
			EndIf

			//carrega dados de contratacao pessoa com deficiencia
			If( Len(aRegS119) == 0 )
				fCarrTab( @aTabS119, "S119",/*dDataRef*/,.T.,/*cAnoMes*/,/*lCarNew*/,aFilEnv[nI])
			Else
				lExtS119 := .T.

				aTabS119 := aClone(aRegS119)

				//"Empurrra" todos para baixo e adiciona a STRING "S119" ou "S120" -> Compatibilidade
				For nX := 1 To Len(aTabS119)
					If lPeriod //Caso use mês/ano, empurra somente 1
						aSize( aTabS119[nX], Len(aTabS119[nX])+1 )
						AIns( aTabS119[nX], 1 )
						aTabS119[nX,1] := cCodigo
					Else //Caso não use mês/ano, empurra 2 para ajustar
						//Ajusta o aCols com o mesmo resultado do fCarrTab
						aSize( aTabS119[nX], Len(aTabS119[nX])+2 )
						AIns( aTabS119[nX], 1 )
						aTabS119[nX,1] := cCodigo
						AIns( aTabS119[nX], 3 )
						aTabS119[nX,3] := "      " //Adiciona uma 'data vazia'
					EndIf
				Next
			EndIf

			//carrega as entidades de ensino dos tomadores
			If( Len(aRegS120) == 0 )
				fCarrTab( @aTabS120, "S120",/*dDataRef*/,.T.,/*cAnoMes*/,/*lCarNew*/,aFilEnv[nI])
			Else
				lExtS120 := .T.

				aTabS120 := aClone(aRegS120)

				For nX := 1 To Len(aTabS120)
					If lPeriod
						aSize( aTabS120[nX], Len(aTabS120[nX])+1 )
						AIns( aTabS120[nX], nCol )
						aTabS120[nX,1] := cCodigo
					Else
						aSize( aTabS120[nX], Len(aTabS120[nX])+2 )
						AIns( aTabS120[nX], 1 )
						aTabS120[nX,1] := cCodigo
						AIns( aTabS120[nX], 3 )
						aTabS120[nX,3] := "      "
					EndIf
				Next
			EndIf

			//Se for extemporâneo vindo da Manutenção de Tabelas
			//Se não possuir mes/ano, devemos ajustar o array contendo somente as alteraçoes
			If lExtemp
				aColsManut := aClone(aRegsManut)
				If !lPeriod
					For nManut := 1 to Len(aColsManut)
						aSize( aColsManut[nManut], Len(aColsManut[nManut])+1 )
						AIns( aColsManut[nManut], 3 )
						aColsManut[nManut,3] := "      "
					Next
				EndIf
			EndIf

			If ExistFunc("fChav119") .and. lExtS037
				nPos2 := 0
				nS137 := 0
				While nPos2 == 0 .And. nS137 <= 4
					nS137++
					nPos2 := Ascan(aX14,{|x| AllTrim(x[2]) + AllTrim(x[3]) == fChav119(nS137, .F., Alltrim(aFilEnv[nI]),Iif(lPeriod, AllTrim(cMesAnoP),"")) })
				EndDo

				If lExtS037 .And. nPos2 > 0
					For nX := 1 To Len(aColsManut)
						If fCompArray(aColsManut[nX],aX14[nPos2])
							lIgual := .T.
							Exit
						EndIf
					Next

					If !lIgual
						nPos2 := 0
					EndIf

					If nPos2 == 0
						Loop
					EndIf
				Elseif nPos2 == 0
					Loop
				EndIf
			EndIf

			If ExistFunc("fChav119")
				//Busca o registro da tabela S120
				nPos1 := 0
				nS120 := 0
				While nPos1 == 0 .And. nS120 <= 4
					nS120++
					nPos1 := Ascan(aTabS120,{|x| AllTrim(x[2]) + AllTrim(x[3]) + AllTrim(x[6]) == fChav119(nS120, .F., Alltrim(aFilEnv[nI]),Iif(lPeriod, AllTrim(cAnoMes),"")) })
				EndDo

				If lExtS120 .And. nPos1 > 0
					For nX := 1 To Len(aColsManut)
						If fCompArray(aColsManut[nX],aTabS120[nPos1])
							lIgual := .T.
							Exit
						EndIf
					Next

					If !lIgual
						nPos1 := 0
					EndIf

					If nPos1 == 0
						Loop
					EndIf
				EndIf
			Else
				nPos1	:= Ascan(aTabS120,{|x| x[2] == aFilEnv[nI] }) // registro da filial
			EndIf

			If Len(aEstEd) == 0  // so deve carregar uma vez este array
				If nPos1 > 0
					If (Alltrim(aTabS120[nPos1,2]) == Alltrim(aFilEnv[nI]) .Or. Empty(aTabS120[nPos1, 2]) ).And. Empty(aTabS120[nPos1,6])
						Aadd(aEstEd, {aTabS120[nPos1,7], aTabS120[nPos1,2]} )
					Endif
				EndIf
			EndIf

			//Busca somente o campo 30 (Sub Patronal) , que nao consta no fInssEmp.
			If cTpInscr == "4"
				If FpHist82(aFilEnv[nI],"14",RhTamFilial(aFilEnv[nI])+cAnoMes+Str(1,1)+"4" ) .Or.;
				FpHist82(aFilEnv[nI],"14",RhTamFilial(Space(FWGETTAMFILIAL))+cAnoMes+Str(1,1)+"4" ) .or.;
				Fphist82(aFilEnv[nI],"14",RhTamFilial(aFilEnv[nI])+ "      " +Str(1,1)+"4" ) .or. ;
				Fphist82(aFilEnv[nI],"14",RhTamFilial(Space(FWGETTAMFILIAL))+"      " +Str(1,1)+"4")
					cSub := IIf(SubStr(SRX->RX_TXT,49,01)=='3',"",SubStr(SRX->RX_TXT,49,01))
				EndIf
			EndIf

			If Len(aX14) > 0 .Or. Len(aDdsX14) > 0

				fCarrTab( @aTabS129, "S129",/*dDataRef*/,.T.,/*cAnoMes*/,/*lCarNew*/,aFilEnv[nI])
				If ExistFunc("fChav119")
					nS129 	:= 0
					nPos129	:= 0
					//Busca o registro da tabela S129
					While nPos129 == 0 .And. nS129 <= 8
						nS129++
						nPos129 := Ascan(aTabS129,{|x| AllTrim(x[2]) + AllTrim(x[3]) + AllTrim(x[5]) == fChav119(nS129, .F., alltrim(aFilEnv[nI]), AllTrim(cAnoMes)) })
					EndDo
				Else
					nPos := Ascan(aTabS129,{|x| alltrim(x[2])== alltrim(aFilEnv[nI])+"" })
					If nPos129 == 0
						nPos129	:= Ascan(aTabS129,{|x| alltrim(x[2]) == ""+"" })
					EndIf
				Endif

				If LEN(aTabS129) > 0 .And. nPos129 > 0
					lTabS129 := .T.
				Endif

				// Dados da Filial
				cNrPcd := cTpPcd := cTpReg := cTpApr := cNrApr := cTpEEn := cEmpMat := ""

				lEmpMatriz := .F.
				lFilMatriz := .F.

				If ExistFunc("fChav119")
					nS119 := 0
					nPos  := 0
					//Busca o registro da tabela S119
					While nPos == 0 .And. nS119 <= 8
						nS119++
						nPos := Ascan(aTabS119,{|x| AllTrim(x[2]) + AllTrim(x[3]) + AllTrim(x[8]) == fChav119(nS119, .F., alltrim(aFilEnv[nI]), Iif(lPeriod, AllTrim(cAnoMes),"")) })
					EndDo

					If lExtS119 .And. nPos > 0
						For nX := 1 To Len(aColsManut)

							//Ajustando o array com registros alterados

							If fCompArray(aColsManut[nX],aTabS119[nPos])
								lIgual := .T.
								Exit
							EndIf
						Next
						If !lIgual
							nPos := 0
						EndIf

						If nPos == 0
							Loop
						EndIf
					EndIf

					If nPos > 0
						cTpReg := AllTrim(aTabS119[nPos][9])
						cTpApr := aTabS119[nPos][10]
						cNrApr := aTabS119[nPos][11]
						cTpEEn := aTabS119[nPos][12]
						cTpPcd := aTabS119[nPos][6]
						cNrPcd := aTabS119[nPos][7]
						If Len(aTabS119[nPos]) >= 13
							cEmpMat:= IIF(ValType(aTabS119[nPos][13]) =="N",CValToChar(aTabS119[nPos][13]),aTabS119[nPos][13])// Empresa Matriz
						Endif
						If Len(aTabS119[nPos]) >= 14
							cCNPJR:= aTabS119[nPos][14] // CNPJ Responsavel
						Endif
					EndIf
				Else
					nPos	:= Ascan(aTabS119,{|x| alltrim(x[2])== alltrim(aFilEnv[nI])+"" })
					If nPos > 0
						cTpReg := AllTrim(aTabS119[nPos][9])
						cTpApr := aTabS119[nPos][10]
						cNrApr := aTabS119[nPos][11]
						cTpEEn := aTabS119[nPos][12]
						cTpPcd := aTabS119[nPos][6]
						cNrPcd := aTabS119[nPos][7]
						If Len(aTabS119[nPos]) >= 13
							cEmpMat:= aTabS119[nPos][13] // Empresa Matriz
						EndIf
					Else
						nPos1	:= Ascan(aTabS119,{|x| alltrim(x[2]) == ""+"" })
						If nPos1 > 0
							cTpReg := AllTrim(aTabS119[nPos1][9])
							cTpApr := aTabS119[nPos1][10]
							cNrApr := aTabS119[nPos1][11]
							cTpEEn := aTabS119[nPos1][12]
							cTpPcd := aTabS119[nPos1][6]
							cNrPcd := aTabS119[nPos1][7]
							If Len(aTabS119[nPos1]) >= 13
								cEmpMat:= aTabS119[nPos1][13] // Empresa Matriz
							EndIf
						EndIf
					EndIf
				EndIf

				//Se a filial que está sendo lida é a matriz, se sim verifica se foi preenchido o campo empresa matriz da tabela S119
				If nPos > 0 .Or. nPos1 > 0
					lEmpMatriz:= If(cFilEnv == aFilEnv[nI] .AND. lMatriz, If(cEmpMat == "2", .T., .F.),.F.)
					lFilMatriz:= If(cFilEnv <> aFilEnv[nI], If(cEmpMat == "1", .T., .F.),.F.)
					lTb119 := .T.
				Else
					lTb119 := .F.
				Endif

				If Len(aX14) > 0 .AND. !lExtS037
					nRAT     := aX14[29,1]*100
					cCodTerc := aX14[25,1]
					nPercAc  := aX14[3,1]*100
					nFAP 	 := nPercAc / (aX14[29,1]*100)
				ElseIf Len(aX14) > 0 .AND. lExtS037
					nRAT     := aX14[ nPos2, 8]
					cCodTerc := ""
					nPercAc  := aX14[ nPos2, 7]
					nFAP     := nPercAc / aX14[ nPos2, 8]
				EndIf

				If lTabS129 .And. (Empty(nRat) .Or. Empty(nPercAc) )
					nRat 	:= aTabS129[nPos129,6]
					nPercAc	:= aTabS129[nPos129,7]
					nFAP	:= nPercAc / (aTabS129[nPos129,6])
				EndIf

				cFPAS := alltrim(str(val(aInfoFil[17])))
				lPonto := If(cVersEnvio < "2.3", Empty(aInfRAIS[14]), !lNT15 .And. Empty(cTpReg))

				// tem que ter tipo e numero de inscricao, percetual acidente trabalho, CNAE, RAT, Contrata aprendiz e Informação de ponto
				If !(Empty(cTpInscr)) .AND. !(Empty(cInscric)) .AND. !(Empty(aInfoFil[16])) .AND. (lNT15 .Or. !lNT15 .And. !(Empty(cTpApr))) .AND. !lPonto .AND. !lEmpMatriz .AND. !lFilMatriz .AND. lTb119

					If !lMiddleware
						//Montando chave de pesquisa do evento no TAF
						cChave := cTpInscr + ";" + cInscric + ";" + cMesAnoP

						//Se for Extemporâneo ou Exclusão em Lote, consulta o Status
						If ( FunName() == "GPEA320" .And. lExtemp) .OR. nOpcAux == 5
							nOpcAux := fVerExtemp( "S-1005", cChave, nOpcAux, @cStatus, lContinua, cFilEnv, @aErros )

							//Se status 2 ou 4 -> Segue o fluxo | Se for diferente, aborta processo
							If nOpcAP == 5
								If ( cStatus $ " |1|3|-1" )
									Loop
								EndIf

								//Se for Extemporâneo, gera a mensagem auxiliar
							ElseIf FunName() == "GPEA320" .And. lExtemp
								If cStatus == "2"
									aAdd( aDados, PADR(OemToAnsi(STR0025), 25) + " " + PADR(OemToAnsi(STR0086) + " " + aFilEnv[nI], 77) + " " + If(lMiddleware,PADR(OemToAnsi(STR0261), 26),PADR(OemToAnsi(STR0029), 26)) )
									aAdd( aDados, aErros[1])
									aAdd( aDados, "")
									nContErr++
								EndIf
								aErros := {}
							EndIf
						EndIf
					Else
						aInfoC   := fXMLInfos()
						IF LEN(aInfoC) >= 4
							cTpInsc  := aInfoC[1]
							lAdmPubl := aInfoC[4]
							cNrInsc  := aInfoC[2]
						ELSE
							cTpInsc  := ""
							lAdmPubl := .F.
							cNrInsc  := "0"
						ENDIF

						aSM0	:= FWLoadSM0(.T.,,.T.)
						If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpAnt .And. X[18] == cNrInsc }) ) > 0
							cFilEmp := aSM0[nFilEmp, 2]
						Else
							cFilEmp := cFilAnt
						EndIf
						cChave := cTpInscr + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1005" + Padr(cFilEmp + cNrInsc, fTamRJEKey(), " ") + cAnoMes
						cStatus := "-1"
						GetInfRJE(2, cChave,@cStatus)

						IF cStatus $ "1|3|-1" .And. nOpcAP == 3
							nOpcAux := 3
						elseif cStatus $ "1|3|-1" .And. nOpcAP == 4
							nOpcAux := 4
						elseif nOpcAP == 5 .And. cStatus $ "1|3|-1"
							nOpcAux := 5
						elseif cStatus == "2"
							aErros := {STR0240}//"O registro está em trânsito para o RET. Esta alteração não poderá ser realizada enquanto o envio não for concluído")
							nOpcAux := 0
							lContinua := .F.
							aAdd( aDados, PADR(OemToAnsi(STR0025), 25) + " " + PADR(OemToAnsi(STR0086) + " " + aFilEnv[nI], 77) + " " + PADR(OemToAnsi(STR0245), 26) )
							aAdd( aDados, aErros[1])
							aAdd( aDados, "")
							nContErr++
						ElseIf nOpcAP == 1 .And. FunName() == "GPEA320" .And. lExtemp
							If cStatus $ "1|3|-1"
								nOpcAux := 3
							Elseif cStatus == "4"
								nOpcAux := 4
							EndIf
						ENDIF
						aErros := {}
					EndIf

					If lTemRJL .And. RJL->( dbSeek( xFilial("RJL", aFilEnv[nI])+aFilEnv[nI] ) )
						While RJL->( !EoF() ) .And. RJL->RJL_FILIAL+RJL->RJL_FIL == xFilial("RJL", aFilEnv[nI])+aFilEnv[nI]
							If Empty(RJL->RJL_CC) .And. SubStr(cMesAnoP,3,4)+SubStr(cMesAnoP,1,2) >= RJL->RJL_COMPET
								cTpProc		:= RJL->RJL_TPPROC
								cNrProc		:= RJL->RJL_NRPROC
								cCSusp		:= RJL->RJL_CSUSP
								cTp			:= RJL->RJL_TP
							EndIf
							RJL->( dbSkip() )
						EndDo
					EndIf

					Aadd(aEstObras, {	cTpInscr										, ; //1  - Tipo da inscrição da Obra/Estabelecimento
										cInscric										, ; //2  - Número da Inscrição da Obra/Estabelecimento
										cFPAS											, ; //3  - FPAS
										cCodTerc										, ; //4  - cod terceiro !
										aInfoFil[16]									, ; //5  - CNAE
										Round(nRAT, 0)									, ; //6  - RAT
										nPercAc											, ; //7  - Perc Acidente
										aFilEnv[nI]										, ; //8  - Codigo Filial
										cSub											, ; //9  - Sub Patronal
										nFAP											, ; //10 - FAP
										Iif(cVersEnvio >= '2.3', cTpReg ,aInfRAIS[14])	, ;	//11 - Tipo de Registro de Ponto
										cTpApr											, ; //12 - Contrata aprendiz
										cNrApr											, ; //13 - Numero de Processo
										cTpEEn											, ; //14 - Tipo de entidade educacional
										cTpPcd											, ; //15 - Tipo de PCD
										cNrPcd											, ; //16 - Processo PCD
										cMesAnoP										, ; //17 - MesAno de Processamento
										nOpcAux											, ; //18 - Armazena o nOpc do extemporâneo
										aEstEd											, ; //19 - Entidade Educativas da Filial
										cTpProc											, ; //20 - Tipo do Processo (1-Administrativo, 2-Judicial, 4-Processo FAP)
										cNrProc											, ; //21 - Número do Processo
										cCSusp											, ; //22 - Código do Indicativo da Suspensão
										cTp												, ; //23 - Tipo de contribuição (1-Proc RAT,2-Proc FAP)
										cCNPJR											} ) //24 - CNPJ Responsavel
				Else
					//Impressao
					If Empty(cMenIni)
						cMenIni := OemToAnsi(STR0060) //##"Inconsistências de Estabelecimento/Obra - Os campos abaixo estão vazios ou zerados e são de preenchimento obrigatórios:"

						aAdd(aLogProc, cMenIni)
						aAdd(aLogProc, "")
						aAdd(aLogProc, "")
					EndIf

					//Mensagem de log que sera gravado
					cMsgLog := OemToAnsi(STR0086) //##"Filial"

					//Mensagem de log
					cMsgLog += " " + aFilEnv[nI] + " - " + OemToAnsi(STR0125) + ": " //##"Preenchimento de campos obrigatórios"

					//Busca campos incosistentes
					fGp23InSM0(aLogProc, {cTpInscr,cInscric, /*aX14[3,1]*/,aInfoFil[16],/*nRAT*/,cTpApr,Iif(cVersEnvio >= "2.3",cTpReg, aInfRAIS[14]),aFilEnv[nI], lEmpMatriz, lFilMatriz, lTb119, aObrasF0F, aCAEPFF0F}, @cMsgLog,cVersEnvio)

					//------------------------------------------------------------------------------------------------------------------------------------
					//Estabelecimentos/Obras    XYZABC1230                                                                    Nâo Enviada ao TAF         "
					//Comentario do erro
					//
					//------------------------------------------------------------------------------------------------------------------------------------
					aAdd( aDados, iif(!lMiddleware, PADR(OemToAnsi(STR0025), 25) + " " + PADR(OemToAnsi(STR0086) + " " + aFilEnv[nI], 77) + " " + PADR(OemToAnsi(STR0029), 26), PADR(OemToAnsi(STR0025), 25) + " " + PADR(OemToAnsi(STR0086) + " " + aFilEnv[nI], 77) + " " + PADR(OemToAnsi(STR0261), 26)) )
					nContErr++

					nPosInco:= aScan(aLogProc, "Filial -> "+ aFilenv[nI])

					//Tratando looping para pegar somente os registros uteis e não as sujeiras
					For nX := nPosInco + 1 To Len(aLogProc)-1
						aAdd(aDados, aLogProc[nX] )
					Next
					nPosInco := 0
					//Pula linha para deixar esteticamente melhor
					aAdd(aDados, "" )
				EndIf

				If !IsBlind()
					//Incrementa regua
					IncProc(OemToAnsi(STR0069) + " " + aFilEnv[nI]+" - "+ cInscric) //##"Gerando o registro de: "
				EndIf
			EndIf
		Next nI

		If Len(aDdsX14) > 0 .And. !Empty(cMsgLog)
			aAdd( aDados, "" )
			aAdd( aDados, cMsgLog )
			aAdd( aDados, "" )

			//Tratamento para quebra de linha do log de ocorrências
			aResumo := {}
			aIncons := {}
			For nE := 1 to Len(aDados)
				aResumo := FWTxt2Array( aDados[nE], 131)
				For nR := 1 to Len(aResumo)
					Aadd(aIncons, aResumo[nR])
				Next nR
			Next nE

			aDados := {}

			For nE := 1 To Len(aIncons)
				Aadd( aDados, aIncons[nE] )
			Next nE

		EndIf

		//Carga do parametro 14 no TAF
		For nI := 1 To Len(aEstObras)
			lContinua:= .T.

			If FunName() $ "GPEA320"
				nOpcAux:= aEstObras[nI,18]
			EndIf

			If ( nOpcAP == 1 .OR. nOpcAP == 5) .and. nOpcAux > 0 //Evita gerar qualquer integração de registro em transito "2"

				Begin Transaction
					If lMiddleware
						cRetKey := cFilEnv+aEstObras[nI,1]+aEstObras[nI,2]+dToS( dDtGer )+StrTran( cHrGer,":","" )
						cKey    := cFilEnv+aEstObras[nI,2]
						aInfoC   := fXMLInfos()
						IF Len(aInfoC) >= 4
							cId  	 := aInfoC[3]
						Else
							cId  	 := ""
						EndIf
						aAdd( aDadosMID,{ cId,cRetKey,dDtGer,cHrGer, cTpInsc,cNrInsc, cKey, aEstobras[nI,2], Substr(cMesAnoP,3,4)+ Substr(cMesAnoP,1,2) } )
					Endif

					cXml := IIF(lMiddleware,"<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTabEstab/v" + cVersMW + "'>",'<eSocial>')
					cXml += IIF(lMiddleware, "	<evtTabEstab Id='" + cId + "'>" , '	<evtTabEstab>')
					IF lMiddleware
						fXMLIdEve( @cXml, { Nil, Nil, Nil, Nil, 1, 1, "12" } )
						fXMLIdEmp( @cXml, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
					ENDIF
					cXml += '		<infoEstab>'

					If nOpcAux == 3
						cXml += '		<inclusao>'
					ElseIf nOpcAux == 4
						cXml += '		<alteracao>'
					ElseIf nOpcAux == 5
						cXml += '		<exclusao>'
					EndIf

					cXml += '				<ideEstab>'
					cXml += '					<tpInsc>' + cValToChar( aEstObras[nI, 1] ) + '</tpInsc>'
					cXml += '					<nrInsc>' + aEstObras[nI, 2] + '</nrInsc>'
					cXml += '					<iniValid>' + substr(cMesAnoP,3,4) + "-" + substr(cMesAnoP,1,2) + '</iniValid>'
					if !lMIddleware
						cXml += '					<fimValid>' + '' + '</fimValid>'
					ENDIF
					cXml += '				</ideEstab>'

					If nOpcAux <> 5
						cXml += '			<dadosEstab>'
						cXml += '				<cnaePrep>' + aEstObras[nI, 5] 		+ '</cnaePrep>'
						If cVersEnvio >= "9.0.00" .And. cValToChar( aEstObras[nI, 1] ) == "4" .And. (Substr(cMesAnoP,3,4) + Substr(cMesAnoP,1,2)) >= "202204"
							cXml += '				<cnpjResp>' + Alltrim(aEstObras[nI, 24]) 		+ '</cnpjResp>'
						Endif
						If cVersEnvio < "9.0.00"
							cXml += '				<aliqGilrat>'
							cXml += '					<aliqRat>' + AllTrim(Str(aEstObras[nI, 6])) + '</aliqRat>'

							If cValToChar( aEstObras[nI, 1] ) == "1" //Só gerar a TAG <fap> se o tipo de inscrição do estabelecimento for pessoa jurídica
								cXml += '				<fap>' + StrTran(Transform(NoRound(aEstObras[nI, 10], 4), "@E 9.9999"), ",", ".") + '</fap>'
								cXml += '				<aliqRatAjust>' + StrTran(Transform(aEstObras[nI, 7], "@E 9.9999"), ",", ".") + '</aliqRatAjust>'
							Endif

							If aEstObras[nI, 23] == "1"
								cXml += '					<procAdmJudRat>'
								cXml += '						<tpProc>' + AllTrim(aEstObras[nI, 20]) + '</tpProc>'
								cXml += '						<nrProc>' + AllTrim(aEstObras[nI, 21]) + '</nrProc>'
								cXml += '						<codSusp>' + AllTrim(aEstObras[nI, 22]) + '</codSusp>'
								cXml += '					</procAdmJudRat>'
							EndIf
							If aEstObras[nI, 23] == "2"
								cXml += '					<procAdmJudFap>'
								cXml += '						<tpProc>' + AllTrim(aEstObras[nI, 20]) + '</tpProc>'
								cXml += '						<nrProc>' + AllTrim(aEstObras[nI, 21]) + '</nrProc>'
								cXml += '						<codSusp>' + AllTrim(aEstObras[nI, 22]) + '</codSusp>'
								cXml += '					</procAdmJudFap>'
							EndIf
							cXml += '				</aliqGilrat>'
						ElseIf cVersEnvio >= "9.0.00" .And. !Empty(aEstObras[nI, 23])
							cXml += '				<aliqGilrat>'
							If aEstObras[nI, 23] == "1"
								cXml += '					<aliqRat>' + AllTrim(Str(aEstObras[nI, 6])) + '</aliqRat>'
							EndIf

							If cValToChar(aEstObras[nI, 1]) == "4" .And. aEstObras[nI, 23] == "2"
								If ((Substr(cMesAnoP,3,4)+Substr(cMesAnoP,1,2)) >= "202204" .And. !Empty(aEstObras[nI, 24]) ) .Or. (Empty(aEstObras[nI, 24]) .And.;
									(Substr(cMesAnoP,3,4)+Substr(cMesAnoP,1,2) < "202204" ))
										cXml += '				<fap>' + StrTran(Transform(NoRound(aEstObras[nI, 10], 4), "@E 9.9999"), ",", ".") + '</fap>'
								Endif
							ElseIf cValToChar( aEstObras[nI, 1] ) == "1" .And. aEstObras[nI, 23] == "2"      //Só gerar a TAG <fap> se o tipo de inscrição do estabelecimento for pessoa jurídica e CNPJR Não preenchido
								cXml += '				<fap>' + StrTran(Transform(NoRound(aEstObras[nI, 10], 4), "@E 9.9999"), ",", ".") + '</fap>'
							Endif
							If aEstObras[nI, 23] == "1"
								cXml += '					<procAdmJudRat>'
								cXml += '						<tpProc>' + AllTrim(aEstObras[nI, 20]) + '</tpProc>'
								cXml += '						<nrProc>' + AllTrim(aEstObras[nI, 21]) + '</nrProc>'
								cXml += '						<codSusp>' + AllTrim(aEstObras[nI, 22]) + '</codSusp>'
								cXml += '					</procAdmJudRat>'
							EndIf
							If aEstObras[nI, 23] == "2"
								cXml += '					<procAdmJudFap>'
								cXml += '						<tpProc>' + AllTrim(aEstObras[nI, 20]) + '</tpProc>'
								cXml += '						<nrProc>' + AllTrim(aEstObras[nI, 21]) + '</nrProc>'
								cXml += '						<codSusp>' + AllTrim(aEstObras[nI, 22]) + '</codSusp>'
								cXml += '					</procAdmJudFap>'
							EndIf
							cXml += '				</aliqGilrat>'
						EndIf

						//Informando se é um "1-Contribuinte Individual" ou "2-Produtor Rural"
						If ( cValToChar( aEstObras[nI, 1] ) == "3" )
							tpCaepf := IIf(ValType(aCAEPFF0F) == "A", aCAEPFF0F[3], "2")
							cXml += '			<infoCaepf>'
							cXml += '				<tpCaepf>' + tpCaepf + '</tpCaepf>'
							cXml += '			</infoCaepf>'
						Endif

						If !Empty(aEstObras[nI, 1]) .And. aEstObras[nI, 1] == "4"
							cXml += '			<infoObra>'
							cXml += '				<indSubstPatrObra>' + If(!Empty(aEstObras[nI, 9]),aEstObras[nI, 9],'2') + '</indSubstPatrObra>'
							cXml += '			</infoObra>'
						Endif

						If !lNT15 .Or. (!Empty(aEstObras[nI, 11]) .Or. !Empty(aEstObras[nI, 12]) .Or. !Empty(aEstObras[nI, 15]) ) .Or.;
						(cVersEnvio >= "9.0.00" .And. (!empty(aEstObras[nI, 13]) .Or. !empty(aEstObras[nI, 16])))  //Na versão S-1.0 (9.0.00) somente o processo
							cXml += '				<infoTrab>'
							If cVersEnvio < "9.0.00" .And. (!lNT15 .Or. !Empty(aEstObras[nI, 11]))
								cXml += '					<regPt>'+ aEstObras[nI, 11] + '</regPt>'
							EndIf
							If !lNT15 .Or. !Empty(aEstObras[nI, 12]) .Or. (cVersEnvio >= "9.0.00" .And. (!empty(aEstObras[nI, 13]) .Or. !empty(aEstObras[nI, 16])))
								cXml += '					<infoApr>'
								If cVersEnvio < "9.0.00"
									cXml += '						<contApr>' + cValToChar( aEstObras[nI, 12] ) + '</contApr>'
								EndIf
								if !empty(aEstObras[nI, 13])
									cXml += '						<nrProcJud>' + AllTrim( cValToChar( aEstObras[nI, 13] ) ) + '</nrProcJud>'
								Endif

								If !lNT15 .Or. aEstObras[nI, 12] != "0" .And. !Empty(aEstObras[nI, 14]) .And. cVersEnvio < "9.0.00"
									cXml += '					<contEntEd>' + Iif(aEstObras[nI, 14] == "1", 'S', 'N') + '</contEntEd>'
								EndIf

								//Entidade Educativa
								If Val(aEstObras[nI, 14]) == 1 .Or. cVersEnvio >= "9.0.00"
									aAreaRA0 := GetArea()
									lEntEduc	:= .F.

									For z1 := 1 to len(aEstObras[nI,19]) //aEstEd -> Ent Educ para esta filial
										dbSelectArea("RA0")
										RA0->(DbSetOrder(1))

										If RA0->(MsSeek(FwxFilial("RA0",aEstObras[nI, 8]) + aEstObras[nI,19,1,1])) .And. ( aEstObras[nI, 8] == aEstObras[nI,19,1,2] .Or. Empty(aEstObras[nI,19,1,2]) )
											If !Empty(RA0->RA0_CGC)
												cXml += '		<infoEntEduc><nrInsc>' + RA0->RA0_CGC + '</nrInsc></infoEntEduc>'
											ElseIf !lNT15
												aAdd( aErros, StrTran(OemToAnsi(STR0215),"(#)","("+aEstEd[z1,1]+")"))
												lContinua:= .F.
											EndIf
										ElseIf !lEntEduc
											if !lMIddleware .And. !lNT15
												cXml += '			<infoEntEduc></infoEntEduc>'
											ENDIF
											lEntEduc := .T.
										Endif
									Next z1
									RestArea(aAreaRA0)
								Endif
								cXml += '					</infoApr>'
							EndIf
							if !(Empty( aEstObras[nI, 15] )) .Or. (cVersEnvio >= "9.0.00" .And. !empty(aEstObras[nI, 16]))
								cXml += '					<infoPCD>'
								If cVersEnvio < "9.0.00"
									cXml += '					<contPCD>' + cValToChar( aEstObras[nI, 15] )	+ '</contPCD>'
								EndIf
								if !empty(aEstObras[nI, 16])
									cXml += '					<nrProcJud>' + AllTrim( cValToChar( aEstObras[nI, 16] ) ) 	+ '</nrProcJud>'
								endif

								cXml += '					</infoPCD>'
							Else
								if !lMIddleware .And. !lNT15
									cXml += '					<infoPCD>'
									If cVersEnvio < "9.0.00"
										cXml += '					<contPCD></contPCD>'
									EndIf
									cXml += '					<nrProcJud></nrProcJud>'
									cXml += '					</infoPCD>'
								ENDIF
							Endif

							cXml += '				</infoTrab>'
						EndIf
						cXml += '			</dadosEstab>'
					EndIf

					If nOpcAux == 3
						cXml += '		</inclusao>'
					ElseIf  nOpcAux == 4
						cXml += '		</alteracao>'
					ElseIf  nOpcAux == 5
						cXml += '		</exclusao>'
					Endif

					cXml += '		</infoEstab>'
					cXml += '	</evtTabEstab>'
					cXml += '</eSocial>'

					If lContinua
						If !lMiddleware
							//Enviar como parametro a filial do Protheus na posição 1 e o XML na posição 2
							aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S1005")
							GrvTxtArq(cXml, "S1005") // Geração do XML na System (Mediante o MV_XMLGPE)
						Else
							cFunc := "X14"
							fGerarRJE(aEstObras, cMesAnoP, aEstEd, aErros, cFilEnv, nOpcAux, cXml, lContinua, aDadosMID,cFunc)
							GrvTxtArq(cXml, "S1005") // Geração do XML na System (Mediante o MV_XMLGPE)
						EndIf

					EndIf

					If Len( aErros ) <= 0
						//--------------------------------------------------------------
						//| Os erros serão impressos alinhados | Tamanho cabecalho: 132
						//| Colunas: Eventos (25+1) | Item/Registro (77+1) | Status (26)
						//| PADR("Eventos", 25) + " " + PADR("ITEM/REGISTRO", 77) + " " + PADR("STATUS", 26))
						//------------------------------------------------------------------------------------------------------------------------------------
						//Estabelecimentos/Obras    XYZABC1230                                                                    Enviada ao TAF com sucesso."
						If( Empty( aEstObras[nI ,8] ) )
							aAdd( aDados, iif(!lMiddleware, PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI, 2], 77) + " " + PADR(OemToAnsi(STR0030), 26),PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI, 2], 77) + " " + PADR(OemToAnsi(STR0255), 26)) )  //Enviado ao Middleware com sucesso
						Else
							aAdd( aDados, iif(!lMiddleware, PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI ,8] + " - " + aEstObras[nI, 2], 77) + " " + PADR(OemToAnsi(STR0030), 26), PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI ,8] + " - " + aEstObras[nI, 2], 77) + " " + PADR(OemToAnsi(STR0255), 26)) )
						EndIf

						//Se o percentual RAT ou Acidente de trabalho estiverem vazios, permite a carga mas avisa.
						If aEstObras[nI, 6] == 0 .Or. aEstObras[nI,7] == 0
							aAdd( aDados, "" )
							aAdd( aDados,  SUBSTR(OemToAnsi(STR0060),43,76) ) // Os campos abaixo estão vazios ou zerados e são de preenchimento obrigatório:

							//Campo percentual Acidente de Trabalho Zerado
							If aEstObras[nI, 7] == 0
								aAdd(aDados,   OemToAnsi(STR0155) + " - " + OemToAnsi(STR0137)) // Tabela S037 Percentual Acidente de Trabalho
							EndIf

							//Campo percentual RAT zerado
							If aEstObras[nI, 6] == 0
								aAdd(aDados,   OemToAnsi(STR0155) + " - " + OemToAnsi(STR0136)) // Tabela S037 % RAT
							EndIf

							aAdd( aDados,  OemToAnsi(STR0214) ) // A menos que exista um processo permitindo os valores zerados para esse(s) campo(s), por este motivo a carga será realizada .
							aAdd( aDados, "" )
						Endif

						nContador++

					ElseIf Len( aErros ) > 0
						//Varrendo array de erro para envio de msg para log
						cResumo	:= ""
						for nCont:= 1 to len(aErros)
							cResumo += aErros[nCont]
						next

						aResumo := FWTxt2Array( cResumo, 125)

						//------------------------------------------------------------------------------------------------------------------------------------
						//Estabelecimentos/Obras    XYZABC1230                                                                    Nâo Enviada ao TAF         "
						//Comentario do erro
						//
						//------------------------------------------------------------------------------------------------------------------------------------
						If( Empty( aEstObras[nI ,8] ) )
							aAdd( aDados, iif(!lMiddleware, PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI, 2] + " " + OemToAnsi(STR0032), 77) + " " + PADR(OemToAnsi(STR0029), 26), PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI, 2] + " " + OemToAnsi(STR0263), 77) + " " + PADR(OemToAnsi(STR0261), 26)) )
						Else
							aAdd( aDados, iif(!lMiddleware, PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI ,8] + " - " + aEstObras[nI, 2] + " " + OemToAnsi(STR0032), 77) + " " + PADR(OemToAnsi(STR0029), 26), PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI ,8] + " - " + aEstObras[nI, 2] + " " + OemToAnsi(STR0263), 77) + " " + PADR(OemToAnsi(STR0261), 26)) )
						EndIf

						For nCont := 1 To Len(aResumo)
							AaDD( aDados, aResumo[nCont] )
						Next

						AaDD( aDados, "" )
						nContErr++
					EndIf

					If !lWorkFlow
						//Incrementa regua
						IncProc(OemToAnsi(STR0069) + " " + aEstObras[nI, 2]) //##"Gerando o registro de: "
					EndIf
				End Transaction
			EndIf
		Next nI
	EndIf

	RestArea(aArea)

	//----------------------
	//| Monta rodapé de LOG
	//----------------------
	If nOpcAP == 1 .AND. (!lExtemp) .OR. (Len(aEstObras) > 0 .and. Len(aDados) > 1)
		aAdd(aDados,"")
		aAdd(aDados,(OemToAnsi(STR0111)+" "+ OemToAnsi(STR0110) + " " + OemToAnsi(STR0025) ))	//"Resumo" ###"Carga Inicial" Estabelecimento/Obra
		aAdd(aDados, OemToAnsi(STR0009)+": " +  SecsToTime(nHrInicio))							//Inicio Processamento: A
		nHrFim 	:= SecsToTime(Seconds())
		aAdd(aDados,+OemToAnsi(STR0010)+":    " + nHrFim)											//Fim Processamento:    A
		aAdd(aDados,"")
		aAdd(aDados,OemToAnsi(STR0077)+": " + SecsToTime(Seconds() - nHrInicio))		//Duracao do Processamento
		aAdd(aDados,Iif(lMiddleware,OemToAnsi(STR0243)+": "+ ALLTRIM(STR(nContador)),OemToAnsi(STR0078)+": "+ ALLTRIM(STR(nContador))))						//Quantidade Registro(s) enviado(s) ao TAF
		aAdd(aDados,Iif(lMiddleware,OemToAnsi(STR0244)+": "+ ALLTRIM(STR(nContErr)),OemToAnsi(STR0151)+": "+ ALLTRIM(STR(nContErr))))						//Quantidade Registros Não Enviados ao TAF
		aAdd(aDados,"")
		aAdd(aDados,"")
	EndIf

Return()
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fObraCTT  ³ Autor ³ Glaucia Messina       ³ Data ³11/06/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza carga das tabelas de Obras para o TAF via CTT       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fObraCTT()                                            	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023						                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fObraCTT(cMesAno, nOpcA, aLogProc, aDados, aFilInTaf, dDataRef, cVersEnvio, aDdsX14, nOpcAux, aRegsManut, aRegS119, aRegS120, cFilRCC, lPeriod, cCodigo, cFiltro)

	//Váriáveis Strings
	Local cMenIni		:= ""
	Local cCnae			:= ""
	Local cMsgLog		:= ""
	Local cSubPat		:= ""
	Local cXml			:= ""
	Local cLayout		:= ""
	Local cFilEnv		:= ""
	Local cQryWhere		:= "%"
	Local cMesAnoP 		:= ""
	Local cTpReg 		:= ""
	Local cTpApr 		:= ""
	Local cNrApr 		:= ""
	Local cTpEEn 		:= ""
	Local cAnoMes    	:= AnoMes(dDataRef)
	Local cResumo		:= ""

	//Variáveis numéricas
	Local nI          	:= 0
	Local z1 			:= 0
	Local nOpcAP 		:= 1
	Local nPos  		:= 0
	Local nPos1 		:= 0
	Local nS119			:= 0
	Local nS129 		:= 0
	Local nPos129 		:= 0

	//Váriaveis Lógicas
	Local lSemFilial 	:= .F.
	Local lAchou		:= .F.
	Local lContinua		:= .T.
	Local lConsolid		:= .T.
	Local lTabS129		:= .F.

	//Váriaveis de Data
	Local dDataRef

	//Alias/Arrays/Structs
	Local cAliasCTT  	:= GetNextAlias()
	Local aFilEnv		:= {}
	Local aResumo		:= {}
	Local aLogCNPJ    	:= {}
	Local aInfoFil    	:= {}
	Local aEstObras   	:= {}
	Local aErros		:= {}
	Local aArrayP 		:= {}
	Local aTabS119		:= {}
	Local aTabS120		:= {}
	Local aTabS129		:= {}
	Local aEstEd		:= {}
	Local aArea		 	:= GetArea()
	Local aAreaCTT  	:= CTT->(GetArea())
	Local aAreaRA0
	Local nCont         := 0
	Local nContErr		:= 0
	Local nContador		:= 0
	Local nValor		:= 0
	Local aArrayFilP	:= {}
	Local nOpcao        := 0
	Local lExtemp       := .F.
	Local lExtS119      := .F.
	Local lExtS120      := .F.
	Local cChave        := ""
	Local cStatus       := ""
	Local aErros        := {}
	Local nX            := 1
	Local lIgual		:= .F.
	Local nManut		:= 0
	Local lContinua		:= .T.
	Local aColsManut	:= {}
	Local lExtS037		:= .F.
	Local nPos2 		:= 0
	Local nS137 		:= 0
	Local aX14			:= {}
	Local lRccCompart	:= .F.
	Local lNT15			:= .F.
	Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
	Local cTpProc		:= ""
	Local cNrProc		:= ""
	Local cCSusp		:= ""
	Local cTp			:= ""
	Local lExstRJL		:= CHKFILE("RJL") // Se existe a tabela RJL
	Local cCompet		:= ""
	Local cCNPJR		:= ""

	default cMesAno		:= ""
	default nOpcA		:= 1
	default aFilInTaf	:= {}
	Default cVersEnvio	:= "2.2"
	Default aRegsManut  := {}
	Default aRegS119	:= {}
	Default aRegS120 	:= {}
	Default cFilRCC		:= xFilial("RCC")
	Default lPeriod     := .F.
	Default aDdsX14 	:= {}
	Default cCodigo		:= ""
	Default nOpcAux		:= 3
	Default cFiltro		:= ""

	//Se for exclusão em Lote
	If nOpcA == 5
		nOpcAux := 5
	EndIf

	nOpcao := nOpcAux

	cMesAnoP	:= cMesAno
	nOpcAP		:= nOpcA
	aArrayFilP	:= aFilInTaf
	cCompet		:= SubStr(cMesAnoP, 3, 4) + SubStr(cMesAnoP, 1, 2)

	cFilEnv		:= aArrayFilP[2]
	lConsolid	:= aArrayFilP[1]
	aFilEnv		:= aArrayFilP[3]

	If( Len(aRegS119) > 0 ) .OR. ( Len(aRegS120) > 0 ) .OR. ( Len(aDdsX14) )
		lExtemp := .T.
	EndIf

	If Empty(xFilial("RCC"))
		lRccCompart := .T.
	EndIf

	//Tratamento de compartilhamento da tabela CTT
	If FWModeAccess("CTT", 1) == "C" .AND. FWModeAccess("CTT", 2) == "C" .AND. FWModeAccess("CTT", 3) == "C" //CTT compartilhada
		lSemFilial := .T.
	EndIf

	//Monta variavel dDataRef da data de competencia em aberto p/ busca do fCarrTab
	dDataRef := cToD( "01/" + SubStr( cMesAnoP, 1, 2 ) + "/" + SubStr( cMesAnoP, 3, 4 ) )

	//Limpa variaveis
	cInscric := ""
	cTpInscr := ""

	fVersEsoc( "S1005", .F., Nil, Nil, Nil, Nil, Nil, @lNT15 )

	//Busca informacoes da tabela S037
	If Len(aDdsX14) > 0
		lExtS037 := .T.

		aX14 := aClone(aDdsX14)
		//"Empurrra" todos para baixo e adiciona a STRING "S119" ou "S120" -> Compatibilidade
		For nX := 1 To Len(aX14)
			If lPeriod //Caso use mês/ano, empurra somente 1
				aSize( aX14[nX], Len(aX14[nX])+1 )
				AIns( aX14[nX], 1 )
				aX14[nX,1] := cCodigo
			Else //Caso não use mês/ano, empurra 2 para ajustar
				//Ajusta o aCols com o mesmo resultado do fCarrTab
				aSize( aX14[nX], Len(aX14[nX])+2 )
				AIns( aX14[nX], 1 )
				aX14[nX,1] := cCodigo
				AIns( aX14[nX], 3 )
				aX14[nX,3] := "      " //Adiciona uma 'data vazia'
			EndIf
		Next
	EndIf

	//carrega a tabela S129 - Encargos
	fCarrTab( @aTabS129, "S129",/*dDataRef*/,.T.,/*cAnoMes*/,/*lCarNew*/,cFilEnv)

	//carrega dados de contratacao pessoa com deficiencia
	If( Len(aRegS119) == 0 )
		fCarrTab( @aTabS119, "S119",/*dDataRef*/,.T.,/*cAnoMes*/,/*lCarNew*/,cFilEnv)
	Else
		lExtS119 := .T.

		aTabS119 := aClone(aRegS119)

		//"Empurrra" todos para baixo e adiciona a STRING "S119" ou "S120" -> Compatibilidade
		For nX := 1 To Len(aTabS119)
			If lPeriod //Caso use mês/ano, empurra somente 1
				aSize( aTabS119[nX], Len(aTabS119[nX])+1 )
				AIns( aTabS119[nX], 1 )
				aTabS119[nX,1] := "S119"
			Else //Caso não use mês/ano, empurra 2 para ajustar
				//Ajusta o aCols com o mesmo resultado do fCarrTab
				aSize( aTabS119[nX], Len(aTabS119[nX])+2 )
				AIns( aTabS119[nX], 1 )
				aTabS119[nX,1] := "S119"
				AIns( aTabS119[nX], 3 )
				aTabS119[nX,3] := "      " //Adiciona uma 'data vazia'
			EndIf
		Next
	EndIf

	//carrega as entidades de ensino dos tomadores
	If( Len(aRegS120) == 0 )
		fCarrTab( @aTabS120, "S120",/*dDataRef*/,.T.,/*cAnoMes*/,/*lCarNew*/,cFilEnv)
	Else
		lExtS120 := .T.

		aTabS120 := aClone(aRegS120)

		For nX := 1 To Len(aTabS120)
			If lPeriod
				aSize( aTabS120[nX], Len(aTabS120[nX])+1 )
				AIns( aTabS120[nX], nCol )
				aTabS120[nX,1] := "S120"
			Else
				aSize( aTabS120[nX], Len(aTabS120[nX])+2 )
				AIns( aTabS120[nX], 1 )
				aTabS120[nX,1] := "S120"
				AIns( aTabS120[nX], 3 )
				aTabS120[nX,3] := "      "
			EndIf
		Next
	EndIf

	//Se for extemporâneo vindo da Manutenção de Tabelas
	//Se não possuir mes/ano, devemos ajustar o array contendo somente as alteraçoes
	If lExtemp
		aColsManut := aClone(aRegsManut)
		If !lPeriod
			For nManut := 1 to Len(aColsManut)
				aSize( aColsManut[nManut], Len(aColsManut[nManut])+1 )
				AIns( aColsManut[nManut], 3 )
				aColsManut[nManut,3] := "      "
			Next
		EndIf
	EndIf

	cQryWhere:= "%(CTT_FILIAL in " + fTratWre(aArrayFilP,"CTT") + ")%"

	if FunName() == "GPEA320" .AND. cCodigo $ "S037|S038"

		cQryWhere := StrTran(cQryWhere,"%","")
		cQryWhere:= "%"+cQryWhere+ " and (CTT_PERCAC = 0 AND CTT_PERRAT = 0)%"

	endif

	If !Empty(cFiltro)
		cQryWhere 	:= StrTran(cQryWhere,"%","")
		cQryWhere 	:= "%"+cQryWhere+ " AND " + GPEParSQL(fPrepExpIn(cFiltro)) + "%"
	EndIf

	nHrInicio := Seconds()

	#IFDEF TOP
	If lExstRJL
		BeginSql alias cAliasCTT
			SELECT
			CTT_FILIAL, CTT_TIPO2, CTT_CEI2, CTT_FPAS, CTT_CODTER, CTT_CNAE, CTT_PERRAT, CTT_FAP, CTT_PERCAC, CTT_CUSTO, CTT_TPLOT, CTT_ICTPAT, CTT_CLASSE,
			ISNULL(RJL_TPPROC, '') AS RJL_TPPROC, ISNULL(RJL_NRPROC, '') AS RJL_NRPROC, ISNULL(RJL_CSUSP, '') AS RJL_CSUSP, ISNULL(RJL_TP, '') AS RJL_TP
			FROM %table:CTT% CTT
			LEFT JOIN (SELECT RJL_FIL, RJL_CC, RJL_TPPROC, RJL_NRPROC, RJL_CSUSP, RJL_TP, D_E_L_E_T_
			FROM %table:RJL% RJL INNER JOIN(SELECT RJL_CC AS CC, MAX(RJL_COMPET) AS RJL_COMPET FROM %table:RJL% WHERE RJL_COMPET <=  %exp:cCompet% GROUP BY RJL_CC) RECENTES
			ON RJL.RJL_CC = RECENTES.CC AND RJL.RJL_COMPET = RECENTES.RJL_COMPET) RJL
			ON CTT.CTT_FILIAL = RJL.RJL_FIL AND CTT_CUSTO = RJL.RJL_CC AND RJL.D_E_L_E_T_ = ' '
			WHERE CTT.%notDel% AND %exp:cQryWhere%
			ORDER BY CTT.CTT_FILIAL, CTT.CTT_CUSTO
		EndSql
	Else
		BeginSql alias cAliasCTT
			SELECT
			CTT_FILIAL, CTT_TIPO2, CTT_CEI2, CTT_FPAS, CTT_CODTER, CTT_CNAE, CTT_PERRAT, CTT_FAP,
			CTT_PERCAC, CTT_CUSTO, CTT_TPLOT, CTT_ICTPAT, CTT_CLASSE
			FROM %table:CTT% CTT
			WHERE CTT.%notDel% AND %exp:cQryWhere%
			ORDER BY CTT.CTT_FILIAL, CTT.CTT_CUSTO
		EndSql
	EndIf

	dbSelectArea(cAliasCTT)
	#ELSE
	cAliasCTT := "CTT"
	dbSelectArea(cAliasCTT)
	#ENDIF

	(cAliasCTT)->(dbGoTop()) //Posiciona no inicio do arquivo
	aEstObras := {}

	While (cAliasCTT)->(!EOF())
		lIgual 		:= .F.
		aEstEd		:= {}
		lTabS129 	:= .F.
		cTpProc		:= Iif(lExstRJL, Alltrim((cAliasCTT)->RJL_TPPROC), "")
		cNrProc		:= Iif(lExstRJL, Alltrim((cAliasCTT)->RJL_NRPROC), "")
		cCSusp		:= Iif(lExstRJL, Alltrim((cAliasCTT)->RJL_CSUSP), "")
		cTp			:= Iif(lExstRJL, Alltrim((cAliasCTT)->RJL_TP), "")

		//Verifica a filial da tabela RCC logada e se for a mesma da filial que esta sendo enviada
		//o fluxo segue, se não volta para o topo
		If lExtemp .and. !lRccCompart
			If !AllTrim(xFilial("RCC", cFilEnv)) $ Alltrim(cFilRCC)
				(cAliasCTT)->(dbSkip())
				Loop
			EndIf
		EndIf

		//Reseta valor para o padrão da tela
		nOpcAux := nOpcao

		If lSemFilial //Compartilhada
			lContinua := .T.
		ElseIf aScan(aArrayFilP[3], {|X| FwxFilial("CTT", X) == (cAliasCTT)->CTT_FILIAL}) > 0 //Exclusiva
			lContinua := .T.
		Else
			lContinua := .F.
		EndIf

		If  lContinua .AND. (cAliasCTT)->CTT_TPLOT 	== "01" .And.;
		(cAliasCTT)->CTT_TIPO2	== "4" 	.And.;
		(cAliasCTT)->CTT_CLASSE == "2"

			If ExistFunc("fChav119") .and. lExtS037
				nPos2 := 0
				nS137 := 0
				While nPos2 == 0 .And. nS137 <= 4
					nS137++
					nPos2 := Ascan(aX14,{|x| AllTrim(x[2]) + AllTrim(x[3]) == fChav119(nS137, .T., Alltrim(cFilEnv),Iif(lPeriod, AllTrim(cMesAnoP),"")) })
				EndDo

				If lExtS037 .And. nPos2 > 0
					For nX := 1 To Len(aColsManut)
						If fCompArray(aColsManut[nX],aX14[nPos2])
							lIgual := .T.
							Exit
						EndIf
					Next

					If !lIgual
						nPos2 := 0
					EndIf

					If nPos2 == 0
						(cAliasCTT)->(dbSkip())
						Loop
					EndIf
				Elseif nPos2 == 0
					(cAliasCTT)->(dbSkip())
					Loop
				EndIf
			EndIf

			If ExistFunc("fChav119")
				nS120 := 0
				nPos1 := 0
				//Busca o registro da tabela S120
				While nPos1 == 0 .And. nS120 <= 8
					nS120++
					nPos1 := Ascan(aTabS120,{|x| If(lSemFilial,AllTrim(x[2]),AllTrim(xFilial("CTT",x[2])))+ AllTrim(x[3])+ AllTrim(x[6])== fChav119(nS120, .T., If(lSemFilial, Alltrim(cFilEnv), AllTrim((cAliasCTT)->CTT_FILIAL)), AllTrim(cAnoMes), AllTrim((cAliasCTT)->CTT_CUSTO)) })
				EndDo

				If lExtS120 .and. nPos1 > 0
					For nX := 1 To Len(aColsManut)
						If fCompArray(aColsManut[nX],aTabS120[nPos1])
							lIgual := .T.
							Exit
						EndIf
					Next

					If !lIgual
						nPos1 := 0
					EndIf

					If nPos1 == 0
						(cAliasCTT)->(dbSkip())
						Loop
					EndIf
				EndIf
			Else
				// alimenta a tabela S120
				If lSemFilial
					nPos1	:= Ascan(aTabS120,{|x| ALLTRIM(x[6]) == ALLTRIM((cAliasCTT)->CTT_CUSTO) })
				Else
					nPos1	:= Ascan(aTabS120,{|x| AllTrim(xFilial("CTT",x[2]))+ ALLTRIM(x[6]) == alltrim((cAliasCTT)->CTT_FILIAL) + ALLTRIM((cAliasCTT)->CTT_CUSTO) })
				EndIf
			EndIf

			If Len(aEstEd) == 0  // so deve carregar uma vez este array
				If nPos1 > 0
					If Alltrim(aTabS120[nPos1,6]) == Alltrim((cAliasCTT)->CTT_CUSTO)
						Aadd(aEstEd, {aTabS120[nPos1,6], aTabS120[nPos1,7]})
					Endif
				EndIf
			EndIf

			//Procura dados na tabela S119
			cTpReg :=  cTpApr := cNrApr := cTpEEn := ""

			If ExistFunc("fChav119")
				nPos := 0
				nS119:= 0
				//Busca o registro da tabela S119
				While nPos == 0 .And. nS119 <= 8
					nS119++
					nPos := Ascan(aTabS119, {|x| If(lSemFilial,AllTrim(x[2]),AllTrim(xFilial("CTT",x[2])))+ AllTrim(x[3])+ AllTrim(x[8]) == fChav119(nS119, .T., If(lSemFilial, Alltrim(cFilEnv), AllTrim((cAliasCTT)->CTT_FILIAL)), AllTrim(cAnoMes), AllTrim((cAliasCTT)->CTT_CUSTO))})
				EndDo

				If lExtS119 .AND. nPos > 0
					For nX := 1 To Len(aColsManut)
						If fCompArray(aColsManut[nX],aTabS119[nPos])
							lIgual := .T.
							Exit
						EndIf
					Next

					If !lIgual
						nPos := 0
					EndIf

					If nPos == 0
						(cAliasCTT)->(dbSkip())
						Loop
					EndIf
				EndIf
			Else
				If lSemFilial
					nPos	:= Ascan(aTabS119,{|x| alltrim(x[8])== alltrim((cAliasCTT)->CTT_CUSTO) })
				Else
					nPos	:= Ascan(aTabS119,{|x| AllTrim(xFilial("CTT",x[2]))+ alltrim(x[8]) == alltrim((cAliasCTT)->CTT_FILIAL) +  alltrim ((cAliasCTT)->CTT_CUSTO) })
				Endif
			EndIf

			If nPos > 0
				cTpReg := AllTrim(aTabS119[nPos][9])
				cTpApr := aTabS119[nPos][10]
				cNrApr := aTabS119[nPos][11]
				cTpEEn := aTabS119[nPos][12]
				If Len(aTabS119[nPos]) >= 14
					cCNPJR:= aTabS119[nPos][14] // CNPJ Responsavel
				Endif
			EndIf

			//Tratamento para remover caracteres do campo CNAE
			cCnae := AllTrim(StrTran(StrTran((cAliasCTT)->CTT_CNAE, "-",""), "/",""))

			//Busca informacao SubPatronal
			cSubPat := ""

			If (cAliasCTT)->CTT_TIPO2 == "4"
				cSubPat := (cAliasCTT)->CTT_ICTPAT
			EndIf

			nRat      :=  (cAliasCTT)->CTT_PERRAT
			cCodTerc  :=  (cAliasCTT)->CTT_CODTER
			nPercAc   :=  (cAliasCTT)->CTT_PERCAC
			nFap      :=  (cAliasCTT)->CTT_FAP

			If Len(aX14) > 0 .AND. lExtS037
				//Verifica se foi preenchido pelo registro da CTT,
				//Se for, continua com ele, se não, recebe valor da S037 e S038
				nRat     := Iif( Empty(nRat)     , aX14[nPos2,8], nRat )
				nPercAc  := Iif( Empty(nPercAc)  , aX14[nPos2,7], nPercAc )
				nFap     := Iif( Empty(nFap)     , nPercAc/aX14[nPos2,8], nFap )
			EndIf

			If Empty(nRat) .Or. Empty(cCodTerc)

				If ExistFunc("fChav119")
					nS129 	:= 0
					nPos129	:= 0
					//Busca o registro da tabela S129
					While nPos129 == 0 .And. nS129 <= 8
						nS129++
						nPos129 := Ascan(aTabS129,{|x| AllTrim(x[2]) + AllTrim(x[3]) + AllTrim(x[5]) == fChav119(nS129, .T., alltrim((cAliasCTT)->CTT_FILIAL), AllTrim(cAnoMes), Alltrim( (cAliasCTT)->CTT_CUSTO ) ) })
					EndDo
				Else
					nPos := Ascan(aTabS129,{|x| alltrim(x[2])== alltrim(aFilEnv[nI])+"" })
					If nPos129 == 0
						nPos129	:= Ascan(aTabS129,{|x| alltrim(x[2]) == ""+"" })
					EndIf
				Endif

				If LEN(aTabS129) > 0 .And. nPos129 > 0
					nRat 	:= aTabS129[nPos129,6]
					nPercAc	:= aTabS129[nPos129,7]
					nFAP	:= nPercAc/(aTabS129[nPos129,6])
				Endif

			Endif

			cChave := (cAliasCTT)->CTT_TIPO2 + ";" + (cAliasCTT)->CTT_CEI2 + ";" + cMesAnoP

			If !lMiddleware .And. ( FunName() == "GPEA320"  .and. lExtemp ) .OR. nOpcAux == 5
				nOpcAux := fVerExtemp( "S-1005", cChave, nOpcAux, @cStatus, lContinua, cFilEnv, @aErros )

				If nOpcA == 5
					If ( cStatus $ " |1|3|-1" )
						(cAliasCTT)->(dbSkip())
						Loop
					EndIf

				ElseIf ( FunName() == "GPEA320"  .and. lExtemp )
					If cStatus == "2"
						aAdd( aDados, PADR(OemToAnsi(STR0025), 25) + " " + PADR(OemToAnsi(STR0086) + " " + aFilEnv[nI], 77) + " " + If(!lMiddleware,PADR(OemToAnsi(STR0029), 26),PADR(OemToAnsi(STR0261), 26)) )
						aAdd( aDados, aErros[1])
						aAdd( aDados, "")
						nContErr++
					EndIf
					aErros := {}
				Endif

			EndIf

			//Adiciona Obras
			Aadd(aEstObras, {	(cAliasCTT)->CTT_FILIAL	, ; //1
								(cAliasCTT)->CTT_TIPO2	, ; //2
								(cAliasCTT)->CTT_CEI2	, ; //3
								(cAliasCTT)->CTT_FPAS	, ; //4
								cCodTerc				, ; //5
								cCnae					, ; //6
								Round(nRat, 0)			, ; //7
								nFAP					, ; //8
								npercAc					, ; //9
								(cAliasCTT)->CTT_CUSTO	, ; //10
								cSubPat					, ; //11
								cTpReg					, ; //12
								cTpApr					, ; //13
								cNrApr					, ; //14
								cTpEEn					, ; //15
								cMesAnoP				, ; //16
								nOpcAux					, ; //17
								cTpProc					, ; //18
								cNrProc					, ; //19
								cCSusp					, ; //20
								cTp						, ; //21
								cCNPJR					} ) //22
		EndIf
		nS119 := 0
		nS120 := 0
		nS129 := 0
		(cAliasCTT)->(dbSkip())
	EndDo

	If !lWorkFlow
		//Inicializa regua de processamento
		ProcRegua(Len(aEstObras))
	EndIf
	//Verifica as obras de Centro de Custo
	For nI := 1 To Len(aEstObras)
		//--------------
		//| Gerar Carga
		//--------------
		If nOpcAP == 1 .OR. nOpcAP == 5
			If !Empty(aEstObras[nI, 2]) .And. !Empty(aEstObras[nI, 3]) .And. (lNT15 .Or. !lNT15 .And. !Empty(aEstObras[nI, 13])) .and.;
			!Empty(aEstObras[nI, 6]) .and. (lNT15 .Or. !lNT15 .And. !Empty(aEstObras[nI, 12])) .And.;
			fGp23VlFil(nI, aEstObras, aLogCNPJ, nOpcAP, lSemFilial, lConsolid, 1)

				nValor := nI

				If FunName() $ "GPEA320"
					nOpcAux:= aEstObras[nI,17]
				EndIf

				lRet := fCarrCTT( aEstobras, cMesAnoP, aEstEd, @aErros, cFilEnv, nOpcAux, Iif(lMiddleware,nI,nValor) )

				If Len( aErros ) <= 0
					//--------------------------------------------------------------
					//| Os erros serão impressos alinhados | Tamanho cabecalho: 132
					//| Colunas: Eventos (25+1) | Item/Registro (77+1) | Status (26)
					//| PADR("Eventos", 25) + " " + PADR("ITEM/REGISTRO", 77) + " " + PADR("STATUS", 26))
					//------------------------------------------------------------------------------------------------------------------------------------
					//Estabelecimentos/Obras    XYZABC1230 123456789-0001 456487877787                                        Enviada ao TAF com sucesso."

					If( Empty( aEstObras[nI ,1] ) )
						aAdd( aDados, iif(lMiddleware, PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI, 10] + " - " + aEstObras[nI, 3], 77) + " " + PADR(OemToAnsi(STR0255), 33), PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI, 10] + " - " + aEstObras[nI, 3], 77) + " " + PADR(OemToAnsi(STR0030), 26) ) )
					Else
						aAdd( aDados, iif(lMiddleware, PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI ,1]+" - " + aEstObras[nI, 10] + " - " + aEstObras[nI, 3], 77) + " " + PADR(OemToAnsi(STR0255), 33), PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI ,1]+" - " + aEstObras[nI, 10] + " - " + aEstObras[nI, 3], 77) + " " + PADR(OemToAnsi(STR0030), 26) ) )
					EndIf
					If aEstObras[nI, 9] == 0 .Or. aEstObras[nI, 7] == 0
						aAdd( aDados, "" )
						aAdd( aDados,  SUBSTR(OemToAnsi(STR0060),43,76) ) // Os campos abaixo estão vazios ou zerados e são de preenchimento obrigatório:

						//Campo percentual Acidente de Trabalho Zerado
						If aEstObras[nI, 9] == 0
							aAdd(aDados, SUBSTR(OemToAnsi(STR0156),9,10)  + " - " + OemToAnsi(STR0137)) // CTT_PERCAC - Percentual Acidente de Trabalho
						EndIf

						//Campo percentual RAT zerado
						If aEstObras[nI, 7] == 0
							aAdd(aDados,   SUBSTR(OemToAnsi(STR0154),9,10)  + " - " + OemToAnsi(STR0136)) // CTT_PERRAT % RAT
						EndIf

						aAdd( aDados,  OemToAnsi(STR0214) ) //A menos que exista um processo permitindo os valores zerados para esse(s) campo(s), por este motivo a carga será realizada.
						aAdd( aDados, "" )
					Endif
					nContador++
				Else
					//Estabelecimentos/Obras    XYZABC1230                                                                    Nâo Enviada ao TAF         "
					If( Empty( aEstObras[nI ,1] ) )
						aAdd( aDados, iif(lMiddleware, PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI, 10] + " - " + aEstObras[nI, 3], 77) + " " + PADR(OemToAnsi(STR0242), 26), PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI, 10] + " - " + aEstObras[nI, 3], 77) + " " + PADR(OemToAnsi(STR0029), 26) ) )
					Else
						aAdd( aDados, iif(lMiddleware, PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI ,1]+ " - " + aEstObras[nI, 10] + " - " + aEstObras[nI, 3], 77) + " " + PADR(OemToAnsi(STR0242), 26), PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI ,1]+ " - " + aEstObras[nI, 10] + " - " + aEstObras[nI, 3], 77) + " " + PADR(OemToAnsi(STR0029), 26) ) )
					EndIf

					//Varrendo array de erro para envio de msg para log
					cResumo := ""
					for nCont:= 1 to len(aErros)
						cResumo += aErros[nCont]
					next

					aResumo := FWTxt2Array( cResumo, 125)
					For nCont := 1 To Len(aResumo)
						aAdd( aDados, aResumo[nCont] )
					Next

					AaDD( aDados, "" )

					nContErr++
				EndIf

				If !lWorkFlow
					//Incrementa regua
					IncProc(OemToAnsi(STR0069) + " " + aEstObras[nI ,1] + " - " + aEstObras[nI, 3]) //##"Gerando o registro de: "
				EndIf
			Else
				//------------------------------------------------------------------------------------------------------------------------------------
				//Estabelecimentos/Obras    XYZABC1230                                                                    Nâo Enviada ao TAF         "
				//Descricao dos erros diversos
				If( Empty( aEstObras[nI ,1] ) )
					aAdd( aDados, IIF(lMiddleware,PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI, 10] + " - " + aEstObras[nI, 3], 77) + " " + PADR(OemToAnsi(STR0242), 26),PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI, 10] + " - " + aEstObras[nI, 3], 77) + " " + PADR(OemToAnsi(STR0029), 26)) )
				Else
					aAdd( aDados, IIF(lMiddleware,PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI ,1]+" - " + aEstObras[nI, 10] + " - " + aEstObras[nI, 3], 77) + " " + PADR(OemToAnsi(STR0242), 26),PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI ,1]+" - " + aEstObras[nI, 10] + " - " + aEstObras[nI, 3], 77) + " " + PADR(OemToAnsi(STR0029), 26)) )
				EndIf

				nContErr++
				If( Empty(aEstObras[nI, 2]) )
					aAdd(aDados, OemToAnsi(STR0152) ) //"O campo CTT_TIPO2 (Tipo Tomador eSocial) está vazio e seu preenchimento é obrigatório."
				EndIf

				If( Empty(aEstObras[nI, 3]) )
					aAdd(aDados, OemToAnsi(STR0153) ) //"O campo CTT_CEI2 (Inscr. Tomador eSocial) está vazio e seu preenchimento é obrigatório."
				EndIf

				If empty(aEstObras[nI, 6])
					aAdd(aDados, OemToAnsi(STR0157) ) //"O campo CTT_CNAE (CNAE) está vazio e seu preenchimento é obrigatório."
				Endif

				If empty(aEstObras[nI, 12])
					aAdd(aDados, OemToAnsi(STR0158) ) //"O Campo Regime do Ponto está vazio e seu preenchimento é obrigatório, utilize a tabela S119"
				Endif

				If empty(aEstObras[nI, 13])
					aAdd(aDados, OemToAnsi(STR0159) ) //"O Campo Contrata Aprendiz está vazio e seu preenchimento é obrigatório, utilize a tabela S11
				Endif
				aAdd(aDados, "")

			EndIf
		Else //Impressao
			//Verifica campos vazios ou zerados


			If Empty(aEstObras[nI, 2]) .Or. Empty(aEstObras[nI, 3]) .Or. Empty(aEstObras[nI, 6]) .Or.;
			aEstObras[nI, 8] == 0 .And.;
			fGp23VlFil(nI, aEstObras, aLogCNPJ, nOpcAP, lSemFilial, lConsolid, 1) //Validacao CNPJ

				If Empty(cMenIni) .And. Len(aLogProc) == 0
					cMenIni := OemToAnsi(STR0060) //##"Inconsistências de Estabelecimento/Obra - Os campos abaixo estão vazios ou zerados e são de preenchimento obrigatórios:"

					aAdd(aLogProc, cMenIni)
					aAdd(aLogProc, "")
					aAdd(aLogProc, "")
				EndIf

				//Mensagem de log que sera gravado
				cMsgLog := OemToAnsi(STR0105) //##"Centro de Custo"

				//Verifica inconsistencias
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Posiciona na tabela CTT - Fisica                    	 	   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				CTT->(dbSetOrder(1))
				CTT->(MsSeek(aEstObras[nI, 1] + aEstObras[nI, 10]))

				//Mensagem de log
				cMsgLog += " " + aEstObras[nI, 10] + " - " + OemToAnsi(STR0125) + ": " //##"Preenchimento de campos obrigatórios"

				//Busca campos incosistentes
				fGp23Inco(aLogProc, 3, "CTT", @cMsgLog)
				If empty(aEstObras[nI, 12])
					cMsgLog += " " + OemToAnsi(STR0158) // rregime do ponto em branco
				Endif

				If empty(aEstObras[nI, 13])
					cMsgLog += " " + OemToAnsi(STR0159) // rregime do ponto em branco
				Endif

				cMsgLog += " " + aEstObras[nI, 10] + " - " + OemToAnsi(STR0125) + ": " //##"Preenchimento de campos obrigatórios"
			EndIf
			//Incrementa regua
			IncProc(OemToAnsi(STR0069) + " " + aEstObras[nI ,1] + " - " + aEstObras[nI, 2]) //##"Gerando o registro de: "
		EndIf
	Next nI

	//Se impressao, adiciona Log de Inconsistencias do CNPJ
	If nOpcAP == 2
		For nI := 1 To Len(aLogCNPJ)
			aAdd(aLogProc, OemToAnsi(STR0025)+" "+ aLogCNPJ[nI, 1] +" "+OemToAnsi(STR0061)) //##"Estabelecimentos/Obras"##"está cadastrado em duas ou mais filiais com dados de cadastro diferentes CTT_FPAS, CTT_CODTER"
			aAdd(aLogProc, OemToAnsi(STR0062)) //##"CTT_CNAE, CTT_PERRAT, CTT_FAT ou CTT_PERCAC"
			aAdd(aLogProc, "")
		Next nI
	Else
		//Grava log
		//cMsgLog := OemToAnsi(STR0025) + " - " + OemToAnsi(STR0032) + OemToAnsi(aIncons[1]) //##"Estabelecimentos/Obras" ##"Falha no envio ao TAF: "
		//fGp23GrLog(aFilEnv[1], "S1005", cMsgLog, "2")
	EndIf

	//Fecha alias em uso
	#IFDEF TOP
	If (Select(cAliasCTT) > 0)
		(cAliasCTT)->(dbCloseArea())
	EndIf
	#ENDIF

	RestArea(aAreaCTT)
	RestArea(aArea)

	//----------------------
	//| Monta rodapé de LOG
	//----------------------
	If nOpcAP == 1 .AND. (!lExtemp) .OR. (Len(aEstObras) > 0 .and. Len(aDados) > 0)
		aAdd(aDados,"")
		aAdd(aDados,(OemToAnsi(STR0111)+" "+ OemToAnsi(STR0110) + " " + OemToAnsi(STR0025) ))	//"Resumo" ###"Carga Inicial" Estabelecimento/Obras
		aAdd(aDados, OemToAnsi(STR0009)+": " +  SecsToTime(nHrInicio))							//Inicio Processamento: A
		nHrFim 	:= SecsToTime(Seconds())
		aAdd(aDados,+OemToAnsi(STR0010)+":    " + nHrFim)											//Fim Processamento:    A
		aAdd(aDados,"")
		aAdd(aDados,OemToAnsi(STR0077)+": " + SecsToTime(Seconds() - nHrInicio))		//Duracao do Processamento
		aAdd(aDados,IIF(lMiddleware,OemToAnsi(STR0243)+": "+ ALLTRIM(STR(nContador)),OemToAnsi(STR0078)+": "+ ALLTRIM(STR(nContador))))						//Quantidade Registro(s) enviado(s) ao TAF
		aAdd(aDados,IIF(lMiddleware,OemToAnsi(STR0244)+": "+ ALLTRIM(STR(nContErr)),OemToAnsi(STR0151)+": "+ ALLTRIM(STR(nContErr))))						//Quantidade Registros Não Enviados ao TAF
		aAdd(aDados,"")
		aAdd(aDados,"")
	EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fGp23VlFil³ Autor ³ Alessandro Santos     ³ Data ³24/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verificacao se CNPJ esta cadastrado para mais de 1 filial   ³±±
±±³          ³e se RAT, FAP e RAT Alterado estao diferentes - Consolidado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGp23VlFil()                                           	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nTpCarga: 1-Estabelecimentos e Obras/2-Portuarios          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023  					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

Static Function fGp23VlFil(nPosAtu, aDados, aLogCNPJ, nOpcA, lSemFilial, lConsolid, nTpCarga)

	Local nI   := 0
	Local nPos 	:= 0
	Local lRet 	:= .T.
	Local aArea := GetArea()

	//Tratamento para inconsistenacia de CNPJ repetido - Apenas para consolidado
	If lConsolid .And. !lSemFilial
		For nI := 1 To Len(aDados)
			//CNPJ repetido e com divergencias
			If nTpCarga == 1 //Estabelecimentos/Obras
				If nI <> nPosAtu .And. (aDados[nI, 2] == aDados[nPosAtu, 2] .And. aDados[nI, 3] == aDados[nPosAtu, 3]) .And.;
				(aDados[nI, 5] <> aDados[nPosAtu, 5] .Or.aDados[nI, 6] <> aDados[nPosAtu, 6])


					If nOpcA == 2 // Se impressao adiciona informacao de divergencia no CNPJ
						nPos := aScan(aLogCNPJ, {|X| X[1] == aDados[nI, 3]})

						If nPos == 0
							Aadd(aLogCNPJ, {aDados[nI, 3]})
						EndIf
					EndIf

					lRet := .F.
				EndIf
			Endif
		Next nI
	EndIf

	RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fCargLota ³ Autor ³ Alessandro Santos     ³ Data ³03/02/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza carga das tabelas de lotacoes para o TAF            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCargLota()                                          	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023   					                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fCargLota(cMesAnoP, nOpcAP, aLogProc, aDados, aArrayFilP,dPar7, cVersEnvio, lSM0, cCodTerc, nOpcAux, cCodigo, lExbMsgAlt, cFiltro)

	Local oModel     	:= Nil

	//Variáveis String
	Local cMenIni     	:= ""
	Local cMsgLog		:= ""
	Local cXml			:= ""
	Local cLayout		:= ""
	Local cLotInsc		:= "02|03|04|05|06|07|08|09"
	Local cFilEnv		:= ""
	Local cQryWhere		:= "%(CTT_FILIAL >= '"+ Space(TamSx3("CTT_FILIAL")[1])+ "')%"
	Local cAliasCTT  	:= GetNextAlias()
	Local aArea		 	:= GetArea()
	Local aAreaCTT  	:= CTT->(GetArea())
	Local cFPAS
	Local cChaveTAF		:= ""
	Local cTabLot		:= ""

	//Variáveis Numerico
	Local nIndex     	:= 5
	Local nOpc       	:= 3
	Local nTerc

	//Variáveis Array
	Local aArrayP 		:= {}
	Local aErros		:= {}
	Local aParam 		:= Array(4)
	Local aRet      	:= {}
	Local aExclu	  	:= {}
	Local aInfoFil    	:= {}
	Local aX14			:= {}

	//Variáveis Lógicas
	Local lSemFilial 	:= .F.
	Local lContinua		:= .T.
	Local lGeraSM0		:= .F.
	Local lNovoCTT		:= .F.
	Local lParcial		:= .F.
	Local lRJs			:= .F.

	//Variaveis de Auxilio de Erro
	Local aAuxErro		:= {}
	Local aConcat		:= ""
	Local nX 			:= 0

	Local nHrInicio
	Local nContador		:= 0
	Local nContErr		:= 0
	Local nHrFim
	Local cAnoMesP		:= ""

	Local cStatus 		:= "-1"

	Local cEFDAviso		:= If(cPaisLoc == 'BRA' .And. Findfunction("fEFDAviso"), fEFDAviso(), SuperGetMv("MV_EFDAVIS",, "0")) //Integracao com TAF)
	Local cXml		 	:= ""
	Local cMsg		 	:= ""
	Local cMsgErro	 	:= ""
	Local cVersMid	 	:= ""
	Local cChave	 	:= ""
	Local cMsgAux	 	:= ""
	Local cMsgRJE	 	:= ""
	Local cIni 		 	:= ""
	Local lAdmPubl	 	:= .F.
	Local aInfos	 	:= {}
	Local aDadosRJE	 	:= {}
	Local cFilEmp	 	:= ""
	Local lRet		 	:= .T.
	Local cRetfNew	 	:= ""
	Local cRetfRJE	 	:= ""
	Local cRetKey	 	:= ""
	Local cOperNew 	 	:= ""
	Local cOperRJE	 	:= "I"
	Local cRetfNew	 	:= ""
	Local cStatNew	 	:= ""
	Local lNovoRJE	 	:= .F.
	Local nOpcao 	 	:= 3
	Local nRecRJE  	 	:= 0
	Local lS1000 	 	:= .F.
	Local aSM0    	 	:= {}
	Local cBkpFil	 	:= cFilAnt
	Local cTpAmb		:= ""
	Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
	Local lRobo			:= IsBlind() .Or. IsInCallStack("FwMyTestRunner") .Or. IsInCallStack("EXECSUITE") .Or. IsInCallStack("EXECSUITEBLIND") .Or. IsInCallStack("AUTJOBRUNCT")

	default cMesAnoP 	:= ""
	default nOpcAP		:= 1
	default aArrayFilP	:= {}
	Default cVersEnvio	:= "2.2"
	Default lSM0		:= .F.
	default cCodTerc	:= ""
	default nOpcAux    	:= nOpc
	default cCodigo    	:= ""
	default lExbMsgAlt 	:= .F.
	Default cFiltro 	:= ""

	cFilEnv		:= aArrayFilP[2]

	cAnoMesP  := SUBSTR(cMesAnoP,3) + SUBSTR(cMesAnoP,1,2)

	//Se for exclusão em Lote
	If nOpcAP == 1
		nOpcAux := 3
	ElseIf nOpcAP == 5
		nOpcAux := 5
	EndIf

	//Verificação do novo controle de Obras/Lotações eSocial
	lNovoCTT:= FindFunction("fVldObraRJ") .And. fVldObraRJ(@lParcial, .T.)
	lRJs := lNovoCTT .And. !lParcial
	IIf(lRJs, cTabLot:= "RJ3", cTabLot:= "CTT")

	//Tratamento para o modo de acesso das tabelas (CTT ou RJ3)
	If FWModeAccess(cTabLot, 1) == "C" .AND. FWModeAccess(cTabLot, 2) == "C" .AND. FWModeAccess(cTabLot, 3) == "C" //CTT/RJ3 compartilhada
		lSemFilial := .T.
	EndIf

	If !Empty(cFilEnv)
		If lMiddleware
			fPosFil( cEmpAnt, cFilEnv )
		EndIf
		fInfo(aInfoFil, cFilEnv, cEmpAnt)
		fInssEmp(cFilEnv,@aX14,.F.,cAnoMesP)

		If !Empty(cFiltro)
			cQryWhere 	:= StrTran(cQryWhere,"%","")
			cQryWhere 	:= "%"+cQryWhere+ " AND " + GPEParSQL(fPrepExpIn(cFiltro)) + "%"
		EndIf

		//Inicio de Operação
		nHrInicio := Seconds()

		//Busca informacoes CTT - Centro de Custo
		BeginSql alias cAliasCTT
			SELECT
			CTT_FILIAL, CTT_CUSTO, CTT_NOME, CTT_TPLOT, CTT_TIPO, CTT_CEI, CTT_FPAS, CTT_CODTER,
			CTT_TPINCT,	CTT_NRINCT, CTT_TPINPR, CTT_NRINPR, CTT_TIPO2, CTT_CEI2, CTT_CLASSE
			FROM
			%table:CTT% CTT
			WHERE
			CTT.%notDel% AND %exp:cQryWhere%
			ORDER BY
			CTT.CTT_FILIAL, CTT.CTT_CUSTO
		EndSql
		dbSelectArea(cAliasCTT)

		//Posiciona no inicio do arquivo
		(cAliasCTT)->(dbGoTop())

		If !lWorkFlow
			//Inicializa regua de processamento
			ProcRegua((cAliasCTT)->(RecCount()))
		EndIf
		While (cAliasCTT)->(!EOF())

			//Verifica filiais
			If lSemFilial //Compartilhada
				lContinua := .T.
			ElseIf !lMiddleware .And. aScan(aArrayFilP[3], {|X| Alltrim(FwxFilial("CTT", X)) == Alltrim((cAliasCTT)->CTT_FILIAL)}) > 0 .Or.;      //Exclusiva
				lMiddleware .And. Alltrim(FwxFilial("CTT", cFilEnv)) == Alltrim((cAliasCTT)->CTT_FILIAL)      //Exclusiva
				lContinua := .T.
			Else
				lContinua := .F.
			EndIf

			If lContinua .and. (cAliasCTT)->CTT_CLASSE == "2"

				cCodLot := IIf(lSemFilial,(cAliasCTT)->CTT_CUSTO, (cAliasCTT)->CTT_FILIAL+(cAliasCTT)->CTT_CUSTO)
				aAuxErro := {}

				//--------------------------------
				//| Realizando a geração da carga
				//--------------------------------
				If nOpcAP == 1 .OR. nOpcAP == 5
					CTT->(dbSetOrder(1))
					CTT->(MsSeek((cAliasCTT)->CTT_FILIAL + (cAliasCTT)->CTT_CUSTO))

					//Se for extemporâneo ou Exclusão em Lote
					If lSM0 .Or. FunName() == "GPEA320" .Or. nOpcAP == 5

						If !lRobo .And. !Empty((cAliasCTT)->CTT_FPAS) .And. !Empty((cAliasCTT)->CTT_CODTER)
							(cAliasCTT)->(dbSkip())
							Loop
						EndIf

						If Empty(cMesAnoP)
							cMesAnoP := Month2Str(dDatabase)+Year2Str(dDatabase)
						EndIf

						If !lMiddleware
							cChaveTAF := cCodLot + ";" + cMesAnoP + ";1"
							nOpcAux := fVerExtemp( "S-1020", cChaveTAF, nOpcAux, @cStatus, lContinua, cFilEnv, @aErros )

							If nOpcAux == 4
								lExbMsgAlt := .T.
							EndIf

							//Se status 2 ou 4 -> Segue o fluxo | Se for diferente, aborta processo
							If nOpcAP == 5
								If ( cStatus $ " |1|3|-1" )
									(cAliasCTT)->(dbSkip())
									nOpcAux := 5 //Reinicio o valor da nOpcAux que foi alterada na chamada da função fVerExtemp
									Loop
								EndIf
							EndIf
						EndIf
					Endif

					lContinua := fGp23Inco(aLogProc, 2, "CTT", @cMsgLog, .F., aAuxErro)

					If lContinua  .and. (cAliasCTT)->CTT_CLASSE == "2"
						If !Empty((cAliasCTT)->CTT_TPLOT) .or. (((cAliasCTT)->CTT_TPLOT $ "02|03|04|05|06|07|08|09" .AND. !Empty((cAliasCTT)->CTT_TIPO2) .AND. !Empty((cAliasCTT)->CTT_CEI2)))
							If lMiddleware
								cIni := SubStr(cMesAnoP,3,4)+SubStr(cMesAnoP,1,2)
								fVersEsoc("S-1020", .F., /*@aRetGPE*/, /*@aRetTAF*/, ,,@cVersMid,,@cTpAmb)
								// verificar os predecessores - evento S1000
								cStatus := "-1"
								cMsgAux := ""
								lS1000 := fVld1000( cIni, @cStatus )
								/*
								* 1 - Não enviado - Gravar por cima do registro encontrado
								* 2 - Enviado - Aguarda Retorno - Enviar mensagem em tela e não continuar com o processo
								* 3 - Retorno com Erro - Gravar por cima do registro encontrado
								* 4 - Retorno com Sucesso -?Efetivar a gravação
								*/
								If lS1000 .Or. cEFDAviso $ "0/2"
									aInfos   := fXMLInfos()

									IF Len(aInfos) >= 4
										cTpInsc  := aInfos[1]
										lAdmPubl := aInfos[4]
										cNrInsc  := aInfos[2]
									Else
										cTpInsc  := ""
										lAdmPubl := .F.
										cNrInsc  := "0"
									EndIf

									aSM0    	 	:= FWLoadSM0(.T.,,.T.)
									If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpAnt .And. X[18] == cNrInsc }) ) > 0
										cFilEmp := aSM0[nFilEmp, 2]
									Else
										cFilEmp := cFilAnt
									EndIf

									// verifica se ja existe o evento s1020 na base de dados
									cChave 	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1020" + Padr(xFilial("CTT", (cAliasCTT)->CTT_FILIAL) + (cAliasCTT)->CTT_CUSTO, fTamRJEKey(), " ") + cIni
									cStatus := "-1"
									//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
									GetInfRJE( 2, cChave, @cStatus, @cOperRJE, @cRetfRJE, @nRecRJE )
									If cStatus != "-1"
										lExbMsgAlt := .T.
									EndIf
									//Alteração ou exclusão
									If nOpcAux == 4 .Or. nOpcAux == 5
										//Retorno pendente impede o cadastro
										If cStatus == "2"
											cMsgRJE 	:= STR0246//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
											lRet		:= .F.
											//ALTERACAO
										ElseIf nOpcAux == 4 .AND. cStatus <> "2"
											//Evento de exclusão sem transmissão impede o cadastro
											If cOperRJE == "E" .And. cStatus != "4"
												cMsgRJE 	:= STR0247//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
												lRet		:= .F.
												//Não existe na fila, será tratado como inclusão
											ElseIf cStatus == "-1"
												nOpcAux		:= 3
												cOperNew 	:= "I"
												cRetfNew	:= "1"
												cStatNew	:= "1"
												lNovoRJE	:= .T.
												//Evento sem transmissão, irá sobrescrever o registro na fila
											ElseIf cStatus $ "1/3"
												If cOperRJE == "A"
													nOpcAux	:= 4
												EndIf
												cOperNew 	:= cOperRJE
												cRetfNew	:= cRetfRJE
												cStatNew	:= "1"
												lNovoRJE	:= .F.
												//Evento diferente de exclusão transmitido, irá gerar uma retificação
											ElseIf cOperRJE != "E" .And. cStatus == "4"
												nOpcAux		:= 4
												cOperNew 	:= "A"
												cRetfNew	:= "2"
												cStatNew	:= "1"
												lNovoRJE	:= .T.
												//Evento de exclusão transmitido, será tratado como inclusão
											ElseIf cOperRJE == "E" .And. cStatus == "4"
												nOpcAux 	:= 3
												cOperNew 	:= "I"
												cRetfNew	:= "1"
												cStatNew	:= "1"
												lNovoRJE	:= .T.
											EndIf
											//Exclusão
										ElseIf nOpcAux == 5
											nOpcAux 		:= 5
											//Evento de exclusão sem transmissão impede o cadastro
											If cOperRJE == "E" .And. cStatus != "4"
												cMsgRJE 	:= STR0247//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
												lRet		:= .F.
												//Evento diferente de exclusão transmitido irá gerar uma exclusão
											ElseIf cOperRJE != "E" .And. cStatus == "4"
												cOperNew 	:= "E"
												cRetfNew	:= cRetfRJE
												cStatNew	:= "1"
												lNovoRJE	:= .T.
											EndIf
										EndIf
									ElseIf nOpcAux == 3
										//Retorno pendente impede o cadastro
										If cStatus == "2"
											cMsgRJE 	:= STR0246//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
											lRet		:= .F.
											//Evento de exclusão sem transmissão impede o cadastro
										ElseIf cOperRJE == "E" .And. cStatus != "4"
											cMsgRJE 	:= STR0247//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
											lRet		:= .F.
											//Evento sem transmissão, irá sobrescrever o registro na fila
										ElseIf cStatus $ "1/3"
											nOpcAux		:= Iif( cOperRJE == "I", 3, 4 )
											cOperNew 	:= cOperRJE
											cRetfNew	:= cRetfRJE
											cStatNew	:= "1"
											lNovoRJE	:= .F.
											//Evento diferente de exclusão transmitido, irá gerar uma retificação
										ElseIf cOperRJE != "E" .And. cStatus == "4"
											nOpcAux		:= 4
											cOperNew 	:= "A"
											cRetfNew	:= "2"
											cStatNew	:=  "1"
											lNovoRJE	:= .T.
											//Será tratado como inclusão
										Else
											cOperNew 	:= "I"
											cRetfNew	:= "1"
											cStatNew	:= "1"
											lNovoRJE	:= .T.
										EndIf
									EndIf

									If !lRet
										aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 77) + " " + PADR(OemToAnsi(STR0256), 26) )//"Não enviada ao Middleware."
										aAdd( aDados, cMsgRJE )
										nContErr++
										(cAliasCTT)->(dbSkip())
										Loop
									EndIf
								EndIf
								If !lS1000 .And. cEFDAviso != "2"
									Do Case
										Case cStatus == "-1" // nao encontrado na base de dados
										If cEFDAviso == "1"
											cMsgRJE := STR0249 //"Registro do evento S-1000 não localizado na base de dados"
										Else
											cMsgAux := STR0249 //"Registro do evento S-1000 não localizado na base de dados"
										EndIf
										Case cStatus == "1" // nao enviado para o governo
										If cEFDAviso == "1"
											cMsgRJE := STR0250 //"Registro do evento S-1000 não transmitido para o governo"
										Else
											cMsgAux := STR0250 //"Registro do evento S-1000 não transmitido para o governo"
										EndIf
										Case cStatus == "2" // enviado e aguardando retorno do governo
										If cEFDAviso == "1"
											cMsgRJE := STR0251 //"Registro do evento S-1000 aguardando retorno do governo"
										Else
											cMsgAux := STR0251 //"Registro do evento S-1000 aguardando retorno do governo"
										EndIf
										Case cStatus == "3" // enviado e retornado com erro
										If cEFDAviso == "1"
											cMsgRJE := STR0252 //"Registro do evento S-1000 retornado com erro do governo"
										Else
											cMsgAux := STR0252 //"Registro do evento S-1000 retornado com erro do governo"
										EndIf
									Endcase

									// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
									If cEFDAviso == "1"
										aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 60) + " " + PADR(OemToAnsi(STR0256), 26) )//"Não enviada ao Middleware."
										aAdd( aDados, cMsgRJE )
										nContErr++
										(cAliasCTT)->(dbSkip())
										Loop
									EndIf
								EndIf
							EndIf

							cFPAS:=(cAliasCTT)->CTT_FPAS
							nTerc:=(cAliasCTT)->CTT_CODTER

							If (cAliasCTT)->CTT_TPLOT $ "01"
								If empty(cFPAS)
									cFPAS := AllTrim(Str(Val(aInfoFil[17])))
									lGeraSM0 := .T.
								Else
									lGeraSM0 := .F.
								EndIf
								If Empty(nTerc)
									if !Empty(cCodTerc)
										nTerc := CVALTOCHAR(cCodTerc)
									Else
										nTerc := aX14[25,1]
									EndIf
								EndIf
							Else
								lGeraSM0 := .F.
							Endif

							Begin Transaction
								If (lSM0 .And. lGeraSM0) .Or. !lSM0
									lRet := fCarrLot(cCodLot,cMesAnoP,(cAliasCTT)->CTT_TPLOT ,cLotInsc,(cAliasCTT)->CTT_TIPO2,(cAliasCTT)->CTT_CEI2,cFPAS,nTerc,(cAliasCTT)->CTT_TPINCT,(cAliasCTT)->CTT_NRINCT, (cAliasCTT)->CTT_TPINPR,(cAliasCTT)->CTT_NRINPR,nOpcAux, @aErros,cFilEnv,.F., @cXml, cVersMid, @cRetKey, cTpAmb)
									If lMiddleware
										aDadosRJE := {}
										aAdd( aDadosRJE, { xFilial("RJE", cFilAnt), xFilial("CTT", (cAliasCTT)->CTT_FILIAL), cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1020", cIni, (cAliasCTT)->CTT_FILIAL + (cAliasCTT)->CTT_CUSTO, cRetKey, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew } )

										//Se não for uma exclusão de registro não transmitido, cria/atualiza registro na fila
										If !( nOpcAux == 5 .And. ((cOperRJE == "E" .And. cStatus == "4") .Or. cStatus $ "-1/1/3") )
											If !( lRet := fGravaRJE( aDadosRJE, cXml, lNovoRJE, nRecRJE ) )
												cMsgRJE := STR0253//"Ocorreu um erro na gravação do registro na tabela RJE"
											EndIf
											//Se for uma exclusão e não for de registro de exclusão transmitido, exclui registro de exclusão na fila
										ElseIf nOpcAux == 5 .And. cStatus != "-1" .And. !(cOperRJE == "E" .And. cStatus == "4")
											If !( lRet := fExcluiRJE( nRecRJE ) )
												cMsgRJE := STR0254//"Ocorreu um erro na exclusão do registro na tabela RJE"
											EndIf
										EndIf
									EndIf
								Endif

								If (!lMiddleware .And. Len( aErros ) <= 0) .Or. (lMiddleware .And. Empty(cMsgRJE))
									//--------------------------------------------------------------
									//| Os erros serão impressos alinhados | Tamanho cabecalho: 132
									//| Colunas: Eventos (25+1) | Item/Registro (77+1) | Status (26)
									//| PADR("Eventos", 25) + " " + PADR("ITEM/REGISTRO", 77) + " " + PADR("STATUS", 26))
									//------------------------------------------------------------------------------------------------------------------------------------
									//Lotacao                   XYZABC1230                                                                    Enviada ao TAF com sucesso."
									If FunName() <> "GPEA320" .Or. (FunName() == "GPEA320" .And. cCodigo == "S038")
										If !lMiddleware
											aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 77) + " " + PADR(OemToAnsi(STR0030), 26) )
										Else
											aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 60) + " " + PADR(OemToAnsi(STR0265), 36) )//"Enviado ao Middleware com sucesso."
											If !Empty(cMsgAux)
												aAdd( aDados, "Obs.: " + cMsgAux )//"Enviada com sucesso."
											EndIf
										EndIf
									EndIf
									nContador++
								Else
									aConcat := {}

									//Le o erro e quebra num array de acordo com a quantidade de enter
									If !lMiddleware
										aConcat := FWTxt2Array( aErros[1], 125)//StrTokArr(, chr(13)+chr(10))
									EndIf

									//Adiciona cabeçalho do erro (Lotação: XYS - Não enviado ao TAF)
									//Lotacao                   XYZABC1230                                                                    Nâo Enviada ao TAF         "
									If !lMiddleware
										aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 77) + " " + PADR(OemToAnsi(STR0029), 26) )
									Else
										aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 60) + " " + PADR(OemToAnsi(STR0256), 26) )//"Não enviada ao Middleware."
									EndIf
									nContErr++

									//Atribui o erro no aDados para impressão em tela
									For nX := 1 To len(aConcat)
										If(!Empty(aConcat[nX]), aAdd( aDados, aConcat[nX] ), )
									Next
									If lMiddleware
										aAdd( aDados, cMsgRJE )
									EndIf
									aAdd( aDados, "" )
								EndIf

								If !lWorkFlow
									//Incrementa regua
									IncProc(OemToAnsi(STR0069) + " " + cCodLot + " " + AllTrim((cAliasCTT)->CTT_NOME))
								EndIf
							End Transaction
						Else

							//Lotacao                   XYZABC1230                                                                    Nâo Enviada ao TAF         "
							If !lMiddleware
								aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 77) + " " + PADR(OemToAnsi(STR0029), 26) )
							Else
								aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 60) + " " + PADR(OemToAnsi(STR0256), 26) )//"Não enviada ao Middleware."
							EndIf
							If( Empty((cAliasCTT)->CTT_TPLOT) )
								aAdd(aDados, OemToAnsi(STR0163) ) //"Campo Vazio: O Campo CTT_TPLOT deve ser preenchido"
							ElseIf( (cAliasCTT)->CTT_TPLOT $ "02|03|04|05|06|07|08|09" .AND. !Empty((cAliasCTT)->CTT_TIPO2) .AND. !Empty((cAliasCTT)->CTT_CEI2) )
								aAdd(aDados, OemToAnsi(STR0164) ) //"Dados Inválidos: Se o campo CTT_TPLOT for igual a '02|03|04|05|06|07|08|09', os campos CTT_TIPO2 e CTT_CEI2 não podem ser preenchidos."
							EndIf
							aAdd(aDados, "" )
						EndIf
					Else
						If( !lContinua )
							//Lotacao                   XYZABC1230                                                                    Nâo Enviada ao TAF         "
							If !lMiddleware
								aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 77) + " " + PADR(OemToAnsi(STR0029), 26) )
							Else
								aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 60) + " " + PADR(OemToAnsi(STR0256), 26) )//"Não enviada ao Middleware."
							EndIf
							For nX := 1 To Len( aAuxErro )
								aAdd(aDados, aAuxErro[nX])
							Next
						ElseIf( (cAliasCTT)->CTT_CLASSE == "2" )
							If !lMiddleware
								aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 77) + " " + PADR(OemToAnsi(STR0029), 26) )
								aAdd(aDados, OemToAnsi(STR0165) ) //Tipo Inválido: A lotação não foi enviada ao TAF, pois é do tipo Sintético
							Else
								aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 60) + " " + PADR(OemToAnsi(STR0256), 26) )//"Não enviada ao Middleware."
								aAdd(aDados, OemToAnsi(STR0257) ) //Tipo Inválido: A lotação não foi enviada ao Middleware, pois é do tipo Sintético
							EndIf
						EndIF
						//Pula Linha
						aAdd(aDados, "")
						nContErr++
					EndIf

					//------------------------------------
					//| Realizando a geração do Relatório
					//------------------------------------
				Else
					If (((cAliasCTT)->CTT_TPLOT $ "02|03|04|05|06|07|08|09" .AND. (Empty((cAliasCTT)->CTT_TIPO2) .OR. Empty((cAliasCTT)->CTT_CEI2)))) .OR. Empty((cAliasCTT)->CTT_TPLOT)

						If Empty(cMenIni)
							cMenIni := OemToAnsi(STR0051) //##"Inconsistências de Lotações - Os campos abaixo estão vazios e são de preenchimento obrigatórios:"

							aAdd(aLogProc, cMenIni)
							aAdd(aLogProc, "")
							aAdd(aLogProc, "")
						EndIf

						//Mensagem de log que sera gravado
						cMsgLog := OemToAnsi(STR0105) //##"Centro de Custo"

						//Verifica inconsistencias
						/*
						ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³ Posiciona na tabela CTT - Fisica                    	 	   ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
						CTT->(dbSetOrder(1))
						CTT->(MsSeek((cAliasCTT)->CTT_FILIAL + (cAliasCTT)->CTT_CUSTO))

						//Mensagem de log
						cMsgLog += " " + (cAliasCTT)->CTT_CUSTO + " - " + OemToAnsi(STR0125) + ": " //##"Preenchimento de campos obrigatórios"

						//Busca campos incosistentes
						fGp23Inco(aLogProc, 2, "CTT", @cMsgLog, .F.)

						//Incrementa regua
						IncProc(OemToAnsi(STR0069) + " " + cCodLot + " " + AllTrim((cAliasCTT)->CTT_NOME))
					EndIf
				EndIf
			EndIf
			(cAliasCTT)->(dbSkip())
		EndDo
		If lMiddleware
			fPosFil( cEmpAnt, cBkpFil )
		EndIf
	EndIf

	//Fecha alias em uso
	#IFDEF TOP
	If (Select(cAliasCTT) > 0)
		(cAliasCTT)->(dbCloseArea())
	EndIf
	#ENDIF

	RestArea(aAreaCTT)
	RestArea(aArea)

	//----------------------
	//| Monta rodapé de LOG
	//----------------------
	If nOpcAP == 1
		If FunName() <> "GPEA320" .Or. (FunName() == "GPEA320" .And. cCodigo == "S038")
			aAdd(aDados,"")
			aAdd(aDados,(OemToAnsi(STR0111)+" "+ OemToAnsi(STR0110) + " " + OemToAnsi(STR0052) ))	//"Resumo" ###"Carga Inicial" Lotação
			aAdd(aDados, OemToAnsi(STR0009)+": " +  SecsToTime(nHrInicio))							//Inicio Processamento: A
			nHrFim 	:= SecsToTime(Seconds())
			aAdd(aDados,+OemToAnsi(STR0010)+":    " + nHrFim)											//Fim Processamento:    A
			aAdd(aDados,"")
			aAdd(aDados,OemToAnsi(STR0077)+": " + SecsToTime(Seconds() - nHrInicio))		//Duracao do Processamento
			If !lMiddleware
				aAdd(aDados,OemToAnsi(STR0078)+": "+ ALLTRIM(STR(nContador)))						//Quantidade Registro(s) enviado(s) ao TAF
				aAdd(aDados,OemToAnsi(STR0151)+": "+ ALLTRIM(STR(nContErr)))						//Quantidade Registros Não Enviados ao TAF
			Else
				aAdd(aDados,OemToAnsi(STR0243)+": "+ ALLTRIM(STR(nContador)))						//Quantidade Registro(s) enviado(s) ao Middleware
				aAdd(aDados,OemToAnsi(STR0244)+": "+ ALLTRIM(STR(nContErr)))						//Quantidade Registros Não Enviados ao Middleware
			EndIf
			aAdd(aDados,"")
			aAdd(aDados,"")
		EndIf
	EndIf

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fCarrLot    ºAutor  ³Marcia Moura        º Data ³  06/11/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega Lotacoes                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GPEM023-                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fCarrLot(cCodLot, cMesAnoP, cTpLot, cLotInsc, cTp2, cInsEsoc, cFPAS, nTerc, cTpInsCo, cNrInsCo, cTpInsPr, cNrInsPr, nOpc, aErros, cFilEnv, lAviso, cRetXML, cVersMw, cId, cTpAmb, oModel941C)

	Local cXml 			:= ""
	Local lGravou 		:= .T.
	Local aIncons		:= {}
	Local nPos			:= 0
	Local lAdmPubl		:= .F.
	Local aInfos		:= {}
	Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
	Local lRot941C		:= .F.
	Local oCab			:= Nil
	Local oGrid			:= Nil

	Local aPrcRJM		:= {}
	Local cCodRJM		:= ""
	Local cFilRJM		:= ""
	Local cLastComp		:= ""
	Local nContRJM		:= 0

	Default cFilEnv		:= ""
	Default cId			:= ""

	default cCodLot 	:= "" //M->CTT_FILIAL + M->CTT_CUSTO
	default cMesAnoP 	:= "" //Mes+Ano
	default cTpLot		:= "" //CTT_TPLOT - Tipo Lotacao
	default cLotInsc 	:= "" //Tipos de Lotação cLotInsc
	default cTp2		:= "" //CTT_TIPO2 - Tipo 2
	default cInsEsoc 	:= "" //CTT_CEI2  - Tipo Inscricao eSocial
	default cFPAS 		:= "" //CTT_FPAS
	default nTerc 		:= "" //CTT_CODTER - Codigo de Terceiro
	default cTpInsCo 	:= "" //CTT_TPINCT- Tipo Inscrição Contratante
	default cNrInsCo 	:= "" //CTT_NRINCT - Nro Inscricao Contratante
	default cTpInsPr 	:= "" //CTT_TPINPT - Tipo Inscricao Proprietario
	default cNrInsPr 	:= "" //CTT_NRINPT - Nro Inscricao Proprietario
	default nOpc 		:= 3  //Identificador de Processo
	Default lAviso		:= .T.
	Default cRetXML		:= ""
	Default cVersMw		:= "02_05_00"
	Default cTpAmb		:= "2"
	Default oModel941C	:= Nil

	lRot941C := (oModel941C != Nil )
	If lRot941C
		oCab	:= oModel941C:GetModel("RJMMASTER")
		oGrid	:= oModel941C:GetModel("RJMDETAIL")
	EndIf

	If lMiddleware
		aInfos	:= fXMLInfos()

		If len(aInfos) >= 4
			cId 	:= aInfos[3]
			cTpInsc := aInfos[1]
			cNrInsc := aInfos[2]
			lAdmPubl:= aInfos[4]
		Else
			cTpInsc  := ""
			lAdmPubl := .F.
			cNrInsc  := "0"
			cId		 := ""
		Endif

		cXML := "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTabLotacao/v" + cVersMw + "'>"
		cXML += 	"<evtTabLotacao Id='" + cId + "'>"

		fXMLIdEve( @cXML, { Nil, Nil, Nil, Nil, cTpAmb, 1, "12" } )
		fXMLIdEmp( @cXML, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
	Else
		cXml := '<eSocial>'
		cXml += '	<evtTabLotacao>'
	EndIf
	cXml += '		<infoLotacao>'

	If nOpc == 3
		cXml += '		<inclusao>'

	ElseIf  nOpc == 4
		cXml += '		<alteracao>'

	ElseIf  nOpc == 5
		cXml += '		<exclusao>'
	Endif

	cXml += '				<ideLotacao>'
	If lMiddleware
		cXml += '					<codLotacao>' + Alltrim(StrTran(cCodLot, "&", "&amp;")) + '</codLotacao>'
	Else
		cXml += '					<codLotacao>' + StrTran(cCodLot, "&", "&amp;") + '</codLotacao>'
	EndIF
	cXml += '					<iniValid>' + substr(cMesAnoP,3,4) + '-' + substr(cMesAnoP,1,2) + '</iniValid>'
	If !lMiddleware
		cXml += '					<fimValid>' + '' + '</fimValid>'
	EndIf
	cXml += '				</ideLotacao>'

	If nOpc <> 5
		cXml += '			<dadosLotacao>'
		cXml += '				<tpLotacao>' + cTpLot + '</tpLotacao>'

		If (cTpLot $ cLotInsc)
			cXml += '			<tpInsc>' + cTp2 + '</tpInsc>'
			cXml += '			<nrInsc>' + cInsEsoc + '</nrInsc>'
		EndIf

		cXml += '				<fpasLotacao>'
		If lMiddleware
			cXml += '				<fpas>' + Alltrim(cFPAS) + '</fpas>'
			cXml += '				<codTercs>' + Alltrim(nTerc) + '</codTercs>'
		Else
			cXml += '				<fpas>' + cFPAS + '</fpas>'
			cXml += '				<codTercs>' + nTerc + '</codTercs>'
		EndIf
		If lTemRJM
			If !lRot941C
				If Len(cCodLot) > nTamCC
					cFilRJM := xFilial( "RJM", SubStr(cCodLot, 1, FwGetTamFilial) )
					cCodRJM := SubStr(cCodLot, FwGetTamFilial+1)
				Else
					cFilRJM := Space(FwGetTamFilial)
					cCodRJM := cCodLot
				EndIf
				If RJM->( dbSeek( cFilRJM+cCodRJM ) )
					While RJM->( !EoF() ) .And. RJM->RJM_FILIAL+RJM->RJM_COD == cFilRJM+cCodRJM
						If SubStr(cMesAnoP,3,4)+SubStr(cMesAnoP,1,2) >= RJM->RJM_COMPET
							If cLastComp != RJM->RJM_COMPET
								aPrcRJM		:= {}
								cLastComp 	:= RJM->RJM_COMPET
							EndIf
							aAdd( aPrcRJM, { RJM->RJM_TERS, RJM->RJM_TERC, RJM->RJM_NPROC, RJM->RJM_SUSP } )
						EndIf
						RJM->( !dbSkip() )
					EndDo
				EndIf
			Else
				If oCab:GetOperation() != MODEL_OPERATION_DELETE
					For nContRJM := 1 To oGrid:Length()
						oGrid:GoLine(nContRJM)
						If !oGrid:IsDeleted()
							aAdd( aPrcRJM, { oCab:GetValue("RJM_TERS"), oGrid:GetValue("RJM_TERC"), oGrid:GetValue("RJM_NPROC"), oGrid:GetValue("RJM_SUSP") } )
						EndIf
					Next nContRJM
				EndIf
			EndIf
		EndIf
		If Len(aPrcRJM) > 0
			cXml += '				<codTercsSusp>' + aPrcRJM[1, 1] + '</codTercsSusp>'
		EndIf
		If Len(aPrcRJM) > 0
			cXml += '				<infoProcJudTerceiros>'
			For nContRJM := 1 To Len( aPrcRJM )
				cXml += '				<procJudTerceiro>'
				cXml += '					<codTerc>' + AllTrim(aPrcRJM[nContRJM, 2]) + '</codTerc>'
				cXml += '					<nrProcJud>' + AllTrim(aPrcRJM[nContRJM, 3]) + '</nrProcJud>'
				cXml += '					<codSusp>' + AllTrim(aPrcRJM[nContRJM, 4]) + '</codSusp>'
				cXml += '				</procJudTerceiro>'
			Next nContRJM
			cXml += '				</infoProcJudTerceiros>'
		EndIf
		cXml += '				</fpasLotacao>'
		//Dados de Subempreitada
		If cTpLot == "02"
			cXml += '			<infoEmprParcial>'
			cXml += '				<tpInscContrat>' + cTpInsCo + '</tpInscContrat>'
			cXml += '				<nrInscContrat>' + cNrInsCo + '</nrInscContrat>'
			cXml += '				<tpInscProp>' + cTpInsPr + '</tpInscProp>'
			cXml += '				<nrInscProp>' + cNrInsPr + '</nrInscProp>'
			cXml += '			</infoEmprParcial>'
		EndIf
		cXml += '			</dadosLotacao>'
	EndIf

	If nOpc == 3
		cXml += '		</inclusao>'
	ElseIf  nOpc == 4
		cXml += '		</alteracao>'
	ElseIf  nOpc == 5
		cXml += '		</exclusao>'
	EndIf

	cXml += '		</infoLotacao>'
	cXml += '	</evtTabLotacao>'
	cXml += '</eSocial>'

	cRetXML := cXml

	GrvTxtArq(cXml, "S1020") // Geração do XML na System (Mediante o MV_XMLGPE)
	If !lMiddleware
		aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S1020")

		If Len( aErros ) > 0
			If lAviso
				Aviso(OemtoAnsi(STR0001), aErros[1],{"Ok"},3) //"Integração - TAF"
			EndIf
			lGravou := .F.
		Endif
	EndIf

Return lGravou

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fCarrCTT  ³ Autor ³ Marcos Coutinho       ³ Data ³05/07/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Realiza a criação do XML da tabelas Obras para o TAF via CTT³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCarrCTT()                                            	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEM023	         	                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function fCarrCTT( aEstObras, cMesAnoP, aEstEd, aErros, cFilEnv, nOpc, nValor, cFunc, lRot941B, cErro941B )
	Local z1 := 0
	Local lGravou	:= .T.
	Local lContinua := .T.
	Local aAreaRA0  := RA0->(GetArea())
	Local cValFil   := ""
	Local aDados	:= {}
	Local aInfoFil	:= {}
	Local dDtGer	:= Date()
	Local cHrGer	:= Time()
	Local lAdmPubl	:= .F.
	Local cMsgErro	:= ""
	Local cTpInsc	:= ""
	Local cSeqId    := "00001"
	Local cStatOld	:= "-1"
	Local fName		:= "GPEM023"
	Local cKey		:= ""
	Local cChaveBus := ""
	Local cFunc		:= ""
	Local cVersEnvio:= ""
	Local cChvFil	:= ""
	Local lNT15		:= .F.
	Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
	Local lProcRAT	:= .F.
	Local lProcFAP	:= .F.
	Local lCNPJR        := RJ4->(ColumnPos("RJ4_CNPJR")) > 0

	Default nOpcO		:= 0
	Default nValor		:= 1
	Default lRot941B	:= .F.
	Default cErro941B	:= ""


	fVersEsoc( "S1005", .F., Nil, Nil, @cVersEnvio, , , @lNT15 )

	If cVersEnvio >= "9.0.00"
		If Len(aEstObras[nValor]) > 18 .And. If(lCNPJR, Len(aEstObras[nValor]) <= 22,Len(aEstObras[nValor]) <= 21)
			If aEstObras[nValor, 21] == "1"
				lProcRAT	:= .T.
			ElseIf aEstObras[nValor, 21] == "2"
				lProcFAP	:= .T.
			EndIf
		ElseIf Len(aEstObras[nValor]) > 18
			//Tem processo RAT
			If !Empty(aEstObras[nValor, 19]) .And. !Empty(aEstObras[nValor, 20]) .And. !Empty(aEstObras[nValor, 21])
				lProcRAT	:= .T.
			EndIf
			//Tem processo FAP
			If Len(aEstObras[nValor]) > 21 .And. Len(aEstObras[nValor]) > 22 .And. !Empty(aEstObras[nValor, 22]) .And. !Empty(aEstObras[nValor, 23]) .And. !Empty(aEstObras[nValor, 24])
				lProcFAP	:= .T.
			EndIf
		EndIf
	EndIf

	If lMIddleware
		aInfoFil := fXMLInfos()

		If Len(aInfoFil) >= 4
			cTpInsc  := aInfoFil[1]
			lAdmPubl := aInfoFil[4]
			cNrInsc  := aInfoFil[2]
			cId		 := aInfoFil[3]
		Else
			cTpInsc  := ""
			lAdmPubl := .F.
			cNrInsc  := "0"
			cId  	 := ""
		EndIf

		If IsInCallStack("GPEA934A")
			cChvFil := xFilial("RJ4", cFilEnv)
		ElseIf IsInCallStack("fIntExt005") .Or. IsInCallStack("fObraX14")
			cChvFil	:= cFilEnv
		Else
			cChvFil := xFilial("CTT", cFilEnv)
		EndIf
		cRetKey		:= cChvFil+aEstObras[nValor,2]+aEstObras[nValor,3]+dToS(dDtGer)+StrTran(cHrGer, ":", "")
		ckey		:= cChvFil+aEstObras[nValor,3]
		aDados 		:= {}

		aAdd( aDados, {cId,cRetKey,dDtGer,cHrGer,cTpInsc,cNrInsc,cKey,aEstObras[nValor,3], Substr(cMesAnoP,3,4)+Substr(cMesAnoP,1,2) })

		If FunName() == "GPEA320"
			cChaveBus := cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1005" + Padr(ckey, fTamRJEKey(), " ") + Substr(cMesAnoP,3,4)+Substr(cMesAnoP,1,2)
			GetInfRJE(2, cChaveBus,@cStatOld)

			If cStatOld == "2"
				aAdd( aErros, OemToAnsi(STR0240))//"O registro está em trânsito para o RET. Esta alteração não poderá ser realizada enquanto o envio não for concluído")
				lContinua := .F.
				// aDados, PADR(OemToAnsi(STR0025), 25) + " " + PADR(OemToAnsi(STR0086) + " " + aFilEnv[nI], 77) + " " + PADR(OemToAnsi(STR0245), 26) )
			ElseIf nOpc <> 5
				If cStatOld == "4"
					nOpc := 4
				ElseIf cStatOld $ "1|3|-1"
					nOpc := 3
				EndIf
			EndIf
		EndIf

	EndIf

	cXml := iif(lMiddleware, "<eSocial xmlns='http://www.esocial.gov.br/schema/evt/evtTabEstab/v" + cVersEnvio + "'>", '<eSocial>' )
	cXml += iif(lMiddleware, "	<evtTabEstab Id='" + cId + "'>", '	<evtTabEstab>' )
	If lMiddleware
		fXMLIdEve( @cXml, { Nil, Nil, Nil, Nil, 1, 1, "12" } )
		fXMLIdEmp( @cXml, { cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ) } )
	Endif
	cXml += '		<infoEstab>'

	If ( nOpc == 3 )
		cXml += '		<inclusao>'
	ElseIf ( nOpc == 4 )
		cXml += '		<alteracao>'
	ElseIf ( nOpc == 5 )
		cXml += '		<exclusao>'
	EndIf

	cXml += '				<ideEstab>'
	cXml += '					<tpInsc>' + aEstObras[nValor,2] + '</tpInsc>'
	cXml += '					<nrInsc>' + aEstObras[nValor, 3] + '</nrInsc>'
	cXml += '					<iniValid>' 	   + substr(cMesAnoP,3,4) + "-" + substr(cMesAnoP,1,2)	+ '</iniValid>'
	If !lMIddleware
		cXml += '					<fimValid>'	       + ''        				+ '</fimValid>'
	endif
	cXml += '				</ideEstab>'

	//Somente se for inclusão ou alteração, cria toda a estrutura abaixo
	If ( nOpc <> 5 )
		cXml += '			<dadosEstab>'
		cXml += '				<cnaePrep>' + AllTrim(fSubst(aEstObras[nValor,6])) + '</cnaePrep>'
		If cVersEnvio >= "9.0.00" .And. Alltrim( aEstObras[nValor, 2] ) == "4" .And. (Substr(cMesAnoP,3,4) + Substr(cMesAnoP,1,2) ) >= "202204"
			cXml += '				<cnpjResp>' + If(Len(aEstObras[nValor]) >= 25, Alltrim(aEstObras[nValor,25]),Alltrim(aEstObras[nValor,22])) + '</cnpjResp>'
		Endif
		If cVersEnvio < "9.0.00"
			cXml += '					<aliqGilrat>'
			cXml += '						<aliqRat>' + cValToChar(Int(aEstObras[nValor, 7])) + '</aliqRat>'

			If Alltrim( aEstObras[nValor, 2] ) $ "1|4"
				cXml += '						<fap>' + StrTran(Transform(aEstObras[nValor, 8], "@E 9.9999"), ",", ".") + '</fap>'
				cXml += '						<aliqRatAjust>' + StrTran(Transform(aEstObras[nValor, 9], "@E 9.9999"), ",", ".") + '</aliqRatAjust>'
			EndIf

			If Len(aEstObras[nValor]) > 18 .And. Len(aEstObras[nValor]) <= 21
				If aEstObras[nValor, 21] == "1"
					cXml += '					<procAdmJudRat>'
					cXml += '						<tpProc>' + AllTrim(aEstObras[nValor, 18]) + '</tpProc>'
					cXml += '						<nrProc>' + AllTrim(aEstObras[nValor, 19]) + '</nrProc>'
					cXml += '						<codSusp>' + AllTrim(aEstObras[nValor, 20]) + '</codSusp>'
					cXml += '					</procAdmJudRat>'
				EndIf

				If aEstObras[nValor, 21] == "2"
					cXml += '					<procAdmJudFap>'
					cXml += '						<tpProc>' + AllTrim(aEstObras[nValor, 18]) + '</tpProc>'
					cXml += '						<nrProc>' + AllTrim(aEstObras[nValor, 19]) + '</nrProc>'
					cXml += '						<codSusp>' + AllTrim(aEstObras[nValor, 20]) + '</codSusp>'
					cXml += '					</procAdmJudFap>'
				EndIf
			ElseIf Len(aEstObras[nValor]) > 18
				If !Empty(aEstObras[nValor, 19]) .And. !Empty(aEstObras[nValor, 20]) .And. !Empty(aEstObras[nValor, 21])
					cXml += '					<procAdmJudRat>'
					cXml += '						<tpProc>' + AllTrim(aEstObras[nValor, 19]) + '</tpProc>'
					cXml += '						<nrProc>' + AllTrim(aEstObras[nValor, 20]) + '</nrProc>'
					cXml += '						<codSusp>' + AllTrim(aEstObras[nValor, 21]) + '</codSusp>'
					cXml += '					</procAdmJudRat>'
				EndIf

				If Len(aEstObras[nValor]) > 21 .And. Len(aEstObras[nValor]) > 22 .And. !Empty(aEstObras[nValor, 22]) .And. !Empty(aEstObras[nValor, 23]) .And. !Empty(aEstObras[nValor, 24])
					cXml += '					<procAdmJudFap>'
					cXml += '						<tpProc>' + AllTrim(aEstObras[nValor, 22]) + '</tpProc>'
					cXml += '						<nrProc>' + AllTrim(aEstObras[nValor, 23]) + '</nrProc>'
					cXml += '						<codSusp>' + AllTrim(aEstObras[nValor, 24]) + '</codSusp>'
					cXml += '					</procAdmJudFap>'
				EndIf
			EndIf

			cXml += '					</aliqGilrat>'
		ElseIf cVersEnvio >= "9.0.00" .And. (lProcRAT .Or. lProcFAP)
			cXml += '					<aliqGilrat>'
			//Inclui a tag do RAT apenas se houver processo para o RAT.
			If lProcRAT
				cXml += '						<aliqRat>' + cValToChar(Int(aEstObras[nValor, 7])) + '</aliqRat>'
			EndIf

			If Alltrim( aEstObras[nValor, 2] ) == "4" .And. lProcFAP
				If ((Substr(cMesAnoP,3,4) + Substr(cMesAnoP,1,2) ) >= "202204" .And. If(Len(aEstObras[nValor]) >= 25, !Empty(aEstObras[nValor,25]), !Empty(aEstObras[nValor,22]))) .Or.;
					( If(Len(aEstObras[nValor]) >= 25, Empty(aEstObras[nValor,25]), Empty(aEstObras[nValor,22])) .And. Substr(cMesAnoP,3,4) + Substr(cMesAnoP,1,2) < "202204" )
					cXml += '				<fap>' + StrTran(Transform(aEstObras[nValor, 8], "@E 9.9999"), ",", ".") + '</fap>'
				Endif
			ElseIf Alltrim( aEstObras[nValor, 2] ) == "1" .And. lProcFAP    //Só gerar a TAG <fap> se o tipo de inscrição do estabelecimento for pessoa jurídica e CNPJR Não preenchido
				cXml += '				<fap>' + StrTran(Transform(aEstObras[nValor, 8], "@E 9.9999"), ",", ".") + '</fap>'
			Endif
			If Len(aEstObras[nValor]) > 18 .And. If(lCNPJR, Len(aEstObras[nValor]) <= 22,Len(aEstObras[nValor]) <= 21)
				If aEstObras[nValor, 21] == "1"
					cXml += '					<procAdmJudRat>'
					cXml += '						<tpProc>' + AllTrim(aEstObras[nValor, 18]) + '</tpProc>'
					cXml += '						<nrProc>' + AllTrim(aEstObras[nValor, 19]) + '</nrProc>'
					cXml += '						<codSusp>' + AllTrim(aEstObras[nValor, 20]) + '</codSusp>'
					cXml += '					</procAdmJudRat>'
				EndIf

				If aEstObras[nValor, 21] == "2"
					cXml += '					<procAdmJudFap>'
					cXml += '						<tpProc>' + AllTrim(aEstObras[nValor, 18]) + '</tpProc>'
					cXml += '						<nrProc>' + AllTrim(aEstObras[nValor, 19]) + '</nrProc>'
					cXml += '						<codSusp>' + AllTrim(aEstObras[nValor, 20]) + '</codSusp>'
					cXml += '					</procAdmJudFap>'
				EndIf
			ElseIf Len(aEstObras[nValor]) > 18
				If !Empty(aEstObras[nValor, 19]) .And. !Empty(aEstObras[nValor, 20]) .And. !Empty(aEstObras[nValor, 21])
					cXml += '					<procAdmJudRat>'
					cXml += '						<tpProc>' + AllTrim(aEstObras[nValor, 19]) + '</tpProc>'
					cXml += '						<nrProc>' + AllTrim(aEstObras[nValor, 20]) + '</nrProc>'
					cXml += '						<codSusp>' + AllTrim(aEstObras[nValor, 21]) + '</codSusp>'
					cXml += '					</procAdmJudRat>'
				EndIf

				If Len(aEstObras[nValor]) > 21 .And. Len(aEstObras[nValor]) > 22 .And.  !Empty(aEstObras[nValor, 22]) .And. !Empty(aEstObras[nValor, 23]) .And. !Empty(aEstObras[nValor, 24])
					cXml += '					<procAdmJudFap>'
					cXml += '						<tpProc>' + AllTrim(aEstObras[nValor, 22]) + '</tpProc>'
					cXml += '						<nrProc>' + AllTrim(aEstObras[nValor, 23]) + '</nrProc>'
					cXml += '						<codSusp>' + AllTrim(aEstObras[nValor, 24]) + '</codSusp>'
					cXml += '					</procAdmJudFap>'
				EndIf
			EndIf
			cXml += '					</aliqGilrat>'
		EndIf

		If !Empty(aEstObras[nValor, 2]) .And. aEstObras[nValor, 2] == "4"
			cXml += '				<infoObra>'
			cXml += '					<indSubstPatrObra>' + If(!Empty(aEstObras[nValor, 11]),aEstObras[nValor, 11],'2') + '</indSubstPatrObra>'
			cXml += '				</infoObra>'
		Endif

		If !lNT15 .Or. (!Empty(aEstObras[nValor, 12]) .Or. !Empty(aEstObras[nValor, 13])) .Or.;
		(cVersEnvio >= "9.0.00" .And. !empty(aEstObras[nValor, 14]))
			cXml += '					<infoTrab>'
			If  cVersEnvio < "9.0.00" .And. (!lNT15 .Or. !Empty(aEstObras[nValor, 12]) )
				cXml += '						<regPt>' + aEstObras[nValor, 12] + '</regPt>'
			EndIf
			If !lNT15 .Or. !Empty(aEstObras[nValor, 13]) .Or. (cVersEnvio >= "9.0.00" .And. !empty(aEstObras[nValor, 14]))
				cXml += '						<infoApr>'
				If cVersEnvio < "9.0.00"
					cXml += '							<contApr>' + aEstObras[nValor, 13]	+ '</contApr>'
				EndIf
				if !empty(aEstObras[nValor, 14])
					cXml += '							<nrProcJud>' + aEstObras[nValor, 14] + '</nrProcJud>'
				endif
				If !lNT15 .Or. aEstObras[nValor, 13] != "0" .And. !Empty(aEstObras[nValor, 15])  .And. cVersEnvio < "9.0.00"
					cXml += '						<contEntEd>' + Iif(!lMiddleware, aEstObras[nValor, 15], Iif(aEstObras[nValor, 15] == "1", 'S', 'N')) + '</contEntEd>'
				EndIf
				//Entidade Educativa
				If Val(aEstObras[nValor, 13]) > 0 .Or. cVersEnvio >= "9.0.00"
					DbSelectArea("RA0")
					RA0->(DbSetOrder(1))
					if Len(aEstEd) > 0 .OR. !lMIddleware .And. !lNT15
						cXml += '						<infoEntEduc>'
						For z1=1 To Len(aEstEd)
							If AllTrim(aEstEd[z1]) == AllTrim(aEstObras[nValor, 10])
								cValFil:= IIF(Empty(aEstObras[nValor, 1]),cFilEnv,aEstObras[nValor, 1])

								If RA0->(MsSeek(FwxFilial("RA0",cValFil) + aEstEd[z1,2]))
									If !Empty(RA0->RA0_CGC)
										cXml += '			<nrInsc>' + RA0->RA0_CGC + '</nrInsc>
									ElseIf !lNT15
										aAdd( aErros, StrTran(OemToAnsi(STR0215),"(#)","("+aEstEd[z1,2]+")"))
										lContinua:= .F.
									EndIf

								EndIf
							EndIf
						Next z1
						cXml += '						</infoEntEduc>'
					endif
				Endif
				cXml += '					</infoApr>'
			EndIf
			cXml += '				</infoTrab>'
		EndIf
		cXml += '			</dadosEstab>'
	EndIf

	If ( nOpc == 3 )
		cXml += '		</inclusao>'
	ElseIf ( nOpc == 4 )
		cXml += '		</alteracao>'
	ElseIf ( nOpc == 5 )
		cXml += '		</exclusao>'
	EndIf

	cXml += '		</infoEstab>'
	cXml += '	</evtTabEstab>'
	cXml += '</eSocial>'

	If lContinua
		if !lMiddleware
			//Enviar como parametro a filial do Protheus na posição 1 e o XML na posição 2
			aErros := TafPrepInt( cEmpAnt, cFilEnv, cXml, , "1", "S1005")
			GrvTxtArq(cXml, "S1005") // Geração do XML na System (Mediante o MV_XMLGPE)
		Else
			cFunc := "CTT"
			fGerarRJE(aEstObras, cMesAnoP, aEstEd, aErros, cFilEnv, nOpc, cXml, lContinua, aDados,cFunc,nValor)
			GrvTxtArq(cXml, "S1005") // Geração do XML na System (Mediante o MV_XMLGPE)
		EndIf
	Endif

	If Len( aErros ) > 0
		If !FunName() $ "GPEM023|GPEA320"
			if !lMiddleware
				FeSoc2Err( aErros[1], @cMsgErro , Iif( aErros[1]!='000026',1,2 ) )
				If !lRot941B
					Aviso(OemtoAnsi(STR0001), cMsgErro,{"Ok"},3) //"Integração - TAF"
				Else
					cErro941B := cMsgErro
				EndIf
			Else
				FeSoc2Err( aErros[1], @cMsgErro , Iif( aErros[1]!='000026',1,2 ) )
				If !lRot941B
					Aviso(OemtoAnsi(STR0264), cMsgErro,{"Ok"},3) //"Integração - TAF"
				Else
					cErro941B := cMsgErro
				EndIf
			EndIf
		Endif
		lGravou := .F.
	Endif

	RestArea(aAreaRA0)
	Return lGravou

	/*/{Protheus.doc}fBuscaCAEPF( aFilEnv, cCAEPF )
	Função responsável por pesquisar dentro da F0F se a filial é CAEPF ou simplesmente PF

	@author: 	Marcos.Coutinho
	@since:	03/01/2017
	@param: cFilEnv -> Filial de envio para consulta
	@param: cCAEPF -> Variavel passada por referencia (@) que armazenará o retorno do F0F_CAEPF
	@version: 	1.0
	/*/
Function fBuscaCAEPF( cFilEnv, cCAEPF, cTpCAEPF )
	Local lRet := .F.
	Local aArea	:= GetArea()

	Default cFilEnv := ""
	Default cCAEPF := ""
	Default cTpCAEPF := ""

	//Verifica se existe F0F e se possui conteudo
	If ChkFile("F0F")
		dbSelectArea( "F0F" )
		dbGoTop()
		lRet := F0F->(!EOF())
	Endif

	//Se existir F0F, pesquisa a filial lá dentro
	//Se existir, recupera o valor de F0F_CAEPF
	If lRet
		DbSelectArea("F0F")
		DbSetOrder(1)
		lRet := DbSeek(xFilial("F0F") + Alltrim(cFilEnv) )

		//Se existir na F0F e tiver os campos CAEPF e TPCAEPF for igual a Produtor Rural
		If lRet
			cCAEPF := F0F->F0F_CAEPF
			cTpCAEPF := F0F_TPCAEP

			If Empty(cCAEPF) .OR. !(cTpCAEPF $ "1|2")
				lRet := .F.
			EndIf

		Else
			lRet := .F.
		EndIf

	EndIf
	RestArea( aArea)
Return lRet

/*/{Protheus.doc} fBuscaOBRA
Função responsável por pesquisar dentro da F0F se a filial é de Empreitada Total ou Sub Empreitada
@type function
@author marcos.coutinho
@since 10/01/2018
@version 1.0
@param cFilEnv, character, Filial que está sendo enviada/processada
@param cCEIObra, character, Passado por referência e recebe o valor da tabela F0F (F0F_TPOBRA)
@return lRet - Se encontrou ou não a filial dentro da F0F
@example
lRet := fBuscaOBRA( cFilEnv, cCEIObra, cTpObra )
/*/
Function fBuscaOBRA( cFilEnv, cCEIObra, cTpObra )
	Local lRet			:= .F.
	Local aArea			:= GetArea()

	Default cFilEnv		:= ""
	Default cCEIObra	:= ""
	Default cTpObra		:= ""

	//Verifica se existe F0F e se possui conteudo
	If ChkFile("F0F")
		dbSelectArea( "F0F" )
		dbGoTop()
		lRet := F0F->(!EOF())
	Endif

	//Se existir F0F, pesquisa a filial lá dentro
	//Se existir, recupera o valor de F0F_CAEPF
	If lRet
		DbSelectArea("F0F")
		DbSetOrder(1)
		lRet := DbSeek(xFilial("F0F") + Alltrim(cFilEnv) )

		//Se existir
		If lRet
			cCEIObra := F0F->F0F_CNO
			cTpObra  := F0F->F0F_TPOBRA
			If Empty(cCEIObra) .OR. cTpObra $ " |2"
				lRet := .F.
			EndIf
			//Se não existir
		Else
			lRet := .F.
		EndIf
	EndIf
	RestArea( aArea)
Return lRet

/*/{Protheus.doc} fTratWre
Responsável pela montagem do where do código de filiais
@type function
@author Eduardo
@since 26/01/2018
@version 1.0
@param aFils, array, Posição 3 do array de filiais
@param cTab, String, Tabela a ser processada
@return cWhere, String, Where a ser devolvido.
/*/
Function fTratWre(aFil,cTab)
	Local cWhere    := ""
	Local nI        := 0

	Default aFIl	:= {}
	Default cTab    := "CTT"


	for nI:= 1 to Len(aFil[3])
		cWhere += xFilial(cTab,aFil[3][nI]) + "|"
	next nI

	If !Empty(cWhere)
		cWhere := FormatIn(Substr(cWhere,1,len(cWhere)-1),"|")
	Else
		cWhere:=FormatIn(aFil[2],"|")
	EndIf

Return cWhere

/*/{Protheus.doc} fCarga1020
Função responsável por organizar os registros para envio do evento S-1020 ao TAF, quando se utiliza o novo controle de obras/lotações, tabela RJ3
@type      	Function
@author   	Claudinei Soares
@since		27/03/2019
@version	1.0
@param		cMesAnoP	,	characters	, 	Data de Referência informada na carga inicial (MMAAAA).
@param		nOpcAP		, 	numeric		, 	Tipo de processamento da carga (Cargas Iniciais, Rel. Inconsistências, Limpar Dados, Exclusão em Lote)
@param		aLogProc	, 	array		, 	Log de processamento
@param		aDados		, 	array		, 	Dados do processamento
@param		aArrayFilP	, 	array		, 	Filial
@param		cVersEnvio	, 	characters	, 	Versão do leiaute considerada para o envio.
@return		Nil
/*/
Function fCarga1020(cMesAnoP, nOpcAP, aLogProc, aDados, aArrayFilP, cVersEnvio, cFiltro)

	//Characters
	Local cFilEnv		:= ""
	Local cMenIni     	:= ""
	Local cAliasRJ3		:= GetNextAlias()
	Local cQryWhere		:= "%(RJ3_FILIAL >= '"+ Space(TamSx3("RJ3_FILIAL")[1])+ "')%"
	Local cLotInsc		:= "02|03|04|05|06|07|08|09"
	Local cAnoMesP		:= ""
	Local cStatus 		:= "-1"
	Local cChaveTAF		:= ""
	Local cCodLot		:= ""
	Local cMsgLog		:= ""
	Local cFPAS			:= ""

	//Numeric
	Local nX			:= 0
	Local nOpcAux		:= 0
	Local nContErr		:= 0
	Local nContador		:= 0
	Local nHrInicio
	Local nTerc

	//Array
	Local aInfoFil    	:= {}
	Local aErros		:= {}
	Local aAuxErro		:= {}
	Local aS037			:= {}
	Local aConcat		:= {}
	Local aArea		 	:= GetArea()
	Local aAreaRJ3  	:= RJ3->(GetArea())

	//Logical
	Local lSemFilial	:= .F.
	Local lContinua		:= .F.

	Local cXml		 := ""
	Local cVersMid	 := ""
	Local cChave	 := ""
	Local cMsgRJE	 := ""
	Local cIni 		 := ""
	Local lAdmPubl	 := .F.
	Local aInfos	 := {}
	Local aDadosRJE	 := {}
	Local cFilEmp	 := ""
	Local lRet		 := .T.
	Local cRetKey	 := ""
	Local cRetfNew	 := ""
	Local cRetfRJE	 := ""
	Local cOperNew 	 := ""
	Local cOperRJE	 := "I"
	Local cStatNew	 := ""
	Local lNovoRJE	 := .F.
	Local nRecRJE  	 := 0
	Local lS1000 	 := .F.
	Local aSM0    	 := FWLoadSM0(.T.,,.T.)

	//Default
	Default cMesAnoP 	:= ""
	Default nOpcAP		:= 1
	Default aArrayFilP	:= {}
	Default cVersEnvio	:= "2.2"
	Default cFiltro		:= ""

	cAnoMesP  := SUBSTR(cMesAnoP,3) + SUBSTR(cMesAnoP,1,2)
	cFilEnv		:= aArrayFilP[2]

	//Se for exclusão em Lote
	If nOpcAP == 1
		nOpcAux := 3
	ElseIf nOpcAP == 5
		nOpcAux := 5
	EndIf

	//Tratamento para o modo de acesso das tabelas
	If FWModeAccess("RJ3", 1) == "C" .AND. FWModeAccess("RJ3", 2) == "C" .AND. FWModeAccess("RJ3", 3) == "C" //RJ3 compartilhada
		lSemFilial := .T.
	EndIf

	If !Empty(cFilEnv)

		fInfo(aInfoFil, cFilEnv, cEmpAnt)
		fInssEmp(cFilEnv,@aS037,.F.,cAnoMesP)

		If !Empty(cFiltro)
			cQryWhere 	:= StrTran(cQryWhere,"%","")
			cQryWhere 	:= "%"+cQryWhere+ " AND " + GPEParSQL(fPrepExpIn(cFiltro)) + "%"
		EndIf

		//Inicio de Operação
		nHrInicio := Seconds()

		//Busca informacoes RJ3 - Lotações eSocial
		BeginSql alias cAliasRJ3
			SELECT
				RJ3_FILIAL, RJ3_INI, RJ3_COD, RJ3_TPLOT, RJ3_TPINSC, RJ3_NINSCR, RJ3_FPAS, RJ3_TERC,
				RJ3_TPINCO,	RJ3_NINSCO, RJ3_TPINPR, RJ3_NINSPR
			FROM
				%table:RJ3% RJ3
			WHERE
				RJ3.%notDel% AND %exp:cQryWhere%
			ORDER BY
				RJ3.RJ3_FILIAL, RJ3.RJ3_COD
			EndSql
		dbSelectArea(cAliasRJ3)

		//Posiciona no inicio do arquivo
		(cAliasRJ3)->(dbGoTop())

		If !lWorkFlow
			//Inicializa regua de processamento
			ProcRegua((cAliasRJ3)->(RecCount()))
		EndIf
		While (cAliasRJ3)->(!EOF())
			//Verifica filiais
			If lSemFilial //Compartilhada
				lContinua := .T.
			ElseIf aScan(aArrayFilP[3], {|X| Alltrim(FwxFilial("RJ3", X)) == Alltrim((cAliasRJ3)->RJ3_FILIAL)}) > 0	//Exclusiva
				lContinua := .T.
			Else
				lContinua := .F.
			EndIf

 			If lContinua .and. cAnoMesP >= (cAliasRJ3)->RJ3_INI

				cCodLot := IIf(lSemFilial,(cAliasRJ3)->RJ3_COD, (cAliasRJ3)->RJ3_FILIAL+(cAliasRJ3)->RJ3_COD)
				aAuxErro := {}

				//--------------------------------
				//| Realizando a geração da carga
				//--------------------------------
	 			If nOpcAP == 1 .OR. nOpcAP == 5
					RJ3->(dbSetOrder(2))
					RJ3->(MsSeek((cAliasRJ3)->RJ3_FILIAL + (cAliasRJ3)->RJ3_COD))

					//Se for Exclusão em Lote
					If nOpcAP == 5

						If Empty(cMesAnoP)
							cMesAnoP := Month2Str(dDatabase)+Year2Str(dDatabase)
						EndIf
						If !lMiddleware
							cChaveTAF := cCodLot + ";" + cMesAnoP + ";1"
							nOpcAux := fVerExtemp( "S-1020", cChaveTAF, nOpcAux, @cStatus, lContinua, cFilEnv, @aErros )

							//Se status 2 ou 4 -> Segue o fluxo | Se for diferente, aborta processo
							If nOpcAP == 5
								If ( cStatus $ " |1|3|-1" )
									(cAliasRJ3)->(dbSkip())
									nOpcAux := 5 //Reinicio o valor da nOpcAux que foi alterada na chamada da função fVerExtemp
									Loop
								EndIf
							EndIf
						Endif
					Endif

	    			lContinua := fGp23Inco(aLogProc, 6, "RJ3", @cMsgLog, .F., aAuxErro)

    				If lContinua
						If !Empty((cAliasRJ3)->RJ3_TPLOT) .Or. (((cAliasRJ3)->RJ3_TPLOT $ "02|03|04|05|06|07|08|09" .And. !Empty((cAliasRJ3)->RJ3_TPINSC) .And. !Empty((cAliasRJ3)->RJ3_NINSCR)))
							If lMiddleware
								cIni := SubStr(cMesAnoP,3,4)+SubStr(cMesAnoP,1,2)
								fVersEsoc("S-1020", .F., /*@aRetGPE*/, /*@aRetTAF*/, ,,@cVersMid)
								// verificar os predecessores - evento S1000
								cStatus := "-1"
								lS1000 := fVld1000( cIni, @cStatus )
								/*
									* 1 - Não enviado - Gravar por cima do registro encontrado
									* 2 - Enviado - Aguarda Retorno - Enviar mensagem em tela e não continuar com o processo
									* 3 - Retorno com Erro - Gravar por cima do registro encontrado
									* 4 - Retorno com Sucesso -?Efetivar a gravação
								*/
								If lS1000 .Or. cEFDAviso $ "0/2"
									aInfos   := fXMLInfos()

									IF Len(aInfos) >= 4
										cTpInsc  := aInfos[1]
										lAdmPubl := aInfos[4]
										cNrInsc  := aInfos[2]
									Else
										cTpInsc  := ""
										lAdmPubl := .F.
										cNrInsc  := "0"
									EndIf

									If ( nFilEmp := aScan(aSM0, { |x| x[1] == cEmpAnt .And. X[18] == cNrInsc }) ) > 0
										cFilEmp := aSM0[nFilEmp, 2]
									Else
										cFilEmp := cFilAnt
									EndIf

									// verifica se ja existe o evento s1035 na base de dados
									cChave 	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S1020" + Padr(cCodLot, fTamRJEKey(), " ") + cIni
									cStatus := "-1"
									//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
									GetInfRJE( 2, cChave, @cStatus, @cOperRJE, @cRetfRJE, @nRecRJE )

									//Alteração ou exclusão
									If nOpcAux == 4 .Or. nOpcAux == 5
										//Retorno pendente impede o cadastro
										If cStatus == "2"
											cMsgRJE 	:= STR0246//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
											lRet		:= .F.
										//ALTERACAO
										ElseIf nOpcAux == 4 .AND. cStatus <> "2"
											//Evento de exclusão sem transmissão impede o cadastro
											If cOperRJE == "E" .And. cStatus != "4"
												cMsgRJE 	:= STR0247//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
												lRet		:= .F.
											//Não existe na fila, será tratado como inclusão
											ElseIf cStatus == "-1"
												nOpcAux		:= 3
												cOperNew 	:= "I"
												cRetfNew	:= "1"
												cStatNew	:= "1"
												lNovoRJE	:= .T.
											//Evento sem transmissão, irá sobrescrever o registro na fila
											ElseIf cStatus $ "1/3"
												If cOperRJE == "A"
													nOpcAux	:= 4
												EndIf
												cOperNew 	:= cOperRJE
												cRetfNew	:= cRetfRJE
												cStatNew	:= "1"
												lNovoRJE	:= .F.
											//Evento diferente de exclusão transmitido, irá gerar uma retificação
											ElseIf cOperRJE != "E" .And. cStatus == "4"
												nOpcAux		:= 4
												cOperNew 	:= "A"
												cRetfNew	:= "2"
												cStatNew	:= "1"
												lNovoRJE	:= .T.
											//Evento de exclusão transmitido, será tratado como inclusão
											ElseIf cOperRJE == "E" .And. cStatus == "4"
												nOpcAux 	:= 3
												cOperNew 	:= "I"
												cRetfNew	:= "1"
												cStatNew	:= "1"
												lNovoRJE	:= .T.
											EndIf
										//Exclusão
										ElseIf nOpcAux == 5
											nOpcAux 		:= 5
											//Evento de exclusão sem transmissão impede o cadastro
											If cOperRJE == "E" .And. cStatus != "4"
												cMsgRJE 	:= STR0247//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
												lRet		:= .F.
											//Evento diferente de exclusão transmitido irá gerar uma exclusão
											ElseIf cOperRJE != "E" .And. cStatus == "4"
												cOperNew 	:= "E"
												cRetfNew	:= cRetfRJE
												cStatNew	:= "1"
												lNovoRJE	:= .T.
											EndIf
										EndIf
									ElseIf nOpcAux == 3
										//Retorno pendente impede o cadastro
										If cStatus == "2"
											cMsgRJE 	:= STR0246//"Operação não será realizada pois o evento foi transmitido, mas o retorno está pendente"
											lRet		:= .F.
										//Evento de exclusão sem transmissão impede o cadastro
										ElseIf cOperRJE == "E" .And. cStatus != "4"
											cMsgRJE 	:= STR0247//"Operação não será realizada pois há evento de exclusão que não foi transmitido ou com retorno pendente"
											lRet		:= .F.
										//Evento sem transmissão, irá sobrescrever o registro na fila
										ElseIf cStatus $ "1/3"
											nOpcAux		:= Iif( cOperRJE == "I", 3, 4 )
											cOperNew 	:= cOperRJE
											cRetfNew	:= cRetfRJE
											cStatNew	:= "1"
											lNovoRJE	:= .F.
										//Evento diferente de exclusão transmitido, irá gerar uma retificação
										ElseIf cOperRJE != "E" .And. cStatus == "4"
											nOpcAux		:= 4
											cOperNew 	:= "A"
											cRetfNew	:= "2"
											cStatNew	:=  "1"
											lNovoRJE	:= .T.
										//Será tratado como inclusão
										Else
											cOperNew 	:= "I"
											cRetfNew	:= "1"
											cStatNew	:= "1"
											lNovoRJE	:= .T.
										EndIf
									EndIf

									If !lRet
										aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 60) + " " + PADR(OemToAnsi(STR0256), 26) )//"Não enviada ao Middleware."
										aAdd( aDados, cMsgRJE )
										nContErr++
										(cAliasRJ3)->(dbSkip())
										Loop
									EndIf
								EndIf
								If !lS1000 .And. cEFDAviso != "2"
									lret := .F.
									cMsgRJE := STR0248//"Problemas com evento S1020"
									Do Case
										Case cStatus == "-1" // nao encontrado na base de dados
											cMsgRJE := STR0249 //"Registro do evento S-1000 não localizado na base de dados"
										Case cStatus == "1" // nao enviado para o governo
											cMsgRJE := STR0250 //"Registro do evento S-1000 não transmitido para o governo"
										Case cStatus == "2" // enviado e aguardando retorno do governo
											cMsgRJE := STR0251 //"Registro do evento S-1000 aguardando retorno do governo"
										Case cStatus == "3" // enviado e retornado com erro
											cMsgRJE := STR0252 //"Registro do evento S-1000 retornado com erro do governo"
									Endcase

									// Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
									If cEFDAviso == "1"
										aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 60) + " " + PADR(OemToAnsi(STR0256), 26) )//"Não enviada ao Middleware."
									EndIf
									aAdd( aDados, cMsgRJE )
									If cEFDAviso == "1"
										nContErr++
										(cAliasRJ3)->(dbSkip())
										Loop
									EndIf
								EndIf
							EndIf
							cFPAS:=(cAliasRJ3)->RJ3_FPAS
							nTerc:=(cAliasRJ3)->RJ3_TERC

							If (cAliasRJ3)->RJ3_TPLOT $ "01"
								If Empty(cFPAS)
									cFPAS := AllTrim(Str(Val(aInfoFil[17])))
								EndIf
								If Empty(nTerc)
									If !Empty(cCodTerc)
										nTerc := CVALTOCHAR(cCodTerc)
									Else
										nTerc := aX14[25,1]
									EndIf
								EndIf
							Endif

							Begin Transaction
								lRet := fCarrLot( cCodLot, cMesAnoP, (cAliasRJ3)->RJ3_TPLOT, cLotInsc, (cAliasRJ3)->RJ3_TPINSC, (cAliasRJ3)->RJ3_NINSCR, cFPAS, nTerc, (cAliasRJ3)->RJ3_TPINCO, (cAliasRJ3)->RJ3_NINSCO, (cAliasRJ3)->RJ3_TPINPR, (cAliasRJ3)->RJ3_NINSPR, nOpcAux, @aErros, cFilEnv, .F., @cXml, cVersMid, @cRetKey )
								If lMiddleware
									aDadosRJE := {}
									aAdd( aDadosRJE, { xFilial("RJE", cFilAnt), xFilial("RJ3", cFilEmp), cTpInsc, Iif( cTpInsc == "1" .And. !lAdmPubl, SubStr(cNrInsc, 1, 8), cNrInsc ), "S1020", cIni, cCodLot, cRetKey, cRetfNew, "12", cStatNew, Date(), Time(), cOperNew } )

									//Se não for uma exclusão de registro não transmitido, cria/atualiza registro na fila
									If !( nOpcAux == 5 .And. ((cOperRJE == "E" .And. cStatus == "4") .Or. cStatus $ "-1/1/3") )
										If !( lRet := fGravaRJE( aDadosRJE, cXml, lNovoRJE, nRecRJE ) )
											cMsgRJE := STR0253//"Ocorreu um erro na gravação do registro na tabela RJE"
										EndIf
									//Se for uma exclusão e não for de registro de exclusão transmitido, exclui registro de exclusão na fila
									ElseIf nOpcAux == 5 .And. cStatus != "-1" .And. !(cOperRJE == "E" .And. cStatus == "4")
										If !( lRet := fExcluiRJE( nRecRJE ) )
											cMsgRJE := STR0254//"Ocorreu um erro na exclusão do registro na tabela RJE"
										EndIf
									EndIf
								EndIf

								If (!lMiddleware .And. Len( aErros ) <= 0) .Or. (lMiddleware .And. Empty(cMsgRJE))
									//--------------------------------------------------------------
									//| Os erros serão impressos alinhados | Tamanho cabecalho: 132
									//| Colunas: Eventos (25+1) | Item/Registro (77+1) | Status (26)
									//| PADR("Eventos", 25) + " " + PADR("ITEM/REGISTRO", 77) + " " + PADR("STATUS", 26))
									//------------------------------------------------------------------------------------------------------------------------------------
									//Lotacao                   XYZABC1230                                                                    Enviada ao TAF com sucesso."
									If FunName() <> "GPEA320" .Or. (FunName() == "GPEA320" .And. cCodigo == "S038")
										If !lMiddleware
											aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 77) + " " + PADR(OemToAnsi(STR0030), 26) )
										Else
											aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 60) + " " + PADR(OemToAnsi(STR0265), 36) )//"Enviado ao Middleware com sucesso."
										EndIf
									EndIf
									nContador++
								Else
									If !lMiddleware
										aConcat := {}
									EndIf

									//Le o erro e quebra num array de acordo com a quantidade de enter
									aConcat := FWTxt2Array( aErros[1], 125)//StrTokArr(, chr(13)+chr(10))

									//Adiciona cabeçalho do erro (Lotação: XYS - Não enviado ao TAF)
									//Lotacao                   XYZABC1230                                                                    Nâo Enviada ao TAF         "
									If !lMiddleware
										aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 77) + " " + PADR(OemToAnsi(STR0029), 26) )
									Else
										aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 77) + " " + PADR(OemToAnsi(STR0029), 26) )
									EndIf
									nContErr++

									//Atribui o erro no aDados para impressão em tela
									For nX := 1 To len(aConcat)
										If(!Empty(aConcat[nX]), aAdd( aDados, aConcat[nX] ), )
									Next
									If lMiddleware
										aAdd( aDados, cMsgRJE )
									EndIf
									aAdd( aDados, "" )
								EndIf

								If !lWorkFlow
									//Incrementa regua
									IncProc(OemToAnsi(STR0069) + " " + cCodLot )
								EndIf
							End Transaction
			    		Else

	   						//Lotacao                   XYZABC1230                                                                    Nâo Enviada ao TAF         "
	   						If !lMiddleware
							   aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 77) + " " + PADR(OemToAnsi(STR0029), 26) )
							Else
							   aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 60) + " " + PADR(OemToAnsi(STR0256), 26) )//"Não enviada ao Middleware."
							EndIf
	    					If( Empty((cAliasRJ3)->RJ3_TPLOT) )
	    						aAdd(aDados, OemToAnsi(STR0163) ) //"Campo Vazio: O Campo RJ3_TPLOT deve ser preenchido"
	    					ElseIf( (cAliasRJ3)->RJ3_TPLOT $ "02|03|04|05|06|07|08|09" .And. !Empty((cAliasRJ3)->RJ3_TPINSC) .AND. !Empty((cAliasRJ3)->RJ3_NINSCR) )
	    						aAdd(aDados, OemToAnsi(STR0230) ) //"Dados Inválidos: Se o campo RJ3_TPLOT for igual a '02|03|04|05|06|07|08|09', os campos RJ3_TPINSC e RJ3_NINSCR não podem ser preenchidos."
	    					EndIf
	    					aAdd(aDados, "" )
			    		EndIf
    				Else
    					If( !lContinua )
	   						//Lotacao                   XYZABC1230                                                                    Nâo Enviada ao TAF         "
	   						If !lMiddleware
							   aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 77) + " " + PADR(OemToAnsi(STR0029), 26) )
							Else
							   aAdd( aDados, PADR(OemToAnsi(STR0052), 25) + " " + PADR(cCodLot, 60) + " " + PADR(OemToAnsi(STR0256), 26) )//"Não enviada ao Middleware."
							EndIf
							For nX := 1 To Len( aAuxErro )
								aAdd(aDados, aAuxErro[nX])
							Next
    					EndIF
    					//Pula Linha
						aAdd(aDados, "")
						nContErr++
    				EndIf

				//------------------------------------
				//| Realizando a geração do Relatório
				//------------------------------------
				Else
					If (((cAliasRJ3)->RJ3_TPLOT $ "02|03|04|05|06|07|08|09" .AND. (Empty((cAliasRJ3)->RJ3_TPINSC) .OR. Empty((cAliasRJ3)->RJ3_NINSCR)))) .OR. Empty((cAliasRJ3)->RJ3_TPLOT)

						If Empty(cMenIni)
							cMenIni := OemToAnsi(STR0051) //##"Inconsistências de Lotações - Os campos abaixo estão vazios e são de preenchimento obrigatórios:"

							aAdd(aLogProc, cMenIni)
							aAdd(aLogProc, "")
							aAdd(aLogProc, "")
						EndIf

						//Mensagem de log que sera gravado
						cMsgLog := OemToAnsi(STR0052) //##"Lotação"

						//Verifica inconsistencias
						/*
						ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³ Posiciona na tabela RJ3 - Fisica                    	 	   ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
						RJ3->(dbSetOrder(2))
						RJ3->(MsSeek((cAliasRJ3)->RJ3_FILIAL + (cAliasRJ3)->RJ3_COD))

						//Mensagem de log
			 			cMsgLog += " " + (cAliasRJ3)->RJ3_COD + " - " + OemToAnsi(STR0125) + ": " //##"Preenchimento de campos obrigatórios"

						//Busca campos incosistentes
						fGp23Inco(aLogProc, 6, "RJ3", @cMsgLog, .F.)

						//Incrementa regua
						IncProc(OemToAnsi(STR0069) + " " + cCodLot ) //## "Gerando o registro de: "
					EndIf
				EndIf
			EndIf
			(cAliasRJ3)->(dbSkip())
		EndDo
	EndIf

	//Fecha alias em uso
	If (Select(cAliasRJ3) > 0)
		(cAliasRJ3)->(dbCloseArea())
	EndIf

	RestArea(aAreaRJ3)
	RestArea(aArea)

Return()

/*/{Protheus.doc} fCarga1005
Função responsável por organizar os registros para envio do evento S-1005 ao TAF, quando se utiliza o novo controle de obras prórpias, tabela RJ4
@type      	Function
@author   	Claudinei Soares
@since		29/03/2019
@version	1.0
@param		cMesAno	,	characters	, 	Data de Referência informada na carga inicial (MMAAAA).
@param		nOpcAP		, 	numeric		, 	Tipo de processamento da carga (Cargas Iniciais, Rel. Inconsistências, Limpar Dados, Exclusão em Lote)
@param		aLogProc	, 	array		, 	Log de processamento
@param		aDados		, 	array		, 	Dados do processamento
@param		aArrayFilP	, 	array		, 	Filial
@param		cVersEnvio	, 	characters	, 	Versão do leiaute considerada para o envio.
@return		Nil
/*/
Function fCarga1005(cMesAnoP, nOpcAP, aLogProc, aDados, aArrayFilP, cVersEnvio, cFiltro)

	//Characters
	Local cAliasRJ4  	:= GetNextAlias()
	Local cQryWhere		:= "%"
	Local cCnae			:= ""
	Local cSubPat		:= ""
	Local cChave        := ""
	Local cStatus       := ""
	Local cFilEnv		:= ""
	Local cTpReg 		:= ""
	Local cTpApr 		:= ""
	Local cNrApr 		:= ""
	Local cTpEEn 		:= ""
	Local cAnoMesP		:= ""
	Local cTpProcRAT	:= ""
	Local cNrProcRAT	:= ""
	Local cCodSuspRAT	:= ""
	Local cTpProcFAP	:= ""
	Local cNrProcFAP	:= ""
	Local cCodSuspFAP	:= ""

	//Numeric
	Local nOpcao        := 0
	Local nOpcAux		:= 3
	Local nI          	:= 0
	Local nValor		:= 0
	Local nCont			:= 0
	Local nContErr		:= 0
	Local nContador		:= 0

	//Logical
	Local lRJ4Comp		:= .F.
	Local lContinua		:= .T.
	Local lSemFilial 	:= .F.

	//Array
	Local aEstObras   	:= {}
	Local aErros		:= {}
	Local aLogCNPJ    	:= {}
	Local aEstEd		:= {}
	Local aAreaRJ4  	:= RJ4->(GetArea())
	Local aArea			:= GetArea()
	Local lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
	Local lCposRatFap	:= fVldCps()
	Local cCNPJR		:= ""
	Local cCposQuery	:= ""
	Local lCNPJR        := RJ4->(ColumnPos("RJ4_CNPJR")) > 0

	//Defaults
	default cMesAnoP	:= ""
	default nOpcAP		:= 1
	default aArrayFilP	:= {}
	Default cVersEnvio	:= "2.2"
	Default cFiltro		:= ""


	//Se for exclusão em Lote
	If nOpcAP == 5
		nOpcAux := 5
	EndIf

	nOpcao := nOpcAux

	cAnoMesP  := SUBSTR(cMesAnoP,3) + SUBSTR(cMesAnoP,1,2)

	cFilEnv		:= aArrayFilP[2]
	lConsolid	:= aArrayFilP[1]
	aFilEnv		:= aArrayFilP[3]

	//Tratamento de compartilhamento da tabela RJ4
	If FWModeAccess("RJ4", 1) == "C" .AND. FWModeAccess("RJ4", 2) == "C" .AND. FWModeAccess("RJ4", 3) == "C" //RJ4 compartilhada
		lSemFilial := .T.
	EndIf

	cQryWhere:= "%(RJ4_FILIAL in " + fTratWre(aArrayFilP,"RJ4") + ")%"
	If !Empty(cFiltro)
		cQryWhere 	:= StrTran(cQryWhere,"%","")
		cQryWhere 	:= "%"+cQryWhere+ " AND " + GPEParSQL(fPrepExpIn(cFiltro)) + "%"
	EndIf

	nHrInicio := Seconds()

	If lCposRatFap
		If !lCNPJR
			cCposQuery 	:= "%RJ4_FILIAL, RJ4_INI, RJ4_TPINSC, RJ4_NINSCR, RJ4_CNAE, RJ4_RAT, RJ4_FAP, RJ4_RAJU, RJ4_TPC, RJ4_ISC, "
			cCposQuery 	+=	"RJ4_PON, RJ4_APR, RJ4_PRC, RJ4_EED, RJ4_TPRAT, RJ4_NPRAT, RJ4_SURAT, RJ4_TPFAP, RJ4_NPFAP, RJ4_SUFAP%"
		else
			cCposQuery 	:= "%RJ4_FILIAL, RJ4_INI, RJ4_TPINSC, RJ4_NINSCR, RJ4_CNAE, RJ4_RAT, RJ4_FAP, RJ4_RAJU, RJ4_TPC, RJ4_ISC, "
			cCposQuery 	+=	"RJ4_PON, RJ4_APR, RJ4_PRC, RJ4_EED, RJ4_TPRAT, RJ4_NPRAT, RJ4_SURAT, RJ4_TPFAP, RJ4_NPFAP, RJ4_SUFAP, RJ4_CNPJR%"
		Endif

		BeginSql alias cAliasRJ4
			SELECT %exp:cCposQuery%
			FROM
			%table:RJ4% RJ4
			WHERE
			RJ4.%notDel% AND %exp:cQryWhere%
			ORDER BY
			RJ4.RJ4_FILIAL
		EndSql
	Else
		BeginSql alias cAliasRJ4
			SELECT
			RJ4_FILIAL, RJ4_INI, RJ4_TPINSC, RJ4_NINSCR, RJ4_CNAE, RJ4_RAT, RJ4_FAP, RJ4_RAJU,
			RJ4_TPC, RJ4_ISC, RJ4_PON, RJ4_APR, RJ4_PRC, RJ4_EED
			FROM
			%table:RJ4% RJ4
			WHERE
			RJ4.%notDel% AND %exp:cQryWhere%
			ORDER BY
			RJ4.RJ4_FILIAL
		EndSql
	EndIf

	dbSelectArea(cAliasRJ4)


	(cAliasRJ4)->(dbGoTop()) //Posiciona no inicio do arquivo
	aEstObras := {}

	While (cAliasRJ4)->(!EOF())

		//Reseta valor para o padrão da tela
		nOpcAux := nOpcao

		If lSemFilial //Compartilhada
			lContinua := .T.
		ElseIf aScan(aArrayFilP[3], {|X| FwxFilial("RJ4", X) == (cAliasRJ4)->RJ4_FILIAL}) > 0 //Exclusiva
			lContinua := .T.
		Else
			lContinua := .F.
		EndIf

		If  lContinua .And. cAnoMesP >= (cAliasRJ4)->RJ4_INI

			cTpReg		:= (cAliasRJ4)->RJ4_PON
			cTpApr		:= (cAliasRJ4)->RJ4_APR
			cNrApr		:= (cAliasRJ4)->RJ4_PRC
			cTpEEn		:= (cAliasRJ4)->RJ4_EED
			cTpProcRAT	:= Iif(lCposRatFap, (cAliasRJ4)->RJ4_TPRAT, "")
			cNrProcRAT	:= Iif(lCposRatFap, (cAliasRJ4)->RJ4_NPRAT, "")
			cCodSuspRAT	:= Iif(lCposRatFap, (cAliasRJ4)->RJ4_SURAT, "")
			cTpProcFAP	:= Iif(lCposRatFap, (cAliasRJ4)->RJ4_TPFAP, "")
			cNrProcFAP	:= Iif(lCposRatFap, (cAliasRJ4)->RJ4_NPFAP, "")
			cCodSuspFAP	:= Iif(lCposRatFap, (cAliasRJ4)->RJ4_SUFAP, "")
			If lCNPJR
				cCNPJR	:= (cAliasRJ4)->RJ4_CNPJR
			Endif

			//Tratamento para remover caracteres do campo CNAE
			cCnae := AllTrim(StrTran(StrTran((cAliasRJ4)->RJ4_CNAE, "-",""), "/",""))

			//Busca informacao SubPatronal
			cSubPat := ""

			If (cAliasRJ4)->RJ4_TPINSC == "4"
				cSubPat := (cAliasRJ4)->RJ4_ISC
			EndIf

			nRat      :=  (cAliasRJ4)->RJ4_RAT
			nFap      :=  (cAliasRJ4)->RJ4_FAP

			cChave := (cAliasRJ4)->RJ4_TPINSC + ";" + (cAliasRJ4)->RJ4_NINSCR + ";" + cMesAnoP

			If FindFunction("fGetEntEdu") .And. cTpEEn == "1"
				fGetEntEdu((cAliasRJ4)->RJ4_FILIAL, (cAliasRJ4)->RJ4_TPINSC, (cAliasRJ4)->RJ4_NINSCR, @aEstEd )
			Endif

			If !lMiddleware
				If nOpcAux == 5
					nOpcAux := fVerExtemp( "S-1005", cChave, nOpcAux, @cStatus, lContinua, cFilEnv, @aErros )

					If nOpcAP == 5
						If ( cStatus $ " |1|3|-1" )
							(cAliasRJ4)->(dbSkip())
							Loop
						EndIf
					Endif

				EndIf
			Endif

			//Adiciona Obras
			Aadd(aEstObras, {	(cAliasRJ4)->RJ4_FILIAL		, ;	//01 Filial
								(cAliasRJ4)->RJ4_TPINSC		, ;	//02 TIPO2 / Tipo Inscrição
								(cAliasRJ4)->RJ4_NINSCR		, ;	//03 CEI2  / Num Inscrição
								""							, ;	//04 FPAS
								""							, ;	//05 Cod. Terceiro
								cCnae						, ;	//06 CNAE
								Round(nRat, 0)				, ;	//07 RAT
								nFAP						, ;	//08 FAP
								0							, ;	//09 % Acidente de Trabalho
								(cAliasRJ4)->RJ4_NINSCR		, ;	//10 Número da Inscrição (Utilizado para buscar a entidade educativa, na )
								cSubPat						, ;	//11 Subst. Contrib. Patronal
								cTpReg						, ;	//12 Tipo de Ponto
								cTpApr						, ;	//13 Contrata Aprendiz
								cNrApr						, ;	//14 Número do Processo Aprendiz
								cTpEEn						, ;	//15 Tipo de Entidade Educativa
								cMesAnoP					, ;	//16 Mes Ano
								nOpcAux						, ;	//17 nOpc
								(cAliasRJ4)->RJ4_INI	 	, ;	//18 Data Inicial(MMAAAA)
								cTpProcRAT					, ;	//19 Tipo do Processo (1-Administrativo,2-Judicial)
								cNrProcRAT					, ;	//20 Número do Processo
								cCodSuspRAT					, ;	//21 Código do Indicativo da Suspensão
								cTpProcFAP					, ;	//22 Tipo do Processo (1-Administrativo, 2-Judicial, 4-Processo FAP)
								cNrProcFAP					, ;	//23 Número do Processo
								cCodSuspFAP					, ;	//24 Código do Indicativo da Suspensão
								cCNPJR						} )	//25 CNPJ Responsavel
		EndIf
		(cAliasRJ4)->(dbSkip())
	EndDo

	If !lWorkFlow
		//Inicializa regua de processamento
		ProcRegua(Len(aEstObras))
	EndIf

	//Verifica as obras de Centro de Custo
	For nI := 1 To Len(aEstObras)
		//--------------
		//| Gerar Carga
		//--------------
		If nOpcAP == 1 .OR. nOpcAP == 5
			If !Empty(aEstObras[nI, 2]) .And. !Empty(aEstObras[nI, 3]) .And. !Empty(aEstObras[nI, 13]) .and.;
			!Empty(aEstObras[nI, 6]) .and. !Empty(aEstObras[nI, 12]) .And.;
			fGp23VlFil(nI, aEstObras, aLogCNPJ, nOpcAP, lSemFilial, lConsolid, 1)

				nValor := nI

				lRet := fCarrCTT(aEstObras, cMesAnoP, aEstEd, @aErros, cFilEnv, nOpcAux, nValor)

				If Len( aErros ) <= 0
					//--------------------------------------------------------------
					//| Os erros serão impressos alinhados | Tamanho cabecalho: 132
					//| Colunas: Eventos (25+1) | Item/Registro (77+1) | Status (26)
					//| PADR("Eventos", 25) + " " + PADR("ITEM/REGISTRO", 77) + " " + PADR("STATUS", 26))
					//------------------------------------------------------------------------------------------------------------------------------------
					//Estabelecimentos/Obras    XYZABC1230 123456789-0001 456487877787                                        Enviada ao TAF com sucesso."
					If( Empty( aEstObras[nI ,1] ) )
						aAdd( aDados, PADR(OemToAnsi(STR0025), 25) + " " +  PADR(aEstObras[nI, 3], 77) + " " + If(!lMiddleware,PADR(OemToAnsi(STR0030), 26),PADR(OemToAnsi(STR0255), 26)) )
					Else
						aAdd( aDados, PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI ,1]+ aEstObras[nI, 3], 77) + " " + If(!lMiddleware,PADR(OemToAnsi(STR0030), 26),PADR(OemToAnsi(STR0255), 26)) )
					EndIf

					//Se o percentual RAT estiver vazio, permite a carga mas avisa.
					If aEstObras[nI, 7] == 0
						aAdd( aDados, "" )
						aAdd( aDados,  SUBSTR(OemToAnsi(STR0060),43,76) ) // Os campos abaixo estão vazios ou zerados e são de preenchimento obrigatório:

						//Campo percentual RAT zerado
						If aEstObras[nI, 7] == 0
							aAdd(aDados,   SUBSTR(OemToAnsi(STR0234),9,10)  + " - " + OemToAnsi(STR0136)) // RJ4_PERRAT Aliquota RAT
						EndIf

						aAdd( aDados,  OemToAnsi(STR0214) ) //A menos que exista um processo permitindo os valores zerados para esse(s) campo(s), por este motivo a carga será realizada.
						aAdd( aDados, "" )
					Endif

					nContador++
				Else
					//Estabelecimentos/Obras    XYZABC1230                                                                    Nâo Enviada ao TAF         "
					If( Empty( aEstObras[nI ,1] ) )
						aAdd( aDados, PADR(OemToAnsi(STR0025), 25) + " " +  PADR(aEstObras[nI, 3], 77) + " " + If(!lMiddleware,PADR(OemToAnsi(STR0029), 26),PADR(OemToAnsi(STR0256), 26)) )
					Else
						aAdd( aDados, PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI ,1]+  aEstObras[nI, 3], 77) + " " + If(!lMiddleware,PADR(OemToAnsi(STR0029), 26),PADR(OemToAnsi(STR0256), 26)) )
					EndIf

					//Varrendo array de erro para envio de msg para log
					cResumo := ""
					for nCont:= 1 to len(aErros)
						cResumo += aErros[nCont]
					next

					aResumo := FWTxt2Array( cResumo, 125)
					For nCont := 1 To Len(aResumo)
						aAdd( aDados, aResumo[nCont] )
					Next

					AaDD( aDados, "" )
					nContErr++
				EndIf

				If !lWorkFlow
					//Incrementa regua
					IncProc(OemToAnsi(STR0069) + " " + aEstObras[nI ,1] + " - " + aEstObras[nI, 3]) //##"Gerando o registro de: "
				EndIf
			Else
				//------------------------------------------------------------------------------------------------------------------------------------
				//Estabelecimentos/Obras    XYZABC1230                                                                    Nâo Enviada ao TAF         "
				//Descricao dos erros diversos
				If( Empty( aEstObras[nI ,1] ) )
					aAdd( aDados, PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI, 3], 77) + " " + If(!lMiddleware,PADR(OemToAnsi(STR0029), 26),PADR(OemToAnsi(STR0256), 26)) )
				Else
					aAdd( aDados, PADR(OemToAnsi(STR0025), 25) + " " + PADR(aEstObras[nI ,1] + aEstObras[nI, 3], 77) + " " + If(!lMiddleware,PADR(OemToAnsi(STR0029), 26),PADR(OemToAnsi(STR0256), 26)) )
				EndIf

				nContErr++
				If( Empty(aEstObras[nI, 2]) )
					aAdd(aDados, OemToAnsi(STR0235) ) //"O campo RJ4_TPINSC (Tipo de Inscrição) está vazio e seu preenchimento é obrigatório."
				EndIf

				If( Empty(aEstObras[nI, 3]) )
					aAdd(aDados, OemToAnsi(STR0236) ) //"O campo RJ4_NINSCR (Número de Inscrição) está vazio e seu preenchimento é obrigatório."
				EndIf

				If empty(aEstObras[nI, 6])
					aAdd(aDados, OemToAnsi(STR0237) ) //"O campo RJ4_CNAE (CNAE) está vazio e seu preenchimento é obrigatório."
				Endif

				If empty(aEstObras[nI, 12])
					aAdd(aDados, OemToAnsi(STR0238) ) //"O campo RJ4_PON (Reg. Ponto) está vazio e seu preenchimento é obrigatório."
				Endif

				If empty(aEstObras[nI, 13])
					aAdd(aDados, OemToAnsi(STR0239) ) //"O campo RJ4_APR (Contratação Aprendiz) está vazio e seu preenchimento é obrigatório."
				Endif
				aAdd(aDados, "")

			EndIf
		Else //Impressao
			//Verifica campos vazios ou zerados


			If Empty(aEstObras[nI, 2]) .Or. Empty(aEstObras[nI, 3]) .Or. Empty(aEstObras[nI, 6]) .Or.;
			aEstObras[nI, 8] == 0 .And.;
			fGp23VlFil(nI, aEstObras, aLogCNPJ, nOpcAP, lSemFilial, lConsolid, 1) //Validacao CNPJ

				If Empty(cMenIni) .And. Len(aLogProc) == 0
					cMenIni := OemToAnsi(STR0060) //##"Inconsistências de Estabelecimento/Obra - Os campos abaixo estão vazios ou zerados e são de preenchimento obrigatórios:"

					aAdd(aLogProc, cMenIni)
					aAdd(aLogProc, "")
					aAdd(aLogProc, "")
				EndIf

				//Mensagem de log que sera gravado
				cMsgLog := OemToAnsi(STR0232) //##"Obra Própria"

				//Verifica inconsistencias
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Posiciona na tabela RJ4 - Fisica                    	 	   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				RJ4->(dbSetOrder(1))
				//RJ4_FILIAL      + RJ4_INI           + RJ4_TPINSC       + RJ4_NINSCR
				RJ4->(MsSeek(aEstObras[nI, 1] + aEstObras[nI, 18] + aEstObras[nI, 2] + aEstObras[nI, 3]))

				//Mensagem de log
				cMsgLog += " " + OemToAnsi(STR0125) + ": " //##"Preenchimento de campos obrigatórios"

				//Busca campos incosistentes
				fGp23Inco(aLogProc, 7, "RJ4", @cMsgLog)
				If empty(aEstObras[nI, 12])
					cMsgLog += " " + OemToAnsi(STR0238) //"O campo RJ4_PON (Reg. Ponto) está vazio e seu preenchimento é obrigatório."
				Endif

				If empty(aEstObras[nI, 13])
					cMsgLog += " " + OemToAnsi(STR0239) //"O campo RJ4_APR (Contratação Aprendiz) está vazio e seu preenchimento é obrigatório."
				Endif

				cMsgLog += " " + OemToAnsi(STR0125) + ": " //##"Preenchimento de campos obrigatórios"
			EndIf
			//Incrementa regua
			IncProc(OemToAnsi(STR0069) + " " + aEstObras[nI ,1] + " - " + aEstObras[nI, 2]) //##"Gerando o registro de: "
		EndIf
	Next nI

	//Se impressao, adiciona Log de Inconsistencias do CNPJ
	If nOpcAP == 2
		For nI := 1 To Len(aLogCNPJ)
			aAdd(aLogProc, OemToAnsi(STR0025)+" "+ aLogCNPJ[nI, 1] +" "+OemToAnsi(STR0061)) //##"Estabelecimentos/Obras"##"está cadastrado em duas ou mais filiais com dados de cadastro diferentes CTT_FPAS, CTT_CODTER"
			aAdd(aLogProc, OemToAnsi(STR0233)) //##"RJ4_CNAE, RJ4_RAT ou RJ4_FAP"
			aAdd(aLogProc, "")
		Next nI
	Else
		//Grava log
		//cMsgLog := OemToAnsi(STR0025) + " - " + OemToAnsi(STR0032) + OemToAnsi(aIncons[1]) //##"Estabelecimentos/Obras" ##"Falha no envio ao TAF: "
		//fGp23GrLog(aFilEnv[1], "S1005", cMsgLog, "2")
	EndIf

	//Fecha alias em uso
	If (Select(cAliasRJ4) > 0)
		(cAliasRJ4)->(dbCloseArea())
	EndIf

	RestArea(aAreaRJ4)
	RestArea(aArea)

	//----------------------
	//| Monta rodapé de LOG
	//----------------------
	If nOpcAP == 1 .OR. (Len(aEstObras) > 0 .and. Len(aDados) > 1)
		aAdd(aDados,"")
		aAdd(aDados,(OemToAnsi(STR0111)+" "+ OemToAnsi(STR0110) + " " + OemToAnsi(STR0025) ))	//"Resumo" ###"Carga Inicial" Estabelecimento/Obras
		aAdd(aDados, OemToAnsi(STR0009)+": " +  SecsToTime(nHrInicio))							//Inicio Processamento: A
		nHrFim 	:= SecsToTime(Seconds())
		aAdd(aDados,+OemToAnsi(STR0010)+":    " + nHrFim)											//Fim Processamento:    A
		aAdd(aDados,"")
		aAdd(aDados,OemToAnsi(STR0077)+": " + SecsToTime(Seconds() - nHrInicio))		//Duracao do Processamento
		If !lMiddleware
			aAdd(aDados,OemToAnsi(STR0078)+": "+ ALLTRIM(STR(nContador)))						//Quantidade Registro(s) enviado(s) ao TAF
			aAdd(aDados,OemToAnsi(STR0151)+": "+ ALLTRIM(STR(nContErr)))						//Quantidade Registros Não Enviados ao TAF
		Else
			aAdd(aDados,OemToAnsi(STR0243)+": "+ ALLTRIM(STR(nContador)))						//Quantidade Registro(s) enviado(s) ao Middleware
			aAdd(aDados,OemToAnsi(STR0244)+": "+ ALLTRIM(STR(nContErr)))						//Quantidade Registros Não Enviados ao Middleware
		Endif
		aAdd(aDados,"")
		aAdd(aDados,"")
	EndIf

Return()

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FSubst        ³ Autor ³ Cristina Ogura   ³ Data ³ 17/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que substitui os caracteres especiais por espacos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FSubst()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM610                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FSubst(cTexto)

	Local aAcentos	:={}
	Local aAcSubst	:={}
	Local cImpCar	:= Space(01)
	Local cImpLin	:=""
	Local cAux		:=""
	Local cAux1		:=""
	Local nTamTxt	:= Len(cTexto)
	Local j
	Local nPos

	// Para alteracao/inclusao de caracteres, utilizar a fonte TERMINAL no IDE com o tamanho
	// maximo possivel para visualizacao dos mesmos.
	// Utilizar como referencia a tabela ASCII anexa a evidencia de teste (FNC 807/2009).

	aAcentos :=	{;
	Chr(199),Chr(231),Chr(196),Chr(197),Chr(224),Chr(229),Chr(225),Chr(228),Chr(170),;
	Chr(201),Chr(234),Chr(233),Chr(237),Chr(244),Chr(246),Chr(242),Chr(243),Chr(186),;
	Chr(250),Chr(097),Chr(098),Chr(099),Chr(100),Chr(101),Chr(102),Chr(103),Chr(104),;
	Chr(105),Chr(106),Chr(107),Chr(108),Chr(109),Chr(110),Chr(111),Chr(112),Chr(113),;
	Chr(114),Chr(115),Chr(116),Chr(117),Chr(118),Chr(120),Chr(122),Chr(119),Chr(121),;
	Chr(065),Chr(066),Chr(067),Chr(068),Chr(069),Chr(070),Chr(071),Chr(072),Chr(073),;
	Chr(074),Chr(075),Chr(076),Chr(077),Chr(078),Chr(079),Chr(080),Chr(081),Chr(082),;
	Chr(083),Chr(084),Chr(085),Chr(086),Chr(088),Chr(090),Chr(087),Chr(089),Chr(048),;
	Chr(049),Chr(050),Chr(051),Chr(052),Chr(053),Chr(054),Chr(055),Chr(056),Chr(057),;
	Chr(038),Chr(195),Chr(212),Chr(211),Chr(205),Chr(193),Chr(192),Chr(218),Chr(220),;
	Chr(213),Chr(245),Chr(227),Chr(252),Chr(045),Chr(047),Chr(061),Chr(060),Chr(062);
	}

	aAcSubst :=	{;
	"C","c","A","A","a","a","a","a","a",;
	"E","e","e","i","o","o","o","o","o",;
	"u","a","b","c","d","e","f","g","h",;
	"i","j","k","l","m","n","o","p","q",;
	"r","s","t","u","v","x","z","w","y",;
	"A","B","C","D","E","F","G","H","I",;
	"J","K","L","M","N","O","P","Q","R",;
	"S","T","U","V","X","Z","W","Y","0",;
	"1","2","3","4","5","6","7","8","9",;
	"E","A","O","O","I","A","A","U","U",;
	"O","o","a","u","","","","","";
	}

	For j:=1 TO Len(AllTrim(cTexto))
		cImpCar	:=SubStr(cTexto,j,1)
		//-- Nao pode sair com 2 espacos em branco.
		cAux	:=Space(01)
		nPos 	:= 0
		nPos 	:= Ascan(aAcentos,cImpCar)
		If nPos > 0
			cAux := aAcSubst[nPos]
		Elseif (cAux1 == Space(1) .And. cAux == space(1)) .Or. Len(cAux1) == 0
			cAux :=	""
		EndIf
		cAux1 	:= 	cAux
		cImpCar	:=	cAux
		cImpLin	:=	cImpLin+cImpCar

	Next j

	//--Volta o texto no tamanho original
	cImpLin := Left(cImpLin+Space(nTamTxt),nTamTxt)

Return cImpLin

/*/{Protheus.doc} fVldCps
Verifica a existencia dos campos RJ4_TPRAT/RJ4_TPFAP na tabela RJ4.

@type		Static Function
@author 	Silvio C. Stecca
@since		28/02/2020
@version	12
@return lRet, logico, Retorna .T. ou .F.
/*/
Static Function fVldCps()

	Local lRet	:= .F.
	Local aArea	:= GetArea()

	dbSelectArea("RJ4")

	If FieldPos("RJ4_TPRAT") > 0 .And. FieldPos("RJ4_TPFAP") > 0
		lRet := .T.
	EndIf

	("RJ4")->(dbCloseArea())

	RestArea(aArea)

Return lRet
