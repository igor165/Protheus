#INCLUDE "Protheus.ch"
#INCLUDE "ATFA300.CH"

// 17/08/2009 - Ajuste para filiais com mais de 2 caracteres.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA300   บAutor  ณMarcos S. Lobo      บ Data ณ  09/26/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCadastro de Ap๓lices de Seguros                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP - SIGAATF                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFA300()

Local cArqMain		:= "SNB"
Local aAreaATF90	:= GetArea()

Private cCadastro	:= STR0001 ///"Ap๓lices de Seguro"

dbSelectArea("SX2")
dbSetOrder(1)
If dbSeek(cArqMain)
	cCadastro := X2Nome()
Endif

Private aRotina := MenuDef()

dbSelectArea(cArqMain)
MsSeek(xFilial(cArqMain))
mBrowse( 6, 1,22,75,cArqMain,,,,,,)

RestArea(aAreaATF90)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF300Vis  บAutor  ณMarcos S. Lobo      บ Data ณ  09/26/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVisualiza็ใo de Ap๓lice de Seguros                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP - SIGAATF                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF300Vis(cAlias,nReg,nOpc)

If Empty(cAlias)
	cAlias := Alias()
Endif

If Empty(nReg)
	nReg := (cAlias)->(Recno())
Endif

AxVisual(cAlias,nReg,nOpc)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF300Inc  บAutor  ณMarcos S. Lobo      บ Data ณ  09/26/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclusใo de Ap๓lice de Seguros                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP - SIGAATF                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                            
Function AF300Inc(cAlias,nReg,nOpc)

Local lNBDADOS	:= .F.
Public cNBDADOS 	:= ""

If Empty(cAlias)
	cAlias := Alias()
Endif

If Empty(nReg)
	nReg := (cAlias)->(Recno())
Endif

lNBDADOS := X3Usado("NB_DADOS")

If AxInclui(cAlias,nReg,nOpc,,,,,,IIf(lNBDADOS,"LoadNBDADOS(3)",),,,,.T.) == 1
	
	If lNBDADOS
		cSNECHAVE := SNB->(NB_APOLICE+NB_CODSEG)
		If Empty(MEUMEMO("SNE",cSNECHAVE,cNBDADOS,3))									//// GRAVACAO DO CONTEUDO DO MEMO
			MsgInfo(STR0007+ALLTRIM(SNB->NB_APOLICE)+" !",STR0008)
		Endif
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF300Alt  บAutor  ณMarcos S. Lobo      บ Data ณ  09/26/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAltera็ใo de Ap๓lice de Seguros                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP - SIGAATF                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF300Alt(cAlias,nReg,nOpc)

Local lNBDADOS 	:= .F.
Public cNBDADOS := ""

If Empty(cAlias)
	cAlias := Alias()
Endif

If Empty(nReg)
	nReg := (cAlias)->(Recno())
Endif
            
lNBDADOS 	:= X3Usado("NB_DADOS")

If AxAltera(cAlias,nReg,nOpc,,,,,,If(lNBDADOS,"LoadNBDADOS(3)",),If(lNBDADOS,"LoadNBDADOS(4)",),,,,.T.) == 1
	dbSelectArea("SN1")
	dbSetOrder(5)
	If MsSeek(xFilial("SN1")+SNB->(NB_APOLICE+NB_CODSEG),.F.)
		While !SN1->(Eof()) .and. SN1->(N1_FILIAL+N1_APOLICE+N1_CODSEG) == xFilial("SN1")+SNB->(NB_APOLICE+NB_CODSEG)
			RecLock("SN1",.F.)
			Field->N1_DTVENC  := SNB->NB_DTVENC
			Field->N1_CSEGURO := SNB->NB_CSEGURO
			SN1->(MsUnlock())
			SN1->(dbSkip())
		Enddo
	Endif
	
	If lNBDADOS
		cSNECHAVE := SNB->(NB_APOLICE+NB_CODSEG)
		If Empty(MEUMEMO("SNE",cSNECHAVE,cNBDADOS,4))									//// ALTERACAO DO CONTEUDO DO MEMO
			MsgInfo(STR0009+ALLTRIM(SNB->NB_APOLICE)+" !",STR0008)
		Endif
	Endif
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF300Del  บAutor  ณMarcos S. Lobo      บ Data ณ  09/26/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclusใo de Ap๓lice de Seguros                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP - SIGAATF                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF300Del(cAlias,nReg,nOpc)

Local cMsg 	  := ""
Local aAreaNB := {}
Local lNBDADOS := .F.

If Empty(cAlias)
	cAlias := Alias()
Endif

If Empty(nReg)
	nReg := (cAlias)->(Recno())
Endif

lNBDADOS := X3Usado("NB_DADOS")

dbSelectArea(cAlias)
dbGoTo(nReg)
aAreaNB := GetArea()

If AxVisual(cAlias,nReg,nOpc) == 1
	
	dbSelectArea("SN1")
	dbSetOrder(5)
	If MsSeek(xFilial("SN1")+SNB->(NB_APOLICE+NB_CODSEG),.F.)
		cMsg := STR0010 ///"Deseja retirar o seguro destes bens e excluir a ap๓lice ?"
		
		If !MsgYesNo(cMsg,STR0011)///"Aten็ใo ! Bens relacionados a esta ap๓lice."
			cMsg := STR0012+ALLTRIM(SNB->NB_APOLICE)+STR0013+ALLTRIM(SNB->NB_CSEGURO)+STR0014 //// "A ap๓lice " # " da Cia. de Seguros " # " foi mantida."
			MsgInfo(cMsg)
			RestArea(aAreaNB)			/// SE NAO CONFIRMOU A LIMPEZA DOS BENS
			Return						/// RESTAURA AREA E CANCELA
		Endif
		
		While !SN1->(Eof()) .and. SN1->(N1_FILIAL+N1_APOLICE+N1_CODSEG) == xFilial("SN1")+SNB->(NB_APOLICE+NB_CODSEG)
			RecLock("SN1",.F.)
			Field->N1_APOLICE := ""
			Field->N1_CODSEG  := ""
			Field->N1_DTVENC  := CTOD("  /  /  ")
			Field->N1_CSEGURO := ""
			SN1->(MsUnlock())
			SN1->(dbSkip())
		Enddo
	Endif
	
	If lNBDADOS
		cSNECHAVE := SNB->(NB_APOLICE+NB_CODSEG)
		If !MEUMEMO("SNE",cSNECHAVE,"",5)									//// DELECAO DO CONTEUDO DO MEMO
			MsgInfo(STR0015+ALLTRIM(SNB->NB_APOLICE)+" !",STR0008) ///"Nao foi possํvel excluir os DADOS ADICIONAIS da apolice " # "Contate o Administrador"
		Endif
	Endif
	
	RecLock(cAlias,.F.)
	(cAlias)->(dbDelete())
	(cAlias)->(MsUnLock())
Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA300   บAutor  ณMicrosiga           บ Data ณ  09/26/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSugere o vencimento para a Ap๓lice de Seguro com base na    บฑฑ
ฑฑบ          ณdata de inํcio de vig๊ncia.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP - SIGAATF                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AF300Venc(dNBDTINI)

Local dNBDTVENC := dDataBase

If Empty(dNBDTINI)
	dNBDTINI := dDataBase
Endif

dNBDTVENC := CTOD(substr(DTOC(dNBDTINI),1,6)+SUBSTR(ALLTRIM(STR(Year(dNBDTINI)+1)),3,2))

M->NB_DTVENC := dNBDTVENC

Return(dNBDTVENC)

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ MEUMEMO  ณ Autor ณ Marcos S. Lobo   	  ณ Data   ณ 02/10/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao para Leitura e Gravacao de campo MEMO Virtual		  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe	 ณ MEUMEMO(cTable,cChave,cString,nOpc)						  ณฑฑ
ฑฑณ       	 ณ cTable 	= Alias da Tabela onde sera gravado o MEMO		  ณฑฑ
ฑฑณ       	 ณ cChave	= Chave Unica para identificacao do MEMO 		  ณฑฑ
ฑฑณ       	 ณ cString	= Conteudo Integral do Memo a ser gravado 		  ณฑฑ
ฑฑณ       	 ณ nOpc		= Opcao a ser executada (2=Vis/3=Inc/4=Alt/5=Exc) ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno	 ณDe acordo com o parametro nOpc					 		  ณฑฑ
ฑฑณ       	 ณnOpc == 3/4 (Inc/Alt)		Retorno = Char   (Chave do MEMO)  ณฑฑ
ฑฑณ       	 ณnOpc == 2   (Visual)		Retorno = Char   (Texto do MEMO)  ณฑฑ
ฑฑณ       	 ณnOpc == 5   (Exclusao)	Retorno = Logico (.T./.F. Exclui) ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ SIGAATF		 											  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
Function MEUMEMO(cTable,cChave,cString,nOpc)

Local cAliasOld := Alias()
Local nOrdX3	:= SX3->(IndexOrd())
Local nRecX3	:= SX3->(Recno())

Local uRet      := " "
Local cMEMO		:= ""

Local cPrefCPO			:= ""
Local nStr				:= 1

If Empty(cTable)							//// DEVE CONTER O NOME DA TABELA A SER GRAVADA
	cTable := Alias()
Endif

If Empty(cTable) .or. Empty(cChave)
	If nOpc == 5
		Return .F.
	Else
		Return("")
	Endif
Endif

dbSelectArea("SX3")
dbSetOrder(1)
If !MsSeek(cTable)
	Alert(STR0016+cTable+STR0017) ///"Tabela " # " nao encontrada no Dicionario !"
	If nOpc == 5
		Return .F.
	Else
		Return("")
	Endif
Endif

cPrefCPO		:= Left(SX3->X3_CAMPO,At("_",SX3->X3_CAMPO))						/// PREFIXO DOS CAMPOS PARA A TABELA
cCpoFILIAL		:= cPrefCPO+"FILIAL"												/// NOME DO CAMPO FILIAL
cCpoKEY	  		:= cPrefCPO+"KEY"													/// NOME DO CAMPO QUE CONTERA A CHAVE
cCpoSEQUEN		:= cPrefCPO+"SEQUEN"												/// NOME DO CAMPO COM A SEQUENCIA
cCpoMEMO		:= cPrefCPO+"MEMO"													/// NOME DO CAMPO COM O CONTEUDO DO TEXTO
nTam			:= Len(CriaVar(cCpoMEMO))											/// TAMANHO DO CAMPO COM O CONTEUDO DO TEXTO

//verifica se o campo existe na tabela
nOpc    := If(nOpc == NIL,3,nOpc)

If Select(cTable) == 0
	If !ChkFile(cTable)
		MsgStop(cTable+STR0018)///" - Falha de abertura."
		If nOpc == 5
			Return .F.
		Else
			Return("")
		Endif
	EndIf
EndIf

DbSelectArea(cTable)
DbSetOrder(1)
cFilial	:= xFilial(cTable)
MsSeek(cFilial+cChave)

cInFILIAL := &(cTable+"->"+cCpoFILIAL)						//// VARIAVEL COM O CONTEUDO DA FILIAL POSICIONADA
cInKEY	  := &(cTable+"->"+cCpoKEY)						//// VARIAVEL COM O CONTEUDO DO KEY POSICIONADO
cInMEMO	  := &(cTable+"->"+cCpoMEMO)						//// VARIAVEL COM O CONTEUDO TEXTO POSICIONADO
cInSEQUEN := &(cTable+"->"+cCpoSEQUEN)						//// VARIAVEL COM O CONTEUDO DA SEQUENCIA POSICINADA

cChave  := PADR(cChave,Len(cInKEY))

If nOpc == 2												/// LEITURA DOS REGISTROS (RETORNA O CONTEUDO)
	uRet	:= ""
	cString := ""
	While !Eof() .And. cFilial+cChave == cInFILIAL+cInKEY
		cString += cInMEMO
		(cTable)->(	dbSkip())
		cInFILIAL := &(cTable+"->"+cCpoFILIAL)
		cInKEY	  := &(cTable+"->"+cCpoKEY)
		cInMEMO	  := &(cTable+"->"+cCpoMEMO)
		cInSEQUEN := &(cTable+"->"+cCpoSEQUEN)
	End
	uRet := cString
ElseIf nOpc == 5											/// SE FOR EXCLUSAO APAGA OS REGISTROS (RETORNA .T./.F.)
	// Excluir campo MEMO
	uRet := .F.
	While !Eof() .And. cFilial+cChave == cInFILIAL+cInKEY
		RecLock(cTable,.F.)
		DbDelete()
		MsUnLock()
		(cTable)->(	dbSkip())
		cInFILIAL := &(cTable+"->"+cCpoFILIAL)
		cInKEY	  := &(cTable+"->"+cCpoKEY)
		cInMEMO	  := &(cTable+"->"+cCpoMEMO)
		cInSEQUEN := &(cTable+"->"+cCpoSEQUEN)
	End
	uRet:=.T.
Else														/// CASO CONTRมRIO DEVE FAZER GRAVACAO (INCLUSAO/ALTERACA)
	uRet := ""
	cString		:= AllTrim(cString)							/// LIMPA OS ESPACOS EM BRANCO A DIREITA E A ESQUERDA NO TEXTO
	nLenStr		:= Len(cString)								/// TAMANHO DO STRING DE TEXTO
	nStepNum	:= 1										/// NUMERO DO STEP PARA IDENTIFICACAO DA SEQUENCIA
	nTCpoSEQUEN := Len(cInSEQUEN)							/// TAMANHO DO CAMPO SEQUEN (PARA O STRZERO)
	
	For nStr := 1 to nLenStr Step nTam
		cMEMO 		:= Substr(cString,nStr,nTam)
		cSEQUEN		:= STRZERO(nStepNum,nTCpoSEQUEN)
		dbSelectArea(cTable)
		dbSetOrder(1)
		If MsSeek(cFilial+cChave+cSEQUEN) .and. nOpc == 4 /// SE ENCONTRAR E FOR ALTERACAO (PARA NO CASO DE PROBLEMAS NAO PERDER O CONTEUDO)
			If cMEMO <> &(cTable+"->"+cCpoMEMO)		   /// SO REGRAVA SE O TEXTO FOI ALTERADO
				RecLock(cTable,.F.)
				&("Field->"+cCpoFILIAL) := cFilial
				&("Field->"+cCpoKEY)	 := cChave
				&("Field->"+cCpoSEQUEN)	 := cSEQUEN
				&("Field->"+cCpoMEMO)	 := cMEMO
				(cTable)->(MsUnlock())
			Endif
		Else											   /// SE FOR INCLUSAO NAO ALTERA... SEMPRE ADICIONA (PARA NAO PERDER O CONTEUDO NO CASO DE PROBLEMAS)
			RecLock(cTable,.T.)
			&("Field->"+cCpoFILIAL) := cFilial
			&("Field->"+cCpoKEY)	 := cChave
			&("Field->"+cCpoSEQUEN)	 := cSEQUEN
			&("Field->"+cCpoMEMO)	 := cMEMO
			(cTable)->(MsUnlock())
		Endif
		nStepNum++
	Next
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	//// NO CASO DE ALTERACAO VERIFICA SE HOUVE DELECAO DE LINHAS - ELIMINANDO AS EXCEDENTES
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	If nOpc <> 3											/// SE NAO FOR INCLUSAO
		DbSelectArea(cTable)
		cSEQUEN		:= STRZERO(nStepNum,nTCpoSEQUEN)
		If MsSeek(cFilial+cChave+cSEQUEN,.F.)
			While !(cTable)->(Eof()) .And. cFilial+cChave == &(cTable+"->("+cCpoFILIAL+"+"+cCpoKEY+")")
				RecLock(cTable,.f.)
				(cTable)->(dbDelete())
				(cTable)->(MsUnlock())
				(cTable)->(dbSkip())
			EndDo
		Endif
	Endif
	uRet := cChave
Endif

SX3->(dbSetOrder(nOrdX3))
SX3->(dbGoTo(nRecX3))
DbSelectArea(cAliasOld)

Return uRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLoadNBDADOบAutor  ณMarcos S. Lobo      บ Data ณ  10/03/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณBloco executado na AxInclui/AxAltera (Dentro da Transacao)  บฑฑ
ฑฑบ          ณpara obter o texto contido no campo memo virtual            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP - Campos Memo em Cadastro do tipo Enchoice (AxXXXXXX)   บฑฑ
ฑฑบ          ณ Cadastro de Apolices de Seguros - SIGAATF                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function LoadNBDADOS(nOpc)

Local cReturn := ""

If nOpc == 3 .or. Empty(nOpc)
	cReturn	:= "cNBDADOS := M->NB_DADOS"
ElseIf nOpc == 4
	If Empty(M->NB_DADOS)
		cReturn	:= 'M->NB_DADOS := CriaVar("NB_DADOS",.T.) '
	Endif
Endif

Return(&cReturn)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณATFA300   บAutor  ณMicrosiga           บ Data ณ  10/09/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function X3Usado(cNomeCpo)

Local lEmUso	:= .F.
Local nOrdX3P	:= 1
Local nRecX3P	:= 1

If Empty(cNomeCpo)
	Return(.F.)
Endif

nOrdX3P := SX3->(IndexOrd())
nRecX3P := SX3->(Recno())

dbSelectArea("SX3")
dbSetOrder(2)
If MsSeek(cNomeCpo,.F.)
	If X3Uso(SX3->X3_USADO)
		lEmUso := .T.
	Endif
Endif

SX3->(dbSetOrder(nOrdX3P))
SX3->(dbGoTo(nRecX3P))

Return(lEmUso)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Ana Paula N. Silva     ณ Data ณ30/11/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados     ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina := {}
	aAdd(aRotina,{ STR0002	, "AxPesqui"  					, 0, 1 , ,.F.})		//"Pesquisar"
	aAdd(aRotina,{ STR0003	, "AF300Vis"					, 0, 2})		//"Visualizar"
	aAdd(aRotina,{ STR0004	, "AF300Inc"					, 0, 3})		//"Incluir"
	aAdd(aRotina,{ STR0005	, "AF300Alt"					, 0, 4})		//"Alterar"
	aAdd(aRotina,{ STR0006	, "AF300Del"					, 0, 5})		//"Excluir"
Return(aRotina)