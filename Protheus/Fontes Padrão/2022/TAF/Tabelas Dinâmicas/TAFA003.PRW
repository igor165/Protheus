#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA003.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA003
Cadastro MVC das Origens das Mercadorias 

@author Mauro A. Goncalves
@since 02/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA003()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Cadastro das Origens das Mercadorias"
oBrw:SetAlias( 'C03')
oBrw:SetMenuDef( 'TAFA003' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 02/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA003" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 02/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC03 	:= 	FWFormStruct( 1, 'C03' )
Local oModel 	:= 	MPFormModel():New( 'TAFA003' )

oModel:AddFields('MODEL_C03', /*cOwner*/, oStruC03)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 02/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA003' )
Local 	oStruZAE 	:= 	FWFormStruct( 2, 'C03' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C03', oStruZAE, 'MODEL_C03' )

oView:EnableTitleView( 'VIEW_C03', STR0001 ) //"Cadastro das Origens das Mercadorias"
oView:CreateHorizontalBox( 'FIELDSC03', 100 )
oView:SetOwnerView( 'VIEW_C03', 'FIELDSC03' )

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
	aAdd( aHeader, "C03_FILIAL" )
	aAdd( aHeader, "C03_ID" )
	aAdd( aHeader, "C03_CODIGO" )
	aAdd( aHeader, "C03_DESCRI" )
	aAdd( aHeader, "C03_VALIDA" )

	aAdd( aBody, { "", "000001", "0", "Origem Nacional", "" } )
	aAdd( aBody, { "", "000002", "1", "Origem Estrangeira - Importacao Direta", "" } )
	aAdd( aBody, { "", "000003", "2", "Origem Estrangeira - Adquirida no Mercado Interno", "" } )
	aAdd( aBody, { "", "000004", "3", "Nacional, mercadoria ou bem com Conteúdo de Importação superior a 40% (quarenta por cento)", "" } )
	aAdd( aBody, { "", "000005", "4", "Nacional, cuja produção tenha sido feita em conformidade com os processos produtivos básicos de que tratam o Decreto-Lei nº 288/67, e as Leis nºs 8.248/91, 8.387/91, 10.176/01 e 11 . 4 8 4 / 0 7", "" } )
	aAdd( aBody, { "", "000006", "5", "Nacional, mercadoria ou bem com Conteúdo de Importação inferior ou igual a 40% (quarenta por cento)", "" } )
	aAdd( aBody, { "", "000007", "6", "Estrangeira - Importação direta, sem similar nacional, constante em lista de Resolução CAMEX", "" } )
	aAdd( aBody, { "", "000008", "7", "Estrangeira - Adquirida no mercado interno, sem similar nacional, constante em lista de Resolução CAMEX", "" } )
	aAdd( aBody, { "", "000009", "8", "NACIONAL, MERCADORIA OU BEM COM CONTEUDO DE IMPORTACAO SUPERIOR A 70% (SETENTA POR CENTO)", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )