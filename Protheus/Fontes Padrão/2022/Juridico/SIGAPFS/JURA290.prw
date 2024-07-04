#INCLUDE "JURA290.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#include "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Anexos

@return oModel, Modelo de dados de anexos

@author Jorge Martins / Abner Oliveira
@since  15/02/2021
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oEvent     := JA290Event():New()
Local oStructNUM := FWFormStruct(1, "NUM")

	oModel:= MPFormModel():New("JURA290", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields("NUMMASTER", NIL, oStructNUM, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription(STR0001) // "Modelo de Dados de Anexos"
	oModel:GetModel("NUMMASTER"):SetDescription(STR0002) // "Dados de Anexos"
	oModel:InstallEvent("JA290Event", /*cOwner*/, oEvent)

	JurSetRules(oModel, "NUMMASTER",, "NUM")

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} JA290Event
Classe interna implementando o FWModelEvent.

@author Jorge Martins / Abner Oliveira
@since  15/02/2021
/*/
//------------------------------------------------------------------------------
Class JA290Event FROM FWModelEvent

	Method New()
	Method ModelPosVld()
	Method InTTS()

End Class

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo construtor FWModelEvent

@author Jorge Martins / Abner Oliveira
@since  15/02/2021
/*/
//------------------------------------------------------------------------------
Method New() Class JA290Event
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
M�todo que � chamado pelo MVC quando ocorrer as a��es de p�s valida��o do Modelo.

@param oModel   - Modelo de dados de anexos
@param cModelId - Id do Modelo

@return lPosVld - Indica se o modelo est� v�lido para ser comitado

@author Jorge Martins / Abner Oliveira
@since  15/02/2021
/*/
//------------------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class JA290Event
Local nOperation := oModel:GetOperation()
Local lPosVld    := .T.
Local lBaseCon   := SuperGetMv('MV_JDOCUME', ,'1') == "2" // Base de Conhecimento
Local cArq       := ""
Local cFile      := ""
Local cExtens    := ""

	If nOperation == MODEL_OPERATION_INSERT
		
		lPosVld := J290VldEnt(oModel) // Valida Filial e Chave da Entidade

		If lPosVld
			If lBaseCon

				cExtens := RTrim(oModel:GetValue("NUMMASTER", "NUM_EXTEN"))
				If Left(cExtens, 1) != "."
					lPosVld := JurMsgErro(STR0017,, I18N(STR0018, {cExtens})) // "Extens�o do arquivo inv�lida." - "Informar extens�o utilizando '.', conforme exemplo: '.#1'"
				EndIf

				If lPosVld .And. !Empty(oModel:GetValue("NUMMASTER", "NUM_NUMERO"))
					lPosVld := JurMsgErro(STR0005,, STR0007) // "N�mero do arquivo inv�lido." - "Para inclus�o de anexos n�o � permitido preencher o campo 'N�mero'."
				EndIf

				If lPosVld
					cArq  := Alltrim(oModel:GetValue("NUMMASTER", "NUM_DESC"))
					cFile := "\spool\" + cArq

					If !File(cFile)
						lPosVld := JurMsgErro(STR0008,, I18N(STR0009, {cArq})) // "N�o foi poss�vel localizar o arquivo para concluir o anexo." - "Verifique junto a equipe t�cnica se o arquivo '#1' existe na pasta SPOOL do diret�rio Protheus_Data."
					EndIf

					If lPosVld .And. J290ExistDoc(oModel) // Verifica se o documento j� foi anexado a este registro
						lPosVld := JurMsgErro(STR0015,, I18N(STR0016, {cArq})) // "Arquivo inv�lido." - "O documento '#1' j� foi anexado a esse registro."
					EndIf

				EndIf
			ElseIf Empty(oModel:GetValue("NUMMASTER", "NUM_NUMERO"))
				lPosVld := JurMsgErro(STR0005,, STR0006) // "N�mero do arquivo inv�lido." - "Para inclus�o de anexos � necess�rio preencher o campo 'N�mero'."
			EndIf
		EndIf
	ElseIf nOperation == MODEL_OPERATION_UPDATE
		oModel:SetErrorMessage(,, oModel:GetId(),, "ModelPosVld", STR0003, STR0004,, ) // "Opera��o n�o permitida" - "Esta rotina n�o permite a opera��o de altera��o!"
		lPosVld := .F.
	EndIf

Return lPosVld

//------------------------------------------------------------------------------
/*/{Protheus.doc} InTTS
M�todo que � chamado pelo MVC quando ocorrer as a��es do commit ap�s as 
grava��es por�m antes do final da transa��o.

Esse evento ocorre uma vez no contexto do modelo principal.

@param oSubModel - Modelo de dados de anexos
@param cModelId  - Id do Modelo

@author Jorge Martins / Abner Oliveira
@since  17/02/2021
/*/
//------------------------------------------------------------------------------
Method InTTS(oSubModel, cModelId) Class JA290Event

	J290OpcAnx(oSubModel) // Realiza as opera��es de inclus�o/exclus�o de anexos

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} J290VldEnt
Valida se a filial da entidade foi enviada corretamente e se o registro (NUM_CENTID)
no qual o anexo ser� feito existe na entidade.

@param oModel   - Modelo de dados de anexos

@return lVldEnt - Indica que a filial da entidade e o registro s�o v�lidos

@author Jorge Martins / Abner Oliveira
@since  25/02/2021
/*/
//------------------------------------------------------------------------------
Static Function J290VldEnt(oModel)
Local lVldEnt   := .T.
Local cEntidade := oModel:GetValue("NUMMASTER", "NUM_ENTIDA") // Entidade de inclus�o do anexo
Local cCodEnt   := oModel:GetValue("NUMMASTER", "NUM_CENTID") // Chave do registro
Local cFilEnt   := oModel:GetValue("NUMMASTER", "NUM_FILENT") // Filial da entidade enviada pelo LD
Local cFilSis   := xFilial(cEntidade) // Filial utilizada pela entidade na qual o sistema est� logado

	If cFilEnt == cFilSis
		If cEntidade == "NVE" // Caso
			If !J290VldNVE(cCodEnt) // Valida a chave da entidade enviada (Valida��o espec�fica para a tabela NVE)
				lVldEnt := JurMsgErro(STR0003,, STR0010) // "Opera��o n�o permitida" - "N�o existe registro relacionado a esta chave."
			EndIf
		ElseIf !ExistCpo(cEntidade, cCodEnt, 1) // Valida a chave da entidade enviada
			lVldEnt := JurMsgErro(STR0003,, STR0010) // "Opera��o n�o permitida" - "N�o existe registro relacionado a esta chave."
		EndIf
	Else
		If Empty(cFilEnt) .And. !Empty(cFilSis)
			lVldEnt := JurMsgErro(STR0011,, STR0012) // "Filial inv�lida." - "Preencha o campo de Filial da Entidade."
		ElseIf !Empty(cFilEnt) .And. Empty(cFilSis)
			lVldEnt := JurMsgErro(STR0011,, i18N(STR0013, {AllTrim(FWX2Nome(cEntidade)), cEntidade})) // "Filial inv�lida." - "Para inclus�o de anexos na entidade #1 (#2) a filial deve estar em branco."
		Else
			lVldEnt := JurMsgErro(STR0011,, STR0014) // "Filial inv�lida." - "Preencha corretamente o campo de Filial da Entidade."
		EndIf
	EndIf

Return lVldEnt

//------------------------------------------------------------------------------
/*/{Protheus.doc} J290ExistDoc
Valida se j� existe um anexo com o mesmo nome para o registro

@param oModel      - Modelo de dados de anexos

@return lExisteDoc - Indica que o arquivo atual j� foi anexado a este registro

@author Jorge Martins
@since  09/03/2021
/*/
//------------------------------------------------------------------------------
Static Function J290ExistDoc(oModel)
Local oModelNUM  := oModel:GetModel("NUMMASTER")
Local cQuery     := ""
Local aRetorno   := {}
Local lExisteDoc := .F.

	cQuery := " SELECT NUM_FILIAL, NUM_COD "
	cQuery +=   " FROM " + RetSqlName("NUM")
	cQuery +=  " WHERE NUM_FILIAL = '" + xFilial("NUM") + "'"
	cQuery +=    " AND NUM_ENTIDA = '" + oModelNUM:GetValue("NUM_ENTIDA") + "'"
	cQuery +=    " AND NUM_FILENT = '" + oModelNUM:GetValue("NUM_FILENT") + "'"
	cQuery +=    " AND NUM_CENTID = '" + oModelNUM:GetValue("NUM_CENTID") + "'"
	cQuery +=    " AND NUM_DOC    = '" + oModelNUM:GetValue("NUM_DOC")    + "'"
	cQuery +=    " AND NUM_EXTEN  = '" + oModelNUM:GetValue("NUM_EXTEN")  + "'"
	cQuery +=    " AND D_E_L_E_T_ = ' '"

	aRetorno := JurSQL(cQuery, "*")

	lExisteDoc := Len(aRetorno) > 0

	JurFreeArr(@aRetorno)

Return lExisteDoc

//------------------------------------------------------------------------------
/*/{Protheus.doc} J290OpcAnx
Realiza as opera��es de inclus�o/exclus�o de anexos

@param oSubModel - Modelo de dados de anexos

@author Jorge Martins / Abner Oliveira
@since  18/02/2021
/*/
//------------------------------------------------------------------------------
Static Function J290OpcAnx(oSubModel)
Local lBaseCon   := SuperGetMv('MV_JDOCUME', ,'1') == "2" // Base de Conhecimento
Local oModel     := oSubModel:GetModel()
Local nOperation := oModel:GetOperation()
Local oModelNUM  := oModel:GetModel("NUMMASTER")
Local cFilEnt    := oModelNUM:GetValue("NUM_FILENT")
Local cEntidade  := oModelNUM:GetValue("NUM_ENTIDA")
Local cCodEnt    := oModelNUM:GetValue("NUM_CENTID")
Local cFile      := "\spool\" + Alltrim(oModelNUM:GetValue("NUM_DESC"))
Local cNumero    := ""
Local cChvACB    := ""
Local cChvAC9    := ""

	If lBaseCon
		If nOperation == MODEL_OPERATION_INSERT
			aRetAnx := J026Anexar(cEntidade, cFilEnt, cCodEnt, "", cFile, .T.)

			If aRetAnx[1] .And. File(cFile) // Apaga o arquivo na pasta spool
				FErase(cFile)
			EndIf

		ElseIf nOperation == MODEL_OPERATION_DELETE
			cNumero  := oModelNUM:GetValue("NUM_NUMERO")
			cChvACB  := cNumero // ACB_CODOBJ
			cChvAC9  := cNumero + cEntidade + cFilEnt + cCodEnt // AC9_CODOBJ, AC9_ENTIDA, AC9_FILENT, AC9_CODENT

			JAnxDlBaseCon(cChvACB, cChvAC9, 1) // Exclui registros na ACB e AC9
		EndIf
	EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} J290VldNVE
Valida se o registro (NUM_CENTID) no qual o anexo ser� feito existe na entidade 
NVE - Caso

@param cCodEnt  - Chave do Registro (NVE_CCLIEN + NVE_LCLIEN + NVE_NUMCAS)

@return lVldEnt - Indica que o registro � v�lido

@author Jorge Martins
@since  23/03/2021
/*/
//------------------------------------------------------------------------------
Static Function J290VldNVE(cCodEnt)
Local lVldEnt  := .T.
Local cQuery   := ""
Local aRetorno := {}
Local nTamCli  := TamSX3("NVE_CCLIEN")[1]
Local nTamLoja := TamSX3("NVE_LCLIEN")[1]
Local nTamCaso := TamSX3("NVE_NUMCAS")[1]
Local cCliente := Substr(cCodEnt, 1, nTamCli)
Local cLoja    := Substr(cCodEnt, 1 + nTamCli, nTamLoja)
Local cCaso    := Substr(cCodEnt, 1 + nTamCli + nTamLoja, nTamCaso)

	cQuery := " SELECT 1 CONTA "
	cQuery +=   " FROM " + RetSqlName( "NVE" ) + " NVE "
	cQuery +=  " WHERE NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
	cQuery +=    " AND NVE.NVE_CCLIEN = '" + cCliente + "' "
	cQuery +=    " AND NVE.NVE_LCLIEN = '" + cLoja + "' "
	cQuery +=    " AND NVE.NVE_NUMCAS = '" + cCaso + "' "
	cQuery +=    " AND NVE.D_E_L_E_T_ = ' ' "

	aRetorno := JurSQL(cQuery, "CONTA")

	lVldEnt  := Len(aRetorno) > 0

	JurFreeArr(@aRetorno)

Return lVldEnt
