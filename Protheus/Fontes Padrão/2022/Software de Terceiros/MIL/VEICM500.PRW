// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 34     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "FWCOMMAND.CH"
#Include "VEICM500.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEICM500 ³ Autor ³ Fabio / Andre Luis Almeida ³ Data ³ 08/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Agenda do Vendedor                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao de Concessionaria (SIGAVEI)                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM500()
Local cCondic := ""
Local lCEVOUT := ( VAI->(FieldPos("VAI_CEVOUT")) > 0 ) // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
Local lCEVTPA := ( VAI->(FieldPos("VAI_CEVTPA")) > 0 ) // Tipos de Agendas permitidas para a visualizacao    
Local i       := 0
Private aCampos   := {}
Private aRotina   := MenuDef()
Private cCadastro := STR0001
VAI->(DbSetOrder(4))
VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
If lCEVOUT .and. VAI->VAI_CEVOUT == "0" // Visualiza Agendas de Outros Usuarios do CEV? (1=Sim/0=Nao)
	cCondic += "VC1_CODVEN='"+VAI->VAI_CODVEN+"' "
EndIf
If lCEVTPA .and. !Empty(VAI->VAI_CEVTPA) // Tipos de Agendas permitidas para a visualizacao
	If !Empty(cCondic)
		cCondic += " AND "
	EndIf
	cCEVTRA := "("
	For i := 1 to Len(VAI->VAI_CEVTPA)
		cCEVTRA += "'"+substr(VAI->VAI_CEVTPA,i,1)+"'"
		if !Empty(substr(VAI->VAI_CEVTPA,i+1,1))
			cCEVTRA += ","        
		Else
			Exit
		Endif	 
	Next
	cCEVTRA += ")"        
	cCondic += "VC1_TIPAGE IN "+cCEVTRA+" "
EndIf
//
mBrowse( 6, 1,22,75,"VC1",,,,"!Empty(VC1->VC1_DATVIS)",,,,,,,,,,cCondic)

//
If !Empty(cCondic)
	dbClearFilter()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ML500V   ³ Autor ³  Andre Luis Almeida        ³ Data ³ 08/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza Agenda                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ML500V(cAlias,nReg,nOpc)
Private cMotivo := "000010"  //Filtro da consulta do motivo de Encerramento do Contato CEV
CAMPOM500(nOpc)
AxVisual(cAlias,nReg,nOpc,aCampos)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ML500I   ³ Autor ³  Andre Luis Almeida        ³ Data ³ 08/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclui Agenda                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ML500I(cAlias,nReg,nOpc)
Private cMotivo := "000010"  //Filtro da consulta do motivo de Encerramento do Contato CEV
Private aNewBot := {}
AADD(aNewBot,{"PMSUSER",{|| VCM500PROS() },( STR0034 )} ) // Converter Prospect em Cliente
CAMPOM500(nOpc)
aMemObj := {{"VC1_OBSOBJ","VC1_OBJETI"}}
M->VC1_OBJETI := ""
If AxInclui(cAlias,nReg,nOpc,aCampos,,,"VCM510VAL('3').and.ML500IVal(M->VC1_TIPAGE,M->VC1_CODCLI,M->VC1_LOJA)",,,aNewBot) == 1 // VCM510VAL() -> Validacao do reg.da visita para Vendedor/Tp.Agenda/Cliente //
	MSMM(VC1->VC1_OBSOBJ,TamSx3("VC1_OBJETI")[1],,&(aMemObj[1][2]),1,,,"VC1","VC1_OBSOBJ")
	DbSelectArea("VC1")
	RecLock("VC1",.F.)
	VC1->VC1_PROCON := ctod("  /  /  ")
	VC1->VC1_PROVEN := ""
	VC1->VC1_PROTPA := ""
	if VC1->(FieldPos("VC1_DATALT")) > 0
		VC1->VC1_DATALT := criavar("VC1_DATALT")
	endif
	MsUnLock()
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ML500IVal³ Autor ³  Andre Luis Almeida        ³ Data ³ 08/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao (Cliente Bloqueado)                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ML500IVal(cTipAge,cCodCli,cLojCli)
Local lRet := .t.
Local lVCF_GRUECN := ( VCF->(FieldPos("VCF_GRUECN")) > 0 )
If !Empty(cCodCli+cLojCli)
	DbSelectArea("VCF")
	DbSetOrder(1)
	If DbSeek( xFilial("VCF") + cCodCli + cLojCli )
		If cTipAge $ VCF->VCF_BLOQAG
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek( xFilial("SA1") + cCodCli + cLojCli )
			MsgStop(STR0015+cTipAge+STR0016+" ("+cCodCli+"-"+cLojCli+") "+Alltrim(SA1->A1_NOME),STR0006)
			lRet := .f.
		EndIf
		If lRet .and. lVCF_GRUECN .and. !Empty(VCF->VCF_GRUECN)
			If VQK->(DbSeek(xFilial("VQK")+VCF->VCF_GRUECN))
				If !Empty(VQK->VQK_CODCLI+VQK->VQK_LOJCLI) .and. VQK->VQK_CODCLI+VQK->VQK_LOJCLI <> cCodCli + cLojCli
					SA1->(DbSeek( xFilial("SA1") + VQK->VQK_CODCLI + VQK->VQK_LOJCLI ))
					lRet := MsgNoYes(STR0031+VQK->VQK_CODCLI+"/"+VQK->VQK_LOJCLI+"-"+SA1->A1_NOME+STR0032,STR0006)
				Else
					MsgInfo(STR0033+VCF->VCF_GRUECN+"-"+VQK->VQK_DESCRI,STR0006)
					lRet := .t.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ML500A   ³ Autor ³  Andre Luis Almeida        ³ Data ³ 08/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Registra Abordagem                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ML500A(cAlias,nReg,nOpc)
Local lRegAbor    := .f.
Local lRegSati    := .f.
Local cTit        := cCadastro
Local lVC1_PROTPA := ( VC1->(ColumnPos("VC1_PROTPA")) > 0 )
Local lVC1_PROVEN := ( VC1->(ColumnPos("VC1_PROVEN")) > 0 )
Local lVC1_CODIGO := ( VC1->(ColumnPos("VC1_CODIGO")) > 0 ) 
Local cVC1_CODREL := ""
Local cVC1_PROTPA := ""
Local cVC1_PROVEN := ""
Local nOpcAnt	   := nOpc 
Local INCLANT	   := INCLUI
Local ALTEANT	   := ALTERA
Private cMotivo   := "000010"  //Filtro da consulta do motivo de Encerramento do Contato CEV
Private aNewBot   := {}
AADD(aNewBot,{"PMSUSER",{|| VCM500PROS() },( STR0034 )} ) // Converter Prospect em Cliente
If FunName() # "VEICM500"
	DEFINE MSDIALOG oAbordSat FROM 000,000 TO 004,060 TITLE STR0017 OF oMainWnd
	@ 012,011 BUTTON oRegAbo PROMPT (STR0018) OF oAbordSat SIZE 60,10 PIXEL ACTION ( lRegAbor := .t. , oAbordSat:End() )
	@ 012,081 BUTTON oRgSati PROMPT (STR0019) OF oAbordSat SIZE 77,10 PIXEL ACTION ( lRegSati := .t. , oAbordSat:End() )
	@ 012,168 BUTTON oSair PROMPT (STR0020) OF oAbordSat SIZE 60,10 PIXEL ACTION ( oAbordSat:End() )
	ACTIVATE MSDIALOG oAbordSat CENTER
Else
	lRegAbor := .t. // Registra Abordagem quando chamado pelo VEICM500
EndIf
If lRegAbor // Registra Abordagem
	nReg := 0
	nOpc := 3   
	//
	INCLUI 		:= .t.
	ALTERA 		:= .f.
	//
	DbSelectArea("VC1")
	DbGoBottom()
	If !Eof()
		DbSkip()
	EndIf
	Altera := .t.
	cAlias := "VC1"
	cCadastro := STR0021
	DbSelectArea(cAlias)
	aMemos  := {{"VC1_OCOMEM","VC1_OCORRE"}}
	aObser  := {{"VC1_OCOMEM","VC1_OCORRE"}}
	aMemObj := {{"VC1_OBSOBJ","VC1_OBJETI"}}
	M->VC1_OBJETI := ""
	M->VC1_RELPRX := "0"
	If AxInclui(cAlias,nReg,nOpc,,,,"VCM510VAL('3')",,,aNewBot) == 1 // VCM510VAL() -> Validacao do reg.da visita para Vendedor/Tp.Agenda/Cliente //
		MSMM(VC1->VC1_OBSOBJ,TamSx3("VC1_OBJETI")[1],,&(aMemObj[1][2]),1,,,"VC1","VC1_OBSOBJ")
		DbSelectArea("VC1")
		cVC1_PROTPA := VC1->VC1_TIPAGE
		If lVC1_PROTPA .and. !Empty(VC1->VC1_PROTPA)
			cVC1_PROTPA := VC1->VC1_PROTPA
		EndIf
		cVC1_PROVEN := VC1->VC1_CODVEN
		If lVC1_PROVEN .and. !Empty(VC1->VC1_PROVEN)
			cVC1_PROVEN := VC1->VC1_PROVEN
		EndIf
		RecLock("VC1",.F.)
		VC1->VC1_DATAGE := VC1->VC1_DATVIS
		if VC1->(FieldPos("VC1_DATALT")) > 0
			VC1->VC1_DATALT := criavar("VC1_DATALT")
		endif
		VC1->VC1_TIPORI := "C" // Criado no CEV - Reg.Abordagem
		VC1->VC1_ORIGEM := strzero(VC1->(RecNo()),10) // Criado no CEV - Reg.Abordagem
		MsUnLock()
		If lVC1_CODIGO .and. M->VC1_RELPRX == "1" // Tem o Codigo e Relaciona proximo Contato
			If !Empty(VC1->VC1_CODREL)
				cVC1_CODREL := VC1->VC1_CODREL
			Else
				cVC1_CODREL := VC1->VC1_CODIGO
			EndIf
		EndIf
		//
		//////////////////////////////////////////////
		//    PE_DEPOIS_DO_REGISTRO_DE_ABORDAGEM    //
		//////////////////////////////////////////////
		If ExistBlock("VCM500DA") // PE executado Depois da Abordagem
			ExecBlock("VCM500DA",.f.,.f.)
		EndIf
		//
		If !Empty(VC1->VC1_PROCON)
			M->VC1_PROCON := VC1->VC1_PROCON
			M->VC1_TIPAGE := cVC1_PROTPA
			M->VC1_CODVEN := cVC1_PROVEN
			M->VC1_CODCLI := VC1->VC1_CODCLI
			M->VC1_LOJA   := VC1->VC1_LOJA
			M->VC1_CDPROS := VC1->VC1_CDPROS
			M->VC1_LJPROS := VC1->VC1_LJPROS
			M->VC1_CODREL := cVC1_CODREL
			FS_AGENDA()
		EndIf
		If !Empty(VC1->VC1_CODCLI+VC1->VC1_LOJA+VC1->VC1_CDPROS+VC1->VC1_LJPROS)
			VAI->(DbSetOrder(4))
			VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
			If VAI->(FieldPos("VAI_CEVOPO")) <= 0 .or. VAI->VAI_CEVOPO <> "0" // Caso nao exista o campo de controle ou o campo esteja configurado como SIM
				VCM510031_CriaOportunidadeInteresse()
			EndIf
		EndIf
	EndIf
ElseIf lRegSati // Satisfacao / Insatisfacao
	nReg := 0
	nOpc := 3
	Altera	:= .f.
	Inclui	:= .t.
	aCampos := {}
	cAlias := "VAO"
	cCadastro := STR0022
	DbSelectArea(cAlias)
	aMemos  := {{"VAO_RECLAO","VAO_RECLAM"}}
	aObser  := {{"VAO_RECLAO","VAO_RECLAM"}}
	ML600I(cAlias,nReg,nOpc)
EndIf
cCadastro := cTit

nOpc := nOpcAnt
INCLUI := INCLANT
ALTERA := ALTEANT

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ML5002   ³ Autor ³  Andre Luis Almeida        ³ Data ³ 08/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Marca que Ficha da Agenda pode ser emitida a 2a.Via             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ML5002(cAlias,nReg,nOpc)
If Empty(VC1->VC1_DATVIS)
	DbSelectArea("VC1")
	RecLock("VC1",.F.)
	VC1->VC1_EMIFIC := "0"
	MsUnLock()
	MsgInfo(STR0010+space(45)+STR0011,STR0006)
Else
	MsgAlert(STR0012+space(65)+STR0013,STR0006)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ML500E   ³ Autor ³  Andre Luis Almeida        ³ Data ³ 08/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclusao da Agenda ou Limpa a Abordagem (Visita)                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ML500E(cAlias,nReg,nOpc)
Local nT         := 0
Local lExc       := .t. // Exclui Agenda
Local lLim       := .f. // Limpa Abordagem
Local lVC1ESTVEI := ( VC1->(FieldPos("VC1_ESTVEI")) > 0 )
Local lVC1MOTIVO := ( VC1->(FieldPos("VC1_MOTIVO")) > 0 )
Local lVC1CONPRO := ( VC1->(FieldPos("VC1_CONPRO")) > 0 )
Private cMotivo  := "000010"  //Filtro da consulta do motivo de Encerramento do Contato CEV
If ( VAI->(FieldPos("VAI_CEVEXC")) <> 0 )
	lExc := .f.
	VAI->(DbSetOrder(4))
	VAI->(DbSeek( xFilial("VAI") + __CUSERID ))
	If Empty(VAI->VAI_CEVEXC) // Usuario nao tem permissao para excluir Agenda
		nT := 10 // somente para dar mensagem de 'Usuario nao permitido!'
	ElseIf VAI->VAI_CEVEXC == "1" // Usuario tem permissao para excluir Agenda SEM Abordagem
		nT := 2
		If Empty(VC1->VC1_DATVIS)
			lExc := .t.
		EndIf
	ElseIf VAI->VAI_CEVEXC == "2" // Usuario tem permissao para excluir Agenda COM Abordagem
		nT := 1
		If Empty(VC1->VC1_DATVIS)
			lExc := .t.
		Else
			nT := 0
			nT := Aviso(STR0006,STR0026+CHR(13)+CHR(10)+STR0027+CHR(13)+CHR(10)+STR0028,{STR0029,STR0005}) // Atencao / Deseja: / - Limpar o registro da Abordagem / - Excluir a Agenda CEV / Limpar / Excluir
			If nT == 1 // Limpa Abordagem
				lLim := .t.
			ElseIf nT == 2 // Exclui Agenda
				lExc := .t.
			EndIf
		EndIf
	EndIf
EndIf
If nT > 0 .and. !lExc .and. !lLim // Nao exclui a Agenda CEV e nao limpa a Abordagem
	MsgStop(STR0007,STR0006) // Usuario nao permitido!
EndIf
If lLim // Limpa a Abordagem
	DbSelectArea("SYP")
	DbSetOrder(1)
	If DbSeek(xFilial("SYP")+VC1->VC1_OCOMEM)
		Do while !Eof() .and. xFilial("SYP")== SYP->YP_FILIAL .and. SYP->YP_CHAVE == VC1->VC1_OCOMEM
			RecLock("SYP",.f.,.t.)
			dbDelete()
			MsUnlock()
			WriteSx2("SYP")
			DbSkip()
		EndDo
	EndIf
	DbSelectArea("VC1")
	RecLock("VC1",.f.)
	VC1->VC1_DATVIS := ctod("")
	VC1->VC1_CODABO := ""
	VC1->VC1_TIPCON := ""
	VC1->VC1_EMIFIC := "1" //Nao
	VC1->VC1_OCOMEM := ""
	If lVC1ESTVEI
		VC1->VC1_ESTVEI := ""
	EndIf
	VC1->VC1_CODMAR := ""
	VC1->VC1_MODVEI := ""
	VC1->VC1_QTDINT := 0
	VC1->VC1_DATINT := ctod("")
	VC1->VC1_PREPAG := ""
	VC1->VC1_PROCON := ctod("")
	VC1->VC1_PROVEN := ""
	VC1->VC1_PROTPA := ""
	If lVC1MOTIVO
		VC1->VC1_MOTIVO := ""
	EndIf
	If lVC1CONPRO
		VC1->VC1_CONPRO := "0" // Contato NAO produtivo 
	EndIf
	if VC1->(FieldPos("VC1_DATALT")) > 0
		VC1->VC1_DATALT := criavar("VC1_DATALT")
	endif
	MsUnLock()
ElseIf lExc // Exclui a Agenda CEV
	CAMPOM500(nOpc)
	AxDeleta(cAlias,nReg,nOpc,aCampos)
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CAMPOM500³ Autor ³  Andre Luis Almeida        ³ Data ³ 08/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Levanta campos do VC1 a serem exibidos na tela                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CAMPOM500(nOpc)
Local cCposVC1 := ""
Default nOpc := 2
cCposVC1 := "VC1_DATVIS/VC1_CODABO/VC1_DESABO/VC1_TIPCON/VC1_DESCON/VC1_OCORRE/VC1_OCOMEM/VC1_OBSOBJ/VC1_ESTVEI/VC1_CODMAR/VC1_DESMAR/"
cCposVC1 += "VC1_MODVEI/VC1_DESMOD/VC1_QTDINT/VC1_DATINT/VC1_PREPAG/VC1_DESPAG/VC1_PROCON/VC1_PROVEN/VC1_PROTPA/VC1_MOTIVO/VC1_CONPRO/"
aCampos := {}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VC1")
Do While !eof() .and. x3_arquivo == "VC1"
	If X3USO(x3_usado).And.cNivel>=x3_nivel .And. ( nOpc == 2 .or. !(Alltrim(x3_campo) $ cCposVC1 ))
		aadd(aCampos,x3_campo)
	EndIf
	DbSkip()
EndDo
DbSelectArea("VC1")
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VEICM500VL³ Autor ³  Andre Luis Almeida        ³ Data ³ 08/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacoes na Digitacao SX3                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICM500VL()
Local lRet := .t.
Local lVCF_GRUECN := ( VCF->(FieldPos("VCF_GRUECN")) > 0 )

If !Empty(M->VC1_TIPAGE).and.!Empty(DTOS(M->VC1_DATAGE)).and.!Empty(M->VC1_CODVEN).and.!Empty(M->VC1_CODCLI).and.!Empty(M->VC1_LOJA).and.!Empty(M->VC1_CDPROS).and.!Empty(M->VC1_LJPROS)
	lRet:= ExistChav("VC1",M->VC1_TIPAGE+DTOS(M->VC1_DATAGE)+M->VC1_CODVEN+M->VC1_CODCLI+M->VC1_LOJA+M->VC1_CDPROS+M->VC1_LJPROS,6)
EndIf

If lVCF_GRUECN .and. !Empty(M->VC1_CODCLI+M->VC1_LOJA)
	DbSelectArea("VCF")
	DbSetOrder(1)
	If DbSeek( xFilial("VCF") + M->VC1_CODCLI+M->VC1_LOJA )
		If !Empty(VCF->VCF_GRUECN)
			If VQK->(DbSeek(xFilial("VQK")+VCF->VCF_GRUECN))
				M->VC1_GRUECN := VCF->VCF_GRUECN
				M->VC1_DESCGE := VQK->VQK_DESCRI
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VCM500CLI ³ Autor ³  Andre Luis Almeida        ³ Data ³ 14/08/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacoes SX3 ( Cliente / Prospect )                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM500CLI()
Local lRet    := .t.
Local nRecSUS := 0
Local nRecSA1 := 0
M->VC1_NOMCLI := ""
If Alltrim(ReadVar()) $ "M->VC1_CODCLI/M->VC1_LOJA/" // Cliente / Loja
	If !Empty(M->VC1_CODCLI+M->VC1_LOJA)
		M->VC1_CDPROS := space(TamSX3("VC1_CDPROS")[1])
		M->VC1_LJPROS := space(TamSX3("VC1_LJPROS")[1])
		nRecSA1 := FM_SQL("SELECT R_E_C_N_O_ AS RECSA1 FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+M->VC1_CODCLI+"'"+IIf(!Empty(M->VC1_LOJA)," AND A1_LOJA='"+M->VC1_LOJA+"' ","")+" AND D_E_L_E_T_=' '")
		If nRecSA1 > 0 // Existe Cliente
			DbSelectArea("SA1")
			DbGoTo(nRecSA1)
			M->VC1_LOJA   := SA1->A1_LOJA
			M->VC1_NOMCLI := SA1->A1_NOME
		EndIf
	EndIf
	lRet := ( vazio() .or. ( nRecSA1 > 0 .and. VEICM500VL() .and. ML500IVal(M->VC1_TIPAGE,M->VC1_CODCLI,M->VC1_LOJA) ) ) // Vazio ou possui Cliente e validacoes estao ok
ElseIf Alltrim(ReadVar()) $ "M->VC1_CDPROS/M->VC1_LJPROS/" // Prospect / Loja
	If !Empty(M->VC1_CDPROS+M->VC1_LJPROS)
		M->VC1_CODCLI := space(TamSX3("VC1_CODCLI")[1])
		M->VC1_LOJA	  := space(TamSX3("VC1_LOJA")[1])
		nRecSUS := FM_SQL("SELECT R_E_C_N_O_ AS RECSUS FROM "+RetSQLName("SUS")+" WHERE US_FILIAL='"+xFilial("SUS")+"' AND US_COD='"+M->VC1_CDPROS+"'"+IIf(!Empty(M->VC1_LJPROS)," AND US_LOJA='"+M->VC1_LJPROS+"' ","")+" AND D_E_L_E_T_=' '")
		If nRecSUS > 0 // Existe Prospect
			DbSelectArea("SUS")
			DbGoTo(nRecSUS)
			M->VC1_LJPROS := SUS->US_LOJA
			M->VC1_NOMCLI := SUS->US_NOME
			If !Empty(SUS->US_CODCLI+SUS->US_LOJACLI)
				MsgInfo(STR0035,STR0006) // Este Prospect já foi convertido para Cliente! / Atencao
				M->VC1_CODCLI := SUS->US_CODCLI
				M->VC1_LOJA	  := SUS->US_LOJACLI
				nRecSA1 := FM_SQL("SELECT R_E_C_N_O_ AS RECSA1 FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+M->VC1_CODCLI+"' AND A1_LOJA='"+M->VC1_LOJA+"' AND D_E_L_E_T_=' '")
				If nRecSA1 > 0 // Existe Cliente
					DbSelectArea("SA1")
					DbGoTo(nRecSA1)
					M->VC1_NOMCLI := SA1->A1_NOME
				EndIf
				M->VC1_CDPROS := space(TamSX3("VC1_CDPROS")[1])
				M->VC1_LJPROS := space(TamSX3("VC1_LJPROS")[1])
			EndIf
		EndIf
	EndIf
	lRet := ( vazio() .or. nRecSUS > 0 ) // Vazio ou possui Prospect
EndIf
DbSelectArea("VC1")
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VCM500NOM ³ Autor ³  Andre Luis Almeida        ³ Data ³ 14/08/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Nome ( Cliente / Prospect )                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM500NOM()
Local cRet := .t.
If !Empty(VC1->VC1_CODCLI+VC1->VC1_LOJA)
	cRet := POSICIONE("SA1",1,XFILIAL("SA1")+VC1->VC1_CODCLI+VC1->VC1_LOJA,"A1_NOME")
ElseIf !Empty(VC1->VC1_CDPROS+VC1->VC1_LJPROS)
	cRet := POSICIONE("SUS",1,XFILIAL("SUS")+VC1->VC1_CDPROS+VC1->VC1_LJPROS,"US_NOME")
EndIf
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ML500Abord³ Autor ³  Andre Luis Almeida        ³ Data ³ 08/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche Campos para o Registro de Abordagem                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ML500Abord(cRet)
Local lOk := .f.
Local cAb := ""
If FM_PILHA("OFIXA011") .OR. FM_PILHA("OFIXA021") // Orcamento
	lOk := .t.
	cAb := left(Alltrim(GetMV("MV_ABORDB"))+space(3),3)
ElseIf FM_PILHA("OFIXX100") .or. FM_PILHA("OFIOM010")// Fechamento Novo / Abertura de OS
	lOk := .t.
	cAb := left(Alltrim(GetMV("MV_ABORDO"))+space(3),3)
EndIf
If lOk
	DbSelectArea("VAI")
	DbSetOrder(4)
	DbSeek( xFilial("VAI") + __CUSERID )
	M->VC1_DATVIS := dDataBase
	M->VC1_CODVEN := VAI->VAI_CODVEN
	M->VC1_TIPAGE := substr(cAb,1,1)
	M->VC1_CODABO := substr(cAb,2,1)
	M->VC1_TIPCON := substr(cAb,3,1)
	M->VC1_EMIFIC := "1" //Nao
	Do Case
		Case cRet == "VC1_DESVEN"
			cRet := FM_SQL("SELECT A3_NOME FROM "+RetSQLName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+VAI->VAI_CODVEN+"' AND D_E_L_E_T_=' '")
		Case cRet == "VC1_DTPAGE"
			cRet := FM_SQL("SELECT VC5_DTPAGE FROM "+RetSQLName("VC5")+" WHERE VC5_FILIAL='"+xFilial("VC5")+"' AND VC5_TIPAGE='"+substr(cAb,1,1)+"' AND D_E_L_E_T_=' '")
		Case cRet == "VC1_DESABO"
			cRet := FM_SQL("SELECT VCA_DESABO FROM "+RetSQLName("VCA")+" WHERE VCA_FILIAL='"+xFilial("VCA")+"' AND VCA_CODABO='"+substr(cAb,2,1)+"' AND D_E_L_E_T_=' '")
		Case cRet == "VC1_DESCON"
			cRet := FM_SQL("SELECT VC0_DESCON FROM "+RetSQLName("VC0")+" WHERE VC0_FILIAL='"+xFilial("VC0")+"' AND VC0_TIPCON='"+substr(cAb,3,1)+"' AND D_E_L_E_T_=' '")
	EndCase
Else
	cRet := ""
EndIf
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VCM500PROS³ Autor ³  Andre Luis Almeida        ³ Data ³ 25/08/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Converter Prospect em Cliente                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VCM500PROS()
If FGX_SUSSA1(M->VC1_CDPROS,M->VC1_LJPROS,.f.,.t.)
	M->VC1_CODCLI := SUS->US_CODCLI
	M->VC1_LOJA   := SUS->US_LOJACLI
	M->VC1_CDPROS := space(TamSX3("VC1_CDPROS")[1])
	M->VC1_LJPROS := space(TamSX3("VC1_LJPROS")[1])
EndIf
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³  Andre Luis Almeida        ³ Data ³ 08/07/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta vetor aRotina (opcoes do MENU lateral)                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := { { STR0002 ,"AxPesqui", 0 , 1},;	// Pesquisar
					{ STR0003 ,"Ml500V", 0 , 2},;	// Visualizar
					{ STR0004 ,"Ml500I", 0 , 3},;	// Agendar
					{ STR0014 ,"Ml500A", 0 , 3},;	// Registra Abordagem
					{ STR0009 ,"Ml5002", 0 , 2},;	// 2a. Via
					{ STR0005 ,"Ml500E", 0 , 5},;	// Excluir
					{ STR0036 , "VCM500021_RelacionarAgendas" , 0 , 4 },; // Relacionar Agendas
					{ STR0037 , "VCM500011_Batiza_VC1_CODIGO()" , 0 , 2 },; // Atualizar Codigos
					{ STR0023 ,"CM500LEG", 0, 0}}	// Legenda
Return aRotina

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CM500LEG  ³ Autor ³ Andre Luis Almeida   ³ Data ³ 16/04/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ VEICM500                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CM500LEG()
Local aLegenda := {{'BR_VERDE',STR0024},;
					{'BR_VERMELHO',STR0025}}
BrwLegenda(STR0001,STR0023,aLegenda) // Legenda
Return .T.

/*/{Protheus.doc} VCM500011_Batiza_VC1_CODIGO
	Batiza os Registros das Agendas VC1_CODIGO
	
	@type function
	@author Andre Luis Almeida
	@since 11/05/2020
/*/
Function VCM500011_Batiza_VC1_CODIGO()
Local cQuery  := ""
Local cQAlias := "SQLVC1"
Local aFilVC1 := {}
Local aFilAtu := {}
Local cBkpFil := cFilAnt
Local nCntFor := 0
//
cQuery := "SELECT COUNT(*) AS QTDE "
cQuery += "  FROM "+RetSqlName("VC1")
cQuery += " WHERE VC1_CODIGO = ' '"
cQuery += "   AND D_E_L_E_T_=' '"
If FM_SQL(cQuery) > 0 // Possui Registros para batizar
	aFilAtu := FWArrFilAtu()
	aFilVC1 := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
	For nCntFor := 1 to len(aFilVC1)
		If !Empty(aFilVC1[nCntFor])
			cFilAnt := aFilVC1[nCntFor]
			cQuery := "SELECT R_E_C_N_O_ AS VC1REC "
			cQuery += "  FROM "+RetSqlName("VC1")
			cQuery += " WHERE VC1_FILIAL = '"+xFilial("VC1")+"'"
			cQuery += "   AND VC1_CODIGO = ' '"
			cQuery += "   AND D_E_L_E_T_=' '"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
			While !( cQAlias )->( Eof() )
				DbSelectArea("VC1")
				DbGoto( ( cQAlias )->( VC1REC ) )
				RecLock("VC1",.f.)
					VC1->VC1_CODIGO := GetSXENum("VC1","VC1_CODIGO")
				MsUnLock()
				ConfirmSX8()
				( cQAlias )->( dbSkip() )
			EndDo
			( cQAlias )->( dbCloseArea() )
		EndIf
	Next
	cFilAnt := cBkpFil
	MsgAlert(STR0038,STR0006) // Todos os Códigos do CEV foram atualizados com sucesso. / Atencao
Else
	MsgAlert(STR0039,STR0006) // Todos os Códigos do CEV já estão atualizados. Não há necessidade de executar esta opção. / Atencao
EndIf
DbSelectArea("VC1")
//
Return

/*/{Protheus.doc} VCM500021_RelacionarAgendas
	Faz manualmente o Relacionamento entre as Agendas (VC1)
	
	@type function
	@author Andre Luis Almeida
	@since 18/05/2020
/*/
Function VCM500021_RelacionarAgendas()
Local lOkTela := .f.
Local aSize   := FWGetDialogSize( oMainWnd )
Local nCntFor := 0
Local nRecVC1 := 0
Local aVetRel := {}
Local cQuery  := ""
Local cQAlias := "SQLVC1"
Local cCodRel := ""
Local lJaRelac := .f.
Private oOkTik    := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik    := LoadBitmap( GetResources() , "LBNO" )
//
nOpc := 2
//
DbSelectArea("VC1")
If !Empty(VC1->VC1_CODREL) // Se possuir relacionamento, posiciona na Principal ( Relacionamento Inicial )
	nRecVC1 := FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSQLName("VC1")+" WHERE VC1_FILIAL='"+VC1->VC1_FILIAL+"' AND VC1_CODIGO='"+VC1->VC1_CODREL+"' AND D_E_L_E_T_=' '")
	If nRecVC1 > 0
		VC1->(DbGoTo(nRecVC1))
	EndIf
EndIf
//
cCodRel := VC1->VC1_CODIGO // Codigo que sera relacionado nas Agendas
//
cQuery := "SELECT TEMP.* FROM ( "
//
cQuery += "SELECT VC1_1.VC1_TIPAGE , VC1_1.VC1_CODVEN ,"
cQuery += "       VC1_1.VC1_DATAGE , VC1_1.VC1_DATVIS ,"
cQuery += "       VC1_1.VC1_CODIGO , VC1_1.VC1_CODREL ,"
cQuery += "       VC1_1.R_E_C_N_O_ AS RECVC1 ,"
cQuery += "       SA3_1.A3_NOME "
cQuery += "  FROM "+RetSQLName("VC1")+" VC1_1"
cQuery += "  LEFT JOIN "+RetSQLName("SA3")+" SA3_1 ON SA3_1.A3_FILIAL='"+xFilial("SA3")+"' AND SA3_1.A3_COD=VC1_1.VC1_CODVEN AND SA3_1.D_E_L_E_T_=' '"
cQuery += " WHERE VC1_1.VC1_FILIAL='"+VC1->VC1_FILIAL+"'"
cQuery += "   AND VC1_1.VC1_CODREL='"+VC1->VC1_CODIGO+"'"
cQuery += "   AND VC1_1.D_E_L_E_T_=' '"
//
cQuery += " UNION ALL "
//
cQuery += "SELECT VC1_2.VC1_TIPAGE , VC1_2.VC1_CODVEN ,"
cQuery += "       VC1_2.VC1_DATAGE , VC1_2.VC1_DATVIS ,"
cQuery += "       VC1_2.VC1_CODIGO , VC1_2.VC1_CODREL ,"
cQuery += "       VC1_2.R_E_C_N_O_ AS RECVC1 ,"
cQuery += "       SA3_2.A3_NOME "
cQuery += "  FROM "+RetSQLName("VC1")+" VC1_2"
cQuery += "  LEFT JOIN "+RetSQLName("SA3")+" SA3_2 ON SA3_2.A3_FILIAL='"+xFilial("SA3")+"' AND SA3_2.A3_COD=VC1_2.VC1_CODVEN AND SA3_2.D_E_L_E_T_=' '"
cQuery += " WHERE VC1_2.VC1_FILIAL='"+VC1->VC1_FILIAL+"'"
cQuery += "   AND VC1_2.VC1_CODCLI='"+VC1->VC1_CODCLI+"'"
cQuery += "   AND VC1_2.VC1_LOJA='"+VC1->VC1_LOJA+"'"
cQuery += "   AND VC1_2.VC1_CDPROS='"+VC1->VC1_CDPROS+"'"
cQuery += "   AND VC1_2.VC1_LJPROS='"+VC1->VC1_LJPROS+"'"
cQuery += "   AND VC1_2.VC1_CODIGO<>'"+VC1->VC1_CODIGO+"'"
cQuery += "   AND VC1_2.VC1_CODREL=' '"
cQuery += "   AND VC1_2.D_E_L_E_T_=' '"
cQuery += "   AND NOT EXISTS ( "
cQuery += "SELECT JAREL.VC1_CODIGO "
cQuery += "  FROM "+RetSQLName("VC1")+" JAREL"
cQuery += " WHERE JAREL.VC1_FILIAL='"+VC1->VC1_FILIAL+"'"
cQuery += "   AND JAREL.VC1_CODREL=VC1_2.VC1_CODIGO "
cQuery += "   AND JAREL.D_E_L_E_T_ = ' ' )"
//
cQuery += " ) TEMP ORDER BY TEMP.VC1_CODREL DESC "
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
While !( cQAlias )->( Eof() )
	lJaRelac := !Empty(( cQAlias )->( VC1_CODREL ))
	aadd(aVetRel,{	lJaRelac ,; // Deixa desmarcar e marcar
					lJaRelac ,; // Controle do que ja estava selecionado
					( cQAlias )->( VC1_TIPAGE ) ,;
					stod(( cQAlias )->( VC1_DATAGE )) ,;
					stod(( cQAlias )->( VC1_DATVIS )) ,;
					( cQAlias )->( VC1_CODVEN )+" "+( cQAlias )->( A3_NOME ) ,;
					( cQAlias )->( RECVC1 ) })
	( cQAlias )->( dbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )

If len(aVetRel) == 0
	MsgStop(STR0040,STR0006) // Não existem outras Agendas do Cliente para fazer o relacionamento. / Atencao
	Return
EndIf

CAMPOM510()

DbSelectArea("VC1")
RegToMemory("VC1",.f.)

oVCM510REL := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0041, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )    // Agendas Relacionadas

oWorkArea := FWUIWorkArea():New( oVCM510REL )
oWorkArea:CreateHorizontalBox( "LINE01", 50 , .f. )
oWorkArea:SetBoxCols( "LINE01", { "PRINCIPAL" } )
oWorkArea:CreateHorizontalBox( "LINE02", 40 , .f. )
oWorkArea:SetBoxCols( "LINE02", { "RELACIONADOS" } )
oWorkArea:Activate()

oEnchVC1 := MSMGet():New( "VC1", VC1->(RecNo()) , nOpc ,;
		/* aCRA */, /* cLetra */, /* cTexto */, aCampos, {0,0,aSize[3]-50,0}, , 3,;
		/* nColMens */, /* cMensagem */, ".t." , oWorkarea:GetPanel("PRINCIPAL") , .f., .t., .t. /* lColumn */ ,;
		"", .t. /* lNoFolder */, .f.)
oEnchVC1:oBox:Align := CONTROL_ALIGN_ALLCLIENT

oLbRel := TWBrowse():New(0,0,50,50,,,,oWorkarea:GetPanel("RELACIONADOS") ,,,,,{ || aVetRel[oLbRel:nAt,01] := !aVetRel[oLbRel:nAt,01] },,,,,,,.F.,,.T.,,.F.,,,)
oLbRel:addColumn( TCColumn():New( "", { || IIf(aVetRel[oLbRel:nAt,01],oOkTik,oNoTik) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Tik
oLbRel:addColumn( TCColumn():New( RetTitle("VC1_TIPAGE") , { || aVetRel[oLbRel:nAt,03] } ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) )
oLbRel:addColumn( TCColumn():New( RetTitle("VC1_DATAGE") , { || Transform(aVetRel[oLbRel:nAt,04],"@D") } ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) )
oLbRel:addColumn( TCColumn():New( RetTitle("VC1_DATVIS") , { || Transform(aVetRel[oLbRel:nAt,05],"@D") } ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) )
oLbRel:addColumn( TCColumn():New( RetTitle("VC1_CODVEN") , { || aVetRel[oLbRel:nAt,06] } ,,,, "LEFT" , 99 ,.F.,.F.,,,,.F.,) )
oLbRel:Align := CONTROL_ALIGN_ALLCLIENT
oLbRel:nAT := 1
oLbRel:SetArray(aVetRel)

ACTIVATE MSDIALOG oVCM510REL ON INIT (EnchoiceBar(oVCM510REL,{|| ( lOkTela := .t. , oVCM510REL:End() ) },{ || oVCM510REL:End()},,))
//
If lOkTela
	For nCntFor := 1 to len(aVetRel)
		Do Case
			Case aVetRel[nCntFor,1] .and. !aVetRel[nCntFor,2] // Selecionou um Registro que nao estava selecionado
				DbSelectArea("VC1")
				DbGoTo(aVetRel[nCntFor,7])
				RecLock("VC1",.f.)
					VC1->VC1_CODREL := cCodRel // Relacionar
				MsUnLock()
			Case !aVetRel[nCntFor,1] .and. aVetRel[nCntFor,2] // Retirou um Registro que estava selecionado
				DbSelectArea("VC1")
				DbGoTo(aVetRel[nCntFor,7])
				RecLock("VC1",.f.)
					VC1->VC1_CODREL := "" // Retirar Relacionamento
				MsUnLock()
		EndCase
	Next
EndIf
//
Return