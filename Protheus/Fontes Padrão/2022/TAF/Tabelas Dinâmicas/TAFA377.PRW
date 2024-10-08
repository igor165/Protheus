#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA377.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA377
Cadastro MVC de Obriga��es Fiscais

@author Paulo S. Vilas B.Santana
@since 10/04/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA377()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001 )    //"Obriga��es Fiscais"
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

oView:EnableTitleView( 'VIEW_CHW', STR0001 )    //"Obriga��es Fiscais"
oView:CreateHorizontalBox( 'FIELDSCHW', 100 )
oView:SetOwnerView( 'VIEW_CHW', 'FIELDSCHW' )

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

	aAdd( aBody, { "", "49c5cc9e-887a-2c2a-b888-c705b2812ace", "000001", "GIA - SP", "TAFXGSP", "TAFXGSP", "2", "Guia de Informacoes de Apura��es de ICMS/ICMS-ST", "TODOS OS CONTRIBUINTES ESTABELECIDOS E INSCRITOS NO ESTADO DE SAO PAULO", "GIA Eletronica - Valida para a Secretaria da Fazenda do Estado de Sao Paulo vigorando a partir da referencia julho/2000 a Nova GIA, contem em um unico documento as informacoes economico-fiscais de 5 documentos em 1: GIA, GIA-ST-11, GINTER, Zona Franca Manaus/ALC e DIPAM-B. Portaria CAT 46/2000.", "", "DISPONIBILIZADO APENAS PARA CONTRIBUINTES CADASTRA", "21� EDI��O", "Altera��es contempladas a partir da 17� edi��o." } )
	aAdd( aBody, { "", "d30637e5-9e62-fd86-53fb-2891a664eaf2", "000002", "SINTEGRA", "TAFA119", "TAFA119", "2", "Arquivo utilizado no processamento do SINTEGRA. A utilizacao do mesmo nesta rotina torna-se desnecessaria, favor acesar a opcao Miscelanea/Arquivos Magneticos/Sintegra para processamento do mesmo.", "", "Trazer informa��es dos contribuintes aos fiscos estaduais e desenvolver o fluxo de dados nas Administra��es Tribut�rias.", "", "", "", "" } )
	aAdd( aBody, { "", "23b21ef5-fe32-769e-7b6f-2c76b1cb488d", "000003", "SPED CONTRIBUI��ES", "TAFA118", "TAFA118", "1", "A EFD-Contribui��es trata-se de um arquivo digital institu�do no Sistema Publico de Escritura��o Digital � SPED, a ser utilizado pelas pessoas jur�dicas de direito privado na escritura��o da Contribui��o para o PIS/Pasep e da Cofins, nos regimes de apura��o n�o-cumulativo e/ou cumulativo, com base no conjunto de documentos e opera��es representativos das receitas auferidas, bem como dos custos, despesas, encargos e aquisi��es geradores de cr�ditos da n�o-cumulatividade.", "", "Promover a integra��o dos fiscos, mediante a padroniza��o e compartilhamento das informa��es cont�beis e fiscais, respeitadas as restri��es legais.", "", "", "", "" } )
	aAdd( aBody, { "", "37302f8e-b0a9-1e4e-831c-9a8a7c596f18", "000004", "SPED FISCAL", "TAFA117", "TAFA117", "2", "A Escritura��o Fiscal Digital - EFD � um arquivo digital, que se constitui de um conjunto de escritura��es de documentos fiscais e de outras informa��es de interesse dos fiscos das unidades federadas e da Secretaria da Receita Federal do Brasil, bem como de registros de apura��o de impostos referentes �s opera��es e presta��es praticadas pelo contribuinte. Este arquivo dever� ser assinado digitalmente e transmitido, via Internet, ao ambiente Sped.", "", "Promover a integra��o dos fiscos, mediante a padroniza��o e compartilhamento das informa��es cont�beis e fiscais, respeitadas as restri��es legais.", "", "", "", "" } )
	aAdd( aBody, { "", "2044f0d3-01f7-3add-ac4e-4773eab77a26", "000005", "ECF", "TAFXECF", "TAFXECF", "1", "A Escritura��o Cont�bil Fiscal, ou simplesmente ECF, � uma nova obriga��o acess�ria a ser entregue ao SPED � Sistema P�blico de Escritura��o Digital.", "", "Declarar os dados relativos a base de c�lculo, valor devido do Imposto de Renda Pessoa Jur�dica e da Contribui��o Social sobre o Lucro L�quido e informa��es relacionadas.", "", "", "", "" } )

	//Verifica se o dicionario aplicado � o da DIEF-CE e da Declan-RJ
	If(AliasInDic("T30") .And. AliasInDic("T39"))
		aAdd( aBody, { "", "1376d025-5b80-d4b6-55cd-191dfd59fc47", "000006", "DIEFE-CE"		, "TAFXDFCE", "TAFXDFCE", "2", "DIEF-CE Declara��o de Informa��es Econ�mico-Fiscais do estado do Cear�"	, "A declara��o dever� ser entregue por todos os contribuintes do Estado, com periodicidade mensal ou anual dependendo do seu regime de recolhimento."	, "A DIEF-CE foi criada com o objetivo de consolidar v�rias informa��es  a serem prestadas pelo contribuinte em um s� documento."	, "", "", "", "" } )
		aAdd( aBody, { "", "12b9dd9d-aedf-c14c-0e60-39937cedc4fd", "000007", "DECLAN - RJ"	, "TAFXDERJ", "TAFXDERJ", "2", "Declara��o Anual para Apura��o de IPM"										, "Contribuintes  do  ICMS  enquadrados  nos regimes  tribut�rios  Normal,Estimativa e Outros"																	, "Valida para a Secretaria da Fazenda do Estado do Rio de Janeiro."																		, "", "", "", "" } )
		aAdd( aBody, { "", "dba0a223-5ae7-dded-4c86-fec7f210d142", "000008", "DFC - PR"		, "TAFXDFPR", "TAFXDFPR", "2", "Declara��o Fisco-Cont�bil (DFC)"												, "A DFC � um demonstrativo das opera��es de entrada e sa�da de mercadorias abrangidas pelo ICMS, transcritas dos livros de Registros Fiscais do ICMS"	, "Valida para a Secretaria da Fazenda do Estado do Paran�."																				, "", "", "", "" } )
	EndIf

	If AliasInDic("T2D")
		aAdd( aBody, { "", "8fe41924-c75e-39a6-fc5c-270a7e07885d", "000009", "GIA - RJ", "TAFXGIRJ", "TAFXGIRJ", "2", "Guia de Informa��es de Apura��es de ICMS/ICMS-ST do estado do Rio de Janeiro", "TODOS OS CONTRIBUINTES ESTABELECIDOS E INSCRITOS NO ESTADO DO RIO DE JANEIRO", "GIA Eletr�nica - V�lida para a Secretaria da Fazenda do Estado do Rio de Janeiro.", "", "", "", "" } )
	EndIf

	aAdd( aBody, { "", "492e797b-0535-76b8-36e0-76298665053d", "000010", "DMA - BA", "TAFXDMA", "TAFXDMA", "2", "Guia de preenchimento da Declara��o e Apura��o Mensal do ICMS - DMA", "TODOS OS CONTRIBUINTES ESTABELECIDOS E INSCRITOS NO ESTADO DA BAHIA", "Declara��o Mensal de Apura��o de ICMS do estado da Bahia", "", "", "", "" } )
	//aAdd( aBody, { "", "7da4de83-80aa-8375-c06a-3c097236c2c7", "000011", "DIME - SC"		, "TAFXDISC", "TAFXDISC", "2", "Declara��o de Informa��es do ICMS e Movimento Econ�mico - DIME ", "A DIME ser� apresentada, em arquivo eletr�nico, pelas contribuintes inscritos no CCICMS para informar � Secretaria da Fazenda o resumo mensal das suas opera��es e presta��es registradas no livro Registro de Apura��o do ICMS"	, "V�lida para a Secretaria da Fazenda do Estado de Santa Catarina."																				, "", "", "", "" } )

	If AliasInDic("T0V")
	   aAdd( aBody, { "", "7d41f047-04b7-576c-a3e2-7341d84e50a7", "000012", "DAPI - MG"		, "TAFXDAPI"	, "TAFXDAPI" 		, "2", "Declara��o de Apura��o e Informa��o do ICMS (DAPI)"				,  "A DAPI destina-se a demonstrar, mensalmente, o movimento econ�mico e fiscal dos contribuintes inscritos no Cadastro de Contribuintes do ICMS de MG"	, "V�lida para a Secretaria da Fazenda do Estado de Minas Gerais."																				, "", "", "", "" } )
	EndIf

	aAdd( aBody, { "", "fe4377d4-d52f-186c-ed66-2d1bce88e071", "000013", "GIM - RN"		, "TAFXGIM", "TAFXGIM", "2", "Guia Informativo Mensal (GIM)",  "A GIM-RN � um arquivo magn�tico em formato texto, para que os contribuintes localizados no estado do Rio Grande do Norte entreguem � Secretaria de Estado da Tributa��o a Guia Informativa Mensal do ICMS." , "V�lida para a Secretaria da Fazenda do Estado do Rio Grande do Norte.", "", "", "", "" } )

	If AliasInDic("CWZ") .And. AliasInDic("CWY")
		aAdd( aBody, { "", "3609a1b6-faaf-67d2-8f16-628367e55426", "000014", "GIA - RS"		, "TAFXGRS", "TAFXGRS", "2", "Guia de Informa��o da Apura��o de ICMS",  "A GIA-RS � um arquivo magn�tico em formato texto, para que os contribuintes localizados no estado do Rio Grande do Sul entreguem � Secretaria de Estado sua movimenta��o econ�mica e apura��o do imposto ICMS devido." , "V�lida para a Secretaria da Fazenda do Estado do Rio Grande do Sul.", "", "", "", "" } )
	EndIf

	aAdd( aBody, { "", "1b771a1e-1eeb-d43f-3a4f-d1149ebd477e", "000015", "GIA - ST"		, "TAFXGST", "TAFXGST", "2", "Guia de Informa��o da Apura��o de ICMS - Substitui��o Tribut�ria ",  "A GIA-ST � um arquivo magn�tico em formato texto, para que os contribuintes informem mensalmente � Secretaria da Fazenda todas as opera��es interestaduais que se enquadraram no regime de substitui��o tribut�ria." , "V�lida para toda Secretaria da Fazenda Estadual que optar por utilizar a GIA-ST nacional desenvolvida pelo Estado do Rio Grande do Sul.", "", "", "", "" } )
	aAdd( aBody, { "", "e81fd4fb-2b64-fd5e-0c7b-ef97681fef40", "000016", "DIAP"		, "TAFXDIAP", "TAFXDIAP", "2", "Declara��o de Informa��es e Apura��o do ICMS"				,  "� a Declara��o de Informa��es e Apura��o do ICMS que integra todos os regimes de tributa��o"	, "V�lida para todos os contribuintes inscritos no cadastro de ICMS do Estado do Amap�"																				, "", "", "", "" } )
	aAdd( aBody, { "", "c26d07af-6c74-c047-4eb8-f1191d728be2", "000017", "DPMP", "TAFXDPMP", "TAFXDPMP", "1", "DEMONSTRATIVO DE PRODU��O E MOVIMENTA��O DE PRODUTOS - DPMP", "O PROJETO SIMP � SISTEMA DE INFORMA��ES DE MOVIMENTA��O DE PRODUTOS � TEM POR OBJETIVO INSTRUMENTALIZAR OS PROCESSOS REGULAT�RIOS DA ANP, MONITORANDO, DE FORMA INTEGRADA, OS DADOS DE PRODU��O", "E MOVIMENTA��O DE PRODUTOS NA CADEIA DO DOWNSTREAM; PERMITINDO ASSIM O ACOMPANHAMENTO DO MERCADO; A DISPONIBILIZA��O DE ESTAT�STICAS PARA A SOCIEDADE E O APOIO T�CNICO AO MINIST�RIO DE MINAS E ENERGIA (MME) E AO CONSELHO NACIONAL DE POL�TICA ENERG�TICA (CNPE).", "", "", "", "" } )
	aAdd( aBody, { "", "e9060f62-b88a-8e69-c381-3dbfbd2aecd5", "000018", "GISSONLINE", "TAFXGISS", "TAFXGISS", "3", "GISS ONLINE - Escritura��o Eletr�nica do I.S.S.Q.N", "GissOnline � uma Ferramenta de Escritura��o Eletr�nica com Controle e Gest�o Completa do I.S.S.Q.N.", "", "", "", "", "" } )
    aAdd( aBody, { "", "29f1888e-d57e-02c6-11e7-5a44aabd803d", "000019", "DES - Contagem MG", "TAFXDES", "TAFXDES", "3", "DES - Declara��o Eletr�nica de Servi�os", "ADES � um arquivo magn�tico em formato texto, que destina-se � escritura��o e registro mensal de todos os servi�os prestados, tomados ou vinculados aos respons�veis tribut�rios previstos na legisla��o municipal, acorbertados ou n�o por documentos fiscais e sujeitos � incid�mcia do Imposto Sobre Servi�os de Qualquer Natureza (ISSQN), devido ou n�o ao Munic�pio de Contagem.", "", "", "", "", "" } )
    
    aAdd( aBody, { "", "e25437fe-efa8-15f2-2704-bea88af04179", "000020", "DES - Belo Horizonte MG", "TAFXDBH", "TAFXDBH", "3", "DES - Declara��o Eletr�nica de Servi�os", "A Declara��o Eletr�nica de Servi�os � DES � um software, distribu�do gratuitamente pela Prefeitura, que tem o objetivo de facilitar a intera��o entre o fisco municipal e os declarantes.", "", "", "", "", ""} )
  
	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )

