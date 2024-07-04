#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA310.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA310
Cadastro MVC de Receitas e Deduções

@author Fabio V Santana
@since 07/03/2013
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA310()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Receitas e Deduções"
oBrw:SetAlias( 'CUZ')
oBrw:SetMenuDef( 'TAFA310' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V Santana
@since 07/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA310" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V Santana
@since 07/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCUZ 	:= 	FWFormStruct( 1, 'CUZ' )
Local oModel 	:= 	MPFormModel():New( 'TAFA310' )

oModel:AddFields('MODEL_CUZ', /*cOwner*/, oStruCUZ)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V Santana
@since 07/03/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA310' )
Local 	oStruCUZ 	:= 	FWFormStruct( 2, 'CUZ' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CUZ', oStruCUZ, 'MODEL_CUZ' )

oView:EnableTitleView( 'VIEW_CUZ', STR0001 )	//"Cadastro das Receitas e Deduções
oView:CreateHorizontalBox( 'FIELDSCUZ', 100 )
oView:SetOwnerView( 'VIEW_CUZ', 'FIELDSCUZ' )

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

nVerAtu := 1032.00

If nVerEmp < nVerAtu
	aAdd( aHeader, "CUZ_FILIAL" )
	aAdd( aHeader, "CUZ_ID" )
	aAdd( aHeader, "CUZ_CODIGO" )
	aAdd( aHeader, "CUZ_DESCRI" )
	aAdd( aHeader, "CUZ_DTINI" )
	aAdd( aHeader, "CUZ_DTFIN" )
	aAdd( aHeader, "CUZ_INDATV" )
	aAdd( aHeader, "CUZ_INDAJU" )
	aAdd( aHeader, "CUZ_CODGRU" )
	aAdd( aHeader, "CUZ_INDOUT" )
	aAdd( aHeader, "CUZ_GERAL" )
   
	aAdd( aBody, { "", "000001", "D0001", "Reversoes de provisoes", "20130101", "", "01;02;", "P", "0", "N", "G" } )
	aAdd( aBody, { "", "000002", "D0002", "Recuperacoes de creditos baixados como perda, limitados aos valores efetivamente baixados, que nao representem ingresso de novas receitas", "20130101", "", "01;02;", "P", "0", "N", "G" } )
	aAdd( aBody, { "", "000003", "D0003", "Resultado positivo da avaliacao de investimentos pelo valor do patrimonio liquido", "20130101", "", "01;02;", "P", "0", "N", "G" } )
	aAdd( aBody, { "", "000004", "D0004", "Lucros e dividendos derivados de investimentos avaliados pelo custo de aquisicao, que tenham sido computados como receita", "20130101", "", "01;02;", "P", "0", "N", "G" } )
	aAdd( aBody, { "", "000005", "D0005", "Receita decorrente da venda de bens do ativo permanente", "20130101", "", "01;02;", "P", "0", "N", "G" } )
	aAdd( aBody, { "", "000006", "D0006", "Vendas canceladas, os descontos incondicionais concedidos, e o IPI e ICMS quando cobrado pelo vendedor dos bens ou prestador dos servicos na condicao de substituto tributario", "20140101", "", "01;02;", "P", "0", "N", "G" } )
	aAdd( aBody, { "", "000007", "D0090", "Outras deducoes e exclusoes de carater geral", "20130101", "", "01;02;", "P", "0", "S", "G" } )
	aAdd( aBody, { "", "000008", "D0101", "Despesas incorridas nas operacoes de intermediacao financeira", "20130101", "", "01;06", "P", "100", "N", "E" } )
	aAdd( aBody, { "", "000009", "D0102", "Encargos com obrigacoes por refinanciamentos, emprestimos e repasses de recursos de orgaos e instituicoes oficiais ou de direito privado", "20130101", "", "01;06", "P", "100", "N", "E" } )
	aAdd( aBody, { "", "000010", "D0103", "Despesas de cambio", "20130101", "", "01;06", "P", "100", "N", "E" } )
	aAdd( aBody, { "", "000011", "D0104", "Despesas de arrendamento mercantil, restritas a empresas e instituicoes arrendadoras", "20130101", "", "01;06", "P", "100", "N", "E" } )
	aAdd( aBody, { "", "000012", "D0105", "Despesas de operacoes especiais por conta e ordem do Tesouro Nacional", "20130101", "", "01;06", "P", "100", "N", "E" } )
	aAdd( aBody, { "", "000013", "D0106", "Desagio na colocacao de titulos", "20130101", "", "01;06", "P", "100", "N", "E" } )
	aAdd( aBody, { "", "000014", "D0107", "Perdas com titulos de renda fixa e variavel, exceto com acoes", "20130101", "", "01;06", "P", "100", "N", "E" } )
	aAdd( aBody, { "", "000015", "D0108", "Perdas com ativos financeiros e mercadorias, em operacoes de hedge", "20130101", "", "01;06", "P", "100", "N", "E" } )
	aAdd( aBody, { "", "000016", "D0109", "Despesas de captacao em operacoes realizadas no mercado interfinanceiro, inclusive com titulos publicos", "20130101", "", "01;06", "P", "100", "N", "E" } )
	aAdd( aBody, { "", "000017", "D0110", "Valor auferido em cada periodo de apuracao como remuneracao pelos servicos de arrecadacao de receitas federais, dividido por 0,04 (quatro centesimos). (deducao especifica na base de calculo da Cofis)", "20140101", "", "01;06", "P", "100", "N", "E" } )
	aAdd( aBody, { "", "000018", "D0190", "Outras deducoes e exclusoes de carater especifico", "20130101", "", "01;06", "P", "100", "S", "E" } )
	aAdd( aBody, { "", "000019", "D0198", "Ajustes Negativos das deducoes e exclusoes de carater especifico", "20130101", "", "01;06", "N", "100", "N", "E" } )
	aAdd( aBody, { "", "000020", "D0199", "Ajustes Positivos das deducoes e exclusoes de carater especifico", "20130101", "", "01;06", "P", "100", "N", "E" } )
	aAdd( aBody, { "", "000021", "D0201", "Cosseguro e resseguro cedidos", "20130101", "20131231", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000022", "D0201", "Premios Cancelados e Restituidos", "20140101", "", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000023", "D0202", "Cancelamentos e restituicoes de premios que houverem sido computados como receitas", "20130101", "20131231", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000024", "D0202", "Cancelamentos e Restituicoes de Cosseguro Aceito", "20140101", "", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000025", "D0203", "Parcela dos premios destinada a constituicao de provisoes ou reservas tecnicas", "20130101", "20131231", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000026", "D0203", "Cosseguro Cedido", "20140101", "", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000027", "D0204", "Parcela dos premios destinada a constituicao de provisoes ou reservas tecnicasIndenizacoes correspondentes aos sinistros ocorridos, efetivamente pagos, deduzidos das importancias recebidas a titulo de cosseguros e resseg", "20130101", "20131231", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000028", "D0204", "Parcela dos premios destinada a constituicao de provisoes ou reservas tecnicas", "20140101", "", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000029", "D0205", "Indenizacoes correspondentes aos sinistros ocorridos, efetivamente pagos, deduzidos das importancias recebidas a titulo de cosseguros e resseguros, salvados e outros ressarcimentos", "20140101", "", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000030", "D0206", "Premios de Resseguros", "20140101", "", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000031", "D0207", "Premios de Retrocessoes Cedidas", "20140101", "", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000032", "D0208", "Cancelamento e/ou Restituicoes de Premios de Resseguro", "20140101", "", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000033", "D0209", "Variacao das Provisoes Tecnicas de Retrocessao", "20140101", "", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000034", "D0210", "Indenizacoes (correspondentes aos sinistros ocorridos, efetivamente pagos)", "20140101", "", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000035", "D0290", "Outras deducoes e exclusoes de carater especifico", "20130101", "", "02;06", "P", "200", "S", "E" } )
	aAdd( aBody, { "", "000036", "D0298", "Ajustes Negativos das deducoes e exclusoes de carater especifico", "20130101", "", "02;06", "N", "200", "N", "E" } )
	aAdd( aBody, { "", "000037", "D0299", "Ajustes Positivos das deducoes e exclusoes de carater especifico", "20130101", "", "02;06", "P", "200", "N", "E" } )
	aAdd( aBody, { "", "000038", "D0301", "Parcela das contribuicoes destinada a constituicao de provisoes ou reservas tecnicas", "20130101", "", "03;06", "P", "300", "N", "E" } )
	aAdd( aBody, { "", "000039", "D0302", "Rendimentos auferidos nas aplicacoes financeiras de recursos destinados ao pagamento de beneficios de aposentadoria, pensao, peculio e de resgates", "20130101", "20131231", "03;06", "P", "300", "N", "E" } )
	aAdd( aBody, { "", "000040", "D0302", "Rendimentos auferidos nas aplicacoes financeiras destinadas ao pagamento de beneficios de aposentadoria, pensao, peculio e de resgates", "20140101", "", "03;06", "P", "300", "N", "E" } )
	aAdd( aBody, { "", "000041", "D0303", "Rendimentos dos ativos financeiros garantidores das provisoes tecnicas de empresas de seguros privados destinadas exclusivamente a planos de beneficios de carater previdenciario e a seguros de vida com clausula de cobert", "20130101", "", "03;06", "P", "300", "N", "E" } )
	aAdd( aBody, { "", "000042", "D0390", "Outras deducoes e exclusoes de carater especifico", "20130101", "", "03;06", "P", "300", "S", "E" } )
	aAdd( aBody, { "", "000043", "D0398", "Ajustes Negativos das deducoes e exclusoes de carater especifico", "20130101", "", "03;06", "N", "300", "N", "E" } )
	aAdd( aBody, { "", "000044", "D0399", "Ajustes Positivos das deducoes e exclusoes de carater especifico", "20130101", "", "03;06", "P", "300", "N", "E" } )
	aAdd( aBody, { "", "000045", "D0401", "Parcela dos premios destinada a constituicao de provisoes ou reservas tecnicas", "20130101", "", "04;06", "P", "400", "N", "E" } )
	aAdd( aBody, { "", "000046", "D0402", "Rendimentos auferidos nas aplicacoes financeiras destinadas ao pagamento de resgate de titulos", "20130101", "", "04;06", "P", "400", "N", "E" } )
	aAdd( aBody, { "", "000047", "D0490", "Outras deducoes e exclusoes de carater especifico", "20130101", "", "04;06", "P", "400", "S", "E" } )
	aAdd( aBody, { "", "000048", "D0498", "Ajustes Negativos das deducoes e exclusoes de carater especifico", "20130101", "", "04;06", "N", "400", "N", "E" } )
	aAdd( aBody, { "", "000049", "D0499", "Ajustes Positivos das deducoes e exclusoes de carater especifico", "20130101", "", "04;06", "P", "400", "N", "E" } )
	aAdd( aBody, { "", "000050", "D0501", "Rendimentos relativos a receitas de aluguel, destinados ao pagamento de beneficios de aposentadoria, pensao, peculio e resgates", "20130101", "", "03;06", "P", "500", "N", "E" } )
	aAdd( aBody, { "", "000051", "D0502", "Receita decorrente da venda de bens imoveis, destinada ao pagamento de beneficios de aposentadoria, pensao, peculio e resgates", "20130101", "", "03;06", "P", "500", "N", "E" } )
	aAdd( aBody, { "", "000052", "D0503", "Resultado positivo, auferido na reavaliacao da carteira de investimentos imobiliarios referida nos codigos 501 e 502", "20130101", "", "03;06", "P", "500", "N", "E" } )
	aAdd( aBody, { "", "000053", "D0590", "Outras deducoes e exclusoes de carater especifico", "20130101", "", "03;06", "P", "500", "S", "E" } )
	aAdd( aBody, { "", "000054", "D0598", "Ajustes Negativos das deducoes e exclusoes de carater especifico", "20130101", "", "03;06", "N", "500", "N", "E" } )
	aAdd( aBody, { "", "000055", "D0599", "Ajustes Positivos das deducoes e exclusoes de carater especifico", "20130101", "", "03;06", "P", "500", "N", "E" } )
	aAdd( aBody, { "", "000056", "D0601", "Co-responsabilidades cedidas", "20130101", "", "05;06", "P", "600", "N", "E" } )
	aAdd( aBody, { "", "000057", "D0602", "Parcela das contraprestacoes pecuniarias destinada a constituicao de provisoes tecnicas", "20130101", "", "05;06", "P", "600", "N", "E" } )
	aAdd( aBody, { "", "000058", "D0603", "Valor referente as indenizacoes correspondentes aos eventos ocorridos, efetivamente pago, deduzido das importancias recebidas a titulo de transferencia de responsabilidades", "20130101", "", "05;06", "P", "600", "N", "E" } )
	aAdd( aBody, { "", "000059", "D0690", "Outras deducoes e exclusoes de carater especifico", "20130101", "", "05;06", "P", "600", "S", "E" } )
	aAdd( aBody, { "", "000060", "D0698", "Ajustes Negativos das deducoes e exclusoes de carater especifico", "20130101", "", "05;06", "N", "600", "N", "E" } )
	aAdd( aBody, { "", "000061", "D0699", "Ajustes Positivos das deducoes e exclusoes de carater especifico", "20130101", "", "05;06", "P", "600", "N", "E" } )
	aAdd( aBody, { "", "000062", "D0701", "Despesas incorridas nas operacoes de intermediacao financeira", "20130101", "20140101", "01;06", "P", "700", "N", "E" } )
	aAdd( aBody, { "", "000063", "D0702", "Encargos com obrigacoes por refinanciamentos, emprestimos e repasses de recursos de orgaos e instituicoes oficiais ou de direito privado", "20130101", "20140101", "01;06", "P", "700", "N", "E" } )
	aAdd( aBody, { "", "000064", "D0703", "Perdas com titulos de renda fixa e variavel, exceto com acoes", "20130101", "20140101", "01;06", "P", "700", "N", "E" } )
	aAdd( aBody, { "", "000065", "D0704", "Perdas com ativos financeiros e mercadorias em operacoes de hedge", "20130101", "20140101", "01;06", "P", "700", "N", "E" } )
	aAdd( aBody, { "", "000066", "D0705", "Ingressos decorrentes de ato cooperativo: Receitas de juros e encargos recebidas diretamente dos associados", "20130101", "", "01;06", "P", "700", "N", "E" } )
	aAdd( aBody, { "", "000067", "D0706", "Ingressos decorrentes de ato cooperativo: Receitas da prestacao de servicos realizados aos associados e recebidas diretamente dos mesmos", "20130101", "20140101", "01;06", "P", "700", "N", "E" } )
	aAdd( aBody, { "", "000068", "D0707", "Ingressos decorrentes de ato cooperativo: Receitas financeiras recebidas de aplicacoes efetuadas em confederacao, federacao e cooperativa singular de que seja associada", "20130101", "20140101", "01;06", "P", "700", "N", "E" } )
	aAdd( aBody, { "", "000069", "D0708", "Ingressos decorrentes de ato cooperativo: Valores arrecadados com a venda de bens moveis e imoveis recebidos de associados para pagamento de emprestimo contraido junto a cooperativa", "20130101", "20140101", "01;06", "P", "700", "N", "E" } )
	aAdd( aBody, { "", "000070", "D0709", "Ingressos decorrentes de ato cooperativo: Valores recebidos de orgaos publicos ou de seguradoras para a liquidacao parcial ou total de emprestimos contraidos por associados, em decorrencia de perda de producao agropecuar", "20130101", "20140101", "01;06", "P", "700", "N", "E" } )
	aAdd( aBody, { "", "000071", "D0710", "Sobras liquidas apuradas na Demonstracao do Resultado do Exercicio, antes da destinacao para a constituicao do Fundo de Reserva e do Fundo de Assistencia Tecnica, Educacional e Social (Fates), previstos no art. 28 da Lei", "20130101", "", "01;06", "P", "700", "N", "E" } )
	aAdd( aBody, { "", "000072", "D0790", "Outras deducoes e exclusoes de carater especifico", "20130101", "", "01;06", "P", "700", "S", "E" } )
	aAdd( aBody, { "", "000073", "D0798", "Ajustes Negativos das deducoes e exclusoes de carater especifico", "20140101", "", "01;06", "N", "700", "N", "E" } )
	aAdd( aBody, { "", "000074", "D0799", "Ajustes Positivos das deducoes e exclusoes de carater especifico", "20140101", "", "01;06", "P", "700", "N", "E" } )
	aAdd( aBody, { "", "000075", "D0801", "Despesas de Captacao de recursos para a Securitizacao de Creditos Imobiliarios", "20140101", "", "02;06", "P", "800", "N", "E" } )
	aAdd( aBody, { "", "000076", "D0802", "Despesas de Captacao de recursos para a Securitizacao de Creditos Financeiros", "20140101", "", "02;06", "P", "800", "N", "E" } )
	aAdd( aBody, { "", "000077", "D0803", "Despesas de Captacao de recursos para a Securitizacao de Creditos Agricolas", "20140101", "", "02;06", "P", "800", "N", "E" } )
	aAdd( aBody, { "", "000078", "D0898", "Ajustes Negativos das deducoes e exclusoes de carater especifico", "20140101", "", "02;06", "N", "800", "N", "E" } )
	aAdd( aBody, { "", "000079", "D0899", "Ajustes Positivos das deducoes e exclusoes de carater especifico", "20140101", "", "02;06", "P", "800", "N", "E" } )
	aAdd( aBody, { "", "000080", "R0711", "Rendas de Operacoes de Credito", "20130101", "20140101", "01;06", "P", "700", "N", "" } )
	aAdd( aBody, { "", "000081", "R0712", "Rendas de Arrendamento Mercantil", "20130101", "20140101", "01;06", "P", "700", "N", "" } )
	aAdd( aBody, { "", "000082", "R0713", "Rendas de Cambio", "20130101", "20140101", "01;06", "P", "700", "N", "" } )
	aAdd( aBody, { "", "000083", "R0714", "Rendas de Aplicacoes Interfinanceiras de Liquidez", "20130101", "20140101", "01;06", "P", "700", "N", "" } )
	aAdd( aBody, { "", "000084", "R0715", "Rendas com Titulos e Valores Mobiliarios e Instrumentos Financeiros Derivativos", "20130101", "20140101", "01;06", "P", "700", "N", "" } )
	aAdd( aBody, { "", "000085", "R0717", "Rendas de Prestacao de Servicos", "20130101", "20140101", "01;06", "P", "700", "N", "" } )
	aAdd( aBody, { "", "000086", "R0718", "Rendas de Participacoes", "20130101", "20140101", "01;06", "P", "700", "N", "" } )
	aAdd( aBody, { "", "000087", "R0719", "Outras Receitas Operacionais", "20130101", "20140101", "01;06", "P", "700", "S", "" } )
	aAdd( aBody, { "", "000088", "R0731", "Lucros em Transacoes com Valores e Bens", "20130101", "20140101", "01;06", "P", "700", "N", "" } )
	aAdd( aBody, { "", "000089", "R0739", "Outras Receitas Nao Operacionais", "20130101", "20140101", "01;06", "P", "700", "S", "" } )
	aAdd( aBody, { "", "000090", "R0751", "Receitas de Variacoes Cambiais", "20130101", "20140101", "01;06", "P", "700", "N", "" } )
	aAdd( aBody, { "", "000091", "R0752", "Receitas de MTM", "20130101", "20140101", "01;06", "P", "700", "N", "" } )
	aAdd( aBody, { "", "000092", "R0759", "Outras Receitas Liquidadas no Mes", "20130101", "20140101", "01;06", "P", "700", "S", "" } )
	aAdd( aBody, { "", "000093", "R0798", "Ajustes Negativos de Receitas", "20130101", "20140101", "01;06", "N", "700", "N", "" } )
	aAdd( aBody, { "", "000094", "R0799", "Ajustes Positivos de Receitas", "20130101", "20140101", "01;06", "P", "700", "N", "" } )
	aAdd( aBody, { "", "000095", "R0111", "Rendas de Operacoes de Credito", "20140101", "", "01;06", "P", "100", "N", "" } )
	aAdd( aBody, { "", "000096", "R0112", "Rendas de Arrendamento Mercantil", "20140101", "", "01;06", "P", "100", "N", "" } )
	aAdd( aBody, { "", "000097", "R0113", "Rendas de Cambio", "20140101", "", "01;06", "P", "100", "N", "" } )
	aAdd( aBody, { "", "000098", "R0114", "Rendas de Aplicacoes Interfinanceiras de Liquidez", "20140101", "", "01;06", "P", "100", "N", "" } )
	aAdd( aBody, { "", "000099", "R0115", "Rendas com Titulos e Valores Mobiliarios e Instrumentos Financeiros Derivativos", "20140101", "", "01;06", "P", "100", "N", "" } )
	aAdd( aBody, { "", "000100", "R0117", "Rendas de Prestacao de Servicos", "20140101", "", "01;06", "P", "100", "N", "" } )
	aAdd( aBody, { "", "000101", "R0118", "Rendas de Participacoes", "20140101", "", "01;06", "P", "100", "N", "" } )
	aAdd( aBody, { "", "000102", "R0119", "Outras Receitas Operacionais", "20140101", "", "01;06", "P", "100", "S", "" } )
	aAdd( aBody, { "", "000103", "R0131", "Lucros em Transacoes com Valores e Bens", "20140101", "", "01;06", "P", "100", "N", "" } )
	aAdd( aBody, { "", "000104", "R0139", "Outras Receitas Nao Operacionais", "20140101", "", "01;06", "P", "100", "S", "" } )
	aAdd( aBody, { "", "000105", "R0151", "Receitas de Variacoes Cambiais", "20140101", "", "01;06", "P", "100", "N", "" } )
	aAdd( aBody, { "", "000106", "R0152", "Receitas de MTM", "20140101", "", "01;06", "P", "100", "N", "" } )
	aAdd( aBody, { "", "000107", "R0159", "Outras Receitas Liquidadas no Mes", "20140101", "", "01;06", "P", "100", "S", "" } )
	aAdd( aBody, { "", "000108", "R0198", "Ajustes Negativos de Receitas", "20140101", "", "01;06", "N", "100", "N", "" } )
	aAdd( aBody, { "", "000109", "R0199", "Ajustes Positivos de Receitas", "20140101", "", "01;06", "P", "100", "N", "" } )
	aAdd( aBody, { "", "000110", "R0201", "Receitas de Comissoes", "20130101", "", "02;06", "P", "200", "N", "" } )
	aAdd( aBody, { "", "000111", "R0202", "Outras Receitas da Venda de Bens e Servicos", "20130101", "", "02;06", "P", "200", "S", "" } )
	aAdd( aBody, { "", "000112", "R0298", "Ajustes Negativos de Receitas", "20130101", "", "02;06", "N", "200", "N", "" } )
	aAdd( aBody, { "", "000113", "R0299", "Ajustes Positivos de Receitas", "20130101", "", "02;06", "P", "200", "N", "" } )

	aAdd( aBody, { "", "000114", "R0301", "Premios de Seguros Diretos e de Resseguros Retidos", "20130101", "20131231", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000115", "R0301", "Premios de Seguros Diretos", "20140101", "", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000116", "R0302", "Premios de Cosseguros Aceitos e Retrocessoes", "20130101", "", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000117", "R0303", "Premios Ganhos", "20130101", "20131231", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000118", "R0303", "Variacoes das Provisoes Tecnicas . Reversao", "20140101", "", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000119", "R0304", "Recuperacao de Sinistros", "20130101", "20140101", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000120", "R0305", "Variacao da Provisao de Sinistros e Eventos Ocorridos mas nao Avisados", "20130101", "20140101", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000121", "R0306", "Outras Receitas de Seguros", "20130101", "", "02;03;", "P", "300", "S", "" } )
	aAdd( aBody, { "", "000122", "R0321", "Premio de Resseguros", "20140101", "", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000123", "R0322", "Premio de Retrocessao Aceita", "20140101", "", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000124", "R0323", "Variacao da Provisao Tecnicas de Resseguro", "20140101", "", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000125", "R0324", "Outras Receitas da Resseguros", "20140101", "", "02;03;", "P", "300", "S", "" } )
	aAdd( aBody, { "", "000126", "R0325", "Outros Ajustes Positivos de carater especifico", "20140101", "", "02;03;", "P", "300", "S", "" } )
	aAdd( aBody, { "", "000127", "R0331", "Receita Liquida com Titulos de Capitalizacao", "20130101", "", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000128", "R0332", "Variacoes das Provisoes Tecnicas", "20130101", "20131231", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000129", "R0332", "Variacoes das Provisoes Tecnicas - Reversao", "20140101", "", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000130", "R0333", "Outras receitas de Capitalizacao", "20130101", "", "02;03;", "P", "300", "S", "" } )
	aAdd( aBody, { "", "000131", "R0361", "Rendas de Contribuicoes Retidas", "20130101", "20131231", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000132", "R0361", "Rendas de Contribuicoes", "20140101", "", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000133", "R0362", "Variacoes das Provisoes Tecnicas", "20130101", "20131231", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000134", "R0362", "Variacoes das Provisoes Tecnicas . Reversao", "20140101", "", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000135", "R0363", "Outras Receitas de Previdencia", "20130101", "", "02;03;", "P", "300", "S", "" } )
	aAdd( aBody, { "", "000136", "R0364", "Rendas com Taxa de Gestao e Outras Taxas", "20130101", "", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000137", "R0395", "Receitas Financeiras", "20140101", "", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000138", "R0396", "Receitas Patrimoniais", "20140101", "", "02;03;", "P", "300", "N", "" } )
	aAdd( aBody, { "", "000139", "R0397", "Outras Receitas Nao Operacionais", "20140101", "", "02;03;", "P", "300", "S", "" } )
	aAdd( aBody, { "", "000140", "R0398", "Ajustes Negativos de Receitas", "20130101", "", "02;03;", "N", "300", "N", "" } )
	aAdd( aBody, { "", "000141", "R0399", "Ajustes Positivos de Receitas", "20130101", "", "02;03;", "P", "300", "N", "" } )

	aAdd( aBody, { "", "000142", "R0401", "Recursos Coletados Previdenciais", "20130101", "20140101", "03;06", "P", "400", "N", "" } )
	aAdd( aBody, { "", "000143", "R0402", "Recursos Coletados Assistenciais", "20130101", "20140101", "03;06", "P", "400", "N", "" } )
	aAdd( aBody, { "", "000144", "R0403", "Receitas Administrativas", "20130101", "", "03;06", "P", "400", "N", "" } )
	aAdd( aBody, { "", "000145", "R0404", "Rendas de Investimento (Bruta)", "20130101", "20140101", "03;06", "P", "400", "N", "" } )
	aAdd( aBody, { "", "000146", "R0405", "Outras Receitas Auferidas no Periodo", "20130101", "", "03;06", "P", "400", "S", "" } )
	aAdd( aBody, { "", "000147", "R0406", "Adicoes da Gestao Previdencial", "20130101", "", "03;06", "P", "400", "N", "" } )
	aAdd( aBody, { "", "000148", "R0407", "Rendas de Investimento da Gestao Administrativas", "20130101", "", "03;06", "P", "400", "N", "" } )
	aAdd( aBody, { "", "000149", "R0408", "Rendas de Investimento da Gestao Previdencial", "20130101", "", "03;06", "P", "400", "N", "" } )
	aAdd( aBody, { "", "000150", "R0498", "Ajustes Negativos de Receitas", "20130101", "", "03;06", "N", "400", "N", "" } )
	aAdd( aBody, { "", "000151", "R0499", "Ajustes Positivos de Receitas", "20130101", "", "03;06", "P", "400", "N", "" } )
	aAdd( aBody, { "", "000152", "R0501", "Contraprestacoes Liquidas / Premios Retidos (311)", "20130101", "20131231", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000153", "R0501", "Contraprestacoes Liquidas / Premios Retidos", "20140101", "", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000154", "R0502", "Variacao das Provisoes Tecnicas de Operacoes de Assistencia a Saude (312)", "20130101", "20131231", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000155", "R0502", "Variacao das Provisoes Tecnicas de Operacoes de Assistencia a Saude . Reversao", "20140101", "", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000156", "R0503", "Receitas com Administracao de Planos de Assistencia a Saude (313)", "20130101", "20131231", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000157", "R0503", "Receitas com Administracao de Planos de Assistencia a Saude", "20140101", "", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000158", "R0504", "Receitas Com o SUS (332)", "20130101", "20140101", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000159", "R0505", "Outras Receitas Operacionais de Assistencia a Saude nao Relacionadas com Planos de Saude da Operadora (333)", "20130101", "20131231", "05;06", "P", "500", "S", "" } )
	aAdd( aBody, { "", "000160", "R0505", "Receitas com Resseguro", "20140101", "", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000161", "R0506", "Receitas Operacionais - Outras (334)", "20130101", "20131231", "05;06", "P", "500", "S", "" } )
	aAdd( aBody, { "", "000162", "R0506", "Receitas Financeiras", "20140101", "", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000163", "R0507", "Receitas de Aplicacoes Financeiras (341)", "20130101", "20131231", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000164", "R0507", "Receitas Patrimoniais", "20140101", "", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000165", "R0508", "Receitas Financeiras com Operacoes de Assistencia a Saude (342)", "20130101", "20131231", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000166", "R0508", "Outras Receitas Nao Operacionais", "20140101", "", "05;06", "P", "500", "S", "" } )
	aAdd( aBody, { "", "000167", "R0509", "Receitas de Ajustes a Valor Presente (343)", "20130101", "20140101", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000168", "R0510", "Outras Receitas Financeiras (348)", "20130101", "20140101", "05;06", "P", "500", "S", "" } )
	aAdd( aBody, { "", "000169", "R0511", "Receitas Patrimoniais (351)", "20130101", "20140101", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000170", "R0512", "Outras Receitas Operacionais de Planos de Assistencia a Saude (331)", "20130101", "20131231", "05;06", "P", "500", "S", "" } )
	aAdd( aBody, { "", "000171", "R0512", "Outras Receitas Operacionais de Planos de Assistencia a Saude", "20140101", "", "05;06", "P", "500", "S", "" } )
	aAdd( aBody, { "", "000172", "R0598", "Ajustes Negativos de Receitas", "20130101", "", "05;06", "N", "500", "N", "" } )
	aAdd( aBody, { "", "000173", "R0599", "Ajustes Positivos de Receitas", "20130101", "", "05;06", "P", "500", "N", "" } )
	aAdd( aBody, { "", "000174", "R0601", "Receita da Securitizacao de Creditos Imobiliarios", "20140101", "", "05;06", "P", "600", "N", "" } )
	aAdd( aBody, { "", "000175", "R0602", "Receita da Securitizacao de Creditos Financeiros", "20140101", "", "05;06", "P", "600", "N", "" } )
	aAdd( aBody, { "", "000176", "R0603", "Receita da Securitizacao de Creditos Agricolas", "20140101", "", "05;06", "P", "600", "N", "" } )
	aAdd( aBody, { "", "000177", "R0604", "Outras Receitas da Atividade", "20140101", "", "05;06", "P", "600", "S", "" } )
	aAdd( aBody, { "", "000178", "R0605", "Receitas Nao Operacionais", "20140101", "", "05;06", "P", "600", "N", "" } )
	aAdd( aBody, { "", "000179", "R0698", "Ajustes Negativos de Receitas", "20130101", "", "05;06", "N", "600", "N", "" } )
	aAdd( aBody, { "", "000180", "R0699", "Ajustes Positivos de Receitas", "20130101", "", "05;06", "P", "600", "N", "" } )


	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
