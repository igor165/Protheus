#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA015.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA015
Cadastro MVC do CST do IPI 

@author Fabio V. Santana
@since 05/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA015()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro do CST do IPI
oBrw:SetAlias( 'C15')
oBrw:SetMenuDef( 'TAFA015' )
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
Return XFUNMnuTAF( "TAFA015" )
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
Local oStruC15 	:= 	FWFormStruct( 1, 'C15' )
Local oModel 	:= 	MPFormModel():New( 'TAFA015' )

oModel:AddFields('MODEL_C15', /*cOwner*/, oStruC15)

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA015' )
Local 	oStruC15 	:= 	FWFormStruct( 2, 'C15' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C15', oStruC15, 'MODEL_C15' )

oView:EnableTitleView( 'VIEW_C15', STR0001 ) //Cadastro do CST do IPI
oView:CreateHorizontalBox( 'FIELDSC15', 100 )
oView:SetOwnerView( 'VIEW_C15', 'FIELDSC15' )

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
	aAdd( aHeader, "C15_FILIAL" )
	aAdd( aHeader, "C15_ID" )
	aAdd( aHeader, "C15_CODIGO" )
	aAdd( aHeader, "C15_DESCRI" )
	aAdd( aHeader, "C15_VALIDA" )

	aAdd( aBody, { "", "000001", "00", "ENTRADA COM RECUPERACAO DE CREDITO", "" } )
	aAdd( aBody, { "", "000002", "01", "ENTRADA TRIBUTADA COM ALIQUOTA ZERO", "" } )
	aAdd( aBody, { "", "000003", "02", "ENTRADA ISENTA", "" } )
	aAdd( aBody, { "", "000004", "03", "ENTRADA NAO TRIBUTADA", "" } )
	aAdd( aBody, { "", "000005", "04", "ENTRADA IMUNE", "" } )
	aAdd( aBody, { "", "000006", "05", "ENTRADA COM SUSPENSAO", "" } )
	aAdd( aBody, { "", "000007", "49", "OUTRAS ENTRADAS", "" } )
	aAdd( aBody, { "", "000008", "50", "SAIDA TRIBUTADA", "" } )
	aAdd( aBody, { "", "000009", "51", "SAIDA TRIBUTADA COM ALIQUOTA ZERO", "" } )
	aAdd( aBody, { "", "000010", "52", "SAIDA ISENTA", "" } )
	aAdd( aBody, { "", "000011", "53", "SAIDA NAO TRIBUTADA", "" } )
	aAdd( aBody, { "", "000012", "54", "SAIDA IMUNE", "" } )
	aAdd( aBody, { "", "000013", "55", "SAIDA COM SUSPENSAO", "" } )
	aAdd( aBody, { "", "000014", "99", "OUTRAS SAIDAS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )