#INCLUDE "Protheus.CH"
#INCLUDE "FwMVCDef.CH"
#INCLUDE "TAFA532.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA532

Cadastro MVC de Códigos de Conta referencial LALUR B.

@Author Matheus G. Prada
@Since 25/04/2019
@Version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA532()

Local oBrw := FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Cadastro de Código de Conta Referencial"
oBrw:SetAlias( "V3K" )
oBrw:SetMenuDef( "TAFA532" )
V3K->( DBSetOrder( 2 ) )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@Author Matheus G. Prada
@Since 25/04/2019
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return xFunMnuTAF( "TAFA532",,,, .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@Return oModel - Objeto do Modelo MVC

@Author Matheus G. Prada
@Since 25/04/2019
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruV3K := FwFormStruct( 1, "V3K" )
Local oModel   := MpFormModel():New( "TAFA532" )

oModel:AddFields( "MODEL_V3K", /*cOwner*/, oStruV3K )
oModel:GetModel( "MODEL_V3K" ):SetPrimaryKey( { "V3K_FILIAL", "V3K_ID" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@Return oView - Objeto da View MVC

@Author Matheus G. Prada
@Since 25/04/2019
@Version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA532" )
Local oStruV3K := FwFormStruct( 2, "V3K" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_V3K", oStruV3K, "MODEL_V3K" )
oView:EnableTitleView( "VIEW_V3K", STR0001 ) //"Cadastro de Código de Conta Referencial"
oView:CreateHorizontalBox( "FIELDSV3K", 100 )
oView:SetOwnerView( "VIEW_V3K", "FIELDSV3K" )

oStruV3K:RemoveField( "V3K_ID" )
oStruV3K:RemoveField( "V3K_IDCTAS" ) 

Return( oView ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Matheus G. Prada
@Since		25/04/2019
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu ) 

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1031.33

If nVerEmp < nVerAtu
	aAdd( aHeader, "V3K_FILIAL" )
	aAdd( aHeader, "V3K_ID" )
	aAdd( aHeader, "V3K_CODIGO")
	aAdd( aHeader, "V3K_DESCRI")
	aAdd( aHeader, "V3K_TRIBUT")
	aAdd( aHeader, "V3K_DTINI" )
	aAdd( aHeader, "V3K_DTFIN" )

	aAdd( aBody, { "", "b0c99256-0957-b8df-3bd0-3b146894f5d7", "1.000", "Prejuízo Fiscal Operacional - Atividade Geral", "I" , "20180101", "" } )
	aAdd( aBody, { "", "11bfb54d-68d4-7712-553b-08ad518f68ca", "1.001", "Prejuízo Fiscal - Não Operacional", "I" , "20180101", "" } )
	aAdd( aBody, { "", "9e4eb167-c578-a9c5-5112-5902a3e6a434", "1.002", "Prejuízo Fiscal - Atividade Rural", "I" , "20180101", "" } )
	aAdd( aBody, { "", "7b6e10b3-9290-d261-4954-978e2d581a9a", "1.003", "Base de Cálculo Negativa da CSLL - Atividade Geral", "C" , "20180101", "" } )
	aAdd( aBody, { "", "d228890b-df7b-514d-e35f-0d0833001bc4", "1.004", "Base de Cálculo Negativa da CSLL - Atividade Rural", "C" , "20180101", "" } )
	aAdd( aBody, { "", "5e827afd-76c6-5fff-9a8d-a3e69f480e96", "1.005", "Provisões ou Perdas Estimadas Não Dedutíveis", "A" , "20180101", "" } )
	aAdd( aBody, { "", "a06c5d91-fbe8-4c75-c45a-e1e8f05add67", "1.010", "Investimento Avaliado pelo Valor de Patrimônio Líquido - Redução da Mais-Valia", "A" , "20180101", "" } )
	aAdd( aBody, { "", "fbe4a419-4705-50c7-86df-25115cdc94c7", "1.015", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Aquisição em Estágios - Perda com Base no Valor Justo", "A" , "20180101", "" } )
	aAdd( aBody, { "", "093a1451-d2f3-4677-4268-47581ebcd96f", "1.020", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Aquisição em Estágios - Redução da Variação Positiva da Mais-Valia", "A" , "20180101", "" } )
	aAdd( aBody, { "", "88286d93-2bd9-e68d-5229-34085b377f25", "1.025", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Aquisição em Estágios - Redução da Variação Positiva do Goodwill", "A" , "20180101", "" } )
	aAdd( aBody, { "", "5167b783-5f7e-0972-6044-7b63d994cf44", "1.030", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Aquisição em Estágios - Redução da Variação Negativa da Menos-Valia", "A" , "20180101", "" } )
	aAdd( aBody, { "", "2f0d290c-e464-e55b-c301-bb5a6fb57782", "1.035", "Investimento Avaliado pelo Valor de Patrimônio Líquido – AVJ na Investida Não Controlado por Meio de Subconta - Registrado em Conta de Patrimônio Líquido – Ganho", "A" , "20180101", "" } )
	aAdd( aBody, { "", "1b49fd2d-7335-1a13-cbf3-2c9f48d6a7a0", "1.040", "Impostos e Contribuições com Exigibilidade Suspensa", "A" , "20180101", "" } )
	aAdd( aBody, { "", "f8197e3a-f246-7df3-da7a-ca27a09c924d", "1.041", "Tributo Pago Sobre Lucros Auferidos no Exterior a Compensar (Art. 30, §§ 14 a 19, da IN RFB nº 1.520/2014)", "A" , "20180101", "" } )
	aAdd( aBody, { "", "c84229bc-1da0-3603-3891-76f322465859", "1.042", "Ajuste negativo a valor de mercado (Lei nº 10.637/2002, art. 35)", "A" , "20180101", "" } )
	aAdd( aBody, { "", "27ab2f5f-b482-7c89-53ed-c8aabc716f7d", "1.043", "Ajuste positivo a valor de mercado - alienação dos respectivos ativos (Lei nº 10.637/2002, art.35)", "A" , "20180101", "" } )
	aAdd( aBody, { "", "fa734402-8e90-e983-a2bb-2b465eb004b1", "1.045", "Avaliação a Valor Justo - Ativo ou Passivo da Pessoa Jurídica - Ganho - Sem Subconta", "A" , "20180101", "" } )
	aAdd( aBody, { "", "79e1f2f7-2346-b72b-0e6e-c824b7185194", "1.050", "Avaliação a Valor Justo – Subscrição - Ganho - Sem Subconta", "A" , "20180101", "" } )
	aAdd( aBody, { "", "bba05064-bbee-90eb-ffcf-6b35c412156b", "1.055", "Adoção Inicial dos Arts. 1º a 71 da Lei nº 12.973/2014 – Ativo Diferido - Realização de Diferença Negativa Entre Valores de Ativo Diferido Não Reconhecida Contabilmente na Data da Adoção Inicial", "A" , "20180101", "" } )
	aAdd( aBody, { "", "8d22ae5a-9d33-c033-38bc-6db422d82a65", "1.060", "Despesas Pré-Operacionais", "A" , "20180101", "" } )
	aAdd( aBody, { "", "a84f1f6d-ad56-259e-dbe7-5181c486ad3f", "1.065", "Provisões ou Perdas Estimadas – Teste de Recuperabilidade", "A" , "20180101", "" } )
	aAdd( aBody, { "", "acf4bcfd-cff7-31fe-95e1-6ca7cbff2956", "1.070", "Pagamento Baseado em Ações Apropriado como Despesa ou Custo", "A" , "20180101", "" } )
	aAdd( aBody, { "", "5f684dba-b0bb-23ff-4402-fcb40ce96417", "1.071", "Depreciação - diferença entre as depreciações contábil e fiscal", "A" , "20180101", "" } )
	aAdd( aBody, { "", "ddd0e3c4-9256-f5c2-b38b-972de02a7ca8", "1.075", "Provisões ou Perdas Estimadas – Gastos com Desmontagem", "A" , "20180101", "" } )
	aAdd( aBody, { "", "65aee342-c122-3ccf-1fa3-7fc2dd56b5a2", "1.080", "Contratos de Concessão de Serviços Públicos - Diferença Positiva - Adoção Inicial dos Arts. 1º a 71 da Lei nº 12.973/2014", "A" , "20180101", "" } )
	aAdd( aBody, { "", "7c080450-4f5d-d893-5110-0c7ae00ebbce", "1.085", "Encargos Incidentes Sobre o Débito Vencido e Não Pago Deduzidos Como Despesa ou Custo a Partir da Data da Citação Inicial Para o Pagamento", "A" , "20180101", "" } )
	aAdd( aBody, { "", "52958462-0a6d-ca1b-fff9-f93a06fd8e9e", "1.090", "Resultados Positivos não Realizados nas Operações Intercompanhias", "A" , "20180101", "" } )
	aAdd( aBody, { "", "0761eecc-efa4-8f85-87f4-dd97985c4b9e", "1.095", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Incorporação, Fusão e Cisão – Aquisição em Estágios - Realização, baixa ou liquidação da variação negativa de mais-valia considerada contabilmente no custo do ativo ou no valor do passivo no caso de aquisição de controle", "A" , "20180101", "" } )
	aAdd( aBody, { "", "8f7ce393-12f3-f33f-6529-8baf670823f0", "1.100", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Incorporação, Fusão e Cisão – Aquisição em Estágios - Redução da variação negativa do ágio por rentabilidade futura no caso de aquisição de controle", "A" , "20180101", "" } )
	aAdd( aBody, { "", "57be96de-e739-83da-f392-2b1fb464e643", "1.105", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Incorporação, Fusão e Cisão – Aquisição em Estágios - Realização, baixa ou liquidação da variação positiva de menos-valia considerada contabilmente no custo do ativo ou no valor do passivo no caso de aquisição de controle", "A" , "20180101", "" } )
	aAdd( aBody, { "", "d69cbab3-969f-94fe-582c-fe0125626736", "1.106", "Investimento avaliado pelo valor de patrimônio líquido - incorporação, fusão e cisão - aquisição em estágios - realização, baixa ou liquidação da variação positiva de mais-valia", "A" , "20180101", "" } )
	aAdd( aBody, { "", "a0a9621f-b70d-01cc-3aec-b8cf90b607e6", "1.110", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Incorporação, Fusão e Cisão – Aquisição em Estágios - Realização, baixa ou liquidação da variação negativa de mais-valia considerada contabilmente no custo do ativo ou no valor do passivo", "A" , "20180101", "" } )
	aAdd( aBody, { "", "dd2f98a2-eee3-ec2a-3ffa-c4dab8b8cdfe", "1.115", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Incorporação, Fusão e Cisão – Aquisição em Estágios - Redução da variação negativa do ágio por rentabilidade futura", "A" , "20180101", "" } )
	aAdd( aBody, { "", "d4c2dbce-8324-b6f8-8125-836c7141d54c", "1.120", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Incorporação, Fusão e Cisão – Aquisição em Estágios - Realização, baixa ou liquidação da variação positiva de menos-valia considerada contabilmente no custo do ativo ou no valor do passivo", "A" , "20180101", "" } )
	aAdd( aBody, { "", "9873b6fa-28d0-bfbf-e938-6ab34e45e837", "1.900", "Outras Adições", "A" , "20180101", "" } )
	aAdd( aBody, { "", "43073fb9-23a2-8b77-3f30-55b914469ba9", "1.990", "Valores Excedentes com Programa de Alimentação do Trabalhador e Outros Previstos no RIR (Art. 227, IV, Decreto nº 9.580/2018)", "A" , "20180101", "" } )
	aAdd( aBody, { "", "fa6d56dc-b9f4-e7e1-eae9-275344e38fcf", "1.992", "Valores Excedentes Relativos ao Programa Rota 2030 - Mobilidade e Logística (Art. 11, § 1º, da Lei nº 13.755/2018)", "A" , "20190101", "" } )
	aAdd( aBody, { "", "17e7639a-5344-e9b4-41ca-1940ca037216", "2.005", "Lucros, Rendimentos e Ganhos de Capital Auferidos no Exterior - Investimentos Não Avaliados pela Equivalência Patrimonial que Tenham Sido Excluídos nos Primeiro, Segundo e Terceiro Trimestres", "A" , "20180101", "" } )
	aAdd( aBody, { "", "38ce1c0c-f519-4bc5-70a7-3e002e0694c3", "2.006", "Lucros, rendimentos e ganhos de capital auferidos no exterior - excluídos nos primeiro, segundo e terceiro trimestres", "A" , "20180101", "" } )
	aAdd( aBody, { "", "75bf023d-18e4-b411-22c9-b4c517f1acde", "2.010", "Investimento Avaliado pelo Valor de Patrimônio Líquido - Ganho Proveniente de Compra Vantajosa", "A" , "20180101", "" } )
	aAdd( aBody, { "", "254ec49f-3377-50b8-92a8-e7a929efc3d7", "2.015", "Investimento Avaliado pelo Valor de Patrimônio Líquido - Redução da Menos-Valia", "A" , "20180101", "" } )
	aAdd( aBody, { "", "0a684010-0c5d-865e-d369-79b26fbe8c48", "2.020", "Investimento Avaliado pelo Valor de Patrimônio Líquido - Aquisição em Estágios - Ganho com Base no Valor Justo", "A" , "20180101", "" } )
	aAdd( aBody, { "", "97bd0d51-199f-f0a3-90ae-ef3de4120d7c", "2.025", "Investimento Avaliado pelo Valor de Patrimônio Líquido - Aquisição em Estágios - Ganho Decorrente do Excesso do Valor Justo dos Ativos Líquidos da Investida", "A" , "20180101", "" } )
	aAdd( aBody, { "", "51ef34a4-52cb-0a08-dd1f-8d607da0ab94", "2.030", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Aquisição em Estágios - Redução da Variação Negativa da Mais-Valia", "A" , "20180101", "" } )
	aAdd( aBody, { "", "6b418858-d77c-6c5e-e7de-888163ec133d", "2.035", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Aquisição em Estágios - Redução da Variação Negativa do Goodwill", "A" , "20180101", "" } )
	aAdd( aBody, { "", "58703ded-9d6f-f8ec-3c6f-6fbd5aaaae1d", "2.040", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Aquisição em Estágios - Redução da Variação Positiva da Menos-Valia", "A" , "20180101", "" } )
	aAdd( aBody, { "", "23c72cf6-bf9c-a085-950a-29b87c0cf005", "2.045", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Incorporação, Fusão e Cisão - Realização da Mais-Valia Integrante do Custo do Bem ou Direito que lhe Deu Causa", "A" , "20180101", "" } )
	aAdd( aBody, { "", "c7ef6121-3d3e-de63-88a6-74d36d91bcdb", "2.050", "Realização de Reserva de Reavaliação", "A" , "20180101", "" } )
	aAdd( aBody, { "", "77bc861f-c7ed-5d4f-8559-7482821dc8cb", "2.055", "Prêmios da Emissão de Debêntures", "A" , "20180101", "" } )
	aAdd( aBody, { "", "a0cea065-0464-b66f-3d29-5e95fea3c2d2", "2.060", "Doações e Subvenções para Investimentos", "A" , "20180101", "" } )
	aAdd( aBody, { "", "5f32a492-82ab-ae50-695d-cffb6804b7d9", "2.065", "Doações e Subvenções - Art. 30 da Lei nº 12.350/2010", "A" , "20180101", "" } )
	aAdd( aBody, { "", "7297796b-27bb-a6cb-cfde-0a47141af126", "2.070", "Realização de Receitas Originárias de Planos de Benefícios Administrados por Entidades Fechadas de Previdência Complementar (Lei nº 11.948/2009, art.5º)", "A" , "20180101", "" } )
	aAdd( aBody, { "", "a75704b3-2d93-5c07-6be6-f66ba9a6c7a9", "2.075", "Parcela dos Lucros de Contratos de Construção por Empreitada ou Fornecimento, Celebrados com Pessoa Jurídica de Direito Público", "A" , "20180101", "" } )
	aAdd( aBody, { "", "c87a9f22-ca30-cd25-63d8-f1df31f94487", "2.080", "Aporte do Poder Público", "A" , "20180101", "" } )
	aAdd( aBody, { "", "14b8d6c4-6e24-fd82-7b97-7c84e20f2b33", "2.085", "Incentivo Fiscal - Amortização Acelerada Incentivada - Ativo Intangível Vinculado à Pesquisa Tecnológica e ao Desenvolvimento de Inovação Tecnológica", "A" , "20180101", "" } )
	aAdd( aBody, { "", "8822e24d-0dd3-1ebc-c996-cd92a32b25e7", "2.090", "Incentivo Fiscal - Depreciação Acelerada Incentivada - Inovação Tecnológica", "A" , "20180101", "" } )
	aAdd( aBody, { "", "355a9c15-daa2-4777-b648-830de1ecf2c2", "2.095", "Incentivo Fiscal - Depreciação ou Amortização Acelerada Incentivada - Pesquisa e Desenvolvimento Tecnológico", "A" , "20180101", "" } )
	aAdd( aBody, { "", "a0506568-d224-af28-943e-9228199a91e0", "2.100", "Incentivo Fiscal - Gastos com Desenvolvimento de Inovação Tecnológica", "A" , "20180101", "" } )
	aAdd( aBody, { "", "10ea5e1f-4081-9e41-896c-95e2ba2183d9", "2.105", "Incentivo Fiscal - Microempresa e EPP - Pesquisa e Inovação Tecnológica", "A" , "20180101", "" } )
	aAdd( aBody, { "", "ca4b81f7-3045-45e3-63b5-529df12424d7", "2.110", "Incentivo Fiscal - Depreciação Acelerada Incentivada - SUDENE e SUDAM", "A" , "20180101", "20201231" } )
	aAdd( aBody, { "", "1538d6c5-1a33-55a7-f085-8fd4f60feb9e", "2.110", "Incentivo Fiscal - Depreciação Acelerada Incentivada - SUDENE", "A" , "20180101", "" } )
	aAdd( aBody, { "", "ff8ad277-b423-16af-2f20-a16ecafd6e8d", "2.115", "Incentivo Fiscal - Depreciação Acelerada Incentivada - SUDAM", "A" , "20180101", "" } )
	aAdd( aBody, { "", "d2e4abcb-5fec-816c-34ef-be20fa46de38", "2.130", "Incentivo Fiscal - Depreciação Acelerada Incentivada - Veículos Automóveis para Transporte de Mercadorias e Vagões, Locomotivas, Locotratores e Tênderes", "A" , "20180101", "" } )
	aAdd( aBody, { "", "a969aff0-8848-895e-58f5-5816a6878c4b", "2.135", "Depreciação Acelerada - Máquinas, Equipamentos, Aparelhos e Instrumentos", "A" , "20180101", "" } )
	aAdd( aBody, { "", "ef99282c-40d1-219f-f71b-f14b98de7050", "2.140", "Depreciação/Amortização Acelerada Incentivada - Demais Hipóteses de Reversão", "A" , "20180101", "" } )
	aAdd( aBody, { "", "7d1c0232-7d61-6da9-2076-e14e014bc667", "2.142", "Exaustão Incentivada", "A" , "20180101", "" } )
	aAdd( aBody, { "", "69800c0d-065e-7a0d-b4c0-43ce810e70c6", "2.145", "Perdas Incorridas no Mercado de Renda Variável no Período de Apuração, exceto Day-Trade", "A" , "20180101", "" } )
	aAdd( aBody, { "", "f01b2d05-777d-ad1b-c3b2-946726c3dde7", "2.150", "Juros Produzidos por NTN", "A" , "20180101", "" } )
	aAdd( aBody, { "", "88704f34-b876-901a-5ba5-b40aebc481ce", "2.155", "Juros de Empréstimos - Custos de Empréstimos", "A" , "20180101", "" } )
	aAdd( aBody, { "", "2f2fa747-bce4-8c3b-4838-e7e7e3dfc0d0", "2.156", "Ajuste positivo a valor de mercado (Lei nº 10.637/2002, art. 35)", "A" , "20180101", "" } )
	aAdd( aBody, { "", "0fcf4e2f-25cf-16cf-a668-34065a8dd203", "2.157", "Ajuste negativo a valor de mercado - alienação dos respectivos ativos (Lei nº 10.637/2002, art.35)", "A" , "20180101", "" } )
	aAdd( aBody, { "", "47461a15-3a35-b1f1-a9c3-213a7301b5b3", "2.160", "Avaliação a Valor Justo - Ativo ou Passivo da Pessoa Jurídica - Ganho", "A" , "20180101", "" } )
	aAdd( aBody, { "", "0b69b90c-bd88-275e-8fd9-0c73b0222e4f", "2.165", "Avaliação a Valor Justo – Subscrição - Ganho", "A" , "20180101", "" } )
	aAdd( aBody, { "", "24031f43-7b3c-bc7d-0543-61c9b27f9f3b", "2.170", "Adoção Inicial dos Arts. 1º a 71 da Lei nº 12.973/2014 – Realização de Investimento em Controlada de Diferença Negativa de Reserva de Reavaliação Controlada na Parte B do e-Lalur", "A" , "20180101", "" } )
	aAdd( aBody, { "", "58f5da24-7f9b-a2a2-6935-a9841cca2f6e", "2.175", "Adoção Inicial dos Arts. 1º a 71 da Lei nº 12.973/2014 – Reserva de Reavaliação - Realização de Diferença Negativa de Reserva Constituída na Subscrição Controlada na Parte B do e-Lalur", "A" , "20180101", "" } )
	aAdd( aBody, { "", "74826735-b44d-d34a-67b0-9aa20bc45f86", "2.180", "Adoção Inicial dos Arts. 1º a 71 da Lei nº 12.973/2014 – Reserva de Reavaliação - Realização de Diferença Negativa de Reserva Constituída na Reavaliação Voluntária de Ativos do Próprio Contribuinte Controlada na Parte B do e-Lalur", "A" , "20180101", "" } )
	aAdd( aBody, { "", "134cfa59-62af-a75c-e5da-e522132dbb3e", "2.182", "Adoção inicial dos arts. 1º a 71 da Lei nº 12.973/2014 - ajustes de avaliação patrimonial", "A" , "20180101", "" } )
	aAdd( aBody, { "", "6239282a-b3de-bb6a-7926-8c35494f2c96", "2.190", "Atividade Imobiliária - Permuta - Lucro bruto decorrente da avaliação a valor justo das unidades permutadas", "A" , "20180101", "" } )
	aAdd( aBody, { "", "c48cec17-4c59-fdba-0d7a-f9270fea04ae", "2.195", "Atividade Imobiliária - Diferimento da Tributação", "A" , "20180101", "" } )
	aAdd( aBody, { "", "8f5713d5-db12-52f4-e8d4-a72c5b4ab959", "2.200", "Contratos de Concessão de Serviços Públicos - Realização de Ativo Intangível Representativo do Direito", "A" , "20180101", "" } )
	aAdd( aBody, { "", "48998c9b-d10f-410b-e38f-3235020143f6", "2.205", "Contratos de Concessão de Serviços Públicos - Recebimento de Ativo Financeiro", "A" , "20180101", "" } )
	aAdd( aBody, { "", "5d4c6529-accf-78b0-3a17-42fd537c7e0e", "2.210", "Depreciação - Diferença entre as Depreciações Contábil e Fiscal", "A" , "20180101", "" } )
	aAdd( aBody, { "", "b30f7486-7757-5f5a-df65-3a567b5af73a", "2.215", "Contratos de Concessão de Serviços Públicos - Diferença Negativa - Adoção Inicial dos Arts. 1º a 71 da Lei nº 12.973/2014", "A" , "20180101", "" } )
	aAdd( aBody, { "", "fb2329bc-1167-77e6-2157-bc4306b85bb9", "2.220", "Ganho de Capital - Recebimento após o Término do Período de Apuração da Contratação", "A" , "20180101", "" } )
	aAdd( aBody, { "", "bb249669-1985-088c-a185-f481b295a2e2", "2.225", "Lucros, Rendimentos e Ganhos de Capital Auferidos no Exterior - Excluídos nos Primeiro, Segundo e Terceiro Trimestres", "A" , "20180101", "" } )
	aAdd( aBody, { "", "75aacb6a-b437-b34d-192a-59eb52da61b5", "2.230", "Perdas no Recebimento de Créditos - PJ Credora - Encargos Financeiros Incidentes Sobre o Crédito Vencido e Não Recebido Contabilizado com Receita", "A" , "20180101", "" } )
	aAdd( aBody, { "", "e22e8319-7e52-28c6-df2a-609a52df64f2", "2.250", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Incorporação, Fusão e Cisão – Aquisição em Estágios - Realização, Baixa ou Liquidação da Variação Positiva da Mais-Valia", "A" , "20180101", "" } )
	aAdd( aBody, { "", "95644e2a-7d5f-b3d4-1802-3f49636f5426", "2.255", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Incorporação, Fusão e Cisão – Aquisição em Estágios - Contrapartida da Redução da Variação Positiva do Ágio por Rentabilidade Futura", "A" , "20180101", "" } )
	aAdd( aBody, { "", "c53c80c3-e7ca-407f-96de-a220928d362d", "2.260", "Investimento Avaliado pelo Valor de Patrimônio Líquido – Incorporação, Fusão e Cisão – Aquisição em Estágios - Realização, Baixa ou Liquidação da Variação Negativa da Menos-Valia", "A" , "20180101", "" } )
	aAdd( aBody, { "", "345f882e-2683-828b-c930-c396a8f8a51c", "2.265", "Combinação de Negócios, Exceto Investimento Avaliado pelo Valor de Patrimônio Líquido", "A" , "20180101", "" } )
	aAdd( aBody, { "", "3d29e0af-0f9b-472d-7241-71f86c6607cd", "2.270", "Resultados Negativos não Realizados nas Operações Intercompanhias", "A" , "20180101", "" } )
	aAdd( aBody, { "", "5a77e729-d0e4-26f2-c889-6e1fdd2f6ed5", "2.275", "Incentivo Fiscal - Depreciação Acelerada - Atividade Rural", "A" , "20180101", "" } )
	aAdd( aBody, { "", "296672ac-e18f-e3a8-b808-eda72e8d7215", "2.280", "Perdas dedutíveis em operações de crédito - Lei 9.430/96 – Art.9º, §1º, inciso I e §7º, inciso I - empréstimos", "A" , "20180101", "" } )
	aAdd( aBody, { "", "e67ec1bd-a1a1-1477-f7c5-c6ca0ce7cdf5", "2.285", "Perdas dedutíveis em operações de crédito - Lei 9.430/96", "A" , "20180101", "" } )
	aAdd( aBody, { "", "e8774808-3e53-b885-eb38-9f08397e5c1a", "2.900", "Outras Exclusões", "A" , "20180101", "" } )
	aAdd( aBody, { "", "8c720128-da63-a1d6-0ba8-713bbeed8a2e", "3.005", "Variação Cambial - Ajuste a Valor Presente", "A" , "20180101", "" } )
	aAdd( aBody, { "", "5524c033-8e67-7cce-8be3-bcc72315315b", "3.010", "Variação Cambial - Ajuste a Valor Presente", "A" , "20180101", "" } )
	aAdd( aBody, { "", "5bc2dc87-ec80-2b2a-0509-310c8a5da97d", "3.015", "Investimento Avaliado pelo Valor de Patrimônio Líquido - Redução do Goodwill", "A" , "20180101", "" } )
	aAdd( aBody, { "", "b61d7fb7-b880-2743-96b9-ac0969d4fc2f", "3.020", "Arrendamento Mercantil - PJ Arrendatária", "A" , "20180101", "" } )
	aAdd( aBody, { "", "bda6a435-4a73-990e-9099-81a93b21cab4", "3.025", "Arrendamento Mercantil - PJ Arrendatária - Contrato Não Tipificado Como Arrendamento Mercantil Financeiro", "A" , "20180101", "" } )
	aAdd( aBody, { "", "c9925b38-79e2-f5da-c86f-e8a6320eb704", "3.026", "Arrendamento Mencantil - PJ Arrendadora", "A" , "20180101", "" } )
	aAdd( aBody, { "", "557c25eb-2f89-6fe2-4536-328a38db6cee", "3.030", "Arrendamento Mercantil - PJ  Arrendadora - Não disciplinado pela Lei nº 6.099/74", "A" , "20180101", "" } )
	aAdd( aBody, { "", "b218f6c2-edb1-5d2b-63c4-24428aa28b0a", "3.035", "Arrendamento Mercantil - PJ Arrendadora - Contrato Não Tipificado Como Arrendamento Mercantil Financeiro", "A" , "20180101", "" } )
	aAdd( aBody, { "", "a3f9c876-5177-932c-778d-ceb948b3ff59", "3.040", "Ajuste a Valor Presente de Elementos do Ativo - Venda", "A" , "20180101", "" } )
	aAdd( aBody, { "", "7ea3eb45-55b8-2209-73c2-53c54eb89af1", "3.045", "Ajuste a Valor Presente de Elementos do Ativo - Demais Operações", "A" , "20180101", "" } )
	aAdd( aBody, { "", "df350d9f-2379-45da-5626-dc7d376ad3f0", "3.050", "Ajuste a Valor Presente de Passivo - Incisos IV e V do art. 5º da Lei nº 12.973/2014", "A" , "20180101", "" } )
	aAdd( aBody, { "", "c69cfcba-6512-9762-12c1-96b0e0fe3835", "3.055", "Ajuste a Valor Presente de Passivo - Outras operações que não sejm aquisição a prazo - Relacionado a uma despesa ou custo", "A" , "20180101", "" } )
	aAdd( aBody, { "", "b9aabb08-ab41-efd3-e39c-57f49ed2bd67", "3.060", "Contratos de Longo Prazo - Divergência de Critério - Ajuste da diferença dos critérios adotados no § 1º do art. 10 do Decreto-Lei nº 1.598, de 1977 em contratos de longo prazo", "A" , "20180101", "" } )
	aAdd( aBody, { "", "0598b263-02b8-e211-bb84-25ce7e2f221c", "3.065", "Contratos de Concessão de Serviços Públicos - Apropriação de Receitas Financeiras Decorrentes de Ajuste a Valor Presente do Ativo Financeiro", "A" , "20180101", "" } )
	aAdd( aBody, { "", "4bb40853-1313-5c7f-deb9-545907cd99ae", "3.070", "Operações Realizadas em Mercados de Liquidação Futura", "A" , "20180101", "" } )
	aAdd( aBody, { "", "1cee084e-7425-c1b4-eab7-7b5a2cb3ebbd", "3.075", "Ajustes de Exercícios Anteriores - Lançamentos Extemporâneos", "A" , "20180101", "" } )
	aAdd( aBody, { "", "6c28200f-a0e4-dc72-9270-7092e237bdb0", "3.080", "CPC 47 - Ajustes de Receita Bruta", "A" , "20180101", "" } )
	aAdd( aBody, { "", "4097a794-aad2-cd0f-0ff4-c8f4f3b71806", "3.085", "CPC 47 - Ajustes de Custos / Despesas", "A" , "20180101", "" } )
	aAdd( aBody, { "", "3b5be0cc-1d42-5bba-82c5-d99c2b10f55b", "3.090", "CPC 47 - Ajustes de Outras Receitas / Outros Resultados", "A" , "20180101", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
