#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA160.CH"                            
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA160
Cadastro MVC de Código da Contribuição Social

@author Fabio V. Santana
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA160()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro das Tabelas da Natureza de Receita
oBrw:SetAlias( 'C1X')
oBrw:SetMenuDef( 'TAFA160' )
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
Return XFUNMnuTAF( "TAFA160" )
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
Local oStruC1X 	:= 	FWFormStruct( 1, 'C1X' )
Local oModel 	:= 	MPFormModel():New( 'TAFA160' )

oModel:AddFields('MODEL_C1X', /*cOwner*/, oStruC1X)

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA160' )
Local 	oStruC1X 	:= 	FWFormStruct( 2, 'C1X' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C1X', oStruC1X, 'MODEL_C1X' )

oView:EnableTitleView( 'VIEW_C1X', STR0001 ) //Cadastro das Tabelas da Natureza de Receita
oView:CreateHorizontalBox( 'FIELDSC1X', 100 )
oView:SetOwnerView( 'VIEW_C1X', 'FIELDSC1X' )

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
	aAdd( aHeader, "C1X_FILIAL" )
	aAdd( aHeader, "C1X_ID" )
	aAdd( aHeader, "C1X_CODIGO" )
	aAdd( aHeader, "C1X_DESCRI" )
	aAdd( aHeader, "C1X_VALIDA" )

	aAdd( aBody, { "", "000002", "4310", "TABELA PRODUTOS SUJEITOS A INCIDENCIA MONOFASICA DA CONTRIBUICAO SOCIAL – ALIQUOTAS DIFERENCIADAS (CST 02 E 04)", "" } )
	aAdd( aBody, { "", "000003", "4311", "TABELA PRODUTOS SUJEITOS A INCIDENCIA MONOFASICA DA CONTRIBUICAO SOCIAL – ALIQUOTAS POR UNIDADE DE MEDIDA DE PRODUTO - (CST 03 E 04)", "" } )
	aAdd( aBody, { "", "000004", "4312", "TABELA PRODUTOS SUJEITOS A SUBSTITUICAO TRIBUTARIA DA CONTRIBUICAO SOCIAL (CST 05)", "" } )
	aAdd( aBody, { "", "000005", "4313", "TABELA PRODUTOS SUJEITOS A ALIQUOTA ZERO DA CONTRIBUICAO SOCIAL (CST 06)", "" } )
	aAdd( aBody, { "", "000006", "4314", "TABELA OPERACOES COM ISENCAO DA CONTRIBUICAO SOCIAL (CST 07)", "" } )
	aAdd( aBody, { "", "000007", "4315", "TABELA OPERACOES SEM INCIDENCIA DA CONTRIBUICAO SOCIAL (CST 08)", "" } )
	aAdd( aBody, { "", "000008", "4316", "TABELA OPERACOES COM SUSPENSAO DA CONTRIBUICAO SOCIAL (CST 09)", "" } )
	aAdd( aBody, { "", "000009", "4317", "TABELA OUTROS PRODUTOS E OPERACOES SUJEITOS A ALIQUOTAS DIFERENCIADAS (CST 02)", "" } )
	aAdd( aBody, { "", "000001", "439", "TABELA DE ALIQUOTAS DE CREDITOS PRESUMIDOS DA AGROINDUSTRIA", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )