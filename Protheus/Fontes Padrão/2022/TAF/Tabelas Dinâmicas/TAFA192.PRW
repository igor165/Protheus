
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA192.CH"                                            

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA192
Cadastro MVC dos Produtos para emissao da GNRE Online 

@author Rodrigo Aguilar
@since 26/09/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA192()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Cadastro dos Produtos para emissão da GNRE Online"
oBrw:SetAlias( 'C6U')
oBrw:SetMenuDef( 'TAFA192' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rodrigo Aguilar
@since 26/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA192" )
//-------------------------------------------------------------------    
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 26/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC6U 	:= 	FWFormStruct( 1, 'C6U' )
Local oModel 	:= 	MPFormModel():New( 'TAFA192' )

oModel:AddFields('MODEL_C6U', /*cOwner*/, oStruC6U)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 26/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA192' )
Local 	oStruC6U 	:= 	FWFormStruct( 2, 'C6U' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C6U', oStruC6U, 'MODEL_C6U' )

oView:EnableTitleView( 'VIEW_C6U', STR0001 ) //"Cadastro dos Produtos para emissão da GNRE Online"
oView:CreateHorizontalBox( 'FIELDSC6U', 100 )
oView:SetOwnerView( 'VIEW_C6U', 'FIELDSC6U' )

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
Local aBody		:=	{}
Local aRet		:=	{}

//Para este cadastro de tabela autocontida, é necessário executar sempre que a Wizard de Configuração é processada.
//Se faz necessário, pois houve uma implementação de novos códigos que demandou aumento do tamanho do campo C6U_CODIGO de 2 para 3.
//A implementação não contemplou uma proteção para o caso do dicionário do ambiente não estar atualizado, e desta forma, pode
//ter sujado a base de dados com informações inconsistentes, como por exemplo truncar o código 108 para tamanho 2, ficando como 10
//e tratando como alteração do código 10, sendo que na verdade deveria ser inclusão do 108. 
nVerAtu := 1029.15

If nVerEmp < nVerAtu
	aAdd( aHeader, "C6U_FILIAL" )
	aAdd( aHeader, "C6U_ID" 	)
	aAdd( aHeader, "C6U_CODIGO" )
	aAdd( aHeader, "C6U_DESCRI" )
	aAdd( aHeader, "C6U_VALIDA" )

	aAdd( aBody, { "", "000001", "1", "Aguardente", "" } )
	aAdd( aBody, { "", "000002", "2", "Alcool Etilico Hidratado Combustivel (AEHC) e Alcool para fins nao-combustiveis", "" } )
	aAdd( aBody, { "", "000003", "3", "Aparelhos Celulares e Cartao Inteligente (Smart Cards e SimCard)", "" } )
	aAdd( aBody, { "", "000004", "4", "Bebidas Alcoolicas (exceto Cervejas, Chopes e Aguardente)", "" } )
	aAdd( aBody, { "", "000005", "5", "Cervejas, Chopes, Refrigerantes, Agua Mineral ou Potavel, Bebidas Eletroliticas (Isotonicas e Energeticas, nbm/sh 2106.90 e 2202.90) e Gelo", "" } )
	aAdd( aBody, { "", "000006", "6", "Cigarros e produtos derivados do fumo", "" } )
	aAdd( aBody, { "", "000007", "7", "Cimento", "" } )
	aAdd( aBody, { "", "000008", "8", "Combustiveis e Lubrificantes, derivados ou nao de petroleo, Alcool Etilico Anidro Combustivel (AEAC) e BIODIESEL B100", "" } )
	aAdd( aBody, { "", "000009", "9", "Cosmeticos, Perfumaria, Artigos de Higiene Pessoal e de Toucador", "" } )
	aAdd( aBody, { "", "000010", "10", "Discos Fonograficos, Fitas Virgens ou Gravadas e Outros Suportes para Reproducao ou Gravacao", "" } )
	aAdd( aBody, { "", "000011", "11", "Eletrodomesticos, Eletroeletronicos e Equipamentos de Informatica", "" } )
	aAdd( aBody, { "", "000012", "12", "Filmes Fotograficos e Cinematograficos e Slides", "" } )
	aAdd( aBody, { "", "000013", "13", "Gado e Produtos Resultantes de seu abate", "" } )
	aAdd( aBody, { "", "000014", "14", "Laminas de Barbear, Aparelhos de Barbear e Isqueiros de Bolso a Gas nao recarregaveis", "" } )
	aAdd( aBody, { "", "000015", "15", "Lampadas Eletricas e Eletronicas, Reatores e Starters", "" } )
	aAdd( aBody, { "", "000016", "16", "Marketing Porta-a-Porta", "" } )
	aAdd( aBody, { "", "000017", "17", "Massas Alimenticias, Biscoitos, Bolachas, Bolos, Paes, e outros derivados da farinha de trigo", "" } )
	aAdd( aBody, { "", "000018", "18", "Materiais de Construcao, Acabamentos, Bricolagens ou Adornos", "" } )
	aAdd( aBody, { "", "000019", "19", "Materiais de Limpeza", "" } )
	aAdd( aBody, { "", "000020", "20", "Pecas, Partes, Componentes, Acessorios e demais produtos para Autopropulsados", "" } )
	aAdd( aBody, { "", "000021", "21", "Pilhas, Baterias Eletricas e Acumuladores Eletricos", "" } )
	aAdd( aBody, { "", "000022", "22", "Pneumaticos, Camaras de ar e Protetores", "" } )
	aAdd( aBody, { "", "000023", "23", "Produtos Farmaceuticos", "" } )
	aAdd( aBody, { "", "000024", "24", "Racoes tipo pet para animais domesticos", "" } )
	aAdd( aBody, { "", "000025", "25", "Sorvetes e Preparados para fabricacao de sorvete em maquina", "" } )
	aAdd( aBody, { "", "000026", "26", "Suportes Elasticos para cama, Colchoes (inclusive Box), Travesseiros e Pillows", "" } )
	aAdd( aBody, { "", "000027", "27", "Tintas, Vernizes e outras mercadorias da industria quimica", "" } )
	aAdd( aBody, { "", "000028", "28", "Trigo, Farinha de Trigo e Mistura de Farinha de Trigo", "" } )
	aAdd( aBody, { "", "000029", "29", "Veiculos Automotores Novos de 4 rodas", "" } )
	aAdd( aBody, { "", "000030", "30", "Veiculos Automotores Novos Faturamento Direto para o Consumidor", "" } )
	aAdd( aBody, { "", "000031", "31", "Veiculos de Duas Rodas Motorizados", "" } )
	aAdd( aBody, { "", "000032", "32", "Telhas, cumeeira e caixas d agua de cimento, amianto, fibrocimento, polietilieno e fibra de vidro, inclusive suas tampas", "" } )
	aAdd( aBody, { "", "000033", "33", "Comercio Outros nao especificados", "" } )
	aAdd( aBody, { "", "000034", "34", "Industria nao especificados", "" } )
	aAdd( aBody, { "", "000035", "35", "Pecuaria", "" } )
	aAdd( aBody, { "", "000036", "36", "Agricultura", "" } )
	aAdd( aBody, { "", "000037", "37", "Transporte", "" } )
	aAdd( aBody, { "", "000038", "38", "Comunicacao", "" } )
	aAdd( aBody, { "", "000039", "39", "Energia Eletrica", "" } )
	aAdd( aBody, { "", "000040", "40", "Bicicletas e Pecas", "" } )
	aAdd( aBody, { "", "000041", "41", "Ferramentas", "" } )
	aAdd( aBody, { "", "000042", "42", "Instrumentos Musicais", "" } )
	aAdd( aBody, { "", "000043", "43", "Artefatos de Uso Domestico", "" } )
	aAdd( aBody, { "", "000044", "44", "Brinquedos", "" } )
	aAdd( aBody, { "", "000045", "45", "Maquinas e Aparelhos Mecanicos, Eletricos, Eletromecanicos e Automaticos", "" } )
	aAdd( aBody, { "", "000046", "46", "Material Eletrico", "" } )
	aAdd( aBody, { "", "000047", "47", "Artigos de Papelaria", "" } )
	aAdd( aBody, { "", "000048", "48", "Alcool Etilico Anidro", "" } )
	aAdd( aBody, { "", "000049", "49", "Alcool Etilico Hidratado", "" } )
	aAdd( aBody, { "", "000050", "50", "Biodiesel B100", "" } )
	aAdd( aBody, { "", "000051", "51", "Gasolina A (sem alcool anidro - AEAC)", "" } )
	aAdd( aBody, { "", "000052", "52", "Gasolina C (com alcool anidro - AEAC)", "" } )
	aAdd( aBody, { "", "000053", "53", "Gasolina de Aviacao", "" } )
	aAdd( aBody, { "", "000054", "54", "Oleo Diesel A (sem biodiesel - B100)", "" } )
	aAdd( aBody, { "", "000055", "55", "Oleo Diesel B (sem biodiesel - B100)", "" } )
	aAdd( aBody, { "", "000056", "56", "Querosene de Aviacao", "" } )
	aAdd( aBody, { "", "000057", "57", "Querosene Iluminante", "" } )
	aAdd( aBody, { "", "000058", "58", "Produtos Asfalticos", "" } )
	aAdd( aBody, { "", "000059", "59", "Coque", "" } )
	aAdd( aBody, { "", "000060", "60", "Oleo Combustivel", "" } )
	aAdd( aBody, { "", "000061", "61", "Oleo de Xisto", "" } )
	aAdd( aBody, { "", "000062", "62", "Gas Natural", "" } )
	aAdd( aBody, { "", "000063", "63", "Gas Liquefeito de Petroleo - GLP", "" } )
	aAdd( aBody, { "", "000064", "64", "Lubrificantes", "" } )
	aAdd( aBody, { "", "000065", "65", "Outros Produtos do Convenio ICMS 110/2007 (Aditivos, fluidos, aguarras, etc)", "" } )
	aAdd( aBody, { "", "000066", "66", "Derivados de petroleo e demais combustiveis e lubrificantes - exceto alcool etilico anidro, alcool etilico hidratado (AEHC) e biodisel - B100", "" } )
	aAdd( aBody, { "", "000067", "68", "Produtos alimenticios", "" } )
	aAdd( aBody, { "", "000068", "69", "Motocicletas e ciclomotores", "" } )
	aAdd( aBody, { "", "000069", "70", "Aquisicao de mercadorias de forma nao presencial (internet, telemarketing e showroom)", "" } )
	aAdd( aBody, { "", "000070", "71", "Cafe Torrado e moido", "" } )
	aAdd( aBody, { "", "000071", "72", "Calcados", "" } )
	aAdd( aBody, { "", "000072", "73", "Chocolates e preparacoes similares", "" } )
	aAdd( aBody, { "", "000073", "74", "Iogurte", "" } )
	aAdd( aBody, { "", "000074", "75", "Luvas Cirurgicas e Luvas de Procedimentos", "" } )
	aAdd( aBody, { "", "000075", "76", "Produtos Ceramicos de uso na construcao civil (utilizando argila ou barro cozido)", "" } )
	aAdd( aBody, { "", "000076", "77", "Ladrilhos, placas p/pavimentacao, cubos, pastilhas e azulejos", "" } )
	aAdd( aBody, { "", "000077", "78", "Extrato concentrados destinado ao preparo de refrigerantes em maquinas (pre-mix e pos-mix)", "" } )
	aAdd( aBody, { "", "000078", "79", "Acucar de cana", "" } )
	aAdd( aBody, { "", "000079", "80", "Salgados Industrializados", "" } )
	aAdd( aBody, { "", "000080", "81", "Bebidas Quentes", "" } )

	If TamSX3( "C6U_CODIGO" )[1] > 2
		aAdd( aBody, { "", "000081", "108", "Bebidas", "" } )
		aAdd( aBody, { "", "000082", "116", "Cigarros e Outros Produtos Derivados do Fumo", "" } )
		aAdd( aBody, { "", "000083", "124", "Veículos e Pneumáticos", "" } )
		aAdd( aBody, { "", "000084", "132", "Medicamentos e Produtos Farmacêuticos", "" } )
		aAdd( aBody, { "", "000085", "140", "Peças, Partes e Acessórios para Veículos Automotores", "" } )
		aAdd( aBody, { "", "000086", "159", "Material de Construção", "" } )
		aAdd( aBody, { "", "000087", "167", "Produtos Alimentícios", "" } )
		aAdd( aBody, { "", "000088", "175", "Cimento", "" } )
		aAdd( aBody, { "", "000089", "183", "Tintas e Vernizes", "" } )
		aAdd( aBody, { "", "000090", "191", "Venda Porta a Porta", "" } )
		aAdd( aBody, { "", "000091", "205", "Material de Limpeza Doméstica", "" } )
		aAdd( aBody, { "", "000092", "396", "Outros", "" } )
		aAdd( aBody, { "", "000093", "400", "Bebidas", "" } )
		aAdd( aBody, { "", "000094", "418", "Cigarros e Outros Produtos Derivados do Fumo", "" } )
		aAdd( aBody, { "", "000095", "426", "Veículos e Pneumáticos", "" } )
		aAdd( aBody, { "", "000096", "434", "Medicamentos e Produtos Farmacêuticos", "" } )
		aAdd( aBody, { "", "000097", "442", "Peças, Partes e Acessórios para Veículos Automotores", "" } )
		aAdd( aBody, { "", "000098", "450", "Material de Construção", "" } )
		aAdd( aBody, { "", "000099", "469", "Produtos Alimentícios", "" } )
		aAdd( aBody, { "", "000100", "477", "Cimento", "" } )
		aAdd( aBody, { "", "000101", "485", "Tintas e Vernizes", "" } )
		aAdd( aBody, { "", "000102", "493", "Venda Porta a Porta", "" } )
		aAdd( aBody, { "", "000103", "507", "Material de Limpeza Doméstica", "" } )
		aAdd( aBody, { "", "000104", "698", "Outros", "" } )
	EndIf

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAGetId

Rotina para carga e atualização da tabela autocontida.
Retorna proximo ID a ser utilizado

@Return	cRet		-	ID disponível para utilização

@Author	Veronica de Almeida Toledo
@Since		07/09/2017
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function TAFAGetId( )
	Local cRet				:= ''
	Local aAreaC6U		:= C6U->(GetArea())
	Local lContinua		:= .T.
	
	C6U->(DbSetOrder(3))	//C6U_FILIAL+C6U_ID
	
	While lContinua
		cRet	:= GetSX8Num('C6U','C6U_ID')
	
		lContinua := ( C6U->(MsSeek(xFilial('C6U') + cRet)) )
		ConfirmSX8()
	EndDo
	
	RestArea(aAreaC6U)
Return cRet