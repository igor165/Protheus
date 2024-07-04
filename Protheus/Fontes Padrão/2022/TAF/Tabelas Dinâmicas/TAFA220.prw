#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA220.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA220
Cadastro MVC de Tipos de Arquivo da e-Social 
Tabela 09

@author Leandro Prado
@since 08/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA220()

	Local oBrw := FWmBrowse():New()

	oBrw:SetDescription( STR0001 ) //Cadastro de Tipos de Arquivo da e-Social
	oBrw:SetAlias( 'C8E')
	oBrw:SetMenuDef( 'TAFA220' )
	oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 08/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA220" )

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 08/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()

	Local oStruC8E := FWFormStruct( 1, 'C8E' ) // Cria a estrutura a ser usada no Modelo de Dados
	Local oModel   := MPFormModel():New('TAFA220' )

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'MODEL_C8E', /*cOwner*/, oStruC8E)
	oModel:GetModel( 'MODEL_C8E' ):SetPrimaryKey( { 'C8E_FILIAL' , 'C8E_ID' } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 08/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	:= FWLoadModel( 'TAFA220' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oStruC8E	:= FWFormStruct( 2, 'C8E' )// Cria a estrutura a ser usada na View
	Local oView		:= FWFormView():New()

	oView:SetModel( oModel )

	oView:AddField( 'VIEW_C8E', oStruC8E, 'MODEL_C8E' )

	oView:EnableTitleView( 'VIEW_C8E',  STR0001 ) //Cadastro de Tipos de Arquivo da e-Social

	oView:CreateHorizontalBox( 'FIELDSC8E', 100 )

	oView:SetOwnerView( 'VIEW_C8E', 'FIELDSC8E' )

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
Static Function FAtuCont(nVerEmp as numeric, nVerAtu as numeric)

	Local aHeader 	as array
	Local aBody   	as array
	Local aRet    	as array

	Default nVerEmp := 0
	Default nVerAtu := 0

	aHeader	:= {}
	aBody   := {}
	aRet    := {}
	nVerAtu := 1032.09

	If (nVerEmp < nVerAtu) .AND. TafAtualizado(.F.)
		aAdd( aHeader, "C8E_FILIAL" )
		aAdd( aHeader, "C8E_ID" )
		aAdd( aHeader, "C8E_CODIGO" )
		aAdd( aHeader, "C8E_DESCRI" )
		aAdd( aHeader, "C8E_VALIDA" )
		aAdd( aHeader, "C8E_DESPRT" )
        aAdd( aHeader, "C8E_ALTCON" )	

		aAdd( aBody, { "", "000001", "S-1000", "INFORMACOES DO EMPREGADOR/CONTRIBUINTE/ÓRGÃO PÚBLICO"											, ""		, "Informações do Empregador/Contribuinte/Órgão Público" } )
		aAdd( aBody, { "", "000002", "S-1005", "TABELA DE ESTABELECIMENTOS - OBRAS DE CONSTRUÇÃO CIVIL OU UNIDADES DE ÓRGÃO PÚBLICOS"			, ""		, "Tabela de Estabelecimentos - Obras de Construção Civil ou Unidades de Órgão Públicos" } )
		aAdd( aBody, { "", "000003", "S-1010", "TABELA DE RUBRICAS"																				, ""		, "Tabela de Rubricas" } )
		aAdd( aBody, { "", "000004", "S-1020", "TABELA DE LOTAÇÕES TRIBUTÁRIAS"																	, ""		, "Tabela de Lotações Tributárias" } )
		aAdd( aBody, { "", "000005", "S-1030", "TABELA DE CARGOS/EMPREGOS PÚBLICOS"																, "20210509", "Tabela de Cargos/Empregos Públicos" } )
		aAdd( aBody, { "", "000006", "S-1040", "TABELA DE FUNÇÕES/CARGOS EM COMISSÃO"															, "20210509", "Tabela de Funções/Cargos em Comissão" } )
		aAdd( aBody, { "", "000007", "S-1050", "TABELA DE HORÁRIOS/TURNOS DE TRABALHO"															, "20210509", "Tabela de Horários/Turnos de Trabalho" } )
		aAdd( aBody, { "", "000008", "S-1060", "TABELA DE AMBIENTES DE TRABALHO"																, "20210509", "Tabela de Ambientes de Trabalho" } )
		aAdd( aBody, { "", "000009", "S-1070", "TABELA DE PROCESSOS ADMINISTRATIVOS/JUDICIAIS"													, ""		, "Tabela de Processos Administrativos/Judiciais" } )
		aAdd( aBody, { "", "000010", "S-1080", "TABELA DE OPERADORES PORTUÁRIOS"																, "20210509", "Tabela de Operadores Portuários" } )
		aAdd( aBody, { "", "000011", "S-1200", "MENSAL - REMUNERAÇÃO DO TRABALHADOR VINCULADO AO REGIME GERAL DE PREVIDÊNCIA SOCIAL - RGPS"		, ""		, "Remuneração do Trabalhador Vinculado ao Regime Geral de Previdência Social - RGPS" } )
		aAdd( aBody, { "", "000012", "S-1210", "MENSAL - PAGAMENTOS DE RENDIMENTOS DO TRABALHO"													, ""		, "Pagamentos de Rendimentos do Trabalho" } )
		aAdd( aBody, { "", "000013", "S-1250", "MENSAL - AQUISIÇÃO DE PRODUÇÃO RURAL"															, "20210509", "Aquisição de Produção Rural" } )
		aAdd( aBody, { "", "000014", "S-1260", "MENSAL - COMERCIALIZAÇÃO DA PRODUÇÃO RURAL PESSOA FÍSICA"										, ""		, "Comercialização da Produção Rural Pessoa Física" } )
		aAdd( aBody, { "", "000015", "S-1270", "MENSAL - CONTRATAÇÃO DE TRABALHADORES AVULSOS NÃO PORTUÁRIOS"									, ""		, "Contratação de Trabalhadores Avulsos Não Portuários" } )
		aAdd( aBody, { "", "000016", "S-1280", "MENSAL - INFORMAÇÕES COMPLEMENTARES AOS EVENTOS PERIÓDICOS"										, ""		, "Informações Complementares aos Eventos Periódicos" } )
		aAdd( aBody, { "", "000017", "S-1298", "MENSAL - REABERTURA DOS EVENTOS PERIÓDICOS"														, ""		, "Reabertura dos Eventos Periódicos" } )
		aAdd( aBody, { "", "000018", "S-1299", "MENSAL - FECHAMENTO DOS EVENTOS PERIÓDICOS"														, ""		, "Fechamento dos Eventos Periódicos" } )
		aAdd( aBody, { "", "000020", "S-1300", "MENSAL - CONTRIBUIÇÃO SINDICAL PATRONAL"														, "20210509", "Contribuição Sindical Patronal" } )
		aAdd( aBody, { "", "000021", "S-2100", "EVENTO - CADASTRAMENTO INICIAL DO VINCULO"														, "20170707", "Cadastramento Inicial do Vínculo" } )
		aAdd( aBody, { "", "000022", "S-2190", "EVENTO - REGISTRO PRELIMINAR DE TRABALHADOR"													, ""		, "Registro Preliminar de Trabalhador" } )
		aAdd( aBody, { "", "000023", "S-2200", "EVENTO - CADASTRAMENTO INICIAL DO VINCULO E ADMISSAO/INGRESSO DE TRABALHADOR"					, ""		, "Cadastramento Inicial do Vínculo e Admissão/Ingresso de Trabalhador" } )
		aAdd( aBody, { "", "000024", "S-2205", "EVENTO - ALTERACAO DE DADOS CADASTRAIS DO TRABALHADOR"									, ""		, "Alteração de Dados Cadastrais do Trabalhador" } )
		aAdd( aBody, { "", "000025", "S-2206", "EVENTO - ALTERACAO DE CONTRATO DE TRABALHO/RELACAO ESTATUTARIA"									, ""		, "Alteração de Contrato de Trabalho/Relação Estatutária" } )
		aAdd( aBody, { "", "000026", "S-2210", "EVENTO - COMUNICACAO DE ACIDENTE DE TRABALHO"													, ""		, "Comunicação de Acidente de Trabalho" } )
		aAdd( aBody, { "", "000027", "S-2220", "EVENTO - MONITORAMENTO DA SAUDE DO TRABALHADOR"													, ""		, "Monitoramento da Saúde do Trabalhador" } )
		aAdd( aBody, { "", "000028", "S-2230", "EVENTO - AFASTAMENTO TEMPORARIO"																, ""		, "Afastamento Temporário" } )
		aAdd( aBody, { "", "000029", "S-2240", "EVENTO - CONDICOES AMBIENTAIS DO TRABALHO - AGENTES NOCIVOS"									, ""		, "Condições Ambientais do Trabalho - Agentes Nocivos" } )
		aAdd( aBody, { "", "000030", "S-2241", "EVENTO - INSALUBRIDADE - PERICULOSIDADE E APOSENTADORIA ESPECIAL"								, "20190101", "Insalubridade - Periculosidade e Aposentadoria Especial" } )
		aAdd( aBody, { "", "000031", "S-2250", "EVENTO - AVISO PREVIO"																			, "20210509", "Aviso Prévio" } )
		aAdd( aBody, { "", "000032", "S-2298", "EVENTO - REINTEGRACAO/OUTROS PROVIMENTOS"														, ""		, "Reintegração/Outros Provimentos" } )
		aAdd( aBody, { "", "000033", "S-2299", "EVENTO - DESLIGAMENTO"																			, ""		, "Desligamento" } )
		aAdd( aBody, { "", "000034", "S-2300", "EVENTO - TRABALHADOR SEM VINCULO DE EMPREGADO/ESTATUTÁRIO - INICIO"								, ""		, "Trabalhador sem Vínculo de Empregado/Estatutário - Inicio" } )
		aAdd( aBody, { "", "000035", "S-2306", "EVENTO - TRABALHADOR SEM VINCULO DE EMPREGADO/ESTATUTÁRIO - ALT. CONTRATUAL"					, ""		, "Trabalhador sem Vínculo de Empregado/Estatutário - Alt. Contratual" } )
		aAdd( aBody, { "", "000036", "S-2399", "EVENTO - TRABALHADOR SEM VINCULO DE EMPREGADO/ESTATUTÁRIO - TERMINO"							, ""		, "Trabalhador sem Vínculo de Empregado/Estatutário - Término" } )
		aAdd( aBody, { "", "000037", "S-3000", "EVENTO - EXCLUSAO DE EVENTOS"																	, ""		, "Exclusão de Eventos" } )
		aAdd( aBody, { "", "000038", "S-4000", "TOTALIZADOR - SOLICITACAO DE TOTALIZACAO DE BASES E CONTRIBUICOES"								, "20170707", "Solicitação de Totalização de Bases e Contribuições" } )
		aAdd( aBody, { "", "000039", "S-5001", "TOTALIZADOR - INFORMACOES DAS CONTRIBUICOES SOCIAIS POR TRABALHADOR"							, ""		, "Informações das Contribuições Sociais por Trabalhador" } )
		aAdd( aBody, { "", "000040", "S-5002", "TOTALIZADOR - IMPOSTO DE RENDA RETIDO NA FONTE POR TRABALHADOR"									, ""		, "Imposto de Renda Retido na Fonte por Trabalhador" } )
		aAdd( aBody, { "", "000041", "S-5011", "TOTALIZADOR - INFORMACOES DAS CONTRIBUICOES SOCIAIS CONSOLIDADAS POR CONTRIBUINTE"				, ""		, "Informações das Contribuições Sociais Consolidadas por Contribuinte" } )
		aAdd( aBody, { "", "000042", "S-5012", "TOTALIZADOR - INFORMACOES DO IRRF CONSOLIDADAS POR CONTRIBUINTE"								, "20210509", "Informações do IRRF Consolidadas por Contribuinte" } )
		aAdd( aBody, { "", "000043", "S-1035", "TABELA DE CARREIRAS PÚBLICAS"																	, "20210509", "Tabela de Carreiras Públicas" } )
		aAdd( aBody, { "", "000044", "S-1202", "MENSAL - REMUNERACAO DE SERVIDOR VINCULADO AO REGIME PROPRIO DE PREVID. SOCIAL"							, ""		, "Remuneração de Servidor vinculado ao Regime Próprio de Previd. Social" } )
		aAdd( aBody, { "", "000045", "S-1207", "MENSAL - BENEFICIOS - ENTES PUBLICOS"																	, ""		, "Benefícios - Entes Públicos" } )
		aAdd( aBody, { "", "000046", "S-2400", "EVENTO - CADASTRO DE BENEFICIARIO - ENTES PÚBLICOS - INÍCIO"												, ""		, "Cadastro de Beneficiário - Entes Públicos - Início" } )
		aAdd( aBody, { "", "000047", "S-1295", "EVENTO - SOLICITAÇÃO DE TOTALIZAÇÃO PARA PAGAMENTO EM CONTINGÊNCIA"								, "20210509", "Solicitação de Totalização para Pagamento em Contingência" } )
		aAdd( aBody, { "", "000048", "S-2260", "EVENTO - CONVOCAÇÃO PARA TRABALHO INTERMITENTE"													, "20210509", "Convocação para Trabalho Intermitente" } )
		aAdd( aBody, { "", "000049", "S-2221", "EVENTO - EXAME TOXICOLÓGICO DO MOTORISTA PROFISSIONAL"											, "20210509", "Exame Toxicológico do Motorista Profissional" } )

		// Layout 2.5
		aAdd( aBody, { "", "000050", "S-2245", "EVENTO - TREINAMENTOS CAPACITAÇÕES EXERCÍCIOS SIMULADOS E OUTRAS ANOTAÇÕES"						, "20210509", "Treinamentos Capacitações Exercícios Simulados e Outras Anotações" } )
		aAdd( aBody, { "", "000051", "S-5003", "EVENTO - INFORMAÇÕES DO FGTS POR TRABALHADOR"													, ""		, "Informações do FGTS por Trabalhador" } )
		aAdd( aBody, { "", "000052", "S-5013", "EVENTO - INFORMAÇÕES DO FGTS CONSOLIDADAS POR CONTRIBUINTE"										, ""		, "Informações do FGTS Consolidadas por Contribuinte" } )

		//Simplificação

		//Inclusões
		aAdd( aBody, { "", "000053", "S-2231", "EVENTO - CESSAO/EXERCICIO EM OUTRO ORGAO"														, ""		, "Cessão/Exercício em Outro Órgão" } )
		aAdd( aBody, { "", "000054", "S-2405", "EVENTO - CADASTRO DE BENEFICIARIO - ENTES PUBLICOS - ALTERACAO"									, ""		, "Cadastro de Beneficiário - Entes Públicos - Alteração" } )
		aAdd( aBody, { "", "000055", "S-2410", "EVENTO - CADASTRO DE BENEFICIO - ENTES PUBLICOS - INICIO"										, ""		, "Cadastro de Benefício - Entes Públicos - Início" } )
		aAdd( aBody, { "", "000056", "S-2416", "EVENTO - CADASTRO DE BENEFICIO - ENTES PUBLICOS - ALTERACAO"									, ""		, "Cadastro de Benefício - Entes Públicos - Alteração" } )
		aAdd( aBody, { "", "000057", "S-2418", "EVENTO - REATIVACAO DE BENEFICIO - ENTES PUBLICOS"												, ""		, "Reativação de Benefício - Entes Públicos" } )
		aAdd( aBody, { "", "000058", "S-2420", "EVENTO - CADASTRO DE BENEFICIO - ENTES PUBLICOS - TERMINO"										, ""		, "Cadastro de Benefício - Entes Públicos - Término" } )

		// Layout S-1.1 e-Social
        aAdd( aBody, { "", "000059", "S-2500", "EVENTO - PROCESSO TRABALHISTA"																	, ""		, "Processo Trabalhista"													, 1032.09 } )
        aAdd( aBody, { "", "000060", "S-2501", "EVENTO - INFORMAÇÕES DE TRIBUTOS DECORRENTES DE PROCESSO TRABALHISTA"							, ""		, "Informações de Tributos Decorrentes de Processo Trabalhista"				, 1032.09 } )
        aAdd( aBody, { "", "000061", "S-3500", "EVENTO - EXCLUSÃO DE EVENTOS - PROCESSO TRABALHISTA"											, ""		, "Exclusão de Eventos - Processo Trabalhista"								, 1032.09 } )
        aAdd( aBody, { "", "000062", "S-5012", "TOTALIZADOR - IMPOSTO DE RENDA RETIDO NA FONTE CONSOLIDADO POR CONTRIBUINTE"					, ""		, "Imposto de Renda Retido na Fonte Consolidado por Contribuinte"			, 1032.09 } )
        aAdd( aBody, { "", "000063", "S-5501", "TOTALIZADOR - INFORMAÇÕES CONSOLIDADAS DE TRIBUTOS DECORRENTES DE PROCESSO TRABALHISTA"			, ""		, "Informações Consolidadas de Tributos Decorrentes de Processo Trabalhista", 1032.09 } )

		aAdd( aRet, { aHeader, aBody } )
	EndIf

Return aRet
