#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA247.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA247
Cadastro MVC de Tipo de Contribuição

@author Leandro Prado
@since 19/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA247()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Indicativo de Decisão 	
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

// Adiciona ao modelo um componente de formulário
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

oView:EnableTitleView( 'VIEW_C8S',  STR0001 ) //Cadastro de Indicativo de Decisão

oView:CreateHorizontalBox( 'FIELDSC8S', 100 )

oView:SetOwnerView( 'VIEW_C8S', 'FIELDSC8S' )

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
Local aBody		:=	{}
Local aRet		:=	{}

nVerAtu := 1013

If nVerEmp < nVerAtu
	aAdd( aHeader, "C8S_FILIAL" )
	aAdd( aHeader, "C8S_ID" )
	aAdd( aHeader, "C8S_CODIGO" )
	aAdd( aHeader, "C8S_DESCRI" )
	aAdd( aHeader, "C8S_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "LIMINAR EM MANDADO DE SEGURANÇA", "" } )
	aAdd( aBody, { "", "000002", "02", "DEPÓSITO JUDICIAL DO MONTANTE INTEGRAL", "" } )
	aAdd( aBody, { "", "000003", "03", "DEPÓSITO ADMINISTRATIVO DO MONTANTE INTEGRAL", "" } )
	aAdd( aBody, { "", "000004", "04", "ANTECIPAÇÃO DE TUTELA", "" } )
	aAdd( aBody, { "", "000005", "05", "LIMINAR EM MEDIDA CAUTELAR", "" } )
	aAdd( aBody, { "", "000006", "08", "SENTENÇA EM MANDADO DE SEGURANÇA FAVORÁVEL AO CONTRIBUINTE", "" } )
	aAdd( aBody, { "", "000007", "09", "SENTENÇA EM AÇÃO ORDINÁRIA FAVORÁVEL AO CONTRIBUINTE E CONFIRMADA PELO TRF", "" } )
	aAdd( aBody, { "", "000008", "10", "ACÓRDÃO DO TRF FAVORÁVEL AO CONTRIBUINTE", "" } )
	aAdd( aBody, { "", "000009", "11", "ACÓRDÃO DO STJ EM RECURSO ESPECIAL FAVORÁVEL AO CONTRIBUINTE", "" } )
	aAdd( aBody, { "", "000010", "12", "ACÓRDÃO DO STF EM RECURSO EXTRAORDINÁRIO FAVORÁVEL AO CONTRIBUINTE", "" } )
	aAdd( aBody, { "", "000011", "13", "SENTENÇA 1ª INSTÂNCIA NÃO TRANSITADA EM JULGADO COM EFEITO SUSPENSIVO", "" } )
	aAdd( aBody, { "", "000012", "14", "CONTESTAÇÃO ADMINISTRATIVA FAP", "" } )
	aAdd( aBody, { "", "000013", "90", "DECISÃO DEFINITIVA A FAVOR DO CONTRIBUINTE (TRANSITADA EM JULGADO)", "" } )
	aAdd( aBody, { "", "000014", "91", "SOLUÇÃO DE CONSULTA INTERNA DA RFB", "" } )
	aAdd( aBody, { "", "000015", "92", "SEM SUSPENSÃO DA EXIGIBILIDADE", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )