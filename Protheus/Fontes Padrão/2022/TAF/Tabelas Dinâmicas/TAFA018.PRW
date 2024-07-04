#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA018.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA018
Cadastro do CST do ISS

@author Marcio Nunes
@since 05/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------  
Function TAFA018()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro do CST do ISS
oBrw:SetAlias( 'C0H')
oBrw:SetMenuDef( 'TAFA018'  )   
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA018" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC0H 	:= 	FWFormStruct( 1, 'C0H' )
Local oModel 	:= 	MPFormModel():New( 'TAFA018' )

oModel:AddFields('MODEL_C0H', /*cOwner*/, oStruC0H)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA018' )
Local 	oStruC0H 	:= 	FWFormStruct( 2, 'C0H' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0H', oStruC0H, 'MODEL_C0H' )

oView:EnableTitleView( 'VIEW_C0H', STR0001 ) //Cadastro do CST do ISS
oView:CreateHorizontalBox( 'FIELDSC0H', 100 )
oView:SetOwnerView( 'VIEW_C0H', 'FIELDSC0H' )

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

nVerAtu := 1031.19

If nVerEmp < nVerAtu
	aAdd( aHeader, "C0H_FILIAL" )
	aAdd( aHeader, "C0H_ID" )
	aAdd( aHeader, "C0H_CODIGO" )
	aAdd( aHeader, "C0H_DESCRI" )
	aAdd( aHeader, "C0H_VALIDA" )

	aAdd( aBody, { "", "000001", "00", "TRIBUTADO INTEGRALMENTE", "" } )
	aAdd( aBody, { "", "000002", "01", "TRIBUTADO INTEGRALMENTE E COM ISSQN RETIDO NA FONTE", "" } )
	aAdd( aBody, { "", "000003", "02", "TRIBUTADO COM REDUCAO DA BASE DE CALCULO OU ALIQUOTA", "" } )
	aAdd( aBody, { "", "000004", "03", "TRIBUTADO COM REDUCAO DA BASE DE CALCULO OU ALIQUOTA E COM ISSQN RETIDO NA FONTE", "" } )
	aAdd( aBody, { "", "000005", "04", "TRIBUTADO COM REDUCAO DE ALIQUOTA EM FUNCAO DE REGIME ESPECIAL DE TRIBUTACAO", "" } )
	aAdd( aBody, { "", "000006", "05", "TRIBUTADO POR MEIO DO IMPOSTO FIXO", "" } )
	aAdd( aBody, { "", "000007", "06", "ISENTO", "" } )
	aAdd( aBody, { "", "000008", "07", "NAO-TRIBUTADO", "" } )
	aAdd( aBody, { "", "000009", "08", "IMUNIDADE TRIBUTARIA", "" } )
	aAdd( aBody, { "", "000010", "09", "EXIGIBILIDADE SUSPENSA POR DECISAO JUDICIAL", "" } )
	aAdd( aBody, { "", "000011", "10", "VENDAS/TRANSPORTE INTERMUNICIPAL", "" } )
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
