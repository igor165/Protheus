#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA046.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA046
Cadastro MVC - Cadastro dos Códigos de Antecipação Tributária

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA046()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro dos Códigos de Antecipação Tributária
oBrw:SetAlias( 'C1Y')
oBrw:SetMenuDef( 'TAFA046' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA046" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC1Y 	:= 	FWFormStruct( 1, 'C1Y' )
Local oModel 	:= 	MPFormModel():New( 'TAFA046' )

oModel:AddFields('MODEL_C1Y', /*cOwner*/, oStruC1Y)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA046' )
Local 	oStruC1Y 	:= 	FWFormStruct( 2, 'C1Y' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C1Y', oStruC1Y, 'MODEL_C1Y' )

oView:EnableTitleView( 'VIEW_C1Y', STR0001 ) //Cadastro dos Códigos de Antecipação Tributária
oView:CreateHorizontalBox( 'FIELDSC1Y', 100 )
oView:SetOwnerView( 'VIEW_C1Y', 'FIELDSC1Y' )

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
	aAdd( aHeader, "C1Y_FILIAL" )
	aAdd( aHeader, "C1Y_ID" )
	aAdd( aHeader, "C1Y_CODIGO" )
	aAdd( aHeader, "C1Y_DESCRI" )
	aAdd( aHeader, "C1Y_VALIDA" )

	aAdd( aBody, { "", "000001", "0", "SUBSTITUICAO TRIBUTARIA INFORMADA PELO SUBSTITUTO OU PELO SUBSTITUIDO", "" } )
	aAdd( aBody, { "", "000002", "1", "PAGAMENTO DE SUBSTITUICAO EFETUADA PELO DESTINATARIO, QUANDO NAO EFETUADA OU EFETUADA  A MENOR PELO SUBSTITUTO", "" } )
	aAdd( aBody, { "", "000003", "2", "ANTECIPACAO TRIBUTARIA EFETUADA PELO DESTINATARIO APENAS COM COMPLEMENTACAO DO DIFERENCIAL DE ALIQUOTA", "" } )
	aAdd( aBody, { "", "000004", "3", "ANTECIPACAO TRIBUTARIA COM MVA (MARGEM DE VALOR AGREGADO), EFETUADA PELO DESTINATARIO SEM ENCERRAR A FASE DE TRIBUTACAO", "" } )
	aAdd( aBody, { "", "000005", "4", "ANTECIPACAO TRIBUTARIA COM MVA (MARGEM DE VALOR AGREGADO), EFETUADA PELO DESTINATARIO ENCERRANDO A FASE DE TRIBUTACAO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )