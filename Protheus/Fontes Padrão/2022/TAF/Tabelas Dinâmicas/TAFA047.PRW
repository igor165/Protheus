#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA047.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA047
Cadastro de Instituições Financeiras (Bancos)

@author Marcio Nunes
@since 16/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA047()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Instituições Financeiras (Bancos)
oBrw:SetAlias( 'C1V')
oBrw:SetMenuDef( 'TAFA047' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA047" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC1V 	:= 	FWFormStruct( 1, 'C1V' )
Local oModel 	:= 	MPFormModel():New( 'TAFA047' )

oModel:AddFields('MODEL_C1V', /*cOwner*/, oStruC1V)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Marcio Nunes
@since 16/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA047' )
Local 	oStruC1V 	:= 	FWFormStruct( 2, 'C1V' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C1V', oStruC1V, 'MODEL_C1V' )

oView:EnableTitleView( 'VIEW_C1V', STR0001 ) //Cadastro de Instituições Financeiras (Bancos)
oView:CreateHorizontalBox( 'FIELDSC1V', 100 )
oView:SetOwnerView( 'VIEW_C1V', 'FIELDSC1V' )

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
	aAdd( aHeader, "C1V_FILIAL" )
	aAdd( aHeader, "C1V_ID" )
	aAdd( aHeader, "C1V_CODINT" )
	aAdd( aHeader, "C1V_CODIGO" )
	aAdd( aHeader, "C1V_DESCRI" )

	aAdd( aBody, { "", "000001", "000001", "001", "BANCO DO BRASIL S.A." } )
	aAdd( aBody, { "", "000002", "000002", "003", "BANCO DA AMAZONIA S.A." } )
	aAdd( aBody, { "", "000003", "000003", "004", "BANCO DO NORDESTE DO BRASIL S.A." } )
	aAdd( aBody, { "", "000004", "000004", "012", "BANCO STANDARD DE INVESTIMENTOS S.A." } )
	aAdd( aBody, { "", "000005", "000005", "014", "NATIXIS BRASIL S.A." } )
	aAdd( aBody, { "", "000006", "000006", "019", "BANCO AZTECA DO BRASIL S.A." } )
	aAdd( aBody, { "", "000007", "000007", "021", "BANESTES S.A. BANCO DO ESTADO DO ESPIRITO SANTO" } )
	aAdd( aBody, { "", "000008", "000008", "024", "BANCO DE PERNAMBUCO S.A. . BANDEPE" } )
	aAdd( aBody, { "", "000009", "000009", "025", "BANCO ALFA S.A." } )
	aAdd( aBody, { "", "000010", "000010", "029", "BANCO BANERJ S.A." } )
	aAdd( aBody, { "", "000011", "000011", "031", "BANCO BEG S.A." } )
	aAdd( aBody, { "", "000012", "000012", "033", "BANCO SANTANDER (BRASIL) S.A." } )
	aAdd( aBody, { "", "000013", "000013", "036", "BANCO BRADESCO BBI S.A." } )
	aAdd( aBody, { "", "000014", "000014", "037", "BANCO DO ESTADO DO PARA S.A." } )
	aAdd( aBody, { "", "000015", "000015", "040", "BANCO CARGILL S.A." } )
	aAdd( aBody, { "", "000016", "000016", "041", "BANCO DO ESTADO DO RIO GRANDE DO SUL S.A." } )
	aAdd( aBody, { "", "000017", "000017", "044", "BANCO BVA S.A." } )
	aAdd( aBody, { "", "000018", "000018", "045", "BANCO OPPORTUNITY S.A." } )
	aAdd( aBody, { "", "000019", "000019", "047", "BANCO DO ESTADO DE SERGIPE S.A." } )
	aAdd( aBody, { "", "000020", "000020", "062", "HIPERCARD BANCO MULTIPLO S.A." } )
	aAdd( aBody, { "", "000021", "000021", "063", "BANCO IBI S.A. - BANCO MULTIPLO" } )
	aAdd( aBody, { "", "000022", "000022", "065", "BANCO LEMON S.A." } )
	aAdd( aBody, { "", "000023", "000023", "066", "BANCO MORGAN STANLEY S.A." } )
	aAdd( aBody, { "", "000024", "000024", "069", "BPN BRASIL BANCO MULTIPLO S.A." } )
	aAdd( aBody, { "", "000025", "000025", "070", "BRB - BANCO DE BRASILIA S.A." } )
	aAdd( aBody, { "", "000026", "000026", "072", "BANCO RURAL MAIS S.A." } )
	aAdd( aBody, { "", "000027", "000027", "073", "BB BANCO POPULAR DO BRASIL S.A." } )
	aAdd( aBody, { "", "000028", "000028", "074", "BANCO J. SAFRA S.A." } )
	aAdd( aBody, { "", "000029", "000029", "075", "BANCO CR2 S/A" } )
	aAdd( aBody, { "", "000030", "000030", "076", "BANCO KDB DO BRASIL S.A." } )
	aAdd( aBody, { "", "000031", "000031", "077", "BANCO INTERMEDIUM S/A" } )
	aAdd( aBody, { "", "000032", "000032", "078", "BES INVESTIMENTO DO BRASIL S.A." } )
	aAdd( aBody, { "", "000033", "000033", "079", "JBS BANCO S/A" } )
	aAdd( aBody, { "", "000034", "000034", "081", "CONCORDIA BANCO S.A." } )
	aAdd( aBody, { "", "000035", "000035", "082", "BANCO TOPAZIO S.A." } )
	aAdd( aBody, { "", "000036", "000036", "083", "BANCO DA CHINA BRASIL S.A" } )
	aAdd( aBody, { "", "000037", "000037", "096", "BANCO BM&F DE SERVICOS DE LIQUIDAC.O E CUSTODIA S.A." } )
	aAdd( aBody, { "", "000038", "000038", "104", "CAIXA ECONOMICA FEDERAL" } )
	aAdd( aBody, { "", "000039", "000039", "107", "BANCO BBM S/A" } )
	aAdd( aBody, { "", "000040", "000040", "151", "BANCO NOSSA CAIXA S.A." } )
	aAdd( aBody, { "", "000041", "000041", "184", "BANCO ITAU BBA S.A." } )
	aAdd( aBody, { "", "000042", "000042", "204", "BANCO BRADESCO CART.ES S.A." } )
	aAdd( aBody, { "", "000043", "000043", "208", "BANCO UBS PACTUAL S.A." } )
	aAdd( aBody, { "", "000044", "000044", "212", "BANCO MATONE S.A." } )
	aAdd( aBody, { "", "000045", "000045", "213", "BANCO ARBI S.A." } )
	aAdd( aBody, { "", "000046", "000046", "214", "BANCO DIBENS S.A." } )
	aAdd( aBody, { "", "000047", "000047", "215", "BANCO COMERCIAL E DE INVESTIMENTO SUDAMERIS S.A." } )
	aAdd( aBody, { "", "000048", "000048", "217", "BANCO JOHN DEERE S.A." } )
	aAdd( aBody, { "", "000049", "000049", "218", "BANCO BONSUCESSO S.A." } )
	aAdd( aBody, { "", "000050", "000050", "222", "BANCO CALYON BRASIL S.A." } )
	aAdd( aBody, { "", "000051", "000051", "224", "BANCO FIBRA S.A." } )
	aAdd( aBody, { "", "000052", "000052", "225", "BANCO BRASCAN S.A." } )
	aAdd( aBody, { "", "000053", "000053", "229", "BANCO CRUZEIRO DO SUL S.A." } )
	aAdd( aBody, { "", "000054", "000054", "230", "UNICARD BANCO MULTIPLO S.A." } )
	aAdd( aBody, { "", "000055", "000055", "233", "BANCO GE CAPITAL S.A." } )
	aAdd( aBody, { "", "000056", "000056", "237", "BANCO BRADESCO S.A." } )
	aAdd( aBody, { "", "000057", "000057", "241", "BANCO CLASSICO S.A." } )
	aAdd( aBody, { "", "000058", "000058", "243", "BANCO MAXIMA S.A." } )
	aAdd( aBody, { "", "000059", "000059", "246", "BANCO ABC BRASIL S.A." } )
	aAdd( aBody, { "", "000060", "000060", "248", "BANCO BOAVISTA INTERATLANTICO S.A." } )
	aAdd( aBody, { "", "000061", "000061", "249", "BANCO INVESTCRED UNIBANCO S.A." } )
	aAdd( aBody, { "", "000062", "000062", "250", "BANCO SCHAHIN S.A." } )
	aAdd( aBody, { "", "000063", "000063", "254", "PARANA BANCO S.A." } )
	aAdd( aBody, { "", "000064", "000064", "263", "BANCO CACIQUE S.A." } )
	aAdd( aBody, { "", "000065", "000065", "265", "BANCO FATOR S.A." } )
	aAdd( aBody, { "", "000066", "000066", "266", "BANCO CEDULA S.A." } )
	aAdd( aBody, { "", "000067", "000067", "300", "BANCO DE LA NACION ARGENTINA" } )
	aAdd( aBody, { "", "000068", "000068", "318", "BANCO BMG S.A." } )
	aAdd( aBody, { "", "000069", "000069", "320", "BANCO INDUSTRIAL E COMERCIAL S.A." } )
	aAdd( aBody, { "", "000070", "000070", "341", "BANCO ITAU S.A." } )
	aAdd( aBody, { "", "000071", "000071", "366", "BANCO SOCIETE GENERALE BRASIL S.A." } )
	aAdd( aBody, { "", "000072", "000072", "370", "BANCO WESTLB DO BRASIL S.A." } )
	aAdd( aBody, { "", "000073", "000073", "376", "BANCO J.P. MORGAN S.A." } )
	aAdd( aBody, { "", "000074", "000074", "389", "BANCO MERCANTIL DO BRASIL S.A." } )
	aAdd( aBody, { "", "000075", "000075", "394", "BANCO FINASA BMC S.A." } )
	aAdd( aBody, { "", "000076", "000076", "399", "HSBC BANK BRASIL S.A." } )
	aAdd( aBody, { "", "000077", "000077", "409", "UNIBANCO-UNIAO DE BANCOS BRASILEIROS S.A." } )
	aAdd( aBody, { "", "000078", "000078", "412", "BANCO CAPITAL S.A." } )
	aAdd( aBody, { "", "000079", "000079", "422", "BANCO SAFRA S.A." } )
	aAdd( aBody, { "", "000080", "000080", "453", "BANCO RURAL S.A." } )
	aAdd( aBody, { "", "000081", "000081", "456", "BANCO DE TOKYO-MITSUBISHI UFJ BRASIL S/A" } )
	aAdd( aBody, { "", "000082", "000082", "464", "BANCO SUMITOMO MITSUI BRASILEIRO S.A." } )
	aAdd( aBody, { "", "000083", "000083", "473", "BANCO CAIXA GERAL - BRASIL S.A." } )
	aAdd( aBody, { "", "000084", "000084", "477", "CITIBANK N.A." } )
	aAdd( aBody, { "", "000085", "000085", "479", "BANCO ITAUBANK S.A." } )
	aAdd( aBody, { "", "000086", "000086", "487", "DEUTSCHE BANK S.A." } )
	aAdd( aBody, { "", "000087", "000087", "488", "JPMORGAN CHASE BANK, NATIONAL ASSOCIATION" } )
	aAdd( aBody, { "", "000088", "000088", "492", "ING BANK N.V." } )
	aAdd( aBody, { "", "000089", "000089", "494", "BANCO DE LA REPUBLICA ORIENTAL DEL URUGUAY" } )
	aAdd( aBody, { "", "000090", "000090", "495", "BANCO DE LA PROVINCIA DE BUENOS AIRES" } )
	aAdd( aBody, { "", "000091", "000091", "505", "BANCO CREDIT SUISSE (BRASIL) S.A." } )
	aAdd( aBody, { "", "000092", "000092", "600", "BANCO LUSO BRASILEIRO S.A." } )
	aAdd( aBody, { "", "000093", "000093", "604", "BANCO INDUSTRIAL DO BRASIL S.A." } )
	aAdd( aBody, { "", "000094", "000094", "610", "BANCO VR S.A." } )
	aAdd( aBody, { "", "000095", "000095", "611", "BANCO PAULISTA S.A." } )
	aAdd( aBody, { "", "000096", "000096", "612", "BANCO GUANABARA S.A." } )
	aAdd( aBody, { "", "000097", "000097", "613", "BANCO PECUNIA S.A." } )
	aAdd( aBody, { "", "000098", "000098", "623", "BANCO PANAMERICANO S.A." } )
	aAdd( aBody, { "", "000099", "000099", "626", "BANCO FICSA S.A." } )
	aAdd( aBody, { "", "000100", "000100", "630", "BANCO INTERCAP S.A." } )
	aAdd( aBody, { "", "000101", "000101", "633", "BANCO RENDIMENTO S.A." } )
	aAdd( aBody, { "", "000102", "000102", "634", "BANCO TRIANGULO S.A." } )
	aAdd( aBody, { "", "000103", "000103", "637", "BANCO SOFISA S.A." } )
	aAdd( aBody, { "", "000104", "000104", "638", "BANCO PROSPER S.A." } )
	aAdd( aBody, { "", "000105", "000105", "641", "BANCO ALVORADA S.A." } )
	aAdd( aBody, { "", "000106", "000106", "643", "BANCO PINE S.A." } )
	aAdd( aBody, { "", "000107", "000107", "652", "ITAU UNIBANCO BANCO MULTIPLO S.A." } )
	aAdd( aBody, { "", "000108", "000108", "653", "BANCO INDUSVAL S.A." } )
	aAdd( aBody, { "", "000109", "000109", "654", "BANCO A.J. RENNER S.A." } )
	aAdd( aBody, { "", "000110", "000110", "655", "BANCO VOTORANTIM S.A." } )
	aAdd( aBody, { "", "000111", "000111", "707", "BANCO DAYCOVAL S.A." } )
	aAdd( aBody, { "", "000112", "000112", "719", "BANIF - BANCO INTERNACIONAL DO FUNCHAL (BRASIL), S.A." } )
	aAdd( aBody, { "", "000113", "000113", "721", "BANCO CREDIBEL S.A." } )
	aAdd( aBody, { "", "000114", "000114", "734", "BANCO GERDAU S.A." } )
	aAdd( aBody, { "", "000115", "000115", "735", "BANCO POTTENCIAL S.A." } )
	aAdd( aBody, { "", "000116", "000116", "738", "BANCO MORADA S.A." } )
	aAdd( aBody, { "", "000117", "000117", "739", "BANCO BGN S.A." } )
	aAdd( aBody, { "", "000118", "000118", "740", "BANCO BARCLAYS S.A." } )
	aAdd( aBody, { "", "000119", "000119", "741", "BANCO RIBEIRAO PRETO S.A." } )
	aAdd( aBody, { "", "000120", "000120", "743", "BANCO SEMEAR S.A." } )
	aAdd( aBody, { "", "000121", "000121", "745", "BANCO CITIBANK S.A." } )
	aAdd( aBody, { "", "000122", "000122", "746", "BANCO MODAL S.A." } )
	aAdd( aBody, { "", "000123", "000123", "747", "BANCO RABOBANK INTERNATIONAL BRASIL S.A." } )
	aAdd( aBody, { "", "000124", "000124", "748", "BANCO COOPERATIVO SICREDI S.A." } )
	aAdd( aBody, { "", "000125", "000125", "749", "BANCO SIMPLES S.A." } )
	aAdd( aBody, { "", "000126", "000126", "751", "DRESDNER BANK BRASIL S.A." } )
	aAdd( aBody, { "", "000127", "000127", "752", "BANCO BNP PARIBAS BRASIL S.A." } )
	aAdd( aBody, { "", "000128", "000128", "753", "NBC BANK BRASIL S. A." } )
	aAdd( aBody, { "", "000129", "000129", "756", "BANCO COOPERATIVO DO BRASIL S.A." } )
	aAdd( aBody, { "", "000130", "000130", "757", "BANCO KEB DO BRASIL S.A." } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )