#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA024.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA024
Cadastro MVC - Cadastro de classificação do item

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA024()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Cadastro de Classificação do Item de Energia Elétrica e Comunicação/Telecomunicação"
oBrw:SetAlias( 'C0K')
oBrw:SetMenuDef( 'TAFA024' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA024" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC0K 	:= 	FWFormStruct( 1, 'C0K' )
Local oModel 	:= 	MPFormModel():New( 'TAFA024' )

oModel:AddFields('MODEL_C0K', /*cOwner*/, oStruC0K)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 10/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA024' )
Local 	oStruC0K 	:= 	FWFormStruct( 2, 'C0K' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0K', oStruC0K, 'MODEL_C0K' )

oView:EnableTitleView( 'VIEW_C0K', STR0001 ) //"Cadastro de Classificação do Item de Energia Elétrica e Comunicação/Telecomunicação"
oView:CreateHorizontalBox( 'FIELDSC0K', 100 )
oView:SetOwnerView( 'VIEW_C0K', 'FIELDSC0K' )

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
	aAdd( aHeader, "C0K_FILIAL" )
	aAdd( aHeader, "C0K_ID" )
	aAdd( aHeader, "C0K_CODIGO" )
	aAdd( aHeader, "C0K_DESCRI" )
	aAdd( aHeader, "C0K_GRUPO" )
	aAdd( aHeader, "C0K_VALIDA" )

	aAdd( aBody, { "", "000001", "0101", "Assinatura de servicos de telefonia", "000001", "" } )
	aAdd( aBody, { "", "000002", "0102", "Assinatura de servicos de comunicacao de dados", "000001", "" } )
	aAdd( aBody, { "", "000003", "0103", "Assinatura de servicos de TV por Assinatura", "000001", 	 "" } )
	aAdd( aBody, { "", "000004", "0104", "Assinatura de servicos de provimento . internet", "000001",  "" } )
	aAdd( aBody, { "", "000005", "0105", "Assinatura de outros servicos de multimidia", "000001", 	 "" } )
	aAdd( aBody, { "", "000006", "0199", "Assinatura de outros servicos", "000001", "" } )
	aAdd( aBody, { "", "000007", "0201", "Habilitacao de servicos de telefonia", "000002", 	"" } )
	aAdd( aBody, { "", "000008", "0202", "Habilitacao de servicos de comunicacao de dados", "000002",  "" } )
	aAdd( aBody, { "", "000009", "0203", "Habilitacao de TV por Assinatura", "000002",	"" } )
	aAdd( aBody, { "", "000010", "0204", "Habilitacao de servicos de provimento . internet", "000002",  "" } )
	aAdd( aBody, { "", "000011", "0205", "Habilitacao de outros servicos multimidia", "000002", "" } )
	aAdd( aBody, { "", "000012", "0299", "Habilitacao de outros servicos", "000002", "" } )
	aAdd( aBody, { "", "000013", "0301", "Servico Medido - chamadas locais", "000003", "" } )
	aAdd( aBody, { "", "000014", "0302", "Servico Medido - chamadas interurbanas no Estado", "000003",  "" } )
	aAdd( aBody, { "", "000015", "0303", "Servico Medido - chamadas interurbanas para fora do Estado", "000003",  "" } )
	aAdd( aBody, { "", "000016", "0304", "Servico Medido - chamadas internacionais", "000003", 					 "" } )
	aAdd( aBody, { "", "000017", "0305", "Servico Medido - N.meros Especiais (0300/0500/0600/0800/etc.)", "000003",  "" } )
	aAdd( aBody, { "", "000018", "0306", "Servico Medido - comunicacao de dados", "000003", 		 "" } )
	aAdd( aBody, { "", "000019", "0307", "Servico Medido - chamadas originadas em Roaming", "000003",  "" } )
	aAdd( aBody, { "", "000020", "0308", "Servico Medido - chamadas recebidas em Roaming", "000003",  "" } )
	aAdd( aBody, { "", "000021", "0309", "Servico Medido - adicional de chamada", "000003", 		 "" } )
	aAdd( aBody, { "", "000022", "0310", "Servico Medido - provimento de acesso . Internet", "000003",  "" } )
	aAdd( aBody, { "", "000023", "0311", "Servico Medido - pay-per-view (programacao TV)", "000003",  "" } )
	aAdd( aBody, { "", "000024", "0312", "Servico Medido - Mensagem SMS", "000003", "" } )
	aAdd( aBody, { "", "000025", "0313", "Servico Medido - Mensagem MMS", "000003", "" } )
	aAdd( aBody, { "", "000026", "0314", "Servico Medido - outros mensagens", "000003", "" } )
	aAdd( aBody, { "", "000027", "0315", "Servico Medido - servico multimidia", "000003", "" } )
	aAdd( aBody, { "", "000028", "0399", "Servico Medido - outros servicos", "000003", 	"" } )
	aAdd( aBody, { "", "000029", "0401", "Cartao Telef.nico - Telefonia Fixa", "000004", "" } )
	aAdd( aBody, { "", "000030", "0402", "Cartao Telef.nico - Telefonia M.vel", "000004", "" } )
	aAdd( aBody, { "", "000031", "0403", "Cartao de Provimento de acesso . internet", "000004", "" } )
	aAdd( aBody, { "", "000032", "0404", "Ficha Telef.nica", "000004", "" } )
	aAdd( aBody, { "", "000033", "0405", "Recarga de Creditos - Telefonia Fixa", "000004", 	 "" } )
	aAdd( aBody, { "", "000034", "0406", "Recarga de Creditos - Telefonia M.vel", "000004",  "" } )
	aAdd( aBody, { "", "000035", "0407", "Recarga de Creditos - Provimento de acesso . Internet", "000004",  "" } )
	aAdd( aBody, { "", "000036", "0499", "Outras cobrancas realizadas de assinantes de plano servico pre-pago", "000004", "" } )
	aAdd( aBody, { "", "000037", "0501", "Servico Adicional (substituicao de n.mero, troca de aparelho, emissao de 2. via de conta, conta detalhada, etc.)", "000005", "" } )
	aAdd( aBody, { "", "000038", "0502", "Servico Facilidades (identificador de chamadas, caixa postal, transferencia temporaria, nao-perturbe, etc.)", "000005","" } )
	aAdd( aBody, { "", "000039", "0599", "Outros Servicos", "000005", "" } )
	aAdd( aBody, { "", "000040", "0601", "Energia Eletrica - Consumo", "000006","" } )
	aAdd( aBody, { "", "000041", "0602", "Energia Eletrica - Demanda", "000006", "" } )
	aAdd( aBody, { "", "000042", "0603", "Energia Eletrica - Servicos (Vistoria de unidade consumidora, Afericao de Medidor, Ligacao, Religacao, Troca de medidor, etc.)", "000006", "" } )
	aAdd( aBody, { "", "000043", "0604", "Energia Eletrica - Encargos Emergenciais", "000006", "" } )
	aAdd( aBody, { "", "000044", "0605", "Tarifa de Uso dos Sistemas de Distribuicao de Energia Eletrica - TUSD - Consumidor Cativo", "000006", "" } )
	aAdd( aBody, { "", "000045", "0606", "Tarifa de Uso dos Sistemas de Distribuicao de Energia Eletrica - TUSD - Consumidor Livre", "000006", 	"" } )
	aAdd( aBody, { "", "000046", "0607", "Encargos de Conexao", "000006", "" } )
	aAdd( aBody, { "", "000047", "0608", "Tarifa de Uso dos Sistemas de Transmissao de Energia Eletrica - TUST - Consumidor Cativo", "000006", 	"" } )
	aAdd( aBody, { "", "000048", "0609", "Tarifa de Uso dos Sistemas de Transmissao de Energia Eletrica - TUST - Consumidor Livre", "000006", 	"" } )
	aAdd( aBody, { "", "000049", "0610", '"Subvencao econ.mica para consumidores da subclasse ""baixa renda"" "', "000006", "" } )
	aAdd( aBody, { "", "000050", "0699", "Energia Eletrica - Outros", "000006", "" } )
	aAdd( aBody, { "", "000051", "0701", "de Aparelho Telef.nico", "000007", "" } )
	aAdd( aBody, { "", "000052", "0702", "de Aparelho Identificador de chamadas", "000007", "" } )
	aAdd( aBody, { "", "000053", "0703", "de Modem", "000007", "" } )
	aAdd( aBody, { "", "000054", "0704", "de Rack", "000007", "" } )
	aAdd( aBody, { "", "000055", "0705", "de Sala/Recinto", "000007", "" } )
	aAdd( aBody, { "", "000056", "0706", "de Roteador", "000007", "" } )
	aAdd( aBody, { "", "000057", "0707", "de Servidor", "000007", "" } )
	aAdd( aBody, { "", "000058", "0708", "de Multiplexador", "000007", "" } )
	aAdd( aBody, { "", "000059", "0709", "de Decodificador/Conversor", "000007", "" } )
	aAdd( aBody, { "", "000060", "0799", "Outras disponibilizacaes", "000007", "" } )
	aAdd( aBody, { "", "000061", "0801", "Cobranca de Servicos de Terceiros", "000008", "" } )
	aAdd( aBody, { "", "000062", "0802", "Cobranca de Seguros", "000008", "" } )
	aAdd( aBody, { "", "000063", "0803", "Cobranca de Financiamento de Aparelho/Servicos", "000008","" } )
	aAdd( aBody, { "", "000064", "0804", "Cobranca de Juros de Mora", "000008",	"" } )
	aAdd( aBody, { "", "000065", "0805", "Cobranca de Multa de Mora", "000008",	"" } )
	aAdd( aBody, { "", "000066", "0806", "Cobranca de Conta de meses anteriores", "000008",	"" } )
	aAdd( aBody, { "", "000067", "0807", "Cobranca de Taxa Iluminacao P.blica", "000008", "" } )
	aAdd( aBody, { "", "000068", "0808", "Retencao de ICMS-ST", "000008", "" } )
	aAdd( aBody, { "", "000069", "0899", "Outras Cobrancas", "000008",	"" } )
	aAdd( aBody, { "", "000070", "0901", "Deducao relativa a impugnacao de servicos", "000009",	"" } )
	aAdd( aBody, { "", "000071", "0902", "Deducao referente ajuste de conta", "000009",			"" } )
	aAdd( aBody, { "", "000072", "0903", "Redutor - Energia Eletrica - In N. 306/2003(PIS/COFINS/IRPJ/CSLL)", "000009", "" } )
	aAdd( aBody, { "", "000073", "0904", "Deducao relativa . multa pela interrupcao de fornecimento", "000009", "" } )
	aAdd( aBody, { "", "000074", "0905", "Deducao relativa . distribuicao de dividendos Eletrobras", "000009", "" } )
	aAdd( aBody, { "", "000075", "0906", '"Deducao relativa . subvencao econ.mica para consumidores da subclasse""baixa renda"" "', "000009","" } )
	aAdd( aBody, { "", "000076", "0999", "Outras deducaes", "000009", "" } )
	aAdd( aBody, { "", "000077", "1001", "Servico nao medido de servicos de telefonia", "000010","" } )
	aAdd( aBody, { "", "000078", "1002", "Servico nao medido de servicos de comunicacao de dados", "000010", "" } )
	aAdd( aBody, { "", "000079", "1003", "Servico nao medido de servicos de TV por Assinatura", "000010", "" } )
	aAdd( aBody, { "", "000080", "1004", "Servico nao medido de servicos de provimento . internet", "000010","" } )
	aAdd( aBody, { "", "000081", "1005", "Servico nao medido de outros servicos de multimidia", "000010", "" } )
	aAdd( aBody, { "", "000082", "1099", '"Servico nao medido de outros servicos"" "', "000010", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
