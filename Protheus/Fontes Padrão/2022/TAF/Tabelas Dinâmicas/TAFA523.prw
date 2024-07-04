#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA523.CH"

/*/{Protheus.doc} TAFA523
	Auto contida Tipos de Dep�sitos do FGTS
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Function TAFA523()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription( STR0001 ) //"Tipos de Dep�sitos do FGTS"
oBrw:SetAlias( "V27" )
oBrw:SetMenuDef( "TAFA523" )
V27->( DBSetOrder( 1 ) )
oBrw:Activate()

Return


/*/{Protheus.doc} MenuDef
	Defini��o de menu
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function MenuDef()
Return xFunMnuTAF( "TAFA523",,,, .T. )


/*/{Protheus.doc} ModelDef
	Defini��o de modelo
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
	Defini�o da vis�o do modelo
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
oView:EnableTitleView( "VIEW_V27", STR0001 ) //"Tipos de Dep�sitos do FGTS"
oView:CreateHorizontalBox( "FIELDSV27", 100 )
oView:SetOwnerView( "VIEW_V27", "FIELDSV27" )

Return( oView )


/*/{Protheus.doc} FAtuCont
	Rotina de carga dos dados dos Tipos de Dep�sitos do FGTS de acordo com a vers�o do cliente
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

	aAdd( aBody, { "", "000001", "51", "Dep�sito do FGTS"													, "" } )
	aAdd( aBody, { "", "000002", "52", "Dep�sito do FGTS 13� Sal�rio"										, "" } )
	aAdd( aBody, { "", "000003", "53", "Dep�sito do FGTS Diss�dio"										, "" } )
	aAdd( aBody, { "", "000004", "54", "Dep�sito do FGTS Diss�dio 13� Sal�rio"							, "" } )
	aAdd( aBody, { "", "000005", "55", "Dep�sito do FGTS - Aprendiz"										, "20191231" } )
	aAdd( aBody, { "", "000006", "56", "Dep�sito do FGTS 13� Sal�rio - Aprendiz"							, "20191231" } )
	aAdd( aBody, { "", "000007", "57", "Dep�sito do FGTS Diss�dio - Aprendiz"								, "20191231" } )
	aAdd( aBody, { "", "000008", "58", "Dep�sito do FGTS Diss�dio 13� Sal�rio - Aprendiz"					, "20191231" } )
	aAdd( aBody, { "", "000009", "61", "Dep�sito do FGTS Rescis�rio"										, "" } )
	aAdd( aBody, { "", "000010", "62", "Dep�sito do FGTS Rescis�rio - 13� Sal�rio"						, "" } )
	aAdd( aBody, { "", "000011", "63", "Dep�sito do FGTS Rescis�rio - Aviso Pr�vio"						, "" } )
	aAdd( aBody, { "", "000012", "64", "Dep�sito do FGTS Rescis�rio - Diss�dio"							, "" } )
	aAdd( aBody, { "", "000013", "65", "Dep�sito do FGTS Rescis�rio - Diss�dio 13� Sal�rio"				, "" } )
	aAdd( aBody, { "", "000014", "66", "Dep�sito do FGTS Rescis�rio - Diss�dio Aviso Pr�vio"				, "" } )
	aAdd( aBody, { "", "000015", "67", "Dep�sito do FGTS Rescis�rio - Aprendiz"							, "20191231" } )
	aAdd( aBody, { "", "000016", "68", "Dep�sito do FGTS Rescis�rio - 13� Sal�rio Aprendiz"				, "20191231" } )
	aAdd( aBody, { "", "000017", "69", "Dep�sito do FGTS Rescis�rio - Aviso Pr�vio Aprendiz"				, "20191231" } )
	aAdd( aBody, { "", "000018", "70", "Dep�sito do FGTS Rescis�rio - Diss�dio Aprendiz"					, "20191231" } )
	aAdd( aBody, { "", "000019", "71", "Dep�sito do FGTS Rescis�rio - Diss�dio 13� Sal�rio Aprendiz"		, "20191231" } )
	aAdd( aBody, { "", "000020", "72", "Dep�sito do FGTS Rescis�rio - Diss�dio Aviso Pr�vio Aprendiz"		, "20191231" } )
	aAdd( aBody, { "", "000021", "55", "Dep�sito do FGTS - Aprendiz/Contrato Verde e Amarelo"				, "" } )	
	aAdd( aBody, { "", "000022", "56", "Dep�sito do FGTS 13� Sal�rio - Aprendiz/Contrato Verde e Amarelo"	, "" } )
	aAdd( aBody, { "", "000023", "57", "Dep�sito do FGTS Diss�dio - Aprendiz/Contrato Verde e Amarelo"		, "" } )
	aAdd( aBody, { "", "000024", "58", "Dep�sito do FGTS Diss�dio 13� Sal�rio - Aprendiz/Contrato Verde e Amarelo"		, "" } )
	aAdd( aBody, { "", "000025", "67", "Dep�sito do FGTS Rescis�rio - Aprendiz/Contrato Verde e Amarelo"				, "" } )
	aAdd( aBody, { "", "000026", "68", "Dep�sito do FGTS Rescis�rio 13� Sal�rio - Aprendiz/Contrato Verde e Amarelo"	, "" } )
	aAdd( aBody, { "", "000027", "69", "Dep�sito do FGTS Rescis�rio Aviso Pr�vio - Aprendiz/Contrato Verde e Amarelo"	, "" } )
	aAdd( aBody, { "", "000028", "70", "Dep�sito do FGTS Rescis�rio Diss�dio - Aprendiz/Contrato Verde e Amarelo"	, "" } )
	aAdd( aBody, { "", "000029", "71", "Dep�sito do FGTS Rescis�rio Diss�dio 13� Sal�rio - Aprendiz/Contrato Verde e Amarelo"	, "" } )
	aAdd( aBody, { "", "000030", "72", "Dep�sito do FGTS Rescis�rio Diss�dio Aviso Pr�vio - Aprendiz/Contrato Verde e Amarelo"	, "" } )
	aAdd( aBody, { "", "000031", "73", "Dep�sito do FGTS - Antecipa��o da multa rescis�ria do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000032", "74", "Dep�sito do FGTS 13� Sal�rio - Antecipa��o da multa rescis�ria do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000033", "75", "Dep�sito do FGTS Diss�dio - Antecipa��o da multa rescis�ria do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000034", "76", "Dep�sito do FGTS Diss�dio 13� Sal�rio - Antecipa��o da multa rescis�ria do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000035", "77", "Dep�sito do FGTS Rescis�rio - Antecipa��o da multa rescis�ria do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000036", "78", "Dep�sito do FGTS Rescis�rio 13� Sal�rio - Antecipa��o da multa rescis�ria do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000037", "79", "Dep�sito do FGTS Rescis�rio Aviso Pr�vio - Antecipa��o da multa rescis�ria do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000038", "80", "Dep�sito do Rescis�rio Diss�dio - Antecipa��o da multa rescis�ria do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000039", "81", "Dep�sito do FGTS Rescis�rio Diss�dio 13� Sal�rio - Antecipa��o da multa rescis�ria do FGTS"	, "20201123" } )
	aAdd( aBody, { "", "000040", "82", "Dep�sito do FGTS Rescis�rio Diss�dio Aviso Pr�vio - Antecipa��o da multa rescis�ria do FGTS"	, "20201123" } )


	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
