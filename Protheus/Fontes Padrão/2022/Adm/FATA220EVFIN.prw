#include 'totvs.ch'
#include 'FWMVCDef.ch'
#Include 'FATA220EVFIN.CH'

/*/{Protheus.doc} FATA220EVFIN
Evento de Integração com o Módulo Financeiro na rotina FATA220 (Usuários de Portal)

@author Alison Kaique
@since Apr|2021
/*/
Class FATA220EVFIN From FWModelEvent
	Method New()
	//Bloco com regras de negócio na pós validação do modelo de dados.
	Method ModelPosVld()
EndClass

/*/{Protheus.doc} New
Método Construtor da Classe

@author Alison Kaique
@since Apr|2021
/*/
Method New() Class FATA220EVFIN
Return Self

/*/{Protheus.doc} ModelPosVld
Método responsável por executar regras de negócio do Financeiro
na pós validação do modelo de dados.

@type 		Método

@param 		oModel, objeto	, Modelo de dados de Clientes.
@param 		cID   , caracter, Identificador do sub-modelo.

@author 	alison.kaique
@version	12.1.33 / Superior
@since		23/04/2021
/*/
Method ModelPosVld(oModel, cID) Class FATA220EVFIN

	Local oModelAI6  As Object
	Local nOperation As Numeric
	Local lRet       As Logical
	Local lContinua  As Logical
	Local cLogin     As Character
	Local cSenha     As Character
	Local cFuncao    As Character
	Local cCodWS     As Character
	Local cUrlMingle As Character

	nOperation := 0
	lRet       := .T.
	lContinua  := .F.
	cLogin     := ''
	cSenha     := ''
	cFuncao    := ''
	cCodWS     := ''
	cUrlMingle := 'PROD'

	nOperation 	:= oModel:GetOperation()

	// verifica o Id do submodelo
	If (AllTrim(cID) == "FATA220") // usuário de Portal
		// verifica a operação
		If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE .OR.;
				nOperation == MODEL_OPERATION_DELETE)
		/*/
			Integração Portal do Cliente Mingle
		/*/
			//Verifica se existe cliente incluido como usuario do Portal
			If (FindFunction('PORTAL.CLIENTE.UTIL.INTMINGLEPCM'))
				// código do WebService
				cCodWS := PadR(SuperGetMV('MV_WEBSVPC', .F., 'PORTALCLIENTEMINGLE'), TamSX3('AI7_WEBSRV')[01])
				// verifica se foi vinculado o WebService do Portal do Cliente para o usuário
				oModelAI6 := oModel:GetModel('AI6DETAIL')
				If (oModelAI6:SeekLine({{"AI6_WEBSRV", cCodWS}}))
					If (oModelAI6:SeekLine({{"AI6_WEBSRV", "PORTALMINGLEDEV"}}))
						cUrlMingle := "DEV"
					Endif

					If  (oModelAI6:SeekLine({{"AI6_WEBSRV", "PORTALMINGLEHOM"}}))
						cUrlMingle := "HOM"
					EndIf

					If ValidModel(oModel)
						cLogin  := AllTrim(oModel:GetValue('AI3MASTER', 'AI3_LOGIN'))
						cSenha  := AllTrim(oModel:GetValue('AI3MASTER', 'AI3_PSW'))
						cFuncao := 'PORTAL.CLIENTE.UTIL.INTMINGLEPCM("' + cLogin + '", "' + cSenha + '", ' + cValToChar(nOperation) + ', "' + cUrlMingle + '")'
						// efetua o processamento no Mingle
						lRet := &(cFuncao)
					Else
						lContinua := .T.
					Endif
				EndIf
			Endif
		EndIf
	EndIf

	If lContinua
		HELP(" ",1, STR0001 ,, STR0002 ,2,0,,,,,,{ STR0003 }) // # "Portal - Clientes" # "Inclusão de Cliente" # "Necessario Incluir Cliente para conclusão do Cadastro"
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} ValidModel
Função responsável por validar se foi cadastrado cliente para o Portal
@type 		Função
@param 		oModel, objeto	, Modelo de dados de Clientes.
@author 	francisco.Oliveira
@version	12.1.33 / Superior
@since		19/09/2021
/*/

Static Function ValidModel(oModel)

	Local nX			    As Numeric
	Local nLenAI4		  As Numeric
	Local lRet			  As Logical
	Local oAI4DETAIL	As Object

	nX		:= 0
	lRet	:= .F.
	oAI4DETAIL  := oModel:GetModel("AI4DETAIL")

	nLenAI4 := oAI4DETAIL:Length()

	If nLenAI4 > 0
		For nX := 1 To nLenAI4
			oAI4DETAIL:Goline(nX)
			If !oAI4DETAIL:IsDeleted()
				cCodCli	:= oAI4DETAIL:GetValue("AI4_CODCLI")
				cLojCli	:= oAI4DETAIL:GetValue("AI4_LOJCLI")
				If Empty(cCodCli) .Or. Empty(cLojCli)
					lRet := .F.
				Else
					lRet := .T.
					Exit
				Endif
			Endif
		Next nX
	Endif

Return lRet
