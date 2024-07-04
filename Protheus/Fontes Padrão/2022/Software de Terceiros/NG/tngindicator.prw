#INCLUDE	"Protheus.ch"
#INCLUDE	"TNGIndicator.ch"


/* Documenta��o das Posi��es dos Shapes utilizados nesta Classe

	Existem 8 shapes disponiveis, e cada um deles compoe um elemento diferente
	no array 'aShapes', sendo os seus sub-elementos, as definicoes do shape em si,
	que varia de acordo com o tipo.

	Antes de prosseguir, vale ressaltar que este array nao e' composto apenas por
	estas posicoes, pois ainda contem a CAMADA na qual o shape sera criado.
	Porem, por se tratar de algo simples (apenas uma posicao PAI a mais no array),
	vamos a parte mais complexa, a que interessa:

	As duas primeiras posicoes do array 'aShapes', serao sempre compostas pelo
	seu ID e seu Tipo:
		[x][1] - ID do Shape
		[x][2] - Tipo do Shape

		*Sendo 'x' qualquer tipo de shape.

	Entao, vamos as demais posicoes, que podem variar de acordo com o tipo de shape:
	[1] - RECT
		[2][3] - Left
		[2][4] - Top
		[2][5] - Largura (Width)
		[2][6] - Altura (Height)
		[2][7] - Cor do Shape
		[2][8] - Tamanho da Linha (Caneta/Contorno)
		[2][9] - Cor do Contorno do Shape
	[2] - RECTROUNDED
		[2][3] - Left
		[2][4] - Top
		[2][5] - Largura (Width)
		[2][6] - Altura (Height)
		[2][7] - Cor do Shape
		[2][8] - Tamanho da Linha (Caneta/Contorno)
		[2][9] - Cor do Contorno do Shape
	[3] - ELLIPSE
		[2][3] - Left
		[2][4] - Top
		[2][5] - Largura (Width)
		[2][6] - Altura (Height)
		[2][7] - Cor do Shape
		[2][8] - Cor do Contorno do Shape
	[4] - ARC
		[4][3] - Left
		[4][4] - Top
		[4][5] - Tamanho (Width e Height)
		[4][6] - Cor
		[4][7] - Fade (Cor da Borda)
		[4][8] - Angulo Inicial
		[4][9] - Angulo do Shape
		[4][10] - Tamanho da Linha (Caneta/Contorno)
		[4][11] - Cor da Linha (Caneta/Contorno)
	[5] - POLYGON
		[5][3] - Left 1
		[5][4] - Top 1
		[5][5] - Left 2
		[5][6] - Top 2
		[5][7] - Left 3
		[5][8] - Top 3
		[5][9] - Cor do Shape
		[5][10] - Espessura da Caneta
		[5][11] - Cor da Caneta
	[6] - LINE
		[6][3] - From Left
		[6][4] - From Top
		[6][5] - To Left
		[6][6] - To Top
		[6][7] - Largura da Linha
		[6][8] - Cor da Linha
	[7] - TEXT
		[7][3] - Left
		[7][4] - Top
		[7][5] - Largura (Width)
		[7][6] - Altura (Height)
		[7][7] - Texto
		[7][8] - Fonte do Texto
		[7][9] - Largura da Linha do Texto
		[7][10] - Cor da Linha do Text
		[7][11] - Indica se deve converter o texto (.T. - Converte ; .F. - Nao converte)
	[8] - IMAGE
		Nao utilizado.
*/

/* Melhorias a serem realizadas na Classe de Indicador:

( ) - ADEQUAR O CODIGO DA ANIMACAO DA SETA DO INDICADOR NO ESTILO Veloc�metro Comum (Atualmente esta' chumbado os valores; talvez seja possivel implementar uma equacao de reta, do tipo f(x) = ax + b)

*/

#DEFINE		__nMinWid__			160   // Largura (Widht) Minima do Indicador (at� 300) (sem considerar o zoom)
#DEFINE		__nMinHei__			160   // Altura (Height) Minima do Indicador (at� 300) (sem considerar o zoom)
#DEFINE		__nAddSiz__			35    // Incremento do tamanho do Indicador
#DEFINE		__nMinZoom__		1     // Zoom M�nimo
#DEFINE		__nMaxZoom__		5     // Zoom M�ximo
#DEFINE		__nSizeInit__		200   // Tamanho Inicial do Indicador (at� 440) (sem considerar o zoom)
#DEFINE		__nSizeZoom__		60    // Tamanho que sera adicionado ao Indicador para cada unidade de Zoom
#DEFINE		__nDecimals__		2     // Quantidade de casas decimais utilizadas para os calculos
#DEFINE		__cPictNum__		SubStr(Posicione("SX3", 2, "TZE_RESULT", "X3_PICTURE"), 1, 21) // Picture para indicador do tipo 'Num�rico'
#DEFINE		__cPictHor__		Replicate("9", Posicione("SX3", 2, "TZE_RESULT", "X3_TAMANHO")) + ":99" // Picture para indicador do tipo 'Hor�rio'
#DEFINE		__nAngIni__			-45   // �ngulo Inicial para o Indicador
#DEFINE		__nAngFim__			225   // �ngulo Final para o Indicador
#DEFINE		__nAngMax__			270   // Quantidade Total de �ngulos (desde o Inicial at� o Final)
#DEFINE		__nPorMin__			33.33 // Porcentagem PADR�O da se��o 'M�nima' (calculada AT� esta porcentagem)
#DEFINE		__nPorMax__			66.67 // Porcentagem PADR�O da se��o 'M�xima' (calculada A PARTIR desta porcentagem)

//--------------------------------------------------
// Posicoes dos Shapes na Classe
//--------------------------------------------------
Static		__nRECT	  		:= 1 // Posi��o de Shapes 'RECT'
Static		__nRECTROUNDED	:= 2 // Posi��o de Shapes 'RECTROUNDED'
Static		__nELLIPSE		:= 3 // Posi��o de Shapes 'ELLIPSE'
Static		__nARC  		:= 4 // Posi��o de Shapes 'ARC'
Static		__nPOLYGON		:= 5 // Posi��o de Shapes 'POLYGON'
Static		__nLINE	 		:= 6 // Posi��o de Shapes 'LINE'
Static		__nTEXT			:= 7 // Posi��o de Shapes 'TEXT'
Static		__nIMAGE		:= 8 // Posi��o de Shapes 'IMAGE'

Static		__nID			:= 1 // Posi��o fixa do 'ID' dos Shapes
Static		__nType			:= 2 // Posi��o fixa do 'Type' dos Shapes
Static		__nValue		:= 1 // Posi��o fixa do 'Value' do Indicador (Shape Text)

//--------------------------------------------------
// Cores Padr�es da Classe
//--------------------------------------------------
Static		__cArcCent		:= "#FFFFFF" // White
Static		__cArcEsqu		:= "#00EE00" // Green2
Static		__cArcTopo		:= "#FFA500" // Orange
Static		__cArcDire		:= "#EE0000" // Red2
Static		__cArcFade		:= "#000000" // Black
Static		__cValFore		:= "#000000" // Black
Static		__cValBack		:= "#FFFFFF" // White
Static		__cMarFore		:= "#000000" // Black
Static		__cMarBack		:= "#F5F5F5" // WhiteSmoke
Static		__cTitFore		:= "#000000" // Black
Static		__cSubFore		:= "#000000" // Black
Static		__cContorn		:= "#000000" // Black
Static		__cPntSeta		:= "#000000" // Black
Static		__cPntCent		:= "#000000" // Black

//--------------------------------------------------
// Posi��es das Cores na Classe (Array: 'aColors')
//--------------------------------------------------
Static		__nClrCent		:= 1  // Posi��o da cor '__cArcCent'
Static		__nClrEsqu		:= 2  // Posi��o da cor '__cArcEsqu'
Static		__nClrTopo		:= 3  // Posi��o da cor '__cArcTopo'
Static		__nClrDire		:= 4  // Posi��o da cor '__cArcDire'
Static		__nClrFade		:= 5  // Posi��o da cor '__cArcFade'
Static		__nClrValF		:= 6  // Posi��o da cor '__cValFore'
Static		__nClrValB		:= 7  // Posi��o da cor '__cValBack'
Static		__nClrMarF		:= 8  // Posi��o da cor '__cMarFore'
Static		__nClrMarB		:= 9  // Posi��o da cor '__cMarBack'
Static		__nClrTitF		:= 10 // Posi��o da cor '__cTitFore'
Static		__nClrSubF		:= 11 // Posi��o da cor '__cSubFore'
Static		__nClrCont		:= 12 // Posi��o da cor '__cContorn'
Static		__nClrPntS		:= 13 // Posi��o da cor '__cPntSeta'
Static		__nClrPntC		:= 14 // Posi��o da cor '__cPntCent'
Static		__nClrQtde		:= 14 // Quantidade de Cores

//--------------------------------------------------
// Posi��es dos Textos na Classe (Array: 'aTexts')
//--------------------------------------------------
Static		__nTxtTitu		:= 1 // Posi��o do texto 'T�tulo do Indicador'
Static		__nTxtSubt		:= 2 // Posi��o do texto 'Subt�tulo do Indicador'
Static		__nTxtFont		:= 3 // Posi��o do texto 'Fonte do Indicador'
Static		__nTxtQtde		:= 3 // Quantidade de Textos

//--------------------------------------------------
// Posi��es dos Sombreamentos na Classe (Array: 'aShadows')
//--------------------------------------------------
Static		__nShwCent		:= 1 // Posi��o do sombreamento 'Sombreamento Central'
Static		__nShwInfe		:= 2 // Posi��o do sombreamento 'Sombreamento Inferior'
Static		__nShwAuxi		:= 3 // Posi��o do sombreamento 'Sombreamento Auxiliar'
Static		__nShwQtde		:= 3 // Quantidade de Sombreamentos

//--------------------------------------------------
// Posi��es dos Outros na Classe (Array: 'aOthers')
//--------------------------------------------------
Static		__nOthCont		:= 1 // Posi��o da outro 'Espessura do Contorno'
Static		__nOthSeta		:= 2 // Posi��o da outro 'Espessura da Seta'
Static		__nOthQtde		:= 2 // Quantidade de Outros

//--------------------------------------------------
// Posi��es das Descri��es na Classe (Array: 'aDesc')
//--------------------------------------------------
Static		__nDesLeg1		:= 1 // Posi��o do armazenamento da descri��o 'Legenda 1' (m�nima)
Static		__nDesLeg2		:= 2 // Posi��o do armazenamento da descri��o 'Legenda 2' (intermedi�ria)
Static		__nDesLeg3		:= 3 // Posi��o do armazenamento da descri��o 'Legenda 3' (m�xima)
Static		__nDesQtde		:= 3 // Quantidade de Descri��es

//--------------------------------------------------
// Posi��es das Configura��es na Classe (Array: 'aConfig')
//--------------------------------------------------
Static		__nCfgDeft		:= 1 // Posi��o do armazenamento da se��o 'Default das Se��es'
Static		__nCfgAtua		:= 2 // Posi��o do armazenamento da se��o 'Atual das Se��es'
Static		__nCfgVals		:= 3 // Posi��o do armazenamento da se��o 'Valores e Porcetagens das Se��e M�nima e M�xima'

//--------------------------------------------------
// Posi��es das Se��es na Classe (Array: 'aRefresh')
//--------------------------------------------------
Static		__nRfsID		:= 1 // Posi��o do armazenamento do 'ID' do shape
Static		__nRfsTipo		:= 2 // Posi��o do armazenamento da 'Camada' do shape
Static		__nRfsCama		:= 3 // Posi��o do armazenamento da 'Camada' do shape
Static		__nRfsAuxi		:= 4 // Posi��o do armazenamento de 'Tipo Axualiar'
Static		__nRfsHow		:= 5 // Posi��o do armazenamento do 'Tipo de Atualiza��o'

Static		__nRfsHCom		:= 0 // Posi��o do armazenamento do 'Tipo de Atualiza��o' 'Comum'
Static		__nRfsHAtu		:= 1 // Posi��o do armazenamento do 'Tipo de Atualiza��o' 'Valor Atual'
Static		__nRfsHMar		:= 2 // Posi��o do armazenamento do 'Tipo de Atualiza��o' 'Valor dos Marcadores'
Static		__nRfsHSec		:= 3 // Posi��o do armazenamento do 'Tipo de Atualiza��o' 'Se��es'

//--------------------------------------------------
// Posi��es dos Campos na Classe (Array: 'aFields')
//--------------------------------------------------
Static		__nFldTitl		:= 1 // Posi��o do campo 'T�tulo'
Static		__nFldSubt		:= 2 // Posi��o do campo 'Subt�tulo'
Static		__nFldLeg1		:= 3 // Posi��o do campo 'Legenda 1' (se��o m�nima)
Static		__nFldLeg2		:= 4 // Posi��o do campo 'Legenda 2' (se��o intermedi�ria)
Static		__nFldLeg3		:= 5 // Posi��o do campo 'Legenda 3' (se��o m�xima)
Static		__nFldModl		:= 6 // Posi��o do campo 'Modelo'
Static		__nFldTipC		:= 7 // Posi��o do campo 'Tipo de Conte�do'
Static		__nFldQtde		:= 7 // Quantidade de Campos

//--------------------------------------------------
// Posi��es dos Blocos de C�digo (Array: 'aCodeBlock')
//--------------------------------------------------
Static		__nBBefCfg		:= 1 // Posi��o do Bloco para 'Bloco de C�digo a ser executado ANTES da Tela de Configura��o do Indicador' (o retorno deste bloco � irrelevante para a classe)
Static		__nBAftCfg		:= 2 // Posi��o do Bloco para 'Bloco de C�digo a ser executado AP�S a Tela de Configura��o do Indicador' (o retorno deste bloco � irrelevante para a classe)
Static		__nBInform		:= 3 // Posi��o do Bloco para 'Bloco de C�digo para executar as Informa��es do indicador'
Static		__nBDetail		:= 4 // Posi��o do Bloco para 'Bloco de C�digo para executar os Detalhes do indicador'
Static		__nBLegend		:= 5 // Posi��o do Bloco para 'Bloco de C�digo para executar a Legenda do indicador'
Static		__nBQtde		:= 5 // Quantidade de Itens

//--------------------------------------------------
// Outras defini��es padr�es na Classe
//--------------------------------------------------
Static		__cTxtFont		:= "Arial" // Fonte padr�o da Classe
Static		__cTxtNull		:= "---" // Texto padr�o da Classe quando n�o for definido
Static		__cShadow1		:= "#E8E8E8" // Gray91 -> 1 - Sombra Fraca
Static		__cShadow2		:= "#CFCFCF" // Gray91 -> 1 - Sombra Forte
Static		__nShadowH		:= 005 // Altura da Sombra

//--------------------------------------------------
// Estilos (modelos) de Indicadores Gr�ficos
//--------------------------------------------------
Static		__cSVeComu		:= "1" // Veloc�metro Comum
Static		__cSVeSecc		:= "2" // Veloc�metro Seccionado
Static		__cSGrBarr		:= "3" // Gr�fico em Barras
Static		__cSPirami		:= "4" // Pir�mide
Static		__cSRadar		:= "5" // Radar
Static		__cSTeia		:= "6" // Teia
Static		__cSSlider		:= "7" // Slider (horizontal)
Static		__cSCilind		:= "8" // Cilindro (vertical)
Static		__cSSemafo		:= "9" // Sem�foro (vertical)
Static		__cSPizza		:= "A" // Pizza
Static		__cSTermom		:= "B" // Term�metro

//---------------------------------------------------------------------
/*/{Protheus.doc} TNGIndicator
Classe para o controle gr�fico de Indicadores, a qual monta os objetos
em tela (shapes) para apresentar os indicadores de forma mais amig�vel.

@author Wagner Sobral de Lacerda
@since 06/10/2011

@return Self Objeto do Indicador
/*/
//---------------------------------------------------------------------
Class TNGIndicator From TPanel

	//--------------------------------------------------
	// ATRIBUTOS
	//--------------------------------------------------
	// Arrays
	DATA	aFields		AS	ARRAY	INIT	{} // Array contendo a configura��o dos campos utilizados pela classe

	DATA	aColors		AS	ARRAY	INIT	{} // Array contendo as Cores do Indicador
	DATA	aDesc		AS	ARRAY	INIT	{} // Array contendo as definicoes da Descricao do Indicador
	DATA	aOthers		AS	ARRAY	INIT	{} // Array contendo os Outros do Indicador
	DATA	aShadows	AS	ARRAY	INIT	{} // Array contendo os Sombreamentos do Indicador
	DATA	aTexts		AS	ARRAY	INIT	{} // Array contendo os Textos do Indicador
	DATA	aValues		AS	ARRAY	INIT	{} // Array contendo os Valores do Inficador

	DATA	aShapes		AS	ARRAY	INIT	{} // Array contendo os Shapes da instancia
	DATA	aConfig		AS	ARRAY	INIT	{} // Array contendo as Configuracoes das Se��es do Indicador
	DATA	aRefresh	AS	ARRAY	INIT	{} // Array contendo o ID dos shapes atualiz�veis para a Anima��o

	DATA	aAuxiliary	AS	ARRAY	INIT	{} // Array para opera��es Auxiliares apenas

	DATA	aCodeBlock	AS	ARRAY	INIT	{} // Array contendo os Blocos de C�digo do Painel de Indicadores

	// Strings
	DATA	cClrBack	AS	STRING	INIT	"#FFFFFF" // Cor do Fundo do TPaintPanel
	DATA	cContent	AS	STRING	INIT	"1" // Tipo de Conteudo dos Valores do Indicador
	DATA	cClrShdw	AS	STRING	INIT	__cShadow // Cor da Sombra
	DATA	cStyle		AS	STRING // Tipo/Estilo de Indicador
	DATA	cPicture	AS	STRING  INIT    __cPictNum__// Picture do Indicador
	DATA	cTooltip	AS	STRING // Dica (tooltip) do Indicador

	DATA	cLoadIndic	AS	STRING // C�digo do Indicador Gr�fico utilizado para carregar as configura��es do Indicador
	DATA	cLoadFilia	AS	STRING // Filial utilizada para carregar as configura��es do Indicador
	DATA	cLoadModul	AS	STRING // M�dulo do Indicador Gr�fico carregado
	DATA	cLoadFormu	AS	STRING // F�rmula carregada para o Indicador Gr�fico

	// Booleanas
	DATA	lBackgroun	AS	BOOLEAN	INIT	.F. // Valor l�gico que indica se foram criados shapes no objeto
	DATA	lIndicator	AS	BOOLEAN	INIT	.F. // Valor l�gico que indica todo o Indicador foi criado (atrav�s do m�todo 'Indicator()')
	DATA	lRefresh	AS	BOOLEAN	INIT	.F. // Valor l�gico que indica se o Indicador pode ser Atualizado via o m�todo 'Refresh()'
	DATA	lUpdating	AS	BOOLEAN	INIT	.F. // Valor l�gico que indica se existe alguma atualiza��o em processo
	DATA	lReseting	AS	BOOLEAN	INIT	.F. // Valor l�gico que indica se o objeto est� em fase de 'reset' (reinicializa��o)
	DATA	lCenter		AS	BOOLEAN	INIT	.F. // Valor l�gico que indica se o Indicador � centralizado na Tela

	DATA	lRClick		AS	BOOLEAN	INIT	.F. // Valor l�gico que indica se o clique da direita sobre o Indicador Gr�fico est� habilitado ou n�o

	// Num�ricas
	DATA	nLeft		AS	INTEGER // Posicao inicial a ESQUERDA
	DATA	nTop		AS	INTEGER // Posicao inicial ao TOPO
	DATA	nZoom		AS	INTEGER // Zoom do objeto do Indicador
	DATA	nSize		AS	INTEGER // Tamanho do objeto do Indicador
	DATA	nWidth		AS	INTEGER // Largura do TPaintPanel
	DATA	nHeight		AS	INTEGER // Altura do TPaintPanel

	DATA	nCenterL	AS	INTEGER // Centro do Objeto com relacao a sua posicao a ESQUERDA
	DATA	nCenterT	AS	INTEGER // Centro do Objeto com relacao a sua posicao ao TOPO
	DATA	nLayers		AS	INTEGER // Quantidade de camadas do objeto Indicador
	DATA	nMarcads	AS	INTEGER // Quantidade de marcadores do objeto Indicador
	DATA	nMaxVals	AS	INTEGER // Quantidade de valores do objeto Indicador
	DATA	nIDShape	AS	INTEGER	INIT	0 // ID disponivel para utilizacao de Shapes
	DATA	nIDBack		AS	INTEGER	INIT	0 // ID do Shape Background
	DATA	nArrow		AS	INTEGER	INIT	0 // Tamanho da Seta
	DATA	nBars		AS	INTEGER	INIT	0 // Quantidade de Barras
	DATA	nValue		AS	INTEGER	INIT	0 // Valor Atual do Indicador

	// Objetos
	DATA	oParent		AS	OBJECT // Objeto Pai da Classe
	DATA	oDlgOwner	AS	OBJECT // Objeto da Janela onde esta' instanciada a Classe

	DATA	oFooter		AS	OBJECT // Objeto do Rodap�
	DATA	oFootCfg	AS	OBJECT // Objeto do Botao de Configura��o do Rodap�
	DATA	oFootZoomP	AS	OBJECT // Objeto do Botao de Zoom + do Rodap� (leia 'Plus' - ingles)
	DATA	oFootZoomM	AS	OBJECT // Objeto do Botao de Zoom - do Rodap� (leia 'Minus' - ingles)

	DATA	oScroll		AS	OBJECT // Objeto do Scroll da tela
	DATA	oTPPanel	AS	OBJECT // Objeto Principal TPaintPanel

	DATA	oMnuPopUp	AS	OBJECT // Objeto do MENU POPUP

	//--------------------------------------------------
	// METODOS
	//--------------------------------------------------
	Method New(nTop, nLeft, nZoom, oParent, nWidth, nHeight, nClrFooter, cContent, cStyle, lScroll, lCenter) CONSTRUCTOR // M�todo construtor da Classe

	Method Initialize(cClrBack, aValores, aCores, aTextos, aSombras, aOutros, aDescricao) // Inicializa as variaveis e objetos do Indicador
	Method ShpNextID() // ID disponivel para o shape

	//----------
	// Setters
	//----------
	Method SetStyle(cStyle) // Seta o Estilo do Indicador
	Method SetConfig(aSetConfig) // Seta as Configura��es do Indicador
	Method SetBackgrd(cClrBack) // Seta o Shape Background
	Method SetShape(nCamada, aShape) // Seta os Shapes para o indicador
	Method SetZoom(nZoom) // Seta o Zoom
	Method SetContent(cContent) // Seta o Tipo de Conte�do do Indicador
	Method SetCenter(lCenter) // Seta a Centraliza��o do Indicador
	Method SetPicture(cPicture) // Seta a Picture dos Valores do Indicador
	Method SetValue(nValue) // Seta o Valor Atual do Indicador

	Method SetVals(aSetVals, lConfig) // Seta o Array de Valores do Indicador
	Method SetColors(aSetClrs) // Seta o Array de Cores do Indicador
	Method SetTexts(aSetTxts) // Seta o Array de Textos do Indicador
	Method SetShadows(aSetShdws) // Seta o Array de Textos do Indicador
	Method SetOthers(aSetOths) // Seta o Array de Outros do Indicador (engloba o contorno e o ponteiro)
	Method SetDesc(aSetDesc) // Seta a Descricao do Indicador
	Method SetTooltip(cTooltip) // Seta a Dica (tooltip) do Indicador

	Method SetFields(aSetFields) // Define a configura��o dos campos do Indicador
	Method SetCodeBlock(nCodeBlock, bCodeBlock) // Seta um Bloco de C�digo do Indicador
	Method SetRClick() // Seta se o clique da direita est� habilitado ou desabilitado

	//----------
	// Getters
	//----------
	Method GetStyle() // Retorna o Estilo do Indicador
	Method GetConfig() // Retorna as Configura��es do Indicador
	Method GetBackgrd() // Retorna o ID do Shape Background
	Method GetShape() // Retorna os Shapes do Indicador
	Method GetZoom() // Retorna o Zoom
	Method GetContent() // Retorna o Tipo de Conte�do
	Method GetCenter() // Retorna a Centraliza��o
	Method GetPicture() // Retorna a Picture dos Valores
	Method GetValue(lWithPict) // Retorna o Valor Atual do Indicador

	Method GetVals(lWithPict) // Retorna o Array de Valores do Indicador
	Method GetColors() // Retorna o Array de Cores do Indicador
	Method GetTexts() // Retorna o Array de Textos do Indicador
	Method GetShadows() // Retorna o Array de Textos do Indicador
	Method GetOthers() // Retorna o Array de Outros do Indicador (engloba o contorno e o ponteiro)
	Method GetDesc() // Retorna a Descricao do Indicador
	Method GetTooltip() // Retorna a Dica (tooltip) do Indicador

	Method GetFields(aSetFields) // Retorna a configura��o dos campos do Indicador
	Method GetCodeBlock(nCodeBlock) // Retorna um Bloco de C�digo do Indicador
	Method GetRClick() // Retorna se o clique da direita est� habilitado ou desabilitado

	Method GetInfo() // Retorna as Informa��es do Indicador

	//----------
	// Outros
	//----------
	Method CreateShapes() //Cria os Shapes do Indicador
	Method Indicator(lOnlyAtu) //Cria o Indicador
	Method Animate(nFromValue, nToValue, lReverse) //Executa uma animacao para o Indicador

	Method Config() //Configura o Indicador
	Method ConfigVals(uValue, lWithPict) //Executa a Configura��o dos Valores
	Method ConfigSecs(nSection, nValue, nType) //Executa a Configura��o das Se��es
	Method ConfigClrs() //Executa a Configura��o das Cores
	Method ConfigLgnd(nValue, lMarcador) //Executa a configura��o de legendas para os marcadores.
	Method Preview() //Define a Configuracao da Pre-Visualizacao (Preview)
	Method Test() //Testa o Indicador
	Method Refresh(lRefresh) //Habilita e Executa o Refresh, ou desabilita o refresh
	Method Reset(lValorAtu, lForceReset) //Reinicializa o Indicador, deletando os Shapes
	Method CopyTo(oIndicTo) // Copia o objeto para um outro objeto (ambos devem ser da classe 'TNGIndicator'

	Method MenuPopUp() // Monta o MENU POPUP do clique da direita sobre o Indicador Gr�fico
	Method CallPopUp(cMethod) // Chama a execu��o da OP��O DO MENU POPUP do clique da direita sobre o Indicador Gr�fico
	Method Information() // Mostra as Informa��es do Indicador Gr�fico
	Method Details() // Mostra os Detalhes do Indicador Gr�fico
	Method Legend() // Mostra uma Legenda para o Indicador Gr�fico

	//------------------------------
	// Libera��o / Destrui��o
	//------------------------------
	Method DeleteBackgrd() //Deleta os Shapes de Background do Indicador
	Method DeleteShapes() //Deleta os Shapes do Indicador
	Method Destroy() //Destroi o Indicador

	//----------
	// Habilitar/Desabilitar
	//----------
	Method CanConfig(lCanConfig) // Habilita/Desabilita a Configura��o do Indicador
	Method CanZoom(lCanZoom) // Habilita/Desabilita a altera��o do Zoom do Indicador
	Method CanFooter(lCanFooter) // Habilita/Desabilita o Rodap� do Indicador

	//----------
	// Exporta��o
	//----------
	Method Export() // Exporta o Objeto para uma Imagem

EndClass

/*/
############################################################################################
##                                                                                        ##
## M�TODOS: GERAIS                                                                        ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} New
M�todo Construtor da classe TNGIndicator.

@author Wagner Sobral de Lacerda
@since 06/10/2011

@param nTop
	Posi��o ao Topo do objeto pai * Opcional
	Default: 001
@param nLeft
	Posi��o a Esquerda do objeto pai * Opcional
	Default: 001
@param nZoom
	Zoom do objeto Indicador * Opcional
	- Zoom de 1 � 5
	Default: __nMinZoom__ (vari�vel)
@param oParent
	Objeto Pai da classe * Opcional
	Default: GetWndDefault() (fun��o)
@param nWidth
	Largura do objeto TPaintPanel * Opcional
	Default: __nMinWid__ (vari�vel)
@param nHeight
	Altura do objeto TPaintPanel * Opcional
	Default: __nMinHei__ (vari�vel)
@param nClrFooter
	Cor da barra do Rodape * Opcional
	Default: Branco
@param cContent
	Tipo de conte�do dos Valores * Opcional
	- "1" = Num�rico
	- "2" = Hor�rio
	Default: Num�rico
@param cStyle
	Estilo do Indicador * Opcional
	Default: __cSVeComu
@param lScroll
	Cria o Scroll * Opcional
	Default: .T.
@param lCenter
	Centraliza o Indicador de acordo com o espa�o dispon�vel * Opcional
	Default: .F.

@return Self Objeto do Indicador
/*/
//---------------------------------------------------------------------
Method New(nTop, nLeft, nZoom, oParent, nWidth, nHeight, nClrFooter, cContent, cStyle, lScroll, lCenter) Class TNGIndicator
	:New(nTop, nLeft, , oParent, , , , CLR_BLACK, CLR_WHITE, nWidth, nHeight, .F., .F.) //Inicializa o TPanel Pai da Classe

	Local nTipo   := 0
	Local nCamada := 0

	// Defaults
	Default nLeft      := 001
	Default nTop       := 001
	Default nZoom      := __nMinZoom__
	Default oParent    := GetWndDefault()
	Default nWidth     := __nMinWid__
	Default nHeight    := __nMinHei__
	Default nClrFooter := CLR_WHITE
	Default cContent   := "1" // Num�rico
	Default cStyle     := __cSVeComu // Veloc�metro Comum
	Default lScroll    := .T.
	Default lCenter    := .F.

	//Define o Tamanho Minimo do Indicador
	If nWidth < __nMinWid__
		nWidth := __nMinWid__
	EndIf
	If nHeight < __nMinHei__
		nHeight := __nMinHei__
	EndIf

	//--- Inicializa os Atributos da Classe
	::aFields := {}

	::aColors  := {}
	::aDesc    := {}
	::aOthers  := {}
	::aShadows := {}
	::aTexts   := {}
	::aValues  := {0,100}

	::aShapes  := {}
	::aConfig  := {}
	::aRefresh := {}

	::aAuxiliary := {}

	::aCodeBlock := Array(__nBQtde)

	::cContent := cContent
	::cPicture := ""
	::cTooltip := ""

	::cLoadIndic := ""
	::cLoadFilia := ""
	::cLoadModul := ""
	::cLoadFormu := ""

	::lBackgroun := .F.
	::lIndicator := .F.
	::lRefresh   := .T.
	::lUpdating  := .F.
	::lReseting  := .F.
	::lCenter    := lCenter

	::lRClick := .T.

	::nLeft     := nLeft
	::nTop      := nTop
	::nZoom     := nZoom
	::nSize     := 0
	::nCenterL  := 0
	::nCenterT  := 0
	::oParent   := oParent
	::oDlgOwner := GetWndDefault() //ATEN��O: Esta fun��o retorna o Dialog padr�o, por�m, se estiver sendo chamada dentro de um MsgRun (por exemplo), ela ir� considerar a tela do MsgRun como Dialog, e ira ocorrer uma falha
	::nWidth    := nWidth
	::nHeight   := nHeight

	::nLayers  := 7
	::nMarcads := 0
	::nMaxVals := 2 // Este controle deve estar de acordo com as posi��es do array '::aValues'

	::nIDShape := 0
	::nIDBack  := 0

	::nArrow   := 0
	::nBars    := 0
	::nValue   := 0

	// Atualiza as Coordenadas do Objeto Pai
	::oParent:CoorsUpdate()

	//--------------------------------------------------
	// ScrollBox
	//--------------------------------------------------
	If lScroll
		::oScroll := TScrollBox():New(::oParent, 0, 0, 0, 0, .T., .T., .T.)
		::oScroll:nClrPane := CLR_WHITE
		::oScroll:Align := CONTROL_ALIGN_ALLCLIENT
		::oScroll:CoorsUpdate()
	EndIf

	//--------------------------------------------------
	// TPaintPanel
	//--------------------------------------------------
	::oTPPanel := TPaintPanel():New(000, 000, ::nWidth, ::nHeight, If(lScroll, ::oScroll, ::oParent))
	::oTPPanel:CoorsUpdate()
	::oTPPanel:SetTransparent(.T.) // Quando for salva a imagem, indica que o fundo deve ser transparente

	//--------------------------------------------------
	// Rodape (Footer)
	//--------------------------------------------------
	::oFooter := TPanel():New(01, 01, , ::oParent, , , , CLR_BLACK, nClrFooter, 100, 012)
	::oFooter:Align := CONTROL_ALIGN_BOTTOM
		// Bot�o: Configura��es
		::oFootCfg := TBtnBmp2():New(01, 01, 40, 30, "ng_config", , , , {|| ::Config() }, ::oFooter, OemToAnsi(STR0001)) //"Configura��es"
		::oFootCfg:Align := CONTROL_ALIGN_LEFT
		// Bot�o: Zoom + (plus)
		::oFootZoomP := TBtnBmp2():New(01, 01, 40, 30, "ng_pg_zoom_mais", , , , {|| fSetZoom(Self, "+") }, ::oFooter, OemToAnsi(STR0002)) //"Zoom +"
		::oFootZoomP:Align := CONTROL_ALIGN_RIGHT
		// Bot�o: Zoom - (minus)
		::oFootZoomM := TBtnBmp2():New(01, 01, 40, 30, "ng_pg_zoom_menos", , , , {|| fSetZoom(Self, "-") }, ::oFooter, OemToAnsi(STR0003)) //"Zoom -"
		::oFootZoomM:Align := CONTROL_ALIGN_RIGHT

	//--------------------------------------------------
	// Define a Configuracao do Indicador de acordo com o Estilo
	//--------------------------------------------------
	::SetStyle(cStyle)

	//--------------------------------------------------
	// Define como devera ser o Array de Shapes
	//--------------------------------------------------
	/* Posicoes dos Shapes
		[1] - Rect
		[2] - RectRounded
		[3] - Ellipse
		[4] - Arc
		[5] - Polygon
		[6] - Line
		[7] - Text
		[8] - Image
	*/
	::aShapes := Array(8)
	For nTipo := 1 To Len(::aShapes)
		::aShapes[nTipo] := Array(::nLayers)

		//Os shapes sao divididos em CAMADAS, para colocar um sobre o outro, e assim formar o desenho final
		For nCamada := 1 To ::nLayers
			::aShapes[nTipo][nCamada] := {}
		Next nCamada
	Next nTipo

	//--------------------------------------------------
	// Define o MENU POPUP
	//--------------------------------------------------
	::oMnuPopUp := ::MenuPopUp()

	//--------------------------------------------------
	// Define os cliques sobre os Shapes
	//--------------------------------------------------
	::oTPPanel:bRClicked := {|nPosX, nPosY| If(::GetRClick(), ::oMnuPopUp:Activate(nPosX+005, nPosY+005, ::oParent), Nil) }

Return Self

//---------------------------------------------------------------------
/*/{Protheus.doc} Initialize
M�todo que inicializa o objeto que ira conter o Indicador, montando o
Background e setando a quantidade de Camadas e Marcadores para os shapes.

@author Wagner Sobral de Lacerda
@since 06/10/2011

@param cClrBack
	Cor do shape Background * Opcional
	Default: Branco
@param aValores
	Valores do Indicador (usado nos marcadores) * Opcional
	- Deve ter no m�ximo 7 posi��es
	Default: {}
@param aCores
	Cores do Indicador * Opcional
	- Deve ter no m�ximo __nClrQtde posi��es e serem em Hexadecimal (#000000)
	Default: {}
@param aTextos
	Textos do Indicador * Opcional
	- Deve ter no m�ximo __nTxtQtde posi��es
	Default: {}
@param aSombras
	Sombreamentos do Indicador * Opcional
	- Deve ter no m�ximo __nShwQtde posi��es
	Default: {}
@param aDescricao
	Descri��o do Indicador * Opcional
	- Deve ter no m�ximo __nOthQtde posi��es
	Default: {}

@return .T.
/*/
//---------------------------------------------------------------------
Method Initialize(cClrBack, aValores, aCores, aTextos, aSombras, aOutros, aDescricao) Class TNGIndicator

	Local cStyle := ::GetStyle()
	Local nZoom  := ::GetZoom()

	// Defaults
	Default cClrBack   := "#FFFFFF" // Branco
	Default aValores   := aClone( ::GetVals()    )
	Default aCores     := aClone( ::GetColors()  )
	Default aTextos    := aClone( ::GetTexts()   )
	Default aSombras   := aClone( ::GetShadows() )
	Default aOutros    := aClone( ::GetOthers()  )
	Default aDescricao := aClone( ::GetDesc()    )

	//Marcadores
	If cStyle $ (__cSVeComu + "/" + __cSVeSecc)
		::nMarcads := If(nZoom < 4, 7, 13)
	ElseIf ::cStyle $ (__cSSemafo + "/" + __cSPizza)
		::nMarcads := 3
	Else
		::nMarcads := If(nZoom < 4, 3, 5)
	EndIf
	//Barras
	If cStyle == __cSGrBarr
		::nBars := 16 + (2 * nZoom) //Maximo � 26 (deve ser um n�mero PAR para poder utilizar os c�lculos atuais; se for �mpar, devem ser ajustados os c�lculos do m�todo 'CreateShapes' desse estilo)
	ElseIf cStyle == __cSPirami
		::nBars := 10
	ElseIf cStyle == __cSRadar
		::nBars := If(nZoom < 4, 8, 10)
	ElseIf cStyle == __cSTeia
		::nBars := If(nZoom < 4, 10, 12)
	ElseIf cStyle == __cSSlider
		::nBars := If(nZoom < 4, 15, 30)
	ElseIf cStyle == __cSCilind
		::nBars := If(nZoom < 2, 40, If(nZoom < 3, 60, If(nZoom < 4, 80, 100)))
	ElseIf ::cStyle == __cSSemafo
		::nBars := 3 // DEVE SER APENAS 3
	ElseIf ::cStyle == __cSPizza
		::nBars := 10 // DEVE SER APENAS 10
	ElseIf ::cStyle == __cSTermom
		// n�o utiliza...
	Else
		::nBars := If(nZoom < 4, 30, 60)
	EndIf
	//Cor de Fundo
	::cClrBack := cClrBack

	//--------------------------------------------------
	// Define os Campos do Indicador
	//--------------------------------------------------
	::SetFields()

	//--------------------------------------------------
	// Define o Tamanho do Indicador
	//--------------------------------------------------
	::SetZoom(::GetZoom())

	//--------------------------------------------------
	// Define se o Indicador � centralizado
	//--------------------------------------------------
	::SetCenter()

	//--------------------------------------------------
	// Define a Picture (M�scara) utilizada
	//--------------------------------------------------
	::SetPicture()

	//--------------------------------------------------
	// Define o Tamanho do Indicador
	//--------------------------------------------------
	// Tamanho da Circunferencia = 2 * PI * R
	::nCenterL := ( ::nLeft + ( ::nSize / 2 ) )
	::nCenterT := ( ::nTop + ( ::nSize / 2 ) )

	//--------------------------------------------------
	// Define as Cores dos Shapes
	//--------------------------------------------------
	::SetColors(aCores)

	//--------------------------------------------------
	// Define os Textos do Indicador
	//--------------------------------------------------
	::SetTexts(aTextos)

	//--------------------------------------------------
	// Define os Sombreamentos do Indicador
	//--------------------------------------------------
	::SetShadows(aSombras)

	//--------------------------------------------------
	// Define os Outros do Indicador
	//--------------------------------------------------
	::SetOthers(aOutros)

	//--------------------------------------------------
	// Define os Valores Mostrados no Indicador
	//--------------------------------------------------
	::SetVals(aValores)

	//--------------------------------------------------
	// Define a Descricao do Indicador
	//--------------------------------------------------
	::SetDesc(aDescricao)

	// Se n�o estiver em processo de Atualiza��o do Indicador
	If !::lUpdating
		//--------------------------------------------------
		// Define o Valor Inicial do Indicador
		//--------------------------------------------------
		::nValue := Round(::aValues[1],__nDecimals__)

		//--------------------------------------------------
		// Inicializa ou Atualiza o Indicador
		//--------------------------------------------------
		If !::lBackgroun
			::SetBackgrd(cClrBack) //Seta o Brackground
		Else
			::Refresh()
		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ShpNextID
M�todo que identifica o pr�ximo ID dispon�vel para o shape.

@author Wagner Sobral de Lacerda
@since 06/10/2011

@return Num�rico Indica o pr�ximo ID de Shape dispon�vel
/*/
//---------------------------------------------------------------------
Method ShpNextID() Class TNGIndicator
Return ++::nIDShape

/*/
############################################################################################
##                                                                                        ##
## M�TODOS: SET                                                                           ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} SetStyle
M�todo que define o Estilo do Indicador

@author Wagner Sobral de Lacerda
@since 14/11/2011

@param cStyle
	Estilo do Indicador * Opcional
	Default: ::cStyle (estilo j� setado)

@return .T. caso tenha setado o Estilo; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method SetStyle(cStyle) Class TNGIndicator

	// Valores poss�veis para o Estilo (Modelo) do Indicador
	Local aValid := {__cSVeComu, __cSVeSecc, __cSGrBarr, __cSPirami, __cSRadar, __cSTeia, __cSSlider, __cSCilind, __cSSemafo, __cSPizza, __cSTermom}

	// Defaults
	Default cStyle := ::GetStyle()

	// Valida o Estilo
	If aScan(aValid, {|x| x == cStyle }) == 0
		fShowMsg(STR0004 + " '" + cStyle + "'." + CRLF + ; //"N�o foi poss�vel carregar o estilo (modelo de indicador)"
					STR0005 + " '" + __cSVeComu + "'.", "I") //"Por padr�o, ser� atribu�do o estilo"
		cStyle := "1"
	EndIf

	// Atualiza somente se o estilo for diferente
	If ::cStyle <> cStyle
		// Limpa o array de refresh
		::aRefresh := {}

		// Define a quantidade de valores utilizados
		If cStyle $ (__cSVeComu + "/" + __cSVeSecc)
			::nMaxVals := 7
		Else
			::nMaxVals := 5
		EndIf

		// Define o novo Estilo
		::cStyle := cStyle

		// Armazena novo array de Configura��o das Se��es
		::SetConfig()

		//--- Atualiza o Indicador caso ja' esteja criado
		::Refresh()
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetConfig
M�todo que define o array de Configura��o das Se��es do Indicador.

@author Wagner Sobral de Lacerda
@since 20/12/2012

@param aSetConfig
	Dados de Configura��o do Indicaodr * Opcional
	Defautl: ::GetConfig()

@return .T. caso tenha setado o array de Configura��es; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method SetConfig(aSetConfig) Class TNGIndicator

	Local cStyle := ::GetStyle()

	// Defaults
	Default aSetConfig := aClone( ::GetConfig() )

	::aConfig := {}

	If cStyle == __cSVeComu
		aAdd(::aConfig, { {135,90}, {045,90}, {__nAngIni__,90} }) // �ngulos dos Arcos 'Default'
		aAdd(::aConfig, { {135,90}, {045,90}, {__nAngIni__,90} }) // �ngulos dos Arcos 'Atual'
	ElseIf cStyle == __cSVeSecc
		aAdd(::aConfig, {2,4}) // Se��es das Barras 'Default'
		aAdd(::aConfig, {2,4}) // Se��es das Barras 'Atual'
	Else
		aAdd(::aConfig, {(__nPorMin__)/100,(__nPorMax__)/100}) // Se��es das Barras 'Default'
		aAdd(::aConfig, {(__nPorMin__)/100,(__nPorMax__)/100}) // Se��es das Barras 'Atual'
	EndIf
	aAdd(::aConfig, { {0,0}, {0,0} }) // Valor Num�rico e em Porcentagem da distribui��o atual das Se��es M�nima e M�xima (respectivamente)

	// Carrega as Se��es de acordo com as configura��es antigas
	// Obs.: Recebe apenas as Porcentagem, pois os valores ser�o calculados pelo m�todo 'ConfigSecs()'
	If Len(aSetConfig) >= __nCfgVals
		::aConfig[__nCfgVals][1][2] := aSetConfig[__nCfgVals][1][2]
		::aConfig[__nCfgVals][2][2] := aSetConfig[__nCfgVals][2][2]
	Else
		// Sen�o, inicializa de forma padr�o
		::aConfig[__nCfgVals][1][2] := __nPorMin__
		::aConfig[__nCfgVals][2][2] := __nPorMax__
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetBackgrd
M�todo que adiciona os Shapes da camada Background.

@author Wagner Sobral de Lacerda
@since 20/10/2011

@param cClrBack
	Cor do shape Background * Opcional
	Default: Branco

@return .T. Background adicionado; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method SetBackgrd(cClrBack) Class TNGIndicator

	Local aShape := {}
	Local nID    := 0
	Local nTipo  := 0

	Local nSomaPnl := 0
	Local nSetWid  := 0
	Local nSetHei  := 0

	// Defaults
	Default cClrBack := ::cClrBack

	If ::GetBackgrd() > 0 //Shape Background ja' existe
		Return .F.
	EndIf

	// Define o Tamanho do Shape Background (temos que multiplicar por 2 pq o tamanho real � sempre dividido por 2)
	nSomaPnl := ( (__nAddSiz__ * 2) * (__nMaxZoom__-1))
	nSetWid  := ( (__nMinWid__ * 2) + nSomaPnl )
	nSetHei  := ( (__nMinHei__ * 2) + nSomaPnl )

	//--------------------------------------------------
	// Shape Background (tipo 1 - RECT)
	//--------------------------------------------------
	nTipo := __nRECT

	nID     := ::ShpNextID()
	nCamada := 1
	aShape  := {nID, nTipo, 0, 0, nSetWid, nSetHei, cClrBack, 0, cClrBack}
	::SetShape(nCamada, aShape) //Branco

	//ID do Shape Background
	::nIDBack := nID
	//Atualiza a variavel que identifica se existe o shape Background
	::lBackgroun := .T.

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetShape
M�todo que adiciona o Shape ao array de Shapes.

@author Wagner Sobral de Lacerda
@since 06/10/2011

@param nCamada
	Camada em que o shape ser� adicionado * Obrigat�rio
	Default: Branco
@param aShape
	Array contendo as informa��es do shape * Obrigat�rio

@return .T. shape adicionado; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method SetShape(nCamada, aShape) Class TNGIndicator

	Local nTipo := 0

	// Defaults
	Default nCamada := ::nLayers
	Default aShape  := {}

	//Valida a camada
	If nCamada < 1
		nCamada := 1
	ElseIf nCamada > ::nLayers
		nCamada := ::nLayers
	EndIf

	//Valida o array contendo o shape
	If Len(aShape) < 2
		Return .F.
	EndIf
	nTipo := aShape[2]

	//--- Adiciona o Shape
	aAdd(::aShapes[nTipo][nCamada], aShape)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetZoom
M�todo que seta o Zoom do Indicador, influenciado em seu tamanho.

@author Wagner Sobral de Lacerda
@since 06/10/2011

@param nZoom
	Zoom do Indicador * Obrigat�rio
	Default: Branco

@return .T. Zoom setado; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method SetZoom(nZoom) Class TNGIndicator

	Local nSomaSize := 0
	Local nSomaPnl  := 0
	Local lMenor    := .F.

	// Defaults
	Default nZoom := __nMinZoom__

	// Valida o Zoom
	If nZoom < __nMinZoom__
		nZoom := __nMinZoom__
	ElseIf nZoom > __nMaxZoom__
		nZoom := __nMaxZoom__
	EndIf

	// Se j� desenhou em tela, n�o � necess�rio setar o mesmo zoom
	If ::lIndicator .And. ::nZoom == nZoom
		Return .F.
	EndIf
	// Verifica se o Zoom que estamos querendo seta � menor do que o que j� est� setado
	lMenor := (nZoom < ::nZoom)

	// Atribui o Zoom
	::nZoom := nZoom

	// Define intensidade do Sombreamento
	::cClrShdw := If(nZoom <= 3, __cShadow1, __cShadow2)

	// Define o tamanho do Indicador
	nSomaSize := ( __nSizeZoom__ * (nZoom-1) )
	::nSize   := ( __nSizeInit__ + nSomaSize )

	If IsInCallStack("FSETZOOM") .And. lMenor
		fDefScroll(Self)
	EndIf

	// Redefine o tamanho do TPaintPanel
	nSomaPnl := ( (__nAddSiz__ * 2) * (nZoom-1))
	::oTPPanel:nWidth  := ( (__nMinWid__ * 2) + nSomaPnl )
	::oTPPanel:nHeight := ( (__nMinHei__ * 2) + nSomaPnl )
	::oTPPanel:CoorsUpdate()

	If ValType(::oScroll) == "O"
		::oScroll:CoorsUpdate()
	EndIf

	//--- Atualiza o Indicador caso ja' esteja criado
	::Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetContent
M�todo que seta o Tipo de Conte�do do Indicador.

@author Wagner Sobral de Lacerda
@since 13/02/2012

@param cContent
	Conte�do do Indicador * Opcional
	Default: ::cContent (tipo de conte�do j� setado)

@return .T. Tipo de Conte�do setado; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method SetContent(cContent) Class TNGIndicator

	Local aValid := {"1", "2"} // Valores poss�veis para o Tipo de Conte�do

	// Defaults
	Default cContent := ::cContent

	// Valida o Tipo de Conte�do
	If aScan(aValid, {|x| x == cContent }) == 0
		Return .F.
	EndIf

	// Define o Tipo de Conte�do
	::cContent := cContent

	// Define a Picture (M�scara) dos valores
	::SetPicture()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetCenter
M�todo que seta as posi��es do Indicador de maneira que fique
Centralizado.

@author Wagner Sobral de Lacerda
@since 06/02/2012

@param lCenter
	Indica se deve ser Centralizado * Opcional
	Default: ::GetCenter()

@return .T. Centraliza��o setada; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method SetCenter(lCenter) Class TNGIndicator

	Local nLeft   := ::nLeft
	Local nTop    := ::nTop
	Local nSize   := ::nSize
	Local nWidth  := 0
	Local nHeight := 0

	Local nParentWid := ::oParent:nClientWidth
	Local nParentHei := ::oParent:nClientHeight
	Local nTPPnlWid  := ::oTPPanel:nClientWidth
	Local nTPPnlHei  := ::oTPPanel:nClientHeight

	Local nHalf := 0

	// Defaults
	Default lCenter := ::GetCenter()

	// Valida se deve Centralizar
	If !lCenter
		Return .F.
	EndIf

	// Recebe qual o Tamanho para calcular
	// ( o Tamanho deve estar entre o m�nimo e o m�ximo do Painel que cont�m o Indicador)
	nWidth  := If(nParentWid > nTPPnlWid, nTPPnlWid, nParentWid)
	nHeight := If(nParentHei > nTPPnlHei, nTPPnlHei, nParentHei)

	//------------------------------
	// Define a Centraliza��o
	//------------------------------

	// Metade do Tamanho
	nHalf := ( nSize / 2 )

	// Posi��o a Esquerda = Centro da Largura - Metade do Tamanho
	nLeft := ( (nWidth * 0.50) - nHalf )

	// Posi��o ao Topo = Centro da Altura - Metade do Tamanho - Espa�o do T�tulo
	nTop := ( (nHeight * 0.50) - (nHalf*1.2) )

	//------------------------------
	// Finaliza
	//------------------------------

	// Valida as posi��es (n�o podem ser negativas)
	If nLeft < 0
		nLeft := ::oParent:nLeft + 005
	EndIf
	If nTop < 0
		nTop := ::oParent:nTop + 005
	EndIf

	//--- Atribui as novas posi��es
	::nLeft := nLeft
	::nTop  := nTop

	//--- Atualiza o Indicador caso ja' esteja criado
	::Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetPicture
M�todo que seta a Picture dos Valores do Indicador, de acordo com o
Tipo de Conte�do.

@author Wagner Sobral de Lacerda
@since 13/02/2012

@param cPicture
	Picture (M�scara) dos Valores * Opcional
	Default: "" (em branco -> receber� de acordo com o tipo de conte�do)

@return .T. Picture setada; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method SetPicture(cPicture) Class TNGIndicator

	Local cContent := ::GetContent()

	// Defaults
	Default cPicture := ""

	// Valida a Picture
	If Empty(cPicture)
		If cContent == "1" // Num�rico
			cPicture := __cPictNum__
		ElseIf cContent == "2" // Hor�rio
			cPicture := __cPictHor__
		EndIf
	EndIf

	// Define a Picture
	::cPicture := cPicture

	//--- Atualiza o Indicador caso ja' esteja criado
	::Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetValue
M�todo que seta o Indicador para o Valor do parametro.

@author Wagner Sobral de Lacerda
@since 20/10/2011

@param nValue
	Valor para o qual o Indicador deve ser atualizado * Opcional
	Default: ::GetValue() (valor j� setado)

@return .T. Valor Setado para o Indicador; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method SetValue(nValue) Class TNGIndicator

	Local aValores := aClone( ::GetVals()   )

	Local cStyle   := ::GetStyle()

	Local nX := 0, nY := 0, nPos := 0

	Local nInicial  := 0
	Local nFinal    := 0
	Local nSecTotal := 0
	Local nSecAtual := 0
	Local nBarsSec  := 0

	Local nSizeSecao := 0
	Local nFromLeft  := 0
	Local nFromTop   := 0
	Local nToLeft    := 0
	Local nToTop     := 0

	Local uAux1 := Nil, uAux2 := Nil, uAux3 := Nil

	// Defaults
	Default nValue := ::GetValue()

	//Valida se consegue atualizar o Indicador
	If Len(aValores) == 0
		Return .F.
	EndIf

	//Converte o Valor para Num�rico
	nValue := ::ConfigVals(nValue)

	//Define o valor Atual
	::nValue := Round(nValue,__nDecimals__)

	//--------------------------------------------------
	// Atualiza o Indicador
	//--------------------------------------------------
	If cStyle == __cSVeComu // Velec�metro Comum

		//Define o Valor Inicial e Final do Indicador
		nInicial := aValores[1]
		nFinal   := aValores[Len(aValores)]

		//Define o Tamango de cada Secao
		nSizeSecao := ::nArrow
		nToLeft    := ::nCenterL //Default = Centro
		nToTop     := ::nCenterT //Default = Centro

		If Round(nValue,__nDecimals__) <= Round(nInicial,__nDecimals__)
			//--------------------------------------------------
			// Minimo
			//--------------------------------------------------
			nToLeft := ::nCenterL - ::nArrow
			nToTop  := ::nCenterT + ::nArrow
		ElseIf Round(nValue,__nDecimals__) >= Round(nFinal,__nDecimals__)
			//--------------------------------------------------
			// Maximo
			//--------------------------------------------------
			nToLeft := ::nCenterL + ::nArrow
			nToTop  := ::nCenterT + ::nArrow
		Else
			//Secciona o Indicador (evite arredondar aqui, pois isto influenciara' em todo o resto dos calculos)
			nPos := aScan(aValores, {|x| Round(x,__nDecimals__) >= Round(nValue,__nDecimals__) })
			If nPos == 0 //Lembrando que o aScan j� vasculhou o array. S� sobraram ent�o os valores menores que o menor, ou maiores que o maior
				nPos := Len(aValores) //Se nao encontrou, diz que � a �ltima posi��o
				If Round(nValue,__nDecimals__) < aValores[nPos]
					nPos := 1 //Mas se for menor que o �ltimo registro, diz que � a primeira
				EndIf
			EndIf
			If nPos == 1
				nInicial := aValores[nPos]
				nFinal   := aValores[nPos]
			Else
				nInicial := aValores[(nPos-1)]
				nFinal   := aValores[nPos]
			EndIf

			nSecTotal := ( (nFinal - nInicial) / 2 ) //2 e' a quantidade de Marcadores para o calculo personalizado

			//Calculo personalizado da Secao Atual
			nSecAtual := (nPos-1) + ( ( (nValue - nInicial) / nSecTotal ) / 2 )

			//Define a posicao mais proxima para o Ponteiro
			uAux1 := 0
			uAux2 := ( nSecAtual - Int(nSecAtual) )
			For nX := 1 To Len(aValores)
				If Round(nValue,__nDecimals__) < Round(aValores[nX],__nDecimals__)
					Exit
				ElseIf Round(nValue,__nDecimals__) == Round(aValores[nX],__nDecimals__)
					nSecAtual := Round(nSecAtual,__nDecimals__)
					uAux1 := nX
					uAux2 := 0
					Exit
				EndIf
				uAux1 := nX
			Next nX

			If ::nMarcads == 7 .Or. ::nMarcads == 13
				//--------------------------------------------------
				// 7 ou 13 MARCADORES (desconsidera os extremos)
				//--------------------------------------------------
				If uAux1 == 1
					nToLeft := ::nCenterL - ::nArrow
					nToTop  := ::nCenterT + ::nArrow

					uAux3 := ( uAux2 / (2+uAux2) )

					nToLeft -= ( nSizeSecao * uAux3 ) //Altera um pouco o Tamanho da Seta
					nToTop  -= ( nSizeSecao * uAux2 )

					If uAux2 > 0.9
						nToLeft += (1)
					EndIf
				ElseIf uAux1 == 2
					nToLeft := ::nCenterL - ::nArrow
					nToTop  := ::nCenterT

					uAux3 := ( ABS(uAux2-1) / (2+ABS(uAux2-1)) )

					nToLeft -= ( nSizeSecao * uAux3 ) //Altera um pouco o Tamanho da Seta
					nToTop  -= ( nSizeSecao * uAux2 )

					If uAux2 < 0.1
						nToLeft += (1)
					ElseIf uAux2 < 0.25
						nToLeft += (1)
					ElseIf uAux2 > 0.9
						nToLeft += (2)
						nToTop  += (2)
					ElseIf uAux2 > 0.75
						nToLeft += (1)
						nToTop  += (1)
					EndIf
				ElseIf uAux1 == 3
					nToLeft := ::nCenterL - ::nArrow
					nToTop  := ::nCenterT - ::nArrow

					uAux3 := ( uAux2 / (2+uAux2) )

					nToLeft += ( nSizeSecao * uAux2 )
					nToTop  -= ( nSizeSecao * uAux3 ) //Altera um pouco o Tamanho da Seta

					If uAux2 < 0.1
						nToLeft += (3)
						nToTop  += (3)
					ElseIf uAux2 < 0.25
						nToLeft += (1)
						nToTop  += (1)
					ElseIf uAux2 > 0.9
						nToLeft += (2)
						nToTop  += (2)
					ElseIf uAux2 > 0.75
						nToLeft += (1)
						nToTop  += (1)
					EndIf
				ElseIf uAux1 == 4
					nToLeft := ::nCenterL
					nToTop  := ::nCenterT - ::nArrow

					uAux3 := ( ABS(uAux2-1) / (2+ABS(uAux2-1)) )

					nToLeft += ( nSizeSecao * uAux2 )
					nToTop  -= ( nSizeSecao * uAux3 ) //Altera um pouco o Tamanho da Seta

					If uAux2 < 0.1
						nToTop  += (2)
					ElseIf uAux2 < 0.25
						nToLeft -= (1)
						nToTop  += (1)
					ElseIf uAux2 > 0.9
						nToLeft -= (2)
						nToTop  += (2)
					ElseIf uAux2 > 0.75
						nToLeft -= (1)
						nToTop  += (1)
					EndIf
				ElseIf uAux1 == 5
					nToLeft := ::nCenterL + ::nArrow
					nToTop  := ::nCenterT - ::nArrow

					uAux3 := ( uAux2 / (2+uAux2) )

					nToLeft += ( nSizeSecao * uAux3 ) //Altera um pouco o Tamanho da Seta
					nToTop  += ( nSizeSecao * uAux2 )

					If uAux2 < 0.1
						nToLeft -= (3)
						nToTop  += (3)
					ElseIf uAux2 < 0.25
						nToLeft -= (1)
						nToTop  += (1)
					ElseIf uAux2 > 0.75
						nToLeft -= (1)
					EndIf
				ElseIf uAux1 == 6
					nToLeft := ::nCenterL + ::nArrow
					nToTop  := ::nCenterT

					uAux3 := ( ABS(uAux2-1) / (2+ABS(uAux2-1)) )

					nToLeft += ( nSizeSecao * uAux3 ) //Altera um pouco o Tamanho da Seta
					nToTop  += ( nSizeSecao * uAux2 )

					If uAux2 < 0.1
						nToLeft -= (3)
					EndIf
				EndIf
			EndIf
		EndIf

		//Redefine o Shape do Ponteiro
		::aShapes[__nLINE][6][1][5] := nToLeft
		::aShapes[__nLINE][6][1][6] := nToTop

	// Qualquer outro que utilize porcentagens padr�es
	Else

		// Atualiza os Shapes e Se��es
		fAtuSects(Self, nValue)

	EndIf

	//--- Atualiza os SHAPES em Tela do Indicador apenas se n�o estiver em processo de atualiza��o
	If !::lUpdating
		::Indicator(.T.)
	EndIf

Return .T.

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetVals
M�todo que seta o Array de Valores do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@param aSetVals, Array	, Array com os Valores para o Indicador * Opcional
	   lConfig , L�gico , Verifica se o conteudo vem do painel de indicadores ou da configura��o.
	Default: ::GetVals (valores j� setados)

@return .T. caso tenha setado; .F. se ocorreu algum problema
/*/
//------------------------------------------------------------------------------------------------
Method SetVals(aSetVals, lConfig) Class TNGIndicator

	Local cStyle    := ::GetStyle()
	Local cContent  := ::GetContent()
	Local aConfig   := aClone( ::GetConfig() )
	Local aCalcVals := {}
	Local nZoom     := ::GetZoom()
	Local nQtdeVals := ::nMaxVals
	Local nPosVal   := 0
	Local nMaiorVal := 0
	Local nX        := 0
	Local nLayer    := 0
	Local nShape    := 0
	Local nSec1Por  := 0
	Local nSec2Por  := 0

	Default aSetVals := aClone( ::GetVals() )
	Default lConfig	 := .F.

	If !lConfig
		// Converte os Valores de acordo com o tipo de conteudo (iremos trabalhar com Num�ricos apenas para facilitar os c�lculos)
		aSetVals := aClone( ::ConfigVals(aSetVals) )

		// Verifica se existe apenas uma Valor definido (neste caso, utiliza-se um valor 'default' pois o array deve ter no minimo duas posicoes)
		If Len(aSetVals) < 2
			aSetVals := aClone( ::GetVals() )
		EndIf

		// TRUNCA o array caso ele seja maior do que o permitido para o estilo do Indicador
		If Len(aSetVals) > nQtdeVals
			nMaiorVal := aTail(aSetVals)
			While Len(aSetVals) > nQtdeVals
				If aTail(aSetVals) > nMaiorVal
					nMaiorVal := aTail(aSetVals)
				EndIf

				aDel(aSetVals, Len(aSetVals))
				aSize(aSetVals, (Len(aSetVals)-1))
			End

			// Seta o array para considerar o valor maior, recalculando todo o resto
			If nMaiorVal > aTail(aSetVals)
				aSetVals := { aSetVals[1], nMaiorVal }
			EndIf
		EndIf

		// Valida o Array de Valores
		If !fValidVals(aSetVals)
			Return .F.
		EndIf

		// Define o Array de Valores
		If cStyle $ (__cSVeComu + "/" + __cSVeSecc)
			If Len(aSetVals) == nQtdeVals
				aCalcVals := aClone( aSetVals )
			ElseIf Len(aSetVals) == 3
				// Se 3 (tr�s) valores estiverem pre-definidos, entao calcula um 'range' Minimo, Intermediario e Maximo
				aCalcVals := Array(nQtdeVals)

				// Define valores do Minimo ate' o Intermediario
				nInicial := aSetVals[1]
				nFinal   := aSetVals[2]
				nSomaVal := ( (nFinal - nInicial) /  3)
				For nX := 1 To 4
					If nX > 1
						nInicial += nSomaVal
					EndIf

					aCalcVals[nX] := Round(nInicial,__nDecimals__)
				Next nX

				// Define valores do Intermediario ate' o Final
				nInicial := aSetVals[2]
				nFinal   := aSetVals[3]
				nSomaVal := ( (nFinal - nInicial) /  3)
				For nX := 5 To 7
					If nX > 1
						nInicial += nSomaVal
					EndIf

					aCalcVals[nX] := Round(nInicial,__nDecimals__)
				Next nX
			Else
				If Len(aSetVals) >= 2 .And. aSetVals[Len(aSetVals)] <= aSetVals[1] //Se o valor Maximo for menor ou igual ao valor Minimo
					aCalcVals := {aSetVals[1], aSetVals[Len(aSetVals)]}
				Else
					// Define Valores
					nInicial := aSetVals[1]
					nFinal   := aSetVals[Len(aSetVals)]
					nSomaVal := ( (nFinal - nInicial) / (nQtdeVals - 1) )

					aCalcVals := Array(nQtdeVals)
					For nX := 1 To (nQtdeVals-1)
						If nX > 1
							nInicial += nSomaVal
						EndIf

						aCalcVals[nX] := Round(nInicial,__nDecimals__)
					Next nX
					aCalcVals[Len(aCalcVals)] := Round(nFinal,__nDecimals__)
				EndIf
			EndIf
		Else
			If Len(aSetVals) == nQtdeVals
				aCalcVals := aClone( aSetVals )
			Else
				aCalcVals := Array(nQtdeVals)
				aCalcVals[1] := aSetVals[1]
				aCalcVals[5] := aSetVals[Len(aSetVals)]

				If Len(aSetVals) == 3
					aCalcVals[3] := aSetVals[2]
				Else
					aCalcVals[3] := ( (aCalcVals[1]+aCalcVals[5]) / 2 )
				EndIf
				aCalcVals[2] := ( (aCalcVals[1]+aCalcVals[3]) / 2 )
				aCalcVals[4] := ( (aCalcVals[3]+aCalcVals[5]) / 2 )
			EndIf
		EndIf
		::aValues := aClone(aCalcVals)
	Else
		::aValues := aClone(aSetVals)
	EndIf

	// Redefine os Shapes dos Valores dos Marcadores
	nPosVal := 0
	For nX := 1 To Len(::aRefresh)
		If ::aRefresh[nX][__nRfsHow] == __nRfsHMar
			nTipo   := __nTEXT
			nLayer  := ::aRefresh[nX][__nRfsCama]
			nPosVal := ::aRefresh[nX][__nRfsAuxi]

			nShape := aScan(::aShapes[nTipo][nLayer], {|x| x[__nID] == ::aRefresh[nX][__nRfsID] })
			If nShape > 0
				::aShapes[nTipo][nLayer][nShape][7] := If(Len(::aValues) >= nPosVal, ::ConfigLgnd(::aValues[nPosVal],.T.), 0)
			EndIf
		EndIf
	Next nX

	// Inicializa os valores Num�ricos e em Porcetagem das se��es de acordo com a configura��o atual (tamb�m atualiza o Indicador)
	nSec1Por := aConfig[__nCfgVals][1][2]
	nSec2Por := aConfig[__nCfgVals][2][2]
	::ConfigSecs(1, nSec1Por, 2) // Se��o M�nima
	::ConfigSecs(2, nSec2Por, 2) // Se��o M�xima

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetColors
M�todo que seta as Cores do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@param aSetClrs
	Array com as Cores do Indicador * Opcional
	Default: ::GetColors (cores j� setadas)

@return .T. caso tenha setado; .F. se ocorreu algum problema
/*/
//---------------------------------------------------------------------
Method SetColors(aSetClrs) Class TNGIndicator

	Local aColors := {}

	// Defaults
	Default aSetClrs := {}

	// Define as cores
	If Len(aSetClrs) == __nClrQtde
		aColors := aClone( aSetClrs )
	Else
		aColors := Array(__nClrQtde)
	EndIf

	aColors[__nClrCent] := If(Len(aSetClrs) >= __nClrCent .And. !Empty(aSetClrs[__nClrCent]), aSetClrs[__nClrCent], __cArcCent)

	aColors[__nClrEsqu] := If(Len(aSetClrs) >= __nClrEsqu .And. !Empty(aSetClrs[__nClrEsqu]), aSetClrs[__nClrEsqu], __cArcEsqu)

	aColors[__nClrTopo] := If(Len(aSetClrs) >= __nClrTopo .And. !Empty(aSetClrs[__nClrTopo]), aSetClrs[__nClrTopo], __cArcTopo)

	aColors[__nClrDire] := If(Len(aSetClrs) >= __nClrDire .And. !Empty(aSetClrs[__nClrDire]), aSetClrs[__nClrDire], __cArcDire)

	aColors[__nClrFade] := If(Len(aSetClrs) >= __nClrFade .And. !Empty(aSetClrs[__nClrFade]), aSetClrs[__nClrFade], __cArcFade)

	aColors[__nClrValF] := If(Len(aSetClrs) >= __nClrValF .And. !Empty(aSetClrs[__nClrValF]), aSetClrs[__nClrValF], __cValFore)

	aColors[__nClrValB] := If(Len(aSetClrs) >= __nClrValB .And. !Empty(aSetClrs[__nClrValB]), aSetClrs[__nClrValB], __cValBack)

	aColors[__nClrMarF] := If(Len(aSetClrs) >= __nClrMarF .And. !Empty(aSetClrs[__nClrMarF]), aSetClrs[__nClrMarF], __cMarFore)

	aColors[__nClrMarB] := If(Len(aSetClrs) >= __nClrMarB .And. !Empty(aSetClrs[__nClrMarB]), aSetClrs[__nClrMarB], __cMarBack)

	aColors[__nClrTitF] := If(Len(aSetClrs) >= __nClrTitF .And. !Empty(aSetClrs[__nClrTitF]), aSetClrs[__nClrTitF], __cTitFore)

	aColors[__nClrSubF] := If(Len(aSetClrs) >= __nClrSubF .And. !Empty(aSetClrs[__nClrSubF]), aSetClrs[__nClrSubF], __cSubFore)

	aColors[__nClrCont] := If(Len(aSetClrs) >= __nClrCont .And. !Empty(aSetClrs[__nClrCont]), aSetClrs[__nClrCont], __cContorn)

	aColors[__nClrPntS] := If(Len(aSetClrs) >= __nClrPntS .And. !Empty(aSetClrs[__nClrPntS]), aSetClrs[__nClrPntS], __cPntSeta)

	aColors[__nClrPntC] := If(Len(aSetClrs) >= __nClrPntC .And. !Empty(aSetClrs[__nClrPntC]), aSetClrs[__nClrPntC], __cPntCent)

	// Seta as cores para o indicador
	::aColors := aClone( aColors )

	//--- Atualiza o Indicador caso ja' esteja criado
	::Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetTexts
M�todo que seta os Textos do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@param aSetClrs
	Array com os Textos do Indicador * Opcional
	Default: ::GetTexts (textos j� setadas)

@return .T. caso tenha setado; .F. se ocorreu algum problema
/*/
//---------------------------------------------------------------------
Method SetTexts(aSetTxts) Class TNGIndicator

	Local aTexts := {}
	Local nX := 0

	// Defaults
	Default aSetTxts := {}

	// Define os textos
	If Len(aSetTxts) == __nTxtQtde
		aTexts := aClone( aSetTxts )
	Else
		aTexts := Array(__nTxtQtde)
	EndIf

	aTexts[__nTxtTitu] := If(Len(aSetTxts) >= __nTxtTitu .And. ValType(aSetTxts[__nTxtTitu]) == "C", aSetTxts[__nTxtTitu], __cTxtNull)

	aTexts[__nTxtSubt] := If(Len(aSetTxts) >= __nTxtSubt .And. ValType(aSetTxts[__nTxtSubt]) == "C", aSetTxts[__nTxtSubt], __cTxtNull)

	aTexts[__nTxtFont] := If(Len(aSetTxts) >= __nTxtFont .And. ValType(aSetTxts[__nTxtFont]) == "C" .And. !Empty(aSetTxts[__nTxtFont]), aSetTxts[__nTxtFont], __cTxtFont)

	// Limpa os espa�os em branco desnecess�rios
	For nX := 1 To Len(aTexts)
		aTexts[nX] := AllTrim(aTexts[nX])
	Next nX

	// Seta os textos para o Indicador
	::aTexts := aClone( aTexts )

	// Seta Dica (tooltip) apenas se uma f�rmula n�o foi carregada
	If Empty(::cLoadFormu)
		::SetTooltip(aTexts[__nTxtTitu])
	EndIf

	//--- Atualiza o Indicador caso ja' esteja criado
	::Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetShadows
M�todo que seta os Sombreamentos do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@param aSetShdws
	Array com os Sombreamentos do Indicador * Opcional
	Default: ::GetShadows (sombreamentos j� setados)

@return .T. caso tenha setado; .F. se ocorreu algum problema
/*/
//---------------------------------------------------------------------
Method SetShadows(aSetShdws) Class TNGIndicator

	Local aShadows := {}

	// Defaults
	Default aSetShdws := {}

	// Define as sombras
	If Len(aSetShdws) == __nShwQtde
		aShadows := aClone( aSetShdws )
	Else
		aShadows := Array(__nShwQtde)
	EndIf

	aShadows[__nShwCent] := If(Len(aSetShdws) >= __nShwCent .And. ValType(aSetShdws[__nShwCent]) == "L", aSetShdws[__nShwCent], .F.)

	aShadows[__nShwInfe] := If(Len(aSetShdws) >= __nShwInfe .And. ValType(aSetShdws[__nShwInfe]) == "L", aSetShdws[__nShwInfe], .F.)

	aShadows[__nShwAuxi] := If(Len(aSetShdws) >= __nShwAuxi .And. ValType(aSetShdws[__nShwAuxi]) == "L", aSetShdws[__nShwAuxi], .F.)

	// Seta as sombras para o indicador
	::aShadows := aClone( aShadows )

	//--- Atualiza o Indicador caso ja' esteja criado
	::Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetOthers
M�todo que seta os Outros do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@param aSetClrs
	Array com os Outros do Indicador * Opcional
	Default: ::GetOthers (textos j� setadas)

@return .T. caso tenha setado; .F. se ocorreu algum problema
/*/
//---------------------------------------------------------------------
Method SetOthers(aSetOths) Class TNGIndicator

	Local aOthers := {}

	// Defaults
	Default aSetOths := {}

	// Define os outros
	If Len(aSetOths) == __nOthQtde
		aOthers := aClone( aSetOths )
	Else
		aOthers := Array(__nOthQtde)
	EndIf

	aOthers[__nOthCont] := If(Len(aSetOths) >= __nOthCont .And. ValType(aSetOths[__nOthCont]) == "N", aSetOths[__nOthCont], 1)

	aOthers[__nOthSeta] := If(Len(aSetOths) >= __nOthSeta .And. ValType(aSetOths[__nOthSeta]) == "N", aSetOths[__nOthSeta], 1)

	// Seta os outros para o indicador
	::aOthers := aClone( aOthers )

	//--- Atualiza o Indicador caso ja' esteja criado
	::Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetDesc
M�todo que define as Descri��es do Indicador.

@author Wagner Sobral de Lacerda
@since 14/11/2011

@param aDesc
	Descricoes do Indicador * Opcional
	Default: ::GetDesc()

@return .T. caso tenha setado a Descri��o; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method SetDesc(aSetDesc) Class TNGIndicator

	Local aDesc := {}
	Local nX := 0

	// Defaults
	Default aSetDesc := aClone( ::GetDesc() )

	// Valida o Tamanho do aSetDesc
	If Len(aSetDesc) == __nDesQtde
		aDesc := aClone( aSetDesc )
	Else
		aDesc := Array(__nDesQtde)

		aDesc[__nDesLeg1] := If(Len(aSetDesc) >= __nDesLeg1 .And. ValType(aSetDesc[__nDesLeg1]) == "C", aSetDesc[__nDesLeg1], "")
		aDesc[__nDesLeg2] := If(Len(aSetDesc) >= __nDesLeg2 .And. ValType(aSetDesc[__nDesLeg2]) == "C", aSetDesc[__nDesLeg2], "")
		aDesc[__nDesLeg3] := If(Len(aSetDesc) >= __nDesLeg3 .And. ValType(aSetDesc[__nDesLeg3]) == "C", aSetDesc[__nDesLeg3], "")
	EndIf

	// Limpa os espa�os em branco desnecess�rios
	For nX := 1 To Len(aDesc)
		aDesc[nX] := AllTrim(aDesc[nX])
	Next nX

	// Seta as descri��es para o indicador
	::aDesc := aClone( aDesc )

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetTooltip
M�todo que define a Dica (tooltip) do Indicador.

@author Wagner Sobral de Lacerda
@since 11/04/2012

@param cTooltip
	Texto com a Dica do Indicador * Opcional
	Default: ::GetTooltip()

@return .T.
/*/
//---------------------------------------------------------------------
Method SetTooltip(cTooltip) Class TNGIndicator

	Local aShapes 	:= aClone(::GetShape())
	Local nTipo 	:= 0
	Local nCamada 	:= 0
	Local nX 		:= 0
	Local cPicture	:= ::GetPicture()

	Default cTooltip := ::GetTooltip()

	// Define a Dica
	::cTooltip := cTooltip

	// Seta a Dica (Tooltip) se o Indicador j� estiver criado
	If ::lIndicator
		For nTipo := 1 To Len(aShapes)
			For nCamada := 2 To ::nLayers // A Camada 1 e' reservada para o Background, e ela n�o ter� Dica (tooltip)
				For nX := 1 To Len(aShapes[nTipo][nCamada])
					//Para Shapes do tipo texto, nas camadas de marcadores e valor total, setar tooltip especifico
					If nTipo == 7 .And. nCamada == 6
						::oTPPanel:SetToolTip(aShapes[nTipo][nCamada][nX][__nID], Transform(aShapes[7][nCamada][nX][12], cPicture))
					ElseIf nCamada == 7 .And. nTipo == 7
						::oTPPanel:SetToolTip(aShapes[nTipo][nCamada][nX][__nID], ;
							IIf( ::GetContent() == '2', NTOH( ::GetValue() ), ; //Se conteudo for do tipo horario converte para o formato correto
								Transform(::GetValue(), cPicture) ) )
					Else
						::oTPPanel:SetToolTip(aShapes[nTipo][nCamada][nX][__nID], ::cTooltip)
					EndIf
				Next nX
			Next nCamada
		Next nTipo
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetCodeBlock
M�todo que seta um Bloco de C�digo para o Indicador

@author Wagner Sobral de Lacerda
@since 11/04/2012

@param nCodeBlock
	Indica qual o Bloco de C�digo que ser� definido * Obrigat�rio
	   1 - Antes da tela de Configura��o
	   2 - Ap�s a tela de Configura��o
	Indica qual o Bloco de C�digo que ser� definido * Obrigat�rio
	   1 - Antes da tela de Configura��o
	   	* n�o recebe par�metros
	   2 - Ap�s a tela de Configura��o
	   	* par�metro 1: Valor l�gico indicando se confirmou (.T.) ou cancelou (.F.) o dialog
	   3 - Informa��es do Indicador Gr�fico (clique da direita)
	    * par�metro 1: Objeto do Indicador Gr�fico
	   4 - Detalhes do Indicador Gr�fico (clique da direita)
	    * par�metro 1: Objeto do Indicador Gr�fico
	   5 - Legenda do Indicador Gr�fico (clique da direita)
	    * par�metro 1: Objeto do Indicador Gr�fico
@param bCodeBlock
	Bloco de C�digo * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Method SetCodeBlock(nCodeBlock, bCodeBlock) Class TNGIndicator

	// Valida se pode setar o bloco de c�digo
	If nCodeBlock <= 0 .Or. nCodeBlock > __nBQtde
		Return .F.
	EndIf

	// Seta o Bloco de C�digo
	::aCodeBlock[nCodeBlock] := bCodeBlock

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetRClick
M�todo que seta se o clique da direita sobre o Indicador Gr�fico
est� habilitado (.T.) ou desabilitado (.F.).

@author Wagner Sobral de Lacerda
@since 27/08/2012

@param lSetRClick
	Indica se o clique da direita est� habilitado ou n�o * Obrigat�rio
	   .T. - Habilita o clique da direita
	   .T. - Desabilita o clique da direita
	Default: ::lRClick

@return .T.
/*/
//---------------------------------------------------------------------
Method SetRClick(lSetRClick) Class TNGIndicator

	// Defaults
	Default lSetRClick := ::lRClick

	// Seta o clique
	::lRClick := lSetRClick

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} SetFields
M�todo que define a configura��o dos campos do Indicador.

@author Wagner Sobral de Lacerda
@since 13/07/2012

@param aSetFields
	Array com a configura��o dos campos * Opcional
	   [x][1] - T�tulo do Campo
	   [x][2] - Tamanho
	   [x][3] - Decimal
	   [x][4] - Picture
	   [x][5] - ComboBox
	Default: ::GetFields()

@return .T.
/*/
//---------------------------------------------------------------------
Method SetFields(aSetFields) Class TNGIndicator

	Local aFields := {}, aAuxFld := {}
	Local nLenFld := 5

	// Defaults
	Default aSetFields := aClone( ::GetFields() )

	// Define os campos
	If Len(aSetFields) == __nFldQtde
		aFields := aClone( aSetFields )
	Else
		aFields := Array(__nFldQtde)
	EndIf

	aAuxFld := {STR0006, 25, 0, "", ""} //"T�tulo"
	aFields[__nFldTitl] := If(Len(aSetFields) >= __nFldTitl .And. Len(aSetFields[__nFldTitl]) >= nLenFld, aSetFields[__nFldTitl], aAuxFld)

	aAuxFld := {STR0007, 10, 0, "", ""} //"Subt�tulo"
	aFields[__nFldSubt] := If(Len(aSetFields) >= __nFldSubt .And. Len(aSetFields[__nFldSubt]) >= nLenFld, aSetFields[__nFldSubt], aAuxFld)

	aAuxFld := {STR0008, 060, 0, "", ""} //"Se��o M�nima"
	aFields[__nFldLeg1] := If(Len(aSetFields) >= __nFldLeg1 .And. Len(aSetFields[__nFldLeg1]) >= nLenFld, aSetFields[__nFldLeg1], aAuxFld)

	aAuxFld := {STR0009, 060, 0, "", ""} //"Se��o Intermedi�ria"
	aFields[__nFldLeg2] := If(Len(aSetFields) >= __nFldLeg2 .And. Len(aSetFields[__nFldLeg2]) >= nLenFld, aSetFields[__nFldLeg2], aAuxFld)

	aAuxFld := {STR0010, 060, 0, "", ""} //"Se��o M�xima"
	aFields[__nFldLeg3] := If(Len(aSetFields) >= __nFldLeg3 .And. Len(aSetFields[__nFldLeg3]) >= nLenFld, aSetFields[__nFldLeg3], aAuxFld)

	aAuxFld := {STR0011, 01, 0, "@!", STR0012} // Por padr�o, carrega o estilo "1" //"Modelo" ## "1=Veloc�metro Comum"
	aFields[__nFldModl] := If(Len(aSetFields) >= __nFldModl .And. Len(aSetFields[__nFldModl]) >= nLenFld, aSetFields[__nFldModl], aAuxFld)

	aAuxFld := {STR0013, 1, 0, "", STR0014} //"Conte�do" ## "1=Num�rico;2=Hor�rio"
	aFields[__nFldTipC] := If(Len(aSetFields) >= __nFldTipC .And. Len(aSetFields[__nFldTipC]) >= nLenFld, aSetFields[__nFldTipC], aAuxFld)

	// Seta as sombras para o indicador
	::aFields := aClone( aFields )

	//--- Atualiza o Indicador caso ja' esteja criado
	::Refresh()

Return .T.

/*/
############################################################################################
##                                                                                        ##
## M�TODOS: GET                                                                           ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} GetStyle
M�todo que retorna o Estilo do Indicador.

@author Wagner Sobral de Lacerda
@since 14/11/2011

@return ::cStyle
/*/
//---------------------------------------------------------------------
Method GetStyle() Class TNGIndicator
Return ::cStyle

//---------------------------------------------------------------------
/*/{Protheus.doc} GetConfig
M�todo que retorna um Array das Configura��es do Indicador.

@author Wagner Sobral de Lacerda
@since 06/02/2012

@return ::aConfig
/*/
//---------------------------------------------------------------------
Method GetConfig() Class TNGIndicator
Return ::aConfig

//---------------------------------------------------------------------
/*/{Protheus.doc} GetBackgrd
M�todo que retorna o ID do Shape Background do Indicador.

@author Wagner Sobral de Lacerda
@since 20/10/2011

@return ::nIDBack
/*/
//---------------------------------------------------------------------
Method GetBackgrd() Class TNGIndicator
Return ::nIDBack

//---------------------------------------------------------------------
/*/{Protheus.doc} GetShape
M�todo que retorna um Array contendo os shapes montados no Indicador.

@author Wagner Sobral de Lacerda
@since 06/10/2011

@return ::aShapes
/*/
//---------------------------------------------------------------------
Method GetShape() Class TNGIndicator
Return ::aShapes

//---------------------------------------------------------------------
/*/{Protheus.doc} GetZoom
M�todo que retorna o Zoom do Indicador.

@author Wagner Sobral de Lacerda
@since 06/10/2011

@return ::nZoom
/*/
//---------------------------------------------------------------------
Method GetZoom() Class TNGIndicator
Return ::nZoom

//---------------------------------------------------------------------
/*/{Protheus.doc} GetContent
M�todo que retorna o Tipo de Conte�do do Indicador.

@author Wagner Sobral de Lacerda
@since 13/02/2012

@return ::cContent
/*/
//---------------------------------------------------------------------
Method GetContent() Class TNGIndicator
Return ::cContent

//---------------------------------------------------------------------
/*/{Protheus.doc} GetCenter
M�todo que retorna a Centraliza��o do Indicador.

@author Wagner Sobral de Lacerda
@since 06/02/2012

@return ::lCenter
/*/
//---------------------------------------------------------------------
Method GetCenter() Class TNGIndicator
Return ::lCenter

//---------------------------------------------------------------------
/*/{Protheus.doc} GetPicture
M�todo que retorna a Picture dos Valores do Indicador.

@author Wagner Sobral de Lacerda
@since 13/02/2012

@return ::cPicture
/*/
//---------------------------------------------------------------------
Method GetPicture() Class TNGIndicator
Return ::cPicture

//---------------------------------------------------------------------
/*/{Protheus.doc} GetValue
M�todo que retorna o Valor Atual do Indicador.

@author Wagner Sobral de Lacerda
@since 06/10/2011

@param lWithPict
	Indica se deve formatar os valores * Opcional
	Default: .F.

@return ::nValue
/*/
//---------------------------------------------------------------------
Method GetValue(lWithPict) Class TNGIndicator

	// Vari�vel do Retorno
	Local uValue := ::nValue
	// Defaults
	Default lWithPict := .F.

	// Forma se desejado
	If lWithPict
		::ConfigVals(uValue, .T.)
	EndIf

Return uValue

//---------------------------------------------------------------------
/*/{Protheus.doc} GetVals
M�todo que retorna o Array de valores do Indicador.

@author Wagner Sobral de Lacerda
@since 13/02/2012

@param lWithPict
	Indica se deve formatar os valores * Opcional
	Default: .F.

@return aValues
/*/
//---------------------------------------------------------------------
Method GetVals(lWithPict) Class TNGIndicator

	Local aValues := ::aValues

	// Defaults
	Default lWithPict := .F.

	// Recebe os Valores
	aValues := aClone( ::aValues )

	// Formata os Valores na Picture definida para o Indicador
	If lWithPict
		aValues := aClone( ::ConfigVals(aValues, .T.) )
	EndIf

Return aValues

//---------------------------------------------------------------------
/*/{Protheus.doc} GetColors
M�todo que retorna o Array de Cores do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@return ::aColors
/*/
//---------------------------------------------------------------------
Method GetColors() Class TNGIndicator
Return ::aColors

//---------------------------------------------------------------------
/*/{Protheus.doc} GetTexts
M�todo que retorna o Array de Textos do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@return ::aTexts
/*/
//---------------------------------------------------------------------
Method GetTexts() Class TNGIndicator
Return ::aTexts

//---------------------------------------------------------------------
/*/{Protheus.doc} GetShadows
M�todo que retorna o Array de Sombreamentos do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@return ::aShadows
/*/
//---------------------------------------------------------------------
Method GetShadows() Class TNGIndicator
Return ::aShadows

//---------------------------------------------------------------------
/*/{Protheus.doc} GetOthers
M�todo que retorna o Array de Outros do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@return ::aOthers
/*/
//---------------------------------------------------------------------
Method GetOthers() Class TNGIndicator
Return ::aOthers

//---------------------------------------------------------------------
/*/{Protheus.doc} GetDesc
M�todo que retorna a Descri��o do Indicador.

@author Wagner Sobral de Lacerda
@since 09/11/2011

@return ::aDesc
/*/
//---------------------------------------------------------------------
Method GetDesc() Class TNGIndicator
Return ::aDesc

//---------------------------------------------------------------------
/*/{Protheus.doc} GetTooltip
M�todo que retorna a Dica (tooltip) do Indicador.

@author Wagner Sobral de Lacerda
@since 11/04/2012

@return ::cTooltip
/*/
//---------------------------------------------------------------------
Method GetTooltip() Class TNGIndicator
Return ::cTooltip

//---------------------------------------------------------------------
/*/{Protheus.doc} GetCodeBlock
M�todo que retorna um Bloco de C�digo do Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 11/04/2012

@return uCodeBlock
/*/
//---------------------------------------------------------------------
Method GetCodeBlock(nCodeBlock) Class TNGIndicator

	// Vari�vel do retorno
	Local uCodeBlock := Nil

	If nCodeBlock > 0 .And. nCodeBlock <= __nBQtde
		uCodeBlock := ::aCodeBlock[nCodeBlock]
	EndIf

Return uCodeBlock

//---------------------------------------------------------------------
/*/{Protheus.doc} GetRClick
M�todo que retorna se o clique da direita sobre o Indicador Gr�fico
est� habilitado (.T.) ou desabilitado (.F.).

@author Wagner Sobral de Lacerda
@since 27/08/2012

@return ::lRClick
/*/
//---------------------------------------------------------------------
Method GetRClick() Class TNGIndicator
Return ::lRClick

//---------------------------------------------------------------------
/*/{Protheus.doc} GetFields
M�todo que retorna a configura��o dos campos do Indicador.

@author Wagner Sobral de Lacerda
@since 13/07/2012

@return ::aFields
/*/
//---------------------------------------------------------------------
Method GetFields() Class TNGIndicator
Return ::aFields

//---------------------------------------------------------------------
/*/{Protheus.doc} GetInfo
M�todo que retorna um Array de Informa��es do Indicador.

@author Wagner Sobral de Lacerda
@since 26/01/2012

@return ::aOthers
/*/
//---------------------------------------------------------------------
Method GetInfo() Class TNGIndicator

	Local aInfo := {}

	Local nTipo   := 0
	Local nCamada := 0
	Local nCount  := 0

	// Recebe a quantidade de Shapes Montados
	For nTipo := 1 To Len(::aShapes)
		For nCamada := 1 To Len(::aShapes[nTipo])
			nCount += Len(::aShapes[nTipo][nCamada])
		Next nCamada
	Next nTipo

	//------------------------------
	// Monta o array de Informa��es
	//------------------------------
	aAdd(aInfo, { STR0015, "TNGIndicator" }) // 1 - Nome da Classe //"Classe"
	aAdd(aInfo, { STR0016, cValToChar()   }) // 2 - Vers�o da Classe //"Vers�o"
	aAdd(aInfo, { STR0017, ::GetContent() }) // 3 - Conte�do do Indicador //"Tipo de Conte�do"
	aAdd(aInfo, { STR0018, ::GetStyle()   }) // 4 - Estilo do Indicador //"Estilo (Modelo)"
	aAdd(aInfo, { STR0019, ::cLoadFilia   }) // 5 - Filial do Indicador Gr�fico carregado //"Filial"
	aAdd(aInfo, { STR0020, ::cLoadIndic   }) // 6 - C�digo do Indicador Gr�fico carregado //"Indicador Gr�fico"
	aAdd(aInfo, { STR0021, ::cLoadModul   }) // 7 - M�dulo do Indicador Gr�fico carregado //"M�dulo do Ambiente"
	aAdd(aInfo, { STR0022, ::cLoadFormu   }) // 8 - F�rmula carregada no Indicador Gr�fico //"F�rmula"
	aAdd(aInfo, { STR0023, cValToChar(::nMaxVals)     }) // 9 - Quantidade de Valores do Indicador //"Quantidade M�xima de Valores"
	aAdd(aInfo, { STR0024, cValToChar(nCount) }) // 10 - Quantidade de Shapes montados do Indicador //"Quantidade de Shapes montados"

Return aInfo

/*/
############################################################################################
##                                                                                        ##
## M�TODOS: CONSTRU��O DO INDICADOR                                                       ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} CreateShapes
M�todo que define os shapes padr�es do Indicador e os armazena no array.

@author Wagner Sobral de Lacerda
@since 06/11/2011

@return aRet
/*/
//---------------------------------------------------------------------
Method CreateShapes() Class TNGIndicator

	Local nID    		:= 0, nCamada := 0
	Local aShape 		:= {}, aOldShape := {}
	Local aConfig 		:= aClone( ::GetConfig() )
	Local cStyle  		:= ::GetStyle()
	Local nZoom   		:= ::GetZoom()
	Local nTipo 		:= 0
	Local cFonteText 	:= ""
	Local cFonteMarc 	:= ""
	Local cFonteTitl 	:= ""
	Local aValChar   	:= {}
	Local nFonteText 	:= 0
	Local nFonteTitl 	:= 0
	Local nFonteTxt2 	:= 0
	Local aMarca  		:= {}
	Local nMarca  		:= 0
	Local nAngulo 		:= 0
	Local nSoma   		:= 0
	Local nValor  		:= 0
	Local nBarra   		:= 0
	Local nLargura 		:= 0
	Local nAltura  		:= 0
	Local nPercent 		:= 0
	Local nSize3 		:= (::nSize / 3)
	Local nSize4 		:= (::nSize / 4)
	Local nSeno 		:= 0
	Local nCoss 		:= 0
	Local nCenterL 		:= 0
	Local nCenterT 		:= 0
	Local aAux  		:= {}
	Local uAux1 := Nil, uAux2 := Nil, uAux3 := Nil
	Local nX 			:= 0
	Local nAltText		:= 12 //Variavel que define o tamanho do shape tipo texto, valor fixo.
	//Vari�veis das propriedados b�sicas do Indicador
	Local aValores 		:= ::GetVals()
	Local aCores   		:= ::GetColors()
	Local aTextos  		:= ::GetTexts()
	Local aSombras 		:= ::GetShadows()
	Local aOutros  		:= ::GetOthers()

	//Define o Tamanho do Texto (varia de acordo com o Zoom)
	nFonteText := If(nZoom <= 2, 10, If(nZoom <= 4, 12, 16))
	//Define o Tamanho do Titulo
	nFonteTitl := If(nZoom <= 2, 11, If(nZoom <= 4, 12, 16))
	//Define o Tamanho do Texto 2 (marcadores)
	If cStyle $ (__cSVeComu + "/" + __cSVeSecc)
		nFonteTxt2 := ( nFonteText - 3 )
	Else
		nFonteTxt2 := If(nZoom <= 2, 08, If(nZoom <= 4, 10, 12))
	EndIf

	//Seta as Fontes (1-Esquerda/2-Direita/3-Centro)
	cFonteText := aTextos[__nTxtFont] + "," + cValToChar(nFonteText) + ",1,0,2"
	cFonteTitl := aTextos[__nTxtFont] + "," + cValToChar(nFonteTitl) + ",1,0,3"
	cFonteMarc := aTextos[__nTxtFont] + "," + cValToChar(nFonteTxt2) + ",1,0,"

	// Limpa o array de refresh
	::aRefresh := {}

	If cStyle == __cSVeComu // Veloc�metro Comum

		//--------------------------------------------------
		// 2 - RECTROUNDED
		//--------------------------------------------------
		nTipo := __nRECTROUNDED

		//Caixa que contem o texto do Velocimetro
		uAux1 := (::nCenterT - ::nTop) / 4
		uAux2 := nSize4 + (3 * nZoom)

		nID     := ::ShpNextID()
		nCamada := 4
		aShape  := {nID, nTipo, (::nCenterL-nSize4), ::nCenterT+uAux2, (nSize4*2), uAux1, aCores[__nClrValB], aOutros[__nOthCont], aCores[__nClrCont]}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

		//--------------------------------------------------
		// 3 - ELLIPSE
		//--------------------------------------------------
		nTipo := __nELLIPSE

		// Sombreamento Inferior
		If aSombras[__nShwInfe]
			uAux1 := (::nSize * 0.55) //Top
			uAux2 := (::nSize * 0.30) //Left
			uAux3 := (uAux2 * 2) //Width

			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, ::nCenterL-uAux2, ::nCenterT+uAux1, uAux3, __nShadowH, ::cClrShdw, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		//--------------------------------------------------
		// 4 - ARC
		//--------------------------------------------------
		nTipo := __nARC

		// Sombreamento Central
		If aSombras[__nShwCent]
			uAux1 := 2
			uAux2 := ( uAux1 * 2 )

			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, (::nLeft-uAux1), ::nTop, (::nSize+uAux2), ::cClrShdw, ::cClrShdw, 0, 360, 0, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		//Direito
		nID     := ::ShpNextID()
		nCamada := 2
		aShape  := {nID, nTipo, ::nLeft, ::nTop, ::nSize, aCores[__nClrDire], aCores[__nClrFade], __nAngIni__, aConfig[__nCfgAtua][3][2], aOutros[__nOthCont], aCores[__nClrCont]}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 3, __nRfsHSec})

		//Centro Superior
		nID     := ::ShpNextID()
		nCamada := 2
		aShape  := {nID, nTipo, ::nLeft, ::nTop, ::nSize, aCores[__nClrTopo], aCores[__nClrFade], aConfig[__nCfgAtua][2][1], aConfig[__nCfgAtua][2][2], aOutros[__nOthCont], aCores[__nClrCont]}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 2, __nRfsHSec})

		//Esquerdo
		nID     := ::ShpNextID()
		nCamada := 2
		aShape  := {nID, nTipo, ::nLeft, ::nTop, ::nSize, aCores[__nClrEsqu], aCores[__nClrFade], aConfig[__nCfgAtua][1][1], aConfig[__nCfgAtua][1][2], aOutros[__nOthCont], aCores[__nClrCont]}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 1, __nRfsHSec})

		//Centro Inferior
		nID     := ::ShpNextID()
		nCamada := 2
		aShape  := {nID, nTipo, ::nLeft, ::nTop, ::nSize, aCores[__nClrCent], aCores[__nClrFade], __nAngFim__, 90, aOutros[__nOthCont], aCores[__nClrCont]}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

		//MARCADORES (A Quantidade real, e' igual a quantidade - 1, por causa da borda, que tambem serve como 'marcador')
		nAngulo := __nAngIni__ //Deve terminar no �ngulo __nAngFim__
		nSoma := If(nZoom < 4, 45, 22.5)
		uAux1 := 10 + (nZoom * If(nZoom <= 2, 1, 2))
		uAux2 := ( uAux1 * 2 )
		For nMarca := 1 To ( ::nMarcads - 1 )
			nID     := ::ShpNextID()
			nCamada := 4
			aShape  := {nID, nTipo, ::nLeft+uAux1, ::nTop+uAux1, ::nSize-uAux2, aCores[__nClrMarB], aCores[__nClrFade], nAngulo, nSoma, aOutros[__nOthCont], aCores[__nClrCont]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

			nAngulo += nSoma
			If nAngulo > 360
				nAngulo -= 360
			EndIf
		Next nMarca

		//Centro Interior
		uAux1 := 20 + (nZoom * If(nZoom <= 2, 1, 4))
		uAux2 := ( uAux1 * 2 )

		nID     := ::ShpNextID()
		nCamada := 4
		aShape  := {nID, nTipo, ::nLeft+uAux1, ::nTop+uAux1, ::nSize-uAux2, aCores[__nClrMarB], aCores[__nClrMarB], __nAngIni__, __nAngMax__, 0, aCores[__nClrCont]}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

		//Centro do Ponteiro
		uAux1 := ( ::nSize / 20 )
		uAux2 := ( uAux1 / 2 )

		nID     := ::ShpNextID()
		nCamada := 7
		aShape  := {nID, nTipo, ::nCenterL-uAux2, ::nCenterT-uAux2, uAux1, aCores[__nClrPntC], aCores[__nClrFade], 0, 360, 0, aCores[__nClrCont]}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

		//--------------------------------------------------
		// 6 - LINE
		//--------------------------------------------------
		nTipo := __nLINE

		//Seta do Ponteiro
		::nArrow := nSize4
		uAux1 := (::nCenterL - ::nArrow)
		uAux2 := (::nCenterT + ::nArrow)

		nID     := ::ShpNextID()
		nCamada := 6
		aShape  := {nID, nTipo, ::nCenterL, ::nCenterT, uAux1, uAux2, aOutros[__nOthSeta], aCores[__nClrPntS]}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

		//--------------------------------------------------
		// 7 - TEXT
		//--------------------------------------------------
		nTipo := __nTEXT

		//Subtitulo localizado um pouco acima do Centro do Ponteiro
		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT-(::nCenterT/6), ::nSize, (::nCenterT/4), aTextos[__nTxtSubt], cFonteMarc+"3", 1, aCores[__nClrSubF], .F.}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

		//Valor Atual do Indicador
		uAux1 := nSize4 + (3 * nZoom) + (2.5 * nZoom) //Centraliza e deixa um pequeno espaco da borda da Ellipse

		nID     := ::ShpNextID()
		nCamada := 7
		aShape  := {nID, nTipo, (::nCenterL-nSize4), ::nCenterT+uAux1, (nSize4*1.95), (::nCenterT/4), ::ConfigLgnd(::GetValue()), cFonteText, 1, aCores[__nClrValF], .T., ::GetValue()}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHAtu})

		// T�tulo localizado abaixo do Veloc�metro
		uAux1 := (::nSize * 0.60)

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT+uAux1, ::nSize, (::nCenterT/2), aTextos[__nTxtTitu], cFonteTitl, 1, aCores[__nClrTitF], .F.}
		::SetShape(nCamada, aShape)

		//VALORES dos MARCADORES
		uAux3 := "3"
		For nValor := 1 To Len(::GetVals())
			uAux1 := 0

			If nValor == 1 //Inicio
				nPercent := If(nZoom == 1, 0.90, If(nZoom < 3, 0.95, 1.00))
				uAux1 := ::nCenterL - (nSize3*nPercent)

				nPercent := If(nZoom == 1, 0.80, If(nZoom < 3, 0.85, 0.90))
				uAux2 := ::nCenterT + (nSize4*nPercent)

				uAux3 := "1" //Texto alinhado a Esquerda
			ElseIf nValor == Len(aValores) //Fim
				nPercent := If(nZoom == 1, 0.01, If(nZoom < 3, 0.05, 0.06))
				uAux1 := ::nCenterL + (nSize3*nPercent)

				nPercent := If(nZoom == 1, 0.80, If(nZoom < 3, 0.85, 0.90))
				uAux2 := ::nCenterT + (nSize4*nPercent)

				uAux3 := "2" //Texto alinhado a Direita
			ElseIf Len(aValores) == 7
				If nValor == 2
					nPercent := If(nZoom == 1, 1.10, If(nZoom < 3, 1.12, 1.15))

					uAux1 := ::nCenterL - (nSize3*nPercent)
					uAux2 := ::nCenterT

					uAux3 := "1" //Texto alinhado a Esquerda
				ElseIf nValor == 3
					nPercent := If(nZoom == 1, 0.90, If(nZoom < 3, 0.95, 1.00))
					uAux1 := ::nCenterL - (nSize3*nPercent)

					nPercent := If(nZoom == 1, 1.00, If(nZoom < 3, 1.05, 1.10))
					uAux2 := ::nCenterT - (nSize4*nPercent)

					uAux3 := "1" //Texto alinhado a Esquerda
				ElseIf nValor == 4 //MEIO
					uAux1 := ::nCenterL - (nSize3/2)

					nPercent := If(nZoom == 1, 1.45, If(nZoom < 3, 1.50, 1.55))
					uAux2 := ::nCenterT - (nSize4*nPercent)

					uAux3 := "3" //Texto alinhado ao Centro
				ElseIf nValor == 5
					nPercent := If(nZoom == 1, 0.01, If(nZoom < 3, 0.05, 0.06))
					uAux1 := ::nCenterL + (nSize3*nPercent)

					nPercent := If(nZoom == 1, 1.00, If(nZoom < 3, 1.05, 1.10))
					uAux2 := ::nCenterT - (nSize4*nPercent)

					uAux3 := "2" //Texto alinhado a Direita
				ElseIf nValor == 6
					nPercent := If(nZoom == 1, 0.10, If(nZoom < 3, 0.12, 0.15))

					uAux1 := ::nCenterL + (nSize3*nPercent)
					uAux2 := ::nCenterT

					uAux3 := "2" //Texto alinhado a Direita
				EndIf
			EndIf

			/*Converte o valor do marcador para uma string abreviada conforme a legenda
			 exclusico para valores maiores q 1 milh�o.*/
			aAdd(aValChar, ::ConfigLgnd(aValores[nValor],.T.))

			nID     := ::ShpNextID()
			nCamada := 6
			aShape  := {nID, nTipo, uAux1, uAux2, nSize3, nAltText, aValChar[nValor], cFonteMarc+uAux3, 1, aCores[__nClrMarF], .T., aValores[nValor]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nValor, __nRfsHMar})
		Next nValor

	ElseIf cStyle == __cSVeSecc // Veloc�metro Seccionado

		//--------------------------------------------------
		// 2 - RECTROUNDED
		//--------------------------------------------------
		nTipo := __nRECTROUNDED

		//Caixa que contem o texto do Velocimetro
		uAux1 := (::nCenterT - ::nTop) / 4
		uAux2 := nSize4 + (3 * nZoom)

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, (::nCenterL-nSize4), ::nCenterT+uAux2, (nSize4*2), uAux1, aCores[__nClrValB], aOutros[__nOthCont], aCores[__nClrCont]}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

		//--------------------------------------------------
		// 3 - ELLIPSE
		//--------------------------------------------------
		nTipo := __nELLIPSE

		// Sombreamento Inferior
		If aSombras[__nShwInfe]
			uAux1 := (::nSize * 0.55) //Top
			uAux2 := (::nSize * 0.30) //left
			uAux3 := (uAux2 * 2) //Width

			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, ::nCenterL-uAux2, ::nCenterT+uAux1, uAux3, __nShadowH, ::cClrShdw, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		//--------------------------------------------------
		// 4 - ARC
		//--------------------------------------------------
		nTipo := __nARC

		// Sombreamento Central
		If aSombras[__nShwCent]
			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, (::nLeft-2), ::nTop, (::nSize+4), ::cClrShdw, ::cClrShdw, 0, 360, 0, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		//Fundo do Indicador
		nID     := ::ShpNextID()
		nCamada := 2
		aShape  := {nID, nTipo, ::nLeft, ::nTop, ::nSize, aCores[__nClrCent], aCores[__nClrFade], 0, 360, 0, aCores[__nClrCont]}
		::SetShape(nCamada, aShape)

		//Fundo das Barras
		uAux1 := 10 + (nZoom * 2)
		uAux2 := ( uAux1 * 2 )

		nID     := ::ShpNextID()
		nCamada := 2
		aShape  := {nID, nTipo, ::nLeft+uAux1, ::nTop+uAux1, ::nSize-uAux2, aCores[__nClrCent], aCores[__nClrFade], __nAngIni__, __nAngMax__, 1, aCores[__nClrCont]}
		::SetShape(nCamada, aShape)

		//BARRAS
		nAngulo := __nAngIni__ //Deve terminar no Angulo __nAngFim__
		nSoma := (__nAngMax__ / ::nBars) //Deve conter '::nBars' em __nAngMax__ graus
		uAux1 := 10 + (nZoom * 2)
		uAux2 := ( uAux1 * 2 )
		For nBarra := 1 To ::nBars
			nID     := ::ShpNextID()
			nCamada := 3
			aShape  := {nID, nTipo, ::nLeft+uAux1, ::nTop+uAux1, ::nSize-uAux2, aCores[__nClrCent], aCores[__nClrFade], nAngulo, nSoma, 1, aCores[__nClrCont]}
			::SetShape(nCamada, aShape)
			// Como a montagem a da direita->esquerda, e a atualiza��o � da esquerda->direita, inverte o n�mero da barra para armazenar na atualiza��o
			uAux3 := (::nBars+1) - nBarra
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, uAux3, __nRfsHSec})

			nAngulo += nSoma
			If nAngulo > 360
				nAngulo -= 360
			EndIf
		Next nBarra

		//MARCADORES (A Quantidade real, e' igual a quantidade - 1, por causa da borda, que tambem serve como 'marcador')
		nAngulo := __nAngIni__ //Deve terminar no Angulo __nAngFim__
		nSoma := If(nZoom < 4, 45, 22.5)
		uAux1 := If(nZoom < 4, ((5*nZoom) + 25), ((5*nZoom) + 30))
		uAux2 := ( uAux1 * 2 )
		For nMarca := 1 To ( ::nMarcads - 1 )
			nID     := ::ShpNextID()
			nCamada := 4
			aShape  := {nID, nTipo, ::nLeft+uAux1, ::nTop+uAux1, ::nSize-uAux2, aCores[__nClrCent], aCores[__nClrFade], nAngulo, nSoma, aOutros[__nOthCont], aCores[__nClrCont]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

			nAngulo += nSoma
			If nAngulo > 360
				nAngulo -= 360
			EndIf
		Next nMarca

		//Fundo Central sobreposto nas Barras
		uAux1 := 60 + (nZoom * 2)
		uAux1 := If(nZoom < 4, ((5*nZoom) + 25), ((5*nZoom) + 30)) + If(nZoom < 4, 10, 15)
		uAux2 := ( uAux1 * 2 )
		nID     := ::ShpNextID()
		nCamada := 4
		aShape  := {nID, nTipo, ::nLeft+uAux1, ::nTop+uAux1, ::nSize-uAux2, aCores[__nClrCent], aCores[__nClrCent], __nAngIni__, 360, 0, aCores[__nClrCont]}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

		//--------------------------------------------------
		// 7 - TEXT
		//--------------------------------------------------
		nTipo := __nTEXT

		//Subtitulo localizado no Centro do Ponteiro
		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT-(::nCenterT/8), ::nSize, (::nCenterT/4), aTextos[__nTxtSubt], cFonteMarc+"3", 1, aCores[__nClrSubF], .F.}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

		//Valor Atual do Indicador
		uAux1 := nSize4 + (3 * nZoom) + (2.5 * nZoom) //Centraliza e deixa um pequeno espaco da borda da Ellipse

		nID     := ::ShpNextID()
		nCamada := 7
		aShape  := {nID, nTipo, (::nCenterL-nSize4), ::nCenterT+uAux1, (nSize4*1.95), (::nCenterT/4), ::ConfigLgnd(::GetValue()), cFonteText, 1, aCores[__nClrValF], .T., ::GetValue()}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHAtu})

		// T�tulo localizado abaixo do Veloc�metro
		uAux1 := (::nSize * 0.60)

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT+uAux1, ::nSize, (::nCenterT/2), aTextos[__nTxtTitu], cFonteTitl, 1, aCores[__nClrTitF], .F.}
		::SetShape(nCamada, aShape)

		//VALORES dos MARCADORES
		uAux3 := "3"
		For nValor := 1 To Len(aValores)
			uAux1 := 0

			If nValor == 1 //Inicio
				nPercent := If(nZoom == 1, 0.80, If(nZoom < 3, 0.85, 0.90))
				uAux1 := ::nCenterL - (nSize3*nPercent)

				nPercent := If(nZoom == 1, 0.60, If(nZoom < 3, 0.65, 0.70))
				uAux2 := ::nCenterT + (nSize4*nPercent)

				uAux3 := "1" //Texto alinhado a Esquerda
			ElseIf nValor == Len(aValores) //Fim
				nPercent := If(nZoom == 1, -0.15, If(nZoom < 3, -0.15, -0.10))
				uAux1 := ::nCenterL + (nSize3*nPercent)

				nPercent := If(nZoom == 1, 0.60, If(nZoom < 3, 0.65, 0.70))
				uAux2 := ::nCenterT + (nSize4*nPercent)

				uAux3 := "2" //Texto alinhado a Direita
			ElseIf Len(aValores) == 7
				If nValor == 2
					nPercent := If(nZoom == 1, 1.00, If(nZoom < 3, 1.02, 1.05))

					uAux1 := ::nCenterL - (nSize3*nPercent)
					uAux2 := ::nCenterT

					uAux3 := "1" //Texto alinhado a Esquerda
				ElseIf nValor == 3
					nPercent := If(nZoom == 1, 0.80, If(nZoom < 3, 0.85, 0.90))
					uAux1 := ::nCenterL - (nSize3*nPercent)

					nPercent := If(nZoom == 1, 0.75, If(nZoom < 3, 0.80, 0.85))
					uAux2 := ::nCenterT - (nSize4*nPercent)

					uAux3 := "1" //Texto alinhado a Esquerda
				ElseIf nValor == 4 //MEIO
					uAux1 := ::nCenterL - (nSize3/2)

					nPercent := If(nZoom == 1, 1.20, If(nZoom < 3, 1.25, 1.30))
					uAux2 := ::nCenterT - (nSize4*nPercent)

					uAux3 := "3" //Texto alinhado ao Centro
				ElseIf nValor == 5
					nPercent := If(nZoom == 1, -0.15, If(nZoom < 3, -0.15, -0.10))
					uAux1 := ::nCenterL + (nSize3*nPercent)

					nPercent := If(nZoom == 1, 0.75, If(nZoom < 3, 0.80, 0.85))
					uAux2 := ::nCenterT - (nSize4*nPercent)

					uAux3 := "2" //Texto alinhado a Direita
				ElseIf nValor == 6
					nPercent := If(nZoom == 1, 0.00, If(nZoom < 3, 0.01, 0.06))

					uAux1 := ::nCenterL + (nSize3*nPercent)
					uAux2 := ::nCenterT

					uAux3 := "2" //Texto alinhado a Direita
				EndIf
			EndIf

			/*Converte o valor do marcador para uma string abreviada conforme a legenda
			 exclusico para valores maiores q 1 milh�o.*/
			aAdd(aValChar, ::ConfigLgnd(aValores[nValor],.T.))

			nID     := ::ShpNextID()
			nCamada := 6
			aShape  := {nID, nTipo, uAux1, uAux2, nSize3, nAltText, aValChar[nValor], cFonteMarc+uAux3, 1, aCores[__nClrMarF], .T., aValores[nValor]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nValor, __nRfsHMar})
		Next nValor

	ElseIf cStyle == __cSGrBarr // Gr�fico em Barras

		//--------------------------------------------------
		// 2 - RECTROUNDED
		//--------------------------------------------------
		nTipo := __nRECTROUNDED

		//BARRAS
		nSoma := ( 007.5 + (nZoom/2) ) //Soma Altura

		uAux1    := ::nLeft //Left Inicial
		uAux2    := ( ::nCenterT + (::nBars*(nSoma/2)) ) //Top Inicial
		nLargura := ( 006 + nZoom ) //Width
		nAltura  := If(nZoom <= 2, 0, If(nZoom <= 4, 010, 030)) //Height
		For nBarra := 1 To ::nBars
			uAux1   += (nLargura + 002 + (nZoom/2)) //Left
			uAux2   -= nSoma //Height
			nAltura += nSoma //Height

			// Sombreamento Central
			If aSombras[__nShwCent]
				nID     := ::ShpNextID()
				nCamada := 2
				aShape  := {nID, nTipo, (uAux1-2), uAux2, (nLargura+4), (nAltura+4), ::cClrShdw, 0, ::cClrShdw}
				::SetShape(nCamada, aShape)
			EndIf

			//Barra Normal
			nID     := ::ShpNextID()
			nCamada := 3
			aShape  := {nID, nTipo, uAux1, uAux2, nLargura, nAltura, aCores[__nClrCent], aOutros[__nOthCont], aCores[__nClrCont]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})

			//--- Armazena as posicoes onde devem estar os marcadores
			uAux3 := ( nBarra == 1 .Or. nBarra == ::nBars .Or. nBarra == (::nBars/2) ) //As marcacoes da Primeira barra, da Ultima, e tambem a do Meio, devem ser mostradas
			If !uAux3 .And. ::nMarcads == 5
				//Mostra as marcacoes entre a Primeira-Meio e Meio-Ultima barra
				uAux3 := ( nBarra == Int(::nBars/4) .Or. nBarra == Int((::nBars/2)+(::nBars/4)) )
			EndIf
			If uAux3
				//1            ; 2
				//Left Inicial ; Top Inicial
				aAdd(aMarca, {( uAux1 + (nLargura/2) ), ( uAux2 + nAltura + If(nZoom < 4, 005, 010) )})
			EndIf
		Next nBarra

		//--------------------------------------------------
		// 3 - ELLIPSE
		//--------------------------------------------------
		nTipo := __nELLIPSE

		// Sombreamento Inferior
		If aSombras[__nShwInfe]
			uAux1 := (::nSize * 0.55) //Top
			uAux2 := (::nSize * 0.30) //left
			uAux3 := (uAux2 * 2) //Width

			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, ::nCenterL-uAux2, ::nCenterT+uAux1, uAux3, __nShadowH, ::cClrShdw, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		//--------------------------------------------------
		// 6 - LINE
		//--------------------------------------------------
		nTipo := __nLINE

		//Linha para os Marcadores
		For nMarca := 1 To Len(aMarca)
			uAux1 := aMarca[nMarca][1]
			uAux2 := aMarca[nMarca][2]
			uAux3 := 005
			If Len(aMarca) == 5 .And. ( nMarca == 1 .Or. nMarca == 3 .Or. nMarca == 5 )
				uAux3 := ( uAux3 + 005 )
			EndIf

			nID     := ::ShpNextID()
			nCamada := 4
			aShape  := {nID, nTipo, uAux1, uAux2, uAux1, uAux2+uAux3, aOutros[__nOthCont], aCores[__nClrCont]}
			::SetShape(nCamada, aShape)
		Next nMarca

		//--------------------------------------------------
		// 7 - TEXT
		//--------------------------------------------------
		nTipo := __nTEXT

		//Subtitulo localizado na parte Superior Esquerda do Grafico em Barras
		uAux1 := ::nLeft
		uAux2 := (::nCenterT * 0.80)

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, uAux1, uAux2, (nSize4*2), nSize4, aTextos[__nTxtSubt], cFonteMarc+"2", 1, aCores[__nClrSubF], .F.}
		::SetShape(nCamada, aShape)

		//Valor Atual do Indicador
		uAux1 := ::nLeft
		uAux2 := (::nCenterT * 0.65)

		nID     := ::ShpNextID()
		nCamada := 7
		aShape  := {nID, nTipo, uAux1, uAux2, (nSize4*2), nSize4, ::ConfigLgnd(::GetValue()), cFonteText, 1, aCores[__nClrValF], .T., ::GetValue()}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHAtu})

		// T�tulo localizado abaixo das Barras
		uAux1 := (::nSize * 0.60)

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT+uAux1, ::nSize, (::nCenterT/2), aTextos[__nTxtTitu], cFonteTitl, 1, aCores[__nClrTitF], .F.}
		::SetShape(nCamada, aShape)

		//VALORES dos MARCADORES
		For nMarca := 1 To Len(aMarca)
			uAux1 := aMarca[nMarca][1]
			uAux2 := aMarca[nMarca][2]
			uAux3 := 005
			If Len(aMarca) == 5 .And. ( nMarca == 1 .Or. nMarca == 3 .Or. nMarca == 5 )
				uAux3 := ( uAux3 + If(nZoom < 4, 005, 010) )
			EndIf

			nValor := nMarca
			If Len(aMarca) == 3
				Do Case
					Case nValor == 1
						nValor := 1
					Case nValor == 2
						nValor := 3
					Case nValor == 3
						nValor := 5
				EndCase
			EndIf

			/*Converte o valor do marcador para uma string abreviada conforme a legenda
			 exclusico para valores maiores q 1 milh�o.*/
			aAdd(aValChar, ::ConfigLgnd(aValores[nValor],.T.))

			nID     := ::ShpNextID()
			nCamada := 6
			aShape  := {nID, nTipo, uAux1, uAux2+uAux3, nSize3, nAltText, aValChar[nMarca], cFonteMarc+"1", 1, aCores[__nClrMarF], .T., aValores[nValor]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nValor, __nRfsHMar})
		Next nMarca

	ElseIf cStyle == __cSPirami // Pir�mide

		//--------------------------------------------------
		// 3 - ELLIPSE
		//--------------------------------------------------
		nTipo := __nELLIPSE

		// Sombreamento Inferior
		If aSombras[__nShwInfe]
			uAux1 := (::nSize * 0.55) //Top
			uAux2 := (::nSize * 0.30) //left
			uAux3 := (uAux2 * 2) //Width

			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, ::nCenterL-uAux2, ::nCenterT+uAux1, uAux3, __nShadowH, ::cClrShdw, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		//--------------------------------------------------
		// 5 - POLYGON
		//--------------------------------------------------
		nTipo := __nPOLYGON

		nLargura := ( ::nCenterL - ::nLeft )
		nAltura  := ::nSize

		// Pol�gonos que formam a pir�mide
		uAux1 := nAltura
		uAux2 := nLargura

		nSeno := 0.500 // Seno de 30 graus
		nCoss := 0.866 // Cosseno de 30 graus
		For nBarra := 1 To ::nBars
			// C�lculo dos Catetos e da Hipotenusa no tri�ngulo
			aAux := Array(3)
			aAux[1] := ( uAux2 ) // Largura (Cateto Adjacente)
			aAux[2] := ( aAux[1] / nCoss ) // Hipotenusa [cos(x) = ca/h -> h = ca/cos(x)]
			aAux[3] := ( aAux[2] * nSeno ) // Altura (Cateto Oposto) [sen(x) = co/h -> co = sen(x).h]
			// Espa�amento para fechar os dois lados do tri�ngulo
			nSoma := Round(aAux[1]*0.10,0)

			// Pol�gono da Esquerda - Inferior
			nID     := ::ShpNextID()
			nCamada := 3
			aShape  := {nID, nTipo, ::nCenterL+1, uAux1, (::nCenterL-aAux[1]), uAux1-aAux[3], (::nCenterL-aAux[1])+nSoma, uAux1-aAux[3]-nSoma, aCores[__nClrCent], 0, aCores[__nClrCent]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
				aOldShape := aClone( aShape )
				// LINHA DE CONTORNO - Inferior
				nID     := ::ShpNextID()
				nCamada := 4
				aShape  := {nID, __nLINE, aOldShape[3], aOldShape[4], aOldShape[5], aOldShape[6], (aOutros[__nOthCont]*0.50), aCores[__nClrCont]}
				::SetShape(nCamada, aShape)
				aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
				// LINHA DE CONTORNO - Esquerda
				nID     := ::ShpNextID()
				nCamada := 4
				aShape  := {nID, __nLINE, aOldShape[5], aOldShape[6], aOldShape[7], aOldShape[8], (aOutros[__nOthCont]*0.50), aCores[__nClrCont]}
				::SetShape(nCamada, aShape)
				aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
				// MARCA��O
				If nBarra == 1
					aAdd(aMarca, {aOldShape[3], aOldShape[4]}) // Left, Top
				EndIf
				// Sombreamento Central
				If aSombras[__nShwCent]
					// LINHA DE CONTORNO - Inferior
					nID     := ::ShpNextID()
					nCamada := 2
					aShape  := {nID, __nLINE, aOldShape[3], aOldShape[4], aOldShape[5], aOldShape[6], 3, ::cClrShdw}
					::SetShape(nCamada, aShape)
					// LINHA DE CONTORNO - Esquerda
					nID     := ::ShpNextID()
					nCamada := 2
					aShape  := {nID, __nLINE, aOldShape[5], aOldShape[6], aOldShape[7], aOldShape[8], 3, ::cClrShdw}
					::SetShape(nCamada, aShape)
				EndIf

			// Pol�gono da Esquerda - Superior
			nID     := ::ShpNextID()
			nCamada := 3
			aShape  := {nID, nTipo, ::nCenterL, uAux1, ::nCenterL, uAux1-(aAux[3]*0.30), (::nCenterL-aAux[1])+nSoma-1, uAux1-aAux[3]-nSoma, aCores[__nClrCent], 0, aCores[__nClrCent]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
				aOldShape := aClone( aShape )
				// LINHA DE CONTORNO - Direita (Centro)
				nID     := ::ShpNextID()
				nCamada := 4
				aShape  := {nID, __nLINE, aOldShape[3], aOldShape[4], aOldShape[5], aOldShape[6], (aOutros[__nOthCont]*0.50), aCores[__nClrCont]}
				::SetShape(nCamada, aShape)
				aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
				// LINHA DE CONTORNO - Superior
				nID     := ::ShpNextID()
				nCamada := 4
				aShape  := {nID, __nLINE, aOldShape[5], aOldShape[6], aOldShape[7], aOldShape[8], (aOutros[__nOthCont]*0.50), aCores[__nClrCont]}
				::SetShape(nCamada, aShape)
				aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
				// Sombreamento Central
				If aSombras[__nShwCent]
					// LINHA DE CONTORNO - Direita (Centro)
					nID     := ::ShpNextID()
					nCamada := 2
					aShape  := {nID, __nLINE, aOldShape[3], aOldShape[4], aOldShape[5], aOldShape[6], 3, ::cClrShdw}
					::SetShape(nCamada, aShape)
					// LINHA DE CONTORNO - Superior
					nID     := ::ShpNextID()
					nCamada := 2
					aShape  := {nID, __nLINE, aOldShape[5], aOldShape[6], aOldShape[7], aOldShape[8], 3, ::cClrShdw}
					::SetShape(nCamada, aShape)
				EndIf

			// Pol�gono da Direita - Inferior
			nID     := ::ShpNextID()
			nCamada := 3
			aShape  := {nID, nTipo, ::nCenterL-1, uAux1, (::nCenterL+aAux[1]), uAux1-aAux[3], (::nCenterL+aAux[1])-nSoma, uAux1-aAux[3]-nSoma, aCores[__nClrCent], 0, aCores[__nClrCent]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
				aOldShape := aClone( aShape )
				// LINHA DE CONTORNO - Inferior
				nID     := ::ShpNextID()
				nCamada := 4
				aShape  := {nID, __nLINE, aOldShape[3], aOldShape[4], aOldShape[5], aOldShape[6], (aOutros[__nOthCont]*0.50), aCores[__nClrCont]}
				::SetShape(nCamada, aShape)
				aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
				// LINHA DE CONTORNO - Direita
				nID     := ::ShpNextID()
				nCamada := 4
				aShape  := {nID, __nLINE, aOldShape[5], aOldShape[6], aOldShape[7], aOldShape[8], (aOutros[__nOthCont]*0.50), aCores[__nClrCont]}
				::SetShape(nCamada, aShape)
				aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
				// MARCA��O
				If nBarra == Int(::nBars/2)
					aAdd(aMarca, {aOldShape[7], aOldShape[8]-10}) // Left, Top
				ElseIf ( ::nMarcads == 5 .And. ( nBarra == Int(::nBars/4) .Or. nBarra == Int((::nBars/2)+(::nBars/4)) ) )
					aAdd(aMarca, {aOldShape[7], aOldShape[8]-20}) // Left, Top
				EndIf
				// Sombreamento Central
				If aSombras[__nShwCent]
					// LINHA DE CONTORNO - Inferior
					nID     := ::ShpNextID()
					nCamada := 2
					aShape  := {nID, __nLINE, aOldShape[3], aOldShape[4], aOldShape[5], aOldShape[6], 3, ::cClrShdw}
					::SetShape(nCamada, aShape)
					// LINHA DE CONTORNO - Direita
					nID     := ::ShpNextID()
					nCamada := 2
					aShape  := {nID, __nLINE, aOldShape[5], aOldShape[6], aOldShape[7], aOldShape[8], 3, ::cClrShdw}
					::SetShape(nCamada, aShape)
				EndIf

			// Pol�gono da Direita - Superior
			nID     := ::ShpNextID()
			nCamada := 3
			aShape  := {nID, nTipo, ::nCenterL, uAux1, ::nCenterL, uAux1-(aAux[3]*0.30), (::nCenterL+aAux[1])-nSoma+1, uAux1-aAux[3]-nSoma, aCores[__nClrCent], 0, aCores[__nClrCent]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
				aOldShape := aClone( aShape )
				// LINHA DE CONTORNO - Esquerda (Centro)
				nID     := ::ShpNextID()
				nCamada := 4
				aShape  := {nID, __nLINE, aOldShape[3], aOldShape[4], aOldShape[5], aOldShape[6], (aOutros[__nOthCont]*0.50), aCores[__nClrCont]}
				::SetShape(nCamada, aShape)
				aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
				// LINHA DE CONTORNO - Superior
				nID     := ::ShpNextID()
				nCamada := 4
				aShape  := {nID, __nLINE, aOldShape[5], aOldShape[6], aOldShape[7], aOldShape[8], (aOutros[__nOthCont]*0.50), aCores[__nClrCont]}
				::SetShape(nCamada, aShape)
				aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
				// Sombreamento Central
				If aSombras[__nShwCent]
					// LINHA DE CONTORNO - Esquerda (Centro)
					nID     := ::ShpNextID()
					nCamada := 2
					aShape  := {nID, __nLINE, aOldShape[3], aOldShape[4], aOldShape[5], aOldShape[6], 3, ::cClrShdw}
					::SetShape(nCamada, aShape)
					// LINHA DE CONTORNO - Superior
					nID     := ::ShpNextID()
					nCamada := 2
					aShape  := {nID, __nLINE, aOldShape[5], aOldShape[6], aOldShape[7], aOldShape[8], 3, ::cClrShdw}
					::SetShape(nCamada, aShape)
				EndIf

			// Se foi montado o �ltimo conjunto de pol�gonos, monta o TOPO da pir�mide
			If nBarra == ::nBars
				// Pol�gono do TOPO da Pir�mide - Inferior
				nID     := ::ShpNextID()
				nCamada := 3
				aShape  := {nID, nTipo, ::nCenterL, uAux1, (::nCenterL-aAux[1])+nSoma, uAux1-aAux[3]-nSoma, (::nCenterL+aAux[1])-nSoma, uAux1-aAux[3]-nSoma, aCores[__nClrCent], 0, aCores[__nClrCent]}
				::SetShape(nCamada, aShape)
				aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})

				// Pol�gono do TOPO da Pir�mide - Superior
				nID     := ::ShpNextID()
				nCamada := 3
				aShape  := {nID, nTipo, ::nCenterL, uAux1-(aAux[3]*2), (::nCenterL-aAux[1])+nSoma, uAux1-aAux[3]-nSoma, (::nCenterL+aAux[1])-nSoma, uAux1-aAux[3]-nSoma, aCores[__nClrCent], 0, aCores[__nClrCent]}
				::SetShape(nCamada, aShape)
				aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
					aOldShape := aClone( aShape )
					// LINHA DE CONTORNO - Esquerda
					nID     := ::ShpNextID()
					nCamada := 4
					aShape  := {nID, __nLINE, aOldShape[3], aOldShape[4], aOldShape[5], aOldShape[6], (aOutros[__nOthCont]*0.50), aCores[__nClrCont]}
					::SetShape(nCamada, aShape)
					aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
					// LINHA DE CONTORNO - Direita
					nID     := ::ShpNextID()
					nCamada := 4
					aShape  := {nID, __nLINE, aOldShape[3], aOldShape[4], aOldShape[7], aOldShape[8], (aOutros[__nOthCont]*0.50), aCores[__nClrCont]}
					::SetShape(nCamada, aShape)
					aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
					// MARCA��O
					aAdd(aMarca, {aOldShape[3], aOldShape[4]}) // Left, Top
					// Sombreamento Central
					If aSombras[__nShwCent]
						// LINHA DE CONTORNO - Esquerda
						nID     := ::ShpNextID()
						nCamada := 2
						aShape  := {nID, __nLINE, aOldShape[3], aOldShape[4], aOldShape[5], aOldShape[6], 3, ::cClrShdw}
						::SetShape(nCamada, aShape)
						// LINHA DE CONTORNO - Direita
						nID     := ::ShpNextID()
						nCamada := 2
						aShape  := {nID, __nLINE, aOldShape[3], aOldShape[4], aOldShape[7], aOldShape[8], 3, ::cClrShdw}
						::SetShape(nCamada, aShape)
					EndIf
			Else // Sen�o, define nova altura e largura
				// Diminui a altura
				uAux1 -= ( aAux[3] * 0.50 )
				// Diminui a largura
				uAux2 -= ( aAux[1] * 0.20 )
			EndIf
		Next nBarra

		//--------------------------------------------------
		// 7 - TEXT
		//--------------------------------------------------
		nTipo := __nTEXT

		// Subt�tulo localizado na parte Superior da Pir�mide
		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nCenterL, (::nCenterT*0.40), (nSize4*2), nSize4, aTextos[__nTxtSubt], cFonteMarc+"2", 1, aCores[__nClrSubF], .F.}
		::SetShape(nCamada, aShape)

		// Valor Atual do Indicador
		uAux1 := nSize4 + (3 * nZoom) + (2.5 * nZoom)

		nID     := ::ShpNextID()
		nCamada := 7
		aShape  := {nID, nTipo, ::nCenterL, (::nCenterT*0.20), (nSize4*1.95), (::nCenterT/4), ::ConfigLgnd(::GetValue()), cFonteText, 1, aCores[__nClrValF], .T., ::GetValue()}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHAtu})

		// T�tulo localizado abaixo da Pir�mide
		uAux1 := (::nSize * 0.60)

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT+uAux1, ::nSize, (::nCenterT/2), aTextos[__nTxtTitu], cFonteTitl, 1, aCores[__nClrTitF], .F.}
		::SetShape(nCamada, aShape)

		// VALORES dos MARCADORES
		For nMarca := 1 To Len(aMarca)
			nValor := nMarca
			If Len(aMarca) == 3
				Do Case
					Case nValor == 1
						nValor := 1
					Case nValor == 2
						nValor := 3
					Case nValor == 3
						nValor := 5
				EndCase
			EndIf
			// Espa�o 'LEFT'
			If nMarca == 1 .Or. nMarca == Len(aMarca)
				uAux1 := (::nCenterL-nSize4)-If(nZoom < 4, 10, 15)
			Else
				uAux1 := aMarca[nMarca][1]+If(nZoom < 4, 15, 20)
			EndIf
			// Espa�o 'TOP'
			If nMarca == 1
				uAux2 := aMarca[nMarca][2]
			ElseIf nMarca == Len(aMarca)
				uAux2 := aMarca[nMarca][2]-If(nZoom < 4, 10, 15)
			Else
				uAux2 := aMarca[nMarca][2]
			EndIf
			// Alinhamento da Fonte
			If nMarca == 1 .Or. nMarca == Len(aMarca)
				uAux3 := "2"
			Else
				uAux3 := "1"
			EndIf

			/*Converte o valor do marcador para uma string abreviada conforme a legenda
			 exclusico para valores maiores q 1 milh�o.*/
			aAdd(aValChar, ::ConfigLgnd(aValores[nValor],.T.))

			nID     := ::ShpNextID()
			nCamada := 6
			aShape  := {nID, nTipo, uAux1, uAux2, nSize3, nAltText, aValChar[nMarca], cFonteMarc+uAux3, 1, aCores[__nClrMarF], .T., aValores[nValor]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nValor, __nRfsHMar})
		Next nMarca

	ElseIf cStyle == __cSRadar // Radar

		//--------------------------------------------------
		// 3 - ELLIPSE
		//--------------------------------------------------
		nTipo := __nELLIPSE

		// Sombreamento Inferior
		If aSombras[__nShwInfe]
			uAux1 := (::nSize * 0.55) //Top
			uAux2 := (::nSize * 0.30) //left
			uAux3 := (uAux2 * 2) //Width

			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, ::nCenterL-uAux2, ::nCenterT+uAux1, uAux3, __nShadowH, ::cClrShdw, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		//--------------------------------------------------
		// 6 - LINE
		//--------------------------------------------------
		nTipo := __nLINE

		nCenterT := ::nCenterT + (10*nZoom)
		nCenterL := ::nCenterL

		nSoma := ( 120 / (__nMaxZoom__-1) )
		nLargura := 100 + (nSoma * (nZoom-1)) // M�nima: 100; M�xima: 220
		nSoma := ( 96 / (__nMaxZoom__-1) )
		nAltura  := 68 + (nSoma * (nZoom-1)) // M�nima: 68; M�xima: 164

		// Linhas que formam o Radar
		uAux1 := ( nLargura / ::nBars )
		uAux2 := ( nAltura / ::nBars )
		For nBarra := 1 To ::nBars
			// Posi��es das Linhas (formando um tri�ngulo)
			aAux := Array(6)
			aAux[1] := ( nCenterL - uAux1 ) // Left 1
			aAux[2] := ( nCenterT + uAux2 ) // Top 1
			aAux[3] := ( nCenterL ) // Left 2
			aAux[4] := ( nCenterT - uAux2 ) // Top 2
			aAux[5] := ( nCenterL + uAux1 ) // Left 3
			aAux[6] := ( nCenterT + uAux2 ) // Top 3

			// Linha da Esquerda: /
			nID     := ::ShpNextID()
			nCamada := 4
			aShape  := {nID, nTipo, aAux[1], aAux[2], aAux[3], aAux[4], aOutros[__nOthCont], aCores[__nClrCent]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
			// Sombreamento Central
			If aSombras[__nShwCent]
				// LINHA DE CONTORNO
				nID     := ::ShpNextID()
				nCamada := 2
				aShape  := {nID, nTipo, aShape[3], aShape[4], aShape[5], aShape[6], 2, ::cClrShdw}
				::SetShape(nCamada, aShape)
			EndIf

			// Linha da Direta: \
			nID     := ::ShpNextID()
			nCamada := 4
			aShape  := {nID, nTipo, aAux[5], aAux[6], aAux[3], aAux[4], aOutros[__nOthCont], aCores[__nClrCent]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
			// MARCA��O
			If nBarra == 1 .Or. nBarra == ::nBars
				aAdd(aMarca, {nCenterL, aShape[6]}) // Left, Top
			ElseIf nBarra == Int(::nBars/2) .Or. ( ::nMarcads == 5 .And. ( nBarra == Int(::nBars/4) .Or. nBarra == Int((::nBars/2)+(::nBars/4)) ) )
				aAdd(aMarca, {aShape[5], aShape[6]}) // Left, Top
			EndIf
			// Sombreamento Central
			If aSombras[__nShwCent]
				// LINHA DE CONTORNO
				nID     := ::ShpNextID()
				nCamada := 2
				aShape  := {nID, nTipo, aShape[3], aShape[4], aShape[5], aShape[6], 2, ::cClrShdw}
				::SetShape(nCamada, aShape)
			EndIf

			// Linha da Base: __
			nID     := ::ShpNextID()
			nCamada := 4
			aShape  := {nID, nTipo, aAux[1], aAux[2], aAux[5], aAux[6], aOutros[__nOthCont], aCores[__nClrCent]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
			// Sombreamento Central
			If aSombras[__nShwCent]
				// LINHA DE CONTORNO
				nID     := ::ShpNextID()
				nCamada := 2
				aShape  := {nID, nTipo, aShape[3], aShape[4], aShape[5], aShape[6], 2, ::cClrShdw}
				::SetShape(nCamada, aShape)
			EndIf

			// Incrementa a Largura
			uAux1 += ( nLargura / ::nBars )
			// Incrementa a Altura
			uAux2 += ( nAltura / ::nBars )
		Next nBarra

		//--------------------------------------------------
		// 7 - TEXT
		//--------------------------------------------------
		nTipo := __nTEXT

		// Subt�tulo localizado na parte Superior da Pir�mide
		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nCenterL, (::nCenterT*0.40), (nSize4*2), nSize4, aTextos[__nTxtSubt], cFonteMarc+"2", 1, aCores[__nClrSubF], .F.}
		::SetShape(nCamada, aShape)

		// Valor Atual do Indicador
		uAux1 := nSize4 + (3 * nZoom) + (2.5 * nZoom)

		nID     := ::ShpNextID()
		nCamada := 7
		aShape  := {nID, nTipo, ::nCenterL, (::nCenterT*0.20), (nSize4*1.95), (::nCenterT/4), ::ConfigLgnd(::GetValue()), cFonteText, 1, aCores[__nClrValF], .T., ::GetValue()}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHAtu})

		// T�tulo localizado abaixo do Radar
		uAux1 := (::nSize * 0.60)

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT+uAux1, ::nSize, (::nCenterT/2), aTextos[__nTxtTitu], cFonteTitl, 1, aCores[__nClrTitF], .F.}
		::SetShape(nCamada, aShape)

		// VALORES dos MARCADORES
		For nMarca := 1 To Len(aMarca)
			nValor := nMarca
			If Len(aMarca) == 3
				Do Case
					Case nValor == 1
						nValor := 1
					Case nValor == 2
						nValor := 3
					Case nValor == 3
						nValor := 5
				EndCase
			EndIf

			/*Converte o valor do marcador para uma string abreviada conforme a legenda
			 exclusico para valores maiores q 1 milh�o.*/
			aAdd(aValChar, ::ConfigLgnd(aValores[nValor],.T.))

			nID     := ::ShpNextID()
			nCamada := 6
			aShape  := {nID, nTipo, (aMarca[nMarca][1]-nSize3), (aMarca[nMarca][2]-5), nSize3, nAltText, aValChar[nMarca], cFonteMarc+"2", 1, aCores[__nClrMarF], .T., aValores[nValor]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nValor, __nRfsHMar})
		Next nMarca

	ElseIf cStyle == __cSTeia // Teia

		//--------------------------------------------------
		// 3 - ELLIPSE
		//--------------------------------------------------
		nTipo := __nELLIPSE

		// Sombreamento Inferior
		If aSombras[__nShwInfe]
			uAux1 := (::nSize * 0.55) //Top
			uAux2 := (::nSize * 0.30) //left
			uAux3 := (uAux2 * 2) //Width

			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, ::nCenterL-uAux2, ::nCenterT+uAux1, uAux3, __nShadowH, ::cClrShdw, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		//--------------------------------------------------
		// 6 - LINE
		//--------------------------------------------------
		nTipo := __nLINE

		nCenterT := ::nCenterT + (10*nZoom)
		nCenterL := ::nCenterL

		nSoma := ( 130 / (__nMaxZoom__-1) )
		nLargura := 90 + (nSoma * (nZoom-1)) // M�nima: 90; M�xima: 220
		nAltura  := nLargura - 10 // M�nima: 80; M�xima: 210

		// Linhas que formam a Teia de Aranha
		uAux1 := ( nLargura / ::nBars )
		uAux2 := ( nAltura / ::nBars )
		For nBarra := 1 To ::nBars
			// Posi��es das Linhas (formando uma camada da teia)
			aAux := Array(12)
			// Array: Left1, Top1, Left2, Top2 (montando da direita para a esquerda, fechando o cilco de cima pra baixo)
			aAux[1] := { nCenterL+(uAux1/2), nCenterT, nCenterL+(uAux1/2), nCenterT-(uAux2/4) } // Linha: |
			aAux[2] := { aAux[1][3], aAux[1][4], nCenterL+(uAux1/4), aAux[1][4]-(uAux2/4) } // Linha: \
			aAux[3] := { aAux[2][3], aAux[2][4], nCenterL, aAux[2][4] } // Linha: -
			aAux[4] := { aAux[2][3], aAux[2][4], nCenterL-(uAux1/4), aAux[3][4] } // Linha: -
			aAux[5] := { aAux[4][3], aAux[4][4], nCenterL-(uAux1/2), aAux[1][4] } // Linha: /
			aAux[6] := { aAux[5][3], aAux[5][4], aAux[5][3], nCenterT } // Linha: |
			aAux[7] := { aAux[6][3], aAux[6][4], aAux[6][3], nCenterT+(uAux2/4) } // Linha: |
			aAux[8] := { aAux[7][3], aAux[7][4], nCenterL-(uAux1/4), aAux[7][4]+(uAux2/4) } // Linha: \
			aAux[9] := { aAux[8][3], aAux[8][4], nCenterL, aAux[8][4] } // Linha: _
			aAux[10] := { aAux[9][3], aAux[9][4], nCenterL+(uAux1/4), aAux[9][4] } // Linha: _
			aAux[11] := { aAux[10][3], aAux[10][4], nCenterL+(uAux1/2), aAux[7][4] } // Linha: /
			aAux[12] := { aAux[11][3], aAux[11][4], aAux[1][1], aAux[1][2] } // Linha: |
			// MARCA��O
			If nBarra == 1 .Or. nBarra == ::nBars .Or. ;
				nBarra == Int(::nBars/2) .Or. ( ::nMarcads == 5 .And. ( nBarra == Int(::nBars/4) .Or. nBarra == Int((::nBars/2)+(::nBars/4)) ) )
				aAdd(aMarca, {aAux[4][3], aAux[4][4]}) // Left, Top
			EndIf

			// Linhas que cruzam a teia
			If nBarra == 1
				uAux3 := Array(8)

				uAux3[1] := Array(4) // Linha: /
				uAux3[1][1] := nCenterL // Left1
				uAux3[1][2] := nCenterT // Top1

				uAux3[2] := Array(4) // Linha: /
				uAux3[2][1] := nCenterL // Left1
				uAux3[2][2] := nCenterT // Top1

				uAux3[3] := Array(4) // Linha: \
				uAux3[3][1] := nCenterL // Left1
				uAux3[3][2] := nCenterT // Top1

				uAux3[4] := Array(4) // Linha: \
				uAux3[4][1] := nCenterL // Left1
				uAux3[4][2] := nCenterT // Top1

				uAux3[5] := Array(4) // Linha: /
				uAux3[5][1] := nCenterL // Left1
				uAux3[5][2] := nCenterT // Top1

				uAux3[6] := Array(4) // Linha: /
				uAux3[6][1] := nCenterL // Left1
				uAux3[6][2] := nCenterT // Top1

				uAux3[7] := Array(4) // Linha: \
				uAux3[7][1] := nCenterL // Left1
				uAux3[7][2] := nCenterT // Top1

				uAux3[8] := Array(4) // Linha: \
				uAux3[8][1] := nCenterL // Left1
				uAux3[8][2] := nCenterT // Top1
			ElseIf nBarra == ::nBars
				uAux3[1][3] := aAux[1][3]+10 // Left2
				uAux3[1][4] := aAux[1][4]-4 // Top2

				uAux3[2][3] := aAux[2][3]+4 // Left2
				uAux3[2][4] := aAux[2][4]-10 // Top2

				uAux3[3][3] := aAux[5][1]-4 // Left2
				uAux3[3][4] := aAux[5][2]-10 // Top2

				uAux3[4][3] := aAux[6][1]-10 // Left2
				uAux3[4][4] := aAux[6][2]-4 // Top2

				uAux3[5][3] := aAux[7][3]-10 // Left2
				uAux3[5][4] := aAux[7][4]+4 // Top2

				uAux3[6][3] := aAux[8][3]-4 // Left2
				uAux3[6][4] := aAux[8][4]+10 // Top2

				uAux3[7][3] := aAux[11][1]+4 // Left2
				uAux3[7][4] := aAux[11][2]+10 // Top2

				uAux3[8][3] := aAux[12][1]+10 // Left2
				uAux3[8][4] := aAux[12][2]+4 // Top2
			EndIf

			// Monta Teia
			For nX := 1 To Len(aAux)
				// Linha
				nID     := ::ShpNextID()
				nCamada := 4
				aShape  := {nID, nTipo, aAux[nX][1], aAux[nX][2], aAux[nX][3], aAux[nX][4], aOutros[__nOthCont], aCores[__nClrCent]}
				::SetShape(nCamada, aShape)
				aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
				// Sombreamento Central
				If aSombras[__nShwCent]
					// LINHA DE CONTORNO
					nID     := ::ShpNextID()
					nCamada := 2
					aShape  := {nID, nTipo, aShape[3], aShape[4], aShape[5], aShape[6], 2, ::cClrShdw}
					::SetShape(nCamada, aShape)
				EndIf
			Next nX

			// Monta as linhas que cruzam a teia
			If nBarra == ::nBars
				For nX := 1 To Len(uAux3)
					// Linha
					nID     := ::ShpNextID()
					nCamada := 3
					aShape  := {nID, nTipo, uAux3[nX][1], uAux3[nX][2], uAux3[nX][3], uAux3[nX][4], (aOutros[__nOthCont]*0.10), aCores[__nClrCont]}
					::SetShape(nCamada, aShape)
				Next nX
			EndIf

			// Incremento auxiliar da teia a cada nova camada criada, para dar um efeito do centro menor para as bordas maiores (mais espa�adas)
			nSoma := 0
			If nBarra >= Int(::nBars/2)
				nSoma += 4
			EndIf
			If nBarra >= Int((::nBars/2)+(::nBars/4))
				nSoma += 8
			EndIf
			// Incrementa a Largura
			uAux1 += ( ( nLargura / ::nBars ) + nSoma )
			// Incrementa a Altura
			uAux2 += ( ( nAltura / ::nBars ) + nSoma )
		Next nBarra

		//--------------------------------------------------
		// 7 - TEXT
		//--------------------------------------------------
		nTipo := __nTEXT

		// Subt�tulo localizado na parte Superior da Pir�mide
		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nCenterL, (::nCenterT*0.40), (nSize4*2), nSize4, aTextos[__nTxtSubt], cFonteMarc+"2", 1, aCores[__nClrSubF], .F.}
		::SetShape(nCamada, aShape)

		// Valor Atual do Indicador
		uAux1 := nSize4 + (3 * nZoom) + (2.5 * nZoom)

		nID     := ::ShpNextID()
		nCamada := 7
		aShape  := {nID, nTipo, ::nCenterL, (::nCenterT*0.20), (nSize4*1.95), (::nCenterT/4), ::ConfigLgnd(::GetValue()), cFonteText, 1, aCores[__nClrValF], .T., ::GetValue()}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHAtu})

		// T�tulo localizado abaixo da Teia
		uAux1 := (::nSize * 0.60)

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT+uAux1, ::nSize, (::nCenterT/2), aTextos[__nTxtTitu], cFonteTitl, 1, aCores[__nClrTitF], .F.}
		::SetShape(nCamada, aShape)

		// VALORES dos MARCADORES
		For nMarca := 1 To Len(aMarca)
			nValor := nMarca
			If Len(aMarca) == 3
				Do Case
					Case nValor == 1
						nValor := 1
					Case nValor == 2
						nValor := 3
					Case nValor == 3
						nValor := 5
				EndCase
			EndIf

			/*Converte o valor do marcador para uma string abreviada conforme a legenda
			 exclusico para valores maiores q 1 milh�o.*/
			aAdd(aValChar, ::ConfigLgnd(aValores[nValor],.T.))

			nID     := ::ShpNextID()
			nCamada := 6
			aShape  := {nID, nTipo, (aMarca[nMarca][1]-nSize3), (aMarca[nMarca][2]-5), nSize3, nAltText, aValChar[nMarca], cFonteMarc+"2", 1, aCores[__nClrMarF], .T., aValores[nValor]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nValor, __nRfsHMar})
		Next nMarca

	ElseIf cStyle == __cSSlider // Slider (Horizontal)

		//--------------------------------------------------
		// 1 - RECT
		//--------------------------------------------------
		nTipo := __nRECT

		// Barra principal, container das cores
		nAltura  := ( ::nCenterT - ::nTop ) * 0.25
		nLargura := ( ::nCenterL - ::nLeft ) * 1.95

		nID     := ::ShpNextID()
		nCamada := 3
		aShape  := {nID, nTipo, ::nCenterL-(nLargura/2), ::nCenterT-(nAltura/1.5), nLargura, nAltura, aCores[__nClrCent], aOutros[__nOthCont], aCores[__nClrCont]}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, -1, __nRfsHCom})
		aMarca := Array(::nMarcads)
		aMarca[1] := {aShape[3], aShape[4] + aShape[6]}
		aMarca[If(::nMarcads == 3,2,3)] := {aShape[3] + (nLargura * 0.50), aMarca[1][2]}
		aMarca[If(::nMarcads == 3,3,5)] := {aShape[3] + nLargura, aMarca[1][2]}
		If ::nMarcads == 5
			aMarca[2] := {aShape[3] + (nLargura * 0.25), aMarca[1][2]}
			aMarca[4] := {aShape[3] + (nLargura * 0.75), aMarca[1][2]}
		EndIf

		// Sombreamento Central
		If aSombras[__nShwCent]
			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, aShape[3]-0.5, aShape[4]-0.5, aShape[5]+2, aShape[6]+3, ::cClrShdw, (aOutros[__nOthCont]*3), ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		// Barras de cores
		uAux1 := ( (nLargura-1) / ::nBars )
		uAux3 := ::nCenterL-(nLargura/2)
		For nBarra := 1 To ::nBars
			// Cria barra
			nID     := ::ShpNextID()
			nCamada := 3
			aShape  := {nID, nTipo, uAux3, ::nCenterT-(nAltura/1.5)+0.2, uAux1+1, nAltura-0.6, aCores[__nClrValB], 0, aCores[__nClrCont]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})

			// Incrementa Left (coluna)
			uAux3 += uAux1
		Next nBarra

		//--------------------------------------------------
		// 3 - ELLIPSE
		//--------------------------------------------------
		nTipo := __nELLIPSE

		// Sombreamento Inferior
		If aSombras[__nShwInfe]
			uAux1 := (::nSize * 0.55) //Top
			uAux2 := (::nSize * 0.30) //left
			uAux3 := (uAux2 * 2) //Width

			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, ::nCenterL-uAux2, ::nCenterT+uAux1, uAux3, __nShadowH, ::cClrShdw, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		//--------------------------------------------------
		// 5 - POLYGON
		//--------------------------------------------------
		nTipo := __nPOLYGON

		// Pol�gono que forma o marcador do valor atual
		uAux1 := ( ::nCenterT-(nAltura/1.5) + nAltura ) // Altura final da barra principal
		uAux2 := If(nZoom < 4, 10, 15) // Auxiliar da largura
		uAux3 := If(nZoom < 4, 5, 10) // Auxiliar da altura

		nID     := ::ShpNextID()
		nCamada := 4
		aShape  := {nID, nTipo, ::nCenterL-uAux2, uAux1+uAux3, ::nCenterL, uAux1-uAux3, ::nCenterL+uAux2, uAux1+uAux3, aCores[__nClrPntS], aOutros[__nOthCont], aCores[__nClrPntC]}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, -2, __nRfsHCom})

		//--------------------------------------------------
		// 6 - LINE
		//--------------------------------------------------
		nTipo := __nLINE

		// Linhas para marca��o
		uAux1 := If(nZoom < 4, 6, 10) // Incremento da altura
		uAux2 := 0 // Incremento final da altura
		For nMarca := 1 To Len(aMarca)
			uAux2 := uAux1
			If ::nMarcads == 5 .And. ( nMarca == 2 .Or. nMarca == 4 )
				uAux2 := ( uAux2 / 2 )
			EndIf

			nID     := ::ShpNextID()
			nCamada := 3
			aShape  := {nID, nTipo, aMarca[nMarca][1], aMarca[nMarca][2], aMarca[nMarca][1], aMarca[nMarca][2]+uAux2, aOutros[__nOthCont], aCores[__nClrCont]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
			// Sombreamento Central
			If aSombras[__nShwCent]
				// LINHA DE CONTORNO
				nID     := ::ShpNextID()
				nCamada := 2
				aShape  := {nID, nTipo, aShape[3], aShape[4], aShape[5], aShape[6], 2, ::cClrShdw}
				::SetShape(nCamada, aShape)
			EndIf
		Next nMarca

		//--------------------------------------------------
		// 7 - TEXT
		//--------------------------------------------------
		nTipo := __nTEXT

		// Subt�tulo localizado acima do Slider
		uAux1 := ( nAltura * 1.5 )

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT-uAux1, ::nSize, (::nCenterT/4), aTextos[__nTxtSubt], cFonteMarc+"2", 1, aCores[__nClrSubF], .F.}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

		// Valor Atual do Indicador
		uAux2 := ( uAux1 + If(nZoom < 4, 20, 30) )

		nID     := ::ShpNextID()
		nCamada := 7
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT-uAux2, ::nSize, (::nCenterT/4), ::ConfigLgnd(::GetValue()), cFonteText, 1, aCores[__nClrValF], .T., ::GetValue()}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHAtu})

		// T�tulo localizado abaixo do Slider
		uAux1 := (::nSize * 0.60)

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT+uAux1, ::nSize, (::nCenterT/2), aTextos[__nTxtTitu], cFonteTitl, 1, aCores[__nClrTitF], .F.}
		::SetShape(nCamada, aShape)

		// VALORES dos MARCADORES
		uAux1 := If(nZoom < 4, 6, 10) // Incremento da altura
		uAux2 := 0 // Incremento final da altura
		For nMarca := 1 To Len(aMarca)
			nValor := nMarca
			If Len(aMarca) == 3
				Do Case
					Case nValor == 1
						nValor := 1
					Case nValor == 2
						nValor := 3
					Case nValor == 3
						nValor := 5
				EndCase
			EndIf

			uAux2 := uAux1
			If Len(aMarca) == 5 .And. ( nMarca == 2 .Or. nMarca == 4 )
				uAux2 := ( uAux2 /2 )
			EndIf

			/*Converte o valor do marcador para uma string abreviada conforme a legenda
			 exclusico para valores maiores q 1 milh�o.*/
			aAdd(aValChar, ::ConfigLgnd(aValores[nValor],.T.))

			nID     := ::ShpNextID()
			nCamada := 6
			aShape  := {nID, nTipo, (aMarca[nMarca][1]-nSize3), (aMarca[nMarca][2]+uAux2), nSize3, nAltText, aValChar[nMarca], cFonteMarc+"2", 1, aCores[__nClrMarF], .T., aValores[nValor]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nValor, __nRfsHMar})
		Next nMarca

	ElseIf cStyle == __cSCilind // Cilindro (vertical)

		//--------------------------------------------------
		// 3 - ELLIPSE
		//--------------------------------------------------
		nTipo := __nELLIPSE

		// Sombreamento Inferior
		If aSombras[__nShwInfe]
			uAux1 := (::nSize * 0.55) //Top
			uAux2 := (::nSize * 0.30) //left
			uAux3 := (uAux2 * 2) //Width

			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, ::nCenterL-uAux2, ::nCenterT+uAux1, uAux3, __nShadowH, ::cClrShdw, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		// Tamanhos
		nAltura  := ( ::nCenterT - ::nTop ) * 0.60
		nLargura := ( ::nCenterL - ::nLeft ) * 1.05

		// Altura das Elipses
		uAux1 := 30

		// Altura Total
		uAux2 := ( nAltura * 2 )
		nSoma := ( uAux2 / ::nBars )

		// Cria Elipses
		For nBarra := 1 To ::nBars

			// Define a posi��o na vertical
			If nBarra == 1
				uAux3 := ::nCenterT+nAltura
			Else
				uAux3 -= nSoma
			EndIf

			// Cria o cilindro
			nID     := ::ShpNextID()
			nCamada := 4
			aShape  := {nID, nTipo, ::nCenterL-(nLargura/2), uAux3, nLargura, uAux1, aCores[__nClrCent], aCores[__nClrCent]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
			aOldShape := aClone(aShape)

			// Cria o contorno do cilindro
			nID     := ::ShpNextID()
			nCamada := 3
			aShape  := aClone(aOldShape)
			aShape[1] := nID
			aShape[3] -= 0.5
			aShape[4] -= 0.5
			aShape[5] += 1.0
			aShape[6] += 1.0
			aShape[7] := aCores[__nClrCont]
			aShape[8] := aCores[__nClrCont]
			aShape  := {nID, nTipo, ::nCenterL-(nLargura/2)-0.5, uAux3-0.5, nLargura+1, uAux1+1, aCores[__nClrCont], aCores[__nClrCont]}
			::SetShape(nCamada, aShape)

			// Sombreamento Central
			If aSombras[__nShwCent]
				nID     := ::ShpNextID()
				nCamada := 2
				aShape  := aClone(aOldShape)
				aShape[1] := nID
				aShape[3] -= 2.5
				aShape[4] -= 2.5
				aShape[5] += 5.0
				aShape[6] += 5.0
				aShape[7] := ::cClrShdw
				aShape[8] := ::cClrShdw
				::SetShape(nCamada, aShape)
			EndIf

			// MARCA��O
			If nBarra == 1 .Or. nBarra == ::nBars .Or. ;
				nBarra == Int(::nBars/2) .Or. ( ::nMarcads == 5 .And. ( nBarra == Int(::nBars/4) .Or. nBarra == Int((::nBars/2)+(::nBars/4)) ) )
				aAdd(aMarca, {aOldShape[3], aOldShape[4]+(uAux1/2)}) // Left, Top
			EndIf

		Next nBarra

		//--------------------------------------------------
		// 6 - LINE
		//--------------------------------------------------
		nTipo := __nLINE

		// Linhas para marca��o
		uAux1 := 6
		For nMarca := 1 To Len(aMarca)
			uAux2 := uAux1
			If ::nMarcads == 5 .And. ( nMarca == 2 .Or. nMarca == 4 )
				uAux2 := ( uAux2 / 2 )
			EndIf

			nID     := ::ShpNextID()
			nCamada := 3
			aShape  := {nID, nTipo, aMarca[nMarca][1], aMarca[nMarca][2], aMarca[nMarca][1]-uAux2, aMarca[nMarca][2], aOutros[__nOthCont], aCores[__nClrCont]}
			::SetShape(nCamada, aShape)
		Next nMarca

		//--------------------------------------------------
		// 7 - TEXT
		//--------------------------------------------------
		nTipo := __nTEXT

		// Subt�tulo localizado a direita do Cilindro
		uAux1 := ( nAltura * 1.20 )

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT-uAux1, ::nSize, (::nCenterT/4), aTextos[__nTxtSubt], cFonteMarc+"2", 1, aCores[__nClrSubF], .F.}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

		// Valor Atual do Indicador
		uAux1 := ( nAltura * 1.50 )

		nID     := ::ShpNextID()
		nCamada := 7
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT-uAux1, ::nSize, (::nCenterT/4), ::ConfigLgnd(::GetValue()), cFonteText, 1, aCores[__nClrValF], .T., ::GetValue()}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHAtu})

		// T�tulo localizado abaixo do Cilindro
		uAux1 := (::nSize * 0.60)

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT+uAux1, ::nSize, (::nCenterT/2), aTextos[__nTxtTitu], cFonteTitl, 1, aCores[__nClrTitF], .F.}
		::SetShape(nCamada, aShape)

		// VALORES dos MARCADORES
		For nMarca := 1 To Len(aMarca)
			nValor := nMarca
			If Len(aMarca) == 3
				Do Case
					Case nValor == 1
						nValor := 1
					Case nValor == 2
						nValor := 3
					Case nValor == 3
						nValor := 5
				EndCase
			EndIf

			/*Converte o valor do marcador para uma string abreviada conforme a legenda
			 exclusico para valores maiores q 1 milh�o.*/
			aAdd(aValChar, ::ConfigLgnd(aValores[nValor],.T.))

			nID     := ::ShpNextID()
			nCamada := 6
			aShape  := {nID, nTipo, (aMarca[nMarca][1]-nSize3)-8, aMarca[nMarca][2]-5, nSize3, nAltText, aValChar[nMarca], cFonteMarc+"2", 1, aCores[__nClrMarF], .T., aValores[nValor]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nValor, __nRfsHMar})
		Next nMarca

	ElseIf cStyle == __cSSemafo // Sem�foro (vertical)

		// Tamanhos
		nAltura  := ( ::nCenterT - ::nTop ) * 0.60
		nLargura := ( ::nCenterL - ::nLeft ) * 0.25

		//--------------------------------------------------
		// 2 - RECTROUNDED
		//--------------------------------------------------
		nTipo := __nRECTROUNDED

		//Barra Normal atr�s
		nID     := ::ShpNextID()
		nCamada := 3
		aShape  := {nID, nTipo, ::nCenterL-nLargura, ::nCenterT-nAltura, (nLargura*2), (nAltura*2), aCores[__nClrPntC], aOutros[__nOthCont], aCores[__nClrCont]}
		::SetShape(nCamada, aShape)
		aOldShape := aClone(aShape)

		//Barra Normal na frente
		nID     := ::ShpNextID()
		nCamada := 3
		aShape  := {nID, nTipo, (aOldShape[3]+2), aOldShape[4]+2, (aOldShape[5]-4), (aOldShape[6]-4), aCores[__nClrCent], 0, aCores[__nClrCont]}
		::SetShape(nCamada, aShape)

		// Sombreamento Central
		If aSombras[__nShwCent]
			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, (aOldShape[3]-2), aOldShape[4]-2, (aOldShape[5]+4), (aOldShape[6]+6), ::cClrShdw, 0, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		//--------------------------------------------------
		// 3 - ELLIPSE
		//--------------------------------------------------
		nTipo := __nELLIPSE

		// Sombreamento Inferior
		If aSombras[__nShwInfe]
			uAux1 := (::nSize * 0.55) //Top
			uAux2 := (::nSize * 0.30) //left
			uAux3 := (uAux2 * 2) //Width

			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, ::nCenterL-uAux2, ::nCenterT+uAux1, uAux3, __nShadowH, ::cClrShdw, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		//--------------------------------------------------
		// 4 - ARC
		//--------------------------------------------------
		nTipo := __nARC

		// Tamanhos dos C�rculos (ARCS) que formam o sem�foro
		uAux1 := ( ::nSize * 0.12 )

		For nBarra := 1 To ::nBars

			// Cor da sinaliza��o
			Do Case
				Case nBarra == 1
					uAux2 := __nClrEsqu
				Case nBarra == ::nBars
					uAux2 := __nClrDire
				Otherwise
					uAux2 := __nClrTopo
			EndCase

			// Posi��o na vertical (na altura)
			Do Case
				Case nBarra == 1
					uAux3 := ::nCenterT+(uAux1)
				Case nBarra == ::nBars
					uAux3 := ::nCenterT-(uAux1*2)
				Otherwise
					uAux3 := ::nCenterT-(uAux1/2)
			EndCase

			// Sinaliza��o
			nID     := ::ShpNextID()
			nCamada := 5
			aShape  := {nID, nTipo, ::nCenterL-(uAux1/2), uAux3, uAux1, aCores[uAux2], aCores[uAux2], 0, 360, 0, aCores[__nClrCont]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
			aOldShape := aClone(aShape)
			// Suporte 1 (cobrindo a sinaliza��o)
			nID     := ::ShpNextID()
			nCamada := 4
			aShape  := {nID, nTipo, aOldShape[3], aOldShape[4]-3, aOldShape[5], aCores[__nClrPntC], aCores[__nClrPntC], 0, 180, aOutros[__nOthCont], aCores[__nClrCont]}
			::SetShape(nCamada, aShape)
			// Suporte 2 (contornando a sinaliza��o)
			nID     := ::ShpNextID()
			nCamada := 4
			aShape  := {nID, nTipo, aOldShape[3]-1, aOldShape[4]-1, aOldShape[5]+2, aCores[__nClrCont], aCores[__nClrCont], 0, 360, 0, aCores[__nClrCont]}
			::SetShape(nCamada, aShape)
			// Suporte 3 (fundo da sinaliza��o - cria um efeito com transpar�ncia quando a sinaliza��o n�o for ativa)
			nID     := ::ShpNextID()
			nCamada := 4
			aShape  := {nID, nTipo, aOldShape[3], aOldShape[4], aOldShape[5], aCores[__nClrPntS], aCores[__nClrPntS], 0, 360, 0, aCores[__nClrCont]}
			::SetShape(nCamada, aShape)

			// MARCA��O
			If nBarra == 1 .Or. nBarra == ::nBars .Or. nBarra == (Int(::nBars/2)+1)
				aAdd(aMarca, {::nCenterL+nLargura+1, aOldShape[4]+(uAux1/2)}) // Left, Top
			EndIf

		Next nBarra

		//--------------------------------------------------
		// 6 - LINE
		//--------------------------------------------------
		nTipo := __nLINE

		// Linhas para marca��o
		uAux1 := 3
		For nMarca := 1 To Len(aMarca)
			uAux2 := uAux1
			If ::nMarcads == 5 .And. ( nMarca == 2 .Or. nMarca == 4 )
				uAux2 := ( uAux2 / 2 )
			EndIf

			nID     := ::ShpNextID()
			nCamada := 3
			aShape  := {nID, nTipo, aMarca[nMarca][1], aMarca[nMarca][2], aMarca[nMarca][1]+uAux2, aMarca[nMarca][2], aOutros[__nOthCont], aCores[__nClrCont]}
			::SetShape(nCamada, aShape)
		Next nMarca

		//--------------------------------------------------
		// 7 - TEXT
		//--------------------------------------------------
		nTipo := __nTEXT

		// Subt�tulo localizado a direita do Sem�foro
		uAux1 := ( nAltura * 1.20 )

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT-uAux1, ::nSize, (::nCenterT/4), aTextos[__nTxtSubt], cFonteMarc+"2", 1, aCores[__nClrSubF], .F.}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

		// Valor Atual do Indicador
		uAux1 := ( nAltura * 1.50 )

		nID     := ::ShpNextID()
		nCamada := 7
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT-uAux1, ::nSize, (::nCenterT/4), ::ConfigLgnd(::GetValue()), cFonteText, 1, aCores[__nClrValF], .T., ::GetValue()}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHAtu})

		// T�tulo localizado abaixo do Sem�foro
		uAux1 := (::nSize * 0.60)

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT+uAux1, ::nSize, (::nCenterT/2), aTextos[__nTxtTitu], cFonteTitl, 1, aCores[__nClrTitF], .F.}
		::SetShape(nCamada, aShape)

		// VALORES dos MARCADORES
		For nMarca := 1 To Len(aMarca)
			nValor := nMarca
			If Len(aMarca) == 3
				Do Case
					Case nValor == 1
						nValor := 1
					Case nValor == 2
						nValor := 3
					Case nValor == 3
						nValor := 5
				EndCase
			EndIf

			/*Converte o valor do marcador para uma string abreviada conforme a legenda
			 exclusico para valores maiores q 1 milh�o.*/
			aAdd(aValChar, ::ConfigLgnd(aValores[nValor],.T.))

			nID     := ::ShpNextID()
			nCamada := 6
			aShape  := {nID, nTipo, aMarca[nMarca][1]+8, aMarca[nMarca][2]-5, nSize3, nAltText, aValChar[nMarca], cFonteMarc+"1", 1, aCores[__nClrMarF], .T., aValores[nValor]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nValor, __nRfsHMar})
		Next nMarca

	ElseIf cStyle == __cSPizza // Pizza

		// Tamanhos
		nAltura  := ( ::nCenterT - ::nTop ) * 0.60
		nCenterT := ( ::nCenterT * 1.10 )

		//--------------------------------------------------
		// 3 - ELLIPSE
		//--------------------------------------------------
		nTipo := __nELLIPSE

		// Sombreamento Inferior
		If aSombras[__nShwInfe]
			uAux1 := (::nSize * 0.55) //Top
			uAux2 := (::nSize * 0.30) //left
			uAux3 := (uAux2 * 2) //Width

			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, ::nCenterL-uAux2, ::nCenterT+uAux1, uAux3, __nShadowH, ::cClrShdw, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		//--------------------------------------------------
		// 4 - ARC
		//--------------------------------------------------
		nTipo := __nARC

		nAngulo := 360

		uAux1 := 0 // �ngulo inicial
		uAux2 := ( nAngulo / ::nBars ) // Incremento de cada ARC

		// Tamanho do ARC
		uAux3 := ( ::nSize / 1.0 )
		For nBarra := 1 To ::nBars
			// Se��o da Pizza (fundo para transpar�ncia)
			nID     := ::ShpNextID()
			nCamada := 3
			aShape  := {nID, nTipo, ::nCenterL-(uAux3/2), nCenterT-(uAux3/2), uAux3, aCores[__nClrCent], aCores[__nClrCent], uAux1, uAux2, 0, aCores[__nClrCont]}
			::SetShape(nCamada, aShape)

			// Se��o da Pizza (se��o sobreposta, a qual realmente utiliza a cor da se��o)
			nID     := ::ShpNextID()
			nCamada := 4
			aShape  := {nID, nTipo, ::nCenterL-(uAux3/2), nCenterT-(uAux3/2), uAux3, aCores[__nClrCent], aCores[__nClrCent], uAux1, uAux2, aOutros[__nOthCont], aCores[__nClrCont]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHSec})
			// Armazena as Posi��es originais do shape
			aAdd(::aAuxiliary, aClone(aShape))

			// Efeito de recheio sobre a fatia da pizza
			aAux := {}
			If ::nBars == 10
				If nBarra == 1
					aAdd(aAux, { 040+(10*(nZoom-1)), -015+(-5*(nZoom-1)) })
				ElseIf nBarra == 2
					aAdd(aAux, { 010+(10*(nZoom-1)), -020+(-10*(nZoom-1)) })
					aAdd(aAux, { 020+(10*(nZoom-1)), -050+(-10*(nZoom-1)) })
					aAdd(aAux, { 025+(10*(nZoom-1)), -030+(-10*(nZoom-1)) })
				ElseIf nBarra == 3
					aAdd(aAux, { 000, -030+(-10*(nZoom-1)) })
					aAdd(aAux, { -010, -060+(-10*(nZoom-1)) })
				ElseIf nBarra == 4
					nSoma := (-5*(nZoom-1))
					aAdd(aAux, { -025+nSoma, -040+(-10*(nZoom-1)) })
				ElseIf nBarra == 5
					aAdd(aAux, { -030+(-10*(nZoom-1)), -008+(-2*(nZoom-1)) })
					aAdd(aAux, { -050+(-15*(nZoom-1)), -010+(-4*(nZoom-1)) })
					aAdd(aAux, { -055+(-15*(nZoom-1)), -025+(-8*(nZoom-1)) })
				ElseIf nBarra == 6
					aAdd(aAux, { -030+(-10*(nZoom-1)), 010+(5*(nZoom-1)) })
					aAdd(aAux, { -050+(-15*(nZoom-1)), 005+(5*(nZoom-1)) })
				ElseIf nBarra == 7
					aAdd(aAux, { -025+(-5*(nZoom-1)), 045+(10*(nZoom-1)) })
					aAdd(aAux, { -030+(-8*(nZoom-1)), 030+(7*(nZoom-1)) })
				ElseIf nBarra == 8
					aAdd(aAux, { -002+(-0*(nZoom-1)), 025+(10*(nZoom-1)) })
					aAdd(aAux, { -008+(-2*(nZoom-1)), 050+(15*(nZoom-1)) })
					aAdd(aAux, { 005+(2*(nZoom-1)), 045+(15*(nZoom-1)) })
				ElseIf nBarra == 9
					aAdd(aAux, { 025+(7*(nZoom-1)), 030+(10*(nZoom-1)) })
				ElseIf nBarra == 10
					aAdd(aAux, { 025+(10*(nZoom-1)), 005+(2*(nZoom-1)) })
					aAdd(aAux, { 045+(15*(nZoom-1)), 020+(4*(nZoom-1)) })
				EndIf
			EndIf
			For nX := 1 To Len(aAux)
				nID     := ::ShpNextID()
				nCamada := 5
				aShape  := {nID, nTipo, ::nCenterL+aAux[nX][1], nCenterT+aAux[nX][2], If(nZoom < 4,5,6), aCores[__nClrPntS], aCores[__nClrPntS], 0, 360, 0, aCores[__nClrCont]}
					aShape[6] += If(aSombras[__nShwAuxi], "100", "0")
					aShape[7] += If(aSombras[__nShwAuxi], "100", "0")
				::SetShape(nCamada, aShape)
				aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nBarra, __nRfsHCom})
				// Armazena as Posi��es originais do shape
				aAdd(::aAuxiliary, aClone(aShape))
			Next nX

			uAux1 := ( uAux1 + uAux2 )
		Next nBarra
		// Sombreamento Central
		If aSombras[__nShwCent]
			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, ::nCenterL-(uAux3/2)-2, nCenterT-(uAux3/2)-2, uAux3+6, ::cClrShdw, ::cClrShdw, 0, 360, 0, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		//--------------------------------------------------
		// 7 - TEXT
		//--------------------------------------------------
		nTipo := __nTEXT

		// Subt�tulo localizado a direita da Pizza
		uAux1 := ( nAltura * 1.20 )

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT-uAux1, ::nSize, (::nCenterT/4), aTextos[__nTxtSubt], cFonteMarc+"2", 1, aCores[__nClrSubF], .F.}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

		// Valor Atual do Indicador
		uAux1 := ( nAltura * 1.50 )

		nID     := ::ShpNextID()
		nCamada := 7
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT-uAux1, ::nSize, (::nCenterT/4), ::ConfigLgnd(::GetValue()), cFonteText, 1, aCores[__nClrValF], .T., ::GetValue()}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHAtu})

		// T�tulo localizado abaixo da Pizza
		uAux1 := (::nSize * 0.60)

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT+uAux1, ::nSize, (::nCenterT/2), aTextos[__nTxtTitu], cFonteTitl, 1, aCores[__nClrTitF], .F.}
		::SetShape(nCamada, aShape)

		// Tamanho do ARC
		uAux3 := ( ::nSize / 1.5 )
		// VALORES dos MARCADORES
		aMarca := Array(5) // definido por: Left ; Top
		aMarca[1] := {::nCenterL+(uAux3/2)+10        , nCenterT-20}
		aMarca[2] := {::nCenterL-nSize3+5            , nCenterT-(uAux3/2)-20}
		aMarca[3] := {::nCenterL-(uAux3/2)-10-nSize3 , nCenterT}
		aMarca[4] := {::nCenterL-nSize3+5            , nCenterT+(uAux3/2)+10}
		aMarca[5] := {::nCenterL+(uAux3/2)+10        , nCenterT+5}

		uAux1 := ""
		For nMarca := 1 To Len(aMarca)
			nValor := nMarca

			If nMarca == 1 .Or. nMarca == 5
				uAux1 := "1"
			ElseIf nMarca == 2 .Or. nMarca == 4
				uAux1 := "2"
			Else
				uAux1 := "2"
			EndIf

			nID     := ::ShpNextID()
			nCamada := 6

			/*Converte o valor do marcador para uma string abreviada conforme a legenda
			 exclusico para valores maiores q 1 milh�o.*/
			aAdd(aValChar, ::ConfigLgnd(aValores[nValor],.T.))

			aShape  := {nID, nTipo, aMarca[nMarca][1], aMarca[nMarca][2], nSize3, nAltText, aValChar[nMarca], cFonteMarc+uAux1, 1, aCores[__nClrMarF], .T., aValores[nValor]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nValor, __nRfsHMar})
		Next nMarca

	ElseIf cStyle == __cSTermom // Term�metro

		// Tamanhos
		nAltura  := ( ::nCenterT - ::nTop ) * 0.70
		nLargura := ( ::nCenterL - ::nLeft ) * 0.100

		//--------------------------------------------------
		// 2 - RECTROUNDED
		//--------------------------------------------------
		nTipo := __nRECTROUNDED

		// Barra do Term�metro
		nID     := ::ShpNextID()
		nCamada := 4
		aShape  := {nID, nTipo, ::nCenterL-nLargura, ::nCenterT-nAltura, (nLargura*2), (nAltura*2), aCores[__nClrCent], aOutros[__nOthCont], aCores[__nClrCont]}
		::SetShape(nCamada, aShape)
		aOldShape := aClone(aShape)

		// Sombreamento Central
		If aSombras[__nShwCent]
			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, aOldShape[3]-002, aOldShape[4]-002, aOldShape[5]+004, aOldShape[6]+004, ::cClrShdw, aOutros[__nOthCont], ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		// Barra de dentro do Term�metro (CONTE�DO de anima��o)
		nID     := ::ShpNextID()
		nCamada := 6
		aShape  := {nID, nTipo, ::nCenterL-(nLargura*0.60), ::nCenterT-(nAltura*0.90), ((nLargura*0.60)*2), ((nAltura*0.90)*2), aCores[__nClrEsqu], 0, aCores[__nClrEsqu]}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, {aShape[4],aShape[6]}, __nRfsHSec})
		aOldShape := aClone(aShape)
		// Barra de contorno de dentro do Term�metro
		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, aOldShape[3]-001, aOldShape[4]-001, aOldShape[5]+002, aOldShape[6]+002, aCores[__nClrMarB], aOutros[__nOthCont], aCores[__nClrMarB]}
		::SetShape(nCamada, aShape)
		aOldShape := aClone(aShape)

		// MARCA��O
		aAdd(aMarca, {::nCenterL-nLargura-(005*nZoom), aOldShape[4]+aOldShape[6]}) // Left, Top
		If nZoom >= 4
			aAdd(aMarca, {aMarca[1][1], aOldShape[4]+(aOldShape[6]*0.75)}) // Left, Top
		EndIf
		aAdd(aMarca, {aMarca[1][1], aOldShape[4]+(aOldShape[6]*0.50)}) // Left, Top
		If nZoom >= 4
			aAdd(aMarca, {aMarca[1][1], aOldShape[4]+(aOldShape[6]*0.25)}) // Left, Top
		EndIf
		aAdd(aMarca, {aMarca[1][1], aOldShape[4]}) // Left, Top

		//--------------------------------------------------
		// 3 - ELLIPSE
		//--------------------------------------------------
		nTipo := __nELLIPSE

		// Sombreamento Inferior
		If aSombras[__nShwInfe]
			uAux1 := (::nSize * 0.55) //Top
			uAux2 := (::nSize * 0.30) //left
			uAux3 := (uAux2 * 2) //Width

			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, ::nCenterL-uAux2, ::nCenterT+uAux1, uAux3, __nShadowH, ::cClrShdw, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		//--------------------------------------------------
		// 4 - ARC
		//--------------------------------------------------
		nTipo := __nARC

		nAngulo := 360

		uAux1 := nLargura * 4.00 // Tamanho do ARCO
		uAux2 := ( uAux1 * 0.80 ) // Tamanaho do ARCO de dentro

		// ARCO da base do Term�metro
		nID     := ::ShpNextID()
		nCamada := 4
		aShape  := {nID, nTipo, ::nCenterL-(uAux1/2), (::nCenterT+nAltura)-(uAux1/2), uAux1, aCores[__nClrCent], aCores[__nClrCent], 0, nAngulo, 0, aCores[__nClrCont]}
		::SetShape(nCamada, aShape)
		aOldShape := aClone(aShape)
		// ARCO de contorno da base do Term�metro
		nID     := ::ShpNextID()
		nCamada := 3
		aShape  := {nID, nTipo, aOldShape[3]-001, aOldShape[4]-001, aOldShape[5]+002, aCores[__nClrCont], aCores[__nClrCont], 0, nAngulo, 0, aCores[__nClrCont]}
		::SetShape(nCamada, aShape)

		// Sombreamento Central
		If aSombras[__nShwCent]
			nID     := ::ShpNextID()
			nCamada := 2
			aShape  := {nID, nTipo, aOldShape[3]-003, aOldShape[4]-003, aOldShape[5]+006, ::cClrShdw, ::cClrShdw, 0, nAngulo, 0, ::cClrShdw}
			::SetShape(nCamada, aShape)
		EndIf

		// ARCO de dentro da base do Term�metro (CONTE�DO de anima��o)
		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nCenterL-(uAux2/2), (::nCenterT+nAltura)-(uAux2/2), uAux2, aCores[__nClrEsqu], aCores[__nClrEsqu], 0, nAngulo, 0, aCores[__nClrEsqu]}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHSec})
		aOldShape := aClone(aShape)
		// ARCO de contorno de dentro da base do Term�metro
		nID     := ::ShpNextID()
		nCamada := 4
		aShape  := {nID, nTipo, aOldShape[3]-001, aOldShape[4]-001, aOldShape[5]+002, aCores[__nClrMarB], aCores[__nClrMarB], 0, nAngulo, 0, aCores[__nClrMarB]}
		::SetShape(nCamada, aShape)

		//--------------------------------------------------
		// 7 - TEXT
		//--------------------------------------------------
		nTipo := __nTEXT

		// Subt�tulo localizado a direita da Pizza
		uAux1 := ( nAltura * 1.20 )

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT-uAux1, ::nSize, (::nCenterT/4), aTextos[__nTxtSubt], cFonteMarc+"2", 1, aCores[__nClrSubF], .F.}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHCom})

		// Valor Atual do Indicador
		uAux1 := ( nAltura * 1.50 )

		nID     := ::ShpNextID()
		nCamada := 7
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT-uAux1, ::nSize, (::nCenterT/4), ::ConfigLgnd(::GetValue()), cFonteText, 1, aCores[__nClrValF], .T., ::GetValue()}
		::SetShape(nCamada, aShape)
		aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, 0, __nRfsHAtu})

		// T�tulo localizado abaixo da Pizza
		uAux1 := (::nSize * 0.60)

		nID     := ::ShpNextID()
		nCamada := 5
		aShape  := {nID, nTipo, ::nLeft, ::nCenterT+uAux1, ::nSize, (::nCenterT/2), aTextos[__nTxtTitu], cFonteTitl, 1, aCores[__nClrTitF], .F.}
		::SetShape(nCamada, aShape)

		// VALORES dos MARCADORES
		For nMarca := 1 To Len(aMarca)
			nValor := nMarca
			If Len(aMarca) == 3
				Do Case
					Case nValor == 1
						nValor := 1
					Case nValor == 2
						nValor := 3
					Case nValor == 3
						nValor := 5
				EndCase
			EndIf

			/*Converte o valor do marcador para uma string abreviada conforme a legenda
			 exclusico para valores maiores q 1 milh�o.*/
			aAdd(aValChar, ::ConfigLgnd(aValores[nValor],.T.))

			nID     := ::ShpNextID()
			nCamada := 6
			aShape  := {nID, nTipo, (aMarca[nMarca][1]-nSize3)-8, aMarca[nMarca][2]-5, nSize3, nAltText, aValChar[nMarca], cFonteMarc+"2", 1, aCores[__nClrMarF], .T., aValores[nValor]}
			::SetShape(nCamada, aShape)
			aAdd(::aRefresh, {aShape[1], aShape[2], nCamada, nValor, __nRfsHMar})
		Next nMarca

	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Indicator
M�todo que cria o Indicador a partir dos shapes.

@author Wagner Sobral de Lacerda
@since 06/10/2011

@param lOnlyAtu
	Monta apenas os Shapes relacionados ao array de atualiza��o do Indicador * Opcional
	Default: .F.

@return .T. Indicador criado; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method Indicator(lOnlyAtu) Class TNGIndicator

	Local cShape := ""

	Local nCamada  := 0
	Local nTipo    := 0
	Local nRefresh := 0
	Local nX       := 0

	Local uAuxiliar := Nil

	Local cStyle := ::GetStyle()
	Local nZoom  := ::GetZoom()

	// Defaults
	Default lOnlyAtu := .F.

	// Valida os Shapes
	If !::lBackgroun
		// Se n�o existir, cria
		::Initialize()
		::CreateShapes()
	EndIf

	// Deleta os Shapes que ser�o atualizados
	If lOnlyAtu
		For nRefresh := 1 To Len(::aRefresh)
			::oTPPanel:DeleteItem(::aRefresh[nRefresh][__nRfsID])
		Next nRefresh
	EndIf

	//------------------------------
	// Cria os Shapes em tela
	//------------------------------
	For nCamada := 1 To ::nLayers

		For nTipo := 1 To Len(::aShapes)

			For nX := 1 To Len(::aShapes[nTipo][nCamada])

				// N�o recria o Background
				If ::lReseting .And. ::aShapes[nTipo][nCamada][nX][__nID] == ::nIDBack
					Loop
				EndIf

				// Monta apenas os Shapes atualiz�veis
				If lOnlyAtu
					If aScan(::aRefresh, {|x| x[__nRfsID] == ::aShapes[nTipo][nCamada][nX][__nID] }) == 0
						Loop
					EndIf
				EndIf

				cShape := "ID=" + cValToChar(::aShapes[nTipo][nCamada][nX][__nID]) + ";"
				cShape += "Type=" + cValToChar(::aShapes[nTipo][nCamada][nX][__nType]) + ";"

				Do Case
					Case ::aShapes[nTipo][nCamada][nX][__nType] == __nRECT
						//--------------------------------------------------
						// RECT
						//--------------------------------------------------
						cShape += "Left=" + cValToChar(::aShapes[nTipo][nCamada][nX][3]) + ";"
						cShape += "Top=" + cValToChar(::aShapes[nTipo][nCamada][nX][4]) + ";"
						cShape += "Width=" + cValToChar(::aShapes[nTipo][nCamada][nX][5]) + ";"
						cShape += "Height=" + cValToChar(::aShapes[nTipo][nCamada][nX][6]) + ";"

						cShape += "Gradient=1,0,0,0,0,0.0," + ::aShapes[nTipo][nCamada][nX][7] + ";"

						cShape += "Pen-Width=" + cValToChar(::aShapes[nTipo][nCamada][nX][8]) + ";"
						cShape += "Pen-Color=" + ::aShapes[nTipo][nCamada][nX][9] + ";"
					Case ::aShapes[nTipo][nCamada][nX][__nType] == __nRECTROUNDED
						//--------------------------------------------------
						// RECTROUNDED
						//--------------------------------------------------
						cShape += "Left=" + cValToChar(::aShapes[nTipo][nCamada][nX][3]) + ";"
						cShape += "Top=" + cValToChar(::aShapes[nTipo][nCamada][nX][4]) + ";"
						cShape += "Width=" + cValToChar(::aShapes[nTipo][nCamada][nX][5]) + ";"
						cShape += "Height=" + cValToChar(::aShapes[nTipo][nCamada][nX][6]) + ";"

						cShape += "Gradient=1,0,0,0,0,0.0," + ::aShapes[nTipo][nCamada][nX][7] + ";"

						cShape += "Pen-Width=" + cValToChar(::aShapes[nTipo][nCamada][nX][8]) + ";"
						cShape += "Pen-Color=" + ::aShapes[nTipo][nCamada][nX][9] + ";"
						cShape += "Is-Blinker=1;"
					Case ::aShapes[nTipo][nCamada][nX][__nType] == __nELLIPSE
						//--------------------------------------------------
						// ELLIPSE
						//--------------------------------------------------
						cShape += "Left=" + cValToChar(::aShapes[nTipo][nCamada][nX][3]) + ";"
						cShape += "Top=" + cValToChar(::aShapes[nTipo][nCamada][nX][4]) + ";"
						cShape += "Width=" + cValToChar(::aShapes[nTipo][nCamada][nX][5]) + ";"
						cShape += "Height=" + cValToChar(::aShapes[nTipo][nCamada][nX][6]) + ";"

						cShape += "Gradient=1,0,0,0,0,0.0," + ::aShapes[nTipo][nCamada][nX][7] + ";"

						cShape += "Pen-Width=1;"
						cShape += "Pen-Color=" + ::aShapes[nTipo][nCamada][nX][8] + ";"
					Case ::aShapes[nTipo][nCamada][nX][__nType] == __nARC
						//--------------------------------------------------
						// ARC
						//--------------------------------------------------
						cShape += "Left=" + cValToChar(::aShapes[nTipo][nCamada][nX][3]) + ";"
						cShape += "Top=" + cValToChar(::aShapes[nTipo][nCamada][nX][4]) + ";"
						cShape += "Width=" + cValToChar(::aShapes[nTipo][nCamada][nX][5]) + ";"
						cShape += "Height=" + cValToChar(::aShapes[nTipo][nCamada][nX][5]) + ";"

						uAuxiliar := cValToChar( (::aShapes[nTipo][nCamada][nX][5] / 2) )
						cShape += "Gradient=2," + uAuxiliar + "," + uAuxiliar + "," + uAuxiliar + "," + uAuxiliar + ",0.0," + ::aShapes[nTipo][nCamada][nX][6] + ",0.98," + ::aShapes[nTipo][nCamada][nX][6] + ",1.0," + ::aShapes[nTipo][nCamada][nX][7] + ";"

						cShape += "Start-Angle=" + cValToChar(::aShapes[nTipo][nCamada][nX][8]) + ";"
						cShape += "Sweep-Length=" + cValToChar(::aShapes[nTipo][nCamada][nX][9]) + ";"
						cShape += "Pen-Width=" + cValToChar(::aShapes[nTipo][nCamada][nX][10]) + ";"
						cShape += "Pen-Color=" + ::aShapes[nTipo][nCamada][nX][11] + ";"
					Case ::aShapes[nTipo][nCamada][nX][__nType] == __nPOLYGON
						//--------------------------------------------------
						// POLYGON
						//--------------------------------------------------
						cShape += "Polygon="
						cShape += cValToChar(::aShapes[nTipo][nCamada][nX][3]) + ":" + cValToChar(::aShapes[nTipo][nCamada][nX][4]) + "," // Left:Top
						cShape += cValToChar(::aShapes[nTipo][nCamada][nX][5]) + ":" + cValToChar(::aShapes[nTipo][nCamada][nX][6]) + "," // Left:Top
						cShape += cValToChar(::aShapes[nTipo][nCamada][nX][7]) + ":" + cValToChar(::aShapes[nTipo][nCamada][nX][8]) + ";" // Left:Top

						cShape += "Gradient=1,0,0,0,0,0.0," + ::aShapes[nTipo][nCamada][nX][9] + ";"

						cShape += "Pen-Width=" + cValToChar(::aShapes[nTipo][nCamada][nX][10]) + ";"
						cShape += "Pen-Color=" + ::aShapes[nTipo][nCamada][nX][11] + ";"
					Case ::aShapes[nTipo][nCamada][nX][__nType] == __nLINE
						//--------------------------------------------------
						// LINE
						//--------------------------------------------------
						cShape += "From-Left=" + cValToChar(::aShapes[nTipo][nCamada][nX][3]) + ";"
						cShape += "From-Top=" + cValToChar(::aShapes[nTipo][nCamada][nX][4]) + ";"
						cShape += "To-Left=" + cValToChar(::aShapes[nTipo][nCamada][nX][5]) + ";"
						cShape += "To-Top=" + cValToChar(::aShapes[nTipo][nCamada][nX][6]) + ";"

						cShape += "Pen-Width=" + cValToChar(::aShapes[nTipo][nCamada][nX][7]) + ";"
						cShape += "Pen-Color=" + ::aShapes[nTipo][nCamada][nX][8] + ";"
						cShape += "Large=" + cValToChar(::aShapes[nTipo][nCamada][nX][7]) + ";"
					Case ::aShapes[nTipo][nCamada][nX][__nType] == __nTEXT
						//--------------------------------------------------
						// TEXT
						//--------------------------------------------------
						cShape += "Left=" + cValToChar(::aShapes[nTipo][nCamada][nX][3]) + ";"
						cShape += "Top=" + cValToChar(::aShapes[nTipo][nCamada][nX][4]) + ";"
						cShape += "Width=" + cValToChar(::aShapes[nTipo][nCamada][nX][5]) + ";"
						cShape += "Height=" + cValToChar(::aShapes[nTipo][nCamada][nX][6]) + ";"

						If nCamada == 7
							uAuxiliar := ::ConfigLgnd(::GetValue())
						Else
							uAuxiliar := ::aShapes[nTipo][nCamada][nX][7]
						EndIf
						//Verifica se o shape est� pronto para utiliza��o e se valor contido � num�rico.
						If ::aShapes[nTipo][nCamada][nX][11] .And. ValType(uAuxiliar) == "N"
							// Formata o Valor para apresentar em tela
							uAuxiliar := ::ConfigVals(uAuxiliar, .T.)
							// Para o Zoom 1, h� um limite de caracteres apresentados em tela
							If nZoom == 1
								If cStyle $ (__cSGrBarr + "/" + __cSPirami) .And. (Len(uAuxiliar)*8) > ::aShapes[nTipo][nCamada][nX][5] // Calcula um tamanho para apresenta��o tem tela, o qual n�o pode ser maior que a largura
									uAuxiliar := SubStr(uAuxiliar, 1, 7) + "~" // Faz a quebra o mais perto do m�ximo poss�vel
								EndIf
							EndIf
						EndIf
						cShape += "Text=" + uAuxiliar + ";"
						cShape += "Font=" + cValToChar(::aShapes[nTipo][nCamada][nX][8]) + ";"
						cShape += "Pen-Width=" + cValToChar(::aShapes[nTipo][nCamada][nX][9]) + ";"
						cShape += "Pen-Color=" + ::aShapes[nTipo][nCamada][nX][10] + ";"
					Case ::aShapes[nTipo][nCamada][nX][__nType] == __nIMAGE
						//--------------------------------------------------
						// IMAGE
						//--------------------------------------------------
						cShape += ""
					OtherWise
						Loop
				EndCase

				// Permite Container apenas no Shape Background (isto permite o clique da esquerda no objeto)
				uAuxiliar := If(::aShapes[nTipo][nCamada][nX][__nID] == ::GetBackgrd(),"1","0")
				cShape += "Can-Move=0;Can-Deform=0;Can-Mark=0;Is-Container=" + uAuxiliar + ";"
				::oTPPanel:AddShape(cShape)

			Next nX

		Next nTipo

	Next nCamada

	::lIndicator := .T.

	// Seta Dica (tooltip)
	::SetTooltip()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Animate
M�todo que executa uma Anima��o no Indicador.

@author Wagner Sobral de Lacerda
@since 24/10/2011

@param nFromValue
	A partir de qual Valor * Obrigat�rio
@param nToValue
	At� qual valor * Obrigat�rio
@param lReverse
	Anima��o Reversa (anima o Indicador, zerando-o primeiro -> sempre voltar� todo � esquerda antes de animar) * Opcional

@return .T. Indicador criado; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method Animate(nFromValue, nToValue, lReverse) Class TNGIndicator

	// Dados do Indicador
	Local cStyle := ::GetStyle()

	// Vari�veis para realizar a anima��o
	Local nInterval := 0 //em Milisegundos
	Local lPositivo := .T. //Indica se a diferenca entre os valores e' positiva ou negativa (.T. - positivo - incremento ; .F. - negativo - decremento)

	Local nValAtu := 0
	Local nRazao  := 0
	Local nAdd    := 0, nQtdeAdd := 10

	// Vari�veis para controlar o tempo da anima��o
	Local cTimeInit := ""
	Local cTimeElap := ""

	// Defaults
	Default nFromValue := ::GetValue()
	Default nToValue   := ::GetValue()
	Default lReverse   := .F.

	//Converte o Valor 'De' para numerico
	nFromValue := ::ConfigVals(nFromValue)
	//Converte o Valor 'Ate' para numerico
	nToValue := ::ConfigVals(nToValue)

	//Executa a Animacao Reversa
	If lReverse
		::Animate(::GetValue(),::aValues[1])
	EndIf

	//Valida se sao iguais (se forem, nao ha' porque animar)
	If nFromValue == nToValue
		Return .F.
	EndIf

	//Define se sera' Incremento ou Drecremento do Valor Atual
	//Lembrando que apenas havera um delay na animacao em caso de Incremento. No caso de Decremento,
	//o Indicador tentara voltar o ais rapido possivel ao valor inicial passado no parametro
	lPositivo := If(nToValue > nFromValue, .T., .F.)

	//Define o Valor atual para atualizar
	nValAtu := nFromValue
	If lPositivo
		If cStyle == __cSVeComu
			nQtdeAdd := 130
		ElseIf cStyle $ (__cSVeSecc + "/" + __cSGrBarr)
			nQtdeAdd := 100
		ElseIf cStyle $ (__cSPirami + "/" + __cSRadar + "/" + __cSTeia)
			nQtdeAdd := 20
		ElseIf cStyle == __cSSlider
			nQtdeAdd := 70
		ElseIf cStyle == __cSCilind
			nQtdeAdd := If(::nZoom < 3, 50, 20)
		ElseIf cStyle == __cSSemafo
			nQtdeAdd := 120
		ElseIf cStyle == __cSPizza
			nQtdeAdd := If(::nZoom < 3, 30, 10)
		ElseIf cStyle == __cSTermom
			nQtdeAdd := 150
		EndIf
		nAdd := ( (nToValue - nFromValue) / nQtdeAdd )
	Else
		If cStyle == __cSVeComu
			nQtdeAdd := 80
		ElseIf cStyle $ (__cSVeSecc + "/" + __cSGrBarr)
			nQtdeAdd := 40
		ElseIf cStyle $ (__cSPirami + "/" + __cSRadar + "/" + __cSTeia)
			nQtdeAdd := 10
		ElseIf cStyle == __cSSlider
			nQtdeAdd := 35
		ElseIf cStyle == __cSCilind
			nQtdeAdd := If(::nZoom < 3, 20, 10)
		ElseIf cStyle == __cSSemafo
			nQtdeAdd := 100
		ElseIf cStyle == __cSPizza
			nQtdeAdd := If(::nZoom < 3, 10, 5)
		ElseIf cStyle == __cSTermom
			nQtdeAdd := 50
		EndIf
		nAdd := ( (nFromValue - nToValue) / nQtdeAdd )
	EndIf

	// Hora de in�cio da anima��o
	cTimeInit := Time()
	// Executa a anima��o
	While If(lPositivo,nValAtu <= nToValue,nValAtu >= nToValue)
		// Seta o valor
		::SetValue(nValAtu)

		// Processa as Mensagens do Application Server
		ProcessMessages()

		// Define a Raz�o
		If lPositivo
			nRazao := ( nToValue / nValAtu )
		Else
			nRazao := ( nFromValue / nValAtu )
		EndIf

		// Define Intervalo
		If nRazao > 1.8 //Razao igual a 2 e' quanto esta' na metade do valor 'nToValue'
			nInterval := 1
		ElseIf nRazao > 1.6
			nInterval := 5
		ElseIf nRazao > 1.2
			nInterval := 10
		Else
			nInterval := 20
		EndIf

		// Incrementa/Decrementa o valor
		If lPositivo
			Sleep(nInterval)
			nValAtu += nAdd
		Else
			nValAtu -= nAdd
		EndIf

		// Verifica o tempo da anima��o
		cTimeElap := ElapTime(cTimeInit, Time())
		If cTimeElap > "00:00:03" // Se demorar mais do que 3 segundos, aborta
			Exit
		EndIf
	End
	// Habilita atualiza��es em tela
	::oDlgOwner:SetUpdatesEnabled(.T.)

	//Se mesmo apos terminar a animacao o valor nao for o desejado, atualiza novamente
	If nValAtu <> nToValue
		::SetValue(nToValue)
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## M�TODOS: CONFIGURA��O DO INDICADOR                                                     ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} Config
M�todo que abre a Tela de Configura��o do Indicador.

@author Wagner Sobral de Lacerda
@since 14/02/2012

@return .T. Configura��o confirmada; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method Config() Class TNGIndicator

	// Vari�veis do Dialog
	Local cDlgConfig := OemToAnsi(STR0025) //"Painel de Configura��o"
	Local lDlgConfig := .F.
	Local oPnlConfig := Nil

	Local oBlackPnl := Nil

	// Vari�veis de Bloco de C�digo
	Local bBeforCfg := ::GetCodeBlock(__nBBefCfg)
	Local bAfterCfg := ::GetCodeBlock(__nBAftCfg)

	// Vari�veis do Painel Esquerdo
	Local oPnlCfgLef := Nil
	Local oCgfToolBx := Nil

	// Vari�veis do Painel Direito
	Local oPnlCfgRig := Nil, oPnlCfgPrw := Nil

	// Vari�veis do Painel de Baixo
	Local oPnlCfgBot := Nil
	Local oBtnTmp := Nil

	// Dialog do Painel de Configura��o
	Private oDlgConfig := Nil

	// Vari�veis de Tela/Painel
	Private nTamPanel := 230
	Private nLeftIni  := 005
	Private nLeftEnd  := (nTamPanel - 005)
	Private nTopIni   := 030

	// Vari�veis da configura��o 'Indicador'
	Private oCfgPnlInd := Nil
	Private aIndModelo, nIndModelo, oIndModelo
	Private aIndTipCon, cIndTipCon, oIndTipCon
	Private cIndTitulo, oIndTitulo
	Private cIndSubtit, oIndSubtit
	Private cIndLegen1, oIndLegen1
	Private cIndLegen2, oIndLegen2
	Private cIndLegen3, oIndLegen3

	// Vari�veis da configura��o 'Valores'
	Private oCfgPnlVls := Nil
	Private nVlsMaxVls
	Private nVlsVal01 , nVlsVal02 , nVlsVal03, nVlsVal04, nVlsVal05, nVlsVal06, nVlsVal07
	Private oVlsVal01 , oVlsVal02 , oVlsVal03, oVlsVal04, oVlsVal05, oVlsVal06, oVlsVal07

	// Vari�veis da configura��o 'Se��es'
	Private oCfgPnlSec := Nil
	Private aSecSecao , nSecSecao , oSecSecao
	Private oSecPanel
	Private oSecValor , oSecPorce
	Private nSecValTmp, nSecValMin, nSecValMax
	Private nSecPorTmp, nSecPorMin, nSecPorMax

	// Vari�veis da configura��o 'Cores'
	Private oCfgPnlClr := Nil
	Private aClrArea  , oClrArea
	Private aClrArea01, nClrArea01, oClrArea01
	Private aClrArea02, nClrArea02, oClrArea02
	Private aClrArea03, nClrArea03, oClrArea03
	Private aClrArea04, nClrArea04, oClrArea04
	Private aClrArea05, nClrArea05, oClrArea05
	Private aClrAtuali
	Private lClrSomCen, lClrSomInf, lClrSomAux
	Private oClrCfgClr := Nil

	// Objeto do Indicador (Preview)
	Private oCfgIndPrw := Nil

	//--- Carrega o estado inicial das vari�veis
	fLoadVars(Self)

	// Painel Preto de Background (Transpar�ncia)
	fBlackPanel(@oBlackPnl, .T.)

	// Executa Bloco de C�digo BEFORE CONFIG
	If ValType(bBeforCfg) == "B"
		Eval(bBeforCfg)
	EndIf

	//--------------------------------------------------
	// Tela
	//--------------------------------------------------
	lDlgConfig := .F.
	DEFINE MSDIALOG oDlgConfig TITLE cDlgConfig FROM 0,0 TO 580,780 OF ::oDlgOwner PIXEL

		// N�o permite fechar a tela com a tecla ESC, para o usu�rio n�o perder sem querer suas altera��es
		oDlgConfig:lEscClose := .F.

		//--- Painel Geral do Dialog
		oPnlConfig := TPanel():New(01, 01, , oDlgConfig, , , , CLR_BLACK, CLR_WHITE, 100, 100)
		oPnlConfig:Align := CONTROL_ALIGN_ALLCLIENT

			//--- Painel Esquerdo
			oPnlCfgLef := TPanel():New(01, 01, , oPnlConfig, , , , CLR_BLACK, CLR_WHITE, nTamPanel, 100)
			oPnlCfgLef:Align := CONTROL_ALIGN_LEFT

				//--------------------------------------------------
				// Configura��o do Indicador
				//--------------------------------------------------
				oCfgPnlInd := TPanel():New(01, 01, , oPnlConfig, , , , CLR_BLACK, CLR_WHITE, 100, 100)
				oCfgPnlInd:Align := CONTROL_ALIGN_ALLCLIENT

					fConfigInd(@oCfgPnlInd, Self)

				//--------------------------------------------------
				// Configura��o dos Valores
				//--------------------------------------------------
				oCfgPnlVls := TPanel():New(01, 01, , oPnlConfig, , , , CLR_BLACK, CLR_WHITE, 100, 100)
				oCfgPnlVls:Align := CONTROL_ALIGN_ALLCLIENT

					fConfigVls(@oCfgPnlVls, Self)

				//--------------------------------------------------
				// Configura��o das Se��es
				//--------------------------------------------------
				oCfgPnlSec := TPanel():New(01, 01, , oPnlConfig, , , , CLR_BLACK, CLR_WHITE, 100, 100)
				oCfgPnlSec:Align := CONTROL_ALIGN_ALLCLIENT

					fConfigSec(@oCfgPnlSec, Self)

				//--------------------------------------------------
				// Configura��o das Cores
				//--------------------------------------------------
				oCfgPnlClr := TPanel():New(01, 01, , oPnlConfig, , , , CLR_BLACK, CLR_WHITE, 100, 100)
				oCfgPnlClr:Align := CONTROL_ALIGN_ALLCLIENT

					fConfigClr(@oCfgPnlClr, Self)

				//--------------------------------------------------
				// ToolBox contendo os pain�s das configura��es
				//--------------------------------------------------
				oCgfToolBx := TToolBox():New(01, 01, oPnlCfgLef, 100, 100)

				oCgfToolBx:AddGroup(oCfgPnlInd, STR0026, ) //"Indicador"
				oCgfToolBx:AddGroup(oCfgPnlVls, STR0027, ) //"Valores dos Marcadores"
				oCgfToolBx:AddGroup(oCfgPnlSec, STR0028, ) //"Se��es"
				oCgfToolBx:AddGroup(oCfgPnlClr, STR0029, ) //"Cores dos Componentes"

				oCgfToolBx:Align := CONTROL_ALIGN_ALLCLIENT

				oCgfToolBx:SetCurrentGroup(oCfgPnlInd)

			//--- Painel Direito
			oPnlCfgRig := TPanel():New(01, 01, , oPnlConfig, , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlCfgRig:Align := CONTROL_ALIGN_ALLCLIENT

				//--- Painel da Pr�-Visualiza��o do Indicador Gr�fico (Preview)
				oPnlCfgPrw := TPanel():New(01, 01, , oPnlCfgRig, , , , CLR_BLACK, CLR_WHITE, 100, 100)
				oPnlCfgPrw:Align := CONTROL_ALIGN_ALLCLIENT

					// Preview
					oCfgIndPrw := TNGIndicator():New(018, 018, 1, oPnlCfgPrw, 1, 1, CLR_WHITE, ::GetContent(), ::GetStyle(), .F., .T.)
					oCfgIndPrw:Preview()
					::CopyTo(@oCfgIndPrw) // Copia os dados do Indicador para o Preview
					oCfgIndPrw:SetValue( aTail( ::GetVals() ) ) // Seta o valor final
					oCfgIndPrw:CanFooter(.F.) // Desabilita completamento o rodap�

				//--- Painel do Rodap�
				oPnlCfgBot := TPanel():New(01, 01, , oPnlCfgRig, , , , CLR_BLACK, CLR_WHITE, 100, 016)
				oPnlCfgBot:Align := CONTROL_ALIGN_BOTTOM

					// Bot�o para testar o Indicador (Animar)
					oBtnTmp := TButton():New(002, 010, STR0030, oPnlCfgBot, {|| oCfgIndPrw:Test() },; //"Testar"
												030, 012, , , .F., .T., .F., , .F., , , .F.)
					oBtnTmp:lCanGotFocus := .T.

					// Confirmar
					oBtnTmp := TButton():New(002, 085, STR0031, oPnlCfgBot, {|| lDlgConfig := .T., If(fCfgConfir(Self), , lDlgConfig := .F.) },; //"Confirmar"
							  				030, 012, , , .F., .T., .F., , .F., , , .F.)
					oBtnTmp:lCanGotFocus := .T.

					// Cancelar
					oBtnTmp := TButton():New(002, 125, STR0032, oPnlCfgBot, {|| lDlgConfig := .F., fCfgCancel() },; //"Cancelar"
											030, 012, , , .F., .T., .F., , .F., , , .F.)
					oBtnTmp:lCanGotFocus := .T.

		// Inicializa o estado inicial da tela de configura��o
		fLoadCfg()

	ACTIVATE MSDIALOG oDlgConfig CENTER

	// Ao final da Configura��o, seta o valor do Indicador para o M�ximo
	::SetValue( aTail(::GetVals()) )

	// Executa Bloco de C�digo AFTER CONFIG
	If ValType(bAfterCfg) == "B"
		Eval(bAfterCfg, lDlgConfig)
	EndIf

	// Esconde Painel Preto
	fBlackPanel(@oBlackPnl, .F.)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ConfigVals
M�todo que define as Configura��es de Valores do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@param uValue
	Valor OU Array de Valores para transformar * Obrigat�rio
@param lWithPict
	Indica se deve formatar os valores * Opcional
	Default: .F.

@return .T. Configura��o confirmada; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method ConfigVals(uValue, lWithPict) Class TNGIndicator

	Local aValues  := {}
	Local cTipoVal := ""
	Local nValue   := 0
	Local nAt      := 0

	Local cContent := ::GetContent()
	Local cPicture := ::GetPicture()

	// Defaults
	Default uValue    := ::GetVals()
	Default lWithPict := .F.

	//------------------------------
	// Conjunto de Valores (Array)
	//------------------------------
	cTipoVal := ValType(uValue)
	If cTipoVal == "A"
		aValues  := aClone( uValue )
	Else
		aValues  := { uValue }
	EndIf

	//------------------------------
	// Transforma os Valores em Num�ricos e os formata caso necess�rio
	//------------------------------
	For nValue := 1 To Len(aValues)
		If ValType(aValues[nValue]) == "C"
			// Retira todas as formata��es em String e Converte para um valor Num�rico
			nAt := AT(":", aValues[nValue])
			If nAT > 0
				aValues[nValue] := HTON(aValues[nValue])
			Else
				aValues[nValue] := StrTran(aValues[nValue], ".", "") // Retira formata��o de N�meros, ex.: 1.000 para 1000
				aValues[nValue] := StrTran(aValues[nValue], ",", ".") // Retira formata��o de N�meros, ex.: 1.000,50 para 1000.50

				aValues[nValue] := Val(aValues[nValue])
			EndIf
		EndIf

		// Se desejar formatar
		If lWithPict
			// Realiza a Formata��o do Valor para:
			If cContent == "1" // Num�rico
				aValues[nValue] := Transform(aValues[nValue], cPicture)
			ElseIf cContent == "2" // Hor�rio
				aValues[nValue] := NTOH(aValues[nValue])
			EndIf
			aValues[nValue] := AllTrim( aValues[nValue] )
		EndIf
	Next nValue

	//------------------------------
	// Devolve o Valor configurado
	//------------------------------
	If cTipoVal == "A"
		uValue := aClone( aValues )
	Else
		uValue := aValues[1]
	EndIf

Return uValue

//---------------------------------------------------------------------
/*/{Protheus.doc} ConfigSecs
M�todo que define as Configura��es das Se��es do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@param nSection
	Se��o a configurar * Obrigat�rio
	 1 - M�nima
	 2 - M�xima
@param nValue
	Valor a setar * Obrigat�rio
@param nType
	Tipo da configura��o * Obrigat�rio
	 1 - Valor Num�rico
	 2 - Porcentagem

@return .T. Configura��o confirmada; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method ConfigSecs(nSection, nValue, nType) Class TNGIndicator

	Local aValores := ::GetVals()
	Local cStyle   := ::GetStyle()

	Local nCalc1Ini := 0, nCalc1Per := 0
	Local nCalc2Ini := 0, nCalc2Per := 0
	Local nCalc3Ini := 0, nCalc3Per := 0

	Local nValNumeri := 0
	Local nValPorcen := 0
	Local nNumeriMin := 0, nNumeriMax := 0
	Local nPercenMin := 0, nPercenMax := 0
	Local uAux1 := 0

	Local nValSecMin := 0, nValSecMax := 0
	Local nPorSecMin := 0, nPorSecMax := 0
	Local nAuxSecao  := 0
	Local nPorOutro  := 0 // Vari�vel que armazena a Porcentagem da OUTRA SE��O (diferente da passada no par�metro 'nSection')

	// Defaults
	Default nSection := 0
	Default nValue   := 0
	Default nType    := 0

	// Valida se consegue configurar
	If Empty(nSection) .Or. Empty(nType)
		Return .F.
	EndIf

	//----------------------------------------
	// Recebe os Valores para os c�lculos
	//----------------------------------------
	// Valores
	nValNumeri := nValue
	nValPorcen := nValue

	// M�nimos e M�ximos
	nNumeriMin := aValores[1]
	nNumeriMax := aTail(aValores)
	nPercenMin := 0
	nPercenMax := 100

	// Como vamos trabalhar com a Porcentagem, se for Num�rico, deve-se converter para Porcentagem
	// O valor num�rico servir� para indicar o quanto a Porcentagem equivale em valor no indicador
	If nType == 1 // Num�rico
		// Porcentagem � da Esquerda para a Direita
		nValPorcen := ( (nValNumeri * 100) / nNumeriMax )
	Else //Porcentagem
		nValNumeri := ( (nValPorcen * nNumeriMax) / 100 )
	EndIf

	// Valida se os valores Num�rico e da Porcentagem est�o dentro dos valores permitidos do Indicador
	/*If ( nValPorcen < nPercenMin .Or. nValPorcen > nPercenMax ) .Or. ;
		( nValNumeri < nNumeriMin .Or. nValNumeri > nNumeriMax )
		fShowMsg(STR0033, "I") //"O valor selecionado � inv�lido pois excede os limites do Indicador."
		Return .F.
	EndIf*/

	//--------------------
	// Ajusta a Se��o
	//--------------------
	If cStyle == __cSVeComu
		//--------------------------------------------------
		// Estilo Veloc�metro Comum
		//--------------------------------------------------
		nCalc1Ini := ::aConfig[__nCfgAtua][1][1] //Inicial
		nCalc1Per := ::aConfig[__nCfgAtua][1][2] //Quanto percorre

		nCalc2Ini := ::aConfig[__nCfgAtua][2][1] //Inicial
		nCalc2Per := ::aConfig[__nCfgAtua][2][2] //Quanto percorre

		nCalc3Ini := ::aConfig[__nCfgAtua][3][1] //Inicial
		nCalc3Per := ::aConfig[__nCfgAtua][3][2] //Quanto percorre

		// Transforma a Porcentagem em �ngulos
		uAux1 := If(nSection == 1, nValPorcen, ABS(nValPorcen-100))// Temos que inverter na Se��o M�xima, pois os �ngulos s�o da Direita para a Esquerda
		uAux1 := ( (__nAngMax__ * uAux1) / 100 )

		If nSection == 1 // Se��o M�nima
			//--- Calcula o Range da Esquerda
			If uAux1 > __nAngMax__ // A Esquerda pode ter no m�ximo a quantidade de �ngulos M�xima
				uAux1 := __nAngMax__
			EndIf
			nCalc1Per := uAux1
			nCalc1Ini := ( __nAngFim__ - nCalc1Per )

			//--- Calcula o Range da Direita
			nCalc3Ini := __nAngIni__ // A Direita sempre inicia no �ngulo M�nimo
			// Somente altera se o In�cio da Esquerda ultrapassar o da Range da Direita
			If ( nCalc3Ini + nCalc3Per ) > nCalc1Ini
				If nCalc3Ini < nCalc1Ini
					If nCalc1Ini < 0
						nCalc3Per := ( nCalc1Ini - nCalc3Ini )
					Else
						nCalc3Per := ABS( nCalc3Ini - nCalc1Ini )
					EndIf
				Else
					nCalc3Per := 0
				EndIf
			EndIf

			// Quantidade de �ngulos at� a Se��o da Direita
			nAuxSecao := (__nAngMax__ - nCalc3Per)
		ElseIf nSection == 2 // Se��o Maxima
			//--- Calcula o Range da Direita
			nCalc3Ini := __nAngIni__ // A Direita sempre inicia no �ngulo M�nimo
			If uAux1 > __nAngMax__ // A Direita pode ter no m�ximo a quantidade de �ngulos M�xima
				uAux1 := __nAngMax__
			EndIf
			nCalc3Per := uAux1

			//--- Calcula o Range da Esquerda
			// Somente altera se o Range da Direita ultrapassar o In�cio da Esquerda
			uAux1 := ( nCalc3Ini + nCalc3Per )
			If uAux1 > nCalc1Ini
				nCalc1Ini := uAux1
				nCalc1Per := ( __nAngFim__ - uAux1 ) // A Esquerda sempre termina no �ngulo Final
			EndIf

			// Quantidade de �ngulos da Se��o da Esquerda
			nAuxSecao := nCalc1Per
		EndIf

		//--- Calcula o Range Central
		nCalc2Ini := ( nCalc3Ini + nCalc3Per ) // In�cio igual ao t�rmino da Direita
		nCalc2Per := ( nCalc1Ini - nCalc2Ini ) // Fim igual ao In�cio da Esquerda menos o T�rmino da Direita (ficando assim o espa�o faltante preenchido com o Range Central)

		// Define as Se��es
		::aConfig[__nCfgAtua][1][1] := Round(nCalc1Ini,__nDecimals__)
		::aConfig[__nCfgAtua][1][2] := Round(nCalc1Per,__nDecimals__)

		::aConfig[__nCfgAtua][2][1] := Round(nCalc2Ini,__nDecimals__)
		::aConfig[__nCfgAtua][2][2] := Round(nCalc2Per,__nDecimals__)

		::aConfig[__nCfgAtua][3][1] := Round(nCalc3Ini,__nDecimals__)
		::aConfig[__nCfgAtua][3][2] := Round(nCalc3Per,__nDecimals__)

		// Porcentagem a partir da quantidade de �ngulos da OUTRA SE��O
		nPorOutro := ( (nAuxSecao * 100) / __nAngMax__ )
	ElseIf cStyle == __cSVeSecc
		//--------------------------------------------------
		// Estilo Veloc�metro Seccionado
		//--------------------------------------------------
		nCalc1Ini := ::aConfig[__nCfgAtua][1] //Inicial

		nCalc2Ini := ::aConfig[__nCfgAtua][2] //Intermidiario/Final

		// Transforma a Porcentagem em Barras
		uAux1 := ( (nValPorcen * ::nBars) / 100 )
		// Transforma num valor aceit�vel pela Se��o (com a quantidade de marcadores, neste caso, se��es: 6 - come�ando a contagem pelo n�mero 1)
		uAux1 := ( (6 * uAux1) / ::nBars ) // Define em qual se��o (de 1 a 6) aquela quantidade de Barras est�

		If nSection == 1 // Se��o M�nima
			nCalc1Ini := uAux1 // Se��o posicionada

			// Somente altera se a Se��o M�nima ultrapassar a M�xima
			If nCalc1Ini > nCalc2Ini
				nCalc2Ini := nCalc1Ini
			EndIf

			// Se��o posicionada na Direita
			nAuxSecao := nCalc2Ini
		ElseIf nSection == 2 // Se��o M�xima
			nCalc2Ini := uAux1 // Se��o posicionada

			// Somente altera se a Se��o M�xima ultrapassar a M�nima
			If nCalc2Ini < nCalc1Ini
				nCalc1Ini := nCalc2Ini
			EndIf

			// Se��o posicionada da Esquerda
			nAuxSecao := nCalc1Ini
		EndIf

		// Define as Se��es
		::aConfig[__nCfgAtua][1] := Round(nCalc1Ini,__nDecimals__)

		::aConfig[__nCfgAtua][2] := Round(nCalc2Ini,__nDecimals__)

		// Porcetagem a partir da se��o posicionada
		nPorOutro := ( (nAuxSecao * 100) / 6 )
	Else
		//--------------------------------------------------
		// Estilos que utilizem porcentagens padr�es
		//--------------------------------------------------
		nCalc1Ini := ::aConfig[__nCfgAtua][1] //Inicial

		nCalc2Ini := ::aConfig[__nCfgAtua][2] //Intermidiario/Final

		uAux1 := ( nValPorcen / 100 )
		If nSection == 1 // Se��o M�nima
			nCalc1Ini := uAux1
		ElseIf nSection == 2 // Se��o M�xima
			nCalc2Ini := uAux1
		EndIf

		// Define as Se��es (Decimais * 2 porque j� est�o dividios por 100)
		::aConfig[__nCfgAtua][1] := Round(nCalc1Ini,(__nDecimals__*2))

		::aConfig[__nCfgAtua][2] := Round(nCalc2Ini,(__nDecimals__*2))

		// Porcentagem da OUTRA SE��O
		nPorOutro := If(nSection == 1, nCalc2Ini, nCalc1Ini) * 100
	EndIf

	//--------------------------------------------------
	// Armazena os Valores a as Porcentagem das Se��es M�nima e M�xima
	//--------------------------------------------------

	If nSection == 1 // Se��o M�nima
		nValSecMin := nValNumeri
		nPorSecMin := nValPorcen

		nPorSecMax := nPorOutro
		nValSecMax := ( (nPorSecMax * nNumeriMax) / 100 )
	Else
		nValSecMax := nValNumeri
		nPorSecMax := nValPorcen

		nPorSecMin := nPorOutro
		nValSecMin := ( (nPorSecMin * nNumeriMax) / 100 )
	EndIf

	//--- Valor e Porcentagem da Se��o M�nima
	::aConfig[__nCfgVals][1][1] := Round(nValSecMin,__nDecimals__)
	::aConfig[__nCfgVals][1][2] := Round(nPorSecMin,__nDecimals__)
	//--- Valor e Porcentagem da Se��o M�xima
	::aConfig[__nCfgVals][2][1] := Round(nValSecMax,__nDecimals__)
	::aConfig[__nCfgVals][2][2] := Round(nPorSecMax,__nDecimals__)

	// Redefine a distribui��o das se��es
	fAtuSects(Self)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} ConfigClrs
M�todo que define as Configura��es de Cores do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@uColor
	Cor a ser convertida * Obrigat�rio

@return aRetClr
	1 - Cor em Hexadecimal
	2 - Cor em RGB
/*/
//---------------------------------------------------------------------
Method ConfigClrs(uColor) Class TNGIndicator

	Local aClrRGB := {}
	Local nClrRGB := 0
	Local cClrHex := ""

	Local aRetClr := {}

	// Recebe a cor em Hexadecimal e em RGB
	If ValType(uColor) == "N"
		nClrRGB := uColor

		// Transforma no array {RED ; GREEN ; BLUE}
		aClrRGB := { Int( nClrRGB % 256 ),  Int( (nClrRGB / 256) % 256 ), Int ( nClrRGB / 256 / 256 ) }

		// Transforma em Hexadecimal
		cClrHex := "#"+NGRGBHEX(aClrRGB)
	ElseIf ValType(uColor) == "C"
		cClrHex := uColor

		aClrRGB := aClone( NGHEXRGB(SubStr(cClrHex,2)) )
		nClrRGB := RGB( aClrRGB[1], aClrRGB[2], aClrRGB[3] )
	EndIf

	// Atribui ao retorno
	aRetClr := {cClrHex, nClrRGB}

Return aRetClr

//---------------------------------------------------------------------
/*/{Protheus.doc} Preview
M�todo que seta a Configura��o da Pr�-visualizacao (Preview).

@author Wagner Sobral de Lacerda
@since 25/01/2012

@return .T. Configura��o atualizada; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method Preview() Class TNGIndicator

	Local cPnlTitle := OemToAnsi(STR0034) //"Pr�-Visualiza��o"
	Local oPnlTitle := Nil

	Local aColor    := NGCOLOR()
	Local nTxtColor := aColor[1]
	Local nBckColor := aColor[2]

	Local oFontBold := TFont():New(, , , , .T.)

	// Desabilita a Configura��o e o Zoom
	::CanConfig(.F.)
	::CanZoom(.F.)

	// Desabilita o Clique da Direita
	::SetRClick(.F.)

	// Adiciona um t�tulo indicando a pr�-visualiza��o
	oPnlTitle := TPanel():New(01, 01, cPnlTitle, ::oParent, oFontBold, .T., , nTxtColor, nBckColor, 100, 012)
	oPnlTitle:Align := CONTROL_ALIGN_TOP

	// Desenha o Indicador apenas se n�o estiver em processo de atualiza��o
	If !::lUpdating
		::Indicator()
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Test
M�todo que executa um teste de Anim��o do Indicador.

@author Wagner Sobral de Lacerda
@since 25/01/2012

@return .T. Indicador configurado corretamente; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method Test() Class TNGIndicator

	Local aValores := aClone( ::GetVals() )
	Local lReverse := .T.

	If ::lIndicator
		::Animate(aValores[1], aValores[Len(aValores)], lReverse)
	Else
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Refresh
M�todo que executa um teste de Anim��o do Indicador.

@author Wagner Sobral de Lacerda
@since 26/01/2012

@param lRefresh
	Indica se pode atualizar o Indicador * Opcional
	Default ::lRefresh

@return .T. Indicador atualizado; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method Refresh(lRefresh) Class TNGIndicator

	// Defaults
	Default lRefresh := ::lRefresh

	//N�o executa o Refresh se houver alguma atualiza��o em processo
	If ::lUpdating
		Return .F.
	EndIf

	// Atualiza somente se j� estiver criado
	If !::lBackgroun
		Return .F.
	EndIf

	//Atualiza o Indicador
	If lRefresh
		::lRefresh := .T.

		::lUpdating := .T.
		::Reset(.T., .T.)
		::lUpdating := .F.
	Else
		::lRefresh := .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Reset
M�todo que reinicializa o Indicador, deletando os Shapes e os criando
novamente.

@author Wagner Sobral de Lacerda
@since 19/10/2011

@param lValorAtu
	Resetar o Indicador, mas deixar o valor atual * Opcional
	Default: .F.
@param lForceReset
	Indica se deve for�ar a reinicializa��o * Opcional
	Default: .F.

@return .T. Indicador resetado; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method Reset(lValorAtu, lForceReset) Class TNGIndicator

	Local nOldValue := 0

	// Vari�veis de configura��o
	Local cClrBack   := ::cClrBack

	Local aCores     := aClone( ::GetColors()  )
	Local aDescricao := aClone( ::GetDesc()    )
	Local aOutros    := aClone( ::GetOthers()  )
	Local aSombras   := aClone( ::GetShadows() )
	Local aTextos    := aClone( ::GetTexts()   )
	Local aValores   := aClone( ::GetVals()    )

	// Defaults
	Default lValorAtu   := .F.
	Default lForceReset := .F.

	// N�o executa o Reset se houver alguma atualiza��o em processo (a n�o ser que tenha sido passado o par�metro para for�ar o Reset
	If !lForceReset .And. ::lUpdating
		Return .F.
	EndIf

	// S� pode resetar se j� estiver criado
	If !::lBackgroun
		Return .F.
	EndIf

	// Indica que est� em fase de 'Reset'
	::lReseting := .T.

	// Recebe o Valor para o qual o Indicador deve ser resetado
	nOldValue := If(lValorAtu, ::GetValue(), ::aValues[1])

	// Reinicializa o Indicador
	::Initialize(cClrBack, aValores, aCores, aTextos, aSombras, aOutros, aDescricao)

	// Deleta os Shapes j� existentes
	::DeleteShapes()

	// Cria os Shapes Padr�es
	::CreateShapes()

	// Atualiza o Valor Atual do Indicador
	::SetValue(nOldValue)

	//--- Atualiza o Indicador (desenha em tela)
	::Indicator()

	// Atualiza o rodap�
	::CanFooter()

	// Retira do estado de 'Reset'
	::lReseting := .F.

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} CopyTo
M�todo que copia os dados do Indicador para um outro objeto Indicador
da classe TNGIndicator.

@author Wagner Sobral de Lacerda
@since 20/02/2012

@param oIndicTo
	Indicador para o qual as informa��es ser�o copiadas/atribu�das * Obrigat�rio

@return .T. Indicador copiado; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method CopyTo(oIndicTo) Class TNGIndicator

	// Recebe Configura��e do Indicador Principal (Self)
	Local cStyle   := ::GetStyle()
	Local cContent := ::GetContent()
	Local cPicture := ::GetPicture()

	Local aConfig    := aClone( ::GetConfig() )
	Local aCores     := aClone( ::GetColors()  )
	Local aDescricao := aClone( ::GetDesc()    )
	Local aOutros    := aClone( ::GetOthers()  )
	Local aSombras   := aClone( ::GetShadows() )
	Local aTextos    := aClone( ::GetTexts()   )
	Local aValores   := aClone( ::GetVals()    )

	// Defaults
	Default oIndicTo := Nil

	// Verifica se � poss�vel copiar o Indicador
	If ValType(oIndicTo) <> "O"
		Return .F.
	EndIf

	// Verifica se o objeto � da classe TNGIndicator
	If Upper(AllTrim( oIndicTo:ClassName() )) <> "TNGINDICATOR"
		Return .F.
	EndIf

	//------------------------------------------------------------
	// Copia para o Indicador passado como par�metro da fun��o
	//------------------------------------------------------------
	oIndicTo:Refresh(.F.)

	oIndicTo:SetStyle(cStyle)
	oIndicTo:SetContent(cContent)
	oIndicTo:SetPicture(cPicture)

	oIndicTo:SetConfig(aConfig)
	oIndicTo:SetColors(aCores)
	oIndicTo:SetOthers(aOutros)
	oIndicTo:SetShadows(aSombras)
	oIndicTo:SetTexts(aTextos)
	oIndicTo:SetDesc(aDescricao)
	oIndicTo:SetVals(aValores)

	oIndicTo:Refresh(.T.)

Return .T.

/*/
############################################################################################
##                                                                                        ##
## M�TODOS: MENU POPUP                                                                    ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} MenuPopUp
M�todo que monta o MENU POPUP.

@author Wagner Sobral de Lacerda
@since 24/08/2012

@return oMenu
/*/
//---------------------------------------------------------------------
Method MenuPopUp() Class TNGIndicator

	// Vari�veis auxiliares
	Local aMenu := {}
	Local cTitulo := "", cImage := "", cAction := ""
	Local lSeparador := .F.
	Local nX := 0, nMaxStr := 15

	// Vari�veis do objeto do Menu
	Local oMenu
	Local oItem
	Local lActive := .T.

	//--- Define os itens do Menu
	// 1      ; 2             ; 3            ; 4
	// T�tulo ; Imagem do RPO ; A��o do Item ; � um separador?
	aAdd(aMenu, {STR0035, "ng_lupacons", {|| ::CallPopup("Information") }, .F.}) //"Informa��es"
	aAdd(aMenu, {STR0036, "ng_ico_docdet", {|| ::CallPopup("Details") }, .F.}) //"Detalhes"
	aAdd(aMenu, {, , , .T.})
	aAdd(aMenu, {STR0037, "ng_ico_legenda", {|| ::CallPopup("Legend") }, .F.}) //"Legenda"

	//----------
	// Monta
	//----------
	oMenu := TMenu():New(0/*nTop*/, 0/*nLeft*/, 0/*nHeight*/, 0/*nWidth*/, .T./*lPopUp*/, /*cBmpName*/, ::oParent/*oWnd*/, ;
							/*nClrNoSelect*/, /*nClrSelect*/, /*cArrowUpNoSel*/, /*cArrowUpSel*/, /*cArrowDownNoSel*/, /*cArrowDownSel*/)

	For nX := 1 To Len(aMenu)
		// Recebe dados do item
		lSeparador := aMenu[nX][4]

		If lSeparador
			cTitulo := "'" + Replicate("_", nMaxStr) + "'"
			cImage  := "''"
			cAction := "{|| Nil }"
			lActive := .F.
		Else
			cTitulo := "'" + PADR(aMenu[nX][1], nMaxStr, " ") + "'"
			cImage  := "'" + aMenu[nX][2] + "'"
			cAction := GetCbSource(aMenu[nX][3])
			lActive := .T.
		EndIf

		// Monta o Item
		oItem := TMenuItem():New(oMenu:Owner()/*oParent*/, &(cTitulo)/*cTitle*/, /*cParam3*/, /*lParam4*/, lActive/*lActive*/, ;
									&(cAction)/*bAction*/, /*cParam7*/, &(cImage)/*cResName*/, /*nParam9*/, /*cParam10*/, /*lParam11*/, ;
									/*nParam12*/, /*bParam13*/, /*lParam14*/, .T./*lPopup*/)

		// Adiciona no Menu
		oMenu:Add(oItem)
	Next nX

Return oMenu

//---------------------------------------------------------------------
/*/{Protheus.doc} CallPopUp
M�todo que chama (executa) o MENU POPUP.

@author Wagner Sobral de Lacerda
@since 24/08/2012

@param cMethod
	M�todo a ser executado * Obrigat�rio
	Obs.: deve ser passado somente o nome do m�todo!
	Por exemplo: "Legend"

@return oMenu
/*/
//---------------------------------------------------------------------
Method CallPopUp(cMethod) Class TNGIndicator

	// Vari�vel do Painel Preto
	Local oBlackPnl := Nil

	// Vari�vel do m�todo a ser executado
	Local cExecMeth := cMethod

	//-- Define o m�todo a ser executado
	cMethod := StrTran(cMethod, "Self", "") // Limpa a chamada do 'Self'
	cMethod := StrTran(cMethod, ":", "") // Limpa os ':'

	cMethod := "Self:" + cMethod // define agora de certeza como vai ficar a chamada
	// Se n�o houver os par�nteses, adiciona
	If !("(" $ cMethod)
		cMethod += "()"
	EndIf
	cMethod := "{|| " + cMethod + "}"

	//----------
	// Executa
	//----------
	// Painel Preto de Background (Transpar�ncia)
	fBlackPanel(@oBlackPnl, .T.)

	//-- Executa a Op��o
	Eval( &(cMethod) )

	// Esconde Painel Preto
	fBlackPanel(@oBlackPnl, .F.)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Information
M�todo que mostra as Informa��es do Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 27/08/2012

@return .T.
/*/
//---------------------------------------------------------------------
Method Information() Class TNGIndicator

	// Vari�veis de Bloco de C�digo
	Local bInform := ::GetCodeBlock(__nBInform)

	//----------
	// Executa
	//----------
	If ValType(bInform) == "B"
		Eval(bInform, Self)
	Else
		fShowMsg(STR0038, "I") //"N�o h� informa��es dispon�veis para este Indicador."
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Details
M�todo que mostra os Detalhes do Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 21/08/2012

@return .T.
/*/
//---------------------------------------------------------------------
Method Details() Class TNGIndicator

	// Vari�veis de Bloco de C�digo
	Local bDetail := ::GetCodeBlock(__nBDetail)

	//----------
	// Executa
	//----------
	If ValType(bDetail) == "B"
		Eval(bDetail, Self)
	Else
		fShowMsg(STR0039, "I") //"N�o h� um detalhamento dispon�vel para este Indicador."
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Legend
M�todo que mostra uma Legenda para o Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 21/08/2012

@return .T.
/*/
//---------------------------------------------------------------------
Method Legend() Class TNGIndicator

	// Vari�veis de Bloco de C�digo
	Local bLegend := ::GetCodeBlock(__nBLegend)

	//----------
	// Executa
	//----------
	If ValType(bLegend) == "B"
		Eval(bLegend, Self)
	Else
		fShowMsg(STR0040, "I") //"N�o h� uma legenda dispon�vel para este Indicador."
		Return .F.
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## M�TODOS: DESTRUI��O DO INDICADOR                                                       ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} DeleteBackgrd
M�todo que deleta os shapes de Background do Indicador.

@author Wagner Sobral de Lacerda
@since 23/02/2011

@return .T. Shapes de Background deletados; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method DeleteBackgrd() Class TNGIndicator

	Local nTipo   := 0
	Local nCamada := 1 // Camada exclusiva de Shapes Background
	Local nX := 0

	//Valida se existem Shapes
	If !::lBackgroun
		Return .F.
	EndIf

	// Limpa o Array de Shapes
	For nTipo := 1 To Len(::aShapes)

		For nX := 1 To Len(::aShapes[nTipo][nCamada])
			::oTPPanel:DeleteItem(::aShapes[nTipo][nCamada][nX][__nID])
		Next nX

		::aShapes[nTipo][nCamada] := {}

	Next nTipo

	// Zera o ID para o Shape Background
	::nIDBack := 0

	// Indica que nao possui mais o Background
	::lBackgroun := .F.

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} DeleteShapes
M�todo que deleta os shapes do Indicador.

@author Wagner Sobral de Lacerda
@since 19/10/2011

@return .T. Shapes deletados; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method DeleteShapes() Class TNGIndicator

	Local nTipo   := 0
	Local nCamada := 0
	Local nX := 0

	//Valida se existem Shapes
	If !::lBackgroun
		Return .F.
	EndIf

	//Limpa o Array de Shapes
	For nTipo := 1 To Len(::aShapes)
		For nCamada := 1 To ::nLayers

			If nCamada > 1 // A Camada 1 e' reservada para o Background, e nao sera deletada (por isto inicia a partir da 'nCamada' 2)
				For nX := 1 To Len(::aShapes[nTipo][nCamada])
					::oTPPanel:DeleteItem(::aShapes[nTipo][nCamada][nX][__nID])
				Next nX

				::aShapes[nTipo][nCamada] := {}
			EndIf

		Next nCamada
	Next nTipo

	// Limpa o Array auxiliar
	::aAuxiliary := {}

	//Zera os IDs para os Shapes
	::nIDShape := ( ::nIDBack + 1 )

	//Indica que nao possui mais os Shapes
	::lIndicator := .F.

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} Destroy
M�todo que destr�i o objeto Indicador.

@author Wagner Sobral de Lacerda
@since 19/10/2011

@return .T. Indicador destru�do; .F. caso n�o
/*/
//---------------------------------------------------------------------
Method Destroy() Class TNGIndicator

	::oTPPanel:ClearAll()
	::oTPPanel:FreeChildren()
	MsFreeObj(::oTPPanel)

	If ValType(::oScroll) == "O"
		::oScroll:FreeChildren()
		MsFreeObj(::oScroll)
	EndIf

	::oFooter:FreeChildren()
	MsFreeObj(::oFooter)

	Self:FreeChildren()
	MsFreeObj(Self)

Return .T.

/*/
############################################################################################
##                                                                                        ##
## M�TODOS: HABILITAR/DESABILITAR                                                         ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} CanConfig
M�todo que Habilita/Desabilita a Configura��o do Indicador.

@author Wagner Sobral de Lacerda
@since 26/03/2012

@param lCanConfig
	Indica se pode (.T.) ou n�o (.F.) configurar * Opcional
	Default: .T.

@return .T.
/*/
//---------------------------------------------------------------------
Method CanConfig(lCanConfig) Class TNGIndicator

	// Defaults
	Default lCanConfig := .T.

	// Se puder configurar, mostra o bot�o
	If lCanConfig
		::oFootCfg:Show()
	Else // Caso contr�rio, esconde o bot�o
		::oFootCfg:Hide()
	EndIf

	// Verifica se deve mostrar ou esconder o rodap�
	::CanFooter()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} CanZoom
M�todo que Habilita/Desabilita o Zoom do Indicador.

@author Wagner Sobral de Lacerda
@since 26/03/2012

@param lCanZoom
	Indica se pode (.T.) ou n�o (.F.) alterar o zoom * Opcional
	Default: .T.

@return .T.
/*/
//---------------------------------------------------------------------
Method CanZoom(lCanZoom) Class TNGIndicator

	// Defaults
	Default lCanZoom := .T.

	// Se puder alterar o zoom, mostra os bot�es
	If lCanZoom
		::oFootZoomP:Show()
		::oFootZoomM:Show()
	Else // Caso contr�rio, esconde os bot�es
		::oFootZoomP:Hide()
		::oFootZoomM:Hide()
	EndIf

	// Verifica se deve mostrar ou esconder o rodap�
	::CanFooter()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} CanFooter
M�todo que Habilita/Desabilita o Rodap� do Indicador.

@author Wagner Sobral de Lacerda
@since 26/03/2012

@param lCanFooter
	Indica se deve for�ar a visibilidade do rodap� * Opcional
	   .T. - For�a como Vis�vel
	   .F. - For�a como Invis�vel
	Default: Nil (n�o for�a, verifica os objetos padr�es do rodap�)

@return .T.
/*/
//---------------------------------------------------------------------
Method CanFooter(lCanFooter) Class TNGIndicator

	Local lForceVis := ( ValType(lCanFooter) == "L" )

	// Mostra ou Esconde o rodap�
	If lForceVis
		If lCanFooter
			::oFooter:Show()
		Else
			::oFooter:Hide()
		EndIf
	Else
		If !::oFootCfg:lVisible .And. !::oFootZoomP:lVisible .And. !::oFootZoomM:lVisible
			::oFooter:Hide()
		EndIf
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## M�TODOS: EXPORTAR O INDICADOR                                                          ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} Export
M�todo que Exporta o Indicador Gr�fico para um imagem no disco.

@author Wagner Sobral de Lacerda
@since 13/07/2012

@return .T.
/*/
//---------------------------------------------------------------------
Method Export() Class TNGIndicator

	// Vari�veis do Dialog
	Local oDlgExport
	Local cDlgExport := OemToAnsi(STR0041 + " .PNG") //"Exportar Indicador para Imagem"
	Local lDlgExport
	Local oPnlExport

	Local cPathArq := ""

	Private oGetDir := Nil, nSizeDir := 100, oLocDir := Nil
	Private oGetArq := Nil, nSizeArq := 40

	Private cDiretorio := Space(nSizeDir)
	Private cArquivo := Space(nSizeArq)

	//--- Nome padr�o do arquivo
	cArquivo := PADR("ind_model_"+::GetStyle(), nSizeArq, " ")

	//----------------------------------------
	// Monta janela para exportar o arquivo
	//----------------------------------------
	DEFINE MSDIALOG oDlgExport TITLE cDlgExport FROM 0,0 TO 250,500 OF oMainWnd PIXEL

		// Painel principal do Dialog
		oPnlExport := TPanel():New(001, 001, , oDlgExport, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
		oPnlExport:Align := CONTROL_ALIGN_ALLCLIENT

			// Mensagem
			@ 005,010 SAY OemToAnsi(STR0042) OF oPnlExport PIXEL //"Informe abaixo o nome do arquivo e o diret�rio onde ele deve ser salvo."

			// Diret�rio
			@ 020,010 SAY OemToAnsi(STR0043) COLOR CLR_HBLUE,CLR_WHITE OF oPnlExport PIXEL //"Diret�rio:"
			@ 030,010 MSGET oGetDir VAR cDiretorio SIZE 180,008 OF oPnlExport PIXEL
			@ 029,200 BUTTON oLocDir PROMPT STR0044 SIZE 040,012 ACTION (fExpGetDir()) OF oPnlExport PIXEL //"Localizar"

			// Arquivo
			@ 045,010 SAY OemToAnsi(STR0045) COLOR CLR_HBLUE,CLR_WHITE OF oPnlExport PIXEL //"Arquivo:"
			@ 055,010 MSGET oGetArq VAR cArquivo SIZE 080,008 OF oPnlExport PIXEL

	ACTIVATE MSDIALOG oDlgExport ON INIT EnchoiceBar(oDlgExport, {|| lDlgExport := .T., If(fExpValid(), oDlgExport:End(), lDlgExport := .F.) }, ;
														{|| lDlgExport := .F., oDlgExport:End() }) CENTERED

	// Exporta o TPaintPanel para uma imagem .PNG
	If lDlgExport
		cPathArq := AllTrim(cDiretorio) + AllTrim(cArquivo) + ".PNG"
		::oTPPanel:SaveToPNG(0/*nLeft*/, 0/*nTop*/, ::oTPPanel:nWidth/*nWidth*/, ::oTPPanel:nHeight/*nHeight*/, cPathArq/*cFileTarget*/)
		MsgInfo(STR0046, STR0047) //"Imagem salva com sucesso!" ## "Exporta��o para PNG"
	EndIf

Return .T.

//--------------------------------------------------------------------------------
/*/{Protheus.doc} ConfigLgnd
M�todo que configura os marcadores do indicador gr�fico conforme os valores
a serem apresentados.

@author Alexandre Santos
@since 08/05/2018

@param 	nValue	 , Num�rico, Valor num�rico que devera ser apresentado no indicador
		lMarker	 , L�gico  , Verifica se a chamada � feita dos shapes de marcadores
		neste formato o valor � abreviado a partir de milh�es.
@return cResult  , Caracter, Valor convertido em texto j� abreviado que devera ser
apresentado no indicador
/*/
//--------------------------------------------------------------------------------
Method ConfigLgnd( nValue, lMarker ) Class TNGIndicator
    Local nValueSize    := 0
    Local cSuffix       := ''
    Local cResult       := ''

    Default nValue      := ::GetValue()
    Default lMarker     := .F.

	//Quantidade de caracteres do numero incluive ap�s as casas decimais, (-3) fixo para remover o decimal com ponto
    nValueSize := Len(AllTrim(Str(nValue, , 2))) - 3

    Do Case
		Case nValueSize > 15
			cSuffix := 'Q' //Quadrilh�es
		Case nValueSize > 12
            cSuffix := 'T' //Trilh�es
		Case nValueSize > 9
            cSuffix := 'B' //Bilh�es
		Case lMarker .And. nValueSize > 6
            cSuffix := 'M' //Milh�es
    EndCase

    If !Empty(cSuffix)
		cResult := Substr(AllTrim(Transform( nValue, ::GetPicture() )),1,5) + cSuffix
	Else
		cResult := AllTrim( IIf(::GetContent() == "2", NtoH(nValue), Transform( nValue, ::GetPicture() )))
	EndIf

Return cResult

//---------------------------------------------------------------------
/*/{Protheus.doc} fExpValid
Fun��o auxilixar para validar a exporta��o do arquivo.

@author Wagner Sobral de Lacerda
@since 13/07/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fExpValid()

	// Vari�veis auxiliares
	Local cExpDir := AllTrim(cDiretorio)
	Local cExpArq := AllTrim(cArquivo) + If(!Empty(cArquivo), ".PNG", "")

	// Valida o Diret�rio
	If Empty(cExpDir)
		fShowMsg(STR0048, "I") //"Informe o diret�rio onde o arquivo dever� ser salvo."
		Return .F.
	ElseIf !ExistDir(cExpDir)
		fShowMsg(STR0049 + CRLF + STR0050, "I") //"O diret�rio informado n�o existe." ## "Por favor, informe outro diret�rio."
		Return .F.
	EndIf

	// Valida o Arquivo
	If Empty(cExpArq)
		fShowMsg(STR0051, "I") //"Informe o nome do arquivo."
		Return .F.
	ElseIf File(cExpDir + cExpArq)
		If !MsgYesNo(STR0052 + " '" + cExpArq + "' " + STR0053 + CRLF + CRLF + ; //"O arquivo" ## "j� existe no diret�rio especificado."
					STR0054, STR0055) //"Deseja subsitutir o arquivo existente?" ## "Aten��o"
			Return .F.
		EndIf
		FErase(cExpDir + cExpArq)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fExpGetDir
Fun��o auxilixar para localizar e selecionar o diret�rio.

@author Wagner Sobral de Lacerda
@since 13/07/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fExpGetDir()

	// Escolhe o diret�rio
	cDiretorio := cGetFile(/*cMascara*/, /*cTitulo*/, /*nMascpadrao*/, /*cDirinicial*/, .F./*lSalvar*/, ;
							GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY/*nOpcoes*/, /*lArvore*/, /*lKeepCase*/)
	cDiretorio := PADR(cDiretorio, nSizeDir, " ")

	oGetDir:CtrlRefresh()

Return .T.


/*/
############################################################################################
##                                                                                        ##
## FUN��ES AUXILIARES PARA A CLASSE                                                       ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fShowMsg
Fun��o auxilixar da classe TNGIndicator:
Mostra uma mensagem em tela.
Se houver um tela, ser� apresentado um Help(), sen�o, uma Msg()

@author Wagner Sobral de Lacerda
@since 15/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fShowMsg(cMsg, cType)

	Local cTitulo := STR0055 //"Aten��o"
	Local nAlerta := ""

	// Defaults
	Default cMsg  := ""
	Default cType := ""

	If !IsBlind()
		Help(Nil, Nil, cTitulo, Nil, cMsg, 1, 0)
	Else

		Do Case
			Case cType == "I" // Informativo
				nAlerta := 64 // MB_ICONASTERISK
			Case cType == "E" // Erro
				nAlerta := 16 // MB_ICONHAND
			Otherwise // Alerta
				nAlerta := 48 // MB_ICONEXCLAMATION
		EndCase
		MessageBox(cMsg, cTitulo, nAlerta)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fValidVals
Fun��o auxilixar da classe TNGIndicator:
Valida o Array de Valores.

@author Wagner Sobral de Lacerda
@since 26/01/2012

@param aValores
	Array de Valores para validar * Obrigat�rio

@return .T. Valores v�lidos; .F. caso n�o
/*/
//---------------------------------------------------------------------
Static Function fValidVals(aValores)

	Local cAuxErro1 := "", cAuxErro2 := ""
	Local cCompar1  := "", cCompar2  := ""
	Local cMsgErro  := ""
	Local nX := 0

	// Defaults
	Default aValores := {}

	//Quantidade m�nima de valores v�lidos
	If Len(aValores) < 2
		Return .F.
	EndIf

	//Valida os Valores
	For nX := 1 To Len(aValores)

		If !Empty(cMsgErro)
			Exit
		EndIf

		cAuxErro1 := PADL(nX, 2, "0")

		If nX == 1
			//N�o pode ser negativo
			If aValores[nX] < 0
				cCompar1 := "'" + STR0056 + Space(1) + cAuxErro1 + "'" //"Valor"
				cCompar2 := ""

				cMsgErro := cCompar1 + Space(1) + STR0057 //"n�o pode ser negativo."
			EndIf
		Else
			cAuxErro2 := PADL((nX-1), 2, "0")

			//O atual n�o pode ser menor que o anterior
			If aValores[nX] < aValores[(nX-1)]
				cCompar1 := "'" + STR0056 + Space(1) + cAuxErro1 + "'" //"Valor"
				cCompar2 := "'" + STR0056 + Space(1) + cAuxErro2 + "'" //"Valor"

				cMsgErro := cCompar1 + Space(1) + STR0058 + Space(1) + cCompar2 + "." //"n�o pode ser menor que"
			EndIf
		EndIf
	Next nX

	//Mostra a mensagem de erro (caso tenha uma)
	If !Empty(cMsgErro)
		fShowMsg(cMsgErro, "E")
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fAtuSects
Fun��o auxilixar da classe TNGIndicator:
Atualiza as Se��es do Indicador, de acordo com a sua distribui��o.

@author Wagner Sobral de Lacerda
@since 17/02/2012

@param oIndicator
	Objeto do Indicador * Obrigat�rio
@param nValue
	Valor a posicionar * Opcional
	Default: oIndicator:GetValue()

@return .T. Valores v�lidos; .F. caso n�o
/*/
//---------------------------------------------------------------------
Static Function fAtuSects(oIndicator, nValue)

	Local aCores     := aClone( oIndicator:GetColors() )
	Local aValores   := aClone( oIndicator:GetVals() )
	Local aAuxiliary := aClone( oIndicator:aAuxiliary )
	Local cStyle     := oIndicator:GetStyle()

	Local nTipo := 0, nCamada := 0, nShape := 0, nAuxShape := 0
	Local nX := 0, nY := 0, nZ := 0, nScan := 0

	// Vari�veis para atualizar o Indicador
	Local cColor     := ""
	Local nInicial   := aValores[1]
	Local nFinal     := aTail(aValores)

	Local nSecTotal := 0
	Local nSecAtual := 0
	Local nBarsSec  := 0
	Local nPosBarra := 0

	Local nPosSec := 0

	Local nBarInicio := 0
	Local nBarFinal  := 0

	Local nPorcAtual := 0 // Porcentagem que o valor atual representa
	Local nPosPontei := 0 // Posi��o do ponteiro
	Local nAuxValue  := 0
	Local nDiff := 0

	Local lUsaAlpha := ( cStyle $ (__cSSemafo + "/" + __cSPizza) )

	Local aQuadrantes := {}
	Local nDiffVerti := 0
	Local nDiffHoriz := 0

	Local nTopoAnt := 0, nTopoAtu := 0
	Local nAltuAnt := 0, nAltuAtu := 0

	// Defaults
	Default nValue := oIndicator:GetValue()

	// Atualiza as Se��es
	If cStyle == __cSVeComu
		//------------------------------
		// Estilo Veloc�metro Comum
		//------------------------------

		// Atualiza as Se��es
		nPosSec := 0
		For nX := 1 To Len(oIndicator:aRefresh)
			If oIndicator:aRefresh[nX][__nRfsHow] == __nRfsHSec
				nTipo   := oIndicator:aRefresh[nX][__nRfsTipo]
				nCamada := oIndicator:aRefresh[nX][__nRfsCama]
				nPosSec := oIndicator:aRefresh[nX][__nRfsAuxi]

				nShape := aScan(oIndicator:aShapes[nTipo][nCamada], {|x| x[__nID] == oIndicator:aRefresh[nX][__nRfsID] })
				If nShape > 0
					oIndicator:aShapes[nTipo][nCamada][nShape][8] := oIndicator:aConfig[__nCfgAtua][nPosSec][1]
					oIndicator:aShapes[nTipo][nCamada][nShape][9] := oIndicator:aConfig[__nCfgAtua][nPosSec][2]
				EndIf
			EndIf
		Next nX
	ElseIf cStyle == __cSVeSecc
		//------------------------------
		// Estilo Veloc�metro Seccionado
		//------------------------------

		// Secciona o Indicador
		nPosSec := aScan(aValores, {|x| Round(x,__nDecimals__) >= Round(nValue,__nDecimals__) })
		If nPosSec == 0 // Lembrando que o aScan j� vasculhou o array. S� sobraram ent�o os valores menores que o menor, ou maiores que o maior
			nPosSec := Len(aValores) // Se n�o encontrou, diz que � a �ltima posi��o
			If Round(nValue,__nDecimals__) < aValores[nPosSec]
				nPosSec := 1 // Mas se for menor que o �ltimo registro, diz que � a primeira
			EndIf
		EndIf
		nInicial := aValores[If(nPosSec == 1, nPosSec, (nPosSec-1))]
		nFinal   := aValores[nPosSec]

		nSecTotal := ( (nFinal - nInicial) / 2 ) // 2 � a quantidade de Marcadores para o c�lculo personalizado

		// C�lculo personalizado da Se��o Atual
		nPosSec := If(nPosSec < 2,2,nPosSec)
		nSecAtual := (nPosSec-2) + ( ( (nValue - nInicial) / nSecTotal ) / 2 )

		// Quantidade de Barras por Se��o
		nBarsSec := ( oIndicator:nBars / 6 ) // 6 � a quantidade de Marcadores 7 menos 1

		// Define a posi��o final da barra
		nPosBarra := (nSecAtual * nBarsSec)

		// Atualiza as Cores
		For nX := 1 To oIndicator:nBars
			// As barras s�o criadas da �ltima para a primeira, ent�o deve ser feita uma convers�o, onde a vari�vel
			// 'nX' = 1, deve ser equivalente a 'nY' = 30 ; 'nX' = 2, 'nY' = 29 ; 'nX' = 3, 'nY' = 28 ; e assim por diante...
			nY := ABS( nX - (oIndicator:nBars+1) )

			If nX <= nPosBarra
				If nX <= (nBarsSec * oIndicator:aConfig[__nCfgAtua][1]) // In�cio
					cColor := oIndicator:aColors[__nClrEsqu]
				ElseIf nX <= (nBarsSec * oIndicator:aConfig[__nCfgAtua][2]) // Meio
					cColor := oIndicator:aColors[__nClrTopo]
				Else // Fim
					cColor := oIndicator:aColors[__nClrDire]
				EndIf
			Else
				cColor := aCores[__nClrCent]
			EndIf

			For nZ := 1 To Len(oIndicator:aRefresh)
				If oIndicator:aRefresh[nZ][__nRfsHow] == __nRfsHSec .And. oIndicator:aRefresh[nZ][__nRfsAuxi] == nX
					nTipo   := oIndicator:aRefresh[nZ][__nRfsTipo]
					nCamada := oIndicator:aRefresh[nZ][__nRfsCama]

					nShape := aScan(oIndicator:aShapes[nTipo][nCamada], {|x| x[__nID] == oIndicator:aRefresh[nZ][__nRfsID] })
					If nShape > 0
						If nTipo == __nARC
							oIndicator:aShapes[nTipo][nCamada][nShape][6] := cColor
						EndIf
					EndIf
				EndIf
			Next nZ
		Next nX
	ElseIf cStyle == __cSTermom
		//------------------------------
		// Estilo Term�metro
		//------------------------------
		nScan := aScan(oIndicator:aRefresh, {|x| x[__nRfsHow] == __nRfsHSec })
		If nScan > 0
			nTopoAnt := oIndicator:aRefresh[nScan][4][1] // Topo Original
			nAltuAnt := oIndicator:aRefresh[nScan][4][2] // Altura Original
			nSecTotal := ( nTopoAnt + nAltuAnt )

			// Regra de Tr�s para descobrir a porcentagem do valor atual em rela��o ao valor m�ximo do indicador
			nPorcAtual := ( nValue * 100 ) / (nFinal - nInicial)
			nPorcAtual := If(nPorcAtual < 0, 0, If(nPorcAtual > 100, 100, nPorcAtual))

			// Novas posi��es
			If nPorcAtual == 0
				nTopoAtu := 0
				nAltuAtu := 0
			ElseIf nPorcAtual == 100
				nTopoAtu := nTopoAnt
				nAltuAtu := nAltuAnt
			Else
				nAltuAtu := nAltuAnt * (nPorcAtual/100)
				nTopoAtu := nSecTotal - nAltuAtu
			EndIf

			// Nova cor
			If (nPorcAtual/100) <= oIndicator:aConfig[__nCfgAtua][1] // In�cio
				cColor := oIndicator:aColors[__nClrEsqu]
			ElseIf (nPorcAtual/100) <= oIndicator:aConfig[__nCfgAtua][2] // Meio
				cColor := oIndicator:aColors[__nClrTopo]
			Else // Fim
				cColor := oIndicator:aColors[__nClrDire]
			EndIf

			//  Atualiza Shapes
			For nZ := 1 To Len(oIndicator:aRefresh)
				If oIndicator:aRefresh[nZ][__nRfsHow] == __nRfsHSec
					nTipo   := oIndicator:aRefresh[nZ][__nRfsTipo]
					nCamada := oIndicator:aRefresh[nZ][__nRfsCama]

					nShape := aScan(oIndicator:aShapes[nTipo][nCamada], {|x| x[__nID] == oIndicator:aRefresh[nZ][__nRfsID] })
					If nShape > 0
						If nTipo == __nRECTROUNDED
							oIndicator:aShapes[nTipo][nCamada][nShape][4] := nTopoAtu
							oIndicator:aShapes[nTipo][nCamada][nShape][6] := nAltuAtu
							oIndicator:aShapes[nTipo][nCamada][nShape][7] := cColor
							oIndicator:aShapes[nTipo][nCamada][nShape][9] := cColor
						ElseIf nTipo == __nARC
							oIndicator:aShapes[nTipo][nCamada][nShape][6] := cColor
						EndIf
					EndIf
				EndIf
			Next nZ
		EndIf
	Else
		//--------------------------------------------------
		// Estilos que utilizem porcentagens padr�es
		//--------------------------------------------------

		// Quantidade de Barras por Se��o
		nBarsSec := ( oIndicator:nBars / oIndicator:nMarcads )

		// Se��o Total
		nSecTotal := ( (nFinal - nInicial) / oIndicator:nMarcads )

		// Sabendo ent�o qual o valor total (m�ximo) de cada se��o, calculamos agora em qual das se��es (1,2,3...) o Valor desejado se encontra
		nSecAtual := ( (nValue - nInicial) / nSecTotal )

		// Define a posi��o final da barra
		nPosBarra := (nSecAtual * nBarsSec)
		If cStyle == __cSSlider
			nPosBarra := oIndicator:nBars
		ElseIf cStyle $ (__cSSemafo + "/" + __cSPizza)
			nPosBarra := Round(nPosBarra,0)
		EndIf

		// Define as barras para a atualiza��o das cores
		nBarInicio := ( oIndicator:nBars * oIndicator:aConfig[__nCfgAtua][1] )
		nBarFinal  := ( oIndicator:nBars * oIndicator:aConfig[__nCfgAtua][2] )
		If cStyle $ (__cSSlider + "/" + __cSSemafo)
			nBarInicio := Round(nBarInicio,0)
			nBarFinal  := Round(nBarFinal,0)
		EndIf

		// Atualiza as Cores
		For nX := 1 To oIndicator:nBars
			If ( nX <= nPosBarra ) .Or. ( lUsaAlpha )
				If nX <= nBarInicio // In�cio
					cColor := oIndicator:aColors[__nClrEsqu]
				ElseIf nX <= nBarFinal // Meio
					cColor := oIndicator:aColors[__nClrTopo]
				Else // Fim
					cColor := oIndicator:aColors[__nClrDire]
				EndIf
				If lUsaAlpha
					// Gradiente mais fraco (mais transparente)
					If cStyle == __cSSemafo .And. nX <> nPosBarra
						cColor += "100"
					ElseIf cStyle == __cSPizza .And. nX > nPosBarra
						cColor += "100"
					EndIf
				EndIf
			Else
				cColor := aCores[__nClrCent]
			EndIf

			For nZ := 1 To Len(oIndicator:aRefresh)
				If oIndicator:aRefresh[nZ][__nRfsHow] == __nRfsHSec .And. oIndicator:aRefresh[nZ][__nRfsAuxi] == nX
					nTipo   := oIndicator:aRefresh[nZ][__nRfsTipo]
					nCamada := oIndicator:aRefresh[nZ][__nRfsCama]

					nShape := aScan(oIndicator:aShapes[nTipo][nCamada], {|x| x[__nID] == oIndicator:aRefresh[nZ][__nRfsID] })
					If nShape > 0
						If nTipo == __nRECT .Or. nTipo == __nRECTROUNDED
							oIndicator:aShapes[nTipo][nCamada][nShape][7] := cColor
						ElseIf nTipo == __nELLIPSE
							oIndicator:aShapes[nTipo][nCamada][nShape][7] := cColor
							oIndicator:aShapes[nTipo][nCamada][nShape][8] := cColor
						ElseIf nTipo == __nARC
							oIndicator:aShapes[nTipo][nCamada][nShape][6] := cColor
							oIndicator:aShapes[nTipo][nCamada][nShape][7] := cColor
						ElseIf nTipo == __nPOLYGON
							oIndicator:aShapes[nTipo][nCamada][nShape][9] := cColor
						ElseIf nTipo == __nLINE
							oIndicator:aShapes[nTipo][nCamada][nShape][8] := cColor
						EndIf
					EndIf
				EndIf
			Next nZ
		Next nX

		// Para o estilo Slider, atualiza o ponteiro
		If cStyle == __cSSlider

			//--- Ponteiro
			nAuxValue := If(nValue > nFinal, nFinal, If(nValue < nInicial, nInicial, nValue))

			// Percentual que o valor atual ocupa dos valores do indicador
			nPorcAtual := ( (100*nAuxValue) / (nFinal-nInicial) )
			// Busca o espa�o equivalente ao percentual calculado
			nScan := aScan(oIndicator:aRefresh, {|x| x[__nRfsAuxi] == -1 })
			If nScan > 0
				nTipo   := oIndicator:aRefresh[nScan][__nRfsTipo]
				nCamada := oIndicator:aRefresh[nScan][__nRfsCama]

				nShape := aScan(oIndicator:aShapes[nTipo][nCamada], {|x| x[__nID] == oIndicator:aRefresh[nScan][__nRfsID] })
				If nShape > 0
					nPosPontei := ( ( (oIndicator:aShapes[nTipo][nCamada][nShape][5]) * nPorcAtual) / 100 )

					nPosPontei += oIndicator:aShapes[nTipo][nCamada][nShape][3]
				EndIf
			EndIf
			// Atualiza o ponteiro do Slider
			nScan := aScan(oIndicator:aRefresh, {|x| x[__nRfsAuxi] == -2 })
			If nScan > 0
				nTipo   := oIndicator:aRefresh[nScan][__nRfsTipo]
				nCamada := oIndicator:aRefresh[nScan][__nRfsCama]

				nShape := aScan(oIndicator:aShapes[nTipo][nCamada], {|x| x[__nID] == oIndicator:aRefresh[nScan][__nRfsID] })
				If nShape > 0
					nDiff := ( oIndicator:aShapes[nTipo][nCamada][nShape][5] - oIndicator:aShapes[nTipo][nCamada][nShape][3] )

					oIndicator:aShapes[nTipo][nCamada][nShape][3] := nPosPontei - nDiff // Left1
					oIndicator:aShapes[nTipo][nCamada][nShape][5] := nPosPontei // Left2
					oIndicator:aShapes[nTipo][nCamada][nShape][7] := nPosPontei + nDiff // Left3
				EndIf
			EndIf

		ElseIf cStyle == __cSPizza // Para o estilo Pizza, da foco na fatia atual

			aQuadrantes := Array(4)
			aQuadrantes[1] := 090
			aQuadrantes[2] := 180
			aQuadrantes[3] := 270
			aQuadrantes[4] := 360

			// Recebe o �ngulo que � representado pela posi��o da barra
			nPosPontei := ( (nPosBarra * 360) / oIndicator:nBars )
			For nX := 1 To oIndicator:nBars
				// Define a diferen�a para o efeito de Foco na Se��o
				nDiffVerti := 0
				nDiffHoriz := 0
				If nX == nPosBarra
					If nPosPontei <= aQuadrantes[1]

						If nPosPontei <= 40
							nDiffVerti := -1
							nDiffHoriz := 3
						ElseIf nPosPontei <= 80
							nDiffVerti := -2
							nDiffHoriz := 2
						Else
							nDiffVerti := -3
							nDiffHoriz := 0
						EndIf

					ElseIf nPosPontei <= aQuadrantes[2]


						If nPosPontei <= 130
							nDiffVerti := -3
							nDiffHoriz := 0
						ElseIf nPosPontei <= 170
							nDiffVerti := -2
							nDiffHoriz := -2
						Else
							nDiffVerti := -1
							nDiffHoriz := -3
						EndIf


					ElseIf nPosPontei <= aQuadrantes[3]


						If nPosPontei <= 220
							nDiffVerti := 1
							nDiffHoriz := -3
						ElseIf nPosPontei <= 260
							nDiffVerti := 2
							nDiffHoriz := -2
						Else
							nDiffVerti := 3
							nDiffHoriz := 0
						EndIf


					ElseIf nPosPontei <= aQuadrantes[4]


						If nPosPontei <= 310
							nDiffVerti := 3
							nDiffHoriz := 0
						ElseIf nPosPontei <= 350
							nDiffVerti := 2
							nDiffHoriz := 2
						Else
							nDiffVerti := 1
							nDiffHoriz := 3
						EndIf

					EndIf
				EndIf

				For nZ := 1 To Len(oIndicator:aRefresh)
					If oIndicator:aRefresh[nZ][__nRfsAuxi] == nX
						nTipo   := oIndicator:aRefresh[nZ][__nRfsTipo]
						nCamada := oIndicator:aRefresh[nZ][__nRfsCama]

						nShape := aScan(oIndicator:aShapes[nTipo][nCamada], {|x| x[__nID] == oIndicator:aRefresh[nZ][__nRfsID] })
						If nShape > 0
							nAuxShape := aScan(aAuxiliary, {|x| x[__nID] == oIndicator:aRefresh[nZ][__nRfsID] })
							If nAuxShape > 0
								If nTipo == __nARC
									oIndicator:aShapes[nTipo][nCamada][nShape][3] := ( aAuxiliary[nAuxShape][3] + nDiffHoriz )
									oIndicator:aShapes[nTipo][nCamada][nShape][4] := ( aAuxiliary[nAuxShape][4] + nDiffVerti )
								EndIf
							EndIf
						EndIf
					EndIf
				Next nZ
			Next nX

		EndIf
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSetZoom
Fun��o auxilixar da classe TNGIndicator:
Realiza o Incremento ou Decremento do Zoom.

@author Wagner Sobral de Lacerda
@since 23/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSetZoom(oIndicator, cTipoZoom)

	Local nZoom := oIndicator:GetZoom()

	// Defaults
	Default cTipoZoom := ""

	If cTipoZoom == "+"
		nZoom++
	ElseIf cTipoZoom == "-"
		nZoom--
	EndIf

	oIndicator:SetZoom(nZoom)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fDefScroll
Fun��o auxilixar da classe TNGIndicator:
Recria o Scroll do Indicador, caso exista.

@author Wagner Sobral de Lacerda
@since 23/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fDefScroll(oIndicator)

	Local lScroll := ValType(oIndicator:oScroll) == "O"

	// Verifica se utiliza scroll
	If !lScroll
		Return .F.
	EndIf

	// Deleta o Background
	oIndicator:DeleteBackgrd()

	// Deleta todos os Shapes
	oIndicator:DeleteShapes()

	// Deleta os Objetos e o pr�prio TPaintPanel
	oIndicator:oTPPanel:ClearAll()
	oIndicator:oTPPanel:FreeChildren()
	MsFreeObj(oIndicator:oTPPanel)

	oIndicator:nIDShape := 0

	// Deleta os Objetos e o pr�prio Scroll
	oIndicator:oScroll:FreeChildren()
	MsFreeObj(oIndicator:oScroll)

	// Cria o Scroll
	oIndicator:oScroll := TScrollBox():New(oIndicator:oParent, 0, 0, 0, 0, .T., .T., .T.)
	oIndicator:oScroll:nClrPane := CLR_WHITE
	oIndicator:oScroll:Align := CONTROL_ALIGN_ALLCLIENT
	oIndicator:oScroll:CoorsUpdate()

	//--------------------------------------------------
	// TPaintPanel com Scroll
	//--------------------------------------------------
	oIndicator:oTPPanel := TPaintPanel():New(000, 000, oIndicator:nWidth, oIndicator:nHeight, oIndicator:oScroll)
	oIndicator:oTPPanel:CoorsUpdate()

	// Cria o Background
	oIndicator:SetBackgrd()
	oIndicator:Indicator() // Desenha os shapes (s� existir� o Background)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fBlackPanel
Fun��o auxilixar da classe TNGIndicator:
Recria o Scroll do Indicador, caso exista.

@author Wagner Sobral de Lacerda
@since 23/02/2012

@param oBlackPanel
	Objeto do Painel Preto * Obrigat�rio
@param lVisible
	Indica a visibilidade do Painel * Obrigat�rio
	   .T. - Vis�vel
	   .F. - Invis�vel
	Default: .T.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fBlackPanel(oBlackPanel, lVisible)

	// Vari�vel da WINDOW PAI
	Local oWndPai := GetWndDefault()

	// Defaults
	Default lVisible := .T.

	// Se n�o existir, cria o objeto
	If ValType(oBlackPanel) <> "O"
		oBlackPanel := TPanel():New(0, 0, , oWndPai, , , , , SetTransparentColor(CLR_BLACK,70), oWndPai:nClientWidth, oWndPai:nClientHeight, .F., .F.)
	EndIf

	// Define visibilidade
	If lVisible
		oBlackPanel:Show()
	Else
		oBlackPanel:Hide()
	EndIf

Return .T.

/*/
############################################################################################
##                                                                                        ##
## FUN��ES AUXILIARES PARA A CONFIGURA��O DA CLASSE                                       ##
##                                                                                        ##
############################################################################################
/*/

//---------------------------------------------------------------------
/*/{Protheus.doc} fCfgConfir
Fun��o auxilixar da classe TNGIndicator:
Confirma��o da tela de Configura��o.

@author Wagner Sobral de Lacerda
@since 21/02/2012

@param oIndicOrig
	Objeto do Indicador Original * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCfgConfir(oIndicOrig)

	Local aCompara := {}
	Local nCompara := 0, nIndic := 0
	Local nX := 0

	Local aAuxiliar := {}

	Local cMsg  := ""
	Local lDiff := .F.

	// Atributos B�sicos
	If oIndicOrig:GetStyle() <> oCfgIndPrw:GetStyle() .Or. oIndicOrig:GetContent() <> oCfgIndPrw:GetContent()
		lDiff := .T.
	EndIf

	If !lDiff
		// Configura��es (apenas as porcentagens atuais)
		aAdd(aCompara, { {}, {} })
		For nIndic := 1 To 2
			aAuxiliar := aClone( If(nIndic == 1, oIndicOrig:GetConfig()[__nCfgVals], oCfgIndPrw:GetConfig()[__nCfgVals]) )

			For nX := 1 To Len(aAuxiliar)
				aAdd(aCompara[1][nIndic], aAuxiliar[nX][2] )
			Next nX
		Next nIndic

		// Cores
		aAdd(aCompara, {aClone( oIndicOrig:GetColors()  ), aClone( oCfgIndPrw:GetColors()  )})
		// Descri��o
		aAdd(aCompara, {aClone( oIndicOrig:GetDesc()    ), aClone( oCfgIndPrw:GetDesc()    )})
		// Outros
		aAdd(aCompara, {aClone( oIndicOrig:GetOthers()  ), aClone( oCfgIndPrw:GetOthers()  )})
		// Sombreamentos
		aAdd(aCompara, {aClone( oIndicOrig:GetShadows() ), aClone( oCfgIndPrw:GetShadows() )})
		// Textos
		aAdd(aCompara, {aClone( oIndicOrig:GetTexts()   ), aClone( oCfgIndPrw:GetTexts()   )})
		// Valores
		aAdd(aCompara, {aClone( oIndicOrig:GetVals()    ), aClone( oCfgIndPrw:GetVals()    )})

		// Verifica se houveram altera��es nas configura��es do Indicador
		For nCompara := 1 To Len(aCompara)
			If Len(aCompara[nCompara][1]) <> Len(aCompara[nCompara][2])
				lDiff := .T.
			Else
				For nX := 1 To Len(aCompara[nCompara][1])
					// Verifica das duas formas porque as vezes n�o funciona quando comparando uma stringe de tamanho maior com uma de tamanho menor ou vice-versa
					If aCompara[nCompara][1][nX] <> aCompara[nCompara][2][nX] .Or. aCompara[nCompara][2][nX] <> aCompara[nCompara][1][nX]
						lDiff := .T.
						Exit
					EndIf
				Next nX
			EndIf

			If lDiff
				Exit
			EndIf
		Next nX
	EndIf

	// Se h� diferen�a nos dados
	If lDiff
		// Define a mensagem para o usu�rio
		cMsg += STR0059 + Space(1) //"Se confirmar as altera��es, o Indicador ter� suas configura��es atualizadas"
		cMsg += STR0060 + Space(1) + STR0034 + Space(1) + STR0061 //"de acordo com a" ## "Pr�-Visualiza��o" ## "apresentada."
		cMsg += CRLF + CRLF
		cMsg += STR0062 //"Deseja confirmar?"

		// Confirma altera��es?
		If !MsgYesNo(cMsg, STR0055) //"Aten��o"
			Return .F.
		EndIf

		// Copia os dados do Indicador
		oCfgIndPrw:CopyTo(oIndicOrig)
	EndIf

	// Encerra do Dialog
	oDlgConfig:End()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fCfgConfir
Fun��o auxilixar da classe TNGIndicator:
Canelamento da tela de Configura��o.

@author Wagner Sobral de Lacerda
@since 21/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fCfgCancel()

	// Encerra do Dialog
	oDlgConfig:End()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadCfg
Fun��o auxilixar da classe TNGIndicator:
Carrega a tela de Configura��o.

@author Wagner Sobral de Lacerda
@since 15/02/2012

@param cNewStyle
	Indica o novo estilo do indicador * Opcional
	Default: "" (n�o ir� recarregar)
@param lForceLoad
	Indica se deve for�ar o recarregamento do indicador * Opcional
	   .T. - For�a
	   .F. - N�o for�a, e sim verifica se deve recarregar
	Default: .F.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fLoadCfg(cNewStyle, lForceLoad)

	Local cOldStyle := ""

	// Defaults
	Default cNewStyle  := ""
	Default lForceLoad := .F.

	If ( ValType(oCfgIndPrw) == "O" .And. !Empty(cNewStyle) ) .Or. lForceLoad

		cOldStyle := oCfgIndPrw:GetStyle()
		cNewStyle := If(Empty(cNewStyle), cOldStyle, cNewStyle)

		If cOldStyle <> cNewStyle
			// Atribui o novo Estilo
			oCfgIndPrw:SetStyle(cNewStyle)
		EndIf

		// Recarrega os pain�is de configura��o
		MsgRun(STR0063, STR0064, {|| fIndReload() }) //"Recarregando..." ## "Aguarde..."
	EndIf

	// Inicializa as defini��es das se��es
	fSecSelect()
	fClrSelect()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fLoadVars
Fun��o auxilixar da classe TNGIndicator:
Carrega as vari�veis Private de configura��o.

@author Wagner Sobral de Lacerda
@since 15/02/2012

@param oIndicator
	Objeto do Indicador * Obrigat�rio
@param lOnlyAtu
	Apenas recarrega as vari�veis * Opcional
	Default: .F.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fLoadVars(oIndicator, lOnlyAtu)

	Local aValores := aClone( oIndicator:GetVals() )
	Local aSombras := aClone( oIndicator:GetShadows() )
	Local aFields  := aClone( oIndicator:GetFields() )
	Local cStyle   := oIndicator:GetStyle()

	// Defaults
	Default lOnlyAtu := .F.

	If !lOnlyAtu
		// Carrega as vari�veis de 'Indicador'
		cIndTitulo := PADR(oIndicator:GetTexts()[__nTxtTitu], aFields[__nFldTitl][2], " ")
		cIndSubtit := PADR(oIndicator:GetTexts()[__nTxtSubt], aFields[__nFldSubt][2], " ")
		cIndLegen1 := PADR(oIndicator:GetDesc()[__nDesLeg1], aFields[__nFldLeg1][2], " ")
		cIndLegen2 := PADR(oIndicator:GetDesc()[__nDesLeg2], aFields[__nFldLeg2][2], " ")
		cIndLegen3 := PADR(oIndicator:GetDesc()[__nDesLeg3], aFields[__nFldLeg3][2], " ")

		// Carrega as vari�veis de 'Valores' (apenas num�ricos)
		nVlsMaxVls := Len(aValores)

		nVlsVal01 := If(nVlsMaxVls >= 1, aValores[1], 0)
		nVlsVal02 := If(nVlsMaxVls >= 2, aValores[2], 0)
		nVlsVal03 := If(nVlsMaxVls >= 3, aValores[3], 0)
		nVlsVal04 := If(nVlsMaxVls >= 4, aValores[4], 0)
		nVlsVal05 := If(nVlsMaxVls >= 5, aValores[5], 0)
		nVlsVal06 := If(nVlsMaxVls >= 6, aValores[6], 0)
		nVlsVal07 := If(nVlsMaxVls >= 7, aValores[7], 0)

		// Carrega as vari�veis de 'Se��es'
		aSecSecao := {STR0008, STR0010} //"Se��o M�nima" ## "Se��o M�xima"
		nSecSecao := 1
	EndIf

	// Carrega/Recarrega os valores Num�rico e em Porcentagem das 'Se��es'
	nSecValMin := oIndicator:aConfig[__nCfgVals][1][1]
	nSecPorMin := oIndicator:aConfig[__nCfgVals][1][2]

	nSecValMax := oIndicator:aConfig[__nCfgVals][2][1]
	nSecPorMax := oIndicator:aConfig[__nCfgVals][2][2]

	nSecValTmp := If(nSecSecao == 1, nSecValMin, nSecValMax)
	nSecPorTmp := If(nSecSecao == 1, nSecPorMin, nSecPorMax)

	If !lOnlyAtu
		// Carrega as vari�veis de 'Cores'
		aClrArea := {STR0065, STR0066, STR0067, STR0068} //"Se��es Principais" ## "Valores" ## "Textos" ## "Complementares"
		If cStyle $ (__cSVeComu + "/" + __cSSlider)
			aAdd(aClrArea, STR0069) //"Ponteiro"
		EndIf
		nClrArea := 1

			aClrAtuali := {}

			// �rea: Se��es
			aClrArea01 := {STR0008, STR0009, STR0010} //"Se��o M�nima" ## "Se��o Intermedi�ria" ## "Se��o M�xima"
			aAdd(aClrAtuali, {__nClrEsqu, __nClrTopo, __nClrDire})
			nClrArea01 := 1

			// �rea: Valores
			If cStyle == __cSVeComu
				aClrArea02 := {STR0070, STR0071, STR0072, STR0073} //"Valor Atual" ## "Fundo do Valor Atual" ## "Valores nos Marcadores" ## "Fundo dos Marcadores"
				aAdd(aClrAtuali, {__nClrValF, __nClrValB, __nClrMarF, __nClrMarB})
			ElseIf cStyle == __cSVeSecc
				aClrArea02 := {STR0070, STR0071, STR0072} //"Valor Atual" ## "Fundo do Valor Atual" ## "Valores nos Marcadores"
				aAdd(aClrAtuali, {__nClrValF, __nClrValB, __nClrMarF})
			Else
				aClrArea02 := {STR0070, STR0072} //"Valor Atual" ## "Valores nos Marcadores"
				aAdd(aClrAtuali, {__nClrValF, __nClrMarF})
			EndIf
			nClrArea02 := 1

			// �rea: Textos
			aClrArea03 := {STR0074, STR0007} //"T�tulo do Indicador" ## "Subt�tulo"
			aAdd(aClrAtuali, {__nClrTitF, __nClrSubF})
			nClrArea03 := 1

			// �rea: Complementares
			If cStyle $ (__cSVeComu + "/" + __cSVeSecc)
				aClrArea04 := {STR0075, STR0076, STR0077} //"Fundo do Indicador" ## "Contorno do Indicador" ## "Gradiente das Bordas"
				aAdd(aClrAtuali, {__nClrCent, __nClrCont, __nClrFade})
			ElseIf cStyle $ (__cSPirami + "/" + __cSRadar + "/" + __cSTeia)
				aClrArea04 := {STR0075} //"Fundo do Indicador"
				aAdd(aClrAtuali, {__nClrCent})
			ElseIf cStyle == __cSSlider
				aClrArea04 := {STR0076} //"Contorno do Indicador"
				aAdd(aClrAtuali, {__nClrCont})
			ElseIf cStyle == __cSSemafo
				aClrArea04 := {STR0075, STR0076, STR0078, STR0079} //"Fundo do Indicador" ## "Contorno do Indicador" ## "Preenchimento dos Contornos" ## "Fundo da Sinaliza��o"
				aAdd(aClrAtuali, {__nClrCent, __nClrCont, __nClrPntC, __nClrPntS})
			ElseIf cStyle == __cSPizza
				aClrArea04 := {STR0075, STR0076, STR0080} //"Fundo do Indicador" ## "Contorno do Indicador" ## "Detalhes sobre as fatias"
				aAdd(aClrAtuali, {__nClrCent, __nClrCont, __nClrPntS})
			ElseIf cStyle == __cSTermom
				aClrArea04 := {STR0075, STR0076, STR0081} //"Fundo do Indicador" ## "Contorno do Indicador" ## "Contorno do Term�metro"
				aAdd(aClrAtuali, {__nClrCent, __nClrCont, __nClrMarB})
			Else
				aClrArea04 := {STR0075, STR0076} //"Fundo do Indicador" ## "Contorno do Indicador"
				aAdd(aClrAtuali, {__nClrCent, __nClrCont})
			EndIf
			nClrArea04 := 1

			// �rea: Ponteiro
			If cStyle == __cSVeComu
				aClrArea05 := {STR0069, STR0082} //"Ponteiro" ## "Centro"
				aAdd(aClrAtuali, {__nClrPntS, __nClrPntC})
			ElseIf cStyle == __cSSlider
				aClrArea05 := {STR0069, STR0083} //"Ponteiro" ## "Ponte"Contorno"iro"
				aAdd(aClrAtuali, {__nClrPntS, __nClrPntC})
			EndIf
			nClrArea05 := 1

		lClrSomCen := aSombras[__nShwCent]
		lClrSomInf := aSombras[__nShwInfe]
		lClrSomAux := aSombras[__nShwAuxi]
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fConfigInd
Fun��o auxilixar da classe TNGIndicator:
Configura��es Gerais do Indicador.

@author Wagner Sobral de Lacerda
@since 14/02/2012

@param oPnlPai
	Indica o Painel Pai deste objeto * Obrigat�rio
@param oIndicator
	Objeto do Indicador original * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fConfigInd(oPnlPai, oIndicator)

	// Vari�veis do Indicador
	Local aFields := aClone( oIndicator:GetFields() )

	// Vari�veis auxliares
	Local oScroll
	Local nModPorLin := 0, nModLinAtu := 0
	Local nX := 0, nAT := 0

	Local oFntTitle  := TFont():New(, , , , .T.)

	Local cPicTITULO := "", cTitTITULO := "", nGetTITULO := 0
	Local cPicSUBTIT := "", cTitSUBTIT := "", nGetSUBTIT := 0

	Local aImgModelos := {}
	Local cAuxClick := ""
	Local cAuxImg   := ""
	Local cAuxSay   := ""

	Local nTmpTop := 0
	Local nLinha  := 0
	Local nColuna := 0

	Local lChange := TZ9->TZ9_PROPRI == "2"

	//----------------------------------------
	// Recebe os campos do Dicion�rio
	//----------------------------------------
	// MODELO
	aIndModelo := StrTokArr(aFields[__nFldModl][5], ";")
	nX := 0
	aEval(aIndModelo, {|x| nX++, aIndModelo[nX] := AllTrim(x) })

	// TIPO DE CONTE�DO
	aIndTipCon := StrTokArr(aFields[__nFldTipC][5], ";")
	nX := 0
	aEval(aIndTipCon, {|x| nX++, aIndTipCon[nX] := AllTrim(x) })

	// T�TULO
	cTitTITULO := AllTrim( aFields[__nFldTitl][1] )
	cPicTITULO := AllTrim( aFields[__nFldTitl][4] )
	nGetTITULO := CalcFieldSize("C", aFields[__nFldTitl][2],aFields[__nFldTitl][3], cPicTITULO, cTitTITULO)

	// SUBT�TULO
	cTitSUBTIT := AllTrim( aFields[__nFldSubt][1] )
	cPicSUBTIT := AllTrim( aFields[__nFldSubt][4] )
	nGetSUBTIT := CalcFieldSize("C", aFields[__nFldSubt][2],aFields[__nFldSubt][3], cPicSUBTIT, cTitSUBTIT)

	//--------------------
	// Monta o Painel
	//--------------------

	// Mensagem
	@ 005,015 SAY OemToAnsi(STR0084) COLOR CLR_BLUE OF oPnlPai PIXEL //"Defina as configura��es b�sicas do Indicador, selecionando o seu estilo,"
	@ 015,005 SAY OemToAnsi(STR0085) COLOR CLR_BLUE OF oPnlPai PIXEL //"tipo de conte�do e descri��es."

	// GroupBox
	nTmpTop := (nTopIni+050)
	TGroup():New(nTopIni, nLeftIni, nTmpTop, nLeftEnd, OemToAnsi(STR0086), oPnlPai, , , .T.) //"Defina os T�tulos do Indicador"

		nColuna := (nLeftIni+010)

		// T�tulo
		nLinha := (nTopIni+015)
		@ nLinha,nColuna SAY OemToAnsi(cTitTITULO + ":") FONT oFntTitle COLOR CLR_BLACK OF oPnlPai PIXEL
		oIndTitulo := TGet():New((nLinha-001), (nColuna+040), {|u| If(PCount() > 0, cIndTitulo := u, cIndTitulo) }, oPnlPai, nGetTITULO, 008, "",;
									{|| If(!IsInCallStack("FCFGCANCEL"), oCfgIndPrw:SetTexts({cIndTitulo, cIndSubtit, }), .T.) }, , , ,;
					 				.F., , .T./*lPixel*/, , .F., {|| lChange }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cIndTitulo", , , , .F./*lHasButton*/)
		oIndTitulo:bHelp := {|| ShowHelpCpo(STR0087,; //"Titulo"
								{STR0088},2,; //"Defina o T�tulo do Indicador."
								{},2)}

		// Subt�tulo
		nLinha += 015
		@ nLinha,nColuna SAY OemToAnsi(cTitSUBTIT + ":") FONT oFntTitle COLOR CLR_BLACK OF oPnlPai PIXEL
		oIndSubtit := TGet():New((nLinha-001), (nColuna+040), {|u| If(PCount() > 0, cIndSubtit := u, cIndSubtit) }, oPnlPai, nGetSUBTIT, 008, "",;
									{|| If(!IsInCallStack("FCFGCANCEL"), oCfgIndPrw:SetTexts({cIndTitulo, cIndSubtit, }), .T.) }, , , ,;
					 				.F., , .T./*lPixel*/, , .F., {|| lChange }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cIndSubtit", , , , .F./*lHasButton*/)
		oIndSubtit:bHelp := {|| ShowHelpCpo(STR0089,; //"Subtitulo"
								{STR0090},2,; //"Defina o Subt�tulo do Indicador."
								{},2)}

		// GroupBox
		nLinha  := (nTopIni+005)
		nColuna := (nLeftEnd-065)
		TGroup():New(nLinha, nColuna, (nTmpTop-005), (nLeftEnd-005), OemToAnsi(STR0013), oPnlPai, , , .T.) //"Conte�do"

			// ComboBox
			cIndTipCon := oIndicator:GetContent()
			oIndTipCon := TComboBox():New((nLinha+015), (nColuna+005), {|u| If(PCount() > 0, cIndTipCon := u , cIndTipCon) },;
											aIndTipCon, 050, 012, oPnlPai, , {|| fLoadCfg(, .T.) };
											, , , , .T., , , , { || lChange }, , , , , "cIndTipCon")
			oIndTipCon:bHelp := {|| ShowHelpCpo(STR0091,; //"Conteudo"
								{STR0092},2,; //"Selecione o Tipo de Conte�do do Indicador."
								{},2)}

	// GroupBox
	nTmpTop += 15
	TGroup():New(nTmpTop, nLeftIni, (nTmpTop+100), nLeftEnd, OemToAnsi(STR0093), oPnlPai, , , .T.) //"Escolha o Estilo do Indicador"

		// ScrollBox para os Modelos de Indicador
		oScroll := TScrollBox():New(oPnlPai, nTmpTop+010, nLeftIni+005, ((nTmpTop+100)-(nTmpTop+010))-005, (nLeftEnd-015), .T., .T., .T.)
		oScroll:nClrPane := CLR_WHITE
		oScroll:CoorsUpdate()
			// Imagens dos modelos
			aImgModelos := {"ng_indic_graf_model_1", "ng_indic_graf_model_2", "ng_indic_graf_model_3", ;
							"ng_indic_graf_model_4", "ng_indic_graf_model_5", "ng_indic_graf_model_6", ;
							"ng_indic_graf_model_7", "ng_indic_graf_model_8", "ng_indic_graf_model_9", ;
							"ng_indic_graf_model_A", "ng_indic_graf_model_B"}
			// Op��es de Indicador
			nModPorLin := Int( ( (nLeftEnd-015)-(nLeftIni+005) ) / 30 )
			nModLinAtu := 0

			nLinha  := 010
			For nX := 1 To Len(aIndModelo)

				nModLinAtu++
				If nModLinAtu > nModPorLin
					nLinha += 65
					nModLinAtu := 1
				EndIf

				If nModLinAtu == 1
					nColuna := 010
				Else
					nColuna += 065
				EndIf

				nAT := AT("=",aIndModelo[nX])
				cAuxClick := "{|| fLoadCfg('" + AllTrim( SubStr(aIndModelo[nX],1,(nAT-1)) ) + "') }"
				cAuxImg   := "'" + If(Len(aImgModelos) >= nX, aImgModelos[nX], "ng_config") + "'"
				cAuxSay   := "'" + OemToAnsi(aIndModelo[nX]) + "'"

				TBtnBmp2():New(nLinha, nColuna, 55, 55, &(cAuxImg), , , , &(cAuxClick), oScroll, &(cAuxSay))
			Next nX

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fIndReload
Fun��o auxilixar da classe TNGIndicator:
Recarrega a tela de Configura��es.

@author Wagner Sobral de Lacerda
@since 15/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fIndReload()

	// Seta o Conte�do
	oCfgIndPrw:SetContent( SubStr(cIndTipCon,1,1) )

	// Recerrega as vari�veis de acordo com o Preview
	fLoadVars(oCfgIndPrw)

	// Recarrega o Painel 'Valores' com o Preview
	oCfgPnlVls:FreeChildren()
	fConfigVls(@oCfgPnlVls, oCfgIndPrw)

	// Recarrega o Painel 'Se��es' com o Preview
	oCfgPnlSec:FreeChildren()
	fConfigSec(@oCfgPnlSec, oCfgIndPrw)

	// Recarrega o Painel 'Cores' com o Preview
	oCfgPnlClr:FreeChildren()
	fConfigClr(@oCfgPnlClr, oCfgIndPrw)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fConfigVls
Fun��o auxilixar da classe TNGIndicator:
Configura��es dos Valores dos Marcadores do Indicador.

@author Wagner Sobral de Lacerda
@since 15/02/2012

@param oPnlPai
	Indica o Painel Pai deste objeto * Obrigat�rio
@param oIndicator
	Objeto do Indicador original * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fConfigVls(oPnlPai, oIndicator)

	// Define vari�veis
	Local nInd		:= 0
	Local cPicture  := ""
	Local cAuxPADL  := ""
	Local cAuxTitulo:= ""
	Local cAuxVar   := ""
	Local cAuxObjeto:= ""
	Local cAuxSetGet:= ""
	Local cAuxWhen  := ""
	Local cAuxHelp1 := ""
	Local cAuxHelp2 := ""
	Local cCampo    := ""
	Local nTmpTop   := 0
	Local nLinha    := 0
	Local nColuna   := 0

	//--------------------
	// Monta o Painel
	//--------------------

	// Mensagem
	@ 005,015 SAY OemToAnsi(STR0094) COLOR CLR_BLUE OF oPnlPai PIXEL //"Defina as configura��es dos valores do Indicador, selecionando"
	@ 015,005 SAY OemToAnsi(STR0095) COLOR CLR_BLUE OF oPnlPai PIXEL //"os valores apresentados nos marcadores."

	// GroupBox
	nTmpTop := (nTopIni+145)
	TGroup():New(nTopIni, nLeftIni, nTmpTop, nLeftEnd, OemToAnsi(STR0096), oPnlPai, , , .T.) //"Selecione os Valores"

		// Sele��o dos Valores
		nLinha  := nTopIni
		nColuna := ( ((nLeftEnd - nLeftIni) / 2) - 050) // Centro
		For nInd := 1 To 7

			cAuxPADL   := PadL(nInd, 2, "0")
			cCampo     := "TZ9_VAL" + cAuxPADL
			cAuxTitulo := "{|| OemToAnsi('" + STR0056 + " " + cAuxPADL + ":') }" //"Valor"
			cAuxVar    := "'" + "nVlsVal" + cAuxPADL + "'"
			cPicture   := Posicione("SX3", 2, cCampo, "X3_PICTURE")
			cAuxObjeto := "oVlsVal" + cAuxPADL
			cAuxSetGet := "{|u| If(PCount() > 0, nVlsVal" + cAuxPADL + " := u, nVlsVal" + cAuxPADL + ") }"
			cAuxWhen   := "{|| nVlsMaxVls >= " + cValToChar(nInd) + " }"

			cAuxHelp1 := STR0056 + " " + cAuxPADL //"Valor"
			cAuxHelp2 := STR0056 + " " + cAuxPADL + " " + STR0097 + "." //"Valor" ## "apresentado no Indicador"

			nLinha += 15
			TSay():New(nLinha, nColuna, &(cAuxTitulo), oPnlPai,,,,,, .T., CLR_BLACK, CLR_WHITE, 040, 010)

			&(cAuxObjeto) := TGet():New((nLinha-001), (nColuna+040), &(cAuxSetGet), oPnlPai, 060, 008, cPicture, {|| If(!IsInCallStack("FCFGCANCEL"), Positivo(), .T.) },;
			                            ,,, .F.,, .T.,, .F., &(cAuxWhen), .F., .F., , .F., .F., "", &(cAuxVar),,,, .T.)

			&(cAuxObjeto):bHelp := {|| ShowHelpCpo(&(cAuxHelp1), {&(cAuxHelp2)}, 2, {}, 2)}

		Next nInd

		// Botao de aplicar os Valores no Preview
		TButton():New((nTmpTop-020), nColuna, STR0098, oPnlPai, {|| fVlsAplica() },; //"Aplicar"
						030, 012, , , .F., .T., .F., , .F., , , .F.)

		// Botao para calcular a M�dia dos Valores selecionados
		TButton():New((nTmpTop-020), (nColuna+050), STR0099, oPnlPai, {|| fVlsCalcMe() },; //"Calcular M�dia"
						050, 012, , , .F., .T., .F., , .F., , , .F.)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fVlsAplica
Fun��o auxilixar da classe TNGIndicator:
Aplica os Valores no Indicador.

@author Wagner Sobral de Lacerda
@since 15/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fVlsAplica()

	Local cStyle := oCfgIndPrw:GetStyle()

	// Define o Array de Valores
	Local aSetVals := {nVlsVal01, nVlsVal02, nVlsVal03, nVlsVal04, nVlsVal05}

	If cStyle $ (__cSVeComu + "/" + __cSVeSecc)
		aAdd(aSetVals, nVlsVal06)
		aAdd(aSetVals, nVlsVal07)
	EndIf

	If !oCfgIndPrw:SetVals(aSetVals, .T.)
		Return .F.
	EndIf
	oCfgIndPrw:SetValue( aTail(oCfgIndPrw:GetVals()) )

	// Atualiza as vari�veis
	fLoadVars(oCfgIndPrw, .T.)
	oSecValor:Refresh()
	oSecPorce:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fVlsCalcMe
Fun��o auxilixar da classe TNGIndicator:
Calcula a M�dia dos Valores, deixando-os com uma mesma raz�o matem�tica.

@author Wagner Sobral de Lacerda
@since 15/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fVlsCalcMe()

	Local lHoras := ( oCfgIndPrw:GetContent() == "2" ) // Em Horas?

	Local nMinimo := 0
	Local nMaximo := 0
	Local nRazao  := 0

	Local aAuxVls := {}
	Local cAuxVar := ""
	Local nX

	// Recebe os valores informados
	aAuxVls := Array(7)
	For nX := 1 To 7
		cAuxVar     := "nVlsVal" + PADL(nX, 2, "0")
		aAuxVls[nX] := &(cAuxVar)
	Next nX

	// Recebe os valores de M�ximo e M�nimo
	nMinimo := aAuxVls[1]
	nMaximo := aAuxVls[nVlsMaxVls]

	// Valida��o B�sica dos Valores
	If nMinimo < 0
		fShowMsg(STR0100) //"O valor selecionado como m�nimo n�o pode ser negativo."
		Return .F.
	ElseIf nMaximo <= nMinimo
		fShowMsg(STR0101) //"O valor selecionado como m�ximo deve ser superior ao m�nimo."
		Return .F.
	EndIf

	//--------------------
	// Calcula a M�dia
	//--------------------
	nRazao := ( (nMaximo - nMinimo) / (nVlsMaxVls-1) )

	nVlsVal01 := nMinimo
	nVlsVal02 := If(nVlsMaxVls >= 2, ( nVlsVal01 + nRazao ), 0)
	nVlsVal03 := If(nVlsMaxVls >= 3, ( nVlsVal02 + nRazao ), 0)
	nVlsVal04 := If(nVlsMaxVls >= 4, ( nVlsVal03 + nRazao ), 0)
	nVlsVal05 := If(nVlsMaxVls >= 5, ( nVlsVal04 + nRazao ), 0)
	nVlsVal06 := If(nVlsMaxVls >= 6, ( nVlsVal05 + nRazao ), 0)
	nVlsVal07 := If(nVlsMaxVls >= 7, ( nVlsVal06 + nRazao ), 0)

	// Atualiza os objetos dos valores com o novo conte�do
	oVlsVal01:Refresh()
	oVlsVal02:Refresh()
	oVlsVal03:Refresh()
	oVlsVal04:Refresh()
	oVlsVal05:Refresh()
	oVlsVal06:Refresh()
	oVlsVal07:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fConfigSec
Fun��o auxilixar da classe TNGIndicator:
Configura��es das Se��es do Indicador.

@author Wagner Sobral de Lacerda
@since 15/02/2012

@param oPnlPai
	Indica o Painel Pai deste objeto * Obrigat�rio
@param oIndicator
	Objeto do Indicador original * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fConfigSec(oPnlPai, oIndicator)

	// Define vari�veis
	Local cPicture := __cPictNum__

	Local oObjTmp := Nil

	Local nTmpTop := 0
	Local nTmpWid := 0, nTmpHei := 0
	Local nLinha  := 0
	Local nColuna := 0

	//--------------------
	// Monta o Painel
	//--------------------

	// Mensagem
	@ 005,015 SAY OemToAnsi(STR0102) COLOR CLR_BLUE OF oPnlPai PIXEL //"Defina as configura��es das se��es do Indicador, selecionando"
	@ 015,005 SAY OemToAnsi(STR0103) COLOR CLR_BLUE OF oPnlPai PIXEL //"distribui��o de valores nas se��es."

	// GroupBox
	nTmpTop := (nTopIni+085)
	TGroup():New(nTopIni, nLeftIni, nTmpTop, nLeftEnd, OemToAnsi(STR0104), oPnlPai, , , .T.) //"Selecione a Se��o para configurar"

		// Op��es de Secao
		oSecSecao := TRadMenu():New((nTopIni+010), (nLeftIni+010), aSecSecao, , oPnlPai, , {|| fSecSelect() }, , ,;
									, , , 080, 012, , , , .T.)
		oSecSecao:bSetGet := {|u| If(PCount() > 0, nSecSecao := u, nSecSecao) }

		// GroupBox
		nLinha  := (nTopIni+005)
		nColuna := (nLeftEnd-065)
		TGroup():New(nLinha, nColuna, (nTopIni+040), (nLeftEnd-005), OemToAnsi(STR0105), oPnlPai, , , .T.) //"Sele��o Atual"

			nLinha  += 010
			nColuna += 005

			nTmpWid := (nLeftEnd-010) - nColuna
			nTmpHei := (nTopIni+035) - (nTopIni+016)

			// Fundo da Cor da Secao
			TPanel():New(nLinha, nColuna, , oPnlPai, , , , CLR_BLACK, CLR_BLACK, nTmpWid, nTmpHei)
			// Mostra a Cor da Secao atual
			oSecPanel := TPanel():New((nLinha+001), (nColuna+001), , oPnlPai, , , , CLR_BLACK, CLR_WHITE, (nTmpWid-002), (nTmpHei-002))

		// GroupBox
		nLinha  := (nTopIni+040)+005
		nColuna := (nLeftEnd-065)
		TGroup():New(nLinha, nColuna, (nTopIni+080), (nLeftEnd-005), OemToAnsi(STR0106), oPnlPai, , , .T.) //"Legendas"

			nLinha  += 015
			nColuna += 010

			// Botao para restaurar o Default
			TButton():New(nLinha, nColuna, STR0037, oPnlPai, {|| fSecLegend(oIndicator:GetFields()) },; //"Legenda"
							040, 012, , , .F., .T., .F., , .F., {|| .T. }, , .F.)

		// Mensagem
		@ (nTmpTop-035),(nLeftIni+010) SAY OemToAnsi(STR0107) COLOR CLR_GRAY OF oPnlPai PIXEL //"A Se��o Intermedi�ria (central) � atualizada de forma"
		@ (nTmpTop-025),(nLeftIni+005) SAY OemToAnsi(STR0108) COLOR CLR_GRAY OF oPnlPai PIXEL //"autom�tica, de acordo com a Se��o M�nima e M�xima"
		@ (nTmpTop-015),(nLeftIni+005) SAY OemToAnsi(STR0109) COLOR CLR_GRAY OF oPnlPai PIXEL //"selecionadas."

	// GroupBox
	nTmpTop += 15
	TGroup():New(nTmpTop, nLeftIni, (nTmpTop+065), nLeftEnd, OemToAnsi(STR0110), oPnlPai, , , .T.) //"Selecione a Distribui��o da Se��o"

		nColuna := (nLeftIni+010)

		// Mensagem
		nLinha := (nTmpTop+015)
		@ nLinha,nColuna SAY OemToAnsi(STR0056+":") OF oPnlPai PIXEL //"Valor"
		// GET do Valor
		oSecValor := TGet():New((nLinha-001), (nColuna+040), {|u| If(PCount() > 0, nSecValTmp := u, nSecValTmp) }, oPnlPai, 050, 008, cPicture,;
								{|| fSecValid(1) }/*bValid*/, , , , .F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/,;
				 				.F., .F., , .F./*lReadOnly*/, .F., "", "nSecValTmp", , , , .T./*lHasButton*/)
			oSecValor:bHelp := {|| ShowHelpCpo(STR0056,; //"Valor"
									{"Valor em que a se��o ser� posicionada no Indicador" + "."},2,;
									{},2)}

		// Mensagem
		nLinha += 015
		@ nLinha,nColuna SAY OemToAnsi(STR0111+":") OF oPnlPai PIXEL //"Porcentagem"
		// GET da Porcentagem
		oSecPorce := TGet():New((nLinha-001), (nColuna+040), {|u| If(PCount() > 0, nSecPorTmp := u, nSecPorTmp) }, oPnlPai, 050, 008, "@E 999.99 %",;
								{|| fSecValid(2) }/*bValid*/, , , , .F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/,;
				 				.F., .F., , .F./*lReadOnly*/, .F., "", "nSecPorTmp", , , , .T./*lHasButton*/)
			oSecPorce:bHelp := {|| ShowHelpCpo(STR0111,; //"Porcentagem"
									{STR0112},2,; //"Porcentagem que a se��o selecionada ocupar� no Indicador."
									{},2)}

		nLinha += 015

		// Botao MAIS (n�o � em Pixel)
		TBtnBmp2():New((nLinha+165), (nColuna+095), 27, 30, "mais" , , , , {|| fSecPluMin("+") }, oPnlPai, OemToAnsi(STR0113), {|| .T. }) //"Mais"

		// Botao MENOS (n�o � em Pixel)
		TBtnBmp2():New((nLinha+165), (nColuna+145), 27, 30, "menos", , , , {|| fSecPluMin("-") }, oPnlPai, OemToAnsi(STR0114), {|| .T. }) //"Menos"

		// Botao para restaurar o Default
		TButton():New(nLinha, (nLeftEnd-045), STR0115, oPnlPai, {|| fSecRest() },; //"Restaurar"
						040, 012, , , .F., .T., .F., , .F., {|| .T. }, , .F.)


Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSecLegend
Fun��o auxilixar da classe TNGIndicator:
Define a Legenda do Indicador Gr�fico.

@author Wagner Sobral de Lacerda
@since 28/08/2012

@param aFields
	Array com as defini��es dos campos do dicion�rio * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSecLegend(aFields)

	// Vari�veis da Janela
	Local oDlgLegend
	Local cDlgLegend := OemToAnsi(STR0037) //"Legenda"
	Local lDlgLegend := .F.
	Local oPnlLegend

	// Vari�veis auxiliares
	Local oTmpGet
	Local oFntBold := TFont():New(, , , , .T.)

	Local cTitLEGEN1, cPicLEGEN1, nGetLEGEN1
	Local cTitLEGEN2, cPicLEGEN2, nGetLEGEN2
	Local cTitLEGEN3, cPicLEGEN3, nGetLEGEN3
	Local nMaxGetLen := 250

	// Vari�veis da Legenda
	Private cNewLeg1 := cIndLegen1
	Private cNewLeg2 := cIndLegen2
	Private cNewLeg3 := cIndLegen3

	//------------------------------
	// Defini��es dos campos
	//------------------------------
	// LEGENDA 1
	cTitLEGEN1 := AllTrim( aFields[__nFldLeg1][1] )
	cPicLEGEN1 := AllTrim( aFields[__nFldLeg1][4] )
	nGetLEGEN1 := CalcFieldSize("C", aFields[__nFldLeg1][2],aFields[__nFldLeg1][3], cPicLEGEN1, cTitLEGEN1)
	If nGetLEGEN1 > nMaxGetLen
		nGetLEGEN1 := nMaxGetLen
	EndIf

	// LEGENDA 2
	cTitLEGEN2 := AllTrim( aFields[__nFldLeg2][1] )
	cPicLEGEN2 := AllTrim( aFields[__nFldLeg2][4] )
	nGetLEGEN2 := CalcFieldSize("C", aFields[__nFldLeg2][2],aFields[__nFldLeg2][3], cPicLEGEN2, cTitLEGEN2)
	If nGetLEGEN2 > nMaxGetLen
		nGetLEGEN2 := nMaxGetLen
	EndIf

	// LEGENDA 3
	cTitLEGEN3 := AllTrim( aFields[__nFldLeg3][1] )
	cPicLEGEN3 := AllTrim( aFields[__nFldLeg3][4] )
	nGetLEGEN3 := CalcFieldSize("C", aFields[__nFldLeg3][2],aFields[__nFldLeg3][3], cPicLEGEN3, cTitLEGEN3)
	If nGetLEGEN3 > nMaxGetLen
		nGetLEGEN3 := nMaxGetLen
	EndIf

	//--------------------
	// Monta Janela
	//--------------------
	DEFINE MSDIALOG oDlgLegend TITLE cDlgLegend FROM 0,0 TO 200,600 OF oMainWnd PIXEL

		// Painel pricipal do Dialog
		oPnlLegend := TPanel():New(01, 01, , oDlgLegend, , , , CLR_BLACK, CLR_WHITE, 100, 100, .F., .F.)
		oPnlLegend:Align := CONTROL_ALIGN_ALLCLIENT

			// GroupBox
			TGroup():New(005, 005, 085, (oPnlLegend:nClientWidth*0.50)-005, OemToAnsi(STR0120), oPnlLegend, , , .T.) //"Defina as Legendas"

			// Legenda: Se��o M�nima
			TSay():New(025, 010, {|| OemToAnsi(cTitLEGEN1+":") }, oPnlLegend, , oFntBold, , , , .T., CLR_BLACK, , 150, 012)
			oTmpGet := TGet():New(024, 090, {|u| If(PCount() > 0, cNewLeg1 := u, cNewLeg1)}, oPnlLegend, nGetLEGEN1, 008, cPicLEGEN1, {|| .T. }, CLR_BLACK, CLR_WHITE, ,;
					 				.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cNewLeg1", , , , .T./*lHasButton*/)
			oTmpGet:bHelp := {|| ShowHelpCpo(STR0037 + " 1",; //"Legenda"
									{STR0117},2,; //"Legenda da Se��o M�nima."
									{},2)}

			// Legenda: Se��o Intermedi�ria
			TSay():New(045, 010, {|| OemToAnsi(cTitLEGEN2+":") }, oPnlLegend, , oFntBold, , , , .T., CLR_BLACK, , 150, 012)
			oTmpGet := TGet():New(044, 090, {|u| If(PCount() > 0, cNewLeg2 := u, cNewLeg2)}, oPnlLegend, nGetLEGEN2, 008, cPicLEGEN2, {|| .T. }, CLR_BLACK, CLR_WHITE, ,;
					 				.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cNewLeg2", , , , .T./*lHasButton*/)
			oTmpGet:bHelp := {|| ShowHelpCpo(STR0037 + " 2",; //"Legenda"
									{STR0118},2,; //"Legenda da Se��o Intermedi�ria."
									{},2)}

			// Legenda: Se��o M�nima
			TSay():New(065, 010, {|| OemToAnsi(cTitLEGEN3+":") }, oPnlLegend, , oFntBold, , , , .T., CLR_BLACK, , 150, 012)
			oTmpGet := TGet():New(064, 090, {|u| If(PCount() > 0, cNewLeg3 := u, cNewLeg3)}, oPnlLegend, nGetLEGEN3, 008, cPicLEGEN3, {|| .T. }, CLR_BLACK, CLR_WHITE, ,;
					 				.F., , .T./*lPixel*/, , .F., {|| .T. }/*bWhen*/, .F., .F., , .F./*lReadOnly*/, .F., "", "cNewLeg3", , , , .T./*lHasButton*/)
			oTmpGet:bHelp := {|| ShowHelpCpo(STR0037 + " 3",; //"Legenda"
									{STR0119},2,; //"Legenda da Se��o M�xima."
									{},2)}

	ACTIVATE MSDIALOG oDlgLegend ON INIT EnchoiceBar(oDlgLegend, {|| lDlgLegend := .T., oDlgLegend:End() }, {|| lDlgLegend := .F., oDlgLegend:End() }) CENTERED

	// Se confirmou
	If lDlgLegend
		cIndLegen1 := cNewLeg1
		cIndLegen2 := cNewLeg2
		cIndLegen3 := cNewLeg3

		oCfgIndPrw:SetDesc({cIndLegen1, cIndLegen2, cIndLegen3})
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSecSelect
Fun��o auxilixar da classe TNGIndicator:
Seleciona a Se��o para configurar.

@author Wagner Sobral de Lacerda
@since 15/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSecSelect()

	Local aCores  := {}
	Local nSelCor := 0

	Local aClrRGB := {}
	Local nClrRGB := 0

	// Recebe as Configura��es de Cores do Indicador
	aCores := aClone( oCfgIndPrw:GetColors() )

	// Calcula a Cor em RGB
	nSelCor := If(nSecSecao == 1, __nClrEsqu, __nClrDire)

	aClrRGB := aClone( NGHEXRGB( SubStr(aCores[nSelCor],2) ) )
	nClrRGB := RGB( aClrRGB[1], aClrRGB[2], aClrRGB[3] )

	// Mostra a Cor
	oSecPanel:SetColor(, nClrRGB)

	// Atualiza o Valor da Se��o
	nSecValTmp := If(nSecSecao == 1, nSecValMin, nSecValMax)
	nSecPorTmp := If(nSecSecao == 1, nSecPorMin, nSecPorMax)

	oSecValor:Refresh()
	oSecPorce:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSecValid
Fun��o auxilixar da classe TNGIndicator:
Valida o Valor/Porcetagem atribu�dos para a Se��o.

@author Wagner Sobral de Lacerda
@since 15/02/2012

@param nCampo
	Qual o Campo que ser� validado * Obrigat�rio
	 1 - Valor Num�rico
	 2 - Porcentagem

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSecValid(nCampo)

	Local nValor := 0

	// Defaults
	Default nCampo := 0

	// Verifica se n�o est� no cancelamento da tela
	If IsInCallStack("FCFGCANCEL")
		Return .T.
	EndIf

	// Valida a Exist�ncia do campo, recebendo o valor a ser atribu�do para a se��o
	If nCampo == 1 // Valor Num�rico
		nValor := nSecValTmp
	ElseIf nCampo == 2 // Porcentagem
		nValor := nSecPorTmp
	Else
		Return .F.
	EndIf

	// Verifica se � positivo
	If !Positivo(nValor)
		Return .F.
	EndIf

	// Configura a se��o de com o valor do campo
	If !oCfgIndPrw:ConfigSecs(nSecSecao, nValor, nCampo)
		Return .F.
	EndIf
	oCfgIndPrw:Indicator(.T.)

	// Atualiza as vari�veis
	fLoadVars(oCfgIndPrw, .T.)
	oSecValor:Refresh()
	oSecPorce:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSecPluMin
Fun��o auxilixar da classe TNGIndicator:
Acrescenta ou Decrementa o Valor/Porcentagem da distribui��o da se��o.

@author Wagner Sobral de Lacerda
@since 15/02/2012

@param cPlusMinus
	Indica se � incremento ou decremento * Obrigat�rio
	 "+" - Incremento
	 "-" - Decremento

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSecPluMin(cPlusMinus)

	// Defaults
	Default cPlusMinus := ""

	If cPlusMinus == "+" // Incremento
		nSecPorTmp++
	ElseIf cPlusMinus == "-" // Decremento
		nSecPorTmp--
	EndIf

	// Adequa a Porcentagem
	If nSecPorTmp < 0
		nSecPorTmp := 0
	ElseIf nSecPorTmp > 100
		nSecPorTmp := 100
	EndIf

	// Configura a se��o de com o valor da Porcentagem
	If !fSecValid(2)
		Return .F.
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSecRest
Fun��o auxilixar da classe TNGIndicator:
Restaura a distribui��o padr�o das se��es.

@author Wagner Sobral de Lacerda
@since 15/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fSecRest()

	// Inicializa os valores Num�ricos e em Porcetagem das se��es
	oCfgIndPrw:ConfigSecs(1, __nPorMin__, 2) // Se��o M�nima
	oCfgIndPrw:ConfigSecs(2, __nPorMax__, 2) // Se��o M�xima
	oCfgIndPrw:Refresh()

	// Atualiza as vari�veis
	fLoadVars(oCfgIndPrw, .T.)
	oSecValor:Refresh()
	oSecPorce:Refresh()

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fConfigClr
Fun��o auxilixar da classe TNGIndicator:
Configura��es das Cores dos Componentes do Indicador.

@author Wagner Sobral de Lacerda
@since 17/02/2012

@param oPnlPai
	Indica o Painel Pai deste objeto * Obrigat�rio
@param oIndicator
	Objeto do Indicador original * Obrigat�rio

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fConfigClr(oPnlPai, oIndicator)

	// Define vari�veis
	Local oPnlTop := Nil, oPnlAll := Nil, oPnlBot := Nil
	Local oPnlTmp := Nil

	Local nTmpTop := 0
	Local nTmpWid := 0, nTmpHei := 0
	Local aClrAreaNew := aClone(aClrArea)

	//--------------------
	// Monta o Painel
	//--------------------

	// Painel TOP
	oPnlTop := TPanel():New(01, 01, , oPnlPai, , , , CLR_BLACK, CLR_WHITE, 100, 110)
	oPnlTop:Align := CONTROL_ALIGN_TOP

		// Mensagem
		@ 005,015 SAY OemToAnsi(STR0121) COLOR CLR_BLUE OF oPnlTop PIXEL //"Defina as configura��es das cores dos componentes do Indicador,"
		@ 015,005 SAY OemToAnsi(STR0122) COLOR CLR_BLUE OF oPnlTop PIXEL //"selecionando a �rea e a cor desejada."

		nTmpTop := (nTopIni+075)
		nTmpWid := (nLeftEnd - nLeftIni)
		nTmpHei := (nTmpTop - nTopIni)

		// Folder com os componentes para configurar
		oClrArea := TFolder():New(nTopIni, nLeftIni, aClrAreaNew, aClrArea, oPnlTop, 1, CLR_BLACK, CLR_WHITE, .T., , nTmpWid, nTmpHei)
		oClrArea:bChange := {|| fClrSelect() }

			// �rea: Se��es Principais
			oPnlTmp := TPanel():New(001, 001, , oClrArea:aDialogs[1], , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlTmp:Align := CONTROL_ALIGN_ALLCLIENT
				// Op��es
				oClrArea01 := TRadMenu():New(005, 005, aClrArea01, , oPnlTmp, , {|| fClrSelect() }, , ,;
											, , , 100, 012, , , , .T.)
				oClrArea01:bSetGet := {|u| If(PCount() > 0, nClrArea01 := u, nClrArea01) }

			// �rea: Valores
			oPnlTmp := TPanel():New(001, 001, , oClrArea:aDialogs[2], , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlTmp:Align := CONTROL_ALIGN_ALLCLIENT
				// Op��es
				oClrArea02 := TRadMenu():New(005, 005, aClrArea02, , oPnlTmp, , {|| fClrSelect() }, , ,;
											, , , 100, 012, , , , .T.)
				oClrArea02:bSetGet := {|u| If(PCount() > 0, nClrArea02 := u, nClrArea02) }

			// �rea: Textos
			oPnlTmp := TPanel():New(001, 001, , oClrArea:aDialogs[3], , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlTmp:Align := CONTROL_ALIGN_ALLCLIENT
				// Op��es
				oClrArea03 := TRadMenu():New(005, 005, aClrArea03, , oPnlTmp, , {|| fClrSelect() }, , ,;
											, , , 100, 012, , , , .T.)
				oClrArea03:bSetGet := {|u| If(PCount() > 0, nClrArea03 := u, nClrArea03) }

			// �rea: Complementares
			oPnlTmp := TPanel():New(001, 001, , oClrArea:aDialogs[4], , , , CLR_BLACK, CLR_WHITE, 100, 100)
			oPnlTmp:Align := CONTROL_ALIGN_ALLCLIENT
				// Opc��es
				oClrArea04 := TRadMenu():New(005, 005, aClrArea04, , oPnlTmp, , {|| fClrSelect() }, , ,;
											, , , 100, 012, , , , .T.)
				oClrArea04:bSetGet := {|u| If(PCount() > 0, nClrArea04 := u, nClrArea04) }

				//GroupBox
				TGroup():New(005, 120, 040, 180, OemToAnsi(STR0123), oPnlTmp, , , .T.) //"Sombreamento"

					// Sombreamento Central
					TCheckBox():New(015, 125, STR0124, {|| lClrSomCen }, oPnlTmp, 030, 012, ,; //"Central"
									{|| lClrSomCen := !lClrSomCen, fClrSombra() }, , , , , , .T., , , )

					// Sombreamento Inferior
					TCheckBox():New(025, 125, STR0125, {|| lClrSomInf }, oPnlTmp, 030, 012, ,; //"Inferior"
									{|| lClrSomInf := !lClrSomInf, fClrSombra() }, , , , , , .T., , , )

				If oIndicator:GetStyle() == __cSPizza
					// Sombreamento Auxiliar
					TCheckBox():New(045, 125, STR0080, {|| lClrSomAux }, oPnlTmp, 100, 012, ,; //"Detalhes sobre as fatias"
									{|| lClrSomAux := !lClrSomAux, fClrSombra() }, , , , , , .T., , , )
				EndIf

			If Len(aClrArea) >= 5
				// �rea: Ponteiro
				oPnlTmp := TPanel():New(001, 001, , oClrArea:aDialogs[5], , , , CLR_BLACK, CLR_WHITE, 100, 100)
				oPnlTmp:Align := CONTROL_ALIGN_ALLCLIENT
					// Opc��es
					oClrArea05 := TRadMenu():New(005, 005, aClrArea05, , oPnlTmp, , {|| fClrSelect() }, , ,;
												, , , 100, 012, , , , .T.)
					oClrArea05:bSetGet := {|u| If(PCount() > 0, nClrArea05 := u, nClrArea05) }
			EndIf

	// Painel ALL
	oPnlAll := TPanel():New(01, 01, , oPnlPai, , , , CLR_BLACK, CLR_WHITE, 100, 100)
	oPnlAll:Align := CONTROL_ALIGN_ALLCLIENT

		// Configura��o da Cor
		oClrCfgClr := TColorTriangle():New(001, 001, oPnlAll, 100, 100)
		oClrCfgClr:Align := CONTROL_ALIGN_ALLCLIENT

	// Painel TOP
	oPnlTop := TPanel():New(01, 01, , oPnlPai, , , , CLR_BLACK, CLR_WHITE, 100, 016)
	oPnlTop:Align := CONTROL_ALIGN_BOTTOM

		// Aplicar
		TButton():New(002, nLeftIni, STR0098, oPnlTop, {|| fClrAplica() },; //"Aplicar"
						030, 012, , , .F., .T., .F., , .F., , , .F.)

		// Restaurar a cor padr�o do Indicador
		TButton():New(002, (nLeftIni+040), STR0115, oPnlTop, {|| fClrRest(oIndicator) },; //"Restaurar"
						040, 012, , , .F., .T., .F., , .F., , , .F.)

		// Restaurar a cor padr�o de todos os componentes do Indicador
		TButton():New(002, (nLeftEnd-050), STR0116, oPnlTop, {|| fClrRest(oIndicator, .T.) },; //"Restaurar Todos"
						050, 012, , , .F., .T., .F., , .F., , , .F.)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fClrSelect
Fun��o auxilixar da classe TNGIndicator:
Seta a cor do componente para o Objeto de Cor (TColorTriangle).

@author Wagner Sobral de Lacerda
@since 17/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fClrSelect()

	Local aCores  := aClone( oCfgIndPrw:GetColors() )
	Local cClrHex := ""

	Local nOption := oClrArea:nOption
	Local nArea   := 0
	Local nDefCor := 0

	Local aClrRGB := {}
	Local nClrRGB := 0

	// Recebe o componente selecionado na �rea
	Do Case
		Case nOption == 1
			nArea := nClrArea01
		Case nOption == 2
			nArea := nClrArea02
		Case nOption == 3
			nArea := nClrArea03
		Case nOption == 4
			nArea := nClrArea04
	EndCase

	// Recebe a Posi��o da Cor
	If nArea > 0
		nDefCor := aClrAtuali[nOption][nArea]
	EndIf

	// Recebe a Cor
	If nDefCor > 0
		cClrHex := aCores[nDefCor]

		// Seta a cor (em RGB)
		aClrRGB := aClone( NGHEXRGB(SubStr(cClrHex,2)) )
		nClrRGB := RGB( aClrRGB[1], aClrRGB[2], aClrRGB[3] )

		// Atualiza a configura��o da cor do componente
		oClrCfgClr:SetColor(nClrRGB)
	EndIf

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fClrAplica
Fun��o auxilixar da classe TNGIndicator:
Aplica a cor selecinada para o Indicador.

@author Wagner Sobral de Lacerda
@since 17/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fClrAplica()

	Local aCores  := aClone( oCfgIndPrw:GetColors() )
	Local cClrHex := oCfgIndPrw:ConfigClrs( oClrCfgClr:RetColor() )[1]

	Local nOption := oClrArea:nOption
	Local nArea   := 0
	Local nDefCor := 0

	// Desabilita as atualiza��es em Tela
	oDlgConfig:SetUpdatesEnabled(.F.)

	// Recebe o componente selecionado na �rea
	Do Case
		Case nOption == 1
			nArea := nClrArea01
		Case nOption == 2
			nArea := nClrArea02
		Case nOption == 3
			nArea := nClrArea03
		Case nOption == 4
			nArea := nClrArea04
		Case nOption == 5
			nArea := nClrArea05
	EndCase

	// Recebe a Posi��o da Cor
	If nArea > 0
		nDefCor := aClrAtuali[nOption][nArea]
	EndIf

	// Atribui a Cor
	If nDefCor > 0
		aCores[nDefCor] := cClrHex

		// Atualiza as cores do Indicador
		oCfgIndPrw:SetColors(aCores)
	EndIf

	// Processa as Mensagens do Application Server
	ProcessMessages()
	// Habilita atualiza��es em tela
	oDlgConfig:SetUpdatesEnabled(.T.)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fClrSombra
Fun��o auxilixar da classe TNGIndicator:
Aplica as Sombras do Indicador.

@author Wagner Sobral de Lacerda
@since 21/02/2012

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fClrSombra()

	Local aSombras := {lClrSomCen, lClrSomInf, lClrSomAux}

	// Atualiza as sombras do Indicador
	oCfgIndPrw:SetShadows(aSombras)

Return .T.

//---------------------------------------------------------------------
/*/{Protheus.doc} fSecRest
Fun��o auxilixar da classe TNGIndicator:
Restaura a distribui��o padr�o das se��es.

@author Wagner Sobral de Lacerda
@since 15/02/2012

@param oIndicOrig
	Objeto do Indicador Original * Obrigat�rio
@param lRestAll
	Indica se deve restaurar TODAS as cores * Opcional
	Default: .F.

@return .T.
/*/
//---------------------------------------------------------------------
Static Function fClrRest(oIndicOrig, lRestAll)

	Local aCoresRest := {}
	Local aCoresOrig := aClone( oIndicOrig:GetColors() )
	Local aCoresPrvw := aClone( oCfgIndPrw:GetColors() )

	Local nOption := oClrArea:nOption
	Local nArea   := 0
	Local nDefCor := 0

	// Defaults
	Default lRestAll := .F.

	// Recebe as cores
	If lRestAll
		aCoresRest := aClone( aCoresOrig )
	Else
		aCoresRest := aClone( aCoresPrvw )

		// Recebe o componente selecionado na �rea
		Do Case
			Case nOption == 1
				nArea := nClrArea01
			Case nOption == 2
				nArea := nClrArea02
			Case nOption == 3
				nArea := nClrArea03
			Case nOption == 4
				nArea := nClrArea04
		EndCase

		// Recebe a Posi��o da Cor
		If nArea > 0
			nDefCor := aClrAtuali[nOption][nArea]
		EndIf

		// Atribui a Cor
		If nDefCor > 0
			aCoresPrvw[nDefCor] := aCoresOrig[nDefCor]

			aCoresRest := aClone( aCoresPrvw )
		EndIf
	EndIf

	// Atribui as cores do Indicador original
	If Len(aCoresRest) > 0
		oCfgIndPrw:SetColors(aCoresRest)
	EndIf

Return .T.