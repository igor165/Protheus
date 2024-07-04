#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA044.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA044
Cadastro de Indicador da Natureza da Ação Judicial impetrada na Justiça Federal

@author Marcio Nunes
@since 16/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA044()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Indicador da Natureza da Ação Judicial impetrada na Justiça Federal
oBrw:SetAlias( 'C18')
oBrw:SetMenuDef( 'TAFA044' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA044" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC18 	:= 	FWFormStruct( 1, 'C18' )
Local oModel 	:= 	MPFormModel():New( 'TAFA044' )

oModel:AddFields('MODEL_C18', /*cOwner*/, oStruC18)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA044' )
Local 	oStruC18 	:= 	FWFormStruct( 2, 'C18' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C18', oStruC18, 'MODEL_C18' )

oView:EnableTitleView( 'VIEW_C18', STR0001 ) //Cadastro de Indicador da Natureza da Ação Judicial impetrada na Justiça Federal
oView:CreateHorizontalBox( 'FIELDSC18', 100 )
oView:SetOwnerView( 'VIEW_C18', 'FIELDSC18' )

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
	aAdd( aHeader, "C18_FILIAL" )
	aAdd( aHeader, "C18_ID" )
	aAdd( aHeader, "C18_CODIGO" )
	aAdd( aHeader, "C18_DESCRI" )
	aAdd( aHeader, "C18_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "DECISAO JUDICIAL TRANSITADA EM JULGADO, A FAVOR DA PESSOA JURIDICA.", "" } )
	aAdd( aBody, { "", "000002", "02", "DECISAO JUDICIAL NAO TRANSITADA EM JULGADO, A FAVOR DA PESSOA JURIDICA.", "" } )
	aAdd( aBody, { "", "000003", "03", "DECISAO JUDICIAL ORIUNDA DE LIMINAR EM MANDADO DE SEGURANCA.", "" } )
	aAdd( aBody, { "", "000004", "04", "DECISAO JUDICIAL ORIUNDA DE LIMINAR EM MEDIDA CAUTELAR.", "" } )
	aAdd( aBody, { "", "000005", "05", "DECISAO JUDICIAL ORIUNDA DE ANTECIPACAO DE TUTELA.", "" } )
	aAdd( aBody, { "", "000006", "06", "DECISAO JUDICIAL VINCULADA A DEPOSITO ADMINISTRATIVO OU JUDICIAL EM MONTANTE INTEGRAL.", "" } )
	aAdd( aBody, { "", "000007", "07", "MEDIDA JUDICIAL EM QUE A PESSOA JURIDICA NAO E O AUTOR.", "" } )
	aAdd( aBody, { "", "000008", "08", "SUMULA VINCULANTE APROVADA PELO STF.", "" } )
	aAdd( aBody, { "", "000009", "99", "OUTROS.", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )