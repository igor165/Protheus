#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA318.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA318
Cadastro MVC Tipo de Combustível

@author Evandro dos Santos Oliveira
@since 24/03/2014
@version 1.0   

@Return - Nil
/*/
//-------------------------------------------------------------------
Function TAFA318()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Tipo de Combustível
oBrw:SetAlias( 'CAX')
oBrw:SetMenuDef( 'TAFA318' )
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
Return XFUNMnuTAF( "TAFA318" )                                                                          

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
Local oStruCAX := FWFormStruct( 1, 'CAX' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA318' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_CAX', /*cOwner*/, oStruCAX)
oModel:GetModel( 'MODEL_CAX' ):SetPrimaryKey( { 'CAX_FILIAL' , 'CAX_ID' } )

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
Local oModel		:= FWLoadModel( 'TAFA318' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruCAX		:= FWFormStruct( 2, 'CAX' )// Cria a estrutura a ser usada na View
Local oView			:= FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CAX', oStruCAX, 'MODEL_CAX' )
oView:EnableTitleView( 'VIEW_CAX',  STR0001 ) //Cadastro de Tipo de Combustível
oView:CreateHorizontalBox( 'FIELDSCAX', 100 )
oView:SetOwnerView( 'VIEW_CAX', 'FIELDSCAX' )

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

nVerAtu := 1008.01

If nVerEmp < nVerAtu
	aAdd( aHeader, "CAX_FILIAL" )
	aAdd( aHeader, "CAX_ID" )
	aAdd( aHeader, "CAX_CODIGO" )
	aAdd( aHeader, "CAX_DESCRI" )
	aAdd( aHeader, "CAX_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "ALCOOL", "" } )
	aAdd( aBody, { "", "000002", "02", "GASOLINA", "" } )
	aAdd( aBody, { "", "000003", "03", "DIESEL", "" } )
	aAdd( aBody, { "", "000004", "04", "GASOGENIO", "" } )
	aAdd( aBody, { "", "000005", "05", "GAS METANO", "" } )
	aAdd( aBody, { "", "000006", "06", "ELETRICO/FONTE INTERNA", "" } )
	aAdd( aBody, { "", "000007", "07", "ELETRICO/FONTE EXTERNA", "" } )
	aAdd( aBody, { "", "000008", "08", "GASOL/GAS NATURAL COMBUSTIVEL", "" } )
	aAdd( aBody, { "", "000009", "09", "ALCOOL/GAS NATURAL COMBUSTIVEL", "" } )
	aAdd( aBody, { "", "000010", "10", "DIESEL/GAS NATURAL COMBUSTIVEL", "" } )
	aAdd( aBody, { "", "000011", "11", "VIDE/CAMPO/OBSERVACAO", "" } )
	aAdd( aBody, { "", "000012", "12", "ALCOOL/GAS NATURAL VEICULAR", "" } )
	aAdd( aBody, { "", "000013", "13", "GASOLINA/GAS NATURAL VEICULAR", "" } )
	aAdd( aBody, { "", "000014", "14", "DIESEL/GAS NATURAL VEICULAR", "" } )
	aAdd( aBody, { "", "000015", "15", "GAS NATURAL VEICULAR", "" } )
	aAdd( aBody, { "", "000016", "16", "ALCOOL/GASOLINA", "" } )
	aAdd( aBody, { "", "000017", "17", "GASOLINA/ALCOOL/GAS NATURAL", "" } )
	aAdd( aBody, { "", "000018", "18", "GASOLINA/ELETRICO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )