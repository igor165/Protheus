#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                                       
#INCLUDE "TAFA151.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA151
Cadastro MVC - Cadastro de Grupo ANP

@author Mauro A. Goncalves
@since 06/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA151()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Grupo ANP
oBrw:SetAlias( 'C0D')
oBrw:SetMenuDef( 'TAFA151' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 06/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA151" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 06/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC0D 	:= 	FWFormStruct( 1, 'C0D' )
Local oModel 	:= 	MPFormModel():New( 'TAFA151' )

oModel:AddFields('MODEL_C0D', /*cOwner*/, oStruC0D)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 06/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA151' )
Local 	oStruC0D 	:= 	FWFormStruct( 2, 'C0D' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0D', oStruC0D, 'MODEL_C0D' )

oView:EnableTitleView( 'VIEW_C0D', STR0001 ) //Cadastro de Grupo ANP
oView:CreateHorizontalBox( 'FIELDSC0D', 100 )
oView:SetOwnerView( 'VIEW_C0D', 'FIELDSC0D' )

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

nVerAtu := 1032.06

If nVerEmp < nVerAtu
	aAdd( aHeader, "C0D_FILIAL" )
	aAdd( aHeader, "C0D_ID" )
	aAdd( aHeader, "C0D_CODIGO" )
	aAdd( aHeader, "C0D_DESCRI" )
	aAdd( aHeader, "C0D_ALTCON" )

	aAdd( aBody, { "", "000001", "01", "ADITIVOS" } )
	aAdd( aBody, { "", "000002", "02", "AGUA" } )
	aAdd( aBody, { "", "000003", "03", "ALCOOL" } )
	aAdd( aBody, { "", "000004", "04", "ASFALTOS" } )
	aAdd( aBody, { "", "000005", "05", "BIODIESEL" } )
	aAdd( aBody, { "", "000006", "06", "CONDENSADO" } )
	aAdd( aBody, { "", "000007", "07", "COQUE" } )
	aAdd( aBody, { "", "000008", "08", "ENXOFRE" } )
	aAdd( aBody, { "", "000009", "09", "GAS NATURAL" } )
	aAdd( aBody, { "", "000010", "10", "GASES" } )
	aAdd( aBody, { "", "000011", "11", "GASOLEOS" } )
	aAdd( aBody, { "", "000012", "12", "GASOLINAS" } )
	aAdd( aBody, { "", "000013", "13", "GRAXAS" } )
	aAdd( aBody, { "", "000014", "14", "HIDROGONIO" } )
	aAdd( aBody, { "", "000015", "15", "NAFTA" } )
	aAdd( aBody, { "", "000016", "16", "OLEO DIESEL" } )
	aAdd( aBody, { "", "000017", "17", "OLEOS COMBUSTIVEIS" } )
	aAdd( aBody, { "", "000018", "18", "OLEOS LUBRIFICANTES ACABADOS" } )
	aAdd( aBody, { "", "000019", "19", "OLEOS LUBRIFICANTES BASICOS" } )
	aAdd( aBody, { "", "000020", "20", "OLEOS LUBRIFICANTES USADOS OU CONTAMINADOS" } )
	aAdd( aBody, { "", "000021", "21", "OUTROS DERIVADOS LEVES" } )
	aAdd( aBody, { "", "000022", "22", "OUTROS DERIVADOS MEDIOS" } )
	aAdd( aBody, { "", "000023", "23", "OUTROS DERIVADOS PESADOS" } )
	aAdd( aBody, { "", "000024", "24", "OUTROS INSUMOS BRUTOS" } )
	aAdd( aBody, { "", "000025", "25", "OUTROS OLEOS LUB. PARAF. E GRAXAS" } )
	aAdd( aBody, { "", "000026", "26", "OUTROS SUB-PRODUTOS" } )
	aAdd( aBody, { "", "000027", "27", "PARAFINAS" } )
	aAdd( aBody, { "", "000028", "28", "PETROLEO" } )
	aAdd( aBody, { "", "000029", "29", "QUEROSENES" } )
	aAdd( aBody, { "", "000030", "30", "RESIDUOS PESADOS" } )
	aAdd( aBody, { "", "000031", "31", "SOLVENTES" } )
	aAdd( aBody, { "", "000032", "32", "RENOVAVEIS",1032.06 } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
