#INCLUDE "PROTHEUS.CH"            
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA178.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA178
Cadastro MVC dos Tipos de Movimentos do Bem/Componente

@author Rodrigo Aguilar
@since 10/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA178()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Cadastro dos Tipos de Movimentos do Bem / Componente
oBrw:SetAlias( 'C52')
oBrw:SetMenuDef( 'TAFA178' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rodrigo Aguilar
@since 10/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA178" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 10/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC52 	:= 	FWFormStruct( 1, 'C52' )
Local oModel 	:= 	MPFormModel():New( 'TAFA178' )

oModel:AddFields('MODEL_C52', /*cOwner*/, oStruC52)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 10/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA178' )
Local 	oStruC52 	:= 	FWFormStruct( 2, 'C52' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C52', oStruC52, 'MODEL_C52' )

oView:EnableTitleView( 'VIEW_C52', STR0001 )	//"Cadastro dos Tipos de Movimentos do Bem / Componente
oView:CreateHorizontalBox( 'FIELDSC52', 100 )
oView:SetOwnerView( 'VIEW_C52', 'FIELDSC52' )

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
	aAdd( aHeader, "C52_FILIAL" )
	aAdd( aHeader, "C52_ID" )
	aAdd( aHeader, "C52_CODIGO" )
	aAdd( aHeader, "C52_DESCRI" )
	aAdd( aHeader, "C52_VALIDA" )

	aAdd( aBody, { "", "000001", "SI", "SALDO INICIAL DE BENS IMOBILIZADOS", "" } )
	aAdd( aBody, { "", "000002", "IM", "IMOBILIZACAO DE BEM INDIVIDUAL", "" } )
	aAdd( aBody, { "", "000003", "IA", "IMOBILIZACAO EM ANDAMENTO - COMPONENTE", "" } )
	aAdd( aBody, { "", "000004", "CI", "CONCLUSAO DE IMOBILIZACAO EM ANDAMENTO – BEM RESULTANTE", "" } )
	aAdd( aBody, { "", "000005", "MC", "IMOBILIZACAO ORIUNDA DO ATIVO CIRCULANTE", "" } )
	aAdd( aBody, { "", "000006", "BA", "BAIXA DO BEM - FIM DO PERIODO DE APROPRIACAO", "" } )
	aAdd( aBody, { "", "000007", "AT", "ALIENACAO OU TRANSFERENCIA", "" } )
	aAdd( aBody, { "", "000008", "PE", "PERECIMENTO, EXTRAVIO OU DETERIORACAO", "" } )
	aAdd( aBody, { "", "000009", "OT", "OUTRAS SAIDAS DO IMOBILIZADO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )