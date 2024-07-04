#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA377.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA377
Cadastro MVC de Obrigações Fiscais

@author Paulo S. Vilas B.Santana
@since 10/04/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA377()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001 )    //"Obrigações Fiscais"
oBrw:SetAlias( 'CHW')
oBrw:SetMenuDef( 'TAFA377' )
CHW->(DbSetOrder(2))
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
Return XFUNMnuTAF( "TAFA377" ,,,,.T. )
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
Local oStruCHW  :=  FWFormStruct( 1, 'CHW' )
Local oModel    :=  MPFormModel():New( 'TAFA377' )

oModel:AddFields('MODEL_CHW', /*cOwner*/, oStruCHW)
oModel:GetModel('MODEL_CHW'):SetPrimaryKey({'CHW_FILIAL','CHW_ID'})

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
Local   oModel      :=  FWLoadModel( 'TAFA377' )
Local   oStruCHW    :=  FWFormStruct( 2, 'CHW' )
Local   oView       :=  FWFormView():New()

oStruCHW:RemoveField('CHW_ID')

oView:SetModel( oModel )
oView:AddField( 'VIEW_CHW', oStruCHW, 'MODEL_CHW' )

oView:EnableTitleView( 'VIEW_CHW', STR0001 )    //"Obrigações Fiscais"
oView:CreateHorizontalBox( 'FIELDSCHW', 100 )
oView:SetOwnerView( 'VIEW_CHW', 'FIELDSCHW' )

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

nVerAtu := 1032.01

If nVerEmp < nVerAtu
	aAdd( aHeader, "CHW_FILIAL" )
	aAdd( aHeader, "CHW_ID" )
	aAdd( aHeader, "CHW_CODIGO" )
	aAdd( aHeader, "CHW_DESCRI" )
	aAdd( aHeader, "CHW_FONTE" )
	aAdd( aHeader, "CHW_MAINFU" )
	aAdd( aHeader, "CHW_ESFERA" )
	aAdd( aHeader, "CHW_DESCCO" )
	aAdd( aHeader, "CHW_DESTIN" )
	aAdd( aHeader, "CHW_OBJETI" )
	aAdd( aHeader, "CHW_PRAZO" )
	aAdd( aHeader, "CHW_APPDIS" )
	aAdd( aHeader, "CHW_VERSAO" )
	aAdd( aHeader, "CHW_COMENT" )

	aAdd( aBody, { "", "49c5cc9e-887a-2c2a-b888-c705b2812ace", "000001", "GIA - SP", "TAFXGSP", "TAFXGSP", "2", "Guia de Informacoes de Apurações de ICMS/ICMS-ST", "TODOS OS CONTRIBUINTES ESTABELECIDOS E INSCRITOS NO ESTADO DE SAO PAULO", "GIA Eletronica - Valida para a Secretaria da Fazenda do Estado de Sao Paulo vigorando a partir da referencia julho/2000 a Nova GIA, contem em um unico documento as informacoes economico-fiscais de 5 documentos em 1: GIA, GIA-ST-11, GINTER, Zona Franca Manaus/ALC e DIPAM-B. Portaria CAT 46/2000.", "", "DISPONIBILIZADO APENAS PARA CONTRIBUINTES CADASTRA", "21ª EDIÇÃO", "Alterações contempladas a partir da 17ª edição." } )
	aAdd( aBody, { "", "d30637e5-9e62-fd86-53fb-2891a664eaf2", "000002", "SINTEGRA", "TAFA119", "TAFA119", "2", "Arquivo utilizado no processamento do SINTEGRA. A utilizacao do mesmo nesta rotina torna-se desnecessaria, favor acesar a opcao Miscelanea/Arquivos Magneticos/Sintegra para processamento do mesmo.", "", "Trazer informações dos contribuintes aos fiscos estaduais e desenvolver o fluxo de dados nas Administrações Tributárias.", "", "", "", "" } )
	aAdd( aBody, { "", "23b21ef5-fe32-769e-7b6f-2c76b1cb488d", "000003", "SPED CONTRIBUIÇÕES", "TAFA118", "TAFA118", "1", "A EFD-Contribuições trata-se de um arquivo digital instituído no Sistema Publico de Escrituração Digital – SPED, a ser utilizado pelas pessoas jurídicas de direito privado na escrituração da Contribuição para o PIS/Pasep e da Cofins, nos regimes de apuração não-cumulativo e/ou cumulativo, com base no conjunto de documentos e operações representativos das receitas auferidas, bem como dos custos, despesas, encargos e aquisições geradores de créditos da não-cumulatividade.", "", "Promover a integração dos fiscos, mediante a padronização e compartilhamento das informações contábeis e fiscais, respeitadas as restrições legais.", "", "", "", "" } )
	aAdd( aBody, { "", "37302f8e-b0a9-1e4e-831c-9a8a7c596f18", "000004", "SPED FISCAL", "TAFA117", "TAFA117", "2", "A Escrituração Fiscal Digital - EFD é um arquivo digital, que se constitui de um conjunto de escriturações de documentos fiscais e de outras informações de interesse dos fiscos das unidades federadas e da Secretaria da Receita Federal do Brasil, bem como de registros de apuração de impostos referentes às operações e prestações praticadas pelo contribuinte. Este arquivo deverá ser assinado digitalmente e transmitido, via Internet, ao ambiente Sped.", "", "Promover a integração dos fiscos, mediante a padronização e compartilhamento das informações contábeis e fiscais, respeitadas as restrições legais.", "", "", "", "" } )
	aAdd( aBody, { "", "2044f0d3-01f7-3add-ac4e-4773eab77a26", "000005", "ECF", "TAFXECF", "TAFXECF", "1", "A Escrituração Contábil Fiscal, ou simplesmente ECF, é uma nova obrigação acessória a ser entregue ao SPED – Sistema Público de Escrituração Digital.", "", "Declarar os dados relativos a base de cálculo, valor devido do Imposto de Renda Pessoa Jurídica e da Contribuição Social sobre o Lucro Líquido e informações relacionadas.", "", "", "", "" } )

	//Verifica se o dicionario aplicado é o da DIEF-CE e da Declan-RJ
	If(AliasInDic("T30") .And. AliasInDic("T39"))
		aAdd( aBody, { "", "1376d025-5b80-d4b6-55cd-191dfd59fc47", "000006", "DIEFE-CE"		, "TAFXDFCE", "TAFXDFCE", "2", "DIEF-CE Declaração de Informações Econômico-Fiscais do estado do Ceará"	, "A declaração deverá ser entregue por todos os contribuintes do Estado, com periodicidade mensal ou anual dependendo do seu regime de recolhimento."	, "A DIEF-CE foi criada com o objetivo de consolidar várias informações  a serem prestadas pelo contribuinte em um só documento."	, "", "", "", "" } )
		aAdd( aBody, { "", "12b9dd9d-aedf-c14c-0e60-39937cedc4fd", "000007", "DECLAN - RJ"	, "TAFXDERJ", "TAFXDERJ", "2", "Declaração Anual para Apuração de IPM"										, "Contribuintes  do  ICMS  enquadrados  nos regimes  tributários  Normal,Estimativa e Outros"																	, "Valida para a Secretaria da Fazenda do Estado do Rio de Janeiro."																		, "", "", "", "" } )
		aAdd( aBody, { "", "dba0a223-5ae7-dded-4c86-fec7f210d142", "000008", "DFC - PR"		, "TAFXDFPR", "TAFXDFPR", "2", "Declaração Fisco-Contábil (DFC)"												, "A DFC é um demonstrativo das operações de entrada e saída de mercadorias abrangidas pelo ICMS, transcritas dos livros de Registros Fiscais do ICMS"	, "Valida para a Secretaria da Fazenda do Estado do Paraná."																				, "", "", "", "" } )
	EndIf

	If AliasInDic("T2D")
		aAdd( aBody, { "", "8fe41924-c75e-39a6-fc5c-270a7e07885d", "000009", "GIA - RJ", "TAFXGIRJ", "TAFXGIRJ", "2", "Guia de Informações de Apurações de ICMS/ICMS-ST do estado do Rio de Janeiro", "TODOS OS CONTRIBUINTES ESTABELECIDOS E INSCRITOS NO ESTADO DO RIO DE JANEIRO", "GIA Eletrônica - Válida para a Secretaria da Fazenda do Estado do Rio de Janeiro.", "", "", "", "" } )
	EndIf

	aAdd( aBody, { "", "492e797b-0535-76b8-36e0-76298665053d", "000010", "DMA - BA", "TAFXDMA", "TAFXDMA", "2", "Guia de preenchimento da Declaração e Apuração Mensal do ICMS - DMA", "TODOS OS CONTRIBUINTES ESTABELECIDOS E INSCRITOS NO ESTADO DA BAHIA", "Declaração Mensal de Apuração de ICMS do estado da Bahia", "", "", "", "" } )
	//aAdd( aBody, { "", "7da4de83-80aa-8375-c06a-3c097236c2c7", "000011", "DIME - SC"		, "TAFXDISC", "TAFXDISC", "2", "Declaração de Informações do ICMS e Movimento Econômico - DIME ", "A DIME será apresentada, em arquivo eletrônico, pelas contribuintes inscritos no CCICMS para informar à Secretaria da Fazenda o resumo mensal das suas operações e prestações registradas no livro Registro de Apuração do ICMS"	, "Válida para a Secretaria da Fazenda do Estado de Santa Catarina."																				, "", "", "", "" } )

	If AliasInDic("T0V")
	   aAdd( aBody, { "", "7d41f047-04b7-576c-a3e2-7341d84e50a7", "000012", "DAPI - MG"		, "TAFXDAPI"	, "TAFXDAPI" 		, "2", "Declaração de Apuração e Informação do ICMS (DAPI)"				,  "A DAPI destina-se a demonstrar, mensalmente, o movimento econômico e fiscal dos contribuintes inscritos no Cadastro de Contribuintes do ICMS de MG"	, "Válida para a Secretaria da Fazenda do Estado de Minas Gerais."																				, "", "", "", "" } )
	EndIf

	aAdd( aBody, { "", "fe4377d4-d52f-186c-ed66-2d1bce88e071", "000013", "GIM - RN"		, "TAFXGIM", "TAFXGIM", "2", "Guia Informativo Mensal (GIM)",  "A GIM-RN é um arquivo magnético em formato texto, para que os contribuintes localizados no estado do Rio Grande do Norte entreguem à Secretaria de Estado da Tributação a Guia Informativa Mensal do ICMS." , "Válida para a Secretaria da Fazenda do Estado do Rio Grande do Norte.", "", "", "", "" } )

	If AliasInDic("CWZ") .And. AliasInDic("CWY")
		aAdd( aBody, { "", "3609a1b6-faaf-67d2-8f16-628367e55426", "000014", "GIA - RS"		, "TAFXGRS", "TAFXGRS", "2", "Guia de Informação da Apuração de ICMS",  "A GIA-RS é um arquivo magnético em formato texto, para que os contribuintes localizados no estado do Rio Grande do Sul entreguem à Secretaria de Estado sua movimentação econômica e apuração do imposto ICMS devido." , "Válida para a Secretaria da Fazenda do Estado do Rio Grande do Sul.", "", "", "", "" } )
	EndIf

	aAdd( aBody, { "", "1b771a1e-1eeb-d43f-3a4f-d1149ebd477e", "000015", "GIA - ST"		, "TAFXGST", "TAFXGST", "2", "Guia de Informação da Apuração de ICMS - Substituição Tributária ",  "A GIA-ST é um arquivo magnético em formato texto, para que os contribuintes informem mensalmente à Secretaria da Fazenda todas as operações interestaduais que se enquadraram no regime de substituição tributária." , "Válida para toda Secretaria da Fazenda Estadual que optar por utilizar a GIA-ST nacional desenvolvida pelo Estado do Rio Grande do Sul.", "", "", "", "" } )
	aAdd( aBody, { "", "e81fd4fb-2b64-fd5e-0c7b-ef97681fef40", "000016", "DIAP"		, "TAFXDIAP", "TAFXDIAP", "2", "Declaração de Informações e Apuração do ICMS"				,  "É a Declaração de Informações e Apuração do ICMS que integra todos os regimes de tributação"	, "Válida para todos os contribuintes inscritos no cadastro de ICMS do Estado do Amapá"																				, "", "", "", "" } )
	aAdd( aBody, { "", "c26d07af-6c74-c047-4eb8-f1191d728be2", "000017", "DPMP", "TAFXDPMP", "TAFXDPMP", "1", "DEMONSTRATIVO DE PRODUÇÃO E MOVIMENTAÇÃO DE PRODUTOS - DPMP", "O PROJETO SIMP – SISTEMA DE INFORMAÇÕES DE MOVIMENTAÇÃO DE PRODUTOS – TEM POR OBJETIVO INSTRUMENTALIZAR OS PROCESSOS REGULATÓRIOS DA ANP, MONITORANDO, DE FORMA INTEGRADA, OS DADOS DE PRODUÇÃO", "E MOVIMENTAÇÃO DE PRODUTOS NA CADEIA DO DOWNSTREAM; PERMITINDO ASSIM O ACOMPANHAMENTO DO MERCADO; A DISPONIBILIZAÇÃO DE ESTATÍSTICAS PARA A SOCIEDADE E O APOIO TÉCNICO AO MINISTÉRIO DE MINAS E ENERGIA (MME) E AO CONSELHO NACIONAL DE POLÍTICA ENERGÉTICA (CNPE).", "", "", "", "" } )
	aAdd( aBody, { "", "e9060f62-b88a-8e69-c381-3dbfbd2aecd5", "000018", "GISSONLINE", "TAFXGISS", "TAFXGISS", "3", "GISS ONLINE - Escrituração Eletrônica do I.S.S.Q.N", "GissOnline é uma Ferramenta de Escrituração Eletrônica com Controle e Gestão Completa do I.S.S.Q.N.", "", "", "", "", "" } )
    aAdd( aBody, { "", "29f1888e-d57e-02c6-11e7-5a44aabd803d", "000019", "DES - Contagem MG", "TAFXDES", "TAFXDES", "3", "DES - Declaração Eletrônica de Serviços", "ADES é um arquivo magnético em formato texto, que destina-se à escrituração e registro mensal de todos os serviços prestados, tomados ou vinculados aos responsáveis tributários previstos na legislação municipal, acorbertados ou não por documentos fiscais e sujeitos à incidêmcia do Imposto Sobre Serviços de Qualquer Natureza (ISSQN), devido ou não ao Município de Contagem.", "", "", "", "", "" } )
    
    aAdd( aBody, { "", "e25437fe-efa8-15f2-2704-bea88af04179", "000020", "DES - Belo Horizonte MG", "TAFXDBH", "TAFXDBH", "3", "DES - Declaração Eletrônica de Serviços", "A Declaração Eletrônica de Serviços – DES é um software, distribuído gratuitamente pela Prefeitura, que tem o objetivo de facilitar a interação entre o fisco municipal e os declarantes.", "", "", "", "", ""} )
  
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )

