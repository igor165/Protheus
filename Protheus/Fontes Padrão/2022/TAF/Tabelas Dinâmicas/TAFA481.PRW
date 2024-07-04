#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA481
Cadastro MVC de Obrigações Fiscais

@author João Vitor Spieker
@since 28/09/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA481()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription("Obrigações Fiscais")    //
oBrw:SetAlias( 'T83')
oBrw:SetMenuDef( 'TAFA481' )
T83->(DbSetOrder(2))
oBrw:Activate()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author João Vitor Spieker
@since 28/09/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA481" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC
@author João Vitor Spieker
@since 28/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT83  :=  FWFormStruct( 1, 'T83' )
Local oModel    :=  MPFormModel():New( 'TAFA481' )

oModel:AddFields('MODEL_T83', /*cOwner*/, oStruT83)
oModel:GetModel('MODEL_T83'):SetPrimaryKey({'T83_FILIAL','T83_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author João Vitor Spieker
@since 28/09/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA481' )
Local   oStruT83    :=  FWFormStruct( 2, 'T83' )
Local   oView       :=  FWFormView():New()

oStruT83:RemoveField('T83_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_T83', oStruT83, 'MODEL_T83' )

oView:EnableTitleView( 'VIEW_T83', "Obrigações Fiscais" )    //
oView:CreateHorizontalBox( 'FIELDST83', 100 )
oView:SetOwnerView( 'VIEW_T83', 'FIELDST83' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@author João Vitor Spieker
@since 28/09/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1019

If nVerEmp < nVerAtu
	aAdd( aHeader, "T83_FILIAL" )
	aAdd( aHeader, "T83_ID" )
	aAdd( aHeader, "T83_CODIGO" )
	aAdd( aHeader, "T83_CODSEC" )
	aAdd( aHeader, "T83_DESCRI" )
	
	aAdd( aBody, { "", "7bfebcaa-2608-62ba-e91d-8f536f46c9f9", "00", "1.0", "Cancelada" } )
	aAdd( aBody, { "", "e27cb872-3d46-341e-4f9a-a665f24e3568", "01", "1.1", "Exclusivamente Prestação de Serviços" } )
	aAdd( aBody, { "", "26ca5b4b-6007-0f5b-cf0d-4e287d1419fc", "02", "1.2", "Prestação de Serviços c/ Dedução" } )
	aAdd( aBody, { "", "ac3b1afd-88cb-50d8-4d78-4f535f2b67dd", "03", "1.3", "Prestação de Serviços c/ Reembolso/Repasse" } )
	aAdd( aBody, { "", "7948ada9-4fe1-6ac6-8f66-64e46b50b53d", "04", "1.4", "Exclusivamente Reembolso/Repasse" } )
	aAdd( aBody, { "", "72068bd5-e86d-c86f-e634-12d34b18221a", "05", "1.5", "Vendas de Mercadorias/Transporte Intermunicipal" } )
	aAdd( aBody, { "", "6098cb08-0b72-fa27-3410-4bba73b0148f", "06", "1.6", "Prestação de Serviços c/ Venda de Mercadorias/Transporte Intermunicipal" } )
	aAdd( aBody, { "", "69d88b84-7267-dc9d-2630-900a6747f403", "07", "1.7", "Devolução/Simples Remessa/Entrada" } )
	aAdd( aBody, { "", "de45a3bf-2316-b25c-bd47-c64d4c5dd053", "08", "1.8", "Não Incidência" } )


	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )

