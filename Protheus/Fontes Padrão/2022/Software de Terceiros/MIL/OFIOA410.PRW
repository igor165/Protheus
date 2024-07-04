#Include "OFIOA410.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA410 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 20/02/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Cidades (VAM)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao de Concessionarias (Veiculos)                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OFIOA410

PRIVATE aCampos := {}
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0001) // Cadastro de Cidades
Private lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)
Private lA2_IBGE := If(SA2->(FieldPos("A2_IBGE"))>0,.t.,.f.)

mBrowse( 6, 1,22,75,"VAM")

Return    

Function ExCidade()
Local aArquivos := {}
	if lA1_IBGE 
		aadd(aArquivos,{"SA1","A1_IBGE",VAM->VAM_IBGE,})
	endif
	if lA2_IBGE
		aadd(aArquivos,{"SA2","A2_IBGE",VAM->VAM_IBGE,})
	endif
	if Len(aArquivos)>0
		If	FG_DELETA(aArquivos)
			DbSelectArea("VAM")
			AxDeleta("VAM",VAM->(RecNo()),5)
		EndIf
	endif
Return

Static Function MenuDef()
Local aRotina := { {STR0002,"AxPesqui", 0 , 1},;   // Pesquisar
                     {STR0003,"AXVISUAL", 0 , 2},; // Visualizar
                     {STR0004,"AXINCLUI", 0 , 3},; // Incluir
                     {STR0005,"AXALTERA", 0 , 4},; // Alterar
                     {STR0006,"EXCIDADE", 0 , 5}}  // Exclui
Return aRotina
