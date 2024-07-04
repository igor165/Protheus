#Include "Protheus.ch"
#Include "Inkey.Ch"
#INCLUDE "GPEA700.CH"                         

/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤┘o    Ё GPEA700  Ё Autor Ё Abel Ribeiro          Ё Data Ё 15/04/08 Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Cadastro de Seguradoras                                    Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠              
╠╠ЁSintaxe   Ё GPEA700()                                                  Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso      Ё SIGAGPE - RH - PORTUGAL                                    Ё╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё         ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.             Ё╠╠
╠╠цддддддддддддбддддддддбддддддбдддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Alteracao                     Ё╠╠
╠╠цддддддддддддеддддддддеддддддедддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддадддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ/*/
Function GPEA700()

Local aIndexRGI	:= {}		       //Variavel Para Filtro

Local cFiltraRGI			       //Variavel para filtro

Private bFiltraBrw := {|| Nil}		//Variavel para Filtro

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Define Array contendo as Rotinas a executar do programa      Ё
Ё ----------- Elementos contidos por dimensao ------------     Ё
Ё 1. Nome a aparecer no cabecalho                              Ё
Ё 2. Nome da Rotina associada                                  Ё
Ё 3. Usado pela rotina                                         Ё
Ё 4. Tipo de Transa┤└o a ser efetuada                          Ё
Ё    1 - Pesquisa e Posiciona em um Banco de Dados             Ё
Ё    2 - Simplesmente Mostra os Campos                         Ё
Ё    3 - Inclui registros no Bancos de Dados                   Ё
Ё    4 - Altera o registro corrente                            Ё
Ё    5 - Remove o registro corrente do Banco de Dados          Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Define o cabecalho da tela de atualizacoes                   Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Private cCadastro := OemToAnsi(STR0006)  //"Cadastro de Seguradoras

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Inicializa o filtro utilizando a funcao FilBrowse                      Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
cFiltraRh := CHKRH("GPEA700","RGI","1")
bFiltraBrw 	:= {|| FilBrowse("RGI",@aIndexRGI,@cFiltraRH) }
Eval(bFiltraBrw)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Endereca a funcao de BROWSE                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea('RGI')
DbGoTop()
mBrowse(06,01,22,75,'RGI')
//mBrowse(06,01,22,75,"RGI",,,,,,fCriaCor() )

/*
здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Deleta o filtro utilizando a funcao FilBrowse                     	 Ё
юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
EndFilBrw("RGI",aIndexRGI)

Return( Nil )

/*
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    ЁGpea700Del 	ЁAutorЁABEL RIBEIRO       Ё Data Ё15/04/2008Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁDeletar Registro do 700                                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Firmais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA700                                                    Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁNIL															Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function Gpe700Del( cAlias , nReg , nOpcx )

Local aArea		:= GetArea()
Local uRet		:= NIL

Private cFilAux	:= ""
/*
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Executa a Delecao   										  Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
//uRet := AxDeleta( cAlias , nReg , nOpcx,,,,,,,MV_MODFOL )
uRet := AxDeleta( cAlias , nReg , nOpcx,,,,,,,, )

RestArea( aArea )

Return( uRet )
/*
зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©
ЁFun┤┘o    ЁGpe700MntЁ Autor ЁAbel Ribeiro           Ё Data Ё15/04/08  Ё
цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤┘o ЁRotina de Manutencao nas opcoes Do Menu                     Ё
Ё          Ё                                                            Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   ЁGpe700Mnt( cAlias , nReg , nOpc )							Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁcAlias = Alias do arquivo                                   Ё
Ё          ЁnReg   = Numero do registro                                 Ё
Ё          ЁnOpc   = Numero da opcao selecionada                        Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGpe700()	                                                Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
Function Gpe700Mnt( cAlias , nReg , nOpc )
Local aAlter  := {}
Local aHeader := {}


// Preencho os arrays de campos do SRV para mostrar na enchoice    
aHeader	:= ( cAlias )->( GdMontaHeader( cAlias ) )
aEval(aHeader,{|cCpo| aAdd(aAlter, cCpo[2])})

// Preencho os arrays de campos do RGI para mostrar na enchoice    

If nOpc == 2 // Visualizar
	AxVisual(cAlias,nReg,2,,,,,,,,)
ElseIf nOpc == 4 // Alterar
	AxAltera(cAlias,nReg,4,aAlter,aAlter,,,,,,,,,,,,,)
ElseIf nOpc == 3 // Incluir   
	AxInclui(cAlias,nReg,3,aAlter,,aAlter,,,,,,,,,,,)
EndIf

Return(NIL)

/*                                	
зддддддддддбддддддддддддддддбдддддбдддддддддддддддддддбддддддбдддддддддд©
ЁFun┤└o    Ё MenuDef		ЁAutorЁ Abel Ribeiro      Ё Data Ё15/04/08  Ё
цддддддддддеддддддддддддддддадддддадддддддддддддддддддаддддддадддддддддд╢
ЁDescri┤└o ЁIsola opcoes de menu para que as opcoes da rotina possam    Ё
Ё          Ёser lidas pelas bibliotecas Framework da Versao 9.12 .      Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё< Vide Parametros Formais >									Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGPEA700                                                     Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Retorno  ЁaRotina														Ё
цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ< Vide Parametros Formais >									Ё
юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/   
Static Function MenuDef()

 Local aRotina := {;
						{ STR0001 , "PESQBRW"		, 0 , 1 , , .F.} ,;	//"Pesquisar"
						{ STR0002 , "Gpe700Mnt"	, 0 , 2 } ,;	//"Visualizar"
						{ STR0003 , "Gpe700Mnt"	, 0 , 3 } ,;	//"Incluir"  
						{ STR0004 , "Gpe700Mnt"	, 0 , 4 } ,;	//"Alterar"  
						{ STR0005 , "Gpe700Del"	, 0 , 5 }  ;	//"Excluir"  
					 }	
Return aRotina