#include "PROTHEUS.CH"
#include "OFINJD28.CH"

/*/{Protheus.doc} mil_ver()
	Retorna a funcao do fonte em novo padrao definido entre Vinicius/Rubens/Andre

	Pontos de entrada:
		PEOJD28CPOS => Usado para customizar os campos no grid

	Parametros:
		MV_XMILDBG => Usado para gravar logs adicionais de debug


	@author Vinicius Gati
	@since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	Endif
Return "006235_5"

/*/{Protheus.doc} OFINJD28 "Demanda Retro"
	Permitirá alterar registros relacionados a demanda(DPM) de um orçamento e reprocessar a demanda dele(retroativo)

	Pontos de entrada:

	Parametros:
		MV_XMILDBG => Usado para gravar logs adicionais de debug


	@author Vinicius Gati
	@since  12/08/2015
/*/
Function OFINJD28(cOrc)
	Private oDlgRecOpc
	Private oEnchParam
	Private aCols         := {}
	Private aHeader       := {}
	Private cCampos       := "VS3_SEQUEN/VS3_GRUITE/VS3_CODITE/VS3_CODSIT/VS3_MOTPED"
	Private oInterfHelper := DMS_InterfaceHelper():New()
	Private aVS3Campos    := FS_GtCposEnc('VS3')
	Private aVS3Header    := FS_GtHeader('VS3')
	Private cNumOrc       := ""
	Private cMotivo       := "000004"  //Filtro da consulta do motivo de Cancelamentos (Orcamento)
	Private oGetDados     := Nil

	if ExistBlock("PEOJD28CPOS")
		cCampos := ExecBlock("PEOJD28CPOS",.f.,.f.)
	EndIf

	If Empty(cOrc)
		Alert(STR0007) // "Esta rotina só deve ser acessada pelo painel de orçamento, ou passando um número de orçamento para a função principal."
		Return .F.
	Endif

	cNumOrc := cOrc

	OJD28CTela()

	dbselectarea('VS1')
	dbseek(xFilial('VS1') + cNumOrc)
	M->TST_TIPORC := VS1->VS1_TIPORC
	M->TST_NUMORC := VS1->VS1_NUMORC
	M->TST_DATORC := VS1->VS1_DATORC
	M->TST_NCLIFT := VS1->VS1_NCLIFT
	M->TST_LOJA   := VS1->VS1_LOJA

	ACTIVATE MSDIALOG oDlgRecOpc;
		ON INIT ( EnChoiceBar(oDlgRecOpc,;
			{|| IIF(FS_CONFIRMA(), oDlgRecOpc:End(), nil) } ,;
			{|| OFINJD2801_FecharTela(), oDlgRecOpc:End() }, , ) )
Return .T.

/*/{Protheus.doc} OJD28CTela
    Cria tela

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function OJD28CTela()
	Local oSizePrinc
	Local   _ni          := 1
	Local nOpcG          := 3
	Private cTudOk       := "OFINJD2803_ValidarLinhaDoGetDados()"
	Private cLinOk       := "OFINJD2803_ValidarLinhaDoGetDados()"
	Private cGdTOK       := "allwaysTrue()"
	Private cFieldOk     := "OFINJD2804_ValidacaoFOk()"

	oInterfHelper:nOpc := 3

	oSizePrinc := oInterfHelper:CreateDefSize( .T. , {;
		{"MGET"  ,060,060,.T.,.F.},;
		{"ITENS" ,100,100,.T.,.T.} ;
	})
	oSizePrinc:aMargins := { 2 , 2 , 2 , 2 }
	oSizePrinc:Process()

	oInterfHelper:SetDefSize(oSizePrinc,"MGET")
	oDlgRecOpc := oInterfHelper:CreateDialog(STR0010/*"Dados Orçamento"*/) // "Dados Orçamento"
	oInterfHelper:SetOwnerPvt("OFINJD28")

	oInterfHelper:SetPrefixo("TST")
	oInterfHelper:AddMGet("VS1_NUMORC", {{"X3_VISUAL", "V"}})
	oInterfHelper:AddMGet("VS1_NCLIFT", {{"X3_VISUAL", "V"}})
	oInterfHelper:AddMGet("VS1_LOJA"  , {{"X3_VISUAL", "V"}})
	oInterfHelper:AddMGet("VS1_DATORC", {{"X3_VISUAL", "V"}})
	oInterfHelper:AddMGet("VS3_MOTPED", {;
		{"X3_VISUAL", "A"}, ;
		{"X3_VALID", "OFINJD2802_AlteraTodos('VS3_MOTPED', TST_MOTPED)"} ;
	})
	oInterfHelper:AddMGet("VS3_CODSIT", {;
		{"X3_VISUAL", "A"}, ;
		{"X3_VALID", "OFINJD2802_AlteraTodos('VS3_CODSIT', TST_CODSIT)"} ;
	})
	oEnchParam := oInterfHelper:CreateMSMGet(.F.)

	//////////////////////////////////////////
	// Criacao da GetDados                  //
	//////////////////////////////////////////

	aHeader := aVS3Header
	// Inclui coluna de registro atraves de funcao generica
	dbSelectArea("VS3")

	// Posicao do registro
	nPosRec := Len(aHeader)
	nUsado  := Len(aHeader)

	aCols:={}
	dbSelectArea("VS3")
	dbSetOrder(1)
	dbSeek(xFilial() + cNumOrc)

	While !eof() .And. VS3->VS3_FILIAL == xFilial("VS3") .AND. VS3->VS3_NUMORC == cNumOrc
		AADD(aCols,Array(nUsado+1))
		For _ni := 1 to nUsado
			if _ni == 1 // cancelado S ou N
				if Empty(VS3->VS3_MOTPED)
					aCols[Len(aCols), _ni] := 'Não'
				else
					aCols[Len(aCols), _ni] := 'Sim'
				end
			else
				aCols[Len(aCols),_ni] := IIf(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			end
		Next
		aCols[Len(aCols),nUsado+1] := .F.
		dbSkip()
	EndDo
	nLenaCols := Len(aCols)

	oGetDados := MsGetDados():New(;
		oSizePrinc:GetDimension("ITENS","LININI"),;
		oSizePrinc:GetDimension("ITENS","COLINI"),;
		oSizePrinc:GetDimension("ITENS","LINEND"),;
		oSizePrinc:GetDimension("ITENS","COLEND"),;
		nOpcG, cLinOk, cGdTOK, "", .F. /*permite deletar?*/, ;
		{'VS3_CODSIT', 'VS3_MOTPED'} ,,,nLenaCols, cFieldOk,,, '{|| AllwaysTrue() }')

Return .T.

/*/{Protheus.doc} FS_GtCposEnc

	@author       Vinicius Gati
	@since        17/11/2014(VEIVA380)
	@description  Pega campos validos para a enchoice
	@param        cAlias, Alias da tabela

/*/
Static Function FS_GtCposEnc(cAlias)
	Local aCampos := {}
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("VS3")
	While !Eof() .And. (x3_arquivo == "VS3")
		If x3_campo $ cCampos
			AADD(aCampos, x3_campo)
		Endif
		DbSkip()
	EndDo
Return aCampos

/*/{Protheus.doc} FS_GtCposEnc

	@author       Vinicius Gati
	@since        17/11/2014(VEIVA380)
	@description  Pega header validos para a getdados
	@param        cAlias, Alias da tabela
/*/
Static Function FS_GtHeader(cAlias)
	Local aHeader := {}

	Aadd(aHeader, { STR0016/*'Cancelado?'*/, 'BMP_CANC', '@!', 15, 0, '', '', 'C','VS3', 'V', '', '' })

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	While !Eof().And.(x3_arquivo==cAlias)
		If x3_campo $ cCampos
			Aadd(aHeader, { TRIM(X3Titulo()) , x3_campo, x3_picture, x3_tamanho, ;
				x3_decimal, '', x3_usado, x3_tipo, x3_arquivo, x3_context, ;
				x3_relacao, x3_reserv } )
		Endif
		dbSkip()
	EndDo
Return aHeader

/*/{Protheus.doc} FS_CONFIRMA

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Acao do botao confirma

/*/
Static Function FS_CONFIRMA(nOpc)
	Local oDPM       := DMS_DPM():New()
	Local nLoop      := 1
	Local cVS3Sequen := ""
	Local cCodSit    := ""
	Local cMotPed    := ""
	Begin Transaction

		BEGIN SEQUENCE
			///////////////////////////////////////
			// Gravação VS3 - Itens do orçamento //
			///////////////////////////////////////
			for nLoop := 1 to Len(aCols)
				if OFINJD2803_ValidarLinhaDoGetDados(,nLoop)
					DbSelectArea('VS3')
					dbSetOrder(1)
					cVS3Sequen := aCols[nLoop, FG_POSVAR('VS3_SEQUEN')]
					VS3->(DbSeek( xFilial('VS3') + cNumOrc + cVS3Sequen))
					RecLock("VS3", !Found())

					cCodSit := aCols[nLoop, FG_POSVAR('VS3_CODSIT')]
					if Empty(cCodSit) .OR. ExistCpo('V09', cCodSit)
						VS3->VS3_CODSIT := cCodSit
					end

					cMotPed := aCols[nLoop, FG_POSVAR('VS3_MOTPED')]
					if Empty(cMotPed) .Or. ExistCpo('VS0', cMotivo + cMotPed)
						VS3->VS3_MOTPED := cMotPed
					end

					VS3->(MsUnlock())
				else
					return .F.
				end
			next
			oDPM:OrcToReproc(xFilial('VS1'), cNumOrc)
		RECOVER
			DisarmTransaction()
			//Erro ao salvar, verifique sua conexão com banco de dados
			UserException(STR0006)
			Return .F.
		END SEQUENCE

	End Transaction
Return .T.

/*/{Protheus.doc} OFINJD2801_FecharTela

	@author       Vinicius Gati
	@since        17/11/2014
	@description  Cancela tudo e volta para mbrowse

/*/
Function OFINJD2801_FecharTela()
	DisarmTransaction()
Return .T.

/*/{Protheus.doc} OFINJD2802_AlteraTodos

	@author       Vinicius Gati
	@since        06/04/2017
	@description  Altera no grid o campo passado pro parametro, com o valor também passado por parametro

/*/
Function OFINJD2802_AlteraTodos(cCampo, cValor)
	Local nLoop := 1
	if Empty(cValor) // não altera se ficou em branco
		return
	end
	if cCampo == 'VS3_MOTPED'
		if !ExistCpo('VS0', cValor)
			M->TST_MOTPED := SPACE(tamsx3('VS3_MOTPED')[1])
			//MSGALERT(STR0014/*"Motivo digitado inválido."*/, STR0013 /*"Atenção"*/)
			return
		end
	end
	if cCampo == 'VS3_CODSIT'
		if !ExistCpo('V09', cValor)
			M->TST_CODSIT := SPACE(tamsx3('VS3_CODSIT')[1])
			//MSGALERT(STR0015/*"Código digitado inválido."*/, STR0013 /*"Atenção"*/)
			return
		end
	end

	if cCampo == 'VS3_MOTPED'
		cMsg := STR0017 //"Deseja alterar o motivo de cancelamento para todos os itens que estão com Cancelado? = Sim"
	else
		cMsg := STR0012
	end
	if MSGYESNO(cMsg)
		for nLoop := 1 to Len(aCols)
			if cCampo == "VS3_MOTPED"
				// VS3_MOTPED só pode ser alterado se tem algum conteúdo nele
				// pois não se pode alterar esse campo de item não cancelado
				if ! Empty(aCols[nLoop, FG_POSVAR(cCampo)])
					aCols[nLoop, FG_POSVAR(cCampo)] := cValor
				end
			else
				aCols[nLoop, FG_POSVAR(cCampo)] := cValor
			end
		next
		oGetDados:Refresh()
	end
Return .T.

/*/{Protheus.doc} OFINJD2803_ValidarLinhaDoGetDados

	@author       Vinicius Gati
	@since        06/04/2017
	@description  Valida as alterações da linha selecionada ou passada por parametro

/*/
Function OFINJD2803_ValidarLinhaDoGetDados(cMotCanc, nAt)
	Local aDados    := Nil
	Local lRet      := .T.
	Local nIdxMot   := FG_POSVAR("VS3_MOTPED")
	Local lCanc     := .F.
	Default nAt     := oGetDados:oBrowse:nAt
	Default cMotCanc := "@@@@@@@"

	aDados := aCols[nAt]
	if cMotCanc == "@@@@@@@"
		cMotCanc := aDados[nIdxMot]
	end

	VS3->(dbSetOrder(1))
	VS3->(DbSeek( xFilial('VS3') + cNumOrc + aDados[FG_POSVAR('VS3_SEQUEN')] ))
	lCanc := ! Empty(VS3->VS3_MOTPED)

	if ! lCanc .AND. ! EMPTY(cMotCanc)
		MSGALERT(STR0008 /*"Não é possível atualizar o motivo de cancelamento para um item não cancelado."*/, STR0013 /*"Atenção"*/)
		cMotCanc := VS3->VS3_MOTPED
		lRet := .F.
	elseif lCanc .AND. EMPTY(cMotCanc)
		MSGALERT(STR0009/*"Não é possível remover o motivo de cancelamento de um item cancelado."*/, STR0013 /*"Atenção"*/)
		cMotCanc := VS3->VS3_MOTPED
		lRet := .F.
	elseif ! EMPTY(cMotCanc) .AND. ! ExistCpo('VS0', cMotivo + cMotCanc)
		cMotCanc := VS3->VS3_MOTPED
		lRet := .F.
	end
	oGetDados:Refresh()
Return lRet


/*/{Protheus.doc} OFINJD2804_ValidacaoFOk

	@author       Vinicius Gati
	@since        20/04/2017
	@description  Valida valor digitado

/*/
Function OFINJD2804_ValidacaoFOk()
	if readvar() == "M->VS3_MOTPED"
		return OFINJD2803_ValidarLinhaDoGetDados(M->VS3_MOTPED)
	elseif readvar() == "M->VS3_CODSIT"
		return ExistCpo('V09', M->VS3_CODSIT)
	end
return .t.