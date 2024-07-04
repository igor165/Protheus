#INCLUDE "Acda080.ch" 
#include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ACDA080  ³ Autor ³ Anderson Rodrigues    ³ Data ³ 21/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tabela de Monitoramento da Producao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACDA080()
Private oTempTable := Nil
Private cArqTrab
Private cOperador  := CBRETOPE()
Private cCadastro  := STR0001 //"Monitoramento da Producao"
Private cTM        := GetMV("MV_TMPAD")
Private cProduto   := Space(Len(SC2->C2_PRODUTO))
Private cLocPad    := Space(Len(SC2->C2_LOCAL)) //Usado na rotina RF ACDV023
Private cRoteiro   := Space(Len(SC2->C2_ROTEIRO))
Private cUltOper   := Space(Len(CBH->CBH_OPERAC))
Private cPriOper   := Space(Len(CBH->CBH_OPERAC))
Private cUltApont  := " "
Private cApontAnt  := " "
Private cTipIni    := "1"
Private nQtdOP     := 0
Private nSldOPer   := 0
Private lConjunto  := .f.
Private lFimIni    := .f.
Private lAutAskUlt := .f.
Private lVldOper   := .f.
Private lRastro    := GetMV("MV_RASTRO")  == "S" // Verifica se utiliza controle de Lote
Private lSGQTDOP   := GetMV("MV_SGQTDOP") == "1" // Sugere quantidade no inicio e no apontamento da producao
Private lInfOpe    := .f. // Validacao no X3_When do Operador
Private lInfQeIni  := GetMV("MV_INFQEIN") == "1" // Verifica se deve informar a quantidade no inicio da Operacao
Private lCBAtuemp  := GetMV("MV_CBATUD4") == "1" // Verifica se ajusta o empenho no inicio da producao
Private lVldQtdOP  := GetMV("MV_CBVQEOP") == "1" // Valida no inicio da operacao a quantidade informada com o saldo a produzir da mesma
Private lVldQtdIni := GetMV("MV_CBVLAPI") == "1" // Valida a quantidade do apontamento com a quantidade informada no inicio da Producao
Private lCfUltOper := GetMV("MV_VLDOPER") == "S" // Verifica se tem controle de operacoes
Private lMod1      := Nil
Private lMsHelpAuto:= .f.
Private lMSErroAuto:= .f.
Private lPerdInf   := .F.
Private aOperadores:= {}
Private aRotina    := Menudef() 

AtivaF12(.F.)

CBH->(DbSetOrder(3))

aCores := {	{ "ACDA080CLR(1)","ENABLE"     },;
			{ "ACDA080CLR(2)","BR_AMARELO" },;
			{ "ACDA080CLR(3)","BR_LARANJA" },;
			{ "ACDA080CLR(4)","BR_AZUL"    },;
			{ "ACDA080CLR(5)","BR_MARRON"  },;
	   		{ "ACDA080CLR(6)","DISABLE"    } }

If Empty(cOperador)
	MsgAlert(STR0075+Alltrim(Substr(cUsuario,7,15))+STR0076) //"Operador referente ao usuario "###" nao cadastrado, Verifique !!!"
	Return .F.
EndIf

If Empty(cTM)
	MsgAlert(STR0077) //"Informe o tipo de movimentacao padrao - MV_TMPAD"
	Return .f.
EndIf

If !lRastro .and. lCBAtuemp
	MsgAlert(STR0078) //"O parametro MV_CBATUD4 so deve ser ativado quando o sistema controlar rastreabilidade, Verifique !!!"
	Return .F.
EndIf

If (lVldQtdOP .or. lVldQtdIni .or. lCBAtuemp) .and. !lInfQeIni	
	MsgAlert(STR0079) //"O parametro MV_INFQEIN deve ser ativado, verifique !!!"
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F12 para acionar perguntas                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetKey(VK_F12,{||AtivaF12(.T.)})
mBrowse( 6, 1, 22, 75, "CBH", , , , , , aCores, , , ,{|x|TimerBrw(x)})
SetKey(VK_F12,Nil)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AtivaF12 ³ Autor ³ Anderson Rodrigues    ³ Data ³ 30/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Executa a Funcao da Pergunte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtivaF12(lPergunte)
Pergunte("ACDB80",lPergunte)
lMod1:= MV_PAR01 == 1
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ACDA080A ³ Autor ³ Anderson Rodrigues    ³ Data ³ 25/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao das opcoes de inclusao/alteracao/exclusao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ACDA080A(cAlias,nReg,nOpc)

Local aCpsUsu	  := {}
Local aAreaTmp	  := GetArea()
Local cUltApont   := ""
local cLote		  := Space(10) 	
Local dValid      := ctod('')
Local nOpcao      := 0
Local lOPEncerrada:= OPInfo(CBH_OP,2)
Local aObjects  := {}                  
Local aSize     := {} 
Local aInfo     := {}
Local aStruCBH  := {}
Local nX

Private cTitulo   := STR0001 //"Monitoramento da Producao"
Private aTrocaF3  := {}
Private oEnchoice
Private nRegSH6	  := 0

If !Empty(CBH->CBH_OP) 
	cUltApont:= CB023UH6(CBH->CBH_OP) // Ultima Operacao apontada no SH6
EndIf
//--Para tratar campos de usuario
aStruCBH  := FWFormStruct(3, "CBH")[3]
For nX := 1 To Len(aStruCBH)
	If GetSx3Cache(aStruCBH[nX,1], "X3_PROPRI") == 'U' .and. GetSx3Cache(aStruCBH[nX,1], "X3_CONTEXT") <> 'V' ;
		.And. aStruCBH[nX, 1] != "CBH_DTAPON" // Proteção para release 12.1.23 para não tratar CBH_DTAPONT como campo de usuário
		aAdd(aCpsUsu,AllTrim(GetSx3Cache(aStruCBH[nX,1], "X3_CAMPO")))
	EndIf
Next nX 

RestArea(aAreaTmp)

If lMod1
	aTrocaF3:={{"CBH_OP","SH8"}}
Else
	aTrocaF3:={{"CBH_OP","SC2"}}
EndIf

If nOpc == 4 // alteracao
	If CBH->CBH_TIPO # "2" .and. CBH->CBH_TIPO # "3"
		MsgAlert(STR0009) //"Somente e permitido a alteracao de registros de monitoramento do tipo pausa"###"Alteracao nao permitida"
		Return .f.
	ElseIf !Empty(CBH->CBH_HRIMAP)
		MsgAlert(STR0011) //"Este registro de monitoramento nao pode ser alterado pois ja gerou movimentacoes no sistema"###"Alteracao nao permitida"
		Return .f.
	EndIf
ElseIf nOpc == 5
	If CBH->CBH_TIPO $ "23"  .and. !Empty(CBH->CBH_HRIMAP)
		MsgAlert(STR0012) //"Este registro de monitoramento nao pode ser excluido pois ja gerou movimentacoes no sistema"###"Exclusao nao permitida"
		Return .f.
	ElseIf CBH->CBH_TIPO $ "23"  .and. ! PermiteExc()
		Return .f.
	ElseIf CBH->CBH_TIPO == "1"  .and. ! PermiteExc()
		MsgAlert(STR0012) //"Este registro de monitoramento nao pode ser excluido pois ja gerou movimentacoes no sistema"###"Exclusao nao permitida"
		Return .f.
	ElseIf lCBAtuEmp .and. CBH->CBH_TIPO == "1" .and. CBH->CBH_OPERAC == "01" .and. CBH->CBH_QEPREV > 0 // Parametro MV_CBATUD4 ativado
		MsgAlert(STR0014) //"Nao e permitida a exclusao deste registro de monitoramento pois o mesmo gerou movimentos de Empenho"###"Exclusao nao permitida"
		Return .f.
	ElseIf CBH->CBH_TIPO $ "45" .and. lOPEncerrada .and. (CBH->CBH_OPERAC # cUltApont)
		MsgAlert(STR0015) //"OP Encerrada, e necessario estornar primeiro o apontamento da ultima operacao para reabrir a OP"###"Exclusao nao permitida"
		Return .f.
	ElseIf CBH->CBH_TIPO $ "45" .and. ! PermiteExc()
		Return .f.
	EndIf	
EndIf
// Valida integração WMS
If (nOpc == 4 .Or. nOpc == 5) .And. IntWMS() .And. !A080ValWMS(CBH->CBH_OP)
	Return .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta a largura para o tamanho padrao Protheus ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize(,.F.,400)       
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo    := { aSize[1], aSize[2], aSize[3], aSize[4], 2, 2 } 
aPosObj := MsObjSize( aInfo, aObjects ) 

SETAPILHA()
DEFINE MSDIALOG oDlg TITLE (cTitulo) FROM aSize[7],0 TO aSize[6],aSize[5] PIXEL OF oMainWnd
RegtoMemory("CBH",nOpc==3)
oEnchoice:= MsMGet():New("CBH",nReg,nOpc,,,,,aPosObj[1],,,,,,oDlg,,,.F.)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(VldDados(nOpc),(nOpcao:=1,oDlg:End()),nOpcao:=0)},{||nOpcao:=0,oDlg:End()})
If nOpcao == 0
	Return
EndIf

cLote  := M->CBH_LOTCTL  
dValid := M->CBH_DVALID

Begin Transaction
If nopc == 3 // inclusao
	If lCBAtuemp .and. (M->CBH_QEPREV > 0) .and. (M->CBH_OPERAC == "01")
		CB023EMP(M->CBH_OP,M->CBH_OPERAC,M->CBH_QEPREV)
	EndIf
	If M->CBH_TIPO $ "123"
		CB023CBH(M->CBH_OP,M->CBH_OPERAC,M->CBH_OPERAD,M->CBH_TRANSA,Nil,M->CBH_DTINI,M->CBH_HRINI,M->CBH_DTFIM,M->CBH_HRFIM,M->CBH_TIPO,"ACDA080",M->CBH_QEPREV,M->CBH_QTD,M->CBH_RECUR,aCpsUsu)
	ElseIf M->CBH_TIPO $ "45"
		Grava(aCpsUsu,cLote,dValid)
	EndIf
ElseIf nOpc == 4
	CB023CBH(M->CBH_OP,M->CBH_OPERAC,M->CBH_OPERAD,M->CBH_TRANSA,nReg,M->CBH_DTINI,M->CBH_HRINI,M->CBH_DTFIM,M->CBH_HRFIM,M->CBH_TIPO,"ACDA080",M->CBH_QEPREV,M->CBH_QTD,M->CBH_RECUR,aCpsUsu,M->CBH_LOTCTL,M->CBH_NUMLOT,M->CBH_DVALID)
ElseIf nOpc == 5
	SH6->(DBSetFilter( {|| M->CBH_OP == SH6->H6_OP .And.M->CBH_HRINI == SH6->H6_HORAINI .And.M->CBH_HRFIM == SH6->H6_HORAFIN .And.M->CBH_OPERAD == SH6->H6_OPERADO}, "M->CBH_OP == SH6->H6_OP .And.M->CBH_HRINI == SH6->H6_HORAINI .And.M->CBH_HRFIM == SH6->H6_HORAFIN .And.M->CBH_OPERAD == SH6->H6_OPERADO" )) //Verifica se o registro existe na tabela SH6
    SH6->(DbGoTop())      
    If M->CBH_OP == SH6->H6_OP .And.M->CBH_HRINI == SH6->H6_HORAINI .And.M->CBH_HRFIM == SH6->H6_HORAFIN .And.M->CBH_OPERAD == SH6->H6_OPERADO
	    cLote  := SH6->H6_LOTECTL
    	cValid := SH6->H6_DTVALID
    EndIf	
	SH6->(DBClearFilter())
	If M->CBH_TIPO == "1" // Exclusao do Inicio
		CB023CB1(M->CBH_OP,M->CBH_OPERAC,M->CBH_OPERAD,M->CBH_TIPO,M->CBH_TRANSA,M->CBH_DTFIM,.T.) // Limpa o Flag do Operador
	ElseIf CBH->CBH_TIPO $ "45" // Exclusao da Producao/Perda
		nRecCBH:= CBH->(RECNO())
		nRegSH6:= SH6->(RECNO())
		CB023GRV(M->CBH_OP,M->CBH_OPERAC,M->CBH_TRANSA,OPInfo(CBH_OP,1),M->CBH_RECUR,M->CBH_OPERAD,M->CBH_TIPO,M->CBH_QTD,cLote,dValid,M->CBH_DTINI,M->CBH_HRINI,M->CBH_DTFIM,M->CBH_HRFIM,.T.)
		CBH->(DbGoTo(nRecCBH))
		AtuEmpenho(M->CBH_OP,M->CBH_OPERAC,M->CBH_QTD) // --> Volta o saldo do D4_EMPROC para produtos de apropriacao indireta
		CBH->(DbGoTo(nRecCBH))
		AtuIniCBH(M->CBH_OP,M->CBH_OPERAC,M->CBH_OPERAD,M->CBH_QTD,M->CBH_DTINI,M->CBH_HRINI,M->CBH_DTFIM,M->CBH_HRFIM) // --> Atualiza os inicios de operacoes do CBH
		CBH->(DbGoTo(nRecCBH))
	EndIf
	RecLock("CBH",.F.)
	CBH->(DbDelete())
	CBH->(MsUnlock())
EndIf
End Transaction
If lMsErroAuto
	MostraErro()
EndIf
SysRefresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ RetProd    ³ Autor ³ Anderson Rodrigues  ³ Data ³ 06/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o Codigo do Produto (PA da OP)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function OPInfo(cOP,nOpc)
Local cProduto:= Space(Len(SC2->C2_PRODUTO))
Local lEndOP  := .f.

SC2->(DbSetOrder(1))
If ! SC2->(DbSeek(xFilial("SC2")+cOP))
	If nOpc == 1
		Return(cProduto)
	Else
		Return(lEndOP)
	EndIf
EndIf

If !Empty(SC2->C2_DATRF) .or. (SC2->C2_QUJE+SC2->C2_PERDA) >= SC2->C2_QUANT
	lEndOP:= .t.
EndIf

cProduto := SC2->C2_PRODUTO

If nOpc == 1
	Return(cProduto)
Else
	Return(lEndOP)
EndIf

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AtuIniCBH  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 06/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza as transacoes do tipo inicio para a chave         ³±±
±±³          ³ OP+OPERACAO+OPERADOR                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AtuIniCBH(cOP,cOperacao,cOperador,nQtd,dDataini,cHoraIni,dDataFim,cHoraFim,lSimulaLib)
Local cTipo       := "1" //--> Tipo Inicio
Local lLibera     := .f.
Default lSimulaLib:= .f.

CBH->(DbSetOrder(3))

If ! CBH->(DbSeek(xFilial("CBH")+cOP+cTipo+cOperacao+cOperador))
	Return(lLibera)
EndIf

While ! CBH->(EOF()) .and. CBH->(CBH_FILIAL+CBH_OP+CBH_TIPO+CBH_OPERAC+CBH_OPERAD) == xFilial("CBH")+cOP+cTipo+cOperacao+cOperador
	If ! Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
		If (DTOS(dDataFim)+cHoraFim) > (DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
			CBH->(DbSkip())
			Loop
		Endif
		If (DTOS(dDataIni)+cHoraIni) < (DTOS(CBH->CBH_DTINI)+CBH->CBH_HRINI)
			CBH->(DbSkip())
			Loop
		EndIf
	EndIf
	If lSimulaLib .and. Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
		CBH->(DbSkip()) // Neste caso nao tem nada pra alterar no inicio
		Loop
	EndIf
	If (nQtd == 0 .and. CBH->CBH_QTD > 0) .or. (nQtd > 0 .and. CBH->CBH_QTD == 0)
		CBH->(DbSkip())
		Loop
	EndIf
	If (CBH->CBH_QTD - nQtd) < 0
		CBH->(DbSkip())
		Loop
	EndIf
	If CBH->CBH_QTD == 0 .and. nQtd == 0 .and. Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
		CBH->(DbSkip()) // Neste caso nao tem nada pra alterar no inicio
		Loop
	EndIf
	If lSimulaLib
		lLibera:= .t.
		Exit
	Else
		RecLock("CBH",.F.)
		CBH->CBH_QTD-= nQtd
		CBH->CBH_DTFIM:= CTOD("  /  /    ")
		CBH->CBH_HRFIM:= " "
		CBH->(MsUnlock())
		lLibera:= .t.
		Exit
	EndIf
Enddo
If lLibera .and. !lSimulaLib
	CB023CB1(M->CBH_OP,M->CBH_OPERAC,M->CBH_OPERAD,M->CBH_TIPO,M->CBH_TRANSA,M->CBH_DTFIM,.T.)
EndIf
Return(lLibera)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmBrowse ³ Autor ³ Anderson Rodrigues    ³ Data ³ 25/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Temporizador para efetuar o Refresh no Browse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function TimerBrw(oMBrowse)
Local oTimer
DEFINE TIMER oTimer INTERVAL 1000 ACTION TmBrowse(GetObjBrow(),oTimer) OF oMBrowse
oTimer:Activate()
Return .T.


Static Function TmBrowse(oObjBrow,oTimer)
oTimer:Deactivate()
oObjBrow:Refresh()
oTimer:Activate()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ACDA080CLR³ Autor ³ Anderson Rodrigues    ³ Data ³ 25/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa as condicoes para retorno das cores da mBrowse     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ACDA080CLR(nTipo)
Local lRet := .F.
If nTipo == 1      	// ENABLE -> LEGENDA = OP em aberto  / DISABLE -> OP encerrada
	If CBH->CBH_TIPO == "1" .and. (EMPTY(CBH->CBH_DTFIM) .or. Empty(CBH->CBH_HRFIM))
		lRet := .T.
	EndIf
ElseIf nTipo == 2		// BR_AMARELO -> LEGENDA = Pausa iniciada
	If CBH->CBH_TIPO $ "23" .and. ! EMPTY(CBH->CBH_DTINI) .and. EMPTY(CBH->CBH_DTFIM)
		lRet := .T.
	EndIf
ElseIf nTipo == 3		// BR_LARANJA -> LEGENDA = Pausa Finalizada
	If CBH->CBH_TIPO $ "23" .and. ! EMPTY(CBH->CBH_DTFIM)
		lRet := .T.
	EndIf
ElseIf nTipo == 4		// BR_AZUL -> LEGENDA = Apontamento da Producao
	If CBH->CBH_TIPO == "4"
		lRet := .T.
	EndIf
ElseIf nTipo == 5		// BR_MARROM -> LEGENDA = Apontamento de Perda
	If CBH->CBH_TIPO == "5"
		lRet := .T.
	EndIf
ElseIf nTipo == 6	       // DISABLE -> LEGENDA = Inicio Encerrado
        lRet := .T.
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ACDA080Lg ³ Autor ³ Anderson Rodrigues    ³ Data ³ 25/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Legenda para as cores da mbrowse                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ACDA080Lg                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ACDA080Lg()
Local aCorDesc   := {}

aCorDesc := { { "ENABLE" ,STR0018},; //"Inicio em aberto"
{ "DISABLE"    ,STR0019},; //"Inicio encerrado"
{ "BR_AMARELO" ,STR0020},; //"Pausa iniciada"
{ "BR_LARANJA" ,STR0021},; //"Pausa finalizada"
{ "BR_AZUL"    ,STR0022},; //"Apontamento da Producao"
{ "BR_MARRON"  ,STR0023}} //"Apontamento de Perda"

BrwLegenda(STR0001,STR0024,aCorDesc) //"Monitoramento da Producao"###"Status"
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³PermiteExc  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 25/09/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Verifica se pode ser realizada a exclusao do tipo inicio    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PermiteExc()
Local nOrdem   := CBH->(INDEXORD())
Local nRecno   := CBH->(RECNO())
Local cOperador:= CBH->CBH_OPERAD
Local cOP      := CBH->CBH_OP
Local cOperac  := CBH->CBH_OPERAC
Local cTipo    := CBH->CBH_TIPO
Local cHrIni   := CBH->CBH_HRINI
Local cHrFim   := CBH->CBH_HRFIM
Local cMensagem:= ""
Local dDtIni   := CBH->CBH_DTINI
Local dDtFim   := CBH->CBH_DTFIM
Local nQtd     := CBH->CBH_QTD
Local lRet     := .t.

If cTipo == "1" // --> Exclusao da transacao de inicio
	If ! Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM) .and. CBH->CBH_QTD > 0
		Return .f.
	EndIf
	CBH->(DbSetOrder(5))
	CBH->(DbGoTop())
	If ! CBH->(DbSeek(xFilial("CBH")+cOP+cOperac))
		Return .f.
	EndIf
	While ! CBH->(EOF()) .and. CBH->(CBH_FILIAL+CBH_OP+CBH_OPERAC) == xFilial("CBH")+cOP+cOperac
		If CBH->CBH_OPERAD # cOperador
			CBH->(DbSkip())
			Loop
		ElseIf CBH->CBH_TIPO # cTipo
			lRet:= .f.
			Exit
		Else
			Exit
		EndIf
	Enddo
	CBH->(DbSetOrder(nOrdem))
	CBH->(DbGoto(nRecno))
ElseIf cTipo $ "23"
	If Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
		cMensagem:= STR0066 //"Nao e permitida a exclusao de registros de pausas nao finalizadas, "
		cMensagem+= STR0067 //"finalize a pausa atraves do SIGAACD para exclui-la"
		MsgAlert(cMensagem)
		lRet:= .f.
	EndIf
Else
	CB1->(DbSetOrder(1))
	If ! CB1->(DbSeek(xFilial("CB1")+cOperador)) .or. CB1->CB1_ACAPSM == "1"
		lRet:= .t.	
	Elseif Empty(CB1->CB1_OP+CB1->CB1_OPERAC) .or. (CB1->CB1_OP+CB1->CB1_OPERAC == cOP+cOperac)
		If ! AtuIniCBH(cOP,cOperac,cOperador,nQtd,dDtIni,cHrIni,dDtFim,cHrFim,.T.) // --> Verifica se a exclusao vai atualizar inicios ja encerrados
			lRet:= .t.
		Else
			CBH->(DbSetOrder(3))
			If CBH->(DbSeek(xFilial("CBH")+cOP+"1"+cOperac+cOperador)) .and. Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
				MsgAlert(STR0068+cOperador+STR0069) //"Existe inicio em aberto desta O.P+Operacao para o Operador "###", Verifique !!!"###"Exclusao nao permitida"
				lRet:= .f.
			EndIf
		EndIf
		CBH->(DbSetOrder(nOrdem))
		CBH->(DbGoto(nRecno))
	Else
		cMensagem:= STR0025 //"Operador sem permissao para executar apontamentos simultaneos, a "
		cMensagem+= STR0026+CB1->CB1_OPERAC+STR0027+CB1->CB1_OP+STR0028 //"operacao "###" da O.P. "###" esta em aberto"
		MsgAlert(cMensagem)
		lRet:= .f.
	EndIf
EndIf
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Fun‡„o   ³ VldDados º Autor ³ Anderson Rodrigues º Data ³TUE 24/03/04 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Validacao chamada pela Enchoice Principal                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function VldDados(nOpc)
Local cDataHora
Local cMensagem:=""

If nOpc == 5 // exclusao  
	If ExistBlock("ACD080VLE")// Validacao antes da exclusao
		If ! ExecBlock("ACD080VLE",.F.,.F.)
			Return .F.
		Else 
			Return .T.
		EndIf
	Else 
		Return .t.  
	EndIf
Elseif M->CBH_TIPO # "1"
	If Empty(M->CBH_RECUR)
		MsgAlert(STR0080) //"Recurso nao Informado"
		Return .f.
	EndIf
EndIf
If nOpc == 4 // se for alteracao significa que e termino da pausa.
	Return .t.
EndIf

// deste bloco pra baixo e validacao de inclusao (nOpc == 3)

If Empty(M->CBH_OP) .or. Empty(M->CBH_OPERAC) .or. Empty(M->CBH_OPERADOR) .or. Empty(M->CBH_TRANSA)
	MsgAlert(STR0081) //"Existem campos obrigatorios nao informados, Verifique !!!"
	Return .f.
EndIf

If M->CBH_TIPO == "1"  // Inicio ja foi validado na digitacao da transacao
	Return .t.
EndIf
If M->CBH_TIPO $ "23"
	cDataHora:= (Dtos(M->CBH_DTINI)+M->CBH_HRINI)
	cMensagem:= STR0082 //"Data Inicio + Hora Inicio invalidas para o Operador "
ElseIf M->CBH_TIPO $ "45"
	cDataHora:= (Dtos(M->CBH_DTFIM)+M->CBH_HRFIM)
	cMensagem:= STR0083 //"Data Fim + Hora Fim invalidas para o Operador "
EndIf
If ! CB023DTHR(M->CBH_OP,M->CBH_OPERAC,M->CBH_OPERAD,cDataHora) // --> Verifica se a Data e Hora atuais sao validas para permitir a transacao.
	MsgAlert(cMensagem+M->CBH_OPERAD)
	Return .f.
EndIf
If lConjunto
	If ! Seleciona()
		Return .f.
	EndIf
EndIf
If M->CBH_TIPO $ "45"
	If ExistBlock("ACD080PR")// Validacao antes da confirmacao do apontamento da producao/perda
		If ! ExecBlock("ACD080PR",.F.,.F.)
			Return .f.
		EndIf
	EndIf
EndIf  
If M->CBH_TIPO $ "23"
	If ExistBlock("ACD080PSA")// Validacao antes da confirmacao do apontamento de pausa
		If ! ExecBlock("ACD080PSA",.F.,.F.)
			Return .f.
		EndIf
	EndIf
EndIf
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Fun‡„o   ³ ACDX301  º Autor ³ Anderson Rodrigues º Data ³Wed  14/10/02º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Inicializacao do conteudo do Campo CBH_DESCOPE no Browse   º±±
±±º          ³ (X3_INIBRW) e no cadastro (X3_RELACAO)                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function ACDX301(lGatilho)
Local cProduto:= " "
Local cDescOpe:= " "
Local cRoteiro:= " "
Local cOP
Local cOperac

Inclui := IIf(Type('Inclui') == "U" , .F. , Inclui)

If Inclui .and. !lGatilho
	Return(cDescOpe)
Endif
If lGatilho
	cOP    := M->CBH_OP
	cOperac:= M->CBH_OPERAC
Else
	cOP    := If(Empty(CBH->CBH_OP),M->CBH_OP,CBH->CBH_OP)
	cOperac:= If(Empty(CBH->CBH_OPERAC),M->CBH_OPERAC,CBH->CBH_OPERAC)
EndIf

SC2->(DbSetOrder(1))
If SC2->(DbSeek(xFilial("SC2")+cOP))
	cProduto := SC2->C2_PRODUTO
EndIf

If !Empty(SC2->C2_ROTEIRO)
	cRoteiro := SC2->C2_ROTEIRO
Else
	SB1->(DbSetorder(1))
	If SB1->(DbSeek(xFilial("SB1")+cProduto)) .And. !Empty(SB1->B1_OPERPAD)
		cRoteiro := SB1->B1_OPERPAD
	Else
		cRoteiro := StrZero(1, Len(SG2->G2_CODIGO))
	EndIf
EndIf

SG2->(DbSetOrder(1))
If SG2->(DbSeek(xFilial("SG2")+cProduto+cRoteiro+cOperac))	
	cDescOpe := SG2->G2_DESCRI
EndIf
Return(cDescOpe)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Fun‡„o   ³ ACDX302  º Autor ³ Anderson Rodrigues º Data ³Wed  14/10/02º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Inicializacao do conteudo do Campo CBH_DESCRI no Browse    º±±
±±º          ³ (X3_INIBRW) e no cadastro (X3_RELACAO)                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function ACDX302()
Local cDescri := " "

Inclui := IIf(Type('Inclui') == "U" , .F. , Inclui)

If	Inclui
	Return(cDescri)
EndIf

CBI->(DbSetorder(1))
If	CBI->(DbSeek(xFilial("CBI")+CBH->CBH_TRANSA+CBH->CBH_TIPO))
	cDescri := CBI->CBI_DESCRI
EndIf
Return(cDescri)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Fun‡„o   ³ ACDX303  º Autor ³ Anderson Rodrigues º Data ³TUE 27/04/04 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Validacao executada atraves do X3_WHEN dos Campos          º±±
±±º			 ³ CBH_DTINI e CBH_HRINI                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function ACDX303()

If	Altera .and. (M->CBH_TIPO $ "23" .and. Empty(Dtos(M->CBH_DTFIM)+M->CBH_HRFIM))
	M->CBH_DTFIM:= dDataBase
	M->CBH_HRFIM:= Left(Time(),5)
EndIf
CB1->(DbSetOrder(2))
If	CB1->(DbSeek(xFilial("CB1")+__cUserID))
	If	CB1->CB1_ALDTHR == "1" // Operador tem permissao para alterar as Datas e Horas no Monitoramento
		Return .t.
	EndIf
EndIf
CB1->(DbSetOrder(1))
Return .f.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Fun‡„o   ³ ACDX304  º Autor ³ Anderson Rodrigues º Data ³SAT 01/05/04 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Validacao executada atraves do X3_WHEN dos Campos          º±±
±±º          ³ CBH_DTFIM e CBH_HRFIM                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function ACDX304()
If	M->CBH_TIPO == "1"
	Return .f.
EndIf
Return ACDX303()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Fun‡„o   ³ ACDX305  º Autor ³ Anderson Rodrigues º Data ³SAT 01/05/04 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Validacao executada atraves do X3_WHEN do Campo CBH_QEPREV º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function ACDX305()

If M->CBH_TIPO == "1" .and. lInfQeIni
	Return .t.
EndIf
Return .f.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB080DTHR  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 16/06/03   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gatilho para Inicializacao dos campos de Data e Hora         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CB080DTHR()
Local cTipo    := "1"
Local nEmAberto:= 0
Local aUltProd := {}

Inclui := IIf(Type('Inclui') == "U" , .F. , Inclui)

If Inclui .and. M->CBH_TIPO $ "123"
	M->CBH_DTINI:= dDataBase
	M->CBH_HRINI:= Left(TIME(),5)
	If ACDX305() // TIPO == 1 e Informa Quantidade para inicio
		nEmAberto:= CB023Apont(M->CBH_OP,M->CBH_OPERAC,.F.) // Retorna a quantidade total de inicio em aberto para esta operacao
		nSldOPer -= nEmAberto // Atualiza o Saldo da operacao considerando as quantidades de inicio que estao em aberto
		If nSldOPer < 0  // --> Se apos a atualizacao o Saldo ficar negativo deixar como zero.
			nSldOPer:= 0
		EndIf
		If lSGQTDOP
			M->CBH_QEPREV:= nSldOPer
		EndIf
	EndIf
ElseIf Altera .and. M->CBH_TIPO $ "23"
	M->CBH_DTFIM:= dDataBase
	M->CBH_HRFIM:= Left(TIME(),5)
Elseif Inclui .and. M->CBH_TIPO $ "45"
	CBH->(DbSetOrder(3))
	If CBH->(DbSeek(xFilial("CBH")+M->CBH_OP+"1"+M->CBH_OPERAC+M->CBH_OPERAD)) .And. !Empty(CBH->CBH_HRFIM)
		While !CBH->(Eof()) .And. !Empty(CBH->CBH_HRFIM)
		 	CBH->(DbSkip())  
	    End 
    EndIf
	If M->CBH_OP == CBH->CBH_OP .And. M->CBH_OPERAD == CBH->CBH_OPERAD .And. CBH->CBH_TIPO == "1" .And. CBH->CBH_QTD == 0
		M->CBH_DTINI:= CBH->CBH_DTINI
		M->CBH_HRINI:= CBH->CBH_HRINI
	Else 
		aUltProd:= CB023Dados(M->CBH_OP,cProduto,M->CBH_OPERAC,M->CBH_OPERAD) // Retorna Dados do ultimo apontamento no SH6
		If!Empty(aUltProd)
			M->CBH_DTINI:= aUltProd[1,4]
			M->CBH_HRINI:= aUltProd[1,5]
		Else
			If ! CBH->(DbSeek(xFilial("CBH")+M->CBH_OP+cTipo+M->CBH_OPERAC))
				MsgAlert(STR0084) //"Operacao nao iniciada para esta OP !!!"
				Return .f.
			ElseIf CBH->(DbSeek(xFilial("CBH")+M->CBH_OP+cTipo+M->CBH_OPERAC+M->CBH_OPERAD)) .and. (!Empty(CBH->CBH_DTFIM) .or. !Empty(CBH->CBH_HRFIM))
				MsgAlert(STR0085) //"Operacao nao possui inicio em aberto para esta OP !!!"
				Return .f.
			Else
				M->CBH_DTINI:= CBH->CBH_DTINI
				M->CBH_HRINI:= CBH->CBH_HRINI
			EndIf
		EndIf
	EndIf	
	M->CBH_DTFIM:= dDataBase
	M->CBH_HRFIM:= Left(TIME(),5)
	If M->CBH_DTINI == M->CBH_DTFIM .AND. M->CBH_HRINI == M->CBH_HRFIM
		M->CBH_HRFIM:= Left(M->CBH_HRFIM,3)+StrZero(Val(Right(M->CBH_HRFIM,2))+1,2)
		If Right(M->CBH_HRFIM,2) == "60"
			M->CBH_HRFIM:= StrZero(Val(Left(M->CBH_HRFIM,2))+1,2)+":00"
			If Left(M->CBH_HRFIM,2)== "24"
				M->CBH_HRFIM:= "00:00"
				M->CBH_DTFIM++
			EndIf
		EndIf
	EndIf
EndIf
Return(M->CBH_DTINI)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Seleciona  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 29/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta Tela para selecao dos operadores para o apontamento  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Seleciona()
Local nX        := 0
Local nOpca     := 0
Local nPos      := 0
Local nMarcados := 0
Local aStru     := {}
Local aCpos     := {}
Local aPosEnch  := {}
Local lRet      := .t.
Local oMark
Local oDlg
Private lInverte:= .f.
Private cMarca  := '6j'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Arquivo de Trabalho para a escolha dos ensaios ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd( aStru,{ "TRB_OK"    ,  "C",02,0})
Aadd( aStru,{ "TRB_OPERAD",  "C",06,0})
Aadd( aStru,{ "TRB_QTD"   ,  "N",15,0})
Aadd( aStru,{ "TRB_DTINI" ,  "D",8,0})
Aadd( aStru,{ "TRB_HRINI" ,  "C",5,0})



oTempTable := FWTemporaryTable():New( "ACDTRB" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"TRB_QTD"} )
oTempTable:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Redefinicao do aCpos para utilizar no MarkBrow ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aCpos := {	{"TRB_OK"     ,"","OK"},;
			{"TRB_OPERAD" ,"",STR0042},; //"Operador"
			{"TRB_QTD"	  ,"",STR0041},;  //"Quantidade"
			{"TRB_DTINI"	  ,"",STR0098},;//"Dt Inicio"
			{"TRB_HRINI"	  ,"",STR0099}}// "Hr Inicio"  	 
			

nPos:= Ascan(aOperadores,{|x| x[2] == M->CBH_OPERAD})

If nPos > 0
	aOperadores[nPos,3]:= Str(M->CBH_QTD,7,2)
EndIf

aOperadores:= aSort(aOperadores,,,{|x,y| x[3] < y[3]})

For nX := 1 to Len(aOperadores)
	RecLock("ACDTRB",.T.)
	If !Empty(aOperadores[nX,1])
		ACDTRB->TRB_OK:= cMarca
	EndIf
	ACDTRB->TRB_OPERAD	:= aOperadores[nX,2]
	ACDTRB->TRB_QTD		:= Val(aOperadores[nX,3])
	ACDTRB->TRB_DTINI	:= aOperadores[nX,4]
	ACDTRB->TRB_HRINI	:= aOperadores[nX,5]	
	ACDTRB->(MsUnlock())
Next

SETAPILHA()

DEFINE MSDIALOG oDlg TITLE (STR0086) FROM 30,0 TO TranslateBottom(.F.,18),62 OF oMainWnd //'Selecao dos Operadores'
aPosEnch:= {30,1,150,245}
oMark := MsSelect():New("ACDTRB","TRB_OK",,aCpos,lInverte,cMarca,aPosEnch)
oMark:oBrowse:lCanAllMark:=.T.
oMark:oBrowse:lHasMark	 :=.T.
oMark:bMark              := {||MarcaItem(cMarca,lInverte,oDlg)}
oMark:oBrowse:bAllMark   := {||MarcaTudo(cMarca,oDlg)}
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||If(VldMark() .and. MsgYesNo(STR0096),(nOpcA:=1,oDlg:End()),nOpcA:=0)},{||nOpcA:=0,oDlg:End()}) //"Confirma a Selecao ?"
If nOpcA == 1
	Return .t.
EndIf

oTempTable:Delete() //-- Deleta Arquivo Temporario

Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ VldMark    ³ Autor ³ Anderson Rodrigues  ³ Data ³ 29/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa se teve algum item selecionado no na MarkBrow      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldMark()
Local nRecno

DbSelectArea("ACDTRB")
ACDTRB->(DbGoTop())
nRecno   := ACDTRB->(Recno())
nMarcados:= 0
While ! ACDTRB->(EOF())
	If ! ACDTRB->(IsMark("TRB_OK"))
		ACDTRB->(DbSkip())
		Loop
	EndIf
	nMarcados++
	ACDTRB->(DbSkip())
Enddo
If nMarcados < 2
	MsgAlert(STR0087)  //"Para utilizar o apontamento em conjunto devem ser selecionados no minimo dois operadores"
	Return .f.
EndIf
If (M->CBH_QTD >= nSldOPer) .and. nMarcados < Len(aOperadores) // Nao selecionou todos os operadores
	MsgAlert(STR0088) //"A quantidade informada finaliza o saldo da operacao, neste caso e necessario selecionar todos os operadores"
	Return .f.
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ MarcaItem  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 29/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca um item por vez na MarkBrowse                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MarcaItem(cMarca,lInverte,oDlg)

If ACDTRB->(IsMark("TRB_OK",cMarca,lInverte))
	RecLock("ACDTRB",.F.)
	If !lInverte
		ACDTRB->TRB_OK:= cMarca
	ElseIf (Empty(ACDTRB->TRB_QTD) .AND. ACDTRB->TRB_OPERAD # M->CBH_OPERAD)
		ACDTRB->TRB_OK:= "  "
	EndIf
	ACDTRB->(MsUnlock())
Else
	RecLock("ACDTRB",.F.)
	If !lInverte .and. (Empty(ACDTRB->TRB_QTD) .AND. ACDTRB->TRB_OPERAD # M->CBH_OPERAD)
		ACDTRB->TRB_OK:= "  "
	Else
		ACDTRB->TRB_OK:= cMarca
	EndIf
	ACDTRB->(MsUnlock())
EndIf
oDlg:Refresh()
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ MarcaTudo  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 29/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Seleciona todos os items da MarkBrowse                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MarcaTudo(cMarca,oDlg)
Local nRecno:= ACDTRB->(Recno())

While ! ACDTRB->(EOF())
	RecLock("ACDTRB",.F.)
	If Empty(ACDTRB->TRB_OK)
		ACDTRB->TRB_OK:= cMarca
	Elseif (Empty(ACDTRB->TRB_QTD) .AND. ACDTRB->TRB_OPERAD # M->CBH_OPERAD)
		ACDTRB->TRB_OK:= " "
	EndIf
	ACDTRB->(MsUnlock())
	ACDTRB->(DbSkip())
EndDo
ACDTRB->(DbGoto(nRecno))
oDlg:Refresh()
Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Fun‡„o   ³  Grava   º Autor ³ Anderson Rodrigues º Data ³TUE 24/03/04 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³  Executa rotina automatica da gravacao da Producao/Perda   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Grava(aCpsUsu,cLote,dValid)
Local cParTot	:= ""
Local dDtApon := If(CBH->(ColumnPos("CBH_DTAPON")) > 0, M->CBH_DTAPON, dDataBase) //Proteção para release 12.1.23

Default aCpsUsu := {}

If lConjunto
	GrvConjunto(aCpsUsu,cLote,dValid)//M->CBH_OP,M->CBH_OPERAC,M->CBH_RECUR,M->CBH_OPERAD,M->CBH_TIPO,M->CBH_QTD)
Else
	If CBH->(ColumnPos( "CBH_PARTOT" )) > 0
		cParTot := M->CBH_PARTOT
	EndIf
	If lMod1		
		CB023GRV(M->CBH_OP,M->CBH_OPERAC,M->CBH_TRANSA,cProduto,M->CBH_RECUR,M->CBH_OPERAD,M->CBH_TIPO,M->CBH_QTD,cLote,dValid,M->CBH_DTINI,M->CBH_HRINI,M->CBH_DTFIM,M->CBH_HRFIM,,aCpsUsu,cParTot,dDtApon)
	Else
		CB025GRV(M->CBH_OP,M->CBH_OPERAC,M->CBH_TRANSA,cProduto,M->CBH_RECUR,M->CBH_OPERAD,M->CBH_TIPO,M->CBH_QTD,cLote,dValid,M->CBH_DTINI,M->CBH_HRINI,M->CBH_DTFIM,M->CBH_HRFIM ,aCpsUsu, cParTot,dDtApon)
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ GrvConjunto³ Autor ³ Anderson Rodrigues  ³ Data ³ 29/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao do apontamento para os operadores selecionados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GrvConjunto(aCpsUsu,cLote,dValid)
Default aCpsUsu := {}

DbSelectArea("ACDTRB")
ACDTRB->(DbGoTop())
While ! ACDTRB->(EOF())
	If ! ACDTRB->(IsMark("TRB_OK"))
		ACDTRB->(DbSkip())
		Loop
	EndIf
	If lMod1
		CB023GRV(M->CBH_OP,M->CBH_OPERAC,M->CBH_TRANSA,cProduto,M->CBH_RECUR,ACDTRB->TRB_OPERAD,M->CBH_TIPO,ACDTRB->TRB_QTD,cLote,dValid,TRB_DTINI,TRB_HRINI,M->CBH_DTFIM,M->CBH_HRFIM,,aCpsUsu)
	Else
		CB025GRV(M->CBH_OP,M->CBH_OPERAC,M->CBH_TRANSA,cProduto,M->CBH_RECUR,ACDTRB->TRB_OPERAD,M->CBH_TIPO,ACDTRB->TRB_QTD,cLote,dValid,TRB_DTINI,TRB_HRINI,M->CBH_DTFIM,M->CBH_HRFIM,aCpsUsu)
	EndIf
	ACDTRB->(DbSkip())
Enddo

If oTempTable <> Nil
	oTempTable:Delete()
	oTempTable := Nil
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Fun‡„o   ³ AtuEmpenho º Autor ³ Anderson Rodrigues º Data ³FRI 02/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Volta o saldo dos produtos consumidos pela producao(D4_EMPROC) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function AtuEmpenho(cOP,cOperacao,nQtd)
Local cProduto := " "
Local cRoteiro := " "
Local cUltOper := " "
Local aSD3
Local nRecnoSD3
Local cNumSeq
Local cIdent
Local cArmProc   := GetMvNNR('MV_LOCPROC','99')

SC2->(DbSetOrder(1))
If ! SC2->(DbSeek(xFilial("SC2")+cOP))
	Return
EndIf
cProduto := SC2->C2_PRODUTO

If ! Empty(SC2->C2_ROTEIRO)
	cRoteiro:= SC2->C2_ROTEIRO
Else
	SB1->(dbSetorder(1))
	If SB1->(dbSeek(xFilial("SB1")+cProduto)) .And. !Empty(SB1->B1_OPERPAD)
		cRoteiro:= SB1->B1_OPERPAD
	Else
		cRoteiro:= StrZero(1, Len(SG2->G2_CODIGO))
	EndIf
EndIf

cUltOper:= CB023UG2(cProduto,cRoteiro) // Retorna o codigo da ultima operacao do roteiro existente no SG2

If cUltOper # cOperacao // Se nao for estorno da ultima operacao, nao deve devolver o saldo da requisicao
	Return
EndIf

SD4->(DbSetOrder(2))

If ! SD4->(DbSeek(xFilial("SD4")+Padr(cOP,Len(SD4->D4_OP))))
	Return
EndIf

aSD3      := SD3->(GetArea())
nRecnoSD3 := SD3->(Recno())
cOP       := SD3->D3_OP
cNumSeq   := SD3->D3_NUMSEQ
cIdent    := SD3->D3_IDENT
SD3->(DbSetOrder(1))
If SD3->(DbSeek(xFilial("SD3")+cOP))
	While SD3->(!Eof() .AND. D3_FILIAL+D3_OP == xFilial("SD3")+cOP)
		If (SD3->D3_CF == "DE2") .AND. (SD3->D3_NUMSEQ == cNumSeq) .AND. (SD3->D3_IDENT == cIdent) .AND. (Left(SD3->D3_COD,3) != "MOD") .AND. (SD3->D3_LOCAL == cArmProc)
			If SD4->(DbSeek(xFilial("SD4")+SD3->(D3_OP+D3_COD+D3_LOCAL)))
				RecLock("SD4",.F.)
				SD4->D4_EMPROC:= SD4->D4_EMPROC + SD3->D3_QUANT
				SD4->(MsUnlock())
			EndIf
		EndIf
		SD3->(DbSkip())
	Enddo
EndIf
RestArea(aSD3)
SD3->(DbGoto(nRecnoSD3))
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ACDA080R º Autor ³ Anderson Rodrigues º Data ³  12/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Monitoramento da Producao                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function ACDA080R()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private cString		:= "CBH"
Private aOrd         := {}
Private cDesc1       := STR0029 //"Este programa tem como objetivo imprimir informacoes necessarias para"
Private cDesc2       := STR0030 //"possibilitar o acompanhamento detalhado da producao de acordo com os "
Private cDesc3       := STR0031 //"parametros informados pelo usuario 											  "
Private cPict        := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "ACDA080R" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { STR0032, 1, STR0033, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cPerg        := "ACDA80"
Private titulo       := STR0034 //"Relatorio Monitoramento da Producao"
Private nLin         := 06
Private Cabec1       := ""
Private Cabec2       := ""
Private cbtxt        := STR0035 //"Regsitro(s) lido(s)"
Private cbcont       := 0
Private CONTFL       := 01
Private m_pag        := 01
Private lRet         := .T.
Private imprime      := .T.
Private wnrel        := "ACDA080R" // Coloque aqui o nome do arquivo usado para impressao em disco

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas como Parametros                                ¿
//³ MV_PAR01 = Da  Data             ?                                   ¿
//³ MV_PAR02 = Ate Data             ?                                   ¿
//³ MV_PAR03 = Da  OP               ?                                   ¿
//³ MV_PAR04 = Ate Ate OP           ?                                   ¿
//³ MV_PAR05 = Da  Transacao        ?                                   ¿
//³ MV_PAR06 = Ate Transacao        ?                                   ¿
//³ MV_PAR07 = Do  Operador         ?                                   ¿
//³ MV_PAR08 = Ate Operador         ?                                   ¿
//³ MV_PAR09 = Ordem para impressao ?                                   ¿
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

Pergunte(cPerg,.F.)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
EndIf

RptStatus({|| Relatorio() },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ Relatorioº Autor ³ Anderson Rodrigues º Data ³  12/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Relatorio()
Local cTotHrs  := " "
Local cTipo    := " "
Local cRecurso := " "
Local cCalend  := " "
Local nMinutos := 0
Local aDados   := {}
Local aDadosSH6:= {}

CBH->(DbSetOrder(6))
DbSeek(xFilial("CBH")+Dtos(MV_PAR01),.T.) // Posiciona no 1o.reg. satisfatorio
SetRegua(RecCount()-Recno())

While !EOF() .and. (CBH->CBH_DTINI >= MV_PAR01 .and. CBH->CBH_DTINI <= MV_PAR02)
	If Padr(CBH->CBH_OP,Len(SH6->H6_OP)) < MV_PAR03 .or. Padr(CBH->CBH_OP,Len(SH6->H6_OP)) > MV_PAR04
		CBH->(DbSkip())
		Loop
	EndIf
	If CBH->CBH_TRANSA < MV_PAR05 .or. CBH->CBH_TRANSA > MV_PAR06
		CBH->(DbSkip())
		Loop
	EndIf
	If CBH->CBH_OPERAD < MV_PAR07 .or. CBH->CBH_OPERAD > MV_PAR08
		CBH->(DbSkip())
		Loop
	EndIf
	IncRegua(STR0036) //"Imprimindo"
	If lAbortPrint
		@nLin,00 PSAY STR0037 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	cTipo:= RetTipo(CBH->CBH_TRANSA)
	If (Empty(CBH->CBH_DTFIM) .or. Empty(CBH->CBH_HRFIM)) .and. cTipo == "1"
		cRecurso:= CBRetRecur(CBH->CBH_OP,CBH->CBH_OPERAC)
		cCalend := Posicione("SH1",1,xFilial("SH1")+cRecurso,"H1_CALEND")
		cTotHrs :=  PmsHrsItvl(CBH->CBH_DTINI,CBH->CBH_HRINI,dDataBase,Left(Time(),5),cCalend,"",cRecurso,.T.)
		nMinutos:= If(cTotHrs-Int(cTotHrs)>0,(cTotHrs-Int(cTotHrs))*60,0)
		cTotHrs := StrZero(Int(cTotHrs),3)+":"+StrZero(nMinutos,2)
	ElseIf (!Empty(CBH->CBH_DTFIM) .or. !Empty(CBH->CBH_HRFIM)) .and. cTipo == "1"
		cRecurso:= CBRetRecur(CBH->CBH_OP,CBH->CBH_OPERAC)
		cCalend := Posicione("SH1",1,xFilial("SH1")+cRecurso,"H1_CALEND")
		cTotHrs := PmsHrsItvl(CBH->CBH_DTINI,CBH->CBH_HRINI,CBH->CBH_DTFIM,CBH->CBH_HRFIM,cCalend,"",cRecurso,.T.)
		nMinutos:= If(cTotHrs-Int(cTotHrs)>0,(cTotHrs-Int(cTotHrs))*60,0)
		cTotHrs := StrZero(Int(cTotHrs),3)+":"+StrZero(nMinutos,2)
	ElseIf cTipo $ "23"
		cRecurso:= CBRetRecur(CBH->CBH_OP,CBH->CBH_OPERAC)
		cCalend := Posicione("SH1",1,xFilial("SH1")+cRecurso,"H1_CALEND")
		cTotHrs :=  PmsHrsItvl(CBH->CBH_DTINI,CBH->CBH_HRINI,CBH->CBH_DTFIM,CBH->CBH_HRFIM,cCalend,"",cRecurso,.T.)
		nMinutos:= If(cTotHrs-Int(cTotHrs)>0,(cTotHrs-Int(cTotHrs))*60,0)
		cTotHrs := StrZero(Int(cTotHrs),3)+":"+StrZero(nMinutos,2)
	Else
		aDadosSH6:= RetDadosH6(CBH->CBH_OP,CBH->CBH_OPERAC,CBH->CBH_DTINI,CBH->CBH_HRINI,CBH->CBH_QTD,CBH->CBH_OPERAD)
	EndIf
	If Empty(aDadosSH6)
		aadd(aDados,{Padr(CBH->CBH_OP,Len(SH6->H6_OP)),;
		CBH->CBH_OPERAC,;
		CBH->CBH_TRANSA,;
		CBH->CBH_QTD,;
		Padr(CBH->CBH_OPERAD,Len(SH6->H6_OPERADO)),;
		CBH->CBH_DTINI,;
		CBH->CBH_HRINI,;
		CBH->CBH_DTFIM,;
		CBH->CBH_HRFIM,;
		cTotHrs,;
		CBH->CBH_TIPO,;
		CBH->CBH_DTINV,;
		CBH->CBH_HRINV,;
		CBH->(RECNO())})
	Else
		aadd(aDados,{aDadosSH6[1,1],; // --> OP
		aDadosSH6[1,2],; //--> Operacao
		CBH->CBH_TRANSA,; //--> Transacao
		(aDadosSH6[1,8]+aDadosSH6[1,9]),; //--> Quantidade
		aDadosSH6[1,11],; //--> Operador
		aDadosSH6[1,4],; //--> Data Inicio
		aDadosSH6[1,5],; //--> Hora Inicio
		aDadosSH6[1,6],; //--> Data Fim
		aDadosSH6[1,7],; //--> Hora Fim
		aDadosSH6[1,10],;//--> Total de Horas
		CBH->CBH_TIPO,;
		CBH->CBH_DTINV,;
		CBH->CBH_HRINV,;
		CBH->(RECNO())})
	EndIf
	cTotHrs  := " "
	nMinutos := 0
	aDadosSH6:= {}
	CBH->(Dbskip())
Enddo
Imprime(aDados)
Fim()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³ Imprime  º Autor ³ Anderson Rodrigues º Data ³  12/09/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela funcao Relatorio              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Imprime(aDados)
Local lRet := .t.
Local nX   := 0
Local aDadosImp:= {}

//aDados[nX,1] --> OP
//aDados[nX,2] --> Operacao
//aDados[nX,3] --> Transacao
//aDados[nX,4] --> Quantidade
//aDados[nX,5] --> Operador
//aDados[nX,6] --> Data Inicio
//aDados[nX,7] --> Hora Inicio
//aDados[nX,8] --> Data Fim
//aDados[nX,9] --> Hora Fim
//aDados[nX,10]--> Total de Horas
//aDados[nX,11]--> Tipo
//aDados[nX,12]--> Data Invertida
//aDados[nX,13]--> Hora Invertida
//aDados[nX,14]--> Recno da tabela CBH
If MV_PAR09 == 1
	// --> Ordem 1 do indice
	aDadosImp:= aSort(aDados,,,{|x,y| x[1]+x[3]+x[11]+x[2]+x[12]+x[13] < y[1]+y[3]+y[11]+y[2]+y[12]+y[13]})
Elseif MV_PAR09 == 2
	// --> Ordem 2 do indice
	aDadosImp:= aSort(aDados,,,{|x,y| x[1]+x[11]+x[3]+x[2]+Dtos(x[8])+x[9] < y[1]+y[11]+y[3]+y[2]+Dtos(y[8])+y[9]})
Elseif MV_PAR09 == 3
	// --> Ordem 3 do indice
	aDadosImp:= aSort(aDados,,,{|x,y| x[1]+x[11]+x[2]+x[3]+Str(x[14]) < y[1]+y[11]+y[2]+y[3]+Str(y[14])})
Elseif MV_PAR09 == 4
	// --> Ordem 4 do indice
	aDadosImp:= aSort(aDados,,,{|x,y| x[5]+x[12]+x[13]+Str(x[14]) < y[5]+y[12]+y[13]+Str(y[14])})
Elseif MV_PAR09 == 5
	// --> Ordem 5 do indice
	aDadosImp:= aSort(aDados,,,{|x,y| x[1]+x[2]+x[12]+x[13] < y[1]+y[2]+y[12]+y[13]})
Endif

SetRegua(RecCount()-Recno())

For nX:= 1 to Len(aDadosImp)
	IncRegua(STR0036) //"Imprimindo"
	If lAbortPrint
		@nLin,00 PSAY STR0037 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao do cabecalho do relatorio. . .                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		@nLin, 000 Psay STR0038 //"OP"
		@nLin, 015 Psay STR0039 //"Operacao"
		@nLin, 026 Psay STR0040 //"Transacao"
		@nLin, 038 Psay STR0041 //"Quantidade"
		@nLin, 051 Psay STR0042 //"Operador"
		@nLin, 064 Psay STR0043 //"Data Inicio"
		@nLin, 079 Psay STR0044 //"Hora Inicio"
		@nLin, 095 Psay STR0045 //"Data Fim"
		@nLin, 108 Psay STR0046 //"Hora Fim"
		@nLin, 120 Psay STR0047 //"Total Horas"
		nLin := nLin + 1
		@nLin, 000 Psay Replicate("*",132)
		nLin := nLin + 1
		lRet := .f.
	EndIf
	@nLin, 000 Psay aDadosImp[nX,1]
	@nLin, 018 Psay aDadosImp[nX,2]
	@nLin, 029 Psay aDadosImp[nX,3]
	@nLin, 031 Psay aDadosImp[nX,4] Picture "@E 999,999,999.99"
	@nLin, 052 Psay aDadosImp[nX,5]
	@nLin, 065 Psay aDadosImp[nX,6]
	@nLin, 081 Psay aDadosImp[nX,7]
	@nLin, 095 Psay aDadosImp[nX,8]
	@nLin, 110 Psay aDadosImp[nX,9]
	@nLin, 122 Psay aDadosImp[nX,10]
	nLin := nLin + 1
	If nLin > 59 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 06
		@nLin, 000 Psay STR0038 //"OP"
		@nLin, 015 Psay STR0039 //"Operacao"
		@nLin, 026 Psay STR0040 //"Transacao"
		@nLin, 038 Psay STR0041 //"Quantidade"
		@nLin, 051 Psay STR0042 //"Operador"
		@nLin, 064 Psay STR0043 //"Data Inicio"
		@nLin, 079 Psay STR0044 //"Hora Inicio"
		@nLin, 095 Psay STR0045 //"Data Fim"
		@nLin, 108 Psay STR0046 //"Hora Fim"
		@nLin, 120 Psay STR0047 //"Total Horas"
		nLin := nLin + 1
		@nLin, 000 Psay Replicate("*",132)
		nLin := nLin + 1
	EndIf
Next
Return

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Static Function Fim()

SET DEVICE TO SCREEN
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIf
MS_FLUSH()
Return

/*

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ RetDadosH6 ³ Autor ³ Anderson Rodrigues  ³ Data ³ 12/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna array contendo as informacoes do apontamento       ³±±
±±³          ³ gerado no SH6                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetDadosH6(cOP,cOperacao,dDtFim,cHrFim,nQtd,cOperador)
Local aDadosSH6:= {}

SH6->(DbSetOrder(1))
If SH6->(DbSeek(xFilial("SH6")+cOP))
	While ! SH6->(EOF()) .and. SH6->H6_OP == Padr(cOP,Len(SH6->H6_OP))
		If SH6->H6_OPERAC # cOperacao
			SH6->(DbSkip())
			Loop
		ElseIf SH6->H6_DATAFIN # dDtFim .or. SH6->H6_HORAFIN # cHrFim
			SH6->(DbSkip())
			Loop
		ElseIf (SH6->H6_QTDPROD+SH6->H6_QTDPERD) # nQtd
			SH6->(DbSkip())
			Loop
		ElseIf SH6->H6_OPERADO # cOperador
			SH6->(DbSkip())
			Loop
		EndIf
		aadd(aDadosSH6,{SH6->H6_OP,SH6->H6_OPERAC,SH6->H6_RECURSO,SH6->H6_DATAINI,SH6->H6_HORAINI,SH6->H6_DATAFIN,SH6->H6_HORAFIN,SH6->H6_QTDPROD,SH6->H6_QTDPERD,SH6->H6_TEMPO,SH6->H6_OPERADO})
		Exit
	Enddo
EndIf
Return(aDadosSH6)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ RetTipo    ³ Autor ³ Anderson Rodrigues  ³ Data ³ 12/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o tipo da transacao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetTipo(cTransa)
Local cTipo:= " "
Local nIndice:= CBH->(IndexOrd())
Local nRecno := CBH->(Recno())

CBI->(DbSetOrder(1))
If CBI->(DbSeek(xFilial("CBI")+cTransa))
	cTipo:= CBI->CBI_TIPO
EndIf
CBH->(DbSetOrder(nIndice))
CBH->(DbGoto(nRecno))
Return(cTipo)


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A080LotCtl³ Autor ³Aecio Ferreira Gomes  ³ Data ³ 11/01/10  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Faz valida‡„o dos Lotes digitados na cria‡„o               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080LotCtl                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A080LotCtl()
Local lRet:=.T.

If Empty(M->CBH_OP) .And. !Rastro(SC2->C2_PRODUTO) 
	Help(" ",1,"NAORASTRO")
	lRet:=.F.
EndIf   

If lRet
	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+SC2->C2_PRODUTO) .And. !Empty(M->CBH_OP) 
		M->CBH_DVALID:= dDataBase + SB1->B1_PRVALID
	EndIf	
EndIf

If Empty(M->CBH_LOTCTL)
	M->CBH_DVALID:= cTod('')
EndIf
	
Return lRet
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A080DesRot³ Autor ³ Paulo Fco. Cruz Nt. ³ Data ³ 28.06.2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a string a pesquisar no gatilho do campo CHB_OPERAC ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A080DesRot												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ACDA080													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A080DesRot(cOP, cOperac)
Local cRet		:= ""
Local aArea		:= GetArea()
Local aAreaSC2	:= SC2->(GetArea())
Local aAreaSG2	:= SG2->(GetArea())

Default cOP		:= ""
Default cOperac	:= ""

DbSelectArea("SC2")
SC2->(DbSetOrder(1))
SC2->(DbSeek(xFilial("SC2")+cOP))

DbSelectArea("SG2")
If Empty(SC2->C2_ROTEIRO)
	SG2->(DbSetOrder(3))
	SG2->(DbSeek(xFilial("SG2")+SC2->(C2_PRODUTO)+cOperac))
Else
	SG2->(DbSetOrder(1))
	SG2->(DbSeek(xFilial("SG2")+SC2->(C2_PRODUTO+C2_ROTEIRO)+cOperac))
EndIf

cRet := SG2->G2_DESCRI

RestArea(aArea)
SC2->(RestArea(aAreaSC2))
SG2->(RestArea(aAreaSG2))

Return cRet
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A080ValWMS³ Autor ³ Alexsander Correa   ³ Data ³ 03.07.2018 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Efetua a validacao da situação da integracao com o WMS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³A080ValWMS												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ACDA080													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A080ValWMS(cOP)
Local lRet      := .T.
Local cQuery    := ""
Local cAliasSD3 := ""
	// Valida se há integração com WMS
	cQuery := "SELECT SD3.R_E_C_N_O_ RECNOSD3"
	cQuery +=  " FROM "+RetSqlName('SD3')+" SD3"
	cQuery += " WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"'"
	cQuery +=   " AND SD3.D3_OP = '"+cOP+"'"
	cQuery +=   " AND SD3.D3_ESTORNO <> 'S'"
	cQuery +=   " AND SD3.D3_IDDCF <> '"+Space(TamSx3("D3_IDDCF")[1])+"'"
	cQuery +=   " AND SD3.D3_TM < '500'"
	cQuery +=   " AND SD3.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	cAliasSD3 := GetNextAlias()
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasSD3,.F.,.T.)
	If (cAliasSD3)->(!Eof())
		lRet := WmsAvalSC2("2",,,,(cAliasSD3)->RECNOSD3)
	EndIf
	(cAliasSD3)->(dbCloseArea())
Return lRet


/*/{Protheus.doc} Menudef
	(long_description)
	@type  Static Function
	@author TOTVS
	@since 21/02/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function MenuDef()

Local aRotMenu := { }


aRotMenu :=  {		{ STR0002, "AxPesqui",    0, 1},; //"Pesquisar"
					{ STR0003, "AxVisual",    0, 2},; //"Visualizar"
					{ STR0004, "ACDA080A",    0, 3},; //"Incluir"
					{ STR0005, "ACDA080A",    0, 4},; //"Alterar"
					{ STR0006, "ACDA080A",    0, 5},; //"Excluir"
					{ STR0007, "ACDA080R",    0, 4},; //"Relatorio"
					{ STR0008, "ACDA080Lg",   0, 3} } //"Legenda"

 
 RETURN aRotMenu







