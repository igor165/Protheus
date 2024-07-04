#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA021.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA021
Cadastro MVC - Cadastro de Classe de Consumo (Energia Elétrica e Gás) 

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA021()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Classe de Consumo (Energia Elétrica e Gás)
oBrw:SetAlias( 'C0L')
oBrw:SetMenuDef( 'TAFA021' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA021" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC0L 	:= 	FWFormStruct( 1, 'C0L' )
Local oModel 	:= 	MPFormModel():New( 'TAFA021' )

oModel:AddFields('MODEL_C0L', /*cOwner*/, oStruC0L)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA021' )
Local 	oStruC0L 	:= 	FWFormStruct( 2, 'C0L' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0L', oStruC0L, 'MODEL_C0L' )

oView:EnableTitleView( 'VIEW_C0L', STR0001 ) //Cadastro de Classe de Consumo (Energia Elétrica e Gás)
oView:CreateHorizontalBox( 'FIELDSC0L', 100 )
oView:SetOwnerView( 'VIEW_C0L', 'FIELDSC0L' )

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
	aAdd( aHeader, "C0L_FILIAL" )
	aAdd( aHeader, "C0L_ID" )
	aAdd( aHeader, "C0L_CODIGO" )
	aAdd( aHeader, "C0L_DESCRI" )
	aAdd( aHeader, "C0L_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "COMERCIAL", "" } )
	aAdd( aBody, { "", "000002", "02", "CONSUMO PROPRIO", "" } )
	aAdd( aBody, { "", "000003", "03", "ILUMINACAO PUBLICA", "" } )
	aAdd( aBody, { "", "000004", "04", "INDUSTRIAL", "" } )
	aAdd( aBody, { "", "000005", "05", "PODER PUBLICO", "" } )
	aAdd( aBody, { "", "000006", "06", "RESIDENCIAL", "" } )
	aAdd( aBody, { "", "000007", "07", "RURAL", "" } )
	aAdd( aBody, { "", "000008", "08", "SERVICO PUBLICO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )