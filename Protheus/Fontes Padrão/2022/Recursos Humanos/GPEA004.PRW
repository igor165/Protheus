#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA004.CH"

/*/{Protheus.doc} GPEA004
//Correção fechamento co-participação para a DIRF
@author flavio.scorrea
@since 25/02/2018
@see (links_or_references)
/*/
Function GPEA004()

	Local aArea			:= GetArea()
	Local aCoors 		:= FWGetDialogSize(oMainWnd)
	Local oDlg
	Local oFWLayer
	Local oPanelUp
	Local aColsMark		:= {}
	Local lMarcar		:= .F.
	Local bIntegra		:= {|| GPM004IniProc(),oDlg:End() }
	Local bGera			:= {|| GPM004Ver() }
	Local aStruct 		:= RHO->(DbStruct())
	Local aFieldsFilter	:= {}
	Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F., {"",""} }) //[1]Acesso; [2]Ofusca; [3]Mensagem
	Local aFldRel		:= {"RA_NOME", "RA_RACACOR"}
	Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
	Local nI			:= 1

	For nI := 1 To Len(aStruct)
		Aadd(aFieldsFilter, { aStruct[nI, 1], aStruct[nI, 1], aStruct[nI, 2], aStruct[nI, 3], aStruct[nI, 4],})
	Next nI

	Private aRotMark   	:= {}
	Private cAliasMark 	:= "TABAUX"
	Private oMark
	Private oTmpTable := Nil

	//Tratamento de acesso a Dados Sensíveis
	If lBlqAcesso
		//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
		Help(" ",1,aOfusca[3,1],,aOfusca[3,2],1,0)
		Return
	EndIf

	fCriaTmp()
	aColsMark:= fMntColsMark()
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] PIXEL

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg,.F.,.T.)
	oFWLayer:AddLine("UP",100,.F.)
	oFWLayer:AddCollumn("ALLRCJ", 100, .T., 'UP' )
	oPanelUp := oFWLayer:GetColPanel("ALLRCJ", 'UP' )

	oMark := FWMarkBrowse():New()
	oMark:SetAlias((cAliasMark))
	oMark:SetFields(aColsMark)
	oMark:SetOwner( oPanelUp )
	oMark:bAllMark := {|| SetMarkAll(oMark:Mark(), lMarcar := !lMarcar), oMark:Refresh(.T.)}

	// Define o campo que sera utilizado para a marcação
	oMark:SetFieldMark( 'TAB_OK')
	oMark:SetUseFilter(.T.)
	oMark:SetValid({||.T.})
	oMark:AddButton(STR0010, bGera,,,, .F., 2 ) //"Verificar"
	oMark:AddButton(STR0011, bIntegra,,,, .F., 2 ) //"Gerar Histórico"
	oMark:obrowse:odata:afieldsfilter := aFieldsFilter
	oMark:SetMenuDef("")

	oMark:Activate()

	ACTIVATE MSDIALOG oDlg

	oTmpTable:Delete()
	oTmpTable := Nil

	RestArea(aArea)

Return .T.

/*/{Protheus.doc} fMntColsMark
//Monta acols
@author flavio.scorrea
@since 25/02/2018
@see (links_or_references)
/*/
Static Function fMntColsMark()

	Local aArea		:= GetArea()
	Local aColsAux 	:=`{}
	Local aColsSX3	:= {}
	Local aCampos  	:= RHO->(dbStruct())
	Local nX		:= 0

	DbSelectArea("SX3")
	DbSetOrder(2)

	For nX := 1 to Len(aCampos)
		If SX3->( dbSeek(aCampos[nX,1]) )
		    aColsSX3 := {X3Titulo(), &("{||(cAliasMark)->"+(aCampos[nX,1])+"}"), SX3->X3_TIPO, SX3->X3_PICTURE,1,SX3->X3_TAMANHO,SX3->X3_DECIMAL,.F.,,,,,,,,1}
		    aAdd(aColsAux,aColsSX3)
		    aColsSX3 := {}
		EndIf
	Next nX

	RestArea(aArea)

Return aColsAux

/*/{Protheus.doc} fCriaTmp
//Cria tabela temporária
@author flavio.scorrea
@since 25/02/2018
@see (links_or_references)
/*/
Static Function fCriaTmp()

	Local aColumns	 := {}
	Local lRet		 := .F.
	Local aCampos  	:= RHO->(dbStruct())
	Local nI		:= 1

	If Select(cAliasMark) > 0
		DbSelectArea(cAliasMark)
		DbCloseArea()
	EndIf

	aAdd(aColumns, {"TAB_OK", "C", 02, 00})

	For nI := 1 To Len(aCampos)
		aAdd(aColumns, {aCampos[nI, 1], aCampos[nI, 2], aCampos[nI, 3], aCampos[nI, 4]})
	Next nI

	aAdd(aColumns, {"RECNORHO", "N", 10, 00})

	oTmpTable := FWTemporaryTable():New(cAliasMark)
	oTmpTable:SetFields( aColumns )
	oTmpTable:AddIndex("IND", {aCampos[1, 1], aCampos[2, 1]})
	oTmpTable:Create()

Return lRet

/*/{Protheus.doc} SetMarkAll
//Seleção de registros
@author flavio.scorrea
@since 25/02/2018
@see (links_or_references)
/*/
Static Function SetMarkAll(cMarca, lMarcar)

	Local aAreaMark  := (cAliasMark)->(GetArea())

	dbSelectArea(cAliasMark)
	(cAliasMark)->( dbGoTop() )

	While !(cAliasMark)->( Eof() )
		RecLock( (cAliasMark), .F. )
			(cAliasMark)->TAB_OK := IIf(lMarcar, cMarca, '  ')
		MsUnLock()

		(cAliasMark)->(dbSkip())

	EndDo

RestArea(aAreaMark)

/*/{Protheus.doc} GPM004IniProc
//Processamento dos registros selecionados
@author flavio.scorrea
@since 25/02/2018
@see (links_or_references)
/*/
Static Function GPM004IniProc()

	Local bProcesso		:= {|oSelf| GPM004Proc(oSelf)}
	Local cCadastro 	:= STR0001 //"Correção fechamento co-participação plano de saúde"
	Local cDescricao	:= STR0002 //"Este programa efetuará o fechamento de lançamentos de co-participação (RHO) para (RHP) que falharam anteriormente."

	tNewProcess():New( "GPEA004" , cCadastro , bProcesso , cDescricao , "",,,,,.T.)

	oMark:deactivate()

Return Nil

/*/{Protheus.doc} fBuscaDtPg
//Busca data de pagamento
@author flavio.scorrea
@since 25/02/2018
@see (links_or_references)
/*/
Static Function fBuscaDtPg(cAnoMes,cVerba, cFilFun,cMatFun)

	Local aArea		:= GetArea()
	Local dDtPag	:= CtoD("//")
	Local lRet		:= .F.

	dbSelectArea("SRA")
	SRA->(dbSetOrder(1))
	If SRA->(dbSeek(cFilFun+cMatFun))

		lRet := fPosPeriodo( xFilial("RCH",SRA->RA_FILIAL), SRA->RA_PROCES, cAnoMes,"" , If(SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar()),,,6,cAnomes)

		If !lRet
			lRet := fPosPeriodo( xFilial("RCH",SRA->RA_FILIAL), SRA->RA_PROCES, cAnoMes, "",  fGetCalcRot("C") ,,,6,cAnomes)
		EndIf

		If lRet
			dDtPag	:= RCH->RCH_DTPAGO
		EndIf

	EndIf

	RestArea(aArea)

Return(dDtPag)

/*/{Protheus.doc} GPM004Proc
//Processamento dos registros selecionados
@author flavio.scorrea
@since 25/02/2018
@see (links_or_references)
/*/
Static Function GPM004Proc(oSelf)

	Local cMarca 		:= oMark:Mark()
	Local dDtPag
	Local cAliasPLA
	Local nT			:= 1
	Local aCodFol		:= {}
	Local cFilAux		:= ""
	Local nTotReg		:= 0
	Local aCampos  		:= RHO->(dbStruct())
	Local aStruRHP 		:= RHP->(dbStruct())
	Local nRecno		:= 0

	DbSelectArea(cAliasMark)
	count to nTotReg
	(cAliasMark)->(DbGoTop())

	oSelf:SetRegua1(nTotReg)
	oSelf:SaveLog(STR0003 + " - " + STR0004) //"Fechamento Co-Participação"##"Inicio do processamento"

	While !(cAliasMark)->(Eof())
		oSelf:IncRegua1(STR0005 + " " + (cAliasMark)->RHO_FILIAL + " - " + (cAliasMark)->RHO_MAT) // Funcionário

		If oMark:IsMark(cMarca)
			dDtPag := cTod("  /  / ")

			If cFilAux <> (cAliasMark)->RHO_FILIAL
				Fp_CodFol(@aCodFol , (cAliasMark)->RHO_FILIAL, .T.)
				cFilAux := (cAliasMark)->RHO_FILIAL
			EndIf

			nRecno := 0

			//utilizado query por que não tem indice, apos criação do indice na 12.1.17, trocar pelo seek
			cAliasPLA := GetNextAlias()
			BeginSql alias cAliasPLA
				SELECT RHP_PD, R_E_C_N_O_ AS RECNO
				FROM %table:RHP% RHP
				WHERE RHP.RHP_FILIAL = %exp:(cAliasMark)->RHO_FILIAL%
				AND RHP.RHP_MAT    = %exp:(cAliasMark)->RHO_MAT%
				AND RHP.RHP_TPFORN = %exp:(cAliasMark)->RHO_TPFORN%
				AND RHP.RHP_CODFOR = %exp:(cAliasMark)->RHO_CODFOR%
				AND RHP.RHP_ORIGEM = %exp:(cAliasMark)->RHO_ORIGEM%
				AND RHP.RHP_PD	   = %exp:(cAliasMark)->RHO_PD%
				AND RHP.RHP_COMPPG = %exp:(cAliasMark)->RHO_COMPPG%
				AND RHP.RHP_CODIGO = %exp:(cAliasMark)->RHO_CODIGO%
				AND RHP.RHP_DTOCOR = %exp:(cAliasMark)->RHO_DTOCOR%
				AND RHP.RHP_TPLAN  = %exp:(cAliasMark)->RHO_TPLAN%
				AND RHP.%notDel%
			EndSql

			If !(lNovo := (cAliasPLA)->(eof()))
				nRecno := (cAliasPLA)->RECNO
			EndIf

			(cAliasPLA)->(dbCloseArea())

			If nRecno > 0
				RHP->(DbGoto(nRecno))
			EndIf

			RHP->(RecLock("RHP", lNovo))

			If Empty(RHP->RHP_DATPGT)
				//Busca a data de pagamento da folha do funcionario
				dDtPag			:= fBuscaDtPg((cAliasMark)->RHO_COMPPG, aCodFol[318, 1], (cAliasMark)->RHO_FILIAL, (cAliasMark)->RHO_MAT)
				RHP->RHP_DATPGT	:= dDtPag
			Endif

			For nT := 1 To Len( aCampos )
				cField		:= aCampos[nT, 1]
				cDestField 	:= "RHP" + Substr(cField, At("_", cField) )
				nExistFld 	:= aScan( aStruRHP, { |x| x[1] == cDestField }  )

				If nExistFld > 0
					RHP->( &cDestField ) := (cAliasMark)->( &cField )
				EndIf

			Next nT

			RHP->(MsUnlock())
		EndIf

		(cAliasMark)->(DbSkip())
	EndDo

	(cAliasMark)->(DbGoTop())

	oSelf:SaveLog(STR0003 + " - " + STR0006) //""Fechamento Co-Participação"##"Fim do processamento"

	SetMarkAll(oMark:Mark(),.F. )

	oMark:Refresh() //Atualiza markbrowse

Return Nil

/*/{Protheus.doc} GPM004Ver
//Carrega registros
@author flavio.scorrea
@since 25/02/2018
@see (links_or_references)
/*/
Static Function GPM004Ver

	Processa( {|| GPM004Carga( ) } )

Return

/*/{Protheus.doc} GPM004Ver
//Carrega registros
@author flavio.scorrea
@since 25/02/2018
@see (links_or_references)
/*/
Static Function GPM004Carga()

	Local aArea		:= GetArea()
	Local cAliasRHO	:= GetNextAlias()
	Local cAliasRHP
	Local aCampos  	:= RHO->(dbStruct())
	Local nI		:= 1
	Local nT		:= 1
	Local cAno		:= Alltrim(Str(Year(date())-1))
	Local cAnoAtual	:= Alltrim(Str(Year(date())))
	Local lTem		:= .F.

	DbSelectArea(cAliasMark)
	(cAliasMark)->(DbGotop())

	While !(cAliasMark)->(Eof() )
		RecLock(cAliasMark,.F.)
		(cAliasMark)->(__dbZap())
		(cAliasMark)->(msUnlock())
		(cAliasMark)->(dbSkip())
	End

	BeginSql alias cAliasRHO
		column RHO_DTOCOR as DATE
		SELECT RHO.R_E_C_N_O_ AS RECNORHO ,RHO.*
		FROM %table:RHO% RHO
		WHERE RHO.D_E_L_E_T_ = '*'
		AND RHO.RHO_COMPPG between %exp:cAno+'01'% and %exp:cAnoAtual+'12'%
	EndSql

	DbSelectArea(cAliasMark)

	While (cAliasRHO)->(!Eof())

		IncProc("Processando..")
		cAliasRHP	 := GetNextAlias()
		BeginSql alias cAliasRHP
				SELECT RHP_PD
					FROM %table:RHP% RHP

					WHERE RHP.RHP_FILIAL = %exp: (cAliasRHO)->RHO_FILIAL%
					AND RHP.RHP_MAT    = %exp: (cAliasRHO)->RHO_MAT%
					AND RHP.RHP_TPFORN = %exp: (cAliasRHO)->RHO_TPFORN%
					AND RHP.RHP_CODFOR = %exp: (cAliasRHO)->RHO_CODFOR%
					AND RHP.RHP_ORIGEM = %exp: (cAliasRHO)->RHO_ORIGEM%
					AND RHP.RHP_PD	   = %exp: (cAliasRHO)->RHO_PD%
					AND RHP.RHP_COMPPG = %exp: (cAliasRHO)->RHO_COMPPG%
					AND RHP.RHP_CODIGO = %exp: (cAliasRHO)->RHO_CODIGO%
					AND RHP.RHP_DTOCOR = %exp: (cAliasRHO)->RHO_DTOCOR%
					AND RHP.RHP_TPLAN  = %exp: (cAliasRHO)->RHO_TPLAN%
					AND RHP.%notDel%
		EndSql

		If (cAliasRHP)->(eof())
			lTem := .T.
			RecLock(cAliasMark,.T.)
			For nT := 1 To Len( aCampos )
				(cAliasMark)->( &(aCampos[nT, 1]) ) := (cAliasRHO)->( &(aCampos[nT, 1]) )
			Next nT
			(cAliasMark)->RECNORHO := (cAliasRHO)->RECNORHO

			(cAliasMark)->(MsUnLock())
		EndIf

		(cAliasRHP)->(dbCloseArea())
		(cAliasRHO)->(DbSkip())
	EndDo

	(cAliasRHO)->( dbCloseArea() )
	(cAliasMark)->(dbGotop())

	SetDtpag()

	If !lTem
		Aviso(STR0007, STR0008, {STR0009}) // "Atenção"## "Sem registros para processar" ## "OK"
	EndIf

	RestArea(aArea)

	oMark:Refresh(.T.)

Return

Static Function SetDtpag()

	Local aArea	:= GetArea()
	Local cAliasTmp

	cAliasTmp := GetNextAlias()

	BeginSql alias cAliasTmp
		SELECT RHP.R_E_C_N_O_ AS RECNO ,RHP.*
		FROM %table:RHP% RHP
		WHERE RHP.%notDel%
		AND RHP_DATPGT = ''
	EndSql

	While (cAliasTmp)->(!Eof())

		IncProc("Processando..")

		RHP->(dbGoto((cAliasTmp)->RECNO))
		RecLock("RHP", .F.)
			RHP->RHP_DATPGT := fBuscaDtPg(RHP->RHP_COMPPG, RHP->RHP_PD, RHP->RHP_FILIAL, RHP->RHP_MAT)
		RHP->(msUnlock())

		(cAliasTmp)->(DbSkip())

	EndDo

	(cAliasTmp)->(dbCloseArea())

	cAliasTmp := GetNextAlias()

	BeginSql alias cAliasTmp
		SELECT RHS.R_E_C_N_O_ AS RECNO ,RHS.*
		FROM %table:RHS% RHS
		WHERE RHS.%notDel%
		AND RHS_DATPGT = ''
	EndSql

	While (cAliasTmp)->(!Eof())
		IncProc("Processando..")
		RHS->(dbGoto((cAliasTmp)->RECNO))
		RecLock("RHS", .F.)
			RHS->RHS_DATPGT := fBuscaDtPg(RHS->RHS_COMPPG, RHS->RHS_PD, RHS->RHS_FILIAL, RHS->RHS_MAT)
		RHS->(msUnlock())
		(cAliasTmp)->(DbSkip())
	EndDo

	( cAliasTmp )->( dbCloseArea() )

	RestArea(aArea)

Return