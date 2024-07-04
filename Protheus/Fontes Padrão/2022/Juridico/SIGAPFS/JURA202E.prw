#INCLUDE "JURA202E.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA202E
Modelo simplificado de Pré-fatura para integração com o LegalDesk.

@author Cristina Cintra
@since 04/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA202E()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author Luciano Pereira dos Santos
@since 15/06/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { '', "VIEWDEF.JURA202E", 0, 2, 0, NIL } ) // "Visualizar"

Return aRotina



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados resumido de Pré-Fatura

@author Cristina Cintra
@since 04/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNX0 := FWFormStruct( 1, 'NX0',{ | cCampo | AllTrim(cCampo) $ "NX0_FILIAL|NX0_COD|NX0_SITUAC|NX0_DMAXEM|NX0_CCLIEN|NX0_CLOJA|NX0_VLFATH|NX0_DINITS|NX0_DFIMTS|NX0_DINIDP|NX0_DFIMDP|NX0_DINITB|NX0_DFIMTB|NX0_CESCR|NX0_CMOEDA|NX0_CIDIO|NX0_DTEMI|NX0_VLFATD|NX0_DESCON" } )  // Pré-fatura
Local oStructNX8 := FWFormStruct( 1, 'NX8',{ | cCampo | AllTrim(cCampo) $ "NX8_FILIAL|NX8_CPREFT|NX8_CCLIEN|NX8_CLOJA|NX8_CCONTR" })  // Contrato
Local oStructNX1 := FWFormStruct( 1, 'NX1',{ | cCampo | AllTrim(cCampo) $ "NX1_FILIAL|NX1_CPREFT|NX1_CCONTR|NX1_CCLIEN|NX1_CLOJA|NX1_CCASO|NX1_CPART"} )  // Caso
Local oStructNX4 := FWFormStruct( 1, 'NX4',{ | cCampo | AllTrim(cCampo) $ "NX4_FILIAL|NX4_COD|NX4_CPREFT|NX4_DTINC|NX4_HIST|NX4_USRINC|NX4_CPART|NX4_TIPO|NX4_AUTO|NX4_CPART1"})  // Histórico
Local oStructNUE := nil
Local oStructNVY := nil
Local oStructNV4 := nil
Local lRevisLD   := ( SuperGetMV("MV_JREVILD", .F., '2') == '1' ) //Controla a integracao da revisão de pré-fatura com o Legal Desk


oModel := MPFormModel():New( 'JURA202E', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
oModel:AddFields( 'NX0RMASTER', /*cOwner*/, oStructNX0, { || }/*bPreValidacao*/, { || }/*bPosValidacao*/, /*bLoad*/ )
oModel:AddGrid( 'NX4RDETAIL', 'NX0RMASTER', oStructNX4, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( 'NX8RDETAIL', 'NX0RMASTER', oStructNX8, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )
oModel:AddGrid( 'NX1RDETAIL', 'NX8RDETAIL', oStructNX1, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, /*bLoad*/ )
oModel:SetDescription( STR0001 ) //"Modelo de Dados Resumido da Pré-Fatura"

oModel:GetModel( 'NX0RMASTER' ):SetDescription( STR0001 ) //"Modelo de Dados de Pré-Fatura"
oModel:GetModel( 'NX4RDETAIL' ):SetDescription( STR0011 ) //"Dados dos Históricos da Pré-Fatura"
oModel:GetModel( 'NX8RDETAIL' ):SetDescription( STR0003 ) //"Dados dos Contratos da Pré-Fatura"
oModel:GetModel( 'NX1RDETAIL' ):SetDescription( STR0004 ) //"Dados dos Casos da Pré-Fatura"

//Histórico
oModel:SetRelation( 'NX4RDETAIL', { { 'NX4_FILIAL', "xFilial( 'NX4' )" }, { 'NX4_CPREFT', 'NX0_COD' } }, NX4->( "NX4_FILIAL + NX4_CPREFT + NX4_COD") )

//contratos da pré
oModel:SetRelation( 'NX8RDETAIL', { { 'NX8_FILIAL', "xFilial( 'NX8' )" }, { 'NX8_CPREFT', 'NX0_COD'    } }, NX8->( IndexKey (1) ) )

//Casos do contrato
oModel:SetRelation( 'NX1RDETAIL', { { 'NX1_FILIAL', "xFilial( 'NX1' )" }, { 'NX1_CPREFT', 'NX0_COD' }, { 'NX1_CCONTR', 'NX8_CCONTR' } }, NX1->( IndexKey (1) ) )

If lRevisLD
	If FindFunction('J300ChkVer') .AND. J300ChkVer("1.0.0")
		//Time Sheets da Pré
		oStructNUE := FWFormStruct( 1, 'NUE',{ | cCampo | AllTrim(cCampo) $ "NUE_FILIAL|NUE_COD"})  // TimeSheet
		oModel:AddGrid( 'NUERDETAIL', 'NX0RMASTER', oStructNUE)
		oModel:GetModel( 'NUERDETAIL' ):SetDescription( STR0012 ) //"Time Sheets da Pré-Fatura"
		oModel:SetRelation( 'NUERDETAIL', { { 'NUE_FILIAL', "xFilial( 'NUE' )" }, { 'NUE_CPREFT', 'NX0_COD'} }, NUE->( IndexKey (1) ))
		
		//DESPESA
		oStructNVY := FWFormStruct( 1, 'NVY',{ | cCampo | AllTrim(cCampo) $ "NVY_FILIAL|NVY_COD"})
		oModel:AddGrid( 'NVYRDETAIL', 'NX0RMASTER', oStructNVY)
		oModel:GetModel( 'NVYRDETAIL' ):SetDescription( STR0013 ) //"Despesas da Pré-Fatura"
		oModel:SetRelation( 'NVYRDETAIL', { { 'NVY_FILIAL', "xFilial( 'NVY' )" }, { 'NVY_CPREFT', 'NX0_COD'} }, NVY->( IndexKey (1) ))
		
		//Tabelados
		oStructNV4 := FWFormStruct( 1, 'NV4',{ | cCampo | AllTrim(cCampo) $ "NV4_FILIAL|NV4_COD"})
		oModel:AddGrid( 'NV4RDETAIL', 'NX0RMASTER', oStructNV4)
		oModel:GetModel( 'NV4RDETAIL' ):SetDescription( STR0014 ) //"Tabelados da Pré-Fatura"
		oModel:SetRelation( 'NV4RDETAIL', { { 'NV4_FILIAL', "xFilial( 'NV4' )" }, { 'NV4_CPREFT', 'NX0_COD'} }, NV4->( IndexKey (1) ))
	EndIf
EndIf

oModel:SetPrimaryKey( {"NX0_COD"} )

Return oModel
