#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA152.CH"                             
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA152
Cadastro MVC - Cadastro de Sub-Grupo ANP

@author Mauro A. Goncalves
@since 06/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA152()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Sub-Grupo ANP
oBrw:SetAlias( 'C0E')
oBrw:SetMenuDef( 'TAFA152' )
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
Return XFUNMnuTAF( "TAFA152" )
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
Local oStruC0E 	:= 	FWFormStruct( 1, 'C0E' )
Local oModel 	:= 	MPFormModel():New( 'TAFA152' )

oModel:AddFields('MODEL_C0E', /*cOwner*/, oStruC0E)

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA152' )
Local 	oStruC0E 	:= 	FWFormStruct( 2, 'C0E' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0E', oStruC0E, 'MODEL_C0E' )

oView:EnableTitleView( 'VIEW_C0E', STR0001 ) //Cadastro de Sub-Grupo ANP
oView:CreateHorizontalBox( 'FIELDSC0E', 100 )
oView:SetOwnerView( 'VIEW_C0E', 'FIELDSC0E' )

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
	aAdd( aHeader, "C0E_FILIAL" )
	aAdd( aHeader, "C0E_ID" )
	aAdd( aHeader, "C0E_CODIGO" )
	aAdd( aHeader, "C0E_DESCRI" )
	aAdd( aHeader, "C0E_ALTCON" )

	aAdd( aBody, { "", "000001", "01", "ADITIVOS" } )
	aAdd( aBody, { "", "000002", "02", "AGUA" } )
	aAdd( aBody, { "", "000003", "03", "ALCOOL ETILICO" } )
	aAdd( aBody, { "", "000004", "04", "ASFALTOS" } )
	aAdd( aBody, { "", "000005", "05", "BIODIESEL" } )
	aAdd( aBody, { "", "000006", "06", "COQUE" } )
	aAdd( aBody, { "", "000007", "07", "ENXOFRE" } )
	aAdd( aBody, { "", "000008", "08", "GAS COMBUSTIVEL" } )
	aAdd( aBody, { "", "000009", "09", "GAS NATURAL" } )
	aAdd( aBody, { "", "000010", "10", "GASES LIQUEFEITOS" } )
	aAdd( aBody, { "", "000011", "11", "GASOLEOS" } )
	aAdd( aBody, { "", "000012", "12", "GASOLINAS AUTOMOTIVAS" } )
	aAdd( aBody, { "", "000013", "13", "GASOLINAS DE AVIACAO" } )
	aAdd( aBody, { "", "000014", "14", "GRAXAS" } )
	aAdd( aBody, { "", "000015", "15", "HIDROGENIO" } )
	aAdd( aBody, { "", "000016", "16", "IMPORTADO" } )
	aAdd( aBody, { "", "000017", "17", "MACRO" } )
	aAdd( aBody, { "", "000018", "18", "MICRO" } )
	aAdd( aBody, { "", "000019", "19", "MISTURA" } )
	aAdd( aBody, { "", "000020", "20", "NACIONAL" } )
	aAdd( aBody, { "", "000021", "21", "NAFTA" } )
	aAdd( aBody, { "", "000022", "22", "NAFTONICOS" } )
	aAdd( aBody, { "", "000023", "23", "OLEO DIESEL MARITIMO" } )
	aAdd( aBody, { "", "000024", "24", "OLEOS BASICOS - GRUPO II" } )
	aAdd( aBody, { "", "000025", "25", "OLEOS BASICOS - GRUPO III" } )
	aAdd( aBody, { "", "000026", "26", "OLEOS COMBUSTIVEIS INDUSTRIAIS" } )
	aAdd( aBody, { "", "000027", "27", "OLEOS COMBUSTIVEIS MARITIMOS" } )
	aAdd( aBody, { "", "000028", "28", "OLEOS DIESEL AUTOMOTIVOS" } )
	aAdd( aBody, { "", "000029", "29", "OLEOS LUBRIFICANTES ACABADOS" } )
	aAdd( aBody, { "", "000030", "30", "OLEOS LUBRIFICANTES AUTOMOTIVOS" } )
	aAdd( aBody, { "", "000031", "31", "OLEOS LUBRIFICANTES FERROVIARIOS" } )
	aAdd( aBody, { "", "000032", "32", "OLEOS LUBRIFICANTES INDUSTRIAIS" } )
	aAdd( aBody, { "", "000033", "33", "OLEOS LUBRIFICANTES MARITIMOS" } )
	aAdd( aBody, { "", "000034", "34", "OLEOS LUBRIFICANTES PARA AVIACAO" } )
	aAdd( aBody, { "", "000035", "35", "OLEOS LUBRIFICANTES USADOS OU CONTAMINADOS" } )
	aAdd( aBody, { "", "000036", "36", "OUTRAS GASOLINAS" } )
	aAdd( aBody, { "", "000037", "37", "OUTRAS PARAFINAS" } )
	aAdd( aBody, { "", "000038", "38", "OUTROS ALCOOIS" } )
	aAdd( aBody, { "", "000039", "39", "OUTROS DERIVADOS LEVES" } )
	aAdd( aBody, { "", "000040", "40", "OUTROS DERIVADOS MEDIOS" } )
	aAdd( aBody, { "", "000041", "41", "OUTROS DERIVADOS PESADOS" } )
	aAdd( aBody, { "", "000042", "42", "OUTROS GASES" } )
	aAdd( aBody, { "", "000043", "43", "OUTROS INSUMOS BRUTOS" } )
	aAdd( aBody, { "", "000044", "44", "OUTROS OLEOS COMBUSTIVEIS" } )
	aAdd( aBody, { "", "000045", "45", "OUTROS OLEOS DIESEL" } )
	aAdd( aBody, { "", "000046", "46", "OUTROS OLEOS LUB. PARAF. E GRAXAS" } )
	aAdd( aBody, { "", "000047", "47", "OUTROS OLEOS LUBRIFICANTES BASICOS" } )
	aAdd( aBody, { "", "000048", "48", "OUTROS SUB-PRODUTOS" } )
	aAdd( aBody, { "", "000049", "49", "PARAFINICOS" } )
	aAdd( aBody, { "", "000050", "50", "QUEROSENES" } )
	aAdd( aBody, { "", "000051", "51", "RERREFINADOS" } )
	aAdd( aBody, { "", "000052", "52", "RESIDUOS PESADOS" } )
	aAdd( aBody, { "", "000053", "53", "SINTETICOS" } )
	aAdd( aBody, { "", "000054", "54", "SOLVENTES" } )
	aAdd( aBody, { "", "000055", "55", "VASELINA" } )
	aAdd( aBody, { "", "000056", "56", "XISTO" } )
	aAdd( aBody, { "", "000057", "57", "OUTROS OLEOS LUB. PARAF. E 14" } )
	aAdd( aBody, { "", "000058", "58", "ETANOL",1032.06 } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
