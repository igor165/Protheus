#Include 'Protheus.ch'
#Include 'mnta035.ch'
#Include 'FWMVCDef.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} MNTA035
Programa de Cadastro de Atraso da Execu��o da O.S
@author Thiago Olis Machado
@since  17/04/2001
@version 4.0
@obs Reescrito para MVC - Douglas Constancio
@since 08/01/2018
/*/
//-------------------------------------------------------------------
Function MNTA035()

    //Guarda conte�do e declara vari�veis padr�es
    Local aNGBEGINPRM := NGBEGINPRM()
	Local cExprFilTop := ""

    Local aArea   := GetArea()
    Local cFunBkp := FunName()
    Local oBrowse

    Private aRotina := {}

    SetFunName("MNTA035")

    If cFunBkp == "MNTA400"
        cExprFilTop := "TPL->TPL_FILIAL == " + ValToSql(xFilial("TPL")) + " .And. TPL->TPL_ORDEM = " + ValToSql(STJ->TJ_ORDEM)
    EndIf

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("TPL")
    oBrowse:SetDescription(STR0006)
    oBrowse:SetFilterDefault(cExprFilTop)
    oBrowse:SetMenuDef("MNTA035")
    oBrowse:Activate()

    SetFunName(cFunBkp)
    RestArea(aArea)

	//Devolve variaveis armazenadas (NGRIGHTCLICK)
	NGRETURNPRM(aNGBEGINPRM)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Defini��o do Menu (padr�o MVC).
@author Douglas Constancio
@since 08/01/2018
@return aRotina array com o Menu MVC
/*/
//---------------------------------------------------------------------
Static Function MenuDef()

    aRotina := {}

    ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.MNTA035' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.MNTA035' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.MNTA035' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.MNTA035' OPERATION MODEL_OPERATION_DELETE ACCESS 3 //OPERATION 5

Return aRotina

//---------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do Modelo (padr�o MVC).
@author Douglas Constancio
@since 08/01/2018
@return oModel objeto do Modelo MVC
/*/
//---------------------------------------------------------------------
Static Function ModelDef()

    Local oModel  := Nil
    Local cFunBkp := IIf(IsInCallStack("MNTA400"),"MNTA400", FunName())
    Local oStTPL  := FWFormStruct(1, "TPL")

    // Inicializa o campo do Codigo do Bem se chamado por Click da Direita
    oStTPL:SetProperty("TPL_ORDEM", MODEL_FIELD_INIT, IIf(cFunBkp == "MNTA400",{|| STJ->TJ_ORDEM},))
    oStTPL:SetProperty("TPL_ORDEM", MODEL_FIELD_WHEN, IIf(cFunBkp == "MNTA400",{|x| .F.},))
    oStTPL:SetProperty("TPL_ORDEM", MODEL_FIELD_NOUPD, .T.)

    oModel := MPFormModel():New("MNTA035",{|oModel| fValidPre(oModel)}, {|oModel| ValidInfo(oModel)},,)

    oModel:AddFields("TPLMASTER",,oStTPL)
    oModel:SetPrimaryKey({'TPL_FILIAL', 'TPL_ORDEM', 'TPL_CODMOT', 'DTOS(TPL_DTINIC)', 'TPL_HOINIC', 'DTOS(TPL_DTFIM)', 'TPL_HOFIM'})
    oModel:SetDescription(STR0006) // Atraso na Execu��o da O.S
    oModel:GetModel("TPLMASTER"):SetDescription(STR0026 + STR0006)

Return oModel

//---------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o da View (padr�o MVC).
@author Douglas Constancio
@since 08/01/2018
@return oView objeto da View MVC
/*/
//---------------------------------------------------------------------
Static Function ViewDef()

    Local aStruTPL := TPL->(DbStruct())

    //Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
    Local oModel := FWLoadModel("MNTA035")

    //Cria��o da estrutura de dados utilizada na interface
    Local oStTPL := FWFormStruct(2, "TPL")

    //Criando oView como nulo
    Local oView := Nil

    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("MNTA035", oStTPL, "TPLMASTER")
    oView:CreateHorizontalBox("TELA", 100)
    oView:SetOwnerView("MNTA035", "TELA")

    //Inclus�o de itens nas A��es Relacionadas de acordo com O NGRightClick
    NGMVCUserBtn(oView)

Return oView

//---------------------------------------------------------------------
/*/{Protheus.doc} ValidInfo
Valida��o ao confirmar tela

@author Douglas Constancio
@since 27/12/2017
@version P12
@return lRet L�gico
/*/
//---------------------------------------------------------------------
Static Function ValidInfo(oModel)

    Local aArea  := GetArea()
    Local aRet   := {}
    Local lRet   := .T.
    Local nOpc   := oModel:GetOperation()
	Local nRecno := TPL->(Recno())

	Local oModelTPL := oModel:GetModel("TPLMASTER")

	// Vari�veis com os valores dos campos do Modelo
	Local cOrdemTPL := oModelTPL:GetValue("TPL_ORDEM")
    Local cMotAtras := oModelTPL:GetValue("TPL_CODMOT")
    Local dDataIni  := oModelTPL:GetValue("TPL_DTINIC")
    Local cHoraIni  := oModelTPL:GetValue("TPL_HOINIC")
    Local dDataFim  := oModelTPL:GetValue("TPL_DTFIM")
    Local cHoraFim  := oModelTPL:GetValue("TPL_HOFIM")

	// Aplica valida��es de Inclus�o e Altera��o
	If nOpc == MODEL_OPERATION_INSERT .Or. nOpc == MODEL_OPERATION_UPDATE

		If AllTrim(oModelTPL:GetValue("TPL_HOFIM")) == ":"
			oModelTPL:SetValue("TPL_HOFIM", "")
		EndIf

		aRet := NGCKINTDAT(cOrdemTPL, cMotAtras, dDataIni, cHoraIni, dDataFim, cHoraFim, .T., nRecno, nOpc)
		If !aRet[1]
			lRet := .F.
		EndIf
	EndIf

    If oModel:GetOperation() == MODEL_OPERATION_DELETE
        lRet  := fValidPre(oModel)
    EndIf

    RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} NGCKINTDAT()
Testa os intervalos aceit�veis de datas e horas para a inclus�o de
motivos de atraso da O.S.

@author �werton Cercal
@since 14/05/2015
@version 3.0
@param  cOrdem	- C�digo da O.S.						-Obrigat�rio
		cMotivo	- C�digo do Motivo						-Obrigat�rio
		dVDTIni	- Data In�cio							-Obrigat�rio
		cVHIni	- Hora In�cio							-Obrigat�rio
		dVDTFim	- Data Fim								-Opcional
		cVHFim	- Hora Fim								-Opcional
		lTipSai	- Indica se h� sa�da de erro na tela	-Obrigat�rio
        nReg	- Indica o endere�o l�gico alterado		-Obrigat�rio
/*/
//---------------------------------------------------------------------
Function NGCKINTDAT(cOrdem, cMotivo, dVDTIni, cVHIni, dVDTFim, cVHFim, lTipSai, nReg, nOpcx)

	Local aVRet     := {}
	Local cMens     := ""
	Local cMena     := STR0007 //"N�o informada"
	Local lMens     := IIf(lTipSai = Nil, .T., lTipSai)
	Local lProbl    := .F.
    Local cHrIniOs  := ""
    Local dDtIniOs  := StoD("")

	dbSelectArea("TPL")
	dbSetOrder(1)
	If dbSeek(xFilial("TPL") + cOrdem + cMotivo)
		While !EoF() .And. TPL->TPL_FILIAL == xFilial("TPL") .And. TPL->TPL_ORDEM  == cOrdem .And. TPL->TPL_CODMOT == cMotivo
			If Empty(TPL->TPL_DTFIM) .And. (nOpcx == 3 .Or. nReg <> Recno())
				cMens := STR0030 + CRLF + CRLF + STR0009 + cOrdem + CRLF + STR0010 + cMotivo + CRLF + STR0011 + DToC(dVDTIni);
				+ CRLF + CRLF + STR0031
				Exit
			Endif
			dbSkip()
		EndDo
	EndIf

    If dbSeek(xFilial("TPL") + cOrdem + cMotivo + DtoS(dVDTIni) + cVHIni) .And. nOpcx == 3
        cMens := STR0017 //"Registro informado j� existe"
    EndIf

	If Empty(cMens) .And. AllTrim(cVHFim) == ":"
		cVHFim := ""
	EndIf

	If Empty(cMens) .And. Empty(cOrdem)
		cMens := STR0009 + cMena	//"Ordem "
	EndIf

	If Empty(cMens) .And. Empty(cMotivo)
		cMens := STR0010 + cMena	//"Motivo "
	EndIf

	If Empty(cMens) .And. Empty(dVDTIni)
		cMens := STR0011 + cMena	//"Data In�cio "
	EndIf

	If Empty(cMens) .And. Empty(cVHIni)
		cMens := STR0012 + cMena //"Hora In�cio "
	EndIf

	If Empty(cMens) .And. Empty(dVDTFim) .And. !Empty(cVHFim)
		cMens := STR0013 + cMena //"Data Fim"
	EndIf

	If Empty(cMens) .And. !Empty(dVDTFim) .And. Empty(cVHFim)
		cMens := STR0014 + cMena //"Hora Fim"
	EndIf

	If Empty(cMens) .And. !Empty(dVDTIni) .And. !Empty(dVDTFim)
		If dVDTFim < dVDTIni
			cMens := STR0015	//"Data Fim dever� ser maior ou igual a Data In�cio. "
		ElseIf dVDTFim == dVDTIni .And. cVHFim <= cVHIni
			cMens := STR0016	//"Hora Fim dever� ser maior que a Hora In�cio. "
		EndIf
	EndIf

    If Empty(cMens)
        dbSelectArea("STJ")
        dbSetOrder(1)
        If dbSeek(xFilial("STJ")+cOrdem)
            dDtIniOs := STJ->TJ_DTORIGI
            If STJ->TJ_HORACO1 <> ""
                cHrIniOs := STJ->TJ_HORACO1
            EndIf
        EndIf

        If dVDTIni < dDtIniOs
            If cVHIni < cHrIniOs
                cMens := STR0024 + cOrdem
            EndIf
            cMens := STR0025 + cOrdem
        EndIf
    EndIf

    If !Empty(cMens)
		aVRet := {.F., cMens}
	Else
		dbSelectArea("TPL")
		dbSetOrder(1)

		If dbSeek(xFilial("TPL") + cOrdem + cMotivo + DTOS(dVDTIni) + cVHIni + DTOS(dVDTFim) + cVHFim) .And. Recno() <> nReg
			aVRet := {.F., STR0017}	//"Registro informado j� existe"*/
        Else
			aVRet := {.T., STR0018}	//"Data e hora de avalia��o est�o fora do Intervalo"
			If dbSeek(xFilial("TPL") + cOrdem + cMotivo)
				While !EoF() .And. TPL->TPL_FILIAL == xFILIAL("TPL") .And. TPL->TPL_ORDEM  == cOrdem .And.;
						TPL->TPL_CODMOT == cMotivo .And. !lPROBL

					If nReg > 0 .And. RecNo() = nReg
						dbSelectArea("TPL")
						dbSkip()
						Loop
					Endif

					If dVDTFim < TPL->TPL_DTFIM
						If dVDTFim == TPL->TPL_DTINIC
							If cVHFim >= TPL->TPL_HOINIC
								lProbl := .T.
								aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
							EndIf
						ElseIf dVDTIni > TPL->TPL_DTINIC
							lProbl := .T.
							aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
						ElseIf dVDTFim > TPL->TPL_DTINIC
							lProbl := .T.
							aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
						EndIf
					Else
						If dVDTFim > TPL->TPL_DTFIM
							If dVDTIni == TPL->TPL_DTFIM
								If cVHIni <= TPL->TPL_HOFIM
									lProbl := .T.
									aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
								EndIf
							Else
								If dVDTIni < TPL->TPL_DTFIM
									lProbl := .T.
									aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
								EndIf
							EndIf
						Else
							If dVDTIni > TPL->TPL_DTINIC
								If dVDTFim == TPL->TPL_DTFIM
									If dVDTIni == TPL->TPL_DTFIM
										If cVHIni <= TPL->TPL_HOFIM
											lProbl := .T.
											aVRet := {.F., STR0019} //"J� existe registro dentro do per�odo informado"
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf

					If dVDTIni < TPL->TPL_DTINIC
						If dVDTFim == TPL->TPL_DTINIC
							If cVHFim >= TPL->TPL_HOINIC
								lProbl := .T.
								aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
							EndIf
						Else
							If dVDTFim == TPL->TPL_DTFIM
								lProbl := .T.
								aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
							EndIf
						EndIf
					Else
						If dVDTIni > TPL->TPL_DTINIC
							If dVDTIni <> TPL->TPL_DTFIM
								If dVDTFim == TPL->TPL_DTFIM
									lProbl := .T.
									aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
								EndIf
	                   	EndIf
						Else
							If dVDTIni == TPL->TPL_DTINIC
								If dVDTFim == TPL->TPL_DTINIC
								Else
									If dVDTFim < TPL->TPL_DTFIM
										lProbl := .T.
										aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf

					If dVDTIni = TPL->TPL_DTINIC .And. dVDTFim = TPL->TPL_DTFIM
						If TPL->TPL_DTINIC == TPL->TPL_DTFIM	//Datas Iguais, Mesmo Dia
							If cVHFim >= TPL->TPL_HOINIC	//In�cio de Arquivo
								If cVHIni < TPL->TPL_HOINIC
									lProbl := .T.
									aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
								EndIf
							EndIf

							If cVHIni <= TPL->TPL_HOFIM	//Final de Arquivo
								If cVHFim > TPL->TPL_HOFIM
									lProbl := .T.
									aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
								EndIf
							EndIf

							If cVHIni >= TPL->TPL_HOINIC
								If cVHFim <= TPL->TPL_HOFIM
									lProbl := .T.
									aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
								EndIf
							EndIf
						Else //Datas Iguais, Dias Diferentes
							If cVHIni >= TPL->TPL_HOINIC
								lProbl := .T.
								aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
							Else
								If !Empty(cVHFim) .And. cVHFim <= TPL->TPL_HOFIM
									lProbl := .T.
									aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
								EndIf
							EndIf

							If cVHIni <= TPL->TPL_HOINIC .And. (!Empty(cVHFim) .And. cVHFim >= TPL->TPL_HOFIM)
								lProbl := .T.
								aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
							EndIf
						EndIf
					Else
						If dVDTIni == TPL->TPL_DTINIC .And. dVDTFim == TPL->TPL_DTINIC
							If cVHFim >= TPL->TPL_HOINIC
								lProbl := .T.
								aVRet := {.F., STR0019}	//"J� existe registro dentro do per�odo informado"
							EndIf
						EndIf
					EndIf

					dbSelectArea("TPL")
					dbSkip()
				EndDo
			EndIf
		EndIf
	EndIf

	If nReg > 0

	   dbSelectArea("TPL")
	   dbGoto(nReg)

	EndIf

	If lMens
		If !aVRET[1]
			Help(" ",1,STR0020,,aVRET[2],3,1) //"N�O CONFORMIDADE"
            aVRET[1] := .F.
		Else
			 aVRET[1] := .T.
		EndIf
	EndIf

Return aVRet

//---------------------------------------------------------------------
/*/{Protheus.doc} fValidPre
Valida��o ao executar a tela

@author Douglas Constancio
@since 10/01/2018
@version P12
/*/
//---------------------------------------------------------------------
Function fValidPre(oModel)

    Local aArea := GetArea()
    Local nOperation := oModel:GetOperation()
    Local lRet := .T.

    If nOperation == MODEL_OPERATION_UPDATE
        dbSelectArea("STJ")
        dbSetOrder(1)
        If dbSeek(xFilial("STJ") + TPL->TPL_ORDEM)
            If STJ->TJ_SITUACA <> "L" .Or. STJ->TJ_TERMINO <> "N"
                Help(" ",1,STR0028,,STR0027, 3, 1) //ATEN��O
                lRet := .F.
            EndIf
        EndIf
    ElseIf nOperation == MODEL_OPERATION_DELETE
        dbSelectArea("STJ")
        dbSetOrder(1)
        If dbSeek(xFilial("STJ") + TPL->TPL_ORDEM)
            If STJ->TJ_TERMINO == "S"
                Help(" ",1,STR0028,,STR0029, 3, 1) //ATEN��O
                lRet := .F.
            EndIf
        EndIf
    EndIf

    RestArea(aArea)

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} NGCHKORD()
Aplica valida��o de Ordem de Sevi�o para o campo TPL_ORDEM.
- Valida se a OS. foi liberada e n�o � finalizada

@author Douglas Constancio
@since 15/01/2018
@version 1.0
@return lRet
@use X3_VALID do campo TPL_ORDEM
/*/
//---------------------------------------------------------------------
Function NGCHKORD()

    Local lRet 	:= .T.
	Local aArea := GetArea()
    Local oModel := FWModelActive() //Ativa o Modelo utilizado.

    dbSelectArea("STJ")
    dbSetOrder(1)
    If dbSeek(xFilial("STJ") + oModel:GetValue( 'TPLMASTER', 'TPL_ORDEM'))
        If STJ->TJ_SITUACA <> "L" .Or. STJ->TJ_TERMINO <> "N"
            Help(" ",1,STR0020,,STR0021+" "+STR0022,3,1) //"N�O CONFORMIDADE"
            lRet := .F.
        EndIf
    EndIf

	RestArea(aArea)

Return lRet
