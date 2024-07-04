#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA045.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA045
Cadastro MVC - Cadastro de Indicador da Natureza da Ação Judicial impetrada na Justiça Federal

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA045()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro do Grupo de classificação do item de energia elétrica
oBrw:SetAlias( 'C19')
oBrw:SetMenuDef( 'TAFA045' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA045" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC19 	:= 	FWFormStruct( 1, 'C19' )
Local oModel 	:= 	MPFormModel():New( 'TAFA045' )

oModel:AddFields('MODEL_C19', /*cOwner*/, oStruC19)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA045' )
Local 	oStruC19 	:= 	FWFormStruct( 2, 'C19' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C19', oStruC19, 'MODEL_C19' )

oView:EnableTitleView( 'VIEW_C19', STR0001 ) //Cadastro de Indicador da Natureza da Ação Judicial impetrada na Justiça Federal
oView:CreateHorizontalBox( 'FIELDSC19', 100 )
oView:SetOwnerView( 'VIEW_C19', 'FIELDSC19' )

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
	aAdd( aHeader, "C19_FILIAL" )
	aAdd( aHeader, "C19_ID" )
	aAdd( aHeader, "C19_CODIGO" )
	aAdd( aHeader, "C19_DESCRI" )
	aAdd( aHeader, "C19_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "PROCESSO ADMINISTRATIVO DE CONSULTA", "" } )
	aAdd( aBody, { "", "000002", "02", "DESPACHO DECISORIO", "" } )
	aAdd( aBody, { "", "000003", "03", "ATO DECLARATORIO EXECUTIVO", "" } )
	aAdd( aBody, { "", "000004", "04", "ATO DECLARATORIO INTERPRETATIVO", "" } )
	aAdd( aBody, { "", "000005", "05", "DECISAO ADMINISTRATIVA DE DRJ OU DO CARF", "" } )
	aAdd( aBody, { "", "000006", "06", "AUTO DE INFRACAO", "" } )
	aAdd( aBody, { "", "000007", "99", "OUTROS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )