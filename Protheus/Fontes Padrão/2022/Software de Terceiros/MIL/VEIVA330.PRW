// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 02     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "VEIVA330.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVA330 ³ Autor ³ Andre Luis Almeida    ³ Data ³ 04/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Box de Entrega de Veiculos ( Atendimento )     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA330
Private cCadastro := STR0001 // Cadastro de Box de Entrega de Veiculos
DbSelectArea("VDH")
axCadastro("VDH",cCadastro,"VEIVA330EX()","VEIVA330OK()")
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VEIVA330OK³ Autor ³ Andre Luis Almeida    ³ Data ³ 04/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ok da janela de Incluir e Alterar                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA330OK()
Local lRet   := .t.
Local cQuery := "SELECT VDH.R_E_C_N_O_ RECVDH FROM "+RetSQLName("VDH")+" VDH WHERE "
cQuery       += "VDH.VDH_FILIAL='"+xFilial("VDH")+"' AND VDH.VDH_FILBOX='"+M->VDH_FILBOX+"' AND "
cQuery       += "VDH.VDH_CODBOX='"+M->VDH_CODBOX+"' AND VDH.VDH_USUBOX='"+M->VDH_USUBOX+"' AND "
If Altera // Alterar
	cQuery   += "VDH.R_E_C_N_O_<>"+Alltrim( str( VDH->(RecNo()) ) )+" AND "
EndIf
cQuery       += "VDH.D_E_L_E_T_=' '"
If FM_SQL(cQuery) > 0
	MsgStop(STR0003,STR0002) // Impossivel continuar! Já existe cadastro com a mesma Filial, Código do Box e Usuário responsavel pelo Box! / Atenção
	lRet := .f.
Else
	If Altera 
		cQuery := "SELECT VVA.R_E_C_N_O_ AS RECVVA FROM "+RetSQLName("VVA")+" VVA WHERE "
		cQuery += "VVA.VVA_FIEPRV='"+VDH->VDH_FILBOX+"' AND "
		cQuery += "VVA.VVA_BOEPRV='"+VDH->VDH_CODBOX+"' AND "
		cQuery += "VVA.VVA_USEPRV='"+VDH->VDH_USUBOX+"' AND "
		cQuery += "VVA.VVA_DTEREA='        ' AND "
		cQuery += "VVA.D_E_L_E_T_=' '"
		If FM_SQL(cQuery) > 0
			MsgStop(STR0004,STR0002) // Impossivel alterar! Filial/Box/Usuario Responsavel pela Entrega já esta sendo utilizado para entrega de um veiculo. / Atencao
			lRet := .f.
		EndIf
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³VEIVA330EX³ Autor ³ Andre Luis Almeida    ³ Data ³ 04/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se pode ser feito a exclusao                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVA330EX()
Local lRet   := .f.
Local cQuery := "SELECT VVA.R_E_C_N_O_ AS RECVVA FROM "+RetSQLName("VVA")+" VVA WHERE "
cQuery       += "VVA.VVA_FIEPRV='"+VDH->VDH_FILBOX+"' AND "
cQuery       += "VVA.VVA_BOEPRV='"+VDH->VDH_CODBOX+"' AND "
If Empty(VDH->VDH_USUBOX)
	cQuery   += "VVA.VVA_USEPRV='      ' AND "
Else
	cQuery   += "VVA.VVA_USEPRV='"+VDH->VDH_USUBOX+"' AND "
EndIf
cQuery       += "VVA.VVA_DTEREA='        ' AND "
cQuery       += "VVA.D_E_L_E_T_=' '"
If FM_SQL(cQuery) > 0
	MsgStop(STR0005,STR0002) // Impossivel excluir! Filial/Box/Usuario Responsavel pela Entrega já esta sendo utilizado para entrega de um veiculo. / Atencao
Else
	lRet := .t.
	DbSelectArea("VDH")
	RecLock("VDH",.F.,.T.)
		VDH->(dbDelete())
	MsUnLock()
EndIf
Return lRet

Static Function MenuDef()
Return StaticCall(MATXATU,MENUDEF)