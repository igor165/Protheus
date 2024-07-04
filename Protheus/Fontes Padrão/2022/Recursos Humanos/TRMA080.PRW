#Include "TRMA080.CH"

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o    Ё TRMA080  Ё Autor Ё Cristina Ogura        Ё Data Ё 30.03.99 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё Cadastro dos Sinonimos dos Cursos                          Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁSintaxe   Ё TRMA080                                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁ Avoid                                                      Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁUso       Ё TRMA080                                                    Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao Efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё21.07.2014ЁCecilia Car.   ЁTPZSOXЁIncluido o fonte da 11 para a 12 e   Ё╠╠
╠╠Ё          Ё               Ё      Ёefetuada a limpeza.                  Ё╠╠
╠╠юддддддддддадддддддддддддддаддддддаддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function TRMA080

LOCAL cFiltra			//Variavel para filtro
LOCAL aIndFil	:= {}	//Variavel Para Filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Array contendo as Rotinas a executar do programa      Ё
//Ё ----------- Elementos contidos por dimensao ------------     Ё
//Ё 1. Nome a aparecer no cabecalho                              Ё
//Ё 2. Nome da Rotina associada                                  Ё
//Ё 3. Usado pela rotina                                         Ё
//Ё 4. Tipo de Transa┤└o a ser efetuada                          Ё
//Ё    1 - Pesquisa e Posiciona em um Banco de Dados             Ё
//Ё    2 - Simplesmente Mostra os Campos                         Ё
//Ё    3 - Inclui registros no Bancos de Dados                   Ё
//Ё    4 - Altera o registro corrente                            Ё
//Ё    5 - Remove o registro corrente do Banco de Dados          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define o cabecalho da tela de atualizacoes                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private cCadastro := OemtoAnsi(STR0006)	//"Cadastro de Sinonimo dos Cursos"
Private cDelFunc	:= Nil //N└o apagar

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("RA9")
dbSetOrder(1)

cFiltra 	:= CHKRH(FunName(),"RA9","1")
bFiltraBrw 	:= {|| FilBrowse("RA9",@aIndFil,@cFiltra) }
Eval(bFiltraBrw)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Endereca a funcao de BROWSE                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
dbSelectArea("RA9")
dbGoTop()

mBrowse(6, 1, 22, 75, "RA9")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Deleta o filtro utilizando a funcao FilBrowse                     	   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
EndFilBrw("RA9",aIndFil)

dbSelectArea("RA9")
dbSetOrder(1)

Return Nil

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ  Luiz Gustavo     Ё Data Ё22/12/2006Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁTRMA080                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/   

Static Function MenuDef()

 Local aRotina :=  { 	{ STR0001,'PesqBrw', 0, 1,,.F.}, ;		//"Pesquisar"
						{ STR0002,'AxVisual', 0, 2}, ;		//"Visualizar"
						{ STR0003,'AxInclui', 0, 3}, ;		//"Incluir"
						{ STR0004,'AxAltera', 0, 4}, ;		//"Alterar"
						{ STR0005,'AxDeleta', 0, 5,3} }	//"Excluir"

Return aRotina