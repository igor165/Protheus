#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA017.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA017
Cadastro do CST da Pis/Cofins

@author Marcio Nunes
@since 05/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA017()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro do CST da Pis/Cofins
oBrw:SetAlias( 'C17')
oBrw:SetMenuDef( 'TAFA017' )
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
Return XFUNMnuTAF( "TAFA017" )
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
Local oStruC17 	:= 	FWFormStruct( 1, 'C17' )
Local oModel 	:= 	MPFormModel():New( 'TAFA017' )

oModel:AddFields('MODEL_C17', /*cOwner*/, oStruC17)

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA017' )
Local 	oStruC17 	:= 	FWFormStruct( 2, 'C17' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C17', oStruC17, 'MODEL_C17' )

oView:EnableTitleView( 'VIEW_C17', STR0001 ) //Cadastro do CST da Pis/Cofins
oView:CreateHorizontalBox( 'FIELDSC17', 100 )
oView:SetOwnerView( 'VIEW_C17', 'FIELDSC17' )

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
	aAdd( aHeader, "C17_FILIAL" )
	aAdd( aHeader, "C17_ID" )
	aAdd( aHeader, "C17_CODIGO" )
	aAdd( aHeader, "C17_DESCRI" )
	aAdd( aHeader, "C17_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "Operacao Tributavel com Aliquota Basica", "" } )
	aAdd( aBody, { "", "000002", "02", "Operacao Tributavel com Aliquota Diferenciada", "" } )
	aAdd( aBody, { "", "000003", "03", "Operacao Tributavel com Aliquota por Unidade de Medida de Produto", "" } )
	aAdd( aBody, { "", "000004", "06", "Operacao Tributavel a Aliquota Zero", "" } )
	aAdd( aBody, { "", "000005", "07", "Operacao Isenta da Contribuicao", "" } )
	aAdd( aBody, { "", "000006", "08", "Operacao sem Incidencia da Contribuicao", "" } )
	aAdd( aBody, { "", "000007", "09", "Operacao com Suspensao da Contribuicao", "" } )
	aAdd( aBody, { "", "000008", "04", "Operacao Tributavel Monofasica - Revenda a Aliquota Zero", "" } )
	aAdd( aBody, { "", "000009", "05", "Operacao Tributavel por Substituicao Tributaria", "" } )
	aAdd( aBody, { "", "000010", "49", "Outras Operacaes de Saida", "" } )
	aAdd( aBody, { "", "000011", "50", "Operacao com Direito a Credito - Vinculada Exclusivamente a Receita Tributada no Mercado Interno", "" } )
	aAdd( aBody, { "", "000012", "51", "Operacao com Direito a Credito ? Vinculada Exclusivamente a Receita Nao Tributada no Mercado Interno", "" } )
	aAdd( aBody, { "", "000013", "52", "Operacao com Direito a Credito - Vinculada Exclusivamente a Receita de Exportacao", "" } )
	aAdd( aBody, { "", "000014", "53", "Operacao com Direito a Credito - Vinculada a Receitas Tributadas e Nao-Tributadas no Mercado Interno", "" } )
	aAdd( aBody, { "", "000015", "54", "Operacao com Direito a Credito - Vinculada a Receitas Tributadas no Mercado Interno e de Exportacao", "" } )
	aAdd( aBody, { "", "000016", "55", "Operacao com Direito a Credito - Vinculada a Receitas Nao-Tributadas no Mercado Interno e de Exportacao", "" } )
	aAdd( aBody, { "", "000017", "56", "Operacao com Direito a Credito - Vinculada a Receitas Tributadas e Nao-Tributadas no Mercado Interno, e de Exportacao", "" } )
	aAdd( aBody, { "", "000018", "60", "Credito Presumido - Operacao de Aquisicao Vinculada Exclusivamente a Receita Tributada no Mercado Interno", "" } )
	aAdd( aBody, { "", "000019", "61", "Credito Presumido - Operacao de Aquisicao Vinculada Exclusivamente a Receita Nao-Tributada no Mercado Interno", "" } )
	aAdd( aBody, { "", "000020", "62", "Credito Presumido - Operacao de Aquisicao Vinculada Exclusivamente a Receita de Exportacao", "" } )
	aAdd( aBody, { "", "000021", "63", "Credito Presumido - Operacao de Aquisicao Vinculada a Receitas Tributadas e Nao-Tributadas no Mercado Interno", "" } )
	aAdd( aBody, { "", "000022", "64", "Credito Presumido - Operacao de Aquisicao Vinculada a Receitas Tributadas no Mercado Interno e de Exportacao", "" } )
	aAdd( aBody, { "", "000023", "65", "Credito Presumido - Operacao de Aquisicao Vinculada a Receitas Nao-Tributadas no Mercado Interno e de Exportacao", "" } )
	aAdd( aBody, { "", "000024", "66", "Credito Presumido - Operacao de Aquisicao Vinculada a Receitas Tributadas e Nao-Tributadas no Mercado Interno, e de Exportacao", "" } )
	aAdd( aBody, { "", "000025", "67", "Credito Presumido - Outras Operacaes", "" } )
	aAdd( aBody, { "", "000026", "70", "Operacao de Aquisicao sem Direito a Credito", "" } )
	aAdd( aBody, { "", "000027", "71", "Operacao de Aquisicao com Isencao", "" } )
	aAdd( aBody, { "", "000028", "72", "Operacao de Aquisicao com Suspensao", "" } )
	aAdd( aBody, { "", "000029", "73", "Operacao de Aquisicao a Aliquota Zero", "" } )
	aAdd( aBody, { "", "000030", "74", "Operacao de Aquisicao sem Incidencia da Contribuicao", "" } )
	aAdd( aBody, { "", "000031", "75", "Operacao de Aquisicao por Substituicao Tributaria", "" } )
	aAdd( aBody, { "", "000032", "98", "Outras Operacaes de Entrada", "" } )
	aAdd( aBody, { "", "000033", "99", "Outras Operacaes", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )