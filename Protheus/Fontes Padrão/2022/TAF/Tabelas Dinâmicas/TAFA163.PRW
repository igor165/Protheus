
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                                          
#INCLUDE "TAFA163.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA163
Cadastro MVC - Gênero do Item de Mercadoria/Serviço 

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA163()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Gênero do Item de Mercadoria/Serviço
oBrw:SetAlias( 'C3Z')
oBrw:SetMenuDef( 'TAFA163' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA163" )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC3Z 	:= 	FWFormStruct( 1, 'C3Z' )
Local oModel 	:= 	MPFormModel():New( 'TAFA163' )

oModel:AddFields('MODEL_C3Z', /*cOwner*/, oStruC3Z)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Mauro A. Goncalves
@since 23/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA163' )
Local 	oStruC3Z 	:= 	FWFormStruct( 2, 'C3Z' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C3Z', oStruC3Z, 'MODEL_C3Z' )

oView:EnableTitleView( 'VIEW_C3Z', STR0001 ) //Gênero do Item de Mercadoria/Serviço
oView:CreateHorizontalBox( 'FIELDSC3Z', 100 )
oView:SetOwnerView( 'VIEW_C3Z', 'FIELDSC3Z' )

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

nVerAtu := 1017.05

If nVerEmp < nVerAtu
	aAdd( aHeader, "C3Z_FILIAL" )
	aAdd( aHeader, "C3Z_ID" )
	aAdd( aHeader, "C3Z_CODIGO" )
	aAdd( aHeader, "C3Z_DESCRI" )
	aAdd( aHeader, "C3Z_VALIDA" )

	aAdd( aBody, { "", "000001", "00", "Servico", "" } )
	aAdd( aBody, { "", "000002", "01", "Animais vivos", "" } )
	aAdd( aBody, { "", "000003", "02", "Carnes e miudezas, comestiveis", "" } )
	aAdd( aBody, { "", "000004", "03", "Peixes e crustaceos, moluscos e os outros invertebrados aquaticos", "" } )
	aAdd( aBody, { "", "000100", "04", "Leite e laticínios; ovos de aves; mel natural; produtos comestíveis de origem animal, não especificados nem compreendidos em outros Capítulos da TIPI", "" } )
	aAdd( aBody, { "", "000005", "05", "Outros produtos de origem animal, nao especificados nem compreendidos em outros Capitulos da TIPI", "" } )
	aAdd( aBody, { "", "000006", "06", "Plantas vivas e produtos de floricultura", "" } )
	aAdd( aBody, { "", "000007", "07", "Produtos horticolas, plantas, raizes e tuberculos, comestiveis", "" } )
	aAdd( aBody, { "", "000008", "08", "Frutas; cascas de citricos e de meloes", "" } )
	aAdd( aBody, { "", "000009", "09", "Cafe, cha, mate e especiarias", "" } )
	aAdd( aBody, { "", "000010", "10", "Cereais", "" } )
	aAdd( aBody, { "", "000011", "11", "Produtos da industria de moagem; malte; amidos e feculas; inulina; gluten de trigo", "" } )
	aAdd( aBody, { "", "000012", "12", "Sementes e frutos oleaginosos; graos, sementes e frutos diversos; plantas industriais ou medicinais; palha e forragem", "" } )
	aAdd( aBody, { "", "000013", "13", "Gomas, resinas e outros sucos e extratos vegetais", "" } )
	aAdd( aBody, { "", "000014", "14", "Materias para entrancar e outros produtos de origem vegetal, nao especificadas nem compreendidas em outros Capitulos da NCM", "" } )
	aAdd( aBody, { "", "000015", "15", "Gorduras e oleos animais ou vegetais; produtos da sua dissociacao; gorduras alimentares elaboradas; ceras de origem animal ou vegetal", "" } )
	aAdd( aBody, { "", "000016", "16", "Preparacoes de carne, de peixes ou de crustaceos, de moluscos ou de outros invertebrados aquaticos", "" } )
	aAdd( aBody, { "", "000017", "17", "Acucares e produtos de confeitaria", "" } )
	aAdd( aBody, { "", "000018", "18", "Cacau e suas preparacoes", "" } )
	aAdd( aBody, { "", "000019", "19", "Preparacoes O base de cereais, farinhas, amidos, feculas ou de leite; produtos de pastelaria", "" } )
	aAdd( aBody, { "", "000020", "20", "Preparacoes de produtos horticolas, de frutas ou de outras partes de plantas", "" } )
	aAdd( aBody, { "", "000021", "21", "Preparacoes alimenticias diversas", "" } )
	aAdd( aBody, { "", "000022", "22", "Bebidas, liquidos alcoolicos e vinagres", "" } )
	aAdd( aBody, { "", "000023", "23", "Residuos e desperdicios das industrias alimentares; alimentos preparados para animais", "" } )
	aAdd( aBody, { "", "000024", "24", "Fumo (tabaco) e seus sucedaneos, manufaturados", "" } )
	aAdd( aBody, { "", "000025", "25", "Sal; enxofre; terras e pedras; gesso, cal e cimento", "" } )
	aAdd( aBody, { "", "000026", "26", "Minerios, escorias e cinzas", "" } )
	aAdd( aBody, { "", "000027", "27", "Combustiveis minerais, oleos minerais e produtos de sua destilacao; materias betuminosas; ceras minerais", "" } )
	aAdd( aBody, { "", "000028", "28", "Produtos quimicos inorganicos; compostos inorganicos ou organicos de metais preciosos, de elementos radioativos, de metais das terras raras ou de isotopos", "" } )
	aAdd( aBody, { "", "000029", "29", "Produtos quimicos organicos", "" } )
	aAdd( aBody, { "", "000030", "30", "Produtos farmaceuticos", "" } )
	aAdd( aBody, { "", "000031", "31", "Adubos ou fertilizantes", "" } )
	aAdd( aBody, { "", "000032", "32", "Extratos tanantes e tintoriais; taninos e seus derivados; pigmentos e outras materias corantes, tintas e vernizes, mastiques; tintas de escrever", "" } )
	aAdd( aBody, { "", "000033", "33", "Oleos essenciais e resinoides; produtos de perfumaria ou de toucador preparados e preparacoes cosmeticas", "" } )
	aAdd( aBody, { "", "000034", "34", "Saboes, agentes organicos de superficie, preparacoes para lavagem, preparacoes lubrificantes, ceras artificiais, ceras preparadas, produtos de conservacao e limpeza, velas e artigos semelhantes, massas ou pastas de model", "" } )
	aAdd( aBody, { "", "000035", "35", "Materias albuminoides; produtos O base de amidos ou de feculas modificados; colas; enzimas", "" } )
	aAdd( aBody, { "", "000036", "36", "Polvoras e explosivos; artigos de pirotecnia; fosforos; ligas piroforicas; materias inflamaveis", "" } )
	aAdd( aBody, { "", "000037", "37", "Produtos para fotografia e cinematografia", "" } )
	aAdd( aBody, { "", "000038", "38", "Produtos diversos das industrias quimicas", "" } )
	aAdd( aBody, { "", "000039", "39", "Plasticos e suas obras", "" } )
	aAdd( aBody, { "", "000040", "40", "Borracha e suas obras", "" } )
	aAdd( aBody, { "", "000041", "41", "Peles, exceto a peleteria (peles com pelo*), e couros", "" } )
	aAdd( aBody, { "", "000042", "42", "Obras de couro; artigos de correeiro ou de seleiro; artigos de viagem, bolsas e artefatos semelhantes; obras de tripa", "" } )
	aAdd( aBody, { "", "000043", "43", "Peleteria (peles com pelo*) e suas obras; peleteria (peles com pelo*) artificial", "" } )
	aAdd( aBody, { "", "000044", "44", "Madeira, carvao vegetal e obras de madeira", "" } )
	aAdd( aBody, { "", "000045", "45", "Cortica e suas obras", "" } )
	aAdd( aBody, { "", "000046", "46", "Obras de espartaria ou de cestaria", "" } )
	aAdd( aBody, { "", "000047", "47", "Pastas de madeira ou de outras materias fibrosas celulosicas; papel ou cartao de reciclar (desperdicios e aparas)", "" } )
	aAdd( aBody, { "", "000048", "48", "Papel e cartao; obras de pasta de celulose, de papel ou de cartao", "" } )
	aAdd( aBody, { "", "000049", "49", "Livros, jornais, gravuras e outros produtos das industrias graficas; textos manuscritos ou datilografados, planos e plantas", "" } )
	aAdd( aBody, { "", "000050", "50", "Seda", "" } )
	aAdd( aBody, { "", "000051", "51", "La e pelos finos ou grosseiros; fios e tecidos de crina", "" } )
	aAdd( aBody, { "", "000052", "52", "Algodao", "" } )
	aAdd( aBody, { "", "000053", "53", "Outras fibras texteis vegetais; fios de papel e tecido de fios de papel", "" } )
	aAdd( aBody, { "", "000054", "54", "Filamentos sinteticos ou artificiais", "" } )
	aAdd( aBody, { "", "000055", "55", "Fibras sinteticas ou artificiais, descontinuas", "" } )
	aAdd( aBody, { "", "000056", "56", 'Pastas ("ouates"), feltros e falsos tecidos; fios especiais; cordeis, cordas e cabos; artigos de cordoaria', "" } )
	aAdd( aBody, { "", "000057", "57", "Tapetes e outros revestimentos para pavimentos, de materias texteis", "" } )
	aAdd( aBody, { "", "000058", "58", "Tecidos especiais; tecidos tufados; rendas; tapecarias; passamanarias; bordados", "" } )
	aAdd( aBody, { "", "000059", "59", "Tecidos impregnados, revestidos, recobertos ou estratificados; artigos para usos tecnicos de materias texteis", "" } )
	aAdd( aBody, { "", "000060", "60", "Tecidos de malha", "" } )
	aAdd( aBody, { "", "000061", "61", "Vestuario e seus acessorios, de malha", "" } )
	aAdd( aBody, { "", "000062", "62", "Vestuario e seus acessorios, exceto de malha", "" } )
	aAdd( aBody, { "", "000063", "63", "Outros artefatos texteis confeccionados; sortidos; artefatos de materias texteis, calcados, chapeus e artefatos de uso semelhante, usados; trapos", "" } )
	aAdd( aBody, { "", "000064", "64", "Calcados, polainas e artefatos semelhantes, e suas partes", "" } )
	aAdd( aBody, { "", "000065", "65", "Chapeus e artefatos de uso semelhante, e suas partes", "" } )
	aAdd( aBody, { "", "000066", "66", "Guarda-chuvas, sombrinhas, guarda-sois, bengalas, bengalas-assentos, chicotes, e suas partes", "" } )
	aAdd( aBody, { "", "000067", "67", "Penas e penugem preparadas, e suas obras; flores artificiais; obras de cabelo", "" } )
	aAdd( aBody, { "", "000068", "68", "Obras de pedra, gesso, cimento, amianto, mica ou de materias semelhantes", "" } )
	aAdd( aBody, { "", "000069", "69", "Produtos ceramicos", "" } )
	aAdd( aBody, { "", "000070", "70", "Vidro e suas obras", "" } )
	aAdd( aBody, { "", "000071", "71", "Perolas naturais ou cultivadas, pedras preciosas ou semipreciosas e semelhantes, metais preciosos, metais folheados ou chapeados de metais preciosos, e suas obras; bijuterias; moedas", "" } )
	aAdd( aBody, { "", "000072", "72", "FERRO FUNDIDO, FERRO E ACO", "" } )
	aAdd( aBody, { "", "000073", "73", "Obras de ferro fundido, ferro ou aco", "" } )
	aAdd( aBody, { "", "000074", "74", "Cobre e suas obras", "" } )
	aAdd( aBody, { "", "000075", "75", "Niquel e suas obras", "" } )
	aAdd( aBody, { "", "000076", "76", "Aluminio e suas obras", "" } )
	aAdd( aBody, { "", "000077", "77", "(Reservado para uma eventual utilizacao futura no SH)", "" } )
	aAdd( aBody, { "", "000078", "78", "Chumbo e suas obras", "" } )
	aAdd( aBody, { "", "000079", "79", "Zinco e suas obras", "" } )
	aAdd( aBody, { "", "000080", "80", "Estanho e suas obras", "" } )
	aAdd( aBody, { "", "000081", "81", "OUTROS METAIS COMUNS; CERAMAIS (CERMETS); OBRAS DESSAS MATERIAS", "" } )
	aAdd( aBody, { "", "000082", "82", "Ferramentas, artefatos de cutelaria e talheres, e suas partes, de metais comuns", "" } )
	aAdd( aBody, { "", "000083", "83", "Obras diversas de metais comuns", "" } )
	aAdd( aBody, { "", "000084", "84", "Reatores nucleares, caldeiras, maquinas, aparelhos e instrumentos mecanicos, e suas partes", "" } )
	aAdd( aBody, { "", "000085", "85", "Maquinas, aparelhos e materiais eletricos, e suas partes; aparelhos de gravacao ou de reproducao de som, aparelhos de gravacao ou de reproducao de imagens e de som em televisao, e suas partes e acessorios", "" } )
	aAdd( aBody, { "", "000086", "86", "Veiculos e material para vias ferreas ou semelhantes, e suas partes; aparelhos mecanicos (incluidos os eletromecanicos) de sinalizacao para vias de comunicacao", "" } )
	aAdd( aBody, { "", "000087", "87", "Veiculos automoveis, tratores, ciclos e outros veiculos terrestres, suas partes e acessorios", "" } )
	aAdd( aBody, { "", "000088", "88", "Aeronaves e aparelhos espaciais, e suas partes", "" } )
	aAdd( aBody, { "", "000089", "89", "Embarcacoes e estruturas flutuantes", "" } )
	aAdd( aBody, { "", "000090", "90", "Instrumentos e aparelhos de optica, fotografia ou cinematografia, medida, controle ou de precisao; instrumentos e aparelhos medico-cirurgicos; suas partes e acessorios", "" } )
	aAdd( aBody, { "", "000091", "91", "Aparelhos de relojoaria e suas partes", "" } )
	aAdd( aBody, { "", "000092", "92", "Instrumentos musicais, suas partes e acessorios", "" } )
	aAdd( aBody, { "", "000093", "93", "Armas e municoes; suas partes e acessorios", "" } )
	aAdd( aBody, { "", "000094", "94", "Moveis, mobiliario medico-cirurgico; colchoes; iluminacao e construcao pre-fabricadas", "" } )
	aAdd( aBody, { "", "000095", "95", "Brinquedos, jogos, artigos para divertimento ou para esporte; suas partes e acessorios", "" } )
	aAdd( aBody, { "", "000096", "96", "Obras diversas", "" } )
	aAdd( aBody, { "", "000097", "97", "Objetos de arte, de colecao e antiguidades", "" } )
	aAdd( aBody, { "", "000098", "98", "(Reservado para usos especiais pelas Partes Contratantes)", "" } )
	aAdd( aBody, { "", "000099", "99", "Operacoes especiais (utilizado exclusivamente pelo Brasil para classificar operacoes especiais na exportacao)", "" } )

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
	Local aAreaC3Z		:= C3Z->(GetArea())
	Local lContinua		:= .T.
	
	C3Z->(DbSetOrder(3))	//C3Z_FILIAL+C3Z_ID
	
	While lContinua
		cRet	:= GetSX8Num('C3Z','C3Z_ID')
	
		lContinua := ( C3Z->(MsSeek(xFilial('C3Z') + cRet)) )
		ConfirmSX8()
	EndDo
	
	RestArea(aAreaC3Z)
Return cRet