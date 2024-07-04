#INCLUDE "PROTHEUS.ch"
#INCLUDE "LOJA864.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA864   บ Autor ณ Antonio C Ferreira บ Data ณ  08/04/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Range de CEP do e-Commerce, define a Filial e Amrazem para บฑฑ
ฑฑบ          ณ a reserva de estoque.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus - eCommerce                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function LOJA864()

Private cCadastro := STR0001   //"Cadastro de Range de CEP do e-Commerce"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ aRotina padrao. Utilizando a declaracao a seguir, a execucao da     ณ
//ณ MBROWSE sera identica a da AXCADASTRO:                              ณ
//ณ                                                                     ณ
//ณ cDelFunc  := ".T."                                                  ณ
//ณ aRotina   := { { "Pesquisar"    ,"AxPesqui" , 0, 1},;               ณ
//ณ                { "Visualizar"   ,"AxVisual" , 0, 2},;               ณ
//ณ                { "Incluir"      ,"AxInclui" , 0, 3},;               ณ
//ณ                { "Alterar"      ,"AxAltera" , 0, 4},;               ณ
//ณ                { "Excluir"      ,"AxDeleta" , 0, 5} }               ณ
//ณ                                                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Private aRotina := { {STR0002,"AxPesqui",0,1} ,;    //"Pesquisar"
             {STR0003,"AxVisual",0,2} ,;       //"Visualizar"
             {STR0004,"AxInclui",0,3} ,;       //"Incluir"
             {STR0005,"AxAltera",0,4} ,;       //"Alterar"
             {STR0006,"AxDeleta",0,5} }        //"Excluir"

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

dbSelectArea("MF6")
dbSetOrder(1)   //MF6_FILIAL+MF6_CEPDE+MF6_CEPATE

mBrowse( 6,1,22,75,"MF6")

Return