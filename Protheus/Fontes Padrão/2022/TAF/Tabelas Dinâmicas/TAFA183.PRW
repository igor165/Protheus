#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA183.CH"                                    
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA183
Cadastro MVC Campos Contribuição Previdenciária

@author Fabio V. Santana
@since 21/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA183()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Campos Contribuição Previdenciária
oBrw:SetAlias( 'C5X')
oBrw:SetMenuDef( 'TAFA183' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 21/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA183" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 21/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC5X 	:= 	FWFormStruct( 1, 'C5X' )
Local oModel 	:= 	MPFormModel():New( 'TAFA183' )

oModel:AddFields('MODEL_C5X', /*cOwner*/, oStruC5X)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 21/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA183' )
Local 	oStruC5X 	:= 	FWFormStruct( 2, 'C5X' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C5X', oStruC5X, 'MODEL_C5X' )

oView:EnableTitleView( 'VIEW_C5X', STR0001 ) //Campos Contribuição Previdenciária
oView:CreateHorizontalBox( 'FIELDSC5X', 100 )
oView:SetOwnerView( 'VIEW_C5X', 'FIELDSC5X' )

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
	aAdd( aHeader, "C5X_FILIAL" )
	aAdd( aHeader, "C5X_ID" )
	aAdd( aHeader, "C5X_CODIGO" )
	aAdd( aHeader, "C5X_DESCRI" )
	aAdd( aHeader, "C5X_NOME" )

	aAdd( aBody, { "", "000001", "02", "DATA INICIAL A QUE A APURACAO SE REFERE", "DTINI" } )
	aAdd( aBody, { "", "000002", "03", "DATA FINAL A QUE A APURACAO SE REFERE", "DTFIM" } )
	aAdd( aBody, { "", "000003", "04", "VALOR DA RECEITA BRUTA TOTAL DO ESTABELECIMENTO NO PERIODO", "VTOT" } )
	aAdd( aBody, { "", "000004", "05", "CODIGO INDICADOR CORRESPONDENTE A ATIVIDADE SUJEITA A INCIDENCIA DA CONTRIBUICAO PREVIDENCIARIA SOBRE A RECEITA BRUTA", "CODATI" } )
	aAdd( aBody, { "", "000005", "06", "VALOR DA RECEITA BRUTA DO ESTABELECIMENTO", "VATIV" } )
	aAdd( aBody, { "", "000006", "07", "VALOR DAS EXCLUSOES DA RECEITA BRUTA", "CEXC" } )
	aAdd( aBody, { "", "000007", "08", "ALIQUOTA DA CONTRIBUICAO PREVIDENCIARIA SOBRE A RECEITA BRUTA", "ALQCON" } )
	aAdd( aBody, { "", "000008", "09", "VALOR DA CONTRIBUICAO PREVIDENCIARIA APURADA SOBRE A RECEITA BRUTA", "VCON" } )
	aAdd( aBody, { "", "000009", "10", "CODIGO DA CONTA ANALITICA CONTABIL", "CODCTA" } )
	aAdd( aBody, { "", "000010", "11", "INFORMACAO COMPLEMENTAR DO REGISTRO", "INFCOM" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )