#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA234.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA234
TABELA 24 - C�digo de incid�ncia tribut�ria da rubrica para o IRRF

@author Anderson Costa
@since 14/08/2013
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA234()

	Local   oBrw        :=  FWmBrowse():New()

	oBrw:SetDescription(STR0001)    //"C�digo de incid�ncia tribut�ria da rubrica para o IRRF" - Tabela 21
	oBrw:SetAlias( 'C8U')
	oBrw:SetMenuDef( 'TAFA234' )
	C8U->(dbSetOrder(2))
	oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 14/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA234" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao gen�rica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 14/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oStruC8U := FWFormStruct( 1, 'C8U' )
	Local oModel   := MPFormModel():New('TAFA234' )

	oModel:AddFields('MODEL_C8U', /*cOwner*/, oStruC8U)
	oModel:GetModel('MODEL_C8U'):SetPrimaryKey({'C8U_FILIAL', 'C8U_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 14/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel   := FWLoadModel( 'TAFA234' )
	Local oStruC8U := FWFormStruct( 2, 'C8U' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_C8U', oStruC8U, 'MODEL_C8U' )

	oView:EnableTitleView( 'VIEW_C8U', STR0001 )    //"C�digo de incid�ncia tribut�ria da rubrica para o IRRF"
	oView:CreateHorizontalBox( 'FIELDSC8U', 100 )
	oView:SetOwnerView( 'VIEW_C8U', 'FIELDSC8U' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp as Numeric, nVerAtu as Numeric)

	Local aHeader	as Array
	Local aBody		as Array
	Local aRet		as Array

	Default nVerEmp	:= 0
	Default nVerAtu	:= 0

	aHeader := {}
	aBody   := {}
	aRet    := {}

	nVerAtu	:= 1032.08

	If nVerEmp < nVerAtu .And. TafAtualizado(.F.)

		aAdd( aHeader, "C8U_FILIAL" )
		aAdd( aHeader, "C8U_ID" )
		aAdd( aHeader, "C8U_CODIGO" )
		aAdd( aHeader, "C8U_DESCRI" )
		aAdd( aHeader, "C8U_VALIDA" )
		aAdd( aHeader, "C8U_ALTCON" )

		aAdd( aBody, { "", "000001", "00"	, "RENDIMENTO NAO TRIBUTAVEL"  																																											, "20210630"} )
		aAdd( aBody, { "", "000002", "11"	, "BASE DE CALCULO DO IRRF - REMUNERA�AO MENSAL"  																																						, "" 		} )
		aAdd( aBody, { "", "000003", "12"	, "BASE DE CALCULO DO IRRF - 13. SALARIO"  																																								, "" 		} )
		aAdd( aBody, { "", "000004", "13"	, "BASE DE CALCULO DO IRRF - FERIAS"  																																									, "" 		} )
		aAdd( aBody, { "", "000005", "14"	, "BASE DE CALCULO DO IRRF - PLR"  																																										, "" 		} )
		aAdd( aBody, { "", "000006", "15"	, "BASE DE CALCULO DO IRRF - RENDIMENTOS RECEBIDOS ACUMULADAMENTE - RRA"  																																, "20210630"} )
		aAdd( aBody, { "", "000007", "31"	, "RETENCOES DO IRRF - REMUNERA�AO MENSAL"  																																							, "" 		} )
		aAdd( aBody, { "", "000008", "32"	, "RETENCOES DO IRRF - 13. SALARIO"  																																									, "" 		} )
		aAdd( aBody, { "", "000009", "33"	, "RETENCOES DO IRRF - FERIAS"  																																										, "" 		} )
		aAdd( aBody, { "", "000010", "34"	, "RETENCOES DO IRRF - PLR"  																																											, "" 		} )
		aAdd( aBody, { "", "000011", "35"	, "RETENCOES DO IRRF - RRA"  																																											, "20210630"} )
		aAdd( aBody, { "", "000012", "41"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PREVIDENCIA SOCIAL OFICIAL - PSO - REMUNERA�AO MENSAL"  																										, "" 		} )
		aAdd( aBody, { "", "000013", "42"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PSO - 13. SALARIO"  																																			, "" 		} )
		aAdd( aBody, { "", "000014", "43"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PSO - FERIAS"  																																				, "" 		} )
		aAdd( aBody, { "", "000015", "44"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PSO - RRA"  																																					, "20210630"} )
		aAdd( aBody, { "", "000016", "46"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PREVIDENCIA PRIVADA - SALARIO MENSAL"  																														, "20230116", 1032.08} )
		aAdd( aBody, { "", "000017", "47"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PREVIDENCIA PRIVADA - 13. SALARIO"  																															, "20230116", 1032.08} )
		aAdd( aBody, { "", "000018", "51"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PENSAO ALIMENTICIA - REMUNERA�AO MENSAL"  																														, "" 		} )
		aAdd( aBody, { "", "000019", "52"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PENSAO ALIMENTICIA - 13. SALARIO"  																															, "" 		} )
		aAdd( aBody, { "", "000020", "53"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PENSAO ALIMENTICIA - FERIAS"  																																	, "" 		} )
		aAdd( aBody, { "", "000021", "54"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PENSAO ALIMENTICIA - PLR"  																																	, "" 		} )
		aAdd( aBody, { "", "000022", "56"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - DEPENDENTE - REMUNERA�AO MENSAL"  																																, "20170901"} )
		aAdd( aBody, { "", "000023", "57"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - DEPENDENTE - 13. SALARIO"  																																	, "20170119"} )
		aAdd( aBody, { "", "000024", "58"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - DEPENDENTE - FERIAS"  																																			, "20170119"} )
		aAdd( aBody, { "", "000025", "61"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - REMUNERA�AO MENSAL"  																					, "" 		} )
		aAdd( aBody, { "", "000026", "62"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - 13. SALARIO"  																							, "" 		} )
		aAdd( aBody, { "", "000027", "63"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - FUNDA�AO DE PREVIDENCIA COMPLEMENTAR DO SERVIDOR - FUNPRESP - REMUNERA�AO MENSAL"  																			, "" 		} )
		aAdd( aBody, { "", "000028", "64"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - FUNDA�AO DE PREVIDENCIA COMPLEMENTAR DO SERVIDOR - FUNPRESP - 13. SALARIO"  																					, "" 		} )
		aAdd( aBody, { "", "000029", "71"	, "ISENCOES DO IRRF - PARCELA ISENTA 65 ANOS - 13. SALARIO"  																																			, "" 		} )
		aAdd( aBody, { "", "000030", "72"	, "ISENCOES DO IRRF - DIARIAS"  																																										, "" 		} )
		aAdd( aBody, { "", "000031", "73"	, "ISENCOES DO IRRF - AJUDA DE CUSTO"  																																									, "" 		} )
		aAdd( aBody, { "", "000032", "74"	, "ISENCOES DO IRRF - INDENIZA�AO E RESCISAO DE CONTRATO, INCLUSIVE A TITULO DE PDV E ACIDENTES DE TRABALHO"  																							, "" 		} )
		aAdd( aBody, { "", "000033", "75"	, "ISENCOES DO IRRF - ABONO PECUNIARIO"  																																								, "" 		} )
		aAdd( aBody, { "", "000034", "76"	, "ISENCOES DO IRRF - PENSAO, APOSENTADORIA OU REFORMA POR MOLESTIA GRAVE OU ACIDENTE EM SERVI�O - REMUNERA�AO MENSAL"  																				, "" 		} )
		aAdd( aBody, { "", "000035", "77"	, "ISENCOES DO IRRF - PENSAO, APOSENTADORIA OU REFORMA POR MOLESTIA GRAVE OU ACIDENTE EM SERVI�O - 13. SALARIO"  																						, "" 		} )
		aAdd( aBody, { "", "000036", "78"	, "ISENCOES DO IRRF - VALORES PAGOS A TITULAR OU SOCIO DE MICROEMPRESA OU EMPRESA DE PEQUENO PORTE, EXCETO PRO-LABORE E ALUGUEIS"  																		, "20210630"} )
		aAdd( aBody, { "", "000037", "79"	, "ISENCOES DO IRRF - OUTRAS ISENCOES (O NOME DA RUBRICA DEVE SER CLARO PARA IDENTIFICA�AO DA NATUREZA DOS VALORES)"  																					, "" 		} )
		aAdd( aBody, { "", "000038", "81"	, "DEMANDAS JUDICIAIS - DEPOSITO JUDICIAL"  																																							, "20210630"} )
		aAdd( aBody, { "", "000039", "82"	, "DEMANDAS JUDICIAIS - COMPENSA�AO JUDICIAL DO ANO CALENDARIO"  																																		, "20210630"} )
		aAdd( aBody, { "", "000040", "83"	, "DEMANDAS JUDICIAIS - COMPENSA�AO JUDICIAL DE ANOS ANTERIORES"  																																		, "20210630"} )
		aAdd( aBody, { "", "000041", "91"	, "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - INCIDENCIA SUSPENSA EM DECORRENCIA DE DECISAO JUDICIAL, RELATIVAS A BASE DE CALCULO DO IRRF SOBRE REMUNERA�AO MENSAL"								, "20210630"} )
		aAdd( aBody, { "", "000042", "92"	, "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - INCIDENCIA SUSPENSA EM DECORRENCIA DE DECISAO JUDICIAL, RELATIVAS A BASE DE CALCULO DO IRRF SOBRE 13. SALARIO"										, "20210630"} )
		aAdd( aBody, { "", "000043", "93"	, "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - INCIDENCIA SUSPENSA EM DECORRENCIA DE DECISAO JUDICIAL, RELATIVAS A BASE DE CALCULO DO IRRF SOBRE FERIAS"											, "20210630"} )
		aAdd( aBody, { "", "000044", "94"	, "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - INCIDENCIA SUSPENSA EM DECORRENCIA DE DECISAO JUDICIAL, RELATIVAS A BASE DE CALCULO DO IRRF SOBRE PLR"												, "20210630"} )
		aAdd( aBody, { "", "000045", "95"	, "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - INCIDENCIA SUSPENSA EM DECORRENCIA DE DECISAO JUDICIAL, RELATIVAS A BASE DE CALCULO DO IRRF SOBRE RRA"												, "20210630"} )
		aAdd( aBody, { "", "000046", "01"	, "REDIMENTO NAO TRIBUTAVEL EM FUNCAO DE ACORDOS INTERNACIONAIS DE BITRIBUTACAO"  																														, "20210430"} )
		aAdd( aBody, { "", "000047", "18"	, "BASE DE CALCULO DO IRRF - REMUNERACAO RECEBIDA POR RESIDENTE FISCAL NO EXTERIOR"  																													, "20170901"} )
		aAdd( aBody, { "", "000048", "55"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PENSAO ALIMENTICIA - RRA"  																																	, "20210630"} )
		aAdd( aBody, { "", "000049", "70"	, "ISENCOES DO IRRF - PARCELA ISENTA 65 ANOS - REMUNERACAO MENSAL"  																																	, "20210509"} )
		
		//Simplifica��o do eSocial Vers�o S-1.0
		aAdd( aBody, { "", "000050", "09"	, "OUTRAS VERBAS N�O CONSIDERADAS COMO BASE DE C�LCULO OU RENDIMENTO"  																																	, "20210430"} )

		//Simplifica��o do eSocial Vers�o S-1.0 -- Dedu��o do rendimento tribut�vel do IRRF
		aAdd( aBody, { "", "000051", "48" 	, "DEDU��O DO RENDIMENTO TRIBUT�VEL DO IRREF - PREVID�NCIA PRIVADA - F�RIAS"  																															, "20230116", 1032.08} )
		aAdd( aBody, { "", "000052", "65" 	, "DEDU��O DO RENDIMENTO TRIBUT�VEL DO IRREF - FUNDA��O DE PREVID�NCIA COMPLEMENTAR DO SERVIDOR P�BLICO - F�RIAS"  																						, "" 		} )
		aAdd( aBody, { "", "000053", "66" 	, "DEDU��O DO RENDIMENTO TRIBUT�VEL DO IRREF - FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - F�RIAS"  																							, "" 		} )
		aAdd( aBody, { "", "000054", "67" 	, "DEDU��O DO RENDIMENTO TRIBUT�VEL DO IRREF - PLANO PRIVADO COLETIVO DE ASSIST�NCIA � SA�DE"  																											, "" 		} )

		//RENDIMENTO N�O TRIBUT�VEL OU ISENTO DO IRRF
		aAdd( aBody, { "", "000055", "70" 	, "ISENCOES DO IRRF - PARCELA ISENTA 65 ANOS - REMUNERA��O MENSAL"  																																	, "" 		} )
		aAdd( aBody, { "", "000056", "700" 	, "ISENCOES DO IRRF - AUX�LIO MORADIA"  																																				 				, "" 		} )
		aAdd( aBody, { "", "000057", "701" 	, "ISENCOES DO IRRF - PARTE N�O TRIBUT�VEL DO VALOR DE SERVI�O DE TRANSPORTE DE PASSAGEIROS OU CARGAS"  																								, "" 		} )		
			
		// EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUT�VEL (BASE DE C�LCULO DO IR)
		aAdd( aBody, { "", "000058", "9011" , "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - REMUNERA��O MENSAL"  																																, "" 		} )
		aAdd( aBody, { "", "000059", "9012" , "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - 13� SAL�RIO"  																																		, "" 		} )
		aAdd( aBody, { "", "000060", "9013" , "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - F�RIAS"  																																			, "" 		} )
		aAdd( aBody, { "", "000061", "9014" , "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - PLR"  																																				, "" 		} )

		// EXIGIBILIDADE SUSPENSA - RETEN��O DO IRRF EFETUADA SOBRE
		aAdd( aBody, { "", "000062", "9031" , "EXIGIBILIDADE SUSPENSA - RETEN��O DO IRRF EFETUADA SOBRE: - REMUNERA��O MENSAL"  																													, "" 		} )
		aAdd( aBody, { "", "000063", "9032" , "EXIGIBILIDADE SUSPENSA - RETEN��O DO IRRF EFETUADA SOBRE: - 13� SAL�RIO"  																															, "" 		} )
		aAdd( aBody, { "", "000064", "9033" , "EXIGIBILIDADE SUSPENSA - RETEN��O DO IRRF EFETUADA SOBRE: - F�RIAS"  																																, "" 		} )
		aAdd( aBody, { "", "000065", "9034" , "EXIGIBILIDADE SUSPENSA - RETEN��O DO IRRF EFETUADA SOBRE: - PLR"  																																	, "" 		} )
		aAdd( aBody, { "", "000066", "9831" , "EXIGIBILIDADE SUSPENSA - RETEN��O DO IRRF EFETUADA SOBRE: - DEP�SITO JUDICIAL - MENSAL"  																											, "" 		} )
		aAdd( aBody, { "", "000067", "9832" , "EXIGIBILIDADE SUSPENSA - RETEN��O DO IRRF EFETUADA SOBRE: - DEP�SITO JUDICIAL - 13� SAL�RIO"  																										, "" 		} )
		aAdd( aBody, { "", "000068", "9833" , "EXIGIBILIDADE SUSPENSA - RETEN��O DO IRRF EFETUADA SOBRE: - DEP�SITO JUDICIAL - F�RIAS"  																											, "" 		} )
		aAdd( aBody, { "", "000069", "9834" , "EXIGIBILIDADE SUSPENSA - RETEN��O DO IRRF EFETUADA SOBRE: - DEP�SITO JUDICIAL - PLR"  																												, "" 		} )
		
		//EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE C�LCULO DO IRRF
		aAdd( aBody, { "", "000070", "9041" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - PREVID�NCIA SOCIAL OFICIAL - PSO - REMUNERA��O MENSAL"  																				, ""		} )
		aAdd( aBody, { "", "000071", "9042" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - PSO - 13� SAL�RIO"  																													, ""		} )
		aAdd( aBody, { "", "000072", "9043" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - PSO - F�RIAS"  																														, ""		} )
		aAdd( aBody, { "", "000073", "9046" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - PREVID�NCIA PRIVADA - SAL�RIO MENSAL"  																								, "20230116", 1032.08} )
		aAdd( aBody, { "", "000074", "9047" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - PREVID�NCIA PRIVADA - 13� SAL�RIO"  																									, "20230116", 1032.08} )
		aAdd( aBody, { "", "000075", "9048" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - PREVID�NCIA PRIVADA - F�RIAS"  																										, "20230116", 1032.08} )
		aAdd( aBody, { "", "000076", "9051" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - PENS�O ALIMENT�CIA - REMUNERA��O MENSAL"  																								, ""		} )
		aAdd( aBody, { "", "000077", "9052" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - PENS�O ALIMENT�CIA - 13� SAL�RIO"  																									, ""		} )
		aAdd( aBody, { "", "000078", "9053" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - PENS�O ALIMENT�CIA - F�RIAS"  																											, ""		} )
		aAdd( aBody, { "", "000079", "9054" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - PENS�O ALIMENT�CIA - PLR"  																											, ""		} )
		aAdd( aBody, { "", "000080", "9061" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - REMUNERA��O MENSAL"  															, ""		} )
		aAdd( aBody, { "", "000081", "9062" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - 13� SAL�RIO"  																	, ""		} )
		aAdd( aBody, { "", "000082", "9063" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - FUNDA��O DE PREVID�NCIA COMPLEMENTAR DO SERVIDOR P�BLICO - REMUNERA��O MENSAL"  														, ""		} )
		aAdd( aBody, { "", "000083", "9064" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - FUNDA��O DE PREVID�NCIA COMPLEMENTAR DO SERVIDOR P�BLICO - 13� SAL�RIO"  																, ""		} )
		aAdd( aBody, { "", "000084", "9065" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - FUNDA��O DE PREVID�NCIA COMPLEMENTAR DO SERVIDOR P�BLICO - F�RIAS"  																	, ""		} )
		aAdd( aBody, { "", "000085", "9066" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - F�RIAS"  																		, ""		} )
		aAdd( aBody, { "", "000086", "9067" , "EXIGIBILIDADE SUSPENSA - DEDU��O DA BASE DE CALCULO DO IRRF - PLANO PRIVADO COLETIVO DE ASSIST�NCIA � SA�DE"  																						, ""		} )
		
		//COMPENSA��O JUDICIAL
		aAdd( aBody, { "", "000087", "9082" , "COMPENSA��O JUDUCIAL - COMPENSA��O JUDICIAL DO ANO-CALEND�RIO"  																																		, ""		} )
		aAdd( aBody, { "", "000088", "9083" , "COMPENSA��O JUDUCIAL - COMPENSA��O JUDICIAL DE ANOS ANTERIORES"  																																	, ""		} )

		//NOVAS INCLUS�ES LEIAUTE 1.0 - RENDIMENTO N�O TRIBUT�VEL OU ISENTO DO IRRF
		aAdd( aBody, { "", "000089", "7900"	, "RENDIMENTO N�O TRIBUT�VEL OU ISENTO DO IRRF - VERBA DE FOLHA DE PAGTO DE NATUR. DIVERSA DE RENDIMENTO OU RETEN��O/ISEN��O/DEDU��O DE IR (EX: DESCONTO DE CONV�NIO FARM�CIA, DE CONSIGNA��ES, ETC.)" 	, ""		} )
		
		//NOVAS INCLUS�ES LEIAUTE 1.0 - C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES
		aAdd( aBody, { "", "000090", "7950" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - RENDIMENTO N�O TRIBUT�VEL"  																													, ""		} )
		aAdd( aBody, { "", "000091", "7951" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - RENDIMENTO N�O TRIBUT�VEL EM FUN��O DE ACORDOS INTERNACIONAIS DE BITRIBUTA��O"  																, ""		} )
		aAdd( aBody, { "", "000092", "7952" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - RENDIMENTO TRIBUT�VEL - RRA"  																													, ""		} )
		aAdd( aBody, { "", "000093", "7953" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - RETEN��O DE IR - RRA"  																															, ""		} )
		aAdd( aBody, { "", "000094", "7954" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - PREVID�NCIA SOCIAL OFICIAL - RRA"  																												, ""		} )
		aAdd( aBody, { "", "000095", "7955" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - PENS�O ALIMENT�CIA - RRA"  																														, ""		} )
		aAdd( aBody, { "", "000096", "7956" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - VALORES PAGOS A TITULAR OU S�CIO DE MICROEMPRESA OU EMPRESA DE PEQUENO PORTE, EXCETO PR�-LABORE E ALUGU�IS"  									, ""		} )
		aAdd( aBody, { "", "000097", "7957" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - DEP�SITO JUDICIAL"  																															, ""		} )
		aAdd( aBody, { "", "000098", "7958" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - COMPENSA��O JUDICIAL DO ANO-CALEND�RIO"   																										, ""		} )
		aAdd( aBody, { "", "000099", "7959" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - COMPENSA��O JUDICIAL DE ANOS ANTERIORES"  																										, ""		} )
		aAdd( aBody, { "", "000100", "7960" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - EXIGIBILIDADE SUSPENSA - REMUNERA��O MENSAL"  																									, ""		} )
		aAdd( aBody, { "", "000101", "7961" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - EXIGIBILIDADE SUSPENSA - 13� SAL�RIOL"  																										, ""		} )
		aAdd( aBody, { "", "000102", "7962" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - EXIGIBILIDADE SUSPENSA - F�RIAS"  																												, ""		} )
		aAdd( aBody, { "", "000103", "7963" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - EXIGIBILIDADE SUSPENSA - PLR"  																													, ""		} )
		aAdd( aBody, { "", "000104", "7964" , "C�DIGOS PARA COMPATIBILIDADE DE VERS�ES ANTERIORES - EXIGIBILIDADE SUSPENSA - RRA"  , ""} )
		aAdd( aBody, { "", "000105", "9" 	, "VERBA TRANSITADA PELA FOLHA DE PAGAMENTO DE NATUREZA DIVERSA DE RENDIMENTO OU RETEN��O/ISEN��O/DEDU��O DE IR (EXEMPLO: DESCONTO DE CONV�NIO FARM�CIA, DESCONTO DE CONSIGNA��ES, ETC.)"  				, ""		} )

		//NOTA T�CNICA S-1.0 N� 06/2022
		aAdd( aBody, { "", "000106", "46" 	, "PREVID�NCIA COMPLEMENTAR - SAL�RIO MENSAL"  																																							, ""		, 1032.08} )
		aAdd( aBody, { "", "000107", "47" 	, "PREVID�NCIA COMPLEMENTAR - 13� SAL�RIO"  																																							, ""		, 1032.08} )
		aAdd( aBody, { "", "000108", "48" 	, "PREVID�NCIA COMPLEMENTAR - F�RIAS"  																																									, ""		, 1032.08} )
		aAdd( aBody, { "", "000109", "9046" , "PREVID�NCIA COMPLEMENTAR - SAL�RIO MENSAL"  																																							, ""		, 1032.08} )
		aAdd( aBody, { "", "000110", "9047" , "PREVID�NCIA COMPLEMENTAR - 13� SAL�RIO"  																																							, ""		, 1032.08} )
		aAdd( aBody, { "", "000111", "9048" , "PREVID�NCIA COMPLEMENTAR - F�RIAS"   																																								, ""		, 1032.08} ) 	

		aAdd( aRet, { aHeader, aBody } )
		
	EndIf

Return( aRet )
