#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA377.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA437
Cadastro MVC de Obrigações Fiscais

@author Rafael Völtz
@since 26/04/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA437()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Tipos de Motivos"
oBrw:SetAlias( 'T0V')
oBrw:SetMenuDef( 'TAFA437' )
T0V->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rafael Völtz
@since 26/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA437" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rafael Völtz
@since 26/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT0V  :=  FWFormStruct( 1, 'T0V' )
Local oModel    :=  MPFormModel():New( 'TAFA437' )

oModel:AddFields('MODEL_T0V', /*cOwner*/, oStruT0V)
oModel:GetModel('MODEL_T0V'):SetPrimaryKey({'T0V_FILIAL','T0V_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rafael Völtz
@since 26/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA437' )
Local   oStruT0V    :=  FWFormStruct( 2, 'T0V' )
Local   oView       :=  FWFormView():New()

oStruT0V:RemoveField('T0V_ID')
oStruT0V:RemoveField('T0V_IDUF')

oView:SetModel( oModel )
oView:AddField( 'VIEW_T0V', oStruT0V, 'MODEL_T0V' )

oView:EnableTitleView( 'VIEW_T0V', STR0001 )    //"Tipos de Motivos"
oView:CreateHorizontalBox( 'FIELDST0V', 100 )
oView:SetOwnerView( 'VIEW_T0V', 'FIELDST0V' )

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

nVerAtu := 1012

If nVerEmp < nVerAtu
    If(AliasInDic("T0V"))
		aAdd( aHeader, "T0V_FILIAL" )
		aAdd( aHeader, "T0V_ID" )
		aAdd( aHeader, "T0V_CODIGO" )
		aAdd( aHeader, "T0V_DESCRI" )
		aAdd( aHeader, "T0V_DCOMPL" )
		aAdd( aHeader, "T0V_IDSBIT" )
		aAdd( aHeader, "T0V_IDUF" )
		aAdd( aHeader, "T0V_VALIDA" )

		//DAPI-MG
		//// Crédito Recebido em Transferência
	    aAdd( aBody, { "", "39c39ad7-b556-70c0-b770-27945a522b93", "00000", "Mandato de Segurança", "",                                                                                                                                                              "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "bae556e6-6e39-8b75-1084-cf22c569518c", "00001", "Recebimento de Crédito Acumulado Transferido para Aquisição de Ações ou Quotas de Capital (recebido com códigos 02 e 05)", "Destino: Fornecedor Mineiro (20% da operação)",             "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "71b9e981-86d0-27a5-e93d-7544430e9923", "00002", "Diferimento", "Destino: AQUIS. DE AÇÕES OU COTAS de Indústria Mineira em fase de instalação/expansão",                                                                                  "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "371511fc-8490-759f-3542-280c72389464", "00003", "Diferimento", "Destino: Fornecedor Mineiro (20% da Operação)",                                                                                                                          "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "da8c50cf-6f9a-da0b-40ff-d6c9a1551600", "00004", "Diferimento", "Destino: Outro estabelecimento da mesma empresa ou empresa interdependente, situados em MG",                                                                             "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","20040401" } )
	    aAdd( aBody, { "", "ee8c984a-b2e2-db8b-6c0a-9042f130f6ad", "00005", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE", "Destino: AQUIS. DE AÇÕES OU COTAS de Indústria Mineira em fase de instalação/expansão",                                   "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "9259bc05-f54f-3b4f-5ac6-f5015e2d1fbd", "00006", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE", "Destino: Fornecedor Mineiro (20% da operação)",                                                                           "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "3bce87d7-d9e2-8f68-0d8a-1348a476c046", "00007", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE", "Destino: Outro estabelecimento da mesma empresa ou empresa interdependente, situados em MG",                              "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","20040401" } )
	    aAdd( aBody, { "", "8843ab9f-bdde-210d-f1da-5f5e72975d05", "00008", "Exportação", "Destino: Estabelecimento do mesmo titular situado no Estado",                                                                                                             "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "5befe4b5-93e5-f0ad-63b9-bd1f5b82471c", "00009", "Exportação", "Destino: Outro contribuinte de MG",                                                                                                                                       "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "6236d79b-fbe6-f6e7-0552-1050c5af2275", "00010", "Exportação (detentor original do crédito)", "Destino: Pagamento crédito tributário",                                                                                                    "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "1dbf2254-ea32-60c6-043d-970067a17099", "00011", "Exportação (detentor original do crédito)", "Destino: Pagamento ICMS diferença de alíquota",                                                                                            "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","20040401" } )
	    aAdd( aBody, { "", "d3553596-8f58-174f-f561-2a59cbba1a15", "00012", "Exportação", "Destino: Fornecedor de outro Estado",                                                                                                                                     "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","20040401" } )
	    aAdd( aBody, { "", "d147e4da-fdb8-78a6-3960-9f573810677e", "00013", "Crédito Acumulado definido em Regime Especial p/ atração de novos investimentos para MG", "Destino: Novos estabelecimentos - Conforme Regime Especial (SRE - Art. 5º Inc. II)",         "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","20040401" } )
	    aAdd( aBody, { "", "1579ffec-f944-91a5-c746-e5490ad0bc03", "00014", "Diferimento", "Destino: Específico - Conforme Regime Especial (DF)",                                                                                                                    "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "6d8e1c7a-bbb3-be56-13cb-3f8be69821b5", "00015", "Crédito Acumulado", "Destino: Transferência de Estoque, previstas nos itens 35 e 36 do Anexo II",                                                                                       "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "0ac13451-abb8-be67-7f02-c98f3bfcc023", "00016", "Saídas Isentas de fabricante de ração avícola para estabelecimento de sua propriedade ou de produtor integrado", "Destino: Estabelecimento abatedor da mesma  empresa - Regime Especial (DF)", "1f139103-3190-60b6-41c5-8fe3cc9fc639",   "000012","" } )
	    aAdd( aBody, { "", "7f4b29cb-b9be-49da-9237-594e3c9a26cf", "00017", "Crédito acumulado em  razão operação intermediária isenta ou não tributada com produto agropecuário", "Destino: Outro contribuinte de MG",                                              "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "d8949d32-4176-dbf4-bf85-ed46541216b6", "00018", "Exportação", "Destino: Empresa interdependente de MG",                                                                                                                                  "1f139103-3190-60b6-41c5-8fe3cc9fc639",   "000012","20040401" } )
	    aAdd( aBody, { "", "4700d727-0dde-5ce0-cba3-025decf1516a", "00019", "Recebimento de Crédito Acumulado de estabelecimento da mesma empresa ou de empresa interdependente (recebido c/ códigos 08 ou 18)", "Destino: Pagamento ICMS vencido",                  "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","20040401" } )
	    aAdd( aBody, { "", "f661ba79-aced-8f09-78ce-02fd32786b8b", "00020", "Recebimento de Crédito Acumulado de estabelecimento da mesma empresa ou de empresa interdependente (recebido c/ códigos 08 ou 18)", "Destino: Pagamento ICMS diferença de alíquota",    "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","20040401" } )
	    aAdd( aBody, { "", "bcdce346-31b9-5f6f-cebb-4c3ced3ff971", "00021", "Crédito Acumulado definido em Regime Especial p/ pagamento pela aquisição de veículos, máquinas e equipamentos, novos, destinados ao ativo permanente", "Destino: Fornecedor situado neste Estado - Conforme Regime Especial (SRE - Art. 5º Inciso II)",                          "1f139103-3190-60b6-41c5-8fe3cc9fc639",   "000012","20020801" } )
	    aAdd( aBody, { "", "ae4b29b0-bfc6-8b9a-0243-03c26bd86fa9", "00022", "Crédito Acumulado de empresa coligada ou controlada pertencente a grupo econômico de fornecedora de energia elétrica e prestadoras de serviço de comunicação", "Destino: Empresa fornecedora de energia elétrica ou prestadora de serviço de comunicação para pagamento de ICMS", "1f139103-3190-60b6-41c5-8fe3cc9fc639",   "000012","" } )
	    aAdd( aBody, { "", "e21940c2-fa9a-5291-5404-921896712f5f", "00023", "Saldo credor acumulado por estabelecimento gerador de energia elétrica", "Destino: Distribuidores de energia ou para empresas consorciadas",                                            "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "d8c93f8d-ee16-e318-6653-c143164c1d13", "00024", "Diferimento (detentor original do crédito)", "Destino: Pagto crédito tributário",                                                                                                       "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "5e8db308-5438-e848-4464-d7cc8b2223fc", "00025", "Saídas internas a 7% de Indústria alimentícia-Divisão 10 da CNAE (detentor original do crédito)", "Destino: Pagto crédito tributário",                                                   "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "2979c428-0fed-5409-d5b6-4f3e285e95dc", "00026", "Diferimento - (detentor original classificado nas Divisões 05 a 33 e CNAEs específicos)", "Destino: Pagto ICMS importação - ativo permanente desembaraçado no Estado",                  "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "2c56a7cf-4e84-3ab2-f09e-5610c6255c7d", "00027", "Diferimento", "Destino: Contribuintes do Estado pertencentes às Divisões 05 a 33 e CNAE específicos, para pagamento de ICMS importação - ativo permanente desembaraçado no Estado",     "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "bfcc2ebb-c506-4517-e236-bba4d3f3e9b9", "00028", "Exportação (detentor original do crédito classificados nas Divisões 05 a 33 e CNAEs específicos)", "Destino: Pagto ICMS importação - ativo permanente desembaraçado no Estado",         "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "515fd766-a0ba-c8f3-2397-ab7404e1479f", "00029", "Exportação", "Destino: Contribuintes de CNAE-Fiscal pertencente às Divisões 05 a 33 e CNAEs específicos, para pagamento de ICMS importação - ativo permanente desembaraçado no Estado", "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "1093c4a7-12f8-9ff0-3f28-9dac598bded2", "00030", "Exportação", "Destino: Outro contribuinte de MG para pagamento de crédito tributário",                                                                                                  "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "24548415-48b2-564e-b4d9-94d17663cbd7", "00031", "Diferimento", "Destino: Estabelecimento do mesmo titular situado em MG",                                                                                                                "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "35866e55-9ae7-4c02-0ebb-b9826af57cce", "00032", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE", "Destino: Estabelecimento do mesmo titular situado em MG",                                                                 "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "29de9a88-283e-e028-0b6a-2286eb12254f", "00033", "Diferimento", "Destino: Estabelecimento do mesmo titular para pagamento de crédito tributário",                                                                                         "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "c3dda20b-3aa2-afe8-2442-c27842b69390", "00034", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE", "Destino: Estabelecimento do mesmo titular para pagamento de crédito tributário",                                          "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "aa97af4f-863e-0650-094d-aa38e44a2443", "00035", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE (detentor original do crédito)", "Destino: Pagamento ICMS importação - ativo permanente desembaraçado no Estado",            "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "5b71aafa-16c4-99a6-5c91-26c42b4c9009", "00036", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE", "Destino: Contribuintes do Estado pertencentes às Divisões 05 a 33, para pagamento de ICMS importação - ativo permanente desembaraçado no Estado", "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "08d70cc5-92c8-dec5-6005-11d72e39b1f9", "00037", "Crédito Acumulado", "Destino: Novo Estabelecimento industrial, de contribuinte que SE instalar neste Estado ou de contribuinte já inscrito",                                            "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "417e5fb1-11f6-ea3d-a948-22a62f1ecf05", "00038", "Crédito Acumulado", "Destino: Estabelecimento industrial de contribuinte situado neste Estado em fase de expansão",                                                                     "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "b54b10ce-a9c5-b929-ea99-d2ff75b75d59", "00039", "Crédito acumulado em operações com equipamentos e componentes p/ aproveitamento de energia solar eólica", "Destino: Outro contribuinte de MG",                                          "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "ba8ae4c6-6033-0a3b-2726-8d124b91375a", "00040", "Protocolo ICM 12/84 referente operações com leite- MG e SP", "Destino: Transferências para contribuintes de MG e de São Paulo",                                                         "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "6e70a1d0-ed5e-817d-383e-28512adcf989", "00041", "Crédito acumulado por estabelecimento industrial ou produtor rural", "Destino: Estabelecimento industrial de MG para aquisição de caminhão, trator, máquina, equipamento agrícola, novos produzidos no Estado, para ativo permanente. Conforme regime especial", "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "ff5fc41f-e133-bf11-64b5-27e1954af161", "00050", "Transferência crédito acumulado não relacionado nas situações anteriores", "",                                                                                                          "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "df60d1a1-2cdb-d137-cf9f-2352ac176c66", "00051", "Compensação entre Saldo Devedor/Credor mesmo núcleo I.E.", "Destino: Sujeito passivo de mesmo núcleo de I.E.",                                                                          "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "a2cfa5d6-cafb-be49-0cee-153d399796c9", "00052", "Saídas com diferimento de ligas de alumínio secundário produzido a partir de sucata", "Destino: Estabelecimento do mesmo titular situado em MG",                                        "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "8b040809-872d-3c37-b032-9ccdc958e619", "00053", "Saídas com diferimento de ligas de alumínio secundário produzido a partir de sucata", "Destino: Outro contribuinte de MG",                                                              "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "022b802a-cd37-b734-177e-1820cb74119c", "00054", "Saídas de ligas de alumínio secundário produzido a partir de sucata", "Destino: Estabelecimento do mesmo titular para pagamento de crédito tributário",                                 "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "8c934017-a6ed-1873-731b-8286c1deccb4", "00055", "Saídas de ligas de alumínio secundário produzido a partir de sucata", "Destino: Outro contribuinte de MG para pagamento de crédito tributário",                                         "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "6c249bf9-046d-0fa6-c127-43492d6441e7", "00056", "Crédito Acumulado por estabelecimento industrial em fase de expansão", "Destino: Utilização para pagamento ICMS importação ou pagamento de ICMS devido pela entrada, em decorrência de operação interestadual, de mercadoria destinada ao ativo permanente", "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "d4bc0d95-2d23-7778-b2cb-479cbff8abd8", "00057", "Crédito Acumulado por estabelecimento industrial em fase de expansão", "Destino: Transferência a título de pagamento pela aquisição de material de construção ou para estabelecimento industrial a título de pagamento pela aquisição de bem para ativo permanente", "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "019b236b-a693-f84f-835d-5b0ab94cb2ef", "00058", "Crédito Acumulado por estabelecimento industrial", "Destino: Estabelecimento industrial de mesma titularidade em fase de expansão ou novo",                                            "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "be2964f6-ad2b-821d-73af-8d9a76fda8fb", "00059", "Crédito acumulado em razão de saídas isentas (item 136 da Parte I do Anexo I) cujas operações estejam sujeitas à substituição tributária", "Destino: Fornecedor de mercadoria do mesmo gênero inscrito no cadastro de contribuintes de MG", "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "d7da3261-03f4-36dd-3081-c4f9ffce7bb2", "00060", "Crédito acumulado em razão de apropriação extemporânea de créditos de entradas de mercadorias que passaram a estar alcançadas pelo regime de substituição tributária", "Destino: Fornecedor de mercadoria do mesmo gênero inscrito no cadastro de contribuintes de MG", "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )
	    aAdd( aBody, { "", "835de3bf-feaf-ede7-2183-6de3bffa30b0", "00061", "Crédito acumulado pelo recebimento de acordo com artigo 27", "Destino: Outro contribuinte de MG conforme Regime Especial SUTR",                                                        "1f139103-3190-60b6-41c5-8fe3cc9fc639", "000012","" } )

	    //DAPI-MG
	    //// Créditos Transferidos
	    aAdd( aBody, { "", "b5c9e565-411b-db2b-d6a7-fb5d68e795d6", "00000", "Mandato de Segurança", "",                                                                                                                                                              "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "8b0659ab-2d2e-4682-883e-3cfe8b0291e0", "00001", "Recebimento de Crédito Acumulado Transferido para Aquisição de Ações ou Quotas de Capital (recebido com códigos 02 e 05)", "Destino: Fornecedor Mineiro (20% da operação)",             "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "65dbb1f8-76f4-edf2-85f4-e80c28c750f5", "00002", "Diferimento", "Destino: AQUIS. DE AÇÕES OU COTAS de Indústria Mineira em fase de instalação/expansão",                                                                                  "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "ab19af66-eba3-a663-8db4-6b9373d12f22", "00003", "Diferimento", "Destino: Fornecedor Mineiro (20% da Operação)",                                                                                                                          "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "61b8b64c-fe24-5bf2-a4b7-c20437258f4a", "00004", "Diferimento", "Destino: Outro estabelecimento da mesma empresa ou empresa interdependente, situados em MG",                                                                             "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","20040401" } )
	    aAdd( aBody, { "", "45c99f25-47c6-c024-4159-2509f4cd3b84", "00005", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE", "Destino: AQUIS. DE AÇÕES OU COTAS de Indústria Mineira em fase de instalação/expansão",                                   "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "ed4a5d60-115d-0ac3-052d-13295b5763a9", "00006", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE", "Destino: Fornecedor Mineiro (20% da operação)",                                                                           "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "52161ef9-1ae8-b257-3be7-fc54a53552c9", "00007", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE", "Destino: Outro estabelecimento da mesma empresa ou empresa interdependente, situados em MG",                              "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","20040401" } )
	    aAdd( aBody, { "", "0b798eb9-f494-0ad0-ab7d-f2ee5f545453", "00008", "Exportação", "Destino: Estabelecimento do mesmo titular situado no Estado",                                                                                                             "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "aa0512dd-89a8-b434-d75a-e47100f01bf3", "00009", "Exportação", "Destino: Outro contribuinte de MG",                                                                                                                                       "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "dbec6128-636c-302d-5d46-5cf158914cb9", "00010", "Exportação (detentor original do crédito)", "Destino: Pagamento crédito tributário",                                                                                                    "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "2281fc1f-99f8-ee00-4039-707aca3c2354", "00011", "Exportação (detentor original do crédito)", "Destino: Pagamento ICMS diferença de alíquota",                                                                                            "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","20040401" } )
	    aAdd( aBody, { "", "0cf43f81-44d3-ede9-ed5a-ccfbda0c75e4", "00012", "Exportação", "Destino: Fornecedor de outro Estado",                                                                                                                                     "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","20040401" } )
	    aAdd( aBody, { "", "83e3e7a8-2bda-5ef8-dee4-425a947c0b2a", "00013", "Crédito Acumulado definido em Regime Especial p/ atração de novos investimentos para MG", "Destino: Novos estabelecimentos - Conforme Regime Especial (SRE - Art. 5º Inc. II)",         "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","20040401" } )
	    aAdd( aBody, { "", "8565a692-4e78-38f1-cf68-3a00fda7297d", "00014", "Diferimento", "Destino: Específico - Conforme Regime Especial (DF)",                                                                                                                    "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "b8b81d4a-eda9-b858-52c4-e5332b9f08cc", "00015", "Crédito Acumulado", "Destino: Transferência de Estoque, previstas nos itens 35 e 36 do Anexo II",                                                                                       "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "6e95ffab-b4a0-1df7-fdf3-f16f3e255038", "00016", "Saídas Isentas de fabricante de ração avícola para estabelecimento de sua propriedade ou de produtor integrado", "Destino: Estabelecimento abatedor da mesma  empresa - Regime Especial (DF)", "a6328391-9e58-dfce-65c8-c3e78a4049aa",   "000012","" } )
	    aAdd( aBody, { "", "2496d7e1-897c-9a02-da7c-3f87e93d668b", "00017", "Crédito acumulado em  razão operação intermediária isenta ou não tributada com produto agropecuário", "Destino: Outro contribuinte de MG",                                              "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "570103f9-a3ed-2dfb-5d2d-1c0edf9c0d4c", "00018", "Exportação", "Destino: Empresa interdependente de MG",                                                                                                                                  "a6328391-9e58-dfce-65c8-c3e78a4049aa",   "000012","20040401" } )
	    aAdd( aBody, { "", "29f98fcf-bc6f-f480-e7d1-861104f4a9d7", "00019", "Recebimento de Crédito Acumulado de estabelecimento da mesma empresa ou de empresa interdependente (recebido c/ códigos 08 ou 18)", "Destino: Pagamento ICMS vencido",                  "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","20040401" } )
	    aAdd( aBody, { "", "d3c3bf0c-e7b8-84ef-f0c4-f8ea6dc35a53", "00020", "Recebimento de Crédito Acumulado de estabelecimento da mesma empresa ou de empresa interdependente (recebido c/ códigos 08 ou 18)", "Destino: Pagamento ICMS diferença de alíquota",    "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","20040401" } )
	    aAdd( aBody, { "", "a010971c-9dd0-0dd4-80ca-8c808f78c38f", "00021", "Crédito Acumulado definido em Regime Especial p/ pagamento pela aquisição de veículos, máquinas e equipamentos, novos, destinados ao ativo permanente", "Destino: Fornecedor situado neste Estado - Conforme Regime Especial (SRE - Art. 5º Inciso II)",                          "a6328391-9e58-dfce-65c8-c3e78a4049aa",   "000012","20020801" } )
	    aAdd( aBody, { "", "829e4b29-d888-5871-531c-0a8191777b83", "00022", "Crédito Acumulado de empresa coligada ou controlada pertencente a grupo econômico de fornecedora de energia elétrica e prestadoras de serviço de comunicação", "Destino: Empresa fornecedora de energia elétrica ou prestadora de serviço de comunicação para pagamento de ICMS", "a6328391-9e58-dfce-65c8-c3e78a4049aa",   "000012","" } )
	    aAdd( aBody, { "", "7fbf6af0-0075-29ba-9b81-9864c639c3be", "00023", "Saldo credor acumulado por estabelecimento gerador de energia elétrica", "Destino: Distribuidores de energia ou para empresas consorciadas",                                            "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "b43369a1-c2d9-1c73-90ce-6c130c3b332b", "00024", "Diferimento (detentor original do crédito)", "Destino: Pagto crédito tributário",                                                                                                       "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "b6c1eb95-6711-2f3a-937d-cf3f7df39cbc", "00025", "Saídas internas a 7% de Indústria alimentícia-Divisão 10 da CNAE (detentor original do crédito)", "Destino: Pagto crédito tributário",                                                   "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "8dc2d72c-0acf-b417-7bd7-68581723b270", "00026", "Diferimento - (detentor original classificado nas Divisões 05 a 33 e CNAEs específicos)", "Destino: Pagto ICMS importação - ativo permanente desembaraçado no Estado",                  "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "ff239574-ce0e-8b9b-0f4c-a4492b3bc702", "00027", "Diferimento", "Destino: Contribuintes do Estado pertencentes às Divisões 05 a 33 e CNAE específicos, para pagamento de ICMS importação - ativo permanente desembaraçado no Estado",     "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "d6cb5221-8ddb-b101-b26b-3c661371f0ec", "00028", "Exportação (detentor original do crédito classificados nas Divisões 05 a 33 e CNAEs específicos)", "Destino: Pagto ICMS importação - ativo permanente desembaraçado no Estado",         "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "995d3eb8-2a98-1dc4-ad1f-f20e1d5f1267", "00029", "Exportação", "Destino: Contribuintes de CNAE-Fiscal pertencente às Divisões 05 a 33 e CNAEs específicos, para pagamento de ICMS importação - ativo permanente desembaraçado no Estado", "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "9522ca82-85b0-be2b-40d0-d22223c3e1c0", "00030", "Exportação", "Destino: Outro contribuinte de MG para pagamento de crédito tributário",                                                                                                  "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "27ea201c-065c-190b-fbf0-b0f324db7673", "00031", "Diferimento", "Destino: Estabelecimento do mesmo titular situado em MG",                                                                                                                "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "fcb3d571-45cd-f29c-faab-2b81a3de6400", "00032", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE", "Destino: Estabelecimento do mesmo titular situado em MG",                                                                 "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "0a30d5c5-9070-9214-5cfe-bcfa7bfe67a8", "00033", "Diferimento", "Destino: Estabelecimento do mesmo titular para pagamento de crédito tributário",                                                                                         "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "13bff8b7-0eb8-4df9-c5e9-94d0b8718934", "00034", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE", "Destino: Estabelecimento do mesmo titular para pagamento de crédito tributário",                                          "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "29d9c5a6-5764-4172-5562-241954fcb2e3", "00035", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE (detentor original do crédito)", "Destino: Pagamento ICMS importação - ativo permanente desembaraçado no Estado",            "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "a87d1c1d-7e5d-a3a7-fd9b-f73d5964c71c", "00036", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE", "Destino: Contribuintes do Estado pertencentes às Divisões 05 a 33, para pagamento de ICMS importação - ativo permanente desembaraçado no Estado", "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "4e81a4b6-06e0-5cb6-602f-94d2e67def4d", "00037", "Crédito Acumulado", "Destino: Novo Estabelecimento industrial, de contribuinte que SE instalar neste Estado ou de contribuinte já inscrito",                                            "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "42481a99-cd00-d230-5139-6047a5be44a8", "00038", "Crédito Acumulado", "Destino: Estabelecimento industrial de contribuinte situado neste Estado em fase de expansão",                                                                     "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "93716f56-a523-dfb6-3509-4381c7b09f63", "00039", "Crédito acumulado em operações com equipamentos e componentes p/ aproveitamento de energia solar eólica", "Destino: Outro contribuinte de MG",                                          "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "1c11d29b-96aa-f6a4-860c-e8d02af30de4", "00040", "Protocolo ICM 12/84 referente operações com leite- MG e SP", "Destino: Transferências para contribuintes de MG e de São Paulo",                                                         "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "90ba0ccb-bedb-a0ad-e68e-a012e01ecd76", "00041", "Crédito acumulado por estabelecimento industrial ou produtor rural", "Destino: Estabelecimento industrial de MG para aquisição de caminhão, trator, máquina, equipamento agrícola, novos produzidos no Estado, para ativo permanente. Conforme regime especial", "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "2fb44381-1b90-4f58-535e-b2f26e3c8e93", "00050", "Transferência crédito acumulado não relacionado nas situações anteriores", "",                                                                                                          "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "bc884528-a1f8-79f8-faf3-83ed18ecdc60", "00051", "Compensação entre Saldo Devedor/Credor mesmo núcleo I.E.", "Destino: Sujeito passivo de mesmo núcleo de I.E.",                                                                          "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "b93ddf07-777d-f047-be4d-ff6033cac3cc", "00052", "Saídas com diferimento de ligas de alumínio secundário produzido a partir de sucata", "Destino: Estabelecimento do mesmo titular situado em MG",                                        "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "dbcc2b34-dc3d-0a5c-158b-c56b5d50507e", "00053", "Saídas com diferimento de ligas de alumínio secundário produzido a partir de sucata", "Destino: Outro contribuinte de MG",                                                              "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "d47bba49-ff75-ea11-922d-57e16b68299c", "00054", "Saídas de ligas de alumínio secundário produzido a partir de sucata", "Destino: Estabelecimento do mesmo titular para pagamento de crédito tributário",                                 "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "4e3ef5fc-c79f-81cb-32fb-4db43f2181f5", "00055", "Saídas de ligas de alumínio secundário produzido a partir de sucata", "Destino: Outro contribuinte de MG para pagamento de crédito tributário",                                         "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "be9d4471-578a-5e5f-89f5-66f40b18c271", "00056", "Crédito Acumulado por estabelecimento industrial em fase de expansão", "Destino: Utilização para pagamento ICMS importação ou pagamento de ICMS devido pela entrada, em decorrência de operação interestadual, de mercadoria destinada ao ativo permanente", "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "b9ca3406-da14-c2de-ee5c-618f095f3697", "00057", "Crédito Acumulado por estabelecimento industrial em fase de expansão", "Destino: Transferência a título de pagamento pela aquisição de material de construção ou para estabelecimento industrial a título de pagamento pela aquisição de bem para ativo permanente", "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "365f287b-ba75-048b-fc17-cb303567ac7d", "00058", "Crédito Acumulado por estabelecimento industrial", "Destino: Estabelecimento industrial de mesma titularidade em fase de expansão ou novo",                                            "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "f3ca73ca-e82e-c29c-6906-135d47b28af0", "00059", "Crédito acumulado em razão de saídas isentas (item 136 da Parte I do Anexo I) cujas operações estejam sujeitas à substituição tributária", "Destino: Fornecedor de mercadoria do mesmo gênero inscrito no cadastro de contribuintes de MG", "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "7b5995e4-62fd-00bc-89cb-60fd664c3261", "00060", "Crédito acumulado em razão de apropriação extemporânea de créditos de entradas de mercadorias que passaram a estar alcançadas pelo regime de substituição tributária", "Destino: Fornecedor de mercadoria do mesmo gênero inscrito no cadastro de contribuintes de MG", "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )
	    aAdd( aBody, { "", "8c2e5bfa-8cd7-e310-621d-fe9e6751c952", "00061", "Crédito acumulado pelo recebimento de acordo com artigo 27", "Destino: Outro contribuinte de MG conforme Regime Especial SUTR",                                                        "a6328391-9e58-dfce-65c8-c3e78a4049aa", "000012","" } )

	    //DAPI-MG
	    //// Dedução - Utilização de créditos transferidos
	    aAdd( aBody, { "", "efdd469b-9b98-8418-1dc9-478c8d4ad881", "00008", "Exportação", "Destino: Estabelecimento do mesmo titular situado no Estado",                                                                      "e2a2d348-97c2-7584-f376-11a9427868c4", "000012","" } )
	    aAdd( aBody, { "", "10c30859-e40b-02e8-2df5-a95a7304b6d8", "00009", "Exportação", "Destino: Outro contribuinte de MG",                                                                                                "e2a2d348-97c2-7584-f376-11a9427868c4", "000012","" } )
	    aAdd( aBody, { "", "afe33db8-d3db-8741-6a12-7baa6ab874e6", "00031", "Diferimento", "Destino: Estabelecimento do mesmo titular situado em MG",                                                                         "e2a2d348-97c2-7584-f376-11a9427868c4", "000012","" } )
	    aAdd( aBody, { "", "e59448f7-0254-1acb-6a85-37b17722ba5e", "00032", "Saídas internas a 7% Ind. alimentícia - Divisão 10 da CNAE", "Destino: Estabelecimento do mesmo titular situado em MG",                          "e2a2d348-97c2-7584-f376-11a9427868c4", "000012","" } )
	    aAdd( aBody, { "", "2c723f08-46b5-8ca2-2fdc-0938d5d18f3c", "00052", "Saídas com diferimento de ligas de alumínio secundário produzido a partir de sucata", "Destino: Estabelecimento do mesmo titular situado em MG", "e2a2d348-97c2-7584-f376-11a9427868c4", "000012","" } )
	    aAdd( aBody, { "", "b98f2416-a451-81e5-6d1c-aa0f7c1fe0c1", "00053", "Saídas com diferimento de ligas de alumínio secundário produzido a partir de sucata", "Destino: Outro contribuinte de MG",                       "e2a2d348-97c2-7584-f376-11a9427868c4", "000012","" } )
	    aAdd( aBody, { "", "ad48a98a-988e-31b9-d70a-0aea1f2aa8a2", "00061", "Crédito acumulado pelo recebimento de acordo com artigo 27", "Destino: Outro contribuinte de MG conforme Regime Especial SUTR",                  "e2a2d348-97c2-7584-f376-11a9427868c4", "000012","" } )

	    //DAPI-MG
	    ////Ressarcimento - subst. Tributária
	    aAdd( aBody, { "", "a688ba06-b30b-0150-21fa-5f15be11629c", "00001", "Perda e ou deterioração",                                   "", "a7ebd2ec-5396-e75e-b1dd-f87423f1672d", "000012","" } )
	    aAdd( aBody, { "", "2c355ed8-25a4-7d45-42db-170712b19919", "00002", "Saída isenta ou não tributada",                           "", "a7ebd2ec-5396-e75e-b1dd-f87423f1672d", "000012","" } )
	    aAdd( aBody, { "", "e0e4b5f7-7464-a82b-5fae-a25a438e6fba", "00003", "Venda para outra UF",                                     "", "a7ebd2ec-5396-e75e-b1dd-f87423f1672d", "000012","" } )
	    aAdd( aBody, { "", "9c6aa470-aa88-087a-420b-de944c33e2f2", "00004", "Mercadoria não comercializada – Art. 66, § 8º, do RICMS", "", "a7ebd2ec-5396-e75e-b1dd-f87423f1672d", "000012","" } )

	    //DAPI-MG
	    ////Estorno de Crédito
	    aAdd( aBody, { "", "2f5c17db-56bd-7e76-9e3a-e5730c0cafa2", "00001", "Estorno de Crédito decorrente de recomposição fiscal",    "", "289a752b-ecd6-c3d9-192f-84f0b363cf6a", "000012","" } )
	    aAdd( aBody, { "", "87fc0896-345b-cf84-f485-46d9aff83c0b", "00002", "Demais Estornos de Créditos",                             "", "289a752b-ecd6-c3d9-192f-84f0b363cf6a", "000012","" } )
	    aAdd( aBody, { "", "2d0893d3-4130-f539-a6d6-8e6ed46a04b3", "00003", "Estorno de Crédito TTD",                                  "", "289a752b-ecd6-c3d9-192f-84f0b363cf6a", "000012","" } )
	    aAdd( aBody, { "", "c7c6c8a2-d629-724e-7ff5-dd54773ee00d", "00004", "Estorno de Crédito Sub-Apuração – Devolução",             "", "289a752b-ecd6-c3d9-192f-84f0b363cf6a", "000012","" } )
	    aAdd( aBody, { "", "0a296392-100c-ec36-1d76-721dd70c8541", "00005", "Estorno de Crédito Art. 73 – RICMS",                      "", "289a752b-ecd6-c3d9-192f-84f0b363cf6a", "000012","" } )

	    //DAPI-MG
	    ////Estorno de Débito
	    aAdd( aBody, { "", "4e674144-e6db-bcfe-44ae-403bbc791dcb", "00001", "Outros",                                                                  "", "3ba6a662-1207-ad30-615e-688f410030dc", "000012","" } )
	    aAdd( aBody, { "", "2f9174dc-f4f9-5296-dfde-b0c4e2f780bf", "00002", "Estorno Débito Serviço Transporte Recolhido ST",                          "", "3ba6a662-1207-ad30-615e-688f410030dc", "000012","" } )
	    aAdd( aBody, { "", "7bd5feba-bc8d-1b94-3c3a-9785cd23f42a", "00003", "Estorno de Débito Serviço Comunicação- Art 44-E do Anexo IX do RICMS/02", "", "3ba6a662-1207-ad30-615e-688f410030dc", "000012","" } )
	    aAdd( aBody, { "", "13881ae4-2bd2-1de2-e161-ed603bbb695c", "00004", "Estorno de Débito Serviço Comunicação – Regime Especial",                 "", "3ba6a662-1207-ad30-615e-688f410030dc", "000012","" } )
	    aAdd( aBody, { "", "552b2bb2-f194-afe1-73c4-e870ce9133d2", "00005", "Estorno de Débito TTD",                                                   "", "3ba6a662-1207-ad30-615e-688f410030dc", "000012","" } )
	    aAdd( aBody, { "", "f1f435b4-b530-9f89-0cfb-6244e1024d0f", "00006", "Estorno de Débito Sub-Apuração – Recolhimento Efetivo",                   "", "3ba6a662-1207-ad30-615e-688f410030dc", "000012","" } )

	    //DAPI-MG
	    ////Ressarcimento de ICMS
	    aAdd( aBody, { "", "bbc70156-4082-16f0-8b29-7d8b7de66396", "00001", "Ressarcimento ICMS",           "", "05c20dba-f852-130f-7cde-7ac4fcdbf9b1", "000012","" } )
	    aAdd( aBody, { "", "134b03dc-5f24-785f-400a-eb05c53631a5", "00002", "Abatimento de ICMS ST por RE", "", "05c20dba-f852-130f-7cde-7ac4fcdbf9b1", "000012","" } )

	    //GIA-RS
	    //OUTROS CRÉDITOS
	    aAdd( aBody, { "", "8ecc913c-b6c2-f5fd-e4ec-3cbeb7f9b876", "00001", "DIFERENCIAL DE ALÍQUOTA - MERC.OU PREST.DE SERV. REC.DE OUF,NAO VINC.A OPER.SUBS", "ART.16,I,F; 17,III",  "7af512c2-3648-5695-db21-c7b17b9933e6", "000024","" } )
	    aAdd( aBody, { "", "d444a74e-f0c9-0332-a7c5-159bc4cac72a", "00002", "ESTORNO DE CR-DITOS.",           											    "ART 34, LIVRO I, RICMS",  "7af512c2-3648-5695-db21-c7b17b9933e6", "000024","" } )
	    aAdd( aBody, { "", "fa2beebd-d917-8052-76b4-ebb2b3ba11d7", "00003", "ANTECIPAÇÃO DO IMPOSTO PARA O MOMENTO DA ENTRADA NO TERRITÓRIO DESTE ESTADO",  "LIVRO I, ART. 46, - 4",   "7af512c2-3648-5695-db21-c7b17b9933e6", "000024","" } )
	    aAdd( aBody, { "", "07c0f128-2f42-b195-cba1-e2fd718c5832", "00004", "ICMS REL.AS OP.SUBSEQUENTES C/AS MERC.EST.EST.ATACADISTA E VAR.POR OCASIÃO DA ENTR.NO REG. ST.",      "", "7af512c2-3648-5695-db21-c7b17b9933e6", "000024","" } )
	    aAdd( aBody, { "", "4486b8b0-a8b9-9319-18fc-cb6e03869601", "00005", "ANTECIP. IMPOSTO MOMENTO ENTR. ESTABEL. VAREJISTA PROD. FARMACEUT. RECEB. BONIFICACAO", "LV.I, ART46, 5", "7af512c2-3648-5695-db21-c7b17b9933e6", "000024","" } )
	    aAdd( aBody, { "", "70e11784-cfd7-af18-b177-3cc168188228", "00006", "IMP.DEVIDO NAS PRESTAÇÕES DE SER.DE TRANSP. DE CARGA POR TRANSP.NAO ESTAB.RS",    "LIVRO III, ART. 54",   "7af512c2-3648-5695-db21-c7b17b9933e6", "000024","" } )
	    aAdd( aBody, { "", "602f944d-2089-c5ad-4a35-eafd6d697061", "00007", "AMPARA/RS ICMS PRÓPRIO",           "",	 																   "7af512c2-3648-5695-db21-c7b17b9933e6", "000024","" } )
	    aAdd( aBody, { "", "ae18fa78-997d-db2c-851a-dbfc92c82db8", "00008", "AMPARA/RS ICMS ST",           "", 																		   "7af512c2-3648-5695-db21-c7b17b9933e6", "000024","" } )
	    aAdd( aBody, { "", "6f6bb021-01de-2bff-4719-044486844a47", "00009", "DIF.AL. EC 87",           "", 																			   "7af512c2-3648-5695-db21-c7b17b9933e6", "000024","" } )
	    aAdd( aBody, { "", "292b1143-4ea5-23cb-81ae-9cc7ff914029", "00010", "OUTROS",           "", 																				   "7af512c2-3648-5695-db21-c7b17b9933e6", "000024","" } )


	    //GIA-RS
	    //Crédito Presumido
	    aAdd( aBody, { "", "99ec63a6-aadc-ec23-d49e-376a010fccab", "00001", "LV.I,art.32,IV - RESTAURANTES", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "ef113232-f97b-2de4-3fc9-2dd74547422a", "00003", "LV.I,art.32,VI - OBRA DE ARTE", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "b4648ae3-015f-fb32-a25c-cc79f0e81043", "00004", "LV.I,art.32,VII - CHAPAS E BOBINAS DE ACO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "b8e46831-69b4-4ad2-e59e-c6967cf47e87", "00005", "LV.I,ART.32,CLXVII.PROD.AC.INF. E AUTOMACAO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "cb4ddc07-d143-2b8f-2aeb-abff4626160b", "00007", "LV.I,art.32,X -PECAS E COMPONENTES P/ CONDIC DE AR", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "9148aca6-77bf-49dd-4394-31021a06a149", "00008", "LV.I,art.32,XI,A-PROG.AGREGAR-CARNES-ENTR.DE GADO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "b49c01e3-6628-74f2-4e9b-f0b869640832", "00009", "LV.I,art.32,XII - INDUSTRIAS LANIFICIAS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "c259f985-b71e-50e6-88cf-0b9bb577b294", "00010", "LV.I,art.32,XIII - FUNDOPEM-RS - LEI 6.427/72", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "f8485a5a-fd24-1640-9858-00ae1bc46839", "00011", "LV.I,art.32,XIII - FUNDOPEM/PROPLAST", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "650fcb4f-262f-a7e2-4a63-e53ef86517b4", "00018", "LV.I,art.32,XIII - FUNDOPEM/NOSSO EMPREGO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "7d6a1a16-a626-8dc2-3410-0cc20d4d34b4", "00019", "'LV.I,ART.32,XIV-''TOPS''DE LA,FIOS ACRILICOS,FIOS LA'", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "b1fb5884-1cb7-353b-d19b-c09a6b35d333", "00020", "LV.I,art.32,XV - PROJETOS CULTURAIS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "dceff77c-bcf4-7fd9-c533-3e1380843f43", "00023", "LV.I,art.32,XIX - INDUSTRIA VINICOLA", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "e2bc9c53-c6a0-328b-d1f6-c87657413c5b", "00025", "LV.I,art.32,XXI -PRESTADOR SERVICOS DE TRANSPORTE", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "6ec94e3c-dacb-d6ef-8f90-175deaeacb6f", "00026", "LV.I,art.32,XXII -PREST SERVICO TRANSPORTE AEREO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "1716620f-fddf-6515-c01f-056a6a829abb", "00030", "LV.I,art.32,XXVI - INDUSTRIA DE QUEIJOS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "a5dc721b-a544-5680-e73e-a2ae8189e2d2", "00031", "LV.I,art.32,XXVII - FOMENTAR/RS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "ab86641d-047c-2179-3d7c-a350df5388cc", "00039", "LV.I,art.32,XXXV -IND LINGUICAS,MORTAD,SALSICHAS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "92d71d1e-e972-aa05-c80e-094acd2d3c7c", "00040", "LV.I,art.32,XXXVI - LEITE EM PO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "1f137fda-e4ad-3951-0df2-23c9673583ab", "00041", "LV.I,art.32,XXXVII - MADEIRA SERRADA", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "aa041bf6-68f7-279e-3772-8cff50e47654", "00042", "LV.I,ART.32,XXXVIII-CARNE GADO VACUM OU AVES COZI", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "4da5af99-aa20-5672-f76f-546fc6a20a7f", "00050", "LV.I,art.32,XLV - CARNE PARA O EXTERIOR", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "b35388a4-6b23-5d47-ecda-993ed73c32a9", "00054", "LV.I,art.32,XLIX- VERDURAS E HORTALICAS, LIMPAS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "22b38f6d-0c61-bc98-f61f-b7dad9635710", "00055", "LV.I,art.32,L- ALHO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "03c75c4b-5cf1-7cd4-c6c1-b317e29bc764", "00056", "LV.I,art.32,LI- ARRENDAMENTO MERCANTIL", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "80ab9771-1223-7b6d-e2eb-fc8e85625492", "00057", "LV.I,art.32,XI,C-PROG.AGREGAR-RS CARNES-SAIDAS I", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "1a14e08b-a371-2106-58e2-6128c5e5c189", "00058", "LV.I,ART.32,LII-PROG.PRO-PROD.AGRICOLA-AGROINDUS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "e3583e04-bfed-2769-fbf1-e865f5ccb59c", "00059", "LV.I,art.32,LIII-PROG.PRO-PROD.AGRICOLA-COOPERAT", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "4281bee7-ce56-c546-333a-77528424d180", "00060", "LV.I,art.32,LIV-SALAME E CARNE SUINA SIMPLESMENT", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "cb642e85-c496-7aca-066a-cf448faf59cc", "00061", "LV.I,art.32,LV - PAPEL HIGIENICO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "efbe62cf-46a0-11dd-0af5-fbf31162ed3d", "00064", "LV.I,art.32,LVIII - EMPANADOS DE AVES", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "35a12ebb-56f0-f04d-d9e1-17e62739b69c", "00065", "LV.I,art.32,LIX - MARMORES E GRANITOS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "9ebde318-bc34-604a-cf24-0200eb874fae", "00066", "LV.I,art.32,LX - MEL PURO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "780faa01-d3ac-af5a-14d2-c0ffcce8b127", "00067", "LV.I,art.32,LXI - MOVEIS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "8bd654b6-236d-ccc8-3e8f-24feb7c37904", "00068", "LV.I,art.32,LXII - BOLACHAS E BISCOITOS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "427e8c1a-8e26-7bc1-c813-fce3ba229bee", "00069", "LV.I,art.32,LXIII - LEITE FLUIDO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "f8156003-dbda-8961-e781-93a9287994bb", "00070", "LV.I,art.32,LXIV - PROJETOS SOCIAIS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "b1210eb8-d8f7-99c9-d077-1ecf944b2064", "00071", "LV.I,art.32,LXV - CONSERVAS DE FRUTAS EXC PESS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "7437bca7-67e7-35e3-92f8-670f9505d3e4", "00072", "LV.I,ART.32,LXVI - CONSERVAS DE PESSEGO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "8cdc8300-fa61-f863-7d57-d37b3c8db325", "00074", "LV.I,art.32,LXVIII - INDUSTRIAIS IMPORTADORES", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "62a93785-96cd-78de-e7a3-fca804394964", "00075", "LV.I,art.32,LXIX - FARINHA DE TRIGO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "40844f71-c4bb-fa53-6af4-d7c87ace6c9e", "00077", "LV.I,art.32,LXXI- FERTILIZANTES", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "46b58a7c-8b6f-d6aa-15bd-840ec9d7fbb4", "00079", "LV.I,art.32,LXXIII - PROCENS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "ed1c8327-22a9-4f71-f628-8f8e95dccc02", "00080", "LV.I,art.32,LXXIV - FUNDOPEM/RS-LEI 11916/03", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "213b7ed3-9ef0-975f-882a-a64578aeda77", "00082", "LV.I,art.32,LXXVI-FARINHA DE TRIGO, MISTURAS E P", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "5ff5d1d9-aa0d-eb0b-d431-11a0d2b6dfb5", "00083", "LV.I,art.32,LXXVII - CONSERVAS DE VERDURAS E H", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "2c5c3fda-ed9c-1b88-d6ac-7fd8c9788a68", "00084", "LV.I,art.32,LXXVIII - VINHO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "b01158d4-d4b7-7058-a729-555af46e6133", "00085", "LV.I,art.32,LXXIX - GELEIAS DE FRUTAS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "f4a6708a-7dfb-aab4-b7ec-a7978b07aa9d", "00087", "LV.I,art.32,LXXXI - PEIXES, CRUSTACEOS E MOLUS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "5951afd4-d44e-9e1e-705c-329d765befe4", "00088", "LV.I,art.32,LXXXII - CARNES E PROD RESULT ABAT", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "de4fb3d0-d34c-40eb-09c4-0761a565ee98", "00089", "LV.I,art.32,LXXXIII - PROD.INDUST.CARNES DE AV", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "51ab1919-e108-fcb7-a5a7-27906de73c8a", "00091", "LV.I,art.32,LXXXV - MILHO DE PIPOCA", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "6941a087-8c46-0019-7d24-894f9098fae0", "00092", "LV.I,ART.32,LXXXVI - MUNICOES", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "17f128e7-d179-c5bc-1fa5-9b278e0bfb9e", "00094", "LV.I,art.32,LXXXVIII - IND.BIODIESEL", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "b7ec8743-23cd-4807-f8bf-5779704818a9", "00096", "LV.I,art.32,LXXXIX - TOMATES-MOLHOS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "912bd877-e03b-f6f3-e1f7-051612d2e9c3", "00098", "LV.I,ART.32,XCI - ACOS SEM COSTURA", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "1171dce2-659f-2824-1878-738dd71365bd", "00099", "LV.I,art.32,XCII - COOPOLIM.POLO PETROQUIMICO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "c218d1bb-3ed4-fa03-613c-3f7b559f2ed8", "00101", "LV.I,art.32,XCIV - SUCOS DE UVA", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "460e5347-e8c9-da33-1fd1-68e1ee3a6aaf", "00103", "LV.I,ART.32,XCVI - PAPEL-COD.4707 DA NBM/SH-NCM", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "083f013d-1aa8-5968-dd9f-8475069448ca", "00104", "LV.I,art.32,XCVII-RESERVAT.FIBRA DE VIDRO/POLIE", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "7f56cc2e-4c56-9979-34e8-41e36fd421f2", "00105", "LV.I,art.32,XCVIII-EMPR.DESENV.PROJ.INOV.TECNOL", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "d782e5c5-7a5d-d015-1f15-4e52a57eb398", "00106", "LV.I,art.32,XCIX - SILICA DA QUEIMA CASCA ARROZ", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "4dfdf21b-41ad-d2e9-1618-4be3470c9316", "00109", "LV.I,ART.32,CII - PROGRAMA PRO-INOVA CO/RS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "be31ea0c-7a5d-0dbf-42d1-b1a24e00bfbf", "00110", "LV.I,art.32,CIII - PNEUM.CAM.AR.PROT.BORR.", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "59d7c85c-c7fe-5a96-ed87-311ddac7f107", "00111", "LV.I,art.32,CIV - MAQ.AP.IMP.AP.XXXVI", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "915b9458-5040-f405-d4a4-825186ce0eba", "00113", "LV.I,art.32,CVI - LEITE P/PROD.QUEIJO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "5cc13069-0551-35b2-6cf1-e2d527824e5e", "00114", "LV.I,art.32,CVII - LEITE DE PROD.PROP.PROD.RUR", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "950f19c9-64e4-44fd-28fb-79380b27dde5", "00117", "LV.I,art.32,CX - COOP.ELETR.RURAL", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "e1508526-5ba6-dfcd-9cec-f2976cb46aa4", "00118", "LV.I,art.32,CXI-FAB.GRANOLA,COOKIES E GTS COOK.", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "5621153b-fefd-30a1-a0be-80adde6901f4", "00120", "LV.I,art.32,CXIII-PRODUTOS CERAMICOS 6908.90.00", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "1d0c7515-f407-9079-6451-90962140ec4f", "00121", "LV.I,art.32,CXIV - FARELO DE SOJA", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "374fd9e6-aee8-ff33-d529-018a97b214d5", "00122", "LV.I,art.32,CXV-POLIEST.CRISTAL.POL.ALT.IMP./ES", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "c7e5aa6d-544e-37c5-bd68-42325092ccb5", "00123", "LV.I,art.32,CXVI-MOD./CIRC.MEM.CIRC.INTEGRADOS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "44c6384a-5dae-fd1b-2ce1-c1fa004800dc", "00125", "'LV.I,art.32,CXVIII. TRANSP.GRAN.", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "33367d1e-359f-039d-6ef4-49757814ed6b", "00126", "LV.I,art.32,CXIX-FAB.RAPADURA-AQ.INT.MEL.AC.MASC.", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "d2cdca57-84fc-9e5a-dd2e-8a72d0d55561", "00127", "LV.I,art.32,CXX - FAB.PNEUMATICOS - FUNDOPEM/RS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "fa5985e0-e6aa-68ed-577c-54c195e0d780", "00128", "LV.I,art.32,CXXI - GUIND. E CAM-GUINDASTES", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "28e5d4f6-e8ed-2760-4f3c-95b390482a1c", "00129", "LV.I,art.32,CXXII - EMPR.IMP.PNEUMATICOS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "1b41299f-5256-22f3-538c-37c27682c341", "00131", "LV.I,art.32,CXXIV-EST.FAB.CHOC.ACH.CAR.CER.FUNDOP", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "89d929ea-b087-dd4e-ae47-db9b754ff66e", "00133", "LV.I,art.32,CXXVI-CARNES E PROD.COMEST.ABAT.AVES", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "51007cea-0e9e-d4f6-e378-4e5d0ab12e40", "00134", "LV.I,art.32,CXXVII- FAB.DISP.P/FECHAR RECEPIENT.", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "182f3984-5d4c-6946-4228-3ef7201c2c7b", "00137", "LV.I,ART.32,CXXX - FAB.CALCADOS ARTEFATOS COURO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "b8e1d21b-c432-9805-f7c5-6803f16ba88c", "00138", "LV.I,art.32,CXXXI- FAB.MERC.P/USO NAVAL/OFFSHORE", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "abb9c6a8-f6eb-b88f-5be0-2c775e511b55", "00139", "L.I,ART.32,CXXXII.FUNDOVINOS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "55702f0a-cfcd-a632-9b98-dedb826d8990", "00140", "L.I,ART.32,CXXXIII.ABATEDORES - SUINOS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "5f64a38d-3deb-23fa-7ca2-92987946a2e9", "00141", "L.I,ART.32,CXXXIV.FABRICANTES DE TORRES E PORTICOS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "e6148301-2410-7732-e787-33fcf131992c", "00145", "LIVRO I,ART.32,CXXXVIII. PROG. PRO-ESPORTE-RS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "714d3023-29d1-735c-ab96-0e04cc60877b", "00146", "LIVRO I,ART.32,CXXXIX.FAB.SORO LEITE PO/COMP.LAC.", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "6b38c9a0-dd25-f332-e766-8fcf647a5cdc", "00147", "LIVRO I,ART.32 CXL.MICROCERVEJARIAS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "c00bda02-35d4-3a97-9216-4d45de248c3d", "00149", "LIVRO I,ART.32,CXLII. FUNDOMATE", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "8108d213-e280-e791-10cb-18bdb3582571", "00150", "LIVRO I, ART. 32, CXLIII.COOP. FUNDO COOPERAR", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "0b74e4ef-ee20-bec0-429f-d9f38c1549da", "00152", "LIVRO I, ART. 32, CXLV.FAB.MOTOV.FRIG.", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "0545a6ec-4dce-bd80-92b9-66251c434767", "00153", "LIVRO I, ART. 32, CXLVI.IND.PROD.ETANOL", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "7097276c-e9b4-a649-bf75-d9d8fe961c6b", "00154", "LIVRO I,ART.32,CXXI,B.GUIND/CAM.GUIND.IMPORT.", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "a72bf4d7-15c7-e272-5e19-86d70ffb1b2d", "00155", "LIVRO I,ART.32,CXLVII.ELEV.,MAQ.,EQUIP.TR.EL.", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "6126366b-ead2-bd4b-ace3-031e3178c8d1", "00157", "LIVRO I,ART.32,CXLIX.PROD.DE SAUDE E MEDICAMENTOS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "f36e7f1f-9bf7-5f9a-c191-154c9c044f64", "00158", "LIVRO I,ART 32,CL.POLIPROPILENO BIORIENTADO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "5920148d-5d6e-6b62-9d8e-73b36497a210", "00159", "LIVRO I,ART.32,CLI.PA CAR.ROD.,ESC,HID.RETROESC.", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "839b2a58-85b7-0827-8e77-eb73947fbd95", "00160", "LIVRO I,ART.32,CLII.CENTR.DISTR.VENDAS N.PRESENC.", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "a53c94e9-4e82-8f77-8455-96713a29701b", "00161", "LIVRO I,ART.32,CLVI.FABRICANTES DE LATICINIOS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "5ef7871e-63b9-f7fe-5640-3504b85cfe8d", "00162", "LIVRO I,ART.32,CLIV.APOIO A EVENTOS ESPORTIVOS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "8a5d88a0-617b-2534-7600-6c7893096e87", "00163", "LIVRO I,ART.32,CLV.FABRICANTES DE CELULOSE", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "50e3153e-0540-fe8f-9215-c5e6cde58a0f", "00164", "LIVRO I, ART.32,CLVII. FAB.VEIC.TRANSP.PROCAM/RS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "3b720c3d-2cb0-1ef0-30c6-60c40f9b9188", "00165", "LIVRO I, ART. 32, CLVIII. LEITE P/ IND.", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "7e09e5c3-6274-20bc-d48f-54d1b3d969f6", "00166", "LIVRO I, ART. 32, CLVIX. MAIONESE", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "db5ac4e3-41cd-18c1-f1e6-89d210a49008", "00167", "LIVRO I,ART.32,CLX.VIDROS", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "cdb897a1-1fa1-15f8-9594-ff1dface81eb", "00168", "LIVRO I,ART.32,CLXI. CARNES/BATATAS CONG.IMP.", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "5d25b407-5d5a-5395-3c79-862fd90e9421", "00170", "LIVRO I,ART.32,CLXIII. FEIJ-O,ARROZ IND.BOL.ARROZ", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "360f9baa-b191-6e60-8695-c3615740f7ab", "00172", "LIVRO I,ART.32,CLXV.COPOS, PR.,PTS,TAL.PLASTICO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "c5bf926a-d511-139f-ac99-6f59350b748d", "00174", "LIVRO I, ART.32,VIII.PROD.INF./AUT.FL.RECEPTOR", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )
		aAdd( aBody, { "", "7ca121d0-f482-1c6d-4b10-8b6db359a9a1", "00178", "LIVRO I,ART.32,CLXXI. FABRICANTES DE ESTIRENO", "","bb634f68-07fb-66dd-e9fb-307bf992642e", "000024","" } )


		//GIA-RS
	    //Créditos Recebidos
		aAdd( aBody, { "", "cd6c8231-d937-2c4e-d5a0-ae08f1c4c277", "00001", "'LIVRO I,58,I,''A'' -EXPORTACAO-ESTABEL MESMA EMPRESA'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "0fa5b0ce-d318-d8f8-68f5-2dd552aace58", "00002", "'LIVRO I,58,I,''B'' -EXPORTACAO-TRANSFORM,FUSAO,CISAO'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "657bee7e-218b-1a1b-9dca-d21c601b14aa", "00003", "LIVRO I,58,II -EXPORTACAO-OUTROS CONTRIBUINTES", "",			"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","20051012" } )
		aAdd( aBody, { "", "3108fbef-8707-6c22-eb94-e439a5c73d69", "00004", "'LIVRO I,59,I,''A'' -ESTABELECIMENTO MESMA EMPRESA'", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "0b0a07ac-517d-a61f-d86e-375e63e97c09", "00005", "'LIVRO I,59,I,''B'' -TRANSFORMACAO,FUSAO,CISAO,ETC'", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "e14b1524-ef27-9308-d922-260341f73993", "00006", "'LIVRO I,59,II,''A'',NOTA 02,''A'' -DIF-MAT-PRIMA,EMBAL'","",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "b9599578-c035-52f3-fe09-13c324a440b3", "00007", "'LIVRO I,59,II,''A'',NOTA 02,''B'' -DIF-MAQ,EQUIPAMENTO'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "58f27973-f901-e7ea-3b51-334ef2004b47", "00008", "'LIVRO I,59,II,''B'' -FABRICANTE TRATOR,COLHEITADEIRA'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "57f0fa01-5f6e-40a0-7bcc-6dd6b362c4ec", "00009", "'LIVRO I,59,II,''D'' -FABRIC VEIC-FOMENTAR/FUNDOPEM'", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "5456e062-d3d2-f86e-95da-a3fcc9989cf0", "00010", "'LIVRO I,59,II,''E'' -FAB PECAS,PARTES,COMPON AUTOMOT'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "c7112b1e-fcbb-1d77-52b1-106305fc9785", "00011", "'LIVRO I,59,II,''F'' -FABRIC VEICULOS -LEI 11.085/98'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "5305bebb-5987-fa26-1dc5-8742f311a732", "00012", "'LIVRO I,59,II,''G'' -FABRICANTE DEFENSIVOS AGRICOLAS'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "569ef2e7-19d4-8139-389e-eff36e0090d7", "00013", "'LIVRO I,59,II,''H'' -FABRICANTE DE PNEUMATICOS'", "",			"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "84b4be12-96ec-3634-c438-34ce9c107d8e", "00014", "'LIVRO I,59,II,''I'' -FABRIC CAMINHAO,TRATOR,MOTOR'", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "7447de52-2b28-8950-a79c-d25aaf8e80b6", "00015", "LIVRO I,59,III -FABRIC VEIC -PGTO DE SUBST TRIB", "",			"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "b861cf14-16a7-093f-cbab-49ca945c8a72", "00016", "'LIVRO I,ART.59,II,''J''-FABRICANTE FARELO ESTABIL'", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "0887e727-797b-bfdb-007d-8de80a0bc7a9", "00017", "'LIVRO I,ART.59,II,''L''-POSTO DE REVENDA MARITIMO'", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "95740384-14ab-abe8-f097-b2fb55015073", "00018", "LIVRO I,ART.37,5- CREDITOS FISCAIS EXCEDENTES", "",			"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "68605786-9b34-db37-df97-bfee93f468d4", "00019", "RICMS,LIVRO I,ART. 59, II, P", "",								"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "f6cce590-28ea-346e-55a3-c0252613dd50", "00020", "'RICMS,LIV.I,ART.58,II''A''1-EXPORTAÇÃO-MAT-PRIM,EMB'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "7f0424f1-cb61-b17c-b7ec-688b657502d1", "00021", "'RICMS,LIV.I,ART.58,II''A''2-EXPORTAÇÃO-MAQ.,EQUIPAM'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "eddb8116-8d7e-4174-c50c-15095ae61eca", "00022", "RICMS,LIVI,ART58,IIB-EXP-DEMAIS HIP. ATE R$100.000", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "a011cf9d-e6bf-3bfb-98f5-c9762f06616d", "00023", "RICMS,LIVI,ART58IIB-EXP-DEMAIS HIP ACIMA R$100.000", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "07811d83-cf36-73cc-ec07-3c0a8d5ea8f7", "00024", "'LIVROI,ART.59,II''A'',NOTA4-DIFERIMENTO ENERGIA ELET'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "95722a79-e4e6-a295-4640-9d0060209263", "00025", "LIVROI,ART.59,II,'M'-PREST.SERVIÇO TRANSP-AQUI VEI", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "49ce4a6f-e605-9f1e-e28e-1be19fc7f165", "00026", "LIVROI,ART.58,III,A-EXPORT-PGTO SUBST TRIB FOMENTA", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "949f8582-53f3-e139-8996-c562640300d6", "00027", "LIVROI,ART.58,III,B-EXPORT-AQUIS.MERC SERVI-OS FOM", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "ae72bc34-388a-3d67-d286-a0c56e409dcc", "00028", "LIVROI,ART.58,III,C-EXPORT-DEMAIS HIPOT FOMENTAR", "",			"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "471eb8f3-6248-5626-2b55-760e90218cea", "00029", "SERVI-O DE TRANSPORTE DE CARGA", "",							"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "f0acc571-552a-26c5-12d8-2a18570a0076", "00030", "'RICMS,LIVROI,ART.58,II,NOTA01,A,EART.58, II, ''A'''", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "15cb22ca-a146-6003-bee3-621db06bdcb6", "00031", "'RICMS,LIVROI,ART.58,II,NOTA01,B,EART.58, II, ''A'''", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "20fb9bc9-9e43-a063-9a54-b634973668d8", "00032", "RICMS,LIVROI,ART58,II,NOTA01,C,EART.58,II,A-EXPORT", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "0b9dcece-327d-2d39-78ca-1b701cbe76ff", "00033", "RICMS,LIVROI,ART58,II,NOTA01,E,EART.58,II,A-EXPORT", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "72d5ba4d-e497-f846-7e4c-9a15ecfb4b65", "00034", "RICMS,LIVROI,ART.58,II,NOTA01,E,ART.58,II,A,EART37", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "9a6a9e53-0796-eeaa-1672-af1e1d94d1f3", "00035", "'RICMS,LIVROI,ART.58,II,NOTA01,A,EART.58, II, ''B'''", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "d4ab47ae-1df8-fbe5-89fe-5390fbc57eb7", "00036", "RICMS,LIVROI,ART.58,II,NOTA01,B,EART.58,II,B-EXPOR", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "8a83e3c9-2a8f-60fe-3a71-36ef4e010f25", "00037", "RICMS,LIVROI,ART.58,II,NOTA01,C,EART.58,II,B-EXPOR", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "1d15f748-406a-2122-6b1f-08ef5c8238f8", "00038", "RICMS,IVROI,ART.58,II,NOTA01,E,EART.58,II,B-EXPORT", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "79cc318a-6db7-0b03-b454-baf6bcb40f37", "00039", "RICMS,LIVROI,ART.58,II,NOTA01,E,ART.58,II,B,EART37", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "5eadca42-2613-8385-3ffd-e8f513ccad71", "00040", "RICMS,LIVROI,ART.58,IV-EXPORTAÇÃO PAGTO CRED TRIB", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "6b7d4199-474d-456c-2fe0-632614d56bec", "00041", "'RICMS,LIVRO,I,ART58,V,''A''-EXP-OUT HIP ATE R$40.000'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "904c0e60-f10a-e614-5d61-f2d96a6d9da3", "00042", "RICMS,LIVI,ART.58,--N,EART.37,-2-,D,2,NOTA01", "",				"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "fd7c3a76-6435-2621-1161-83dd27c64801", "00043", "RICMS,LIVI,ART.58,--N,EART.37,-2-,D,2,NOTA01", "",				"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "295c849f-d845-95fe-f338-2f1bf3b4f0e8", "00044", "RICMS-LIV.I,ART.58,NOTA 01'D',E ART.58,II'A'", "",				"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "28aedc60-8a09-0656-2de3-3eb4158049e7", "00045", "'RICMS-LIVRO I, ART. 58, NOTA 01 ''D'' E ART.58,II,B'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "10bc48aa-74df-a26c-0d5d-06c3debc9b79", "00046", "'RICMS-LIVRO I, ART.59, II, ''O'''", "",						"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "47b4982a-ed49-e79a-b5c7-b112e0213325", "00047", "'RICMS-LIVI,ART59,II,D,''A''-FAB VEIC AQUIS MERC SERV'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "f5897853-cfaf-781f-42e3-a965c750f4d4", "00048", "'RICMS-LIVI,ART59,II,D,''B''-FAB VEIC DEM HIP FOMENTA'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "e4f8f66a-d1b1-c57b-9e3a-c3c8a67552f4", "00049", "LIVROI,ART.59,V-DIFERIMENTO,MAQ E EQUIP IND P/FAB", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "cf85c194-1559-1986-6594-82fd3520b039", "00050", "'RICMS,LIVRO,I,ART58,V,''B''-EXP-OUT HIP ATE R$30.000'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "326c8a14-73df-13ee-4fa0-b36bf5b5b163", "00051", "'RICMS,LIVRO,I,ART58,V,''C''-EXP-OUT HIP ATE R$20.000'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "37091049-3a89-7aab-9adc-46a4b5fae262", "00052", "'RICMS,LIVRO I,ART.58,II, NOTA 01, ''A'' A ''E'' E ART.'", "",	"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "20d61398-f961-34eb-a9f3-41287a5f35c7", "00053", "'LIVRO I, ART. 59, II, ''Q'' - EPC-SAIDA MAQ/EQUIP.'", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "5e818efd-5022-cc5f-0d5f-3dc2f30805eb", "00054", "'RICMS, LIVRO I, ART. 59, II, ''S'''", "",						"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "ac3d8fb7-8dd4-b12e-f3dc-7c59368f6066", "00055", "RICMS, LIVRO I, ART. 59, II, R", "",							"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "0dd4963c-5a5f-9360-fd62-1d0765d0f730", "00056", "RICMS, LIVRO I, ART.59, II,T", "",								"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "3b395010-daef-14fc-2a75-45d8e4966a9b", "00057", "RICMS, LIVRO I,ART.59,II,U", "",								"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "7030d5b7-41dd-5615-2e69-634a370baf35", "00058", "RICMS, LIVRO I, ART. 59, II, V", "",							"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "3e412b19-52ee-f9f0-2f67-361568144144", "00092", "RICMS,LIVI,ART58,--,EART37-2-,D,2,NOT1-EXP-TA A PA", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "0351606c-8e6d-6769-319b-d3765e71bbdc", "00093", "RICMS,LIVI,ART58,--,EART37-2-,D,2,NOT1-EXP-TA A PA", "",		"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )
		aAdd( aBody, { "", "7dfdebea-cb75-8f38-f688-185f56e3dbd1", "00098", "DECISÃO JUDICIAL", "",											"94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "000024","" } )

		//GIA-RS
	    //Débitos por transferência de crédito e de saldo devedor
	    aAdd( aBody, { "", "9a390b53-ccde-a913-17fa-9a06bf43ffa6", "00100", "'LIVRO I,58,I,''A'' -EXPORTACAO-ESTABEL MESMA EMPRESA'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "ee2bbe06-2cd4-410f-d080-2a27adaa4059", "00101", "'LIVRO I,58,I,''B'' -EXPORT-TRANSFORMACAO,FUSAO,CISAO'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "513aeab0-95c7-c3b8-bd06-5a2e5300e044", "00102", "LIVRO I,58,II -EXPORTACAO-OUTROS CONTRIBUINTES", "",			"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "7b0e3699-b38e-afb4-ed8c-234c024a742a", "00103", "'LIVRO I,59,I,''A'' -ESTABELECIMENTO MESMA EMPRESA'", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "f5ffeeba-5a4e-ce12-6422-6e0fb9d96a51", "00104", "'LIVRO I,59,I,''B'' -TRANSFORMACAO,FUSAO,CISAO,ETC.'", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "25caeaf1-d863-e9a2-a142-3d3d3df1ea16", "00105", "'LIVRO I,59,II,''A'',NOTA 02,''A'' -DIF-MAT PRIMA,EMBAL'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "f069b796-1acb-d553-2dd9-1039b68cbc0d", "00106", "'LIVRO I,59,II,''A'',NOTA 02,''B'' -DIF-MAQ,EQUIPAMENTO'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "f5c625d7-772d-8af4-c26d-15041129512a", "00107", "'LIVRO I,59,II,''B'' -FABRICANTE TRATOR,COLHEITADEIRA'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "2aab9779-ecf2-e3c9-a7f9-47305e07a93b", "00108", "'LIVRO I,59,II,''D'' -FABRIC VEIC-FOMENTAR/FUNDOPEM'", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "31ec87d5-8d88-a958-2580-c0971defc162", "00109", "'LIVRO I,59,II,''E'' -FAB PECAS,PARTES,COMPON AUTOMOT'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "acbc2daa-088e-c386-d6d0-ec1891a21719", "00110", "'LIVRO I,59,II,''F'' -FABRICANTE VEIC -LEI 11.085/98'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "ae39b85b-59ca-598c-84ce-ec8a39a2379f", "00111", "'LIVRO I,59,II,''G'' -FABRICANTE DEFENSIVOS AGRICOLAS'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "4a87730b-e9ca-364f-6829-c26e776a97df", "00112", "'LIVRO I,59,II,''H'' -FABRICANTE DE PNEUMATICOS'", "",			"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "7147595a-8e63-9073-037a-ac63f4937453", "00113", "'LIVRO I,59,II,''I'' -FABRIC CAMINHAO,TRATOR,MOTOR'", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "0f3d3da7-1dc2-d74c-6901-9a8732496500", "00114", "LIVRO I,59,III -FABRICANTE VEIC-PGTO DE SUBST TRIB", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "30245944-4ecd-04bc-68ad-013dcbd262c4", "00115", "'LIVRO I,ART.59,II,''J''-FABRICANTE FARELO ESTABILI'", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "95bc0ce0-f17e-85d4-ed29-895a8734b0ce", "00116", "'LIVRO I,ART.59,II,''L''-POSTO DE REVENDA MARITIMO'", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "1cffdb0a-8bdc-d98f-f5fc-f4553f4440e3", "00117", "LIVRO I,ART 37,5- CREDITOS FISCAIS EXCEDENTES", "",			"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "7265b377-a5c7-c871-2205-9e122a079483", "00118", "RICMS, LIVRO I, ART. 59, II, P", "",							"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "e17d1354-6cba-d66b-86e9-f90c4b04eb47", "00119", "'RICMS,LIV.I,ART.58,II''A''1-EXPORTAÇÃO-MAT-PRIM,EMB'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "04d7af07-1540-39a6-3474-99e2ab741b2b", "00120", "'RICMS,LIV.I,ART.58,II''A''2-EXPORTAÇÃO-MAQ.,EQUIPAM'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "46c0190c-7aaa-6166-f998-6ec9121b4f98", "00121", "RICMS,LIVI,ART58,IIB-EXP.DEMAIS HIP ATE R$100.000", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "d7e402a7-9e04-4778-a762-5d6a0a7b631d", "00122", "RICMS,LIVI,ART58IIB-EXP-DEMAIS HIP ACIMA R$100.000", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "0516ea01-cd49-3cfb-8bce-9b7bfc45129a", "00123", "'LIVROI,ART.59,II''A'',NOTA4-DIFERIMENTO ENERGIA ELET'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "fd1646ae-5642-c64c-f761-6cebe5c43737", "00124", "LIVROI,ART.59,II,'M'-PREST.SERVI-O TRANSP-AQUI VEI", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "fe466866-f493-76b2-fe6a-e9b2af4729a9", "00125", "LIVROI,ART.58,III,A-EXPORT.PGTO SUBST.TRIB FOMENTA", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "ce73c451-5948-7130-04f0-daf9dd47595f", "00126", "LIVROI,ART.58,III,B-EXPORT-AQUIS MERC. E SERVI-OS", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "be8f5a7a-7eab-1fc2-12c6-fa280d386e6b", "00127", "LIVROI,ART.58,III,C-EXPORT-DEMAIS HIPOTESES FOMEN", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "3a5b3d2d-39ce-1ceb-95ed-6b8902126dfc", "00128", "RICMS-LIVROI,ART.59,IV-SERVI-OS DE TRANSP.DE CARGA", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "27db0349-142e-9a82-a815-981f6138ac54", "00131", "RICMS,LIV I,ART.58,II,NOTA01,A,EART.58II,A-EXPORT", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "f6143f70-064c-28bc-57a8-98411b8daf91", "00132", "RICMS,LIV I,ART.58,II,NOTA01,B,EART.58,II,A-EXPORT", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "ef3af449-e592-847e-1e7e-45296f337c11", "00133", "RICMS,LIV I,ART.58,II,NOTA01,C,EART58,II,A-EXPORT", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "623c3217-fc5d-b391-80f2-6afdc246911f", "00134", "RICMS,LIVROI,ART.58II,NOTA01,E,EART.58,IIA-EXPORT", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "2234807b-d213-2372-8b0e-e52d9531fde3", "00135", "RICMS,LIVROI,ART.58,II,NOTA01,E,ART.58,II,A,EART37", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "3e4f7ee3-631c-bdf5-4c9d-94b99eba3eb9", "00141", "RICMS,LIVI,ART.58,II,NOTA01,A,EART58,II,B-EXPORT", "",			"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "8bd4ee3c-dac2-4f43-d57f-c12ebba10755", "00142", "RICMS,LIVROI,ART58,II,NOTA01,B,EART.58,II,B-EXPOR", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "fb11c85f-ca64-d3a4-d686-53e11b0ecf54", "00143", "RICMS,LIVROI:ART.58,II,NOTA01,C,EART58,II,B-EXPORT", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "afbb4db2-5a50-06bb-5272-736451790c58", "00144", "RICMS,LIVROI:ART.58,II,NOTA01,E,EART.58,II,B-EXPOR", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "ea93b8ba-cede-23fd-2751-ba78fe6b6cca", "00145", "RICMS,LIVROI:ART.58,II,NOTA01,E,ART58,II,B,EART37", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "f2abd601-6c2a-8dbb-ad9f-87b90d1f7afd", "00151", "RICMS,LIVI,ART.58,IV-EXPORT-PAGTO DE CRED TRIB C", "",			"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "2e2f985f-3796-121e-5334-7ea8fe47946a", "00152", "'RICMS,LIVRO,I,ART58,V,''A''-EXP-OUT HIP ATE R$40.000'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "b13b17df-0b84-0360-de0f-c8f2a3dce572", "00153", "RICMS,LIVI:ART.58,- -N,EART.37,-2-,D,2,NOTA01", "",			"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "e57cb39f-49cc-fe98-c883-39cb79104911", "00154", "LIVROI:ART.58,PARAG.U,ART.37,PARAG.2,D,2,NOT01", "",			"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "eda909cc-ec25-55ec-a8e5-49eebfdfbc02", "00155", "'RICMS,LIVRO I, ART. 58, NOTA 01,''D''E ART.58,II,'A''", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "a1141ba9-7c1b-9f56-f89e-2a3cb17f4c10", "00156", "'RICMS,LIVRO I, ART. 58,II NOTA 1,''D'' E ART 58,II,B'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "d6ffc620-38fc-568e-8aa8-8cf8d68b12a0", "00157", "'RICMS-LIVRO I, ART.59, II, ''O'''", "",						"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "e468b142-11db-4a30-f6a8-a1365979a5f2", "00158", "'RICMS,LIVI,ART59,II,''D'',A-FAB VEIC AQUIS MERC SERV'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "77bc74a1-c1be-ef00-a2d1-4697d8ff5ed0", "00159", "RICMS,LIVI,ART.59,II,D,B-FAB VEIC DEM HIP FOMENTAR", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "941b0348-69c3-3c5e-045b-1db2a763b3c0", "00160", "LIVROI,ART.59,V-DIFERIMENTO,MAQ E EQUIP IND / FAB", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "6a1eefe1-d4b7-6f3f-5187-5f35440da545", "00161", "'RICMS,LIVRO,I,ART58,V,''B''-EXP-OUT HIP ATE R$30.000'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "e1a53333-7cdb-a150-2e3b-488ed1f0d957", "00162", "'RICMS,LIVRO,I,ART58,V,''C''-EXP-OUT HIP ATE R$20.000'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "35bf8c13-94e7-640f-75b0-f53b7ea19c44", "00163", "'RICMS, LIVRO I,ART.58,II, NOTA 01,''A'' A ''E'' E ART.'", "",	"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "cea589ed-baa4-b7a5-dea7-20999f05fb51", "00164", "'LIVROI, ART. 59, II, ''Q'' - EPC-SAIDA MAQ/EQUIP.'", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "fd5da701-0e9d-0409-4eeb-48d53e5b42a0", "00165", "'RICMS, LIVRO I, ART. 59, II, ''S'''", "",						"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "93da3731-54a1-c5e1-0f23-cc861b7662ac", "00166", "RICMS, LIVRO I, ART. 59, II, R", "",							"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "58c14677-6a40-3f3f-cb23-a08ac3dc055b", "00167", "RICMS, LIVRO I, ART.59, II, T", "",							"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "78ca0bbe-199b-dd6a-515a-4bb086b28dcc", "00168", "RICMS, LIVRO I, ART. 59, II, U", "",							"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "85fc9c47-5cc9-b4e7-2b2c-7f11447a48f0", "00169", "RICMS, LIVRO I, ART.59, II, V", "",							"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "8139f4b6-4aa9-7f0f-9cb5-0d2ba1ce172b", "00192", "RICMS,LIVI,ART58,--,EART37-2-,D,2,NOT1-EXP-TA APAR", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "ceee3cdd-a883-ceac-d81a-9962130b520a", "00193", "RICMS,LIVI,ART58,--,EART37-2-,D,2,NOT1-EXP-TAA PAR", "",		"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
		aAdd( aBody, { "", "809d28ad-5774-91d5-c45a-abc4e878f7c8", "00198", "DECISÃO JUDICIAL", "",											"fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "000024","" } )
	    
		aAdd( aRet, { aHeader, aBody } )
	EndIf
EndIf

Return( aRet )