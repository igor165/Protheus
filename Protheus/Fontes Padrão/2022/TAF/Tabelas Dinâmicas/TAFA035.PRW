#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA035.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA035
Cadastro de Códigos de Base de Cálculo para Crédito

@author Marcio Nunes
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA035()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Códigos de Base de Cálculo para Crédito
oBrw:SetAlias( 'C11')
oBrw:SetMenuDef( 'TAFA035' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 05/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA035" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC11 	:= 	FWFormStruct( 1, 'C11' )
Local oModel 	:= 	MPFormModel():New( 'TAFA035' )

oModel:AddFields('MODEL_C11', /*cOwner*/, oStruC11)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 11/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA035' )
Local 	oStruC11 	:= 	FWFormStruct( 2, 'C11' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C11', oStruC11, 'MODEL_C11' )

oView:EnableTitleView( 'VIEW_C11', STR0001 ) //Cadastro de Códigos de Base de Cálculo para Crédito
oView:CreateHorizontalBox( 'FIELDSC11', 100 )
oView:SetOwnerView( 'VIEW_C11', 'FIELDSC11' )

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

nVerAtu := 1003

If nVerEmp < nVerAtu
	aAdd( aHeader, "C11_FILIAL" )
	aAdd( aHeader, "C11_ID" )
	aAdd( aHeader, "C11_CODIGO" )
	aAdd( aHeader, "C11_DESCRI" )
	aAdd( aHeader, "C11_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "AQUISICAO DE BENS PARA REVENDA", "" } )
	aAdd( aBody, { "", "000002", "02", "AQUISICAO DE BENS UTILIZADOS COMO INSUMO", "" } )
	aAdd( aBody, { "", "000003", "03", "AQUISICAO DE SERVICOS UTILIZADOS COMO INSUMO", "" } )
	aAdd( aBody, { "", "000004", "04", "ENERGIA ELETRICA E TERMICA, INCLUSIVE SOB A FORMA DE VAPOR", "" } )
	aAdd( aBody, { "", "000005", "05", "ALUGUEIS DE PREDIOS", "" } )
	aAdd( aBody, { "", "000006", "06", "ALUGUEIS DE MAQUINAS E EQUIPAMENTOS", "" } )
	aAdd( aBody, { "", "000007", "07", "ARMAZENAGEM DE MERCADORIA E FRETE NA OPERACAO DE VENDA", "" } )
	aAdd( aBody, { "", "000008", "08", "CONTRAPRESTACAES DE ARRENDAMENTO MERCANTIL", "" } )
	aAdd( aBody, { "", "000009", "09", "MAQUINAS, EQUIPAMENTOS E OUTROS BENS INCORPORADOS AO ATIVO IMOBILIZADO (CREDITO SOBRE ENCARGOS DE DEPRECIACAO).", "" } )
	aAdd( aBody, { "", "000010", "10", "MAQUINAS, EQUIPAMENTOS E OUTROS BENS INCORPORADOS AO ATIVO IMOBILIZADO (CREDITO COM BASE NO VALOR DE AQUISICAO).", "" } )
	aAdd( aBody, { "", "000011", "11", "AMORTIZACAO E DEPRECIACAO DE EDIFICACAES E BENFEITORIAS EM IM.VEIS", "" } )
	aAdd( aBody, { "", "000012", "12", "DEVOLUCAO DE VENDAS SUJEITAS . INCIDENCIA NAO-CUMULATIVA", "" } )
	aAdd( aBody, { "", "000013", "13", "OUTRAS OPERACAES COM DIREITO A CREDITO", "" } )
	aAdd( aBody, { "", "000014", "14", "ATIVIDADE DE TRANSPORTE DE CARGAS ? SUBCONTRATACAO", "" } )
	aAdd( aBody, { "", "000015", "15", "ATIVIDADE IMOBILIARIA ? CUSTO INCORRIDO DE UNIDADE IMOBILIARIA", "" } )
	aAdd( aBody, { "", "000016", "16", "ATIVIDADE IMOBILIARIA ? CUSTO ORCADO DE UNIDADE NAO CONCLUIDA", "" } )
	aAdd( aBody, { "", "000017", "17", "ATIVIDADE DE PRESTACAO DE SERVICOS DE LIMPEZA, CONSERVACAO E MANUTENCAO ? VALE-TRANSPORTE, VALE-REFEICAO OU VALE-ALIMENTACAO, FARDAMENTO OU UNIFORME.", "" } )
	aAdd( aBody, { "", "000018", "18", "ESTOQUE DE ABERTURA DE BENS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )