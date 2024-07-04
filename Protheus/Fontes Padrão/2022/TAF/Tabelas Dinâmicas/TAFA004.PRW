#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA004.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA004
Cadastro MVC do Cadastro das Modalidades da Base de Calculo do ICMS

@author Fabio V. Santana
@since 07/05/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA004()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro das Modalidades da Base de Calculo do ICMS
oBrw:SetAlias( 'C04')
oBrw:SetMenuDef( 'TAFA004' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 07/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA004" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 07/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC04 	:= 	FWFormStruct( 1, 'C04' )
Local oModel 	:= 	MPFormModel():New( 'TAFA004' )

oModel:AddFields('MODEL_C04', /*cOwner*/, oStruC04)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 07/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA004' )
Local 	oStruC04 	:= 	FWFormStruct( 2, 'C04' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C04', oStruC04, 'MODEL_C04' )

oView:EnableTitleView( 'VIEW_C04', STR0001 ) //Cadastro das Modalidades da Base de Calculo do ICMS
oView:CreateHorizontalBox( 'FIELDSC04', 100 )
oView:SetOwnerView( 'VIEW_C04', 'FIELDSC04' )

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
	aAdd( aHeader, "C04_FILIAL" )
	aAdd( aHeader, "C04_ID" )
	aAdd( aHeader, "C04_CODIGO" )
	aAdd( aHeader, "C04_DESCRI" )
	aAdd( aHeader, "C04_VALIDA" )

	aAdd( aBody, { "", "000001", "0", "Margem Valor Agregado (%)", "" } )
	aAdd( aBody, { "", "000002", "1", "Pauta (Valor)", "" } )
	aAdd( aBody, { "", "000003", "2", "Preco Tabelado Max. (valor)", "" } )
	aAdd( aBody, { "", "000004", "3", "Valor da operacao", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )