#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA213.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA213
Cadastro MVC Grau de Exposição Agentes Nocivos

@author Leandro Prado
@since 07/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA213()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Grau de Exposicao a Agentes Nocivos
oBrw:SetAlias( 'C88')
oBrw:SetMenuDef( 'TAFA213' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 07/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA213" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 07/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC88 := FWFormStruct( 1, 'C88' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA213' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_C88', /*cOwner*/, oStruC88)
oModel:GetModel( 'MODEL_C88' ):SetPrimaryKey( { 'C88_FILIAL' , 'C88_ID' } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 07/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel( 'TAFA213' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruC88		:= FWFormStruct( 2, 'C88' )// Cria a estrutura a ser usada na View
Local oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C88', oStruC88, 'MODEL_C88' )

oView:EnableTitleView( 'VIEW_C88',  STR0001 ) //Cadastro de Grau de Exposicao a Agentes Nocivos

oView:CreateHorizontalBox( 'FIELDSC88', 100 )

oView:SetOwnerView( 'VIEW_C88', 'FIELDSC88' )

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

	nVerAtu := 1023.12


	aAdd( aHeader, "C88_FILIAL" )
	aAdd( aHeader, "C88_ID" )
	aAdd( aHeader, "C88_CODIGO" )
	aAdd( aHeader, "C88_DESCRI" )
	aAdd( aHeader, "C88_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "NAO EXPOSTO A AGENTE NOCIVO NA ATIVIDADE ATUAL", "20180220" } )
	aAdd( aBody, { "", "000002", "02", "EXPOSICAO A AGENTE NOCIVO – APOSENTADORIA ESPECIAL AOS 25 ANOS DE TRABALHO", "20180220" } )
	aAdd( aBody, { "", "000003", "03", "EXPOSICAO A AGENTE NOCIVO – APOSENTADORIA ESPECIAL AOS 20 ANOS DE TRABALHO", "20180220" } )
	aAdd( aBody, { "", "000004", "04", "EXPOSICAO A AGENTE NOCIVO – APOSENTADORIA ESPECIAL AOS 15 ANOS DE TRABALHO", "20180220" } )

	aAdd( aBody, { "", "000005", "1", "NÃO ENSEJADOR DE APOSENTADORIA ESPECIAL", "" } )
	aAdd( aBody, { "", "000006", "2", "ENSEJADOR DE APOSENTADORIA ESPECIAL - FAE15_12% (15 ANOS DE CONTRIBUIÇÃO E ALÍQUOTA DE 12%)", "" } )
	aAdd( aBody, { "", "000007", "3", "ENSEJADOR DE APOSENTADORIA ESPECIAL - FAE20_09% (20 ANOS DE CONTRIBUIÇÃO E ALÍQUOTA DE 9%)", "" } )
	aAdd( aBody, { "", "000008", "4", "ENSEJADOR DE APOSENTADORIA ESPECIAL - FAE25_06% (25 ANOS DE CONTRIBUIÇÃO E ALÍQUOTA DE 6%)", "" } )

	aAdd( aRet, { aHeader, aBody } )



Return( aRet )
