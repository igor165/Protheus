#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA219.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA219
Cadastro MVC de Classificação Tributária 

@author Anderson Costa
@since 07/08/2013
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA219()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Cadastro da Classificação Tributária"
oBrw:SetAlias( 'C8D')
oBrw:SetMenuDef( 'TAFA219' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 07/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA219" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 07/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC8D  :=  FWFormStruct( 1, 'C8D' )
Local oModel    :=  MPFormModel():New( 'TAFA219' )

oModel:AddFields('MODEL_C8D', /*cOwner*/, oStruC8D)
oModel:GetModel('MODEL_C8D'):SetPrimaryKey({'C8D_FILIAL', 'C8D_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 07/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA219' )
Local   oStruC8D    :=  FWFormStruct( 2, 'C8D' )
Local   oView       :=  FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C8D', oStruC8D, 'MODEL_C8D' )

oView:EnableTitleView( 'VIEW_C8D', STR0001 )    //"Cadastro da Classificação Tributária"
oView:CreateHorizontalBox( 'FIELDSC8D', 100 )
oView:SetOwnerView( 'VIEW_C8D', 'FIELDSC8D' )

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

nVerAtu := 1031.18

If nVerEmp < nVerAtu
	aAdd( aHeader, "C8D_FILIAL" )
	aAdd( aHeader, "C8D_ID" )
	aAdd( aHeader, "C8D_CODIGO" )
	aAdd( aHeader, "C8D_DESCRI" )
	aAdd( aHeader, "C8D_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "EMPRESA ENQUADRADA NO REGIME DE TRIBUTACAO SIMPLES NACIONAL COM TRIBUTACAO PREVIDENCIARIA SUBSTITUIDA", "" } )
	aAdd( aBody, { "", "000002", "02", "EMPRESA ENQUADRADA NO REGIME DE TRIBUTACAO SIMPLES NACIONAL COM TRIBUTACAO PREVIDENCIARIA NÃO SUBSTITUIDA", "" } )
	aAdd( aBody, { "", "000003", "03", "EMPRESA ENQUADRADA NO REGIME DE TRIBUTACAO SIMPLES NACIONAL COM TRIBUTACAO PREVIDENCIARIA SUBSTITUIDA E NÃO SUBSTITUIDA", "" } )
	aAdd( aBody, { "", "000004", "04", "MEI - MICRO EMPREENDEDOR INDIVIDUAL", "" } )
	aAdd( aBody, { "", "000005", "06", "AGROINDÚSTRIA", "" } )
	aAdd( aBody, { "", "000006", "07", "PRODUTOR RURAL PESSOA JURIDICA", "" } )
	aAdd( aBody, { "", "000007", "08", "CONSÓRCIO SIMPLIFICADO DE PRODUTORES RURAIS", "20201123" } )
	aAdd( aBody, { "", "000008", "09", "ORGÃO GESTOR DE MÃO DE OBRA", "" } )
	aAdd( aBody, { "", "000009", "10", "ENTIDADE SINDICAL A QUE SE REFERE A LEI 12.023/2009", "" } )
	aAdd( aBody, { "", "000010", "11", "ASSOCIACAO DESPORTIVA QUE MANTEM CLUBE DE FUTEBOL PROFISSIONAL", "" } )
	aAdd( aBody, { "", "000011", "13", "BANCO, CAIXA ECONÔMICA, SOCIEDADE DE CRÉDITO, FINANCIAMENTO E INVESTIMENTO E DEMAIS EMPRESAS RELACIONADAS NO PARÁGRAFO 1º DO ART. 22 DA LEI 8.212./91", "" } )
	aAdd( aBody, { "", "000012", "14", "SINDICATOS EM GERAL, EXCETO AQUELE CLASSIFICADO NO CODIGO [10]", "" } )
	aAdd( aBody, { "", "000013", "21", "PESSOA FISICA, EXCETO SEGURADO ESPECIAL", "" } )
	aAdd( aBody, { "", "000014", "22", "SEGURADO ESPECIAL, INCLUSIVE QUANDO FOR EMPREGADOR DOMÉSTICO", "" } )
	aAdd( aBody, { "", "000015", "60", "MISSAO DIPLOMATICA OU REPARTICAO CONSULAR DE CARREIRA ESTRANGEIRA", "" } )
	aAdd( aBody, { "", "000016", "70", "EMPRESA DE QUE TRATA O DECRETO 5.436/2005", "" } )
	aAdd( aBody, { "", "000017", "80", "ENTIDADE BENEFICIENTE DE ASSISTÊNCIA SOCIAL ISENTA DE CONTRIBUIÇÕES SOCIAIS", "" } )
	aAdd( aBody, { "", "000018", "85", "ADMINISTRAÇÃO DIRETA DA UNIÃO, ESTADOS, DISTRITO FEDERAL E MUNICÍPÍOS; AUTARQUIAS E FUNDAÇÕES PÚBLICAS", "" } ) // LAYOUT 2.4.02
	aAdd( aBody, { "", "000019", "99", "PESSOAS JURIDICAS EM GERAL", "" } )

	aAdd( aRet, { aHeader, aBody } )

EndIf

Return( aRet )
