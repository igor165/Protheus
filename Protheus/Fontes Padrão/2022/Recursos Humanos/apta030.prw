#INCLUDE "protheus.ch"      
#INCLUDE "apta030.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³APTA030   º Autor ³ TANIA BRONZERI     º Data ³  22/03/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cadastro de Juizes                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cadastro de Juizes                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºProgramador ³ Data     ³ BOPS ³  Motivo da Alteracao                   º±± 
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±³Cecilia Car.³04/08/2014³TQEQ39³Incluido o fonte da 11 para a 12 e efe- ³±±  
±±³            ³          ³      ³tuada a limpeza.                        ³±± 
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function APTA030

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

LOCAL cFiltraREJ							//Variavel para filtro
LOCAL aIndexREJ	:= {}						//Variavel Para Filtro

        
Private cCadastro	:= OemToAnsi(STR0001)	//"Cadastro de Varas" 
Private bFiltraBrw := {|| Nil}				//Variavel para Filtro

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array (tambem deve ser aRotina sempre) com as definicoes das opcoes ³
//³ que apareceram disponiveis para o usuario. Segue o padrao:          ³
//³ aRotina := { {<DESCRICAO>,<ROTINA>,0,<TIPO>},;                      ³
//³              {<DESCRICAO>,<ROTINA>,0,<TIPO>},;                      ³
//³              . . .                                                  ³
//³              {<DESCRICAO>,<ROTINA>,0,<TIPO>} }                      ³
//³ Onde: <DESCRICAO> - Descricao da opcao do menu                      ³
//³       <ROTINA>    - Rotina a ser executada. Deve estar entre aspas  ³
//³                     duplas e pode ser uma das funcoes pre-definidas ³
//³                     do sistema (AXPESQUI,AXVISUAL,AXINCLUI,AXALTERA ³
//³                     e AXDELETA) ou a chamada de um EXECBLOCK.       ³
//³                     Obs.: Se utilizar a funcao AXDELETA, deve-se de-³
//³                     clarar uma variavel chamada CDELFUNC contendo   ³
//³                     uma expressao logica que define se o usuario po-³
//³                     dera ou nao excluir o registro, por exemplo:    ³
//³                     cDelFunc := 'ExecBlock("TESTE")'  ou            ³
//³                     cDelFunc := ".T."                               ³
//³                     Note que ao se utilizar chamada de EXECBLOCKs,  ³
//³                     as aspas simples devem estar SEMPRE por fora da ³
//³                     sintaxe.                                        ³
//³       <TIPO>      - Identifica o tipo de rotina que sera executada. ³
//³                     Por exemplo, 1 identifica que sera uma rotina de³
//³                     pesquisa, portando alteracoes nao podem ser efe-³
//³                     tuadas. 3 indica que a rotina e de inclusao, por³
//³                     tanto, a rotina sera chamada continuamente ao   ³
//³                     final do processamento, ate o pressionamento de ³
//³                     <ESC>. Geralmente ao se usar uma chamada de     ³
//³                     EXECBLOCK, usa-se o tipo 4, de alteracao.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aRotina padrao. Utilizando a declaracao a seguir, a execucao da     ³
//³ MBROWSE sera identica a da AXCADASTRO:                              ³
//³                                                                     ³
//³ cDelFunc  := ".T."                                                  ³
//³ aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;               ³
//³                { "Visualizar"   ,"AxVisual" , 0, 2},;               ³
//³                { "Incluir"      ,"AxInclui" , 0, 3},;               ³
//³                { "Alterar"      ,"AxAltera" , 0, 4},;               ³
//³                { "Excluir"      ,"AxDeleta" , 0, 5} }               ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta um aRotina proprio                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


Private aRotina := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFiltraRh := CHKRH("APTA030","REJ","1")
bFiltraBrw 	:= {|| FilBrowse("REJ",@aIndexREJ,@cFiltraRH) }
Eval(bFiltraBrw)


dbSelectArea("REJ")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a funcao MBROWSE. Sintaxe:                                  ³
//³                                                                     ³
//³ mBrowse(<nLin1,nCol1,nLin2,nCol2,Alias,aCampos,cCampo)              ³
//³ Onde: nLin1,...nCol2 - Coordenadas dos cantos aonde o browse sera   ³
//³                        exibido. Para seguir o padrao da AXCADASTRO  ³
//³                        use sempre 6,1,22,75 (o que nao impede de    ³
//³                        criar o browse no lugar desejado da tela).   ³
//³                        Obs.: Na versao Windows, o browse sera exibi-³
//³                        do sempre na janela ativa. Caso nenhuma este-³
//³                        ja ativa no momento, o browse sera exibido na³
//³                        janela do proprio SIGAADV.                   ³
//³ Alias                - Alias do arquivo a ser "Browseado".          ³
//³ aCampos              - Array multidimensional com os campos a serem ³
//³                        exibidos no browse. Se nao informado, os cam-³
//³                        pos serao obtidos do dicionario de dados.    ³
//³                        E util para o uso com arquivos de trabalho.  ³
//³                        Segue o padrao:                              ³
//³                        aCampos := { {<CAMPO>,<DESCRICAO>},;         ³
//³                                     {<CAMPO>,<DESCRICAO>},;         ³
//³                                     . . .                           ³
//³                                     {<CAMPO>,<DESCRICAO>} }         ³
//³                        Como por exemplo:                            ³
//³                        aCampos := { {"TRB_DATA","Data  "},;         ³
//³                                     {"TRB_COD" ,"Codigo"} }         ³
//³ cCampo               - Nome de um campo (entre aspas) que sera usado³
//³                        como "flag". Se o campo estiver vazio, o re- ³
//³                        gistro ficara de uma cor no browse, senao fi-³
//³                        cara de outra cor.                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                              	
dbSelectArea("REJ")
mBrowse( 6,1,22,75,"REJ")

EndFilBrw("REJ",aIndexREJ)

Return Nil
         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Aptx030DelºAutor  ³Tania Bronzeri      º Data ³  17/05/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para Exclusao                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Cadastro de Juizes                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Aptx030Del ()

Local uRet 
Local cAlias 	:= "REJ"  
Local nReg		:= 0

dbSelectArea("REJ")
dbSetOrder(1)
nReg			:= ( cAlias )->( Recno() )
                      
If (ChkDelRegs(cAlias))
	RecLock(cAlias,.F.)
	uRet := AxDeleta( cAlias , nReg , 5 , NIL , NIL , NIL , NIL , NIL , .T. )
	MSUnlock()
Endif

Return Nil

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³18/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³APTA030                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   

Static Function MenuDef()

 Local aRotina := { 	{ STR0002 ,"AxPesqui",	  0	,1,,.F.} ,;
             			{ STR0003 ,"AxVisual",	  0	,2 } ,;
            			{ STR0004 ,"AxInclui",	  0	,3 } ,;
             			{ STR0005 ,"AxAltera",	  0	,4 } ,;
             			{ STR0006 ,"Aptx030Del",  0 ,5 } }

		 
Return aRotina