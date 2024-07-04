#Include "TOTVS.CH"
#Include "PLSA371.CH"
Function PLSA371
AxCadastro("BXY",STR0001,"PLSA371Del()","PLSA371Val(nOpc)")//Especialidades Conselho Federal de Medicina
Return 

Function PLSA371Val(nOpc)
Local lRet := .T.

If nOpc == 3 //Incluir
	lRet := !BXY->(dbSeek(xFilial("BXY")+M->BXY_CODIGO))
	If !lRet
		MsgInfo(STR0002)//"Já existe uma especialidade cadastrada com esse código!"
	EndIf
EndIf

If nOpc == 4 .And. M->BXY_CODIGO <> BXY->BXY_CODIGO //Alterar
	lRet := .F.
	MsgInfo(STR0003)//"Não é permitido alterar o códgio da especialidade"
EndIf

Return lRet

Function PLSA371Del()
Local lDel := .F.

If BAQ->(FieldPos("BAQ_ESPCFM")) <= 0
	lRet := .T.
EndIf

If !lDel
	cSql := ChangeQuery("SELECT BAQ_FILIAL FROM " + RetSqlName("BAQ") + " WHERE BAQ_FILIAL = '" +xFilial("BAQ")+ "' AND BAQ_ESPCFM = '" +BXY->BXY_CODIGO+ "'" )
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBB",.F.,.T.)	

	If TRBB->(Eof())
		lRet := .T.
	Else
		lRet := .F.
		MsgInfo(STR0004)//"Existem registros relacionados a este cadastro. Não será possível concluir sua exclusão."
	EndIf

	TRBB->(dbCloseArea())

EndIf

Return lRet