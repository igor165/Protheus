#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                  
#INCLUDE "TAFA157.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA157
Cadastro MVC - Cadastro de Classe de Consumo (Água Canalizada)

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA157()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Classe de Consumo (Água Canalizada)
oBrw:SetAlias( 'C0O')
oBrw:SetMenuDef( 'TAFA157' )
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
Return XFUNMnuTAF( "TAFA157" )
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
Local oStruC0O 	:= 	FWFormStruct( 1, 'C0O' )
Local oModel 	:= 	MPFormModel():New( 'TAFA157' )

oModel:AddFields('MODEL_C0O', /*cOwner*/, oStruC0O)

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA157' )
Local 	oStruC0O 	:= 	FWFormStruct( 2, 'C0O' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0O', oStruC0O, 'MODEL_C0O' )

oView:EnableTitleView( 'VIEW_C0O', STR0001 ) //Cadastro de Classe de Consumo (Água Canalizada)
oView:CreateHorizontalBox( 'FIELDSC0O', 100 )
oView:SetOwnerView( 'VIEW_C0O', 'FIELDSC0O' )

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
	aAdd( aHeader, "C0O_FILIAL" )
	aAdd( aHeader, "C0O_ID" )
	aAdd( aHeader, "C0O_CODIGO" )
	aAdd( aHeader, "C0O_DESCRI" )
	aAdd( aHeader, "C0O_VALIDA" )

	aAdd( aBody, { "", "000001", "00", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL ATE R$ 50,00", "" } )
	aAdd( aBody, { "", "000002", "01", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL DE R$ 50,01 A R$ 100,00", "" } )
	aAdd( aBody, { "", "000003", "02", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL DE R$ 100,01 A R$ 200,00", "" } )
	aAdd( aBody, { "", "000004", "03", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL DE R$ 200,01 A R$ 300,00", "" } )
	aAdd( aBody, { "", "000005", "04", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL DE R$ 300,01 A R$ 400,00", "" } )
	aAdd( aBody, { "", "000006", "05", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL DE R$ 400,01 A R$ 500,00", "" } )
	aAdd( aBody, { "", "000007", "06", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL DE R$ 500,01 A R$ 1000,00", "" } )
	aAdd( aBody, { "", "000008", "07", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL ACIMA DE R$ 1.000,01", "" } )
	aAdd( aBody, { "", "000009", "20", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO COMERCIAL/INDUSTRIAL ATE R$ 50,00", "" } )
	aAdd( aBody, { "", "000010", "21", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO COMERCIAL/INDUSTRIAL DE R$ 50,01 A R$ 100,00", "" } )
	aAdd( aBody, { "", "000011", "22", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO COMERCIAL/INDUSTRIAL DE R$ 100,01 A R$ 200,00", "" } )
	aAdd( aBody, { "", "000012", "23", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO COMERCIAL/INDUSTRIAL DE R$ 200,01 A R$ 300,00", "" } )
	aAdd( aBody, { "", "000013", "24", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO COMERCIAL/INDUSTRIAL DE R$ 300,01 A R$ 400,00", "" } )
	aAdd( aBody, { "", "000014", "25", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO COMERCIAL/INDUSTRIAL DE R$ 400,01 A R$ 500,00", "" } )
	aAdd( aBody, { "", "000015", "26", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO COMERCIAL/INDUSTRIAL DE R$ 500,01 A R$ 1.000,00", "" } )
	aAdd( aBody, { "", "000016", "27", "01 REGISTRO POR DOCUMENTO FISCAL DE CONSUMO COMERCIAL/INDUSTRIAL ACIMA DE R$ 1.000,01", "" } )
	aAdd( aBody, { "", "000017", "80", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO DE ORGAO PUBLICO", "" } )
	aAdd( aBody, { "", "000018", "90", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO ATE R$ 50,00", "" } )
	aAdd( aBody, { "", "000019", "91", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO DE R$ 50,01 A R$ 100,00", "" } )
	aAdd( aBody, { "", "000020", "92", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO DE R$ 100,01 A R$ 200,00", "" } )
	aAdd( aBody, { "", "000021", "93", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO DE R$ 200,01 A R$ 300,00", "" } )
	aAdd( aBody, { "", "000022", "94", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO DE R$ 300,01 A R$ 400,00", "" } )
	aAdd( aBody, { "", "000023", "95", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO DE R$ 400,01 A R$ 500,00", "" } )
	aAdd( aBody, { "", "000024", "96", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO DE R$ 500,01 A R$ 1.000,00", "" } )
	aAdd( aBody, { "", "000025", "97", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO ACIMA DE R$ 1.000,01", "" } )
	aAdd( aBody, { "", "000026", "99", "01 REGISTRO POR DOCUMENTO FISCAL EMITIDO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )