#INCLUDE "PROTHEUS.CH"
#INCLUDE "MRPPROCED.CH"

/*/{Protheus.doc} MRPProced
Fonte para executar as procedures referentes ao MRP
@author marcelo.neumann
@since 12/11/2019
@version P12
@param cErro  , caracter, mensagem de erro (passado por referência)
@param lAllFil, Lógico  , indica se deve calcular o nível em todas as filiais.
@return lOk, lógico, indica se tudo foi executado com sucesso
/*/
Function MRPProced(cErro, lAllFil)
	Local lOk := .T.
	
	Default lAllFil := .F.

	lOk := CalcNivel(@cErro, lAllFil)

Return lOk

/*/{Protheus.doc} CalcNivel
Calcula o nível de cada Produto do MRP (HWA) de acordo com a Estrutura (T4N)
@author marcelo.neumann
@since 12/11/2019
@version P12
@param cErro  , caracter, mensagem de erro (passado por referência)
@param lAllFil, Lógico  , indica se deve calcular o nível em todas as filiais.
@return lOk, lógico, indica se foi executada com sucesso
/*/
Static Function CalcNivel(cErro, lAllFil)

	Local aFilProc := {}
	Local aResult  := {}
	Local cProcNam := GetSPName("MRP001","24")
	Local lOk      := .T.
	Local nIndex   := 0
	Local nTotal   := 0
	Local nInicio  := MicroSeconds()
	Local nIniFil  := 0

	LogNiv(STR0005) //"Inicio do recalculo dos niveis."

	//Verifica se a procedure existe
	If ExistProc(cProcNam, VerIDProc())
		
		//Verifica se deve executar para todas as filiais.
		If lAllFil .And. FwAliasInDic("SMB", .F.)
			//Primeiro elimina a tabela SMB para incluir novamente com os níveis atualizados
			If deletaSMB(@cErro)
				//Recupera todas as filiais para executar 1 a 1.
				aFilProc := FwAllFilial(,,cEmpAnt,.F.)
				nTotal   := Len(aFilProc)

				For nIndex := 1 To nTotal
					nIniFil := MicroSeconds()
					LogNiv(STR0006 + aFilProc[nIndex]) //"Inicio do recalculo dos niveis. Filial: "

					//Somente executa a procedure se existir alguma estrutura na filial
					If T4N->(dbSeek(xFilial("T4N", aFilProc[nIndex])))
						//Executa a procedure no banco recuperando o retorno
						aResult := TCSPEXEC(xProcedures(cProcNam), xFilial("HWA", aFilProc[nIndex]), xFilial("T4N", aFilProc[nIndex]), aFilProc[nIndex], "1")
						
						//Se ocorreu algum erro, retorna o status de execução como falso
						If Empty(aResult) .Or. Valtype(aResult) <> "A"
							cErro := STR0001 + AllTrim(cProcNam) + ": " + TcSqlError() //"Erro na execução da Stored Procedure "
							lOk   := .F.
						EndIf
					EndIf

					LogNiv(STR0007 + aFilProc[nIndex] + ". " + STR0008 + cValToChar(MicroSeconds()-nIniFil)) //"Termino do recalculo de niveis. Filial: " Tempo total: "
					If !lOk
						Exit						
					EndIf
				Next nIndex

				aSize(aFilProc, 0)
			Else
				lOk := .F.
			EndIf
		Else
			//Executa a procedure no banco recuperando o retorno
			aResult := TCSPEXEC(xProcedures(cProcNam), xFilial("HWA"), xFilial("T4N"), "", "0")
			//Se ocorreu algum erro, retorna o status de execução como falso
			If Empty(aResult) .Or. Valtype(aResult) <> "A"
				cErro := STR0001 + AllTrim(cProcNam) + ": " + TcSqlError() //"Erro na execução da Stored Procedure "
				lOk   := .F.
			EndIf
		EndIf

	Else
		cErro := STR0002 + AllTrim(cProcNam) + STR0003 //"Stored Procedure " XXX " não instalada no banco de dados."
		lOk   := .F.
	EndIf

	LogNiv(STR0009 + cValToChar(MicroSeconds()-nInicio)) //"Termino do recalculo de niveis. Tempo total: "

	If !lOk
		LogNiv(STR0010 + cErro) // "Recalculo de niveis processado com erro. "
	EndIf

Return lOk

/*/{Protheus.doc} deletaSMB
Faz a exclusão dos dados da tabela SMB

@type  Static Function
@author lucas.franca
@since 11/09/2020
@version P12
@param cErro, caracter, mensagem de erro (passado por referência)
@return lRet, lógico  , indica se foi executada com sucesso
/*/
Static Function deletaSMB(cErro)
	Local cSql := ""
	Local lRet := .T.

	cSql := "DELETE FROM " + RetSqlName("SMB")

	If TcSqlExec(cSql) < 0
		cErro := STR0004 + TcSqlError() //"Erro ao excluir os dados da tabela SMB. "
		lRet  := .F.
	EndIf
Return lRet

/*/{Protheus.doc} LogNiv
Função para exibição de mensagens de log

@type  Static Function
@author lucas.franca
@since 17/09/2020
@version P12
@param cMessage, Character, Mensagem de log
@return Nil
/*/
Static Function LogNiv(cMessage)
	Local dDate := Date()
	Local cTime := Time()

	cMessage := "MRPProced - " + DtoC(dDate) + " - " + cTime + ": " + cMessage

	LogMsg('MRPProced', 0, 0, 1, '', '', cMessage)
Return Nil

/*/{Protheus.doc} VerIDProc
Identifica a sequência de controle do fonte ADVPL com a stored procedure.
Qualquer alteração que envolva diretamente a procedure a variavel será incrementada.
@author marcelo.neumann
@since 12/11/2019
@version P12
@return versão da procedure (compatibilidade)
/*/
Static Function VerIDProc()
Return '003'
