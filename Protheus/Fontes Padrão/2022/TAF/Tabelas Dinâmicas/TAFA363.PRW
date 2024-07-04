#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA363.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA363
Cadastro MVC de Codigos Retencao Rec. Federal

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA363()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Cadastro de Codigos Retencao Rec. Federal"
oBrw:SetAlias( 'CW9')
oBrw:SetMenuDef( 'TAFA363' ) 
CW9->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA363" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCW9  :=  FWFormStruct( 1, 'CW9' )
Local oModel    :=  MPFormModel():New( 'TAFA363' )

oModel:AddFields('MODEL_CW9', /*cOwner*/, oStruCW9)
oModel:GetModel('MODEL_CW9'):SetPrimaryKey({'CW9_FILIAL','CW9_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Denis R de Oliveira
@since 15/05/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA363' )
Local   oStruCW9    :=  FWFormStruct( 2, 'CW9' )
Local   oView       :=  FWFormView():New()
                                            
oStruCW9:RemoveField('CW9_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_CW9', oStruCW9, 'MODEL_CW9' )

oView:EnableTitleView( 'VIEW_CW9', STR0001 )    //"Cadastro de Codigos Retencao Rec. Federal"
oView:CreateHorizontalBox( 'FIELDSCW9', 100 )
oView:SetOwnerView( 'VIEW_CW9', 'FIELDSCW9' )

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

nVerAtu := 1031.22

If nVerEmp < nVerAtu
	aAdd( aHeader, "CW9_FILIAL" )
	aAdd( aHeader, "CW9_ID" )
	aAdd( aHeader, "CW9_CODIGO" )
	aAdd( aHeader, "CW9_DESCRI" )
	aAdd( aHeader, "CW9_DESCOM" )
	aAdd( aHeader, "CW9_DTINI" )
	aAdd( aHeader, "CW9_DTFIN" )

	//aAdd( aBody, { "", "7ebb9b31-02d8-bb09-d6dd-0ce453a2ba2e", "4085", "CSLL – RETENÇÃO ÓRGÃOS/AUTARQUIAS/FUNDAÇÕES DOS ESTADOS, DISTRITO FEDERAL E MUNICÍPIOS", "", "20140101", "" } )
	aAdd( aBody, { "", "7ebb9b31-02d8-bb09-d6dd-0ce453a2ba2e", "4085", "RETENÇÕES CONTRIBUIÇÕES – PAGAMENTOS EFETUADOS PELOS ESTADOS, MUNICÍPIOS E DF PELA AQUISIÇÃO DE BENS E SERVIÇOS", "", "20140101", "" } )
	//aAdd( aBody, { "", "ae7b99f2-cae7-33ac-706b-b9950dd3fde2", "4397", "CSLL – RETENÇÃO ÓRGÃOS/AUTARQUIAS/FUNDAÇÕES DOS ESTADOS, DISTRITO FEDERAL E MUNICÍPIOS ( PJ AMPARADA POR MEDIDA JUDICIAL)", "", "20140101", "" } )
	aAdd( aBody, { "", "ae7b99f2-cae7-33ac-706b-b9950dd3fde2", "4397", "CSLL – PAGAMENTOS EFETUADOS PELOS ESTADOS, MUNICÍPIOS E DF PELA AQUISIÇÃO DE BENS E SERVIÇOS.", "", "20140101", "" } )
	aAdd( aBody, { "", "8c2ddf93-0687-9c81-959f-153f79e3e585", "5928", "RENDIMENTOS DECORRENTES DE DECISÃO DA JUSTIÇA FEDERAL", "", "20140101", "" } )
	aAdd( aBody, { "", "5ada0c32-fb94-0377-45d1-5348dd41448c", "5936", "RENDIMENTOS DECORRENTES DE DECISÃO DA JUSTIÇA DO TRABALHO", "", "20140101", "" } )
	aAdd( aBody, { "", "cb3426ea-3da8-1914-5af6-0f4f0adc8669", "5944", "PAGAMENTOS DE PESSOA JURÍDICA A PESSOA JURÍDICA POR SERVIÇOS DE FACTORING", "", "20140101", "" } )
	//aAdd( aBody, { "", "cd2b0233-1d81-79b8-e6b0-b60a8973ba01", "6147", "ALIMENTAÇÃO/ENERGIA ELÉTRICA/SERVIÇOS PRESTADOS COM EMPREGO DE MATERIAIS/CONSTRUÇÃO CIVIL POR EMPREITADA COM EMPREGO DE MATÉRIAS/SERVIÇOS HOSPITALARES PRESTADOS POR ESTABELECIMENTOS", "", "20140101", "" } )
	aAdd( aBody, { "", "cd2b0233-1d81-79b8-e6b0-b60a8973ba01", "6147", "ALIMENTAÇÃO, ENERGIA ELÉTRICA, TRANSPORTE DE CARGAS, BENS EM GERAL, SERVIÇOS C/ FORN. DE BENS", "", "20140101", "" } )
	//aAdd( aBody, { "", "95cb7755-aa39-d3c4-ecc3-93b9cf109e0b", "6175", "PASSAGENS AÉREAS, RODOVIÁRIAS E DEMAIS SERVIÇOS DE TRANSPORTE DE PASSAGEIROS, EXCETO AS RELACIONADAS NO CÓDIGO 8850", "", "20140101", "" } )
	aAdd( aBody, { "", "95cb7755-aa39-d3c4-ecc3-93b9cf109e0b", "6175", "PASSAGENS AÉREAS, RODOVIÁRIAS E DEMAIS SERVIÇOS DE TRANSPORTE DE PASSAGEIROS", "", "20140101", "" } )
	aAdd( aBody, { "", "563e922b-16b1-27ca-a1d7-2b17cf4fe6c4", "6188", "SERVIÇOS PRESTADOS POR BANCOS COMERCIAIS, DE INVESTIMENTO E DE DESENVOLVIMENTO, CAIXAS ECONÔMICAS, SOCIEDADES DE CRÉDITO, FINANCIAMENTO, INVESTIMENTO, DE CRÉDITO IMOBILIÁRIO E CÂMBIO", "", "20140101", "" } )
	//aAdd( aBody, { "", "7d802bcf-52c8-e1f2-74ad-5e20c8744623", "6190", "SERVIÇOS DE ABASTECIMENTO DE ÁGUA, TELEFONE, CORREIO E TELÉGRAFOS, VIGILÂNCIA, LIMPEZA, LOCAÇÃO DE MÃO DE OBRA, INTERMEDIAÇÃO DE NEGÓCIOS, ADMINISTRAÇÃO OU CESSÃO DE BENS IMÓVEIS, MÓ", "", "20140101", "" } )
	aAdd( aBody, { "", "7d802bcf-52c8-e1f2-74ad-5e20c8744623", "6190", "ÁGUA, TELEFONE, CORREIOS, VIGILÂNCIA, LIMPEZA, LOCAÇÃO DE MÃO-DE-OBRA, LOCAÇÃO E DEMAIS SERVIÇOS", "", "20140101", "" } )
	//aAdd( aBody, { "", "88553b1c-38e6-4a3a-c162-98b569600b04", "6228", "CSLL - RETENÇÃO EMPRESA PÚBLICA/SOCIEDADE DE ECONOMIA MISTA/DEMAIS ENTIDADES (PJ AMPARADA POR MEDIDA JUDICIAL)", "", "20140101", "" } )
	aAdd( aBody, { "", "88553b1c-38e6-4a3a-c162-98b569600b04", "6228", "CSLL – ISENÇÃO OU SUSPENSÃO AMPARADA POR LEI, DE PIS/PASEP E/OU COFINS E/OU IRPJ", "", "20140101", "" } )
	//aAdd( aBody, { "", "fb0ef8f0-304d-7a03-81e5-85ef82d10d8f", "6256", "IRPJ - RETENÇÃO EMPRESA PÚBLICA/SOCIEDADE DE ECONOMIA MISTA/DEMAIS ENTIDADES (PJ AMPARADA POR MEDIDA JUDICIAL)", "", "20140101", "" } )
	aAdd( aBody, { "", "fb0ef8f0-304d-7a03-81e5-85ef82d10d8f", "6256", "IRPJ – ISENÇÃO OU SUSPENSÃO AMPARADA POR LEI, DE CSLL E/OU PIS/PASP E/OU COFINS", "", "20140101", "" } )
	//aAdd( aBody, { "", "4191e39e-754b-e3cd-ac30-3a77bad581c0", "8739", "GASOLINA/DIESEL/GLP E ÁLCOOL ADQUIRIDO NO VAREJO", "", "20140101", "" } )
	aAdd( aBody, { "", "4191e39e-754b-e3cd-ac30-3a77bad581c0", "8739", "GASOLINA, ÓLEO DIESEL E GLP, ADQ. DE DISTRIB. E VAREJ. E ÁLCOOL ADQ. DE VAREJ", "", "20140101", "" } )
	//aAdd( aBody, { "", "d3e577c2-1d74-39a9-ae46-83c63a48db50", "8767", "TRANSPORTE INTERNACIONAL DE CARGAS OU DE PASSAGEIROS EFETUADOS POR EMPRESAS NACIONAIS/ESTALEIROS NAVAIS BRASILEIROS NAS ATIVIDADES DE CONSTRUÇÃO, CONSERVAÇÃO, MODERNIZAÇÃO, CONVERSÃO", "", "20140101", "" } )
	aAdd( aBody, { "", "d3e577c2-1d74-39a9-ae46-83c63a48db50", "8767", "MEDICAMENTOS E PROD. DE PERFUMARIA ETC...(TIPI) ADQ. DISTRIB. OU VAREJ", "", "20140101", "" } )
	//aAdd( aBody, { "", "0407352d-cf75-d578-96b5-1689a4bf9644", "8850", "TRANSPORTE INTERNACIONAL DE PASSAGEIROS EFETUADO POR EMPRESAS NACIONAIS", "", "20140101", "" } )
	aAdd( aBody, { "", "0407352d-cf75-d578-96b5-1689a4bf9644", "8850", "BENS SERVIÇOS ADQUIRIDOS DE SOCIEDADES COOP. E ASS. PROFISSIONAIS OU ASSEMELHADOS", "", "20140101", "" } )
	aAdd( aBody, { "", "445e20f6-8f74-ee42-1959-22f81ce9bd48", "8863", "BENS OU SERVIÇOS ADQUIRIDOS DE SOCIEDADES COOPERATIVAS E ASSOCIAÇÕES PROFISSIONAIS OU ASSEMELHADAS", "", "20140101", "" } )
	//aAdd( aBody, { "", "96eca266-cb36-437d-506f-e95fd88b1237", "9060", "GASOLINA, ÓLEO DIESEL, GÁS LIQUEFEITO DE PETRÓLEO (GLP) E QUEROSENE DE AVIAÇÃO ADQUIRIDO DE PRODUTOR OU IMPORTADOR/DEMAIS COMBUSTÍVEIS DERIVADOS DE PETRÓLEO, ADQUIRIDOS DE PRODUTOR,", "", "20140101", "" } )
	aAdd( aBody, { "", "96eca266-cb36-437d-506f-e95fd88b1237", "9060", "QUEROSENE DE AVIAÇÃO ADQUIRIDO DE PRODUTOR OU IMPORTADOR", "", "20140101", "" } )
	aAdd( aBody, { "", "c1d3bb4a-cf44-dc1e-8efe-03223296ef4f", "9997", "OUTRAS RETENÇÕES NÃO ESPECIFICADAS ACIMA", "", "20140101", "" } )
	aAdd( aBody, { "", "e139b360-374c-64d7-56e6-ed3b11b74f40", "0916", "PRÊMIOS OBTIDOS EM CONCURSOS E SORTEIOS", "", "20140101", "" } )
	//aAdd( aBody, { "", "9e3976e2-9d48-ecc5-0d87-66629f401659", "0924", "FICART E DEMAIS RENDIMENTOS DE CAPITAL (DAY-TRADE)", "", "20140101", "" } )
	aAdd( aBody, { "", "9e3976e2-9d48-ecc5-0d87-66629f401659", "0924", "FUNDOS DE INVESTIMENTO CULTURAL E ARTÍSTICO (FICART) E DEMAIS RENDIMENTOS DE CAPITAL", "", "20140101", "" } )
	aAdd( aBody, { "", "ad311761-7c17-c50f-648d-f40538dacdbe", "1708", "REMUNERAÇÃO DE SERVIÇOS PROFISSIONAIS PRESTADOS POR PESSOA JURÍDICA", "", "20140101", "" } )
	aAdd( aBody, { "", "37535630-9b41-4684-9798-ee8efbdd2f8e", "3277", "RENDIMENTOS DE PARTES BENEFICIÁRIAS OU DE FUNDADOR", "", "20140101", "" } )
	//aAdd( aBody, { "", "b572770e-68a9-7278-b026-3aac03c33090", "3426", "APLICAÇÕES FINANCEIRAS DE RENDA FIXA", "", "20140101", "" } )
	aAdd( aBody, { "", "b572770e-68a9-7278-b026-3aac03c33090", "3426", "APLICAÇÕES FINANCEIRAS DE RENDA FIXA, EXCETO EM FUNDOS DE INVESTIMENTO - PESSOA JURÍDICA", "", "", "" } )
	//aAdd( aBody, { "", "f925d75e-efb1-7c63-2480-cde691f24bd8", "5204", "FRANQUIAS EMPRESARIAIS/LUCROS CESSANTES", "", "20140101", "" } )
	aAdd( aBody, { "", "f925d75e-efb1-7c63-2480-cde691f24bd8", "5204", "JUROS E INDENIZAÇÕES POR LUCROS CESSANTES", "", "20140101", "" } )
	//aAdd( aBody, { "", "365a6769-d645-6ec3-c188-61f1120a8292", "5232", "APLICAÇÕES FINANCEIRAS EM FUNDOS DE INVESTIMENTO IMOBILIÁRIOS", "", "20140101", "" } )
	aAdd( aBody, { "", "365a6769-d645-6ec3-c188-61f1120a8292", "5232", "FUNDOS DE INVESTIMENTO IMOBILIÁRIOS", "", "20140101", "" } )
	aAdd( aBody, { "", "daf2d9f0-11b8-bf1a-a1b9-f2a57821bb00", "5273", "OPERAÇÕES DE SWAP", "", "20140101", "" } )
	aAdd( aBody, { "", "c985a977-bae1-9e9b-6501-a84f61cf998f", "5557", "MERCADO DE RENDA VARIÁVEL", "", "20140101", "" } )
	aAdd( aBody, { "", "1f541b8f-9f8e-a631-bd75-9785e2684b60", "5706", "JUROS SOBRE O CAPITAL PRÓPRIO", "", "20140101", "" } )
	aAdd( aBody, { "", "8442467e-cd69-6896-0471-0cab30c49c0c", "5928", "RENDIMENTOS DECORRENTES DE DECISÃO DA JUSTIÇA FEDERAL", "", "20140101", "" } )
	aAdd( aBody, { "", "7c2b72b5-85c4-776c-e502-cb6c7f862242", "5936", "RENDIMENTOS DECORRENTES DE DECISÃO DA JUSTIÇA DO TRABALHO", "", "20140101", "" } )
	//aAdd( aBody, { "", "f095562d-a545-cca4-d1b7-c087e5a8edf4", "5944", "PAGAMENTO DE PESSOA JURÍDICA A PESSOA JURÍDICA POR SERVIÇOS DE FACTORING", "", "20140101", "" } )
	//aAdd( aBody, { "", "fc0fa76c-cefa-f87b-c306-04fe082e1f93", "5952", "CSLL – RETENÇÃO SOBRE PAGAMENTOS DE PESSOA JURÍDICA A PESSOA JURÍDICA DE DIREITO PRIVADO/LEI N° 10.833/2003", "", "20140101", "" } )
	aAdd( aBody, { "", "fc0fa76c-cefa-f87b-c306-04fe082e1f93", "5952", "RETENÇÕES DE CONTRIBUIÇÕES PAGAMENTO PJ A PJ DE DIREITO PRIVADO","","20140101", "" } )
	//aAdd( aBody, { "", "509ccc7c-37da-1419-a1ef-3893d75cc895", "5987", "CSLL – RETENÇÃO SOBRE PAGAMENTOS DE PESSOA JURÍDICA A PESSOA JURÍDICA DE DIREITO PRIVADO- PAGAMENTOS A PJ AMPARADA POR MEDIDA JUDICIAL (LEI N° 10.833/2003)", "", "20140101", "" } )
	aAdd( aBody, { "", "509ccc7c-37da-1419-a1ef-3893d75cc895", "5987", "CSLL – RETENÇÃO PAGAMENTO PJ A PJ DE DIREITO PRIVADO", "", "20140101", "" } )
	//aAdd( aBody, { "", "888063f9-689a-37cf-1ea8-0bf447aeacef", "6800", "APLICAÇÕES FINANCEIRAS EM FUNDOS DE INVESTIMENTO - RENDA FIXA", "", "20140101", "" } )
	aAdd( aBody, { "", "888063f9-689a-37cf-1ea8-0bf447aeacef", "6800", "FUNDOS DE INVESTIMENTO E FUNDOS DE INVESTIMENTO EM QUOTAS DE FUNDOS DE INVESTIMENTO", "", "20140101", "" } )
	//aAdd( aBody, { "", "328cc640-6409-580e-eb4c-5054cdb0e034", "6813", "APLICAÇÕES FINANCEIRAS EM FUNDOS DE INVESTIMENTO – AÇÕES", "", "20140101", "" } )
	aAdd( aBody, { "", "328cc640-6409-580e-eb4c-5054cdb0e034", "6813", "FUNDOS DE INVESTIMENTO EM AÇÕES E FUNDOS DE INVESTIMENTO EM QUOTAS DE FUNDOS DE INVESTIMENTO EM AÇÕES", "", "20140101", "" } )
	//aAdd( aBody, { "", "3a898632-95be-8143-0e8d-44bb7a5bb53f", "8045", "RENDIMENTOS NAO ESPECIFICADOS (CONDENACOES JUDICIAIS, MULTAS E VANTAGENS)", "", "20140101", "" } )
	aAdd( aBody, { "", "3a898632-95be-8143-0e8d-44bb7a5bb53f", "8045", "COMISSÕES E CORRETAGENS PAGOS À PJ E SERVIÇOS DE PROPAGANDA PRESTADOS POR PJ (ART. 53, LEI 7.450/85)", "", "20140101", "" } )
	aAdd( aBody, { "", "d0734388-82bd-9981-2c37-6e6ba5f1ed18", "8468", "OPERAÇÕES DAY-TRADE", "", "20140101", "" } )
	//aAdd( aBody, { "", "56d17263-5eda-b5c5-cb72-f0a595de1fc2", "9385", "MULTAS E QUALQUER OUTRA VANTAGEM EM VIRTUDE DE RESCISÃO DE CONTRATO", "", "20140101", "" } )
	aAdd( aBody, { "", "56d17263-5eda-b5c5-cb72-f0a595de1fc2", "9385", "MULTAS E VANTAGENS", "", "20140101", "" } )
	aAdd( aBody, { "", "b956199c-8d48-0320-1047-a12f0dc82631", "9998", "CSLL - OUTRAS RETENÇÕES NÃO ESPECIFICADAS ACIMA", "", "20140101", "" } )
	aAdd( aBody, { "", "9ceac37d-b40b-076c-0c6f-f98da7d2a551", "9999", "IRPJ - OUTRAS RETENÇÕES NÃO ESPECIFICADAS ACIMA", "", "20140101", "" } )
	aAdd( aBody, { "", "f527145a-1e3d-cf96-64b1-48d63beeb5f6", "1895", "IRRF - RENDIMENTOS DECORRENTES DE DECISÃO JUDICIAL DOS ESTADOS E MUNICÍPIOS, EXCETO ART. 12A DE LEI Nº 7.713/88","","20160101","" })
	// Reinf 1.3
	aAdd( aBody, { "", "cbc9f0f2-5d44-149d-6fd4-a47ab1eb06e8", "3208", "ALUGUÉIS E ROYALTIES", "", "", "" } )
	aAdd( aBody, { "", "db4f2730-fe75-c33a-d8ed-a952f48c7194", "3223", "RESGATE DE PREVIDÊNCIA COMPLEMENTAR - MODALIDADE CONTRIBUIÇÃO DEFINIDA/VARIÁVEL - NÃO OPTANTE PELA TRIBUTAÇÃO EXCLUSIVA", "", "", "" } )
	aAdd( aBody, { "", "329323a6-af32-8237-7f87-96cbf6f47a0b", "3533", "APOSENTADORIA, RESERVA, REFORMA OU PENSÃO PAGOS POR PREVIDÊNCIA PÚBLICA", "", "", "" } )
	aAdd( aBody, { "", "bda6c20a-41bc-f427-f681-1e552fcc29c8", "3540", "BENEFÍCIO DE PREVIDÊNCIA COMPLEMENTAR - NÃO OPTANTE PELA TRIBUTAÇÃO EXCLUSIVA", "", "", "" } )
	aAdd( aBody, { "", "7b6597ed-1dc5-3e9a-d271-12079f915b2d", "3540", "RESGATE DE PREVIDÊNCIA COMPLEMENTAR- MODALIDADE BENEFÍCIO DEFINIDO - NÃO OPTANTE PELA TRIBUTAÇÃO EXCLUSIVA", "", "", "" } )
	aAdd( aBody, { "", "814c29a4-98d7-8512-dedb-4f29f3c50f4a", "3579", "REGASTE DE PREVIDÊNCIA COMPLEMENTAR - OPTANTE PELA TRIBUTAÇÃO EXCLUSIVA", "", "", "" } )
	aAdd( aBody, { "", "97afe278-f99e-7cc5-b1c3-8c7fa07a01d7", "3280", "REMUNERAÇÃO DE SERVIÇOS PESSOAIS PRESTADOS POR ASSOCIADOS DE COOPERATIVAS DE TRABALHO", "", "", "" } )
	aAdd( aBody, { "", "0b677399-9763-d79f-ff56-ed4807a4d988", "3746", "COFINS – PAGAMENTOS PARA PESSOAS JURÍDICAS REFERIDAS NA LEI Nº 10.485/2002", "", "", "" } )
	aAdd( aBody, { "", "8254b024-438b-7534-757a-d6e6adbeb0f7", "3770", "CONTRIBUIÇÃO PIS/PASEP – PAGAMENTOS PARA PESSOAS JURÍDICAS REFERIDAS NA LEI º 10.485/2002", "", "", "" } )
	aAdd( aBody, { "", "0fbdae42-280a-b077-10c9-1fa54b835efa", "4407", "COFINS – PAGAMENTOS EFETUADOS PELOS ESTADOS, MUNICÍPIOS E DF PELA AQUISIÇÃO DE BENS E SERVIÇOS", "", "", "" } )
	aAdd( aBody, { "", "4760aec7-8919-73ff-6a21-88f0206ec1ea", "4409", "PIS – PAGAMENTOS EFETUADOS PELOS ESTADOS, MUNICÍPIOS E DF PELA AQUISIÇÃO DE BENS E SERVIÇOS.", "", "", "" } )
	aAdd( aBody, { "", "be104ec4-c0c9-05c6-9ba7-859a80f5ef4a", "5217", "PAGAMENTOS A BENEFICIÁRIOS NÃO IDENTIFICADOS", "", "", "" } )
	aAdd( aBody, { "", "ce3af3fd-1a32-fe15-1e5e-6bcd00014093", "5565", "BENEFÍCIO DE PREVIDÊNCIA COMPLEMENTAR – TRIBUTAÇÃO EXCLUSIVA", "", "", "" } )
	aAdd( aBody, { "", "6af0b8a8-aaae-1857-d388-11298854e07e", "5960", "CONFIS – RETENÇÃO PAGAMENTO PJ A PJ DE DIREITO PRIVADO", "", "", "" } )
	aAdd( aBody, { "", "fcb1f2bd-465b-fab6-639f-fe2f92e7ea43", "5979", "PIS/PASEP – RETENÇÃO PAGAMENTO PJ A PJ DE DIREITO PRIVADO", "", "", "" } )
	aAdd( aBody, { "", "7ec2b973-25f2-3a43-7bf0-b7dd7693ff72", "6230", "PIS/PASEP – ISENÇÃO OU SUSPENSÃO AMPARADA POR LEI, DE CSLL E/OU COFINS E/OU IRPJ", "", "", "" } )
	aAdd( aBody, { "", "8efcb29d-42a3-20f2-e0cd-2371d422858b", "6243", "COFINS – ISENÇÃO OU SUSPENSÃO AMPARADA POR LEI, DE CSLL E/OU PIS/PASEP E/OU IRPJ", "", "", "" } )	
	aAdd( aBody, { "", "f5fdc0ac-64de-e22e-793e-fc544fed424f", "6904", "INDENIZAÇÃO POR DANO MORAIS", "", "", "" } )
	aAdd( aBody, { "", "239d7528-32f7-55e2-387f-a6f77c28a025", "8053", "APLICAÇÕES FINANCEIRAS DE RENDA FIXA, EXCETO EM FUNDOS DE INVESTIMENTO - PESSOA FÍSICA", "", "", "" } )
	aAdd( aBody, { "", "43c7042b-bd07-b55a-8037-1cf1001ad217", "8673", "PRÊMIOS EM SORTEIOS DOS JOGOS DE BINGO", "", "", "" } )
	aAdd( aBody, { "", "93fedfef-4e86-c715-3e06-ea8352c99552", "1889", "RENDIMENTOS RECEBIDOS ACUMULADAMENTE", "", "", "" } )
	aAdd( aBody, { "", "9ae55dae-dd03-bdd9-478d-f476c8b89671", "0422", "ROYALTIES E PAGAMENTOS DE ASSISTÊNCIA TÉCNICA", "", "", "" } )
	aAdd( aBody, { "", "eed08342-8826-3d51-d5e9-bb5fb659d777", "0473", "RENDA E PROVENTOS DE QUALQUER NATUREZA", "", "", "" } )
	aAdd( aBody, { "", "5d9526c9-697d-b832-37ac-10577d61c3db", "0481", "JUROS E COMISSÕES EM GERAL", "", "", "" } )
	aAdd( aBody, { "", "730c5ea7-9626-9240-5365-be234a5cc5ed", "0490", "RENDIMENTOS DE APLICAÇÕES EM FUNDOS DE INVESTIMENTO DE CONVERSÃO DE DÉBITOS EXTERNOS", "", "", "" } )
	aAdd( aBody, { "", "3b5ed83a-d26a-9073-fe3a-cf3f9cdc385e", "0610", "TRANSPORTE RODOVIÁRIO INTERNACIONAL DE CARGA POR AUTÔNOMO, RESIDENTE NO PARAGUAI", "", "", "" } )
	aAdd( aBody, { "", "4a21222d-f85d-dceb-142f-2a891a7cd670", "5192", "OBRAS AUDIOVISUAIS, CINEMATOGRÁFICAS E VIDEOFÔNICAS", "", "", "" } )
	aAdd( aBody, { "", "924a52e4-628d-769c-e265-3d664c6252ee", "5286", "APLICAÇÕES EM FUNDOS OU ENTIDADES DE INVESTIMENTO COLETIVO/APLICAÇÕES EM CARTEIRAS DE VALORES MOBILIÁRIOS/ APLICAÇÕES FINANCEIRAS NOS MERCADOS DE RENDA FIXA OU RENDA VARIÁVEL", "", "", "" } )
	aAdd( aBody, { "", "e41dada4-a6c4-4c6f-30a1-db8e6ae85397", "5286", "FRETES INTERNACIONAIS", "", "", "" } )
	aAdd( aBody, { "", "77579394-95c9-23fc-ba6a-87aa9fb38ea1", "9427", "REMUNERAÇÃO DE DIREITOS", "", "", "" } )
	aAdd( aBody, { "", "08874982-408e-5a08-cfa9-707150624ee0", "9453", "JUROS SOBRE O CAPITAL PRÓPRIO", "", "", "" } )
	aAdd( aBody, { "", "f87ce11c-71a6-56bb-bb3a-2e9c8242709d", "9478", "ALUGUEL E ARRENDAMENTO", "", "", "" } )
	aAdd( aBody, { "", "cf200c7f-3930-2b5e-328a-42da25ebe992", "9466", "PREVIDÊNCIA PRIVADA E FAPI", "", "", "" } )
	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
