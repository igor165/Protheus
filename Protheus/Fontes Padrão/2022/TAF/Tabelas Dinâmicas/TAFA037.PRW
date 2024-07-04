#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA037.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA037
Cadastro MVC de Indicador de Natureza da Retenção na Fonte 

@author Fabio V. Santana
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA037()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro de Indicador de Natureza da Retenção na Fonte 
oBrw:SetAlias( 'C1Q')
oBrw:SetMenuDef( 'TAFA037' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA037" )
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
Local oStruC1Q 	:= 	FWFormStruct( 1, 'C1Q' )
Local oModel 	:= 	MPFormModel():New( 'TAFA037' )

oModel:AddFields('MODEL_C1Q', /*cOwner*/, oStruC1Q)

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA037' )
Local 	oStruC1Q 	:= 	FWFormStruct( 2, 'C1Q' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C1Q', oStruC1Q, 'MODEL_C1Q' )

oView:EnableTitleView( 'VIEW_C1Q', STR0001 ) //Cadastro de Indicador de Natureza da Retenção na Fonte 
oView:CreateHorizontalBox( 'FIELDSC1Q', 100 )
oView:SetOwnerView( 'VIEW_C1Q', 'FIELDSC1Q' )

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
	aAdd( aHeader, "C1Q_FILIAL" )
	aAdd( aHeader, "C1Q_ID" )
	aAdd( aHeader, "C1Q_CODIGO" )
	aAdd( aHeader, "C1Q_DESCRI" )
	aAdd( aHeader, "C1Q_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "RETENCAO POR ORGAOS, AUTARQUIAS E FUNDACOES FEDERAIS", "" } )
	aAdd( aBody, { "", "000002", "02", "RETENCAO POR OUTRAS ENTIDADES DA ADMINISTRACAO PUBLICA FEDERAL", "" } )
	aAdd( aBody, { "", "000003", "03", "RETENCAO POR PESSOAS JURIDICAS DE DIREITO PRIVADO", "" } )
	aAdd( aBody, { "", "000004", "04", "RECOLHIMENTO POR SOCIEDADE COOPERATIVA", "" } )
	aAdd( aBody, { "", "000005", "05", "RETENCAO POR FABRICANTE DE MAQUINAS E VEICULOS", "" } )
	aAdd( aBody, { "", "000006", "99", "OUTRAS RETENCOES", "" } )
	aAdd( aBody, { "", "000007", "59", "OUTRAS RETENCOES - RENDIMENTOS SUJEITOS A REGRA ESPECIFICA DE INCIDENCIA CUMULATIVA (ART. 8º DA LEI Nº 10.637/2002 E ART. 10 DA LEI Nº 10.833/2003)", "" } )
	aAdd( aBody, { "", "000008", "52", "RETENCAO POR OUTRAS ENTIDADES DA ADMINISTRACAO PUBLICA FEDERAL", "" } )
	aAdd( aBody, { "", "000009", "53", "RETENCAO POR PESSOAS JURIDICAS DE DIREITO PRIVADO", "" } )
	aAdd( aBody, { "", "000010", "54", "RECOLHIMENTO POR SOCIEDADE COOPERATIVA", "" } )
	aAdd( aBody, { "", "000011", "55", "RETENCAO POR FABRICANTE DE MAQUINAS E VEICULOS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )