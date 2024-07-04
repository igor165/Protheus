#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA009.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA009
Cadastro MVC das Unidade Federativa

@author Mauro A. Goncalves
@since 03/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA009()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de UF
oBrw:SetAlias( 'C09')
oBrw:SetMenuDef( 'TAFA009' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 03/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA009" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 03/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC09 	:= 	FWFormStruct( 1, 'C09' )
Local oModel 	:= 	MPFormModel():New( 'TAFA009' )

oModel:AddFields('MODEL_C09', /*cOwner*/, oStruC09)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 03/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA009' )
Local 	oStruC09 	:= 	FWFormStruct( 2, 'C09' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C09', oStruC09, 'MODEL_C09' )

oView:EnableTitleView( 'VIEW_C09', STR0001 ) //Cadastro de Tipos de Logradouros
oView:CreateHorizontalBox( 'FIELDSC09', 100 )
oView:SetOwnerView( 'VIEW_C09', 'FIELDSC09' )

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

nVerAtu := 1020.01

If nVerEmp < nVerAtu
	aAdd( aHeader, "C09_FILIAL" )
	aAdd( aHeader, "C09_ID" )
	aAdd( aHeader, "C09_UF" )
	aAdd( aHeader, "C09_DESCRI" )
	aAdd( aHeader, "C09_CODIGO" )
	aAdd( aHeader, "C09_CODUF" )
	aAdd( aHeader, "C09_CUFGIA" )
	aAdd( aHeader, "C09_CDGIRJ" )

	aAdd( aBody, { "", "000001", "AC", "ACRE", "12", "019", "01", "12" } )
	aAdd( aBody, { "", "000002", "AL", "ALAGOAS", "27", "027", "02", "27" } )
	aAdd( aBody, { "", "000003", "AM", "AMAZONAS", "13", "043", "04", "13" } )
	aAdd( aBody, { "", "000004", "AP", "AMAPA", "16", "035", "03", "16" } )
	aAdd( aBody, { "", "000005", "BA", "BAHIA", "29", "051", "05", "29" } )
	aAdd( aBody, { "", "000006", "CE", "CEARA", "23", "060", "06", "23" } )
	aAdd( aBody, { "", "000007", "DF", "DISTRITO FEDERAL", "53", "078", "07", "53" } )
	aAdd( aBody, { "", "000008", "ES", "ESPIRITO SANTO", "32", "086", "08", "32" } )
	aAdd( aBody, { "", "000009", "EX", "EXTERIOR", "99", "", "", "" } )
	aAdd( aBody, { "", "000010", "GO", "GOIAS", "52", "108", "10", "52" } )
	aAdd( aBody, { "", "000011", "MA", "MARANHAO", "21", "124", "12", "21" } )
	aAdd( aBody, { "", "000012", "MG", "MINAS GERAIS", "31", "140", "14", "31" } )
	aAdd( aBody, { "", "000013", "MS", "MATO GROSSO DO SUL", "50", "280", "28", "50" } )
	aAdd( aBody, { "", "000014", "MT", "MATO GROSSO", "51", "132", "13", "51" } )
	aAdd( aBody, { "", "000015", "PA", "PARA", "15", "159", "15", "15" } )
	aAdd( aBody, { "", "000016", "PB", "PARAIBA", "25", "167", "16", "25" } )
	aAdd( aBody, { "", "000017", "PE", "PERNAMBUCO", "26", "183", "18", "26" } )
	aAdd( aBody, { "", "000018", "PI", "PIAUI", "22", "191", "19", "22" } )
	aAdd( aBody, { "", "000019", "PR", "PARANA", "41", "175", "17", "41" } )
	aAdd( aBody, { "", "000020", "RJ", "RIO DE JANEIRO", "33", "221", "22", "33" } )
	aAdd( aBody, { "", "000021", "RN", "RIO GRANDE DO NORTE", "24", "205", "20", "24" } )
	aAdd( aBody, { "", "000022", "RO", "RONDONIA", "11", "230", "23", "11" } )
	aAdd( aBody, { "", "000023", "RR", "RORAIMA", "14", "248", "24", "14" } )
	aAdd( aBody, { "", "000024", "RS", "RIO GRANDE DO SUL", "43", "213", "21", "43" } )
	aAdd( aBody, { "", "000025", "SC", "SANTA CATARINA", "42", "256", "25", "42" } )
	aAdd( aBody, { "", "000026", "SE", "SERGIPE", "28", "272", "27", "28" } )
	aAdd( aBody, { "", "000027", "SP", "SAO PAULO", "35", "264", "26", "35" } )
	aAdd( aBody, { "", "000028", "TO", "TOCANTINS", "17", "299", "29", "17" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )