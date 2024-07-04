#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA378.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA378
Cadastro MVC de Obrigações Fiscais

@author Paulo S. Vilas B.Santana
@since 10/04/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA378()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Código de Subitem"
oBrw:SetAlias( 'CHY')
oBrw:SetMenuDef( 'TAFA378' )
CHY->(DbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Paulo S. Vilas B.Santana
@since 10/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA378" ,,,,.T. )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Paulo S. Vilas B.Santana
@since 10/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCHY  :=  FWFormStruct( 1, 'CHY' )
Local oModel    :=  MPFormModel():New( 'TAFA378' )

oModel:AddFields('MODEL_CHY', /*cOwner*/, oStruCHY)
oModel:GetModel('MODEL_CHY'):SetPrimaryKey({'CHY_FILIAL','CHY_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Paulo S. Vilas B.Santana
@since 10/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA378' )
Local   oStruCHY    :=  FWFormStruct( 2, 'CHY' )
Local   oView       :=  FWFormView():New()

oStruCHY:RemoveField('CHY_ID')
oStruCHY:RemoveField('CHY_IDUF')

oView:SetModel( oModel )
oView:AddField( 'VIEW_CHY', oStruCHY, 'MODEL_CHY' )

oView:EnableTitleView( 'VIEW_CHY', STR0001 )    //"Código de Subitem"
oView:CreateHorizontalBox( 'FIELDSCHY', 100 )
oView:SetOwnerView( 'VIEW_CHY', 'FIELDSCHY' )

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
	aAdd( aHeader, "CHY_FILIAL" )
	aAdd( aHeader, "CHY_ID" )
	aAdd( aHeader, "CHY_CODIGO" )
	aAdd( aHeader, "CHY_DESCRI" )
	aAdd( aHeader, "CHY_FLEGAL" )
	aAdd( aHeader, "CHY_OPERAC" )
	aAdd( aHeader, "CHY_IDUF" )

	aAdd( aBody, { "", "765cc950-71c0-8ce3-aa90-7c84fdf4131e", "00201", "Credito acumulado utilizavel apropriado no periodo.", "Artigo 72 do RICMS/00 e Portaria CAT-53/96", "0", "000027" } )
	aAdd( aBody, { "", "b72e824d-bc1e-a9e2-b790-e6244e93350e", "00202", "Diferenca de imposto apurada por contribuinte.", "Artigo 108 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "2ee9bcff-d6a5-8d05-7406-c6bb39d79a35", "00203", "Reserva de Credito Acumulado para liquidacao de debito fiscal.", "Artigo 588, . 1. do RICMS/00 e Artigo 15 da Portaria CAT-53/96", "0", "000027" } )
	aAdd( aBody, { "", "d7c447e4-3a13-d692-0284-97b4cc2d9671", "00204", "Devolucao de Credito Acumulado.", "Artigo 77 do RICMS/00 e Portaria CAT-53/96", "0", "000027" } )
	aAdd( aBody, { "", "6eb05988-d9fa-9311-db55-d61a46f62421", "00205", "Transferencia de Credito Simples do ICMS.", "Artigo 70 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "68e45adf-dfa4-527f-095a-4f6f19b9fbee", "00206", "Entrada de mercadoria com imposto a pagar ou utilizacao de servicos com imposto a pagar.", "Artigo 116, I do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "7f246319-9eda-10c8-4eb1-8bedfc52e127", "00207", "Entrada de mercadoria, oriunda de outro Estado, destinada a uso, consumo ou integracao no ativo imobilizado ou utilizacao de servico iniciado fora do territorio paulista - Diferencial de aliquota.", "Artigo 117, II do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "4f040bc4-0ecb-a76b-7baa-2182227cee9c", "00208", "Complemento do imposto por contribuinte substituido - Complemento de Substituicao Tributaria.", "Artigo 265 do RICMS/00 e Artigo 7., I, da Portaria CAT-17/99", "0", "000027" } )
	aAdd( aBody, { "", "0e90a9b7-c60b-4d15-fc03-b372a9a82a3c", "00209", "Ressarcimento de substituicao tributaria por Pedido de Liquidacao de Debito Fiscal.", "Artigo 270, . 2. do RICMS/00 e Artigo 7., . 1. da Portaria CAT-17/99", "0", "000027" } )
	aAdd( aBody, { "", "7f1f6c07-dd53-3c43-aba5-1857f73a0712", "00210", "Ressarcimento de substituicao tributaria por Nota Fiscal de Ressarcimento.", "Artigo 270, II do RICMS/00 e Artigo 7., . 1. da Portaria CAT-17/99", "0", "000027" } )
	aAdd( aBody, { "", "5517c758-6647-0579-ee9f-97ab20c268dc", "00211", "Ressarcimento de substituicao tributaria por Pedido de Ressarcimento.", "Artigo 270, III do RICMS/00 e Artigo 7., . 1. da Portaria CAT-17/99", "0", "000027" } )
	aAdd( aBody, { "", "0c6249e6-e6d0-441b-fc6d-0f016b3c93ac", "00212", "Estabelecimento que receber de outro Estado, mercadoria abrangida pela substituicao tributaria, quando a responsabilidade pelo pagamento do imposto seja a ele atribuida - valor do imposto incidente sobre sua propria oper", '"Artigo 277, . 2., itens 1, ""a"" e 2 do RICMS/00"', "0", "000027" } )
	aAdd( aBody, { "", "3c7d39eb-5566-6cbc-a166-6572dea05cf2", "00213", "Sujeito passivo por substituicao que realizar operacao fora do estabelecimento, sem destinatario certo, com mercadoria abrangida pela Substituicao Tributaria - ICMS proprio em remessa para venda fora do estabelecimento.", '"Artigo 284, II, ""b"" do RICMS/00"', "0", "000027" } )
	aAdd( aBody, { "", "9f1df6af-86a5-c2ef-bd85-d7acabae0ee0", "00214", "Entrada de residuo de materiais em estabelecimento industrial.", "Artigo 392, . 1., 3 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "f6a76f49-c85e-1a17-ca95-ddc4de07e071", "00215", "Entrada de metais nao-ferrosos em estabelecimentos industriais. (Validade ate a referencia 08/2000).", "Artigo 379-A, , III do RICMS/91", "0", "000027" } )
	aAdd( aBody, { "", "d07e7154-a584-451c-f7b4-e8b234be3b1b", "00216", "Remessa para venda fora do estabelecimento.", "Artigo 434, . 1., 2 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "49564c25-3ad9-1345-aa74-ebcd00b30941", "00217", "Diferenca paga por empresa seguradora relativamente a pecas adquiridas para emprego em conserto de veiculo acidentado.", "Artigo 7., Anexo XIV do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "20c1953b-b6df-6fa0-3eec-c721bb45b697", "00218", "Transferencia de saldo credor para estabelecimento centralizador", "Artigo 98, III do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "142a5f81-5bef-6b51-8191-13fe1e51d90d", "00219", "Recebimento de saldo devedor - estabelecimento centralizador", "Artigo 99 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "241f8413-0840-e522-95d3-52d913974615", "00220", "Devolucao de credito acumulado mediante autorizacao eletronica", "Artigo 77 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "000c4129-cbf0-1385-c5a3-7b889d806bd2", "00221", "Apropriacao de credito acumulado mediante autorizacao eletronica", "Artigo 72, II do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "40d26c95-87e8-bd3f-8101-06144ce459c2", "00749", "Ressarcimento de substituicao tributaria - Compensacao Escritural mediante autorizacao eletronica.", "Artigo 72, II do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "46e2004e-06fd-fc78-0990-cf599077ec25", "00222", "Transferencia de credito acumulado - Protocolo ICM 12/84", "Artigo 73, V do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "43e6900c-b19c-ea4a-bd1a-553c8e892f55", "00223", "Devolucao de credito recebido de Produtor Rural ou Cooperativa de Produtores Rurais mediante autorizacao eletronica", "Artigo 70-E do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "3eb435fe-b878-5026-4765-fa93c56266ca", "00224", "Imposto devido na prestacao de servico de comunicacao a usuario localizado neste Estado, na hipotese de inexistencia de estabelecimento do prestador no territorio paulista", "Artigo 2., . 4. do Anexo XVII do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "946bfedb-a0bf-ebc0-df42-70b68c794d4a", "00225", "Transferencia de Credito Simples do ICMS, decorrente da entrada de bem destinado ao ativo permanente", "Artigo 70 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "ec06d817-dd69-a090-3454-4d30ba22dbcc", "00226", "Transferencia de credito do ICMS para cooperativa centralizadora de vendas", "Artigo 70-I do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "3b286d17-7611-a234-33ec-f263d8ca7dce", "00299", "OUTRAS HIPOTESES - PREENCHIDA PELO CONTRIBUINTE", "PREENCHIDA PELO CONTRIBUINTE", "0", "000027" } )
	aAdd( aBody, { "", "754f6287-1492-9553-eee7-1209d6004e1a", "00301", "Estorno de imposto creditado quando a mercadoria entrada no estabelecimento vier a perecer, deteriorar-se ou for objeto de roubo, furto ou extravio.", "Artigo 67, I do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "32cd39fb-7d66-f2b2-589f-e2e96a171bb5", "00302", "Estorno de imposto creditado quando o servico tomado ou a mercadoria adquirida for objeto de saida ou prestacao de servico nao tributada.", "Artigo 67, II do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "9a314ca6-cadb-14d9-9992-70778ca9678d", "00303", "Estorno de imposto creditado quando a mercadoria adquirida for integrada ou consumida em processo de industrializacao ou producao rural, quando a saida nao for tributada ou estiver isenta do imposto.", "Artigo 67, III do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "d48913df-249c-8d03-a876-3f94ec1283be", "00304", "Estorno de imposto creditado quando a mercadoria adquirida for integrada ou consumida em processo de industrializacao ou producao rural, quando a saida tiver base de calculo reduzida.", "Artigo 64, IV do RICMS/91", "0", "000027" } )
	aAdd( aBody, { "", "27f0a0a7-2c92-cff8-d55f-f62eb5a93626", "00305", "Estorno do valor do credito deduzido na guia de recolhimento nas saidas de cafe cru, em coco ou em grao.", "Artigo 339, paragrafo unico do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "cc6eb811-bf4a-fd10-8517-cad0775d37cd", "00306", "Estorno do valor do credito deduzido na guia de recolhimento nas saidas de gado em pe bovino e suino.", "Artigo 371, paragrafo unico do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "5b20ec6b-0da5-b7f8-ca83-4d4343205d04", "00307", "Ativo Permanente - transferencia de credito remanescente.", '"Artigo 4. DDTT, I, ""b"", do RICMS/00"', "0", "000027" } )
	aAdd( aBody, { "", "5829dad2-4cf4-a64c-f979-c25b4b5bae7a", "00308", "Saidas de produtos agricolas - ICMS recolhido pelo armazem geral, por guia de recolhimentos especiais.", "Artigo 3., . 2., Anexo VIII do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "a18ff641-8877-613a-4856-ab82a7ea5b53", "00309", "Uso ou consumo da mercadoria ou servico destinado O comercializacao ou Industrializacao.", "Artigo 67, V do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "ea5302e1-2ece-e2ee-cc1f-8d4fb0f9f7e7", "00310", "Estorno do imposto creditado na ocorrencia 007.08", "Artigo 61, . 2., Anexo VIII do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "c0d68ce5-0c64-31ac-89d7-c0febc8d2c7f", "00399", "OUTRAS HIPOTESES - PREENCHIDA PELO CONTRIBUINTE", "PREENCHIDA PELO CONTRIBUINTE", "0", "000027" } )
	aAdd( aBody, { "", "b3128d40-e923-8d7e-3355-869120219bea", "00701", "Recebimento de credito simples do ICMS.", "Artigo 70 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "53a87e69-ad4b-05a4-47fa-9c5dbc80758a", "00702", "Reincorporacao de credito acumulado.", "Artigo 80, I do RICMS/00 e Artigo 12 da Portaria CAT-53/96", "0", "000027" } )
	aAdd( aBody, { "", "135041ee-a10e-45b4-da4c-6f9c05818ba1", "00703", "Reincorporacao de credito acumulado para reserva.", "Artigo 80 do RICMS/00 e Artigo 15 da Portaria CAT-53/96", "0", "000027" } )
	aAdd( aBody, { "", "ea7f1680-fa66-5927-cc5c-8bed41cadd12", "00704", "Recebimento de credito acumulado por fornecimento de materia-prima, material secundario e de embalagem.", "Artigo 76, II do RICMS/00 e Artigo 9. da Portaria CAT-53/96", "0", "000027" } )
	aAdd( aBody, { "", "d53ca159-3e1b-df88-a344-55d73e6a739e", "00705", "Recebimento de credito acumulado por fornecimento de maquina, aparelho ou equipamento industrial.", "Artigo 76, II do RICMS/00 e Artigo 9. da Portaria CAT-53/96", "0", "000027" } )
	aAdd( aBody, { "", "b2335740-397a-14de-3aad-716014b7aeb1", "00706", "Recebimento de credito acumulado de estabelecimento da mesma empresa.", "Artigo 76, II do RICMS/00 e Artigo 9. da Portaria CAT-53/96", "0", "000027" } )
	aAdd( aBody, { "", "aa97e6df-1980-4282-b5f7-3706b6d6e1eb", "00707", "Recebimento de credito acumulado de estabelecimento de empresa interdependente.", "Artigo 76, II do RICMS/00 e Artigo 9. da Portaria CAT-53/96", "0", "000027" } )
	aAdd( aBody, { "", "b524e2b7-5cb3-6a9b-79fd-196aac187947", "00708", "Importacao de bem ou mercadoria com direito a credito de ICMS.", "Artigo 61, . 8. do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "8d836bc6-d2d5-fe3e-8225-b01664cca6a2", "00709", "Credito outorgado sobre o imposto devido na prestacao de servico de transporte, exceto aereo.", "Artigo 62 e Artigo 11, Anexo III do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "f538af4c-098a-2256-8e20-67a4483fcf63", "00710", "Imposto pago indevidamente, em virtude de erro de fato ocorrido na escrituracao dos livros fiscais ou no preparo da guia de recolhimento.", "Artigo 63, II do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "f0e08fb4-71d8-e1a3-9ad1-190458c9c7db", "00711", "Imposto correspondente O diferenca verificada entre a importancia recolhida e a apurada decorrente do desenquadramento do regime de estimativa", '"Artigo 63, III e Artigo 92, II, ""a"" do RICMS/00."', "0", "000027" } )
	aAdd( aBody, { "", "bc3aed34-43af-683e-515d-113dd9bfe7e2", "00712", "Imposto pago indevidamente, objeto de pedido administrativo de restituicao quando a decisao nao tiver sido proferida no prazo de 45 dias, contados da data do respectivo pedido.", "Artigo 63, V do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "52b239c5-dd1a-9fc3-658a-ddc7fa4797b0", "00713", "Imposto pago indevidamente em razao de destaque a maior em documento fiscal, ate o limite estabelecido pela Secretaria da Fazenda.", "Artigo 63, VII do RICMS/00 e Portaria CAT-83/91", "0", "000027" } )
	aAdd( aBody, { "", "0c631748-dfd3-9592-d4e7-5283f6c4f858", "00714", "Valor do imposto destacado na nota fiscal relativa O aquisicao de bem, objeto de arrendamento mercantil pela empresa arrendadora, por ocasiao da entrada no estabelecimento.", "Artigo 63, VIII do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "089e2937-d082-ae8b-fda8-a0b8377cdecf", "00715", "Recebimento de credito transferido por produtor rural.", "Artigo 70, I e Artigo 8. das DDTT do RICMS/00 e Portaria CAT-28/91", "0", "000027" } )
	aAdd( aBody, { "", "9612be61-eb97-0c05-91eb-362a80cf5cc4", "00716", "Imposto recolhido por guia de recolhimentos especiais nas saidas de alcool carburante e de produtos resultantes da industrializacao do petroleo.", "Artigo 115, . 6. do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "6fc7ae6b-1061-0122-290e-22bc05b6293c", "00717", "Imposto recolhido pelo destinatario por guia de recolhimentos especiais, relativo a servico tomado ou mercadoria entrada no estabelecimento.", '"Artigo 116, paragrafo unico, 2, ""b"" do RICMS/00"', "0", "000027" } )
	aAdd( aBody, { "", "d6023655-b9b1-e9af-b169-d806139cd621", "00718", "Entrada de mercadoria, oriunda de outro Estado, destinada a uso, consumo ou integracao no ativo imobilizado, ou utilizacao de servico iniciado noutro Estado - Diferencial de aliquota.", "Artigo 117, I do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "6d3c1bc1-2adb-eced-dacb-cc31bc326234", "00719", "Ressarcimento de substituicao tributaria, por estabelecimento de contribuinte substituido.", "Artigos 269 e 270 do RICMS/00 e Artigo 7., II da Portaria CAT-17/99", "0", "000027" } )
	aAdd( aBody, { "", "44796f2e-74c2-4a65-0a88-1330b864273a", "00720", "Compensacao de imposto pago na operacao propria do substituto, por estabelecimento de contribuinte substituido, relativamente a operacoes com veiculos.", "Artigos 269 e 270 do RICMS/00 e Artigo 7., III da Portaria CAT-17/99", "0", "000027" } )
	aAdd( aBody, { "", "bc002cfb-0802-68d1-e769-10e989b43ffd", "00721", "Credito relativo O operacao propria do Substituto em operacao interestadual promovida pelo contribuinte substituido.", "Artigo 271 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "4f7570a4-e8d5-3c0b-b499-e43bdd0f015a", "00722", "Imposto recolhido mediante guia de recolhimentos especiais nas operacoes com cafe cru.", "Artigo 344, II do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "e621835a-c1ed-2824-5788-950fa03ec68a", "00723", "Imposto recolhido por guia de recolhimentos especiais pelo abate de gado.", "Artigo 367, . 2. e Artigo 381, I do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "70b4ea15-a4ac-80d3-48a5-e27646dfe4b6", "00724", "Credito outorgado - abate de bovinos e suinos.", "Artigo 372 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "955f0ea1-c432-b386-b679-6bb2e72e6e4a", "00725", "Imposto recolhido mediante guia de recolhimentos especiais nas operacoes com gado em pe.", "Artigo 380, II do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "63682693-6908-730a-1b7f-53987b9fe526", "00726", "Imposto relativo O entrada de gado em pe originario de outro Estado.", "Artigo 381, II do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "4901b5fd-8dbb-effa-0e13-07c7bdb1f219", "00727", "Recolhimento em outros Estados nas operacoes de vendas fora do estabelecimento.", '"Artigo 434, . 4., 5, ""b"" do RICMS/00"', "0", "000027" } )
	aAdd( aBody, { "", "937225d4-29b2-9a5f-9d92-ce1a08cb6de7", "00728", "Na desistencia de ressarcimento por Nota Fiscal de Ressarcimento, Pedido de Ressarcimento ou Pedido de Liquidacao de Debito Fiscal -Reincorporacao do imposto.", "Artigo 7., . 2. da Portaria CAT-17/99", "0", "000027" } )
	aAdd( aBody, { "", "3b7ff6fe-1a7f-5710-e8b9-8a33b2b93be7", "00729", "Transferencia de saldo devedor para estabelecimento centralizador", "Artigo 98, III do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "33c86079-b5d1-e97f-38d2-538e3f42dc56", "00730", "Recebimento de saldo credor - estabelecimento centralizador", "Artigo 99 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "dcae5d66-995e-97cd-9323-0ecb0703a8a7", "00731", "Credito outorgado - abate de aves", "Artigo 363, . 2. do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "ce82ca65-89ab-03f8-5d7d-3bd6884da09f", "00732", "Credito outorgado - outros produtos alimenticios", "Artigos 1., 2., 6. e 9., exceto item XXIX do Artigo 9., anexo III do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "64aa4cd3-0226-c010-8f28-a0ae6dd87f86", "00733", "Credito outorgado - informatica periferico", "Artigo 7., Anexo III, itens I, II, V, VI, VII, XIV, XV, XVI, XVII e XVIII do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "5d9f465a-93ce-ae34-8de9-282f62aa317d", "00734", "Credito outorgado - telefone celular", "Artigo 7., Anexo III, itens III e IV do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "aaae41c2-5970-162f-6c22-0dd63f2104c7", "00735", "Credito outorgado - unidade de processamento", "Artigo 7., Anexo III, itens VIII, IX, XII e XIII do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "d2081868-94a4-1401-bef3-94743fde8012", "00736", "Credito outorgado - informatica outros", "Artigo 7., Anexo III, itens X e XI do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "88a45029-264b-04b1-9d0a-3072bd3f4878", "00737", "Credito outorgado - leite esterilizado UHT (longa vida)", "Artigo 9., Anexo III, item XXIX do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "2335655f-5de4-7179-4717-7536ed0251a0", "00738", "Credito outorgado - adesivo hidroxilado - garrafas PET", "Artigo 14, Anexo III do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "3ef617fc-f132-c924-fd02-1e09ec1c352f", "00739", "Valor destinado ao Programa de Acao Cultural - PAC", "Artigo 20, Anexo III do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "bee21d04-ee7e-a3ce-ffd5-d6399aa2f799", "00740", "Recebimento de credito acumulado mediante autorizacao eletronica", "Artigo 76, II do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "fbbd18cf-ffff-050e-804f-483fbbbf6b93", "00741", "Reincorporacao de credito acumulado mediante autorizacao eletronica", "Artigo 80 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "70f4785a-d2b0-596e-5daf-34f517bd9bc9", "00742", "Valor destinado ao Programa de Incentivo ao Esporte - PIE", "Artigo 30, Anexo III do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "a73495d1-9ad5-833a-7fa6-a62c1bca80ca", "00743", "Recebimento de Credito Acumulado - Protocolo ICM 12/84", "Protocolo ICM 12/84", "0", "000027" } )
	aAdd( aBody, { "", "335748d5-4bf7-ec8e-31b6-a02e044b96cb", "00744", "Recebimento de credito de estabelecimento de Produtor Rural ou de estabelecimento de Cooperativas de Produtores Rurais mediante autorizacao eletronica", "Artigo 70-A, inc. I do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "eab508c0-f587-6103-21cd-d745c825d006", "00745", "Incorporacao de Credito por estabelecimento de Cooperativas de Produtores Rurais mediante autorizacao eletronica", "Artigo 70-F do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "80fb8c75-3a0c-b539-4c60-e74ee122ec14", "00746", "Credito oriundo de servico de comunicacao utilizado na prestacao de servico de mesma natureza a usuario localizado neste Estado, na hipotese de inexistencia de estabelecimento do prestador no territorio paulista", "Artigo 2., . 4. do Anexo XVII do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "0d76e28e-72f6-c033-0bd2-12344aed59f1", "00747", "Recebimento de Credito Simples do ICMS, a que se refere o Decreto 56.133/2010.", "Artigo 70 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "1c04ee8e-c726-9363-08b8-7b13b5532bd1", "00748", "Recebimento de credito do ICMS de estabelecimento fabricante de acucar ou etanol.", "Artigo 70-I do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "0b18d10f-465f-cf45-b52a-9ae644249110", "00799", "OUTRAS HIPOTESES - PREENCHIDA PELO CONTRIBUINTE", "PREENCHIDA PELO CONTRIBUINTE", "0", "000027" } )
	aAdd( aBody, { "", "c00d4cbc-5737-67a9-08e1-831beea62a28", "00801", "Devolucao de mercadoria oriunda de outro Estado, destinada a uso, consumo ou integracao no ativo imobilizado, ou de utilizacao de servico iniciado em outro Estado.", "Artigo 117, . 3. do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "d9d02567-dc09-1379-994d-069341fc1947", "00802", "Regularizacao de documentos fiscais em virtude de diferenca no preco, em operacao ou prestacao, ou na quantidade de mercadoria, quando a regularizacao se efetuar apos o periodo de apuracao.", "Artigo 182, III, . 2., 3 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "cc89c727-6047-8c32-4dfa-970be36cc3bf", "00803", "Lancamento do imposto, nao efetuado em epoca propria, em virtude de erro de calculo ou de classificacao fiscal, ou outro, quando a regularizacao se efetuar apos o periodo de apuracao.", "Artigo 182, IV, . 2., 3 do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "3364d71a-3def-999e-bae9-62cd204740db", "00804", "Imposto relativo O operacoes realizadas pelo sujeito passivo por substituicao fora do estabelecimento com mercadoria abrangida pela substituicao tributaria - Estorno do ICMS proprio no retorno - venda fora do estabelecim", '"Artigo 284, III, ""c"" do RICMS/00"', "0", "000027" } )
	aAdd( aBody, { "", "1ad4770a-0ba3-b531-ec4b-3daea37144d8", "00805", "Operacoes com cafe cru: imposto a ser recolhido em periodo posterior.", "Artigo 344, III do RICMS/00", "0", "000027" } )
	aAdd( aBody, { "", "3c3b377c-fdf6-58bb-0f48-02d208208427", "00806", "Imposto destacado em Nota Fiscal de remessa para venda fora do estabelecimento.", '"Artigo 434, . 4., 5, ""a"" do RICMS/00"', "0", "000027" } )
	aAdd( aBody, { "", "6917c68d-479d-cfc2-529c-e98c4c81dc00", "00899", "OUTRAS HIPOTESES - PREENCHIDA PELO CONTRIBUINTE", "PREENCHIDA PELO CONTRIBUINTE", "0", "000027" } )
	aAdd( aBody, { "", "e872eeff-b423-ba0f-f39b-8402033288db", "01499", "Deducoes - RPA - ST - RES", "PREENCHIDA PELO CONTRIBUINTE", "0", "000027" } )
	aAdd( aBody, { "", "c36e1c94-a2be-ce03-0531-1fd46231f14b", "00201", "Imposto retido em remessa para venda fora do estabelecimento.", "Artigo 284, II, .c. do RICMS/00", "1", "000027" } )
	aAdd( aBody, { "", "1655ef6f-0c92-1fb4-b315-35fdaaa777a5", "00202", "ICMS retido nas vendas efetuadas a revendedores ambulantes para revenda no sistema porta-a-porta para consumidores finais.", "Artigos 288 e 479 do RICMS/00", "1", "000027" } )
	aAdd( aBody, { "", "d40443f9-6911-e7f2-a324-3c1cb48a7358", "00299", "OUTRAS HIPOTESES - PREENCHIDA PELO CONTRIBUINTE", "PREENCHIDA PELO CONTRIBUINTE", "1", "000027" } )
	aAdd( aBody, { "", "fdebaf2e-19d7-f52c-3393-f62c01e9badd", "00399", "OUTRAS HIPOTESES - PREENCHIDA PELO CONTRIBUINTE", "PREENCHIDA PELO CONTRIBUINTE", "1", "000027" } )
	aAdd( aBody, { "", "05ed6827-75bf-9c90-2ab8-46554ec1501e", "00701", "Ressarcimento de imposto retido por nota fiscal", "Artigo 9., . 5., item 2, .a., da Portaria CAT- 17/99.", "1", "000027" } )
	aAdd( aBody, { "", "27e67c90-0831-8ada-b146-90eb0688348a", "00702", "Deducao de imposto retido - ressarcimento por deposito bancario.", "Artigo 10, . 5., item 3, .d. da Portaria CAT-17/99.", "1", "000027" } )
	aAdd( aBody, { "", "38acdd41-3e36-7032-9ae2-ae66e349d968", "00703", "Ressarcimento relativo a operacoes interestaduais com combustiveis.", "Artigo 414, . 2., do RICMS/00.", "1", "000027" } )
	aAdd( aBody, { "", "102e5ab0-237f-d5e2-2edf-48ca4f690731", "00704", "Repasse a outras unidades federadas relativo a operacoes interestaduais com combustiveis.", "Clausula Decima Primeira, . 1., do Convenio ICMS 03/99.", "1", "000027" } )
	aAdd( aBody, { "", "3d8599e1-a6a2-3673-8c8e-78d083076ac3", "00799", "OUTRAS HIPOTESES - PREENCHIDA PELO CONTRIBUINTE", "PREENCHIDA PELO CONTRIBUINTE", "1", "000027" } )
	aAdd( aBody, { "", "e0a8ab64-b106-55d7-f49f-a00dc0916d6a", "00801", "Estorno de imposto retido no retorno - venda fora do estabelecimento.", "Artigo 284, III, .d. do RICMS/00", "1", "000027" } )
	aAdd( aBody, { "", "ac8cb282-886f-384a-8866-c8840052b406", "00899", "OUTRAS HIPOTESES - PREENCHIDA PELO CONTRIBUINTE", "PREENCHIDA PELO CONTRIBUINTE", "1", "000027" } )
	aAdd( aBody, { "", "2e0e62d5-c9b1-cbe6-28ea-90e3b105db24", "01499", "Deducoes - RPA - ST - RES", "PREENCHIDA PELO CONTRIBUINTE", "1", "000027" } )

	//Verifica se o dicionario aplicado é o da DIEF-CE e da Declan-RJ
	If(AliasInDic("T30") .And. AliasInDic("T39"))
		aAdd( aBody, { "", "4f3395a3-6ccf-156d-dbb7-e8277ea09f8a", "01501", "DEDUÇÃO REFERENTE AO FDI – PROVIN", "DEDUÇÃO REFERENTE AO FDI – PROVIN", "0", "000006" } )
		aAdd( aBody, { "", "a27b118f-9ab4-c2d5-9a7d-3b20a99f945a", "01502", "DEDUÇÃO REFERENTE AO FECOP DO ICMS NORMAL", "DEDUÇÃO REFERENTE AO FECOP DO ICMS NORMAL", "0", "000006" } )
		aAdd( aBody, { "", "0afadc6f-b6fb-dc1d-c450-14b0e2e61129", "01503", "INCENTIVO FISCAL", "INCENTIVO FISCAL", "0", "000006" } )
		aAdd( aBody, { "", "935319fb-6183-1ef6-672c-d5f8bc4fad57", "01504", "FDI – TRANSFERÊNCIA DE CRÉDITO", "FDI – TRANSFERÊNCIA DE CRÉDITO", "0", "000006" } )
		aAdd( aBody, { "", "1d59c2e6-f124-d688-a5d2-fba94785db49", "01505", "CRÉDITO PRESUMIDO", "CRÉDITO PRESUMIDO", "0", "000006" } )
		aAdd( aBody, { "", "94c3a91e-8c37-2d84-1a94-398c1a1c57e8", "01506", "CRÉDITO ANTECIPADO", "CRÉDITO ANTECIPADO", "0", "000006" } )
		aAdd( aBody, { "", "5b2f63ce-3995-d710-ce09-dcb269d964eb", "01507", "CRÉDITO BENS DE ATIVO IMOBILIZADO", "CRÉDITO BENS DE ATIVO IMOBILIZADO", "0", "000006" } )
		aAdd( aBody, { "", "d479acef-6a08-89d4-4d03-ebe7c4a292df", "01508", "CRÉDITO RESTITUIÇÃO DE INDÉBITO", "CRÉDITO RESTITUIÇÃO DE INDÉBITO", "0", "000006" } )
		aAdd( aBody, { "", "a4d86d43-5f84-56fc-c4d2-8d9b78f9e0c9", "01509", "CRÉDITO ICMS A MAIS OU EM DUPLICIDADE", "CRÉDITO ICMS A MAIS OU EM DUPLICIDADE", "0", "000006" } )
		aAdd( aBody, { "", "6abe31dc-9695-18a4-4400-1eec772ea750", "01510", "CRÉDITO ICMS IMPORTAÇÃO DIFERIDO", "CRÉDITO ICMS IMPORTAÇÃO DIFERIDO", "0", "000006" } )
		aAdd( aBody, { "", "134ce7b9-7eeb-b99b-e787-31612097d472", "01511", "CRÉDITO DECORRENTE DE AUTO DE INFRAÇÃO", "CRÉDITO DECORRENTE DE AUTO DE INFRAÇÃO", "0", "000006" } )
		aAdd( aBody, { "", "4b647aec-3c1b-4595-966f-ef22a5deeeef", "01512", "ESTORNO DÉBITO REVERSÃO DE RESERVA DE TRANSFERÊNCIA", "ESTORNO DÉBITO REVERSÃO DE RESERVA DE TRANSFERÊNCIA", "0", "000006" } )
		aAdd( aBody, { "", "bbe7d145-bde9-a773-dd62-4e81471adbe2", "01513", "SALDO CREDOR PERIODO ANTERIOR", "SALDO CREDOR PERIODO ANTERIOR", "0", "000006" } )
		aAdd( aBody, { "", "f86ad855-84cd-c4f4-eac5-47ad9c6b1eb4", "01514", "CRÉDITOS EXTEMPORÂNEOS", "CRÉDITOS EXTEMPORÂNEOS", "0", "000006" } )
		aAdd( aBody, { "", "c20d3203-cbef-d282-92b8-4189f0a6618e", "01515", "SALDO DE ICMS ANTECIPADO - EPP / ME", "SALDO DE ICMS ANTECIPADO - EPP / ME", "0", "000006" } )
		aAdd( aBody, { "", "bc8d118c-7991-8f17-9584-305a867cc90b", "01516", "CRÉDITO OUTROS", "CRÉDITO OUTROS", "0", "000006" } )
		aAdd( aBody, { "", "eb4091bc-960c-9b15-9e21-b62442687d56", "01517", "ESTORNO DÉBITO OUTROS", "ESTORNO DÉBITO OUTROS", "0", "000006" } )
		aAdd( aBody, { "", "66cc6533-5914-60c3-bea8-cc3924edb3a5", "01518", "DÉBITO RESERVA TRANSFERÊNCIA DE CRÉDITO", "DÉBITO RESERVA TRANSFERÊNCIA DE CRÉDITO", "0", "000006" } )
		aAdd( aBody, { "", "e886b40d-a0d3-e75d-46c2-957c298f23fe", "01519", "DÉBITO DIFERENÇIAL DE ALÍQUOTA", "DÉBITO DIFERENÇIAL DE ALÍQUOTA", "0", "000006" } )
		aAdd( aBody, { "", "4877bd68-05dc-a004-895e-520c0c80ce05", "01520", "DÉBITO TRANSFERÊNCIA DE CRÉDITO", "DÉBITO TRANSFERÊNCIA DE CRÉDITO", "0", "000006" } )
		aAdd( aBody, { "", "654a319e-b792-4792-1f9b-a1b6ebdc5fea", "01521", "DÉBITO COMPENSAÇÃO DE DÉBITOS NA DÍVIDA ATIVA", "DÉBITO COMPENSAÇÃO DE DÉBITOS NA DÍVIDA ATIVA", "0", "000006" } )
		aAdd( aBody, { "", "94cf6cb9-fef5-9610-d451-a981cfd0f73a", "01522", "ESTORNO CRÉDITO SAÍDAS ISENTAS OU NÃO TRIBUTADAS", "ESTORNO CRÉDITO SAÍDAS ISENTAS OU NÃO TRIBUTADAS", "0", "000006" } )
		aAdd( aBody, { "", "4e966dd7-639a-fe1b-a296-8339454a0609", "01523", "ESTORNO CRÉDITO BENS DE ATIVO POR SAÍDAS NÃO TRIBUTADAS", "ESTORNO CRÉDITO BENS DE ATIVO POR SAÍDAS NÃO TRIBUTADAS", "0", "000006" } )
		aAdd( aBody, { "", "a834a062-3d45-c341-616b-32f7677142e4", "01524", "ESTORNO CRÉDITO SUFRAMA", "ESTORNO CRÉDITO SUFRAMA", "0", "000006" } )
		aAdd( aBody, { "", "a9a30b2e-cd23-f845-3e73-2c716b50d141", "01525", "ESTORNO DE CRÉDITO DE BENS DO ATIVO POR BAIXA", "ESTORNO DE CRÉDITO DE BENS DO ATIVO POR BAIXA", "0", "000006" } )
		aAdd( aBody, { "", "d09bc6d8-6097-ad28-43e7-3d9fbffbd11b", "01526", "FECOP ICMS NORMAL", "FECOP ICMS NORMAL", "0", "000006" } )
		aAdd( aBody, { "", "f197e390-7c18-653e-2f23-fcfa30a2b5fc", "01527", "DEVOLUÇÃO DE COMPRAS (SOMENTE EPP E ME)", "DEVOLUÇÃO DE COMPRAS (SOMENTE EPP E ME)", "0", "000006" } )
		aAdd( aBody, { "", "4a87aff5-a2b0-2cde-d610-332bf3fe8ead", "01528", "DIFERENÇA DE CARTÃO DE CRÉDITO", "DIFERENÇA DE CARTÃO DE CRÉDITO", "0", "000006" } )
		aAdd( aBody, { "", "965355eb-b2e4-0e5e-84f6-f68988401058", "01529", "DÉBITO OUTROS", "DÉBITO OUTROS", "0", "000006" } )
		aAdd( aBody, { "", "daa923a2-be18-9683-18cb-21fc37b7a33d", "01530", "ESTORNOS CRÉDITO OUTROS", "ESTORNOS CRÉDITO OUTROS", "0", "000006" } )
	EndIf

	If(AliasInDic("T2D"))
		aAdd(aBody, { "", "808333c3-bb9b-b3f3-2291-0cd4ad76f473", "00081", "Destaque incorreto do ICMS no documento fiscal.", "Decreto 27427/00, Livro I, artigos 32 e 33", "0", "000020"} )
		aAdd(aBody, { "", "252bed48-76cb-064e-abe7-d99719aaf203", "00082", "Ao final do prazo da operação amparada por suspensão ou não configurada a condição que a autorize (pelo remetente).", "Resolução SEFAZ 720/2014, Parte II, Anexo XIII, art. 44, inc. II, alínea b", "0", "000020"} )
		aAdd(aBody, { "", "a30bde0e-4ba4-b5be-4e50-f3a9ea16862c", "00083", "Estorno de crédito na restituição de bem arrendado.", "Convênio ICMS 4/97; Resolução 2983/98, artigo 4°", "0", "000020"} )
		aAdd(aBody, { "", "98e1ac0d-7e39-e83d-b00a-797075e4c8ba", "00085", "Imposto diferido ou suspenso exigido por ocasião da saída quando ocorrer entrada de mercadoria com diferimento ou suspensão do tributo e sem direito a crédito equivalente.", "Decreto 27427/00, Livro I, artigo 39, § único", "0", "000020"} )
		aAdd(aBody, { "", "9ecb9ac4-c28c-6757-351e-be4f44811725", "00086", "Operação com sucata e com lingotes e tarugos de metais não-ferrosos e couro curtido pelo estabelecimento industrial em relação à mercadoria entrada para industrialização", "Decreto 27427/00, Livro XII, artigo 6º, inciso IV", "0", "000020"} )
		aAdd(aBody, { "", "e241fa7e-7460-cb59-b791-f12d755f98af", "00087", "Entradas de mercadorias importadas (lançamento conjunto em outros débitos e deduções).", "Decreto 27427/00, Livro XI, artigo 9°, inciso II", "0", "000020"} )
		aAdd(aBody, { "", "a1688b92-aeff-16c7-6020-636b01fbe0a8", "00091", "Lançamento do imposto devido pelo contribuinte que calcula o valor do imposto devido com base na receita bruta na atividade de fornecimento de alimentação.", "Lei 2657/96, art.33, § 5º, inc. V; Decreto 27427/00, Livro V, Título V; Resolução SEFAZ 322/10, Resolução SEFAZ 6.410/2002, art.12", "0", "000020"} )
		aAdd(aBody, { "", "c461248a-5693-b7a8-01b8-e96af2e175b2", "00092", "Lançamento do imposto devido pelo contribuinte que calcula o valor do imposto devido com base na receita bruta na atividade de transporte aquaviário no Estado.", "Lei 2657/96, art.33, § 5º, inc. V; Decreto 27427/00, Livro V, Título IV; Resolução 6410/02, art. 12", "0", "000020"} )
		aAdd(aBody, { "", "ec3cfc3c-6794-c4d1-7b8d-4ae46ce172fe", "00093", "Compensações, utilizações e transferências de saldos credores acumulados", "Resolução SEFAZ 720/2014, Parte II, Anexo IX, artigo 3º", "0", "000020"} )
		aAdd(aBody, { "", "f61adc51-6253-126f-b8fc-f611fae35d74", "00258", "importador ou atacadista na primeira saída de fruta fresca estrangeira, exc pêra e maçã, sem isenção ou suspensão, para destinatário neste Estado (lançamento conjunto com deduções)", "Decreto 27427/00, Livro XV, artigo 41.", "0", "000020"} )
		aAdd(aBody, { "", "eae441b0-70ba-de35-6978-3b3c31e73b90", "00094", "Outros", "Outros", "0", "000020"} )
		aAdd(aBody, { "", "6a849740-bfda-ae4d-ae32-5366e510d91b", "00095", "Estorno complementar da saída tributada de bem com valor do estorno calculado no CIAP superior ao imposto destacado na NF para os bens cuja entrada ocorreu de 01/11/96 a 31/01/99", "Resolução 2921/98, artigo 8º, § 2º c/c Decreto 27427/00, Livro VI, artigo 97", "0", "000020"} )
		aAdd(aBody, { "", "8508d99a-9604-8ef0-0773-81f0ccd43065", "00096", "Estorno do crédito do ativo permanente por saídas isentas ou não tributadas e por saída ou perda para os bens cuja entrada tenha ocorrido de 01/11/1996 a 31/07/2000.", "Resolução 2921/98, artigo 7º, inciso V, item 8 c/c Decreto 27427/00, Livro I, artigo 62, incisos I e II", "0", "000020"} )
		aAdd(aBody, { "", "c1838974-f2b7-2670-d6b9-b036e42cfe84", "00097", "Estorno do crédito por integração no ativo permanente de mercadoria adquirida para industrialização ou comercialização.", "Decreto 27427/00, Livro VI, artigo 95, § 4º", "0", "000020"} )
		aAdd(aBody, { "", "98c3f890-ca81-9493-88b2-cdbad0e376a2", "00098", "Transferência de crédito de ativo permanente entre estabelecimentos da mesma empresa no Estado (pelo remetente) para os bens cuja entrada tenha ocorrido de 01/11/1996 a 31/07/2000", "Resolução 2921/98, artigo 8º, § 3º a 5º c/c Decreto 27427/00, Livro VI, artigo 97", "0", "000020"} )
		aAdd(aBody, { "", "994ebd3d-249c-e0a3-efcb-a15a003ad441", "00099", "Estorno do imposto creditado sempre que forem objeto de saída isenta as mercadorias que compõem a cesta básica.", "Decreto 32161/02, artigo 2º", "0", "000020"} )
		aAdd(aBody, { "", "4cfe857f-e1e6-b52c-b07a-4c0a0a48353d", "00101", "Mercadoria alienada por preço inferior a aquisição.", "Decreto 27427/00, Livro I, artigo 37, § 1°", "0", "000020"} )
		aAdd(aBody, { "", "e14502b1-5ca8-d978-8c43-788fcc3829a5", "00102", "Serviço ou mercadoria entrada no estabelecimento e for integrada ou consumida na industrialização, quando a saída do produto resultante não for tributada ou estiver isenta", "Decreto 27427/00, Livro I, artigo 37, inciso II", "0", "000020"} )
		aAdd(aBody, { "", "41d2b438-b751-b33a-e894-8b8a9e8cf2b7", "00103", "Serviço ou mercadoria entrada no estabelecimento e for objeto de saída ou prestação de serviço não tributada ou isenta.", "Decreto 27427/00, Livro I, artigo 37, inciso I", "0", "000020"} )
		aAdd(aBody, { "", "ab327a06-5e38-b968-2dd8-23c986faff0c", "00104", "Serviço ou mercadoria entrada no estabelecimento e gozar de redução da base de cálculo na operação ou prestação subseqüente.", "Decreto 27427/00, Livro I, artigo 37, inciso V", "0", "000020"} )
		aAdd(aBody, { "", "efaad5fb-3050-a87e-e2a3-8b3be8297626", "00105", "Serviço ou mercadoria entrada no estabelecimento e vier a perecer, deteriorar-se ou extraviar-se.", "Decreto 27427/00, Livro I, artigo 37, inciso IV e Livro VI, artigo 116, §1º", "0", "000020"} )
		aAdd(aBody, { "", "31f1bb10-6db3-f7a2-0ac0-b1ba737cc001", "00106", "Serviço ou mercadoria entrada no estabelecimento vier a ser utilizada em fim alheio à atividade do estabelecimento.", "Decreto 27427/00, Livro I, artigo 37, inciso III", "0", "000020"} )
		aAdd(aBody, { "", "9b11e495-c7dc-b86e-8f9e-70a59d5558fe", "00108", "Crédito indevido por documento inidôneo (lançamento conjunto em estorno de crédito e deduções).", "Lei 2657/96, artigo 34 Resolução 365/78, artigo 3°", "0", "000020"} )
		aAdd(aBody, { "", "88071228-7696-bc8a-9b10-d4ddd10fb67b", "00109", "Estorno da restituição do imposto retido pago por substituição tributária correspondente ao fato gerador que não se realizar sobrevindo decisão contrária irrecorrível ao pedido", "Decreto 27427/00, Livro II, artigo 19, § 3°", "0", "000020"} )
		aAdd(aBody, { "", "d419bea8-b6cc-e0cf-37ec-abe0941dfe82", "00111", "Estorno do saldo credor dos contribuintes enquadrados no regime apuração do ICMS com base receita bruta (fornecimento alimentação, indústria sal e transporte aquaviário).", "Resolução 6410/2002, art. 12, § único", "0", "000020"} )
		aAdd(aBody, { "", "bbb970b6-90c9-12ee-679a-56268854e774", "00252", "Estorno do crédito pelo adquirente de mercadoria de ME/EPP no Simples Nacional pela soma do imposto creditado no mês (lançamento conjunto em outros créditos e estornos de créditos)", "Res. SEFAZ 194/09, artigo 2°, § 2º", "0", "000020"} )
		aAdd(aBody, { "", "bb33e199-e464-f6fe-7804-dcd9c896b8bc", "00253", "Estorno do crédito indevido ou a maior pelo adquirente de mercadoria de ME/EPP no Simples Nacional", "Res. SEFAZ 194/09, artigo 3°, § 1º, inciso I", "0", "000020"} )
		aAdd(aBody, { "", "2cf2ab56-565a-e4fa-443e-7b593e08bc6b", "00259", "Estorno do crédito do imposto do volume de AEAC na mistura com gasolina ou B100 com oleo diesel para contribuintes que efetuarem operações interestaduais com produtos da mistura", "Decreto 27427/00, livro IV, Art.19 §9º", "0", "000020"} )
		aAdd(aBody, { "", "4f6044bb-0363-06fd-95c0-dc535b5c5aa9", "00260", "fornecedores com saídas diferidas nas op internas com peças, partes, máq, equip, apare e acessóri utilizados como insumos na construção de sistema flutuante de produção de petróleo", "decreto 35220/04, art.1º §5º", "0", "000020"} )
		aAdd(aBody, { "", "2f4535c2-5026-897d-9abf-2b03a2f4a6c0", "00112", "Outros", "Outros", "0", "000020"} )
		aAdd(aBody, { "", "09582289-79e0-f9c5-f4e1-872a50e19b75", "00113", "Credito de ativo permanente e diferencial de alíquota do ativo permanente em parcelas para os bens cuja entrada tenha ocorrido de 01/02/1999 a 31/07/2000.", "Lei 3188/99, artigo 2º c/c Decreto 27427/00, Livro I artigo 62, inciso II", "0", "000020"} )
		aAdd(aBody, { "", "39898729-d4f4-dee6-1063-c109c224695c", "00114", "Credito de ativo permanente e diferencial de alíquota do ativo permanente em parcelas para os bens cuja entrada tenha ocorrido a partir de 01/08/2000.", "Lei 2657/96, artigo 33, § 7; Decreto 27427/00, Livro VI, artigo 92, inciso II, item 4-h", "0", "000020"} )
		aAdd(aBody, { "", "d65cce7a-d982-a89e-997d-006e56f47002", "00115", "Transferência de crédito de ativo permanente entre estabelecimentos da mesma empresa no Estado (pelo destinatário) para bens cuja entrada tenha ocorrido de 01/11/96 a 31/01/99", "Resolução 2921/98, artigo 8º, § 6º c/c Decreto 27427/00, Livro VI, artigo 97", "0", "000020"} )
		aAdd(aBody, { "", "69366f78-1a13-a119-6039-328827f0dcfe", "00119", "Destaque incorreto do ICMS no documento fiscal.", "Decreto 27427/00, Livro I, artigos 32 e 33", "0", "000020"} )
		aAdd(aBody, { "", "0b350a19-044c-8fbe-855d-c7f9d4da2aa7", "00120", "Crédito do ICMS oriundo da execução de projetos do Programa Luz no Campo para concessionárias de energia.", "Lei 3393/00; Decreto 26788/00; Resolução 4468/00, artigo 1°", "0", "000020"} )
		aAdd(aBody, { "", "2546f736-f7b7-db22-38f3-bb1a9ea50fca", "00121", "Crédito do imposto do valor dos direitos autorais pagos a autores e artistas nacionais ou a empresas.", "Convênio ICMS 23/90 c/c prorrogações", "0", "000020"} )
		aAdd(aBody, { "", "95cd2d7b-9894-c714-28f0-15e4f718a138", "00122", "Crédito em operação interna tributada antecedente à exportação com metais e pedras preciosas e semipreciosas.", "Convênio ICMS 108/96", "0", "000020"} )
		aAdd(aBody, { "", "6c839954-6a46-8873-42be-414bb80aca40", "00123", "Crédito presumido aos estabelecimentos de serviço de transporte.", "Convênio ICMS 106/96", "0", "000020"} )
		aAdd(aBody, { "", "8a41e34a-4eca-b432-486d-1cec6cbc8439", "00124", "Crédito presumido do ICMS correspondente a 13% (treze por cento) do valor da operação, nas saídas internas promovidas pelo fabricante produtos cerâmicos para construção.", "Decreto 25404/99, artigo 1°, § 1°", "0", "000020"} )
		aAdd(aBody, { "", "dd5d9cf6-da63-2746-2121-ee7fb765e973", "00125", "Crédito presumido do ICMS, vinculado à realização de projeto cultural.", "Lei 1954/92; Decreto 44.013/13; Resolução 6313/01, artigo 8°", "0", "000020"} )
		aAdd(aBody, { "", "1d40b736-f985-e6d6-5f20-6976af9148e5", "00126", "Crédito presumido leite adquirido no Estado do Rio de Janeiro, diretamente do produtor ou através de usinas de laticínios legalmente estabelecidas no Estado.", "Decreto 29042/01, artigo 1°", "0", "000020"} )
		aAdd(aBody, { "", "99d167bc-9e6b-250b-30a2-b84dd72dc81b", "00127", "Crédito presumido leite adquirido no Estado do RJ, do produtor ou através de usinas de laticínios legalmente estabelecidas no Estado p/utilização no PROGRAMA DE SAUDE ANIMAL", "Decreto 29042/01, artigo 4°", "0", "000020"} )
		aAdd(aBody, { "", "569e12dd-10f7-e6e3-e904-85cf9f617b75", "00128", "Crédito presumido para contribuintes c/CAE principal de extração de minerais não metálicos não preciosos, trabalhos em mármore e outras pedras; aparelhamento de pedras p/construção", "Decreto 25666/99, artigo 1°, § 2°", "0", "000020"} )
		aAdd(aBody, { "", "411c8fec-7483-d1da-e413-412f299ad6c8", "00129", "Crédito presumido serviço transporte aéreo operação interna.", "Convênio ICMS 120/96", "0", "000020"} )
		aAdd(aBody, { "", "e9951cb4-65c8-aac1-60d0-c685c6d35914", "00130", "Ao final do prazo da operação amparada por suspensão ou não configurada a condição que a autorize (pelo destinatário).", "Decreto 27427/00, Livro VI, artigo 168, § 4º", "0", "000020"} )
		aAdd(aBody, { "", "29f65250-ad53-a5b2-1493-bc2f31aae6f4", "00131", "Correção monetária do recolhimento feito espontaneamente a maior que o valor do imposto devido.", "Decreto-lei 5/75, artigo 185; Resolução 2455/94, artigo 17, inciso I-b", "0", "000020"} )
		aAdd(aBody, { "", "282ed1ea-853b-81dc-b949-1cb1c6b59e98", "00132", "Recolhimento feito espontaneamente a maior que o valor do imposto devido.", "Decreto-lei 5/75, artigo 183; Resolução 2455/94, artigo 2°", "0", "000020"} )
		aAdd(aBody, { "", "0d020795-d95c-5c8a-e00a-81d437cb11c5", "00133", "Operações ou prestações submetidas ao regime de diferimento em decorrência de decisão exarada em processo.", "Resolução 2985/98, artigo 5º, inciso II", "0", "000020"} )
		aAdd(aBody, { "", "b75dc308-a151-2c54-b8ae-79ec354148ae", "00134", "Credito do frete pago pelo remetente/destinatário contrib do ICMS quando realizado por empresa de transporte de fora do estado e não inscrita no CADERJ ou autônomo.", "Decreto 27427/00, Livro IX, artigo 82, inciso II-1 c/c Lei 2657/97, artigo 33, § 2º", "0", "000020"} )
		aAdd(aBody, { "", "f6a1f6b3-f269-60af-637e-d82cb30aaaa8", "00135", "Operação com sucata e com lingotes e tarugos de metais não-ferrosos e couro curtido pelo estabelecimento industrial em relação à mercadoria entrada p/utilização em industrialização", "Decreto 27427/00, Livro XII, artigo 6º, inciso IV", "0", "000020"} )
		aAdd(aBody, { "", "59c0a062-b8e4-270d-16a5-1f2f995bdfd0", "00136", "Operação com sucata, fragmento, retalho ou resíduo de materiais, lingotes e tarugos de metais não-ferrosos, couro, pele, sebo, osso, chifre e casco na saída do Estado pelo remet", "Decreto 27427/00, Livro XII, artigo 7º, inciso II-2", "0", "000020"} )
		aAdd(aBody, { "", "3819c919-78e7-410a-1240-990fe81c9732", "00137", "Operação com sucata, lingotes e tarugos de metais não-ferrosos, couro, pele, sebo, osso, chifre e casco na entrada no RJ com regime especial p/ Nota Fiscal sem guia de recolhimento", "Decreto 27427/00, Livro XII, artigo 7º, § 1º", "0", "000020"} )
		aAdd(aBody, { "", "0713aca8-b4ee-9a38-a85d-50d86a94aa6f", "00140", "Na saída de mercadoria para utilização em processo industrial, realizada por distribuidor ou atacadista que a tenha recebido com imposto retido.", "Decreto 27427/00, Livro II, artigo 29, § 1º", "0", "000020"} )
		aAdd(aBody, { "", "34850dc8-a84b-cbfb-c834-2dbf5e7ef9b9", "00142", "Restituição do imposto retido pago por força da substituição tributária correspondente ao fato gerador que não se realizar.", "Decreto 27427/00, Livro II, artigo 19, § 1°", "0", "000020"} )
		aAdd(aBody, { "", "5c872773-13c0-b3ca-390e-d63dc6933032", "00144", "Recebimento de saldos credores acumulados em decorrência de operações ou prestações destinadas ao exterior.", "Resolução 6410, artigo 19 c/c Portaria SUCIEF 11/08, artigo 2º", "0", "000020"} )
		aAdd(aBody, { "", "cf412f15-5c2a-e08e-97fc-0097797c0587", "00195", "Crédito do ICMS materializado na Guia de Controle Fiscal (GCF), vinculado à aquisição de gado por estabelecimento com atividade industrial ou comercial", "Decreto 27427/00, Livro XV, art. 12, § 4º", "0", "000020"} )
		aAdd(aBody, { "", "fda73d6f-ec4f-a207-9fc3-5b96a814017a", "00196", "Crédito relativo ao imposto diferido ou amparado com dilação de prazo para empresa do Polo Gás Químico ou com projeto independente de termogeração de energia elétrica a gás", "Decreto 26789/00 e Resolução 6481/02, art. 7º, parágrafo único", "0", "000020"} )
		aAdd(aBody, { "", "78334678-6e6b-2b85-f323-723a9cf7fe4d", "00216", "Crédito na devolução ou remessa interestadual de mercadoria sujeita à subst. tributária nas operações internas, cujo imposto st foi pago antecip. ou retido e pago pelo adquirente", "Res. SER 119/04, art. 4º, inc. III", "0", "000020"} )
		aAdd(aBody, { "", "04894145-58e1-52cb-f122-41b3fda74793", "00217", "Crédito do destinatário de nota fiscal de ressarcimento do imposto retido do fornecedor do óleo diesel destinados a embarcações pesqueiras nacionais", "Res. SEFCON 3803/00, art. 10, § 2º, item 2", "0", "000020"} )
		aAdd(aBody, { "", "0192d449-6370-4685-245a-46ede61a0a79", "00218", "Crédito do imposto relativo à entrada de remessa, em operação interestadual, de mercadoria cujo imposto já tenha sido objeto de retenção anterior", "Decreto 27427/00, Livro II, artigo 20, Nota", "0", "000020"} )
		aAdd(aBody, { "", "4c12bb60-2d8e-6ef1-a85c-1cbe7da123a4", "00219", "Crédito presumido equivalente a carga tributária efetiva de 3% nas saídas pela empresa ind. ou com. atacadista estab RJ de produtos a que se referem o artigo 1º do Decreto 33981/03", "Decreto 33981/03, artigos 1º e 4º", "0", "000020"} )
		aAdd(aBody, { "", "8816c03a-fddc-f1c2-adf5-274e79ec944e", "00220", "Crédito presumido equivalente a carga tributária efetiva de 0% nas saídas pela empresa sede industrial estabelecida RJ de produtos a que se referem o artigo 1º do Decreto 33981/03", "Decreto 33981/03, artigos 3º e 4º", "0", "000020"} )
		aAdd(aBody, { "", "07b6d1be-3e4f-e96b-88fc-26acc9a01752", "00221", "Crédito presumido conf art. 8º do Dec 33976/03 nas saídas pela indústria estabelecida RJ de derivados prod químicos e petroquím básicos e intermed produzidos em Território Nacional", "Decreto 33976/03, artigo 7º, inciso II", "0", "000020"} )
		aAdd(aBody, { "", "4f431e26-c32d-dcfa-d583-d7e46c544b63", "00222", "Crédito presumido de 2% das vendas pela Central de Distribuição nas saídas interestaduais pelas empresas enquadradas no RIOLOG", "Lei 4173, artigo 3º, inciso I", "0", "000020"} )
		aAdd(aBody, { "", "ff816b50-69c8-45fb-6932-7becd47ae9c0", "00223", "Crédito presumido de 2% das compras de mercadorias comercializadas pela Central de Distribuição nas entradas interestaduais pelas empresas enquadradas no RIOLOG", "Lei 4173, artigo 3º, inciso II", "0", "000020"} )
		aAdd(aBody, { "", "b74e1970-910c-7cd5-92ed-5b9b2025cbc6", "00224", "Crédito presumido de 2% das transferências nas entradas por transferência de estabelecimento indutrial de outra UF pelas empresas enquadradas no RIOLOG", "Lei 4173, artigo 3º, inciso III", "0", "000020"} )
		aAdd(aBody, { "", "bc770ff1-270a-3089-58d3-212e8defcb8d", "00225", "Crédito presumido de 2% das compras nas operações internas de entrada dos produtos relacionados no Art. 3º, inciso IV da Lei 4173/03 pelas empresas enquadradas no RIOLOG", "Lei 4173, artigo 3º, inciso IV", "0", "000020"} )
		aAdd(aBody, { "", "dd15d700-0ee2-7dcf-a3d0-aa4868bcf332", "00226", "Crédito presumido de 6% das compras internas de prod agropec RJ, de produtores rurais, pessoa física, para processam agro-industrial pelas empresas com investim >= 20000 UFIRs-RJ", "Lei 4177, artigo 2º, inciso I", "0", "000020"} )
		aAdd(aBody, { "", "95b71082-c9af-df54-e29e-48e9382c5a62", "00227", "Crédito presumido de 4% das compras interestaduais de prod agropecuários, produzidos em outros Estados, para processam agro-industrial pelas empresas com investim >= 20000 UFIRs-RJ", "Lei 4177, artigo 2º, inciso II", "0", "000020"} )
		aAdd(aBody, { "", "fa63d8f7-f7d8-a599-efe3-0f693abc35db", "00228", "Crédito presumido do ICMS equivalente ao valor da alíquota nas saídas interestaduais e internas dos produtos reciclados por estab industrial das empresas destinadas à reciclagem", "Lei 4178, artigo 1º, inciso I", "0", "000020"} )
		aAdd(aBody, { "", "59642386-22fc-1cb5-917f-b7529af925ef", "00229", "Crédito presumido de empresa fluminense que realizar operações de saída a que se referem os artigos 1º e 2º da Res. SER 82/04", "Res. SER 82/04, art. 3º", "0", "000020"} )
		aAdd(aBody, { "", "234a2495-807e-2b0f-b0cf-d1d0645c5039", "00230", "Crédito presumido de 7% nas saídas internas industrializadas no RJ pelo fabricante localizado RJ de aguardente de cana e de melaço", "Decreto 36111/04, artigo 5º, inciso I", "0", "000020"} )
		aAdd(aBody, { "", "47b1240b-5389-1fc7-3c76-3e8e130362bd", "00231", "Crédito presumido de 14% nas saídas internas industrializadas no RJ pelo fabricante localizado RJ de bebidas alcoólicas da posição 2204 a 2208 da NBM/SH exceto cerveja e chope", "Decreto 36111/04, artigo 5º, inciso II", "0", "000020"} )
		aAdd(aBody, { "", "bc87b2ac-19a3-90a6-39fc-e3e86f37f77a", "00232", "Crédito presumido de 12% das saídas internas ou interestad para não contribuinte à empresa industrial com sede RJ com as mercadorias do Anexo ao Decreto 36376/04", "Decreto 36376/04, artigo 2º", "0", "000020"} )
		aAdd(aBody, { "", "40d4887b-d378-a346-7e9d-b033a24ace7c", "00233", "Crédito presumido equiv a carga tribut efetiva de 12% nas oper interestad de saída para não contrib pela empresa industrial estab RJ de prod identif no artigo 1º do Dec 36451/04", "Decreto 36451/04, artigo 11", "0", "000020"} )
		aAdd(aBody, { "", "a60a8a5a-da41-7874-1294-c7a0dca4e24a", "00234", "Crédito presumido de 4% da Nota Fiscal ao industrial da cadeia farmacêutica na saída interna entre contrib de mercad com destino a atacadista, central de distribuição e varejista", "Decreto 36450/04, artigo 4º", "0", "000020"} )
		aAdd(aBody, { "", "6add90bc-a2de-a3d8-e722-d1b329756903", "00239", "Crédito presumido de 6% da N Fiscal ao estab industr, central de distrib ou atacadista, com sede RJ, na saída interestad para consumid final de vendas por Internet e telemarketing", "Decreto 36449/04, artigo 1º", "0", "000020"} )
		aAdd(aBody, { "", "cd93e175-518f-8fa9-9c0c-bada67bd9deb", "00240", "Crédito presumido equiv a carga tribut efetiva de 7% nas oper internas de saída pela empresa industrial estab RJ de produtos a que se referem os artigos 1º e 3º do Decreto 36452/04", "Decreto 36452/04, artigos 1º, 3º e 5º", "0", "000020"} )
		aAdd(aBody, { "", "9fb9b82f-4632-2b1c-db18-cd70eb6e61c5", "00241", "Crédito presumido equiv a carga tribut efetiva de 12% nas oper interestad de saída para não contrib pela empresa industrial estab RJ de prod identif nos art 1º e 3º do Dec 36452/04", "Decreto 36452/04, artigos 2º, 3º e 5º", "0", "000020"} )
		aAdd(aBody, { "", "bbd3ee8e-4ae6-ad66-7361-7a42ab290c82", "00242", "Crédito presumido equivalente ao débito de operações interestaduais com os produtos referidos no Decreto 36279/04", "Decreto 36279/04, artigo 10, com redação do Decreto 37605/05", "0", "000020"} )
		aAdd(aBody, { "", "0fdbc032-5a51-3e4f-b594-6e24daa8f88b", "00243", "Crédito presumido de 7% nas oper interestad de saída destinad a não contribuintes do imposto pelas empresas enquadradas de produtos a que se referem o artigo 1º do Decreto 37255/05", "Decreto 37255/05, artigo 3º", "0", "000020"} )
		aAdd(aBody, { "", "00638fba-2ec7-0f8f-6535-dc78f5d6079c", "00244", "Crédito presumido equivalente ao débito decorrente das operações interestaduais de saída pelas empresas enquadradas de produtos a que se referem o artigo 1º do Decreto 37188/05", "Decreto 37188/05, artigo 2º", "0", "000020"} )
		aAdd(aBody, { "", "0ba9c9d9-ed03-8d0c-1862-edb102a68986", "00245", "Crédito presumido de 7% nas operações internas de saída pelas empresas enquadradas de bens a que se referem o artigo 1º do Decreto 37270/05", "Decreto 37270/05, artigo 2º", "0", "000020"} )
		aAdd(aBody, { "", "abea0503-84c3-b21b-19a4-4786be33f1e2", "00246", "Crédito presumido nas operações interestaduais de forma que a incidência do imposto resulte no percentual de 7% sobre o valor das operações a que se referem o Decreto 38938/06", "Decreto 38938/06, artigo 7º", "0", "000020"} )
		aAdd(aBody, { "", "fa234c81-1c91-1822-1e20-67e01ee6f8c2", "00247", "Crédito de substituto do imposto destac no doc fiscal rel à aquis de mercadoria de empr comercial atacadista que realizar oper suj subst tributária relac no art. 1º do Dec.40016/06", "Decreto 40016/06, artigo 4º, inciso IV", "0", "000020"} )
		aAdd(aBody, { "", "c17a2ce3-afbc-5e95-54cd-adfb5cb6005d", "00248", "Crédito presumido de ICMS sobre o valor do faturamento incremental", "Decreto 39784/06, artigo 2º, inciso III", "0", "000020"} )
		aAdd(aBody, { "", "d589ac1d-83e4-4ef9-7b10-82ac74b1b4b4", "00249", "Crédito presumido de ICMS equivalente ao débito das operações sobre o faturamento incremental na produção de risers até 2020 para as linhas de fabricação e produção de risers", "Decreto 40478/06, artigo 1º, inciso III", "0", "000020"} )
		aAdd(aBody, { "", "c08d8590-f86f-8043-f3cd-fb288513c4d8", "00251", "Crédito pelo adquirente de mercadoria de ME/EPP no Simples Nacional pelo somatório do imposto creditado no mês (lançamento conjunto em outros créditos e estornos de créditos)", "Res. SEFAZ 194/09, artigo 2°, § 2º", "0", "000020"} )
		aAdd(aBody, { "", "b4250f0d-1df2-bdc0-7244-3618521ede2c", "00261", "Imposto calculado na saída interna de óleo diesel, GLP e GLGN promovida por distribuidor, destinado a estabelecimento fabricante para utilização em processo industrial.", "Decreto 27.427/00, livro IV, Art. 46 §1º", "0", "000020"} )
		aAdd(aBody, { "", "89eafd1d-45e8-285a-0412-3e05719e4df4", "00262", "Diferença entre as parcelas recolhidas até o dia 5 e o imposto devido, no período seguinte ao do período de apuração em questão por estabelecimentos de empresa de telecomunicações.", "Decreto 27427/00, Livro X, artigo 9º, §3º", "0", "000020"} )
		aAdd(aBody, { "", "fa12db88-7e2e-e8db-9395-8d5218f3a922", "00263", "Diferença entre as parcelas recolhidas até o dia 5 e o imposto devido, no período seguinte ao período em questão pelos contribuintes em ato do Secretário de Fazenda (Resol.393/11).", "Decreto 31235/02 art. 1º §4º", "0", "000020"} )
		aAdd(aBody, { "", "c6da761d-6a5c-5f8b-d334-f0e1c2c82151", "00264", "Créd presumido de ICMS de forma que a incidência do imposto resulte em 7%, pelo estabelecimento ind, localizado no Estado do RJ, que realizar op de saída com embarcações náuticas.", "Decreto 41681/09", "0", "000020"} )
		aAdd(aBody, { "", "8f3ef2ea-7e8c-0d76-1b93-ae28555621b1", "00265", "Créd presumido de forma que a carga tribut equivalha 2%, por indústria, com. atacadista, centro de distribuição, no RJ que realize saída com prod de informática e eletroeletrônico.", "Decreto 42649/10, art.1º e art.3º", "0", "000020"} )
		aAdd(aBody, { "", "20ace66a-b81c-7851-222d-adaf8a5b7e96", "00266", "Créd presumido de forma que a carga tribut equivalha 0%, por empresa industrial, cuja sede estabelecida no RJ, que realizar saída com produtos de informática e eletroeletrônicos .", "Decreto 42649/10, art.2º e art.3º", "0", "000020"} )
		aAdd(aBody, { "", "64bad3ad-dad8-80d2-3350-9d3bbfc290d7", "00267", "Créd presumido em decorrência da aquisição de equipamentos necessários à emissão de NFe, caso esteja localizado em logradouro a que se refere o artigo 5º do Decreto 42.855/11.", "Decreto 42.855/11 art.1º §7º", "0", "000020"} )
		aAdd(aBody, { "", "71e096be-860c-572c-6e2a-d666ba83a5c1", "00268", "Créd presumido, por estabelecimento industrial, localizado no RJ, que realizar saída interestadual com pescado processado, industrializado neste estabelecimento fluminense.", "Decreto 43.771/12, art. 1º e 3º", "0", "000020"} )
		aAdd(aBody, { "", "621a2535-9141-ce38-5942-faf9eb71948b", "00269", "Créd presumido de 2 % da venda de saída interestadual ao estab atacadista e à central de distrib integrados à cadeia farmacêutica, dos produtos do Anexo Único do Decreto 36450/04.", "Decreto 36450/04, Art.9-A", "0", "000020"} )
		aAdd(aBody, { "", "cf4ca30d-e9fc-9c8d-232a-d484398c7c9c", "00270", "Crédito presumido de 06% (seis por cento) ao estabelecimento varejista que realize operação de que trata o art. 1.º do decreto 36449/04.", "Decreto 36449/04, artigo 1ºA", "0", "000020"} )
		aAdd(aBody, { "", "23feb066-253a-a7c9-2a31-91ecbd65e399", "00271", "Crédito relativo à compensação de débitos de ICMS, apurados mensalmente pelas concessionárias de serviços públicos, com dívidas do Estado.", "Lei n° 7.019/15 e Resolução SEFAZ 940/15, art. 2º", "0", "000020"} )
		aAdd(aBody, { "", "5244ee7f-888e-d399-2966-1be93444106b", "00145", "Outros", "Outros", "0", "000020"} )
		aAdd(aBody, { "", "1f2092b2-ad72-b68c-aede-686708c784b9", "00146", "Débito do imposto com valor superior ao correto feito nos livros fiscais pelo valor do destaque e o pagamento do respectivo período de apuração ainda não houver sido realizado", "Decreto 27427/00, Livro I, artigo 33, inciso II, item 2", "0", "000020"} )
		aAdd(aBody, { "", "78b33fba-8585-d393-68fb-36fabf193a1f", "00147", "Mercadoria inutilizada ou perdida após sua saída do estabelecimento e sendo o caso de estorno de crédito", "Decreto 27427/00, Livro VI, artigo 117, inciso II", "0", "000020"} )
		aAdd(aBody, { "", "23dc8505-06cb-8ad8-38c8-1386bad4bc58", "00148", "Outros", "Outros", "0", "000020"} )
		aAdd(aBody, { "", "e5d1ba0a-ee0c-6a62-b0a3-57c4f69d8ad6", "00149", "Destaque incorreto do ICMS no documento fiscal.", "Decreto 27427/00, Livro I, artigos 32 e 33", "0", "000020"} )
		aAdd(aBody, { "", "ceea1046-f674-ecd1-7a8f-23960b754520", "00150", "Nota fiscal avulsa com operação tributável.", "Decreto 27427/00, Livro VI, artigo 44", "0", "000020"} )
		aAdd(aBody, { "", "35ddca4f-ed50-5e96-a596-86fa933500c8", "00153", "Crédito indevido por documento inidôneo (lançamento conjunto em estorno de crédito e deduções).", "Lei 2657/96, artigo 34 Resolução 365/78, artigo 3°", "0", "000020"} )
		aAdd(aBody, { "", "2f9435e8-2cec-f79d-d193-73fccf0495eb", "00154", "Recolhimento antecipado.", "Decreto 27427/00, Livro I, artigo 27", "0", "000020"} )
		aAdd(aBody, { "", "b438c2ef-815c-a0e4-4fda-30eee712c6c5", "00155", "Entradas de mercadorias importadas (lançamento conjunto em outros débitos e deduções).", "Decreto 27427/00, Livro XI, artigo 9°, inciso II", "0", "000020"} )
		aAdd(aBody, { "", "133c1ee7-9340-1b9e-c94a-0010795d445f", "00157", "Compensação do ICMS da liberação de financiamento do FUNDES.", "Lei 2823/97; Dec. 25980/00; Resol. 3563/00, art. 2°, § único; Resol. 6410/02, artigo 10", "0", "000020"} )
		aAdd(aBody, { "", "ae14f681-cb04-6db7-5995-1fba8a384ac7", "00201", "Adicional relativo ao FECP - Fundo Estadual de Combate à Pobreza e às Desigualdades Sociais", "Lei 4056/02; Decreto 32646/03; Resolução 6556/03, art. 2º", "0", "000020"} )
		aAdd(aBody, { "", "a3f7befe-ad08-6b1a-d26b-08f7bb9668b0", "00250", "Benefício de 95% das saídas de animais vivos ou abatidos de que trata o artigo 6º da Lei nº 4177/03 para produtor rural, agroindústrias e indústrias de prod agropec semiprocessados", "Lei 4177, artigo 6º; Res. SER 112/04, art. 4º", "0", "000020"} )
		aAdd(aBody, { "", "8abecd87-eac7-a1e9-7d2c-4c14118f841e", "00254", "Escrituração do imposto recolhido do crédito indevido ou a maior pelo adquirente de mercadoria de ME/EPP no Simples Nacional", "Res. SEFAZ 194/09, artigo 3°, § 1º, inciso III", "0", "000020"} )
		aAdd(aBody, { "", "a7a27c7f-39e5-3f41-cede-37335345dd4a", "00272", "Importador ou atacadista na primeira saída de fruta fresca estrang, exc pêra e maçã, sem isenção ou suspensão, para destin localiz neste Estad (lanç em conjunto com outros débitos)", "Decreto 27427/00, Livro XV, artigo 41, parágrafo único", "0", "000020"} )
		aAdd(aBody, { "", "678981f4-ddb7-3ecf-8bcd-2ed6b5b8dec7", "00273", "Soma das parcelas do imposto relativo às operações do mês pagos nos dias 10, 20 e último dia útil do próprio mês pelos contribuintes do Decreto 35219/04.", "Decreto 35219/04, art.1º §1º", "0", "000020"} )
		aAdd(aBody, { "", "79c0f344-26bf-58ee-2399-b3b789e3d7b1", "00158", "Outros", "Outros", "0", "000020"} )
		aAdd(aBody, { "", "f0fc585c-fb55-3299-5aa0-78387d861c2a", "00164", "Saídas internas de gêneros alimentícios realizadas na Bolsa de Gêneros Alimentícios do Estado do Rio de Janeiro", "Decreto 27857/01, artigo 1º", "0", "000020"} )
		aAdd(aBody, { "", "009829db-b0bf-2e0c-c056-08bd4a9cface", "00165", "Nas aquisições em operação interna de gêneros alimentícios por intermédio da Bolsa de Gêneros Alimentícios do Estado do RJ na proporção das aquisições no total das entradas", "Decreto 27857/01, artigo 2º", "0", "000020"} )
		aAdd(aBody, { "", "b526bbb5-813b-4a1f-fbe1-7656c28c1ff3", "00167", "Outros", "Outros", "0", "000020"} )
		aAdd(aBody, { "", "47f5d23e-b82d-82f7-d94d-23b61eb397e7", "00169", "Diferencial de alíquota uso e consumo", "", "0", "000020"} )
		aAdd(aBody, { "", "a6f90ba0-f451-35b1-f18c-6c68a42b940d", "00170", "Diferencial de alíquota ativo fixo", "", "0", "000020"} )
		aAdd(aBody, { "", "565770df-a757-6ff1-fd73-d3ebf132afd1", "00194", "Diferencial de alíquota na utilização de serviço cuja prestação iniciou em outra UF e não vinculada à operação ou prestação subseqüente alcançada pela incidência do imposto", "", "0", "000020"} )
		aAdd(aBody, { "", "07248091-93d1-1891-f748-956e94bb7664", "00206", "Imposto não retido de mercadoria recebida sujeita à substituição tributária sem que a retenção ou pagamento do ICMS tenha sido efetuado pelo remetente ou transportador", "", "0", "000020"} )
		aAdd(aBody, { "", "ccd2048a-0217-9ca1-d277-1efb5b9619ff", "00207", "ICMS pela importação", "", "0", "000020"} )
		aAdd(aBody, { "", "d3d0edf1-427f-6710-c8ac-ad37d9d6f2ae", "00208", "FECP referente às operações e prestações internas", "", "0", "000020"} )
		aAdd(aBody, { "", "8c8616ae-a725-4f79-b042-1526741cfdcf", "00209", "FECP referente à importação", "", "0", "000020"} )
		aAdd(aBody, { "", "8beb9e0b-956e-9560-99f6-bc017c366039", "00210", "FECP referente ao diferencial de alíquotas", "", "0", "000020"} )
		aAdd(aBody, { "", "2e9527ee-73c0-38b6-5a8a-8bfb11dd57dc", "00211", "FECP em razão da substituição tributária em operações internas", "", "0", "000020"} )
		aAdd(aBody, { "", "91d92f42-226c-98ce-8926-2f8ced731732", "00159", "Outros", "Outros", "0", "000020"} )
		aAdd(aBody, { "", "803dedc0-b58c-2a0a-6425-51c5a2018ad0", "00160", "Outros", "Outros", "0", "000020"} )
		aAdd(aBody, { "", "e1ba6b8e-8f35-d590-dcb4-e0b6445d3868", "00214", "Crédito do ICMS anteriormente retido por responsável, relativo à devolução de mercadoria sujeita à substituição tributária", "Res. SER 119/04, art. 5º, inc. II, alínea b", "0", "000020"} )
		aAdd(aBody, { "", "27fd053d-11da-b8e2-bc88-245c72085b4f", "00275", "Crédito relativo à compensação de débitos de ICMS, apurados mensalmente pelas concessionárias de serviços públicos, com dívidas do Estado.", "Lei n° 7.019/15 e Resolução SEFAZ 940/15, art. 2º", "0", "000020"} )
		aAdd(aBody, { "", "e25bdeca-d961-b7dc-0f44-c965c3574cca", "00161", "Outros", "Outros", "0", "000020"} )
		aAdd(aBody, { "", "33c28478-6ee3-e488-68da-25a20a653e59", "00215", "Anulação correspondente à remessa para outro estado de mercadoria sujeitas à substituição tributária, cujo ICMS foi retido por responsável", "Res. SER 119/04, art. 5º, inc. II, alínea c", "0", "000020"} )
		aAdd(aBody, { "", "f9c86b09-6d35-21c1-c7d6-412f56532aaf", "00162", "Outros", "Outros", "0", "000020"} )
		aAdd(aBody, { "", "f8463a87-2215-a948-21d8-c65e356510f2", "00202", "Adicional relativo ao FECP Fundo Estadual de Combate à Pobreza e às Desigualdades Sociais", "LEI 4056/02; Decreto 32646/03; Resolução 6556/03, art. 2º", "0", "000020"} )
		aAdd(aBody, { "", "90ab012d-a697-b1b1-0206-ed68f9f4c060", "00163", "Outros", "Outros", "0", "000020"} )
		aAdd(aBody, { "", "511244e0-a8b7-f9a9-4c5d-c2b731da0f0d", "00168", "Outros", "Outros", "0", "000020"} )
	EndIf
	aAdd(aBody, { "", "4a683a3a-18a5-3dfc-77fa-2d0b389a2d3b", "01501", "Diferencial de Alíquota", "Artigos 352, Inciso II, § 2º e 125 do RICMS/BA", "0", "000005"} )

	//DAPI - MG
	If(AliasInDic("T0V"))
		aAdd(aBody, { "", "9997d035-6864-bd38-e104-5b0eaf9c4bc3", "00025", "Dedução - Incentivo à Cultura", "Dedução - Incentivo à Cultura", "0", "000012"} )
		aAdd(aBody, { "", "304ec27f-ffcd-4b43-c2d3-228f02a64a01", "00036", "Dedução - Incentivo ao Esporte", "Dedução - Incentivo ao Esporte", "0", "000012"} )
		aAdd(aBody, { "", "1f139103-3190-60b6-41c5-8fe3cc9fc639", "00066", "Crédito Recebido em Transferência", "Crédito Recebido em Transferência", "0", "000012"} )
		aAdd(aBody, { "", "12b7b3dd-db5c-fedc-12be-83c69f991ed3", "00067", "Crédito Presumido", "Crédito Presumido", "0", "000012"} )
		aAdd(aBody, { "", "5feeae8d-839a-9322-a93d-55e1cb84bdd9", "00068", "Crédito Extemporâneo", "Crédito Extemporâneo", "0", "000012"} )
		aAdd(aBody, { "", "eb2c297d-6dc0-2203-1a6c-6a1823548f69", "00069", "Diferença Alíquota - Crédito", "Diferença Alíquota - Crédito", "0", "000012"} )
		aAdd(aBody, { "", "a7ebd2ec-5396-e75e-b1dd-f87423f1672d", "00070", "Ressarcimento - subst. Tributária", "Ressarcimento - subst. Tributária", "1", "000012"} )
		aAdd(aBody, { "", "dc99d8ed-7ed6-d80e-20c8-e8b154a19c9e", "00071", "Outros Créditos", "Outros Créditos", "0", "000012"} )
		aAdd(aBody, { "", "a6328391-9e58-dfce-65c8-c3e78a4049aa", "00073", "Créditos Transferidos", "Créditos Transferidos", "0", "000012"} )
		aAdd(aBody, { "", "9c8ea573-506f-88a6-154f-8823bb0fd05c", "00074", "Outros Débitos", "Outros Débitos", "0", "000012"} )
		aAdd(aBody, { "", "05c20dba-f852-130f-7cde-7ac4fcdbf9b1", "00079", "Restituição ICMS", "Restituição ICMS", "1", "000012"} )
		aAdd(aBody, { "", "3ba6a662-1207-ad30-615e-688f410030dc", "00090", "Estorno de débito", "Estorno de débito", "0", "000012"} )
		aAdd(aBody, { "", "289a752b-ecd6-c3d9-192f-84f0b363cf6a", "00095", "Estorno de crédito", "Estorno de crédito", "0", "000012"} )
		aAdd(aBody, { "", "e2a2d348-97c2-7584-f376-11a9427868c4", "00098", "Dedução - Utilização de créditos transferidos", "Dedução - Utilização de créditos transferidos", "0", "000012"} )
		aAdd(aBody, { "", "96bf478a-f767-9e1a-2683-9e9ea9e51f87", "00119", "Fundo de Err. Da Miséria FEM", "Fundo de Err. Da Miséria FEM", "1", "000012"} )
		aAdd(aBody, { "", "df75a7d6-96db-3781-c2e4-9333ebff1ebd", "00120", "Estorno FEM", "Estorno FEM", "0", "000012"} )
		aAdd(aBody, { "", "0d3e1e19-97a9-81bd-3e9d-bbc8721c658a", "00100", "Diferencial de alíquota - Débito", "Diferencial de alíquota - Débito", "0", "000012"} )
		aAdd(aBody, { "", "01289268-4dcc-afd9-1c3a-f1544cb6c2fc", "00104", "Outros", "Outros", "0", "000012"} )
		aAdd(aBody, { "", "88525c88-4ad7-ce05-adfd-608ba0689d38", "00107", "Débito Extemporâneo	", "Débito Extemporâneo	", "0", "000012"} )
		aAdd(aBody, { "", "82c714d2-e6db-464e-058c-08b19e1279b0", "00122", "Total do FEM Antecipado", "Total do FEM Antecipado", "1", "000012"} )
	EndIf

	//GIM-RN
	aAdd(aBody, { "", "9c5cbfab-d809-caf9-db54-d37d2586db62", "00143", "Transf. De Credito: Exportação", "Outro Débitos", "0", "000021"} )
	aAdd(aBody, { "", "ac28dbe7-9ee9-1abd-2c23-fab79bce3697", "00144", "Ementa constitucional 87/15 - Débitos DIFAL", "Outro Débitos", "0", "000021"} )
	aAdd(aBody, { "", "038c73f1-ca44-952b-8ae4-fc7667fbf3b6", "00158", "Baixas do Ativo Fixo", "Estornos de Créditos", "0", "000021"} )
	aAdd(aBody, { "", "40856191-6a9f-bfdd-312c-8e04bd260b42", "00159", "Em Decorrência Saídas Isentas", "Estornos de Créditos", "0", "000021"} )
	aAdd(aBody, { "", "f63d91ed-19e3-5f3b-d2e6-f523789562cf", "00148", "Energia", "Outros Créditos", "0", "000021"} )
	aAdd(aBody, { "", "eb2d0014-7b0b-496b-fcc4-0fdc92766e1f", "00149", "Ementa constitucional 87/15 - Crédito DIFAL", "Outros Créditos", "0", "000021"} )
	aAdd(aBody, { "", "6be7173b-0136-0aff-3155-b51a1f21ab2a", "00150", "ICMS Antecipado", "Outros Créditos", "0", "000021"} )
	aAdd(aBody, { "", "0bac2be1-e278-3500-1708-9f800ae9dbb0", "00163", "Estornos", "Estornos de Débitos", "0", "000021"} )
	aAdd(aBody, { "", "1ad2f5ab-9c7d-65cc-f045-e5d271497973", "00168", "Importação RN", "Deduções", "0", "000021"} )
	aAdd(aBody, { "", "863cab74-4570-df56-8834-0845d04f1f1d", "00169", "Regime mensal apuração 1º parcela 1212", "Deduções", "0", "000021"} )

	//GIA-RS
	If AliasInDic("CWZ") .AND. AliasInDic("CWY")
		aAdd(aBody, { "", "7af512c2-3648-5695-db21-c7b17b9933e6", "00201", "DIFERENCIAL DE ALÍQUOTA - MERC.OU PREST.DE SERV. REC.DE OUF,NAO VINC.A OPER.SUBS.ART.16,I,F; 17,III", "Outros Débitos", "0", "000024"} )
		aAdd(aBody, { "", "b1407354-3607-c71e-0634-9cc04a15ebad", "00202", "ESTORNO DE CRÉDITOS. ART 34, LIVRO I, RICMS", "Outros Débitos", "0", "000024"} )
		aAdd(aBody, { "", "6e761588-b391-6bc7-56d7-391fb66f8a92", "00203", "ANTECIPAÇÃO DO IMPOSTO PARA O MOMENTO DA ENTRADA NO TERRITÓRIO DESTE ESTADO. LIVRO I, ART. 46, - 4-", "Outros Débitos", "0", "000024"} )
		aAdd(aBody, { "", "c609969d-9ba4-541c-d289-8714e5b55ce8", "00204", "ICMS REL.AS OP.SUBSEQUENTES C/AS MERC.EST.EST.ATACADISTA E VAR.POR OCASIÃO DA ENTR.NO REG. ST.", "Outros Débitos", "0", "000024"} )
		aAdd(aBody, { "", "983cbd9f-89eb-d9b0-3722-f573f0116c80", "00205", "ANTECIP. IMPOSTO MOMENTO ENTR. ESTABEL. VAREJISTA PROD. FARMACEUT. RECEB. BONIFICACAO LV.I, ART46, 5", "Outros Débitos", "0", "000024"} )
		aAdd(aBody, { "", "4f706222-32ae-29a5-f171-ad5ce9f025d8", "00206", "LIVRO III, ART. 54, IMP.DEVIDO NAS PRESTAÇÕES DE SER.DE TRANSP. DE CARGA POR TRANSP.NAO ESTAB.RS", "Outros Débitos", "0", "000024"} )
		aAdd(aBody, { "", "d9fa3e02-5a9d-ce71-70f7-cc2322ce88db", "00207", "AMPARA/RS ICMS PRÓPRIO", "Outros Débitos", "0", "000024"} )
		aAdd(aBody, { "", "54a4f4be-60f0-96e4-9489-cfcae9910ae8", "00208", "AMPARA/RS ICMS ST", "Outros Débitos", "0", "000024"} )
		aAdd(aBody, { "", "7717f493-3c03-08e1-4c9b-8bcc42dd2780", "00209", "DIF.AL. EC 87", "Outros Débitos", "0", "000024"} )
		aAdd(aBody, { "", "3a1cf335-59fd-ebec-adf4-4ea992eb4495", "00299", "OUTROS DÉBITOS", "Outros Débitos", "0", "000024"} )
		aAdd(aBody, { "", "44b1a30d-25e2-aa5a-a1d1-bbadfb998da3", "00211", "Débitos por Responsabilidade Compensáveis", "Outros Débitos", "0", "000024"} )
		aAdd(aBody, { "", "c854e5d5-d9d4-52bf-8651-10a3a74adcdd", "00212", "Débitos por Compensação", "Outros Débitos", "0", "000024"} )
		aAdd(aBody, { "", "fbe4ad8e-08c2-5b8c-e778-53b1433ab8aa", "00411", "Débitos por transferência de crédito e de saldo devedor", "Outros Débitos", "0", "000024"} )
		aAdd(aBody, { "", "a9262035-075e-6d06-95d1-8b12615c5416", "00601", "ANT.DO IMPOSTO P/ O MOMENTO DA ENTRADA DA MERCADORIA NO RGS. LIVRO I, ART. 31, II, 'C'", "Outros Créditos", "0", "000024"} )
		aAdd(aBody, { "", "8ba41eb5-7e61-08be-ced8-2efed769db0f", "00602", "DEVOLUÇÃO MERCADORIAS RECEBIDAS PARA USO CONSUMO", "Outros Créditos", "0", "000024"} )
		aAdd(aBody, { "", "918683f6-9f73-04f9-4189-e4768fe59ffc", "00603", "ENTRADAS EM RETORNO DE MERCADORIAS OU BENS REMETIDOS EM DEMONSTRAÇÃO P/ CONTRIBUINTES NÃO INSCRITOS", "Outros Créditos", "0", "000024"} )
		aAdd(aBody, { "", "12f75a4c-436b-8088-f349-a6ea4a7880c3", "00604", "EXCLUSÃO DE MERCADORIA DA SUBSTITUIÇÃO TRIBUTARIA", "Outros Créditos", "0", "000024"} )
		aAdd(aBody, { "", "d82e4624-c104-8430-8f62-5039cb1d1fc8", "00605", "DIFERENCIAL DE ALÍQUOTA. EC 87", "Outros Créditos", "0", "000024"} )
		aAdd(aBody, { "", "0db5f6e7-ed2d-4b19-3e81-bc6a728c7a6b", "00699", "OUTROS CRÉDITOS", "Outros Créditos", "0", "000024"} )
		aAdd(aBody, { "", "94a06fe9-5b60-447f-1dd1-c89c3a82c82e", "00803", "Créditos Recebidos", "Outros Créditos", "0", "000024"} )
		aAdd(aBody, { "", "bb634f68-07fb-66dd-e9fb-307bf992642e", "00804", "Créditos Presumido", "Outros Créditos", "0", "000024"} )
		aAdd(aBody, { "", "5e8f696f-6dda-8d9d-72f2-2080cc47b3e7", "00805", "Créditos por Compensação por Pagamentos Indevidos", "Outros Créditos", "0", "000024"} )
		aAdd(aBody, { "", "441c7025-ac69-ad47-2192-c17da6005efe", "00701", "Outros Créditos ST", "Outros Créditos ST", "1", "000024"} )// ICMS ST
		aAdd(aBody, { "", "3c422e12-79e4-c7ba-96bc-871659c156af", "00201", "Outros débitos ST", "Outros Débitos ST", "1", "000024"} ) //ICMS ST
	EndIf
	
	aAdd(aBody, { "", "27a21940-21d6-372a-3f79-9107721015dc", "00274", "ICMS proporcional devido ao RJ nas operações e prestações que destinem bens e serviços a consumidor final não contribuinte localizado em outro Estado.","Art. 99 no Ato das Disposições Constitucionais Transitórias incluído pela EC 87/2015", "0", "000020" } )
	aAdd(aBody, { "", "27a21940-21d6-372a-3f79-910772101521", "00287", "Parcela do diferencial de alíquota decorrente de operações e prestações que destinem bens e serviços a não contribuinte do ICMS localizado", "Inc. I do art. 9º das Disp. Transitórias da Lei 6374/89.", "0", "000027" } )
	aAdd(aBody, { "", "0d3dd7ee-af53-b5db-d0a4-ee6bf260698g", "00770", "ICMS relativo ao FECOEP-Fundo Estadual de Combate e Erradicação da Pobreza, a ser pago separadamente em guia especial.", "Lei Nº 16.006, de 24 de novembro de 2015", "0", "000027" } )
	aAdd(aBody, { "", "1ce34b84-82f9-f947-a2dc-20afc433831j", "00770", "ICMS relativo ao FECOEP-Fundo Estadual de Combate e Erradicação da Pobreza, a ser pago separadamente em guia especial.", "Lei Nº 16.006, de 24 de novembro de 2015", "1", "000027" } )
	
	//DIAP
	aAdd(aBody, { "", "f85ba38c-e207-965d-6d4d-90c3f3875b6b", "00200", "ICMS Efetivo Recolhido", "ICMS Efetivo Recolhido", "0", "000004"} )
	aAdd(aBody, { "", "3a013cbc-01ca-fa14-39a3-28cc3b69715b", "00201", "Utilização Crédito do Produtor Rural", "Utilização Crédito do Produtor Rural", "0", "000004"} )
	aAdd(aBody, { "", "93b48bd9-e94a-146c-40a0-7f9d97173af8", "00202", "ICMS pago indevidamente ou por erro de escrituração", "ICMS pago indevidamente ou por erro de escrituração", "0", "000004"} )
	aAdd(aBody, { "", "ddb5ca30-25f9-1272-5c28-46ab91e49ad9", "00203", "Excesso de Estimativa autorizado por motivo de desenquadramento", "Excesso de Estimativa autorizado por motivo de desenquadramento", "0", "000004"} )
	aAdd(aBody, { "", "d9475d51-3a3a-10f5-ed08-757859f16b54", "00204", "Concessão de crédito de 20% do valor do ICMS devido na prestação, aos estabelecimentos prestadores de serviços de transporte, que será adotado, opcionalmente, pelo contribuinte, em substituição ao sistema de tributação normal a que está inscrito.", "Concessão de crédito de 20% do valor do ICMS devido na prestação, aos estabelecimentos prestadores de serviços de transporte, que será adotado, opcionalmente, pelo contribuinte, em substituição ao sistema de tributação normal a que está inscrito.", "0", "000004"} )
	aAdd(aBody, { "", "b234e777-e294-90be-06d7-52c45d73cda6", "00205", "Concessão de crédito presumido, utilizado quando da saída, interna ou interestadual, do estab. industrial de pescado, submetido a processo de industrialização, na qual a carga trib. resulte 4%, vedado o aproveitamento de quaisquer outros créditos.", "Concessão de crédito presumido, utilizado quando da saída, interna ou interestadual, do estab. industrial de pescado, submetido a processo de industrialização, na qual a carga trib. resulte 4%, vedado o aproveitamento de quaisquer outros créditos.", "0", "000004"} )
	aAdd(aBody, { "", "554fcd69-61e8-5257-2b4b-468fa38e1c0b", "00206", "Concessão de crédito presumido do ICMS na aquisição de equipamento Emissor de Cupom Fiscal - ECF e acessórios.", "Concessão de crédito presumido do ICMS na aquisição de equipamento Emissor de Cupom Fiscal - ECF e acessórios.", "0", "000004"} )
	aAdd(aBody, { "", "92a6aaac-08c3-e9c5-1601-fd2227b712b4", "00207", "Diferimento no pagamento do ICMS incidente na primeira operação interna realizada com pescado destinada a estabelecimentos que promovam o processo de industrialização.", "Diferimento no pagamento do ICMS incidente na primeira operação interna realizada com pescado destinada a estabelecimentos que promovam o processo de industrialização.", "0", "000004"} )
	aAdd(aBody, { "", "f6a1c149-2510-8c45-49ff-88becfab6ef3", "00208", "Antecipação, pela administração direta e indireta, do recolhimento do ICMS decorrente do fornecimento de bens ou de prestação de serviços", "Antecipação, pela administração direta e indireta, do recolhimento do ICMS decorrente do fornecimento de bens ou de prestação de serviços", "0", "000004"} )
	aAdd(aBody, { "", "a938e9a7-8b1f-8792-4ec7-d5c1220a36cd", "00299", "Outros", "Outros", "0", "000004"} )
	aAdd(aBody, { "", "fe4377d4-d52f-186c-ed66-2d1bce88e071", "00300", "Lei de Incentivo à Cultura", "Lei de Incentivo à Cultura", "0", "000004"} )
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAGetId

Rotina para carga e atualização da tabela autocontida.
Retorna próximo ID a ser utilizado.

@Return		cRet - ID disponível para utilização

@Author		fabio.santana
@Since		12/03/2018
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function TAFAGetId( )

	Local cRet			:= ''
	Local aAreaCHY		:= CHY->(GetArea())
	Local lContinua		:= .T.
	
	CHY->(DbSetOrder(1))	//CHY_FILIAL+CHY_ID
	
	While lContinua
		cRet	:= GetSX8Num('CHY','CHY_ID')
	
		lContinua := ( CHY->(MsSeek(xFilial('CHY') + cRet)) )
		ConfirmSX8()
	EndDo
	
	RestArea(aAreaCHY)

Return(cRet)
