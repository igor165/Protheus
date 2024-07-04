#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "MNTSR.CH"

#DEFINE __AFIELDSO_SO__ 1
#DEFINE __AFIELDSO_INPUT__ 2
#DEFINE __AFIELDSO_STEP__ 3

//------------------------------------------------------------------------------
/*/{Protheus.doc} MntSR
Classe de Solicita��o de Servi�o - MntSR

@author Guilherme Freudenburg
@since 29/05/2018
@version P12
/*/
//------------------------------------------------------------------------------
Class MntSR FROM NGGenerico

	Method New() CONSTRUCTOR

	//------------------------------------------------------
	// Publico: Valida��o e Opera��o
	//------------------------------------------------------
	Method ValidBusiness() // Valida��es de neg�cio.
	Method Upsert() // M�todo para inclus�o e altera��o.
	Method CreateSO() // M�todo para gera��o de O.S.
	Method Delete() // M�todo para exclus�o.
	Method Assign() // M�todo para Distribui��o da S.S.
	Method Close()  // M�todo para Fechamento da S.S.

	//------------------------------------------------------
	// Publico: Status da S.S.
	//------------------------------------------------------
	Method IsAnalysis()  // Aguardando An�lise
	Method IsAssigned()  // Distribu�da
	Method IsClosed()    // Fechada
	Method IsCanceled()  // Cancelada (Somente Facilities)
	Method IsCreateSO()  // Verifica se est� no processo de Gera��o de OS
	Method IsAnswer()    // Verifica se est� no processo de Resposta Question�rio de Satisfa��o.

	//-------------------------------------------------------
	// Publico: Gera��o de OS
	//-------------------------------------------------------
	Method SetValueSO()   // M�todo para definir valores para gera��o de OS.
	Method HasSO()        // Verifica se existe OS em aberto para a SS.
	Method HasInput()     // Verifica se a OS possui insumos
	Method HasStep()      // Verifica se a OS possui etapas
	Method isCorrective() // Define se a O.S. � Corretiva
	Method isPreventive() // Define se a O.S. � Preventiva
	Method isThird()      // Indica se a O.S. � enviada para Terceiros

	//-------------------------------------------------------
	// Publico: Imagem
	//-------------------------------------------------------
	Method AddFile() // M�todo para adicionar imagem no Banco de Conhecimento
	Method GetFile() // M�todo para pegar imagem do Banco de Conhecimento
	Method GetFileList() // M�todo para pegar todas as imagens da S.S do Banco de Conhecimento
	Method DeleteFile()  // M�todo para excluir imagem do Bnaco de Conhecimento.

    //-------------------------------------------------------
	// Privado: Contador
	//-------------------------------------------------------
	Method HasCounter() // M�todo para identifica��o da utiliza��o de contador.

    //-------------------------------------------------------
	// Privado: Workflow
	//-------------------------------------------------------
	Method SendWF() // M�todo para envio de Workflow.

	//--------------------------------------------------------------------------
	// Privado: Atributos gerais
	//--------------------------------------------------------------------------
	Data aFieldSO As Array

EndClass

//------------------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo inicializador da classe

@author Guilherme Freudenburg
@since 01/06/2018
@version P12
@return Self, Objeto, objeto criado.
/*/
//------------------------------------------------------------------------------
Method New() Class MntSR

	_Super:New()

	// Alias formul�rio.
	::SetAlias("TQB")

	// Define o tipo de valida��o da classe.
	::SetValidationType("OUB")

	// Campos que n�o ser�o alterados.
	::SetUniqueField("TQB_FILIAL")
	::SetUniqueField("TQB_SOLICI")

	// Par�metros utilizados
	::SetParam("MV_NGSSWRK", "N") // Gera��o de Workflow.
	::SetParam("MV_NG1FAC" , "2") // Integra��o com Facilites.
	::SetParam("MV_NGMNTMS", "N") // Integra��o com o TMS.
	::SetParam("MV_NGMULOS", "N") // Permite gerar m�ltiplas OS's a partir do retorno da Distribui��o.
	::SetParam("MV_NGMNTFR", "N") // Indica se a empresa ira utilizar o Gestao de Frota.
	::SetParam("MV_NGSEREF", "")  // C�digo do servi�o para Reforma de Pneus.
	::SetParam("MV_NGSECON", "")  // Codigo de servico para conserto de pneus.
	::SetParam("MV_NGSSPRE", "N") // Indica se a Solicitacao de Servico podera gerar OS do tipo Preventiva/Preditiva.
	::SetParam("MV_NGPSATI", "N") // Indica se utiliza pesquisa de satisfa��o das solicita��es de servi�os.
	::SetParam("MV_NGUNIDT", "D") // Indica o formato de data utilizado.
	::SetParam("MV_NGTARGE", "2") // Indica se utiliza Tarefa Genr�rica.

	// Vari�veis Privadas
	::cClassName := "MntSR"// Determina o nome da classe.
	// Exemplo da estrutura do ::aFieldSO
	// aAdd(aFieldSO,{ {*Ordem de Servi�o 1*,{{Insumo 1}, {Insumo 2}, {Insumo 3}},{{Etapa 1}, {Etapa 2}, {Etapa 3}}} })
	::aFieldSO   := {} // Campos espec�ficos para Gera��o de OS.

	// Grava��o dos campos memo.
	::SetRelMemos({{"TQB_CODMSS", "TQB_DESCSS"},{"TQB_CODMSO","TQB_DESCSO"}})

Return Self

//------------------------------------------------------------------------------
/*/{Protheus.doc} ValidBusiness
M�todo que realiza a valida��o da regra de neg�cio da classe.

@param nOperation, Num�rico, Determina o numero da opera��o selecionado.

@author Guilherme Freudenburg
@author Wexlei Silveira
@since 01/06/2018
@return lValid, l�gico, confirma que os valores foram validados pela classe.
/*/
//------------------------------------------------------------------------------
Method ValidBusiness(nOperation) Class MntSR

	Local aArea     := GetArea()
	Local cError    := ""
	Local cUserName := RetCodUsr() // Retorna c�digo do usu�rio.
	Local lRet      := .T.
	Local lGetAsk   := ::GetAsk()
	Local aOldArea  := {}
	Local aRet      := {}
	Local aEntryPt  := {}
	Local aHelp     := {}
	Local cSRStatus := ""
	Local nInd      := 0
	Local nCost     := 0
	Local nHourIn   := 0
	Local nHourCt1  := 0
	Local nHourCt2  := 0
	Local nDateIn   := 0
	Local nAsset    := 0
	Local nCount1   := 0
	Local nCount2   := 0
	Local nX        := 0
	Local nTask     := 0
	Local nRegType  := 0
	Local nTlCode   := 0
	Local nQuant    := 0
	Local nStepTask := 0
	Local nStep     := 0
	Local nResQt    := 0
	Local nLocal    := 0
	Local nUse      := 0
	Local nUnity    := 0
	Local nRecord   := 0
	Local cInput    := ""
	Local dDateIn
	Local nService  := 0
	Local cService  := ""
	Local nSitua    := 0
	Local nSeque    := 0
	Local cSeque    := ""
	Local cAssetSO  := ""
	Local cFil2ST4  := NGTROCAFILI("ST4","")
	Local cFil2STE  := NGTROCAFILI("STE","")
	Local cFil2STF  := NGTROCAFILI("STF","")
	Local cHourSys  := SubStr( Time(), 1, 5 )
	Local cDateSys  := DToS( Date() )
	Local lDevice   := IsInCallStack("RESTEXECUTE") // Indica se vem do Mobile
	Local xPE280I   := Nil
	Local cCostTable  := If(CtbInUse(), "CTT", "SI3")
	Local cCostField  := If(CtbInUse(), "CTT_CUSTO", "I3_CUSTO")

	// Informa��es da TQB para valida��o.
	Local cBranch   := ::GetValue("TQB_FILIAL")
	Local cSolici   := ::GetValue("TQB_SOLICI")
	Local cDescSR   := ::GetValue("TQB_DESCSS")
	Local cTypeSR   := ::GetValue("TQB_TIPOSS")
	Local cAsset    := ::GetValue("TQB_CODBEM")
	Local cCostCnt  := ::GetValue("TQB_CCUSTO")
	Local cDateOp   := ::GetValue("TQB_DTABER")
	Local cHourOp   := ::GetValue("TQB_HOABER")
	Local cSolution := ::GetValue("TQB_SOLUCA")
	Local cCodeReq  := ::GetValue("TQB_CDSOLI")
	Local nCounter1 := ::GetValue("TQB_POSCON")
	Local nCounter2 := ::GetValue("TQB_POSCO2")
	Local cServCode := ::GetValue("TQB_CDSERV")
	Local cSupervi  := ::GetValue("TQB_FUNEXE")
	Local cWorkCnt  := ::GetValue("TQB_CENTRA")
	Local cExecCode := ::GetValue("TQB_CDEXEC")
	Local cPriority := ::GetValue("TQB_PRIORI")
	Local cOrder    := ::GetValue("TQB_ORDEM")
	Local cDateCl   := ::GetValue("TQB_DTFECH")
	Local cHourCl   := ::GetValue("TQB_HOFECH")
	Local cTime     := ::GetValue("TQB_TEMPO")
	Local cDeadL    := ::GetValue("TQB_PSAP")
	Local cNeed     := ::GetValue("TQB_PSAN")

	aRet      := NgFilTPN(cAsset,cDateOp,cHourOp,,cBranch)
	cSRStatus := Posicione("TQB",01,cBranch+cSolici,"TQB_SOLUCA")
	nCount1   := Posicione("TQB",01,cBranch+cSolici,"TQB_POSCON")
	nCount2   := Posicione("TQB",01,cBranch+cSolici,"TQB_POSCO2")

	//------------------------------------------------------------------------
	// MNTSR - Valida��es
	//------------------------------------------------------------------------
	If ::IsInsert()

		//------------------------------------------------------------------------
		// 1 - Valida��o de campos obrigat�rios na Inclus�o
		//------------------------------------------------------------------------

		// 1.1 - O campo Bem/Localiz. (TQB_CODBEM) deve estar preenchido.
		If Empty(cError) .And. Empty(cAsset) .And. !::IsUpdate()
			cError := ::MsgRequired('TQB_CODBEM') // O campo n�o foi preenchido.
		EndIf

		// 1.2 - O campo Solicitacao (TQB_SOLICI) deve estar preenchido.
		If Empty(cError) .And. Empty(cSolici)
			cError := ::MsgRequired('TQB_SOLICI') // O campo n�o foi preenchido.
		EndIf

		// 1.3 - O campo Tipo Item (TQB_TIPOSS) deve estar preenchido.
		If Empty(cError) .And. (!Empty(cTypeSR) .And. !(cTypeSR $ "BL"))
			cError := ::MsgRequired('TQB_TIPOSS') // O campo n�o foi preenchido.
		EndIf

		// 1.3.1 - O campo Servi�o (TQB_DESCSS) deve estar preenchido
		If Empty(cError) .And. Empty(cDescSR)
			cError := ::MsgRequired('TQB_DESCSS') // O campo n�o foi preenchido.
		EndIf

		// Valida��es de permiss�o para o bem/localiza��o
		If cTypeSR == "B" // Se for bem

			// 1.4 - O c�digo do bem precisa ser v�lido.
			dbSelectArea("ST9")
			dbSetOrder(1)
			If !dbSeek(xFilial("ST9") + cAsset)
				cError := STR0001 // "N�o existe Bem relacionado a este c�digo."
			Else

				// 1.5 - O bem precisa estar ativo.
				If ST9->T9_SITBEM == "I"//Bem Inativo
					cError := STR0002 // "O Bem est� Inativo no sistema."

				// 1.6 - O bem precisa pertencer a filial atual.
				ElseIf ST9->T9_SITBEM = "T"//Bem Transferido
					cError := STR0003 // "O Bem foi Transferido."

				// 1.7 - O bem precisa estar com manuten��o ativa.
				ElseIf ST9->T9_SITMAN = "I"//Situa��o do bem Inativa
					cError := STR0004 // "Situa��o da Manuten��o do bem est� Inativa."
				EndIf

			EndIf

		Else // Se for localiza��o
			// 1.8 - O usu�rio precisa ter permiss�o para incluir S.S. para bem informado.
			If Empty(cError) .And. Alltrim(Posicione("TAF", 7, cBranch + "X2" + Substr(cAsset, 1, 3), "TAF_CODNIV")) != AllTrim( cAsset )

				cError := STR0005 // "N�o existe Localiza��o relacionada a este c�digo."

			// 1.9 - O usu�rio precisa ter permiss�o para incluir S.S. para a localiza��o informada.
			ElseIf Empty(cError)

				dbSelectArea("TAF")
				dbSetOrder(2)
				If dbSeek(cBranch + "001" + Substr(cAsset, 1, 3))

					lRet := NGValidTUA() // Verifica se h� permiss�o para visualizar o registro.

					If lRet
						lRet := MNT902REST( TAF->TAF_CODNIV, 'S', 'I', .F. )
					EndIf

					If !lRet
						cError := STR0006 // "Usu�rio sem permiss�o para incluir solicita��es para esta localiza��o."
					EndIf

				EndIf

			EndIf

		EndIf

		// 1.10 - O campo Centro Custo (TQB_CCUSTO) deve referenciar um centro de custo na tabela SI3 conforme regras do CTB.
		If Empty(cError) .And. cTypeSR != "L" .And. !Empty(cCostCnt) // N�o valida para localiza��o

			If Alltrim(cCostCnt) != Alltrim(aRet[2]) .Or. Empty(Alltrim(Posicione(cCostTable,1,xFilial(cCostTable) + cCostCnt,cCostField)))
				cError := STR0007 // "O Centro de Custo informado � incorreto, conforme hist�rico de movimenta��es."
			EndIf

		EndIf

		// 1.11 - O campo Centro Trabalho (TQB_CENTRA) deve estar de acordo com o Centro de Trabalho cadastrado na ST9 para o bem e com a TPN.
		If Empty(cError) .And. cTypeSR != "L" .And. !Empty(cWorkCnt) // N�o valida para localiza��o

			dbSelectArea("ST9")
			dbSetOrder(1)
			If dbSeek(cBranch + cAsset)

				If !Empty(ST9->T9_CENTRAB) .And. Alltrim(cWorkCnt) != Alltrim(ST9->T9_CENTRAB)
					cError := STR0008 // "O Centro de Trabalho informado � inv�lido."
				EndIf

			EndIf

			If Empty(cError) .And. Alltrim(cWorkCnt) != Alltrim(aRet[3])
				cError := STR0009 // "O Centro de Trabalho informado � incorreto, conforme hist�rico de movimenta��es."
			EndIf

		EndIf

		// 1.12 - O campo Dt. Abertura (TQB_DTABER) deve estar preenchido e ser menor ou igual a data atual.
		If Empty(cError)
			If Empty(cDateOp)
				cError := ::MsgRequired('TQB_DTABER') // O campo n�o foi preenchido.
			ElseIf cDateOp > dDataBase
				cError := STR0010 + Alltrim(Posicione("SX3",2,"TQB_DTABER","X3Titulo()")) + STR0011 // "O campo " #### " deve ser menor ou igual a data atual."
			ElseIf cDateOp == dDataBase .And. cHourOp > SubStr(Time(),1,5)
				cError := STR0010 + Alltrim(Posicione("SX3",2,"TQB_HOABER","X3Titulo()")) + STR0012 // "O campo " #### " deve ser menor ou igual a hora atual."
			EndIf
		EndIf

		// 1.13 - O campo Hr. Abertura (TQB_HOABER) deve estar preenchido.
		If Empty(cError) .And. Empty(cHourOp)
			cError := ::MsgRequired('TQB_HOABER') // O campo n�o foi preenchido.
		EndIf

		// 1.14 - O campo Hr. Abertura (TQB_HOABER) deve estar preenchido e ser v�lido.
		If Empty(cError) .And. !Empty(cHourOp) .And. !NGVALHORA(cHourOp,.F.)
			cError := STR0010 + Alltrim(Posicione("SX3",2,"TQB_HOABER","X3Titulo()")) + STR0013 // "O campo " #### " deve ser v�lido."
		EndIf

		// 1.15 - O campo Situacao S.S (TQB_SOLUCA) deve estar preenchido.
		If Empty(cError) .And. Empty(cSolution)
			cError := ::MsgRequired('TQB_SOLUCA') // O campo n�o foi preenchido.
		EndIf

		// 1.16 - O campo Situacao S.S (TQB_SOLUCA) deve estar preenchido e conter o valor "ADEC" .
		If Empty(cError) .And. !Empty(cSolution) .And. !( Left( cSolution, 1 ) $ 'A/D/E/C' )
			cError := STR0010 + Alltrim(Posicione("SX3",2,"TQB_SOLUCA","X3Titulo()")) + STR0014 // "O campo " #### " deve estar preechido e conter um valor entre: A, D, E ou C."
		EndIf

		// 1.17 - O campo Supervisor (TQB_FUNEXE) precisa ser v�lido.
		If Empty(cError) .And. !Empty(cSupervi) .And. !Empty(cServCode)
			aRet := NGFUNCRH( cSupervi, .F., , ,.T. )
			If !aRet
				cError := aRet[2]
			EndIf
			If Empty(cError) .And. Alltrim(Posicione("ST1",1,cSupervi,"T1_CODFUNC")) != Alltrim(cSupervi)
				cError := STR0015 + Alltrim(Posicione("SX3",2,"TQB_FUNEXE","X3Titulo()")) + STR0016 //"O valor informado no campo " #### " n�o foi encontrado na tabela de funcion�rios da manuten��o."
			EndIf
		EndIf

		// 1.18 - O campo Solicitante (TQB_CDSOLI) deve estar preenchido.
		If Empty(cError) .And. Empty(cCodeReq)
			cError := ::MsgRequired('TQB_CDSOLI') // O campo n�o foi preenchido.
		EndIf

		// 1.19 - O usu�rio do campo Solicitante (TQB_CDSOLI) deve existir.
		If Empty(cError) .And. !Empty(cCodeReq)

			PswOrder(1) // Posiciona no usu�rio
			If !PswSeek(cCodeReq, .T.)
				cError := STR0017 //"N�o existe usu�rio relacionado � este c�digo."
			EndIf

		EndIf

		// 1.20 - O campo Tipo Servico (TQB_CDSERV) precisa ser v�lido.
		If Empty(cError) .And.  !Empty(cServCode)
			cError := fValServ(cServCode)
		EndIf

		//------------------------------------------------------------------------
		// 2 - Valida��es a n�vel de relacionamentos
		//------------------------------------------------------------------------

		// 2.1 - Valida��o de escala de viagem para o per�odo da SS.
		If Empty(cError) .And. ::GetParam("MV_NGMNTMS", "N") == "S"
			aHelp := NGCHKTMS(cAsset, cDateOp, cHourOp, .F.)
			If !aHelp[2]
				If aHelp[3]
					cError := aHelp[1]
				ElseIf lGetAsk
					::AddAsk(aHelp[1])
				EndIf
			EndIf
		EndIf

		// 2.2 - Valida��o de exist�ncia de S.S. duplicada
		If Empty(cError) .And. !Empty(cAsset) .And. !Empty(cServCode)
			If fDplSR(Self, cAsset, cServCode)
				If lGetAsk
					::AddAsk( STR0018 ) // "Existe pelo menos uma Solicita��o de Servi�o inclu�da para o mesmo bem/localiza��o e �rea de manuten��o desta S.S."
				EndIf
			EndIf
		EndIf

		// 2.3 - Valida��o de exist�ncia de O.S. vencidas.
		If Empty(cError) .And. !Empty(cAsset)

			aRet := NGOSABRVEN( cAsset,,.F.,.T.,.T.,,, .F., .T., 2 )

			If aRet[1]
				If aRet[3]
					cError := aRet[2]
				ElseIf lGetAsk
					::AddAsk(aRet[2])
				EndIf
			EndIf
		EndIf

		// 3.3 - O campo Contador (TQB_POSCON) deve estar preenchido com um valor v�lido
		If Empty(cError) .And. nCounter1 != 0

			aRet := fValCnt(cAsset, cDateOp, cHourOp, nCounter1, 1, lGetAsk)

			If !Empty( aRet[2] )

				If aRet[1]
					::AddAsk( aRet[2] )
				Else
					cError := aRet[2]
				EndIf

			EndIf

		EndIf

		// 3.4 - O campo Contador 2 (TQB_POSCO2) deve estar preenchido com um valor v�lido
		If Empty(cError) .And. nCounter2 != 0

			aRet := fValCnt(cAsset, cDateOp, cHourOp, nCounter2, 2, lGetAsk)

			If !Empty( aRet[2] )

				If aRet[1]
					::AddAsk( aRet[2] )
				Else
					cError := aRet[2]
				EndIf

			EndIf

		EndIf

		//---------------------------------------------------------
		// Verifica se h� pesquisa pendente para o usu�rio
		//---------------------------------------------------------
		If ::GetParam("MV_NGPSATI", "N") == "S" .And. !lDevice .And. isPending()
			cError := STR0019 // "Para abrir uma nova Solicita��o de Servi�o, voc� dever� responder as pesquisas de satisfa��o pendentes."
		EndIf

	ElseIf ::IsUpdate() .And. !::IsCreateSO() .And. !::IsAnswer()

		// 3.3 - O campo Contador (TQB_POSCON) deve estar preenchido com um valor v�lido quando informado.
		If Empty(cError) .And. nCount1 != nCounter1
			cError := STR0020 // "N�o � poss�vel alterar o contador."
		EndIf

		If Empty(cError) .And. nCount2 != nCounter2
			cError := STR0020 // "N�o � poss�vel alterar o contador."
		EndIf

		If ::IsAnalysis() // Altera��o de SS com status "Aguardando An�lise"

			If ::HasSO(cSolici)

				cError := STR0021 // "N�o � poss�vel alterar esta S.S. pois ela j� possui Ordem de Servi�o."

			EndIf

			// 3.1 - O campo Servi�o (TQB_DESCSS) deve estar preenchido.
			If Empty(cError) .And. Empty(cDescSR)
				cError := ::MsgRequired('TQB_DESCSS') // O campo n�o foi preenchido.
			EndIf

			// 3.2 - O campo Tipo Servico (TQB_CDSERV) precisa ser v�lido.
			If Empty(cError) .And.  !Empty(cServCode)
				cError := fValServ(cServCode)
			EndIf

		ElseIf ::IsAssigned() // Distribui��o de S.S.

			If cSRStatus != "D" // Distribui��o de S.S.
				//------------------------------------------------------------------------
				// 5 - Valida��es do processo de Distribui��o de Solicita��o de Servi�o
				//------------------------------------------------------------------------

				// 5.1 - O campo Executante (TQB_CDEXEC) deve ser preenchido.
				If Empty(cError) 
					If Empty(cExecCode)
						cError := ::MsgRequired('TQB_CDEXEC') // O campo n�o foi preenchido.
					ElseIf ::GetParam( 'MV_NG1FAC', .F., '2') == '2' .And. !NGIFDBSEEK( 'TQ4', cExecCode, 1, .F. )
						cError := STR0083 // 'C�digo do executante informado n�o � v�lido!'
					ElseIf ::GetParam( 'MV_NG1FAC', .F., '2') == '1' .And.  ( !NGIFDBSEEK( 'ST1', cExecCode, 1, .F. ) .Or. ST1->T1_TIPATE == '1' ) 
						cError := STR0083 // 'C�digo do executante informado n�o � v�lido!'
					EndIf
				EndIf
				
				// 5.2 - O campo Tipo Servi�o (TQB_CDSERV) deve ser preenchido.
				If Empty(cError)
					If Empty(cServCode)
						cError := ::MsgRequired('TQB_CDSERV') // O campo n�o foi preenchido.
					ElseIf !NGIFDBSEEK( 'TQ3', cServCode, 1, .F. )
						cError := STR0084 // 'Servi�o informado n�o � v�lido!'
					EndIf

				// 5.3 - O campo Prioridade (TQB_PRIORI) deve ser preenchido.
				ElseIf Empty(cError) .And. Empty(cPriority) .And.  X3Obrigat('TQB_PRIORI')
					cError := ::MsgRequired('TQB_PRIORI') // O campo n�o foi preenchido.
				EndIf

				// 5.3.1 - O campo Servi�o (TQB_DESCSS) deve estar preenchido
				If Empty(cError) .And. Empty(cDescSR)
					cError := ::MsgRequired('TQB_DESCSS') // O campo n�o foi preenchido.
				EndIf

				If Empty(cError)

					// 5.4 - N�o � poss�vel distribuir solicita��es de servi�o com status diferente de Aguardando An�lise (TQB_SOLUCA <> A).
					If cSRStatus != "A"
						cError := STR0022 // "N�o � poss�vel distribuir esta Solicita��o de Servi�o pois ela j� foi distribu�da."

					// 5.5 - N�o � poss�vel distribuir solicita��es de servi�o caso elas j� possuam ordens de servi�o relacionadas.
					ElseIf ::GetParam("MV_NGMULOS", "N") == "S"
						If !Empty(Alltrim(cOrder))
							cError := STR0023 // "N�o � poss�vel distribuir esta Solicita��o de Servi�o pois ela j� possui Ordem de Servi�o."
						EndIf
					EndIf

				EndIf

				//Ponto de Entrada para validar campos preenchidos ou n�o ap�s distribui��o da SS.
				If ExistBlock("MNTA295A")
					If !ExecBlock( "MNTA295A", .F., .F. ) //Se o Retorno do PE for falso.
						cError := STR0024 // "A valida��o adicionada no ponto de entrada MNTA295A est� impossibilitando a continuidade do processo."
					EndIf
				EndIf

			EndIf

		ElseIf ::IsClosed() // Fechamento de S.S.

			//|------------------------------------------------------------------------
			//| 7 - Valida��es do processo de Fechamento de Solicita��o de Servi�o
			//|------------------------------------------------------------------------
			If cSRStatus != "E" // Fechamento de S.S.

				// 7.1 - N�o � permitido fechar solicita��es de servi�o n�o distribu�das.
				If cSRStatus != "D"
					cError = STR0025 // "N�o � poss�vel fechar esta solicita��o, pois ela ainda n�o foi distribu�da."
				EndIf

				// 7.2 - N�o � poss�vel fechar uma S.S. que possua Ordem de Servi�o em aberto.
				If Empty(cError) .And. ::HasSO(cSolici)
					cError := STR0026 // "N�o � poss�vel fechar esta S.S. pois ela ainda possui Ordem de Servi�o aberta."
				EndIf

				If !Empty(cDateCl)
					// 7.3 - Se preenchido, campo TQB_DTFECH n�o pode ser maior que a data atual.
					If Empty(cError) .And. cDateCl > dDataBase
						cError := STR0027 // "A data de fechamento n�o pode ser maior que a data atual."
					EndIf

					// 7.4 - Se preenchido, campo TQB_DTFECH n�o pode ser menor que a data de abertura da S.S.
					If Empty(cError) .And. cDateCl < cDateOp
						cError := STR0028 // "A data de fechamento n�o pode ser menor que a data de abertura."
					EndIf

				EndIf

				If !Empty(cHourCl)

					If Empty(cDateCl)
						cError := ::MsgRequired('TQB_DTFECH') // O campo n�o foi preenchido.
					EndIf

					// 7.5 - Se preenchido, campo TQB_HOFECH n�o pode ser maior que a hora atual.
					If Empty(cError) .And. (cDateCl == dDataBase .And. cHourCl > SubStr(Time(),1,5))
						cError := STR0029 // "A hora de fechamento n�o pode ser maior que a hora atual."
					EndIf

					// 7.6 - Se preenchido, campo TQB_HOFECH deve ser maior que a hora de abertura da S.S.
					If Empty(cError) .And. (cDateCl == cDateOp .And. cHourCl <= cHourOp)
						cError := STR0010 + Alltrim(Posicione("SX3",2,"TQB_HOFECH","X3Titulo()")) + STR0030 // "O campo " #### " deve ser maior que a hora de abertura da S.S."
					EndIf

				EndIf

				// 7.7 - Campo TQB_TEMPO precisa ser maior que zero
				If Empty(cError) .And. (Empty(cTime) .Or. Val(AllTrim(StrTran(cTime,":",""))) == 0)
					cError := ::MsgRequired('TQB_TEMPO') // O campo n�o foi preenchido.
				EndIf

				// Ponto de Entrada MNTA2908 - Valida��o de campos n�o vazios
				If Empty(cError)
					If ExistBlock("MNTA2908")
						aEntryPt := ExecBlock("MNTA2908",.F.,.F.)
						If Len(aEntryPt) > 0
							For nX := 1 To Len(aEntryPt)
								If Empty(::GetValue(aEntryPt[nX,1])) .And. Empty(cError)
									cError := aEntryPt[nX,2]
								EndIf
							Next nX
						EndIf
					EndIf
				EndIf
			EndIf

		EndIf

		// 7.8 - N�o � poss�vel alterar o contador se a SS n�o estiver com status "Aguardando An�lise"
		If !::IsAnalysis()

			If Empty(cError) .And. nCount1 != nCounter1
				cError := STR0020 // "N�o � poss�vel alterar o contador."
			EndIf

			If Empty(cError) .And. nCount2 != nCounter2
				cError := STR0020 // "N�o � poss�vel alterar o contador."
			EndIf

		EndIf

	ElseIf ::IsDelete()

		//------------------------------------------------------------------------
		// 4. Valida��es do processo de Exclus�o de Solicita��o de Servi�o
		//------------------------------------------------------------------------

		// 4.1 - Ponto de Entrada MNTA280E - N�o permite excluir S.S se o usu�rio de dele��o for diferente do usu�rio que incluiu a S.S.
		If ExistBlock( "MNTA280E" )
			If !ExecBlock( "MNTA280E", .F., .F. )
				cError := STR0031 // "O usu�rio � diferente do que realizou a abertura da solicita��o de servi�o."
			EndIf
		Else
			// 4.2 - Dele��o permitida apenas para o solicitante da S.S. ou usu�rio pertencente ao grupo de administradores.
			If AllTrim(cCodeReq) != AllTrim(cUserName) .And. !FwIsAdmin() //Verifica se o usuario e mesmo que abriu a SS ou se e administrador
				cError := STR0032 // "Dele��o permitida apenas para o Solicitante da S.S. ou um usu�rio do grupo de Administradores."
			EndIf
		EndIf

		// 4.3 - N�o � permitido a exclus�o de solicita��es de servi�o j� distribu�das.
		If Empty(cError) .And. cSolution != "A"
			cError := STR0033 // "Opera��o n�o permitida. A S.S. j� foi distribu�da."
		EndIf

		// 4.4 - N�o � permitido a exclus�o de solicita��es de servi�o que j� possuam Ordem de Servi�o relacionada.
		If Empty(cError) .And. ::HasSO(cSolici)
			cError := STR0034 // "N�o � poss�vel deletar esta S.S. pois ela j� possui Ordem de Servi�o."
		EndIf

	ElseIf ::IsCreateSO() // Verifica se � chamado pela Gera��o de OS.

		//------------------------------------------------------------------------
		// 6 - Valida��es do processo de Gera��o de Ordem de Servi�o
		//------------------------------------------------------------------------

		// 6.1 - Verifica se a solicita��o de servi�o j� foi distribuida.
		If Empty(cError) .And. !::IsAssigned()
			cError := STR0035 // "O Solicita��o de Servi�o n�o est� distribu�da."
		EndIf

		// 6.2 - Verifica se a Solicita��o de Servi�o possui Ordens de Servi�o.
		If ::HasSO(cSolici) .And. ::GetParam("MV_NGMULOS", "N") == "N"
			cError := STR0036 // "J� foi gerada Ordem de Servi�o para a Solicita��o."
		EndIf

		nRecord := Len(::aFieldSO) // Verifica se existe algum registro para gera��o de OS.

		If Empty(cError) .And. nRecord > 0

			nAsset   := aScan( ::aFieldSO[nRecord,__AFIELDSO_SO__], {|x| AllTrim( Upper( X[1] ) ) == 'TJ_CODBEM' }  )
			nDateIn  := aScan( ::aFieldSO[nRecord,__AFIELDSO_SO__], {|x| AllTrim( Upper( X[1] ) ) == 'TJ_DTORIGI' } )
			nHourCt1 := aScan( ::aFieldSO[nRecord,__AFIELDSO_SO__], {|x| AllTrim( Upper( X[1] ) ) == 'TJ_HORACO1' } )
			nHourCt2 := aScan( ::aFieldSO[nRecord,__AFIELDSO_SO__], {|x| AllTrim( Upper( X[1] ) ) == 'TJ_HORACO2' } )

			For nInd := 1 To Len(::aFieldSO[nRecord, __AFIELDSO_SO__])

				// 6.3 - Valida��es do campo "Bem"
				If ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_CODBEM"
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
						cError := ::MsgRequired(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1]) // O campo n�o foi preenchido.
					EndIf

				// 6.4 - Valida��es do campo "Servi�o"
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_SERVICO"
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
						cError := ::MsgRequired(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1]) // O campo n�o foi preenchido.
					EndIf
					// 6.4.1 - Caso servi�o da Solicita��o de Servi�o seja Reforma ou Conserto de Pneus,
					//  n�o ser� permitido fazer pela rotina, mas apenas pela rotina de O.S. Em Lote.
					If ::GetParam("MV_NGMNTFR", "N") == "S" //Efetua a valida��o somente se for Frota
						If (!Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2]) .And. !Empty(::GetParam("MV_NGSEREF", "")) .And.;
							Alltrim(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2]) == Alltrim(::GetParam("MV_NGSEREF", ""))) .Or.;
							(!Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2]) .And. !Empty(::GetParam("MV_NGSECON", "")) .And.;
							Alltrim(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2]) == Alltrim(::GetParam("MV_NGSECON", "")))
							cError := STR0037 // "Para abertura e finaliza��o de O.S. com o servi�o de Reforma ou Conserto de Pneus, "
							cError += STR0038 // "conforme definido nos par�metros MV_NGSEREF e MV_NGSECON, deve ser utilizada a rotina de O.S. Em Lote."
						EndIf
					EndIf
					// 6.4.2 - O servi�o informado, presente na tabela ST4, deve ser do tipo Corretivo, caso o parametro MV_NGSSPRE for diferente de "S".
					If AllTrim(::GetParam("MV_NGSSPRE", "")) == "N"
						aRet := NGTIPSER(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2],"C",.F.)
						If !aRet[1]
							If aRet[2] == 'SERVNAOEXI'
								cError := STR0039 // 'O servi�o informado n�o existe.'
							ElseIf aRet[2] == 'REGBLOQ' // 6.4.3 - O servi�o informado, presente na tabela ST4, n�o pode estar bloqueado para uso (T4_MSBLQL = 1).
								cError := STR0040 // 'Entre em contato com o administrador do sistema ou o respons�vel pelo registro para identificar o motivo do bloqueio.'
							ElseIf aRet[2] == 'TPSERVNEXI'
								cError := STR0041 // 'Informe um servico do tipo Corretivo.'
							ElseIf aRet[2] == 'SERVNAOCOR'
								cError := STR0042 // 'Servi�o informado n�o � do tipo Corretivo.'
							ElseIf aRet[2] == 'NSERVPREVE'
								cError := STR0043 // 'Para esta op��o informar um servico do  tipo preventivo.'
							EndIf
						EndIf
					Else
						aOldArea := GetArea()
						dbSelectArea("ST4")
						dbSetOrder(1)
						If !dbSeek(xFilial("ST4")+::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
							cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1],"X3Titulo()")) + STR0044 // "O campo " #### " deve ser preenchido corretamente."
							RestArea(aOldArea)
						Else
							If !NGSERVBLOQ(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2],.F.)[1] // 6.4.3 - O servi�o informado, presente na tabela ST4, n�o pode estar bloqueado para uso (T4_MSBLQL = 1).
								cError := STR0045 // "Este registro est� bloqueado para uso."
							EndIf
						EndIf
						RestArea(aOldArea)
					EndIf

				// 6.5 - Valida��es do campo "Dt. Original"
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_DTORIGI"
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
						cError := ::MsgRequired(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1]) // O campo n�o foi preenchido.
					EndIf
					// 6.5.1 - O campo Data Original (TJ_DTORIGI) n�o pode ser menor que a Data e Hora de abertura da S.S.
					If ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] < ::GetValue("TQB_DTABER")
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1],"X3Titulo()")) + STR0046 // "O campo " #### " deve conter um valor maior ou igual a data de abertura."
					EndIf

				// 6.6 - Valida��es do campo "Contador" - primeiro contador
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_POSCONT"

					If Empty(cError) .And. ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] != 0

						aRet := fValCnt( ::aFieldSO[nRecord,__AFIELDSO_SO__,nAsset,2], ::aFieldSO[nRecord,__AFIELDSO_SO__,nDateIn,2],;
						::aFieldSO[nRecord,__AFIELDSO_SO__,nHourCt1,2], ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2], 1, lGetAsk )

						If !Empty( aRet[2] )

							If aRet[1]
								::AddAsk( aRet[2] )
							Else
								cError := aRet[2]
							EndIf

						EndIf

					EndIf

				// 6.7 - Valida��es do campo "Contador 2"
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_POSCON2"

					If Empty(cError) .And. ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] != 0

						aRet := fValCnt( ::aFieldSO[nRecord,__AFIELDSO_SO__,nAsset,2], ::aFieldSO[nRecord,__AFIELDSO_SO__,nDateIn,2],;
						::aFieldSO[nRecord,__AFIELDSO_SO__,nHourCt2,2], ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2], 2, lGetAsk )

						If !Empty( aRet[2] )

							If aRet[1]
								::AddAsk( aRet[2] )
							Else
								cError := aRet[2]
							EndIf

						EndIf

					EndIf

				// 6.8 - Valida��es do campo "Hora cont. 1"
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_HORACO1"
					
					// 6.8.1 - Valor informado deve ser uma hora valida.
					If Empty(cError) .And. !Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2]) .And. !NGVALHORA(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2],.F.)
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1],"X3Titulo()")) + STR0013 // "O campo " #### " deve ser v�lido."
					EndIf

					// 6.8.2 - Valor informado n�o deve ser superior a hora atual do sistema.
					If Empty( cError ) .And. ( DToS( ::aFieldSO[nRecord,__AFIELDSO_SO__,nDateIn,2] ) + ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] ) > ( cDateSys + cHourSys )
						
						// A hora de leitura do contador 1: XX:XX n�o deve ser maior que a hora atual do sistema: XX:XX
						cError := STR0081 + '1: ' + ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] + STR0082 + cHourSys

					EndIf

				// 6.9 - Valida��es do campo "Hora cont. 2"
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_HORACO2"
					
					// 6.9.1 - Valor informado deve ser uma hora valida.
					If Empty(cError) .And. !Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2]) .And. !NGVALHORA(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2],.F.)
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1],"X3Titulo()")) + STR0013 // "O campo " #### " deve ser v�lido."
					EndIf

					// 6.9.2 - Valor informado n�o deve ser superior a hora atual do sistema.
					If Empty( cError ) .And. ( DToS( ::aFieldSO[nRecord,__AFIELDSO_SO__,nDateIn,2] ) + ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] ) > ( cDateSys + cHourSys )
						
						// A hora de leitura do contador 2: XX:XX n�o deve ser maior que a hora atual do sistema: XX:XX
						cError := STR0081 + '2: ' + ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] + STR0082 + cHourSys

					EndIf

				// 6.10 - Valida��es do campo "Centro Custo"
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_CCUSTO"
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
						cError := ::MsgRequired(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1]) // O campo n�o foi preenchido.
					EndIf
					If Empty(cError) .And. Alltrim(Posicione(cCostTable,1,xFilial(cCostTable) + ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2],cCostField)) != Alltrim(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1],"X3Titulo()")) + STR0047 // "O campo " #### " est� inv�lido."
					EndIf

				// 6.11 - Valida��es do campo "Centro Trab."
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_CENTRAB"
					If Empty(cError)
						nCost := aScan(::aFieldSO[nRecord,__AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_CCUSTO" })
						dbSelectArea("SHB")
						dbSetOrder(01) //HB_FILIAL+HB_COD
						If dbSeek(xFilial("SHB") + ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
							If AllTrim( SHB->HB_CC ) <> AllTrim( ::aFieldSO[nRecord,__AFIELDSO_SO__,nCost,2] )
								cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1],"X3Titulo()")) + STR0047 // "O campo " #### " est� inv�lido."
							EndIf
						EndIf
					EndIf

				// 6.12 - Valida��es do campo "Real. In�cio"
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_DTPRINI"
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
						cError := ::MsgRequired(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1]) // O campo n�o foi preenchido.
					EndIf
					If Empty(cError)
						nHourIn := aScan(::aFieldSO[nRecord,__AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_HOPRINI" })
						If ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2] == dDataBase
							If ::aFieldSO[nRecord,__AFIELDSO_SO__,nHourIn,2]  > SubStr(Time(),1,5)
								cError := STR0048 // "A 'Hora Inicio Parada Real' � maior que a hora atual."
							EndIf
						ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nDateIn,2] > dDataBase
							cError := STR0049 // "A 'Data Parada Real Inicio' n�o pode ser maior que a data atual."
						EndIf
					EndIf

				// 6.13 - Valida��es do campo "Real. In�cio"
				ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1] == "TJ_HOPRINI"
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2])
						cError := ::MsgRequired(::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,1]) // O campo n�o foi preenchido.
					EndIf
					If Empty(cError)
						nDateIn := aScan(::aFieldSO[nRecord,__AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_DTPRINI" })
						If ::aFieldSO[nRecord,__AFIELDSO_SO__,nDateIn,2] == dDataBase
							If ::aFieldSO[nRecord,__AFIELDSO_SO__,nInd,2]  > SubStr(Time(),1,5)
								cError := STR0048 // "A 'Hora Inicio Parada Real' � maior que a hora atual."
							EndIf
						ElseIf ::aFieldSO[nRecord,__AFIELDSO_SO__,nDateIn,2] > dDataBase
							cError := STR0049 // "A 'Data Parada Real Inicio' n�o pode ser maior que a data atual."
						EndIf
					EndIf

				EndIf

				If !Empty(cError)
					Exit
				EndIf

			Next nInd

			// 6.13.2 - Valida��es de Ordem de Servi�o Preventiva
			If Empty(cError) .And. ::isPreventive(nRecord) .And. AllTrim(::GetParam("MV_NGSSPRE", "")) == "S"
				For nInd := 1 To Len(::aFieldSO)

					// Busca a posi��o dos campos.
					nService := aScan(::aFieldSO[nRecord, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_SERVICO"})
					nSitua   := aScan(::aFieldSO[nRecord, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_SITUACA"})
					nSeque   := aScan(::aFieldSO[nRecord, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_SEQRELA"})

					dDateIn  := ::aFieldSO[nRecord,__AFIELDSO_SO__,nDateIn,2]
					cAssetSO := ::aFieldSO[nRecord,__AFIELDSO_SO__,nAsset,2]
					cService := ::aFieldSO[nRecord,__AFIELDSO_SO__,nService,2]
					cSeque   := ::aFieldSO[nRecord,__AFIELDSO_SO__,nSeque,2]

					dbSelectArea("ST4")
					dbSetOrder(1)
					If dbSeek(cFil2ST4+cService)
						dbSelectArea("STE")
						dbSetOrder(1)
						If dbSeek(cFil2STE+ST4->T4_TIPOMAN) .And. STE->TE_CARACTE != 'P'
							cError := STR0078 // "Tipo de servi�o dever� ser preventivo."
						EndIf
					EndIf

					If Empty(cError)
						dbSelectArea("STF")
						dbSetOrder(1)
						If !dbSeek(cFil2STF+cAssetSO+cService+cSeque)
							cError := STR0079 // "Sequ�ncia da manuten��o n�o cadastrada."
						EndIf
					EndIf

					If Empty(cError)
						cError := NGPREVBSS("B",cAssetSO,cService,dDateIn,cSeque,.F.) // verifica se ja tem O.S pra data
					EndIf

					If !Empty(cError)
						Exit
					EndIf
				Next nInd
			EndIf

			// Valida��o de Insumos da OS.
			If Empty(cError) .And. ::HasInput(nRecord)

				For nX := 1 To Len(::aFieldSO[nRecord, __AFIELDSO_INPUT__])

					nTask    := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_TAREFA"})
					nRegType := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_TIPOREG"})
					nTlCode  := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_CODIGO"})
					nQuant   := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_QUANTID"})
					nResQt   := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_QUANREC"})
					nUse     := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_DESTINO"})
					nLocal   := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_LOCAL"})
					nUnity   := aScan(::aFieldSO[nRecord, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_UNIDADE"})
					cInput   := ::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nRegType,2] // Tipo do insumo

					If ::GetParam("MV_NGTARGE", "2") == "1" .And. ::isCorrective(nRecord) // TODO: Tratar o caso de tarefa generica no upsert da OS

						// 6.14 - Na previs�o de insumos, o campo Tarefa (TL_TAREFA) deve ser preenchido.
						If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTask,2])
							cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTask,1],"X3Titulo()")) + STR0050 // "O campo " #### STR0020
						EndIf

						// 6.15 - O c�digo da tarefa deve ser um valor v�lido.
						If Empty(cError) .And. !NGIFDBSEEK("TT9", ::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTask,2], 1)
							cError := STR0051 // 'O C�digo da tarefa n�o foi encontrado na tabela "TT9 - Tarefas Gen�ricas".'
						EndIf

					EndIf

					//------------------------------------------------------------------------
					// 8.2 - Se OS for Preventiva, a Tarefa deve estar preenchida com um
					// c�digo existente na tabela ST5 - Tarefas da Manuten��o.
					//------------------------------------------------------------------------
					If Empty(cError) .And. ::isPreventive(nRecord) .And. AllTrim(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTask,2]) <> "0" .And.;
					   !NGIFDBSEEK("ST5", ::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTask,2], 5)
						cError := STR0052 // "O Campo tarefa n�o existe ou pertence � tabela 'ST5 - Tarefas da Manuten��o'"
					EndIf

					//------------------------------------------------------------------------
					// 6.16 -Campo TL_TIPOREG � obrigat�rio
					//------------------------------------------------------------------------
					If Empty(cError) .And. Empty(cInput)
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nRegType,1],"X3Titulo()")) + STR0050 // "O campo " #### " � obrigat�rio."
					EndIf

					//------------------------------------------------------------------------
					// 6.17 - C�digo de Tipo de Insumo deve ser preenchido corretamente.
					//------------------------------------------------------------------------
					If Empty(cError) .And. !(cInput $ "F/M/P/T/E")
						cError := STR0053 + CRLF // "O C�digo do Tipo de insumo deve ser preenchido corretamente com: "
						cError += STR0054 + CRLF // "P � Produto"
						cError += STR0055 + CRLF // "M � Funcion�rio (M�o de Obra)"
						cError += STR0056 + CRLF // "F � Ferramenta"
						cError += STR0057 + CRLF // "T � Terceiros"
						cError += STR0058 // "E � Especialidade."
						::addError(cError)
					EndIf

					//------------------------------------------------------------------------
					// 8.5 -Quando informado Ferramenta ou Especialidade, Quantidade de Recurso deve ser informado
					//------------------------------------------------------------------------
					If Empty(cError) .And. (cInput == "F" .Or. cInput == "E") .And. Empty(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nResQt,2])
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nResQt,1],"X3Titulo()")) +; // "O campo " ####
						          STR0059 // " � obrigat�rio para insumos do tipo Ferramenta e Especialidade."
					EndIf

					//------------------------------------------------------------------------
					// 6.18 -Campo TL_CODIGO � obrigat�rio
					//------------------------------------------------------------------------
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTlCode,2])
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTlCode,1],"X3Titulo()")) + STR0050 // "O campo " #### " � obrigat�rio."
					EndIf

					//------------------------------------------------------------------------
					// 8.7 - Campo TL_QUANTID � obrigat�rio e precisa ser maior que zero
					//------------------------------------------------------------------------
					If Empty(cError) .And. (Empty(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nQuant,2]) .Or. ::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nQuant,2] <= 0)
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nQuant,1],"X3Titulo()")) + STR0050 // "O campo " #### " � obrigat�rio."
					EndIf

					//------------------------------------------------------------------------
					// 6.19 - Se insumo for Ferramenta, c�digo deve existir na tabela SH4
					//------------------------------------------------------------------------
					If Empty(cError) .And. cInput == "F" .And. !NGIFDBSEEK("SH4", ::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nTlCode,2], 1)
						cError := STR0060 // 'C�digo do insumo n�o encontrado na tabela "SH4 - Ferramentas".'
					EndIf

					//------------------------------------------------------------------------
					// 8.9 - Quando informado Produto, o campo Destino deve ser informado
					//------------------------------------------------------------------------
					If Empty(cError) .And. cInput == "P" .And. Empty(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nUse,2])
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nUse,1],"X3Titulo()")) + STR0050 // "O campo " #### " � obrigat�rio."
					EndIf

					//------------------------------------------------------------------------
					// 8.10 - Quando informado Terceiro, campo Almoxarifado deve ser informado
					//------------------------------------------------------------------------
					If Empty(cError) .And. ::isThird(nRecord) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nLocal,2])
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nLocal,1],"X3Titulo()")) + STR0050 // "O campo " #### " � obrigat�rio."
					EndIf

					//+------------------------------------------------------------------
					// 8.11. - Se insumo for Ferramenta, unidade de consumo do insumo deve ser "H- Horas"
					//+------------------------------------------------------------------
					If Empty(cError) .And. cInput == "F" .And. AllTrim(::aFieldSO[nRecord,__AFIELDSO_INPUT__,nX,nUnity,2]) != "H"
						cError := STR0061 // "Unidade 'Consumo' deve ser como 'H- Horas' para o uso de insumo tipo 'F- Ferramenta'."
						::addError(cError)
					EndIf

					If !Empty(cError)
						Exit
					EndIf

				Next nX

			EndIf

			// Valida��o de Etapas da OS
			If Empty(cError) .And. ::HasStep(nRecord)

				For nX := 1 To Len(::aFieldSO[nRecord, __AFIELDSO_STEP__])

					nStepTask := aScan(::aFieldSO[nRecord, __AFIELDSO_STEP__,nX],{|x| AllTrim(Upper(X[1])) == "TQ_TAREFA"})
					nstep     := aScan(::aFieldSO[nRecord, __AFIELDSO_STEP__,nX],{|x| AllTrim(Upper(X[1])) == "TQ_ETAPA"})

					//------------------------------------------------------------------------
					// 8.11 - Campo TQ_TAREFA � obrigat�rio
					//------------------------------------------------------------------------
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nStepTask,2])
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nStepTask,1],"X3Titulo()")) + STR0050 // "O campo " #### " � obrigat�rio."
					EndIf

					//------------------------------------------------------------------------
					// 8.12 - Campo TQ_ETAPA � obrigat�rio
					//------------------------------------------------------------------------
					If Empty(cError) .And. Empty(::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nstep,2])
						cError := STR0010 + Alltrim(Posicione("SX3",2,::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nstep,1],"X3Titulo()")) + STR0050 // "O campo " #### " � obrigat�rio."
					EndIf

					//------------------------------------------------------------------------
					// 8.13 - O c�digo da tarefa deve existir na tabela TT9 - Tarefas Gen�ricas.
					//------------------------------------------------------------------------
					If Empty(cError) .And. (::isCorrective(nRecord) .And. ::GetParam("MV_NGTARGE", "2") == "1") .And.;
					   !NGIFDBSEEK("TT9", ::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nStepTask,2], 1)
						cError := STR0062 // "O C�digo da tarefa n�o existe ou n�o pertence � tabela TT9 - Tarefas Gen�ricas"
					EndIf

					//------------------------------------------------------------------------
					// 8.14 - O c�digo da Etapa deve existir na tabela TPA - Etapas Gen�ricas.
					//------------------------------------------------------------------------
					If Empty(cError) .And. !NGIFDBSEEK("TPA", ::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nstep,2], 1)
						cError := STR0063 // "O C�digo da Etapa n�o existe ou pertence � tabela TPA - Etapas Gen�ricas"
					EndIf

					//------------------------------------------------------------------------
					// 8.15 - Se OS for Preventiva, a Tarefa deve estar preenchida
					// com um c�digo existente na tabela ST5 - Tarefas da Manuten��o.
					//------------------------------------------------------------------------
					If Empty(cError) .And. ::isPreventive(nRecord) .And. Alltrim(::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nStepTask,2]) <> "0" .And.;
					   !NGIFDBSEEK("ST5", ::aFieldSO[nRecord,__AFIELDSO_STEP__,nX,nStepTask,2], 5)
						cError := STR0064 // "O Campo tarefa n�o existe ou pertence � tabela ST5 - Tarefas da Manuten��o"
					EndIf

					If !Empty(cError)
						Exit
					EndIf

				Next nX

			EndIf

			// Ponto de entrada que permite adicionar valida��es na gera��o de OS
			If Empty( cError ) .And. ( ExistBlock( 'MNTA2953' ) .And. !ExecBlock( 'MNTA2953', .F., .F. ) )

				cError := STR0080 // A valida��o adicionada no ponto de entrada MNTA295A est� impossibilitando a continuidade do processo.

			EndIf

		EndIf

		If Empty(cError) //Caso n�o encontre problemas na valida��o.
			::SetValid(.T.)
		EndIf

	ElseIf ::IsAnswer() // Caso seja Resposta Question�rio de Satisfa��o.

		//-------------------------------------------------------------------
		// 8 - Valida��es do processo de Question�rio de Satisfa��o de S.S.
		//-------------------------------------------------------------------

		// 8.1 - Verificar se o campo Atend. Prazo(TQB_PSAP) foi preenchido.
		If Empty(cError) .And. Empty(cDeadL)
			cError := ::MsgRequired('TQB_PSAP') // O campo n�o foi preenchido.
		EndIf

		// 8.2 - Verificar se o campo Atend. Neces(TQB_PSAN) foi preenchido.
		If Empty(cError) .And. Empty(cNeed)
			cError := ::MsgRequired('TQB_PSAN') // O campo n�o foi preenchido.
		EndIf

		// 8.3 - Verifica se a S.S est� como E - Encerrada.
		If Empty(cError) .And. !Empty(cSolution) .And. cSolution <> 'E'
			cError := STR0010 + Alltrim(Posicione("SX3",2,"TQB_SOLUCA","X3Titulo()")) + STR0065 // "O campo " #### " deve estar como E - Encerrada."
		EndIf

		// 8.4 - Verifica se o Question�rio de Satisfa��o j� foi Respondido.
		If Empty(cError) .And. !Empty(cSolici)
			If !Empty(Posicione("TQB",1,cBranch+cSolici,"TQB_PSAP")) .And.;
				!Empty(Posicione("TQB",1,cBranch+cSolici,"TQB_PSAN"))
				cError := STR0066 // "O Question�rio de Satisfa��o j� foi Respondido."
			EndIf
		EndIf

		// 8.5 - Verifica se o Servi�o da S.S. possui question�rio de Satisfa��o.
		If Empty(cError) .And. !Empty(cServCode)
			If Posicione("TQ3",1,cBranch+cServCode,"TQ3_PESQST") == "2"
				cError := STR0067 // "O Servi�o da Solicita��o de Servi�o n�o possui Question�rio de Satisfa��o."
			EndIf
		EndIf

	EndIf

	// 5 - N�o � poss�vel alterar ou excluir uma S.S. que j� possua Ordem de Servi�o.
	If  Empty(cError) .And. (::IsUpdate() .Or. ::IsDelete()) .And. !::IsCreateSO()

		If ::HasSO(cSolici) .And. !(::IsCreateSO() .And. ::GetParam("MV_NGMULOS", "N") == "S")

			cError := STR0068 + IIf(::IsUpdate(), STR0069, STR0070) + STR0071 // "N�o � poss�vel " #### "alterar" ou "excluir" #### " esta S.S. pois ela j� possui Ordem de Servi�o."

		EndIf

	EndIf

	// Ponto de entrada que permite incluir novas valida��es aos processos de solicita��o de servi�o.
	If Empty( cError ) .And. ExistBlock( 'MNTA280I' )

		xPE280I := ExecBlock( 'MNTA280I', .F., .F., { ::GetOperation() } )

		If ValType( xPE280I ) == 'A'

			cError := xPE280I[2]

		ElseIf !xPE280I

			cError := STR0072 // A valida��o adicionada no ponto de entrada MNTA280I est� impossibilitando a continuidade do processo.

		EndIF

	EndIf

	//Adiciona o Erro ao Objeto instanciado
	If !Empty(cError)
		::AddError(cError)
		RollBackSX8()
	EndIf

	RestArea(aArea)

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} Upsert
M�todo para grava��o dos registros.

@author Guilherme Freudenburg
@since 29/05/2018
@return lValid, l�gico, confirma que os valores foram validados pela classe.
/*/
//------------------------------------------------------------------------------
Method Upsert() Class MntSR

	Local aArea      := GetArea()
	Local aAreaTQB   := {}
	Local cBranchST9 := ""
	Local cAsset     := ::GetValue("TQB_CODBEM")
	Local dDateOp    := ::GetValue("TQB_DTABER")
	Local cHourOp    := ::GetValue("TQB_HOABER")

	// Verifica se a informa��o � v�lida para Inclus�o/Altera��o.
	If ::IsValid()

		BEGIN TRANSACTION

		// Realiza a grava��o da tabela TQB - Solicita��o de Servi�o.
		_Super:Upsert()

		If ::IsValid()


			cBranchST9 := NGSEEK("ST9", cAsset, 1, "T9_FILIAL")

			// Verifica se o bem informado possui o contador 1 e se foi informado um valor para o contador.
			If ::HasCounter(1) .And. ::GetValue("TQB_POSCON") > 0

				NGTRETCON(cAsset, dDateOp, ::GetValue("TQB_POSCON"), cHourOp, 1, , .F., , cBranchST9)

			EndIf
			// Verifica se o bem informado possui o contador 2 e se foi informado um valor para o contador.
			If ::HasCounter(2) .And. ::GetValue("TQB_POSCO2") > 0

				NGTRETCON(cAsset, dDateOp, ::GetValue("TQB_POSCO2"), cHourOp, 2, , .F., , cBranchST9)

			EndIf

			//--------------------------------------------------------------------------
			// Ponto de entrada MNTA2807
			//--------------------------------------------------------------------------
			If ExistBlock("MNTA2807") .And. AllTrim( SuperGetMv("MV_NG1FAC", .F., "2") ) != "1"
				aAreaTQB := TQB->(GetArea())
				ExecBlock("MNTA2807",.F.,.F.)
				RestArea(aAreaTQB)
			EndIf

			If ::IsInsert()
				ConfirmSX8()
			EndIf

			//--------------------------------------------------------------------------
			// Envia Workflow
			//--------------------------------------------------------------------------
			::SendWF(::GetValue("TQB_SOLICI"))

		Else
			DisarmTransaction()
		EndIf

		END TRANSACTION

		// Finaliza o processo de altera��o dos registros.
		MsUnlockAll()

	EndIf

	RestArea(aArea)

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} Delete
M�todo para exclus�o da Solicita��o de Servi�o.

@author Guilherme Freudenburg
@since 07/06/2018
@return lValid, l�gico, confirma que os valores foram validados pela classe.
@sample oObj:Delete()
/*/
//------------------------------------------------------------------------------
Method Delete() Class MntSR

	Local cBranch := ::GetValue("TQB_FILIAL")
	Local cAsset  := ::GetValue("TQB_CODBEM")
	Local nCount1 := ::GetValue("TQB_POSCON")
	Local nCount2 := ::GetValue("TQB_POSCO2")
	Local cDateOp := ::GetValue("TQB_DTABER")
	Local cHourOp := ::GetValue("TQB_HOABER")

	Begin Transaction

	// Verifica se a informa��o � v�lida.
	If ::IsValid()

		// Chama m�todo para exclus�o.
		_Super:Delete()

		// Realiza a exclus�o do contador 1
		If ::HasCounter(1)
			dbSelectArea("STP")
			dbSetOrder(5) // TP_FILIAL + TP_CODBEM + TP_DTLEITU + TP_HORA
			If dbSeek(cBranch + cAsset + DTOS(cDateOp) + cHourOp, .T.)

				RecLock("STP",.F.)
				dbDelete()
				STP->(MsUnLock())

				// Realiza o acerto do contador 1
				NGRECALHIS(cAsset, 0, nCount1, cDateOp, 1, .T., .F., .T.)

			EndIf
		EndIf

		// Realiza a exclus�o do contador 2
		If ::HasCounter(2)
			dbSelectArea("TPP")
			dbSetOrder(5) // TPP_FILIAL+TPP_CODBEM+DTOS(TPP_DTLEIT)+TPP_HORA
			If dbSeek(cBranch + cAsset + DTOS(cDateOp) + cHourOp)

				RecLock("TPP",.F.)
				dbDelete()
				TPP->(MsUnLock())

				// Realiza o acerto do contador 2
				NGRECALHIS(cAsset, 0, nCount2, cDateOp, 2, .T., .F., .T.)

			EndIf
		EndIf

        // Envia Workflow
		::SendWF(::GetValue("TQB_SOLICI"))

	Else
		// Para a grava��o.
		DisarmTransaction()
	EndIf

	End Transaction

	MsUnlockAll()

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} Assign
M�todo para distribui��o da Solicita��o de Servi�o.

@author Wexlei Silveira
@since 13/06/2018
@return lValid, l�gico, confirma que os valores foram validados pela classe.
@sample oObj:Assign()
/*/
//------------------------------------------------------------------------------
Method Assign() Class MntSR

	Local lMNTA280J := ExistBlock( 'MNTA280J' )

	If ::IsAssigned()

		Begin Transaction

			// Verifica se a informa��o � v�lida.
			If ::ValidBusiness()

				// Efetua a altera��o do registro na TQB - Solicita��o de Servi�o.
				_Super:Upsert()

				// Ponto de entrada que permite customizar o processo de grava��o, incluindo novos campos.
				If lMNTA280J
					ExecBlock( 'MNTA280J', .F., .F. )
				EndIf

				// Envia Workflow
				::SendWF(::GetValue("TQB_SOLICI"), ::GetValue("TQB_CDEXEC"), ::GetValue("TQB_CDSERV"))

			Else
				// Para a grava��o.
				DisarmTransaction()
			EndIf

		End Transaction

		MsUnlockAll()

	EndIf

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} Close
M�todo para fechamento da Solicita��o de Servi�o.

@author Wexlei Silveira
@since 18/06/2018
@return lValid, l�gico, confirma que os valores foram validados pela classe.
@sample oObj:Close()
/*/
//------------------------------------------------------------------------------
Method Close() Class MntSR

	Local lFacilit := AllTrim( SuperGetMv("MV_NG1FAC", .F., "2") ) == "1"

	If ::IsClosed()

		Begin Transaction

		// Verifica se a informa��o � v�lida.
		If ::IsValid()

			// Efetua a altera��o do registro na TQB - Solicita��o de Servi�o.
			_Super:Upsert()

			//--------------------------------------------------------------------------
			// Ponto de entrada MNTFE290
			//--------------------------------------------------------------------------
			If ExistBlock("MNTFE290")
				ExecBlock("MNTFE290",.F.,.F.)
			EndIf

			If lFacilit
				//---------------------------------------------------------------------------------------------
				// Carrega campos de pesquisa quando utiliza facilities, deve ser acionado antes de enviar wf
				//---------------------------------------------------------------------------------------------
				fQuestions( ::GetValue("TQB_SOLICI") )
			EndIf

			//--------------------------------------------------------------------------
			// Envia Workflow
			//--------------------------------------------------------------------------
			::SendWF( ::GetValue("TQB_SOLICI"), ::GetValue("TQB_CDEXEC"), ::GetValue("TQB_CDSERV"), lFacilit )

			//--------------------------------------------------------------------------
			// Ponto de entrada MNTA2909
			//--------------------------------------------------------------------------
			If ExistBlock("MNTA2909")
				ExecBlock("MNTA2909",.F.,.F.,{ 3 }) //3 - fechamento, sempre fechamento
			EndIf

		Else
			// Para a grava��o.
			DisarmTransaction()
		EndIf

		End Transaction

		MsUnlockAll()

	EndIf

Return ::IsValid()

//------------------------------------------------------------------------------
/*/{Protheus.doc} CreateSO
M�todo para gera��o de O.S. mediante a Solicita�ao de Servi�o.

@author Guilherme Freudenburg
@since 11/06/2018
@return bool -	.T. - Gera��o Efetuada ,
                .F. - Gera��o n�o Efetuada.
/*/
//------------------------------------------------------------------------------
Method CreateSO() Class MntSR

	Local cBrachST9  := ""
	Local cObsTqb    := ""
	Local aAreaOS    := GetArea()
	Local aAreaTQB   := TQB->(GetArea())
	Local aAreaSS    := {}
	Local aAreaSSOS  := {}
	Local aCodSO     := {}
	Local aReturn    := {}
	Local nInd       := 0
	Local nSizeField := Len(::aFieldSO)
	Local nAsset     := 0
	Local nDate      := 0
	Local nServ      := 0
	Local nCounter1  := 0
	Local nCounter2  := 0
	Local nHour1     := 0
	Local nHour2     := 0
	Local nPlan      := 0
	Local nSitua     := 0
	Local nFinish    := 0
	Local nCostCnt   := 0
	Local nSequen    := 0
	Local nTipoOS    := 0
	Local nX         := 0
	Local aInput     := {}
	Local aStep      := {}
	Local aInputBlk  := {}
	Local aCamp      := {}
	Local xRet       := {}
	Local lMNTA2956  := ExistBlock( 'MNTA2956' )
	Local lMNTA2952  := ExistBlock( 'MNTA2952' )

	// Insumos
	Local nTask      := 0
	Local nRegType   := 0
	Local nTlCode    := 0
	Local nReqQuant  := 0
	Local nQuant     := 0
	Local nUnity     := 0
	Local nDestin    := 0
	Local nLocale    := 0
	Local cTypeHour  := ::GetParam("MV_NGUNIDT", "D")
	Local nUseCal    := 0
	Local nInputCost := 0
	Local nTaskSeq   := 0
	Local nFornec    := 0
	Local nLoja      := 0
	Local nObserva   := 0

	// Etapas
	Local nStepTask := 0
	Local nStep     := 0
	Local nSeqStep  := 0

	SetInclui() // TODO: Remover quando for implementada no Gen�rico

	If ::GetParam("MV_NGMULOS", "N") == "N" .And. nSizeField > 1
		nSizeField := 1
	EndIf

	BEGIN TRANSACTION

	// Percorre os valores informados atrav�s do aFieldSO, para realizar a inclus�o de OS.
	For nInd := 1 To nSizeField

		// Busca a posi��o dos campos.
		nAsset    := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_CODBEM" })
		nDate     := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_DTORIGI"})
		nServ     := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_SERVICO"})
		nCounter1 := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_POSCONT"})
		nCounter2 := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_POSCON2"})
		nHour1    := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_HORACO1"})
		nHour2    := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_HORACO2"})
		nPlan     := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_PLANO"  })
		nSitua    := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_SITUACA"})
		nFinish   := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_TERMINO"})
		nCostCnt  := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_CCUSTO" })
		nSequen   := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_SEQRELA"})
		nTipoOS   := aScan(::aFieldSO[nInd, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_TIPOOS" })

		// Verifica se o registro � v�lido para exclus�o.
		::ValidBusiness()

		// Verifica se o valor est� valido para grava��o.
		If ::IsValid()

			If ::isPreventive(nInd)
				// Chama fun��o para inclus�o de Ordem de Servi�o Preventiva.
				aReturn := NGGERAOS("P",;
									::aFieldSO[nInd,__AFIELDSO_SO__,nDate,2],;
									::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2],;
									::aFieldSO[nInd,__AFIELDSO_SO__,nServ,2],;
									::aFieldSO[nInd,__AFIELDSO_SO__,nSequen,2],;
									"N","N","N","",;
									::aFieldSO[nInd,__AFIELDSO_SO__,nSitua,2],;
									.F.,.F., ::aFieldSO[nInd, __AFIELDSO_SO__],;
									IIf( nTipoOS > 0, ::aFieldSO[nInd,__AFIELDSO_SO__, nTipoOS, 2], "B"),;
									::GetValue( "TQB_SOLICI" ))

			ElseIf ::isCorrective(nInd)
				// Chama fun��o para inclus�o de Ordem de Servi�o Corretiva.
				aReturn := NGGERAOS("C",;
									::aFieldSO[nInd,__AFIELDSO_SO__,nDate,2],;
									::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2],;
									::aFieldSO[nInd,__AFIELDSO_SO__,nServ,2],;
									"","","","","",;
									::aFieldSO[nInd,__AFIELDSO_SO__,nSitua,2],;
									.F.,.F.,;
									::aFieldSO[nInd, __AFIELDSO_SO__],;
									IIf(nTipoOS <> 0,::aFieldSO[nInd,__AFIELDSO_SO__,nTipoOS,2],"B"),;
									::GetValue( "TQB_SOLICI" ))
			EndIf

			If Len(aReturn) > 0 .And. aReturn[1,1] == "S"

				NGIFDBSEEK("STJ", aReturn[1,3], 1) // seleciona ordem gerada

				//--------------------------------------------------------------------------
				// Ponto de entrada MNTA2956 para inser��o de campo
				//--------------------------------------------------------------------------
				If lMNTA2956

					// Salva area posicionada
					aAreaSS   := TQB->(GetArea())
					aAreaSSOS := STJ->(GetArea())

					xRet := ExecBlock("MNTA2956",.F.,.F.)

					If ValType(xRet) == "A"

						cObsTqb := MSMM(TQB->TQB_CODMSS,80) // Busca o valor do campo memo.
						aCamp   := xRet

						For nX:= 1 to Len(aCamp)

							cObsTqb := cObsTqb + " " + aCamp[nX]

						Next nX

					EndIf

					If !Empty(cObsTqb)
						RecLock("STJ",.F.)
						STJ->TJ_OBSERVA  := cObsTqb
						STJ->(MsUnLock())
					EndIf

					// Retorna area posicionada
					RestArea(aAreaSS)
					RestArea(aAreaSSOS)

				EndIf

				//--------------------------------------------------------------------------
				// Ponto de entrada MNTA2952 para grava��o de campos de usu�rios.
				//--------------------------------------------------------------------------
				If lMNTA2952

					ExecBlock( 'MNTA2952', .F., .F., { aReturn[1,3] } )

				EndIf

				If ::GetParam("MV_NGMULOS", "N") == "N"

					// Adiciona o valor da ordem adicionado.
					::SetValue("TQB_ORDEM",aReturn[1,3])

					// Determina que o resgistro est� correto para grava��o.
					::SetValid(.T.)

					// Realiza a grava��o da tabela TQB - Solicita��o de Servi�o.
					_Super:Upsert()

				EndIf

				//-----------------------------------
				// Envia e-mail para o solicitante
				//-----------------------------------
				::SendWF()

				// Busca a filial do Bem
				cBrachST9 := NGSEEK("ST9",::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2],1,"T9_FILIAL")

				// Verifica se o bem informado possui o contador 1 e se foi informado um valor para o contador.
				If ::HasCounter(1,::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2]) .And. nCounter1 > 0 .And. ::aFieldSO[nInd,__AFIELDSO_SO__,nCounter1,2] > 0
					NGTRETCON(::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2],::aFieldSO[nInd,__AFIELDSO_SO__,nDate,2],::aFieldSO[nInd,__AFIELDSO_SO__,nCounter1,2],::aFieldSO[nInd,__AFIELDSO_SO__,nHour1,2],1,,.F.,,cBrachST9)
				EndIf

				// Verifica se o bem informado possui o contador 2 e se foi informado um valor para o contador.
				If ::HasCounter(2,::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2]) .And. nCounter2 > 0 .And. ::aFieldSO[nInd,__AFIELDSO_SO__,nCounter2,2] > 0
					NGTRETCON(::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2],::aFieldSO[nInd,__AFIELDSO_SO__,nDate,2],::aFieldSO[nInd,__AFIELDSO_SO__,nCounter2,2],::aFieldSO[nInd,__AFIELDSO_SO__,nHour2,2],2,,.F.,,cBrachST9)
				EndIf

				// Gerar registro de nao-conformidade no respectivo modulo
				If nPlan > 0 .And. Val(::aFieldSO[nInd,__AFIELDSO_SO__,nPlan,2]) == 0
					NGGERAFNC(aReturn[1,3],::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2],::aFieldSO[nInd,__AFIELDSO_SO__,nServ,2],::aFieldSO[nInd,__AFIELDSO_SO__,nDate,2])
				EndIf

				// Caso o par�metro MV_NGMULOS estiver como 'S', gera relacionamento entre Solicit. Serv. X Ordem Serv. atrav�s da tabela TT7.
				If ::GetParam("MV_NGMULOS", "N") == "S"

					dbSelectArea("TT7")
					dbSetOrder(1)
					If !dbSeek(xFilial("TT7") + ::GetValue("TQB_SOLICI") + STJ->TJ_ORDEM)

						Reclock("TT7",.T.)
						TT7->TT7_FILIAL := xFilial("TT7")
						TT7->TT7_SOLICI := ::GetValue("TQB_SOLICI")
						TT7->TT7_ORDEM  := STJ->TJ_ORDEM
						TT7->TT7_PLANO  := STJ->TJ_PLANO
						TT7->TT7_SITUAC := STJ->TJ_SITUACA
						TT7->TT7_TERMIN := STJ->TJ_TERMINO
						MsUnLock("TT7")

					EndIf

				EndIf

				// Monta o array de Insumos e grava
				If ::HasInput(nInd)

					For nX := 1 to Len(::aFieldSO[nInd,__AFIELDSO_INPUT__])

						nTask     := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_TAREFA"})
						nRegType  := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_TIPOREG"})
						nTlCode   := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_CODIGO"})
						nReqQuant := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_QUANREC"})
						nQuant    := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_QUANTID"})
						nUnity    := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_UNIDADE"})
						nDestin   := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_DESTINO"})
						nLocale   := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_LOCAL"})
						nUseCal   := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_USACALE"})
						nTaskSeq  := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_SEQTARE"})
						nDtIni    := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_DTINICI"})
						nHrIni    := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_HOINICI"})
						nFornec   := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_FORNEC"})
						nLoja     := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_LOJA"})
						nObserva  := aScan(::aFieldSO[nInd, __AFIELDSO_INPUT__, nX],{|x| AllTrim(Upper(X[1])) == "TL_OBSERVA"})

						nInputCost := NGCALCUSTI(::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nTlCode,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nRegType,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nQuant,2],;
												 ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nLocale,2], cTypeHour,,, ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nReqQuant,2])

						aAdd( aInput, { ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nTask,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nRegType,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nTlCode,2],;
							::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nReqQuant,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nQuant,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nUnity,2],;
							::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nDestin,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nLocale,2], cTypeHour,;
							::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nUseCal,2], nInputCost, ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nTaskSeq,2],;
							::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nDtIni,2], ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nHrIni,2],;
							IIf( nFornec > 0, ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nFornec,2], '' ),;   // 15 - TL_FORNEC
							IIf( nLoja > 0, ::aFieldSO[nInd,__AFIELDSO_INPUT__,nX,nLoja,2], '' ),;       // 16 - TL_LOJA
							IIf( nObserva > 0, ::aFieldSO[nInd, __AFIELDSO_INPUT__,nX,nObserva,2], '' )})// 17 - TL_OBSERVA 

						// Grava os insumos previstos
						aInputBlk := fInputStep(aReturn[1,3], ::aFieldSO[nInd,__AFIELDSO_SO__,nPlan,2], aInput, {}, ::aFieldSO[nInd,__AFIELDSO_SO__,nCostCnt,2])

						// Grava os bloqueios dos insumos
						NGBLOQINS(aInputBlk, ::aFieldSO[nInd,__AFIELDSO_SO__,nPlan,2], ::aFieldSO[nInd,__AFIELDSO_SO__,nAsset,2])

						aInput := {}
						aInputBlk := {}

					Next nX

				EndIf

				// Monta o array de Etapas e grava
				If ::HasStep(nInd)

					For nX := 1 to Len(::aFieldSO[nInd,__AFIELDSO_STEP__])

						nStepTask := aScan(::aFieldSO[nInd, __AFIELDSO_STEP__, nX],{|x| AllTrim(Upper(X[1])) == "TQ_TAREFA"})
						nStep     := aScan(::aFieldSO[nInd, __AFIELDSO_STEP__, nX],{|x| AllTrim(Upper(X[1])) == "TQ_ETAPA"})
						nSeqStep  := aScan(::aFieldSO[nInd, __AFIELDSO_STEP__, nX],{|x| AllTrim(Upper(X[1])) == "TQ_SEQETA"})

						aAdd(aStep, {::aFieldSO[nInd, __AFIELDSO_STEP__, nX, nStepTask,2], ::aFieldSO[nInd, __AFIELDSO_STEP__, nX, nStep,2], ::aFieldSO[nInd, __AFIELDSO_STEP__, nX, nSeqStep,2]})

						// Grava as etapas previstas
						fInputStep(aReturn[1,3], ::aFieldSO[nInd,__AFIELDSO_SO__,nPlan,2], {}, aStep, ::aFieldSO[nInd,__AFIELDSO_SO__,nCostCnt,2])

						aStep := {}

					Next nX

				EndIf

				// Verifica se foi realizado a inclus�o de uma OS.
				aAdd(aCodSO, aReturn[1,3]) // Adiciona o c�digo da OS gerada na vari�vel da Classe.

				// Finaliza o processo de altera��o dos registros.
				MsUnlockAll()

			ElseIf Len(aReturn) > 0 .And. !Empty(aReturn[1,2])

				::AddError(aReturn[1,2])
				aCodSO := {}
				DisarmTransaction()
				Exit

			EndIf

			// Finaliza processo de grava��o
			If !::IsValid()
				DisarmTransaction()
			EndIf

		EndIf

	Next nInd

	END TRANSACTION

	RestArea(aAreaOS)
	RestArea(aAreaTQB)

Return aCodSO

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsAnalysis
Indica se a S.S. est� com status "Aguardando An�lise".

@author Wexlei Silveira
@since 08/06/2018
@return l�gico, se o status da SS for igual a "Aguardando An�lise"
/*/
//------------------------------------------------------------------------------
Method IsAnalysis() Class MntSR
Return ::GetValue("TQB_SOLUCA") == "A"

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsAssigned
Indica se a S.S. est� com status "Distribu�da".

@author Wexlei Silveira
@since 08/06/2018
@return l�gico, se o status da SS for igual a "Distribu�da"
/*/
//------------------------------------------------------------------------------
Method IsAssigned() Class MntSR
Return ::GetValue("TQB_SOLUCA") == "D"

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsClosed
Indica se a S.S. est� com status "Encerrada".

@author Wexlei Silveira
@since 08/06/2018
@return l�gico, se o status da SS for igual a "Encerrada"
/*/
//------------------------------------------------------------------------------
Method IsClosed() Class MntSR
Return ::GetValue("TQB_SOLUCA") == "E"

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsCanceled
Indica se a S.S. est� com status "Cancelada".

@author Wexlei Silveira
@since 08/06/2018
@return l�gico, se o status da SS for igual a "Cancelada"
/*/
//------------------------------------------------------------------------------
Method IsCanceled() Class MntSR
Return ::GetValue("TQB_SOLUCA") == "C"

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsCreateSO
Indica se � o processo de Gera��o de Ordem de Servi�o (OS)

@author Guilherme Freudenburg
@since 20/06/2018
@return l�gico, se est� no processo de gera��o de OS.
/*/
//------------------------------------------------------------------------------
Method IsCreateSO() Class MntSR
Return Len(::aFieldSO) > 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} HasInput
Indica se a OS possui Insumos.

@parameters [nPos], Num�rico, Posi��o no aFieldSO de acordo com a OS.
@author Wexlei Silveira
@since 29/08/2018
@return l�gico, se est� no processo de gera��o de OS.
/*/
//------------------------------------------------------------------------------
Method HasInput(nPos) Class MntSR

	Default nPos := 1

Return Len(::aFieldSO[nPos, __AFIELDSO_INPUT__, 1]) > 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} HasStep
Indica se a OS possui Etapas.

@parameters [nPos], Num�rico, Posi��o no aFieldSO de acordo com a OS.
@author Wexlei Silveira
@since 29/08/2018
@return l�gico, se est� no processo de gera��o de OS.
/*/
//------------------------------------------------------------------------------
Method HasStep(nPos) Class MntSR

	Default nPos := 1

Return Len(::aFieldSO[nPos, __AFIELDSO_STEP__, 1]) > 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} isCorrective
Define se a O.S. � Corretiva.

@parameters nPos, Num�rico, Posi��o no aFieldSO de acordo com a OS.
@author Wexlei Silveira
@since 02/10/2018
@return Bool
/*/
//------------------------------------------------------------------------------
Method isCorrective(nPos) Class MntSR

	Local nPlan := aScan(::aFieldSO[nPos, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_PLANO"})

Return Val(::aFieldSO[nPos, __AFIELDSO_SO__, nPlan, 2]) == 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} isPreventive
Define se a O.S. � Preventiva.

@parameters nPos, Num�rico, Posi��o no aFieldSO de acordo com a OS.
@author Wexlei Silveira
@since 02/10/2018
@return Bool
/*/
//------------------------------------------------------------------------------
Method isPreventive(nPos) Class MntSR

	Local nPlan := aScan(::aFieldSO[nPos, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_PLANO"})

Return Val(::aFieldSO[nPos, __AFIELDSO_SO__, nPlan, 2]) > 0

//------------------------------------------------------------------------------
/*/{Protheus.doc} isThird
Indica se a O.S. � enviada para Terceiros.

@parameters nPos, Num�rico, Posi��o no aFieldSO de acordo com a OS.
@author Wexlei Silveira
@since 02/10/2018
@return bool
/*/
//------------------------------------------------------------------------------
Method isThird(nPos) Class MntSR

	Local nThird := aScan(::aFieldSO[nPos, __AFIELDSO_SO__],{|x| AllTrim(Upper(X[1])) == "TJ_TERCEIR"})

Return nThird > 0 .And. ::aFieldSO[nPos, __AFIELDSO_SO__, nThird, 2] == "2"

//------------------------------------------------------------------------------
/*/{Protheus.doc} IsAnswer
Indica se est� no processo de Resposta de Question�rio de Satisfa��o da
Solicita��o de Servi�o.

@author Guilherme Freudenburg
@since 26/06/2018
@return l�gico, se est� no processo de gera��o de Satisfa��o de SS.
/*/
//------------------------------------------------------------------------------
Method IsAnswer() Class MntSR

Return Posicione("TQB",01,::GetValue("TQB_FILIAL")+::GetValue("TQB_SOLICI"),"TQB_SOLUCA") == "E"

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetValueSO
Transfere os valores do Array para o objeto.

@example
   aAdd(aCampos,{ {"TJ_CODBEM" , '10              '  },;
		          {"TJ_CCUSTO" , '01       ' },;
				  {"TJ_SERVICO", '10    ' },;
				  {"TJ_SEQRELA", '0' },;
				  {"TJ_DTORIGI", 01/01/2018 },;
				  {"TJ_POSCONT", 30000 },;
				  {"TJ_HORACO1", '10:10' },;
				  {"TJ_HOMPINI", '10:10' },;
				  {"TJ_DTMPINI", '01/01/2018' },;
				  {"TJ_OBSERVA", 'Observa��o da OS.' },;
				  {"TJ_SITUACA", 'L' },;
				  {"TJ_TERCEIR", 'N' },;
				  {"TJ_PLANO"  , '000000' }})

	oTQB:SetValueSO(aCampos)

@author Guilherme Freudenburg
@since 15/06/2018
@return Nil
/*/
//------------------------------------------------------------------------------
Method SetValueSO(aFields) Class MntSR
	::aFieldSO := aClone(aFields)
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} HasCounter
Indica se o bem da S.S. possui contador

@author Guilherme Freudenburg
@since 30/05/2018
@parameters nCounter - Contador (1/2) - Numerico
@return lHasCount, l�gico, se o bem tem contador pr�prio
/*/
//------------------------------------------------------------------------------
Method HasCounter(nCounter,cAsset) Class MntSR

	Local lHasCount := .F.

	Default nCounter := 1
	Default cAsset  := ::GetValue("TQB_CODBEM")

    // Contador 1.
    If nCounter == 1
        dbSelectArea("ST9")
        dbSetOrder(1)
        If dbSeek(xFilial("ST9") + cAsset)
            If ST9->T9_TEMCONT == "S"
                lHasCount := .T.
            EndIf
        EndIf

	// Contador 2.
	ElseIf nCounter == 2
		//FindFunction remover na release GetRPORelease() >= '12.1.027'
		If FindFunction("MNTCont2")
			lHasCount := MNTCont2(xFilial("TPE"), cAsset)
		Else
			dbSelectArea("TPE")
			dbSetOrder(1)
			If dbSeek(xFilial("TPE") + cAsset) .And. TPE->TPE_SITUAC == "1"
				lHasCount := .T.
			EndIf
		EndIf
	EndIf

Return lHasCount

//------------------------------------------------------------------------------
/*/{Protheus.doc} SendWF
Envio de Workflow.

@author Wexlei Silveira
@since 08/06/2018

@param cSolici, Caractere, C�digo da Solicita��o
@param [cCDExec], Caractere, C�digo do Executante
@param [cServCode], Caractere, Tipo do Servi�o
@param [cOrder], Caractere, C�digo da OS
@param [cState], Caractere, Status da OS
@param [lFacilit], boolean, se utiliza novo facilities

@return lRet, L�gico, Retorno das fun��es de envio de Workflow
/*/
//------------------------------------------------------------------------------
Method SendWF(cSolici, cCDExec, cServCode, cOrder, cState, lFacilit ) Class MntSR

	Local oWorkflow
	Local cAliasWF := GetNextAlias()
	Local aDbfW045 := {}
	Local aArea    := GetArea()
	Local aAreaTQB := TQB->(GetArea())
	Local lRet     := .T.

	Default lFacilit := .F.

	If ::GetParam("MV_NGSSWRK", "N") == "S"

		If ::IsInsert() // Workflow de inclus�o de SS

			lRet := MNTW025(cSolici,,, cAliasWF)

		ElseIf ::IsAssigned() .And. !::IsCreateSO()// Workflow de distribui��o da SS

			lRet := MNTW040(cSolici, cCDExec, cServCode, cAliasWF)

		ElseIf ::IsDelete() // Workflow de exclus�o de SS

			lRet := MNTW045(cSolici,,, cAliasWF, aDbfW045)

		ElseIf ::IsClosed() // Workflow de fechamento de SS

			If lFacilit .Or. ( Empty( ::GetValue("TQB_PSAN") ) .And. Empty( ::GetValue("TQB_PSAP") ) )

				dbSelectArea("TQB")
				dbSetOrder(01)
				If dbSeek(xFilial("TQB") + cSolici, .T.)

					lRet := MNTW035(TQB->(RecNo()))

				Else

					lRet := .F.

				EndIf
			EndIf

		ElseIf ::IsCreateSO() // Caso seja chamado pela gera��o de Ordem de Servi�o.

			MNW29501( ::GetValue( "TQB_CDSOLI" ) ) //Envia e-mail para solicitante
			//O wf MNTW215 n�o deve ser acionado aqui pois j� � enviado atrav�s da fun��o NGGERAOS
		EndIf
	EndIf

	If Type("oWorkflow") == "O"
		oWorkflow:Delete()
	EndIf

	RestArea(aAreaTQB)
	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} HasSO
Verifica se existe OS em aberto para a S.S.

@author Wexlei Silveira
@since 19/06/2018

@param cSolici, Caractere, C�digo da Solicita��o de Servi�o

@return lRet, L�gico, Se existe ou n�o OS em aberto para a S.S.
/*/
//------------------------------------------------------------------------------
Method HasSO(cSolici) Class MntSR

	Local lRet     := .F.
	Local aArea    := GetArea()
	Local aAreaTQB := TQB->(GetArea())

	If ::GetParam("MV_NGMULOS", "N") == "N"

		dbSelectArea("TQB")
		dbSetOrder(01)
		If dbSeek(xFilial("TQB") + cSolici)
			If !Empty(TQB->TQB_ORDEM)
				lRet := .T.
				If ::IsClosed() .And. NGIFDBSEEK("STJ", TQB->TQB_ORDEM, 1) .And. ;
					(STJ->TJ_TERMINO != 'N' .Or. STJ->TJ_SITUACA == 'C')
					lRet := .F.
				EndIf
			EndIf
		EndIf

	ElseIf ::IsClosed()

		dbSelectArea("TT7")
		dbSetOrder(1)
		If dbSeek(xFilial("TT7") + cSolici)
			While !Eof() .And. Alltrim(TT7->TT7_SOLICI) == Alltrim(cSolici)
				dbSelectArea("STJ")
				dbSetOrder(01)
				If dbSeek(xFilial("STJ") + TT7->TT7_ORDEM)
					If STJ->TJ_TERMINO == "N" .And. STJ->TJ_SITUACA <> 'C'
						lRet := .T.
						Exit
					EndIf
				EndIf
				TT7->(dbSkip())
			EndDo
		EndIf

	EndIf

	RestArea(aAreaTQB)
	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AddFile
Adicionar imagem no Banco de Conhecimento

@author Vitor Bonet
@since 16/08/2018

@param oImage, Objeto, Contem a imagem em Base 64
@param nMode, Num�rico, Modo de grava��o. 1 para corpo da ordem, 2 para finaliza��o

@return aImage, array, aImage[1] = nome do arquivo, aImage[2] = data e hora.
/*/
//------------------------------------------------------------------------------
Method AddFile(oImage, nMode) Class MntSR

	Local cDocPath
	Local cObject
	Local cFilePath
	Local nHandler
	Local cObjCode
	Local cSlash := If(isSRVunix(),"/","\")
	Local nNameSize := 5
	Local cDateTime := DToC( Date() ) + ' ' + Time()
	Local cType := If( nMode == 1, 'PROBLEM ', 'SOLUTION' )
	Local cMsDocPath := If(isSRVunix(), Lower(StrTran( MsDocPath(),'\', '/')),MsDocPath())
	Local cSolici   := ::GetValue("TQB_SOLICI")
	Local aImage := {}

	cDocPath := cMsDocPath
	cObject  := NewIdentif( nNameSize ) + '.jpg'
	// Enquanto existirem nomes conflitantes, geramos outro
	While File( cDocPath + cSlash + cObject )
		cObject := NewIdentif( nNameSize ) + '.jpg'
	EndDo

	// Abrimos um ponteiro para o novo arquivo para depositar os bytes
	cFilePath := cDocPath + cSlash + cObject
	nHandler := FCreate( cFilePath, Nil, Nil, .F. )
	If nHandler == -1
		::AddError( STR0077 ) // "Erro ao criar arquivo no servidor."
		Return aImage// "Erro ao criar arquivo no servidor"
	EndIf
	FWrite( nHandler, Decode64( oImage ) )
	FClose( nHandler )

	// Posicionar na tabela de objetos
	dbSelectArea( 'ACB' )
	dbSetOrder( 2 ) // ACB_FILIAL + ACB_OBJETO
	// Arquivo n�o possui registro na base, ent�o adicionamos

	If !dbSeek( xFilial( 'ACB' ) + cObject )
		cObjCode := GetSXEnum( 'ACB', 'ACB_CODOBJ' )
		RecLock( 'ACB', .T. )
		ACB->ACB_FILIAL := xFilial( 'ACB' )
		ACB->ACB_CODOBJ := cObjCode
		ACB->ACB_OBJETO := cObject
		ACB->ACB_DESCRI := cType + ' ' + cDateTime
		ACB->(MsUnLock())
		ConfirmSX8()

		// Gravar v�nculos entre objetos e ordem na AC9
		dbSelectArea( 'AC9' )
		dbSetOrder( 1 ) // AC9_FILIAL + AC9_CODOBJ + AC9_ENTIDA + AC9_FILENT + AC9_CODENT

		If !dbSeek( xFilial( 'AC9' ) + cObjCode + 'TQB' + xFilial( 'TQB' ) + cSolici )
			RecLock( 'AC9', .T. )
			AC9->AC9_FILIAL := xFilial( 'AC9' )
			AC9->AC9_FILENT := xFilial( 'TQB' )
			AC9->AC9_ENTIDA := 'TQB'
			AC9->AC9_CODENT := xFilial( 'TQB' ) + cSolici
			AC9->AC9_CODOBJ := cObjCode
			AC9->(MsUnLock())
		EndIf
	EndIf

	aAdd(aImage, { cObject, cDateTime, cObjCode })

Return aImage

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetFile
Busca uma imagem espec�fica no Banco de Conhecimento

@author Vitor Bonet
@since 16/08/2018

@param cFile, Caractere, Caminho da imagem.

@return xBytes, Bytes, Retorna a imagem em Bytes, se n�o, retorna nulo.
/*/
//------------------------------------------------------------------------------
Method GetFile(cFile) Class MntSR

	Local cMsDocPath := If(isSRVunix(), Lower(StrTran( MsDocPath(),'\', '/')),MsDocPath())
	Local cSlash := If(isSRVunix(),"/","\")
	Local cPath := ""
	Local xBytes

	cPath := cMsDocPath + cSlash + cFile // Complementa o nome da imagem com o caminho at� o diret�rio
	xBytes := StaticCall( ngwsutil, ReadBytes, cPath)  // Le os Bytes da imagem chamando uma fun��o static do fonte ngwsutil

    If Nil == xBytes .Or. 0 <> FError()
        Return
    EndIf

Return xBytes

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetFileList
Busca todas as imagens que a S.S possui no Banco de Conhecimento.

@author Vitor Bonet
@since 16/08/2018

@return aImages, Array, Array com todos os C�digos de Objeto das imagens.

@obs aImages[1] = C�digo do Objeto, aImages[2] = Nome do arquivo, aImages[3] = Descri��o, aImages[3] = Tipo da Imagem (Problema ou solu��o)

/*/
//------------------------------------------------------------------------------
Method GetFileList() Class MntSR

	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()
	Local cSolici   := ::GetValue("TQB_SOLICI")
	Local aImages   := {}

	// Busca todos os caminhos das imagens PROBLEMA/SOLU��O no Banco de Conhecimento.
	BeginSql Alias cAliasQry

		SELECT AC9.AC9_CODOBJ, ACB.ACB_OBJETO, ACB.ACB_DESCRI
		FROM %table:AC9% AC9
		INNER JOIN %table:ACB% ACB 
			ON ACB.ACB_FILIAL = %xFilial:ACB%
			AND ACB.ACB_CODOBJ = AC9.AC9_CODOBJ
			AND ACB.%NotDel%
            AND RTRIM(SUBSTRING( ACB.ACB_DESCRI, 1, 8 )) IN ('PROBLEM', 'SOLUTION')
		WHERE AC9.AC9_FILIAL = %xFilial:AC9%
			AND AC9_FILENT = %xFilial:TQB%
			AND AC9_ENTIDA = 'TQB'
			AND AC9_CODENT = %xFilial:TQB% || %Exp:cSolici%
			AND AC9.%NotDel%
		ORDER BY AC9.AC9_CODOBJ

	EndSql

	While (cAliasQry)->(!Eof())
		// Adiciona no array o C�digo do Objeto de cada imagem.
		aAdd( aImages, { (cAliasQry)->AC9_CODOBJ, (cAliasQry)->ACB_OBJETO, (cAliasQry)->ACB_DESCRI, SUBSTR((cAliasQry)->ACB_DESCRI, 1, 8) })

		(cAliasQry)->(dbSkip())
	End

	(cAliasQry)->(dbCloseArea())

	RestArea(aArea)

Return aImages

//------------------------------------------------------------------------------
/*/{Protheus.doc} DeleteFile
Deleta imagem do Banco de Conhecimento.

@author Vitor Bonet
@since 16/08/2018

@param cId, Caractere, C�digo do Objeto.

@return L�gico.

/*/
//------------------------------------------------------------------------------
Method DeleteFile(cId) Class MntSR

    Local cSlash   := If(isSRVunix(),"/","\")
    Local cDocPath := MsDocPath() + cSlash
    Local aArea    := GetArea()
    Local cAlias   := GetNextAlias()
	Local lRet     := .T.

    cQry := " SELECT AC9_CODENT, ACB_OBJETO "
    cQry += " FROM " + RetSqlName("AC9") + " AC9 "
    cQry += " INNER JOIN " + RetSqlName("ACB") + " ACB "
    cQry += "     ON ACB_CODOBJ = AC9_CODOBJ "
    cQry += "     AND ACB.D_E_L_E_T_ <> '*'
    cQry += " WHERE AC9_FILENT = " + ValToSQL(xFilial("TQB"))
    cQry += "     AND AC9_ENTIDA = 'TQB'"
    cQry += "     AND AC9_CODOBJ = "+ ValToSQL(cId)
    cQry += "     AND AC9.D_E_L_E_T_ <> '*'
    cQry += "     AND AC9_FILIAL = " + ValToSQL(xFilial("AC9"))

    cQry := ChangeQuery(cQry)

    MPSysOpenQuery(cQry, cAlias)

    dbSelectArea(cAlias)

    If Empty( ( cAlias )->AC9_CODENT )
        ::addError( STR0073 + cId + STR0074 )
        lRet := .F.
    EndIf

    // Remover v�nculo de entidades (dele��o l�gica)
    dbSelectArea( 'AC9' )
    dbSetOrder( 2 ) // AC9_FILIAL + AC9_ENTIDA + AC9_FILENT + AC9_CODENT + AC9_CODOBJ
    If dbSeek( xFilial( 'AC9' ) + 'TQB' + xFilial( 'TQB' ) +( cAlias )->AC9_CODENT + cId )
        RecLock( 'AC9', .F. )
        dbDelete()
        MsUnlock()
    EndIf

    // Remover registro textual do banco de objetos (dele��o l�gica)
    dbSelectArea( 'ACB' )
    dbSetOrder( 1 ) // ACB_FILIAL + ACB_CODOBJ
    If dbSeek( xFilial( 'ACB' ) + cId )
        RecLock( 'ACB', .F. )
        dbDelete()
        MsUnlock()
    EndIf

    // Remover arquivo f�sico do banco de conhecimento
    If File( cDocPath + ( cAlias )->ACB_OBJETO )
        FErase( cDocPath + ( cAlias )->ACB_OBJETO )
    EndIf

    ( cAlias )->( dbCloseArea() )
	RestArea( aArea )

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} fDplSR
Alerta a exist�ncia de SS duplicadas.

@author Wexlei Silveira
@since 07/06/2018
@param oTQB    , Object  , Objeto com os valores.
@param cAsset , Caracter, C�digo do bem.
@param cServCode, Caracter, C�digo do tipo de servi�o.

@return lRet, L�gico, Retorna verdadeiro caso possua outra S.S.
/*/
//------------------------------------------------------------------------------
Static Function fDplSR(oTQB, cAsset, cServCode)

	Local lRet     := .F.
	Local aArea    := GetArea()
	Local aAreaTQB := TQB->(GetArea())

	dbSelectArea("TQB")
	dbSetOrder(05)
	dbSeek(xFilial("TQB") + cAsset,.T.)
	While !Eof() .And. TQB->TQB_FILIAL == xFilial("TQB") .And. TQB->TQB_CODBEM == cAsset

		If TQB->TQB_CDSERV == cServCode .And. TQB->TQB_SOLUCA == "A"
			lRet := .T.
			Exit
		EndIf

		TQB->(dbSkip())
	EndDo

	RestArea(aAreaTQB)
	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} fValServ
Fun��o respons�vel pela valida��o do campo 'TQB_CDSERV'

@param cCodServ, Caracter, C�digo do servi�o - TQB_CDSERV.

@author Guilherme Freudenburg
@since 10/08/2018

@return lRet, L�gico, Retorna verdadeiro caso possua outra S.S.
/*/
//------------------------------------------------------------------------------
Static Function fValServ(cCodServ)

	Local aArea := GetArea()
	Local cErro := ""

	dbSelectArea("TQ3")
	dbSetOrder(1)
	If !dbSeek(xFilial("TQ3")+cCodServ)
		cErro := STR0015 + Alltrim(Posicione("SX3",2,"TQB_CDSERV","X3Titulo()")) + STR0075 //"O valor informado no campo " #### " est� incorreto."
	EndIf

RestArea(aArea)

Return cErro

//------------------------------------------------------------------------------
/*/{Protheus.doc} fInputStep
Grava Insumo e/ou Etapa da OS.
@type function

@param cSOCode , Caractere, C�digo da OS
@param cSOPlan , Caractere, C�digo do plano da OS
@param [aInput], Array    , Array da Tarefa
@param [aStep] , Array    , Array da Etapa
@param cCostCnt, Caractere, C�digo do Centro de Custo

@author Wexlei Silveira
@since 30/08/2018

@return aBlock, Array, Array dos recursos a serem bloqueados.
@Obs.: C�pia da fun��o NGGSTLSTQ
/*/
//------------------------------------------------------------------------------
Static Function fInputStep( cSOCode, cSOPlan, aInput, aStep, cCostCnt )

	Local i          := 1
	Local nTIP       := 0
	Local lSEQTAR    := NGCADICBASE( 'TL_SEQTARE', 'A', 'STL', .F. )
	Local lGrvBLO    := .T.
	Local aBlock     := { {}, {}, {}, {}, {} }
	Local aInsFim    := {}
	Local aArea      := GetArea()
	Local cCorPR     := SuperGetMv( 'MV_NGCORPR', .F., 'N' )
	Local cBlockEmp  := 'S'
	Local cBlockTool := 'S'
	Local cBlockItem := 'S'
	Local cUsCal     := ''
	Local cHrFim     := ''
	Local cHrIni     := ''
	Local dDtFim     := cToD( '' )
	Local dDtIni     := cToD( '' )

	If cSOPlan <= "000000"

		cBlockEmp  := IIf(cCorPR == "S", "S", "N")
		cBlockTool := IIf(cCorPR == "S", "S", "N")
		cBlockItem := IIf(cCorPR == "S", "S", "N")

	EndIf

	For i := 1 to Len(aInput)

		cUsCal := IIf( Empty( aInput[i,10] ), 'N', aInput[i,10] )

		If FindFunction( 'NgVldRpo' ) .And. NgVldRpo( { { 'MNTA295.prw', cToD( '20/12/2019' ), '11:08' } } )

			cHrIni := aInput[i][14]
			dDtIni := aInput[i][13]

			If aInput[i,2] == 'P'

				dDtFim := aInput[i,13]
				cHrFim := aInput[i,14]

			ElseIf aInput[i,2] == 'M'

				aInsFim := M420RETDAT( aInput[i,3], aInput[i,13], aInput[i,14], aInput[i,5], cUsCal )

				dDtFim := aInsFim[3]
				cHrFim := aInsFim[4]

			Else

				aInsFim := NGDTHORFIM( aInput[i,13], aInput[i,14], aInput[i,5], aInput[i][9] )

				dDtFim := aInsFim[1]
				cHrFim := aInsFim[2]

			EndIf

		EndIf

		dbSelectArea("STL")
		dbSetOrder(1)
		If !dbSeek(cSOCode + cSOPlan + aInput[i][1] + aInput[i][2] + aInput[i][3])

			STL->(RecLock("STL",.T.))
			STL->TL_FILIAL  := xFilial("STL")
			STL->TL_ORDEM   := cSOCode
			STL->TL_PLANO   := cSOPlan
			STL->TL_TAREFA  := aInput[i][1]
			STL->TL_TIPOREG := aInput[i][2]
			STL->TL_CODIGO  := aInput[i][3]
			STL->TL_QUANREC := aInput[i][4]
			STL->TL_QUANTID := aInput[i][5]
			STL->TL_UNIDADE := aInput[i][6]
			STL->TL_DESTINO := aInput[i][7]
			STL->TL_LOCAL   := aInput[i][8]
			STL->TL_SEQRELA := "0"
			STL->TL_TIPOHOR := aInput[i][9]
			STL->TL_USACALE := cUsCal
			STL->TL_CUSTO   := aInput[i][11]
			STL->TL_DTINICI := dDtIni
			STL->TL_HOINICI := cHrIni
			STL->TL_DTFIM   := dDtFim
			STL->TL_HOFIM   := cHrFim

			If STL->TL_TIPOREG == 'T'
				STL->TL_FORNEC := aInput[i][15]
				STL->TL_LOJA   := aInput[i][16]
			EndIf

			If lSEQTAR
				STL->TL_SEQTARE := aInput[i][12]
			EndIf
			STL->TL_OBSERVA := aInput[i][17]
			STL->(MsUnlock())

		EndIf

		If aInput[i][2] == "F"
			nTIP := IIf(cBlockTool == "S", 1, 0)
		ElseIf aInput[i][2] == "M"
			nTIP := IIf(cBlockEmp == "S", 2, 0)
		ElseIf aInput[i][2] == "E"
			nTIP := IIf(cBlockEmp == "S", 3, 0)
		ElseIf aInput[i][2] == "P"
			nTIP := IIf(cBlockItem == "S", 4, 0)
		ElseIf aInput[i][2] == "T"
			nTIP := IIf(cBlockItem == "S", 5, 0)
		Else
			nTIP := 0
		EndIf

		If nTIP > 0

			lGrvBLO := .T.
			If nTIP == 4 // Aglutina produtos iguais

				nPosBlo := aScan(aBlock[nTIP], {|x| x[2]+x[11] = aInput[i][3] + aInput[i][12]})
				If nPosBlo > 0
					aBlock[nTIP][nPosBlo][3] += IIf(aInput[i][2] $ "E/F", aInput[i][4], aInput[i][5])
					lGrvBLO := .F.
				Else
					lGrvBLO := .T.
				EndIf

			EndIf

			If lGrvBLO
				AAdd(aBlock[nTIP], {aInput[i][1],;
									aInput[i][3],;
									IIf(aInput[i][2] $ "E/F", aInput[i][4], aInput[i][5]),;
									dDtIni,;
									cHrIni,;
									dDtFim,;
									cHrFim,;
									cSOCode      ,;
									cSOPlan      ,;
									cCostCnt     ,;
									aInput[i][8],;
									aInput[i][6] ,;
									"S",;
									,,,,,,,,;
									STL->TL_FORNEC,; // 22
									STL->TL_LOJA}) // 23
									
									
			EndIf

		EndIf

	Next i

	//Grava as etapas da O.S.
	For i := 1 To Len(aStep)

		dbSelectArea("STQ")
		RecLock("STQ", .T.)
		STQ->TQ_FILIAL := xFILIAL("STQ")
		STQ->TQ_ORDEM  := cSOCode
		STQ->TQ_PLANO  := cSOPlan
		STQ->TQ_TAREFA := aStep[i][1]
		STQ->TQ_ETAPA  := aStep[i][2]
		STQ->TQ_SEQETA := aStep[i][3]
		MsUnlock("STQ")

	Next i

	RestArea(aArea)

Return aBlock

//------------------------------------------------------------------------------
/*/{Protheus.doc} fValCnt
Valida��es de contador.

@param cAsset, Caractere, C�digo do bem.
@param cDate, Caractere, Data do apontamento de contador.
@param cHour, Caractere, Hora do apontamento do contador.
@param nCounter, Num�rico, Valor do contador.
@param nType, Num�rico, Tipo de contador (1 ou 2).
@param lGetAsk, L�gico, Define se retorna perguntas.

@author Wexlei Silveira
@since 18/09/2018

@return aEror, Array, L�gico se o retorno � pergunta ou mensagem e
Descri��o do erro ou vazio se n�o houver erros {lPergunta, cMensagem}.
/*/
//------------------------------------------------------------------------------
Static Function fValCnt(cAsset, cDate, cHour, nCounter, nType, lGetAsk)

	Local aRet   := {}
	Local aAcum  := {}
	Local nAcum  := 0
	Local nDtVar := 0
	Local aError := {.F., ""}
	Local aArea  := GetArea()

	// Posi��o de contador menor que zero
	If nCounter < 0
		aError := {.F., STR0076}
	EndIf

	// 3.3.1 - N�o � permitido informar um valor de contador superior ao limite cadastrado na tabela ST9
	// 3.4.1 - N�o � permitido informar um valor de contador superior ao limite cadastrado na tabela TPE
	If Empty(aError[2])

		aRet := CHKPOSLIM(cAsset, nCounter, nType, , .F.)
		If !aRet[1]
			aError := {.F., aRet[2]}
		EndIf

	EndIf

	// 3.3.2 - N�o � permitido informar uma posi��o de contador inconsistente ao hist�rico de lan�amentos
	// 3.4.2 - N�o � permitido informar uma posi��o de contador 2 inconsistente ao hist�rico de lan�amentos
	If aRet[1]

		aRet := NGCHKHISTO(cAsset, cDate, nCounter, cHour, nType, , .F.)
		If !aRet[1]
			aError := {.F., aRet[2]}
		EndIf

	EndIf

	// 3.3.3 - O usu�rio ser� alertado quando a posi��o de contador informado ultrapassar o limite de varia��o dia.
	If aRet[1]

		aAcum := NGACUMEHIS(cAsset, cDate, cHour, nType, "A")
		nAcum := aAcum[2] + (nCounter - aAcum[1])
		nDtVar := NGVARIADT(cAsset, cDate, nType, nAcum, .F., .T.)

		// 3.3.4 - O usu�rio ser� alertado quando a varia��o dia no intervalo ultrapassar o limite de varia��o estipulado para o bem nas tabelas STP e ST9.
		aRet := NGCHKLIMVAR(cAsset, NGSEEK("ST9", cAsset, 1, "T9_CODFAMI"), nType, nDtVar, .F., .F.)
		If !aRet[1]
			If lGetAsk
				aError := {.T., aRet[2]}
			EndIf
		EndIf

	EndIf

	// 3.4.3 - O usu�rio ser� alertado quando a varia��o dia no intervalo ultrapassar o limite de varia��o estipulado para o bem
	If aRet[1]

		aRet := NGVALIVARD(cAsset, nCounter, cDate, cHour, nType, .F.)
		If !aRet[1]
			If lGetAsk
				aError := {.T., aRet[2]}
			EndIf
		EndIf

	EndIf

	RestArea(aArea)

Return aError

//------------------------------------------------------------------------------
/*/{Protheus.doc} fQuestions
Grava campos de pesquisa para facilities

@author Maria Elisandra de paula
@since 27/09/2019
@param cSolic, string, C�digo da solicita��o
@return Nil
/*/
//------------------------------------------------------------------------------
Static Function fQuestions( cSolic )

	Local aQuest  := {}

	//Retorna question�rios
	aQuest := fRetQuesti( AllTrim( SuperGetMv( "MV_NGPESST",.F.,"" ) ), cSolic, .F., "" )
	If Len( aQuest ) > 0 .And. aQuest[4] <> "1" //Verifica se o Question�rio est� habilitado ou n�o (1=Sim;2=N�o)
		MNT307QUE( .F., cSolic, .T. ) //Grava campos referente a pesquisa
	EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} isPending
Verifica se h� pesquisa pendente para o usu�rio

@author Maria Elisandra de paula
@since 27/09/2019
@return boolean, se h� pesquisa pendente para o usu�rio
/*/
//------------------------------------------------------------------------------
Static Function isPending()

	Local cCodUser  := RetCodUsr() // Retorna o Codigo do Usuario
	Local cAliasQry := GetNextAlias()
	Local lRet      := .F.

	If AllTrim( SuperGetMv("MV_NG1FAC", .F., "2") ) == "1" //facilities

		BeginSql Alias cAliasQry

			SELECT COUNT( TQB_SOLICI ) AS NClose
			FROM %table:TQB% TQB
			WHERE TQB.TQB_SOLUCA = 'E'
				AND TQB.TQB_CDSOLI = %Exp:cCodUser%
				AND TQB.TQB_SATISF <> '1'
				AND TQB.TQB_SEQQUE <> ' '
				AND TQB.TQB_FILIAL = %xFilial:TQB%
				AND TQB.%NotDel%

		EndSql

	Else

		BeginSql Alias cAliasQry

			SELECT COUNT( TQB_SOLICI ) AS NClose
			FROM %table:TQB% TQB
			INNER JOIN %table:TQ3% TQ3
				ON TQ3.TQ3_FILIAL = %xFilial:TQ3%
			  	AND TQB.TQB_CDSERV = TQ3.TQ3_CDSERV
				AND TQ3.%NotDel%
				AND TQ3.TQ3_PESQST = '1'
			  WHERE TQB.TQB_SOLUCA = 'E'
			    AND TQB.TQB_CDSOLI = %Exp:cCodUser%
			    AND TQB.TQB_PSAP = ' '
			    AND TQB.TQB_PSAN = ' '
				AND TQB.TQB_FILIAL = %xFilial:TQB%
				AND TQB.%NotDel%

		EndSql
	EndIf

	lRet := (cAliasQry)->NClose > 0

	(cAliasQry)->(dbCloseArea())

Return lRet
