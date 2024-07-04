#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA191.CH"                                                                   

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA191
Cadastro MVC dos Tipos de Documentos para GNRE Online

@author Rodrigo Aguilar
@since 26/09/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA191()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Cadastro dos Tipos de Documentos de Origem para emissão da GNRE Online"
oBrw:SetAlias( 'C6T')
oBrw:SetMenuDef( 'TAFA191' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rodrigo Aguilar
@since 26/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA191" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 26/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC6T 	:= 	FWFormStruct( 1, 'C6T' )
Local oModel 	:= 	MPFormModel():New( 'TAFA191' )

oModel:AddFields('MODEL_C6T', /*cOwner*/, oStruC6T)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 26/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA191' )
Local 	oStruC6T 	:= 	FWFormStruct( 2, 'C6T' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C6T', oStruC6T, 'MODEL_C6T' )

oView:EnableTitleView( 'VIEW_C6T', STR0001 ) //"Cadastro dos Tipos de Documentos de Origem para emissão da GNRE Online"
oView:CreateHorizontalBox( 'FIELDSC6T', 100 )
oView:SetOwnerView( 'VIEW_C6T', 'FIELDSC6T' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1003

If nVerEmp < nVerAtu
	aAdd( aHeader, "C6T_FILIAL" )
	aAdd( aHeader, "C6T_ID" )
	aAdd( aHeader, "C6T_CODIGO" )
	aAdd( aHeader, "C6T_DESCRI" )
	aAdd( aHeader, "C6T_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "Nota Fiscal Avulsa", "" } )
	aAdd( aBody, { "", "000002", "04", "DI - Declaracao de Importacao", "" } )
	aAdd( aBody, { "", "000003", "05", "DMI - Declaracao de Mercadorias Importadas", "" } )
	aAdd( aBody, { "", "000004", "06", "DSI - Declaracao Simplificada de Importacao", "" } )
	aAdd( aBody, { "", "000005", "07", "Conhecimento de Transporte Rodoviario", "" } )
	aAdd( aBody, { "", "000006", "08", "Conhecimento de Transporte Aereo", "" } )
	aAdd( aBody, { "", "000007", "10", "Nota Fiscal", "" } )
	aAdd( aBody, { "", "000008", "12", "TERMO DE INFRAC.O NO TRANSITO", "" } )
	aAdd( aBody, { "", "000009", "13", "Auto de Lancamento", "" } )
	aAdd( aBody, { "", "000010", "14", "Divida Ativa", "" } )
	aAdd( aBody, { "", "000011", "15", "CONSOLIDAC.O DE DEBITOS", "" } )
	aAdd( aBody, { "", "000012", "16", "Notificacao Fiscal", "" } )
	aAdd( aBody, { "", "000013", "17", "Numero do Parcelamento", "" } )
	aAdd( aBody, { "", "000014", "18", "DIRE - Declaracao de Imp de Remessa Expressa", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )