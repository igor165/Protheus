#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA453.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA453
Cadastro MVC da Tabela de Itens UF Índice de Participação dos Municípios

@author Daniel Schmidt	
@since 25/08/2016
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA453()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Tabela de Itens UF Índice de Participação dos Municípios"
oBrw:SetAlias( 'LF0')
oBrw:SetMenuDef( 'TAFA453' )

LF0->(DbSetOrder(1))

oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Daniel Schmidt	
@since 25/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA453" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Daniel Schmidt	
@since 25/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruLF0 	:= 	FWFormStruct( 1, 'LF0' )
Local oModel 	:= 	MPFormModel():New( 'TAFA453' )

oModel:AddFields('MODEL_LF0', /*cOwner*/, oStruLF0)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Daniel Schmidt	
@since 25/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 	:= 	FWLoadModel( 'TAFA453' )
Local 	oStruLF0 	:= 	FWFormStruct( 2, 'LF0' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_LF0', oStruLF0, 'MODEL_LF0' )

oView:EnableTitleView( 'VIEW_LF0', STR0001 )	//"Cadastro dos Modelos de Documentos Fiscais"
oView:CreateHorizontalBox( 'FIELDSLF0', 100 )
oView:SetOwnerView( 'VIEW_LF0', 'FIELDSLF0' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@author Daniel Schmidt	
@since 25/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

//Verifica se o dicionario aplicado é o da DIEF-CE e da Declan-RJ
nVerAtu := 1031.14


If nVerEmp < nVerAtu

	aAdd( aHeader, "LF0_FILIAL" )
	aAdd( aHeader, "LF0_ID" )
	aAdd( aHeader, "LF0_CODIGO" )
	aAdd( aHeader, "LF0_DESCRI" )
	aAdd( aHeader, "LF0_DTINI" )
	aAdd( aHeader, "LF0_DTFIN" )
	aAdd( aHeader, "LF0_UF" )
	
	//Minas Gerias - 000012

	aAdd( aBody, { "", "4c7a5671-36eb-1e0b-008b-956355c90988", "COOPERATIVAS"									 , "Cooperativas", "20150101","", "000012" } )
	aAdd( aBody, { "", "d30a0ecb-f9f0-4440-577d-df63252bb619", "GERACAO_DE_ENERGIA_ELETRICA"					 , "Geração de Energia Elétrica", "20150101","", "000012" } )
	aAdd( aBody, { "", "414721b1-bd67-cbca-be92-c4c767044ecb", "MUDANCA_DE_MUNICIPIO"							 , "Mudança de Município - município de localização anterior à mudança.", "20170101", "", "000012" })
	aAdd( aBody, { "", "8cc80b91-38d4-86b6-0f3f-1550c7f99a98", "OUTRAS_ENTRADAS_A_DETALHAR_POR_MUNICIPIO"		 , "Outras Entradas a Detalhar por município","20150101","", "000012" } )
	aAdd( aBody, { "", "522d1100-163a-67e8-46e9-a595099692b5", "PRESTACAO_DE_SERVICO_DE_TRANSPORTE_RODOVIARIO"   , "Prestação de Serviço de Transporte Rodoviário","20150101", "", "000012" })
	aAdd( aBody, { "", "0ecf4576-f078-d693-12dd-212bc4694f5f", "PRODUTOS_AGROPECUARIOS"							 , "Produtos Agropecuários/Hortifrutigranjeiros", "20150101","", "000012" } )
	aAdd( aBody, { "", "f0fbc990-44ec-b629-4748-2dcbf1af987e", "TRANSPORTE_TOMADO"								 , "Transporte Tomado", "20150101","", "000012" } )
	
	//Rio Grande do Norte - 000021
	
	aAdd( aBody, { "", "715c6b7e-6638-8c32-c11e-43dfe43d4e23", "IPM 3.1"											 , "Produtos Agropecuários/Hortifrutigranjeiros", "20160101", "", "000021" } )
	aAdd( aBody, { "", "f4f3338f-6485-3d43-a4d9-1d74a2f06085", "IPM 3.2"											 , "Transporte Tomado de Transportador Autônomo ou Empresa Transportadora não Inscrita no Estado", "20160101", "", "000021" })
	aAdd( aBody, { "", "a8063ff4-ccb6-5e9d-56ab-0b83727362b0", "IPM 3.3"											 , "Cooperativas", "20160101", "", "000021" } )
	aAdd( aBody, { "", "7e36d39a-3584-0203-0cfb-db3c421de872", "IPM 3.4"											 , "Geração de Energia Elétrica para Utilização Própria (Autogeração)","20160101", "", "000021" } )
	aAdd( aBody, { "", "d577a0ec-05f6-0539-51d2-93e6f27db4b0", "IPM 3.5"											 , "Vendas em Outros Municípios Fora da Sede do Estabelecimento, com Retenção do ICMS por Substituição Tributária, Inclusive Marketing Porta a Porta a Consumidor Final", "20160101", "", "000021" })
	aAdd( aBody, { "", "ed538573-0046-0363-a9e8-24c359d52c62", "IPM 4.1"											 , "Prestação de Serviço de Transporte Rodoviário de Cargas","20160101", "", "000021" })
	aAdd( aBody, { "", "14bac2eb-6c0b-869f-b241-293b9e37f799", "IPM 4.2"											 , "Prestação de Serviço de Transporte Aéreo de Cargas","20160101", "", "000021" })
	aAdd( aBody, { "", "9f72137f-f78b-d06c-4f0e-4279753a6738", "IPM 4.3"											 , "Prestação de Serviço de Transporte Aquaviário de Cargas","20160101", "", "000021" })
	aAdd( aBody, { "", "95a98788-d39f-5351-e945-1dc2a63744d0", "IPM 4.4"											 , "Extração de Substâncias Minerais - Na Hipótese da Jazida se Estender por Mais de um Município","20160101", "", "000021" })
	aAdd( aBody, { "", "3f5f690f-b810-1cd7-2e3e-d74734c70ea3", "IPM 4.5"											 , "Atividades de Distribuição de Energia Elétrica","20160101", "", "000021" })
	aAdd( aBody, { "", "a86a6305-0602-9b86-d2ed-4a43af9e6c64", "IPM 4.6"											 , "Atividades de Prestação de Serviços de Comunicação/Telecomunicação","20160101", "", "000021" })
	aAdd( aBody, { "", "3be749b0-522a-33cb-461c-6a3746d4eb4d", "IPM 4.7"											 , "Produção de Petróleo e Gás Natural - Na Hipótese da Produção se Estender por Mais de um Município","20160101", "", "000021" })
	aAdd( aBody, { "", "c4b0a6e1-2d97-12d0-2dfe-c3c15d4a966a", "IPM 4.8"											 , "Distribuição de Água Canalizada","20160101", "", "000021" })
	aAdd( aBody, { "", "72b70beb-108c-aaeb-c4f6-f03056c20daf", "IPM 4.9"											 , "Distribuição de Gás Natural Canalizado","20160101", "", "000021" })
	aAdd( aBody, { "", "fdcca1cb-2e6e-8a38-0b94-cc708d6dcc24", "IPM 5.1"											 , "Atividades de Prestação de Serviço de Transporte Dutoviário/Ferroviário","20160101", "", "000021" })
	aAdd( aBody, { "", "0d092cff-4934-b44f-2cfd-ed33f61e4567", "IPM 5.2"											 , "Sistemas de Integração entre Empresário, Sociedade Empresária ou Empresa Individual de Responsabilidade Limitada e Produtores Rurais","20160101", "", "000021" })
	aAdd( aBody, { "", "6b5ee4cf-9678-82a4-4628-581dd3f8849c", "IPM 5.3"											 , "Atividades do Estabelecimento do Contribuinte que se estenderem pelos Territórios de mais de um Município","20160101", "", "000021" })
	aAdd( aBody, { "", "13bd7810-c6fe-7a64-1cc3-5d3b633edd42", "IPM 5.4"											 , "Atividades de Geração/Transmissão de Energia Elétrica","20160101", "", "000021" })
	aAdd( aBody, { "", "1c604cfb-6da4-b415-4ea3-c22ef672ed6b", "IPM 5.5"											 , "Atividade de Fornecimento de Refeição Industrial para Município Distinto daquele da Circunscrição do Contribuinte","20160101", "", "000021" })
	aAdd( aBody, { "", "c35a9dfd-62bd-ac79-dedb-8a8543eddcec", "IPM 5.6"											 , "Mudança do Estabelecimento do Contribuinte para Outro Município","20160101", "", "000021" })
	aAdd( aBody, { "", "d59b647d-f01b-38ea-4f75-45f5a670f3d1", "IPM 5.7"											 , "Outras Hipóteses em que Haja Necessidade de Atribuição de Valor Adicionado Fiscal (VAF) a mais de um Município","20160101", "", "000021" })
	
	//São Paulo - 000027
	
	aAdd( aBody, { "", "97fa4e11-4188-0f1c-6dd4-d24e120ac2ae", "SPDIPAM11"										 , "Compras escrituradas de mercadorias de produtores agropecuários paulistas por município de origem.","20150101", "", "000027" })
	aAdd( aBody, { "", "e65361ee-766a-5dd4-2881-3b018baad9b2", "SPDIPAM12"										 , "Compras não escrituradas de mercadorias de agropecuários paulistas por município de origem e outros ajustes determinados pela SEFAZ-SP.","20150101", "", "000027"  })
	aAdd( aBody, { "", "4d21b580-7abe-7b1d-fcf7-9e57573f2dba", "SPDIPAM13"										 , "Recebimentos, por cooperativas, de mercadorias remetidas por produtores rurais deste Estado, desde que ocorra a efetiva transmissão da propriedade para a cooperativa. Excluem-se as situações em que haja previsão de retorno da mercadoria ao cooperado, como quando a cooperativa é simples depositária.","20150101", "", "000027"  })
	aAdd( aBody, { "", "16680874-fca6-9107-a382-cbca9bad1cb9", "SPDIPAM22"										 , "Vendas efetuadas por revendedores ambulantes autônomos em outros municípios paulistas; Refeições preparadas fora do município do declarante, em operações autorizadas por Regime Especial; operações realizadas por empresas devidamente autorizadas a declarar por meio de uma única Inscrição Estadual; Outros ajustes determinados pela Secretaria da Fazenda mediante instrução expressa e específica.","20150101", "", "000027"  })
	aAdd( aBody, { "", "830292a4-aa98-1dd7-8c7a-8e72046dcf4d", "SPDIPAM23"										 , "Rateio dos serviços de transporte intermunicipal e interestadual iniciados em municípios paulistas.","20150101", "", "000027"  })
	aAdd( aBody, { "", "640085e1-2c8c-9835-b908-1c4fd2d13822", "SPDIPAM24"										 , "Rateio dos serviços de comunicação aos municípios paulistas onde tenham sido prestados.","20150101", "", "000027"  })
	aAdd( aBody, { "", "8017836c-4896-ef35-d365-4777dd87c741", "SPDIPAM25"										 , "Rateio de energia elétrica – Estabelecimento Distribuidor de Energia.","20150101", "", "000027"  })
	aAdd( aBody, { "", "02cef896-3a94-4229-ea86-03efba9d09d7", "SPDIPAM26"										 , "Informar o Valor Adicionado (deduzidos os custos de insumos) referente à produção própria ou arrendada nos estabelecimentos nos quais o contribuinte não possua Inscrição Estadual inscrita.","20150101", "", "000027"  })
	aAdd( aBody, { "", "bcacfe83-5136-5692-ae8d-a88d5f56714d", "SPDIPAM27"										 , "Informar: (i) o valor das operações de saída de mercadorias cujas transações comerciais tenham sido realizadas em outro estabelecimento localizado neste Estado, excluídas as transações comerciais não presenciais; e (ii) os respectivos municípios onde as transações comerciais foram realizadas.","20170701","20171231","000027"})
	aAdd( aBody, { "", "ea11f96a-4702-d686-df95-abcc6358e191", "SPDIPAM27"										 , "Vendas presenciais com saídas/vendas efetuadas em estabelecimento diverso de onde ocorreu a transação/negociação inicial.", "20180201","","000027" })
	aAdd( aBody, { "", "fc5a2c4f-a107-c2ab-3927-a209bd8af9ea", "SPDIPAM31"										 , "Saídas não escrituradas e outros ajustes determinados pela SEFAZ-SP.","20150101", "", "000027"  })
	aAdd( aBody, { "", "45f4a04d-5c24-c149-2b06-a88ee424fc0b", "SPDIPAM35"										 , "Entradas não escrituradas e outros ajustes determinados pela SEFAZ-SP.","20150101", "", "000027"  })
	aAdd( aBody, { "", "04551faa-91c2-0dc8-5752-30a82c991562", "SPDIPAM36"										 , "Entradas não escrituradas de produtores não equiparados.","20150101", "", "000027"  })
	
	//Espirito Santo - 000008
	
	aAdd( aBody, { "", "4553de70-c658-d65e-f32f-535dca61c8bd", "ESIPM01"											 , "PRODUÇÃO RURAL PRÓPRIA - Entradas para comercialização ou industrialização, de produtos agropecuários produzidos em propriedade rural que o contribuinte é responsável, inclusive as entradas por retorno de animal em sistema de integração.","20151001", "", "000008" })
	aAdd( aBody, { "", "5e4a80b6-c632-47fb-4fac-254824baf65f", "ESIPM02"											 , "COOPERATIVAS E CONTRIBUINTES QUE POSSUAM REOA - Valor dos produtos agropecuários adquiridos por cooperativas ou contribuintes que possuam Regime Especial de Obrigação Acessória - REOA - para emitir a NFe referente à entrada de produtos.","20151001", "", "000008" })
	aAdd( aBody, { "", "b409689b-e9c7-d5f5-658f-23c2125bce23", "ESIPM03"											 , "AQUISIÇÕES DE PESSOAS FÍSICAS - Valor correspondente às aquisições de mercadorias de pessoas físicas, tais como sucatas e veículos usados. Não consideraras aquisições de produtores rurais que tenham emitido nota fiscal de produtor.","20151001", "", "000008" })
	aAdd( aBody, { "", "36ac86ae-86fb-bb01-ebc4-fab01875f3cd", "ESIPM04"											 , "GERAÇÃO DE ENERGIA ELÉTRICA - Receita referente à produção de energia elétrica, deduzidos os custos de produção. Detalhando para o Município de localização do estabelecimento produtor, que é onde está instalado o motor primário.","20151001", "", "000008" })
	aAdd( aBody, { "", "d8ce139a-12c3-108f-c16e-320583c9ae91", "ESIPM05"											 , "DISTRIBUIÇÃO DE ENERGIA ELÉTRICA - Receita de energia elétrica distribuída, deduzido o valor da compra de energia elétrica, utilizando o critério de rateio proporcional e considerando o valor total do fornecimento.","20151001", "", "000008" })
	aAdd( aBody, { "", "09c717ca-f890-f5b8-8898-7b34838f01a3", "ESIPM06"											 , "PRESTAÇÃO SERVIÇO DE TRANSPORTE - Valor das prestações de serviços de transporte intermunicipal e interestadual, para o Município que tenha iniciado o transporte. Se iniciado em outro Estado, registra-se para o Município sede da transportadora.","20151001", "", "000008" })
	aAdd( aBody, { "", "fee22f7e-a96a-abfc-5a3b-74e76a8ef451", "ESIPM07"											 , "SERVIÇOS DE COMUNICAÇÃO E TELECOMUNICAÇÃO -Valor correspondente para cada Município nos quais foram realizadas prestações de serviços de comunicação e telecomunicação, não considerando o faturamento referente à comercialização de equipamentos.","20151001", "", "000008" })
	aAdd( aBody, { "", "c29dd290-025a-958a-b036-ca6b0ebecd48", "ESIPM08"											 , "PRODUÇÃO DE PETRÓLEO E GÁS NATURAL - Valor referente às atividades de produção de petróleo ou gás natural, considerando para o rateio do Município o critério “cabeça do poço”, que é onde estão instalados os equipamentos de extração.","20151001", "", "000008" })
	aAdd( aBody, { "", "9b81f1a9-e831-130d-b232-92b33e3f13b0", "ESIPM09"											 , "DISTRIBUIÇÃO DE ÁGUA CANALIZADA - Valor relativo ao faturamento de água tratada, considerando o fornecimento para cada Município individualmente e rateando os custos proporcionalmente. Sendo vedada a inclusão do faturamento relativo ao esgoto.","20151001", "", "000008" })
	aAdd( aBody, { "", "1e65a649-3687-2069-d175-c00391b7c63f", "ESIPM10"											 , "DISTRIBUIÇÃO DE GÁS NATURAL CANALIZADO - Valor do faturamento com gás natural canalizado, deduzido por critério de rateio as compras de gás natural e os tributos incidentes.","20151001", "", "000008" })
	aAdd( aBody, { "", "2d0e68e3-23d2-e0ec-7e22-682af4d52985", "ESIPM11"											 , "COZINHAS INDUSTRIAIS E SISTEMA DE INSCRIÇÃO CENTRALIZADA - Faturamento não incluídos nos itens anteriores, realizados por contribuintes com inscrição centralizada, legislação do ICMS ou regime especial, como cozinhas industriais.","20151001", "", "000008" })
	aAdd( aBody, { "", "cb3f7474-32b8-1df2-3267-82d061a1ba2c", "ESIPM12"											 , "FOMENTOS AGROPECUÁRIOS - Valor correspondente ao fomento agropecuário realizados pelo contribuinte.","20151001", "", "000008" })
	aAdd( aBody, { "", "cf45eab3-bd16-cf1e-c769-9a41e62e29b1", "ESIPM13"											 , "MUDANÇA PARA OUTRO MUNICÍPIO - Será informado para o Município onde o contribuinte estava localizado, o valor referente ao estoque final de mercadorias constantes no dia da mudança para outro Município.","20151001", "", "000008" })
	
	//Rio Grande do Sul - 000024
	
	aAdd( aBody, { "", "3a6fe33a-bb80-3cb9-852e-7d0b65e645e6",	"01"												 , "Transporte: serviço de transporte por município de origem deste Estado, na hipótese de transportadores e de responsáveis por substituição tributária", "20161001", "", "000024"	})
	aAdd( aBody, { "", "108293fc-4880-f93a-ea77-b5f114e94853",	"02"												 , "Energia Elétrica - Distribuição: distribuição de energia elétrica em cada município",	"20161001", "", "000024"	})
	aAdd( aBody, { "", "39501407-864f-545c-6f6f-b6eebaae101c",	"03"												 , "Comunicação: prestação de serviços de comunicação em cada município",	"20161001", "", "000024"	})
	aAdd( aBody, { "", "7de8a973-f65d-e358-6d77-332015f1bcdd",	"05"												 , "Vendas Fora do Estabelecimento: vendas realizadas por contribuinte deste Estado fora do seu estabelecimento",	"20161001", "", "000024"	})
	aAdd( aBody, { "", "d124c96d-49bf-8c4a-23fd-c8cf8a733c74",	"06"												 , "Energia Elétrica - Geração: geração de energia elétrica produzida em município distinto do domicílio fiscal do estabelecimento informante",	"20161001", "", "000024"	})
	aAdd( aBody, { "", "214f9fb5-b372-f474-26af-e4351bb547d0",	"09"											 	 , "Regime Especial - ver necessidade de apresentar também registro E115 (código RS160087) para entradas/custos; e registro E115 (código RS160001) para a identificação do Ato Declaratório do regime especial" , "20161001", "", "000024"	})	

	//Bahia - 000005
	aAdd( aBody, { "", "c1794766-55ad-7f49-1725-5513fceb6b67",	"BAE01"												 , "Aquisição de Serviços de Transporte - valor contábil das entradas e aquisições de serviço de transporte intermunicipal e/ou interestadual, por município baiano, proporcionalmente às saídas informadas, excluindo-se as operações dedutíveis", "20180101", "", "000005"	})
	aAdd( aBody, { "", "c018af05-4f94-034d-5c66-54ee813b205c",	"BAS01"												 , "Prestação de Serviços de Transporte - valor contábil das saídas e prestações de serviço de transporte intermunicipal e/ou interestadual, por município baiano de início (origem) da prestação, excluindo-se as operações dedutíveis",	"20180101", "", "000005"	})
	aAdd( aBody, { "", "38396e1f-ffca-6f16-7ded-669d81c44010",	"BAE02"												 , "Aquisição de serviços de Comunicação/Telecomunicação -  valor contábil das entradas e aquisições de serviço de comunicação, por município baiano, proporcionalmente às saídas, excluindo-se as operações dedutíveis",	"20180101", "", "000005"	})
	aAdd( aBody, { "", "516b1486-a55f-4c1b-17b4-8904c8fe470a",	"BAE03"												 , "Geração e Distribuição de Energia Elétrica e Água - Entradas - valor contábil das entradas  e insumos utilizados na geração e distribuição de energia elétrica ou água, por município baiano, proporcionalmente às saídas, excluindo-se as operações dedutíveis",	"20180101", "", "000005"	})
	aAdd( aBody, { "", "af95e789-0db7-f10b-26ad-be10544531b9",	"BAS03"												 , "Geração e Distribuição de Energia Elétrica e Água - Saídas - valor contábil das saídas de geração e distribuição de energia elétrica ou água, por município baiano onde ocorreu o fato gerador ou, no caso da distribuição, por município baiano onde ocorreu o fornecimento, excluindo-se as operações dedutíveis",	"20180101", "", "000005"	})
	aAdd( aBody, { "", "43d65f0e-c021-e99b-df65-ed666cb0b1c5",	"BAE04"											 	 , "Regimes Especiais - Entradas - valor contábil das entradas, por município baiano, para as empresas que possuem regime especial de escrituração centralizada, excluindo-se as operações dedutíveis e observando o disposto no referido regime" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "20b40930-e8f7-a6e6-ed35-f3291a2ab68e",	"BAS04"											 	 , "Regimes Especiais – Saídas - valor contábil das saídas, por município baiano de ocorrência do fato gerador, para as empresas que possuem regime especial de escrituração centralizada, excluindo-se as operações dedutíveis e observando o disposto no referido regime" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "fc3e9031-4351-e719-fc51-364fea36b2d4",	"BAE05"											 	 , "Exclusões nas entradas - IPI e ICMS/ST - Informar, para o município de localização do estabelecimento, a parcela do ICMS retido por substituição tributária e a parcela do IPI que não integra a base de cálculo do ICMS" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "b684bcb0-89e7-b3df-4034-7104111c27ef",	"BAS05"											 	 , "Exclusões nas saídas - IPI e ICMS/ST - Informar, para o município de localização do estabelecimento, a parcela do ICMS retido por substituição tributária e a parcela do IPI que não integre a base de cálculo do ICMS" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "9b1d3c66-1d28-1865-f073-ecc64bb0336f",	"BAE06"											 	 , "Operações não dedutíveis nas entradas - Informar, para o município de localização do estabelecimento, caso tenham ocorrido, as operações realizadas com os CFOPs genéricos 1949, 2949 e 3949, e que representem uma real movimentação econômica para a empresa, ou seja, gerem valor adicionado (agregado)" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "eb963ade-2242-9159-381b-07a9d7200238",	"BAS06"											 	 , "Operações não dedutíveis nas saídas - Informar, para o município de localização do estabelecimento, caso tenham ocorrido, as operações realizadas com os CFOPs genéricos 5949, 6949 e 7949, e que representem uma real movimentação econômica para a empresa, ou seja, gerem valor adicionado (agregado)" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "8edbc146-6c3c-981b-b101-b3e90c147cd8",	"BAE07"											 	 , "Aquisição de produto diferido - Eucalipto - valor das aquisições internas de EUCALIPTO oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "ba1064f5-c282-4c90-1e47-61e343b9256b",	"BAE08"											 	 , "Aquisição de produto diferido - Animais vivos - valor das aquisições internas de GADO BOVINO, SUÍNO, BUFALINO, ASININO, EQUINO E MUAR EM PÉ, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "700dadd6-491e-b8d9-6b4f-1f09271b0224",	"BAE09"											 	 , "Aquisição de produto diferido - Leite fresco - valor das aquisições internas de LEITE FRESCO oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "99716e3d-1b62-46d3-1743-d311e1ed27a5",	"BAE10"											 	 , "Aquisição de produto diferido - Mariscos/Peixes - valor das aquisições internas de LAGOSTA, CAMARÕES E PEIXES, oriundas de contribuintes não inscritos, por município baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "7561eaf2-ae7c-1704-1e7b-9509b7824328",	"BAE11"											 	 , "Aquisição de produto diferido - Sucatas - valor das aquisições internas de SUCATAS METÁLICAS, SUCATAS NÃO METÁLICAS, SUCATAS DE ALUMÍNIO, FRAGMENTOS, RETALHOS DE PLASTICOS E TECIDOS, SUCATAS DE PNEUS E BORRACHAS – RECICLÁVEIS, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "1396d3b6-5d6c-515f-68fb-ae81a0eecf34",	"BAE12"											 	 , "Aquisição de produto diferido - Couros e Peles - valor das aquisições internas de COUROS E PELES, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "6a8bd1bd-f777-cc3d-27ee-304deeca0e4f",	"BAE13"											 	 , "Aquisição de produto diferido - Materiais para combustão - valor das aquisições internas de LENHA E OUTROS MATERIAIS PARA COMBUSTÃO INDUSTRIAL, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "9df24656-8115-50ea-3b9c-23ba581caaa6",	"BAE14"											 	 , "Aquisição de produto diferido - Embalagens e insumos - valor das aquisições internas de EMBALAGENS E INSUMOS oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "fe81654e-f0de-af8c-b5f1-7c31d0d4a08e",	"BAE15"											 	 , "Aquisição de produto diferido - Cravo da Índia - valor das aquisições internas de CRAVO DA ÍNDIA, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "f292c807-17df-fd3d-f6fd-b99e595815ca",	"BAE16"											 	 , "Aquisição de produto diferido - Bambu - valor das aquisições internas de BAMBU, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "e637fbe8-3acd-154b-bf07-9b9e800247cf",	"BAE17"											 	 , "Aquisição de produto diferido - Resíduo papel/papelão - valor das aquisições internas de RESÍDUOS DE PAPEL E PAPELÃO, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "949a3b24-a740-630a-e1a0-ee7ec1b39eb4",	"BAE18"											 	 , "Aquisição de produto diferido - Sebo, osso, chifre e casco - valor das aquisições internas de SEBO, OSSOS, CHIFRES E CASCO, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "01b5aa11-2962-35e6-78db-f38f6bcadfc0",	"BAE19"											 	 , "Aquisição de produto diferido - Argila - valor das aquisições internas de ARGILA, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "b04768e3-1504-279b-0e52-b3b869a5af6e",	"BAE20"											 	 , "Aquisição de produto diferido - Outros - valor das aquisições internas de outros produtos não especificados nas linhas anteriores, oriundas de contribuintes não inscritos, inclusive do produtor rural pessoa física inscrito, por município baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "9148e538-5c37-94c6-c12e-700a169bc059",	"BAE99"											 	 , "Outros ajustes nas entradas - outros ajustes específicos determinados pela Sefaz BA" , "20180101", "", "000024"	})	
	aAdd( aBody, { "", "8a9cb272-0f0d-7517-c690-a3c1f7a7a97c",	"BAS99"											 	 , "Outros ajustes nas saídas - outros ajustes específicos determinados pela Sefaz BA" , "20180101", "", "000024"	})	
	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )