#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA080.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA080
Cadastro MVC de Cadastro de Codigos de Tributos 


@author Danilo L Zanaga
@since 09/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA080()

Local oBrw	as object

oBrw	:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro de Codigos de Tributos 
oBrw:SetAlias( 'C3S')
oBrw:SetMenuDef( 'TAFA080' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Danilo L Zanaga
@since 09/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return xFunMnuTAF( "TAFA080" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Danilo L Zanaga
@since 09/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruC3S	as object
Local oModel		as object

oStruC3S	:=	FWFormStruct( 1, "C3S" )
oModel		:=	MPFormModel():New( "TAFA080" )

oModel:AddFields('MODEL_C3S', /*cOwner*/, oStruC3S)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Danilo L Zanaga
@since 09/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		as object
Local oStruC3S	as object
Local oView		as object

oModel		:=	FWLoadModel( "TAFA080" )
oStruC3S	:=	FWFormStruct( 2, "C3S" )
oView		:=	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C3S', oStruC3S, 'MODEL_C3S' )

oView:EnableTitleView( 'VIEW_C3S', STR0001 ) //Cadastro de Codigos de Tributos
oView:CreateHorizontalBox( 'FIELDSC3S', 100 )
oView:SetOwnerView( 'VIEW_C3S', 'FIELDSC3S' )

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

Local aHeader	as array
Local aBody		as array
Local aRet		as array

aHeader	:=	{}
aBody		:=	{}
aRet		:=	{}

nVerAtu := 1029.20

If nVerEmp < nVerAtu
	aAdd( aHeader, "C3S_FILIAL" )
	aAdd( aHeader, "C3S_ID" )
	aAdd( aHeader, "C3S_CODIGO" )
	aAdd( aHeader, "C3S_DESCRI" )

	aAdd( aBody, { "", "000001", "01", "ISSQN (IMPOSTO SOBRE SERVICOS DE QUALQUER NATUREZA)" } )
	aAdd( aBody, { "", "000002", "02", "ICMS (IMPOSTO SOBRE A CIRCULACAO DE MERCADORIAS E SERVICOS)" } )
	aAdd( aBody, { "", "000003", "03", "ICMS COMPLEMENTAR (IMPOSTO SOBRE A CIRCULACAO DE MERCADORIAS E SERVICOS - COMPLEMENTAR)" } )
	aAdd( aBody, { "", "000004", "04", "ICMS/ST (IMPOSTO SOBRE A CIRCULACAO DE MERCADORIAS E SERVICOS - SUBSTITUICAO TRIBUTARIA)" } )
	aAdd( aBody, { "", "000005", "05", "IPI (IMPOSTO SOBRE PRODUTOS INDUSTRIALIZADOS)" } )
	aAdd( aBody, { "", "000006", "06", "PIS/PASEP (PROGRAMA DE INTEGRACAO SOCIAL - PROGRAMA DE FORMACAO DO PATRIMONIO DO SERVIDOR PUBLICO)" } )
	aAdd( aBody, { "", "000007", "07", "COFINS (CONTRIBUICAO PARA O FINANCIAMENTO DA SEGURIDADE SOCIAL)" } )
	aAdd( aBody, { "", "000008", "08", "PIS/PASEP ST (PROGRAMA DE INTEGRACAO SOCIAL - PROGRAMA DE FORMACAO DO PATRIMONIO DO SERVIDOR PUBLICO - SUBSTITUICAO TRIBUTARIA)" } )
	aAdd( aBody, { "", "000009", "09", "COFINS ST (CONTRIBUICAO PARA O FINANCIAMENTO DA SEGURIDADE SOCIAL - SUBSTITUICAO TRIBUTARIA)" } )
	aAdd( aBody, { "", "000010", "10", "PIS/PASEP RETENCAO (PROGRAMA DE INTEGRACAO SOCIAL - PROGRAMA DE FORMACAO DO PATRIMONIO DO SERVIDOR PUBLICO - RETENCAO)" } )
	aAdd( aBody, { "", "000011", "11", "COFINS RETENCAO (CONTRIBUICAO PARA O FINANCIAMENTO DA SEGURIDADE SOCIAL - RETENCAO)" } )
	aAdd( aBody, { "", "000012", "12", "IR (IMPOSTO DE RENDA EMISSÃO)" } )
	aAdd( aBody, { "", "000013", "13", "PREVIDENCIA" } )
	aAdd( aBody, { "", "000014", "14", "PIS/PASEP IMPORTACAO (PROGRAMA DE INTEGRACAO SOCIAL - PROGRAMA DE FORMACAO DO PATRIMONIO DO SERVIDOR PUBLICO - IMPORTACAO)" } )
	aAdd( aBody, { "", "000015", "15", "COFINS IMPORTACAO (CONTRIBUICAO PARA O FINANCIAMENTO DA SEGURIDADE SOCIAL - IMPORTACAO)" } )
	aAdd( aBody, { "", "000016", "16", "ISSQN RETIDO (IMPOSTO SOBRE SERVICOS DE QUALQUER NATUREZA)" } )
	aAdd( aBody, { "", "000017", "17", "ICMS ANTECIPADO (IMPOSTO SOBRE CIRCULACAO DE MERCADORIAS E SERVICOS - ANTECIPADO)" } )
	aAdd( aBody, { "", "000018", "18", "CSLL (CONTRIBUICAO SOCIAL SOBRE O LUCRO LIQUIDO)" } )
	aAdd( aBody, { "", "000019", "19", "IRPJ (IMPOSTO SOBRE A RENDA DE PESSOA JURIDICA)" } )
	aAdd( aBody, { "", "000020", "20", "ICMS COMPLEMENTAR (DIFAL) - UD DE ORIGEM - OPERAÇÃO INTERESTADUAL DESTINADA A NAO CONTRIBUINTE" } )
	aAdd( aBody, { "", "000021", "21", "ICMS COMPLEMENTAR (DIFAL) - UF DE DESTINO - OPERACAO INTERESTADUAL DESTINADA A NAO CONTRIBUINTE" } )
	aAdd( aBody, { "", "000022", "22", "FCP - UF DE DESTINO - OPERACAO INTERESTADUAL DESTINADA A NAO CONTRIBUINTE" } )
	aAdd( aBody, { "", "000023", "23", "CPRB (IMPOSTO SOBRE SERVICOS DE QUALQUER NATUREZA)" } )
	aAdd( aBody, { "", "000024", "24", "GILRAT (GRAU DE INCIDÊNCIA DE INCAPACIDADE LABORATIVA DECORRENTE DOS RISCOS AMBIENTAIS DO TRABALHO)" } )
	aAdd( aBody, { "", "000025", "25", "SENAR" } )
	aAdd( aBody, { "", "000026", "26", "ICMS/ST (IMPOSTO SOBRE A CIRCULACAO DE MERCADORIAS E SERVICOS - ICMS SUBSTITUIDO)" } )
	aAdd( aBody, { "", "000027", "27", "CSLL RETENCAO (CONTRIBUICAO SOCIAL SOBRE O LUCRO LIQUIDO - RETENCAO)" } )
	aAdd( aBody, { "", "000028", "28", "IR (IMPOSTO DE RENDA PAGAMENTO)" } )
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )