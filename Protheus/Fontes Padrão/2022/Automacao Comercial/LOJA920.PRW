#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA920.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡…o    ³ Loja920  ³ Autor ³ Vendas Clientes       ³ Data ³ 15/01/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ SAIDA de Notas Fiscais de Venda Manual                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function LOJA920

/******************************************************************************************
 STR0047 = Devido ao novo layout da NFE, que entrou em vigor em 01/04/2015, 
 alguns campos estão sendo obrigatórios na DANFE, por isso, é recomendável 
 a utilização da rotina de Saída de Materiais MATA920, 
 que possui todos os tratamentos necessários.
*******************************************************************************************/
MsgAlert(STR0047)


MsgStop("Esta rotina não pode ser utilizada." + CHR(13) +;
	"Deve ser utilizada a rotina de Saída de Materiais (MATA920) do módulo Livros Fiscais (SIGAFIS)")

Return Nil
