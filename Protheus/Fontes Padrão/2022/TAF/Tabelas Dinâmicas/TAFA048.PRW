#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA048.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA048
Cadastro MVC - Cadastro de Indicador da Natureza do Frete Contratado

@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA048()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Indicador da Natureza do Frete Contratado
oBrw:SetAlias( 'C3P')
oBrw:SetMenuDef( 'TAFA048' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA048" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC3P 	:= 	FWFormStruct( 1, 'C3P' )
Local oModel 	:= 	MPFormModel():New( 'TAFA048' )

oModel:AddFields('MODEL_C3P', /*cOwner*/, oStruC3P)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA048' )
Local 	oStruC3P 	:= 	FWFormStruct( 2, 'C3P' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C3P', oStruC3P, 'MODEL_C3P' )

oView:EnableTitleView( 'VIEW_C3P', STR0001 ) //Cadastro de Indicador da Natureza do Frete Contratado
oView:CreateHorizontalBox( 'FIELDSC3P', 100 )
oView:SetOwnerView( 'VIEW_C3P', 'FIELDSC3P' )

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
	aAdd( aHeader, "C3P_FILIAL" )
	aAdd( aHeader, "C3P_ID" )
	aAdd( aHeader, "C3P_CODIGO" )
	aAdd( aHeader, "C3P_DESCRI" )
	aAdd( aHeader, "C3P_VALIDA" )

	aAdd( aBody, { "", "000001", "0", "OPERACOES DE VENDAS, COM ONUS SUPORTADO PELO ESTABELECIMENTO VENDEDOR", "" } )
	aAdd( aBody, { "", "000002", "1", "OPERACOES DE VENDAS, COM ONUS SUPORTADO PELO ADQUIRENTE", "" } )
	aAdd( aBody, { "", "000003", "2", "OPERACOES DE COMPRAS (BENS PARA REVENDA, MATERIAS-PRIMA E OUTROS PRODUTOS, GERADORES DE CREDITO)", "" } )
	aAdd( aBody, { "", "000004", "3", "OPERACOES DE COMPRAS (BENS PARA REVENDA, MATERIAS-PRIMA E OUTROS PRODUTOS, NAO GERADORES DE CREDITO)", "" } )
	aAdd( aBody, { "", "000005", "4", "TRANSFERENCIA DE PRODUTOS ACABADOS ENTRE ESTABELECIMENTOS DA PESSOA JURIDICA", "" } )
	aAdd( aBody, { "", "000006", "5", "TRANSFERENCIA DE PRODUTOS EM ELABORACAO ENTRE ESTABELECIMENTOS DA PESSOA JURIDICA", "" } )
	aAdd( aBody, { "", "000007", "9", "OUTRAS", "" } )
	aAdd( aBody, { "", "000008", "A", "NEGOCIAVEL", "" } )
	aAdd( aBody, { "", "000009", "B", "NAO NEGOCIAVEL", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )