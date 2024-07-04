#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA001.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA001
Cadastro MVC dos Modelos de Documentos Fiscais 

@author Gustavo G. Rueda
@since 07/05/2012
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA001()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Cadastro dos Modelos de Documentos Fiscais"
oBrw:SetAlias( 'C01')
oBrw:SetMenuDef( 'TAFA001' )

C01->(DbSetOrder(1))
//oBrw:Refresh()

oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Gustavo G. Rueda
@since 07/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA001" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Gustavo G. Rueda
@since 07/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC01 	:= 	FWFormStruct( 1, 'C01' )
Local oModel 	:= 	MPFormModel():New( 'TAFA001' )

oModel:AddFields('MODEL_C01', /*cOwner*/, oStruC01)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Gustavo G. Rueda
@since 07/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA001' )
Local 	oStruC01 	:= 	FWFormStruct( 2, 'C01' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C01', oStruC01, 'MODEL_C01' )

oView:EnableTitleView( 'VIEW_C01', STR0001 )	//"Cadastro dos Modelos de Documentos Fiscais"
oView:CreateHorizontalBox( 'FIELDSC01', 100 )
oView:SetOwnerView( 'VIEW_C01', 'FIELDSC01' )

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

nVerAtu := 1023.13

If nVerEmp < nVerAtu
	aAdd( aHeader, "C01_FILIAL" )
	aAdd( aHeader, "C01_ID" )
	aAdd( aHeader, "C01_CODIGO" )
	aAdd( aHeader, "C01_DESCRI" )
	aAdd( aHeader, "C01_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "NOTA FISCAL", "" } )
	aAdd( aBody, { "", "000002", "02", "NOTA FISCAL DE VENDA A CONSUMIDOR", "" } )
	aAdd( aBody, { "", "000003", "04", "NOTA FISCAL DE PRODUTOR", "" } )
	aAdd( aBody, { "", "000004", "06", "NOTA FISCAL/CONTA DE ENERGIA ELETRICA", "" } )
	aAdd( aBody, { "", "000005", "07", "NOTA FISCAL DE SERVICO DE TRANSPORTE", "" } )
	aAdd( aBody, { "", "000006", "08", "CONHECIMENTO DE TRANSPORTE RODOVIARIO DE CARGAS", "" } )
	aAdd( aBody, { "", "000007", "09", "CONHECIMENTO DE TRANSPORTE AQUAVIARIO DE CARGAS", "" } )
	aAdd( aBody, { "", "000008", "10", "CONHECIMENTO AEREO", "" } )
	aAdd( aBody, { "", "000009", "11", "CONHECIMENTO DE TRANSPORTE FERROVIARIO DE CARGAS", "" } )
	aAdd( aBody, { "", "000010", "13", "BILHETE DE PASSAGEM RODOVIARIO", "" } )
	aAdd( aBody, { "", "000011", "14", "BILHETE DE PASSAGEM AQUAVIARIO", "" } )
	aAdd( aBody, { "", "000012", "15", "BILHETE DE PASSAGEM E NOTA DE BAGAGEM", "" } )
	aAdd( aBody, { "", "000013", "16", "BILHETE DE PASSAGEM FERROVIARIO", "" } )
	aAdd( aBody, { "", "000014", "17", "DESPACHO DE TRANSPORTE", "" } )
	aAdd( aBody, { "", "000015", "18", "RESUMO DE MOVIMENTO DIARIO", "" } )
	aAdd( aBody, { "", "000016", "1B", "NOTA FISCAL AVULSA", "" } )
	aAdd( aBody, { "", "000017", "20", "ORDEM DE COLETA DE CARGAS", "" } )
	aAdd( aBody, { "", "000018", "21", "NOTA FISCAL DE SERVICO DE COMUNICACAO", "" } )
	aAdd( aBody, { "", "000019", "22", "NOTA FISCAL DE SERVICO DE TELECOMUNICACAO", "" } )
	aAdd( aBody, { "", "000020", "23", "GNRE", "" } )
	aAdd( aBody, { "", "000021", "24", "AUTORIZACAO DE CARREGAMENTO E TRANSPORTE", "" } )
	aAdd( aBody, { "", "000022", "25", "MANIFESTO DE CARGA", "" } )
	aAdd( aBody, { "", "000023", "26", "CONHECIMENTO DE TRANSPORTE MULTIMODAL DE CARGAS", "" } )
	aAdd( aBody, { "", "000024", "27", "NOTA FISCAL DE TRANSPORTE FERROVIARIO DE CARGA", "" } )
	aAdd( aBody, { "", "000025", "28", "NOTA FISCAL/CONTA DE FORNECIMENTO DE GAS CANALIZADO", "" } )
	aAdd( aBody, { "", "000026", "29", "NOTA FISCAL/CONTA DE FORNECIMENTO DE AGUA CANALIZADA", "" } )
	aAdd( aBody, { "", "000027", "2D", "CUPOM FISCAL", "" } )
	aAdd( aBody, { "", "000028", "2E", "CUPOM FISCAL BILHETE DE PASSAGEM", "" } )
	aAdd( aBody, { "", "000029", "55", "NOTA FISCAL ELETRONICA NF-E", "" } )
	aAdd( aBody, { "", "000030", "57", "CONHECIMENTO DE TRANSPORTE ELETRONICO - CT-E", "" } )
	aAdd( aBody, { "", "000031", "59", "CUPOM FISCAL ELETRONICO – CF-E-SAT", "" } )
	aAdd( aBody, { "", "000032", "60", "CUPOM FISCAL ELETRONICO CF-E-ECF", "" } )
	aAdd( aBody, { "", "000033", "65", "NOTA FISCAL ELETRONICA AO CONSUMIDOR FINAL – NFC-E", "" } )
	aAdd( aBody, { "", "000034", "8B", "CONHECIMENTO DE TRANSPORTE DE CARGAS AVULSO", "" } )
	aAdd( aBody, { "", "000035", "98", "NOTA FISCAL DE PRESTACAO DE SERVICO (ISSQN)", "" } )
	aAdd( aBody, { "", "000036", "99", "OUTROS", "" } )
	aAdd( aBody, { "", "000038", "63", "BILHETE DE PASSAGEM ELETRÔNICO – BP-e", "" } )
	aAdd( aBody, { "", "000039", "67", "CONHECIMENTO DE TRANSPORTE ELETRÔNICO PARA OUTROS SERVIÇOS - CT-e OS", "" } )
	aAdd( aBody, { "", "000040", "56", "NOTA FISCAL ELETRONICA DE SERVIÇO", "" } )
	
	//Verifica se o dicionario aplicado é o da DIEF-CE e da Declan-RJ
	If(AliasInDic("T30") .And. AliasInDic("T39"))
		aAdd( aBody, { "", "000037", "37", "CUPOM FISCAL", "" } )
	EndIf

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )