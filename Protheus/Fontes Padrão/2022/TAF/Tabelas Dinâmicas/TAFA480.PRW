#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA480
Cadastro MVC de Obrigações Fiscais

@author João Vitor Spieker
@since 21/09/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA480()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription("Obrigações Fiscais")    //
oBrw:SetAlias( 'T81')
oBrw:SetMenuDef( 'TAFA480' )
T81->(DbSetOrder(2))
oBrw:Activate()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author João Vitor Spieker
@since 21/09/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA480" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC
@author João Vitor Spieker
@since 21/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT81  :=  FWFormStruct( 1, 'T81' )
Local oModel    :=  MPFormModel():New( 'TAFA480' )

oModel:AddFields('MODEL_T81', /*cOwner*/, oStruT81)
oModel:GetModel('MODEL_T81'):SetPrimaryKey({'T81_FILIAL','T81_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author João Vitor Spieker
@since 21/09/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA480' )
Local   oStruT81    :=  FWFormStruct( 2, 'T81' )
Local   oView       :=  FWFormView():New()

oStruT81:RemoveField('T81_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_T81', oStruT81, 'MODEL_T81' )

oView:EnableTitleView( 'VIEW_T81', "Obrigações Fiscais" )    //
oView:CreateHorizontalBox( 'FIELDST81', 100 )
oView:SetOwnerView( 'VIEW_T81', 'FIELDST81' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@author João Vitor Spieker
@since 21/09/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1019

If nVerEmp < nVerAtu
	aAdd( aHeader, "T81_FILIAL" )
	aAdd( aHeader, "T81_ID" )
	aAdd( aHeader, "T81_CODIGO" )
	aAdd( aHeader, "T81_CODSEC" )
	aAdd( aHeader, "T81_DESCRI" )
	
	aAdd( aBody, { "", "388094da-1560-6586-b900-bf5a76bd6f26", "01", "2.1", "Não retido" } )
	aAdd( aBody, { "", "5ebc5c0a-0f06-90da-474f-b31450f43f97", "02", "2.2", "Imunidade Tributária" } )
	aAdd( aBody, { "", "51d9ee20-edea-d3f2-6e6d-f9269f5935d8", "03", "2.3", "Regime de Estimativa em BH" } )
	aAdd( aBody, { "", "5a20b006-5e86-da06-ffb8-cd4f3b24b974", "04", "2.4", "Isenta do ISSQN em BH" } )
	aAdd( aBody, { "", "020e8e89-8827-8e5b-4d11-eb47926fee55", "05", "2.5", "Tributação fora de BH" } )
	aAdd( aBody, { "", "a45c5d48-436a-9140-4fef-cee1f1e00319", "06", "2.6", "SPL - Sociedade de Profissionais Liberais" } )
	aAdd( aBody, { "", "29d7c2c2-bd3f-ea41-eee9-2db219cab2ab", "07", "2.7", "Incentivador Cultural em BH" } )
	aAdd( aBody, { "", "773f6b58-817b-0683-cd8c-3eb0249008a8", "08", "2.8", "Exigibilade do ISSQN Suspensa por Decisão Judicial" } )
	aAdd( aBody, { "", "7f1acc59-c4ef-992a-e6f3-26371fd9be87", "09", "2.9", "Profissional Autônomo inscrito na PBH" } )
	aAdd( aBody, { "", "a7e0aa5d-d49f-3ad5-8f40-84a8c72d8577", "10", "2.10", "Não Incidência/Reembolso/Repasse" } )
	aAdd( aBody, { "", "863a3349-01fb-f478-b437-5f48ef465daa", "11", "2.11", "Não disponível na DES 3.0" } )
	aAdd( aBody, { "", "7ee3b5eb-51c2-c667-3468-9f3f09e53ea7", "12", "2.12", "Cartórios" } )
	aAdd( aBody, { "", "3b05f41f-8af2-859f-727a-e96501a4d2ae", "13", "2.13", "PROEMP" } )
	aAdd( aBody, { "", "9bacabbb-fb17-bfd4-c73e-4884ae1727ca", "14", "2.14", "MEI - Microempreendedor Individual" } )
	aAdd( aBody, { "", "5bfa6322-20d5-2383-11cb-816871a75457", "15", "2.15", "Desobrigado legalemnte" } )
	aAdd( aBody, { "", "b1ff42d8-5eba-73da-39cc-f59527582c7d", "16", "2.16", "ISSQN Retido" } )
	aAdd( aBody, { "", "7fa933bc-e32e-37df-389d-c1407f449a9d", "17", "2.17", "Exportação" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )

