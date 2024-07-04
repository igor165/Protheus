#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA522.CH"

/*/{Protheus.doc} TAFA522
	Tabela autocontida criada para evento do e-Social S-5003
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@type function
/*/
Function TAFA522()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription( STR0001 ) //"Tipos de Base para Cálculo do FGTS"
oBrw:SetAlias( "V26" )
oBrw:SetMenuDef( "TAFA522" )
V26->( DBSetOrder( 1 ) )
oBrw:Activate()

Return 


/*/{Protheus.doc} MenuDef
	Definição do menu da rotina
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function MenuDef()
Return xFunMnuTAF( "TAFA522",,,, .T. )


/*/{Protheus.doc} ModelDef
	Modelo da rotina 
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function ModelDef()

Local oStruV26 := FwFormStruct( 1, "V26" )
Local oModel   := MpFormModel():New( "TAFA522" )

oModel:AddFields( "MODEL_V26", /*cOwner*/, oStruV26 )
oModel:GetModel ( "MODEL_V26" ):SetPrimaryKey( { "V26_FILIAL", "V26_ID" } )

Return( oModel )


/*/{Protheus.doc} ViewDef
	View da rotina
	@author veronica.toledo
	@since 27/12/2018
	@version 1.0
	@return ${return}, ${return_description}
	@type function
/*/
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA522" )
Local oStruv26 := FwFormStruct( 2, "V26" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_V26", oStruv26, "MODEL_V26" )
oView:EnableTitleView( "VIEW_V26", STR0001 ) //"Tipos de Base para Cálculo do FGTS"
oView:CreateHorizontalBox( "FIELDSV26", 100 )
oView:SetOwnerView( "VIEW_V26", "FIELDSV26" )

Return( oView )


/*/{Protheus.doc} FAtuCont
	Função que carrega os dados da autocontida de acordo com a versão do cliente
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

nVerAtu := 1031.29

If nVerEmp < nVerAtu
	aAdd( aHeader, "V26_FILIAL" )
	aAdd( aHeader, "V26_ID" )
	aAdd( aHeader, "V26_CODIGO" )
	aAdd( aHeader, "V26_DESCRI" )
	aAdd( aHeader, "V26_VALIDA" )

	aAdd( aBody, { "", "000001", "11", "Base de Cálculo do FGTS"																		 , "20210509" } )
	aAdd( aBody, { "", "000002", "12", "Base de Cálculo do FGTS 13° Salário"															 , "20210509" } )
	aAdd( aBody, { "", "000003", "13", "Base de Cálculo do FGTS Dissídio"																 , "20210509" } )
	aAdd( aBody, { "", "000004", "14", "Base de Cálculo do FGTS Dissídio 13º Salário"													 , "20210509" } )
	aAdd( aBody, { "", "000005", "15", "Base de Cálculo do FGTS - Aprendiz"																 , "20191127" } )
	aAdd( aBody, { "", "000006", "16", "Base de Cálculo do FGTS 13° Salário - Aprendiz"													 , "20191127" } )
	aAdd( aBody, { "", "000007", "17", "Base de Cálculo do FGTS Dissídio - Aprendiz"													 , "20191127" } )
	aAdd( aBody, { "", "000008", "18", "Base de Cálculo do FGTS Dissídio 13º Salário - Aprendiz"										 , "20191127" } )
	aAdd( aBody, { "", "000009", "21", "Base de Cálculo do FGTS Rescisório"																 , "20210509" } )
	aAdd( aBody, { "", "000010", "22", "Base de Cálculo do FGTS Rescisório - 13° Salário"												 , "20210509" } )
	aAdd( aBody, { "", "000011", "23", "Base de Cálculo do FGTS Rescisório - Aviso Prévio"												 , "20210509" } )
	aAdd( aBody, { "", "000012", "24", "Base de Cálculo do FGTS Rescisório - Dissídio"													 , "20210509" } )
	aAdd( aBody, { "", "000013", "25", "Base de Cálculo do FGTS Rescisório - Dissídio 13º Salário"										 , "20210509" } )
	aAdd( aBody, { "", "000014", "26", "Base de Cálculo do FGTS Rescisório - Dissídio Aviso Prévio"										 , "20210509" } )
	aAdd( aBody, { "", "000015", "27", "Base de Cálculo do FGTS Rescisório - Aprendiz"													 , "20191127" } )
	aAdd( aBody, { "", "000016", "28", "Base de Cálculo do FGTS Rescisório - 13° Salário Aprendiz"										 , "20191127" } )
	aAdd( aBody, { "", "000017", "29", "Base de Cálculo do FGTS Rescisório - Aviso Prévio Aprendiz"										 , "20191127" } )
	aAdd( aBody, { "", "000018", "30", "Base de Cálculo do FGTS Rescisório - Dissídio Aprendiz"											 , "20191127" } )
	aAdd( aBody, { "", "000019", "31", "Base de Cálculo do FGTS Rescisório - Dissídio 13° Salário Aprendiz"								 , "20191127" } )
	aAdd( aBody, { "", "000020", "32", "Base de Cálculo do FGTS Rescisório - Dissídio Aviso Prévio Aprendiz"						   	 , "20191127" } )
	aAdd( aBody, { "", "000021", "91", "Incidência suspensa em decorrência de decisão judicial"											 , "20210509" } )
	aAdd( aBody, { "", "000022", "17", "Base de Cálculo do FGTS Dissídio - Aprendiz/Contrato Verde e Amarelo"  							 , "20191127" } )
	aAdd( aBody, { "", "000023", "18", "Base de Cálculo do FGTS Dissídio 13º Salário - Aprendiz/Contrato Verde e Amarelo"			   	 , "20191127" } )
	aAdd( aBody, { "", "000024", "30", "Base de Cálculo do FGTS Rescisório Dissídio - Aprendiz/Contrato Verde e Amarelo"				 , "20191127" } )
	aAdd( aBody, { "", "000025", "31", "Base de Cálculo do FGTS Rescisório Dissídio 13° Salário - Aprendiz/Contrato Verde e Amarelo"	 , "20191127" } )
	aAdd( aBody, { "", "000026", "32", "Base de Cálculo do FGTS Rescisório Dissídio Aviso Prévio - Aprendiz/Contrato Verde e Amarelo"	 , "20191127" } )
	aAdd( aBody, { "", "000027", "15", "Base de Cálculo do FGTS - Aprendiz/Contrato Verde e Amarelo"									 , "20210509" } )
	aAdd( aBody, { "", "000028", "16", "Base de Cálculo do FGTS 13° Salário - Aprendiz/Contrato Verde e Amarelo"						 , "20210509" } )
	aAdd( aBody, { "", "000029", "17", "Base de Cálculo do FGTS Dissídio - Aprendiz/Contrato Verde e Amarelo"					         , "20210509" } )
    aAdd( aBody, { "", "000030", "18", " Base de Cálculo do FGTS Dissídio 13º Salário - Aprendiz/Contrato Verde e Amarelo"		         , "20210509" } )
	aAdd( aBody, { "", "000031", "27", "Base de Cálculo do FGTS Rescisório - Aprendiz/Contrato Verde e Amarelo"							 , "20210509" } )
	aAdd( aBody, { "", "000032", "28", "Base de Cálculo do FGTS Rescisório 13° Salário - Aprendiz/Contrato Verde e Amarelo"				 , "20210509" } )
	aAdd( aBody, { "", "000033", "29", "Base de Cálculo do FGTS Rescisório Aviso Prévio - Aprendiz/Contrato Verde e Amarelo"			 , "20210509" } )
	aAdd( aBody, { "", "000034", "30", "Base de Cálculo do FGTS Rescisório - Dissídio Aprendiz Base de Cálculo do FGTS Rescisório Dissídio - Aprendiz/Contrato Verde e Amarelo" , "20210509" } )
    aAdd( aBody, { "", "000035", "31", " Base de Cálculo do FGTS Rescisório Dissídio 13° Salário - Aprendiz/Contrato Verde e Amarelo"	 , "20210509" } )
    aAdd( aBody, { "", "000036", "32", " Base de Cálculo do FGTS Rescisório Dissídio Aviso Prévio - Aprendiz/Contrato Verde e Amarelo"	 , "20210509" } )

	// Novos códigos de acordo com o Leiaute S-1.0  Simplificado

	aAdd( aBody, { "", "000037", "11", "FGTS mensal"	 																			 , "" } )
	aAdd( aBody, { "", "000038", "12", "FGTS 13° salário"	 																		 , "" } )
	aAdd( aBody, { "", "000039", "13", "FGTS dissídio mensal"	 																	 , "" } )
	aAdd( aBody, { "", "000040", "14", "FGTS dissídio 13º salário"	 																 , "" } )
	aAdd( aBody, { "", "000041", "15", "FGTS mensal - Aprendiz/Contrato Verde e Amarelo"	 										 , "" } )
	aAdd( aBody, { "", "000042", "16", "13° salário - Aprendiz/Contrato Verde e Amarelo"	 										 , "" } )
	aAdd( aBody, { "", "000043", "17", "FGTS dissídio mensal - Aprendiz/Contrato Verde e Amarelo"									 , "" } )
	aAdd( aBody, { "", "000044", "18", "FGTS dissídio 13º salário - Aprendiz/Contrato Verde e Amarelo"								 , "" } )
	aAdd( aBody, { "", "000045", "21", "FGTS mês da rescisão"	 																	 , "" } )
	aAdd( aBody, { "", "000046", "22", "FGTS 13° salário rescisório"	 															 , "" } )
	aAdd( aBody, { "", "000047", "23", "FGTS aviso prévio indenizado"	 															 , "" } )
	aAdd( aBody, { "", "000048", "24", "FGTS dissídio mês da rescisão"	 															 , "" } )
	aAdd( aBody, { "", "000049", "25", "FGTS dissídio 13º salário rescisório"	 													 , "" } )
	aAdd( aBody, { "", "000050", "26", "FGTS dissídio aviso prévio indenizado"	 													 , "" } )
	aAdd( aBody, { "", "000051", "27", "FGTS mês da rescisão - Aprendiz/Contrato Verde e Amarelo"	 								 , "" } )
	aAdd( aBody, { "", "000052", "28", "FGTS 13° salário rescisório - Aprendiz/Contrato Verde e Amarelo"							 , "" } )
	aAdd( aBody, { "", "000053", "29", "FGTS aviso prévio indenizado - Aprendiz/Contrato Verde e Amarelo"							 , "" } )
	aAdd( aBody, { "", "000054", "30", "FGTS dissídio mês da rescisão - Aprendiz/Contrato Verde e Amarelo"							 , "" } )
	aAdd( aBody, { "", "000055", "31", "FGTS dissídio 13° salário rescisório Aprendiz/Contrato Verde e Amarelo"	 					 , "" } )
	aAdd( aBody, { "", "000056", "32", "FGTS dissídio aviso prévio indenizado Aprendiz/Contrato Verde e Amarelo"	 				 , "" } )
	aAdd( aBody, { "", "000057", "41", "FGTS mensal - Indenização compensatória do empregado doméstico"	 							 , "" } )
	aAdd( aBody, { "", "000058", "42", "FGTS 13° salário - Indenização compensatória do empregado doméstico"	      				 , "" } )
	aAdd( aBody, { "", "000059", "43", "FGTS dissídio mensal - Indenização compensatória do empregado doméstico"	 				 , "" } )
	aAdd( aBody, { "", "000060", "44", "FGTS dissídio 13º salário - Indenização compensatória do empregado doméstico"	 			 , "" } )
	aAdd( aBody, { "", "000061", "45", "FGTS mês da rescisão - Indenização compensatória do empregado doméstico"	 				 , "" } )
	aAdd( aBody, { "", "000062", "46", "FGTS 13° salário rescisório - Indenização compensatória do empregado doméstico"	 			 , "" } )
	aAdd( aBody, { "", "000063", "47", "FGTS aviso prévio indenizado - Indenização compensatória do empregado doméstico"	 		 , "" } )
	aAdd( aBody, { "", "000064", "48", "FGTS dissídio mês da rescisão - Indenização compensatória do empregado doméstico"	 		 , "" } )
	aAdd( aBody, { "", "000065", "49", "FGTS dissídio 13º salário rescisório - Indenização compensatória do empregado doméstico"	 , "" } )
	aAdd( aBody, { "", "000066", "50", "FGTS dissídio aviso prévio indenizado - Indenização compensatória do empregado doméstico"	 , "" } )
	aAdd( aBody, { "", "000067", "19", "FGTS - Avulsos não Portuários"															     , "" } )

	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
