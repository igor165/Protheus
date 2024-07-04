#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA523.CH"

/*/{Protheus.doc} TAFA523
	Auto contida Tipos de Depósitos do FGTS
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Function TAFA523()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription( STR0001 ) //"Tipos de Depósitos do FGTS"
oBrw:SetAlias( "V27" )
oBrw:SetMenuDef( "TAFA523" )
V27->( DBSetOrder( 1 ) )
oBrw:Activate()

Return


/*/{Protheus.doc} MenuDef
	Definição de menu
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function MenuDef()
Return xFunMnuTAF( "TAFA523",,,, .T. )


/*/{Protheus.doc} ModelDef
	Definição de modelo
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function ModelDef()

Local oStruV27 := FwFormStruct( 1, "V27" )
Local oModel   := MpFormModel():New( "TAFA523" )

oModel:AddFields( "MODEL_V27", /*cOwner*/, oStruV27 )
oModel:GetModel ( "MODEL_V27" ):SetPrimaryKey( { "V27_FILIAL", "V27_ID" } )

Return( oModel )


/*/{Protheus.doc} ViewDef
	Definião da visão do modelo
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA523" )
Local oStruv27 := FwFormStruct( 2, "V27" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_V27", oStruv27, "MODEL_V27" )
oView:EnableTitleView( "VIEW_V27", STR0001 ) //"Tipos de Depósitos do FGTS"
oView:CreateHorizontalBox( "FIELDSV27", 100 )
oView:SetOwnerView( "VIEW_V27", "FIELDSV27" )

Return( oView )


/*/{Protheus.doc} FAtuCont
	Rotina de carga dos dados dos Tipos de Depósitos do FGTS de acordo com a versão do cliente
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@param nVerEmp, numeric, descricao
	@param nVerAtu, numeric, descricao
	@type function
/*/
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody		:=	{}
Local aRet		:=	{}

nVerAtu := 1031.18

If nVerEmp < nVerAtu
	aAdd( aHeader, "V27_FILIAL" )
	aAdd( aHeader, "V27_ID" )
	aAdd( aHeader, "V27_CODIGO" )
	aAdd( aHeader, "V27_DESCRI" )
	aAdd( aHeader, "V27_VALIDA" )

	aAdd( aBody, { "", "000001", "51", "Depósito do FGTS"													, "" } )
	aAdd( aBody, { "", "000002", "52", "Depósito do FGTS 13° Salário"										, "" } )
	aAdd( aBody, { "", "000003", "53", "Depósito do FGTS Dissídio"										, "" } )
	aAdd( aBody, { "", "000004", "54", "Depósito do FGTS Dissídio 13º Salário"							, "" } )
	aAdd( aBody, { "", "000005", "55", "Depósito do FGTS - Aprendiz"										, "20191231" } )
	aAdd( aBody, { "", "000006", "56", "Depósito do FGTS 13° Salário - Aprendiz"							, "20191231" } )
	aAdd( aBody, { "", "000007", "57", "Depósito do FGTS Dissídio - Aprendiz"								, "20191231" } )
	aAdd( aBody, { "", "000008", "58", "Depósito do FGTS Dissídio 13º Salário - Aprendiz"					, "20191231" } )
	aAdd( aBody, { "", "000009", "61", "Depósito do FGTS Rescisório"										, "" } )
	aAdd( aBody, { "", "000010", "62", "Depósito do FGTS Rescisório - 13° Salário"						, "" } )
	aAdd( aBody, { "", "000011", "63", "Depósito do FGTS Rescisório - Aviso Prévio"						, "" } )
	aAdd( aBody, { "", "000012", "64", "Depósito do FGTS Rescisório - Dissídio"							, "" } )
	aAdd( aBody, { "", "000013", "65", "Depósito do FGTS Rescisório - Dissídio 13º Salário"				, "" } )
	aAdd( aBody, { "", "000014", "66", "Depósito do FGTS Rescisório - Dissídio Aviso Prévio"				, "" } )
	aAdd( aBody, { "", "000015", "67", "Depósito do FGTS Rescisório - Aprendiz"							, "20191231" } )
	aAdd( aBody, { "", "000016", "68", "Depósito do FGTS Rescisório - 13° Salário Aprendiz"				, "20191231" } )
	aAdd( aBody, { "", "000017", "69", "Depósito do FGTS Rescisório - Aviso Prévio Aprendiz"				, "20191231" } )
	aAdd( aBody, { "", "000018", "70", "Depósito do FGTS Rescisório - Dissídio Aprendiz"					, "20191231" } )
	aAdd( aBody, { "", "000019", "71", "Depósito do FGTS Rescisório - Dissídio 13° Salário Aprendiz"		, "20191231" } )
	aAdd( aBody, { "", "000020", "72", "Depósito do FGTS Rescisório - Dissídio Aviso Prévio Aprendiz"		, "20191231" } )
	aAdd( aBody, { "", "000021", "55", "Depósito do FGTS - Aprendiz/Contrato Verde e Amarelo"				, "" } )	
	aAdd( aBody, { "", "000022", "56", "Depósito do FGTS 13° Salário - Aprendiz/Contrato Verde e Amarelo"	, "" } )
	aAdd( aBody, { "", "000023", "57", "Depósito do FGTS Dissídio - Aprendiz/Contrato Verde e Amarelo"		, "" } )
	aAdd( aBody, { "", "000024", "58", "Depósito do FGTS Dissídio 13º Salário - Aprendiz/Contrato Verde e Amarelo"		, "" } )
	aAdd( aBody, { "", "000025", "67", "Depósito do FGTS Rescisório - Aprendiz/Contrato Verde e Amarelo"				, "" } )
	aAdd( aBody, { "", "000026", "68", "Depósito do FGTS Rescisório 13° Salário - Aprendiz/Contrato Verde e Amarelo"	, "" } )
	aAdd( aBody, { "", "000027", "69", "Depósito do FGTS Rescisório Aviso Prévio - Aprendiz/Contrato Verde e Amarelo"	, "" } )
	aAdd( aBody, { "", "000028", "70", "Depósito do FGTS Rescisório Dissídio - Aprendiz/Contrato Verde e Amarelo"	, "" } )
	aAdd( aBody, { "", "000029", "71", "Depósito do FGTS Rescisório Dissídio 13° Salário - Aprendiz/Contrato Verde e Amarelo"	, "" } )
	aAdd( aBody, { "", "000030", "72", "Depósito do FGTS Rescisório Dissídio Aviso Prévio - Aprendiz/Contrato Verde e Amarelo"	, "" } )
	aAdd( aBody, { "", "000031", "73", "Depósito do FGTS - Antecipação da multa rescisória do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000032", "74", "Depósito do FGTS 13° Salário - Antecipação da multa rescisória do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000033", "75", "Depósito do FGTS Dissídio - Antecipação da multa rescisória do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000034", "76", "Depósito do FGTS Dissídio 13º Salário - Antecipação da multa rescisória do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000035", "77", "Depósito do FGTS Rescisório - Antecipação da multa rescisória do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000036", "78", "Depósito do FGTS Rescisório 13° Salário - Antecipação da multa rescisória do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000037", "79", "Depósito do FGTS Rescisório Aviso Prévio - Antecipação da multa rescisória do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000038", "80", "Depósito do Rescisório Dissídio - Antecipação da multa rescisória do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000039", "81", "Depósito do FGTS Rescisório Dissídio 13º Salário - Antecipação da multa rescisória do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000040", "82", "Depósito do FGTS Rescisório Dissídio Aviso Prévio - Antecipação da multa rescisória do FGTS"	, "20201123" } )


	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
