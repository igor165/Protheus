#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA234.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA234
TABELA 24 - Código de incidência tributária da rubrica para o IRRF

@author Anderson Costa
@since 14/08/2013
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA234()

	Local   oBrw        :=  FWmBrowse():New()

	oBrw:SetDescription(STR0001)    //"Código de incidência tributária da rubrica para o IRRF" - Tabela 21
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
Funcao genérica MVC do model

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

	oView:EnableTitleView( 'VIEW_C8U', STR0001 )    //"Código de incidência tributária da rubrica para o IRRF"
	oView:CreateHorizontalBox( 'FIELDSC8U', 100 )
	oView:SetOwnerView( 'VIEW_C8U', 'FIELDSC8U' )

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
		aAdd( aBody, { "", "000002", "11"	, "BASE DE CALCULO DO IRRF - REMUNERAÇAO MENSAL"  																																						, "" 		} )
		aAdd( aBody, { "", "000003", "12"	, "BASE DE CALCULO DO IRRF - 13. SALARIO"  																																								, "" 		} )
		aAdd( aBody, { "", "000004", "13"	, "BASE DE CALCULO DO IRRF - FERIAS"  																																									, "" 		} )
		aAdd( aBody, { "", "000005", "14"	, "BASE DE CALCULO DO IRRF - PLR"  																																										, "" 		} )
		aAdd( aBody, { "", "000006", "15"	, "BASE DE CALCULO DO IRRF - RENDIMENTOS RECEBIDOS ACUMULADAMENTE - RRA"  																																, "20210630"} )
		aAdd( aBody, { "", "000007", "31"	, "RETENCOES DO IRRF - REMUNERAÇAO MENSAL"  																																							, "" 		} )
		aAdd( aBody, { "", "000008", "32"	, "RETENCOES DO IRRF - 13. SALARIO"  																																									, "" 		} )
		aAdd( aBody, { "", "000009", "33"	, "RETENCOES DO IRRF - FERIAS"  																																										, "" 		} )
		aAdd( aBody, { "", "000010", "34"	, "RETENCOES DO IRRF - PLR"  																																											, "" 		} )
		aAdd( aBody, { "", "000011", "35"	, "RETENCOES DO IRRF - RRA"  																																											, "20210630"} )
		aAdd( aBody, { "", "000012", "41"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PREVIDENCIA SOCIAL OFICIAL - PSO - REMUNERAÇAO MENSAL"  																										, "" 		} )
		aAdd( aBody, { "", "000013", "42"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PSO - 13. SALARIO"  																																			, "" 		} )
		aAdd( aBody, { "", "000014", "43"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PSO - FERIAS"  																																				, "" 		} )
		aAdd( aBody, { "", "000015", "44"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PSO - RRA"  																																					, "20210630"} )
		aAdd( aBody, { "", "000016", "46"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PREVIDENCIA PRIVADA - SALARIO MENSAL"  																														, "20230116", 1032.08} )
		aAdd( aBody, { "", "000017", "47"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PREVIDENCIA PRIVADA - 13. SALARIO"  																															, "20230116", 1032.08} )
		aAdd( aBody, { "", "000018", "51"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PENSAO ALIMENTICIA - REMUNERAÇAO MENSAL"  																														, "" 		} )
		aAdd( aBody, { "", "000019", "52"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PENSAO ALIMENTICIA - 13. SALARIO"  																															, "" 		} )
		aAdd( aBody, { "", "000020", "53"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PENSAO ALIMENTICIA - FERIAS"  																																	, "" 		} )
		aAdd( aBody, { "", "000021", "54"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PENSAO ALIMENTICIA - PLR"  																																	, "" 		} )
		aAdd( aBody, { "", "000022", "56"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - DEPENDENTE - REMUNERAÇAO MENSAL"  																																, "20170901"} )
		aAdd( aBody, { "", "000023", "57"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - DEPENDENTE - 13. SALARIO"  																																	, "20170119"} )
		aAdd( aBody, { "", "000024", "58"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - DEPENDENTE - FERIAS"  																																			, "20170119"} )
		aAdd( aBody, { "", "000025", "61"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - REMUNERAÇAO MENSAL"  																					, "" 		} )
		aAdd( aBody, { "", "000026", "62"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - 13. SALARIO"  																							, "" 		} )
		aAdd( aBody, { "", "000027", "63"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - FUNDAÇAO DE PREVIDENCIA COMPLEMENTAR DO SERVIDOR - FUNPRESP - REMUNERAÇAO MENSAL"  																			, "" 		} )
		aAdd( aBody, { "", "000028", "64"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - FUNDAÇAO DE PREVIDENCIA COMPLEMENTAR DO SERVIDOR - FUNPRESP - 13. SALARIO"  																					, "" 		} )
		aAdd( aBody, { "", "000029", "71"	, "ISENCOES DO IRRF - PARCELA ISENTA 65 ANOS - 13. SALARIO"  																																			, "" 		} )
		aAdd( aBody, { "", "000030", "72"	, "ISENCOES DO IRRF - DIARIAS"  																																										, "" 		} )
		aAdd( aBody, { "", "000031", "73"	, "ISENCOES DO IRRF - AJUDA DE CUSTO"  																																									, "" 		} )
		aAdd( aBody, { "", "000032", "74"	, "ISENCOES DO IRRF - INDENIZAÇAO E RESCISAO DE CONTRATO, INCLUSIVE A TITULO DE PDV E ACIDENTES DE TRABALHO"  																							, "" 		} )
		aAdd( aBody, { "", "000033", "75"	, "ISENCOES DO IRRF - ABONO PECUNIARIO"  																																								, "" 		} )
		aAdd( aBody, { "", "000034", "76"	, "ISENCOES DO IRRF - PENSAO, APOSENTADORIA OU REFORMA POR MOLESTIA GRAVE OU ACIDENTE EM SERVIÇO - REMUNERAÇAO MENSAL"  																				, "" 		} )
		aAdd( aBody, { "", "000035", "77"	, "ISENCOES DO IRRF - PENSAO, APOSENTADORIA OU REFORMA POR MOLESTIA GRAVE OU ACIDENTE EM SERVIÇO - 13. SALARIO"  																						, "" 		} )
		aAdd( aBody, { "", "000036", "78"	, "ISENCOES DO IRRF - VALORES PAGOS A TITULAR OU SOCIO DE MICROEMPRESA OU EMPRESA DE PEQUENO PORTE, EXCETO PRO-LABORE E ALUGUEIS"  																		, "20210630"} )
		aAdd( aBody, { "", "000037", "79"	, "ISENCOES DO IRRF - OUTRAS ISENCOES (O NOME DA RUBRICA DEVE SER CLARO PARA IDENTIFICAÇAO DA NATUREZA DOS VALORES)"  																					, "" 		} )
		aAdd( aBody, { "", "000038", "81"	, "DEMANDAS JUDICIAIS - DEPOSITO JUDICIAL"  																																							, "20210630"} )
		aAdd( aBody, { "", "000039", "82"	, "DEMANDAS JUDICIAIS - COMPENSAÇAO JUDICIAL DO ANO CALENDARIO"  																																		, "20210630"} )
		aAdd( aBody, { "", "000040", "83"	, "DEMANDAS JUDICIAIS - COMPENSAÇAO JUDICIAL DE ANOS ANTERIORES"  																																		, "20210630"} )
		aAdd( aBody, { "", "000041", "91"	, "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - INCIDENCIA SUSPENSA EM DECORRENCIA DE DECISAO JUDICIAL, RELATIVAS A BASE DE CALCULO DO IRRF SOBRE REMUNERAÇAO MENSAL"								, "20210630"} )
		aAdd( aBody, { "", "000042", "92"	, "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - INCIDENCIA SUSPENSA EM DECORRENCIA DE DECISAO JUDICIAL, RELATIVAS A BASE DE CALCULO DO IRRF SOBRE 13. SALARIO"										, "20210630"} )
		aAdd( aBody, { "", "000043", "93"	, "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - INCIDENCIA SUSPENSA EM DECORRENCIA DE DECISAO JUDICIAL, RELATIVAS A BASE DE CALCULO DO IRRF SOBRE FERIAS"											, "20210630"} )
		aAdd( aBody, { "", "000044", "94"	, "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - INCIDENCIA SUSPENSA EM DECORRENCIA DE DECISAO JUDICIAL, RELATIVAS A BASE DE CALCULO DO IRRF SOBRE PLR"												, "20210630"} )
		aAdd( aBody, { "", "000045", "95"	, "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - INCIDENCIA SUSPENSA EM DECORRENCIA DE DECISAO JUDICIAL, RELATIVAS A BASE DE CALCULO DO IRRF SOBRE RRA"												, "20210630"} )
		aAdd( aBody, { "", "000046", "01"	, "REDIMENTO NAO TRIBUTAVEL EM FUNCAO DE ACORDOS INTERNACIONAIS DE BITRIBUTACAO"  																														, "20210430"} )
		aAdd( aBody, { "", "000047", "18"	, "BASE DE CALCULO DO IRRF - REMUNERACAO RECEBIDA POR RESIDENTE FISCAL NO EXTERIOR"  																													, "20170901"} )
		aAdd( aBody, { "", "000048", "55"	, "DEDUCOES DA BASE DE CALCULO DO IRRF - PENSAO ALIMENTICIA - RRA"  																																	, "20210630"} )
		aAdd( aBody, { "", "000049", "70"	, "ISENCOES DO IRRF - PARCELA ISENTA 65 ANOS - REMUNERACAO MENSAL"  																																	, "20210509"} )
		
		//Simplificação do eSocial Versão S-1.0
		aAdd( aBody, { "", "000050", "09"	, "OUTRAS VERBAS NÃO CONSIDERADAS COMO BASE DE CÁLCULO OU RENDIMENTO"  																																	, "20210430"} )

		//Simplificação do eSocial Versão S-1.0 -- Dedução do rendimento tributável do IRRF
		aAdd( aBody, { "", "000051", "48" 	, "DEDUÇÃO DO RENDIMENTO TRIBUTÁVEL DO IRREF - PREVIDÊNCIA PRIVADA - FÉRIAS"  																															, "20230116", 1032.08} )
		aAdd( aBody, { "", "000052", "65" 	, "DEDUÇÃO DO RENDIMENTO TRIBUTÁVEL DO IRREF - FUNDAÇÃO DE PREVIDÊNCIA COMPLEMENTAR DO SERVIDOR PÚBLICO - FÉRIAS"  																						, "" 		} )
		aAdd( aBody, { "", "000053", "66" 	, "DEDUÇÃO DO RENDIMENTO TRIBUTÁVEL DO IRREF - FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - FÉRIAS"  																							, "" 		} )
		aAdd( aBody, { "", "000054", "67" 	, "DEDUÇÃO DO RENDIMENTO TRIBUTÁVEL DO IRREF - PLANO PRIVADO COLETIVO DE ASSISTÊNCIA À SAÚDE"  																											, "" 		} )

		//RENDIMENTO NÃO TRIBUTÁVEL OU ISENTO DO IRRF
		aAdd( aBody, { "", "000055", "70" 	, "ISENCOES DO IRRF - PARCELA ISENTA 65 ANOS - REMUNERAÇÃO MENSAL"  																																	, "" 		} )
		aAdd( aBody, { "", "000056", "700" 	, "ISENCOES DO IRRF - AUXÍLIO MORADIA"  																																				 				, "" 		} )
		aAdd( aBody, { "", "000057", "701" 	, "ISENCOES DO IRRF - PARTE NÃO TRIBUTÁVEL DO VALOR DE SERVIÇO DE TRANSPORTE DE PASSAGEIROS OU CARGAS"  																								, "" 		} )		
			
		// EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTÁVEL (BASE DE CÁLCULO DO IR)
		aAdd( aBody, { "", "000058", "9011" , "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - REMUNERAÇÃO MENSAL"  																																, "" 		} )
		aAdd( aBody, { "", "000059", "9012" , "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - 13º SALÁRIO"  																																		, "" 		} )
		aAdd( aBody, { "", "000060", "9013" , "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - FÉRIAS"  																																			, "" 		} )
		aAdd( aBody, { "", "000061", "9014" , "EXIGIBILIDADE SUSPENSA - RENDIMENTO TRIBUTAVEL - PLR"  																																				, "" 		} )

		// EXIGIBILIDADE SUSPENSA - RETENÇÃO DO IRRF EFETUADA SOBRE
		aAdd( aBody, { "", "000062", "9031" , "EXIGIBILIDADE SUSPENSA - RETENÇÃO DO IRRF EFETUADA SOBRE: - REMUNERAÇÃO MENSAL"  																													, "" 		} )
		aAdd( aBody, { "", "000063", "9032" , "EXIGIBILIDADE SUSPENSA - RETENÇÃO DO IRRF EFETUADA SOBRE: - 13º SALÁRIO"  																															, "" 		} )
		aAdd( aBody, { "", "000064", "9033" , "EXIGIBILIDADE SUSPENSA - RETENÇÃO DO IRRF EFETUADA SOBRE: - FÉRIAS"  																																, "" 		} )
		aAdd( aBody, { "", "000065", "9034" , "EXIGIBILIDADE SUSPENSA - RETENÇÃO DO IRRF EFETUADA SOBRE: - PLR"  																																	, "" 		} )
		aAdd( aBody, { "", "000066", "9831" , "EXIGIBILIDADE SUSPENSA - RETENÇÃO DO IRRF EFETUADA SOBRE: - DEPÓSITO JUDICIAL - MENSAL"  																											, "" 		} )
		aAdd( aBody, { "", "000067", "9832" , "EXIGIBILIDADE SUSPENSA - RETENÇÃO DO IRRF EFETUADA SOBRE: - DEPÓSITO JUDICIAL - 13º SALÁRIO"  																										, "" 		} )
		aAdd( aBody, { "", "000068", "9833" , "EXIGIBILIDADE SUSPENSA - RETENÇÃO DO IRRF EFETUADA SOBRE: - DEPÓSITO JUDICIAL - FÉRIAS"  																											, "" 		} )
		aAdd( aBody, { "", "000069", "9834" , "EXIGIBILIDADE SUSPENSA - RETENÇÃO DO IRRF EFETUADA SOBRE: - DEPÓSITO JUDICIAL - PLR"  																												, "" 		} )
		
		//EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CÁLCULO DO IRRF
		aAdd( aBody, { "", "000070", "9041" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - PREVIDÊNCIA SOCIAL OFICIAL - PSO - REMUNERAÇÃO MENSAL"  																				, ""		} )
		aAdd( aBody, { "", "000071", "9042" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - PSO - 13º SALÁRIO"  																													, ""		} )
		aAdd( aBody, { "", "000072", "9043" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - PSO - FÉRIAS"  																														, ""		} )
		aAdd( aBody, { "", "000073", "9046" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - PREVIDÊNCIA PRIVADA - SALÁRIO MENSAL"  																								, "20230116", 1032.08} )
		aAdd( aBody, { "", "000074", "9047" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - PREVIDÊNCIA PRIVADA - 13º SALÁRIO"  																									, "20230116", 1032.08} )
		aAdd( aBody, { "", "000075", "9048" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - PREVIDÊNCIA PRIVADA - FÉRIAS"  																										, "20230116", 1032.08} )
		aAdd( aBody, { "", "000076", "9051" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - PENSÃO ALIMENTÍCIA - REMUNERAÇÃO MENSAL"  																								, ""		} )
		aAdd( aBody, { "", "000077", "9052" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - PENSÃO ALIMENTÍCIA - 13º SALÁRIO"  																									, ""		} )
		aAdd( aBody, { "", "000078", "9053" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - PENSÃO ALIMENTÍCIA - FÉRIAS"  																											, ""		} )
		aAdd( aBody, { "", "000079", "9054" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - PENSÃO ALIMENTÍCIA - PLR"  																											, ""		} )
		aAdd( aBody, { "", "000080", "9061" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - REMUNERAÇÃO MENSAL"  															, ""		} )
		aAdd( aBody, { "", "000081", "9062" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - 13º SALÁRIO"  																	, ""		} )
		aAdd( aBody, { "", "000082", "9063" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - FUNDAÇÃO DE PREVIDÊNCIA COMPLEMENTAR DO SERVIDOR PÚBLICO - REMUNERAÇÃO MENSAL"  														, ""		} )
		aAdd( aBody, { "", "000083", "9064" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - FUNDAÇÃO DE PREVIDÊNCIA COMPLEMENTAR DO SERVIDOR PÚBLICO - 13º SALÁRIO"  																, ""		} )
		aAdd( aBody, { "", "000084", "9065" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - FUNDAÇÃO DE PREVIDÊNCIA COMPLEMENTAR DO SERVIDOR PÚBLICO - FÉRIAS"  																	, ""		} )
		aAdd( aBody, { "", "000085", "9066" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - FUNDO DE APOSENTADORIA PROGRAMADA INDIVIDUAL - FAPI - FÉRIAS"  																		, ""		} )
		aAdd( aBody, { "", "000086", "9067" , "EXIGIBILIDADE SUSPENSA - DEDUÇÃO DA BASE DE CALCULO DO IRRF - PLANO PRIVADO COLETIVO DE ASSISTÊNCIA À SAÚDE"  																						, ""		} )
		
		//COMPENSAÇÃO JUDICIAL
		aAdd( aBody, { "", "000087", "9082" , "COMPENSAÇÃO JUDUCIAL - COMPENSAÇÃO JUDICIAL DO ANO-CALENDÁRIO"  																																		, ""		} )
		aAdd( aBody, { "", "000088", "9083" , "COMPENSAÇÃO JUDUCIAL - COMPENSAÇÃO JUDICIAL DE ANOS ANTERIORES"  																																	, ""		} )

		//NOVAS INCLUSÕES LEIAUTE 1.0 - RENDIMENTO NÃO TRIBUTÁVEL OU ISENTO DO IRRF
		aAdd( aBody, { "", "000089", "7900"	, "RENDIMENTO NÃO TRIBUTÁVEL OU ISENTO DO IRRF - VERBA DE FOLHA DE PAGTO DE NATUR. DIVERSA DE RENDIMENTO OU RETENÇÃO/ISENÇÃO/DEDUÇÃO DE IR (EX: DESCONTO DE CONVÊNIO FARMÁCIA, DE CONSIGNAÇÕES, ETC.)" 	, ""		} )
		
		//NOVAS INCLUSÕES LEIAUTE 1.0 - CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES
		aAdd( aBody, { "", "000090", "7950" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - RENDIMENTO NÃO TRIBUTÁVEL"  																													, ""		} )
		aAdd( aBody, { "", "000091", "7951" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - RENDIMENTO NÃO TRIBUTÁVEL EM FUNÇÃO DE ACORDOS INTERNACIONAIS DE BITRIBUTAÇÃO"  																, ""		} )
		aAdd( aBody, { "", "000092", "7952" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - RENDIMENTO TRIBUTÁVEL - RRA"  																													, ""		} )
		aAdd( aBody, { "", "000093", "7953" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - RETENÇÃO DE IR - RRA"  																															, ""		} )
		aAdd( aBody, { "", "000094", "7954" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - PREVIDÊNCIA SOCIAL OFICIAL - RRA"  																												, ""		} )
		aAdd( aBody, { "", "000095", "7955" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - PENSÃO ALIMENTÍCIA - RRA"  																														, ""		} )
		aAdd( aBody, { "", "000096", "7956" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - VALORES PAGOS A TITULAR OU SÓCIO DE MICROEMPRESA OU EMPRESA DE PEQUENO PORTE, EXCETO PRÓ-LABORE E ALUGUÉIS"  									, ""		} )
		aAdd( aBody, { "", "000097", "7957" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - DEPÓSITO JUDICIAL"  																															, ""		} )
		aAdd( aBody, { "", "000098", "7958" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - COMPENSAÇÃO JUDICIAL DO ANO-CALENDÁRIO"   																										, ""		} )
		aAdd( aBody, { "", "000099", "7959" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - COMPENSAÇÃO JUDICIAL DE ANOS ANTERIORES"  																										, ""		} )
		aAdd( aBody, { "", "000100", "7960" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - EXIGIBILIDADE SUSPENSA - REMUNERAÇÃO MENSAL"  																									, ""		} )
		aAdd( aBody, { "", "000101", "7961" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - EXIGIBILIDADE SUSPENSA - 13º SALÁRIOL"  																										, ""		} )
		aAdd( aBody, { "", "000102", "7962" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - EXIGIBILIDADE SUSPENSA - FÉRIAS"  																												, ""		} )
		aAdd( aBody, { "", "000103", "7963" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - EXIGIBILIDADE SUSPENSA - PLR"  																													, ""		} )
		aAdd( aBody, { "", "000104", "7964" , "CÓDIGOS PARA COMPATIBILIDADE DE VERSÕES ANTERIORES - EXIGIBILIDADE SUSPENSA - RRA"  , ""} )
		aAdd( aBody, { "", "000105", "9" 	, "VERBA TRANSITADA PELA FOLHA DE PAGAMENTO DE NATUREZA DIVERSA DE RENDIMENTO OU RETENÇÃO/ISENÇÃO/DEDUÇÃO DE IR (EXEMPLO: DESCONTO DE CONVÊNIO FARMÁCIA, DESCONTO DE CONSIGNAÇÕES, ETC.)"  				, ""		} )

		//NOTA TÉCNICA S-1.0 Nº 06/2022
		aAdd( aBody, { "", "000106", "46" 	, "PREVIDÊNCIA COMPLEMENTAR - SALÁRIO MENSAL"  																																							, ""		, 1032.08} )
		aAdd( aBody, { "", "000107", "47" 	, "PREVIDÊNCIA COMPLEMENTAR - 13º SALÁRIO"  																																							, ""		, 1032.08} )
		aAdd( aBody, { "", "000108", "48" 	, "PREVIDÊNCIA COMPLEMENTAR - FÉRIAS"  																																									, ""		, 1032.08} )
		aAdd( aBody, { "", "000109", "9046" , "PREVIDÊNCIA COMPLEMENTAR - SALÁRIO MENSAL"  																																							, ""		, 1032.08} )
		aAdd( aBody, { "", "000110", "9047" , "PREVIDÊNCIA COMPLEMENTAR - 13º SALÁRIO"  																																							, ""		, 1032.08} )
		aAdd( aBody, { "", "000111", "9048" , "PREVIDÊNCIA COMPLEMENTAR - FÉRIAS"   																																								, ""		, 1032.08} ) 	

		aAdd( aRet, { aHeader, aBody } )
		
	EndIf

Return( aRet )
