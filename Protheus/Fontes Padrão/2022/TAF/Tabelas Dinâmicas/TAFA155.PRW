#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA155.CH"                                    
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA155
Cadastro de Ajustes (PIS/COFINS) de Contribuição Social Apurada

@author Marcio Nunes
@since 05/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA155()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Ajustes (PIS/COFINS) de Contribuição Social Apurada
oBrw:SetAlias( 'C1C')
oBrw:SetMenuDef( 'TAFA155' )
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
Return XFUNMnuTAF( "TAFA155" )
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
Local oStruC1C 	:= 	FWFormStruct( 1, 'C1C' )
Local oModel 	:= 	MPFormModel():New( 'TAFA155' )

oModel:AddFields('MODEL_C1C', /*cOwner*/, oStruC1C)

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA155' )
Local 	oStruC1C 	:= 	FWFormStruct( 2, 'C1C' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C1C', oStruC1C, 'MODEL_C1C' )

oView:EnableTitleView( 'VIEW_C1C', STR0001 ) //Cadastro de Ajustes (PIS/COFINS) de Contribuição Social Apurada
oView:CreateHorizontalBox( 'FIELDSC1C', 100 )
oView:SetOwnerView( 'VIEW_C1C', 'FIELDSC1C' )

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
	aAdd( aHeader, "C1C_FILIAL" )
	aAdd( aHeader, "C1C_ID" )
	aAdd( aHeader, "C1C_CODIGO" )
	aAdd( aHeader, "C1C_DESCRI" )
	aAdd( aHeader, "C1C_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "CONTRIBUICAO NAO-CUMULATIVA APURADA A ALIQUOTA BASICA", "" } )
	aAdd( aBody, { "", "000002", "02", "CONTRIBUICAO NAO-CUMULATIVA APURADA A ALIQUOTAS DIFERENCIADAS", "" } )
	aAdd( aBody, { "", "000003", "03", "CONTRIBUICAO NAO-CUMULATIVA APURADA A ALIQUOTA POR UNIDADE DE MEDIDA DE PRODUTO", "" } )
	aAdd( aBody, { "", "000004", "04", "CONTRIBUICAO NAO-CUMULATIVA APURADA A ALIQUOTA BASICA – ATIVIDADE IMOBILIARIA", "" } )
	aAdd( aBody, { "", "000005", "31", "CONTRIBUICAO APURADA POR SUBSTITUICAO TRIBUTARIA", "" } )
	aAdd( aBody, { "", "000006", "32", "CONTRIBUICAO APURADA POR SUBSTITUICAO TRIBUTARIA – VENDAS A ZONA FRANCA DE MANAUS", "" } )
	aAdd( aBody, { "", "000007", "51", "CONTRIBUICAO CUMULATIVA APURADA A ALIQUOTA BASICA", "" } )
	aAdd( aBody, { "", "000008", "52", "CONTRIBUICAO CUMULATIVA APURADA A ALIQUOTAS DIFERENCIADAS", "" } )
	aAdd( aBody, { "", "000009", "53", "CONTRIBUICAO CUMULATIVA APURADA A ALIQUOTA POR UNIDADE DE MEDIDA DE PRODUTO", "" } )
	aAdd( aBody, { "", "000010", "54", "CONTRIBUICAO CUMULATIVA APURADA A ALIQUOTA BASICA – ATIVIDADE IMOBILIARIA", "" } )
	aAdd( aBody, { "", "000011", "70", "CONTRIBUICAO APURADA DA ATIVIDADE IMOBILIARIA - RET", "" } )
	aAdd( aBody, { "", "000012", "71", "CONTRIBUICAO APURADA DE SCP – INCIDENCIA NAO CUMULATIVA", "" } )
	aAdd( aBody, { "", "000013", "72", "CONTRIBUICAO APURADA DE SCP – INCIDENCIA CUMULATIVA", "" } )
	aAdd( aBody, { "", "000014", "99", "CONTRIBUICAO PARA O PIS/PASEP – FOLHA DE SALARIOS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )