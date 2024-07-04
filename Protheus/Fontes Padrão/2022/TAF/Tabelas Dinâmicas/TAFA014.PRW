#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA014.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA014
Cadastro de CST do ICMS 

@author Marcio Nunes
@since 04/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA014()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de CST do ICMS
oBrw:SetAlias( 'C14')
oBrw:SetMenuDef( 'TAFA014' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 04/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA014" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 04/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC14 	:= 	FWFormStruct( 1, 'C14' )
Local oModel 	:= 	MPFormModel():New( 'TAFA014' )

oModel:AddFields('MODEL_C14', /*cOwner*/, oStruC14)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 04/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA014' )
Local 	oStruC14 	:= 	FWFormStruct( 2, 'C14' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C14', oStruC14, 'MODEL_C14' )

oView:EnableTitleView( 'VIEW_C14', STR0001 ) //Cadastro de CST do ICMS
oView:CreateHorizontalBox( 'FIELDSC14', 100 )
oView:SetOwnerView( 'VIEW_C14', 'FIELDSC14' )

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
	aAdd( aHeader, "C14_FILIAL" )
	aAdd( aHeader, "C14_ID" )
	aAdd( aHeader, "C14_CODIGO" )
	aAdd( aHeader, "C14_DESCRI" )
	aAdd( aHeader, "C14_VALIDA" )

	aAdd( aBody, { "", "000001", "00", "TRIBUTADA INTEGRALMENTE", "" } )
	aAdd( aBody, { "", "000002", "10", "TRIBUTADA,C/COBR. ICMS POR SUBSTITUICAO TRIB.", "" } )
	aAdd( aBody, { "", "000003", "20", "COM REDUCAO DE BASE DE CALCULO", "" } )
	aAdd( aBody, { "", "000004", "30", "ISENTA OU NAO TRIB.,C/COBR.ICMS POR SUBS.TRIB.", "" } )
	aAdd( aBody, { "", "000005", "40", "ISENTA", "" } )
	aAdd( aBody, { "", "000006", "41", "NAO TRIBUTADA", "" } )
	aAdd( aBody, { "", "000007", "50", "COM SUSPENSAO", "" } )
	aAdd( aBody, { "", "000008", "51", "DIFERIMENTO", "" } )
	aAdd( aBody, { "", "000009", "60", "ICMS COBRADO ANTERIORMENTE POR SUBST. TRIB.", "" } )
	aAdd( aBody, { "", "000010", "70", "C/REDUCAO DE BASE CALC.E COBR.ICMS P/SUBS.TRIB", "" } )
	aAdd( aBody, { "", "000011", "90", "OUTRAS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )