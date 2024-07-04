#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA190.CH"
                                                                       
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA190
Cadastro MVC dos Detalhamentos da Receita para emissao da GNRE Online

@author Rodrigo Aguilar
@since 26/09/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA190()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	// "Cadastro dos Códigos de Detalhamento da Receita para emissão da GNRE Online"
oBrw:SetAlias( 'C6S')
oBrw:SetMenuDef( 'TAFA190' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rodrigo Aguilar
@since 26/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA190" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 26/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC6S 	:= 	FWFormStruct( 1, 'C6S' )
Local oModel 	:= 	MPFormModel():New( 'TAFA190' )

oModel:AddFields('MODEL_C6S', /*cOwner*/, oStruC6S)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 26/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA190' )
Local 	oStruC6S 	:= 	FWFormStruct( 2, 'C6S' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C6S', oStruC6S, 'MODEL_C6S' )

oView:EnableTitleView( 'VIEW_C6S', STR0001 )	// "Cadastro dos Códigos de Detalhamento da Receita para emissão da GNRE Online"
oView:CreateHorizontalBox( 'FIELDSC6S', 100 )
oView:SetOwnerView( 'VIEW_C6S', 'FIELDSC6S' )

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
	aAdd( aHeader, "C6S_FILIAL" )
	aAdd( aHeader, "C6S_ID" )
	aAdd( aHeader, "C6S_CODIGO" )
	aAdd( aHeader, "C6S_DESCRI" )
	aAdd( aHeader, "C6S_VALIDA" )

	aAdd( aBody, { "", "000001", "000003", "ICMS - Antecipacao", "" } )
	aAdd( aBody, { "", "000002", "000004", "ICMS - Combustivel", "" } )
	aAdd( aBody, { "", "000003", "000005", "ICMS - Diferencial de Aliquota", "" } )
	aAdd( aBody, { "", "000004", "000006", "ICMS - Fundo Especial de Combate e Erradicacao da Pobreza", "" } )
	aAdd( aBody, { "", "000005", "000007", "ICMS - Substituicao Tributaria Interna", "" } )
	aAdd( aBody, { "", "000006", "000009", "10 - Peticoes ou requerimentos dirigidos a autoridades administrativas estaduais", "" } )
	aAdd( aBody, { "", "000007", "000010", "10022 - Utilizado para recolhimento do imposto postergado por regime especial", "" } )
	aAdd( aBody, { "", "000008", "000011", "10030 - Repasse da refinaria - Combustiveis e outros", "" } )
	aAdd( aBody, { "", "000009", "000012", "10049 - Substituicao tributaria - prazo normal", "" } )
	aAdd( aBody, { "", "000010", "000013", "10200 - Substituicao Tributaria - mercadoria desacompanhada de GNRE", "" } )
	aAdd( aBody, { "", "000011", "000014", "10251 - Repasse da refinaria - Combustiveis e outros", "" } )
	aAdd( aBody, { "", "000012", "000015", "10383 - Utilizado para recolhimento da parcela unica do imposto, equivalente a 100% do montante devido no mes anterior (ver classe 10391)", "" } )
	aAdd( aBody, { "", "000013", "000016", "10391 - Utilizado para recolhimento do valor remanescente do saldo devedor do imposto (ver classe 10383)", "" } )
	aAdd( aBody, { "", "000014", "000017", "1538 - ICMS COMERCIO SUBST.TRIB. N.O CADAST.", "" } )
	aAdd( aBody, { "", "000015", "000018", "1546 - ICMS COM COMB.LIQ.GAS.SUB.TRIB.NAO CAD.", "" } )
	aAdd( aBody, { "", "000016", "000020", "1813 - ICMS COMERCIO SUBSTITUICAO TRIBUTARIA", "" } )
	aAdd( aBody, { "", "000017", "000021", "1821 - ICMS COMERCIO COMB.LIQ.GAS.SUBST.TRIBUT.", "" } )
	aAdd( aBody, { "", "000018", "000022", "2550 - ICMS INDUSTRIA SUBST.TRIBUT.NAO CADAS.", "" } )
	aAdd( aBody, { "", "000019", "000023", "2810 - ICMS INDUSTRIA SUBSTITUICAO TRIBUTARIA", "" } )
	aAdd( aBody, { "", "000020", "000024", "3816 - ICMS TRANSP SUBSTITUICAO TRIBUTARIA", "" } )
	aAdd( aBody, { "", "000021", "000025", "3824 - ICMS COMUNICACAO SUBSTITUICAO TRIBUTARIA", "" } )
	aAdd( aBody, { "", "000022", "000026", "4685 - ICMS SUBSTITUIC.O TRIBUTARIA - GINF", "" } )
	aAdd( aBody, { "", "000023", "000032", "1414 - ICMS COMERCIO IMPORTAC.O", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )