#INCLUDE "JURA144.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

Static CUserLogado := ""
Static cPart1_old  := ''
Static nUt_old     := 0
Static nHrFra_old  := 0
Static cMrMin_old  := ""
Static oModelOld   := Nil
Static lIsLancOk   := .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA144
Time Sheets dos Profissionais

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA144()
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lVldUser   := Iif(FindFunction("JurVldUxP"), JurVldUxP(), .T.)
Local cFiltro    := ""

Private oBrowse  := Nil

If lVldUser
	oBrowse := FWMBrowse():New()
	oBrowse:SetMenuDef('JURA144')
	oBrowse:SetDescription( STR0007 )
	oBrowse:SetAlias("NUE")
	If FindFunction("JurBrwRev")
		Iif(cLojaAuto == "1", JurBrwRev(oBrowse, "NUE", {"NUE_CLOJA"}), )
	EndIf
	oBrowse:SetLocate()
	JurSetLeg(oBrowse, "NUE")
	JurSetBSize(oBrowse)
	
	If ExistBlock('JA144FIL')
		cFiltro := ExecBlock( 'JA144FIL', .F., .F. )
		If !Empty(cFiltro)
			oBrowse:SetFilterDefault( cFiltro )
		EndIf
	EndIf
	
	J144Filter(oBrowse, cLojaAuto) // Adiciona filtros padrões no browse

	oBrowse:Activate()
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J144Filter
Adiciona filtros padrões no browse

@param  oBrowse, objeto, browse da rotina

@author Reginaldo Borges / Cristina Cintra
@since  08/08/2022
/*/
//-------------------------------------------------------------------
Static Function J144Filter(oBrowse, cLojaAuto)
Local aFilNUE1 := {}
Local aFilNUE2 := {}
Local aFilNUE3 := {}
Local aFilNUE4 := {}
Local aFilNUE5 := {}
Local aFilNUE6 := {}
Local aFilNUE7 := {}

	SAddFilPar("NUE_CPART1", "==", "%NUE_CPART10%", @aFilNUE1)
	oBrowse:AddFilter(STR0165, 'NUE_CPART1 == "%NUE_CPART10%"', .F., .F., , .T., aFilNUE1, STR0165) // "Participante Lançado"

	SAddFilPar("NUE_CPART2", "==", "%NUE_CPART20%", @aFilNUE2)
	oBrowse:AddFilter(STR0166, 'NUE_CPART2 == "%NUE_CPART20%"', .F., .F., , .T., aFilNUE2, STR0166) // "Participante Revisado"

	SAddFilPar("NUE_SITUAC", "==", "%NUE_SITUAC0%", @aFilNUE3)
	oBrowse:AddFilter(STR0167, 'NUE_SITUAC == "%NUE_SITUAC0%"', .F., .F., , .T., aFilNUE3, STR0167) // "Situação"

	SAddFilPar("NUE_DATATS", ">=", "%NUE_DATATS0%", @aFilNUE4)
	oBrowse:AddFilter(STR0168, 'NUE_DATATS >= "%NUE_DATATS0%"', .F., .F., , .T., aFilNUE4, STR0168) // "Data Maior ou Igual a"

	SAddFilPar("NUE_DATATS", "<=", "%NUE_DATATS0%", @aFilNUE5)
	oBrowse:AddFilter(STR0169, 'NUE_DATATS <= "%NUE_DATATS0%"', .F., .F., , .T., aFilNUE5, STR0169) // "Data Menor ou Igual a"

	If cLojaAuto == "2"
		SAddFilPar("NUE_CCLIEN", "==", "%NUE_CCLIEN0%", @aFilNUE6)
		SAddFilPar("NUE_CLOJA", "==", "%NUE_CLOJA0%", @aFilNUE6)
		oBrowse:AddFilter(STR0170, 'NUE_CCLIEN == "%NUE_CCLIEN0%" .AND. NUE_CLOJA == "%NUE_CLOJA0%"', .F., .F., , .T., aFilNUE6, STR0170) // "Cliente"
	Else
		SAddFilPar("NUE_CCLIEN", "==", "%NUE_CCLIEN0%", @aFilNUE6)
		oBrowse:AddFilter(STR0170, 'NUE_CCLIEN == "%NUE_CCLIEN0%"', .F., .F., , .T., aFilNUE6, STR0170) // "Cliente"
	EndIf
	
	SAddFilPar("NUE_CCASO", "==", "%NUE_CCASO0%", @aFilNUE7)
	oBrowse:AddFilter(STR0172, 'NUE_CCASO == "%NUE_CCASO0%"', .F., .F., , .T., aFilNUE7, STR0172) // "Caso"

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina   := {}
Local aAux      := {}
Local nI        := 0
Local aUserButt := {}

aAdd( aRotina, { STR0001, "PesqBrw"                 , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA144"         , 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA144"         , 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA144"         , 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA144"         , 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0032, "JA144REVAL(NUE->NUE_COD)", 0, 6, 0, NIL } ) // "Revalorizar"
aAdd( aRotina, { STR0074, "JA144DivTS()"            , 0, 5, 0, NIL } ) // "Dividir TS"
aAdd( aRotina, { STR0087, "JCall145"                , 0, 3, 0, NIL } ) // "Oper. em Lote"
aAdd( aRotina, { STR0132, "JA144REPLI()"            , 0, 3, 0, NIL } ) // "Replicar TS"

// Obsoleto, usar o ponto do MVC abaixo
If ExistBlock( 'JA144BTN' )
	aAux := Execblock('JA144BTN', .F., .F.)
	If Valtype( aAux ) == 'A'
		For nI := 1 To Len(aAux)
			aAdd(aRotina, aAux[nI])
		Next
	EndIf
EndIf

// Ponto de entrada para acrescentar botões no menu
If ExistBlock( 'JURA144' )       // Mesmo ID do Modelo de Dados
	aUserButt := ExecBlock( 'JURA144', .F., .F., { NIL, "MENUDEF", 'JURA144' } )
	If ValType( aUserButt ) == 'A'
		aEval( aUserButt, { |aX| aAdd( aRotina, aX ) } )
	EndIf
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Time Sheets dos Profissionais

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView        := Nil
Local oModel       := FWLoadModel( "JURA144" )
Local oStructNUE   := FWFormStruct( 2, "NUE" )
Local oStructNW0   := FWFormStruct( 2, "NW0" ) //Dados do Faturamento
Local cLojaAuto    := SuperGetMv("MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lFSinc       := SuperGetMV("MV_JFSINC", .F., '2') == '1'
Local lRevisLD     := SuperGetMV("MV_JREVILD", .F., '2') == '1' //Controla a integracao da revisão de pré-fatura com o Legal Desk

oStructNUE:RemoveField("NUE_TKRET")
oStructNUE:RemoveField("NUE_OK")
oStructNUE:RemoveField("NUE_CPART1")
oStructNUE:RemoveField("NUE_CPART2")
oStructNUE:RemoveField("NUE_CUSERA")
oStructNUE:RemoveField("NUE_CCATEG")
oStructNUE:RemoveField("NUE_COTAC")
oStructNUE:RemoveField("NUE_ACAOLD")
oStructNUE:RemoveField("NUE_CCLILD")
oStructNUE:RemoveField("NUE_CLJLD")
oStructNUE:RemoveField("NUE_CCSLD")
oStructNUE:RemoveField("NUE_PARTLD")
oStructNUE:RemoveField("NUE_CMOTWO")
oStructNUE:RemoveField("NUE_OBSWO")
oStructNUE:RemoveField("NUE_CDWOLD")
oStructNUE:RemoveField("NUE_CREPRO")
If (cLojaAuto == "1")
	oStructNUE:RemoveField( "NUE_CLOJA" )
	oStructNW0:RemoveField( "NW0_CLOJA" )
EndIf
oStructNW0:RemoveField("NW0_CTS")
oStructNW0:RemoveField("NW0_CPART2")
oStructNW0:RemoveField("NW0_CPART1")
oStructNW0:RemoveField("NW0_TEMPOL")
oStructNW0:RemoveField("NW0_TEMPOR")
oStructNW0:RemoveField("NW0_VALORH")
oStructNW0:RemoveField("NW0_CMOEDA")
oStructNW0:RemoveField("NW0_DMOEDA")
oStructNW0:RemoveField("NW0_COTAC")

If !lFSinc
	oStructNW0:RemoveField( 'NW0_CCLICM' )
	oStructNW0:RemoveField( 'NW0_CLOJCM' )
	oStructNW0:RemoveField( 'NW0_CCASCM' )
EndIf

If !lRevisLD
	oStructNUE:RemoveField( 'NUE_FLUREV' )
	oStructNUE:RemoveField( 'NUE_SIGLAR' )
	oStructNUE:RemoveField( 'NUE_DREPRO' )
	oStructNUE:RemoveField( 'NUE_DTREPR' )
EndIf

If NUE->(FieldPos( "NUE_CODLD" )) > 0
	oStructNUE:RemoveField( 'NUE_CODLD' )
EndIf

JurSetAgrp( 'NUE',, oStructNUE )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA144_NUE", oStructNUE, "NUEMASTER"  )
oView:AddGrid(  "JURA144_NW0", oStructNW0, "NW0DETAIL"  )

oView:CreateHorizontalBox( "FORMFIELD" , 60,,,, )
oView:CreateHorizontalBox( "FORMFOLDER", 40,,,, )

oView:CreateFolder('FOLDER_01',"FORMFOLDER")
oView:AddSheet('FOLDER_01','ABA_NW0', STR0028) // Faturamento do Time Sheet
oView:CreateHorizontalBox("FORMFOLDER_NW0",100,,,'FOLDER_01','ABA_NW0')

oView:SetOwnerView( "JURA144_NUE" , "FORMFIELD" )
oView:SetOwnerView( "JURA144_NW0" , "FORMFOLDER_NW0" )

// Nao é Linux nem Web
If GetRemoteType() == 0 .Or. GetRemoteType() == 1

	hHdl := ExecInDLLOpen( "SIGAADDICT.DLL" )
	// Se a dll estiver acessível, adiciona a opção de correção de texto
	If hHdl >= 0 
		ExecInDllClose( hHdl )
		oView:AddUserButton( STR0016, "GCTIMG32_OCEAN", { || JURA144Bt1( oModel ) } ) //Botão - Corrigir Texto do TS
	EndIf
EndIf

oView:SetDescription( STR0007 ) // "Time Sheets dos Profissionais"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Time Sheets dos Profissionais

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local lShowVirt  := !JurIsRest() // Inclui os campos virtuais nos structs somente se não for REST (Necessário já que os inicializadores dos campos virtuais são executados sempre, mesmo sem o uso do header FIELDVIRTUAL = TRUE)
Local oStructNUE := FWFormStruct( 1, "NUE",,, lShowVirt )
Local oStructNW0 := FWFormStruct( 1, "NW0",,, lShowVirt )
Local lIsRest    := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))
Local oCommit    := JA144COMMIT():New()

If !lShowVirt
	// Adiciona os campos virtuais de "SIGLA" novamente nas estruturas, pois foram retirados via lShowVirt,
	// mas precisam existir para execução das operações nos lançamentos via REST
	AddCampo(1, "NUE_SIGLA1", @oStructNUE)
	AddCampo(1, "NUE_SIGLA2", @oStructNUE)
	AddCampo(1, "NUE_SIGLAA", @oStructNUE)
	AddCampo(1, "NUE_SIGLAR", @oStructNUE)
	AddCampo(1, "NW0_SIGLA1", @oStructNW0)
	AddCampo(1, "NW0_SIGLA2", @oStructNW0)
EndIf

oModel:= MPFormModel():New( "JURA144", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
oModel:AddFields( "NUEMASTER", NIL, oStructNUE, {|oM, cFun, cCamp|J144PreVld(oM, cFun, cCamp)} /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid( "NW0DETAIL", "NUEMASTER" /*cOwner*/, oStructNW0, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Time Sheets dos Profissionais"
oModel:GetModel( "NUEMASTER" ):SetDescription( STR0009 ) // "Dados de Time Sheets dos Profissionais"
oModel:GetModel( "NW0DETAIL" ):SetDescription( STR0028 ) // Faturamento do Time Sheet

oModel:SetRelation( "NW0DETAIL", { { "NW0_FILIAL", "xFilial('NW0')" }, { "NW0_CTS", "NUE_COD" } }, "R_E_C_N_O_" )
oModel:GetModel( "NW0DETAIL" ):SetDelAllLine( .T. )

// Bloqueia os campos para alteração
oStructNUE:SetProperty( 'NUE_VALORH', MODEL_FIELD_NOUPD, .T. )
oStructNUE:SetProperty( 'NUE_CMOEDA', MODEL_FIELD_NOUPD, .T. )
If !lIsRest
	oStructNUE:SetProperty( 'NUE_CPREFT', MODEL_FIELD_NOUPD, .T. )
EndIf
oStructNUE:SetProperty( 'NUE_VALOR' , MODEL_FIELD_NOUPD, .F. )
oStructNUE:SetProperty( 'NUE_VALOR1', MODEL_FIELD_NOUPD, .T. )
oStructNUE:SetProperty( 'NUE_CCATEG', MODEL_FIELD_NOUPD, .T. )
oStructNUE:SetProperty( 'NUE_COTAC' , MODEL_FIELD_NOUPD, .T. )
oStructNW0:SetProperty( 'NW0_COTAC' , MODEL_FIELD_NOUPD, .T. )

oModel:SetOptional( "NW0DETAIL", .T. )

oModel:InstallEvent("JA144COMMIT", /*cOwner*/, oCommit)

If !ExistBlock( 'JA144FIL' )
	JurSetRules( oModel, "NUEMASTER",, "NUE",,  )
EndIf

JurSetRules( oModel, "NW0DETAIL",, "NW0",,  )

oModel:SetVldActivate( { |oModel| Iif(FindFunction("JurVldUxP"), JurVldUxP(oModel), .T.) } )
oModel:SetActivate( {|oM| JA144LOAD(oM)} )

oModel:GetModel( 'NW0DETAIL' ):SetOnlyView( .T. )
oStructNW0:SetProperty( '*', MODEL_FIELD_NOUPD, .T. )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J144PreVld(oModel)
Função de pré validação do Model NUE.

@author bruno.ritter
@since 29/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144PreVld(oModel, cFun, cCamp)
Local lRet       := .T.
Local nOperation := oModel:GetOperation()

	If !lIsLancOk .And. nOperation == MODEL_OPERATION_UPDATE

		If cCamp != "NUE_DESC" .And. cCamp != "NUEMASTER"
			lRet := lIsLancOk
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144TUDOK
Validações ao salvar ao salvar o Time-Sheet

@param oModel     - Modelo de dados de Time Sheet
@param oTmpAcaoLD - Tabela Temporária de Time Sheet (Usada para vínculo de TS via LD)

@return lRet   - .T./.F. As informações são válidas ou não

@author David Gonçalves Fernandes
@since 03/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144TUDOK(oModel, oTmpAcaoLD)
Local lRet         := .T.
Local cIDNUE       := IIf( oModel:GetId() == 'JURA202', "NUEDETAIL", "NUEMASTER" )
Local oModelNUE    := oModel:GetModel(cIDNUE)
Local lRetEbill    := .T.
Local aArea        := GetArea()
Local lAtivTSF     := .F.
Local cCliFu       := SuperGetMV('MV_JURTS5',, "")
Local cLojFu       := SuperGetMV('MV_JURTS6',, "")
Local cLancTab     := oModelNUE:GetValue('NUE_CLTAB')
Local cCaso        := oModelNUE:GetValue('NUE_CCASO' )
Local cClien       := oModelNUE:GetValue('NUE_CCLIEN')
Local cLoja        := oModelNUE:GetValue('NUE_CLOJA' )
Local dDataTs      := oModelNUE:GetValue('NUE_DATATS')
Local lAltHr       := NUE->(ColumnPos('NUE_ALTHR')) > 0
Local lIsRest      := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))
Local nOperation   := oModel:GetOperation()

Default oTmpAcaoLD := Nil

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

	lRet := J144PreVal(oModel)  // Valida os direitos do usuário de incluir ou alterar após a data de corte

	If lRet .And. !IsInCallStack( 'JURA063' )
		lRet := J144VHisCa() // Valida se tem o Histórico no caso
	EndIf

	If lRet
		If nOperation == MODEL_OPERATION_UPDATE
			oModelNUE:LoadValue("NUE_CUSERA", JurUsuario(__CUSERID))
			oModelNUE:LoadValue("NUE_ALTDT", Date())
			If lAltHr
				oModelNUE:LoadValue("NUE_ALTHR", Time())
			EndIf
		Else // Inclusão
			oModelNUE:LoadValue("NUE_CUSERA", "")
			oModelNUE:LoadValue("NUE_ALTDT", CToD( '  /  /  ' ))
			If lAltHr
				oModelNUE:LoadValue("NUE_ALTHR", "")
			EndIf
		EndIf
	EndIf

	If lRet // Validação de TS com data futura
		If dDataTs > Date()
			lAtivTSF := JurGetDados('NRC', 1, xFilial('NRC') + oModelNUE:GetValue("NUE_CATIVI"), 'NRC_FUTURO') == '1'
			If !(lAtivTSF .And. cClien == cCliFu .And. cLoja == cLojFu)
				lRet := JurMsgErro(STR0023) // Cliente/Loja ou Atividade não permite lançamento de Time Sheet com data futura
			EndIf
		EndIf
	EndIf

	If lRet .And. oModelNUE:GetValue("NUE_SITUAC") == '1'
		lRetEbill := JAUSAEBILL(cClien, cLoja)
		If lRetEbill .And. (Empty(oModelNUE:GetValue("NUE_CFASE")) .OR. Empty(oModelNUE:GetValue("NUE_CTAREF")) .Or. Empty(oModelNUE:GetValue("NUE_CTAREB")))
			lRet := JurMsgErro(STR0056) // "É necessário preencher fase, tarefa e atividade de ebilling para este time sheet."
		EndIf
	EndIf

	If lRet .And. oModelNUE:IsModified() // Proteção. Transf. regra para gatilho NUE_DATATS. Remover após release 23
		lRet := oModelNUE:LoadValue('NUE_ANOMES', JA144ATLAM())
	EndIf

	If lRet
		If Empty(oModelNUE:GetValue('NUE_CPART1'))
			lRet := JurMsgErro(STR0122)  //"O participante lançado não foi preenchido. Verifique!"
		EndIf
		If lRet .And. Empty(oModelNUE:GetValue('NUE_CPART2'))
			lRet := JurMsgErro(STR0123)  //"O participante revisado não foi preenchido. Verifique!"
		EndIf
	EndIf

	If lRet
		lRet := J144AtvArea(.T.) // Valida o relacionamento entre Área Jurídica e Tp Atividade
	EndIf

	If lRet .And. lIsRest .And. cIDNUE == "NUEMASTER"
		lRet := JurVldAcLd(oModel, cIDNUE, "NUE", @oTmpAcaoLD)
	EndIf

	If lRet .And. lIsRest .And. nOperation == MODEL_OPERATION_INSERT .And. NUE->(FieldPos( "NUE_CODLD" )) > 0 .And. FindFunction("JurMsgCdLD")
		lRet := JurMsgCdLD(oModelNUE:GetValue('NUE_CODLD'))
	EndIf

EndIf

If lRet .And. (nOperation == 4 .Or. nOperation == 5) // Alteração ou Exclusão

	lRet := J144PreVal(oModel)  // Valida os direitos do usuário de incluir ou alterar após a data de corte

	If lRet .And. !Empty(oModelNUE:GetValue('NUE_CPREFT'))
		lRet := JA144VERPRE(oModelNUE:GetValue('NUE_CPREFT'), cLancTab, .F.)  //Valida se o Time Sheet tem pré-fatura e valida
	EndIf

	//Se o TS estiver dividido
	If lRet .And. nOperation == 5
		If !(lRet := JA144VE(oModel))
			JurMsgErro(STR0054) // "O Time Sheet não pode ser excluído, pois existe faturamento/wo relacionados."
		EndIf

		If lRet .And. FwFldGet("NUE_TSDIV") == "1"
			If !(lRet := MsgYesNo(STR0083)) //"Este TS está dividido, confirma a exclusão?"
				JurMsgErro(STR0084)  //"O Time Sheet não foi excluido."
			EndIf
		EndIf
	EndIf

EndIf

//Valida  a existência de Fatura Adicional faturada cujo período de referência englobe a data do Lançamento
If lRet .And. (nOperation == MODEL_OPERATION_DELETE .OR. nOperation == MODEL_OPERATION_INSERT) .And. FindFunction("JurBlqLnc")
	lRet := JurBlqLnc( cClien, cLoja, cCaso, dDataTs, "TS" )
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144CM
Executa rotina ao comitar as alterações no Model

@Param oModel    - Modelo de dados de Time Sheet
@Param aVlCpoLD  - Array com os campos e valores referente ao ação LD

@author Jacques Alves Xavier
@since 17/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA144CM(oModel, aVlCpoLD)
Local aArea      := GetArea()
Local aAreaNX0   := NX0->(GetArea())
Local aAreaNX8   := NX8->(GetArea())
Local aAreaNX1   := NX1->(GetArea())
Local lRet       := .T.
Local cIDNUE     := IIf( oModel:GetId() == 'JURA202', "NUEDETAIL", "NUEMASTER" )
Local oModelNUE  := oModel:GetModel(cIDNUE)
Local cCodTS     := oModelNUE:GetValue('NUE_COD')
Local cCodPre    := oModelNUE:GetValue('NUE_CPREFT')
Local cClien     := oModelNUE:GetValue('NUE_CCLIEN')
Local cLoja      := oModelNUE:GetValue('NUE_CLOJA')
Local cCaso      := oModelNUE:GetValue('NUE_CCASO')
Local cCPart     := oModelNUE:GetValue('NUE_CPART2')
Local lConcluido := oModelNUE:GetValue('NUE_SITUAC') == '1'
Local cContr     := ""
Local cContrAju  := ""
Local lReval     := .F.
Local aCampos    := {}
Local aContr     := {}
Local nOperation := oModel:GetOperation()
Local lLote      := JPELancLote("JURA144", nOperation) // Ponto de entrada que define se é um processamento em lote
Local lShowMsg   := !lLote
Local lIsRest    := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))
Local cSeqNX2    := PADL(0, TamSX3('NX2_CODSEQ')[1], '0')

If nOperation != 5
	
	//Alteração
	If nOperation == 4
		// Se for alteração, sempre considera o parâmetro.
		lReval := .F.

		//Verifica se houve alteração no caso para ajustar / excluir a pré
		If (!Empty(cCodPre) .And. ;
		   (cClien + cLoja + cCaso <> NUE->NUE_CCLIEN + NUE->NUE_CLOJA + NUE->NUE_CCASO)) .Or. ;
			oModel:GetValue("NUEMASTER", "NUE_ACAOLD") == "1"

			JAALTCASO(cCodPre, "NUEMASTER", "NUE", cCodTS, cClien, cLoja, cCaso)
			// Ajusta Flags na transferência via Legal Desk
			If FindFunction("JURFlagLD")
				JurFlagLD(oModel, "NUE", "NW0")
			EndIf
		EndIf
	EndIf

	//Inclusão
	If nOperation == 3
		// Se for inclusão, força o recálculo do TS.
		lReval := .T.

		//Se a inclusão estiver ocorrendo via REST - Integração com o Legal Desk
		If lIsRest

			If !Empty(cCodPre)
				// Ajusta Flags na transferência via Legal Desk
				JurFlagLD(oModel, "NUE", "NW0")

				cContr  := JurGetDados('NX0', 1, xFilial('NX0') + cCodPre, 'NX0_CCONTR')
				cJContr := JurGetDados('NX0', 1, xFilial('NX0') + cCodPre, 'NX0_CJCONT')
				If !Empty(aContr := J202BCntPf(cCodPre, cContr, cJContr, cClien, cLoja, cCaso))
					cContrAju := aContr[3]
				EndIf

				NX2->(dbSetOrder(1)) //NX2_FILIAL+NX2_CPREFT+NX2_CPART+NX2_CCLIEN+NX2_CLOJA+NX2_CCONTR+NX2_CCASO+NX2_CODSEQ
				If !NX2->( dbSeek( xFilial('NX2') + cCodPre + cCPart + cClien + cLoja + cContrAju + cCaso ))
					RecLock("NX2", .T.)
					NX2->NX2_FILIAL  := xFilial("NX2")
					NX2->NX2_CPREFT  := cCodPre
					NX2->NX2_CPART   := cCPart
					NX2->NX2_CCLIEN  := cClien
					NX2->NX2_CLOJA   := cLoja
					NX2->NX2_CCONTR  := cContrAju
					NX2->NX2_CCASO   := cCaso
					NX2->NX2_CODSEQ  := cSeqNX2
					NX2->(MsUnlock() )
					NX2->(DbCommit())
				EndIf
			EndIf
		EndIf
	EndIf

	If FindFunction("JurClearLD")
		aVlCpoLD := JurClearLD(oModel, "NUEMASTER", "NUE") //Limpar os campos de operação do Legal Desk
	EndIf
EndIf

aAdd(aCampos,{NUE->NUE_CCLIEN, cClien})
aAdd(aCampos,{NUE->NUE_CLOJA,  cLoja})
aAdd(aCampos,{NUE->NUE_CCASO,  cCaso})
aAdd(aCampos,{NUE->NUE_DATATS, oModelNUE:GetValue('NUE_DATATS')})
aAdd(aCampos,{NUE->NUE_CPREFT, oModelNUE:GetValue('NUE_CPREFT')}) // Necessário refazer o GetValue aqui pois a função JAALTCASO limpa esse campo dependendo da situação

JurShowPf('NUE', 'TS', nOperation, aCampos, , lConcluido, cCodTS, lShowMsg) //Informa se o TS esta sendo tirado/colocado em um caso que possui pré-fatura

If nOperation == 5 .And. !Empty(cCodPre)
	//Verifica se há outros lançamentos na pré-fatura para cancelá-la se necessário
	If (JurLancPre( cCodPre ) <= 1)
		JA202CANPF( cCodPre )
	EndIf
EndIf

RestArea( aAreaNX1 )
RestArea( aAreaNX8 )
RestArea( aAreaNX0 )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J144InTTS
Execução após a gravação dos registros no processo de commit do modelo.

@Param oModel     - Modelo de dados de Time Sheet
@Param oTmpAcaoLD - Tabela temporária para vínculo de TS na Pré via LD
@Param aVlCpoLD   - Array com os campos e valores referente ao ação LD

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144InTTS(oModel, oTmpAcaoLD, aVlCpoLD)
Local lReval := If(oModel:GetOperation() == 3, .T., .F.)
Local cCodTS := oModel:GetValue("NUEMASTER", "NUE_COD")

	JA144VALTS(cCodTS, lReval, .F.)
	If FindFunction( "JVincLanLD")
		JVincLanLD(oModel:GetModel("NUEMASTER"), "NUE", oTmpAcaoLD, aVlCpoLD) // Vínculo do TS pelo Ação LD
	EndIf
	J170GRAVA(oModel, xFilial('NUE') + cCodTS)

Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA144COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA144COMMIT FROM FWModelEvent
	Data oTmpAcaoLD // Tabela temporária para vínculo de TS na Pré via LD
	Data aVlCpoLD  // Array com os campos e valores referente ao ação LD

	Method New()
	Method ModelPosVld()
	Method BeforeTTS()
	Method InTTS()
	Method DeActivate()
End Class

Method New() Class JA144COMMIT
	Self:oTmpAcaoLD := Nil
	Self:aVlCpoLD   := {}
Return

Method ModelPosVld(oSubModel, cModelID) Class JA144COMMIT
	Local lRet := .T.

	If ValType(Self:oTmpAcaoLD) == "O"
		Self:oTmpAcaoLD:Destroy()
		Self:oTmpAcaoLD := Nil
	EndIf

	lRet := JA144TUDOK(oSubModel:GetModel(), @Self:oTmpAcaoLD)

Return lRet

Method BeforeTTS(oSubModel, cModelId) Class JA144COMMIT
	JA144CM(oSubModel:GetModel(), @Self:aVlCpoLD)
Return

Method InTTS(oSubModel, cModelId) Class JA144COMMIT
	J144InTTS(oSubModel:GetModel(), Self:oTmpAcaoLD, Self:aVlCpoLD)
Return

Method DeActivate() Class JA144COMMIT
	If ValType(Self:oTmpAcaoLD) == "O"
		Self:oTmpAcaoLD:Delete()
	EndIf
	Self:oTmpAcaoLD := Nil
	JurFreeArr(@Self:aVlCpoLD)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144TxtTS
Retorna o texto sugerido para a desrição do apontamento de horas
conforme o idioma do contrato

@author David Gonçalves Fernandes
@since 03/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144TxtTS()
Local oModel    := Nil
Local cTexto    := ""
Local cIdioma   := ""
Local cCliente  := ""
Local cCaso     := ""
Local cLoja     := ""
Local cAtiv     := ""

Local cQueryFX  := ""
Local cResQRY   := GetNextAlias()

Local aArea     := GetArea()
Local aAreaNUE  := NUE->( GetArea() )

oModel   := FWModelActive()
cCliente := oModel:GetValue("NUEMASTER", "NUE_CCLIEN")
cLoja    := oModel:GetValue("NUEMASTER", "NUE_CLOJA")
cCaso    := oModel:GetValue("NUEMASTER", "NUE_CCASO")
cAtiv    := oModel:GetValue("NUEMASTER", "NUE_CATIVI")

//Retorna o idioma do caso do TS
cQueryFX := " SELECT NVE.NVE_CIDIO IDIOMA "
cQueryFX +=   " FROM " + RetSqlName("NVE") +" NVE "
cQueryFX +=  " WHERE NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
cQueryFX +=    " AND NVE.NVE_CCLIEN = '" + cCliente + "' "
cQueryFX +=    " AND NVE.NVE_LCLIEN = '" + cLoja + "' "
cQueryFX +=    " AND NVE.NVE_NUMCAS = '" + cCaso + "' "
cQueryFX +=    " AND NVE.D_E_L_E_T_ = ' '"

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryFX), cResQRY, .T., .T.)

cIdioma := (cResQRY)->IDIOMA

(cResQRY)->( dbCloseArea() )

If !Empty(cIdioma)
	cQueryFX := " SELECT R_E_C_N_O_ NR5RECNO "
	cQueryFX +=   " FROM " + RetSqlName("NR5") + " NR5 "
	cQueryFX +=  " WHERE NR5.NR5_FILIAL = '" + xFilial("NR5") + "' "
	cQueryFX +=    " AND NR5.NR5_CTATV =  '" + cAtiv + "' "
	cQueryFX +=    " AND NR5.NR5_CIDIOM = '" + cIdioma + "' "
	cQueryFX +=    " AND NR5.D_E_L_E_T_ = ' ' "

	cResQRY   := GetNextAlias()
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryFX), cResQRY, .T., .T.)

	If (cResQRY)->NR5RECNO > 0
		NR5->( dbGoTo( (cResQRY)->NR5RECNO ) )
		cTexto := NR5->NR5_TXTPAD
	EndIf

	(cResQRY)->( dbCloseArea() )

EndIf

RestArea( aAreaNUE )
RestArea( aArea )

Return cTexto

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA144W
Hablita o campo de tempo conforme o tipo de apontamento:
Campo de UTs           MV_JURTS2 = '1'
Campo de Horas Frac    MV_JURTS2 = '2'
Campo de Horas Minutos MV_JURTS2 = '3'
Utilizado no WHEN do dicionário.

@author David Gonçalves Fernandes
@since 03/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA144W( cNomeCampo )
Local aArea     := GetArea()
Local oModel    := FwModelActive()
Local nTipoApon := SuperGetMV( 'MV_JURTS2',, 1 )
Local lRet      := .F.
Local cCliente  := ""
Local cLoja     := ""

cNomeCampo := AllTrim(cNomeCampo)

Do Case
	Case nTipoApon == 1 .And. cNomeCampo $ 'NUE_UTL|NUE_UTR|NUE_UTP'
		lRet := .T.
	Case nTipoApon == 2 .And. cNomeCampo $ 'NUE_TEMPOL|NUE_TEMPOR|NUE_TEMPOP'
		lRet := .T.
	Case nTipoApon == 3 .And. cNomeCampo $ 'NUE_HORAL|NUE_HORAR|NUE_HORAP'
		lRet := .T.
EndCase

If oModel:GetId() != 'JURA202'

	If lRet := oModel:GetValue("NUEMASTER", "NUE_SITUAC") == '1'
		If cNomeCampo == 'NUE_VALOR'
			lRet := !Empty(oModel:GetValue("NUEMASTER", "NUE_VALORH"))
		ElseIf cNomeCampo $ 'NUE_VALORH|NUE_VALOR1'
			lRet := .F.
		ElseIf cNomeCampo $ "NUE_CTAREB|NUE_CFASE"
			lRet := !Empty(oModel:GetValue("NUEMASTER", "NUE_CDOC"))
		ElseIf cNomeCampo $ "NUE_CTAREF"
			lRet := !Empty(oModel:GetValue("NUEMASTER", "NUE_CFASE"))
		EndIf
	EndIf

ElseIf oModel:GetId() == 'JURA202'

	If cNomeCampo $ 'NUE_VALORH,NUE_VALOR1,NUE_CATIVI,NUE_SIGLA2,NUE_CPART2,NUE_CRETIF,NUE_REVISA,NUE_CGRPCL,NUE_CCLIEN,NUE_CLOJA,NUE_CCASO,NUE_DATATS,NUE_COBRAR'
		lRet := .T.
	ElseIf cNomeCampo $ "NUE_CMOEDA|NUE_VALOR"
		lRet := IsInCallStack( "JA202VAL" )
	ElseIf cNomeCampo $ 'NUE_CFASE|NUE_CTAREF|NUE_CTAREB'
		cCliente := oModel:GetValue("NUEDETAIL", "NUE_CCLIEN")
		cLoja    := oModel:GetValue("NUEDETAIL", "NUE_CLOJA")
		lRet     := JAUSAEBILL(cCliente, cLoja) .And. oModel:GetValue("NUEDETAIL", "NUE_SITUAC") == '1'
	EndIf

ElseIf oModel:GetId() == "JURA144DIV"
	lRet := .T.
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA144V1
Realiza as conversões dos tempos lançados / revisados

@param cNomeCampo    Nome do campo a validar
@param lAltLote      Originado da tela de lote (.T. - Sim / .F. - Não)
@param lCasAtv       Chamado através dos campos NUE_CATIVI ou NUE_CCASO (.T. - Sim / .F. - Não)

@author David Gonçalves Fernandes
@since 03/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA144V1( cNomeCampo, lAltLote, lCasAtv)
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaNX0   := NX0->(GetArea())
Local cMsg       := ""
Local nMultiplo  := SuperGetMV( 'MV_JURTS1',, 10  ) //Define a quantidade de minutos referentes a 1 UT
Local lPodeFrac  := SuperGetMV( 'MV_JURTS3',, .F. ) //Indica se as uts ou o tempo pode ser possuir frações da unidade de tempo
Local lAtivNaoC  := SuperGetMV( 'MV_JURTS4',, .F. ) //Zera o tempo revisado de atividades nao cobraveis
Local cAtivNaoC  := "1"
Local oModel     := If( oModelOld = Nil, FWModelActive(), oModelOld)
Local cConteudo  := ''
Local nInteiro   := 0
Local nDecimal   := 0
Local nUts       := 0
Local cHora      := ""
Local cIdNUE     := ""
Local nTipoCpo   := 0
Local nValorTS   := 0
Local aValorConv := {}
Local cCliente   := ""
Local cLoja      := ""
Local cCaso      := ""
Local dDtCotac   := CtoD("") // data da cotacao da pre-fatura (emissao)
Local cHsMinZr   := Transform(PADL("0", TamSX3('NUE_HORAL')[1], '0'), PesqPict("NUE", "NUE_HORAL")) // CH8177 adotar tamanho e mascara do campo HH:mm
Local nUTtoHoraF := 0
Local nDecHF     := 0

Default lAltLote := .F. // Originado da tela de lote (.T. - Sim / .F. - Não)
Default lCasAtv  := .F. // Chamado através dos campos NUE_CATIVI ou NUE_CCASO (.T. - Sim / .F. - Não)

If oModel:GetId() $ "JURA144|JURA144DIV"
	cIdNUE := "NUEMASTER"
ElseIf oModel:GetId() == "JURA202"
	cIdNUE := "NUEDETAIL"
EndIf

cCliente := oModel:GetValue( cIdNUE, "NUE_CCLIEN") // cliente da validação NX0_ALTPER $ '2,3'
cLoja    := oModel:GetValue( cIdNUE, "NUE_CLOJA" ) // loja da validaçao NX0_ALTPER $ '2,3'
cCaso    := oModel:GetValue( cIdNUE, "NUE_CCASO" ) // Caso da validaçao NX0_ALTPER $ '2,3'

If !(ValType(oModel:GetValue( cIdNUE, "NUE_"+ cNomeCampo)) == 'C')
	cConteudo := Str( oModel:GetValue( cIdNUE, "NUE_" + cNomeCampo))
Else
	cConteudo := oModel:GetValue( cIdNUE, "NUE_" + cNomeCampo)
EndIf

If cNomeCampo $ 'NUE_UTL / NUE_UTR / NUE_UTP'
	nTipoCpo := 1
ElseIf cNomeCampo $ 'NUE_TEMPOL / NUE_TEMPOR / NUE_TEMPOP'
	nTipoCpo := 2
ElseIf cNomeCampo $ 'NUE_HORAL / NUE_HORAR / NUE_HORAP'
	nTipoCpo := 3
EndIf

nUts      := Val( JURA144C1(nTipoCpo, 1, cConteudo) )
nHoraFrac := Val( JURA144C1(nTipoCpo, 2, cConteudo) )
cHora     := Transform(PadL(JURA144C1(nTipoCpo, 3, cConteudo), TamSX3('NUE_HORAL')[1], '0'), PesqPict("NUE", "NUE_HORAL")) // CH8177 adotar tamanho e mascara do campo HH:mm

If !lPodeFrac
	nUTtoHoraF := Round(nUts, 0) * (nMultiplo / 60)
	nDecHF     := TamSx3("NUE_TEMPOR")[2]
	If Round(nUTtoHoraF, nDecHF) == Round(nHoraFrac, nDecHF)
		// Ajuste a UT para quando digitar a hora fracionada,
		// não exibir erro sendo que é o valor que representa a UT não fracionada
		nUts := Round(nUts, 0)
	EndIf
EndIf

nInteiro  := Int( nUts )
nDecimal  := nUts - Int( nUts )

If nDecimal <> 0 .And. !lPodeFrac
	nUts      := Val( JURA144C1(1, 1, Str(Round(nUts, 0)) ) )
	nHoraFrac := Val( JURA144C1(1, 2, Str(Round(nUts, 0)) ) )
	cHora     := Transform(PADL(JURA144C1(nTipoCpo, 3, cConteudo), TamSX3('NUE_HORAL')[1], '0'), PesqPict("NUE", "NUE_HORAL"))

	cMsg := STR0013 + Alltrim( Str( nMultiplo ) ) + STR0014 // 'Só é permitido apontar tempos múltiplos de '+ Alltrim( Str( nMultiplo ) ) +' minutos '

	lRet := .F.
EndIf

If nUts < 0
	cMsg := STR0088 // "Informe um valor positivo!"
	lRet := .F.
EndIf

dDtCotac := oModel:GetValue( cIdNUE, "NUE_DATATS" )

If IsJura202() .And. !lAltLote .And. !IsInCallStack("JA145ALT2")

	If cIdNUE == "NUEMASTER"
		DbSelectArea("NX0")
		DbSetOrder(1)
		If DbSeek(xFilial("NX0") + oModel:GetValue(cIdNUE, "NUE_CPREFT"))
			dDtCotac := NX0->NX0_DTEMI
		EndIf
	Else
		dDtCotac     := oModel:GetValue( "NX0MASTER", "NX0_DTEMI"  )
	EndIf

	//Valida a alteração em um TS dividido pelas alterações de período.
	If (Empty(oModel:GetValue(cIdNUE, "NUE_CPREFT")) .And. cIdNUE == "NUEDETAIL") .Or.;
			J202VldDiv("NUE_CODPAI", oModel:GetValue(cIdNUE, "NUE_COD"))
		cMsg := STR0089 //"Existem alterações de valor pendentes, para efetuar novas alterações cancele as anteriores!"
		lRet := .F.
	EndIf

EndIf

If cNomeCampo $ 'NUE_UTL / NUE_TEMPOL / NUE_HORAL / NUE_UTR / NUE_TEMPOR / NUE_HORAR'
	//Verifica se o tipo de atividade é não cobrável quando o parametro MV_JURTS4 está para zerar TS de Ativ não cobrável
	cAtivNaoC := JurGetDados("NRC", 1, xFilial("NRC") + oModel:GetValue(cIdNUE,"NUE_CATIVI"), "NRC_TEMPOZ")
EndIf

If lRet
	If cNomeCampo $ 'NUE_UTL / NUE_TEMPOL / NUE_HORAL'

		If (oModel:IsFieldUpdated(cIdNUE, "NUE_UTL") .Or. ;  //CH8177 Somente atualiza os campos se algum dos tipos sofreu alteração
			oModel:IsFieldUpdated(cIdNUE,"NUE_HORAL") .Or.;
			oModel:IsFieldUpdated(cIdNUE,"NUE_TEMPOL"))

			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_UTL", nUts ), )
			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_HORAL", cHora) , )
			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_TEMPOL", nHoraFrac ), )
		EndIf

		//CH8177 SE O LANÇADO FOR IGUAL AO REVISADO OU ZERADO, REPLICA A ALTERAÇÃO PARA O REVISADO
		If ( oModel:GetOperation() == 3  .Or.  oModel:GetOperation() == 4 ) .And. ;
				oModel:IsFieldUpdated(cIdNUE, "NUE_UTL") .And. ( oModel:GetValue(cIdNUE, "NUE_UTR") == nUt_old )
			If lAtivNaoC .And. cAtivNaoC == '2'
				IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_UTR", 0 ), ) // 0
			Else
				IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_UTR", nUts ), ) // 9
			EndIf
		EndIf

		If ( oModel:GetOperation() == 3  .Or.  oModel:GetOperation() == 4 ) .And. ;
			oModel:IsFieldUpdated(cIdNUE, "NUE_UTL") .And. ( oModel:GetValue(cIdNUE, "NUE_UTP") == nUt_old )
			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_UTP", nUts ), )
		EndIf

		If ( oModel:GetOperation() == 3  .Or.  oModel:GetOperation() == 4 ) .And. ;
				oModel:IsFieldUpdated(cIdNUE, "NUE_HORAL") .And. ( IIF(Empty(oModel:GetValue(cIdNUE, "NUE_HORAR")), cHsMinZr, oModel:GetValue(cIdNUE, "NUE_HORAR")) == cMrMin_old )
			If lAtivNaoC .And. cAtivNaoC == '2'
				IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_HORAR", cHsMinZr ), ) // 00:00
			Else
				IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_HORAR", cHora ), ) //01:30
			EndIf
		EndIf

		If ( oModel:GetOperation() == 3  .Or.  oModel:GetOperation() == 4 ) .And. ;
			oModel:IsFieldUpdated(cIdNUE, "NUE_HORAL") .And. ( IIF(Empty(oModel:GetValue(cIdNUE, "NUE_HORAP")), cHsMinZr, oModel:GetValue(cIdNUE, "NUE_HORAP")) == cMrMin_old )
			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_HORAP", cHora ), )
		EndIf

		If ( oModel:GetOperation() == 3  .Or.  oModel:GetOperation() == 4 ) .And. ;
				oModel:IsFieldUpdated(cIdNUE, "NUE_TEMPOL") .And. ( oModel:GetValue(cIdNUE, "NUE_TEMPOR") == nHrFra_old )
			If lAtivNaoC .And. cAtivNaoC == '2'
				IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_TEMPOR", 0 ), ) // 0
			Else
				IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_TEMPOR", nHoraFrac ), ) //1,5
			EndIf
		EndIf

		If ( oModel:GetOperation() == 3  .Or.  oModel:GetOperation() == 4 ) .And. ;
			oModel:IsFieldUpdated(cIdNUE, "NUE_TEMPOL") .And. ( oModel:GetValue(cIdNUE, "NUE_TEMPOP") == nHrFra_old )
			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_TEMPOP", nHoraFrac ), )
		EndIf

		If (oModel:GetOperation() == 3 .Or. oModel:GetOperation() == 4)
			nUt_old    := nUts
			cMrMin_old := cHora
			nHrFra_old := nHoraFrac
		Else
			nUt_old    := CriaVar( "NUE_UTL", .F. )
			cMrMin_old := cHsMinZr
			nHrFra_old := CriaVar( "NUE_TEMPOL", .F. )
		EndIf

	ElseIf lRet .And. (cNomeCampo $ 'NUE_UTR / NUE_TEMPOR / NUE_HORAR')
		If lAtivNaoC .And. cAtivNaoC == '2'
			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_UTR", 0 ), ) // 0
			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_HORAR", cHsMinZr ), ) // 00:00
			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_TEMPOR", 0 ), ) // 0
		Else
			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_UTR", nUts ), ) // 9
			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_HORAR", cHora ), ) //01:30
			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_TEMPOR", nHoraFrac ), ) //1,5
		EndIf

	ElseIf lRet .And. (cNomeCampo $ 'NUE_UTP / NUE_TEMPOP / NUE_HORAP')
		If (oModel:IsFieldUpdated(cIdNUE, "NUE_UTP") .Or. ;
			oModel:IsFieldUpdated(cIdNUE, "NUE_HORAP") .Or. ;
			oModel:IsFieldUpdated(cIdNUE, "NUE_TEMPOP"))

			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_UTP", nUts ), )
			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_HORAP", cHora), )
			IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_TEMPOP", nHoraFrac ), )
		EndIf
	EndIf

	If cIdNUE == "NUEDETAIL"
		nValorTS  := oModel:GetValue( cIdNUE, "NUE_TEMPOR" ) * oModel:GetValue( cIdNUE, "NUE_VALORH")

		nVlOld    := oModel:GetValue( cIdNUE, "NUE_VALOR1" )

		aValorConv := JA201FConv(oModel:GetValue( cIdNUE, "NUE_CMOED1" ),oModel:GetValue( cIdNUE, "NUE_CMOEDA" ),;
		                         nValorTS, "1", dDtCotac, /*cCodFImpr*/, oModel:GetValue( cIdNUE, "NUE_CPREFT" ), /*cXFilial*/ )
		If !IsInCallStack("JANX2_VTS") .And. !IsInCallStack("JANX1_VTS")
			JA202Part(oModel:GetModel(cIdNUE), "-" )
		EndIf

		IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_VALOR",  nValorTS), )
		IIF(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_VALOR1", aValorConv[1]), )

		nDif := aValorConv[1] - nVlOld
		If !IsInCallStack("JANX2_VTS") .And. !IsInCallStack("JANX1_VTS")
			JA202Part(oModel:GetModel(cIdNUE), "+", .T. )
		EndIf

		If !IsInCallStack("JA202ALTP") .And. !IsInCallStack("JA202VAL3") .And. !IsInCallStack("JANUE_VTS")
			oModel:LoadValue( "NX1DETAIL", "NX1_VTS",  oModel:GetValue( "NX1DETAIL", "NX1_VTS" ) + nDif )
			oModel:LoadValue( "NX1DETAIL", "NX1_VHON", oModel:GetValue( "NX1DETAIL", "NX1_VHON") + nDif )
			oModel:LoadValue( "NX8DETAIL", "NX8_VTS",  oModel:GetValue( "NX8DETAIL", "NX8_VTS" ) + nDif )
			oModel:LoadValue( "NX0MASTER", "NX0_VTS",  oModel:GetValue( "NX0MASTER", "NX0_VTS" ) + nDif )
		EndIf

	EndIf

EndIf

If lRet .And. !IsJura202() //Não revaloriza TS alterados pela pré-fatura
	lRet := JA144VALTS( FwFldGet("NUE_COD"), .T., !JurIsRest() )
EndIf

If !lRet .And. !Empty(cMsg)
	JurMsgErro(cMsg)
EndIf

RestArea(aAreaNX0)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA144C1()
Retorna o valor no tipo de apontamento origem convertido no tipo de apontamento de destino
Melhoria na precisão de casas decimais usando decimal de ponto flutuante.

@param  nTipoOrig   Tipo de apontamento origem ( 1- Uts, 2-Hora Fracionada, 3-Hora:minuto)
@param  nTipoDest   Tipo de apontamento destino ( 1- Uts, 2-Hora Fracionada, 3-Hora:minuto)
@param  cValor      Valor a ser convertido
@param  nTamHora    Quantidade de dígitos na composição da hora. Usado quando o 'nTipoDest' for igual a 3-Hora:minuto
@param  nCfgUT      Quantidade de minutos referente a 1 UT
@Return cRet        String com o valor convertido para o tempo do apontamento

@author Luciano Pereira dos Santos
@since 24/01/2017
@version 2.0
/*/
//-------------------------------------------------------------------
Function JURA144C1(nTipoOrig, nTipoDest, cValor, nTamHora, nCfgUT)
Local cRet       := ""
Local nUt        := 0
Local nHFrac     := 0
Local cTempo     := '0'
Local nDec       := 20

Default nTamHora := 2 // Quantidade de dígitos na composição da HORA
Default nCfgUT   := SuperGetMV( 'MV_JURTS1',, 10 )

If nTipoOrig == nTipoDest
	cRet := cValor
Else
	If nTipoOrig == 1 .And. nTipoDest == 3

		nHFrac  := Val(cValToChar(cValor)) * nCfgUT / 60
		cTempo  := StrZero( Int(nHFrac), nTamHora) + ':' + StrZero( Round( ( nHFrac - Int(nHFrac) ) * 60, 0), 2 )
		cRet    := cTempo

	ElseIf nTipoOrig == 1 .And. nTipoDest == 2

		nHFrac    := DEC_MUL( DEC_CREATE(cValToChar(cValor), 64, nDec), (DEC_DIV(DEC_CREATE(cValToChar(nCfgUT), 64, nDec), DEC_CREATE('60', 64, nDec))) )
		cRet      := cValToChar(DEC_RESCALE(nHFrac, nDec, 0))

	ElseIf nTipoOrig == 3 .And. nTipoDest == 1

		nHoraFrac := Val( Substr( cValor, 0, At(':', cValor) - 1 ) ) + ( Val( SubStr( cValor, At(':', cValor) + 1, 2 ) ) / 60 )
		nUt       := ( nHoraFrac * 60 ) / nCfgUT
		cRet      := cValToChar( nUt )

	ElseIf nTipoOrig == 3 .And. nTipoDest == 2

		nHoraFrac := Val( Substr( cValor, 0, At(':', cValor) - 1 ) ) + ( Val( SubStr( cValor, At(':', cValor) + 1, 2 ) ) / 60 )
		cRet      := cValToChar( nHoraFrac )

	ElseIf nTipoOrig == 2 .And. nTipoDest == 1

		nHFrac    := DEC_MUL( DEC_CREATE(cValToChar(cValor), 64, nDec), (DEC_DIV(DEC_CREATE('60', 64, nDec), DEC_CREATE(cValToChar(nCfgUT), 64, nDec))) )
		cRet      := cValToChar(DEC_RESCALE(nHFrac, nDec, 0))

	ElseIf nTipoOrig == 2 .And. nTipoDest == 3

		cValor := cValToChar(cValor)
		cTempo := StrZero( Int(Val(cValor)), nTamHora) + ':' +  StrZero( Round( ( Val(cValor) - Int(Val(cValor)) ) * 60, 0), 2 )

		cRet   := cTempo
	EndIf
EndIf

If At("*", cTempo)  > 0
	cRet := "****"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144LOAD()
Função para sugerir os Tempos revisados do Lançamento

@author David Gonçalves Fernandes
@since 07/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144LOAD(oModel)
Local lRet    := .T.
Local cClien  := ""
Local cLoja   := ""
Local cCaso   := ""
Local dDataLC := CToD( '  /  /  ' )
Local nOpc    := oModel:GetOperation()

nUt_old    := oModel:GetValue("NUEMASTER", "NUE_UTL")
nHrFra_old := oModel:GetValue("NUEMASTER", "NUE_TEMPOL")
cMrMin_old := oModel:GetValue("NUEMASTER", "NUE_HORAL")

If nOpc == 3 .And. IsInCallStack('JA144REPLI') //Rotina de réplica de time sheet
	JA144SGNUE(NUE->NUE_COD, oModel)
ElseIf nOpc == 4
	cClien    := oModel:GetValue("NUEMASTER", "NUE_CCLIEN")
	cLoja     := oModel:GetValue("NUEMASTER", "NUE_CLOJA")
	cCaso     := oModel:GetValue("NUEMASTER", "NUE_CCASO")
	dDataLC   := oModel:GetValue("NUEMASTER", "NUE_DATATS")
	lIsLancOk := JurBlqLnc( cClien, cLoja, cCaso, dDataLC, "TS", "2" )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144NVE
Rotina para consulta padrão de caso , considerando o parâmetro dias de encerramento do caso e as permissões do participante logado.
Uso Geral.

@param  cMaster   Nome do master
@param  cGrupo    Nome do campo de cliente
@param  cCliente  Nome do campo de cliente
@param  cLoja     Nome do campo de loja

@Return cRet      Comando para filtro

@sample
@#JA144NVE('NUEMASTER','NUE_CGRPCL','NUE_CCLIEN','NUE_CLOJA') //Não pode ter espaços

@author David Gonçalves Fernandes
@since 07/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144NVE(cMaster, cGrupo, cCliente, cLoja)
Local cRet := ""

cRet := JANVELANC(cMaster, cGrupo, cCliente, cLoja, "NVE_LANTS")

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144VLDEB
Função para validar os referências dos campos de cliente / loja / caso

@param 	cCampo  	Nome do campo que será validado (Fase / ou Tarefa)
@Return lRet	 	Indica se a validação foi bem sucedida ou não( .T. / .F. )

@author David Gonçalves Fernandes
@since 09/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144VLDEB(cCampo)
Local lRet     := .T.
Local cCodFase := ""

	Do Case
	Case cCampo == "NUE_CFASE"
		lRet := !Empty(JurGetDados("NRY", 5, xFilial("NRY") + FwFldGet("NUE_CFASE") + FwFldGet("NUE_CDOC"), "NRY_CFASE"))
	Case cCampo == "NUE_CTAREF"
		cCodFase := JurGetDados("NRY", 5, xFilial("NRY") + FwFldGet("NUE_CFASE") + FwFldGet("NUE_CDOC"), "NRY_COD")
		lRet     := !Empty(JurGetDados("NRZ", 2, xFilial("NRZ") + FwFldGet("NUE_CDOC") + cCodFase + FwFldGet("NUE_CTAREF"), "NRZ_CTAREF"))
	Case cCampo == "NUE_CTAREB"
		lRet := !Empty(JurGetDados('NS0', 2, xFilial('NS0') + FwFldGet("NUE_CDOC") + FwFldGet("NUE_CTAREB"), 'NS0_CATIV'))
	End Case

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144VLCPO
Função para validar as referências dos campos de cliente / loja / caso

@param 	cCampo  	Nome do campo que será validado
@Return cRet	 		Indica se a validação foi bem sucedida ou não( .T. / .F. )

@author David Gonçalves Fernandes
@since 09/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144VLCPO(cCampo)
Local lRet       := .T.
Local oModel     := FWModelActive()
Local nOperation := oModel:GetOperation()
Local aArea      := GetArea()
Local lAltLote   := IsInCallStack( 'JA145ALT2' )
Local cIdNUE     := IIf(oModel:GetId() == 'JURA202', "NUEDETAIL", "NUEMASTER")
Local cMsg       := ""
Local cSolucao   := ""
Local lRetPtoE   := .T.
Local lPE144Vlc  := ExistBlock("PE144VLC")
Local cRetif     := ""
Local cAtivi     := ""
Local cDataTS    := ""
Local cAnoMes    := ""
Local cTitData   := ""

If lPE144Vlc
	lRetPtoE  := ExecBlock("PE144VLC", .F., .F., {cCampo, oModel, cIdNUE})
	lPE144Vlc := Valtype(lRetPtoE) == "L"
EndIf

If (nOperation == 3 .Or. nOperation == 4 )
	Do Case
	Case cCampo == "NUE_CPART1"
		If !lPE144Vlc
			lRet := ExistCpo("RD0", oModel:GetValue(cIdNUE, "NUE_CPART1"), 1)
		Else
			lRet := lRetPtoE
		EndIf

		If lRet .And. (Empty( oModel:GetValue(cIdNUE, "NUE_CPART2") ) .Or. (cPart1_old == oModel:GetValue(cIdNUE, "NUE_CPART2") ) )
			If !oModel:SetValue(cIdNUE, "NUE_CPART2", oModel:GetValue(cIdNUE, "NUE_CPART1"))
				lRet := .F.
			EndIf
		EndIf
		If !lRet
			cMsg     := STR0112 //"O participante lançado não existe ou está inativo."
			cSolucao := STR0149 //"Verifique o cadastro do participante."
		EndIf
		cPart1_old := oModel:GetValue(cIdNUE, "NUE_CPART1")

	Case cCampo == "NUE_CPART2"
		If !lPE144Vlc
			lRet := ExistCpo("RD0", oModel:GetValue(cIdNUE, "NUE_CPART2"), 1)
		Else
			lRet := lRetPtoE
		EndIf

		If lRet .Or. Empty(oModel:GetValue(cIdNUE, "NUE_CPART2"))
			JA144VALTS(oModel:GetValue(cIdNUE, "NUE_COD"), .T., !JurIsRest())
		EndIf
		If !lRet
			cMsg     := STR0113 //"O participante revisado não existe ou está inativo."
			cSolucao := STR0149 //"Verifique o cadastro do participante."
		EndIf
	Case cCampo == "NUE_CRETIF"
		If !Empty(cRetif := oModel:GetValue(cIdNUE, "NUE_CRETIF") )
			If !(lRet := JurGetDados('NSB', 1, xFilial('NSB') + cRetif, 'NSB_ATIVO') == '1')
				cMsg     := STR0114 //"O código de retificação não existe ou está inativo."
				cSolucao := STR0150 //"Verifique o cadastro de Retificação de TimeSheet."
			EndIf
		EndIf
	Case cCampo == "NUE_CATIVI"
		If !Empty(cAtivi := oModel:GetValue(cIdNUE, "NUE_CATIVI"))
			If (lRet := JurGetDados('NRC', 1, xFilial('NRC') + cAtivi, 'NRC_ATIVO') == '1')
				lRet := J144AtvArea(.T.) // Valida o relacionamento entre Área Jurídica e Tipo de Atividade
				If lRet
					lRet := JURA144V1("UTR", lAltLote, .T.) // verifica se o tipo de atividade e nao cobravel e atualiza os valores do ts
				EndIf
			Else
				cMsg      := STR0115 // "O código de Tipo de Atividade do Time Sheet não existe, está inativo."
				cSolucao  := STR0148 //"Verifique o cadastro de Tipos de Atividade."
			EndIf
		EndIf
	Case cCampo == "NUE_ANOMES"
		cDataTS := cValToChar(Year(oModel:GetValue(cIdNUE, "NUE_DATATS"))) + StrZero(Month(oModel:GetValue(cIdNUE, "NUE_DATATS")), 2)
		cAnoMes := oModel:GetValue(cIdNUE, "NUE_ANOMES")
		If cDataTS != cAnoMes
			cTitData := RetTitle("NUE_DATATS")
			lRet := JurMsgErro(I18N(STR0163, {cTitData}), , I18N(STR0164, {cTitData})) //"O ano/mês está fora do período do campo '#1'" ### "Altere a data no campo '#1'"
		EndIf
	End Case
EndIf

If !lRet .And. !Empty(cMsg)
	JurMsgErro(cMsg,, cSolucao)
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144F3NRC
Consulta padrão do tipo de atividade

@author David Gonçalves Fernandes
@since 09/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144F3NRC()
local cIdNUE    := IIf( IsJura202(), "NUEDETAIL", "NUEMASTER" )

lRet := JURF3NRC(cIdNUE, "NUE_CCLIEN", "NUE_CLOJA", "NUE_CCASO")

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144NRC
Retorna a descrição da atividade no idioma do caso do time-Sheet
Uso Geral.

@Return cRet       Descrição do Tipo de Atividade

@author David G. Fernandes
@since 14/08/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144NRC()
Local cRet     := ""

cRet := JurGetDados('NRC', 1, xFilial('NRC') + FWFldGet("NUE_CATIVI"), 'NRC_DESC')

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144DESCS
Funções para retornar a descrição dos campos:
Título do caso
Descrição da atividade no idioma do caso

@param 	cCampo	Ex: "NUE_DCLIEN" ou "NUE_DCASO"

@Return cRet	 A descrição do codigo do campo informado

@author Luciano Pereira dos Santos
@since 25/01/17
@version 2.0
/*/
//-------------------------------------------------------------------
Function JA144DESCS(cCampo)
Local aArea     := GetArea()
Local cRet      := ""
Local oModel    := Nil
Local oModelNX1 := Nil
Local oModelNX0 := Nil

Do Case
	Case cCampo == 'NUE_DCASO'
		oModel    := FWModelActive()
		If oModel != Nil .And. oModel:GetId() == "JURA202"
			oModelNX1 := oModel:GetModel('NX1DETAIL')
			cRet      := oModelNX1:GetValue('NX1_DCASO')
		Else
			cRet := POSICIONE('NVE', 1, xFilial('NVE') + NUE->NUE_CCLIEN + NUE->NUE_CLOJA + NUE->NUE_CCASO, 'NVE_TITULO')
		EndIf

	Case cCampo == 'NUE_DCLIEN'
		oModel    := FWModelActive()
		If oModel != Nil .And. oModel:GetId() == "JURA202"
			oModelNX1 := oModel:GetModel('NX1DETAIL')
			cRet      := oModelNX1:GetValue('NX1_DCLIEN')
		Else
			cRet := POSICIONE('SA1', 1, xFilial('SA1') + NUE->NUE_CCLIEN + NUE->NUE_CLOJA, 'A1_NOME')
		EndIf

	Case cCampo == 'NUE_DGRPCL'
		If !Empty(NUE->NUE_CGRPCL)
			cRet := POSICIONE('ACY', 1, xFilial('ACY') + NUE->NUE_CGRPCL, 'ACY_DESCRI')
		EndIf

	Case cCampo == 'NUE_DLTAB'
		If !Empty(NUE->NUE_CLTAB)
			cRet := SUBSTR(POSICIONE('NV4', 1, xFilial('NV4') + NUE->NUE_CLTAB, 'NV4_DESCRI'), 1, 20)
		EndIf

	Case cCampo == 'NUE_DFASE'
		If !Empty(NUE->NUE_CFASE)
			cRet := JA144DESFA('NUE_DFASE', .F.)
		EndIf

	Case cCampo == 'NUE_DRETIF'
		If !Empty(NUE->NUE_CRETIF)
			cRet := POSICIONE('NSB', 1, xFilial('NSB') + NUE->NUE_CRETIF, 'NSB_DESC')
		EndIf

	Case cCampo == 'NUE_DTAREF'
		If !Empty(NUE->NUE_CTAREF)
			cRet := JA144DESFA('NUE_DTAREF', .F.)
		EndIf

	Case cCampo == 'NUE_DTAREB'
		If !Empty(NUE->NUE_CTAREB)
			cRet := JA144DESFA('NUE_DTAREB', .F.)
		EndIf

	Case cCampo == 'NUE_DMOED1'
		oModel    := FWModelActive()
		If oModel != Nil .And. oModel:GetId() == "JURA202"
			oModelNX0 := oModel:GetModel('NX0MASTER')
			cRet      := oModelNX0:GetValue('NX0_DMOEDA')
		Else
			cRet := POSICIONE('CTO', 1, xFilial('CTO') + NUE->NUE_CMOED1, 'CTO_SIMB')
		EndIf

	Otherwise
		cRet := ""
	End Case

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA144Bt1()
Corrige o texto do Time-Sheet

@param oModel  Modelo de dados

@author David G. Fernandes
@since 22/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA144Bt1( oModel )
Local cIdNUE    := IIf( IsJura202(), "NUEDETAIL", "NUEMASTER" )
Local oModelNUE := oModel:GetModel(cIdNUE)
Local nOpc      := oModel:GetOperation()
Local cMemo     := ''

If nOpc == 3 .Or. nOpc == 4
	If !Empty( oModelNUE:GetValue("NUE_COD") ) .And. oModelNUE:CanSetValue("NUE_DESC")
		cMemo := oModelNUE:GetValue("NUE_DESC")
		JurSpell(, @cMemo)
		oModelNUE:SetValue("NUE_DESC", cMemo)
	EndIf
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144ATLAM
Função para validar os referências dos campos de contrato envolvido

@param    cCampo  Nome do campo que será validado (Fase / ou Tarefa)

@Return   cRet    Indica se a validação foi bem sucedida ou não( .T. / .F. )

@author David Gonçalves Fernandes
@since 09/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144ATLAM()
Local oModel := FWModelActive()
Local dData  := oModel:GetValue("NUEMASTER", 'NUE_DATATS')
Local cAM    := ' '

cAM := AnoMes(dData)

Return cAM

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144DESFA()
Atualiza a descrição da tarefa e-billing.
Melhoria de desempenho pra abertura de tela da pre-fatura.

@param 	 cCampo	 Nome do campo
@param   lModel  Indica se o model está ativado ou não. Utilizado como .F. em inicializador padrão cujo model ainda não está ativo
@Return  cRet    Retorna a descrição conforme o campo

@Obs Não usar JurGetDados em funções de dicionário

@author Luciano Pereira dos Santos
@since  07/01/2017
@version 2.0
/*/
//-------------------------------------------------------------------
Function JA144DESFA(cCampo,lModel)
Local cRet      := ""
Local cFaseInt  := ""
Local cDoc      := ""
Local cFase     := ""
Local cTaref    := ""
Local cAtivEb   := ""
Local oModel    := Nil
Local oModelNUE := Nil
Local cIdNUE    := ""

Default lModel  := .T.

If lModel
	oModel    := Iif( oModelOld == Nil, FWModelActive(), oModelOld)
	cIdNUE    := IIf( oModel:GetId() == 'JURA202', "NUEDETAIL", "NUEMASTER" )
	oModelNUE := oModel:GetModel(cIdNUE)
	cDoc      := oModelNUE:GetValue("NUE_CDOC")
	cFase     := oModelNUE:GetValue("NUE_CFASE" )
	cTaref    := oModelNUE:GetValue("NUE_CTAREF")
	cAtivEb   := oModelNUE:GetValue("NUE_CTAREB")
Else
	cDoc    := NUE->NUE_CDOC
	cFase   := NUE->NUE_CFASE
	cTaref  := NUE->NUE_CTAREF
	cAtivEb := NUE->NUE_CTAREB
EndIf

Do Case
	Case cCampo == 'NUE_DFASE'
		If FindFunction("J202FaseEb")
			cRet := J202FaseEb('2', cFase, cDoc) //Rotina de cache na JURA202
		Else
			cRet := Posicione("NRY", 5, xFilial("NRY") + cFase + cDoc, "NRY_DESC")
		EndIf

	Case cCampo == 'NUE_DTAREF'
		If FindFunction("J202FaseEb")
			cFaseInt := J202FaseEb('1', cFase, cDoc) //Rotina de cache na JURA202
		Else
			cFaseInt := Posicione("NRY", 5, xFilial("NRY") + cFase + cDoc, "NRY_COD")
		EndIf
		cRet := Posicione("NRZ", 2, xFilial("NRZ") + cDoc + cFaseInt + cTaref, 'NRZ_DESC')

	Case cCampo == 'NUE_DTAREB'
		If !Empty(cAtivEb)
			cRet := Posicione('NS0', 2, xFilial('NS0') + cDoc + cAtivEb, 'NS0_DESC')
		EndIf
	Otherwise
		cRet := ""
	End Case

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144CODEB()
Atualiza codigo atividade, fase e tarefa.

@param   cCampo  Nome do campo
@Return  cRet    Retorna a descrição conforme o campo

@Obs Não usar JurGetDados em funções de dicionário

@author Nivia Ferreira
@since  19/11/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Function JA144CODEB(cCampo)
Local cRet      := ""
Local cDoc      := ""
local cCliente  := ""
Local cloja     := ""
Local cAtiv     := ""
Local oModel    := Nil
Local oModelNUE := Nil

oModel    := FWModelActive()
oModelNUE := oModel:GetModel("NUEMASTER")
cDoc      := oModelNUE:GetValue("NUE_CDOC")
cAtiv     := oModelNUE:GetValue("NUE_CATIVI" )
cCliente  := oModelNUE:GetValue("NUE_CCLIEN" )
cloja     := oModelNUE:GetValue("NUE_CLOJA" )

If JAUSAEBILL(cCliente, cLoja)
	DbSelectArea("NS1")  //Tipo atividade E-billing (de-para)
	NS1->(dbSetOrder(3)) //NS1_FILIAL+NS1_CDOC+NS1_CATIVJ
	If NS1->( dbSeek( xFilial('NS1') + cDoc + cAtiv))

		DbSelectArea("NS0")  //Tipo atividade E-billing
		NS0->(dbSetOrder(1)) //NS0_FILIAL+NS0_CDOC+NS0_COD
		If NS0->( dbSeek( xFilial('NS0') + cDoc + NS1->NS1_CATIV))

			Do Case
				Case cCampo == 'NUE_CFASE'
					cRet := AllTrim(NS0->NS0_CFASE)
				Case cCampo == 'NUE_CTAREF'
					cRet := AllTrim(NS0->NS0_CTAREF)
				Case cCampo == 'NUE_CTAREB'
					cRet := AllTrim(NS0->NS0_CATIV)
				Case cCampo == 'NUE_DTAREB'
					cRet := AllTrim(NS0->NS0_DESC)
				Otherwise
					cRet := ""
			End Case
		EndIf
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144VALTS
Retorna o valor da Moeda e Valor

@param  cCodTS  Codido do Time Sheet
@param  lReval  .T. força a revalorização do Time Sheet, padrao=.F.
@param  lTela   Indica se está sendo feito via tela ou não, se por tela, realiza os ajustes via modelo
@param  lMsgErr .T. Exibe mensagem de erro da revalorização do Time Sheet, padrao=.F.

@author Jacques Alves Xavier
@since 04/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144VALTS(cCodTS, lReval, lTela, lMsgErr)
Local oModel    := Nil
Local aResult   := {}
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaNUE  := NUE->(GetArea())
Local cRecTs    := Substr(SuperGetMV( "MV_JRECTS",, "0000-00" ), 0, 4) + Substr(SuperGetMV( "MV_JRECTS",, "0000-00" ), 6, 2)  //'0000-00' sempre calcula;  '9999-99' - nunca calcula; Ex: '2011-10' - calcula apartir de outubro de 2011
Local cCliente  := ""
Local cLoja     := ""
Local cCaso     := ""
Local cPart     := ""
Local cAnoMes   := ""
Local cPrefat   := ""
Local cIDNue    := IIf( IsJura202() .And. !IsInCallStack("JA145ALT2") .And. !IsInCallStack("J202DivTs"), "NUEDETAIL", "NUEMASTER" )
Local cSolucao  := ""
Local cSigla    := ""
Local cAtivi    := ""
Local lAltHr    := NUE->(ColumnPos('NUE_ALTHR')) > 0

Default lReval  := .F.
Default lTela   := .F.
Default lMsgErr := .F.

If lTela
	oModel   := FWModelActive()
	cCliente := oModel:GetValue(cIDNue, "NUE_CCLIEN")
	cLoja    := oModel:GetValue(cIDNue, "NUE_CLOJA")
	cCaso    := oModel:GetValue(cIDNue, "NUE_CCASO")
	cPart    := oModel:GetValue(cIDNue, "NUE_CPART2")
	cAnoMes  := oModel:GetValue(cIDNue, "NUE_ANOMES")
	cAtivi   := oModel:GetValue(cIDNue, "NUE_CATIVI")
Else
	dbSelectarea('NUE')
	NUE->( dbSetOrder(1) )
	If NUE->(dbSeek(xFilial('NUE') + cCodTS)) .And. NUE->NUE_SITUAC == '1'
		cCliente := NUE->NUE_CCLIEN
		cLoja    := NUE->NUE_CLOJA
		cCaso    := NUE->NUE_CCASO
		cPart    := NUE->NUE_CPART2
		cAnoMes  := NUE->NUE_ANOMES
		cPrefat  := NUE->NUE_CPREFT
		cAtivi   := NUE->NUE_CATIVI
	EndIf
EndIf

If !Empty(cCodTS) .And. !Empty(cPart) .And. !Empty(cCliente) .And. !Empty(cLoja) .And. !Empty(cCaso) .And. !Empty(cAnoMes)

	If lReval .Or. cAnoMes >= cRecTs
		aResult    := JURA200( cCodTS, cPart, cCliente, cLoja, cCaso, cAnoMes,, cAtivi )
	Else
		aResult    := JURA200( cCodTS, cPart, cCliente, cLoja, cCaso, cAnoMes,, cAtivi )
		aResult[1] := NUE->NUE_CMOEDA
		aResult[2] := NUE->NUE_VALORH
	EndIf

	If Empty(aResult[1]) .And. lMsgErr
		lRet := .F.
		cAnoMes  := Transform(cAnoMes,'@R 9999-99')
		cSigla   := JurGetDados('RD0', 1, xFilial('RD0') + cPart, 'RD0_SIGLA')

		cSolucao := CRLF + I18N(STR0126, {cSigla , cAnoMes}) + CRLF //"-No cadastro de Participantes, verifique se existe histórico de categoria para o participante de sigla '#1' no ano-mês '#2'."
		cSolucao += I18N(STR0127, {cCliente+"|"+cLoja+"|"+cCaso, cAnoMes}) + CRLF //"-No cadastro de Caso, verifique se existe histórico da tabela de honorários para o cliente, loja e caso '#1' no ano-mês '#2'."
		cSolucao += I18N(STR0128, {cAnoMes }) //"-No cadastro de Tabela do Honorários, verifique se existe o histórico para a tabela de honorários do caso no ano-mês '#1', e se no histórico existe a categoria do participante."
		JurMsgErro(STR0025+" "+cCodTS, , cSolucao ) // "Foram encontradas inconsistências na valorização do Time Sheet"
	Else
		If !Empty(cPrefat) .And. !IsJura202()
			JA144VERPRE(cPrefat)
		EndIf

		If lTela
			oModel:LoadValue(cIDNue, "NUE_CMOEDA", aResult[1])
			oModel:LoadValue(cIDNue, "NUE_DMOEDA", Left(JurGetDados('CTO', 1, xFilial('CTO') + oModel:GetValue(cIDNue, "NUE_CMOEDA"), "CTO_SIMB"), TamSX3("NUE_DMOEDA")[1]))
			oModel:LoadValue(cIDNue, "NUE_VALORH", aResult[2])
			oModel:LoadValue(cIDNue, "NUE_VALOR" , aResult[2] * oModel:GetValue(cIDNue,"NUE_TEMPOR"))
			oModel:LoadValue(cIDNue, "NUE_CCATEG", aResult[3])
			oModel:LoadValue(cIDNue, "NUE_CUSERA", JurUsuario(__CUSERID))
			oModel:LoadValue(cIDNue, "NUE_ALTDT" , Date())
			If lAltHr
				oModel:LoadValue(cIDNue, "NUE_ALTHR", Time())
			EndIf
		Else
			RecLock("NUE", .F.)
			NUE->NUE_CMOEDA := aResult[1]
			NUE->NUE_VALORH := aResult[2]
			NUE->NUE_VALOR  := aResult[2] * NUE->NUE_TEMPOR
			NUE->NUE_CCATEG := aResult[3]
			NUE->NUE_CUSERA := JurUsuario(__CUSERID)
			NUE->NUE_ALTDT  := Date()
			If lAltHr
				NUE->NUE_ALTHR := Time()
			EndIf
			NUE->(MsUnlock())

			//Grava na fila de sincronização a alteração
			J170GRAVA("NUE", xFilial('NUE') + CCodTS, "4")

		EndIf
	EndIf
Else
	If lTela
		oModel:ClearField(cIDNue, "NUE_CMOEDA")
		oModel:ClearField(cIDNue, "NUE_DMOEDA")
		oModel:ClearField(cIDNue, "NUE_VALORH")
		oModel:ClearField(cIDNue, "NUE_VALOR")
		oModel:ClearField(cIDNue, "NUE_CCATEG")
	EndIf
EndIf

RestArea( aAreaNUE )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144VERPRE
Rotina para validar se existe pré-fatura para o Time Sheet.

@author Jacques Alves Xavier
@since 05/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144VERPRE(cPreFat, cLancTab, lMudaSit)
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaNX0   := NX0->(GetArea())
Local cMsg       := ""
Local cPartLog   := JurUsuario(__CUSERID)
Local lAlterada  := .F.
Local lIsRest    := Iif(FindFunction("JurIsRest"), JurIsRest(), .F.)

Default cLancTab := ""
Default lMudaSit := .T.

If !Empty(cPartLog)
	If !Empty(cPreFat)

		If (JurGetDados("NUR", 1, xFilial("NUR") + cPartLog, "NUR_LCPRE") == '1')
			If !Empty(cLancTab)
				cMsg := J144VlTAB(cLancTab, cPreFat)
				If !Empty(cMsg)
					lRet := JurMsgErro(cMsg) //Ver criticas de erro na rotina J144VlTAB
				EndIf
			EndIf

			If lRet .And. NX0->(dbSeek(xFilial('NX0') + cPreFat))
				If NX0->NX0_SITUAC $ '2|3|D|E'  //Pré-Fatura alterável
					If lMudaSit
						lAlterada := NX0->NX0_SITUAC == '3' // Pré-Fatura já alterada
						J144AltPre(cPreFat, I18N(STR0141, {NUE->NUE_COD}), !lAlterada) // "Atualização no Time Sheet '#1'."
					EndIf
				ElseIf NX0->NX0_SITUAC == "6" // Minuta Emitida
					lRet := J144VerAltM()
					If (!lRet)
						lRet := JurMsgErro(STR0055, , JMsgVerPre('1')) // "Não foi possível realizar as alterações, o lançamento possui minuta!"
					EndIf
				ElseIf NX0->NX0_SITUAC $ '5|7|9|A|B' //Emitir Minuta | Minuta Emitida | Minuta Cancelada | Minuta Sócio | Minuta Sócio Emitida | Minuta Sócio Cancelada
					lRet := JurMsgErro(STR0055, , JMsgVerPre('1')) // "Não foi possível realizar as alterações, o lançamento possui minuta!"
				ElseIf NX0->NX0_SITUAC == '4' //'Definitivo'
					lRet := JurMsgErro(STR0030, , JMsgVerPre('1')) // "Não foi possível realizar as alterações, o lançamento possui pré-fatura em Definifivo!"
				ElseIf NX0->NX0_SITUAC == 'C' .And. !lIsRest // Em Revisão - permitir o ajuste quando partir do REST, devido a alteração de valor e partic
					lRet := JurMsgErro(STR0124, , JMsgVerPre('1')) // "Não foi possível realizar as alterações, o lançamento possui pré-fatura em processo de Revisão!"
				ElseIf NX0->NX0_SITUAC == 'F' .And. !lIsRest //Aguardando Sincronização
					lRet := JurMsgErro(STR0124, , JMsgVerPre('1')) // "Não foi possível realizar as alterações, o lançamento possui pré-fatura em processo de Revisão!"
				EndIf
			EndIf
		Else
			lRet := JurMsgErro(STR0102, , JMsgVerPre('2')) //"O participante não tem permissão para alterar Tabelado com Pré-faturas."
		EndIf
	EndIf

Else
	lRet := JurMsgErro(STR0109, , JMsgVerPre('3')) //"O usuário logado não esta relacionado a nenhum participante! Verifique."
EndIf

RestArea( aArea )
RestArea( aAreaNX0 )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J49VerAltM
Verifica os campos que foram alterados

@author Willian Kazahaya
@since 26/01/2022
/*/
//-------------------------------------------------------------------
Static Function J144VerAltM()
Local oMdl      := FwModelActive()
Local oMdlNUE   := oMdl:GetModel("NUEMASTER")
Local aCmpsAlt  := {"NUE_DESC", "NUE_CUSERA", "NUE_ANOMES", "NUE_ALTHR", "NUE_ACAOLD", ;
                    "NUE_CCLILD", "NUE_CLJLD", "NUE_CCSLD", "NUE_PARTLD", "NUE_CMOTWO", ;
                    "NUE_OBSWO"} // São alteraveis campos Integ. LegalDesk + Campos de Log Alt
                                 // + campo de descrição
Return JVldAltMdl(oMdlNUE, 1, aCmpsAlt)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144F3NV4
Monta a consulta padrão de Serviços Tabelados
Uso Geral.

@Return   lRet .T./.F. As informações são válidas ou não

@author Jacques Alves Xavier
@since 08/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144F3NV4()
Local lRet     := .F.
Local aAreaNV4 := NV4->( GetArea() )
Local aArea    := GetArea()
Local cQuery   := JA144QRY('NV4')

cQuery := ChangeQuery(cQuery, .F.)

uRetorno := ''

RestArea( aAreaNV4 )
RestArea( aArea )

If JurF3Qry( cQuery, 'NV4NUE', 'NV4RECNO', @uRetorno, , {"NV4_COD"} )
	NV4->( dbGoto( uRetorno ) )
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144QRY
Monta a query de Serviços Tabelados que podem ser vinculados ao Time Sheet

@Param cAliasF3   Tabela de pesquisa

@Return cQuery	 	Query montada

@author Jacques Alves Xavier
@since 08/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA144QRY(cAliasF3, CodTab)
Local cQuery   := ''
Default CodTab := ''

If cAliasF3 == 'NV4'
	cQuery := " SELECT NV4.NV4_COD, NV4.NV4_CCLIEN, NV4.NV4_CLOJA, NV4.NV4_CCASO, NV4.NV4_CTPSRV, "
	cQuery += " NR3.NR3_DESCHO, NV4.NV4_VLHTAB, NV4.R_E_C_N_O_ NV4RECNO "
	cQuery += " FROM " + RetSqlName("NV4") + " NV4,"
	cQuery +=      " " + RetSqlName("NVE") + " NVE,"
	cQuery +=      " " + RetSqlName("NRD") + " NRD,"
	cQuery +=      " " + RetSqlName("NR3") + " NR3 "
	cQuery +=  " WHERE NR3.NR3_FILIAL = '" + xFilial( "NR3" ) +"'"
	cQuery +=    " AND NV4.NV4_FILIAL = '" + xFilial( "NV4" ) +"'"
	cQuery +=    " AND NVE.NVE_FILIAL = '" + xFilial( "NVE" ) +"'"
	cQuery +=    " AND NRD.NRD_FILIAL = '" + xFilial( "NRD" ) +"'"
	If !Empty(CodTab)
		cQuery += " AND NV4.NV4_COD = '" + CodTab +"'"
	EndIf
	cQuery +=    " AND NV4.NV4_CTPSRV = NR3.NR3_CITABE "
	cQuery +=    " AND NV4.NV4_CCLIEN = NVE.NVE_CCLIEN "
	cQuery +=    " AND NV4.NV4_CLOJA = NVE.NVE_LCLIEN "
	cQuery +=    " AND NV4.NV4_CCASO = NVE.NVE_NUMCAS "
	cQuery +=    " AND NR3.NR3_CIDIOM = NVE.NVE_CIDIO "
	cQuery +=    " AND NV4.NV4_SITUAC = '1' "
	cQuery +=    " AND NRD.NRD_COD = NR3.NR3_CITABE "
	cQuery +=    " AND NRD.NRD_LANTS = '1' " //O tabelado permita vincular timeSheet
	cQuery +=    " AND ((NV4.NV4_CONC = '1' AND NV4.NV4_DTCONC >= '" + DtoS(FWFldGet('NUE_DATATS')) + "') OR NV4.NV4_CONC = '2') "
	cQuery +=    " AND NV4.NV4_CCLIEN = '" + FWFldGet('NUE_CCLIEN') + "'"
	cQuery +=    " AND NV4.NV4_CLOJA = '" + FWFldGet('NUE_CLOJA') + "'"
	cQuery +=    " AND NV4.NV4_CCASO = '" + FWFldGet('NUE_CCASO') + "'"
	cQuery +=    " AND NR3.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NV4.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NVE.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NRD.D_E_L_E_T_ = ' ' "

EndIf

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144VLT()
Verifica se o valor do campo de serviço tabelado é válido quando o mesmo o digita no campo
Uso Geral.

@param  cMaster  Fields ou Grid a ser verificado
@param  cCampo   Campo de tabelado a ser verificado

@Return lRet    .T./.F. As informações são válidas ou não

@sample Vazio().Or.JA144VLT("NUEMASTER","NUE_CLTAB")

@author Jacques Alves Xavier
@since 09/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144VLT(cMaster, cCampo)
Local lRet     := .F.
Local aArea    := GetArea()
Local cQryRes  := GetNextAlias()
Local oModel   := FWModelActive()
Local cCod     := oModel:GetValue(cMaster, cCampo)
Local cQuery   := JA144QRY('NV4', cCod)

cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQryRes, .T., .T.)

lRet := !(cQryRes)->(EOF())
(cQryRes)->(dbcloseArea())

If !lRet
	JurMsgErro(STR0031) // Não é possível vincular este Lançamento Tabelado para o Cliente/Loja e Caso preenchido. Verifique!
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144REVAL
Revaloriza o time-sheet posicionado.

@Param cAliasF3   Tabela de pesquisa

@Return cQuery	 	Query montada

@author Jacques Alves Xavier
@since 08/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144REVAL(cCodTS)
Local lRet          := .T.
Local lLiberaTudo   := .T.
Local lLibAlteracao := .T.
Local lLibParam     := .T. //Se MV_JCORTE preenchido corretamente
Local aRetBlqTS     := {}
Local dDataTs       := NUE->NUE_DATATS
Local cCaso         := NUE->NUE_CCASO
Local cClien        := NUE->NUE_CCLIEN
Local cLoja         := NUE->NUE_CLOJA
Local lAltHr        := NUE->(ColumnPos('NUE_ALTHR')) > 0

If NUE->NUE_SITUAC == "1"

	If !Empty(NUE->NUE_CPREFT)
		lRet := !(JurGetDados("NX0", 1, xFilial("NX0") + NUE->NUE_CPREFT, "NX0_SITUAC") $ "C|F")
	EndIf

	If lRet
		//Valida  a existência de Fatura Adicional faturada cujo período de referência englobe a data do Lançamento
		If lRet
			lRet := JurBlqLnc( cClien, cLoja, cCaso, dDataTs, "TS" )
		EndIf

		If lRet
			Begin Sequence
				If ApMsgYesNo(STR0033) //"Deseja revalorizar o Time-Sheet selecionado?"
					aRetBlqTS     := JBlqTSheet(NUE->NUE_DATATS)
					lLiberaTudo   := aRetBlqTS[1]
					lLibAlteracao := aRetBlqTS[3]
					lLibParam     := aRetBlqTS[5]

					If !lLiberaTudo .And. !lLibAlteracao .And. lLibParam
						MsgInfo(STR0117 + AllTrim(NUE->NUE_COD) + ". ")  // "Você não tem permissão para alterar o Time Sheet: "
						Break
					EndIf

					If lLibParam
						If JA144VALTS(cCodTS, .T., .F.)
							If NUE->(Dbseek(xFilial('NUE') + cCodTS))
								RecLock("NUE", .F.) //Ajusta o timeSheet atual
								NUE->NUE_CUSERA := JurUsuario(__CUSERID)
								NUE->NUE_ALTDT  := Date()
								If lAltHr
									NUE->NUE_ALTHR := Time()
								EndIf
								NUE->(MsUnlock())
								NUE->(DbCommit())
							EndIf

							MsgInfo(STR0086) //"Time Sheet Revalorizado com sucesso!"
						EndIf
					EndIf
				EndIf
			End Sequence
		EndIf
	Else
		MsgInfo( STR0140, STR0118 ) // "Atenção" "Alteração não permitida. Time Sheet está vinculado a pré-fatura em processo de Revisão."
	EndIf

Else
	MsgInfo( STR0139, STR0118 ) // "Atenção" // "Alteração não permitida. Time Sheet está concluído."
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144VE
Tudo OK do Model

@author Fabio Crespo Arruda
@since 29/05/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144VE(oModel)
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaNW0 := NW0->( GetArea() )

If oModel:GetOperation() == MODEL_OPERATION_DELETE

	NW0->( dbSetOrder(1) ) //NW0_FILIAL+NW0_CTS+NW0_SITUAC+NW0_PRECNF+NW0_CFATUR+NW0_CESCR+NW0_CWO
	If NW0->( dbSeek(xFilial("NW0") + NUE->NUE_COD) )

		While !NW0->( EOF() ) .And. xFilial("NW0") + NW0->NW0_CTS == xFilial("NUE") + NUE->NUE_COD

			If (NW0->NW0_SITUAC $ "2|3") .And. NW0->NW0_CANC == '2'  //2- Não cancelada
				lRet := .F.
				Exit
			EndIf

			NW0->( dbSkip() )

		EndDo
	EndIf
EndIf

RestArea(aAreaNW0)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144VE
Função para validar se existe o histórico do caso para o período do TS.

@author Felipe Bonvicini Conti
@since 07/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144VHisCa()
Local lRet    := .T.
Local cSQL    := ""
Local aSqlRet := {}
Local cData   := JSToFormat(DToS(FwFldGet('NUE_DATATS')), 'YYYYMM')

	cSQL := " SELECT COUNT(NUU.R_E_C_N_O_) QTD"
	cSQL +=   " FROM " + RetSqlname('NUU') + " NUU "
	cSQL +=   " WHERE NUU.NUU_FILIAL = '" + xFilial("NUU") +"' "
	cSQL +=     " AND NUU.D_E_L_E_T_ = ' ' "
	cSQL +=     " AND NUU.NUU_CCLIEN = '" + FwFldGet('NUE_CCLIEN') + "'"
	cSQL +=     " AND NUU.NUU_CLOJA = '" + FwFldGet('NUE_CLOJA') + "'"
	cSQL +=     " AND NUU.NUU_CCASO = '" + FwFldGet('NUE_CCASO') + "'"
	cSQL +=     " AND NUU.NUU_AMINI <= '" + cData + "'"
	aSqlRet := JurSQL(cSQL, {"QTD"})

	lRet := aSqlRet[1][1] > 0

	If !lRet
		JurMsgErro(STR0057) //"Não existe histórico do caso para esta data do Time Sheet!"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LRetSA1
Revisao da Pré-Fatura
@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function LRetSA1( oLookUp, oObj, cCli, CLoja )
Local oSXB     := oLookUp:GetCargo()
Local aReturns := oSXB:GetReturnFields()

cCli  := PadR(Eval(& ('{||' + aReturns[1] + '}')), Len(cCli))
cLoja := PadR(Eval(& ('{||' + aReturns[2] + '}')), Len(cLoja))

oObj:Refresh()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144Lote(cOption)
Verifica se a consulta padrão de caso deve ser filtrada por cliente
e loja
Uso Geral.
@param 	cOption 7
@Return cRet	 	Comando para filtro
@sample @#JURNVE('NSZMASTER', 'NSZ_CCLIEN', 'NSZ_LCLIEN')
@author Clóvis Eduardo Teixeira
@since 19/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144Lote(cOption)
Local cRet := "@#@#"

If cOption == '1'
	If !(Empty(cCliOr) .And. Empty(cLojaOr))
		cRet := "@#NVE->NVE_CCLIEN == '"+cCliOr+"' .AND. NVE->NVE_LCLIEN == '"+cLojaOr+"'"
	Else
		cRet := "@#"
	EndIf
Else
	If !(Empty(cCliDes) .And. Empty(cLojaDes))
		cRet := "@#NVE->NVE_CCLIEN == '"+cCliDes+"' .AND. NVE->NVE_LCLIEN == '"+cLojaDes+"'"
	Else
		cRet := "@#"
	EndIf
Endif

If !IsInCallStack("JA143DLG")
	cRet := cRet+"@#"
Else
	If cRet == "@#"
		cRet := cRet+"NVE->NVE_LANDSP == '1'@#"
	Else
		cRet := cRet+" .AND. NVE->NVE_LANDSP == '1'@#"
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144DivTS
Tela para informar o Cliente/Loja/Caso/UTs que receberá a divisão do valor do TS

@Param   aParam   , Parâmetros para dividir o TS sem exibir a tela
@Param   nNewRecTS, Passar como referência para receber o recno do TS criado na divisão
@Param   nMVJurTS2, Apontamento de Timesheet ( 1-Uts, 2-Hora Fracionada, 3-Hora:minuto )
                    Ao utilizar esse parâmetro o conteúdo do MV_JURTS2 será ignorado

@author Daniel Magalhaes
@since 27/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144DivTS(aParam, nMVJurTS2, nNewRecTS)
Local aArea       := GetArea()
Local lRet        := .T.
Local cRet        := ""
Local lWhenPart   := SuperGetMv('MV_JPARTSD',, 2) == 1 // habilita a edição de participante na divisão 1- sim; 2- não (padrão)
Local aAreaNUE    := NUE->(GetArea())
Local dDataTs     := NUE->NUE_DATATS
Local cCaso       := NUE->NUE_CCASO
Local cClien      := NUE->NUE_CCLIEN
Local cLoja       := NUE->NUE_CLOJA
Local xValAtuL    := NUE->NUE_UTL
Local xValAtuR    := NUE->NUE_UTR
Local cCpoValL    := ""
Local cCpoValR    := ""
Local oGetGrup    := Nil
Local oGetClie    := Nil
Local oGetLoja    := Nil
Local oGetCaso    := Nil
Local oGetPart    := Nil
Local oGetValR    := Nil
Local oGetValL    := Nil
Local oGetValAL   := Nil
Local oGetValAR   := Nil
Local oDlg        := Nil
Local oCkDivTxt   := Nil
Local lLibTudo    := .F.
Local lLibAlter   := .F.
Local aRetBlqTS   := {}
Local oMainColl   := Nil
Local oLayer      := FWLayer():New()
Local cLojaAuto   := SuperGetMv( "MV_JLOJAUT", .F., "2") //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local nLocLj      := 0
Local bButtonOk   := {||}
Local aCpoVal     := 0
Local lLibParam   := .T. //Se MV_JCORTE preenchido corretamente

Default aParam    := {}
Default nMVJurTS2 := SuperGetMv('MV_JURTS2',, 1) // Apontamento de Timesheet ( 1- Uts, 2-Hora Fracionada, 3-Hora:minuto)
Default nNewRecTS := 0

Private cGetGrup  := "" //Necessário por conta da consulta padrão
Private cGetClie  := ""
Private cGetLoja  := ""
Private cGetCaso  := ""

If NUE->NUE_SITUAC != '1' //Time-sheet Pendente
	lRet := JurMsgErro(I18N(STR0129, {JurInfBox('NUE_SITUAC', NUE->NUE_SITUAC)}), , STR0081) //#"O Time Sheet esta com situação '#1'."  ##"Esta operação só está disponível para Time Sheets em situação 'Pendente'."
EndIf

//Valida  a existência de Fatura Adicional faturada cujo período de referência englobe a data do Lançamento
If lRet .And. FindFunction("JurBlqLnc")
	lRet := JurBlqLnc( cClien, cLoja, cCaso, dDataTs, "TS" )
EndIf

If lRet
	If lLibParam
		aRetBlqTS := JBlqTSheet(dDataTs)
		lLibTudo  := aRetBlqTS[1]
		lLibAlter := aRetBlqTS[3]
		lLibParam := aRetBlqTS[5]
	EndIf

	IF !lLibParam
		lRet := .F.
	EndIf

	If !lLibTudo .And. !lLibAlter .And. lLibParam
		ApMsgInfo( STR0117 + NUE->NUE_COD) // "Você não tem permissão para alterar o Time Sheet: "
		lRet := .F.
	EndIf
EndIf

If !Empty(NUE->NUE_CPREFT) .And. lLibParam
	lRet := JA144VERPRE(NUE->NUE_CPREFT,, .F.)
EndIf

If lRet
	If Len(aCpoVal := J144ConvTS(1, nMVJurTS2, 'L', xValAtuL)) == 2
		cCpoValL := aCpoVal[1]
		xValAtuL := aCpoVal[2]
	EndIf
	If Len(aCpoVal := J144ConvTS(1, nMVJurTS2, 'R', xValAtuR)) == 2
		cCpoValR := aCpoVal[1]
		xValAtuR := aCpoVal[2]
	EndIf

	If Empty(aParam) .Or. Len(aParam) < 10
		DEFINE MSDIALOG oDlg TITLE STR0076 FROM 000, 000 TO 290, 590 PIXEL // ###"Dividir TS com:"

		oTela   := FWFormContainer():New( oDlg )
		cIdTela := oTela:CreateHorizontalBox( 100 )
		oTela:Activate( oDlg, .F. )
		oPnlDlg := oTela:GeTPanel( cIdTela )

		oLayer:init(oPnlDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
		oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
		oMainColl := oLayer:GetColPanel( 'MainColl' )

		oGetGrup := TJurPnlCampo():New(005,006,050,022,oMainColl, ,'NUE_CGRPCL', {|| },{|| },Nil,Nil,Nil,'ACY'   ) //"Grupo"
		oGetGrup:SetValid({|| JurTrgGCLC(@oGetGrup, @cGetGrup, @oGetClie, @cGetClie, @oGetLoja, @cGetLoja, @oGetCaso, @cGetCaso, "GRP") })

		oGetClie := TJurPnlCampo():New(005,066,050,022,oMainColl, ,'NUE_CCLIEN', {|| },{|| },Nil,Nil,Nil,'SA1NUH') //"Cliente"
		oGetClie:SetValid({|| JurTrgGCLC(@oGetGrup, @cGetGrup, @oGetClie, @cGetClie, @oGetLoja, @cGetLoja, @oGetCaso, @cGetCaso, "CLI") })

		oGetLoja := TJurPnlCampo():New(005,126,040,022,oMainColl, ,'NUE_CLOJA',  {|| },{|| },Nil,Nil,Nil,Nil     ) //"Loja"
		oGetLoja:SetValid({|| JurTrgGCLC(@oGetGrup, @cGetGrup, @oGetClie, @cGetClie, @oGetLoja, @cGetLoja, @oGetCaso, @cGetCaso, "LOJ") })

		If (cLojaAuto == "1")
			oGetLoja:Hide()
			nLocLj := 45
		EndIf

		oGetCaso := TJurPnlCampo():New(005,176-nLocLj,050,022,oMainColl, ,'NUE_CCASO', {|| },{|| },Nil,Nil,Nil,'NVENUE') //"Caso"
		oGetCaso:SetValid({|| JurTrgGCLC(@oGetGrup, @cGetGrup , @oGetClie, @cGetClie, @oGetLoja, @cGetLoja, @oGetCaso, @cGetCaso, "CAS") })

		oGetPart := TJurPnlCampo():New(005,238-nLocLj,050,022,oMainColl, ,'NUE_SIGLA1',{|| },{|| },Nil,Nil,Nil,'RD0ATV') //"Participante"
		oGetPart:SetValid({|| J144VldPart(oGetPart:GetValue(), dDataTs)})
		oGetPart:SetWhen({|| lWhenPart})

		oGetValAL := TJurPnlCampo():New(040,006,085,022,oMainColl,STR0079 + AllTrim(RetTitle(cCpoValL)) + ":", cCpoValL,{||},{||},xValAtuL,Nil,.F.,Nil) //"Tempo do TS Atual"

		oGetValAR := TJurPnlCampo():New(040,126,085,022,oMainColl,STR0079 + AllTrim(RetTitle(cCpoValR)) + ":", cCpoValR,{||},{||},xValAtuR,Nil,.F.,Nil) //"Tempo do TS Atual"

		oGetValL := TJurPnlCampo():New(075,006,085,022,oMainColl,STR0077 + AllTrim(RetTitle(cCpoValL))+ ":", cCpoValL,{|| },{||},Nil,Nil,Nil,Nil) //"Tempo do novo TS"
		oGetValL:SetValid({|| Empty(oGetValL:GetValue()) .Or. JA144VLTRB('1', oGetValL, oGetValAL,oGetValR, oGetValAR, nMVJurTS2) })

		oGetValR := TJurPnlCampo():New(075,126,085,022,oMainColl,STR0077 + AllTrim(RetTitle(cCpoValR))+ ":", cCpoValR,{|| },{||},Nil,Nil,Nil,Nil) //"Tempo do novo TS"
		oGetValR:SetValid({|| Empty(oGetValR:GetValue()) .Or. JA144VLTRB('2', oGetValL, oGetValAL,oGetValR, oGetValAR, nMVJurTS2) })

		oCkDivTxt := TJurCheckBox():New( 89, 223, STR0101, , oMainColl, 100, 10, ,{ ||  } , , , , , , .T., , , )
		oCkDivTxt:SetCheck(.F.)

		bButtonOk := {|| cRet := JA144ETL(oGetGrup:GetValue(), oGetClie:GetValue(), oGetLoja:GetValue(), oGetCaso:GetValue(), oGetPart:GetValue(),;
										oGetValAL:GetValue(), oGetValAR:GetValue(), oGetValL:GetValue(), oGetValR:GetValue(),;
										oCkDivTxt:Checked(), nMVJurTS2, @nNewRecTS), Iif(cRet != ".F.", oDlg:End(), Nil)}

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bButtonOk, {|| cRet := ".F.", oDlg:End()},, /*aButtons*/,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )
	Else
		cRet := JA144ETL(aParam[1], aParam[2], aParam[3], aParam[4], aParam[5], aParam[6], aParam[7], aParam[8], aParam[9], aParam[10], nMVJurTS2, @nNewRecTS)

	EndIf
Else
	cRet := ".F."
EndIf

NUE->( RestArea(aAreaNUE) )
RestArea( aArea )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144ConvTS(nTpOrig, nTpDest, cTpCpo, xValor)
Converte o valor do tipo de apontamento para outro devolvendo tambem o
campo correspondente

@param  nTpOrig   Tipo de apontamento origem  ( 1- Uts, 2-Hora Fracionada, 3-Hora:minuto)
@param  nTpDest   Tipo de apontamento destino ( 1- Uts, 2-Hora Fracionada, 3-Hora:minuto)
@param  cTpCpo    Tipo de campo: 'L'- Lançado; 'R' - Revisado
@param  xValor    Valor a ser convertido

@Return aRet[1]   Campo da tabela de TS correspondente ao valor convertido
         aRet[2]   Valor convertido

@author Luciano Pereira dos Santos
@since 05/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144ConvTS(nTpOrig, nTpDest, cTpCpo, xValor)
Local aRet    := {}
Local cCampo  := ''

Do Case
Case nTpDest == 1
	cCampo := "NUE_UT" + cTpCpo
	xValor := Val(JURA144C1(nTpOrig, nTpDest, cValtoChar(xValor)))
Case nTpDest == 2
	cCampo := "NUE_TEMPO" + cTpCpo
	xValor := Val(JURA144C1(nTpOrig, nTpDest, cValtoChar(xValor)))
Case nTpDest == 3
	cCampo := "NUE_HORA" + cTpCpo
	xValor := Transform(JURA144C1(nTpOrig, nTpDest, cValtoChar(xValor)), Alltrim(X3Picture(cCampo)))
EndCase

aRet := {cCampo, xValor}

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144DivTmp
Faz o reateio da divisão de timesheet

@param  xValAtuL , Valor lançado do Timesheet atual
@param  xValAtuR , Valor Revisado do Timesheet atual
@param  xValNovL , Valor lançado do Timesheet novo
@param  xValNovR , Valor Revisado do Timesheet novo
@param  nMVJurTS2, Sobrescreve o valor do parâmetro MV_JURTS2
                   (Caso não seja enviado nenhum valor, será
                    utilizado o valor original do parâmetro MV_JURTS2)

@author Luciano Pereira dos Santos
@since 05/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144DivTmp(xValAtuL, xValAtuR, xValNovL, xValNovR, nMVJurTS2)
Local aRet      := {}
Local lMVJurTS3 := SuperGetMv('MV_JURTS3', Nil, .F.)
Local nI        := 0
Local aValAtuL  := {}
Local aValAtuR  := {}
Local aValNovL  := {}
Local aValNovR  := {}

Default nMVJurTS2 := SuperGetMv('MV_JURTS2', Nil, 1 )

//Calcula o valor revisado do Ts atual em UT Fracionada
xValAtuR := Val( JURA144C1(nMVJurTS2, 1, cValtoChar(xValAtuR) ) )
xValNovR := Val( JURA144C1(nMVJurTS2, 1, cValtoChar(xValNovR) ) )

//Calcula o valor lançado do Ts atual em UT Fracionada
xValAtuL := Val( JURA144C1(nMVJurTS2 , 1, cValtoChar(xValAtuL) ) )
xValNovL := Val( JURA144C1(nMVJurTS2 , 1, cValtoChar(xValNovL) ) )

If !lMVJurTS3
	xValNovR := Round( xValNovR , 0 )
	xValAtuR := Round( xValAtuR , 0 )
	xValNovL := Round( xValNovL , 0 )
	xValAtuL := Round( xValAtuL , 0 )
EndIf

xValAtuR := xValAtuR - xValNovR
xValAtuL := xValAtuL - xValNovL

For nI := 1 To 3
	Aadd(aValAtuL, J144ConvTS(1, nI, 'L', xValAtuL))
	Aadd(aValAtuR, J144ConvTS(1, nI, 'R', xValAtuR))
	Aadd(aValNovL, J144ConvTS(1, nI, 'L', xValNovL))
	Aadd(aValNovR, J144ConvTS(1, nI, 'R', xValNovR))
Next nI

aRet := {aValAtuL, aValAtuR, aValNovL, aValNovR}

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144ETL(cCodGrp, cCodCli, cCodLoj, cCodCas, cSigla, xValAtuL, xValAtuR, xNewValL, xNewValR, lDivTxt)
Executa a divisao da TS para o Cliente/Loja/Caso/UTs definido

@Param   cCodGrp  , Código do grupo para a divisão de Timesheet
@Param   cCodCli  , Código do cliente para a divisão de Timesheet
@Param   cCodLoj  , Código da loja para a divisão de Timesheet
@Param   cCodCas  , Código do Caso para a divisão de Timesheet
@Param   cSigla   , Sigla do participante para a divisão de Timesheet
@Param   xValAtuL , Valor lançado atual (conforme o parametro MV_JURTS2)
@Param   xValAtuL , Valor revisado atual (conforme o parametro MV_JURTS2)
@Param   xNewValL , Valor lançado Novo (conforme o parametro MV_JURTS2)
@Param   xNewValR , Valor revisado Novo (conforme o parametro MV_JURTS2)
@Param   lDivTxt  , .T. Abre a tela de edição da descrição do TimeSheet
@param   nMVJurTS2, Sobrescreve o valor do parâmetro MV_JURTS2
                    (Caso não seja enviado nenhum valor, será
                     utilizado o valor original do parâmetro MV_JURTS2)
@Param   nNewRecTS, Passar como referência para receber o recno do TS criado na divisão

@author Luciano Pereira dos Santos
@since 28/04/2011
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function JA144ETL(cCodGrp, cCodCli, cCodLoj, cCodCas, cSigla, xValAtuL, xValAtuR, xNewValL, xNewValR, lDivTxt, nMVJurTS2, nNewRecTS)
Local nPosAtuL    := 1
Local nPosAtuR    := 2
Local nPosNovL    := 3
Local nPosNovR    := 4
Local oStruct     := FWFormStruct( 1, "NUE" )
Local aStrcNUE    := oStruct:GetFields()
Local oModelFw    := Nil
Local lRet        := .T.
Local cCpoValR    := ""
Local cCpoValL    := ""
Local aAreaNUE    := NUE->(GetArea())
Local aAreaNX0    := NX0->(GetArea())
Local cCodTS      := NUE->NUE_COD
Local cNumPreF    := NUE->NUE_CPREFT
Local cCliOrig    := NUE->NUE_CCLIEN
Local cLojOrig    := NUE->NUE_CLOJA
Local cCasOrig    := NUE->NUE_CCASO
Local dDataTS     := NUE->NUE_DATATS
Local cTxtOri     := NUE->NUE_DESC
Local cTxtDes     := cTxtOri
Local cPreTsNew   := ""
Local cNewCodTS   := ""
Local aDataNUE    := {}
Local aNewData    := {}
Local aEbil       := {}
Local nIdx        := 1
Local cCampo      := ""
Local lIsJ202     := IsJura202()
Local lTemCsPre   := lIsJ202 .And. J144TemCs(cNumPreF, cCodCli, cCodLoj, cCodCas)
Local aDivTxt     := {.T.,'',''}
Local cSolucao    := ""
Local aTsAtual    := {}
Local aTsNovo     := {}
Local oCommit     := JA144BCOMMIT():New()
Local aDivEmp     := J144DivTmp(xValAtuL, xValAtuR, xNewValL, xNewValR, nMVJurTS2)
Local cFase       := ""
Local cTarefa     := ""
Local cAtivEb     := ""
Local cDocEb      := ""
Local lEbil       := .F.
Local lAltHr      := NUE->(ColumnPos('NUE_ALTHR')) > 0
Local cEscrAnt	  := ""
Local cCCAnt	  := ""

Default nMVJurTS2 := SuperGetMv("MV_JURTS2", Nil, 1)
Default nNewRecTS := 0

Private cInstanc  := "NUE"

If lIsJ202
	oModelOld := FWModelActive()
EndIf

If Len(aDivEmp) >= 4
	cCpoValL  := aDivEmp[nPosNovL][nMVJurTS2][1]
	cCpoValR  := aDivEmp[nPosNovR][nMVJurTS2][1]
EndIf

If Empty(cCodCli) .Or. Empty(cCodLoj) .Or. Empty(cCodCas)
	lRet := JurMsgErro(STR0078,, STR0061) //"Preencher corretamente as informações" ### Dados do Cliente Destino são Obrigatórios.
EndIf

If lRet .And. FindFunction("JurBlqLnc") //Valida  a existência de Fatura Adicional faturada cujo período de referência englobe a data do Lançamento
	lRet := JurBlqLnc( cCodCli, cCodLoj, cCodCas, dDataTS, "TS" )
EndIf

If lRet .And. aDivEmp[nPosNovL][1][2] == 0 .And. aDivEmp[nPosNovR][1][2] == 0
	cSolucao := STR0085 + "'" + Alltrim(RetTitle(cCpoValL)) + "'" + STR0095 + "'" + Alltrim(RetTitle(cCpoValR)) + "'" + "."
	lRet := JurMsgErro(I18N(STR0125, {Alltrim(RetTitle(cCpoValL)), Alltrim(RetTitle(cCpoValR))}), , cSolucao) //#"Os campos '#1' e '#2' não foram preenchidos."   ##"Informe o campo " ### " ou "
EndIf

If aDivEmp[nPosAtuL][1][2] == 0 .And. aDivEmp[nPosAtuR][1][2] == 0
	JurErrLog(STR0111, STR0074) //#"Não é possível dividir o valor total para o novo Time Sheet." ## Dividir TS
	lRet := .F.
EndIf

If lRet
	If JA144Ebil(cCliOrig, cLojOrig, cCodCli, cCodLoj,, @lEbil) //Se o documento e-billing é diferente ou o cliente destino tem e-billing
		aEbil := JA148AEBIL(cCodCli, cCodLoj,, .T.)
		If !Empty(aEbil) .And. Len(aEbil) >= 9
			lRet    := aEbil[1]
			cFase   := aEbil[5]
			cTarefa := aEbil[6]
			cAtivEb := aEbil[7]
			cDocEb  := aEbil[9]
		Else
			lRet    := .F.
		EndIf
	ElseIf lEbil
		lRet    := .T.
		cFase   := NUE->NUE_CFASE
		cTarefa := NUE->NUE_CTAREF
		cAtivEb := NUE->NUE_CTAREB
		cDocEb  := NUE->NUE_CDOC
	EndIf
EndIf

If lRet .And. lDivTxt //Edição da descrição do Time Sheet
	aDivTxt := J144TsTxt(cTxtOri, cTxtDes)
	lRet    := aDivTxt[1]
	cTxtOri := aDivTxt[2]
	cTxtDes := aDivTxt[3]
EndIf

If lRet
	//Lê os dados do registro da NUE atual
	For nIdx := 1 To Len(aStrcNUE)
		If (!aStrcNUE[nIdx][14] .Or. aStrcNUE[nIdx][3] $ "NUE_SIGLA1|NUE_SIGLA2") .And.;
			!(aStrcNUE[nIdx][3] $ "NUE_FILIAL|NUE_COD|NUE_VALOR|NUE_VALOR1|NUE_COTAC|NUE_COTAC1|NUE_COTAC2|NUE_CMOED1|NUE_CPART1|NUE_CPART2"+;
			                      "|NUE_DATAIN|NUE_HORAIN|NUE_ALTDT|NUE_CUSERA|NUE_ALTHR|NUE_VTSANT|NUE_SITUAC"+;
			                      "|NUE_CLTAB|NUE_CODLD|NUE_CREPRO|NUE_CDWOLD|NUE_OBSWO|NUE_CMOTWO|NUE_PARTLD|NUE_ACAOLD|NUE_CCLILD|NUE_CLJLD"+;
			                      "|NUE_CCSLD|NUE_OK|NUE_REVISA|NUE_FLUREV|NUE_DTREPR|NUE_CRETIF"+; //Campos que nao serão replicados
			                      Iif(Empty(cSigla), "", "|NUE_CESCR|NUE_CC| |")) //Se informar o participante os campos de escritorio e centro de custo são preenchidos pela regra
			cCampo := aStrcNUE[nIdx][3]
			aAdd(aNewData, {cCampo, NUE->(FieldGet(FieldPos(cCampo)))})

		EndIf
		If !Empty(cSigla)
			cEscrAnt	  := NUE->(FieldGet(FieldPos("NUE_CESCR")))
			cCCAnt	  := NUE->(FieldGet(FieldPos("NUE_CC")))
		EndIf
	Next nIdx

	//Altera os arrays para gravacao -> aNewData (TS Resultado da Divisao) e aDataNUE (TS Atual Alterada)
	For nIdx := 1 To Len(aNewData)
		cCampo := aNewData[nIdx][1]

		Do Case
		Case cCampo == "NUE_CGRPCL"
			aNewData[nIdx][2] := cCodGrp
		Case cCampo == "NUE_CCLIEN"
			aNewData[nIdx][2] := cCodCli
		Case cCampo == "NUE_CLOJA"
			aNewData[nIdx][2] := cCodLoj
		Case cCampo == "NUE_CCASO"
			aNewData[nIdx][2] := cCodCas
		Case cCampo == "NUE_SIGLA1" //No modelo devem ser gravados os campos de sigla
			If Empty(cSigla)
				cSigla := JurGetDados('RD0', 1, xFilial('RD0') + NUE->NUE_CPART1, 'RD0_SIGLA')
			EndIf
			aNewData[nIdx][2] := cSigla
		Case cCampo == "NUE_SIGLA2"
			If Empty(cSigla)
				cSigla := JurGetDados('RD0', 1, xFilial('RD0') + NUE->NUE_CPART2, 'RD0_SIGLA')
			EndIf
			aNewData[nIdx][2] := cSigla
		Case cCampo == "NUE_TSDIV"
			aNewData[nIdx][2] := "1"
			aAdd(aDataNUE, {cCampo, "1"})
		Case cCampo == "NUE_CODPAI"
			aNewData[nIdx][2] := cCodTS
		Case cCampo == "NUE_CFASE"
			aNewData[nIdx][2] := cFase
		Case cCampo == "NUE_CTAREF"
			aNewData[nIdx][2] := cTarefa
		Case cCampo == "NUE_CTAREB"
			aNewData[nIdx][2] := cAtivEb
		Case cCampo == "NUE_CDOC"
			aNewData[nIdx][2] := cDocEb
		Case cCampo == "NUE_DESC"
			aNewData[nIdx][2] := cTxtDes
			aAdd(aDataNUE, {cCampo, cTxtOri})
		Case cCampo == "NUE_CPREFT"
			If lTemCsPre
				aNewData[nIdx][2] := cNumPreF
				cPreTsNew         := cNumPreF
			Else
				aNewData[nIdx][2] := '' //Não vincular automaticamente o Time Sheet se o caso nao estiver na mesma pré-fatura.
			EndIf
		EndCase

	Next nIdx

	For nIdx := 1 To 3 //Complementa os campos para atualizar o TS Novo
		Aadd(aNewData, aDivEmp[nPosNovL][nIdx])
		Aadd(aNewData, aDivEmp[nPosNovR][nIdx])
	Next nIdx

	For nIdx := 1 To 3 //Complementa os campos para atualizar o TS Atual
		Aadd(aDataNUE, aDivEmp[nPosAtuL][nIdx])
		Aadd(aDataNUE, aDivEmp[nPosAtuR][nIdx])
	Next nIdx

	//Inicia a transacao para alterar a TS Atual e gerar a TS Dividida
	Begin Transaction

		oModelFw:= MPFormModel():New( "JURA144DIV", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
		oModelFw:AddFields( "NUEMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
		oModelFw:SetDescription( STR0008 ) // "Modelo de Dados de Time Sheets dos Profissionais"
		oModelFw:GetModel( "NUEMASTER" ):SetDescription( STR0009 ) // "Dados de Time Sheets dos Profissionais"
		oModelFw:InstallEvent("JA144BCOMMIT", /*cOwner*/, oCommit)

		//Cria o TS Novo Dividido
		oModelFw:SetOperation( 3 )
		oModelFw:Activate()
		cNewCodTS := oModelFw:GetValue("NUEMASTER", "NUE_COD")

		For nIdx := 1 To Len(aNewData)
			cCampo := aNewData[nIdx][1]

			If oModelFw:CanSetValue("NUEMASTER", cCampo )
				lRet := lRet .And. oModelFw:SetValue("NUEMASTER", cCampo, aNewData[nIdx][2] )
			Else
				lRet := lRet .And. oModelFw:LoadValue("NUEMASTER", cCampo, aNewData[nIdx][2] )
			EndIf
		Next nIdx

		If !Empty(cSigla) 

			cCampo := "NUE_CESCR"
			If Empty(oModelFw:GetValue("NUEMASTER",cCampo))
				If oModelFw:CanSetValue("NUEMASTER", cCampo )
					lRet := lRet .And. oModelFw:SetValue("NUEMASTER", cCampo, cEscrAnt )
				Else
					lRet := lRet .And. oModelFw:LoadValue("NUEMASTER", cCampo, cEscrAnt )
				EndIf
			EndIf
			cCampo := "NUE_CC"
			If Empty(oModelFw:GetValue("NUEMASTER",cCampo))
				If oModelFw:CanSetValue("NUEMASTER", cCampo )
					lRet := lRet .And. oModelFw:SetValue("NUEMASTER", cCampo, cCCAnt )
				Else
					lRet := lRet .And. oModelFw:LoadValue("NUEMASTER", cCampo, cCCAnt )
				EndIf
			EndIf

		EndIf

		If lRet .And. (lRet := oModelFw:VldData())

			If lRet := oModelFw:CommitData()
				nNewRecTS := oModelFw:GetModel("NUEMASTER"):GetDataID()

				If NUE->(Dbseek(xFilial('NUE') + cCodTS))
					RecLock("NUE", .F.) //Ajusta o timeSheet atual
					For nIdx := 1 To Len(aDataNUE)
						cCampo := aDataNUE[nIdx][1]
						NUE->(FieldPut(FieldPos(cCampo), aDataNUE[nIdx][2]))
					Next nIdx
					NUE->NUE_CUSERA := JurUsuario(__CUSERID)
					NUE->NUE_ALTDT  := Date()
					If lAltHr
						NUE->NUE_ALTHR := Time()
					EndIf
					NUE->(MsUnlock())
					NUE->(DbCommit())
				EndIf

				J170GRAVA("NUE", xFilial('NUE') + cCodTS, "4") //fila de sincronização.
				J144VlTsPf(cCodTS, cNumPreF) //Revaloriza o Time Sheet atual e ajusta na pre-fatura

			EndIf
		EndIf

		If !lRet
			JurShowErro(oModelFw:GetModel():GetErrorMessage())
			While __lSX8 //Libera os registros usados na transação
				RollBackSX8()
			EndDo
			DisarmTransaction()
			cNewCodTS := ".F."
		EndIf

		oModelFw:DeActivate()

		FreeObj( oModelFw )
		If lIsJ202
			oModelOld := Nil
		EndIf

	End Transaction

	If lRet
		aTsAtual := {cCodTS, cCliOrig, cLojOrig, cCasOrig, dDataTS, cNumPreF}
		aTsNovo  := {cNewCodTS, cCodCli, cCodLoj, cCodCas, dDataTS, cPreTsNew}
		J144MsgDiv(aTsAtual, aTsNovo) // Gera o log de divisão de TS
	EndIf

Else
	cNewCodTS := ".F."
EndIf

NX0->( RestArea(aAreaNX0) )
NUE->( RestArea(aAreaNUE) )

Return cNewCodTS

//-------------------------------------------------------------------
/*/{Protheus.doc} J144VlTsPf()
Rotina para revalorizar e ajustar os valores do TimeSheet na pré-fatura

@Param    cCodTs   Código do Time Sheet
@Param    cPreFat  Código da Pré-fatura

@Obs Somente utilizar a rotina em pré-fatura que for passivel de alteração

@author Luciano Pereira dos Santos
@since 28/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144VlTsPf(cCodTs, cPreFat)
Local lRet      := .T.
Local aConvLanc := {}
Local aAreaNUE  := NUE->(GetArea())
Local aPreFat   := JurGetDados("NX0", 1, xFilial("NX0") + cPreFat, {"NX0_CMOEDA", "NX0_DTEMI", "NX0_SITUAC"} )

NUE->(DbSetOrder(1))
If NUE->(DbSeek( xFilial("NUE") + cCodTs ) )

	JA144VALTS(cCodTs, .T., .F., .T. ) //Revaloriza no timesheet

	If !Empty(cPreFat)
		aConvLanc := JA201FConv(aPreFat[1], NUE->NUE_CMOEDA, NUE->NUE_VALOR, "2", aPreFat[2], "", cPreFat )
		RecLock("NUE", .F.)
		NUE->NUE_VALOR1 := aConvLanc[1] // Valor convertido
		NUE->NUE_COTAC1 := aConvLanc[2] // Cotação do lançamento
		NUE->NUE_COTAC2 := aConvLanc[3] // Cotação da pré
		NUE->NUE_COTAC  := JurCotac(aConvLanc[2], aConvLanc[3])
		NUE->NUE_CMOED1 := aPreFat[1]   // Moeda da pré
		NUE->(MsUnlock())
		NUE->(DbCommit())
		lRet := J144VincTs(cCodTS)
	EndIf

EndIf

RestArea(aAreaNUE)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144VincTs()
Rotina para ajustar o registro de historico do timeSheet em pré-fatura

@Param    cCodTS Codigo do TimeSheet

@Obs Somente utilizar a rotina em pré-fatura que for passivel de alteração

@author Luciano Pereira dos Santos
@since 28/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144VincTs(cCodTS)
Local lRet      := {}
Local aArea     := GetArea()
Local aAreaNUE  := NUE->(GetArea())
Local aCampos   := {}
Local aValores  := {}
Local nOperacao := 0

NUE->( dbSetOrder( 1 ) )
If NUE->(DbSeek( xFilial("NUE") + cCodTS ) )

	aCampos  := {"NW0_CTS", "NW0_PRECNF", "NW0_SITUAC", "NW0_CANC", "NW0_CODUSR",;
					"NW0_CCLIEN", "NW0_CLOJA", "NW0_CCASO", "NW0_CPART1", "NW0_TEMPOL",;
					"NW0_TEMPOR", "NW0_VALORH", "NW0_CMOEDA", "NW0_DATATS", "NW0_COTAC1" , "NW0_COTAC2"}

	aValores := {NUE->NUE_COD, NUE->NUE_CPREFT, "1", "2", __CUSERID,;
					NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO, NUE->NUE_CPART1, NUE->NUE_TEMPOL,;
					NUE->NUE_TEMPOR, NUE->NUE_VALORH, NUE->NUE_CMOEDA, NUE->NUE_DATATS, NUE->NUE_COTAC1, NUE->NUE_COTAC2}

	NW0->(dbSetOrder(1)) //NW0_FILIAL+NW0_CTS+NW0_SITUAC+NW0_PRECNF+NW0_CFATUR+NW0_CESCR+NW0_CWO
	If NW0->(dbSeek( xFilial( 'NW0' ) + NUE->NUE_COD + "1"+ NUE->NUE_CPREFT ))
		nOperacao := 4
	Else
		nOperacao := 3
	EndIf

	lRet := JurOperacao(nOperacao, "NW0", , , aCampos, aValores)

EndIf

RestArea(aAreaNUE)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144MsgDiv(aTsAtual, aTsNovo, lExibe)
Rotina para construir a mensagem de log da divisão do TimeSheet

@Param  aTsAtual Array com as informaçoes do TimeSheet atual
aTsAtual[1] - Codigo Ts
aTsAtual[2] - Cliente
aTsAtual[3] - Loja
aTsAtual[4] - Caso
aTsAtual[5] - Data Ts
aTsAtual[6] - Numero da Pré-fatura

@Param  aTsNovo  Array com as informaçoes do TimeSheet Novo
aTsNovo[1] - Codigo Ts
aTsNovo[2] - Cliente
aTsNovo[3] - Loja
aTsNovo[4] - Caso
aTsNovo[5] - Data Ts
aTsNovo[6] - Numero da Pré-fatura

@Param  lExibe  .T. Se exibe a dialog com a mesagem de Log

@Return cRet    Mensagem de texto com o Log

@author Luciano Pereira dos Santos
@since 28/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144MsgDiv(aTsAtual, aTsNovo, lExibe)
Local aArea      := GetArea()
Local aAreaNX0   := NX0->(GetArea())
Local cMsg       := ""
Local cMsglog    := ""
Local nI         := 0
Local aPreFat    := {}
Local lCalMsg    := (IsInCallStack('JURA144'))
Local aPreFatAlt := {}

Default lExibe   := .T.

//Time Sheet atual
If !Empty(aTsAtual[6])
	aPreFat := JA202VERPRE(aTsAtual[2], aTsAtual[3], aTsAtual[4], aTsAtual[5], 'TS')
	For nI := 1 To Len(aPreFat)
		If aPreFat[nI][1] == aTsAtual[6] //Só altera a pré-fatura que o lançamento esta vinculado
			aAdd(aPreFatAlt, aPreFat[nI])
			J144AltPre(aPreFat[nI][1], I18N(STR0143, {aTsAtual[1]}))
		EndIf
	Next nI

	If !IsJura202() .And. !Empty(cMsglog := JurLogLanc(aPreFatAlt, aTsAtual[6], 4, .T.))
		cMsg += I18N(STR0048, {aTsAtual[1]}) + CRLF //"- Time Sheet atual: #1"
		cMsg += cMsglog + Replicate('-', 85) + CRLF
	EndIf
EndIf

//Time Sheet Novo
If Empty(aTsNovo[6])
	aPreFat := JA202VERPRE(aTsNovo[2], aTsNovo[3], aTsNovo[4], aTsNovo[5], 'TS')
	For nI := 1 To Len(aPreFat)
		If aPreFat[nI][2] == '2'
			J144AltPre(aPreFat[nI][1], I18N(STR0144, {aTsNovo[1]}))
		EndIf
	Next nI
Else // O timesheet dividido já vinculado à pré-fatura, então altera somente a pré em que ele esta vinculado
	NX0->(DbsetOrder(1))
	If NX0->(dbSeek(xFilial('NX0') + aTsNovo[6] ))
		J144AltPre(aTsNovo[6], I18N(STR0144, {aTsNovo[1]})) // "Inclusão do Time Sheet '#1' após a emissão da pré-fatura."
	EndIf
	aPreFat := { {NX0->NX0_COD, NX0->NX0_SITUAC, .T.} }
EndIf

If !Empty(cMsglog := JurLogLanc(aPreFat, aTsNovo[6], 3, .T.)) .Or. lCalMsg
	cMsg += I18N(STR0082, {aTsNovo[1]}) + CRLF   //"- Time Sheet novo: #1"
	cMsg += cMsglog
	Iif(lExibe, JurErrLog(cMsg, STR0074), Nil)
EndIf

RestArea(aAreaNX0)
RestArea(aArea)

Return cMsg

//-------------------------------------------------------------------
/*/{Protheus.doc} J144AltPre()
Rotina de exibir janela de dialogo pra edição da descrição do time-sheet

@Param    cTxtOri descrição de origem
@Param    cTxtDes descrição de destino

@author Luciano Pereira dos Santos
@since  07/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144AltPre(cPreFat, cMsglog, lGravLog)
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaNX0   := NX0->(GetArea())
Local cPartLog   := JurUsuario(__CUSERID)

Default lGravLog := .T.

NX0->(DbsetOrder(1)) //NX0_FILIAL + NX0_COD + NX0_SITUAC
If NX0->(dbSeek(xFilial('NX0') + cPreFat))
	If NX0->NX0_SITUAC $ '2|3|D|E'
		RecLock('NX0', .F.)
		NX0->NX0_SITUAC := '3'
		NX0->NX0_USRALT := cPartLog
		NX0->NX0_DTALT  := date()
		NX0->(MsUnlock())
		NX0->(DbCommit())
		Iif(lGravLog, J202HIST('99', cPreFat, cPartLog, cMsglog), Nil)
	EndIf
EndIf

RestArea(aAreaNX0)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144TsTxt()
Rotina de exibir janela de dialogo pra edição da descrição do time-sheet

@Param    cTxtOri descrição de origem
@Param    cTxtDes descrição de destino

@author Luciano Pereira dos Santos
@since  28/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J144TsTxt(cTxtOri, cTxtDes)
Local oDlg      := Nil
Local oTSOrig   := Nil
Local oTSDest   := Nil
Local aRet      := {.F., cTxtOri, cTxtDes}
Local oLayer    := FWLayer():New()
Local bBntOk    := {||}

Default cTxtOri := ""
Default cTxtDes := cTxtOri

DEFINE MSDIALOG oDlg TITLE STR0076 FROM 000, 000 TO 400, 550 PIXEL // ###"Dividir TS com:"

oLayer:init(oDlg,.F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
oMainColl := oLayer:GetColPanel( 'MainColl' )

oTSOrig := TJurPnlCampo():New(005,006,125,150, oMainColl, STR0039, 'NUE_DESC', {|| },{|| }, cTxtOri, Nil, Nil ) //"TimeSheet atual"

oTSDest := TJurPnlCampo():New(005,142,125,150, oMainColl, STR0043, 'NUE_DESC', {|| },{|| }, cTxtDes, Nil, Nil ) //"TimeSheet novo"

bBntOk  := {|| (aRet := {.T., oTSOrig:GetValue(), oTSDest:GetValue()}, oDlg:End())}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bBntOk, {|| oDlg:End()},, /*aButtons*/,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144VldPart()
Rotina de validação e preenchimento do campo de Participante na tela de divisao de TS

@Param  cSiglaPar  Sigla do participante
@Param  dDataTS    Data do Time Sheet

@author Daniel Magalhaes
@since 28/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144VldPart(cSiglaPar, dDataTS)
Local lRet      := .T.

If !Empty(cSiglaPar)
	lRet := ExistCpo( 'RD0', cSiglaPar, 9) .And. JurGetDados('RD0', 9, xFilial('RD0') + cSiglaPar, 'RD0_TPJUR') == "1"

	If lRet
		dDtDemis := JurGetDados('RD0', 9, xFilial('RD0') + cSiglaPar, 'RD0_DTADEM')
		If !Empty(dDtDemis)
			If dDtDemis < dDataTS
				lRet := JurMsgErro(STR0110) //A data do lançamento é posterior a data de demissão do participante.
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144VLTRB()
Rotina de validação e preenchimento dos de valor lançado e revisado para o novo Time Sheet na tela de divisao de TS

@Param  cTipo       Tipo da Ação: 1= Validação pra valor lançado; / 2= Validação pra valor revisado
@Param  oGetValL   Objeto contendo o valor lançado do Time Sheet novo
@Param  oGetValAL  Objeto contendo o valor lançado do Time Sheet atual
@Param  oGetValR   Objeto contendo o valor revisado do Time Sheet novo
@Param  oGetValAR  Objeto contendo o valor revisado do Time Sheet atual
@Param  nMVJurTS2  Valor do parametro MV_JURTS2

@author Luciano Pereira dos Santos
@since 28/04/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA144VLTRB(cTipo, oGetValL, oGetValAL, oGetValR, oGetValAR, nMVJurTS2)
Local lRet      := .F.
Local nUTLAtual := 0
Local nUTLNovo  := 0
Local nUTRAtual := 0
Local nUTRNovo  := 0
Local cCampo    := ''
Local xValor    := Nil

Do Case // Validacao do campo 'Novo Valor'
Case cTipo == '1'
	nUTLAtual := Val(JURA144C1(nMVJurTS2, 1, cValToChar(oGetValAL:Valor) ))
	nUTLNovo  := Val(JURA144C1(nMVJurTS2, 1, cValToChar(oGetValL:Valor) ))

	lRet := nUTLAtual > nUTLNovo

	If lRet
		nUTRAtual := Val(JURA144C1(nMVJurTS2, 1, cValToChar(oGetValAR:Valor)))

		nUTRNovo := (nUTLNovo / nUTLAtual) * nUTRAtual
		xValor   := JURA144C1(1, nMVJurTS2, cValToChar(nUTRNovo) )

		Do Case
			Case nMVJurTS2 == 1
				xValor := Val(xValor)
			Case nMVJurTS2 == 2
				xValor := Val(xValor)
			Case nMVJurTS2 == 3
				xValor := Transform(xValor, Alltrim(X3Picture(oGetValR:GetNameField()) ) )
			Otherwise
				xValor := Val(xValor)
		EndCase

		oGetValR:Valor := xValor
		oGetValR:Refresh()
	Else
		cCampo := Alltrim(RetTitle(oGetValL:GetNameField()))
		JurMsgErro(I18N(STR0130, {cCampo}), , STR0080) //#"O valor de '#1' do novo Time Sheet é maior que o valor atual." ## "Informe um valor menor que o do Time Sheet atual."
	EndIf

Case cTipo == '2' // Validacao do campo Valor Revisado
	nUTRAtual := Val(JURA144C1(nMVJurTS2, 1, cValToChar(oGetValAR:Valor)) )
	nUTRNovo  := Val(JURA144C1(nMVJurTS2, 1, cValToChar(oGetValR:Valor)) )

	lRet := nUTRAtual > nUTRNovo

	If !lRet
		cCampo := Alltrim(RetTitle(oGetValR:GetNameField()))
		JurMsgErro(I18N(STR0130, {cCampo}), , STR0080) //#"O valor de '#1' do novo Time Sheet é maior que o valor atual." ## "Informe um valor menor que o do Time Sheet atual."
	EndIf

EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144VTAEB()
Filtro de tarefa de e-billing

@Param    cDoc   	Número do documento
@Param    cFaseTaf  Código da fase relacionada a tarefa
@Param    cFaseLf   parametro usado para a Dlg de Lotes de TS

@author Juliana Iwayama Velho
@since 25/05/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144VTAEB(cDoc, cFaseTaf, cCliente, cLoja, cFaseLt)
Local lRet  := .T.
Local cFase := ""

If Empty(cFaseLt)
	cFase := FwFldGet('NUE_CFASE')
Else
	cFase := cFaseLt
EndIf

lRet := cDoc == JAEMPEBILL(cCliente, cLoja)

If lRet
	NRY->( dbSetOrder( 1 ) )
	NRY->( dbSeek( xFilial('NRY') + cDoc ) )

	While !NRY->( EOF() ) .And. NRY->NRY_CDOC == cDoc
		If AllTrim(NRY->NRY_CFASE) == AllTrim(cFase) .And. AllTrim(NRY->NRY_COD) == cFaseTaf
			lRet := .T.
			Exit
		Else
			lRet := .F.
		EndIf
		NRY->( dbSkip() )
	EndDo
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144Lote(cOption)
Filtro para as consultas padrão NRZ e NRY para lançamentos em lote.

@param 	cOption   "1" - Fase, "2" - farefa
@Return cRet      Comando para filtro

@author Lucino Pereria dos Santos
@since 09/09/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144LDS(cOption)
Local cRet := "@#@#"

If cOption == "1" //Fase Ebilling
	If IsInCallStack('JURA144') .Or. IsInCallStack('JA145DLG')
		cRet := "@#NRY->NRY_CDOC == '" + JAEMPEBILL(cCliOr, cLojaOr) + "'@#"
	EndIf

ElseIf cOption == "2" //Tarefa Ebilling
	If IsInCallStack('JURA144') .Or. IsInCallStack('JA145DLG')
		cRet := JA144VTAEB(NRZ->NRZ_CDOC, NRZ->NRZ_CFASE, cCliOr, cLojaOr, cFase)
	EndIf

ElseIf cOption == "3" //Atividade Ebilling
	If IsInCallStack('JURA144') .Or. IsInCallStack('JA145DLG')
		cRet := "@#NS0->NS0_CDOC == '" + JAEMPEBILL(cCliOr, cLojaOr) + "'@#"
	EndIf

EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144Ebil()
Rotina para verificar se é necessario preencher as informaçoes de E-billing para o
TimeSheet Destino.

@param  cCliOrig   Cliente de Origem
@param  cLojOrig   Loja de Origem
@param  cCliDest   Cliente de Destino
@param  cLojDest   Loja de Destino
@param  cTSCod     Não usado
@param  lMesmoDoc  Somente retorno por referencia, .T. se for o mesmo documento de origem e destino.

@author Jorge Luis Branco Martins Junior
@since 01/03/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144Ebil(cCliOrig, cLojOrig, cCliDest, cLojDest, cTSCod, lMesmoDoc)
Local lRet   := .F.
Local cDocO  := ''
Local cDocD  := ''
Local cEmpO  := ''
Local cEmpD  := ''

ParamType 4 Var cTSCod As Character Optional Default ''

If !Empty(cEmpO := JurGetDados('NUH', 1, xFilial('NUH') + cCliOrig + cLojOrig, 'NUH_CEMP'))
	cDocO := JurGetDados("NRX", 1, xFilial("NRX") + cEmpO, "NRX_CDOC")
EndIf

If !Empty(cEmpD := JurGetDados('NUH', 1, xFilial('NUH') + cCliDest + cLojDest, 'NUH_CEMP'))
	cDocD := JurGetDados("NRX", 1, xFilial("NRX") + cEmpD, "NRX_CDOC")
EndIf

If (cDocO != cDocD .And. !Empty(cDocO) .And. !Empty(cDocD) ) .Or. (Empty(cDocO) .And. !Empty(cDocD))
	lRet := .T.
EndIf

lMesmoDoc := (cDocO == cDocD .And. !Empty(cDocD))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144VlDTS()
Função para o Validar a Data do Time Sheet na pré-fatura.

@author Luciano Pereira dos Santos
@since 02/03/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function J144VlDTS()
Local lRet       := .T.
Local oModel     := Iif( oModelOld == Nil, FWModelActive(), oModelOld)
Local cAnoMes    := " "
Local dDataTs    := CToD( '  /  /  ' )
Local dDtIniTs   := CToD( '  /  /  ' )
Local dDtFimTs   := CToD( '  /  /  ' )
Local dDtFixIni  := CToD( '  /  /  ' )
Local dDtFixFim  := CToD( '  /  /  ' )
Local dDtRefIni  := CToD( '  /  /  ' )
Local dDtRefFim  := CToD( '  /  /  ' )
Local aArea      := GetArea()
Local aAreaNX0   := NX0->(GetArea())
Local aDataVig   := {}
Local cIdNUE     := ""
Local cCaso      := ""
Local cClien     := ""
Local cLoja      := ""
Local cCodPre    := ""
Local dVigIniCtr := CToD( '  /  /  ' )
Local dVigFimCtr := CToD( '  /  /  ' )
Local lFixo      := .F.
Local nOpc       := 0
Local cCodTS     := ""

If oModel:GetId() $ "JURA144|JURA144DIV"
	cIdNUE := "NUEMASTER"
ElseIf oModel:GetId() == "JURA202"
	cIdNUE := "NUEDETAIL"
EndIf

If !Empty(cIdNUE)

	dDataTs := oModel:GetValue(cIdNUE, "NUE_DATATS")
	cAnoMes := JSToFormat(DToS(dDataTs), 'YYYYMM')
	cClien  := oModel:GetValue(cIDNUE, 'NUE_CCLIEN')
	cLoja   := oModel:GetValue(cIDNUE, 'NUE_CLOJA' )
	cCaso   := oModel:GetValue(cIDNUE, 'NUE_CCASO' )
	cCodTS  := oModel:GetValue(cIDNUE, 'NUE_COD' )
	cCodPre := oModel:GetValue(cIdNUE, "NUE_CPREFT")	
	nOpc    := oModel:GetOperation()
		
	If !Empty(cCodPre)
		If cIdNUE == "NUEMASTER"
			DbSelectArea("NX0")
			DbSetOrder(1) //
			If DbSeek(xFilial("NX0") + oModel:GetValue(cIdNUE, "NUE_CPREFT"))
				dDtIniTs := NX0->NX0_DINITS
				dDtFimTs := NX0->NX0_DFIMTS
			EndIf
		Else
			dDtIniTs := oModel:GetValue("NX0MASTER", "NX0_DINITS")
			dDtFimTs := oModel:GetValue("NX0MASTER", "NX0_DFIMTS")
		EndIf

		aDtFixo := J144GetDtFx(cCodPre)
		If Len(aDtFixo) > 1 .And. !Empty(dDtIniTs) .And. !Empty(dDtFimTs)
			lFixo     := .T.
			dDtFixIni := aDtFixo[1][1]
			dDtFixFim := aDtFixo[1][2]
			IIf(dDtFixIni < dDtIniTs, dDtRefIni := dDtIniTs, dDtRefIni := dDtFixIni)
			IIf(dDtFixFim > dDtFimTs, dDtRefFim := dDtFimTs, dDtRefFim := dDtFixFim)
		Else
			dDtRefIni := dDtIniTs
			dDtRefFim := dDtFimTs
		EndIf

		If !Empty(dDtRefIni) .And. !Empty(dDtRefFim)
			If (dDataTs < dDtRefIni) .Or. (dDataTs > dDtRefFim)
				lRet := JurMsgErro(I18N(STR0092, {cCodPre}),, STR0093) //"Lançamento vinculado a pré-fatura: #1. A data esta fora do período de emissão da Pré-Fatura!" ## "Retire o Time Sheet da pré-fatura e altere sua data na tela de Time Sheets."
			Else
				Iif(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_ANOMES", cAnoMes ), )
				If !lRet
					JurMsgErro(STR0094 + RetTitle("NUE_ANOMES") ) //## "Não foi possível alterar o campo "
				EndIf
			EndIf
		Else
			Iif(lRet, lRet := oModel:LoadValue( cIdNUE, "NUE_ANOMES", cAnoMes ), )
			If !lRet
				JurMsgErro(STR0094 + RetTitle("NUE_ANOMES") ) //"Não foi possivel alterar o campo "
			EndIf

			If lRet
				lRet := J144PreVal(oModel)
			EndIf
		EndIf
		If IsJura202()
			//Valida  a existência de Fatura Adicional faturada cujo período de referência englobe a data do Lançamento
			If lRet .And. FindFunction("JurBlqLnc")
				lRet := JurBlqLnc( cClien, cLoja, cCaso, dDataTs, "TS" )
			EndIf
		EndIf
	EndIf

	If lRet .And. nOpc <> MODEL_OPERATION_INSERT
		aDataVig := J144GetVig(cCodPre, cClien, cLoja, cCaso, cCodTS)
		If Len(aDataVig) > 0
			dVigIniCtr := StoD(aDataVig[1][1])
			dVigFimCtr := StoD(aDataVig[1][2])
		EndIf
		If !Empty(dVigIniCtr) .And. !Empty(dVigFimCtr) .And. (dDataTs < dVigIniCtr .Or. dDataTs > dVigFimCtr)
			lRet := JurMsgErro(STR0162, , STR0093) //"A data esta fora do período de vigência do contrato!" ### "Retire o Time Sheet da pré-fatura e altere sua data na tela de Time Sheets."
		EndIf
	EndIf
EndIf

RestArea(aAreaNX0)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144GetDtFx
Retorna o período do lançamento fixo com base no código da pré-fatura
vinculado ao timesheet.

@param cCodPre  - Código da pré-fatura

@return aDtFixo - Data inicial e final do lançamento fixo

@author Abner Fogaca
@since 14/05/2021
/*/
//-------------------------------------------------------------------
Static Function J144GetDtFx(cCodPre)
Local aArea   := GetArea()
Local aDtFixo := {}
Local cQry    := GetNextAlias()

	BeginSQL Alias cQry
		%NoParser%
		SELECT NT1.NT1_DATAIN, NT1.NT1_DATAFI
		  FROM %Table:NX8% NX8, %Table:NT1% NT1
		 WHERE NX8.NX8_FILIAL = %xFilial:NX8%
		   AND NX8.NX8_FIXO = '1'
		   AND NX8.NX8_CPREFT = %Exp:cCodPre%
		   AND NX8.%NotDel%
		   AND NT1.NT1_FILIAL = NX8.NX8_FILIAL
		   AND NT1.NT1_CCONTR = NX8.NX8_CCONTR
		   AND NT1.NT1_CPREFT = NX8.NX8_CPREFT
		   AND NT1.%NotDel%
	EndSQL

	If (cQry)->(!EOF())
		Aadd(aDtFixo, {SToD((cQry)->NT1_DATAIN), SToD((cQry)->NT1_DATAFI)})
	EndIf

	(cQry)->(DbCloseArea())
	RestArea(aArea)

Return aDtFixo

//-------------------------------------------------------------------
/*/{Protheus.doc}  J144GetVig()
Retorna a maior data de vigência dos contratos na pré-fatura

@param cPrefat  Código da pré-fatura
@param cCliente Código do cliente
@param cloja    Código da loja 
@param cCaso    Código do caso
@param cCodTS   Código do Time Sheet

@author Abner Fogaça de Oliveira
@since  08/06/2020
/*/
//-------------------------------------------------------------------
Static Function J144GetVig(cPreFat, cCliente, cLoja, cCaso, cCodTS)
Local cQuery   := ""
Local aDataVig := {}
Local cDataTS  := DToS(JurGetDados("NUE", 1, xFilial("NUE") + cCodTS, "NUE_DATATS"))

cQuery := " SELECT NX8.NX8_DTVIGI, NX8.NX8_DTVIGF "
cQuery +=   " FROM " + RetSqlName("NX8") + " NX8" 
cQuery +=  " INNER JOIN " + RetSqlName("NX1") + " NX1"
cQuery +=     " ON NX1.NX1_FILIAL = '" + xFilial("NX1") + "'"
cQuery +=    " AND NX1.NX1_CPREFT = NX8.NX8_CPREFT"
cQuery +=    " AND NX1.NX1_CCLIEN = NX8.NX8_CCLIEN"
cQuery +=    " AND NX1.NX1_CLOJA  = NX8.NX8_CLOJA "
cQuery +=    " AND NX1.NX1_CCONTR = NX8.NX8_CCONTR"
cQuery +=    " AND NX1.NX1_CCASO  = '" + cCaso + "'"
cQuery +=    " AND NX1.D_E_L_E_T_ = ' '"
cQuery +=  " INNER JOIN " + RetSqlName("NX0") + " NX0"
cQuery +=     " ON NX0.NX0_FILIAL = '" + xFilial("NX0") + "'"
cQuery +=    " AND NX0.NX0_COD = NX8.NX8_CPREFT"
cQuery +=    " AND NX0.NX0_SITUAC IN ('2','3','C')"
cQuery +=    " AND NX0.D_E_L_E_T_ = ' '"
cQuery +=  " WHERE NX8.NX8_FILIAL = '" + xFilial("NX8") + "'" 
cQuery +=    " AND NX8.NX8_CPREFT = '" + cPreFat  + "'"
cQuery +=    " AND NX8.NX8_CCLIEN = '" + cCliente + "'"
cQuery +=    " AND NX8.NX8_CLOJA  = '" + cLoja    + "'"
cQuery +=    " AND NX8.NX8_DTVIGI <= '" + cDataTS + "'"
cQuery +=    " AND NX8.NX8_DTVIGF >= '" + cDataTS + "'"
cQuery +=    " AND NX8.D_E_L_E_T_ = ' '"

aDataVig := JurSQL(cQuery, "*")

Return aDataVig

//-------------------------------------------------------------------
/*/{Protheus.doc}  J144AtvNC()
Função para retornar se a atividade é cobrável ou não no contrato por
hora vinculado ao caso.

@author Jacques Alves Xavier
@since 08/03/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function J144AtvNC(cCliente, cLoja, cCaso, cAtiv, lFxNC)
Local cSQL      := ""
Local aAtv      := {}
Local cAtivNaoC := ""

Default lFxNC   := .F.

cSQL := " SELECT NTJ.NTJ_CTPATV NTJ_CTPATV "
cSQL += " FROM " + RetSqlName("NUT") + " NUT, "
cSQL +=      " " + RetSqlName("NT0") + " NT0, "
cSQL +=      " " + RetSqlName("NRA") + " NRA, "
cSQL +=      " " + RetSqlName("NTJ") + " NTJ "
cSQL += " WHERE NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
cSQL +=   " AND NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
cSQL +=   " AND NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
cSQL +=   " AND NTJ.NTJ_FILIAL = '" + xFilial("NTJ") + "' "
cSQL +=   " AND NUT.NUT_CCONTR = NT0.NT0_COD "
cSQL +=   " AND NT0.NT0_CTPHON = NRA.NRA_COD "
cSQL +=   " AND NUT.NUT_CCONTR = NTJ.NTJ_CCONTR "
cSQL +=   " AND NUT.NUT_CCLIEN = '" + cCliente + "' "
cSQL +=   " AND NUT.NUT_CLOJA = '" + cLoja + "' "
cSQL +=   " AND NUT.NUT_CCASO = '" + cCaso + "' "
If lFxNC // Se for pré de TS de contrato fixo ou não cobrável
	cSQL +=   " AND (NRA.NRA_NCOBRA = '1' OR (NRA.NRA_COBRAH = '2' AND NRA.NRA_COBRAF = '1')) "
Else
	cSQL +=   " AND NRA.NRA_COBRAH = '1' "
EndIf
cSQL +=   " AND NTJ.NTJ_CTPATV = '" + cAtiv + "' "
cSQL +=   " AND NUT.D_E_L_E_T_ = ' ' "
cSQL +=   " AND NT0.D_E_L_E_T_ = ' ' "
cSQL +=   " AND NRA.D_E_L_E_T_ = ' ' "
cSQL +=   " AND NTJ.D_E_L_E_T_ = ' ' "

aAtv := JurSQL(cSQL, {"NTJ_CTPATV"})

If Empty(aAtv)
	cAtivNaoC := "1"
Else
	cAtivNaoC := "2"
EndIf

Return cAtivNaoC

//-------------------------------------------------------------------
/*/{Protheus.doc}  J202TemCs()
Rotina para verificar se o cliente loja caso ao qual o time sheet será
transferido esta contido na pré-fatura.

@author Luciano Pereira dos Santos
@since 20/03/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144TemCs(cCodPre, cCliente, cLoja, cCaso)
Local lRet      := .F.
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local nQtde     := 0

cQuery := " SELECT COUNT(NX1.R_E_C_N_O_) QTDE "
cQuery += " FROM " + RetSqlName("NX1") + " NX1 "
cQuery += " WHERE NX1.NX1_FILIAL = '" + xFilial("NX1") + "' "
cQuery +=   " AND NX1.NX1_CPREFT = '" + cCodPre + "' "
cQuery +=   " AND NX1.NX1_CCASO  = '" + cCaso + "' "
cQuery +=   " AND NX1.NX1_CCLIEN = '" + cCliente + "' "
cQuery +=   " AND NX1.NX1_CLOJA  = '" + cLoja + "' "
cQuery +=   " AND NX1.D_E_L_E_T_ = ' ' "

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry, .T., .F. )

If !(cAliasQry)->(Eof())
	nQtde := (cAliasQry)->QTDE
EndIf

(cAliasQry)->(DbCloseArea())

If nQtde > 0
	lRet := .T.
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  J144VlTAB()
Rotina para verificar se o lançamento tabelado esta vinculado em alguma
outra pré-fatura, caso esteja solicita a ação do usuario quanto a
transferencia do lançaamento para a pré-fatura do TimeSheet.
Obs: Usar somente com as validações da rotina JA144VERPRE

@params	cLancTab código do lançamento a ser verificado
@params	cPreTs 	 código da pré-fatura do time sheet

@author Luciano Pereira dos Santos
@since 16/04/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144VlTAB(cLancTab, cPrefat)
Local cRet      := ""
Local aArea     := GetArea()
Local aAreaNX0  := NX0->(GetArea())
Local cPreTab   := JurGetDados("NV4", 1, xFilial("NV4") + cLancTab, "NV4_CPREFT")
Local lAlterada := .F.
Local cPartLog  := JurUsuario(__CUSERID)

NX0->(DbSetOrder(1)) //NX0_FILIAL+NX0_COD
If NX0->(dbSeek(xFilial('NX0') + cPreTab)) .And. !Empty(cLancTab)
	If NX0->NX0_SITUAC $ '2|3|D|E'
		lAlterada := NX0->NX0_SITUAC == '3' // Pré-Fatura já alterada
		If cPreTab != cPrefat
			If ApMsgYesNo(STR0096 + cPreTab + STR0097 + cPrefat + "." + CRLF + STR0098 )  //"O Lançamento Tabelado será transferido da pré-fatura "+ cPreTab ### + "para a pré-fatura "+cPrefat+ ### "Confirma a transferência?"

				Begin TransAction
				cRet := J144MVTAB(cLancTab, cPreTab, cPrefat )

				If Empty(cRet)
					If JurLancPre( cPreTab ) <= 1  // Verifica se era o último lançamento da pré para cancelar
						JA202CANPF(NX0->NX0_COD)
						J202HIST('5', cPreTab, cPartLog) //Insere o Histórico na pré-fatura
					Else
						J144AltPre(NX0->NX0_COD, I18N(STR0142, {cLancTab}), !lAlterada) // "Atualização no Lançamento Tabelado '#1'."
					EndIf
				EndIf

				End Transaction

			Else
				cRet := (STR0101) //"Operação cancelada pelo usuário!"
			EndIf
		Else // se é a mesma pré-fatura altera o status direto

			J144AltPre(NX0->NX0_COD, I18N(STR0142, {cLancTab}), !lAlterada) // "Atualização no Lançamento Tabelado '#1'."

		EndIf
	Else
		cRet := (STR0099 + cPreTab + ".")
	EndIf
Else
	// se o tabelado não estiver vinculado a outra pré-fatura, vincula direto na pré do TS
	cRet := J144MVTAB(cLancTab, cPreTab, cPrefat )
EndIf

RestArea(aArea)
RestArea(aAreaNX0)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  J144MVTAB()
Rotina para mover o lançamento tabelado para a pré-fatura do Time Sheet
Obs: Usar somente com as validações da rotina J144VlTAB e
JA144VERPRE

@param  cLancTab  código do lançamento a ser movido
@param  cPreTs    código da pré-fatura do time sheet
@param  cPreTab   código do pré-fatura do Tabelado

@author Luciano Pereira dos Santos
@since 16/04/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144MVTAB(cLancTab, cPreTab, cPreTs )
Local cRet     := ""
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaNW4 := NW4->(GetArea())
Local aAreaNV4 := NV4->(GetArea())

//Inclui o Tabelado na Pré-fatura do TimeSheet
NV4->(dbSetOrder(1)) //NV4_FILIAL+NV4_COD
If NV4->(dbSeek(xFilial('NV4') + cLancTab))
	RecLock("NV4", .F.)
	NV4->NV4_CPREFT := cPreTs
	NV4->(msUnlock())
	NV4->(DbCommit())
	//Grava na fila de sincronização
	J170GRAVA("NV4", xFilial("NV4") + cLancTab, "4")
Else
	lRet  := .F.
EndIf

//Remove o vinculo da Pré-fatura antiga
If lRet .And. !Empty(cPreTab)
	NW4->(dbSetOrder(4)) //NW4_FILIAL+NW4_CLTAB+NW4_SITUAC+NW4_PRECNF
	If (NW4->( dbSeek( xFilial( 'NW4' ) + cLancTab + "1" + cPreTab ) ))
		RecLock("NW4", .F.)
		NW4->NW4_CANC   := "1"
		NW4->NW4_CODUSR := __cUserID
		NW4->(MsUnlock())
		NW4->(DbCommit())
		//Grava na fila de sincronização
		J170GRAVA("NV4", xFilial("NV4") + cLancTab, "4")
	EndIf
EndIf

//Cria o novo vinculo com a Pré-fatura do Time Sheet
If lRet .And. !Empty(cPreTs)
	NW4->(dbSetOrder(4)) //NW4_FILIAL+NW4_CLTAB+NW4_SITUAC+NW4_PRECNF
	If !(NW4->( dbSeek( xFilial( 'NW4' ) + cLancTab + "1" + cPreTs ) ))
		RecLock("NW4", .T.)
		NW4->NW4_FILIAL := xFilial("NW4")
		NW4->NW4_CLTAB  := cLancTab
		NW4->NW4_SITUAC := "1"
		NW4->NW4_PRECNF := cPreTs
		NW4->NW4_CANC   := "2"
		NW4->NW4_CODUSR := __cUserID
		NW4->(MsUnlock())
		NW4->(DbCommit())
	Else
		RecLock("NW4", .F.)
		NW4->NW4_CANC   := "2"
		NW4->NW4_CODUSR := __cUserID
		NW4->(MsUnlock())
		NW4->(DbCommit())
	EndIf
EndIf

If !lRet
	cRet := (STR0100 + cPreTs + "!")
EndIf

RestArea(aAreaNV4)
RestArea(aAreaNW4)
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc}JCall145()
Função chamar a rotina JURA145 sem carregar as configurações de botão do XNU.

@author Luciano Pereira dos Santos
@since 21/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall145()
Local cAceAnt  := AcBrowse
Local cFunName := FunName()

// JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA144 inserida no XNU.
AcBrowse := Replicate("x", 10)
SetFunName( 'JURA145' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA145

JURA145()

SetFunName( cFunName )
AcBrowse := cAceAnt

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}  JLimpa()
Função utilizada nos gatilhos para limpar os campos de valor e moeda

@author Jacques Alves Xavier
@since 19/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JLimpa()
Local oModel := FwModelActive()
Local cRet   := ""
Local cIDNue := IIf( IsJura202() .And. !IsInCallStack("JA145ALT2") .And. !IsInCallStack("J202DivTs"), "NUEDETAIL", "NUEMASTER" )

oModel:ClearField(cIDNue, "NUE_CMOEDA")
oModel:ClearField(cIDNue, "NUE_DMOEDA")
oModel:ClearField(cIDNue, "NUE_VALORH")
oModel:ClearField(cIDNue, "NUE_VALOR")
oModel:ClearField(cIDNue, "NUE_CCATEG")

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  JCalcTempo()
Função utilizada no campo de valor do TS para calcular os tempos do TS

@author Jacques Alves Xavier
@since 20/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCalcTempo()
Local lRet       := .T.
Local oModel     := FwModelActive()
Local cIDNue     := IIf( IsJura202() .And. !IsInCallStack("JA145ALT2") .And. !IsInCallStack("J202DivTs"), "NUEDETAIL", "NUEMASTER" )
Local cIDNueZera := ""
Local nNUEVALOR  := oModel:GetValue(cIDNue, "NUE_VALOR")
Local nNUEVALORH := oModel:GetValue(cIDNue, "NUE_VALORH")
Local nUTTSNova  := 0
Local nHoraFrac  := 0
Local cHora      := 0
Local nDecimal   := 0
Local nInteiro   := 0
Local nJURTS1    := SuperGetMV( 'MV_JURTS1',, 10  ) // Minutos da UT
Local lPodeFrac  := SuperGetMV( 'MV_JURTS3',, .F. )  // Indica se as uts ou o tempo pode ser possuir frações da unidade de tempo
Local lZera      := SuperGetMV( 'MV_JURTS4',, .F. )  // Zera o tempo revisado de atividades nao cobraveis
Local cAtivNaoC  := "1"
Local cCliente   := ""
Local cLoja      := ""
Local cCaso      := ""
Local cHsMinZr   := "" // Tamanho e mascara do campo HH:mm

If nNUEVALOR < 0
	lRet := JurMsgErro(STR0088) // "Informe um valor positivo!"
EndIf

If lRet
	If nNUEVALORH == 0 .Or. nJURTS1 == 0 .Or. nNUEVALOR == 0
		nHoraFrac := 0
	Else
		nHoraFrac := (nNUEVALOR / nNUEVALORH)
	EndIf

	nUTTSNova := Val( JURA144C1(2, 1, Str(nHoraFrac)) )
	cHora     :=      JURA144C1(2, 3, Str(nHoraFrac))

	nInteiro  := Int( nUTTSNova )
	nDecimal  := nUTTSNova - Int( nUTTSNova )

	If nDecimal <> 0 .And. !lPodeFrac

		nUTTSNova := Val( JURA144C1(1, 1, Str(Round(nUTTSNova, 0)) ) )
		nHoraFrac := Val( JURA144C1(1, 2, Str(Round(nUTTSNova, 0)) ) )
		cHora     :=      JURA144C1(1, 3, Str(Round(nUTTSNova, 0)) )

	EndIf

	lRet := lRet .And. JurLoadValue( oModel, cIDNue, "NUE_HORAR" , cHora                                                  )
	lRet := lRet .And. JurLoadValue( oModel, cIDNue, "NUE_UTR"   , Round( nUTTSNova             , TamSX3('NUE_UTR')[2] )  )
	lRet := lRet .And. JurLoadValue( oModel, cIDNue, "NUE_TEMPOR", Round( nHoraFrac             , TamSX3('NUE_TEMPOR')[2]))
	lRet := lRet .And. JurLoadValue( oModel, cIDNue, "NUE_VALOR" , Round( nHoraFrac * nNUEVALORH, TamSX3('NUE_VALOR')[2]) )

EndIf

If lZera
	oModel     := If( oModelOld == Nil, FWModelActive(), oModelOld)

	cIDNueZera := If( oModelOld == Nil, cIDNue, "NUEDETAIL" )

	cCliente  := oModel:GetValue( cIDNueZera, "NUE_CCLIEN") // cliente da validação NX0_ALTPER $ '2,3'
	cLoja     := oModel:GetValue( cIDNueZera, "NUE_CLOJA" ) // loja da validaçao NX0_ALTPER $ '2,3'
	cCaso     := oModel:GetValue( cIDNueZera, "NUE_CCASO" ) // Caso da validaçao NX0_ALTPER $ '2,3'
	cHsMinZr  := Transform(PADL("0", TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR"))

	cAtivNaoC := JurGetDados("NRC", 1, xFilial("NRC") + oModel:GetValue( cIDNueZera, "NUE_CATIVI"), "NRC_TEMPOZ")

	If cAtivNaoC == "2"
		// <- Zera os valores dos campos conforme o parametro MV_JURTS4 ->

		//<- UT Revisada ->
		IIF(lRet, lRet := oModel:LoadValue( cIDNueZera, "NUE_UTR", 0 ), ) // 0
		//<- HH:MM Rev ->
		IIF(lRet, lRet := oModel:LoadValue( cIDNueZera, "NUE_HORAR", cHsMinZr ), ) // 00:00
		//<- Hora F Rev ->
		IIF(lRet, lRet := oModel:LoadValue( cIDNueZera, "NUE_TEMPOR", 0 ), ) // 0
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144PreVal
Pré-Validação do Modelo de dados JURA144.

@param oMoldel objeto do modelo de dados do fonte JURA144.
@return .T./.F. Verdadeiro ou Falso.

@author Julio de Paula Paz
@since 16/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J144PreVal(oModel)
Local lRet            := .T.
Local aRetBlqTS       := {}
Local dDtTimeSh
Local lLiberaTudo
Local llibInclusao
Local lLibAlteracao
Local lLibExclusao
Local lLibParam       := .T.  //Se MV_JCORTE preenchido corretamente

Begin Sequence
Do Case
	Case oModel:GetOperation() == 3 // Inclusão
		dDtTimeSh     := oModel:GetValue("NUEMASTER", "NUE_DATATS")
		aRetBlqTS     := JBlqTSheet(dDtTimeSh)
		lLiberaTudo   := aRetBlqTS[1]
		llibInclusao  := aRetBlqTS[2]
		lLibParam     := aRetBlqTS[5]

		If lLiberaTudo
			lRet := .T.
		Else
			lRet := llibInclusao
		EndIf

		If ! lRet .And. lLibParam
			JurMsgErro(STR0119,, STR0145)  // "Você não tem permissão para realizar a operação de inclusão!" ### "Verifique seus acessos quanto ao corte de Time Sheets."
		EndIf

	Case oModel:GetOperation() == 4 // Alteração
		dDtTimeSh     := NUE->NUE_DATATS
		aRetBlqTS     := JBlqTSheet(dDtTimeSh)
		lLiberaTudo   := aRetBlqTS[1]
		lLibAlteracao := aRetBlqTS[3]
		lLibParam     := aRetBlqTS[5]

		If lLiberaTudo
			lRet := .T.
		Else
			lRet := lLibAlteracao
		EndIf

		If ! lRet .And. lLibParam
			JurMsgErro(STR0120,, STR0145) // "Você não tem permissão para realizar a operação de alteração!" ### "Verifique seus acessos quanto ao corte de Time Sheets."
		EndIf

	Case oModel:GetOperation() == 5 // Exclusão
		dDtTimeSh    := NUE->NUE_DATATS
		aRetBlqTS    := JBlqTSheet(dDtTimeSh)
		lLiberaTudo  := aRetBlqTS[1]
		lLibExclusao := aRetBlqTS[4]
		lLibParam    := aRetBlqTS[5]

		If lLiberaTudo
			lRet := .T.
		Else
			lRet := lLibExclusao
		EndIf

		If ! lRet .And. lLibParam
			JurMsgErro(STR0121,, STR0145)  // "Você não tem permissão para realizar a operação de exclusão!" ### "Verifique seus acessos quanto ao corte de Time Sheets."
		EndIf
EndCase

End Sequence

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144VldCli
Validação dos campos: Grupo, Cliente e Loja

@Return   lRet  .T. ou .F.

@author Bruno Ritter
@since 23/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J144VldCli()
Local lRet    := .T.
Local oModel  := FWModelActive()
Local cIDNUE  := IIf( oModel:GetId() == 'JURA202', "NUEDETAIL", "NUEMASTER" )
Local cGrupo  := ''
Local cClien  := ''
Local cLoja   := ''
Local cCaso   := ''
Local cCampo  := AllTrim(__ReadVar)
Local dDataLC := CToD( '  /  /  ' )

	cGrupo  := oModel:GetValue(cIDNUE, "NUE_CGRPCL")
	dDataLC := oModel:GetValue(cIDNUE, 'NUE_DATATS')

	If (cCampo == "M->NUE_CCLIEN") .Or. (cCampo == "M->NUE_CLOJA") .Or. (cCampo == "M->NUE_CCASO") .Or. (cCampo == "M->NUE_DATATS")
		cClien  := oModel:GetValue(cIDNUE, "NUE_CCLIEN")
		cLoja   := oModel:GetValue(cIDNUE, "NUE_CLOJA")
		cCaso   := oModel:GetValue(cIDNUE, "NUE_CCASO")
	Else
		cClien  := oModel:GetValue(cIDNUE, "NUE_CCLILD")
		cLoja   := oModel:GetValue(cIDNUE, "NUE_CLJLD")
		cCaso   := oModel:GetValue(cIDNUE, "NUE_CCSLD")
	EndIf

	If (cCampo == "M->NUE_CGRPCL")
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "GRP")

	ElseIf (cCampo == "M->NUE_CCLIEN") .Or. (cCampo == "M->NUE_CCLILD")
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "CLI")

	ElseIf (cCampo == "M->NUE_CLOJA") .Or. (cCampo == "M->NUE_CLJLD")
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "LOJ")

	ElseIf (cCampo == "M->NUE_CCASO") .Or. (cCampo == "M->NUE_CCSLD") .Or. (cCampo == "M->NUE_DATATS")
		lRet := JurVldCli(cGrupo, cClien, cLoja, cCaso, "NVE_LANTS", "CAS",,, dDataLC)

	EndIf

	//Valida  a existência de Fatura Adicional faturada cujo período de referência englobe a data do Lançamento
	If lRet .And. cCampo != "M->NUE_CGRPCL"
		lRet := JurBlqLnc( cClien, cLoja, cCaso, dDataLC, "TS" )
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144ClxCa()
Rotina para verificar se o cliente/loja pertece ao caso.
Utilizado para condição de gatilho

@Return - lRet  .T. quando o cliente PERTENCE ao caso informado OU
                .F. quando o cliente NÃO pertence ao caso informado

@author Bruno Ritter
@since 22/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J144ClxCa()
Local lRet     := .F.
Local oModel   := FWModelActive()
Local cClien   := ""
Local cLoja    := ""
Local cCaso    := ""
Local cIDNUE   := IIf( oModel:GetId() == 'JURA202', "NUEDETAIL", "NUEMASTER" )

cClien    := oModel:GetValue(cIDNUE, "NUE_CCLIEN")
cCaso     := oModel:GetValue(cIDNUE, "NUE_CCASO")
cLoja     := oModel:GetValue(cIDNUE, "NUE_CLOJA")

lRet := JurClxCa(cClien, cLoja, cCaso)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144ClxGr()
Rotina para verificar se o cliente/loja pertence ao grupo.
Usado nos gatilhos de Grupo

@Return - lRet  .T. quando o cliente PERTENCE ao grupo informado OU
                .F. quando o cliente NÃO pertence ao grupo informado

@author Bruno Ritter
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J144ClxGr()
Local lRet    := .T.
Local oModel  := FWModelActive()
Local cIDNUE  := IIf( oModel:GetId() == 'JURA202', "NUEDETAIL", "NUEMASTER" )
Local cGrupo  := ''
Local cClien  := ''
Local cLoja   := ''

	cGrupo  := oModel:GetValue(cIDNUE, "NUE_CGRPCL")
	cClien  := oModel:GetValue(cIDNUE, "NUE_CCLIEN")
	cLoja   := oModel:GetValue(cIDNUE, "NUE_CLOJA")

	lRet := JurClxGr(cClien, cLoja, cGrupo)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144GtlCas()
Rotina para executar algumas funções de preenchimento no gatilho do caso

@Return - NUE_CCASO

@author Bruno Ritter
@since 12/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J144GtlCas()
Local cRet      := FwFldGet("NUE_CCASO")
Local lAltLote  := IsInCallStack( 'JA145ALT2' )

	If !Empty(cRet)
		JA144VALTS(FwFldGet("NUE_COD"), .T., .T.)
	EndIf

	JURA144V1("UTR", lAltLote, .T.) // verifica se o tipo de atividade e nao cobravel e atualiza os valores do ts

	If(Empty(cRet))
		JLimpa()
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144REPLI
Botão para replicar as informações do contrato

@author Jorge Luis Branco Martins Junior
@since 07/03/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA144REPLI()
Local aArea     := GetArea()

If ApMsgYesNo(STR0133) //"Deseja replicar os dados principais deste time sheet?"
	FWExecView(STR0003, 'JURA144', 3,, {|| .T.})
EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144SGNUE
Rotina para sugerir as informações do time-sheet selecionado para a
replicação

@param  cCodTS   Código do Time Sheet
@param  oModel   Model a ser verificado

@author Jorge Luis Branco Martins Junior
@since 07/03/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA144SGNUE(cCodTS, oModel)
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaNUE  := NUE->(GetArea())
Local oModelNUE := oModel:GetModel('NUEMASTER')
Local aStruct   := {}
Local aNUE      := {}
Local nI        := 0

NUE->(dbSetOrder(1)) //NUE_FILIAL + NUE_COD
If NUE->( dbSeek( xFilial( 'NUE' ) + cCodTS ) )
	aStruct := J144Struct({'NUE_FILIAL','NUE_COD','NUE_VALOR1','NUE_DATAIN','NUE_HORAIN',;
	                       'NUE_ALTDT','NUE_CUSERA','NUE_VTSANT','NUE_COTAC1','NUE_COTAC2',;
	                       'NUE_CMOED1','NUE_CODPAI','NUE_CPREFT','NUE_TSDIV','NUE_SITUAC',;
	                       'NUE_ALTHR','NUE_CLTAB','NUE_CODLD','NUE_CREPRO','NUE_COTAC',;
	                       'NUE_CDWOLD','NUE_OBSWO','NUE_CMOTWO','NUE_PARTLD','NUE_ACAOLD',;
	                       'NUE_CCLILD','NUE_CLJLD','NUE_CCSLD','NUE_OK','NUE_REVISA',;
	                       'NUE_FLUREV','NUE_DTREPR','NUE_CRETIF'}) //Campos não replicáveis
	aNUE := J144GetDat(aStruct)
EndIf

For nI := 1 To Len( aNUE )
	If oModelNUE:CanSetValue(aNUE[nI][1])
		// Necessário fazer via LoadValue para que não fique recalculando os tempos
		If aNUE[nI][1] $ "NUE_UTP|NUE_HORAP|NUE_TEMPOP|NUE_UTL|NUE_HORAL|NUE_TEMPOL|NUE_UTR|NUE_HORAR|NUE_TEMPOR|NUE_VALOR"
			lRet := oModelNUE:LoadValue(aNUE[nI][1], aNUE[nI][2])
		Else
			lRet := oModelNUE:SetValue(aNUE[nI][1], aNUE[nI][2])
		EndIf
		If !lRet
			JurMsgErro( STR0134 + aNUE[nI][1] + STR0135 + AllToChar( aNUE[nI][2] ) ) // "Erro ao replicar time sheet: Campo = " / " - Conteúdo = "
			oModel:GetErrorMessage(.T.)
			Exit
		EndIf
	EndIf
Next nI

RestArea( aAreaNUE )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144Struct()
Rotina para retornar a estrutura da tabela NUE filtrada por um array de campos

@Param  aCampos  Array com campos adicionais para serem removidos Ex: ['NUE_FILIAL','NUE_COD']

@Return aRet     Array da estrutura da tabela com os campos removidos

@author Luciano Pereira dos Santos
@since 31/05/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144Struct(aCampos)
Local aRet      := {}
Local aStruct   := NUE->(DbStruct())
Local nI        := 0

Default aCampos := {}

For nI := 1 To Len(aStruct)
	If (Ascan(aCampos, {|aY| aY == aStruct[nI][1]}) == 0)
		aAdd(aRet, aStruct[nI])
	EndIf
Next nI

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144GetDat()
Recupera os dados de um registro posicionado, conforme os campos da estrutura.

@Param  aStruct          Array com a estrutura dos campos da tabela
         aStruct[n][1]   Campo da estrutura (Obrigatorio)

@Return  aData           Array multidimensional contendo contentdo os dados a serem gravados
          aData[n][1]    Nome do campo da linha
          aData[n][2]    Informação a ser gravada no campo

@author Luciano Pereira dos Santos
@since 01/06/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144GetDat(aStruct)
Local nCampo  := 0
Local cCampo  := ''
Local xValor  := Nil
Local aData   := {}
Local lTsZero := SuperGetMv("MV_JREPZER", .F., "1") == "1" // Indica se os Time Sheets criados por meio do botão "Replicar TS" deverão ter o tempo trabalhado zerado. (1-Sim; 2-Não)
Local nQtd    := Len(aStruct)

For nCampo := 1 To nQtd
	cCampo := AllTrim(aStruct[nCampo][1])

	Do Case
		Case cCampo $ 'NUE_CPART1|NUE_CPART2'
			xValor := JurGetDados('RD0', 1, xFilial('RD0') + NUE->(FieldGet(FieldPos(cCampo))), 'RD0_SIGLA') // No modelo devem ser gravados os campos virtuais de sigla
			cCampo := IIf(cCampo=='NUE_CPART1', 'NUE_SIGLA1', 'NUE_SIGLA2')

		Case cCampo $ 'NUE_UTL|NUE_HORAL|NUE_TEMPOL'
			If lTsZero
				xValor := Iif(aStruct[nCampo][2] == "N", 0, "00:00")
			Else
				xValor := NUE->(FieldGet(FieldPos(cCampo)))
			EndIf

		Case cCampo $ 'NUE_UTP|NUE_HORAP|NUE_TEMPOP'
			xValor := Iif(aStruct[nCampo][2] == "N", 0, "00:00")

		OtherWise
			xValor := NUE->(FieldGet(FieldPos(cCampo)))
	EndCase

	aAdd(aData, {cCampo, xValor})
Next nCampo

Return aData

//-------------------------------------------------------------------
/*/{Protheus.doc} J144QryTmp()
Rotina para gerar uma query da NUE para gerar a tabela temporária na função JurCriaTmp

@author bruno.ritter
@since 31/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J144QryTmp(cNvCampos, lDistinct)
Local cQry      := ""
Local cCampos   := JurCmpSelc("NUE")
Local aCamposJL := {}
Local cCamposJL := ''

Default lDistinct := .F.

	cCampos := StrTran(cCampos, "NUE_OK    ,")

	Aadd(aCamposJL,{"ACY.ACY_DESCRI" , "NUE_DGRPCL" })
	Aadd(aCamposJL,{"SA1.A1_NOME"    , "NUE_DCLIEN" })
	Aadd(aCamposJL,{"RD01.RD0_SIGLA" , "NUE_SIGLA1" })
	Aadd(aCamposJL,{"RD01.RD0_NOME"  , "NUE_DPART1" })
	Aadd(aCamposJL,{"RD02.RD0_SIGLA" , "NUE_SIGLA2" })
	Aadd(aCamposJL,{"RD02.RD0_NOME"  , "NUE_DPART2" })
	Aadd(aCamposJL,{"RD03.RD0_SIGLA" , "NUE_SIGLAA" })
	Aadd(aCamposJL,{"RD03.RD0_NOME"  , "NUE_DUSERA" })
	Aadd(aCamposJL,{"NSB.NSB_DESC"   , "NUE_DRETIF" })
	Aadd(aCamposJL,{"CTO1.CTO_SIMB"  , "NUE_DMOEDA" })
	Aadd(aCamposJL,{"CTO2.CTO_SIMB"  , "NUE_DMOED1" })
	Aadd(aCamposJL,{"NVE.NVE_TITULO" , "NUE_DCASO"  })
	Aadd(aCamposJL,{"NRC.NRC_DESC"   , "NUE_DATIVI" })
	Aadd(aCamposJL,{"NRY.NRY_DESC"   , "NUE_DFASE"  })
	Aadd(aCamposJL,{"NS0_DESC"       , "NUE_DTAREB" })
	cCamposJL := JurCaseJL(aCamposJL)

	cQry := "SELECT "
	cQry += Iif(lDistinct, " DISTINCT ", "")
	cQry += cCampos + cCamposJL + CRLF
	cQry += " '' NUE_OK" + cNvCampos
	cQry +=     " FROM " + RetSqlName( 'NUE' ) + " NUE "
	cQry += " LEFT JOIN "+ RetSqlName( 'ACY' ) + " ACY "
	cQry +=                                         " ON  ACY.ACY_GRPVEN = NUE.NUE_CGRPCL "
	cQry +=                                         " AND ACY.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND ACY.ACY_FILIAL = '" + xFilial("ACY") + "' "
	cQry += " INNER JOIN "+ RetSqlName( 'SA1' ) + " SA1 "
	cQry +=                                         " ON  SA1.A1_COD = NUE.NUE_CCLIEN "
	cQry +=                                         " AND SA1.A1_LOJA = NUE.NUE_CLOJA "
	cQry +=                                         " AND SA1.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQry += " INNER JOIN "+ RetSqlName( 'RD0' ) + " RD01 "
	cQry +=                                         " ON  RD01.RD0_CODIGO = NUE.NUE_CPART1 "
	cQry +=                                         " AND RD01.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND RD01.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQry += " INNER JOIN "+ RetSqlName( 'RD0' ) + " RD02 "
	cQry +=                                         " ON  RD02.RD0_CODIGO = NUE.NUE_CPART2 "
	cQry +=                                         " AND RD02.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND RD02.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQry += " LEFT JOIN "+ RetSqlName( 'RD0' ) + " RD03 "
	cQry +=                                         " ON  RD03.RD0_CODIGO = NUE.NUE_CUSERA "
	cQry +=                                         " AND RD03.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND RD03.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQry += " LEFT JOIN "+ RetSqlName( 'NSB' ) + " NSB "
	cQry +=                                         " ON  NSB.NSB_COD = NUE.NUE_CRETIF "
	cQry +=                                         " AND NSB.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND NSB.NSB_FILIAL = '" + xFilial("NSB") + "' "
	cQry += " LEFT JOIN "+ RetSqlName( 'NV4' ) + " NV4 "
	cQry +=                                         " ON  NV4.NV4_COD = NUE.NUE_CLTAB "
	cQry +=                                         " AND NV4.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND NV4.NV4_FILIAL = '" + xFilial("NV4") + "' "
	cQry += " LEFT JOIN "+ RetSqlName( 'CTO' ) + " CTO1 "
	cQry +=                                         " ON  CTO1.CTO_MOEDA = NUE.NUE_CMOEDA "
	cQry +=                                         " AND CTO1.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND CTO1.CTO_FILIAL = '" + xFilial("CTO") + "' "
	cQry += " LEFT JOIN "+ RetSqlName( 'CTO' ) + " CTO2 "
	cQry +=                                         " ON  CTO2.CTO_MOEDA = NUE.NUE_CMOED1 "
	cQry +=                                         " AND CTO2.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND CTO2.CTO_FILIAL = '" + xFilial("CTO") + "' "
	cQry += " INNER JOIN "+ RetSqlName( 'NVE' ) + " NVE "
	cQry +=                                         " ON  NVE.NVE_CCLIEN = NUE.NUE_CCLIEN "
	cQry +=                                         " AND NVE.NVE_LCLIEN = NUE.NUE_CLOJA "
	cQry +=                                         " AND NVE.NVE_NUMCAS = NUE.NUE_CCASO "
	cQry +=                                         " AND NVE.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
	cQry += " LEFT JOIN "+ RetSqlName( 'NRY' ) + " NRY "
	cQry +=                                         " ON  NRY.NRY_CFASE = NUE.NUE_CFASE "
	cQry +=                                         " AND NRY.NRY_CDOC = NUE.NUE_CDOC "
	cQry +=                                         " AND NRY.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND NRY.NRY_FILIAL = '" + xFilial("NRY") + "' "
	cQry += " INNER JOIN "+ RetSqlName( 'NUH' ) + " NUH "
	cQry +=                                         " ON  NUH.NUH_COD = NUE.NUE_CCLIEN "
	cQry +=                                         " AND NUH.NUH_LOJA = NUE.NUE_CLOJA "
	cQry +=                                         " AND NUH.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND NUH.NUH_FILIAL = '" + xFilial("NUH") + "' "
	cQry += " LEFT JOIN "+ RetSqlName( 'NRX' ) + " NRX "
	cQry +=                                         " ON  NRX.NRX_COD = NUH.NUH_CEMP "
	cQry +=                                         " AND NRX.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND NRX.NRX_FILIAL = '" + xFilial("NRX") + "' "
	cQry += " LEFT JOIN "+ RetSqlName( 'NS0' ) + " NS0 "
	cQry +=                                         " ON NS0.NS0_CDOC = NRX.NRX_CDOC "
	cQry +=                                         " AND NS0.NS0_COD = NUE.NUE_CTAREB "
	cQry +=                                         " AND NS0.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND NS0.NS0_FILIAL = '" + xFilial("NS0") + "' "
	cQry += " INNER JOIN "+ RetSqlName( 'NRC' ) + " NRC "
	cQry +=                                         " ON  NRC.NRC_COD = NUE.NUE_CATIVI "
	cQry +=                                         " AND NRC.D_E_L_E_T_ = ' ' "
	cQry +=                                         " AND NRC.NRC_FILIAL = '" + xFilial("NRC") + "' "

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} J144RETDOC()
Rotina para retorna o documento e-billing no gatilhos do campo loja NUE_CLOJA

@author bruno.ritter
@since 04/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J144RETDOC()
Local cEmpEb := JurGetDados("NUH", 1, xFilial("NUH") + FwFldGet('NUE_CCLIEN') + FwFldGet('NUE_CLOJA'), "NUH_CEMP")
Local cRet   := JurGetDados("NRX", 1, xFilial("NRX") + cEmpEb, "NRX_CDOC")

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144BCOMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA144BCOMMIT FROM FWModelEvent
	Method New()
	Method InTTS()
End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Classe interna implementando o FWModelEvent, para execução de função
para inicializar o metodo.

@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class JA144BCOMMIT
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS()
Classe interna implementando o FWModelEvent, para execução do metodo
de alteração em transão.

@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Method InTTS(oSubModel, cModelId) Class JA144BCOMMIT
	JA144CMB(oSubModel:GetModel())
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}  JA144CMB(oModel)
Executa rotina ao comitar as alterações no Model

@Param oModel  modelo de dados do TimeSheet

@author Jacques Alves Xavier
@since 17/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA144CMB(oModel)
Local lRet    := .T.
Local cCodTS  := oModel:GetValue("NUEMASTER", "NUE_COD")
Local cPreFat := oModel:GetValue("NUEMASTER", "NUE_CPREFT")

J170GRAVA("NUE", xFilial('NUE') + cCodTS, '3') // Fila de sincronização
J144VlTsPf(cCodTS, cPreFat ) //Revaloriza o Time Sheet novo e ajusta na pre-fatura

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144ParHst(cCampo)
Rotina para retorna o escritório e o centro de custo do historico do participante
conforme o paricipante lançado e a data do timesheet.

@param cCampo  Campo a ser retornado da tabela de histórico de paticipante

@return cRet   Conteudo do campo do historico do participante

@author Nivia Ferreira
@since 04/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J144ParHst(cCampo)
Local cRet    := ""
Local oModel  := FWModelActive()
Local cIDNUE  := IIf( oModel:GetId() == 'JURA202', "NUEDETAIL", "NUEMASTER" )
Local dDataTS := oModel:GetValue(cIDNUE, "NUE_DATATS")
Local cSigla1 := oModel:GetValue(cIDNUE, "NUE_SIGLA1")
Local cPart1  := oModel:GetValue(cIDNUE, "NUE_CPART1")

If Empty(cPart1)
	cPart1 := JurGetDados('RD0', 9, xFilial('RD0') + cSigla1, 'RD0_CODIGO')
EndIf

cRet := JurPartHst(cPart1, dDataTS, cCampo)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144FlRev()
Rotina para alterar o campo fluxo de revisão quando o campo revisado
for alterado.

@return cRet   Conteúdo do campo do fluxo de revisão

@author Queizy.nascimento
@since 24/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J144FlRev()
Local cRet     := ""
Local oModel   := FWModelActive()
Local cIDNUE   := IIf( oModel:GetId() == 'JURA144', "NUEMASTER", "NUEDETAIL" )
Local cRevisa  := oModel:GetValue(cIDNUE, "NUE_REVISA")
Local cFlRev   := oModel:GetValue(cIDNUE, "NUE_FLUREV")
Local lRevisLD := ( SuperGetMV("MV_JREVILD", .F., '2') == '1' ) //Controla a integracao da revisão de pré-fatura com o Legal Desk

If lRevisLD

	// Mudança de reprovado para qualquer outra opção
	If cFlRev == "3"
		oModel:ClearField(cIDNue, "NUE_SIGLAR")
		oModel:ClearField(cIDNue, "NUE_CREPRO")
		oModel:ClearField(cIDNue, "NUE_DREPRO")
		oModel:ClearField(cIDNue, "NUE_DTREPR")
	EndIf

	If cRevisa == '1' //Revisado
		cFlRev := '2' //Aprovado
	Else
		cFlRev := '1' //Pendente
	EndIf

	cRet := cFlRev

EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144AtvArea()
Rotina para validar o relacionamento entre Tipo de Atividade e a Área
Jurídica do Caso, considerando o histórico.

@param  lMsg  Indica se deve ser mostrada mensagem, caso o Tipo de Atividade
              não seja válido.

@return lRet  Indica se o Tipo de Atividade é válido

@author Cristina Cintra
@since 13/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144AtvArea(lMsg)
	Local lRet     := .T.
	Local oModel   := FWModelActive()
	Local cIDNUE   := IIf( oModel:GetId() $ 'JURA144|JURA144DIV|', "NUEMASTER", "NUEDETAIL" )
	Local cClien   := oModel:GetValue(cIDNUE, "NUE_CCLIEN")
	Local cLoja    := oModel:GetValue(cIDNUE, "NUE_CLOJA")
	Local cCaso    := oModel:GetValue(cIDNUE, "NUE_CCASO")
	Local cAtiv    := oModel:GetValue(cIDNUE, "NUE_CATIVI")
	Local cAnoMes  := oModel:GetValue(cIDNUE, "NUE_ANOMES")
	Local aSqlRet  := {}

	Default lMsg   := .T.

	If !Empty(cAtiv)
		aSqlRet := JurSQL(J144TpAtv(cClien, cLoja, cCaso, cAnoMes, cAtiv, .F.), {"NRC_COD"})
		If Empty(aSqlRet)
			If lMsg
				oModel:SetErrorMessage( , , oModel:GetId(), , "J144AtvArea", STR0146, STR0147, , ) //# "O Tipo de Atividade não é válido para o Caso, pois não está relacionado à Área Jurídica dele."
				lRet := .F.                                                                       //## "Verifique se o Caso está relacionado a Área Jurídica correta."
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J144RetArea
Retorna a Área Jurídica do Histórico do Caso para o período do TS.

@param   cClien  Código do Cliente
@param   cLoja   Código da Loja
@param   cCaso   Código do Caso
@param   cAnoMes Ano/Mês do Time Sheet

@return   cArea  Código da Área Jurídica

@author Cristina Cintra
@since 14/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144RetArea(cClien, cLoja, cCaso, cAnoMes)
Local cArea   := ""
Local cSQL    := ""
Local aSqlRet := {}

If !Empty(cClien) .And. !Empty(cLoja) .And. !Empty(cCaso) .And. !Empty(cAnoMes)

	cSQL := " SELECT NUU.NUU_CAREAJ CAREAJ "
	cSQL +=   " FROM " + RetSqlname('NUU') + " NUU "
	cSQL +=   " WHERE NUU.NUU_FILIAL = '" + xFilial("NUU") + "' "
	cSQL +=     " AND NUU.D_E_L_E_T_ = ' ' "
	cSQL +=     " AND NUU.NUU_CCLIEN = '" + cClien + "'"
	cSQL +=     " AND NUU.NUU_CLOJA = '" + cLoja + "'"
	cSQL +=     " AND NUU.NUU_CCASO = '" + cCaso + "'"
	cSQL +=     " AND NUU.NUU_AMINI <= '" + cAnoMes + "'"
	cSQL +=     " AND ( NUU.NUU_AMFIM >= '" + cAnoMes + "'"
	cSQL +=           " OR  NUU.NUU_AMFIM = '" + Space(TamSx3('NUU_AMFIM')[1]) + "' )"

	If !Empty(aSqlRet := JurSQL(cSQL, {"CAREAJ"}))
		cArea := aSqlRet[1][1]
	EndIf

EndIf

Return cArea

//-------------------------------------------------------------------
/*/{Protheus.doc} J144TpAtv()
Retorna para retorar os Tipos de Atividade passíveis de escolha no TS, considerando
a área jurídica do caso, data do TS e tipos de atividade não relacionados
a alguma área jurídica.

@return aTipoAtv  array com os códigos tipo de Atividades passíveis de escolha

@author Luciano Pereira dos Santos / Bruno Ritter
@since 07/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J144TpAtv(cClien, cLoja, cCaso, cAnoMes, cAtiv, lVldAtivo)
	Local cSQL        := ""
	Local cAreaCas    := J144RetArea(cClien, cLoja, cCaso, cAnoMes) //Verifica qual a área jurídica no histórico do caso

	Default cAtiv     := ""
	Default lVldAtivo := .T.

	cSQL := " SELECT NRC.NRC_COD, NRC.NRC_DESC, NRC.R_E_C_N_O_ RECNO "
	cSQL +=        " FROM " + RetSqlname('NRC') + " NRC "
	cSQL +=       " WHERE NRC.NRC_FILIAL = '" + xFilial("NRC") + "' "
	If lVldAtivo
		cSQL +=         " AND NRC.NRC_ATIVO = '1' "
	EndIf
	If !Empty(cAtiv)
		cSQL +=     " AND NRC.NRC_COD = '" + cAtiv + "' "
	EndIf
	cSQL +=         " AND ( "
	If !Empty(cAreaCas)
		cSQL +=          " EXISTS (SELECT OHQ.R_E_C_N_O_ FROM " + RetSqlname('OHQ') + " OHQ " // Ou o tipo esta vinculado a area juridica do histórico do caso.
		cSQL +=                   " WHERE OHQ.OHQ_FILIAL = '" + xFilial("OHQ") + "' "
		cSQL +=                     " AND OHQ.OHQ_CTATV = NRC.NRC_COD "
		cSQL +=                     " AND OHQ.OHQ_CAREA = '" + cAreaCas + "' "
		cSQL +=                     " AND OHQ.D_E_L_E_T_ = ' ') "
		cSQL +=          " OR "
	Endif
	cSQL +=              " NOT EXISTS (SELECT OHQ.R_E_C_N_O_ FROM " + RetSqlname('OHQ') + " OHQ " //Ou o tipo não esta vinculada a nenhuma outra area juridica.
	cSQL +=                           " WHERE OHQ.OHQ_FILIAL = '" + xFilial("OHQ") + "' "
	cSQL +=                             " AND OHQ.OHQ_CTATV = NRC.NRC_COD "
	cSQL +=                             " AND OHQ.D_E_L_E_T_ = ' ') "
	cSQL +=              " ) "
	cSQL +=         " AND NRC.D_E_L_E_T_ = ' ' "

Return cSQL

//-------------------------------------------------------------------
/*/{Protheus.doc} J144F3AtiV()
Consulta padrão de tipo de atividade filtrando as atividades passíveis
de escolha no TS, considerando a área jurídica do caso, data do TS e
tipos de atividade não relacionados a alguma área jurídica.

@Return lRet .T. retornou informação na consulta

@author Luciano Pereira dos Santos
@since 07/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Function J144F3AtiV()
	Local oModel     := FWModelActive()
	Local cIDNUE     := IIf(oModel:GetId() == 'JURA144', "NUEMASTER", "NUEDETAIL")
	Local cAnoMes    := Iif(!Empty(oModel:GetValue(cIDNUE, "NUE_ANOMES")), oModel:GetValue(cIDNUE, "NUE_ANOMES"), JSToFormat(DToS(Date()), 'YYYYMM'))
	Local cClien     := oModel:GetValue(cIDNUE, "NUE_CCLIEN")
	Local cLoja      := oModel:GetValue(cIDNUE, "NUE_CLOJA")
	Local cCaso      := oModel:GetValue(cIDNUE, "NUE_CCASO")
	Local cQuery     := ""
	Local aCampos    := {"NRC_COD", "NRC_DESC"}
	Local lVisualiza := .T.
	Local lInclui    := .T.
	Local nResult    := 0
	Local lResult    := .F.

	cQuery  := J144TpAtv(cClien, cLoja, cCaso, cAnoMes, , .T.)

	nResult := JurF3SXB("NRC", aCampos, "", lVisualiza, lInclui, "JURA039", cQuery)
	lResult := nResult > 0

	If lResult
		DbSelectArea("NRC")
		NRC->(dbgoTo(nResult))
	EndIf

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} JA144DivVl
Divide um TS para chegar o mais próximo possível do valor passado no
parâmetro sem ultrapassar o mesmo

@Param nRecTs, Recno do TS para dividir
@Param nValor, Valor para dividir o TS sem ultrapassar o mesmo.

@Return nRecNewTs, Retorna o recno do novo Timesheet

@author Bruno Ritter
@since 25/03/2019
/*/
//-------------------------------------------------------------------
Function JA144DivVl(nRecTs, nValor)
	Local nRecPos   := NUE->(Recno())
	Local lPodeFrac := SuperGetMV( 'MV_JURTS3',, .F. )  // Indica se as uts ou o tempo pode ser possuir frações da unidade de tempo
	Local oModel    := Nil
	Local oModelNUE := Nil
	Local cGrupCli  := ""
	Local cCliente  := ""
	Local cLoja     := ""
	Local cCaso     := ""
	Local cSigla1   := ""
	Local nOldTPL   := 0
	Local nOldTPR   := 0
	Local nAtuTPR   := 0
	Local nNewTPL   := 0
	Local nNewTPR   := 0
	Local nNewRecTS := 0
	Local nMultiplo := 0
	Local nNovaTP   := 0
	Local nSubTP    := 0
	Local lOk       := .T.

	NUE->(dbGoTo(nRecTs))
	oModel := FwLoadModel("JURA144")
	oModel:SetOperation(4)
	oModel:Activate()
	oModelNUE := oModel:GetModel("NUEMASTER")

	cGrupCli  := oModelNUE:GetValue("NUE_CGRPCL")
	cCliente  := oModelNUE:GetValue("NUE_CCLIEN")
	cLoja     := oModelNUE:GetValue("NUE_CLOJA")
	cCaso     := oModelNUE:GetValue("NUE_CCASO")
	cSigla1   := oModelNUE:GetValue("NUE_SIGLA1")
	nOldTPL   := oModelNUE:GetValue("NUE_TEMPOL")
	nOldTPR   := oModelNUE:GetValue("NUE_TEMPOR")

	oModelNUE:SetValue("NUE_VALOR", nValor)
	nNovaTP := oModelNUE:GetValue("NUE_TEMPOR")
	// Necessário limpar o campo de TEMPOR para recalculo
	oModelNUE:SetValue("NUE_TEMPOR", 0)
	oModelNUE:SetValue("NUE_TEMPOR", nNovaTP)

	If lPodeFrac
		nSubTP    := 1 / (10 ^ TamSx3("NUE_TEMPOR")[2])
	Else
		nMultiplo := SuperGetMV( 'MV_JURTS1',, 10 ) // Define a quantidade de minutos referentes a 1 UT
		nSubTP    := nMultiplo / 60
	EndIf

	While lOk .And. oModelNUE:GetValue("NUE_VALOR") > nValor .And. nNovaTP > 0
		nNovaTP -= nSubTP
		lOk := oModelNUE:SetValue("NUE_TEMPOR", nNovaTP)
	EndDo

	If lOk
		nAtuTPR := oModelNUE:GetValue("NUE_TEMPOR")
		nNewTPL := 0
		nNewTPR := nOldTPR - nAtuTPR

		oModel:DeActivate()
		oModel:Destroy()

		If nNewTPR > 0
			JA144DivTS({cGrupCli, cCliente, cLoja, cCaso, cSigla1, nOldTPL, nOldTPR, nNewTPL, nNewTPR, .F.}, 2, @nNewRecTS)
		EndIf
	EndIf

	NUE->(dbGoTo(nRecPos))

Return nNewRecTS

//-------------------------------------------------------------------
/*/{Protheus.doc} J144NUENRZ
Consulta especifica para retornar a tarefa e-billing

@Return lResult, Retorna o filtro conforme a consulta passada no filtro

@author Bruno Ritter / Anderson Carvalho
@since 21/06/2019
/*/
//-------------------------------------------------------------------
Function J144NUENRZ()
	Local cSQL       := ""
	Local cTab       := "NRZ"
	Local aCampos    := {{"NRZ", "NRZ_CTAREF"}, {"NRZ", "NRZ_DESC"}}
	Local lVisualiza := .F.
	Local lInclui    := .F.
	Local nResult    := 0
	Local lResult    := .T.
	Local lOperLote  := FwIsInCallStack("JA145DLG") // Operações em Lote - Time Sheet
	Local oModel     := Nil
	Local cIdNUE     := ""
	Local cFase      := ""
	Local cCodFase   := ""
	Local cDoc       := ""
	Local cClien     := ""
	Local cLoja      := ""

	If lOperLote // oFase, oClior e oLojaOr são variáveis PRIVATE criadas na JURA145
		cFase  := IIf(Type("oFase")   == "U", "", oFase:GetValue())
		cClien := IIf(Type("oClior")  == "U", "", oClior:GetValue())
		cLoja  := IIf(Type("oLojaOr") == "U", "", oLojaOr:GetValue())
		cDoc   := JAEMPEBILL(cClien, cLoja)
	Else
		oModel := FWModelActive()
		cIdNUE := IIf( oModel:GetId() == "JURA202", "NUEDETAIL", "NUEMASTER" )
		cFase  := oModel:GetValue(cIdNUE, "NUE_CFASE")
		cClien := oModel:GetValue(cIdNUE, "NUE_CCLIEN")
		cLoja  := oModel:GetValue(cIdNUE, "NUE_CLOJA")
		cDoc   := oModel:GetValue(cIdNUE, "NUE_CDOC")
	EndIf

	If NRY->( IndexKey(5) ) == "NRY_FILIAL+NRY_CFASE+NRY_CDOC" // Proteção
		cCodFase := JurGetDados("NRY", 5, xFilial("NRY") + cFase + cDoc, "NRY_COD")
	Else
		NRY->( dbSetOrder( 1 ) )
		NRY->( dbSeek( xFilial('NRY') + cDoc ) )

		While !NRY->( EOF() ) .And. NRY->NRY_CDOC == cDoc
			If AllTrim(NRY->NRY_CFASE) == AllTrim(cFase)
				cCodFase := NRY->NRY_COD
				Exit
			Else
				lResult := .F.
			EndIf
			NRY->( dbSkip() )
		EndDo
	EndIf

	If lResult
		cSQL := " SELECT NRZ.NRZ_CTAREF, NRZ.NRZ_DESC, NRZ.R_E_C_N_O_ RECNO "
		cSQL +=   " FROM " + RetSqlName("NRZ") + " NRZ "
		cSQL +=  " WHERE NRZ.NRZ_FILIAL = '" + xFilial("NRZ") + "'"
		cSQL +=    " AND NRZ.NRZ_CDOC = '" + cDoc + "' "
		cSQL +=    " AND NRZ.NRZ_CFASE = '" + cCodFase + "' "
		CSQL +=    " AND NRZ.D_E_L_E_T_ = ' ' "

		nResult := JurF3SXB(cTab, aCampos, "", lVisualiza, lInclui, "", cSQL)
		lResult := nResult > 0

		If lResult
			DbSelectArea(cTab)
			(cTab)->(dbgoTo(nResult))
		EndIf
	EndIf

Return lResult

//-------------------------------------------------------------------
/*/{Protheus.doc} J144NS0NRY
Consulta especifica para retornar a Atividade ou fase E-billing

@param cCampo Nome do campo no dicionário onde é utilizado esta função.

@Return lResult, Retorna o filtro conforme a consulta passada no filtro

@Obs:  Função chamada no X3_F3 dos campos NUE_CTAREB e NUE_CFASE

@author Abner Fogaça
@since 17/06/2022
/*/
//-------------------------------------------------------------------
Function J144NS0NRY(cCampo)
Local cSQL       := ""
Local cTab       := ""
Local cIdNUE     := ""
Local cDoc       := ""
Local aCampos    := {}
Local lVisualiza := .T.
Local lInclui    := .F.
Local nResult    := 0
Local lResult    := .T.
Local oModel     := Nil

	oModel := FWModelActive()
	cIdNUE := IIf( oModel:GetId() == "JURA202", "NUEDETAIL", "NUEMASTER" )
	cDoc   := oModel:GetValue(cIdNUE, "NUE_CDOC")

	If "NUE_CTAREB" $ cCampo
		aCampos := {{"NS0", "NS0_CATIV"}, {"NS0", "NS0_DESC"}}
		cTab    := "NS0"

		cSQL := " SELECT NS0_CATIV, NS0_DESC, NS0.R_E_C_N_O_ RECNO"
		cSQL +=   " FROM " + RetSqlName("NS0") + " NS0 "
		cSQL +=  " WHERE NS0_FILIAL = '" + xFilial("NS0") + "'"
		cSQL +=    " AND NS0_CDOC = '" + cDoc + "'
		CSQL +=    " AND NS0.D_E_L_E_T_ = ' ' "
	Else
		aCampos := {{"NRY", "NRY_CFASE"}, {"NRY", "NRY_DESC"}}
		cTab    := "NRY"

		cSQL := " SELECT NRY_CFASE, NRY_DESC, NRY.R_E_C_N_O_ RECNO"
		cSQL +=   " FROM " + RetSqlName("NRY") + " NRY "
		cSQL +=  " WHERE NRY_FILIAL = '" + xFilial("NRY") + "'"
		cSQL +=    " AND NRY_CDOC = '" + cDoc + "'
		CSQL +=    " AND NRY.D_E_L_E_T_ = ' ' "
	EndIf

	nResult := JurF3SXB(cTab, aCampos, "", lVisualiza, lInclui, "", cSQL)
	lResult := nResult > 0

	If lResult
		DbSelectArea(cTab)
		(cTab)->(dbgoTo(nResult))
	EndIf

Return lResult
