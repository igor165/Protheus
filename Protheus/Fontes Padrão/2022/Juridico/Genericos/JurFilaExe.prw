#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURFILAEXE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JurFilaExe
Classe para controle da fila de processamento de dados (OH1), utilizada na emissão de pré-fatura e impressão de relatório em segundo plano

Data cRotina    - Valor usado para inserir na tabela OH1 no Insert() e consequentemente no filtro do GetNext() exemplo: "JURA202"
Data cTipo       - 1=Impressão;2=Relatório
Data cCodUser   - Código do usuário é usado como filtro, assim não criamos concorrência na leitura da tabela,
                        pois criamos uma fila por usuário/rotina/tipo
Data cSituacao  - Controle de Status do processamento, o GetNext só busca registros com Situação = 1-Pendente
	                    1=Pendente;2=Execução;3=Concluído;4=Cancelado
Data aParams    - Parâmetros utilizados no processamento,
                       utilizar o AddParams() para acresentar os parâmetros antes de executar o Insert()
                  - Os Parâmetros são gravados em XML no banco de dados e depois convertidos novamente para Array pelo GetNext()
                  - Utilizar a função Encode64() para gravar um objeto serializado, pois Serialize() transforma o objeto em um XML.
                  Estrutura: aParams[nI][1] "Codigo Usuario" -Nome do campo
                               aParams[nI][2] "00000000" -Valor do campo
                               aParams[nI][3] .T. -Se o campo será visivel para o usuário em uma futura tela de consulta (Opcional)
                               aParams[nI][4] "C" -Tipo do campo (Inserido automáticamente pelo AddParams())
                                                 Utilizado para conversão do valor.

@author Bruno Ritter
@since 01/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Class JurFilaExe
	Data cRotina
	Data cTipo
	Data cCodUser
	Data cNameUser
	Data cSituacao
	Data aParams
	Data cLockByName
	Data cLByNameRpt
	Data cRptFunc
	Data cNumThread

	Method New(cRotina, cTipo) Constructor
	Method GetXmlPar()
	Method AddParams(cCampo, xValor, lVisivel)
	Method RmvParams()
	Method GetParams()
	Method Insert()
	Method GetRotina()
	Method GetTipo()
	Method GetNext()
	Method SetConcl(nRec)
	Method SetExec(nRec)

	Method OpenWindow(lShowMsg)
	Method CloseWindow()
	Method IsOpenWindow()
	Method StartReport(lAutomato)
	Method IsOpenReport(lAutomato)
	Method GetRptFunc()
	Method CloseReport()
	Method OpenReport()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Metodo construtor
@author Bruno Ritter
@since 01/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method New(cRotina, cTipo, cNumThread) class JurFilaExe
	Default cRotina    := ""
	Default cTipo      := ""
	Default cNumThread := "" // Passar o número da thread para possibilitar abrir várias vezes a mesma rotina

	Self:aParams     := {}
	Self:cCodUser    := __cUserID
	Self:cNameUser   := JurUsrName(Self:cCodUser)
	Self:cRotina     := cRotina
	Self:cTipo       := cTipo
	Self:cNumThread  := cNumThread
	Self:cLockByName := cNumThread + Self:cRotina + Self:cCodUser
	Self:cRptFunc    := Self:GetRptFunc()
	Self:cLByNameRpt := cNumThread + Self:cRptFunc + Self:cCodUser

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} GetParams()
Método para retornar os Parâmetros informados

@author Bruno Ritter
@since 24/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetParams() Class JurFilaExe
Return Self:aParams

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRotina()
Método para retornar a Rotina

@author Bruno Ritter
@since 24/10/2016
/*/
//-------------------------------------------------------------------
Method GetRotina() Class JurFilaExe
Return Self:cRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTipo()
Método para retornar o Tipo

@author Bruno Ritter
@since 24/10/2016
/*/
//-------------------------------------------------------------------
Method GetTipo() Class JurFilaExe
Return Self:cTipo

//-------------------------------------------------------------------
/*/{Protheus.doc} AddParams()
Método para adicionar parâmetro na estrutura para inclusão de processamento
	cCampo    Ex:"Codigo Usuario" -Nome do campo
	xValor    Ex:"00000000"       -Valor do campo
	lVisivel  Ex:.T.              -Se o campo será visivel para o usuário em uma futura tela de consulta (Opcional)

@author Bruno Ritter
@since 24/10/2016
/*/
//-------------------------------------------------------------------
Method AddParams(cCampo, xValor, lVisivel) Class JurFilaExe
Local   lRet      := .F.
Default lVisivel  := .T.

	If ValType(cCampo) == "C"  .AND. ValType(xValor) $("C|D|L|M|N") .AND. ValType(lVisivel) == "L"
		Aadd(Self:aParams, {cCampo, xValor, lVisivel, ValType(xValor)})
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Insert()
Método para inserir um registro na tabela OH1 - Fila de Processamento

@param lSegPlano - Informa se a execução será em segundo plano ( thread ) (Padrão = .T.)
@param cRotina   - Rotina do processamento (opcional)
@param cTipo     - Tipo de processamento (1-Emissão, 2-Impressão) (opcional)

@author Bruno Ritter
@since 25/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method Insert(lSegPlano, cRotina, cTipo) Class JurFilaExe
Local aArea    := GetArea()
Local nRet     := 0
Local aParams  := Self:GetParams()
Local cCod     := "0"
Local cStatus  := "1"

Default lSegPlano := .T.
Default cRotina   := Self:GetRotina()
Default cTipo     := Self:GetTipo()

Iif(lSegPlano, cStatus := "1", cStatus := "2")

If ( !Empty(aParams) .AND. ValType(aParams) == "A";
		.AND. !Empty(Self:cCodUser) .AND. ValType(Self:cCodUser) == "C";
		.AND. !Empty(cRotina) .AND. ValType(cRotina) == "C";
		.AND. !Empty(cTipo) .AND. ValType(cTipo) == "C")

	DbSelectArea('OH1')
	RecLock("OH1", .T.)
	cCod := GetSXENum("OH1", "OH1_CODIGO")
	OH1->OH1_CODIGO := cCod
	OH1->OH1_FILIAL := xFilial('OH1')
	OH1->OH1_SITUAC := cStatus //1=Pendente;2=Execução;3=Concluído;4=Cancelado
	OH1->OH1_CODUSE := Self:cCodUser
	OH1->OH1_TIPO   := cTipo
	OH1->OH1_ROTINA := cRotina
	OH1->OH1_PARAME := Self:GetXmlPar()
	OH1->OH1_DTINIC := DATE()
	OH1->OH1_HRINIC := TIME()
	OH1->(MsUnlock())
	OH1->(DbCommit())
	ConfirmSX8()

	nRet := OH1->(Recno())
EndIf

RestArea( aArea )

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetXmlPar()
Método para montar o XML dos parâmetros informados na classe.

@author Bruno Ritter
@since 26/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetXmlPar() Class JurFilaExe
	Local cXML     := ""
	Local nI       := 1
	Local aParams  := Self:GetParams()
	Local cXmlRet  := ""
	Local cError   := ""
	Local cWarning := ""

	cXML += "<?xml version='1.0' encoding='iso-8859-1'?>"
	cXML += "<PARAMETROS>"
	For nI := 1 To Len(aParams)
		cXML += "<CAMPO>"
			cXML += "<ALIAS>"          + cValToChar(aParams[nI][1]) + "</ALIAS>"
			cXML += "<VALOR><![CDATA[" + cValToChar(aParams[nI][2]) + "]]></VALOR>"
			cXML += "<VISIVEL>"        + cValToChar(aParams[nI][3]) + "</VISIVEL>"
			cXML += "<TIPO>"           + cValToChar(aParams[nI][4]) + "</TIPO>"
		cXML += "</CAMPO>"
	Next
	cXML += "</PARAMETROS>"

	cXmlRet := XmlC14N( cXml, "", @cError, @cWarning )
	Iif(!Empty(cError)  , JurLogMsg(I18n(STR0003, {"'" + cError + "'", "GetXmlPar()"}), "ERROR" ), Nil) // "Erro ao executar o parse do xml #1, rotina: '#2'."
	Iif(!Empty(cWarning), JurLogMsg(I18n(STR0004, {cWarning          , "GetXmlPar()"}), "WARN"),   Nil) // "Alerta ao executar o parse do xml '#1', rotina: '#2'."

Return cXmlRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNext()
Método para achar o próximo registro na tabela OH1 levando em consideração Filial/Situacao = 1-Pendente/Usuario/Tipo/Rotina

@return Retorna um array contendo {aParam(OH1_PARAME), R_E_C_N_O_}

@author Bruno Ritter
@since 26/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetNext() Class JurFilaExe
Local aRet    := {}
Local aArea   := GetArea()
Local cRotina := Self:GetRotina()
Local cTipo   := Self:GetTipo()
Local nRecno  := 0
Local aParam  := {}

If (!Empty(Self:cCodUser) .AND. ValType(Self:cCodUser) == "C";
		.AND. !Empty(cRotina) .AND. ValType(cRotina) == "C";
		.AND. !Empty(cTipo) .AND. ValType(cTipo) == "C")

	DbSelectArea( 'OH1' )
	OH1->( dbSetOrder( 2 ) ) //OH1_FILIAL+OH1_SITUAC+OH1_CODUSE+OH1_TIPO+OH1_ROTINA

	If (DbSeek(xFilial('OH1') + "1" + Self:cCodUser + cTipo + cRotina) ) //1=Pendente
		If Self:SetExec(OH1->(Recno()))
			nRecno := OH1->(Recno())
			aParam := XmlToArray(OH1->(OH1_PARAME))
		EndIf
	EndIf

EndIf

aRet := {aParam, nRecno}
RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetConcl()
Método para registrar que foi concluído o processamento de um registro
@param nRec  ->Número do R_E_C_N_O_ do registro que foi concluido;

@author Bruno Ritter
@since 01/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetConcl(nRec) Class JurFilaExe
Local lRet    := .F.
Local aArea   := GetArea()
	
	dbSelectArea("OH1")
	OH1->(dbGoto(nRec))

	If OH1->(! Eof())
		RecLock("OH1", .F.)
		OH1->OH1_SITUAC := "3"
		OH1->OH1_DTFIM  := Date()
		OH1->OH1_HRFIM  := Time()
		OH1->(MsUnlock())
		lRet := .T.
	EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetExec()
Método para registrar que o registro está em execução

@param nRec  ->Número do R_E_C_N_O_ do registro que está em execução;

@author Bruno Ritter
@since 01/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Method SetExec(nRec) Class JurFilaExe
Local lRet    := .F.
Local aArea   := GetArea()
	
	DbSelectArea("OH1")
	Iif((OH1->(Recno()) != nRec), OH1->(dbGoto(nRec)), Nil)
	If OH1->(! Eof())
		If RecLock("OH1", .F.)
			OH1->OH1_SITUAC := "2"
			OH1->(MsUnlock())
			lRet := .T.
		EndIf
	EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XmlToArray()
Método para montar um array apartir do XML.

@author Bruno Ritter
@since 26/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function XmlToArray(cXml)
	Local oXML     := TXmlManager():New()
	Local nCampo   := 0
	Local nI       := 1
	Local nZ       := 1
	Local aRet     := {}
	Local aValores := {}
	Local lOk      := .T.
	Local nTotProp := 0

	Iif( RIGHT(cXml, 1) != ">", cXml += ">",)
	lOk := lOk .AND. oXml:Parse(cXML)
	lOk := lOk .AND. oXml:XPathHasNode("/PARAMETROS")

	If( lOk .AND. oXML:DOMChildNode() )
		nCampo := oXml:DOMSiblingCount()
		For nI := 1 To nCampo // Percorrer os campos
			lOk := lOk .AND. oXml:XPathHasNode("/PARAMETROS/CAMPO[" + cValToChar( nI ) + "]")
			lOk := lOk .AND. oXml:DOMChildNode()

			If lOk // Entra no nível de propriedades do Campo
				nTotProp := oXml:DOMSiblingCount()
				For  nZ := 1 To nTotProp //Percorrer as propriedades do Campo
					aAdd(aValores, oXml:cText)
					oXml:DOMNextNode()
				Next nZ

				Aadd(aRet, xConvCampo(aValores))
				aValores := {}
				oXML:DOMParentNode()
				oXml:DOMNextNode()
			EndIf
		Next nI
	EndIf

	Iif(!lOk, JurLogMsg(I18n(STR0003,{'', "XmlToArray()"}), "ERROR"), Nil) // "Erro ao executar o parse do xml #1, rotina: '#2'."

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XmlToArray()
Função para auxiliar a função XmlToArray, convertendo o valor do xml para o que foi definido na propriedade do campo.
E converter o valor do lVisivel

@author Bruno Ritter
@since 26/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function xConvCampo(aCampo)
Local aRet       := {}
Local xVlConv    := Nil
Local xValor     := aCampo[2]
Local lVisivel   := aCampo[3] == ".T."
Local xTpValor   := aCampo[4]

	If ( xTpValor == "N" )
		xVlConv := Val(xValor)

	ElseIf( xTpValor == "D" )
		xVlConv := Ctod(xValor)

	ElseIf( xTpValor == "L" )
		xVlConv := xValor == ".T."

	Else
		xVlConv := xValor
	EndIf

	aRet := {aCampo[1], xVlConv, lVisivel, aCampo[4]}

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} OpenWindow()
Método para ativar o controle de semaforo da tela (controle de abertura da tela)

@Return lRet .. a abertura da tela.

@author Luciano Pereira dos Santos
@since 19/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method OpenWindow(lShowMsg) Class JurFilaExe
Local lRet      := .F.
Local cRotina   := Self:cRotina
Local cUsrName  := Self:cNameUser

Default lShowMsg := .F.

lRet := LockByName(Self:cLockByName, .T., .F.)

IIf(lShowMsg .And. !lRet, JurMsgErro(STR0001, Self:cRotina, I18N(STR0002, {cRotina, cUsrName})), Nil) //#"Esta rotina só pode ser executada apenas uma vez por usuário. ##"Verifique se a rotina #1 esta aberta para o usuário #2 em outra conexão.

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} CloseWindow()
Método para desativar o controle de semaforo da tela (controle de fechamento da tela)

@Return lRet .T. se conseguiu desbloquear o registro.

@author Luciano Pereira dos Santos
@since 19/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method CloseWindow() Class JurFilaExe

UnlockByName(Self:cLockByName, .T., .F. )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IsOpenWindow()
Método para verificar se a tela esta aberta (Thread Pai)

@author Luciano Pereira dos Santos
@since 19/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method IsOpenWindow() Class JurFilaExe
Local lOpenWin := .T.

If Self:OpenWindow(.F.)
	Self:CloseWindow()
	lOpenWin := .F.
EndIf

Return lOpenWin

//-------------------------------------------------------------------
/*/{Protheus.doc} StartReport(lAutomato, cRotina)
Método para executar a função de relatório via SmartClient

@author Luciano Pereira dos Santos
@since 04/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method StartReport(lAutomato) Class JurFilaExe
Local lRet      := .T.
Local cParams   := ""
Local cCommand  := ""
Local cRmtExe   := ""
Local cMsglog   := ""
Local cCryPath  := "" //Caminho dos arquivos exportados do Crystal
Local cFuncao   := ""
Local cRotina   := ""
Local lPDUserAc := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)

Default lAutomato := .F.

If !lAutomato .And. !Self:IsOpenReport()
	cCryPath := JurCrysPath(@cMsglog)
	cFuncao  := Self:GetRptFunc()
	cRotina  := Self:GetRotina()

	JurCrLog(@cMsglog)

	cParams := __cUserID + "||" + cEmpAnt + "||" + cFilAnt + "||" + cCryPath + "||" + cRotina + "||" + Self:cNumThread + "||" + cValToChar(lPDUserAc)
	cParams := StrTran(cParams, " ", Chr(135))

	cCommand := "SMARTCLIENT.exe"
	cCommand += " -Q -P=" + cFuncao + " -E=" + GetEnvServer() + " -A=" + cParams + " -M"

	cRmtExe := GetRemoteIniName()

	If ( GetRemoteType() == 2 )
		cRmtExe := Subs(cRmtExe, At(':', cRmtExe) + 1 )
		cRmtExe := Subs(cRmtExe, 1, Rat('/', cRmtExe) ) + cCommand
	Else
		cRmtExe := Subs(cRmtExe, 1, Rat('\', cRmtExe) ) + cCommand
	EndIf

	lRet := WinExec(cRmtExe) == 0

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRptFunc()
Método para trazer a função de relatório executada via SmartClient
com base na rotina.

@author Luciano Pereira dos Santos
@since 04/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method GetRptFunc() Class JurFilaExe
Local cFuncao := ""
Local cRotina := Self:GetRotina()

Do Case
	Case cRotina == "JURA201"
		cFuncao := "J201GeraRpt"
	Case cRotina == "JURA202"
		cFuncao := "J202GeraRpt"
	Case cRotina == "JURA203"
		cFuncao := "J203GeraRpt"
	Case cRotina == "JURA204"
		cFuncao := "J204GeraRpt"
EndCase

Return cFuncao

//-------------------------------------------------------------------
/*/{Protheus.doc} IsOpenReport(lAutomato)
Método para verificar se a Thread de relatório esta aberta

@author Luciano Pereira dos Santos
@since 04/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method IsOpenReport() Class JurFilaExe
Local lOpen  := .T.

If Self:OpenReport()
	Self:CloseReport()
	lOpen := .F.
EndIf

Return lOpen

//-------------------------------------------------------------------
/*/{Protheus.doc} CloseReport()
Método para desativar o controle de semaforo da emissão de relatório (controle da thread do relatório)

@Return lRet .T. se conseguiu desbloquear o registro.

@author Luciano Pereira dos Santos
@since 19/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method CloseReport() Class JurFilaExe

UnlockByName(Self:cLByNameRpt, .T., .F. )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OpenReport()
Método para efetuar o lock do semafaro de emissão do relatorio,
para saber se a thread esta aberta.

@author Luciano Pereira dos Santos
@since 22/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Method OpenReport() Class JurFilaExe
Local lRet := .F.

lRet := LockByName(Self:cLByNameRpt, .T., .F.)

Return (lRet)
