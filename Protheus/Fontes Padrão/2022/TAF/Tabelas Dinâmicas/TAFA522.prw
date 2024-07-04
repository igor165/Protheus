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

oBrw:SetDescription( STR0001 ) //"Tipos de Base para C�lculo do FGTS"
oBrw:SetAlias( "V26" )
oBrw:SetMenuDef( "TAFA522" )
V26->( DBSetOrder( 1 ) )
oBrw:Activate()

Return 


/*/{Protheus.doc} MenuDef
	Defini��o do menu da rotina
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
oView:EnableTitleView( "VIEW_V26", STR0001 ) //"Tipos de Base para C�lculo do FGTS"
oView:CreateHorizontalBox( "FIELDSV26", 100 )
oView:SetOwnerView( "VIEW_V26", "FIELDSV26" )

Return( oView )


/*/{Protheus.doc} FAtuCont
	Fun��o que carrega os dados da autocontida de acordo com a vers�o do cliente
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

	aAdd( aBody, { "", "000001", "11", "Base de C�lculo do FGTS"																		 , "20210509" } )
	aAdd( aBody, { "", "000002", "12", "Base de C�lculo do FGTS 13� Sal�rio"															 , "20210509" } )
	aAdd( aBody, { "", "000003", "13", "Base de C�lculo do FGTS Diss�dio"																 , "20210509" } )
	aAdd( aBody, { "", "000004", "14", "Base de C�lculo do FGTS Diss�dio 13� Sal�rio"													 , "20210509" } )
	aAdd( aBody, { "", "000005", "15", "Base de C�lculo do FGTS - Aprendiz"																 , "20191127" } )
	aAdd( aBody, { "", "000006", "16", "Base de C�lculo do FGTS 13� Sal�rio - Aprendiz"													 , "20191127" } )
	aAdd( aBody, { "", "000007", "17", "Base de C�lculo do FGTS Diss�dio - Aprendiz"													 , "20191127" } )
	aAdd( aBody, { "", "000008", "18", "Base de C�lculo do FGTS Diss�dio 13� Sal�rio - Aprendiz"										 , "20191127" } )
	aAdd( aBody, { "", "000009", "21", "Base de C�lculo do FGTS Rescis�rio"																 , "20210509" } )
	aAdd( aBody, { "", "000010", "22", "Base de C�lculo do FGTS Rescis�rio - 13� Sal�rio"												 , "20210509" } )
	aAdd( aBody, { "", "000011", "23", "Base de C�lculo do FGTS Rescis�rio - Aviso Pr�vio"												 , "20210509" } )
	aAdd( aBody, { "", "000012", "24", "Base de C�lculo do FGTS Rescis�rio - Diss�dio"													 , "20210509" } )
	aAdd( aBody, { "", "000013", "25", "Base de C�lculo do FGTS Rescis�rio - Diss�dio 13� Sal�rio"										 , "20210509" } )
	aAdd( aBody, { "", "000014", "26", "Base de C�lculo do FGTS Rescis�rio - Diss�dio Aviso Pr�vio"										 , "20210509" } )
	aAdd( aBody, { "", "000015", "27", "Base de C�lculo do FGTS Rescis�rio - Aprendiz"													 , "20191127" } )
	aAdd( aBody, { "", "000016", "28", "Base de C�lculo do FGTS Rescis�rio - 13� Sal�rio Aprendiz"										 , "20191127" } )
	aAdd( aBody, { "", "000017", "29", "Base de C�lculo do FGTS Rescis�rio - Aviso Pr�vio Aprendiz"										 , "20191127" } )
	aAdd( aBody, { "", "000018", "30", "Base de C�lculo do FGTS Rescis�rio - Diss�dio Aprendiz"											 , "20191127" } )
	aAdd( aBody, { "", "000019", "31", "Base de C�lculo do FGTS Rescis�rio - Diss�dio 13� Sal�rio Aprendiz"								 , "20191127" } )
	aAdd( aBody, { "", "000020", "32", "Base de C�lculo do FGTS Rescis�rio - Diss�dio Aviso Pr�vio Aprendiz"						   	 , "20191127" } )
	aAdd( aBody, { "", "000021", "91", "Incid�ncia suspensa em decorr�ncia de decis�o judicial"											 , "20210509" } )
	aAdd( aBody, { "", "000022", "17", "Base de C�lculo do FGTS Diss�dio - Aprendiz/Contrato Verde e Amarelo"  							 , "20191127" } )
	aAdd( aBody, { "", "000023", "18", "Base de C�lculo do FGTS Diss�dio 13� Sal�rio - Aprendiz/Contrato Verde e Amarelo"			   	 , "20191127" } )
	aAdd( aBody, { "", "000024", "30", "Base de C�lculo do FGTS Rescis�rio Diss�dio - Aprendiz/Contrato Verde e Amarelo"				 , "20191127" } )
	aAdd( aBody, { "", "000025", "31", "Base de C�lculo do FGTS Rescis�rio Diss�dio 13� Sal�rio - Aprendiz/Contrato Verde e Amarelo"	 , "20191127" } )
	aAdd( aBody, { "", "000026", "32", "Base de C�lculo do FGTS Rescis�rio Diss�dio Aviso Pr�vio - Aprendiz/Contrato Verde e Amarelo"	 , "20191127" } )
	aAdd( aBody, { "", "000027", "15", "Base de C�lculo do FGTS - Aprendiz/Contrato Verde e Amarelo"									 , "20210509" } )
	aAdd( aBody, { "", "000028", "16", "Base de C�lculo do FGTS 13� Sal�rio - Aprendiz/Contrato Verde e Amarelo"						 , "20210509" } )
	aAdd( aBody, { "", "000029", "17", "Base de C�lculo do FGTS Diss�dio - Aprendiz/Contrato Verde e Amarelo"					         , "20210509" } )
    aAdd( aBody, { "", "000030", "18", " Base de C�lculo do FGTS Diss�dio 13� Sal�rio - Aprendiz/Contrato Verde e Amarelo"		         , "20210509" } )
	aAdd( aBody, { "", "000031", "27", "Base de C�lculo do FGTS Rescis�rio - Aprendiz/Contrato Verde e Amarelo"							 , "20210509" } )
	aAdd( aBody, { "", "000032", "28", "Base de C�lculo do FGTS Rescis�rio 13� Sal�rio - Aprendiz/Contrato Verde e Amarelo"				 , "20210509" } )
	aAdd( aBody, { "", "000033", "29", "Base de C�lculo do FGTS Rescis�rio Aviso Pr�vio - Aprendiz/Contrato Verde e Amarelo"			 , "20210509" } )
	aAdd( aBody, { "", "000034", "30", "Base de C�lculo do FGTS Rescis�rio - Diss�dio Aprendiz Base de C�lculo do FGTS Rescis�rio Diss�dio - Aprendiz/Contrato Verde e Amarelo" , "20210509" } )
    aAdd( aBody, { "", "000035", "31", " Base de C�lculo do FGTS Rescis�rio Diss�dio 13� Sal�rio - Aprendiz/Contrato Verde e Amarelo"	 , "20210509" } )
    aAdd( aBody, { "", "000036", "32", " Base de C�lculo do FGTS Rescis�rio Diss�dio Aviso Pr�vio - Aprendiz/Contrato Verde e Amarelo"	 , "20210509" } )

	// Novos c�digos de acordo com o Leiaute S-1.0  Simplificado

	aAdd( aBody, { "", "000037", "11", "FGTS mensal"	 																			 , "" } )
	aAdd( aBody, { "", "000038", "12", "FGTS 13� sal�rio"	 																		 , "" } )
	aAdd( aBody, { "", "000039", "13", "FGTS diss�dio mensal"	 																	 , "" } )
	aAdd( aBody, { "", "000040", "14", "FGTS diss�dio 13� sal�rio"	 																 , "" } )
	aAdd( aBody, { "", "000041", "15", "FGTS mensal - Aprendiz/Contrato Verde e Amarelo"	 										 , "" } )
	aAdd( aBody, { "", "000042", "16", "13� sal�rio - Aprendiz/Contrato Verde e Amarelo"	 										 , "" } )
	aAdd( aBody, { "", "000043", "17", "FGTS diss�dio mensal - Aprendiz/Contrato Verde e Amarelo"									 , "" } )
	aAdd( aBody, { "", "000044", "18", "FGTS diss�dio 13� sal�rio - Aprendiz/Contrato Verde e Amarelo"								 , "" } )
	aAdd( aBody, { "", "000045", "21", "FGTS m�s da rescis�o"	 																	 , "" } )
	aAdd( aBody, { "", "000046", "22", "FGTS 13� sal�rio rescis�rio"	 															 , "" } )
	aAdd( aBody, { "", "000047", "23", "FGTS aviso pr�vio indenizado"	 															 , "" } )
	aAdd( aBody, { "", "000048", "24", "FGTS diss�dio m�s da rescis�o"	 															 , "" } )
	aAdd( aBody, { "", "000049", "25", "FGTS diss�dio 13� sal�rio rescis�rio"	 													 , "" } )
	aAdd( aBody, { "", "000050", "26", "FGTS diss�dio aviso pr�vio indenizado"	 													 , "" } )
	aAdd( aBody, { "", "000051", "27", "FGTS m�s da rescis�o - Aprendiz/Contrato Verde e Amarelo"	 								 , "" } )
	aAdd( aBody, { "", "000052", "28", "FGTS 13� sal�rio rescis�rio - Aprendiz/Contrato Verde e Amarelo"							 , "" } )
	aAdd( aBody, { "", "000053", "29", "FGTS aviso pr�vio indenizado - Aprendiz/Contrato Verde e Amarelo"							 , "" } )
	aAdd( aBody, { "", "000054", "30", "FGTS diss�dio m�s da rescis�o - Aprendiz/Contrato Verde e Amarelo"							 , "" } )
	aAdd( aBody, { "", "000055", "31", "FGTS diss�dio 13� sal�rio rescis�rio Aprendiz/Contrato Verde e Amarelo"	 					 , "" } )
	aAdd( aBody, { "", "000056", "32", "FGTS diss�dio aviso pr�vio indenizado Aprendiz/Contrato Verde e Amarelo"	 				 , "" } )
	aAdd( aBody, { "", "000057", "41", "FGTS mensal - Indeniza��o compensat�ria do empregado dom�stico"	 							 , "" } )
	aAdd( aBody, { "", "000058", "42", "FGTS 13� sal�rio - Indeniza��o compensat�ria do empregado dom�stico"	      				 , "" } )
	aAdd( aBody, { "", "000059", "43", "FGTS diss�dio mensal - Indeniza��o compensat�ria do empregado dom�stico"	 				 , "" } )
	aAdd( aBody, { "", "000060", "44", "FGTS diss�dio 13� sal�rio - Indeniza��o compensat�ria do empregado dom�stico"	 			 , "" } )
	aAdd( aBody, { "", "000061", "45", "FGTS m�s da rescis�o - Indeniza��o compensat�ria do empregado dom�stico"	 				 , "" } )
	aAdd( aBody, { "", "000062", "46", "FGTS 13� sal�rio rescis�rio - Indeniza��o compensat�ria do empregado dom�stico"	 			 , "" } )
	aAdd( aBody, { "", "000063", "47", "FGTS aviso pr�vio indenizado - Indeniza��o compensat�ria do empregado dom�stico"	 		 , "" } )
	aAdd( aBody, { "", "000064", "48", "FGTS diss�dio m�s da rescis�o - Indeniza��o compensat�ria do empregado dom�stico"	 		 , "" } )
	aAdd( aBody, { "", "000065", "49", "FGTS diss�dio 13� sal�rio rescis�rio - Indeniza��o compensat�ria do empregado dom�stico"	 , "" } )
	aAdd( aBody, { "", "000066", "50", "FGTS diss�dio aviso pr�vio indenizado - Indeniza��o compensat�ria do empregado dom�stico"	 , "" } )
	aAdd( aBody, { "", "000067", "19", "FGTS - Avulsos n�o Portu�rios"															     , "" } )

	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
