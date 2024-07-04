#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                     
#INCLUDE "TAFA162.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA162
Cadastro MVC - C2M – Cadastro do Tipo do item (Atividades Industriais, Comerciais e Serviços)

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA162()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //C2M – Cadastro do Tipo do item (Atividades Industriais, Comerciais e Serviços), 
oBrw:SetAlias( 'C2M')
oBrw:SetMenuDef( 'TAFA162' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA162" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC2M 	:= 	FWFormStruct( 1, 'C2M' )
Local oModel 	:= 	MPFormModel():New( 'TAFA162' )

oModel:AddFields('MODEL_C2M', /*cOwner*/, oStruC2M)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA162' )
Local 	oStruC2M 	:= 	FWFormStruct( 2, 'C2M' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C2M', oStruC2M, 'MODEL_C2M' )

oView:EnableTitleView( 'VIEW_C2M', STR0001 ) //C2M – Cadastro do Tipo do item (Atividades Industriais, Comerciais e Serviços), 
oView:CreateHorizontalBox( 'FIELDSC2M', 100 )
oView:SetOwnerView( 'VIEW_C2M', 'FIELDSC2M' )

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

//Verifica se o dicionario aplicado é o da DIEF-CE e da Declan-RJ
If(AliasInDic("T30") .And. AliasInDic("T39"))
	nVerAtu := 1007
Else
	nVerAtu := 1003
EndIf

If nVerEmp < nVerAtu
	aAdd( aHeader, "C2M_FILIAL" )
	aAdd( aHeader, "C2M_ID" )
	aAdd( aHeader, "C2M_CODIGO" )
	aAdd( aHeader, "C2M_DESCRI" )
	aAdd( aHeader, "C2M_VALIDA" )

	aAdd( aBody, { "", "000001", "00", "MERCADORIA PARA REVENDA", "" } )
	aAdd( aBody, { "", "000002", "01", "MATERIA PRIMA", "" } )
	aAdd( aBody, { "", "000003", "02", "EMBALAGEM", "" } )
	aAdd( aBody, { "", "000004", "03", "PRODUTO EM PROCESSO", "" } )
	aAdd( aBody, { "", "000005", "04", "PRODUTO ACABADO", "" } )
	aAdd( aBody, { "", "000006", "05", "SUBPRODUTO", "" } )
	aAdd( aBody, { "", "000007", "06", "PRODUTO INTERMEDIARIO", "" } )
	aAdd( aBody, { "", "000008", "07", "MATERIAL DE USO E CONSUMO", "" } )
	aAdd( aBody, { "", "000009", "08", "ATIVO IMOBILIZADO", "" } )
	aAdd( aBody, { "", "000010", "09", "SERVICOS", "" } )
	aAdd( aBody, { "", "000011", "10", "OUTROS INSUMOS", "" } )
	aAdd( aBody, { "", "000012", "99", "OUTRAS", "" } )
	
	//Verifica se o dicionario aplicado é o da DIEF-CE e da Declan-RJ
	If(AliasInDic("T30") .And. AliasInDic("T39"))
		aAdd( aBody, { "", "000013", "11", "SERVIÇO COM INCIDÊNCIA DE ICMS", "" } )
		aAdd( aBody, { "", "000014", "12", "MERCADORIA RECEBIDA EM CONSIGNAÇÃO", "" } )
	EndIf
	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )