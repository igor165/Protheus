#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA022.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA022
Cadastro MVC de Classe de consumo - Comunicação e Telecomunicação

@author Fabio V. Santana
@since 10/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA022()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro de Classe de consumo - Comunicação e Telecomunicação
oBrw:SetAlias( 'C0M')
oBrw:SetMenuDef( 'TAFA022' )
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
Return XFUNMnuTAF( "TAFA022" )
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
Local oStruC0M 	:= 	FWFormStruct( 1, 'C0M' )
Local oModel 	:= 	MPFormModel():New( 'TAFA022' )

oModel:AddFields('MODEL_C0M', /*cOwner*/, oStruC0M)

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA022' )
Local 	oStruC0M 	:= 	FWFormStruct( 2, 'C0M' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0M', oStruC0M, 'MODEL_C0M' )

oView:EnableTitleView( 'VIEW_C0M', STR0001 ) //Cadastro de Classe de consumo - Comunicação e Telecomunicação
oView:CreateHorizontalBox( 'FIELDSC0M', 100 )
oView:SetOwnerView( 'VIEW_C0M', 'FIELDSC0M' )

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
	aAdd( aHeader, "C0M_FILIAL" )
	aAdd( aHeader, "C0M_ID" )
	aAdd( aHeader, "C0M_CODIGO" )
	aAdd( aHeader, "C0M_DESCRI" )
	aAdd( aHeader, "C0M_VALIDA" )

	aAdd( aBody, { "", "000001", "00", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL/PESSOA FISICA ATE R$ 50,00", "" } )
	aAdd( aBody, { "", "000002", "01", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL/PESSOA FISICA DE R$ 50,01 A R$ 100,00", "" } )
	aAdd( aBody, { "", "000003", "02", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL/PESSOA FISICA DE R$ 100,01 A R$ 200,00", "" } )
	aAdd( aBody, { "", "000004", "03", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL/PESSOA FISICA DE R$ 200,01 A R$ 300,00", "" } )
	aAdd( aBody, { "", "000005", "04", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL/PESSOA FISICA DE R$ 300,01 A R$ 400,00", "" } )
	aAdd( aBody, { "", "000006", "05", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL/PESSOA FISICA DE R$ 400,01 A R$ 500,00", "" } )
	aAdd( aBody, { "", "000007", "06", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO RESIDENCIAL/PESSOA FISICA DE R$ 500,01 A R$ 1000,00", "" } )
	aAdd( aBody, { "", "000008", "07", "01 REGISTRO POR DOCUMENTO FISCAL DE CONSUMO RESIDENCIAL/PESSOA FISICA ACIMA DE R$ 1.000,01", "" } )
	aAdd( aBody, { "", "000009", "10", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO COMERCIAL/INDUSTRIAL ATE R$ 50,00", "" } )
	aAdd( aBody, { "", "000010", "11", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO COMERCIAL/INDUSTRIAL DE R$ 50,01 A R$ 100,00", "" } )
	aAdd( aBody, { "", "000011", "12", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO COMERCIAL/INDUSTRIAL DE R$ 100,01 A R$ 200,00", "" } )
	aAdd( aBody, { "", "000012", "13", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO COMERCIAL/INDUSTRIAL DE R$ 200,01 A R$ 300,00", "" } )
	aAdd( aBody, { "", "000013", "14", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO COMERCIAL/INDUSTRIAL DE R$ 300,01 A R$ 400,00", "" } )
	aAdd( aBody, { "", "000014", "15", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO COMERCIAL/INDUSTRIAL DE R$ 400,01 A R$ 500,00", "" } )
	aAdd( aBody, { "", "000015", "16", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO COMERCIAL/INDUSTRIAL DE R$ 500,01 A R$ 1.000,00", "" } )
	aAdd( aBody, { "", "000016", "17", "01 REGISTRO POR DOCUMENTO FISCAL DE CONSUMO COMERCIAL/INDUSTRIAL ACIMA DE R$ 1.000,01", "" } )
	aAdd( aBody, { "", "000017", "70", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO DO PODER PUBLICO ATE R$ 50,00", "" } )
	aAdd( aBody, { "", "000018", "71", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO PODER PUBLICO DE R$ 50,01 A R$ 100,00", "" } )
	aAdd( aBody, { "", "000019", "72", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO PODER PUBLICO DE R$ 100,01 A R$ 200,00", "" } )
	aAdd( aBody, { "", "000020", "73", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO PODER PUBLICO DE R$ 200,01 A R$ 300,00", "" } )
	aAdd( aBody, { "", "000021", "74", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO PODER PUBLICO DE R$ 300,01 A R$ 400,00", "" } )
	aAdd( aBody, { "", "000022", "75", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO PODER PUBLICO DE R$ 400,01 A R$ 500,00", "" } )
	aAdd( aBody, { "", "000023", "76", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE CONSUMO PODER PUBLICO DE R$ 500,01 A R$ 1.000,00", "" } )
	aAdd( aBody, { "", "000024", "77", "01 REGISTRO POR DOCUMENTO FISCAL DE CONSUMO PODER PUBLICO ACIMA DE R$ 1.000,01", "" } )
	aAdd( aBody, { "", "000025", "78", "01 REGISTRO POR DOCUMENTO FISCAL DE CONSUMO DE ORGAO PUBLICO ISENTO DO ICMS", "" } )
	aAdd( aBody, { "", "000026", "79", "01 REGISTRO POR DOCUMENTO FISCAL DE CONSUMO DE ORGAOS SEMIPUBLICOS", "" } )
	aAdd( aBody, { "", "000027", "90", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO ATE R$ 50,00", "" } )
	aAdd( aBody, { "", "000028", "91", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO DE R$ 50,01 A R$ 100,00", "" } )
	aAdd( aBody, { "", "000029", "92", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO DE R$ 100,01 A R$ 200,00", "" } )
	aAdd( aBody, { "", "000030", "93", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO DE R$ 200,01 A R$ 300,00", "" } )
	aAdd( aBody, { "", "000031", "94", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO DE R$ 300,01 A R$ 400,00", "" } )
	aAdd( aBody, { "", "000032", "95", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO DE R$ 400,01 A R$ 500,00", "" } )
	aAdd( aBody, { "", "000033", "96", "01 REGISTRO CONSOLIDANDO OS DOCUMENTOS DE OUTROS TIPOS DE CONSUMO DE R$ 500,01 A R$ 1.000,00", "" } )
	aAdd( aBody, { "", "000034", "97", "01 REGISTRO POR DOCUMENTO FISCAL DE OUTROS TIPOS DE CONSUMO ACIMA DE R$ 1.000,01", "" } )
	aAdd( aBody, { "", "000035", "99", "01 REGISTRO POR DOCUMENTO FISCAL EMITIDO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )