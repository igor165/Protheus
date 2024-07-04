#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA005.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA005
Cadastro MVC das Modalidades da Base de Calculo do ICMS/ST

@author Marcio Nunes
@since 03/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA005()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro das Modalidades da Base de Calculo do ICMS/ST
oBrw:SetAlias( 'C05')
oBrw:SetMenuDef( 'TAFA005' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 03/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA005" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 03/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC05 	:= 	FWFormStruct( 1, 'C05' )
Local oModel 	:= 	MPFormModel():New( 'TAFA005' )

oModel:AddFields('MODEL_C05', /*cOwner*/, oStruC05)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 03/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA005' )
Local 	oStruC05 	:= 	FWFormStruct( 2, 'C05' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C05', oStruC05, 'MODEL_C05' )

oView:EnableTitleView( 'VIEW_C05', STR0001 ) //Cadastro das Modalidades da Base de Calculo do ICMS/ST
oView:CreateHorizontalBox( 'FIELDSC05', 100 )
oView:SetOwnerView( 'VIEW_C05', 'FIELDSC05' )

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
	aAdd( aHeader, "C05_FILIAL" )
	aAdd( aHeader, "C05_ID" )
	aAdd( aHeader, "C05_CODIGO" )
	aAdd( aHeader, "C05_DESCRI" )
	aAdd( aHeader, "C05_VALIDA" )

	aAdd( aBody, { "", "000001", "0", "PRECO TABELADO OU MAXIMO SUGERIDO", "" } )
	aAdd( aBody, { "", "000002", "1", "LISTA NEGATIVA (VALOR)", "" } )
	aAdd( aBody, { "", "000003", "2", "LISTA POSITIVA (VALOR)", "" } )
	aAdd( aBody, { "", "000004", "3", "LISTA NEUTRA (VALOR)", "" } )
	aAdd( aBody, { "", "000005", "4", "MARGEM VALOR AGREGADO (%)", "" } )
	aAdd( aBody, { "", "000006", "5", "PAUTA (VALOR)", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )