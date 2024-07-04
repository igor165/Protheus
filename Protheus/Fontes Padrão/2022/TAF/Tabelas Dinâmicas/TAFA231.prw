#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA231.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA231
Cadastro dos Codigos de Natureza Juridica do Contribuinte

@author Anderson Costa
@since 13/08/2013
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA231()
Local   oBrw        :=  FWmBrowse():New()

oBrw:SetDescription(STR0001)    //"Cadastro dos Codigos de Natureza Juridica do Contribuinte"
oBrw:SetAlias( 'C8P')
oBrw:SetMenuDef( 'TAFA231' )
C8P->(dbSetOrder(2))
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 13/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA231" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Anderson Costa
@since 13/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC8P  :=  FWFormStruct( 1, 'C8P' )
Local oModel    :=  MPFormModel():New( 'TAFA231' )

oModel:AddFields('MODEL_C8P', /*cOwner*/, oStruC8P)
oModel:GetModel('MODEL_C8P'):SetPrimaryKey({'C8P_FILIAL', 'C8P_ID'})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Anderson Costa
@since 13/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local   oModel      :=  FWLoadModel( 'TAFA231' )
Local   oStruC8P    :=  FWFormStruct( 2, 'C8P' )
Local   oView       :=  FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C8P', oStruC8P, 'MODEL_C8P' )

oView:EnableTitleView( 'VIEW_C8P', STR0001 )    //"Cadastro dos Codigos de Natureza Juridica do Contribuinte"
oView:CreateHorizontalBox( 'FIELDSC8P', 100 )
oView:SetOwnerView( 'VIEW_C8P', 'FIELDSC8P' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualizaçao da tabela autocontida.

@Param		nVerEmp	-	Versao corrente na empresa
			nVerAtu	-	Versao atual ( passado como referencia )

@Return	aRet		-	Array com estrutura de campos e conteudo da tabela

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
	aAdd( aHeader, "C8P_FILIAL" )
	aAdd( aHeader, "C8P_ID" )
	aAdd( aHeader, "C8P_CODIGO" )
	aAdd( aHeader, "C8P_DESCRI" )
	aAdd( aHeader, "C8P_REPRES" )
	aAdd( aHeader, "C8P_QUALIF" )
	aAdd( aHeader, "C8P_VALIDA" )

	aAdd( aBody, { "", "000001", "1015", "Orgao Publico do Poder Executivo Federal"								, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000002", "1023", "Orgao Publico do Poder Executivo Estadual ou do Distrito Federal"		, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000003", "1031", "Orgao Publico do Poder Executivo Municipal"							, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000004", "1040", "Orgao Publico do Poder Legislativo Federal"							, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000005", "1058", "Orgao Publico do Poder Legislativo Estadualaou do Distrito Federal"	, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000006", "1066", "Orgao Publico do Poder Legislativo Municipal"							, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000007", "1074", "Orgao Publico do Poder Judiciario Federal"							, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000008", "1082", "Orgao Publico do Poder Judiciario Estadual"							, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000009", "1104", "Autarquia Federal"													, "Administrador ou Presidente", "05 ou 16", "" } )
	aAdd( aBody, { "", "000010", "1112", "Autarquia Estadual ou do Distrito Federal"							, "Administrador ou Presidente", "05 ou 16", "" } )
	aAdd( aBody, { "", "000011", "1120", "Autarquia Municipal"													, "Administrador ou Presidente", "05 ou 16", "" } )
	aAdd( aBody, { "", "000012", "1139", "Fundaçao Publica de Direito Publico Federal"							, "Presidente", "16", "" } )
	aAdd( aBody, { "", "000013", "1147", "Fundaçao Publica de Direito Publico Estadual ou do Distrito Federall"	, "Presidente", "16", "" } )
	aAdd( aBody, { "", "000014", "1155", "Fundaçao Publica de Direito Publico Municipal"						, "Presidente", "16", "" } )
	aAdd( aBody, { "", "000015", "1163", "Orgao Publico Autonomo Federal"										, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000016", "1171", "Orgao Publico Autonomo Estadual ou doaDistrito Federal"				, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000017", "1180", "Orgao Publico Autonomo Municipal"										, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000018", "1198", "Comissao Polinacional"												, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000019", "1201", "Fundo Publico"														, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000020", "1210", "Consorcio Publico de Direito Publico ()Associacao Publica)"			, "Presidente", "16", "" } )
	aAdd( aBody, { "", "000021", "2011", "Empresa Publica", "Administrador, Diretor ou Presidente"				, "05, 10 ou 16", "" } )
	aAdd( aBody, { "", "000022", "2038", "Sociedade de Economia Mista", "Diretor ou Presidente"					, "10 ou 16", "" } )
	aAdd( aBody, { "", "000023", "2046", "Sociedade Anonima Aberta", "Administrador, Diretor ou Presidente"		, "05, 10 ou 16", "" } )
	aAdd( aBody, { "", "000024", "2054", "Sociedade Anonima Fechada", "Administrador, Diretor ou Presidente"	, "05, 10 ou 16", "" } )
	aAdd( aBody, { "", "000025", "2062", "Sociedade Empresaria Limitada", "Administrador ou Socio-Administrador", "05 ou 49", "" } )
	aAdd( aBody, { "", "000026", "2070", "Sociedade Empresaria em Nome Coletivo"								, "Socio-Administrador", "49", "" } )
	aAdd( aBody, { "", "000027", "2089", "Sociedade Empresaria em Comandita Simples"							, "Socio Comanditado", "24", "" } )
	aAdd( aBody, { "", "000028", "2097", "Sociedade Empresaria em Comandita por Acoes"							, "Diretor ou Presidente", "10 ou 16", "" } )
	aAdd( aBody, { "", "000029", "2127", "Sociedade em Conta de Participacao"									, "Procurador ou Socio Ostensivo", "17 ou 31", "" } )
	aAdd( aBody, { "", "000030", "2135", "Empresario (Individual)"												, "Empresario", "50", "" } )
	aAdd( aBody, { "", "000031", "2143", "Cooperativa"															, "Diretor ou Presidente", "10 ou 16", "" } )
	aAdd( aBody, { "", "000032", "2151", "Consorcio de Sociedades"												, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000033", "2160", "Grupo de Sociedades"													, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000034", "2178", "Estabelecimento, no Brasil, de SociedadeaEstrangeira"					, "Procurador", "17", "" } )
	aAdd( aBody, { "", "000035", "2194", "Estabelecimento, no Brasil, de EmpresaaBinacional Argentino-Brasileira", "Procurador", "17", "" } )
	aAdd( aBody, { "", "000036", "2216", "Empresa Domiciliada no Exterior"										, "Procurador", "17", "" } )
	aAdd( aBody, { "", "000037", "2224", "Clube/Fundo de Investimento"											, "Responsavel", "43", "" } )
	aAdd( aBody, { "", "000038", "2232", "Sociedade Simples Pura"												, "Administrador ou Socio-Administrador", "05 ou 49", "" } )
	aAdd( aBody, { "", "000039", "2240", "Sociedade Simples Limitada"											, "Administrador ou Socio-Administrador", "05 ou 49", "" } )
	aAdd( aBody, { "", "000040", "2259", "Sociedade Simples em Nome Coletivo"									, "Socio-Administrador", "49", "" } )
	aAdd( aBody, { "", "000041", "2267", "Sociedade Simples em Comandita Simples"								, "Socio Comanditado", "24", "" } )
	aAdd( aBody, { "", "000042", "2275", "Empresa Binacional"													, "Diretor", "10", "" } )
	aAdd( aBody, { "", "000043", "2283", "Consorcio de Empregadores"											, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000044", "2291", "Consorcio Simples"													, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000045", "2305", "Empresa Individual de Responsabilidade Limitada (de Natureza Empresaria)", "Administrador, Procurador ou Titular Pessoa Fisica Residente ou Domiciliado no Brasil"	, "05,17 ou 65", "" } )
	aAdd( aBody, { "", "000046", "2313", "Empresa Individual de Responsabilidade Limitada (de Natureza Simples)", "Administrador, Procurador ou Titular Pessoa Fisica Residente ou Domiciliado no Brasil"		, "05,17 ou 65", "" } )
	aAdd( aBody, { "", "000047", "3034", "Servico Notarial e Registral (Cartorio)"								, "Tabeliao ou Oficial de Registro", "32 ou 42", "" } )
	aAdd( aBody, { "", "000048", "3069", "Fundacao Privada"														, "Administrador, Diretor, Presidente ouaFundador", "05, 10, 16 oua54", "" } )
	aAdd( aBody, { "", "000049", "3077", "Servico Social Autonomo"												, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000050", "3085", "Condominio Edilicio"													, "Administrador ou Sindicoa(Condominio)", "05 ou 19", "" } )
	aAdd( aBody, { "", "000051", "3107", "Comissao de Conciliacao Previa"										, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000052", "3115", "Entidade de Mediacao e Arbitragem"									, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000054", "3131", "Entidade Sindical"													, "Administrador ou Presidente", "05 ou 16", "" } )
	aAdd( aBody, { "", "000055", "3204", "Estabelecimento, no Brasil, de Fundacao ou Associacao Estrangeiras"	, "Procurador", "17", "" } )
	aAdd( aBody, { "", "000056", "3212", "Fundacao ou Associacao domiciliada no exterior"						, "Procurador", "17", "" } )
	aAdd( aBody, { "", "000057", "3220", "Organizacao Religiosa"												, "Administrador, Diretor ou Presidente", "05, 10 ou 16", "" } )
	aAdd( aBody, { "", "000058", "3239", "Comunidade Indigena"													, "Responsavel Indigena", "61", "" } )
	aAdd( aBody, { "", "000059", "3247", "Fundo Privado"														, "Administrador", "5", "" } )
	aAdd( aBody, { "", "000060", "3999", "Associacao Privada"													, "Administrador, Diretor ou Presidente", "05, 10 ou 16", "" } )
	aAdd( aBody, { "", "000061", "4014", "Empresa Individual Imobiliaria"										, "Titular", "34", "" } )
	aAdd( aBody, { "", "000062", "4081", "Contribuinte Individual"												, "Produtor Rural", "59", "" } )
	aAdd( aBody, { "", "000063", "4090", "Candidato a Cargo Politico Eletivo"									, "Candidato a Cargo Politico Eletivo", "51", "" } )
	aAdd( aBody, { "", "000064", "5010", "Organizacao Internacional"											, "Representante de OrganizacaoaInternacional", "41", "" } )
	aAdd( aBody, { "", "000065", "5029", "Representacao Diplomatica Estrangeira"								, "Diplomata, Consul, Ministro de Estadoadas Relacoes Exteriores ou ConsulaHonorario", "39, 40, 46 oua60", "" } )
	aAdd( aBody, { "", "000066", "5037", "Outras Instituicoes Extraterritoriais"								, "Representante da InstituicaoaExtraterritorial", "62", "" } )
	
	//Layout 2.2.3 
	aAdd( aBody, { "", "000067", "1228", "Consorcio Publico de Direito Privado"									, "", "", "" } )
	aAdd( aBody, { "", "000068", "1236", "Estado ou Distrito Federal"											, "", "", "" } )
	aAdd( aBody, { "", "000069", "1244", "Municipio", "Presidente"												, "", "", "" } )
	aAdd( aBody, { "", "000070", "1252", "Fundaçao Publica de Direito Privado Federal"							, "", "", "" } )
	aAdd( aBody, { "", "000071", "1260", "Fundaçao Publica de Direito Privado Estadual ou do Distrito Federal"	, "", "", "" } )
	aAdd( aBody, { "", "000072", "1279", "Fundaçao Publica de Direito Privado Municipal"						, "", "", "" } )
	
	aAdd( aBody, { "", "000073", "3255", "Orgao de Direçao Nacional de Partido Politico"						, "", "", "" } )
	aAdd( aBody, { "", "000074", "3263", "Orgao de Direçao Regional de Partido Politico"						, "", "", "" } )
	aAdd( aBody, { "", "000075", "3271", "Orgao de Direçao Local de Partido Politico"							, "", "", "" } )
	aAdd( aBody, { "", "000076", "3280", "Comite Financeiro de Partido Politico"								, "", "", "" } )
	aAdd( aBody, { "", "000077", "3298", "Frente Plebiscitaria ou Referendaria"									, "", "", "" } )
	aAdd( aBody, { "", "000078", "3306", "Organizaçao Social (OS)"												, "", "", "20180926" } )	
	
	aAdd( aBody, { "", "000079", "4022", "Segurado Especial"													, "", "", "" } )
	aAdd( aBody, { "", "000080", "4111", "Leiloeiro"															, "", "", "" } )
	aAdd( aBody, { "", "000081", "4124", "Produtor Rural (Pessoa Fisica)"										, "", "", "20180926" } )	
	
	aAdd( aBody, { "", "000082", "2321", "Sociedade Unipessoal de Advogados"									, "", "", "" } )
	aAdd( aBody, { "", "000083", "2330", "Cooperativas de Consumo"												, "", "", "" } )
	aAdd( aBody, { "", "000084", "3310", "Demais Condomínios"													, "", "", "" } )

	//Nota Técnica 09/2018
	aAdd( aBody, { "", "000085", "3301", "Organizaçao Social (OS)"												, "", "", "" } )
	aAdd( aBody, { "", "000086", "4120", "Produtor Rural (Pessoa Fisica)"										, "", "", "" } )

	aAdd( aBody, { "", "000087", "1341", "União", "", "", "" } )
	aAdd( aBody, { "", "000088", "1317", "Fundo Público da Administração Direta Federal"						,"", "", "" } )
	aAdd( aBody, { "", "000089", "1287", "Fundo Público da Administração Indireta Federal"						,"", "", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
