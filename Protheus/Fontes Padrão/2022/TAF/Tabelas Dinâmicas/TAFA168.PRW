#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA168.CH"                                
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA168
Cadastro MVC - Cadastro de códigos das obrigações de ICMS a recolher

@author Mauro A. Goncalves
@since 30/07/12
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA168()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de códigos das obrigações de ICMS a recolher
oBrw:SetAlias( 'C3E')
oBrw:SetMenuDef( 'TAFA168' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 30/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA168" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 30/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC3E 	:= 	FWFormStruct( 1, 'C3E' )
Local oModel 	:= 	MPFormModel():New( 'TAFA168' )

oModel:AddFields('MODEL_C3E', /*cOwner*/, oStruC3E)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 30/07/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA168' )
Local 	oStruZAE 	:= 	FWFormStruct( 2, 'C3E' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C3E', oStruZAE, 'MODEL_C3E' )

oView:EnableTitleView( 'VIEW_C3E', STR0001 ) //Cadastro de códigos das obrigações de ICMS a recolher
oView:CreateHorizontalBox( 'FIELDSC3E', 100 )
oView:SetOwnerView( 'VIEW_C3E', 'FIELDSC3E' )

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

//Verifica se o dicionario aplicado é o da DIEF-CE e da Declan-RJ
If(AliasInDic("T30") .And. AliasInDic("T39"))
	nVerAtu := 1007
Else
	nVerAtu := 1003
EndIf

If nVerEmp < nVerAtu
	aAdd( aHeader, "C3E_FILIAL" )
	aAdd( aHeader, "C3E_ID" )
	aAdd( aHeader, "C3E_CODIGO" )
	aAdd( aHeader, "C3E_DESCRI" )
	aAdd( aHeader, "C3E_VALIDA" )

	aAdd( aBody, { "", "000001", "000", "ICMS A RECOLHER", "" } )
	aAdd( aBody, { "", "000002", "001", "ICMS DA SUBSTITUICAO TRIBUTARIA PELAS ENTRADAS", "" } )
	aAdd( aBody, { "", "000003", "002", "ICMS DA SUBSTITUICAO TRIBUTARIA PELAS SAIDAS PARA O ESTADO", "" } )
	aAdd( aBody, { "", "000004", "003", "ANTECIPACAO DO DIFERENCIAL DE ALIQUOTAS DO ICMS", "" } )
	aAdd( aBody, { "", "000005", "004", "ANTECIPACAO DO ICMS DA IMPORTACAO", "" } )
	aAdd( aBody, { "", "000006", "005", "ANTECIPACAO TRIBUTARIA", "" } )
	aAdd( aBody, { "", "000007", "006", "ICMS RESULTANTE DA ALIQUOTA ADICIONAL DOS ITENS INCLUIDOS NO FUNDO DE COMBATE A POBREZA", "" } )
	aAdd( aBody, { "", "000008", "090", "OUTRAS OBRIGACOES DO ICMS", "" } )
	aAdd( aBody, { "", "000009", "999", "ICMS DA SUBSTITUICAO TRIBUTARIA PELAS SAIDAS PARA OUTRO ESTADO", "" } )
	
	//Verifica se o dicionario aplicado é o da DIEF-CE e da Declan-RJ
	If(AliasInDic("T30") .And. AliasInDic("T39"))
		aAdd( aBody, { "", "000010", "007", "VALOR DO FECOP-ICMS-ST DAS SAÍDAS INTERNAS", "" } )
		aAdd( aBody, { "", "000011", "008", "VALOR DO FECOP-ICMS-ST DAS ENTRADAS INTERESTADUAIS", "" } )
		aAdd( aBody, { "", "000012", "009", "VALOR DO FECOP-ICMS-ST DAS ENTRADAS INTERNAS", "" } )
		aAdd( aBody, { "", "000013", "010", "VALOR DO ICMS ST NAS ENTRADAS A RECOLHER (CONTRIBUINTE CREDENCIADO)", "" } )
	EndIf

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )