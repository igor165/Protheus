#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                           
#INCLUDE "TAFA165.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA165
Cadastro MVC - Cadastro do grupo correspondente à marca comercial da bebida

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA165()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro do grupo correspondente à marca comercial da bebida
oBrw:SetAlias( 'C3X')
oBrw:SetMenuDef( 'TAFA165' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA165" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC3X 	:= 	FWFormStruct( 1, 'C3X' )
Local oModel 	:= 	MPFormModel():New( 'TAFA165' )

oModel:AddFields('MODEL_C3X', /*cOwner*/, oStruC3X)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA165' )
Local 	oStruC3X 	:= 	FWFormStruct( 2, 'C3X' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C3X', oStruC3X, 'MODEL_C3X' )

oView:EnableTitleView( 'VIEW_C3X', STR0001 ) //Cadastro do grupo correspondente à marca comercial da bebida
oView:CreateHorizontalBox( 'FIELDSC3X', 100 )
oView:SetOwnerView( 'VIEW_C3X', 'FIELDSC3X' )

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

nVerAtu := 1032.00

If nVerEmp < nVerAtu
	aAdd( aHeader, "C3X_FILIAL" )
	aAdd( aHeader, "C3X_ID" )
	aAdd( aHeader, "C3X_CODTAB" )
	aAdd( aHeader, "C3X_CODGRU" )
	aAdd( aHeader, "C3X_DESCRI" )
	aAdd( aHeader, "C3X_VALIDA" )

	aAdd( aBody, { "", "000001", "000001", "SN", "GRUPO SN", "" } )
	aAdd( aBody, { "", "000002", "000002", "SN", "GRUPO SN", "" } )
	aAdd( aBody, { "", "000003", "000003", "01", "GRUPO 01", "" } )
	aAdd( aBody, { "", "000004", "000003", "02", "GRUPO 02", "" } )
	aAdd( aBody, { "", "000005", "000003", "03", "GRUPO 03", "" } )
	aAdd( aBody, { "", "000006", "000003", "04", "GRUPO 04", "" } )
	aAdd( aBody, { "", "000007", "000003", "05", "GRUPO 05", "" } )
	aAdd( aBody, { "", "000008", "000003", "06", "GRUPO 06", "" } )
	aAdd( aBody, { "", "000009", "000003", "07", "GRUPO 07", "" } )
	aAdd( aBody, { "", "000010", "000003", "08", "GRUPO 08", "" } )
	aAdd( aBody, { "", "000011", "000003", "09", "GRUPO 09", "" } )
	aAdd( aBody, { "", "000012", "000003", "10", "GRUPO 10", "" } )
	aAdd( aBody, { "", "000013", "000003", "11", "GRUPO 11", "" } )
	aAdd( aBody, { "", "000014", "000003", "12", "GRUPO 12", "" } )
	aAdd( aBody, { "", "000015", "000003", "13", "GRUPO 13", "" } )
	aAdd( aBody, { "", "000016", "000003", "14", "GRUPO 14", "" } )
	aAdd( aBody, { "", "000017", "000003", "15", "GRUPO 15", "" } )
	aAdd( aBody, { "", "000018", "000003", "16", "GRUPO 16", "" } )
	aAdd( aBody, { "", "000019", "000003", "17", "GRUPO 17", "" } )
	aAdd( aBody, { "", "000020", "000003", "18", "GRUPO 18", "" } )
	aAdd( aBody, { "", "000021", "000003", "19", "GRUPO 19", "" } )
	aAdd( aBody, { "", "000022", "000003", "20", "GRUPO 20", "" } )
	aAdd( aBody, { "", "000023", "000003", "21", "GRUPO 21", "" } )
	aAdd( aBody, { "", "000024", "000003", "22", "GRUPO 22", "" } )
	aAdd( aBody, { "", "000025", "000003", "23", "GRUPO 23", "" } )
	aAdd( aBody, { "", "000026", "000003", "24", "GRUPO 24", "" } )
	aAdd( aBody, { "", "000027", "000003", "25", "GRUPO 25", "" } )
	aAdd( aBody, { "", "000028", "000003", "26", "GRUPO 26", "" } )
	aAdd( aBody, { "", "000029", "000003", "27", "GRUPO 27", "" } )
	aAdd( aBody, { "", "000030", "000003", "28", "GRUPO 28", "" } )
	aAdd( aBody, { "", "000031", "000003", "29", "GRUPO 29", "" } )
	aAdd( aBody, { "", "000032", "000003", "30", "GRUPO 30", "" } )
	aAdd( aBody, { "", "000033", "000003", "31", "GRUPO 31", "" } )
	aAdd( aBody, { "", "000034", "000003", "32", "GRUPO 32", "" } )
	aAdd( aBody, { "", "000035", "000003", "33", "GRUPO 33", "" } )
	aAdd( aBody, { "", "000036", "000003", "34", "GRUPO 34", "" } )
	aAdd( aBody, { "", "000037", "000003", "35", "GRUPO 35", "" } )
	aAdd( aBody, { "", "000038", "000003", "38", "GRUPO 38", "" } )
	aAdd( aBody, { "", "000039", "000003", "39", "GRUPO 39", "" } )
	aAdd( aBody, { "", "000040", "000004", "01", "GRUPO 01", "" } )
	aAdd( aBody, { "", "000041", "000004", "05", "GRUPO 05", "" } )
	aAdd( aBody, { "", "000042", "000004", "06", "GRUPO 06", "" } )
	aAdd( aBody, { "", "000043", "000004", "07", "GRUPO 07", "" } )
	aAdd( aBody, { "", "000044", "000004", "08", "GRUPO 08", "" } )
	aAdd( aBody, { "", "000045", "000004", "09", "GRUPO 09", "" } )
	aAdd( aBody, { "", "000046", "000004", "10", "GRUPO 10", "" } )
	aAdd( aBody, { "", "000047", "000004", "11", "GRUPO 11", "" } )
	aAdd( aBody, { "", "000048", "000004", "12", "GRUPO 12", "" } )
	aAdd( aBody, { "", "000049", "000004", "13", "GRUPO 13", "" } )
	aAdd( aBody, { "", "000050", "000004", "14", "GRUPO 14", "" } )
	aAdd( aBody, { "", "000051", "000004", "15", "GRUPO 15", "" } )
	aAdd( aBody, { "", "000052", "000004", "17", "GRUPO 17", "" } )
	aAdd( aBody, { "", "000053", "000004", "18", "GRUPO 18", "" } )
	aAdd( aBody, { "", "000054", "000004", "19", "GRUPO 19", "" } )
	aAdd( aBody, { "", "000055", "000004", "24", "GRUPO 24", "" } )
	aAdd( aBody, { "", "000056", "000005", "01", "GRUPO 01", "" } )
	aAdd( aBody, { "", "000057", "000005", "02", "GRUPO 02", "" } )
	aAdd( aBody, { "", "000058", "000005", "03", "GRUPO 03", "" } )
	aAdd( aBody, { "", "000059", "000005", "04", "GRUPO 04", "" } )
	aAdd( aBody, { "", "000060", "000005", "05", "GRUPO 05", "" } )
	aAdd( aBody, { "", "000061", "000005", "06", "GRUPO 06", "" } )
	aAdd( aBody, { "", "000062", "000005", "07", "GRUPO 07", "" } )
	aAdd( aBody, { "", "000063", "000005", "08", "GRUPO 08", "" } )
	aAdd( aBody, { "", "000064", "000005", "09", "GRUPO 09", "" } )
	aAdd( aBody, { "", "000065", "000005", "10", "GRUPO 10", "" } )
	aAdd( aBody, { "", "000066", "000005", "11", "GRUPO 11", "" } )
	aAdd( aBody, { "", "000067", "000005", "12", "GRUPO 12", "" } )
	aAdd( aBody, { "", "000068", "000005", "13", "GRUPO 13", "" } )
	aAdd( aBody, { "", "000069", "000005", "14", "GRUPO 14", "" } )
	aAdd( aBody, { "", "000070", "000005", "15", "GRUPO 15", "" } )
	aAdd( aBody, { "", "000071", "000005", "16", "GRUPO 16", "" } )
	aAdd( aBody, { "", "000072", "000005", "17", "GRUPO 17", "" } )
	aAdd( aBody, { "", "000073", "000005", "18", "GRUPO 18", "" } )
	aAdd( aBody, { "", "000074", "000005", "19", "GRUPO 19", "" } )
	aAdd( aBody, { "", "000075", "000005", "20", "GRUPO 20", "" } )
	aAdd( aBody, { "", "000076", "000005", "22", "GRUPO 22", "" } )
	aAdd( aBody, { "", "000077", "000005", "23", "GRUPO 23", "" } )
	aAdd( aBody, { "", "000078", "000005", "24", "GRUPO 24", "" } )
	aAdd( aBody, { "", "000079", "000005", "26", "GRUPO 26", "" } )
	aAdd( aBody, { "", "000080", "000005", "29", "GRUPO 29", "" } )
	aAdd( aBody, { "", "000081", "000005", "30", "GRUPO 30", "" } )
	aAdd( aBody, { "", "000082", "000005", "31", "GRUPO 31", "" } )
	aAdd( aBody, { "", "000083", "000005", "32", "GRUPO 32", "" } )
	aAdd( aBody, { "", "000084", "000005", "33", "GRUPO 33", "" } )
	aAdd( aBody, { "", "000085", "000005", "34", "GRUPO 34", "" } )
	aAdd( aBody, { "", "000086", "000005", "41", "GRUPO 41", "" } )
	aAdd( aBody, { "", "000087", "000005", "42", "GRUPO 42", "" } )
	aAdd( aBody, { "", "000088", "000005", "43", "GRUPO 43", "" } )
	aAdd( aBody, { "", "000089", "000005", "53", "GRUPO 53", "" } )
	aAdd( aBody, { "", "000090", "000007", "01", "GRUPO 01", "" } )
	aAdd( aBody, { "", "000091", "000007", "02", "GRUPO 02", "" } )
	aAdd( aBody, { "", "000092", "000007", "03", "GRUPO 03", "" } )
	aAdd( aBody, { "", "000093", "000007", "04", "GRUPO 04", "" } )
	aAdd( aBody, { "", "000094", "000007", "05", "GRUPO 05", "" } )
	aAdd( aBody, { "", "000095", "000007", "06", "GRUPO 06", "" } )
	aAdd( aBody, { "", "000096", "000007", "07", "GRUPO 07", "" } )
	aAdd( aBody, { "", "000097", "000007", "09", "GRUPO 09", "" } )
	aAdd( aBody, { "", "000098", "000007", "11", "GRUPO 11", "" } )
	aAdd( aBody, { "", "000099", "000007", "12", "GRUPO 12", "" } )
	aAdd( aBody, { "", "000100", "000007", "13", "GRUPO 13", "" } )
	aAdd( aBody, { "", "000101", "000007", "14", "GRUPO 14", "" } )
	aAdd( aBody, { "", "000102", "000007", "15", "GRUPO 15", "" } )
	aAdd( aBody, { "", "000103", "000007", "16", "GRUPO 16", "" } )
	aAdd( aBody, { "", "000104", "000007", "17", "GRUPO 17", "" } )
	aAdd( aBody, { "", "000105", "000007", "18", "GRUPO 18", "" } )
	aAdd( aBody, { "", "000106", "000007", "19", "GRUPO 19", "" } )
	aAdd( aBody, { "", "000107", "000007", "20", "GRUPO 20", "" } )
	aAdd( aBody, { "", "000108", "000007", "22", "GRUPO 22", "" } )
	aAdd( aBody, { "", "000109", "000007", "23", "GRUPO 23", "" } )
	aAdd( aBody, { "", "000110", "000007", "25", "GRUPO 25", "" } )
	aAdd( aBody, { "", "000111", "000007", "27", "GRUPO 27", "" } )
	aAdd( aBody, { "", "000112", "000007", "28", "GRUPO 28", "" } )
	aAdd( aBody, { "", "000113", "000007", "30", "GRUPO 30", "" } )
	aAdd( aBody, { "", "000114", "000007", "31", "GRUPO 31", "" } )
	aAdd( aBody, { "", "000115", "000007", "32", "GRUPO 32", "" } )
	aAdd( aBody, { "", "000116", "000007", "34", "GRUPO 34", "" } )
	aAdd( aBody, { "", "000117", "000007", "37", "GRUPO 37", "" } )
	aAdd( aBody, { "", "000118", "000007", "38", "GRUPO 38", "" } )
	aAdd( aBody, { "", "000119", "000007", "42", "GRUPO 42", "" } )
	aAdd( aBody, { "", "000120", "000007", "45", "GRUPO 45", "" } )
	aAdd( aBody, { "", "000121", "000007", "50", "GRUPO 50", "" } )
	aAdd( aBody, { "", "000122", "000008", "01", "GRUPO 01", "" } )
	aAdd( aBody, { "", "000123", "000008", "17", "GRUPO 17", "" } )
	aAdd( aBody, { "", "000124", "000008", "28", "GRUPO 28", "" } )
	aAdd( aBody, { "", "000125", "000008", "29", "GRUPO 29", "" } )
	aAdd( aBody, { "", "000126", "000008", "30", "GRUPO 30", "" } )
	aAdd( aBody, { "", "000127", "000008", "32", "GRUPO 32", "" } )
	aAdd( aBody, { "", "000128", "000008", "33", "GRUPO 33", "" } )
	aAdd( aBody, { "", "000129", "000008", "34", "GRUPO 34", "" } )
	aAdd( aBody, { "", "000130", "000008", "35", "GRUPO 35", "" } )
	aAdd( aBody, { "", "000131", "000008", "36", "GRUPO 36", "" } )
	aAdd( aBody, { "", "000132", "000008", "37", "GRUPO 37", "" } )
	aAdd( aBody, { "", "000133", "000008", "38", "GRUPO 38", "" } )
	aAdd( aBody, { "", "000134", "000008", "39", "GRUPO 39", "" } )
	aAdd( aBody, { "", "000135", "000008", "40", "GRUPO 40", "" } )
	aAdd( aBody, { "", "000136", "000008", "41", "GRUPO 41", "" } )
	aAdd( aBody, { "", "000137", "000008", "42", "GRUPO 42", "" } )
	aAdd( aBody, { "", "000138", "000008", "44", "GRUPO 44", "" } )
	aAdd( aBody, { "", "000139", "000008", "45", "GRUPO 45", "" } )
	aAdd( aBody, { "", "000140", "000009", "01", "GRUPO 01", "" } )
	aAdd( aBody, { "", "000141", "000009", "02", "GRUPO 03", "" } )
	aAdd( aBody, { "", "000142", "000009", "04", "GRUPO 04", "" } )
	aAdd( aBody, { "", "000143", "000009", "05", "GRUPO 05", "" } )
	aAdd( aBody, { "", "000144", "000009", "06", "GRUPO 06", "" } )
	aAdd( aBody, { "", "000145", "000009", "07", "GRUPO 07", "" } )
	aAdd( aBody, { "", "000146", "000009", "08", "GRUPO 08", "" } )
	aAdd( aBody, { "", "000147", "000009", "09", "GRUPO 09", "" } )
	aAdd( aBody, { "", "000148", "000009", "10", "GRUPO 10", "" } )
	aAdd( aBody, { "", "000149", "000009", "11", "GRUPO 11", "" } )
	aAdd( aBody, { "", "000150", "000009", "12", "GRUPO 12", "" } )
	aAdd( aBody, { "", "000151", "000009", "13", "GRUPO 13", "" } )
	aAdd( aBody, { "", "000152", "000009", "14", "GRUPO 14", "" } )
	aAdd( aBody, { "", "000153", "000009", "15", "GRUPO 15", "" } )
	aAdd( aBody, { "", "000154", "000009", "16", "GRUPO 16", "" } )
	aAdd( aBody, { "", "000155", "000009", "17", "GRUPO 17", "" } )
	aAdd( aBody, { "", "000156", "000009", "18", "GRUPO 18", "" } )
	aAdd( aBody, { "", "000157", "000009", "20", "GRUPO 20", "" } )
	aAdd( aBody, { "", "000158", "000009", "24", "GRUPO 24", "" } )
	aAdd( aBody, { "", "000159", "000009", "25", "GRUPO 25", "" } )
	aAdd( aBody, { "", "000160", "000009", "32", "GRUPO 32", "" } )
	aAdd( aBody, { "", "000161", "000009", "33", "GRUPO 33", "" } )
	aAdd( aBody, { "", "000162", "000009", "34", "GRUPO 34", "" } )
	aAdd( aBody, { "", "000163", "000010", "01", "GRUPO 01", "" } )
	aAdd( aBody, { "", "000164", "000010", "02", "GRUPO 02", "" } )
	aAdd( aBody, { "", "000165", "000010", "03", "GRUPO 03", "" } )
	aAdd( aBody, { "", "000166", "000010", "04", "GRUPO 04", "" } )
	aAdd( aBody, { "", "000167", "000010", "05", "GRUPO 05", "" } )
	aAdd( aBody, { "", "000168", "000010", "06", "GRUPO 06", "" } )
	aAdd( aBody, { "", "000169", "000010", "07", "GRUPO 07", "" } )
	aAdd( aBody, { "", "000170", "000010", "08", "GRUPO 08", "" } )
	aAdd( aBody, { "", "000171", "000010", "09", "GRUPO 09", "" } )
	aAdd( aBody, { "", "000172", "000010", "10", "GRUPO 10", "" } )
	aAdd( aBody, { "", "000173", "000010", "11", "GRUPO 11", "" } )
	aAdd( aBody, { "", "000174", "000010", "12", "GRUPO 12", "" } )
	aAdd( aBody, { "", "000175", "000010", "13", "GRUPO 13", "" } )
	aAdd( aBody, { "", "000176", "000010", "14", "GRUPO 14", "" } )
	aAdd( aBody, { "", "000177", "000010", "15", "GRUPO 15", "" } )
	aAdd( aBody, { "", "000178", "000010", "16", "GRUPO 16", "" } )
	aAdd( aBody, { "", "000179", "000010", "17", "GRUPO 17", "" } )
	aAdd( aBody, { "", "000180", "000010", "18", "GRUPO 18", "" } )
	aAdd( aBody, { "", "000181", "000010", "19", "GRUPO 19", "" } )
	aAdd( aBody, { "", "000182", "000010", "20", "GRUPO 20", "" } )
	aAdd( aBody, { "", "000183", "000010", "22", "GRUPO 22", "" } )
	aAdd( aBody, { "", "000184", "000010", "23", "GRUPO 23", "" } )
	aAdd( aBody, { "", "000185", "000010", "27", "GRUPO 27", "" } )
	aAdd( aBody, { "", "000186", "000010", "28", "GRUPO 28", "" } )
	aAdd( aBody, { "", "000187", "000010", "42", "GRUPO 42", "" } )
	aAdd( aBody, { "", "000188", "000010", "44", "GRUPO 44", "" } )
	aAdd( aBody, { "", "000189", "000010", "45", "GRUPO 45", "" } )
	aAdd( aBody, { "", "000190", "000011", "01", "GRUPO 01", "" } )
	aAdd( aBody, { "", "000191", "000011", "02", "GRUPO 02", "" } )
	aAdd( aBody, { "", "000192", "000011", "04", "GRUPO 04", "" } )
	aAdd( aBody, { "", "000193", "000011", "05", "GRUPO 05", "" } )
	aAdd( aBody, { "", "000194", "000011", "07", "GRUPO 07", "" } )
	aAdd( aBody, { "", "000195", "000011", "08", "GRUPO 08", "" } )
	aAdd( aBody, { "", "000196", "000011", "09", "GRUPO 09", "" } )
	aAdd( aBody, { "", "000197", "000011", "10", "GRUPO 10", "" } )
	aAdd( aBody, { "", "000198", "000011", "11", "GRUPO 11", "" } )
	aAdd( aBody, { "", "000199", "000011", "12", "GRUPO 12", "" } )
	aAdd( aBody, { "", "000200", "000011", "13", "GRUPO 13", "" } )
	aAdd( aBody, { "", "000201", "000011", "14", "GRUPO 14", "" } )
	aAdd( aBody, { "", "000202", "000011", "15", "GRUPO 15", "" } )
	aAdd( aBody, { "", "000203", "000011", "16", "GRUPO 16", "" } )
	aAdd( aBody, { "", "000204", "000011", "17", "GRUPO 17", "" } )
	aAdd( aBody, { "", "000205", "000011", "18", "GRUPO 18", "" } )
	aAdd( aBody, { "", "000206", "000011", "19", "GRUPO 19", "" } )
	aAdd( aBody, { "", "000207", "000011", "20", "GRUPO 20", "" } )
	aAdd( aBody, { "", "000208", "000011", "21", "GRUPO 21", "" } )
	aAdd( aBody, { "", "000209", "000011", "22", "GRUPO 22", "" } )
	aAdd( aBody, { "", "000210", "000011", "23", "GRUPO 23", "" } )
	aAdd( aBody, { "", "000211", "000011", "24", "GRUPO 24", "" } )
	aAdd( aBody, { "", "000212", "000011", "25", "GRUPO 25", "" } )
	aAdd( aBody, { "", "000213", "000011", "26", "GRUPO 26", "" } )
	aAdd( aBody, { "", "000214", "000011", "27", "GRUPO 27", "" } )
	aAdd( aBody, { "", "000215", "000011", "29", "GRUPO 29", "" } )
	aAdd( aBody, { "", "000216", "000011", "30", "GRUPO 30", "" } )
	aAdd( aBody, { "", "000217", "000011", "31", "GRUPO 31", "" } )
	aAdd( aBody, { "", "000218", "000011", "32", "GRUPO 32", "" } )
	aAdd( aBody, { "", "000219", "000011", "33", "GRUPO 33", "" } )
	aAdd( aBody, { "", "000220", "000011", "34", "GRUPO 34", "" } )
	aAdd( aBody, { "", "000221", "000011", "35", "GRUPO 35", "" } )
	aAdd( aBody, { "", "000222", "000011", "36", "GRUPO 36", "" } )
	aAdd( aBody, { "", "000223", "000011", "37", "GRUPO 37", "" } )
	aAdd( aBody, { "", "000224", "000011", "38", "GRUPO 38", "" } )
	aAdd( aBody, { "", "000225", "000011", "39", "GRUPO 39", "" } )
	aAdd( aBody, { "", "000226", "000011", "40", "GRUPO 40", "" } )
	aAdd( aBody, { "", "000227", "000011", "41", "GRUPO 41", "" } )
	aAdd( aBody, { "", "000228", "000011", "42", "GRUPO 42", "" } )
	aAdd( aBody, { "", "000229", "000011", "44", "GRUPO 44", "" } )
	aAdd( aBody, { "", "000230", "000011", "45", "GRUPO 45", "" } )
	aAdd( aBody, { "", "000231", "000011", "46", "GRUPO 46", "" } )
	aAdd( aBody, { "", "000232", "000011", "47", "GRUPO 47", "" } )
	aAdd( aBody, { "", "000233", "000011", "64", "GRUPO 64", "" } )
	aAdd( aBody, { "", "000234", "000011", "74", "GRUPO 74", "" } )
	aAdd( aBody, { "", "000235", "000011", "83", "GRUPO 83", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
