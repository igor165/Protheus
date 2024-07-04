#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA482
Cadastro MVC de Obrigações Fiscais

@author João Vitor Spieker
@since 28/09/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA482()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription("Obrigações Fiscais")    //
oBrw:SetAlias( 'T84')
oBrw:SetMenuDef( 'TAFA482' )
T84->(DbSetOrder(2))
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
Return XFUNMnuTAF( "TAFA482" ,,,,.T. )
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
Local oStruT84  :=  FWFormStruct( 1, 'T84' )
Local oModel    :=  MPFormModel():New( 'TAFA482' )

oModel:AddFields('MODEL_T84', /*cOwner*/, oStruT84)
oModel:GetModel('MODEL_T84'):SetPrimaryKey({'T84_FILIAL','T84_ID'})

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
Local   oModel      :=  FWLoadModel( 'TAFA482' )
Local   oStruT84    :=  FWFormStruct( 2, 'T84' )
Local   oView       :=  FWFormView():New()

oStruT84:RemoveField('T84_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_T84', oStruT84, 'MODEL_T84' )

oView:EnableTitleView( 'VIEW_T84', "Obrigações Fiscais" )    //
oView:CreateHorizontalBox( 'FIELDST84', 100 )
oView:SetOwnerView( 'VIEW_T84', 'FIELDST84' )

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
	aAdd( aHeader, "T84_FILIAL" )
	aAdd( aHeader, "T84_ID" )
	aAdd( aHeader, "T84_CODIGO" )
	aAdd( aHeader, "T84_CODSEC" )
	aAdd( aHeader, "T84_DESCRI" )
	
	aAdd( aBody, { "", "a5d26ea2-cdcf-60da-92c7-1746216a6e3a", "01", "1.1", "Exclusivamente Prestação de Serviços" } )
	aAdd( aBody, { "", "edee28c7-1a5c-db0d-e8a1-d75ad4e71304", "02", "1.2", "Prestação de Serviços c/ Dedução" } )
	aAdd( aBody, { "", "aef2cc06-3ac9-fc0e-40d5-c1a84f8cc377", "03", "1.3", "Construção Civil" } )
	aAdd( aBody, { "", "1ddd6d5b-b501-336f-1c87-52732c5ce269", "04", "1.4", "Agenciamento de Turismo/Administração de Fundos" } )
	aAdd( aBody, { "", "6a9d346e-779d-7332-4335-5c861313d352", "05", "1.5", "Propaganda e Publicidade/Intermediação" } )
	aAdd( aBody, { "", "5e3a14bb-95eb-f4df-492e-896fcbbed28a", "06", "1.6", "Propaganda e Publicidade/Intermediação - Isento" } )
	aAdd( aBody, { "", "b171ef9e-d0c3-f03f-ee3c-fc2d4d40517a", "07", "1.7", "Não Incidência/Reembolso/Repasse" } )


	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )

