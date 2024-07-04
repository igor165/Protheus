#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA315.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA315
Cadastro MVC Cor do Veículo - Tabela Renavan

@author Evandro dos Santos Oliveira
@since 24/03/2014
@version 1.0   

@Return - Nil
/*/
//-------------------------------------------------------------------
Function TAFA315()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Cor do Veículo - Tabela Renavan
oBrw:SetAlias( 'CAL')
oBrw:SetMenuDef( 'TAFA315' )
oBrw:Activate()

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Evandro dos Santos Oliveira
@since 24/03/2014
@version 1.0

@Return 
XFUNMnuTAF - Funcão com Menu Padrão para o módulo TAF
/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA315" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Evandro dos Santos Oliveira
@since 24/03/2014
@version 1.0

@Return 
oModel - Model da tabela/programa
/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruCAL := FWFormStruct( 1, 'CAL' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA315' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_CAL', /*cOwner*/, oStruCAL)
oModel:GetModel( 'MODEL_CAL' ):SetPrimaryKey( { 'CAL_FILIAL' , 'CAL_ID' } )

Return (oModel)            


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Evandro dos Santos Oliveira
@since 24/03/2014
@version 1.0
 
@Return 
oView -  View da Tabela/Programa
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel( 'TAFA315' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruCAL		:= FWFormStruct( 2, 'CAL' )// Cria a estrutura a ser usada na View
Local oView			:= FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CAL', oStruCAL, 'MODEL_CAL' )
oView:EnableTitleView( 'VIEW_CAL',  STR0001 ) //Cadastro de Cor do Veículo - Tabela Renavan
oView:CreateHorizontalBox( 'FIELDSCAL', 100 )
oView:SetOwnerView( 'VIEW_CAL', 'FIELDSCAL' )

Return (oView) 

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

nVerAtu := 1006

If nVerEmp < nVerAtu
	aAdd( aHeader, "CAL_FILIAL" )
	aAdd( aHeader, "CAL_ID" )
	aAdd( aHeader, "CAL_CODIGO" )
	aAdd( aHeader, "CAL_DESCRI" )
	aAdd( aHeader, "CAL_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "AMARELA", "" } )
	aAdd( aBody, { "", "000002", "02", "AZUL", "" } )
	aAdd( aBody, { "", "000003", "03", "BEGE", "" } )
	aAdd( aBody, { "", "000004", "04", "BRANCA", "" } )
	aAdd( aBody, { "", "000005", "05", "CINZA", "" } )
	aAdd( aBody, { "", "000006", "06", "GRENA", "" } )
	aAdd( aBody, { "", "000007", "07", "COLECAO", "" } )
	aAdd( aBody, { "", "000008", "08", "LARANJA", "" } )
	aAdd( aBody, { "", "000009", "09", "MARROM", "" } )
	aAdd( aBody, { "", "000010", "10", "PRATA", "" } )
	aAdd( aBody, { "", "000011", "11", "PRETA", "" } )
	aAdd( aBody, { "", "000012", "12", "ROSA", "" } )
	aAdd( aBody, { "", "000013", "13", "ROXA", "" } )
	aAdd( aBody, { "", "000014", "14", "VERDE", "" } )
	aAdd( aBody, { "", "000015", "15", "VERMELHA", "" } )
	aAdd( aBody, { "", "000016", "16", "FANTASIA", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )