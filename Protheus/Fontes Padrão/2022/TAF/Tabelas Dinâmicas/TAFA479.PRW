#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA479
Cadastro MVC de Obrigações Fiscais

@author João Vitor Spieker
@since 21/09/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA479()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription("Obrigações Fiscais")    //
oBrw:SetAlias( 'T82')
oBrw:SetMenuDef( 'TAFA479' )
T82->(DbSetOrder(2))
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
Return XFUNMnuTAF( "TAFA479" ,,,,.T. )
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
Local oStruT82  :=  FWFormStruct( 1, 'T82' )
Local oModel    :=  MPFormModel():New( 'TAFA479' )

oModel:AddFields('MODEL_T82', /*cOwner*/, oStruT82)
oModel:GetModel('MODEL_T82'):SetPrimaryKey({'T82_FILIAL','T82_ID'})

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
Local   oModel      :=  FWLoadModel( 'TAFA479' )
Local   oStruT82    :=  FWFormStruct( 2, 'T82' )
Local   oView       :=  FWFormView():New()

oStruT82:RemoveField('T82_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_T82', oStruT82, 'MODEL_T82' )

oView:EnableTitleView( 'VIEW_T82', "Obrigações Fiscais" )    //
oView:CreateHorizontalBox( 'FIELDST82', 100 )
oView:SetOwnerView( 'VIEW_T82', 'FIELDST82' )

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
	aAdd( aHeader, "T82_FILIAL" )
	aAdd( aHeader, "T82_ID" )
	aAdd( aHeader, "T82_CODIGO" )
	aAdd( aHeader, "T82_CODSEC" )
	aAdd( aHeader, "T82_DESCRI" )
	
	aAdd( aBody, { "", "3d2863c8-a638-848f-92e3-0921a9549824", "00", "3.0", "Cancelada" } )
	aAdd( aBody, { "", "bf6be3a1-4d1b-2f28-5202-e60c13cabf85", "01", "3.1", "Regra Geral" } )
	aAdd( aBody, { "", "61c0590d-e925-44a2-b21c-494394980c71", "02", "3.2", "Regime de Estimativa" } )
	aAdd( aBody, { "", "7f4a0e42-a1bd-e6e9-7b8a-3bcb1335105a", "03", "3.3", "SPL - Sociedade de Profissionais Liberais" } )
	aAdd( aBody, { "", "d3743890-60d0-bb56-98e2-869f6c872bc3", "04", "3.4", "Cooperativa" } )
	aAdd( aBody, { "", "cd3b51a5-bc3e-cc55-d807-853b7091cd5a", "05", "3.5", "Não disponível na DES 3.0" } )
	aAdd( aBody, { "", "82304f4e-2f23-a631-1d03-12052f691710", "06", "3.6", "Construção Civil" } )
	aAdd( aBody, { "", "7b90272a-8812-48ba-3ade-6176bbf83ca6", "07", "3.7", "Propaganda e Publicidade/Intermediação" } )
	aAdd( aBody, { "", "4c5da6da-f76f-8073-2fd6-04f671f07089", "08", "3.8", "Agenciamento de Turismo/Administração de Fundos" } )
	aAdd( aBody, { "", "4189be1f-6618-fdf2-59c2-3ccb4036790e", "09", "3.9", "ME ou EPP optante pelo Simples Nacional" } )
	aAdd( aBody, { "", "b4f8dde9-c22c-9feb-a77f-b7597f0d107b", "10", "3.10", "MEI–Microempreendedor Individual" } )
	aAdd( aBody, { "", "10d2d68b-c748-8848-c499-5760268cda7d", "11", "3.11", "Vendas/Transporte Intermunicipal" } )
	aAdd( aBody, { "", "34d38420-b8a9-e602-b7a0-5583d999bea8", "12", "3.12", "Não Incidência" } )


	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )

