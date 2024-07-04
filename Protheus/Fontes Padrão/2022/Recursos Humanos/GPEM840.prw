#Include 'Protheus.ch'
#Include 'GPEM800A.CH'

/*/{Protheus.doc}GPEM840
Função principal da Ferramenta de Diagnóstico de Base
@author Gabriel de Souza Almeida
@since 24/04/2017
@version P12
@return Nil
/*/
Function GPEM840()
	Local aArea       := GetArea()
	Local aStruct     := {}
	Local cValidFil   := fValidFil()

	Private lHstMov   := .T.
	Private lProv     := .T.
	Private lCadFun   := .T.
	Private lDiasDir  := .T.
	Private lCadVerb  := .T.
	Private lCompVerb := .T.
	Private lVerbFer  := .T.
	Private lVldCompar:= .T.
	Private lExibeGE  := .T.
	Private lVldGrp   := .T.
	Private lVldCTT	  := .T.
	Private lModComp  := .T.

	Private cAliasSM0 := GetNextAlias()
	Private oTmpTbl   := FWTemporaryTable():New(cAliasSM0)
	Private cMark     := GetMark()
	Private oMsSelect := Nil
	Private cIniLcto  := SuperGetMv("MV_COMPSRD", NIL, "201701")

	If Empty(cIniLcto) .Or. !( Len(cIniLcto) == 6 )
		cIniLcto := "201701"
	EndIf

	DbSelectArea("SM0")
	SM0->(DbGoTop())

	aAdd(aStruct, { "EMPRESA" ,"C",Len(SM0->M0_CODIGO) ,0} )
	aAdd(aStruct, { "FILIAL"  ,"C",Len(SM0->M0_CODFIL) ,0} )
	aAdd(aStruct, { "MARK"    ,"C",02                  ,0} )
	aAdd(aStruct, { "NOME"    ,"C",20                  ,0} )

	oTmpTbl:SetFields(aStruct)
	oTmpTbl:AddIndex("INDEX1", {"EMPRESA", "FILIAL"})
	oTmpTbl:Create()

	If (cAliasSM0)->(Eof())
		nRecSM0 := SM0->(Recno())

		While SM0->(!Eof())
			If AllTrim(SM0->M0_CODIGO) == cEmpAnt .And. AllTrim( SM0->M0_CODFIL ) $ cValidFil
				RecLock(cAliasSM0,.T.)
				(cAliasSM0)->EMPRESA := SM0->M0_CODIGO
				(cAliasSM0)->FILIAL  := SM0->M0_CODFIL
				(cAliasSM0)->NOME    := SM0->M0_FILIAL
				(cAliasSM0)->MARK    := cMark
				(cAliasSM0)->(MsUnLock())
			EndIf

			SM0->(DbSkip())
		EndDo
	EndIf

	//Painel 1 - Tela inicial do Wizard
	//"Ferramenta de Diagnóstico de Inconsistências de Base"
	//"Validação de inconsistências na base"
	//"Ferramenta de Diagnóstico de Inconsistências"
	//"Essa ferramenta validará algumas inconsistências existentes na base, afim de auxiliar no dignóstico de possíveis erros."
	oWizard := APWizard():New( STR0001, STR0004, STR0002, STR0003, {||.T.}, {||.T.}, .F., Nil, {|| .T.}, Nil, {00,00,450,600} )


	//Painel 2 - Seleção das opções de verificação
	oWizard:NewPanel( STR0005               ,; //"Itens a Validar"
						STR0006               ,; //"Selecione o(s) iten(s) que deseja validar"
						{||.T.}               ,; //<bBack>
						{||.T.}               ,; //<bNext>
						{||.F.}               ,; //<bFinish>
						.T.                   ,; //<.lPanel.>
						{|| fGetOpcoes()}   )    //<bExecute>

	//Painel 3 - Seleção de Filiais
	oWizard:NewPanel(	STR0060         ,; //"Seleção de Filiais"
						STR0061        ,; //"Selecione as filiais cujos dados serão validados"
						{||.T.}        ,; //<bBack>
						{||.T.}        ,; //<bNext>
						{||.F.}        ,; //<bFinish>
						.T.            ,; //<.lPanel.>
						{|| GetFils() } ) //<bExecute>


	//Painel 4 - Acompanhamento do Processo
	oWizard:NewPanel(	STR0007                 ,; //"Realizando validação na base"
						STR0008                 ,; //"Após gerar o log clique em finalizar para encerrar a operação."
						{||.F.}                 ,; //<bBack>
						{||.F.}                 ,; //<bNext>
						{||.T.}                 ,; //<bFinish>
						.T.                     ,; //<.lPanel.>
						{| lEnd| fChamaVld(@lEnd)})//<bExecute>


	oWizard:Activate( .T.,{||.T.},{||.T.},	{||.T.})

	If oTmpTbl <> Nil
		oTmpTbl:Delete()
		oTmpTbl := Nil
	EndIf

	RestArea(aArea)
Return

/*/{Protheus.doc}fGetOpcoes
Define as opções de validação da ferramenta
@author Gabriel de Souza Almeida
@since 24/04/2017
@version P12
@return Nil
/*/
Static Function fGetOpcoes()

	Local aRetcoords := {}
	Local oPanel     := oWizard:oMPanel[oWizard:nPanel]
	Local lSel       := .T.

	Private oChkTeste
	Private oCheck2
	Private oCheck3

	aRetcoords := RetCoords(2,8,150,20,2,,,,{0,0,oPanel:oWnd:nTop*0.92,oPanel:oWnd:nLeft*0.88})

	//Marca os itens de validação
	TcheckBox():New(aRetcoords[01][1], aRetcoords[01][2], STR0009,{|| lHstMov   },oPanel, 300,10,,{|| lHstMov:=!lHstMov      },,,,,,.T.,,,) //"Movimentos"
	TcheckBox():New(aRetcoords[02][1], aRetcoords[02][2], STR0010,{|| lProv     },oPanel, 300,10,,{|| lProv:=!lProv          },,,,,,.T.,,,) //"Provisão"
	TcheckBox():New(aRetcoords[03][1], aRetcoords[03][2], STR0011,{|| lCadFun   },oPanel, 300,10,,{|| lCadFun:=!lCadFun      },,,,,,.T.,,,) //"Cadastro de Funcionários"
	TcheckBox():New(aRetcoords[04][1], aRetcoords[04][2], STR0013,{|| lDiasDir  },oPanel, 300,10,,{|| lDiasDir:=!lDiasDir    },,,,,,.T.,,,) //"Dias de Direito"
	TcheckBox():New(aRetcoords[05][1], aRetcoords[05][2], STR0016,{|| lCadVerb  },oPanel, 300,10,,{|| lCadVerb:=!lCadVerb    },,,,,,.T.,,,) //"Cadastro de Verbas"
	TcheckBox():New(aRetcoords[06][1], aRetcoords[06][2], STR0014,{|| lCompVerb },oPanel, 300,10,,{|| lCompVerb:=!lCompVerb  },,,,,,.T.,,,) //"Comparação das incidências das verbas"
	TcheckBox():New(aRetcoords[07][1], aRetcoords[07][2], STR0073,{|| lVerbFer  },oPanel, 300,10,,{|| lVerbFer:=!lVerbFer    },,,,,,.T.,,,) //"Data de pagamento de Verbas de férias"
	TcheckBox():New(aRetcoords[08][1], aRetcoords[08][2], STR0080,{|| lVldCompar},oPanel, 300,10,,{|| lVldCompar:=!lVldCompar},,,,,,.T.,,,) //"Avaliação Estrutural"
	TcheckBox():New(aRetcoords[09][1], aRetcoords[09][2], STR0086,{|| lExibeGE	},oPanel, 300,10,,{|| lExibeGE:=!lExibeGE},,,,,,.T.,,,) //"Exibe definição de Gestão Corporativa"
	TcheckBox():New(aRetcoords[10][1], aRetcoords[10][2], STR0094,{|| lVldGrp	},oPanel, 300,10,,{|| lVldGrp:=!lVldGrp},,,,,,.T.,,,) //"Validação Grupo de Campos x SX3 x Tabelas"
	TcheckBox():New(aRetcoords[11][1], aRetcoords[11][2], STR0117,{|| lVldCTT	},oPanel, 300,10,,{|| lVldCTT:=!lVldCTT},,,,,,.T.,,,) //"Validação de Centro de Custos"
	TcheckBox():New(aRetcoords[12][1], aRetcoords[12][2], STR0106,{|| lModComp	},oPanel, 300,10,,{|| lModComp:=!lModComp},,,,,,.T.,,,) //"Modo de Compartilhamento"

	TcheckBox():New(aRetcoords[13][1], aRetcoords[13][2], STR0015,{|| lSel      },oPanel, 300,10,,{|| fInverte(lSel)        },,,,,,.T.,,,) //"Inverter Seleção"

Return

/*/{Protheus.doc}fInverte
Inverte todas as seleções
@author Gabriel de Souza Almeida
@since 24/04/2017
@version P12
@return Lógico, lRet
/*/
Static Function fInverte(lRet)

	lHstMov   := !lHstMov
	lProv     := !lProv
	lCadFun   := !lCadFun
	lDiasDir  := !lDiasDir
	lCadVerb  := !lCadVerb
	lCompVerb := !lCompVerb
	lVerbFer  := !lVerbFer
	lVldCompar:= !lVldCompar
	lExibeGE  := !lExibeGE
	lVldGrp   := !lVldGrp
	lVldCTT	  := !lVldCTT
	lModComp  := !lModComp

	oWizard:RefreshButtons()

Return !lRet

/*/{Protheus.doc}fChamaVld
Chama a função de execução principal
@author Gabriel de Souza Almeida
@since 24/04/2017
@version P12
@return Nil
/*/
Static Function fChamaVld(lEnd)

	Private oProcess

	// Executa o processamento dos arquivos
	oProcess:=	MsNewProcess():New( {|lEnd| fExecVld(oProcess) } , STR0036 , STR0036 )     //"Efetuando validação de base..."
	oProcess:Activate()

Return

/*/{Protheus.doc}fExecVld
Executa a validação da base de acordo com as opções selecionadas
@author Gabriel de Souza Almeida
@since 24/04/2017
@version P12
@return Nil
/*/
Static Function fExecVld()

	Local aTitleFil		:= {}
	Local aLogFil		:= {}
	Local nX			:= 0
	Local nY			:= 0
	Local aFil			:= fGetFil()
	Local lSRVComp		:= Empty(xFilial("SRV"))
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
	Local aFldRel		:= If(aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RA_NOME"} ), {})

	Private lOfusca		:= Len(aFldRel) > 0
	Private aCodFol		:= {}
	Private nP			:= 0

	oProcess:SetRegua1(Len(aFil))

	For nX := 1 To Len(aFil)
		If Empty(aFil[nX])
			Loop
		EndIf

		oProcess:IncRegua1(aFil[nX]) //"Empresa: + Filial: "

		If lHstMov .or. lProv .or. lCadFun .or. lDiasDir .or. lVerbFer .or. lCadVerb .or. lCompVerb
			If nX > 1
				aAdd(aLogFil,"")
				aAdd(aLogFil,"")
			EndIf
			aAdd(aLogFil,STR0017 + aFil[nX]) //"Inconsistências da filial: "
			aAdd(aLogFil,"")
			nY++
		EndIf

		If lHstMov
			nP := 0
			oProcess:IncRegua2(STR0009) //"Movimentos"
			aAdd(aLogFil,Space(3) + STR0009) //"Movimentos"
			aAdd(aLogFil,"")
			fVldIDSRD(@aLogFil,aFil[nX]) //Valida o ID 0318 na SRD e SRC
			fVldHstSRV(@aLogFil,aFil[nX]) //Valida os tipos de verba

			If nP == 0
				aAdd(aLogFil,Space(6) + STR0035) //"Não existem inconsistências na filial"
				aAdd(aLogFil,"")
			EndIf
			aAdd(aLogFil,"")
		EndIf

		If lProv
			nP := 0
			oProcess:IncRegua2(STR0010) //"Provisão"
			aAdd(aLogFil,Space(3) + STR0010) //"Provisão"
			aAdd(aLogFil,"")
			fVldProv(@aLogFil,aFil[nX]) //Valida provisão calculada

			If nP == 0
				aAdd(aLogFil,Space(6) + STR0035) //"Não existem inconsistências na filial"
				aAdd(aLogFil,"")
			EndIf
			aAdd(aLogFil,"")
		EndIf

		If lCadFun
			nP := 0
			oProcess:IncRegua2(STR0011) //"Cadastro de Funcionários"
			aAdd(aLogFil,Space(3) + STR0011) //"Cadastro de Funcionários"
			aAdd(aLogFil,"")
			FVldSraCom(@aLogFil,aFil[nX]) //Valida compartilhamento da SRA
			fVldFunDem(@aLogFil,aFil[nX]) //Valida funcionários demitidos
			fVldFunSR7(@aLogFil,aFil[nX]) //Valida Histórico Salarial
			FVldSraEmp(@aLogFil,aFil[nX]) //Valida se há registros com RA_FILIAL, RA_MAT, RA_CC em branco
			fVldFunSRE(@aLogFil,aFil[nX]) //Valida dados do cadastro com a última transferência

			If nP == 0
				aAdd(aLogFil,Space(6) + STR0035) //"Não existem inconsistências na filial"
				aAdd(aLogFil,"")
			EndIf
			aAdd(aLogFil,"")
		EndIf

		If lDiasDir
			nP := 0
			oProcess:IncRegua2(STR0013) //"Dias de Direito"
			aAdd(aLogFil,Space(3) + STR0013) //"Dias de Direito"
			aAdd(aLogFil,"")
			fVldDiaDir(@aLogFil,aFil[nX]) //Valida os dias de direito do funcionário

			If nP == 0
				aAdd(aLogFil,Space(6) + STR0035) //"Não existem inconsistências na filial"
				aAdd(aLogFil,"")
			EndIf
			aAdd(aLogFil,"")
		EndIf

		If lVerbFer
			nP := 0
			oProcess:IncRegua2(STR0067) //"Verbas de férias com pagamento divergente (SRH e SRD)"
			aAdd(aLogFil,Space(3) + STR0067) //"Verbas de férias com pagamento divergente (SRH e SRD)"
			aAdd(aLogFil,"")
			fVldVrbFer(@aLogFil,aFil[nX]) //Valida se há verbas de férias com datas de pagamento divergentes (SRH e SRD)

			If nP == 0
				aAdd(aLogFil,Space(6) + STR0035) //"Não existem inconsistências na filial"
				aAdd(aLogFil,"")
			EndIf
			aAdd(aLogFil,"")
		Endif

		If !lSRVComp
			If lCadVerb
				nP := 0
				oProcess:IncRegua2(STR0016) //"Cadastro de Verbas"
				aAdd(aLogFil,Space(3) + STR0016) //"Cadastro de Verbas"
				aAdd(aLogFil,"")
				fp_CodFol( @aCodFol , xFilial("SRV",aFil[nX]), .F., .F. )
				fVldPdMS(@aLogFil,aFil[nX]) //Valida referência de férias em verbas do mês seguinte
				fVldPdIR(@aLogFil,aFil[nX]) //Valida configuração das verbas de IR pra DIRF
				fVldPdMMS(@aLogFil,aFil[nX]) //Valida configuração das verbas mês e mês seguinte

				If nP == 0
					aAdd(aLogFil,Space(6) + STR0035) //"Não existem inconsistências na filial"
					aAdd(aLogFil,"")
				EndIf
				aAdd(aLogFil,"")
			EndIf

			If lCompVerb
				nP := 0
				oProcess:IncRegua2(STR0014) //"Comparação das incidências das verbas"
				aAdd(aLogFil,Space(3) + STR0014) //"Comparação das incidências das verbas"
				aAdd(aLogFil,Space(3) + STR0062) //"Observação: As divergências apresentadas são apenas uma sugestão para configuração de verbas, já que essa é de inteira responsabilidade do cliente."
				aAdd(aLogFil,"")
				fCompPd(@aLogFil,aFil[nX]) //Valida configuração das verbas mês e mês seguinte

				If nP == 0
					aAdd(aLogFil,Space(6) + STR0035) //"Não existem inconsistências na filial"
					aAdd(aLogFil,"")
				EndIf
				aAdd(aLogFil,"")
			EndIf

		Else
			If nP == 0 .And. ( lCadVerb .Or. lCompVerb )
				aAdd(aLogFil,Space(6) + STR0035) //"Não existem inconsistências na filial"
				aAdd(aLogFil,"")
			EndIf
			aAdd(aLogFil,"")
		EndIf
	Next nX

	aAdd(aLogFil,STR0055) //"Inconsistências gerais: "
	aAdd(aLogFil,"")

	If lCadFun
		nP := 0

		oProcess:IncRegua2(STR0011) //"Cadastro de Funcionários"
		aAdd(aLogFil,Space(3) + STR0011) //"Cadastro de Funcionários"
		aAdd(aLogFil,"")
		FVldSraEmp(@aLogFil) //Valida se há registros com RA_FILIAL em branco

		If nP == 0
			aAdd(aLogFil,Space(6) + STR0056) //"Não existem inconsistências"
			aAdd(aLogFil,"")
		EndIf
		aAdd(aLogFil,"")
	EndIf

	If lVldCompar
		nP := 0

		fVldCompt(@aLogFil)

		If nP == 0
			aAdd(aLogFil,Space(6) + STR0056) //"Não existem inconsistências"
			aAdd(aLogFil,"")
		EndIf
	Endif

	If lVldCTT
		nP := 0

		fVldCTT(@aLogFil)

		If nP == 0
			aAdd(aLogFil,Space(6) + STR0056) //"Não existem inconsistências"
			aAdd(aLogFil,"")
		EndIf
	EndIf

	If lHstMov
		nP := 0
		aAdd(aLogFil,Space(3) + STR0009) //"Movimentos"
		aAdd(aLogFil,"")
		fVldMovVaz(@aLogFil) //Valida Dados em branco nos movimentos

		fVldFilMov(@aLogFil) //Valida se as filiais dos movimentos existem na tabela de empresas

		If nP == 0
			aAdd(aLogFil,Space(6) + STR0056) //"Não existem inconsistências"
			aAdd(aLogFil,"")
		EndIf
		aAdd(aLogFil,"")
	EndIf

	if lExibeGE
		nP := 0
		oProcess:IncRegua2(STR0087) //"Exibindo Gestão Empresarial"
		aAdd(aLogFil,Space(3) + STR0088) //"Formato da Gestão Empresarial"
		aAdd(aLogFil,"")

		fExibeGE(@aLogFil) //Exibe Gestão empresarial
	endif

	If lVldGrp
		aAdd(aLogFil, Space(3) + STR0094)//"Validação Grupo de Campos x SX3 x Tabelas"
		aAdd(aLogFil, "")
		fVldGrp(@aLogFil)
	EndIf

	if lModComp
		nP := 0
		oProcess:IncRegua2(STR0105) //"Modo de compartilhamento das tabelas do GPE"
		aAdd(aLogFil,Space(3) + STR0105) //"Modo de compartilhamento das tabelas do GPE"
		aAdd(aLogFil,"")

		fGrpGPE(@aLogFil) //Exibe o compartilhamento

	endif

	If lSRVComp
		If lCadVerb
			nP := 0
			oProcess:IncRegua2(STR0016) //"Cadastro de Verbas"
			aAdd(aLogFil,Space(3) + STR0016) //"Cadastro de Verbas"
			aAdd(aLogFil,"")
			fp_CodFol( @aCodFol , xFilial("SRV"), .F., .F. )
			fVldPdMS(@aLogFil) //Valida referência de férias em verbas do mês seguinte
			fVldPdIR(@aLogFil) //Valida configuração das verbas de IR pra DIRF
			fVldPdMMS(@aLogFil) //Valida configuração das verbas mês e mês seguinte

			If nP == 0
				aAdd(aLogFil,Space(6) + STR0056) //"Não existem inconsistências"
				aAdd(aLogFil,"")
			EndIf
			aAdd(aLogFil,"")
		EndIf

		If lCompVerb
			nP := 0
			oProcess:IncRegua2(STR0014) //"Comparação das incidências das verbas"
			aAdd(aLogFil,Space(3) + STR0014) //"Comparação das incidências das verbas"
			aAdd(aLogFil,Space(3) + STR0062) //"Observação: As divergências apresentadas são apenas uma sugestão para configuração de verbas, já que essa é de inteira responsabilidade do cliente."
			aAdd(aLogFil,"")
			fCompPd(@aLogFil) //Compara as verbas com cadastro padrão

			If nP == 0
				aAdd(aLogFil,Space(6) + STR0056) //"Não existem inconsistências"
				aAdd(aLogFil,"")
			EndIf
			aAdd(aLogFil,"")
		EndIf
	EndIf

	MsAguarde( { || fMakeLog( {aLogFil},{} , FunName() , NIL , FunName() , STR0018,,,,.F. ) } ,  STR0018 ) // "Log de Inconsistências de base"
Return

/*/{Protheus.doc} fVldSraEmp
Valida se há registros com RA_FILIAL, RA_MAT, RA_CC em branco
@author Fernando Quinteiro
@since 15/04/2019
@version 1.0
@return Nil
/*/
Static Function fVldSraEmp(aLogItens,cFil)
	Local cAliasQry  := GetNextAlias()

	Local aLogSRAMat := {} //funcionários com matrícula em branco
	Local aLogSRACC  := {} //funcionários com CC em branco
	Local aLogSRAFI  := {} //funcionários com filial inválida
	Local aLogSRAFE  := {} //funcionários com filial em branco
	Local aSRAFI := {}
	Local nX         := 0

	Default aLogItens:= {}
	Default cFil     := Space(FWGETTAMFILIAL)

	If !Empty(cFil)

		BeginSql Alias cAliasQry
			SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_CIC, RA_CC
				FROM %table:SRA% SRA
			WHERE
				SRA.%NotDel% AND
				RA_FILIAL = %Exp:cFil% AND
				(RA_MAT = '' OR RA_CC = '')
			ORDER BY 1, 2
		EndSql

		While !(cAliasQry)->(Eof())
			nP++

			If Empty((cAliasQry)->RA_MAT)
				aAdd( aLogSRAMat, Space(9) + PadR((cAliasQry)->RA_FILIAL,12) + PadR((cAliasQry)->RA_NOME,30))
			Endif

			If Empty((cAliasQry)->RA_CC)
				aAdd( aLogSRACC,  Space(9) + PadR((cAliasQry)->RA_MAT,12) + If(lOfusca, Replicate('*',30), PadR((cAliasQry)->RA_NOME,30)))
			Endif

			(cAliasQry)->( DbSkip())
		EndDo

		If Len(aLogSRAMat ) > 0 .And. !lOfusca
			aAdd(aLogItens,Space(6) + STR0074 ) //"Funcionários com o campo RA_MAT vazios"
			aAdd(aLogItens,"")
			aAdd( aLogItens,Space(9) + STR0068 + Space(6) + STR0029) //"Filial + Nome"
			For nX := 1 To Len(aLogSRAMat)
				aAdd( aLogItens, aLogSRAMat[nX] )
			Next nX
			aAdd(aLogItens,"")
		Endif

		If Len(aLogSRACC) > 0
			aAdd(aLogItens,Space(6) + STR0075 ) //"Funcionários com o campo RA_CC vazios"
			aAdd(aLogItens,"")
			aAdd( aLogItens,Space(9) + STR0028 + Space(3) + STR0029) //"Matrícula + Nome"
			For nX := 1 To Len(aLogSRACC)
				aAdd( aLogItens, aLogSRACC[nX] )
			Next nX
			aAdd(aLogItens,"")
		Endif

	Else

		BeginSql Alias cAliasQry
			SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_CIC, RA_CC
				FROM %table:SRA% SRA
			WHERE
				SRA.%NotDel%
			ORDER BY 1, 2
		EndSql

		While !(cAliasQry)->(Eof())

			if Empty((cAliasQry)->(RA_FILIAL))
				nP++
				aAdd( aLogSRAFE, Space(9) + PadR((cAliasQry)->RA_MAT,12) + If(lOfusca, Replicate('*',30), PadR((cAliasQry)->RA_NOME,30)))				
				(cAliasQry)->(DbSkip())
				loop
			endif

			if !FWFilExist(cEmpAnt,(cAliasQry)->RA_FILIAL)
				nP++
				nSRAFI := aScan(aSRAFI,{|x| x[1]==(cAliasQry)->RA_FILIAL})
				if nSRAFI == 0
					aAdd(aSRAFI,{(cAliasQry)->RA_FILIAL,1})
				else
					aSRAFI[nSRAFI,2]++
				endif
				
				
			endif
			(cAliasQry)->(DbSkip())
		EndDo

		If Len(aLogSRAFE) > 0
			aAdd(aLogItens,Space(6) + STR0076 ) //"Funcionários com o campo RA_FILIAL vazios"
			aAdd(aLogItens,"")

			For nX := 1 To Len(aLogSRAFE)
				aAdd( aLogItens, aLogSRAFE[nX] )
			Next nX
			aAdd(aLogItens,"")
		Endif

		If Len(aSRAFI) > 0
			aAdd(aLogItens,Space(6) + STR0085 ) //"Filiais inválidas na SRA"
			aAdd(aLogItens,"")

			For nX := 1 To Len(aSRAFI) 
				aAdd( aLogItens,Space(9) +  STR0068+": "+aSRAFI[nX][1]+ STR0082 +Alltrim(Str(aSRAFI[nX][2])) )
			Next nX
			aAdd(aLogItens,"")
		Endif

	Endif

	(cAliasQry)->(DbCloseArea())
Return

/*/{Protheus.doc} fVldSraCom
Valida compartilhametno da SRA
@author Fernando Quinteiro
@since 15/04/2019
@version 1.0
@return Nil
/*/
Static Function fVldSraCom(aLogItens,cFil)

	If (FWModeAccess( "SRA", 1) + FWModeAccess( "SRA", 2) + FWModeAccess( "SRA", 3)) <> "EEE"
		aAdd( aLogItens,Space(6) + STR0077 ) //"A tabela SRA está com compartilhamento diferente de exclusivo (EEE)"
	EndIf

Return

/*/{Protheus.doc} fVldCompt
Valida compartilhametno da SRA
@author Fernando Quinteiro
@since 15/04/2019
@version 1.0
@return Nil
/*/
Static Function fVldCompt(aLogItens)

	If (FWModeAccess( "SRC", 1) + FWModeAccess( "SRC", 2) + FWModeAccess( "SRC", 3)) <> "EEE"
		nP++
		aAdd( aLogItens,Space(3) + STR0078 ) //"A tabela SRC está com compartilhamento diferente de exclusivo (EEE)."
		aAdd( aLogItens, "" )
	EndIf

	If (FWModeAccess( "SRD", 1) + FWModeAccess( "SRD", 2) + FWModeAccess( "SRD", 3)) <> "EEE"
		nP++
		aAdd( aLogItens,Space(3) + STR0079 ) //"A tabela SRD está com compartilhamento diferente de exclusivo (EEE)."
		aAdd( aLogItens, "" )
	EndIf

Return

/*/{Protheus.doc} fVldCTT
Valida se os centros de custos existentes na SRC, SRD e SRA são validos na CTT
@author Leandro Drumond
@since 10/02/2022
@version 1.0
@return Nil
/*/
Static Function fVldCTT(aLogItens)
Local cAliasTmp := GetNextAlias()
Local cJoinSRD  := "%" + FWJoinFilial("CTT", "SRD") + "%"
Local cJoinSRC  := "%" + FWJoinFilial("CTT", "SRC") + "%"
Local cJoinSRA  := "%" + FWJoinFilial("CTT", "SRA") + "%"
Local cFilCCAnt := "##$$##$$##"
Local aLogTemp  := {}
Local nX        := 0

BeginSQL Alias cAliasTmp
	SELECT
		RA_FILIAL FILIAL, RA_CC CC, CTT_CUSTO CUSTO
	FROM
		%Table:SRA% SRA
		LEFT JOIN %Table:CTT% CTT ON CTT_CUSTO = RA_CC AND %Exp:cJoinSRA%
	WHERE
		SRA.%NotDel%
		AND CTT_CUSTO IS NULL

	UNION

	SELECT
		RC_FILIAL FILIAL, RC_CC CC, CTT_CUSTO CUSTO
	FROM
		%Table:SRC% SRC
		LEFT JOIN %Table:CTT% CTT ON CTT_CUSTO = RC_CC AND %Exp:cJoinSRC%
	WHERE
		SRC.%NotDel%
		AND CTT_CUSTO IS NULL

	UNION

	SELECT
		RD_FILIAL FILIAL, RD_CC CC, CTT_CUSTO CUSTO
	FROM
		%Table:SRD% SRD
		LEFT JOIN %Table:CTT% CTT ON CTT_CUSTO = RD_CC AND %Exp:cJoinSRD%
	WHERE
		SRD.%NotDel%
		AND CTT_CUSTO IS NULL

	ORDER BY
		FILIAL, CC
EndSQL

While (cAliasTmp)->(!Eof())
	If cFilCCAnt <> (cAliasTmp)->FILIAL + (cAliasTmp)->CC
		aAdd( aLogTemp,Space(9) + STR0119 + (cAliasTmp)->FILIAL + Space(6) + STR0120 + (cAliasTmp)->CC  )
	EndIf 
	cFilCCAnt := (cAliasTmp)->FILIAL + (cAliasTmp)->CC
	(cAliasTmp)->( DbSkip() )
EndDo

If Len(aLogTemp) > 0
	nP++
	aAdd( aLogItens,Space(6) + STR0118) //"Os centros de custo a seguir são referenciados no cadastro de funcionários ou tabels de movimento (SRC/SRD) mas não estão cadastrados: "
	aAdd( aLogItens,"")
	For nX := 1 To Len(aLogTemp)
		aAdd(aLogItens,aLogTemp[nX])
	Next nX
	aAdd( aLogItens,"")
EndIf

(cAliasTmp)->(DbCloseArea())

Return

/*/{Protheus.doc} fVldFilMov
	Valida se os movimentos estão com filiais que existem na sys_company
	@type  Static Function
	@author gustavo.hbaptista
	@since 10/01/2022
	/*/
Static Function fVldFilMov(aLogFil)

	Local aLogInvld := {}
	Local nX:= 0
	Local cAliasTmp  := GetNextAlias()
	Local cAliasTmp2 := GetNextAlias()
	Local aSRCFil 	 := {}
	Local nSRCFil    := 0
	Local aSRDFil 	 := {}
	Local nSRDFil	 := 0
	Local cWhere     := "% RD_PERIODO >= '" + cIniLcto + "' %"

	BeginSQL Alias cAliasTmp
		SELECT
			RD_FILIAL
		FROM
			%Table:SRD% SRD
		WHERE
			%Exp:cWhere% AND
			SRD.%NotDel% AND
			RD_FILIAL <> ''
			
	EndSQL

	BeginSQL Alias cAliasTmp2
		SELECT
			RC_FILIAL
		FROM
			%Table:SRC% SRC
		WHERE
			SRC.%NotDel% AND
			RC_FILIAL <> ''
	EndSQL

	DbSelectArea(cAliasTmp2)
	DbSelectArea(cAliasTmp)

	//Vamos varrer a SRC e verificar se alguma filial não existe na sys_company
	while (cAliasTmp2)->(!EOF())
		
		if !FWFilExist(cEmpAnt,(cAliasTmp2)->RC_FILIAL)
			nP++
			nSRCFil := aScan(aSRCFil,{|x| x[1]==(cAliasTmp2)->RC_FILIAL})
			if nSRCFil == 0
				aAdd(aSRCFil,{(cAliasTmp2)->RC_FILIAL,1})
			else
				aSRCFil[nSRCFil,2]++
			endif
		endif			

		(cAliasTmp2)->(dbSkip())
	endDo

	if !Empty(aSRCFil)
		aAdd(aLogFil,Space(6) + STR0083) //"Filiais inválidas na SRC"
		aAdd(aLogFil,"")
		For nX := 1 To Len(aSRCFil) 
			aAdd( aLogFil,Space(9) +  STR0068+": "+aSRCFil[nX][1]+ STR0082 +Alltrim(Str(aSRCFil[nX][2])) )
		Next nX
		aAdd(aLogFil,"")

	endif

	aLogInvld := {}

	while (cAliasTmp)->(!EOF())
		
		if !FWFilExist(cEmpAnt,(cAliasTmp)->RD_FILIAL)
			nP++
			nSRDFil := aScan(aSRDFil,{|x| x[1]==(cAliasTmp)->RD_FILIAL})
			if nSRDFil == 0
				aAdd(aSRDFil,{(cAliasTmp)->RD_FILIAL,1})
			else
				aSRDFil[nSRDFil,2]++
			endif
		endif	

		(cAliasTmp)->(dbSkip())
	endDo

	if !Empty(aSRDFil)
		aAdd(aLogFil,Space(6) + STR0084) //"Filiais inválidas na SRD"
		aAdd(aLogFil,"")
		For nX := 1 To Len(aSRDFil) 
			aAdd( aLogFil,Space(9) +  STR0068+": "+aSRDFil[nX][1]+ STR0082 +Alltrim(Str(aSRDFil[nX][2])) )
		Next nX
		aAdd(aLogFil,"")
	endif
 
Return

 /*/{Protheus.doc} fExibeGE
	(long_description)
	@type  static Function
	@author user
	@since 14/01/2022
	/*/
static Function fExibeGE(aLogFil)
	
	Local cLayout:= FWSM0Layout()

	Local nx := 0
	Local cFmtEmp:=""
	Local cFmtUnid:=""
	Local cFmtFili:=""

	if fIsCorpManage(cEmpAnt)
		aAdd(aLogFil,Space(6) + STR0090)
		aAdd(aLogFil,"")
	else
		aAdd(aLogFil,Space(6) + STR0089)
		aAdd(aLogFil,"")
	endif

	for nX:=1 to Len(Alltrim(cLayout))
		cStr:= SubStr(cLayout,nX,1)
		If cStr == 'E'
			cFmtEmp+= cStr
		elseif cStr == 'U'
			cFmtUnid+= cStr
		else
			cFmtFili+= cStr
		endif

	next
	
	if !Empty(cFmtEmp)
		aAdd(aLogFil,Space(6) + STR0091+cFmtEmp) //"Leiaute de Empresa:"
		aAdd(aLogFil,"")
	endIf
	if !Empty(cFmtUnid)
		aAdd(aLogFil,Space(6) + STR0092+cFmtUnid) //"Leiaute de Unidade:"
		aAdd(aLogFil,"")
	endIf
	if !Empty(cFmtFili)
		aAdd(aLogFil,Space(6) + STR0093+cFmtFili) //"Leiaute de Filial:"
		aAdd(aLogFil,"")
	endIf

	
Return

/*/{Protheus.doc} fVldPdMS
Verifica se existem verbas de férias mês seguinte que estão com campo RV_REFFER com "não"
@author Gabriel de Souza Almeida
@since 24/04/2017
@version 1.0
@return Nil
/*/
Static Function fVldPdMS(aLogItens,cFil)
	Local cAliasQry := GetNextAlias()

	Default aLogItens := {}
	Default cFil      := Space(FWGETTAMFILIAL)

	BeginSql Alias cAliasQry
		SELECT SRV1.RV_COD AS COD1, SRV1.RV_DESC AS DESC1, SRV2.RV_COD AS COD2, SRV2.RV_DESC AS DESC2
		FROM %table:SRV% SRV1
		INNER JOIN %table:SRV% SRV2
		ON SRV1.RV_FILIAL = SRV2.RV_FILIAL AND SRV2.RV_COD = SRV1.RV_CODMSEG
		WHERE SRV1.RV_CODMSEG <> '' AND SRV2.RV_REFFER = 'S' AND SRV1.RV_REFFER <> 'S' AND SRV1.%NotDel% AND SRV2.%NotDel% AND SRV1.RV_FILIAL = %Exp:xFilial("SRV",cFil)%
		ORDER BY SRV1.RV_COD
	EndSql

	If (cAliasQry)->( !Eof() )
		nP++
		Do While (cAliasQry)->( !Eof() )
			aAdd(aLogItens,Space(6) + STR0019) //"As seguintes verbas estão configuradas como 'Verba de Mês Seguinte' de verbas de férias porém a sua referência para férias (RV_REFFER) está como 'Não'"
			aAdd(aLogItens,"")
			aAdd(aLogItens,Space(9) + Padr(STR0020,TAMSX3("RV_COD")[1]+3+TAMSX3("RV_DESC")[1]+3) + Padr(STR0021,TAMSX3("RV_COD")[1]+3+TAMSX3("RV_DESC")[1]+3)) //"Verba Mês Seguinte" + "Verba Mês"
			aAdd(aLogItens,Space(9) + (cAliasQry)->(COD1 + " - " + DESC1 + Space(3) + COD2 + Space(3) + DESC2 ))

			(cAliasQry)->( DbSkip() )
		EndDo
		aAdd(aLogItens,"")
	EndIf

	(cAliasQry)->(DbCloseArea())
Return

/*/{Protheus.doc} lVerbFer
Valida se as verbas de férias estão gravadas na folha mantendo a data de pagamento original das férias
@author Fernando Quinteiro
@since 31/01/2019
@version 1.0
@return Nil
/*/
Function fVldVrbFer(aLogItens,cFil, aTitle, cAno)
	Local cAliasTemp  := GetNextAlias()
	Local cFilProc    := ""
	Local cAnoTemp    := ""
	Local lTemp       :=  ValType(aTitle) == "U"

	cFilProc := If(Empty(cFil),"%%", "%RH_FILIAL = '" + cFil  + "' AND%")
	cAnoTemp := If(Empty(cAno),"%%", "%SUBSTRING(RH_PERIODO, 1 , 4) = '" + cAno  + "' AND%")

	BeginSQL Alias cAliasTemp
		SELECT
			RH_FILIAL,RH_MAT, RH_PERIODO, RD_SEMANA, RH_DTRECIB, RR_DATAPAG, RD_DATPGT, RD_ROTEIR, RD_PD
		FROM
			%Table:SRH% SRH
			JOIN %Table:SRR% SRR ON RR_FILIAL = RH_FILIAL AND RR_MAT = RH_MAT AND RR_PERIODO = RH_PERIODO AND RR_SEMANA = RH_NPAGTO AND RR_DATA = RH_DATAINI 
			JOIN %Table:SRD% SRD ON RR_FILIAL = RD_FILIAL AND RR_MAT = RD_MAT AND RR_PD = RD_PD AND RR_PERIODO = RD_PERIODO AND RR_SEMANA = RD_SEMANA AND RR_DATAPAG = RD_DTREF
		WHERE
			%Exp:cFilProc%
			RD_TIPO2 = 'K' AND
			%Exp:cAnoTemp%
			RH_DTRECIB <> RD_DATPGT AND
			SRH.%NotDel% AND
			SRR.%NotDel% AND
			SRD.%NotDel%
		ORDER BY 1,2
	EndSQL

	If !(cAliasTemp)->(Eof())
		Iif(!Empty(cFil), nP++,)

		aAdd( (Iif(lTemp, aLogItens, aTitle)),Space(6) + STR0070 ) //"Inconsistências em datas de pagamentos de verbas entre data do cálculo de férias(SRH/SRR) e data de pagamento na folha (SRD)"
		aAdd( (Iif(lTemp, aLogItens, aTitle)), , "")
		aAdd( aLogItens, Space(9) + STR0068 + Space(4) + STR0028 + Space(2) + STR0047 + Space(2) + STR0069 + Space(2) + STR0050 + Space(3) + STR0071 + Space(5) + STR0072)
		While (cAliasTemp)->(!Eof())
			aAdd( aLogItens,Space(9) + AllTrim( (cAliasTemp)->RH_FILIAL ) + Space(3) +  AllTrim( (cAliasTemp)->RH_MAT ) + Space(6) + AllTrim( (cAliasTemp)->RH_PERIODO ) + Space(4) + AllTrim( (cAliasTemp)->RD_SEMANA ) + Space(4) + AllTrim( (cAliasTemp)->RD_PD ) + Space(5) +  DToC(SToD(AllTrim((cAliasTemp)->RH_DTRECIB)))   + Space(5) +  DToC(SToD(AllTrim((cAliasTemp)->RD_DATPGT))) )
			(cAliasTemp)->(DbSkip())
		EndDo
		aAdd(aLogItens,"")
	EndIf

	(cAliasTemp)->(DbCloseArea())


Return

/*/{Protheus.doc} fVldPdIR
Verifica se existem verbas com incidência para IR, mas sem configuração para DIRF
@author Gabriel de Souza Almeida
@since 24/04/2017
@version 1.0
@return Nil
/*/
Static Function fVldPdIR(aLogItens,cFil)
	Local cWhere    := "%"
	Local cAliasTmp := GetNextAlias()

	Default cFil    := Space(FWGETTAMFILIAL)

	cWhere += " SRV.RV_IR = 'S' "
	cWhere += " AND SRV.RV_DIRF IN ('N','I1','I','', ' ') "
	cWhere += " AND SRV.RV_FILIAL = '" + xFilial("SRV",cFil) + "' "
	cWhere += "%"

	BeginSQL Alias cAliasTmp
		SELECT RV_COD, RV_DESC, RV_IR, RV_DIRF
		FROM
		%Table:SRV% SRV
		WHERE %Exp:cWhere% AND
			SRV.%NotDel%
		ORDER BY RV_FILIAL, RV_COD
	EndSQL

	If !(cAliasTmp)->(Eof())
		nP++
		aAdd(aLogItens,Space(6) + STR0022 ) //"Verbas com incidência de IR mas sem configuração para DIRF."
		aAdd(aLogItens,"")
		While (cAliasTmp)->(!Eof())
			aAdd( aLogItens,Space(9) + PadR((cAliasTmp)->RV_COD,6) + PadR((cAliasTmp)->RV_DESC,21))
			(cAliasTmp)->(DbSkip())
		EndDo
		aAdd(aLogItens,"")
	EndIf

	(cAliasTmp)->(DbCloseArea())
Return

/*/{Protheus.doc} fVldPdMMS
Verifica se a configuração das verbas de férias mês e mês seguinte está de acordo com o "padrão"
@author Gabriel de Souza Almeida
@since 25/04/2017
@version 1.0
@return Nil
/*/
Static Function fVldPdMMS(aLogItens,cFil)
	Local cAliasQry := GetNextAlias()
	Local aPadIds   := {}
	Local nX        := 0
	Local nY        := 0
	Local aLogTemp  := {}
	Local cVerba    := ""

	Default aLogItens := {}
	Default cFil      := Space(FWGETTAMFILIAL)

	aAdd(aPadIds, {"0015","0106"}) //BASE IRRF
	aAdd(aPadIds, {"0043","0044"}) //ARREDONDAMENTO
	aAdd(aPadIds, {"0045","0046"}) //INSUFICIENCIA SALDO
	aAdd(aPadIds, {"0066","0107"}) //IRRF
	aAdd(aPadIds, {"0073","0072"}) //FERIAS
	aAdd(aPadIds, {"0076","0075"}) //MED. FERIAS VALOR
	aAdd(aPadIds, {"0078","0077"}) //1/3 SOBRE FERIAS
	aAdd(aPadIds, {"0081","0080"}) //D.S.R. MEDIA FERIAS
	aAdd(aPadIds, {"0083","0082"}) //MEDIA FERIAS HORAS
	aAdd(aPadIds, {"0085","0084"}) //OUTROS ADIC. FERIAS
	aAdd(aPadIds, {"0089","0088"}) //DIF. DE FERIAS
	aAdd(aPadIds, {"0091","0090"}) //DIFERENCA 1/3 FERIAS
	aAdd(aPadIds, {"0093","0092"}) //DIF. DSR DE FERIAS
	aAdd(aPadIds, {"0097","0096"}) //DIF. MEDIA HORAS FER
	aAdd(aPadIds, {"0099","0098"}) //DIF.OUT.ADIC.FERIAS
	aAdd(aPadIds, {"0162","0161"}) //DIF.CONV.COL.FER.
	aAdd(aPadIds, {"0205","0074"}) //ABONO PECUNIARIO
	aAdd(aPadIds, {"0206","0079"}) //1/3 SOBRE AB. PEC.
	aAdd(aPadIds, {"0207","0094"}) //DIF. ABONO PERCUNIAR
	aAdd(aPadIds, {"0208","0095"}) //DIF. 1/3 ABONO PECUN
	aAdd(aPadIds, {"0232","0065"}) //INSS FERIAS
	aAdd(aPadIds, {"0344","0343"}) //MED FER COM MES
	aAdd(aPadIds, {"0346","0345"}) //MEDIA FER TAREFEIRO
	aAdd(aPadIds, {"0633","0622"}) //MED. HOR. SOBRE ABONO
	aAdd(aPadIds, {"0634","0623"}) //MED. VAL. SOBRE ABONO
	aAdd(aPadIds, {"0637","0636"}) //MEDIA FER PROF
	aAdd(aPadIds, {"1297","1296"}) //ATS FERIAS MES
	aAdd(aPadIds, {"1299","1298"}) //ATS FERIAS MES S/VER
	aAdd(aPadIds, {"1301","1300"}) //PERICUL. FERIAS MES
	aAdd(aPadIds, {"1303","1302"}) //PERIC. FER. MES S/VE
	aAdd(aPadIds, {"1305","1304"}) //INSALUBRIDADE FERIAS
	aAdd(aPadIds, {"1307","1306"}) //INSAL. FER. MES. S/V
	aAdd(aPadIds, {"1309","1308"}) //ADIC. CRG. CONF. FER
	aAdd(aPadIds, {"1311","1310"}) //ADIC. TRANS. FER.MES
	aAdd(aPadIds, {"1313","1312"}) //ATS ABONO MES
	aAdd(aPadIds, {"1315","1314"}) //ATS ABONO MES S/ VER
	aAdd(aPadIds, {"1317","1316"}) //PERICULOSIDADE ABONO
	aAdd(aPadIds, {"1319","1318"}) //PERICULOSIDADE ABONO S/ VERBAS
	aAdd(aPadIds, {"1321","1320"}) //INSALUBRIDADE ABONO
	aAdd(aPadIds, {"1323","1322"}) //INSALUBRIDADE ABONO S/ VERBAS
	aAdd(aPadIds, {"1325","1324"}) //ADIC. CARGO CONFIANC
	aAdd(aPadIds, {"1327","1326"}) //ADIC. TRANSFERENCIA
	aAdd(aPadIds, {"1331","1330"}) //DSR SOBRE MEDIAS ABONO

	cWhere := " RV_CODFOL IN ("

	For nX := 1 To Len(aPadIds)
		cWhere += "'" + aPadIds[nX,1] + "',"
	Next nX

	cWhere += "'xxxx') "

	cWhere := "%" + cWhere + "%"

	BeginSQL Alias cAliasQry
		SELECT
			RV_CODFOL, RV_COD, RV_DESC, RV_CODMSEG
		FROM
			%Table:SRV% SRV
		WHERE
			%Exp:cWhere% AND SRV.%NotDel%
		ORDER BY 1
	EndSQL

	For nX := 1 To Len(aPadIds)
		If (cAliasQry)->( !Eof() )
			If (cAliasQry)->RV_CODFOL == aPadIds[nX,1]
				cVerba := aCodFol[Val(aPadIds[nX,2]),1]
				If (cAliasQry)->RV_CODMSEG <> cVerba
					aAdd(aLogTemp,Space(9) + (cAliasQry)->(RV_COD + " - " + RV_DESC + Space(3) + STR0033 + cVerba + STR0034 + aPadIds[nX,2] )) //"No campo RV_CODMSEG (Verba mês seguinte) deveria estar a verba X que possui o ID Y"
					nY++
				EndIf
				(cAliasQry)->( DbSkip() )
			Else
				Loop
			EndIf
		EndIf
	Next nX

	If nY > 0
		nP++

		aAdd(aLogItens,Space(6) + STR0023) //"As verbas a seguir não estão configuradas de acordo com o padrão sugerido para verbas mês e mês seguinte: "
		aAdd(aLogItens,"")
		aAdd(aLogItens,Space(9) + Padr(STR0020,TAMSX3("RV_COD")[1]+3+TAMSX3("RV_DESC")[1]+3) + STR0037) //"Verba Mês Seguinte" + "Inconsistência"

		For nX := 1 To Len(aLogTemp)
			aAdd(aLogItens,aLogTemp[nX])
		Next nX
		aAdd(aLogItens,"")
	EndIf

	(cAliasQry)->(DbCloseArea())
Return

/*/{Protheus.doc} fVldFunDem
Verifica se existem funcionários com a situação "D" e sem data de demissão ou com o campo RESCRAI em branco
@author Gabriel de Souza Almeida
@since 25/04/2017
@version 1.0
@return Nil
/*/
Static Function fVldFunDem(aLogItens,cFil)
	Local cAliasTmp  := GetNextAlias()
	Local cAliasTmp2 := GetNextAlias()

	BeginSQL Alias cAliasTmp
		SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_SITFOLH, RA_DEMISSA, RA_RESCRAI
		FROM
			%Table:SRA% SRA
		WHERE
			SRA.%NotDel% AND RA_SITFOLH = 'D' AND RA_DEMISSA = '' AND RA_FILIAL = %Exp:cFil%
		ORDER BY 1
	EndSQL

	If !(cAliasTmp)->(Eof())
		nP++
		aAdd( aLogItens,Space(6) + STR0032 ) //"Os funcionários a seguir estão com a situação 'D' (Demitidos) no cadastro de funcionários, porém estão com a data de demissão em branco: "
		aAdd( aLogItens,"")
		aAdd( aLogItens,Space(9) + STR0028 + Space(3) + STR0029) //"Matrícula + Nome"
		While (cAliasTmp)->(!Eof())
			aAdd( aLogItens,Space(9) + PadR((cAliasTmp)->RA_MAT,12) + If(lOfusca, Replicate('*',30), PadR((cAliasTmp)->RA_NOME,30)))
			(cAliasTmp)->(DbSkip())
		EndDo
	EndIf

	(cAliasTmp)->(DbCloseArea())

	BeginSQL Alias cAliasTmp2
		SELECT RA_FILIAL, RA_MAT, RA_NOME, RA_SITFOLH, RA_DEMISSA, RA_RESCRAI
		FROM
			%Table:SRA% SRA
		WHERE
			SRA.%NotDel%
			AND RA_SITFOLH = 'D'
			AND RA_RESCRAI = ''
			AND RA_CATFUNC NOT IN ('E','A','G')
			AND RA_FILIAL = %Exp:cFil%
		ORDER BY 1
	EndSQL

	If !(cAliasTmp2)->(Eof())
		nP++
		aAdd( aLogItens,"")
		aAdd( aLogItens,Space(6) + STR0031 ) //"Os funcionários a seguir estão com a situação 'D' (Demitidos) no cadastro de funcionários, porém estão com o campo RA_RESCRAI em branco: "
		aAdd( aLogItens,"")
		aAdd( aLogItens,Space(9) + STR0028 + Space(3) + STR0029) //"Matrícula + Nome"
		While (cAliasTmp2)->(!Eof())
			aAdd( aLogItens,Space(9) + PadR((cAliasTmp2)->RA_MAT,12) + If(lOfusca, Replicate('*',30), PadR((cAliasTmp2)->RA_NOME,30)))
			(cAliasTmp2)->(DbSkip())
		EndDo
		aAdd(aLogItens,"")
	EndIf

	(cAliasTmp2)->(DbCloseArea())
Return

/*/{Protheus.doc} fVldFunSR7
Verifica se existem funcionários com o salário diferente do último registro da SR7
@author Gabriel de Souza Almeida
@since 25/04/2017
@version 1.0
@return Nil
/*/
Static Function fVldFunSR7(aLogItens,cFil)
	Local cAliasTmp  := GetNextAlias()

	BeginSQL Alias cAliasTmp
		SELECT
			RA_FILIAL, RA_MAT, RA_NOME, RA_SITFOLH, RA_SALARIO, R3_VALOR, R7_DATA, R3_DATA, R3_TIPO, R7_TIPO
		FROM
			%Table:SRA% SRA
			JOIN %Table:SR7% SR7 ON R7_MAT = RA_MAT AND R7_FILIAL = RA_FILIAL
			JOIN %Table:SR3% SR3 ON R3_MAT = RA_MAT AND R3_FILIAL = RA_FILIAL AND R7_TIPO = R3_TIPO AND R7_DATA = R3_DATA AND R7_SEQ = R3_SEQ
			JOIN
				(SELECT R7_FILIAL AS FILIAL, R7_MAT AS MAT, MAX(R7_DATA) AS DATA, MAX(R7_SEQ) AS SEQ
				 FROM
					%Table:SR7% SR7
					JOIN %Table:SR3% SR3 ON R7_FILIAL = R3_FILIAL AND R3_MAT = R7_MAT AND R3_DATA = R7_DATA AND R3_TIPO = R7_TIPO AND R3_SEQ = R7_SEQ
				 WHERE
					 SR3.%NotDel% AND SR7.%NotDel%
				 GROUP BY R7_FILIAL, R7_MAT) TMP ON TMP.FILIAL = RA_FILIAL AND TMP.MAT = R7_MAT AND TMP.DATA = R7_DATA AND TMP.SEQ = R7_SEQ
		WHERE
			SR3.R3_VALOR <> RA_SALARIO
			AND SRA.RA_FILIAL = %Exp:cFil%
			AND SR3.%NotDel%
			AND SRA.%NotDel%
			AND SR7.%NotDel%
		ORDER BY 1,2
	EndSQL

	If !(cAliasTmp)->(Eof())
		nP++
		aAdd( aLogItens,Space(6) + STR0030 ) //"Os funcionários a seguir estão com o salário da SRA diferente do salário do último registro do histórico salarial: "
		aAdd( aLogItens,"")
		aAdd( aLogItens,Space(9) + STR0028 + Space(3) + STR0029) //"Matrícula + Nome"
		While (cAliasTmp)->(!Eof())
			aAdd( aLogItens,Space(9) + PadR((cAliasTmp)->RA_MAT,12) + If(lOfusca, Replicate('*',30), PadR((cAliasTmp)->RA_NOME,30)))
			(cAliasTmp)->(DbSkip())
		EndDo
		aAdd(aLogItens,"")
	EndIf

	(cAliasTmp)->(DbCloseArea())
Return

/*/{Protheus.doc} fVldFunSRE
Verifica se os dados da SRA estão de acordo com a última transferência do funcionário
@author Gabriel de Souza Almeida
@since 26/04/2017
@version 1.0
@return Nil
/*/
Static Function fVldFunSRE(aLogItens,cFil)
	Local aTransf    := {}
	Local nUltPos    := 0
	Local lFil       := .F.
	Local lMat       := .F.
	Local lCC        := .F.
	Local lProc      := .F.
	Local lDpto      := .F.
	Local lPosto     := .F.
	Local lItem      := .F.
	Local lClasse    := .F.
	Local lInconsist := .F.

	DbSelectArea("SRA")
	DbSetOrder(1)

	If SRA->( DbSeek(cFil) )
		While !SRA->(Eof()) .And. alltrim(SRA->RA_FILIAL) == Alltrim(cFil)

			If SRA->RA_SITFOLH == 'D'
				SRA->(DbSkip())
				Loop
			EndIf

			fTransf(@aTransf)

			If ( nUltPos := Len(aTransf) ) > 0
				lFil       := AllTrim(aTransf[nUltPos,10]) <> AllTrim(SRA->RA_FILIAL)
				lMat       := AllTrim(aTransf[nUltPos,11]) <> AllTrim(SRA->RA_MAT)
				lCC        := AllTrim(aTransf[nUltPos,06]) <> AllTrim(SRA->RA_CC)
				lProc      := AllTrim(aTransf[nUltPos,15]) <> AllTrim(SRA->RA_PROCES)
				lDpto      := AllTrim(aTransf[nUltPos,17]) <> AllTrim(SRA->RA_DEPTO)
				lPosto     := AllTrim(aTransf[nUltPos,19]) <> AllTrim(SRA->RA_POSTO)
				lItem      := AllTrim(aTransf[nUltPos,21]) <> AllTrim(SRA->RA_ITEM)
				lClasse    := AllTrim(aTransf[nUltPos,23]) <> AllTrim(SRA->RA_CLVL)
				lInconsist := lFil .Or. lMat .Or. lCC .Or. lProc .Or. lDpto .Or. lPosto .Or. lItem .Or. lClasse

				If lInconsist
					aAdd( aLogItens,Space(6) + STR0026 + AllTrim(SRA->RA_MAT) + " - " + If(lOfusca, Replicate('*',30), AllTrim(SRA->RA_NOME)) + STR0027 ) //"O funcionário X possui divergência(s) em seu cadastro de acordo com a última transferência realizada: "
				EndIf

				If lFil
					aAdd( aLogItens,Space(9) + STR0024 +  "RA_FILIAL" + STR0025) //"Campo RA_FILIAL não está de acordo com a última transferência"
				EndIf

				If lMat
					aAdd( aLogItens,Space(9) + STR0024 + "RA_MAT" + STR0025) //"Campo RA_MAT não está de acordo com a última transferência"
				EndIf

				If lCC
					aAdd( aLogItens,Space(9) + STR0024 + "RA_CC" + STR0025) //"Campo RA_CC não está de acordo com a última transferência"
				EndIf

				If lProc
					aAdd( aLogItens,Space(9) + STR0024 + "RA_PROCES" + STR0025) //"Campo RA_PROCES não está de acordo com a última transferência"
				EndIf

				If lDpto
					aAdd( aLogItens,Space(9) + STR0024 + "RA_DEPTO" + STR0025) //"Campo RA_DEPTO não está de acordo com a última transferência"
				EndIf

				If lPosto
					aAdd( aLogItens,Space(9) + STR0024 + "RA_POSTO" + STR0025) //"Campo RA_POSTO não está de acordo com a última transferência"
				EndIf

				If lItem
					aAdd( aLogItens,Space(9) + STR0024 + "RA_ITEM" + STR0025) //"Campo RA_ITEM não está de acordo com a última transferência"
				EndIf

				If lClasse
					aAdd( aLogItens,Space(9) + STR0024 +  "RA_CLVL" + STR0025) //"Campo RA_CLVL não está de acordo com a última transferência"
				EndIf

				If lInconsist
					nP++
					aAdd( aLogItens,"")
				EndIf
			EndIf

			SRA->( DbSkip() )
			aTransf := {}
		EndDo
	EndIf

	SRA->( DbCloseArea() )
Return

/*/{Protheus.doc} fVldProv
Verifica se existem meses anteriores ao da folha em aberto, sem provisão calculada
@author Gabriel de Souza Almeida
@since 26/04/2017
@version 1.0
@return Nil
/*/
Static Function fVldProv(aLogItens,cFil)
	Local cPer      := ""
	Local cSem      := ""
	Local cProc     := ""
	Local cRot      := fGetCalcRot('1')
	Local aProcPer  := {}
	Local nPosProc  := 0
	Local dDataCal  := SToD("")
	Local nX        := 0
	Local aLogTemp  := {}
	Local nDiasTrab := 0
	Local cDiasPer  := GetMvRH("MV_DIASPER",,"1")

	DbSelectArea("RCJ")
	DbSetOrder(1) //Filial + Processo

	If 	RCJ->( DbSeek( xFilial("RCJ",cFil) ) )
		While !RCJ->( Eof() ) .And. RCJ->RCJ_FILIAL == xFilial("RCJ", cFil)
			If fGetLastPer( @cPer, @cSem, RCJ->RCJ_CODIGO, cRot,,,, xFilial("RCH",cFil) ) .Or. fGetLastPer( @cPer, @cSem, RCJ->RCJ_CODIGO, fGetCalcRot('9'),,,, xFilial("RCH",cFil) )
				aAdd( aProcPer,{RCJ->RCJ_CODIGO,cPer})
			EndIf
			RCJ->( DbSkip() )
		EndDo
	EndIf

	RCJ->( DbCloseArea() )

	DbSelectArea("SRA")
	DbSetOrder(1)

	If SRA->( DbSeek(cFil) )
		DbSelectArea("SRT")
		SRT->( DbSetOrder(5) ) //Filial + Mat + DataCal

		While !SRA->( Eof() ) .And. Alltrim(SRA->RA_FILIAL) == Alltrim(cFil)

		If ( nPosProc := aScan(aProcPer, {|X| X[1] == SRA->RA_PROCES }) ) > 0
				cPer      := aProcPer[nPosProc,2]
				dDataCal  := SToD(cPer + "01") - 1
				nDiasTrab := ( IIf( cDiasPer == "1",f_UltDia(SRA->RA_ADMISSA),30 ) - 15 ) - 1 //Verifica se trabalhou 15 dias no mês
				For nX := 1 To 3
					If (Empty(SRA->RA_DEMISSA) .OR. SRA->RA_DEMISSA > dDataCal) .And. ( ( SRA->RA_ADMISSA + nDiasTrab ) <= dDataCal ) .And.  !SRT->( DbSeek( SRA->( RA_FILIAL + RA_MAT ) + DToS(dDataCal) ) )
						aAdd( aLogTemp,Space(9) + PadR(SRA->RA_MAT,12) + If(lOfusca, Replicate('*',30), PadR(SRA->RA_NOME,30)))
						Exit
					EndIf

					dDataCal := dDataCal - f_UltDia(dDataCal)
				Next nX
			EndIf
			SRA->( DbSkip() )
		EndDo

		SRT->( DbCloseArea() )

		If Len(aLogTemp) > 0
			nP++
			aAdd( aLogItens,Space(6) + STR0038 ) //"Os funcionários a seguir não possuem cálculo de provisão em pelo menos um dos últimos três meses: "
			aAdd( aLogItens,"")
			aAdd( aLogItens,Space(9) + STR0028 + Space(3) + STR0029) //"Matrícula + Nome"

			For nX := 1 To Len(aLogTemp)
				aAdd(aLogItens,aLogTemp[nX])
			Next nX
			aAdd( aLogItens,"")
		EndIf
	EndIf

	SRA->( DbCloseArea() )

Return

/*/{Protheus.doc} fVldDiaDir
Verifica se os dias de direito do funcionário estão de acordo com os registros de férias
@author Gabriel de Souza Almeida
@since 26/04/2017
@version 1.0
@return Nil
/*/
Static Function fVldDiaDir(aLogItens,cFil)
	Local cAliasTmp := GetNextAlias()
	Local aLogTemp  := {}
	Local nX        := 0
	Local cDataBas  := ""

	BeginSQL Alias cAliasTmp
		SELECT
			RA_FILIAL, RA_MAT, RA_NOME, RH_DATABAS, SUM(RH_DFERIAS) DIASFERIAS, SUM(RH_DABONPE) DIASABON, SUM(RG_DFERVEN) DIASRES
		FROM
			%Table:SRA% SRA
			JOIN %Table:SRH% SRH ON RH_FILIAL = RA_FILIAL AND RH_MAT = RA_MAT
			JOIN %Table:SRF% SRF ON RF_FILIAL = RA_FILIAL AND RF_MAT = RA_MAT AND RF_DATABAS = RH_DATABAS
			LEFT JOIN %Table:SRR% SRR ON RR_FILIAL = RA_FILIAL AND RR_MAT = RA_MAT AND RR_PD = %Exp:fGetCodFOL("0086",,xFilial("SRV",cFil))% AND SUBSTRING(RR_NUMID,1,8) = RF_DATABAS
			LEFT JOIN %Table:SRG% SRG ON RG_FILIAL = RA_FILIAL AND RG_MAT = RA_MAT AND RR_DATA = RG_DTGERAR
		WHERE
			SRA.%NotDel%
			AND SRH.%NotDel%
			AND SRF.%NotDel%
			AND ( SRR.%NotDel% OR SRR.D_E_L_E_T_ IS NULL )
			AND ( SRG.%NotDel% OR SRG.D_E_L_E_T_ IS NULL )
			AND RA_FILIAL = %Exp:cFil%
		GROUP BY
			RA_FILIAL, RA_MAT, RA_NOME, RH_DATABAS
	EndSQL

	DbSelectArea("SRF")
	DbSetOrder(1) //Filial + Mat + Data Base

	While (cAliasTmp)->(!Eof())
		If SRF->( DbSeek( (cAliasTmp)->(RA_FILIAL + RA_MAT + RH_DATABAS) ) )
			If (cAliasTmp)->DIASFERIAS + (cAliasTmp)->DIASABON + IIf( ValType( (cAliasTmp)->DIASRES ) == "N" ,(cAliasTmp)->DIASRES,0 ) < SRF->RF_DFERANT
				cDataBas := SubStr( (cAliasTmp)->RH_DATABAS,7,2 ) + "/" + SubStr( (cAliasTmp)->RH_DATABAS,5,2 ) + "/" + SubStr( (cAliasTmp)->RH_DATABAS,1,4 )
				aAdd( aLogTemp,Space(6) + STR0026 + AllTrim( (cAliasTmp)->RA_MAT ) + " - " + If(lOfusca, Replicate('*',30), AllTrim( (cAliasTmp)->RA_NOME) ) + STR0039 + cDataBas ) //O funcionário X possui menos dias pagos de férias do que está registrado no controle de dias de direito (SRF) para a data base
			ElseIf (cAliasTmp)->DIASFERIAS + (cAliasTmp)->DIASABON + IIf( ValType( (cAliasTmp)->DIASRES ) == "N" ,(cAliasTmp)->DIASRES,0 ) > SRF->RF_DFERANT
				cDataBas := SubStr( (cAliasTmp)->RH_DATABAS,7,2 ) + "/" + SubStr( (cAliasTmp)->RH_DATABAS,5,2 ) + "/" + SubStr( (cAliasTmp)->RH_DATABAS,1,4 )
				aAdd( aLogTemp,Space(6) + STR0026 + AllTrim( (cAliasTmp)->RA_MAT ) + " - " + If(lOfusca, Replicate('*',30), AllTrim( (cAliasTmp)->RA_NOME) ) + STR0040 + cDataBas ) //O funcionário X possui mais dias pagos de férias do que está registrado no controle de dias de direito (SRF) para a data base
			EndIf
		EndIf
		(cAliasTmp)->(DbSkip())
	EndDo

	SRF->(DbCloseArea())

	If Len(aLogTemp) > 0
		nP++
		For nX := 1 To Len(aLogTemp)
			aAdd(aLogItens,aLogTemp[nX])
		Next nX
		aAdd( aLogItens,"")
	EndIf

	(cAliasTmp)->(DbCloseArea())
Return

/*/{Protheus.doc} fVldMovVaz
Valida registro com os campos chave em branco na SRC e SRD
@author Gabriel de Souza Almeida
@since 26/04/2017
@version 1.0
@return Nil
/*/
Static Function fVldMovVaz(aLogItens)
	Local cAliasTmp  := GetNextAlias()
	Local cAliasTmp2 := GetNextAlias()
	Local nSRC       := 0
	Local nSRD       := 0
	Local cWhere     := "% RD_PERIODO >= '" + cIniLcto + "' %"

	BeginSQL Alias cAliasTmp
		SELECT
			RD_FILIAL AS FIL, RD_MAT AS MAT, RD_PD AS PD, RD_PERIODO AS PER, RD_ROTEIR AS ROT, RD_PROCES AS PROCES, RD_SEMANA AS SEM, RD_CC AS CC, R_E_C_N_O_ AS REC
		FROM
			%Table:SRD% SRD
		WHERE
			%Exp:cWhere% AND
			SRD.%NotDel% AND
			(RD_FILIAL = ''
			OR RD_MAT = ''
			OR RD_PD = ''
			OR RD_PERIODO = ''
			OR RD_ROTEIR = ''
			OR RD_PROCES = ''
			OR RD_SEMANA = ''
			OR RD_CC = '')
	EndSQL

	BeginSQL Alias cAliasTmp2
		SELECT
			RC_FILIAL AS FIL, RC_MAT AS MAT, RC_PD AS PD, RC_PERIODO AS PER, RC_ROTEIR AS ROT, RC_PROCES AS PROCES, RC_SEMANA AS SEM, RC_CC AS CC, R_E_C_N_O_ AS REC
		FROM
			%Table:SRC% SRC
		WHERE
			SRC.%NotDel% AND
			(RC_FILIAL = ''
			OR RC_MAT = ''
			OR RC_PD = ''
			OR RC_PERIODO = ''
			OR RC_ROTEIR = ''
			OR RC_PROCES = ''
			OR RC_SEMANA = ''
			OR RC_CC = '')
	EndSQL

	DbSelectArea(cAliasTmp2)
	Count To nSRC
	DbSelectArea(cAliasTmp)
	Count To nSRD

	If nSRC > 0 .Or. nSRD > 0
		nP++
		aAdd( aLogItens,Space(6) + STR0041) //"Validação de registros em branco - Campos considerados na validação: Filial, Matrícula, Código da verba, Período do cálculo, Roteiro calculado, Processo, Nro. Pagamento e Centro de Custo."
		aAdd( aLogItens,"")

		If nSRC > 0
			aAdd( aLogItens,Space(9) + STR0042 + AllTrim( Str(nSRC) ) + STR0043 ) //"Existe(m) x registro(s) na tabela SRC com pelo menos um dos campos citados acima em branco. Seguem os recnos: "
			(cAliasTmp2)->( DbGoTop() )
			While (cAliasTmp2)->( !EOF() )
				aAdd( aLogItens,Space(9) + "- " + AllTrim( Str( (cAliasTmp2)->REC ) ) )
				(cAliasTmp2)->( DbSkip() )
			EndDo
		EndIf

		If nSRD > 0
			aAdd( aLogItens,Space(9) + STR0042 + AllTrim( Str(nSRD) ) + STR0044 ) //"Existe(m) x registro(s) na tabela SRC com pelo menos um dos campos citados acima em branco. Seguem os recnos: "
			(cAliasTmp)->( DbGoTop() )
			While (cAliasTmp)->( !EOF() )
				aAdd( aLogItens,Space(9) + "- " + AllTrim( Str( (cAliasTmp)->REC ) ) )
				(cAliasTmp)->( DbSkip() )
			EndDo
		EndIf

		aAdd( aLogItens,"")
	EndIf

	(cAliasTmp)->(DbCloseArea())
	(cAliasTmp2)->(DbCloseArea())
Return

/*/{Protheus.doc} fVldIDSRD
Valida a existência do ID 0318 na SRD e na SRC
@author Gabriel de Souza Almeida
@since 27/04/2017
@version 1.0
@return Nil
/*/
Static Function fVldIDSRD(aLogItens, cFil)
	Local cAliasTmp := GetNextAlias()
	Local cJoinSRD  := "%" + FWJoinFilial("SRV", "SRD") + "%"
	Local cJoinSRC  := "%" + FWJoinFilial("SRV", "SRC") + "%"
	Local cWhere    := "% RD_PERIODO >= '" + cIniLcto + "' %"
	Local aLogTemp  := {}
	Local nX        := 0

	cJoinSRD := Replace(cJoinSRD,"SRD", "SRD2")
	cJoinSRC := Replace(cJoinSRC,"SRC", "SRC2")

	BeginSQL Alias cAliasTmp
		SELECT
			RD_FILIAL FILIAL, RD_MAT MAT, RA_NOME NOME, RA_CATFUNC CAT, RD_PROCES PROCES, RD_PERIODO PER, RD_ROTEIR ROT, RD_SEMANA SEM
			,(
			  SELECT COUNT(*)
			  FROM %Table:SRD% SRD2
			    JOIN %Table:SRV% SRV ON SRD2.RD_PD = SRV.RV_COD AND %Exp:cJoinSRD%
			  WHERE
	  			%Exp:cWhere% AND
				SRD2.RD_FILIAL = SRD1.RD_FILIAL AND SRD2.RD_MAT = SRD1.RD_MAT AND SRD2.RD_PROCES = SRD1.RD_PROCES
				AND SRD2.RD_PERIODO = SRD1.RD_PERIODO AND SRD2.RD_ROTEIR = SRD1.RD_ROTEIR AND SRD2.RD_SEMANA = SRD1.RD_SEMANA
				AND SRV.RV_CODFOL = '0318'
				AND SRD2.%NotDel%
				AND SRV.%NotDel%
			  )QTD
		FROM
			%Table:SRD% SRD1
			JOIN %Table:SRA% SRA ON SRA.RA_FILIAL = SRD1.RD_FILIAL AND SRA.RA_MAT = SRD1.RD_MAT
		WHERE
  			%Exp:cWhere% AND
			SRD1.%NotDel%
			AND SRA.%NotDel%
			AND SRD1.RD_FILIAL <> ''
			AND SRD1.RD_MAT <> ''
			AND SRD1.RD_PROCES <> ''
			AND SRD1.RD_PERIODO <> ''
			AND SRD1.RD_SEMANA <> ''
			AND SRD1.RD_ROTEIR = %Exp:fGetCalcRot('1')% //FOL
			AND SRA.RA_CATFUNC NOT IN ('A','P','J','C','T')
			AND SRD1.RD_FILIAL = %Exp:cFil%

		UNION

		SELECT
			RC_FILIAL FILIAL, RC_MAT MAT, RA_NOME NOME, RA_CATFUNC CAT, RC_PROCES PROCES, RC_PERIODO PER, RC_ROTEIR ROT, RC_SEMANA SEM
			,(
			  SELECT COUNT(*)
			  FROM %Table:SRC% SRC2
			    JOIN %Table:SRV% SRV ON SRC2.RC_PD = SRV.RV_COD AND %Exp:cJoinSRC%
			  WHERE
				SRC2.RC_FILIAL = SRC1.RC_FILIAL AND SRC2.RC_MAT = SRC1.RC_MAT AND SRC2.RC_PROCES = SRC1.RC_PROCES
				AND SRC2.RC_PERIODO = SRC1.RC_PERIODO AND SRC2.RC_ROTEIR = SRC1.RC_ROTEIR AND SRC2.RC_SEMANA = SRC1.RC_SEMANA
				AND SRV.RV_CODFOL = '0318'
				AND SRC2.%NotDel%
				AND SRV.%NotDel%
			  )QTD
		FROM
			%Table:SRC% SRC1
			JOIN %Table:SRA% SRA ON SRA.RA_FILIAL = SRC1.RC_FILIAL AND SRA.RA_MAT = SRC1.RC_MAT
		WHERE
			SRC1.%NotDel%
			AND SRA.%NotDel%
			AND SRC1.RC_FILIAL <> ''
			AND SRC1.RC_MAT <> ''
			AND SRC1.RC_PROCES <> ''
			AND SRC1.RC_PERIODO <> ''
			AND SRC1.RC_SEMANA <> ''
			AND SRC1.RC_ROTEIR = %Exp:fGetCalcRot('1')% //FOL
			AND SRA.RA_CATFUNC NOT IN ('A','P','J','C','T')
			AND SRC1.RC_FILIAL = %Exp:cFil%
		GROUP BY RC_FILIAL, RC_MAT, RC_PROCES, RC_PERIODO, RC_ROTEIR, RC_SEMANA, RA_NOME, RA_CATFUNC
		ORDER BY QTD, FILIAL, MAT, PROCES, PER, SEM
	EndSQL

	While (cAliasTmp)->(!Eof()) .And. (cAliasTmp)->QTD == 0
		nP++
		aAdd( aLogTemp,Space(9) + STR0046 + (cAliasTmp)->MAT + " - " + If(lOfusca, Replicate('*',30), (cAliasTmp)->NOME) + STR0047 + (cAliasTmp)->PER + STR0048 + (cAliasTmp)->SEM ) //"Funcionário" " Período " " Nro. Pagamento "
		(cAliasTmp)->( DbSkip() )
	EndDo

	If Len(aLogTemp) > 0
		aAdd( aLogItens,Space(6) + STR0045) //"O(s) cálculo(s) que segue(m) não possuem a verba de salário base (ID 0318): "
		aAdd( aLogItens,"")
		For nX := 1 To Len(aLogTemp)
			aAdd(aLogItens,aLogTemp[nX])
		Next nX
		aAdd( aLogItens,"")
	EndIf

	(cAliasTmp)->(DbCloseArea())
Return

/*/{Protheus.doc} fVldHstSRV
Valida os tipos de verba na SRC e na SRD
@author Gabriel de Souza Almeida
@since 27/04/2017
@version 1.0
@return Nil
/*/
Static Function fVldHstSRV(aLogItens, cFil)
	Local cAliasTmp := GetNextAlias()
	Local cJoinSRD  := "%" + FWJoinFilial("SRV", "SRD") + "%"
	Local cJoinSRC  := "%" + FWJoinFilial("SRV", "SRC") + "%"
	Local cWhere    := "% RD_PERIODO >= '" + cIniLcto + "' %"
	Local aLogTemp  := {}
	Local nX        := 0

	BeginSQL Alias cAliasTmp
		SELECT
			RD_FILIAL FILIAL, RD_MAT MAT, RA_NOME NOME, RD_PD PD, RV_DESC PDDESC, RD_TIPO1 CTIPO, RV_TIPO RVTIPO, RD_ROTEIR ROT, RD_PROCES PROCES, RD_PERIODO PER, RD_SEMANA SEM
		FROM
			%Table:SRD% SRD
			JOIN %Table:SRV% SRV ON RV_COD = RD_PD AND %Exp:cJoinSRD%
			JOIN %Table:SRA% SRA ON RD_FILIAL = RA_FILIAL AND RD_MAT = RA_MAT
		WHERE
  			%Exp:cWhere% AND
			RD_TIPO1 <> RV_TIPO
			AND SRD.%NotDel%
			AND SRA.%NotDel%
			AND SRV.%NotDel%
			AND RD_FILIAL = %Exp:cFil%

		UNION

		SELECT
			RC_FILIAL FILIAL, RC_MAT MAT, RA_NOME NOME, RC_PD PD, RV_DESC PDDESC, RC_TIPO1 CTIPO, RV_TIPO RVTIPO, RC_ROTEIR ROT, RC_PROCES PROCES, RC_PERIODO PER, RC_SEMANA SEM
		FROM
			%Table:SRC% SRC
			JOIN %Table:SRV% SRV ON RV_COD = RC_PD AND %Exp:cJoinSRC%
			JOIN %Table:SRA% SRA ON RC_FILIAL = RA_FILIAL AND RC_MAT = RA_MAT
		WHERE
			RC_TIPO1 <> RV_TIPO
			AND SRC.%NotDel%
			AND SRA.%NotDel%
			AND SRV.%NotDel%
			AND RC_FILIAL = %Exp:cFil%

		ORDER BY
			FILIAL, MAT, PD
	EndSQL

	While (cAliasTmp)->(!Eof())
		aAdd( aLogTemp,Space(9) + (cAliasTmp)->MAT + Space(6) + If(lOfusca, Replicate('*',30), (cAliasTmp)->NOME) + Space(1) + (cAliasTmp)->PD + Space(3) + (cAliasTmp)->PDDESC + Space(1) + (cAliasTmp)->CTIPO + Space(10) + (cAliasTmp)->RVTIPO + Space(8) + (cAliasTmp)->ROT + Space(5) + (cAliasTmp)->PER )
		(cAliasTmp)->NOME
		(cAliasTmp)->PD
		(cAliasTmp)->PDDESC

		(cAliasTmp)->( DbSkip() )
	EndDo

	If Len(aLogTemp) > 0
		nP++
		aAdd( aLogItens,Space(6) + STR0049) //"Os registros a seguir tem divergência entre o tipo da verba cadastrado na SRV e o tipo da mesma registrado no cálculo: "
		aAdd( aLogItens,"")
		aAdd( aLogItens,Space(9) + STR0028 + Space(3) + Padr(STR0029,TAMSX3("RA_NOME")[1]-Len(STR0029)+5) + STR0050 + Space(1) + Padr(STR0063,TAMSX3("RV_DESC")[1]+1) + STR0051 + Space(1) + STR0052 + Space(1) + STR0053 + Space(1) + STR0054 ) //"Matrícula" "Nome" "Verba" "Descrição" "Tipo Calc." "Tipo SRV" "Roteiro" "Período"
		For nX := 1 To Len(aLogTemp)
			aAdd(aLogItens,aLogTemp[nX])
		Next nX
		aAdd( aLogItens,"")
	EndIf

	(cAliasTmp)->(DbCloseArea())
Return

/*/{Protheus.doc} fCompPd
Compara as verbas com um cadastro padrão
@author Gabriel de Souza Almeida
@since 28/04/2017
@version 1.0
@return Nil
/*/
Static Function fCompPd(aLogItens, cFil)
	Local cAliasTmp  := GetNextAlias()
	Local aLogTemp   := {}
	Local nX         := 0
	Local aCabVer    := {}
	Local aVerbas    := fCargPadPD(@aCabVer)
	Local aVerbasTmp := {}
	Local cWhere     := ""
	Local cP         := " | "
	Local nCodFol    := aScan(aCabVer, {|X| X == "RV_CODFOL" })
	Local nINSS      := aScan(aCabVer, {|X| X == "RV_INSS" })
	Local nIR        := aScan(aCabVer, {|X| X == "RV_IR" })
	Local nINSSFER   := aScan(aCabVer, {|X| X == "RV_INSSFER" })
	Local nFGTS      := aScan(aCabVer, {|X| X == "RV_FGTS" })
	Local nINCORP    := aScan(aCabVer, {|X| X == "RV_INCORP" })
	Local nREF13     := aScan(aCabVer, {|X| X == "RV_REF13" })
	Local nREFFER    := aScan(aCabVer, {|X| X == "RV_REFFER" })
	Local nADIANTA   := aScan(aCabVer, {|X| X == "RV_ADIANTA" })
	Local nPERICUL   := aScan(aCabVer, {|X| X == "RV_PERICUL" })
	Local nINSALUB   := aScan(aCabVer, {|X| X == "RV_INSALUB" })
	Local nPENSAO    := aScan(aCabVer, {|X| X == "RV_PENSAO" })
	Local nDSRHE     := aScan(aCabVer, {|X| X == "RV_DSRHE" })
	Local nHE        := aScan(aCabVer, {|X| X == "RV_HE" })
	Local nADICTS    := aScan(aCabVer, {|X| X == "RV_ADICTS" })
	Local nSINDICA   := aScan(aCabVer, {|X| X == "RV_SINDICA" })
	Local nSALFAMI   := aScan(aCabVer, {|X| X == "RV_SALFAMI" })
	Local nSEGVIDA   := aScan(aCabVer, {|X| X == "RV_SEGVIDA" })
	Local nDEDINSS   := aScan(aCabVer, {|X| X == "RV_DEDINSS" })
	Local nPIS       := aScan(aCabVer, {|X| X == "RV_PIS" })
	Local nDSRPROF   := aScan(aCabVer, {|X| X == "RV_DSRPROF" })
	Local nHRSATIV   := aScan(aCabVer, {|X| X == "RV_HRSATIV" })
	Local nCUSTEMP   := aScan(aCabVer, {|X| X == "RV_CUSTEMP" })
	Local nRRA       := aScan(aCabVer, {|X| X == "RV_RRA" })
	Local nBASCAL    := aScan(aCabVer, {|X| X == "RV_BASCAL" })

	Default cFil     := Space(FWGETTAMFILIAL)

	aSort(aVerbas, , , { | x,y | x[nCodFol] < y[nCodFol] } )

	cWhere := "RV_CODFOL IN ("

	For nX := 1 To Len(aVerbas)
		If !( Empty(aVerbas[nX,nCodFol]) )
			cWhere += "'" + aVerbas[nX,nCodFol] + "',"
			aAdd(aVerbasTmp, aVerbas[nX])
		EndIf
	Next nX

	cWhere += "'xxxx')"
	cWhere := "%" + cWhere + "%"

	BeginSQL Alias cAliasTmp
		SELECT *
		FROM
			%Table:SRV% SRV
		WHERE
			%Exp:cWhere%
			AND SRV.%NotDel%
			AND SRV.RV_FILIAL = %Exp:xFilial("SRV",cFil)%
		ORDER BY
			RV_CODFOL
	EndSQL

	nX      := 1
	aVerbas := {}
	While (cAliasTmp)->(!Eof())
		If aScan(aVerbasTmp,{ |X| (cAliasTmp)->RV_CODFOL == X[nCodFol] } ) > 0
			aAdd(aVerbas, aVerbasTmp[nX])
		EndIf
		nX++
		(cAliasTmp)->( DbSkip() )
	EndDo

	(cAliasTmp)->( DbGoTop() )

	nX := 1

	While (cAliasTmp)->(!Eof())
		If (cAliasTmp)->RV_INSS <> aVerbas[nX,nINSS]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nINSS],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nINSS]) + Space(5) + cP + Space(5) + aVerbas[nX,nINSS] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_IR <> aVerbas[nX,nIR]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nIR],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nIR]) + Space(5) + cP + Space(5) + aVerbas[nX,nIR] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_INSSFER <> aVerbas[nX,nINSSFER]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nINSSFER],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nINSSFER]) + Space(5) + cP + Space(5) + aVerbas[nX,nINSSFER] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_FGTS <> aVerbas[nX,nFGTS]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nFGTS],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nFGTS]) + Space(5) + cP + Space(5) + aVerbas[nX,nFGTS] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_INCORP <> aVerbas[nX,nINCORP]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nINCORP],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nINCORP]) + Space(5) + cP + Space(5) + aVerbas[nX,nINCORP] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_REF13 <> aVerbas[nX,nREF13]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nREF13],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nREF13]) + Space(5) + cP + Space(5) + aVerbas[nX,nREF13] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_REFFER <> aVerbas[nX,nREFFER]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nREFFER],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nREFFER]) + Space(5) + cP + Space(5) + aVerbas[nX,nREFFER] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_ADIANTA <> aVerbas[nX,nADIANTA]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nADIANTA],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nADIANTA]) + Space(5) + cP + Space(5) + aVerbas[nX,nADIANTA] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_PERICUL <> aVerbas[nX,nPERICUL]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nPERICUL],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nPERICUL]) + Space(5) + cP + Space(5) + aVerbas[nX,nPERICUL] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_INSALUB <> aVerbas[nX,nINSALUB]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nINSALUB],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nINSALUB]) + Space(5) + cP + Space(5) + aVerbas[nX,nINSALUB] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_PENSAO <> aVerbas[nX,nPENSAO]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nPENSAO],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nPENSAO]) + Space(5) + cP + Space(5) + aVerbas[nX,nPENSAO] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_DSRHE <> aVerbas[nX,nDSRHE]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nDSRHE],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nDSRHE]) + Space(5) + cP + Space(5) + aVerbas[nX,nDSRHE] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_HE <> aVerbas[nX,nHE]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nHE],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nHE]) + Space(5) + cP + Space(5) + aVerbas[nX,nHE] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_ADICTS <> aVerbas[nX,nADICTS]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nADICTS],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nADICTS]) + Space(5) + cP + Space(5) + aVerbas[nX,nADICTS] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_SINDICA <> aVerbas[nX,nSINDICA]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nSINDICA],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nSINDICA]) + Space(5) + cP + Space(5) + aVerbas[nX,nSINDICA] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_SALFAMI <> aVerbas[nX,nSALFAMI]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nSALFAMI],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nSALFAMI]) + Space(5) + cP + Space(5) + aVerbas[nX,nSALFAMI] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_SEGVIDA <> aVerbas[nX,nSEGVIDA]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nSEGVIDA],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nSEGVIDA]) + Space(5) + cP + Space(5) + aVerbas[nX,nSEGVIDA] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_DEDINSS <> aVerbas[nX,nDEDINSS]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nDEDINSS],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nDEDINSS]) + Space(5) + cP + Space(5) + aVerbas[nX,nDEDINSS] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_PIS <> aVerbas[nX,nPIS]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nPIS],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nPIS]) + Space(5) + cP + Space(5) + aVerbas[nX,nPIS] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_DSRPROF <> aVerbas[nX,nDSRPROF]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nDSRPROF],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nDSRPROF]) + Space(5) + cP + Space(5) + aVerbas[nX,nDSRPROF] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_HRSATIV <> aVerbas[nX,nHRSATIV]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nHRSATIV],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nHRSATIV]) + Space(5) + cP + Space(5) + aVerbas[nX,nHRSATIV] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_CUSTEMP <> aVerbas[nX,nCUSTEMP]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nCUSTEMP],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nCUSTEMP]) + Space(5) + cP + Space(5) + aVerbas[nX,nCUSTEMP] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_RRA <> aVerbas[nX,nRRA]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nRRA],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nRRA]) + Space(5) + cP + Space(5) + aVerbas[nX,nRRA] + Space(6) + cP)
		EndIf
		If (cAliasTmp)->RV_BASCAL <> aVerbas[nX,nBASCAL]
			aAdd( aLogTemp,Space(6) + cP + (cAliasTmp)->RV_COD + Space(2) + cP + (cAliasTmp)->RV_DESC + cP + (cAliasTmp)->RV_CODFOL + cP + Padr(aCabVer[nBASCAL],10) + cP + Space(4) + (cAliasTmp)->&(aCabVer[nBASCAL]) + Space(5) + cP + Space(5) + aVerbas[nX,nBASCAL] + Space(6) + cP)
		EndIf

		nX++
		(cAliasTmp)->( DbSkip() )
	EndDo

	If Len(aLogTemp) > 0
		nP++
		aAdd( aLogItens,Space(7) + Replicate("-",80) )
		aAdd( aLogItens,Space(6) + cP + STR0050 + cP + Padr(STR0063,TAMSX3("RV_DESC")[1]) + cP + "ID" + Space(2) + cP + STR0064 + Space(5) + cP + STR0065 + cP + STR0066 + cP ) //"Verba" "Descrição" "ID" "Campo" "Valor Base" "Valor Padrão"
		aAdd( aLogItens,Space(7) + Replicate("-",80) )
		For nX := 1 To Len(aLogTemp)
			aAdd(aLogItens,aLogTemp[nX])
		Next nX
		aAdd( aLogItens,Space(7) + Replicate("-",80) )
		aAdd( aLogItens,"")
	EndIf

	(cAliasTmp)->(DbCloseArea())
Return

/*/{Protheus.doc} GetFils
Monta tela para seleção de filiais
@author Gabriel de Souza Almeida
@since 03/05/2017
@version 1.0
@return Nil
/*/
Static Function GetFils()
	Local aColumns    := {}
	Local bMarkAll    := { || RhMkAll( cAliasSM0 , .F., .T. , 'MARK', @cMarkAll ,cMark ) }
	Local cMarkAll    := cMark
	Local oPanel      := oWizard:oMPanel[oWizard:nPanel]

	(cAliasSM0)->(DbGoTop())

	While (cAliasSM0)->(!Eof())
		If Empty((cAliasSM0)->MARK)
			cFilOk += AllTrim((cAliasSM0)->(EMPRESA)) + AllTrim((cAliasSM0)->(FILIAL)) + "*"
		Else
			cMark := (cAliasSM0)->MARK
		EndIf
		(cAliasSM0)->(DbSkip())
	EndDo

	(cAliasSM0)->(DbGoTop())

	If oMsSelect == Nil
		aAdd( aColumns, { "MARK"    ,,''        ,"@!"})
		aAdd( aColumns, { "EMPRESA" ,,"Empresa" ,"@!"})
		aAdd( aColumns, { "FILIAL"  ,,"Filial"  ,"@!"})
		aAdd( aColumns, { "NOME"    ,,"Nome"    ,"@!"})

		oMsSelect := MsSelect():New( cAliasSM0      ,; //Alias do Arquivo de Filtro
										 "MARK"         ,; //Campo para controle do mark
										 NIL            ,; //Condicao para o Mark
										 aColumns       ,; //Array com os Campos para o Browse
										 NIL            ,; //
										 cMark          ,; //Conteudo a Ser Gravado no campo de controle do Mark
										 {10,12,150 ,285} ,; //Coordenadas do Objeto
										 NIL            ,; //
										 NIL            ,; //
										 oPanel          ; //Objeto Dialog
										 )
		oMsSelect:oBrowse:lAllMark := .T.
		oMsSelect:oBrowse:bAllMark := bMarkAll
	EndIf
Return

/*/{Protheus.doc} RhMkAll
Marca todas as filiais
@author Gabriel de Souza Almeida
@since 03/05/2017
@version 1.0
@return Nil
/*/
Static Function RhMkAll( cAlias, lInverte, lTodos, cCpoCtrl, cMark, cMarkAux )
	Local nRecno := (cAlias)->(Recno())

	(cAlias)->( DbGoTop() )
	While (cAlias)->( !Eof() )
		RhMkMrk( cAlias , lInverte , lTodos, cCpoCtrl, cMark, {})
		(cAlias)->( DbSkip() )
	End While
	(cAlias)->( MsGoto( nRecno ) )

	If cMark == cMarkAux
		cMark := ""
	Else
		cMark := cMarkAux
	EndIf
Return

/*/{Protheus.doc} fGetFil
Pega filiais selecionadas
@author Gabriel de Souza Almeida
@since 03/05/2017
@version 1.0
@return Nil
/*/
Static Function fGetFil()
	Local aRet  := {}

	DbSelectArea(cAliasSM0)
	(cAliasSM0)->( DbGotop() )

	While (cAliasSM0)->(!Eof())
		If !( Empty((cAliasSM0)->MARK) )
			aAdd( aRet , AllTrim( (cAliasSM0)->FILIAL ) )
		EndIf

		(cAliasSM0)->(DbSkip())
	EndDo
Return aRet


/*/{Protheus.doc} fCargPadPD
Cópia  da função contida no RHIMPSRV
@version P12.1.17
@return Nil, Valor Nulo
/*/
Static Function fCargPadPD(aCabec)
	Local aRet	:= {}

	aCabec := {"DEPARA","RV_COD","RV_DESC","RV_DESCDET","RV_TIPOCOD","RV_IMPRIPD","RV_PERC","RV_CODCORR","RV_CODFOL","RV_TIPO","RV_OBRIGAT","RV_QTDLANC","RV_LCTODIA","RV_VLIMDE","RV_VLIMATE","RV_RLIMDE","RV_RLIMATE","RV_INSS","RV_IR","RV_INSSFER","RV_FGTS","RV_INCORP","RV_REF13","RV_REFFER","RV_ADIANTA","RV_PERICUL","RV_LEEINC","RV_INSALUB","RV_LEEPRE","RV_LEEAUS","RV_PENSAO","RV_LEEBEN","RV_DSRHE","RV_LEEFIX","RV_HE","RV_ADICTS","RV_SINDICA","RV_SALFAMI","RV_SEGVIDA","RV_DEDINSS","RV_TAREFA","RV_PIS","RV_ENCARCC","RV_CUSTO","RV_LCTOP","RV_MED13","RV_MEDFER","RV_MEDAVI","RV_GRAMED","RV_CONVCOL","RV_VALDISS","RV_MEDREAJ","RV_RAIS","RV_DIRF","RV_COMPL_","RV_CODCOM_","RV_DSRPROF","RV_HRSATIV","RV_CUSTEMP","RV_FECCOMP","RV_COD13","RV_CODFER","RV_CODMSEG","RV_LANCPCO","RV_CODMEMO","RV_GRPVERB","RV_CODDSR","RV_CODBASE","RV_RRA","RV_BASCAL","RV_NATUREZ","RV_INCIRF","RV_INCFGTS","RV_INCSIND","RV_INCCP","RV_TPPIRRF","RV_NRPIRRF","RV_TPPFGTS","RV_NRPFGTS","RV_TPPSIND","RV_NRPSIND","RV_TPPROCP","RV_NRPROCP","RV_EXPROCP","RV_FERSEG","RV_EMPCONS","RV_HOMOLOG","RV_AGLTRCT"}

	aAdd(aRet,{Space(10),"001","SALARIO","","1","1","100,000","","0031","D","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"002","DIF.SALARIAL","","1","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"004","SAL.HORISTA","","1","1","100,000","","0032","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"006","DIF.SAL.HORISTA","","1","1","100,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"008","DSR HORISTA","","1","1","100,000","","0033","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"014","PRO LABORE","","1","1","100,000","","0217","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","00","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"016","PGTO.AUTONOMO","","1","1","100,000","","0218","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","00","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"018","ESTAGIO MENSALISTA","","1","1","100,000","","0219","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","029","2",.F.})
	aAdd(aRet,{Space(10),"020","ESTAGIO HORISTA","","1","1","100,000","","0220","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","029","2",.F.})
	aAdd(aRet,{Space(10),"023","COMISSOES","","1","1","100,000","","0165","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","007","2",.F.})
	aAdd(aRet,{Space(10),"025","GARANTIA COMISSAO","","1","1","100,000","","0347","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","007","2",.F.})
	aAdd(aRet,{Space(10),"027","DSR COMISSAO","","1","1","100,000","","0166","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"030","HRA.ATIVIDADE","","1","1","100,000","","0317","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"032","HRA.ATIV.VARIAVEL","","1","1","100,000","","0603","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"034","DSR PROF.VARIAVEL","","1","1","100,000","","0602","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"036","TAREFAS","","1","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"047","GARANTIA TAREFAS","","1","1","100,000","","0652","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"049","HORAS PRONTIDAO","","1","1","100,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","016","2",.F.})
	aAdd(aRet,{Space(10),"052","HORAS SOBREAVISO","","1","1","100,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","015","2",.F.})
	aAdd(aRet,{Space(10),"055","ADIC.C.CONFIANCA","","1","1","100,000","","0984","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","S","S","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"058","ADIC.TRANSFERENCIA","","1","1","100,000","","0988","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","019","2",.F.})
	aAdd(aRet,{Space(10),"061","SALARIO FAMILIA","","1","1","100,000","","0034","V","S","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","S","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","51","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"068","SAL.MATERNIDADE","","1","1","100,000","","0040","D","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","S","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","21","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"070","PRORR.SAL.MAT","","1","1","100,000","","0927","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","S","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"072","MED.SAL.MATERNIDADE","","1","1","100,000","","0407","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","S","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"074","MED.PRORR.SAL.MAT","","1","1","100,000","","0928","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","S","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"076","ATS MATERNIDADE","","1","1","100,000","","1338","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"078","PRORR.ATS MATER","","1","1","100,000","","1351","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"080","INSALUB.MATERNIDADE","","1","1","100,000","","1339","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"082","PRORR.INSAL.MAT","","1","1","100,000","","1352","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"084","PERICUL.MATERNIDADE","","1","1","100,000","","1340","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"086","PRORR.PERIC.MAT","","1","1","100,000","","1353","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"088","ADIC.C.CONF.MATER","","1","1","100,000","","1341","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"090","PRORR.AD.C.CONF.MAT","","1","1","100,000","","1354","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"092","ADIC.TRANSF.MATER","","1","1","100,000","","1342","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"094","PRORR.AD.TRANSF.MAT","","1","1","100,000","","1355","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"097","VLR.EXC.LIM.SAL.MAT","","1","1","100,000","","0668","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","S","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"099","VLR.MD.EXC.SAL.MAT","","1","1","100,000","","0669","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","S","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"103","AUXILIO DOENCA","","1","1","100,000","","0041","D","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"105","COMPL.AUX.DOENCA","","1","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"108","AUXILIO ACIDENTE","","1","1","100,000","","0042","D","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"110","COMPL.AUX.ACIDENTE","","1","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"113","AUXILIO NATALIDADE","","1","1","100,000","","0053","D","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"115","AUXILIO CRECHE","","1","1","100,000","","0721","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"130","INSALUB.MINIMA","","1","1","10,000","","0037","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","S","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","013","2",.F.})
	aAdd(aRet,{Space(10),"133","INSALUB.MEDIA","","1","1","20,000","","0038","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","S","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","013","2",.F.})
	aAdd(aRet,{Space(10),"136","INSALUB.MAXIMA","","1","1","40,000","","0039","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","S","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","013","2",.F.})
	aAdd(aRet,{Space(10),"139","INSALUB.VERBAS","","1","1","100,000","","1282","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"142","PERICULOSIDADE","","1","1","30,000","","0036","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","S","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","014","2",.F.})
	aAdd(aRet,{Space(10),"145","PERICUL.VERBAS","","1","1","100,000","","1281","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"154","ANUENIO","","1","1","100,000","","0001","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","S","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","018","2",.F.})
	aAdd(aRet,{Space(10),"156","ANUENIO VERBAS","","1","1","100,000","","1283","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"158","BIENIO","","1","1","100,000","","0002","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","S","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","018","2",.F.})
	aAdd(aRet,{Space(10),"160","BIENIO VERBAS","","1","1","100,000","","1284","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"162","TRIENIO","","1","1","100,000","","0003","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","S","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","018","2",.F.})
	aAdd(aRet,{Space(10),"164","TRIENIO VERBAS","","1","1","100,000","","1285","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"166","QUADRIENIO","","1","1","100,000","","0004","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","S","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","018","2",.F.})
	aAdd(aRet,{Space(10),"168","QUADRIENIO VERBAS","","1","1","100,000","","1286","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"170","QUINQUENIO","","1","1","100,000","","0005","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","S","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","018","2",.F.})
	aAdd(aRet,{Space(10),"172","QUINQUENIO VERBAS","","1","1","100,000","","1287","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"179","H.EXTRA 50%","","1","1","150,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","S","1","S","N","N","N","N","N","","N","N","N","","S","S","S","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","004","2",.F.})
	aAdd(aRet,{Space(10),"181","DIF.H.EXTRA 50%","","1","1","150,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","S","1","S","N","N","N","N","N","","N","N","N","","S","S","S","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","004","2",.F.})
	aAdd(aRet,{Space(10),"184","H.EXTRA 60%","","1","1","160,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","S","1","S","N","N","N","N","N","","N","N","N","","S","S","S","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","004","2",.F.})
	aAdd(aRet,{Space(10),"186","DIF.H.EXTRA 60%","","1","1","160,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","S","1","S","N","N","N","N","N","","N","N","N","","S","S","S","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","004","2",.F.})
	aAdd(aRet,{Space(10),"189","H.EXTRA 100%","","1","1","200,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","S","1","S","N","N","N","N","N","","N","N","N","","S","S","S","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","004","2",.F.})
	aAdd(aRet,{Space(10),"191","DIF.H.EXTRA 100%","","1","1","200,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","S","1","S","N","N","N","N","N","","N","N","N","","S","S","S","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","004","2",.F.})
	aAdd(aRet,{Space(10),"200","H.E.INTERJORNADA","","1","1","150,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","S","1","S","N","N","N","N","N","","N","N","N","","S","S","S","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","004","2",.F.})
	aAdd(aRet,{Space(10),"203","ADIC.NOTURNO","","1","1","30,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","S","1","N","N","N","N","N","N","","N","N","N","","S","S","S","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","012","2",.F.})
	aAdd(aRet,{Space(10),"205","DIF.ADIC.NOTURNO","","1","1","30,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","S","1","N","N","N","N","N","N","","N","N","N","","S","S","S","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","012","2",.F.})
	aAdd(aRet,{Space(10),"207","ADIC.NOT.EXTRA","","1","1","30,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","S","1","N","N","N","N","N","N","","N","N","N","","S","S","S","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","012","2",.F.})
	aAdd(aRet,{Space(10),"209","DIF.ADIC.NOT.EXTRA","","1","1","30,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","S","1","N","N","N","N","N","N","","N","N","N","","S","S","S","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","012","2",.F.})
	aAdd(aRet,{Space(10),"212","ACRESCIMO NOTURNO","","1","1","100,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","012","2",.F.})
	aAdd(aRet,{Space(10),"215","NONA HORA","","1","1","100,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"218","CRED.BANCO HORAS","","1","1","100,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","S","1","S","N","N","N","N","N","","N","N","N","","S","S","S","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"220","DSR HORA EXTRA","","1","1","100,000","","0035","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","S","N","N","N","N","N","","N","N","N","","S","S","S","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"223","REEMBOLSO ATRASO","","1","1","100,000","","0245","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"225","REEMBOLSO FALTA","","1","1","100,000","","0244","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"227","REEMBOLSO FALTA II","","1","1","100,000","","1363","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"229","REEMBOLSO FALTA III","","1","1","100,000","","1366","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"231","REEMBOLSO FALTA IV","","1","1","100,000","","1367","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"238","PGTO.DIF.DISSIDIO","","1","1","100,000","","0341","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"240","PGTO.DIF.DISS.13 SAL","","1","1","100,000","","0402","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","****C-**********************************","J","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"242","PGTO.DIF.DISS.RRA","","1","1","100,000","","0986","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"245","ADIANTAMENTO","","1","1","100,000","","0006","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"247","ARRED.ADTO","","1","1","100,000","","1329","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"249","ARREDONDAMENTO","","1","1","100,000","","0043","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"251","ARRED.VAL.EXTRA","","1","1","100,000","","0179","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"254","INSUFICIENCIA SALDO","","1","1","100,000","","0045","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"257","PLR","","1","1","100,000","","0151","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","O1","N","","N","N","2","2","","","","","","","","","2","1","1212","14","00","00","00","","","","","","","","","","","2","027","2",.F.})
	aAdd(aRet,{Space(10),"259","PIS RENDIM.ABONO","","1","1","100,000","","","V","S","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"261","COMPENSACAO IR","","1","1","100,000","","0659","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"263","PGTO.V.TRANSPORTE","","1","1","100,000","","0052","V","S","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"265","PGTO.VALE CULTURA","","1","1","100,000","","1368","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"280","1A PARC.13 SALARIO","","1","1","100,000","","0022","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","S","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**B-************************************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","11","00","00","","","","","","","","","","282","2","","2",.F.})
	aAdd(aRet,{Space(10),"282","DIF.1A PARC.13 SAL","","1","1","100,000","","0163","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**B-************************************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"284","2A PARC.13 SALARIO","","1","1","100,000","","0024","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","****C-**********************************","J","N","","N","N","2","2","","","","","","","","","2","1","","12","11","00","12","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"286","DIF.2A PARC.13 SAL","","1","1","100,000","","0028","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","****C-**********************************","J","N","","N","N","2","2","","","","","","","","","2","1","","12","11","00","12","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"289","MED.13 SAL.VALOR","","1","1","100,000","","0123","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","****C-**********************************","J","N","","N","N","2","2","","","","","","","","","2","1","","12","11","00","12","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"291","MED.13 SAL.HORAS","","1","1","100,000","","0124","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","****C-**********************************","J","N","","N","N","2","2","","","","","","","","","2","1","","12","11","00","12","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"294","PERIC.MEDIA 13 SAL","","1","1","100,000","","0181","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","****C-**********************************","J","N","","N","N","2","2","","","","","","","","","2","1","","12","11","00","12","","","","","","","","","","","2","014","2",.F.})
	aAdd(aRet,{Space(10),"296","INSAL.MEDIA 13 SAL","","1","1","100,000","","0182","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","****C-**********************************","J","N","","N","N","2","2","","","","","","","","","2","1","","12","11","00","12","","","","","","","","","","","2","013","2",.F.})
	aAdd(aRet,{Space(10),"299","ATS 13 SALARIO","","1","1","100,000","","1288","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"301","ATS 13 SAL.VB","","1","1","100,000","","1289","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"304","PERICUL.13","","1","1","100,000","","1290","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"306","PERICUL.13 VB","","1","1","100,000","","1291","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"309","INSALUB.13.SALARIO","","1","1","100,000","","1292","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"311","INSALUB.13.SAL.VB","","1","1","100,000","","1293","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"314","ADIC.C.CONF.13","","1","1","100,000","","1294","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"316","ADIC.TRANSF.13","","1","1","100,000","","1295","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"319","INSUF.SALDO 13 SAL","","1","1","100,000","","0030","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"321","ARRED.13 SALARIO","","1","1","100,000","","0026","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"322","1.PARC 13 ANTEC RESC","1 PARCELA 13 ANTECIPADO RESCISAO","1","1","100,000","","1415","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","S","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"337","LIC.REMUNERADA","","1","1","100,000","","0103","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"340","FERIAS","","1","1","100,000","","0072","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","342","2","","2",.F.})
	aAdd(aRet,{Space(10),"342","DIFERENCA FERIAS","","1","1","100,000","","0088","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"344","FERIAS MS","","1","1","100,000","","0073","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","1","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","340","","","","","","2","1","","13","00","00","00","","","","","","","","","","346","2","","2",.F.})
	aAdd(aRet,{Space(10),"346","DIF.FERIAS MS","","1","1","100,000","","0089","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","342","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"348","ATS FERIAS","","1","1","100,000","","1296","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","342","2","","2",.F.})
	aAdd(aRet,{Space(10),"350","ATS FERIAS MS","","1","1","100,000","","1297","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","348","","","","","","2","1","","13","00","00","00","","","","","","","","","","346","2","","2",.F.})
	aAdd(aRet,{Space(10),"352","ATS FERIAS VB","","1","1","100,000","","1298","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"354","ATS FERIAS VB MS","","1","1","100,000","","1299","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","352","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"356","PERICUL.FERIAS","","1","1","100,000","","1300","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","342","2","","2",.F.})
	aAdd(aRet,{Space(10),"358","PERICUL.FERIAS MS","","1","1","100,000","","1301","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","356","","","","","","2","1","","13","00","00","00","","","","","","","","","","346","2","","2",.F.})
	aAdd(aRet,{Space(10),"360","PERICUL.FERIAS VB","","1","1","100,000","","1302","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"362","PERICUL.FERIAS VB MS","","1","1","100,000","","1303","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","360","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"364","INSALUB.FERIAS","","1","1","100,000","","1304","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","342","2","","2",.F.})
	aAdd(aRet,{Space(10),"366","INSALUB.FERIAS MS","","1","1","100,000","","1305","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","364","","","","","","2","1","","13","00","00","00","","","","","","","","","","346","2","","2",.F.})
	aAdd(aRet,{Space(10),"368","INSALUB.FERIAS VB","","1","1","100,000","","1306","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"370","INSALUB.FERIAS VB MS","","1","1","100,000","","1307","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","368","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"372","ADIC.C.CONF.FER","","1","1","100,000","","1308","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","342","2","","2",.F.})
	aAdd(aRet,{Space(10),"374","ADIC.C.CONF.FER.MS","","1","1","100,000","","1309","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","372","","","","","","2","1","","13","00","00","00","","","","","","","","","","346","2","","2",.F.})
	aAdd(aRet,{Space(10),"376","ADIC.TRANSF.FERIAS","","1","1","100,000","","1310","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","342","2","","2",.F.})
	aAdd(aRet,{Space(10),"378","ADIC.TRANSF.FER.MS","","1","1","100,000","","1311","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","376","","","","","","2","1","","13","00","00","00","","","","","","","","","","346","2","","2",.F.})
	aAdd(aRet,{Space(10),"380","CONV.COLET.FERIAS","","1","1","100,000","","0159","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","382","2","","2",.F.})
	aAdd(aRet,{Space(10),"382","DIF.CONV.COL.FERIAS","","1","1","100,000","","0161","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"384","CONV.COLET.FER.MS","","1","1","100,000","","0160","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","1","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","380","","","","","","2","1","","13","00","00","00","","","","","","","","","","386","2","","2",.F.})
	aAdd(aRet,{Space(10),"386","DIF.CONV.COL.FER.MS","","1","1","100,000","","0162","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","382","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"388","OUT.ADICIONAIS","","1","1","100,000","","0084","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"390","DIF.OUT.ADICIONAIS","","1","1","100,000","","0098","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"392","OUT.ADICIONAIS MS","","1","1","100,000","","0085","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","1","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","388","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"394","DIF.OUT.ADIC.MS","","1","1","100,000","","0099","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","390","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"396","MED.FER.VLR","","1","1","100,000","","0075","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","398","2","","2",.F.})
	aAdd(aRet,{Space(10),"398","DIF.MED.FER.VLR","","1","1","100,000","","0838","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"400","MED.FER.VLR.MS","","1","1","100,000","","0076","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","1","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","396","","","","","","2","1","","13","00","00","00","","","","","","","","","","402","2","","2",.F.})
	aAdd(aRet,{Space(10),"402","DIF.MED.FER.VLR.MS","","1","1","100,000","","0839","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","398","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"404","MEDIA H.EXTRA","","1","1","100,000","","0082","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","S","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","406","2","","2",.F.})
	aAdd(aRet,{Space(10),"406","DIF.MED.H.EXTRA","","1","1","100,000","","0096","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"408","MEDIA H.EXTRA MS","","1","1","100,000","","0083","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","1","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","404","","","","","","2","1","","13","00","00","00","","","","","","","","","","410","2","","2",.F.})
	aAdd(aRet,{Space(10),"410","DIF.MED.H.EXTRA MS","","1","1","100,000","","0097","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","406","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"412","MED.FER.COMISSAO","","1","1","100,000","","0343","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","398","2","","2",.F.})
	aAdd(aRet,{Space(10),"414","MED.FER.COMISSAO MS","","1","1","100,000","","0344","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","1","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","412","","","","","","2","1","","13","00","00","00","","","","","","","","","","402","2","","2",.F.})
	aAdd(aRet,{Space(10),"416","MED.FER.TAREFA","","1","1","100,000","","0345","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","398","2","","2",.F.})
	aAdd(aRet,{Space(10),"418","MED.FER.TAREFA MS","","1","1","100,000","","0346","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","1","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","416","","","","","","2","1","","13","00","00","00","","","","","","","","","","402","2","","2",.F.})
	aAdd(aRet,{Space(10),"420","MED.FER.PROFESSOR","","1","1","100,000","","0636","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"422","MED.FER.PROF.MS","","1","1","100,000","","0637","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","1","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"424","DSR MED.FERIAS","","1","1","100,000","","0080","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","428","2","","2",.F.})
	aAdd(aRet,{Space(10),"426","DSR MED.FER.MS","","1","1","100,000","","0081","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","424","","","","","","2","1","","13","00","00","00","","","","","","","","","","430","2","","2",.F.})
	aAdd(aRet,{Space(10),"428","DIF.DSR MED.FERIAS","","1","1","100,000","","0092","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"430","DIF.DSR MED.FER.MS","","1","1","100,000","","0093","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","428","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"432","PGTO.PERIC.MED.FER","","1","1","100,000","","0639","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"434","PGTO.INSAL.MED.FER","","1","1","100,000","","0640","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"437","1/3 FERIAS","","1","1","100,000","","0077","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","441","2","","2",.F.})
	aAdd(aRet,{Space(10),"439","1/3 FERIAS MS","","1","1","100,000","","0078","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","1","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","437","","","","","","2","1","","13","00","00","00","","","","","","","","","","443","2","","2",.F.})
	aAdd(aRet,{Space(10),"441","DIF.1/3 FERIAS","","1","1","100,000","","0090","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"443","DIF.1/3 FERIAS MS","","1","1","100,000","","0091","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","441","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"445","DIF.1/3 MED.FERIAS","","1","1","100,000","","0840","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"447","DIF.1/3 MED.FER.MS","","1","1","100,000","","0841","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","445","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"450","ABONO FERIAS","","1","1","100,000","","0074","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","452","2","","2",.F.})
	aAdd(aRet,{Space(10),"452","DIF.ABONO FERIAS","","1","1","100,000","","0094","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"454","ABONO FERIAS MS","","1","1","100,000","","0205","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","450","","","","","","2","1","","00","00","00","00","","","","","","","","","","456","2","","2",.F.})
	aAdd(aRet,{Space(10),"456","DIF.AB.FERIAS MS","","1","1","100,000","","0207","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","452","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"458","ADIC.ABONO FERIAS","","1","1","100,000","","0632","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"460","ADIC.ABONO FER.MS","","1","1","100,000","","0635","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","458","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"462","MED.HRS.ABONO","","1","1","100,000","","0622","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"464","MED.HRS.ABONO MS","","1","1","100,000","","0633","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","462","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"466","MED.VLR.ABONO","","1","1","100,000","","0623","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"468","MED.VLR.ABONO MS","","1","1","100,000","","0634","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","466","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"471","ATS ABONO","","1","1","100,000","","1312","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","452","2","","2",.F.})
	aAdd(aRet,{Space(10),"473","ATS ABONO MS","","1","1","100,000","","1313","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","471","","","","","","2","1","","00","00","00","00","","","","","","","","","","456","2","","2",.F.})
	aAdd(aRet,{Space(10),"475","ATS ABONO VB","","1","1","100,000","","1314","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"477","ATS ABONO VB MS","","1","1","100,000","","1315","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","475","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"479","PERICUL.ABONO","","1","1","100,000","","1316","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","452","2","","2",.F.})
	aAdd(aRet,{Space(10),"481","PERICUL.ABONO MS","","1","1","100,000","","1317","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","479","","","","","","2","1","","00","00","00","00","","","","","","","","","","456","2","","2",.F.})
	aAdd(aRet,{Space(10),"483","PERICUL.ABONO VB","","1","1","100,000","","1318","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"485","PERICUL.ABONO VB MS","","1","1","100,000","","1319","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","483","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"487","INSALUB.ABONO","","1","1","100,000","","1320","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","452","2","","2",.F.})
	aAdd(aRet,{Space(10),"489","INSALUB.ABONO MS","","1","1","100,000","","1321","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","487","","","","","","2","1","","00","00","00","00","","","","","","","","","","456","2","","2",.F.})
	aAdd(aRet,{Space(10),"491","INSALUB.ABONO VB","","1","1","100,000","","1322","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"493","INSALUB.ABONO VB MS","","1","1","100,000","","1323","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","491","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"495","ADIC.C.CONF.ABONO","","1","1","100,000","","1324","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","452","2","","2",.F.})
	aAdd(aRet,{Space(10),"497","ADIC.C.CONF.AB.MS","","1","1","100,000","","1325","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","495","","","","","","2","1","","00","00","00","00","","","","","","","","","","456","2","","2",.F.})
	aAdd(aRet,{Space(10),"499","ADIC.TRANSF.ABONO","","1","1","100,000","","1326","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","452","2","","2",.F.})
	aAdd(aRet,{Space(10),"502","ADIC.TRANSF.AB.MS","","1","1","100,000","","1327","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","499","","","","","","2","1","","00","00","00","00","","","","","","","","","","456","2","","2",.F.})
	aAdd(aRet,{Space(10),"504","DSR MEDIA ABONO","","1","1","100,000","","1330","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","452","2","","2",.F.})
	aAdd(aRet,{Space(10),"506","DSR MEDIA ABONO MS","","1","1","100,000","","1331","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","504","","","","","","2","1","","00","00","00","00","","","","","","","","","","456","2","","2",.F.})
	aAdd(aRet,{Space(10),"509","1/3 ABONO FERIAS","","1","1","100,000","","0079","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","511","2","","2",.F.})
	aAdd(aRet,{Space(10),"511","DIF.1/3 AB.FERIAS","","1","1","100,000","","0095","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"513","1/3 ABONO FER.MS","","1","1","100,000","","0206","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","509","","","","","","2","1","","00","00","00","00","","","","","","","","","","515","2","","2",.F.})
	aAdd(aRet,{Space(10),"515","DIF.1/3 AB.FER.MS","","1","1","100,000","","0208","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","0","N","","N","N","2","2","","","511","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"518","FERIAS DOBRO","","1","1","100,000","","0224","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","520","2","","2",.F.})
	aAdd(aRet,{Space(10),"520","DIF.FERIAS DOBRO","","1","1","100,000","","0227","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"522","1/3 FERIAS DOBRO","","1","1","100,000","","0226","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","524","2","","2",.F.})
	aAdd(aRet,{Space(10),"524","DIF.1/3 FER.DOBRO","","1","1","100,000","","0228","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","1","S","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"527","RECESSO ESTAGIARIO","","1","1","100,000","","0891","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","029","2",.F.})
	aAdd(aRet,{Space(10),"530","ARRED.FERIAS","","1","1","100,000","","0104","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"536","SALDO DE SALARIO","","1","1","100,000","","0048","D","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"539","DSR INDENIZADO","","1","1","100,000","","0430","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"542","COMISSAO RESCISAO","","1","1","100,000","","0121","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","007","2",.F.})
	aAdd(aRet,{Space(10),"544","DSR COMISSAO RESC","","1","1","100,000","","0122","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"547","CONV.COLET.RESCISAO","","1","1","100,000","","0158","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"550","INDENIZACAO RESCISAO","","1","1","100,000","","0110","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","N","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","E","N","","N","N","2","2","","","","","","","","","2","1","","00","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"552","FER.PROPORCIONAIS","","1","1","100,000","","0087","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","******D-********************************","I","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"554","MED.FER.PROPOR","","1","1","100,000","","0249","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","******D-********************************","I","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"556","1/3 FERIAS PROPOR","","1","1","100,000","","0625","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","******D-********************************","I","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"558","FERIAS INDENIZADAS","","1","1","100,000","","0086","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","******D-********************************","I","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"560","MED.FER.INDENIZADAS","","1","1","100,000","","0248","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","******D-********************************","I","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"562","1/3 FER.INDENIZADAS","","1","1","100,000","","0125","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","******D-********************************","I","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"564","FERIAS DOBRO RESC","","1","1","100,000","","0925","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","******D-********************************","E","N","","N","N","2","2","","","","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"566","1/3 FER.DOBRO RESC","","1","1","100,000","","0926","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","******D-********************************","E","N","","N","N","2","2","","","","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"568","AV.PREV.TRABALHADO","","1","1","100,000","","0112","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"570","AV.PREV.INDENIZADO","","1","1","100,000","","0111","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","N","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","************************************S-**","E","N","","N","N","2","2","","","","","","","","","2","1","","00","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"572","MEDIA AVISO PREVIO","","1","1","100,000","","0250","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","N","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","************************************S-**","E","N","","N","N","2","2","","","","","","","","","2","1","","00","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"574","AVO FER.AV.PREVIO","","1","1","100,000","","0230","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","************************************S-**","I","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"576","MED.FER.AV.PREVIO","","1","1","100,000","","0252","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","************************************S-**","I","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"578","1/3 FER.AV.PREVIO","","1","1","100,000","","0231","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","************************************S-**","I","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"580","13 SAL.RESCISAO","","1","1","100,000","","0114","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","****C-**********************************","J","N","","N","N","2","2","","","","","","","","","2","1","","12","11","00","12","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"582","MEDIA 13 SAL.RES","","1","1","100,000","","0251","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","****C-**********************************","J","N","","N","N","2","2","","","","","","","","","2","1","","12","11","00","12","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"584","AVO 13 AV.PREVIO","","1","1","100,000","","0115","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","************************************S-**","I","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"586","MEDIA 13 AV.PREVIO","","1","1","100,000","","0253","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","************************************S-**","I","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"589","MULTA CONTR.EXPER","","1","1","100,000","","0176","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","E","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"591","MULTA DISP.DISSIDIO","","1","1","100,000","","0178","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","E","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"593","MED.MULTA DISP.DISS","","1","1","100,000","","0985","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","E","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"596","ARRED.RESCISAO","","1","1","100,000","","0127","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"600","INSS","","2","1","100,000","","0064","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","9206","00","00","00","31","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"602","INSS FERIAS","","2","1","100,000","","0065","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","9206","00","00","00","31","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"604","INSS FERIAS MS","","2","1","100,000","","0232","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"606","INSS 13 SALARIO","","2","1","100,000","","0070","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","9207","00","00","00","32","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"608","INSS P.LAB/AUTONOMO","","2","1","100,000","","0222","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"610","INSS AUTONOMOS","","2","1","100,000","","0209","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"612","INSS SEST / SENAT","","2","1","100,000","","0437","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"614","INSS DIF.DISSIDIO","","2","1","100,000","","0340","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"616","INSS DIF.DISS.13 SAL","","2","1","100,000","","0401","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"620","CONTR.PREV.RRA","","2","1","100,000","","0975","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","B2","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"622","CONTR.PREV.RRA 13","","2","1","100,000","","0980","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","B2","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"630","IR","","2","1","100,000","","0066","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","D","N","","N","N","2","2","","","C42","","","","","","2","1","9208","31","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"632","IR.ADTO","","2","1","100,000","","0009","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","S","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","D","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"634","DIF.IR.ADTO.MA","","2","1","100,000","","0011","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","D","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"636","IR.FERIAS","","2","1","100,000","","0067","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","D","N","","N","N","2","2","","","","","","","","","2","1","9209","33","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"638","DIF.IR.FERIAS","","2","1","100,000","","0101","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","D","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"640","IR.13 SALARIO","","2","1","100,000","","0071","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","L","N","","N","N","2","2","","","","","","","","","2","1","9210","32","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"642","IR.PLR","","2","1","100,000","","0152","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","Q1","N","","N","N","2","2","","","","","","","","","2","1","9208","34","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"644","IR.RRA","","2","1","100,000","","0978","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","D2","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"646","IR.RRA 13 SAL","","2","1","100,000","","0983","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","D2","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"650","ARRED.VAL.EXTRA","","2","1","100,000","","0180","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"652","ARRED.ADTO","","2","1","100,000","","0008","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","S","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"654","ADTO.QUINZENAL","","2","1","100,000","","0007","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","11","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"656","ADTO.PLR","","2","1","100,000","","1279","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"660","MENSAL.SINDICAL","","2","1","100,000","","0720","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"663","CONTR.SINDICAL","","2","1","100,000","","0068","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","****************************O-**********","N","N","","N","N","2","2","","","","","","","","","2","1","9202","00","00","31","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"665","CONTR.ASSISTENCIAL","","2","1","100,000","","0069","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","******************************P-********","N","N","","N","N","2","2","","","","","","","","","2","1","9203","00","00","31","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"667","CONTR.CONFEDERATIVA","","2","1","100,000","","0175","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","********************************Q-******","N","N","","N","N","2","2","","","","","","","","","2","1","9204","00","00","31","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"670","SAIDA ANTECIPADA","","2","1","100,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"672","SAIDA EXPEDIENTE","","2","1","100,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"674","FALTA 1/2 PERIODO","","2","1","100,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"676","FALTAS","","2","1","100,000","","0054","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"678","FALTAS II","","2","1","100,000","","0242","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"680","FALTAS III","","2","1","100,000","","1364","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"682","FALTAS IV","","2","1","100,000","","1365","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"684","DESC.FALTA MA","","2","1","100,000","","0203","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"686","ATRASO","","2","1","100,000","","0055","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"688","ATRASO II","","2","1","100,000","","0243","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"690","DEB.BANCO HORAS","","2","1","100,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"692","DESCONTO DSR","","2","1","100,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","S","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","11","11","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"695","VALE TRANSPORTE","","2","1","6,000","","0051","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"697","VALE REFEICAO","","2","1","100,000","","0050","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"699","VALE ALIMENTACAO","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"702","CESTA BASICA","","2","1","100,000","","0156","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"704","SEGURO DE VIDA","","2","1","100,000","","0153","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"706","FARMACIA","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"712","ASS.MEDICA","","2","1","100,000","","0049","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","R","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"714","ASS.MED.DEPENDENTE","","2","1","100,000","","0607","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"716","ASS.MED.AGREGADO","","2","1","100,000","","0609","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"728","ASS.ODO.TITULAR","","2","1","100,000","","0714","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","R","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"730","ASS.ODO.DEPENDENTE","","2","1","100,000","","0715","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","R","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"732","ASS.ODO.AGREGADO","","2","1","100,000","","0716","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","R","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"742","EMPRESTIMO","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"750","VALE CULTURA","","2","1","100,000","","1369","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"760","PENS.ALIMENTICIA","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"762","PENS.ALIMENTICIA 2","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"764","PENS.ALIM.ADTO","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"766","PENS.ALIM.ADTO 2","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"768","PENS.ALIM.FERIAS","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"770","PENS.ALIM.FERIAS 2","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"772","P.ALIM.1A PARC.13","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"774","P.ALIM.1A PARC.13 2","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"776","P.ALIM.2A PARC.13","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"778","P.ALIM.2A PARC.13 2","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"780","PENS.ALIM.PLR","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"782","PENS.ALIM.PLR 2","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"784","PENS.ALIM.RRA","","2","1","100,000","","0976","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","C2","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"786","PENS.ALIM.RRA 2","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"788","PENS.ALIM.RRA 13","","2","1","100,000","","0981","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","C2","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"790","PENS.ALIM.RRA 13 2","","2","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"794","DESC.DIF.DISSIDIO","","2","1","100,000","","0342","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"796","DESC.DIF.DISS.13","","2","1","100,000","","0403","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"798","DESC.DIF.DISS.RRA","","2","1","100,000","","0987","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"804","DESC.INSUF.SALDO","","2","1","100,000","","0046","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"806","ARRED.ANTERIOR","","2","1","100,000","","0044","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"809","DESC.DIF.13 SAL","","2","1","100,000","","0348","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"811","ADIANT.13 SALARIO","","2","1","100,000","","0023","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"813","DESC.ANT.13 2A PARC","","2","1","100,000","","0183","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","S","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","11","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"815","ADIANT.13 FERIAS","","2","1","100,000","","0202","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"817","DESC.13 SAL.RESCISAO","","2","1","100,000","","0116","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","S","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","11","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"819","DESC.2A PARC.13 SAL","","2","1","100,000","","0247","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","S","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","11","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"821","DESC.INSUF.SALDO 13","","2","1","100,000","","0025","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"823","ARRED.13 SAL","","2","1","100,000","","0029","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"829","FERIAS PAGAS MA","","2","1","100,000","","0164","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A","N","","N","N","2","2","","","","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"831","ARRED.FERIAS","","2","1","100,000","","0105","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"833","LIQUIDO FERIAS","","2","1","100,000","","0102","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"839","DESC.INDENIZACAO","","2","1","100,000","","0301","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"841","DESC.CONT.EXPER","","2","1","100,000","","0177","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"850","AV.PREV.DESCONTADO","","2","1","100,000","","0113","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"855","DESC.MED.AV.PREVIO","","2","1","100,000","","0972","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"878","LIQ.RESC.ANTERIOR","","2","1","100,000","","0303","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"880","LIQUIDO RESCISAO","","2","1","100,000","","0126","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","S","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B00","BASE INSS ATE LIM","","3","1","100,000","","0013","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B02","BASE INSS ACIMA LIM","","3","1","100,000","","0014","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B04","B.INSS ATE LIM.13","","3","1","100,000","","0019","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B06","B.INSS ACIMA LIM.13","","3","1","100,000","","0020","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B09","B.INSS 13 ANT.DESON","","3","1","100,000","","0991","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B12","PGTO.SERV.P.FISICA","","3","1","100,000","","0349","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","11","00","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B14","BASE INSS P.FISICA","","3","1","100,000","","0350","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B16","INSS P.FISICA","","3","1","100,000","","0351","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B19","PGTO.SERV.P.JURIDICA","","3","1","100,000","","0352","V","N","9","N","0,01","999999999,99","0,01","999999999,99","S","S","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","11","00","00","11","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B21","B.INSS P.JURIDICA","","3","1","100,000","","0353","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B23","INSS P.JURIDICA","","3","1","100,000","","0354","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B26","B.INSS FER.OUT.PER","","3","1","100,000","","0396","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B28","INSS FER.OUT.PER","","3","1","100,000","","0397","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B31","B.INSS OUT.EMP","","3","1","100,000","","0288","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B33","INSS OUT.EMPRESA","","3","1","100,000","","0289","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B35","B.INSS 13 OUT.EMP","","3","1","100,000","","0290","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B38","INSS 13 OUT.EMP","","3","1","100,000","","0291","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B40","INSS PRO LAB.AUT","","3","1","100,000","","0197","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B42","INSS VLR.RECEITA","","3","1","100,000","","0198","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B44","% ACID.VLR.RECEITA","","3","1","100,000","","0199","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B46","INSS COOPERATIVA","","3","1","100,000","","0313","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B48","NF.PREST.SERVICO","","3","1","100,000","","0314","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B50","PROD.RURAL P.FIS","","3","1","100,000","","0315","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B52","PROD.RURAL P.JUR","","3","1","100,000","","0316","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B54","INSS FATURAMENTO","","3","1","100,000","","0973","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B56","COMPENSACAO GPS","","3","1","100,000","","0584","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B58","B.INSS AUT/PRO LAB","","3","1","20,000","","0221","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B60","B.INSS AUTONOMO","","3","1","20,000","","0225","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B62","B.INSS DIF.DISSIDIO","","3","1","100,000","","0338","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B64","B.INSS DIF.DISS.13","","3","1","100,000","","0399","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B70","INSS EMPRESA","","3","1","100,000","","0148","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","782","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B72","INSS EMPRESA DISS.","","3","1","100,000","","0943","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B74","TERCEIROS","","3","1","100,000","","0149","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","786","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B76","TERCEIROS DISSIDIO","","3","1","100,000","","0944","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B78","ACID.TRABALHO","","3","1","100,000","","0150","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","784","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B80","ACID.TRAB.DISSIDIO","","3","1","100,000","","0945","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B82","INCRA","","3","1","100,000","","0184","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","963","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B84","INCRA DISSIDIO","","3","1","100,000","","0946","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B86","SENAI","","3","1","100,000","","0185","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","965","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B88","SENAI DISSIDIO","","3","1","100,000","","0947","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B90","SESI","","3","1","100,000","","0186","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","967","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B92","SESI DISSIDIO","","3","1","100,000","","0948","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B94","SENAC","","3","1","100,000","","0187","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","969","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B96","SENAC DISSIDIO","","3","1","100,000","","0949","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"B98","SESC","","3","1","100,000","","0188","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","971","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C00","SESC DISSIDIO","","3","1","100,000","","0950","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C02","SEBRAE","","3","1","100,000","","0189","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","973","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C04","SEBRAE DISSIDIO","","3","1","100,000","","0951","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C06","DPC","","3","1","100,000","","0190","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","975","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C08","DPC DISSIDIO","","3","1","100,000","","0952","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C10","FAER","","3","1","100,000","","0191","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","977","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C12","FAER DISSIDIO","","3","1","100,000","","0953","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C14","SENAR","","3","1","100,000","","0192","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","979","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C16","SENAR DISSIDIO","","3","1","100,000","","0954","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C18","SECONC","","3","1","100,000","","0193","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","981","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C20","SECONC DISSIDIO","","3","1","100,000","","0955","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C22","CONTR.SEST","","3","1","100,000","","0200","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","983","N","N","2","2","","","","","","","","","2","1","","00","00","00","","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C24","CONTR.SEST DISSIDIO","","3","1","100,000","","0956","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C26","CONTR.SENAT","","3","1","100,000","","0201","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","985","N","N","2","2","","","","","","","","","2","1","","00","00","00","","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C28","CONTR.SENAT DISSIDIO","","3","1","100,000","","0957","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C30","CONTR.SESCOOP","","3","1","100,000","","0782","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","987","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C32","CONTR.SESCOOP DISS","","3","1","100,000","","0958","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C34","SALARIO EDUCACAO","","3","1","100,000","","0204","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","S","961","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C36","SAL.EDUCACAO DISS","","3","1","100,000","","0959","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C40","B.IR MES ANTERIOR","","3","1","100,000","","0106","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","S","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C42","IR MES ANTERIOR","","3","1","100,000","","0107","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","S","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C44","BASE IR","","3","1","100,000","","0015","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","C40","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C46","BASE IR ADTO","","3","1","100,000","","0010","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C48","IR ADTO","","3","1","100,000","","0012","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","D","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C50","BASE IR FERIAS","","3","1","100,000","","0016","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C52","DIF.BASE IR FER","","3","1","100,000","","0100","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C54","B.IR.FERIAS OUT.PER","","3","1","100,000","","0236","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C56","IR.FERIAS OUT.PER","","3","1","100,000","","0237","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","D","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C58","BASE IR 13 SAL","","3","1","100,000","","0027","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C60","BASE IR PLR","","3","1","100,000","","0835","H","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C62","IR PLR MA","","3","1","100,000","","1328","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C64","BASE IR RRA","","3","1","100,000","","0974","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A1","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C66","BASE IR RRA 13 SAL","","3","1","100,000","","0979","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","A1","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C68","B.IR OUT.EMP","","3","1","100,000","","0992","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C70","IR OUT.EMP","","3","1","100,000","","0993","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C72","B.IR OUT.EMP.13","","3","1","100,000","","0994","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C74","IR OUT.EMP.13","","3","1","100,000","","0995","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C76","B.IR OUT.EMP.ADTO","","3","1","100,000","","0996","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C78","IR OUT.EMP.ADTO","","3","1","100,000","","0997","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C80","REDUTOR B.IR FOLHA","","3","1","100,000","","0408","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","11","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C82","REDUTOR B.IR 13","","3","1","100,000","","0409","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","S","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","12","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C84","REDUTOR B.IR FERIAS","","3","1","100,000","","0410","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C86","REDUTOR B.IR PLR","","3","1","100,000","","0411","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","11","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C90","B.FGTS SEM.ANTERIOR","","3","1","100,000","","0649","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C92","FGTS SEM.ANTERIOR","","3","1","100,000","","0650","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C94","CONTR.SEM.ANTERIOR","","3","1","100,000","","0651","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C96","BASE FGTS","","3","1","100,000","","0017","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"C98","FGTS","","3","1","100,000","","0018","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D00","CONT.0,5% FGTS","","3","1","0,500","","0298","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D02","BASE FGTS 13 SAL","","3","1","100,000","","0108","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D04","FGTS 13 SALARIO","","3","1","100,000","","0109","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D06","CONT.0,5% FGTS 13","","3","1","0,500","","0299","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D08","SALDO FGTS","","3","1","100,000","","0118","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D10","FGTS M.ANTERIOR","","3","1","100,000","","0117","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D12","FGTS A RECUPERAR","","3","1","100,000","","0823","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D14","B.FGTS RESC.DISP","","3","1","100,000","","0293","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D16","FGTS RESCISAO","","3","1","100,000","","0119","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D18","CONTR.0,5% RESCISAO","","3","1","0,500","","0295","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D20","B.FGTS 13 RESC.DISP","","3","1","100,000","","0294","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D22","FGTS 13 RESCISAO","","3","1","100,000","","0214","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D24","FGTS 13 2A PARC.RESC","","3","1","100,000","","0722","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D26","FGTS 13 RECUP.RESC","","3","1","100,000","","0292","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D28","CONTR.0,5% 13 RESC","","3","1","0,500","","0296","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D30","CONTR.10% FGTS RESC","","3","1","10,000","","0297","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D32","CONTR.10% FGTS DISS","","3","1","10,000","","0727","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D34","MULTA 40% FGTS","","3","1","100,000","","0120","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D36","MULTA 40% FGTS DISS","","3","1","100,000","","0712","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D39","B.FGTS DIF.DISSIDIO","","3","1","100,000","","0337","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D41","FGTS DIF.DISSIDIO","","3","1","100,000","","0339","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D43","B.FGTS DIF.DISS.13","","3","1","100,000","","0398","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D45","FGTS DIF.DISS.13","","3","1","100,000","","0400","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D51","DED.INSS BASE IR","","3","1","100,000","","0167","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","B","N","","N","N","2","2","","","","","","","","","2","1","","11","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D53","DED.INSS B.IR FERIAS","","3","1","100,000","","0168","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","S","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","B","N","","N","N","2","2","","","","","","","","","2","1","","13","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D55","DED.INSS B.IR 13","","3","1","100,000","","0169","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","S","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","B1","N","","N","N","2","2","","","","","","","","","2","1","","12","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D58","DED.SAL.MATERNIDADE","","3","1","100,000","","1280","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D60","DED.SAL.MATER.13","","3","1","100,000","","0670","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D63","DED.IR.INATIVOS","","3","1","100,000","","0624","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**********************************R-****","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D65","DED.RESIDUO DO IR","","3","1","100,000","","0063","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","S","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D68","DED.DEPENDENTES","","3","1","100,000","","0059","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","T","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D70","DED.DEP.FERIAS","","3","1","100,000","","0060","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","T","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D72","DED.DEP.DIF.FER","","3","1","100,000","","0061","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","T","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D74","DED.DEP.13","","3","1","100,000","","0062","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","T1","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D76","DED.DEP.PLR","","3","1","100,000","","0300","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","T","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D80","BASE PIS EMPRESA","","3","1","100,000","","0223","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D82","PIS EMPRESA","","3","1","100,000","","0229","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D86","B.PENSAO ALIMENTICIA","","3","1","100,000","","0057","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D88","B.PENSAO ALIM.ADTO","","3","1","100,000","","0174","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D90","B.PENSAO ALIM.FERIAS","","3","1","100,000","","0171","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","S","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D92","B.PENSAO 1A PARC.13","","3","1","100,000","","0173","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D94","B.PENSAO 2A PARC.13","","3","1","100,000","","0129","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"D98","B.SAL.MATERNIDADE","","3","1","100,000","","0238","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E02","B.PERICULOSIDADE","","3","1","30,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E06","B.INSALUB.MINIMA","","3","1","10,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E08","B.INSALUB.MEDIA","","3","1","20,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E10","B.INSALUB.MAXIMA","","3","1","40,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E14","BASE ANUENIO","","3","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E16","BASE BIENIO","","3","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E18","BASE TRIENIO","","3","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E20","BASE QUADRIENIO","","3","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E22","BASE QUINQUENIO","","3","1","100,000","","","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E28","PREV.PRIVADA FOLHA","","3","1","100,000","","0215","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","11","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E30","PREV.PRIVADA FERIAS","","3","1","100,000","","0216","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","11","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E32","PREV.PRIVADA 13","","3","1","100,000","","0302","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","S","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","11","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E40","CONT.SIND.OUT.EMPR","","3","1","100,000","","0246","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E44","BASE CESTA BASICA","","3","1","100,000","","0157","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E46","CESTA BAS.EMPRESA","","3","1","100,000","","0211","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E50","BASE SEGURO VIDA","","3","1","100,000","","0155","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E52","SEG.VIDA EMPRESA","","3","1","100,000","","0154","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E56","V.TRANSP.EMPRESA","","3","1","100,000","","0210","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E60","V.REFEICAO EMPRESA","","3","1","100,000","","0212","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E70","ASSIST.MED.EMP.TIT","","3","1","100,000","","0213","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E72","ASSIST.MED.EMP.DEP","","3","1","100,000","","0725","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E74","ASSIST.MED.EMP.AGR","","3","1","100,000","","0726","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E78","DEP. ASS.MED.EMP","","3","1","100,000","","0608","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E80","AGR.ASS.MED.EMP","","3","1","100,000","","0610","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E90","ASSIST.ODONT.EMP.TIT","","3","1","100,000","","0717","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E92","ASSIST.ODONT.EMP.DEP","","3","1","100,000","","0718","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"E94","ASSIST.ODONT.EMP.AGR","","3","1","100,000","","0719","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F00","INSALUBRIDADE MES","","3","1","100,000","","0672","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F02","PERICULOSIDADE MES","","3","1","100,000","","0673","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F04","ADIC.TEMPO SERV.MES","","3","1","100,000","","0671","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F10","PROV.CUSTO 13","","3","1","100,000","","0195","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F12","PROV.CUSTO FERIAS","","3","1","100,000","","0194","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F14","PROV.CUSTO RESC","","3","1","100,000","","0196","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F30","PROVISAO FERIAS","","3","1","100,000","","0130","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F32","ADIC.PROV.FERIAS","","3","1","100,000","","0254","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F34","1/3 PROV.FERIAS","","3","1","100,000","","0255","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F36","INSS PROV.FERIAS","","3","1","100,000","","0131","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F38","FGTS PROV.FERIAS","","3","1","100,000","","0132","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F42","CORR.PROV.FERIAS","","3","1","100,000","","0133","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F44","CORR.ADIC.PROV.FER","","3","1","100,000","","0256","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F46","CORR.1/3 PROV.FER","","3","1","100,000","","0257","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F48","CORR.INSS PROV.FER","","3","1","100,000","","0134","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F50","CORR.FGTS PROV.FER","","3","1","100,000","","0135","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F54","BAIXA PROV.FERIAS","","3","1","100,000","","0233","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F56","BAIXA ADIC.PROV.FER","","3","1","100,000","","0258","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F58","BAIXA 1/3 PROV.FER","","3","1","100,000","","0259","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F60","BAIXA INSS PROV.FER","","3","1","100,000","","0234","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F62","BAIXA FGTS PROV.FER","","3","1","100,000","","0235","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F66","BAIXA PROV.FER.TRAN","","3","1","100,000","","0239","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F68","B.ADIC.FERIAS TRAN","","3","1","100,000","","0260","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F70","B.1/3 PROV.FER.TRAN","","3","1","100,000","","0261","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F72","B.INSS PROV.FER.TRAN","","3","1","100,000","","0240","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F74","B.FGTS PROV.FER.TRAN","","3","1","100,000","","0241","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F78","B.PROV.FER.RESCISAO","","3","1","100,000","","0262","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F80","B.ADIC.PROV.FER.RESC","","3","1","100,000","","0263","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F82","B.1/3 PROV.FER.RESC","","3","1","100,000","","0264","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F84","B.INSS PROV.FER.RESC","","3","1","100,000","","0265","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F86","B.FGTS PROV.FER.RESC","","3","1","100,000","","0266","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F90","PROV.MES FERIAS","","3","1","100,000","","0960","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F92","PROV.MES 1/3 FERIAS","","3","1","100,000","","0961","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F94","PROV.MES ADIC.FERIAS","","3","1","100,000","","0962","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F96","PROV.MES INSS FERIAS","","3","1","100,000","","0963","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"F98","PROV.MES FGTS FERIAS","","3","1","100,000","","0964","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G00","PROV.MES PIS FERIAS","","3","1","100,000","","0965","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G20","PROVISAO 13 SALARIO","","3","1","100,000","","0136","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G22","ADTO.1A PARC.13 PROV","","3","1","100,000","","0268","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G24","ADIC.PROV.13 SALARIO","","3","1","100,000","","0267","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G26","INSS PROV.13 SALARIO","","3","1","100,000","","0137","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G28","FGTS PROV.13 SALARIO","","3","1","100,000","","0138","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G32","CORR.PROV.13 SALARIO","","3","1","100,000","","0139","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G34","CORR.ADIC.PROV.13","","3","1","100,000","","0269","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G36","CORR.INSS PROV.13","","3","1","100,000","","0140","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G38","CORR.FGTS PROV.13","","3","1","100,000","","0141","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G42","B.PROVISAO 13 SAL","","3","1","100,000","","0332","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G44","B.ADIC.PROV.13 SAL","","3","1","100,000","","0333","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G46","B.ANTECIP.1A P.13","","3","1","100,000","","0334","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G48","B.INSS PROV.13 SAL","","3","1","100,000","","0335","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G50","B.FGTS PROV. 13 SAL","","3","1","100,000","","0336","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G54","BAIXA 13 SAL.TRAN","","3","1","100,000","","0270","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G56","B.ADIC.PROV.13 TRAN","","3","1","100,000","","0271","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G58","B.INSS PROV.13 TRAN","","3","1","100,000","","0272","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G60","B.FGTS PROV.13 TRAN","","3","1","100,000","","0273","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G66","B.PROV.13 RESCISAO","","3","1","100,000","","0274","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G68","B.ADIC.PROV.13 RESC","","3","1","100,000","","0275","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G70","B.INSS PROV.13 RESC","","3","1","100,000","","0276","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G72","B.FGTS PROV.13 RESC","","3","1","100,000","","0277","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G78","PROV.MES 13 SALARIO","","3","1","100,000","","0966","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G80","PROV.MES ADIC.13 SAL","","3","1","100,000","","0967","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G82","PROV.MES 1A P.13 SAL","","3","1","100,000","","0968","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G84","PROV.MES INSS 13 SAL","","3","1","100,000","","0969","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G86","PROV.MES FGTS 13 SAL","","3","1","100,000","","0970","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"G88","PROV.MES PIS 13 SAL","","3","1","100,000","","0971","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H08","PROVISAO 14 SALARIO","","3","1","100,000","","0142","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H10","ADIC.PROV.14 SALARIO","","3","1","100,000","","0278","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H12","INSS PROV.14 SALARIO","","3","1","100,000","","0143","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H14","FGTS PROV.14 SALARIO","","3","1","100,000","","0144","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H18","CORR.PROV.14 SALARIO","","3","1","100,000","","0145","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H20","CORR.ADIC.PROV.14","","3","1","100,000","","0279","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H22","CORR.INSS PROV.14","","3","1","100,000","","0146","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H24","CORR.FGTS PROV.14","","3","1","100,000","","0147","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H28","B.PROV.14 TRAN","","3","1","100,000","","0280","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H30","B.ADIC.PROV.14 TRAN","","3","1","100,000","","0281","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H32","B.INSS PROV.14 TRAN","","3","1","100,000","","0282","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H34","B.FGTS PROV.14 TRAN","","3","1","100,000","","0283","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H38","B.PROV.14 RESCISAO","","3","1","100,000","","0284","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H40","B.ADIC.PROV.14 RESC","","3","1","100,000","","0285","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H42","B.INSS PROV.14 RESC","","3","1","100,000","","0286","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H44","B.FGTS PROV.14 RESC","","3","1","100,000","","0287","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H64","PIS PROV.FERIAS","","3","1","100,000","","0416","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H66","CORR.PIS PROV.FERIAS","","3","1","100,000","","0417","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H68","BX.PIS PROV.FERIAS","","3","1","100,000","","0418","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H70","BX.PIS.PROV.FER.TRAN","","3","1","100,000","","0419","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H72","BX.PIS.PROV.FER.RESC","","3","1","100,000","","0420","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H76","PIS PROV.13 SALARIO","","3","1","100,000","","0421","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H78","CORR.PIS.PROV.13 SAL","","3","1","100,000","","0422","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H80","BX.PIS PROV.13 SAL","","3","1","100,000","","0423","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H82","BX.PIS PROV.13 TRAN","","3","1","100,000","","0424","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H84","BX.PIS PROV.13 RESC","","3","1","100,000","","0425","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H88","PIS PROV.14 SAL","","3","1","100,000","","0426","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H90","CORR.PIS.PROV.14 SAL","","3","1","100,000","","0427","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H92","BX.PIS PROV.14 TRAN","","3","1","100,000","","0428","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"H94","BX.PIS PROV.14 RESC","","3","1","100,000","","0429","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"I00","HRS.TRABALHADAS","","3","1","100,000","","0638","H","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"I05","HRS.ABONADAS","","3","1","100,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"I10","HRS.NAO REALIZADAS","","3","1","100,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"I15","HRS.NAO REALIZ.NOT","","3","1","100,000","","","H","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","A-**************************************","A","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"I20","DIAS TRABALHADOS","","3","1","100,000","","0989","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"I25","DIAS DESCANSO","","3","1","100,000","","0990","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"I30","SALARIO BASE","","3","1","100,000","","0318","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"I35","LIQUIDO ADIANTAMENTO","","3","1","100,000","","0546","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"I40","LIQUIDO 1A PARC.13","","3","1","100,000","","0678","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"I45","LIQUIDO 13 SALARIO","","3","1","100,000","","0021","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","S","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"I50","LIQUIDO PLR","","3","1","100,000","","0836","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"I55","LIQUIDO RRA","","3","1","100,000","","0977","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"I57","LIQUIDO RRA 13 SAL","","3","1","100,000","","0982","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})
	aAdd(aRet,{Space(10),"I60","LIQUIDO","","3","1","100,000","","0047","V","N","9","N","0,01","999999999,99","0,01","999999999,99","N","N","2","N","N","N","N","N","N","1","N","1","1","N","1","N","1","N","N","N","N","N","N","","N","N","N","","N","N","N","","N","2","N","**************************N-************","N","N","","N","N","2","2","","","","","","","","","2","1","","00","00","00","00","","","","","","","","","","","2","","2",.F.})

	aEval(aRet,{|x|x[4] := x[3]}) //Igual descrição detalhada e descrição.

Return aRet

Static Function fVldGrp(aLogFil)

fGrpSRA(@aLogFil)

Return

/*/{Protheus.doc} fGrpSRA
Valida os grupos de campos da tabela SRA
@author allyson.mesashi
@since 10/02/2022
/*/
Static Function fGrpSRA(aLogFil)

Local aCampos	:= { {"RA_CC", "004"}, {"RA_MAT", "121"}, {"RA_FILIAL", "033"}, {"RA_ITEM", "005"}, {"RA_CLVL", "006"} }
Local aLogSRA	:= {}
Local aLogSXG 	:= {}
Local aTamSRA	:= {}
Local lIncons	:= .F.
Local nTamSX3	:= 0
Local nCont		:= 0

For nCont := 1 To Len(aCampos)
	nTamSX3 := TamSX3(aCampos[nCont][1])[1]
	//Forçado para não dar error log em TamSXG
	DbSelectArea("SRA")
	If nTamSX3 != TamSXG(aCampos[nCont][2])[1]
		lIncons	:= .T.
		aAdd(aLogSXG, aCampos[nCont][1])
	EndIf
	aAdd(aTamSRA, nTamSX3)
Next

If Len(SRA->RA_CC) != aTamSRA[1]
	lIncons	:= .T.
	aAdd(aLogSRA, "RA_CC")
EndIf
If Len(SRA->RA_MAT) != aTamSRA[2]
	lIncons	:= .T.
	aAdd(aLogSRA, "RA_MAT")
EndIf
If Len(SRA->RA_FILIAL) != aTamSRA[3]
	lIncons	:= .T.
	aAdd(aLogSRA, "RA_FILIAL")
EndIf
If Len(SRA->RA_ITEM) != aTamSRA[4]
	lIncons	:= .T.
	aAdd(aLogSRA, "RA_ITEM")
EndIf
If Len(SRA->RA_CLVL) != aTamSRA[5]
	lIncons	:= .T.
	aAdd(aLogSRA, "RA_CLVL")
EndIf

If lIncons
	If !Empty(aLogSXG)
		aAdd(aLogFil, Space(9) + STR0096)//"Divergência(s) no tamanho do Grupo de Campos x SX3: "
		For nCont := 1 To Len(aLogSXG)
			aAdd(aLogFil, Space(12) + STR0097 + aLogSXG[nCont] )//"Campo : "
		Next nCont
	EndIf

	If !Empty(aLogSRA)
		aAdd(aLogFil, Space(9) + STR0098)//"Divergência(s) no tamanho do SX3 x tabela SRA: "
		For nCont := 1 To Len(aLogSRA)
			aAdd(aLogFil, Space(12) + STR0097 + aLogSRA[nCont] )//"Campo : "
		Next nCont
	EndIf
Else
	aAdd(aLogFil, Space(9) + STR0116)//"Não há inconsistência no Grupo de Campos x SX3 x tabela SRA"
	aAdd(aLogFil, "")
EndIf

Return

/*/{Protheus.doc} fGrpGPE
	Exibe as tabelas do grupo GPE
	@type  static Function
	@author gustavo.hbaptista
	@since 11/01/2022
/*/
Static function fGrpGPE(aLogFil)

	Local cAlias := getNextAlias()

	BeginSQL Alias cAlias
		Select X2_CHAVE CHAVE
		From %table:SX2% SX2
		WHERE SX2.%NotDel%
		and X2_MODULO = '7'
	EndSql

	nP+=1

	While (cAlias)->(!EOF())

		aAdd(aLogFil,Space(6) + STR0107 +Alltrim((cAlias)->(CHAVE))) //"Tabela: "
		aAdd(aLogFil,Space(9) + STR0108 + iif(FWModeAccess( (cAlias)->(CHAVE), 3)=='C','Compartilhado','Exclusivo'))//"Ac. Filial: "
		aAdd(aLogFil,Space(9) + STR0109 +iif(FWModeAccess( (cAlias)->(CHAVE), 2)=='C','Compartilhado','Exclusivo'))//"Ac. Unidade: "
		aAdd(aLogFil,Space(9) + STR0110 +iif(FWModeAccess( (cAlias)->(CHAVE), 1)=='C','Compartilhado','Exclusivo'))//"Ac. Empresa: "

		(cAlias)->(dbSkip())
	EndDo


Return
