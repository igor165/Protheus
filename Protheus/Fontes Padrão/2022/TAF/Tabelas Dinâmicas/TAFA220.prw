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

	// Adiciona ao modelo um componente de formul�rio
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

Rotina para carga e atualiza��o da tabela autocontida.

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

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

		aAdd( aBody, { "", "000001", "S-1000", "INFORMACOES DO EMPREGADOR/CONTRIBUINTE/�RG�O P�BLICO"											, ""		, "Informa��es do Empregador/Contribuinte/�rg�o P�blico" } )
		aAdd( aBody, { "", "000002", "S-1005", "TABELA DE ESTABELECIMENTOS - OBRAS DE CONSTRU��O CIVIL OU UNIDADES DE �RG�O P�BLICOS"			, ""		, "Tabela de Estabelecimentos - Obras de Constru��o Civil ou Unidades de �rg�o P�blicos" } )
		aAdd( aBody, { "", "000003", "S-1010", "TABELA DE RUBRICAS"																				, ""		, "Tabela de Rubricas" } )
		aAdd( aBody, { "", "000004", "S-1020", "TABELA DE LOTA��ES TRIBUT�RIAS"																	, ""		, "Tabela de Lota��es Tribut�rias" } )
		aAdd( aBody, { "", "000005", "S-1030", "TABELA DE CARGOS/EMPREGOS P�BLICOS"																, "20210509", "Tabela de Cargos/Empregos P�blicos" } )
		aAdd( aBody, { "", "000006", "S-1040", "TABELA DE FUN��ES/CARGOS EM COMISS�O"															, "20210509", "Tabela de Fun��es/Cargos em Comiss�o" } )
		aAdd( aBody, { "", "000007", "S-1050", "TABELA DE HOR�RIOS/TURNOS DE TRABALHO"															, "20210509", "Tabela de Hor�rios/Turnos de Trabalho" } )
		aAdd( aBody, { "", "000008", "S-1060", "TABELA DE AMBIENTES DE TRABALHO"																, "20210509", "Tabela de Ambientes de Trabalho" } )
		aAdd( aBody, { "", "000009", "S-1070", "TABELA DE PROCESSOS ADMINISTRATIVOS/JUDICIAIS"													, ""		, "Tabela de Processos Administrativos/Judiciais" } )
		aAdd( aBody, { "", "000010", "S-1080", "TABELA DE OPERADORES PORTU�RIOS"																, "20210509", "Tabela de Operadores Portu�rios" } )
		aAdd( aBody, { "", "000011", "S-1200", "MENSAL - REMUNERA��O DO TRABALHADOR VINCULADO AO REGIME GERAL DE PREVID�NCIA SOCIAL - RGPS"		, ""		, "Remunera��o do Trabalhador Vinculado ao Regime Geral de Previd�ncia Social - RGPS" } )
		aAdd( aBody, { "", "000012", "S-1210", "MENSAL - PAGAMENTOS DE RENDIMENTOS DO TRABALHO"													, ""		, "Pagamentos de Rendimentos do Trabalho" } )
		aAdd( aBody, { "", "000013", "S-1250", "MENSAL - AQUISI��O DE PRODU��O RURAL"															, "20210509", "Aquisi��o de Produ��o Rural" } )
		aAdd( aBody, { "", "000014", "S-1260", "MENSAL - COMERCIALIZA��O DA PRODU��O RURAL PESSOA F�SICA"										, ""		, "Comercializa��o da Produ��o Rural Pessoa F�sica" } )
		aAdd( aBody, { "", "000015", "S-1270", "MENSAL - CONTRATA��O DE TRABALHADORES AVULSOS N�O PORTU�RIOS"									, ""		, "Contrata��o de Trabalhadores Avulsos N�o Portu�rios" } )
		aAdd( aBody, { "", "000016", "S-1280", "MENSAL - INFORMA��ES COMPLEMENTARES AOS EVENTOS PERI�DICOS"										, ""		, "Informa��es Complementares aos Eventos Peri�dicos" } )
		aAdd( aBody, { "", "000017", "S-1298", "MENSAL - REABERTURA DOS EVENTOS PERI�DICOS"														, ""		, "Reabertura dos Eventos Peri�dicos" } )
		aAdd( aBody, { "", "000018", "S-1299", "MENSAL - FECHAMENTO DOS EVENTOS PERI�DICOS"														, ""		, "Fechamento dos Eventos Peri�dicos" } )
		aAdd( aBody, { "", "000020", "S-1300", "MENSAL - CONTRIBUI��O SINDICAL PATRONAL"														, "20210509", "Contribui��o Sindical Patronal" } )
		aAdd( aBody, { "", "000021", "S-2100", "EVENTO - CADASTRAMENTO INICIAL DO VINCULO"														, "20170707", "Cadastramento Inicial do V�nculo" } )
		aAdd( aBody, { "", "000022", "S-2190", "EVENTO - REGISTRO PRELIMINAR DE TRABALHADOR"													, ""		, "Registro Preliminar de Trabalhador" } )
		aAdd( aBody, { "", "000023", "S-2200", "EVENTO - CADASTRAMENTO INICIAL DO VINCULO E ADMISSAO/INGRESSO DE TRABALHADOR"					, ""		, "Cadastramento Inicial do V�nculo e Admiss�o/Ingresso de Trabalhador" } )
		aAdd( aBody, { "", "000024", "S-2205", "EVENTO - ALTERACAO DE DADOS CADASTRAIS DO TRABALHADOR"									, ""		, "Altera��o de Dados Cadastrais do Trabalhador" } )
		aAdd( aBody, { "", "000025", "S-2206", "EVENTO - ALTERACAO DE CONTRATO DE TRABALHO/RELACAO ESTATUTARIA"									, ""		, "Altera��o de Contrato de Trabalho/Rela��o Estatut�ria" } )
		aAdd( aBody, { "", "000026", "S-2210", "EVENTO - COMUNICACAO DE ACIDENTE DE TRABALHO"													, ""		, "Comunica��o de Acidente de Trabalho" } )
		aAdd( aBody, { "", "000027", "S-2220", "EVENTO - MONITORAMENTO DA SAUDE DO TRABALHADOR"													, ""		, "Monitoramento da Sa�de do Trabalhador" } )
		aAdd( aBody, { "", "000028", "S-2230", "EVENTO - AFASTAMENTO TEMPORARIO"																, ""		, "Afastamento Tempor�rio" } )
		aAdd( aBody, { "", "000029", "S-2240", "EVENTO - CONDICOES AMBIENTAIS DO TRABALHO - AGENTES NOCIVOS"									, ""		, "Condi��es Ambientais do Trabalho - Agentes Nocivos" } )
		aAdd( aBody, { "", "000030", "S-2241", "EVENTO - INSALUBRIDADE - PERICULOSIDADE E APOSENTADORIA ESPECIAL"								, "20190101", "Insalubridade - Periculosidade e Aposentadoria Especial" } )
		aAdd( aBody, { "", "000031", "S-2250", "EVENTO - AVISO PREVIO"																			, "20210509", "Aviso Pr�vio" } )
		aAdd( aBody, { "", "000032", "S-2298", "EVENTO - REINTEGRACAO/OUTROS PROVIMENTOS"														, ""		, "Reintegra��o/Outros Provimentos" } )
		aAdd( aBody, { "", "000033", "S-2299", "EVENTO - DESLIGAMENTO"																			, ""		, "Desligamento" } )
		aAdd( aBody, { "", "000034", "S-2300", "EVENTO - TRABALHADOR SEM VINCULO DE EMPREGADO/ESTATUT�RIO - INICIO"								, ""		, "Trabalhador sem V�nculo de Empregado/Estatut�rio - Inicio" } )
		aAdd( aBody, { "", "000035", "S-2306", "EVENTO - TRABALHADOR SEM VINCULO DE EMPREGADO/ESTATUT�RIO - ALT. CONTRATUAL"					, ""		, "Trabalhador sem V�nculo de Empregado/Estatut�rio - Alt. Contratual" } )
		aAdd( aBody, { "", "000036", "S-2399", "EVENTO - TRABALHADOR SEM VINCULO DE EMPREGADO/ESTATUT�RIO - TERMINO"							, ""		, "Trabalhador sem V�nculo de Empregado/Estatut�rio - T�rmino" } )
		aAdd( aBody, { "", "000037", "S-3000", "EVENTO - EXCLUSAO DE EVENTOS"																	, ""		, "Exclus�o de Eventos" } )
		aAdd( aBody, { "", "000038", "S-4000", "TOTALIZADOR - SOLICITACAO DE TOTALIZACAO DE BASES E CONTRIBUICOES"								, "20170707", "Solicita��o de Totaliza��o de Bases e Contribui��es" } )
		aAdd( aBody, { "", "000039", "S-5001", "TOTALIZADOR - INFORMACOES DAS CONTRIBUICOES SOCIAIS POR TRABALHADOR"							, ""		, "Informa��es das Contribui��es Sociais por Trabalhador" } )
		aAdd( aBody, { "", "000040", "S-5002", "TOTALIZADOR - IMPOSTO DE RENDA RETIDO NA FONTE POR TRABALHADOR"									, ""		, "Imposto de Renda Retido na Fonte por Trabalhador" } )
		aAdd( aBody, { "", "000041", "S-5011", "TOTALIZADOR - INFORMACOES DAS CONTRIBUICOES SOCIAIS CONSOLIDADAS POR CONTRIBUINTE"				, ""		, "Informa��es das Contribui��es Sociais Consolidadas por Contribuinte" } )
		aAdd( aBody, { "", "000042", "S-5012", "TOTALIZADOR - INFORMACOES DO IRRF CONSOLIDADAS POR CONTRIBUINTE"								, "20210509", "Informa��es do IRRF Consolidadas por Contribuinte" } )
		aAdd( aBody, { "", "000043", "S-1035", "TABELA DE CARREIRAS P�BLICAS"																	, "20210509", "Tabela de Carreiras P�blicas" } )
		aAdd( aBody, { "", "000044", "S-1202", "MENSAL - REMUNERACAO DE SERVIDOR VINCULADO AO REGIME PROPRIO DE PREVID. SOCIAL"							, ""		, "Remunera��o de Servidor vinculado ao Regime Pr�prio de Previd. Social" } )
		aAdd( aBody, { "", "000045", "S-1207", "MENSAL - BENEFICIOS - ENTES PUBLICOS"																	, ""		, "Benef�cios - Entes P�blicos" } )
		aAdd( aBody, { "", "000046", "S-2400", "EVENTO - CADASTRO DE BENEFICIARIO - ENTES P�BLICOS - IN�CIO"												, ""		, "Cadastro de Benefici�rio - Entes P�blicos - In�cio" } )
		aAdd( aBody, { "", "000047", "S-1295", "EVENTO - SOLICITA��O DE TOTALIZA��O PARA PAGAMENTO EM CONTING�NCIA"								, "20210509", "Solicita��o de Totaliza��o para Pagamento em Conting�ncia" } )
		aAdd( aBody, { "", "000048", "S-2260", "EVENTO - CONVOCA��O PARA TRABALHO INTERMITENTE"													, "20210509", "Convoca��o para Trabalho Intermitente" } )
		aAdd( aBody, { "", "000049", "S-2221", "EVENTO - EXAME TOXICOL�GICO DO MOTORISTA PROFISSIONAL"											, "20210509", "Exame Toxicol�gico do Motorista Profissional" } )

		// Layout 2.5
		aAdd( aBody, { "", "000050", "S-2245", "EVENTO - TREINAMENTOS CAPACITA��ES EXERC�CIOS SIMULADOS E OUTRAS ANOTA��ES"						, "20210509", "Treinamentos Capacita��es Exerc�cios Simulados e Outras Anota��es" } )
		aAdd( aBody, { "", "000051", "S-5003", "EVENTO - INFORMA��ES DO FGTS POR TRABALHADOR"													, ""		, "Informa��es do FGTS por Trabalhador" } )
		aAdd( aBody, { "", "000052", "S-5013", "EVENTO - INFORMA��ES DO FGTS CONSOLIDADAS POR CONTRIBUINTE"										, ""		, "Informa��es do FGTS Consolidadas por Contribuinte" } )

		//Simplifica��o

		//Inclus�es
		aAdd( aBody, { "", "000053", "S-2231", "EVENTO - CESSAO/EXERCICIO EM OUTRO ORGAO"														, ""		, "Cess�o/Exerc�cio em Outro �rg�o" } )
		aAdd( aBody, { "", "000054", "S-2405", "EVENTO - CADASTRO DE BENEFICIARIO - ENTES PUBLICOS - ALTERACAO"									, ""		, "Cadastro de Benefici�rio - Entes P�blicos - Altera��o" } )
		aAdd( aBody, { "", "000055", "S-2410", "EVENTO - CADASTRO DE BENEFICIO - ENTES PUBLICOS - INICIO"										, ""		, "Cadastro de Benef�cio - Entes P�blicos - In�cio" } )
		aAdd( aBody, { "", "000056", "S-2416", "EVENTO - CADASTRO DE BENEFICIO - ENTES PUBLICOS - ALTERACAO"									, ""		, "Cadastro de Benef�cio - Entes P�blicos - Altera��o" } )
		aAdd( aBody, { "", "000057", "S-2418", "EVENTO - REATIVACAO DE BENEFICIO - ENTES PUBLICOS"												, ""		, "Reativa��o de Benef�cio - Entes P�blicos" } )
		aAdd( aBody, { "", "000058", "S-2420", "EVENTO - CADASTRO DE BENEFICIO - ENTES PUBLICOS - TERMINO"										, ""		, "Cadastro de Benef�cio - Entes P�blicos - T�rmino" } )

		// Layout S-1.1 e-Social
        aAdd( aBody, { "", "000059", "S-2500", "EVENTO - PROCESSO TRABALHISTA"																	, ""		, "Processo Trabalhista"													, 1032.09 } )
        aAdd( aBody, { "", "000060", "S-2501", "EVENTO - INFORMA��ES DE TRIBUTOS DECORRENTES DE PROCESSO TRABALHISTA"							, ""		, "Informa��es de Tributos Decorrentes de Processo Trabalhista"				, 1032.09 } )
        aAdd( aBody, { "", "000061", "S-3500", "EVENTO - EXCLUS�O DE EVENTOS - PROCESSO TRABALHISTA"											, ""		, "Exclus�o de Eventos - Processo Trabalhista"								, 1032.09 } )
        aAdd( aBody, { "", "000062", "S-5012", "TOTALIZADOR - IMPOSTO DE RENDA RETIDO NA FONTE CONSOLIDADO POR CONTRIBUINTE"					, ""		, "Imposto de Renda Retido na Fonte Consolidado por Contribuinte"			, 1032.09 } )
        aAdd( aBody, { "", "000063", "S-5501", "TOTALIZADOR - INFORMA��ES CONSOLIDADAS DE TRIBUTOS DECORRENTES DE PROCESSO TRABALHISTA"			, ""		, "Informa��es Consolidadas de Tributos Decorrentes de Processo Trabalhista", 1032.09 } )

		aAdd( aRet, { aHeader, aBody } )
	EndIf

Return aRet
