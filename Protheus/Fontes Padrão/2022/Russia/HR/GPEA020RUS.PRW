#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA020.CH"

Static lGp020Auto:= SetRotAuto()
Static cEFDAviso
Static lMsg := .F.
//Integra็ใo com o TAF
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
Static cCatNTSV		:= If( Empty(SuperGetMv("MV_NTSV",,"")), "701|711|712|741|", SuperGetMv("MV_NTSV",, "701|711|712|741|") )
Static lMiddleware	:= If( Findfunction("fVerMW"), fVerMW(), .F. )
Static lGeraEvt		:= lIntTAF .Or. lMiddleware

/*
{Protheus.doc} GPEA020RUS()
    Russian localization of GPEA020 - Dependants

    @type Function
    @author dtereshenko
    @since 2020/07/30
    @version 12.1.23
*/
Function GPEA020RUS()
Return GPEA020()

/*
{Protheus.doc} MenuDef()
    Menu definition

    @type Function
    @author dtereshenko
    @since 2020/07/30
    @version 12.1.23
*/
Static Function MenuDef()
Return FWLoadMenuDef("GPEA020")

/*
{Protheus.doc} ModelDef()
    Model definition

    @type Function
    @author dtereshenko
    @since 2020/07/30
    @version 12.1.23
*/
Static Function ModelDef()
    Local oStructSRA
    Local oStructSRB
    Local oModel
    //Tratativa pra identificar o versionamento do eSocial
    Local cVersEnvio := ""
    Local aRetGPE := array(2)
    Local aRetTAF := array(2)
    Local cVersGPE := ""
    Local lVerBlq := If(ExistFunc("fVersEsoc"), fVersEsoc( "S2300", .F., @aRetGPE, @aRetTAF, @cVersEnvio, @cVersGPE ), .T.)

    If Empty(cVersGPE)
        cVersGPE := cVersEnvio
    EndIf

    oModel:= MpFormModel():New("GPEA020", /*Pre-Validacao*/, { || Gpea020ValPE() } /*Pos-Validacao*/, { |oModel| Gp020Grav( oModel,cVersEnvio ) } /*Commit*/, /*Cancel*/)

    oStructSRA := FWFormStruct(1,"SRA",{|cCampo| AllTrim(cCampo)+"|" $ "RA_FILIAL|RA_MAT|RA_NOMECMP|RA_ADMISSA|"})
    oModel:AddFields("GPEA020_SRA", /*cOwner*/, oStructSRA , /*Pre-Validacao*/, /*Pos-Validacao*/, /*Carga*/)
    oModel:GetModel("GPEA020_SRA"):SetOnlyView( .T. )
    oModel:GetModel("GPEA020_SRA"):SetOnlyQuery( .T. )

    If !IsInCallStack("FWMILEIMPORT")
        oStructSRA:SetProperty( 'RA_MAT'    ,MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, 'SRA->RA_MAT') )
        oStructSRA:SetProperty( 'RA_NOMECMP',MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, 'SRA->RA_NOMECMP') )
        oStructSRA:SetProperty( 'RA_ADMISSA',MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, 'SRA->RA_ADMISSA') )
    EndIf

    oStructSRB := FWFormStruct(1,"SRB")
    oModel:AddGrid("GPEA020_SRB", "GPEA020_SRA", oStructSRB , /*bLinePre*/, { |oGrid| Gp020LOk(oGrid,cVersEnvio) } /* bLinePost*/, /*bPre*/, { |oGrid| Gp020TOk(oGrid) } /*bPost*/, /*bLoad*/)
    oModel:GetModel('GPEA020_SRB'):SetOptional(.T.)

    If !lGp020Auto
        oStructSRB:RemoveField( "RB_MAT" ) // Remove campo do modelo de dados
    EndIf

    oModel:SetRelation("GPEA020_SRB", {{"RB_FILIAL",'xFilial("SRB",SRA->RA_FILIAL)'}, {"RB_MAT","RA_MAT"}}, SRB->(IndexKey()))

    //Funcao a ser chamada antes da ativacao do Modelo de Dados.
    //Pode ser utilizada para inibir a inicializacao do model.
    //Se o retorno for negativo, o Model nao sera exibido e a rotina sera abortada
    If !lGp020Auto
        oModel:SetVldActivate( { |oModel| G020VldIni(oModel,oModel:GetOperation(),lVerBlq,aRetGPE,aRetTAF) } )
    EndIf

Return oModel

/*
{Protheus.doc} ViewDef()
    View definition

    @type Function
    @author dtereshenko
    @since 2020/07/30
    @version 12.1.23
*/
Static Function ViewDef()
    Local oModel
    Local oStructSRA
    Local oStructSRB
    Local oView

    oModel := FwLoadModel("GPEA020")

    oView := FWFormView():New()

    oView:SetModel(oModel)

    oStructSRA := FWFormStruct(2,"SRA",{|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOMECMP|RA_ADMISSA|"})
    oStructSRA:SetNoFolder()

    oView:AddField( "GPEA020_SRA" , oStructSRA )

    oStructSRB := FWFormStruct(2,"SRB")
    oView:AddGrid(  "GPEA020_SRB" , oStructSRB )

    oStructSRB:RemoveField( "RB_MAT" )

    oView:SetViewProperty("GPEA020_SRA","OnlyView") //Somente visualizacao. Nao permite edicao dos campos do cabecalho (SRA)

    oView:CreateHorizontalBox("FORMFIELD",15)
    oView:CreateHorizontalBox("GRID"     ,85)

    oView:SetOwnerView( "GPEA020_SRA","FORMFIELD")
    oView:SetOwnerView( "GPEA020_SRB","GRID")

    oView:AddIncrementField("GPEA020_SRB","RB_COD")

    oView:SetCloseOnOk( { |oView| Gp020ClsOk( oView ) } )

Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณG020VldIniบAutor  ณLeandro Drumond     บ Data ณ  03/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao antes da ativacao do modelo de dados   			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function G020VldIni(oModel,nOperacao,lBloqExec,aRetGPE,aRetTAF)
    Local aArea     := GetArea()
    Local lRet 		:= .T.
    Local cMsgRet	:= ""
    Local cRetGPE 	:= ""

    Default lBloqExec := .T.
    Default aRetGPE	  := array(2)
    Default aRetTAF	  := array(2)

    If len(aRetGPE) >= 2
        cRetGPE := aRetGPE[2]
    EndIf

    cMsgRet	:= STRTRAN(STRTRAN(STR0099,"#GPE#",cRetGPE),"#TAF#",cRetGPE)

    If !(IsInCallStack("CFG600lmdl")) .And. nOperacao == 3
        oModel:SetOperation( 4 )
    EndIf

    //--------------------------------------------------------------
    //Verifica se o Arquivo Esta Vazio
    //--------------------------------------------------------------
    If !ChkVazio("SRA")
        Return .F.
    EndIf

    If nOperacao == MODEL_OPERATION_DELETE .and. Gp020SrbNull()
        If lGp020Auto
            AutoGrLog(STR0044)
        Else
            Help(,,'HELP',, STR0044,1,0 ) //"Nใo existe nenhum dependente cadastrado para este funcionแrio."
        EndIf
        lRet := .F.
    EndIf

    RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGp020SrbNullบAutor  ณLeandro Drumond   บ Data ณ  30/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se existe registro na SRB para funcionario atual.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Gp020SrbNull()
    Local aArea := GetArea()
    Local lRet	:= .T.

    DbSelectArea("SRB")

    If DbSeek(xFilial("SRA")+SRA->RA_MAT)
        lRet := .F.
    EndIf

    RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGp020LOk  บAutor  ณLeandro Drumond     บ Data ณ  03/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao de bLinePos. Valida a troca de linha do Grid	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Gp020LOk(oGrid,cVersGPE)
	Local cDia      := If (Month(dDataBase) == 2 , "28" , "30")
	Local lRet 		:= .T.
	Local lMes		:= .T.
	Local dAniver 	:= CtoD("")
	Local ddacalc   := CtoD("")
	Local dFaz14Anos:= CtoD("")
	Local oStruct   := oGrid:GetStruct()
	Local aCampos	:= oStruct:GetFields()
	Local nPosBaixa	:= oGrid:GetIdField("RB_DTBAIXA")
	Local nPosEntreg:= oGrid:GetIdField("RB_DTENTRA")
	Local nPosNasc	:= oGrid:GetIdField("RB_DTNASC")
	Local nPosTipSF	:= oGrid:GetIdField("RB_TIPSF")
	Local nPosIniAM	:= oGrid:GetIdField("RB_DTINIAM")
	Local nPosFimAM	:= oGrid:GetIdField("RB_DTFIMAM")
	Local nPosIniAO	:= oGrid:GetIdField("RB_DTINIAO")
	Local nPosFimAO	:= oGrid:GetIdField("RB_DTFIMAO")
	Local nPosCPF	:= oGrid:GetIdField("RB_CIC")
	Local nPosPS	:= oGrid:GetIdField("RB_PLSAUDE")
	Local cPerRef	:= AnoMes(dDataBase)
	Local nIdade 	:= 0
	Local nx		:= 0
	Local cCodDep	:= oGrid:GetValue("RB_COD")
	Local cDepIR	:= ""
	Local aEstb		:= {}
	Local nPosEstb	:= 0
	Local cTpInscr	:= ""
	Local cInscr	:= ""
	Local cCPF_Dep	:= ""
	Local nGrid		:= 0
	Local nG		:= 0

	Default cVersGPE:= "2.2"

	If cPaisLoc $ 'BRA|RUS'
		cDepIR := oGrid:GetValue("RB_TIPIR")
	EndIf

	ddacalc :=CtoD(cDia+"/"+StrZero(Month(dDataBase),2)+"/"+StrZero(Year(dDataBase),4), "DDMMYY" ) //Atualizacao da Variavel ddacalc para nใo utilizar o DDATABASE

	Begin Sequence

		// VERIFICA O COMPARTILHAMENTO DAS TABELAS C9V/C9Y/CUP/T3L/CRQ/T80/T90/T1U/T1V/TOF/CUU/T3A E COMPARA
		// AO DA TABELA SRA.
		If Findfunction("fVldCmpTab") .And. !fVldCmpTab()
			lRet := .F.
		EndIf

		If lRet .And. !oGrid:IsDeleted()

			For nx := 1 To Len(aCampos)

				If lRet .And. Empty(oGrid:GetValue(Trim(aCampos[nx][MODEL_FIELD_IDFIELD])))

					nIdade   := CALC_IDADE(dDataBase,oGrid:GetValue("RB_DTNASC"))
					dAniver  := StrZero(Year(dDataBase),4)+StrZero(Month(oGrid:GetValue("RB_DTNASC")),2)

					If cPaisLoc $ 'BRA|RUS'

						If ( MesAno(ddacalc) > MesAno(oGrid:GetValue("RB_DTNASC"),14) )
							lMes := .F.
						EndIf

						dFaz14Anos := YearSum( oGrid:GetValue("RB_DTNASC"), 14 )

						If ( ((oGrid:GetValue("RB_TIPIR") == "2" .And. nIdade > 21) .and. !lMes) .Or.;
						((oGrid:GetValue("RB_TIPIR") == "3" .And. nIdade > 24) .and. !lMes) ) .and. lRet

							ShowError("A020STIPIR", .T.,,.T.)
							lRet := .F.
							Exit
						EndIf

						If nPosTipSF > 0
							If oGrid:GetValue("RB_TIPSF") == "2" .And. nIdade >= 14 .And. MesAno(ddacalc) > MesAno(dFaz14Anos) .and. lRet
								ShowError(OemToAnsi(STR0079))
								lRet := .F.
								Exit
							EndIf
						EndIf

						// Se exibe aviso de inconsistencia eSocial
						If Empty(oGrid:GetValue("RB_TPDEP"))
							If lRet .And. cEFDAviso <> "2" .And. !(SRA->RA_CATEFD $ cCatNTSV)
								// "O campo (TP Dep.eSoci) - 'Tipo de Dependente eSocial' nao foi informado."###"Atencao"

								//-- Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
								ShowError(OemToAnsi(STR0056), Iif(cEFDAviso == "1",.T., .F.), OemToAnsi(STR0017))
								If cEFDAviso == "1"
									lRet := .F.
								EndIf
								lGeraEvt := .F.
								Exit
							Else
								lGeraEvt := .F.
							EndIf
						EndIf

					ElseIf cPaisLoc $ "ARG|RUS"	//# Argentina
						If oGrid:GetValue("RB_TIPSF") == "2" .And. (nIdade > 18 .Or. nIdade == 18 .And.;
							MesAno(ddacalc) > dAniver) .And. lRet
							ShowError("A020STIPSF", .T.,,.T.)
							lRet := .F.
							Exit
						EndIf
					ElseIf cPaisLoc $ "ANG"	//# Angola
						If oGrid:GetValue("RB_TIPSF") == "2" .And. nIdade > 18 .And. lRet
							ShowError("A020STIPSF", .T.,,.T.)
							lRet := .F.
							Exit
						EndIf
					EndIf
					If Trim(aCampos[nx][MODEL_FIELD_IDFIELD]) == "RB_NOME" .and. lRet
						ShowError("A020SNOME", .T.,,.T.)
						lRet := .F.
						Exit
					EndIf
					If Trim(aCampos[nx][MODEL_FIELD_IDFIELD]) == "RB_DTNASC" .and. lRet
						ShowError("A020SDTNAS", .T.,,.T.)
						lRet := .F.
						Exit
					EndIf
					If Trim(aCampos[nx][MODEL_FIELD_IDFIELD]) == "RB_SEXO" .and. lRet
						ShowError("A020SSEXO", .T.,,.T.)
						lRet := .F.
						Exit
					EndIf
					If Trim(aCampos[nx][MODEL_FIELD_IDFIELD]) == "RB_GRAUPAR" .and. lRet
						ShowError("A020SGRAUP", .T.,,.T.)
						lRet := .F.
						Exit
					EndIf
					If Trim(aCampos[nx][MODEL_FIELD_IDFIELD]) == "RB_TIPIR" .and. lRet
						ShowError("A020STIPIR", .T.,,.T.)
						lRet := .F.
						Exit
					EndIf
					If Trim(aCampos[nx][MODEL_FIELD_IDFIELD]) == "RB_TIPSF" .and. lRet
						ShowError("A020STIPSF", .T.,,.T.)
						lRet := .F.
						Exit
					EndIf

					If lRet .And. Trim(aCampos[nx][MODEL_FIELD_IDFIELD]) == "RB_TIPAMED" .and. oGrid:GetValue("RB_TPDEPAM") $ "1|2"
						ShowError("A020STPAM", .T.,,.T.) //Tipo de Assist๊ncia M้dica em branco
						lRet := .F.
						Exit
					EndIf
					If lRet .And. Trim(aCampos[nx][MODEL_FIELD_IDFIELD]) == "RB_CODAMED" .and. oGrid:GetValue("RB_TPDEPAM") $ "1|2"
						ShowError("A020SCODAM", .T.,,.T.)//C๓digo do plano de Assist๊ncia M้dica em branco
						lRet := .F.
						Exit
					EndIf
					If lRet .And. Trim(aCampos[nx][MODEL_FIELD_IDFIELD]) == "RB_VBDESAM" .and. oGrid:GetValue("RB_TPDEPAM") $ "1|2"
						ShowError("A020SVERBAM", .T.,,.T.) //C๓digo da verba de desconto da Assist๊ncia M้dica em branco
						lRet := .F.
						Exit
					EndIf

					If lRet .And. Trim(aCampos[nx][MODEL_FIELD_IDFIELD]) == "RB_TPASODO" .and. oGrid:GetValue("RB_TPDPODO") $ "1|2"
						ShowError("A020STPAO", .T.,,.T.) //Tipo de Assist๊ncia Odontol๓gia em branco
						lRet := .F.
						Exit
					EndIf
					If lRet .And. Trim(aCampos[nx][MODEL_FIELD_IDFIELD]) == "RB_ASODONT" .and. oGrid:GetValue("RB_TPDPODO") $ "1|2"
						ShowError("A020SCODAO", .T.,,.T.)//C๓digo do plano de Assist๊ncia Odontol๓gia em branco
						lRet := .F.
						Exit
					EndIf
					If lRet .And. Trim(aCampos[nx][MODEL_FIELD_IDFIELD]) == "RB_VBDESAO" .and. oGrid:GetValue("RB_TPDPODO") $ "1|2"
						ShowError("A020SVERBAO", .T.,,.T.)//C๓digo da verba de desconto da Assist๊ncia Odontol๓gia em branco
						lRet := .F.
						Exit
					EndIf
					If lRet .And. Trim(aCampos[nx][MODEL_FIELD_IDFIELD]) == "RB_DEFP" .and. SRA->RA_TPPREVI == "2"
						ShowError(OemtoAnsi(STR0105), .T.,OemtoAnsi(STR0017))
						lRet := .F.
						Exit
					Endif
				EndIf
			Next nx

			If !lRet
				Break
			EndIf

			If lRet .And. nPosPs > 0 .And. oGrid:GetValue("RB_PLSAUDE") == "2"
				DbSelectArea("RHL")
				RHL->(DbSetOrder(2))
				RHL->(DbSeek( xFilial( "RHL" , xFilial("SRB") ) + SRA->RA_MAT + cCodDep ))
				If RHL->RHL_FILIAL == SRA->RA_FILIAL .And. RHL->RHL_MAT == SRA->RA_MAT .And. RHL->RHL_CODIGO == cCodDep .And. RHL->RHL_TPFORN == '1'
					cPerIni := Right(RHL->RHL_PERINI, 4) + Left(RHL->RHL_PERINI, 2)
					cPerFim := Right(RHL->RHL_PERFIM, 4) + Left(RHL->RHL_PERFIM, 2)
					If (cPerRef >= cPerIni .And. (Empty(RHL->RHL_PERFIM) .Or. cPerRef <= cPerFim ))
						//"O Dependente possui Plano de Sa๚de Ativo, nใo ้ possํvel alterar o campo 'Pl.Sa๚de' para 'Nใo'
						ShowError(OemtoAnsi(STR0065)+oGrid:GetValue("RB_COD")+ OemtoAnsi(STR0066), .T.,OemtoAnsi(STR0017))
						lRet:= .F.
						Break
					Endif
				Endif
			Endif

			If nPosBaixa > 0 .and. nPosEntreg > 0 .and. nPosNasc > 0
				If (!empty(oGrid:GetValue("RB_DTBAIXA")).and. oGrid:GetValue("RB_DTBAIXA") < oGrid:GetValue("RB_DTENTRA")) .and. lRet
					lRet := .F.
					ShowError(STR0016,.T.)//"Data da Baixa nao pode ser inferior a data de entrega!"
					Break
				EndIf
				If (( !Empty(oGrid:GetValue("RB_DTBAIXA")) .and. oGrid:GetValue("RB_DTBAIXA")< oGrid:GetValue("RB_DTNASC")) .or. (!empty(oGrid:GetValue("RB_DTENTRA")) .And. oGrid:GetValue("RB_DTENTRA") < oGrid:GetValue("RB_DTNASC"))) .and. lRet
					lRet := .F.
					ShowError(STR0018,.T.) //"Data da Baixa e Data de Entrega nao podem ser inferiores a data de Nascimento!"
					Break
				EndIf
			EndIf

			If lRet .and. nPosIniAM > 0 .and. nPosFimAM > 0
				If !Empty(oGrid:GetValue("RB_DTINIAM")) .and. !Empty(oGrid:GetValue("RB_DTFIMAM")) .and. oGrid:GetValue("RB_DTFIMAM") < oGrid:GetValue("RB_DTINIAM")
					lRet := .F.
					ShowError(STR0023,.T.)//"A data de encerramento da vig๊ncia do plano de assist๊ncia m้dica nใo pode ser inferior a data de inํcio."
					Break
				EndIf
			EndIf

			If lRet .and. nPosIniAO > 0 .and. nPosFimAO > 0
				If !Empty(oGrid:GetValue("RB_DTINIAO")) .and. !Empty(oGrid:GetValue("RB_DTFIMAO")) .and. oGrid:GetValue("RB_DTFIMAO") < oGrid:GetValue("RB_DTINIAO")
					lRet := .F.
					ShowError(STR0024,.T.)//"A data de encerramento da vig๊ncia do plano de assist๊ncia odontol๓gica nใo pode ser inferior a data de inํcio."
					Break
				EndIf
			EndIf

			If cPaisLoc $ 'BRA|RUS'
				If lRet .And. nPosCPF > 0 .and. nPosNasc > 0
					//Se for maior de 18 anos, apenas informa que CPF necessario mas nao obriga.
					If !(lInttaf .And. lMiddleware) .And. nIdade >= 18 .Or. (lInttaf .Or. lMiddleware) .And. oGrid:GetValue("RB_TIPIR") $ "123" .And. (cVersGPE >= "2.5.00" .OR. (cVersGPE >= '2.4.02' .And. cVersGPE < "2.5.00" .And. nIdade >= 8))
						If Empty(oGrid:GetValue("RB_CIC"))
							If(!lGp020Auto)
								If cEFDAviso == "1"
									ShowError(OemToAnsi( IIF(cVersGPE >= '2.5.00', STR0100,STR0096)),.T.)// eSocial: Preenchimento do CPF obrigat๓rio para idade maior ou igual a 12 anos e dependente de IR.
									lRet 	:= .F.
									Break
								Else
									If MsgNoYes( OemToAnsi( IIF(cVersGPE >= '2.5.00', STR0106, Iif(cVersGPE >= '2.4.02',STR0104, STR0060)) ) ) // "CPF do Dependente que possui idade maior ou igual a 8 anos cadastrado nใo foi Preenchido. Deseja Continuar?" , "CPF do Dependente maior de 18 anos cadastrado nใo foi Preenchido. Deseja Continuar?"
										lRet	 := .T.
										lGeraEvt := .F.
									Else
										ShowError("A020CPFVLD",.T.,,.T.)// "Informe um CPF valido para o Dependente."###"Atencao"
										lRet 	 := .F.
										Break
									EndIf
								EndIf
							Else
								If !lRobo
									lRet	:= .F.
									Break
								Endif
							EndIf
						ElseIf oGrid:GetValue("RB_CIC") == SRA->RA_CIC
							ShowError(OemToAnsi(IIF(cVersGPE == '2.4.02',STR0103,STR0064)),.T.) //"Dependente maior de 14 anos nใo deve utilizar o mesmo CPF do funcionแrio."
							lRet := .F.
							Break
						EndIf
					EndIf
				EndIf

				If cVersGPE >= "2.3" //Se estiver no leiaute 2.3 do eSocial faz as valida็๕es.
					//Valida็๕es para o eSocial leiaute 2.3
					//1- Deve ser um n๚mero de CPF vแlido (valida็ใo jแ existente no cadastro)
					//2- O preenchimento ้ obrigat๓rio para maior ou igual a 12 (doze) anos e {depIRRF} = [S];
					//3- Em arquivo de empregador Pessoa Fํsica, deve ser diferente do CPF informado em {ideEmpregador};
					//4- Nใo pode haver mais de um dependente com um mesmo n๚mero do CPF.

					//2 - Se for dependente de IR e idade maior que 11 deverแ ser preenchido o CPF
					If ( cDepIR <> "4" .Or. Empty(cDepIR) ) .And. lRet .and. nPosCPF > 0 .and. nPosNasc > 0
						If nIdade > 11 .And. Empty(oGrid:GetValue("RB_CIC"))
							ShowError(OemToAnsi(STR0096),cEFDAviso == "1") //"eSocial:Preenchimento do CPF obrigat๓rio para idade maior ou igual a 12 anos e dependente de IR."
							If cEFDAviso == "1" //-- Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
								lRet := .F.
								Break
							Else
								lGeraEvt := .F.
							EndIf
						Endif
					EndIf

					//3-Busca informa็๕es do {ideEmpregador}
					aEstb:= fGM23SM0()
					If Len(aEstb) > 0
						nPosEstb 	:= aScan(aEstb, {|x| x[1] == ALLTRIM(SRA->RA_FILIAL)})
						If nPosEstb > 0
							cTpInscr	:= aEstb[nPosEstb,3]
							cInscr		:= aEstb[nPosEstb,2]
							If cTpInscr == "2" .And. !Empty(cInscr)
								If Alltrim(cInscr) == 	Alltrim(oGrid:GetValue("RB_CIC"))
									ShowError(OemToAnsi(STR0097),.T.) //"eSocial:O CPF do dependente nใo pode ser o mesmo do empregador."
									lRet := .F.
									Break
								Endif
							Endif
						Endif
					Endif

					//4 - Nใo pode haver mais de um dependente com um mesmo n๚mero do CPF.
					nGrid:=oGrid:GetLine()
					cCPF_Dep:= Alltrim(oGrid:GetValue("RB_CIC"))
					For nG := 1 To oGrid:Length()
						oGrid:GoLine( nG )
						If nGrid <> nG .And. !Empty(oGrid:GetValue("RB_CIC"))
							If !oGrid:IsDeleted() .And. Alltrim(oGrid:GetValue("RB_CIC")) == cCPF_Dep
								ShowError(OemToAnsi(STR0098),.T.) //"eSocial:O CPF informado jแ foi cadastrado para outro dependente."
								lRet := .F.
								Break
							Endif
						Endif
					Next nG
					oGrid:GoLine( nGrid )
				Endif
			Endif
			If cPaisLoc == "PER"
				If oGrid:GetValue("RB_TPDOCPA") $ "123" .And. oGrid:GetValue("RB_GRAUPAR") # "4" //Gestante
					lRet := .F.
				ElseIf oGrid:GetValue("RB_TPDOCPA") $ "4" .And. oGrid:GetValue("RB_GRAUPAR") # "6" //Filho maior de idade incapacitado
					lRet := .F.
				ElseIf oGrid:GetValue("RB_TPDOCPA") $ "567" .And. oGrid:GetValue("RB_GRAUPAR") # "2" //Conjuge
					lRet := .F.
				ElseIf oGrid:GetValue("RB_TPDOCPA") $ "89" .And. oGrid:GetValue("RB_GRAUPAR") # "3" //Concubina(o)
					lRet := .F.
				ElseIf oGrid:GetValue("RB_TPDOCPA") $ "A" .And. oGrid:GetValue("RB_GRAUPAR") # "5" //Filho menor de idade
					lRet := .F.
				EndIf

				If !lRet
					ShowError(OemToAnsi(STR0035),.T.)//"O Documento Paterno nใo ้ compatํvel com o grau de parentesco"
					Break
				EndIf

				If Empty( oGrid:GetValue("RB_DOCPAT") ) .And. oGrid:GetValue("RB_GRAUPAR") $ "36"
					ShowError(OemToAnsi(STR0036),.T. ) //"O Numero de Documento ้ obrigat๓rio para este tipo de vํnculo"
					lRet := .F.
					Break
				EndIf

				If lRet .and. oGrid:GetValue("RB_TPCIC") == "07" .and. Empty(oGrid:GetValue("RB_PAISPAS"))
					ShowError(OemToAnsi(STR0042),.T. ) //"Pais emissor do Passaport obrigat๓rio para este tipo de documento."
					lRet := .F.
					Break
				EndIf

			EndIf

		EndIf

	End Sequence

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGp020TOk  บAutor  ณLeandro Drumond     บ Data ณ  03/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao de bPost. Valida Grid ao confirmar a tela	  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Gp020TOk(oGrid)
    Local oStruct   := oGrid:GetStruct()
    Local aCampos	:= oStruct:GetFields()
    Local lRetorna  := .T.
    Local lRetEFD   := .F.
    Local lRetPE	:= .T.
    Local dDtRef   	:= CtoD("//")
    Local nValBase	:= 0
    Local nBusca, cTab, nLinha
    Local lGestPubl := if(ExistFunc("fUsaGFP"),fUsaGFP(),.f.)	//Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP
    Local aPerAtual	:= {}
    Local cRoteiro	:= If(SRA->RA_CATFUNC $ 'A|P',fGetCalcRot('9'),fGetCalcRot('1'))
    Local aCpoObrig := {{"RB_NOME"},{"RB_DTNASC"},{"RB_TIPIR"},{"RB_TIPSF"}}
    Local nX		:= 1
    Local nSizeSin	:= TamSX3("RA_SINDICA")[1]
    Local cMsgObri  := ""
    Local lCpoObr   := .T.

    If fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, cRoteiro )
        dDtRef		:= aPerAtual[1,6]
    Else
        dDtRef   	:= firstday(dDatabase)
    EndIf

    Continua := .F.

    If (lInttaf .Or. lMiddleware) .And. !(SRA->RA_CATEFD $ cCatNTSV)
        aAdd(aCpoObrig,{"RB_TPDEP"})
    EndIf

    For nX := 1 To Len(aCpoObrig)
        If Empty(oGrid:GetValue(aCpoObrig[nX,1]))
            dbSelectArea("SX3")
            dbSetOrder(2)
            dbSeek( aCpoObrig[nX,1] )
            cMsgObri += aCpoObrig[nX,1] +" - "+ X3Titulo() + CRLF
            lCpoObr  := .F.
            lRetorna := .F.
            If aCpoObrig[nX,1] == "RB_TPDEP"
                lRetEFD := .T.
            EndIf
        EndIf
    Next

    If oGrid:GetValue("RB_AUXCRE") == "1" .AND. Empty(oGrid:GetValue("RB_VLRCRE"))
        // Bsca Tabela Relacionada
        nBusca   := DateDiffMonth( dDtRef , oGrid:GetValue("RB_DTNASC") )
        cTab     := IIf(lGestPubl,"S109","S015")
        dDataRef := dDtRef

        nLinha := fPosTab(cTab,SRA->RA_SINDICA,"==",4 ,nBusca,"<=",5,,,,,SRA->RA_FILIAL,,,,dDataRef) //filial+mes/ano+sindicato (preenchidos)
        If nLinha == 0
            nLinha := fPosTab(cTab,SRA->RA_SINDICA,"==",4 ,nBusca,"<=",5,,,,,SRA->RA_FILIAL,,,,Ctod("  /  /    ")) //filial+sindicato (preenchidos)
        EndIf
        If nLinha == 0
            nLinha := fPosTab(cTab,SRA->RA_SINDICA,"==",4 ,nBusca,"<=",5,,,,,Space(FWGetTamFilial),,,,dDataRef) //mes/ano+sindicato (preenchidos)
        EndIf
        If nLinha == 0
            nLinha := fPosTab(cTab,SRA->RA_SINDICA,"==",4 ,nBusca,"<=",5,,,,,Space(FWGetTamFilial),,,,Ctod("  /  /    ")) //sindicato (preenchido)
        EndIf
        If nLinha == 0
            nLinha := fPosTab(cTab,Space(nSizeSin),"==",4 ,nBusca,"<=",5,,,,,Space(FWGetTamFilial),,,,Ctod("  /  /    ")) //filial+mes/ano+sindicato (em branco)
        EndIf

        If nLinha > 0
            nValBase := fTabela(cTab,nLinha,6,dDataRef,SRA->RA_FILIAL)
        EndIf
        If nValBase <= 0
            lRetorna		:= .F.
            Help( " ", 1, "Help",, STR0080 + cTab + '.', 1, 0 ) //"Quando o campo 'Aux Creche' for preenchido com 'Sim', deverแ existir valor no campo 'Valor Creche' ou entใo existir registro vแlido na tabela " + "S015" ou "S109"
        EndIf
    EndIf

    If lCpoObr == .F. .And. lRetorna == .F.
    If lRetEFD
            If cEFDAviso <> "1"
            lRetorna := .T.
        EndIf
    EndIf
    Help( " ", 1, "Help",, STR0102 + CRLF + cMsgObri , 1, 0 )
    EndIf
Return lRetorna

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGp020Grav บAutor  ณLeandro Drumond     บ Data ณ  03/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava no arquivo de Dependentes						  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Gp020Grav( oModel,cVersEnvio )
    Local aArea      := GetArea()
    Local nOperacao  := oModel:GetOperation()
    Local oGrid 	 := oModel:GetModel("GPEA020_SRB")
    Local oStruct    := oGrid:GetStruct()
    Local aCampos	 := oStruct:GetFields()
    Local nDepIr 	 := 0
    Local nDepSf  	 := 0
    Local nI	 	 := 0
    Local nJ	 	 := 0
    Local nPosTipIR  := oGrid:GetIdField("RB_TIPIR")
    Local nPosTipSF  := oGrid:GetIdField("RB_TIPSF")
    Local nPosNasc   := oGrid:GetIdField("RB_DTNASC")
    Local nPosDpInc  := oGrid:GetIdField("RB_INCT")
    Local cIncTrab	 := "N"
    Local aSaveLines := FWSaveRows( oModel )
    Local nLoop      := 0
    Local nLoops     := 0
    Local lRet 		 := .t.
    Local aDadosXml  := {}
    Local aTpAlt	 := {.F.,.F.,.F.,.F.} // indica o tipo de integracao com eSocial
    Local cCPF	     := ""
    Local cStat1	 := ""
    Local cStatus    := ""
    Local cTCV		 := fCatTrabEFD("TCV")
    Local cTSV		 := fCatTrabEFD("TSV")
    Local lUpdated	 := .F.

    Local lRetif
    Local lAltCad
    Local lAltCon
    Local aContainer := {}

    Local aFilInTaf		:= {}
    Local aArrayFil		:= {}
    Local cFilEnv    	   := ""
    Local cFilTrab		:= If(Empty(SRA->RA_FILIAL) , cFilAnt, SRA->RA_FILIAL )
    Local cCatTSVPl     := "721|722" // Trabalhadores pro-labore sem vํnculo.

    Local lIntMDT       := SuperGetMv( "MV_MDTGPE", .F., "N" ) == "S"

    Local aInfoC	 := {}
    Local cChaveMid	 := ""	
    Local cStatMid   := ""
    Local lAdmPubl	:= .F.

    Default cVersEnvio:= "2.2"

    If nOperacao != 5 //se for exclusใo nใo deixa montar adadosXml para que entใo os dados sejam excluidos no TAF
        For nI := 1 To oGrid:Length()
            oGrid:GoLine( nI )

            //Verifica็ใo do Dependente Incapaz
            If nPosDpInc > 0
                cIncTrab := Iif( oGrid:GetValue("RB_INCT") $ " |1","N","S")
            EndIf

            // Caso o dependente seja classificado como Agregados/Outros e o plano estiver ativo, serแ exibido um help alertando sobre a necessidade
            // do cadastro do registro no Planos ativos para calculo do plano de sa๚de.
            If oGrid:GetValue("RB_GRAUPAR") == "O" .And. oGrid:GetValue("RB_PLSAUDE") == "1"
                Help(" ", 1, "GRAUPAR",, OemToAnsi(STR0107), 1, 0,,,,,, { OemToAnsi(STR0108)})
            Endif

            If !oGrid:IsDeleted()
                Aadd(aDadosXml, {	oGrid:GetValue("RB_TPDEP")                         ,; //01-TP DEP
                                        AllTrim( oGrid:GetValue("RB_NOME")                ),; //02-NOME
                                        oGrid:GetValue("RB_DTNASC")                        ,; //03-DT NASC
                                        AllTrim( oGrid:GetValue("RB_CIC")                 ),; //04-CIC
                                        IIf( oGrid:GetValue("RB_TIPIR") == "4" .Or. !Empty(oGrid:GetValue("RB_DTBAIXA")) .And. oGrid:GetValue("RB_DTBAIXA") <= dDataBase,"N","S"  ),; //05-TP IR
                                        IIf( oGrid:GetValue("RB_TIPSF") == "3" .Or. !Empty(oGrid:GetValue("RB_DTBAIXA")) .And. oGrid:GetValue("RB_DTBAIXA") <= dDataBase,"N","S"  ),; //06-TP SF
                                        ""												   ,; //07-PL SAUDE (descontinuado)
                                        oGrid:GetValue("RB_COD")                           ,; //08-COD
                                        cIncTrab                                           }) //09-INC TRAB

                If !lUpdated
                    lUpdated := fTemAlt(oGrid)
                EndIf
            Else
                lUpdated := .T.
            EndIf
        Next
    EndIf

    If (lInttaf .Or. lMiddleware) .And. FUNNAME() <> "GPEM035" .And. !(SRA->RA_CATEFD $ cCatNTSV) .And. lGeraEvt

        lRetif :=  fAltRetNew()
        lAltCad := .F.
        lAltCon := .F.

        If !lRetif
            lAltCad := fAltCadNew() // alterado cadastro
            lAltCon := fAltConNew() // alterado dados contrato
        Endif

        aAdd( aContainer, { lRetif, lAltCad, lAltCon } )

        aTpAlt := {.F.,.F.,.F.,.F.}

        If lMiddleware
            If  !ChkFile("RJE") .And. ChkFile("RJ9")
                MsgInfo(OemToAnsi(STR0109)) //"Tabela RJE nใo encontrada. Execute o UPDDISTR - atualizador de dicionแrio e base de dados."
                lRetorno		:= .F.
            Elseif ChkFile("RJE")
                fPosFil( cEmpAnt, SRA->RA_FILIAL )
                aInfoC   := fXMLInfos()
                                    
                IF LEN(aInfoC) >= 4
                    cTpInsc  := aInfoC[1]
                    lAdmPubl := aInfoC[4]
                    cNrInsc  := aInfoC[2]
                Else
                    cTpInsc  := ""
                    lAdmPubl := .F.
                    cNrInsc  := "0"
                Endif
            Endif	
        Endif 

        If !lMiddleware
            fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
        EndIf

        If Empty(cFilEnv)
            cFilEnv:= cFilAnt
        EndIf
        //tratamento para empresa configurada como 1x1 ou 1xN
        If !lMiddleware .And. Len(aFilInTaf[1,3]) == 1 //1X1
            cFilEnv:= cFilTrab
        EndIf

        If SRA->RA_CATEFD $ cTCV
            If !lMiddleware
                cCPF := AllTrim(SRA->RA_CIC) + ";" + alltrim(SRA->RA_CODUNIC)
                cStatus := TAFGetStat( "S-2200", cCPF, cEmpAnt, cFilEnv )
                cStat1  := TAFGetStat( "S-2100", cCPF, cEmpAnt, cFilEnv )
            Else
                cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
                cStatus 	:= "-1"
                cStat1  	:= "-1"						
                //RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
                GetInfRJE( 2, cChaveMid, @cStatus )			
            EndIf
        ElseIf (SRA->RA_CATEFD $ cTSV)
            If !lMiddleware
                cCPF := AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
                cStatus := TAFGetStat( "S-2300", cCPF, cEmpAnt, cFilEnv )
            Else
                cCPF 		:= AllTrim( SRA->RA_CIC ) + AllTrim( SRA->RA_CATEFD ) + DTOS( SRA->RA_ADMISSA )
                cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2300" + Padr(cCPF, 40, " ")
                cStatus 	:= "-1"			
                //RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
                GetInfRJE( 2, cChaveMid, @cStatus )	
            EndIf
            cStat1  := "-1"
        EndIf

        fStatusTAF(@aTpAlt,cStatus,cStat1,, aContainer)

        If cStatus == "2" // em transito
            If !lMiddleware
                cMsg	:= STR0082
            Else
                cMsg	:= STR0110//"eSocial: Registro de admissใo do funcionแrio em trโnsito. A altera็ใo nใo serแ efetivada."
            EndIf
            MsgAlert(OemToAnsi(cMsg))
            lRet := .F.
        EndIf

        If lRet .AND. lUpdated
            //Caso nใo encontre nenhuma inconsistencia no TudoOk
            //Ele realiza a gera็ใo do XML. Verificando a Cat EFD do funcionแrio
            //Caso apresente algum erro ele nใo gera o registro no banco e fica em tela aguardando at้ a corre็ใo
            If (SRA->RA_CATEFD $ cTSV)
                If( aTpAlt[1] ) .And. !(SRA->RA_CATEFD $ cCatNTSV)
                    regtomemory("SRA")
                    lRet:= fInt2300New("SRA",,3,"S2300", ,aDadosXml,cVersEnvio)
                    If( lRet ) .And. !IsBlind() .And. FindFunction("fEFDMsg")
                        fEFDMsg()
                    EndIf
                ElseIf( aTpAlt[3] )
                    If !(SRA->RA_CATEFD $ cCatNTSV .Or. SRA->RA_CATEFD $ cCatTSVPl)  .Or. ;
                        ((SRA->RA_CATEFD $ cCatNTSV .Or. SRA->RA_CATEFD $ cCatTSVPl) .And. cStatus == '4')
                        regtomemory("SRA")
                        lRet := fIntAdmiss("SRA",,3,"S2205", ,aDadosXml,,,,,cVersEnvio)
                        If( lRet ) .And. !IsBlind() .And. FindFunction("fEFDMsg")
                            fEFDMsg()
                        EndIf
                    EndIf
                EndIf
            ElseIf (SRA->RA_CATEFD $ cTCV)
                regtomemory("SRA")
                If aTpAlt[1] .OR. aTpAlt[2]
                    lRet:= (  Iif( aTpAlt[1] ,fIntAdmiss("SRA",/*lAltCad*/,3,"S2200",/*cTFilial*/,aDadosXml,/*cCodUn*/,/*oModel*/,/*cOrigem*/,/*aErros*/,cVersEnvio) ,;
                                                    fIntAdmiss("SRA",/*lAltCad*/,3,"S2100",/*cTFilial*/,aDadosXml,/*cCodUn*/,/*oModel*/,/*cOrigem*/,/*aErros*/,cVersEnvio) )   )
                Else
                    lRet:= fIntAdmiss("SRA",,3,"S2205", ,aDadosXml,,,,,cVersEnvio)
                Endif
                If( lRet ) .And. !IsBlind() .And. FindFunction("fEFDMsg")
                    fEFDMsg()
                EndIf
            EndIf
        Endif
    Endif

    lGeraEvt := lIntTAF .Or. lMiddleware // Reseto o valor, pois o usuแrio pode continuar na tela e tentar incluir os dados que faltaram para enviar para o TAF

    If lRet
        FWFormCommit(oModel,{ |oModel,cID,cAlias,lNewRecord| GP020PEGRV(oModel,cID,cAlias,lNewRecord) } )

        //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
        //ณ Atualiza o Cadastro de Funcionario "SRA"                     ณ
        //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
        dbSelectArea( "SRA" )
        If nOperacao == MODEL_OPERATION_DELETE
            //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
            //ณ Atualiza o Cadastro de Funcionario "SRA"                     ณ
            //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
            dbSelectArea( "SRA" )
            RecLock("SRA",.F.)
            SRA->RA_DEPIR := "00"
            SRA->RA_DEPSF := "00"
            SRA->(MsUnlock())	

        Else
            For nI := 1 To oGrid:Length()
                oGrid:GoLine( nI )
                If !oGrid:IsDeleted()
                    if(nPosNasc > 0)
                        If MesAno(oGrid:GetValue("RB_DTNASC")) <= MesAno(dDataBase)
                            If nPosTipIR > 0
                                If oGrid:GetValue("RB_TIPIR") $ "123"
                                    nDepIr++
                                EndIf
                            EndIf
                            If nPosTipSF > 0
                                If oGrid:GetValue("RB_TIPSF") $ "12"
                                    nDepSf++
                                EndIf
                            EndIf
                        EndIf
                    EndIf

                    //Se existir integra็ใo com o MDT, atualiza a ficha m้dica
                    If lIntMDT
                        dbSelectArea( "TM0" )
                        dbSetOrder( 3 ) //TM0_FILFUN+TM0_MAT+TM0_NUMDEP
                        If dbSeek( SRA->RA_FILIAL + SRA->RA_MAT + oGrid:GetValue("RB_COD") )
                            MdtAltTrf( SRA->RA_FILIAL , SRA->RA_MAT , ;
                                        {   oGrid:GetValue("RB_COD"), ;
                                            oGrid:GetValue("RB_NOME"), ;
                                            oGrid:GetValue("RB_DTNASC"), ;
                                            oGrid:GetValue("RB_SEXO"), ;
                                            oGrid:GetValue("RB_CIC") } )
                        EndIf
                    EndIf
                EndIf
            Next nI

            aCpyGrid := {}

            fGravaSr9("RA_DEPIR",StrZero( nDepIr , 2 ),If(Empty(SRA->RA_DEPIR),"00",SRA->RA_DEPIR),dDataBase)
            RecLock("SRA",.F.)
            SRA->RA_DEPIR := StrZero( nDepIr , 2 )
            SRA->RA_DEPSF := StrZero( nDepSf , 2 )

            MsUnlock()
        EndIf

        fPrepDadosApi(nOperacao,oGrid)

        FWRestRows( aSaveLines, oModel )
        
        RestArea( aArea )

        aSize(aSaveLines,0)
        aSaveLines := Nil
        oGrid := Nil
    Else
        Help( " ", 1, "Help",, OemToAnsi(STR0093), 1, 0 )
    EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGP020PEGRVบAutor  ณLeandro Drumond     บ Data ณ  03/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a chamada do Ponto de Entrada
			  	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GP020PEGRV(oModel,cID,cAlias,lNewRecord)
    If ExistBlock("GP020GRV")
        ExecBlock("GP020GRV",.F.,.F.)
    EndIf
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGp020ClsOkบAutor  ณLeandro Drumond     บ Data ณ  03/10/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTratamento para o metodo SetCloseOnOk (fechar tela Ok)      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGAGPE                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Gp020ClsOk( oView )
    Local aArea    	 := GetArea()
    Local nOperation := oView:oModel:GetOperation()
    Local oGrid   	 := oView:oModel:GetModel("GPEA020_SRB")
    Local nLinGrdPos := oGrid:GetLine() //Linha posicionada atualmente no Grid
    Local lRet     	 :=  .F.
    Local nX  		 := 0

    If nOperation == MODEL_OPERATION_UPDATE
        lRet := .T.
        For nX:=1 to oGrid:GetQtdLine()
            oGrid:GoLine( nX )
            if !oGrid:IsDeleted()
                lRet := .F.
                Exit
            EndIf
        Next nX
        oGrid:GoLine( nLinGrdPos )
    EndIf

    RestArea( aArea )
    oGrid := Nil
Return lRet

/*/{Protheus.doc} ShowError
	Fun็ใo responsแvel em mostrar todos os erros, jแ fazendo tratativa
para situa็๕es do ExecAuto.
	Explica็ใo para exist๊ncia dessa fun็ใo:
	A ideia da fun็ใo HELP ้ que ela pode ser utilizada junto com o MVC
de maneira que ela guarde na mem๓ria os erros que ocorreram, mas
isso nใo estava acontecendo corretamente. Digamos que fosse passado
4 dependentes num vetor, sendo que todos sใo vแlidos, exceto a posi็ใo 3,
nesse caso, quando ele passasse pela posi็ใo 4, ele limparia os erros que
ocorreram na posi็ใo 3.
	Verificar de quando o Framework corrigir alterar essa fun็ใo.
@author PHILIPE.POMPEU
@since 18/08/2015
@version 12.1.7
@param cMsg, caractere, Mensagem ou C๓digo do Help
@param lIsHelp, l๓gico, Caso <cMsg> deva ser tratado como um c๓digo de Help
@param cTitle, caractere, Tํtulo da Tela de Help
@return Nil, Valor Nulo
@project 12.1.7
/*/
Static Function ShowError(cMsg,lIsHelp,cTitle,lCodHlp)
	DEFAULT cMsg 	:= ''
	DEFAULT lIsHelp	:= .F.
	DEFAULT cTitle 	:= OemToAnsi(STR0017)
	DEFAULT lCodHlp	:= .F.

	If lGp020Auto
		AutoGrLog(cTitle + ':' + cMsg)
	Else
		If(lIsHelp)
			If lCodHlp
				Help(" ",1,cMsg)
			Else
				Help(,,'HELP',, cMsg,1,0 )
			EndIf
		Else
			MsgInfo(cMsg,cTitle)
		EndIf
	EndIf
Return

/*/{Protheus.doc} SetRotAuto
	Fun็ใo utilizada para setar o valor de <lGp020Auto>,
	pode ser usada por quem foi instโnciar o modelo de dados
	sem no entanto chamar a fun็ใo GPEA020() antes.
	Foi necessแrio porque, ao contrแrio do que as boas prแticas ditam,
	o modelo de dados tem depend๊ncia com variaveis estแticas, no caso a
	<lGp020Auto>, como quem quer que fosse instโnciar o modelo nใo conseguiria
	utilizแ-lo, pq <lGp020Auto> por padrใo ้ .F., sendo "setada" pela fun็ใo
	GPEA020.
@author PHILIPE.POMPEU
@since 19/08/2015
@version P12
@param lValue, l๓gico, valor para <lGp020Auto>
@sample
		StaticCall(GPEA020,SetRotAuto,.T.)
		oModel 	:= FWLoadModel("GPEA020")
@return Nil, Valor nulo
@project 12.1.7
/*/
Static Function SetRotAuto(lValue)
	Default lValue := .F.
	lGp020Auto := lValue
Return (Nil)

/*/{Protheus.doc} fTemAlt
Verifica se campos que vใo no XML do esocial sofreram altera็ใo, caso nใo tenham sofrido altera็ใo nใo ้ necessแrio enviar o xml
@author guilherme.bertelli
@since 21/05/2018
/*/
Static Function fTemAlt(oModel)
	Local lRet		:= .F.
	Local aCampos 	:= {'RB_TPDEP', 'RB_NOME', 'RB_DTNASC', 'RB_CIC', 'RB_TIPIR', 'RB_TIPSF'}
	Local nI		:= 1

	If SRB->( ColumnPos('RB_INCT') ) > 0
		AAdd(aCampos,'RB_INCT')
	EndIf

	For nI := 1 To Len(aCampos)
		If oModel:IsFieldUpdated(aCampos[nI])
			lRet := .T.
			Exit
		EndIf
	Next nI
Return lRet

/*/{Protheus.doc} fTemDepen
Quando for chamada via execauto, verifica se existe registro na SRB diferente do que esta sendo enviado, caso exista,
serแ incluido no array de itens para gera็ใo correta do evento S-2205.

@since	25/03/2020
@autor	Silvio C. Stecca
@version P12.1.XX

/*/
Static Function fTemDepen(aItens, nOpc)
	Local nReg		:= 0
	Local nPosfil	:= 0
	Local nPosMat	:= 0
	Local nPosCod	:= 0
	Local cFilSRB	:= ""
	Local cMatSRB	:= ""
	Local cCodSRB	:= ""

	If nOpc == 3
		For nReg := 1 To Len(aItens)	
		
			If (nPosfil := AScan(aItens[1], {|x|x[1]=='RB_FILIAL'})) > 0
				cFilSRB := aItens[nReg, nPosfil, 2]
			Else
				cFilSRB := xFilial("SRA")
			EndIf

			If (nPosMat := AScan(aItens[1], {|x|x[1]=='RB_MAT'})) > 0
				cMatSRB := aItens[nReg, nPosMat, 2]
			EndIf

			If (nPosCod := AScan(aItens[1], {|x|x[1]=='RB_COD'})) > 0
				cCodSRB := aItens[nReg, nPosCod, 2]
			EndIf

			// CHAMA FUNวรO QUE VERIFICA SE Jม EXISTE OUTRO DEPENDENTE PARA A MATRICULA.
			fIncDepen(aItens, cFilSRB, cMatSRB, cCodSRB)

		Next nReg
	EndIf

Return Nil

/*/{Protheus.doc} fTemDepen
Quando for chamada via execauto, verifica se existe registro na SRB diferente do que esta sendo enviado, caso exista,
serแ incluido no array de itens para gera็ใo correta do evento S-2205.

@since	25/03/2020
@autor	Silvio C. Stecca
@version P12.1.XX

/*/
Static Function fIncDepen(aItens, cFilSRB, cMatSRB, cCodSRB)
	Local cAliasSRB	:= GetNextAlias()
	Local aArea		:= GetArea()
	Local aLinSRB	:= {}
	Local aRecSRB	:= {}
	Local nRec		:= 0

	// FECHA O ALIAS CASO ESTEJA SENDO USADO.
	If (Select(cAliasSRB) > 0)
		(cAliasSRB)->(DbCloseArea())
	EndIf
	
	BeginSql alias cAliasSRB
		SELECT RB_FILIAL, RB_MAT, RB_COD, RB_NOME, RB_TPDEP, RB_DTNASC, RB_SEXO, RB_GRAUPAR, RB_TIPIR, RB_TIPSF, RB_LOCNASC, RB_CIC, R_E_C_N_O_ RECSRB
		FROM %table:SRB% SRB
		WHERE 
		RB_FILIAL = %exp:cFilSRB% 
		AND RB_MAT = %exp:cMatSRB% 
		AND RB_COD <> %exp:cCodSRB% 
		AND SRB.%NotDel%
	EndSql

	If !(cAliasSRB)->(Eof())
		While !(cAliasSRB)->(Eof())

			aLinSRB := {}

			aAdd(aLinSRB, {"RB_FILIAL"	, (cAliasSRB)->RB_FILIAL		, Nil})
			aAdd(aLinSRB, {"RB_MAT"   	, (cAliasSRB)->RB_MAT			, Nil})
			aAdd(aLinSRB, {"RB_COD"     , (cAliasSRB)->RB_COD			, Nil})
			aAdd(aLinSRB, {"RB_NOME"   	, (cAliasSRB)->RB_NOME			, Nil})
			aAdd(aLinSRB, {"RB_TPDEP"   , (cAliasSRB)->RB_TPDEP			, Nil})
			aAdd(aLinSRB, {"RB_DTNASC" 	, sTod((cAliasSRB)->RB_DTNASC)	, Nil})
			aAdd(aLinSRB, {"RB_SEXO"  	, (cAliasSRB)->RB_SEXO			, Nil})
			aAdd(aLinSRB, {"RB_GRAUPAR"	, (cAliasSRB)->RB_GRAUPAR		, Nil})
			aAdd(aLinSRB, {"RB_TIPIR" 	, (cAliasSRB)->RB_TIPIR			, Nil})
			aAdd(aLinSRB, {"RB_TIPSF" 	, (cAliasSRB)->RB_TIPSF			, Nil})
			aAdd(aLinSRB, {"RB_LOCNASC" , (cAliasSRB)->RB_LOCNASC		, Nil})
			aAdd(aLinSRB, {"RB_CIC"    	, (cAliasSRB)->RB_CIC			, Nil})                             

			// ARMAZENA NO ARRAY OS RECNOดS DOS REGISTROS ENCONTRADOS.
			aAdd(aRecSRB, {(cAliasSRB)->RECSRB})

			// ADICIONA O REGISTRO ENCONTRADO AO ARRAY ENVIADO PELO EXECAUTO DA ROTINA.
			aadd(aItens, aLinSRB)  

			(cAliasSRB)->(dbSkip())
		EndDo

		// ORDENA O ARRAY DO EXECAUTO.
		aSort(aItens)

		// COM O ARRAY DE RECNO CONTENDO INFORMAวรO, VAI DELETAR OS REGISTROS
		// ENCONTRADOS DA TABELA SRB PARA GARANTIR QUE NรO HAJA CHAVE DUPLICADA DURANTE O EXECAUTO.
		If Len(aRecSRB) > 0
			For nRec := 1 To Len(aRecSRB)
				SRB->(DbSetOrder(1))
				
				Begin Transaction	
					// DELETA OS ITENS DA SRB ENCONTRADOS.
					SRB->(DbGoTo(aRecSRB[nRec, 1]))
					If Reclock("SRB", .F.)
						SRB->(DbDelete())
						SRB->(MsUnLock())
					EndIf
				End Transaction
			Next nRec
		EndIf
	EndIf

	// FECHA O ARQUIVO TEMPORARIO CRIADO.
	(cAliasSRB)->(DbCloseArea())

	// RESTAURA A AREA.
	RestArea(aArea)

Return Nil

/*/{Protheus.doc} fAltCamposApi
Verifica se os campos de envio da API foram alterados 
@since	08/04/2020
@autor	Wesley Alves Pereira
@version P12.1.XX

/*/
Static Function fAltCamposApi(oGridApi,nNumLinha)
    Local aArea		:= GetArea()
    Local aCampos 	:= {'RB_NOME', 'RB_DTNASC', 'RB_CIC', 'RB_SEXO'}
    Local lAlterou  := .F.	
    Local nI		:= 1
    Local nJ        := 1

    For nJ := 1 To oGridApi:Length()
        If nJ == nNumLinha
            oGridApi:GoLine( nJ )
            For nI := 1 To Len(aCampos)
                If oGridApi:IsFieldUpdated(aCampos[nI])
                    lAlterou := .T.
                    Exit
                EndIf
            Next nI
        EndIf
    Next nJ

    RestArea(aArea)

Return (lAlterou)

*/

/*/{Protheus.doc} fPrepDadosApi
Processo para preparar os dados de inclusใo/altera็ใo/dele็ใo para 
integra็ใo via API REST.

@since	08/04/2020
@autor	Wesley Alves Pereira
@version P12.1.XX

/*/
Static Function fPrepDadosApi(nOpcModel,oGridApi)
    Local aArea		:= GetArea()
    Local oModel 	:= FWModelActive()
    Local oGrid   	:= oModel:GetModel("GPEA020_SRB")
    Local cTmpCod   := ""

    Local nI		:= 1
    Local cOperacao := ""
    Local lIntegrac := SUPERGETMV('MV_RHNG', .F., .F.)

    If ( ! ( lIntegrac) )
        Return (.T.)
    EndIf

    If nOpcModel == MODEL_OPERATION_DELETE
        For nI := 1 To oGrid:Length()
            oGrid:GoLine( nI )
            cTmpCod := oGrid:GetValue("RB_COD")
            cOperacao := "E"
            fSendDadosApi(cOperacao,cTmpCod)	
        Next nI
    Else	
        For nI := 1 To oGrid:Length()
            oGrid:GoLine( nI )
            If oGrid:IsDeleted()
                cTmpCod := oGrid:GetValue("RB_COD")
                cOperacao := "E"
                fSendDadosApi(cOperacao,cTmpCod)
            Else
                If oGrid:IsInserted()
                    cTmpCod := oGrid:GetValue("RB_COD")
                    cOperacao := "I"
                    fSendDadosApi(cOperacao,cTmpCod)
                Else
                    If fAltCamposApi(oGridApi,nI)
                        cTmpCod := oGrid:GetValue("RB_COD")
                        cOperacao := "A"
                        fSendDadosApi(cOperacao,cTmpCod)
                    EndIf
                EndIf
            EndIf
        Next nI
    EndIf

    RestArea(aArea)

Return (.T.)

/*/{Protheus.doc} fSendDadosApi
Processo para enviar os dados de inclusใo/altera็ใo/dele็ใo para 
integra็ใo via API REST.

@since	08/04/2020
@autor	Wesley Alves Pereira
@version P12.1.XX

/*/
Static Function fSendDadosApi(cOperacao, cTmpCod)
    Local dDtBase   := DDATABASE
    Local cHoraAt   := time()
    Local cTmpEmp   := cEmpAnt
    Local cProces   := "SRB"
    Local cUserId   := SubStr(cUsuario,7,15)
    Local cTmpMat   := SRB->RB_MAT
    Local cTmpFil   := SRB->RB_FILIAL
    Local cChave    := cTmpEmp + "|" + cTmpFil + "|" + cTmpMat + "|" + cTmpCod

    fSetInforRJP(cTmpFil, cTmpMat, cProces, cChave, cOperacao,  dDtBase, cHoraAt,cUserId)

Return (.T.)