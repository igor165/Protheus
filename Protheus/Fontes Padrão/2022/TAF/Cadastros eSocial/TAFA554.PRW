#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA554
@type Function
@description Cadastro MVC Cadastro de Tipo de Valor de Apuração

@author Ricardo Lovrenovic
@since 04/02/2020
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA554()
Local oBrw as object

oBrw	:= FWmBrowse():New()

oBrw:SetDescription( "Tipo de Valor Apuração da Contribuição Devida" )  
oBrw:SetAlias( 'V5L')
oBrw:SetMenuDef( 'TAFA554' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
@type Static function
@description Funcao generica MVC com as opcoes de menu

@author Ricardo Lovrenovic
@since 04/02/2020
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA554" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
@type Static function
@description Funcao generica MVC do model

@author Ricardo Lovrenovic
@since 04/02/2020
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruV5L  as object 
Local oModel    as object

oStruV5L := FWFormStruct( 1, 'V5L' )// Cria a estrutura a ser usada no Modelo de Dados
oModel   := MPFormModel():New('TAFA554' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_V5L', /*cOwner*/, oStruV5L)
oModel:GetModel( 'MODEL_V5L' ):SetPrimaryKey( { 'V5L_FILIAL' , 'V5L_ID' } )

Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@type Static Function
@description Funcao generica MVC do View

@author Ricardo Lovrenovic
@since 04/02/2020
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel	as object
Local oStruV5L	as object
Local oView		as object

oModel		:= FWLoadModel( 'TAFA554' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
oStruV5L	:= FWFormStruct( 2, 'V5L' )// Cria a estrutura a ser usada na View
oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_V5L', oStruV5L, 'MODEL_V5L' )

oView:EnableTitleView( 'VIEW_V5L',  "Tipo de Valor Apuração da Contribuição Devida" ) //Cadastro de Códigos da Receita

oView:CreateHorizontalBox( 'FIELDSV5L', 100 )

oView:SetOwnerView( 'VIEW_V5L', 'FIELDSV5L' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

@type Static Function
@description Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Ricardo Lovrenovic Bueno
@Since		04/02/2020
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp as numeric, nVerAtu as numeric)
Local aHeader as array
Local aBody	  as array
Local aRet	  as array

aHeader	:=	{}
aBody	:=	{}
aRet	:=	{}

nVerAtu := 1030.00

If nVerEmp < nVerAtu
	aAdd( aHeader, "V5L_FILIAL" )
	aAdd( aHeader, "V5L_ID" )
	aAdd( aHeader, "V5L_CODIGO" )
	aAdd( aHeader, "V5L_DESCRI" )
	aAdd( aHeader, "V5L_VALIDA" )

	aAdd( aBody, { "", "000001", "11", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA NORMAL", "" } )
	aAdd( aBody, { "", "000002", "12", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 15 ANOS DE CONTRIBUIÇÃO", "" } )
	aAdd( aBody, { "", "000003", "13", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 20 ANOS DE CONTRIBUIÇÃO", "" } )
	aAdd( aBody, { "", "000004", "14", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 25 ANOS DE CONTRIBUIÇÃO", "" } )
	aAdd( aBody, { "", "000005", "15", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000006", "16", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 15 ANOS DE CONTRIBUIÇÃO - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000007", "17", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 20 ANOS DE CONTRIBUIÇÃO - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000008", "18", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA ADICIONAL PARA O FINANCIAMENTO DOS BENEFÍCIOS DE APOSENTADORIA ESPECIAL APÓS 25 ANOS DE CONTRIBUIÇÃO - EXCLUSIVA DO EMPREGADOR", "" } )
	aAdd( aBody, { "", "000009", "19", "BASE DE CÁLCULO DA CONTRIBUIÇÃO PREVIDENCIÁRIA EXCLUSIVA DO EMPREGADO", "" } )
	aAdd( aBody, { "", "000010", "21", "VALOR TOTAL DESCONTADO DO TRABALHADOR PARA RECOLHIMENTO À PREVIDÊNCIA SOCIAL", "" } )
	aAdd( aBody, { "", "000011", "22", "VALOR DESCONTADO DO TRABALHADOR PARA RECOLHIMENTO AO SEST", "" } )
	aAdd( aBody, { "", "000012", "23", "VALOR DESCONTADO DO TRABALHADOR PARA RECOLHIMENTO AO SENAT", "" } )
	aAdd( aBody, { "", "000013", "31", "VALOR PAGO AO TRABALHADOR A TÍTULO DE SALÁRIO-FAMÍLIA", "" } )
	aAdd( aBody, { "", "000014", "32", "VALOR PAGO AO TRABALHADOR A TÍTULO DE SALÁRIO-MATERNIDADE", "" } )

	aAdd( aRet, { aHeader, aBody } )
	

EndIf



Return( aRet )