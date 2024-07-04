#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA145DEF.ch"

Static _oProcesso := Nil

/*/{Protheus.doc} PCPA145SLD
THREAD Filha para delegação dos processo de atualização de estoque.

@type  Function
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cTicket , Character, Ticket de processamento do MRP para geração dos documentos
@param cNivel  , Character, Nível dos produtos que devem ser atualizados.
@param cFilProc, Character, Código da filial para processamento
@return Nil
/*/
Function PCPA145SLD(cTicket, cNivel, cFilProc)
	Local aProdutos := {}
	Local cName     := cTicket + CHR(13) + cNivel + CHR(13) + "COUNT"
	Local lRet      := .T.
	Local nIndex    := 0
	Local nTotal    := 0

	If _oProcesso == Nil
		_oProcesso := ProcessaDocumentos():New(cTicket, .T.)
	EndIf

	aProdutos := _oProcesso:getProdutoNivel(cNivel, @lRet, cFilProc)

	If lRet
		//Inicializa o contador para controle dos jobs executados.
		_oProcesso:initCount(cName)

		//Delega os produtos para atualização de estoque.
		nTotal := Len(aProdutos)
		For nIndex := 1 To nTotal
			_oProcesso:incCount(_oProcesso:cThrSaldoJob + "_Delegados")
			PCPIPCGO(_oProcesso:cThrSaldoJob, .F., "PCPA145EST", _oProcesso:cTicket, aProdutos[nIndex], cName, cNivel, cFilProc)
		Next nIndex

		//Aguarda a finalização dos jobs delegadas.
		While _oProcesso:getCount(cName) < nTotal
			Sleep(50)
		End

		//Limpa da memória os dados de saldo dos produtos deste nível.
		_oProcesso:delSaldoProd(cNivel, cFilProc)

		//Limpa o contador.
		_oProcesso:clearCount(cName)
	EndIf

	aSize(aProdutos, 0)

	_oProcesso:incCount(_oProcesso:cThrSaldo + "_Concluidos")

Return