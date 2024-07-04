#INCLUDE "PCOA200.ch"
#INCLUDE "PROTHEUS.CH"
Static aCpoAK2_AKD	:= {}
Static aMovAK2_AKD	:= {}
Static nQtdEntid	:= Nil

//comentário para tradução!

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PCOA200  ³ Autor ³ Paulo Carnelossi      ³ Data ³ 10/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutecao das simulacoes de planilhas            ³±±
±±³          ³ orcamentarias                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCOA200()

PRIVATE cCadastro	:= STR0001 //"Simulacoes de Planilhas Orcamentarias"
PRIVATE aRotina := MenuDef()


mBrowse(6,1,22,75,"AKR")


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PCO200Dlg³ Autor ³ Paulo Carnelossi       ³ Data ³ 10/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ³±±
±±³          ³ Simulacao de Planilhas Orcamentarias.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco200Dlg(cAlias,nReg,nOpcx)
Local l200Inclui	:= .F.
Local l200Visual	:= .F.
Local l200Altera	:= .F.
Local l200Exclui	:= .F.
Local bOk           := {|| Pco200Atu()} //Bloco de código que será executado fora da transação
Local bOk2          := {|| PcoA200OK()} //Bloco de código para processamento na validação da confirmação das informações
Local aExec         := Array(4)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do Case
	Case (aRotina[nOpcx][4] == 2)
		l200Visual := .T.
	Case (aRotina[nOpcx][4] == 3) .Or. (aRotina[nOpcx,4] == 6)
		l200Inclui	:= .T.
	Case (aRotina[nOpcx][4] == 4)
		l200Altera	:= .T.
	Case (aRotina[nOpcx][4] == 5)
		l200Exclui	:= .T.
EndCase

If l200Inclui

	aExec[1] :=  {||} //Bloco de código que será processado antes da exibição das informações na tela
	aExec[2] :=  bOk2 //Bloco de código para processamento na validação da confirmação das informações
	aExec[3] :=  {||} //Bloco de código que será executado dentro da transação
	aExec[4] :=  bOk  //Bloco de código que será executado fora da transação

	PcoIniLan("000252")
	AxInclui(cAlias,nReg,nOpcx,,,,"PcoA200OK()",,,,aExec)
	PcoFinLan("000252")
Endif

If l200Altera
	dbSelectArea("AK3")
	AK1->(dbSetOrder(1))
	AK1->(dbSeek(xFilial()+AKR->AKR_ORCAME))
	If Empty(AKR->AKR_VERATU) .And. SoftLock("AKR")
		PcoA100(4,AKR->AKR_REVISA,.T.,.T.)
		AKR->(MsUnLockAll())
	Else
		Help("  ",1,"PcoA2002")
	EndIf
EndIf

If l200Visual
	AK1->(dbSetOrder(1))
	AK1->(dbSeek(xFilial()+AKR->AKR_ORCAME))
	PcoA100(2,AKR->AKR_REVISA,.T.,.T.)
EndIf

If l200Exclui
	If Empty(AKR->AKR_VERATU) .And. SoftLock("AKR")
		If AxDeleta(cAlias,nReg,nOpcx,"Pco200Del()") == 2
			AKR->(MsUnLockAll())
			PcoFinLan("000252")
		EndIf
	Else
		Help("  ",1,"PCOA2001")
	EndIf
EndIf


Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco200Atu³ Autor ³ Paulo Carnelossi       ³ Data ³ 10/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao das tabelas auxiliares do cadastro   ³±±
±±³          ³ de simulacoes de planilhas orcamentarias.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco200Atu()

AK1->(dbSetOrder(1))
AK1->(dbSeek(xFilial("AK1")+AKR->AKR_ORCAME))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o arquivo de revisoes com o historico inicial.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RecLock("AKE",.T.)
AKE->AKE_FILIAL := xFilial("AKE")
AKE->AKE_ORCAME := AK1->AK1_CODIGO
AKE->AKE_REVISA := AKR->AKR_REVISA
AKE->AKE_DATAI	:= MsDate()
AKE->AKE_HORAI  := Time()
AKE->AKE_DATAF  := MsDate()
AKE->AKE_HORAF	:= Time()
AKE->AKE_USERI  := RetCodUsr()
AKE->AKE_USERF  := RetCodUsr()
AKE->AKE_MEMO	:= STR0009 //"Simulacao de Planilha Orcamentaria"
AKE->AKE_TIPO	:= "2"	//Tipo 2 - Simulacao de Planilha
MsUnlock()

PcoRevisa(AK1->(RecNo()),2,AKR->AKR_VERBAS,AKR->AKR_REVISA,,.F.,.T.)


Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco200Del³ Autor ³ Paulo Carnelossi       ³ Data ³ 10/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de exclusao das tabelas auxiliares do cadastro  de  ³±±
±±³          ³ simulacoes de planilhas orcamentarias.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco200Del()

AK1->(dbSetOrder(1))
If AK1->(dbSeek(xFilial("AK1")+AKR->AKR_ORCAME))
	PcoIniLan("000252")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta as tabelas utilizadas na simulaca                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PcoRevisa(AK1->(RecNo()),3,AKR->AKR_REVISA,,,.F.,.T.)
	dbSelectArea("AKE")
	dbSetOrder(1)
	If dbSeek(xFilial("AKE")+AKR->AKR_ORCAME+AKR->AKR_REVISA)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Delete o arquivo de revisoes                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("AKE",.F.,.T.)
		dbDelete()
		MsUnlock()
	EndIf
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco200Eft³ Autor ³ Paulo Carnelossi       ³ Data ³ 10/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de efetivacao de uma versao simulada de planilha.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco200Eft(cAlias,nReg,nOpcx)
Local lContinua := .T.
Local cNextVer	:= ""

AK1->(dbSetOrder(1))
AK1->(dbSeek(xFilial("AK1")+AKR->AKR_ORCAME))

If Empty(AKR->AKR_VERATU) .And. SoftLock("AKR")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o projeto nao esta reservado.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AK1->AK1_STATUS=="2"
		Help("  ",1,"PcoA1201")
		lContinua := .F.
	Else
		lContinua := SoftLock("AK1")
	EndIf

	If lContinua .And. AxAltera(cAlias,nReg,nOpcx) == 1
		//Inico : Copia a simulaçao para uma revisao
		PcoIniLan("000252")
		Begin Transaction
		cNextVer := Soma1(If(Empty(AK1->AK1_VERREV), AK1->AK1_VERSAO, AK1->AK1_VERREV))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a versao nao existe e pega a proxima                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("AKE")
		dbSetOrder(1)
		While dbSeek(xFilial()+AK1->AK1_CODIGO+cNextVer)
			cNextVer := Soma1(cNextVer)
		End
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o arquivo de revisoes com o historico inicial.    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("AKE",.T.)
		AKE->AKE_FILIAL := xFilial("AKE")
		AKE->AKE_ORCAME := AK1->AK1_CODIGO
		AKE->AKE_REVISA := cNextVer
		AKE->AKE_DATAI	:= MsDate()
		AKE->AKE_HORAI  := Time()
		AKE->AKE_DATAF  := MsDate()
		AKE->AKE_HORAF	:= Time()
		AKE->AKE_USERI  := RetCodUsr()
		AKE->AKE_USERF  := RetCodUsr()
		AKE->AKE_MEMO	:= STR0010+AKR->AKR_REVISA //"Versao criada a partir da simulacao : "
		// SIMULACAO DE PROJETO PARA PROJETO NORMAL.
		AKE->AKE_TIPO	:= "1"
		MsUnlock()

		//Estorna saldos da simulacao
		dbSelectArea("AK2")
		dbSetOrder(1)
		dbSeek(xFilial()+AK1->AK1_CODIGO+AKR->AKR_REVISA)
		While !Eof() .And. xFilial()+AK1->AK1_CODIGO+AKR->AKR_REVISA==AK2->AK2_FILIAL+AK2->AK2_ORCAME+AK2->AK2_VERSAO
			PcoDetLan("000252","03","PCOA100",.T.)
			dbSelectArea("AK2")
			dbSkip()
		End
		cRevisa := PcoRevisa(AK1->(RecNo()),1,AKR->AKR_REVISA,cNextVer,.F.,.F.,.T.)

/*		RecLock("AKR",.F.)
		AKR->AKR_VERATU	:= cNextVer
		MsUnlock()
		RecLock("AK1",.F.)
		AK1->AK1_VERSAO := cNextVer
		AK1->AK1_VERREV	:= ""
		MsUnlock()
		dbSelectArea("AK2")
		dbSetOrder(1)
		dbSeek(xFilial()+AK1->AK1_CODIGO+AK1->AK1_VERSAO)
		While !Eof() .And. xFilial()+AK1->AK1_CODIGO+AK1->AK1_VERSAO==AK2->AK2_FILIAL+AK2->AK2_ORCAME+AK2->AK2_VERSAO
			PcoDetLan("000252","01","PCOA100")
			dbSelectArea("AK2")
			dbSkip()
		End
*/
		End Transaction
		PcoFinLan("000252")
		//Fim : Copia a simulaçao para uma revisao
		//Inicio : fecha a revisao
		Pco120RevFin(AK1->AK1_CODIGO, STR0010+AKR->AKR_REVISA)
		//Fim: fecha a revisao

		AK1->(MsUnlockAll())  //libera registro travado com softlock para garantir integridade
		Aviso(STR0011,STR0012+AK1->AK1_CODIGO+" : "+cNextVer+STR0013+AKR->AKR_REVISA+".",{"Ok"},2 ) //"Simulacao efetivada om sucesso."###"Versao atual do planilha orcamentaria "###" criada a partir da versao simulada : "
	EndIf
	AKR->(MsUnLockAll())
Else
	Help("  ",1,"PcoA2002")
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco200Cmp³ Autor ³ Paulo Carnelossi       ³ Data ³ 10/01/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Comparacao de versao das planilhas.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco200Cmp(cAlias,nReg,nOpcx)

AK1->(dbSetOrder(1))

If AK1->(dbSeek(xFilial("AK1")+AKR->AKR_ORCAME))
	Pco120CMP()
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pco200Mov³ Autor ³ Paulo Carnelossi       ³ Data ³ 06/04/2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa para inclusao de uma simulacao a partir da movimen- ³±±
±±³          ³ cao orcamentaria - tabela AKD                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco200Mov(cAlias,nReg,nOpcx)
Local lContinua := .F.
Local aPlanoCta := {}
Local aPlanoAux := {}
Local nX, cCtaSup, nNivCta
Local nZ
Local cCodCfgVis := "002"
Local cCampo, nTamanho, cVarIni, cVarFim
Local cFiltro := ""
Local cArqInd, cKey, nIndOrd
Local aPerPla, aPerMov
Local bOk
Local aAreaAK1
Local cConsPad	:= ""

Private lCompara := .F.
Private aAux
Private nRecAK1 := 0 //NAO DELETAR POIS E UTILIZADO NA FUNCAO A100INCPLAN
Private M->AKR_ORCAME := ""

aCpoAK2_AKD := {}
aMovAK2_AKD := {}

If nQtdEntid == Nil
	If cPaisLoc == "RUS" 
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf

dbSelectArea("AK1")
lContinua := A100IncPlan("AK1",0,3,"PCO100Atu()")

PcoIniLan("000252")
If lContinua .And. SoftLock("AK1")

	aAreaAK1 := AK1->(GetArea())

	aPerPla := PcoRetPer()

   aPerMov := A200Periodo(aPerPla)

	dbSelectArea("AK5")
	dbSetOrder(1)

	aParametros := {}
	aConfig := {}

	dbSelectArea("AKD")
	dbSelectArea("AKM")
	dbSeek(xFilial("AKM")+cCodCfgVis)
	While AKM->(!Eof().And. AKM_FILIAL+AKM_CONFIG == xFilial("AKM")+cCodCfgVis)

		cCampo := AKM->AKM_ENTFIL+"->"+AKM->AKM_CPOFIL

		If ValType(&cCampo) == "D"
			nTamanho := 8*7
			cVarIni := CTOD(&(AKM->AKM_VALINI))
			cVarFim := CTOD(&(AKM->AKM_VALFIM))
		Else
			nTamanho := Len(&(cCampo))*7
			cVarIni := &(AKM->AKM_VALINI)
			cVarFim := &(AKM->AKM_VALFIM)
		EndIf

		//---------------------------
		// Ajuste da consulta padrão
		//---------------------------
		If "AKD_VERSAO" $ cCampo
			cConsPad := "AKEVS"
		Else
			cConsPad := AKM->AKM_CONPAD
		EndIf

		aAdd(aParametros,{1,AllTrim(AKM->AKM_TITULO)+If(AKM->AKM_TIPO == "2",STR0017,""),cVarIni, "" ,"",cConsPad,"", nTamanho ,.F.}) //" de "

	   If AKM->AKM_TIPO == "2"
			aAdd(aParametros,{1,AllTrim(AKM->AKM_TITULO)+STR0018,cVarFim, "" ,"",AKM->AKM_CONPAD,"", nTamanho ,.F.}) //" ate "
	   EndIf

	   If Alltrim(Upper(cCampo)) == "AKD->AKD_DATA"
		   	bOk := MontaBlock("{||aConfig["+Alltrim(Str(Len(aParametros)-1))+"] >= AK1->AK1_INIPER .And. aConfig["+Alltrim(Str(Len(aParametros)))+"] <= AK1->AK1_FIMPER }")
	   EndIf
		AKM->(dbSkip())
	End
	//coloca filtro
	aAdd(aParametros,{7,STR0019,"AKD",""}) //"Filtro "
	aConfig := ARRAY(Len(aParametros))
	dbSelectArea("AKD")

	If ParamBox(  aParametros ,STR0020,aConfig,bOK,,.F.) //"Filtro para Geracao de Planilha de Simulacao por Movimentos"

	   //Montar o filtro de acordo as configuracoes acima
	   aHeaderCfg := {}
	   aVisConfig := {}

	   A180aHeaderCfg(aHeaderCfg, .F./*lVisual*/, aVisConfig, cCodCfgVis)

	   cFiltro:= A200MontaFiltro(aHeaderCfg, aVisConfig, aConfig)
	   RestArea(aAreaAK1)

	   cFiltro:= 'AKD_FILIAL == "'+xFilial("AKD")+'" .And.' + cFiltro

		//indregua na tabela AKD para filtrar as movimentacoes
		dbSelectArea("AKD")
		dbSetOrder(1)
		cArqInd := CriaTrab(NIL,.F.)

		cKey := IndexKey()

		IndRegua("AKD",cArqInd,cKey,,cFiltro) //"Selecionando Registros ..."
		nIndOrd := RetIndex("AKD")

		#IFNDEF TOP
			dbSetIndex( cArqInd + OrdBagExt() )
		#ENDIF

		dbSetOrder(nIndOrd+1)
		dbGotop()

		If AKD->(Eof())
			Help(" ",1,"PCO200MOV",,STR0027,1,0) // "Não foram localizados movimentos de acordo com os parâmetros informados."
		    Return
		Endif

		//inclui cadastro de simulacao
		dbSelectArea("AKR")
		RecLock("AKR", .T.)
		AKR->AKR_FILIAL := xFilial("AKR")
		AKR->AKR_ORCAME := AK1->AK1_CODIGO
		AKR->AKR_VERBAS := AK1->AK1_VERSAO
		AKR->AKR_REVISA := "8"+Subs(AK1->AK1_VERSAO, 2)
		AKR->AKR_DESCRI := STR0021+ALLTRIM(AK1->AK1_DESCRI) //"(SIMUL.MOVTO)-"
		MsUnLock()
		//para gerar revisao
		Pco200Atu()

		//montar a planilha simulada
		While AKD->(! Eof())

			nNivel := 2

			A200IncSimul(AKD->AKD_CO, @nNivel)

			dbSelectArea("AK3")
			dbSetOrder(1)
			If dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+AKR->AKR_REVISA+AKD->AKD_CO)

				A200IncItem(aPerPla, aPerMov,nQtdEntid)

	        EndIf

			AKD->(dbSkip())

	   End

	EndIf

	dbSelectArea("AK1")
	AK1->(MsUnlockAll())  //libera registro travado com softlock para garantir integridade

EndIf
PcoFinLan("000252")

dbSelectArea(cAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200IncSimul ºAutor ³Paulo Carnelossi   º Data ³ 15/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclui as contas orcamentarias ref ao movto(AKD) posicionadoº±±
±±º          ³utiliza recursividade ao chamar a funcao A200Nivel() para   º±±
±±º          ³chamar novamente A200IncSimul para as contas pai            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200IncSimul(cCtaOrc, nNivel)
Local aArea := GetArea()
Local aAreaAK5 := AK5->(GetArea())
Local aAreaAK3 := AK3->(GetArea())
Local nRecAk3, lNivel := .F.

dbSelectArea("AK5")
dbSetOrder(1)
If dbSeek(xFilial("AK5")+cCtaOrc)
	dbSelectArea("AK3")
	dbSetOrder(1)
	If ! dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+AKR->AKR_REVISA+cCtaOrc)
			RecLock("AK3",.T.)
			AK3->AK3_FILIAL	:= xFilial("AK3")
			AK3->AK3_ORCAME	:= AK1->AK1_CODIGO
			AK3->AK3_VERSAO	:= AKR->AKR_REVISA
			AK3->AK3_CO			:= cCtaOrc
			AK3->AK3_DESCRI	:= AK5->AK5_DESCRI
			If Empty(AK5->AK5_COSUP)
				AK3->AK3_PAI := AK1->AK1_CODIGO
				AK3->AK3_NIVEL := StrZero(2, Len(AK3->AK3_NIVEL))  // "002"
			Else
				AK3->AK3_PAI := AK5->AK5_COSUP
				nRecAK3 := AK3->(Recno())
				lNivel := .T.
			EndIf
			MsUnlock()

			If lNivel
				A200Nivel(AK5->AK5_COSUP,@nNivel)
				dbSelectArea("AK3")
				dbGoto(nRecAK3)
				RecLock("AK3",.F.)
				nNivel++
				AK3->AK3_NIVEL := StrZero(nNivel, Len(AK3->AK3_NIVEL))
				MsUnlock()
			EndIf
   Else
   	nNivel := Val(AK3->AK3_NIVEL)-1
	EndIf
EndIf

RestArea(aAreaAK5)
RestArea(aAreaAK3)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200Nivel  ºAutor ³Paulo Carnelossi    º Data ³  15/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna Nivel existente na planilha - funcao que eh chamada º±±
±±º          ³pela A200IncSimul e recursivamente chama novamente a funcao º±±
±±º          ³A200IncSimul                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200Nivel(cCtaSup, nNivel)
Local aArea := GetArea()
Local aAreaAK5 := AK5->(GetArea())
Local aAreaAK3 := AK3->(GetArea())

dbSelectArea("AK3")
dbSetOrder(1)
If ! dbSeek(xFilial("AK3")+AK1->AK1_CODIGO+AKR->AKR_REVISA+cCtaSup)
	A200IncSimul(cCtaSup, @nNivel)
Else
   nNivel := Val(AK3->AK3_NIVEL)
EndIf

RestArea(aAreaAK5)
RestArea(aAreaAK3)
RestArea(aArea)

Return(nNivel)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200IncItem ºAutor ³Paulo Carnelossi   º Data ³  15/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Inclui item orcamentario para o movimento posicionado (AKD) º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200IncItem(aPerPla, aPerMov,nQtdEntid)
Local nX
Local nPosCpo
Local nRecAK2 := 0

Default nQtdEntid := Iif(cPaisLoc$"RUS",PCOQtdEntd(),CtbQtdEntd()) //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.

Private nValorIt, nMoeda := 0
Private cIdAK2
Private aPerAux

nValorIt := A200Valor(@nMoeda)

If Empty(aCpoAK2_AKD)

	aAdd(aCpoAK2_AKD, { "AK2_FILIAL", 	{||AKD->AKD_FILIAL}})
	aAdd(aCpoAK2_AKD, { "AK2_ORCAME", 	{||AK1->AK1_CODIGO}})
	aAdd(aCpoAK2_AKD, { "AK2_VERSAO", 	{||AKR->AKR_REVISA}})
	aAdd(aCpoAK2_AKD, { "AK2_CO", 		{||AK3->AK3_CO}})
	aAdd(aCpoAK2_AKD, { "AK2_CC", 		{||AKD->AKD_CC}})
	aAdd(aCpoAK2_AKD, { "AK2_ITCTB",	{||AKD->AKD_ITCTB}})
	aAdd(aCpoAK2_AKD, { "AK2_CLVLR", 	{||AKD->AKD_CLVLR}})
	aAdd(aCpoAK2_AKD, { "AK2_UNIORC", 	{||AKD->AKD_UNIORC}})

	For nX := 5 To nQtdEntid
		Aadd(aCpoAK2_AKD, {"AK2_ENT"+StrZero(nX,2), MontaBlock( "{||AKD->AKD_ENT"+StrZero(nX,2)+"}" )})
	Next nX

	aAdd(aCpoAK2_AKD, { "AK2_CLASSE", 	{||AKD->AKD_CLASSE}})
	aAdd(aCpoAK2_AKD, { "AK2_DESCRI",	{||AKD->AKD_HIST}})
	aAdd(aCpoAK2_AKD, { "AK2_OPER", 		{||AKD->AKD_OPER}})
	aAdd(aCpoAK2_AKD, { "AK2_CHAVE", 	{||AKD->AKD_IDREF}})

	cIdAK2 := "0001"

	aAdd(aMovAK2_AKD, { "AK2_ID", 		{||cIdAK2 } })
	aAdd(aMovAK2_AKD, { "AK2_VALOR", 	{||nValorIt} })
	aAdd(aMovAK2_AKD, { "AK2_PERIOD", 	{||aPerAux[1]}})
	aAdd(aMovAK2_AKD, { "AK2_DATAI", 	{||aPerAux[1]}})
	aAdd(aMovAK2_AKD, { "AK2_DATAF", 	{||aPerAux[2]}})
	aAdd(aMovAK2_AKD, { "AK2_MOEDA", 	{||nMoeda}})

	aPerAux := A200VerPeriodo(AKD->AKD_DATA, aPerPla, aPerMov)

	If !Empty(aPerAux[1])
		A200Grv(aCpoAK2_AKD, aMovAK2_AKD, .T.)
	EndIf

Else

	lCompara := .T.
	cIdAK2 := A200ItAK2(aCpoAK2_AKD, lCompara)
	aPerAux := A200VerPeriodo(AKD->AKD_DATA, aPerPla, aPerMov)

	If !Empty(aPerAux[1])
	   //verifica se existe o registro - se existir ja deixa posicionado para atualizar
		lInclReg := A200VerExist(aCpoAK2_AKD, aPerAux, nMoeda)
		A200Grv(aCpoAK2_AKD, aMovAK2_AKD, lInclReg)
	EndIf

EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200Grv   ºAutor  ³Paulo Carnelossi    º Data ³  28/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³grava item orcamentario (ou somente atualiza valor)         º±±
±±º          ³Inclusao por Movimento                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200Grv(aCpoAK2_AKD, aMovAK2_AKD, lInclReg)
Local nRecAk2 := 0
Local nPosCpo := 0
Local nX

dbSelectArea("AK2")
dbSetOrder(1)

If lInclReg
	RecLock("AK2", .T.)
Else
	RecLock("AK2", .F.)
EndIf
nRecAK2 := AK2->(Recno())

If lInclReg
	For nX := 1 TO Len(aCpoAK2_AKD)
		If (nPosCpo := FieldPos(aCpoAK2_AKD[nX][1])) > 0
			FieldPut(nPosCpo, Eval(aCpoAK2_AKD[nX][2]))
		EndIf
	Next
EndIf

If lInclReg

	For nX := 1 TO Len(aMovAK2_AKD)
		If (nPosCpo := FieldPos(aMovAK2_AKD[nX][1])) > 0
			FieldPut(nPosCpo, Eval(aMovAK2_AKD[nX][2]))
		EndIf
	Next

Else

   //Atualizar somente o valor
   //o registro tem que estar posicionado

   AK2->AK2_VALOR += Eval(aMovAK2_AKD[2][2])

EndIf

MsUnLock()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200Valor ºAutor  ³Paulo Carnelossi    º Data ³  28/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ retorna o valor e a moeda do movimento                     º±±
±±º          ³ obs: a moeda retorna por referencia                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200Valor(nMoeda)
Local nValor := 0
If !Empty(AKD->AKD_VALOR1)
	nValor := AKD->AKD_VALOR1
	nMoeda := 1
ElseIf !Empty(AKD->AKD_VALOR2)
	nValor := AKD->AKD_VALOR2
	nMoeda := 2
ElseIf !Empty(AKD->AKD_VALOR3)
	nValor := AKD->AKD_VALOR3
	nMoeda := 3
ElseIf !Empty(AKD->AKD_VALOR4)
	nValor := AKD->AKD_VALOR4
	nMoeda := 4
ElseIf !Empty(AKD->AKD_VALOR5)
	nValor := AKD->AKD_VALOR5
	nMoeda := 5
EndIf

Return(nValor)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200VerExist ºAutor  ³Paulo Carnelossi º Data ³  28/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se ja existe item orcamentario igual ao movto      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200VerExist(aCpoAK2_AKD, aPerAux, nMoeda)
Local lRet := .T.

dbSelectArea("AK2")
dbSetOrder(5)
If dbSeek(xFilial("AK2")+AK1->AK1_CODIGO+AKR->AKR_REVISA+AK3->AK3_CO)

	While AK2->(!Eof().And.AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO == ;
					xFilial("AK2")+AK1->AK1_CODIGO+AKR->AKR_REVISA+AK3->AK3_CO)

		If A200VerIgual(aCpoAK2_AKD) .And. ;
			AK2->AK2_PERIOD == aPerAux [1] .And. ;
			AK2->AK2_DATAI == aPerAux [1] .And. ;
			AK2->AK2_DATAF == aPerAux [2] .And. ;
			AK2->AK2_MOEDA == nMoeda
			lRet := .F.
			EXIT
		EndIf

		AK2->(dbSkip())

	End

EndIf

dbSelectArea("AK2")

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200ItAK2ºAutor ³Paulo Carnelossi      º Data ³  15/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o item a ser gravado na tabela AK2 - incrementa 1   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200ItAK2(aCpoAK2_AKD, lCompara)
Local nItAK2 := 0
Local cItAK2
Local lIncrementa := .T.
Local aArea := AK2->(GetArea())

dbSelectArea("AK2")
dbSetOrder(5)
If dbSeek(xFilial("AK2")+AK1->AK1_CODIGO+AKR->AKR_REVISA+AK3->AK3_CO)

	While AK2->(!Eof().And.AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO == ;
					xFilial("AK2")+AK1->AK1_CODIGO+AKR->AKR_REVISA+AK3->AK3_CO)
		If lCompara .And. A200VerIgual(aCpoAK2_AKD)
			nItAK2 := VAL(AK2->AK2_ID)
			lIncrementa := .F.
			EXIT
		Else
			nItAK2 := VAL(AK2->AK2_ID)
		EndIf

		AK2->(dbSkip())

	End

EndIf

If lIncrementa
	nItAK2++
EndIf

cItAK2 := StrZero(nItAK2, Len(AK2->AK2_ID))

RestArea(aArea)
dbSelectArea("AK2")

Return(cItAK2)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200VerIgual ºAutor  ³Paulo Carnelossi º Data ³  28/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Compara AK2 (ITEM ORCAMENTO) COM AKD (MOVTO ORCTO) conforme º±±
±±º          ³array aCpoAK2_AKD e se for igual retorna .T.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200VerIgual(aCpoAK2_AKD)
Local aRet := ARRAY(Len(aCpoAK2_AKD))
Local lRet := .T.
Local nX
Local cCpoAK2

AFILL(aRet, .F.)

For nX := 1 TO Len(aCpoAK2_AKD)
	nPosCpo := AK2->(FieldPos(aCpoAK2_AKD[nX][1]))
	If nPosCpo > 0
		cCpoAK2 := AK2->(FieldGet(nPosCpo))
		aRet[nX] := (cCpoAK2==PadR(Eval(aCpoAK2_AKD[nX][2]),Len(cCpoAK2)))
	EndIf
Next

For nX := 1 TO Len(aRet)
	If !aRet[nX]
		lRet := .F.
		Exit
   EndIf
Next

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200VerPeriodo ºAutor ³Paulo Carnelossiº Data ³  15/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna array com data inicio e fim do periodo do movto     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200VerPeriodo(dDataMov, aPerPla, aPerMov)
Local aRetorno := {CTOD('  /  /  '), CTOD('  /  /  ')}
Local dIni, dFim
Local nX

For nX := 1 TO Len(aPerPla)
	dIni := CTOD(Subs(aPerPla[nX], 1, 10))
	dFim := CTOD(Alltrim(Subs(aPerPla[nX], 14)))
	If dDataMov >= aPerMov[nX][1].And. dDataMov <= aPerMov[nX][2]
		aRetorno[1] := dIni
		aRetorno[2] := dFim
		Exit
	EndIf
Next

Return(aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200Periodo  ºAutor ³Paulo Carnelossi    º Data ³ 18/04/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta tela com os periodos da planilha e permite modificar  º±±
±±º          ³data a ser considerada no mov para montagem da planilha     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200Periodo(aPerPla)
Local aParDate := {}, aParam := {}
Local aPerMov := {}
Local nX, dIni, dFim
Local oDlg
Local nLinha := 8

Private aPer_Pla, aPer_Mov

DEFINE MSDIALOG oDlg TITLE STR0022 FROM 0,0 TO 274,445 OF oMainWnd Pixel //"Considerar Datas de Movimentos por Periodo"

oPanel := TScrollBox():New( oDlg, 8,10,104,203)
oPanel:Align := CONTROL_ALIGN_ALLCLIENT

TSay():New( nLinha, 15 , MontaBlock("{||'"+STR0023+"'}") , oPanel , ,,,,,.T.,CLR_BLACK,,,,,,,,) //"Para Alterar Data Marque o CheckBox:"
nLinha += 17

For nX := 1 TO Len(aPerPla)
	dIni := CTOD(Subs(aPerPla[nX], 1, 10))
	dFim := CTOD(Alltrim(Subs(aPerPla[nX], 14)))
	aAdd(aPerMov, {dIni,dFim})

	&("MV_PAR"+AllTrim(STRZERO(nx,2,0))) := .F.
	cBlkGet := "{ | u | If( PCount() == 0, "+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+","+"MV_PAR"+AllTrim(STRZERO(nx,2,0))+":= u ) }"
	cBlkWhen := "{|| .T. }"

	TCheckBox():New(nLinha,75,aPerPla[nx], &cBlkGet,oPanel, 120,10,,{|oCheck|A200Mod_Data(oCheck)},,,,,,.T.,,,&(cBlkWhen))
	nLinha += 17

Next

aPer_Pla := ACLONE(aPerPla)
aPer_Mov := ACLONE(aPerMov)

oPanelB := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,40,20,.T.,.T. )
oPanelB:Align := CONTROL_ALIGN_BOTTOM

DEFINE SBUTTON FROM 4, 190   TYPE 1 ENABLE OF oPanelB ACTION (lOk:=.T.,oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED

Return(aPer_Mov)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200Mod_Data ºAutor ³Paulo Carnelossi    º Data ³ 18/04/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Permite modificar a data a ser considerada para o periodo daº±±
±±º          ³planilha                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200Mod_Data(oCheck)
Local aParaData := {}, aParam := {}
Local dIni, dFim, nPos
Local aSavPar := {MV_PAR01, MV_PAR02}
nPos := ASCAN(aPer_Pla, oCheck:cTitle)

dIni := aPer_Mov[nPos,1]
dFim := aPer_Mov[nPos,2]

MV_PAR01 := dIni
MV_PAR02 := dFim

aAdd(aParaData,{1,STR0024,dIni, "" ,"",,"", 8*7 ,.T.}) //" Considerar Movto. de "
aAdd(aParaData,{1,STR0025,dFim, "" ,"",,"", 8*7 ,.T.}) //" Considerar Movto. Ate "

If ParamBox(aParaData ,STR0026+aPer_Pla[nPos],aParam,,,.F.)  //"Periodo de "
	aPer_Mov[nPos,1] := aParam[1]
	aPer_Mov[nPos,2] := aParam[2]
EndIf

MV_PAR01 := aSavPar[01]
MV_PAR02 := aSavPar[02]

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A200MontaFiltro ºAutor ³Paulo Carnelossi º Data ³ 15/04/05  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta o filtro para a configuracao visao 002 de acordo com  º±±
±±º          ³retorno da parambox montada acima funcao pco200mov          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A200MontaFiltro(aHeaderCfg, aVisConfig, aConfig)
Local nX, nY, nCtd := 1
Local aAuxFil := {}
Local cEntFil, cCpoFil, cCpoRef, cTipo, cFiltro, nPosCol
Local cCompFiltro, lFlag

Local nEntFil 	:= aScan(aVisConfig[1],{|x| AllTrim(x[1])=="AKM_ENTFIL"})
Local nCpoFil 	:= aScan(aVisConfig[1],{|x| AllTrim(x[1])=="AKM_CPOFIL"})
Local nTipo  	:= aScan(aVisConfig[1],{|x| AllTrim(x[1])=="AKM_TIPO"})
Local nPlanilha := Ascan(aHeaderCfg,{|x| AllTrim(x[2]) == "AKP_CRF01"})

For nX := 1 TO Len(aVisConfig)

	cEntFil := aVisConfig[nX][nEntFil][2]
	cCpoFil := aVisConfig[nX][nCpoFil][2]
	cCpoRef := "AKP_CRF"+StrZero(nX,2)
   cTipo   := aVisConfig[nX][nTipo][2]

	aAdd(aAuxFil,{cEntFil, cCpoFil, cCpoRef+If(cTipo=="1","","1"), cTipo, aConfig[nCtd]})
   nCtd++

	If cTipo == "2"
		aAdd(aAuxFil,{cEntFil, cCpoFil, cCpoRef+"2", cTipo, aConfig[nCtd]})
		nCtd++
	EndIf

Next


cFiltro := "( "

For nY := 1 TO Len(aAuxFil)

	nPosCol := aScan(aHeaderCfg,{|x| AllTrim(x[2])==AllTrim(aAuxFil[nY][3])})
	lFlag := .F.

	If nPosCol > 0
		If aAuxFil[nY][4]=="1"
			If !Empty(aAuxFil[nY][5])
				lFlag := .T.
				If aHeaderCfg[nPosCol][8] == "C"
					cFiltro += Alltrim(aAuxFil[nY][1])+"->"+Alltrim(aAuxFil[nY][2])
					cFiltro += " == "
					cFiltro += "PadR('"+aAuxFil[nY][5]+"', Len("+Alltrim(aAuxFil[nY][1])+"->"+Alltrim(aAuxFil[nY][2])+"))"

				ElseIf aHeaderCfg[nPosCol][8] == "N"
					cFiltro += Alltrim(aAuxFil[nY][1])+"->"+Alltrim(aAuxFil[nY][2])
					cFiltro += " == "
					cFiltro += "'"+Str(aAuxFil[nY][5],15,2)+"'"

				ElseIf aHeaderCfg[nPosCol][8] == "D"
					cFiltro += "DTOS("+Alltrim(aAuxFil[nY][1])+"->"+Alltrim(aAuxFil[nY][2])+")"
					cFiltro += " == "
					cFiltro += "DTOS(CTOD('"+DTOC(aAuxFil[nY][5])+"'))"

				EndIf
			EndIf
		Else
			lFlag := .T.
			If Right(Alltrim(aAuxFil[nY][3]),1)=="1"
				cCompFiltro := " >= "
			Else
				cCompFiltro := " <= "
			EndIf

			If aHeaderCfg[nPosCol][8] == "C"
				cFiltro += Alltrim(aAuxFil[nY][1])+"->"+Alltrim(aAuxFil[nY][2])
				cFiltro += cCompFiltro
				cFiltro += "PadR('"+aAuxFil[nY][5]+"', Len("+Alltrim(aAuxFil[nY][1])+"->"+Alltrim(aAuxFil[nY][2])+"))"

			ElseIf aHeaderCfg[nPosCol][8] == "N"
				cFiltro += Alltrim(aAuxFil[nY][1])+"->"+Alltrim(aAuxFil[nY][2])
				cFiltro += cCompFiltro
				cFiltro += "'"+Str(aAuxFil[nY][5],15,2)+"'"

			ElseIf aHeaderCfg[nPosCol][8] == "D"
				cFiltro += "DTOS("+Alltrim(aAuxFil[nY][1])+"->"+Alltrim(aAuxFil[nY][2])+")"
				cFiltro += cCompFiltro
				cFiltro += "DTOS(CTOD('"+DTOC(aAuxFil[nY][5])+"'))"
			EndIf

		EndIf

		If lFlag .And. nY < Len(aAuxFil)
			cFiltro += " .And. "
		EndIf
   EndIf
Next

If !Empty(aConfig[Len(aConfig)])
	cFiltro += " .And. ("
	cFiltro += AllTrim(aConfig[Len(aConfig)])+")"
EndIf

cFiltro += " )"

Return(cFiltro)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³29/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local aRotina 	:= {	{ STR0002		, "AxPesqui"  , 0 , 1, ,.F.},; //"Pesquisar"
							{ STR0003		, "PCO200Dlg" , 0 , 2},; //"Visualizar"
							{ STR0004			, "PCO200Dlg" , 0 , 3},; //"Incluir"
							{ STR0005			, "PCO200Dlg" , 0 , 4},; //"Alterar"
							{ STR0006			, "PCO200Dlg" , 0 , 5},; //"Excluir"
							{ STR0007		, "PCO200Cmp" , 0 , 5},; //"Comparar"
							{ STR0014, 	"PCO200Mov" , 0 , 3},; //"Incl/Mov."
							{ STR0008		, "PCO200Eft" , 0 , 4} } //"Efetivar"
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoA200OK ºAutor  ³Microsiga           º Data ³  17/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validar se  ja existe a revisao na tabela AKE, pois esta eh º±±
±±º          ³compartilhada com a rotina de simulacao                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PcoA200OK(lHelp)
Local lRet := .T.
Local aArea := GetArea()
Local aAreaAKE := AKE->(GetArea())

DEFAULT lHelp := .T.

dbSelectArea("AKE")
dbSetOrder(1)

lRet := ! MsSeek(xFilial("AKE")+M->AKR_ORCAME+M->AKR_REVISA)

If lHelp .And. !lRet   //se encontrado o registro na tabela AKE informa e nao permite confirmar
	Help(" ",1,"JAGRAVADO")
EndIf

RestArea(aAreaAKE)
RestArea(aArea)

Return(lRet)
