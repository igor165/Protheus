#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA247.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA247
Cadastro MVC de Tipo de Contribui��o

@author Leandro Prado
@since 19/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA247()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Indicativo de Decis�o 	
oBrw:SetAlias( 'C8S')
oBrw:SetMenuDef( 'TAFA247' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 19/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA247" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 19/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruC8S := FWFormStruct( 1, 'C8S' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA247' )

// Adiciona ao modelo um componente de formul�rio
oModel:AddFields( 'MODEL_C8S', /*cOwner*/, oStruC8S)
oModel:GetModel( 'MODEL_C8S' ):SetPrimaryKey( { 'C8S_FILIAL' , 'C8S_ID' } )

Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 19/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel( 'TAFA247' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruC8S		:= FWFormStruct( 2, 'C8S' )// Cria a estrutura a ser usada na View
Local oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C8S', oStruC8S, 'MODEL_C8S' )

oView:EnableTitleView( 'VIEW_C8S',  STR0001 ) //Cadastro de Indicativo de Decis�o

oView:CreateHorizontalBox( 'FIELDSC8S', 100 )

oView:SetOwnerView( 'VIEW_C8S', 'FIELDSC8S' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody		:=	{}
Local aRet		:=	{}

nVerAtu := 1013

If nVerEmp < nVerAtu
	aAdd( aHeader, "C8S_FILIAL" )
	aAdd( aHeader, "C8S_ID" )
	aAdd( aHeader, "C8S_CODIGO" )
	aAdd( aHeader, "C8S_DESCRI" )
	aAdd( aHeader, "C8S_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "LIMINAR EM MANDADO DE SEGURAN�A", "" } )
	aAdd( aBody, { "", "000002", "02", "DEP�SITO JUDICIAL DO MONTANTE INTEGRAL", "" } )
	aAdd( aBody, { "", "000003", "03", "DEP�SITO ADMINISTRATIVO DO MONTANTE INTEGRAL", "" } )
	aAdd( aBody, { "", "000004", "04", "ANTECIPA��O DE TUTELA", "" } )
	aAdd( aBody, { "", "000005", "05", "LIMINAR EM MEDIDA CAUTELAR", "" } )
	aAdd( aBody, { "", "000006", "08", "SENTEN�A EM MANDADO DE SEGURAN�A FAVOR�VEL AO CONTRIBUINTE", "" } )
	aAdd( aBody, { "", "000007", "09", "SENTEN�A EM A��O ORDIN�RIA FAVOR�VEL AO CONTRIBUINTE E CONFIRMADA PELO TRF", "" } )
	aAdd( aBody, { "", "000008", "10", "AC�RD�O DO TRF FAVOR�VEL AO CONTRIBUINTE", "" } )
	aAdd( aBody, { "", "000009", "11", "AC�RD�O DO STJ EM RECURSO ESPECIAL FAVOR�VEL AO CONTRIBUINTE", "" } )
	aAdd( aBody, { "", "000010", "12", "AC�RD�O DO STF EM RECURSO EXTRAORDIN�RIO FAVOR�VEL AO CONTRIBUINTE", "" } )
	aAdd( aBody, { "", "000011", "13", "SENTEN�A 1� INST�NCIA N�O TRANSITADA EM JULGADO COM EFEITO SUSPENSIVO", "" } )
	aAdd( aBody, { "", "000012", "14", "CONTESTA��O ADMINISTRATIVA FAP", "" } )
	aAdd( aBody, { "", "000013", "90", "DECIS�O DEFINITIVA A FAVOR DO CONTRIBUINTE (TRANSITADA EM JULGADO)", "" } )
	aAdd( aBody, { "", "000014", "91", "SOLU��O DE CONSULTA INTERNA DA RFB", "" } )
	aAdd( aBody, { "", "000015", "92", "SEM SUSPENS�O DA EXIGIBILIDADE", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )