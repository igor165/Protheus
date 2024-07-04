#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                               
#INCLUDE "TAFA169.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA169
Cadastro MVC de Unidades de Medida

@author Fabio V. Santana
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA169()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Indicador de Operação
oBrw:SetAlias( 'C3D')
oBrw:SetMenuDef( 'TAFA169' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC dos Processos Referenciados

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA169" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC3D 	:= 	FWFormStruct( 1, 'C3D' )
Local oModel 	:= 	MPFormModel():New( 'TAFA169' )

oModel:AddFields('MODEL_C3D', /*cOwner*/, oStruC3D)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA169' )
Local 	oStruC3D 	:= 	FWFormStruct( 2, 'C3D' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C3D', oStruC3D, 'MODEL_C3D' )

oView:EnableTitleView( 'VIEW_C3D', STR0001 ) //Processos Referenciados
oView:CreateHorizontalBox( 'FIELDSC3D', 100 )
oView:SetOwnerView( 'VIEW_C3D', 'FIELDSC3D' )

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
	aAdd( aHeader, "C3D_FILIAL" )
	aAdd( aHeader, "C3D_ID" )
	aAdd( aHeader, "C3D_CODIGO" )
	aAdd( aHeader, "C3D_DESCRI" )
	aAdd( aHeader, "C3D_VALIDA" )

	aAdd( aBody, { "", "000001", "0", "OPERACAO REPRESENTATIVA DE AQUISICAO, CUSTOS, DESPESA OU ENCARGOS, SUJEITA A INCIDENCIA DE CREDITO DE PIS/PASEP OU COFINS (CST 50 A 66).", "" } )
	aAdd( aBody, { "", "000002", "1", "OPERACAO REPRESENTATIVA DE RECEITA AUFERIDA SUJEITA AO PAGAMENTO DA CONTRIBUICAO PARA O PIS/PASEP E DA COFINS (CST 01, 02, 03 OU 05).", "" } )
	aAdd( aBody, { "", "000003", "2", "OPERACAO REPRESENTATIVA DE RECEITA AUFERIDA NAO SUJEITA AO PAGAMENTO DA CONTRIBUICAO PARA O PIS/PASEP E DA COFINS (CST 04, 06, 07, 08, 09, 49 OU 99).", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )