#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA016.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA016
Cadastro MVC de indicador de Tipo de Transporte

@author Fabio V. Santana
@since 05/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA016()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro de indicador de Tipo de Transporte
oBrw:SetAlias( 'C16')
oBrw:SetMenuDef( 'TAFA016' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA016" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC16 	:= 	FWFormStruct( 1, 'C16' )
Local oModel 	:= 	MPFormModel():New( 'TAFA016' )

oModel:AddFields('MODEL_C16', /*cOwner*/, oStruC16)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA016' )
Local 	oStruC16 	:= 	FWFormStruct( 2, 'C16' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C16', oStruC16, 'MODEL_C16' )

oView:EnableTitleView( 'VIEW_C16', STR0001 ) //Cadastro de indicador de Tipo de Transporte
oView:CreateHorizontalBox( 'FIELDSC16', 100 )
oView:SetOwnerView( 'VIEW_C16', 'FIELDSC16' )

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
	aAdd( aHeader, "C16_FILIAL" )
	aAdd( aHeader, "C16_ID" )
	aAdd( aHeader, "C16_CODIGO" )
	aAdd( aHeader, "C16_DESCRI" )
	aAdd( aHeader, "C16_VALIDA" )

	aAdd( aBody, { "", "000001", "0", "RODOVIARIO", "" } )
	aAdd( aBody, { "", "000002", "1", "FERROVIARIO", "" } )
	aAdd( aBody, { "", "000003", "2", "RODO-FERROVIARIO", "" } )
	aAdd( aBody, { "", "000004", "3", "AQUAVIARIO", "" } )
	aAdd( aBody, { "", "000005", "4", "DUTOVIARIO", "" } )
	aAdd( aBody, { "", "000006", "5", "AEREO", "" } )
	aAdd( aBody, { "", "000007", "9", "OUTROS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )