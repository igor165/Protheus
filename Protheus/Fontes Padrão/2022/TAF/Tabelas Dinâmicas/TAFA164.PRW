#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA164.CH"                                
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA164
Cadastro MVC - Cadastro do Indicador da Tabela de Incidência da bebida
@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA164()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro do Indicador da Tabela de Incidência da bebida
oBrw:SetAlias( 'C3V')
oBrw:SetMenuDef( 'TAFA164' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA164" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC3V 	:= 	FWFormStruct( 1, 'C3V' )
Local oModel 	:= 	MPFormModel():New( 'TAFA164' )

oModel:AddFields('MODEL_C3V', /*cOwner*/, oStruC3V)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA164' )
Local 	oStruC3V 	:= 	FWFormStruct( 2, 'C3V' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C3V', oStruC3V, 'MODEL_C3V' )

oView:EnableTitleView( 'VIEW_C3V', STR0001 ) //Cadastro do Indicador da Tabela de Incidência da bebida
oView:CreateHorizontalBox( 'FIELDSC3V', 100 )
oView:SetOwnerView( 'VIEW_C3V', 'FIELDSC3V' )

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
	aAdd( aHeader, "C3V_FILIAL" )
	aAdd( aHeader, "C3V_ID" )
	aAdd( aHeader, "C3V_CODIGO" )
	aAdd( aHeader, "C3V_DESCRI" )
	aAdd( aHeader, "C3V_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "TABELA I", "" } )
	aAdd( aBody, { "", "000002", "02", "TABELA II", "" } )
	aAdd( aBody, { "", "000003", "03", "TABELA III", "" } )
	aAdd( aBody, { "", "000004", "04", "TABELA IV", "" } )
	aAdd( aBody, { "", "000005", "05", "TABELA V", "" } )
	aAdd( aBody, { "", "000006", "06", "TABELA VI", "" } )
	aAdd( aBody, { "", "000007", "07", "TABELA VII", "" } )
	aAdd( aBody, { "", "000008", "08", "TABELA VIII", "" } )
	aAdd( aBody, { "", "000009", "09", "TABELA IX", "" } )
	aAdd( aBody, { "", "000010", "10", "TABELA X", "" } )
	aAdd( aBody, { "", "000011", "11", "TABELA XI", "" } )
	aAdd( aBody, { "", "000012", "12", "TABELA XII", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )