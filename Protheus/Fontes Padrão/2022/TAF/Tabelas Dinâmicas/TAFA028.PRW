#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA028.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA028
Cadastro MVC de Documento de Arrecadação

@author Fabio V. Santana
@since 10/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA028()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro de Documento de Arrecadação
oBrw:SetAlias( 'C0S')
oBrw:SetMenuDef( 'TAFA028' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA028" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC0S 	:= 	FWFormStruct( 1, 'C0S' )
Local oModel 	:= 	MPFormModel():New( 'TAFA028' )

oModel:AddFields('MODEL_C0S', /*cOwner*/, oStruC0S)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA028' )
Local 	oStruC0S 	:= 	FWFormStruct( 2, 'C0S' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0S', oStruC0S, 'MODEL_C0S' )

oView:EnableTitleView( 'VIEW_C0S', STR0001 ) //Cadastro de Documento de Arrecadação
oView:CreateHorizontalBox( 'FIELDSC0S', 100 )
oView:SetOwnerView( 'VIEW_C0S', 'FIELDSC0S' )

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
	aAdd( aHeader, "C0S_FILIAL" )
	aAdd( aHeader, "C0S_ID" )
	aAdd( aHeader, "C0S_CODIGO" )
	aAdd( aHeader, "C0S_DESCRI" )
	aAdd( aHeader, "C0S_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "AWB", "" } )
	aAdd( aBody, { "", "000002", "02", "MAWB", "" } )
	aAdd( aBody, { "", "000003", "03", "HAWB", "" } )
	aAdd( aBody, { "", "000004", "04", "COMAT", "" } )
	aAdd( aBody, { "", "000005", "06", "R. EXPRESSAS", "" } )
	aAdd( aBody, { "", "000006", "07", "ETIQ. REXPRESSAS", "" } )
	aAdd( aBody, { "", "000007", "08", "HR. EXPRESSAS", "" } )
	aAdd( aBody, { "", "000008", "09", "AV7", "" } )
	aAdd( aBody, { "", "000009", "10", "BL", "" } )
	aAdd( aBody, { "", "000010", "11", "MBL", "" } )
	aAdd( aBody, { "", "000011", "12", "HBL", "" } )
	aAdd( aBody, { "", "000012", "13", "CRT", "" } )
	aAdd( aBody, { "", "000013", "14", "DSIC", "" } )
	aAdd( aBody, { "", "000014", "16", "COMAT BL", "" } )
	aAdd( aBody, { "", "000015", "17", "RWB", "" } )
	aAdd( aBody, { "", "000016", "18", "HRWB", "" } )
	aAdd( aBody, { "", "000017", "19", "TIF/DTA", "" } )
	aAdd( aBody, { "", "000018", "20", "CP2", "" } )
	aAdd( aBody, { "", "000019", "91", "NAO IATA", "" } )
	aAdd( aBody, { "", "000020", "92", "MNAO IATA", "" } )
	aAdd( aBody, { "", "000021", "93", "HNAO IATA", "" } )
	aAdd( aBody, { "", "000022", "99", "OUTROS", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )