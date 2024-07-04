#INCLUDE "PROTHEUS.CH"
#INCLUDE "JurTpConta.CH"
#INCLUDE "FWBROWSE.CH"

Static _cTpConta   := "" // Usada para consulta padrão de Tipo de Conta

//-------------------------------------------------------------------
/*/{Protheus.doc} JURTPCONTA
Classa para controle dos tipos de contas do PFS, utilizado no financeiro/Centro de custos

@author bruno.ritter
@since 26/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JURTPCONTA

	Data lTudoOk
	Data aMsgError  //[1]Erro, [2]Solução
	Data lExibMsg   //Se exibe mensagem de erro automaticamente.
	Data aContas    //Lista de Tipo de Contas
	Data nPosCodigo //Posição do Código do Tipo Conta dentro do aContas
	Data nPosNmCont //Posição do Nome do Tipo de Conta dentro do aContas
	Data nPosOrigem //Posição do Sinal de Origem do Tipo de Conta dentro do aContas
	Data nPosDestin //Posição do Sinal de Destino do Tipo de Conta dentro do aContas
	Data nPosClasFl //Posição do ClashFlow, 1 = habilita o campo, 2 = Não habilita
	Data oTmpTable //Tabela temporária com os tipos de contas

	Method New() Constructor
	Method SetExibMsg()
	Method SetError()
	Method GetError()
	Method GetListDic()
	Method GetTpConta()
	Method GetCashFlw()
	Method GetNmConta()
	Method GetRecPag()
	Method GeraTmp()
	Method Destroy()
	Method GetTmpName()

End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} New()

Construtor da Classe JURTPCONTA

@author bruno.ritter
@since 26/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class JURTPCONTA

	Self:aContas       := JListConta()
	Self:aMsgError     := {"",""}
	Self:lExibMsg      := .T.
	Self:lTudoOk       := .T.
	Self:nPosCodigo    := 1
	Self:nPosNmCont    := 2
	Self:nPosOrigem    := 3
	Self:nPosDestin    := 4
	Self:nPosClasFl    := 5

Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} SetExibMsg(lExibMsg)
Método para setar se os erros devem ser exibidos automaticamente.

@author bruno.ritter
@since 26/07/2017
/*/
//-------------------------------------------------------------------
Method SetExibMsg(lExibMsg) Class JURTPCONTA
Self:lTudoOk := .T.

	If ValType(lExibeMsg == "L")
		Self:lExibMsg := lExibeMsg
	EndIf

Self:lTudoOk := Self:lExibMsg == lExibMsg
Return Self:lTudoOk

//-------------------------------------------------------------------
/*/{Protheus.doc} SetError(cMsgError, cMsgSoluc)
Método local para Setar um erro

@author bruno.ritter
@since 26/07/2017
/*/
//-------------------------------------------------------------------
Method SetError(cMsgError, cMsgSoluc) Class JURTPCONTA
	
	Self:lTudoOk    := .F.
	Self:aMsgError  := {cMsgError, cMsgSoluc}

	If Self:lExibMsg
		JurMsgErro(Self:aMsgError[1], "JurTpConta" , Self:aMsgError[2])
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetError()
Método para retorna o erro da última operação.

@author bruno.ritter
@since 26/07/2017
/*/
//-------------------------------------------------------------------
Method GetError() Class JURTPCONTA
Local aRet := {}

	If !Self:lTudoOk
		aRet := {Self:aMsgError[1] , Self:aMsgError[2]}
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetListDic()
Método para gerar a lista dos tipos de conta da forma que o campo X3_CBOX do dicionario entenda

@author bruno.ritter
@since 26/07/2017
/*/
//-------------------------------------------------------------------
Method GetListDic() Class JURTPCONTA
Local cRet       := ""
Local nI         := 1
Local nTotConta  := Len(Self:aContas)

	For nI := 1 to nTotConta
		cRet += Self:aContas[nI, Self:nPosCodigo] + "="
		cRet += Self:aContas[nI, Self:nPosNmCont] + ";"
	Next nI

	cRet := SUBSTR(cRet,1,Len(cRet)-1) //Remove o ultimo ponto e virgula";"
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTpConta(cCodTpCont)
Método para pegar o(s) tipo(s) de conta(s)

@param cCodTpCont - filtrar um tipo de conta pelo código

@author bruno.ritter
@since 26/07/2017
/*/
//-------------------------------------------------------------------
Method GetTpConta(cCodTpCont) Class JURTPCONTA
Local aRet   := Self:aContas
Local nPos   := 0

Default cCodTpCont := ""
Self:lTudoOk := .T.

	If !Empty(cCodTpCont)
		nPos := Ascan(Self:aContas, {|aX| aX[Self:nPosCodigo] == cCodTpCont})
		If nPos != 0
			aRet := Self:aContas[nPos]

		Else
			aRet := {}
			Self:SetError(I18n(STR0009,{cCodTpCont}), STR0010) // "Tipo de Conta '#1' não encontrado." ##"Informe um Tipo de Conta válido."
		EndIf
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCashFlw(cCodTpCont)
Método para pegar o CashFlow do Tipo de Conta

@author bruno.ritter
@since 26/07/2017
/*/
//-------------------------------------------------------------------
Method GetCashFlw(cCodTpCont) Class JURTPCONTA
Local aConta   := 0
Local cRet     := ""

Default cCodTpCont := ""
Self:lTudoOk := .T.

If !Empty(cCodTpCont)
	aConta := Self:GetTpConta(cCodTpCont)
	If !Empty(aConta)
		cRet := aConta[Self:nPosClasFl]
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNmConta(cCodTpCont)
Método para pegar o Nome do Tipo de Conta

@author bruno.ritter
@since 26/07/2017
/*/
//-------------------------------------------------------------------
Method GetNmConta(cCodTpCont) Class JURTPCONTA
Local aConta   := 0
Local cRet     := ""

Default cCodTpCont := ""
Self:lTudoOk := .T.

If !Empty(cCodTpCont)
	aConta := Self:GetTpConta(cCodTpCont)
	If !Empty(aConta)
		cRet := aConta[Self:nPosNmCont]
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JListConta()
Carregar a lista de tipos de contas

@return aRet - array com o código da conta, Tipo de Conta, Sinal Origem, Sinal Destino 

@author bruno.ritter
@since 26/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JListConta()

Local aRet := {;//Código, Nm Conta, Sinal Origem, Sinal Destino, CashFlow
				{"1"    ,STR0001  ,"P"          ,"R"           , "1"},; // Banco/Caixa
				{"2"    ,STR0002  ,"P"          ,"R"           , "2"},; // Custo
				{"3"    ,STR0003  ,"R"          ,"P"           , "2"},; // Receita
				{"4"    ,STR0004  ,"P"          ,"R"           , "2"},; // Investimento
				{"5"    ,STR0005  ,"P"          ,"R"           , "2"},; // Lucro/Bônus
				{"6"    ,STR0006  ,"P"          ,"R"           , "2"},; // Obrigações
				{"7"    ,STR0007  ,"R"          ,"P"           , "2"},; // C.C. Profissional
				{"8"    ,STR0008  ,"P"          ,"R"           , "2"} ; // Despesa
}

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRecPag(cCodTpCont, cTpNatur)
Método para retornar o tipo de conta da natureza é a pagar ou receber

@param cCodTpCont - Filtrar um tipo de conta pelo código
@param cTpNatur   - O = Natureza de Origem, D = Naturaza de destino

@Return cRet      - P=Pagar, R=Receber 

@author Eduardo Augusto
@since 26/07/2017
/*/
//-------------------------------------------------------------------
Method GetRecPag(cCodTpCont, cTpNatur) Class JURTPCONTA
Local cRet     := AvKey("", "FIV_CARTEI")
Local aContas  := Self:aContas
Local nPos     := 0

If (nPos := AScan(aContas, {|x| x[1] == cCodTpCont })) > 0
	If cTpNatur == 'O'
		cRet := aContas[nPos][3]
	ElseIf cTpNatur == 'D'
		cRet := aContas[nPos][4]
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraTmp()
Método para gerar uma tabela temporária no banco de dados com os tipos de conta

@author Bruno Ritter / Thiago Malaquias
@since 22/03/2018
/*/
//-------------------------------------------------------------------
Method GeraTmp() Class JURTPCONTA
Local aStruct   := {}
Local oTmpTable := Nil
Local aTpContas := Self:aContas
Local nConta    := 1
Local cInsertO  := ""
Local cInsertD  := ""

Aadd(aStruct, { "CODIGO", "C", 1, 0 })
Aadd(aStruct, { "TIPO"  , "C", 1, 0 })
Aadd(aStruct, { "SINAL" , "N", 1, 0 })

oTmpTable := FWTemporaryTable():New( GetNextAlias(), aStruct )
oTmpTable:AddIndex("CODIGO",{"CODIGO"})
oTmpTable:Create()

For nConta := 1 To Len(aTpContas)

	cInsertO := " INSERT INTO " + oTmpTable:GetRealName() + " (CODIGO, TIPO, SINAL) VALUES "+CRLF
	cInsertD := " INSERT INTO " + oTmpTable:GetRealName() + " (CODIGO, TIPO, SINAL) VALUES "+CRLF

	If aTpContas[nConta][3] == "P"
		cInsertO += " ('" +aTpContas[nConta][1]+ "', 'O', -1)"
		cInsertD += " ('" +aTpContas[nConta][1]+ "', 'D',  1)"
	Else
		cInsertO += " ('" +aTpContas[nConta][1]+ "', 'O',  1)"
		cInsertD += " ('" +aTpContas[nConta][1]+ "', 'D', -1)"
	EndIf

	If (TCSQLExec(cInsertO) < 0) //Usar TCSQLExec apenas na tabela temporária criada pelo FWTemporaryTable()
		JurLogMsg( TCSQLError() )
	EndIf

	If (TCSQLExec(cInsertD) < 0) //Usar TCSQLExec apenas na tabela temporária criada pelo FWTemporaryTable()
		JurLogMsg( TCSQLError() )
	EndIf
Next nConta

Self:oTmpTable := oTmpTable

Return oTmpTable

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy()
Destrói o objeto

@author Bruno Ritter / Thiago Malaquias
@since 22/03/2018
/*/
//-------------------------------------------------------------------
Method Destroy() Class JURTPCONTA

If !Empty(Self:aMsgError)
	ASize( Self:aMsgError, 0 )
EndIf

If !Empty(Self:aContas)
	ASize( Self:aContas, 0 )
EndIf

If !Empty(Self:oTmpTable)
	Self:oTmpTable:Delete()
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTmpName()
Retorna o nome real da tabela temporária

@author Bruno Ritter / Thiago Malaquias
@since 22/03/2018
/*/
//-------------------------------------------------------------------
Method GetTmpName() Class JURTPCONTA
Local cRealName := ""

If !Empty(Self:oTmpTable)
	cRealName := Self:oTmpTable:GetRealName()
EndIf

Return cRealName


//-------------------------------------------------------------------
/*/{Protheus.doc} JF3TpConta
Consulta Padrão de Tipo de conta - ED_TPCOJR

Usado no Pergunte do Relatório JURAPAD034 - Extrato por Natureza / 
Centro de Custo

@return lRet, lógico, .T./.F. As informações são válidas ou não

@author  Jorge Martins
@version P12
@since   30/03/2018
/*/
//-------------------------------------------------------------------
Function JF3TpConta()
	Local lRet       := .F.
	Local oMain      := Nil
	Local oMainPanel := Nil
	Local oPanelBrw  := Nil
	Local oBrowse    := Nil
	Local oColumn1   := Nil
	Local oColumn2   := Nil
	Local aDados     := {}
	Local aCbox      := STRTOKARR(JurListCon(), ";")
	Local nPos       := 0
	Local nI         := 0
	Local cCod       := ""
	Local cDesc      := ""
	
	For nI := 1 To Len(aCbox)
		nPos   := At('=',aCbox[nI])
		cCod   := LEFT(aCbox[nI], nPos-1)
		cDesc  := RIGHT(aCbox[nI], Len(aCbox[nI])-nPos)

		aAdd(aDados, {cCod, cDesc})

	Next nI
	
	oModal := FWDialogModal():New()
	oModal:SetFreeArea(420,180)
	oModal:SetEscClose(.T.)
	oModal:SetTitle( STR0011 ) // "Consulta Padrão - Tipo de Conta"

	oModal:createDialog()
	oModal:addOkButton(   {|| _cTpConta := aDados[oBrowse:nAt][1], ( lRet := .T., oModal:oOwner:End() ) })
	oModal:addCloseButton({|| lRet := .F., oModal:oOwner:End() })

	oMain := oModal:GetPanelMain()
	oMainPanel := TPanel():Create(oMain,02,,,,,,,/*CLR_RED*/,,20)
	oMainPanel:Align := CONTROL_ALIGN_TOP

	oPanelBrw := TPanel():Create(oMain,02,,,,,,,/*CLR_BLUE*/)
	oPanelBrw:Align := CONTROL_ALIGN_ALLCLIENT

	Define FWBrowse oBrowse DATA ARRAY ARRAY aDados NO LOCATE  NO CONFIG  NO REPORT ;
	                        DOUBLECLICK { || _cTpConta := aDados[oBrowse:nAt][1], lRet := .T.,  oModal:oOwner:End() } Of oPanelBrw
	
	ADD COLUMN oColumn1  DATA { || aDados[oBrowse:nAt][1] }  Title STR0012 Of oBrowse // "Código"
	ADD COLUMN oColumn2  DATA { || aDados[oBrowse:nAt][2] }  Title STR0013 Of oBrowse // "Descrição"

	oBrowse:Activate()

	oModal:Activate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JRetTpCont
Retorno da Consulta Padrão de Tipo de conta - ED_TPCOJR

Usado no Pergunte do Relatório JURAPAD034 - Extrato por Natureza / 
Centro de Custo

@return _cTpConta, caractere, Código do tipo de conta

@author  Jorge Martins
@version P12
@since   30/03/2018
/*/
//-------------------------------------------------------------------
Function JRetTpCont()
Return _cTpConta

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldTpCont
Validação do Tipo de conta - ED_TPCOJR

Usado no Pergunte do Relatório JURAPAD034 - Extrato por Natureza / 
Centro de Custo

@param cTPConta, caractere, Valor informado no campo

@return lRet, logico, T./.F. As informações são válidas ou não

@author  Jorge Martins
@version P12
@since   30/03/2018
/*/
//-------------------------------------------------------------------
Function JVldTpCont(cTPConta)
Local lRet          := .T.
Local aCbox         := STRTOKARR(JurListCon(), ";")
Local nPos          := 0
Local nI            := 0
Local cOpcTpConta   := ""

For nI := 1 To Len(aCbox)
	nPos         := At('=',aCbox[nI])
	cOpcTpConta  += LEFT(aCbox[nI], nPos-1) + "|"
Next nI

If !(cTPConta $ cOpcTpConta)
	lRet := .F.
	JurMsgErro(I18n(STR0009,{cTPConta}),"JVldTpCont", STR0010) // "Tipo de Conta '#1' não encontrado." ##"Informe um Tipo de Conta válido."
EndIf

Return lRet