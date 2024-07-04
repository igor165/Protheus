#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA380.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA380
Cadastro MVC de Obrigações Fiscais

@author Paulo S. Vilas B.Santana
@since 10/04/2015
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA380()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Código da DIPAM-B"
oBrw:SetAlias('CW5')
oBrw:SetMenuDef( 'TAFA380' )
CW5->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Paulo S. Vilas B.Santana
@since 10/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA380" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Paulo S. Vilas B.Santana
@since 10/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local 	oStruCW5	:= 	FWFormStruct( 1, 'CW5' )
Local 	oStruCZQ	:= 	FWFormStruct( 1, 'CZQ' )
Local 	oModel 		:=  MPFormModel():New( 'TAFA380' , , , {|oModel| SaveModel( oModel ) } )


oModel:AddFields('MODEL_CW5', /*cOwner*/, oStruCW5)
oModel:AddGrid  ('MODEL_CZQ', 'MODEL_CW5', oStruCZQ)  
oModel:GetModel ('MODEL_CZQ'):SetOptional( .T. )
oModel:GetModel ('MODEL_CZQ' ):SetUniqueLine( { 'CZQ_ID', 'CZQ_IDCFOP'} )

oModel:SetRelation( 'MODEL_CZQ', { { 'CZQ_FILIAL', 'xFilial( "CZQ" )' } , { 'CZQ_ID' , "CW5_ID" } }, CZQ->( IndexKey( 1 ) ) )
oModel:GetModel('MODEL_CW5'):SetPrimaryKey( { "CW5_ID" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Paulo S. Vilas B.Santana
@since 10/04/2015
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA380' )
Local oStruCW5 	:= 	FWFormStruct( 2, 'CW5' )
Local oStruCZQ 	:= 	FWFormStruct( 2, 'CZQ' )
Local oView 	:= 	FWFormView():New()

oStruCZQ :RemoveField("CZQ_ID")
oStruCZQ :RemoveField("CZQ_CODDIP")
oStruCZQ :RemoveField("CZQ_IDCFOP")
oStruCZQ :RemoveField("CZQ_DESDIP")

oView:SetModel( oModel )

oView:AddField( 'VIEW_CW5', oStruCW5, 'MODEL_CW5' )
oView:EnableTitleView( 'VIEW_CW5', STR0001 ) //"Código da DIPAM-B"

oView:AddGrid ( 'VIEW_CZQ', oStruCZQ, 'MODEL_CZQ' )
oView:EnableTitleView( 'VIEW_CZQ', STR0002 ) //CFOPs

oView:CreateHorizontalBox( 'FIELDSCW5', 15 )
oView:CreateHorizontalBox( 'GRIDCZQ', 85 )
oView:SetOwnerView( 'VIEW_CW5', 'FIELDSCW5' )
oView:SetOwnerView( 'VIEW_CZQ', 'GRIDCZQ' )

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

nVerAtu := 1009.05

If nVerEmp < nVerAtu
	aAdd( aHeader, "CW5_FILIAL" )
	aAdd( aHeader, "CW5_ID" )
	aAdd( aHeader, "CW5_CODIGO" )
	aAdd( aHeader, "CW5_CABEC" )
	aAdd( aHeader, "CW5_DESCRI" )

	aAdd( aBody, { "", "ea44205d-3aef-3c23-780b-dcada992c8c0", "11", "Compra de produtores paulistas nao equiparados a comerciantes ou a industriais e recebimentos de mercadorias por cooperativa de produtores deste Estado.", "Compras escrituradas de mercadorias de produtores agropecuarios, inclusive hortifrutigranjeiros, por municipio de origem." } )
	aAdd( aBody, { "", "9d17b3ed-b025-af5c-f087-286a57780f5e", "12", "Compra de produtores paulistas nao equiparados a comerciantes ou a industriais e recebimentos de mercadorias por cooperativa de produtores deste Estado.", "Compras nao escrituradas de mercadorias de produtores agropecuarios, inclusive hortifrutigranjeiros, por municipio de origem." } )
	aAdd( aBody, { "", "72c25bc0-414e-583d-2c59-b740efcacbc6", "13", "Compra de produtores paulistas nao equiparados a comerciantes ou a industriais e recebimentos de mercadorias por cooperativa de produtores deste Estado.", "Recebimentos, por cooperativas, de mercadorias remetidas por produtores agropecuarios, inclusive hortifrutigranjeiros, por municipio de origem." } )
	aAdd( aBody, { "", "648f2a39-6c93-6bab-a9bb-0f47d8bd6773", "22", "Rateio do valor adicionado.", '"Este codigo somente devera ser preenchido por: a)    empresas que realizem vendas por intermedio de revendedores ambulantes autonomos' } )
	aAdd( aBody, { "", "2292464f-3ebc-31e1-155f-0fbfd7785e26", "23", "Rateio do valor adicionado.", "Valor dos servicos de transporte intermunicipal e interestadual, distribuido por municipio paulista onde se tenham iniciado os servicos (origem)." } )
	aAdd( aBody, { "", "e269d8e4-f821-cb02-c314-ddf39f469795", "24", "Rateio do valor adicionado.", "Valores adicionados por prestacao de servicos de comunicacao, distribuidos por municipio paulista onde o servico tenha sido prestado." } )
	aAdd( aBody, { "", "56f71ab0-3ad6-85e7-ff1b-c80063a9aa6e", "25", "Rateio do valor adicionado.", "Valor adicionado por fornecimento de energia eletrica distribuido por municipio paulista onde esta tenha sido consumida." } )
	aAdd( aBody, { "", "9b5e04e5-8904-5a50-dd18-bc282793ef63", "26", "Rateio do valor adicionado.", "Distribuir por municipio paulista o valor da producao agropecuaria, inclusive de hortifrutigranjeiros, nos casos de a producao ocorrer no territorio de mais de um municipio." } )
	aAdd( aBody, { "", "f27ef90a-a6ed-075f-e23c-63f00c37ee55", "31", "Operacoes e prestacoes nao escrituradas e dados necessarios ao ajuste dos valores declarados em Guia de Informacao e Apuracao do ICMS.", '"Total de saidas de mercadorias e prestacoes de servicos nao escrituradas: a)    relativas a Autos de Infracao e Imposicao de Multa - AIIM pagos ou inscritos na Divida Ativa no periodo b)    autodenunciadas' } )
	aAdd( aBody, { "", "fba619bb-ee32-cf60-ac58-0dd3b19fb2f9", "35", "Operacoes e prestacoes nao escrituradas e dados necessarios ao ajuste dos valores declarados em Guia de Informacao e Apuracao do ICMS.", '"Total das entradas de mercadorias ou prestacao de servicos nao escrituradas: a)    autodenunciadas b)    relativas a AIIM pagos ou inscritos na Divida Ativa no periodo' } )
	aAdd( aBody, { "", "7106b27b-bab8-4afc-b851-df62ccf3f391", "36", "Operacoes e prestacoes nao escrituradas e dados necessarios ao ajuste dos valores declarados em Guia de Informacao e Apuracao do ICMS.", "Informar o valor das entradas de mercadorias ou aquisicoes de servicos nao escrituradas, provenientes de produtores rurais deste Estado nao equiparados a comerciantes ou a industriais." } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
