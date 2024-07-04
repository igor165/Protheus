#INCLUDE "JURA049.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDef.ch"

Static lIsLancOk := .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA049
Despesas.

@author Rodrigo Antonio Godinho da Silva
@since 24/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA049()
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lVldUser  := Iif(FindFunction("JurVldUxP"), JurVldUxP(), .T.)
Private oBrowse

If lVldUser
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0009 )
	oBrowse:SetAlias( "NVY" )
	Iif(cLojaAuto == "1" .And. FindFunction("JurBrwRev"), JurBrwRev(oBrowse, "NVY", {"NVY_CLOJA"}), ) //PROTEÇÃO
	oBrowse:SetLocate()
	oBrowse:SetMenuDef('JURA049')
	JurSetLeg(oBrowse, "NVY")
	J049Filter(oBrowse, cLojaAuto) // Adiciona fitros padrões no browse

	oBrowse:Activate()
EndIf

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} J049Filter
Adiciona filtros padrões no browse

@param  oBrowse, objeto, browse da rotina

@author Reginaldo Borges / Cristina Cintra
@since  08/08/2022
/*/
//-------------------------------------------------------------------
Static Function J049Filter(oBrowse, cLojaAuto)
Local aFilNVY1 := {}
Local aFilNVY2 := {}
Local aFilNVY3 := {}
Local aFilNVY4 := {}
Local aFilNVY5 := {}
Local aFilNVY6 := {}

	SAddFilPar("NVY_SITUAC", "==", "%NVY_SITUAC0%", @aFilNVY1)
	oBrowse:AddFilter(STR0126, 'NVY_SITUAC == "%NVY_SITUAC0%"', .F., .F., , .T., aFilNVY1, STR0126) // "Situação"

	SAddFilPar("NVY_DATA", ">=", "%NVY_DATA0%", @aFilNVY2)
	oBrowse:AddFilter(STR0127, 'NVY_DATA >= "%NVY_DATA0%"', .F., .F., , .T., aFilNVY2, STR0127) // "Data Maior ou Igual a"

	SAddFilPar("NVY_DATA", "<=", "%NVY_DATA0%", @aFilNVY3)
	oBrowse:AddFilter(STR0128, 'NVY_DATA <= "%NVY_DATA0%"', .F., .F., , .T., aFilNVY3, STR0128) // "Data Menor ou Igual a"

	If cLojaAuto == "2"
		SAddFilPar("NVY_CCLIEN", "==", "%NVY_CCLIEN0%", @aFilNVY4)
		SAddFilPar("NVY_CLOJA", "==", "%NVY_CLOJA0%", @aFilNVY4)
		oBrowse:AddFilter(STR0129, 'NVY_CCLIEN == "%NVY_CCLIEN0%" .AND. NVY_CLOJA == "%NVY_CLOJA0%"', .F., .F., , .T., aFilNVY4, STR0129) // "Cliente"
	Else
		SAddFilPar("NVY_CCLIEN", "==", "%NVY_CCLIEN0%", @aFilNVY4)
		oBrowse:AddFilter(STR0129, 'NVY_CCLIEN == "%NVY_CCLIEN0%"', .F., .F., , .T., aFilNVY4, STR0129) // "Cliente"
	EndIf
	
	SAddFilPar("NVY_CCASO", "==", "%NVY_CCASO0%", @aFilNVY5)
	oBrowse:AddFilter(STR0131, 'NVY_CCASO == "%NVY_CCASO0%"', .F., .F., , .T., aFilNVY5, STR0131) // "Caso"
	
	SAddFilPar("NVY_CTPDSP", "==", "%NVY_CTPDSP0%", @aFilNVY6)
	oBrowse:AddFilter(STR0132, 'NVY_CTPDSP == "%NVY_CTPDSP0%"', .F., .F., , .T., aFilNVY6, STR0132) // "Tipo"

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

@author Rodrigo Antonio Godinho da Silva
@since 24/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina    := {}
Local lIntFinanc := SuperGetMV("MV_JURXFIN",, .F.) // Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // Pesquisar
aAdd( aRotina, { STR0002, "VIEWDEF.JURA049", 0, 2, 0, NIL } ) // Visualizar

If !lIntFinanc
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA049", 0, 3, 0, NIL } ) // Incluir
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA049", 0, 5, 0, NIL } ) // Excluir
	aAdd( aRotina, { STR0006, "JURA049Agr"     , 0, 5, 0, NIL } ) // Agrupar
EndIf

aAdd( aRotina, { STR0004, "VIEWDEF.JURA049", 0, 4, 0, NIL } ) // Alterar
aAdd( aRotina, { STR0045, "JCall143"       , 0, 5, 0, NIL } ) // Op. em Lote

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Despesas

@author Rodrigo Antonio Godinho da Silva
@since 24/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA049" )
Local oStruct    := FWFormStruct( 2, "NVY" )
Local oStructNVZ := FWFormStruct( 2, "NVZ" )
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lJurxFin   := SuperGetMV("MV_JURXFIN",, .F.) //Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
Local lFSinc     := SuperGetMV("MV_JFSINC", .F., '2') == '1' // Fila de sincronização

// Remove os campos da tela
oStruct:RemoveField("NVY_TKRET")
oStruct:RemoveField("NVY_CPART")
oStruct:RemoveField("NVY_ACAOLD")
oStruct:RemoveField("NVY_CCLILD")
oStruct:RemoveField("NVY_CLJLD")
oStruct:RemoveField("NVY_CCSLD")
oStruct:RemoveField("NVY_PARTLD")
oStruct:RemoveField("NVY_CMOTWO")
oStruct:RemoveField("NVY_OBSWO")
oStruct:RemoveField("NVY_CDWOLD")
oStruct:RemoveField("NVY_COTAC")

oStructNVZ:RemoveField("NVZ_COTAC")

If !lJurxFin
	oStruct:RemoveField("NVY_CLANC")
	oStruct:RemoveField("NVY_CPAGTO")
	oStruct:RemoveField("NVY_ITDES")
	oStruct:RemoveField("NVY_ITDPGT")
EndIf

JurSetAgrp( "NVY",, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( "JURA049_VIEW", oStruct   , "NVYMASTER" )
oView:AddGrid(  "JURA049_NVZ" , oStructNVZ, "NVZDETAIL" )

oView:CreateHorizontalBox("FORMFIELD", 60)
oView:CreateHorizontalBox("FORMFOLDER", 40 )

oView:CreateFolder('FOLDER_01',"FORMFOLDER")
oView:AddSheet('FOLDER_01','ABA_NVZ', STR0044) // Despesa de Faturamento
oView:CreateHorizontalBox("FORMFOLDER_NVZ",100,,,'FOLDER_01','ABA_NVZ')

oView:SetOwnerView( "JURA049_VIEW","FORMFIELD" )
oView:SetOwnerView( "JURA049_NVZ" , "FORMFOLDER_NVZ" )

If(cLojaAuto == "1")
	oStruct:RemoveField( "NVY_CLOJA" )
	oStructNVZ:RemoveField( "NVZ_CLOJA" )
EndIf

If !lFSinc
	oStructNVZ:RemoveField("NVZ_CCLICM")
	oStructNVZ:RemoveField("NVZ_CLOJCM")
	oStructNVZ:RemoveField("NVZ_CCASCM")
EndIf

oView:SetDescription( STR0009 )
oView:SetViewCanActivate({|oView|JA049CANA(oView)})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Despesas

@author Rodrigo Antonio Godinho da Silva
@since 24/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local lShowVirt  := !JurIsRest() // Inclui os campos virtuais nos structs somente se não for REST (Necessário já que os inicializadores dos campos virtuais são executados sempre, mesmo sem o uso do header FIELDVIRTUAL = TRUE)
Local oStruct    := FWFormStruct( 1, "NVY",,, lShowVirt )
Local oStructNVZ := FWFormStruct( 1, "NVZ",,, lShowVirt )
Local bBlock049W := FwBuildFeature( STRUCT_FEATURE_WHEN, 'JA049WHEN()' )
Local bBlockTrue := FwBuildFeature( STRUCT_FEATURE_WHEN, ".T." )
Local bBlockCaso := FwBuildFeature( STRUCT_FEATURE_WHEN, "JA49VLCLI() .AND. JA049WHEN()" )
Local oCommit    := JA049Commit():New()

If !lShowVirt
	// Adiciona os campos virtuais "TKRET" e "SIGLA" novamente nas estruturas, pois foram retirados via lShowVirt,
	// mas precisam existir para execução das operações nos lançamentos via REST
	AddCampo(1, "NVY_TKRET", @oStruct)
	AddCampo(1, "NVY_SIGLA", @oStruct)
EndIf

oModel:= MPFormModel():New( "JURA049", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)

oModel:AddFields( "NVYMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddGrid( "NVZDETAIL", "NVYMASTER" /*cOwner*/, oStructNVZ, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:SetDescription(STR0009)
oModel:GetModel( "NVYMASTER" ):SetDescription( STR0010 )

oStruct:SetProperty( '*', MODEL_FIELD_WHEN, bBlock049W )
oStruct:SetProperty( 'NVY_DESCRI', MODEL_FIELD_WHEN, bBlockTrue )
oStruct:SetProperty( 'NVY_CCASO', MODEL_FIELD_WHEN, bBlockCaso )

oModel:SetRelation( "NVZDETAIL", { { "NVZ_FILIAL", "xFilial('NVZ')" }, { "NVZ_CDESP", "NVY_COD" } }, "R_E_C_N_O_" )
oModel:GetModel( "NVZDETAIL" ):SetDelAllLine( .T. )
oModel:GetModel( "NVZDETAIL" ):SetUniqueLine( { "NVZ_CDESP" } )

oModel:GetModel( "NVZDETAIL" ):SetNoInsertLine()
oModel:GetModel( "NVZDETAIL" ):SetNoUpdateLine()
oModel:GetModel( "NVZDETAIL" ):SetNoDeleteLine()

oModel:SetOptional( "NVZDETAIL", .T. )

oModel:InstallEvent("JA049Commit", /*cOwner*/, oCommit)

oStruct:SetProperty( 'NVY_COTAC', MODEL_FIELD_NOUPD, .T. )

JurSetRules( oModel, "NVYMASTER",, "NVY" )
JurSetRules( oModel, "NVZDETAIL",, "NVZ",,  )

oModel:SetVldActivate( { |oModel| J049VldAct( oModel ) } )
oModel:SetActivate( { |oModel| JA049ACT( oModel ) } )

oModel:GetModel( 'NVZDETAIL' ):SetOnlyView( .T. )
oStructNVZ:SetProperty( '*', MODEL_FIELD_NOUPD, .T. )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049ACT(oModel)
Função de ativação do modelo.

@param oModel, Modelo de dados de despesas.

@author bruno.ritter
@since 24/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA049ACT(oModel)
Local cClien     := NVY->NVY_CCLIEN
Local cLoja      := NVY->NVY_CLOJA
Local cCaso      := NVY->NVY_CCASO
Local dDataLC    := NVY->NVY_DATA
Local nOperation := oModel:GetOperation()

	If nOperation == MODEL_OPERATION_UPDATE .And. FindFunction("JurBlqLnc")
		lIsLancOk := JurBlqLnc( cClien, cLoja, cCaso, dDataLC, "DEP", "2" )
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J049VldAct
Função de validação da ativação do modelo.

@param oModel, Modelo de dados de despesas.

@retrun lRet,  Indica se o modelo poderá ser ativado.

@author Jorge Martins
@since  13/12/2019
/*/
//-------------------------------------------------------------------
Static Function J049VldAct(oModel)
Local lRet       := .T.
Local nOperation := oModel:GetOperation()
Local lJurxFin   := SuperGetMV("MV_JURXFIN",,.F.) // Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
Local lIsRest    := (Iif(FindFunction("JurIsRest"), JurIsRest(), .F.))

	lRet := Iif(FindFunction("JurVldUxP"), JurVldUxP(oModel), .T.)

	If lRet .And. lJurxFin .And. lIsRest .And. nOperation == MODEL_OPERATION_INSERT .And. (!IsInCallStack("JA049GerDp") .And. !IsInCallStack("J241OpDesp"))
		lRet := JurMsgErro(STR0123,, STR0124) // "Operação não permitida. Não é possível incluir despesa através deste modelo quando a integração com o módulo financeiro está habilitada (MV_JURXFIN)." // "Utilize o modelo de lançamentos entre naturezas para incluir despesas, ou desabilite o parâmetro MV_JURXFIN."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049CANA
Modelo de dados de Despesas

@author Rodrigo Antonio Godinho da Silva
@since 24/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA049CANA(oView)
Local lRet       := .T.
Local nOperation := 0
Local lAltDesp   := SuperGetMV("MV_JALTDSP", , "2") == "1"  // Permite manipulação de despesas pelo SIGAPFS? "1" = Sim / "2" = Não

nOperation := oView:GetModel():GetOperation()

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_DELETE
	If !lAltDesp
		lRet := JurMsgErro(STR0011)  //"O Sistema está bloqueado para a inclusão/exclusão de Despesas direto pelo Faturamento de Serviços."
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049OBS
Função para validação da observação nao cobravel(NVY_OBSCOB) baseado no MV_JCOBDSP e no campo NVY_COBRAR
Melhoria de performance para operaçoes de pré-fatura

@author Luciano Pereira dos Santos
@since 27/01/2017
@version 2.0
/*/
//-------------------------------------------------------------------
Function JA049OBS(nLine)
Local lRet      := .T.
Local lJcobDsp  := SuperGetMV('MV_JCOBDSP',, .F.)
Local oModel    := FWModelActive()
Local oModelNVY := Nil
Local cCobrar   := ''
Local cObsCob   := ''

Default nLine   := 1

If oModel:GetId() == 'JURA202'
	oModelNVY := oModel:GetModel("NVYDETAIL")
	cCobrar   := oModelNVY:GetValue("NVY_COBRAR", nLine)
	cObsCob   := oModelNVY:GetValue("NVY_OBSCOB", nLine)
Else
	oModelNVY := oModel:GetModel("NVYMASTER")
	cCobrar   := oModelNVY:GetValue("NVY_COBRAR")
	cObsCob   := oModelNVY:GetValue("NVY_OBSCOB")
EndIf

If lJcobDsp
	If cCobrar == "2" .And. Empty(cObsCob)
		lRet := JurMsgErro(STR0012,, STR0120) // "É necessário informar a Observação de não cobrável." # "Preencha a Observação de não cobrável."
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA49VLDCB
Função para validação do campo NVY_COBRAR.

@param  cPart     Código do participante que efetuou a alteração
        lForce    Indica se deve forçar a atualização do campo de Obs e
                  Usuário não cobrável

@return lRet      .T. ou .F. da validação

@author Rodrigo Antonio Godinho da Silva
@since 26/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA49VLDCB(cPart, lForce, oModel)
Local lRet     := .T.
Local cCobrar  := ""
Local cIdNVY   := ""
Local cSigla   := ""

Default cPart  := JurUsuario(__cUserID)
Default lForce := .F.
Default oModel := FWModelActive()

	cIdNVY   := IIF(oModel:GetId() == 'JURA202', "NVYDETAIL", "NVYMASTER" )

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .AND. (!JurIsRest() .Or. lForce)
		cCobrar := oModel:GetValue(cIdNVY, "NVY_COBRAR")
		cSigla  := JurGetDados("RD0", 1, xFilial("RD0") + cPart, "RD0_SIGLA")
		cObs    := FWTimeStamp(2) + " - " + STR0020 + AllTrim(cSigla) + CRLF + STR0133 + Iif(cCobrar == "1", STR0042, STR0043) + CRLF + CRLF //Usuário: # Alteração para # cobrável/não cobrável 
		If cCobrar == "1" // Sim
			oModel:GetModel( cIdNVY ):ClearField( "NVY_OBSCOB" )
			oModel:GetModel( cIdNVY ):ClearField( "NVY_USRNCB" )
		Else
			oModel:LoadValue(cIdNVY, "NVY_USRNCB", AVKey(cPart, "NVY_USRNCB"))
		EndIf
		oModel:LoadValue(cIdNVY, "NVY_OBS", AllTrim(cObs + oModel:GetValue(cIdNVY, "NVY_OBS")))
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049OK
Tudo OK do Model

@param oModel      - Modelo de dados da despesa
@param oModelDesd  - Modelo de dados do desdobrameto
@param oModelLanc  - Modelo de dados do lançamento financeiro
@param oTmpAcaoLD  - Tabela Temporária da despesa (Usada para vínculo de despesa via LD)

@author Felipe Bonvicini Conti
@since 26/05/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA049OK(oModel, oModelDesd, oModelLanc, oTmpAcaoLD)
Local lRet      := .T.
Local aArea     := GetArea()
Local dDemis    := CToD( '  /  /  ' )
Local cIdNVY    := IIf( oModel:GetId() == 'JURA202', "NVYDETAIL", "NVYMASTER" )
Local cPrefat   := oModel:GetValue(cIdNVY, 'NVY_CPREFT')
Local cSigla    := oModel:GetValue(cIdNVY, 'NVY_SIGLA')
Local cClien    := oModel:GetValue(cIdNVY, "NVY_CCLIEN")
Local cLoja     := oModel:GetValue(cIdNVY, "NVY_CLOJA" )
Local cCaso     := oModel:GetValue(cIdNVY, "NVY_CCASO" )
Local dDataLC   := oModel:GetValue(cIdNVY, 'NVY_DATA'  )
Local nOper     := oModel:GetOperation()
Local lJurxFin  := SuperGetMV("MV_JURXFIN",,.F.) // Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
Local lOrigJ241 := FwIsInCallStack("J241OpDesp") // Quando a origem da operação for da JURA241(Lançamento)
Local lOrigJ246 := FwIsInCallStack("J246OpDesp") // Quando a origem da operação for da JURA246(Desdobramento)
Local lOrigJ247 := FwIsInCallStack("J247OpDesp") // Quando a origem da operação for da JURA247(Desdobramento pós pagamento)
Local oModelNVY := oModel:GetModel(cIdNVY)
Local lIsRest   := JurIsRest()

lRet := JA049VERPRE(cPrefat, oModel)

If lRet .And. (oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
	lRet = JurCliLVld(oModel, oModelNVY:GetValue('NVY_CCLIEN'), oModelNVY:GetValue('NVY_CLOJA'))
EndIf

If lRet .And. (nOper == MODEL_OPERATION_DELETE)

	lRet := J049CanDel(oModel)

ElseIf lRet .And. (nOper == MODEL_OPERATION_INSERT .Or. nOper == MODEL_OPERATION_UPDATE)
	lRet := JA049OBS()

	If lRet .And. lIsRest .And. cIdNVY == "NVYMASTER" .And. oModelNVY:GetValue("NVY_COBRAR") == "1"
		lRet := JurVldAcLd(oModel, cIdNVY, "NVY", @oTmpAcaoLD)
	EndIf

	If lRet .And. lIsRest
		If oModelNVY:GetValue("NVY_COBRAR") == "2" .And. Empty(oModelNVY:GetValue("NVY_USRNCB"))
			lRet := JurMsgErro(STR0121,, STR0122) // "O Código do Usuário que está alterando o lançamento para não cobrar deve ser preenchido." # "Preencha o Código do Usuário para Não Cobrar (NVY_USRNCB)."
		EndIf
	EndIf

	// Valida o preenchimento do solicitante e se a data do cadastro da despesa é maior ou igual a data de demissão do solicitante
	If lRet
		If !Empty(cSigla)
			dDemis := JurGetDados('RD0', 9, xFilial('RD0') + cSigla, 'RD0_DTADEM') // Campo da data de demissão

			If !Empty(dDemis) .And. (dDemis < dDataLC)
				lRet := JurMsgErro(STR0113, , I18N(STR0114, {DtoC(dDemis), Alltrim(cSigla)})) //#A data da despesa é posterior a data de demissão do solicitante.                                                         //## "Informe uma data anterior a '#1' ou verifique a situação do solicitante '#2' no cadastro de participantes."
			EndIf
		EndIf
	EndIf

EndIf

If lRet .And. (nOper == MODEL_OPERATION_DELETE .OR. nOper == MODEL_OPERATION_INSERT)

	If FindFunction("JurBlqLnc") //PROTEÇÃO
		//Valida  a existência de Fatura Adicional faturada cujo período de referência englobe a data do Lançamento
		lRet := JurBlqLnc( cClien, cLoja, cCaso, dDataLC, "DEP" )
	EndIf

	// Não é possível incluir ou excluir pela tela de despesa
	If lRet .And. lJurxFin .And. !lOrigJ241 .And. !lOrigJ246 .And. !lOrigJ247
		lRet := JurMsgErro( STR0100,,;//"Não é possível incluir ou excluir registros."
						STR0101+CRLF+;//"1) Verifique o parâmetro 'MV_JURXFIN'."
						STR0102)//"2) Realize a operação pela tela de Lançamentos 'JURA241'."
	EndIf

EndIf

If lRet .And. lJurxFin .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. !lOrigJ241 .And. !lOrigJ246 .And. !lOrigJ247
	//Atualiza e valida os modelos para replicar despesa
	If !Empty(oModelNVY:GetValue("NVY_CLANC")) .Or. !Empty(oModelNVY:GetValue('NVY_CPAGTO'))
		oModelLanc := J049RepLan(oModel)
		If !Empty(oModelNVY:GetValue("NVY_ITDES")) .Or. !Empty(oModelNVY:GetValue("NVY_ITDPGT"))
			oModelDesd := J049RepDsb(oModel)
		EndIf
		lRet := !Empty(oModelDesd) .Or. !Empty(oModelLanc)
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J049CanDel(oModel)
Rotina para  verificar se o Lançamento pode ser excluido.
@param oModel      - Modelo de dados da despesa
@author Luciano Pereira dos Santos
@since 27/10/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J049CanDel(oModel)
Local lRet      := .T.
Local oModelNVZ := oModel:GetModel("NVZDETAIL")

	If !oModelNVZ:IsEmpty()
		lRet := JurMsgErro(STR0110,, STR0111) // "A despesa possui movimentações e não pode ser excluída." # "Existe faturamento/wo relacionados. Mesmo que o WO/Fatura estiverem cancelados, por questão de rastreabilidade o registro não pode ser excluido."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049WHFIN
Avalia o WHen dos campos NVY_DATA,NVY_CMOEDA,NVY_VALOR

@author Rodrigo Antonio Godinho da Silva
@since 26/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA049WHFIN()
Local lRet
Local oModel
Local cIdNVY

oModel := FWModelActive()
cIdNVY := IIf( oModel:GetId() == 'JURA202', "NVYDETAIL", "NVYMASTER" )

lRet := Empty(oModel:GetValue(cIdNVY ,"NVY_CDETRT"))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049WHEN
Avalia a situação (NVY_SITUAC), para verificar se ira habilitar os campos.

@author Rodrigo Antonio Godinho da Silva
@since 27/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA049WHEN()
Local lRet     := .T.
Local oModel   := FWModelActive()
Local cIdNVY   := IIf( oModel:GetId() == 'JURA202', "NVYDETAIL", "NVYMASTER" )
Local lAltDesp := SuperGetMV("MV_JALTDSP", , "2") == "1" .OR. IsInCallStack('JURA063') .OR. IsInCallStack('J063Remanj') // Permite manipulação de despesas pelo SIGAPFS? "1" = Sim / "2" = Não
Local cCampo   := ""

lRet := (oModel:GetValue(cIdNVY ,"NVY_SITUAC") != "2") .AND. lAltDesp

If lRet
	cCampo := ReadVar()
	If "NVY_CTPDSP" $ cCampo
		lRet := !Empty(oModel:GetValue(cIdNVY, "NVY_CCASO"))
	ElseIf "NVY_CMOTWR" $ cCampo
		lRet := oModel:GetValue(cIdNVY, "NVY_COBRAR") == "2"
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049VALC
Validação do campo NVY_CTPDSP.

@author Rodrigo Antonio Godinho da Silva
@since 27/12/09
@version 1.1
/*/
//-------------------------------------------------------------------
Function JA049VALC()
Local oModel    := FWModelActive()
Local cIdNVY    := IIf( oModel:GetId() == 'JURA202', "NVYDETAIL", "NVYMASTER" )
Local aFields   := {{'NVY_CGRUPO',STR0013},{'NVY_CCLIEN',STR0014},{'NVY_CLOJA',STR0015},{'NVY_CCASO',STR0016},{'NVY_CTPDSP',STR0017}}
Local cMessage  := ""
Local nX        := 0
Local xValue    := Nil
Local xOldValue := Nil
Local lRet      := .T.

If (__ReadVar $ 'M->NVY_CTPDSP')

	NRH->(dbSetOrder(1)) //NRH_FILIAL+NRH_COD
	If !NRH->(dbSeek(xFilial("NRH") + oModel:GetValue(cIdNVY, "NVY_CTPDSP")))
		lRet := JurMsgErro(STR0038) //"Código de despesa inválido"
	Else
		If NRH->NRH_ATIVO != "1"
			lRet := JurMsgErro(STR0039) //"Código de despesa inativo"
		EndIf
	EndIf
EndIf

If lRet .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	For nX := 1 To Len(aFields)
		xOldValue := NVY->(&(aFields[nX][1]))
		xValue    := oModel:GetValue(cIdNVY,aFields[nX][1])
		If !(Alltrim(xOldValue) == Alltrim(xValue)) .And. !Empty(xValue)
			cMessage += aFields[nX][2] + STR0018 + Alltrim(xOldValue) + STR0019 + Alltrim(xValue) + CRLF
		EndIf
	Next nX
	If !Empty(cMessage)
		cMessage := STR0020 + __cUserID + CRLF + cMessage
		cMessage := cMessage + NVY->NVY_OBS
		oModel:LoadValue(cIdNVY, "NVY_OBS", cMessage)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA049Agr
Função Agrupar Despesas
@author Rodrigo Antonio Godinho da Silva
@since 28/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA049Agr()
Local cCodPai     := ""
Local nX          := 0
Local aArea       := GetArea()
Local cMensagem   := ""
Local nTotalDesp  := 0
Local aRecnos     := {}
Local lTemPF      := .T.
Local cCodPre     := NVY->NVY_CPREFT
Local nRegAtu     := 0
Local cClienDesp  := ""
Local cLojaDesp   := ""
Local cCasoDesp   := ""
Local cMoedaDesp  := ""
Local dDtDesp     := CToD( '  /  /  ' )
Local cTextoMsg   := ""
Local nRegNVY     := 0
Local aOrd        := SaveOrd({"NVY", "NX0"})
Local cKeyNVY     := ""
Local cPreFatPai  := ""
Local lCanPre     := .F.
Local aPreFilho   := {}
Local aPreAlter   := {}
Local cPartLog    := JurUsuario(__CUSERID)
Local cTextoAlt   := ""
Local cTextoExc   := ""
Local cSitPrePai  := ""
Local cSitPreFilho:= ""
Local cDespOrigem := ""
Local aDPSemPre   := {}
Local cClien      := NVY->NVY_CCLIEN
Local cLoja       := NVY->NVY_CLOJA
Local cCaso       := NVY->NVY_CCASO
Local dDataLC     := NVY->NVY_DATA
Local cNx0SitAnt  := ""

//Valida  a existência de Fatura Adicional faturada cujo período de referência englobe a data do Lançamento
If FindFunction("JurBlqLnc") .And. JurBlqLnc( cClien, cLoja, cCaso, dDataLC, "DEP" ) //PROTEÇÃO
	If NVY->NVY_DESDIV == "1" .And. !Empty(NVY->NVY_CODPAI)

		If !Empty(cCodPre) .And. !Empty(NVY->NVY_CODPAI)  //Negação da função Empty() pois estava invertida, só pode pegar cCodPre se não estiver vazio.

			// Correção na forma de obtenção do código da pré-fatura e leitura de dados utilizados nas validações do agrupamento.
			nRegAtu := NVY->(Recno())
			cKeyNVY := xFilial("NVY")+NVY->NVY_CODPAI
			NVY->(DbSetOrder(1))
			NVY->(DbSeek(cKeyNVY))
			cCodPre     := NVY->NVY_CPREFT
			nRegNVY     := NVY->(Recno())
			cPreFatPai  := cCodPre
			cClienDesp  := NVY->NVY_CCLIEN
			cLojaDesp   := NVY->NVY_CLOJA
			cCasoDesp   := NVY->NVY_CCASO
			cMoedaDesp  := NVY->NVY_CMOEDA
			dDtDesp     := NVY->NVY_DATA
			cDespOrigem := NVY->NVY_COD
			RestOrd(aOrd)
			NVY->(DbGoTo(nRegAtu))
			// Fim da correção da obtenção do código da pré-fatura e leitura de dados utilizados nas validações do sistema.
		Else
			// Obtenção do recno da despesa pai e dados utilizados nas validações dos agrupamentos.
			nRegAtu := NVY->(Recno())
			cKeyNVY := xFilial("NVY")+NVY->NVY_CODPAI
			NVY->(DbSetOrder(1))
			NVY->(DbSeek(cKeyNVY))
			nRegNVY     := NVY->(Recno())
			cPreFatPai  := NVY->NVY_CPREFT
			cClienDesp  := NVY->NVY_CCLIEN
			cLojaDesp   := NVY->NVY_CLOJA
			cCasoDesp   := NVY->NVY_CCASO
			cMoedaDesp  := NVY->NVY_CMOEDA
			dDtDesp     := NVY->NVY_DATA
			cDespOrigem := NVY->NVY_COD
			RestOrd(aOrd)
			NVY->(DbGoTo(nRegAtu))
			// Fim da da obtenção do recno() da despesa pai.
		EndIf

		NX0->(DbSetOrder(1)) // NX0_FILIAL+NX0_COD+NX0_SITUAC
		If NX0->(DbSeek(xFilial("NX0")+cPreFatPai))
			cSitPrePai := NX0->NX0_SITUAC
			If NX0->NX0_SITUAC <> "2" .And. NX0->NX0_SITUAC <> "3"
				JurErrLog(STR0081 + AllTrim(cPreFatPai)+; // "O agrupamento de despesas não poderá ser realizado. A pré-fatura '"
				STR0082 + AllTrim(JurSitGet(NX0->NX0_SITUAC))+". " )// "' da despesa de origem está com a situação: "
				RestOrd(aOrd,.T.)
				Return
			EndIf
		EndIf
		If cPreFatPai <> cCodPre // Se sim, pega situação da pré-fatura cCodPre, pois a função JA049VERPRE altera a situação da pré-fatura.
			If NX0->(DbSeek(xFilial("NX0")+cCodPre))
				cSitPreFilho := NX0->NX0_SITUAC
			EndIf
		EndIf

		If !Empty(cCodPre)
			lTemPF := JA049VERPRE(cCodPre)  //Valida se a Despesa tem pré-fatura e valida
		EndIf

		If lTemPF // Não tem pre-fatura ou foi alterada
			If Empty(cMensagem)
				cCodPai := Alltrim(NVY->NVY_CODPAI)
				NVY->(DbSetOrder(1))
				If NVY->(DbSeek( xFilial("NVY") + cCodPai))
					nTotalDesp += NVY->NVY_VALOR
					aAdd(aRecnos,NVY->(Recno()))
				EndIf
				NVY->(DbSetOrder(3)) //NVY_FILIAL+NVY_CODPAI+NVY_COD
				NVY->(DbSeek( xFilial("NVY") + cCodPai))

				While (NVY->(!Eof() .And. NVY_CODPAI == cCodPai))

					If NVY->NVY_DESDIV != '1'
						cMensagem := STR0022 //"Todas as despesas precisam ser despesas divididas."
						Exit
					ElseIf NVY->NVY_SITUAC != '1'
						cMensagem := STR0023 //"Não é possivel agrupar as despesas pois existem despesas já concluídas."
						Exit
					EndIf

					If cClienDesp  <> NVY->NVY_CCLIEN .Or. cLojaDesp <> NVY->NVY_CLOJA .Or. cCasoDesp <> NVY->NVY_CCASO
						cMensagem := STR0076 // "Não é possivel agrupar as despesas de clientes, lojas e casos diferentes."
						Exit
					EndIf

					If cMoedaDesp <> NVY->NVY_CMOEDA
						cMensagem := STR0077 // "Não é possivel agrupar as despesas de moedas diferentes."
						Exit
					EndIf

					nTotalDesp += NVY->NVY_VALOR
					aAdd(aRecnos, NVY->(Recno()))

					NVY->(DbSkip())
				End
			EndIf

			If Empty(cMensagem)
				If !Empty(aRecnos)
					If MsgYesNo(STR0024)  // "Deseja realmente agrupar as despesas?"

						BEGIN Transaction
							NVY->(DbGoto(nRegNVY))
							RecLock("NVY",.F.)
							NVY->NVY_VALOR  := nTotalDesp
							NVY->NVY_CODPAI := ""
							NVY->NVY_DESDIV := "2"
							NVY->(MsUnlock())

							//Grava na fila de sincronização a alteração
							J170GRAVA("NVY", xFilial("NVY") + NVY->NVY_COD, "4")

							If Posicione("NVY",1,xFilial("NVY")+cCodPai,"NVY_SITUAC") == "1" // "Pai Pendente"
								For nX := 2 To Len(aRecnos)
									NVY->(DbGoto(aRecnos[nX]))

									If NVY->NVY_CPREFT <> cPreFatPai
										If !Empty(NVY->NVY_CPREFT)
											Aadd(aPreFilho, {NVY->NVY_CPREFT, NVY->NVY_COD, NVY->NVY_CCASO})
										Else
											Aadd(aDPSemPre , {"", NVY->NVY_COD, NVY->NVY_CCASO})
										EndIf
									EndIf

									RecLock("NVY",.F.)
									NVY->(DbDelete())
									NVY->(MsUnlock())

									//Grava na fila de sincronização a alteração
									J170GRAVA("NVY", xFilial("NVY") + NVY->NVY_COD, "5")
								Next nX

								lCanPre := .F.

								cTextoExc := ""
								For nX := 1 To Len(aPreFilho)
									If JurLancPre( aPreFilho[nX,1] ) < 1
										nRegAtu := NX0->(Recno())
										NX0->(DbSetOrder(1)) // NX0_FILIAL+NX0_COD+NX0_SITUAC
										NX0->(dbSeek(xFilial('NX0') + aPreFilho[nX,1]))
										cTextoExc += STR0079 + aPreFilho[nX,2] + CRLF +;  // "- Despesa Agrupada: "
										STR0085 + Alltrim(aPreFilho[nX,1])+; // " O caso está vinculado a pré-fatura "
										STR0086 + AllTrim(JurSitGet(NX0->NX0_SITUAC))+". "+; // " com situação "
										STR0087 + AllTrim(JurSitGet("8"))+"." + CRLF+; // " A pré-fatura terá a situação atualizada para " ### Alterada
										Replicate("-",80) + CRLF
										NX0->(DbGoto(nRegAtu))

										JA202CANPF( aPreFilho[nX,1] )  //  Após excluir as despesas, se não existir lançamentos na pré-fatura, esta deve ser cancelada.
										J202HIST('5', aPreFilho[nX,1], cPartLog )//Insere o Histórico na pré-fatura
										lCanPre := .T.
									Else
										Aadd(aPreAlter ,{aPreFilho[nX,1], aPreFilho[nX,2], aPreFilho[nX,3]}) // Pré-faturas que foram alteradas
									EndIf
								Next

								// Atualizar pré-fatura da despesas Pai e monta a mensagem
								cTextoMsg := ""
								nRegAtu := NX0->(Recno())
								NX0->(DbSetOrder(1)) // NX0_FILIAL+NX0_COD+NX0_SITUAC
								If NX0->(dbSeek(xFilial('NX0') + cPreFatPai))  //Validação do dbseek com IF para o caso de não existir pre-fatura pai
									cTextoMsg := STR0078 + cDespOrigem + CRLF +;  // "- Despesa de Origem: "
									STR0085 + Alltrim(cPreFatPai)+; // " O caso está vinculado a pré-fatura "
									STR0086 + AllTrim(JurSitGet(cSitPrePai))+". "+; // " com situação "
									STR0087 + AllTrim(JurSitGet("3"))+"." + CRLF +;// " A pré-fatura terá a situação atualizada para ### "Alterada
									Replicate("-",80) + CRLF
									cTextoMsg += " " + CRLF

									cNx0SitAnt := NX0->NX0_SITUAC
									RecLock("NX0",.F.)
									NX0->NX0_SITUAC := '3' // Situação "Alterada".
									NX0->NX0_USRALT := cPartLog
									NX0->NX0_DTALT  := date()
									NX0->(MsUnlock())

									If cNx0SitAnt != '3'
										J202HIST('99', NX0->NX0_COD, cPartLog, I18N(STR0115, {cDespOrigem})) // "Agrupamento da despesa '#1'."
									EndIf
								EndIf

								NX0->(DbGoto(nRegAtu))

								// Monta mensagem com as despesas que não estão vinculadas a nenhuma pré-fatura.
								For nX := 1 To Len(aDPSemPre)
									cTextoMsg += STR0079 + aDPSemPre[nX,2] + CRLF +; // "- Despesa Agrupada: "
									STR0083 + CRLF+; // "Esta despesa não está vinculada a nenhuma pré-fatura."
									Replicate("-",80) + CRLF
								Next
								cTextoMsg += " " + CRLF

								// Posicionar nas pré-faturas das despesas filhas, alterar e montar mensagem.
								cTextoAlt := ""
								nRegAtu := NX0->(Recno())
								NX0->(DbSetOrder(1)) // NX0_FILIAL+NX0_COD+NX0_SITUAC
								For nX := 1 To Len(aPreAlter)
									NX0->(dbSeek(xFilial('NX0') + aPreAlter[nX,1]))
									If cCodPre == aPreAlter[nX,1]
										cTextoAlt += STR0079 + aPreAlter[nX,2] + CRLF +; // "- Despesa Agrupada: "
										STR0085 + Alltrim(aPreAlter[nX,1])+; // " O caso está vinculado a pré-fatura "
										STR0086 + AllTrim(JurSitGet(cSitPreFilho))+". "+; // " com situação "
										STR0087 + AllTrim(JurSitGet("3"))+"." + CRLF+; // " A pré-fatura terá a situação atualizada para " ### Alterada
										Replicate("-",80) + CRLF
									Else
										cTextoAlt += STR0079 + aPreAlter[nX,2] + CRLF +; // "- Despesa Agrupada: "
										STR0085 + Alltrim(aPreAlter[nX,1])+; // " O caso está vinculado a pré-fatura "
										STR0086 + AllTrim(JurSitGet(NX0->NX0_SITUAC))+". "+; // " com situação "
										STR0087 + AllTrim(JurSitGet("3"))+"." + CRLF +; // " A pré-fatura terá a situação atualizada para " ### Alterada
										Replicate("-",80) + CRLF
									EndIf

									cNx0SitAnt := NX0->NX0_SITUAC
									RecLock("NX0",.F.)
									NX0->NX0_SITUAC := '3' // Situação "Alterada".
									NX0->NX0_USRALT := cPartLog
									NX0->NX0_DTALT  := date()
									NX0->(MsUnlock())

									If cNx0SitAnt != '3'
										J202HIST('99', NX0->NX0_COD, cPartLog, I18N(STR0116, {cDespOrigem, aPreAlter[nX,2]})) // "Agrupamento entre as despesas '#1' e '#2'."
									EndIf
								Next
								NX0->(DbGoto(nRegAtu))

								If ! Empty(cTextoAlt)
									cTextoMsg += cTextoAlt + CRLF
								EndIf

								If ! Empty(cTextoExc)
									cTextoMsg += cTextoExc + CRLF
								EndIf

								JurErrLog(STR0026 + CRLF +" "+ CRLF+ cTextoMsg, STR0084) // "Agrupamento de Despesas"

							Else
								DisarmTransaction() // Nesta linha já foi realizado uma gravação. Esta gravação precisa ser desfeita devido a condição.
								MsgAlert(STR0025)  // "Não é possível executar esta ação, pois a despesa pai já foi faturada."
							EndIf

						END TRANSACTION

					EndIf
				EndIf
			Else
				MsgStop(cMensagem)
			EndIf
		Else
			JurMsgErro(STR0064) // "Não foi possível realizar as alterações, o lançamento possui pré-fatura em Definifivo!"
		EndIf

	Else
		MsgStop(STR0021) // "Opção permitida apenas para Despesas divididas e que sejam filhas."
	EndIf
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JA49FilDes
Gatilho para preencher a descricao da despesa baseada no idioma do caso.
Campo que dispara esse gatilho:NVY_CTPDSP

@author Rodrigo Antonio Godinho da Silva
@since 30/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA49FilDes(lInicPadrao)
Local oModel   := Nil
local cIdNVY   := ""
Local cClient  := ""
Local cLoja    := ""
Local cCaso    := ""
Local cIdio    := ""
Local cRet     := ""
Local cCodDsp  := ""

Default lInicPadrao := .F.

If lInicPadrao
	cClient  := NVY->NVY_CCLIEN
	cLoja    := NVY->NVY_CLOJA
	cCaso    := NVY->NVY_CCASO
	cCodDsp  := NVY->NVY_CTPDSP
Else
	oModel   := FWModelActive()
	cIdNVY   := IIf( IsInCallStack( 'JURA202' ), "NVYDETAIL", "NVYMASTER" )
	cClient  := oModel:GetValue(cIdNVY,"NVY_CCLIEN")
	cLoja    := oModel:GetValue(cIdNVY,"NVY_CLOJA")
	cCaso    := oModel:GetValue(cIdNVY,"NVY_CCASO")
	cCodDsp  := oModel:GetValue(cIdNVY,"NVY_CTPDSP")
Endif

If cIdNVY == "NVYDETAIL"
	cIdio := oModel:GetValue('NX1DETAIL', 'NX1_CIDIO')
Else
	cIdio := Posicione('NVE', 1, xFilial('NVE') + cClient + cLoja + cCaso, 'NVE_CIDIO')
EndIf

If !Empty(cIdio)
	cRet := AllTrim(Posicione('NR4', 3, xFilial("NR4") + cCodDsp + cIdio, 'NR4_DESC'))
	If NR4->(ColumnPos('NR4_TXTPAD')) > 0 .And. !Empty(NR4->NR4_TXTPAD) // Proteção
		cRet := NR4->NR4_TXTPAD
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA49VLGRP
Gatilho para validar se o grupo tem relacionamento com o cliente
(caso esteja preenchido)
Campo que dispara esse gatilho:NVY_CGRUPO

@author Edvin Markstein Zimmermann
@since 24/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA49VLGRP()
Local lRet := .T.

If !Empty(M->NVY_CCLIEN)
	lRet := SA1->A1_GRPVEN == M->NVY_CGRUPO
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA49WCLI()
Função para validar o When do campo NVY_CCASO

@author Luciano Pereira dos Santos
@since 29/10/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA49VLCLI()
Local lRet     := .F.
Local oModel   := FWModelActive()
Local cIdNVY   := Iif(oModel:GetId() == "JURA202", "NVYDETAIL", "NVYMASTER")
Local cClien   := oModel:GetValue(cIdNVY, "NVY_CCLIEN")
Local cLoja    := oModel:GetValue(cIdNVY, "NVY_CLOJA")
Local cJcaso   := GETMV("MV_JCASO1",, '1')  //1 – Por Cliente; 2 – Independente de cliente

If cJcaso == "1"
	If !Empty(cClien) .And. !Empty(cLoja)
		lRet := .T.
	EndIf
ElseIf cJcaso == "2"
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA49VLNVE
Gatilho preencher o campo NVY_DCASO
Campo que dispara esse gatilho: NVY_CCASO

@author Luciano Pereira dos Santos
@since 15/09/11
@version 1.1
/*/
//-------------------------------------------------------------------
Function JA49VLNVE( cField )
Local cRet    := ""
Local oModel  := FWModelActive()
Local aArea   := GetArea()
Local cCaso   := oModel:GetValue("NVYMASTER", "NVY_CCASO")
Local cClien  := oModel:GetValue("NVYMASTER", "NVY_CCLIEN")
Local cLoja   := oModel:GetValue("NVYMASTER", "NVY_CLOJA")

If !Empty(cClien) .And. !Empty(cLoja) .And. !Empty(cCaso)
	dbSelectArea("NVE")
	NVE->(dbSetOrder(1))
	If NVE->(dbSeek(xFilial("NVE") + cClien + cLoja + cCaso))
		cRet := NVE->NVE_TITULO
	EndIf
EndIf

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA49CASO()
Função para limpar campo caso (NVY_CCASO) através de gatilho
@author Edvin Markstein Zimmermann
@since 03/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA49CASO()
Local cRet := .f.

If Empty(M->NVY_CCLIEN)
	cRet := ""
Else
	cRet := M->NVY_CCASO
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA49CPART()
Função para validar se o participante existe e se está ativo

@author Edvin Markstein Zimmermann
@since 05/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA49CPART()
Local oModel     := FWModelActive()
Local oModelGrid := Nil
Local cPart      := ''
Local cRet       := ''

dbSelectArea("RD0")

If IsInCallStack( 'JURA202' )
	oModelGrid := oModel:GetModel("NVYDETAIL")
	cPart      := oModelGrid:GetValue("NVY_CPART")
Else
	cPart      := oModel:GetValue("NVYMASTER", "NVY_CPART")
EndIf

If !Empty(cPart)

	RD0->(dbSetOrder(1))
	If !RD0->(dbSeek(xFilial("RD0") + cPart))
		MsgAlert(STR0036) //"Código de participante inválido"
	Else
		If RD0->RD0_MSBLQL != "2"
			MsgAlert(STR0037) //"Código de participante inativo"
		Else
			cRet := RD0->RD0_NOME
		EndIf
	EndIf

EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA49CTPDSP()
Função para validar se o participante existe e se está ativo
@author Edvin Markstein Zimmermann
@since 05/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA49CTPDSP()
Local cRet := JA49FilDes(.F.)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049F3NRH()
Função de F3 da NRH (Tipo de Despesa)

@author Edvin Markstein Zimmermann
@since 05/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA049F3NRH()
Local cIdNRH := IIf( IsInCallStack( 'JURA202' ), "NVYDETAIL", "NVYMASTER" )

If !IsInCallStack( 'JA143DLG' )
	lRet := JURF3NRH(cIdNRH, "NVY_CCLIEN", "NVY_CLOJA", "NVY_CCASO", .F.)
Else
	lRet := JURF3NRH(Nil, cCliOr, cLojaOr, cCasoOr, .T.)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURF3NRH
Monta a consulta padrão tipo despesa
Uso Geral.
@param 	cMaster 	Nome da estrutura do modelo de dados
		cCpClien 	Nome do campo de cliente do cadastro utilizado
		cCpLoja 	Nome do campo de loja
		cCpCaso 	Nome do campo de caso
		lLote		Verifica se a consulta foi chamada da tela de lote de despesas (JURA143)

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample
Consulta padrão específica NRH2

@author Edvin Markstein Zimmermannn
@since 10/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURF3NRH(cMaster, cCpClien, cCpLoja, cCpCaso,lLote)
Local lRet     := .F.
Local aArea    := GetArea()
Local cQuery   := ""
Local oModel   := Nil
Local cClien   := ""
Local cLoja    := ""
Local cCaso    := ""

If lLote
	cClien   := cCpClien
	cLoja    := cCpLoja
	cCaso    := cCpCaso
Else
	oModel   := FWModelActive()
	cClien   := oModel:GetValue(cMaster, cCpClien)
	cLoja    := oModel:GetValue(cMaster, cCpLoja)
	cCaso    := oModel:GetValue(cMaster, cCpCaso)
EndIf

cQuery := JQRYNVENRH(cClien, cLoja, cCaso, "1")
cQuery := ChangeQuery(cQuery, .F.)

uRetorno := ''

RestArea( aArea )

If JurF3Qry( cQuery, 'JURNRC', 'NRHRECNO', @uRetorno,, {"NRH_COD", "NR4_DESC"} )
	NRH->( dbGoto( uRetorno ) )
	lRet := .T.
EndIf

Return lRet

Function JQRYNVENRH(cClien, cLoja, cCaso, cAtiv, cCod)
Local cQuery   := ""
Local cIdioma  := Posicione('NVE', 1, xFilial('NVE') + cClien + cLoja + cCaso, 'NVE_CIDIO')

Default cCod   := ""

cQuery := " SELECT NRH.NRH_COD, NR4.NR4_DESC, NR4.NR4_CIDIOM, NRH.R_E_C_N_O_ NRHRECNO"
cQuery +=   " FROM " + RetSqlName("NRH") + " NRH, " // TIPO DE DESPESA
cQuery +=        " " + RetSqlName("NR4") + " NR4 "  // DESC TP DESP POR IDIOMA
cQuery +=  " WHERE NRH.NRH_FILIAL = '" + xFilial( "NRH" ) + "'"
cQuery +=    " AND NR4.NR4_FILIAL = '" + xFilial( "NR4" ) + "'"
cQuery +=    " AND NRH.D_E_L_E_T_ = ' ' "
cQuery +=    " AND NR4.D_E_L_E_T_ = ' ' "
cQuery +=    " AND NRH.NRH_ATIVO = '" + cAtiv + "' "
cQuery +=    " AND NR4.NR4_CTDESP = NRH.NRH_COD "
cQuery +=    " AND NR4.NR4_CIDIOM = '" + cIdioma + "' "
If !Empty(cCod)
	cQuery += " AND NRH.NRH_COD = '" + cCod + "' "
EndIf
cQuery +=    " AND NR4.NR4_CIDIOM IN ( SELECT NVE.NVE_CIDIO "
cQuery +=                              " FROM " + RetSqlName("NVE") + " NVE " // CASO
cQuery +=                             " WHERE NVE.NVE_FILIAL = '" + xFilial("NVE") + "'"
cQuery +=                               " AND NVE.D_E_L_E_T_ = ' '"
cQuery +=                               " AND NVE.NVE_CCLIEN = '" + cClien + "' " // CLIENTE
cQuery +=                               " AND NVE.NVE_NUMCAS = '" + cCaso  + "' " // GRUPO
cQuery +=                               " AND NVE.NVE_LCLIEN = '" + cLoja  + "' " // LOJA
cQuery +=                          " ) "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049NVE
Rotina para consulta padrão de caso , considerando o parâmetro dias de encerramento do caso e as permissões do participante logado.
Uso Geral.

@param 	cMaster  	Nome do master
@param  cGrupo		Nome do campo de cliente
@param  cCliente	Nome do campo de cliente
@param  cLoja	    Nome do campo de loja
@param  cLan	    Filtro para tipos de lançamentos

@Return cRet	 		Comando para filtro

@sample
@#JA144NVE('NUEMASTER','NUE_CGRPCL','NUE_CCLIEN','NUE_CLOJA') //Não pode ter espaços

@author Edvin Markstein Zimmermann
@since 012/03/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA049NVE(cMaster, cGrupo, cCliente, cLoja, cLan)
Local cRet      := "@#@#"

cRet := JANVELANC(cMaster, cGrupo, cCliente, cLoja, cLan)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049AM
Função que alterar o campo de ano-mês

@Return cRet	 		Ano-Mês

@author Fabio Crespo Arruda
@since 11/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA049AM()
Local oModel := FWModelActive()
Local cModel := IIf( IsJura202(), "NVYDETAIL", "NVYMASTER" )
Local dData  := oModel:GetValue(cModel, 'NVY_DATA')
Local cAM    := ' '

cAM := AnoMes(dData)

Return cAM

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049DESC
Função que exibe as descrições no Browse
Melhoria de performance na tela de abertura da pré-fatura

@Param  cCampo    Campo a ser tratado

@Return cRet	 		Descrição

@author Luciano Pereira dos Santos
@since 27/01/2017
@version 2.0
/*/
//-------------------------------------------------------------------
Function JA049DESC(cCampo)
Local cRet      := ""
Local oModel    := Nil
Local oModelNX1 := Nil

Do Case
Case cCampo == "NVY_DGRUPO"
	If !Empty(NVY->NVY_CGRUPO)
		cRet := POSICIONE('ACY', 1, XFILIAL('ACY') + NVY->NVY_CGRUPO, 'ACY_DESCRI')
	EndIf

Case cCampo == "NVY_DCLIEN"
	oModel    := FWModelActive()
	If oModel != Nil .And. oModel:GetId() == "JURA202"
		oModelNX1 := oModel:GetModel('NX1DETAIL')
		cRet      := oModelNX1:GetValue('NX1_DCLIEN')
	Else
		cRet := POSICIONE('SA1', 1, xFilial('SA1') + NVY->NVY_CCLIEN + NVY->NVY_CLOJA, 'A1_NOME')
	EndIf

Case cCampo == "NVY_DCASO"
	oModel    := FWModelActive()
	If oModel != Nil .And. oModel:GetId() == "JURA202"
		oModelNX1 := oModel:GetModel('NX1DETAIL')
		cRet      := oModelNX1:GetValue('NX1_DCASO')
	Else
		cRet := POSICIONE('NVE', 1, xFilial('NVE') + NVY->NVY_CCLIEN + NVY->NVY_CLOJA + NVY->NVY_CCASO, 'NVE_TITULO')
	EndIf

EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049VERPRE
Rotina para validar se existe pré-fatura para a Despesa.

@author Jacques Alves Xavier
@since 03/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA049VERPRE(cCodPre, oModel)
Local lRet     := .T.
Local cPartLog := JurUsuario(__CUSERID)
Local cStruct  := ""
Local lCobra   := .T.
Local lPrefPai := .F.
Local lCanc    := .F.
Local lIsRest  := JurIsRest()

Default cCodPre := NVY->NVY_CPREFT

If oModel == Nil
	lCobra   := NVY->NVY_COBRAR == "1"
Else
	If oModel:GetId() == 'JURA202'
		cStruct := 'NVYDETAIL'
	Else 
		cStruct := 'NVYMASTER'
	EndIF
	lCobra   := oModel:GetValue(cStruct, 'NVY_COBRAR') == "1"
EndIF

If Empty(cCodPre) .And. !Empty(NVY->NVY_CODPAI)
	cCodPre  := JurGetDados("NVY", 1, xFilial("NVY") + NVY->NVY_CODPAI, "NVY_CPREFT")
	lPrefPai := .T.
EndIf

If !Empty(cPartLog)

	If !Empty(cCodPre)
		If (JurGetDados("NUR", 1, xFilial("NUR") + cPartLog, "NUR_LCPRE") == "1")
			If NX0->(dbSeek(xFilial('NX0') + cCodPre))
				If NX0->NX0_SITUAC $ '2|3|D|E' .Or. (NX0->NX0_SITUAC == "C" .And. lIsRest)
					If !lPrefPai .And. !lCobra
						If oModel == Nil
							RecLock("NVY", .F.)
							NVY->NVY_CPREFT := ''
							NVY->(MsUnlock())

							//Grava na fila de sincronização a alteração
							J170GRAVA("NVY", xFilial("NVY") + NVY->NVY_COD, "4")
							lRet := .T.
						Else
							lRet := oModel:LoadValue(cStruct, 'NVY_CPREFT', '')
						EndIf

						If lRet
							JACanVinc('DP', cCodPre, NVY->NVY_COD, .T.)

							//Grava na fila de sincronização
							J170GRAVA("NVY", xFilial("NVY") + NVY->NVY_COD, "4")

							If JurLancPre( cCodPre ) <= 1  // Verifica se era o último lançamento da pré para cancelar
								If JA202CANPF( cCodPre )
									J202HIST('5', cCodPre, cPartLog )//Insere o Histórico na pré-fatura
									If oModel:GetId() != 'JURA202' .And. !IsInCallStack("JURA143")
										ApMsgInfo(I18N(STR0088, {cCodPre}))
									Else
										AutoGrLog(I18N(STR0088+CRLF, {cCodPre}))  //# "A pré-fatura #1 foi cancelada por não conter mais lançamentos."
									EndIf
									lCanc := .T.
								EndIf
							EndIf
						EndIf
					EndIf
				ElseIf NX0->NX0_SITUAC == '6' // Minuta Emitida
					lRet := J49VerAltM(oModel:GetModel(cStruct))
					If (!lRet)
						JurMsgErro(STR0073, , JMsgVerPre('1')) // "Não foi possível realizar as alterações, o lançamento possui Minuta!"
					EndIf
				ElseIf NX0->NX0_SITUAC $ '5|7|9|A|B' //Emitir Minuta | Minuta Emitida | Minuta Cancelada | Minuta Sócio | Minuta Sócio Emitida | Minuta Sócio Cancelada
					lRet := JurMsgErro(STR0073, , JMsgVerPre('1')) // "Não foi possível realizar as alterações, o lançamento possui Minuta!"

				ElseIf NX0->NX0_SITUAC == '4' //Definifivo
					lRet := JurMsgErro(STR0064, , JMsgVerPre('1')) // "Não foi possível realizar as alterações, o lançamento possui pré-fatura em Definifivo!"

				ElseIf NX0->NX0_SITUAC $ 'C|F' .And. Iif(FindFunction("JurIsRest"), !JurIsRest(), .T.) // Em Revisão | Aguardando Sincronização - permitir o ajuste quando partir do REST
					lRet := JurMsgErro(STR0103, , JMsgVerPre('1')) // "Não foi possível realizar as alterações, o lançamento possui pré-fatura em processo de Revisão!"

				EndIf

			EndIf
		Else
			lRet := JurMsgErro(STR0065, , JMsgVerPre('2')) // "O participante não tem permissão para alterar despesas com Pré-faturas."
		EndIF
	Else
		If !lCobra
			JACanVinc('DP', cCodPre, NVY->NVY_COD, .T.)
		EndIF
	EndIf
Else
	lRet := JurMsgErro(STR0066, , JMsgVerPre('3')) //"O usuário logado não esta relacionado a nenhum participante! Verifique."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J49VerAltM(oModelNVY)
Verifica os campos que foram alterados

@param oModelNVY - Modelo da Despesa 

@author Willian Kazahaya
@since 26/01/2022
/*/
//-------------------------------------------------------------------
Static Function J49VerAltM(oModelNVY)
Return JVldAltMdl(oModelNVY, 1, {"NVY_DESCRI"})

//-------------------------------------------------------------------
/*/{Protheus.doc} JA49Cobrar
Rotina para validar a cobranca da  despesa.verificando todos os casos vinculados aos contratos
utilizada no gatilho do campo NVY_CTPDSP
@author Paulo Borges
@since 10-12-10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA49Cobrar(lPadrao)
Local oModel    := FWModelActive()
Local cIdNVY    := IIf( oModel:GetId() == 'JURA202', "NVYDETAIL", "NVYMASTER" )
Local cClient   := NVY->NVY_CCLIEN
Local cLoja     := NVY->NVY_CLOJA
Local cCaso     := NVY->NVY_CCASO
Local cCtpDsp   := NVY->NVY_CTPDSP
Local cContrato := ''
Local xValue    := '2'
Local aArea     := GetArea()
Local aAreaNRH  := NRH->(GetArea())
Local aAreaNTK  := NTK->(GetArea())
Local aNUT      := {}
Local nNUT      := 0

If !lPadrao
	cClient := oModel:GetValue(cIdNVY, "NVY_CCLIEN")
	cLoja   := oModel:GetValue(cIdNVY, "NVY_CLOJA")
	cCaso   := oModel:GetValue(cIdNVY, "NVY_CCASO")
	cCtpDsp := oModel:GetValue(cIdNVY, "NVY_CTPDSP")
EndIf

NRH->(DbSetOrder(1))
If NRH->(DbSeek(xFilial("NRH") + cCtpDsp))
	xValue := NRH->NRH_COBRAR
EndIf

If xValue <> '2'

	//Verifica todos os contratos amarrados ao caso
	NUT->(DbSetOrder(2))   //NUT_FILIAL+NUT_CCLIEN+NUT_CLOJA+NUT_CCASO
	NUT->(DbSeek(xFilial("NUT") + cClient + cLoja + cCaso))

	While NUT->( NUT_CCLIEN + NUT_CLOJA + NUT_CCASO ) == cClient + cLoja + cCaso .And. ! NUT->(Eof() )
		Aadd(aNUT, NUT->NUT_CCONTR)
		NUT->(dbskip())
	EndDo

	If !Empty(aNUT)
		For nNUT := 1 To Len(aNUT)
			cContrato := aNUT[nNUT]
			//Varre todos os contrato vinculados ao caso e verifica se cobra a despesa
			NT0->(DbSetOrder(1))   //CONTRATO
			NT0->(DbSeek(xFilial("NT0") + cContrato ))

			If NT0->NT0_DESPES == '1'   //COBRAR DESPESA
				NTK->(DbSetOrder(1)) // NTK_FILIAL+NTK_CCONTR+NTK_CTPDSP
				If NTK->(DbSeek(xFilial("NTK") + cContrato + cCtpDsp))
					xValue   := "2" // Nao Cobravel
				EndIf
				Exit
			EndIf
		Next
	EndIf
EndIf

RestArea(aAreaNTK)
RestArea(aAreaNRH)
RestArea(aArea)

Return xValue

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049CM
Executa rotina ao comitar as alterações no Model

@Param oModel    - Modelo de dados de Despesa
@Param aVlCpoLD  - Array com os campos e valores referente ao ação LD

@author David G. Fernandes
@since 13/02/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA049CM(oModel, aVlCpoLD)
Local lRet       := .T.
Local aCampos    := {}
Local cIdNVY     := IIf( oModel:GetId() == 'JURA202', "NVYDETAIL", "NVYMASTER" )
Local oModelNVY  := oModel:GetModel(cIdNVY)
Local cCodDP     := oModelNVY:GetValue('NVY_COD')
Local cClient    := oModelNVY:GetValue('NVY_CCLIEN')
Local cLoja      := oModelNVY:GetValue('NVY_CLOJA')
Local cCaso      := oModelNVY:GetValue('NVY_CCASO')
Local cPrefat    := oModelNVY:GetValue('NVY_CPREFT')
Local lCobra     := (oModelNVY:GetValue('NVY_COBRAR') == '1' .And. oModelNVY:GetValue('NVY_SITUAC') == '1')
Local nOperation := oModel:GetOperation()
Local lLote      := JPELancLote("JURA049", nOperation) //Ponto de entrada que define se é um processamento em lote
Local lShowMsg   := !lLote

If nOperation != 5
	//Verifica se houve alteração no caso para ajustar / excluir a pré
	If cClient + cLoja + cCaso != NVY->(NVY_CCLIEN + NVY_CLOJA + NVY_CCASO) .OR. oModelNVY:GetValue("NVY_ACAOLD") == "1"

		JAALTCASO(cPrefat, cIdNVY, "NVY", cCodDP, cClient, cLoja, cCaso, oModel)
		// Ajusta Flags na trasnferência via Legal Desk do novo caso, contrato e pré-fatura
		If FindFunction("JURFlagLD")
			JURFlagLD(oModel, "NVY", "NVZ")
		EndIf
	EndIf

	//Limpar os campos de operação do Legal Desk
	If FindFunction("JurClearLD")
		aVlCpoLD := JurClearLD(oModel, cIdNVY, "NVY") //Limpar os campos de operação do Legal Desk
	EndIf

	If JurIsRest()
		JA49VLDCB(oModelNVY:GetValue("NVY_USRNCB"), .T., oModel)
	EndIf
EndIf

aAdd(aCampos,{NVY->NVY_CCLIEN, cClient})
aAdd(aCampos,{NVY->NVY_CLOJA,  cLoja})
aAdd(aCampos,{NVY->NVY_CCASO,  cCaso})
aAdd(aCampos,{NVY->NVY_DATA,   oModelNVY:GetValue('NVY_DATA')})
aAdd(aCampos,{NVY->NVY_CPREFT, oModelNVY:GetValue('NVY_CPREFT')}) // Necessário refazer o GetValue aqui pois a função JAALTCASO limpa esse campo dependendo da situação

JurShowPf('NVY', 'DP', nOperation, aCampos, oModelNVY:GetValue('NVY_CTPDSP'), lCobra, cCodDP, lShowMsg) //Informa se o DP esta sendo tirada/colocada em um caso que possui pré-fatura

If !Empty(cPrefat) .And. (nOperation == 5 .Or. !lCobra)
	//Verifica se há outros lançamentos na pré-fatura para cancelá-la se necessário
	If (JurLancPre( cPrefat ) <= 1)
		JA202CANPF( cPrefat )
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  J049VlDDP()
Função para o Validar a Data da Despesa na pré-fatura.

@author Jacques Alves Xavier
@since 18/12/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function J049VlDDP()
Local lRet      := .T.
Local oModel    := FWModelActive()
Local cIdNVY    := IIf( IsInCallStack( 'JURA202' ), "NVYDETAIL", "NVYMASTER" )
Local cAnoMes   := " "
Local dDataDP   := CToD( '  /  /  ' )
Local dDtIniDP  := CToD( '  /  /  ' )
Local dDtFimDP  := CToD( '  /  /  ' )
Local cClien    := oModel:GetValue(cIdNVY, 'NVY_CCLIEN')
Local cLoja     := oModel:GetValue(cIdNVY, 'NVY_CLOJA' )
Local cCaso     := oModel:GetValue(cIdNVY, 'NVY_CCASO' )
Local aArea     := GetArea()
Local aAreaNX0  := NX0->(GetArea())

dDataDP  := oModel:GetValue(cIdNVY, "NVY_DATA")
cAnoMes  := JSToFormat(DToS(dDataDP), 'YYYYMM')

If IsJura202() .And. oModel:GetId() == "JURA202"
	dDtIniDP := oModel:GetValue("NX0MASTER", "NX0_DINIDP")
	dDtFimDP := oModel:GetValue("NX0MASTER", "NX0_DFIMDP")

	If (dDataDP < dDtIniDP) .or. (dDataDP > dDtFimDP)
		lRet := JurMsgErro(STR0071, , STR0072) //## "A data esta fora do período de emissão da Pré-Fatura!" ### "Retire a Despesa da pré-fatura e altere sua data na tela de Despesas."
	EndIf
EndIf

//Valida  a existência de Fatura Adicional faturada cujo período de referência englobe a data do Lançamento
If lRet .And. FindFunction("JurBlqLnc") //PROTEÇÃO
	lRet := JurBlqLnc( cClien, cLoja, cCaso, dDataDP, "DEP") //Retorna de se deve bloquear
EndIf

RestArea(aAreaNX0)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  JCall143()
Função chamar a rotina JURA143 sem carregar as configurações de botão do XNU.

@author Jacques Alves Xavier
@since 21/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCall143()
Local cAceAnt  := AcBrowse
Local cFunName := FunName()

	// JAX/Ernani: A linha abaixo serve liberar o acesso aos botões da Browse, para não manter a regra da tela JURA049 inserida no XNU.
	AcBrowse := Replicate("x", 10)
	SetFunName( 'JURA143' ) // Isto serve para o filtro de tela ter sua própia configuração na JURA143

	JURA143()

	SetFunName( cFunName )
	AcBrowse := cAceAnt

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J049GtlObs
Gatilho preencher o campo Observação NVY_OBS

@author Bruno Ritter
@since 20/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J049GtlObs()
Local oModel    := FWModelActive()
Local cIdNVY    := IIf( oModel:GetId() == 'JURA202', "NVYDETAIL", "NVYMASTER" )
Local aFields   := {{'NVY_CGRUPO',STR0013},{'NVY_CCLIEN',STR0014},{'NVY_CLOJA',STR0015},{'NVY_CCASO',STR0016},{'NVY_CTPDSP',STR0017}}
Local cMessage  := ""
Local nX        := 0
Local xValue    := Nil
Local xOldValue := Nil
Local cSigla    := ""

Default cPart  := JurUsuario(__cUserID)

If oModel:GetOperation() == MODEL_OPERATION_UPDATE
	For nX := 1 To Len(aFields)
		xOldValue := NVY->(&(aFields[nX][1]))
		xValue    := oModel:GetValue(cIdNVY, aFields[nX][1])
		cSigla  := JurGetDados("RD0", 1, xFilial("RD0") + cPart, "RD0_SIGLA")
		If !(Alltrim(xOldValue) == Alltrim(xValue)) .And. !Empty(xValue)
			cMessage += aFields[nX][2] + STR0018 + Alltrim(xOldValue) + STR0019 + Alltrim(xValue) + CRLF //"Antes", "Depois"
		EndIf
	Next nX
	If !Empty(cMessage)
		cMessage := FWTimeStamp(2) + " - " + STR0020 + cSigla + CRLF + cMessage + CRLF//"Usuário"
		cMessage := cMessage + M->NVY_OBS
	EndIf
EndIf

Return cMessage

//-------------------------------------------------------------------
/*/{Protheus.doc} J049VldCli
Validação dos campos: Grupo, Cliente e Loja

@Return   lRet  .T. ou .F.

@author Bruno Ritter
@since 20/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J049VldCli()
Local lRet    := .T.
Local oModel  := FWModelActive()
Local cIdNVY  := IIf( oModel:GetId() == 'JURA202', "NVYDETAIL", "NVYMASTER" )
Local cGrupo  := ''
Local cClien  := ''
Local cLoja   := ''
Local cCaso   := ''
Local dDataLC := CToD( '  /  /  ' )
Local cCampo  := AllTrim(__ReadVar)

	cGrupo  := oModel:GetValue(cIdNVY, "NVY_CGRUPO")
	dDataLC := oModel:GetValue(cIdNVY, 'NVY_DATA'  )

	If (cCampo == "M->NVY_CCLIEN") .Or. (cCampo == "M->NVY_CLOJA") .Or. (cCampo == "M->NVY_CCASO") .Or. (cCampo == "M->NVY_DATA")
		cClien  := oModel:GetValue(cIdNVY, "NVY_CCLIEN")
		cLoja   := oModel:GetValue(cIdNVY, "NVY_CLOJA" )
		cCaso   := oModel:GetValue(cIdNVY, "NVY_CCASO" )
	Else
		cClien  := oModel:GetValue(cIdNVY, "NVY_CCLILD")
		cLoja   := oModel:GetValue(cIdNVY, "NVY_CLJLD" )
		cCaso   := oModel:GetValue(cIdNVY, "NVY_CCSLD" )
	EndIf

	If cCampo == "M->NVY_CGRUPO"
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "GRP")

	ElseIf cCampo == "M->NVY_CCLIEN" .Or. cCampo == "M->NVY_CCLILD"
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "CLI")

	ElseIf cCampo == "M->NVY_CLOJA" .Or. cCampo == "M->NVY_CLJLD"
		lRet := JurVldCli(cGrupo, cClien, cLoja,,, "LOJ")

	ElseIf cCampo == "M->NVY_CCASO" .Or. cCampo == "M->NVY_CCSLD" .Or. cCampo == "M->NVY_DATA"
		lRet := JurVldCli(cGrupo, cClien, cLoja, cCaso, "NVE_LANDSP", "CAS",,, dDataLC)

	EndIf

	//Valida  a existência de Fatura Adicional faturada cujo período de referência englobe a data do Lançamento
	If lRet .AND. cCampo != "M->NVY_CGRUPO"
		lRet := JurBlqLnc(cClien, cLoja, cCaso, dDataLC, "DEP") //Retorna de se deve bloquear
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J049ClxGr()
Rotina para verificar se o cliente/loja pertence ao grupo.
Usado nos gatilhos de Grupo

@Return - lRet  .T. quando o cliente PERTENCE ao grupo informado OU
                .F. quando o cliente NÃO pertence ao grupo informado

@author Bruno Ritter
@since 04/01/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function J049ClxGr()
Local lRet    := .T.
Local oModel  := FWModelActive()
Local cIdNVY  := IIf( oModel:GetId() == 'JURA202', "NVYDETAIL", "NVYMASTER" )
Local cGrupo  := ''
Local cClien  := ''
Local cLoja   := ''

cGrupo  := oModel:GetValue(cIdNVY, "NVY_CGRUPO")
cClien  := oModel:GetValue(cIdNVY, "NVY_CCLIEN")
cLoja   := oModel:GetValue(cIdNVY, "NVY_CLOJA")

If FindFunction("JurClxGr") //PROTEÇÃO
	lRet := JurClxGr(cClien, cLoja, cGrupo)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J049ClxCa()
Rotina para verificar se o cliente/loja pertece ao caso.
Utilizado para condição de gatilho

@Return - lRet  .T. quando o cliente PERTENCE ao caso informado OU
                .F. quando o cliente NÃO pertence ao caso informado

@author Bruno Ritter
@since 09/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J049ClxCa()
Local lRet    := .F.
Local oModel  := FWModelActive()
Local cIdNVY  := IIf( oModel:GetId() == 'JURA202', "NVYDETAIL", "NVYMASTER" )
Local cClien  := ""
Local cLoja   := ""
Local cCaso   := ""

cClien  := oModel:GetValue(cIdNVY, "NVY_CCLIEN")
cLoja   := oModel:GetValue(cIdNVY, "NVY_CLOJA")
cCaso   := oModel:GetValue(cIdNVY, "NVY_CCASO")

If FindFunction("JurClxGr") //PROTEÇÃO
	lRet := JurClxCa(cClien, cLoja, cCaso)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA049COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA049COMMIT FROM FWModelEvent
	Data oModelDesd // Modelo para replicar as alterações da despesa no desdobramento e desdobramento pós-pagamento.
	Data oModelLanc // Modelo para replicar as alterações da despesa no Lançamento.
	Data oTmpAcaoLD // Tabela temporária para vínculo do lançamento na Pré via LD
	Data aVlCpoLD   // Array com os campos e valores referente ao ação LD

	Method New()
	Method FieldPreVld()
	Method ModelPosVld()
	Method BeforeTTS()
	Method InTTS()
	Method DeActivate()
	Method Destroy()
End Class

Method New() Class JA049COMMIT
	Self:oModelDesd := Nil
	Self:oModelLanc := Nil
	Self:oTmpAcaoLD := Nil
	Self:aVlCpoLD   := {}
Return

Method Destroy() Class JA049COMMIT
	Self:oModelDesd := Nil
	Self:oModelLanc := Nil
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FieldPreVld
Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field

@param oSubModel , Modelo principal
@param cModelId  , Id do submodelo
@param nLine     , Linha do grid
@param cAction   , Ação executada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cCamp     , nome do campo
@param xValue    , Novo valor do campo

@author bruno.ritter
@since 20/12/2018
/*/
//-------------------------------------------------------------------
Method FieldPreVld(oSubModel, cModelId, cAction, cCamp, xValue) Class JA049COMMIT
	Local lRet       := .T.
	Local nOperation := oSubModel:GetOperation()
	Local lIntFinanc := SuperGetMV("MV_JURXFIN",,.F.) // Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
	Local lOrigJ241  := FwIsInCallStack("J241OpDesp") // Quando a origem da operação for da JURA241(Lançamento)
	Local lOrigJ246  := FwIsInCallStack("J246OpDesp") // Quando a origem da operação for da JURA246(Desdobramento)
	Local lOrigJ247  := FwIsInCallStack("J247OpDesp") // Quando a origem da operação for da JURA247(Desdobramento pós pagamento)

	If !lIsLancOk .And. cModelId == "NVYMASTER" .And. nOperation == MODEL_OPERATION_UPDATE
		If cCamp != "NVY_DESCRI"
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. lIntFinanc .And. !lOrigJ241 .And. !lOrigJ246 .And. !lOrigJ247
		If cCamp $ "NVY_DATA|NVY_CMOEDA|NVY_VALOR"
			lRet := .F.
		EndIf
	EndIf

Return lRet

Method ModelPosVld(oModel, cModelID) Class JA049COMMIT
	Local lRet    := .T.

	Self:oModelDesd  := Nil
	Self:oModelLanc  := Nil

	If ValType(Self:oTmpAcaoLD) == "O"
		Self:oTmpAcaoLD:Destroy()
		Self:oTmpAcaoLD := Nil
	EndIf

	lRet := JA049OK(oModel, @Self:oModelDesd, @Self:oModelLanc, @Self:oTmpAcaoLD)

Return lRet

Method BeforeTTS(oSubModel, cModelId) Class JA049COMMIT
	JA049CM(oSubModel:GetModel(), @Self:aVlCpoLD)
Return

Method InTTS(oSubModel, cModelId) Class JA049COMMIT
	If FindFunction( "JVincLanLD")
		JVincLanLD(oSubModel:GetModel("NVYMASTER"), "NVY", Self:oTmpAcaoLD, Self:aVlCpoLD) // Vínculo da despesa pelo Ação LD
	EndIf

	JFILASINC(oSubModel:GetModel(), "NVY", "NVYMASTER", "NVY_COD")

	If !Empty(Self:oModelDesd)
		Processa ( {||J049CMLanc(Self:oModelDesd)}, STR0098, STR0099)// "Gravando." "Replicando dados da despesa..."
	EndIf
	If !Empty(Self:oModelLanc)
		Processa ( {||J049CMLanc(Self:oModelLanc)}, STR0098, STR0099)// "Gravando." "Replicando dados da despesa..."
	EndIf

Return

Method DeActivate() Class JA049COMMIT
	If ValType(Self:oTmpAcaoLD) == "O"
		Self:oTmpAcaoLD:Delete()
	EndIf
	Self:oTmpAcaoLD := Nil
	JurFreeArr(@Self:aVlCpoLD)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J049RepLan(oModel)
Replica as alterações na despesa para o lançamento

@param oModel    => Modelo ativo

@Return oModelLanc Retorna o modelo preparado da OHB

@author ricardo.neves/bruno.ritter
@since 11/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J049RepLan(oModel)
	Local aAreaOHB   := OHB->(GetArea())
	Local oModelLanc := Nil
	Local oModelOHB  := Nil
	Local cIdNVY     := IIF(oModel:GetId() == 'JURA202', "NVYDETAIL", "NVYMASTER")
	Local oModelNVY  := oModel:GetModel(cIdNVY)
	Local cCodDesp   := oModelNVY:GetValue('NVY_COD')
	Local cCodLanc   := oModelNVY:GetValue("NVY_CLANC")
	Local cPagto     := oModelNVY:GetValue('NVY_CPAGTO') // Somente quando é desdobramento
	Local cFilLanc   := J049FilOri(cPagto, cCodDesp, cCodLanc)
	Local aErro      := {}

	If Empty(cCodLanc)
		cCodLanc := J049GetLanc(cCodDesp, cFilLanc)
	EndIf

	If !Empty(cCodLanc)
		OHB->(DbSetOrder(1)) // OHB_FILIAL+OHB_CODIGO
		If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. OHB->(DbSeek(cFilLanc + cCodLanc))
			oModelLanc := FWLoadModel("JURA241")
			oModelLanc:SetOperation(MODEL_OPERATION_UPDATE)
			oModelLanc:Activate()

			oModelOHB := oModelLanc:GetModel("OHBMASTER")
			oModelOHB:SetValue("OHB_CCLID ", oModelNVY:GetValue("NVY_CCLIEN"))
			oModelOHB:SetValue("OHB_CLOJD ", oModelNVY:GetValue("NVY_CLOJA" ))
			oModelOHB:SetValue("OHB_CCASOD", oModelNVY:GetValue("NVY_CCASO" ))
			oModelOHB:SetValue("OHB_CPART ", oModelNVY:GetValue("NVY_CPART" ))
			oModelOHB:SetValue("OHB_CTPDPD", oModelNVY:GetValue("NVY_CTPDSP"))
			oModelOHB:SetValue("OHB_QTDDSD", oModelNVY:GetValue("NVY_QTD"   ))
			oModelOHB:SetValue("OHB_COBRAD", oModelNVY:GetValue("NVY_COBRAR"))
			oModelOHB:SetValue("OHB_HISTOR", oModelNVY:GetValue("NVY_DESCRI"))

			If oModelLanc:HasErrorMessage()
				aErro := oModelLanc:GetErrorMessage()
				JurMsgErro(STR0105 + CRLF + aErro[6],, aErro[7]) //"Erro ao atualizar lançamento:"
				oModelLanc := Nil

			ElseIf !oModelLanc:VldData()
				aErro := oModelLanc:GetErrorMessage()
				JurMsgErro(STR0105 + CRLF + aErro[6],, aErro[7]) //"Erro ao atualizar lançamento:"
				oModelLanc := Nil
			EndIf
		EndIf
	EndIf

	RestArea(aAreaOHB)

Return oModelLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} J049RepDsb(oModel)
Replica as alterações na despesa para o desdobramento

@param oModel    => Modelo ativo

@Return oModelDesb Retorna o modelo preparado da OHF

@author abner.oliveira
@since 04/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J049RepDsb(oModel)
	Local lRet       := .T.
	Local aArea      := GetArea()
	Local aAreaSE2   := SE2->(GetArea())
	Local aAreaOHF   := OHF->(GetArea())
	Local aAreaOHG   := OHG->(GetArea())
	Local oModelDesb := Nil
	Local oModelOHF  := Nil
	Local oModelOHG  := Nil
	Local cIdNVY     := IIf( oModel:GetId() == 'JURA202', "NVYDETAIL", "NVYMASTER" )
	Local oModelNVY  := oModel:GetModel(cIdNVY)
	Local aErro      := {}
	Local cChaveSE2  := StrTran(oModelNVY:GetValue("NVY_CPAGTO"), "|", "")
	Local cTpDesdob  := Iif(Empty(oModelNVY:GetValue("NVY_ITDES")), "P", "F") // "P" = Pós Pagamento e "F" = Financeiro

	SE2->(DbSetOrder(1))     // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. SE2->(DbSeek( cChaveSE2 ))

		If cTpDesdob == "F"
			oModelDesb := FWLoadModel("JURA246")
			oModelDesb:SetOperation(MODEL_OPERATION_UPDATE)
		Else
			oModelDesb := FWLoadModel("JURA247")
			oModelDesb:SetOperation(MODEL_OPERATION_UPDATE)
		EndIf

		If oModelDesb:CanActivate()
			oModelDesb:Activate()

			If cTpDesdob == "F"
				oModelOHF := oModelDesb:GetModel("OHFDETAIL")
				If oModelOHF:SeekLine({ {"OHF_CITEM", oModelNVY:GetValue("NVY_ITDES")} })
					oModelOHF:SetValue("OHF_CCLIEN", oModelNVY:GetValue("NVY_CCLIEN"))
					oModelOHF:SetValue("OHF_CLOJA" , oModelNVY:GetValue("NVY_CLOJA" ))
					oModelOHF:SetValue("OHF_CCASO" , oModelNVY:GetValue("NVY_CCASO" ))
					oModelOHF:SetValue("OHF_SIGLA" , oModelNVY:GetValue("NVY_SIGLA" ))
					oModelOHF:SetValue("OHF_CTPDSP", oModelNVY:GetValue("NVY_CTPDSP"))
					oModelOHF:SetValue("OHF_QTDDSP", oModelNVY:GetValue("NVY_QTD"   ))
					oModelOHF:SetValue("OHF_COBRA ", oModelNVY:GetValue("NVY_COBRAR"))
					oModelOHF:SetValue("OHF_HISTOR", oModelNVY:GetValue("NVY_DESCRI"))
				Else
					lRet := .F.
				EndIf
			Else
				oModelOHG := oModelDesb:GetModel("OHGDETAIL")
				If oModelOHG:SeekLine({ {"OHG_CITEM", oModelNVY:GetValue("NVY_ITDPGT")} })
					oModelOHG:SetValue("OHG_CCLIEN", oModelNVY:GetValue("NVY_CCLIEN"))
					oModelOHG:SetValue("OHG_CLOJA" , oModelNVY:GetValue("NVY_CLOJA" ))
					oModelOHG:SetValue("OHG_CCASO" , oModelNVY:GetValue("NVY_CCASO" ))
					oModelOHG:SetValue("OHG_SIGLA" , oModelNVY:GetValue("NVY_SIGLA" ))
					oModelOHG:SetValue("OHG_CTPDSP", oModelNVY:GetValue("NVY_CTPDSP"))
					oModelOHG:SetValue("OHG_QTDDSP", oModelNVY:GetValue("NVY_QTD"   ))
					oModelOHG:SetValue("OHG_COBRA ", oModelNVY:GetValue("NVY_COBRAR"))
					oModelOHG:SetValue("OHG_HISTOR", oModelNVY:GetValue("NVY_DESCRI"))
				Else
					lRet := .F.
				EndIf
			EndIf
		Else
			lRet := .F.
		EndIf

		If !lRet .Or. oModelDesb:HasErrorMessage()
			aErro := oModelDesb:GetErrorMessage()
			JurMsgErro(STR0106+CRLF+aErro[6],,aErro[7]) // "Erro ao atualizar desdobramento:"
			oModelDesb := Nil

		ElseIf !oModelDesb:VldData()
			aErro := oModelDesb:GetErrorMessage()
			JurMsgErro(STR0106+CRLF+aErro[6],,aErro[7]) // "Erro ao atualizar desdobramento:"
			oModelDesb := Nil
		EndIf
	EndIf

	RestArea(aAreaOHG)
	RestArea(aAreaOHF)
	RestArea(aAreaSE2)
	RestArea(aArea)

Return oModelDesb

//-------------------------------------------------------------------
/*/{Protheus.doc} J049CMLanc(oModelRepl)
Efetua o commit das alterações no lançamento.

@param oModelRepl Modelos da OHB, OHG ou OHF.

@author bruno.ritter ricardo.neves
@since 11/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J049CMLanc(oModelRepl)
	ProcRegua( 0 )
	IncProc()
	IncProc()
	IncProc()

	oModelRepl:CommitData()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049GerDp(oModel, nOperDesp)
Função para replicar os dados gerados no financeiro para uma Despesa

@param oModel     => Modelo ativo
@param nOperDesp  => Operacao para a Despesa (1=INSERT;2=UPDATE;3=DELETE)

@Return oModelNVY => Gerar um model NVY pronto para se excutado o commit

@author bruno.ritter
@since 04/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA049GerDp(nOperDesp, cCodDesp, cCliente, cLoja, cCaso, dData, cSigla, cTipoDesp, nQtdDesp, cCobrar, cHist, cMoeda, nValor, cCobraOld, cCodLanc, cCodPagto, cItemDesp, cItemPosPg)
	Local aAreaNVY     := NVY->(GetArea())
	Local oModelDesp   := Nil
	Local oModelNVY    := Nil
	Local aErro        := {}
	Local aRetCmpErr   := {}
	Local cRetError    := ""
	Local nI           := 1
	Local lRet         := .T.
	Local cPartSigla   := ""

	Default cCobraOld  := CriaVar("NVY_COBRAR")
	Default cCodLanc   := CriaVar("NVY_CLANC")
	Default cCodPagto  := CriaVar("NVY_CPAGTO")
	Default cItemDesp  := CriaVar("NVY_ITDES")
	Default cItemPosPg := CriaVar("NVY_ITDPGT")

	NVY->(DbSetOrder(1)) // NVY_FILIAL+NVY_COD
	If nOperDesp == MODEL_OPERATION_INSERT .Or. NVY->(DbSeek(xFilial("NVY") + cCodDesp))
		oModelDesp := FWLoadModel("JURA049")
		oModelDesp:SetOperation(nOperDesp)
		oModelDesp:Activate()

		If nOperDesp != MODEL_OPERATION_DELETE
			oModelNVY := oModelDesp:GetModel("NVYMASTER")

			lRet :=            JA049SetVl(oModelNVY, "NVY_CCLIEN" , cCliente  , @aRetCmpErr)
			lRet := lRet .And. JA049SetVl(oModelNVY, "NVY_CLOJA"  , cLoja     , @aRetCmpErr)
			lRet := lRet .And. JA049SetVl(oModelNVY, "NVY_CCASO"  , cCaso     , @aRetCmpErr)
			lRet := lRet .And. JA049SetVl(oModelNVY, "NVY_DATA"   , dData     , @aRetCmpErr)
			lRet := lRet .And. JA049SetVl(oModelNVY, "NVY_SIGLA"  , cSigla    , @aRetCmpErr)
			lRet := lRet .And. JA049SetVl(oModelNVY, "NVY_CTPDSP" , cTipoDesp , @aRetCmpErr)
			lRet := lRet .And. JA049SetVl(oModelNVY, "NVY_QTD"    , nQtdDesp  , @aRetCmpErr)
			lRet := lRet .And. JA049SetVl(oModelNVY, "NVY_COBRAR" , cCobrar   , @aRetCmpErr)
			lRet := lRet .And. JA049SetVl(oModelNVY, "NVY_DESCRI" , cHist     , @aRetCmpErr)
			lRet := lRet .And. JA049SetVl(oModelNVY, "NVY_CMOEDA" , cMoeda    , @aRetCmpErr)
			lRet := lRet .And. JA049SetVl(oModelNVY, "NVY_VALOR"  , nValor    , @aRetCmpErr)
			lRet := lRet .And. JA049SetVl(oModelNVY, "NVY_CLANC"  , cCodLanc  , @aRetCmpErr)
			lRet := lRet .And. JA049SetVl(oModelNVY, "NVY_CPAGTO" , cCodPagto , @aRetCmpErr)
			lRet := lRet .And. JA049SetVl(oModelNVY, "NVY_ITDES"  , cItemDesp , @aRetCmpErr)
			lRet := lRet .And. JA049SetVl(oModelNVY, "NVY_ITDPGT" , cItemPosPg, @aRetCmpErr)

			If cCobrar == "2" .And. (nOperDesp == MODEL_OPERATION_INSERT .Or. cCobraOld == "1")
				cPartSigla := AllTrim(JurGetDados("RD0",1,xFilial("RD0")+JurUsuario(__cUserId), "RD0_SIGLA"))
				JA049SetVl(oModelNVY, "NVY_OBSCOB", I18n(STR0104, {cPartSigla}), @aRetCmpErr)// "Despesa gerada como não cobrável pela sigla do participante: '#1'."
			EndIf
		EndIf

		If !Empty(aRetCmpErr)
			cRetError := STR0097+CRLF //"Erro ao atualizar despesa:"
			cRetError += CRLF+"--------------------"+CRLF + STR0109 + CRLF //"Detalhes técnicos:"
			cRetError += I18n(STR0107,{oModelNVY:GetValue("NVY_COD")})+CRLF //"Existem restrições de edição na despesa '#1', os campos abaixo não podem ser alterados:"
			For nI := 1 To Len(aRetCmpErr)
				cRetError += "'"+aRetCmpErr[nI]+"', "
			Next nI
			cRetError := Left(cRetError, Len(cRetError)-2)+CRLF

			JurMsgErro(cRetError,,STR0108)//"Verifique a despesa para maiores detalhes."
			oModelDesp := Nil

		ElseIf oModelDesp:HasErrorMessage()
			aErro := oModelDesp:GetErrorMessage()

			JurMsgErro(STR0097,,Alltrim(aErro[7])) //"Erro ao atualizar despesa:"
			oModelDesp := Nil

		ElseIf !oModelDesp:VldData()
			aErro := oModelDesp:GetErrorMessage()

			JurMsgErro(STR0097,,Alltrim(aErro[7])) //"Erro ao atualizar despesa:"
			oModelDesp := Nil
		EndIf
	EndIf

	RestArea(aAreaNVY)

Return oModelDesp

//-------------------------------------------------------------------
/*/{Protheus.doc} JA049SetVl(oModelNVY, cCampo, xValue, @aRetCmpErr)
Função para validar o setValue dos campos para replicar o desdobramento para a despesa.

@param oModelNVY   => Modelo da NVY
@param cCampo      => Campo para setar o valor
@param xValue      => Valor para ser inserido no campo
@param @aRetCmpErr => Array para armazenar os campos que foram alterados que não poder ser alterados.

@Return Nil        => O valor do retorno será armazenado na váriavel aRet

@author bruno.ritter
@since 09/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA049SetVl(oModelNVY, cCampo, xValue, aRetCmpErr)
Local lRet := .T.

	If oModelNVY:GetValue(cCampo) != xValue
		If !(oModelNVY:CanSetValue(cCampo) .And. oModelNVY:SetValue(cCampo, xValue))
			lRet := .F.
			aAdd(aRetCmpErr, AllTrim(RetTitle(cCampo)))
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J049FilOri
Retorna a filial do desdobramento, desdobramento-pós ou lançamento
que orignou a despesa.

@param   cPagto  , Chave do título a pagar vinculado ao desdob/desdob-pós
@param   cCodDesp, Código da despesa
@param   cCodLanc, Código do lançamento

@Return  cFilOri, Filial do desdobramento/lançamento que originou a despesa

@author  bruno.ritter
@since   13/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J049FilOri(cPagto, cCodDesp, cCodLanc)
	Local cAlsTmp    := ""
	Local cQuery     := ""
	Local cFilOri    := ""

	Default cPagto   := ""
	Default cCodDesp := ""
	Default cCodLanc := ""

	If !Empty(cPagto)
		cFilOri := Left(cPagto, TamSX3("NVY_FILIAL")[1])
	Else
		If !Empty(cCodDesp)
			If NVY->(ColumnPos("NVY_FILLAN")) > 0
				cFilOri := JurGetDados("NVY", 1, xFilial("NVY") + cCodDesp, "NVY_FILLAN")
			EndIf
			If Empty(cFilOri)
				cAlsTmp := GetNextAlias()

				cQuery := "SELECT OHB_FILIAL "
				cQuery += "FROM " + RetSqlName("OHB") + " OHB "
				cQuery += "WHERE OHB.OHB_CDESPD = '" + cCodDesp + "' "
				If !Empty(cCodLanc)
					cQuery += "AND OHB.OHB_CODIGO = '" + cCodLanc + "' "
				EndIf
				cQuery += "AND OHB.D_E_L_E_T_ = ' ' "

				DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cAlsTmp, .T., .T.)

				If (cAlsTmp)->(!Eof())
					cFilOri := (cAlsTmp)->OHB_FILIAL
				EndIf
				(cAlsTmp)->(DbCloseArea())
			EndIf
		EndIf
	EndIf

Return (cFilOri)

//-------------------------------------------------------------------
/*/{Protheus.doc} J049GetLanc()
Retorna a o código do lançamento gerado pelo desdobramento que orignou
a despesa.

@param cCodDesp  Codigo da despesa
@param cFilLanc  Codigo da filial do lançamento
@param cTipo     Tipo de desdobramento do lançamento retornado
                 por referencia: "D"- Desdobramento;
                 "P"- Desdobramento Pós-pagamento

@Return cCodLanc  Codigo do lançamento do desdobramento

@author Luciano Pereira dos Santos / Queizy Nascimento
@since 26/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J049GetLanc(cCodDesp, cFilLanc, cTipo)
	Local aArea      := GetArea()
	Local cQuery     := ""
	Local cQueryRes  := GetNextAlias()
	Local cItSpace   := Space(TamSX3("OHB_ITDES")[1])
	Local cCodLanc   := ""

	Default cCodDesp := ""
	Default cFilLanc := ""
	Default cTipo    := ""

	cQuery := " SELECT OHB.OHB_CODIGO, "
	cQuery +=       " (CASE WHEN OHB_ITDES > '" + cItSpace + "' THEN 'D' ELSE 'P' END) TIPO "
	cQuery += " FROM " + RetSqlName('OHB') + " OHB "
	cQuery += " INNER JOIN " + RetSqlName('NVY') + " NVY "
	cQuery +=         " ON (NVY.NVY_FILIAL = '" + xFilial("NVY") + "' "
	cQuery +=         " AND NVY.NVY_COD = '" + cCodDesp + "' "
	cQuery +=         " AND NVY.D_E_L_E_T_ = ' ') "
	cQuery += " INNER JOIN " + RetSqlName('FK7') + " FK7 "
	cQuery +=         " ON (FK7.FK7_FILIAL = '" + cFilLanc + "' "
	cQuery +=         " AND FK7.FK7_CHAVE = NVY.NVY_CPAGTO "
	cQuery +=         " AND FK7.D_E_L_E_T_ = ' ') "
	cQuery += " LEFT JOIN " + RetSqlName('OHF') + " OHF "
	cQuery +=         " ON (OHF.OHF_FILIAL = FK7.FK7_FILIAL "
	cQuery +=         " AND OHF.OHF_IDDOC = FK7.FK7_IDDOC "
	cQuery +=         " AND OHF.OHF_CITEM = NVY.NVY_ITDES "
	cQuery +=         " AND OHF.D_E_L_E_T_ = ' ') "
	cQuery += " LEFT JOIN  " + RetSqlName('OHG') + " OHG "
	cQuery +=       " ON (OHG.OHG_FILIAL = FK7.FK7_FILIAL "
	cQuery +=       " AND OHG.OHG_IDDOC = FK7.FK7_IDDOC "
	cQuery +=       " AND OHG.OHG_CITEM = NVY.NVY_ITDPGT "
	cQuery +=       " AND OHG.D_E_L_E_T_ = ' ') "
	cQuery +=     " WHERE OHB.OHB_FILIAL = FK7.FK7_FILIAL "
	cQuery +=       " AND OHB.OHB_CPAGTO = FK7.FK7_CHAVE "
	cQuery +=       " AND OHB.OHB_ITDES = NVY.NVY_ITDES "
	cQuery +=       " AND OHB.OHB_ITDPGT = NVY.NVY_ITDPGT "
	cQuery +=       " AND OHB.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cQueryRes, .T., .F.)

	If !(cQueryRes)->(EOF())
		cCodLanc := (cQueryRes)->OHB_CODIGO
		cTipo    := (cQueryRes)->TIPO
	EndIf
	(cQueryRes)->(DbCloseArea())

	RestArea(aArea)

Return cCodLanc
