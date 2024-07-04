#INCLUDE "PROTHEUS.CH"                                       
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA166.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA166
Cadastro MVC - Cadastro dos campos de Identificação dos Itens

@author Mauro A. Goncalves
@since 24/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA166()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro dos campos de Identificação dos Itens
oBrw:SetAlias( 'C2Q')
oBrw:SetMenuDef( 'TAFA166' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 24/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA166" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 24/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC2Q 	:= 	FWFormStruct( 1, 'C2Q' )
Local oModel 	:= 	MPFormModel():New( 'TAFA166' )

oModel:AddFields('MODEL_C2Q', /*cOwner*/, oStruC2Q)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 24/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA166' )
Local 	oStruC2Q 	:= 	FWFormStruct( 2, 'C2Q' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C2Q', oStruC2Q, 'MODEL_C2Q' )

oView:EnableTitleView( 'VIEW_C2Q', STR0001 ) //Cadastro dos campos de Identificação dos Itens
oView:CreateHorizontalBox( 'FIELDSC2Q', 100 )
oView:SetOwnerView( 'VIEW_C2Q', 'FIELDSC2Q' )

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
	aAdd( aHeader, "C2Q_FILIAL" )
	aAdd( aHeader, "C2Q_ID" )
	aAdd( aHeader, "C2Q_NUMCPO" )
	aAdd( aHeader, "C2Q_NOMCPO" )
	aAdd( aHeader, "C2Q_DESCRI" )

	aAdd( aBody, { "", "000001", "01", "CODIGO", "CODIGO DO ITEM" } )
	aAdd( aBody, { "", "000002", "02", "DESCRI", "DESCRICAO DO ITEM" } )
	aAdd( aBody, { "", "000003", "03", "CODBAR", "CODIGO DE BARRAS" } )
	aAdd( aBody, { "", "000004", "04", "UM", "UNIDADE DE MEDIDA" } )
	aAdd( aBody, { "", "000005", "05", "TIPITE", "TIPO DO ITEM" } )
	aAdd( aBody, { "", "000006", "06", "CODNCM", "CODIGO DO NCM" } )
	aAdd( aBody, { "", "000007", "07", "EXCNCM", "CODIGO DE EXCECAO NCM" } )
	aAdd( aBody, { "", "000008", "08", "CODGEN", "CODIGO DO GENERO" } )
	aAdd( aBody, { "", "000009", "09", "CODSER", "CODIGO DO SERVICO" } )
	aAdd( aBody, { "", "000010", "10", "CODANP", "CODIGO DO COMBUSTIVEL ANP" } )
	aAdd( aBody, { "", "000011", "11", "CODIND", "CODIGO DA TABELA INCIDENCIA" } )
	aAdd( aBody, { "", "000012", "12", "CODGRU", "CODIGO DO GRUPO" } )
	aAdd( aBody, { "", "000013", "13", "NATREC", "NATUREZA DA RECEITA" } )
	aAdd( aBody, { "", "000014", "14", "ORIMER", "DATA INCLUSAO DO PRODUTO NO ERP" } )
	aAdd( aBody, { "", "000015", "15", "DTINCL", "DATA INCLUSAO DO PRODUTO NO ERP" } )
	aAdd( aBody, { "", "000016", "16", "ALQICM", "ALIQUOTA DO ICMS" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )