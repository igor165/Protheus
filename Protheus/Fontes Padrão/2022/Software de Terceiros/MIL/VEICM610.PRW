#Include "VEICM610.CH"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICM610 | Autor ³ Andre Luis Almeida    ³ Data ³ 08/05/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Departamentos RAIC e Verbas de Pecas/Servicos Nivel 1/2/3  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION VEICM610()
PRIVATE aCampos := {}
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0001)
mBrowse( 6, 1,22,75,"VAP")
Return

Static Function MenuDef()
Local aRotina := { { STR0002 ,"AxPesqui", 0 , 1},;		&& Pesquisar
                     { STR0003 ,"AXVISUAL", 0 , 2},;	&& Visualizar
                     { STR0004 ,"AXINCLUI", 0 , 3 },;	&& Incluir
                     { STR0005 ,"AXALTERA", 0 , 4 },;	&& Alterar
                     { STR0006 ,"AXDELETA", 0 , 5 }}	&& Excluir
Return aRotina

/*/{Protheus.doc} VCM610011_UsuarioResp
Retorna o Usuario Responsavel pelo Departamento ou Usuario Logado

@author Andre Luis Almeida
@since 23/07/2019
@version undefined
@type function
/*/
Function VCM610011_UsuarioResp()
Local cRetUsr := __CUSERID // Usuario Logado
If VAP->(FieldPos("VAP_USURES")) > 0
	VAP->(DbSetOrder(1))
	If VAP->(MsSeek(xFilial("VAP")+M->VAO_DEPART)) .and. !Empty(VAP->VAP_USURES) // Usuario preenchido no Departamento
		cRetUsr := VAP->VAP_USURES
		If !Empty(M->VAO_USURES) .and. M->VAO_USURES <> cRetUsr
			MsgInfo(STR0007,STR0008) // Usuário Responsável pelo RAIC não é o mesmo do Responsável pelo Departamento. / Atenção
		EndIf
	EndIf
EndIf
If Empty(M->VAO_USURES)
	M->VAO_USURES := cRetUsr
EndIf
Return .t.