#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA453.CH" 

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA453
Cadastro MVC da Tabela de Itens UF �ndice de Participa��o dos Munic�pios

@author Daniel Schmidt	
@since 25/08/2016
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA453()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Tabela de Itens UF �ndice de Participa��o dos Munic�pios"
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

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@author Daniel Schmidt	
@since 25/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

//Verifica se o dicionario aplicado � o da DIEF-CE e da Declan-RJ
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
	aAdd( aBody, { "", "d30a0ecb-f9f0-4440-577d-df63252bb619", "GERACAO_DE_ENERGIA_ELETRICA"					 , "Gera��o de Energia El�trica", "20150101","", "000012" } )
	aAdd( aBody, { "", "414721b1-bd67-cbca-be92-c4c767044ecb", "MUDANCA_DE_MUNICIPIO"							 , "Mudan�a de Munic�pio - munic�pio de localiza��o anterior � mudan�a.", "20170101", "", "000012" })
	aAdd( aBody, { "", "8cc80b91-38d4-86b6-0f3f-1550c7f99a98", "OUTRAS_ENTRADAS_A_DETALHAR_POR_MUNICIPIO"		 , "Outras Entradas a Detalhar por munic�pio","20150101","", "000012" } )
	aAdd( aBody, { "", "522d1100-163a-67e8-46e9-a595099692b5", "PRESTACAO_DE_SERVICO_DE_TRANSPORTE_RODOVIARIO"   , "Presta��o de Servi�o de Transporte Rodovi�rio","20150101", "", "000012" })
	aAdd( aBody, { "", "0ecf4576-f078-d693-12dd-212bc4694f5f", "PRODUTOS_AGROPECUARIOS"							 , "Produtos Agropecu�rios/Hortifrutigranjeiros", "20150101","", "000012" } )
	aAdd( aBody, { "", "f0fbc990-44ec-b629-4748-2dcbf1af987e", "TRANSPORTE_TOMADO"								 , "Transporte Tomado", "20150101","", "000012" } )
	
	//Rio Grande do Norte - 000021
	
	aAdd( aBody, { "", "715c6b7e-6638-8c32-c11e-43dfe43d4e23", "IPM 3.1"											 , "Produtos Agropecu�rios/Hortifrutigranjeiros", "20160101", "", "000021" } )
	aAdd( aBody, { "", "f4f3338f-6485-3d43-a4d9-1d74a2f06085", "IPM 3.2"											 , "Transporte Tomado de Transportador Aut�nomo ou Empresa Transportadora n�o Inscrita no Estado", "20160101", "", "000021" })
	aAdd( aBody, { "", "a8063ff4-ccb6-5e9d-56ab-0b83727362b0", "IPM 3.3"											 , "Cooperativas", "20160101", "", "000021" } )
	aAdd( aBody, { "", "7e36d39a-3584-0203-0cfb-db3c421de872", "IPM 3.4"											 , "Gera��o de Energia El�trica para Utiliza��o Pr�pria (Autogera��o)","20160101", "", "000021" } )
	aAdd( aBody, { "", "d577a0ec-05f6-0539-51d2-93e6f27db4b0", "IPM 3.5"											 , "Vendas em Outros Munic�pios Fora da Sede do Estabelecimento, com Reten��o do ICMS por Substitui��o Tribut�ria, Inclusive Marketing Porta a Porta a Consumidor Final", "20160101", "", "000021" })
	aAdd( aBody, { "", "ed538573-0046-0363-a9e8-24c359d52c62", "IPM 4.1"											 , "Presta��o de Servi�o de Transporte Rodovi�rio de Cargas","20160101", "", "000021" })
	aAdd( aBody, { "", "14bac2eb-6c0b-869f-b241-293b9e37f799", "IPM 4.2"											 , "Presta��o de Servi�o de Transporte A�reo de Cargas","20160101", "", "000021" })
	aAdd( aBody, { "", "9f72137f-f78b-d06c-4f0e-4279753a6738", "IPM 4.3"											 , "Presta��o de Servi�o de Transporte Aquavi�rio de Cargas","20160101", "", "000021" })
	aAdd( aBody, { "", "95a98788-d39f-5351-e945-1dc2a63744d0", "IPM 4.4"											 , "Extra��o de Subst�ncias Minerais - Na Hip�tese da Jazida se Estender por Mais de um Munic�pio","20160101", "", "000021" })
	aAdd( aBody, { "", "3f5f690f-b810-1cd7-2e3e-d74734c70ea3", "IPM 4.5"											 , "Atividades de Distribui��o de Energia El�trica","20160101", "", "000021" })
	aAdd( aBody, { "", "a86a6305-0602-9b86-d2ed-4a43af9e6c64", "IPM 4.6"											 , "Atividades de Presta��o de Servi�os de Comunica��o/Telecomunica��o","20160101", "", "000021" })
	aAdd( aBody, { "", "3be749b0-522a-33cb-461c-6a3746d4eb4d", "IPM 4.7"											 , "Produ��o de Petr�leo e G�s Natural - Na Hip�tese da Produ��o se Estender por Mais de um Munic�pio","20160101", "", "000021" })
	aAdd( aBody, { "", "c4b0a6e1-2d97-12d0-2dfe-c3c15d4a966a", "IPM 4.8"											 , "Distribui��o de �gua Canalizada","20160101", "", "000021" })
	aAdd( aBody, { "", "72b70beb-108c-aaeb-c4f6-f03056c20daf", "IPM 4.9"											 , "Distribui��o de G�s Natural Canalizado","20160101", "", "000021" })
	aAdd( aBody, { "", "fdcca1cb-2e6e-8a38-0b94-cc708d6dcc24", "IPM 5.1"											 , "Atividades de Presta��o de Servi�o de Transporte Dutovi�rio/Ferrovi�rio","20160101", "", "000021" })
	aAdd( aBody, { "", "0d092cff-4934-b44f-2cfd-ed33f61e4567", "IPM 5.2"											 , "Sistemas de Integra��o entre Empres�rio, Sociedade Empres�ria ou Empresa Individual de Responsabilidade Limitada e Produtores Rurais","20160101", "", "000021" })
	aAdd( aBody, { "", "6b5ee4cf-9678-82a4-4628-581dd3f8849c", "IPM 5.3"											 , "Atividades do Estabelecimento do Contribuinte que se estenderem pelos Territ�rios de mais de um Munic�pio","20160101", "", "000021" })
	aAdd( aBody, { "", "13bd7810-c6fe-7a64-1cc3-5d3b633edd42", "IPM 5.4"											 , "Atividades de Gera��o/Transmiss�o de Energia El�trica","20160101", "", "000021" })
	aAdd( aBody, { "", "1c604cfb-6da4-b415-4ea3-c22ef672ed6b", "IPM 5.5"											 , "Atividade de Fornecimento de Refei��o Industrial para Munic�pio Distinto daquele da Circunscri��o do Contribuinte","20160101", "", "000021" })
	aAdd( aBody, { "", "c35a9dfd-62bd-ac79-dedb-8a8543eddcec", "IPM 5.6"											 , "Mudan�a do Estabelecimento do Contribuinte para Outro Munic�pio","20160101", "", "000021" })
	aAdd( aBody, { "", "d59b647d-f01b-38ea-4f75-45f5a670f3d1", "IPM 5.7"											 , "Outras Hip�teses em que Haja Necessidade de Atribui��o de Valor Adicionado Fiscal (VAF) a mais de um Munic�pio","20160101", "", "000021" })
	
	//S�o Paulo - 000027
	
	aAdd( aBody, { "", "97fa4e11-4188-0f1c-6dd4-d24e120ac2ae", "SPDIPAM11"										 , "Compras escrituradas de mercadorias de produtores agropecu�rios paulistas por munic�pio de origem.","20150101", "", "000027" })
	aAdd( aBody, { "", "e65361ee-766a-5dd4-2881-3b018baad9b2", "SPDIPAM12"										 , "Compras n�o escrituradas de mercadorias de agropecu�rios paulistas por munic�pio de origem e outros ajustes determinados pela SEFAZ-SP.","20150101", "", "000027"  })
	aAdd( aBody, { "", "4d21b580-7abe-7b1d-fcf7-9e57573f2dba", "SPDIPAM13"										 , "Recebimentos, por cooperativas, de mercadorias remetidas por produtores rurais deste Estado, desde que ocorra a efetiva transmiss�o da propriedade para a cooperativa. Excluem-se as situa��es em que haja previs�o de retorno da mercadoria ao cooperado, como quando a cooperativa � simples deposit�ria.","20150101", "", "000027"  })
	aAdd( aBody, { "", "16680874-fca6-9107-a382-cbca9bad1cb9", "SPDIPAM22"										 , "Vendas efetuadas por revendedores ambulantes aut�nomos em outros munic�pios paulistas; Refei��es preparadas fora do munic�pio do declarante, em opera��es autorizadas por Regime Especial; opera��es realizadas por empresas devidamente autorizadas a declarar por meio de uma �nica Inscri��o Estadual; Outros ajustes determinados pela Secretaria da Fazenda mediante instru��o expressa e espec�fica.","20150101", "", "000027"  })
	aAdd( aBody, { "", "830292a4-aa98-1dd7-8c7a-8e72046dcf4d", "SPDIPAM23"										 , "Rateio dos servi�os de transporte intermunicipal e interestadual iniciados em munic�pios paulistas.","20150101", "", "000027"  })
	aAdd( aBody, { "", "640085e1-2c8c-9835-b908-1c4fd2d13822", "SPDIPAM24"										 , "Rateio dos servi�os de comunica��o aos munic�pios paulistas onde tenham sido prestados.","20150101", "", "000027"  })
	aAdd( aBody, { "", "8017836c-4896-ef35-d365-4777dd87c741", "SPDIPAM25"										 , "Rateio de energia el�trica � Estabelecimento Distribuidor de Energia.","20150101", "", "000027"  })
	aAdd( aBody, { "", "02cef896-3a94-4229-ea86-03efba9d09d7", "SPDIPAM26"										 , "Informar o Valor Adicionado (deduzidos os custos de insumos) referente � produ��o pr�pria ou arrendada nos estabelecimentos nos quais o contribuinte n�o possua Inscri��o Estadual inscrita.","20150101", "", "000027"  })
	aAdd( aBody, { "", "bcacfe83-5136-5692-ae8d-a88d5f56714d", "SPDIPAM27"										 , "Informar: (i) o valor das opera��es de sa�da de mercadorias cujas transa��es comerciais tenham sido realizadas em outro estabelecimento localizado neste Estado, exclu�das as transa��es comerciais n�o presenciais; e (ii) os respectivos munic�pios onde as transa��es comerciais foram realizadas.","20170701","20171231","000027"})
	aAdd( aBody, { "", "ea11f96a-4702-d686-df95-abcc6358e191", "SPDIPAM27"										 , "Vendas presenciais com sa�das/vendas efetuadas em estabelecimento diverso de onde ocorreu a transa��o/negocia��o inicial.", "20180201","","000027" })
	aAdd( aBody, { "", "fc5a2c4f-a107-c2ab-3927-a209bd8af9ea", "SPDIPAM31"										 , "Sa�das n�o escrituradas e outros ajustes determinados pela SEFAZ-SP.","20150101", "", "000027"  })
	aAdd( aBody, { "", "45f4a04d-5c24-c149-2b06-a88ee424fc0b", "SPDIPAM35"										 , "Entradas n�o escrituradas e outros ajustes determinados pela SEFAZ-SP.","20150101", "", "000027"  })
	aAdd( aBody, { "", "04551faa-91c2-0dc8-5752-30a82c991562", "SPDIPAM36"										 , "Entradas n�o escrituradas de produtores n�o equiparados.","20150101", "", "000027"  })
	
	//Espirito Santo - 000008
	
	aAdd( aBody, { "", "4553de70-c658-d65e-f32f-535dca61c8bd", "ESIPM01"											 , "PRODU��O RURAL PR�PRIA - Entradas para comercializa��o ou industrializa��o, de produtos agropecu�rios produzidos em propriedade rural que o contribuinte � respons�vel, inclusive as entradas por retorno de animal em sistema de integra��o.","20151001", "", "000008" })
	aAdd( aBody, { "", "5e4a80b6-c632-47fb-4fac-254824baf65f", "ESIPM02"											 , "COOPERATIVAS E CONTRIBUINTES QUE POSSUAM REOA - Valor dos produtos agropecu�rios adquiridos por cooperativas ou contribuintes que possuam Regime Especial de Obriga��o Acess�ria - REOA - para emitir a NFe referente � entrada de produtos.","20151001", "", "000008" })
	aAdd( aBody, { "", "b409689b-e9c7-d5f5-658f-23c2125bce23", "ESIPM03"											 , "AQUISI��ES DE PESSOAS F�SICAS - Valor correspondente �s aquisi��es de mercadorias de pessoas f�sicas, tais como sucatas e ve�culos usados. N�o consideraras aquisi��es de produtores rurais que tenham emitido nota fiscal de produtor.","20151001", "", "000008" })
	aAdd( aBody, { "", "36ac86ae-86fb-bb01-ebc4-fab01875f3cd", "ESIPM04"											 , "GERA��O DE ENERGIA EL�TRICA - Receita referente � produ��o de energia el�trica, deduzidos os custos de produ��o. Detalhando para o Munic�pio de localiza��o do estabelecimento produtor, que � onde est� instalado o motor prim�rio.","20151001", "", "000008" })
	aAdd( aBody, { "", "d8ce139a-12c3-108f-c16e-320583c9ae91", "ESIPM05"											 , "DISTRIBUI��O DE ENERGIA EL�TRICA - Receita de energia el�trica distribu�da, deduzido o valor da compra de energia el�trica, utilizando o crit�rio de rateio proporcional e considerando o valor total do fornecimento.","20151001", "", "000008" })
	aAdd( aBody, { "", "09c717ca-f890-f5b8-8898-7b34838f01a3", "ESIPM06"											 , "PRESTA��O SERVI�O DE TRANSPORTE - Valor das presta��es de servi�os de transporte intermunicipal e interestadual, para o Munic�pio que tenha iniciado o transporte. Se iniciado em outro Estado, registra-se para o Munic�pio sede da transportadora.","20151001", "", "000008" })
	aAdd( aBody, { "", "fee22f7e-a96a-abfc-5a3b-74e76a8ef451", "ESIPM07"											 , "SERVI�OS DE COMUNICA��O E TELECOMUNICA��O -Valor correspondente para cada Munic�pio nos quais foram realizadas presta��es de servi�os de comunica��o e telecomunica��o, n�o considerando o faturamento referente � comercializa��o de equipamentos.","20151001", "", "000008" })
	aAdd( aBody, { "", "c29dd290-025a-958a-b036-ca6b0ebecd48", "ESIPM08"											 , "PRODU��O DE PETR�LEO E G�S NATURAL - Valor referente �s atividades de produ��o de petr�leo ou g�s natural, considerando para o rateio do Munic�pio o crit�rio �cabe�a do po�o�, que � onde est�o instalados os equipamentos de extra��o.","20151001", "", "000008" })
	aAdd( aBody, { "", "9b81f1a9-e831-130d-b232-92b33e3f13b0", "ESIPM09"											 , "DISTRIBUI��O DE �GUA CANALIZADA - Valor relativo ao faturamento de �gua tratada, considerando o fornecimento para cada Munic�pio individualmente e rateando os custos proporcionalmente. Sendo vedada a inclus�o do faturamento relativo ao esgoto.","20151001", "", "000008" })
	aAdd( aBody, { "", "1e65a649-3687-2069-d175-c00391b7c63f", "ESIPM10"											 , "DISTRIBUI��O DE G�S NATURAL CANALIZADO - Valor do faturamento com g�s natural canalizado, deduzido por crit�rio de rateio as compras de g�s natural e os tributos incidentes.","20151001", "", "000008" })
	aAdd( aBody, { "", "2d0e68e3-23d2-e0ec-7e22-682af4d52985", "ESIPM11"											 , "COZINHAS INDUSTRIAIS E SISTEMA DE INSCRI��O CENTRALIZADA - Faturamento n�o inclu�dos nos itens anteriores, realizados por contribuintes com inscri��o centralizada, legisla��o do ICMS ou regime especial, como cozinhas industriais.","20151001", "", "000008" })
	aAdd( aBody, { "", "cb3f7474-32b8-1df2-3267-82d061a1ba2c", "ESIPM12"											 , "FOMENTOS AGROPECU�RIOS - Valor correspondente ao fomento agropecu�rio realizados pelo contribuinte.","20151001", "", "000008" })
	aAdd( aBody, { "", "cf45eab3-bd16-cf1e-c769-9a41e62e29b1", "ESIPM13"											 , "MUDAN�A PARA OUTRO MUNIC�PIO - Ser� informado para o Munic�pio onde o contribuinte estava localizado, o valor referente ao estoque final de mercadorias constantes no dia da mudan�a para outro Munic�pio.","20151001", "", "000008" })
	
	//Rio Grande do Sul - 000024
	
	aAdd( aBody, { "", "3a6fe33a-bb80-3cb9-852e-7d0b65e645e6",	"01"												 , "Transporte: servi�o de transporte por munic�pio de origem deste Estado, na hip�tese de transportadores e de respons�veis por substitui��o tribut�ria", "20161001", "", "000024"	})
	aAdd( aBody, { "", "108293fc-4880-f93a-ea77-b5f114e94853",	"02"												 , "Energia El�trica - Distribui��o: distribui��o de energia el�trica em cada munic�pio",	"20161001", "", "000024"	})
	aAdd( aBody, { "", "39501407-864f-545c-6f6f-b6eebaae101c",	"03"												 , "Comunica��o: presta��o de servi�os de comunica��o em cada munic�pio",	"20161001", "", "000024"	})
	aAdd( aBody, { "", "7de8a973-f65d-e358-6d77-332015f1bcdd",	"05"												 , "Vendas Fora do Estabelecimento: vendas realizadas por contribuinte deste Estado fora do seu estabelecimento",	"20161001", "", "000024"	})
	aAdd( aBody, { "", "d124c96d-49bf-8c4a-23fd-c8cf8a733c74",	"06"												 , "Energia El�trica - Gera��o: gera��o de energia el�trica produzida em munic�pio distinto do domic�lio fiscal do estabelecimento informante",	"20161001", "", "000024"	})
	aAdd( aBody, { "", "214f9fb5-b372-f474-26af-e4351bb547d0",	"09"											 	 , "Regime Especial - ver necessidade de apresentar tamb�m registro E115 (c�digo RS160087) para entradas/custos; e registro E115 (c�digo RS160001) para a identifica��o do Ato Declarat�rio do regime especial" , "20161001", "", "000024"	})	

	//Bahia - 000005
	aAdd( aBody, { "", "c1794766-55ad-7f49-1725-5513fceb6b67",	"BAE01"												 , "Aquisi��o de Servi�os de Transporte - valor cont�bil das entradas e aquisi��es de servi�o de transporte intermunicipal e/ou interestadual, por munic�pio baiano, proporcionalmente �s sa�das informadas, excluindo-se as opera��es dedut�veis", "20180101", "", "000005"	})
	aAdd( aBody, { "", "c018af05-4f94-034d-5c66-54ee813b205c",	"BAS01"												 , "Presta��o de Servi�os de Transporte - valor cont�bil das sa�das e presta��es de servi�o de transporte intermunicipal e/ou interestadual, por munic�pio baiano de in�cio (origem) da presta��o, excluindo-se as opera��es dedut�veis",	"20180101", "", "000005"	})
	aAdd( aBody, { "", "38396e1f-ffca-6f16-7ded-669d81c44010",	"BAE02"												 , "Aquisi��o de servi�os de Comunica��o/Telecomunica��o -  valor cont�bil das entradas e aquisi��es de servi�o de comunica��o, por munic�pio baiano, proporcionalmente �s sa�das, excluindo-se as opera��es dedut�veis",	"20180101", "", "000005"	})
	aAdd( aBody, { "", "516b1486-a55f-4c1b-17b4-8904c8fe470a",	"BAE03"												 , "Gera��o e Distribui��o de Energia El�trica e �gua - Entradas - valor cont�bil das entradas  e insumos utilizados na gera��o e distribui��o de energia el�trica ou �gua, por munic�pio baiano, proporcionalmente �s sa�das, excluindo-se as opera��es dedut�veis",	"20180101", "", "000005"	})
	aAdd( aBody, { "", "af95e789-0db7-f10b-26ad-be10544531b9",	"BAS03"												 , "Gera��o e Distribui��o de Energia El�trica e �gua - Sa�das - valor cont�bil das sa�das de gera��o e distribui��o de energia el�trica ou �gua, por munic�pio baiano onde ocorreu o fato gerador ou, no caso da distribui��o, por munic�pio baiano onde ocorreu o fornecimento, excluindo-se as opera��es dedut�veis",	"20180101", "", "000005"	})
	aAdd( aBody, { "", "43d65f0e-c021-e99b-df65-ed666cb0b1c5",	"BAE04"											 	 , "Regimes Especiais - Entradas - valor cont�bil das entradas, por munic�pio baiano, para as empresas que possuem regime especial de escritura��o centralizada, excluindo-se as opera��es dedut�veis e observando o disposto no referido regime" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "20b40930-e8f7-a6e6-ed35-f3291a2ab68e",	"BAS04"											 	 , "Regimes Especiais � Sa�das - valor cont�bil das sa�das, por munic�pio baiano de ocorr�ncia do fato gerador, para as empresas que possuem regime especial de escritura��o centralizada, excluindo-se as opera��es dedut�veis e observando o disposto no referido regime" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "fc3e9031-4351-e719-fc51-364fea36b2d4",	"BAE05"											 	 , "Exclus�es nas entradas - IPI e ICMS/ST - Informar, para o munic�pio de localiza��o do estabelecimento, a parcela do ICMS retido por substitui��o tribut�ria e a parcela do IPI que n�o integra a base de c�lculo do ICMS" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "b684bcb0-89e7-b3df-4034-7104111c27ef",	"BAS05"											 	 , "Exclus�es nas sa�das - IPI e ICMS/ST - Informar, para o munic�pio de localiza��o do estabelecimento, a parcela do ICMS retido por substitui��o tribut�ria e a parcela do IPI que n�o integre a base de c�lculo do ICMS" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "9b1d3c66-1d28-1865-f073-ecc64bb0336f",	"BAE06"											 	 , "Opera��es n�o dedut�veis nas entradas - Informar, para o munic�pio de localiza��o do estabelecimento, caso tenham ocorrido, as opera��es realizadas com os CFOPs gen�ricos 1949, 2949 e 3949, e que representem uma real movimenta��o econ�mica para a empresa, ou seja, gerem valor adicionado (agregado)" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "eb963ade-2242-9159-381b-07a9d7200238",	"BAS06"											 	 , "Opera��es n�o dedut�veis nas sa�das - Informar, para o munic�pio de localiza��o do estabelecimento, caso tenham ocorrido, as opera��es realizadas com os CFOPs gen�ricos 5949, 6949 e 7949, e que representem uma real movimenta��o econ�mica para a empresa, ou seja, gerem valor adicionado (agregado)" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "8edbc146-6c3c-981b-b101-b3e90c147cd8",	"BAE07"											 	 , "Aquisi��o de produto diferido - Eucalipto - valor das aquisi��es internas de EUCALIPTO oriundas de contribuintes n�o inscritos, inclusive do produtor rural pessoa f�sica inscrito, por munic�pio baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "ba1064f5-c282-4c90-1e47-61e343b9256b",	"BAE08"											 	 , "Aquisi��o de produto diferido - Animais vivos - valor das aquisi��es internas de GADO BOVINO, SU�NO, BUFALINO, ASININO, EQUINO E MUAR EM P�, oriundas de contribuintes n�o inscritos, inclusive do produtor rural pessoa f�sica inscrito, por munic�pio baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "700dadd6-491e-b8d9-6b4f-1f09271b0224",	"BAE09"											 	 , "Aquisi��o de produto diferido - Leite fresco - valor das aquisi��es internas de LEITE FRESCO oriundas de contribuintes n�o inscritos, inclusive do produtor rural pessoa f�sica inscrito, por munic�pio baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "99716e3d-1b62-46d3-1743-d311e1ed27a5",	"BAE10"											 	 , "Aquisi��o de produto diferido - Mariscos/Peixes - valor das aquisi��es internas de LAGOSTA, CAMAR�ES E PEIXES, oriundas de contribuintes n�o inscritos, por munic�pio baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "7561eaf2-ae7c-1704-1e7b-9509b7824328",	"BAE11"											 	 , "Aquisi��o de produto diferido - Sucatas - valor das aquisi��es internas de SUCATAS MET�LICAS, SUCATAS N�O MET�LICAS, SUCATAS DE ALUM�NIO, FRAGMENTOS, RETALHOS DE PLASTICOS E TECIDOS, SUCATAS DE PNEUS E BORRACHAS � RECICL�VEIS, oriundas de contribuintes n�o inscritos, inclusive do produtor rural pessoa f�sica inscrito, por munic�pio baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "1396d3b6-5d6c-515f-68fb-ae81a0eecf34",	"BAE12"											 	 , "Aquisi��o de produto diferido - Couros e Peles - valor das aquisi��es internas de COUROS E PELES, oriundas de contribuintes n�o inscritos, inclusive do produtor rural pessoa f�sica inscrito, por munic�pio baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "6a8bd1bd-f777-cc3d-27ee-304deeca0e4f",	"BAE13"											 	 , "Aquisi��o de produto diferido - Materiais para combust�o - valor das aquisi��es internas de LENHA E OUTROS MATERIAIS PARA COMBUST�O INDUSTRIAL, oriundas de contribuintes n�o inscritos, inclusive do produtor rural pessoa f�sica inscrito, por munic�pio baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "9df24656-8115-50ea-3b9c-23ba581caaa6",	"BAE14"											 	 , "Aquisi��o de produto diferido - Embalagens e insumos - valor das aquisi��es internas de EMBALAGENS E INSUMOS oriundas de contribuintes n�o inscritos, inclusive do produtor rural pessoa f�sica inscrito, por munic�pio baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "fe81654e-f0de-af8c-b5f1-7c31d0d4a08e",	"BAE15"											 	 , "Aquisi��o de produto diferido - Cravo da �ndia - valor das aquisi��es internas de CRAVO DA �NDIA, oriundas de contribuintes n�o inscritos, inclusive do produtor rural pessoa f�sica inscrito, por munic�pio baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "f292c807-17df-fd3d-f6fd-b99e595815ca",	"BAE16"											 	 , "Aquisi��o de produto diferido - Bambu - valor das aquisi��es internas de BAMBU, oriundas de contribuintes n�o inscritos, inclusive do produtor rural pessoa f�sica inscrito, por munic�pio baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "e637fbe8-3acd-154b-bf07-9b9e800247cf",	"BAE17"											 	 , "Aquisi��o de produto diferido - Res�duo papel/papel�o - valor das aquisi��es internas de RES�DUOS DE PAPEL E PAPEL�O, oriundas de contribuintes n�o inscritos, inclusive do produtor rural pessoa f�sica inscrito, por munic�pio baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "949a3b24-a740-630a-e1a0-ee7ec1b39eb4",	"BAE18"											 	 , "Aquisi��o de produto diferido - Sebo, osso, chifre e casco - valor das aquisi��es internas de SEBO, OSSOS, CHIFRES E CASCO, oriundas de contribuintes n�o inscritos, inclusive do produtor rural pessoa f�sica inscrito, por munic�pio baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "01b5aa11-2962-35e6-78db-f38f6bcadfc0",	"BAE19"											 	 , "Aquisi��o de produto diferido - Argila - valor das aquisi��es internas de ARGILA, oriundas de contribuintes n�o inscritos, inclusive do produtor rural pessoa f�sica inscrito, por munic�pio baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "b04768e3-1504-279b-0e52-b3b869a5af6e",	"BAE20"											 	 , "Aquisi��o de produto diferido - Outros - valor das aquisi��es internas de outros produtos n�o especificados nas linhas anteriores, oriundas de contribuintes n�o inscritos, inclusive do produtor rural pessoa f�sica inscrito, por munic�pio baiano de origem, acobertadas pelo regime de diferimento" , "20180101", "", "000005"	})	
	aAdd( aBody, { "", "9148e538-5c37-94c6-c12e-700a169bc059",	"BAE99"											 	 , "Outros ajustes nas entradas - outros ajustes espec�ficos determinados pela Sefaz BA" , "20180101", "", "000024"	})	
	aAdd( aBody, { "", "8a9cb272-0f0d-7517-c690-a3c1f7a7a97c",	"BAS99"											 	 , "Outros ajustes nas sa�das - outros ajustes espec�ficos determinados pela Sefaz BA" , "20180101", "", "000024"	})	
	
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )