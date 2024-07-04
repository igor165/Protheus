#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                             
#INCLUDE "TAFA161.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA161
Cadastro MVC de Código da Contribuição Social

@author Fabio V. Santana
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA161()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro dos Grupos da Natureza de Receita
oBrw:SetAlias( 'C1W')
oBrw:SetMenuDef( 'TAFA161' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA161" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC1W 	:= 	FWFormStruct( 1, 'C1W' )
Local oModel 	:= 	MPFormModel():New( 'TAFA161' )

oModel:AddFields('MODEL_C1W', /*cOwner*/, oStruC1W)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA161' )
Local 	oStruC1W 	:= 	FWFormStruct( 2, 'C1W' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C1W', oStruC1W, 'MODEL_C1W' )

oView:EnableTitleView( 'VIEW_C1W', STR0001 ) //Cadastro dos Grupos da Natureza de Receita
oView:CreateHorizontalBox( 'FIELDSC1W', 100 )
oView:SetOwnerView( 'VIEW_C1W', 'FIELDSC1W' )

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
	aAdd( aHeader, "C1W_FILIAL" )
	aAdd( aHeader, "C1W_ID" )
	aAdd( aHeader, "C1W_CODIGO" )
	aAdd( aHeader, "C1W_DESCRI" )
	aAdd( aHeader, "C1W_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "GRUPO 1", "" } )
	aAdd( aBody, { "", "000002", "02", "GRUPO 2", "" } )
	aAdd( aBody, { "", "000003", "03", "GRUPO 3", "" } )
	aAdd( aBody, { "", "000004", "04", "GRUPO 4", "" } )
	aAdd( aBody, { "", "000005", "05", "GRUPO 5", "" } )
	aAdd( aBody, { "", "000006", "06", "GRUPO 6", "" } )
	aAdd( aBody, { "", "000007", "07", "GRUPO 7", "" } )
	aAdd( aBody, { "", "000008", "08", "GRUPO 8", "" } )
	aAdd( aBody, { "", "000009", "09", "GRUPO 9", "" } )
	aAdd( aBody, { "", "000010", "10", "GRUPO 10", "" } )
	aAdd( aBody, { "", "000011", "11", "GRUPO 11", "" } )
	aAdd( aBody, { "", "000012", "12", "GRUPO 12", "" } )
	aAdd( aBody, { "", "000013", "13", "GRUPO 13", "" } )
	aAdd( aBody, { "", "000014", "14", "GRUPO 14", "" } )
	aAdd( aBody, { "", "000015", "15", "GRUPO 15", "" } )
	aAdd( aBody, { "", "000016", "16", "GRUPO 16", "" } )
	aAdd( aBody, { "", "000017", "17", "GRUPO 17", "" } )
	aAdd( aBody, { "", "000018", "18", "GRUPO 18", "" } )
	aAdd( aBody, { "", "000019", "19", "GRUPO 19", "" } )
	aAdd( aBody, { "", "000020", "20", "GRUPO 20", "" } )
	aAdd( aBody, { "", "000021", "21", "GRUPO 21", "" } )
	aAdd( aBody, { "", "000022", "22", "GRUPO 22", "" } )
	aAdd( aBody, { "", "000023", "23", "GRUPO 23", "" } )
	aAdd( aBody, { "", "000024", "24", "GRUPO 24", "" } )
	aAdd( aBody, { "", "000025", "25", "GRUPO 25", "" } )
	aAdd( aBody, { "", "000026", "26", "GRUPO 26", "" } )
	aAdd( aBody, { "", "000027", "27", "GRUPO 27", "" } )
	aAdd( aBody, { "", "000028", "28", "GRUPO 28", "" } )
	aAdd( aBody, { "", "000029", "29", "GRUPO 29", "" } )
	aAdd( aBody, { "", "000030", "30", "GRUPO 30", "" } )
	aAdd( aBody, { "", "000031", "31", "GRUPO 31", "" } )
	aAdd( aBody, { "", "000032", "32", "GRUPO 32", "" } )
	aAdd( aBody, { "", "000033", "33", "GRUPO 33", "" } )
	aAdd( aBody, { "", "000034", "34", "GRUPO 34", "" } )
	aAdd( aBody, { "", "000035", "35", "GRUPO 35", "" } )
	aAdd( aBody, { "", "000036", "36", "GRUPO 36", "" } )
	aAdd( aBody, { "", "000037", "37", "GRUPO 37", "" } )
	aAdd( aBody, { "", "000038", "38", "GRUPO 38", "" } )
	aAdd( aBody, { "", "000039", "39", "GRUPO 39", "" } )
	aAdd( aBody, { "", "000040", "40", "GRUPO 40", "" } )
	aAdd( aBody, { "", "000041", "41", "GRUPO 41", "" } )
	aAdd( aBody, { "", "000042", "42", "GRUPO 42", "" } )
	aAdd( aBody, { "", "000043", "43", "GRUPO 43", "" } )
	aAdd( aBody, { "", "000044", "44", "GRUPO 44", "" } )
	aAdd( aBody, { "", "000045", "45", "GRUPO 45", "" } )
	aAdd( aBody, { "", "000046", "46", "GRUPO 46", "" } )
	aAdd( aBody, { "", "000047", "47", "GRUPO 47", "" } )
	aAdd( aBody, { "", "000048", "48", "GRUPO 48", "" } )
	aAdd( aBody, { "", "000049", "49", "GRUPO 49", "" } )
	aAdd( aBody, { "", "000050", "50", "GRUPO 50", "" } )
	aAdd( aBody, { "", "000051", "51", "GRUPO 51", "" } )
	aAdd( aBody, { "", "000052", "52", "GRUPO 52", "" } )
	aAdd( aBody, { "", "000053", "53", "GRUPO 53", "" } )
	aAdd( aBody, { "", "000054", "54", "GRUPO 54", "" } )
	aAdd( aBody, { "", "000055", "55", "GRUPO 55", "" } )
	aAdd( aBody, { "", "000056", "56", "GRUPO 56", "" } )
	aAdd( aBody, { "", "000057", "57", "GRUPO 57", "" } )
	aAdd( aBody, { "", "000058", "58", "GRUPO 58", "" } )
	aAdd( aBody, { "", "000059", "59", "GRUPO 59", "" } )
	aAdd( aBody, { "", "000060", "60", "GRUPO 60", "" } )
	aAdd( aBody, { "", "000061", "61", "GRUPO 61", "" } )
	aAdd( aBody, { "", "000062", "62", "GRUPO 62", "" } )
	aAdd( aBody, { "", "000063", "63", "GRUPO 63", "" } )
	aAdd( aBody, { "", "000064", "64", "GRUPO 64", "" } )
	aAdd( aBody, { "", "000065", "65", "GRUPO 65", "" } )
	aAdd( aBody, { "", "000066", "66", "GRUPO 66", "" } )
	aAdd( aBody, { "", "000067", "67", "GRUPO 67", "" } )
	aAdd( aBody, { "", "000068", "68", "GRUPO 68", "" } )
	aAdd( aBody, { "", "000069", "69", "GRUPO 69", "" } )
	aAdd( aBody, { "", "000070", "70", "GRUPO 70", "" } )
	aAdd( aBody, { "", "000071", "71", "GRUPO 71", "" } )
	aAdd( aBody, { "", "000072", "72", "GRUPO 72", "" } )
	aAdd( aBody, { "", "000073", "73", "GRUPO 73", "" } )
	aAdd( aBody, { "", "000074", "74", "GRUPO 74", "" } )
	aAdd( aBody, { "", "000075", "75", "GRUPO 75", "" } )
	aAdd( aBody, { "", "000076", "76", "GRUPO 76", "" } )
	aAdd( aBody, { "", "000077", "77", "GRUPO 77", "" } )
	aAdd( aBody, { "", "000078", "78", "GRUPO 78", "" } )
	aAdd( aBody, { "", "000079", "79", "GRUPO 79", "" } )
	aAdd( aBody, { "", "000080", "80", "GRUPO 80", "" } )
	aAdd( aBody, { "", "000081", "81", "GRUPO 81", "" } )
	aAdd( aBody, { "", "000082", "82", "GRUPO 82", "" } )
	aAdd( aBody, { "", "000083", "83", "GRUPO 83", "" } )
	aAdd( aBody, { "", "000084", "84", "GRUPO 84", "" } )
	aAdd( aBody, { "", "000085", "85", "GRUPO 85", "" } )
	aAdd( aBody, { "", "000086", "86", "GRUPO 86", "" } )
	aAdd( aBody, { "", "000087", "87", "GRUPO 87", "" } )
	aAdd( aBody, { "", "000088", "88", "GRUPO 88", "" } )
	aAdd( aBody, { "", "000089", "89", "GRUPO 89", "" } )
	aAdd( aBody, { "", "000090", "90", "GRUPO 90", "" } )
	aAdd( aBody, { "", "000091", "91", "GRUPO 91", "" } )
	aAdd( aBody, { "", "000092", "92", "GRUPO 92", "" } )
	aAdd( aBody, { "", "000093", "93", "GRUPO 93", "" } )
	aAdd( aBody, { "", "000094", "94", "GRUPO 94", "" } )
	aAdd( aBody, { "", "000095", "95", "GRUPO 95", "" } )
	aAdd( aBody, { "", "000096", "96", "GRUPO 96", "" } )
	aAdd( aBody, { "", "000097", "97", "GRUPO 97", "" } )
	aAdd( aBody, { "", "000098", "98", "GRUPO 98", "" } )
	aAdd( aBody, { "", "000099", "99", "GRUPO 99", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )