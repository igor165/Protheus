#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA211.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA211
Cadastro MVC de Tipos de Bairros

@author Demetrio Fontes De Los Rios
@since 21/02/2013
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA211()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	// Cadastro de Tipos de Bairro
oBrw:SetAlias( 'C86')
oBrw:SetMenuDef( 'TAFA211' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Demetrio Fontes De Los Rios
@since 21/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( 'TAFA211' )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Demetrio Fontes De Los Rios
@since 21/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC86 	:= 	FWFormStruct( 1, 'C86' )
Local oModel 	:= 	MPFormModel():New( 'TAFA211' )

oModel:AddFields('MODEL_C86', /*cOwner*/, oStruC86)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Demetrio Fontes De Los Rios
@since 21/02/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA211' )
Local 	oStruC86 	:= 	FWFormStruct( 2, 'C86' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C86', oStruC86, 'MODEL_C86' )

oView:EnableTitleView( 'VIEW_C86', STR0001 ) // Cadastro de Tipos de Bairro
oView:CreateHorizontalBox( 'FIELDSC86', 100 )
oView:SetOwnerView( 'VIEW_C86', 'FIELDSC86' )

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
	aAdd( aHeader, "C86_FILIAL" )
	aAdd( aHeader, "C86_ID" )
	aAdd( aHeader, "C86_CODIGO" )
	aAdd( aHeader, "C86_DESCRI" )

	aAdd( aBody, { "", "000001", "01", "BAIRRO" } )
	aAdd( aBody, { "", "000002", "02", "BOSQUE" } )
	aAdd( aBody, { "", "000003", "03", "CHACARA" } )
	aAdd( aBody, { "", "000004", "04", "CONJUNTO" } )
	aAdd( aBody, { "", "000005", "05", "DESMEMBRAMENTO" } )
	aAdd( aBody, { "", "000006", "06", "DISTRITO" } )
	aAdd( aBody, { "", "000007", "07", "FAVELA" } )
	aAdd( aBody, { "", "000008", "08", "FAZENDA" } )
	aAdd( aBody, { "", "000009", "09", "GLEBA" } )
	aAdd( aBody, { "", "000010", "10", "HORTO" } )
	aAdd( aBody, { "", "000011", "11", "JARDIM" } )
	aAdd( aBody, { "", "000012", "12", "LOTEAMENTO" } )
	aAdd( aBody, { "", "000013", "13", "NUCLEO" } )
	aAdd( aBody, { "", "000014", "14", "PARQUE" } )
	aAdd( aBody, { "", "000015", "15", "RESIDENCIAL" } )
	aAdd( aBody, { "", "000016", "16", "SITIO" } )
	aAdd( aBody, { "", "000017", "17", "TROPICAL" } )
	aAdd( aBody, { "", "000018", "18", "VILA" } )
	aAdd( aBody, { "", "000019", "19", "ZONA" } )
	aAdd( aBody, { "", "000020", "99", "OUTROS" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )