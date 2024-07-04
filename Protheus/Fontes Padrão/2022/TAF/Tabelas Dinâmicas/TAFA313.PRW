#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA313.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA313
Cadastro MVC Tipo de Veiculo

@author Evandro dos Santos Oliveira
@since 24/03/2014
@version 1.0   

@Return - Nil
/*/
//-------------------------------------------------------------------
Function TAFA313()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Tipo de Veiculo	
oBrw:SetAlias( 'CAJ')
oBrw:SetMenuDef( 'TAFA313' )
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
Return XFUNMnuTAF( "TAFA313" )                                                                          

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
Local oStruCAJ := FWFormStruct( 1, 'CAJ' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA313' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_CAJ', /*cOwner*/, oStruCAJ)
oModel:GetModel( 'MODEL_CAJ' ):SetPrimaryKey( { 'CAJ_FILIAL' , 'CAJ_ID' } )

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
Local oModel		:= FWLoadModel( 'TAFA313' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruCAJ		:= FWFormStruct( 2, 'CAJ' )// Cria a estrutura a ser usada na View
Local oView			:= FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CAJ', oStruCAJ, 'MODEL_CAJ' )
oView:EnableTitleView( 'VIEW_CAJ',  STR0001 ) //Cadastro de Tipo de Veiculo
oView:CreateHorizontalBox( 'FIELDSCAJ', 100 )
oView:SetOwnerView( 'VIEW_CAJ', 'FIELDSCAJ' )

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
	aAdd( aHeader, "CAJ_FILIAL" )
	aAdd( aHeader, "CAJ_ID" )
	aAdd( aHeader, "CAJ_CODIGO" )
	aAdd( aHeader, "CAJ_DESCRI" )
	aAdd( aHeader, "CAJ_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "BICICLETA", "" } )
	aAdd( aBody, { "", "000002", "02", "CICLOMOTOR", "" } )
	aAdd( aBody, { "", "000003", "03", "MOTONETA", "" } )
	aAdd( aBody, { "", "000004", "04", "MOTOCICLETA", "" } )
	aAdd( aBody, { "", "000005", "05", "TRICICLO", "" } )
	aAdd( aBody, { "", "000006", "06", "AUTOMOVEL", "" } )
	aAdd( aBody, { "", "000007", "07", "MICROONIBUS", "" } )
	aAdd( aBody, { "", "000008", "08", "ONIBUS", "" } )
	aAdd( aBody, { "", "000009", "09", "BONDE", "" } )
	aAdd( aBody, { "", "000010", "10", "REBOQUE", "" } )
	aAdd( aBody, { "", "000011", "11", "SEMI-REBOQUE", "" } )
	aAdd( aBody, { "", "000012", "12", "CHARRETE", "" } )
	aAdd( aBody, { "", "000013", "13", "CAMIONETA", "" } )
	aAdd( aBody, { "", "000014", "14", "CAMINHAO", "" } )
	aAdd( aBody, { "", "000015", "15", "CARROCA", "" } )
	aAdd( aBody, { "", "000016", "16", "CARRO DE MAO", "" } )
	aAdd( aBody, { "", "000017", "17", "CAMINHAO TRATOR", "" } )
	aAdd( aBody, { "", "000018", "18", "TRATOR DE RODAS", "" } )
	aAdd( aBody, { "", "000019", "19", "TRATOR DE ESTEIRAS", "" } )
	aAdd( aBody, { "", "000020", "20", "TRATOR MISTO", "" } )
	aAdd( aBody, { "", "000021", "21", "QUADRICICLO", "" } )
	aAdd( aBody, { "", "000022", "22", "CHASSI/PLATAFORMA", "" } )
	aAdd( aBody, { "", "000023", "23", "CAMINHONETE", "" } )
	aAdd( aBody, { "", "000024", "24", "SIDE-CAR", "" } )
	aAdd( aBody, { "", "000025", "25", "UTILITARIO", "" } )
	aAdd( aBody, { "", "000026", "26", "MOTOR-CASA", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )