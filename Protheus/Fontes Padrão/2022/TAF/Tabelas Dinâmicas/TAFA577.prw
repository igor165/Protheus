#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA577.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA577
******* FONTE DESCONTINUADO - TABELA 21 ESTA NO FONTE TAFA234 *******
Tabela 21 - C�digos de Incid�ncia Tribut�ria da Rubrica para o IRRF

@author Jos� Riquelmo
@since 03/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA577()
/*
	Local oBrw := FWmBrowse():New()

	oBrw:SetDescription(STR0001)    //"C�digos de Incid�ncia Tribut�ria da Rubrica para o IRRF"
	oBrw:SetAlias( 'V5X')
	oBrw:SetMenuDef('TAFA577')
	oBrw:Activate()
*/
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Jos� Riquelmo
@since 03/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA577" )
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Jos� Riquelmo
@since 03/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Static Function ModelDef()

	Local oStruV5X	:= FwFormStruct( 1, "V5X" )
	Local oModel   	:= MpFormModel():New( "TAFA577" )

	oModel:AddFields( "MODEL_V5X", /*cOwner*//*, oStruV5X )
	oModel:GetModel ( "MODEL_V5X" ):SetPrimaryKey( { "V5X_FILIAL", "V5X_ID" } )

Return oModel
*/
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Jos� Riquelmo
@since 03/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Static Function ViewDef()

	Local   oModel      :=  FWLoadModel( 'TAFA577' )
	Local   oStruV5X    :=  FWFormStruct( 2, 'V5X' )
	Local   oView       :=  FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_V5X', oStruV5X, 'MODEL_V5X' )

	oView:EnableTitleView( 'VIEW_V5X', STR0001 )    //"C�digos de Incid�ncia Tribut�ria da Rubrica para o IRRF"
	oView:CreateHorizontalBox( 'FIELDSV5X', 100 )
	oView:SetOwnerView( 'VIEW_V5X', 'FIELDSV5X' )

Return oView
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@author Jos� Riquelmo
@since 03/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
/*
Static Function FAtuCont( nVerEmp, nVerAtu )

	Local aHeader	:=	{}
	Local aBody		:=	{}
	Local aRet		:=	{}

	nVerAtu := 1032.08

	If nVerEmp < nVerAtu

		aAdd( aHeader, "V5X_FILIAL" )
		aAdd( aHeader, "V5X_ID" )
		aAdd( aHeader, "V5X_CODIGO" )
		aAdd( aHeader, "V5X_DESCRI" )
		aAdd( aHeader, "V5X_VALIDA" )
		aAdd( aHeader, "V5X_ALTCON" )
		
		aAdd( aBody, { "", "000001", "0" 	, "RENDIMENTO N�O TRIBUT�VEL" 																																								, ""		} )
		aAdd( aBody, { "", "000002", "1" 	, "RENDIMENTO N�O TRIBUT�VEL EM FUN��O DE ACORDOS INTERNACIONAIS DE BITRIBUTA��O" 																											, ""		} )
		aAdd( aBody, { "", "000003", "9" 	, "VERBA TRANSITADA PELA FOLHA DE PAGAMENTO DE NATUREZA DIVERSA DE RENDIMENTO OU RETEN��O/ISEN��O/DEDU��O DE IR (EXEMPLO: DESCONTO DE CONV�NIO FARM�CIA, DESCONTO DE CONSIGNA��ES, ETC.)" 	, ""		} )
		
		// Rendimento tribut�vel (base de c�lculo do IR)
		aAdd( aBody, { "", "000004", "11" 	, "REMUNERA��O MENSAL"  																																									, ""		} )
		aAdd( aBody, { "", "000005", "12" 	, "13� SAL�RIO"  																																											, ""		} )
		aAdd( aBody, { "", "000006", "13" 	, "F�RIAS"  																																												, ""		} )
		aAdd( aBody, { "", "000007", "14" 	, "PLR"  																																													, ""		} )
		aAdd( aBody, { "", "000008", "15" 	, "RENDIMENTOS RECEBIDOS ACUMULADAMENTE - RRA"  																																			, "20210430"} )

		// Reten��o do IRRF efetuada sobre
		aAdd( aBody, { "", "000009", "31" 	, "REMUNERA��O MENSAL"  																																									, ""		} )
		aAdd( aBody, { "", "000010", "32" 	, "13� SAL�RIO"  																																											, ""		} )
		aAdd( aBody, { "", "000011", "33" 	, "F�RIAS"  																																												, ""		} )
		aAdd( aBody, { "", "000012", "34" 	, "PLR"  																																													, ""		} )
		aAdd( aBody, { "", "000013", "35" 	, "RENDIMENTOS RECEBIDOS ACUMULADAMENTE - RRA"  																																			, "20210430"} )

		// Dedu��o do rendimento tribut�vel do IRRF
		aAdd( aBody, { "", "000014", "41" 	, "PREVID�NCIA SOCIAL OFICIAL - PSO - REMUNERA��O MENSAL"  																																	, ""		} )
		aAdd( aBody, { "", "000015", "42" 	, "PSO - 13� SAL�RIO"  																																										, ""		} )
		aAdd( aBody, { "", "000016", "43" 	, "PSO - F�RIAS"  																																											, ""		} )
		aAdd( aBody, { "", "000017", "44" 	, "PSO - RRA"  																																												, "20210430"} )
		aAdd( aBody, { "", "000018", "46" 	, "PREVID�NCIA PRIVADA - SAL�RIO MENSAL"  																																					, "20230116", 1032.08} )
		aAdd( aBody, { "", "000019", "47" 	, "PREVID�NCIA PRIVADA - 13� SAL�RIO"  																																						, "20230116", 1032.08} )
		aAdd( aBody, { "", "000020", "48" 	, "PREVID�NCIA PRIVADA - F�RIAS"  																																							, "20230116", 1032.08} )
		aAdd( aBody, { "", "000021", "51" 	, "PENS�O ALIMENT�CIA - REMUNERA��O MENSAL"  																																				, ""		} )
		aAdd( aBody, { "", "000022", "52" 	, "PENS�O ALIMENT�CIA - 13� SAL�RIO"  																																						, ""		} )
		aAdd( aBody, { "", "000023", "53" 	, "PENS�O ALIMENT�CIA - F�RIAS"  																																							, ""		} )
		aAdd( aBody, { "", "000024", "54" 	, "PENS�O ALIMENT�CIA - PLR"  																																								, ""		} )
		aAdd( aBody, { "", "000025", "55" 	, "PENS�O ALIMENT�CIA - RRA"  																																								, "20210430"} )
		aAdd( aBody, { "", "000026", "61" 	, "FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - REMUNERA��O MENSAL"  																												, ""		} )
		aAdd( aBody, { "", "000027", "62" 	, "FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - 13� SAL�RIO"  																														, ""		} )
		aAdd( aBody, { "", "000028", "63" 	, "FUNDA��O DE PREVID�NCIA COMPLEMENTAR DO SERVIDOR P�BLICO - REMUNERA��O MENSAL"  																											, ""		} )
		aAdd( aBody, { "", "000029", "64" 	, "FUNDA��O DE PREVID�NCIA COMPLEMENTAR DO SERVIDOR P�BLICO - 13� SAL�RIO" 																													, ""		} )
		aAdd( aBody, { "", "000030", "65" 	, "FUNDA��O DE PREVID�NCIA COMPLEMENTAR DO SERVIDOR P�BLICO - F�RIAS"  																														, ""		} )
		aAdd( aBody, { "", "000031", "66" 	, "FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - F�RIAS"  																															, ""		} )
		aAdd( aBody, { "", "000032", "67" 	, "PLANO PRIVADO COLETIVO DE ASSIST�NCIA � SA�DE"  																																			, ""		} )

		//RENDIMENTO N�O TRIBUT�VEL OU ISENTO DO IRRF
		aAdd( aBody, { "", "000033", "70" 	, "PARCELA ISENTA 65 ANOS - REMUNERA��O MENSAL"  																																			, ""		} )
		aAdd( aBody, { "", "000034", "71" 	, "PARCELA ISENTA 65 ANOS - 13� SAL�RIO"  																																					, ""		} )
		aAdd( aBody, { "", "000035", "72" 	, "DI�RIAS"  																																												, ""		} )
		aAdd( aBody, { "", "000036", "73" 	, "AJUDA DE CUSTO"  																																										, ""		} )
		aAdd( aBody, { "", "000037", "74" 	, "INDENIZA��O E RESCIS�O DE CONTRATO, INCLUSIVE A T�TULO DE PDV E ACIDENTES DE TRABALHO"  																									, ""		} )
		aAdd( aBody, { "", "000038", "75" 	, "ABONO PECUNI�RIO"  																																										, ""		} )
		aAdd( aBody, { "", "000039", "76" 	, "RENDIMENTO DE BENEFICI�RIO COM MOL�STIA GRAVE OU ACIDENTE EM SERVI�O REMUNERA��O MENSAL"  																								, ""		} )
		aAdd( aBody, { "", "000040", "77" 	, "RENDIMENTO DE BENEFICI�RIO COM MOL�STIA GRAVE OU ACIDENTE EM SERVI�O - 13� SAL�RIO"  																									, ""		} )
		aAdd( aBody, { "", "000041", "78" 	, "VALORES PAGOS A TITULAR OU S�CIO DE MICROEMPRESA OU EMPRESA DE PEQUENO PORTE, EXCETO PR�-LABORE E ALUGU�IS"  																			, "20210430"} )
		aAdd( aBody, { "", "000042", "700"	, "AUX�LIO MORADIA"  																																										, ""		} )
		aAdd( aBody, { "", "000043", "701"	, "PARTE N�O TRIBUT�VEL DO VALOR DE SERVI�O DE TRANSPORTE DE PASSAGEIROS OU CARGAS"  																										, ""		} )		
		aAdd( aBody, { "", "000044", "79" 	, "OUTRAS ISEN��ES (O NOME DA RUBRICA DEVE SER CLARO PARA IDENTIFICA��O DA NATUREZA DOS VALORES)"  																							, ""		} )

		//DEMANDAS JUDICIAIS		
		aAdd( aBody, { "", "000045", "81" 	, "DEP�SITO JUDICIAL"  																																										, "20210430"} )
		aAdd( aBody, { "", "000046", "82" 	, "COMPENSA��O JUDICIAL DO ANO-CALEND�RIO"  																																				, "20210430"} )
		aAdd( aBody, { "", "000047", "83" 	, "COMPENSA��O JUDICIAL DE ANOS ANTERIORES"  																																				, "20210430"} )

		// EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUT�VEL (BASE DE C�LCULO DO IR)
		aAdd( aBody, { "", "000048", "91" 	, "REMUNERA��O MENSAL"  																																									, "20210430"} )
		aAdd( aBody, { "", "000049", "92" 	, "13� SAL�RIO"  																																											, "20210430"} )
		aAdd( aBody, { "", "000050", "93" 	, "F�RIAS"  																																												, "20210430"} )
		aAdd( aBody, { "", "000051", "94" 	, "PLR"  																																													, "20210430"} )
		aAdd( aBody, { "", "000052", "95" 	, "RRA"  																																													, "20210430"} )
		aAdd( aBody, { "", "000053", "9011" , "REMUNERA��O MENSAL"  																																									, ""		} )
		aAdd( aBody, { "", "000054", "9012" , "13� SAL�RIO"  																																											, ""		} )
		aAdd( aBody, { "", "000055", "9013" , "F�RIAS"  																																												, ""		} )
		aAdd( aBody, { "", "000056", "9014" , "PLR"  																																													, ""		} )

		// EXIGIBILIDADE SUSPENSA - RETEN��O DO IRRF EFETUADA SOBRE
		aAdd( aBody, { "", "000057", "9031" , "REMUNERA��O MENSAL"  																																									, ""		} )
		aAdd( aBody, { "", "000058", "9032" , "13� SAL�RIO" 																																							 				, ""		} )
		aAdd( aBody, { "", "000059", "9033" , "F�RIAS"  																																												, ""		} )
		aAdd( aBody, { "", "000060", "9034" , "PLR"  																																													, ""		} )
		aAdd( aBody, { "", "000061", "9831" , "DEP�SITO JUDICIAL - MENSAL"  																																							, ""		} )
		aAdd( aBody, { "", "000062", "9832" , "DEP�SITO JUDICIAL - 13� SAL�RIO"  																																						, ""		} )
		aAdd( aBody, { "", "000063", "9833" , "DEP�SITO JUDICIAL - F�RIAS"  																																							, ""		} )
		aAdd( aBody, { "", "000064", "9834" , "DEP�SITO JUDICIAL - PLR"  																																								, ""		} )
		
		//EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE C�LCULO DO IRRF
		aAdd( aBody, { "", "000065", "9041" , "PREVID�NCIA SOCIAL OFICIAL - PSO - REMUNERA��O MENSAL"  																																	, ""		} )
		aAdd( aBody, { "", "000066", "9042" , "PSO - 13� SAL�RIO"  																																										, ""		} )
		aAdd( aBody, { "", "000067", "9043" , "PSO - F�RIAS"  																																											, ""		} )
		aAdd( aBody, { "", "000068", "9046" , "PREVID�NCIA PRIVADA - SAL�RIO MENSAL"  																																					, "20230116", 1032.08} )
		aAdd( aBody, { "", "000069", "9047" , "PREVID�NCIA PRIVADA - 13� SAL�RIO"  																																						, "20230116", 1032.08} )
		aAdd( aBody, { "", "000070", "9048" , "PREVID�NCIA PRIVADA - F�RIAS"  																																							, "20230116", 1032.08} )
		aAdd( aBody, { "", "000071", "9051" , "PENS�O ALIMENT�CIA - REMUNERA��O MENSAL"  																																				, ""		} )
		aAdd( aBody, { "", "000072", "9052" , "PENS�O ALIMENT�CIA - 13� SAL�RIO"  																																						, ""		} )
		aAdd( aBody, { "", "000073", "9053" , "PENS�O ALIMENT�CIA - F�RIAS"  																																							, ""		} )
		aAdd( aBody, { "", "000074", "9054" , "PENS�O ALIMENT�CIA - PLR"  																																								, ""		} )
		aAdd( aBody, { "", "000075", "9061" , "FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - REMUNERA��O MENSAL"  																												, ""		} )
		aAdd( aBody, { "", "000076", "9062" , "FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - 13� SAL�RIO"  																														, ""		} )
		aAdd( aBody, { "", "000077", "9063" , "FUNDA��O DE PREVID�NCIA COMPLEMENTAR DO SERVIDOR P�BLICO - REMUNERA��O MENSAL"  																											, ""		} )
		aAdd( aBody, { "", "000078", "9064" , "FUNDA��O DE PREVID�NCIA COMPLEMENTAR DO SERVIDOR P�BLICO - 13� SAL�RIO"  																												, ""		} )
		aAdd( aBody, { "", "000079", "9065" , "FUNDA��O DE PREVID�NCIA COMPLEMENTAR DO SERVIDOR P�BLICO - F�RIAS"  																														, ""		} )
		aAdd( aBody, { "", "000080", "9066" , "FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - F�RIAS"  																															, ""		} )
		aAdd( aBody, { "", "000081", "9067" , "PLANO PRIVADO COLETIVO DE ASSIST�NCIA � SA�DE" 																																			, ""		} )
		
		//COMPENSA��O JUDICIAL
		aAdd( aBody, { "", "000082", "9082" , "COMPENSA��O JUDICIAL DO ANO-CALEND�RIO"  																																				, ""		} )
		aAdd( aBody, { "", "000083", "9083" , "COMPENSA��O JUDICIAL DE ANOS ANTERIORES"  																																				, ""		} )

		//NOVAS INCLUS�ES LEIAUTE 1.0 - RENDIMENTO N�O TRIBUT�VEL OU ISENTO DO IRRF
		aAdd( aBody, { "", "000084", "7900"	, "VERBA TRANSITADA PELA FOLHA DE PAGAMENTO DE NATUREZA DIVERSA DE RENDIMENTO OU RETEN��O/ISEN��O/DEDU��O DE IR (EXEMPLO: DESCONTO DE CONV�NIO FARM�CIA, DESCONTO DE CONSIGNA��ES, ETC.)"	, "" 		} )
		
		//NOVAS INCLUS�ES LEIAUTE 1.0 - C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES
		aAdd( aBody, { "", "000085", "7950" , "RENDIMENTO N�O TRIBUT�VEL"  																																								, ""		} )
		aAdd( aBody, { "", "000086", "7951" , "RENDIMENTO N�O TRIBUT�VEL EM FUN��O DE ACORDOS INTERNACIONAIS DE BITRIBUTA��O" 																											, ""		} )
		aAdd( aBody, { "", "000087", "7952" , "RENDIMENTO TRIBUT�VEL - RRA"  																																							, ""		} )
		aAdd( aBody, { "", "000088", "7953" , "RETEN��O DE IR - RRA"  																																									, ""		} )
		aAdd( aBody, { "", "000089", "7954" , "PREVID�NCIA SOCIAL OFICIAL - RRA"  																																						, ""		} )
		aAdd( aBody, { "", "000090", "7955" , "PENS�O ALIMENT�CIA - RRA"  																																								, ""		} )
		aAdd( aBody, { "", "000091", "7956" , "VALORES PAGOS A TITULAR OU S�CIO DE MICROEMPRESA OU EMPRESA DE PEQUENO PORTE, EXCETO PR�-LABORE E ALUGU�IS" 																				, ""		} )
		aAdd( aBody, { "", "000092", "7957" , "DEP�SITO JUDICIAL"  																																										, ""		} )
		aAdd( aBody, { "", "000093", "7958" , "COMPENSA��O JUDICIAL DO ANO-CALEND�RIO"  																																				, ""		} )
		aAdd( aBody, { "", "000094", "7959" , "COMPENSA��O JUDICIAL DE ANOS ANTERIORES"  																																				, ""		} )
		aAdd( aBody, { "", "000095", "7960" , "EXIGIBILIDADE SUSPENSA - REMUNERA��O MENSAL"  																																			, ""		} )
		aAdd( aBody, { "", "000096", "7961" , "EXIGIBILIDADE SUSPENSA - 13� SAL�RIOL"  																																					, ""		} )
		aAdd( aBody, { "", "000097", "7962" , "EXIGIBILIDADE SUSPENSA - F�RIAS"  																																						, ""		} )
		aAdd( aBody, { "", "000098", "7963" , "EXIGIBILIDADE SUSPENSA - PLR"  																																							, ""		} )
		aAdd( aBody, { "", "000099", "7964" , "EXIGIBILIDADE SUSPENSA - RRA"  																																							, ""		} )

		//NOTA T�CNICA S-1.0 N� 06/2022
		aAdd( aBody, { "", "000100", "46" 	, "PREVID�NCIA COMPLEMENTAR- SAL�RIO MENSAL"  																																				, ""		, 1032.08} )
		aAdd( aBody, { "", "000101", "47" 	, "PREVID�NCIA COMPLEMENTAR - 13� SAL�RIO"  																																				, ""		, 1032.08} )
		aAdd( aBody, { "", "000102", "48" 	, "PREVID�NCIA COMPLEMENTAR - F�RIAS"  																																						, ""		, 1032.08} )
		aAdd( aBody, { "", "000103", "9046" , "PREVID�NCIA COMPLEMENTAR - SAL�RIO MENSAL"  																																				, ""		, 1032.08} )
		aAdd( aBody, { "", "000104", "9047" , "PREVID�NCIA COMPLEMENTAR - 13� SAL�RIO"  																																				, ""		, 1032.08} )
		aAdd( aBody, { "", "000105", "9048" , "PREVID�NCIA COMPLEMENTAR - F�RIAS"  																																						, ""		, 1032.08} )

		aAdd( aRet, { aHeader, aBody } )

	EndIf

Return( aRet )
*/
