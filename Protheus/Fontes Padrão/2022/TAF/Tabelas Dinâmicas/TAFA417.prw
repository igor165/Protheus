#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA417.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA417
Cadastro MVC dos Indicativos de Comercialização

@author Daniel Schimidt			
@since 11/01/2015
@version 1.0

/*/
//-------------------------------------------------------------------

Function TAFA417()

Local	oBrw		:=	FWmBrowse():New()

If TAFAlsInDic('T1T')
	oBrw:SetDescription( STR0001 ) //Cadastro de Indicativos de Comercialização
	oBrw:SetAlias( 'T1T')
	oBrw:SetMenuDef( 'TAFA417' )
	oBrw:Activate()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Daniel Schimidt			
@since 11/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA417" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Daniel Schimidt			
@since 11/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT1T 	:= 	FWFormStruct( 1, 'T1T' )
Local oModel 	:= 	MPFormModel():New( 'TAFA417' )

oModel:AddFields('MODEL_T1T', /*cOwner*/, oStruT1T)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Daniel Schimidt			
@since 11/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 	:= 	FWLoadModel( 'TAFA417' )
Local 	oStruC06 	:= 	FWFormStruct( 2,'T1T' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_T1T', oStruC06, 'MODEL_T1T' )

oView:EnableTitleView( 'VIEW_T1T', STR0001 ) //Cadastro de Indicativos de Comercialização
oView:CreateHorizontalBox( 'FIELDST1T', 100 )
oView:SetOwnerView( 'VIEW_T1T', 'FIELDST1T' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@author Daniel Schimidt			
@since 11/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1031.54

If nVerEmp < nVerAtu
	aAdd( aHeader, "T1T_FILIAL" )
	aAdd( aHeader, "T1T_ID" )
	aAdd( aHeader, "T1T_CODIGO" )
	aAdd( aHeader, "T1T_DESCRI" )
	aAdd( aHeader, "T1T_VALIDA" )

	aAdd( aBody, { "", "000001", "2", "COMERCIALIZAÇÃO DA PRODUÇÃO POR PROD. RURAL PESSOA FÍSICA, INCLUSIVE POR SEGURADO ESPECIAL, EFETUADA DIRETAMENTE NO VAREJO A CONSUMIDOR FINAL OU A OUTRO PRODUTOR RURAL PESSOA FÍSICA", "" } )
	aAdd( aBody, { "", "000002", "3", "COMERCIALIZAÇÃO DA PRODUÇÃO POR PROD. RURAL PF/SEG. ESPECIAL - VENDAS A PJ (EXCETO ENTIDADE DO PROGRAMA DE AQUISIÇÃO DE ALIMENTOS - PAA) OU A INTERMEDIÁRIO PF", "" } )
	aAdd( aBody, { "", "000003", "8", "COMERCIALIZAÇÃO DA PRODUÇÃO DA PESSOA FÍSICA/SEGURADO ESPECIAL PARA ENTIDADE DO PROGRAMA DE AQUISIÇÃO DE ALIMENTOS - PAA", "" } )
	aAdd( aBody, { "", "000004", "9", "COMERCIALIZAÇÃO DA PRODUÇÃO NO MERCADO EXTERNO", "" } )
	aAdd( aBody, { "", "000005", "7", "COMERCIALIZAÇÃO DA PRODUÇÃO ISENTA DE ACORDO COM A LEI Nº 13.606/2018 EFETUADA DIRETAMENTE NO VAREJO A CONS. FINAL OU A OUTRO PROD. RURAL PF POR PROD. RURAL PF, INCLUSIVE POR SEG. ESPECIAL, OU POR PF NÃO PROD. RURAL", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
