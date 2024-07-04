#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA314.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA314
Cadastro MVC Espécie de Veículo

@author Evandro dos Santos Oliveira
@since 24/03/2014
@version 1.0   

@Return - Nil
/*/
//-------------------------------------------------------------------
Function TAFA314()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Espécie de Veículo
oBrw:SetAlias( 'CAK')
oBrw:SetMenuDef( 'TAFA314' )
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
Return XFUNMnuTAF( "TAFA314" )                                                                          

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
Local oStruCAK := FWFormStruct( 1, 'CAK' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA314' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_CAK', /*cOwner*/, oStruCAK)
oModel:GetModel( 'MODEL_CAK' ):SetPrimaryKey( { 'CAK_FILIAL' , 'CAK_ID' } )

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
Local oModel		:= FWLoadModel( 'TAFA314' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruCAK		:= FWFormStruct( 2, 'CAK' )// Cria a estrutura a ser usada na View
Local oView			:= FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CAK', oStruCAK, 'MODEL_CAK' )
oView:EnableTitleView( 'VIEW_CAK',  STR0001 ) //Cadastro de Espécie de Veículo
oView:CreateHorizontalBox( 'FIELDSCAK', 100 )
oView:SetOwnerView( 'VIEW_CAK', 'FIELDSCAK' )

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
	aAdd( aHeader, "CAK_FILIAL" )
	aAdd( aHeader, "CAK_ID" )
	aAdd( aHeader, "CAK_CODIGO" )
	aAdd( aHeader, "CAK_DESCRI" )
	aAdd( aHeader, "CAK_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "PASSAGEIRO", "" } )
	aAdd( aBody, { "", "000002", "02", "CARGA", "" } )
	aAdd( aBody, { "", "000003", "03", "MISTO", "" } )
	aAdd( aBody, { "", "000004", "04", "CORRIDA", "" } )
	aAdd( aBody, { "", "000005", "05", "TRACAO", "" } )
	aAdd( aBody, { "", "000006", "06", "ESPECIAL", "" } )
	aAdd( aBody, { "", "000007", "07", "COLECAO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )