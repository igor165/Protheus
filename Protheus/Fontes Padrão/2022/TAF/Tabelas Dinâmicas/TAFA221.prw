#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA221.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA221
Cadastro MVC de Tipos de Lotação

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA221()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Tipos de Lotação
oBrw:SetAlias( 'C8F')
oBrw:SetMenuDef( 'TAFA221' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA221" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruC8F := FWFormStruct( 1, 'C8F' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA221' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_C8F', /*cOwner*/, oStruC8F)
oModel:GetModel( 'MODEL_C8F' ):SetPrimaryKey( { 'C8F_FILIAL' , 'C8F_ID' } )

Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 09/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel( 'TAFA221' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruC8F		:= FWFormStruct( 2, 'C8F' )// Cria a estrutura a ser usada na View
Local oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C8F', oStruC8F, 'MODEL_C8F' )

oView:EnableTitleView( 'VIEW_C8F',  STR0001 ) //Tipos de Lotação

oView:CreateHorizontalBox( 'FIELDSC8F', 100 )

oView:SetOwnerView( 'VIEW_C8F', 'FIELDSC8F' )

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

nVerAtu := 1013

If nVerEmp < nVerAtu
	aAdd( aHeader, "C8F_FILIAL" )
	aAdd( aHeader, "C8F_ID" )
	aAdd( aHeader, "C8F_CODIGO" )
	aAdd( aHeader, "C8F_DESCRI" )
	aAdd( aHeader, "C8F_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "CLASSIFICAÇÃO DA ATIVIDADE ECONÔMICA EXERCIDA PELA PESSOA JURÍDICA PARA FINS DE ATRIBUIÇÃO DE CÓDIGO FPAS, INCLUSIVE OBRAS DE CONSTRUÇÃO CIVIL PRÓPRIA", "" } )
	aAdd( aBody, { "", "000002", "02", "OBRA DE CONSTRUÇÃO CIVIL - EMPREITADA PARCIAL OU SUB-EMPREITADA ", "" } )
	aAdd( aBody, { "", "000003", "03", "PESSOA FÍSICA TOMADORA DE SERVIÇOS PRESTADOS MEDIANTE CESSÃO DE MÃO DE OBRA, EXCETO CONTRATANTE DE COOPERATIVA", "" } )
	aAdd( aBody, { "", "000004", "04", "PESSOA JURÍDICA TOMADORA DE SERVIÇOS PRESTADOS MEDIANTE CESSÃO DE MÃO DE OBRA, EXCETO CONTRATANTE DE COOPERATIVA, NOS TERMOS DA LEI 8.212/1991", "" } )
	aAdd( aBody, { "", "000005", "05", "PESSOA JURÍDICA TOMADORA DE SERVIÇOS PRESTADOS POR COOPERADOS POR INTERMÉDIO DE COOPERATIVA DE TRABALHO, EXCETO AQUELES PRESTADOS A ENTIDADE BENEFICENTE/ISENTA", "" } )
	aAdd( aBody, { "", "000006", "06", "ENTIDADE BENEFICENTE/ISENTA TOMADORA DE SERVIÇOS PRESTADOS POR COOPERADOS POR INTERMÉDIO DE COOPERATIVA DE TRABALHO", "" } )
	aAdd( aBody, { "", "000007", "07", "PESSOA FÍSICA TOMADORA DE SERVIÇOS PRESTADOS POR COOPERADOS POR INTERMÉDIO DE COOPERATIVA DE TRABALHO", "" } )
	aAdd( aBody, { "", "000008", "08", "OPERADOR PORTUÁRIO TOMADOR DE SERVIÇOS DE TRABALHADORES AVULSOS", "" } )
	aAdd( aBody, { "", "000009", "09", "CONTRATANTE DE TRABALHADORES AVULSOS NÃO PORTUÁRIOS POR INTERMÉDIO DE SINDICATO", "" } )
	aAdd( aBody, { "", "000010", "10", "EMBARCAÇÃO INSCRITA NO REGISTRO ESPECIAL BRASILEIRO - REB", "" } )
	aAdd( aBody, { "", "000011", "21", "CLASSIFICAÇÃO DA ATIVIDADE ECONÔMICA OU OBRA PRÓPRIA DE CONSTRUÇÃO CIVIL DA PESSOA FÍSICA", "" } )
	aAdd( aBody, { "", "000012", "24", "EMPREGADOR DOMÉSTICO", "" } )
	aAdd( aBody, { "", "000013", "90", "ATIVIDADES DESENVOLVIDAS NO EXTERIOR POR TRABALHADOR VINCULADO AO REGIME GERAL DE PREVIDÊNCIA SOCIAL (EXPATRIADOS)", "" } )
	aAdd( aBody, { "", "000014", "91", "ATIVIDADES DESENVOLVIDAS POR TRABALHADOR ESTRANGEIRO VINCULADO A REGIME DE PREVIDÊNCIA SOCIAL ESTRANGEIRO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
