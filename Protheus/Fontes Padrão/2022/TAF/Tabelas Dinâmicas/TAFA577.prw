#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA577.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA577
******* FONTE DESCONTINUADO - TABELA 21 ESTA NO FONTE TAFA234 *******
Tabela 21 - Códigos de Incidência Tributária da Rubrica para o IRRF

@author José Riquelmo
@since 03/02/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA577()
/*
	Local oBrw := FWmBrowse():New()

	oBrw:SetDescription(STR0001)    //"Códigos de Incidência Tributária da Rubrica para o IRRF"
	oBrw:SetAlias( 'V5X')
	oBrw:SetMenuDef('TAFA577')
	oBrw:Activate()
*/
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author José Riquelmo
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

@author José Riquelmo
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

@author José Riquelmo
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

	oView:EnableTitleView( 'VIEW_V5X', STR0001 )    //"Códigos de Incidência Tributária da Rubrica para o IRRF"
	oView:CreateHorizontalBox( 'FIELDSV5X', 100 )
	oView:SetOwnerView( 'VIEW_V5X', 'FIELDSV5X' )

Return oView
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@author José Riquelmo
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
		
		aAdd( aBody, { "", "000001", "0" 	, "RENDIMENTO NÃO TRIBUTÁVEL" 																																								, ""		} )
		aAdd( aBody, { "", "000002", "1" 	, "RENDIMENTO NÃO TRIBUTÁVEL EM FUNÇÃO DE ACORDOS INTERNACIONAIS DE BITRIBUTAÇÃO" 																											, ""		} )
		aAdd( aBody, { "", "000003", "9" 	, "VERBA TRANSITADA PELA FOLHA DE PAGAMENTO DE NATUREZA DIVERSA DE RENDIMENTO OU RETENÇÃO/ISENÇÃO/DEDUÇÃO DE IR (EXEMPLO: DESCONTO DE CONVÊNIO FARMÁCIA, DESCONTO DE CONSIGNAÇÕES, ETC.)" 	, ""		} )
		
		// Rendimento tributável (base de cálculo do IR)
		aAdd( aBody, { "", "000004", "11" 	, "REMUNERAÇÃO MENSAL"  																																									, ""		} )
		aAdd( aBody, { "", "000005", "12" 	, "13º SALÁRIO"  																																											, ""		} )
		aAdd( aBody, { "", "000006", "13" 	, "FÉRIAS"  																																												, ""		} )
		aAdd( aBody, { "", "000007", "14" 	, "PLR"  																																													, ""		} )
		aAdd( aBody, { "", "000008", "15" 	, "RENDIMENTOS RECEBIDOS ACUMULADAMENTE - RRA"  																																			, "20210430"} )

		// Retenção do IRRF efetuada sobre
		aAdd( aBody, { "", "000009", "31" 	, "REMUNERAÇÃO MENSAL"  																																									, ""		} )
		aAdd( aBody, { "", "000010", "32" 	, "13º SALÁRIO"  																																											, ""		} )
		aAdd( aBody, { "", "000011", "33" 	, "FÉRIAS"  																																												, ""		} )
		aAdd( aBody, { "", "000012", "34" 	, "PLR"  																																													, ""		} )
		aAdd( aBody, { "", "000013", "35" 	, "RENDIMENTOS RECEBIDOS ACUMULADAMENTE - RRA"  																																			, "20210430"} )

		// Dedução do rendimento tributável do IRRF
		aAdd( aBody, { "", "000014", "41" 	, "PREVIDÊNCIA SOCIAL OFICIAL - PSO - REMUNERAÇÃO MENSAL"  																																	, ""		} )
		aAdd( aBody, { "", "000015", "42" 	, "PSO - 13º SALÁRIO"  																																										, ""		} )
		aAdd( aBody, { "", "000016", "43" 	, "PSO - FÉRIAS"  																																											, ""		} )
		aAdd( aBody, { "", "000017", "44" 	, "PSO - RRA"  																																												, "20210430"} )
		aAdd( aBody, { "", "000018", "46" 	, "PREVIDÊNCIA PRIVADA - SALÁRIO MENSAL"  																																					, "20230116", 1032.08} )
		aAdd( aBody, { "", "000019", "47" 	, "PREVIDÊNCIA PRIVADA - 13º SALÁRIO"  																																						, "20230116", 1032.08} )
		aAdd( aBody, { "", "000020", "48" 	, "PREVIDÊNCIA PRIVADA - FÉRIAS"  																																							, "20230116", 1032.08} )
		aAdd( aBody, { "", "000021", "51" 	, "PENSÃO ALIMENTÍCIA - REMUNERAÇÃO MENSAL"  																																				, ""		} )
		aAdd( aBody, { "", "000022", "52" 	, "PENSÃO ALIMENTÍCIA - 13º SALÁRIO"  																																						, ""		} )
		aAdd( aBody, { "", "000023", "53" 	, "PENSÃO ALIMENTÍCIA - FÉRIAS"  																																							, ""		} )
		aAdd( aBody, { "", "000024", "54" 	, "PENSÃO ALIMENTÍCIA - PLR"  																																								, ""		} )
		aAdd( aBody, { "", "000025", "55" 	, "PENSÃO ALIMENTÍCIA - RRA"  																																								, "20210430"} )
		aAdd( aBody, { "", "000026", "61" 	, "FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - REMUNERAÇÃO MENSAL"  																												, ""		} )
		aAdd( aBody, { "", "000027", "62" 	, "FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - 13º SALÁRIO"  																														, ""		} )
		aAdd( aBody, { "", "000028", "63" 	, "FUNDAÇÃO DE PREVIDÊNCIA COMPLEMENTAR DO SERVIDOR PÚBLICO - REMUNERAÇÃO MENSAL"  																											, ""		} )
		aAdd( aBody, { "", "000029", "64" 	, "FUNDAÇÃO DE PREVIDÊNCIA COMPLEMENTAR DO SERVIDOR PÚBLICO - 13º SALÁRIO" 																													, ""		} )
		aAdd( aBody, { "", "000030", "65" 	, "FUNDAÇÃO DE PREVIDÊNCIA COMPLEMENTAR DO SERVIDOR PÚBLICO - FÉRIAS"  																														, ""		} )
		aAdd( aBody, { "", "000031", "66" 	, "FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - FÉRIAS"  																															, ""		} )
		aAdd( aBody, { "", "000032", "67" 	, "PLANO PRIVADO COLETIVO DE ASSISTÊNCIA À SAÚDE"  																																			, ""		} )

		//RENDIMENTO NÃO TRIBUTÁVEL OU ISENTO DO IRRF
		aAdd( aBody, { "", "000033", "70" 	, "PARCELA ISENTA 65 ANOS - REMUNERAÇÃO MENSAL"  																																			, ""		} )
		aAdd( aBody, { "", "000034", "71" 	, "PARCELA ISENTA 65 ANOS - 13º SALÁRIO"  																																					, ""		} )
		aAdd( aBody, { "", "000035", "72" 	, "DIÁRIAS"  																																												, ""		} )
		aAdd( aBody, { "", "000036", "73" 	, "AJUDA DE CUSTO"  																																										, ""		} )
		aAdd( aBody, { "", "000037", "74" 	, "INDENIZAÇÃO E RESCISÃO DE CONTRATO, INCLUSIVE A TÍTULO DE PDV E ACIDENTES DE TRABALHO"  																									, ""		} )
		aAdd( aBody, { "", "000038", "75" 	, "ABONO PECUNIÁRIO"  																																										, ""		} )
		aAdd( aBody, { "", "000039", "76" 	, "RENDIMENTO DE BENEFICIÁRIO COM MOLÉSTIA GRAVE OU ACIDENTE EM SERVIÇO REMUNERAÇÃO MENSAL"  																								, ""		} )
		aAdd( aBody, { "", "000040", "77" 	, "RENDIMENTO DE BENEFICIÁRIO COM MOLÉSTIA GRAVE OU ACIDENTE EM SERVIÇO - 13º SALÁRIO"  																									, ""		} )
		aAdd( aBody, { "", "000041", "78" 	, "VALORES PAGOS A TITULAR OU SÓCIO DE MICROEMPRESA OU EMPRESA DE PEQUENO PORTE, EXCETO PRÓ-LABORE E ALUGUÉIS"  																			, "20210430"} )
		aAdd( aBody, { "", "000042", "700"	, "AUXÍLIO MORADIA"  																																										, ""		} )
		aAdd( aBody, { "", "000043", "701"	, "PARTE NÃO TRIBUTÁVEL DO VALOR DE SERVIÇO DE TRANSPORTE DE PASSAGEIROS OU CARGAS"  																										, ""		} )		
		aAdd( aBody, { "", "000044", "79" 	, "OUTRAS ISENÇÕES (O NOME DA RUBRICA DEVE SER CLARO PARA IDENTIFICAÇÃO DA NATUREZA DOS VALORES)"  																							, ""		} )

		//DEMANDAS JUDICIAIS		
		aAdd( aBody, { "", "000045", "81" 	, "DEPÓSITO JUDICIAL"  																																										, "20210430"} )
		aAdd( aBody, { "", "000046", "82" 	, "COMPENSAÇÃO JUDICIAL DO ANO-CALENDÁRIO"  																																				, "20210430"} )
		aAdd( aBody, { "", "000047", "83" 	, "COMPENSAÇÃO JUDICIAL DE ANOS ANTERIORES"  																																				, "20210430"} )

		// EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTÁVEL (BASE DE CÁLCULO DO IR)
		aAdd( aBody, { "", "000048", "91" 	, "REMUNERAÇÃO MENSAL"  																																									, "20210430"} )
		aAdd( aBody, { "", "000049", "92" 	, "13º SALÁRIO"  																																											, "20210430"} )
		aAdd( aBody, { "", "000050", "93" 	, "FÉRIAS"  																																												, "20210430"} )
		aAdd( aBody, { "", "000051", "94" 	, "PLR"  																																													, "20210430"} )
		aAdd( aBody, { "", "000052", "95" 	, "RRA"  																																													, "20210430"} )
		aAdd( aBody, { "", "000053", "9011" , "REMUNERAÇÃO MENSAL"  																																									, ""		} )
		aAdd( aBody, { "", "000054", "9012" , "13º SALÁRIO"  																																											, ""		} )
		aAdd( aBody, { "", "000055", "9013" , "FÉRIAS"  																																												, ""		} )
		aAdd( aBody, { "", "000056", "9014" , "PLR"  																																													, ""		} )

		// EXIGIBILIDADE SUSPENSA - RETENÇÃO DO IRRF EFETUADA SOBRE
		aAdd( aBody, { "", "000057", "9031" , "REMUNERAÇÃO MENSAL"  																																									, ""		} )
		aAdd( aBody, { "", "000058", "9032" , "13º SALÁRIO" 																																							 				, ""		} )
		aAdd( aBody, { "", "000059", "9033" , "FÉRIAS"  																																												, ""		} )
		aAdd( aBody, { "", "000060", "9034" , "PLR"  																																													, ""		} )
		aAdd( aBody, { "", "000061", "9831" , "DEPÓSITO JUDICIAL - MENSAL"  																																							, ""		} )
		aAdd( aBody, { "", "000062", "9832" , "DEPÓSITO JUDICIAL - 13º SALÁRIO"  																																						, ""		} )
		aAdd( aBody, { "", "000063", "9833" , "DEPÓSITO JUDICIAL - FÉRIAS"  																																							, ""		} )
		aAdd( aBody, { "", "000064", "9834" , "DEPÓSITO JUDICIAL - PLR"  																																								, ""		} )
		
		//EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CÁLCULO DO IRRF
		aAdd( aBody, { "", "000065", "9041" , "PREVIDÊNCIA SOCIAL OFICIAL - PSO - REMUNERAÇÃO MENSAL"  																																	, ""		} )
		aAdd( aBody, { "", "000066", "9042" , "PSO - 13º SALÁRIO"  																																										, ""		} )
		aAdd( aBody, { "", "000067", "9043" , "PSO - FÉRIAS"  																																											, ""		} )
		aAdd( aBody, { "", "000068", "9046" , "PREVIDÊNCIA PRIVADA - SALÁRIO MENSAL"  																																					, "20230116", 1032.08} )
		aAdd( aBody, { "", "000069", "9047" , "PREVIDÊNCIA PRIVADA - 13º SALÁRIO"  																																						, "20230116", 1032.08} )
		aAdd( aBody, { "", "000070", "9048" , "PREVIDÊNCIA PRIVADA - FÉRIAS"  																																							, "20230116", 1032.08} )
		aAdd( aBody, { "", "000071", "9051" , "PENSÃO ALIMENTÍCIA - REMUNERAÇÃO MENSAL"  																																				, ""		} )
		aAdd( aBody, { "", "000072", "9052" , "PENSÃO ALIMENTÍCIA - 13º SALÁRIO"  																																						, ""		} )
		aAdd( aBody, { "", "000073", "9053" , "PENSÃO ALIMENTÍCIA - FÉRIAS"  																																							, ""		} )
		aAdd( aBody, { "", "000074", "9054" , "PENSÃO ALIMENTÍCIA - PLR"  																																								, ""		} )
		aAdd( aBody, { "", "000075", "9061" , "FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - REMUNERAÇÃO MENSAL"  																												, ""		} )
		aAdd( aBody, { "", "000076", "9062" , "FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - 13º SALÁRIO"  																														, ""		} )
		aAdd( aBody, { "", "000077", "9063" , "FUNDAÇÃO DE PREVIDÊNCIA COMPLEMENTAR DO SERVIDOR PÚBLICO - REMUNERAÇÃO MENSAL"  																											, ""		} )
		aAdd( aBody, { "", "000078", "9064" , "FUNDAÇÃO DE PREVIDÊNCIA COMPLEMENTAR DO SERVIDOR PÚBLICO - 13º SALÁRIO"  																												, ""		} )
		aAdd( aBody, { "", "000079", "9065" , "FUNDAÇÃO DE PREVIDÊNCIA COMPLEMENTAR DO SERVIDOR PÚBLICO - FÉRIAS"  																														, ""		} )
		aAdd( aBody, { "", "000080", "9066" , "FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - FÉRIAS"  																															, ""		} )
		aAdd( aBody, { "", "000081", "9067" , "PLANO PRIVADO COLETIVO DE ASSISTÊNCIA À SAÚDE" 																																			, ""		} )
		
		//COMPENSAÇÃO JUDICIAL
		aAdd( aBody, { "", "000082", "9082" , "COMPENSAÇÃO JUDICIAL DO ANO-CALENDÁRIO"  																																				, ""		} )
		aAdd( aBody, { "", "000083", "9083" , "COMPENSAÇÃO JUDICIAL DE ANOS ANTERIORES"  																																				, ""		} )

		//NOVAS INCLUSÕES LEIAUTE 1.0 - RENDIMENTO NÃO TRIBUTÁVEL OU ISENTO DO IRRF
		aAdd( aBody, { "", "000084", "7900"	, "VERBA TRANSITADA PELA FOLHA DE PAGAMENTO DE NATUREZA DIVERSA DE RENDIMENTO OU RETENÇÃO/ISENÇÃO/DEDUÇÃO DE IR (EXEMPLO: DESCONTO DE CONVÊNIO FARMÁCIA, DESCONTO DE CONSIGNAÇÕES, ETC.)"	, "" 		} )
		
		//NOVAS INCLUSÕES LEIAUTE 1.0 - CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES
		aAdd( aBody, { "", "000085", "7950" , "RENDIMENTO NÃO TRIBUTÁVEL"  																																								, ""		} )
		aAdd( aBody, { "", "000086", "7951" , "RENDIMENTO NÃO TRIBUTÁVEL EM FUNÇÃO DE ACORDOS INTERNACIONAIS DE BITRIBUTAÇÃO" 																											, ""		} )
		aAdd( aBody, { "", "000087", "7952" , "RENDIMENTO TRIBUTÁVEL - RRA"  																																							, ""		} )
		aAdd( aBody, { "", "000088", "7953" , "RETENÇÃO DE IR - RRA"  																																									, ""		} )
		aAdd( aBody, { "", "000089", "7954" , "PREVIDÊNCIA SOCIAL OFICIAL - RRA"  																																						, ""		} )
		aAdd( aBody, { "", "000090", "7955" , "PENSÃO ALIMENTÍCIA - RRA"  																																								, ""		} )
		aAdd( aBody, { "", "000091", "7956" , "VALORES PAGOS A TITULAR OU SÓCIO DE MICROEMPRESA OU EMPRESA DE PEQUENO PORTE, EXCETO PRÓ-LABORE E ALUGUÉIS" 																				, ""		} )
		aAdd( aBody, { "", "000092", "7957" , "DEPÓSITO JUDICIAL"  																																										, ""		} )
		aAdd( aBody, { "", "000093", "7958" , "COMPENSAÇÃO JUDICIAL DO ANO-CALENDÁRIO"  																																				, ""		} )
		aAdd( aBody, { "", "000094", "7959" , "COMPENSAÇÃO JUDICIAL DE ANOS ANTERIORES"  																																				, ""		} )
		aAdd( aBody, { "", "000095", "7960" , "EXIGIBILIDADE SUSPENSA - REMUNERAÇÃO MENSAL"  																																			, ""		} )
		aAdd( aBody, { "", "000096", "7961" , "EXIGIBILIDADE SUSPENSA - 13º SALÁRIOL"  																																					, ""		} )
		aAdd( aBody, { "", "000097", "7962" , "EXIGIBILIDADE SUSPENSA - FÉRIAS"  																																						, ""		} )
		aAdd( aBody, { "", "000098", "7963" , "EXIGIBILIDADE SUSPENSA - PLR"  																																							, ""		} )
		aAdd( aBody, { "", "000099", "7964" , "EXIGIBILIDADE SUSPENSA - RRA"  																																							, ""		} )

		//NOTA TÉCNICA S-1.0 Nº 06/2022
		aAdd( aBody, { "", "000100", "46" 	, "PREVIDÊNCIA COMPLEMENTAR- SALÁRIO MENSAL"  																																				, ""		, 1032.08} )
		aAdd( aBody, { "", "000101", "47" 	, "PREVIDÊNCIA COMPLEMENTAR - 13º SALÁRIO"  																																				, ""		, 1032.08} )
		aAdd( aBody, { "", "000102", "48" 	, "PREVIDÊNCIA COMPLEMENTAR - FÉRIAS"  																																						, ""		, 1032.08} )
		aAdd( aBody, { "", "000103", "9046" , "PREVIDÊNCIA COMPLEMENTAR - SALÁRIO MENSAL"  																																				, ""		, 1032.08} )
		aAdd( aBody, { "", "000104", "9047" , "PREVIDÊNCIA COMPLEMENTAR - 13º SALÁRIO"  																																				, ""		, 1032.08} )
		aAdd( aBody, { "", "000105", "9048" , "PREVIDÊNCIA COMPLEMENTAR - FÉRIAS"  																																						, ""		, 1032.08} )

		aAdd( aRet, { aHeader, aBody } )

	EndIf

Return( aRet )
*/
