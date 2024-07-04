#INCLUDE "JURA027.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"

Static lIsLancOk := .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA027
Lançamento Tabelado.

@author Ernani Forastieri
@since 01/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA027(cCliente, cLoja, cCaso)
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lVldUser  := Iif(FindFunction("JurVldUxP"), JurVldUxP(), .T.)
Local oBrowse

If lVldUser
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0001) //'Lançamento Tabelado'
	oBrowse:SetAlias('NV4')
	Iif(cLojaAuto == "1" .And. FindFunction("JurBrwRev"), JurBrwRev(oBrowse, "NV4", {"NV4_CLOJA"}), ) //Proteção
	oBrowse:SetLocate()
	oBrowse:ForceQuitButton(.T.)
	oBrowse:SetBeforeClose({|| oBrowse:VerifyLayout()})
	
	If !Empty(cCliente) .And. !Empty(cLoja) .And. !Empty(cCaso) .And. IsInCallStack('JURA162')
		oBrowse:SetFilterDefault(" NV4_CCLIEN == '" + cCliente + "' .And. NV4_CLOJA == '" + cLoja + "' .And. NV4_CCASO == '" + cCaso + "' " )
	EndIf
	
	oBrowse:SetMenuDef('JURA027')
	JurSetLeg(oBrowse, "NV4" )
	JurSetBSize(oBrowse)
	J027Filter(oBrowse, cLojaAuto) // Adiciona filtros padrões no browse

	oBrowse:Activate()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J027Filter
Adiciona filtros padrões no browse

@param  oBrowse, objeto, browse da rotina

@author Reginaldo Borges / Cristina Cintra
@since  08/08/2022
/*/
//-------------------------------------------------------------------
Static Function J027Filter(oBrowse, cLojaAuto)
Local aFilNV41 := {}
Local aFilNV42 := {}
Local aFilNV43 := {}

	If cLojaAuto == "2"
		SAddFilPar("NV4_CCLIEN", "==", "%NV4_CCLIEN0%", @aFilNV41)
		SAddFilPar("NV4_CLOJA ", "==", "%NV4_CLOJA0%", @aFilNV41)
		oBrowse:AddFilter(STR0081, 'NV4_CCLIEN == "%NV4_CCLIEN0%" .AND. NV4_CLOJA == "%NV4_CLOJA0%"', .F., .F., , .T., aFilNV41, STR0081) // "Cliente"
	Else
		SAddFilPar("NV4_CCLIEN", "==", "%NV4_CCLIEN%", @aFilNV41)
		oBrowse:AddFilter(STR0081, 'NV4_CCLIEN == "%NV4_CCLIEN%"', .F., .F., , .T., aFilNV41, STR0081) // "Cliente"
	EndIf

	SAddFilPar("NV4_CCASO", "==", "%NV4_CCASO%", @aFilNV42)
	oBrowse:AddFilter(STR0082, 'NV4_CCASO == "%NV4_CCASO%"', .F., .F., , .T., aFilNV42, STR0082) // "Caso"

	SAddFilPar("NV4_SITUAC", "==", "%NV4_SITUAC%", @aFilNV43)
	oBrowse:AddFilter(STR0083, 'NV4_SITUAC == "%NV4_SITUAC%"', .F., .F., , .T., aFilNV43, STR0083) // "Situação"

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Lançamento Tabelado

@author Ernani Forastieri
@since 01/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA027", 0, 2, 0, NIL } ) // "Visualizar"
If !IsInCallStack('JURA162')
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA027", 0, 3, 0, NIL } ) // "Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA027", 0, 4, 0, NIL } ) // "Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA027", 0, 5, 0, NIL } ) // "Excluir"
	aAdd( aRotina, { STR0039, "JCall142()"     , 0, 3, 0, NIL } ) // "Oper. em Lote"
	aAdd( aRotina, { STR0008, "VIEWDEF.JURA027", 0, 8, 0, NIL } ) // "Imprimir"
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Lançamento Tabelado

@author Ernani Forastieri
@since 01/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local lShowVirt := !JurIsRest() // Inclui os campos virtuais nos structs somente se não for REST (Necessário já que os inicializadores dos campos virtuais são executados sempre, mesmo sem o uso do header FIELDVIRTUAL = TRUE)
Local oStrNV4   := FWFormStruct(1, 'NV4',,, lShowVirt)
Local oStrNW4   := FWFormStruct(1, 'NW4',,, lShowVirt)
Local oModel    := Nil
Local oCommit   := JA027COMMIT():New()

If !lShowVirt
	// Adiciona o campo virtual "SIGLA" novamente nas estruturas, pois foi retirado via lShowVirt,
	// mas precisa existir para execução das operações nos lançamentos via REST
	AddCampo(1, "NV4_SIGLA" , @oStrNV4)
	AddCampo(1, "NW4_SIGLA1", @oStrNW4)
EndIf

oStrNV4:RemoveField('NV4_TKRET')

oModel := MPFormModel():New('JURA027', /* bPreValidacao */, /*bPosValid*/, /*bCommit*/, /*bCancel*/)

oModel:AddFields('NV4MASTER', /*cOwner*/, oStrNV4, {|oM, cFun, cCamp|J027PreVld(oM, cFun, cCamp)} /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid('NW4DETAIL', 'NV4MASTER', oStrNW4, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetRelation('NW4DETAIL', {{'NW4_FILIAL', 'xFilial("NW4")' }, {'NW4_CLTAB', 'NV4_COD'} }, 'R_E_C_N_O_' )

oModel:InstallEvent("JA027COMMIT", /*cOwner*/, oCommit)

oModel:SetDescription(STR0009) //'Modelo de Dados - Lançamento Tabelado'

oModel:GetModel('NV4MASTER'):SetDescription(STR0001) //'Lançamento Tabelado'
oModel:GetModel('NW4DETAIL'):SetDescription(STR0010) //'Lançamento Tabelado Faturamento'

oModel:SetOptional( "NW4DETAIL", .T.)

oStrNV4:SetProperty( 'NV4_COTAC', MODEL_FIELD_NOUPD, .T. )

oModel:SetVldActivate( { |oModel| Iif(FindFunction("JurVldUxP"), JurVldUxP(oModel), .T.) } )

oModel:SetActivate( { |oModel| JA027ACT( oModel ) } )

oModel:GetModel( 'NW4DETAIL' ):SetOnlyView( .T. )
oStrNW4:SetProperty( '*', MODEL_FIELD_NOUPD, .T. )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Lançamento Tabelado

@author Ernani Forastieri
@since 01/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStrNV4      := FWFormStruct(2, 'NV4')
Local oStrNW4      := FWFormStruct(2, 'NW4')
Local oModel       := FWLoadModel('JURA027')
Local oView        := Nil
Local lIntegracao  := (SuperGetMV("MV_JFSINC", .F., '2') == '1') //Sincronização com o Legal Desk.
Local cLojaAuto    := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

oStrNW4:RemoveField('NW4_CLTAB')
oStrNW4:RemoveField('NW4_CPART1')
oStrNW4:RemoveField('NW4_DTCONC')

If !lIntegracao
	oStrNW4:RemoveField( "NW4_CCLICM" )
	oStrNW4:RemoveField( "NW4_CLOJCM" )
	oStrNW4:RemoveField( "NW4_CCASCM" )
EndIf

If(cLojaAuto == "1")
	oStrNV4:RemoveField( "NV4_CLOJA" )
	oStrNW4:RemoveField( "NW4_CLOJA" )
EndIf

oStrNV4:RemoveField('NV4_TKRET')
oStrNV4:RemoveField('NV4_CPART')
oStrNV4:RemoveField("NV4_ACAOLD")
oStrNV4:RemoveField("NV4_CCLILD")
oStrNV4:RemoveField("NV4_CLJLD")
oStrNV4:RemoveField("NV4_CCSLD")
oStrNV4:RemoveField("NV4_PARTLD")
oStrNV4:RemoveField("NV4_CMOTWO")
oStrNV4:RemoveField("NV4_OBSWO")
oStrNV4:RemoveField("NV4_CDWOLD")
oStrNV4:RemoveField("NV4_COTAC")
oStrNW4:RemoveField("NW4_COTAC")

If NV4->(FieldPos("NV4_CODLD")) > 0
	oStrNV4:RemoveField('NV4_CODLD')
EndIf

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField( "JURA027_NV4", oStrNV4, "NV4MASTER" )
oView:AddGrid(  "JURA027_NW4", oStrNW4, "NW4DETAIL" )

oView:CreateHorizontalBox( "FORMFIELD" , 60,,,, )
oView:CreateHorizontalBox( "FORMFOLDER", 40,,,, )

oView:CreateFolder('FOLDER_01',"FORMFOLDER")
oView:AddSheet('FOLDER_01', 'ABA_NW4', STR0011) // Faturamento do Time Sheet

oView:CreateHorizontalBox("FORMFOLDER_NW4", 100,,, 'FOLDER_01', 'ABA_NW4')

oView:SetOwnerView( "JURA027_NV4", "FORMFIELD" )
oView:SetOwnerView( "JURA027_NW4", "FORMFOLDER_NW4")

oView:SetDescription( STR0001 ) // "Time Sheets dos Profissionais"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA027COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Cristina Cintra Santos
@since 18/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA027COMMIT FROM FWModelEvent
	Data oTmpAcaoLD // Tabela temporária para vínculo do lançamento na Pré via LD
	Data aVlCpoLD   // Array com os campos e valores referente ao ação LD

	Method New()
	Method ModelPosVld()
	Method BeforeTTS()
	Method InTTS()
	Method DeActivate()
End Class

Method New() Class JA027COMMIT
	Self:oTmpAcaoLD := Nil
	Self:aVlCpoLD   := {}
Return

Method ModelPosVld(oModel, cModelID) Class JA027COMMIT
	Local lRet := .T.

	If ValType(Self:oTmpAcaoLD) == "O"
		Self:oTmpAcaoLD:Destroy()
		Self:oTmpAcaoLD := Nil
	EndIf

	lRet := J027PosVal(oModel, @Self:oTmpAcaoLD)
Return lRet

Method BeforeTTS(oSubModel, cModelId) Class JA027COMMIT
	JA027CM(oSubModel:GetModel(), @Self:aVlCpoLD)
Return

Method InTTS(oSubModel, cModelId) Class JA027COMMIT
	If FindFunction( "JVincLanLD")
		JVincLanLD(oSubModel:GetModel("NV4MASTER"), "NV4", Self:oTmpAcaoLD, Self:aVlCpoLD) // Vínculo do Tabelado pelo Ação LD
	EndIf

	JFILASINC(oSubModel:GetModel(), "NV4", "NV4MASTER", "NV4_COD") //Fila de sincronização
Return

Method DeActivate() Class JA027COMMIT
	If ValType(Self:oTmpAcaoLD) == "O"
		Self:oTmpAcaoLD:Delete()
	EndIf
	Self:oTmpAcaoLD := Nil
	JurFreeArr(@Self:aVlCpoLD)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA027ACT
Função de validação da ativação do modelo.

@author bruno.ritter
@since 27/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA027ACT(oModel)
Local lRet       := .T.
Local cClien     := NV4->NV4_CCLIEN
Local cLoja      := NV4->NV4_CLOJA
Local cCaso      := NV4->NV4_CCASO
Local dDataLC    := NV4->NV4_DTCONC
Local nOperation := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_UPDATE .And. FindFunction("JurBlqLnc")
		lIsLancOk := JurBlqLnc( cClien, cLoja, cCaso, dDataLC, "TAB", "2" )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J027PreVld(oModel)
Função de pré validação do Model NV4.

@author bruno.ritter
@since 29/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J027PreVld(oModel,cFun,cCamp)
Local lRet       := .T.
Local nOperation := oModel:GetOperation()

	If !lIsLancOk .AND. nOperation == MODEL_OPERATION_UPDATE

		If cCamp != "NV4_DESCRI" .AND. cCamp != "NV4MASTER"
			lRet := lIsLancOk
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J027PosVal
Validação da tela de Lançamento Tabelado

@param  oModel     , Model ativo
@param  oTmpAcaoLD , Tabela Temporária da Tabelado (Usada para vínculo de tabelado via LD)

@return lRetFun    , .T. ou .F.

@author Jacques Alves Xavier
@since 23/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J027PosVal(oModel, oTmpAcaoLD)
Local lRetFun    := .T.
Local dDemis     := CToD('  /  /  ')
Local oModelNV4  := oModel:GetModel("NV4MASTER")
Local cIDNV4     := IIf( oModel:GetId() == 'JURA202', "NV4DETAIL", "NV4MASTER" )
Local cClien     := oModel:GetValue(cIDNV4, 'NV4_CCLIEN')
Local cLoja      := oModel:GetValue(cIDNV4, 'NV4_CLOJA' )
Local cCaso      := oModel:GetValue(cIDNV4, 'NV4_CCASO' )
Local dDataLC    := oModel:GetValue(cIDNV4, 'NV4_DTCONC')
Local lIsRest    := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))
Local nOperation := oModel:GetOperation()

If (nOperation == OP_INCLUIR .Or. nOperation == OP_ALTERAR) // Inclusão ou Alteração
	If lRetFun .AND. !Empty(oModelNV4:GetValue('NV4_VLDFAT')) .AND. Empty(oModelNV4:GetValue('NV4_CMOED'))
		lRetFun := JurMsgErro(I18N(STR0072, {AllTrim(RetTitle('NV4_CMOED'))}),, STR0044) //#"O campo '#1' não foi preenchido."  ##"Informe a moeda da taxa antes de confirmar."
	EndIf

	If lRetFun .AND. Empty(oModelNV4:GetValue('NV4_VLHFAT')) .And. Empty(oModelNV4:GetValue('NV4_VLDFAT'))
		lRetFun := JurMsgErro(I18N(STR0073, {AllTrim(RetTitle('NV4_VLHFAT')), AllTrim(RetTitle('NV4_VLDFAT'))}),, STR0041) //#"Os campos '#1' e '#2' não foram preenchidos." ##"É preciso haver valor de Honorários e de Taxa para incluir o lançamento Tabelado"
	EndIf

	If lRetFun .And. oModelNV4:GetValue('NV4_CONC') == '1' .And. Empty(oModelNV4:GetValue('NV4_DTCONC'))
		lRetFun := JurMsgErro(I18N(STR0072, {AllTrim(RetTitle("NV4_DTCONC"))}),, STR0067) //#"O campo '#1' não foi preenchido."  ## "O preenchimento da 'Data de Conclusão' é obrigatório para lançamentos tabelados concluídos."
	EndIf

	If lRetFun
		If !Empty(oModelNV4:GetValue('NV4_CPART'))
			dDemis := JurGetDados('RD0', 1, xFilial('RD0') + oModelNV4:GetValue('NV4_CPART'), 'RD0_DTADEM') // Campo da data de demissão

			If !Empty(dDemis) .And. (dDemis < oModelNV4:GetValue('NV4_DTCONC'))
				lRetFun := JurMsgErro(STR0058,, STR0073) //#"Não foi possível vincular o participante a este lançamento pois ele encontra-se demitido." ## "Verifique a situação do participante no cadastro ou selecione um participante válido."
			EndIf
		Else
			lRetFun := JurMsgErro(I18N(STR0072, {AllTrim(RetTitle('NV4_CPART'))}),, STR0068) // ##"Informe o participante antes de confirmar."
		EndIf
	EndIf

	If lRetFun .And. lIsRest .And. cIDNV4 == "NV4MASTER"
		lRetFun := JurVldAcLd(oModel, cIDNV4, "NV4", @oTmpAcaoLD)
	EndIf

	If lRetFun .And. lIsRest .And. nOperation == MODEL_OPERATION_INSERT .And. NV4->(FieldPos( "NV4_CODLD" )) > 0 .And. FindFunction("JurMsgCdLD")
		lRetFun := JurMsgCdLD(oModelNV4:GetValue('NV4_CODLD'))
	EndIf

EndIf

If (nOperation == OP_EXCLUIR) // Exclusão

	lRetFun := J027CanDel(oModel) // Verificar se o Lançamento pode ser excluido.

Endif

If lRetFun .And. (nOperation == MODEL_OPERATION_DELETE .OR. nOperation == MODEL_OPERATION_INSERT)
	//Valida  a existência de Fatura Adicional faturada cujo período de referência englobe a data do Lançamento
	lRetFun := Iif(FindFunction("JurBlqLnc"), JurBlqLnc( cClien, cLoja, cCaso, dDataLC, "TAB"), .T.)
EndIf

//Valida se o Lançamento Tabelado possui pré-fatura e valida
If lRetFun
	lRetFun := JA027VERPRE(oModelNV4:GetValue('NV4_CPREFT'), oModel)
EndIf

Return lRetFun

//-------------------------------------------------------------------
/*/{Protheus.doc} J027CanDel(oModel)
Rotina para  verificar se o Lançamento pode ser excluido.

@author Luciano Pereira dos Santos
@since 04/10/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J027CanDel(oModel)
Local lRet      := .T.
Local oModelNV4 := oModel:GetModel("NV4MASTER")
Local oModelNW4 := oModel:GetModel("NW4DETAIL")
Local cMsgSoluc := ""
Local nI        := 0

If oModel:GetOperation() == MODEL_OPERATION_DELETE .And. oModelNV4:GetValue('NV4_SITUAC') == "2"

	For  nI := 1 To oModelNW4:Length()
		If oModelNW4:GetValue('NW4_CANC', nI) == "2" .And. oModelNW4:GetValue('NW4_SITUAC', nI) $ "2|3"
			If oModelNW4:GetValue('NW4_SITUAC', nI) == "2"
				cMsgSoluc := I18N(STR0070, {oModelNW4:GetValue('NW4_CFATUR', nI)}) //"Para excluir o lançamento é necessário cancelar a fatura #1 antes."
			ElseIf oModelNW4:GetValue('NW4_SITUAC', nI) == "3"
				cMsgSoluc := I18N(STR0071, {oModelNW4:GetValue('NW4_CWO', nI)}) //"Para excluir o lançamento é necessário cancelar o WO #1 antes."
			EndIf
			lRet := JurMsgErro(STR0055, , cMsgSoluc) // "O Lançamento Tabelado não pode ser excluído, pois existe faturamento/wo."
			Exit
		EndIf
	Next nI

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J027ValCpo
Validação dos campos

@Return   lRetFun  .T. ou .F.

@author Jacques Alves Xavier
@since 23/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J027ValCpo()
Local oModel    := FwModelActive()
Local lRetFun   := .T.
Local aArea     := GetArea()
Local aAreNVE   := NVE->(GetArea())
Local cClien    := ''
Local cLoja     := ''
Local cCaso     := ''
Local cStruct   := IIf( oModel:GetId() == 'JURA202', "NV4DETAIL", "NV4MASTER" )
Local cCampo    := AllTrim(__ReadVar)
Local cGrupo    := oModel:GetValue(cStruct, 'NV4_CGRUPO')
Local dDataLC   := oModel:GetValue(cStruct, 'NV4_DTCONC') // Data de conclusão do lançamento
Local dDtLanc   := oModel:GetValue(cStruct, 'NV4_DTLANC') // Data do Lançamento Tabelado
Local lShowVirt := !JurIsRest() // Indica se os campos virtuais estão no modelo


	If (cCampo == "M->NV4_CCLIEN") .Or. (cCampo == "M->NV4_CLOJA") .Or. (cCampo == "M->NV4_CCASO") .Or. (cCampo == "M->NV4_DTCONC")
		cClien  := oModel:GetValue(cStruct, 'NV4_CCLIEN')
		cLoja   := oModel:GetValue(cStruct, 'NV4_CLOJA' )
		cCaso   := oModel:GetValue(cStruct, 'NV4_CCASO' )
	Else
		cClien  := oModel:GetValue(cStruct, 'NV4_CCLILD')
		cLoja   := oModel:GetValue(cStruct, 'NV4_CLJLD' )
		cCaso   := oModel:GetValue(cStruct, 'NV4_CCSLD' )
	EndIf

	If cCampo == "M->NV4_CGRUPO"
		lRetFun := JurVldCli(cGrupo, cClien, cLoja,,, "GRP")

	ElseIf cCampo == 'M->NV4_CCLIEN' .Or. cCampo == "M->NV4_CCLILD"
		lRetFun := JurVldCli(cGrupo, cClien, cLoja,,, "CLI")

	ElseIf cCampo == 'M->NV4_CLOJA' .Or. cCampo == "M->NV4_CLJLD"
		lRetFun := JurVldCli(cGrupo, cClien, cLoja,,, "LOJ")

	ElseIf cCampo == 'M->NV4_CCASO' .Or. cCampo == "M->NV4_CCSLD" .Or. cCampo == 'M->NV4_DTCONC'
		lRetFun := JurVldCli(cGrupo, cClien, cLoja, cCaso, "NVE_LANTAB", "CAS",,, dDtLanc)

	ElseIf cCampo == 'M->NV4_CMOEH' .And. lShowVirt // Somente se lShowVirt = .T. os campos virtuais estarão no modelo. Por isso, seta o valor no campo NV4_DMOEH condicionando.
		If lRetFun := Empty(FwFldGet('NV4_CMOEH')) .Or. ExistCpo('CTO', FwFldGet('NV4_CMOEH'), 1)
			oModel:LoadValue(cStruct, 'NV4_DMOEH', Left(Posicione('CTO', 1, xFilial('CTO') + oModel:GetValue(cStruct, 'NV4_CMOEH'), 'CTO_SIMB'), TamSX3('NV4_DMOEH')[1]))
		Else
			oModel:ClearField(cStruct, 'NV4_DMOEH')
		EndIf

	ElseIf cCampo == 'M->NV4_CMOED' .And. lShowVirt // Somente se lShowVirt = .T. os campos virtuais estarão no modelo. Por isso, seta o valor no campo NV4_DMOED condicionando.
		If lRetFun := Empty(FwFldGet('NV4_CMOED')) .Or. ExistCpo('CTO',FwFldGet('NV4_CMOED'),1)
			oModel:LoadValue(cStruct, 'NV4_DMOED', Left(Posicione('CTO', 1, xFilial('CTO') + oModel:GetValue(cStruct, 'NV4_CMOED'), 'CTO_SIMB'), TamSX3('NV4_DMOED')[1]))
		Else
			oModel:ClearField(cStruct, 'NV4_DMOED')
		EndIf

	ElseIf cCampo == 'M->NV4_CTPSRV'

		lRetFun := ExistCpo("NRD",FWFLDGET("NV4_CTPSRV"), 1) .And.;
		           (Posicione('NRD', 1, XFilial('NRD') + FwFldGet("NV4_CTPSRV"), 'NRD_ATIVO') == "1")

		If lRetFun
			IIf(lShowVirt, oModel:SetValue(cStruct, 'NV4_DTPSRV', JA027IdiTB('NV4_DTPSRV')), Nil) // Somente se lShowVirt = .T. os campos virtuais estarão no modelo. Por isso, seta o valor no campo NV4_DTPSRV condicionando.
			If Empty(FwFldGet('NV4_DESCRI'))
				oModel:SetValue(cStruct, 'NV4_DESCRI', JA027IdiTB('NV4_DESCRI'))
			EndIf
		EndIf

		If Empty(FwFldGet('NV4_CTPSRV'))
			JA027CLEAR(oModel)
		EndIf

		If lRetFun
			lRetFun := JA027SRVMOE(oModel, 1) .And. JA027SRVMOE(oModel, 2)
		EndIf

		If lRetFun
			aArrRet := FBusSrv(oModel:GetValue(cStruct, 'NV4_CCLIEN'), oModel:GetValue(cStruct, 'NV4_CLOJA'), oModel:GetValue(cStruct, 'NV4_CCASO'), Left(DToS(oModel:GetValue(cStruct, 'NV4_DTLANC')), 6))

			FVlrSrv(aArrRet[1], oModel:GetValue(cStruct, 'NV4_CTPSRV'))
		EndIf

	ElseIf cCampo == 'M->NV4_QUANT'
		aArrRet := FBusSrv(oModel:GetValue(cStruct, 'NV4_CCLIEN'), oModel:GetValue(cStruct,'NV4_CLOJA'), oModel:GetValue(cStruct, 'NV4_CCASO'), Left(DToS(oModel:GetValue(cStruct, 'NV4_DTLANC')), 6))

		FVlrSrv(aArrRet[1], oModel:GetValue(cStruct, 'NV4_CTPSRV'))

	EndIf

	//Valida  a existência de Fatura Adicional faturada cujo período de referência englobe a data do Lançamento
	If lRetFun .AND. (cCampo == 'M->NV4_CCLIEN' .OR. cCampo == 'M->NV4_CLOJA' .OR. cCampo == 'M->NV4_CCASO' .OR. cCampo == 'M->NV4_DTCONC')
		lRetFun := JurBlqLnc( cClien, cLoja, cCaso, dDataLC, "TAB" )
	EndIf

	RestArea(aAreNVE)
	RestArea(aArea)

Return lRetFun

//-------------------------------------------------------------------
/*/{Protheus.doc} J027IniCpo
Inicialização dos campos

@Param    cCpoRef  Campo a ser inicializado

@Return   lRetFun  .T. ou .F.

@author Jacques Alves Xavier
@since 23/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J027IniCpo(cCpoRef)
Local xVlrCpo   := ''

Default cCpoRef := ''

//NV4
If cCpoRef == 'NV4_DCASO'
	xVlrCpo := Posicione('NVE', 1, xFilial('NV4') + NV4->(NV4_CCLIEN + NV4_CLOJA + NV4_CCASO), 'NVE_TITULO')
EndIf

Return xVlrCpo

//-------------------------------------------------------------------
/*/{Protheus.doc} J027FCli4
Filtro Cliente NV4

@Param    cCpoRef  Campo a ser inicializado

@Return   lRetFun  .T. ou .F.

@author Ernani Forastieri
@since 01/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J027FCli4()
Local lRetFun := .T.
Local oModel

If IsPesquisa()
	lRetFun := .T.
Else
	oModel := FWModelActive()

	If !Empty(oModel:GetValue('NV4MASTER', 'NV4_CGRUPO'))
		lRetFun := SA1->A1_GRPVEN == oModel:GetValue('NV4MASTER', 'NV4_CGRUPO')
	EndIf
EndIf

Return lRetFun

//-------------------------------------------------------------------
/*/{Protheus.doc} J027FCas4
Filtro Caso NV4

@Param    cCpoRef  Campo a ser inicializado

@Return   cRet     String para o filtro

@author Jacques Alves Xavier
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J027FCas4()
Local cRet     := "@#@#"
Local oModel   := FWModelActive()
Local nLanc1   := SuperGetMV('MV_JLANC1',, 0)
Local nSqNmCas := SuperGetMV('MV_JCASO1',, 0) // Seqüencia da numeracao do caso: 1)por cliente ou 2)independente do cliente
Local lSituac  := JurGetDados("NUR", 1, xFilial("NUR") + JurUsuario(__CUSERID), "NUR_CASOEN") == "1"
Local cCodCli  := oModel:GetValue('NV4MASTER', 'NV4_CCLIEN')
Local cLoja    := oModel:GetValue('NV4MASTER', 'NV4_CLOJA')
Local cGrupo   := oModel:GetValue('NV4MASTER', 'NV4_CGRUPO')
Local dDtLanc  := oModel:GetValue('NV4MASTER', 'NV4_DTLANC') // Data do Lançamento Tabelado

If IsPesquisa()
	lRetFun := .T.
Else

	Do Case
	Case Empty(cCodCli) .And. nSqNmCas == '1'
		cRet   := "@#.F."

	Case Empty(cCodCli) .And. nSqNmCas == '2'
		cRet   := "@#.T."

	Case Empty(cCodCli) .And. Empty(cLoja) .And. lSituac
		cRet   := "@#NVE->NVE_CGRPCL == '" + cGrupo + "'"

	OTHERWISE
		cRet   := "@#.T."
	EndCase

	If !Empty(cCodCli)
		cRet += " .AND. NVE->NVE_CCLIEN == '" + cCodCli + "'"
	EndIf

	If !Empty(cLoja)
		cRet += " .AND. NVE->NVE_LCLIEN == '" + cLoja + "'"
	EndIf

	If !lSituac
		cRet  += " .AND. ( NVE->NVE_SITUAC == '1' "
		cRet   += " .OR. (NVE->NVE_SITUAC == '2'"
		cRet   += " .AND. NVE->NVE_DTENCE >= '" + DtoS(JRetDtEnc(dDtLanc, nLanc1, .T.)) + "' ))"
	EndIf

	cRet += " .AND. NVE->NVE_LANTAB == '1'@#"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J027FSrv4
Filtro Servicos NV4

@Return   cRet     String para o filtro

@author Jacques Alves Xavier
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function J027FSrv4()
Local cRet    := "@#@#"
Local oModel  := FWModelActive()
Local aArrRet := {}

aArrRet := FBusSrv(oModel:GetValue('NV4MASTER', 'NV4_CCLIEN'), oModel:GetValue('NV4MASTER', 'NV4_CLOJA'), oModel:GetValue('NV4MASTER', 'NV4_CCASO'), Left(DToS(oModel:GetValue('NV4MASTER', 'NV4_DTLANC')), 6))

If !Empty(aArrRet[1])
	cRet := "@#NTS->NTS_CTAB == '" + aArrRet[2] + "' .AND.  NTS->NTS_CHIST == '" + aArrRet[1] + "'@#"
Else
	cRet := "@#.F.@#"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FVlrSrv
Calcula os valores de Honorários e Taxas do Lançamento Tabelado

@Param    cCodHis  Código do Histórico do Serviço Tabelado
@Param    cLojCli  Código do Serviço Tabelado
@Param    lRecHonFat  Indica se o valor de honorários faturado do Lançamento Tabelado deve ser recalculado
@Param    lRecTaxFat  Indica se o valor de taxa faturada do Lançamento Tabelado deve ser recalculado
@Param    cMdTabNovo  Indica a moeda da nova Tabela de Serviços

@author Jacques Alves Xavier
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FVlrSrv(cCodHis, cCodSrv, lRecHonFat, lRecTaxFat, cMdTabNovo)
Local oModel    := FWModelActive()
Local nHonQtd   := 0
Local nTaxQtd   := 0
Local nHonExt   := 0
Local nTaxExt   := 0
Local nVlrHon   := 0
Local nVlrTax   := 0
Local lShowVirt := !JurIsRest() // Inclui os campos virtuais nos structs somente se não for REST (Necessário já que os inicializadores dos campos virtuais são executados sempre, mesmo sem o uso do header FIELDVIRTUAL = TRUE)

Default lRecHonFat := .T.
Default lRecTaxFat := .T.

NTS->(dbSetOrder(3))
If NTS->(dbSeek(xFilial('NTS') + cCodHis + cCodSrv))
	oModel:LoadValue('NV4MASTER', 'NV4_CMOED', NTS->NTS_MOEDAT)
	If lShowVirt
		oModel:LoadValue('NV4MASTER', 'NV4_DMOED', Left(Posicione('CTO', 1, xFilial('CTO') + oModel:GetValue('NV4MASTER', 'NV4_CMOED'), 'CTO_SIMB'), TamSX3('NV4_DMOED')[1]))
	EndIf
	If !Empty(cMdTabNovo)
		oModel:LoadValue('NV4MASTER', 'NV4_CMOEH', cMdTabNovo)
		If lShowVirt
			oModel:LoadValue('NV4MASTER', 'NV4_DMOEH', Left(Posicione('CTO', 1, xFilial('CTO') + oModel:GetValue('NV4MASTER', 'NV4_CMOEH'), 'CTO_SIMB'), TamSX3('NV4_DMOEH')[1]))
		EndIf
	EndIf

	If FWFldGet('NV4_QUANT') > 0
		nHonExt := oModel:GetValue('NV4MASTER', 'NV4_QUANT') - NTS->NTS_MAXSER
		nHonExt := IIf(nHonExt > 0, nHonExt, 0)
		nHonQtd := oModel:GetValue('NV4MASTER', 'NV4_QUANT') - nHonExt
		nVlrHon := NTS->NTS_VALORH + (NTS->NTS_ADISER * nHonExt)
		oModel:SetValue('NV4MASTER', 'NV4_VLHTAB', nVlrHon)
		If lRecHonFat
			oModel:SetValue('NV4MASTER', 'NV4_VLHFAT', nVlrHon)
		EndIf
	Else
		oModel:SetValue('NV4MASTER', 'NV4_VLHTAB', 0)
		If lRecHonFat
			oModel:SetValue('NV4MASTER', 'NV4_VLHFAT', 0)
		EndIf
	EndIf

	If FWFldGet('NV4_QUANT') > 0
		nTaxExt := oModel:GetValue('NV4MASTER', 'NV4_QUANT') - NTS->NTS_MAXTAX
		nTaxExt := IIf(nTaxExt > 0, nTaxExt, 0)
		nTaxQtd := oModel:GetValue('NV4MASTER', 'NV4_QUANT') - nTaxExt
		nVlrTax := NTS->NTS_VALORT + (NTS->NTS_ADITAX * nTaxExt)
		oModel:SetValue('NV4MASTER', 'NV4_VLDTAB', nVlrTax)
		If lRecTaxFat
			oModel:SetValue('NV4MASTER', 'NV4_VLDFAT', nVlrTax)
		EndIf
	Else
		oModel:SetValue('NV4MASTER', 'NV4_VLDTAB', 0)
		If lRecTaxFat
			oModel:SetValue('NV4MASTER', 'NV4_VLDFAT', 0)
		EndIf
	EndIf
Else
	oModel:SetValue('NV4MASTER', 'NV4_VLHTAB', 0)
	oModel:SetValue('NV4MASTER', 'NV4_VLDTAB', 0)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA027ATLAM
Função para atualizar o anomes com base na data do lançamento

@Return cAM	 		AnoMes com base na data do lançamento

@author Jacques Alves Xavier
@since 12/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA027ATLAM()
Local oModel := FWModelActive()
Local dData  := oModel:GetValue("NV4MASTER", 'NV4_DTLANC')
Local cAM    := ' '

cAM := AnoMes(dData)

Return cAM

//-------------------------------------------------------------------
/*/{Protheus.doc} JA027VLCLC
Função para bloquear o campo enquanto os campos Cliente, Loja e Caso estiverem em branco

@Param  cCampo   Campo a ser validado

@Return cRet	 		.T. ou .F.

@author Jacques Alves Xavier
@since 18/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA027VLCLC(cCampo)
Local lRet   := .F.
Local aSQL   := {}
Local cSQL   := JA027SQL('1')
Local xValor := Nil

Do Case
Case cCampo == 'NV4_CTPSRV'
	If !Empty(FWFldGet('NV4_CCLIEN')) .And. !Empty(FWFldGet('NV4_CLOJA')) .And. !Empty(FWFldGet('NV4_CCASO'))
		lRet := .T.
	EndIf

Case cCampo == 'NV4_CCASO'
	If SuperGetMV('MV_JCASO1',, '1') == '1'
		If !Empty(FWFldGet('NV4_CCLIEN')) .And. !Empty(FWFldGet('NV4_CLOJA'))
			lRet := .T.
		EndIf
	Else
		lRet := .T.
	EndIf

Case cCampo == 'NV4_CMOEH'
	If IsInCallStack('JURA202')
		lRet := .F.
	Else
		aSQL := JurSQL(cSQL, {"MOEDA", "MOEDA_TAXA"})

		If Empty( aSQL )
			lRet := .T.

		ElseIf !Empty(aSQL[1][1])
			xValor := &(READVAR())
			lRet   := aSQL[1][1] == xValor
		EndIf
	EndIF

Case cCampo == 'NV4_CMOED'
	If IsInCallStack('JURA202')
		lRet := .F.
	Else
		aSQL := JurSQL(cSQL, {"MOEDA", "MOEDA_TAXA"})

		If Empty( aSQL )
			lRet := .T.

		ElseIf !Empty(aSQL[1][2])
			xValor := &(READVAR())
			lRet   := aSQL[1][2] == xValor
		EndIf

	EndIf
EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA027IdiTB
Retorna o texto sugerido para a desrição do tabelado conforme o idioma do contrato

@Param  cCampo  O campo a ser retornado

@author Jacques Alves Xavier
@since 18/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA027IdiTB(cCampo, cpCliente, cpLoja, cpCaso, cpTpSrv)
local cTexto      := ""
local cIdioma     := ""
local cCliente    := ""
local cCaso       := ""
local cLoja       := ""
local cCodTB      := ""
Local cQuery      := ""
Local cResQRY     := Nil
Local aArea       := GetArea()

Default cpCliente := "NV4_CCLIEN"
Default cpLoja    := "NV4_CLOJA"
Default cpCaso    := "NV4_CCASO"
Default cpTpSrv   := "NV4_CTPSRV"

cCliente := FwFldGet(cpCliente)
cLoja    := FwFldGet(cpLoja)
cCaso    := FwFldGet(cpCaso)
cCodTB   := FwFldGet(cpTpSrv)

cIdioma  := JurGetDados("NVE", 1, xFilial("NVE") + cCliente + cLoja + cCaso, 'NVE_CIDIO')

If !Empty(cIdioma)
	cQuery := " SELECT R_E_C_N_O_ NR3RECNO "
	cQuery +=   " FROM " + RetSqlName("NR3") + " NR3 "
	cQuery +=  " WHERE NR3.NR3_FILIAL = '" + xFilial("NTR") + "' "
	cQuery +=    " AND NR3.NR3_CITABE =  '" + cCodTB + "'"
	cQuery +=    " AND NR3.NR3_CIDIOM = '" + cIdioma + "'"
	cQuery +=    " AND NR3.D_E_L_E_T_ = ' ' "

	cResQRY := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

	If (cResQRY)->NR3RECNO > 0
		NR3->( dbGoTo( (cResQRY)->NR3RECNO ) )
		Do Case
		Case cCampo == "NV4_DTPSRV" .Or. cCampo == "NWM_DESCRI"
			cTexto := NR3->NR3_DESCHO
		OtherWise
			cTexto := NR3->NR3_NARRAP
		End Case
	EndIf

	(cResQRY)->( dbCloseArea() )

EndIf

RestArea( aArea )

Return AllTrim(cTexto)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA027DESCS
Função para retornar a descrição dos campos:
Descricao Tipo Servico
Descricao do Lancamento
Melhoria de performace na abertura da tela de operaçoes de pré-fatura.

@param 	cCampo	"NV4_DTPSRV" ou "NV4_DESCRI"

@Return cRet	 	Retorna a descrição com base no idioma do caso do Lançamento Tabelado

@author Luciano Pereira dos Santos
@since 18/02/2010
@version 2.0
/*/
//-------------------------------------------------------------------
Function JA027DESCS(cCampo)
Local aArea      := GetArea()
Local cRet       := ""
Local cIdio      := ""
Local oModel     := Nil
Local oModelNX1  := Nil

	Do Case
	Case cCampo == "NV4_DGRUPO"
		If !Empty(NV4->NV4_CGRUPO)
			cRet := Posicione('ACY', 1, XFILIAL('ACY') + NV4->NV4_CGRUPO, 'ACY_DESCRI')
		EndIf

	Case cCampo == "NV4_DCLIEN"
		oModel    := FWModelActive()
		If oModel != Nil .And. oModel:GetId() == "JURA202"
			oModelNX1 := oModel:GetModel('NX1DETAIL')
			cRet      := oModelNX1:GetValue('NX1_DCLIEN')
		Else
			cRet := Posicione('SA1', 1, xFilial('SA1') + NV4->NV4_CCLIEN + NV4->NV4_CLOJA, 'A1_NOME' )
		EndIf

	Case cCampo == "NV4_DCASO"
		oModel    := FWModelActive()
		If oModel != Nil .And. oModel:GetId() == "JURA202"
			oModelNX1 := oModel:GetModel('NX1DETAIL')
			cRet      := oModelNX1:GetValue('NX1_DCASO')
		Else
			cRet := Posicione('NVE', 1, xFilial('NVE') + NV4->NV4_CCLIEN + NV4->NV4_CLOJA + NV4->NV4_CCASO, 'NVE_TITULO')
		EndIf

	Case cCampo == 'NV4_DTPSRV'
		oModel    := FWModelActive()
		If oModel != Nil .And. oModel:GetId() == "JURA202"
			oModelNX1 := oModel:GetModel('NX1DETAIL')
			cIdio     := oModelNX1:GetValue('NX1_CIDIO')
		Else
			cIdio := Posicione('NVE', 1, xFilial('NVE') + NV4->NV4_CCLIEN + NV4->NV4_CLOJA + NV4->NV4_CCASO, 'NVE_CIDIO')
		EndIf
		If !Empty(cIdio)
			cRet  := Posicione('NR3', 2, xFilial('NR3') + NV4->NV4_CTPSRV + cIdio, 'NR3_DESCHO')
		EndIf

	Case cCampo == 'NV4_DESCRI'
		oModel    := FWModelActive()
		If oModel != Nil .And. oModel:GetId() == "JURA202"
			oModelNX1 := oModel:GetModel('NX1DETAIL')
			cIdio     := oModelNX1:GetValue('NX1_CIDIO')
		Else
			cIdio := Posicione('NVE', 1, xFilial('NVE') + NV4->NV4_CCLIEN + NV4->NV4_CLOJA + NV4->NV4_CCASO, 'NVE_CIDIO')
		EndIf

		If !Empty(cIdio)
			cRet  := Posicione('NR3', 2, xFilial('NR3') + NV4->NV4_CTPSRV + cIdio, 'NR3_NARRAP')
		EndIf

	Case cCampo == 'NWM_DTPSRV'
		cRet := Posicione('NRD', 1, XFilial('NRD') + NWM->NWM_CTPSRV, 'NRD_DESCH')

	EndCase

	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURNTS
Verifica se o valor do campo de tabelado é válido quando o mesmo o
digita no campo

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Jacques Alves Xavier
@since 19/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURNTS()
Local lRet     := .F.
Local aArea    := GetArea()
Local aAreaNTS := NTS->(GetArea())
Local cResQRY  := GetNextAlias()
Local cQuery   := ''
Local aArrRet  := {}

aArrRet := FBusSrv(FWFldGet('NV4_CCLIEN'), FWFldGet('NV4_CLOJA'), FWFldGet('NV4_CCASO'), Left(DToS(FWFldGet('NV4_DTLANC')), 6))

cQuery := "SELECT NTS.NTS_CSERV "
cQuery +=  " FROM " + RetSqlName("NTS") + " NTS "
cQuery += " WHERE NTS.D_E_L_E_T_ = ' ' "
cQuery +=   " AND NTS.NTS_FILIAL = '" + xFilial("NTS") + "' "
cQuery +=   " AND NTS.NTS_CHIST = '" + aArrRet[1] + "' "

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cResQRY, .T., .T.)

While !(cResQRY)->(EOF())
	If (cResQRY)->NTS_CSERV == FWFldGet('NV4_CTPSRV')
		lRet := .T.
		Exit
	EndIf
	(cResQRY)->( dbSkip() )
EndDo

If !lRet
	JurMsgErro(STR0027) // Não é permitido vincular este código de Serviço Tabelado para este Cliente/Loja/Caso
EndIf

(cResQRY)->( dbcloseArea() )
RestArea(aAreaNTS)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA027VERPRE
Rotina para validar se exite pré-fatura para o Lançamento Tabelado

@author Jacques Alves Xavier
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA027VERPRE(cPreFat, oModel)
Local lRet     := .T.
Local aArea    := GetArea()
Local cPartLog := JurUsuario(__CUSERID)
Local dDtConc  := CToD( '  /  /  ' )
Local cStruct  := ""
Local lCobra   := .T.
Local lConclui := .T.
Local cCodTab  := ""

If oModel:GetId() == 'JURA202'
	cStruct := 'NV4DETAIL'
Else
	cStruct := 'NV4MASTER'
EndIf

If !Empty(cPartLog)
	cCodTab  := oModel:GetValue(cStruct, 'NV4_COD')
	lCobra   := oModel:GetValue(cStruct, 'NV4_COBRAR') == "1"
	lConclui := oModel:GetValue(cStruct, 'NV4_CONC') == "1"
	If !Empty(cPreFat)
		If (JurGetDados("NUR", 1, xFilial("NUR") + cPartLog, "NUR_LCPRE") == '1')

			If NX0->(dbSeek(xFilial('NX0') + cPreFat))
				If NX0->NX0_SITUAC $ '2|3|D|E' //Pré-Fatura alterável
					dDtConc := oModel:GetValue(cStruct, 'NV4_DTCONC')

					If !(dDtConc >= NX0->NX0_DINITB .And. dDtConc <= NX0->NX0_DFIMTB) .Or. !lCobra //fora do período da pré-fatura ou não cobrável, remove o lançamento
						If (lRet := oModel:LoadValue(cStruct, 'NV4_CPREFT', ''))

							JACanVinc('LT', cPreFat, cCodTab, .T.)

							If JurLancPre( cPreFat ) <= 1  // Verifica se era o último lançamento da pré para cancelar
								If JA202CANPF( cPreFat )
									J202HIST('5', cPreFat, cPartLog) //Insere o Histórico na pré-fatura
									If oModel:GetId() != 'JURA202' .And. !IsInCallStack("JURA142")
										ApMsgInfo(I18N(STR0064, {cPreFat}))
									Else
										AutoGrLog(I18N(STR0064+CRLF, {cPreFat}))  //# "A pré-fatura #1 foi cancelada por não conter mais lançamentos."
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				ElseIf NX0->NX0_SITUAC == '6' //Minuta Emitida

					lRet := J27VerAltM(oModel:GetModel(cStruct))
					If (!lRet)
						lRet := JurMsgErro(STR0056, , JMsgVerPre('1')) // "Não foi possível realizar as alterações, o lançamento possui minuta!"
					EndIf
				ElseIf NX0->NX0_SITUAC $ '5|7|9|A|B' //Emitir Minuta | Minuta Emitida | Minuta Cancelada | Minuta Sócio | Minuta Sócio Emitida | Minuta Sócio Cancelada
					lRet := JurMsgErro(STR0056, , JMsgVerPre('1')) // "Não foi possível realizar as alterações, o lançamento possui minuta!"
				ElseIf NX0->NX0_SITUAC == '4' //'Definitivo'
					lRet := JurMsgErro(STR0057, , JMsgVerPre('1')) // "Não foi possível realizar as alterações, o lançamento possui pré-fatura em Definifivo!"
				ElseIf NX0->NX0_SITUAC $ 'C|F' .And. Iif(FindFunction("JurIsRest"), !JurIsRest(), .T.) // Em Revisão ou Aguardando Sincronização - permitir o ajuste quando partir do REST
					lRet := JurMsgErro(STR0069, , JMsgVerPre('1')) // "Não foi possível realizar as alterações, o lançamento possui pré-fatura em processo de Revisão!"
				EndIf
			EndIf
		Else
			lRet := JurMsgErro(STR0063, , JMsgVerPre('2')) //"O participante não tem permissão para alterar Tabelado com Pré-faturas."
		EndIf
	Else
		If !lCobra .Or. !lConclui
			JACanVinc('LT', cPreFat, oModel:GetValue(cStruct, 'NV4_COD'), .T.)
		EndIf
	EndIf
Else
	lRet := JurMsgErro(STR0062, , JMsgVerPre('3')) //"O usuário logado não esta relacionado a nenhum participante."
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J27VerAltM(oModelNV4)
Verifica os campos que foram alterados

@param oModelNV4 - Modelo do Lançamento Tabelado

@author Willian Kazahaya
@since 26/01/2022
/*/
//-------------------------------------------------------------------
Static Function J27VerAltM(oModelNV4)
Return JVldAltMdl(oModelNV4, 1, {"NV4_DESCRI"})

//-------------------------------------------------------------------
/*/{Protheus.doc} JA027DTPS
Função para retornar a descrição do campo Descricao Tipo Servico na
consulta padrão
Uso Geral.

@Return cRet	 	Retorna a descrição com base no idioma do caso do Lançamento Tabelado

@author Juliana Iwayama Velho
@since 15/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA027DTPS()
Local cRet     := ""
Local cIdio    := ""

cIdio := Posicione('NVE', 1, xFilial('NVE') + NV4->NV4_CCLIEN + NV4->NV4_CLOJA + NV4->NV4_CCASO, 'NVE_CIDIO')
cRet  := Posicione('NR3', 2, xFilial('NR3') + NTS->NTS_CSERV + cIdio, 'NR3_DESCHO')

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA027CLEAR
Função para limpar os campos.
Uso Geral.

@Return lRet

@author André Godoi
@since 29/07/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA027CLEAR(oModel)
Local lRet      := .T.
Local lShowVirt := !JurIsRest() // Indica se os campos virtuais estão no modelo

oModel:ClearField('NV4MASTER', "NV4_CTPSRV")
IIf(lShowVirt, oModel:ClearField('NV4MASTER', "NV4_DTPSRV"), Nil)
oModel:ClearField('NV4MASTER', "NV4_QUANT")
oModel:ClearField('NV4MASTER', "NV4_CMOEH")
IIf(lShowVirt, oModel:ClearField('NV4MASTER', "NV4_DMOEH"), Nil)
oModel:ClearField('NV4MASTER', "NV4_VLHFAT")
oModel:ClearField('NV4MASTER', "NV4_VLHTAB")
oModel:ClearField('NV4MASTER', "NV4_CMOED")
IIf(lShowVirt, oModel:ClearField('NV4MASTER', "NV4_DMOED"), Nil)
oModel:ClearField('NV4MASTER', "NV4_VLDFAT")
oModel:ClearField('NV4MASTER', "NV4_VLDTAB")

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA027CM
Executa rotina ao comitar as alterações no Model

@Param oModel    - Modelo de dados de Despesa
@Param aVlCpoLD  - Array com os campos e valores referente ao ação LD

@author David G. Fernandes
@since 13/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA027CM(oModel, aVlCpoLD)
Local lRet       := .T.
Local aCampos    := {}
Local oModelNV4  := oModel:Getmodel("NV4MASTER")
Local cCodLT     := oModelNV4:getvalue('NV4_COD')
Local cClient    := oModelNV4:getvalue('NV4_CCLIEN')
Local cLoja      := oModelNV4:getvalue('NV4_CLOJA')
Local cCaso      := oModelNV4:getvalue('NV4_CCASO')
Local cPrefat    := oModelNV4:getvalue('NV4_CPREFT')
Local lCobra     := (oModelNV4:getvalue('NV4_COBRAR') == '1' .And. oModelNV4:getvalue('NV4_CONC') == '1')
Local nOperation := oModel:GetOperation()
Local lLote      := FWIsInCallStack("JURA109") .Or. FWIsInCallStack("JURA109A") .Or. JPELancLote("JURA027", nOperation) //Ponto de entrada que define se é um processamento em lote
Local lShowMsg   := !lLote

If nOperation != 5
	//Verifica se houve alteração no caso para ajustar ou excluir a pré-fatura / Ajusta o vínculo da conferência
	If cClient + cLoja + cCaso != NV4->(NV4_CCLIEN + NV4_CLOJA + NV4_CCASO) .OR. (oModel:GetValue("NV4MASTER", "NV4_ACAOLD") == "1")

		JAALTCASO(cPrefat, "NV4MASTER", "NV4", cCodLT, cClient, cLoja, cCaso )
		// Ajusta Flags na transferência via Legal Desk
		If FindFunction("JURFlagLD")
			JURFlagLD(oModel, "NV4", "NW4")
		EndIf
	EndIf

	//Limpar os campos de operação do Legal Desk
	If FindFunction("JurClearLD")
		aVlCpoLD := JurClearLD(oModel, "NV4MASTER", "NV4") //Limpar os campos de operação do Legal Desk
	EndIf

EndIf

aAdd(aCampos,{NV4->NV4_CCLIEN, cClient})
aAdd(aCampos,{NV4->NV4_CLOJA,  cLoja})
aAdd(aCampos,{NV4->NV4_CCASO,  cCaso})
aAdd(aCampos,{NV4->NV4_DTLANC, oModelNV4:GetValue('NV4_DTLANC')})
aAdd(aCampos,{NV4->NV4_CPREFT, oModelNV4:GetValue('NV4_CPREFT')}) // Necessário refazer o GetValue aqui pois a função JAALTCASO limpa esse campo dependendo da situação

JurShowPf('NV4', 'LT', nOperation, aCampos, , lCobra, cCodLT, lShowMsg) //Informa se o LT esta sendo tirado/colocado em um caso que possui pré-fatura

If nOperation == 5 .And. !Empty(cPrefat)
	//Verifica se há outros lançamentos na pré-fatura para cancelá-la se necessário
	If (JurLancPre( cPrefat ) <= 1)
		JA202CANPF( cPrefat )
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA027SRVMOE
Executa rotina para o retorno/inserção da moeda e taxa

@param lGatilho - Se .T. Retorna o valor da volor da moeda/taxa
                     .F. (padrão) Insere o valor da moeda no moedel e retorna lógico se foi concluído com êxito

@author TOTVS
@since 10/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA027SRVMOE(oModel, nTipo, lGatilho)
Local xRet       := Nil
Local cSQL       := JA027SQL('1')
Local aSQL       := {}
Local cVal       := ""
Local lShowVirt  := !JurIsRest() // Inclui os campos virtuais nos structs somente se não for REST (Necessário já que os inicializadores dos campos virtuais são executados sempre, mesmo sem o uso do header FIELDVIRTUAL = TRUE)

Default oModel   := Nil
Default lGatilho := .F.

aSQL := JurSQL(cSQL, {"MOEDA", "MOEDA_TAXA"})

If !Empty( aSQL ) .And. !Empty(aSQL[1][nTipo])
	cVal := aSQL[1][nTipo]

	Do Case
	Case !lGatilho .AND. nTipo == 1
		xRet := oModel:LoadValue('NV4MASTER','NV4_CMOEH', cVal)
		If lShowVirt
			xRet := oModel:LoadValue('NV4MASTER','NV4_DMOEH', Left(Posicione('CTO', 1, xFilial('CTO') + oModel:GetValue('NV4MASTER', 'NV4_CMOEH'), 'CTO_SIMB'), TamSX3('NV4_DMOEH')[1]))
		EndIf

	Case !lGatilho .AND. nTipo == 2
		xRet := oModel:LoadValue('NV4MASTER','NV4_CMOED', cVal)
		If lShowVirt
			xRet := oModel:LoadValue('NV4MASTER','NV4_DMOED', Left(Posicione('CTO', 1, xFilial('CTO') + oModel:GetValue('NV4MASTER', 'NV4_CMOED'), 'CTO_SIMB'), TamSX3('NV4_DMOED')[1]))
		EndIf
	End Case

Else
	If(lGatilho)
		cVal := Iif(nTipo == 1, FwFldGet("NV4_CMOEH"), FwFldGet("NV4_CMOED"))
	Else
		xRet := .T.
	EndIf

EndIf

Iif(lGatilho, xRet := cVal,)

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA027SQL()
Retorna o Select

@Param cTipo: 1 - Retorna select para retornar as moedas do serviço tabelado

@author Jacques Alves Xavier
@since 20/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA027SQL(cTipo)
Local cSQL   := ""

If cTipo == '1'
	cSQL += " SELECT NRE.NRE_MOEDA MOEDA, NS5.NS5_MOEDAT MOEDA_TAXA "
	cSQL += "  FROM " + RetSqlName("NS5") +" NS5 "
	cSQL += " INNER JOIN " + RetSqlName("NRE") + " NRE "
	cSQL += "    ON NS5.NS5_CTAB = NRE.NRE_COD "
	cSQL += "   AND NRE.NRE_FILIAL = '" + xFilial("NRE") + "' "
	cSQL += "   AND NRE.D_E_L_E_T_ = ' ' "
	cSQL += " INNER JOIN " + RetSqlName("NVE") + " NVE "
	cSQL += "    ON NRE.NRE_COD = NVE_CTABS "
	cSQL += "   AND NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
	cSQL += "   AND NVE.D_E_L_E_T_ = ' ' "
	cSQL += "   AND NVE.NVE_CCLIEN = '" + FwFldGet("NV4_CCLIEN") + "' "
	cSQL += "   AND NVE.NVE_LCLIEN = '" + FwFldGet("NV4_CLOJA") + "' "
	cSQL += "   AND NVE.NVE_NUMCAS = '" + FwFldGet("NV4_CCASO") + "' "
	cSQL += " Where NS5.NS5_FILIAL = '" + xFilial("NS5") + "' "
	cSQL += "   AND NS5.D_E_L_E_T_ = ' ' "
	cSQL += "   AND NS5_CSERV = '" + FwFldGet("NV4_CTPSRV") + "' "
EndIf

Return cSQL

//-------------------------------------------------------------------
/*/ { Protheus.doc } J027CPW()
Rotina para validar o modo de edição do campo NV4_FINANC

@author Luciano Pereira dos Santos
@since 01/06/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J027CPW()
Local lRet  := .F.

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J027LegPag
Exibe a legenda da tela de "Contas a Pagar - Lanc. Tabelado"

@param cCadastro

@Return Nil

@author Luciano P. Santos
@since 12/06/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function J027LegPag(cCadastro)
Local aCores      := {}
Default cCadastro := STR0045 //"Contas a Pagar - Lanc. Tabelado"

aAdd( aCores, { "BR_VERMELHO", STR0046 } ) // "Titulo Baixado"
aAdd( aCores, { "BR_AZUL"    , STR0047 } ) // "Baixado Parcialmente"
aAdd( aCores, { "BR_VERDE"   , STR0048 } ) // "Titulo em Aberto"

BrwLegenda( cCadastro, OemToAnsi(STR0049), aCores ) // "Status"

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JCall142()
Função chamar a rotina JURA142 sem carregar as configurações de botão do XNU.

@author Jacques Alves Xavier
@since 02/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall142()
Local cAceAnt  := AcBrowse
Local cFunName := FunName()

// JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA027 inserida no XNU.
AcBrowse := Replicate("x", 10)
SetFunName( 'JURA142' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA142

JURA142()

SetFunName( cFunName )
AcBrowse := cAceAnt

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J27CasNam
Gatilho preencher o campo Nome cliente

@author Rafael Rezende Costa
@since 14/06/13
@version 1.1
/*/
//-------------------------------------------------------------------
Function J27CasNam()
Local cRet     := ""
Local oModel   := FWModelActive()
Local aArea    := GetArea()
Local cClien   := oModel:GetValue("NV4MASTER", "NV4_CCLIEN")
Local cLoja    := oModel:GetValue("NV4MASTER", "NV4_CLOJA")

If !Empty(cClien) .And. !Empty(cLoja)
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	If ( SA1->(dbSeek(xFilial("SA1") + cClien + cLoja )) )
		cRet := SA1->A1_NOME
	EndIf
EndIf

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  JA027Recalc()
Função que levanta os dados necessários para que ao alterar o caso do
Lançamento Tabelado, os valores sejam recalculados (função FVlrSrv).

@author Cristina Cintra
@since 10/09/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA027Recalc()
Local oModel     := FWModelActive()
Local aArea      := GetArea()
Local aAreaNU1   := NU1->(GetArea())
Local aAreaNUU   := NUU->(GetArea())
Local cCodTab    := ""  //Código do lançamento tabelado
Local cTpServ    := ""  //Código do tipo de serviço do lançamento tabelado
Local cTabNovo   := ""  //Código da Tabela de Serviços do novo caso
Local cCodHist   := ""  //Código do histórico da nova Tabela de Serviços
Local cAnoMes    := ""  //Ano-Mês do lançamento
Local cMdTabNovo := ""  //Moeda da Tabela de Serviços do novo caso
Local cCliNovo   := ""  //Cliente novo
Local cLojNovo   := ""  //Loja nova
Local cCasoNovo  := ""  //Caso novo
Local cTabLanc   := ""  //Código da Tabela de Serviços do caso do lançamento (original)
Local cCliLanc   := ""  //Cliente do lançamento (original)
Local cLojLanc   := ""  //Loja do lançamento (original)
Local cCasoLanc  := ""  //Caso do lançamento (original)
Local cMdTabLanc := ""  //Moeda da Tabela de Serviços do lançamento (original)
Local nVHonTab   := 0
Local nVHonFat   := 0
Local nVTaxTab   := 0
Local nVTaxFat   := 0
Local lRecHonFat := .T.
Local lRecTaxFat := .T.
Local lRet       := .T.

cCodTab   := oModel:GetValue("NV4MASTER", "NV4_COD")
cTpServ   := oModel:GetValue("NV4MASTER", "NV4_CTPSRV")

cCliNovo  := oModel:GetValue("NV4MASTER", "NV4_CCLIEN")
cLojNovo  := oModel:GetValue("NV4MASTER", "NV4_CLOJA")
cCasoNovo := oModel:GetValue("NV4MASTER", "NV4_CCASO")

cCliLanc  := Posicione("NV4", 1, xFilial("NV4") + cCodTab, "NV4_CCLIEN")
cLojLanc  := Posicione("NV4", 1, xFilial("NV4") + cCodTab, "NV4_CLOJA")
cCasoLanc := Posicione("NV4", 1, xFilial("NV4") + cCodTab, "NV4_CCASO")

If oModel:IsFieldUpdated('NV4MASTER', 'NV4_CCASO') .And. (Alltrim(cCliNovo + cLojNovo + cCasoNovo) <> Alltrim(cCliLanc + cLojLanc + cCasoLanc))

	cAnoMes := oModel:GetValue("NV4MASTER", "NV4_ANOMES")

	//Verificação da Tabela de Serviços do novo caso
	NUU->(dbGoTop())
	NUU->(dbSetOrder(1))
	If !Empty(cAnoMes) .And. NUU->(dbSeek(xFilial('NUU') + cCliNovo + cLojNovo + cCasoNovo))
		While !NUU->(Eof()) .And. NUU->(NUU_FILIAL + NUU_CCLIEN + NUU_CLOJA + NUU_CCASO) ==  xFilial('NUU') + cCliNovo + cLojNovo + cCasoNovo
			If cAnoMes >= NUU->NUU_AMINI .And. (cAnoMes <= NUU->NUU_AMFIM .OR. Empty(NUU->NUU_AMFIM))
				cTabNovo := NUU->NUU_CTABS
				Exit
			EndIf
			NUU->(dbSkip())
		End
	EndIf

	//Verificação da Tabela de Serviços do caso do lançamento (original)
	NUU->(dbGoTop())
	NUU->(dbSetOrder(1))
	If !Empty(cAnoMes) .And. NUU->(dbSeek(xFilial('NUU') + cCliLanc + cLojLanc + cCasoLanc))
		While !NUU->(Eof()) .And. NUU->(NUU_FILIAL + NUU_CCLIEN + NUU_CLOJA + NUU_CCASO) ==  xFilial('NUU') + cCliLanc + cLojLanc + cCasoLanc
			If cAnoMes >= NUU->NUU_AMINI .And. (cAnoMes <= NUU->NUU_AMFIM .OR. Empty(NUU->NUU_AMFIM))
				cTabLanc := NUU->NUU_CTABS
				Exit
			EndIf
			NUU->(dbSkip())
		End
	EndIf

	//Quando houver alteração para caso sem Tabela de Serviços os campos NV4_VLHTAB e NV4_VLDTAB serão zerados
	If Empty(cTabNovo)
		lRet := oModel:SetValue("NV4MASTER", "NV4_VLHTAB", 0)
		If lRet
			lRet := oModel:SetValue("NV4MASTER", "NV4_VLDTAB", 0)
		EndIf
	EndIf

	//Quando houver alteração para caso com Tabela de Serviços diferente da que estava no lançamento será verificada a moeda de cada tabela
	If lRet .And. !Empty(cTabNovo) .And. (Alltrim(cTabNovo) <> Alltrim(cTabLanc))
		//Verificação da moeda Tabela de Serviços do caso do lançamento (original)
		NU1->(dbGoTop())
		NU1->(dbSetOrder(1))
		NU1->(dbSeek(xFilial('NU1') + cTabLanc))
		While !NU1->(Eof()) .And. NU1->(NU1_FILIAL + NU1_CTAB) == xFilial('NUU') + cTabLanc
			If cAnoMes >= NU1->NU1_AMINI .And. (cAnoMes <= NU1->NU1_AMFIM .Or. Empty(NU1->NU1_AMFIM))
				cMdTabLanc := NU1->NU1_CMOEDA
				Exit
			EndIf
			NU1->(dbSkip())
		EndDo

		//Verificação da moeda Tabela de Serviços do caso novo
		NU1->(dbGoTop())
		NU1->(dbSetOrder(1))
		NU1->(dbSeek(xFilial('NU1') + cTabNovo))
		While !NU1->(Eof()) .And. NU1->(NU1_FILIAL + NU1_CTAB) == xFilial('NUU') + cTabNovo
			If cAnoMes >= NU1->NU1_AMINI .And. (cAnoMes <= NU1->NU1_AMFIM .Or. Empty(NU1->NU1_AMFIM))
				cMdTabNovo := NU1->NU1_CMOEDA
				cCodHist   := NU1->NU1_COD
				Exit
			EndIf
			NU1->(dbSkip())
		EndDo

		nVHonTab := oModel:GetValue("NV4MASTER", "NV4_VLHTAB")
		nVHonFat := oModel:GetValue("NV4MASTER", "NV4_VLHFAT")
		nVTaxTab := oModel:GetValue("NV4MASTER", "NV4_VLDTAB")
		nVTaxFat := oModel:GetValue("NV4MASTER", "NV4_VLDFAT")

		If Alltrim(cMdTabLanc) == Alltrim(cMdTabNovo) .Or. Empty(cMdTabLanc)
			If nVHonTab <> nVHonFat //Só recalcular o valor faturado se ele estiver igual ao tabelado
				lRecHonFat := .F.
			EndIf
			If nVTaxTab <> nVTaxFat //Só recalcular a taxa faturada se ela estiver igual ao tabelado
				lRecTaxFat := .F.
			EndIf
			FVlrSrv(cCodHist, cTpServ, lRecHonFat, lRecTaxFat, cMdTabNovo) //Rotina de recálculo dos valores do lançamento tabelado
		Else
			FVlrSrv(cCodHist, cTpServ, lRecHonFat, lRecTaxFat, cMdTabNovo) //Rotina de recálculo dos valores do lançamento tabelado
		EndIf
	EndIf

EndIf

RestArea(aAreaNU1)
RestArea(aAreaNUU)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA027Gat
Gatilho da data de conclusão do tabelado

@author Cristina Cintra Santos
@since 05/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA027Gat()
Local aArea    := GetArea()
Local dRet     := CToD( '' )
Local lRet     := .T.
Local dDtDemis
Local dDtLanc

If M->NV4_CONC == '1'
	If !Empty(FWFLDGET("NV4_SIGLA"))
		lRet := (ExistCpo("RD0", FWFLDGET("NV4_SIGLA"), 9,,, .F.) .AND. JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NV4_SIGLA"), 'RD0_TPJUR') == "1")
		If lRet
			dDtDemis := JurGetDados('RD0', 9, xFilial('RD0') + FWFLDGET("NV4_SIGLA"), 'RD0_DTADEM')
			If !Empty(dDtDemis)

				dDtLanc := Date()

				If dDtDemis >= dDtLanc
					lRet := .T.
					dRet := Date()
				Else
					APMsgInfo(STR0065) //"Não foi possível sugerir a Data de Conclusão, pois o participante do lançamento encontra-se demitido."
					lRet := .F.
				EndIf
			Else
				dRet := Date()
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return dRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J027ClxCa()
Rotina para verificar se o cliente/loja pertece ao caso.
Utilizado para condição de gatilho

@Return - lRet  .T. quando o cliente PERTENCE ao caso informado OU
                .F. quando o cliente NÃO pertence ao caso informado

@author Bruno Ritter
@since 26/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J027ClxCa()
Local lRet      := .F.
Local oModel    := FWModelActive()
Local cClien    := ""
Local cLoja     := ""
Local cCaso     := ""
Local cIDNV4    := IIf( oModel:GetId() == 'JURA202', "NV4DETAIL", "NV4MASTER" )

cClien    := oModel:GetValue(cIDNV4, "NV4_CCLIEN")
cCaso     := oModel:GetValue(cIDNV4, "NV4_CCASO")
cLoja     := oModel:GetValue(cIDNV4, "NV4_CLOJA")

lRet := JurClxCa(cClien, cLoja, cCaso)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J027ClxGr()
Rotina para verificar se o cliente/loja pertence ao grupo.
Usado nos gatilhos de Grupo

@Return - lRet  .T. quando o cliente PERTENCE ao grupo informado OU
                .F. quando o cliente NÃO pertence ao grupo informado

@author Bruno Ritter
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J027ClxGr()
Local lRet     := .T.
Local oModel   := FwModelActive()
Local cClien   := ''
Local cLoja    := ''
Local cGrupo   := ''
Local cStruct  := ''

If oModel:GetId() == 'JURA202'
	cStruct := 'NV4DETAIL'
Else
	cStruct := 'NV4MASTER'
EndIf

cGrupo  := oModel:GetValue(cStruct, 'NV4_CGRUPO')
cClien  := oModel:GetValue(cStruct, 'NV4_CCLIEN')
cLoja   := oModel:GetValue(cStruct, 'NV4_CLOJA')

lRet := JurClxGr(cClien, cLoja, cGrupo)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J027QryTmp()
Rotina para gerar uma query da NV4 para gerar a tabela temporária na função JurCriaTmp

@author bruno.ritter
@since 31/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J027QryTmp(cNvCampos)
Local cQry      := ""
Local cCampos   := JurCmpSelc("NV4")
Local aCamposJL := {}
Local cCamposJL := ''

	cCampos := StrTran(cCampos, "NV4_OK    ,")
	Aadd(aCamposJL,{"ACY.ACY_DESCRI" , "NV4_DGRUPO" })
	Aadd(aCamposJL,{"SA1.A1_NOME"    , "NV4_DCLIEN" })
	Aadd(aCamposJL,{"NVE.NVE_TITULO" , "NV4_DCASO"  })
	Aadd(aCamposJL,{"RD0.RD0_SIGLA"  , "NV4_SIGLA"  })
	Aadd(aCamposJL,{"RD0.RD0_NOME"   , "NV4_DPART"  })
	Aadd(aCamposJL,{"CTOH.CTO_SIMB"  , "NV4_DMOEH"  })
	Aadd(aCamposJL,{"CTOD.CTO_SIMB"  , "NV4_DMOED"  })
	Aadd(aCamposJL,{"NR3.NR3_DESCHO" , "NV4_DTPSRV" })

	cCamposJL := JurCaseJL(aCamposJL)

	cQry := "SELECT "+ cCampos + cCamposJL + CRLF
	cQry += " ' ' NV4_OK" + cNvCampos
	cQry +=     " FROM " + RetSqlName( 'NV4' ) + " NV4 "
	cQry += " LEFT JOIN "+ RetSqlName( 'ACY' ) + " ACY "
	cQry +=                                         " ON ACY.ACY_GRPVEN = NV4.NV4_CGRUPO "
	cQry +=                                         " AND ACY.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND ACY.ACY_FILIAL = '" + xFilial("ACY") + "' "
	cQry += " INNER JOIN "+ RetSqlName( 'SA1' ) + " SA1 "
	cQry +=                                         " ON SA1.A1_COD = NV4.NV4_CCLIEN "
	cQry +=                                         " AND SA1.A1_LOJA = NV4.NV4_CLOJA "
	cQry +=                                         " AND SA1.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQry += " INNER JOIN "+ RetSqlName( 'NVE' ) + " NVE "
	cQry +=                                         " ON NVE.NVE_CCLIEN = NV4.NV4_CCLIEN "
	cQry +=                                         " AND NVE.NVE_LCLIEN = NV4.NV4_CLOJA "
	cQry +=                                         " AND NVE.NVE_NUMCAS = NV4.NV4_CCASO "
	cQry +=                                         " AND NVE.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
	cQry += " INNER JOIN "+ RetSqlName( 'RD0' ) + " RD0 "
	cQry +=                                         " ON RD0.RD0_CODIGO = NV4.NV4_CPART "
	cQry +=                                         " AND RD0.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQry += " INNER JOIN "+ RetSqlName( 'CTO' ) + " CTOH "
	cQry +=                                         " ON CTOH.CTO_MOEDA = NV4.NV4_CMOEH "
	cQry +=                                         " AND CTOH.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND CTOH.CTO_FILIAL = '" + xFilial("CTO") + "' "
	cQry += " LEFT JOIN "+ RetSqlName( 'CTO' ) + " CTOD "
	cQry +=                                         " ON CTOD.CTO_MOEDA = NV4.NV4_CMOED "
	cQry +=                                         " AND CTOD.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND CTOD.CTO_FILIAL = '" + xFilial("CTO") + "' "
	cQry += " LEFT JOIN "+ RetSqlName( 'NR3' ) + " NR3 "
	cQry +=                                         " ON NR3.NR3_CITABE = NV4.NV4_CTPSRV "
	cQry +=                                         " AND NR3.NR3_CIDIOM = NVE.NVE_CIDIO "
	cQry +=                                         " AND NR3.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND NR3.NR3_FILIAL = '" + xFilial("NR3") + "' "

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} J027DscCaso
Gatilho da descrição do caso, quando o usuário informa o numero do caso.

@author Julio de Paula Paz
@since 22/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J027DscCaso()
Local cRet      := ""
Local oModel    := FwModelActive()
Local aArea     := GetArea()
Local aAreNVE   := NVE->(GetArea())
Local cClien    := ''
Local cLoja     := ''
Local cCaso     := ''
Local cDescCaso := ""
Local cStruct   := ''

Begin Sequence
	If oModel:GetId() == 'JURA202'
		cStruct := 'NV4DETAIL'
	Else
		cStruct := 'NV4MASTER'
	EndIf

	cClien  := oModel:GetValue(cStruct, 'NV4_CCLIEN')
	cLoja   := oModel:GetValue(cStruct, 'NV4_CLOJA')
	cCaso   := oModel:GetValue(cStruct, 'NV4_CCASO')

	cDescCaso := Posicione('NVE', 1, xFilial('NVE') + oModel:GetValue(cStruct, 'NV4_CCLIEN') + oModel:GetValue(cStruct, 'NV4_CLOJA') + cCaso, 'NVE_TITULO')
	cDescCaso := AllTrim(cDescCaso)
	cRet := cDescCaso

End Sequence

RestArea(aAreNVE)
RestArea(aArea)

Return cRet
