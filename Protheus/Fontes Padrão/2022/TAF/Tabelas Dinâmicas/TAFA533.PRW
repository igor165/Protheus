#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA533.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA533
MVC DA TABELA AUTO CONTIDA V3O-NATUREZA DE RENDIMENTO

@author Katielly Feitosa Rezende
@since 06/05/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA533()
Local	oBrw		:=	FWmBrowse():New()

If AliasIndic("V3O")
    oBrw:SetDescription(STR0001)    //"Cadastros das Naturezas de rendimento "
    oBrw:SetAlias( 'V3O')
    oBrw:SetMenuDef( 'TAFA533' )
    V3O->(DbSetOrder(1))
    oBrw:Activate()
Else
	Alert(STR0002)  //"Tabela V3O não existe."
EndIF

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC para o menu
@author Katielly Feitosa Rezende
@since 06/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA533" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Katielly Feitosa Rezende
@since 06/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruV3O 	:= 	FWFormStruct( 1, 'V3O' )
Local oModel 	:= 	MPFormModel():New( 'TAFA533' )

oModel:AddFields('MODEL_V3O', /*cOwner*/, oStruV3O)
oModel:GetModel('MODEL_V3O'):SetPrimaryKey({'V3O_FILIAL','V3O_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Katielly Feitosa Rezende
@since 06/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA533' )
Local 	oStruV3O	:= 	FWFormStruct( 2, 'V3O' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_V3O', oStruV3O, 'MODEL_V3O' )

oView:EnableTitleView( 'VIEW_V3O',STR0003)  //"Natureza de Rendimento"
oView:CreateHorizontalBox( 'FIELDSV3O', 100 )
oView:SetOwnerView( 'VIEW_V3O', 'FIELDSV3O' )

Return oView	

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Autor Katielly Feitosa Rezende
@Since		06/05/2019
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1028
If AliasIndic("V3O")
	If nVerEmp < nVerAtu 
        
        aAdd( aHeader, "V3O_FILIAL" ) 
        aAdd( aHeader, "V3O_ID" ) 
        aAdd( aHeader, "V3O_CODIGO" )
        aAdd( aHeader, "V3O_DESCR" )
        aAdd( aHeader, "V3O_FCI" )
        aAdd( aHeader, "V3O_DECSAL" )
        aAdd( aHeader, "V3O_RRA" )
        aAdd( aHeader, "V3O_CMPJUD" )
        aAdd( aHeader, "V3O_DEDUC" ) 
        aAdd( aHeader, "V3O_ISENTO" ) 
        aAdd( aHeader, "V3O_BENNAC" ) 
        aAdd( aHeader, "V3O_BENEXT" )
        aAdd( aHeader, "V3O_TRIB" )

        aAdd( aBody, { "", "000001", "000000001", "Decorrente de Decisão da Justiça do Trabalho" , "2", "1", "1", "1", "1,5,6", "2,3,4,5,7,8,99", "3", "3", "1"})
        aAdd( aBody, { "", "000002", "000000002", "Decorrente de Decisão da Justiça Federal", "2", "1", "1", "1", "1,2,3,4,5,6,7", "1,2,3,4,5,6,7,8,99", "3", "3", "1"})
        aAdd( aBody, { "", "000003", "000000003", "Decorrente de Decisão da Justiça dos Estados/Distrito Federal", "2", "1", "1", "1", "1,2,3,4,5,6,7", "1,2,3,4,5,6,7,8,99", "3", "3", "1"})
        aAdd( aBody, { "", "000004", "000000004", "Honorários advocatícios de sucumbência pelos advogados e procuradores públicos deque trata o art. 27 da Lei nº 13.327", "2", "2", "1", "1", "1,2,3,4,5,6,7",, "1", "1", "1"})
        aAdd( aBody, { "", "000005", "000000005", "Benefício do Regime Geral de Previdência Social", "2", "1", "1", "1", "1,2,3,4,5,6,7", "1,6", "1", "1","1"})
        aAdd( aBody, { "", "000006", "000000006", "Lucro e Dividendo", "2", "2", "2", "2", , , "3", "3", })
        aAdd( aBody, { "", "000007", "000000007", "Resgate de Previdência Complementar - Modalidade Contribuição Definida/Variável - Não Optante pela Tributação Exclusiva", "1", "2", "2", "1", , "7", "1", "1", "1"})
        aAdd( aBody, { "", "000008", "000000008", "Resgate de Fundo de Aposentadoria Programada Individual (Fapi)- Não Optante pela Tributação Exclusiva", "1", "2", "2", "1",  , "7", "1", "1", "1"})
        aAdd( aBody, { "", "000009", "000000009", "Resgate de Previdência Complementar - Modalidade Benefício Definido - Não Optante pela Tributação Exclusiva", "1", "2", "2", "1",  , "7", "1", "1", "1"})
        aAdd( aBody, { "", "000010", "000000010", "Resgate de Previdência Complementar - Modalidade Contribuição Definida/Variável - Optante pela Tributação Exclusiva", "1", "2", "2", "2",, "7", "1", "1","1"})
        aAdd( aBody, { "", "000011", "000000011", "Resgate de Fundo de Aposentadoria Programada Individual (Fapi)- Optante pela Tributação Exclusiva", "1", "2", "2", "2", , "7", "1", "1", "1"})
        aAdd( aBody, { "", "000012", "000000012", "Resgate de Planos de Seguro de Vida com Cláusula de Cobertura por Sobrevivência- Optante pela Tributação Exclusiva", "1", "2", "2", "2",,, "1", "1", "1"})
        aAdd( aBody, { "", "000013", "000000013", "Resgate de Planos de Seguro de Vida com Cláusula de Cobertura por Sobrevivência - Não Optante pela Tributação Exclusiva", "2", "2", "2", "1",,, "1", "1", "1"})
        aAdd( aBody, { "", "000014", "000000014", "Benefício de Previdência Complementar - Modalidade Contribuição Definida/Variável - Não Optante pela Tributação Exclusiva", "1", "1", "1", "1", "2,3,4,5,6,7", "1,6,7,99", "1",  "1", "1"})
        aAdd( aBody, { "", "000015", "000000015", "Benefício de Fundo de Aposentadoria Programada Individual (Fapi)- Não Optante pela Tributação Exclusiva", "1", "1", "1", "1", "2,3,4,5,6,7", "1,6,7,99", "1", "1", "1"})
        aAdd( aBody, { "", "000016", "000000016", "Benefício de Previdência Complementar - Modalidade Benefício Definido - Não Optante pela Tributação Exclusiva", "1", "1", "1", "1", "2,3,4,5,6,7", "1,6,7,99", "1", "1", "1"})
        aAdd( aBody, { "", "000017", "000000017", "Benefício de Previdência Complementar - Modalidade Contribuição Definida/Variável - Optante pela Tributação Exclusiva", "1", "1", "1", "2",, "6,7", "1", "1", "1"})
        aAdd( aBody, { "", "000018", "000000018", "Benefício de Fundo de Aposentadoria Programada Individual (Fapi)- Optante pela Tributação Exclusiva", "1", "1", "1", "2",, "6,7", "1", "1","1"})
        aAdd( aBody, { "", "000019", "000000019", "Benefício de Planos de Seguro de Vida com Cláusula de Cobertura por Sobrevivência- Optante pela Tributação Exclusiva", "1", "2", "2", "2",,, "1", "1", "1"})
        aAdd( aBody, { "", "000020", "000000020", "Benefício de Planos de Seguro de Vida com Cláusula de Cobertura por Sobrevivência - Não Optante pela Tributação Exclusiva", "2", "2", "2", "1",,, "1", "1", "1"})
        aAdd( aBody, { "", "000021", "000000021", "Juros sobre o Capital Próprio", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000022", "000000022", "Rendimento de Aplicações Financeiras de Renda Fixa, decorrentes de alienação, liquidação (total ou parcial), resgate, cessão ou repactuação do título ou aplicação", "2", "2", "2", "2",,,"3", "3", "1"})
        aAdd( aBody, { "", "000023", "000000023", "Rendimentos auferidos pela entrega de recursos à pessoa jurídica", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000024", "000000024", "Rendimentos predeterminados obtidos em operações conjugadas realizadas: nos mercados de opções de compra e venda em bolsas de valores, de mercadorias e de futuros (box); no mercado a termo nas bolsas de valores, de mercadorias e de futuros, em operações de venda coberta e sem ajustes diários, e no mercado de balcão.", "2", "2", "2", "2",,,"3", "3", "1"})
        aAdd( aBody, { "", "000025", "000000025", "Rendimentos obtidos nas operações de transferência de dívidas realizadas com instituição financeira e outras instituições autorizadas a funcionar pelo Banco Central do Brasil", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000026", "000000026", "Rendimentos periódicos produzidos por título ou aplicação, bem como qualquer remuneração adicional aos rendimentos prefixados", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000027", "000000027", "Rendimentos auferidos nas operações de mútuo de recursos financeiros", "2", "2", "2", "2",,, "3", "3", "1"}) 
        aAdd( aBody, { "", "000028", "000000028", "Rendimentos auferidos em operações de adiantamento sobre contratos de câmbio de exportação, não sacado (trava de câmbio), bem como operações com export notes, com debêntures, com depósitos voluntários para garantia de instância e com depósitos judiciais ou administrativos, quando seu levantamento se der em favor do depositante", "2", "2", "2", "2",,,"3", "3", "1"})
        aAdd( aBody, { "", "000029", "000000029", "Rendimentos obtidos nas operações de mútuo e de compra vinculada à revenda tendo por objeto ouro, ativo financeiro", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000030", "000000030", "Rendimentos auferidos em contas de depósitos de poupança", "2", "2", "2", "2",,, "2", "2", "1"})
        aAdd( aBody, { "", "000031", "000000031", "Rendimentos auferidos sobre juros produzidos por letras hipotecárias", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000032", "000000032", "Rendimentos ou ganhos decorrentes da negociação de títulos ou valores mobiliários de renda fixa em bolsas de valores, de mercadorias, de futuros e assemelhadas", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000033", "000000033", "Rendimentos auferidos em outras aplicações financeiras de renda fixa ou de renda variável", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000034", "000000034", "Rendimentos auferidos em Fundo de Investimento", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000035", "000000035", "Rendimentos auferidos em Fundos de investimento em quotas de fundos de investimento", "1", "2", "2", "2",,,"3", "3", "1"})
        aAdd( aBody, { "", "000036", "000000036", "Rendimentos produzidos por aplicações em fundos de investimento em ações", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000037", "000000037", "Rendimentos produzidos por aplicações em fundos de investimento em quotas de fundos de investimento em ações", "1", "2", "2" ,"2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000038", "000000038", "Rendimentos produzidos por aplicações em Fundos Mútuos de Privatização com recursos do Fundo de Garantia por Tempo de Serviço (FGTS)", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000039", "000000039", "Rendimentos auferidos pela carteira dos Fundos de Investimento Imobiliário", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000040", "000000040", "Rendimentos distribuídos pelo Fundo de Investimento Imobiliário aos seus cotistas", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000041", "000000041", "Rendimento auferido pelo cotista no resgate de cotas na liquidação do Fundo de Investimento Imobiliário", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000042", "000000042", "Rendimentos e ganhos de capital distribuídos pelo Fundo de Investimento Cultural e Artístico (Ficart)", "1", "2", "2", "2",,, "3", "3","1"})
        aAdd( aBody, { "", "000043", "000000043", "Rendimentos e ganhos de capital distribuídos pelo Fundo de Financiamento da Indústria Cinematográfica Nacional (Funcines)", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000044", "000000044", "Juros não especificados", "2","2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000045", "000000045", "Rendimentos auferidos no resgate de quotas de fundos de investimento mantidos com recursos provenientes de conversão de débitos externos brasileiros, e de que participem, exclusivamente, residentes ou domiciliados no exterior", "1", "2", "2","2",,,"4", "3", "1"})
        aAdd( aBody, { "", "000046", "000000046", "Demais rendimentos de capital", "2", "2", "2", "2",,,"3", "3", "1"})
        aAdd( aBody, { "", "000047", "000000047", "Rendimentos  de Locação ou Sublocação", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000048", "000000048", "Rendimentos  de Arrendamento ou Subarrendamento", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000049", "000000049", "Importâncias pagas por terceiros por conta do locador do bem (juros, comissões etc.)", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000050", "000000050", "Importâncias pagas ao locador pelo contrato celebrado (luvas, prêmios etc.)", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000051", "000000051", "Benfeitorias e quaisquer melhoramentos realizados no bem locado", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000052", "000000052", "Juros decorrente da alienação a prazo de bens", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000053", "000000053", "Rendimentos de Direito de Uso ou Passagem de Terrenos e de aproveitamento de águas", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000054", "000000054", "Rendimentos de Direito de exploração de películas cinematográficas, Obras Audiovisuais, e Videofônicas", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000055", "000000055", "Rendimentos de  Direito de Conjuntos Industriais e Invenções", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000056", "000000056", "Rendimentos de Direito Autoral", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000057", "000000057", "Rendimentos de Direito Autoral (quando não percebidos pelo autor ou criador da obra)", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000058", "000000058", "Rendimentos de Direito de Imagem", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000059", "000000059", "Rendimentos de Direito de colher ou extrair recursos vegetais, pesquisar e extrair recursos minerais", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000060", "000000060", "Produto da alienação de marcas de indústria e comércio, patentes de invenção e processo ou fórmulas de fabricação", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000061", "000000061", "Importâncias pagas por terceiros por conta do cedente dos direitos (juros, comissões etc.)", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000062", "000000062", "Importâncias pagas ao cedente do direito, pelo contrato celebrado (luvas, prêmios etc.)", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000063", "000000063", "Despesas para conservação dos direitos cedidos (quando compensadas pelo uso do bem ou direito)", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000064", "000000064", "Demais Royalties", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000065", "000000065", "Juros de mora e quaisquer outras compensações pelo atraso no pagamento de royalties", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000066", "000000066", "Juros decorrente da alienação a prazo de direitos", "2", "2", "2", "1", "1,5,6",, "1", "3", "1"})
        aAdd( aBody, { "", "000067", "000000067", "Ganho de capital decorrente da integralização de cotas de fundos ou clubes de investimento por meio da entrega de ativos financeiros", "1","2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000068", "000000068", "Distribuição de Juros sobre o Capital Próprio pela companhia emissora de ações objeto de empréstimo", "1", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000069", "000000069", "Rendimentos de Partes Beneficiárias ou de Fundador", "2", "2", "2", "1", "1,5,6",, "3", "3", "1"})
        aAdd( aBody, { "", "000070", "000000070", "Rendimentos auferidos em operações de swap", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000071", "000000071", "Rendimentos auferidos em operações day trade realizadas em bolsa de valores, de mercadorias, de futuros e assemelhadas", "2", "2", "2","2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000072", "000000072", "Rendimento decorrente de Operação realizada em bolsas de valores, de mercadorias, de futuros, e assemelhadas, exceto day trade", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000073", "000000073", "Rendimento decorrente de Operação realizada no mercado de balcão, com intermediação, tendo por objeto ações, ouro ativo financeiro e outros valores mobiliários negociados no mercado à vista", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000074", "000000074", "Rendimento decorrente de Operação realizada em mercados de liquidação futura fora de bolsa", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000075", "000000075", "Alienação de bens e direitos do ativo não circulante localizados no Brasil", "2", "2", "2", "2",,, "4", "2", "1"})
        aAdd( aBody, { "", "000076", "000000076", "Comissões, corretagens, ou qualquer outra importância paga/creditada pela representação comercial ou pela mediação na realização de negócios civis e comerciais", "2", "2", "2", "2",,, "2", "3", "1"})
        aAdd( aBody, { "", "000077", "000000077", "Rendimento de Serviços de propaganda e publicidade", "2", "2", "2", "2",,, "2", "3", "1"})
        aAdd( aBody, { "", "000078", "000000078", "Prêmios distribuídos, sob a forma de bens e serviços, mediante concursos e sorteios", "2", "2", "2", "2",,, "3", "3" , "1"})
        aAdd( aBody, { "", "000079", "000000079", "Prêmios distribuídos, sob a forma de dinheiro, mediante concursos e sorteios", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000080", "000000080", "Prêmios de Proprietários e Criadores de Cavalos de Corrida", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000081", "000000081", "Benefícios líquidos resultantes da amortização antecipada, mediante sorteio, dos títulos de capitalização", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000082", "000000082", "Benefícios atribuídos aos portadores de títulos de capitalização nos lucros da empresa emitente", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000083", "000000083", "Prêmios distribuídos, sob a forma de bens e serviços, mediante sorteios de jogos de bingo permanente ou eventual", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000084", "000000084", "Prêmios distribuídos, em dinheiro, obtido mediante sorteios de jogos de bingo permanente ou eventual", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000085", "000000085", "Importâncias correspondentes a multas e qualquer outra vantagem, ainda que a título de indenização, em virtude de rescisão de contrato", "2", "2", "2", "2",,, "3", "3", "1"})
        aAdd( aBody, { "", "000086", "000000086", "Responsabilidade Civil - juros e indenizações por lucros cessantes", "2", "1", "2", "2", "1,2,3,4,5,6,7",, "3", "3", "1"})
        aAdd( aBody, { "", "000087", "000000087", "Importâncias pagas ou creditadas a cooperativas de trabalho, associações de profissionais ou assemelhadas, relativas a serviços pessoais que lhes forem prestados por associados destas ou colocados à disposição", "2", "2", "2", "2",,, "2", "2", "1"}) 
        aAdd( aBody, { "", "000088", "000000088", "Remuneração de Serviços de administração de bens ou negócios em geral, exceto consórcios ou fundos mútuos para aquisição de bens", "2", "2", "2", "2" ,,, "2", "2", "2"})
        aAdd( aBody, { "", "000089", "000000089", "Remuneração de Serviços de advocacia", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000090", "000000090", "Remuneração de Serviços de análise clínica laboratorial", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000091", "000000091", "Remuneração de Serviços de análises técnicas", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000092", "000000092", "Remuneração de Serviços de arquitetura", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000093", "000000093", "Remuneração de Serviços de assessoria e consultoria técnica, exceto serviço de assistência técnica prestado a terceiros e concernente a ramo de indústria ou comércio explorado pelo prestador do serviço", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000094", "000000094", "Remuneração de Serviços de assistência social", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000095", "000000095", "Remuneração de Serviços de auditoria", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000096", "000000096", "Remuneração de Serviços de avaliação e perícia", "2", "2", "2","2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000097", "000000097", "Remuneração de Serviços de  biologia e biomedicina", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000098", "000000098", "Remuneração de Serviços de cálculo em geral", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000099", "000000099", "Remuneração de Serviços de consultoria", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000100", "000000100", "Remuneração de Serviços de contabilidade", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000101", "000000101", "Remuneração de Serviços de desenho técnico", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000102", "000000102", "Remuneração de Serviços de economia", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000103", "000000103", "Remuneração de Serviços de elaboração de projetos", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000104", "000000104", "Remuneração de Serviços de engenharia, exceto construção de estradas, pontes, prédios e obras assemelhadas", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000105", "000000105", "Remuneração de Serviços de  ensino e treinamento", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000106", "000000106", "Remuneração de Serviços de estatística", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000107", "000000107", "Remuneração de Serviços de fisioterapia", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000108", "000000108", "Remuneração de Serviços de fonoaudiologia", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000109", "000000109", "Remuneração de Serviços de geologia", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000110", "000000110", "Remuneração de Serviços de leilão",  "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000111", "000000111", "Remuneração de Serviços de  medicina, exceto aquela prestada por ambulatório, banco de sangue, casa de saúde, casa de recuperação ou repouso sob orientação médica, hospital e pronto-socorro", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000112", "000000112", "Remuneração de Serviços de nutricionismo e dietética", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000113", "000000113", "Remuneração de Serviços de odontologia", "2", "2", "2", "2",,, "2", "2","2"})
        aAdd( aBody, { "", "000114", "000000114", "Remuneração de Serviços de organização de feiras de amostras, congressos, seminários, simpósios e congêneres", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000115", "000000115", "Remuneração de Serviços de pesquisa em geral", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000116", "000000116", "Remuneração de Serviços de planejamento", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000117", "000000117", "Remuneração de Serviços de programação", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000118", "000000118", "Remuneração de Serviços de  prótese", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000119", "000000119", "Remuneração de Serviços de  psicologia e psicanálise", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000120", "000000120", "Remuneração de Serviços de química", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000121", "000000121", "Remuneração de Serviços de radiologia e radioterapia", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000122", "000000122", "Remuneração de Serviços de relações públicas", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000123", "000000123", "Remuneração de Serviços de serviço de despachante", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000124", "000000124", "Remuneração de Serviços de  terapêutica ocupacional", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000125", "000000125", "Remuneração de Serviços de  tradução ou interpretação comercial", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000126", "000000126", "Remuneração de Serviços de urbanismo", "2", "2", "2", "2",,,"2", "2", "2"})
        aAdd( aBody, { "", "000127", "000000127", "Remuneração de Serviços de  veterinária", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000128", "000000128", "Remuneração de Serviços de Limpeza","2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000129", "000000129", "Remuneração de Serviços de Conservação/ Manutenção", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000130", "000000130", "Remuneração de Serviços de Segurança/Vigilância/Transporte de valores", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000131", "000000131", "Remuneração de Serviços Locação de Mão de obra", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000132", "000000132", "Remuneração de Serviços de Assessoria Creditícia, Mercadológica, Gestão de Crédito, Seleção e Riscos e Administração de Contas a Pagar e a Receber", "2", "2", "2", "2",,, "2", "2", "2"})
        aAdd( aBody, { "", "000133", "000000133", "Pagamentos Referentes à Aquisição de Autopeças", "2", "2", "2", "2",,, "2", "4", "3" })
        aAdd( aBody, { "", "000134", "000000134", "Rendimentos pago a companhias de navegação aérea e marítima", "2", "2", "2", "2",,, "4", "2", "2" })
        aAdd( aBody, { "", "000135", "000000135", "Demais pagamentos a entidades imunes ou isentas", "2", "2", "2", "2",,,"2", "4", } )

        aAdd( aBody, { "", "000136", "200000001", "Alimentação", "2", "2", , "2",,,"2","4","2" } )
        aAdd( aBody, { "", "000137", "200000002", "Energia elétrica", "2", "2", , "2",,,"2","4","2" } )
        aAdd( aBody, { "", "000138", "200000003", "Serviços prestados com emprego de materiais", "2", "2",, "2",,,"2","4", "2" } )
        aAdd( aBody, { "", "000139", "200000004", "Construção Civil por empreitada com emprego de materiais", "2", "2", ,"2",,,"2","4","2" } )
        aAdd( aBody, { "", "000140", "200000005", "Serviços hospitalares de que trata o art. 30 da Instrução Normativa RFB nº 1.234, de 11 de janeiro de 2012", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000141", "200000006", "Transporte nacional de cargas", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000142", "200000007", "Serviços de auxílio diagnóstico e terapia, patologia clínica, imagenologia, anatomia patológica e citopatológica, medicina nuclear e análises e patologias clínicas, exames por métodos gráficos, procedimentos endoscópicos, radioterapia, quimioterapia, diálise e oxigenoterapia hiperbárica de que trata o art. 31 e parágrafo único da Instrução Normativa RFB nº 1.234, de 2012", "2", "2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000143", "200000008", "Produtos farmacêuticos, de perfumaria, de toucador ou de higiene pessoal adquiridos de produtor, importador, distribuidor ou varejista", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000144", "200000009", "Mercadorias e bens em geral", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000145", "200000010", "Gasolina, inclusive de aviação, óleo diesel, gás liquefeito de petróleo (GLP), combustíveis derivados de petróleo ou de gás natural, querosene de aviação (QAV), e demais produtos derivados de petróleo, adquiridos de refinarias de petróleo, de demais produtores, de importadores, de distribuidor ou varejista", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000146", "200000011", "Álcool etílico hidratado, inclusive para fins carburantes, adquirido diretamente de produtor, importador ou do distribuidor", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000147", "200000012", "Biodiesel adquirido de produtor ou importador", "2", "2", , "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000148", "200000013", "Gasolina, exceto gasolina de aviação, óleo diesel e gás liquefeito de petróleo (GLP), derivados de petróleo ou de gás natural e querosene de aviação adquiridos de distribuidores e comerciantes varejistas", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000149", "200000014", "Álcool etílico hidratado nacional, inclusive para fins carburantes adquirido de comerciante varejista", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000150", "200000015", "Biodiesel adquirido de distribuidores e comerciantes varejistas", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000151", "200000016", "Biodiesel adquirido de produtor detentor regular do selo Combustível Social, fabricado a partir de mamona ou fruto, caroço ou amêndoa de palma produzidos nas regiões norte e nordeste e no semiárido, por agricultor familiar enquadrado no Programa Nacional de Fortalecimento da Agricultura Familiar (Pronaf)", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000152", "200000017", "Transporte internacional de cargas efetuado por empresas nacionais", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000153", "200000018", "Estaleiros navais brasileiros nas atividades de Construção, conservação, modernização, conversão e reparo de embarcações pré- registradas ou registradas no REB", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000154", "200000019", "Produtos de perfumaria, de toucador e de higiene pessoal a que se refere o § 1º do art. 22 da Instrução Normativa RFB nº 1.234, de 2012, adquiridos de distribuidores e de comerciantes varejistas", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000155", "200000020", "Produtos a que se refere o § 2º do art. 22 da Instrução Normativa RFB nº 1.234, de 2012","2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000156", "200000021", "Produtos de que tratam as alíneas c a k do inciso I do art. 5º da Instrução Normativa RFB nº 1.234, de 2012", "2", "2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000157", "200000022", "Outros produtos ou serviços beneficiados com isenção, não incidência ou alíquotas zero da Cofins e da Contribuição para o PIS/Pasep, observado o disposto no § 5º do art. 2º da Instrução Normativa RFB nº 1.234, de 2012","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000158", "200000023", "Passagens aéreas, rodoviárias e demais serviços de transporte de passageiros, inclusive, tarifa de embarque, exceto transporte internacional de passageiros", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000159", "200000024", "Transporte internacional de passageiros efetuado por empresas nacionais","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000160", "200000025", "Serviços prestados por associações profissionais ou assemelhadas e cooperativas","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000161", "200000026", "Serviços prestados por bancos comerciais, bancos de investimento, bancos de desenvolvimento, caixas econômicas, sociedades de crédito, financiamento e investimento, sociedades de crédito imobiliário, e câmbio, distribuidoras de títulos e valores mobiliários, empresas de arrendamento mercantil, cooperativas de crédito, empresas de seguros privados e de capitalização e entidades abertas de previdência complementar","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000162", "200000027", "Seguro Saúde","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000163", "200000028", "Serviços de abastecimento de água", "2", "2", ,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000164", "200000029", "Telefone","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000165", "200000030", "Correio e telégrafos","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000166", "200000031", "Vigilância", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aBody, { "", "000167", "200000032", "Limpeza","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000168", "200000033", "Locação de mão de obra", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000169", "200000034", "Intermediação de negócios","2","2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000170", "200000035", "Administração, locação ou cessão de bens imóveis, móveis e direitos de qualquer natureza", "2", "2",, "2",,,"2","4", "2"} )
        aAdd( aBody, { "", "000171", "200000036", "Factoring", "2", "2",,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000172", "200000037", "Plano de saúde humano, veterinário ou odontológico com valores fixos por servidor, por empregado ou por animal", "2", "2", ,"2",,,"2","4","2"} )
        aAdd( aBody, { "", "000173", "200000038", "Demais serviços", "2", "2",, "2",,,"2","4","2"} )
        aAdd( aRet, { aHeader, aBody } )
    EndIf
EndIf
   
Return( aRet )