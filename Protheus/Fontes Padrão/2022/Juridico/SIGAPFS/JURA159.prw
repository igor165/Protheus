#INCLUDE "JURA159.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/ { Protheus.doc } JURA159
Cadastro de Participantes

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA159()
Local oBrowse
Local aAreaSXV := SXV->(GetArea())

	oBrowse := FWmBrowse():New()
	oBrowse:SetDescription( STR0007)
	oBrowse:SetAlias("RD0")
	oBrowse:SetLocate()
	JurSetLeg(oBrowse, "RD0")
	JurSetBSize(oBrowse)
	J159Filter(oBrowse) // Adiciona filtros padrões no browse

	//Verifica se tem integração Mashup
	SXV->(DbSetOrder(2)) //XV_ALIAS + XV_MASHUP
	If SXV->(DbSeek("RD0"))
		AddMashupAlias({"RD0"})
	EndIf
	RestArea(aAreaSXV)

	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J159Filter
Adiciona filtros padrões no browse

@param  oBrowse, objeto, browse da rotina

@author Reginaldo Borges
@since  08/08/2022
/*/
//-------------------------------------------------------------------
Static Function J159Filter(oBrowse)
Local aFilRD01 := {}
Local aFilRD02 := {}
Local aFilRD03 := {}

	SAddFilPar("RD0_SIGLA", "$", "%RD0_SIGLA0%", @aFilRD01)
	oBrowse:AddFilter(STR0073, 'UPPER("%RD0_SIGLA0%") $ UPPER(RD0_SIGLA)', .F., .F., , .T., aFilRD01, STR0073) // "Sigla"

	SAddFilPar("RD0_NOME", "$", "%RD0_NOME0%", @aFilRD02)
	oBrowse:AddFilter(STR0074, 'ALLTRIM("%RD0_NOME0%") $ RD0_NOME', .F., .F., , .T., aFilRD02, STR0074) // "Nome"

	SAddFilPar("RD0_CC", "==", "%RD0_CC0%", @aFilRD03)
	oBrowse:AddFilter(STR0075, 'RD0_CC == "%RD0_CC0%"', .F., .F., , .T., aFilRD03, STR0075) // "Centro de Custo"

Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } MenuDef
Menu Funcional

@Return aRotina - Estrutura
[n, 1] Nome a aparecer no cabecalho
[[n, 2] Nome da Rotina associada
[n, 3] Reservado
[n, 4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n, 5] Nivel de acesso
[n, 6] Habilita Menu Funcional

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA159", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA159", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA159", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA159", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA159", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/ { Protheus.doc } ModelDef
Modelo de dados de Participante

@author David Gonçalves Fernandes
@since 28/04/09
@version 1.0

@obs RD0MASTER - Dados do Participante
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oStructRD0  := NIL
Local oStructNUR  := NIL
Local oStructNUS  := NIL
Local oStructNTX  := NIL
Local oStructNSS  := NIL
Local oStructNVM  := NIL
Local oStructFIL  := NIL
Local oModel      := NIL
Local oCommit     := JA159COMMIT():New()
Local lJurxFin    := SuperGetMV("MV_JURXFIN",,.F.) // Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
Local aAreaSXV    := SXV->( GetArea() )
Local lFornAt     := NUR->(ColumnPos("NUR_FORNAT")) > 0
Local lIntegrPFS  := SuperGetMV("MV_JFTJURI",, "2" ) == "1"//Se a integração estiver Habilitada

oStructRD0 := FWFormStruct( 1, "RD0" )
oStructNUR := FWFormStruct( 1, "NUR" )

If lIntegrPFS .OR. nModulo == 77
	oStructNUS := FWFormStruct( 1, "NUS" )
	oStructNTX := FWFormStruct( 1, "NTX" )
	oStructNSS := FWFormStruct( 1, "NSS" )
	oStructNVM := FWFormStruct( 1, "NVM" )
	If lFornAt
		oStructFIL := FWFormStruct( 1, "FIL" )
	EndIf
EndIf

If nModulo == 77 .And. NSS->(ColumnPos("NSS_CESCR")) > 0 // Proteção // Somente SIGAPFS

	// Cria os campos virtuais de escritório na área das informações de participante
	J159InCpoM(@oModel,@oStructRD0)

	// Indica o campo de escritório como obrigatório somente se o centro de custo do participante for obrigatório no dicionário
	oStructRD0:SetProperty("RD0__CESCR", MODEL_FIELD_OBRIGAT, x3Obrigat( PadR( "RD0_CC", 10 ) ))

	// Altera o valid do campo de centro de custo para filtro por escritório
	oStructRD0:SetProperty("RD0_CC", MODEL_FIELD_VALID, {|oModel, cCampo, cValor| JVldCTTMdl('RD0__CESCR', cValor, .T. /* lValBloq */) })
	oStructNUS:SetProperty("NUS_CC", MODEL_FIELD_VALID, {|oModel, cCampo, cValor| JVldCTTMdl('NUS_CESCR' , cValor, .F. /* lValBloq */) }) // Histórico não valida CC bloqueado

	// Inclui gatilho para apagar centro de custo quando alterar o escritório somente quando integração com financeiro estiver ativa
	If lJurxFin
		oStructRD0:AddTrigger('RD0__CESCR','RD0_CC'    , {|| .T. } , {|| "" } )
		oStructRD0:AddTrigger('RD0__CESCR','RD0_DESCCC', {|| .T. } , {|| "" } )
	EndIf

	// Inclui gatilho para Fornecedor e loja
	If lFornAt
		oStructRD0:SetProperty("RD0_SIGLA", MODEL_FIELD_VALID, {|oModelRD0, cCampo, cValor| J159Clilj(oModelRD0:GetModel(), "RD0_SIGLA") })
	EndIf

	oStructNUS:AddTrigger('NUS_CESCR' ,'NUS_CC'    , {|| .T. } , {|| "" } )

	// Incluí gatilho para que o campo seja preenchido corretamente, além de limpar caso o campo esteja vazio
	oStructRD0:AddTrigger('RD0_CC','RD0_DESCCC', {|| .T. } , {|oModel, cCampo, cValor| POSICIONE("CTT", 1, xFilial("CTT") + cValor, "CTT_DESC01") } )

EndIf

//Verifica se tem integração Mashup
//Força um tamanho maior para os campos serem atualizados pelo mashup
SXV->( DbSetOrder(2) )	//XV_ALIAS + XV_MASHUP
If SXV->( DbSeek("RD0") )
	oStructRD0:SetProperty("RD0_END"   , MODEL_FIELD_TAMANHO, 80)
	oStructRD0:SetProperty("RD0_BAIRRO", MODEL_FIELD_TAMANHO, 50)
EndIf
RestArea(aAreaSXV)

If lFornAt //Proteção
	If !lJurxFin
		oStructNUR:SetProperty( 'NUR_FORNAT', MODEL_FIELD_INIT   , {|| "2"} )
		oStructNUR:SetProperty( 'NUR_FORNAT', MODEL_FIELD_OBRIGAT, .F.      )
	Else
		oStructNUR:SetProperty( 'NUR_FORNAT', MODEL_FIELD_VALID, {|oModelNUR, cCampo, cValor| J159Clilj(oModelNUR:GetModel(), "NUR_FORNAT") })
	EndIf
EndIf

oModel := MPFormModel():New( "JURA159", /*Pre-Validacao*/,  /*Pos-Validacao*/, /*Commit*/, /*Cancel*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados do Participantes"

oModel:AddFields( "RD0MASTER",             /*cOwner*/, oStructRD0, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddFields( "NURDETAIL", "RD0MASTER" /*cOwner*/, oStructNUR )

If lIntegrPFS .OR. nModulo == 77
	oModel:AddGrid( "NUSDETAIL", "RD0MASTER" /*cOwner*/, oStructNUS, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, { |oGrid| LoadNusNvm(oGrid,"NUS_AMINI",oModel) } )
	oModel:AddGrid( "NTXDETAIL", "RD0MASTER" /*cOwner*/, oStructNTX, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
	oModel:AddGrid( "NSSDETAIL", "RD0MASTER" /*cOwner*/, oStructNSS, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
	oModel:AddGrid( "NVMDETAIL", "RD0MASTER" /*cOwner*/, oStructNVM, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, { |oGrid| LoadNusNvm(oGrid,"NVM_AMINI", oModel) } )
	If lFornAt
		oModel:AddGrid( "FILDETAIL", "RD0MASTER" /*cOwner*/, oStructFIL, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
	EndIf
EndIf

oModel:GetModel( "RD0MASTER" ):SetDescription( STR0009 ) //Cadastro do Participante"
oModel:GetModel( "NURDETAIL" ):SetDescription( STR0010 ) //"Dados do Participante"

oModel:SetRelation( "NURDETAIL", { { "NUR_FILIAL", "xFilial( 'NUR' )" } , { "NUR_CPART", "RD0_CODIGO" } } , NUR->( IndexKey( 1 ) ) )

If lIntegrPFS .OR. nModulo == 77
	oModel:GetModel( "NUSDETAIL" ):SetDescription( STR0011 ) //"Histórico do Participante"
	oModel:GetModel( "NTXDETAIL" ):SetDescription( STR0012 ) //"Ausências"
	oModel:GetModel( "NSSDETAIL" ):SetDescription( STR0013 ) //"Rateio entre Centros de Custo"
	oModel:GetModel( "NVMDETAIL" ):SetDescription( STR0014 ) //"Histórico do Rateio entre Centros de Custo"
	If lFornAt
		oModel:GetModel( "FILDETAIL" ):SetDescription( STR0059 ) //"Bancos"
	EndIf

	oModel:GetModel( "NUSDETAIL" ):SetUniqueLine( { "NUS_AMINI" } )

	If NSS->(ColumnPos("NSS_CESCR")) > 0 // Proteção
		oModel:GetModel( "NSSDETAIL" ):SetUniqueLine( { "NSS_CESCR", "NSS_CC" } )
	Else
		oModel:GetModel( "NSSDETAIL" ):SetUniqueLine( { "NSS_CC" } )
	EndIf

	If NVM->(ColumnPos("NVM_CESCR")) > 0 // Proteção
		oModel:GetModel( "NVMDETAIL" ):SetUniqueLine( { "NVM_CESCR", "NVM_CC", "NVM_AMINI" } )
	Else
		oModel:GetModel( "NVMDETAIL" ):SetUniqueLine( { "NVM_CC", "NVM_AMINI" } )
	EndIf

	oModel:GetModel( "NUSDETAIL" ):SetDelAllLine( .T. )
	oModel:GetModel( "NTXDETAIL" ):SetDelAllLine( .T. )
	oModel:GetModel( "NSSDETAIL" ):SetDelAllLine( .T. )
	oModel:GetModel( "NVMDETAIL" ):SetDelAllLine( .T. )
	If lFornAt
		oModel:GetModel( "FILDETAIL" ):SetDelAllLine( .T. )
	EndIf

	oModel:SetRelation( "NUSDETAIL", { { "NUS_FILIAL", "xFilial( 'NUS' )" } , { "NUS_CPART", "RD0_CODIGO" } } , NUS->( IndexKey( 1 ) ) )
	oModel:SetRelation( "NTXDETAIL", { { "NTX_FILIAL", "xFilial( 'NTX' )" } , { "NTX_CPART", "RD0_CODIGO" } } , "NTX_FILIAL+NTX_CPART" )
	oModel:SetRelation( "NSSDETAIL", { { "NSS_FILIAL", "xFilial( 'NSS' )" } , { "NSS_CPART", "RD0_CODIGO" } } , "NSS_FILIAL+NSS_CPART" )
	oModel:SetRelation( "NVMDETAIL", { { "NVM_FILIAL", "xFilial( 'NVM' )" } , { "NVM_CPART", "RD0_CODIGO" } } , "NVM_FILIAL+NVM_CPART" )
	If lFornAt
		oModel:SetRelation( "FILDETAIL", { { "FIL_FILIAL", "xFilial( 'FIL' )" } , { "FIL_FORNEC", "RD0_FORNEC"}   , { "FIL_LOJA", "RD0_LOJA" } } , "FIL_BANCO+FIL_AGENCI+FIL_CONTA" )
	EndIf

	oModel:SetOptional( 'NUSDETAIL', .T.)
	oModel:SetOptional( 'NTXDETAIL', .T.)
	oModel:SetOptional( 'NSSDETAIL', .T.)
	oModel:SetOptional( 'NVMDETAIL', .T.)
	If lFornAt
		oModel:SetOptional( 'FILDETAIL', .T.)
	EndIf

	oModel:InstallEvent("JA159COMMIT", /*cOwner*/, oCommit)

	JurSetRules( oModel, 'NUSDETAIL',, 'NUS' )
	JurSetRules( oModel, 'NTXDETAIL',, 'NTX' )
	JurSetRules( oModel, 'NSSDETAIL',, 'NSS' )
	JurSetRules( oModel, 'NVMDETAIL',, 'NVM' )
Else
	J159CmpJur(@oStructNUR)//altera as propriedades de campos especificos para o cadastro feito pelo sigajuri
EndIF

//-- Validação do campo de sigla de participante
oStructRD0:SetProperty( "RD0_SIGLA", MODEL_FIELD_VALID,  {|oModel| JVldRD0Sgl( oModel:GetModel() ) })

JurSetRules( oModel, 'RD0MASTER',, 'RD0' )
JurSetRules( oModel, 'NURDETAIL',, 'NUR' )

oModel:SetActivate( { |oModel| JA159NUR( oModel ) } )

Return oModel

//-------------------------------------------------------------------
/*/ { Protheus.doc } ViewDef
View de dados de Tabela de Honorarios

@author David Gonçalves Fernandes

@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA159" )
Local lJurxFin   := SuperGetMV("MV_JURXFIN",,.F.) // Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico

Local oStructRD0 := Nil
Local oStructNUR := Nil
Local oStructNUS := Nil
Local oStructNTX := Nil
Local oStructNSS := Nil
Local oStructNVM := Nil
Local oStructFIL := Nil
Local lUsaHist   := SuperGetMV( 'MV_JURHS1',, .F. )
Local lFornAt    := NUR->(ColumnPos("NUR_FORNAT")) > 0
Local aCampsJur  := J159JurCmps()
Local lIntegrPFS := SuperGetMV("MV_JFTJURI",, "2" ) == "1"//Se a integração estiver desabilitada
Local lNatFech   := !Empty(SuperGetMV("MV_JNATFEP",,""))

If lIntegrPFS .OR. nModulo == 77
	oStructRD0 := FWFormStruct( 2, "RD0" )
	oStructNUR := FWFormStruct( 2, "NUR" )
	oStructNUS := FWFormStruct( 2, "NUS" )
	oStructNTX := FWFormStruct( 2, "NTX" )
	oStructNSS := FWFormStruct( 2, "NSS" )
	oStructNVM := FWFormStruct( 2, "NVM" )
	If lFornAt
		oStructFIL := FWFormStruct( 2, "FIL" )
	EndIf
Else
	oStructRD0 := FWFormStruct( 2, "RD0", { | cCampo | aScan(aCampsJur,Alltrim(cCampo)) > 0 } )
	oStructNUR := FWFormStruct( 2, "NUR", { | cCampo | aScan(aCampsJur,Alltrim(cCampo)) > 0 }  )
EndIf

If !lNatFech .And. NUR->(ColumnPos("NUR_NATURE")) > 0
	oStructNUR:RemoveField("NUR_NATURE")
	oStructNUR:RemoveField("NUR_DNATUR")
EndIf

If nModulo == 77 .And. NSS->(ColumnPos("NSS_CESCR")) > 0 // Proteção // Somente SIGAPFS

	// Cria os campos virtuais de escritório na área das informações de participante
	J159InCpoV(@oView,@oStructRD0)

	// Remove da view os campos de escritório na área das informações de complemento do participante
	oStructNUR:RemoveField( "NUR_CESCR" )
	oStructNUR:RemoveField( "NUR_DESCR" )

	// Altera a consulta padrão do campo de centro de custo para filtro por escritório
	oStructRD0:SetProperty('RD0_CC', MVC_VIEW_LOOKUP, 'CTTNS7' )
	oStructNUS:SetProperty('NUS_CC', MVC_VIEW_LOOKUP, 'CTTNS7' )

	// Altera a consulta padrão do campo de escritório para consulta de escritórios ativos
	oStructNUS:SetProperty('NUS_CESCR', MVC_VIEW_LOOKUP, 'NS7ATV' )

	// Altera a ordem do campo de Centro de Custo
	oStructNUS:SetProperty('NUS_CC', MVC_VIEW_ORDEM, GetSx3Cache('NUS_DESCR', 'X3_ORDEM') )

EndIf

If !lJurxFin .And. NUR->(ColumnPos("NUR_FORNAT")) > 0 //Proteção
	oStructNUR:RemoveField( "NUR_FORNAT" )
EndIf

//Remove os campos do filho que já estão no pai
oStructNUR:RemoveField( "NUR_CPART" )
//Remove campos não usados para o jurídico
oStructRD0:RemoveField( "RD0_BITMAP" )

If lIntegrPFS .OR. nModulo == 77

	//Remove os campos do filho que já estão no pai
	oStructNUS:RemoveField( "NUS_CPART" )
	oStructNTX:RemoveField( "NTX_CPART" )
	oStructNSS:RemoveField( "NSS_CPART" )
	//oStructNSS:RemoveField( "NSS_COD"   )
	oStructNVM:RemoveField( "NVM_CPART" )
	oStructNVM:RemoveField( "NVM_COD"   )

EndIf
//--------------------------------------------------------------
//Montagem do View normal se Container
//--------------------------------------------------------------
JurSetAgrp( 'RD0',, oStructRD0 )
JurSetAgrp( 'NUR',, oStructNUR )

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( "JURA159_RDO", oStructRD0, "RD0MASTER" )
oView:AddField( "JURA159_NUR", oStructNUR, "NURDETAIL" )

If lIntegrPFS .OR. nModulo == 77
	oView:AddGrid( "JURA159_NTX", oStructNTX, "NTXDETAIL" )
	oView:AddGrid( "JURA159_NSS", oStructNSS, "NSSDETAIL" )
	If lFornAt
		oView:AddGrid( "JURA159_FIL", oStructFIL, "FILDETAIL" )
	EndIf
	If lUsaHist
		oView:AddGrid( "JURA159_NUS", oStructNUS, "NUSDETAIL" )
		oView:AddGrid( "JURA159_NVM", oStructNVM, "NVMDETAIL" )
	EndIf

	oView:SetCloseOnOk({||.F.})
EndIF

oView:CreateFolder("FOLDER_01")
oView:AddSheet("FOLDER_01", "ABA_01_01", STR0015   ) //"Participante"
If lIntegrPFS .OR. nModulo == 77
	If lUsaHist
		oView:AddSheet("FOLDER_01", "ABA_01_02", STR0016   ) //"Histórico"
	EndIf
	oView:AddSheet("FOLDER_01", "ABA_01_03", STR0012   ) //"Ausências"
	oView:AddSheet("FOLDER_01", "ABA_01_04", STR0013   ) //"Rateio entre Centros de Custo"
	If lFornAt
		oView:AddSheet("FOLDER_01", "ABA_01_05", STR0059   ) //"Bancos"
	EndIf
EndIF

oView:CreateHorizontalBox("BOX_01_F01_A01",50,,,"FOLDER_01","ABA_01_01")
oView:CreateHorizontalBox("BOX_02_F01_A01",50,,,"FOLDER_01","ABA_01_01")

If lIntegrPFS .OR. nModulo == 77
	oView:CreateHorizontalBox("BOX_01_F01_A03",100,,,"FOLDER_01","ABA_01_03")
	oView:CreateHorizontalBox("BOX_01_F01_A05",100,,,"FOLDER_01","ABA_01_05")

	If lUsaHist
		oView:CreateHorizontalBox("BOX_01_F01_A02",100,,,"FOLDER_01","ABA_01_02")
		oView:CreateHorizontalBox("BOX_01_F01_A04",50,,,"FOLDER_01","ABA_01_04")
		oView:CreateHorizontalBox("BOX_02_F01_A04",50,,,"FOLDER_01","ABA_01_04")
	Else
		oView:CreateHorizontalBox("BOX_01_F01_A04",100,,,"FOLDER_01","ABA_01_04")
	EndIf
EndIf

oView:SetOwnerView( "RD0MASTER", "BOX_01_F01_A01" )
oView:SetOwnerView( "NURDETAIL", "BOX_02_F01_A01" )

If lIntegrPFS .OR. nModulo == 77
	oView:SetOwnerView( "NTXDETAIL", "BOX_01_F01_A03" )
	oView:SetOwnerView( "NSSDETAIL", "BOX_01_F01_A04" )
	If lFornAt
		oView:SetOwnerView( "FILDETAIL", "BOX_01_F01_A05" )
	EndIf

	If lUsaHist
		oView:SetOwnerView( "NUSDETAIL", "BOX_01_F01_A02" )
		oView:SetOwnerView( "NVMDETAIL", "BOX_02_F01_A04" )
		oView:EnableTitleView( "NVMDETAIL" )
	EndIf
EndIf

Return oView

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA159COMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author Cristina Cintra Santos
@since 21/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA159COMMIT FROM FWModelEvent
	Data lCopyBanks
	Data cClieForn
	Data cLojaForn
	Data cTempForn

	Method New()
	Method BeforeTTS()
	Method InTTS()
	Method GridLinePosVld()
	Method ModelPosVld()
	Method GridLinePreVld()
	Method Activate()
	Method Destroy()
End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy()
Metodo de Destroy do modelo.

@Param oModel Modelo de dados de de contas bancarias do fornecedor

@author Luciano Pereira dos Santos
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class JA159COMMIT
	Self:lCopyBanks := .F.
	Self:cClieForn  := ""
	Self:cLojaForn  := ""
	self:cTempForn  := ""
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy()
Metodo de Destroy do modelo.

@Param oModel Modelo de dados de de contas bancarias do fornecedor

@author Luciano Pereira dos Santos
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Method Destroy() Class JA159COMMIT
	Self:lCopyBanks := .F.
	Self:cClieForn  := ""
	Self:cLojaForn  := ""
	Self:cTempForn  := ""
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Activate()
Metodo de ativação do modelo.

@Param oModel Modelo de dados de de contas bancarias do fornecedor

@author Luciano Pereira dos Santos
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Method Activate(oModel) Class JA159COMMIT
	Local lRet      := .T.
	Local oModelRD0 := oModel:GetModel("RD0MASTER")

	Self:cClieForn := oModelRD0:GetValue("RD0_FORNEC")
	Self:cLojaForn := oModelRD0:GetValue("RD0_LOJA")
	Self:cTempForn := TempForn()
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BeforeTTS()
Metodo de commit do modelo antes da transação.

@Param oModel Modelo de dados de de contas bancarias do fornecedor

@author Luciano Pereira dos Santos
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Method BeforeTTS(oModel, cModelId) Class JA159COMMIT
	If NUR->(ColumnPos("NUR_FORNAT")) > 0
		J159VldBnk(oModel, Self:lCopyBanks, Self:cTempForn, Self:cLojaForn)
	EndIf
	JURA159CMT(oModel)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS()
Metodo de commit do modelo em transação.

@Param oModel Modelo de dados de de contas bancarias do fornecedor

@author Luciano Pereira dos Santos
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class JA159COMMIT
	JA159SetRst(oModel)
	JFILASINC(oModel, "RD0", "RD0MASTER", "RD0_CODIGO")
	If NUR->(ColumnPos("NUR_FORNAT")) > 0
		J159GrvBnk(oModel, Self:lCopyBanks, Self:cClieForn, Self:cLojaForn, Self:cTempForn)
		J159AtuBnk(oModel)
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld()
Metodo de pos-validação do Grid.

@Param oModel       Modelo de dados de de contas bancarias do fornecedor

@author Luciano Pereira dos Santos
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Method GridLinePosVld(oSubModel, cModelID) Class JA159COMMIT
Local lRet := .T.

Do Case
	Case cModelID == "NUSDETAIL"
		lRet := JHistValid(oSubModel)
	Case cModelID == "NTXDETAIL"
		lRet := Jur159VAus(oSubModel)
	Case cModelID == "NSSDETAIL"
		lRet := Jur159VRat(oSubModel)
EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld()
Metodo de pos-validação do Modelo.

@Param oModel       Modelo de dados de de contas bancarias do fornecedor

@author Luciano Pereira dos Santos
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class JA159COMMIT
Local lRet      := .T.
Local lNovoForn := (Empty(Self:cClieForn) .And. Empty(Self:cClieForn))

If NUR->(ColumnPos("NUR_FORNAT")) > 0
	Self:lCopyBanks := J159VldFor(oModel, lNovoForn) //Validação replicar as contas Banco do fornecedor (Participante)
EndIf

lRet := Jur159VHCC( oModel:GetModel("NVMDETAIL") )
lRet := lRet .And. Jur159TOk(oModel)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GridLinePreVld()
Metodo de pré-validação do grid.

@Param oModel       Modelo de dados de de contas bancarias do fornecedor

@author Luciano Pereira dos Santos
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class JA159COMMIT
Local lRet      := .T.
Local oModel    := Nil
Local oModelRD0 := Nil

Do Case
	Case cModelID == "FILDETAIL" .And. cAction != "DELETE"
		oModel    := oSubModel:GetModel()
		oModelRD0 := oModel:GetModel("RD0MASTER")
		lRet      := !Empty(oModelRD0:GetValue("RD0_FORNEC")) .And. !Empty(oModelRD0:GetValue("RD0_LOJA"))
EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J159VldFor(oModel, lNovoForn)
Função para verificar se ocorreu alteração do fornecedor do participante

@Param oModel     Modelo de dados de de contas bancarias do fornecedor
@Param lNovoForn .T. se é um forncedor novo

@author Luciano Pereira dos Santos
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J159VldFor(oModel, lNovoForn)
Local lRet        := .T.
Local oModelRD0   := oModel:GetModel("RD0MASTER")
Local oModelFIL   := oModel:GetModel("FILDETAIL")
Local lAltera     := oModel:GetOperation() == MODEL_OPERATION_UPDATE

Default lNovoForn := .T.

	If !lNovoForn .And. lAltera .And. !oModelFIL:IsEmpty() .And.;
		(oModelRD0:IsFieldUpdated("RD0_FORNEC") .Or. oModelRD0:IsFieldUpdated("RD0_LOJA"))

		If Empty( oModelRD0:GetValue("RD0_FORNEC") ) .Or. Empty( oModelRD0:GetValue("RD0_LOJA") )
			lRet := .F.
		Else
			lRet := IIF(IsBlind(), lRet, ApMsgYesNo(STR0060)) //"As informações do fornecedor foram alteradas. Deseja replicar as contas bancarias para o novo fornecedor?"
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J159VldBnk(oModel, cClFornOld, cLjFornOld, cTempForn)
Função para verificar se o fornedor novo ja possui o mesmo registro bancario na base
Em positivo, elimina ou direciona para um forncedor temporario

@Param oModel        Modelo de dados de de contas bancarias do fornecedor
@Param lCopyBanks  .T. replica as informaçoes bancarias do fornecedor
@Param cClFornOld   Codigo do fornecedor na inicialização do modelo
@Param cLjFornOld   Loja do fornecedor na inicialização do modelo
@Param cTempForn    Codigo do forncedor temporario

@Obs É preciso o controle para que alteração de fornecedor não cause violação de chave primaria

@author Luciano Pereira dos Santos
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J159VldBnk(oModel, lCopyBanks, cTempForn, cLjFornOld)
Local lRet       := .T.
Local oModelRD0  := oModel:Getmodel("RD0MASTER")
Local oModelFIL  := oModel:Getmodel("FILDETAIL")
Local nI         := 0
Local cClFornNew := oModelRD0:GetValue("RD0_FORNEC")
Local cLjFornNew := oModelRD0:GetValue("RD0_LOJA")
Local lAltera    := (oModel:GetOperation() ==  MODEL_OPERATION_UPDATE)

If lAltera .And. !oModelFIL:IsEmpty() .And.;
		(oModelRD0:IsFieldUpdated("RD0_FORNEC") .Or. oModelRD0:IsFieldUpdated("RD0_LOJA"))

	For nI := 1 to oModelFIL:Length()

		If J159VldCont(oModelFIL, nI, cClFornNew, cLjFornNew) //Verifica se o MVC vai gravar o registro novo duplicado na base
			If !lCopyBanks //Se não replicar, grava o registro duplicado para o forncedor antigo
				RecLock("FIL", .F.)
				FIL->FIL_FORNEC := cTempForn
				FIL->FIL_LOJA   := cLjFornOld
				FIL->(MsUnlock())
			Else  //Se existir o registro duplicado, deleta o regsitro mais antigo (qua nao esta no modelo)
				RecLock("FIL", .F.)
				FIL->(DbDelete())
				FIL->(MsUnlock())
			EndIf
		EndIf

	Next nI

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TempForn()
Gera um código temporário de forncedor

@Return cRet  Marca gerada por número aleatório

@author Luciano Pereira dos Santos
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static function TempForn()
Local cRet   := ""
Local nI     := 0
Local nTamCp := TamSX3("A2_COD")[1]

For nI := 1 to nTamCp
	If (Randomize(0,100)%2 == 0)
		cRet := cRet + Chr(Randomize(97,123))
	Else
		cRet := cRet + Chr(Randomize(48,58) )
	EndIf
Next nI

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J159GrvBnk(oModel, lCopyBanks, cClFornOld, cLjFornOld, cTempForn)
Função verificar se a conta de para uma determinado fornecedor ja existe.

@Param oModel       Modelo de dados de de contas bancarias do fornecedor
@Param lCopyBanks  .T. replica as contas bancarias do fornecedor
@Param cClFornOld  Codigo do cliente do fornecedor
@Param cLjFornOld  Codigo da loja do cliente do fornecedor

@Obs Nesse momento o MVC já transf. os dados bancarios para o novo fornecedor

@author Luciano Pereira dos Santos
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J159GrvBnk(oModel, lCopyBanks, cClFornOld, cLjFornOld, cTempForn)
Local aArea      := GetArea()
Local oModelFIL  := oModel:GetModel("FILDETAIL")
Local oModelRD0  := oModel:GetModel("RD0MASTER")
Local lRet       := .T.
Local nI         := 0
Local aFilStruct := FIL->(DbStruct())
Local nY         := 0
Local cCampo     := ""
Local xValor     := Nil
Local lOk        := .F.
Local lAcao      := .F.
Local cClFornNew := oModelRD0:GetValue("RD0_FORNEC")
Local cLjFornNew := oModelRD0:GetValue("RD0_LOJA")
Local lExistOld  := .F.
Local lExistNew  := .F.

If oModel:GetOperation() ==  MODEL_OPERATION_UPDATE .And.;
	(oModelRD0:IsFieldUpdated("RD0_FORNEC") .Or. oModelRD0:IsFieldUpdated("RD0_LOJA"))

	For nI := 1 To oModelFIL:Length()
		lExistOld := J159VldCont(oModelFIL, nI, cClFornOld, cLjFornOld) //Valida se a conta de banco já existe o fornecedor antigo.
		lExistNew := J159VldCont(oModelFIL, nI, cTempForn, cLjFornOld) //Tenta posicionar na conta de banco do fornecedor temporario.
		If !lExistNew
			lExistNew := J159VldCont(oModelFIL, nI, cClFornNew, cLjFornNew) //Se não existir temporario, posiciona na conta de banco do fornecedor novo.
		EndIf
		lOk       := !lExistOld .And. lExistNew .And. !oModelFIL:IsInserted(nI) //se a linha é nova permanece com o fornecedor novo

		If lOk
			If lCopyBanks
				lAcao := .T. // Cria as mesmas informações de banco para o fornecedor antigo.
			Else
				lAcao := .F. //Transfere os registros para o forncedor antigo
			EndIf

			RecLock("FIL", lAcao)
			For nY := 1 To Len(aFilStruct)
				cCampo := aFilStruct[nY][1]
				If cCampo == "FIL_FILIAL"
					xValor := xFilial("FIL")
				ElseIf cCampo == "FIL_FORNEC"
					xValor := cClFornOld
				ElseIf cCampo == "FIL_LOJA"
					xValor := cLjFornOld
				Else
					xValor := oModelFIL:GetValue(cCampo, nI)
				EndIf
				FIL->(FieldPut(FieldPos(cCampo), xValor))
			Next nY
			FIL->(MsUnlock())
			FIL->(DbCommit())
		EndIf

	Next nI

EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J159VldCont(oModelFIL, nLinha, cFornec, cLojaForn)
Função verificar se a conta de um determinado fornecedor ja existe.

@Param oModelFIL  Modelo de dados de de contas bancarias do fornecedor
@Param nLinha     Linha posicionada do modelo de dados de de contas bancarias do fornecedor
@Param cFornec    Codigo do cliente do fornecedor
@Param cLojaForn  Codigo da loja do cliente do fornecedor

@author Luciano Pereira dos Santos
@since 16/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static function J159VldCont(oModelFIL, nLinha, cFornec, cLojaForn)
Local cTipo    := oModelFIL:GetValue("FIL_TIPO", nLinha)
Local cBanco   := oModelFIL:GetValue("FIL_BANCO", nLinha)
Local cAgenci  := oModelFIL:GetValue("FIL_AGENCI", nLinha)
Local cConta   := oModelFIL:GetValue("FIL_CONTA", nLinha)

FIL->(DbsetOrder(1)) // FIL_FILIAL+FIL_FORNEC+FIL_LOJA+FIL_TIPO+FIL_BANCO+FIL_AGENCI+FIL_CONTA

lRet := FIL->(DbSeek(xFilial("FIL")+ cFornec + cLojaForn + cTipo + cBanco + cAgenci + cConta))

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JURA159CMT
Função para chamada de atualização/ajuste de histórico.

@author Felipe Bonvicini Conti
@since 28/04/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURA159CMT(oModel)
Local lRet      := .T.
Local aArea     := GetArea()
Local oModelNVM := oModel:GetModel( "NVMDETAIL" )
Local nOpc      := 0
Local lNaturez  := !Empty(SuperGetMv("MV_JNATFEP",.F.,"")) .And. NUR->(ColumnPos("NUR_NATURE")) > 0

	If !oModel:GetOperation() == OP_EXCLUIR
		lRet := JURA159HST(oModel)
	EndIf

	If lRet
		lRet := JURPerHist( oModelNVM, .T.,  {"NVM_CC"} )
	EndIf

	If lRet .And. NUR->(ColumnPos("NUR_FORNAT")) > 0 .And. oModel:GetValue("NURDETAIL", "NUR_FORNAT") == "1" .And. oModel:GetValue("RD0MASTER", "RD0_TPJUR") == "1" //Proteção
		nOpc := oModel:GetOperation()
		If (nOpc == 3 .Or. nOpc == 4)
			lRet := JA159CForn(oModel, lNaturez)
		ElseIf (nOpc == 5)
			lRet := JA159BlqFN(oModel, lNaturez)
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } JURA159HST
Rotina para atualizar o histórico do participante.

@author Bruno Ritter / Luciano Pereira
@since 14/08/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function JURA159HST(oModel)
Local lRet         := .T.
Local lGrid        := .F.
Local aCpoMdls     := {}
Local aNURCpo      := {}
Local aRD0Cpo      := {}
Local aNSSCpo      := {}

	aAdd(aNURCpo, {"NUR_CESCR", "NUS_CESCR"})
	aAdd(aNURCpo, {"NUR_CCAT", "NUS_CCAT"})
	aAdd(aNURCpo, {"NUR_SOCIO", "NUS_SOCIO"})
	aAdd(aNURCpo, {"NUR_HRDIAD", "NUS_HRDIAD"})
	aAdd(aNURCpo, {"NUR_HRDIAB", "NUS_HRDIAB"})
	aAdd(aNURCpo, {"NUR_ORDHIE", "NUS_ORDHIE"})
	Iif(NUR->(ColumnPos("NUR_RATDES")) > 0, aAdd(aNURCpo, {"NUR_RATDES", "NUS_RATDES"}), ) // Proteção
	Iif(NUR->(ColumnPos("NUR_TECNIC")) > 0, aAdd(aNURCpo, {"NUR_TECNIC", "NUS_TECNIC"}), ) // Proteção

	aAdd(aRD0Cpo, {"RD0_CC", "NUS_CC"})
	If NUS->(ColumnPos("NUS_DTADMI")) > 0
		aAdd(aRD0Cpo, {"RD0_DTADMI", "NUS_DTADMI"})
		aAdd(aRD0Cpo, {"RD0_DTADEM", "NUS_DTADEM"})
	EndIf

	aAdd(aCpoMdls, {"NURDETAIL", aNURCpo})
	aAdd(aCpoMdls, {"RD0MASTER", aRD0Cpo})

	lGrid := .F.
	lRet := JurHist(oModel, "NUSDETAIL", aCpoMdls, lGrid)

	If lRet
		JurFreeArr(@aCpoMdls)

		If NSS->(ColumnPos("NSS_CESCR")) > 0 .And. NVM->(ColumnPos("NVM_CESCR")) > 0 // Proteção
			aAdd(aNSSCpo, {"NSS_CESCR", "NVM_CESCR"})
		EndIf
		aAdd(aNSSCpo, {"NSS_CC"   , "NVM_CC"})
		aAdd(aNSSCpo, {"NSS_PERC" , "NVM_PERC"})
		aAdd(aNSSCpo, {"NSS_COD"  , "NVM_COD"})
		aAdd(aCpoMdls, {"NSSDETAIL", aNSSCpo})

		lGrid := .T.
		lRet := JurHist(oModel, "NVMDETAIL", aCpoMdls, lGrid, {"NSS_CC","NVM_CC"})
	EndIf

	JurFreeArr(@aNURCpo )
	JurFreeArr(@aRD0Cpo )
	JurFreeArr(@aNSSCpo )
	JurFreeArr(@aCpoMdls)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadNusNvm
Faz a carga dos dados da grid do NUS ou NVM e ordena decrescente pelo ano-mês

@author Claudio Donizete de Souza
@since 20/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function LoadNUSNVM( oGrid, cCampo, oModel)
Local nOperacao := oGrid:GetModel():GetOperation()
Local aStruct   := oGrid:oFormModelStruct:GetFields()
Local nAt       := 0
Local aRet      := {}

If nOperacao <> OP_INCLUIR // <- requer o INCLUDE do "FWMVCDEF.CH"

	aRet := FormLoadGrid( oGrid )

	// Ordena decrescente pelo Ano/Mes
	If ( nAt := aScan( aStruct, { |e| e[MODEL_FIELD_IDFIELD] == cCampo } ) ) > 0
		aSort( aRet,,, { |aX,aY| aX[2][nAt] > aY[2][nAt] } )
	EndIf

EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur159VRat
Valida o total do rateio entre grupos

@author Claudio Donizete de Souza
@since 20/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Jur159VRat( oGrid, lTudOk )
Local lRet      := .T.
Local nTotal    := 0
Local nLines    := oGrid:GetQtdLine()
Local nLinDel   := 0
Local nFirstLin := 0
Local nX

Default lTudOk  := .F.

// Verifica o total de linhas deletadas, para validar o total do rateio somente se tiver ao menos uma linha nao deletada
For nX := 1 To nLines
	If oGrid:IsDeleted(nX)
		nLinDel ++
	Else
		If Empty(nFirstLin)
			nFirstLin := nX	// Localiza a primeira linha nao deletada
		EndIf
	Endif
Next

// Soma total do Rateio, apenas se houver linhas validas digitadas
If Round(nLinDel,0) != Round(nLines,0) .And. ;
	( !Empty(oGrid:GetValue("NSS_CC",nFirstLin)) .Or. !Empty(oGrid:GetValue("NSS_PERC",nFirstLin)) )
	For nX := 1 To nLines
		If !oGrid:IsDeleted(nX)
			nTotal += oGrid:GetValue( "NSS_PERC", nX )
		EndIf
	Next

	If lTudOk
		If Round(nTotal,2) <> 100
			lRet := JurMsgErro( STR0022 ) //"Total do Rateio deve ser igual a 100%"
		Endif
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur159VHCC
Valida o total do rateio do historico do rateio entre grupos

@author Claudio Donizete de Souza
@since 22/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Jur159VHCC( oGrid )
Local lRet      := .T.
Local nTotal    := 0
Local nX
Local cAnoMes, cAnoMesFim
Local aColsOrd := {}
Local nPosAmIni := 1
Local nPosAmFim := 2
Local nPosPerc  := 3
Local nLines	:= 0

For nX := 1 To oGrid:GetQtdLine()
	If !oGrid:IsDeleted(nX) .And. !oGrid:IsEmpty(nX)
		aAdd(aColsOrd,{oGrid:GetValue("NVM_AMINI",nX),oGrid:GetValue("NVM_AMFIM",nX), oGrid:GetValue("NVM_PERC",nX)})
	Endif
Next

nLines := len(aColsOrd)

// Ordena os dados em uma copia, para nao prejudicar a referencia do aCols
aSort( aColsOrd,,, { |aX,aY| aX[nPosAmIni] > aY[nPosAmIni] } )

// Soma total do Rateio, apenas se houver linhas validas digitadas
For nX := 1 To nLines Step 0
	cAnoMes    := aColsOrd[nX,nPosAmIni]
	cAnoMesFim := aColsOrd[nX,nPosAmFim]
	// Soma os percentuais do mesmo ano/mes
	nTotal := 0

	//Utiliza as linhas com o mesmo valor e ja adianta o contador Nx
	While nX <= nLines .And. cAnoMes == aColsOrd[nX,nPosAmIni] .And. cAnoMesFim == aColsOrd[nX,nPosAmFim]
		nTotal += aColsOrd[nX,nPosPerc]
		nX++
	End

	If lRet
		If nTotal > 0 .And. Round(nTotal,2) <> 100
			lRet := JurMsgErro( STR0023 + Transform(cAnoMes,PesqPict("NVM", "NVM_AMINI")) + STR0025 ) //"Total do Rateio do Histórico entre Grupos, do ano/mes "###",  deve ser igual a 100%"
			Exit
		Endif

		If nX <= nLines
			If aColsOrd[(nX-1),nPosAmIni] <= aColsOrd[nX,nPosAmIni] .Or.;
				aColsOrd[(nX-1),nPosAmIni] <= aColsOrd[nX,nPosAmFim]
				lRet := JurMsgErro(STR0029) // "Não é possível ter históricos considerando o mesmo Ano-mês"
			Endif
		Endif
	Endif
Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur159TOk
Valida o total do rateio entre grupos ao confirmar o participante

@author Claudio Donizete de Souza
@since 20/10/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Jur159TOk(oModel)
Local oGridNSS   := oModel:GetModel( "NSSDETAIL" )
Local oGridNUS   := oModel:GetModel( "NUSDETAIL" )
Local oGridNVM   := oModel:GetModel( "NVMDETAIL" )
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaRD0   := RD0->(GetArea())
Local nI         := 0
Local cProblema  := ""
Local cSolucao   := ""
Local cDescEsc   := ""
Local cDescCC    := ""
Local cRegs := ""
Local lNaturez  := !Empty(SuperGetMv("MV_JNATFEP",.F.,"")) .And. NUR->(ColumnPos("NUR_NATURE")) > 0

 	lRet := JURPerHist( oGridNUS, .T. ) //CH8119 Valida lacunas de período no histórico de honorários

 	If lRet
 		lRet := JURPerHist( oGridNVM, .T.,  {"NVM_CC"} )//CH8119 Valida lacunas de período no histórico de rateio de grupos
	EndIf

 	If lRet
 		lRet := Jur159VRat( oGridNSS, .T. )
	EndIf

	If lRet
		If FwFldGet("RD0_TPJUR") == "1" .And. Empty(FwFldGet("RD0_SIGLA"))
			lRet := JurMsgErro(STR0033) //Preencha a Sigla do Participante
		EndIf
	EndIf

	If lRet .And. NUR->(ColumnPos("NUR_FORNAT")) > 0 .And. oModel:GetValue("NURDETAIL", "NUR_FORNAT") == "1" //Proteção

		If oModel:GetOperation() != MODEL_OPERATION_DELETE .AND. Ja159NatDup(@cRegs, FwFldGet("RD0_CODIGO"), FwFldGet("RD0_FORNEC"), FwFldGet("RD0_LOJA") , IIF(lNaturez, oModel:GetValue("NURDETAIL", "NUR_NATURE"), ""), lNaturez)
			lRet := JurMsgErro(STR0066 + cRegs, STR0068, IIF(!lNaturez, STR0067, STR0071)) //"Já existe a natureza vinculada à outro participante."##"Natureza Duplicada"##"Realize um vínculo a um fornecedor, que não esteja cadastrado à mais de uma natureza."##"Realize o vínculo de uma natureza que não esteja vinculada a mais de um participante."
		EndIf

		lRet := lRet .AND. J159Clilj(oModel) //Preenchimento automatico do fornecedor e loja para gerar o Fornecedor e Natureza Financeira automaticamente (NUR_FORNAT == "1")

		If lRet
			lRet := JA159VlFoN(oModel) //Validação para gerar o Fornecedor e Natureza Financeira automaticamente (NUR_FORNAT == "1").
		EndIf
	EndIf

	If nModulo == 77 .And. x3Obrigat( PadR( "RD0_CC", 10 ) ) // Somente SIGAPFS e se o Centro de custo do participante for obrigatório no dicionário,
	                                                         // valida preenchimento dos campos de escritório e centro de custo na aba Histórico
		For nI := 1 to oGridNUS:GetQtdLine()

			If !oGridNUS:IsDeleted(nI) .And. !oGridNUS:IsEmpty(nI)

				cDescEsc := AllTrim(RetTitle('NUS_CESCR'))
				cDescCC  := AllTrim(RetTitle('NUS_CC'))

				If Empty(oGridNUS:GetValue("NUS_CESCR", nI))
					cProblema := I18N(STR0057, {cDescEsc}) // "O campo '#1' não foi preenchido."
				ElseIf Empty(oGridNUS:GetValue("NUS_CC", nI))
					cProblema := I18N(STR0057, {cDescCC})  // "O campo '#1' não foi preenchido."
				EndIf

				If !Empty(cProblema)
					cSolucao  := I18N(STR0058, {cDescEsc,cDescCC, STR0016}) // "É necessário preencher os campos '#1' e '#2' para todas as linhas da aba '#3'." - "Histórico"

					lRet := JurMsgErro(cProblema,,cSolucao)
					Exit
				EndIf
			EndIf
		Next
	EndIf

	RestArea(aAreaRD0)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYNUR
Monta a query de participantes relacionando com complemento do cadastro de participantes em ordem de hierarquia

@Return cQuery	 	Query montada

@author Claudio Donizete de Souza
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQRYNUR
	Local cQuery   := ""

	cQuery := "	SELECT RD0.RD0_CODIGO, RD0.RD0_NOME, NUR.NUR_ORDHIE, NUR.NUR_CCAT, RD0.R_E_C_N_O_ RD0RECNO"
	cQuery += "   FROM "+RetSqlName("RD0")+" RD0 "
	cQuery += "  JOIN " +RetSqlName("NUR")+" NUR "
	cQuery += "        ON NUR.NUR_FILIAL = '" + xFilial("NUR") + "'"
	cQuery += "		   AND NUR.NUR_CPART = RD0.RD0_CODIGO "
	cQuery += "		   AND NUR.D_E_L_E_T_ = ' '
	cQuery += " WHERE RD0.RD0_FILIAL = '" + xFilial( "RD0" ) + "'"
	cQuery += "       AND RD0.D_E_L_E_T_ = ' ' "
//	cQuery += "	  ORDER BY NUR.NUR_ORDHIE "  // não pode ter order by na query pois ao utilizar a pesquisa ele incluirá "order by rd0_cod"

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JURF3NURHIE
Monta a consulta padrão participantes por ordem hierarquica
Uso Geral.

@Return lRet	 	.T./.F. As informações são válidas ou não
@sample
Consulta padrão específica NURHIE

@author Claudio Donizete de Souza
@since 20/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURF3NURHIE(cTipo)
	Local lRet     := .F.
	Local aArea    := GetArea()
	Local cQuery   := JQRYNUR()
	Local aPesq    := {"RD0_CODIGO", "RD0_NOME"}

	cQuery := ChangeQuery(cQuery, .F.)

	uRetorno := ''

	If JurF3Qry( cQuery, 'JURRD0', 'RD0RECNO', @uRetorno, , aPesq )
		lRet := .T.
	EndIf

	RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA159VLDCP
Validação da data inicial no cadastro ausências do participante

@Return lRet	 	.T./.F. As informações são válidas ou não

@author David Gonçalves Fernandes
@since 10/12/20096
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA159VLDCP(cCampo)
Local lRet := .F.

If cCampo == 'NTX_DATAI' .OR. cCampo == 'NTX_DATAF'
	lRet := Vazio(FwFldGet("NTX_DATAF")).Or.If(FwFldGet("NTX_DATAF") >= FwFldGet("NTX_DATAI"),.T.,(JurMsgErro(STR0031),.F.)) // "Data final deve ser maior que data inicial"
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur159VAus
Valida a inclusão de linhas na ausência do participante

@Return lRet, .T./.F. As informações são válidas ou não

@author David Gonçalves Fernandes
@since  07/12/2009
/*/
//-------------------------------------------------------------------
Static Function Jur159VAus( oGrid )
Local lRet        := .T.
Local nLine       := 0
Local nOperation  := oGrid:GetModel():GetOperation()
Local oModelNTX   := oGrid:GetModel():GetModel("NTXDETAIL")
Local nLineAtu    := oGrid:GetLine() // Linha posicionada
Local dDataIni    := Nil
Local dDataFim    := Nil

If nOperation == 3 .Or. nOperation == 4 // Inclusão (3) ou Alteração (4)

	// Só valida se a linha atual não foi deletada
	If !oModelNTX:IsDeleted(nLineAtu) .AND. !oModelNTX:IsEmpty(nLineAtu)

		dDataIni := oGrid:GetValue("NTX_DATAI", nLineAtu) // Data Inicial na linha posicionada
		dDataFim := oGrid:GetValue("NTX_DATAF", nLineAtu) // Data Final na linha posicionada

		For nLine := 1 To oGrid:GetQtdLine()
			If !oGrid:IsDeleted(nLine) .And. !oGrid:IsEmpty(nLine) .And. nLine <> nLineAtu // Não valida a própria linha posicionada
				If oModelNTX:GetValue("NTX_DATAI", nLine) <= dDataFim .And. oModelNTX:GetValue("NTX_DATAF", nLine) >= dDataIni
					lRet := JurMsgErro(STR0030) // "Períodos sobrepostos no cadastro de ausências"
					Exit
				EndIf
			Endif
		Next
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA159NUR
Inicializa os campos da NUR na alteracao
@author Ernani Forastieri
@since 23/12/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA159NUR( oModel )
Local aArea      := GetArea()
Local aAreaNUR   := NUR->( GetArea() )
Local aCampos    := {}
Local nI         := 0
Local nOperation := oModel:GetOperation()
Local oModelNUR  := Nil
Local xInit      := ""

If nOperation == MODEL_OPERATION_UPDATE
	oModelNUR := oModel:GetModel( 'NURDETAIL')

	NUR->( dbSetOrder( 1 ) )
	If !NUR->( dbSeek( xFilial( 'NUR' ) + oModel:GetValue( 'RD0MASTER', 'RD0_CODIGO' ) ) )
		aCampos := oModelNUR:GetStruct():GetFields()

		For nI :=  1 to Len( aCampos )
			If aCampos[nI][MODEL_FIELD_INIT] <> NIL
				xInit := oModelNUR:InitValue( aCampos[nI][MODEL_FIELD_IDFIELD] )
				If !Empty( xInit )
					oModelNUR:LoadValue( aCampos[nI][MODEL_FIELD_IDFIELD], xInit )
				EndIf
			EndIf
		Next
	EndIf
EndIf

RestArea( aAreaNUR )
RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA159SetRst
Função para chamada da JurSetRest() - Restrição de Cadastros, quando
for inclusão pelo SIGAJURI.

@author Jorge Luis Branco Martins Junior
@since 12/09/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA159SetRst(oModel)
Local cSigla := oModel:GetValue("RD0MASTER","RD0_SIGLA")
Local nOpc	 := oModel:GetOperation()

	If nOpc == 3 .And. nModulo == 76 .And. (oModel:GetValue("RD0MASTER","RD0_TPJUR") == "1") .And. ;
	   !Empty(Alltrim(cSigla))
		lRet := JurSetRest('RD0', cSigla)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA159CForn()
Cria e vincula o fornecedor no participante.

@param oModel   - Modelo de dados do participante
@param lNaturez - Utiliza Natureza Vinculada ao participante

@return lRet    - Alteração realizada com sucesso

@author Bruno Ritter
@since 01/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA159CForn(oModel, lNaturez)
Local lRet          := .T.
Local oModelRD0     := oModel:GetModel( "RD0MASTER" )
Local cCdPart       := ""
Local cNmPart       := ""
Local cNomeRed      := ""
Local cEndPart      := ""
Local cUFPart       := ""
Local cMunPart      := ""
Local cCpfPart      := ""
Local cCmplPart     := ""
Local cCepPart      := ""
Local cBaiPart      := ""
Local cDdiPart      := ""
Local cDddPart      := ""
Local cFonePart     := ""
Local cFaxPart      := ""
Local cEmlPart      := ""
Local dNascPart     := ""
Local cLojaForn     := CriaVar("A2_COD", .F.)
Local cCodForn      := CriaVar("A2_LOJA", .F.)
Local nOpcFor       := 0
Local nOpcNat       := 0
Local aCamposSED    := {}
Local aCamposSA2    := {}
Local cCodNatFor    := CriaVar("ED_CODIGO", .F.)
Local cMoedaNac     := SuperGetMv('MV_JMOENAC',,'01')
Local lNatSint      := SuperGetMv('MV_NATSINT',, '1') == '1'
Local cNatPai       := ""
Local cFilSa2       := J159FilSa2("", oModel)
Local cEscri        := oModel:GetValue("NURDETAIL", "NUR_CESCR")
Local cFilEscr      := JurGetDados("NS7", 1, xFilial("NS7") + cEscri, "NS7_CFILIA")
Local cFilOld       := cFilAnt
Local nOpcNFor      := 0 // Operação da Natureza do fechamento
Local cNatPaiFe     := ""
Local cNatFech      := ""
Local lGrvNat       := .F.
Local lOHPInDic     := FWAliasInDic("OHP")

Private lMsErroAuto := .F.
Default oModel      := FwModelActive()
Default lNaturez    := .F.

If (oModel:GetId() != 'JURA159') // Se o Model que vier carregado for diferente do JURA159, carrega o Modelo correspondente do JURA159
	oModel := FWLoadModel( 'JURA159' )
	oModel:Activate()
EndIf

cFilAnt := cFilEscr

If (oModel:GetValue("NURDETAIL", "NUR_FORNAT") == "1")

	cCodForn  := oModelRD0:GetValue("RD0_FORNEC")
	cLojaForn := oModelRD0:GetValue("RD0_LOJA")
	cCdPart   := oModelRD0:GetValue("RD0_CODIGO")
	cNmPart   := oModelRD0:GetValue("RD0_NOME"  )

	cNomeRed  := AvKey(cNmPart, "A2_NREDUZ")
	cEndPart  := AvKey(oModelRD0:GetValue("RD0_END"), "A2_END")
	cUFPart   := oModelRD0:GetValue("RD0_UF"    )
	cMunPart  := AvKey(oModelRD0:GetValue("RD0_MUN"), "A2_MUN")
	cAtivo    := oModelRD0:GetValue("RD0_MSBLQL")
	cCpfPart  := oModelRD0:GetValue("RD0_CIC"   )
	cCmplPart := oModelRD0:GetValue("RD0_CMPEND")
	cCepPart  := oModelRD0:GetValue("RD0_CEP"   )
	cBaiPart  := oModelRD0:GetValue("RD0_BAIRRO")
	cDdiPart  := oModelRD0:GetValue("RD0_DDI"   )
	cDddPart  := oModelRD0:GetValue("RD0_DDD"   )
	cFonePart := oModelRD0:GetValue("RD0_FONE"  )
	cFaxPart  := AvKey(oModelRD0:GetValue("RD0_FAX"), "A2_FAX")
	cEmlPart  := PADR(oModelRD0:GetValue("RD0_EMAIL"), TamSX3("A2_EMAIL")[1], " ")
	dNascPart := oModelRD0:GetValue("RD0_DTNASC")

	//---------------------------------------------------------//
	// Valida FORNECEDOR
	//---------------------------------------------------------//
	SA2->(DbSetOrder(1))
	If !SA2->(DbSeek(cFilSa2 + cCodForn + cLojaForn))
		nOpcFor := 3
	Else
		nOpcFor := 4
		cCodNatFor := SA2->A2_NATUREZ
	EndIf

	//---------------------------------------------------------//
	// Valida NATUREZA
	//---------------------------------------------------------//
	SED->(DbSetOrder(1))
	If !SED->(DbSeek(xFilial("SED") + cCodNatFor))
		nOpcNat := 3
		If Empty(cCodNatFor)
			cCodNatFor := &(SuperGetMV('MV_JNATPAR', .F., "PART" + oModelRD0:GetValue("RD0_SIGLA")))
			cCodNatFor := AvKey(cCodNatFor, "ED_CODIGO")
		EndIf

		If lOHPInDic .And. lNatSint
			cNatPai := AllTrim(JurGetDados("OHP", 1, xFilial("OHP") + "4" + "NP", "OHP_CNATUR"))
		EndIf
	Else
		nOpcNat := 4
	EndIf

	//---------------------------------------------------------//
	// Valida NATUREZA DE FECHAMENTO DO PARTICIPANTE
	//---------------------------------------------------------//
	If lNaturez
		cNatFech := oModel:GetValue("NURDETAIL", "NUR_NATURE")
		If (lGrvNat  := Empty(cNatFech))
			cNatFech := &(SuperGetMV('MV_JNATFEP', .F., ""))
			cNatFech := AvKey(cNatFech, "ED_CODIGO")
		EndIf

		If !SED->(DbSeek(xFilial("SED") + cNatFech))
			nOpcNFor := 3
			
			If lOHPInDic .And. lNatSint
				cNatPaiFe := AllTrim(JurGetDados("OHP", 1, xFilial("OHP") + "4" + "FP", "OHP_CNATUR"))
			EndIf
		Else
			nOpcNFor := 4
		EndIf

	EndIf

	Begin Transaction

		If lNaturez
			//---------------------------------------------------------//
			// Cria/Altera NATUREZA FECHAMENTO DO PARTICIPANTE
			//---------------------------------------------------------//
			aAdd(aCamposSED,{"ED_CODIGO", cNatFech       , Nil})
			aAdd(aCamposSED,{"ED_MSBLQL", cAtivo         , Nil})

			If (nOpcNFor == 3) // Este bloco deve ficar após o ED_CODIGO!
				aAdd(aCamposSED, {"ED_CMOEJUR", cMoedaNac, Nil})
				aAdd(aCamposSED, {"ED_TPCOJR" ,  "7"     , Nil}) // 7 - C.C. Profissional
				aAdd(aCamposSED, {"ED_DESCRIC", cNmPart  , Nil})
				aAdd(aCamposSED, {"ED_COND"   , "D"      , Nil}) // D = Despesa
				If !Empty(cNatPaiFe)
					aAdd(aCamposSED, {"ED_PAI", cNatPaiFe, Nil})
				ElseIf lNatSint
					MsgAlert(STR0061) // "Não foi preenchida a natureza pai na natureza criada para o Participante. Ajuste diretamente no cadastro de Naturezas."
				EndIf
			EndIf

			lMsErroAuto    := .F.
			MsExecAuto( { |x, y| FINA010(x, y) }, aCamposSED, nOpcNFor )
			If (lMsErroAuto)
				lRet := .F.
				DisarmTransaction()
				Break
			EndIf
			aCamposSED := {}
		EndIf

		//---------------------------------------------------------//
		// Cria/Altera NATUREZA
		//---------------------------------------------------------//
		aAdd(aCamposSED,{"ED_CODIGO", cCodNatFor    , Nil})
		aAdd(aCamposSED,{"ED_MSBLQL", cAtivo        , Nil})

		If (nOpcNat == 3) // Este bloco deve ficar após o ED_CODIGO!
			aAdd(aCamposSED, {"ED_CMOEJUR", cMoedaNac, Nil})
			aAdd(aCamposSED, {"ED_TPCOJR" ,  "7"     , Nil}) // 7 - C.C. Profissional
			aAdd(aCamposSED, {"ED_DESCRIC", cNmPart  , Nil})
			aAdd(aCamposSED, {"ED_COND"   , "D"      , Nil}) // D = Despesa
			If !Empty(cNatPai)
				aAdd(aCamposSED, {"ED_PAI", cNatPai  , Nil})
			ElseIf lNatSint
				MsgAlert(STR0061) // "Não foi preenchida a natureza pai na natureza criada para o Participante. Ajuste diretamente no cadastro de Naturezas."
			EndIf
		EndIf

		lMsErroAuto    := .F.
		MsExecAuto( { |x, y| FINA010(x, y) }, aCamposSED, nOpcNat )
		If (lMsErroAuto)
			lRet := .F.
			DisarmTransaction()
			Break
		EndIf

		//---------------------------------------------------------//
		// Cria/Altera FORNECEDOR
		//---------------------------------------------------------//
		aAdd(aCamposSA2,{"A2_FILIAL" , xFilial("SA2"), Nil})
		aAdd(aCamposSA2,{"A2_COD"    , cCodForn      , Nil})
		aAdd(aCamposSA2,{"A2_LOJA"   , cLojaForn     , Nil})
		aAdd(aCamposSA2,{"A2_NOME"   , cNmPart       , Nil})
		aAdd(aCamposSA2,{"A2_NREDUZ" , cNomeRed      , Nil})
		aAdd(aCamposSA2,{"A2_END"    , cEndPart      , Nil})
		aAdd(aCamposSA2,{"A2_EST"    , cUFPart       , Nil})
		aAdd(aCamposSA2,{"A2_MUN"    , cMunPart      , Nil})
		aAdd(aCamposSA2,{"A2_TIPO"   , "F"           , Nil})
		aAdd(aCamposSA2,{"A2_NATUREZ", cCodNatFor    , Nil})
		aAdd(aCamposSA2,{"A2_MSBLQL" , cAtivo        , Nil})
		aAdd(aCamposSA2,{"A2_CGC"    , cCpfPart      , Nil})
		aAdd(aCamposSA2,{"A2_ENDCOMP", cCmplPart     , Nil})
		aAdd(aCamposSA2,{"A2_CEP"    , cCepPart      , Nil})
		aAdd(aCamposSA2,{"A2_BAIRRO" , cBaiPart      , Nil})
		aAdd(aCamposSA2,{"A2_DDD"    , cDddPart      , Nil})
		aAdd(aCamposSA2,{"A2_DDI"    , cDdiPart      , Nil})
		aAdd(aCamposSA2,{"A2_TEL"    , cFonePart     , Nil})
		aAdd(aCamposSA2,{"A2_FAX"    , cFaxPart      , Nil})
		aAdd(aCamposSA2,{"A2_EMAIL"  , cEmlPart      , Nil})
		aAdd(aCamposSA2,{"A2_DTNASC" , dNascPart     , Nil})

		lMsErroAuto    := .F.
		MsExecAuto( { |x, y| MATA020(x, y) }, aCamposSA2, nOpcFor )

		If (lMsErroAuto)
			lRet := .F.
			DisarmTransaction()
			Break
		EndIf

	End Transaction

	If (lMsErroAuto)
		MostraErro()
		lRet := .F.
	ElseIf lGrvNat
		lRet := oModel:LoadValue("NURDETAIL", "NUR_NATURE", cNatFech)
	EndIf

EndIf

cFilAnt := cFilOld

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA159BlqFN()
Bloqueia Forenecedor que está vinculado ao participante e a natureza
que está vinculada ao fornecedor.
Utilizado ao excluir o participante que está com o campo NUR_FORNAT == "1"

@param oModel   - Modelo de dados do participante
@param lNaturez - Utiliza Natureza Vinculada ao participante

@return lRet    - Alteração realizada com sucesso

@author Bruno Ritter
@since 01/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA159BlqFN(oModel, lNaturez)
Local lRet          := .T.
Local cCodPadr      := ""
Local cLojaForn     := ""
Local aCamposSED    := {}
Local aCamposSA2    := {}
Local cEscri        := oModel:GetValue("NURDETAIL", "NUR_CESCR")
Local cFilEscr      := JurGetDados("NS7", 1, xFilial("NS7") + cEscri, "NS7_CFILIA")
Local cFilOld       := cFilAnt
Local cNatureza     := ""
Local aAreaSED      := {}

Private lMsErroAuto := .F.

Default oModel      := FwModelActive()
Default lNaturez    := .F.

cCodForn  := oModel:GetValue("RD0MASTER","RD0_FORNEC" )
cLojaForn := oModel:GetValue("RD0MASTER","RD0_LOJA"   )

If (oModel:GetValue("NURDETAIL", "NUR_FORNAT") == "1" .AND. !Empty(cCodForn) .AND. !Empty(cLojaForn))
	cFilAnt := cFilEscr

	Begin Transaction
		DbSelectArea("SA2")
		DbSetOrder(1)
		If (DbSeek(xFilial("SA2") + cCodForn + cLojaForn))
			cCodPadr := SA2->A2_NATUREZ

			aAdd(aCamposSA2,{"A2_COD"    , cCodForn  , Nil})
			aAdd(aCamposSA2,{"A2_LOJA"   , cLojaForn , Nil})
			aAdd(aCamposSA2,{"A2_MSBLQL" , "1"       , Nil})
			lMsErroAuto    := .F.
			MsExecAuto( { |x, y| MATA020(x, y) }, aCamposSA2, 4 )

			If(lMsErroAuto)
				lRet := .F.
				DisarmTransaction()
				break
			EndIf

			If(!Empty(cCodPadr))
				aAdd(aCamposSED,{"ED_CODIGO" , cCodPadr, Nil})
				aAdd(aCamposSED,{"ED_MSBLQL" , "1"     , Nil})
				lMsErroAuto    := .F.
				MsExecAuto( { |x, y| FINA010(x, y) }, aCamposSED, 4 )
				If(lMsErroAuto)
					lRet := .F.
					DisarmTransaction()
					break
				EndIf
			EndIf
		EndIf

		// Bloqueia a natureza do fechamento financeiro
		If lNaturez
			cNatureza := oModel:GetValue("NURDETAIL", "NUR_NATURE")
			If(!Empty(cNatureza))
				aAreaSED := SED->(GetArea())
				SED->(DbSetOrder(1)) // ED_FILIAL + ED_CODIGO
				If SED->(DbSeek(xFilial("SED") + cNatureza))
					aCamposSED := {}
					aAdd(aCamposSED, {"ED_CODIGO", cNatureza, Nil})
					aAdd(aCamposSED, {"ED_MSBLQL", "1"      , Nil})
					lMsErroAuto := .F.
					MsExecAuto( { |x, y| FINA010(x, y) }, aCamposSED, 4 )
					If(lMsErroAuto)
						lRet := .F.
						DisarmTransaction()
						Break
					EndIf
				EndIf
				RestArea(aAreaSED)
				JurFreeArr(@aAreaSED)
			EndIf
		EndIf
	End Transaction

	If(lMsErroAuto)
		Mostraerro()
		lRet := .F.
	EndIf

	cFilAnt := cFilOld
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA159VlFoN(oModel)
Validação para gerar o Fornecedor e Natureza Financeira automaticamente
(NUR_FORNAT == "1")

@author Bruno Ritter
@since 01/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA159VlFoN(oModel)
Local lRet       := .T.
Local oModelRD0  := oModel:GetModel( "RD0MASTER" )
Local cTlForNat  := ""
Local cTlTpJur   := ""
Local cTlCampo   := ""
Local xRetNatPar := &(SuperGetMV('MV_JNATPAR', .F., "PART" + FwFldGet("RD0_SIGLA")))
Local cRetNatPar := ""
Local cCodFor    := ""
Local cLojFor    := ""
Local cCodNat    := ""
Local cMsgConf   := ""
Local lInclFor   := .F.
Local lInclNat   := .F.
Local cFilSa2    := J159FilSa2("", oModel)

	If (oModel:GetValue("NURDETAIL", "NUR_FORNAT") == "1") .And.;
		oModel:GetOperation() != OP_EXCLUIR

		cTlForNat  := AllTrim(RetTitle("NUR_FORNAT"))

		//Valida se o participante é do Jurídico
		If( lRet .And. FwFldGet("RD0_TPJUR") != "1")
			cTlTpJur   := AllTrim(RetTitle("RD0_TPJUR"))
			lRet := JurMsgErro(I18N(STR0035, {cTlForNat, cTlTpJur}),; //"Só é possível escolher a opção 'Sim' no campo '#1', quando o campo '#2' estiver com a opção 'Sim' selecionado!"
			               "JA159VlFoN",;
			               STR0036; //"Informe um valor válido:"
			          +CRLF+I18N(STR0037, {cTlTpJur, cTlForNat}) ; //"1) Escolha a opção 'Sim' no campo '#1' para manter o valor do campo '#2'"
			          +CRLF+I18N(STR0038, {cTlForNat, cTlTpJur}) ) //"2) Escolha a opção 'Não' no campo '#1' para manter o valor do campo '#2'"
		EndIf

		//Valida os Campos obrigatórios para gerar o Fornecedor
		If lRet
			Do Case
				Case Empty(oModelRD0:GetValue("RD0_END"))
					cTlCampo := AllTrim(RetTitle("RD0_END"))

				Case Empty(oModelRD0:GetValue("RD0_UF"))
					cTlCampo := AllTrim(RetTitle("RD0_UF"))

				Case Empty(oModelRD0:GetValue("RD0_MUN"))
					cTlCampo := AllTrim(RetTitle("RD0_MUN"))

				Otherwise
					cTlCampo := ""
			EndCase

			If(!Empty(cTlCampo))
				lRet := JurMsgErro(I18N(STR0039, {cTlCampo, cTlForNat}),; //"O campo '#1' do Participante é obrigatório quando a opção do campo '#2' for igual a 'Sim'!"
				           "JA159VlFoN",;
				           STR0036; //"Informe um valor válido:"
				      +CRLF+I18N(STR0040, {cTlCampo}) ; //"1) Informe um valor válido para o campo '#1'"
				      +CRLF+I18N(STR0038, {cTlForNat, cTlCampo}) ) //"2) Escolha a opção 'Não' no campo '#1' para manter o valor do campo '#2'"
			EndIf
		EndIf

		//Valida o retorno do Parâmetro MV_JNATPAR
		If lRet .And. (ValType(xRetNatPar) != "C" .Or. Empty(xRetNatPar))
			lRet := JurMsgErro(STR0041,; //"O retorno ou valor do parâmetro MV_JNATPAR está com um valor inválido"
			           "JA159VlFoN",;
			           STR0042) //"Para gerar a Natureza Financeira e o Fornecedor automaticamente, informe uma fórmula válida no parâmetro MV_JNATPAR."
		Else
			cRetNatPar := AvKey(xRetNatPar, "ED_CODIGO")
		EndIf

		//Valida se não vai dar problema em criar o Fornecedor devido a chave única
		cCodFor  := oModelRD0:GetValue("RD0_FORNEC")
		cLojFor  := oModelRD0:GetValue("RD0_LOJA")
		lInclFor := Empty(cCodFor)

		If lRet .And. lInclFor //Código do Fornecedor Vazio

			aNewFornec := J149NewFor(oModel)
			If !Empty(JurGetDados('SA2', 1, cFilSa2 + aNewFornec[1] + aNewFornec[2], 'A2_COD'))
				lRet := JurMsgErro(I18N(STR0047, {aNewFornec[1]}),; //"Não foi possível criar o Fornecedor, pois já existe um Fornecedor com o código = '#1'!"
				       "JA159VlFoN",;
				       I18N(STR0048, {aNewFornec[1]})) //"Verifique o Fornecedor com o código = '#1'."
			EndIf
		EndIf

		//Valida se não vai dar problema em criar a Natureza devido a chave única
		cCodNat  := ""
		cCodNat  :=  Iif(!Empty(cCodFor), JurGetDados('SA2', 1, cFilSa2 + cCodFor+cLojFor, 'A2_NATUREZ'), )
		lInclNat :=  Empty(cCodNat)
		If lRet .And. lInclNat
			If( !Empty(JurGetDados('SED', 1, xFilial('SED') + cRetNatPar, 'ED_CODIGO')) )
				lRet := JurMsgErro(I18N(STR0043, {cRetNatPar}),; //"Não foi possível criar a Natureza Financeira, pois já existe uma Natureza Financeira com o código = '#1'!"
				       "JA159VlFoN",;
				        STR0044; //"Verifique:"
				       +CRLF+I18N(STR0045, {cRetNatPar}); //"1) A Natureza Financeira com o código = '#1';"
				       +CRLF+STR0046 ) //"2) O parâmetro MV_JNATPAR."
			EndIf
		EndIf

		If lRet .And. (lInclNat .Or. lInclFor)
			cMsgConf := CRLF+STR0050//"Será criado(a):"
			cMsgConf += Iif(lInclFor, CRLF+STR0051,'')//"Um Fornecedor e será vinculado ao Participante atual."
			cMsgConf += CRLF+STR0052//"Uma Nautureza e será vinculada ao Fornecedor do Participante atual."
			cMsgConf += CRLF+STR0053//"Deseja continuar?"

			lRet := IIF(IsBlind(), lRet, ApMsgYesNo(cMsgConf, STR0054)) //"Atenção"

			If !lRet
				//#"Operação finalizada pelo usuário"
				//##"Para o sistema não criar automaticamente o Fornecedor e/ou a Natureza, altere o campo '#1' para '2-Não'"
				JurMsgErro(STR0055, 'JA159VlFoN', I18N(STR0056, {RetTitle("NUR_FORNAT")}))
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J159InCpoV
Inclui campos no view através da função AddField

@author Jorge Luis Branco Martins Junior
@since 22/09/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J159InCpoV(oView, oStruct)
Local aArea   := GetArea()
Local nI      := 0
Local aCampos := {}
Local aLgpd   := {}
Local cCampo  := ""
Local cOrdem  := GetSx3Cache('RD0_CC', 'X3_ORDEM')

//               Campo virtual   Campo Origem   When  F3
aAdd( aCampos, { 'RD0__CESCR'  , 'NUR_CESCR'  , .T. , "NS7ATV" } )
aAdd( aCampos, { 'RD0__DESCR'  , 'NUR_DESCR'  , .F. , ""       } )

For nI := 1 To Len(aCampos)

	cCampo := aCampos[nI][2]

	oStruct:AddField( ;
	aCampos[nI][1]                     , ; // [01] Campo
	cOrdem                             , ; // [02] Ordem
	GetSx3Cache( cCampo, 'X3_TITULO' ) , ; // [03] Titulo
	GetSx3Cache( cCampo, 'X3_DESCRIC') , ; // [04] Descricao
	                                   , ; // [05] Help
	'GET'                              , ; // [06] Tipo do campo   COMBO, Get ou CHECK
	'@X'                               , ; // [07] Picture
	                                   , ; // [08] PictVar
	aCampos[nI][4]                     , ; // [09] F3
	aCampos[nI][3]                     , ; // [10] When
	"1"                                , ; // [11] Folder
	                                   , ; // [12] Group
	                                   , ; // [13] Lista Combo
	                                   , ; // [14] Tam Max Combo
	                                   , ; // [15] Inic. Browse
	.T.                                )   // [16] Virtual

	aAdd(aLgpd, {aCampos[nI][1], aCampos[nI][2]})

Next

If FindFunction("JPDOfusca")
	JPDOfusca(@oStruct, aLgpd)
EndIf

RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J159InCpoM
Inclui campos no model através da função AddField

@author Jorge Luis Branco Martins Junior
@since 22/09/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J159InCpoM(oModel,oStruct)
Local aArea    := GetArea()
Local nI       := 0
Local aCampos  := {}
Local aTam     := {}
Local cCampo   := ""

	//               Campo Virtual  Campo Origem    Validação                                Inicializador Padrão
	aAdd( aCampos, { 'RD0__CESCR'  ,'NUR_CESCR'   , { || J159SetVal(@oModel) }, { || J159IniPad('RD0__CESCR', oModel) } } )
	aAdd( aCampos, { 'RD0__DESCR'  ,'NUR_DESCR'   , { || .T. }                , { || J159IniPad('RD0__DESCR', oModel) } } )

	For nI := 1 To Len(aCampos)

		cCampo   := aCampos[nI][2]
		aTam     := TamSx3(cCampo)

		oStruct:AddField( ;
		GetSx3Cache( cCampo, 'X3_TITULO'  ) , ; // [01] Titulo do campo // "Importar Arquivo"
		GetSx3Cache( cCampo, 'X3_DESCRIC' ) , ; // [02] ToolTip do campo // "Importar Arquivo"
		aCampos[nI][1]                      , ; // [03] Id do Field
		aTam[3]                             , ; // [04] Tipo do campo
		aTam[1]                             , ; // [05] Tamanho do campo
		aTam[2]                             , ; // [06] Decimal do campo
		aCampos[nI][3]                      , ; // [07] Code-block de validação do campo
		                                    , ; // [08] Code-block de validação When do campo
		                                    , ; // [09] Lista de valores permitido do campo
		.F.                                 , ; // [10] Indica se o campo tem preenchimento obrigatório
		aCampos[nI][4]                      , ; // [11] Bloco de código de inicializacao do campo
		                                    , ; // [12] Indica se trata-se de um campo chave
		                                    , ; // [13] Indica se o campo não pode receber valor em uma operação de update
		.T.                                   ) // [14] Indica se o campo é virtual

	Next

	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J159SetVal
Preenche os valores dos campos de escritório na tabela NUR após
o preenchimento do campo virtual posicionado na RD0

@author Jorge Luis Branco Martins Junior
@since 22/09/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J159SetVal(oModel)
Local cCodEscri := oModel:GetValue("RD0MASTER","RD0__CESCR" ) // Escritório
Local aDados    := JurGetDados("NS7", 1 , xFilial("NS7") + cCodEscri, {"NS7_ATIVO","NS7_NOME"})
Local lRet      := .F.

If Empty(cCodEscri)

	lRet := .T.

	oModel:SetValue("NURDETAIL", "NUR_CESCR" , "" )
	oModel:LoadValue("RD0MASTER", "RD0__DESCR", "" )

ElseIf Len(aDados) > 1

	lRet := aDados[1] == "1" // Vazio ou escritório ativo

	If lRet
		oModel:SetValue("NURDETAIL", "NUR_CESCR" , cCodEscri )
		oModel:LoadValue("RD0MASTER", "RD0__DESCR", aDados[2] )
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J159IniPad
Inicializador padrão dos campos virtuais

@param  cCampo  Campo que será preenchido
@param  oModel  Modelo de dados do participante

@return cRet    Conteúdo do campo

@author Jorge Luis Branco Martins Junior
@since 22/09/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J159IniPad(cCampo, oModel)
Local cRet    := ''
Local cEscri  := ''

	If oModel:GetOperation() <> MODEL_OPERATION_INSERT
	
		cEscri := JurGetDados("NUR", 1, xFilial("NUR") + RD0->RD0_CODIGO, "NUR_CESCR")
	
		If cCampo == 'RD0__CESCR'
			cRet := cEscri
		ElseIf cCampo == 'RD0__DESCR'
			cRet := JurGetDados("NS7", 1, xFilial("NS7") + cEscri, "NS7_NOME")
		EndIf
	
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J159PrtNat
Função para buscar a natureza do participante.

@param cPart    , Código do participante para busca.
@param lValid   , Se não achar a natureza irá apresentar uma mensagem de erro.
@param lExibeErr, Se o erro será exibido.
@param aError   , Váriavel para receber o erro e a solução.

@author bruno.ritter
@since 18/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J159PrtNat(cPart, lValid, lExibeErr, aError)
Local cNatureza  := ""
Local cQuery     := ""
Local cSigla     := ""
Local cQueryRes  := GetNextAlias()
Local cTitSigla  := ""
Local cTitNatSE2 := ""
Local cFilSa2    := J159FilSa2(cPart)

Default lValid    := .F.
Default lExibeErr := .F.
Default aError    := {}

If !Empty(cPart)
	cQuery := " SELECT SED.ED_CODIGO"
	cQuery +=   " FROM "+RetSqlName("RD0")+" RD0"
	cQuery +=   " INNER JOIN "+RetSqlName("SA2")+" SA2 "
	cQuery +=      " ON SA2.A2_FILIAL = '" + cFilSa2 + "'"
	cQuery +=      " AND SA2.D_E_L_E_T_ = ' '"
	cQuery +=      " AND SA2.A2_COD = RD0.RD0_FORNEC"
	cQuery +=      " AND SA2.A2_LOJA = RD0.RD0_LOJA"
	cQuery +=   " INNER JOIN "+RetSqlName("SED")+" SED"
	cQuery +=      " ON SED.ED_FILIAL = '" + xFilial( "SED" ) + "'"
	cQuery +=      " AND SED.D_E_L_E_T_ = ' '"
	cQuery +=      " AND SED.ED_CODIGO = SA2.A2_NATUREZ"
	cQuery += " WHERE RD0.RD0_CODIGO = '"+cPart+"'"
	cQuery +=      " AND RD0.D_E_L_E_T_ = ' '"
	cQuery +=      " AND RD0.RD0_FILIAL = '" + xFilial( "RD0" ) + "'"

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQueryRes, .T., .F. )

	If !(cQueryRes)->(EOF())
		cNatureza := (cQueryRes)->ED_CODIGO
	EndIf

	(cQueryRes)->(DbCloseArea())

	If lValid .And. Empty(cNatureza)
		cSigla     := JurGetDados("RD0", 1, xFilial("RD0") + cPart, "RD0_SIGLA")
		cTitSigla  := Alltrim(RetTitle("RD0_SIGLA"))
		cTitNatSE2 := Alltrim(RetTitle("A2_NATUREZ"))
		aAdd(aError, i18n(STR0064, {cPart, cTitSigla, cSigla})) // "Não foi encontrado uma natureza para o participante '#1', #2: '#3'."
		aAdd(aError, i18n(STR0063, {cTitNatSE2})) // "Verifique o campo '#1' no cadastro do fornecedor vinculado ao participante."
		If lExibeErr
			JurMsgErro(aError[1], , aError[2])
		EndIf
	EndIf
EndIf

Return cNatureza

//-------------------------------------------------------------------
/*/{Protheus.doc} J159Clilj(oModel, cCpoGatilh)
Rotina para retornar o cliente e loja para o fornecedor do participante
Valid do campo RD0_SIGLA (Implementado em código)

@Param oModel  Modelo de dados da tabela de participantes RDO
@Param cValor  Valor do digitado no campo RD0_SIGLA

@author Luciano Pereira dos Santos

@since 18/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J159Clilj(oModel, cCpoGatilh)
Local lRet         := .T.
Local lForValido   := .T.
Local oModelRD0    := oModel:GetModel("RD0MASTER")
Local oModelNUR    := oModel:GetModel("NURDETAIL")
Local oModelFIL    := oModel:Getmodel("FILDETAIL")
Local cFornec      := oModelRD0:GetValue("RD0_FORNEC")
Local cLojaForn    := oModelRD0:GetValue("RD0_LOJA")
Local lMovFin      := oModelNUR:GetValue("NUR_FORNAT") == "1"
Local lExcluir     := oModel:GetOperation() == OP_EXCLUIR
Local aNewFornec   := {}
Local nTotalLn     := 0
Local nLine        := 1

Default cCpoGatilh := ""

If !lExcluir .And. lMovFin .And. ( Empty(cFornec) .Or. Empty(cLojaForn) )

	aNewFornec := J149NewFor(oModel)
	lRet := oModelRD0:LoadValue("RD0_FORNEC", aNewFornec[1])
	lRet := lRet .And. oModelRD0:LoadValue("RD0_LOJA", aNewFornec[2])

EndIf

If !lMovFin .And. cCpoGatilh == "NUR_FORNAT" .And. ( !Empty(cLojaForn) .Or. !Empty(cLojaForn) )
	//Verificar se o fornecedor está valido, pois pode ter sido preenchido pelo loadvalue
	// e o usuário alterar o campo NUR_FORNAT para "2-não"
	oModelRD0:LoadValue("RD0_FORNEC", "")
	oModelRD0:LoadValue("RD0_LOJA", "")
	lForValido := oModelRD0:SetValue("RD0_FORNEC", cFornec) .And. oModelRD0:SetValue("RD0_LOJA", cLojaForn)

	If !lForValido
		//Pega o erro para não mostrar ao usuário
		oModel:GetErrorMessage(.T.)

		oModelRD0:LoadValue("RD0_FORNEC", "")
		oModelRD0:LoadValue("RD0_LOJA", "")

		nTotalLn := oModelFIL:GetQTDLine()
		If nTotalLn > 0
			For nLine := 1 to nTotalLn
				oModelFIL:GoLine(nLine)

				If oModelFIL:IsInserted()
					oModelFIL:DeleteLine()
				EndIf
			Next nLine
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J149NewFor
Retorna o código/loja para cadastro de um novo fornecedor

@Param oModel  Modelo de dados da tabela de participantes RDO

@Return aNewFornec := {Código do Fornecedor, Loja do fornecedor}

@author Bruno Ritter
@since 02/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J149NewFor(oModel)
Local cClieForn  := CriaVar("A2_COD", .T.)
Local cLojaForn  := CriaVar("A2_LOJA", .T.)
Local aNewFornec := {}

Default oModel   := FwModelActive()

	If Empty(cClieForn)
		cClieForn := AvKey(oModel:GetValue("RD0MASTER", "RD0_SIGLA"), "A2_COD" )
	EndIf

	If Empty(cLojaForn)
		cLojaForn := AvKey(Iif(Empty(cClieForn), "", "01"), "A2_LOJA")
	EndIf

	aNewFornec := {cClieForn, cLojaForn}

Return aNewFornec
//-------------------------------------------------------------------
/*/{Protheus.doc} J159JurCmps
Retorna array com campos que são utilizados no cadastro pelo sigajuri

@Return aCampos array com campos que serão utilizados no cadastro

@author Brenno Gomes
@since 23/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J159JurCmps()
	local aCampos := {}

	aAdd(aCampos, "RD0_CODIGO")
	aAdd(aCampos, "RD0_NOME")
	aAdd(aCampos, "RD0_TIPO")
	aAdd(aCampos, "RD0_SEXO")
	aAdd(aCampos, "RD0_DTNASC")
	aAdd(aCampos, "RD0_CIC")
	aAdd(aCampos, "RD0_DTADMI")
	aAdd(aCampos, "RD0_END")
	aAdd(aCampos, "RD0_CMPEND")
	aAdd(aCampos, "RD0_CEP")
	aAdd(aCampos, "RD0_BAIRRO")
	aAdd(aCampos, "RD0_UF")
	aAdd(aCampos, "RD0_MUN")
	aAdd(aCampos, "RD0_EMAIL")
	aAdd(aCampos, "RD0_EMAILC")
	aAdd(aCampos, "RD0_USER")
	aAdd(aCampos, "RD0_MSBLQL")
	aAdd(aCampos, "RD0_TPJUR")
	aAdd(aCampos, "RD0_SIGLA")
	aAdd(aCampos, "NUR_OAB")
	aAdd(aCampos, "NUR_APELI")

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} J159CmpJur
Retira a obrigatoriedade de campos e altera inicializador padrão caso a integração com o PFS esteja desabilitada

@Param oStruct  Estrutura

@author Brenno Gomes
@since 23/01/2019
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function J159CmpJur(oStruct)

	oStruct:SetProperty( 'NUR_SOCIO' , MODEL_FIELD_INIT   , {|| "1"} )
	oStruct:SetProperty( 'NUR_HRDIAD', MODEL_FIELD_INIT   , {|| "08:00"} )
	oStruct:SetProperty( 'NUR_REVFAT', MODEL_FIELD_INIT   , {|| "1"} )
	oStruct:SetProperty( 'NUR_CCAT'  , MODEL_FIELD_OBRIGAT, .F.)
	oStruct:SetProperty( 'NUR_APELI' , MODEL_FIELD_OBRIGAT, .F.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J159FilSa2
Função filial do fornecedor vinculado ao participante

@param cPart    , Código do participante para busca.
@param oModel   , Modelo do participante para busca.

@author Bruno Ritter
@since 12/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J159FilSa2(cPart, oModel)
	Local cFilSa2  := ""
	Local cEscri   := ""
	Local cFilEscr := ""

	Default cPart  := ""
	Default oModel := Nil

	If !Empty(oModel)
		cEscri := oModel:GetValue("NURDETAIL", "NUR_CESCR")
	Else
		cEscri := JurGetDados("NUR", 1, xFilial("NUR") + cPart, "NUR_CESCR")
	EndIf

	cFilEscr := JurGetDados("NS7", 1, xFilial("NS7") + cEscri, "NS7_CFILIA")

	cFilSa2 := FWxFilial("SA2", cFilEscr)


Return cFilSa2

//-------------------------------------------------------------------
/*/{Protheus.doc} JVldRD0Sgl
Função para validar se já possui SIGLA cadastrada - RD0_SIGLA

@return lRet .T. - Não possui participante com a SIGLA
             .F. - possui participante cadastrado com a SIGLA

@since 26/03/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function JVldRD0Sgl( oModel )

Local oModelRD0 := oModel:GetModel("RD0MASTER")
Local cPartJuri := oModelRD0:GetValue("RD0_TPJUR")     //-- Indica se participa do módulo Juridico - 1=Sim / 2=Nao
Local cSglPart  := oModelRD0:GetValue("RD0_SIGLA")
Local lRet      := .T.
Local cQry      := ""
Local aArea     := GetArea()
Local cAliasRD0 := GetNextAlias()

	If cPartJuri == "1" .AND. oModelRD0:IsFieldUpdated('RD0_SIGLA')

		cQry := " SELECT RD0_SIGLA "
		cQry +=	" FROM " + RetSqlName("RD0") + " "
		cQry +=	" WHERE RD0_FILIAL = '" + xFilial("RD0") + "'"
		cQry +=		" AND UPPER(RD0_SIGLA) = '" + UPPER(cSglPart) + "'"
		cQry +=		" AND D_E_L_E_T_ = ' ' "

		cQry := ChangeQuery(cQry)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQry), cAliasRD0, .F., .F. )

		While !(cAliasRD0)->(EOF())
			lRet := .F.
			oModel:SetErrorMessage("RD0MASTER", "RD0_SIGLA", "RD0MASTER", "RD0_SIGLA", "JVldRD0Sgl", STR0034, STR0065, cSglPart, "") //"A Sigla do Participante informada já existe" / "Utilize uma sigla diferente"
			Exit
		End
		
		(cAliasRD0)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ja159NatDup
Função para verificar se existem naturezas duplicadas

@param cRegs    - Registros duplicados
@param cCodPart - Participante
@param cFornec  - Fornecedor
@param cLoja    - Loja
@param cNatAnt  - Natureza vinculada ao participante
@param lNaturez - Utiliza Natureza vinculada ao participante

@return lRet    - Existem Registros duplicados

@author fabiana.silva
@since  05/11/2020
/*/
//-------------------------------------------------------------------
Function Ja159NatDup(cRegs, cCodPart, cFornec, cLoja, cNatAnt, lNaturez)
Local cQuery    := ""  // Query do Participante
Local cSubQry   := ""  // Subquery do Participante
Local cAliasTmp := ""  // Alias Temporário
Local cLim      := "1" // Limite de Participantes
Local lRet      := .F. // Natureza Duplicada?
Local lLGPD     := FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.)
Local lFuncPrt  := lLGPD .AND. FindFunction("Ja284CmpPr")
Local aOfPart   := {"A2_NATUREZ", "NUR_CPART", "RD0_SIGLA", "RD0_NOME", "RDZ_CODENT"}
Local aStruQry  := {}
Local nTamRAFil := SRA->(TamSX3("RA_FILIAL")[1]) + 1
Local cColNat   := "A2_NATUREZ"
Local cNatVaz   := Space(TamSx3("A2_NATUREZ")[1])

Default cRegs    := ""
Default cCodPart := ""
Default cFornec  := ""
Default cLoja    := ""
Default cNatAnt  := ""
Default lNaturez := !Empty(SuperGetMv("MV_JNATFEP",.F.,"")) .And. NUR->(ColumnPos("NUR_NATURE")) > 0

	If lNaturez
		cColNat := "NUR_NATURE"
	EndIf

	If !Empty(cFornec + cLoja)
		cLim := "0"
		If !lNaturez
			cNatAnt := GetAdvFVal('SA2', "A2_NATUREZ", xFilial('SA2') + cFornec + cLoja, 1, "")
		EndIf
	EndIf

	If lLGPD
		aStruQry := FwProtectedDataUtil():UsrNoAccessFieldsInList(aOfPart)
		aOfPart := {}
		AEval(aStruQry, {|x| AAdd( aOfPart, x:CFIELD)})
	EndIf

	// Somente consulta se não for participante (todos rotina de fechamento participante ou existir natureza vinculada)
	If Empty(cCodPart) .Or. !Empty(cNatAnt)

		cAliasTmp := GetNextAlias()

		If !lNaturez
			cSubQry +=    " FROM " + RetSqlName("SA2") + " SA2 "
			cSubQry +=   " INNER JOIN " + RetSqlName("RD0") + " RD0 "
			cSubQry +=      " ON RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
			cSubQry +=     " AND RD0.RD0_FORNEC = SA2.A2_COD " // Solicitante
			cSubQry +=     " AND RD0.RD0_LOJA = SA2.A2_LOJA " // Solicitante
			cSubQry +=     " AND RD0.RD0_TPJUR  = '1' " // Solicitante
			If !Empty(cCodPart)
				cSubQry += " AND RD0.RD0_CODIGO <> '" + cCodPart + "' " // Solicitante
			EndIf
			cSubQry +=     " AND RD0.D_E_L_E_T_ = ' ' "
			cSubQry +=   " INNER JOIN " + RetSqlName("NUR") + " NUR "
			cSubQry +=      " ON NUR.NUR_FILIAL = '" + xFilial("NUR") + "' "
			cSubQry +=     " AND RD0.RD0_CODIGO = NUR.NUR_CPART " // Solicitante
			cSubQry +=     " AND NUR.NUR_FORNAT = '1' " // Solicitante
			If !Empty(cCodPart)
				cSubQry += " AND NUR.NUR_CPART <> '" + cCodPart + "' " // Solicitante
			EndIf
			cSubQry +=     " AND NUR.D_E_L_E_T_ = ' ' "
			cSubQry +=    " LEFT JOIN " +RetSqlName("RDZ")+" RDZ "
			cSubQry +=      " ON RDZ.RDZ_FILIAL = '" + xFilial("RDZ") + "' "
			cSubQry +=     " AND RDZ.RDZ_CODRD0 = RD0.RD0_CODIGO" // Solicitante
			cSubQry +=     " AND RDZ_ENTIDA = 'SRA' "
			cSubQry +=     " AND RDZ_EMPENT = '" + cEmpAnt + "' "
			cSubQry +=     " AND RDZ_FILENT = '" + cFilAnt + "' " // Solicitante
			cSubQry +=     " AND RDZ.D_E_L_E_T_ = ' ' "
			cSubQry +=   " WHERE SA2.A2_FILIAL = '" + xFilial("SA2") + "' "
			cSubQry +=     " AND SA2.D_E_L_E_T_ = ' ' "
			If !Empty(cNatAnt)
				cSubQry += " AND SA2.A2_NATUREZ = '" + cNatAnt + "' "
			EndIf
		Else
			cSubQry +=    " FROM " +  RetSqlName("RD0") + " RD0 "
			cSubQry +=   " INNER JOIN " + RetSqlName("NUR") + " NUR "
			cSubQry +=      " ON NUR.NUR_FILIAL = '" + xFilial("NUR") + "' "
			cSubQry +=     " AND RD0.RD0_CODIGO = NUR.NUR_CPART " // Solicitante
			cSubQry +=     " AND NUR.NUR_FORNAT = '1' " // Solicitante
			If !Empty(cCodPart)
				cSubQry += " AND NUR.NUR_CPART <> '" + cCodPart + "' " // Solicitante
			EndIf
			If !Empty(cNatAnt)
				cSubQry += " AND NUR.NUR_NATURE = '" + cNatAnt + "' "
			EndIf
			cSubQry +=     " AND NUR.D_E_L_E_T_ = ' ' "
			cSubQry +=    " LEFT JOIN " +RetSqlName("RDZ")+" RDZ "
			cSubQry +=      " ON RDZ.RDZ_FILIAL = '" + xFilial("RDZ") + "' "
			cSubQry +=     " AND RDZ.RDZ_CODRD0 = RD0.RD0_CODIGO" // Solicitante
			cSubQry +=     " AND RDZ_ENTIDA = 'SRA' "
			cSubQry +=     " AND RDZ_EMPENT = '" + cEmpAnt + "' "
			cSubQry +=     " AND RDZ_FILENT = '" + cFilAnt + "' " // Solicitante
			cSubQry +=     " AND RDZ.D_E_L_E_T_ = ' ' "
			cSubQry +=   " WHERE RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
			cSubQry +=     " AND RD0.RD0_TPJUR  = '1' " // Solicitante
			If !Empty(cCodPart)
				cSubQry += " AND RD0.RD0_CODIGO  <> '" + cCodPart + "' " // Solicitante
			EndIf
			cSubQry +=     " AND RD0.D_E_L_E_T_ = ' ' "
		EndIf

		cQuery := "SELECT X.* FROM ( "
		cQuery +=                    " SELECT " + cColNat + ", COUNT(NUR.NUR_CPART) AS PARTICIP "
		cQuery +=                             cSubQry
		cQuery +=                     " GROUP BY " + cColNat + " "
		cQuery +=                " ) X "
		cQuery += " WHERE X." + cColNat + "<> '" + cNatVaz + "' AND X.PARTICIP > " + cLim
		
		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTmp, .T., .F.)

		If lRet := (cAliasTmp)->(!Eof())

			(cAliasTmp)->(DbCloseArea())

			cQuery := " SELECT " + cColNat + ", NUR.NUR_CPART, RD0.RD0_SIGLA,  RD0.RD0_NOME,  RDZ.RDZ_CODENT "
			cQuery +=          cSubQry
			cQuery +=            " AND " + cColNat + " IN "
			cQuery +=                "("
			cQuery +=                  " SELECT X." + cColNat
			cQuery +=                    " FROM ( "
			cQuery +=                             " SELECT " + cColNat + ", COUNT(NUR.NUR_CPART) AS PARTICIP "
			cQuery +=                                      cSubQry
			cQuery +=                              " GROUP BY " + cColNat
			cQuery +=                         " ) X "
			cQuery +=                   " WHERE X." + cColNat + "<> '" + cNatVaz + "' AND X.PARTICIP > " + cLim
			cQuery +=                ")"
			cQuery +=          " ORDER BY " + cColNat + ", NUR.NUR_CPART, RD0.RD0_SIGLA, RD0.RD0_NOME, RDZ.RDZ_CODENT "

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T., 'TOPCONN', TcGenQry(,, cQuery), cAliasTmp, .T., .F.)
			
			cRegs += CRLF + STR0069 // "Natureza - Participante - Sigla - Nome - Funcionário"

			Do While (cAliasTmp)->(!Eof())
				If !lLGPD .OR. !lFuncPrt
					cRegs += CRLF + space(3) + AllTrim((cAliasTmp)->&(cColNat)) + " - " + ;
					                           AllTrim((cAliasTmp)->NUR_CPART)  + " - " + ;
					                           AllTrim((cAliasTmp)->RD0_SIGLA)  + " - " + ;
					                           AllTrim((cAliasTmp)->RD0_NOME)   + " - " + ;
					                           AllTrim(Substr( (cAliasTmp)->RDZ_CODENT, nTamRAFil))
				Else
					cRegs += CRLF + space(3) + AllTrim(Ja284CmpPr(cAliasTmp, cColNat    , aOfPart)) + " - " + ;
					                           AllTrim(Ja284CmpPr(cAliasTmp, "NUR_CPART", aOfPart)) + " - " + ;
					                           AllTrim(Ja284CmpPr(cAliasTmp, "RD0_SIGLA", aOfPart)) + " - " + ;
					                           AllTrim(Ja284CmpPr(cAliasTmp, "RD0_NOME" , aOfPart)) + " - " + ;
					                           AllTrim(Substr(Ja284CmpPr( cAliasTmp, "RDZ_CODENT", aOfPart), nTamRAFil))
				EndIf

				(cAliasTmp)->(DbSkip(1))
			EndDo

		EndIf

		(cAliasTmp)->(DbCloseArea())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J159AtuBnk
Função para atualizar na SA2 os dados bancários.

@param oModel , Modelo do cadastro de participantes

@author Cristina Cintra
@since 27/01/2021
/*/
//-------------------------------------------------------------------
Static Function J159AtuBnk(oModel)
Local aBanco    := {}
Local oModelRD0 := Nil
Local oModelFIL := Nil

	If AliasInDic("FIL")

		oModelRD0 := oModel:GetModel("RD0MASTER")
		oModelFIL := oModel:GetModel("FILDETAIL")
		
		aBanco := JurGetDados("FIL", 1, xFilial("FIL") + oModelRD0:GetValue("RD0_FORNEC") + oModelRD0:GetValue("RD0_LOJA") + "1", {"FIL_BANCO", "FIL_AGENCI", "FIL_DVAGE", "FIL_CONTA", "FIL_DVCTA"})
		
		If Empty(aBanco)
			aBanco := {"", "", "", "", ""}
		EndIf

		If SA2->A2_COD == oModelRD0:GetValue("RD0_FORNEC") .And. SA2->A2_LOJA == oModelRD0:GetValue("RD0_LOJA")
			RecLock("SA2", .F.)
			SA2->A2_BANCO   := aBanco[1]
			SA2->A2_AGENCIA := aBanco[2]
			SA2->A2_DVAGE   := aBanco[3]
			SA2->A2_NUMCON  := aBanco[4]
			SA2->A2_DVCTA   := aBanco[5]
			SA2->A2_TIPCTA  := "1"
			SA2->(MsUnlock())
			SA2->(DbCommit())
		EndIf

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J159ValNat
Função que valida a Natureza

@param cCodCpo - Nome do Campo

@return lRet   - Natureza Válida

@author fabiana.silva
@since  11/03/2021
/*/
//-------------------------------------------------------------------
Function J159ValNat(cCodCpo)
Local lRet    := .T.
Local cCpo    := ""
Local cTpCJur := ""

	lRet := JurValNat(cCodCpo)

	If lRet
		cCpo := FwFldGet(cCodCpo)
		cTpCJur := JurGetDados("SED", 1, xFilial("SED") + cCpo, {"ED_TPCOJR"})
		If Empty(cTpCJur) .Or. !(cTpCJur $ "7")
			lRet := JurMsgErro(STR0072, , STR0070) // "Natureza inválida." ## "A natureza informada deve ser C.C. Profissional "
		EndIf
	EndIf

Return lRet
